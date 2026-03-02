#!/bin/bash
# deploy_api.sh — synchronizuje pliki API z repo do /var/www/html/
# FIX47: Usprawnia deployment — jedno polecenie zamiast ręcznego kopiowania.
# Użycie: ./deploy_api.sh [--dry-run]
#
# Kopiuje:
#   html_copy/apik/v1/*.php  →  /var/www/html/apik/v1/
#   html_copy/apik/v1/*.sql  →  /var/www/html/apik/v1/
#   html_copy/apik/v1/.env   →  /var/www/html/apik/v1/.env (only if missing in dest)
#   html_copy/launcher_config.json → /var/www/html/launcher_config.json
#
# NIE kopiuje:
#   .env.example (niepotrzebny na serwerze produkcyjnym)
#   manifests/ (generowane na serwerze przez generate_manifest.php)

set -uo pipefail
# FIX65: Nie używamy -e bo cp/chown ze sudo mogą wymagać hasła i zwracać non-zero
# FIX-AUD19: Dodano zmienną ERRORS do śledzenia błędów krytycznych operacji

ERRORS=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_API="${SCRIPT_DIR}/html_copy/apik/v1"
DEST_API="/var/www/html/apik/v1"
REPO_ROOT="${SCRIPT_DIR}/html_copy"
DEST_ROOT="/var/www/html"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] — nic nie będzie kopiowane"
fi

echo "=== Deploy API: ${REPO_API} → ${DEST_API} ==="

# Upewnij się, że katalog docelowy istnieje
if [[ "$DRY_RUN" == false ]]; then
    sudo mkdir -p "${DEST_API}"
    if [[ $? -ne 0 ]]; then
        echo "  [ERROR] Nie udało się utworzyć katalogu ${DEST_API}"
        ((ERRORS++))
    fi
fi

# Kopiuj pliki PHP
CHANGED=0
for f in "${REPO_API}"/*.php; do
    fname="$(basename "$f")"
    dest="${DEST_API}/${fname}"
    if [[ -f "$dest" ]]; then
        if ! diff -q "$f" "$dest" >/dev/null 2>&1; then
            echo "  [UPDATE] ${fname}"
            if [[ "$DRY_RUN" == false ]]; then
                if ! sudo cp "$f" "$dest"; then
                    echo "  [ERROR] Nie udało się skopiować ${fname}"
                    ((ERRORS++))
                fi
            fi
            ((CHANGED++))
        else
            echo "  [OK]     ${fname}"
        fi
    else
        echo "  [NEW]    ${fname}"
        if [[ "$DRY_RUN" == false ]]; then
            if ! sudo cp "$f" "$dest"; then
                echo "  [ERROR] Nie udało się skopiować ${fname}"
                ((ERRORS++))
            fi
        fi
        ((CHANGED++))
    fi
done

# Kopiuj pliki SQL (schemat)
for f in "${REPO_API}"/*.sql; do
    [[ -f "$f" ]] || continue
    fname="$(basename "$f")"
    dest="${DEST_API}/${fname}"
    if [[ ! -f "$dest" ]] || ! diff -q "$f" "$dest" >/dev/null 2>&1; then
        echo "  [SYNC]   ${fname}"
        if [[ "$DRY_RUN" == false ]]; then
            if ! sudo cp "$f" "$dest"; then
                echo "  [ERROR] Nie udało się skopiować ${fname}"
                ((ERRORS++))
            fi
        fi
        ((CHANGED++))
    fi
done

# .env — TYLKO jeśli brak w destinacji (nie nadpisujemy prod .env!)
if [[ ! -f "${DEST_API}/.env" ]]; then
    echo "  [NEW]    .env (kopiuję z repo — zmień hasła na produkcji!)"
    if [[ "$DRY_RUN" == false ]]; then
        if ! sudo cp "${REPO_API}/.env" "${DEST_API}/.env"; then
            echo "  [ERROR] Nie udało się skopiować .env"
            ((ERRORS++))
        fi
        sudo chmod 640 "${DEST_API}/.env"
    fi
    ((CHANGED++))
else
    echo "  [SKIP]   .env (już istnieje w ${DEST_API} — nie nadpisuję)"
fi

# launcher_config.json
if [[ -f "${REPO_ROOT}/launcher_config.json" ]]; then
    dest="${DEST_ROOT}/launcher_config.json"
    if [[ ! -f "$dest" ]] || ! diff -q "${REPO_ROOT}/launcher_config.json" "$dest" >/dev/null 2>&1; then
        echo "  [SYNC]   launcher_config.json"
        if [[ "$DRY_RUN" == false ]]; then
            if ! sudo cp "${REPO_ROOT}/launcher_config.json" "$dest"; then
                echo "  [ERROR] Nie udało się skopiować launcher_config.json"
                ((ERRORS++))
            fi
        fi
        ((CHANGED++))
    fi
fi

# Ustaw właściciela i uprawnienia
if [[ "$DRY_RUN" == false && $CHANGED -gt 0 ]]; then
    sudo chown -R www-data:www-data "${DEST_API}" 2>/dev/null || true
    sudo chmod 644 "${DEST_API}"/*.php 2>/dev/null || true
    sudo chmod 640 "${DEST_API}"/.env 2>/dev/null || true
fi

echo ""
echo "=== Gotowe: ${CHANGED} plik(ów) zaktualizowanych ==="
if [[ $CHANGED -gt 0 && "$DRY_RUN" == false ]]; then
    echo "⚠  Jeśli zmieniłeś .env — sprawdź wartości na serwerze: ${DEST_API}/.env"
fi

# FIX-AUD19: Podsumowanie błędów — deploy nie powinien raportować sukcesu przy błędach
if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "🔴 UWAGA: ${ERRORS} błąd(ów) podczas kopiowania! Deploy NIE jest kompletny."
    echo "   Sprawdź logi powyżej i napraw ręcznie."
    # Nie wychodzimy z kodem != 0 bo dalej jest walidacja spójności
fi

# ================================================================
# FIX33: Walidacja spójności CLIENT_LOCKED między init.lua i .env
# ================================================================
INIT_LUA="${SCRIPT_DIR}/testyy/init.lua"
ENV_FILE="${REPO_API}/.env"

if [[ -f "$INIT_LUA" && -f "$ENV_FILE" ]]; then
    # Parsuj CLIENT_LOCKED z init.lua (Lua: CLIENT_LOCKED = true/false)
    LUA_CL=$(grep -oP '^\s*CLIENT_LOCKED\s*=\s*\K(true|false)' "$INIT_LUA" | head -1)
    # Parsuj CLIENT_LOCKED z .env (CLIENT_LOCKED=true/false)
    ENV_CL=$(grep -oP '^CLIENT_LOCKED=\K(true|false)' "$ENV_FILE" | head -1)

    if [[ -n "$LUA_CL" && -n "$ENV_CL" ]]; then
        if [[ "$LUA_CL" != "$ENV_CL" ]]; then
            echo ""
            echo "⚠ ⚠ ⚠  CLIENT_LOCKED DRYFT WYKRYTY! ⚠ ⚠ ⚠"
            echo "    init.lua: CLIENT_LOCKED = ${LUA_CL}"
            echo "    .env:     CLIENT_LOCKED = ${ENV_CL}"
            echo "    Te wartości MUSZĄ być identyczne! (FIX16/FIX33)"
            echo "    → Klient zablokowany ale API nie wymaga launchToken = luka bezpieczeństwa"
            echo ""
        else
            echo "✓ CLIENT_LOCKED spójny: init.lua=${LUA_CL}, .env=${ENV_CL}"
        fi
    fi
fi

# Walidacja TICKET_SECRET (.env vs config.lua)
CONFIG_LUA="${SCRIPT_DIR}/config.lua"
if [[ -f "$CONFIG_LUA" && -f "$ENV_FILE" ]]; then
    LUA_TS=$(grep -oP 'ticketSecret\s*=\s*"\K[^"]+' "$CONFIG_LUA" | head -1)
    ENV_TS=$(grep -oP "^TICKET_SECRET='?\K[^'\"]*" "$ENV_FILE" | head -1)
    if [[ -n "$LUA_TS" && -n "$ENV_TS" ]]; then
        if [[ "$LUA_TS" != "$ENV_TS" ]]; then
            echo ""
            echo "⚠ ⚠ ⚠  TICKET_SECRET DRYFT WYKRYTY! ⚠ ⚠ ⚠"
            echo "    config.lua: ${LUA_TS:0:16}..."
            echo "    .env:       ${ENV_TS:0:16}..."
            echo "    Te wartości MUSZĄ być identyczne! Ticket HMAC nie zadziała."
        else
            echo "✓ TICKET_SECRET spójny: config.lua == .env"
        fi
    fi
fi

# FIX-AUD19: Exit z kodem błędu jeśli były problemy kopiowania
if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi