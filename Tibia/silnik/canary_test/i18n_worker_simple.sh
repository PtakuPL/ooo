#!/bin/bash
#===============================================================================
# I18N WORKER v2.0 - Multi-Mode Worker z trybami pracy
#===============================================================================
# TRYBY:
#   1. MIGRATION   - Migracja kodu NPC (8 etapów) - domyślny
#   2. TRANSLATION - Tłumaczenia kluczy EN → inne języki (6 etapów + składnie)
#   3. VALIDATION  - Walidacja tłumaczeń (4 etapy)
#
# Worker automatycznie przełącza się między trybami w trybie --continuous
#===============================================================================

cd "$(dirname "$0")"
WORK_DIR="$(pwd)"

# Repo root (do odczytu komend z origin/master bez robienia pull)
REPO_ROOT="$(git -C "$WORK_DIR" rev-parse --show-toplevel 2>/dev/null || echo "")"

STATUS_FILE="i18n_file_status.json"
I18N_DIR="i18n"
BACKUP_DIR="backups"
PROCESSED_FILE="i18n_processed_files.txt"

# Konfiguracja trybów
MIGRATION_BATCH=50          # Ile plików na cykl migracji (total)
MINI_BATCH=10               # Ile plików w mini-batch
MINI_PAUSE=3                # Pauza między mini-batch (sekundy)
CYCLE_PAUSE=12              # Pauza po pełnym cyklu (sekundy)
TRANSLATION_BATCH=300       # Ile kluczy na batch synchronizacji
TRANSLATION_SUBSTAGE=4      # Ile kluczy na składnię
LANG_PRIORITY="de pl es pt fr it ru nl sv da no fi cs"  # Priorytet języków (Europa first)

# Nowe opcje (Agent 2)
NO_GIT=false                # Flaga --no-git: wyłącza git add/commit/push
TRANSLATE_LIMIT=0           # --translate-limit N: max kluczy do przetłumaczenia na cykl (0=brak limitu)
TRANSLATIONS_ONLY=false     # --translations-only: tylko tłumaczenia, bez migracji kodu

# Zakres pracy workera:
# - server: tylko serwer (bez website + OTClient/testyy)
# - full (domyślnie): serwer + instalka (OTClient/testyy), bez website
# - all: wszystkie zdefiniowane kategorie (w tym website)
I18N_SCOPE="${I18N_SCOPE:-full}"
export I18N_SCOPE

# Statusy (LIVE + zdarzenia + daily) - docelowo źródło prawdy dla I18N_STATUS.md
STATUS_DIR="$I18N_DIR/status"

status_update_activity() {
    # Użycie:
    #   status_update_activity <status> <cycle> <phase> <stage> <category> <file> <message> <done> <total> <unit> <eta>
    local st="${1:-running}"; shift || true
    local cycle="${1:-0}"; shift || true
    local phase="${1:-IDLE}"; shift || true
    local stage="${1:--}"; shift || true
    local category="${1:--}"; shift || true
    local file="${1:--}"; shift || true
    local message="${1:-}"; shift || true
    local done="${1:-0}"; shift || true
    local total="${1:-0}"; shift || true
    local unit="${1:-units}"; shift || true
    local eta="${1:-0}"; shift || true

    mkdir -p "$STATUS_DIR" "$STATUS_DIR/categories" "$STATUS_DIR/daily" 2>/dev/null
    python3 tools/i18n_status.py --status-dir "$STATUS_DIR" update-activity \
        --status "$st" \
        --cycle "$cycle" \
        --phase "$phase" \
        --stage "$stage" \
        --category "$category" \
        --file "$file" \
        --message "$message" \
        --progress-done "$done" \
        --progress-total "$total" \
        --progress-unit "$unit" \
        --eta-seconds "$eta" \
        >/dev/null 2>&1 || true
}

status_log_op() {
    # Użycie:
    #   status_log_op <cycle> <phase> <stage> <category> <file> <result> <detail> [keys_added] [files_changed] [mapped_new] [translated] [skipped]
    local cycle="${1:-0}"; shift || true
    local phase="${1:-IDLE}"; shift || true
    local stage="${1:--}"; shift || true
    local category="${1:--}"; shift || true
    local file="${1:--}"; shift || true
    local result="${1:-ok}"; shift || true
    local detail="${1:-}"; shift || true
    local keys_added="${1:-}"; shift || true
    local files_changed="${1:-}"; shift || true
    local mapped_new="${1:-}"; shift || true
    local translated="${1:-}"; shift || true
    local skipped="${1:-}"; shift || true

    mkdir -p "$STATUS_DIR" 2>/dev/null
    local args=(--status-dir "$STATUS_DIR" log-op --cycle "$cycle" --phase "$phase" --stage "$stage" --category "$category" --file "$file" --result "$result")
    [ -n "$detail" ] && args+=(--detail "$detail")
    [ -n "$keys_added" ] && args+=(--keys-added "$keys_added")
    [ -n "$files_changed" ] && args+=(--files-changed "$files_changed")
    [ -n "$mapped_new" ] && args+=(--mapped-new "$mapped_new")
    [ -n "$translated" ] && args+=(--translated "$translated")
    [ -n "$skipped" ] && args+=(--skipped "$skipped")
    python3 tools/i18n_status.py "${args[@]}" >/dev/null 2>&1 || true
}

status_log_error() {
    # Użycie:
    #   status_log_error <cycle> <phase> <stage> <category> <file> <error> <action>
    local cycle="${1:-0}"; shift || true
    local phase="${1:--}"; shift || true
    local stage="${1:--}"; shift || true
    local category="${1:--}"; shift || true
    local file="${1:--}"; shift || true
    local error="${1:-error}"; shift || true
    local action="${1:-}"; shift || true

    mkdir -p "$STATUS_DIR" 2>/dev/null
    python3 tools/i18n_status.py --status-dir "$STATUS_DIR" log-error \
        --cycle "$cycle" --phase "$phase" --stage "$stage" --category "$category" --file "$file" \
        --error "$error" --action "$action" \
        >/dev/null 2>&1 || true
}

status_build_daily() {
    # Użycie: status_build_daily [YYYY-MM-DD]
    local date_utc="${1:-}"
    mkdir -p "$STATUS_DIR/daily" 2>/dev/null
    if [ -n "$date_utc" ]; then
        python3 tools/i18n_status.py --status-dir "$STATUS_DIR" build-daily --date "$date_utc" >/dev/null 2>&1 || true
    else
        python3 tools/i18n_status.py --status-dir "$STATUS_DIR" build-daily >/dev/null 2>&1 || true
    fi
}

status_lock_acquire() {
    if command -v flock >/dev/null 2>&1; then
        exec 9>".i18n_status.lock"
        flock -w 10 9 || return 1
    fi
    return 0
}

status_lock_release() {
    if command -v flock >/dev/null 2>&1; then
        flock -u 9 2>/dev/null || true
        exec 9>&-
    fi
}

category_lock_acquire() {
    if command -v flock >/dev/null 2>&1; then
        exec 8>".i18n_category_state.lock"
        flock -w 10 8 || return 1
    fi
    return 0
}

category_lock_release() {
    if command -v flock >/dev/null 2>&1; then
        flock -u 8 2>/dev/null || true
        exec 8>&-
    fi
}

#===============================================================================
# SELF_CHECK - szybki sanity check środowiska i statusów
#===============================================================================
self_check() {
    local ok=1
    local script_path="$WORK_DIR/i18n_worker_simple.sh"
    local tools=(
        "tools/i18n_status.py"
        "tools/i18n_migrate_lua_sendtext.py"
        "tools/i18n_migrate_lua_say.py"
        "tools/i18n_migrate_lua_broadcast.py"
        "tools/i18n_keymap.py"
        "tools/json_to_lua_locales.py"
    )
    local json_files=(
        "$STATUS_FILE"
        ".i18n_category_state.json"
        "i18n_global_stats.json"
        "i18n/new_files_detected.json"
        "i18n/quality_report.json"
    )

    echo "🔎 SELF-CHECK: $script_path"

    if command -v bash >/dev/null 2>&1; then
        if bash -n "$script_path" >/dev/null 2>&1; then
            echo "✅ bash -n: OK"
        else
            echo "❌ bash -n: FAILED"
            ok=0
        fi
    else
        echo "❌ bash: brak w PATH"
        ok=0
    fi

    if command -v python3 >/dev/null 2>&1; then
        echo "✅ python3: OK"
    else
        echo "❌ python3: brak w PATH"
        ok=0
    fi

    for tool in "${tools[@]}"; do
        if [ -f "$tool" ]; then
            echo "✅ tool: $tool"
        else
            echo "❌ tool: brak $tool"
            ok=0
        fi
    done

    for jf in "${json_files[@]}"; do
        if [ -f "$jf" ]; then
            if python3 -m json.tool "$jf" >/dev/null 2>&1; then
                echo "✅ json: $jf"
            else
                echo "❌ json: niepoprawny $jf"
                ok=0
            fi
        else
            echo "⚠️ json: brak $jf"
        fi
    done

    local state_file=".i18n_category_state.json"
    local state_backup=""
    local had_state=0
    if [ -f "$state_file" ]; then
        had_state=1
        state_backup="$(mktemp)"
        cp "$state_file" "$state_backup"
    fi

    local mode_result=""
    mode_result=$(select_work_mode 2>/dev/null || true)

    if [ "$had_state" -eq 1 ] && [ -n "$state_backup" ]; then
        mv "$state_backup" "$state_file"
    elif [ "$had_state" -eq 0 ]; then
        rm -f "$state_file" 2>/dev/null || true
    fi

    if [[ "$mode_result" =~ ^[A-Z_]+: ]]; then
        echo "✅ dispatcher: $mode_result"
    else
        echo "❌ dispatcher: niepoprawny output: ${mode_result:-<empty>}"
        ok=0
    fi

    if [ "$ok" -eq 1 ]; then
        echo "✅ SELF-CHECK: OK"
        return 0
    fi

    echo "❌ SELF-CHECK: FAIL"
    return 1
}

#===============================================================================
# GET_UNPROCESSED_FILES - Znajdź pliki które jeszcze nie były przetwarzane
#===============================================================================
# Użycie: get_unprocessed_files <find_args...> <batch_size>
# Przykład: get_unprocessed_files data-otservbr-global/monster -name "*.lua" 50
# Zwraca listę plików które NIE są w PROCESSED_FILE, max batch_size
#===============================================================================
get_unprocessed_files() {
    local batch=50
    local find_args=()

    if [ "$#" -ge 1 ]; then
        local last_arg="${@: -1}"
        if [[ "$last_arg" =~ ^[0-9]+$ ]]; then
            batch="$last_arg"
            if [ "$#" -gt 1 ]; then
                find_args=("${@:1:$#-1}")
            fi
        else
            find_args=("$@")
        fi
    fi

    if [ "${#find_args[@]}" -eq 0 ]; then
        return 1
    fi

    # Filtruj processed i weź batch
    find "${find_args[@]}" 2>/dev/null | while read -r f; do
        grep -qF "$f" "$PROCESSED_FILE" 2>/dev/null || echo "$f"
    done | head -n "$(sanitize_batch "$batch" 50)"
}

sanitize_batch() {
    local value="${1:-}"
    local default="${2:-10}"
    if [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -gt 0 ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

py_regex_matches() {
    local file="$1"
    local pattern="$2"
    local limit="${3:-1}"
    python3 - "$file" "$pattern" "$limit" << 'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
pattern = sys.argv[2]
try:
    limit = int(sys.argv[3])
except Exception:
    limit = 1

try:
    text = path.read_text(encoding="utf-8", errors="ignore")
except Exception:
    sys.exit(0)

count = 0
for m in re.finditer(pattern, text, re.DOTALL):
    if m.groups():
        val = m.group(1)
    else:
        val = m.group(0)
    if val is None:
        continue
    print(val)
    count += 1
    if limit > 0 and count >= limit:
        break
PY
}

title_case() {
    local text="$1"
    python3 - "$text" << 'PY'
import sys

value = sys.argv[1] if len(sys.argv) > 1 else ""
print(value.title())
PY
}

#===============================================================================
# MARK_FILE_COMPLETED - Zapisz plik do obu źródeł (processed + file_status)
#===============================================================================
mark_file_completed() {
    local file="$1"
    local category="$2"
    local keys_added="${3:-0}"
    
    # 1. Dodaj do processed_files.txt (jeśli nie ma)
    if ! grep -qF "$file" "$PROCESSED_FILE" 2>/dev/null; then
        echo "$file" >> "$PROCESSED_FILE"
    fi
    
    # 2. Dodaj do i18n_file_status.json (nie nadpisuj istniejących etapów)
    if ! status_lock_acquire; then
        return 1
    fi
    python3 << PYMARK
import json
import os
import shutil
from datetime import datetime

status_file = "$STATUS_FILE"
file_path = "$file"
category = "$category"
keys_added = int("$keys_added") if "$keys_added".isdigit() else 0

try:
    with open(status_file) as f:
        status = json.load(f)
except:
    status = {}

# Upewnij się że struktura istnieje
if "files" not in status:
    status["files"] = {}
if "global_stats" not in status:
    status["global_stats"] = {"files_completed": 0, "total_keys": 0}

file_info = status["files"].get(file_path, {})
stages = file_info.get("stages", {})

if "1_started" not in stages:
    stages["1_started"] = {"status": "completed", "type": category}

stage_5 = stages.get("5_extraction_en", {})
if keys_added > 0:
    stage_5["keys_added"] = max(keys_added, stage_5.get("keys_added", 0))
if stage_5:
    stage_5.setdefault("status", "completed")
    stages["5_extraction_en"] = stage_5

stages["8_sync"] = {"status": "completed"}

file_info["stages"] = stages
file_info["overall_status"] = "completed"
file_info["completed_at"] = datetime.now().isoformat()
file_info.setdefault("category", category)
status["files"][file_path] = file_info

status["global_stats"]["files_completed"] = len([
    f for f, info in status["files"].items() 
    if info.get("overall_status") == "completed"
])

tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)
PYMARK
    local rc=$?
    status_lock_release
    return $rc
}

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# NAPRAWIONE: Log do stderr żeby nie mieszać z return values w subshell
log() { printf '%b\n' "$1" >&2; }

#===============================================================================
# VALIDATION HELPERS
#===============================================================================
restore_backup_file() {
    local file="$1"
    local type="other"
    [[ "$file" == *"/npc/"* ]] && type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    local backup="$BACKUP_DIR/$type/$(basename "$file").bak"
    [ -f "$backup" ] && cp "$backup" "$file"
}

validate_lua_file() {
    local file="$1"
    if command -v luac >/dev/null 2>&1; then
        luac -p "$file" >/dev/null 2>&1
        return $?
    fi
    if command -v lua >/dev/null 2>&1; then
        # Fallback: loadfile bez wykonywania
        lua -e "local f = loadfile('$file'); if not f then os.exit(1) end" >/dev/null 2>&1
        return $?
    fi
    # Brak lua/luac w PATH – nie blokuj
    return 0
}

# Smoke-test: próba załadowania pliku Lua (bardziej rygorystyczny test)
smoke_test_lua() {
    local file="$1"
    if command -v lua >/dev/null 2>&1; then
        # Użyj dofile w trybie "dry-run" - tylko parsowanie bez wykonywania
        lua -e "local f = loadfile('$file'); if not f then os.exit(1) end" 2>/dev/null
        return $?
    fi
    return 0
}


#===============================================================================
# UPDATE_CATEGORY_STATE - Zapamiętaj wynik przetwarzania kategorii
#===============================================================================
update_category_state() {
    local CATEGORY="$1"
    local PROCESSED_COUNT="$2"
    
    if ! category_lock_acquire; then
        return 1
    fi
    python3 - "$CATEGORY" "$PROCESSED_COUNT" << 'CATSTATEPY'
import json
import os
import shutil
import sys
import time

CATEGORY_STATE_FILE = ".i18n_category_state.json"
CATEGORY = sys.argv[1] if len(sys.argv) > 1 else ""
try:
    PROCESSED_COUNT = int(sys.argv[2])
except Exception:
    PROCESSED_COUNT = 0

# Progresywne czasy skip (w sekundach)
SKIP_TIMES = [300, 600, 1800, 3600, 7200]  # 5min, 10min, 30min, 1h, 2h

# Wczytaj obecny stan
try:
    with open(CATEGORY_STATE_FILE, 'r') as f:
        state = json.load(f)
except:
    state = {"skip_until": {}, "last_processed": {}, "consecutive_zeros": {}, "total_processed": {}}

# Upewnij się że wszystkie klucze istnieją
for key in ["skip_until", "last_processed", "consecutive_zeros", "total_processed"]:
    if key not in state:
        state[key] = {}

# Pobierz poprzednie wartości
prev_zeros = state["consecutive_zeros"].get(CATEGORY, 0)
prev_total = state["total_processed"].get(CATEGORY, 0)

# Zapisz wynik
state["last_processed"][CATEGORY] = {
    "count": PROCESSED_COUNT,
    "timestamp": time.time()
}

if PROCESSED_COUNT == 0:
    # Zwiększ licznik consecutive zeros
    state["consecutive_zeros"][CATEGORY] = prev_zeros + 1
    zeros = state["consecutive_zeros"][CATEGORY]
    
    # Progresywny backoff - im więcej zer, tym dłuższy skip
    skip_index = min(zeros - 1, len(SKIP_TIMES) - 1)
    skip_time = SKIP_TIMES[skip_index]
    state["skip_until"][CATEGORY] = time.time() + skip_time
    
    skip_min = skip_time // 60
    print(f"⏭️ Kategoria '{CATEGORY}' pominięta na {skip_min} min (0 przetworzonych, seria: {zeros}x)")
else:
    # Reset consecutive zeros przy sukcesie
    state["consecutive_zeros"][CATEGORY] = 0
    state["total_processed"][CATEGORY] = prev_total + PROCESSED_COUNT
    # Wyczyść skip
    state["skip_until"].pop(CATEGORY, None)
    print(f"✅ Kategoria '{CATEGORY}': +{PROCESSED_COUNT} (total: {prev_total + PROCESSED_COUNT})")

# Zapisz stan
tmp_file = CATEGORY_STATE_FILE + ".tmp"
if os.path.exists(CATEGORY_STATE_FILE):
    try:
        shutil.copy2(CATEGORY_STATE_FILE, CATEGORY_STATE_FILE + ".bak")
    except Exception:
        pass
with open(tmp_file, 'w') as f:
    json.dump(state, f, indent=2)
os.replace(tmp_file, CATEGORY_STATE_FILE)
CATSTATEPY
    local rc=$?
    category_lock_release
    return $rc
}

#===============================================================================
# RUN_WITH_MINI_BATCH - Wrapper do przetwarzania z mini-batch i pauzami
#===============================================================================
# Użycie: run_with_mini_batch <category_name> <process_function> <total_batch>
# Przykład: run_with_mini_batch "items" "process_items_category" 50
#===============================================================================
run_with_mini_batch() {
    local category="$1"
    local process_func="$2"
    local total_batch="${3:-$MIGRATION_BATCH}"
    local mini_batch="${MINI_BATCH:-10}"
    local mini_pause="${MINI_PAUSE:-3}"
    
    local processed=0
    local mini_count=0
    local total_added=0
    
    # NAPRAWIONE: Logi do stderr (>&2) żeby nie mieszać z return value
    echo "📦 Mini-batch mode: $total_batch total, $mini_batch per batch, ${mini_pause}s pause" >&2

    # LIVE snapshot dla mini-batch (ogarnia wszystkie kategorie korzystające z wrappera)
    status_update_activity "running" "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch_start" "$category" "-" "mini-batch" 0 "$total_batch" "items" 0
    
    while [ $processed -lt $total_batch ]; do
        local current_mini=$mini_batch
        [ $((processed + mini_batch)) -gt $total_batch ] && current_mini=$((total_batch - processed))

        status_update_activity "running" "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch" "$category" "-" "batch $((mini_count + 1)) size=$current_mini" "$processed" "$total_batch" "items" 0
        
        # Zlicz klucze przed
        local keys_before=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
        
        # Wywołaj funkcję przetwarzania (przekieruj jej output do stderr)
        # UWAGA: process_generic_category ma inny podpis: (category, batch)
        if [ "$process_func" = "process_generic_category" ]; then
            if $process_func "$category" "$current_mini" >&2; then
                :
            else
                local rc=$?
                echo "   ❌ Mini-batch: $process_func failed (rc=$rc)" >&2
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch" "$category" "-" "mini-batch failed rc=$rc" "func=$process_func"
                break
            fi
        else
            if $process_func "$current_mini" >&2; then
                :
            else
                local rc=$?
                echo "   ❌ Mini-batch: $process_func failed (rc=$rc)" >&2
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch" "$category" "-" "mini-batch failed rc=$rc" "func=$process_func"
                break
            fi
        fi
        
        # Zlicz klucze po
        local keys_after=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
        
        local added=$((keys_after - keys_before))
        [ "$added" -lt 0 ] && added=0
        total_added=$((total_added + added))
        processed=$((processed + current_mini))
        mini_count=$((mini_count + 1))
        
        echo "   📦 Mini-batch #$mini_count: +$added kluczy (suma: $total_added)" >&2

        status_log_op "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch_done" "$category" "-" "ok" "mini_batch=$mini_count processed=$processed/$total_batch" "$added" ""
        status_update_activity "running" "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch_done" "$category" "-" "+$added keys" "$processed" "$total_batch" "items" 0
        
        # Pauza między mini-batch (ale nie po ostatnim i nie gdy nic nie dodano)
        if [ $processed -lt $total_batch ] && [ "$added" -gt 0 ]; then
            echo "   ⏳ Pauza ${mini_pause}s..." >&2
            sleep $mini_pause
        fi
        
        # Jeśli nie dodano nic, przerwij wcześniej
        if [ "$added" -eq 0 ]; then
            echo "   ⚠️ Brak nowych danych, kończę wcześniej" >&2
            status_log_op "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch_stop" "$category" "-" "ok" "no new data" "0" ""
            break
        fi
    done
    
    echo "✅ Zakończono: +$total_added kluczy w $mini_count mini-batch" >&2

    status_update_activity "running" "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "mini_batch_end" "$category" "-" "done" "$processed" "$total_batch" "items" 0
    
    # Zwróć TYLKO liczbę dodanych kluczy (do stdout)
    echo "$total_added"
}

#===============================================================================
# UPDATE_STATUS - Aktualizacja I18N_STATUS.md dla GitHub (pełna wersja)
#===============================================================================
update_github_status() {
    log "${CYAN}📊 Aktualizuję I18N_STATUS.md...${NC}"

    # Utrzymuj kanoniczne źródła statusu (JSON) w i18n/status/.
    # - daily/YYYY-MM-DD.json: "co zrobił dziś"
    # - worker_state.json: trwały stan (schema 3.0)
    python3 tools/i18n_status.py --status-dir "$STATUS_DIR" build-daily >/dev/null 2>&1 || true
    python3 tools/i18n_status.py --status-dir "$STATUS_DIR" build-worker-state --repo-root "$WORK_DIR" >/dev/null 2>&1 || true
    
    python3 << 'STATUSPY'
import json
import os
import subprocess
from datetime import datetime, timezone

WORK_DIR = os.getcwd()
STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"
PROCESSED_FILE = "i18n_processed_files.txt"
EXCLUDED_FILE = "i18n_excluded_files.txt"

# Git root - tam gdzie jest .git (dla pushowania I18N_STATUS.md)
def _detect_git_root(work_dir: str) -> str:
    try:
        out = subprocess.check_output(
            ["git", "-C", work_dir, "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return out or work_dir
    except Exception:
        return work_dir

GIT_ROOT = _detect_git_root(WORK_DIR)

# Wczytaj status workera
try:
    with open(STATUS_FILE) as f:
        data = json.load(f)
except:
    data = {"files": {}}

files = data.get("files", {})
completed = len([f for f, info in files.items() if info.get("overall_status") == "completed"])
in_progress = len([f for f, info in files.items() if info.get("overall_status") == "in_progress"])

# Zlicz klucze per kategoria
def count_keys(filename):
    filepath = f"{I18N_DIR}/en/{filename}"
    if os.path.exists(filepath):
        try:
            with open(filepath) as f:
                return len(json.load(f))
        except:
            pass
    return 0

# ============ DYNAMICZNE SKANOWANIE WSZYSTKICH KATEGORII JSON ============
all_json_categories = {}
if os.path.isdir(f"{I18N_DIR}/en"):
    for jf in sorted(os.listdir(f"{I18N_DIR}/en")):
        if jf.endswith(".json"):
            cat_name = jf.replace(".json", "")
            all_json_categories[cat_name] = count_keys(jf)

# ============ INTEGRACJA ZE STANEM WORKERA ============
worker_state = {"skip_until": {}, "last_processed": {}, "consecutive_zeros": {}, "total_processed": {}}
try:
    with open(".i18n_category_state.json") as f:
        worker_state = json.load(f)
except:
    pass

# Pobierz aktualną kategorię (ostatnio przetwarzaną)
current_category = "items"  # default
last_activity_time = 0
for cat, info in worker_state.get("last_processed", {}).items():
    if isinstance(info, dict) and info.get("timestamp", 0) > last_activity_time:
        last_activity_time = info.get("timestamp", 0)
        current_category = cat

# Pobierz ostatnie operacje ze wszystkich kategorii
recent_operations = []
for cat, info in worker_state.get("last_processed", {}).items():
    if isinstance(info, dict):
        ts = info.get("timestamp", 0)
        count = info.get("count", 0)
        if ts > 0:
            from datetime import datetime
            time_str = datetime.fromtimestamp(ts).strftime("%H:%M:%S")
            recent_operations.append({
                "category": cat,
                "count": count,
                "timestamp": ts,
                "time_str": time_str,
                "type": "migration"
            })

# Pobierz operacje z translation_sync
translation_sync_data = worker_state.get("translation_sync", {})
sync_last_ts = translation_sync_data.get("last_sync", 0)
sync_current_lang = translation_sync_data.get("current_lang", "")
sync_current_cat = translation_sync_data.get("current_category", "")
sync_stats = translation_sync_data.get("stats", {})
sync_langs_done = translation_sync_data.get("languages_done", [])

if sync_last_ts > 0 and sync_current_lang:
    from datetime import datetime
    sync_time_str = datetime.fromtimestamp(sync_last_ts).strftime("%H:%M:%S")
    lang_total = sync_stats.get(sync_current_lang, {}).get("total", 0)
    recent_operations.append({
        "category": f"{sync_current_lang.upper()}/{sync_current_cat}",
        "count": lang_total,
        "timestamp": sync_last_ts,
        "time_str": sync_time_str,
        "type": "translation_sync"
    })

recent_operations.sort(key=lambda x: -x["timestamp"])

# Oblicz total processed ze wszystkich kategorii
total_files_processed = sum(worker_state.get("total_processed", {}).values())

# Wszystkie kategorie (stare + nowe) - dla kompatybilności
game_keys = count_keys("game.json")
items_keys = count_keys("items.json")
misc_keys = count_keys("misc.json")
monsters_keys = count_keys("monsters.json")
npc_keys = count_keys("npc.json")
player_keys = count_keys("player.json")
quests_keys = count_keys("quests.json")
scripts_keys = count_keys("scripts.json")
server_keys = count_keys("server.json")
spells_keys = count_keys("spells.json")
system_keys = count_keys("system.json")
ui_keys = count_keys("ui.json")

# NOWE KATEGORIE (dodane 2025-12-10)
startup_keys = count_keys("startup.json")
raids_keys = count_keys("raids.json")
world_keys = count_keys("world.json")
libs_keys = count_keys("libs.json")
events_keys = count_keys("events.json")
chatchannels_keys = count_keys("chatchannels.json")
modules_keys = count_keys("modules.json")
npclib_keys = count_keys("npclib.json")
actions_keys = count_keys("actions.json")
errors_keys = count_keys("errors.json")
messages_keys = count_keys("messages.json")

# KATEGORIE ZEWNĘTRZNE (Website/Client - dodane 2025-12-10)
php_keys = count_keys("php.json")
cpp_keys = count_keys("cpp.json")
html_keys = count_keys("html.json")
client_keys = count_keys("client.json")

# KATEGORIE OTCLIENT/TESTYY (dodane 2025-01-XX)
otclient_modules_keys = count_keys("otclient_modules.json")
otclient_data_keys = count_keys("otclient_data.json")
otclient_src_keys = count_keys("otclient_src.json")
otclient_mods_keys = count_keys("otclient_mods.json")
otclient_tools_keys = count_keys("otclient_tools.json")

# Zakres pracy (spójny z dispatcherem): domyślnie pełny (serwer + instalka), bez website
SCOPE = (os.environ.get("I18N_SCOPE", "full") or "full").strip().lower()
if SCOPE in ("server", "canary", "server_only", "server-only"):
    php_keys = 0
    html_keys = 0
    client_keys = 0
    otclient_modules_keys = 0
    otclient_data_keys = 0
    otclient_src_keys = 0
    otclient_mods_keys = 0
    otclient_tools_keys = 0

total_keys = (game_keys + items_keys + misc_keys + monsters_keys + npc_keys + 
              player_keys + quests_keys + scripts_keys + server_keys + spells_keys + 
              system_keys + ui_keys + startup_keys + raids_keys + world_keys + 
              libs_keys + events_keys + chatchannels_keys + modules_keys + npclib_keys +
              actions_keys + errors_keys + messages_keys +
              php_keys + cpp_keys + html_keys + client_keys +
              otclient_modules_keys + otclient_data_keys + otclient_src_keys + 
              otclient_mods_keys + otclient_tools_keys)

# Zlicz języki (foldery w i18n/; pomijamy foldery techniczne typu i18n/status)
def _list_language_dirs(i18n_dir: str):
    if not os.path.isdir(i18n_dir):
        return []
    langs = []
    for name in os.listdir(i18n_dir):
        if name.startswith('.'):
            continue
        if name in ("status",):
            continue
        path = os.path.join(i18n_dir, name)
        if os.path.isdir(path):
            langs.append(name)
    return sorted(langs)

ALL_LANGUAGES = _list_language_dirs(I18N_DIR)
langs_count = len(ALL_LANGUAGES)

langs_with_data = []
for lang in ALL_LANGUAGES:
    lang_path = f"{I18N_DIR}/{lang}"
    try:
        for jf in os.listdir(lang_path):
            if jf.endswith(".json"):
                try:
                    with open(f"{lang_path}/{jf}") as f:
                        if len(json.load(f)) > 0:
                            langs_with_data.append(lang)
                            raise StopIteration
                except StopIteration:
                    raise
                except Exception:
                    pass
    except StopIteration:
        pass
    except Exception:
        pass

# Zlicz pliki NPC
npc_dir = "data-otservbr-global/npc"
total_npc = 0
needs_migration_npc = 0
migrated_npc = 0
if os.path.isdir(npc_dir):
    for f in os.listdir(npc_dir):
        if f.endswith(".lua"):
            total_npc += 1
            fpath = f"{npc_dir}/{f}"
            try:
                with open(fpath) as fp:
                    content = fp.read()
                    has_i18n = "i18nKey" in content
                    has_npc_lib = "NPC_LIB.i18n.npcSay" in content
                    needs = False
                    # 1. StdModule.say z text = "..." bez i18nKey
                    if "StdModule.say" in content and "text" in content and not has_i18n:
                        needs = True
                    # 2. npcHandler:say( z literalnym stringiem bez NPC_LIB
                    import re
                    if re.search(r'npcHandler:say\s*\(\s*["\']', content) and not has_npc_lib:
                        needs = True
                    # 3. NpcHandler:say( z literalnym stringiem bez NPC_LIB
                    if re.search(r'NpcHandler:say\s*\(\s*["\']', content) and not has_npc_lib:
                        needs = True
                    # 4. npcConfig.voices z text = "..." bez i18nKey
                    if "npcConfig.voices" in content and 'text = "' in content and not has_i18n:
                        needs = True
                    if needs:
                        needs_migration_npc += 1
                    elif has_i18n or has_npc_lib:
                        migrated_npc += 1
            except:
                pass

# Processed & excluded files count (z i18n_file_status.json, NIE ze starych plików!)
processed_count = completed  # Używamy completed z JSON
excluded_count = 0  # Już nie używamy starego systemu wykluczeń

# Policz faktycznie wykluczone (bez StdModule.say lub już zmigrowane)
excluded_count = 0
for f in os.listdir("data-otservbr-global/npc"):
    if f.endswith(".lua"):
        fpath = f"data-otservbr-global/npc/{f}"
        if fpath not in files:  # Nie w statusie
            try:
                with open(fpath) as nf:
                    content = nf.read()
                    if "StdModule.say" not in content:
                        excluded_count += 1  # Nie ma StdModule.say
            except:
                pass

# Cykl - pobierz z i18n_global_stats.json lub status file
cycle_count = 1
try:
    with open("i18n_global_stats.json") as f:
        gs = json.load(f)
        cycle_count = gs.get("total_cycles", 1)
except:
    try:
        with open("i18n_worker_state.json") as f:
            ws = json.load(f)
            cycle_count = ws.get("cycle", 1)
    except:
        pass

# ============ NOWE STATYSTYKI DLA ROZBUDOWANEGO GLOBALNY POSTĘP ============

# 1. WSZYSTKIE PLIKI W PROJEKCIE - PEŁNY SKAN
all_project_files = 0
files_by_type = {}
scannable_extensions = ['.lua', '.xml', '.php', '.html', '.js', '.cpp', '.hpp', '.h', '.py', '.json', '.ts', '.css']

for root, dirs, flist in os.walk('.'):
    # Pomijaj foldery które nie są częścią projektu
    dirs[:] = [d for d in dirs if d not in ['vcpkg', 'build', '.git', 'node_modules', 'html_copy', 'oryginall', '__pycache__', 'large_files_zip']]
    for fname in flist:
        all_project_files += 1
        ext = os.path.splitext(fname)[1].lower()
        if ext:
            files_by_type[ext] = files_by_type.get(ext, 0) + 1

# 2. PLIKI DO SKANOWANIA (wszystkie z kodem/tekstami)
scannable_files = sum(files_by_type.get(ext, 0) for ext in scannable_extensions)

# Szczegóły per typ
lua_files = files_by_type.get('.lua', 0)
xml_files = files_by_type.get('.xml', 0)
php_files = files_by_type.get('.php', 0)
html_files = files_by_type.get('.html', 0)
js_files = files_by_type.get('.js', 0)
cpp_files = files_by_type.get('.cpp', 0) + files_by_type.get('.hpp', 0) + files_by_type.get('.h', 0)
json_files_count = files_by_type.get('.json', 0)

# 3. PRZESKANOWANE (z processed_files.txt)
scanned_files = 0
try:
    with open(PROCESSED_FILE) as pf:
        scanned_files = len([l for l in pf if l.strip()])
except:
    pass

# 4. ANALIZA STATUSÓW PLIKÓW
files_migrated = 0       # Mają klucze i18n
files_needs_migration = 0  # Trzeba dodać i18n
files_clean = 0          # Czyste (bez tekstów do tłumaczenia)
files_in_progress = 0    # W trakcie przetwarzania
total_keys_extracted = 0

for fpath, info in files.items():
    status = info.get('overall_status', '')
    stages = info.get('stages', {})
    
    if status == 'in_progress':
        files_in_progress += 1
    elif status == 'completed':
        extraction = stages.get('5_extraction_en', {})
        keys = extraction.get('keys_added', 0)
        if keys > 0:
            files_migrated += 1
            total_keys_extracted += keys
        else:
            # Sprawdź czy plik miał teksty do migracji
            analysis = stages.get('2_analysis', {})
            if analysis.get('needs_migration', False):
                files_needs_migration += 1
            else:
                files_clean += 1

# 5. DO ZROBIENIA
files_not_scanned = scannable_files - scanned_files
files_to_migrate = files_needs_migration

# 6. JĘZYKI - szczegółowa analiza
translated_langs = 0
prepared_langs = 0
langs_with_real_translations = []
langs_with_placeholders_only = []

for lang_dir in os.listdir(I18N_DIR):
    lang_path = os.path.join(I18N_DIR, lang_dir)
    if not os.path.isdir(lang_path) or lang_dir == 'en':
        continue
    
    has_json = False
    has_real_translations = False
    total_keys_in_lang = 0
    translated_keys_in_lang = 0
    
    for jf in os.listdir(lang_path):
        if jf.endswith('.json'):
            has_json = True
            try:
                with open(os.path.join(lang_path, jf)) as f:
                    data = json.load(f)
                    total_keys_in_lang += len(data)
                    for v in data.values():
                        if isinstance(v, str) and not v.startswith('[EN]') and v.strip():
                            translated_keys_in_lang += 1
                            has_real_translations = True
            except:
                pass
    
    if has_json:
        prepared_langs += 1
        if has_real_translations:
            translated_langs += 1
            langs_with_real_translations.append(lang_dir)
        else:
            langs_with_placeholders_only.append(lang_dir)

# 7. PROCENTY
scanned_pct = round(scanned_files / scannable_files * 100, 1) if scannable_files > 0 else 0
migrated_pct = round(files_migrated / scanned_files * 100, 1) if scanned_files > 0 else 0
translated_pct = round(translated_langs / langs_count * 100, 1) if langs_count > 0 else 0

# Ostatnio ukończone NPC
recent_completed = []
sorted_files = sorted(
    [(f, info.get("completed_at", "")) for f, info in files.items() if info.get("overall_status") == "completed"],
    key=lambda x: x[1],
    reverse=True
)[:10]
for fpath, completed_at in sorted_files:
    fname = os.path.basename(fpath).replace(".lua", "")
    time_str = completed_at[:16].replace("T", " ") if completed_at else "?"
    recent_completed.append(f"- ✅ `{fname}` - ukończono {time_str}")

# Cele dla kategorii (zaktualizowane 2025-12-10)
# AUTO-ADJUST: jeśli current > target, cel wzrasta automatycznie
TARGETS = {
    "game": 100, "items": 40000, "misc": 100, "monsters": 5000,
    "npc": 15000, "player": 200, "quests": 500, "scripts": 1000,
    "server": 300, "spells": 200, "system": 2000, "ui": 200,
    "php": 3000, "cpp": 500, "html": 500, "client": 200,
    # OTClient/Testyy kategorie
    "otclient_modules": 500, "otclient_data": 200, "otclient_src": 300,
    "otclient_mods": 100, "otclient_tools": 50
}

# Auto-adjust targets na podstawie aktualnych wartości
def auto_adjust_target(current, base_target):
    """Zwiększ cel jeśli przekroczono, zaokrąglij do ładnej liczby"""
    if current <= base_target:
        return base_target
    # Zaokrąglij w górę do najbliższej "ładnej" liczby
    if current < 1000:
        return ((current // 100) + 1) * 100  # np. 550 -> 600
    elif current < 10000:
        return ((current // 500) + 1) * 500  # np. 5699 -> 6000
    else:
        return ((current // 1000) + 1) * 1000  # np. 15500 -> 16000

# Aktualizuj TARGETS na podstawie aktualnych danych
category_current = {
    "items": items_keys, "monsters": monsters_keys, "npc": npc_keys,
    "scripts": scripts_keys, "spells": spells_keys, "server": server_keys,
    "system": system_keys, "ui": ui_keys, "php": php_keys, "cpp": cpp_keys,
    "html": html_keys, "client": client_keys
}
for cat, cur in category_current.items():
    if cat in TARGETS:
        TARGETS[cat] = auto_adjust_target(cur, TARGETS[cat])

def progress_bar(current, target, width=20):
    if target == 0:
        return "░" * width
    pct = min(current / target, 1.0)
    filled = int(pct * width)
    return "█" * filled + "░" * (width - filled)

def status_icon(current, target):
    if target == 0:
        return "⏳"
    pct = current / target
    if pct >= 0.9:
        return "✅"
    elif pct > 0:
        return "🔄"
    return "⏳"

# Generuj timestamp
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Pre-compute roadmap values for table
roadmap_items = f"| 🎒 Items | {items_keys} | {progress_bar(items_keys, TARGETS['items'])} | {TARGETS['items']} | {status_icon(items_keys, TARGETS['items'])} {round(items_keys/TARGETS['items']*100) if TARGETS['items'] else 0}% |"
roadmap_npc = f"| 🧙 NPC | {npc_keys} | {progress_bar(npc_keys, TARGETS['npc'])} | {TARGETS['npc']} | {status_icon(npc_keys, TARGETS['npc'])} {round(npc_keys/TARGETS['npc']*100) if TARGETS['npc'] else 0}% |"
roadmap_scripts = f"| 📜 Scripts | {scripts_keys} | {progress_bar(scripts_keys, TARGETS['scripts'])} | {TARGETS['scripts']} | {status_icon(scripts_keys, TARGETS['scripts'])} {round(scripts_keys/TARGETS['scripts']*100) if TARGETS['scripts'] else 0}% |"
roadmap_monsters = f"| 👹 Monsters | {monsters_keys} | {progress_bar(monsters_keys, TARGETS['monsters'])} | {TARGETS['monsters']} | {status_icon(monsters_keys, TARGETS['monsters'])} {round(monsters_keys/TARGETS['monsters']*100) if TARGETS['monsters'] else 0}% |"
roadmap_spells = f"| ✨ Spells | {spells_keys} | {progress_bar(spells_keys, TARGETS['spells'])} | {TARGETS['spells']} | {status_icon(spells_keys, TARGETS['spells'])} {round(spells_keys/TARGETS['spells']*100) if TARGETS['spells'] else 0}% |"
roadmap_server = f"| ⚙️ Server | {server_keys} | {progress_bar(server_keys, TARGETS['server'])} | {TARGETS['server']} | {status_icon(server_keys, TARGETS['server'])} {round(server_keys/TARGETS['server']*100) if TARGETS['server'] else 0}% |"
roadmap_system = f"| 🖥️ System | {system_keys} | {progress_bar(system_keys, TARGETS['system'])} | {TARGETS['system']} | {status_icon(system_keys, TARGETS['system'])} {round(system_keys/TARGETS['system']*100) if TARGETS['system'] else 0}% |"
roadmap_ui = f"| 🎨 UI | {ui_keys} | {progress_bar(ui_keys, TARGETS['ui'])} | {TARGETS['ui']} | {status_icon(ui_keys, TARGETS['ui'])} {round(ui_keys/TARGETS['ui']*100) if TARGETS['ui'] else 0}% |"

# Debug targets (łatwiej znaleźć rozjazdy auto-adjust)
targets_comment = f"<!-- TARGETS {TARGETS} -->"

# AUTO tłumaczenia - statystyki TM
try:
    with open(f"{I18N_DIR}/translation_memory.json") as f:
        tm_data = json.load(f)
except:
    tm_data = {}

# Języki do podglądu auto (TM lub kluczowe)
auto_langs = sorted(set(list(tm_data.keys()) + ["pl","de","es","pt","ru","fr","tr","it","sv","ro","tr"]))
auto_rows = []
for _lang in auto_langs:
    tm_count = len(tm_data.get(_lang, {})) if isinstance(tm_data.get(_lang, {}), dict) else 0
    status_auto = "✅ TM" if tm_count > 0 else "⚠️ placeholdery (brak TM)"
    auto_rows.append(f"| {_lang.upper()} | {tm_count} | {status_auto} |")
auto_table = chr(10).join(auto_rows)

# ============ WCZYTAJ ROZSZERZONE DANE Z i18n_global_stats.json ============
global_stats = {}
try:
    with open("i18n_global_stats.json") as f:
        global_stats = json.load(f)
except:
    pass

# ============ NOWY KANONICZNY LIVE STATUS (i18n/status/activity.json) ==========
status_dir = os.path.join(I18N_DIR, "status")
activity_path = os.path.join(status_dir, "activity.json")
worker_state_path = os.path.join(status_dir, "worker_state.json")
activity = {}
activity_present = False
worker_state = {}
worker_state_present = False
try:
    if os.path.exists(activity_path):
        with open(activity_path) as f:
            activity = json.load(f)
        if isinstance(activity, dict) and activity.get("phase"):
            activity_present = True
    if os.path.exists(worker_state_path):
        with open(worker_state_path) as f:
            worker_state = json.load(f)
        if isinstance(worker_state, dict) and worker_state.get("worker"):
            worker_state_present = True
except:
    activity_present = False

def _parse_iso_z(s: str):
    try:
        if isinstance(s, str) and s.endswith('Z'):
            s = s[:-1] + '+00:00'
        return datetime.fromisoformat(s)
    except Exception:
        return None

def _heartbeat_age_seconds(iso: str) -> int:
    dt = _parse_iso_z(iso)
    if not dt:
        return 0
    try:
        now = datetime.now(timezone.utc)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return max(0, int((now - dt).total_seconds()))
    except Exception:
        return 0

# ============ DAILY SUMMARY (i18n/status/daily/YYYY-MM-DD.json) ==========
daily_section = ""
try:
    today_utc = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    daily_path = os.path.join(status_dir, "daily", f"{today_utc}.json")
    if os.path.exists(daily_path):
        with open(daily_path) as f:
            daily = json.load(f)

        work = daily.get("work", {}) if isinstance(daily.get("work", {}), dict) else {}
        mig = work.get("migration", {}) if isinstance(work.get("migration", {}), dict) else {}
        errs = daily.get("errors", {}) if isinstance(daily.get("errors", {}), dict) else {}

        mig_keys = int(mig.get("keys_added", 0) or 0)
        mig_files = int(mig.get("files_changed", 0) or 0)
        mig_cats = mig.get("categories_touched", []) if isinstance(mig.get("categories_touched", []), list) else []
        cycles = int(daily.get("cycles", 0) or 0)
        err_count = int(errs.get("count", 0) or 0)

        cats_preview = ", ".join([str(c) for c in mig_cats[:10]])
        if len(mig_cats) > 10:
            cats_preview += "..."

        daily_section = f"""

## 📅 Dziś (UTC)

- Cykle: **{cycles}**
- MIGRATION: **+{mig_keys}** kluczy, **{mig_files}** plików `.lua`
- Kategorie dotknięte: {cats_preview if cats_preview else '-'}
- Błędy: **{err_count}**
"""
except:
    daily_section = ""

last_mode = global_stats.get("mode", "MIGRATION")
last_category = global_stats.get("category", "npc")

# Preferuj kanoniczny worker_state.json (trwały stan) jeśli istnieje.
if worker_state_present:
    try:
        _cur = (worker_state.get("worker", {}) or {}).get("current", {}) or {}
        last_mode = _cur.get("phase") or last_mode
        last_category = _cur.get("category") or last_category
        cycle_count = int((worker_state.get("worker", {}) or {}).get("cycle", cycle_count) or cycle_count)
    except Exception:
        pass

# Jeśli mamy activity.json, traktuj to jako źródło prawdy dla LIVE.
if activity_present:
    last_mode = (activity.get("phase") or last_mode)
    last_category = (activity.get("category") or last_category)
    try:
        cycle_count = int(activity.get("cycle", cycle_count) or cycle_count)
    except Exception:
        pass

# Heartbeat/stale: preferuj activity.generated_at_utc, potem worker_state.worker.heartbeat_at_utc.
heartbeat_iso = None
if activity_present:
    heartbeat_iso = activity.get("generated_at_utc")
if not heartbeat_iso and worker_state_present:
    heartbeat_iso = (worker_state.get("worker", {}) or {}).get("heartbeat_at_utc")

heartbeat_age = _heartbeat_age_seconds(heartbeat_iso) if heartbeat_iso else 0
stale_threshold_seconds = 120
is_stale = bool(heartbeat_iso) and heartbeat_age >= stale_threshold_seconds

# Dane specyficzne dla trybu
migration_data = global_stats.get("migration", {})
translation_sync_data_gs = global_stats.get("translation_sync", {})
auto_translate_data = global_stats.get("auto_translate", {})
idle_data = global_stats.get("idle", {})

# ============ GENERUJ LIVE DISPLAY W ZALEŻNOŚCI OD TRYBU ============
def fit(text: str, width: int = 61) -> str:
    text = str(text)
    if len(text) > width:
        text = "…" + text[-(width - 1):]
    return text.ljust(width)

def line(text: str) -> str:
    return f"│ {fit(text)} │"

if activity_present:
    phase = str(activity.get("phase") or "?").upper()
    stage = str(activity.get("stage") or "-")
    category = str(activity.get("category") or "-")
    file_path = str(activity.get("file") or "-")
    msg = str(activity.get("message") or "")
    prog = activity.get("progress", {}) if isinstance(activity.get("progress", {}), dict) else {}
    done = int(prog.get("done", 0) or 0)
    total = int(prog.get("total", 0) or 0)
    unit = str(prog.get("unit") or "units")
    status_txt = str(activity.get("status") or "running")

    icon = {
        "MIGRATION": "🔧",
        "TRANSLATION_SYNC": "🌍",
        "AUTO_TRANSLATE": "🤖",
        "COMPACT_KEYS": "🔑",
        "VALIDATION": "🧪",
        "IDLE": "✅",
    }.get(phase, "🔴")

    mode_display = f"{icon} {phase} ({stage})"
    category_display = f"📁 {category.upper()}" if category and category != "-" else "-"

    live_details = "\n".join(
        [
            line(f"Status: {status_txt}"),
            line(f"Plik: {file_path}"),
            line(f"Postęp: {done}/{total} {unit}"),
            line(f"Info: {msg}"),
        ]
    )

    summary_phase = phase
    summary_stage = stage
    summary_category = category
    summary_file = file_path
    summary_eta = int(activity.get("eta_seconds") or 0) if str(activity.get("eta_seconds") or "").isdigit() else activity.get("eta_seconds")

elif last_mode == "MIGRATION":
    mode_display = "🔧 MIGRATION (skanowanie plików)"
    category_display = f"📁 {last_category.upper()}"
    
    # Statystyki migracji - RZECZYWISTE DANE z plików JSON
    # Klucze z i18n/en/*.json (faktyczne klucze), pliki z file_status
    files_scanned = len([f for f, info in json.load(open(STATUS_FILE)).get("files", {}).items() 
                        if info.get("overall_status") == "completed"]) if os.path.exists(STATUS_FILE) else 0
    
    # Klucze per kategoria - z tego co pokazujemy w tabelach
    category_keys = {
        "npc": npc_keys,
        "scripts": scripts_keys,
        "monsters": monsters_keys,
        "items": items_keys,
        "spells": spells_keys
    }
    current_cat_keys = category_keys.get(last_category.lower(), 0)
    
    live_details = f"""│ 📊 Pliki przeskanowane: {files_scanned:>6} (wszystkie kategorie)          │
│    ├─ Kategoria {last_category.upper():>6}: {current_cat_keys:>6} kluczy EN                    │
│    └─ Total kluczy EN: {total_keys:>6}                                 │"""

    summary_phase = "MIGRATION"
    summary_stage = "-"
    summary_category = last_category
    summary_file = "-"
    summary_eta = "-"

elif last_mode == "TRANSLATION_SYNC":
    mode_display = "🌍 TRANSLATION_SYNC (synchronizacja)"
    sync_lang = translation_sync_data_gs.get("language", "?")
    sync_file = translation_sync_data_gs.get("json_file", "?")
    sync_keys = translation_sync_data_gs.get("keys_to_sync", 0)
    category_display = f"🌍 {sync_lang.upper()}/{sync_file}"
    
    live_details = f"""│ 📊 Synchronizacja kluczy EN → {sync_lang.upper()}                           │
│    ├─ Plik:           {sync_file:>20}                       │
│    └─ Kluczy do sync: {sync_keys:>6}                                 │"""

    summary_phase = "TRANSLATION_SYNC"
    summary_stage = "-"
    summary_category = f"{sync_lang}/{sync_file}"
    summary_file = "-"
    summary_eta = "-"

elif last_mode == "AUTO_TRANSLATE":
    mode_display = "🤖 AUTO_TRANSLATE (tłumaczenie)"
    at_lang = auto_translate_data.get("language", "?")
    at_file = auto_translate_data.get("json_file", "?")
    at_keys = auto_translate_data.get("keys_to_translate", 0)
    category_display = f"🤖 {at_lang.upper()}/{at_file}"
    
    live_details = f"""│ 📊 Automatyczne tłumaczenie                                       │
│    ├─ Język:          {at_lang.upper():>10}                               │
│    ├─ Plik:           {at_file:>20}                       │
│    └─ Kluczy:         {at_keys:>6}                                 │"""

    summary_phase = "AUTO_TRANSLATE"
    summary_stage = "-"
    summary_category = f"{at_lang}/{at_file}"
    summary_file = "-"
    summary_eta = "-"

elif last_mode == "COMPACT_KEYS":
    mode_display = "🔑 COMPACT_KEYS (keymap + export)"
    category_display = "🔑 keymap/export"

    km_total = 0
    try:
        km_path = os.path.join(I18N_DIR, "keymap.json")
        if os.path.exists(km_path):
            with open(km_path) as f:
                km_total = len(json.load(f))
    except:
        km_total = 0

    missing = (total_keys - km_total) if isinstance(total_keys, int) else 0
    if missing < 0:
        missing = 0

    live_details = f"""│ 📊 Keymap: {km_total:>6}/{total_keys:>6} (brakuje {missing:>6})                  │
│    └─ Użyj: tools/i18n_keymap.py sync/verify + json_to_lua_locales.py │"""

    summary_phase = "COMPACT_KEYS"
    summary_stage = "-"
    summary_category = "keymap"
    summary_file = "-"
    summary_eta = "-"

elif last_mode == "VALIDATION":
    mode_display = "🧪 VALIDATION (quality/validator)"
    category_display = "🧪 quality"

    total_issues = 0
    try:
        qp = os.path.join(I18N_DIR, "quality_report.json")
        if os.path.exists(qp):
            with open(qp) as f:
                total_issues = int((json.load(f) or {}).get("total_issues", 0) or 0)
    except:
        total_issues = 0

    live_details = f"""│ 📊 Quality issues: {total_issues:>6}                                      │
│    └─ Raport: i18n/quality_report.json                               │"""

    summary_phase = "VALIDATION"
    summary_stage = "-"
    summary_category = "quality"
    summary_file = "-"
    summary_eta = "-"

elif last_mode == "IDLE":
    mode_display = "✅ IDLE (oczekiwanie)"
    category_display = "📋 Skanowanie nowych plików"
    
    new_files = idle_data.get("new_files_detected", 0)
    quality_issues = idle_data.get("quality_issues", 0)
    
    live_details = f"""│ 📊 Tryb IDLE - wszystko zrobione                                  │
│    ├─ Nowe pliki:     {new_files:>6} {'(restart!)' if new_files > 0 else '(brak)'}             │
│    └─ Problemy TM:    {quality_issues:>6}                                 │"""

    summary_phase = "IDLE"
    summary_stage = "-"
    summary_category = "idle"
    summary_file = "-"
    summary_eta = "-"

else:
    mode_display = f"❓ {last_mode}"
    category_display = f"📁 {last_category}"
    live_details = "│ 📊 Brak szczegółowych danych                                      │"

    summary_phase = str(last_mode or "?")
    summary_stage = "-"
    summary_category = str(last_category or "-")
    summary_file = "-"
    summary_eta = "-"

# TM coverage (do notki o placeholderach)
try:
    with open(f"{I18N_DIR}/translation_memory.json") as f:
        tm_data = json.load(f)
except:
    tm_data = {}
tm_langs = set(tm_data.keys())
sync_langs = set(sync_stats.keys()) if isinstance(sync_stats, dict) else set()
known_langs = sorted(tm_langs | sync_langs | {"pl", "de", "es", "pt", "ru", "fr", "tr"})
no_tm_langs = [lang for lang in known_langs if lang not in tm_langs]

status_display = ("🟢 RUNNING" if str(last_mode).upper() != "IDLE" else "✅ IDLE")
if is_stale:
    status_display = f"🟠 STALE (heartbeat {heartbeat_age}s temu)"
elif activity_present:
    act_phase = str(activity.get("phase") or "").upper()
    st = str(activity.get("status") or "running").lower()
    if st in ("interrupted", "stopped"):
        status_display = "⛔ INTERRUPTED"
    elif st in ("error", "failed"):
        status_display = "🔴 ERROR"
    elif st in ("idle",) or act_phase == "IDLE":
        status_display = "✅ IDLE"
    else:
        status_display = "🟢 RUNNING"

# Per-cycle ops from i18n/status/ops.jsonl ("W tym cyklu" / historia).
cycle_ops_md = "- Brak operacji"
try:
    ops_path = os.path.join(status_dir, "ops.jsonl")
    ops = []
    if os.path.exists(ops_path):
        with open(ops_path, "r", encoding="utf-8") as f:
            for _line in f:
                _line = _line.strip()
                if not _line:
                    continue
                try:
                    ev = json.loads(_line)
                except Exception:
                    continue
                try:
                    if int(ev.get("cycle", 0) or 0) != int(cycle_count or 0):
                        continue
                except Exception:
                    continue
                ops.append(ev)

    if ops:
        ops = ops[-10:]

        def _icon(phase_name: str) -> str:
            phase_name = str(phase_name or "").upper()
            return {
                "MIGRATION": "🔧",
                "COMPACT_KEYS": "🔑",
                "TRANSLATION_SYNC": "🌍",
                "AUTO_TRANSLATE": "🤖",
                "VALIDATION": "🧪",
                "IDLE": "✅",
            }.get(phase_name, "•")

        lines = []
        def _nice_stage(stg: str) -> str:
            stg = str(stg or "-")
            mapping = {
                "category_done": "zakończono kategorię",
                "mini_batch_done": "mini-batch",
                "mini_batch_stop": "mini-batch stop",
                "migration_start": "start migracji",
                "file": "plik",
                "dispatch": "wybór",
            }
            return mapping.get(stg, stg)

        for ev in reversed(ops):
            ph = ev.get("phase")
            stg = _nice_stage(ev.get("stage"))
            cat = ev.get("category")
            res = ev.get("result")
            detail = ev.get("detail")
            delta = ev.get("delta") if isinstance(ev.get("delta"), dict) else {}

            delta_bits = []
            if "keys_added" in delta:
                delta_bits.append(f"keys+{int(delta.get('keys_added') or 0)}")
            if "files_changed" in delta:
                delta_bits.append(f"files+{int(delta.get('files_changed') or 0)}")
            if "translated" in delta:
                delta_bits.append(f"translated+{int(delta.get('translated') or 0)}")
            if "skipped" in delta:
                delta_bits.append(f"skipped+{int(delta.get('skipped') or 0)}")
            if "mapped_new" in delta:
                delta_bits.append(f"mapped_new+{int(delta.get('mapped_new') or 0)}")

            delta_txt = (" (" + ", ".join(delta_bits) + ")") if delta_bits else ""
            detail_txt = f" — {detail}" if detail else ""
            cat_txt = f"[{cat}]" if cat else ""
            lines.append(f"- {_icon(ph)} {ph}: {stg} {cat_txt} → {res}{delta_txt}{detail_txt}")

        cycle_ops_md = "\n".join(lines)
except Exception:
    cycle_ops_md = "- Brak operacji"

# ==================== GENERUJ PEŁNY I18N_STATUS.md ====================
md = f'''# 🌍 I18N Internationalization System - Live Dashboard

{targets_comment}

> **Aktualizacja:** {timestamp} UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** {langs_count} | **Klucze EN:** {total_keys}  
> **LIVE:** Cykl #{cycle_count} | Status: {status_display} | Faza: {summary_phase} | Etap: {summary_stage} | Kategoria: {summary_category} | Plik: {summary_file} | ETA: {summary_eta} | Heartbeat: {str(heartbeat_iso or '-')}

---

## 🤖 AI Agent Integration

```
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n_file_status.json                              │
│  Worker: i18n_worker_simple.sh                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🕹️ Komendy przez GitHub (sterowanie workerem)

- Edytuj plik: `Tibia/silnik/canary_test/.github/worker_commands.txt`
- Wpisz **jedną** komendę w nowej linii (bez `#`), np.: `FORCE:scripts:ONCE` lub `COMPACT_KEYS:ONCE`
- Worker sam zakomentuje wykonaną komendę i dopisze historię.

---

## 📊 Globalny Postęp

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **{all_project_files:,}** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **{scannable_files:,}** | {round(scannable_files/all_project_files*100, 1)}% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **{scanned_files:,}** | **{scanned_pct}%** | historia workera |
| ⏳ Nie przeskanowane | **{files_not_scanned:,}** | {round(files_not_scanned/scannable_files*100, 1) if scannable_files else 0}% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | {lua_files:,} | NPC, scripts, libs |
| 📄 XML (.xml) | {xml_files:,} | items, monsters, spells |
| 🐘 PHP (.php) | {php_files:,} | backend AAC |
| 🌐 HTML (.html) | {html_files:,} | widoki |
| 📦 JavaScript (.js) | {js_files:,} | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | {cpp_files:,} | silnik serwera |
| 📋 JSON (.json) | {json_files_count:,} | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **{files_migrated}** | {migrated_pct}% | mają klucze i18n |
| 🔄 Wymaga migracji | **{files_needs_migration}** | - | trzeba dodać i18n |
| ⚪ Czyste | **{files_clean}** | - | bez tekstów |
| 🔧 W trakcie | **{files_in_progress}** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **{total_keys:,}** | wszystkie kategorie |
| 📊 NPC | {npc_keys:,} | dialogi NPC |
| 📊 Items | {items_keys:,} | przedmioty |
| 📊 Monsters | {monsters_keys:,} | potwory |
| 📊 HTML | {html_keys:,} | widoki web |
| 📊 Pozostałe | {total_keys - npc_keys - items_keys - monsters_keys - html_keys:,} | scripts, spells, etc. |

### 🌍 Języki i Tłumaczenia
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **{langs_count}** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **{prepared_langs}** | {round(prepared_langs/langs_count*100) if langs_count else 0}% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **{translated_langs}** | **{translated_pct}%** | prawdziwe tłumaczenia |
| ⏳ Do tłumaczenia | **{prepared_langs - translated_langs}** | - | tylko placeholdery |

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#{cycle_count}** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **{total_keys_extracted:,}** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: {len(sync_stats)}/{langs_count}  
- Ostatni sync: {(sync_current_lang.upper() + '/' + sync_current_cat) if sync_current_lang else '-'}

### 🌍 Etap 2: Tłumaczenia (AUTO + TM)
| Język | TM wpisy | Status |
|-------|----------|--------|
{auto_table}

**Języki bez TM (AUTO → placeholdery):** {', '.join(no_tm_langs[:8]) + ('...' if len(no_tm_langs) > 8 else '') if no_tm_langs else 'brak (TM dostępny)'}

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | {status_icon(npc_keys, TARGETS["npc"])} | {npc_keys}/{TARGETS["npc"]} ({round(npc_keys/TARGETS["npc"]*100)}%) | {TARGETS["npc"]} |
| 📜 Lua Scripts | {status_icon(scripts_keys, TARGETS["scripts"])} | {scripts_keys}/{TARGETS["scripts"]} ({round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}%) | {TARGETS["scripts"]} |
| 🎒 Items Database | {status_icon(items_keys, TARGETS["items"])} | {items_keys}/{TARGETS["items"]} ({round(items_keys/TARGETS["items"]*100)}%) | {TARGETS["items"]} |
| 👹 Monsters | {status_icon(monsters_keys, TARGETS["monsters"])} | {monsters_keys}/{TARGETS["monsters"]} ({round(monsters_keys/TARGETS["monsters"]*100)}%) | {TARGETS["monsters"]} |
| ✨ Spells & Magic | {status_icon(spells_keys, TARGETS["spells"])} | {spells_keys}/{TARGETS["spells"]} ({round(spells_keys/TARGETS["spells"]*100)}%) | {TARGETS["spells"]} |
| ⚙️ Server C++ | {status_icon(server_keys, TARGETS["server"])} | {server_keys}/{TARGETS["server"]} ({round(server_keys/TARGETS["server"]*100)}%) | {TARGETS["server"]} |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | {status_icon(php_keys, TARGETS["php"])} | {php_keys}/{TARGETS["php"]} ({round(php_keys/TARGETS["php"]*100) if TARGETS["php"] else 0}%) | {TARGETS["php"]} |
| 📄 HTML Views | {status_icon(html_keys, 300)} | {html_keys}/300 ({round(html_keys/300*100) if html_keys else 0}%) | 300 |
| 📦 JavaScript | {status_icon(client_keys, TARGETS["client"])} | {client_keys}/{TARGETS["client"]} ({round(client_keys/TARGETS["client"]*100) if TARGETS["client"] else 0}%) | {TARGETS["client"]} |

### ⏳ Faza 3: 📱 OTClient / Testyy

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | {status_icon(ui_keys, 200)} | {ui_keys}/200 ({round(ui_keys/200*100)}%) | 200 |
| 💿 Server C++ | {status_icon(cpp_keys, TARGETS["cpp"])} | {cpp_keys}/{TARGETS["cpp"]} ({round(cpp_keys/TARGETS["cpp"]*100) if TARGETS["cpp"] else 0}%) | {TARGETS["cpp"]} |
| 🎮 OTClient Modules | {status_icon(otclient_modules_keys, 500)} | {otclient_modules_keys}/500 ({round(otclient_modules_keys/500*100) if otclient_modules_keys else 0}%) | 500 |
| 📦 OTClient Data | {status_icon(otclient_data_keys, 200)} | {otclient_data_keys}/200 ({round(otclient_data_keys/200*100) if otclient_data_keys else 0}%) | 200 |
| ⚙️ OTClient Src | {status_icon(otclient_src_keys, 300)} | {otclient_src_keys}/300 ({round(otclient_src_keys/300*100) if otclient_src_keys else 0}%) | 300 |
| 🔧 OTClient Mods | {status_icon(otclient_mods_keys, 100)} | {otclient_mods_keys}/100 ({round(otclient_mods_keys/100*100) if otclient_mods_keys else 0}%) | 100 |
| 🛠️ OTClient Tools | {status_icon(otclient_tools_keys, 50)} | {otclient_tools_keys}/50 ({round(otclient_tools_keys/50*100) if otclient_tools_keys else 0}%) | 50 |

### ⏳ Faza 4: 🌍 Tłumaczenia (Etap 1: Sync Kluczy)

| Język | Status | Kluczy | Etap |
|-------|--------|--------|------|
| 🇩🇪 Niemiecki | {"✅ Sync" if "de" in sync_langs_done else ("🔄 Sync..." if sync_current_lang == "de" else ("📊 " + str(sync_stats.get("de", {}).get("total", 0)) + " kluczy" if sync_stats.get("de") else "⏳ Czeka"))} | {sync_stats.get("de", {}).get("total", 0) if sync_stats.get("de") else 0} | {"[EN] prefix" if sync_stats.get("de") else "nie rozpoczęto"} |
| 🇵🇱 Polski | {"✅ Sync" if "pl" in sync_langs_done else ("🔄 Sync..." if sync_current_lang == "pl" else ("📊 " + str(sync_stats.get("pl", {}).get("total", 0)) + " kluczy" if sync_stats.get("pl") else "⏳ Czeka"))} | {sync_stats.get("pl", {}).get("total", 0) if sync_stats.get("pl") else 0} | {"[EN] prefix" if sync_stats.get("pl") else "nie rozpoczęto"} |
| 🇪🇸 Hiszpański | {"✅ Sync" if "es" in sync_langs_done else ("🔄 Sync..." if sync_current_lang == "es" else ("📊 " + str(sync_stats.get("es", {}).get("total", 0)) + " kluczy" if sync_stats.get("es") else "⏳ Czeka"))} | {sync_stats.get("es", {}).get("total", 0) if sync_stats.get("es") else 0} | {"[EN] prefix" if sync_stats.get("es") else "nie rozpoczęto"} |
| 🇫🇷 Francuski | {"✅ Sync" if "fr" in sync_langs_done else ("🔄 Sync..." if sync_current_lang == "fr" else ("📊 " + str(sync_stats.get("fr", {}).get("total", 0)) + " kluczy" if sync_stats.get("fr") else "⏳ Czeka"))} | {sync_stats.get("fr", {}).get("total", 0) if sync_stats.get("fr") else 0} | {"[EN] prefix" if sync_stats.get("fr") else "nie rozpoczęto"} |
| 🌐 Pozostałe ({len(sync_langs_done)}/53) | {"🔄" if sync_current_lang else "⏳"} | {sum(v.get("total", 0) for v in sync_stats.values())} | {f"Aktualnie: {sync_current_lang.upper()}" if sync_current_lang else "nie rozpoczęto"} |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: {len(sync_stats)}/{langs_count}
- Ostatni sync: {(sync_current_lang.upper() + '/' + sync_current_cat) if sync_current_lang else '-'}

### 🌍 Etap 2: Tłumaczenia (AUTO)
| Język | TM wpisy | Status |
|-------|----------|--------|
{auto_table}

**Języki bez TM (AUTO → placeholdery):** {', '.join(no_tm_langs[:8]) + ('...' if len(no_tm_langs) > 8 else '') if no_tm_langs else 'brak (TM dostępny)'}
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #{cycle_count:>6} │
├─────────────────────────────────────────────────────────────────┤
│ Status:    {status_display:40} │
│ Tryb:      {mode_display:40} │
│ Kategoria: {category_display:40} │
├─────────────────────────────────────────────────────────────────┤
{live_details}
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: {str(heartbeat_iso or '-'):30} │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

{(lambda _a: '\n'.join([f"- {_it.get('t','')[:19].replace('T',' ')} | {_it.get('phase','')}:{_it.get('stage','')} | {_it.get('category','')} | {_it.get('result','')} | {_it.get('file','-')}" for _it in (_a.get('recent', []) if isinstance(_a.get('recent', []), list) else [])][:6]) or '- brak danych')(activity if activity_present else {})}

---

## 🔁 W tym cyklu

{cycle_ops_md}


{daily_section}

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **{len(files)}** | w tej sesji |
| ✅ Plików z kluczami | **{files_migrated}** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **{len(files) - files_migrated}** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **{total_keys_extracted}** | przez workera w tej sesji |
| 🌍 Języków | **{langs_count}** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#{cycle_count}** | continuous mode |

---

## 📂 Szczegóły Kategorii

<details>
<summary>🎮 1. Game - {status_icon(game_keys, TARGETS["game"])} ({round(game_keys/TARGETS["game"]*100) if TARGETS["game"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {game_keys} |
| 🎯 Cel | {TARGETS["game"]} |
| 📊 Postęp | {round(game_keys/TARGETS["game"]*100) if TARGETS["game"] else 0}% |
| 📁 Plik | i18n/en/game.json |

</details>

<details>
<summary>🎒 2. Items - {status_icon(items_keys, TARGETS["items"])} ({round(items_keys/TARGETS["items"]*100) if TARGETS["items"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {items_keys} |
| 🎯 Cel | {TARGETS["items"]} |
| 📊 Postęp | {round(items_keys/TARGETS["items"]*100) if TARGETS["items"] else 0}% |
| 📁 Plik | i18n/en/items.json |

</details>

<details>
<summary>📦 3. Misc - {status_icon(misc_keys, TARGETS["misc"])} ({round(misc_keys/TARGETS["misc"]*100) if TARGETS["misc"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {misc_keys} |
| 🎯 Cel | {TARGETS["misc"]} |
| 📊 Postęp | {round(misc_keys/TARGETS["misc"]*100) if TARGETS["misc"] else 0}% |
| 📁 Plik | i18n/en/misc.json |

</details>

<details>
<summary>👹 4. Monsters - {status_icon(monsters_keys, TARGETS["monsters"])} ({round(monsters_keys/TARGETS["monsters"]*100) if TARGETS["monsters"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {monsters_keys} |
| 🎯 Cel | {TARGETS["monsters"]} |
| 📊 Postęp | {round(monsters_keys/TARGETS["monsters"]*100) if TARGETS["monsters"] else 0}% |
| 📁 Plik | i18n/en/monsters.json |

</details>

<details>
<summary>🧙 5. NPC - {status_icon(npc_keys, TARGETS["npc"])} ({round(npc_keys/TARGETS["npc"]*100) if TARGETS["npc"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {npc_keys} |
| 🎯 Cel | {TARGETS["npc"]} |
| 📊 Postęp | {round(npc_keys/TARGETS["npc"]*100) if TARGETS["npc"] else 0}% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | {total_npc} |
| ✅ Zmigrowanych | {migrated_npc} |
| 🔄 Do migracji | {needs_migration_npc} |

</details>

<details>
<summary>👤 6. Player - {status_icon(player_keys, TARGETS["player"])} ({round(player_keys/TARGETS["player"]*100) if TARGETS["player"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {player_keys} |
| 🎯 Cel | {TARGETS["player"]} |
| 📊 Postęp | {round(player_keys/TARGETS["player"]*100) if TARGETS["player"] else 0}% |
| 📁 Plik | i18n/en/player.json |

</details>

<details>
<summary>📜 7. Quests - {status_icon(quests_keys, TARGETS["quests"])} ({round(quests_keys/TARGETS["quests"]*100) if TARGETS["quests"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {quests_keys} |
| 🎯 Cel | {TARGETS["quests"]} |
| 📊 Postęp | {round(quests_keys/TARGETS["quests"]*100) if TARGETS["quests"] else 0}% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - {status_icon(scripts_keys, TARGETS["scripts"])} ({round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {scripts_keys} |
| 🎯 Cel | {TARGETS["scripts"]} |
| 📊 Postęp | {round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}% |
| 📁 Plik | i18n/en/scripts.json |

</details>

<details>
<summary>⚙️ 9. Server - {status_icon(server_keys, TARGETS["server"])} ({round(server_keys/TARGETS["server"]*100) if TARGETS["server"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {server_keys} |
| 🎯 Cel | {TARGETS["server"]} |
| 📊 Postęp | {round(server_keys/TARGETS["server"]*100) if TARGETS["server"] else 0}% |
| 📁 Plik | i18n/en/server.json |

</details>

<details>
<summary>✨ 10. Spells - {status_icon(spells_keys, TARGETS["spells"])} ({round(spells_keys/TARGETS["spells"]*100) if TARGETS["spells"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {spells_keys} |
| 🎯 Cel | {TARGETS["spells"]} |
| 📊 Postęp | {round(spells_keys/TARGETS["spells"]*100) if TARGETS["spells"] else 0}% |
| 📁 Plik | i18n/en/spells.json |

</details>

<details>
<summary>🖥️ 11. System - {status_icon(system_keys, TARGETS["system"])} ({round(system_keys/TARGETS["system"]*100) if TARGETS["system"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {system_keys} |
| 🎯 Cel | {TARGETS["system"]} |
| 📊 Postęp | {round(system_keys/TARGETS["system"]*100) if TARGETS["system"] else 0}% |
| 📁 Plik | i18n/en/system.json |

</details>

<details>
<summary>🎨 12. UI - {status_icon(ui_keys, TARGETS["ui"])} ({round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {ui_keys} |
| 🎯 Cel | {TARGETS["ui"]} |
| 📊 Postęp | {round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}% |
| 📁 Plik | i18n/en/ui.json |

</details>

---

## 📊 Wszystkie Kategorie JSON (Dynamiczne)

| Kategoria | Kluczy | Przetworzono | Seria zer | Status |
|-----------|--------|--------------|-----------|--------|
'''

# Generuj dynamiczną tabelę wszystkich kategorii
import time
now = time.time()
for cat_name, keys in sorted(all_json_categories.items(), key=lambda x: -x[1]):
    total_proc = worker_state.get("total_processed", {}).get(cat_name, 0)
    consec_zeros = worker_state.get("consecutive_zeros", {}).get(cat_name, 0)
    skip_until = worker_state.get("skip_until", {}).get(cat_name, 0)
    
    # Status
    if skip_until > now:
        status = f"⏭️ Skip {int((skip_until - now) / 60)}m"
    elif keys > 0:
        status = "✅ Active"
    else:
        status = "⏳ Empty"
    
    md += f"| {cat_name} | {keys} | {total_proc} | {consec_zeros} | {status} |\n"

md += '''
---

## 🤖 Worker Category State

'''

# Pokaż kategorie z aktywnym skip
skipped_cats = []
for cat_name, skip_time in worker_state.get("skip_until", {}).items():
    if skip_time > now:
        mins_left = int((skip_time - now) / 60)
        consec = worker_state.get("consecutive_zeros", {}).get(cat_name, 0)
        skipped_cats.append(f"| {cat_name} | {mins_left}m | {consec}x | Progresywny backoff |")

if skipped_cats:
    md += '''| Kategoria | Skip pozostało | Seria zer | Powód |
|-----------|----------------|-----------|-------|
'''
    md += "\n".join(skipped_cats)
else:
    md += "*Brak kategorii z aktywnym skip*"

md += f'''

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #{cycle_count} |
| Guardian v2.0 | 🟢 ACTIVE | Push co 2 min |

---

## 🌍 Tłumaczenia - Etap 1: Synchronizacja Kluczy

'''

# Pobierz dane synchronizacji
sync_data = worker_state.get("translation_sync", {})
sync_stats = sync_data.get("stats", {})
languages_done = sync_data.get("languages_done", [])
current_sync_lang = sync_data.get("current_lang", "")
current_sync_cat = sync_data.get("current_category", "")

# Kolejność języków
TARGET_LANGS_ORDER = ["de", "pl", "es", "pt", "fr", "it", "nl", "cs", "sk", "hu", "sv", "da", "no", "fi", "ru", "uk", "tr", "ar", "zh", "ja", "ko"]

# Oblicz postęp dla każdego języka
lang_progress = []
for lang in TARGET_LANGS_ORDER[:10]:  # Pokaż top 10
    if lang in sync_stats:
        stats = sync_stats[lang]
        lang_total = stats.get("total", sum(v for k,v in stats.items() if k != "total"))
        is_done = "✅" if lang in languages_done else "🔄" if lang == current_sync_lang else "⏳"
        lang_progress.append(f"| {lang.upper()} | {lang_total:,} | {is_done} |")
    else:
        lang_progress.append(f"| {lang.upper()} | 0 | ⏳ |")

if lang_progress:
    md += '''| Język | Kluczy | Status |
|-------|--------|--------|
'''
    md += "\n".join(lang_progress)
    md += f'''

> **Aktualnie:** {current_sync_lang.upper() if current_sync_lang else "IDLE"} / {current_sync_cat if current_sync_cat else "-"}  
> **Ukończone języki:** {len(languages_done)}/53  
> **Prefix:** `[EN] ` (klucze do przetłumaczenia)
'''
else:
    md += "*Synchronizacja jeszcze nie rozpoczęta*"

md += f'''

---

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
{roadmap_items}
{roadmap_npc}
{roadmap_scripts}
{roadmap_monsters}
{roadmap_spells}
{roadmap_server}
{roadmap_system}
{roadmap_ui}

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: {timestamp}  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

{chr(10).join(recent_completed) if recent_completed else "- Brak"}

---

## 🚀 Jak uruchomić

```bash
# Pojedynczy plik
./i18n_worker_simple.sh --file data-otservbr-global/npc/nazwa.lua

# Status lokalny
./i18n_worker_simple.sh --status

# Auto migracja (5 plików)
./i18n_worker_simple.sh --auto 5

# Aktualizuj I18N_STATUS.md
./i18n_worker_simple.sh --update-status
```

---

*Wygenerowano automatycznie przez i18n_worker_simple.sh v1.1*
'''

# Zapisz do git root (dla GitHub) + do lokalnego katalogu workera (dla podglądu w workspace)
status_paths = []
status_paths.append(os.path.join(GIT_ROOT, "I18N_STATUS.md"))
status_paths.append(os.path.join(WORK_DIR, "I18N_STATUS.md"))

written = []
for p in status_paths:
    p = os.path.abspath(p)
    if p in written:
        continue
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w") as f:
        f.write(md)
    written.append(p)

print(f"✅ I18N_STATUS.md zaktualizowany: {timestamp}")
for p in written:
    print(f"   Ścieżka: {p}")
print(f"   NPC: {npc_keys} kluczy, {completed} zmigrowanych, {needs_migration_npc} do zrobienia")
print(f"   Total: {total_keys} kluczy | Języki: {len(langs_with_data)}/{langs_count}")
STATUSPY
}

#===============================================================================
# ETAP 1: STARTED
#===============================================================================
stage_1() {
    local file="$1"
    log "${BLUE}[1/8] STARTED${NC}: $file"
    
    [ ! -f "$file" ] && { log "${RED}Plik nie istnieje${NC}"; return 1; }
    
    local hash=""
    if command -v md5sum >/dev/null 2>&1; then
        hash=$(md5sum "$file" | cut -d' ' -f1)
    elif command -v sha256sum >/dev/null 2>&1; then
        hash=$(sha256sum "$file" | cut -d' ' -f1)
    elif command -v python3 >/dev/null 2>&1; then
        hash=$(python3 - "$file" <<'PY'
import hashlib
import sys

path = sys.argv[1]
h = hashlib.md5()
with open(path, "rb") as f:
    for chunk in iter(lambda: f.read(8192), b""):
        h.update(chunk)
print(h.hexdigest())
PY
)
    else
        hash="unknown"
    fi
    local type="other"
    [[ "$file" == *"/npc/"* ]] && type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    
    mkdir -p "$BACKUP_DIR/$type"
    cp "$file" "$BACKUP_DIR/$type/$(basename "$file").bak"
    
    # Zapisz do JSON
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_1)${NC}"
        return 1
    fi
    python3 -c "
import json
import os
import shutil
from datetime import datetime

status_file = '$STATUS_FILE'
try:
    with open(status_file, 'r') as f: data = json.load(f)
except: data = {'files': {}}

data['files']['$file'] = {
    'stages': {
        '1_started': {'status': 'completed', 'hash': '$hash', 'type': '$type'}
    },
    'overall_status': 'in_progress'
}

tmp_file = status_file + '.tmp'
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + '.bak')
    except Exception:
        pass
with open(tmp_file, 'w') as f: json.dump(data, f, indent=2)
os.replace(tmp_file, status_file)
print('OK')
"
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    log "${GREEN}✓ Etap 1 OK${NC}: hash=$hash type=$type"
}

#===============================================================================
# ETAP 2: ANALYSIS
#===============================================================================
stage_2() {
    local file="$1"
    log "${BLUE}[2/8] ANALYSIS${NC}: $file"
    
    # Szukamy różnych wzorców tekstowych
    local stdmod=$(grep -c "StdModule\.say" "$file" 2>/dev/null || echo "0")
    local npcsay=$(grep -c "npcHandler:say" "$file" 2>/dev/null || echo "0")
    local sendtxt=$(grep -c "sendTextMessage" "$file" 2>/dev/null || echo "0")
    local greet=$(grep -c "addGreetKeyword" "$file" 2>/dev/null || echo "0")
    local farewell=$(grep -c "addFarewellKeyword" "$file" 2>/dev/null || echo "0")
    local i18nkey=$(grep -c "i18nKey" "$file" 2>/dev/null || echo "0")
    local npcsaylib=$(grep -c "NPC_LIB.i18n.npcSay" "$file" 2>/dev/null || echo "0")
    
    # Wyczyść zmienne - usuń białe znaki
    stdmod=${stdmod//[[:space:]]/}
    npcsay=${npcsay//[[:space:]]/}
    sendtxt=${sendtxt//[[:space:]]/}
    greet=${greet//[[:space:]]/}
    farewell=${farewell//[[:space:]]/}
    i18nkey=${i18nkey//[[:space:]]/}
    npcsaylib=${npcsaylib//[[:space:]]/}
    
    # Domyślne wartości
    [ -z "$stdmod" ] && stdmod=0
    [ -z "$npcsay" ] && npcsay=0
    [ -z "$sendtxt" ] && sendtxt=0
    [ -z "$greet" ] && greet=0
    [ -z "$farewell" ] && farewell=0
    [ -z "$i18nkey" ] && i18nkey=0
    [ -z "$npcsaylib" ] && npcsaylib=0
    
    local total=$((stdmod + npcsay + sendtxt + greet + farewell))
    local greet_farewell=$((greet + farewell))
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Sprawdź czy plik wymaga migracji
    local needs="false"
    
    # StdModule.say wymaga migracji jeśli brak i18nKey
    if [ "$stdmod" -gt 0 ] && [ "$i18nkey" -lt "$stdmod" ]; then
        needs="true"
    fi
    
    # npcHandler:say wymaga migracji jeśli są jakiekolwiek stare wywołania
    # (nawet jeśli część została już przekonwertowana na NPC_LIB.i18n.npcSay)
    if [ "$npcsay" -gt 0 ]; then
        needs="true"
    fi
    
    # addGreetKeyword/addFarewellKeyword z text wymaga migracji jeśli brak i18nKey
    if [ "$greet_farewell" -gt 0 ]; then
        local greet_with_i18n=$(grep -c "addGreetKeyword.*i18nKey\|addFarewellKeyword.*i18nKey" "$file" 2>/dev/null || echo "0")
        greet_with_i18n=${greet_with_i18n//[[:space:]]/}
        if [ "$greet_with_i18n" -lt "$greet_farewell" ]; then
            needs="true"
        fi
    fi
    
    # npcConfig.voices z text = "..." wymaga migracji jeśli brak i18nKey
    if grep -q "npcConfig.voices" "$file" 2>/dev/null; then
        if grep -q 'text = "' "$file" 2>/dev/null; then
            if ! grep -q "i18nKey" "$file" 2>/dev/null; then
                needs="true"
            fi
        fi
    fi
    
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_2)${NC}"
        return 1
    fi
    python3 -c "
import json
import os
import shutil

needs_bool = True if '$needs' == 'true' else False
status_file = '$STATUS_FILE'

with open(status_file, 'r') as f: data = json.load(f)

data['files']['$file']['stages']['2_analysis'] = {
    'status': 'completed',
    'safe_name': '$safe',
    'StdModule_say': $stdmod,
    'npcHandler_say': $npcsay,
    'sendTextMessage': $sendtxt,
    'addGreetKeyword': $greet,
    'addFarewellKeyword': $farewell,
    'total': $total,
    'already_i18n': $i18nkey,
    'npcSayLib': $npcsaylib,
    'needs_migration': needs_bool
}

tmp_file = status_file + '.tmp'
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + '.bak')
    except Exception:
        pass
with open(tmp_file, 'w') as f: json.dump(data, f, indent=2)
os.replace(tmp_file, status_file)
print('OK')
"
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    log "${GREEN}✓ Etap 2 OK${NC}: StdModule=$stdmod, greet/farewell=$greet_farewell, needs=$needs"
    [ "$needs" = "true" ] && return 0 || return 2
}

#===============================================================================
# ETAP 3: DOCUMENTATION
#===============================================================================
stage_3() {
    local file="$1"
    log "${BLUE}[3/8] DOCUMENTATION${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    local doc_dir="docs/i18n/npc"
    local backup_file="$BACKUP_DIR/npc/$(basename "$file").bak"
    
    mkdir -p "$doc_dir"
    
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_3)${NC}"
        return 1
    fi
    python3 << EOF
import json
import os
import re
import shutil
from datetime import datetime

# Wczytaj backup z oryginalnymi tekstami
backup_file = "$backup_file"
try:
    with open(backup_file, "r") as f:
        content = f.read()
except:
    content = ""

# Znajdź wszystkie text = "..."
texts = re.findall(r'text\s*=\s*"([^"]+)"', content)

# Generuj markdown
doc_file = "$doc_dir/${safe}.md"
with open(doc_file, "w") as f:
    f.write(f"# NPC: $base\n\n")
    f.write(f"**Plik:** `$file`\n")
    f.write(f"**Data migracji:** {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
    f.write(f"**Liczba tekstów:** {len(texts)}\n\n")
    f.write("## Klucze i18n\n\n")
    f.write("| Klucz | Tekst EN |\n")
    f.write("|-------|----------|\n")
    for i, text in enumerate(texts, 1):
        if len(text) >= 5:
            key = f"npc.$safe.stdmod_{i}"
            f.write(f"| `{key}` | {text[:60]}{'...' if len(text) > 60 else ''} |\n")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["3_documentation"] = {
    "status": "completed", 
    "doc_file": doc_file,
    "keys_documented": len([t for t in texts if len(t) >= 5])
}
status_file = "$STATUS_FILE"
tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)

print(f"Utworzono: {doc_file}")
EOF
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    
    log "${GREEN}✓ Etap 3 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 4: TRANSFORMATION (text → i18nKey + npcHandler:say → NPC_LIB.i18n.npcSay)
#===============================================================================
stage_4() {
    local file="$1"
    log "${BLUE}[4/8] TRANSFORMATION${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Użyj Pythona dla multi-line parsing
    local transformed=$(python3 << TRANSFORM_PY
import re
import os

file_path = "$file"
safe_name = "$safe"

with open(file_path, 'r') as f:
    content = f.read()

original_content = content
total_transformed = 0

#==============================================================================
# TRANSFORMACJA 1: StdModule.say / StdModule.promotePlayer (text=... lub text={...}) → i18nKey
#==============================================================================
stdmod_counter = [0]
promote_counter = [0]

#==============================================================================
# TRANSFORMACJA 2: npcHandler:say(...) → NPC_LIB.i18n.npcSay / npcSayMultiple
# Obsługa:
#   - literal "..."
#   - string.format("...", ...)
#   - konkatenacje "..." .. expr .. "..."
#   - tablice npcHandler:say({ ... }, npc, creature, delay) lub tablica z npc/creature/delay na końcu
# NIE transformujemy:
#   - message jako zmienna bez literalów
#   - wywołania z dodatkowymi parametrami (poza delay przy tablicach)
#==============================================================================
npcsay_calls = 0
npcsay_keys = 0
npcsay_concat = 0
npcsay_arrays = 0
npcsay_format = 0
npcsay_simple = 0

_STRING_LITERAL_RE = re.compile(
    r"^(?P<q>['\"])(?P<body>(?:\\.|(?!\1).)*)\1$",
    re.DOTALL,
)
_FMT_SPEC_RE = re.compile(r"%(?:[0-9#+\\-\\.]*)(?:[diuoxXfFeEgGaAcsp])")

def _scan_matching_paren_in_expr(expr, open_idx):
    depth = 1
    i = open_idx + 1
    in_str = None
    esc = False
    while i < len(expr):
        ch = expr[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None

def _strip_wrapping_parens(expr):
    expr = expr.strip()
    while expr.startswith("(") and expr.endswith(")"):
        idx = _scan_matching_paren_in_expr(expr, 0)
        if idx == len(expr) - 1:
            expr = expr[1:-1].strip()
        else:
            break
    return expr

def _is_comment_call(content, idx):
    line_start = content.rfind("\n", 0, idx) + 1
    return "--" in content[line_start:idx]

def _scan_matching_paren(content, open_paren_idx):
    depth = 1
    i = open_paren_idx + 1
    in_str = None
    esc = False
    while i < len(content):
        ch = content[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None

def _scan_matching_brace(content, open_brace_idx):
    depth = 1
    i = open_brace_idx + 1
    in_str = None
    esc = False
    while i < len(content):
        ch = content[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None

def _split_top_level_args(arg_str):
    args = []
    buf = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(arg_str):
        ch = arg_str[i]
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if ch == "," and depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            args.append("".join(buf).strip())
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        args.append(tail)
    return args

def _infer_inner_indent(table_block, base_indent):
    lines = table_block.splitlines()
    for line in lines[1:]:
        stripped = line.strip()
        if stripped and not stripped.startswith("}"):
            return line[: len(line) - len(line.lstrip())]
    return base_indent + ("\t" if "\t" in base_indent else "    ")

def _find_table_field_span(table_block, field_name):
    depth_brace = 0
    depth_paren = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(table_block):
        ch = table_block[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)

        if depth_brace == 1 and depth_paren == 0 and depth_bracket == 0:
            if table_block.startswith(field_name, i):
                prev = table_block[i - 1] if i > 0 else " "
                if prev.isalnum() or prev == "_":
                    i += 1
                    continue
                j = i + len(field_name)
                while j < len(table_block) and table_block[j].isspace():
                    j += 1
                if j >= len(table_block) or table_block[j] != "=":
                    i += 1
                    continue
                k = j + 1
                while k < len(table_block) and table_block[k].isspace():
                    k += 1
                if k >= len(table_block):
                    return None
                if table_block[k] == "{":
                    close_idx = _scan_matching_brace(table_block, k)
                    if close_idx is None:
                        return None
                    return k, close_idx + 1

                depth_p = 0
                depth_b = 0
                depth_br = 0
                in_str2 = None
                esc2 = False
                l = k
                while l < len(table_block):
                    ch2 = table_block[l]
                    if in_str2:
                        if esc2:
                            esc2 = False
                        elif ch2 == "\\\\":
                            esc2 = True
                        elif ch2 == in_str2:
                            in_str2 = None
                        l += 1
                        continue
                    if ch2 == '"' or ch2 == "'":
                        in_str2 = ch2
                        l += 1
                        continue
                    if ch2 == "(":
                        depth_p += 1
                    elif ch2 == ")":
                        depth_p = max(0, depth_p - 1)
                    elif ch2 == "{":
                        depth_b += 1
                    elif ch2 == "}":
                        if depth_b == 0 and depth_p == 0 and depth_br == 0:
                            return k, l
                        depth_b = max(0, depth_b - 1)
                    elif ch2 == "[":
                        depth_br += 1
                    elif ch2 == "]":
                        depth_br = max(0, depth_br - 1)
                    if ch2 == "," and depth_b == 0 and depth_p == 0 and depth_br == 0:
                        return k, l
                    l += 1
                return k, len(table_block)
        i += 1
    return None

def _collect_module_tables(content, module_name):
    tables = []
    start = 0
    while True:
        idx = content.find(module_name, start)
        if idx == -1:
            break
        if _is_comment_call(content, idx):
            start = idx + len(module_name)
            continue
        line_start = content.rfind("\n", 0, idx) + 1
        line_prefix = content[line_start:idx]
        if re.search(r"\\bfunction\\s+" + re.escape(module_name) + r"\\b", line_prefix):
            start = idx + len(module_name)
            continue
        p = idx + len(module_name)
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != ",":
            start = idx + len(module_name)
            continue
        p += 1
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != "{":
            start = idx + len(module_name)
            continue
        brace_start = p
        brace_end = _scan_matching_brace(content, brace_start)
        if brace_end is None:
            start = idx + len(module_name)
            continue
        tables.append((brace_start, brace_end))
        start = brace_end + 1
    return tables

def _parse_index_expr(expr):
    expr = expr.strip()
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\\s*\\[(.+)\\]\\s*$", expr, re.DOTALL)
    if not m:
        return None
    return {"var": m.group(1), "index": m.group(2).strip()}

def _collect_literal_tables(content):
    tables = {}
    pattern = re.compile(r"(^[ \\t]*)(local\\s+)?([A-Za-z_][A-Za-z0-9_]*)\\s*=\\s*\\{", re.MULTILINE)
    for m in pattern.finditer(content):
        name = m.group(3)
        if name.endswith("_i18n"):
            continue
        brace_start = m.end() - 1
        brace_end = _scan_matching_brace(content, brace_start)
        if brace_end is None:
            continue
        table_block = content[brace_start:brace_end + 1]
        inner = table_block[1:-1].strip()
        if not inner:
            continue
        elements = [e.strip() for e in _split_top_level_args(inner) if e.strip()]
        if not elements:
            continue
        texts = []
        ok = True
        for elem in elements:
            lit = _extract_string_literal(elem)
            if lit is None:
                ok = False
                break
            texts.append(lit)
        if not ok:
            continue
        indent = m.group(1) or ""
        is_local = bool(m.group(2))
        inner_indent = _infer_inner_indent(table_block, indent)
        tables[name] = {
            "texts": texts,
            "indent": indent,
            "inner_indent": inner_indent,
            "is_local": is_local,
        }
    return tables

def _build_i18n_table_def(var_name, info, safe_name):
    indent = info["indent"]
    inner_indent = info["inner_indent"]
    prefix = "local " if info["is_local"] else ""
    lines = [f"{indent}{prefix}{var_name}_i18n = {{"]
    for i in range(1, len(info["texts"]) + 1):
        key = f"npc.{safe_name}.{var_name}_{i}"
        lines.append(f'{inner_indent}"{key}",')
    lines.append(f"{indent}}}")
    return "\n".join(lines) + "\n"

def _find_table_definition(content, var_name):
    pattern = re.compile(r"(^[ \\t]*)(local\\s+)?%s\\s*=\\s*\\{" % re.escape(var_name), re.MULTILINE)
    m = pattern.search(content)
    if not m:
        return None
    brace_start = m.end() - 1
    brace_end = _scan_matching_brace(content, brace_start)
    if brace_end is None:
        return None
    table_block = content[brace_start:brace_end + 1]
    return {
        "brace_end": brace_end,
        "indent": m.group(1) or "",
        "inner_indent": _infer_inner_indent(table_block, m.group(1) or ""),
        "is_local": bool(m.group(2)),
        "table_block": table_block,
    }

def _insert_i18n_tables(content, literal_tables, used_names, safe_name):
    insertions = []
    for name in sorted(used_names):
        if re.search(r"\\b" + re.escape(name) + r"_i18n\\s*=", content):
            continue
        info = literal_tables.get(name)
        if not info:
            continue
        defn = _find_table_definition(content, name)
        if not defn:
            continue
        info = dict(info)
        info["indent"] = defn["indent"]
        info["inner_indent"] = defn["inner_indent"]
        info["is_local"] = defn["is_local"]
        table_def = _build_i18n_table_def(name, info, safe_name)
        pos = defn["brace_end"] + 1
        pad = "\n"
        if pos < len(content) and content[pos:pos + 1] in "\r\n":
            pad = ""
        insertions.append((pos, pad + table_def))
    if insertions:
        for pos, text in sorted(insertions, key=lambda x: x[0], reverse=True):
            content = content[:pos] + text + content[pos:]
    return content

def _extract_string_literal(expr):
    expr = _strip_wrapping_parens(expr)
    m = _STRING_LITERAL_RE.match(expr)
    if not m:
        return None
    return m.group("body")

def _printf_to_braces(s):
    s = s.replace("%%", "%")
    return _FMT_SPEC_RE.sub("{}", s)

def _split_concat(expr):
    parts = []
    buf = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(expr):
        ch = expr[i]
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0 and ch == ".":
            if i + 1 < len(expr) and expr[i + 1] == ".":
                if i + 2 < len(expr) and expr[i + 2] == ".":
                    buf.append(ch)
                    i += 1
                    continue
                parts.append("".join(buf).strip())
                buf = []
                i += 2
                continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return [p for p in parts if p]

def _has_top_level_bool_or_compare(expr):
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(expr):
        ch = expr[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
            i += 1
            continue
        if ch == ")":
            depth_paren = max(0, depth_paren - 1)
            i += 1
            continue
        if ch == "{":
            depth_brace += 1
            i += 1
            continue
        if ch == "}":
            depth_brace = max(0, depth_brace - 1)
            i += 1
            continue
        if ch == "[":
            depth_bracket += 1
            i += 1
            continue
        if ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
            i += 1
            continue
        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            if expr.startswith("==", i) or expr.startswith("~=", i) or expr.startswith("<=", i) or expr.startswith(">=", i):
                return True
            if ch == "<" or ch == ">":
                return True
            if expr.startswith("and", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 3] if i + 3 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
            if expr.startswith("or", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 2] if i + 2 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
        i += 1
    return False

def _normalize_text(text):
    return " ".join(text.split())

def _parse_string_format(expr):
    expr = _strip_wrapping_parens(expr)
    m = re.match(r"^string\\.format\\s*\\((.*)\\)\\s*$", expr, re.DOTALL)
    if not m:
        return None
    inner = m.group(1)
    parts = _split_top_level_args(inner)
    if not parts:
        return None
    fmt_literal = _extract_string_literal(parts[0])
    if fmt_literal is None:
        return None
    translation = _printf_to_braces(fmt_literal)
    args = [p.strip() for p in parts[1:] if p.strip()]
    return {"text": translation, "args": args, "kind": "format"}

def _parse_concat(expr):
    expr = _strip_wrapping_parens(expr)
    parts = _split_concat(expr)
    if len(parts) <= 1:
        return None
    text_parts = []
    args = []
    literal_seen = False
    for part in parts:
        lit = _extract_string_literal(part)
        if lit is not None:
            text_parts.append(lit)
            literal_seen = True
        else:
            text_parts.append("{}")
            args.append(part.strip())
    if not literal_seen:
        return None
    translation = "".join(text_parts)
    return {"text": translation, "args": args, "kind": "concat"}

def _parse_message_expr(expr):
    expr = expr.strip()
    if not expr:
        return None
    literal = _extract_string_literal(expr)
    if literal is not None:
        return {"text": literal, "args": [], "kind": "literal"}
    fmt = _parse_string_format(expr)
    if fmt:
        return fmt
    concat = _parse_concat(expr)
    if concat:
        return concat
    return None

def _is_target_expr(expr):
    return expr in ("creature", "player")

def _is_delay_expr(expr):
    if re.match(r"^\\d+(?:\\.\\d+)?$", expr):
        return True
    return re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", expr) is not None

def _parse_table_expr(expr):
    expr = expr.strip()
    if not (expr.startswith("{") and expr.endswith("}")):
        return None
    inner = expr[1:-1].strip()
    elements = [e.strip() for e in _split_top_level_args(inner) if e.strip()]
    npc_arg = None
    target_arg = None
    delay_arg = None
    if len(elements) >= 3 and _is_delay_expr(elements[-1]) and _is_target_expr(elements[-2]) and elements[-3] == "npc":
        delay_arg = elements[-1]
        target_arg = elements[-2]
        npc_arg = elements[-3]
        elements = elements[:-3]
    elif len(elements) >= 2 and _is_target_expr(elements[-1]) and elements[-2] == "npc":
        target_arg = elements[-1]
        npc_arg = elements[-2]
        elements = elements[:-2]
    return elements, npc_arg, target_arg, delay_arg

def _collect_npcsay_calls(content):
    calls = []
    needle = "npcHandler:say"
    start = 0
    while True:
        idx = content.find(needle, start)
        if idx == -1:
            break
        if content.startswith("npcHandler:sayLocalized", idx):
            start = idx + len(needle)
            continue
        if _is_comment_call(content, idx):
            start = idx + len(needle)
            continue
        p = idx + len(needle)
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != "(":
            start = idx + len(needle)
            continue
        close_idx = _scan_matching_paren(content, p)
        if close_idx is None:
            start = idx + len(needle)
            continue
        calls.append((idx, p, close_idx))
        start = close_idx + 1
    return calls

def _build_npcsay_replacements(content, safe_name):
    replacements = []
    say_index = 0
    call_counts = {"simple": 0, "format": 0, "concat": 0, "array": 0, "keys": 0}

    calls = _collect_npcsay_calls(content)
    for idx, open_idx, close_idx in calls:
        args_str = content[open_idx + 1 : close_idx]
        args = _split_top_level_args(args_str)
        if not args:
            continue
        msg_expr = args[0].strip()
        table_info = _parse_table_expr(msg_expr)
        if table_info is not None:
            table_elements, table_npc, table_target, table_delay = table_info
            npc_arg = None
            target_arg = None
            delay_arg = None
            if len(args) >= 3:
                npc_arg = args[1].strip()
                target_arg = args[2].strip()
                if len(args) >= 4:
                    delay_arg = args[3].strip()
                if len(args) > 4:
                    continue
            else:
                npc_arg = table_npc
                target_arg = table_target
                delay_arg = table_delay

            if not npc_arg or not target_arg:
                continue

            parsed_entries = []
            ok = True
            for elem in table_elements:
                info = _parse_message_expr(elem)
                if not info:
                    ok = False
                    break
                text_clean = _normalize_text(info["text"])
                if not text_clean:
                    ok = False
                    break
                parsed_entries.append(info)
            if not ok or not parsed_entries:
                continue

            entries = []
            for info in parsed_entries:
                say_index += 1
                key = f"npc.{safe_name}.say_{say_index}"
                call_counts["keys"] += 1
                if info["args"]:
                    args_table = "{ " + ", ".join(info["args"]) + " }"
                    entries.append(f'{{ "{key}", {args_table} }}')
                else:
                    entries.append(f'"{key}"')

            keys_table = "{ " + ", ".join(entries) + " }"
            new_call = f"NPC_LIB.i18n.npcSayMultiple(npcHandler, {npc_arg}, {target_arg}, {keys_table}"
            if delay_arg:
                new_call += f", {delay_arg}"
            new_call += ")"

            replacements.append((idx, close_idx + 1, new_call))
            call_counts["array"] += 1
            continue

        info = _parse_message_expr(msg_expr)
        if not info:
            continue

        if len(args) < 3:
            continue
        if len(args) > 3:
            continue

        text_clean = _normalize_text(info["text"])
        if len(text_clean) < 5:
            continue

        npc_arg = args[1].strip()
        target_arg = args[2].strip()

        say_index += 1
        key = f"npc.{safe_name}.say_{say_index}"
        call_counts["keys"] += 1

        if info["args"]:
            args_table = "{ " + ", ".join(info["args"]) + " }"
            new_call = f'NPC_LIB.i18n.npcSay(npcHandler, {npc_arg}, {target_arg}, "{key}", {args_table})'
        else:
            new_call = f'NPC_LIB.i18n.npcSay(npcHandler, {npc_arg}, {target_arg}, "{key}")'

        replacements.append((idx, close_idx + 1, new_call))
        call_counts[info["kind"]] += 1

    return replacements, call_counts

if "npcHandler:say" in content:
    replacements, call_counts = _build_npcsay_replacements(content, safe_name)
    if replacements:
        for start, end, new_call in sorted(replacements, key=lambda x: x[0], reverse=True):
            content = content[:start] + new_call + content[end:]
        npcsay_calls = call_counts["simple"] + call_counts["format"] + call_counts["concat"] + call_counts["array"]
        npcsay_keys = call_counts["keys"]
        npcsay_simple = call_counts["simple"]
        npcsay_format = call_counts["format"]
        npcsay_concat = call_counts["concat"]
        npcsay_arrays = call_counts["array"]
        total_transformed += npcsay_calls

#==============================================================================
# TRANSFORMACJA 3: addGreetKeyword/addFarewellKeyword text = "..." → i18nKey = "..."
# Wzorce:
#   keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, text = "Greetings, |PLAYERNAME|." })
#   keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, text = "Good bye." })
# Transformacja:
#   Dodaj i18nKey = "npc.{name}.greet_N" lub "npc.{name}.farewell_N"
#==============================================================================
greet_counter = [0]
farewell_counter = [0]

# Pattern dla addGreetKeyword z text = "..." (bez i18nKey)
# Szukamy: addGreetKeyword(..., { ... text = "..." ... (może być } albo }, function)
# Zmieniony pattern - szukamy text = "..." i dodajemy i18nKey zaraz po
pattern_greet = r'(addGreetKeyword\s*\([^)]*?)(text\s*=\s*"([^"]+)")([^}]*?\})'
# Pattern dla addFarewellKeyword z text = "..." (bez i18nKey)
pattern_farewell = r'(addFarewellKeyword\s*\([^)]*?)(text\s*=\s*"([^"]+)")([^}]*?\})'

# Transformuj tylko te wpisy które nie mają jeszcze i18nKey
def safe_replace_greet(match):
    full = match.group(0)
    if 'i18nKey' in full:
        return full  # Już ma - nie transformuj
    greet_counter[0] += 1
    key = f"npc.{safe_name}.greet_{greet_counter[0]}"
    before = match.group(1)
    text_part = match.group(2)
    text = match.group(3)
    after = match.group(4)
    return f'{before}{text_part}, i18nKey = "{key}"{after}'

def safe_replace_farewell(match):
    full = match.group(0)
    if 'i18nKey' in full:
        return full  # Już ma - nie transformuj
    farewell_counter[0] += 1
    key = f"npc.{safe_name}.farewell_{farewell_counter[0]}"
    before = match.group(1)
    text_part = match.group(2)
    text = match.group(3)
    after = match.group(4)
    return f'{before}{text_part}, i18nKey = "{key}"{after}'

if 'addGreetKeyword' in content:
    content = re.sub(pattern_greet, safe_replace_greet, content, flags=re.DOTALL)
    total_transformed += greet_counter[0]

if 'addFarewellKeyword' in content:
    content = re.sub(pattern_farewell, safe_replace_farewell, content, flags=re.DOTALL)
    total_transformed += farewell_counter[0]

greet_fare_total = greet_counter[0] + farewell_counter[0]

#==============================================================================
# TRANSFORMACJA 4: npcConfig.voices { text = "..." } → { i18nKey = "..." }
#==============================================================================
voices_counter = [0]

# Proste podejście: znajdź wszystkie { text = "..." } po npcConfig.voices
if 'npcConfig.voices' in content:
    # Znajdź pozycję początku voices
    voices_start = content.find('npcConfig.voices')
    if voices_start >= 0:
        # Znajdź otwierający nawias bloku voices
        brace_start = content.find('{', voices_start)
        if brace_start >= 0:
            # Policz nawiasy aby znaleźć zamykający nawias całego bloku
            depth = 0
            brace_end = brace_start
            for i, c in enumerate(content[brace_start:], brace_start):
                if c == '{':
                    depth += 1
                elif c == '}':
                    depth -= 1
                    if depth == 0:
                        brace_end = i
                        break
            
            # Wytnij blok voices
            voices_block = content[brace_start:brace_end+1]
            
            # Transformuj text = "..." → i18nKey = "..." w bloku
            def replace_voice(match):
                voices_counter[0] += 1
                key = f"npc.{safe_name}.voice_{voices_counter[0]}"
                before = match.group(1)
                after = match.group(3)
                return f'{before}i18nKey = "{key}"{after}'
            
            # Pattern dla: { text = "..." } lub { text = "...", yell = false }
            # Grupuje: ({\s*) text="..." (reszta do })
            pattern_voice = r'(\{\s*)text\s*=\s*"([^"]+)"([^}]*\})'
            new_voices_block = re.sub(pattern_voice, replace_voice, voices_block)
            
            # Zamień blok w content
            content = content[:brace_start] + new_voices_block + content[brace_end+1:]
            total_transformed += voices_counter[0]
    total_transformed += voices_counter[0]

voices_total = voices_counter[0]

#==============================================================================
# ZAPIS
#==============================================================================
if total_transformed > 0 and content != original_content:
    with open(file_path, 'w') as f:
        f.write(content)
    print(f"{total_transformed}|{stdmod_counter[0]}|{npcsay_calls}|{greet_fare_total}|{voices_total}")
else:
    print("0|0|0|0|0")
TRANSFORM_PY
)
    
    # Parsuj wynik: total|stdmod|npcsay|greetfare|voices
    local total_t=$(echo "$transformed" | cut -d'|' -f1)
    local stdmod_t=$(echo "$transformed" | cut -d'|' -f2)
    local npcsay_t=$(echo "$transformed" | cut -d'|' -f3)
    local greetfare_t=$(echo "$transformed" | cut -d'|' -f4)
    local voices_t=$(echo "$transformed" | cut -d'|' -f5)
    
    [ -z "$total_t" ] && total_t=0
    [ -z "$stdmod_t" ] && stdmod_t=0
    [ -z "$npcsay_t" ] && npcsay_t=0
    [ -z "$greetfare_t" ] && greetfare_t=0
    [ -z "$voices_t" ] && voices_t=0

    if [ "${I18N_DEBUG_STAGE4:-0}" = "1" ]; then
        printf '%s\n' "stage_4: file=$file total=$total_t stdmod=$stdmod_t npcsay=$npcsay_t greetfare=$greetfare_t voices=$voices_t" >> /tmp/i18n_debug.log
    fi
    
    if [ "$total_t" -gt 0 ] 2>/dev/null; then
        log "${GREEN}✓ Etap 4 OK${NC}: StdModule=$stdmod_t, npcHandler:say=$npcsay_t, greet/farewell=$greetfare_t, voices=$voices_t, Total=$total_t"
    else
        total_t=0
        log "${YELLOW}⏭ Etap 4${NC}: Brak zmian"
    fi
    
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_4)${NC}"
        return 1
    fi
    python3 -c "
import json
import os
import shutil
status_file = '$STATUS_FILE'
with open(status_file, 'r') as f: data = json.load(f)
data['files']['$file']['stages']['4_transformation'] = {
    'status': 'completed', 
    'transformed': $total_t,
    'stdmod_transformed': $stdmod_t,
    'npcsay_transformed': $npcsay_t
}
tmp_file = status_file + '.tmp'
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + '.bak')
    except Exception:
        pass
with open(tmp_file, 'w') as f: json.dump(data, f, indent=2)
os.replace(tmp_file, status_file)
"
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    return 0
}

#===============================================================================
# ETAP 5: EXTRACTION_EN (klucze do JSON) - StdModule.say + npcHandler:say
#===============================================================================
stage_5() {
    local file="$1"
    log "${BLUE}[5/8] EXTRACTION_EN${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    
    local backup="$BACKUP_DIR/$type/$(basename "$file").bak"
    [ ! -f "$backup" ] && { log "${RED}Brak backupu${NC}"; return 1; }
    
    # Wyciągnij teksty z backupu i dodaj do JSON
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_5)${NC}"
        return 1
    fi
    python3 << EOF
import json
import os
import re
import shutil

# Wczytaj backup (oryginalne teksty przed transformacją)
with open("$backup", "r") as f:
    content = f.read()

# Wczytaj npc.json
json_file = "$I18N_DIR/en/npc.json"
data = {}
try:
    with open(json_file, "r") as f:
        data = json.load(f)
except Exception as e:
    print(f"BŁĄD KRYTYCZNY: Nie można wczytać {json_file}: {e}")
    print("Przerywam ekstrakcję - nie chcę nadpisać danych!")
    exit(1)

added = 0
stdmod_count = 0
npcsay_count = 0

#==============================================================================
# EKSTRAKCJA 1: StdModule.say z text = "..." (może być multi-line)
#==============================================================================
# Pattern dla multi-line - text = "..." wewnątrz bloku StdModule.say
pattern_stdmod = r'StdModule\.say\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_stdmod = re.findall(pattern_stdmod, content, re.DOTALL)

for i, text in enumerate(texts_stdmod, 1):
    if len(text) >= 5:
        key = f"npc.$safe.stdmod_{i}"
        if key not in data:
            data[key] = text
            added += 1
            stdmod_count += 1

#==============================================================================
# EKSTRAKCJA 2: npcHandler:say(...) (literal / concat / format / arrays)
#==============================================================================
_STRING_LITERAL_RE = re.compile(
    r"^(?P<q>['\"])(?P<body>(?:\\.|(?!\1).)*)\1$",
    re.DOTALL,
)
_FMT_SPEC_RE = re.compile(r"%(?:[0-9#+\\-\\.]*)(?:[diuoxXfFeEgGaAcsp])")

def _scan_matching_paren_in_expr(expr, open_idx):
    depth = 1
    i = open_idx + 1
    in_str = None
    esc = False
    while i < len(expr):
        ch = expr[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None

def _strip_wrapping_parens(expr):
    expr = expr.strip()
    while expr.startswith("(") and expr.endswith(")"):
        idx = _scan_matching_paren_in_expr(expr, 0)
        if idx == len(expr) - 1:
            expr = expr[1:-1].strip()
        else:
            break
    return expr

def _is_comment_call(content, idx):
    line_start = content.rfind("\n", 0, idx) + 1
    return "--" in content[line_start:idx]

def _scan_matching_paren(content, open_paren_idx):
    depth = 1
    i = open_paren_idx + 1
    in_str = None
    esc = False
    while i < len(content):
        ch = content[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return None

def _split_top_level_args(arg_str):
    args = []
    buf = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(arg_str):
        ch = arg_str[i]
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if ch == "," and depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            args.append("".join(buf).strip())
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        args.append(tail)
    return args

def _extract_string_literal(expr):
    expr = _strip_wrapping_parens(expr)
    m = _STRING_LITERAL_RE.match(expr)
    if not m:
        return None
    return m.group("body")

def _printf_to_braces(s):
    s = s.replace("%%", "%")
    return _FMT_SPEC_RE.sub("{}", s)

def _split_concat(expr):
    parts = []
    buf = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(expr):
        ch = expr[i]
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0 and ch == ".":
            if i + 1 < len(expr) and expr[i + 1] == ".":
                if i + 2 < len(expr) and expr[i + 2] == ".":
                    buf.append(ch)
                    i += 1
                    continue
                parts.append("".join(buf).strip())
                buf = []
                i += 2
                continue
        buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return [p for p in parts if p]

def _has_top_level_bool_or_compare(expr):
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False
    i = 0
    while i < len(expr):
        ch = expr[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
            i += 1
            continue
        if ch == ")":
            depth_paren = max(0, depth_paren - 1)
            i += 1
            continue
        if ch == "{":
            depth_brace += 1
            i += 1
            continue
        if ch == "}":
            depth_brace = max(0, depth_brace - 1)
            i += 1
            continue
        if ch == "[":
            depth_bracket += 1
            i += 1
            continue
        if ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
            i += 1
            continue
        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            if expr.startswith("==", i) or expr.startswith("~=", i) or expr.startswith("<=", i) or expr.startswith(">=", i):
                return True
            if ch == "<" or ch == ">":
                return True
            if expr.startswith("and", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 3] if i + 3 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
            if expr.startswith("or", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 2] if i + 2 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
        i += 1
    return False

def _normalize_text(text):
    return " ".join(text.split())

def _parse_string_format(expr):
    expr = _strip_wrapping_parens(expr)
    m = re.match(r"^string\\.format\\s*\\((.*)\\)\\s*$", expr, re.DOTALL)
    if not m:
        return None
    inner = m.group(1)
    parts = _split_top_level_args(inner)
    if not parts:
        return None
    fmt_literal = _extract_string_literal(parts[0])
    if fmt_literal is None:
        return None
    translation = _printf_to_braces(fmt_literal)
    args = [p.strip() for p in parts[1:] if p.strip()]
    return {"text": translation, "args": args, "kind": "format"}

def _parse_concat(expr):
    expr = _strip_wrapping_parens(expr)
    if _has_top_level_bool_or_compare(expr):
        return None
    parts = _split_concat(expr)
    if len(parts) <= 1:
        return None
    text_parts = []
    args = []
    literal_seen = False
    for part in parts:
        lit = _extract_string_literal(part)
        if lit is not None:
            text_parts.append(lit)
            literal_seen = True
        else:
            text_parts.append("{}")
            args.append(part.strip())
    if not literal_seen:
        return None
    translation = "".join(text_parts)
    return {"text": translation, "args": args, "kind": "concat"}

def _parse_message_expr(expr):
    expr = expr.strip()
    if not expr:
        return None
    literal = _extract_string_literal(expr)
    if literal is not None:
        return {"text": literal, "args": [], "kind": "literal"}
    fmt = _parse_string_format(expr)
    if fmt:
        return fmt
    concat = _parse_concat(expr)
    if concat:
        return concat
    return None

def _is_target_expr(expr):
    return expr in ("creature", "player")

def _is_delay_expr(expr):
    if re.match(r"^\\d+(?:\\.\\d+)?$", expr):
        return True
    return re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", expr) is not None

def _parse_table_expr(expr):
    expr = expr.strip()
    if not (expr.startswith("{") and expr.endswith("}")):
        return None
    inner = expr[1:-1].strip()
    elements = [e.strip() for e in _split_top_level_args(inner) if e.strip()]
    npc_arg = None
    target_arg = None
    delay_arg = None
    if len(elements) >= 3 and _is_delay_expr(elements[-1]) and _is_target_expr(elements[-2]) and elements[-3] == "npc":
        delay_arg = elements[-1]
        target_arg = elements[-2]
        npc_arg = elements[-3]
        elements = elements[:-3]
    elif len(elements) >= 2 and _is_target_expr(elements[-1]) and elements[-2] == "npc":
        target_arg = elements[-1]
        npc_arg = elements[-2]
        elements = elements[:-2]
    return elements, npc_arg, target_arg, delay_arg

def _collect_npcsay_calls(content):
    calls = []
    needle = "npcHandler:say"
    start = 0
    while True:
        idx = content.find(needle, start)
        if idx == -1:
            break
        if content.startswith("npcHandler:sayLocalized", idx):
            start = idx + len(needle)
            continue
        if _is_comment_call(content, idx):
            start = idx + len(needle)
            continue
        p = idx + len(needle)
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != "(":
            start = idx + len(needle)
            continue
        close_idx = _scan_matching_paren(content, p)
        if close_idx is None:
            start = idx + len(needle)
            continue
        calls.append((idx, p, close_idx))
        start = close_idx + 1
    return calls

say_index = 0
calls = _collect_npcsay_calls(content)
for idx, open_idx, close_idx in calls:
    args_str = content[open_idx + 1 : close_idx]
    args = _split_top_level_args(args_str)
    if not args:
        continue
    msg_expr = args[0].strip()
    table_info = _parse_table_expr(msg_expr)
    if table_info is not None:
        table_elements, table_npc, table_target, _table_delay = table_info
        npc_arg = None
        target_arg = None
        if len(args) >= 3:
            if len(args) > 4:
                continue
            npc_arg = args[1].strip()
            target_arg = args[2].strip()
        else:
            npc_arg = table_npc
            target_arg = table_target
        if not npc_arg or not target_arg:
            continue

        parsed_entries = []
        ok = True
        for elem in table_elements:
            info = _parse_message_expr(elem)
            if not info:
                ok = False
                break
            text_clean = _normalize_text(info["text"])
            if not text_clean:
                ok = False
                break
            parsed_entries.append(text_clean)
        if not ok or not parsed_entries:
            continue

        for text_clean in parsed_entries:
            say_index += 1
            key = f"npc.$safe.say_{say_index}"
            if key not in data:
                data[key] = text_clean
                added += 1
                npcsay_count += 1
        continue

    info = _parse_message_expr(msg_expr)
    if not info:
        continue
    if len(args) < 3 or len(args) > 3:
        continue
    text_clean = _normalize_text(info["text"])
    if len(text_clean) < 5:
        continue
    say_index += 1
    key = f"npc.$safe.say_{say_index}"
    if key not in data:
        data[key] = text_clean
        added += 1
        npcsay_count += 1

#==============================================================================
# EKSTRAKCJA 3: addGreetKeyword/addFarewellKeyword text = "..."
#==============================================================================
greet_count = 0
farewell_count = 0

# Pattern dla addGreetKeyword z text = "..."
pattern_greet = r'addGreetKeyword\s*\(\{[^}]+\}\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_greet = re.findall(pattern_greet, content, re.DOTALL)

for i, text in enumerate(texts_greet, 1):
    text_clean = ' '.join(text.split())
    if len(text_clean) >= 3:
        key = f"npc.$safe.greet_{i}"
        if key not in data:
            data[key] = text_clean
            added += 1
            greet_count += 1

# Pattern dla addFarewellKeyword z text = "..."
pattern_farewell = r'addFarewellKeyword\s*\(\{[^}]+\}\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_farewell = re.findall(pattern_farewell, content, re.DOTALL)

for i, text in enumerate(texts_farewell, 1):
    text_clean = ' '.join(text.split())
    if len(text_clean) >= 3:
        key = f"npc.$safe.farewell_{i}"
        if key not in data:
            data[key] = text_clean
            added += 1
            farewell_count += 1

#==============================================================================
# EKSTRAKCJA 4: npcConfig.voices z { text = "..." }
#==============================================================================
voices_count = 0

# Pattern dla npcConfig.voices z text = "..." (obsługa wielu bloków)
if 'npcConfig.voices' in content:
    for voices_block in re.findall(r'npcConfig\\.voices\\s*=\\s*\\{([^}]*)\\}', content, re.DOTALL):
        texts_voices = re.findall(r'text\\s*=\\s*\"([^\"]+)\"', voices_block)
        for i, text in enumerate(texts_voices, 1):
            text_clean = ' '.join(text.split())
            if len(text_clean) >= 3:
                key = f"npc.$safe.voice_{i}"
                if key not in data:
                    data[key] = text_clean
                    added += 1
                    voices_count += 1

# Zapisz
with open(json_file, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Dodano {added} kluczy (StdModule: {stdmod_count}, npcHandler:say: {npcsay_count}, greet: {greet_count}, farewell: {farewell_count}, voices: {voices_count})")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["5_extraction_en"] = {
    "status": "completed", 
    "keys_added": added,
    "stdmod_keys": stdmod_count,
    "npcsay_keys": npcsay_count,
    "greet_keys": greet_count,
    "farewell_keys": farewell_count,
    "voices_keys": voices_count
}
status_file = "$STATUS_FILE"
tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)
EOF
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    
    log "${GREEN}✓ Etap 5 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 6: TRANSLATION (EN → inne języki)
#===============================================================================
stage_6() {
    local file="$1"
    log "${BLUE}[6/8] PLACEHOLDER${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Etap 6 tylko tworzy placeholdery [LANG] - prawdziwe tłumaczenia w trybie TRANSLATION
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_6)${NC}"
        return 1
    fi
    python3 << PYEOF
import json
import os
import shutil

safe_name = "$safe"
status_file = "$STATUS_FILE"
i18n_dir = "$I18N_DIR"
file_path = "$file"

# Wczytaj en/npc.json
en_file = f"{i18n_dir}/en/npc.json"
try:
    with open(en_file, "r") as f:
        en_data = json.load(f)
except:
    print("Brak en/npc.json")
    exit(1)

# Znajdź klucze dla tego NPC
npc_keys = {k: v for k, v in en_data.items() if k.startswith(f"npc.{safe_name}.")}

if not npc_keys:
    print("Brak kluczy dla tego NPC - skip")
    exit(0)

# Tylko placeholder dla głównych języków (szybkie)
MAIN_LANGS = ["pl", "de", "es", "pt", "fr", "it", "ru"]
langs_done = []

for lang in MAIN_LANGS:
    lang_dir = f"{i18n_dir}/{lang}"
    os.makedirs(lang_dir, exist_ok=True)
    
    lang_file = f"{lang_dir}/npc.json"
    try:
        with open(lang_file, "r") as f:
            lang_data = json.load(f)
    except:
        lang_data = {}
    
    added = 0
    for key, text in npc_keys.items():
        if key not in lang_data:
            # Placeholder - do przetłumaczenia w trybie TRANSLATION
            lang_data[key] = f"[{lang.upper()}] {text}"
            added += 1
    
    if added > 0:
        with open(lang_file, "w") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
        langs_done.append(lang)

# Update status
with open(status_file, "r") as f:
    status = json.load(f)
status["files"][file_path]["stages"]["6_placeholder"] = {
    "status": "completed",
    "languages": langs_done,
    "keys_per_lang": len(npc_keys),
    "note": "Placeholdery - do przetłumaczenia w trybie --translate"
}
tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)

print(f"Placeholdery: {len(langs_done)} języków, {len(npc_keys)} kluczy każdy")
PYEOF
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    
    log "${GREEN}✓ Etap 6 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 7: VALIDATION
#===============================================================================
stage_7() {
    local file="$1"
    log "${BLUE}[7/8] VALIDATION${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_7)${NC}"
        return 1
    fi
    python3 << PYEOF
import json
import os
import re
import shutil

safe_name = "$safe"
status_file = "$STATUS_FILE"
i18n_dir = "$I18N_DIR"
file_path = "$file"
lua_file = "$file"

errors = []
warnings = []

# 1. Sprawdź czy plik Lua ma i18nKey
with open(lua_file, "r") as f:
    lua_content = f.read()

i18n_keys_in_lua = re.findall(r'i18nKey\s*=\s*"([^"]+)"', lua_content)
if not i18n_keys_in_lua:
    warnings.append("Brak i18nKey w pliku Lua")

# 2. Sprawdź czy klucze istnieją w en/npc.json
en_file = f"{i18n_dir}/en/npc.json"
try:
    with open(en_file, "r") as f:
        en_data = json.load(f)
except:
    en_data = {}

missing_in_json = []
for key in i18n_keys_in_lua:
    if key not in en_data:
        missing_in_json.append(key)
        errors.append(f"Klucz {key} brakuje w en/npc.json")

# 3. Duplikaty wartości - pomijamy (to normalne że różni NPC używają tych samych słów)
# values = list(en_data.values())
# duplicates = [v for v in values if values.count(v) > 1]
# To NIE jest błąd - wiele NPC może mieć te same teksty

# 4. Walidacja JSON wszystkich języków
valid_langs = []
invalid_langs = []
for lang_dir in os.listdir(i18n_dir):
    lang_file = f"{i18n_dir}/{lang_dir}/npc.json"
    if os.path.exists(lang_file):
        try:
            with open(lang_file, "r") as f:
                json.load(f)
            valid_langs.append(lang_dir)
        except json.JSONDecodeError as e:
            invalid_langs.append(lang_dir)
            errors.append(f"Błąd JSON w {lang_dir}/npc.json: {e}")

validation_ok = len(errors) == 0

# Update status
with open(status_file, "r") as f:
    status = json.load(f)
status["files"][file_path]["stages"]["7_validation"] = {
    "status": "completed" if validation_ok else "failed",
    "errors": errors,
    "warnings": warnings,
    "valid_langs": valid_langs,
    "keys_in_lua": len(i18n_keys_in_lua),
    "validation_passed": validation_ok
}
tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)

if errors:
    print(f"BŁĘDY: {len(errors)}")
    for e in errors:
        print(f"  ❌ {e}")
if warnings:
    print(f"OSTRZEŻENIA: {len(warnings)}")
    for w in warnings:
        print(f"  ⚠ {w}")
if not errors and not warnings:
    print("Walidacja OK - brak błędów")
PYEOF
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    
    log "${GREEN}✓ Etap 7 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 8: SYNC (status, statystyki)
#===============================================================================
stage_8() {
    local file="$1"
    log "${BLUE}[8/8] SYNC${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    if ! status_lock_acquire; then
        log "${RED}❌ Brak locka statusu (stage_8)${NC}"
        return 1
    fi
    python3 << PYEOF
import json
import os
import shutil
from datetime import datetime

status_file = "$STATUS_FILE"
file_path = "$file"
safe_name = "$safe"

# Wczytaj status
with open(status_file, "r") as f:
    status = json.load(f)

# Oznacz plik jako ukończony
file_info = status["files"].get(file_path, {})
all_stages = file_info.get("stages", {})
completed_stages = [s for s, v in all_stages.items() if v.get("status") == "completed"]

file_info["overall_status"] = "completed"
file_info["completed_at"] = datetime.now().isoformat()
file_info["stages"]["8_sync"] = {"status": "completed"}

status["files"][file_path] = file_info

# Statystyki globalne
if "global_stats" not in status:
    status["global_stats"] = {"files_completed": 0, "total_keys": 0}

status["global_stats"]["files_completed"] = len([
    f for f, info in status["files"].items() 
    if info.get("overall_status") == "completed"
])

# Zapisz
tmp_file = status_file + ".tmp"
if os.path.exists(status_file):
    try:
        shutil.copy2(status_file, status_file + ".bak")
    except Exception:
        pass
with open(tmp_file, "w") as f:
    json.dump(status, f, indent=2)
os.replace(tmp_file, status_file)

# Aktualizuj I18N_STATUS.md
status_md = "I18N_STATUS.md"
try:
    with open(status_md, "r") as f:
        content = f.read()
except:
    content = "# I18N Status\n\n"

# Znajdź lub dodaj sekcję NPC
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
new_entry = "- ✅ `" + safe_name + "` - ukończono " + timestamp + "\\n"

if "## Ostatnio zmigrowane NPC" not in content:
    content += "\\n## Ostatnio zmigrowane NPC\\n\\n"

if safe_name not in content:
    # Dodaj po nagłówku
    content = content.replace(
        "## Ostatnio zmigrowane NPC\\n\\n",
        "## Ostatnio zmigrowane NPC\\n\\n" + new_entry
    )
    with open(status_md, "w") as f:
        f.write(content)
    print("Zaktualizowano " + status_md)

print(f"SYNC OK - plik oznaczony jako completed")
PYEOF
    local rc=$?
    status_lock_release
    [ "$rc" -ne 0 ] && return $rc
    
    log "${GREEN}✓ Etap 8 OK${NC}"
    return 0
}

#===============================================================================
# GŁÓWNA FUNKCJA
#===============================================================================
process_file() {
    local file="$1"
    echo ""
    echo "========================================"
    echo "Przetwarzanie: $file"
    echo "========================================"
    
    stage_1 "$file" || return 1
    stage_2 "$file"
    local ret=$?
    
    if [ $ret -eq 2 ]; then
        if ! stage_3 "$file"; then
            return 1
        fi
        # Oznacz jako przetworzony nawet jeśli nie wymaga migracji (analysis/doc wykonane)
        mark_file_completed "$file" "npc" "0"
        log "${YELLOW}Plik nie wymaga migracji (analysis/doc zaktualizowane)${NC}"
        return 0
    fi
    
    stage_3 "$file" || return 1
    stage_4 "$file" || return 1

    # Walidacja syntaktyczna Lua po transformacji
    if ! validate_lua_file "$file"; then
        log "${RED}❌ Walidacja Lua nieudana, przywracam backup${NC}"
        restore_backup_file "$file"
        return 1
    fi

    stage_5 "$file" || return 1
    stage_6 "$file" || return 1
    stage_7 "$file" || return 1
    stage_8 "$file" || return 1
    
    # Dodaj do listy przetworzonych (do obu źródeł!)
    mark_file_completed "$file" "npc" "1"
    
    log "${GREEN}✅ WSZYSTKIE 8 ETAPÓW UKOŃCZONE!${NC}"
    return 0
}

#===============================================================================
# FUNKCJE PRZETWARZANIA KATEGORII (SCRIPTS, MONSTERS, SPELLS, ITEMS)
#===============================================================================

# Przetwarzaj pliki skryptów (sendTextMessage → klucze i18n)
process_scripts_file() {
    local file="$1"
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    local json_file="$I18N_DIR/en/scripts.json"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📜 Processing script: $base${NC}"

    # FIZYCZNA MIGRACJA: przepisz :sendTextMessage(...) -> :sendLocalizedTextMessage(...)
    # i dopisz EN klucze do i18n/en/scripts.json
    local _out _rc
    _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
        --file "$file" \
        --json "$json_file" \
        --key-prefix "scripts.${safe}" \
        --backup-dir "$BACKUP_DIR/scripts" \
        2>&1)
    _rc=$?
    if [ "$_rc" -ne 0 ]; then
        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_migrate" "scripts" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
        return 1
    fi

    local keys_added calls_migrated file_changed
    keys_added=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
    calls_migrated=$(echo "$_out" | grep -oE 'calls_migrated=[0-9]+' | tail -n 1 | cut -d= -f2)
    file_changed=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
    keys_added=${keys_added:-0}
    calls_migrated=${calls_migrated:-0}
    file_changed=${file_changed:-0}

    # Walidacja syntaktyczna Lua po transformacji (jeśli mamy lua w PATH)
    if [ "$file_changed" = "1" ]; then
        if ! validate_lua_file "$file"; then
            log "${RED}❌ Walidacja Lua nieudana, przywracam backup${NC}"
            restore_backup_file "$file"
            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_validate" "scripts" "$file" "lua validation failed" "restored backup"
            return 1
        fi
    fi

    # FIZYCZNA MIGRACJA: creature/player/npc :say("...") -> :sayLocalized("key", ...)
    _out=$(python3 tools/i18n_migrate_lua_say.py \
        --target creature \
        --file "$file" \
        --json "$json_file" \
        --key-prefix "scripts.${safe}" \
        --backup-dir "$BACKUP_DIR/scripts" \
        --suffix "say" \
        2>&1)
    _rc=$?
    if [ "$_rc" -ne 0 ]; then
        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_say_migrate" "scripts" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
        return 1
    fi
    local say_keys_added say_calls_migrated say_file_changed
    say_keys_added=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
    say_calls_migrated=$(echo "$_out" | grep -oE 'calls_migrated=[0-9]+' | tail -n 1 | cut -d= -f2)
    say_file_changed=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
    say_keys_added=${say_keys_added:-0}
    say_calls_migrated=${say_calls_migrated:-0}
    say_file_changed=${say_file_changed:-0}
    if [ "$say_file_changed" = "1" ]; then
        if ! validate_lua_file "$file"; then
            log "${RED}❌ Walidacja Lua nieudana po sayLocalized, przywracam backup${NC}"
            restore_backup_file "$file"
            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_say_validate" "scripts" "$file" "lua validation failed" "restored backup"
            return 1
        fi
    fi

    # FIZYCZNA MIGRACJA: broadcastMessage -> Game.broadcastLocalizedMessage
    _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
        --file "$file" \
        --json "$json_file" \
        --key-prefix "scripts.${safe}" \
        --backup-dir "$BACKUP_DIR/scripts" \
        --suffix "broadcast" \
        2>&1)
    _rc=$?
    if [ "$_rc" -ne 0 ]; then
        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_broadcast_migrate" "scripts" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
        return 1
    fi
    local broadcast_keys_added broadcast_file_changed
    broadcast_keys_added=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
    broadcast_file_changed=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
    broadcast_keys_added=${broadcast_keys_added:-0}
    broadcast_file_changed=${broadcast_file_changed:-0}
    if [ "$broadcast_file_changed" = "1" ]; then
        if ! validate_lua_file "$file"; then
            log "${RED}❌ Walidacja Lua nieudana po broadcastLocalized, przywracam backup${NC}"
            restore_backup_file "$file"
            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "scripts_broadcast_validate" "scripts" "$file" "lua validation failed" "restored backup"
            return 1
        fi
    fi

    local total_keys_added total_calls_migrated
    total_keys_added=$((keys_added + say_keys_added + broadcast_keys_added))
    total_calls_migrated=$((calls_migrated + say_calls_migrated))

    # Oznacz jako przetworzony (do obu plików!)
    mark_file_completed "$file" "scripts" "$total_keys_added"

    log "${GREEN}✅ Scripts: migrated=$total_calls_migrated calls, +$total_keys_added keys (${base})${NC}"

    return 0
}

# Przetwarzaj kategorię monsters
process_monsters_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/monsters.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/monsters"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}👹 Processing monsters...${NC}"
    
    # Szukaj plików monsters w różnych lokalizacjach
    for dir in data-otservbr-global/monster data-canary/monster; do
        [ ! -d "$dir" ] && continue
        
        # NAPRAWIONE: Nie filtruj po PROCESSED_FILE (monsters mogą dostać nowe wzorce)
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|xml\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local base_title
            base_title=$(title_case "${base//_/ }")
            
            local result rc
            result=$(python3 - "$file" "$json_file" "$safe" "$base_title" "$backup_dir" << 'MONSPY'
import json
import os
import re
import shutil
import sys

file_path = sys.argv[1]
json_file = sys.argv[2]
safe = sys.argv[3]
base_title = sys.argv[4]
backup_dir = sys.argv[5]

try:
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
except Exception as exc:
    print(f"ERROR: read failed: {exc}")
    sys.exit(1)

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as exc:
    print(f"ERROR: json load failed: {exc}")
    sys.exit(1)

changed_file = False
json_changed = False
keys_added = 0
name_added = 0
desc_added = 0
voice_added = 0

def atomic_write_json(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

# === NAME (prefer monster.name, fallback createMonsterType, fallback base title) ===
name = None
match = re.search(r'monster\.name\s*=\s*"([^"]+)"', content)
if match:
    name = match.group(1)
else:
    match = re.search(r'createMonsterType\s*\(\s*"([^"]+)"', content)
    if match:
        name = match.group(1)
if not name:
    name = base_title

name_key = f"monster.{safe}.name"
if name and name_key not in data:
    data[name_key] = name
    keys_added += 1
    name_added += 1
    json_changed = True

# === DESCRIPTION ===
desc = None
match = re.search(r'monster\.description\s*=\s*"([^"]+)"', content)
if match:
    desc = match.group(1)
desc_key = f"monster.{safe}.desc"
if desc and desc_key not in data:
    data[desc_key] = desc
    keys_added += 1
    desc_added += 1
    json_changed = True

# === VOICES (add i18nKey + add keys to JSON) ===
voice_key_prefix = f"monster.{safe}.voice_"
state = {
    "voice_index": 0,
    "changed_file": False,
    "json_changed": False,
    "keys_added": 0,
    "voice_added": 0,
}
for key in data:
    if key.startswith(voice_key_prefix):
        try:
            state["voice_index"] = max(state["voice_index"], int(key.rsplit("_", 1)[1]))
        except Exception:
            pass

def extract_voices_block(text):
    start = text.find("monster.voices")
    if start < 0:
        return None, None, None
    brace_start = text.find("{", start)
    if brace_start < 0:
        return None, None, None
    depth = 0
    brace_end = None
    for idx in range(brace_start, len(text)):
        c = text[idx]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                brace_end = idx
                break
    if brace_end is None:
        return None, None, None
    return brace_start, brace_end, text[brace_start:brace_end + 1]

def voice_text_from_block(block):
    m = re.search(r'text\s*=\s*"([^"]*)"', block)
    if m:
        return m.group(1)
    m = re.search(r"text\s*=\s*'([^']*)'", block)
    if m:
        return m.group(1)
    return None

brace_start, brace_end, voices_block = extract_voices_block(content)
if voices_block:
    voice_pattern = re.compile(r'(\{[^{}]*?text\s*=\s*[^{}]*?\})(\s*)', re.DOTALL)

    def repl(match):
        block = match.group(1)
        ws = match.group(2)

        text = voice_text_from_block(block)
        if not text:
            return block + ws

        key_match = re.search(r'i18nKey\s*=\s*"([^"]+)"', block)
        if key_match:
            key = key_match.group(1)
        else:
            state["voice_index"] += 1
            key = f"{voice_key_prefix}{state['voice_index']}"
            block = block[:-1] + f', i18nKey = "{key}"' + "}"
            state["changed_file"] = True

        if key and key not in data:
            data[key] = text
            state["keys_added"] += 1
            state["voice_added"] += 1
            state["json_changed"] = True

        return block + ws

    new_block = voice_pattern.sub(repl, voices_block)
    if new_block != voices_block:
        content = content[:brace_start] + new_block + content[brace_end + 1:]
        state["changed_file"] = True

if state["changed_file"]:
    changed_file = True
if state["json_changed"]:
    json_changed = True
if state["keys_added"]:
    keys_added += state["keys_added"]
if state["voice_added"]:
    voice_added += state["voice_added"]

if changed_file:
    os.makedirs(backup_dir, exist_ok=True)
    backup_path = os.path.join(backup_dir, os.path.basename(file_path) + ".bak")
    try:
        shutil.copy2(file_path, backup_path)
    except Exception:
        pass
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

if json_changed:
    atomic_write_json(json_file, data)

changed = 1 if (changed_file or json_changed) else 0
file_changed = 1 if changed_file else 0
print(f"__MONSTER_RESULT__ changed={changed} file_changed={file_changed} keys_added={keys_added} name_added={name_added} desc_added={desc_added} voice_added={voice_added}")
MONSPY
            )
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "monsters_process" "monsters" "$file" "python processing failed" "skip mark"
                continue
            fi

            local changed file_changed keys_added name_added desc_added voice_added
            changed=$(echo "$result" | awk -F'changed=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            file_changed=$(echo "$result" | awk -F'file_changed=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            keys_added=$(echo "$result" | awk -F'keys_added=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            name_added=$(echo "$result" | awk -F'name_added=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            desc_added=$(echo "$result" | awk -F'desc_added=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            voice_added=$(echo "$result" | awk -F'voice_added=' '/__MONSTER_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')

            changed=${changed:-0}
            file_changed=${file_changed:-0}
            keys_added=${keys_added:-0}
            name_added=${name_added:-0}
            desc_added=${desc_added:-0}
            voice_added=${voice_added:-0}

            if [ "$file_changed" -gt 0 ] 2>/dev/null && [[ "$file" == *.lua ]]; then
                if ! validate_lua_file "$file"; then
                    local backup="$backup_dir/$(basename "$file").bak"
                    [ -f "$backup" ] && cp "$backup" "$file"
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "monsters_validate" "monsters" "$file" "lua validation failed" "restored backup"
                    continue
                fi
            fi

            if [ "$changed" -gt 0 ] 2>/dev/null; then
                count=$((count + 1))
                total_keys_added=$((total_keys_added + keys_added))
                mark_file_completed "$file" "monsters" "$keys_added"
                log "   👹 ${base} (+$keys_added keys; name=$name_added desc=$desc_added voices=$voice_added)"
            fi

            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.xml" 2>/dev/null)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Monsters: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię spells
process_spells_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/spells.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/spells"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}✨ Processing spells...${NC}"
    
    for dir in data-otservbr-global/scripts/spells data/scripts/spells; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local base_title
            base_title=$(title_case "${base//_/ }")
            
            # NAPRAWIONE: Obsłuż nowy format spell:name("...") i spell:words("...")
            # oraz stary format words = "..." i description = "..."
            local name words desc
            name=$(py_regex_matches "$file" 'spell:name\s*\(\s*"([^"]+)"' 1)
            [ -z "$name" ] && name=$(py_regex_matches "$file" 'name\s*=\s*"([^"]+)"' 1)
            [ -z "$name" ] && name="$base_title"
            
            words=$(py_regex_matches "$file" 'spell:words\s*\(\s*"([^"]+)"' 1)
            [ -z "$words" ] && words=$(py_regex_matches "$file" 'words\s*=\s*"([^"]+)"' 1)
            
            desc=$(py_regex_matches "$file" 'spell:description\s*\(\s*"([^"]+)"' 1)
            [ -z "$desc" ] && desc=$(py_regex_matches "$file" 'description\s*=\s*"([^"]+)"' 1)
            
            local result rc
            result=$(python3 - "$json_file" "$safe" "$name" "$words" "$desc" << 'SPELLPY'
import json
import os
import shutil
import sys

json_file = sys.argv[1]
safe = sys.argv[2]
name = sys.argv[3]
words = sys.argv[4]
desc = sys.argv[5]

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

changed = False
keys_added = 0
name_added = 0
words_added = 0
desc_added = 0

def atomic_write(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

name_key = f"spell.{safe}.name"
if name and name_key not in data:
    data[name_key] = name
    keys_added += 1
    name_added += 1
    changed = True

words_key = f"spell.{safe}.words"
if words and words_key not in data:
    data[words_key] = words
    keys_added += 1
    words_added += 1
    changed = True

desc_key = f"spell.{safe}.desc"
if desc and desc_key not in data:
    data[desc_key] = desc
    keys_added += 1
    desc_added += 1
    changed = True

if changed:
    atomic_write(json_file, data)

print(
    f"__SPELL_RESULT__ keys_added={keys_added} "
    f"name_added={name_added} words_added={words_added} desc_added={desc_added}"
)
SPELLPY
)
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_json_update" "spells" "$file" "python json update failed" "skip mark"
                continue
            fi

            local keys_added name_added words_added desc_added
            keys_added=$(echo "$result" | awk -F'keys_added=' '/__SPELL_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            name_added=$(echo "$result" | awk -F'name_added=' '/__SPELL_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            words_added=$(echo "$result" | awk -F'words_added=' '/__SPELL_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            desc_added=$(echo "$result" | awk -F'desc_added=' '/__SPELL_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')

            keys_added=${keys_added:-0}
            name_added=${name_added:-0}
            words_added=${words_added:-0}
            desc_added=${desc_added:-0}

            local keys_added_total file_changed
            keys_added_total=$keys_added
            file_changed=0

            # FIZYCZNA MIGRACJA: sendTextMessage + :say + broadcastMessage w SPELLS
            local _out _rc

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "spell.${safe}" \
                    --backup-dir "$backup_dir" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_migrate_sendtext" "spells" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_validate_sendtext" "spells" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "spell.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_migrate_say" "spells" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_validate_say" "spells" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "spell.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_migrate_broadcast" "spells" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "spells_validate_broadcast" "spells" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if [ "$keys_added_total" -gt 0 ] 2>/dev/null || [ "$file_changed" -gt 0 ] 2>/dev/null; then
                mark_file_completed "$file" "spells" "$keys_added_total"
                count=$((count + 1))
                total_keys_added=$((total_keys_added + keys_added_total))
                log "   ✨ spell.$safe (+$keys_added_total keys; name=$name_added words=$words_added desc=$desc_added)"
            fi
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Spells: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię items (z XML)
process_items_category() {
    local batch="${1:-50}"
    local mini_batch="${MINI_BATCH:-10}"
    local mini_pause="${MINI_PAUSE:-3}"
    local json_file="$I18N_DIR/en/items.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🎒 Processing items (batch=$batch, mini=$mini_batch, pause=${mini_pause}s)...${NC}"
    
    # Items są głównie w XML
    local items_xml="data/items/items.xml"
    [ ! -f "$items_xml" ] && items_xml="data-otservbr-global/items/items.xml"
    
    if [ -f "$items_xml" ]; then
        # Przetwarzaj w mini-batch z pauzami
        local processed=0
        local total_added=0
        
        while [ $processed -lt $batch ]; do
            local current_mini=$mini_batch
            [ $((processed + mini_batch)) -gt $batch ] && current_mini=$((batch - processed))
            
            # Wyciągnij mini-batch itemów (name + desc)
            local result rc
            result=$(python3 - "$json_file" "$items_xml" "$current_mini" << 'PY'
import json
import os
import re
import shutil
import sys

json_file = sys.argv[1]
items_xml = sys.argv[2]
mini_batch = int(sys.argv[3])

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

try:
    with open(items_xml, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
except Exception:
    print("__ITEMS_RESULT__ keys_added=0 items_processed=0")
    sys.exit(1)

items = []
seen_ids = set()

block_pattern = re.compile(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"[^>]*>(.*?)</item>', re.DOTALL)
for m in block_pattern.finditer(content):
    item_id = m.group(1)
    name = m.group(2)
    block = m.group(3)
    desc = None
    desc_match = re.search(r'<attribute\s+key="description"\s+value="([^"]+)"', block)
    if desc_match:
        desc = desc_match.group(1)
    items.append((item_id, name, desc))
    seen_ids.add(item_id)

self_close_pattern = re.compile(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"[^>]*/>')
for m in self_close_pattern.finditer(content):
    item_id = m.group(1)
    if item_id in seen_ids:
        continue
    name = m.group(2)
    items.append((item_id, name, None))

candidates = []
for item_id, name, desc in items:
    need = False
    if name and f"item.{item_id}.name" not in data:
        need = True
    if desc and f"item.{item_id}.desc" not in data:
        need = True
    if need:
        candidates.append((item_id, name, desc))

batch_items = candidates[:mini_batch]
keys_added = 0
items_processed = 0

for item_id, name, desc in batch_items:
    added_any = False
    name_key = f"item.{item_id}.name"
    if name and name_key not in data:
        data[name_key] = name
        keys_added += 1
        added_any = True
    desc_key = f"item.{item_id}.desc"
    if desc and desc_key not in data:
        data[desc_key] = desc
        keys_added += 1
        added_any = True
    if added_any:
        items_processed += 1

def atomic_write(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

if keys_added > 0:
    atomic_write(json_file, data)

print(f"__ITEMS_RESULT__ keys_added={keys_added} items_processed={items_processed}")
PY
)
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "items_json_update" "items" "$items_xml" "python items update failed" "break"
                break
            fi
            local added items_done
            added=$(echo "$result" | awk -F'keys_added=' '/__ITEMS_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            items_done=$(echo "$result" | awk -F'items_processed=' '/__ITEMS_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            added=${added:-0}
            items_done=${items_done:-0}
            
            total_added=$((total_added + added))
            processed=$((processed + items_done))
            
            log "   📦 Mini-batch: +$added keys (items: $items_done, total keys: $total_added)"
            
            # Pauza między mini-batch (ale nie po ostatnim)
            if [ $processed -lt $batch ] && [ "$added" -gt 0 ]; then
                sleep $mini_pause
            fi
            
            # Jeśli nie dodano nic, zakończ wcześniej
            [ "$items_done" -eq 0 ] && break
        done
        
        log "${GREEN}✅ Items: +$total_added kluczy (items processed: $processed)${NC}"
    else
        log "${YELLOW}⚠️ Brak pliku items.xml${NC}"
    fi
}

# Przetwarzaj kategorię raids
process_raids_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/raids.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/raids"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}⚔️ Processing raids...${NC}"
    
    for dir in data-otservbr-global/raids data-canary/raids data/raids; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|xml\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local name=$(title_case "${base//_/ }")
            
            # Wyciągnij komunikaty raidów
            local announce=$(py_regex_matches "$file" '(?:broadcast|announce|message)[^"]*"([^"]+)"' 1)
            
            local result rc
            result=$(python3 - "$json_file" "$safe" "$name" "$announce" << 'RAIDSPY'
import json
import os
import shutil
import sys

json_file = sys.argv[1]
safe = sys.argv[2]
name = sys.argv[3]
announce = sys.argv[4]

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

changed = False
keys_added = 0
name_added = 0
announce_added = 0

def atomic_write(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

name_key = f"raid.{safe}.name"
if name and name_key not in data:
    data[name_key] = name
    keys_added += 1
    name_added += 1
    changed = True

announce_key = f"raid.{safe}.announce"
if announce and announce_key not in data:
    data[announce_key] = announce
    keys_added += 1
    announce_added += 1
    changed = True

if changed:
    atomic_write(json_file, data)

print(
    f"__RAID_RESULT__ keys_added={keys_added} "
    f"name_added={name_added} announce_added={announce_added}"
)
RAIDSPY
)
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_json_update" "raids" "$file" "python json update failed" "skip mark"
                continue
            fi
            
            local keys_added name_added announce_added
            keys_added=$(echo "$result" | awk -F'keys_added=' '/__RAID_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            name_added=$(echo "$result" | awk -F'name_added=' '/__RAID_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            announce_added=$(echo "$result" | awk -F'announce_added=' '/__RAID_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')

            keys_added=${keys_added:-0}
            name_added=${name_added:-0}
            announce_added=${announce_added:-0}

            local keys_added_total file_changed
            keys_added_total=$keys_added
            file_changed=0

            # FIZYCZNA MIGRACJA: sendTextMessage + :say + broadcastMessage w RAIDS (lua)
            if [[ "$file" == *.lua ]]; then
                local _out _rc
                if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "raid.${safe}" \
                        --backup-dir "$backup_dir" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_migrate_sendtext" "raids" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_validate_sendtext" "raids" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi

                if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_say.py \
                        --target creature \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "raid.${safe}" \
                        --backup-dir "$backup_dir" \
                        --suffix "say" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_migrate_say" "raids" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_validate_say" "raids" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi

                if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "raid.${safe}" \
                        --backup-dir "$backup_dir" \
                        --suffix "broadcast" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_migrate_broadcast" "raids" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "raids_validate_broadcast" "raids" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi
            fi

            if [ "$keys_added_total" -gt 0 ] 2>/dev/null || [ "$file_changed" -gt 0 ] 2>/dev/null; then
                mark_file_completed "$file" "raids" "$keys_added_total"
                count=$((count + 1))
                total_keys_added=$((total_keys_added + keys_added_total))
                log "   ⚔️ raid.$safe (+$keys_added_total keys; name=$name_added announce=$announce_added)"
            fi
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.xml" 2>/dev/null)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Raids: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię world (mapy, areas, wydarzenia)
process_world_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/world.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/world"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}🗺️ Processing world...${NC}"
    
    for dir in data-otservbr-global/world data-canary/world data/world; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            local result rc
            result=$(python3 - "$json_file" "$safe" "$file" << 'WORLDPY'
import json
import os
import re
import shutil
import sys

json_file = sys.argv[1]
safe = sys.argv[2]
file_path = sys.argv[3]

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

try:
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
except Exception:
    print("__WORLD_RESULT__ keys_added=0")
    sys.exit(1)

texts = []
for m in re.finditer(r'"([^"]{10,})"', content, re.DOTALL):
    val = m.group(1).strip()
    if len(val) > 5:
        texts.append(val)
    if len(texts) >= 5:
        break

prefix = f"world.{safe}.text"
existing = [k for k in data.keys() if k.startswith(prefix)]
max_idx = 0
for k in existing:
    m = re.match(rf"^{re.escape(prefix)}(\d+)$", k)
    if m:
        try:
            max_idx = max(max_idx, int(m.group(1)))
        except Exception:
            pass

keys_added = 0
idx = max_idx + 1
for text in texts:
    key = f"{prefix}{idx}"
    if key not in data:
        data[key] = text
        keys_added += 1
    idx += 1

def atomic_write(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

if keys_added > 0:
    atomic_write(json_file, data)

print(f"__WORLD_RESULT__ keys_added={keys_added}")
WORLDPY
)
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_json_update" "world" "$file" "python json update failed" "skip mark"
                continue
            fi

            local keys_added
            keys_added=$(echo "$result" | awk -F'keys_added=' '/__WORLD_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            keys_added=${keys_added:-0}

            local keys_added_total file_changed
            keys_added_total=$keys_added
            file_changed=0

            # FIZYCZNA MIGRACJA: sendTextMessage + :say + broadcastMessage w WORLD (lua)
            if [[ "$file" == *.lua ]]; then
                local _out _rc
                if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "world.${safe}" \
                        --backup-dir "$backup_dir" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_migrate_sendtext" "world" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_validate_sendtext" "world" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi

                if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_say.py \
                        --target creature \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "world.${safe}" \
                        --backup-dir "$backup_dir" \
                        --suffix "say" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_migrate_say" "world" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_validate_say" "world" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi

                if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                    _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                        --file "$file" \
                        --json "$json_file" \
                        --key-prefix "world.${safe}" \
                        --backup-dir "$backup_dir" \
                        --suffix "broadcast" \
                        2>&1)
                    _rc=$?
                    if [ "$_rc" -ne 0 ]; then
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_migrate_broadcast" "world" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                    else
                        local k fc
                        k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                        fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                        k=${k:-0}
                        fc=${fc:-0}
                        keys_added_total=$((keys_added_total + k))
                        if [ "$fc" = "1" ]; then
                            file_changed=1
                            if ! validate_lua_file "$file"; then
                                restore_backup_file "$file"
                                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "world_validate_broadcast" "world" "$file" "lua validation failed" "restored backup"
                            fi
                        fi
                    fi
                fi
            fi
            
            if [ "$keys_added_total" -gt 0 ] 2>/dev/null || [ "$file_changed" -gt 0 ] 2>/dev/null; then
                mark_file_completed "$file" "world" "$keys_added_total"
                count=$((count + 1))
                total_keys_added=$((total_keys_added + keys_added_total))
                log "   🗺️ world.$safe (+$keys_added_total keys)"
            fi

            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ World: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię libs
process_libs_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/libs.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📚 Processing libs...${NC}"
    
    for dir in data/libs data-otservbr-global/lib data-canary/lib; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            # Wyciągnij stringi z bibliotek
            local strings=$(py_regex_matches "$file" 'sendTextMessage\s*\([^,]+,\s*"([^"]+)"' 5)
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            if [ -n "$strings" ]; then
                local i=1
                local json_ok=1
                while IFS= read -r str; do
                    if [ -n "$str" ] && [ ${#str} -gt 5 ]; then
                        if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['lib.$safe.msg$i'] = '''$str'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                            i=$((i + 1))
                        else
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_json_update" "libs" "$file" "python json update failed" "skip mark"
                            json_ok=0
                            break
                        fi
                    fi
                done <<< "$strings"
                if [ "$json_ok" -eq 0 ]; then
                    continue
                fi
                count=$((count + 1))
            fi

            # FIZYCZNA MIGRACJA: sendTextMessage + :say w LIBS
            local _out _rc keys_added_total
            keys_added_total=0

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "lib.${safe}" \
                    --backup-dir "$BACKUP_DIR/libs" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_migrate_sendtext" "libs" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_validate_sendtext" "libs" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "lib.${safe}" \
                    --backup-dir "$BACKUP_DIR/libs" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_migrate_say" "libs" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_validate_say" "libs" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "lib.${safe}" \
                    --backup-dir "$BACKUP_DIR/libs" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_migrate_broadcast" "libs" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "libs_validate_broadcast" "libs" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi
            
            mark_file_completed "$file" "libs" "$keys_added_total"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Libs: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię events
process_events_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/events.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🎉 Processing events...${NC}"
    
    for dir in data/events data-otservbr-global/events; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij komunikaty eventów
            local messages=$(py_regex_matches "$file" '"([^"]{10,})"' 5)
            
            if [ -n "$messages" ]; then
                if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}

texts = '''$messages'''.strip().split('\n')
for i, t in enumerate(texts[:5]):
    t = t.strip('\"')
    if len(t) > 5:
        d[f'event.$safe.msg{i+1}'] = t
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                    count=$((count + 1))
                else
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_json_update" "events" "$file" "python json update failed" "skip mark"
                    continue
                fi
            fi

            # FIZYCZNA MIGRACJA: sendTextMessage + :say w EVENTS
            local _out _rc keys_added_total
            keys_added_total=0

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "event.${safe}" \
                    --backup-dir "$BACKUP_DIR/events" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_migrate_sendtext" "events" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_validate_sendtext" "events" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "event.${safe}" \
                    --backup-dir "$BACKUP_DIR/events" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_migrate_say" "events" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_validate_say" "events" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "event.${safe}" \
                    --backup-dir "$BACKUP_DIR/events" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_migrate_broadcast" "events" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "events_validate_broadcast" "events" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi
            
            mark_file_completed "$file" "events" "$keys_added_total"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Events: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię chatchannels
process_chatchannels_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/chatchannels.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/chatchannels"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}💬 Processing chatchannels...${NC}"
    
    for dir in data/chatchannels data-otservbr-global/chatchannels; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local base_title
            base_title=$(title_case "${base//_/ }")
            local name
            name=$(py_regex_matches "$file" '(?:channel\.)?name\s*=\s*"([^"]+)"' 1)
            [ -z "$name" ] && name="$base_title"
            
            local result rc
            result=$(python3 - "$json_file" "$safe" "$name" << 'CHATPY'
import json
import os
import shutil
import sys

json_file = sys.argv[1]
safe = sys.argv[2]
name = sys.argv[3]

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

changed = False
keys_added = 0

def atomic_write(path, payload):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, path)

name_key = f"channel.{safe}.name"
if name and name_key not in data:
    data[name_key] = name
    keys_added += 1
    changed = True

if changed:
    atomic_write(json_file, data)

print(f"__CHAT_RESULT__ keys_added={keys_added}")
CHATPY
)
            rc=$?
            if [ "$rc" -ne 0 ]; then
                status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_json_update" "chatchannels" "$file" "python json update failed" "skip mark"
                continue
            fi
            
            local keys_added
            keys_added=$(echo "$result" | awk -F'keys_added=' '/__CHAT_RESULT__/{print $2}' | awk '{print $1}' | tr -dc '0-9')
            keys_added=${keys_added:-0}

            local keys_added_total file_changed
            keys_added_total=$keys_added
            file_changed=0

            # FIZYCZNA MIGRACJA: sendTextMessage + :say + broadcastMessage w CHATCHANNELS
            local _out _rc
            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "channel.${safe}" \
                    --backup-dir "$backup_dir" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_migrate_sendtext" "chatchannels" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_validate_sendtext" "chatchannels" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "channel.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_migrate_say" "chatchannels" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_validate_say" "chatchannels" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "channel.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_migrate_broadcast" "chatchannels" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        file_changed=1
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "chatchannels_validate_broadcast" "chatchannels" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if [ "$keys_added_total" -gt 0 ] 2>/dev/null || [ "$file_changed" -gt 0 ] 2>/dev/null; then
                mark_file_completed "$file" "chatchannels" "$keys_added_total"
                count=$((count + 1))
                total_keys_added=$((total_keys_added + keys_added_total))
                log "   💬 channel.$safe (+$keys_added_total keys)"
            fi
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Chatchannels: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię modules
process_modules_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/modules.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📦 Processing modules...${NC}"
    
    for dir in data/modules data-otservbr-global/modules; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij teksty z modułów
            local texts=$(py_regex_matches "$file" '"([^"]{10,})"' 5)
            
            if [ -n "$texts" ]; then
                if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}

texts = '''$texts'''.strip().split('\n')
for i, t in enumerate(texts[:5]):
    t = t.strip('\"')
    if len(t) > 5:
        d[f'module.$safe.text{i+1}'] = t
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                    count=$((count + 1))
                else
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_json_update" "modules" "$file" "python json update failed" "skip mark"
                    continue
                fi
            fi

            # FIZYCZNA MIGRACJA: sendTextMessage + :say w MODULES
            local _out _rc keys_added_total
            keys_added_total=0

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "module.${safe}" \
                    --backup-dir "$BACKUP_DIR/modules" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_migrate_sendtext" "modules" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_validate_sendtext" "modules" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "module.${safe}" \
                    --backup-dir "$BACKUP_DIR/modules" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_migrate_say" "modules" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_validate_say" "modules" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "module.${safe}" \
                    --backup-dir "$BACKUP_DIR/modules" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_migrate_broadcast" "modules" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "modules_validate_broadcast" "modules" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi
            
            mark_file_completed "$file" "modules" "$keys_added_total"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Modules: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię startup
process_startup_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/startup.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🚀 Processing startup...${NC}"
    
    for dir in data-otservbr-global/startup data-canary/startup; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij komunikaty startowe
            local messages=$(py_regex_matches "$file" 'print\s*\(\s*"([^"]+)"' 5)
            [ -z "$messages" ] && messages=$(py_regex_matches "$file" '"([^"]{10,})"' 5)
            
            if [ -n "$messages" ]; then
                if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}

texts = '''$messages'''.strip().split('\n')
for i, t in enumerate(texts[:5]):
    t = t.strip('\"')
    if len(t) > 5:
        d[f'startup.$safe.msg{i+1}'] = t
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                    count=$((count + 1))
                else
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_json_update" "startup" "$file" "python json update failed" "skip mark"
                    continue
                fi
            fi

            # FIZYCZNA MIGRACJA: sendTextMessage + :say w STARTUP
            local _out _rc keys_added_total
            keys_added_total=0

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "startup.${safe}" \
                    --backup-dir "$BACKUP_DIR/startup" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_migrate_sendtext" "startup" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_validate_sendtext" "startup" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "startup.${safe}" \
                    --backup-dir "$BACKUP_DIR/startup" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_migrate_say" "startup" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_validate_say" "startup" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "startup.${safe}" \
                    --backup-dir "$BACKUP_DIR/startup" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_migrate_broadcast" "startup" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "startup_validate_broadcast" "startup" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi
            
            mark_file_completed "$file" "startup" "$keys_added_total"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Startup: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię npclib
process_npclib_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/npclib.json"
    local count=0
    local total_keys_added=0
    local backup_dir="$BACKUP_DIR/npclib"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    mkdir -p "$backup_dir" 2>/dev/null
    
    log "${CYAN}📖 Processing npclib...${NC}"
    
    for dir in data/npclib; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij stałe tekstowe z biblioteki NPC
            local strings=$(py_regex_matches "$file" '(?:TEXT_|MSG_)[A-Z_]+\s*=\s*"([^"]+)"' 10)
            
            if [ -n "$strings" ]; then
                local i=1
                local json_ok=1
                while IFS= read -r str; do
                    if [ -n "$str" ] && [ ${#str} -gt 3 ]; then
                        if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['npclib.$safe.const$i'] = '''$str'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                            i=$((i + 1))
                        else
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_json_update" "npclib" "$file" "python json update failed" "skip mark"
                            json_ok=0
                            break
                        fi
                    fi
                done <<< "$strings"
                if [ "$json_ok" -eq 0 ]; then
                    continue
                fi
                count=$((count + 1))
            fi

            # FIZYCZNA MIGRACJA: sendTextMessage + :say + broadcastMessage w NPCLIB
            local _out _rc keys_added_total
            keys_added_total=0

            if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_sendtext.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "npclib.${safe}" \
                    --backup-dir "$backup_dir" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_migrate_sendtext" "npclib" "$file" "i18n_migrate_lua_sendtext.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_validate_sendtext" "npclib" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE ':say\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_say.py \
                    --target creature \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "npclib.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "say" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_migrate_say" "npclib" "$file" "i18n_migrate_lua_say.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_validate_say" "npclib" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if grep -qE 'broadcastMessage\s*\(' "$file" 2>/dev/null; then
                _out=$(python3 tools/i18n_migrate_lua_broadcast.py \
                    --file "$file" \
                    --json "$json_file" \
                    --key-prefix "npclib.${safe}" \
                    --backup-dir "$backup_dir" \
                    --suffix "broadcast" \
                    2>&1)
                _rc=$?
                if [ "$_rc" -ne 0 ]; then
                    status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_migrate_broadcast" "npclib" "$file" "i18n_migrate_lua_broadcast.py failed" "rc=$_rc"
                else
                    local k fc
                    k=$(echo "$_out" | grep -oE 'keys_added=[0-9]+' | tail -n 1 | cut -d= -f2)
                    fc=$(echo "$_out" | grep -oE 'file_changed=[01]' | tail -n 1 | cut -d= -f2)
                    k=${k:-0}
                    fc=${fc:-0}
                    keys_added_total=$((keys_added_total + k))
                    if [ "$fc" = "1" ]; then
                        if ! validate_lua_file "$file"; then
                            restore_backup_file "$file"
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "npclib_validate_broadcast" "npclib" "$file" "lua validation failed" "restored backup"
                        fi
                    fi
                fi
            fi

            if [ "$keys_added_total" -gt 0 ] 2>/dev/null; then
                total_keys_added=$((total_keys_added + keys_added_total))
            fi

            mark_file_completed "$file" "npclib" "$keys_added_total"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ NpcLib: pliki=$count, klucze=$total_keys_added${NC}"
    echo "$count"
}

# Przetwarzaj kategorię PHP (html_copy - strona WWW)
process_php_category() {
    local batch="${1:-5}"
    local json_file="$I18N_DIR/en/php.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🐘 Processing PHP (html_copy)...${NC}"
    
    while IFS= read -r file; do
        [ -f "$file" ] || continue
        
        # Pomiń jeśli już używa __(
        grep -q "__(" "$file" 2>/dev/null && continue
        
        local base=$(basename "$file" .php)
        local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
        
        # Wyciągnij kandydatów ze stringów, odfiltruj kod/ścieżki/URL/SQL
        local strings=$(python3 - "$file" << 'PYCODE'
import re, sys
from pathlib import Path

if len(sys.argv) < 2:
    sys.exit(0)
path = Path(sys.argv[1])
try:
    text = path.read_text(encoding="utf-8", errors="ignore")
except Exception:
    sys.exit(0)
res = []
for m in re.finditer(r'"([^"\n]{15,})"', text):
    val = m.group(1).strip()
    if len(val) < 15:
        continue
    low = val.lower()
    if low.startswith(("http", "/", "./", "../")):
        continue
    if any(tok in val for tok in ["$_", "$this", "<?php", "->", "::", "<?", "?>", "{", "}", "[", "]", "(", ")", ";", "=", ":"]):
        continue
    if any(ext in low for ext in [".php", ".js", ".css", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".ttf", ".woff", ".otf", ".map"]):
        continue
    if re.search(r"\\b(SELECT|INSERT|UPDATE|DELETE|FROM|WHERE|JOIN|ORDER BY)\\b", val, re.IGNORECASE):
        continue
    res.append(val[:200])
for line in res[:5]:
    print(line)
PYCODE
)
        
        if [ -n "$strings" ]; then
            local i=1
            local keys_added_file=0
            local json_ok=1
            while IFS= read -r str; do
                str=$(echo "$str" | tr -d '"'"'" | head -c 200)
                if [ -n "$str" ] && [ ${#str} -gt 15 ]; then
                    if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'php.$safe.text$i'
if key not in d:
    d[key] = '''$str'''[:200]
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                        i=$((i + 1))
                        keys_added_file=$((keys_added_file + 1))
                    else
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "php_json_update" "php" "$file" "python json update failed" "skip mark"
                        json_ok=0
                        break
                    fi
                fi
            done <<< "$strings"
            if [ "$json_ok" -eq 0 ]; then
                continue
            fi
            count=$((count + 1))
        fi
        
        mark_file_completed "$file" "php" "${keys_added_file:-0}"
        [ "$count" -ge "$batch" ] && break
    done < <(find html_copy -name "*.php" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -n "$(sanitize_batch "$batch" 5)")
    
    log "${GREEN}✅ PHP: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię HTML/Twig
process_html_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/html.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📄 Processing HTML/Twig...${NC}"
    
    while IFS= read -r file; do
        [ -f "$file" ] || continue
        
        local base=$(basename "$file" | sed 's/\.\(html\|twig\)$//')
        local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
        
        # Wyciągnij teksty między tagami
        local strings=$(py_regex_matches "$file" '>([^<]{20,})<' 5 | tr -d '><')
        
        if [ -n "$strings" ]; then
            local i=1
            local keys_added_file=0
            local json_ok=1
            while IFS= read -r str; do
                str=$(echo "$str" | head -c 200)
                if [ -n "$str" ] && [ ${#str} -gt 15 ]; then
                    if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'html.$safe.text$i'
if key not in d:
    d[key] = '''$str'''[:200]
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                        i=$((i + 1))
                        keys_added_file=$((keys_added_file + 1))
                    else
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "html_json_update" "html" "$file" "python json update failed" "skip mark"
                        json_ok=0
                        break
                    fi
                fi
            done <<< "$strings"
            if [ "$json_ok" -eq 0 ]; then
                continue
            fi
            count=$((count + 1))
        fi
        
        mark_file_completed "$file" "html" "${keys_added_file:-0}"
        [ "$count" -ge "$batch" ] && break
    done < <(find html_copy -name "*.html" -o -name "*.twig" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
    
    log "${GREEN}✅ HTML: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię C++ (src)
process_cpp_category() {
    local batch="${1:-5}"
    local json_file="$I18N_DIR/en/cpp.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}⚙️ Processing C++ (src)...${NC}"
    
    while IFS= read -r file; do
        [ -f "$file" ] || continue
        
        local base=$(basename "$file" | sed 's/\.\(cpp\|hpp\)$//')
        local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
        
        # Wyciągnij stringi > 10 znaków
        # FILTRUJ: pomiń kod, formaty, ścieżki
        local strings=$(py_regex_matches "$file" '"([^"]{10,100})"' 5 \
            | tr -d '"' \
            | grep -v '%' \
            | grep -v '\\' \
            | grep -v '::' \
            | grep -v '->' \
            | grep -v '/' \
            | grep -v '\.' \
            | grep -v '_' \
            | head -5)
        
        if [ -n "$strings" ]; then
            local i=1
            local keys_added_file=0
            local json_ok=1
            while IFS= read -r str; do
                # Tylko tekst z literami i spacjami, bez camelCase
                if [ -n "$str" ] && [ ${#str} -gt 8 ] && [[ "$str" =~ [a-zA-Z].*[[:space:]].*[a-zA-Z] ]]; then
                    if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'cpp.$safe.str$i'
if key not in d:
    d[key] = '''$str'''
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                        i=$((i + 1))
                        keys_added_file=$((keys_added_file + 1))
                    else
                        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "cpp_json_update" "cpp" "$file" "python json update failed" "skip mark"
                        json_ok=0
                        break
                    fi
                fi
            done <<< "$strings"
            if [ "$json_ok" -eq 0 ]; then
                continue
            fi
            count=$((count + 1))
        fi
        
        mark_file_completed "$file" "cpp" "${keys_added_file:-0}"
        [ "$count" -ge "$batch" ] && break
    done < <(find src -name "*.cpp" -o -name "*.hpp" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -n "$(sanitize_batch "$batch" 5)")
    
    log "${GREEN}✅ C++: $count plików${NC}"
    echo "$count"
}

# Przetwarzaj kategorię OTClient (testyy)
process_client_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/client.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🎮 Processing OTClient (testyy)...${NC}"
    
    for dir in testyy/modules testyy/mods; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|otui\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij stringi (pomiń tr() i techniczne ścieżki/kod)
            local strings=$(python3 - "$file" << 'PYCODE'
import re, sys
from pathlib import Path

if len(sys.argv) < 2:
    sys.exit(0)
path = Path(sys.argv[1])
try:
    text = path.read_text(encoding="utf-8", errors="ignore")
except Exception:
    sys.exit(0)
res = []
for m in re.finditer(r'"([^"\n]{8,})"', text):
    val = m.group(1).strip()
    if val.startswith("tr(") or val.startswith("tr\""):
        continue
    if val.startswith(("http", "/", "./", "../")):
        continue
    if any(tok in val for tok in ["{", "}", "[", "]", "(", ")", "::", "->", "%", "_", "$"]):
        continue
    if any(ext in val for ext in [".lua", ".otui", ".png", ".ogg", ".wav", ".ttf"]):
        continue
    if len(val) < 8:
        continue
    res.append(val[:200])
for line in res[:5]:
    print(line)
PYCODE
)
            
            if [ -n "$strings" ]; then
                local i=1
                local keys_added_file=0
                local json_ok=1
                while IFS= read -r str; do
                    # Pomiń jeśli wygląda jak kod lub nazwa pliku
                    if [ -n "$str" ] && [ ${#str} -gt 8 ] && [[ ! "$str" =~ ^[a-z]+[A-Z] ]] && [[ ! "$str" =~ ^[A-Z_]+$ ]]; then
                        if python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'client.$safe.text$i'
if key not in d:
    d[key] = '''$str'''
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"; then
                            i=$((i + 1))
                            keys_added_file=$((keys_added_file + 1))
                        else
                            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "client_json_update" "client" "$file" "python json update failed" "skip mark"
                            json_ok=0
                            break
                        fi
                    fi
                done <<< "$strings"
                if [ "$json_ok" -eq 0 ]; then
                    continue
                fi
                count=$((count + 1))
            fi
            
            mark_file_completed "$file" "client" "${keys_added_file:-0}"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.otui" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -n "$(sanitize_batch "$batch" 10)")
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Client: $count plików${NC}"
    echo "$count"
}

#===============================================================================
# NOWA KATEGORIA: sendTextMessage → sendLocalizedTextMessage
#===============================================================================
# Zamienia player:sendTextMessage(TYPE, "text") na sendLocalizedTextMessage
# z kluczami w messages.json
#===============================================================================
process_sendTextMessage_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/messages.json"
    local count=0
    local modified=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📨 Processing sendTextMessage patterns...${NC}"

    # Dodaj klucz do messages.json jeśli nie istnieje
    if ! python3 << 'MSGPY'
import json
json_file = "i18n/en/messages.json"
try:
    with open(json_file) as f:
        data = json.load(f)
except:
    data = {}

# Kluczowe wiadomości systemowe
keys = {
    "system.trade.sold": "Sold {1}x {2} for {3} gold.",
    "system.trade.bought": "Bought {1}x {2} for {3} gold.",
    "system.blessing.already": "You are already blessed.",
    "system.blessing.received": "You received the remaining {1} blesses.",
    "system.experience.gained": "You gained {1} experience points.",
    "system.item.received": "You gained a {1}.",
    "system.mount.received": "Congratulations you received the {1} mount.",
    "system.store.check_inbox": "Please make sure you have free slots in your store inbox.",
    "system.venture.decay": "Venture the path of decay!"
}

added = 0
for key, value in keys.items():
    if key not in data:
        data[key] = value
        added += 1

with open(json_file, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

if added > 0:
    print(f"   📝 Dodano {added} kluczy do messages.json")
MSGPY
    then
        status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "messages_seed" "messages" "$json_file" "python json seed failed" "continue without seed"
    fi

    local marker_prefix="STM:"
    local max_modified
    max_modified=$(sanitize_batch "$batch" 10)

    while IFS= read -r -d '' file; do
        [ -f "$file" ] || continue

        local marker="${marker_prefix}${file}"
        if grep -qF "$marker" "$PROCESSED_FILE" 2>/dev/null; then
            continue
        fi

        local _out _rc
        _out=$(python3 - "$file" << 'PYCODE'
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    text = path.read_text(encoding="utf-8", errors="ignore")
except Exception:
    sys.exit(2)

replacements = [
    (
        'player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))',
        'player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})',
    ),
    (
        'player:sendTextMessage(MESSAGE_STATUS, "You are already blessed.")',
        'player:sendLocalizedTextMessage(MESSAGE_STATUS, "system.blessing.already")',
    ),
    (
        'player:sendTextMessage(MESSAGE_GAME_HIGHLIGHT, "Venture the path of decay!")',
        'player:sendLocalizedTextMessage(MESSAGE_GAME_HIGHLIGHT, "system.venture.decay")',
    ),
]

new_text = text
changed = False
for old, new in replacements:
    if old in new_text:
        new_text = new_text.replace(old, new)
        changed = True

if changed:
    path.write_text(new_text, encoding="utf-8")
    print("modified=1")
else:
    print("modified=0")
PYCODE
)
        _rc=$?
        if [ "$_rc" -ne 0 ]; then
            status_log_error "${CYCLE:-0}" "${MODE_TYPE:-MIGRATION}" "sendtext_replace" "sendtext" "$file" "python replace failed" "skip mark"
            continue
        fi

        if echo "$_out" | grep -q "modified=1"; then
            modified=$((modified + 1))
            log "   sendTextMessage: $(basename "$file")"
        fi

        echo "$marker" >> "$PROCESSED_FILE"
        count=$((count + 1))
        [ "$modified" -ge "$max_modified" ] && break
    done < <(find data-otservbr-global/npc -name "*.lua" -print0 2>/dev/null)
    
    log "${GREEN}✅ sendTextMessage: $modified plików zmodyfikowanych${NC}"
}

#===============================================================================
# NOWA KATEGORIA: keywordHandler bez i18nKey
#===============================================================================
# Przetwarza keywordHandler:addKeyword które mają text = {...} bez i18nKey
# Dodaje klucze do npc.json i transformuje Lua
#===============================================================================
process_keywordHandler_category() {
    local batch="${1:-5}"
    local json_file="$I18N_DIR/en/npc.json"
    local count=0
    local modified=0
    
    log "${CYAN}🔑 Processing keywordHandler without i18nKey...${NC}"
    
    # Python script do przetwarzania plików
    local max_batch
    max_batch=$(sanitize_batch "$batch" 5)
    python3 - "$max_batch" << 'KWPY'
import json
import re
import os
import sys

BATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 5
json_file = "i18n/en/npc.json"
processed_file = "i18n_processed_files.txt"

# Wczytaj JSON
try:
    with open(json_file) as f:
        npc_data = json.load(f)
except:
    npc_data = {}

# Wczytaj przetworzone pliki
processed = set()
try:
    with open(processed_file) as f:
        processed = set(line.strip() for line in f)
except:
    pass

modified_count = 0
keys_added = 0

# Znajdź pliki NPC z keywordHandler bez i18nKey
npc_dir = "data-otservbr-global/npc"
for filename in os.listdir(npc_dir):
    if not filename.endswith('.lua'):
        continue
    
    filepath = os.path.join(npc_dir, filename)
    marker = f"KWH:{filepath}"
    
    if marker in processed:
        continue
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except:
        continue
    
    # Szukaj keywordHandler:addKeyword bez i18nKey
    # Pattern: keywordHandler:addKeyword({ "word" }, StdModule.say, {\n\tnpcHandler = npcHandler,\n\ttext = {...}\n})
    pattern = r'keywordHandler:addKeyword\(\s*\{\s*"([^"]+)"\s*\}\s*,\s*StdModule\.say\s*,\s*\{\s*npcHandler\s*=\s*npcHandler\s*,\s*text\s*=\s*\{([^}]+)\}\s*,?\s*\}\)'
    
    matches = list(re.finditer(pattern, content, re.DOTALL))
    
    if not matches:
        continue
    
    # Sprawdź czy już ma i18nKey
    has_i18n = 'i18nKey' in content
    needs_work = False
    
    for match in matches:
        full_match = match.group(0)
        if 'i18nKey' not in full_match:
            needs_work = True
            break
    
    if not needs_work:
        continue
    
    npc_name = filename.replace('.lua', '').lower().replace(' ', '_').replace('-', '_')
    new_content = content
    local_keys_added = 0
    
    for i, match in enumerate(matches):
        keyword = match.group(1)
        text_block = match.group(2)
        full_match = match.group(0)
        
        # Już ma i18nKey?
        if 'i18nKey' in full_match:
            continue
        
        # Wyciągnij teksty z tablicy
        texts = re.findall(r'"([^"]+)"', text_block)
        
        if not texts:
            continue
        
        # Utwórz klucz
        safe_kw = keyword.lower().replace(' ', '_')
        base_key = f"npc.{npc_name}.kw_{safe_kw}"
        
        # Dla wielu tekstów - utwórz array key
        if len(texts) == 1:
            key = base_key
            npc_data[key] = texts[0]
            keys_added += 1
            local_keys_added += 1
        else:
            # Wiele tekstów - dodaj jako array_1, array_2, ...
            for j, txt in enumerate(texts, 1):
                key = f"{base_key}_{j}"
                npc_data[key] = txt
                keys_added += 1
                local_keys_added += 1
        
        # Transformacja - dodaj i18nKey do istniejącego kodu
        # Zamień text = {...} na text = {...}, i18nKey = "..."
        if len(texts) == 1:
            new_text_block = f'text = "{texts[0]}", i18nKey = "{base_key}"'
        else:
            # Dla array, tworzymy nowy format
            new_text_block = f'text = {{{text_block}}}, i18nKey = "{base_key}_1"'
        
        # Prostsza zamiana - dodaj i18nKey przed zamknięciem
        old_ending = 'npcHandler = npcHandler,'
        if old_ending in full_match:
            # Znajdź pozycję i wstaw i18nKey
            pass  # Skomplikowane, pomińmy transformację na razie
    
    # Zapisz klucze (transformacja plików w następnej wersji)
    if local_keys_added > 0:
        print(f"   🔑 {filename}: +{local_keys_added} kluczy")
        modified_count += 1
        
        # Oznacz jako częściowo przetworzony (klucze wyciągnięte)
        with open(processed_file, 'a') as f:
            f.write(f"{marker}\n")
    
    if modified_count >= BATCH:
        break

# Zapisz JSON
with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(npc_data, f, indent=2, ensure_ascii=False)

print(f"   📊 Razem: {modified_count} plików, +{keys_added} kluczy")
KWPY
    
    log "${GREEN}✅ keywordHandler: Przetworzono${NC}"
}

#===============================================================================
# NOWA KATEGORIA: Twig templates
#===============================================================================
# Ekstrahuje teksty z plików .twig do html.json
# Później można ręcznie zastąpić przez {{ 'key'|trans }}
#===============================================================================
process_twig_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/html.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🎨 Processing Twig templates...${NC}"
    
    local max_batch
    max_batch=$(sanitize_batch "$batch" 10)
    python3 - "$max_batch" << 'TWIGPY'
import json
import re
import os
import sys

BATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 10
json_file = "i18n/en/html.json"
processed_file = "i18n_processed_files.txt"

# Wczytaj JSON
try:
    with open(json_file) as f:
        html_data = json.load(f)
except:
    html_data = {}

# Wczytaj przetworzone pliki
processed = set()
try:
    with open(processed_file) as f:
        processed = set(line.strip() for line in f)
except:
    pass

modified_count = 0
keys_added = 0

# Znajdź pliki Twig
twig_dirs = ['html_copy/system/templates', 'html_copy/admin/pages', 'html_copy/templates']

for twig_dir in twig_dirs:
    if not os.path.isdir(twig_dir):
        continue
    
    for root, dirs, files in os.walk(twig_dir):
        for filename in files:
            if not filename.endswith('.twig'):
                continue
            
            filepath = os.path.join(root, filename)
            marker = f"TWIG:{filepath}"
            
            if marker in processed:
                continue
            
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
            except:
                continue
            
            # Pomiń jeśli już ma trans()
            if '|trans' in content:
                continue
            
            # Wyciągnij teksty:
            # 1. {% set title = 'Text' %}
            # 2. <b>Text</b>, <td>Text</td>, etc.
            # 3. Hardcoded stringi w HTML
            
            tpl_name = filename.replace('.html.twig', '').replace('.twig', '').lower().replace(' ', '_').replace('-', '_')
            local_keys = 0
            
            # Pattern 1: {% set var = 'text' %}
            set_matches = re.findall(r"\{%\s*set\s+\w+\s*=\s*'([^']+)'\s*%\}", content)
            for i, text in enumerate(set_matches, 1):
                if len(text) > 3 and not text.startswith('{') and not text.startswith('/'):
                    key = f"web.tpl.{tpl_name}.set_{i}"
                    if key not in html_data:
                        html_data[key] = text
                        keys_added += 1
                        local_keys += 1
            
            # Pattern 2: <b>Text</b>, <td>Text</td>, <span>Text</span>
            tag_matches = re.findall(r'<(b|td|th|span|label|h[1-6])>([^<>{]+)</\1>', content)
            for i, (tag, text) in enumerate(tag_matches, 1):
                text = text.strip()
                if len(text) > 2 and text not in ['&nbsp;', '']:
                    key = f"web.tpl.{tpl_name}.{tag}_{i}"
                    if key not in html_data:
                        html_data[key] = text
                        keys_added += 1
                        local_keys += 1
            
            if local_keys > 0:
                print(f"   🎨 {filename}: +{local_keys} kluczy")
                modified_count += 1
                
                with open(processed_file, 'a') as f:
                    f.write(f"{marker}\n")
            
            if modified_count >= BATCH:
                break
        
        if modified_count >= BATCH:
            break
    
    if modified_count >= BATCH:
        break

# Zapisz JSON
with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(html_data, f, indent=2, ensure_ascii=False)

print(f"   📊 Razem: {modified_count} plików, +{keys_added} kluczy")
TWIGPY
    
    log "${GREEN}✅ Twig: Przetworzono${NC}"
}

#===============================================================================
# PROCESS_GENERIC_CATEGORY - Generyczna funkcja dla nowych kategorii
#===============================================================================
# Obsługuje kategorie: actions, quests, talkactions, movements, creaturescripts,
# globalevents, mounts, dataroot, server
#===============================================================================
process_generic_category() {
    local category="$1"
    local BATCH="${2:-10}"
    
    log "${CYAN}📂 GENERIC CATEGORY: $category (batch: $BATCH)${NC}"
    
    python3 << GENERICPY
import json
import os
import re
import glob
import subprocess

category = "$category"
BATCH = int("$BATCH")
I18N_DIR = "i18n"
PROCESSED_FILE = "i18n_processed_files.txt"

# Wczytaj definicję kategorii z pliku Python w dispatcherze
# Albo użyj prostszego podejścia - hardcoded dirs
CATEGORY_DIRS = {
    "actions": ["data-otservbr-global/scripts/actions", "data-canary/scripts/actions"],
    "quests": ["data-otservbr-global/scripts/quests", "data-canary/scripts/quests"],
    "talkactions": ["data-otservbr-global/scripts/talkactions", "data-canary/scripts/talkactions"],
    "movements": ["data-otservbr-global/scripts/movements", "data-canary/scripts/movements"],
    "creaturescripts": ["data-otservbr-global/scripts/creaturescripts", "data-canary/scripts/creaturescripts"],
    "globalevents": ["data-otservbr-global/scripts/globalevents", "data-canary/scripts/globalevents"],
    "mounts": ["data/XML"],
    "dataroot": ["data"],
    "server": ["src"],

    # OTClient/Testyy (instalka)
    "otclient_modules": ["testyy/modules"],
    "otclient_mods": ["testyy/mods"],
    "otclient_data": ["testyy/data"],
    "otclient_tools": ["testyy/tools"],
    "otclient_src": ["testyy/src"],
}

dirs = CATEGORY_DIRS.get(category, [])
if not dirs:
    print(f"   ⚠️ Brak definicji katalogów dla: {category}")
    exit(0)

# Wczytaj już przetworzone pliki
processed = set()
if os.path.exists(PROCESSED_FILE):
    with open(PROCESSED_FILE) as f:
        processed = set(line.strip() for line in f)

repeat_categories = {
    "actions",
    "quests",
    "talkactions",
    "movements",
    "creaturescripts",
    "globalevents",
}

# Wczytaj/stwórz JSON dla kategorii
json_file = f"{I18N_DIR}/en/{category}.json"
if os.path.exists(json_file):
    with open(json_file) as f:
        data = json.load(f)
else:
    data = {}

keys_added = 0
files_processed = 0

# Rozszerzenia plików
if category in ["mounts"]:
    extensions = [".xml"]
elif category in ["server", "otclient_src"]:
    extensions = [".cpp", ".hpp"]
elif category.startswith("otclient_"):
    extensions = [".lua", ".otui", ".otmod"]
else:
    extensions = [".lua"]

for dir_path in dirs:
    if not os.path.isdir(dir_path):
        continue
    
    # Dla dataroot - tylko główny folder
    if category == "dataroot":
        files = [f for f in os.listdir(dir_path) if f.endswith('.lua')]
        files = [os.path.join(dir_path, f) for f in files]
    else:
        files = []
        for ext in extensions:
            files.extend(glob.glob(f"{dir_path}/**/*{ext}", recursive=True))
    
    for filepath in files:
        # Pomiń backupy / stare kopie
        if '/backups/' in filepath or filepath.endswith('.bak') or '/styles.bak/' in filepath:
            continue
        marker = f"{category.upper()}:{filepath}"
        if category not in repeat_categories and marker in processed:
            continue
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            continue
        
        # Wyciągnij stringi + spróbuj FIZYCZNIE zmigrować sendTextMessage / say / tr()
        basename = os.path.basename(filepath).replace('.lua', '').replace('.xml', '').replace('.cpp', '').replace('.hpp', '')
        safe_name = re.sub(r'[^a-z0-9_]', '_', basename.lower())
        
        local_keys = 0

        file_changed_by_tool = False

        # 1) Lua: zamień :sendTextMessage(...) na :sendLocalizedTextMessage(...)
        if filepath.endswith('.lua') and 'sendTextMessage' in content:
            key_prefix = f"{category}.{safe_name}"
            cmd = [
                'python3', 'tools/i18n_migrate_lua_sendtext.py',
                '--file', filepath,
                '--json', json_file,
                '--key-prefix', key_prefix,
                '--backup-dir', os.path.join('backups', category),
            ]
            try:
                out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
                m = re.search(r'keys_added=(\d+)', out)
                if m:
                    local_keys += int(m.group(1))
                    keys_added += int(m.group(1))
                m2 = re.search(r'file_changed=([01])', out)
                if m2 and m2.group(1) == '1':
                    file_changed_by_tool = True
                # Tool mógł dopisać klucze do JSON -> przeładuj
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    pass
            except subprocess.CalledProcessError:
                # w razie błędu nie blokuj całej kategorii; zostaw tylko extraction
                pass

        # 2) Lua: zamień :say("...") na :sayLocalized("key", ...)
        if filepath.endswith('.lua') and ':say' in content and not category.startswith('otclient_'):
            key_prefix = f"{category}.{safe_name}"
            cmd = [
                'python3', 'tools/i18n_migrate_lua_say.py',
                '--target', 'creature',
                '--file', filepath,
                '--json', json_file,
                '--key-prefix', key_prefix,
                '--backup-dir', os.path.join('backups', category),
                '--suffix', 'say',
            ]
            try:
                out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
                m = re.search(r'keys_added=(\d+)', out)
                if m:
                    local_keys += int(m.group(1))
                    keys_added += int(m.group(1))
                m2 = re.search(r'file_changed=([01])', out)
                if m2 and m2.group(1) == '1':
                    file_changed_by_tool = True
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    pass
            except subprocess.CalledProcessError:
                pass

        # 2b) Lua: zamień broadcastMessage(...) na Game.broadcastLocalizedMessage(...)
        if filepath.endswith('.lua') and 'broadcastMessage' in content and not category.startswith('otclient_'):
            key_prefix = f"{category}.{safe_name}"
            cmd = [
                'python3', 'tools/i18n_migrate_lua_broadcast.py',
                '--file', filepath,
                '--json', json_file,
                '--key-prefix', key_prefix,
                '--backup-dir', os.path.join('backups', category),
                '--suffix', 'broadcast',
            ]
            try:
                out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
                m = re.search(r'keys_added=(\d+)', out)
                if m:
                    local_keys += int(m.group(1))
                    keys_added += int(m.group(1))
                m2 = re.search(r'file_changed=([01])', out)
                if m2 and m2.group(1) == '1':
                    file_changed_by_tool = True
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    pass
            except subprocess.CalledProcessError:
                pass

        # 3) OTClient/Testyy: zamień tr("literal") -> tr("key") i dopisz do JSON
        if category.startswith('otclient_') and ('tr(' in content):
            key_prefix = f"{category}.{safe_name}"
            cmd = [
                'python3', 'tools/i18n_migrate_otclient_tr.py',
                '--file', filepath,
                '--json', json_file,
                '--key-prefix', key_prefix,
                '--backup-dir', os.path.join('backups', category),
            ]
            try:
                out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
                m = re.search(r'keys_added=(\d+)', out)
                if m:
                    local_keys += int(m.group(1))
                    keys_added += int(m.group(1))
                m2 = re.search(r'file_changed=([01])', out)
                if m2 and m2.group(1) == '1':
                    file_changed_by_tool = True
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    pass
            except subprocess.CalledProcessError:
                pass

        # 4) OTClient/Testyy (.otui): zamień text: "literal" -> text: tr('key')
        if category.startswith('otclient_') and filepath.endswith('.otui') and ('text:' in content):
            key_prefix = f"{category}.{safe_name}"
            cmd = [
                'python3', 'tools/i18n_migrate_otclient_otui_text.py',
                '--file', filepath,
                '--json', json_file,
                '--key-prefix', key_prefix,
                '--backup-dir', os.path.join('backups', category),
                '--suffix', 'otui_text',
            ]
            try:
                out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True)
                m = re.search(r'keys_added=(\d+)', out)
                if m:
                    local_keys += int(m.group(1))
                    keys_added += int(m.group(1))
                m2 = re.search(r'file_changed=([01])', out)
                if m2 and m2.group(1) == '1':
                    file_changed_by_tool = True
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    pass
            except subprocess.CalledProcessError:
                pass
        
        # Pattern: sendTextMessage(TYPE, "text")
        stm_matches = re.findall(r'sendTextMessage\s*\([^,]+,\s*"([^"]{10,})"', content)
        for i, text in enumerate(stm_matches, 1):
            key = f"{category}.{safe_name}.msg_{i}"
            if key not in data:
                data[key] = text
                keys_added += 1
                local_keys += 1
        
        # Pattern: player:say("text")
        say_matches = re.findall(r'player:say\s*\(\s*"([^"]{10,})"', content)
        for i, text in enumerate(say_matches, 1):
            key = f"{category}.{safe_name}.say_{i}"
            if key not in data:
                data[key] = text
                keys_added += 1
                local_keys += 1
        
        # Pattern: broadcastMessage("text")
        broadcast_matches = re.findall(r'broadcastMessage\s*\(\s*"([^"]{10,})"', content)
        for i, text in enumerate(broadcast_matches, 1):
            key = f"{category}.{safe_name}.broadcast_{i}"
            if key not in data:
                data[key] = text
                keys_added += 1
                local_keys += 1
        
        # Zapisz marker
        processed.add(marker)
        
        if local_keys > 0 or file_changed_by_tool:
            files_processed += 1
            if local_keys > 0:
                print(f"   📄 {basename}: +{local_keys} kluczy")
            else:
                print(f"   📄 {basename}: zmieniono plik (0 nowych kluczy)")
        
        if files_processed >= BATCH:
            break
    
    if files_processed >= BATCH:
        break

# Zapisz JSON
with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

# Zapisz processed
with open(PROCESSED_FILE, 'w') as f:
    f.write('\n'.join(sorted(processed)))

print(f"   📊 Razem: {files_processed} plików, +{keys_added} kluczy")
GENERICPY
    
    log "${GREEN}✅ Generic ($category): Przetworzono${NC}"
}

#===============================================================================
# SYNC TRANSLATION KEYS - Etap 1: Synchronizacja struktury kluczy
#===============================================================================
# Kopiuje klucze z EN do innych języków z prefixem [EN] 
# Nie tłumaczy! Tylko synchronizuje strukturę.
#===============================================================================
sync_translation_keys() {
    local target_lang="$1"
    local json_file="$2"
    local batch_size="${3:-300}"
    
    log "${CYAN}🌍 SYNC KEYS: $target_lang <- en/$json_file (batch: $batch_size)${NC}"
    
    local _sync_out _sync_rc _synced
    _sync_out=$(python3 << SYNCPY
import json
import os
import time
import sys

I18N_DIR = "i18n"
target_lang = "$target_lang"
json_file = "$json_file"
batch_size = int("$batch_size") if "$batch_size".isdigit() else 300
CATEGORY_STATE_FILE = ".i18n_category_state.json"
UNTRANSLATED_PREFIX = "[EN] "

# Wczytaj plik EN (źródło)
en_path = f"{I18N_DIR}/en/{json_file}"
if not os.path.exists(en_path):
    print(f"   ❌ Brak pliku źródłowego: {en_path}")
    print("__SYNC_RESULT__ synced=0")
    sys.exit(1)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

print(f"   📖 Źródło EN: {len(en_data)} kluczy")

# Utwórz katalog językowy jeśli nie istnieje
lang_dir = f"{I18N_DIR}/{target_lang}"
os.makedirs(lang_dir, exist_ok=True)

# Wczytaj lub stwórz plik językowy
lang_path = f"{lang_dir}/{json_file}"
if os.path.exists(lang_path):
    with open(lang_path, 'r', encoding='utf-8') as f:
        lang_data = json.load(f)
    print(f"   📄 Istniejące: {len(lang_data)} kluczy")
else:
    lang_data = {}
    print(f"   📄 Tworzę nowy plik: {lang_path}")

# Znajdź brakujące klucze
missing_keys = [key for key in en_data if key not in lang_data]
print(f"   🔍 Brakujących: {len(missing_keys)}")

if not missing_keys:
    print(f"   ✅ Wszystkie klucze zsynchronizowane dla {target_lang}/{json_file}")
    print("__SYNC_RESULT__ synced=0")
    sys.exit(0)

# Synchronizuj batch kluczy
synced = 0
for key in missing_keys[:batch_size]:
    en_value = en_data[key]
    # Dodaj prefix [EN] do wartości
    lang_data[key] = f"{UNTRANSLATED_PREFIX}{en_value}"
    synced += 1

# Zapisz plik językowy (posortowany alfabetycznie)
lang_data_sorted = dict(sorted(lang_data.items()))
with open(lang_path, 'w', encoding='utf-8') as f:
    json.dump(lang_data_sorted, f, indent=2, ensure_ascii=False)

print(f"   ✅ Zsynchronizowano: +{synced} kluczy → {target_lang}/{json_file}")
print(f"   📊 Teraz: {len(lang_data)} kluczy (pozostało: {len(missing_keys) - synced})")

# Zaktualizuj state synchronizacji
try:
    with open(CATEGORY_STATE_FILE, 'r') as f:
        state = json.load(f)
except:
    state = {}

if "translation_sync" not in state:
    state["translation_sync"] = {
        "current_lang": target_lang,
        "current_category": json_file,
        "languages_done": [],
        "stats": {},
        "last_sync": 0
    }

sync_state = state["translation_sync"]

# Aktualizuj statystyki
if target_lang not in sync_state.get("stats", {}):
    sync_state["stats"][target_lang] = {}

sync_state["stats"][target_lang][json_file.replace(".json", "")] = len(lang_data)
sync_state["current_lang"] = target_lang
sync_state["current_category"] = json_file
sync_state["last_sync"] = time.time()

# Sprawdź czy wszystkie kategorie dla tego języka są zsynchronizowane
all_json_files = [f for f in os.listdir(f"{I18N_DIR}/en") if f.endswith(".json")]
all_synced_for_lang = True
for jf in all_json_files:
    jp = f"{I18N_DIR}/{target_lang}/{jf}"
    if not os.path.exists(jp):
        all_synced_for_lang = False
        break
    with open(f"{I18N_DIR}/en/{jf}") as f:
        en_keys = set(json.load(f).keys())
    with open(jp) as f:
        lang_keys = set(json.load(f).keys())
    if en_keys - lang_keys:  # Jeśli są brakujące klucze
        all_synced_for_lang = False
        break

if all_synced_for_lang and target_lang not in sync_state.get("languages_done", []):
    if "languages_done" not in sync_state:
        sync_state["languages_done"] = []
    sync_state["languages_done"].append(target_lang)
    print(f"   🎉 Język {target_lang} w pełni zsynchronizowany!")

# Oblicz total dla języka (BEZ poprzedniego total - to powodowało błąd kumulacji!)
lang_stats = sync_state["stats"].get(target_lang, {})
total_keys = sum(v for k, v in lang_stats.items() if k != "total")
sync_state["stats"][target_lang]["total"] = total_keys

# Zapisz state
with open(CATEGORY_STATE_FILE, 'w') as f:
    json.dump(state, f, indent=2)

print(f"   💾 State zapisany")

print(f"__SYNC_RESULT__ synced={synced}")
SYNCPY
    2>&1)
    _sync_rc=$?

    # Loguj pełny output do stderr, ale zwróć tylko liczbę zsynchronizowanych kluczy na stdout.
    echo "$_sync_out" >&2
    _synced=$(echo "$_sync_out" | awk -F'synced=' '/__SYNC_RESULT__/{print $2}' | tail -n 1 | tr -dc '0-9')
    _synced=${_synced:-0}
    echo "$_synced"
    
    log "${GREEN}✅ Sync: Zakończono batch${NC}"
}

#===============================================================================
# AUTO TRANSLATE - Automatyczne tłumaczenie BEZ interakcji
#===============================================================================
# Kopiuje klucze EN do innych języków z prefiksem [LANG] lub używa prostych
# tłumaczeń dla popularnych fraz.
#===============================================================================
auto_translate_keys() {
    local target_lang="$1"
    local json_file="$2"
    local keys_count="$3"
    # Jeśli TRANSLATE_LIMIT > 0, użyj go; w przeciwnym razie użyj keys_count.
    # (TRANSLATE_LIMIT bywa ustawiony na 0, a wtedy nie powinien nadpisywać keys_count)
    local translate_limit="0"
    if [ "${TRANSLATE_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
        translate_limit="$TRANSLATE_LIMIT"
    else
        translate_limit="${keys_count:-0}"
    fi  # 0 = brak limitu
    
    log "${CYAN}🌍 AUTO TRANSLATE: $target_lang <- $json_file (limit: $translate_limit)${NC}"
    
    local _at_out _at_rc _translated _placeholders
    _at_out=$(python3 << AUTOTRANSPY
import json
import os
import re
import hashlib
import sys

I18N_DIR = "i18n"
target_lang = "$target_lang"
json_file = "$json_file"
translate_limit = int("$translate_limit" or "0")

# Prosty słownik tłumaczeń dla popularnych fraz
SIMPLE_TRANSLATIONS = {
    "pl": {
        "Hello": "Witaj",
        "Welcome": "Witamy",
        "Goodbye": "Do widzenia",
        "Thank you": "Dziękuję",
        "Yes": "Tak",
        "No": "Nie",
        "Buy": "Kup",
        "Sell": "Sprzedaj",
        "Trade": "Handel",
        "Help": "Pomoc",
        "Quest": "Zadanie",
        "Mission": "Misja",
        "Gold": "Złoto",
        "Player": "Gracz",
        "Monster": "Potwór",
        "Item": "Przedmiot",
        "Spell": "Zaklęcie",
        "Attack": "Atak",
        "Defense": "Obrona",
        "Health": "Zdrowie",
        "Mana": "Mana",
    },
    "de": {
        "Hello": "Hallo",
        "Welcome": "Willkommen",
        "Goodbye": "Auf Wiedersehen",
        "Thank you": "Danke",
        "Yes": "Ja",
        "No": "Nein",
        "Buy": "Kaufen",
        "Sell": "Verkaufen",
        "Trade": "Handel",
        "Help": "Hilfe",
        "Quest": "Quest",
        "Mission": "Mission",
        "Gold": "Gold",
        "Player": "Spieler",
        "Monster": "Monster",
        "Item": "Gegenstand",
        "Spell": "Zauber",
    },
    "es": {
        "Hello": "Hola",
        "Welcome": "Bienvenido",
        "Goodbye": "Adiós",
        "Thank you": "Gracias",
        "Yes": "Sí",
        "No": "No",
        "Buy": "Comprar",
        "Sell": "Vender",
        "Trade": "Comercio",
        "Help": "Ayuda",
        "Quest": "Misión",
        "Gold": "Oro",
        "Player": "Jugador",
        "Monster": "Monstruo",
    },
    "ru": {
        "Hello": "Привет",
        "Welcome": "Добро пожаловать",
        "Goodbye": "До свидания",
        "Thank you": "Спасибо",
        "Yes": "Да",
        "No": "Нет",
        "Buy": "Купить",
        "Sell": "Продать",
        "Trade": "Торговля",
        "Help": "Помощь",
        "Quest": "Задание",
        "Gold": "Золото",
        "Player": "Игрок",
        "Monster": "Монстр",
    },
    "pt": {
        "Hello": "Olá",
        "Welcome": "Bem-vindo",
        "Goodbye": "Adeus",
        "Thank you": "Obrigado",
        "Yes": "Sim",
        "No": "Não",
        "Buy": "Comprar",
        "Sell": "Vender",
        "Trade": "Comércio",
        "Help": "Ajuda",
        "Quest": "Missão",
        "Gold": "Ouro",
        "Player": "Jogador",
        "Monster": "Monstro",
    }
}

def simple_translate(text, lang):
    """Zwraca tłumaczenie TYLKO gdy całe zdanie równa się wpisowi w słowniku."""
    translations = SIMPLE_TRANSLATIONS.get(lang)
    if not translations:
        return None
    for en, translated in translations.items():
        if text.strip().lower() == en.lower():
            return translated
    return None

# Wczytaj EN jako źródło
en_file = f"{I18N_DIR}/en/{json_file}"
if not os.path.exists(en_file):
    print(f"Brak pliku źródłowego: {en_file}")
    exit(0)

with open(en_file) as f:
    en_data = json.load(f)

# Wczytaj lub utwórz plik docelowy
lang_file = f"{I18N_DIR}/{target_lang}/{json_file}"
os.makedirs(os.path.dirname(lang_file), exist_ok=True)

try:
    with open(lang_file) as f:
        lang_data = json.load(f)
except:
    lang_data = {}

# Pamięć tłumaczeń (TM) - przechowuje tłumaczenie + hash źródła
tm_path = f"{I18N_DIR}/translation_memory.json"
try:
    with open(tm_path) as f:
        tm_data = json.load(f)
except:
    tm_data = {}

if target_lang not in tm_data:
    tm_data[target_lang] = {}

def src_hash(text: str) -> str:
    return hashlib.md5(text.encode("utf-8")).hexdigest()

def count_placeholders(text: str):
    braces = re.findall(r'\{[^}]*\}', text)
    pipes = re.findall(r'\|[^|]+\|', text)
    return len(braces), len(pipes)

# Przetwórz klucze
translated = 0
placeholders = 0
guard_fail = 0
tm_updates = 0
for key, en_text in en_data.items():
    # Sprawdź limit tłumaczeń
    if translate_limit > 0 and translated >= translate_limit:
        print(f"⚠️ Osiągnięto limit {translate_limit} tłumaczeń")
        break
        
    if key in lang_data:
        # Sprawdź czy to placeholder
        if not lang_data[key].startswith("["):
            continue  # Już przetłumaczone
    
    # TM lookup: użyj zapamiętanego tłumaczenia jeśli hash źródła pasuje
    h = src_hash(en_text)
    saved = tm_data.get(target_lang, {}).get(key)
    if saved and saved.get("src_hash") == h:
        candidate = saved.get("text", "")
        sb, sp = count_placeholders(en_text)
        tb, tp = count_placeholders(candidate)
        if sb == tb and sp == tp and candidate:
            lang_data[key] = candidate
            translated += 1
            continue

    # Spróbuj prostego tłumaczenia
    simple = simple_translate(en_text, target_lang)
    
    if simple:
        # Guard na placeholdery {} i |...|
        sb, sp = count_placeholders(en_text)
        tb, tp = count_placeholders(simple)
        if sb == tb and sp == tp:
            lang_data[key] = simple
            translated += 1
            tm_data[target_lang][key] = {"src_hash": h, "text": simple}
            tm_updates += 1
        else:
            lang_data[key] = f"[{target_lang.upper()}] {en_text}"
            placeholders += 1
            guard_fail += 1
    else:
        # Placeholder z kodem języka
        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
        placeholders += 1

# Zapisz
lang_data = dict(sorted(lang_data.items()))
with open(lang_file, 'w') as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)

if tm_updates > 0:
    with open(tm_path, 'w') as f:
        json.dump(tm_data, f, indent=2, ensure_ascii=False)

print(f"✅ {target_lang}/{json_file}: {translated} przetłumaczonych, {placeholders} placeholder'ów, TM+{tm_updates}, guard_fail={guard_fail}")

print(f"__AUTO_RESULT__ translated={translated} placeholders={placeholders}")
AUTOTRANSPY
    2>&1)
    _at_rc=$?

    echo "$_at_out" >&2

    _translated=$(echo "$_at_out" | awk -F'translated=' '/__AUTO_RESULT__/{print $2}' | awk '{print $1}' | tail -n 1 | tr -dc '0-9')
    _placeholders=$(echo "$_at_out" | awk -F'placeholders=' '/__AUTO_RESULT__/{print $2}' | tail -n 1 | tr -dc '0-9')
    _translated=${_translated:-0}
    _placeholders=${_placeholders:-0}

    # stdout: "translated placeholders" (dla status_log_op)
    echo "$_translated $_placeholders"
    
    log "${GREEN}✅ Auto-translate zakończone${NC}"
}

#===============================================================================
# TRYB IDLE: SKANOWANIE NOWYCH PLIKÓW
#===============================================================================
# Funkcja skanuje workspace w poszukiwaniu nowych plików NPC/scripts
# które nie zostały jeszcze przetworzone przez worker.
#===============================================================================
scan_new_files() {
    log "${CYAN}🔍 IDLE: Skanowanie nowych plików...${NC}"
    
    python3 << 'SCANNEWPY'
import os
import json
import re

# Ścieżki do skanowania
SCAN_PATHS = [
    "data-otservbr-global/npc",
    "data-canary/npc",
    "data-otservbr-global/scripts",
    "data-canary/scripts"
]

# Plik z listą przetworzonych
PROCESSED_FILE = "i18n_processed_files.txt"
NEW_FILES_REPORT = "i18n/new_files_detected.json"

# Wzorce wymagające migracji
MIGRATION_PATTERNS = [
    r'StdModule\.say\s*\(\s*[^,]+,\s*[^,]+,\s*"[^"]+"\)',
    r'npcHandler:say\s*\(\s*"[^"]+"\s*[,\)]',
    r'NpcHandler:say\s*\(\s*"[^"]+"\s*[,\)]',
    r'npcConfig\.voices\s*=\s*\{[^}]*text\s*=\s*"[^"]+"'
]

# Wczytaj przetworzone
processed = set()
if os.path.exists(PROCESSED_FILE):
    with open(PROCESSED_FILE, 'r') as f:
        processed = set(line.strip() for line in f if line.strip())

new_files = []
needs_migration = []

for scan_path in SCAN_PATHS:
    if not os.path.exists(scan_path):
        continue
    for root, dirs, files in os.walk(scan_path):
        for fname in files:
            if not fname.endswith('.lua'):
                continue
            fpath = os.path.join(root, fname)
            rel_path = fpath
            
            if rel_path not in processed:
                new_files.append(rel_path)
                
                # Sprawdź czy wymaga migracji
                try:
                    with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    for pattern in MIGRATION_PATTERNS:
                        if re.search(pattern, content):
                            needs_migration.append({
                                "file": rel_path,
                                "pattern": pattern[:40] + "..."
                            })
                            break
                except:
                    pass

# Zapisz raport
report = {
    "scan_time": __import__('datetime').datetime.now().isoformat(),
    "total_new": len(new_files),
    "needs_migration": len(needs_migration),
    "files": needs_migration[:20]  # Max 20 w raporcie
}

os.makedirs("i18n", exist_ok=True)
with open(NEW_FILES_REPORT, 'w') as f:
    json.dump(report, f, indent=2)

if needs_migration:
    print(f"⚠️ WYKRYTO {len(needs_migration)} NOWYCH PLIKÓW DO MIGRACJI!")
    for item in needs_migration[:5]:
        print(f"   - {item['file']}")
    if len(needs_migration) > 5:
        print(f"   ... i {len(needs_migration)-5} więcej")
else:
    print(f"✅ Brak nowych plików wymagających migracji (sprawdzono: {len(new_files)} nowych)")
SCANNEWPY
}

#===============================================================================
# TRYB IDLE: GENEROWANIE DOKUMENTACJI KATEGORII (NPC, SCRIPTS, itp.)
#===============================================================================
generate_npc_documentation() {
    log "${CYAN}📚 IDLE: Generowanie dokumentacji kategorii...${NC}"
    
    python3 << 'GENDOCPY'
import os
import json
from datetime import datetime

I18N_DIR = "i18n"
DOCS_DIR = "docs/i18n/categories"
os.makedirs(DOCS_DIR, exist_ok=True)

# Kategorie do dokumentowania
CATEGORIES = ["npc", "scripts", "monsters", "items", "spells", "quests", "actions", "events"]

generated = 0

# Zbierz dane z EN jako bazę (ma wszystkie klucze)
en_dir = os.path.join(I18N_DIR, "en")
if not os.path.exists(en_dir):
    print("⚠️ Brak katalogu i18n/en")
    exit(0)

for category in CATEGORIES:
    en_file = os.path.join(en_dir, f"{category}.json")
    if not os.path.exists(en_file):
        continue
    
    doc_path = os.path.join(DOCS_DIR, f"{category}.md")
    
    try:
        with open(en_file, 'r', encoding='utf-8') as f:
            en_data = json.load(f)
    except:
        continue
    
    # Zlicz tłumaczenia dla każdego języka
    translations_count = {}
    for lang_dir in os.listdir(I18N_DIR):
        lang_path = os.path.join(I18N_DIR, lang_dir)
        if not os.path.isdir(lang_path) or lang_dir == 'en':
            continue
        
        lang_file = os.path.join(lang_path, f"{category}.json")
        if not os.path.exists(lang_file):
            continue
        
        try:
            with open(lang_file, 'r', encoding='utf-8') as f:
                lang_data = json.load(f)
            # Zlicz niepuste tłumaczenia
            translated = sum(1 for k, v in lang_data.items() if v and v != en_data.get(k, ''))
            if translated > 0:
                translations_count[lang_dir] = translated
        except:
            continue
    
    # Generuj dokumentację
    md_lines = [
        f"# Kategoria: {category.upper()}",
        "",
        f"> Auto-generated by i18n_worker on {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        "",
        "## Statystyki",
        "",
        "| Metryka | Wartość |",
        "|---------|---------|",
        f"| Kluczy EN | {len(en_data)} |",
        f"| Języki z tłumaczeniami | {len(translations_count)} |",
    ]
    
    if translations_count:
        best_lang = max(translations_count, key=translations_count.get)
        coverage = (translations_count[best_lang] / len(en_data)) * 100 if en_data else 0
        md_lines.append(f"| Najlepiej przetłumaczony | {best_lang} ({translations_count[best_lang]}, {coverage:.1f}%) |")
    
    md_lines.extend(["", "## Tłumaczenia według języków", ""])
    md_lines.append("| Język | Przetłumaczonych | Coverage |")
    md_lines.append("|-------|-----------------|----------|")
    
    for lang, count in sorted(translations_count.items(), key=lambda x: -x[1])[:15]:
        cov = (count / len(en_data)) * 100 if en_data else 0
        md_lines.append(f"| {lang} | {count} | {cov:.1f}% |")
    
    md_lines.extend(["", "## Przykładowe klucze (pierwszych 10)", ""])
    
    for key in list(en_data.keys())[:10]:
        en_text = en_data[key]
        preview = en_text[:50] + "..." if len(en_text) > 50 else en_text
        md_lines.append(f"- `{key}`: {preview}")
    
    if len(en_data) > 10:
        md_lines.append(f"- *... i {len(en_data)-10} więcej kluczy*")
    
    md_lines.extend(["", "---", f"*Źródło: `{en_file}`*"])
    
    with open(doc_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_lines))
    
    generated += 1

print(f"📚 Wygenerowano/zaktualizowano {generated} dokumentacji kategorii")
GENDOCPY
}

#===============================================================================
# TRYB IDLE: WALIDACJA JAKOŚCI TŁUMACZEŃ
#===============================================================================
validate_translation_quality() {
    log "${CYAN}🔬 IDLE: Walidacja jakości tłumaczeń...${NC}"
    
    python3 << 'VALIDATEPY'
import os
import json
import re
from datetime import datetime

I18N_DIR = "i18n"
REPORT_FILE = "i18n/quality_report.json"

issues = []

# Wzorce do sprawdzenia
PLACEHOLDER_RE = re.compile(r'\{[^}]+\}')
COMMAND_RE = re.compile(r"'[a-z]+(?:\s+[a-z]+)?'")
PIPE_RE = re.compile(r'\|[A-Z]+\|')

def check_translation(key, en_text, translation, lang, source_file):
    """Sprawdza jakość pojedynczego tłumaczenia"""
    local_issues = []
    
    if not translation or translation == en_text:
        return []  # Brak tłumaczenia - pomijamy
    
    # 1. Sprawdź placeholdery {player}, {item} itp.
    en_placeholders = set(PLACEHOLDER_RE.findall(en_text))
    tr_placeholders = set(PLACEHOLDER_RE.findall(translation))
    
    if en_placeholders != tr_placeholders:
        missing = en_placeholders - tr_placeholders
        extra = tr_placeholders - en_placeholders
        if missing:
            local_issues.append({
                "type": "MISSING_PLACEHOLDER",
                "key": key,
                "lang": lang,
                "file": source_file,
                "details": f"Brakuje: {missing}"
            })
        if extra:
            local_issues.append({
                "type": "EXTRA_PLACEHOLDER",
                "key": key,
                "lang": lang,
                "file": source_file,
                "details": f"Nadmiarowe: {extra}"
            })
    
    # 2. Sprawdź komendy 'trade', 'job' - powinny być niezmienione
    en_commands = set(COMMAND_RE.findall(en_text))
    tr_commands = set(COMMAND_RE.findall(translation))
    
    if en_commands and en_commands != tr_commands:
        local_issues.append({
            "type": "COMMAND_CHANGED",
            "key": key,
            "lang": lang,
            "file": source_file,
            "details": f"EN: {en_commands}, {lang}: {tr_commands}"
        })
    
    # 3. Sprawdź formatowanie |PIPE|
    en_pipes = set(PIPE_RE.findall(en_text))
    tr_pipes = set(PIPE_RE.findall(translation))
    
    if en_pipes != tr_pipes:
        local_issues.append({
            "type": "PIPE_FORMAT_CHANGED",
            "key": key,
            "lang": lang,
            "file": source_file,
            "details": f"EN: {en_pipes}, {lang}: {tr_pipes}"
        })
    
    # 4. Sprawdź drastyczną różnicę długości (>3x)
    len_ratio = len(translation) / max(len(en_text), 1)
    if len_ratio > 3 or len_ratio < 0.3:
        local_issues.append({
            "type": "LENGTH_SUSPICIOUS",
            "key": key,
            "lang": lang,
            "file": source_file,
            "details": f"EN: {len(en_text)} znaków, {lang}: {len(translation)} znaków (ratio: {len_ratio:.2f})"
        })
    
    return local_issues

# Skanuj wszystkie pliki JSON w strukturze i18n/{lang}/{category}.json
CATEGORIES = ['npc', 'scripts', 'monsters', 'items', 'spells', 'quests', 'actions']

# Najpierw wczytaj EN jako bazę
en_dir = os.path.join(I18N_DIR, "en")
if not os.path.exists(en_dir):
    print("⚠️ Brak katalogu i18n/en")
    exit(0)

en_data = {}  # {category: {key: text}}
for cat in CATEGORIES:
    en_file = os.path.join(en_dir, f"{cat}.json")
    if os.path.exists(en_file):
        try:
            with open(en_file, 'r', encoding='utf-8') as f:
                en_data[cat] = json.load(f)
        except:
            pass

# Teraz sprawdź tłumaczenia w innych językach
for lang_dir in os.listdir(I18N_DIR):
    lang_path = os.path.join(I18N_DIR, lang_dir)
    if not os.path.isdir(lang_path) or lang_dir == 'en':
        continue
    
    for cat in CATEGORIES:
        if cat not in en_data:
            continue
        
        lang_file = os.path.join(lang_path, f"{cat}.json")
        if not os.path.exists(lang_file):
            continue
        
        try:
            with open(lang_file, 'r', encoding='utf-8') as f:
                lang_data = json.load(f)
        except:
            continue
        
        for key, translation in lang_data.items():
            en_text = en_data[cat].get(key, '')
            if not en_text or not translation:
                continue
            
            issues.extend(check_translation(key, en_text, translation, lang_dir, lang_file))

# Zapisz raport
report = {
    "timestamp": datetime.now().isoformat(),
    "total_issues": len(issues),
    "by_type": {},
    "issues": issues[:100]  # Max 100 w raporcie
}

for issue in issues:
    issue_type = issue["type"]
    report["by_type"][issue_type] = report["by_type"].get(issue_type, 0) + 1

with open(REPORT_FILE, 'w', encoding='utf-8') as f:
    json.dump(report, f, indent=2, ensure_ascii=False)

if issues:
    print(f"⚠️ Znaleziono {len(issues)} problemów z jakością tłumaczeń:")
    for issue_type, count in report["by_type"].items():
        print(f"   - {issue_type}: {count}")
else:
    print("✅ Wszystkie tłumaczenia przeszły walidację jakości")
VALIDATEPY
}

#===============================================================================
# TRYB IDLE: DZIENNY RAPORT
#===============================================================================
generate_daily_report() {
    log "${CYAN}📊 IDLE: Generowanie dziennego raportu...${NC}"
    
    python3 << 'DAILYPY'
import os
import json
from datetime import datetime

I18N_DIR = "i18n"
REPORTS_DIR = "i18n/reports"
os.makedirs(REPORTS_DIR, exist_ok=True)

today = datetime.now().strftime('%Y-%m-%d')
report_file = os.path.join(REPORTS_DIR, f"daily_{today}.md")

# Zbierz statystyki
stats = {
    "npc_files": 0,
    "total_keys": 0,
    "translations": {},
    "quality_issues": 0
}

for subdir in ['npc', 'scripts', 'monsters']:
    dir_path = os.path.join(I18N_DIR, subdir)
    if not os.path.exists(dir_path):
        continue
    
    for fname in os.listdir(dir_path):
        if not fname.endswith('.json'):
            continue
        
        stats["npc_files"] += 1
        fpath = os.path.join(dir_path, fname)
        
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            stats["total_keys"] += len(data)
            
            for key, val in data.items():
                if isinstance(val, dict):
                    for lang in val.keys():
                        if lang != 'en' and val.get(lang):
                            stats["translations"][lang] = stats["translations"].get(lang, 0) + 1
        except:
            pass

# Wczytaj raport jakości
quality_file = os.path.join(I18N_DIR, "quality_report.json")
if os.path.exists(quality_file):
    try:
        with open(quality_file, 'r') as f:
            quality = json.load(f)
            stats["quality_issues"] = quality.get("total_issues", 0)
    except:
        pass

# Generuj raport MD
md_lines = [
    f"# Raport dzienny i18n - {today}",
    "",
    f"> Wygenerowany automatycznie przez i18n_worker",
    "",
    "## Podsumowanie",
    "",
    "| Metryka | Wartość |",
    "|---------|---------|",
    f"| Pliki JSON | {stats['npc_files']} |",
    f"| Klucze i18n | {stats['total_keys']} |",
    f"| Języki z tłumaczeniami | {len(stats['translations'])} |",
    f"| Problemy jakości | {stats['quality_issues']} |",
    "",
    "## Tłumaczenia według języków",
    "",
    "| Język | Przetłumaczonych kluczy |",
    "|-------|------------------------|",
]

for lang, count in sorted(stats["translations"].items(), key=lambda x: -x[1])[:20]:
    md_lines.append(f"| {lang} | {count} |")

md_lines.extend([
    "",
    "---",
    f"*Worker: i18n_worker_simple.sh*"
])

with open(report_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(md_lines))

print(f"📊 Raport zapisany: {report_file}")
print(f"   Pliki: {stats['npc_files']}, Klucze: {stats['total_keys']}, Języki: {len(stats['translations'])}")
DAILYPY
}

#===============================================================================
# TRYB IDLE: PEŁNA FUNKCJONALNOŚĆ
#===============================================================================
# Wykonuje wszystkie zadania IDLE:
# 1. Skanowanie nowych plików
# 2. Walidacja jakości
# 3. Generowanie dokumentacji
# 4. Raport dzienny (raz dziennie)
#===============================================================================
idle_full_cycle() {
    log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    log "${GREEN}TRYB IDLE - Pełny cykl (skan + walidacja + dokumentacja)${NC}"
    log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    # 1. Skanuj nowe pliki
    scan_new_files
    
    # 2. Walidacja jakości
    validate_translation_quality
    
    # 3. Generuj dokumentację NPC
    generate_npc_documentation
    
    # 4. Dzienny raport (sprawdź czy już wygenerowany dzisiaj)
    local today=$(date +%Y-%m-%d)
    local report_file="i18n/reports/daily_${today}.md"
    
    if [[ ! -f "$report_file" ]]; then
        generate_daily_report
    else
        log "${GRAY}📊 Raport dzienny już istnieje: $report_file${NC}"
    fi
    
    log "${GREEN}✅ IDLE cykl zakończony${NC}"
}

#===============================================================================
# TRYB 2: TŁUMACZENIA - INTERAKTYWNY dla agenta LLM
#===============================================================================
# Agent LLM (Phi-4, GPT, Claude) uruchamia ten skrypt w terminalu.
# Worker wyświetla tekst EN, agent wpisuje tłumaczenie, worker zapisuje.
#
# ZASADY DLA AGENTA:
# - Tłumacz całe zdania naturalnie
# - Komendy w 'apostrofach' (np. 'trade', 'job') - NIE TŁUMACZ
# - Zmienne w {nawiasach} (np. {player}) - BEZ ZMIAN
# - Formatowanie |PIPE| - BEZ ZMIAN
# - Wpisz "SKIP" aby pominąć klucz
# - Wpisz "QUIT" aby zakończyć sesję
#===============================================================================
mode_translation() {
    local target_lang="${1:-pl}"
    
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BLUE}TRYB 2: TŁUMACZENIA INTERAKTYWNE${NC} - Język: $target_lang"
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Przekaż zmienne do Pythona przez zmienne środowiskowe
    export TRANSLATE_LANG="$target_lang"
    export TRANSLATE_I18N_DIR="$I18N_DIR"
    export TRANSLATE_STATUS_FILE="$STATUS_FILE"
    export TRANSLATE_BATCH="$TRANSLATION_BATCH"
    export TRANSLATE_SUBSTAGE="$TRANSLATION_SUBSTAGE"
    
    python3 << 'PYTRANSLATE'
import json
import os
import re
import sys
import shutil

target_lang = os.environ.get("TRANSLATE_LANG", "pl")
i18n_dir = os.environ.get("TRANSLATE_I18N_DIR", "i18n")
status_file = os.environ.get("TRANSLATE_STATUS_FILE", "i18n_file_status.json")
batch_size = int(os.environ.get("TRANSLATE_BATCH", "50"))
substage_size = int(os.environ.get("TRANSLATE_SUBSTAGE", "4"))

def atomic_write_json(path, data, ensure_ascii=True):
    tmp_path = path + ".tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, path + ".bak")
        except Exception:
            pass
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=ensure_ascii)
    os.replace(tmp_path, path)

def update_translation_status(status_path, payload):
    lock_f = None
    try:
        import fcntl
        lock_f = open(os.path.join(os.getcwd(), ".i18n_status.lock"), "w")
        fcntl.flock(lock_f, fcntl.LOCK_EX)
    except Exception:
        lock_f = None

    try:
        with open(status_path, encoding="utf-8") as f:
            status = json.load(f)
    except Exception:
        status = {}

    if "translation_status" not in status:
        status["translation_status"] = {}

    status["translation_status"][target_lang] = payload
    atomic_write_json(status_path, status, ensure_ascii=True)

    if lock_f:
        try:
            fcntl.flock(lock_f, fcntl.LOCK_UN)
        except Exception:
            pass
        lock_f.close()

# [1/6] SELECT_SOURCE
print("[1/6] SELECT_SOURCE: en/npc.json")
en_file = f"{i18n_dir}/en/npc.json"
if not os.path.exists(en_file):
    print("❌ Brak pliku en/npc.json")
    exit(1)

with open(en_file) as f:
    en_data = json.load(f)

# [2/6] DETECT_PROGRESS
print(f"[2/6] DETECT_PROGRESS: Sprawdzam {target_lang}/npc.json")
lang_dir = f"{i18n_dir}/{target_lang}"
os.makedirs(lang_dir, exist_ok=True)
lang_file = f"{lang_dir}/npc.json"

if os.path.exists(lang_file):
    with open(lang_file) as f:
        lang_data = json.load(f)
else:
    lang_data = {}

# Znajdź klucze do przetłumaczenia (brakujące lub z placeholder [LANG])
keys_todo = []
for key, text in en_data.items():
    if key not in lang_data:
        keys_todo.append((key, text))
    elif lang_data[key].startswith(f"[{target_lang.upper()}]") or lang_data[key].startswith("[TODO]"):
        keys_todo.append((key, text))

print(f"   Kluczy do tłumaczenia: {len(keys_todo)}")

if len(keys_todo) == 0:
    print(f"✅ Wszystkie klucze dla {target_lang} są przetłumaczone!")
    exit(0)

# [3/6] PREPARE_BATCH
print(f"[3/6] PREPARE_BATCH: Przygotowanie {min(batch_size, len(keys_todo))} kluczy")
keys_batch = keys_todo[:batch_size]
total_substages = (len(keys_batch) + substage_size - 1) // substage_size
print(f"   Składni: {total_substages}")

# [4/6] TRANSLATE_BATCH - tłumaczenie ze składniami
print(f"[4/6] TRANSLATE_BATCH: Tłumaczenie")

#===============================================================================
# Słownik nazw języków
LANG_NAMES = {
    "pl": "polski", "de": "niemiecki", "es": "hiszpański", "pt": "portugalski",
    "fr": "francuski", "it": "włoski", "ru": "rosyjski", "nl": "holenderski",
    "sv": "szwedzki", "da": "duński", "no": "norweski", "fi": "fiński",
    "cs": "czeski", "sk": "słowacki", "hu": "węgierski", "ro": "rumuński",
    "bg": "bułgarski", "el": "grecki", "tr": "turecki", "uk": "ukraiński",
    "zh": "chiński (uproszczony)", "ja": "japoński", "ko": "koreański", "ar": "arabski"
}

# Przetwórz interaktywnie - agent wpisuje tłumaczenia
translated_count = 0
skipped_count = 0

print("")
print("╔══════════════════════════════════════════════════════════════════════╗")
print(f"║  🌍 TRYB INTERAKTYWNY - TŁUMACZENIE NA {LANG_NAMES.get(target_lang, target_lang).upper():20}         ║")
print("╠══════════════════════════════════════════════════════════════════════╣")
print("║  ZASADY:                                                             ║")
print("║  • Komendy w 'apostrofach' NIE TŁUMACZ (np. 'trade', 'job')          ║")
print("║  • Zmienne w {nawiasach} zachowaj bez zmian                          ║")
print("║  • Formatowanie |PIPE| zachowaj bez zmian                            ║")
print("║                                                                      ║")
print("║  KOMENDY: SKIP = pomiń | QUIT = zakończ | SAVE = zapisz i kontynuuj  ║")
print("╚══════════════════════════════════════════════════════════════════════╝")
print("")
print(f"📊 Do przetłumaczenia: {len(keys_batch)} kluczy")
print("")

quit_requested = False

for idx, (key, en_text) in enumerate(keys_batch):
    if quit_requested:
        break
    
    # Wyświetl tekst do tłumaczenia
    print("─" * 70)
    print(f"[{idx + 1}/{len(keys_batch)}] 📌 {key}")
    print(f"")
    print(f"  EN: {en_text}")
    print(f"")
    
    # Pokaż zmienne/komendy do zachowania
    commands = re.findall(r"'[^']+?'", en_text)
    variables = re.findall(r"\{[^}]+?\}", en_text)
    pipes = re.findall(r"\|[^|]+?\|", en_text)
    
    if commands or variables or pipes:
        print(f"  ⚠️  Zachowaj bez zmian: ", end="")
        if commands:
            print(f"komendy: {', '.join(commands)} ", end="")
        if variables:
            print(f"zmienne: {', '.join(variables)} ", end="")
        if pipes:
            print(f"pipe: {', '.join(pipes)}", end="")
        print("")
        print("")
    
    # Czekaj na input od agenta (przez terminal)
    print(f"  {target_lang.upper()}: ", end="")
    sys.stdout.flush()
    
    try:
        # Spróbuj czytać z /dev/tty (terminal) jeśli stdin jest pipe
        if not sys.stdin.isatty():
            try:
                with open('/dev/tty', 'r') as tty:
                    translation = tty.readline().strip()
            except:
                translation = input().strip()
        else:
            translation = input().strip()
    except EOFError:
        print("\n⚠️  Koniec input - zapisuję i kończę")
        break
    
    # Obsłuż komendy
    if translation.upper() == "QUIT":
        print("  ✋ Zakończono sesję")
        quit_requested = True
        break
    elif translation.upper() == "SKIP":
        print("  ⏭️  Pominięto")
        skipped_count += 1
        lang_data[key] = f"[SKIP:{target_lang.upper()}] {en_text}"
        continue
    elif translation.upper() == "SAVE":
        print("  💾 Zapisuję dotychczasowe i kontynuuję...")
        lang_data = dict(sorted(lang_data.items()))
        atomic_write_json(lang_file, lang_data, ensure_ascii=False)
        print(f"  ✅ Zapisano {len(lang_data)} kluczy")
        continue
    elif not translation:
        print("  ⏭️  Puste - pominięto")
        skipped_count += 1
        lang_data[key] = f"[EMPTY:{target_lang.upper()}] {en_text}"
        continue
    
    # Walidacja - czy zachowano komendy i zmienne
    valid = True
    for cmd in commands:
        if cmd not in translation:
            print(f"  ⚠️  UWAGA: Brakuje komendy {cmd}!")
            valid = False
    for var in variables:
        if var not in translation:
            print(f"  ⚠️  UWAGA: Brakuje zmiennej {var}!")
            valid = False
    
    if valid:
        print(f"  ✅ OK")
    
    # Zapisz tłumaczenie
    lang_data[key] = translation
    translated_count += 1

print("")
print("═" * 70)

# [5/6] SAVE_TRANSLATIONS
print(f"[5/6] SAVE_TRANSLATIONS: Zapisuję {translated_count} tłumaczeń")
lang_data = dict(sorted(lang_data.items()))
atomic_write_json(lang_file, lang_data, ensure_ascii=False)

# Statystyki
placeholders = len([v for v in lang_data.values() if v.startswith("[")])
real_total = len(lang_data) - placeholders

# [6/6] SYNC
print(f"[6/6] SYNC: Aktualizacja statusu")

payload = {
    "total_keys": len(lang_data),
    "translated": real_total,
    "placeholders": placeholders,
    "last_batch": translated_count,
    "last_update": __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S")
}
update_translation_status(status_file, payload)

print(f"\n✅ SESJA TŁUMACZENIA ZAKOŃCZONA: {target_lang}")
print(f"   Przetłumaczono: {translated_count}")
print(f"   Pominięto: {skipped_count}")
print(f"   Razem w pliku: {len(lang_data)} kluczy")
print(f"   Prawdziwe tłumaczenia: {real_total}")
print(f"   Pozostało placeholder'ów: {placeholders}")
PYTRANSLATE

    log "${GREEN}✅ TRYB TŁUMACZEŃ ZAKOŃCZONY${NC}"
    return 0
}

#===============================================================================
# DISPATCHER - Wybór trybu w continuous mode (Multi-Category)
#===============================================================================
# KATEGORIE: NPC → SCRIPTS → MONSTERS → ITEMS → SPELLS → SERVER → WEB
# Po zakończeniu migracji wszystkich kategorii → AUTO_TRANSLATE
#===============================================================================
select_work_mode() {
    python3 << 'DISPATCHERPY'
import os
import json
import glob
import re

I18N_DIR = "i18n"
LANG_PRIORITY = ["pl", "de", "es", "pt", "fr", "it", "ru", "nl", "sv", "cs"]
ALL_LANGUAGES = ["pl", "de", "es", "pt", "fr", "it", "ru", "uk", "nl", "sv", "da", "no", "fi", "cs", "sk", "hu", "ro", "bg", "el", "tr", "ar", "he", "hi", "zh", "ja", "ko", "th", "vi", "id", "ms"]

# ==========================================================================
# Kategorie (kolejność wg priority)
# ==========================================================================
CATEGORIES = {

    # === NPC (priorytet 1) ===
    "npc": {
        "dirs": [
            "data-otservbr-global/npc",
            "data-canary/npc"
        ],
        "patterns": [r'StdModule\\.say', r'npcHandler:say\\(', r'npcConfig\\.voices'],
        "exclude_if": ["i18nKey", "NPC_LIB.i18n.npcSay"],
        "json": "npc.json",
        "priority": 1
    },
    
    # === SCRIPTS GŁÓWNE (priorytet 2) ===
    "scripts": {
        "dirs": [
            "data-otservbr-global/scripts",
            "data/scripts",
            "data-canary/scripts"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'player:say\s*\(', r'"[^"]{15,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n.get", "i18n:"],
        "json": "scripts.json",
        "priority": 2
    },
    
    # === MONSTERS (priorytet 3) ===
    "monsters": {
        "dirs": ["data-otservbr-global/monster", "data-canary/monster"],
        "patterns": [r'description\s*=\s*"[^"]+', r'<description>[^<]+'],
        "exclude_if": ["i18n:"],
        "json": "monsters.json",
        "file_ext": [".lua", ".xml"],
        "priority": 3
    },
    
    # === ACTIONS (priorytet 4) - akcje przedmiotów ===
    "actions": {
        "dirs": [
            "data-otservbr-global/scripts/actions",
            "data-canary/scripts/actions",
            "data/scripts/actions"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{10,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "actions.json",
        "priority": 4
    },
    
    # === QUESTS (priorytet 5) - skrypty questów ===
    "quests": {
        "dirs": [
            "data-otservbr-global/scripts/quests",
            "data-canary/scripts/quests",
            "data/scripts/quests"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'player:say\s*\(', r'"[^"]{15,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "quests.json",
        "priority": 5
    },
    
    # === RAIDS (priorytet 6) ===
    "raids": {
        "dirs": ["data-otservbr-global/raids", "data-canary/raids"],
        "patterns": [r'message="[^"]+', r'<message>[^<]+'],
        "exclude_if": ["i18n:"],
        "json": "raids.json",
        "file_ext": [".xml", ".lua"],
        "priority": 6
    },
    
    # === WORLD (priorytet 7) ===
    "world": {
        "dirs": ["data-otservbr-global/world", "data-canary/world"],
        "patterns": [r'name="[^"]+', r'description="[^"]+'],
        "exclude_if": [],
        "json": "world.json",
        "file_ext": [".lua"],
        "priority": 7
    },
    
    # === SPELLS (priorytet 8) ===
    "spells": {
        "dirs": [
            "data-otservbr-global/scripts/spells",
            "data/scripts/spells",
            "data-canary/scripts/spells"
        ],
        "patterns": [r'words\s*=\s*"[^"]+', r'description\s*=\s*"[^"]+'],
        "exclude_if": ["i18n:"],
        "json": "spells.json",
        "priority": 8
    },
    
    # === TALKACTIONS (priorytet 9) - komendy czatu ===
    "talkactions": {
        "dirs": [
            "data-otservbr-global/scripts/talkactions",
            "data-canary/scripts/talkactions",
            "data/scripts/talkactions"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{10,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "talkactions.json",
        "priority": 9
    },
    
    # === MOVEMENTS (priorytet 10) - ruchy/wejścia ===
    "movements": {
        "dirs": [
            "data-otservbr-global/scripts/movements",
            "data-canary/scripts/movements",
            "data/scripts/movements"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{10,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "movements.json",
        "priority": 10
    },
    
    # === CREATURESCRIPTS (priorytet 11) - eventy kreatur ===
    "creaturescripts": {
        "dirs": [
            "data-otservbr-global/scripts/creaturescripts",
            "data-canary/scripts/creaturescripts",
            "data/scripts/creaturescripts"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{10,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "creaturescripts.json",
        "priority": 11
    },
    
    # === GLOBALEVENTS (priorytet 12) - globalne eventy ===
    "globalevents": {
        "dirs": [
            "data-otservbr-global/scripts/globalevents",
            "data-canary/scripts/globalevents",
            "data/scripts/globalevents"
        ],
        "patterns": [r'sendTextMessage\s*\(', r'broadcastMessage\s*\(', r'"[^"]{10,}"'],
        "exclude_if": ["sendLocalizedTextMessage", "i18n"],
        "json": "globalevents.json",
        "priority": 12
    },
    
    # === ITEMS (priorytet 13) ===
    "items": {
        "dirs": ["data/items", "data/XML"],
        "patterns": [r'name="[^"]+', r'description="[^"]+', r'<attribute key="description" value="[^"]+'],
        "exclude_if": [],
        "json": "items.json",
        "file_ext": [".xml"],
        "priority": 13
    },
    
    # === MOUNTS (priorytet 14) ===
    "mounts": {
        "dirs": ["data/XML"],
        "patterns": [r'<mount\s+[^>]*name="[^"]+', r'description="[^"]+'],
        "exclude_if": [],
        "json": "mounts.json",
        "file_ext": [".xml"],
        "priority": 14
    },
    
    # === LIBS (priorytet 15) ===
    "libs": {
        "dirs": [
            "data/libs",
            "data-otservbr-global/lib",
            "data-canary/lib"
        ],
        "patterns": [r'"[^"]{20,}"'],
        "exclude_if": ["i18n", "require"],
        "json": "libs.json",
        "priority": 15
    },
    
    # === EVENTS (priorytet 16) ===
    "events": {
        "dirs": ["data/events"],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{15,}"'],
        "exclude_if": ["i18n"],
        "json": "events.json",
        "priority": 16
    },
    
    # === CHATCHANNELS (priorytet 17) ===
    "chatchannels": {
        "dirs": ["data/chatchannels"],
        "patterns": [r'name\s*=\s*"[^"]+'],
        "exclude_if": [],
        "json": "chatchannels.json",
        "priority": 17
    },
    
    # === MODULES (priorytet 18) ===
    "modules": {
        "dirs": ["data/modules"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": ["require", "dofile"],
        "json": "modules.json",
        "priority": 18
    },
    
    # === STARTUP (priorytet 19) ===
    "startup": {
        "dirs": ["data-otservbr-global/startup"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": [],
        "json": "startup.json",
        "priority": 19
    },
    
    # === NPCLIB (priorytet 20) ===
    "npclib": {
        "dirs": ["data/npclib"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": ["i18n"],
        "json": "npclib.json",
        "priority": 20
    },
    
    # === DATA ROOT (priorytet 21) - główne pliki lua w data/ ===
    "dataroot": {
        "dirs": ["data"],
        "patterns": [r'"[^"]{15,}"'],
        "exclude_if": ["require", "dofile", "i18n"],
        "json": "dataroot.json",
        "file_ext": [".lua"],
        "recursive": False,  # Tylko główny folder, nie podkatalogi
        "priority": 21
    },
    
    # === HTML_COPY - PHP (priorytet 22) - Strona WWW ===
    "php": {
        "dirs": ["html_copy"],
        "patterns": [r'"[^"]{20,}"', r"'[^']{20,}'", r'echo\s*"[^"]+"'],
        "exclude_if": ["__()"],
        "json": "php.json",
        "file_ext": [".php"],
        "priority": 22
    },
    
    # === HTML_COPY - HTML/Twig (priorytet 23) ===
    "html": {
        "dirs": ["html_copy"],
        "patterns": [r'>[^<]{20,}<', r'title="[^"]+', r'placeholder="[^"]+'],
        "exclude_if": ["{{", "trans"],
        "json": "html.json",
        "file_ext": [".html", ".twig"],
        "priority": 23
    },
    
    # === SRC - C++ Server (priorytet 24) ===
    "cpp": {
        "dirs": ["src"],
        "patterns": [r'"[^"]{10,}"', r'pushString\s*\("[^"]+"\)'],
        "exclude_if": ["i18n::"],
        "json": "cpp.json",
        "file_ext": [".cpp", ".hpp"],
        "priority": 24
    },
    
    # === TESTYY/MODULES - OTClient Modules (priorytet 25) ===
    "otclient_modules": {
        "dirs": ["testyy/modules"],
        "patterns": [r'"[^"]{10,}"', r"'[^']{10,}'", r'tr\s*\([^)]+\)'],
        "exclude_if": [],
        "json": "otclient_modules.json",
        "file_ext": [".lua", ".otui"],
        "priority": 25
    },
    
    # === TESTYY/MODS - OTClient Mods (priorytet 26) ===
    "otclient_mods": {
        "dirs": ["testyy/mods"],
        "patterns": [r'"[^"]{10,}"', r"'[^']{10,}'"],
        "exclude_if": [],
        "json": "otclient_mods.json",
        "file_ext": [".lua", ".otui"],
        "priority": 26
    },
    
    # === TESTYY/DATA - OTClient Data (priorytet 27) ===
    "otclient_data": {
        "dirs": ["testyy/data"],
        "patterns": [r'"[^"]{10,}"', r"'[^']{10,}'"],
        "exclude_if": [],
        "json": "otclient_data.json",
        "file_ext": [".lua", ".otui", ".xml"],
        "priority": 27
    },
    
    # === TESTYY/SRC - OTClient C++ (priorytet 28) ===
    "otclient_src": {
        "dirs": ["testyy/src"],
        "patterns": [r'"[^"]{10,}"', r'pushString\s*\('],
        "exclude_if": [],
        "json": "otclient_src.json",
        "file_ext": [".cpp", ".hpp", ".h"],
        "priority": 28
    },
    
    # === TESTYY/TOOLS - OTClient Tools (priorytet 29) ===
    "otclient_tools": {
        "dirs": ["testyy/tools"],
        "patterns": [r'"[^"]{10,}"', r"'[^']{10,}'"],
        "exclude_if": [],
        "json": "otclient_tools.json",
        "file_ext": [".lua", ".py", ".sh"],
        "priority": 29
    },
    
    # === SERVER ERRORS/MESSAGES (priorytet 30) ===
    "server": {
        "dirs": ["src"],
        "patterns": [r'sendTextMessage\s*\(', r'fmt::format\s*\("[^"]+'],
        "exclude_if": ["i18n::"],
        "json": "server.json",
        "file_ext": [".cpp", ".hpp"],
        "priority": 30
    },
    
    # === ERRORS - Komunikaty błędów (priorytet 31) ===
    "errors": {
        "dirs": ["data-otservbr-global/scripts", "data-canary/scripts", "data/scripts", "src"],
        "patterns": [r'error\s*[=(].*"[^"]+"', r'Error:\s*"[^"]+"', r'fmt::format\s*\("[^"]+'],
        "exclude_if": ["i18n::"],
        "json": "errors.json",
        "file_ext": [".lua", ".cpp", ".hpp"],
        "priority": 31
    }
}

# ============================================================================
# SCOPE:
# - server: serwer bez website + OTClient/testyy
# - full: serwer + OTClient/testyy (bez website)
# - all: wszystko
# ============================================================================
SCOPE = (os.environ.get("I18N_SCOPE", "full") or "full").strip().lower()
if SCOPE in ("server", "canary", "server_only", "server-only"):
    excluded = {"php", "html"}
    CATEGORIES = {k: v for k, v in CATEGORIES.items() if k not in excluded and not k.startswith("otclient_")}
elif SCOPE in ("full", "installer", "server+installer", "server_installer", "server+otclient"):
    excluded = {"php", "html"}
    CATEGORIES = {k: v for k, v in CATEGORIES.items() if k not in excluded}
elif SCOPE in ("all", "everything"):
    pass
else:
    excluded = {"php", "html"}
    CATEGORIES = {k: v for k, v in CATEGORIES.items() if k not in excluded}

# Plik komend sterowania workerem
COMMAND_FILE = ".worker_command"
# Plik stanu kategorii (skip po 0 przetworzonych)
CATEGORY_STATE_FILE = ".i18n_category_state.json"

def read_command():
    """Odczytaj komendę z pliku (jeśli istnieje)"""
    try:
        if os.path.exists(COMMAND_FILE):
            with open(COMMAND_FILE) as f:
                cmd = f.read().strip()
            os.remove(COMMAND_FILE)  # Usuń po odczytaniu
            return cmd
    except:
        pass
    return None

def read_category_state():
    """Odczytaj stan kategorii - które mają być pominięte"""
    try:
        if os.path.exists(CATEGORY_STATE_FILE):
            with open(CATEGORY_STATE_FILE) as f:
                state = json.load(f)
        else:
            state = {}
        
        # Ustaw wartości domyślne
        state.setdefault("skip_until", {})
        state.setdefault("last_processed", {})
        state.setdefault("consecutive_zeros", {})
        state.setdefault("total_processed", {})
        state.setdefault("migrations_done", False)
        
        # Auto-reset kategorii po 24h bez aktywności
        import time
        now = time.time()
        reset_threshold = 24 * 3600  # 24 godziny
        
        for cat_name in list(state.get("skip_until", {}).keys()):
            last_proc = state.get("last_processed", {}).get(cat_name, {})
            last_time = last_proc.get("timestamp", 0)
            
            # Jeśli minęło 24h od ostatniej próby, resetuj skip
            if now - last_time > reset_threshold:
                state["skip_until"].pop(cat_name, None)
                state["consecutive_zeros"][cat_name] = 0
                # Ważne: nie wypisuj na stdout (stdout jest parsowany jako wynik dispatchera)
                if cat_name in CATEGORIES:
                    import sys
                    print(f"🔄 Auto-reset kategorii '{cat_name}' po 24h", file=sys.stderr)
        
        return state
    except:
        return {"skip_until": {}, "last_processed": {}, "consecutive_zeros": {}, "total_processed": {}, "migrations_done": False}

def write_category_state(state):
    """Zapisz stan kategorii"""
    try:
        with open(CATEGORY_STATE_FILE, "w") as f:
            json.dump(state, f, indent=2)
    except:
        pass

def should_skip_category(cat_name, state):
    """Sprawdź czy kategoria powinna być pominięta"""
    skip_until = state.get("skip_until", {}).get(cat_name, 0)
    import time
    return time.time() < skip_until

# Wczytaj status plików z i18n_file_status.json
STATUS_FILE = "i18n_file_status.json"
completed_files = set()
try:
    with open(STATUS_FILE) as f:
        status_data = json.load(f)
    for fpath, info in status_data.get("files", {}).items():
        if info.get("overall_status") == "completed":
            completed_files.add(fpath)
except:
    pass

REPEAT_CATEGORIES = {
    "npc",
    "monsters",
    "scripts",
    "actions",
    "quests",
    "talkactions",
    "movements",
    "creaturescripts",
    "globalevents",
    "spells",
    "items",
    "raids",
    "world",
    "libs",
    "events",
    "chatchannels",
    "modules",
    "startup",
    "npclib",
}

def count_files_needing_work(category):
    """Zlicz pliki wymagające migracji w danej kategorii"""
    config = CATEGORIES.get(category, {})
    if not config:
        return 0

    exts = config.get("file_ext") or [".lua", ".xml"]
    monsters_data = None
    spells_data = None
    raids_data = None
    world_data = None
    chatchannels_data = None
    npclib_data = None
    if category == "monsters":
        try:
            with open(f"{I18N_DIR}/en/monsters.json") as mf:
                monsters_data = json.load(mf)
        except:
            monsters_data = {}

    if category == "items":
        items_xml = None
        for path in ["data/items/items.xml", "data-otservbr-global/items/items.xml"]:
            if os.path.exists(path):
                items_xml = path
                break
        if not items_xml:
            return 0
        try:
            with open(f"{I18N_DIR}/en/items.json") as jf:
                items_data = json.load(jf)
        except:
            items_data = {}
        try:
            with open(items_xml, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except:
            return 0

        block_pattern = re.compile(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"[^>]*>(.*?)</item>', re.DOTALL)
        for m in block_pattern.finditer(content):
            item_id = m.group(1)
            name = m.group(2)
            block = m.group(3)
            if name and f"item.{item_id}.name" not in items_data:
                return 1
            desc_match = re.search(r'<attribute\s+key="description"\s+value="([^"]+)"', block)
            if desc_match and f"item.{item_id}.desc" not in items_data:
                return 1

        self_close_pattern = re.compile(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"[^>]*/>')
        for m in self_close_pattern.finditer(content):
            item_id = m.group(1)
            name = m.group(2)
            if name and f"item.{item_id}.name" not in items_data:
                return 1
        return 0

    text_call_categories = {
        "scripts",
        "actions",
        "quests",
        "talkactions",
        "movements",
        "creaturescripts",
        "globalevents",
        "libs",
        "events",
        "modules",
        "startup",
    }
    
    needs_work = 0
    for dir_path in config["dirs"]:
        if not os.path.isdir(dir_path):
            continue
        for root, dirs, files in os.walk(dir_path):
            for f in files:
                if not any(f.endswith(ext) for ext in exts):
                    continue
                fpath = os.path.join(root, f)
                
                # Sprawdź czy plik nie jest już oznaczony jako completed (dla kategorii z nowymi wzorcami pozwól na ponowne przetwarzanie)
                if category not in REPEAT_CATEGORIES and fpath in completed_files:
                    continue
                
                try:
                    with open(fpath, 'r', errors='ignore') as fp:
                        content = fp.read()
                    
                    # Specjalna logika dla NPC (zgodna z bash)
                    if category == "npc":
                        needs = False
                        # StdModule.say + text= i bez i18nKey
                        if re.search(r'StdModule\.say', content):
                            if re.search(r'text\s*=\s*"', content):
                                if 'i18nKey' not in content:
                                    needs = True
                        # npcHandler:say( bez NPC_LIB (prostszy pattern)
                        if 'npcHandler:say(' in content:
                            if 'NPC_LIB.i18n.npcSay' not in content:
                                needs = True
                        # npcConfig.voices z text = "..." (brak i18n)
                        if re.search(r'npcConfig\.voices\s*=\s*\{', content):
                            if re.search(r'text\s*=\s*"', content):
                                if 'i18nKey' not in content:
                                    needs = True
                        if needs:
                            needs_work += 1
                        continue

                    # Specjalna logika dla monsters
                    if category == "monsters":
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        name_key = f"monster.{safe_name}.name"
                        desc_key = f"monster.{safe_name}.desc"

                        name_in_file = bool(re.search(r'monster\.name\s*=\s*"', content) or re.search(r'createMonsterType\s*\(\s*"[^"]+"', content))
                        desc_in_file = bool(re.search(r'monster\.description\s*=\s*"', content))

                        def voices_missing_i18n(text):
                            start = text.find("monster.voices")
                            if start < 0:
                                return False
                            brace_start = text.find("{", start)
                            if brace_start < 0:
                                return False
                            depth = 0
                            brace_end = None
                            for idx in range(brace_start, len(text)):
                                c = text[idx]
                                if c == "{":
                                    depth += 1
                                elif c == "}":
                                    depth -= 1
                                    if depth == 0:
                                        brace_end = idx
                                        break
                            if brace_end is None:
                                return False
                            block = text[brace_start:brace_end + 1]
                            for entry in re.findall(r'\{[^{}]*?text\s*=\s*[^{}]*?\}', block, re.DOTALL):
                                if "i18nKey" not in entry:
                                    return True
                            return False

                        needs = False
                        if name_in_file and name_key not in monsters_data:
                            needs = True
                        if desc_in_file and desc_key not in monsters_data:
                            needs = True
                        if voices_missing_i18n(content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category == "spells":
                        if spells_data is None:
                            try:
                                with open(f"{I18N_DIR}/en/spells.json") as sf:
                                    spells_data = json.load(sf)
                            except:
                                spells_data = {}
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        name_key = f"spell.{safe_name}.name"
                        words_key = f"spell.{safe_name}.words"
                        desc_key = f"spell.{safe_name}.desc"

                        name_in_file = bool(re.search(r'spell\.name\s*=\s*"[^"]+"', content) or re.search(r'spell:name\s*\(\s*"[^"]+"', content) or re.search(r'name\s*=\s*"[^"]+"', content))
                        words_in_file = bool(re.search(r'spell:words\s*\(\s*"[^"]+"', content) or re.search(r'words\s*=\s*"[^"]+"', content))
                        desc_in_file = bool(re.search(r'spell:description\s*\(\s*"[^"]+"', content) or re.search(r'description\s*=\s*"[^"]+"', content))

                        needs = False
                        if name_in_file and name_key not in spells_data:
                            needs = True
                        if words_in_file and words_key not in spells_data:
                            needs = True
                        if desc_in_file and desc_key not in spells_data:
                            needs = True
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category == "raids":
                        if raids_data is None:
                            try:
                                with open(f"{I18N_DIR}/en/raids.json") as rf:
                                    raids_data = json.load(rf)
                            except:
                                raids_data = {}
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        name_key = f"raid.{safe_name}.name"
                        announce_key = f"raid.{safe_name}.announce"

                        announce_in_file = bool(re.search(r'(?:broadcast|announce|message)[^"]*"[^"]+"', content))
                        needs = False
                        if name_key not in raids_data:
                            needs = True
                        if announce_in_file and announce_key not in raids_data:
                            needs = True
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category == "world":
                        if world_data is None:
                            try:
                                with open(f"{I18N_DIR}/en/world.json") as wf:
                                    world_data = json.load(wf)
                            except:
                                world_data = {}
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        prefix = f"world.{safe_name}.text"
                        has_text_key = any(k.startswith(prefix) for k in world_data.keys())

                        needs = False
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs = True
                        if not has_text_key and re.search(r'"[^"]{10,}"', content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category == "chatchannels":
                        if chatchannels_data is None:
                            try:
                                with open(f"{I18N_DIR}/en/chatchannels.json") as cf:
                                    chatchannels_data = json.load(cf)
                            except:
                                chatchannels_data = {}
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        name_key = f"channel.{safe_name}.name"

                        needs = False
                        if name_key not in chatchannels_data:
                            needs = True
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category == "npclib":
                        if npclib_data is None:
                            try:
                                with open(f"{I18N_DIR}/en/npclib.json") as nf:
                                    npclib_data = json.load(nf)
                            except:
                                npclib_data = {}
                        safe_base = os.path.splitext(os.path.basename(fpath))[0]
                        safe_name = safe_base.lower().replace(" ", "_").replace("-", "_")
                        consts = re.findall(r'(?:TEXT_|MSG_)[A-Z_]+\s*=\s*"[^"]+"', content)
                        existing = [k for k in npclib_data.keys() if k.startswith(f"npclib.{safe_name}.const")]

                        needs = False
                        if consts and len(existing) < len(consts):
                            needs = True
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs = True

                        if needs:
                            needs_work += 1
                        continue

                    if category in text_call_categories:
                        if re.search(r'sendTextMessage\s*\(', content) or re.search(r':say\s*\(', content) or re.search(r'broadcastMessage\s*\(', content):
                            needs_work += 1
                        continue
                    
                    # Standardowa logika dla innych kategorii
                    has_pattern = False
                    for pattern in config["patterns"]:
                        if re.search(pattern, content):
                            has_pattern = True
                            break
                    
                    if not has_pattern:
                        continue
                    
                    # Sprawdź czy nie jest już zmigrowany
                    already_done = False
                    for exclude in config["exclude_if"]:
                        if exclude in content:
                            already_done = True
                            break
                    
                    if has_pattern and not already_done:
                        needs_work += 1
                except:
                    pass
    return needs_work

def count_keys_in_json(json_file):
    """Zlicz klucze w pliku JSON"""
    fpath = f"{I18N_DIR}/en/{json_file}"
    if os.path.exists(fpath):
        try:
            with open(fpath) as f:
                return len(json.load(f))
        except:
            pass
    return 0

def count_untranslated_keys(lang, json_file):
    """Zlicz klucze z placeholderami [LANG] lub brakujące"""
    en_path = f"{I18N_DIR}/en/{json_file}"
    lang_path = f"{I18N_DIR}/{lang}/{json_file}"
    
    if not os.path.exists(en_path):
        return 0
    
    try:
        with open(en_path) as f:
            en_data = json.load(f)
        
        if not os.path.exists(lang_path):
            return len(en_data)
        
        with open(lang_path) as f:
            lang_data = json.load(f)
        
        # Zlicz placeholdery i brakujące
        untranslated = 0
        for key in en_data:
            if key not in lang_data:
                untranslated += 1
            elif lang_data[key].startswith("["):
                untranslated += 1
            elif lang_data[key] == en_data[key]:  # Identyczne = nie przetłumaczone
                untranslated += 1
        return untranslated
    except:
        return 0

# ============ GŁÓWNA LOGIKA DISPATCHERA ============

# 0. Sprawdź komendy sterowania
cmd = read_command()
if cmd:
    if cmd.startswith("FORCE:"):
        # Wymuś kategorię: FORCE:monsters lub FORCE:translation
        forced_cat = cmd.split(":")[1]
        
        # FORCE:translation - wymuś przejście do synchronizacji tłumaczeń
        if forced_cat == "translation":
            # Znajdź pierwszy język/kategorię do synchronizacji
            json_files = list(set([c["json"] for c in CATEGORIES.values()]))
            json_files.sort()
            for lang in TARGET_LANGUAGES:
                for json_file in json_files:
                    missing = count_missing_keys(lang, json_file)
                    if missing > 0:
                        print(f"TRANSLATION_SYNC:{lang}:{json_file}:{missing}:FORCED")
                        exit(0)
            print("IDLE:translation_done:0:FORCED")
            exit(0)
        
        if forced_cat in CATEGORIES:
            needs = count_files_needing_work(forced_cat)
            print(f"MIGRATION:{forced_cat}:{needs}:FORCED")
            exit(0)
        elif forced_cat == "random":
            # Losowa kategoria
            import random
            cats_with_work = [(c, count_files_needing_work(c)) for c in CATEGORIES]
            cats_with_work = [(c, n) for c, n in cats_with_work if n > 0]
            if cats_with_work:
                cat, needs = random.choice(cats_with_work)
                print(f"MIGRATION:{cat}:{needs}:RANDOM")
                exit(0)
    elif cmd == "SKIP":
        # Pomiń aktualną kategorię
        print("SKIP:current:0")
        exit(0)
    elif cmd == "STATUS":
        # Wyświetl status wszystkich kategorii
        for cat in CATEGORIES:
            needs = count_files_needing_work(cat)
            print(f"STATUS:{cat}:{needs}")
        exit(0)

# 1. Sprawdź każdą kategorię po kolei (według priorytetu)
# Uwzględnij skip dla kategorii które zwróciły 0 w poprzednim cyklu
cat_state = read_category_state()
last_processed = cat_state.get("last_processed", {})

# BOOTSTRAP: jeśli kategoria nie była jeszcze ruszana, zrób co najmniej jedno podejście (nawet gdy needs=0)
sorted_cats = sorted(CATEGORIES.items(), key=lambda x: x[1].get("priority", 99))
for cat_name, config in sorted_cats:
    if cat_name not in last_processed:
        needs_work = count_files_needing_work(cat_name)
        print(f"MIGRATION:{cat_name}:{needs_work}:BOOTSTRAP")
        exit(0)

# Standardowy przebieg
pending_skip = False
skip_has_work = False
total_needs = 0
for cat_name, config in sorted_cats:
    needs_work = count_files_needing_work(cat_name)
    total_needs += needs_work
    
    # Pomiń kategorie oznaczone do skip, ale zapamiętaj czy mają pracę
    if should_skip_category(cat_name, cat_state):
        pending_skip = True
        if needs_work > 0:
            skip_has_work = True
        continue
    
    if needs_work > 0:
        cat_state["migrations_done"] = False
        write_category_state(cat_state)
        print(f"MIGRATION:{cat_name}:{needs_work}")
        exit(0)

# Jeśli są kategorie na skip/backoff, nie przechodź do TRANSLATION_SYNC
if pending_skip:
    cat_state["migrations_done"] = False
    write_category_state(cat_state)
    if skip_has_work or total_needs > 0:
        print(f"MIGRATION:pending_skip:{total_needs}:WAIT")
        exit(0)
    # jeśli nie ma realnej pracy, pozwól przejść dalej

# Jeśli tu doszliśmy: brak pracy migracyjnej → uznaj migracje za zakończone
cat_state["migrations_done"] = True
write_category_state(cat_state)

# 1.5) COMPACT_KEYS (po zakończeniu migracji): sync keymap + export compact locales
def count_en_keys_total():
    en_dir = os.path.join(I18N_DIR, "en")
    if not os.path.isdir(en_dir):
        return 0
    total = 0
    for jf in os.listdir(en_dir):
        if not jf.endswith(".json"):
            continue
        try:
            with open(os.path.join(en_dir, jf), "r", encoding="utf-8") as f:
                data = json.load(f)
            if isinstance(data, dict):
                total += len(data)
        except:
            pass
    return total

def count_keymap_total():
    km_path = os.path.join(I18N_DIR, "keymap.json")
    if not os.path.exists(km_path):
        return 0
    try:
        with open(km_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return len(data) if isinstance(data, dict) else 0
    except:
        return 0

def compact_locales_missing():
    # Minimalny check: czy są wygenerowane locale compact dla podstawowych języków.
    langs = ["en", "pl", "de", "es", "pt", "fr", "it", "ru", "tr", "sv", "nl"]
    base = os.path.join("testyy", "data", "locales")
    missing = []
    for lang in langs:
        p = os.path.join(base, f"game_i18n_{lang}_compact.lua")
        if not os.path.exists(p):
            missing.append(lang)
    return missing

en_total = count_en_keys_total()
km_total = count_keymap_total()
missing_langs = compact_locales_missing()

if km_total < en_total or missing_langs:
    reason = []
    if km_total < en_total:
        reason.append(f"keymap_missing={en_total - km_total}")
    if missing_langs:
        reason.append("export_missing=" + ",".join(missing_langs[:6]) + ("..." if len(missing_langs) > 6 else ""))
    print(f"COMPACT_KEYS:all:{en_total - km_total if en_total > km_total else 0}:{'|'.join(reason) if reason else 'needed'}")
    exit(0)

# 2. Migracja zakończona - sprawdź TRANSLATION_SYNC (Etap 1)
# Jeśli migracje nie są oficjalnie zakończone, zatrzymaj się tutaj
if not cat_state.get("migrations_done", False):
    print("MIGRATION:pending:0:WAIT")
    exit(0)
# Kolejność języków: Europa → Rosja/Azja Śr. → Bliski Wschód → Azja → Inne
TARGET_LANGUAGES = [
    # Europa Zachodnia & Środkowa
    "de", "pl", "es", "pt", "fr", "it", "nl", "cs", "sk", "hu",
    # Europa Północna
    "sv", "da", "no", "fi", "et", "lv", "lt",
    # Europa Południowa & Wschodnia
    "ro", "bg", "el", "hr", "sl", "bs", "sr", "mk", "sq",
    # Rosja & Azja Środkowa
    "ru", "uk", "kk", "uz", "az", "hy", "ka",
    # Bliski Wschód
    "tr", "ar", "he", "fa",
    # Azja
    "zh", "zh_TW", "ja", "ko", "hi", "th", "vi", "id", "ms", "tl",
    # Inne
    "bn", "ta", "te", "ml", "sw"
]

# Funkcja synchronizacji kluczy EN → LANG
def get_sync_state():
    """Pobierz stan synchronizacji z category_state"""
    try:
        with open(CATEGORY_STATE_FILE) as f:
            state = json.load(f)
        return state.get("translation_sync", {})
    except:
        return {}

def count_missing_keys(lang, json_file):
    """Zlicz klucze brakujące w danym języku (nie mają odpowiednika lub nie mają [EN] prefix)"""
    en_path = f"{I18N_DIR}/en/{json_file}"
    lang_path = f"{I18N_DIR}/{lang}/{json_file}"
    
    if not os.path.exists(en_path):
        return 0
    
    try:
        with open(en_path) as f:
            en_data = json.load(f)
        
        if not os.path.exists(lang_path):
            return len(en_data)  # Wszystkie klucze brakują
        
        with open(lang_path) as f:
            lang_data = json.load(f)
        
        # Zlicz klucze które nie istnieją w pliku językowym
        missing = 0
        for key in en_data:
            if key not in lang_data:
                missing += 1
        return missing
    except:
        return 0

# Znajdź pierwszy język/kategorię do synchronizacji
sync_state = get_sync_state()
languages_done = sync_state.get("languages_done", [])

# Pobierz unikalne pliki JSON z kategorii
json_files = list(set([c["json"] for c in CATEGORIES.values()]))
json_files.sort()

for lang in TARGET_LANGUAGES:
    if lang in languages_done:
        continue  # Ten język już zsynchronizowany
    
    for json_file in json_files:
        missing = count_missing_keys(lang, json_file)
        if missing > 0:
            # Znaleziono język/kategorię do synchronizacji
            print(f"TRANSLATION_SYNC:{lang}:{json_file}:{missing}")
            exit(0)

# 3. Sprawdź czy wszystko zsynchronizowane
all_synced = True
for lang in TARGET_LANGUAGES:
    for json_file in json_files:
        if count_missing_keys(lang, json_file) > 0:
            all_synced = False
            break
    if not all_synced:
        break

if all_synced:
    print("IDLE:all_synced:0")
else:
    # Coś poszło nie tak - powtórz od początku
    print(f"TRANSLATION_SYNC:{TARGET_LANGUAGES[0]}:{json_files[0]}:retry")
DISPATCHERPY
}

#===============================================================================
# MAIN
#===============================================================================
echo "╔════════════════════════════════════════╗"
echo "║   I18N WORKER v2.0 - Multi-Mode        ║"
echo "╚════════════════════════════════════════╝"

# Inicjalizuj JSON
[ ! -f "$STATUS_FILE" ] && echo '{"files":{}}' > "$STATUS_FILE"
mkdir -p "$I18N_DIR/en" "$BACKUP_DIR/npc" "$BACKUP_DIR/scripts"

case "${1:-}" in
    --file)
        [ -z "${2:-}" ] && { echo "Podaj ścieżkę pliku"; exit 1; }
        process_file "$2"
        ;;
    --translate)
        # Tryb tłumaczeń
        LANG="${2:-pl}"
        mode_translation "$LANG"
        update_github_status
        ;;
    --self-check)
        self_check
        exit $?
        ;;
    --status)
        python3 << 'STATUSEOF'
import json
import os
from datetime import datetime

STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"

try:
    with open(STATUS_FILE) as f:
        data = json.load(f)
except:
    data = {"files": {}}

files = data.get("files", {})
global_stats = data.get("global_stats", {})

# Kolory ANSI
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
RED = "\033[0;31m"
CYAN = "\033[0;36m"
NC = "\033[0m"

print(f"\n{CYAN}╔══════════════════════════════════════════════════════════════════╗{NC}")
print(f"{CYAN}║          I18N WORKER - STATUS DASHBOARD                          ║{NC}")
print(f"{CYAN}╚══════════════════════════════════════════════════════════════════╝{NC}")

# Zlicz pliki po statusie
completed = [f for f, info in files.items() if info.get("overall_status") == "completed"]
in_progress = [f for f, info in files.items() if info.get("overall_status") == "in_progress"]

# Zlicz pliki do migracji
npc_dir = "data-otservbr-global/npc"
total_npc = 0
needs_migration = 0
if os.path.isdir(npc_dir):
    for f in os.listdir(npc_dir):
        if f.endswith(".lua"):
            total_npc += 1
            fpath = os.path.join(npc_dir, f)
            try:
                with open(fpath, "r") as fp:
                    content = fp.read()
                    import re
                    has_i18n = "i18nKey" in content
                    has_npc_lib = "NPC_LIB.i18n.npcSay" in content
                    needs = False
                    # 1. StdModule.say z text = "..." bez i18nKey
                    if "StdModule.say" in content and "text" in content and not has_i18n:
                        needs = True
                    # 2. npcHandler:say( z literalnym stringiem bez NPC_LIB
                    if re.search(r'npcHandler:say\s*\(\s*["\']', content) and not has_npc_lib:
                        needs = True
                    # 3. NpcHandler:say( z literalnym stringiem bez NPC_LIB
                    if re.search(r'NpcHandler:say\s*\(\s*["\']', content) and not has_npc_lib:
                        needs = True
                    # 4. npcConfig.voices z text = "..." bez i18nKey
                    if "npcConfig.voices" in content and 'text = "' in content and not has_i18n:
                        needs = True
                    if needs:
                        needs_migration += 1
            except:
                pass

# Statystyki kluczy
en_keys = 0
if os.path.exists(f"{I18N_DIR}/en/npc.json"):
    try:
        with open(f"{I18N_DIR}/en/npc.json") as f:
            en_keys = len(json.load(f))
    except:
        pass

# Języki z tłumaczeniami
langs_with_data = []
if os.path.isdir(I18N_DIR):
    for lang in os.listdir(I18N_DIR):
        lang_file = f"{I18N_DIR}/{lang}/npc.json"
        if os.path.exists(lang_file):
            try:
                with open(lang_file) as f:
                    if len(json.load(f)) > 0:
                        langs_with_data.append(lang)
            except:
                pass

print(f"\n{BLUE}📊 STATYSTYKI GLOBALNE:{NC}")
print(f"   ├─ Plików NPC ogółem:     {total_npc}")
print(f"   ├─ Do migracji:          {YELLOW}{needs_migration}{NC}")
print(f"   ├─ Ukończonych:          {GREEN}{len(completed)}{NC}")
print(f"   ├─ W trakcie:            {CYAN}{len(in_progress)}{NC}")
print(f"   ├─ Kluczy EN:            {en_keys}")
print(f"   └─ Języków z danymi:     {len(langs_with_data)} ({', '.join(sorted(langs_with_data)[:5])}{'...' if len(langs_with_data) > 5 else ''})")

# Pokaż pliki w trakcie
if in_progress:
    print(f"\n{YELLOW}🔄 W TRAKCIE PRZETWARZANIA:{NC}")
    for fpath in in_progress:
        info = files[fpath]
        stages = info.get("stages", {})
        done_stages = [s for s in stages.keys()]
        last_stage = done_stages[-1] if done_stages else "brak"
        print(f"   ├─ {os.path.basename(fpath)}")
        print(f"   │  └─ Ostatni etap: {last_stage} ({len(done_stages)}/8)")

# Pokaż ostatnie ukończone
if completed:
    print(f"\n{GREEN}✅ OSTATNIO UKOŃCZONE:{NC}")
    # Sortuj po czasie ukończenia
    sorted_completed = sorted(
        [(f, files[f].get("completed_at", "")) for f in completed],
        key=lambda x: x[1],
        reverse=True
    )[:5]
    for fpath, completed_at in sorted_completed:
        info = files[fpath]
        stages = info.get("stages", {})
        keys = stages.get("5_extraction_en", {}).get("keys_added", 0)
        langs = len(stages.get("6_translation", {}).get("languages", []))
        time_str = completed_at[:16].replace("T", " ") if completed_at else "?"
        print(f"   ├─ {os.path.basename(fpath)}")
        print(f"   │  └─ {time_str} | {keys} kluczy | {langs} języków")

# Pokaż etapy dla ostatniego pliku
if files:
    last_file = list(files.keys())[-1]
    info = files[last_file]
    stages = info.get("stages", {})
    print(f"\n{CYAN}📋 ETAPY DLA: {os.path.basename(last_file)}{NC}")
    stage_names = {
        "1_started": "STARTED",
        "2_analysis": "ANALYSIS", 
        "3_documentation": "DOCUMENTATION",
        "4_transformation": "TRANSFORMATION",
        "5_extraction_en": "EXTRACTION_EN",
        "6_translation": "TRANSLATION",
        "7_validation": "VALIDATION",
        "8_sync": "SYNC"
    }
    for stage_key, stage_name in stage_names.items():
        if stage_key in stages:
            status = stages[stage_key].get("status", "?")
            icon = "✅" if status == "completed" else "❌" if status == "failed" else "🔄"
            extra = ""
            if stage_key == "4_transformation":
                extra = f" ({stages[stage_key].get('transformed', 0)} zmian)"
            elif stage_key == "5_extraction_en":
                extra = f" ({stages[stage_key].get('keys_added', 0)} kluczy)"
            elif stage_key == "6_translation":
                extra = f" ({len(stages[stage_key].get('languages', []))} języków)"
            print(f"   {icon} {stage_name}{extra}")
        else:
            print(f"   ⬜ {stage_name}")

print(f"\n{CYAN}─────────────────────────────────────────────────────────────────────{NC}")
print(f"Użyj: ./i18n_worker_simple.sh --auto   aby kontynuować migrację")
print()
STATUSEOF
        ;;
    --stats)
        echo "Szczegółowe statystyki..."
        python3 -c "
import json
import os

with open('$STATUS_FILE') as f: d=json.load(f)

print('\n=== STATYSTYKI KLUCZY ===')
for lang_dir in sorted(os.listdir('$I18N_DIR')):
    npc_file = f'$I18N_DIR/{lang_dir}/npc.json'
    if os.path.exists(npc_file):
        with open(npc_file) as f:
            keys = len(json.load(f))
            print(f'  {lang_dir}: {keys} kluczy')
"
        ;;
    --auto)
        LIMIT="${2:-0}"
        COUNT=0
        echo "Tryb AUTO - szukam plików NPC do migracji..."
        echo "Wzorce: StdModule.say, npcHandler:say, npcConfig.voices z text="
        [ "$LIMIT" -gt 0 ] && echo "Limit: $LIMIT plików"
        for f in data-otservbr-global/npc/*.lua; do
            NEEDS_WORK=false
            
            # Sprawdź StdModule.say bez i18nKey
            if grep -q "StdModule\.say" "$f" 2>/dev/null; then
                if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                    if grep -q 'text = "' "$f" 2>/dev/null; then
                        NEEDS_WORK=true
                    fi
                fi
            fi
            
            # Sprawdź npcHandler:say (wszystkie formy - literały, konkatenacje itp.)
            # Jeśli plik ma jakiekolwiek npcHandler:say, wymaga migracji
            if grep -q 'npcHandler:say(' "$f" 2>/dev/null; then
                NEEDS_WORK=true
            fi
            
            # Sprawdź npcConfig.voices z text = "..." bez i18nKey
            if grep -q "npcConfig.voices" "$f" 2>/dev/null; then
                if grep -q 'text = "' "$f" 2>/dev/null; then
                    if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                        NEEDS_WORK=true
                    fi
                fi
            fi
            
            if [ "$NEEDS_WORK" = "true" ]; then
                process_file "$f"
                COUNT=$((COUNT + 1))
                if [ "$LIMIT" -gt 0 ] && [ "$COUNT" -ge "$LIMIT" ]; then
                    echo ""
                    echo "Osiągnięto limit $LIMIT plików."
                    break
                fi
            fi
        done
        echo ""
        echo "Przetworzono: $COUNT plików"
        # Aktualizuj status dla GitHub
        update_github_status
        ;;
    --update-status)
        update_github_status
        ;;
    --continuous)
        # Tryb ciągły - pracuje cały czas, przełącza się między trybami
        PID_FILE=".worker_simple.pid"
        if [ -f "$PID_FILE" ]; then
            existing_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
            if [[ "$existing_pid" =~ ^[0-9]+$ ]] && kill -0 "$existing_pid" 2>/dev/null; then
                echo "Inny worker już działa (PID: $existing_pid). Zatrzymuję uruchomienie."
                exit 1
            fi
        fi
        echo $$ > "$PID_FILE"
        
        # Parsuj opcje
        shift  # usuń --continuous
        BATCH=$MIGRATION_BATCH  # Domyślnie 50 z podziałem na mini-batch
        DELAY=4
        while [ $# -gt 0 ]; do
            case "$1" in
                --batch)
                    BATCH="${2:-$MIGRATION_BATCH}"
                    shift 2
                    ;;
                --delay)
                    DELAY="${2:-4}"
                    shift 2
                    ;;
                --no-git)
                    NO_GIT=true
                    shift
                    ;;
                --translate-limit)
                    TRANSLATE_LIMIT="${2:-100}"
                    shift 2
                    ;;
                --translations-only)
                    TRANSLATIONS_ONLY=true
                    shift
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        
        echo "╔════════════════════════════════════════════════════════════════════╗"
        echo "║   I18N WORKER v3.1 - FULL AUTONOMOUS (24/7)                        ║"
        echo "║   PID: $$                                                          ║"
        echo "║   Batch: $BATCH plików | Przerwa: ${DELAY}s                        ║"
        [ "$NO_GIT" = "true" ] && echo "║   🚫 --no-git: Git push WYŁĄCZONY                                ║"
        [ "$TRANSLATE_LIMIT" -gt 0 ] 2>/dev/null && echo "║   📊 --translate-limit: max $TRANSLATE_LIMIT kluczy/cykl                       ║"
        [ "$TRANSLATIONS_ONLY" = "true" ] && echo "║   🌐 --translations-only: tylko tłumaczenia                      ║"
        echo "║   Tryby: NPC → SCRIPTS → MONSTERS → ITEMS → AUTO_TRANSLATE        ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Aby zatrzymać: kill $$ lub Ctrl+C"
        echo ""
        
        CYCLE=0
        
        # Obsługa Ctrl+C
        trap 'echo ""; echo "⛔ Zatrzymuję worker..."; status_update_activity "interrupted" "${CYCLE:-0}" "${MODE_TYPE:-IDLE}" "signal" "${MODE_CAT:-}" "-" "stopping" 0 0 "units" 0; update_github_status; rm -f "$PID_FILE"; exit 0' SIGINT SIGTERM
        
        while true; do
            CYCLE=$((CYCLE + 1))
            STOP_AFTER_CYCLE="false"
            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "🔄 CYKL #$CYCLE - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "═══════════════════════════════════════════════════════════════"

            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "cycle_start" "${MODE_CAT:-}" "-" "cycle start" 0 0 "units" 0
            
            # Sprawdź komendy sterowania z plików
            # Najpierw sprawdź worker_commands.txt (dla GitHub), potem .worker_command (lokalny)
            COMMANDS_TXT_PRIMARY=".github/worker_commands.txt"
            COMMANDS_TXT_FALLBACK="worker_commands.txt"
            COMMAND_FILE=".worker_command"
            CMD=""
            
            # 1. Komendy z GitHub:
            # Preferuj .github/worker_commands.txt z origin/master (działa bez git pull)
            CMD_SOURCE=""
            if [ -n "$REPO_ROOT" ]; then
                REMOTE_CMDS=$(git -C "$REPO_ROOT" show "origin/master:Tibia/silnik/canary_test/.github/worker_commands.txt" 2>/dev/null || true)
                if [ -n "$REMOTE_CMDS" ]; then
                    CMD=$(echo "$REMOTE_CMDS" | grep -v '^#' | grep -v '^$' | grep -E '^(FORCE:|AUTO:|SYNC:|COMPACT_KEYS|IDLE|RANDOM|STATUS|SELFTEST|SELF_CHECK|SKIP|PAUSE:|NOTE:)' | head -1)
                    if [ -n "$CMD" ]; then
                        CMD_SOURCE="github"
                        echo "📨 Odebrano z GitHub (.github/worker_commands.txt): $CMD"
                        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
                        # Zapisz ACK lokalnie (guardian wypchnie commit/push w swoim cyklu)
                        mkdir -p .github 2>/dev/null || true
                        UPDATED_CMDS=$(printf '%s\n' "$REMOTE_CMDS" | awk -v ts="$TIMESTAMP" '
BEGIN { done=0 }
{
    line=$0
    if (line ~ /^[[:space:]]*#/ || line ~ /^[[:space:]]*$/) {
        print line
        next
    }
    if (!done && line ~ /^(FORCE:|AUTO:|SYNC:|COMPACT_KEYS|IDLE|RANDOM|STATUS|SKIP|PAUSE:|NOTE:)/) {
        print "#" line "  # Wykonano " ts
        done=1
        next
    }
    print line
}
')
                        {
                            printf '%s\n' "$UPDATED_CMDS"
                            printf '# [%s] Wykonano: %s\n' "$TIMESTAMP" "$CMD"
                        } > "$COMMANDS_TXT_PRIMARY"
                    fi
                fi
            fi

            # Fallback: lokalne pliki (jeśli nie ma komendy z GitHub)
            if [ -z "$CMD" ]; then
                for COMMANDS_TXT in "$COMMANDS_TXT_PRIMARY" "$COMMANDS_TXT_FALLBACK"; do
                    [ -n "$CMD" ] && break
                    if [ -f "$COMMANDS_TXT" ]; then
                        CMD=$(grep -v '^#' "$COMMANDS_TXT" | grep -v '^$' | grep -E '^(FORCE:|AUTO:|SYNC:|COMPACT_KEYS|IDLE|RANDOM|STATUS|SELFTEST|SELF_CHECK|SKIP|PAUSE:|NOTE:)' | head -1)
                        if [ -n "$CMD" ]; then
                            echo "📨 Odebrano z $COMMANDS_TXT: $CMD"
                            TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
                            sed -i "s/^$CMD/#$CMD  # Wykonano $TIMESTAMP/" "$COMMANDS_TXT" 2>/dev/null
                            echo "# [$TIMESTAMP] Wykonano: $CMD" >> "$COMMANDS_TXT"
                            break
                        fi
                    fi
                done
            fi
            
            # 2. Sprawdź .worker_command (szybsze, lokalne)
            if [ -z "$CMD" ] && [ -f "$COMMAND_FILE" ]; then
                CMD=$(cat "$COMMAND_FILE" 2>/dev/null)
                rm -f "$COMMAND_FILE"
                [ -n "$CMD" ] && echo "📨 Odebrano z .worker_command: $CMD"
            fi
            
            # 3. Wykonaj komendę jeśli jest
            if [ -n "$CMD" ]; then
                # Opcja: zakończ po tym cyklu (dla testów faz i weryfikacji dashboardu)
                if [[ "$CMD" == *":ONCE" ]]; then
                    STOP_AFTER_CYCLE="true"
                    CMD="${CMD%:ONCE}"
                    echo "🛑 Tryb testowy: zakończę po tym cyklu"
                fi

                case "$CMD" in
                    FORCE:*)
                        FORCED_CAT=$(echo "$CMD" | cut -d: -f2)
                        echo "🎯 Wymuszam kategorię: $FORCED_CAT"
                        MODE_TYPE="MIGRATION"
                        MODE_CAT="$FORCED_CAT"
                        MODE_COUNT="forced"
                        MODE_EXTRA="FORCED"
                        ;;
                    COMPACT_KEYS)
                        echo "🔑 Wymuszam COMPACT_KEYS"
                        MODE_TYPE="COMPACT_KEYS"
                        MODE_CAT="-"
                        MODE_COUNT="forced"
                        MODE_EXTRA="FORCED"
                        ;;
                    IDLE)
                        echo "✅ Wymuszam IDLE"
                        MODE_TYPE="IDLE"
                        MODE_CAT="-"
                        MODE_COUNT="forced"
                        MODE_EXTRA="FORCED"
                        ;;
                    SYNC:*)
                        # Format: SYNC:<lang>:<json_file>
                        SYNC_LANG=$(echo "$CMD" | cut -d: -f2)
                        SYNC_JSON=$(echo "$CMD" | cut -d: -f3)
                        SYNC_LANG=${SYNC_LANG:-pl}
                        SYNC_JSON=${SYNC_JSON:-npc.json}
                        echo "🌐 Wymuszam TRANSLATION_SYNC: $SYNC_LANG / $SYNC_JSON"
                        MODE_TYPE="TRANSLATION_SYNC"
                        MODE_CAT="$SYNC_LANG"
                        MODE_COUNT="$SYNC_JSON"
                        MODE_EXTRA="forced"
                        MODE_EXTRA2="SYNC"  # znacznik żeby nie nadpisywać dispatchera
                        ;;
                    RANDOM)
                        echo "🎲 Losowanie kategorii..."
                        ALL_CATS="npc scripts monsters raids world spells items libs events chatchannels modules startup npclib"
                        RANDOM_CAT=$(echo "$ALL_CATS" | tr ' ' '\n' | shuf | head -1)
                        echo "🎯 Wylosowano: $RANDOM_CAT"
                        MODE_TYPE="MIGRATION"
                        MODE_CAT="$RANDOM_CAT"
                        MODE_COUNT="random"
                        MODE_EXTRA="RANDOM"
                        ;;
                    STATUS)
                        echo "📊 STATUS WSZYSTKICH KATEGORII:"
                        for cat in npc scripts monsters raids world spells items libs events chatchannels modules startup npclib; do
                            count=$(find data-otservbr-global/$cat data-canary/$cat data/$cat -name "*.lua" 2>/dev/null | wc -l)
                            keys=$(python3 -c "import json; print(len(json.load(open('i18n/en/${cat}.json'))))" 2>/dev/null || echo 0)
                            echo "   $cat: ~$count plików, $keys kluczy"
                        done
                        continue
                        ;;
                    SKIP)
                        echo "⏭️ Pomijam ten cykl..."
                        continue
                        ;;
                    PAUSE:*)
                        PAUSE_CYCLES=$(echo "$CMD" | cut -d: -f2)
                        echo "⏸️ PAUZA na $PAUSE_CYCLES cykli..."
                        sleep $((PAUSE_CYCLES * DELAY))
                        continue
                        ;;
                    NOTE:*)
                        NOTE_TEXT=$(echo "$CMD" | cut -d: -f2-)
                        echo "📝 NOTATKA: $NOTE_TEXT"
                        # Notatka nie wykonuje akcji, kontynuuj normalnie
                        ;;
                    AUTO:*)
                        # Format: AUTO:<lang>:<json_file>:<limit>
                        AUTO_LANG=$(echo "$CMD" | cut -d: -f2)
                        AUTO_JSON=$(echo "$CMD" | cut -d: -f3)
                        AUTO_LIMIT=$(echo "$CMD" | cut -d: -f4)
                        echo "🎯 Wymuszam AUTO_TRANSLATE: $AUTO_LANG / $AUTO_JSON (limit: $AUTO_LIMIT)"
                        MODE_TYPE="AUTO_TRANSLATE"
                        MODE_CAT="$AUTO_LANG"
                        MODE_COUNT="${AUTO_JSON:-npc.json}"
                        MODE_EXTRA="${AUTO_LIMIT:-0}"
                        MODE_EXTRA2="AUTO"  # znacznik żeby nie nadpisywać dispatchera
                        ;;
                    SELFTEST|SELF_CHECK)
                        echo "🧪 Wymuszam SELFTEST"
                        MODE_TYPE="SELFTEST"
                        MODE_CAT="-"
                        MODE_COUNT="0"
                        MODE_EXTRA="FORCED"
                        ;;
                    *)
                        echo "⚠️ Nieznana komenda: $CMD"
                        ;;
                esac
            fi
            
            # Jeśli nie było wymuszenia, użyj dispatchera
            if [ "$MODE_EXTRA2" = "AUTO" ] || [ "$MODE_EXTRA2" = "SYNC" ]; then
                :
            elif [[ -z "$MODE_EXTRA" || ( "$MODE_EXTRA" != "FORCED" && "$MODE_EXTRA" != "RANDOM" ) ]]; then
                MODE_RESULT=$(select_work_mode)
                MODE_TYPE=$(echo "$MODE_RESULT" | cut -d: -f1)
                MODE_CAT=$(echo "$MODE_RESULT" | cut -d: -f2)
                MODE_COUNT=$(echo "$MODE_RESULT" | cut -d: -f3)
                MODE_EXTRA=$(echo "$MODE_RESULT" | cut -d: -f4)
            fi
            
            # --translations-only: wymusza TRANSLATION_SYNC zamiast MIGRATION
            if [ "$TRANSLATIONS_ONLY" = "true" ] && [ "$MODE_TYPE" = "MIGRATION" ]; then
                echo "🌐 --translations-only: pomijam MIGRATION, przechodzę do TRANSLATION_SYNC"
                MODE_TYPE="TRANSLATION_SYNC"
                MODE_CAT=""
                MODE_COUNT="0"
            fi
            
            echo "📋 Dispatcher: $MODE_TYPE | Kategoria: $MODE_CAT | Ilość: ${MODE_COUNT:-0}"
            echo ""

            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "dispatch" "${MODE_CAT:-}" "-" "selected" 0 "${MODE_COUNT:-0}" "items" 0
            
            # Zlicz klucze PRZED przetwarzaniem (do wykrycia czy coś dodano)
            KEYS_BEFORE=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
            
            case "$MODE_TYPE" in
                MIGRATION)
                    echo "🔧 TRYB: MIGRACJA kategorii '$MODE_CAT' ($MODE_COUNT plików do zrobienia)"

                    status_update_activity "running" "$CYCLE" "MIGRATION" "migration_start" "$MODE_CAT" "-" "migration" 0 "${MODE_COUNT:-0}" "files" 0

                    # Zapisz stan diff przed kategorią (żeby liczyć tylko zmiany z tego przebiegu).
                    TMP_DIFF_BEFORE="$(mktemp)"
                    TMP_DIFF_AFTER="$(mktemp)"
                    git diff --name-only 2>/dev/null >"$TMP_DIFF_BEFORE" || true
                    
                    # Specjalny przypadek: wszystkie kategorie są na skip
                    if [ "$MODE_CAT" = "pending_skip" ]; then
                        echo "   ⏳ Wszystkie kategorie są tymczasowo pominięte (skip), czekam..."
                        status_update_activity "running" "$CYCLE" "MIGRATION" "pending_skip" "$MODE_CAT" "-" "all categories skipped" 0 0 "files" 0
                        sleep 30
                        continue
                    fi
                    
                    # Wywołaj odpowiednią funkcję migracji dla kategorii
                    case "$MODE_CAT" in
                        npc)
                            echo "   🧙 Przetwarzam NPC..."
                            COUNT=0
                            # Wczytaj completed files raz na początku
                            COMPLETED_LIST=$(python3 -c "import json; d=json.load(open('$STATUS_FILE')); print(' '.join([f for f,v in d.get('files',{}).items() if v.get('overall_status')=='completed']))" 2>/dev/null)
                            NEEDS_ANALYSIS_DOC_FILE="$(mktemp)"
                            python3 - "$STATUS_FILE" << 'PY' > "$NEEDS_ANALYSIS_DOC_FILE"
import json
import os
import sys

status_file = sys.argv[1]
try:
    with open(status_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

files = data.get("files", {})
npc_dirs = ["data-otservbr-global/npc", "data-canary/npc"]

for npc_dir in npc_dirs:
    if not os.path.isdir(npc_dir):
        continue
    for fname in os.listdir(npc_dir):
        if not fname.endswith(".lua"):
            continue
        path = os.path.join(npc_dir, fname)
        info = files.get(path)
        if not info:
            print(path)
            continue
        stages = info.get("stages", {})
        if "2_analysis" not in stages or "3_documentation" not in stages:
            print(path)
            continue
        doc_file = stages.get("3_documentation", {}).get("doc_file")
        if doc_file:
            if not os.path.exists(doc_file):
                print(path)
            continue
        base = os.path.splitext(os.path.basename(path))[0]
        safe = base.lower().replace(" ", "_").replace("-", "_")
        if not os.path.exists(os.path.join("docs", "i18n", "npc", f"{safe}.md")):
            print(path)
PY
                            
                            # Przetwórz oba katalogi NPC
                            for npc_dir in data-otservbr-global/npc data-canary/npc; do
                                [ -d "$npc_dir" ] || continue
                                for f in "$npc_dir"/*.lua; do
                                    [ -f "$f" ] || continue
                                    
                                    NEEDS_ANALYSIS_DOC=false
                                    if grep -qF "$f" "$NEEDS_ANALYSIS_DOC_FILE" 2>/dev/null; then
                                        NEEDS_ANALYSIS_DOC=true
                                    fi

                                    if [ "$NEEDS_ANALYSIS_DOC" != "true" ]; then
                                        # NAPRAWIONE: Pomiń już przetworzone pliki!
                                        echo "$COMPLETED_LIST" | grep -qF "$f" && continue
                                        grep -qF "$f" "$PROCESSED_FILE" 2>/dev/null && continue
                                    fi
                                    
                                    NEEDS_WORK=false
                                    
                                    if grep -q "StdModule\.say" "$f" 2>/dev/null; then
                                        if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                                            if grep -q 'text = "' "$f" 2>/dev/null; then
                                                NEEDS_WORK=true
                                            fi
                                        fi
                                    fi
                                    
                                    # Prostszy pattern - npcHandler:say( bez wymuszania " zaraz po
                                    if grep -q 'npcHandler:say(' "$f" 2>/dev/null; then
                                        if ! grep -q "NPC_LIB.i18n.npcSay" "$f" 2>/dev/null; then
                                            NEEDS_WORK=true
                                        fi
                                    fi
                                    
                                    # npcConfig.voices z text = "..." bez i18nKey
                                    if grep -q "npcConfig.voices" "$f" 2>/dev/null; then
                                        if grep -q 'text = "' "$f" 2>/dev/null; then
                                            if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                                                NEEDS_WORK=true
                                            fi
                                        fi
                                    fi
                                    
                                    if [ "$NEEDS_WORK" = "true" ] || [ "$NEEDS_ANALYSIS_DOC" = "true" ]; then
                                        status_update_activity "running" "$CYCLE" "MIGRATION" "file" "npc" "$f" "processing" "$COUNT" "${MODE_COUNT:-0}" "files" 0
                                        if ! process_file "$f"; then
                                            status_log_error "$CYCLE" "MIGRATION" "file" "npc" "$f" "process_file failed" "continue"
                                        fi
                                        COUNT=$((COUNT + 1))
                                        [ "$COUNT" -ge "$BATCH" ] && break 2
                                    fi
                                done
                            done
                            rm -f "$NEEDS_ANALYSIS_DOC_FILE" 2>/dev/null || true
                            echo "   📊 NPC: Zmigrowano $COUNT plików"
                            ;;
                        scripts)
                            echo "   📜 Przetwarzam SCRIPTS..."
                            COUNT=0
                            # Wczytaj completed files
                            COMPLETED_LIST=$(python3 -c "import json; d=json.load(open('$STATUS_FILE')); print(' '.join([f for f,v in d.get('files',{}).items() if v.get('overall_status')=='completed']))" 2>/dev/null)
                            
                            # Przeszukaj wszystkie pliki scripts (bez limitu)
                            while IFS= read -r f; do
                                [ -f "$f" ] || continue
                                
                                # Pomiń już przetworzone w JSON (relatywna ścieżka)
                                echo "$COMPLETED_LIST" | grep -qF "$f" && continue
                                
                                # Pomiń już przetworzone w starym pliku (absolutna lub relatywna)
                                grep -qF "$f" "$PROCESSED_FILE" 2>/dev/null && continue
                                grep -qF "$(pwd)/$f" "$PROCESSED_FILE" 2>/dev/null && continue
                                
                                # Szukaj sendTextMessage i/lub :say (fizyczne migracje)
                                # Nie pomijaj plików tylko dlatego, że mają już gdzieś sendLocalizedTextMessage
                                # (mogą być częściowo zmigrowane).
                                if grep -qE '([:.])sendTextMessage\s*\(|\bsendTextMessage\s*\(|:say\s*\(|npcHandler:say\s*\(' "$f" 2>/dev/null; then
                                    status_update_activity "running" "$CYCLE" "MIGRATION" "file" "scripts" "$f" "processing" "$COUNT" "${MODE_COUNT:-0}" "files" 0
                                    if ! process_scripts_file "$f"; then
                                        status_log_error "$CYCLE" "MIGRATION" "file" "scripts" "$f" "process_scripts_file failed" "continue"
                                    fi
                                    COUNT=$((COUNT + 1))
                                    [ "$COUNT" -ge "$BATCH" ] && break
                                fi
                            done < <(find data-otservbr-global/scripts data-canary/scripts data/scripts -name "*.lua" 2>/dev/null)
                            echo "   📊 Scripts: Przetworzono $COUNT plików"
                            ;;
                        monsters)
                            echo "   👹 Przetwarzam MONSTERS z mini-batch..."
                            COUNT=$(run_with_mini_batch "monsters" "process_monsters_category" "$BATCH")
                            ;;
                        spells)
                            echo "   ✨ Przetwarzam SPELLS z mini-batch..."
                            COUNT=$(run_with_mini_batch "spells" "process_spells_category" "$BATCH")
                            ;;
                        items)
                            echo "   🎒 Przetwarzam ITEMS z mini-batch..."
                            COUNT=$(run_with_mini_batch "items" "process_items_category" "$BATCH")
                            ;;
                        raids)
                            echo "   ⚔️ Przetwarzam RAIDS z mini-batch..."
                            COUNT=$(run_with_mini_batch "raids" "process_raids_category" "$BATCH")
                            ;;
                        world)
                            echo "   🗺️ Przetwarzam WORLD z mini-batch..."
                            COUNT=$(run_with_mini_batch "world" "process_world_category" "$BATCH")
                            ;;
                        libs)
                            echo "   📚 Przetwarzam LIBS z mini-batch..."
                            COUNT=$(run_with_mini_batch "libs" "process_libs_category" "$BATCH")
                            ;;
                        events)
                            echo "   🎉 Przetwarzam EVENTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "events" "process_events_category" "$BATCH")
                            ;;
                        chatchannels)
                            echo "   💬 Przetwarzam CHATCHANNELS z mini-batch..."
                            COUNT=$(run_with_mini_batch "chatchannels" "process_chatchannels_category" "$BATCH")
                            ;;
                        modules)
                            echo "   📦 Przetwarzam MODULES z mini-batch..."
                            COUNT=$(run_with_mini_batch "modules" "process_modules_category" "$BATCH")
                            ;;
                        startup)
                            echo "   🚀 Przetwarzam STARTUP z mini-batch..."
                            COUNT=$(run_with_mini_batch "startup" "process_startup_category" "$BATCH")
                            ;;
                        npclib)
                            echo "   📖 Przetwarzam NPCLIB z mini-batch..."
                            COUNT=$(run_with_mini_batch "npclib" "process_npclib_category" "$BATCH")
                            ;;
                        php)
                            echo "   🐘 Przetwarzam PHP z mini-batch..."
                            COUNT=$(run_with_mini_batch "php" "process_php_category" "$BATCH")
                            ;;
                        html)
                            echo "   📄 Przetwarzam HTML/Twig z mini-batch..."
                            COUNT=$(run_with_mini_batch "html" "process_html_category" "$BATCH")
                            ;;
                        cpp)
                            echo "   ⚙️ Przetwarzam C++ z mini-batch..."
                            COUNT=$(run_with_mini_batch "cpp" "process_cpp_category" "$BATCH")
                            ;;
                        client)
                            echo "   🎮 Przetwarzam OTClient z mini-batch..."
                            COUNT=$(run_with_mini_batch "client" "process_client_category" "$BATCH")
                            ;;
                        actions)
                            echo "   🎯 Przetwarzam ACTIONS z mini-batch..."
                            COUNT=$(run_with_mini_batch "actions" "process_generic_category" "$BATCH")
                            ;;
                        quests)
                            echo "   🏆 Przetwarzam QUESTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "quests" "process_generic_category" "$BATCH")
                            ;;
                        talkactions)
                            echo "   💬 Przetwarzam TALKACTIONS z mini-batch..."
                            COUNT=$(run_with_mini_batch "talkactions" "process_generic_category" "$BATCH")
                            ;;
                        movements)
                            echo "   🚶 Przetwarzam MOVEMENTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "movements" "process_generic_category" "$BATCH")
                            ;;
                        creaturescripts)
                            echo "   👹 Przetwarzam CREATURESCRIPTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "creaturescripts" "process_generic_category" "$BATCH")
                            ;;
                        globalevents)
                            echo "   🌍 Przetwarzam GLOBALEVENTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "globalevents" "process_generic_category" "$BATCH")
                            ;;
                        mounts)
                            echo "   🐴 Przetwarzam MOUNTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "mounts" "process_generic_category" "$BATCH")
                            ;;
                        dataroot)
                            echo "   📁 Przetwarzam DATA ROOT z mini-batch..."
                            COUNT=$(run_with_mini_batch "dataroot" "process_generic_category" "$BATCH")
                            ;;
                        server)
                            echo "   🖥️ Przetwarzam SERVER z mini-batch..."
                            COUNT=$(run_with_mini_batch "server" "process_generic_category" "$BATCH")
                            ;;
                        otclient_modules)
                            echo "   🎮 Przetwarzam OTCLIENT MODULES z mini-batch..."
                            COUNT=$(run_with_mini_batch "otclient_modules" "process_generic_category" "$BATCH")
                            ;;
                        otclient_data)
                            echo "   📦 Przetwarzam OTCLIENT DATA z mini-batch..."
                            COUNT=$(run_with_mini_batch "otclient_data" "process_generic_category" "$BATCH")
                            ;;
                        otclient_src)
                            echo "   ⚙️ Przetwarzam OTCLIENT SRC (C++) z mini-batch..."
                            COUNT=$(run_with_mini_batch "otclient_src" "process_generic_category" "$BATCH")
                            ;;
                        otclient_mods)
                            echo "   🔧 Przetwarzam OTCLIENT MODS z mini-batch..."
                            COUNT=$(run_with_mini_batch "otclient_mods" "process_generic_category" "$BATCH")
                            ;;
                        otclient_tools)
                            echo "   🛠️ Przetwarzam OTCLIENT TOOLS z mini-batch..."
                            COUNT=$(run_with_mini_batch "otclient_tools" "process_generic_category" "$BATCH")
                            ;;
                        errors)
                            echo "   🐛 Przetwarzam ERRORS z mini-batch..."
                            COUNT=$(run_with_mini_batch "errors" "process_generic_category" "$BATCH")
                            ;;
                        *)
                            echo "   ⚠️ Nieznana kategoria: $MODE_CAT - próbuję generyczną obsługę..."
                            COUNT=$(run_with_mini_batch "$MODE_CAT" "process_generic_category" "$BATCH")
                            ;;
                    esac
                    
                    # === ŚLEDZENIE WYNIKU KATEGORII ===
                    # Zlicz klucze PO przetwarzaniu
                    KEYS_AFTER=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo "0")
                    KEYS_ADDED=$((KEYS_AFTER - KEYS_BEFORE))
                    
                    # Sprawdź zmiany w git wprowadzone TYLKO przez tę kategorię (delta).
                    git diff --name-only 2>/dev/null >"$TMP_DIFF_AFTER" || true
                    FILES_CHANGED=$(comm -13 <(sort "$TMP_DIFF_BEFORE") <(sort "$TMP_DIFF_AFTER") | grep -E '\.(lua|otui|otmod|xml|cpp|hpp)$' | wc -l)
                    FILES_CHANGED=${FILES_CHANGED:-0}
                    rm -f "$TMP_DIFF_BEFORE" "$TMP_DIFF_AFTER" 2>/dev/null || true
                    
                    # Za "realną pracę" uznajemy tylko zmiany: dodane klucze + zmodyfikowane pliki .lua.
                    # COUNT bywa niespójny między kategoriami (czasem to pliki, czasem klucze z mini-batch),
                    # więc nie używamy go do backoff/skip.
                    COUNT=${COUNT:-0}
                    EFFECTIVE_COUNT=$((KEYS_ADDED + FILES_CHANGED))
                    echo "   📈 Wynik: +$KEYS_ADDED kluczy, $FILES_CHANGED plików źródłowych, COUNT=$COUNT"
                    update_category_state "$MODE_CAT" "$EFFECTIVE_COUNT"

                    status_log_op "$CYCLE" "MIGRATION" "category_done" "$MODE_CAT" "-" "ok" "migration finished" "$KEYS_ADDED" "$FILES_CHANGED"
                    status_update_activity "running" "$CYCLE" "MIGRATION" "migration_done" "$MODE_CAT" "-" "+$KEYS_ADDED keys, $FILES_CHANGED files" "$EFFECTIVE_COUNT" "$EFFECTIVE_COUNT" "items" 0
                    ;;

                COMPACT_KEYS)
                    echo "🔑 TRYB: COMPACT_KEYS - keymap + export client locales (compact)"
                    echo "   Powód: ${MODE_EXTRA:-auto} | brak mapowań: ${MODE_COUNT:-0}"

                    status_update_activity "running" "$CYCLE" "COMPACT_KEYS" "keymap_sync" "-" "-" "sync keymap" 0 0 "keys" 0
                    SYNC_OUT=$(python3 tools/i18n_keymap.py sync --i18n-dir i18n --min-len 2 --max-len 7 2>&1)
                    SYNC_RC=$?
                    if [ "$SYNC_RC" -ne 0 ]; then
                        echo "   ❌ keymap sync failed"
                        echo "$SYNC_OUT" | tail -n 5
                        status_log_error "$CYCLE" "COMPACT_KEYS" "keymap_sync" "-" "-" "i18n_keymap.py sync failed" "rc=$SYNC_RC"
                        break
                    fi

                    # Spróbuj wyciągnąć liczbę nowo dodanych mappingów
                    MAPPED_NEW=$(echo "$SYNC_OUT" | grep -oE 'created [0-9]+' | awk '{print $2}' | tail -n 1)
                    MAPPED_NEW=${MAPPED_NEW:-0}
                    status_log_op "$CYCLE" "COMPACT_KEYS" "keymap_sync" "-" "-" "ok" "${MODE_EXTRA:-auto}" "" "" "$MAPPED_NEW"

                    status_update_activity "running" "$CYCLE" "COMPACT_KEYS" "keymap_verify" "-" "-" "verify keymap" 0 0 "keys" 0
                    if ! python3 tools/i18n_keymap.py verify --i18n-dir i18n >/dev/null 2>&1; then
                        status_log_error "$CYCLE" "COMPACT_KEYS" "keymap_verify" "-" "-" "i18n_keymap.py verify failed" "fix keymap"
                        break
                    fi

                    status_update_activity "running" "$CYCLE" "COMPACT_KEYS" "export" "-" "-" "export compact locales" 0 0 "langs" 0
                    if ! python3 tools/json_to_lua_locales.py --all --server-dir i18n --client-dir testyy/data/locales --compact-keys --i18n-dir i18n >/dev/null 2>&1; then
                        status_log_error "$CYCLE" "COMPACT_KEYS" "export" "-" "-" "json_to_lua_locales.py compact export failed" "check tool"
                        break
                    fi
                    status_log_op "$CYCLE" "COMPACT_KEYS" "export_done" "-" "-" "ok" "export compact locales" "" "" "0"
                    status_update_activity "running" "$CYCLE" "COMPACT_KEYS" "done" "-" "-" "compact keys ready" "$MAPPED_NEW" "$MAPPED_NEW" "mapped" 0
                    ;;

                TRANSLATION_SYNC)
                    echo "🌍 TRYB: TRANSLATION_SYNC - Etap 1 (język: $MODE_CAT, plik: $MODE_COUNT, brakuje: $MODE_EXTRA)"
                    
                    # Synchronizuj klucze EN → LANG z prefixem [EN]
                    status_update_activity "running" "$CYCLE" "TRANSLATION_SYNC" "sync_start" "$MODE_CAT" "$MODE_COUNT" "syncing" 0 0 "keys" 0
                    SYNCED_KEYS=$(sync_translation_keys "$MODE_CAT" "$MODE_COUNT" "${MODE_EXTRA:-300}")
                    SYNCED_KEYS=${SYNCED_KEYS:-0}
                    SYNC_FILES_CHANGED=0
                    if [ "$SYNCED_KEYS" -gt 0 ] 2>/dev/null; then
                        SYNC_FILES_CHANGED=1
                    fi
                    status_log_op "$CYCLE" "TRANSLATION_SYNC" "SYNC_FILE_DONE" "$MODE_CAT" "$MODE_COUNT" "ok" "lang=${MODE_CAT} file=${MODE_COUNT}" "$SYNCED_KEYS" "$SYNC_FILES_CHANGED"

                    # LIVE: zakończ etap sync dla czytelnego dashboardu
                    status_update_activity "running" "$CYCLE" "TRANSLATION_SYNC" "sync_done" "$MODE_CAT" "$MODE_COUNT" "synced" "$SYNCED_KEYS" "$SYNCED_KEYS" "keys" 0
                    ;;
                AUTO_TRANSLATE)
                    echo "🌍 TRYB: AUTO TRANSLATE (język: $MODE_CAT, plik: $MODE_COUNT, kluczy: $MODE_EXTRA)"
                    
                    # Automatyczne tłumaczenie BEZ interakcji!
                    status_update_activity "running" "$CYCLE" "AUTO_TRANSLATE" "auto_start" "$MODE_CAT" "$MODE_COUNT" "auto translate" 0 0 "keys" 0
                    read -r AT_TRANSLATED AT_PLACEHOLDERS <<< "$(auto_translate_keys "$MODE_CAT" "$MODE_COUNT" "$MODE_EXTRA")"
                    AT_TRANSLATED=${AT_TRANSLATED:-0}
                    AT_PLACEHOLDERS=${AT_PLACEHOLDERS:-0}
                    AT_FILES_CHANGED=0
                    if [ "$AT_TRANSLATED" -gt 0 ] 2>/dev/null || [ "$AT_PLACEHOLDERS" -gt 0 ] 2>/dev/null; then
                        AT_FILES_CHANGED=1
                    fi
                    status_log_op "$CYCLE" "AUTO_TRANSLATE" "AUTO_TRANSLATE_DONE" "$MODE_CAT" "$MODE_COUNT" "ok" "lang=${MODE_CAT} file=${MODE_COUNT}" "" "$AT_FILES_CHANGED" "" "$AT_TRANSLATED" "$AT_PLACEHOLDERS"

                    # LIVE: zakończ etap auto dla czytelnego dashboardu
                    status_update_activity "running" "$CYCLE" "AUTO_TRANSLATE" "auto_done" "$MODE_CAT" "$MODE_COUNT" "translated" "$AT_TRANSLATED" "$AT_TRANSLATED" "keys" 0
                    ;;
                IDLE)
                    echo "✅ TRYB: IDLE - Wszystko zrobione!"
                    echo "   Migracja: ✅ | Tłumaczenia: ✅"
                    echo ""
                    
                    # Pełny cykl IDLE: skan + walidacja + dokumentacja + raporty
                    status_update_activity "running" "$CYCLE" "IDLE" "idle_cycle" "-" "-" "idle cycle" 0 0 "steps" 0
                    idle_full_cycle

                    status_log_op "$CYCLE" "IDLE" "IDLE_CYCLE_DONE" "-" "-" "ok" "idle cycle complete"
                    
                    # Sprawdź czy wykryto nowe pliki do migracji
                    if [[ -f "i18n/new_files_detected.json" ]]; then
                        new_count=$(python3 -c "import json; print(json.load(open('i18n/new_files_detected.json')).get('needs_migration', 0))" 2>/dev/null || echo "0")
                        if [[ "$new_count" -gt 0 ]]; then
                            echo "⚠️ Wykryto $new_count nowych plików - restart cyklu!"
                            status_log_op "$CYCLE" "IDLE" "IDLE_NEW_WORK_DETECTED" "-" "-" "ok" "needs_migration=$new_count"
                            continue  # Restart pętli od MIGRATION
                        fi
                    fi
                    
                    echo "   Następny skan za 5 minut..."
                    status_log_op "$CYCLE" "IDLE" "IDLE_SLEEP" "-" "-" "ok" "sleep_seconds=300"
                    if [ "${STOP_AFTER_CYCLE:-false}" = "true" ]; then
                        echo "🛑 ONCE: pomijam IDLE sleep"
                    else
                        sleep 300
                    fi
                    ;;
                SELFTEST)
                    echo "🧪 TRYB: SELFTEST"
                    if ! self_check; then
                        status_log_error "$CYCLE" "SELFTEST" "self_check" "-" "-" "self_check failed" "check logs"
                    fi
                    ;;
                *)
                    echo "⚠️ Nieznany tryb: $MODE_TYPE"
                    ;;
            esac
            
            # Zapisz licznik cykli do pliku (dla statusu) - ROZSZERZONE DANE
            python3 - "$CYCLE" "$MODE_TYPE" "$MODE_CAT" "$MODE_COUNT" "$MODE_EXTRA" << 'SAVEPY'
import json
import os
import sys
import shutil
from datetime import datetime

try:
    cycle = int(sys.argv[1])
except Exception:
    cycle = 0
mode_type = sys.argv[2] if len(sys.argv) > 2 else ""
mode_cat = sys.argv[3] if len(sys.argv) > 3 else ""
mode_count = sys.argv[4] if len(sys.argv) > 4 else "0"
mode_extra = sys.argv[5] if len(sys.argv) > 5 else "0"

def to_int(value):
    try:
        return int(value)
    except Exception:
        return 0

try:
    with open('i18n_global_stats.json', 'r') as f:
        data = json.load(f)
except Exception:
    data = {}

# Podstawowe dane cyklu
data['total_cycles'] = cycle
data['last_update'] = datetime.now().isoformat()
data['mode'] = mode_type
data['category'] = mode_cat

# === DANE SPECYFICZNE DLA TRYBU ===
if mode_type == 'MIGRATION':
    # Statystyki migracji plików
    status_file = 'i18n_file_status.json'
    try:
        with open(status_file) as f:
            status_data = json.load(f)
        files = status_data.get('files', {})

        # Zlicz pliki
        completed = [f for f, info in files.items() if info.get('overall_status') == 'completed']
        files_with_keys = 0
        files_without_keys = 0
        total_keys_extracted = 0

        for fpath in completed:
            keys = files[fpath].get('stages', {}).get('5_extraction_en', {}).get('keys_added', 0)
            if keys > 0:
                files_with_keys += 1
                total_keys_extracted += keys
            else:
                files_without_keys += 1

        data['migration'] = {
            'files_scanned': len(completed),
            'files_with_keys': files_with_keys,
            'files_without_keys': files_without_keys,
            'keys_extracted': total_keys_extracted,
            'current_category': mode_cat,
            'batch_size': to_int(mode_count)
        }
    except Exception as e:
        data['migration'] = {'error': str(e)}

elif mode_type == 'TRANSLATION_SYNC':
    data['translation_sync'] = {
        'language': mode_cat,
        'json_file': mode_count,
        'keys_to_sync': to_int(mode_extra)
    }

elif mode_type == 'AUTO_TRANSLATE':
    data['auto_translate'] = {
        'language': mode_cat,
        'json_file': mode_count,
        'keys_to_translate': to_int(mode_extra)
    }

elif mode_type == 'IDLE':
    # Sprawdź wyniki skanowania
    new_files_count = 0
    quality_issues = 0
    try:
        with open('i18n/new_files_detected.json') as f:
            new_files_count = json.load(f).get('needs_migration', 0)
    except Exception:
        pass
    try:
        with open('i18n/quality_report.json') as f:
            quality_issues = json.load(f).get('total_issues', 0)
    except Exception:
        pass

    data['idle'] = {
        'new_files_detected': new_files_count,
        'quality_issues': quality_issues,
        'last_scan': datetime.now().isoformat()
    }

# Zapisz atomowo
output_file = 'i18n_global_stats.json'
tmp_file = output_file + '.tmp'
if os.path.exists(output_file):
    try:
        shutil.copy2(output_file, output_file + '.bak')
    except Exception:
        pass
with open(tmp_file, 'w') as f:
    json.dump(data, f, indent=2)
os.replace(tmp_file, output_file)
SAVEPY

            # Daily agregacja (UTC) na podstawie ops/errors
            status_build_daily
            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "cycle_end" "${MODE_CAT:-}" "-" "cycle end" 0 0 "units" 0
            
            # Aktualizuj status co cykl
            update_github_status
            
            # Git commit co cykl
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                if [ "$NO_GIT" = "true" ]; then
                    echo "🚫 --no-git: pomijam git add/commit/push"
                else
                    (
                        GIT_LOCK_FILE=".i18n_git.lock"
                        if command -v flock >/dev/null 2>&1; then
                            exec 9>"$GIT_LOCK_FILE"
                            if ! flock -n 9; then
                                echo "🔒 Repo zablokowane (git lock), pomijam git w tym cyklu"
                                exec 9>&-
                                exit 0
                            fi
                            git add -A 2>/dev/null
                            # Zlicz TOTAL kluczy ze wszystkich JSON (nie tylko NPC completed)
                            TOTAL_KEYS=$(python3 -c "
import json, os
total = 0
for f in os.listdir('i18n/en'):
    if f.endswith('.json'):
        try:
            with open(f'i18n/en/{f}') as jf:
                total += len(json.load(jf))
        except: pass
print(total)
" 2>/dev/null || echo "?")
                            git commit -m "📊 I18N: $TOTAL_KEYS kluczy, $MODE_TYPE - Cykl #$CYCLE" 2>/dev/null
                            git push origin master 2>/dev/null && echo "📤 Push OK" || echo "⚠️ Push failed"
                            flock -u 9 2>/dev/null || true
                            exec 9>&-
                        else
                            if ! mkdir "$GIT_LOCK_FILE" 2>/dev/null; then
                                echo "🔒 Repo zablokowane (git lock), pomijam git w tym cyklu"
                                exit 0
                            fi
                            git add -A 2>/dev/null
                            # Zlicz TOTAL kluczy ze wszystkich JSON (nie tylko NPC completed)
                            TOTAL_KEYS=$(python3 -c "
import json, os
total = 0
for f in os.listdir('i18n/en'):
    if f.endswith('.json'):
        try:
            with open(f'i18n/en/{f}') as jf:
                total += len(json.load(jf))
        except: pass
print(total)
" 2>/dev/null || echo "?")
                            git commit -m "📊 I18N: $TOTAL_KEYS kluczy, $MODE_TYPE - Cykl #$CYCLE" 2>/dev/null
                            git push origin master 2>/dev/null && echo "📤 Push OK" || echo "⚠️ Push failed"
                            rmdir "$GIT_LOCK_FILE" 2>/dev/null || true
                        fi
                    )
                fi
            fi
            
            echo ""
            echo "💤 Przerwa ${DELAY}s przed następnym cyklem..."

            if [ "$STOP_AFTER_CYCLE" = "true" ]; then
                echo "🛑 Kończę po cyklu (ONCE)"
                status_update_activity "stopped" "${CYCLE:-0}" "${MODE_TYPE:-IDLE}" "stop_after_cycle" "${MODE_CAT:-}" "-" "stop after cycle" 0 0 "units" 0
                update_github_status
                rm -f "$PID_FILE" 2>/dev/null || true
                exit 0
            fi
            
            # Reset zmiennych wymuszenia przed następnym cyklem
            MODE_EXTRA=""
            
            sleep "$DELAY"
        done
        ;;
    *)
        echo ""
        echo "I18N Worker v2.0 - Multi-Mode Worker"
        echo ""
        echo "TRYBY PRACY:"
        echo "  1. MIGRATION   - Migracja kodu NPC (text= → i18nKey=)"
        echo "  2. TRANSLATION - Interaktywne tłumaczenia (agent wpisuje)"
        echo ""
        echo "TRYB TRANSLATION - INTERAKTYWNY:"
        echo "  Worker wyświetla tekst EN, agent wpisuje tłumaczenie."
        echo "  Komendy: SKIP (pomiń) | QUIT (zakończ) | SAVE (zapisz)"
        echo ""
        echo "  Zasady:"
        echo "  - Komendy w 'apostrofach' (np. 'trade') → NIE TŁUMACZ"
        echo "  - Zmienne w {nawiasach} (np. {player}) → BEZ ZMIAN"
        echo ""
        echo "Użycie:"
        echo "  $0 --file <path>        Przetwórz jeden plik (MIGRATION)"
        echo "  $0 --translate [lang]   Interaktywne tłumaczenia (domyślnie: pl)"
        echo "  $0 --self-check         Szybki sanity check"
        echo "  $0 --status             Pokaż dashboard statusu"
        echo "  $0 --stats              Szczegółowe statystyki języków"
        echo "  $0 --auto [N]           Automatyczna migracja N plików"
        echo "  $0 --continuous [B] [D] Tryb ciągły (B=batch, D=delay)"
        echo "  $0 --update-status      Aktualizuj I18N_STATUS.md"
        echo ""
        echo "Opcje --continuous:"
        echo "  --no-git                Wyłącz git add/commit/push"
        echo "  --translate-limit N     Max N kluczy do tłumaczenia na cykl"
        echo "  --translations-only     Tylko tłumaczenia, bez migracji kodu"
        echo ""
        ;;
esac
