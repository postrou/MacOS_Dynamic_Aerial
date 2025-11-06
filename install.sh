#!/usr/bin/env bash
set -euo pipefail

echo "=== Aerial Wallpaper Switcher - Installation ==="

# Determine current user and paths
CURRENT_USER="$(id -un)"
USER_HOME="${HOME}"
AERIAL_DIR="${USER_HOME}/.aerial"
LAUNCH_AGENTS="${USER_HOME}/Library/LaunchAgents"
LABEL="com.${CURRENT_USER}.aerial.switcher"
PLIST_NAME="${LABEL}.plist"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "User: ${CURRENT_USER}"
echo "Installation directory: ${AERIAL_DIR}"

# Check if .aerial directory exists with required profiles
echo "Checking prerequisites..."
if [[ ! -d "${AERIAL_DIR}" ]]; then
  echo "✗ Error: Directory ${AERIAL_DIR} not found!"
  echo ""
  echo "Please create profiles first:"
  echo "  mkdir -p ~/.aerial"
  echo "  # Then save each Tahoe profile as described in README.md"
  exit 1
fi

# Check for required profile files
REQUIRED_PROFILES=("Tahoe-Morning.plist" "Tahoe-Day.plist" "Tahoe-Evening.plist" "Tahoe-Night.plist")
MISSING_PROFILES=()

for profile in "${REQUIRED_PROFILES[@]}"; do
  if [[ ! -f "${AERIAL_DIR}/${profile}" ]]; then
    MISSING_PROFILES+=("${profile}")
  fi
done

if [[ ${#MISSING_PROFILES[@]} -gt 0 ]]; then
  echo "✗ Error: Missing profile files in ${AERIAL_DIR}:"
  for profile in "${MISSING_PROFILES[@]}"; do
    echo "  - ${profile}"
  done
  echo ""
  echo "Please create all four profiles before installation."
  echo "See README.md for instructions."
  exit 1
fi

echo "✓ All profile files found"

# Create other necessary directories
echo "Creating directories..."
mkdir -p "${LAUNCH_AGENTS}"
mkdir -p "${USER_HOME}/Library/Logs"

# Copy scripts
echo "Copying scripts..."
cp "${SCRIPT_DIR}/update_aerial.sh" "${AERIAL_DIR}/"
cp "${SCRIPT_DIR}/aerial_dispatch.sh" "${AERIAL_DIR}/"

# Make scripts executable (optional, since we call them via bash)
chmod u+x "${AERIAL_DIR}/update_aerial.sh"
chmod u+x "${AERIAL_DIR}/aerial_dispatch.sh"

# Copy and configure plist
echo "Configuring LaunchAgent..."
cp "${SCRIPT_DIR}/com.username.aerial.switcher.plist" "${LAUNCH_AGENTS}/${PLIST_NAME}"

# Replace USERNAME with actual user (macOS sed requires -i '' with space)
sed -i '' "s|USERNAME|${CURRENT_USER}|g" "${LAUNCH_AGENTS}/${PLIST_NAME}"

# Validate plist
if plutil -lint "${LAUNCH_AGENTS}/${PLIST_NAME}" > /dev/null 2>&1; then
  echo "✓ Plist is valid"
else
  echo "✗ Error in plist file!"
  exit 1
fi

# Stop agent if already loaded
echo "Stopping previous version of agent (if any)..."
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

# Load agent
echo "Loading LaunchAgent..."
launchctl bootstrap "gui/$(id -u)" "${LAUNCH_AGENTS}/${PLIST_NAME}"

# Check status
if launchctl list | grep -q "${LABEL}"; then
  echo "✓ Agent successfully loaded"
else
  echo "⚠ Agent not found in list. Check logs:"
  echo "  ${USER_HOME}/Library/Logs/aerial.switcher.err.log"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The wallpaper will switch automatically at:"
echo "  06:00 - Morning"
echo "  12:00 - Day"
echo "  18:00 - Evening"
echo "  22:00 - Night"
echo ""
echo "Management:"
echo "  Check status: launchctl list | grep aerial"
echo "  Logs: tail -f ~/Library/Logs/aerial.switcher.err.log"
echo "  Test now: bash ~/.aerial/aerial_dispatch.sh"
echo "  Uninstall: ./uninstall.sh"
