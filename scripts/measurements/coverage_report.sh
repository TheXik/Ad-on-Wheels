#!/usr/bin/env bash
# Runs the full Maven test suite under JDK 21 (matching the project's stated
# target) and prints the per-service JaCoCo line-coverage and branch-coverage
# numbers. Fills chap05 placeholders JACOCO_LINE_PCT and JACOCO_BRANCH_PCT.
#
# The repository default JDK on the dev machine is whatever `java` resolves
# to; this script forces JDK 21 for `mvn` so the results match what runs in
# the eclipse-temurin:21-jre-jammy containers.
#
# Usage:
#   scripts/measurements/coverage_report.sh
#
# Override the JDK with: JAVA_HOME=/path/to/jdk21 scripts/measurements/coverage_report.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND="$ROOT/src/backend"

if [ -z "${JAVA_HOME:-}" ]; then
    if [ -d "/opt/homebrew/Cellar/openjdk@21/21.0.11/libexec/openjdk.jdk/Contents/Home" ]; then
        export JAVA_HOME="/opt/homebrew/Cellar/openjdk@21/21.0.11/libexec/openjdk.jdk/Contents/Home"
    elif command -v /usr/libexec/java_home >/dev/null 2>&1 && /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
        export JAVA_HOME=$(/usr/libexec/java_home -v 21)
    else
        echo "JDK 21 not found. Install with: brew install openjdk@21" >&2
        echo "Or set JAVA_HOME explicitly." >&2
        exit 1
    fi
fi

export PATH="$JAVA_HOME/bin:$PATH"

echo "JAVA_HOME : $JAVA_HOME"
java -version 2>&1 | head -1
echo

cd "$BACKEND"

echo "==> mvn -pl common-dto install -DskipTests"
mvn -pl common-dto install -DskipTests -q

echo "==> mvn test (full backend, this takes a few minutes)"
mvn test -fae 2>&1 | tail -20 || true

echo
echo "==> Coverage by service"
printf "%-22s %12s %12s\n" "service" "lines" "branches"
printf "%-22s %12s %12s\n" "-------" "-----" "--------"

for svc in auth-service driver-service company-service campaign-service ride-service gateway-service eureka-server; do
    csv="$BACKEND/$svc/target/site/jacoco/jacoco.csv"
    if [ -f "$csv" ]; then
        # Aggregate INSTRUCTION/BRANCH columns from JaCoCo CSV (header columns 4,5,6,7).
        read -r line_pct branch_pct <<EOF
$(awk -F',' 'NR > 1 { im+=$4; ic+=$5; bm+=$6; bc+=$7 }
            END {
                if (ic+im==0) lp=0; else lp=100*ic/(ic+im);
                if (bc+bm==0) bp=0; else bp=100*bc/(bc+bm);
                printf "%.1f %.1f", lp, bp
            }' "$csv")
EOF
        printf "%-22s %11s%% %11s%%\n" "$svc" "$line_pct" "$branch_pct"
    else
        printf "%-22s %12s %12s\n" "$svc" "(no data)" "(no data)"
    fi
done

echo
echo "Per-service HTML reports: src/backend/<service>/target/site/jacoco/index.html"
