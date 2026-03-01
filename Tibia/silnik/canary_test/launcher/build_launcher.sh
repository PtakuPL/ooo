#!/usr/bin/env bash
# E12: Build launcher z PyInstaller (Linux)
# Użycie: ./build_launcher.sh

set -e

echo "=== Building Launcher ==="

# 1. Zainstaluj zależności
pip3 install -r requirements.txt pyinstaller

# 2. Build
pyinstaller --onefile \
    --name "GameLauncher" \
    --windowed \
    --add-data "launcher_config.json:." \
    launcher.py

echo ""
echo "=== Build complete ==="
echo "Output: dist/GameLauncher"
echo ""
echo "Skopiuj do katalogu instalacyjnego:"
echo "  dist/GameLauncher       -> InstallDir/launcher"
echo "  launcher_config.json    -> InstallDir/launcher_config.json"
