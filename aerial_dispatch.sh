#!/usr/bin/env bash
set -euo pipefail

BASE="${HOME}/.aerial"
HOUR=$(date +%H)

# Set your time boundaries
if   (( 6 <= 10#${HOUR} && 10#${HOUR} < 12 )); then
  P="${BASE}/Tahoe-Morning.plist"
elif (( 12 <= 10#${HOUR} && 10#${HOUR} < 18 )); then
  P="${BASE}/Tahoe-Day.plist"
elif (( 18 <= 10#${HOUR} && 10#${HOUR} < 22 )); then
  P="${BASE}/Tahoe-Evening.plist"
else
  P="${BASE}/Tahoe-Night.plist"
fi

bash "${BASE}/update_aerial.sh" "${P}"
