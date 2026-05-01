#!/usr/bin/env bash
# Shared helpers for measurement scripts.

set -euo pipefail

GATEWAY="${GATEWAY:-http://localhost:8080}"

require_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required: brew install jq" >&2
        exit 1
    fi
}

require_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is required" >&2
        exit 1
    fi
}

stats_from_stdin() {
    awk '
        BEGIN { count=0 }
        /^[0-9.]+$/ { v[count++]=$1; sum+=$1; if($1>max) max=$1 }
        END {
            if (count == 0) { print "no samples"; exit 1 }
            n = asort(v)
            mean = sum/n
            p50 = v[int(n*0.50+0.5)]
            p95 = v[int(n*0.95+0.5)]
            p99 = v[int(n*0.99+0.5)]
            printf "  samples : %d\n", n
            printf "  mean    : %.3f s\n", mean
            printf "  p50     : %.3f s\n", p50
            printf "  p95     : %.3f s\n", p95
            printf "  p99     : %.3f s\n", p99
            printf "  max     : %.3f s\n", max
        }
    '
}

ensure_gateway_up() {
    if ! curl -fsS "${GATEWAY}/actuator/health" >/dev/null 2>&1; then
        echo "Gateway is not reachable at ${GATEWAY}/actuator/health" >&2
        echo "Start the backend with: cd src/backend && ./scripts/up.sh" >&2
        exit 1
    fi
}
