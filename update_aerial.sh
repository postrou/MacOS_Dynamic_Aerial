#!/usr/bin/env bash
set -euo pipefail

PROFILE_PLIST="${1:-}"
if [[ -z "${PROFILE_PLIST}" ]]; then
  echo "Usage: update_aerial.sh /path/to/Profile.plist" >&2
  exit 2
fi

DEST="${HOME}/Library/Application Support/com.apple.wallpaper/Store/Index.plist"

if [[ ! -f "${PROFILE_PLIST}" ]]; then
  echo "Profile not found: ${PROFILE_PLIST}" >&2
  exit 1
fi

# Replace active configuration
cp "${PROFILE_PLIST}" "${DEST}"

# Apply without logging out
killall WallpaperAgent || true
