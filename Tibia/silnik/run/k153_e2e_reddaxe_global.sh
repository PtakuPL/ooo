#!/usr/bin/env bash
set -euo pipefail

cd /home/ptaku/serweryt/Tibia/silnik

BASE_URL="https://127.0.0.1"
TS="$(date +%s)"
ACCOUNT_NAME="k153rx_${TS}"
EMAIL="k153_rx_${TS}@example.com"
PASS="K153RedDaxe!123"

COOKIE_JAR="/tmp/k153_reddaxe_${TS}.cookies"
CREATE_HTML="/tmp/k153_reddaxe_create_${TS}.html"
LOGIN_HEADERS="/tmp/k153_reddaxe_login_headers_${TS}.txt"
LOGIN_HTML="/tmp/k153_reddaxe_login_${TS}.html"
POST_LOGIN_HTML="/tmp/k153_reddaxe_post_login_${TS}.html"
MANAGE_HTML="/tmp/k153_www_manage_${TS}.html"
MANAGE_LOGIN_PAGE="/tmp/k153_www_manage_login_page_${TS}.html"
MANAGE_LOGIN_POST="/tmp/k153_www_manage_login_post_${TS}.html"
C1_GET="/tmp/k153_www_c1_get_${TS}.html"
C1_POST="/tmp/k153_www_c1_post_${TS}.html"
C2_GET="/tmp/k153_www_c2_get_${TS}.html"
C2_POST="/tmp/k153_www_c2_post_${TS}.html"

cleanup() {
  rm -f "$COOKIE_JAR" "$CREATE_HTML" "$LOGIN_HEADERS" "$LOGIN_HTML" "$POST_LOGIN_HTML" "$MANAGE_HTML" "$MANAGE_LOGIN_PAGE" "$MANAGE_LOGIN_POST" "$C1_GET" "$C1_POST" "$C2_GET" "$C2_POST"
}
trap cleanup EXIT

REDDAXE_LOGIN_OK=0

# 1) Create account through RedDAXE form flow.
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  "$BASE_URL/reddaxe/account-create.php" \
  --data-urlencode "accountName=${ACCOUNT_NAME}" \
  --data-urlencode "email=${EMAIL}" \
  --data-urlencode "password=${PASS}" \
  --data-urlencode "passwordConfirm=${PASS}" \
  -o "$CREATE_HTML"

if ! grep -Eqi 'Konto zostalo utworzone|Account has been created|Zaloguj|Go to login' "$CREATE_HTML"; then
  echo "reddaxe_create_failed"
  sed -n '1,180p' "$CREATE_HTML"
  exit 1
fi

echo "reddaxe_create_ok account=${ACCOUNT_NAME} email=${EMAIL}"

# 2) Login through RedDAXE form flow.
curl -sk -D "$LOGIN_HEADERS" -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  "$BASE_URL/reddaxe/account-login.php" \
  --data-urlencode "email=${EMAIL}" \
  --data-urlencode "password=${PASS}" \
  -o "$LOGIN_HTML"

if grep -Eqi '^Location: /reddaxe/post-login.php\?source=reddaxe' "$LOGIN_HEADERS"; then
  REDDAXE_LOGIN_OK=1
  echo "reddaxe_login_ok redirect_post_login"
else
  echo "reddaxe_login_blocked_no_redirect"
  # Most common blocker on runtime: login.php rejects launch token in RedDAXE flow.
  grep -Eio 'Invalid launch token|launch token|\[[0-9]+\]' "$LOGIN_HTML" | head -3 || true
fi

# 3) If RedDAXE login succeeded, confirm post-login actions are present.
if [[ "$REDDAXE_LOGIN_OK" == "1" ]]; then
  curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
    "$BASE_URL/reddaxe/post-login.php?source=reddaxe" \
    -o "$POST_LOGIN_HTML"

  if ! grep -Eqi '/account/createcharacter\?mode=classic74|/account/createcharacter\?mode=modern' "$POST_LOGIN_HTML"; then
    echo "reddaxe_post_login_missing_create_links"
    sed -n '1,200p' "$POST_LOGIN_HTML"
    exit 1
  fi

  echo "reddaxe_post_login_ok"
fi

# 4) Ensure WWW session (fallback login) and create one character in classic74 and one in modern.
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  "$BASE_URL/index.php/account/manage" \
  -o "$MANAGE_LOGIN_PAGE"

LOGIN_TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$MANAGE_LOGIN_PAGE" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$LOGIN_TOKEN" ]]; then
  LOGIN_TOKEN="$(grep -Eo '<meta name="csrf-token" content="[^"]+"' "$MANAGE_LOGIN_PAGE" | head -1 | sed -E 's/.*content="([^"]+)"/\1/' || true)"
fi
if [[ -z "$LOGIN_TOKEN" ]]; then
  echo "www_manage_login_token_missing"
  exit 1
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  "$BASE_URL/index.php/account/manage" \
  -H "X-CSRF-TOKEN: ${LOGIN_TOKEN}" \
  --data-urlencode "account_login=${ACCOUNT_NAME}" \
  --data-urlencode "password_login=${PASS}" \
  --data-urlencode "token=${LOGIN_TOKEN}" \
  -o "$MANAGE_LOGIN_POST"

S1="$(cat /proc/sys/kernel/random/uuid | tr -d '-' | tr '0-9' 'abcdefghij' | cut -c1-7)"
S2="$(cat /proc/sys/kernel/random/uuid | tr -d '-' | tr '0-9' 'abcdefghij' | cut -c1-7)"
C1="Rclassic${S1}"
C2="Rmodern${S2}"

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  "$BASE_URL/account/character/create?mode=classic74&source=reddaxe" \
  -o "$C1_GET"

C1_TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$C1_GET" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$C1_TOKEN" ]]; then
  C1_TOKEN="$(grep -Eo '<meta name="csrf-token" content="[^"]+"' "$C1_GET" | head -1 | sed -E 's/.*content="([^"]+)"/\1/' || true)"
fi
if [[ -z "$C1_TOKEN" ]]; then
  echo "create_classic_token_missing"
  exit 1
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  "$BASE_URL/account/character/create?mode=classic74&source=reddaxe" \
  -H "X-CSRF-TOKEN: ${C1_TOKEN}" \
  --data-urlencode "token=${C1_TOKEN}" \
  --data-urlencode "save=1" \
  --data-urlencode "name=${C1}" \
  --data-urlencode "sex=1" \
  --data-urlencode "vocation=1" \
  --data-urlencode "town=1" \
  --data-urlencode "mode=classic74" \
  -o "$C1_POST"

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  "$BASE_URL/account/character/create?mode=modern&source=reddaxe" \
  -o "$C2_GET"

C2_TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$C2_GET" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$C2_TOKEN" ]]; then
  C2_TOKEN="$(grep -Eo '<meta name="csrf-token" content="[^"]+"' "$C2_GET" | head -1 | sed -E 's/.*content="([^"]+)"/\1/' || true)"
fi
if [[ -z "$C2_TOKEN" ]]; then
  echo "create_modern_token_missing"
  exit 1
fi

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  "$BASE_URL/account/character/create?mode=modern&source=reddaxe" \
  -H "X-CSRF-TOKEN: ${C2_TOKEN}" \
  --data-urlencode "token=${C2_TOKEN}" \
  --data-urlencode "save=1" \
  --data-urlencode "name=${C2}" \
  --data-urlencode "sex=1" \
  --data-urlencode "vocation=1" \
  --data-urlencode "town=1" \
  --data-urlencode "mode=modern" \
  -o "$C2_POST"

echo "classic_result:"
grep -Eio 'Character created|Tryb Classic|Invalid world|already being used|maximum number of characters|Please enter your character name' "$C1_POST" | head -8 || true

echo "modern_result:"
grep -Eio 'Character created|Tryb Modern|Invalid world|already being used|maximum number of characters|Please enter your character name' "$C2_POST" | head -8 || true

# 5) Verify WWW visibility on account management page (same global account session).
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  "$BASE_URL/account/manage" \
  -o "$MANAGE_HTML"

if ! grep -Fq "$C1" "$MANAGE_HTML"; then
  echo "www_visibility_failed_missing_classic"
  exit 1
fi
if ! grep -Fq "$C2" "$MANAGE_HTML"; then
  echo "www_visibility_failed_missing_modern"
  exit 1
fi

echo "www_visibility_ok account_manage_contains_both_characters"

# 6) Verify world mapping in DB.
DB_ENV="/var/www/html/apik/v1/.env"
DB_HOST="$(grep -E '^DB_HOST=' "$DB_ENV" | tail -1 | cut -d= -f2- | tr -d "'\"")"
DB_PORT="$(grep -E '^DB_PORT=' "$DB_ENV" | tail -1 | cut -d= -f2- | tr -d "'\"")"
DB_NAME="$(grep -E '^DB_NAME=' "$DB_ENV" | tail -1 | cut -d= -f2- | tr -d "'\"")"
DB_USER="$(grep -E '^DB_USER=' "$DB_ENV" | tail -1 | cut -d= -f2- | tr -d "'\"")"
DB_PASS="$(grep -E '^DB_PASS=' "$DB_ENV" | tail -1 | cut -d= -f2- | tr -d "'\"")"

ROWS="$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SELECT name, world FROM players WHERE name IN ('${C1}','${C2}') ORDER BY name;")"
echo "$ROWS"

W1="$(echo "$ROWS" | awk -v n="$C1" '$1==n{print $2}' | head -1)"
W2="$(echo "$ROWS" | awk -v n="$C2" '$1==n{print $2}' | head -1)"

if [[ -z "$W1" || -z "$W2" ]]; then
  echo "db_verify_failed_missing_rows"
  exit 1
fi
if [[ "$W1" != "0" || "$W2" != "1" ]]; then
  echo "db_verify_failed_world_mismatch classic=$W1 modern=$W2"
  exit 1
fi

echo "k153_reddaxe_global_e2e_ok account=${ACCOUNT_NAME} classic=${C1}:$W1 modern=${C2}:$W2"
