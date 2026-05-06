#!/bin/bash
# Gateway authorization negative tests for chap 5.4 (req:nfr:surface, design-comm).
# Run: bash gateway-403-tests.sh > gateway-403-tests.log 2>&1
# Requires: curl, jq, Tailscale-connected backend at $GATEWAY.

set -u
GATEWAY="${GATEWAY:-http://100.122.33.104:8080}"
DRIVER_EMAIL="eval-driver-01@test.dev"
COMPANY_EMAIL="eval-company-01@test.dev"
PASSWORD="EvalTest2026!"

echo "=========================================="
echo "Gateway authorization negative tests"
echo "Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "Target: $GATEWAY"
echo "=========================================="

login() {
    local email="$1"
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"email\":\"${email}\",\"password\":\"${PASSWORD}\"}" \
        "${GATEWAY}/auth/login" | jq -r '.data.token // empty'
}

echo ""; echo "[STEP] Logging in driver and company to obtain JWTs ..."
DRIVER_JWT=$(login "$DRIVER_EMAIL")
COMPANY_JWT=$(login "$COMPANY_EMAIL")
[ -z "$DRIVER_JWT" ] && { echo "FAIL: driver login returned no token"; exit 1; }
[ -z "$COMPANY_JWT" ] && { echo "FAIL: company login returned no token"; exit 1; }
echo "  driver JWT: ${DRIVER_JWT:0:32}... (${#DRIVER_JWT} chars)"
echo "  company JWT: ${COMPANY_JWT:0:32}... (${#COMPANY_JWT} chars)"

run_test() {
    local label="$1"
    local expected_code="$2"
    shift 2
    local code body
    body=$(curl -s -o /dev/null -w "%{http_code}" "$@")
    code="$body"
    if [ "$code" = "$expected_code" ]; then
        echo "  PASS  $label  -> HTTP $code (expected $expected_code)"
    else
        echo "  FAIL  $label  -> HTTP $code (expected $expected_code)"
    fi
}

echo ""; echo "[NEGATIVE] G1 -- COMPANY token on driver-scoped GET"
run_test "G1 company on /api/drivers/{id}" 403 \
    -X GET -H "Authorization: Bearer ${COMPANY_JWT}" \
    "${GATEWAY}/api/drivers/00000000-0000-0000-0000-000000000000"

echo ""; echo "[NEGATIVE] G2 -- DRIVER token on company-scoped POST"
run_test "G2 driver on POST /api/companies" 403 \
    -X POST -H "Authorization: Bearer ${DRIVER_JWT}" \
    -H "Content-Type: application/json" -d '{}' \
    "${GATEWAY}/api/companies"

echo ""; echo "[NEGATIVE] G3 -- forged X-User-Role header on DRIVER token"
run_test "G3 forged ADMIN role header" 403 \
    -X POST -H "Authorization: Bearer ${DRIVER_JWT}" \
    -H "X-User-Role: ADMIN" \
    -H "Content-Type: application/json" -d '{}' \
    "${GATEWAY}/api/companies"

echo ""; echo "[POSITIVE] G4 -- DRIVER token on driver-scoped GET (should pass)"
run_test "G4 driver on /api/drivers/{id} with own id"  200 \
    -X GET -H "Authorization: Bearer ${DRIVER_JWT}" \
    "${GATEWAY}/api/drivers/$(curl -s -H "Authorization: Bearer ${DRIVER_JWT}" "${GATEWAY}/auth/me" | jq -r '.data.userId // .data.id // empty')"

echo ""; echo "[NEGATIVE] G5 -- @NoHtml validator (script tag in description)"
PAYLOAD='{"name":"x","description":"<script>alert(1)</script>","startDate":"2026-06-01","endDate":"2026-07-01","totalBudget":100,"driverPayPerKm":0.1,"maxDrivers":1,"estimatedReach":100}'
run_test "G5 NoHtml on Campaign.description" 400 \
    -X POST -H "Authorization: Bearer ${COMPANY_JWT}" \
    -H "Content-Type: application/json" -d "$PAYLOAD" \
    "${GATEWAY}/api/campaigns"

echo ""; echo "=========================================="
echo "Done."
echo "=========================================="
