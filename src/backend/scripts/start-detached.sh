#!/bin/bash
set -e

if [ ! -f ".env" ]; then
    echo ".env not found. Run ./scripts/build.sh first."
    exit 1
fi

docker compose up -d --build

echo "Services started in background."
echo "  Logs:    ./scripts/logs.sh [service-name]"
echo "  Stop:    ./scripts/stop.sh"
echo "  Status:  docker compose ps"
