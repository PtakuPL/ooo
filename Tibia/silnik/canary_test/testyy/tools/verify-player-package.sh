#!/usr/bin/env bash
# verify-player-package.sh — hard gate for player client packages and deployed runtimes.

set -euo pipefail

PKG="${1:-}"
PLATFORM="${2:-auto}"

if [[ -z "$PKG" || ! -d "$PKG" ]]; then
  echo "Usage: $0 <package_dir> [windows|linux|merged|auto]"
  exit 1
fi

case "$PLATFORM" in
  windows|linux|merged|auto) ;;
  *) echo "ERROR: invalid platform '$PLATFORM'"; exit 1 ;;
esac

echo "=== verify-player-package.sh: checking $PKG ($PLATFORM) ==="

fail() {
  echo "FAIL: $*"
  exit 1
}

has_file() {
  [[ -f "$PKG/$1" ]]
}

case "$PLATFORM" in
  windows)
    has_file otclient.exe || fail "missing otclient.exe"
    ;;
  linux)
    has_file otclient || fail "missing otclient"
    ;;
  merged)
    has_file otclient.exe || fail "missing otclient.exe"
    has_file otclient || fail "missing otclient"
    ;;
  auto)
    if ! has_file otclient.exe && ! has_file otclient; then
      fail "missing otclient executable"
    fi
    ;;
esac

[[ -f "$PKG/init.lua" ]] || fail "missing init.lua"
grep -q "CLIENT_LOCKED = getNativeClientLocked()" "$PKG/init.lua" || fail "init.lua is not wired to native client lock policy"
[[ -d "$PKG/modules" ]] || fail "missing modules/"
[[ -d "$PKG/data" ]] || fail "missing data/"

echo "[VERIFY] Unicode fallback fonts"
REQUIRED_FONTS=(
  data/fonts/noto-12.otfont
  data/fonts/mono-12.otfont
  data/fonts/ttf/NotoSans-Regular.ttf
  data/fonts/ttf/NotoSans-Bold.ttf
  data/fonts/ttf/NotoSansMono-Regular.ttf
  data/fonts/ttf/NotoSansSC-Regular.ttf
  data/fonts/ttf/NotoSansTC-Regular.otf
  data/fonts/ttf/NotoSansJP-Regular.otf
  data/fonts/ttf/NotoSansKR-Regular.otf
  data/fonts/ttf/NotoNaskhArabic-Regular.ttf
  data/fonts/ttf/NotoSansHebrew-Regular.ttf
  data/fonts/ttf/NotoSansThai-Regular.ttf
  data/fonts/ttf/NotoSansDevanagari-Regular.ttf
  data/fonts/ttf/NotoSansBengali-Regular.ttf
  data/fonts/ttf/NotoSansTamil-Regular.ttf
)
for required_font in "${REQUIRED_FONTS[@]}"; do
  [[ -f "$PKG/$required_font" ]] || fail "missing Unicode font asset: $required_font"
done

REQUIRED_FALLBACKS=(
  NotoSansSC-Regular.ttf
  NotoSansTC-Regular.otf
  NotoSansJP-Regular.otf
  NotoSansKR-Regular.otf
  NotoNaskhArabic-Regular.ttf
  NotoSansHebrew-Regular.ttf
  NotoSansThai-Regular.ttf
  NotoSansDevanagari-Regular.ttf
  NotoSansBengali-Regular.ttf
  NotoSansTamil-Regular.ttf
)
while IFS= read -r font_config; do
  if grep -q '^  type: ttf$' "$font_config"; then
    for fallback in "${REQUIRED_FALLBACKS[@]}"; do
      grep -q "$fallback" "$font_config" || fail "TTF font config ${font_config#$PKG/} is missing fallback $fallback"
    done
  fi
done < <(find "$PKG/data/fonts" -maxdepth 1 -name '*.otfont' -type f | sort)

echo "[VERIFY] Top-level allowlist"
while IFS= read -r item; do
  case "$item" in
    otclient|otclient.exe|init.lua|meta.lua|cacert.pem|data|modules|mods|records|*.dll|*.so|*.so.*)
      ;;
    *) fail "unexpected top-level item: $item" ;;
  esac
done < <(find "$PKG" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)

echo "[VERIFY] Denylist files"
DENYLIST=$(find "$PKG" \( \
  -name '*.pdb' -o -name '*.ilk' -o -name '*.exp' -o -name '*.lib' -o -name '*.a' -o -name '*.obj' -o -name '*.o' \
  -o -name '*.cpp' -o -name '*.c' -o -name '*.h' -o -name '*.hpp' -o -name '*.rs' -o -name 'Cargo.toml' -o -name 'Cargo.lock' \
  -o -name '.env' -o -name '.env.*' -o -name '*.pem.key' -o -name '*.key' -o -name '*.secret' \
  -o -name '*.ps1' -o -name '*.bat' -o -name '*.cmd' -o -name '*.sh' -o -name '*.log' \
  -o -name 'CMakeLists.txt' -o -name 'CMakeCache.txt' -o -name 'cmake_install.cmake' -o -name 'Makefile' \
  -o -name '*.md' -o -name '*.patch' -o -name '*.orig' -o -name '*.bak' -o -name '*.bak.*' -o -name '*.backup' \
  -o -name '*.corrupted_backup' -o -name '*.utf8.bak*' -o -name '*_upstream.lua' \
  -o -name '*.txt' -o -iname 'README*' -o -path '*/serverSIDE/*' \
\) -print | sort)

if [[ -n "$DENYLIST" ]]; then
  echo "$DENYLIST"
  fail "player package contains denylist files"
fi

echo "[VERIFY] Root dev launcher leftovers"
ROOT_LEAKS=$(find "$PKG" -maxdepth 1 \( \
  -name 'start_dev*' -o -name 'start_player*' -o -name 'serverlist.*' -o -name 'init_serverlist*' -o -name 'otclientrc.lua' -o -name 'otclientrc.lua.default' \
\) -print | sort)
if [[ -n "$ROOT_LEAKS" ]]; then
  echo "$ROOT_LEAKS"
  fail "player package contains root dev/operator files"
fi

echo "[VERIFY] Secret pattern scan"
if grep -RInE --binary-files=without-match \
  '(TICKET_SECRET|DB_PASS|MYSQL_PASSWORD|PRIVATE KEY|BEGIN [A-Z ]*PRIVATE KEY|PAYPAL_CLIENT_SECRET|GOOGLE_CLIENT_SECRET|FACEBOOK_CLIENT_SECRET|STEAM_API_KEY|HMAC_SECRET|SIGNING_KEY|AWS_SECRET|API_KEY[[:space:]]*=)' \
  "$PKG"; then
  fail "secret-like content found in package"
fi

echo "PASS: player package verified"