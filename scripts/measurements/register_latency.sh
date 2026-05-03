#!/usr/bin/env bash
# Measures end-to-end latency of POST /auth/register over N fresh accounts.
# Each iteration uses a unique email so the saga's happy path is exercised.
#
# Fills chap05 placeholder: REGISTER_LATENCY_MEDIAN_S, REGISTER_LATENCY_P95_S.
#
# Usage:
#   scripts/measurements/register_latency.sh [N]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/measurements/_lib.sh"

N="${1:-50}"

require_curl
ensure_gateway_up

echo "Gateway   : $GATEWAY"
echo "Iterations: $N"
echo

prefix="bench-$(date +%s)"

{
    for i in $(seq 1 "$N"); do
        email="${prefix}-${i}@example.com"
        body=$(cat <<EOF
{"email":"$email","password":"password123","name":"Bench User $i","role":"DRIVER"}
EOF
)
        curl -fsS -o /dev/null \
            -w "%{time_total}\n" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "$body" \
            "$GATEWAY/auth/register"
    done
} | stats_from_stdin
