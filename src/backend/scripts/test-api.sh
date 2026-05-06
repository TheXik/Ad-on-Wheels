#!/bin/bash

BASE_URL="http://localhost:8080"

PASSED=0
FAILED=0

test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5

    echo "Testing: $test_name"

    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi

    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$status_code" -eq "$expected_status" ]; then
        echo "  PASSED (status $status_code)"
        ((PASSED++))
    else
        echo "  FAILED (expected $expected_status, got $status_code)"
        ((FAILED++))
    fi

    echo "  Body: ${body:0:100}"
    echo
}

echo "Note: some tests may fail if data already exists."
echo

test_endpoint "Register Driver" "POST" "/auth/register" \
    '{"name":"Test Driver","email":"driver_'$(date +%s)'@test.com","password":"thesis-test-pwd","role":"DRIVER"}' 200

test_endpoint "Register Company" "POST" "/auth/register" \
    '{"name":"Test Company","email":"company_'$(date +%s)'@test.com","password":"thesis-test-pwd","role":"COMPANY"}' 200

test_endpoint "Login Driver" "POST" "/auth/login" \
    '{"email":"driver@test.com","password":"thesis-test-pwd"}' 200

# Token-required endpoints; a bare hit without a JWT should yield 401.
test_endpoint "Get All Drivers (no token)"   "GET" "/drivers"   "" 401
test_endpoint "Get All Companies (no token)" "GET" "/companies" "" 401
test_endpoint "Get All Campaigns (no token)" "GET" "/campaigns" "" 401

echo "Results: $PASSED passed, $FAILED failed"
[ $FAILED -eq 0 ] && exit 0 || exit 1
