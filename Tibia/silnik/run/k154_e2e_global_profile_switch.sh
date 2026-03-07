#!/usr/bin/env bash
set -euo pipefail

cd /home/ptaku/serweryt/Tibia/silnik

BASE_URL="https://127.0.0.1"
TS="$(date +%s)"
ACCOUNT_NAME="k154sw_${TS}"
EMAIL="k154_sw_${TS}@example.com"
PASS="K154Switch!123"
COOKIE_JAR="/tmp/k154_profile_${TS}.cookies"
REG_JSON="/tmp/k154_reg_${TS}.json"
LOGIN_PAGE="/tmp/k154_login_page_${TS}.html"
LOGIN_POST="/tmp/k154_login_post_${TS}.html"
MANAGE_ALL="/tmp/k154_manage_all_${TS}.html"
MANAGE_CLASSIC="/tmp/k154_manage_classic_${TS}.html"
MANAGE_MODERN="/tmp/k154_manage_modern_${TS}.html"

cleanup() {
  rm -f "$COOKIE_JAR" "$REG_JSON" "$LOGIN_PAGE" "$LOGIN_POST" "$MANAGE_ALL" "$MANAGE_CLASSIC" "$MANAGE_MODERN"
}
trap cleanup EXIT

# 1) Register a fresh global account.
cat > "$REG_JSON" <<JSON
{"type":"register","accountName":"${ACCOUNT_NAME}","email":"${EMAIL}","password":"${PASS}","passwordConfirm":"${PASS}"}
JSON

REG_RESP="$(curl -sk -X POST "$BASE_URL/apik/v1/register-account.php" -H 'Content-Type: application/json' --data-binary @"$REG_JSON")"
if ! echo "$REG_RESP" | grep -q '"ok":true'; then
  echo "register_failed"
  echo "$REG_RESP"
  exit 1
fi

echo "register_ok account=${ACCOUNT_NAME}"

# 2) Login to WWW account panel and capture session cookie.
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" "$BASE_URL/index.php/account/manage" -o "$LOGIN_PAGE"
TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$LOGIN_PAGE" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$TOKEN" ]]; then
  TOKEN="$(grep -Eo '<meta name="csrf-token" content="[^"]+"' "$LOGIN_PAGE" | head -1 | sed -E 's/.*content="([^"]+)"/\1/' || true)"
fi
if [[ -z "$TOKEN" ]]; then
  echo "www_login_token_missing"
  exit 1
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST "$BASE_URL/index.php/account/manage" \
  -H "X-CSRF-TOKEN: ${TOKEN}" \
  --data-urlencode "account_login=${ACCOUNT_NAME}" \
  --data-urlencode "password_login=${PASS}" \
  --data-urlencode "token=${TOKEN}" \
  -o "$LOGIN_POST"

if ! grep -Eqi 'account/logout|Account Management|Global Profile|Create Character' "$LOGIN_POST"; then
  echo "www_login_failed"
  sed -n '1,180p' "$LOGIN_POST"
  exit 1
fi

echo "www_login_ok"

# 3) WWW profile switch -> classic74 and modern and verify marker text.
SWITCH_TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$LOGIN_POST" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$SWITCH_TOKEN" ]]; then
  SWITCH_TOKEN="$TOKEN"
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST "$BASE_URL/account/profile-switch" \
  --data-urlencode "token=${SWITCH_TOKEN}" \
  --data-urlencode "mode=classic74" \
  --data-urlencode "redirect=/account/manage" \
  -o /dev/null

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" "$BASE_URL/account/manage" -o "$MANAGE_CLASSIC"
if ! grep -q 'classic74' "$MANAGE_CLASSIC"; then
  echo "www_switch_classic_failed"
  exit 1
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST "$BASE_URL/account/profile-switch" \
  --data-urlencode "token=${SWITCH_TOKEN}" \
  --data-urlencode "mode=modern" \
  --data-urlencode "redirect=/account/manage" \
  -o /dev/null

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" "$BASE_URL/account/manage" -o "$MANAGE_MODERN"
if ! grep -q 'modern' "$MANAGE_MODERN"; then
  echo "www_switch_modern_failed"
  exit 1
fi

echo "www_profile_switch_ok"

# 4) WWW session -> launcher sync token.
SYNC_WWW_TOKEN_RESP="$(curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST "$BASE_URL/apik/v1/account-sync-www-token.php" -H 'Content-Type: application/json' -d '{"type":"account_sync_www_token","target":"launcher"}')"
SYNC_TOKEN="$(echo "$SYNC_WWW_TOKEN_RESP" | sed -n 's/.*"syncToken":"\([a-f0-9]\{64\}\)".*/\1/p' | head -1)"
if [[ -z "$SYNC_TOKEN" ]]; then
  echo "sync_www_token_failed"
  echo "$SYNC_WWW_TOKEN_RESP"
  exit 1
fi

echo "sync_www_token_ok"

# 5) Consume token to get launcher/API session key.
CONSUME_RESP="$(curl -sk -X POST "$BASE_URL/apik/v1/account-sync-consume.php" -H 'Content-Type: application/json' -d '{"type":"account_sync_consume","syncToken":"'"$SYNC_TOKEN"'","target":"launcher","source":"www"}')"
SESSION_KEY="$(echo "$CONSUME_RESP" | sed -n 's/.*"sessionKey":"\([a-f0-9]\{64\}\)".*/\1/p' | head -1)"
if [[ -z "$SESSION_KEY" ]]; then
  echo "sync_consume_failed"
  echo "$CONSUME_RESP"
  exit 1
fi
if ! echo "$CONSUME_RESP" | grep -q '"gameMode":"all"'; then
  echo "sync_consume_missing_all_mode"
  echo "$CONSUME_RESP"
  exit 1
fi

echo "sync_consume_ok"

# 6) Switch launcher/API active profile and validate via account-context.
SWITCH_RESP="$(curl -sk -X POST "$BASE_URL/apik/v1/account-profile-switch.php" -H 'Content-Type: application/json' -d '{"type":"account_profile_switch","sessionKey":"'"$SESSION_KEY"'","gameMode":"modern"}')"
if ! echo "$SWITCH_RESP" | grep -q '"ok":true'; then
  echo "api_profile_switch_failed"
  echo "$SWITCH_RESP"
  exit 1
fi
if ! echo "$SWITCH_RESP" | grep -q '"gameMode":"modern"'; then
  echo "api_profile_switch_wrong_mode"
  echo "$SWITCH_RESP"
  exit 1
fi

CTX_RESP="$(curl -sk -X POST "$BASE_URL/apik/v1/account-context.php" -H 'Content-Type: application/json' -d '{"type":"account_context","sessionKey":"'"$SESSION_KEY"'"}')"
if ! echo "$CTX_RESP" | grep -q '"gameMode":"modern"'; then
  echo "account_context_mode_not_updated"
  echo "$CTX_RESP"
  exit 1
fi
if ! echo "$CTX_RESP" | grep -q '"profileSwitchEndpoint":"/apik/v1/account-profile-switch.php"'; then
  echo "account_context_missing_profile_switch_link"
  echo "$CTX_RESP"
  exit 1
fi

echo "k154_global_profile_switch_ok account=${ACCOUNT_NAME} session=${SESSION_KEY:0:12} mode=modern"
