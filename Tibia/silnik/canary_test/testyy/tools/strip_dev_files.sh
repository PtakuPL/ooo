#!/usr/bin/env bash
# strip_dev_files.sh — Usuwa pliki deweloperskie z paczki klienta OTClient.
#
# Użycie:
#   ./tools/strip_dev_files.sh <package_dir>
#
# Skrypt jest wywoływany ZARÓWNO:
#   - Przez build-client-package.yml (GHA, automatycznie)
#   - Lokalnie (testowanie paczki bez GHA)
#
# Wzorce denylist: src/, CMake*, *.cpp, *.h, *.hpp, *.pdb, *.ilk, *.exp,
#   *.lib, *.a, *.obj, *.o, *.rs, Cargo.*, .env*, *.key, *.secret,
#   *.ps1, *.bat, *.cmd, *.log, Makefile, .git*, backupy locale,
#   katalogi stagingowe typu data/locales/disabled i modules/.project

set -euo pipefail

PKG="${1:-}"
if [ -z "$PKG" ] || [ ! -d "$PKG" ]; then
    echo "Usage: $0 <package_dir>"
    echo "  package_dir must be an existing directory"
    exit 1
fi

echo "=== strip_dev_files.sh: cleaning $PKG ==="
BEFORE=$(find "$PKG" -type f | wc -l)

# ── 1. Remove source directories ──
rm -rf "$PKG/src" 2>/dev/null || true

# ── 2. Remove .git directories ──
find "$PKG" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PKG" -name ".git*" -not -type d -delete 2>/dev/null || true

# ── 3. Remove build system files ──
find "$PKG" \( \
    -name "CMakeLists.txt" \
    -o -name "CMakeCache.txt" \
    -o -name "cmake_install.cmake" \
    -o -name "Makefile" \
    -o -name "Cargo.toml" \
    -o -name "Cargo.lock" \
\) -type f -delete 2>/dev/null || true

# ── 4. Remove source/object files ──
find "$PKG" \( \
    -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.c" \
    -o -name "*.rs" \
    -o -name "*.obj" -o -name "*.o" \
\) -type f -delete 2>/dev/null || true

# ── 5. Remove debug/linker artifacts ──
find "$PKG" \( \
    -name "*.pdb" -o -name "*.ilk" -o -name "*.exp" \
    -o -name "*.lib" -o -name "*.a" \
\) -type f -delete 2>/dev/null || true

# ── 6. Remove env/secret files ──
find "$PKG" \( \
    -name ".env" -o -name ".env.*" \
    -o -name "*.pem.key" -o -name "*.key" -o -name "*.secret" \
\) -type f -delete 2>/dev/null || true

# ── 7. Remove scripts and logs ──
find "$PKG" \( \
    -name "*.ps1" -o -name "*.bat" -o -name "*.cmd" -o -name "*.sh" \
    -o -name "*.log" \
\) -type f -delete 2>/dev/null || true

# ── 8. Remove AI/IDE cache ──
find "$PKG" \( \
    -name ".ai_cache" -o -name ".vscode" -o -name ".idea" \
\) -type d -exec rm -rf {} + 2>/dev/null || true

# ── 8b. Remove player-package staging leftovers ──
rm -rf "$PKG/data/locales/disabled" 2>/dev/null || true
rm -rf "$PKG/modules/.project" 2>/dev/null || true
find "$PKG/modules" -type d -iname "serverSIDE" -prune -exec rm -rf {} + 2>/dev/null || true
find "$PKG" \( \
    -name "*.bak" -o -name "*.bak.*" \
    -o -name "*.backup" -o -name "*.corrupted_backup" \
    -o -name "*.utf8.bak*" -o -name "*_upstream.lua" \
\) -type f -delete 2>/dev/null || true

# ── 9. Remove misc dev files ──
rm -f "$PKG/start_dev.bat" "$PKG/start_dev.sh" "$PKG/start_player.bat" "$PKG/start_player.sh" 2>/dev/null || true
rm -f "$PKG/serverlist.lua" "$PKG/serverlist.json" "$PKG/init_serverlist.lua" 2>/dev/null || true
rm -f "$PKG/otclientrc.lua" "$PKG/otclientrc.lua.default" 2>/dev/null || true
find "$PKG" \( \
    -name "*.md" -o -name "*.patch" -o -name "*.orig" \
    -o -name "*.txt" -o -iname "README*" \
    -o -name "*.bak" -o -name "*~" \
\) -type f -delete 2>/dev/null || true

# ── Remove empty directories ──
find "$PKG" -type d -empty -delete 2>/dev/null || true

AFTER=$(find "$PKG" -type f | wc -l)
REMOVED=$((BEFORE - AFTER))

echo "  Before: $BEFORE files"
echo "  After:  $AFTER files"
echo "  Removed: $REMOVED dev files"
echo "=== strip_dev_files.sh: done ==="
