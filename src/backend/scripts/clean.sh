#!/bin/bash

SKIP_PROMPT=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes) SKIP_PROMPT=1 ;;
    esac
done
if [ "${CLEAN_YES:-0}" = "1" ]; then
    SKIP_PROMPT=1
fi

if [ "$SKIP_PROMPT" -ne 1 ]; then
    echo "This removes JARs, Docker containers/images, and MySQL volumes."
    echo "Maven cache (~/.m2) is preserved to speed up rebuilds."
    read -p "Continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

docker compose down -v 2>/dev/null || true
docker compose images -q 2>/dev/null | xargs -r docker rmi -f 2>/dev/null || true
docker rmi -f eureka-server gateway-service auth-service driver-service company-service campaign-service ride-service 2>/dev/null || true

find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
[ -d "common-dto/target" ] && rm -rf common-dto/target

echo "Done. Run ./scripts/build.sh and ./scripts/start.sh to rebuild."
