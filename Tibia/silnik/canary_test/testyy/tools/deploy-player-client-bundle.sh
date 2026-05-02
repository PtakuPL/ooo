#!/usr/bin/env bash
# ============================================================
# deploy-player-client-bundle.sh
#
# Deploys the final player client runtime as one cross-platform
# update bundle: Windows package + Linux package -> one manifest.
#
# Usage:
#   ./tools/deploy-player-client-bundle.sh <windows.zip> <linux.tar.gz> <version> [channel]
#
# Example:
#   ./tools/deploy-player-client-bundle.sh \
#     otclient-windows-x64-1.2.1.zip \
#     otclient-linux-x64-1.2.1.tar.gz \
#     1.2.1 stable
#
# What it does:
#   1. Replaces /var/www/html/apik/v1/files/<channel>/<version>/
#   2. Extracts both platform packages into that directory
#   3. Generates update.php manifest and manifest_versions DB row
#   4. Stores original archives under files/<channel>/packages/
#   5. Updates installer-catalog .env metadata for client pack downloads
#   6. Moves latest -> <version>
# ============================================================

set -euo pipefail

WEB_ROOT="${WEB_ROOT:-/var/www/html/apik/v1}"
FILES_BASE="${FILES_BASE:-$WEB_ROOT/files}"
MANIFEST_SCRIPT="${MANIFEST_SCRIPT:-$WEB_ROOT/generate_manifest.php}"
ENV_FILE="${ENV_FILE:-$WEB_ROOT/.env}"
KEEP_VERSIONS="${KEEP_VERSIONS:-5}"
VERIFY_SCRIPT="${VERIFY_SCRIPT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/verify-player-package.sh}"

WIN_ARCHIVE="${1:-}"
LINUX_ARCHIVE="${2:-}"
VERSION="${3:-}"
CHANNEL="${4:-stable}"

usage() {
  echo "Usage: $0 <windows.zip> <linux.tar.gz> <version> [channel]"
}

if [[ -z "$WIN_ARCHIVE" || -z "$LINUX_ARCHIVE" || -z "$VERSION" ]]; then
  usage
  exit 1
fi

if [[ ! -f "$WIN_ARCHIVE" ]]; then
  echo "ERROR: Windows archive not found: $WIN_ARCHIVE"
  exit 1
fi

if [[ ! -f "$LINUX_ARCHIVE" ]]; then
  echo "ERROR: Linux archive not found: $LINUX_ARCHIVE"
  exit 1
fi

case "$WIN_ARCHIVE" in
  *.zip) ;;
  *) echo "ERROR: Windows archive must be .zip"; exit 1 ;;
esac

case "$LINUX_ARCHIVE" in
  *.tar.gz|*.tgz) ;;
  *) echo "ERROR: Linux archive must be .tar.gz or .tgz"; exit 1 ;;
esac

DEPLOY_DIR="$FILES_BASE/$CHANNEL/$VERSION"
CHANNEL_DIR="$FILES_BASE/$CHANNEL"
PACKAGE_DIR="$CHANNEL_DIR/packages"
LATEST_LINK="$CHANNEL_DIR/latest"
STAGING_PARENT=$(mktemp -d)
STAGING_DIR="$STAGING_PARENT/runtime"
BACKUP_DIR=""

cleanup_staging() {
  rm -rf "$STAGING_PARENT"
}

restore_on_error() {
  local exit_code=$?
  if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
    echo "ERROR: deploy failed; restoring previous runtime from $BACKUP_DIR"
    sudo rm -rf "$DEPLOY_DIR"
    sudo mv "$BACKUP_DIR" "$DEPLOY_DIR"
  fi
  cleanup_staging
  exit "$exit_code"
}

trap restore_on_error ERR
trap cleanup_staging EXIT

WIN_NAME=$(basename "$WIN_ARCHIVE")
LINUX_NAME=$(basename "$LINUX_ARCHIVE")
WIN_SHA=$(sha256sum "$WIN_ARCHIVE" | awk '{print $1}')
LINUX_SHA=$(sha256sum "$LINUX_ARCHIVE" | awk '{print $1}')
WIN_SIZE=$(stat --format=%s "$WIN_ARCHIVE" 2>/dev/null || stat -f%z "$WIN_ARCHIVE" 2>/dev/null)
LINUX_SIZE=$(stat --format=%s "$LINUX_ARCHIVE" 2>/dev/null || stat -f%z "$LINUX_ARCHIVE" 2>/dev/null)

echo "============================================================"
echo "Deploy final player client bundle"
echo "  Version: $VERSION"
echo "  Channel: $CHANNEL"
echo "  Windows: $WIN_NAME ($WIN_SIZE bytes)"
echo "  Linux:   $LINUX_NAME ($LINUX_SIZE bytes)"
echo "  Target:  $DEPLOY_DIR"
echo "============================================================"

mkdir -p "$STAGING_DIR"

echo "Extracting Windows package..."
unzip -q -o "$WIN_ARCHIVE" -d "$STAGING_DIR"

echo "Extracting Linux package..."
tar -xzf "$LINUX_ARCHIVE" -C "$STAGING_DIR"

if [[ ! -x "$VERIFY_SCRIPT" ]]; then
  echo "ERROR: verify script not found or not executable: $VERIFY_SCRIPT"
  exit 1
fi

if [[ ! -f "$STAGING_DIR/otclient.exe" ]]; then
  echo "ERROR: merged bundle is missing otclient.exe"
  exit 1
fi

if [[ ! -f "$STAGING_DIR/otclient" ]]; then
  echo "ERROR: merged bundle is missing Linux otclient binary"
  exit 1
fi

echo "Verifying merged player runtime before publishing manifest..."
"$VERIFY_SCRIPT" "$STAGING_DIR" merged

if [[ -d "$DEPLOY_DIR" ]]; then
  BACKUP_DIR="${DEPLOY_DIR}.bak.$(date +%s)"
  echo "Existing deploy found, moving to: $BACKUP_DIR"
  sudo mv "$DEPLOY_DIR" "$BACKUP_DIR"
fi

sudo mkdir -p "$DEPLOY_DIR" "$PACKAGE_DIR"
sudo cp -a "$STAGING_DIR"/. "$DEPLOY_DIR"/

echo "Copying source archives for catalog downloads..."
sudo cp "$WIN_ARCHIVE" "$PACKAGE_DIR/$WIN_NAME"
sudo cp "$LINUX_ARCHIVE" "$PACKAGE_DIR/$LINUX_NAME"

sudo chown -R www-data:www-data "$DEPLOY_DIR" "$PACKAGE_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;
sudo chmod 755 "$DEPLOY_DIR/otclient"

FILE_COUNT=$(sudo find "$DEPLOY_DIR" -type f | wc -l)
echo "Merged files: $FILE_COUNT"

if [[ -f "$MANIFEST_SCRIPT" ]]; then
  echo "Generating update manifest..."
  sudo -u www-data php "$MANIFEST_SCRIPT" "$DEPLOY_DIR" "$VERSION" "$CHANNEL" 2>&1 | tail -5
else
  echo "ERROR: manifest script not found: $MANIFEST_SCRIPT"
  exit 1
fi

sudo rm -f "$LATEST_LINK"
sudo ln -s "$VERSION" "$LATEST_LINK"
echo "Latest: $LATEST_LINK -> $VERSION"

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

MANIFEST_URL="/apik/v1/update.php?channel=${CHANNEL}&version=${VERSION}"

echo "Updating installer catalog metadata..."
update_env_key "CLIENT_PACK_VERSION" "$VERSION"
update_env_key "CLIENT_PACK_PROFILE" "player"
update_env_key "CLIENT_PACK_FILENAME_WIN" "$WIN_NAME"
update_env_key "CLIENT_PACK_FILENAME_LINUX" "$LINUX_NAME"
update_env_key "CLIENT_PACK_DOWNLOAD_URL_WIN" "/apik/v1/files/${CHANNEL}/packages/${WIN_NAME}"
update_env_key "CLIENT_PACK_DOWNLOAD_URL_LINUX" "/apik/v1/files/${CHANNEL}/packages/${LINUX_NAME}"
update_env_key "CLIENT_PACK_SHA256_WIN" "$WIN_SHA"
update_env_key "CLIENT_PACK_SHA256_LINUX" "$LINUX_SHA"
update_env_key "CLIENT_PACK_SIZE_WIN" "$WIN_SIZE"
update_env_key "CLIENT_PACK_SIZE_LINUX" "$LINUX_SIZE"
update_env_key "CLIENT_PACK_MANIFEST_URL_WIN" "$MANIFEST_URL"
update_env_key "CLIENT_PACK_MANIFEST_URL_LINUX" "$MANIFEST_URL"
update_env_key "CLIENT_PACK_RELEASE_DATE" "$(date +%Y-%m-%d)"
update_env_key "CLIENT_PACK_NOTES" "Player client bundle v${VERSION}"

if [[ -d "$CHANNEL_DIR" ]]; then
  OLD_VERSIONS=$(sudo find "$CHANNEL_DIR" -mindepth 1 -maxdepth 1 -type d -regex '.*/[0-9][0-9A-Za-z._-]*' | sort -V | head -n -"$KEEP_VERSIONS" || true)
  if [[ -n "$OLD_VERSIONS" ]]; then
    echo "Removing old versions, keeping last $KEEP_VERSIONS:"
    echo "$OLD_VERSIONS" | while read -r dir; do
      [[ -n "$dir" ]] || continue
      echo "  rm -rf $dir"
      sudo rm -rf "$dir"
    done
  fi
fi

echo ""
echo "Deploy complete: $CHANNEL/$VERSION"
echo "  Manifest: /apik/v1/update.php?channel=$CHANNEL&version=$VERSION"
echo "  Catalog:  /apik/v1/installer-catalog.php?type=client&profile=player"

trap - ERR