#!/bin/bash
# ============================================================
# START_DEV.SH — Uruchom klienta OTClient w trybie DEV
# ============================================================
# Tryb DEV:
#   - CLIENT_LOCKED=false (nie wymaga launchera)
#   - Brak ticket-gate (bezpośrednie połączenie z serwerem)
#   - Logowanie przez email+hasło do login.php (HTTPS)
#
# WYMAGANIA:
#   - Apache/nginx z SSL na porcie 443
#   - .env: CLIENT_LOCKED=false (synchronizacja z klientem)
#   - Serwer gry (canary) uruchomiony na portach 7171-7174
#   - login.php dostępny pod https://tibia.reddaxe.pl/apik/v1/login.php
#
# UŻYCIE:
#   chmod +x start_dev.sh
#   ./start_dev.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ustaw DEV_MODE — klient wyłączy CLIENT_LOCKED
export OTC_DEV_MODE=1

# Opcjonalny debug Lua
# export LOCAL_LUA_DEBUGGER_VSCODE=1

echo "[DEV] Uruchamiam klienta w trybie deweloperskim..."
echo "[DEV] CLIENT_LOCKED=false, brak wymagania launchera"
echo "[DEV] OTC_DEV_MODE=$OTC_DEV_MODE"

# Uruchom klienta
if [ -f "./otclient" ]; then
    ./otclient
elif [ -f "./otclient.exe" ]; then
    ./otclient.exe
else
    echo "[DEV] BŁĄD: Nie znaleziono pliku otclient!"
    echo "[DEV] Skompiluj klienta przez GHA i skopiuj tutaj."
    exit 1
fi
