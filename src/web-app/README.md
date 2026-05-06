# Ad-on-Wheels Web Dashboard

The company-side dashboard of the Ad-on-Wheels platform. Companies use it to register, create and manage advertising campaigns, review driver applications, exchange messages with accepted drivers, see a coverage map of every completed ride per campaign, and export campaign statistics as CSV.

The dashboard is web-only for company users; drivers use the iOS application. The same workflow is also reachable from the iOS app for company users who prefer mobile.

## Tech Stack

- **React** 19
- **Vite** 8 (dev server + production bundler)
- **React Router** 7 (client-side routing)
- **Leaflet** + `react-leaflet` (campaign coverage map)
- **@react-oauth/google** (Google sign-in)
- **ESLint** 9 (lint)

No global state library. Authentication state lives in a single `AuthContext`; per-page state lives in local `useState` hooks.

## Getting Started

### Prerequisites

- **Node.js** 20+
- The Ad-on-Wheels backend running locally (see [`src/backend/README.md`](../backend/README.md)). The dashboard talks to the gateway on `http://localhost:8080` by default.

### Setup

```bash
cd src/web-app
npm install
npm run dev
```

Vite serves on `http://localhost:5173`. The dev server hot-reloads on file changes.

### Configuration

The dashboard reads two environment variables, both injected at build/dev time by Vite:

| Variable | Purpose | Default |
|----------|---------|---------|
| `VITE_API_BASE_URL` | Gateway URL the browser fetches from | `http://localhost:8080` |
| `VITE_GOOGLE_WEB_CLIENT_ID` | Google OAuth web client ID | (none, Google sign-in disabled if missing) |

These live in `.env.local`, which is gitignored. The repo's top-level `scripts/sync-backend-url.sh` writes this file from `config/backend.env`, so the values stay in one place per machine. To configure manually:

```bash
cat > .env.local <<EOF
VITE_API_BASE_URL=http://localhost:8080
VITE_GOOGLE_WEB_CLIENT_ID=<paste-from-Google-Cloud-Console>
EOF
```

### Production Build

```bash
npm run build       # bundles to dist/
npm run preview     # serve the bundle locally for smoke-test
```

## Project Structure

```
src/
  App.jsx                      # router + ProtectedRoute wrapper
  main.jsx                     # entry; mounts AuthProvider + GoogleOAuthProvider
  contexts/
    AuthContext.jsx            # JWT in localStorage, manual base64 decode of payload
  services/
    api.js                     # fetch wrapper, handles ApiResponse envelope + 401 redirect
  components/
    Navbar.jsx
    GoogleLoginButton.jsx
    CampaignCoverageMap.jsx    # Leaflet map with verified/unverified polyline styling
    RoleMismatchModal.jsx
  pages/
    LoginPage.jsx
    RegisterPage.jsx           # role hardcoded COMPANY (per FR.1)
    DashboardPage.jsx          # campaigns list + aggregate stats + CSV export
    CreateCampaignPage.jsx     # form + drag-drop image upload (max 5 × 5 MB)
    CampaignDetailPage.jsx     # detail + applications + coverage map + CSV export
    CompanyProfilePage.jsx     # all-campaigns applications view
    MessagesPage.jsx           # split-pane inbox; 15 s polling
```

## Routes

| Path | Component | Auth | Notes |
|------|-----------|------|-------|
| `/login` | LoginPage | public | Email/password + Google OAuth |
| `/register` | RegisterPage | public | Company sign-up only (FR.1) |
| `/dashboard` | DashboardPage | required | Campaign list, stats, CSV export |
| `/campaigns/new` | CreateCampaignPage | required | Form + image upload |
| `/campaigns/:id` | CampaignDetailPage | required | Detail, applications, coverage map (UC15) |
| `/messages` | MessagesPage | required | Inbox + reply, polled every 15 s |
| `/profile` | CompanyProfilePage | required | All-campaigns applications |
| `*` | redirect | — | Falls through to `/dashboard` if signed in, else `/login` |

`ProtectedRoute` wraps the protected paths; if the JWT is missing or expired the user is redirected to `/login`.

## Authentication Flow

1. User submits credentials on `/login` (or via `<GoogleLoginButton>`)
2. POST to `/auth/login`, `/auth/register`, or `/auth/google` through the gateway
3. On success the dashboard stores the returned JWT in `localStorage` under the key `token`
4. `AuthContext` decodes the JWT payload (manual `atob` of the middle segment) and exposes `role`, `profileID` (as `profileId`), and `email` (`sub`)
5. Every subsequent fetch through `services/api.js` adds `Authorization: Bearer <jwt>`
6. A 401 response anywhere in the app clears the token and redirects to `/login`

The web dashboard restricts Google sign-in to the company role (FR.4); a Google account already registered as a driver triggers a `RoleMismatchModal` and is not signed in.

## Coverage Map (FR.22 / UC15)

`CampaignCoverageMap.jsx` renders Leaflet polylines for every completed ride on a campaign:

- **Verified rides:** solid polyline, blue (`#2563eb`)
- **Unverified rides:** dashed polyline, gray (`#94a3b8`, `dashArray="6 6"`)

Data comes from `GET /api/campaigns/{id}/coverage` (a gateway-local BFF endpoint that proxies `ride-service`). The viewport auto-fits to the union of every trace. A legend below the map shows the verified/unverified swatches.

## CSV Export (FR.21 / UC08)

Two flavours, both downloaded as a `Blob` via the same `<a download>` pattern:

- **Single campaign:** `GET /api/campaigns/{id}/export` (button on the campaign detail page)
- **All campaigns:** `GET /api/companies/{companyId}/export-csv` (button on the dashboard)

Both responses carry a UTF-8 BOM so spreadsheet software opens them with the right encoding (C.3).

## Linting

```bash
npm run lint
```

ESLint 9 with the project's flat config (`eslint.config.js`).
