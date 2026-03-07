#!/usr/bin/env bash
set -euo pipefail

cd /home/ptaku/serweryt/Tibia/silnik

TS="$(date +%s)"
ACCOUNT_NAME="k134www_${TS}"
EMAIL="k134_www_${TS}@example.com"
PASS="K134Www!123"
COOKIE_JAR="/tmp/k134_www_${TS}.cookies"
REG_JSON="/tmp/k134_www_reg_${TS}.json"
LOGIN_PAGE="/tmp/k134_www_login_page_${TS}.html"
LOGIN_POST="/tmp/k134_www_login_post_${TS}.html"

json_payload=$(cat <<JSON
{"type":"register","accountName":"${ACCOUNT_NAME}","email":"${EMAIL}","password":"${PASS}","passwordConfirm":"${PASS}"}
JSON
)

curl -sk -X POST https://127.0.0.1/apik/v1/register-account.php \
  -H 'Content-Type: application/json' \
  -d "$json_payload" \
  > "$REG_JSON"

php -r '$j=json_decode(file_get_contents($argv[1]),true); if(!is_array($j)||empty($j["ok"])) {fwrite(STDERR,"register failed\n".file_get_contents($argv[1])."\n"); exit(1);} echo "register_ok accountId=".$j["accountId"]."\n";' "$REG_JSON"

# Step 1: obtain login form + CSRF token.
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  https://127.0.0.1/index.php/account/manage \
  -o "$LOGIN_PAGE"

LOGIN_TOKEN="$(grep -Eo 'name="token" value="[^"]+"' "$LOGIN_PAGE" | head -1 | sed -E 's/.*value="([^"]+)"/\1/' || true)"
if [[ -z "$LOGIN_TOKEN" ]]; then
  LOGIN_TOKEN="$(grep -Eo '<meta name="csrf-token" content="[^"]+"' "$LOGIN_PAGE" | head -1 | sed -E 's/.*content="([^"]+)"/\1/' || true)"
fi
if [[ -z "$LOGIN_TOKEN" ]]; then
  echo "login_token_missing"
  exit 1
fi

# Step 2: login using real field names expected by WWW.
curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST \
  https://127.0.0.1/index.php/account/manage \
  -H "X-CSRF-TOKEN: ${LOGIN_TOKEN}" \
  --data-urlencode "account_login=${ACCOUNT_NAME}" \
  --data-urlencode "password_login=${PASS}" \
  --data-urlencode "token=${LOGIN_TOKEN}" \
  -o "$LOGIN_POST"

if ! grep -Eqi 'account/characters/create|account/character/create|account/logout|Change Password|Manage Account' "$LOGIN_POST"; then
  echo "login_failed"
  sed -n '1,140p' "$LOGIN_POST"
  exit 1
fi

S1="$(cat /proc/sys/kernel/random/uuid | tr -d '-' | tr '0-9' 'abcdefghij' | cut -c1-7)"
S2="$(cat /proc/sys/kernel/random/uuid | tr -d '-' | tr '0-9' 'abcdefghij' | cut -c1-7)"
C1="Kclassic${S1}"
C2="Kmodern${S2}"

C1_GET="/tmp/k134_www_c1_get_${TS}.html"
C1_POST="/tmp/k134_www_c1_${TS}.html"
C2_GET="/tmp/k134_www_c2_get_${TS}.html"
C2_POST="/tmp/k134_www_c2_${TS}.html"

curl -sk -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  "https://127.0.0.1/account/character/create?mode=classic74" \
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
  "https://127.0.0.1/account/character/create?mode=classic74" \
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
  "https://127.0.0.1/account/character/create?mode=modern" \
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
  "https://127.0.0.1/account/character/create?mode=modern" \
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
grep -Eio 'Character created|Tryb Classic|Invalid world|Set a name|already being used|maximum number of characters|Please enter your character name|You are already logged in' "$C1_POST" | head -8 || true

echo "modern_result:"
grep -Eio 'Character created|Tryb Modern|Invalid world|Set a name|already being used|maximum number of characters|Please enter your character name|You are already logged in' "$C2_POST" | head -8 || true

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

echo "k134_db_verify_ok classic=$W1 modern=$W2"
