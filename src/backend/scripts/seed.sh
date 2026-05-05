#!/bin/bash
# Seed Ad-on-Wheels with deterministic demo data.
#   - 1 company
#   - 3 drivers (onboarded)
#   - 1 campaign
#   - applications (driver 1 ACCEPTED, driver 2 APPLIED, driver 3 DECLINED)
#   - 3 verified rides for driver 1 across Prague (Old Town -> Letna,
#     Wenceslas -> Vinohrady -> Vysehrad, Castle -> Smichov)
#
# Idempotent: re-running this script reuses existing accounts, campaigns
# and applications. Rides are only added on the first run (a marker is
# checked to avoid creating duplicates).
#
# Usage:
#   ./scripts/seed.sh
#
# Override defaults:
#   BASE_URL=http://localhost:8080 SEED_PASSWORD=Test123! ./scripts/seed.sh

set -e

BASE_URL="${BASE_URL:-http://localhost:8080}"
PASSWORD="${SEED_PASSWORD:-Test123!}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

for tool in curl jq python3; do
    command -v $tool >/dev/null 2>&1 || { echo -e "${RED}Missing required tool: $tool${NC}"; exit 1; }
done

# --- helpers ---------------------------------------------------------------

post_json() {
    local path=$1 data=$2 token=$3
    if [ -n "$token" ]; then
        curl -s -X POST "$BASE_URL$path" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data"
    else
        curl -s -X POST "$BASE_URL$path" \
            -H "Content-Type: application/json" \
            -d "$data"
    fi
}

patch_json() {
    local path=$1 data=$2 token=$3
    curl -s -X PATCH "$BASE_URL$path" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -d "$data"
}

get_with_token() {
    local path=$1 token=$2
    curl -s "$BASE_URL$path" -H "Authorization: Bearer $token"
}

decode_profile_id() {
    local token=$1
    python3 - "$token" <<'PY'
import sys, base64, json
token = sys.argv[1]
parts = token.split(".")
if len(parts) != 3:
    sys.exit("not a JWT")
payload = parts[1]
payload += "=" * ((4 - len(payload) % 4) % 4)
payload = payload.replace("-", "+").replace("_", "/")
data = json.loads(base64.b64decode(payload))
print(data.get("profileID", ""))
PY
}

ensure_user() {
    # role name email -> "id|token"
    local role=$1 name=$2 email=$3
    local resp=$(post_json /auth/register \
        "{\"name\":\"$name\",\"email\":\"$email\",\"password\":\"$PASSWORD\",\"role\":\"$role\"}")
    local token=$(echo "$resp" | jq -r '.data.token // empty')
    if [ -z "$token" ]; then
        # Already registered. Login.
        resp=$(post_json /auth/login "{\"email\":\"$email\",\"password\":\"$PASSWORD\"}")
        token=$(echo "$resp" | jq -r '.data.token // empty')
    fi
    if [ -z "$token" ]; then
        echo -e "${RED}Failed to ensure user $email: $resp${NC}" >&2
        return 1
    fi
    local pid=$(decode_profile_id "$token")
    echo "$pid|$token"
}

ensure_onboarded() {
    local id=$1 token=$2 plate=$3
    local body="{\"make\":\"Skoda\",\"model\":\"Octavia\",\"year\":\"2021\",\"licensePlate\":\"$plate\",\"monthlyGoalKm\":500.0}"
    patch_json "/api/drivers/$id/onboarding" "$body" "$token" >/dev/null
}

# --- 1. company + drivers --------------------------------------------------

echo -e "${BLUE}== Seeding users ==${NC}"

co=$(ensure_user COMPANY "Eval Test Corp s.r.o." "evaluator-co@test.dev")
co_id=${co%%|*}
co_token=${co##*|}
echo -e "  ${GREEN}company id=$co_id${NC}"

d1=$(ensure_user DRIVER "Demo Driver 1" "evaluator-d1@test.dev")
d1_id=${d1%%|*}; d1_token=${d1##*|}
ensure_onboarded "$d1_id" "$d1_token" "DEMO-1"
echo -e "  ${GREEN}driver 1 id=$d1_id${NC}"

d2=$(ensure_user DRIVER "Demo Driver 2" "evaluator-d2@test.dev")
d2_id=${d2%%|*}; d2_token=${d2##*|}
ensure_onboarded "$d2_id" "$d2_token" "DEMO-2"
echo -e "  ${GREEN}driver 2 id=$d2_id${NC}"

d3=$(ensure_user DRIVER "Demo Driver 3" "evaluator-d3@test.dev")
d3_id=${d3%%|*}; d3_token=${d3##*|}
ensure_onboarded "$d3_id" "$d3_token" "DEMO-3"
echo -e "  ${GREEN}driver 3 id=$d3_id${NC}"

# --- 2. campaign -----------------------------------------------------------

echo -e "${BLUE}== Seeding campaign ==${NC}"

CAMPAIGN_NAME="Demo Campaign 2026"
existing_id=$(get_with_token "/api/campaigns/company/$co_id" "$co_token" \
    | jq -r ".data[]? | select(.name == \"$CAMPAIGN_NAME\") | .id" | head -1)

if [ -n "$existing_id" ]; then
    campaign_id="$existing_id"
    echo -e "  ${YELLOW}campaign exists id=$campaign_id${NC}"
else
    body=$(cat <<EOF
{
    "name": "$CAMPAIGN_NAME",
    "description": "Seeded demo campaign. Drivers earn EUR 0.10 per kilometre. Demo data only.",
    "companyId": $co_id,
    "startDate": "2026-05-01",
    "endDate": "2026-12-31",
    "budget": 1000,
    "ratePerKm": 0.10,
    "maxDrivers": 5,
    "estimatedReach": 50000,
    "status": "RECRUITING"
}
EOF
    )
    resp=$(post_json /api/campaigns "$body" "$co_token")
    campaign_id=$(echo "$resp" | jq -r '.data.id // empty')
    if [ -z "$campaign_id" ]; then
        echo -e "${RED}Campaign create failed: $resp${NC}" >&2
        exit 1
    fi
    echo -e "  ${GREEN}campaign created id=$campaign_id${NC}"
fi

# --- 3. applications -------------------------------------------------------

echo -e "${BLUE}== Seeding applications ==${NC}"

apply_for() {
    local d_id=$1 d_token=$2
    local resp=$(post_json "/api/campaigns/$campaign_id/apply?driverId=$d_id" "" "$d_token")
    local app_id=$(echo "$resp" | jq -r '.data.id // empty')
    if [ -z "$app_id" ]; then
        # Probably already applied. Look up existing.
        app_id=$(get_with_token "/api/campaigns/driver/$d_id/applications" "$d_token" \
            | jq -r ".data[]? | select(.campaignId == $campaign_id) | .id" | head -1)
    fi
    echo "$app_id"
}

app1=$(apply_for "$d1_id" "$d1_token")
app2=$(apply_for "$d2_id" "$d2_token")
app3=$(apply_for "$d3_id" "$d3_token")
echo -e "  apps: d1=$app1, d2=$app2, d3=$app3"

set_status() {
    local app_id=$1 status=$2
    [ -z "$app_id" ] && return
    patch_json "/api/campaigns/applications/$app_id" "{\"status\":\"$status\"}" "$co_token" >/dev/null
}

set_status "$app1" ACCEPTED
set_status "$app3" DECLINED
echo -e "  ${GREEN}d1=ACCEPTED  d2=APPLIED (pending)  d3=DECLINED${NC}"

# --- 4. rides through Prague (only on first run) ---------------------------

echo -e "${BLUE}== Seeding rides ==${NC}"

# Skip if rides already exist for driver 1 (idempotency).
existing_rides=$(get_with_token "/api/rides/$d1_id/history" "$d1_token" \
    | jq -r '.data | length // 0')

if [ "$existing_rides" -gt 0 ] 2>/dev/null; then
    echo -e "  ${YELLOW}driver 1 already has $existing_rides ride(s); skipping ride seed${NC}"
else
    # Generate three ride traces through Prague with proper timestamps. Each
    # ride is a list of waypoints; we interpolate ~12 GPS points per leg with a
    # small jitter and ~30 second cadence (so implied speed lands around
    # 30-60 km/h, well under the 200 km/h glitch filter).
    rides_json=$(BASE_DAYS_AGO_1=3 BASE_DAYS_AGO_2=2 BASE_DAYS_AGO_3=1 python3 <<'PY'
import json, math, random
from datetime import datetime, timedelta, timezone
import os

random.seed(42)

# Three Prague routes (lat, lon waypoints)
routes = [
    {  # Old Town -> Charles Bridge -> Letna -> Holesovice
        "days_ago": int(os.environ["BASE_DAYS_AGO_1"]),
        "start_hour": 9,
        "duration_min": 28,
        "waypoints": [
            (50.0875, 14.4213),  # Old Town Square
            (50.0865, 14.4135),  # Charles Bridge east end
            (50.0900, 14.4080),  # Charles Bridge west end
            (50.0967, 14.4185),  # Letna Park
            (50.1027, 14.4475),  # Holesovice
        ],
    },
    {  # Wenceslas -> Vinohrady -> Vysehrad
        "days_ago": int(os.environ["BASE_DAYS_AGO_2"]),
        "start_hour": 14,
        "duration_min": 22,
        "waypoints": [
            (50.0814, 14.4262),  # Wenceslas Square
            (50.0775, 14.4400),  # Namesti Miru / Vinohrady
            (50.0712, 14.4350),  # I.P. Pavlova
            (50.0635, 14.4181),  # Vysehrad
        ],
    },
    {  # Prague Castle -> Petrin -> Andel
        "days_ago": int(os.environ["BASE_DAYS_AGO_3"]),
        "start_hour": 17,
        "duration_min": 18,
        "waypoints": [
            (50.0903, 14.4006),  # Prague Castle
            (50.0832, 14.3964),  # Petrin
            (50.0780, 14.4012),  # Ujezd
            (50.0717, 14.4036),  # Andel / Smichov
        ],
    },
]

points_per_leg = 12  # 12 samples between each pair of waypoints

all_rides = []
for r in routes:
    base = datetime.now() - timedelta(days=r["days_ago"])
    base = base.replace(hour=r["start_hour"], minute=0, second=0, microsecond=0)
    legs = len(r["waypoints"]) - 1
    total_points = legs * points_per_leg + 1  # +1 for the final endpoint
    cadence_sec = (r["duration_min"] * 60) / (total_points - 1)

    pts = []
    t = base
    for i in range(legs):
        a = r["waypoints"][i]
        b = r["waypoints"][i + 1]
        for j in range(points_per_leg):
            f = j / points_per_leg
            lat = a[0] + (b[0] - a[0]) * f + random.uniform(-3e-5, 3e-5)
            lon = a[1] + (b[1] - a[1]) * f + random.uniform(-3e-5, 3e-5)
            pts.append({
                "lat": round(lat, 7),
                "lon": round(lon, 7),
                "capturedAt": t.replace(microsecond=0).isoformat(),
            })
            t += timedelta(seconds=cadence_sec)
    # final endpoint
    last = r["waypoints"][-1]
    pts.append({
        "lat": round(last[0], 7),
        "lon": round(last[1], 7),
        "capturedAt": t.replace(microsecond=0).isoformat(),
    })
    all_rides.append(pts)

print(json.dumps(all_rides))
PY
    )

    submit_ride() {
        local points_json=$1
        local body=$(python3 - "$d1_id" "$campaign_id" "$points_json" <<'PY'
import json, sys
driver_id = sys.argv[1]
campaign_id = int(sys.argv[2])
points = json.loads(sys.argv[3])
print(json.dumps({
    "driverId": driver_id,
    "campaignId": campaign_id,
    "ratePerKm": 0.10,
    "locationPoints": points,
}))
PY
        )
        local resp=$(post_json /api/rides/deferred "$body" "$d1_token")
        echo "$resp" | jq -r '.data.completedRideId // empty'
    }

    for i in 0 1 2; do
        pts=$(echo "$rides_json" | jq -c ".[$i]")
        ride_id=$(submit_ride "$pts")
        if [ -n "$ride_id" ]; then
            # Verify the ride so its earnings count.
            curl -s -X POST "$BASE_URL/api/rides/$ride_id/verify" \
                -H "Authorization: Bearer $d1_token" >/dev/null
            echo -e "  ${GREEN}ride $((i+1)) recorded id=$ride_id (verified)${NC}"
        else
            echo -e "  ${RED}ride $((i+1)) failed${NC}"
        fi
    done
fi

# --- summary ---------------------------------------------------------------

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}  Seed complete${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "  Password for everyone: ${YELLOW}$PASSWORD${NC}"
echo ""
echo -e "  ${BLUE}Company${NC}"
echo -e "    evaluator-co@test.dev    Eval Test Corp s.r.o."
echo ""
echo -e "  ${BLUE}Drivers${NC}"
echo -e "    evaluator-d1@test.dev    ACCEPTED  (3 verified rides through Prague)"
echo -e "    evaluator-d2@test.dev    APPLIED   (waiting for review)"
echo -e "    evaluator-d3@test.dev    DECLINED"
echo ""
echo -e "  ${BLUE}Campaign${NC}"
echo -e "    $CAMPAIGN_NAME (id=$campaign_id)"
echo ""
echo -e "${GREEN}Re-run any time; existing data is reused.${NC}"
