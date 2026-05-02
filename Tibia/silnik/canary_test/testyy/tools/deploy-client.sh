#!/usr/bin/env bash
# ============================================================
# deploy-client.sh — Deploy nowej wersji klienta OTClient
# ============================================================
# Użycie:
#   ./deploy-client.sh <plik.zip|plik.tar.gz> <wersja> [kanał]
#
# Przykład:
#   ./deploy-client.sh otclient-windows-x64-1.0.3.zip 1.0.3 stable
#
# Co robi:
#   1. Rozpakuje artefakt do /var/www/html/apik/v1/files/<channel>/<version>/
#   2. Regeneruje manifest.json poleceniem generate_manifest.php
#   3. Aktualizuje symlink "latest" → <version>
#   4. Opcjonalnie: czyści stare wersje (zachowuje N ostatnich)
#
# Wymaga: sudo (pliki w /var/www/html należą do www-data)
# ============================================================

set -euo pipefail

# ─── Config ───
WEB_ROOT="/var/www/html/apik/v1"
FILES_BASE="$WEB_ROOT/files"
MANIFEST_SCRIPT="$WEB_ROOT/generate_manifest.php"
KEEP_VERSIONS=5  # ile starych wersji zachować
VERIFY_SCRIPT="${VERIFY_SCRIPT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/verify-player-package.sh}"

# ─── Arguments ───
ARCHIVE="${1:?Użycie: deploy-client.sh <archive> <version> [channel]}"
VERSION="${2:?Brakuje argumentu: version}"
CHANNEL="${3:-stable}"

if [ ! -f "$ARCHIVE" ]; then
  echo "ERROR: Plik '$ARCHIVE' nie istnieje"
  exit 1
fi

DEPLOY_DIR="$FILES_BASE/$CHANNEL/$VERSION"
STAGING_PARENT=$(mktemp -d)
STAGING_DIR="$STAGING_PARENT/runtime"
BACKUP_DIR=""

cleanup_staging() {
  rm -rf "$STAGING_PARENT"
}

restore_on_error() {
  local exit_code=$?
  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo "ERROR: deploy nieudany; przywracam poprzedni katalog z $BACKUP_DIR"
    sudo rm -rf "$DEPLOY_DIR"
    sudo mv "$BACKUP_DIR" "$DEPLOY_DIR"
  fi
  cleanup_staging
  exit "$exit_code"
}

trap restore_on_error ERR
trap cleanup_staging EXIT

echo "═══════════════════════════════════════"
echo "Deploy klienta OTClient"
echo "  Archive: $ARCHIVE"
echo "  Version: $VERSION"
echo "  Channel: $CHANNEL"
echo "  Target:  $DEPLOY_DIR"
echo "═══════════════════════════════════════"

# ─── 1. Create staging directory ───
mkdir -p "$STAGING_DIR"

# ─── 2. Extract archive ───
echo "Rozpakowuję archiwum..."
case "$ARCHIVE" in
  *.zip)
    unzip -q -o "$ARCHIVE" -d "$STAGING_DIR"
    ;;
  *.tar.gz|*.tgz)
    tar -xzf "$ARCHIVE" -C "$STAGING_DIR"
    ;;
  *)
    echo "ERROR: Nieobsługiwany format archiwum: $ARCHIVE"
    exit 1
    ;;
esac

FILE_COUNT=$(find "$STAGING_DIR" -type f | wc -l)
echo "Rozpakowano: $FILE_COUNT plików"

if [ -x "$VERIFY_SCRIPT" ]; then
  echo "Weryfikuję paczkę gracza przed manifestem..."
  "$VERIFY_SCRIPT" "$STAGING_DIR" auto
else
  echo "ERROR: brak verify-player-package.sh: $VERIFY_SCRIPT"
  exit 1
fi

if [ -d "$DEPLOY_DIR" ]; then
  BACKUP_DIR="${DEPLOY_DIR}.bak.$(date +%s)"
  echo "WARN: Katalog $DEPLOY_DIR już istnieje — backup: $BACKUP_DIR"
  sudo mv "$DEPLOY_DIR" "$BACKUP_DIR"
fi

sudo mkdir -p "$DEPLOY_DIR"
sudo cp -a "$STAGING_DIR"/. "$DEPLOY_DIR"/

# ─── 3. Fix permissions ───
sudo chown -R www-data:www-data "$DEPLOY_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;
if [ -f "$DEPLOY_DIR/otclient" ]; then
  sudo chmod 755 "$DEPLOY_DIR/otclient"
fi

# ─── 4. Regenerate manifest ───
if [ -f "$MANIFEST_SCRIPT" ]; then
  echo "Generuję manifest..."
  sudo -u www-data php "$MANIFEST_SCRIPT" "$DEPLOY_DIR" "$VERSION" "$CHANNEL" 2>&1 | tail -3
  echo "Manifest wygenerowany"
else
  echo "WARN: $MANIFEST_SCRIPT nie istnieje — pominięto generację manifestu"
fi

# ─── 5. Update 'latest' symlink ───
LATEST_LINK="$FILES_BASE/$CHANNEL/latest"
sudo rm -f "$LATEST_LINK"
sudo ln -s "$VERSION" "$LATEST_LINK"
echo "Symlink: $LATEST_LINK → $VERSION"

# ─── 6. Cleanup old versions ───
CHANNEL_DIR="$FILES_BASE/$CHANNEL"
if [ -d "$CHANNEL_DIR" ]; then
  OLD_VERSIONS=$(ls -1d "$CHANNEL_DIR"/[0-9]* 2>/dev/null | sort -V | head -n -"$KEEP_VERSIONS" || true)
  if [ -n "$OLD_VERSIONS" ]; then
    echo "Czyszczę stare wersje (zachowuję $KEEP_VERSIONS):"
    echo "$OLD_VERSIONS" | while read -r dir; do
      echo "  rm -rf $dir"
      sudo rm -rf "$dir"
    done
  fi
fi

echo ""
echo "✓ Deploy zakończony: $CHANNEL/$VERSION"
echo "  Plików: $FILE_COUNT"
echo "  Latest: $LATEST_LINK → $VERSION"

trap - ERR
