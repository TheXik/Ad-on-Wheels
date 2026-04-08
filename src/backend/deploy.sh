#!/bin/bash
set -e

CONTEXT=lukbaos

cd "$(dirname "$0")"

echo "==> Building and running on remote ($CONTEXT) via docker context..."
echo "    Source stays on this Mac. Build runs on the Ubuntu server."
echo ""

docker --context "$CONTEXT" compose build
docker --context "$CONTEXT" compose up -d

echo ""
echo "==> Running containers on server:"
docker --context "$CONTEXT" compose ps

echo ""
echo "Done. Gateway should be at: http://lukbaos-ubuntu:8080"
