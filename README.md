# Ad-on-Wheels

A mobile advertising platform connecting drivers with companies for car-based advertising campaigns.

## Purpose and Goals

Ad-on-Wheels lets drivers earn money by displaying advertising decals on their cars, and lets companies recruit those drivers, run campaigns, and see where the ads were actually driven. The platform pays per kilometre against GPS-tracked verified rides; companies get a coverage map of every completed ride and can export campaign statistics as CSV.

## Authors

**Lukáš Hellesch**

**Thesis supervisor:** Ing. Pavel Koupil, Ph.D.

---

## Project Overview

**Ad-on-Wheels** is a full-stack application:

- **Backend**: seven Java microservices (Spring Boot + Spring Cloud) behind an API gateway.
- **iOS client**: native SwiftUI app for drivers and companies.
- **Web dashboard**: React + Vite app for companies (campaign management, coverage heat-map).
- **Storage**: MySQL for relational data, Cassandra for active ride sessions, MinIO for campaign images.

### Key Features

- **Driver and company onboarding.** JWT authentication, Google sign-in, and saga-based registration that rolls back on partial failure.
- **Campaign lifecycle.** Companies create campaigns, drivers browse and apply, companies accept or decline.
- **Live ride tracking.** The driver app records GPS at a five-second cadence. Ride-service stores active sessions in Cassandra (24h TTL) and persists completed rides in MySQL.
- **Earnings and statistics.** Daily and weekly breakdown for drivers, computed from verified rides only.
- **Coverage map.** Companies see the routes of every completed ride contributed by accepted drivers, overlaid on a single map per campaign. Verified rides render as solid polylines, unverified rides as dashed.
- **In-app messaging** between driver and company, scoped per campaign.

### Technology Stack

#### Backend
- **Language**: Java 21 (Eclipse Temurin in containers).
- **Framework**: Spring Boot 3.4.3, Spring Cloud 2024.0.0.
- **Storage**: MySQL 8.0 (per-service schemas), Cassandra (ride sessions), MinIO (S3-compatible object storage).
- **Security**: Spring Security, JWT (JJWT 0.12.5), bcrypt with work factor ≥ 12, Google OAuth.
- **Service discovery**: Netflix Eureka.
- **API gateway**: Spring Cloud Gateway (reactive); BFF controllers aggregate driver-home, company-home, and coverage responses.
- **Build**: Maven 3.9+; per-module JaCoCo coverage.
- **Container**: Docker & Docker Compose.

#### iOS client
- **Language**: Swift, SwiftUI.
- **Architecture**: MVVM with `@Published` state; `URLSession` async/await networking.
- **Security**: Keychain token storage.
- **Platform**: iOS 18.4+.

#### Web dashboard
- **Stack**: React 19 + Vite 8, React Router 7, Leaflet for the coverage map, `@react-oauth/google` for sign-in.

## Getting Started

### System Requirements

**Driver device.** iPhone running iOS 18.4 or later, with GPS hardware. Location permission must be granted in *While Using the App* mode; *Always* is neither requested nor required. Camera permission is requested the first time the driver verifies a ride via QR.

**Company workstation.** Any current desktop browser (Chromium-family, Firefox, or Safari) on any operating system. No plug-ins, extensions, or native installers are required. The dashboard is also reachable from the same iOS application drivers use, for company users who prefer mobile.

**Backend host.** Linux, macOS, or Windows WSL with at least 8 GB of free RAM, [Docker Engine](https://docs.docker.com/get-docker/) 20.10 or newer, and Docker Compose v2 (included with Docker Desktop). A container runtime is the only hard dependency; no JDK, Python, or Node installation is required on the host.

**iOS development (optional).** macOS with Xcode 16.0 or newer (required for the iOS 18.4 SDK), [installable from the App Store](https://apps.apple.com/us/app/xcode/id497799835).

### Quick Start

#### 1. Get the source

Clone the repository (or unpack the thesis attachment) and `cd` into the project root.

#### 2. Configure secrets and the backend URL

```bash
# Copy the env template and fill in values for your local environment.
cp src/backend/.env.template src/backend/.env
# Generate a JWT secret: openssl rand -base64 32
# Add Google OAuth client IDs from Google Cloud Console (iOS, Web).
# Fill MinIO and MySQL credentials.

# Create config/backend.env with your machine's reachable backend URL.
# This is gitignored on purpose; each machine has its own.
cat > config/backend.env <<EOF
BACKEND_URL=http://localhost:8080
GOOGLE_WEB_CLIENT_ID=<paste-from-cloud-console>
EOF

# Generate per-machine config files for the iOS app and the web dashboard.
bash scripts/sync-backend-url.sh
```

The sync script writes `src/swift-ui/.../LocalConfig.swift` (gitignored) and `src/web-app/.env.local` (gitignored) so that source files stay clean of personal IPs.

#### 3. Start backend services

```bash
cd src/backend

# Single command: build every microservice image, then start the stack
./scripts/up.sh
```

The first run takes about five to ten minutes (Maven build + image layers). Later runs reuse the cache. `./scripts/build.sh` and `./scripts/start.sh` run the two halves separately if you prefer; `./scripts/start-detached.sh` runs the stack in the background.

**Wait for all services to start** (look for "Started GatewayServiceApplication" in logs).

**Verify backend is running:**
```bash
# In another terminal
cd src/backend
./scripts/status.sh
```

All services should show `UP`.

#### 4. Run the iOS app

```bash
open src/swift-ui/AdOnWheelsApp/AdOnWheelsApp.xcodeproj
```

**In Xcode:**
1. Select a simulator (e.g., iPhone 15 Pro) or connect your iPhone
2. Click the **Play** button or press `Cmd + R`
3. Wait for the app to build and launch

**First Launch:**
- App opens to **Role Selection** screen
- Choose **Driver** or **Company**
- Register a new account
- You'll be automatically logged in after registration

#### 5. Run the web dashboard (optional)

```bash
cd src/web-app
npm install
npm run dev
```

Vite serves on `http://localhost:5173` by default. The dashboard reads `VITE_API_BASE_URL` and `VITE_GOOGLE_WEB_CLIENT_ID` from `.env.local`, which `sync-backend-url.sh` already populated.

## Configuration

### Backend secrets

All backend secrets live in `src/backend/.env`, which is gitignored. The committed `src/backend/.env.template` lists the required keys with empty values:

- `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD` — database credentials.
- `JWT_SECRET_KEY` — generate with `openssl rand -base64 32`.
- `GOOGLE_CLIENT_IDS` — comma-separated list of OAuth client IDs (iOS, Web), created in Google Cloud Console.
- `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_BUCKET` — object storage.
- `GATEWAY_ALLOWED_ORIGINS` — comma-separated origins for CORS (defaults to `http://localhost:*,http://127.0.0.1:*`).

### Backend URL (per machine)

`config/backend.env` is gitignored and personal: it holds `BACKEND_URL` and `GOOGLE_WEB_CLIENT_ID` for the local machine. `scripts/sync-backend-url.sh` reads it and regenerates:

- `src/swift-ui/AdOnWheelsApp/AdOnWheelsApp/Core/Networking/LocalConfig.swift` — read by `AppConfig.swift` at runtime.
- `src/web-app/.env.local` — read by Vite at build/dev time.

Both generated files are gitignored, so personal IPs never end up in source control. To override at iOS runtime instead of regenerating, set the `API_BASE_URL` key in the build's `Info.plist`; `AppConfig` prefers it over `LocalConfig.backendURL` when present.

### iOS App Transport Security

For development against an HTTP backend, the iOS target's `Info.plist` allows arbitrary loads. Production builds should target HTTPS and remove that exception.

### Ports Reference

| Service | Port | Access |
|---------|------|--------|
| **Gateway (API)** | 8080 | **http://localhost:8080** ← Use this in iOS app |
| Eureka Dashboard | 8761 | http://localhost:8761 |
| Auth Service | 8081 | Internal only (via Gateway) |
| Driver Service | 8082 | Internal only |
| Company Service | 8083 | Internal only |
| Campaign Service | 8084 | Internal only |
| Ride Service | 8085 | Internal only |
| MySQL | 3306 | Internal only |
| Cassandra | 9042 | Internal only |
| MinIO (S3) | 9000 / 9001 | Internal only |

The iOS app and the web dashboard talk only to the gateway on port 8080.

## Development

### Backend Development

See detailed backend documentation: [src/backend/README.md](src/backend/README.md)

**Common commands:**
```bash
cd src/backend

# Build all services
./scripts/build.sh

# Start services (foreground)
./scripts/start.sh

# Start services (background)
./scripts/start-detached.sh

# View logs
./scripts/logs.sh
./scripts/logs.sh auth-service

# Check status
./scripts/status.sh

# Run API tests
./scripts/test-api.sh

# Stop services
./scripts/stop.sh

# Clean everything
./scripts/clean.sh
```

### API Documentation

#### Base URL
```
http://localhost:8080
```

#### Authentication Flow

**1. Register**
```bash
POST /auth/register
Content-Type: application/json

{
  "name": "Demo Driver",
  "email": "driver-demo@test.dev",
  "password": "thesis-test-pwd",
  "role": "DRIVER"
}

Response:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "errors": null
}
```

**2. Login**
```bash
POST /auth/login
Content-Type: application/json

{
  "email": "driver-demo@test.dev",
  "password": "thesis-test-pwd"
}
```

**3. Use Token**
```bash
GET /campaigns
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

See full API documentation in [src/backend/README.md](src/backend/README.md#api-endpoints).
     
## Architecture Patterns

### Backend

- Seven Spring Boot services plus one shared library (`common-dto`), each registered with a Netflix Eureka discovery server.
- A Spring Cloud Gateway is the single public entry point. It validates JWTs, gates routes by role, and hosts three BFF aggregators (driver home, company applications view, campaign coverage).
- Registration is coordinated by `RegistrationSagaOrchestratorService` in the auth service: create profile -> save credentials -> issue JWT, with `deleteProfile` as the compensating rollback (FR.5).
- Database per service. Five MySQL schemas, one Cassandra keyspace (`ride_service`, with TTL on active sessions), and one MinIO bucket. Cross-service identifiers are stitched in code by the saga (writes) and the BFF endpoints (reads).
- Ride service uses a dual store: Cassandra absorbs the 5-second GPS writes during an active ride; on `/end` the completed ride is persisted to MySQL and the Cassandra row is deleted (with the 24h TTL as a safety net).

### iOS client

- MVVM. Views, view models with `@Published`, and `Codable` models.
- A single `APIClient` issues every network request through `URLSession` with `async/await`. Combine appears only where a publisher is genuinely needed (e.g. the `.rideCompleted` notification on the stats view model).
- The JWT lives in the iOS Keychain. Removing the app drops the credential.



### Support 
- For questions please contact: **lukas.hellesch@gmail.com**