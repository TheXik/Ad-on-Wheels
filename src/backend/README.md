# Ad-on-Wheels Backend

Java microservices backend for the Ad-on-Wheels platform — connecting drivers with advertising companies.

## Architecture Overview

The backend consists of **7 Spring Boot services** plus one shared library, behind a single API gateway.

| Service | Port | Storage | Description |
|---------|------|---------|-------------|
| **Eureka Server** | 8761 | — | Service discovery and registry |
| **Gateway Service** | 8080 | — | Single public entry point; JWT validation, role gating, BFF aggregators |
| **Auth Service** | 8081 | MySQL `auth-service` | Email/password and Google sign-in, JWT issuance, registration SAGA |
| **Driver Service** | 8082 | MySQL `driver-service` + MinIO | Driver profiles, vehicle data, decal photo storage |
| **Company Service** | 8083 | MySQL `companyservice` | Company profiles |
| **Campaign Service** | 8084 | MySQL `campaign-service` + MinIO | Campaigns, applications, in-app messages, lifecycle scheduler, image upload |
| **Ride Service** | 8085 | Cassandra (active sessions, 24h TTL) + MySQL `ride-service` (completed rides) | Live GPS tracking, deferred rides, route polylines, per-campaign aggregates |
| **common-dto** | — | — | Shared library: `ApiResponse<T>` envelope, `AppErrorCode`, `BaseExceptionHandler`, `@NoHtml` validator |

### Tech Stack

- **Java**: 21 (Eclipse Temurin)
- **Spring Boot**: 3.4.3
- **Spring Cloud**: 2024.0.0
- **Relational DB**: MySQL 8.0 (per-service schemas)
- **Wide-column DB**: Cassandra 4.1 (active ride sessions, 24h TTL)
- **Object storage**: MinIO (S3-compatible) for vehicle decal and campaign images
- **Security**: Spring Security, JWT (JJWT 0.12.5), bcrypt with work factor ≥ 12, Google OAuth
- **Build**: Maven 3.9+, JaCoCo coverage per module
- **Container**: Docker & Docker Compose

## Prerequisites

### Required
- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ (included with Docker Desktop)

### Optional (for local development without Docker)
- **Java 21**
- **Maven 3.9+**

You don't need Java or Maven installed locally if you use the build scripts.

## Quick Start (3 Steps)

### 1. Build All Microservices

```bash
cd /path/to/Ad-on-Wheels/src/backend
./scripts/build.sh
```

**What this does:**
- Verifies `.env` exists (copy from `.env.template` if missing)
- Downloads Maven and Java 21 in a Docker container
- Compiles every service module

### 2. Start All Services

```bash
./scripts/start.sh
```

**What this does:**
- Starts MySQL, Cassandra, and MinIO with health checks
- Starts Eureka and waits for it to be ready
- Starts the business services (auth, driver, company, campaign, ride)
- Starts Gateway last (depends on every business service)

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
Eureka Server     - UP
Gateway Service   - UP
Auth Service      - UP
Driver Service    - UP
Company Service   - UP
Campaign Service  - UP
Ride Service      - UP
MySQL Database    - UP
Cassandra         - UP
MinIO             - UP
```

## Helper Scripts Reference

### `./scripts/build.sh`
Builds every service using Maven in Docker.

**What it does:**
1. Checks Docker is installed
2. Verifies `.env` exists
3. Runs `mvn clean package -DskipTests` in a Docker container
4. Outputs JAR files to `<service>/target/`

---

### `./scripts/start.sh`
Starts every service in foreground (interactive mode).

**What it does:**
1. Validates JAR files exist (rebuilds if needed)
2. Starts all containers with `docker compose up --build`
3. Streams live logs from every service
4. Blocks the terminal (press `Ctrl+C` to stop)

**Best for:** development when you want to watch logs live.

---

### `./scripts/start-detached.sh`
Starts every service in background (detached).

**What it does:**
1. Runs `docker compose up -d`
2. Returns control to the terminal immediately

**Best for:** continuing to work in the same terminal. View logs later with `./scripts/logs.sh`.

---

### `./scripts/up.sh`
One-shot: build then start (foreground). Equivalent to running `build.sh` followed by `start.sh`.

---

### `./scripts/stop.sh`
Stops every running service.

```bash
./scripts/stop.sh           # preserves database data
./scripts/stop.sh --clean   # also removes volumes (deletes data)
```

**Warning:** `--clean` deletes every persisted record (MySQL, Cassandra, MinIO buckets).

---

### `./scripts/status.sh`
Checks the status of every service plus dependencies.

**What it shows:**
- Docker container status
- Per-service `/actuator/health`
- MySQL, Cassandra, and MinIO connection status
- Quick links to Eureka Dashboard and Gateway API

---

### `./scripts/logs.sh`
View logs from running services.

```bash
./scripts/logs.sh                    # every service
./scripts/logs.sh auth-service       # one service
./scripts/logs.sh ride-service
./scripts/logs.sh mysql
./scripts/logs.sh cassandra
```

**Valid service names:**
`mysql`, `cassandra`, `minio`, `eureka-server`, `gateway-service`,
`auth-service`, `driver-service`, `company-service`, `campaign-service`, `ride-service`.

Press `Ctrl+C` to stop tailing (services keep running).

---

### `./scripts/test-api.sh`
Runs automated smoke tests against the gateway.

**What it tests:**
1. Driver registration
2. Company registration
3. Login
4. Protected endpoints reject calls without a JWT (expecting 401)

---

### `./scripts/clean.sh`
Complete cleanup for a fresh start.

**What it removes:**
- Compiled JAR files (`target/`)
- Every Docker container and image for the project
- MySQL, Cassandra, and MinIO volumes
- `~/.m2` cache is **preserved**

Confirmation prompt before deleting.

**After cleaning:**
```bash
./scripts/build.sh
./scripts/start.sh
```

---

## Configuration

### Environment Variables (`.env`)

The committed `.env.template` lists every required key with empty values. Copy to `.env` and fill in for the local environment:

```bash
# MySQL
MYSQL_ROOT_PASSWORD=...
MYSQL_USER=ad_on_wheels_user
MYSQL_PASSWORD=...

# JWT — generate with: openssl rand -base64 32
JWT_SECRET_KEY=...

# Google OAuth — comma-separated client IDs from Google Cloud Console (iOS, Web)
GOOGLE_CLIENT_IDS=...,...

# MinIO (S3-compatible object storage)
MINIO_ROOT_USER=...
MINIO_ROOT_PASSWORD=...
MINIO_ACCESS_KEY=...
MINIO_SECRET_KEY=...
MINIO_BUCKET=ad-on-wheels

# Gateway CORS — comma-separated origin patterns (defaults to localhost:* / 127.0.0.1:*)
GATEWAY_ALLOWED_ORIGINS=http://localhost:*,http://127.0.0.1:*
```

**Production checklist:**
- Rotate `JWT_SECRET_KEY` to a strong random string (≥ 256 bits)
- Use strong passwords for MySQL and MinIO
- Tighten `GATEWAY_ALLOWED_ORIGINS` to known frontend hostnames
- Restrict `GOOGLE_CLIENT_IDS` to production OAuth clients

### Service Ports

The Gateway is the only port published on the host. Every other service is reachable only from inside the Docker network.

| Service | Port | Host access |
|---------|------|-------------|
| **Gateway** | 8080 | `http://localhost:8080` ← clients talk here |
| Eureka | 8761 | `http://localhost:8761` (dashboard, optional) |
| Auth | 8081 | internal only |
| Driver | 8082 | internal only |
| Company | 8083 | internal only |
| Campaign | 8084 | internal only |
| Ride | 8085 | internal only |
| MySQL | 3306 | internal only |
| Cassandra | 9042 | internal only |
| MinIO | 9000 / 9001 | internal only |

**Client apps must connect only to the Gateway (8080).**

### Database Schemas

MySQL holds five separate schemas (database-per-service pattern):

- `auth-service` — user credentials (`user_credentials` table)
- `driver-service` — driver profiles with vehicle and onboarding columns
- `companyservice` — company profiles
- `campaign-service` — campaigns, applications, messages, campaign image keys
- `ride-service` — completed rides with route JSON

Cassandra holds the `ride_service` keyspace with `ride_sessions` (per-ride GPS trace, partitioned by `ride_id`) and `driver_active_rides` (lookup by `driver_id`). Both tables carry a 24h TTL so abandoned sessions clean themselves up.

MinIO holds the campaign image bucket (driver decal photos and campaign visual assets).

**Schema initialisation:** automatic on first startup via Hibernate `ddl-auto: update` for MySQL and `SchemaAction.CREATE_IF_NOT_EXISTS` for Cassandra. The Cassandra side has a `CassandraSchemaMigrator` that ALTERs missing columns at startup so older keyspaces stay compatible.

## API Endpoints

Every endpoint is reached through the Gateway at `http://localhost:8080`. Internal service paths (`/drivers`, `/companies`, `/campaigns`, `/rides`, `/messages`) live behind the gateway under the `/api/` prefix; the gateway strips it before forwarding.

### Public endpoints (no JWT required)

```
POST /auth/register
POST /auth/login
POST /auth/google
GET  /api/campaigns/images/**          # campaign image binary
GET  /api/drivers/images/**            # driver decal binary
GET  /actuator/health
GET  /actuator/info
```

#### Register
```bash
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "DRIVER"            // or "COMPANY"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Login
```bash
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123",
  "expectedRole": "DRIVER"    // optional; rejects if mismatched
}

Response: 200 OK
{
  "success": true,
  "data": { "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." }
}
```

#### Google sign-in
```bash
POST /auth/google
Content-Type: application/json

{
  "idToken": "<Google ID token>",
  "role": "DRIVER"            // or "COMPANY"
}
```

### Protected endpoints (require `Authorization: Bearer <jwt>`)

The gateway extracts `role` and `profileID` from the JWT and stamps them as `X-User-Role` and `X-User-Id` headers on the forwarded request. Each downstream controller pins the resource id (driver / company / campaign owner) to the caller; ADMIN bypasses the check.

#### Drivers
```
GET    /api/drivers/{id}                 # own profile (ownership-enforced)
PUT    /api/drivers/{id}                 # update profile
PATCH  /api/drivers/{id}/vehicle         # update vehicle info
PATCH  /api/drivers/{id}/onboarding      # finalize onboarding wizard
POST   /api/drivers/{id}/vehicle-image   # multipart upload
DELETE /api/drivers/{id}                 # delete account
GET    /api/drivers/{id}/home            # gateway BFF: profile + active ride + stats + active campaign
GET    /api/drivers/{id}/statistics      # gateway BFF: ride statistics
GET    /api/drivers/{id}/rides?limit=N   # gateway BFF: ride history
DELETE /api/drivers/{id}/rides           # delete ride history
```

#### Companies
```
GET    /api/companies/{id}                                  # own profile
DELETE /api/companies/{id}
GET    /api/companies/{id}/applications-with-drivers        # gateway BFF
GET    /api/companies/{id}/campaign-stats                   # gateway BFF
GET    /api/companies/{id}/export-csv                       # CSV blob, all-company campaigns
```

#### Campaigns
```
GET    /api/campaigns                                  # discovery feed (driver)
GET    /api/campaigns/{id}                             # campaign detail
POST   /api/campaigns                                  # create (company-only)
DELETE /api/campaigns/{id}
GET    /api/campaigns/company/{companyId}              # campaigns owned by a company
GET    /api/campaigns/driver/{driverId}                # campaigns the driver is accepted on
GET    /api/campaigns/driver/{driverId}/applications   # driver's own applications
POST   /api/campaigns/{id}/apply?driverId=X            # driver applies
GET    /api/campaigns/{companyId}/applications         # applications for one company's campaigns
PATCH  /api/campaigns/applications/{id}                # accept / decline (company)
DELETE /api/campaigns/applications/{id}?driverId=X     # withdraw (driver)
GET    /api/campaigns/{id}/export                      # CSV, single campaign
GET    /api/campaigns/company/{companyId}/export       # CSV, all campaigns
POST   /api/campaigns/{id}/images                      # multipart upload (company)
GET    /api/campaigns/{id}/coverage                    # gateway BFF: ride routes for the campaign
```

#### Rides
```
POST   /api/rides/start                              # body: { driverId, campaignId, ratePerKm }
POST   /api/rides/track                              # body: { rideId, lat, lon }  — every 5 s during active ride
POST   /api/rides/end                                # body: { rideId }
POST   /api/rides/{completedRideId}/verify           # mark ride verified after QR scan
POST   /api/rides/deferred                           # reconstruct a forgotten drive (UC13)
GET    /api/rides/{driverId}/active                  # currently active ride, if any
GET    /api/rides/{driverId}/history?limit=N         # completed rides
GET    /api/rides/{driverId}/statistics              # weekly / monthly aggregates
DELETE /api/rides/{driverId}/history                 # delete all completed rides
GET    /api/rides/{rideId}/route                     # raw route polyline
GET    /api/rides/campaign/{campaignId}/routes       # all rides on a campaign
GET    /api/rides/campaign/{campaignId}/statistics   # one campaign's aggregates
GET    /api/rides/campaigns/statistics?ids=1,2,3     # bulk aggregates
GET    /api/rides/campaigns/earnings-totals?ids=1,2  # verified-earnings sums (used by lifecycle scheduler)
```

#### Messages
```
POST   /api/messages                              # send a message
GET    /api/messages/inbox/{recipientId}          # list inbox
GET    /api/messages/conversation?campaignId=&userId1=&userId2=
PATCH  /api/messages/{messageId}/read
GET    /api/messages/unread-count/{recipientId}
```

## Architecture Patterns

### Microservices
- Independent services, each with its own database schema
- Service discovery via Eureka
- Single public entry point through the API Gateway (NFR.3)

### Registration SAGA
- Distributed-transaction orchestration in `RegistrationSagaOrchestratorService`
- Forward path: email-uniqueness check → create profile in driver/company service → save credentials in auth DB → issue JWT
- Compensating action `deleteProfile` runs with retry/backoff on any failure path (FR.5)

### Backend for Frontend (BFF)
- Three gateway-local controllers (`DriverBffController`, `CompanyBffController`, `CoverageBffController`) aggregate downstream calls in parallel via WebClient
- Reduces mobile-client round trips on the home screen, applications view, and coverage map
- Outbound calls re-stamp `X-User-Id` and `X-User-Role` so the per-endpoint ownership check still fires downstream

### Database per Service
- Five MySQL schemas plus the Cassandra `ride_service` keyspace and the MinIO bucket
- No cross-schema foreign keys; cross-service identifiers are stitched in code by the saga (writes) and the BFF (reads)

### Dual store in the Ride Service
- Cassandra absorbs the high-frequency GPS writes during an active ride (24h TTL); the row is deleted on `/end`
- MySQL persists the completed ride for read-heavy statistics and earnings queries
- The hand-off (Cassandra → MySQL → delete Cassandra) is single-manager forward-write with TTL-backed cleanup
