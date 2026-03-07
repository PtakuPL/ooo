@echo off
REM ============================================================
REM START_DEV.BAT — Uruchom klienta OTClient w trybie DEV (Windows)
REM ============================================================
REM Tryb DEV:
REM   - CLIENT_LOCKED=false (nie wymaga launchera)
REM   - Brak ticket-gate (bezpośrednie połączenie z serwerem)
REM   - Logowanie przez email+haslo do login.php (HTTPS)
REM
REM WYMAGANIA:
REM   - Serwer z SSL na porcie 443
REM   - .env: CLIENT_LOCKED=false (synchronizacja z klientem)
REM   - Serwer gry (canary) uruchomiony
REM   - login.php dostepny pod https://ADRES_SERWERA/apik/v1/login.php
REM ============================================================

cd /d "%~dp0"

REM Ustaw DEV_MODE
set OTC_DEV_MODE=1

echo [DEV] Uruchamiam klienta w trybie deweloperskim...
echo [DEV] CLIENT_LOCKED=false, brak wymagania launchera
echo [DEV] OTC_DEV_MODE=%OTC_DEV_MODE%

if exist "otclient.exe" (
    otclient.exe
) else (
    echo [DEV] BLAD: Nie znaleziono pliku otclient.exe!
    echo [DEV] Skompiluj klienta przez GHA i skopiuj tutaj.
    pause
    exit /b 1
)
