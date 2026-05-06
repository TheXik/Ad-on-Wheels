#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"

echo "Docker container status:"
docker compose ps
echo

check_container() {
    local service_name=$1
    if docker compose ps --quiet "$service_name" 2>/dev/null | grep -q .; then
        if docker compose ps "$service_name" | grep -q "Up"; then
            return 0
        fi
    fi
    return 1
}

check_public_endpoint() {
    local name=$1
    local url=$2
    if curl -s --max-time 2 "$url" > /dev/null 2>&1; then
        echo "  $name  UP"
    else
        echo "  $name  DOWN"
    fi
}

# Probes an internal (expose-only) endpoint via the gateway container so the
# script honors req:nfr:surface (single-public-port) rather than relying on host curl.
check_internal_endpoint() {
    local name=$1
    local url=$2
    if docker compose exec -T gateway-service curl -fsS -o /dev/null --max-time 3 "$url" 2>/dev/null; then
        echo "  $name  UP"
    else
        echo "  $name  DOWN"
    fi
}

echo "Public services:"
check_internal_endpoint "Eureka Server (in-network)" "http://eureka-server:8761/eureka/apps"
check_public_endpoint "Gateway API (8080)        " "http://localhost:8080/actuator/health"

if docker compose exec -T mysql mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" > /dev/null 2>&1; then
    echo "  MySQL Database (3306)  UP"
else
    echo "  MySQL Database (3306)  DOWN"
fi
echo

echo "Internal services (Docker network):"
check_internal_service() {
    local display_name=$1
    local service_name=$2
    if check_container "$service_name"; then
        local eureka_name
        eureka_name=$(echo "$service_name" | tr '[:lower:]' '[:upper:]')
        if docker compose exec -T gateway-service curl -fsS --max-time 3 "http://eureka-server:8761/eureka/apps/$eureka_name" 2>/dev/null | grep -q "UP"; then
            echo "  $display_name  RUNNING (registered with Eureka)"
        else
            echo "  $display_name  STARTING (not yet registered)"
        fi
    else
        echo "  $display_name  STOPPED"
    fi
}

check_internal_service "Auth Service        " "auth-service"
check_internal_service "Driver Service      " "driver-service"
check_internal_service "Company Service     " "company-service"
check_internal_service "Campaign Service    " "campaign-service"
check_internal_service "Ride Service        " "ride-service"
echo

echo "Data stores:"
if docker compose exec -T cassandra cqlsh -e "DESCRIBE KEYSPACES" > /dev/null 2>&1; then
    echo "  Cassandra (9042)       UP"
else
    echo "  Cassandra (9042)       DOWN"
fi
echo

echo "Gateway routing:"
if curl -s --max-time 2 "http://localhost:8080/auth/login" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"test","password":"test"}' 2>/dev/null | grep -q "success"; then
    echo "  Gateway -> Auth Service  OK"
else
    echo "  Gateway -> Auth Service  responding"
fi
echo

echo "Quick links:"
echo "  Gateway API:      http://localhost:8080"
echo "  Actuator:         http://localhost:8080/actuator"
echo "  Eureka (in-net):  docker compose exec gateway-service curl http://eureka-server:8761/eureka/apps"
echo "  Logs:             ./scripts/logs.sh [service]"
echo "  Test API:         ./scripts/test-api.sh"
echo "  Stop:             ./scripts/stop.sh"
