# Ad-on-Wheels Backend

Java microservices backend for the Ad-on-Wheels platform - connecting drivers with advertising companies.

## Architecture Overview

This backend consists of **6 microservices** built with Spring Boot and Spring Cloud:

| Service | Port | Description |
|---------|------|-------------|
| **Eureka Server** | 8761 | Service discovery and registry |
| **Gateway Service** | 8080 | API Gateway + BFF (Backend for Frontend) |
| **Auth Service** | 8085 | Authentication, JWT management, SAGA orchestration |
| **Driver Service** | 8082 | Driver profile management |
| **Company Service** | 8083 | Company profile management |
| **Campaign Service** | 8084 | Campaign and application management |

### Tech Stack

- **Java**: 21 (Eclipse Temurin)
- **Spring Boot**: 3.4.3
- **Spring Cloud**: 2024.0.0
- **Database**: MySQL 8.0
- **Build Tool**: Maven 3.9+
- **Container**: Docker & Docker Compose

## Prerequisites

### Required
- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ (included with Docker Desktop)

### Optional (for local development without Docker)
- **Java 21**
- **Maven 3.9+**

**Note**: You don't need Java or Maven installed locally if you use our build scripts (recommended)!

## Quick Start (3 Steps)

### 1. Build All Microservices

```bash
cd /path/to/Ad-on-Wheels/src/backend
./scripts/build.sh
```

**What this does:**
- Creates `.env` file with default configuration (if missing)
- Downloads Maven and Java 21 in a Docker container
- Compiles all 6 microservices


### 2. Start All Services

```bash
./scripts/start.sh
```

**What this does:**
- Starts MySQL database with health checks
- Starts Eureka Server and waits for it to be ready
- Starts all business services (auth, driver, company, campaign)
- Starts Gateway Service last (depends on all other services)

**Wait for this message:**
```
gateway-service | Started GatewayServiceApplication
```

### 3. Verify Everything Works

```bash
./scripts/status.sh
```

**Expected output:**
```
Eureka Server    - UP
Gateway Service  - UP
Auth Service     - UP
Driver Service   - UP
Company Service  - UP
Campaign Service - UP
MySQL Database   - UP
```

## Helper Scripts Reference

###  `./scripts/build.sh`
Builds all microservices using Maven in Docker.

**Usage:**
```bash
./scripts/build.sh
```

**What it does:**
1. Checks if Docker is installed
2. Creates `.env` file if missing
3. Runs `mvn clean package -DskipTests` in Docker container
4. Outputs JAR files to `<service>/target/` directories



---

###  `./scripts/start.sh`
Starts all services in foreground (interactive mode).

**Usage:**
```bash
./scripts/start.sh
```

**What it does:**
1. Validates that JAR files exist (runs build if needed)
2. Starts all 7 containers with `docker compose up --build`
3. Shows live logs from all services
4. Blocks terminal (press `Ctrl+C` to stop)

**Best for:** Development when you want to see all logs.

---

###  `./scripts/start-detached.sh`
Starts all services in background (detached mode).

**Usage:**
```bash
./scripts/start-detached.sh
```

**What it does:**
1. Starts all services with `docker compose up -d`
2. Returns control to terminal immediately
3. Services run in background

**Best for:** When you want to continue working in the same terminal.

**View logs after starting:**
```bash
./scripts/logs.sh
```

---

###  `./scripts/stop.sh`
Stops all running services.

**Usage:**
```bash
# Stop services
./scripts/stop.sh

# Stop services and DELETE all data
./scripts/stop.sh --clean
```

**Options:**
- No flags: Stops containers, preserves database data
- `--clean` or `-c`: Stops containers AND removes all volumes (database data)

**Warning:** `--clean` flag will delete all database records!

---

###  `./scripts/status.sh`
Checks status of all services and endpoints.

**Usage:**
```bash
./scripts/status.sh
```

**What it shows:**
- Docker container status
- Health check results for each service
- MySQL connection status
- Quick links to Eureka Dashboard and Gateway API

---

###  `./scripts/logs.sh`
View logs from running services.

**Usage:**
```bash
# View ALL service logs
./scripts/logs.sh

# View specific service logs
./scripts/logs.sh auth-service
./scripts/logs.sh gateway-service
./scripts/logs.sh mysql
```

**Valid service names:**
- `mysql`
- `eureka-server`
- `gateway-service`
- `auth-service`
- `driver-service`
- `company-service`
- `campaign-service`

**Press `Ctrl+C` to stop viewing logs** (services keep running).

---

###  `./scripts/test-api.sh`
Runs automated API tests against all endpoints.

**Usage:**
```bash
./scripts/test-api.sh
```

**What it tests:**
1. Driver registration
2. Company registration
3. User login
4. Protected endpoints (expecting 401 Unauthorized)

**Example output:**
```
Testing: Register Driver
  ✓ PASSED (Status: 200)

Testing: Login Driver
  ✓ PASSED (Status: 200)

Test Results
  Passed: 5
  Failed: 0
✓ All tests passed!
```

---

###  `./scripts/clean.sh`
Complete cleanup for a fresh start.

**Usage:**
```bash
./scripts/clean.sh
```

**What it removes:**
- All compiled JAR files (`target/` directories)
- All Docker containers
- All Docker images for this project
- All database data (MySQL volumes)
- Maven cache (`~/.m2`) is **preserved**

**Confirmation required** - prompts before deleting.

**Use when:**
- Switching branches with major changes
- Debugging weird build issues
- Starting completely fresh

**After cleaning:**
```bash
./scripts/build.sh  # Rebuild everything
./scripts/start.sh  # Start services
```

---

## Configuration

### Environment Variables (`.env`)

Created automatically by `build.sh`, but you can customize:

```bash
# MySQL Configuration
MYSQL_ROOT_PASSWORD=root_password   # Root password for MySQL
MYSQL_USER=ad_on_wheels_user  # Application database user
MYSQL_PASSWORD=test  Application database password

# JWT Secret Key
JWT_SECRET_KEY=super-secret-jwt-key
```

**Important for production:**
- Change `JWT_SECRET_KEY` to a strong random string (min 256 bits)
- Use strong passwords for MySQL

### Service Ports

All services expose ports on `localhost`:

| Service | Port | URL |
|---------|------|-----|
| MySQL | 3306 | `localhost:3306` |
| Eureka | 8761 | http://localhost:8761 |
| Gateway | 8080 | http://localhost:8080 |
| Auth | 8085 | http://localhost:8085 |
| Driver | 8082 | http://localhost:8082 |
| Company | 8083 | http://localhost:8083 |
| Campaign | 8084 | http://localhost:8084 |

**Client apps should only connect to Gateway (8080)**.

### Database Schemas

MySQL creates 4 separate schemas (database-per-service pattern):

- `auth-service` - User credentials and JWT data
- `driver-service` - Driver profiles
- `company-service` - Company profiles
- `campaign-service` - Campaigns and applications

**Schema initialization:** Automatic on first startup via `mysql/init/01-init.sql`

## API Endpoints

All endpoints are accessed through the **Gateway** at `http://localhost:8080`.

### Public Endpoints (No Authentication)

#### Register User
```bash
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "DRIVER"  # or "COMPANY"
}

Response: 200 OK
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Registration successful"
  },
  "errors": null
}
```

#### Login
```bash
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Login successful"
  },
  "errors": null
}
```

### Protected Endpoints (Require JWT Token)

Include token in header:
```
Authorization: Bearer <your-jwt-token>
```

#### Drivers
```bash
GET    /drivers # List all drivers
POST   /drivers # Create driver
GET    /drivers/{id} # Get driver by ID
PUT    /drivers/{id} # Update driver
DELETE /drivers/{id} # Delete driver
```

#### Companies
```bash
GET    /companies # List all companies
POST   /companies # Create company
GET    /companies/{id} # Get company by ID
DELETE /companies/{id} # Delete company
```

#### Campaigns
```bash
GET    /campaigns # List all campaigns
POST   /campaigns  # Create campaign
POST   /campaigns/{id}/apply?driverId=X  # Driver applies
GET    /campaigns/{companyId}/applications # View applications
POST   /applications/{id}/accept  # Accept application
POST   /applications/{id}/decline# Decline application
```

#### BFF (Backend for Frontend)
```bash
GET /api/companies/{companyId}/applications-with-drivers
# Returns aggregated data: campaigns + applications + driver details
```




## Architecture Patterns

### Microservices
- Independent services with separate databases
- Service discovery via Eureka
- API Gateway for unified entry point

### SAGA Pattern
- Distributed transaction management
- Implemented in user registration flow
- Automatic rollback on failure

### Backend for Frontend (BFF)
- Gateway aggregates data from multiple services
- Reduces mobile client round trips
- Example: `CompanyBffService.getApplicationsWithDrivers()`

### Database Per Service
- Each service has its own MySQL schema
- Loose coupling between services
- Independent scaling and deployment


