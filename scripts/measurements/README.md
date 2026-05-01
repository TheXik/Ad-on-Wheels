# Chapter 5 measurement scripts

Helpers that produce the numbers the `\{\{PLACEHOLDER\}\}` markers in
`chap05.tex` are waiting for. Each script prints the value in a form ready
to paste into the thesis.

| Script | Fills | Notes |
| --- | --- | --- |
| `register_latency.sh` | `REGISTER_LATENCY_*` | Single-call /auth/register median + p95 over N fresh accounts |
| `bff_latency.sh` | `BFF_*`, `FANOUT_*` | BFF aggregate vs four sequential client-side calls |
| `deploy_time.sh` | `DEPLOY_TIME_S` | Clean-checkout `docker compose up --build` to all-healthy |
| `coverage_report.sh` | `JACOCO_*` | JDK 21 `mvn test`, per-service line + branch coverage |

The measurements that need a real device or a person are not scripted:

- `CADENCE_*` — record a 30-minute ride on iPhone or `StreetRouteSimulator` and read the inter-arrival times of `/rides/track` from the gateway log.
- `DISTANCE_*` and `REFERENCE_KM` — walk a known 1-km route and compare to `RideStatistics.distance`.
- `T1_TIME_S`, `T2_TIME_S`, `T1_FINDINGS`, `T2_FINDINGS` — three-participant usability walkthrough.

## Running

Start the backend (`cd src/backend && ./scripts/up.sh`), then either get a
JWT manually or register a bench user with `register_latency.sh` and copy
the token from a `/auth/login` response.

```bash
# Latencies
scripts/measurements/register_latency.sh 50
scripts/measurements/bff_latency.sh 1 "$JWT" 100

# Coverage (under JDK 21)
scripts/measurements/coverage_report.sh

# Deploy time (tears down + rebuilds; takes a while)
scripts/measurements/deploy_time.sh
```

The latency scripts fail loudly if the gateway is not reachable on
`http://localhost:8080`. Set `GATEWAY` to override.
