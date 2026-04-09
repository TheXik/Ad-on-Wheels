#!/bin/bash
set -e

CONTEXT=lukbaos

cd "$(dirname "$0")"

mvn -q -DskipTests clean package


docker --context "$CONTEXT" compose build
docker --context "$CONTEXT" compose up -d

echo "Running containers on server:"
docker --context "$CONTEXT" compose ps

echo "Done"
