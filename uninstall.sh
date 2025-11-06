#!/usr/bin/env bash
set -euo pipefail

echo "=== Aerial Wallpaper Switcher - Uninstall ==="

CURRENT_USER="$(id -un)"
USER_HOME="${HOME}"
AERIAL_DIR="${USER_HOME}/.aerial"
LAUNCH_AGENTS="${USER_HOME}/Library/LaunchAgents"
LABEL="com.${CURRENT_USER}.aerial.switcher"
PLIST_PATH="${LAUNCH_AGENTS}/${LABEL}.plist"

# Stop and remove agent
echo "Stopping LaunchAgent..."
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

# Remove files
if [[ -f "${PLIST_PATH}" ]]; then
  echo "Removing plist..."
  rm -f "${PLIST_PATH}"
fi

# Ask about removing directory with profiles
if [[ -d "${AERIAL_DIR}" ]]; then
  echo ""
  read -p "Remove ~/.aerial with saved profiles? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing ${AERIAL_DIR}..."
    rm -rf "${AERIAL_DIR}"
  else
    echo "Directory ${AERIAL_DIR} preserved"
  fi
fi

echo "✓ Uninstall complete"
