#!/bin/bash

# Ad-on-Wheels Clean Script
# Removes all built artifacts and Docker resources for a fresh start

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ad-on-Wheels Clean Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW} This will remove:${NC}"
echo "  - All compiled JAR files (target/ directories)"
echo "  - All Docker containers and images"
echo "  - All database data (MySQL volumes)"
echo "  - Maven cache (.m2 directory will be preserved)"
echo ""

read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Cleaning...${NC}"
echo ""

# Stop and remove Docker containers and volumes
echo "1. Stopping Docker containers..."
docker compose down -v 2>/dev/null || true

# Remove Docker images
echo "2. Removing Docker images..."
docker rmi -f eureka-server gateway-service auth-service driver-service company-service campaign-service ride-service 2>/dev/null || true

# Clean Maven target directories
echo "3. Cleaning Maven build artifacts..."
find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true

# Clean common-dto
if [ -d "common-dto/target" ]; then
    rm -rf common-dto/target
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Fresh start instructions:"
echo "  1. Run ${YELLOW}./scripts/build.sh${NC} to rebuild everything"
echo "  2. Run ${YELLOW}./scripts/start.sh${NC} to start services"
echo ""
echo "Note: Maven cache (~/.m2) was preserved to speed up rebuilds"
