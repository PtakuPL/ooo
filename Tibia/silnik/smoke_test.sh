#!/bin/bash
PASS=0; FAIL=0
test_url() {
    local url="$1"
    local expected="${2:-200}"
    local code
    code=$(curl -sk -o /dev/null -w "%{http_code}" "https://127.0.0.1${url}")
    if [[ "|$expected|" == *"|$code|"* ]]; then
        PASS=$((PASS+1))
        echo "OK $code $url (expected: $expected)"
    else
        FAIL=$((FAIL+1))
        echo "!! $code $url (expected: $expected)"
    fi
}

test_url "/"
test_url "/index.php?subtopic=highscores"
test_url "/community/highscores"
test_url "/community/online"
test_url "/community/characters"
test_url "/community/guilds"
test_url "/index.php?subtopic=rules"
test_url "/index.php?subtopic=online"
test_url "/portal/"
test_url "/reddaxe/"
test_url "/apik/v1/health.php"
test_url "/apik/v1/toplist.php"
test_url "/apik/v1/server-status.php"
test_url "/apik/v1/players-list.php?mode=all"
test_url "/index.php?subtopic=accountmanagement"
test_url "/index.php/account/create" "302"

echo "=== PASS=$PASS FAIL=$FAIL ==="
