#!/bin/bash
set -e

if ! command -v docker compose &> /dev/null; then
    echo "Docker Compose is not installed."
    exit 1
fi

if [ ! -f ".env" ]; then
    echo ".env not found. Run ./scripts/build.sh first."
    exit 1
fi

SERVICES=("auth-service" "driver-service" "company-service" "campaign-service" "ride-service" "gateway-service" "eureka-server")
for svc in "${SERVICES[@]}"; do
    if [ ! -f "$svc/target/$svc-0.0.1-SNAPSHOT.jar" ]; then
        echo "JARs missing, running build first."
        ./scripts/build.sh
        break
    fi
done

echo "Starting services. Gateway will be on http://localhost:8080. Ctrl+C to stop."
docker compose up --build

echo "Services stopped."
