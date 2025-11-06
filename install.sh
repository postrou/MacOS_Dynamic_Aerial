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

# Create necessary directories
echo "Creating directories..."
mkdir -p "${AERIAL_DIR}"
mkdir -p "${LAUNCH_AGENTS}"
mkdir -p "${USER_HOME}/Library/Logs"

# Copy scripts
echo "Copying scripts..."
cp "${SCRIPT_DIR}/update_aerial.sh" "${AERIAL_DIR}/"
cp "${SCRIPT_DIR}/aerial_dispatch.sh" "${AERIAL_DIR}/"

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
echo "Next steps:"
echo "1. Select Tahoe Morning in System Settings → Wallpaper & Screensaver"
echo "2. Save the profile:"
echo "   cp ~/Library/Application\\ Support/com.apple.wallpaper/Store/Index.plist ~/.aerial/Tahoe-Morning.plist"
echo ""
echo "3. Repeat for Tahoe Day, Evening, Night"
echo ""
echo "Management:"
echo "  Check status: launchctl list | grep aerial"
echo "  Logs: tail -f ~/Library/Logs/aerial.switcher.err.log"
echo "  Test: bash ~/.aerial/aerial_dispatch.sh"
echo "  Uninstall: ./uninstall.sh"
