#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/config/backend.env"

cat > "$ROOT/src/web-app/.env.local" <<EOF
VITE_API_BASE_URL=$BACKEND_URL
VITE_GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID
EOF

cat > "$ROOT/src/swift-ui/AdOnWheelsApp/AdOnWheelsApp/Core/Networking/LocalConfig.swift" <<EOF
import Foundation

enum LocalConfig {
    static let backendURL = "$BACKEND_URL"
}
EOF

echo "Synced $BACKEND_URL"
