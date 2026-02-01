#!/bin/bash

# Ad-on-Wheels Backend Stop Script
# Stops all running microservices

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Stopping Backend Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Default: stop without removing volumes
REMOVE_VOLUMES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean|-c)
            REMOVE_VOLUMES=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./stop.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --clean, -c    Stop and remove all data (volumes)"
            echo "  --help, -h     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "${YELLOW} This will stop all services and DELETE all database data!${NC}"
    read -p "Are you sure? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo "Stopping services and removing volumes..."
    docker compose down -v
    echo ""
    echo -e "${GREEN}✓ Services stopped and all data removed${NC}"
else
    echo "Stopping services (data will be preserved)..."
    docker compose down
    echo ""
    echo -e "${GREEN}✓ Services stopped${NC}"
    echo ""
    echo "To remove all data, run:"
    echo "  ${YELLOW}./scripts/stop.sh --clean${NC}"
fi
