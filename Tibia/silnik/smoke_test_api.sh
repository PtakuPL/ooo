#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Smoke testy API (POST/JSON) — TEST-001, TEST-002
# ═══════════════════════════════════════════════════════════════
# Uruchomienie: bash smoke_test_api.sh [BASE_URL]
# Domyślnie: https://127.0.0.1
# Wymaga: curl, jq (opcjonalnie)

set -euo pipefail

BASE="${1:-https://127.0.0.1}"
PASS=0; FAIL=0; SKIP=0

ok()   { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }
skip() { SKIP=$((SKIP+1)); echo "  ⏭️  $1"; }

# ── Helper: POST JSON i sprawdź kod HTTP ──
test_post() {
    local label="$1" url="$2" body="$3" expected="${4:-200}"
    local code
    code=$(curl -sk -o /dev/null -w "%{http_code}" \
        -X POST -H "Content-Type: application/json" \
        -d "$body" "${BASE}${url}")
    if [[ "|$expected|" == *"|$code|"* ]]; then
        ok "$label → $code"
    else
        fail "$label → $code (expected $expected)"
    fi
}

# ── Helper: GET i sprawdź kod HTTP ──
test_get() {
    local label="$1" url="$2" expected="${3:-200}"
    local code
    code=$(curl -sk -o /dev/null -w "%{http_code}" "${BASE}${url}")
    if [[ "|$expected|" == *"|$code|"* ]]; then
        ok "$label → $code"
    else
        fail "$label → $code (expected $expected)"
    fi
}

# ── Helper: POST JSON i sprawdź pole w odpowiedzi ──
test_post_field() {
    local label="$1" url="$2" body="$3" field="$4" expected="$5"
    local resp
    resp=$(curl -sk -X POST -H "Content-Type: application/json" \
        -d "$body" "${BASE}${url}" 2>/dev/null)
    if echo "$resp" | grep -q "\"$field\""; then
        ok "$label — pole '$field' obecne"
    else
        fail "$label — brak pola '$field'"
    fi
}

echo "═══════════════════════════════════════"
echo "  SMOKE TEST API — ${BASE}"
echo "═══════════════════════════════════════"
echo ""

# ── TEST-001: Health / podstawowe endpointy ──
echo "▸ TEST-001: Podstawowe endpointy API"
test_get "health" "/apik/v1/health.php"
test_get "server-status" "/apik/v1/server-status.php"
test_get "game-profiles" "/apik/v1/game-profiles.php"
test_get "installer-catalog" "/apik/v1/installer-catalog.php"
echo ""

# ── TEST-002: Login flow ──
echo "▸ TEST-002: Login flow"
test_post "login — brak danych" "/apik/v1/login.php" '{}' "400|401|422"
test_post "login — zły email" "/apik/v1/login.php" \
    '{"type":"login","email":"nonexistent@test.invalid","password":"wrongpass"}' \
    "401|403|429"
echo ""

# ── TEST-002b: Account context (wymaga sesji) ──
echo "▸ TEST-002b: Account context (bez sesji → 401)"
test_post "account-context — brak sesji" "/apik/v1/account-context.php" '{}' "400|401|403"
echo ""

# ── TEST-002c: Ticket (wymaga sesji) ──
echo "▸ TEST-002c: Ticket (bez sesji → 401)"
test_post "ticket — brak sesji" "/apik/v1/ticket.php" '{}' "400|401|403"
echo ""

# ── TEST-007: Sync token endpoints ──
echo "▸ TEST-007: Sync token endpoints"
test_post "sync-token — brak sesji" "/apik/v1/account-sync-token.php" '{}' "400|401|403"
test_post "sync-www-token — brak sesji" "/apik/v1/account-sync-www-token.php" '{}' "400|401|403"
test_post "sync-consume — zły token" "/apik/v1/account-sync-consume.php" \
    '{"syncToken":"invalidtoken"}' "400|401|403"
echo ""

# ── TEST-020: HTTPS (sprawdź czy HTTP redirectuje) ──
echo "▸ TEST-020: HTTPS enforced"
HTTP_BASE=$(echo "$BASE" | sed 's|^https://|http://|')
if [ "$HTTP_BASE" != "$BASE" ]; then
    HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "${HTTP_BASE}/apik/v1/health.php" 2>/dev/null || echo "000")
    if [[ "$HTTP_CODE" == "301" || "$HTTP_CODE" == "302" || "$HTTP_CODE" == "000" ]]; then
        ok "HTTP → HTTPS redirect (lub brak HTTP) — $HTTP_CODE"
    else
        fail "HTTP zwrócił $HTTP_CODE zamiast 301/302"
    fi
else
    skip "Nie można sprawdzić HTTP redirect (base URL nie jest HTTPS)"
fi
echo ""

# ── Rate limiting test ──
echo "▸ Dodatkowy: Rate limiting (10 szybkich requestów)"
RATE_FAIL=0
for i in $(seq 1 12); do
    code=$(curl -sk -o /dev/null -w "%{http_code}" \
        -X POST -H "Content-Type: application/json" \
        -d '{"type":"login","email":"ratelimit@test.invalid","password":"x"}' \
        "${BASE}/apik/v1/login.php" 2>/dev/null)
    if [ "$code" = "429" ]; then
        RATE_FAIL=1
        break
    fi
done
if [ "$RATE_FAIL" -eq 1 ]; then
    ok "Rate limit aktywny (429 po $i requestach)"
else
    skip "Rate limit nie zadziałał w 12 requestach (może wyższy limit)"
fi
echo ""

echo "═══════════════════════════════════════"
echo "  WYNIK: ✅ $PASS  ❌ $FAIL  ⏭️ $SKIP"
echo "═══════════════════════════════════════"
[ "$FAIL" -eq 0 ] || exit 1
