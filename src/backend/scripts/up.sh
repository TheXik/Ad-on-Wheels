#!/bin/bash
set -e
cd "$(dirname "$0")/.."
./scripts/build.sh
./scripts/start.sh
