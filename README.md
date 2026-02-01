# Ad-on-Wheels

A mobile advertising platform connecting drivers with companies for car-based advertising campaigns.

## Purpose and Goals

The purpose of this project is to develop a mobile application that connects car owners with advertising companies, enabling drivers to earn money by displaying ads on their vehicles. The main goals are to provide a platform for managing ad campaigns, tracking driver performance, and delivering real-time analytics for both drivers and companies. The app aims to simplify the process of on-vehicle advertising, ensure transparency, and maximize benefits for all participants.

## Authors

**Lukáš Hellesch**

**Thesis supervisor:** Ing. Pavel Koupil, Ph.D.

---

## Project Overview

**Ad-on-Wheels** is a full-stack application built with modern technologies:

- **Backend**: Java microservices (Spring Boot + Spring Cloud)
- **Frontend**: Native iOS app (SwiftUI)
- **Database**: MySQL 8.0

### Key Features

- **Driver Registration & Profiles** - Drivers create profiles to participate in campaigns
- **Company Accounts** - Companies manage advertising campaigns
- **Campaign Management** - Create, browse, and apply to campaigns
- **Application Tracking** - View and manage campaign applications
- **Secure Authentication** - JWT-based authentication with auto-login
- **Native iOS Experience** - SwiftUI app with modern UX



### Technology Stack

#### Backend
- **Language**: Java 21
- **Framework**: Spring Boot 3.4.3, Spring Cloud 2024.0.0
- **Database**: MySQL 8.0
- **Security**: JWT (JJWT 0.12.5), Spring Security
- **Service Discovery**: Netflix Eureka
- **API Gateway**: Spring Cloud Gateway
- **Build**: Maven 3.9+
- **Container**: Docker & Docker Compose

#### Frontend
- **Language**: Swift
- **Framework**: SwiftUI (iOS)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Networking**: URLSession with async/await
- **Security**: Keychain for token storage
- **Platforms**: iOS 15.0+

## Getting Started

### Prerequisites

#### For Backend
- **Docker** 20.10+ ([Install](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ (included with Docker Desktop)

#### For iOS App
- **macOS** (required for iOS development)
- **Xcode** 14.0+ ([Install from App Store](https://apps.apple.com/us/app/xcode/id497799835))

### Quick Start

#### 1. Clone Repository

```bash
git clone https://github.com/your-username/Ad-on-Wheels.git
cd Ad-on-Wheels
```

#### 2. Start Backend Services

```bash
cd src/backend

# Build all microservices (first time: ~5-10 minutes)
./scripts/build.sh

# Start all services
./scripts/start.sh
```

**Wait for all services to start** (look for "Started GatewayServiceApplication" in logs).

**Verify backend is running:**
```bash
# In another terminal
cd src/backend
./scripts/status.sh
```

All services should show `UP`.

#### 3. Configure iOS App

**IMPORTANT**: Update the backend URL in the iOS app to match your setup.

#### 4. Run iOS App

```bash
# Open Xcode project
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

## Configuration

### Backend Configuration

The backend uses environment variables defined in [`src/backend/.env`](src/backend/.env):

```bash
# MySQL Configuration
MYSQL_ROOT_PASSWORD=root_password
MYSQL_USER=ad_on_wheels_user
MYSQL_PASSWORD=test

# JWT Secret (CHANGE IN PRODUCTION!)
JWT_SECRET_KEY=jwt-secret-token
```


### iOS App Configuration

#### Base URL Configuration

The app's backend URL is configured in [`AppConfig.swift`](src/swift-ui/AdOnWheelsApp/AdOnWheelsApp/Core/Networking/AppConfig.swift):

```swift
private static let defaultBaseURLString: String = "http://192.168.1.27:8080"
```

**Configuration Options:**

1. **Hardcoded URL** (current approach):
   - Edit `AppConfig.swift` directly
   - Simple but requires recompile for changes

2. **Info.plist Configuration**:
   - Add `API_BASE_URL` key to `Info.plist`
   - App will use this value if present
   - Allows different URLs per build configuration

**Example Info.plist:**
```xml
<key>API_BASE_URL</key>
<string>http://localhost:8080</string>
```

#### Building for Different Environments

**Debug (Development)**:
- Use `http://localhost:8080` (simulator)
- Use `http://<your-ip>:8080` (physical device)

**Release (Production)**:
- Use your production domain: `https://api.yourdomain.com`
- Ensure HTTPS is configured

#### Network Security

For iOS 14+, if using HTTP (not HTTPS), you must configure App Transport Security.

Edit `Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Only use HTTP for development!** Production should always use HTTPS.

### Ports Reference

| Service | Port | Access |
|---------|------|--------|
| **Gateway (API)** | 8080 | **http://localhost:8080** ← Use this in iOS app |
| Eureka Dashboard | 8761 | http://localhost:8761 |
| Auth Service | 8085 | Internal only (via Gateway) |
| Driver Service | 8082 | Internal only |
| Company Service | 8083 | Internal only |
| Campaign Service | 8084 | Internal only |
| MySQL | 3306 | Internal only |

**iOS app should ONLY connect to Gateway (port 8080).**

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
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "DRIVER"  # or "COMPANY"
}

Response:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Registration successful"
  },
  "errors": null
}
```

**2. Login**
```bash
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
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
- **Microservices Architecture** - Independent, scalable services
- **Service Discovery** - Eureka for dynamic service location
- **API Gateway** - Single entry point with authentication
- **SAGA Pattern** - Distributed transaction management
- **BFF Pattern** - Backend for Frontend data aggregation
- **Database Per Service** - Isolated data stores

### Frontend
- **MVVM** - Model-View-ViewModel for clean separation
- **Reactive State** - Combine framework with `@Published`
- **Repository Pattern** - Centralized API client
- **Keychain Storage** - Secure token persistence



### Support 
- For questions please contact: **lukas.hellesch@gmail.com**