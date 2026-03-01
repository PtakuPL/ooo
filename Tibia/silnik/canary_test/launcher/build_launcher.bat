@echo off
REM E12: Build launcher.exe z PyInstaller (Windows)
REM Użycie: build_launcher.bat

echo === Building Launcher ===

REM 1. Zainstaluj zależności
pip install -r requirements.txt pyinstaller

REM 2. Build .exe
REM FIX17: --icon wykomentowany — icon.ico nie istnieje.
REM        Dodaj plik icon.ico do katalogu launcher/ i odkomentuj poniższe.
pyinstaller --onefile ^
    --name "GameLauncher" ^
    --windowed ^
    --add-data "launcher_config.json;." ^
    launcher.py

echo.
echo === Build complete ===
echo Output: dist/GameLauncher.exe
echo.
echo Skopiuj do katalogu instalacyjnego:
echo   dist/GameLauncher.exe -> InstallDir/launcher.exe
echo   launcher_config.json  -> InstallDir/launcher_config.json
pause
