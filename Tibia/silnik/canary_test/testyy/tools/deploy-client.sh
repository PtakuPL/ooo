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

# ─── Arguments ───
ARCHIVE="${1:?Użycie: deploy-client.sh <archive> <version> [channel]}"
VERSION="${2:?Brakuje argumentu: version}"
CHANNEL="${3:-stable}"

if [ ! -f "$ARCHIVE" ]; then
  echo "ERROR: Plik '$ARCHIVE' nie istnieje"
  exit 1
fi

DEPLOY_DIR="$FILES_BASE/$CHANNEL/$VERSION"

echo "═══════════════════════════════════════"
echo "Deploy klienta OTClient"
echo "  Archive: $ARCHIVE"
echo "  Version: $VERSION"
echo "  Channel: $CHANNEL"
echo "  Target:  $DEPLOY_DIR"
echo "═══════════════════════════════════════"

# ─── 1. Create target directory ───
if [ -d "$DEPLOY_DIR" ]; then
  echo "WARN: Katalog $DEPLOY_DIR już istnieje — backup..."
  sudo mv "$DEPLOY_DIR" "${DEPLOY_DIR}.bak.$(date +%s)"
fi

sudo mkdir -p "$DEPLOY_DIR"

# ─── 2. Extract archive ───
echo "Rozpakowuję archiwum..."
case "$ARCHIVE" in
  *.zip)
    sudo unzip -q -o "$ARCHIVE" -d "$DEPLOY_DIR"
    ;;
  *.tar.gz|*.tgz)
    sudo tar -xzf "$ARCHIVE" -C "$DEPLOY_DIR"
    ;;
  *)
    echo "ERROR: Nieobsługiwany format archiwum: $ARCHIVE"
    exit 1
    ;;
esac

FILE_COUNT=$(find "$DEPLOY_DIR" -type f | wc -l)
echo "Rozpakowano: $FILE_COUNT plików"

# ─── 3. Fix permissions ───
sudo chown -R www-data:www-data "$DEPLOY_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

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
