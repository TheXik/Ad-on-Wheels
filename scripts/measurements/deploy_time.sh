#!/usr/bin/env bash
# Measures clean-checkout deploy time: from `docker compose up --build` start
# to all configured healthchecks reporting healthy. Fills chap05 placeholder
# DEPLOY_TIME_S (NFR.5: deployable from a clean checkout in under 10 minutes).
#
# Run this from the repository root. The script:
#   1. Tears down any running stack and prunes images for a clean rebuild.
#   2. Starts `docker compose up --build` in the background.
#   3. Polls `docker compose ps` every 2 seconds until every service that
#      declares a healthcheck reports `healthy`.
#   4. Prints the elapsed time and a per-service status table.
#
# Usage:
#   scripts/measurements/deploy_time.sh [--keep-images]
#
# By default the script removes service images first to simulate a true cold
# build. Use --keep-images to skip that and only re-run compose.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_DIR="$ROOT/src/backend"
KEEP_IMAGES=0

for arg in "$@"; do
    case "$arg" in
        --keep-images) KEEP_IMAGES=1 ;;
        *) echo "unknown flag: $arg" >&2; exit 1 ;;
    esac
done

if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required" >&2
    exit 1
fi

cd "$COMPOSE_DIR"

echo "==> Stopping any running stack"
docker compose down --remove-orphans >/dev/null 2>&1 || true

if [ "$KEEP_IMAGES" -eq 0 ]; then
    echo "==> Removing built service images (clean-checkout simulation)"
    for img in eureka-server gateway-service auth-service driver-service \
               company-service campaign-service ride-service ad-on-wheels-mysql; do
        docker image rm "$img" >/dev/null 2>&1 || true
    done
fi

echo "==> Starting stack (timer begins)"
START_NS=$(date +%s)
docker compose up --build -d

services=$(docker compose ps --services)

while :; do
    pending=0
    while IFS= read -r svc; do
        [ -z "$svc" ] && continue
        cid=$(docker compose ps -q "$svc" 2>/dev/null || true)
        [ -z "$cid" ] && { pending=$((pending+1)); continue; }
        status=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$cid" 2>/dev/null || echo "unknown")
        case "$status" in
            healthy|running) ;;
            *) pending=$((pending+1)) ;;
        esac
    done <<<"$services"

    if [ "$pending" -eq 0 ]; then
        break
    fi
    sleep 2
done

END_NS=$(date +%s)
ELAPSED=$((END_NS - START_NS))

echo
echo "==> All services healthy"
docker compose ps
echo
printf "Deploy time: %d seconds (%dm %ds)\n" "$ELAPSED" "$((ELAPSED/60))" "$((ELAPSED%60))"
echo "Use this number for chap05 placeholder DEPLOY_TIME_S."
