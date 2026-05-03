#!/bin/bash
# Personal workflow: pushes the local build to a private Ubuntu host over Tailscale
# via the "lukbaos" Docker context. Not part of the reproducible build.
# Other developers should use scripts/build.sh + scripts/start.sh instead.
set -e

CONTEXT=lukbaos

cd "$(dirname "$0")"

mvn -DskipTests clean package


docker --context "$CONTEXT" compose build
docker --context "$CONTEXT" compose up -d

echo "Running containers on server:"
docker --context "$CONTEXT" compose ps

bash ../../scripts/sync-backend-url.sh

echo "Done"
