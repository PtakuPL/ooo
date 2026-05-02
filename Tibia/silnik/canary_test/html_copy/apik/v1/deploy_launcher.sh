#!/usr/bin/env bash
# deploy_launcher.sh - deploy full launcher ZIPs consumed by bootstrap.
#
# Usage:
#   ./deploy_launcher.sh <version> <windows.zip> [linux.zip]
#
# The ZIPs must contain launcher-tauri-windows-x86_64.exe / LauncherHelper.exe
# or launcher-tauri-linux-x86_64 / launcher-helper as produced by
# .github/workflows/release-launcher.yml.

set -euo pipefail

VERSION="${1:-}"
WIN_ZIP="${2:-}"
LINUX_ZIP="${3:-}"

DEPLOY_DIR="${DEPLOY_DIR:-/var/www/html/files/launcher}"
ENV_FILE="${ENV_FILE:-/var/www/html/apik/v1/.env}"

if [[ -z "$VERSION" || -z "$WIN_ZIP" ]]; then
  echo "Usage: $0 <version> <windows.zip> [linux.zip]"
  exit 1
fi

if [[ ! -f "$WIN_ZIP" ]]; then
  echo "ERROR: Windows launcher ZIP not found: $WIN_ZIP"
  exit 1
fi

if [[ -n "$LINUX_ZIP" && ! -f "$LINUX_ZIP" ]]; then
  echo "ERROR: Linux launcher ZIP not found: $LINUX_ZIP"
  exit 1
fi

case "$WIN_ZIP" in
  *.zip) ;;
  *) echo "ERROR: Windows launcher artifact must be a ZIP"; exit 1 ;;
esac

if [[ -n "$LINUX_ZIP" ]]; then
  case "$LINUX_ZIP" in
    *.zip) ;;
    *) echo "ERROR: Linux launcher artifact must be a ZIP"; exit 1 ;;
  esac
fi

if ! unzip -l "$WIN_ZIP" | awk '{print $4}' | grep -Eq '(^|/)launcher-tauri-windows-x86_64\.exe$'; then
  echo "ERROR: Windows ZIP missing launcher-tauri-windows-x86_64.exe"
  exit 1
fi

if ! unzip -l "$WIN_ZIP" | awk '{print $4}' | grep -Eq '(^|/)LauncherHelper\.exe$'; then
  echo "ERROR: Windows ZIP missing LauncherHelper.exe"
  exit 1
fi

if [[ -n "$LINUX_ZIP" ]]; then
  if ! unzip -l "$LINUX_ZIP" | awk '{print $4}' | grep -Eq '(^|/)launcher-tauri-linux-x86_64$'; then
    echo "ERROR: Linux ZIP missing launcher-tauri-linux-x86_64"
    exit 1
  fi
  if ! unzip -l "$LINUX_ZIP" | awk '{print $4}' | grep -Eq '(^|/)launcher-helper$'; then
    echo "ERROR: Linux ZIP missing launcher-helper"
    exit 1
  fi
fi

sudo mkdir -p "$DEPLOY_DIR"

WIN_DEST_NAME="launcher-tauri-windows-x86_64-${VERSION}.zip"
WIN_DEST="$DEPLOY_DIR/$WIN_DEST_NAME"
sudo cp "$WIN_ZIP" "$WIN_DEST"
WIN_SHA=$(sha256sum "$WIN_ZIP" | awk '{print $1}')
WIN_SIZE=$(stat --format=%s "$WIN_ZIP" 2>/dev/null || stat -f%z "$WIN_ZIP" 2>/dev/null)

LINUX_DEST_NAME=""
LINUX_SHA=""
LINUX_SIZE=""
if [[ -n "$LINUX_ZIP" ]]; then
  LINUX_DEST_NAME="launcher-tauri-linux-x86_64-${VERSION}.zip"
  sudo cp "$LINUX_ZIP" "$DEPLOY_DIR/$LINUX_DEST_NAME"
  LINUX_SHA=$(sha256sum "$LINUX_ZIP" | awk '{print $1}')
  LINUX_SIZE=$(stat --format=%s "$LINUX_ZIP" 2>/dev/null || stat -f%z "$LINUX_ZIP" 2>/dev/null)
fi

sudo chown -R www-data:www-data "$DEPLOY_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

update_env_key() {
  local key="$1"
  local value="$2"

  if [[ ! -f "$ENV_FILE" ]]; then
    echo "WARN: env file not found: $ENV_FILE"
    return 0
  fi

  if sudo grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    sudo sed -i "s|^${key}=.*|${key}='${value}'|" "$ENV_FILE"
  else
    printf "%s='%s'\n" "$key" "$value" | sudo tee -a "$ENV_FILE" >/dev/null
  fi
}

update_env_key "LAUNCHER_VERSION" "$VERSION"
update_env_key "LAUNCHER_PACKAGE_URL_WIN" "/files/launcher/${WIN_DEST_NAME}"
update_env_key "LAUNCHER_PACKAGE_FILENAME_WIN" "$WIN_DEST_NAME"
update_env_key "LAUNCHER_PACKAGE_SHA256_WIN" "$WIN_SHA"
update_env_key "LAUNCHER_PACKAGE_SIZE_WIN" "$WIN_SIZE"
update_env_key "LAUNCHER_RELEASE_DATE" "$(date +%Y-%m-%d)"
update_env_key "LAUNCHER_NOTES" "Launcher v${VERSION}"

if [[ -n "$LINUX_ZIP" ]]; then
  update_env_key "LAUNCHER_PACKAGE_URL_LINUX" "/files/launcher/${LINUX_DEST_NAME}"
  update_env_key "LAUNCHER_PACKAGE_FILENAME_LINUX" "$LINUX_DEST_NAME"
  update_env_key "LAUNCHER_PACKAGE_SHA256_LINUX" "$LINUX_SHA"
  update_env_key "LAUNCHER_PACKAGE_SIZE_LINUX" "$LINUX_SIZE"
fi

echo "Launcher deploy complete: v${VERSION}"
echo "  Windows: /files/launcher/${WIN_DEST_NAME}"
if [[ -n "$LINUX_ZIP" ]]; then
  echo "  Linux:   /files/launcher/${LINUX_DEST_NAME}"
fi
echo "  Catalog: /apik/v1/installer-catalog.php?type=launcher"