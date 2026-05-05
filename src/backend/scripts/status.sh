#!/bin/bash

# Ad-on-Wheels Backend Status Checker
# Check status of all services and endpoints

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ad-on-Wheels Backend Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check Docker containers
echo -e "${BLUE}Docker Container Status:${NC}"
docker compose ps
echo ""

# Function to check if container is running
check_container() {
    local service_name=$1
    if docker compose ps --quiet "$service_name" 2>/dev/null | grep -q .; then
        if docker compose ps "$service_name" | grep -q "Up"; then
            return 0
        fi
    fi
    return 1
}

# Check public endpoints (exposed to host)
echo -e "${BLUE}Public Services (Accessible from Host):${NC}"
echo ""

# Function to check public endpoint
check_public_endpoint() {
    local name=$1
    local url=$2

    if curl -s --max-time 2 "$url" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $name - ${GREEN}UP${NC}"
    else
        echo -e "  ${RED}✗${NC} $name - ${RED}DOWN${NC}"
    fi
}

# Function to probe an internal (expose-only) endpoint via the gateway container.
# Eureka and the per-service Eureka registration check go through here so that the
# script honors req:nfr:surface (single-public-port) instead of relying on host curl.
check_internal_endpoint() {
    local name=$1
    local url=$2

    if docker compose exec -T gateway-service curl -fsS -o /dev/null --max-time 3 "$url" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name - ${GREEN}UP${NC}"
    else
        echo -e "  ${RED}✗${NC} $name - ${RED}DOWN${NC}"
    fi
}

check_internal_endpoint "Eureka Server (in-network)" "http://eureka-server:8761/eureka/apps"
check_public_endpoint "Gateway API (8080)        " "http://localhost:8080/actuator/health"

# Check MySQL
if docker compose exec -T mysql mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} MySQL Database (3306)  - ${GREEN}UP${NC}"
else
    echo -e "  ${RED}✗${NC} MySQL Database (3306)  - ${RED}DOWN${NC}"
fi

echo ""

# Check internal services (only accessible within Docker network)
echo -e "${BLUE}Internal Services (Docker Network Only):${NC}"
echo ""

# Function to check internal service
check_internal_service() {
    local display_name=$1
    local service_name=$2

    if check_container "$service_name"; then
        # Convert service name to uppercase for Eureka check (e.g., auth-service -> AUTH-SERVICE)
        local eureka_name
        eureka_name=$(echo "$service_name" | tr '[:lower:]' '[:upper:]' | tr '-' '-')

        # Check if service is registered with Eureka (better health indicator).
        # Probe via the gateway container so we honor req:nfr:surface (Eureka is expose-only).
        if docker compose exec -T gateway-service curl -fsS --max-time 3 "http://eureka-server:8761/eureka/apps/$eureka_name" 2>/dev/null | grep -q "UP"; then
            echo -e "  ${GREEN}✓${NC} $display_name - ${GREEN}RUNNING${NC} ${CYAN}(registered with Eureka)${NC}"
        else
            echo -e "  ${YELLOW}⚡${NC} $display_name - ${YELLOW}STARTING${NC} ${CYAN}(not yet registered)${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} $display_name - ${RED}STOPPED${NC}"
    fi
}

check_internal_service "Auth Service        " "auth-service"
check_internal_service "Driver Service      " "driver-service"
check_internal_service "Company Service     " "company-service"
check_internal_service "Campaign Service    " "campaign-service"
check_internal_service "Ride Service        " "ride-service"

echo ""
echo -e "${BLUE}Data Stores:${NC}"
echo ""

# Check Cassandra
if docker compose exec -T cassandra cqlsh -e "DESCRIBE KEYSPACES" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Cassandra (9042)       - ${GREEN}UP${NC}"
else
    echo -e "  ${RED}✗${NC} Cassandra (9042)       - ${RED}DOWN${NC}"
fi

echo ""
echo -e "${CYAN}ℹ  Internal services are only accessible through the Gateway${NC}"
echo ""

# Test Gateway routing
echo -e "${BLUE}Gateway Routing Test:${NC}"
echo ""

# Test if we can reach auth service through gateway
if curl -s --max-time 2 "http://localhost:8080/auth/login" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"test","password":"test"}' 2>/dev/null | grep -q "success"; then
    echo -e "  ${GREEN}✓${NC} Gateway → Auth Service routing ${GREEN}OK${NC}"
else
    echo -e "  ${YELLOW}⚡${NC} Gateway → Auth Service routing ${YELLOW}responding${NC}"
fi

echo ""
echo -e "${BLUE}Quick Links:${NC}"
echo "  Gateway API:      ${YELLOW}http://localhost:8080${NC}"
echo "  API Docs:         ${YELLOW}http://localhost:8080/actuator${NC}"
echo "  Eureka (in-net):  ${YELLOW}docker compose exec gateway-service curl http://eureka-server:8761/eureka/apps${NC}"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "  View all logs:     ${GREEN}./scripts/logs.sh${NC}"
echo "  View auth logs:    ${GREEN}./scripts/logs.sh auth-service${NC}"
echo "  Test API:          ${GREEN}./scripts/test-api.sh${NC}"
echo "  Stop services:     ${GREEN}./scripts/stop.sh${NC}"
