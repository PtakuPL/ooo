#!/bin/bash
# Static audit for Canary/DB P0 tasks K140-K142.
# Verifies code/migration guards without requiring local build.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PASS=0
FAIL=0

ok() {
  PASS=$((PASS + 1))
  echo "  [PASS] $1"
}

ko() {
  FAIL=$((FAIL + 1))
  echo "  [FAIL] $1"
}

expect_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    ok "file exists: $file"
  else
    ko "missing file: $file"
  fi
}

expect_grep() {
  local label="$1"
  local pattern="$2"
  local file="$3"
  if rg -q --pcre2 "$pattern" "$file"; then
    ok "$label"
  else
    ko "$label"
  fi
}

echo "=== K140-K142 STATIC AUDIT ==="
echo "repo: $ROOT_DIR"
echo

MIGRATION_SYNC="canary_test/html_copy/apik/migrations/008_account_sync_modern.sql"
MIGRATION_SYNC_MANAGED="canary_test/html_copy/apik/v1/migrations/012_account_sync_triggers_rollout.sql"
LOGIN_PHP="canary_test/html_copy/apik/v1/login.php"
TICKET_PHP="canary_test/html_copy/apik/v1/ticket.php"
TICKET_VALIDATOR="canary_test/src/server/network/protocol/ticket_validator.cpp"
PROTOCOL_GAME="canary_test/src/server/network/protocol/protocolgame.cpp"

expect_file "$MIGRATION_SYNC"
expect_file "$MIGRATION_SYNC_MANAGED"
expect_file "$LOGIN_PHP"
expect_file "$TICKET_PHP"
expect_file "$TICKET_VALIDATOR"
expect_file "$PROTOCOL_GAME"

echo
echo "K140: Canary/DB sync triggers + initial sync"
expect_grep "initial sync into canary_modern.accounts" "INSERT INTO canary_modern\\.accounts" "$MIGRATION_SYNC"
expect_grep "trigger modern_sync_ai exists" "CREATE TRIGGER canaryaac\\.modern_sync_ai" "$MIGRATION_SYNC"
expect_grep "trigger modern_sync_au exists" "CREATE TRIGGER canaryaac\\.modern_sync_au" "$MIGRATION_SYNC"
expect_grep "trigger modern_sync_ad exists" "CREATE TRIGGER canaryaac\\.modern_sync_ad" "$MIGRATION_SYNC"

echo
echo "K180: trigger sync moved into migration system"
expect_grep "migration 012 registers in _migrations" "VALUES \\(12, '012_account_sync_triggers'\\)" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates acc_sync_ai" "CREATE TRIGGER canaryaac\\.acc_sync_ai" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates acc_sync_au" "CREATE TRIGGER canaryaac\\.acc_sync_au" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates acc_sync_ad" "CREATE TRIGGER canaryaac\\.acc_sync_ad" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates modern_sync_ai" "CREATE TRIGGER canaryaac\\.modern_sync_ai" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates modern_sync_au" "CREATE TRIGGER canaryaac\\.modern_sync_au" "$MIGRATION_SYNC_MANAGED"
expect_grep "migration 012 recreates modern_sync_ad" "CREATE TRIGGER canaryaac\\.modern_sync_ad" "$MIGRATION_SYNC_MANAGED"

echo
echo "K141: Ticket flow blocks character/world mismatch"
expect_grep "ticket.php rejects world<->mode mismatch" "ticket\\.rejected\\.world_mode_mismatch" "$TICKET_PHP"
expect_grep "ticket.php rejects character world mismatch" "ticket\\.rejected\\.character_world_mismatch" "$TICKET_PHP"
expect_grep "ticket.php returns explicit mismatch error" "Character is not assigned to selected server" "$TICKET_PHP"
expect_grep "ticket_validator has worldId mismatch guard" "Ticket worldId mismatch\\." "$TICKET_VALIDATOR"
expect_grep "protocolgame disconnects on ticket validation fail" "disconnectClient\\(\"Ticket validation failed:" "$PROTOCOL_GAME"

echo
echo "K142: worldId/gameMode mapping is consistent in key paths"
expect_grep "login.php maps worldId from games.sort_order-1" 'worldId = \(int\)\$row\['"'"'sort_order'"'"'\] - 1' "$LOGIN_PHP"
expect_grep "ticket.php maps worldId from games.sort_order-1" '\$worldId = \(int\)\$gameRow\['"'"'sort_order'"'"'\] - 1' "$TICKET_PHP"
expect_grep "login.php maps engine modern->1 and classic->0" "engineWorldId = \\(\\\$gm === 'modern'\\) \\? 1 : 0" "$LOGIN_PHP"
expect_grep "ticket.php validates requested gameMode against session mode" "ticket\\.rejected\\.game_mode_mismatch" "$TICKET_PHP"
expect_grep "login.php validates gameMode against active games table" "SELECT 1 FROM games WHERE game_mode = \\? AND status = 'active'" "$LOGIN_PHP"

echo
echo "=== SUMMARY ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
