@echo off
REM ============================================================
REM START_PLAYER.BAT — Uruchom klienta OTClient w trybie GRACZA (Windows)
REM ============================================================
REM Tryb GRACZA (produkcyjny):
REM   - CLIENT_LOCKED=true (wymaga launchera z OTC_LAUNCH_TOKEN)
REM   - Ticket-gate aktywny (HMAC ticket przed połączeniem)
REM   - Pełne zabezpieczenia bezpieczeństwa
REM
REM UWAGA: W normalnym trybie gracz uruchamia klienta PRZEZ LAUNCHER.
REM   Launcher sam ustawia OTC_LAUNCH_TOKEN i odpala klienta.
REM   Ten skrypt jest dla testowania trybu produkcyjnego.
REM
REM WYMAGANIA:
REM   - .env: CLIENT_LOCKED=true
REM   - Serwer gry uruchomiony
REM   - Ważny launch token (z launcher-token.php)
REM ============================================================

cd /d "%~dp0"

REM NIE ustawiamy OTC_DEV_MODE — CLIENT_LOCKED pozostaje true
REM Launcher normalnie ustawia OTC_LAUNCH_TOKEN tutaj:
REM set OTC_LAUNCH_TOKEN=<token_z_launcher-token.php>

echo [PLAYER] Uruchamiam klienta w trybie produkcyjnym...
echo [PLAYER] CLIENT_LOCKED=true, wymagany launcher token

if exist "otclient.exe" (
    otclient.exe
) else (
    echo [PLAYER] BLAD: Nie znaleziono pliku otclient.exe!
    pause
    exit /b 1
)
