#!/usr/bin/env bash
# deploy_bootstrap.sh — BL-17: Deploy bootstrap launcher artifact
#
# Pobiera artefakt z GHA (lub lokalnie), kopiuje na serwer,
# aktualizuje .env z SHA-256 i wersją.
#
# Użycie:
#   ./deploy_bootstrap.sh <wersja> <plik_win> [plik_linux]
#
# Przykłady:
#   ./deploy_bootstrap.sh 1.0.0 launcher-bootstrap-windows-x86_64.exe launcher-bootstrap-linux-x86_64
#   ./deploy_bootstrap.sh 1.0.0 ./artifacts/launcher-bootstrap-windows-x86_64.exe

set -euo pipefail

# ─── Konfiguracja ───
DEPLOY_DIR="${DEPLOY_DIR:-/var/www/html/files/bootstrap}"
ENV_FILE="${ENV_FILE:-/var/www/html/apik/v1/.env}"

# ─── Argumenty ───
VERSION="${1:-}"
WIN_BINARY="${2:-}"
LINUX_BINARY="${3:-}"

if [[ -z "$VERSION" || -z "$WIN_BINARY" ]]; then
    echo "Użycie: $0 <wersja> <plik_win> [plik_linux]"
    echo "Przykład: $0 1.0.0 launcher-bootstrap-windows-x86_64.exe"
    exit 1
fi

echo "═══════════════════════════════════════════"
echo "  Deploy Bootstrap Launcher v${VERSION}"
echo "═══════════════════════════════════════════"

# ─── Tworzenie katalogu docelowego ───
mkdir -p "$DEPLOY_DIR"

# ─── Kopiowanie Windows ───
if [[ -f "$WIN_BINARY" ]]; then
    DEST_WIN="${DEPLOY_DIR}/launcher-bootstrap-windows-x86_64.exe"
    cp "$WIN_BINARY" "$DEST_WIN"
    SHA_WIN=$(sha256sum "$DEST_WIN" | awk '{print $1}')
    SIZE_WIN=$(stat --format=%s "$DEST_WIN" 2>/dev/null || stat -f%z "$DEST_WIN" 2>/dev/null)
    SIZE_WIN_KB=$((SIZE_WIN / 1024))
    echo "✅ Windows: ${DEST_WIN} (${SIZE_WIN_KB} KB)"
    echo "   SHA-256: ${SHA_WIN}"
else
    echo "❌ Nie znaleziono pliku Windows: ${WIN_BINARY}"
    exit 1
fi

# ─── Kopiowanie Linux ───
SHA_LINUX=""
if [[ -n "$LINUX_BINARY" && -f "$LINUX_BINARY" ]]; then
    DEST_LINUX="${DEPLOY_DIR}/launcher-bootstrap-linux-x86_64"
    cp "$LINUX_BINARY" "$DEST_LINUX"
    chmod +x "$DEST_LINUX"
    SHA_LINUX=$(sha256sum "$DEST_LINUX" | awk '{print $1}')
    SIZE_LINUX=$(stat --format=%s "$DEST_LINUX" 2>/dev/null || stat -f%z "$DEST_LINUX" 2>/dev/null)
    SIZE_LINUX_KB=$((SIZE_LINUX / 1024))
    echo "✅ Linux:   ${DEST_LINUX} (${SIZE_LINUX_KB} KB)"
    echo "   SHA-256: ${SHA_LINUX}"
elif [[ -n "$LINUX_BINARY" ]]; then
    echo "⚠️  Nie znaleziono pliku Linux: ${LINUX_BINARY} — pomijam"
fi

# ─── Aktualizacja .env ───
if [[ -f "$ENV_FILE" ]]; then
    echo ""
    echo "📝 Aktualizuję ${ENV_FILE}..."

    # Funkcja: zamień lub dodaj klucz w .env
    update_env_key() {
        local key="$1"
        local value="$2"
        if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
            sed -i "s|^${key}=.*|${key}='${value}'|" "$ENV_FILE"
        else
            echo "${key}='${value}'" >> "$ENV_FILE"
        fi
    }

    update_env_key "BOOTSTRAP_VERSION" "$VERSION"
    update_env_key "BOOTSTRAP_DOWNLOAD_URL_WIN" "/files/bootstrap/launcher-bootstrap-windows-x86_64.exe"
    update_env_key "BOOTSTRAP_SHA256_WIN" "$SHA_WIN"
    update_env_key "BOOTSTRAP_SIZE_WIN" "$SIZE_WIN"
    update_env_key "BOOTSTRAP_RELEASE_DATE" "$(date +%Y-%m-%d)"
    update_env_key "BOOTSTRAP_NOTES" "Bootstrap Launcher v${VERSION}"

    if [[ -n "$LINUX_BINARY" && -f "$LINUX_BINARY" ]]; then
        update_env_key "BOOTSTRAP_DOWNLOAD_URL_LINUX" "/files/bootstrap/launcher-bootstrap-linux-x86_64"
        update_env_key "BOOTSTRAP_SHA256_LINUX" "$SHA_LINUX"
        update_env_key "BOOTSTRAP_SIZE_LINUX" "$SIZE_LINUX"
    fi

    echo "✅ .env zaktualizowany"
else
    echo "⚠️  Brak pliku .env: ${ENV_FILE} — pominięto aktualizację"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Deploy zakończony"
echo "  Wersja:   ${VERSION}"
echo "  Katalog:  ${DEPLOY_DIR}"
echo "═══════════════════════════════════════════"
echo ""
echo "Następne kroki:"
echo "  1. Sprawdź stronę: https://tibia.reddaxe.pl/portal/download.php"
echo "  2. Sprawdź API:    curl -s https://tibia.reddaxe.pl/apik/v1/installer-catalog.php?type=bootstrap | jq"
