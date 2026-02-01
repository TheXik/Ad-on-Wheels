#!/bin/bash

# Ad-on-Wheels API Testing Script
# Tests all major API endpoints

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ad-on-Wheels API Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

BASE_URL="http://localhost:8080"

# Test counters
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5

    echo -e "${BLUE}Testing:${NC} $test_name"

    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi

    # Extract status code (last line)
    status_code=$(echo "$response" | tail -n1)
    # Extract body (everything except last line)
    body=$(echo "$response" | sed '$d')

    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC} (Status: $status_code)"
        ((PASSED++))
    else
        echo -e "  ${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        ((FAILED++))
    fi

    echo "  Response: ${body:0:100}"
    echo ""
}

echo -e "${YELLOW}Note: Some tests may fail if data already exists${NC}"
echo ""

# Test 1: Register a Driver
test_endpoint \
    "Register Driver" \
    "POST" \
    "/auth/register" \
    '{"name":"Test Driver","email":"driver_'$(date +%s)'@test.com","password":"password123","role":"DRIVER"}' \
    200

# Test 2: Register a Company
test_endpoint \
    "Register Company" \
    "POST" \
    "/auth/register" \
    '{"name":"Test Company","email":"company_'$(date +%s)'@test.com","password":"password123","role":"COMPANY"}' \
    200

# Test 3: Login
test_endpoint \
    "Login Driver" \
    "POST" \
    "/auth/login" \
    '{"email":"driver@test.com","password":"password123"}' \
    200

# Test 4: Get All Drivers (requires authentication - might fail)
test_endpoint \
    "Get All Drivers" \
    "GET" \
    "/drivers" \
    "" \
    401  # Expecting 401 Unauthorized without token

# Test 5: Get All Companies (requires authentication - might fail)
test_endpoint \
    "Get All Companies" \
    "GET" \
    "/companies" \
    "" \
    401  # Expecting 401 Unauthorized without token

# Test 6: Get All Campaigns (requires authentication - might fail)
test_endpoint \
    "Get All Campaigns" \
    "GET" \
    "/campaigns" \
    "" \
    401  # Expecting 401 Unauthorized without token

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Test Results${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed${NC}"
    exit 1
fi
