#!/bin/bash

# Ad-on-Wheels Backend Start Script
# Starts all microservices using Docker Compose

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ad-on-Wheels Backend Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker Compose is available
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed!${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED} .env file not found!${NC}"
    echo "Run ./scripts/build.sh first to create .env file"
    exit 1
fi

# Check if JAR files are built
if [ ! -f "auth-service/target/auth-service-0.0.1-SNAPSHOT.jar" ]; then
    echo -e "${YELLOW} JAR files not found!${NC}"
    echo "Running build first..."
    ./scripts/build.sh
fi

echo -e "${GREEN}✓ All checks passed${NC}"
echo ""
echo -e "${BLUE}Starting all services...${NC}"
echo ""
echo "Services that will start:"
echo "  1. MySQL Database        (Port 3306)"
echo "  2. Eureka Server         (Port 8761)"
echo "  3. Auth Service          (Port 8085)"
echo "  4. Driver Service        (Port 8082)"
echo "  5. Company Service       (Port 8083)"
echo "  6. Campaign Service      (Port 8084)"
echo "  7. Gateway Service       (Port 8080) ← Main API Entry"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Start services with Docker Compose
docker compose up --build

# Note: This line only executes if user stops the services
echo ""
echo -e "${BLUE}Services stopped${NC}"
