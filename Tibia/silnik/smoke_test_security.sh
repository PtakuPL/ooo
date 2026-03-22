#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Statyczna analiza bezpieczeństwa — TEST-008, TEST-020, TEST-021
# ═══════════════════════════════════════════════════════════════
# Sprawdza kod źródłowy pod kątem znanych wzorców bezpieczeństwa.
# Nie wymaga uruchomionych serwerów — analiza plików na dysku.
#
# Uruchomienie: bash smoke_test_security.sh

set -euo pipefail
cd "$(dirname "$0")"

PASS=0; FAIL=0; WARN=0

ok()   { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }
warn() { WARN=$((WARN+1)); echo "  ⚠️  $1"; }

echo "═══════════════════════════════════════"
echo "  SECURITY STATIC ANALYSIS"
echo "═══════════════════════════════════════"
echo ""

# ─── TEST-020: HTTPS enforced (brak http:// w API calls) ───
echo "▸ TEST-020: HTTPS enforced — brak http:// w kodzie API/launcher"

# Sprawdź launcher Rust — brak http:// do API (pomijając komentarze i testy)
HTTP_HITS=$(grep -rn 'http://' \
    launcher-rust/crates/launcher-api/src/ \
    launcher-rust/apps/launcher-tauri/src/ \
    2>/dev/null | grep -v '^\s*//' | grep -v 'test' | grep -v 'localhost\|127\.0\.0\.1\|loopback' | wc -l)
if [ "$HTTP_HITS" -eq 0 ]; then
    ok "Launcher Rust: brak http:// do zewnętrznych endpointów"
else
    fail "Launcher Rust: znaleziono $HTTP_HITS http:// URL-i (powinno być https://)"
fi

# Sprawdź PHP API — brak http:// w redirectach (pomijając localhost)
HTTP_PHP=$(grep -rn 'http://' \
    canary_test/html_copy/apik/v1/ \
    2>/dev/null | grep -v '^\s*//' | grep -v 'localhost\|127\.0\.0\.1' | grep -v 'comment' | wc -l)
if [ "$HTTP_PHP" -eq 0 ]; then
    ok "PHP API: brak http:// URL-i"
else
    warn "PHP API: znaleziono $HTTP_PHP linii z http:// (sprawdź ręcznie)"
fi

# Sprawdź klient Lua — brak http:// do API
HTTP_LUA=$(grep -rn 'http://' \
    canary_test/testyy/modules/client_entergame/ \
    canary_test/testyy/modules/client_locales/ \
    client_pack/1.1.0/ \
    2>/dev/null | grep -v '^\s*--' | grep -v 'localhost\|127\.0\.0\.1' | wc -l)
if [ "$HTTP_LUA" -eq 0 ]; then
    ok "Klient Lua: brak http:// URL-i do API"
else
    warn "Klient Lua: znaleziono $HTTP_LUA linii z http:// (sprawdź ręcznie)"
fi
echo ""

# ─── TEST-008: Player mode sealed ───
echo "▸ TEST-008: Player mode — sealed checks"

# CLIENT_LOCKED via getNativeClientLocked()
if grep -q "CLIENT_LOCKED = getNativeClientLocked()" canary_test/testyy/init.lua; then
    ok "init.lua: CLIENT_LOCKED = getNativeClientLocked()"
else
    fail "init.lua: brak getNativeClientLocked()"
fi

if grep -q "CLIENT_LOCKED = getNativeClientLocked()" canary_test/testyy/customizations/init.lua; then
    ok "customizations/init.lua: CLIENT_LOCKED = getNativeClientLocked()"
else
    fail "customizations/init.lua: brak getNativeClientLocked()"
fi

# isPlayerMode() gate w serverlist
if grep -q "isPlayerMode\(\)" canary_test/testyy/modules/client_serverlist/serverlist.lua 2>/dev/null || \
   grep -q "isPlayerMode\(\)" canary_test/testyy/customizations/modules/client_serverlist/serverlist.lua 2>/dev/null; then
    ok "serverlist.lua: isPlayerMode() gate present"
else
    fail "serverlist.lua: brak isPlayerMode() gate"
fi

# isClientLocked() w C++
if grep -q "isClientLocked" canary_test/testyy/src/client/game.cpp; then
    ok "game.cpp: isClientLocked reference present"
else
    warn "game.cpp: brak isClientLocked (może być w innym pliku)"
fi

# Allowed worlds gate w C++
if grep -q "m_allowedWorlds" canary_test/testyy/src/client/game.cpp; then
    ok "game.cpp: allowed worlds gate present"
else
    fail "game.cpp: brak allowed worlds gate"
fi
echo ""

# ─── TEST-021: Brak sekretów w plikach klienta ───
echo "▸ TEST-021: Brak sekretów w plikach paczki klienta"

SECRET_PATTERN='(TICKET_SECRET|DB_PASS|MYSQL_PASSWORD|PRIVATE KEY|BEGIN.*PRIVATE KEY|PAYPAL_CLIENT_SECRET|GOOGLE_CLIENT_SECRET|FACEBOOK_CLIENT_SECRET|STEAM_API_KEY|HMAC_SECRET|SIGNING_KEY|AWS_SECRET)'

# Sprawdź init.lua
SECRET_INIT=$(grep -cE "$SECRET_PATTERN" canary_test/testyy/init.lua 2>/dev/null || echo 0)
if [ "$SECRET_INIT" -eq 0 ]; then
    ok "init.lua: brak wzorców sekretów"
else
    fail "init.lua: znaleziono $SECRET_INIT wzorców sekretów!"
fi

# Sprawdź customizations/
SECRET_CUSTOM=$(grep -rcE "$SECRET_PATTERN" canary_test/testyy/customizations/ 2>/dev/null | grep -v ':0$' | wc -l)
if [ "$SECRET_CUSTOM" -eq 0 ]; then
    ok "customizations/: brak wzorców sekretów"
else
    fail "customizations/: znaleziono sekrety w $SECRET_CUSTOM plikach!"
fi

# Sprawdź modules/ (Lua)
SECRET_MODULES=$(grep -rcE "$SECRET_PATTERN" canary_test/testyy/modules/ 2>/dev/null | grep -v ':0$' | wc -l)
if [ "$SECRET_MODULES" -eq 0 ]; then
    ok "modules/: brak wzorców sekretów"
else
    fail "modules/: znaleziono sekrety w $SECRET_MODULES plikach!"
fi

# Sprawdź client_pack/
if [ -d "client_pack" ]; then
    SECRET_PACK=$(grep -rcE "$SECRET_PATTERN" client_pack/ 2>/dev/null | grep -v ':0$' | wc -l)
    if [ "$SECRET_PACK" -eq 0 ]; then
        ok "client_pack/: brak wzorców sekretów"
    else
        fail "client_pack/: znaleziono sekrety w $SECRET_PACK plikach!"
    fi
fi
echo ""

# ─── Dodatkowe: danger_accept_invalid_certs ───
echo "▸ Dodatkowe: Brak danger_accept_invalid_certs w produkcji"

DANGER_BOOTSTRAP=$(grep -rn "danger_accept_invalid_certs" \
    launcher-rust/apps/launcher-bootstrap/src/ 2>/dev/null | wc -l)
if [ "$DANGER_BOOTSTRAP" -eq 0 ]; then
    ok "Bootstrap: brak danger_accept_invalid_certs"
else
    fail "Bootstrap: danger_accept_invalid_certs nadal w kodzie!"
fi

DANGER_API=$(grep -rn "danger_accept_invalid_certs" \
    launcher-rust/crates/launcher-api/src/ 2>/dev/null | grep -v '^\s*//' | wc -l)
if [ "$DANGER_API" -eq 0 ]; then
    ok "API client: brak bezwarunkowego danger_accept_invalid_certs"
elif grep -q "dev_mode\|loopback\|127\.0\.0\.1" launcher-rust/crates/launcher-api/src/client.rs 2>/dev/null; then
    ok "API client: danger_accept_invalid_certs warunkowe (dev_mode only)"
else
    fail "API client: danger_accept_invalid_certs bez warunku!"
fi
echo ""

# ─── Dodatkowe: sessionKey nigdy w URL query string ───
echo "▸ Dodatkowe: sessionKey nie w URL query string"
SESSION_IN_URL=$(grep -rn 'sessionKey.*[?&]' \
    canary_test/html_copy/apik/v1/ \
    launcher-rust/apps/launcher-tauri/ \
    2>/dev/null | grep -v '^\s*//' | grep -v '^\s*\*' | wc -l)
if [ "$SESSION_IN_URL" -eq 0 ]; then
    ok "sessionKey nie w URL query string"
else
    warn "Znaleziono $SESSION_IN_URL potencjalnych sessionKey w URL"
fi
echo ""

# ─── Dodatkowe: sync token POST-only ───
echo "▸ Dodatkowe: Sync token consume = POST-only"
if grep -q "\\\$_GET\[.*syncToken\]" canary_test/html_copy/system/pages/account/sync-login.php 2>/dev/null; then
    fail "sync-login.php: syncToken z GET (powinien być POST-only)"
else
    ok "sync-login.php: syncToken nie z GET"
fi
echo ""

echo "═══════════════════════════════════════"
echo "  WYNIK: ✅ $PASS  ❌ $FAIL  ⚠️ $WARN"
echo "═══════════════════════════════════════"
[ "$FAIL" -eq 0 ] || exit 1
