#!/bin/bash

if [ -z "$1" ]; then
    echo "Tailing all service logs. Ctrl+C to stop."
    docker compose logs -f
    exit 0
fi

SERVICE=$1
VALID=("mysql" "cassandra" "eureka-server" "gateway-service" "auth-service" "driver-service" "company-service" "campaign-service" "ride-service")

if ! printf '%s\n' "${VALID[@]}" | grep -qx "$SERVICE"; then
    echo "Unknown service: $SERVICE"
    echo "Valid: ${VALID[*]}"
    echo "Usage: ./logs.sh [service-name]"
    exit 1
fi

echo "Tailing $SERVICE logs. Ctrl+C to stop."
docker compose logs -f "$SERVICE"
