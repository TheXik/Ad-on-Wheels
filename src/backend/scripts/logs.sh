#!/bin/bash

# Ad-on-Wheels Backend Logs Viewer
# View logs from running services

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if a specific service is requested
if [ -z "$1" ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Viewing ALL Service Logs${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    docker compose logs -f
else
    SERVICE=$1

    # Validate service name
    VALID_SERVICES=("mysql" "eureka-server" "gateway-service" "auth-service" "driver-service" "company-service" "campaign-service")

    if [[ ! " ${VALID_SERVICES[@]} " =~ " ${SERVICE} " ]]; then
        echo -e "${YELLOW}Unknown service: $SERVICE${NC}"
        echo ""
        echo "Valid services:"
        for svc in "${VALID_SERVICES[@]}"; do
            echo "  - $svc"
        done
        echo ""
        echo "Usage:"
        echo "  ${GREEN}./logs.sh${NC}              - View all logs"
        echo "  ${GREEN}./logs.sh auth-service${NC}  - View specific service logs"
        exit 1
    fi

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Viewing Logs: $SERVICE${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    docker compose logs -f "$SERVICE"
fi
