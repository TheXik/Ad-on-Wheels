#!/bin/bash
set -e

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. See https://docs.docker.com/get-docker/"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo ".env not found, creating one with default values."
    cat > .env << EOF
MYSQL_ROOT_PASSWORD=root_password
MYSQL_USER=ad_on_wheels_user
MYSQL_PASSWORD=test
JWT_SECRET_KEY=dev-jwt-secret-rotate-before-deploy-min-256-bits
EOF
fi

mkdir -p ~/.m2

echo "Building all microservices (5-10 min on first run)..."
docker run --rm \
  -v "$(pwd)":/app \
  -v ~/.m2:/root/.m2 \
  -w /app \
  maven:3.9-eclipse-temurin-21 \
  mvn clean package -DskipTests

echo "Build done. Run ./scripts/start.sh to start services."
