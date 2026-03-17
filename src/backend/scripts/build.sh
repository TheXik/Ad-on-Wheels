#!/bin/bash

# Ad-on-Wheels Backend Build Script
# This script builds all microservices using Maven in a Docker container

set -e 

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ad-on-Wheels Backend Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED} Docker is not installed!${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✓ Docker found${NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW} .env file not found!${NC}"
    echo "Creating .env file with default values..."
    cat > .env << EOF
# MySQL Configuration
MYSQL_ROOT_PASSWORD=root_password
MYSQL_USER=ad_on_wheels_user
MYSQL_PASSWORD=test

# JWT Secret Key (change this in production!)
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this-in-production-min-256-bits
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
fi

# Create .m2 directory for Maven cache
mkdir -p ~/.m2

echo -e "${BLUE}Building all microservices...${NC}"
echo "This may take 5-10 minutes on first run (downloading dependencies)"
echo ""

# Run Maven build in Docker container
docker run --rm \
  -v "$(pwd)":/app \
  -v ~/.m2:/root/.m2 \
  -w /app \
  maven:3.9-eclipse-temurin-21 \
  mvn package -DskipTests

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Build Successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "JAR files created in:"
echo "  - auth-service/target/auth-service-0.0.1-SNAPSHOT.jar"
echo "  - driver-service/target/driver-service-0.0.1-SNAPSHOT.jar"
echo "  - company-service/target/company-service-0.0.1-SNAPSHOT.jar"
echo "  - campaign-service/target/campaign-service-0.0.1-SNAPSHOT.jar"
echo "  - ride-service/target/ride-service-0.0.1-SNAPSHOT.jar"
echo "  - gateway-service/target/gateway-service-0.0.1-SNAPSHOT.jar"
echo "  - eureka-server/target/eureka-server-0.0.1-SNAPSHOT.jar"
echo ""
echo -e "${BLUE}Next step: Run ${YELLOW}./scripts/start.sh${BLUE} to start all services${NC}"
