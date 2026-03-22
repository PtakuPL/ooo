#!/bin/bash
# K182: Validate critical API runtime .env contract without printing secrets.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="canary_test/html_copy/apik/v1/.env"
EXAMPLE_FILE="canary_test/html_copy/apik/v1/.env.example"

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

has_key() {
  local file="$1"
  local key="$2"
  rg -q "^[[:space:]]*${key}[[:space:]]*=" "$file"
}

non_placeholder_value() {
  local file="$1"
  local key="$2"
  local value
  value="$(sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//p" "$file" | tail -n 1)"
  value="${value%%#*}"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  value="$(echo "$value" | xargs)"
  if [[ -z "$value" ]]; then
    return 1
  fi
  if [[ "$value" == "ZMIEN_NA_LOSOWY_KLUCZ_64_ZNAKI_HEX" || "$value" == "ZMIEN_WYGENERUJ_NOWY_KLUCZ" ]]; then
    return 1
  fi
  return 0
}

echo "=== K182 ENV CONTRACT CHECK ==="
echo "repo: $ROOT_DIR"
echo

if [[ -f "$EXAMPLE_FILE" ]]; then
  ok "example env present: $EXAMPLE_FILE"
else
  ko "missing example env: $EXAMPLE_FILE"
fi

if [[ -f "$ENV_FILE" ]]; then
  ok "runtime env present: $ENV_FILE"
else
  ko "missing runtime env: $ENV_FILE"
fi

REQUIRED_KEYS=(
  DB_USER
  DB_PASS
  ENGINE_DB_HOST
  ENGINE_DB_PORT
  ENGINE_DB_NAME
  ENGINE_DB_USER
  ENGINE_DB_PASS
  ENGINE_MODERN_DB_HOST
  ENGINE_MODERN_DB_PORT
  ENGINE_MODERN_DB_NAME
  ENGINE_MODERN_DB_USER
  ENGINE_MODERN_DB_PASS
  TICKET_SECRET
)

if [[ -f "$EXAMPLE_FILE" ]]; then
  echo
  echo "Checking .env.example contract keys"
  for key in "${REQUIRED_KEYS[@]}"; do
    if has_key "$EXAMPLE_FILE" "$key"; then
      ok ".env.example has $key"
    else
      ko ".env.example missing $key"
    fi
  done
fi

if [[ -f "$ENV_FILE" ]]; then
  echo
  echo "Checking runtime .env contract keys"
  for key in "${REQUIRED_KEYS[@]}"; do
    if has_key "$ENV_FILE" "$key"; then
      ok ".env has $key"
    else
      ko ".env missing $key"
    fi
  done

  if non_placeholder_value "$ENV_FILE" "TICKET_SECRET"; then
    ok ".env TICKET_SECRET is non-empty and not a placeholder"
  else
    ko ".env TICKET_SECRET is empty or placeholder"
  fi
fi

echo
echo "=== SUMMARY ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
