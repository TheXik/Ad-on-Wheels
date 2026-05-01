#!/usr/bin/env bash
# Measures end-to-end latency of the driver-home BFF call (single round-trip
# through the gateway aggregating auth, driver, ride, and campaign data) and
# compares it to the equivalent client-side fan-out (four sequential calls).
#
# Fills chap05 placeholders: BFF_MEDIAN_S, BFF_P95_S, BFF_MAX_S,
# FANOUT_MEDIAN_S, FANOUT_P95_S, FANOUT_MAX_S.
#
# Usage:
#   scripts/measurements/bff_latency.sh <DRIVER_ID> <BEARER_TOKEN> [N]
#
# Example:
#   scripts/measurements/bff_latency.sh 1 "$JWT" 100

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/measurements/_lib.sh"

DRIVER_ID="${1:?usage: bff_latency.sh DRIVER_ID JWT [N]}"
JWT="${2:?usage: bff_latency.sh DRIVER_ID JWT [N]}"
N="${3:-100}"

require_curl
ensure_gateway_up

echo "Gateway   : $GATEWAY"
echo "Driver ID : $DRIVER_ID"
echo "Iterations: $N"
echo

run_curl() {
    curl -fsS -o /dev/null \
        -w "%{time_total}\n" \
        -H "Authorization: Bearer $JWT" \
        "$1"
}

echo "==> BFF: GET /api/drivers/$DRIVER_ID/home"
{
    for i in $(seq 1 "$N"); do
        run_curl "$GATEWAY/api/drivers/$DRIVER_ID/home"
    done
} | stats_from_stdin

echo
echo "==> Fan-out: four sequential calls per iteration"
{
    for i in $(seq 1 "$N"); do
        sum_ms=$(
            {
                run_curl "$GATEWAY/drivers/$DRIVER_ID"
                run_curl "$GATEWAY/api/rides/$DRIVER_ID/statistics"
                run_curl "$GATEWAY/api/rides/$DRIVER_ID/history?limit=10"
                run_curl "$GATEWAY/campaigns"
            } | awk '{s+=$1} END {printf "%.3f", s}'
        )
        echo "$sum_ms"
    done
} | stats_from_stdin
