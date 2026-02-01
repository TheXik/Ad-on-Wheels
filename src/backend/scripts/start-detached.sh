#!/bin/bash

# Ad-on-Wheels Backend Start Script (Background Mode)
# Starts all microservices in detached mode (runs in background)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Starting Backend (Background Mode)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found!${NC}"
    echo "Run ./scripts/build.sh first"
    exit 1
fi

# Start services in detached mode
docker compose up -d --build

echo ""
echo -e "${GREEN}✓ All services started in background!${NC}"
echo ""
echo "View logs with:"
echo "  ${YELLOW}./scripts/logs.sh${NC}              - View all logs"
echo "  ${YELLOW}./scripts/logs.sh auth-service${NC}  - View specific service logs"
echo ""
echo "Stop services with:"
echo "  ${YELLOW}./scripts/stop.sh${NC}"
echo ""
echo "Check status:"
echo "  ${YELLOW}docker compose ps${NC}"
