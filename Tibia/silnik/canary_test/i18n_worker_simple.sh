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
#
# ── UNIFIED STAGE / EVENT NAMES ──────────────────────────────────
# Phase            Stage                  Opis
# ─────────────    ─────────────────────  ─────────────────────────
# MIGRATION        migration_start        Początek cyklu migracji
#                  file                   Przetwarzanie pliku
#                  pending_skip           Pomijanie pending_skip
#                  mini_batch             Mini-batch w toku
#                  mini_batch_start/done  Granice mini-batch
#                  migration_done         Koniec migracji
# TRANSLATION_SYNC sync_start             Synchronizacja EN→lang
#                  sync_file_done         Plik zsynchronizowany
#                  sync_done              Koniec synchronizacji
# AUTO_TRANSLATE   auto_start             Tłumaczenie GT/dict
#                  parallel_start         Parallel langs start
#                  auto_done              Koniec auto-translate
# COMPACT_KEYS     keymap_sync            Sync keymap
#                  keymap_verify          Weryfikacja keymap
#                  export                 Export compact keys
#                  done                   Koniec compact
# VALIDATION       validation_start       Początek walidacji
#                  validation_done        Koniec walidacji
# IDLE             idle_cycle / sleeping  Oczekiwanie
# (lifecycle)      cycle_start/end        Granice cyklu
#                  dispatch               Dispatch trybu pracy
#                  signal / restart       Sygnały systemowe
# ─────────────────────────────────────────────────────────────────

# Zachowaj oryginalne argumenty (do RESTART)
WORKER_ORIGINAL_ARGS=("$@")
WORKER_SCRIPT="$(readlink -f "$0")"

cd "$(dirname "$0")"
WORK_DIR="$(pwd)"

# Repo root (do odczytu komend z origin/<branch> bez robienia pull)
REPO_ROOT="$(git -C "$WORK_DIR" rev-parse --show-toplevel 2>/dev/null || echo "")"
GIT_TRACK_BRANCH="${GIT_TRACK_BRANCH:-$(git -C "$WORK_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)}"
[ -z "$GIT_TRACK_BRANCH" ] && GIT_TRACK_BRANCH="master"
[ "$GIT_TRACK_BRANCH" = "HEAD" ] && GIT_TRACK_BRANCH="master"

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
TARGET_LANGS="${TARGET_LANGS:-}"  # --langs "pl,de,es" lub env TARGET_LANGS
BOOTSTRAP_PRIORITY_LANGS="${BOOTSTRAP_PRIORITY_LANGS:-es pl}"  # Bootstrap dla trybu ogólnego: es -> pl
STRICT_SELECTOR_CACHE_TTL_CYCLES="${STRICT_SELECTOR_CACHE_TTL_CYCLES:-5}"  # co ile cykli odświeżać pełny skan strict selector
STATUS_UPDATE_EVERY_CYCLES="${STATUS_UPDATE_EVERY_CYCLES:-5}"              # pełny update I18N_STATUS.md co N cykli
STATUS_UPDATE_MIN_INTERVAL_SEC="${STATUS_UPDATE_MIN_INTERVAL_SEC:-300}"    # lub co N sekund (fallback)
WORKER_PROFILING="${WORKER_PROFILING:-1}"                                  # 1=loguj czasy faz cyklu do i18n/status
QUALITY_AUDIT_EVERY_CYCLES="${QUALITY_AUDIT_EVERY_CYCLES:-10}"             # audyt jakości co N cykli
QUALITY_AUDIT_MIN_INTERVAL_SEC="${QUALITY_AUDIT_MIN_INTERVAL_SEC:-3600}"   # lub co N sekund
QUALITY_AUDIT_THRESHOLD="${QUALITY_AUDIT_THRESHOLD:-10}"                    # powyżej tylu issue spowolnij batch

# ==== TIER SYSTEM (Sekcja 5) ====
# Tier 1: języki priorytetowe — cel: 90% coverage
# Tier 2: języki "bliskie" — cel: 50% coverage
# Tier 3: pozostałe — cel: 30% coverage
# Tier weight = ile razy częściej język danego tieru dostaje cykl tłumaczenia
TIER1_LANGS="pl es"                # Tier 1: PL i ES (już mają >50%)
TIER2_LANGS="de pt ru tr fr it nl cs sk hu"  # Tier 2: europejskie z istniejącą bazą + nowe EU
TIER1_TARGET=90                    # Docelowe pokrycie %
TIER2_TARGET=50
TIER3_TARGET=30
TIER1_WEIGHT=4                     # Tier 1 dostaje 4x więcej cykli
TIER2_WEIGHT=3                     # Tier 2 dostaje 3x więcej (było 2 — boost dla nadrobienia backlogu)
TIER3_WEIGHT=1                     # Tier 3 = baseline
# Priorytet kategorii plików JSON dla tłumaczenia (niższy = ważniejszy)
# items (16894), npc (13769), monsters (5915), server (2574), spells, quests...
CATEGORY_TRANSLATE_PRIORITY="items.json npc.json monsters.json server.json spells.json quests.json scripts.json actions.json raids.json"


# Nowe opcje (Agent 2)
NO_GIT=false                # Flaga --no-git: wyłącza git add/commit/push
TRANSLATE_LIMIT=0           # --translate-limit N: max kluczy do przetłumaczenia na cykl (0=brak limitu)
TRANSLATIONS_ONLY=false     # --translations-only: tylko tłumaczenia, bez migracji kodu
TRANSLATIONS_STRICT=false   # Tryb strict: zero nowych kluczy, tylko istniejące wpisy do tłumaczenia
USE_GOOGLE_TRANSLATE=false  # --use-gt: używaj Google Translate jako fallback po słownikach
GT_BATCH_SIZE=50            # ile kluczy tłumaczyć w jednym batchu GT
GT_DELAY=1.5                # sekundy przerwy między batchami GT (anty rate-limit)
CROSSREF_AUTO_FIX=false     # --auto-fix-crossref: faza 4.5 (Tryb 2), domyślnie OFF
CROSSREF_AUTO_FIX_LIMIT=30  # maksymalna liczba auto-fix na język / przebieg walidacji
PINNED_AUTO_LANG=""        # SWITCH:<lang> - przypięty język AUTO_TRANSLATE między cyklami
PINNED_AUTO_JSON=""        # opcjonalny plik JSON przypięty do SWITCH
PINNED_AUTO_LIMIT=0         # opcjonalny limit przypięty do SWITCH
PINNED_AUTO_JSON_LIST=""   # LANG:<code>:<f1>,<f2>,... - lista plików do cyklicznego przechodzenia
PINNED_AUTO_JSON_IDX=0      # aktualny indeks w PINNED_AUTO_JSON_LIST

# === Sekcja 8 P1: Adaptive batch tuning (8.3) ===
ADAPTIVE_BATCH_ENABLED=true     # włącz adaptive batch (8.3.3)
ADAPTIVE_BATCH_DEFAULT=20       # domyślny batch kluczy/cykl (8.3.1)
ADAPTIVE_BATCH_MIN=5            # minimalny batch (high guard_fail)
ADAPTIVE_BATCH_MAX=50           # maksymalny batch (low guard_fail)
ADAPTIVE_BATCH_WINDOW=10        # ile ostatnich cykli brać pod uwagę
ADAPTIVE_BATCH_HIGH_THRESHOLD=20  # guard_fail_rate% powyżej → zmniejsz batch
ADAPTIVE_BATCH_LOW_THRESHOLD=5    # guard_fail_rate% poniżej → zwiększ batch

# === Sekcja 8 P1: Parallel language processing (8.4) ===
PARALLEL_LANGS_PER_CYCLE=3     # ile języków tłumaczyć w jednym cyklu (8.4.1)
PARALLEL_GT_MAX_RPM=100        # max GT requests/min (8.4.3)

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

extract_auto_result_metric() {
    local line="$1"
    local metric="$2"
    local value
    value=$(printf '%s\n' "$line" | grep -oE "${metric}=[0-9]+" | head -n 1 | cut -d= -f2)
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        value=0
    fi
    echo "$value"
}

extract_quality_metric_number() {
    local line="$1"
    local key="$2"
    python3 - "$line" "$key" << 'PY'
import json
import re
import sys

line = sys.argv[1] if len(sys.argv) > 1 else ""
key = sys.argv[2] if len(sys.argv) > 2 else ""

m = re.search(r"__QUALITY__\s+(\{.*\})", line)
if not m:
    print("0")
    raise SystemExit(0)

try:
    payload = json.loads(m.group(1))
except Exception:
    print("0")
    raise SystemExit(0)

value = payload.get(key, 0)
try:
    if isinstance(value, float):
        print(f"{value:.3f}")
    else:
        print(int(value))
except Exception:
    print("0")
PY
}

ensure_tibia_proper_nouns() {
    local nouns_file="$STATUS_DIR/tibia_proper_nouns.json"
    # Zawsze regeneruj — auto-ekstrakcja z danych EN
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$nouns_file" "$I18N_DIR" << 'PROPER_NOUNS_PY'
import json
import os
import re
import sys

out_path = sys.argv[1]
i18n_dir = sys.argv[2] if len(sys.argv) > 2 else "i18n"
en_dir = os.path.join(i18n_dir, "en")

# ============================================================================
# 1. Hardcoded core terms (cities, regions, vocations, key Tibia terms)
# ============================================================================
CORE_TERMS = [
    # Miasta i regiony
    "Tibia", "Rookgaard", "Thais", "Carlin", "Venore", "Kazordoon", "Ankrahmun",
    "Darashia", "Edron", "Yalahar", "Roshamuul", "Rathleton", "Ab'Dendriel",
    "Svargrond", "Liberty Bay", "Port Hope", "Farmine", "Issavi", "Marapur",
    "Gray Beach", "Bounac", "Azerus", "Oramond", "Falcon Bastion", "Zao",
    "Krailos", "Cormaya", "Fibula", "Mintwallin", "Femor Hills", "Drefia",
    "Demona", "Banuta", "Beregar", "Dawnport", "Feyrist", "Gnomprona",
    "Hrodmir", "Kha'zeel", "Kilmaresh", "Muggy Plains", "Nimmersatt",
    "Opticording", "Ramoa", "Quirefang", "Tiquanda", "Trapwood", "Vengoth",
    "Zao Steppe", "Cyclopolis", "Ghastly Dragon Lair",
    # Klasy / Promocje
    "Knight", "Paladin", "Druid", "Sorcerer",
    "Royal Paladin", "Elite Knight", "Master Sorcerer", "Elder Druid",
    # Bogowie / NPC kluczowi
    "Ferumbras", "Orshabaal", "Morgaroth", "Ghazbaran", "Apocalypse",
    "Durin", "Cipfried", "Henricus", "Rashid", "Nah'Bob", "The Ruthless Seven",
    # Questy kluczowe
    "Pits of Inferno", "Inquisition", "Demon Oak", "Soul War",
    "Forgotten Knowledge", "Wrath of the Emperor", "Children of the Revolution",
    "Dangerous Depths", "Feaster of Souls", "The Dream Courts",
    "Heart of Destruction", "Grimvale", "Cults of Tibia",
    # Systemy gry
    "Exiva", "Prey", "Bestiary", "Imbuing", "Cyclopedia",
    "Party", "Guild", "Market", "Depot",
]

# ============================================================================
# 2. Auto-extract spell words (incantations) — NEVER translate these
# ============================================================================
spell_words = set()
spells_file = os.path.join(en_dir, "spells.json")
if os.path.exists(spells_file):
    try:
        with open(spells_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        for k, v in data.items():
            if k.endswith(".words"):
                word = str(v).strip().strip('"').strip("'")
                if len(word) > 2 and not word.startswith("#"):
                    spell_words.add(word)
    except Exception:
        pass

# ============================================================================
# 3. Auto-extract spell names — keep as reference (not all need protection)
# ============================================================================
spell_names = set()
if os.path.exists(spells_file):
    try:
        with open(spells_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        for k, v in data.items():
            if k.endswith(".name"):
                name = str(v).strip()
                # Only short spell names (long descriptions are translatable)
                if 2 < len(name) <= 40 and not name.startswith("#"):
                    spell_names.add(name)
    except Exception:
        pass

# ============================================================================
# 4. Auto-extract quest names
# ============================================================================
quest_names = set()
quest_file = os.path.join(en_dir, "questlog.json")
if os.path.exists(quest_file):
    try:
        with open(quest_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        for k, v in data.items():
            if k.endswith(".name") or k.endswith(".title"):
                name = str(v).strip()
                if 2 < len(name) <= 60 and not name.startswith("#"):
                    quest_names.add(name)
    except Exception:
        pass

# ============================================================================
# 5. Auto-extract raid names
# ============================================================================
raid_names = set()
raid_file = os.path.join(en_dir, "raids.json")
if os.path.exists(raid_file):
    try:
        with open(raid_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        for k, v in data.items():
            if k.endswith(".name"):
                name = str(v).strip()
                if 2 < len(name) <= 60 and not name.startswith("#"):
                    raid_names.add(name)
    except Exception:
        pass

# ============================================================================
# 6. Build final set — deduplicate and sort
# ============================================================================
all_terms = set(CORE_TERMS)
all_terms.update(spell_words)  # Always protect incantations
# Add top spell names (common ones)
all_terms.update(spell_names)
all_terms.update(quest_names)
all_terms.update(raid_names)

# Remove empty / too short
all_terms = sorted(t for t in all_terms if isinstance(t, str) and len(t.strip()) > 1)

payload = {
    "version": 2,
    "description": "Nazwy własne Tibia - nie tłumaczyć. Auto-generowane z danych EN + ręczne core terms.",
    "auto_generated": True,
    "stats": {
        "core_terms": len(CORE_TERMS),
        "spell_words": len(spell_words),
        "spell_names": len(spell_names),
        "quest_names": len(quest_names),
        "raid_names": len(raid_names),
        "total_unique": len(all_terms),
    },
    "terms": all_terms,
}

os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
tmp = out_path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2, ensure_ascii=False)
os.replace(tmp, out_path)
print(f"tibia_proper_nouns: {len(all_terms)} terms (core={len(CORE_TERMS)}, spells={len(spell_words)+len(spell_names)}, quests={len(quest_names)}, raids={len(raid_names)})")
PROPER_NOUNS_PY
}

apply_manual_review_approvals() {
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$I18N_DIR" "$STATUS_DIR" << 'PY'
import json
import os
import tempfile
import time
import sys

i18n_dir = sys.argv[1]
status_dir = sys.argv[2]
queue_path = os.path.join(status_dir, "manual_review_queue.json")

if not os.path.exists(queue_path):
    payload = {
        "queue": [],
        "stats": {"total": 0, "reviewed": 0, "approved": 0, "rejected": 0, "applied": 0},
        "updated_at": int(time.time()),
    }
    fd, tmp = tempfile.mkstemp(dir=status_dir, suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, queue_path)
    print("0")
    raise SystemExit(0)

try:
    with open(queue_path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {"queue": [], "stats": {}}

queue = data.get("queue", []) if isinstance(data.get("queue", []), list) else []
stats = data.get("stats", {}) if isinstance(data.get("stats", {}), dict) else {}

applied = 0
for item in queue:
    if not isinstance(item, dict):
        continue
    if str(item.get("status", "")).lower() != "approved":
        continue
    if item.get("applied"):
        continue

    lang = str(item.get("lang", "") or "").strip()
    json_file = str(item.get("json_file", "") or "").strip()
    key = str(item.get("key", "") or "").strip()
    approved_translation = item.get("approved_translation")
    if not (lang and json_file and key and isinstance(approved_translation, str) and approved_translation.strip()):
        continue

    target_file = os.path.join(i18n_dir, lang, json_file)
    if not os.path.exists(target_file):
        continue
    try:
        with open(target_file, "r", encoding="utf-8") as f:
            payload = json.load(f)
        if not isinstance(payload, dict):
            continue
    except Exception:
        continue

    payload[key] = approved_translation
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(target_file) or ".", suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, target_file)

    item["applied"] = True
    item["applied_at"] = int(time.time())
    applied += 1

stats["applied"] = int(stats.get("applied", 0) or 0) + applied
data["stats"] = stats
data["updated_at"] = int(time.time())

fd, tmp = tempfile.mkstemp(dir=status_dir, suffix=".tmp")
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
os.replace(tmp, queue_path)
print(str(applied))
PY
}

ensure_external_dictionary_files() {
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    local simple_file="$STATUS_DIR/simple_translations.json"
    local word_file="$STATUS_DIR/word_translations.json"
    if [ -f "$simple_file" ] && [ -f "$word_file" ]; then
        return 0
    fi
    if [ -x "tools/i18n_dictionary_materialize.py" ] || [ -f "tools/i18n_dictionary_materialize.py" ]; then
        python3 tools/i18n_dictionary_materialize.py --i18n-dir "$I18N_DIR" --status-dir "$STATUS_DIR" >/dev/null 2>&1 || true
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
import re
import subprocess
import time
from datetime import datetime, timedelta, timezone

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
        if os.path.isdir(path) and re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
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

inventory_cache_path = os.path.join(I18N_DIR, "status", "project_file_inventory_cache.json")
inventory_cache_ttl = 600
try:
    inventory_cache_ttl = max(30, int(os.environ.get("STATUS_PROJECT_SCAN_TTL_SEC", "600") or 600))
except Exception:
    inventory_cache_ttl = 600

inventory_cache_used = False
try:
    if os.path.exists(inventory_cache_path):
        with open(inventory_cache_path, "r", encoding="utf-8") as f:
            inv = json.load(f)
        inv_ts = int(inv.get("timestamp", 0) or 0)
        if inv_ts > 0 and (int(time.time()) - inv_ts) <= inventory_cache_ttl:
            all_project_files = int(inv.get("all_project_files", 0) or 0)
            fb = inv.get("files_by_type", {})
            files_by_type = fb if isinstance(fb, dict) else {}
            inventory_cache_used = True
except Exception:
    inventory_cache_used = False

if not inventory_cache_used:
    for root, dirs, flist in os.walk('.'):
        # Pomijaj foldery które nie są częścią projektu
        dirs[:] = [d for d in dirs if d not in ['vcpkg', 'build', '.git', 'node_modules', 'html_copy', 'oryginall', '__pycache__', 'large_files_zip']]
        for fname in flist:
            all_project_files += 1
            ext = os.path.splitext(fname)[1].lower()
            if ext:
                files_by_type[ext] = files_by_type.get(ext, 0) + 1

    try:
        os.makedirs(os.path.join(I18N_DIR, "status"), exist_ok=True)
        inv_out = {
            "timestamp": int(time.time()),
            "ttl_sec": int(inventory_cache_ttl),
            "all_project_files": int(all_project_files),
            "files_by_type": files_by_type,
        }
        tmp_inv = inventory_cache_path + ".tmp"
        with open(tmp_inv, "w", encoding="utf-8") as f:
            json.dump(inv_out, f, indent=2, ensure_ascii=False)
        os.replace(tmp_inv, inventory_cache_path)
    except Exception:
        pass

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

# 3b. PRZESKANOWANE LIVE (z i18n_file_status.json, niezależnie od processed_files.txt)
# To lepiej odzwierciedla stan po ręcznych zmianach w repo.
scanned_files_live_raw = len(files)
scanned_files_live = min(scannable_files, scanned_files_live_raw) if scannable_files > 0 else scanned_files_live_raw
scanned_files_live = max(0, scanned_files_live)

# 4. ANALIZA STATUSÓW PLIKÓW
files_migrated = 0       # Mają klucze i18n
files_needs_migration = 0  # Trzeba dodać i18n
files_clean = 0          # Czyste (bez tekstów do tłumaczenia)
files_in_progress = 0    # W trakcie przetwarzania
total_keys_extracted_registry = 0

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
            total_keys_extracted_registry += keys
        else:
            # Sprawdź czy plik miał teksty do migracji
            analysis = stages.get('2_analysis', {})
            if analysis.get('needs_migration', False):
                files_needs_migration += 1
            else:
                files_clean += 1

# Backward-compat dla starszych odwołań w skrypcie.
total_keys_extracted = total_keys_extracted_registry

# 5. DO ZROBIENIA
files_not_scanned = scannable_files - scanned_files
files_not_scanned_live = max(0, scannable_files - scanned_files_live)
files_to_migrate = files_needs_migration

# 6. JĘZYKI - szczegółowa analiza
translated_langs = 0
prepared_langs = 0
prepared_lang_codes = set()
langs_with_real_translations = []
langs_with_placeholders_only = []

for lang_dir in ALL_LANGUAGES:
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
        prepared_lang_codes.add(lang_dir)
        if has_real_translations:
            translated_langs += 1
            langs_with_real_translations.append(lang_dir)
        else:
            langs_with_placeholders_only.append(lang_dir)

# 7. PROCENTY
scanned_pct = round(scanned_files / scannable_files * 100, 1) if scannable_files > 0 else 0
scanned_live_pct = round(scanned_files_live / scannable_files * 100, 1) if scannable_files > 0 else 0
migrated_pct = round(files_migrated / scanned_files * 100, 1) if scanned_files > 0 else 0
translated_pct = round(translated_langs / langs_count * 100, 1) if langs_count > 0 else 0
scan_history_minus_live = scanned_files - scanned_files_live

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

# Auto-adjust targets na podstawie aktualnych wartości — WSZYSTKIE kategorie z en/
category_current = dict(all_json_categories)  # dynamicznie z i18n/en/*.json
for cat, cur in category_current.items():
    if cat in TARGETS:
        TARGETS[cat] = auto_adjust_target(cur, TARGETS[cat])
    else:
        # Nowa kategoria bez zdefiniowanego celu — generuj automatycznie
        TARGETS[cat] = auto_adjust_target(cur, max(cur, 100))

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

# Generuj timestamp (UTC, spójny z heartbeat/reportami)
timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')

# Pre-compute roadmap values for table — dynamicznie z all_json_categories
CATEGORY_ICONS = {
    "achievements": "🏆", "actions": "⚡", "books": "📖", "chatchannels": "💬",
    "client": "🖥️", "cpp": "⚙️", "creaturescripts": "🐾", "dataroot": "📂",
    "errors": "❌", "events": "🎉", "globalevents": "🌐", "html": "🌍",
    "items": "🎒", "libs": "📚", "messages": "✉️", "modules": "📦",
    "monsters": "👹", "mounts": "🐴", "movements": "🚶", "npc": "🧙",
    "npclib": "📜", "otclient_data": "📊", "otclient_mods": "🔧",
    "otclient_modules": "🧩", "otclient_src": "💻", "otclient_tools": "🛠️",
    "php": "🐘", "questlog": "📋", "quests": "🗡️", "raids": "⚔️",
    "scripts": "📜", "server": "🖧", "spells": "✨", "startup": "🚀",
    "system": "🖥️", "talkactions": "🗣️", "ui": "🎨", "world": "🌎",
}
roadmap_rows_list = []
for cat in sorted(all_json_categories.keys()):
    cur = all_json_categories[cat]
    tgt = TARGETS.get(cat, cur)
    icon = CATEGORY_ICONS.get(cat, "📁")
    pct = round(cur / tgt * 100) if tgt else 0
    roadmap_rows_list.append(
        f"| {icon} {cat.capitalize()} | {cur} | {progress_bar(cur, tgt)} | {tgt} | {status_icon(cur, tgt)} {pct}% |"
    )
roadmap_table = chr(10).join(roadmap_rows_list)

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

LANG_NAMES = {
    "pl": "Polski",
    "tr": "Turecki",
    "de": "Niemiecki",
    "es": "Hiszpański",
    "pt": "Portugalski",
    "ru": "Rosyjski",
    "fr": "Francuski",
    "it": "Włoski",
    "sv": "Szwedzki",
    "ro": "Rumuński",
    "cs": "Czeski",
    "sk": "Słowacki",
    "hu": "Węgierski",
    "nl": "Niderlandzki",
    "uk": "Ukraiński",
    "ar": "Arabski",
    "zh": "Chiński",
    "ja": "Japoński",
    "ko": "Koreański",
}

CLIENT_CATEGORIES = {
    "client", "php", "html", "ui", "otclient_modules", "otclient_data",
    "otclient_src", "otclient_mods", "otclient_tools"
}

def _lang_name(code: str) -> str:
    return LANG_NAMES.get(str(code or "").lower(), str(code or "").upper())

def _scope_from_json(json_file: str) -> str:
    cat = os.path.splitext(os.path.basename(str(json_file or "")))[0].lower()
    return "Klient" if cat in CLIENT_CATEGORIES else "Serwer"

def _is_likely_proper_noun_status(key, en_value):
    """Heurystyka: klucz, którego wartość EN jest prawdopodobnie nazwą własną."""
    proper_noun_prefixes = (
        "item.", "monster.", "spell.", "mount.", "quest.", "raid.",
        "achievement.", "npc.", "book.otbm."
    )
    proper_noun_suffixes = (".name", ".words", ".title", ".desc", ".announce")
    if any(key.startswith(p) for p in proper_noun_prefixes):
        if any(key.endswith(s) for s in proper_noun_suffixes):
            return True
        # Short text (1-4 words) starting with uppercase under proper-noun prefix
        words = en_value.strip().split()
        if words and len(words) <= 4 and words[0][0:1].isupper():
            return True
    if len(en_value.strip()) <= 3:
        return True
    stripped = en_value.strip()
    if stripped and all(c.isupper() or c.isdigit() or c in ".-_/ " for c in stripped):
        return True
    return False

def _is_untranslated(value, en_value, key=""):
    if value is None:
        return True
    text = str(value)
    if text.startswith("["):
        return True
    if text.strip() == "":
        return True
    if text == str(en_value):
        # Nazwy własne identyczne z EN to poprawne tłumaczenia
        if _is_likely_proper_noun_status(key, str(en_value)):
            return False
        return True
    return False

translation_lang_overview = []
translation_global = {
    "total_reference_keys": 0,
    "translated_keys": 0,
    "english_copy_keys": 0,
    "missing_keys": 0,
    "missing_files": 0,
}

en_json_dir = os.path.join(I18N_DIR, "en")
en_json_files_all = sorted([f for f in os.listdir(en_json_dir) if f.endswith(".json")]) if os.path.isdir(en_json_dir) else []
if SCOPE in ("server", "canary", "server_only", "server-only"):
    en_json_files = [
        jf for jf in en_json_files_all
        if os.path.splitext(jf)[0].lower() not in CLIENT_CATEGORIES
    ]
else:
    en_json_files = en_json_files_all

en_file_key_count = {}
for jf in en_json_files:
    try:
        with open(os.path.join(I18N_DIR, "en", jf), encoding="utf-8") as f:
            en_file_key_count[jf] = len(json.load(f))
    except Exception:
        en_file_key_count[jf] = 0

# Jedno źródło prawdy dla licznika kluczy EN używanego w dashboardzie.
total_keys = int(sum(en_file_key_count.values()))
total_keys_extracted_live = int(total_keys)
keys_extracted_outside_worker = max(0, total_keys_extracted_live - total_keys_extracted_registry)

# Preload EN dane raz na przebieg STATUSPY (P3 cold-path optimization)
en_data_cache = {}
for jf in en_json_files:
    en_path = os.path.join(I18N_DIR, "en", jf)
    try:
        with open(en_path, encoding="utf-8") as f:
            en_data_cache[jf] = json.load(f)
    except Exception:
        en_data_cache[jf] = None

status_translation_dir = os.path.join(I18N_DIR, "status")
os.makedirs(status_translation_dir, exist_ok=True)
lang_stats_cache_path = os.path.join(status_translation_dir, "translation_lang_stats_cache.json")

def _safe_stat_sig(path: str):
    try:
        st = os.stat(path)
        return [int(st.st_mtime_ns), int(st.st_size)]
    except Exception:
        return [0, 0]

en_signature = []
for jf in en_json_files:
    en_path = os.path.join(I18N_DIR, "en", jf)
    sig = _safe_stat_sig(en_path)
    en_signature.append([jf, sig[0], sig[1], int(en_file_key_count.get(jf, 0))])

cache_payload = {}
cache_langs = {}
cache_valid = False
try:
    if os.path.exists(lang_stats_cache_path):
        with open(lang_stats_cache_path, "r", encoding="utf-8") as f:
            cache_payload = json.load(f)
        cache_langs = cache_payload.get("langs", {}) if isinstance(cache_payload.get("langs", {}), dict) else {}
        cache_valid = (
            cache_payload.get("version") == 2
            and cache_payload.get("scope") == SCOPE
            and cache_payload.get("en_signature") == en_signature
            and cache_payload.get("en_total_keys") == int(total_keys)
        )
except Exception:
    cache_payload = {}
    cache_langs = {}
    cache_valid = False

cache_hits = 0
cache_misses = 0
file_cache_hits = 0
file_cache_misses = 0
new_cache_langs = {}

def _compute_lang_file_row(lang: str, jf: str, en_data):
    if not isinstance(en_data, dict):
        return {
            "total_reference_keys": 0,
            "translated_keys": 0,
            "english_copy_keys": 0,
            "missing_keys": 0,
            "missing_files": 0,
        }

    lang_path = os.path.join(I18N_DIR, lang, jf)
    total_reference = int(en_file_key_count.get(jf, len(en_data)))
    translated_ok = 0
    english_copy = 0
    missing_keys = 0
    missing_files = 0

    if not os.path.exists(lang_path):
        return {
            "total_reference_keys": total_reference,
            "translated_keys": 0,
            "english_copy_keys": 0,
            "missing_keys": int(len(en_data)),
            "missing_files": 1,
        }

    try:
        with open(lang_path, encoding="utf-8") as f:
            lang_data = json.load(f)
    except Exception:
        return {
            "total_reference_keys": total_reference,
            "translated_keys": 0,
            "english_copy_keys": 0,
            "missing_keys": int(len(en_data)),
            "missing_files": 1,
        }

    for k, en_text in en_data.items():
        if k not in lang_data:
            missing_keys += 1
            continue
        tr_val = lang_data.get(k)
        if str(tr_val) == str(en_text):
            english_copy += 1
        if not _is_untranslated(tr_val, en_text, k):
            translated_ok += 1

    return {
        "total_reference_keys": int(total_reference),
        "translated_keys": int(translated_ok),
        "english_copy_keys": int(english_copy),
        "missing_keys": int(missing_keys),
        "missing_files": int(missing_files),
    }

for lang in [l for l in ALL_LANGUAGES if l != "en"]:
    lang_sig = []
    lang_sig_by_file = {}
    for jf in en_json_files:
        lang_path = os.path.join(I18N_DIR, lang, jf)
        if os.path.exists(lang_path):
            sig = _safe_stat_sig(lang_path)
            sig_row = [1, sig[0], sig[1]]
            lang_sig.append([jf, sig_row[0], sig_row[1], sig_row[2]])
            lang_sig_by_file[jf] = sig_row
        else:
            sig_row = [0, 0, 0]
            lang_sig.append([jf, sig_row[0], sig_row[1], sig_row[2]])
            lang_sig_by_file[jf] = sig_row

    cached_entry = cache_langs.get(lang, {}) if cache_valid else {}
    cached_files = cached_entry.get("files") if isinstance(cached_entry.get("files"), dict) else {}
    new_files = {}

    total_reference = 0
    translated_ok = 0
    english_copy = 0
    missing_keys = 0
    missing_files = 0
    # Scope breakdown: serwer vs instalka (klient)
    server_reference = 0
    server_translated = 0
    client_reference = 0
    client_translated = 0

    lang_all_files_from_cache = cache_valid and bool(cached_files)

    for jf in en_json_files:
        current_file_sig = lang_sig_by_file.get(jf, [0, 0, 0])
        cached_file = cached_files.get(jf, {}) if cache_valid else {}
        cached_file_sig = cached_file.get("sig") if isinstance(cached_file.get("sig"), list) else None
        cached_file_row = cached_file.get("row") if isinstance(cached_file.get("row"), dict) else None

        if cache_valid and cached_file_row and cached_file_sig == current_file_sig:
            file_row = cached_file_row
            file_cache_hits += 1
        else:
            file_row = _compute_lang_file_row(lang, jf, en_data_cache.get(jf))
            file_cache_misses += 1
            lang_all_files_from_cache = False

        new_files[jf] = {
            "sig": current_file_sig,
            "row": file_row,
        }

        fr_ref = int(file_row.get("total_reference_keys", 0) or 0)
        fr_tr = int(file_row.get("translated_keys", 0) or 0)
        total_reference += fr_ref
        translated_ok += fr_tr
        english_copy += int(file_row.get("english_copy_keys", 0) or 0)
        missing_keys += int(file_row.get("missing_keys", 0) or 0)
        missing_files += int(file_row.get("missing_files", 0) or 0)

        # Scope breakdown
        jf_cat = os.path.splitext(jf)[0].lower()
        if jf_cat in CLIENT_CATEGORIES:
            client_reference += fr_ref
            client_translated += fr_tr
        else:
            server_reference += fr_ref
            server_translated += fr_tr

    completion = round((translated_ok / total_reference) * 100, 2) if total_reference else 0.0
    server_pct = round((server_translated / server_reference) * 100, 2) if server_reference else 0.0
    client_pct = round((client_translated / client_reference) * 100, 2) if client_reference else 0.0
    row = {
        "lang": lang,
        "language_name": _lang_name(lang),
        "scope": "global",
        "total_reference_keys": int(total_reference),
        "translated_keys": int(translated_ok),
        "english_copy_keys": int(english_copy),
        "missing_keys": int(missing_keys),
        "missing_files": int(missing_files),
        "completion_pct": completion,
        "server_keys": int(server_reference),
        "server_translated": int(server_translated),
        "server_pct": server_pct,
        "client_keys": int(client_reference),
        "client_translated": int(client_translated),
        "client_pct": client_pct,
    }

    if lang_all_files_from_cache:
        cache_hits += 1
    else:
        cache_misses += 1

    translation_lang_overview.append(row)
    new_cache_langs[lang] = {
        "sig": lang_sig,
        "row": row,
        "files": new_files,
    }

    translation_global["total_reference_keys"] += int(row.get("total_reference_keys", 0) or 0)
    translation_global["translated_keys"] += int(row.get("translated_keys", 0) or 0)
    translation_global["english_copy_keys"] += int(row.get("english_copy_keys", 0) or 0)
    translation_global["missing_keys"] += int(row.get("missing_keys", 0) or 0)
    translation_global["missing_files"] += int(row.get("missing_files", 0) or 0)

try:
    cache_out = {
        "version": 2,
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "scope": SCOPE,
        "en_total_keys": int(total_keys),
        "en_signature": en_signature,
        "cache_hits": int(cache_hits),
        "cache_misses": int(cache_misses),
        "file_cache_hits": int(file_cache_hits),
        "file_cache_misses": int(file_cache_misses),
        "langs": new_cache_langs,
    }
    tmp_path = lang_stats_cache_path + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(cache_out, f, indent=2, ensure_ascii=False)
    os.replace(tmp_path, lang_stats_cache_path)
except Exception:
    pass

cache_hit_pct = round((cache_hits / max(cache_hits + cache_misses, 1)) * 100, 1)
file_cache_hit_pct = round((file_cache_hits / max(file_cache_hits + file_cache_misses, 1)) * 100, 1)
cache_mode_label = "warm-cache" if cache_hits > 0 and cache_misses == 0 else ("mixed" if cache_hits > 0 and cache_misses > 0 else "cold-cache")

translation_lang_overview.sort(key=lambda x: (-x.get("completion_pct", 0), x.get("lang", "")))

# Urealnij metrykę "Przetłumaczone": język liczony jako gotowy, jeśli ma >=95% pokrycia
# i 0 brakujących kluczy (dla języków faktycznie przygotowanych w i18n/<lang>/).
translated_langs = sum(
    1 for row in translation_lang_overview
    if row.get("lang") in prepared_lang_codes
    and float(row.get("completion_pct", 0.0) or 0.0) >= 95.0
    and int(row.get("missing_keys", 0) or 0) == 0
)
translated_pct = round(translated_langs / prepared_langs * 100, 1) if prepared_langs > 0 else 0

language_rows = []
for row in translation_lang_overview[:20]:
    language_rows.append(
        f"| {row['lang'].upper()} ({row['language_name']}) | {int(row['translated_keys']):,}/{int(row['total_reference_keys']):,} | {row['completion_pct']:.2f}% | {int(row['english_copy_keys']):,} | {int(row['missing_keys']):,} |"
    )
translation_lang_table = "\n".join(language_rows) if language_rows else "| - | - | - | - | - |"

global_completion_pct = round((translation_global["translated_keys"] / max(translation_global["total_reference_keys"], 1)) * 100, 2)

def _count_jsonl(path: str):
    total = 0
    blocked = 0
    if not os.path.exists(path):
        return total, blocked
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                total += 1
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                gf = int(obj.get("guard_fail", 0) or 0)
                smf = int(obj.get("strict_missing_file", 0) or 0)
                smk = int(obj.get("strict_missing_key", 0) or 0)
                ssd = int(obj.get("strict_skipped_done", 0) or 0)
                if gf > 0 or smf > 0 or smk > 0 or ssd > 0:
                    blocked += 1
    except Exception:
        pass
    return total, blocked

guard_total, guard_blocked = _count_jsonl(os.path.join(status_translation_dir, "translation_guard_report.jsonl"))
blockers_total, _ = _count_jsonl(os.path.join(status_translation_dir, "translation_blockers_report.jsonl"))
cannot_translate_reports = int(guard_blocked + blockers_total)

recent_translation_entry = {}
recent_translations = []
try:
    recent_path = os.path.join(status_translation_dir, "translation_recent_latest.json")
    if os.path.exists(recent_path):
        with open(recent_path, "r", encoding="utf-8") as f:
            recent_translation_entry = json.load(f)
        if isinstance(recent_translation_entry.get("entries", []), list):
            recent_translations = recent_translation_entry.get("entries", [])[-20:]
except Exception:
    recent_translation_entry = {}
    recent_translations = []

translation_guard_latest = {}
try:
    guard_latest_path = os.path.join(status_translation_dir, "translation_guard_latest.json")
    if os.path.exists(guard_latest_path):
        with open(guard_latest_path, "r", encoding="utf-8") as f:
            translation_guard_latest = json.load(f)
except Exception:
    translation_guard_latest = {}

recent_translation_md = "\n".join(
    [f"- {str(it.get('en', ''))[:80]} → {str(it.get('translated', ''))[:80]} ({it.get('key', '-')})" for it in recent_translations[-20:]]
) if recent_translations else "- Brak nowych tłumaczeń w ostatnim cyklu"

perf_latest = {}
perf_summary_md = "-"
try:
    perf_path = os.path.join(status_translation_dir, "worker_cycle_perf_latest.json")
    if os.path.exists(perf_path):
        with open(perf_path, "r", encoding="utf-8") as f:
            perf_latest = json.load(f)
except Exception:
    perf_latest = {}

try:
    events = perf_latest.get("events", {}) if isinstance(perf_latest.get("events", {}), dict) else {}
    dispatch_ms = int(events.get("dispatch", 0) or 0)
    mode_run_ms = int(events.get("mode_run", 0) or 0)
    status_update_ms = int(events.get("status_update", 0) or 0)
    cycle_total_ms = int(events.get("cycle_total", 0) or 0)
    perf_cycle = int(perf_latest.get("cycle", 0) or 0)
    perf_mode = str(perf_latest.get("mode", "-") or "-")
    if cycle_total_ms > 0:
        perf_summary_md = (
            f"cykl #{perf_cycle} ({perf_mode}): dispatch {dispatch_ms}ms, "
            f"mode {mode_run_ms}ms, status {status_update_ms}ms, total {cycle_total_ms}ms"
        )
except Exception:
    perf_summary_md = "-"


def _parse_iso_any(value):
    if value is None:
        return None
    try:
        if isinstance(value, (int, float)):
            return datetime.fromtimestamp(float(value), tz=timezone.utc)
        text = str(value).strip()
        if not text:
            return None
        if text.endswith("Z"):
            text = text[:-1] + "+00:00"
        dt = datetime.fromisoformat(text)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    except Exception:
        return None


def _jsonl_window(path: str, cutoff_dt: datetime):
    rows = []
    if not os.path.exists(path):
        return rows
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                ts = _parse_iso_any(obj.get("timestamp"))
                if ts and ts >= cutoff_dt:
                    rows.append(obj)
    except Exception:
        pass
    return rows


# ============================================================================
# STRICT HOURLY WINDOW (JSONL-only contract)
# ============================================================================
strict_window_hours = 1.0
try:
    strict_window_hours = float(os.environ.get("STATUS_STRICT_WINDOW_HOURS", "1") or "1")
except Exception:
    strict_window_hours = 1.0
if strict_window_hours <= 0:
    strict_window_hours = 1.0

strict_now = datetime.now(timezone.utc)
strict_cutoff = strict_now - timedelta(hours=strict_window_hours)

strict_perf_entries = _jsonl_window(
    os.path.join(status_translation_dir, "worker_cycle_perf.jsonl"),
    strict_cutoff,
)
strict_guard_entries = _jsonl_window(
    os.path.join(status_translation_dir, "translation_guard_report.jsonl"),
    strict_cutoff,
)
strict_susp_entries = _jsonl_window(
    os.path.join(status_translation_dir, "suspicious_log.jsonl"),
    strict_cutoff,
)

strict_mode_counts = {}
strict_migration_cats = {}
strict_duration_ms = 0
for _row in strict_perf_entries:
    _mode = str(_row.get("mode", "?") or "?")
    _cat = str(_row.get("category", "?") or "?")
    strict_mode_counts[_mode] = int(strict_mode_counts.get(_mode, 0)) + 1
    strict_duration_ms += int(_row.get("duration_ms", 0) or 0)
    if _mode == "MIGRATION":
        strict_migration_cats[_cat] = int(strict_migration_cats.get(_cat, 0)) + 1

strict_total_cycles = len(strict_perf_entries)
strict_migration_cycles = int(strict_mode_counts.get("MIGRATION", 0))
strict_pending_skip_count = int(strict_migration_cats.get("pending_skip", 0))
strict_pending_skip_share_total = (
    strict_pending_skip_count / strict_total_cycles if strict_total_cycles > 0 else 0.0
)
strict_pending_skip_share_migration = (
    strict_pending_skip_count / strict_migration_cycles if strict_migration_cycles > 0 else 0.0
)

strict_translated = 0
strict_guard_fail = 0
strict_no_progress_entries = 0
strict_targets = {}
for _row in strict_guard_entries:
    _translated = int(_row.get("translated", 0) or 0)
    _guard_fail = int(_row.get("guard_fail", 0) or 0)
    strict_translated += _translated
    strict_guard_fail += _guard_fail
    if _translated == 0:
        strict_no_progress_entries += 1

    _lang = str(_row.get("language", "?") or "?").lower()
    _file = str(_row.get("json_file", "?") or "?")
    _key = f"{_lang}/{_file}"
    _tg = strict_targets.get(
        _key,
        {"target": _key, "translated": 0, "guard_fail": 0, "guard_command": 0},
    )
    _tg["translated"] += _translated
    _tg["guard_fail"] += _guard_fail
    _guard_obj = _row.get("guard") if isinstance(_row.get("guard"), dict) else {}
    _tg["guard_command"] += int(_guard_obj.get("command", 0) or 0)
    strict_targets[_key] = _tg

strict_attempts = strict_translated + strict_guard_fail
strict_guard_fail_rate = (strict_guard_fail / strict_attempts) if strict_attempts > 0 else 0.0
strict_no_progress_rate = (
    strict_no_progress_entries / len(strict_guard_entries) if len(strict_guard_entries) > 0 else 0.0
)
strict_runtime_h = strict_duration_ms / 3600000.0 if strict_duration_ms > 0 else strict_window_hours
strict_throughput = strict_translated / strict_runtime_h if strict_runtime_h > 0 else 0.0
strict_top_guard_fail_targets = sorted(
    strict_targets.values(),
    key=lambda x: int(x.get("guard_fail", 0)),
    reverse=True,
)[:8]

strict_window_payload = {
    "window_start_utc": strict_cutoff.isoformat().replace("+00:00", "Z"),
    "window_end_utc": strict_now.isoformat().replace("+00:00", "Z"),
    "window_hours": round(strict_window_hours, 3),
    "sources": [
        "i18n/status/worker_cycle_perf.jsonl",
        "i18n/status/translation_guard_report.jsonl",
        "i18n/status/suspicious_log.jsonl",
    ],
    "total_cycles": strict_total_cycles,
    "mode_distribution": strict_mode_counts,
    "auto_translate_cycles": int(strict_mode_counts.get("AUTO_TRANSLATE", 0)),
    "migration_cycles": strict_migration_cycles,
    "pending_skip_count": strict_pending_skip_count,
    "pending_skip_share_pct": round(strict_pending_skip_share_total * 100, 1),
    "pending_skip_share_migration_pct": round(strict_pending_skip_share_migration * 100, 1),
    "translated": strict_translated,
    "guard_fail": strict_guard_fail,
    "guard_fail_rate_pct": round(strict_guard_fail_rate * 100, 1),
    "no_progress_entries": strict_no_progress_entries,
    "no_progress_rate_pct": round(strict_no_progress_rate * 100, 1),
    "throughput_keys_per_h": round(strict_throughput, 1),
    "suspicious_total": len(strict_susp_entries),
    "top_guard_fail_targets": strict_top_guard_fail_targets,
}

strict_summary_md = (
    f"okno={strict_window_payload['window_hours']}h | cycles={strict_total_cycles} | "
    f"pending_skip={strict_window_payload['pending_skip_share_pct']}% | "
    f"guard_fail={strict_window_payload['guard_fail_rate_pct']}% | "
    f"throughput={strict_window_payload['throughput_keys_per_h']}/h"
)
strict_sources_md = ", ".join([f"`{p}`" for p in strict_window_payload["sources"]])
strict_top_targets_md = ", ".join(
    [
        f"{it.get('target')} (gf={int(it.get('guard_fail', 0) or 0)})"
        for it in strict_top_guard_fail_targets[:5]
    ]
) if strict_top_guard_fail_targets else "-"

try:
    with open(os.path.join(status_translation_dir, "strict_hourly_window_latest.json"), "w", encoding="utf-8") as f:
        json.dump(strict_window_payload, f, indent=2, ensure_ascii=False)
except Exception:
    pass

quality_audit_latest = {}
quality_dashboard = {}
quality_summary_md = "-"
quality_top_issues_md = "-"
quality_worst_langs_md = "-"
try:
    qa_path = os.path.join(status_translation_dir, "quality_audit_latest.json")
    if os.path.exists(qa_path):
        with open(qa_path, "r", encoding="utf-8") as f:
            quality_audit_latest = json.load(f)
except Exception:
    quality_audit_latest = {}

try:
    qd_path = os.path.join(status_translation_dir, "quality_dashboard.json")
    if os.path.exists(qd_path):
        with open(qd_path, "r", encoding="utf-8") as f:
            quality_dashboard = json.load(f)
except Exception:
    quality_dashboard = {}

try:
    qa_checked = int(quality_audit_latest.get("checked_entries", 0) or 0)
    qa_issues = int(quality_audit_latest.get("issues_found", 0) or 0)
    qa_ts = str(quality_audit_latest.get("timestamp", "-") or "-")
    qa_slow = bool(quality_audit_latest.get("slow_mode", False))
    qa_status = "SLOW_MODE" if qa_slow else "OK"
    if qa_checked > 0 or qa_issues > 0:
        quality_summary_md = f"{qa_status} | {qa_issues} issue(s) / {qa_checked} entries | {qa_ts}"

    by_type = quality_audit_latest.get("issues_by_type", {}) if isinstance(quality_audit_latest.get("issues_by_type", {}), dict) else {}
    top_types = sorted(by_type.items(), key=lambda x: int(x[1] or 0), reverse=True)[:5]
    if top_types:
        quality_top_issues_md = ", ".join([f"{k}={int(v or 0)}" for k, v in top_types])

    lang_rows = []
    for lang, row in (quality_dashboard.items() if isinstance(quality_dashboard, dict) else []):
        if not isinstance(row, dict):
            continue
        score = float(row.get("quality_score", 100.0) or 100.0)
        cnt = int(row.get("issues_count", 0) or 0)
        lang_rows.append((lang, score, cnt))
    worst = sorted(lang_rows, key=lambda x: (x[1], -x[2], x[0]))[:5]
    if worst:
        quality_worst_langs_md = ", ".join([f"{lang}({score:.1f}, issues={cnt})" for lang, score, cnt in worst])
except Exception:
    pass

overview_payload = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "global": {
        **translation_global,
        "completion_pct": global_completion_pct,
    },
    "migration": {
        "files_total": len(files),
        "files_completed": completed,
        "scanned_files_history": scanned_files,
        "scanned_files_live": scanned_files_live,
        "scanned_files_history_pct": scanned_pct,
        "scanned_files_live_pct": scanned_live_pct,
        "files_not_scanned_history": files_not_scanned,
        "files_not_scanned_live": files_not_scanned_live,
        "scanned_files_history_minus_live": scan_history_minus_live,
        "files_migrated": files_migrated,
        "files_in_progress": files_in_progress,
        "files_needs_migration": files_needs_migration,
        "files_clean": files_clean,
        "total_keys_extracted": total_keys_extracted_live,
        "total_keys_extracted_live": total_keys_extracted_live,
        "total_keys_extracted_worker_registry": total_keys_extracted_registry,
        "keys_extracted_outside_worker_registry": keys_extracted_outside_worker,
        "npc_total": total_npc,
        "npc_migrated": migrated_npc,
        "npc_needs_migration": needs_migration_npc,
    },
    "scope_totals": {
        "server_keys": int(sum(en_file_key_count.get(f, 0) for f in en_json_files if os.path.splitext(f)[0].lower() not in CLIENT_CATEGORIES)),
        "client_keys": int(sum(en_file_key_count.get(f, 0) for f in en_json_files if os.path.splitext(f)[0].lower() in CLIENT_CATEGORIES)),
        "client_categories": sorted(list(CLIENT_CATEGORIES)),
    },
    "reports": {
        "guard_reports_total": guard_total,
        "guard_reports_blocked": guard_blocked,
        "blockers_reports_total": blockers_total,
        "cannot_translate_reports_visible": cannot_translate_reports,
    },
    "cache": {
        "lang_stats_hits": int(cache_hits),
        "lang_stats_misses": int(cache_misses),
        "lang_stats_hit_pct": cache_hit_pct,
        "lang_stats_mode": cache_mode_label,
        "lang_file_hits": int(file_cache_hits),
        "lang_file_misses": int(file_cache_misses),
        "lang_file_hit_pct": file_cache_hit_pct,
        "lang_stats_cache_file": "i18n/status/translation_lang_stats_cache.json",
    },
    "profiler_latest": perf_latest,
    "strict_hourly_window": strict_window_payload,
    "quality": {
        "audit_latest": quality_audit_latest,
        "dashboard": quality_dashboard,
        "summary": quality_summary_md,
    },
    "languages": translation_lang_overview,
}
try:
    with open(os.path.join(status_translation_dir, "translation_global_overview.json"), "w", encoding="utf-8") as f:
        json.dump(overview_payload, f, indent=2, ensure_ascii=False)
except Exception:
    pass

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
stale_threshold_seconds = 360  # 6 min, bo IDLE sleep = 300s + margines
is_stale = bool(heartbeat_iso) and heartbeat_age >= stale_threshold_seconds

# Dane specyficzne dla trybu
migration_data = global_stats.get("migration", {})
translation_sync_data_gs = global_stats.get("translation_sync", {})
auto_translate_data = global_stats.get("auto_translate", {})
idle_data = global_stats.get("idle", {})
translations_only_mode = (os.environ.get("TRANSLATIONS_ONLY", "false") or "false").lower() == "true"

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
    at_guard_fail = auto_translate_data.get("guard_fail", 0)
    at_strict_missing = auto_translate_data.get("strict_missing_key", 0)
    at_recent = auto_translate_data.get("recent_translated", 0)
    at_scope = _scope_from_json(at_file)
    at_lang_name = _lang_name(at_lang)
    at_folder_label = f"{str(at_lang).upper()} - {at_lang_name} - {at_scope}"
    category_display = f"🤖 {at_lang.upper()}/{at_file}"
    
    live_details = f"""│ 📊 Automatyczne tłumaczenie                                       │
│    ├─ Folder:         {at_folder_label[:28]:>28}                       │
│    ├─ Plik:           {at_file:>20}                       │
│    ├─ Kluczy:         {at_keys:>6}                                 │
│    ├─ Ostatnio:       {at_recent:>6} przetłumaczonych                  │
│    └─ Guard/Strict:   {at_guard_fail:>3}/{at_strict_missing:>3}                              │"""

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
    
    if translations_only_mode:
        blocker = auto_translate_data.get("strict_blocker", "")
        live_details = f"""│ 📊 Tryb IDLE - strict tłumaczenia                                 │
│    ├─ Blokery:        {(blocker or 'brak'):>20}                       │
│    └─ Problemy TM:    {quality_issues:>6}                                 │"""
    else:
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

if translations_only_mode:
    mode_display = f"{mode_display} | STRICT"

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

active_lang = str(auto_translate_data.get("language", "") or recent_translation_entry.get("language", "") or "-")
active_file = str(auto_translate_data.get("json_file", "") or recent_translation_entry.get("json_file", "") or "-")
active_scope = _scope_from_json(active_file) if active_file not in ("", "-") else "-"
active_lang_name = _lang_name(active_lang) if active_lang not in ("", "-") else "-"
active_folder_display = f"{active_lang.upper()} - {active_lang_name} - {active_scope}" if active_lang not in ("", "-") else "-"
recent_count = len(recent_translations)
report_counter_md = f"- Guard reports: **{guard_total}**  \n- Blocker reports: **{blockers_total}**  \n- Widoczne raporty 'nie mogę tłumaczyć': **{cannot_translate_reports}**"

# ============ SECTION METADATA (P0.1 Spójny status) ============
_now_utc = datetime.now(timezone.utc)

def _section_state(phase_list, current_phase):
    """Returns (state_label, reason) based on current worker mode."""
    current = str(current_phase or "").upper()
    if current in [p.upper() for p in phase_list]:
        return ("🟢 ACTIVE", "")
    return ("🔒 INACTIVE", f"worker w trybie {current}")

def _freshness_label(iso_or_ts):
    """Human-readable freshness from ISO timestamp or unix timestamp."""
    if not iso_or_ts:
        return "brak danych"
    try:
        if isinstance(iso_or_ts, (int, float)):
            dt = datetime.fromtimestamp(float(iso_or_ts), tz=timezone.utc)
        else:
            dt = _parse_iso_z(str(iso_or_ts))
        if not dt:
            return "?"
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        age = (_now_utc - dt).total_seconds()
        if age < 0:
            return "przyszłość?"
        if age < 60:
            return f"{int(age)}s temu"
        if age < 3600:
            return f"{int(age//60)}min temu"
        if age < 86400:
            return f"{int(age//3600)}h temu"
        return f"{int(age//86400)}d temu"
    except Exception:
        return "?"

def _section_hdr(name, state, reason, freshness, source, last_update):
    """Generate section metadata block."""
    reason_txt = f" ({reason})" if reason else ""
    return (
        f"> **[{name}]** {state}{reason_txt}  \n"
        f"> Świeżość: {freshness} | Źródło: `{source}` | Ostatnia aktualizacja: {last_update}"
    )

# Current phase for section state computation
_current_phase = str(summary_phase if 'summary_phase' in dir() else last_mode or "").upper()

# Section states
sec_meta_state, sec_meta_reason = "🟢 ACTIVE", ""
sec_live_state, sec_live_reason = _section_state(
    ["MIGRATION", "TRANSLATION_SYNC", "AUTO_TRANSLATE", "COMPACT_KEYS", "VALIDATION", "IDLE"],
    _current_phase
)
sec_migration_state, sec_migration_reason = _section_state(
    ["MIGRATION", "COMPACT_KEYS"], _current_phase
)
sec_translation_state, sec_translation_reason = _section_state(
    ["AUTO_TRANSLATE", "TRANSLATION_SYNC"], _current_phase
)
sec_quality_state, sec_quality_reason = _section_state(["VALIDATION"], _current_phase)
sec_history_state, sec_history_reason = "🟢 ACTIVE", ""

# Section sources + last_update
meta_source = "update_github_status()"
meta_last_update = timestamp
live_source = "activity.json / worker_state.json"
live_last_update = str(heartbeat_iso or "-")
migration_source = "i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt"
migration_last_update = timestamp
translation_source = "translation_guard_latest.json / translation_recent_latest.json"
translation_last_update = next(
    (
        str(_v)
        for _v in [
            translation_guard_latest.get("timestamp") if isinstance(translation_guard_latest, dict) else None,
            recent_translation_entry.get("timestamp") if isinstance(recent_translation_entry, dict) else None,
            heartbeat_iso if _current_phase in ("AUTO_TRANSLATE", "TRANSLATION_SYNC") else None,
        ]
        if _v
    ),
    "-",
)
quality_source = "quality_audit_latest.json"
quality_last_update = str(quality_audit_latest.get("timestamp", "-")) if isinstance(quality_audit_latest, dict) else "-"
history_source = "daily/*.json / ops.jsonl"
history_last_update = timestamp

# Section freshness
meta_freshness = "teraz"
live_freshness = _freshness_label(heartbeat_iso) if heartbeat_iso else "brak heartbeat"
migration_freshness = _freshness_label(last_activity_time) if last_activity_time > 0 else "brak aktywności migracji"
translation_freshness = _freshness_label(translation_last_update) if translation_last_update != "-" else "brak"
quality_freshness = _freshness_label(quality_last_update) if quality_last_update != "-" else "brak"
history_freshness = "teraz"

# Generate section metadata headers
meta_section_hdr = _section_hdr("META", sec_meta_state, sec_meta_reason, meta_freshness,
    meta_source, meta_last_update)
live_section_hdr = _section_hdr("LIVE", sec_live_state, sec_live_reason, live_freshness,
    live_source, live_last_update)
migration_section_hdr = _section_hdr("MIGRATION", sec_migration_state, sec_migration_reason,
    migration_freshness, migration_source, migration_last_update)
translation_section_hdr = _section_hdr("TRANSLATION", sec_translation_state, sec_translation_reason,
    translation_freshness, translation_source, translation_last_update)
quality_section_hdr = _section_hdr("QUALITY", sec_quality_state, sec_quality_reason,
    quality_freshness, quality_source, quality_last_update)
history_section_hdr = _section_hdr("HISTORY", sec_history_state, sec_history_reason,
    history_freshness, history_source, history_last_update)

def _state_plain(state_label: str) -> str:
    label = str(state_label or "").upper()
    if "INACTIVE" in label:
        return "inactive"
    if "ACTIVE" in label:
        return "active"
    return "unknown"

def _section_record(name, state, reason, freshness, source, last_update):
    return {
        "name": name,
        "state": _state_plain(state),
        "state_label": state,
        "reason": reason or "",
        "freshness": freshness,
        "source": source,
        "last_update": str(last_update),
    }

section_records = [
    _section_record("META", sec_meta_state, sec_meta_reason, meta_freshness, meta_source, meta_last_update),
    _section_record("LIVE", sec_live_state, sec_live_reason, live_freshness, live_source, live_last_update),
    _section_record("MIGRATION", sec_migration_state, sec_migration_reason, migration_freshness, migration_source, migration_last_update),
    _section_record("TRANSLATION", sec_translation_state, sec_translation_reason, translation_freshness, translation_source, translation_last_update),
    _section_record("QUALITY", sec_quality_state, sec_quality_reason, quality_freshness, quality_source, quality_last_update),
    _section_record("HISTORY", sec_history_state, sec_history_reason, history_freshness, history_source, history_last_update),
]

sections_matrix_md = "\n".join(
    [
        f"| {r['name']} | {r['state_label']} | {r['freshness']} | {r['reason'] or '-'} | `{r['source']}` | {r['last_update']} |"
        for r in section_records
    ]
)

sections_payload = {
    "schema_version": "1.0",
    "generated_at_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "current_phase": _current_phase,
    "sections": {r["name"]: {
        "state": r["state"],
        "state_label": r["state_label"],
        "reason": r["reason"],
        "freshness": r["freshness"],
        "source": r["source"],
        "last_update": r["last_update"],
    } for r in section_records},
}
try:
    with open(os.path.join(status_translation_dir, "status_sections_latest.json"), "w", encoding="utf-8") as f:
        json.dump(sections_payload, f, indent=2, ensure_ascii=False)
except Exception:
    pass

# net_effective_translated (P0.1 checklist item 3)
net_effective_translated = 0
try:
    _grd_path = os.path.join(status_translation_dir, "translation_guard_report.jsonl")
    if os.path.exists(_grd_path):
        with open(_grd_path, "r", encoding="utf-8") as _gf:
            for _gl in _gf:
                _gl = _gl.strip()
                if not _gl:
                    continue
                try:
                    _ge = json.loads(_gl)
                    net_effective_translated += max(0, int(_ge.get("translated", 0) or 0) - int(_ge.get("guard_fail", 0) or 0))
                except Exception:
                    pass
except Exception:
    pass

# ============ DASHBOARD KPI — Pilot health PL/ES ============
kpi_pilot_langs = ["pl", "es"]
kpi_data = {}
for _kl in kpi_pilot_langs:
    _row = next((r for r in translation_lang_overview if r.get("lang") == _kl), None)
    _cov = float(_row.get("completion_pct", 0) or 0) if _row else 0.0
    _miss = int(_row.get("missing_keys", 0) or 0) if _row else 0
    _encopy = int(_row.get("english_copy_keys", 0) or 0) if _row else 0

    # Per-lang guard stats from last 200 entries
    _kpi_translated = 0
    _kpi_guard_fail = 0
    _kpi_entries = 0
    try:
        _grd_path2 = os.path.join(status_translation_dir, "translation_guard_report.jsonl")
        if os.path.exists(_grd_path2):
            with open(_grd_path2, "r", encoding="utf-8") as _gf2:
                _lines2 = _gf2.readlines()
            for _gl2 in _lines2[-200:]:
                _gl2 = _gl2.strip()
                if not _gl2:
                    continue
                try:
                    _ge2 = json.loads(_gl2)
                    if str(_ge2.get("language", "")).lower() == _kl:
                        _kpi_entries += 1
                        _kpi_translated += int(_ge2.get("translated", 0) or 0)
                        _kpi_guard_fail += int(_ge2.get("guard_fail", 0) or 0)
                except Exception:
                    pass
    except Exception:
        pass
    _kpi_gf_rate = round(_kpi_guard_fail / max(_kpi_translated + _kpi_guard_fail, 1) * 100, 1)
    kpi_data[_kl] = {
        "coverage_pct": round(_cov, 2),
        "missing_keys": _miss,
        "en_copy": _encopy,
        "translated_recent": _kpi_translated,
        "guard_fail_recent": _kpi_guard_fail,
        "guard_fail_rate_pct": _kpi_gf_rate,
        "entries": _kpi_entries,
    }

# Adaptive batch state
_adaptive_label = "-"
try:
    _adf = os.path.join(status_translation_dir, "adaptive_batch_state.json")
    if os.path.exists(_adf):
        with open(_adf) as _af:
            _ad = json.load(_af)
        _adaptive_label = f"batch={_ad.get('batch_size', '?')}, gf_rate={_ad.get('guard_fail_rate', '?')}%, reason={_ad.get('reason', '?')}"
except Exception:
    pass

# Build KPI table rows
kpi_rows = []
for _kl in kpi_pilot_langs:
    d = kpi_data[_kl]
    health_icon = "🟢" if d["coverage_pct"] >= 80 and d["guard_fail_rate_pct"] < 10 else ("🟡" if d["coverage_pct"] >= 50 else "🔴")
    kpi_rows.append(
        f"| {health_icon} {_kl.upper()} | {d['coverage_pct']:.1f}% | {d['missing_keys']:,} | {d['en_copy']:,} | "
        f"{d['translated_recent']:,} | {d['guard_fail_recent']} ({d['guard_fail_rate_pct']}%) | {d['entries']} |"
    )
kpi_table = chr(10).join(kpi_rows)

# Scope breakdown table (serwer vs instalka)
_scope_server_keys = int(sum(en_file_key_count.get(f, 0) for f in en_json_files if os.path.splitext(f)[0].lower() not in CLIENT_CATEGORIES))
_scope_client_keys = int(sum(en_file_key_count.get(f, 0) for f in en_json_files if os.path.splitext(f)[0].lower() in CLIENT_CATEGORIES))
scope_rows = []
for row in translation_lang_overview:
    lang = row.get("lang", "")
    s_pct = row.get("server_pct", 0)
    c_pct = row.get("client_pct", 0)
    s_tr = row.get("server_translated", 0)
    c_tr = row.get("client_translated", 0)
    scope_rows.append(
        f"| {lang.upper()} | {s_tr:,}/{_scope_server_keys:,} | {s_pct:.1f}% | {c_tr:,}/{_scope_client_keys:,} | {c_pct:.1f}% |"
    )
scope_table = chr(10).join(scope_rows[:12])  # top 12 języków

# ==================== GENERUJ PEŁNY I18N_STATUS.md ====================
md = f'''# 🌍 I18N Internationalization System - Live Dashboard

{targets_comment}

## 🧭 META

{meta_section_hdr}

> **Aktualizacja:** {timestamp} UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** {langs_count} | **Klucze EN:** {total_keys}  
> **LIVE:** Cykl #{cycle_count} | Status: {status_display} | Faza: {summary_phase} | Etap: {summary_stage} | Kategoria: {summary_category} | Plik: {summary_file} | ETA: {summary_eta} | Heartbeat: {str(heartbeat_iso or '-')}  
> **Strict hourly (JSONL-only):** {strict_summary_md}  
> **Net effective translated:** {net_effective_translated:,}

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
{sections_matrix_md}

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

{live_section_hdr}

- **Faza:** `{summary_phase}`
- **Etap:** `{summary_stage}`
- **Kategoria:** `{summary_category}`
- **Plik:** `{summary_file}`
- **Status:** {status_display}
- **Heartbeat:** `{str(heartbeat_iso or '-')}`

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

#### Sterowanie językiem
| Komenda | Opis |
|---------|------|
| `LANG:<lang>` | Przypiąj worker do jednego języka (auto-wybór plików) |
| `LANG:<lang>:<plik1>,<plik2>,...` | Przypiąj język + cyklicznie przechodź podane pliki |
| `LANG:random` | Przywróć tryb losowy (wszystkie języki) |
| `FOCUS:<lang>[:json[:limit]]` | Skup na języku (persystentne, zapis do config) |
| `UNFOCUS` | Zdejmij focus, wróć do tier-round-robin |

#### Tłumaczenie i testy
| Komenda | Opis |
|---------|------|
| `AUTO:<lang>:<json>:<limit>` | Jednorazowe tłumaczenie (lang/plik/limit) |
| `TEST:<lang>` | Pełny test: translate + validate + crossref (1 cykl) |
| `TEST_ALL` | Dodaj WSZYSTKIE języki do kolejki testowej |
| `LANGVAL:all` / `LANGVAL:<lang>` | Wymuś walidację |
| `SPOTCHECK:<lang>[:N]` | Losowy audit N tłumaczeń |
| `GRAMMARFIX:<lang>[:json[:N]]` | Napraw EN-copy/artefakty + walidacja |

#### Konfiguracja w locie
| Komenda | Opis |
|---------|------|
| `GT:on` / `GT:off` | Włącz/wyłącz Google Translate |
| `BATCH:<N>` | Ustaw translate_limit na N kluczy/cykl |
| `SET:<key>=<value>` | Zmień wartość w worker_config.json |
| `RESTART` | Restart workera (git pull + exec) |
| `CONFIG` | Wyświetl aktualną konfigurację |
| `REPORT` / `LANGS` | Raport coverage / lista języków |
| `SKIP` / `PAUSE:<N>` / `IDLE` | Kontrola cyklu |

---

## 🛠️ MIGRATION

{migration_section_hdr}

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **{all_project_files:,}** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **{scannable_files:,}** | {round(scannable_files/all_project_files*100, 1)}% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **{scanned_files:,}** | **{scanned_pct}%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **{scanned_files_live:,}** | **{scanned_live_pct}%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **{files_not_scanned:,}** | {round(files_not_scanned/scannable_files*100, 1) if scannable_files else 0}% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **{files_not_scanned_live:,}** | {round(files_not_scanned_live/scannable_files*100, 1) if scannable_files else 0}% | wg rejestru LIVE |

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
| 🧮 **Klucze wyekstrahowane (LIVE)** | **{total_keys_extracted_live:,}** | realny stan `i18n/en/*.json` |
| 🤖 Klucze z rejestru workera | **{total_keys_extracted_registry:,}** | suma `5_extraction_en.keys_added` |
| ➕ Klucze poza rejestrem workera | **{keys_extracted_outside_worker:,}** | ręczne zmiany / starsze migracje |
| 📊 NPC | {npc_keys:,} | dialogi NPC |
| 📊 Items | {items_keys:,} | przedmioty |
| 📊 Monsters | {monsters_keys:,} | potwory |
| 📊 HTML | {html_keys:,} | widoki web |
| 📊 Pozostałe | {total_keys - npc_keys - items_keys - monsters_keys - html_keys:,} | scripts, spells, etc. |

## 🌍 TRANSLATION

{translation_section_hdr}

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **{langs_count}** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **{prepared_langs}** | {round(prepared_langs/langs_count*100) if langs_count else 0}% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **{translated_langs}** | **{translated_pct}%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **{prepared_langs - translated_langs}** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
{translation_lang_table}

### 🧭 Aktywny folder tłumaczeń
- **Folder:** {active_folder_display}
- **Plik JSON:** {active_file}
- **Ostatnie klucze (10-20):** {recent_count}

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
{recent_translation_md}

### 🚫 Raporty "nie mogę przetłumaczyć"
{report_counter_md}

### 🌐 Globalne info wszystkich języków
- **Global completion:** **{global_completion_pct}%** ({translation_global['translated_keys']:,}/{translation_global['total_reference_keys']:,})
- **EN-copy łącznie:** **{translation_global['english_copy_keys']:,}**
- **Braki kluczy łącznie:** **{translation_global['missing_keys']:,}**
- **Brakujące pliki językowe:** **{translation_global['missing_files']:,}**
- **Cache STATUSPY (per-lang):** **{cache_mode_label}** | hit **{cache_hits}**, miss **{cache_misses}**, hit-rate **{cache_hit_pct}%**
- **Cache STATUSPY (per-file):** hit **{file_cache_hits}**, miss **{file_cache_misses}**, hit-rate **{file_cache_hit_pct}%**
- **Profiler cyklu (ostatni):** {perf_summary_md}
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **{_scope_server_keys:,}** |
| 📦 **Instalka** (klient/OTClient) | **{_scope_client_keys:,}** |

| Język | Serwer | Serwer % | Instalka | Instalka % |
|-------|--------|----------|----------|------------|
{scope_table}

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **{strict_window_payload['window_hours']}h** ({strict_window_payload['window_start_utc']} → {strict_window_payload['window_end_utc']}) |
| Cykle | **{strict_window_payload['total_cycles']}** (AUTO={strict_window_payload['auto_translate_cycles']}, MIGRATION={strict_window_payload['migration_cycles']}) |
| Pending skip | **{strict_window_payload['pending_skip_count']}** (all={strict_window_payload['pending_skip_share_pct']}%, migration={strict_window_payload['pending_skip_share_migration_pct']}%) |
| Guard fail rate | **{strict_window_payload['guard_fail_rate_pct']}%** |
| No progress rate | **{strict_window_payload['no_progress_rate_pct']}%** |
| Throughput | **{strict_window_payload['throughput_keys_per_h']} kluczy/h** |
| Suspicious | **{strict_window_payload['suspicious_total']}** |
| Top guard_fail targets | {strict_top_targets_md} |
| Źródła | {strict_sources_md} |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

{quality_section_hdr}

- **Ostatni audyt:** {quality_summary_md}
- **Top 5 typów problemów:** {quality_top_issues_md}
- **Języki o najsłabszej jakości:** {quality_worst_langs_md}
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#{cycle_count}** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **{total_keys_extracted_live:,}** | realny stan EN |
| 🤖 Kluczy z rejestru workera | **{total_keys_extracted_registry:,}** | historia runów workera |
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

> **Aktualna faza:** {summary_phase}  
> **Aktualna kategoria:** {summary_category}
{"> **Tryb:** 🔒 TRANSLATIONS_ONLY STRICT (bez dodawania nowych kluczy)" if os.environ.get("TRANSLATIONS_ONLY", "false") == "true" else ""}

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
| 📄 HTML Views | {status_icon(html_keys, TARGETS["html"])} | {html_keys}/{TARGETS["html"]} ({round(html_keys/TARGETS["html"]*100) if TARGETS["html"] else 0}%) | {TARGETS["html"]} |
| 📦 JavaScript | {status_icon(client_keys, TARGETS["client"])} | {client_keys}/{TARGETS["client"]} ({round(client_keys/TARGETS["client"]*100) if TARGETS["client"] else 0}%) | {TARGETS["client"]} |

### ⏳ Faza 3: 📱 OTClient / Testyy

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | {status_icon(ui_keys, TARGETS["ui"])} | {ui_keys}/{TARGETS["ui"]} ({round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}%) | {TARGETS["ui"]} |
| 💿 Server C++ | {status_icon(cpp_keys, TARGETS["cpp"])} | {cpp_keys}/{TARGETS["cpp"]} ({round(cpp_keys/TARGETS["cpp"]*100) if TARGETS["cpp"] else 0}%) | {TARGETS["cpp"]} |
| 🎮 OTClient Modules | {status_icon(otclient_modules_keys, TARGETS["otclient_modules"])} | {otclient_modules_keys}/{TARGETS["otclient_modules"]} ({round(otclient_modules_keys/TARGETS["otclient_modules"]*100) if TARGETS["otclient_modules"] else 0}%) | {TARGETS["otclient_modules"]} |
| 📦 OTClient Data | {status_icon(otclient_data_keys, TARGETS["otclient_data"])} | {otclient_data_keys}/{TARGETS["otclient_data"]} ({round(otclient_data_keys/TARGETS["otclient_data"]*100) if TARGETS["otclient_data"] else 0}%) | {TARGETS["otclient_data"]} |
| ⚙️ OTClient Src | {status_icon(otclient_src_keys, TARGETS["otclient_src"])} | {otclient_src_keys}/{TARGETS["otclient_src"]} ({round(otclient_src_keys/TARGETS["otclient_src"]*100) if TARGETS["otclient_src"] else 0}%) | {TARGETS["otclient_src"]} |
| 🔧 OTClient Mods | {status_icon(otclient_mods_keys, TARGETS["otclient_mods"])} | {otclient_mods_keys}/{TARGETS["otclient_mods"]} ({round(otclient_mods_keys/TARGETS["otclient_mods"]*100) if TARGETS["otclient_mods"] else 0}%) | {TARGETS["otclient_mods"]} |
| 🛠️ OTClient Tools | {status_icon(otclient_tools_keys, TARGETS["otclient_tools"])} | {otclient_tools_keys}/{TARGETS["otclient_tools"]} ({round(otclient_tools_keys/TARGETS["otclient_tools"]*100) if TARGETS["otclient_tools"] else 0}%) | {TARGETS["otclient_tools"]} |

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

## 🔴 LIVE: Szczegóły wykonania

{live_section_hdr}

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

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
{kpi_table}

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **{net_effective_translated:,}** | — | 📊 |
| Adaptive batch | {_adaptive_label} | gf <5% → increase | 📊 |
| Throughput (last window) | {sum(d['translated_recent'] for d in kpi_data.values()):,} keys / {sum(d['entries'] for d in kpi_data.values())} entries | >50/h | 📊 |

---

## 📜 HISTORY

{history_section_hdr}

{cycle_ops_md}


{daily_section}

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych (LIVE registry) | **{scanned_files_live:,}** | z `i18n_file_status.json` |
| 📚 Plików przeskanowanych (historia) | **{scanned_files:,}** | z `i18n_processed_files.txt` |
| ↕️ Historia minus LIVE | **{scan_history_minus_live:+,}** | dodatnie = historia > LIVE |
| ✅ Plików z kluczami | **{files_migrated}** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **{files_clean}** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych (LIVE) | **{total_keys_extracted_live:,}** | realny stan `i18n/en/*.json` |
| 🤖 Kluczy wyciągniętych przez workera | **{total_keys_extracted_registry:,}** | z `i18n_file_status.json` |
| ➕ Kluczy poza rejestrem workera | **{keys_extracted_outside_worker:,}** | ręczne/Codex/Claude/starsze |
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

# ============================================================================
# SEKCJA: JAKOŚĆ TŁUMACZEŃ (Quality Dashboard)
# ============================================================================
quality_dashboard_section = ""
try:
    qd_path = os.path.join(STATUS_DIR, "quality_dashboard.json")
    qa_path = os.path.join(STATUS_DIR, "quality_audit_latest.json")
    
    if os.path.exists(qd_path):
        with open(qd_path, "r", encoding="utf-8") as f:
            qd = json.load(f)
        
        # Tabela per-język
        rows = []
        for lang_code in sorted(qd.keys()):
            ld = qd[lang_code]
            score = ld.get("quality_score", 0)
            cycles = ld.get("cycles", 0)
            suspicious = ld.get("total_suspicious", 0)
            rejected = ld.get("total_rejected", 0)
            gt_fail = ld.get("total_gt_guard_fail", 0)
            last = ld.get("last_cycle", "")[:10]
            
            # Ikona jakości
            if score >= 90:
                icon = "🟢"
            elif score >= 70:
                icon = "🟡"
            elif score >= 50:
                icon = "🟠"
            else:
                icon = "🔴"
            
            rows.append(f"| {icon} {lang_code.upper()} | {score} | {cycles} | {suspicious} | {rejected} | {gt_fail} | {last} |")
        
        if rows:
            quality_dashboard_section = """
---

## 🔬 Jakość Tłumaczeń

| Język | Jakość | Cykli | Podejrzane | Odrzucone | GT fail | Ostatni |
|-------|--------|-------|------------|-----------|---------|---------|
""" + "\n".join(rows[:20])
            
            if len(rows) > 20:
                quality_dashboard_section += f"\n\n> *...i {len(rows) - 20} więcej języków*"
    
    # Ostatni audyt
    if os.path.exists(qa_path):
        with open(qa_path, "r", encoding="utf-8") as f:
            qa = json.load(f)
        
        qa_ts = qa.get("timestamp", "?")[:19]
        qa_issues = qa.get("issues_found", 0)
        qa_sev = qa.get("issues_by_severity", {})
        qa_sources = qa.get("source_breakdown_total", {})
        
        if not quality_dashboard_section:
            quality_dashboard_section = "\n---\n\n## 🔬 Jakość Tłumaczeń\n"
        
        quality_dashboard_section += f"""

### Ostatni audyt jakości

| Metryka | Wartość |
|---------|---------|
| 📅 Data | {qa_ts} |
| 🔍 Problemy | {qa_issues} |
| 🚨 CRITICAL | {qa_sev.get('CRITICAL', 0)} |
| ⚠️ HIGH | {qa_sev.get('HIGH', 0)} |
| 📊 MEDIUM | {qa_sev.get('MEDIUM', 0)} |
"""

        if qa_sources:
            src_parts = [f"{k}: {v}" for k, v in sorted(qa_sources.items(), key=lambda x: -x[1])]
            quality_dashboard_section += f"\n> **Źródła tłumaczeń:** {', '.join(src_parts)}\n"
        
        # Top issues
        top_issues = qa.get("issues", [])[:3]
        if top_issues:
            quality_dashboard_section += "\n**Top problemy:**\n"
            for issue in top_issues:
                sev = issue.get("severity", "?")
                msg = issue.get("message", "?")
                quality_dashboard_section += f"- [{sev}] {msg}\n"

except Exception:
    pass

md += quality_dashboard_section

# ============================================================================
# SEKCJA: WALIDACJA PER-JĘZYK (Validation Summary)
# ============================================================================
validation_section = ""
try:
    val_summary_path = os.path.join(STATUS_DIR, "validation", "summary.json")
    if os.path.exists(val_summary_path):
        with open(val_summary_path, "r", encoding="utf-8") as f:
            val_sum = json.load(f)

        val_ts = str(val_sum.get("validated_at", "?"))[:19]
        val_avg = val_sum.get("avg_score", 0)
        val_total_langs = val_sum.get("total_languages", 0)
        by_score = val_sum.get("by_score", {})
        by_group = val_sum.get("by_group", {})

        validation_section = f"""
---

## ✅ Walidacja Per-Język

> Ostatnia walidacja: **{val_ts}** | Języków: **{val_total_langs}** | Średni score: **{val_avg}**

"""
        # Score icon
        def _scr_icon(s):
            if s >= 95: return "🟢"
            if s >= 80: return "🟡"
            if s >= 60: return "🟠"
            return "🔴"

        # Groups summary
        group_names = {"latin": "Łacińskie", "cyrillic": "Cyrylica", "cjk": "CJK", "rtl": "RTL", "exotic": "Egzotyczne"}
        for grp, grp_name in group_names.items():
            langs_in_grp = by_group.get(grp, [])
            if not langs_in_grp:
                continue
            # Get scores for langs in this group
            grp_rows = []
            for lg in sorted(langs_in_grp):
                info = by_score.get(lg, {})
                sc = info.get("score", 0)
                cov = info.get("coverage_pct", 0)
                iss = info.get("issues", 0)
                crit = info.get("critical", 0)
                high_c = info.get("high", 0)
                grp_rows.append(f"| {_scr_icon(sc)} {lg.upper()} | {sc} | {cov}% | {iss} | {crit} | {high_c} |")

            validation_section += f"### {grp_name} ({len(langs_in_grp)} języków)\n\n"
            validation_section += "| Język | Score | Coverage | Issues | CRIT | HIGH |\n"
            validation_section += "|-------|-------|----------|--------|------|------|\n"
            # Show max 10 per group, worst first
            grp_rows_sorted = sorted(grp_rows)
            for row in grp_rows_sorted[:10]:
                validation_section += row + "\n"
            if len(grp_rows) > 10:
                validation_section += f"\n> *+{len(grp_rows) - 10} więcej*\n"
            validation_section += "\n"

except Exception:
    pass

md += validation_section

# === Tier system info ===
tier_section = ""
try:
    dsp = os.path.join(status_dir, "translation_dispatch_state.json")
    if os.path.exists(dsp):
        with open(dsp) as f:
            ds = json.load(f)
        tc = ds.get("tier_config", {})
        if tc:
            t1 = ", ".join(tc.get("tier1", []))
            t2 = ", ".join(tc.get("tier2", []))
            tier_section = f"""
---

## ⚡ System tierów (Sekcja 5)

| Tier | Języki | Waga | Cel pokrycia |
|------|--------|------|-------------|
| **Tier 1** | {t1} | ×{tc.get("w1", 4)} | 90% |
| **Tier 2** | {t2} | ×{tc.get("w2", 2)} | 50% |
| **Tier 3** | reszta ({52 - len(tc.get("tier1",[])) - len(tc.get("tier2",[]))}) | ×{tc.get("w3", 1)} | 30% |

**Priorytet kategorii:** items → npc → monsters → server → spells → quests → scripts → actions → raids

> Tier 1 przetwarza 4 pliki per super-rundę, Tier 2 przetwarza 2, Tier 3 przetwarza 1.
"""
except Exception:
    pass

md += tier_section

md += f'''

---

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
{roadmap_table}

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
if translations_only_mode:
    at_lang = auto_translate_data.get("language", "-")
    at_file = auto_translate_data.get("json_file", "-")
    at_guard = auto_translate_data.get("guard_fail", 0)
    at_strict = auto_translate_data.get("strict_missing_key", 0)
    print(f"   TRYB: TRANSLATIONS_ONLY STRICT | AUTO: {at_lang}/{at_file} | guard_fail={at_guard} | strict_missing_key={at_strict}")
else:
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
            | grep -v -- '->' \
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
import re

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

# Normalizacja legacy placeholderów ([PL]/[TR]/...) do [EN]
normalized_placeholders = 0
for key, en_value in en_data.items():
    if key not in lang_data:
        continue
    value = lang_data.get(key)
    if not isinstance(value, str):
        continue
    m = re.match(r'^\[([A-Z]{2}(?:_[A-Z]{2})?)\]\s*', value)
    if not m:
        continue
    if m.group(1) == "EN":
        continue
    lang_data[key] = f"{UNTRANSLATED_PREFIX}{en_value}"
    normalized_placeholders += 1

if normalized_placeholders > 0:
    print(f"   🧹 Znormalizowano placeholdery: {normalized_placeholders}")

# Znajdź brakujące klucze
missing_keys = [key for key in en_data if key not in lang_data]
print(f"   🔍 Brakujących: {len(missing_keys)}")

if not missing_keys and normalized_placeholders == 0:
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

total_synced = synced + normalized_placeholders

# Zapisz plik językowy (posortowany alfabetycznie)
lang_data_sorted = dict(sorted(lang_data.items()))
with open(lang_path, 'w', encoding='utf-8') as f:
    json.dump(lang_data_sorted, f, indent=2, ensure_ascii=False)

print(f"   ✅ Zsynchronizowano: +{total_synced} wpisów → {target_lang}/{json_file}")
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

print(f"__SYNC_RESULT__ synced={total_synced}")
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
# REPAIR IDENTICAL BONUS ROUND — Sekcja 12.5
#===============================================================================
# Dedykowana runda naprawcza:
# 1) buduje kolejkę backlogu "identical_to_en (translatable)" dla PL/ES
# 2) zapisuje artefakt queue do i18n/status/identical_to_en_repair_queue.json
# 3) wybiera kolejny target wg priorytetu lang + domeny i uruchamia auto_translate_keys
# Wywoływane co N cykli po standardowej translacji.
#===============================================================================
REPAIR_IDENTICAL_INTERVAL="${REPAIR_IDENTICAL_INTERVAL:-2}"
REPAIR_IDENTICAL_LIMIT="${REPAIR_IDENTICAL_LIMIT:-300}"
REPAIR_PRIORITY_LANGS="${REPAIR_PRIORITY_LANGS:-es pl}"
REPAIR_IDENTICAL_LIMIT_HIGH="${REPAIR_IDENTICAL_LIMIT_HIGH:-380}"
REPAIR_IDENTICAL_LIMIT_LOW="${REPAIR_IDENTICAL_LIMIT_LOW:-180}"
REPAIR_IDENTICAL_HIGH_BACKLOG="${REPAIR_IDENTICAL_HIGH_BACKLOG:-1500}"
REPAIR_IDENTICAL_LOW_BACKLOG="${REPAIR_IDENTICAL_LOW_BACKLOG:-350}"
REPAIR_IDENTICAL_FORCE_GT="${REPAIR_IDENTICAL_FORCE_GT:-true}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_NPC="${REPAIR_IDENTICAL_DOMAIN_LIMIT_NPC:-260}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_SERVER="${REPAIR_IDENTICAL_DOMAIN_LIMIT_SERVER:-240}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_TALKACTIONS="${REPAIR_IDENTICAL_DOMAIN_LIMIT_TALKACTIONS:-200}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_QUESTS="${REPAIR_IDENTICAL_DOMAIN_LIMIT_QUESTS:-180}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_ACTIONS="${REPAIR_IDENTICAL_DOMAIN_LIMIT_ACTIONS:-180}"
REPAIR_IDENTICAL_DOMAIN_LIMIT_DEFAULT="${REPAIR_IDENTICAL_DOMAIN_LIMIT_DEFAULT:-220}"
REPAIR_SUSPICIOUS_WINDOW_ENTRIES="${REPAIR_SUSPICIOUS_WINDOW_ENTRIES:-30}"
REPAIR_SUSPICIOUS_HIGH_THRESHOLD_PCT="${REPAIR_SUSPICIOUS_HIGH_THRESHOLD_PCT:-12}"
REPAIR_SUSPICIOUS_MIN_TRANSLATED="${REPAIR_SUSPICIOUS_MIN_TRANSLATED:-80}"
REPAIR_SUSPICIOUS_LIMIT_FACTOR="${REPAIR_SUSPICIOUS_LIMIT_FACTOR:-0.60}"

repair_identical_bonus_round() {
    local cycle="$1"

    # Sprawdź interwał — preferuj globalny licznik cykli dispatchera (nie resetuje się po restarcie workera),
    # aby runda repair nie była głodzona przez częste restarty i reset lokalnego CYCLE=1.
    local interval_cycle="$cycle"
    local global_cycle
    global_cycle=$(python3 - "$STATUS_DIR/translation_dispatch_state.json" <<'PYREPAIRCYCLE'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    v = d.get("cycle_counter", "")
    print(int(float(v)))
except Exception:
    print("")
PYREPAIRCYCLE
)
    case "${global_cycle:-}" in
        ''|*[!0-9]*)
            ;;
        *)
            if [ "$global_cycle" -gt 0 ] 2>/dev/null; then
                interval_cycle="$global_cycle"
            fi
            ;;
    esac

    if (( interval_cycle % REPAIR_IDENTICAL_INTERVAL != 0 )); then
        return 0
    fi
    
    echo "🔧 REPAIR: identical_to_en bonus round (cykl $cycle, interval_key=$interval_cycle)"
    
    # Zbuduj kolejkę naprawczą i wybierz target wg priorytetu
    local repair_target
    export REPAIR_PRIORITY_LANGS
    repair_target=$(python3 << 'REPAIR_SELECT_PY'
import json, os, re
from collections import Counter
from datetime import datetime, timezone

I18N_DIR = "i18n"
en_dir = os.path.join(I18N_DIR, "en")
status_dir = os.environ.get("STATUS_DIR", os.path.join(I18N_DIR, "status"))
queue_latest_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
queue_report_path = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")

_split = lambda raw: [p for p in re.split(r"[\s,;]+", str(raw or "").strip()) if p]
tier1_langs = _split(os.environ.get("TIER1_LANGS", "pl es"))
priority_langs = _split(os.environ.get("REPAIR_PRIORITY_LANGS", "es pl"))

langs = [l for l in priority_langs if l in tier1_langs]
langs += [l for l in tier1_langs if l not in langs]
if not langs:
    langs = ["es", "pl"]

domain_priority = [
    "npc.json",
    "server.json",
    "talkactions.json",
    "quests.json",
    "actions.json",
    "modules.json",
    "messages.json",
    "items.json",
    "monsters.json",
]
domain_rank = {name: idx for idx, name in enumerate(domain_priority)}

# Ta sama heurystyka co w workerze
def _is_game_nontranslatable(key, t):
    t = str(t or "").strip()
    if not t:
        return False
    _animal = ('GRRR','YOOO','ZZZZ','ROAR','HISS','SNARL','RAWR','HOWL','GROWL','SCREE','CLANK','BOOM')
    if any(p in t.upper() for p in _animal):
        return True
    if re.search(r'\b(?:gort|utash|karek|booz|omark|ikem|goshak|torilu[nm]?|garnum|saethelon|zathroth|uthun|nortat|urghh?|brakka|morda|chakka|batuk|charach|galunda|mugrah|gorak|shakk|uurgh|tanjil|lanar|kull|ogar|azarak)\b', t, re.I):
        return True
    words = re.findall(r'[A-Za-z]+', t)
    if len(words) >= 3:
        _common_en = {
            'a','i','an','am','as','at','be','by','do','go','he','if','in','is','it','me','my','no',
            'of','on','or','so','to','up','us','we','the','and','are','but','can','did','for','get',
            'got','had','has','her','him','his','how','its','let','may','new','nor','not','now','old',
            'one','our','out','own','put','ran','run','saw','say','set','she','sit','too','try',
            'two','use','was','way','who','why','win','won','yes','yet','you','all','any','ask','bad',
            'big','bit','boy','buy','cut','day','eat','end','far','few','fly','fun','god','hat','hit',
            'hot','job','key','lay','led','lie','lot','low','man','map','men','met','mix','off',
            'oil','pay','per','red','rid','sad','six','son','ten','top','war','wet',
            'able','also','back','been','best','body','both','call','came','case','come','could','each',
            'even','fact','feel','find','first','from','gave','give','goes','gone','good','great',
            'hand','have','head','help','here','high','home','hope','into','just','keep','kind','knew',
            'know','last','left','life','like','line','live','long','look','lost','made','make','many',
            'mind','more','most','much','must','name','need','next','only','open','over','part','plan',
            'play','real','rest','room','said','same','seem','show','side','some','soon','stop','such',
            'sure','take','talk','tell','than','that','them','then','they','this','time','told','took',
            'turn','upon','very','walk','want','well','went','were','what','when','will','with','word',
            'work','year','your','about','after','again','being','below','bring','carry','cause',
            'close','doing','don','every','found','going','house','human','large','later','leave',
            'light','might','money','never','night','often','order','other','place','point','right',
            'shall','should','since','small','sorry','start','still','story','study','thank','their',
            'there','these','thing','think','those','three','today','under','until','watch','water',
            'where','which','while','world','would','write','young','really','little','around',
            'before','always','people','already',
        }
        en_count = sum(1 for w in words if w.lower() in _common_en)
        if en_count == 0 and all(len(w) <= 6 for w in words):
            return True
    if re.match(r'^([A-Za-z]{2,8})[,.\s]+\1(?:[,.\s]+\1)*[.!?]*$', t, re.I):
        return True
    return False

def _is_proper_noun(key, en_value):
    pn_prefixes = ("item.","monster.","spell.","mount.","quest.","raid.","achievement.","npc.","book.otbm.")
    pn_suffixes = (".name",".words",".title",".desc",".announce")
    if any(key.startswith(p) for p in pn_prefixes) and any(key.endswith(s) for s in pn_suffixes):
        return True
    en_s = en_value.strip()
    if len(en_s) <= 3:
        return True
    if _is_game_nontranslatable(key, en_s):
        return True
    if any(key.startswith(p) for p in pn_prefixes):
        words = en_s.split()
        if len(words) <= 4 and words[0][0:1].isupper():
            return True
    if en_s and all(c.isupper() or c.isdigit() or c in ".-_/ " for c in en_s):
        return True
    return False

json_files = sorted([f for f in os.listdir(en_dir) if f.endswith(".json")]) if os.path.isdir(en_dir) else []
entries = []

for lang in langs:
    for jf in json_files:
        en_path = os.path.join(en_dir, jf)
        lang_path = os.path.join(I18N_DIR, lang, jf)
        if not os.path.exists(en_path) or not os.path.exists(lang_path):
            continue
        try:
            with open(en_path, encoding="utf-8") as f:
                en_data = json.load(f)
            with open(lang_path, encoding="utf-8") as f:
                lang_data = json.load(f)
        except Exception:
            continue
        identical_translatable = 0
        for k, v in en_data.items():
            if k in lang_data and str(lang_data[k]) == str(v):
                if not _is_proper_noun(k, str(v)):
                    identical_translatable += 1
        if identical_translatable > 0:
            entries.append({
                "lang": lang,
                "json_file": jf,
                "identical_to_en": int(identical_translatable),
                "domain_priority": int(domain_rank.get(jf, len(domain_priority))),
            })

entries.sort(
    key=lambda e: (
        langs.index(e["lang"]) if e["lang"] in langs else 999,
        e["domain_priority"],
        -int(e["identical_to_en"]),
        str(e["json_file"]),
    )
)
selected = entries[0] if entries else None

entries_by_lang = Counter()
for e in entries:
    entries_by_lang[e["lang"]] += int(e["identical_to_en"])

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "priority_langs": langs,
    "domain_priority": domain_priority,
    "entries_total": len(entries),
    "entries_by_lang": dict(entries_by_lang),
    "top_entries": entries[:200],
    "selected": selected or {},
}

try:
    os.makedirs(status_dir, exist_ok=True)
    with open(queue_latest_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    with open(queue_report_path, "a", encoding="utf-8") as f:
        f.write(json.dumps({
            "timestamp": payload["timestamp"],
            "entries_total": payload["entries_total"],
            "entries_by_lang": payload["entries_by_lang"],
            "selected": selected or {},
        }, ensure_ascii=False) + "\n")
except Exception:
    pass

if selected:
    print(f"{selected['lang']}:{selected['json_file']}:{selected['identical_to_en']}")
else:
    print("NONE:0:0")
REPAIR_SELECT_PY
    )

    local R_LANG R_FILE R_COUNT
    R_LANG=$(echo "$repair_target" | cut -d: -f1)
    R_FILE=$(echo "$repair_target" | cut -d: -f2)
    R_COUNT=$(echo "$repair_target" | cut -d: -f3)
    
    if [ "$R_LANG" = "NONE" ] || [ "${R_COUNT:-0}" -le 0 ] 2>/dev/null; then
        echo "   ✅ REPAIR: brak kluczy identical_to_en do naprawy"
        return 0
    fi
    
    echo "   🎯 REPAIR target: $R_LANG/$R_FILE ($R_COUNT identical_to_en translatable)"
    
    # Adaptacyjne strojenie limitu naprawy na podstawie wielkości backlogu.
    local repair_limit="$REPAIR_IDENTICAL_LIMIT"
    local repair_limit_tier="base"
    if [ "${R_COUNT:-0}" -ge "${REPAIR_IDENTICAL_HIGH_BACKLOG:-1500}" ] 2>/dev/null; then
        repair_limit="$REPAIR_IDENTICAL_LIMIT_HIGH"
        repair_limit_tier="high_backlog"
    elif [ "${R_COUNT:-0}" -le "${REPAIR_IDENTICAL_LOW_BACKLOG:-350}" ] 2>/dev/null; then
        repair_limit="$REPAIR_IDENTICAL_LIMIT_LOW"
        repair_limit_tier="low_backlog"
    fi
    case "${repair_limit:-}" in
        ''|*[!0-9]*)
            repair_limit="$REPAIR_IDENTICAL_LIMIT"
            repair_limit_tier="${repair_limit_tier}_fallback_base"
            ;;
    esac
    if [ "${repair_limit:-0}" -le 0 ] 2>/dev/null; then
        repair_limit="$REPAIR_IDENTICAL_LIMIT"
        repair_limit_tier="${repair_limit_tier}_fallback_base"
    fi
    if [ "${repair_limit:-0}" -le 0 ] 2>/dev/null; then
        repair_limit=300
        repair_limit_tier="${repair_limit_tier}_fallback_hard"
    fi

    # Per-domena cap limitu repair (kontrola quality dla ryzykownych domen).
    local domain_limit="$REPAIR_IDENTICAL_DOMAIN_LIMIT_DEFAULT"
    case "$R_FILE" in
        npc.json) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_NPC:-260}" ;;
        server.json) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_SERVER:-240}" ;;
        talkactions.json) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_TALKACTIONS:-200}" ;;
        quests.json) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_QUESTS:-180}" ;;
        actions.json) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_ACTIONS:-180}" ;;
        *) domain_limit="${REPAIR_IDENTICAL_DOMAIN_LIMIT_DEFAULT:-220}" ;;
    esac
    case "${domain_limit:-}" in
        ''|*[!0-9]*)
            domain_limit="$repair_limit"
            ;;
    esac
    if [ "${domain_limit:-0}" -gt 0 ] 2>/dev/null && [ "${domain_limit:-0}" -lt "${repair_limit:-0}" ] 2>/dev/null; then
        repair_limit="$domain_limit"
        repair_limit_tier="${repair_limit_tier}+domain_cap"
    fi

    # Guard jakości: jeśli suspicious_high dla tego lang/file jest wysoki,
    # obniż limit rundy repair, by zmniejszyć ryzyko dalszej degradacji.
    local repair_suspicious_pct="0.00"
    local repair_suspicious_high="0"
    local repair_suspicious_translated="0"
    local suspicious_stats
    suspicious_stats=$(python3 - "$STATUS_DIR" "$R_LANG" "$R_FILE" "$REPAIR_SUSPICIOUS_WINDOW_ENTRIES" <<'PYREPAIRRISK'
import json, os, sys

status_dir = sys.argv[1]
lang = str(sys.argv[2]).strip().lower()
json_file = str(sys.argv[3]).strip().lower()
try:
    limit = max(1, int(float(sys.argv[4])))
except Exception:
    limit = 30

quality_path = os.path.join(status_dir, "quality_report.jsonl")
rows = []
if os.path.exists(quality_path):
    with open(quality_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            r_lang = str(row.get("language", "")).strip().lower()
            r_file = str(row.get("json_file", "")).strip().lower()
            if r_lang == lang and r_file == json_file:
                rows.append(row)

if not rows:
    print("0.00:0:0")
    raise SystemExit(0)

rows = rows[-limit:]
translated = 0
susp_high = 0
for row in rows:
    try:
        translated += int(row.get("translated", 0) or 0)
    except Exception:
        pass
    q = row.get("quality", {}) if isinstance(row.get("quality", {}), dict) else {}
    try:
        susp_high += int(q.get("suspicious_high", 0) or 0)
    except Exception:
        pass

pct = (float(susp_high) / float(max(translated, 1))) * 100.0
print(f"{pct:.2f}:{susp_high}:{translated}")
PYREPAIRRISK
)
    repair_suspicious_pct=$(echo "$suspicious_stats" | cut -d: -f1)
    repair_suspicious_high=$(echo "$suspicious_stats" | cut -d: -f2)
    repair_suspicious_translated=$(echo "$suspicious_stats" | cut -d: -f3)
    repair_suspicious_pct=${repair_suspicious_pct:-0.00}
    repair_suspicious_high=${repair_suspicious_high:-0}
    repair_suspicious_translated=${repair_suspicious_translated:-0}

    local repair_limit_pre_risk="$repair_limit"
    local reduce_for_suspicious="false"
    if [ "${repair_suspicious_translated:-0}" -ge "${REPAIR_SUSPICIOUS_MIN_TRANSLATED:-80}" ] 2>/dev/null; then
        if awk -v pct="${repair_suspicious_pct:-0}" -v thr="${REPAIR_SUSPICIOUS_HIGH_THRESHOLD_PCT:-12}" 'BEGIN{exit !(pct>=thr)}'; then
            reduce_for_suspicious="true"
        fi
    fi
    if [ "$reduce_for_suspicious" = "true" ]; then
        local risk_limit
        risk_limit=$(awk -v lim="${repair_limit:-0}" -v fac="${REPAIR_SUSPICIOUS_LIMIT_FACTOR:-0.60}" 'BEGIN{v=int(lim*fac); if(v<80)v=80; print v}')
        case "${risk_limit:-}" in
            ''|*[!0-9]*)
                risk_limit="$repair_limit_pre_risk"
                ;;
        esac
        if [ "${risk_limit:-0}" -lt "${repair_limit_pre_risk:-0}" ] 2>/dev/null; then
            repair_limit="$risk_limit"
            repair_limit_tier="${repair_limit_tier}+suspicious_guard"
        fi
    fi

    # W rundzie repair dla PL/ES można wymusić GT, żeby szybciej zbijać EN-copy.
    local orig_use_gt="${USE_GOOGLE_TRANSLATE:-false}"
    local repair_gt_mode="$orig_use_gt"
    local repair_gt_forced="false"
    case "$(echo "${REPAIR_IDENTICAL_FORCE_GT:-true}" | tr '[:upper:]' '[:lower:]')" in
        1|true|yes|on)
            if [ "$orig_use_gt" != "true" ] && { [ "$R_LANG" = "es" ] || [ "$R_LANG" = "pl" ]; }; then
                export USE_GOOGLE_TRANSLATE=true
                repair_gt_mode="true"
                repair_gt_forced="true"
            fi
            ;;
    esac

    echo "   🎚️ REPAIR tuning: tier=$repair_limit_tier limit=$repair_limit domain_cap=$domain_limit gt=$repair_gt_mode suspicious_high=${repair_suspicious_high}/${repair_suspicious_translated} (${repair_suspicious_pct}%)"

    # Zapisz obecny limit i ustaw limit rundy repair
    local orig_limit="${TRANSLATE_LIMIT:-80}"
    export TRANSLATE_LIMIT="$repair_limit"
    
    # Uruchom auto_translate_keys z limitem repair
    local R_TRANSLATED R_PLACEHOLDERS R_GUARD_FAIL R_GUARD_PH R_GUARD_CMD R_GUARD_PIPE R_SKIP_FILE R_SKIP_KEY R_SKIP_DONE
    read -r R_TRANSLATED R_PLACEHOLDERS R_GUARD_FAIL R_GUARD_PH R_GUARD_CMD R_GUARD_PIPE R_SKIP_FILE R_SKIP_KEY R_SKIP_DONE <<< "$(auto_translate_keys "$R_LANG" "$R_FILE" "$R_COUNT")"
    R_TRANSLATED=${R_TRANSLATED:-0}
    R_GUARD_FAIL=${R_GUARD_FAIL:-0}
    
    # Przywróć limit
    export TRANSLATE_LIMIT="$orig_limit"
    if [ "$repair_gt_forced" = "true" ]; then
        export USE_GOOGLE_TRANSLATE="$orig_use_gt"
    fi
    
    echo "   📊 REPAIR result: translated=$R_TRANSLATED guard_fail=$R_GUARD_FAIL (limit=$repair_limit tier=$repair_limit_tier gt=$repair_gt_mode suspicious_pct=${repair_suspicious_pct}%)"
    
    # Loguj operację repair
    status_log_op "$cycle" "AUTO_TRANSLATE" "REPAIR_IDENTICAL_DONE" "$R_LANG" "$R_FILE" "ok" "repair_identical lang=${R_LANG} file=${R_FILE} target_identical=${R_COUNT} limit=${repair_limit} tier=${repair_limit_tier} domain_cap=${domain_limit} gt=${repair_gt_mode} suspicious_pct=${repair_suspicious_pct}" "" "" "" "$R_TRANSLATED" ""

    # Artefakt tuningu repair (do obserwacji trendu suspicious_high per domena).
    python3 - "$STATUS_DIR/identical_to_en_repair_tuning.jsonl" "$cycle" "$R_LANG" "$R_FILE" "$R_COUNT" "$repair_limit" "$repair_limit_tier" "$domain_limit" "$repair_suspicious_pct" "$repair_suspicious_high" "$repair_suspicious_translated" "$repair_gt_mode" "$R_TRANSLATED" "$R_GUARD_FAIL" <<'PYREPAIRTUNING'
import json, os, sys
from datetime import datetime, timezone

path = sys.argv[1]
cycle = int(float(sys.argv[2])) if str(sys.argv[2]).strip() else 0
lang = sys.argv[3]
json_file = sys.argv[4]
target_identical = int(float(sys.argv[5])) if str(sys.argv[5]).strip() else 0
limit = int(float(sys.argv[6])) if str(sys.argv[6]).strip() else 0
tier = sys.argv[7]
domain_cap = int(float(sys.argv[8])) if str(sys.argv[8]).strip() else 0
try:
    suspicious_pct = float(sys.argv[9])
except Exception:
    suspicious_pct = 0.0
suspicious_high = int(float(sys.argv[10])) if str(sys.argv[10]).strip() else 0
suspicious_translated = int(float(sys.argv[11])) if str(sys.argv[11]).strip() else 0
gt_mode = str(sys.argv[12])
translated = int(float(sys.argv[13])) if str(sys.argv[13]).strip() else 0
guard_fail = int(float(sys.argv[14])) if str(sys.argv[14]).strip() else 0

os.makedirs(os.path.dirname(path), exist_ok=True)
entry = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "cycle": cycle,
    "lang": lang,
    "json_file": json_file,
    "target_identical": target_identical,
    "limit": limit,
    "tier": tier,
    "domain_cap": domain_cap,
    "suspicious_high_pct": round(float(suspicious_pct), 3),
    "suspicious_high_count": suspicious_high,
    "suspicious_translated_total": suspicious_translated,
    "gt_mode": gt_mode,
    "translated": translated,
    "guard_fail": guard_fail,
}
with open(path, "a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False) + "\n")
PYREPAIRTUNING
    
    # Wyczyść cache selektora (repair zmienił dane)
    rm -f "$STATUS_DIR/translation_strict_candidates_cache.json" 2>/dev/null || true

    return 0
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
    
    local strict_mode="false"
    if [ "${TRANSLATIONS_STRICT:-false}" = "true" ]; then
        strict_mode="true"
    fi

    log "${CYAN}🌍 AUTO TRANSLATE: $target_lang <- $json_file (limit: $translate_limit, strict: $strict_mode, GT: $USE_GOOGLE_TRANSLATE)${NC}"
    
    local _at_out _at_rc _translated _placeholders
    _at_out=$(USE_GOOGLE_TRANSLATE="$USE_GOOGLE_TRANSLATE" GT_BATCH_SIZE="$GT_BATCH_SIZE" GT_DELAY="$GT_DELAY" python3 - "$target_lang" "$json_file" "$translate_limit" "$strict_mode" << 'AUTOTRANSPY'
import json
import os
import re
import hashlib
import sys
from datetime import datetime, timezone

I18N_DIR = "i18n"
target_lang = sys.argv[1]
json_file = sys.argv[2]
translate_limit = int(sys.argv[3] or "0")
strict_mode = sys.argv[4] == "true"
status_dir = os.environ.get("STATUS_DIR", os.path.join(I18N_DIR, "status"))
proper_nouns_path = os.path.join(status_dir, "tibia_proper_nouns.json")

try:
    with open(proper_nouns_path, "r", encoding="utf-8") as f:
        _pn_data = json.load(f)
    TIBIA_PROPER_NOUNS = set(str(x).strip() for x in _pn_data.get("terms", []) if str(x).strip())
except Exception:
    TIBIA_PROPER_NOUNS = set()

# Google Translate config (from env)
use_google_translate = os.environ.get("USE_GOOGLE_TRANSLATE", "false") == "true"
gt_batch_size = int(os.environ.get("GT_BATCH_SIZE", "50"))
gt_delay = float(os.environ.get("GT_DELAY", "1.5"))

# Mapowanie kodów języków i18n -> kody Google Translate
GT_LANG_MAP = {
    "pt-br": "pt", "zh": "zh-CN", "zh-cn": "zh-CN", "zh-tw": "zh-TW", "zh_tw": "zh-TW", "he": "iw",
    "sr": "sr", "bs": "bs", "no": "no", "nb": "no",
}

def _gt_lang_code(lang):
    """Konwertuj kod języka i18n na kod Google Translate."""
    raw = str(lang or "").strip()
    low = raw.lower()
    normalized = low.replace("_", "-")
    return GT_LANG_MAP.get(raw) or GT_LANG_MAP.get(low) or GT_LANG_MAP.get(normalized) or raw

def _protect_placeholders(text):
    """Zamień placeholdery, HTML tagi, escape sequences i nazwy własne na tokeny ochronne przed GT."""
    replacements = {}
    idx = [0]
    def _replace(m):
        token = f"__PH{idx[0]}__"
        replacements[token] = m.group(0)
        idx[0] += 1
        return token
    protected = str(text)
    # Krok 1: Chroń nazwy własne Tibia NAJPIERW (zanim regex zamieni otaczające tagi)
    if TIBIA_PROPER_NOUNS:
        sorted_nouns = sorted(
            (n for n in TIBIA_PROPER_NOUNS if len(n) > 4),
            key=len, reverse=True
        )
        for noun in sorted_nouns:
            if noun in protected:
                pattern = r'\b' + re.escape(noun) + r'\b'
                protected = re.sub(pattern, lambda m, n=noun: _replace(m), protected, count=0)
    # Krok 2: Chroń placeholdery, tagi HTML, escape sequences, komendy
    protected = re.sub(
        r"\{[^}]*\}"               # {0}, {player}, {}
        r"|%[0-9]*[sdifuxXcp%]"    # %s, %d, %02d, %%
        r"|\|[A-Z_]+\|"           # |PLAYERNAME|, |NAME|
        r"|''[^']*''"             # ''trade'', ''job''
        r"|(?<!['\w])'([^']{1,200}?)'(?!')"   # 'task', 'keyword', 'long game command' — single-quoted commands
        r"|'\/[a-zA-Z]+'"         # '/heal', '/cast'
        r"|<[a-zA-Z/][^>]*>"     # <b>, </b>, <br>, <font color='red'>
        r"|\\[ntr]"               # \n, \t, \r
        r"|&[a-zA-Z]+;"          # &amp;, &lt;, &gt;
        r"|&#[0-9]+;"            # &#123;
        , _replace, protected)
    return protected, replacements

def _restore_placeholders(text, replacements):
    """Przywróć oryginalne placeholdery po tłumaczeniu GT."""
    for token, original in replacements.items():
        text = text.replace(token, original)
    return text

# Prosty słownik tłumaczeń dla popularnych fraz
SIMPLE_TRANSLATIONS = {
    "pl": {
        # === Powitania / Pożegnania ===
        "Hello": "Witaj",
        "Hello!": "Witaj!",
        "Hi": "Cześć",
        "Hi!": "Cześć!",
        "Welcome": "Witamy",
        "Welcome!": "Witamy!",
        "Goodbye": "Do widzenia",
        "Good bye.": "Do widzenia.",
        "Good bye!": "Do widzenia!",
        "Good bye then.": "W takim razie do widzenia.",
        "Good bye, |PLAYERNAME|.": "Do widzenia, |PLAYERNAME|.",
        "Bye.": "Cześć.",
        "Bye!": "Cześć!",
        "Bye, bye.": "Pa, pa.",
        "Bye, |PLAYERNAME|.": "Cześć, |PLAYERNAME|.",
        "Well, bye then.": "No to cześć.",
        "See you my friend.": "Do zobaczenia, przyjacielu.",
        "Farewell.": "Żegnaj.",
        "Farewell!": "Żegnaj!",
        "Have a nice day.": "Miłego dnia.",
        "Have a nice day!": "Miłego dnia!",
        "Good bye and don't forget me!": "Do widzenia i nie zapomnij o mnie!",
        "Good bye. Come back soon.": "Do widzenia. Wracaj wkrótce.",
        "Good bye. Recommend us if you were satisfied with our service.": "Do widzenia. Polecaj nas, jeśli byłeś zadowolony z naszych usług.",
        "Please come back from time to time.": "Wracaj od czasu do czasu.",
        "We would like to serve you some time.": "Chętnie ci kiedyś usłużymy.",
        "May your path always be even.": "Niech twoja droga będzie zawsze równa.",
        "It was a pleasure to help you, |PLAYERNAME|.": "Cieszę się, że mogłem ci pomóc, |PLAYERNAME|.",
        "May the gods bless you, |PLAYERNAME|!": "Niech bogowie ci błogosławią, |PLAYERNAME|!",
        "Greetings, |PLAYERNAME|.": "Pozdrowienia, |PLAYERNAME|.",
        # === Tak/Nie/Anuluj ===
        "Yes": "Tak",
        "Yes!": "Tak!",
        "Yes?": "Tak?",
        "No": "Nie",
        "No!": "Nie!",
        "Ok": "Ok",
        "Ok.": "Ok.",
        "Ok then.": "No dobrze.",
        "Cancel": "Anuluj",
        "Sure.": "Jasne.",
        "Fine.": "Dobrze.",
        "Sorry.": "Przepraszam.",
        "Sorry!": "Przepraszam!",
        "Oh well.": "No cóż.",
        "Oh...": "Och...",
        "Then not.": "W takim razie nie.",
        "No problem.": "Nie ma problemu.",
        "Fine. You are free to decline my offer.": "Dobrze. Możesz odrzucić moją ofertę.",
        "Sorry, not possible.": "Przepraszam, to niemożliwe.",
        # === Handel ===
        "Buy": "Kup",
        "Sell": "Sprzedaj",
        "Trade": "Handel",
        "Gold": "Złoto",
        "You don't have enough money.": "Nie masz wystarczająco dużo pieniędzy.",
        "Sorry, you don't have enough money.": "Przepraszam, nie masz wystarczająco dużo pieniędzy.",
        "Here you are.": "Proszę bardzo.",
        "Here you are. Take care.": "Proszę bardzo. Uważaj na siebie.",
        "Here it is.": "Oto jest.",
        "Of course, just browse through my wares. You can also look at {}.": "Oczywiście, przejrzyj moje towary. Możesz też zobaczyć {}.",
        "You don't have it...": "Nie masz tego...",
        "You shouldn't miss the experience.": "Nie powinieneś tracić doświadczenia.",
        # === NPC ogólne ===
        "How could I help you?": "Jak mogę ci pomóc?",
        "Well, can I help you with something else?": "Cóż, mogę ci w czymś jeszcze pomóc?",
        "Talk to me if you need directions.": "Porozmawiaj ze mną, jeśli potrzebujesz wskazówek.",
        "I am the captain of this ship.": "Jestem kapitanem tego statku.",
        "Do you seek a passage to {0} for {1}?": "Szukasz przeprawy do {0} za {1}?",
        "Welcome on board, |PLAYERNAME|. Where can I {sail} you today?": "Witaj na pokładzie, |PLAYERNAME|. Dokąd mogę cię dziś {sail}?",
        "Yes? What may I do for you, |PLAYERNAME|? Bank business, perhaps?": "Tak? Czym mogę ci służyć, |PLAYERNAME|? Może sprawy bankowe?",
        "Don't forget to deposit your money here in the Global Bank before you head out for adventure.": "Nie zapomnij wpłacić pieniędzy w Globalnym Banku przed wyruszeniem na przygodę.",
        "Free escort to the depot for newcomers!": "Darmowa eskorta do depo dla nowych graczy!",
        "Hello and welcome in the Gnomprona Gardens": "Witaj w Ogrodach Gnomprona",
        "Keep your adventurer's stone well.": "Pilnuj dobrze swojego kamienia poszukiwacza przygód.",
        "Ah, you want to replace your adventurer's stone for free?": "Chcesz wymienić swój kamień poszukiwacza przygód za darmo?",
        "Ah, you want to replace your adventurer's stone for 30 gold?": "Chcesz wymienić swój kamień poszukiwacza przygód za 30 złotych?",
        "LONG LIVE THE KING!": "NIECH ŻYJE KRÓL!",
        "LONG LIVE THE QUEEN!": "NIECH ŻYJE KRÓLOWA!",
        # === Leczenie / Blessings ===
        "You are hurt, my child. I will heal your wounds.": "Jesteś ranny, moje dziecko. Uleczę twoje rany.",
        "Remember: If you are heavily wounded or poisoned, I can heal you for free.": "Pamiętaj: jeśli jesteś ciężko ranny lub zatruty, mogę cię uleczyć za darmo.",
        "Welcome, young |PLAYERNAME|! If you are heavily wounded or poisoned, I can {heal} you for free.": "Witaj, młody |PLAYERNAME|! Jeśli jesteś ciężko ranny lub zatruty, mogę cię {heal} za darmo.",
        "So receive the protection of the twist of fate, pilgrim.": "Przyjmij ochronę zrządzenia losu, pielgrzymie.",
        "You can ask for the blessing of spiritual shielding in the whiteflower temple south of Thais.": "Możesz poprosić o błogosławieństwo duchowej tarczy w świątyni białokwiatowej na południe od Thais.",
        "You can ask for the blessing of the two suns in the suntower near Ab'Dendriel.": "Możesz poprosić o błogosławieństwo dwóch słońc w wieży słonecznej koło Ab'Dendriel.",
        "The spark of the phoenix is given by the dwarven priests of earth and fire in Kazordoon.": "Iskra feniksa jest dawana przez krasnoludzkich kapłanów ziemi i ognia w Kazordoon.",
        "The druids north of Carlin will provide you with the embrace of Tibia.": "Druidzi na północ od Carlin obdarzą cię objęciem Tibii.",
        "A hermit near Carlin might be able to tell you more about it": "Pustelnik koło Carlin może ci o tym więcej opowiedzieć",
        "I see you received the spiritual shielding in the whiteflower temple south of Thais.": "Widzę, że otrzymałeś duchową tarczę w świątyni białokwiatowej na południe od Thais.",
        "I can sense that the druids north of Carlin have provided you with the Embrace of Tibia.": "Wyczuwam, że druidzi na północ od Carlin obdarzyli cię Objęciem Tibii.",
        "I can see you received the blessing of the two suns in the suntower near Ab'Dendriel.": "Widzę, że otrzymałeś błogosławieństwo dwóch słońc w wieży słonecznej koło Ab'Dendriel.",
        # === Przedmioty / Otoczenie ===
        "closed door": "zamknięte drzwi",
        "open door": "otwarte drzwi",
        "gate of expertise": "brama wiedzy",
        "stairs": "schody",
        "unknown item": "nieznany przedmiot",
        "It is locked.": "Jest zamknięte.",
        "It is empty.": "Jest puste.",
        "The door seems to be sealed against unwanted intruders.": "Drzwi wydają się być zabezpieczone przed niechcianymi intruzami.",
        "Somebody is sleeping there": "Ktoś tam śpi",
        "The chest is empty.": "Skrzynia jest pusta.",
        "stone wall": "kamienna ściana",
        "stone floor": "kamienna podłoga",
        "wooden floor": "drewniana podłoga",
        "flower pot": "doniczka z kwiatem",
        "wall lamp": "kinkiet",
        "lit wall lamp": "zapalony kinkiet",
        "cozy couch": "przytulna kanapa",
        "hole": "dziura",
        "ladder": "drabina",
        "trapdoor": "klapa",
        "parchment": "pergamin",
        "book": "księga",
        "chest": "skrzynia",
        "crate": "skrzynka",
        "skull": "czaszka",
        "stone": "kamień",
        "snow": "śnieg",
        "grass": "trawa",
        "earth": "ziemia",
        "entrance": "wejście",
        "fire field": "pole ognia",
        "magic tile": "magiczna płytka",
        "crystal column": "kryształowa kolumna",
        "ramp": "rampa",
        "bed": "łóżko",
        "simple bed": "proste łóżko",
        "hammock": "hamak",
        "verdant bed": "zielone łóżko",
        "homely bed": "domowe łóżko",
        "wrought-iron bed": "łóżko z kutego żelaza",
        "magnificent bed": "wspaniałe łóżko",
        "ornate bed": "ozdobne łóżko",
        "vengothic bed": "vengothickie łóżko",
        "grandiose couch": "okazała kanapa",
        "grandiose bed": "okazałe łóżko",
        "log bed": "łóżko z bali",
        "kraken bed": "łóżko krakena",
        "sleeping mat": "mata do spania",
        "knightly bed": "rycerskie łóżko",
        "flower bed": "kwiatowe łóżko",
        "seafarer bed": "łóżko żeglarza",
        "opulent kline": "luksusowa kline",
        "straw mat": "słomiana mata",
        "knightly bench": "rycerska ławka",
        "carved table": "rzeźbiony stół",
        "silver rune emblem": "srebrny emblemat runiczny",
        "golden rune emblem": "złoty emblemat runiczny",
        "golden outfit display": "złota gablotka strojów",
        "Souvenir from Thais Museum": "Pamiątka z Muzeum Thais",
        "This replica looks charged": "Ta replika wygląda na naładowaną",
        "This replica looks heavily charged": "Ta replika wygląda na mocno naładowaną",
        "This replica looks overcharged": "Ta replika wygląda na przeładowaną",
        "It can be disassembled with the right tool": "Można to rozmontować odpowiednim narzędziem",
        "You need to wait before using it again.": "Musisz poczekać zanim użyjesz tego ponownie.",
        "You have %s hours and %s minutes left": "Pozostało %s godzin i %s minut",
        # === Trupy / Monster ===
        "dead orc": "martwy ork",
        "dead human": "martwy człowiek",
        "dead troll": "martwy trol",
        "dead corpse": "martwe zwłoki",
        "dead wolf": "martwy wilk",
        "dead dwarf": "martwy krasnolud",
        "dead cyclops": "martwy cyklop",
        "dead dragon": "martwy smok",
        "dead bear": "martwy niedźwiedź",
        "dead dworc": "martwy dworc",
        "dead spider": "martwy pająk",
        "dead elf": "martwy elf",
        "dead dragon hatchling": "martwe pisklę smoka",
        "dead djinn": "martwy dżinn",
        "dead chakoya": "martwy chakoya",
        "dead iks": "martwy iks",
        "dead rat": "martwy szczur",
        "dead minotaur": "martwy minotaur",
        "slain skeleton": "zabity szkielet",
        # === Odgłosy stworzeń ===
        "Ribbit!": "Kum!",
        "Ribbit! Ribbit!": "Kum! Kum!",
        "Grrr.": "Grrr.",
        "Hiss.": "Syk.",
        "FIRE!": "OGIEŃ!",
        "BURN!": "PŁOŃ!",
        "Meat!": "Mięso!",
        "MINE!": "MOJE!",
        "PAIN!": "BÓL!",
        # === NPC podróże ===
        "Pssst! Keep it down! <gives you an elaborate report on monster activity>": "Pssst! Ciszej! <daje ci szczegółowy raport o aktywności potworów>",
        # === Terminy gry ===
        "Item": "Przedmiot",
        "Spell": "Zaklęcie",
        "Attack": "Atak",
        "Defense": "Obrona",
        "Health": "Zdrowie",
        "Mana": "Mana",
        "Help": "Pomoc",
        "Quest": "Zadanie",
        "Mission": "Misja",
        "Player": "Gracz",
        "Monster": "Potwór",
        "Name": "Nazwa",
        "Level": "Poziom",
        "Status": "Status",
        "Error": "Błąd",
        "Close": "Zamknij",
        "Description": "Opis",
        "The": "Ten",
        "RESERVED SPRITE": "ZAREZERWOWANY SPRITE",
        "Sort by name": "Sortuj po nazwie",
        "Loading": "Ładowanie",
        # === Znalezione przedmioty ===
        "You found ": "Znalazłeś ",
        "You found a bag.": "Znalazłeś torbę.",
        "You found a wooden sword.": "Znalazłeś drewniany miecz.",
        "You found a beautiful pearl.": "Znalazłeś piękną perłę.",
        "You found Waldo's posthorn.": "Znalazłeś róg pocztowy Waldo.",
        "You found %s %s in the bag.": "W torbie znalazłeś %s %s.",
        "You found {0} in the bag.": "W torbie znalazłeś {0}.",
        "You found {} while digging.": "Podczas kopania znalazłeś {}.",
        # === Materiały / kompozycje (poprawna gramatyka polska) ===
        "stone wall": "kamienna ściana",
        "Stone Wall": "Kamienna Ściana",
        "stone floor": "kamienna podłoga",
        "Stone Floor": "Kamienna Podłoga",
        "stone stairs": "kamienne schody",
        "Stone Stairs": "Kamienne Schody",
        "stone tile": "kamienna płytka",
        "stone pillar": "kamienny filar",
        "stone bridge": "kamienny most",
        "wooden floor": "drewniana podłoga",
        "Wooden Floor": "Drewniana Podłoga",
        "wooden wall": "drewniana ściana",
        "wooden door": "drewniane drzwi",
        "wooden chest": "drewniana skrzynia",
        "wooden box": "drewniane pudełko",
        "wooden table": "drewniany stół",
        "wooden chair": "drewniane krzesło",
        "wooden shelf": "drewniana półka",
        "wooden stairs": "drewniane schody",
        "wooden barrel": "drewniana beczka",
        "wall lamp": "lampa ścienna",
        "Wall Lamp": "Lampa Ścienna",
        "dead corpse": "martwe zwłoki",
        "Dead Corpse": "Martwe Zwłoki",
        "unknown corpse": "nieznane zwłoki",
        "Unknown Corpse": "Nieznane Zwłoki",
        "dead witch": "martwa wiedźma",
        "dead spider": "martwy pająk",
        "dead crystal wolf": "martwy kryształowy wilk",
        "dead ghost wolf": "martwy widmowy wilk",
        "dead sacred spider": "martwy święty pająk",
        "slain ice witch": "zabita lodowa wiedźma",
        "Magic Level": "Poziom Magii",
        "magic level": "poziom magii",
        "Item Name": "Nazwa Przedmiotu",
        "item name": "nazwa przedmiotu",
        "special flask": "specjalna butelka",
        "Special Flask": "Specjalna Butelka",
        "spell rune": "runa zaklęcia",
        "Spell Rune": "Runa Zaklęcia",
        "dead human": "martwy człowiek",
        "dead rat": "martwy szczur",
        "dead wolf": "martwy wilk",
        "dead bear": "martwy niedźwiedź",
        "dead troll": "martwy trol",
        "dead orc": "martwy ork",
        "dead dragon": "martwy smok",
        "dead demon": "martwy demon",
        "dead dwarf": "martwy krasnolud",
        "dead elf": "martwy elf",
        "dead goblin": "martwy goblin",
        "dead giant": "martwy olbrzym",
        "dead vampire": "martwy wampir",
        "dead skeleton": "martwy szkielet",
        "dead zombie": "martwy zombi",
        "dead knight": "martwy rycerz",
        "dead warrior": "martwy wojownik",
        "dead minotaur": "martwy minotaur",
        "dead werewolf": "martwy wilkołak",
        "slain skeleton": "zabity szkielet",
        "slain orc": "zabity ork",
        "slain troll": "zabity trol",
        "slain goblin": "zabity goblin",
        "slain wolf": "zabity wilk",
        "slain rat": "zabity szczur",
        "slain spider": "zabity pająk",
        "slain dragon": "zabity smok",
        "gold coin": "złota moneta",
        "Gold Coin": "Złota Moneta",
        "gold coins": "złote monety",
        "silver coin": "srebrna moneta",
        "crystal coin": "kryształowa moneta",
        "iron helmet": "żelazny hełm",
        "iron armor": "żelazny pancerz",
        "iron shield": "żelazna tarcza",
        "steel helmet": "stalowy hełm",
        "steel armor": "stalowy pancerz",
        "steel shield": "stalowa tarcza",
        "golden armor": "złoty pancerz",
        "ancient shield": "starożytna tarcza",
        "magic shield": "magiczna tarcza",
        "enchanted sword": "zaczarowany miecz",
        "enchanted staff": "zaczarowany kostur",
        "Royal Paladin": "Królewski Paladyn",
        "Elite Knight": "Elitarny Rycerz",
        "Master Sorcerer": "Arcyczarnoksiężnik",
        "Elder Druid": "Starszy Druid",
        "dark cave": "ciemna jaskinia",
        "old temple": "stara świątynia",
        "ancient temple": "starożytna świątynia",
        "dark tower": "ciemna wieża",
        "crystal cave": "kryształowa jaskinia",
        "snow ramp": "śnieżna rampa",
        "dirt floor": "ziemna podłoga",
        "dirt ramp": "ziemna rampa",
        "grass floor": "trawiasta podłoga",
        "sand floor": "piaszczysta podłoga",
        "ice floor": "lodowa podłoga",
        "North East": "Północny Wschód",
        "North West": "Północny Zachód",
        "South East": "Południowy Wschód",
        "South West": "Południowy Zachód",
        "north east": "północny wschód",
        "north west": "północny zachód",
        "south east": "południowy wschód",
        "south west": "południowy zachód",
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
        "Good bye.": "Adiós.",
        "Good bye!": "¡Adiós!",
        "Good bye then.": "Bueno, adiós entonces.",
        "Bye.": "Chao.",
        "Bye!": "¡Chao!",
        "Bye, bye.": "Chao, chao.",
        "Thank you": "Gracias",
        "Yes": "Sí",
        "No": "No",
        "Buy": "Comprar",
        "Sell": "Vender",
        "Trade": "Comercio",
        "Help": "Ayuda",
        "Quest": "Misión",
        "Town not found.": "Ciudad no encontrada.",
        "Helmet": "Casco",
        "Left Hand": "Mano izquierda",
        "Right Hand": "Mano derecha",
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
    },
    "tr": {
        # === Selamlaşmalar / Vedalaşmalar ===
        "Hello": "Merhaba",
        "Hello!": "Merhaba!",
        "Hi": "Selam",
        "Hi!": "Selam!",
        "Welcome": "Hoş geldin",
        "Welcome!": "Hoş geldin!",
        "Goodbye": "Hoşça kal",
        "Good bye.": "Hoşça kal.",
        "Good bye!": "Hoşça kal!",
        "Good bye then.": "O zaman hoşça kal.",
        "Good bye, |PLAYERNAME|.": "Hoşça kal, |PLAYERNAME|.",
        "Bye.": "Güle güle.",
        "Bye!": "Güle güle!",
        "Bye, bye.": "Güle güle.",
        "Bye, |PLAYERNAME|.": "Güle güle, |PLAYERNAME|.",
        "Well, bye then.": "Peki, hoşça kal o zaman.",
        "See you my friend.": "Görüşürüz dostum.",
        "Farewell.": "Elveda.",
        "Farewell!": "Elveda!",
        "Have a nice day.": "İyi günler.",
        "Have a nice day!": "İyi günler!",
        "Good bye and don't forget me!": "Hoşça kal ve beni unutma!",
        "Good bye. Come back soon.": "Hoşça kal. Yakında tekrar gel.",
        "Good bye. Recommend us if you were satisfied with our service.": "Hoşça kal. Hizmetimizden memnun kaldıysan bizi tavsiye et.",
        "Please come back from time to time.": "Lütfen zaman zaman tekrar gel.",
        "We would like to serve you some time.": "Size bir zaman hizmet etmek isteriz.",
        "May your path always be even.": "Yolun hep düz olsun.",
        "It was a pleasure to help you, |PLAYERNAME|.": "Sana yardım etmek bir zevkti, |PLAYERNAME|.",
        "May the gods bless you, |PLAYERNAME|!": "Tanrılar seni korusun, |PLAYERNAME|!",
        "Greetings, |PLAYERNAME|.": "Selamlar, |PLAYERNAME|.",
        # === Evet/Hayır/İptal ===
        "Yes": "Evet",
        "Yes!": "Evet!",
        "Yes?": "Evet?",
        "No": "Hayır",
        "No!": "Hayır!",
        "Ok": "Tamam",
        "Ok.": "Tamam.",
        "Ok then.": "Peki o zaman.",
        "Cancel": "İptal",
        "Sure.": "Tabii.",
        "Fine.": "İyi.",
        "Sorry.": "Özür dilerim.",
        "Sorry!": "Özür dilerim!",
        "Oh well.": "Neyse.",
        "Oh...": "Ah...",
        "Then not.": "O zaman hayır.",
        "No problem.": "Sorun değil.",
        "Fine. You are free to decline my offer.": "Peki. Teklifimi reddetmekte özgürsün.",
        "Sorry, not possible.": "Üzgünüm, mümkün değil.",
        # === Ticaret ===
        "Buy": "Satın al",
        "Sell": "Sat",
        "Trade": "Takas",
        "Gold": "Altın",
        "You don't have enough money.": "Yeterli paran yok.",
        "Sorry, you don't have enough money.": "Üzgünüm, yeterli paran yok.",
        "Here you are.": "Buyur.",
        "Here you are. Take care.": "Buyur. Kendine iyi bak.",
        "Here it is.": "İşte burada.",
        "Of course, just browse through my wares. You can also look at {}.": "Tabii, mallarıma göz at. Ayrıca {} de bakabilirsin.",
        "You don't have it...": "Sende yok...",
        "You shouldn't miss the experience.": "Bu deneyimi kaçırmamalısın.",
        # === NPC genel ===
        "How could I help you?": "Sana nasıl yardımcı olabilirim?",
        "Well, can I help you with something else?": "Peki, başka bir konuda yardımcı olabilir miyim?",
        "Talk to me if you need directions.": "Yön tarifi lazımsa benimle konuş.",
        "I am the captain of this ship.": "Bu geminin kaptanıyım.",
        "Do you seek a passage to {0} for {1}?": "{0} yolculuğu {1} karşılığında ister misin?",
        "Welcome on board, |PLAYERNAME|. Where can I {sail} you today?": "Gemiye hoş geldin, |PLAYERNAME|. Bugün seni nereye {sail} edebilirim?",
        "Yes? What may I do for you, |PLAYERNAME|? Bank business, perhaps?": "Evet? Sana nasıl yardımcı olabilirim, |PLAYERNAME|? Banka işleri belki?",
        "Don't forget to deposit your money here in the Global Bank before you head out for adventure.": "Maceraya çıkmadan önce paranı Global Banka yatırmayı unutma.",
        "Free escort to the depot for newcomers!": "Yeni oyuncular için depoya ücretsiz eşlik!",
        "Hello and welcome in the Gnomprona Gardens": "Merhaba ve Gnomprona Bahçelerine hoş geldin",
        "Keep your adventurer's stone well.": "Maceracı taşını iyi koru.",
        "Ah, you want to replace your adventurer's stone for free?": "Maceracı taşını ücretsiz değiştirmek mi istiyorsun?",
        "Ah, you want to replace your adventurer's stone for 30 gold?": "Maceracı taşını 30 altına değiştirmek mi istiyorsun?",
        "LONG LIVE THE KING!": "YAŞASIN KRAL!",
        "LONG LIVE THE QUEEN!": "YAŞASIN KRALİÇE!",
        # === İyileşme / Kutsama ===
        "You are hurt, my child. I will heal your wounds.": "Yaralısın, çocuğum. Yaralarını iyileştireceğim.",
        "Remember: If you are heavily wounded or poisoned, I can heal you for free.": "Unutma: Ağır yaralı veya zehirlenmişsen seni ücretsiz iyileştirebilirim.",
        "Welcome, young |PLAYERNAME|! If you are heavily wounded or poisoned, I can {heal} you for free.": "Hoş geldin, genç |PLAYERNAME|! Ağır yaralı veya zehirlenmişsen seni ücretsiz {heal} edebilirim.",
        "So receive the protection of the twist of fate, pilgrim.": "Kaderin bükülesinin korumasını al, hacı.",
        "You can ask for the blessing of spiritual shielding in the whiteflower temple south of Thais.": "Thais'in güneyindeki beyaz çiçek tapınağında ruhani kalkan kutsağını isteyebilirsin.",
        "You can ask for the blessing of the two suns in the suntower near Ab'Dendriel.": "Ab'Dendriel yakınlarındaki güneş kulesinde iki güneşin kutsağını isteyebilirsin.",
        "The spark of the phoenix is given by the dwarven priests of earth and fire in Kazordoon.": "Anka kuşu kıvılcımı Kazordoon'daki cüce toprak ve ateş rahipleri tarafından verilir.",
        "The druids north of Carlin will provide you with the embrace of Tibia.": "Carlin'in kuzeyindeki druidler sana Tibia'nın kucaklamasını sağlayacak.",
        "A hermit near Carlin might be able to tell you more about it": "Carlin yakınlarındaki bir münzevi sana daha fazla bilgi verebilir",
        "I see you received the spiritual shielding in the whiteflower temple south of Thais.": "Thais'in güneyindeki beyaz çiçek tapınağında ruhani kalkanı aldığını görüyorum.",
        "I can sense that the druids north of Carlin have provided you with the Embrace of Tibia.": "Carlin'in kuzeyindeki druidlerin sana Tibia'nın Kucaklamasını sağladığını hissedebiliyorum.",
        "I can see you received the blessing of the two suns in the suntower near Ab'Dendriel.": "Ab'Dendriel yakınlarındaki güneş kulesinde iki güneşin kutsağını aldığını görebiliyorum.",
        # === Eşyalar / Çevre ===
        "closed door": "kapalı kapı",
        "open door": "açık kapı",
        "gate of expertise": "uzmanlık kapısı",
        "stairs": "merdivenler",
        "unknown item": "bilinmeyen eşya",
        "It is locked.": "Kilitli.",
        "It is empty.": "Boş.",
        "The door seems to be sealed against unwanted intruders.": "Kapı istenmeyen davetsiz misafirlere karşı mühürlenmiş görünüyor.",
        "Somebody is sleeping there": "Orada birisi uyuyor",
        "The chest is empty.": "Sandık boş.",
        "stone wall": "taş duvar",
        "stone floor": "taş zemin",
        "wooden floor": "ahşap zemin",
        "flower pot": "saksı",
        "wall lamp": "duvar lambası",
        "lit wall lamp": "yanan duvar lambası",
        "cozy couch": "rahat kanepe",
        "hole": "delik",
        "ladder": "merdiven",
        "trapdoor": "tuzak kapı",
        "parchment": "parşömen",
        "book": "kitap",
        "chest": "sandık",
        "crate": "kasa",
        "skull": "kafatası",
        "stone": "taş",
        "snow": "kar",
        "grass": "çimen",
        "earth": "toprak",
        "entrance": "giriş",
        "fire field": "ateş alanı",
        "magic tile": "sihirli karo",
        "crystal column": "kristal sütun",
        "ramp": "rampa",
        "bed": "yatak",
        "simple bed": "basit yatak",
        "hammock": "hamak",
        "verdant bed": "yeşil yatak",
        "homely bed": "ev yatağı",
        "wrought-iron bed": "ferforje yatak",
        "magnificent bed": "muhteşem yatak",
        "ornate bed": "süslü yatak",
        "vengothic bed": "vengothik yatak",
        "grandiose couch": "görkemli kanepe",
        "grandiose bed": "görkemli yatak",
        "log bed": "kütük yatak",
        "kraken bed": "kraken yatağı",
        "sleeping mat": "uyku matı",
        "knightly bed": "şövalye yatağı",
        "flower bed": "çiçekli yatak",
        "seafarer bed": "denizci yatağı",
        "opulent kline": "lüks kline",
        "straw mat": "saman mat",
        "knightly bench": "şövalye bankı",
        "carved table": "oyma masa",
        "silver rune emblem": "gümüş rün amblemi",
        "golden rune emblem": "altın rün amblemi",
        "golden outfit display": "altın kıyafet vitrini",
        "Souvenir from Thais Museum": "Thais Müzesi hatırası",
        "This replica looks charged": "Bu replika şarjlı görünüyor",
        "This replica looks heavily charged": "Bu replika çok şarjlı görünüyor",
        "This replica looks overcharged": "Bu replika aşırı şarjlı görünüyor",
        "It can be disassembled with the right tool": "Doğru aletle sökülebilir",
        "You need to wait before using it again.": "Tekrar kullanmadan önce beklemelisin.",
        "You have %s hours and %s minutes left": "%s saat ve %s dakikan kaldı",
        # === Ölüler / Canavar ===
        "dead orc": "ölü ork",
        "dead human": "ölü insan",
        "dead troll": "ölü trol",
        "dead corpse": "ölü ceset",
        "dead wolf": "ölü kurt",
        "dead dwarf": "ölü cüce",
        "dead cyclops": "ölü tepegöz",
        "dead dragon": "ölü ejderha",
        "dead bear": "ölü ayı",
        "dead dworc": "ölü dworc",
        "dead spider": "ölü örümcek",
        "dead elf": "ölü elf",
        "dead dragon hatchling": "ölü ejderha yavrusu",
        "dead djinn": "ölü cin",
        "dead chakoya": "ölü chakoya",
        "dead iks": "ölü iks",
        "dead rat": "ölü fare",
        "dead minotaur": "ölü minotaur",
        "slain skeleton": "öldürülmüş iskelet",
        # === Yaratık sesleri ===
        "Ribbit!": "Vrak!",
        "Ribbit! Ribbit!": "Vrak! Vrak!",
        "Grrr.": "Grrr.",
        "Hiss.": "Tıs.",
        "FIRE!": "ATEŞ!",
        "BURN!": "YAN!",
        "Meat!": "Et!",
        "MINE!": "BENİM!",
        "PAIN!": "ACI!",
        # === NPC yolculuklar ===
        "Pssst! Keep it down! <gives you an elaborate report on monster activity>": "Pssst! Sessiz ol! <canavar aktivitesi hakkında detaylı rapor verir>",
        # === Oyun terimleri ===
        "Item": "Eşya",
        "Spell": "Büyü",
        "Attack": "Saldırı",
        "Defense": "Savunma",
        "Health": "Sağlık",
        "Mana": "Mana",
        "Help": "Yardım",
        "Quest": "Görev",
        "Mission": "Görev",
        "Player": "Oyuncu",
        "Monster": "Canavar",
        "Name": "İsim",
        "Level": "Seviye",
        "Status": "Durum",
        "Error": "Hata",
        "Close": "Kapat",
        "Description": "Açıklama",
        "The": "Bu",
        "RESERVED SPRITE": "AYRILMIŞ SPRİTE",
        "Sort by name": "İsme göre sırala",
        "Loading": "Yükleniyor",
        # === Bulunan eşyalar ===
        "You found ": "Buldun ",
        "You found a bag.": "Bir çanta buldun.",
        "You found a wooden sword.": "Ahşap bir kılıç buldun.",
        "You found a beautiful pearl.": "Güzel bir inci buldun.",
        "You found Waldo's posthorn.": "Waldo'nun posta borusunu buldun.",
        "You found %s %s in the bag.": "Çantada %s %s buldun.",
        "You found {0} in the bag.": "Çantada {0} buldun.",
        "You found {} while digging.": "Kazarken {} buldun.",
        "Thank you": "Teşekkür ederim",
        # === Malzeme / bileşimler (doğru Türkçe dilbilgisi) ===
        "stone wall": "taş duvar",
        "Stone Wall": "Taş Duvar",
        "stone floor": "taş zemin",
        "Stone Floor": "Taş Zemin",
        "stone stairs": "taş merdivenler",
        "stone tile": "taş karo",
        "stone pillar": "taş sütun",
        "stone bridge": "taş köprü",
        "wooden floor": "ahşap zemin",
        "Wooden Floor": "Ahşap Zemin",
        "wooden wall": "ahşap duvar",
        "wooden door": "ahşap kapı",
        "wooden chest": "ahşap sandık",
        "wooden box": "ahşap kutu",
        "wooden table": "ahşap masa",
        "wooden chair": "ahşap sandalye",
        "wooden shelf": "ahşap raf",
        "wooden stairs": "ahşap merdivenler",
        "wooden barrel": "ahşap fıçı",
        "wall lamp": "duvar lambası",
        "Wall Lamp": "Duvar Lambası",
        "dead corpse": "ölü ceset",
        "Dead Corpse": "Ölü Ceset",
        "unknown corpse": "bilinmeyen ceset",
        "dead witch": "ölü cadı",
        "dead spider": "ölü örümcek",
        "dead crystal wolf": "ölü kristal kurt",
        "dead ghost wolf": "ölü hayalet kurt",
        "dead sacred spider": "ölü kutsal örümcek",
        "slain ice witch": "öldürülmüş buz cadısı",
        "Magic Level": "Büyü Seviyesi",
        "magic level": "büyü seviyesi",
        "Item Name": "Eşya Adı",
        "item name": "eşya adı",
        "special flask": "özel şişe",
        "spell rune": "büyü rünü",
        "dead human": "ölü insan",
        "dead rat": "ölü fare",
        "dead wolf": "ölü kurt",
        "dead bear": "ölü ayı",
        "dead troll": "ölü trol",
        "dead orc": "ölü ork",
        "dead dragon": "ölü ejderha",
        "dead demon": "ölü iblis",
        "dead dwarf": "ölü cüce",
        "dead elf": "ölü elf",
        "dead goblin": "ölü goblin",
        "dead giant": "ölü dev",
        "dead vampire": "ölü vampir",
        "dead skeleton": "ölü iskelet",
        "dead zombie": "ölü zombi",
        "dead knight": "ölü şövalye",
        "dead minotaur": "ölü minotaur",
        "dead werewolf": "ölü kurtadam",
        "slain skeleton": "öldürülmüş iskelet",
        "slain orc": "öldürülmüş ork",
        "slain troll": "öldürülmüş trol",
        "slain goblin": "öldürülmüş goblin",
        "slain wolf": "öldürülmüş kurt",
        "slain rat": "öldürülmüş fare",
        "slain spider": "öldürülmüş örümcek",
        "slain dragon": "öldürülmüş ejderha",
        "gold coin": "altın sikke",
        "gold coins": "altın sikkeler",
        "silver coin": "gümüş sikke",
        "crystal coin": "kristal sikke",
        "iron helmet": "demir miğfer",
        "iron armor": "demir zırh",
        "iron shield": "demir kalkan",
        "steel helmet": "çelik miğfer",
        "steel armor": "çelik zırh",
        "steel shield": "çelik kalkan",
        "golden armor": "altın zırh",
        "ancient shield": "antik kalkan",
        "magic shield": "büyülü kalkan",
        "enchanted sword": "büyülü kılıç",
        "Royal Paladin": "Kraliyet Paladini",
        "Elite Knight": "Elit Şövalye",
        "dark cave": "karanlık mağara",
        "old temple": "eski tapınak",
        "ancient temple": "antik tapınak",
        "dark tower": "karanlık kule",
        "crystal cave": "kristal mağara",
        "snow ramp": "kar rampası",
        "dirt floor": "toprak zemin",
        "dirt ramp": "toprak rampa",
        "grass floor": "çimen zemin",
        "sand floor": "kum zemin",
        "ice floor": "buz zemin",
        "North East": "Kuzey Doğu",
        "North West": "Kuzey Batı",
        "South East": "Güney Doğu",
        "South West": "Güney Batı",
        "north east": "kuzey doğu",
        "north west": "kuzey batı",
        "south east": "güney doğu",
        "south west": "güney batı",
    },
    # ==========================================================================
    # NOWE JĘZYKI EU — Faza 1c (2026-02-14)
    # ==========================================================================
    "fr": {
        "Hello": "Bonjour",
        "Hello!": "Bonjour !",
        "Hi": "Salut",
        "Hi!": "Salut !",
        "Welcome": "Bienvenue",
        "Welcome!": "Bienvenue !",
        "Goodbye": "Au revoir",
        "Good bye.": "Au revoir.",
        "Good bye!": "Au revoir !",
        "Bye.": "Salut.",
        "Bye!": "Salut !",
        "Farewell.": "Adieu.",
        "Thank you": "Merci",
        "Thank you!": "Merci !",
        "Yes": "Oui",
        "Yes!": "Oui !",
        "No": "Non",
        "No!": "Non !",
        "Ok": "Ok",
        "Cancel": "Annuler",
        "Buy": "Acheter",
        "Sell": "Vendre",
        "Trade": "Commerce",
        "Help": "Aide",
        "Quest": "Quête",
        "Mission": "Mission",
        "Gold": "Or",
        "Gold Coin": "Pièce d'or",
        "Player": "Joueur",
        "Monster": "Monstre",
        "Item": "Objet",
        "Spell": "Sort",
        "It is empty.": "C'est vide.",
        "You are dead.": "Vous êtes mort.",
        "Town not found.": "Ville non trouvée.",
        "Helmet": "Casque",
        "Left Hand": "Main gauche",
        "Right Hand": "Main droite",
        "north": "nord",
        "south": "sud",
        "east": "est",
        "west": "ouest",
    },
    "it": {
        "Hello": "Ciao",
        "Hello!": "Ciao!",
        "Hi": "Ciao",
        "Welcome": "Benvenuto",
        "Welcome!": "Benvenuto!",
        "Goodbye": "Arrivederci",
        "Good bye.": "Arrivederci.",
        "Bye.": "Ciao.",
        "Farewell.": "Addio.",
        "Thank you": "Grazie",
        "Yes": "Sì",
        "No": "No",
        "Ok": "Ok",
        "Cancel": "Annulla",
        "Buy": "Comprare",
        "Sell": "Vendere",
        "Trade": "Commercio",
        "Help": "Aiuto",
        "Quest": "Missione",
        "Gold": "Oro",
        "Gold Coin": "Moneta d'oro",
        "Player": "Giocatore",
        "Monster": "Mostro",
        "Item": "Oggetto",
        "Spell": "Incantesimo",
        "It is empty.": "È vuoto.",
        "You are dead.": "Sei morto.",
        "Helmet": "Elmo",
        "Left Hand": "Mano sinistra",
        "Right Hand": "Mano destra",
        "north": "nord",
        "south": "sud",
        "east": "est",
        "west": "ovest",
    },
    "nl": {
        "Hello": "Hallo",
        "Hello!": "Hallo!",
        "Hi": "Hoi",
        "Welcome": "Welkom",
        "Welcome!": "Welkom!",
        "Goodbye": "Tot ziens",
        "Good bye.": "Tot ziens.",
        "Bye.": "Doei.",
        "Farewell.": "Vaarwel.",
        "Thank you": "Dank je",
        "Yes": "Ja",
        "No": "Nee",
        "Ok": "Oké",
        "Cancel": "Annuleren",
        "Buy": "Kopen",
        "Sell": "Verkopen",
        "Trade": "Handel",
        "Help": "Hulp",
        "Quest": "Opdracht",
        "Gold": "Goud",
        "Gold Coin": "Gouden munt",
        "Player": "Speler",
        "Monster": "Monster",
        "Item": "Voorwerp",
        "Spell": "Spreuk",
        "It is empty.": "Het is leeg.",
        "You are dead.": "Je bent dood.",
        "Helmet": "Helm",
        "Left Hand": "Linkerhand",
        "Right Hand": "Rechterhand",
        "north": "noord",
        "south": "zuid",
        "east": "oost",
        "west": "west",
    },
    "cs": {
        "Hello": "Ahoj",
        "Hello!": "Ahoj!",
        "Hi": "Čau",
        "Welcome": "Vítejte",
        "Welcome!": "Vítejte!",
        "Goodbye": "Sbohem",
        "Good bye.": "Sbohem.",
        "Good bye!": "Sbohem!",
        "Bye.": "Čau.",
        "Farewell.": "Sbohem.",
        "Thank you": "Děkuji",
        "Yes": "Ano",
        "Yes!": "Ano!",
        "No": "Ne",
        "No!": "Ne!",
        "Ok": "Ok",
        "Cancel": "Zrušit",
        "Buy": "Koupit",
        "Sell": "Prodat",
        "Trade": "Obchod",
        "Help": "Pomoc",
        "Quest": "Úkol",
        "Gold": "Zlato",
        "Gold Coin": "Zlatá mince",
        "Player": "Hráč",
        "Monster": "Nestvůra",
        "Item": "Předmět",
        "Spell": "Kouzlo",
        "It is empty.": "Je to prázdné.",
        "You are dead.": "Jsi mrtvý.",
        "Helmet": "Helma",
        "Left Hand": "Levá ruka",
        "Right Hand": "Pravá ruka",
        "north": "sever",
        "south": "jih",
        "east": "východ",
        "west": "západ",
    },
    "sk": {
        "Hello": "Ahoj",
        "Hello!": "Ahoj!",
        "Hi": "Čau",
        "Welcome": "Vitajte",
        "Welcome!": "Vitajte!",
        "Goodbye": "Zbohom",
        "Good bye.": "Zbohom.",
        "Bye.": "Čau.",
        "Farewell.": "Zbohom.",
        "Thank you": "Ďakujem",
        "Yes": "Áno",
        "No": "Nie",
        "Ok": "Ok",
        "Cancel": "Zrušiť",
        "Buy": "Kúpiť",
        "Sell": "Predať",
        "Trade": "Obchod",
        "Help": "Pomoc",
        "Quest": "Úloha",
        "Gold": "Zlato",
        "Gold Coin": "Zlatá minca",
        "Player": "Hráč",
        "Monster": "Príšera",
        "Item": "Predmet",
        "Spell": "Kúzlo",
        "It is empty.": "Je to prázdne.",
        "Helmet": "Helma",
        "Left Hand": "Ľavá ruka",
        "Right Hand": "Pravá ruka",
        "north": "sever",
        "south": "juh",
        "east": "východ",
        "west": "západ",
    },
    "hu": {
        "Hello": "Helló",
        "Hello!": "Helló!",
        "Hi": "Szia",
        "Welcome": "Üdvözöllek",
        "Welcome!": "Üdvözöllek!",
        "Goodbye": "Viszontlátásra",
        "Good bye.": "Viszontlátásra.",
        "Bye.": "Szia.",
        "Farewell.": "Isten veled.",
        "Thank you": "Köszönöm",
        "Yes": "Igen",
        "No": "Nem",
        "Ok": "Rendben",
        "Cancel": "Mégse",
        "Buy": "Vásárlás",
        "Sell": "Eladás",
        "Trade": "Kereskedés",
        "Help": "Segítség",
        "Quest": "Küldetés",
        "Gold": "Arany",
        "Gold Coin": "Aranyérme",
        "Player": "Játékos",
        "Monster": "Szörny",
        "Item": "Tárgy",
        "Spell": "Varázslat",
        "It is empty.": "Üres.",
        "You are dead.": "Meghaltál.",
        "Helmet": "Sisak",
        "Left Hand": "Bal kéz",
        "Right Hand": "Jobb kéz",
        "north": "észak",
        "south": "dél",
        "east": "kelet",
        "west": "nyugat",
    },
    "sv": {
        "Hello": "Hej",
        "Hello!": "Hej!",
        "Welcome": "Välkommen",
        "Goodbye": "Adjö",
        "Good bye.": "Adjö.",
        "Bye.": "Hejdå.",
        "Thank you": "Tack",
        "Yes": "Ja",
        "No": "Nej",
        "Ok": "Ok",
        "Cancel": "Avbryt",
        "Buy": "Köp",
        "Sell": "Sälj",
        "Trade": "Handel",
        "Help": "Hjälp",
        "Quest": "Uppdrag",
        "Gold": "Guld",
        "Player": "Spelare",
        "Monster": "Monster",
        "Item": "Föremål",
        "Spell": "Besvärjelse",
        "It is empty.": "Det är tomt.",
        "Helmet": "Hjälm",
        "north": "norr",
        "south": "söder",
        "east": "öster",
        "west": "väster",
    },
    "da": {
        "Hello": "Hej",
        "Hello!": "Hej!",
        "Welcome": "Velkommen",
        "Goodbye": "Farvel",
        "Good bye.": "Farvel.",
        "Bye.": "Hej hej.",
        "Thank you": "Tak",
        "Yes": "Ja",
        "No": "Nej",
        "Ok": "Ok",
        "Cancel": "Annuller",
        "Buy": "Køb",
        "Sell": "Sælg",
        "Trade": "Handel",
        "Help": "Hjælp",
        "Quest": "Opgave",
        "Gold": "Guld",
        "Player": "Spiller",
        "Monster": "Monster",
        "Item": "Genstand",
        "Spell": "Trylleformular",
        "It is empty.": "Det er tomt.",
        "Helmet": "Hjelm",
        "north": "nord",
        "south": "syd",
        "east": "øst",
        "west": "vest",
    },
    "no": {
        "Hello": "Hei",
        "Hello!": "Hei!",
        "Welcome": "Velkommen",
        "Goodbye": "Ha det",
        "Good bye.": "Ha det.",
        "Bye.": "Ha det.",
        "Thank you": "Takk",
        "Yes": "Ja",
        "No": "Nei",
        "Ok": "Ok",
        "Cancel": "Avbryt",
        "Buy": "Kjøp",
        "Sell": "Selg",
        "Trade": "Handel",
        "Help": "Hjelp",
        "Quest": "Oppdrag",
        "Gold": "Gull",
        "Player": "Spiller",
        "Monster": "Monster",
        "Item": "Gjenstand",
        "Spell": "Trylleformel",
        "It is empty.": "Det er tomt.",
        "Helmet": "Hjelm",
        "north": "nord",
        "south": "sør",
        "east": "øst",
        "west": "vest",
    },
    "fi": {
        "Hello": "Hei",
        "Hello!": "Hei!",
        "Welcome": "Tervetuloa",
        "Goodbye": "Näkemiin",
        "Good bye.": "Näkemiin.",
        "Bye.": "Hei hei.",
        "Thank you": "Kiitos",
        "Yes": "Kyllä",
        "No": "Ei",
        "Ok": "Ok",
        "Cancel": "Peruuta",
        "Buy": "Osta",
        "Sell": "Myy",
        "Trade": "Kauppa",
        "Help": "Apua",
        "Quest": "Tehtävä",
        "Gold": "Kulta",
        "Player": "Pelaaja",
        "Monster": "Hirviö",
        "Item": "Esine",
        "Spell": "Loitsu",
        "It is empty.": "Se on tyhjä.",
        "Helmet": "Kypärä",
        "north": "pohjoinen",
        "south": "etelä",
        "east": "itä",
        "west": "länsi",
    },
    "ro": {
        "Hello": "Bună",
        "Hello!": "Bună!",
        "Hi": "Salut",
        "Welcome": "Bine ai venit",
        "Welcome!": "Bine ai venit!",
        "Goodbye": "La revedere",
        "Good bye.": "La revedere.",
        "Bye.": "Pa.",
        "Farewell.": "Adio.",
        "Thank you": "Mulțumesc",
        "Yes": "Da",
        "No": "Nu",
        "Ok": "Bine",
        "Cancel": "Anulare",
        "Buy": "Cumpără",
        "Sell": "Vinde",
        "Trade": "Comerț",
        "Help": "Ajutor",
        "Quest": "Misiune",
        "Gold": "Aur",
        "Gold Coin": "Monedă de aur",
        "Player": "Jucător",
        "Monster": "Monstru",
        "Item": "Obiect",
        "Spell": "Vrajă",
        "It is empty.": "Este gol.",
        "Helmet": "Coif",
        "north": "nord",
        "south": "sud",
        "east": "est",
        "west": "vest",
    },
    "hr": {
        "Hello": "Bok",
        "Hello!": "Bok!",
        "Hi": "Bok",
        "Welcome": "Dobrodošli",
        "Welcome!": "Dobrodošli!",
        "Goodbye": "Doviđenja",
        "Good bye.": "Doviđenja.",
        "Bye.": "Bok.",
        "Farewell.": "Zbogom.",
        "Thank you": "Hvala",
        "Yes": "Da",
        "No": "Ne",
        "Ok": "U redu",
        "Cancel": "Otkaži",
        "Buy": "Kupi",
        "Sell": "Prodaj",
        "Trade": "Trgovina",
        "Help": "Pomoć",
        "Quest": "Zadatak",
        "Gold": "Zlato",
        "Gold Coin": "Zlatnik",
        "Player": "Igrač",
        "Monster": "Čudovište",
        "Item": "Predmet",
        "Spell": "Čarolija",
        "It is empty.": "Prazno je.",
        "Helmet": "Kaciga",
        "north": "sjever",
        "south": "jug",
        "east": "istok",
        "west": "zapad",
    },
    "sl": {
        "Hello": "Živjo",
        "Hello!": "Živjo!",
        "Welcome": "Dobrodošli",
        "Goodbye": "Nasvidenje",
        "Good bye.": "Nasvidenje.",
        "Bye.": "Adijo.",
        "Farewell.": "Zbogom.",
        "Thank you": "Hvala",
        "Yes": "Da",
        "No": "Ne",
        "Ok": "V redu",
        "Cancel": "Prekliči",
        "Buy": "Kupi",
        "Sell": "Prodaj",
        "Trade": "Trgovina",
        "Help": "Pomoč",
        "Quest": "Naloga",
        "Gold": "Zlato",
        "Player": "Igralec",
        "Monster": "Pošast",
        "Item": "Predmet",
        "Spell": "Urok",
        "It is empty.": "Prazno je.",
        "Helmet": "Čelada",
        "north": "sever",
        "south": "jug",
        "east": "vzhod",
        "west": "zahod",
    },
    "bg": {
        "Hello": "Здравей",
        "Hello!": "Здравей!",
        "Welcome": "Добре дошъл",
        "Goodbye": "Довиждане",
        "Good bye.": "Довиждане.",
        "Bye.": "Чао.",
        "Thank you": "Благодаря",
        "Yes": "Да",
        "No": "Не",
        "Ok": "Добре",
        "Cancel": "Отмяна",
        "Buy": "Купи",
        "Sell": "Продай",
        "Trade": "Търговия",
        "Help": "Помощ",
        "Quest": "Задача",
        "Gold": "Злато",
        "Player": "Играч",
        "Monster": "Чудовище",
        "Item": "Предмет",
        "Spell": "Магия",
        "It is empty.": "Празно е.",
        "Helmet": "Шлем",
        "north": "север",
        "south": "юг",
        "east": "изток",
        "west": "запад",
    },
    "el": {
        "Hello": "Γεια",
        "Hello!": "Γεια!",
        "Welcome": "Καλώς ήρθατε",
        "Goodbye": "Αντίο",
        "Good bye.": "Αντίο.",
        "Bye.": "Γεια.",
        "Thank you": "Ευχαριστώ",
        "Yes": "Ναι",
        "No": "Όχι",
        "Ok": "Εντάξει",
        "Cancel": "Ακύρωση",
        "Buy": "Αγορά",
        "Sell": "Πώληση",
        "Trade": "Εμπόριο",
        "Help": "Βοήθεια",
        "Quest": "Αποστολή",
        "Gold": "Χρυσός",
        "Player": "Παίκτης",
        "Monster": "Τέρας",
        "Item": "Αντικείμενο",
        "Spell": "Ξόρκι",
        "It is empty.": "Είναι άδειο.",
        "Helmet": "Κράνος",
        "north": "βορράς",
        "south": "νότος",
        "east": "ανατολή",
        "west": "δύση",
    },
    "lv": {
        "Hello": "Sveiki",
        "Hello!": "Sveiki!",
        "Welcome": "Laipni lūdzam",
        "Goodbye": "Ardievu",
        "Good bye.": "Ardievu.",
        "Bye.": "Čau.",
        "Thank you": "Paldies",
        "Yes": "Jā",
        "No": "Nē",
        "Ok": "Labi",
        "Cancel": "Atcelt",
        "Buy": "Pirkt",
        "Sell": "Pārdot",
        "Trade": "Tirdzniecība",
        "Help": "Palīdzība",
        "Quest": "Uzdevums",
        "Gold": "Zelts",
        "Player": "Spēlētājs",
        "Monster": "Briesmonis",
        "Item": "Priekšmets",
        "Spell": "Burvestība",
        "It is empty.": "Tas ir tukšs.",
        "Helmet": "Ķivere",
        "north": "ziemeļi",
        "south": "dienvidi",
        "east": "austrumi",
        "west": "rietumi",
    },
    "lt": {
        "Hello": "Sveiki",
        "Hello!": "Sveiki!",
        "Welcome": "Sveiki atvykę",
        "Goodbye": "Viso gero",
        "Good bye.": "Viso gero.",
        "Bye.": "Iki.",
        "Thank you": "Ačiū",
        "Yes": "Taip",
        "No": "Ne",
        "Ok": "Gerai",
        "Cancel": "Atšaukti",
        "Buy": "Pirkti",
        "Sell": "Parduoti",
        "Trade": "Prekyba",
        "Help": "Pagalba",
        "Quest": "Užduotis",
        "Gold": "Auksas",
        "Player": "Žaidėjas",
        "Monster": "Monstras",
        "Item": "Daiktas",
        "Spell": "Burtažodis",
        "It is empty.": "Tuščia.",
        "Helmet": "Šalmas",
        "north": "šiaurė",
        "south": "pietūs",
        "east": "rytai",
        "west": "vakarai",
    },
    "et": {
        "Hello": "Tere",
        "Hello!": "Tere!",
        "Welcome": "Tere tulemast",
        "Goodbye": "Head aega",
        "Good bye.": "Head aega.",
        "Bye.": "Nägemist.",
        "Thank you": "Tänan",
        "Yes": "Jah",
        "No": "Ei",
        "Ok": "Olgu",
        "Cancel": "Tühista",
        "Buy": "Osta",
        "Sell": "Müü",
        "Trade": "Kaubandus",
        "Help": "Abi",
        "Quest": "Ülesanne",
        "Gold": "Kuld",
        "Player": "Mängija",
        "Monster": "Koletis",
        "Item": "Ese",
        "Spell": "Loits",
        "It is empty.": "See on tühi.",
        "Helmet": "Kiiver",
        "north": "põhi",
        "south": "lõuna",
        "east": "ida",
        "west": "lääs",
    },
    "sq": {
        "Hello": "Përshëndetje",
        "Hello!": "Përshëndetje!",
        "Welcome": "Mirë se vini",
        "Goodbye": "Mirupafshim",
        "Good bye.": "Mirupafshim.",
        "Bye.": "Tung.",
        "Thank you": "Faleminderit",
        "Yes": "Po",
        "No": "Jo",
        "Ok": "Mirë",
        "Cancel": "Anulo",
        "Buy": "Bli",
        "Sell": "Shit",
        "Trade": "Tregti",
        "Help": "Ndihmë",
        "Quest": "Detyrë",
        "Gold": "Ar",
        "Player": "Lojtar",
        "Monster": "Përbindësh",
        "Item": "Objekt",
        "Spell": "Magji",
        "It is empty.": "Është bosh.",
        "Helmet": "Helmetë",
        "north": "veri",
        "south": "jug",
        "east": "lindje",
        "west": "perëndim",
    },
    "uk": {
        "Hello": "Привіт",
        "Hello!": "Привіт!",
        "Welcome": "Ласкаво просимо",
        "Goodbye": "До побачення",
        "Good bye.": "До побачення.",
        "Bye.": "Бувай.",
        "Thank you": "Дякую",
        "Yes": "Так",
        "No": "Ні",
        "Ok": "Гаразд",
        "Cancel": "Скасувати",
        "Buy": "Купити",
        "Sell": "Продати",
        "Trade": "Торгівля",
        "Help": "Допомога",
        "Quest": "Завдання",
        "Gold": "Золото",
        "Player": "Гравець",
        "Monster": "Монстр",
        "Item": "Предмет",
        "Spell": "Заклинання",
        "It is empty.": "Порожньо.",
        "Helmet": "Шолом",
        "north": "північ",
        "south": "південь",
        "east": "схід",
        "west": "захід",
    },
}

WORD_TRANSLATIONS = {
    "pl": {
        # Walka / Statystyki
        "attack": "atak",
        "defense": "obrona",
        "speed": "szybkość",
        "health": "zdrowie",
        "mana": "mana",
        "magic": "magia",
        "fire": "ogień",
        "ice": "lód",
        "earth": "ziemia",
        "energy": "energia",
        "holy": "świętość",
        "death": "śmierć",
        "physical": "fizyczny",
        "sword": "miecz",
        "axe": "topór",
        "club": "obuch",
        "distance": "dystans",
        "shield": "tarcza",
        "armor": "pancerz",
        "helmet": "hełm",
        "boots": "buty",
        "ring": "pierścień",
        "amulet": "amulet",
        "level": "poziom",
        "experience": "doświadczenie",
        "required": "wymagany",
        "weight": "waga",
        "charges": "ładunki",
        "duration": "czas trwania",
        "chance": "szansa",
        "bonus": "premia",
        # Typy stworzeń / przeciwników
        "dead": "martwy",
        "slain": "zabity",
        "corpse": "zwłoki",
        "skeleton": "szkielet",
        "zombie": "zombi",
        "ghost": "duch",
        "rat": "szczur",
        "wolf": "wilk",
        "bear": "niedźwiedź",
        "spider": "pająk",
        "troll": "trol",
        "orc": "ork",
        "dragon": "smok",
        "demon": "demon",
        "dwarf": "krasnolud",
        "elf": "elf",
        "goblin": "goblin",
        "giant": "olbrzym",
        "serpent": "wąż",
        "beast": "bestia",
        "creature": "stworzenie",
        "undead": "nieumarły",
        "vampire": "wampir",
        "witch": "wiedźma",
        "wizard": "czarodziej",
        "knight": "rycerz",
        "paladin": "paladyn",
        "sorcerer": "czarnoksiężnik",
        "druid": "druid",
        # Przedmioty / Materiały
        "gold": "złoto",
        "silver": "srebro",
        "iron": "żelazo",
        "steel": "stal",
        "wood": "drewno",
        "wooden": "drewniany",
        "stone": "kamień",
        "crystal": "kryształ",
        "gem": "klejnot",
        "diamond": "diament",
        "ruby": "rubin",
        "emerald": "szmaragd",
        "sapphire": "szafir",
        "potion": "mikstura",
        "scroll": "zwój",
        "rune": "runa",
        "key": "klucz",
        "door": "drzwi",
        "chest": "skrzynia",
        "bag": "torba",
        "box": "pudełko",
        "flask": "butelka",
        "vial": "fiolka",
        "rope": "lina",
        "torch": "pochodnia",
        "lamp": "lampa",
        "candle": "świeca",
        "coin": "moneta",
        "coins": "monety",
        # Otoczenie / Mapa
        "north": "północ",
        "south": "południe",
        "east": "wschód",
        "west": "zachód",
        "left": "lewo",
        "right": "prawo",
        "up": "góra",
        "down": "dół",
        "entrance": "wejście",
        "exit": "wyjście",
        "bridge": "most",
        "mountain": "góra",
        "forest": "las",
        "desert": "pustynia",
        "cave": "jaskinia",
        "dungeon": "loch",
        "temple": "świątynia",
        "tower": "wieża",
        "castle": "zamek",
        "house": "dom",
        "shop": "sklep",
        "bank": "bank",
        "depot": "depo",
        "island": "wyspa",
        "city": "miasto",
        "village": "wioska",
        "harbor": "port",
        "lake": "jezioro",
        "river": "rzeka",
        "sea": "morze",
        "ocean": "ocean",
        "swamp": "bagno",
        "floor": "podłoga",
        "wall": "ściana",
        "roof": "dach",
        "stairs": "schody",
        "hole": "dziura",
        "closed": "zamknięte",
        "open": "otwarte",
        "locked": "zamknięte na klucz",
        # Akcje / Czasowniki
        "buy": "kup",
        "sell": "sprzedaj",
        "trade": "handel",
        "look": "popatrz",
        "use": "użyj",
        "move": "przesuń",
        "take": "weź",
        "drop": "upuść",
        "eat": "zjedz",
        "drink": "wypij",
        "read": "czytaj",
        "write": "pisz",
        "open": "otwórz",
        "close": "zamknij",
        "push": "popchnij",
        "pull": "pociągnij",
        "throw": "rzuć",
        "cast": "rzuć",
        "heal": "lecz",
        "kill": "zabij",
        "fight": "walcz",
        "run": "biegnij",
        "walk": "idź",
        "stop": "stój",
        "wait": "czekaj",
        "rest": "odpocznij",
        "sleep": "śpij",
        "talk": "rozmawiaj",
        "say": "powiedz",
        "ask": "zapytaj",
        "answer": "odpowiedz",
        "search": "szukaj",
        "find": "znajdź",
        "hide": "ukryj",
        "show": "pokaż",
        "give": "daj",
        "receive": "otrzymaj",
        # Przymiotniki / Przysłówki
        "small": "mały",
        "big": "duży",
        "large": "duży",
        "huge": "ogromny",
        "tiny": "malutki",
        "old": "stary",
        "new": "nowy",
        "ancient": "starożytny",
        "dark": "ciemny",
        "light": "jasny",
        "bright": "jasny",
        "strong": "silny",
        "weak": "słaby",
        "fast": "szybki",
        "slow": "wolny",
        "hot": "gorący",
        "cold": "zimny",
        "warm": "ciepły",
        "empty": "pusty",
        "full": "pełny",
        "broken": "złamany",
        "enchanted": "zaczarowany",
        "magical": "magiczny",
        "cursed": "przeklęty",
        "blessed": "błogosławiony",
        "sacred": "święty",
        "royal": "królewski",
        "golden": "złoty",
        "unknown": "nieznany",
        "rare": "rzadki",
        "common": "zwykły",
        "special": "specjalny",
        "normal": "normalny",
        "simple": "prosty",
        # Ogólne / UI
        "yes": "tak",
        "no": "nie",
        "ok": "ok",
        "name": "nazwa",
        "error": "błąd",
        "warning": "ostrzeżenie",
        "success": "sukces",
        "failed": "nieudane",
        "loading": "ładowanie",
        "cancel": "anuluj",
        "confirm": "potwierdź",
        "delete": "usuń",
        "save": "zapisz",
        "load": "wczytaj",
        "status": "status",
        "description": "opis",
        "quest": "zadanie",
        "mission": "misja",
        "reward": "nagroda",
        "player": "gracz",
        "monster": "potwór",
        "item": "przedmiot",
        "spell": "zaklęcie",
        # Dodatkowe stworzenia / Tibia
        "ramp": "rampa",
        "bed": "łóżko",
        "skull": "czaszka",
        "book": "książka",
        "human": "człowiek",
        "statue": "posąg",
        "pillar": "filar",
        "werewolf": "wilkołak",
        "minotaur": "minotaur",
        "parchment": "pergamin",
        "strange": "dziwny",
        "snow": "śnieg",
        "dirt": "ziemia",
        "sand": "piasek",
        "grass": "trawa",
        "mud": "błoto",
        "water": "woda",
        "blood": "krew",
        "bone": "kość",
        "bones": "kości",
        "skull": "czaszka",
        "sign": "znak",
        "banner": "sztandar",
        "flag": "flaga",
        "throne": "tron",
        "altar": "ołtarz",
        "fountain": "fontanna",
        "grave": "grób",
        "tomb": "grobowiec",
        "coffin": "trumna",
        "shelf": "półka",
        "table": "stół",
        "chair": "krzesło",
        "barrel": "beczka",
        "crate": "skrzynia",
        "basket": "kosz",
        "flower": "kwiat",
        "plant": "roślina",
        "tree": "drzewo",
        "bush": "krzak",
        "mushroom": "grzyb",
        "fish": "ryba",
        "meat": "mięso",
        "bread": "chleb",
        "cheese": "ser",
        "apple": "jabłko",
        "cake": "ciasto",
        "wine": "wino",
        "beer": "piwo",
        "horn": "róg",
        "wing": "skrzydło",
        "claw": "pazur",
        "fang": "kieł",
        "tail": "ogon",
        "scale": "łuska",
        "skin": "skóra",
        "leather": "skóra",
        "cloth": "tkanina",
        "fur": "futro",
        "feather": "pióro",
        "shard": "odłamek",
        "piece": "kawałek",
        "fragment": "fragment",
        "remains": "szczątki",
        "powder": "proszek",
        "dust": "pył",
        "ashes": "popioły",
        "slime": "szlam",
        "web": "pajęczyna",
        "nest": "gniazdo",
        "lair": "legowisko",
        "den": "nora",
        "pit": "dół",
        "trap": "pułapka",
        "lever": "dźwignia",
        "switch": "przełącznik",
        "gate": "brama",
        "fence": "płot",
        "ladder": "drabina",
        "well": "studnia",
        "oven": "piec",
        "anvil": "kowadło",
        "loom": "krosno",
        "hammer": "młot",
        "pickaxe": "kilof",
        "shovel": "łopata",
        "saw": "piła",
        "nail": "gwóźdź",
        "chain": "łańcuch",
        "mirror": "lustro",
        "painting": "obraz",
        "carpet": "dywan",
        "curtain": "zasłona",
        "window": "okno",
        "balcony": "balkon",
        "armor": "pancerz",
        "weapon": "broń",
        "bow": "łuk",
        "arrow": "strzała",
        "crossbow": "kusza",
        "bolt": "bełt",
        "spear": "włócznia",
        "dagger": "sztylet",
        "wand": "różdżka",
        "staff": "kostur",
        "backpack": "plecak",
        "belt": "pas",
        "legs": "nogawice",
        "plate": "płyta",
        "mail": "kolczuga",
        "cap": "czapka",
        "hat": "kapelusz",
        "crown": "korona",
        "cloak": "peleryna",
        "cape": "peleryna",
        "gloves": "rękawice",
        "sandals": "sandały",
        "depot": "depo",
        "supply": "zaopatrzenie",
        "depot": "depo",
    },
    "tr": {
        # Savaş / İstatistikler
        "attack": "saldırı",
        "defense": "savunma",
        "speed": "hız",
        "health": "sağlık",
        "mana": "mana",
        "magic": "büyü",
        "fire": "ateş",
        "ice": "buz",
        "earth": "toprak",
        "energy": "enerji",
        "holy": "kutsal",
        "death": "ölüm",
        "physical": "fiziksel",
        "sword": "kılıç",
        "axe": "balta",
        "club": "topuz",
        "distance": "mesafe",
        "shield": "kalkan",
        "armor": "zırh",
        "helmet": "miğfer",
        "boots": "çizme",
        "ring": "yüzük",
        "amulet": "muska",
        "level": "seviye",
        "experience": "deneyim",
        "required": "gerekli",
        "weight": "ağırlık",
        "charges": "yük",
        "duration": "süre",
        "chance": "şans",
        "bonus": "bonus",
        # Yaratık türleri
        "dead": "ölü",
        "slain": "öldürülmüş",
        "corpse": "ceset",
        "skeleton": "iskelet",
        "zombie": "zombi",
        "ghost": "hayalet",
        "rat": "fare",
        "wolf": "kurt",
        "bear": "ayı",
        "spider": "örümcek",
        "troll": "trol",
        "orc": "ork",
        "dragon": "ejderha",
        "demon": "iblis",
        "dwarf": "cüce",
        "elf": "elf",
        "goblin": "goblin",
        "giant": "dev",
        "serpent": "yılan",
        "beast": "canavar",
        "creature": "yaratık",
        "undead": "yaşayan ölü",
        "vampire": "vampir",
        "witch": "cadı",
        "wizard": "büyücü",
        "knight": "şövalye",
        "paladin": "paladin",
        "sorcerer": "büyücü",
        "druid": "druid",
        # Eşyalar / Malzemeler
        "gold": "altın",
        "silver": "gümüş",
        "iron": "demir",
        "steel": "çelik",
        "wood": "odun",
        "wooden": "ahşap",
        "stone": "taş",
        "crystal": "kristal",
        "gem": "mücevher",
        "diamond": "elmas",
        "ruby": "yakut",
        "emerald": "zümrüt",
        "sapphire": "safir",
        "potion": "iksir",
        "scroll": "tomar",
        "rune": "rün",
        "key": "anahtar",
        "door": "kapı",
        "chest": "sandık",
        "bag": "çanta",
        "box": "kutu",
        "flask": "şişe",
        "vial": "flakon",
        "rope": "halat",
        "torch": "meşale",
        "lamp": "lamba",
        "candle": "mum",
        "coin": "sikke",
        "coins": "sikkeler",
        # Çevre / Harita
        "north": "kuzey",
        "south": "güney",
        "east": "doğu",
        "west": "batı",
        "left": "sol",
        "right": "sağ",
        "up": "yukarı",
        "down": "aşağı",
        "entrance": "giriş",
        "exit": "çıkış",
        "bridge": "köprü",
        "mountain": "dağ",
        "forest": "orman",
        "desert": "çöl",
        "cave": "mağara",
        "dungeon": "zindan",
        "temple": "tapınak",
        "tower": "kule",
        "castle": "kale",
        "house": "ev",
        "shop": "dükkan",
        "bank": "banka",
        "depot": "depo",
        "island": "ada",
        "city": "şehir",
        "village": "köy",
        "harbor": "liman",
        "lake": "göl",
        "river": "nehir",
        "sea": "deniz",
        "ocean": "okyanus",
        "swamp": "bataklık",
        "floor": "zemin",
        "wall": "duvar",
        "roof": "çatı",
        "stairs": "merdivenler",
        "hole": "delik",
        "closed": "kapalı",
        "open": "açık",
        "locked": "kilitli",
        # Eylemler
        "buy": "satın al",
        "sell": "sat",
        "trade": "takas",
        "look": "bak",
        "use": "kullan",
        "move": "taşı",
        "take": "al",
        "drop": "bırak",
        "eat": "ye",
        "drink": "iç",
        "read": "oku",
        "write": "yaz",
        "open": "aç",
        "close": "kapat",
        "push": "it",
        "pull": "çek",
        "throw": "at",
        "cast": "yap",
        "heal": "iyileştir",
        "kill": "öldür",
        "fight": "savaş",
        "run": "koş",
        "walk": "yürü",
        "stop": "dur",
        "wait": "bekle",
        "rest": "dinlen",
        "sleep": "uyu",
        "talk": "konuş",
        "say": "söyle",
        "ask": "sor",
        "answer": "cevapla",
        "search": "ara",
        "find": "bul",
        "hide": "saklan",
        "show": "göster",
        "give": "ver",
        "receive": "al",
        # Sıfatlar
        "small": "küçük",
        "big": "büyük",
        "large": "büyük",
        "huge": "devasa",
        "tiny": "minik",
        "old": "eski",
        "new": "yeni",
        "ancient": "antik",
        "dark": "karanlık",
        "light": "aydınlık",
        "bright": "parlak",
        "strong": "güçlü",
        "weak": "zayıf",
        "fast": "hızlı",
        "slow": "yavaş",
        "hot": "sıcak",
        "cold": "soğuk",
        "warm": "ılık",
        "empty": "boş",
        "full": "dolu",
        "broken": "kırık",
        "enchanted": "büyülü",
        "magical": "sihirli",
        "cursed": "lanetli",
        "blessed": "kutsanmış",
        "sacred": "kutsal",
        "royal": "kraliyet",
        "golden": "altın",
        "unknown": "bilinmeyen",
        "rare": "nadir",
        "common": "yaygın",
        "special": "özel",
        "normal": "normal",
        "simple": "basit",
        # Genel / UI
        "yes": "evet",
        "no": "hayır",
        "ok": "tamam",
        "name": "isim",
        "error": "hata",
        "warning": "uyarı",
        "success": "başarı",
        "failed": "başarısız",
        "loading": "yükleniyor",
        "cancel": "iptal",
        "confirm": "onayla",
        "delete": "sil",
        "save": "kaydet",
        "load": "yükle",
        "status": "durum",
        "description": "açıklama",
        "quest": "görev",
        "mission": "görev",
        "reward": "ödül",
        "player": "oyuncu",
        "monster": "canavar",
        "item": "eşya",
        "spell": "büyü",
        # Ek yaratıklar / Tibia
        "ramp": "rampa",
        "bed": "yatak",
        "skull": "kafatası",
        "book": "kitap",
        "human": "insan",
        "statue": "heykel",
        "pillar": "sütun",
        "werewolf": "kurtadam",
        "minotaur": "minotaur",
        "parchment": "parşömen",
        "strange": "tuhaf",
        "snow": "kar",
        "dirt": "toprak",
        "sand": "kum",
        "grass": "çimen",
        "mud": "çamur",
        "water": "su",
        "blood": "kan",
        "bone": "kemik",
        "bones": "kemikler",
        "sign": "tabela",
        "banner": "sancak",
        "flag": "bayrak",
        "throne": "taht",
        "altar": "sunak",
        "fountain": "çeşme",
        "grave": "mezar",
        "tomb": "türbe",
        "coffin": "tabut",
        "shelf": "raf",
        "table": "masa",
        "chair": "sandalye",
        "barrel": "fıçı",
        "crate": "sandık",
        "basket": "sepet",
        "flower": "çiçek",
        "plant": "bitki",
        "tree": "ağaç",
        "bush": "çalı",
        "mushroom": "mantar",
        "fish": "balık",
        "meat": "et",
        "bread": "ekmek",
        "cheese": "peynir",
        "apple": "elma",
        "cake": "pasta",
        "wine": "şarap",
        "beer": "bira",
        "horn": "boynuz",
        "wing": "kanat",
        "claw": "pençe",
        "fang": "diş",
        "tail": "kuyruk",
        "scale": "pul",
        "skin": "deri",
        "leather": "deri",
        "cloth": "kumaş",
        "fur": "kürk",
        "feather": "tüy",
        "shard": "parça",
        "piece": "parça",
        "fragment": "parça",
        "remains": "kalıntılar",
        "powder": "toz",
        "dust": "toz",
        "ashes": "küller",
        "slime": "balçık",
        "web": "ağ",
        "nest": "yuva",
        "lair": "in",
        "den": "in",
        "pit": "çukur",
        "trap": "tuzak",
        "lever": "kol",
        "switch": "düğme",
        "gate": "kapı",
        "fence": "çit",
        "ladder": "merdiven",
        "well": "kuyu",
        "oven": "fırın",
        "anvil": "örs",
        "loom": "tezgah",
        "hammer": "çekiç",
        "pickaxe": "kazma",
        "shovel": "kürek",
        "saw": "testere",
        "nail": "çivi",
        "chain": "zincir",
        "mirror": "ayna",
        "painting": "tablo",
        "carpet": "halı",
        "curtain": "perde",
        "window": "pencere",
        "balcony": "balkon",
        "weapon": "silah",
        "bow": "yay",
        "arrow": "ok",
        "crossbow": "tatar yayı",
        "bolt": "cıvata",
        "spear": "mızrak",
        "dagger": "hançer",
        "wand": "asa",
        "staff": "asa",
        "backpack": "sırt çantası",
        "belt": "kemer",
        "legs": "bacaklık",
        "plate": "plaka",
        "mail": "zırh",
        "cap": "şapka",
        "hat": "şapka",
        "crown": "taç",
        "cloak": "pelerin",
        "cape": "pelerin",
        "gloves": "eldiven",
        "sandals": "sandalet",
        "supply": "erzak",
    },
}

def _load_external_dict(path: str):
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}

EXT_SIMPLE_TRANSLATIONS = _load_external_dict(os.path.join(status_dir, "simple_translations.json"))
EXT_WORD_TRANSLATIONS = _load_external_dict(os.path.join(status_dir, "word_translations.json"))

def _merged_lang_dict(external_dict: dict, fallback_dict: dict, lang: str):
    merged = {}
    ext_lang = external_dict.get(lang, {}) if isinstance(external_dict.get(lang, {}), dict) else {}
    fb_lang = fallback_dict.get(lang, {}) if isinstance(fallback_dict.get(lang, {}), dict) else {}
    # Dla pilota jakości PL/ES nie pozwalamy, by zewnętrzny słownik nadpisywał
    # ręcznie kuratorowane wpisy bazowe (zostają tylko dodatkowe klucze).
    if str(lang or "").lower() in {"pl", "es"}:
        merged.update(ext_lang)
        merged.update(fb_lang)  # fallback ma priorytet
    else:
        merged.update(fb_lang)
        merged.update(ext_lang)  # external ma priorytet
    return merged

SIMPLE_TRANSLATIONS_ACTIVE = {
    lang: _merged_lang_dict(EXT_SIMPLE_TRANSLATIONS, SIMPLE_TRANSLATIONS, lang)
    for lang in set(list(SIMPLE_TRANSLATIONS.keys()) + list(EXT_SIMPLE_TRANSLATIONS.keys()))
}

WORD_TRANSLATIONS_ACTIVE = {
    lang: _merged_lang_dict(EXT_WORD_TRANSLATIONS, WORD_TRANSLATIONS, lang)
    for lang in set(list(WORD_TRANSLATIONS.keys()) + list(EXT_WORD_TRANSLATIONS.keys()))
}

def simple_translate(text, lang):
    """Zwraca tłumaczenie TYLKO gdy całe zdanie równa się wpisowi w słowniku."""
    translations = SIMPLE_TRANSLATIONS_ACTIVE.get(lang)
    if not translations:
        return None
    for en, translated in translations.items():
        if text.strip().lower() == en.lower():
            return translated
    return None

def _is_game_nontranslatable(key, en_value):
    """Heurystyka: tekst nieprzetłumaczalny specyficzny dla gry Tibia.
    Fikcyjne języki (orcki, smocze), odgłosy zwierząt, onomatopeje."""
    t = str(en_value or "").strip()
    if not t:
        return False
    # Odgłosy zwierząt / krzyki: GRRRR, YOOOO, ZzzZzz, ROAAAAR itp.
    _animal_patterns = ('GRRR', 'YOOO', 'ZZZZ', 'ROAR', 'HISS', 'SNARL', 'RAWR',
                        'HOWL', 'GROWL', 'SCREE', 'CLANK', 'BOOM')
    if any(p in t.upper() for p in _animal_patterns):
        return True
    # Fikcyjne frazy językowe Tibia (orcki, smocze, starożytne)
    _fictional_words = re.compile(
        r'\b(?:gort|utash|karek|booz|omark|ikem|goshak|torilu[nm]?|garnum|'
        r'saethelon|zathroth|uthun|nortat|urghh?|brakka|morda|chakka|'
        r'batuk|goshak|charach|galunda|mugrah|gorak|shakk|uurgh|'
        r'tanjil|lanar|kull|ogar|azarak)\b', re.IGNORECASE
    )
    if _fictional_words.search(t):
        return True
    # Tekst wyłącznie z nie-angielskich nonsensownych sylab (≥3 "słowa" ≤5 liter, brak znanych angielskich słów)
    words = re.findall(r'[A-Za-z]+', t)
    if len(words) >= 3:
        _common_en = {
            'a','i','an','am','as','at','be','by','do','go','he','if','in','is','it','me','my','no',
            'of','on','or','so','to','up','us','we','the','and','are','but','can','did','for','get',
            'got','had','has','her','him','his','how','its','let','may','new','nor','not','now','old',
            'one','our','out','own','put','ran','run','saw','say','set','she','sit','the','too','try',
            'two','use','was','way','who','why','win','won','yes','yet','you','all','any','ask','bad',
            'big','bit','boy','buy','cut','day','eat','end','far','few','fly','fun','god','hat','hit',
            'hot','job','key','lay','led','lie','lot','low','man','map','men','met','mix','nor','off',
            'oil','pay','per','red','rid','run','sad','sit','six','son','ten','top','war','wet','yet',
            'able','also','back','been','best','body','both','call','came','case','come','could','each',
            'even','fact','feel','find','first','from','gave','give','goes','gone','good','great',
            'hand','have','head','help','here','high','home','hope','into','just','keep','kind','knew',
            'know','last','left','life','like','line','live','long','look','lost','made','make','many',
            'mind','more','most','much','must','name','need','next','only','open','over','part','plan',
            'play','real','rest','room','said','same','seem','show','side','some','soon','stop','such',
            'sure','take','talk','tell','than','that','them','then','they','this','time','told','took',
            'turn','upon','very','walk','want','well','went','were','what','when','will','with','word',
            'work','year','your','about','after','again','being','below','bring','carry','cause',
            'close','could','doing','don','every','first','found','going','great','house','human',
            'large','later','leave','light','might','money','never','night','often','order','other',
            'place','point','right','shall','should','since','small','sorry','start','still','story',
            'study','thank','their','there','these','thing','think','those','three','today','under',
            'until','watch','water','where','which','while','world','would','write','young',
            'really','little','around','before','always','people','after','again','already',
        }
        en_count = sum(1 for w in words if w.lower() in _common_en)
        if en_count == 0 and all(len(w) <= 6 for w in words):
            return True
    # Czysta onomatopeja: powtórzenie tego samego wzorca liter 3+ razy (Hum hum hum, Clink clank clink)
    if re.match(r'^([A-Za-z]{2,8})[,.\s]+\1(?:[,.\s]+\1)*[.!?]*$', t, re.IGNORECASE):
        return True
    return False

def _is_proper_noun_key(key, en_value):
    """Klucz z nazwą własną — identyczna wartość = poprawne tłumaczenie."""
    pn_prefixes = ("item.", "monster.", "spell.", "mount.", "quest.", "raid.", "achievement.", "npc.", "book.otbm.")
    pn_suffixes = (".name", ".words", ".title", ".desc", ".announce")
    if any(key.startswith(p) for p in pn_prefixes) and any(key.endswith(s) for s in pn_suffixes):
        return True
    en_stripped = en_value.strip()
    if len(en_stripped) <= 3:
        return True
    # Game-specific nontranslatable content (fictional languages, animal sounds)
    if _is_game_nontranslatable(key, en_stripped):
        return True
    # Short text (1-4 words) starting with uppercase under proper-noun prefix = likely a name
    if any(key.startswith(p) for p in pn_prefixes):
        words = en_stripped.split()
        if len(words) <= 4 and words[0][0:1].isupper():
            return True
    # All-uppercase/digit strings (abbreviations, codes)
    if en_stripped and all(c.isupper() or c.isdigit() or c in ".-_/ " for c in en_stripped):
        return True
    return False

def is_untranslated_value(value, en_value, key=""):
    if value is None:
        return True
    txt = str(value)
    if txt.startswith("["):
        return True
    if txt.strip() == "":
        return True
    if txt == str(en_value):
        if _is_proper_noun_key(key, str(en_value)):
            return False
        return True
    return False

# Whitelist of REAL Tibia game commands that must be preserved literally in translations.
# Only these tokens trigger guard_command. Everything else in single quotes is normal text.
GAME_COMMANDS = {
    'hi', 'hello', 'bye', 'trade', 'job', 'task', 'mission', 'quest',
    'yes', 'no', 'name', 'offer', 'sell', 'buy', 'outfit', 'addon',
    'heal', 'bank', 'balance', 'deposit', 'withdraw', 'transfer',
    'bless', 'blessing', 'passage', 'travel', 'destination',
    'help', 'info', 'report', 'news', 'rumour', 'rumor',
    'key', 'door', 'boss', 'hunt', 'monster', 'spell',
    'join', 'leave', 'invite', 'kick', 'war', 'guild',
    'promotion', 'premium', 'reward', 'claim',
    'alana sio', 'exani hur', 'exani tera', 'exani mort',
    'utevo lux', 'utevo gran lux', 'utevo vis lux',
    'exura', 'exura gran', 'exura vita', 'exura sio',
    'exani hur up', 'exani hur down',
}
# Slash-command regex: excludes URLs (://...) and file paths (/a/b/...)
_SLASH_CMD_RE = re.compile(r"(?<![\w:/])/([a-zA-Z][\w-]*)")
_URL_RE = re.compile(r"https?://\S+")

def _extract_command_tokens(text: str):
    """Extract game command tokens from text.
    Pattern 1: ''double-quoted'' tokens — always treated as commands.
    Pattern 2: 'single-quoted' tokens — ONLY if they match GAME_COMMANDS whitelist.
    Pattern 3: /slash-commands like /heal, /cast — always treated as commands.
    """
    src = str(text or "")
    normalized = src.translate(str.maketrans({
        "’": "'",
        "‘": "'",
        "`": "'",
        "´": "'",
    }))
    tokens = set()

    # Pattern 1: ''double-quoted'' tokens — always treated as commands
    for m in re.finditer(r"''([^']+?)''", normalized):
        token = m.group(1).strip().lower()
        if token:
            tokens.add(token)

    # Pattern 2 (WHITELIST): 'single-quoted' — ONLY if token matches GAME_COMMANDS
    for m in re.finditer(r"(?<!['\w])'([^']+?)'(?!')", normalized):
        token = m.group(1).strip().lower()
        if token and token in GAME_COMMANDS:
            tokens.add(token)

    # Pattern 3: /slash-commands like /heal, /house-kick
    # Strip URLs first to avoid false positives from https://github.com etc.
    text_no_urls = _URL_RE.sub("", normalized)
    for m in _SLASH_CMD_RE.finditer(text_no_urls):
        full_token = "/" + m.group(1).strip().lower()
        # Skip if followed by / (file paths like /startup/tables/...)
        end_pos = m.end()
        if end_pos < len(text_no_urls) and text_no_urls[end_pos] == "/":
            continue
        tokens.add(full_token)

    return tokens
def _token_sets_fast(text: str):
    placeholders = set(re.findall(r'\{[^}]*\}', text or ""))
    commands = _extract_command_tokens(text)
    pipes = set(re.findall(r'\|[^|]+\|', text or ""))
    return placeholders, commands, pipes

def _candidate_shape_ok(en_text: str, candidate: str):
    src = str(en_text or "").strip()
    dst = str(candidate or "").strip()
    if not dst:
        return False

    en_ph, en_cmd, en_pipe = _token_sets_fast(src)
    tr_ph, tr_cmd, tr_pipe = _token_sets_fast(dst)
    if en_ph != tr_ph:
        return False
    if en_cmd and en_cmd != tr_cmd:
        return False
    if en_pipe != tr_pipe:
        return False

    en_words = re.findall(r"[^\W\d_]+", src, flags=re.UNICODE)
    tr_words = re.findall(r"[^\W\d_]+", dst, flags=re.UNICODE)
    if len(en_words) >= 2:
        min_words = max(1, len(en_words) // 2)
        if len(tr_words) < min_words:
            return False

    # Ochrona przed skróconymi tłumaczeniami jak "distance" → "I."
    # Ratio długości: tłumaczenie nie powinno być <30% ani >400% oryginału
    src_len = len(src)
    dst_len = len(dst)
    if src_len >= 4 and dst_len > 0:
        ratio = dst_len / src_len
        if ratio < 0.3 or ratio > 4.0:
            return False

    if len(src) >= 12:
        dst_has_latin = bool(re.search(r"[A-Za-zÀ-ÿ]", dst))
        if dst_has_latin and len(dst) < 6:
            return False
        if not dst_has_latin and len(dst) < 2:
            return False
    return True

def match_case(src_word: str, translated_word: str) -> str:
    if not translated_word:
        return translated_word
    if src_word.isupper():
        return translated_word.upper()
    if src_word.istitle():
        return translated_word[:1].upper() + translated_word[1:]
    return translated_word

def translate_words_for_simple_text(text: str, lang: str):
    # Sekcja 5.3: WORD_TRANSLATIONS only for latin-script languages
    lang_lc = lang.lower().replace("_", "-")
    group = LANG_SCRIPT_GROUP.get(lang_lc, "latin")
    if group != "latin":
        return None
    vocab = WORD_TRANSLATIONS_ACTIVE.get(lang, {})
    if not vocab:
        return None
    src = str(text or "")
    if re.search(r"\{[^}]*\}|\|[^|]+\||'[^']+'", src):
        return None
    words = re.findall(r"[A-Za-zÀ-ÿ]+", src)
    if len(words) == 0 or len(words) > 6:
        return None

    changed = False
    ok = True
    def repl(m):
        nonlocal changed, ok
        w = m.group(0)
        lw = w.lower()
        tw = vocab.get(lw)
        if tw is None:
            ok = False
            return w
        changed = True
        return match_case(w, tw)

    out = re.sub(r"[A-Za-zÀ-ÿ]+", repl, src)
    if not ok or not changed:
        return None
    return out

# Wczytaj EN jako źródło
en_file = f"{I18N_DIR}/en/{json_file}"
if not os.path.exists(en_file):
    print(f"Brak pliku źródłowego: {en_file}")
    print("__AUTO_RESULT__ translated=0 placeholders=0 guard_fail=0 guard_placeholder=0 guard_command=0 guard_pipe=0")
    exit(0)

with open(en_file) as f:
    en_data = json.load(f)

# Wczytaj lub utwórz plik docelowy
lang_file = f"{I18N_DIR}/{target_lang}/{json_file}"
if strict_mode and not os.path.exists(lang_file):
    print(f"⚠️ STRICT: Brak pliku docelowego {lang_file} - nie mogę dodać nowych kluczy")
    print("__AUTO_RESULT__ translated=0 placeholders=0 guard_fail=0 guard_placeholder=0 guard_command=0 guard_pipe=0 skipped_missing_file=1 skipped_missing_key=0 skipped_not_placeholder=0")
    exit(0)

os.makedirs(os.path.dirname(lang_file), exist_ok=True)

try:
    with open(lang_file) as f:
        lang_data = json.load(f)
except:
    lang_data = {}

# Pamięć tłumaczeń (TM) - per-język + metadata jakości
tm_dir = os.path.join(status_dir, "tm")
os.makedirs(tm_dir, exist_ok=True)
tm_path = os.path.join(tm_dir, f"{target_lang}.json")
legacy_tm_path = f"{I18N_DIR}/translation_memory.json"

tm_data = {}
try:
    with open(tm_path, "r", encoding="utf-8") as f:
        tm_data = json.load(f)
    if not isinstance(tm_data, dict):
        tm_data = {}
except Exception:
    tm_data = {}

if not tm_data and os.path.exists(legacy_tm_path):
    try:
        with open(legacy_tm_path, "r", encoding="utf-8") as f:
            legacy = json.load(f)
        if isinstance(legacy, dict) and isinstance(legacy.get(target_lang, {}), dict):
            tm_data = legacy.get(target_lang, {})
    except Exception:
        pass

normalized_tm = {}
for _k, _v in (tm_data.items() if isinstance(tm_data, dict) else []):
    if isinstance(_v, dict):
        normalized_tm[_k] = {
            "src_hash": str(_v.get("src_hash", "") or ""),
            "text": str(_v.get("text", "") or ""),
            "source": str(_v.get("source", "legacy") or "legacy"),
            "confidence": float(_v.get("confidence", 0.8) or 0.8),
            "verified": bool(_v.get("verified", False)),
            "updated_at": str(_v.get("updated_at", datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")) or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")),
        }
    elif isinstance(_v, str):
        normalized_tm[_k] = {
            "src_hash": "",
            "text": _v,
            "source": "legacy",
            "confidence": 0.8,
            "verified": False,
            "updated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        }
tm_data = normalized_tm

# Sanitize TM: usuń znane artefakty z istniejących danych TM
_tm_bad_keys = []
for _tk, _tv in tm_data.items():
    _t_text = str(_tv.get("text", "") or "").strip()
    if _t_text in ("I.", "I..", "Nie.", "Niene", "Tak.", "Ja.", ""):
        _tm_bad_keys.append(_tk)
    elif re.match(r'^\[([A-Z]{2}(?:_[A-Z]{2})?)\]\s*', _t_text):
        _tm_bad_keys.append(_tk)
for _tk in _tm_bad_keys:
    del tm_data[_tk]
if _tm_bad_keys:
    print(f"🧹 TM sanitizer: usunięto {len(_tm_bad_keys)} artefaktów z TM")

def tm_upsert(key: str, src_hash_value: str, text: str, source: str, confidence: float, verified: bool = False):
    # Quality gate: odrzuć śmieci zanim trafią do TM
    txt = str(text or "").strip()
    if not txt or len(txt) < 1:
        return  # pusty
    if txt in ("I.", "I..", "Nie.", "Niene", "Tak.", "Ja."):
        return  # znane artefakty GT
    if re.match(r'^\[([A-Z]{2}(?:_[A-Z]{2})?)\]\s*', txt):
        return  # placeholder [PL] xxx — nie zapisuj do TM
    tm_data[key] = {
        "src_hash": src_hash_value,
        "text": text,
        "source": source,
        "confidence": float(confidence),
        "verified": bool(verified),
        "updated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }

text_memory = {}
text_memory_lc = {}
text_memory_counts = {}
lang_dir = os.path.join(I18N_DIR, target_lang)
if os.path.isdir(lang_dir):
    for lf in os.listdir(lang_dir):
        if not lf.endswith('.json'):
            continue
        en_ref = os.path.join(I18N_DIR, 'en', lf)
        tr_ref = os.path.join(lang_dir, lf)
        if not os.path.exists(en_ref) or not os.path.exists(tr_ref):
            continue
        try:
            with open(en_ref, encoding='utf-8') as f:
                en_ref_data = json.load(f)
            with open(tr_ref, encoding='utf-8') as f:
                tr_ref_data = json.load(f)
        except Exception:
            continue
        for k, en_src in en_ref_data.items():
            if k not in tr_ref_data:
                continue
            tr_val = tr_ref_data.get(k)
            if is_untranslated_value(tr_val, en_src, k):
                continue
            en_src_s = str(en_src)
            tr_val_s = str(tr_val)
            # Quality gate: odrzuć artefakty z text_memory
            if tr_val_s in ("I.", "I..", "Nie.", "Niene", "Tak.", "Ja."):
                continue
            if len(en_src_s) >= 4 and len(tr_val_s) > 0:
                _tm_ratio = len(tr_val_s) / len(en_src_s)
                if _tm_ratio < 0.3 or _tm_ratio > 4.0:
                    continue
            if en_src_s and tr_val_s and _candidate_shape_ok(en_src_s, tr_val_s):
                bucket = text_memory_counts.setdefault(en_src_s, {})
                bucket[tr_val_s] = int(bucket.get(tr_val_s, 0) or 0) + 1

for en_src_s, variants in text_memory_counts.items():
    if not variants:
        continue
    best_val = sorted(
        variants.items(),
        key=lambda it: (int(it[1] or 0), len(str(it[0] or ""))),
        reverse=True,
    )[0][0]
    text_memory[en_src_s] = best_val
    text_memory_lc.setdefault(en_src_s.lower(), best_val)

def src_hash(text: str) -> str:
    return hashlib.md5(text.encode("utf-8")).hexdigest()

def count_placeholders(text: str):
    braces = re.findall(r'\{[^}]*\}', text)
    pipes = re.findall(r'\|[^|]+\|', text)
    return len(braces), len(pipes)

def token_sets(text: str):
    placeholders = set(re.findall(r'\{[^}]*\}', text or ""))
    commands = _extract_command_tokens(text)
    pipes = set(re.findall(r'\|[^|]+\|', text or ""))
    return placeholders, commands, pipes

# ── Faza 4: Auto-fix pass po tłumaczeniu ─────────────────────────────────────
# Normalizuje spacing, punctuation, capitalization —  BEZ zmiany znaczenia.
# Zwraca (fixed_text, list_of_fixes_applied).
_DOUBLE_SPACE_RE = re.compile(r'  +')
_TRAILING_SPACE_RE = re.compile(r' +\n')

def _auto_fix_translation(en_text: str, candidate: str, lang: str = ""):
    """Apply safe auto-fixes to a candidate translation.
    Returns (fixed_text, fixes_applied: list[str])."""
    fixes = []
    text = str(candidate)

    # F1: Trailing whitespace normalization
    stripped = text.rstrip()
    if stripped != text and not en_text.endswith(' '):
        text = stripped
        fixes.append("trailing_whitespace")

    # F2: Double spaces → single (unless EN has them)
    if '  ' in text and '  ' not in en_text:
        text = _DOUBLE_SPACE_RE.sub(' ', text)
        fixes.append("double_space")

    # F3: Trailing space before newline
    if ' \n' in text:
        text = _TRAILING_SPACE_RE.sub('\n', text)
        fixes.append("trailing_space_before_newline")

    # F4: Match EN leading/trailing punctuation
    # If EN ends with period and translation doesn't, add period
    en_s = str(en_text).strip()
    tr_s = text.strip()
    if en_s and tr_s:
        # Match trailing punctuation (. ! ? ... only)
        for punc in ['.', '!', '?']:
            if en_s.endswith(punc) and not tr_s.endswith(punc) and not tr_s.endswith('...'):
                # Don't add punctuation if translation ends with another valid punctuation
                if not tr_s[-1:] in '.!?…':
                    text = text.rstrip() + punc
                    fixes.append(f"trailing_punct_{punc}")
                    break

    # F5: Capitalize first letter to match EN (if EN starts uppercase)
    if en_s and en_s[0].isupper() and text and text[0].islower():
        # Don't capitalize if it's a special token like {placeholder}
        if not text.startswith('{') and not text.startswith('|') and not text.startswith("'"):
            text = text[0].upper() + text[1:]
            fixes.append("capitalize_first")

    # F6: Preserve EN leading/trailing newlines
    if en_text.startswith('\n') and not text.startswith('\n'):
        text = '\n' + text
        fixes.append("leading_newline")
    if en_text.endswith('\n') and not text.endswith('\n'):
        text = text + '\n'
        fixes.append("trailing_newline")

    return text, fixes

# ── Faza 4 / Section 12.5: Post-translation validation ──────────────────────
# Re-runs validate_key() + validate_candidate() AFTER auto-fix.
# Returns (is_ok, issues_list, fixed_text).
def _post_translation_validate(en_text: str, candidate: str, lang: str, key: str):
    """Full post-translation validation gate.
    1. Apply auto-fix
    2. Re-validate candidate (placeholder/command/pipe)
    3. Run validate_key() for V1-V7 checks
    Returns (ok: bool, fixed: str, fixes: list, issues: list)."""
    # Step 1: auto-fix
    fixed, fixes = _auto_fix_translation(en_text, candidate, lang)

    # Step 2: validate_candidate (hard gate on tokens)
    ok, reason = validate_candidate(en_text, fixed)
    if not ok:
        return False, fixed, fixes, [{"type": f"post_validate_{reason}", "severity": "CRITICAL"}]

    # Step 3: validate_key V1-V7
    issues = validate_key(en_text, fixed, lang, key)
    critical = [i for i in issues if i.get("severity") == "CRITICAL"]
    if critical:
        return False, fixed, fixes, issues

    return True, fixed, fixes, issues

def validate_candidate(en_text: str, candidate: str):
    if not candidate:
        return False, "empty"

    en_ph, en_cmd, en_pipe = token_sets(en_text)
    tr_ph, tr_cmd, tr_pipe = token_sets(candidate)
    if en_ph != tr_ph:
        return False, "placeholder"
    if en_cmd and en_cmd != tr_cmd:
        return False, "command"
    if en_pipe != tr_pipe:
        return False, "pipe"

    if not _candidate_shape_ok(en_text, candidate):
        return False, "quality"

    return True, "ok"

def _append_jsonl(path: str, entry: dict):
    try:
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass

def _enqueue_manual_review(status_dir: str, item: dict):
    queue_path = os.path.join(status_dir, "manual_review_queue.json")
    payload = {
        "queue": [],
        "stats": {"total": 0, "reviewed": 0, "approved": 0, "rejected": 0, "applied": 0},
        "updated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }
    try:
        if os.path.exists(queue_path):
            with open(queue_path, "r", encoding="utf-8") as f:
                cur = json.load(f)
            if isinstance(cur, dict):
                payload.update(cur)
    except Exception:
        pass

    queue = payload.get("queue", []) if isinstance(payload.get("queue", []), list) else []
    stats = payload.get("stats", {}) if isinstance(payload.get("stats", {}), dict) else {}

    dedupe_id = f"{item.get('lang','')}::{item.get('json_file','')}::{item.get('key','')}"
    already = False
    for q in queue:
        if not isinstance(q, dict):
            continue
        qid = f"{q.get('lang','')}::{q.get('json_file','')}::{q.get('key','')}"
        if qid == dedupe_id and not q.get("applied"):
            already = True
            break

    if not already:
        queue.append(item)
        stats["total"] = int(stats.get("total", 0) or 0) + 1

    payload["queue"] = queue
    payload["stats"] = stats
    payload["updated_at"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    try:
        tmp = queue_path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)
        os.replace(tmp, queue_path)
    except Exception:
        pass

def _max_severity(issues):
    order = {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4}
    best = "LOW"
    best_rank = 1
    for issue in issues or []:
        sev = str(issue.get("severity", "LOW") or "LOW").upper()
        rank = order.get(sev, 1)
        if rank > best_rank:
            best_rank = rank
            best = sev
    return best

def _contains_mixed_scripts(text: str):
    has_latin = bool(re.search(r"[A-Za-z]", text or ""))
    has_cyr = bool(re.search(r"[\u0400-\u04FF]", text or ""))
    has_ar = bool(re.search(r"[\u0600-\u06FF]", text or ""))
    has_cjk = bool(re.search(r"[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF]", text or ""))
    groups = int(has_latin) + int(has_cyr) + int(has_ar) + int(has_cjk)
    return groups >= 2

def _has_issue_type(issues, issue_type: str) -> bool:
    issue_type = str(issue_type or "").strip().lower()
    if not issue_type:
        return False
    for issue in issues or []:
        if str(issue.get("type", "")).strip().lower() == issue_type:
            return True
    return False

def _is_probably_nontranslatable_text(text: str) -> bool:
    t = str(text or "").strip()
    if not t:
        return True
    # URLs i template markup zwykle powinny zostać bez zmian.
    if re.search(r"https?://|www\.", t, re.IGNORECASE):
        return True
    if "{{" in t or "}}" in t or "{%" in t or "%}" in t:
        return True
    # Ścieżki plików / startup skrypty / include-like tokens.
    if re.search(r"(?:^|\s)/(?:[A-Za-z0-9_.-]+/){1,}[A-Za-z0-9_.-]+", t):
        return True
    # Template concatenation / kodowe fragmenty twig/lua/php.
    if "~" in t and re.search(r"[A-Za-z_]", t):
        return True
    # Ujęte w nawiasy ostre adnotacje i emotes: <gasp>, <click>, <...>.
    if re.fullmatch(r"<[^<>]+>", t):
        return True
    # Tokeny techniczne (css classes, identifiers, keys, env names).
    tokens = [tok for tok in re.split(r"\s+", t) if tok]
    if tokens and all(re.fullmatch(r"[A-Za-z0-9_.:-]+", tok) for tok in tokens):
        if any(("/" in tok) or ("_" in tok) or ("-" in tok) or re.search(r"\d", tok) for tok in tokens):
            return True
        if len(tokens) == 1 and "." in tokens[0]:
            return True
    # Czyste symbole / cyfry / placeholdery.
    cleaned = re.sub(r'__PH\d+__|[{}\[\]|%$0-9\s_\-:;.,!?/\\()<>\"\'`~+=*&^#@]', '', t)
    if not cleaned:
        return True
    # Jednowyrazowe onomatopeje i krzyki typu BOOOM!
    words = [w for w in re.findall(r"[A-Za-zÀ-ÖØ-öø-ÿ]{2,}", t)]
    if len(words) <= 1 and t.upper() == t and len(t) <= 20:
        return True
    return False

def detect_suspicious(en_text: str, translated_text: str, lang: str, key: str = ""):
    en = str(en_text or "")
    tr = str(translated_text or "")
    issues = []

    en_ph, en_cmd, en_pipe = token_sets(en)
    tr_ph, tr_cmd, tr_pipe = token_sets(tr)

    # S1: Placeholder mismatch
    if en_ph != tr_ph or (en_cmd and en_cmd != tr_cmd) or en_pipe != tr_pipe:
        issues.append({
            "type": "placeholder_mismatch",
            "severity": "CRITICAL",
            "message": "Tokeny placeholder/command/pipe nie zgadzają się z EN",
        })

    en_len = len(en.strip())
    tr_len = len(tr.strip())
    ratio = (tr_len / en_len) if en_len > 0 else 1.0

    # S2: Extreme length ratio
    if en_len >= 5 and (ratio < 0.3 or ratio > 4.0):
        issues.append({
            "type": "length_extreme_ratio",
            "severity": "HIGH",
            "ratio": round(ratio, 3),
            "message": "Ekstremalna proporcja długości tłumaczenia",
        })

    # S3: Identical to EN (z wykluczeniem nazw własnych)
    if tr == en and not _is_proper_noun_key(key, en) and (en not in TIBIA_PROPER_NOUNS):
        lang_lc = str(lang or "").lower()
        if lang_lc in {"pl", "es"}:
            # Dla PL/ES wymuszamy realne tłumaczenie: EN-copy tylko gdy tekst
            # jest technicznie nieprzetłumaczalny.
            if _is_probably_nontranslatable_text(en):
                pass
            else:
                issues.append({
                    "type": "identical_to_en",
                    "severity": "CRITICAL",
                    "message": "Tłumaczenie identyczne z EN",
                })
        else:
            # Skip short single-word/phrase texts (likely names/terms/labels that don't change)
            en_words = [w.rstrip(":,.!?") for w in en.strip().split() if w.rstrip(":,.!?")]
            if len(en_words) <= 3 and all(w[0:1].isupper() for w in en_words if w):
                pass  # Short capitalized phrase — likely a proper name or label
            elif len(en.strip()) <= 20 and not any(c.islower() for c in en.strip()[:1]):
                pass  # Short text starting with uppercase — likely a label
            else:
                issues.append({
                    "type": "identical_to_en",
                    "severity": "MEDIUM",
                    "message": "Tłumaczenie identyczne z EN",
                })

    # Trudne termy gry: niekoniecznie błąd, ale sygnał do manual review
    if TIBIA_PROPER_NOUNS and any(term in en for term in TIBIA_PROPER_NOUNS):
        issues.append({
            "type": "contains_tibia_proper_noun",
            "severity": "LOW",
            "message": "Tekst zawiera nazwę własną Tibia",
        })

    # S4: Mixed scripts (heurystyka dla części języków)
    non_latin_langs = {"ar", "he", "ru", "uk", "bg", "mk", "sr", "ja", "zh", "zh_tw", "zh-cn", "zh-tw", "ko"}
    if str(lang or "").lower() in non_latin_langs and _contains_mixed_scripts(tr):
        issues.append({
            "type": "mixed_scripts",
            "severity": "HIGH",
            "message": "Wykryto mieszane skrypty Unicode",
        })

    # S6: Artifacts
    if re.search(r"\?\?\?|\[[A-Z]{2,}(?:[-_][A-Z]{2,})?\]|TODO|FIXME", tr):
        issues.append({
            "type": "artifact_tokens",
            "severity": "HIGH",
            "message": "Wykryto artefakty typu TODO/[LANG]/???",
        })

    # S8: Exploded translation size
    if en_len > 0 and en_len < 50 and tr_len > 500:
        issues.append({
            "type": "exploded_length",
            "severity": "MEDIUM",
            "ratio": round(ratio, 3),
            "message": "Tłumaczenie nadmiernie długie względem EN",
        })

    # S9: repeated word 3+
    if re.search(r"\b(\w+)\b(?:\s+\1\b){2,}", tr.lower()):
        issues.append({
            "type": "word_repetition",
            "severity": "HIGH",
            "message": "Powtórzony wyraz 3+ razy",
        })

    # S5: Cross-language duplicate hint (same translation in many langs = probably untranslated EN copy)
    # Note: Full cross-lang analysis is in run_quality_audit (batch). Here we flag obvious cases.
    if tr == en and en_len > 10 and not _is_proper_noun_key(key, en):
        # Already covered by S3 "identical_to_en" above, but S5 adds context for audit
        pass  # Handled by S3 + audit cross-referencing

    # S7: Capitalization mismatch (EN starts uppercase, LANG doesn't — script-dependent)
    latin_langs = {
        "az", "bs", "cs", "da", "de", "es", "et", "fi", "fr", "ga", "gl", "hr", "hu",
        "id", "it", "lt", "lv", "ms", "mt", "nl", "no", "pl", "pt", "ro", "sk", "sl",
        "sq", "sv", "sw", "tl", "tr", "vi", "cy",
    }
    if str(lang or "").lower() in latin_langs and en_len > 3 and tr_len > 1:
        en_first = en.lstrip()[:1] if en.strip() else ""
        tr_first = tr.lstrip()[:1] if tr.strip() else ""
        if en_first.isupper() and tr_first.isalpha() and tr_first.islower():
            # Skip if EN is a single word (might be intentional lowercase in LANG)
            if " " in en.strip() or en_len > 15:
                issues.append({
                    "type": "capitalization_mismatch",
                    "severity": "LOW",
                    "message": "EN zaczyna wielką literą, tłumaczenie małą",
                })

    # S10: Incomplete sentence (EN ends with punctuation, LANG doesn't)
    if en_len > 10 and tr_len > 5:
        en_stripped = en.rstrip()
        tr_stripped = tr.rstrip()
        en_end = en_stripped[-1] if en_stripped else ""
        tr_end = tr_stripped[-1] if tr_stripped else ""
        # EN ends with sentence punctuation
        if en_end in ".!?。！？":
            # LANG should also end with some punctuation (any script)
            if tr_end.isalnum():
                issues.append({
                    "type": "incomplete_sentence",
                    "severity": "LOW",
                    "message": f"EN kończy się '{en_end}', tłumaczenie nie ma znaku końca zdania",
                })

    # S11: Mixed-language detection for Latin-script (np. "Handel mógł Niet być completed.")
    # Sprawdź czy tłumaczenie zawiera zbyt wiele nienaruszonych angielskich słów
    if str(lang or "").lower() in latin_langs and en_len > 15 and tr != en:
        en_words_set = set(w.lower() for w in re.findall(r"[a-zA-Z]{3,}", en))
        tr_words_list = re.findall(r"[a-zA-Z]{3,}", tr)
        if len(tr_words_list) >= 3 and en_words_set:
            # Ile słów z tłumaczenia jest identycznych z EN (poza nazwami własnymi)
            en_kept = sum(1 for w in tr_words_list if w.lower() in en_words_set and not w[0:1].isupper())
            en_kept_ratio = en_kept / len(tr_words_list) if tr_words_list else 0
            if en_kept_ratio > 0.6:
                issues.append({
                    "type": "mixed_language",
                    "severity": "HIGH",
                    "message": f"Tłumaczenie zawiera {int(en_kept_ratio*100)}% nieprzetłumaczonych angielskich słów",
                    "en_kept_ratio": round(en_kept_ratio, 3),
                })

    # S12: Diacritics missing — długi tekst bez oczekiwanych diakrytyków dla danego języka
    EXPECTED_DIACRITICS = {
        "pl": r"[ąćęłńóśźż]",
        "cs": r"[áčďéěíňóřšťúůýž]",
        "sk": r"[áäčďéíľĺňóôŕšťúýž]",
        "hu": r"[áéíóöőúüű]",
        "ro": r"[ăâîșț]",
        "hr": r"[čćđšž]",
        "sl": r"[čšž]",
        "lv": r"[āčēģīķļņšūž]",
        "lt": r"[ąčęėįšųūž]",
        "fr": r"[àâæçéèêëîïôûùüÿœ]",
        "es": r"[áéíóúñü]",
        "pt": r"[ãáàâçéêíóôõúü]",
        "de": r"[äöüß]",
        "tr": r"[çğıöşü]",
        "sv": r"[åäö]",
        "da": r"[æøå]",
        "no": r"[æøå]",
        "fi": r"[äö]",
        "et": r"[äöüõ]",
    }
    lang_lower = str(lang or "").lower()
    diac_pattern = EXPECTED_DIACRITICS.get(lang_lower)
    if diac_pattern and tr_len > 80 and tr != en:
        if not re.search(diac_pattern, tr, re.IGNORECASE):
            issues.append({
                "type": "diacritics_missing",
                "severity": "LOW",
                "message": f"Tekst >{tr_len} znaków bez oczekiwanych diakrytyków dla {lang_lower}",
            })

    return issues

# ==========================================================================
# WALIDACJA PER-JĘZYK — walidatory specyficzne per pismo/grupa (6.1–6.2)
# ==========================================================================

# Mapowanie języków → grupy pism
LANG_SCRIPT_GROUP = {
    # Grupa A: Latin
    "az": "latin", "bs": "latin", "cs": "latin", "cy": "latin", "da": "latin",
    "de": "latin", "en": "latin", "es": "latin", "et": "latin", "fi": "latin",
    "fr": "latin", "ga": "latin", "gl": "latin", "hr": "latin", "hu": "latin",
    "id": "latin", "it": "latin", "lt": "latin", "lv": "latin", "ms": "latin",
    "mt": "latin", "nl": "latin", "no": "latin", "pl": "latin", "pt": "latin",
    "pt-br": "latin", "ro": "latin", "sk": "latin", "sl": "latin", "sq": "latin",
    "sv": "latin", "sw": "latin", "tl": "latin", "tr": "latin", "vi": "latin",
    # Grupa B: Cyrillic
    "bg": "cyrillic", "mk": "cyrillic", "ru": "cyrillic", "sr": "cyrillic", "uk": "cyrillic",
    # Grupa C: CJK
    "ja": "cjk", "ko": "cjk", "zh": "cjk", "zh-cn": "cjk", "zh-tw": "cjk", "zh_tw": "cjk",
    # Grupa D: RTL (Right-to-Left)
    "ar": "rtl", "he": "rtl",
    # Grupa E: Exotic scripts
    "bn": "exotic", "el": "exotic", "hi": "exotic", "hy": "exotic", "ka": "exotic",
    "ml": "exotic", "ta": "exotic", "te": "exotic", "th": "exotic",
}

# Oczekiwane pisma dla języków egzotycznych (unicodedata.name)
EXPECTED_SCRIPTS = {
    "bn": "BENGALI",
    "el": "GREEK",
    "hi": "DEVANAGARI",
    "hy": "ARMENIAN",
    "ka": "GEORGIAN",
    "ml": "MALAYALAM",
    "ta": "TAMIL",
    "te": "TELUGU",
    "th": "THAI",
}

def validate_per_lang(en_text: str, translated_text: str, lang: str, key: str = ""):
    """
    Walidacja specyficzna per-język/pismo.
    Zwraca listę issue dicts (jak detect_suspicious).
    V1-V5,V7 są już w validate_candidate/detect_suspicious.
    Tu dodajemy: V6 (newline), script-specific checks.
    """
    import unicodedata as _ud
    en = str(en_text or "")
    tr = str(translated_text or "")
    lang_lc = str(lang or "").lower().replace("_", "-")
    issues = []

    # V6: Newline count check — EN i LANG powinny mieć tyle samo \n
    en_nl = en.count("\\n") + en.count("\n")
    tr_nl = tr.count("\\n") + tr.count("\n")
    if en_nl != tr_nl and en_nl > 0:
        issues.append({
            "type": "newline_mismatch",
            "severity": "MEDIUM",
            "message": f"EN ma {en_nl} newline(s), tłumaczenie ma {tr_nl}",
        })

    group = LANG_SCRIPT_GROUP.get(lang_lc, "latin")

    # === Grupa B: Cyrillic script check ===
    if group == "cyrillic":
        # Odfiltruj tokeny ochronne i placeholder'y
        clean = re.sub(r'__PH\d+__|[{}\d|%]', '', tr)
        if len(clean) > 5:
            latin_count = sum(1 for c in clean if c.isalpha() and ord(c) < 0x0400)
            total_alpha = sum(1 for c in clean if c.isalpha())
            if total_alpha > 3:
                latin_ratio = latin_count / total_alpha
                if latin_ratio > 0.3:
                    issues.append({
                        "type": "cyrillic_latin_mix",
                        "severity": "HIGH",
                        "ratio": round(latin_ratio, 3),
                        "message": f"Język cyrylicowy ma {latin_ratio:.0%} łacińskich liter",
                    })

    # === Grupa C: CJK ratio check ===
    elif group == "cjk":
        en_len = len(en.strip())
        tr_len = len(tr.strip())
        if en_len > 3:
            ratio = tr_len / en_len
            # CJK text is typically 30-80% of EN length in characters
            if ratio < 0.15 or ratio > 2.5:
                issues.append({
                    "type": "cjk_ratio_anomaly",
                    "severity": "MEDIUM",
                    "ratio": round(ratio, 3),
                    "message": f"CJK ratio {ratio:.2f} poza zakresem 0.15–2.5",
                })

    # === Grupa D: RTL direction check ===
    elif group == "rtl":
        clean = re.sub(r'__PH\d+__|[{}\d|%\s]', '', tr)
        if len(clean) > 5:
            rtl_count = sum(
                1 for c in clean
                if _ud.bidirectional(c) in ('R', 'AL', 'AN')
            )
            total_vis = len(clean)
            if total_vis > 3:
                rtl_ratio = rtl_count / total_vis
                if rtl_ratio < 0.3:
                    issues.append({
                        "type": "rtl_insufficient",
                        "severity": "HIGH",
                        "ratio": round(rtl_ratio, 3),
                        "message": f"Język RTL ma tylko {rtl_ratio:.0%} znaków RTL",
                    })

    # === Grupa E: Exotic script consistency ===
    elif group == "exotic":
        expected_script = EXPECTED_SCRIPTS.get(lang_lc)
        if expected_script:
            clean = re.sub(r'__PH\d+__|[{}\d|%\s]', '', tr)
            total_alpha = sum(1 for c in clean if c.isalpha())
            if total_alpha > 5:
                correct_script = sum(
                    1 for c in clean
                    if c.isalpha() and expected_script in _ud.name(c, '')
                )
                script_ratio = correct_script / total_alpha
                if script_ratio < 0.4:
                    issues.append({
                        "type": "wrong_script",
                        "severity": "HIGH",
                        "expected_script": expected_script,
                        "ratio": round(script_ratio, 3),
                        "message": f"Oczekiwane pismo {expected_script}, znaleziono tylko {script_ratio:.0%}",
                    })

    return issues

# Przetwórz klucze
translated = 0
placeholders = 0
guard_fail = 0
guard_placeholder = 0
guard_command = 0
guard_pipe = 0
guard_quality = 0
skipped_missing_file = 0
skipped_missing_key = 0
skipped_not_placeholder = 0
suspicious_existing = 0
sanitized_existing = 0
tm_updates = 0
suspicious_detected = 0
suspicious_rejected = 0
suspicious_high = 0
recent_translations = []
gt_pending = []  # Klucze do tłumaczenia przez Google Translate
suspicious_log_path = os.path.join(status_dir, "suspicious_log.jsonl")
suspicious_rejected_path = os.path.join(status_dir, "suspicious_rejected.jsonl")
for key, en_text in en_data.items():
    # Sprawdź limit tłumaczeń
    if translate_limit > 0 and translated >= translate_limit:
        print(f"⚠️ Osiągnięto limit {translate_limit} tłumaczeń")
        break
        
    if strict_mode and key not in lang_data:
        skipped_missing_key += 1
        continue

    suspicious_existing_current = False

    if key in lang_data:
        current_value = str(lang_data.get(key, ""))
        # W strict tłumaczymy tylko placeholdery / TODO / wartości równe EN
        if strict_mode:
            if current_value == en_text and _is_proper_noun_key(key, en_text):
                skipped_not_placeholder += 1  # Nazwa własna — identyczna = OK
                continue
            if not (current_value.startswith("[") or current_value.startswith("[TODO]") or current_value == en_text):
                ok_current, _ = validate_candidate(en_text, current_value)
                if ok_current:
                    skipped_not_placeholder += 1
                    continue
                suspicious_existing += 1
                suspicious_existing_current = True
        else:
            if not current_value.startswith("["):
                continue  # Już przetłumaczone
    
    # TM lookup: użyj zapamiętanego tłumaczenia jeśli hash źródła pasuje
    h = src_hash(en_text)
    saved = tm_data.get(key)
    if saved and saved.get("src_hash") == h:
        candidate = saved.get("text", "")
        # ── Faza 4: Auto-fix pass na TM candidate ──────────────────────
        candidate, _af_fixes = _auto_fix_translation(en_text, candidate, target_lang)
        ok, reason = validate_candidate(en_text, candidate)
        if ok:
            issues = detect_suspicious(en_text, candidate, target_lang, key)
            issues.extend(validate_per_lang(en_text, candidate, target_lang, key))
            max_sev = _max_severity(issues)
            if issues:
                # Only count MEDIUM+ issues as truly suspicious (LOW = informational)
                if max_sev != "LOW":
                    suspicious_detected += 1
                if max_sev in ("HIGH", "CRITICAL"):
                    suspicious_high += 1
                log_entry = {
                    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                    "lang": target_lang,
                    "category": json_file,
                    "key": key,
                    "source": "tm",
                    "severity": max_sev,
                    "issues": issues,
                    "en": str(en_text),
                    "translated": str(candidate),
                }
                if len(issues) > 3:
                    suspicious_rejected += 1
                    _append_jsonl(suspicious_rejected_path, log_entry)
                    _enqueue_manual_review(status_dir, {
                        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                        "status": "pending",
                        "lang": target_lang,
                        "json_file": json_file,
                        "key": key,
                        "reason": "more_than_3_suspicious_flags",
                        "en_text": str(en_text),
                        "attempted_translation": str(candidate),
                        "issues": issues,
                        "source": "tm",
                    })
                    guard_fail += 1
                    guard_quality += 1
                    if strict_mode:
                        if suspicious_existing_current:
                            lang_data[key] = str(en_text)
                            sanitized_existing += 1
                        skipped_not_placeholder += 1
                    else:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    continue
                if max_sev == "CRITICAL":
                    if _has_issue_type(issues, "identical_to_en") and use_google_translate:
                        # TM dał EN-copy dla PL/ES — spróbuj realnego tłumaczenia przez GT.
                        gt_pending.append((key, en_text, h, suspicious_existing_current))
                        _append_jsonl(suspicious_log_path, {
                            "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                            "lang": target_lang,
                            "category": json_file,
                            "key": key,
                            "source": "tm",
                            "severity": "CRITICAL",
                            "issues": issues,
                            "action": "fallback_to_google_translate",
                            "en": str(en_text),
                            "translated": str(candidate),
                        })
                        continue
                    suspicious_rejected += 1
                    _append_jsonl(suspicious_rejected_path, log_entry)
                    guard_fail += 1
                    guard_quality += 1
                    if strict_mode:
                        if suspicious_existing_current:
                            lang_data[key] = str(en_text)
                            sanitized_existing += 1
                        skipped_not_placeholder += 1
                    else:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    continue
                _append_jsonl(suspicious_log_path, log_entry)
            lang_data[key] = candidate
            translated += 1
            recent_translations.append({
                "key": key,
                "en": en_text,
                "translated": candidate,
                "source": "tm",
            })
            continue
        guard_fail += 1
        if reason == "placeholder":
            guard_placeholder += 1
        elif reason == "command":
            guard_command += 1
        elif reason == "pipe":
            guard_pipe += 1
        else:
            guard_quality += 1
        if strict_mode:
            if suspicious_existing_current:
                lang_data[key] = str(en_text)
                sanitized_existing += 1
            skipped_not_placeholder += 1
        else:
            lang_data[key] = f"[{target_lang.upper()}] {en_text}"
            placeholders += 1
        continue

    # Spróbuj prostego tłumaczenia
    simple = simple_translate(en_text, target_lang)

    if not simple:
        by_text = text_memory.get(str(en_text))
        if not by_text:
            by_text = text_memory_lc.get(str(en_text).lower())
        if by_text:
            simple = by_text

    if not simple:
        simple = translate_words_for_simple_text(str(en_text), target_lang)
    
    if simple:
        # ── Faza 4: Auto-fix pass na simple candidate ─────────────────
        simple, _af_fixes = _auto_fix_translation(en_text, simple, target_lang)
        # Guard na placeholdery {} + komendy '' + formatowanie |...|
        ok, reason = validate_candidate(en_text, simple)
        if ok:
            issues = detect_suspicious(en_text, simple, target_lang, key)
            issues.extend(validate_per_lang(en_text, simple, target_lang, key))
            max_sev = _max_severity(issues)
            if issues:
                # Only count MEDIUM+ issues as truly suspicious (LOW = informational)
                if max_sev != "LOW":
                    suspicious_detected += 1
                if max_sev in ("HIGH", "CRITICAL"):
                    suspicious_high += 1
                log_entry = {
                    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                    "lang": target_lang,
                    "category": json_file,
                    "key": key,
                    "source": "simple",
                    "severity": max_sev,
                    "issues": issues,
                    "en": str(en_text),
                    "translated": str(simple),
                }
                if len(issues) > 3:
                    suspicious_rejected += 1
                    _append_jsonl(suspicious_rejected_path, log_entry)
                    _enqueue_manual_review(status_dir, {
                        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                        "status": "pending",
                        "lang": target_lang,
                        "json_file": json_file,
                        "key": key,
                        "reason": "more_than_3_suspicious_flags",
                        "en_text": str(en_text),
                        "attempted_translation": str(simple),
                        "issues": issues,
                        "source": "simple",
                    })
                    guard_fail += 1
                    guard_quality += 1
                    if strict_mode:
                        skipped_not_placeholder += 1
                    else:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    continue
                if max_sev == "CRITICAL":
                    if _has_issue_type(issues, "identical_to_en") and use_google_translate:
                        # Simple/TM-text dał EN-copy dla PL/ES — przekieruj do GT.
                        gt_pending.append((key, en_text, h, suspicious_existing_current))
                        _append_jsonl(suspicious_log_path, {
                            "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                            "lang": target_lang,
                            "category": json_file,
                            "key": key,
                            "source": "simple",
                            "severity": "CRITICAL",
                            "issues": issues,
                            "action": "fallback_to_google_translate",
                            "en": str(en_text),
                            "translated": str(simple),
                        })
                        continue
                    suspicious_rejected += 1
                    _append_jsonl(suspicious_rejected_path, log_entry)
                    guard_fail += 1
                    guard_quality += 1
                    if strict_mode:
                        skipped_not_placeholder += 1
                    else:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    continue
                _append_jsonl(suspicious_log_path, log_entry)
            lang_data[key] = simple
            translated += 1
            source_name = "simple_dict" if simple_translate(en_text, target_lang) else "word_dict"
            tm_upsert(key, h, simple, source_name, 0.98 if source_name == "simple_dict" else 0.92)
            tm_updates += 1
            recent_translations.append({
                "key": key,
                "en": en_text,
                "translated": simple,
                "source": "simple",
            })
        else:
            if strict_mode:
                skipped_not_placeholder += 1
            else:
                lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                placeholders += 1
            guard_fail += 1
            if reason == "placeholder":
                guard_placeholder += 1
            elif reason == "command":
                guard_command += 1
            elif reason == "pipe":
                guard_pipe += 1
            else:
                guard_quality += 1
            if strict_mode and suspicious_existing_current:
                lang_data[key] = str(en_text)
                sanitized_existing += 1
    else:
        # Brak tłumaczenia z słowników — zbierz do GT lub ustaw placeholder
        if use_google_translate:
            # Zbierz do batch GT (działa zarówno w strict jak i non-strict)
            gt_pending.append((key, en_text, h, suspicious_existing_current))
        elif strict_mode:
            if suspicious_existing_current:
                lang_data[key] = str(en_text)
                sanitized_existing += 1
            skipped_not_placeholder += 1
        else:
            # Placeholder z kodem języka
            lang_data[key] = f"[{target_lang.upper()}] {en_text}"
            placeholders += 1

# ============================================================================
# GOOGLE TRANSLATE — batch fallback
# ============================================================================
gt_translated = 0
gt_guard_fail = 0

if use_google_translate and gt_pending:
    import time
    gt_lang = _gt_lang_code(target_lang)
    try:
        from deep_translator import GoogleTranslator
        translator = GoogleTranslator(source='en', target=gt_lang)
        print(f"🌍 GT: {len(gt_pending)} kluczy do tłumaczenia via Google Translate ({gt_lang})")

        # Limit GT do translate_limit (jeśli ustawiony)
        gt_todo = gt_pending
        if translate_limit > 0:
            remaining = translate_limit - translated
            if remaining <= 0:
                gt_todo = []
                print(f"⚠️ GT: limit tłumaczeń osiągnięty ({translate_limit}), pomijam GT")
            else:
                gt_todo = gt_pending[:remaining]

        for batch_start in range(0, len(gt_todo), gt_batch_size):
            batch = gt_todo[batch_start:batch_start + gt_batch_size]
            # Przygotuj teksty z ochroną placeholderów
            protected_texts = []
            meta = []  # (key, en_text, hash, suspicious, replacements)
            for key, en_text, h, suspicious in batch:
                protected, replacements = _protect_placeholders(str(en_text))
                protected_texts.append(protected)
                meta.append((key, en_text, h, suspicious, replacements))

            # Batch translate
            try:
                if len(protected_texts) == 1:
                    gt_results = [translator.translate(protected_texts[0])]
                else:
                    gt_results = translator.translate_batch(protected_texts)
                if gt_results is None:
                    gt_results = protected_texts  # fallback — użyj oryginału
            except Exception as e:
                print(f"⚠️ GT batch error: {e}")
                gt_results = protected_texts  # fallback

            # Zastosuj wyniki
            for i, (key, en_text, h, suspicious, replacements) in enumerate(meta):
                if i >= len(gt_results) or gt_results[i] is None:
                    # GT nie dał wyniku
                    if not strict_mode:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    else:
                        skipped_not_placeholder += 1
                    continue

                candidate = _restore_placeholders(gt_results[i], replacements)

                # ── Faza 4: Auto-fix + post-translation validation ────────────
                candidate, _af_fixes = _auto_fix_translation(en_text, candidate, target_lang)

                # Walidacja tłumaczenia GT
                ok, reason = validate_candidate(en_text, candidate)
                if ok:
                    issues = detect_suspicious(en_text, candidate, target_lang, key)
                    issues.extend(validate_per_lang(en_text, candidate, target_lang, key))
                    max_sev = _max_severity(issues)
                    if issues:
                        # Only count MEDIUM+ issues as truly suspicious (LOW = informational)
                        if max_sev != "LOW":
                            suspicious_detected += 1
                        if max_sev in ("HIGH", "CRITICAL"):
                            suspicious_high += 1
                        log_entry = {
                            "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                            "lang": target_lang,
                            "category": json_file,
                            "key": key,
                            "source": "google_translate",
                            "severity": max_sev,
                            "issues": issues,
                            "en": str(en_text),
                            "translated": str(candidate),
                        }
                        if len(issues) > 3:
                            suspicious_rejected += 1
                            _append_jsonl(suspicious_rejected_path, log_entry)
                            _enqueue_manual_review(status_dir, {
                                "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                                "status": "pending",
                                "lang": target_lang,
                                "json_file": json_file,
                                "key": key,
                                "reason": "more_than_3_suspicious_flags",
                                "en_text": str(en_text),
                                "attempted_translation": str(candidate),
                                "issues": issues,
                                "source": "google_translate",
                            })
                            gt_guard_fail += 1
                            guard_fail += 1
                            guard_quality += 1
                            if not strict_mode:
                                lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                                placeholders += 1
                            else:
                                skipped_not_placeholder += 1
                            continue
                        if max_sev == "CRITICAL":
                            suspicious_rejected += 1
                            _append_jsonl(suspicious_rejected_path, log_entry)
                            gt_guard_fail += 1
                            guard_fail += 1
                            guard_quality += 1
                            if not strict_mode:
                                lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                                placeholders += 1
                            else:
                                skipped_not_placeholder += 1
                            continue
                        _append_jsonl(suspicious_log_path, log_entry)
                    lang_data[key] = candidate
                    gt_translated += 1
                    translated += 1
                    tm_upsert(key, h, candidate, "google_translate", 0.90)
                    tm_updates += 1
                    recent_translations.append({
                        "key": key,
                        "en": en_text,
                        "translated": candidate,
                        "source": "google_translate",
                    })
                else:
                    gt_guard_fail += 1
                    guard_fail += 1
                    if reason == "placeholder":
                        guard_placeholder += 1
                    elif reason == "command":
                        guard_command += 1
                    elif reason == "pipe":
                        guard_pipe += 1
                    else:
                        guard_quality += 1
                    if not strict_mode:
                        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                        placeholders += 1
                    else:
                        skipped_not_placeholder += 1

            # Rate limit delay między batchami
            if batch_start + gt_batch_size < len(gt_todo):
                time.sleep(gt_delay)

        print(f"✅ GT: {gt_translated} przetłumaczonych, {gt_guard_fail} odrzuconych przez guard")

    except ImportError:
        print("⚠️ GT: deep-translator nie zainstalowany (pip install deep-translator)")
        for key, en_text, h, suspicious in gt_pending:
            if not strict_mode:
                lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                placeholders += 1
            else:
                skipped_not_placeholder += 1
    except Exception as e:
        print(f"⚠️ GT: błąd inicjalizacji: {e}")
        for key, en_text, h, suspicious in gt_pending:
            if not strict_mode:
                lang_data[key] = f"[{target_lang.upper()}] {en_text}"
                placeholders += 1
            else:
                skipped_not_placeholder += 1

# Zapisz (atomic)
import tempfile
lang_data = dict(sorted(lang_data.items()))
lang_dir_path = os.path.dirname(lang_file) or "."
fd, tmp_lang = tempfile.mkstemp(dir=lang_dir_path, suffix=".tmp")
try:
    with os.fdopen(fd, 'w', encoding='utf-8') as f:
        json.dump(lang_data, f, indent=2, ensure_ascii=False)
    os.replace(tmp_lang, lang_file)
except Exception:
    try: os.unlink(tmp_lang)
    except: pass
    raise

if tm_updates > 0:
    import tempfile
    tm_dir = os.path.dirname(tm_path) or "."
    fd, tmp_tm = tempfile.mkstemp(dir=tm_dir, suffix=".tmp")
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            json.dump(tm_data, f, indent=2, ensure_ascii=False)
        os.replace(tmp_tm, tm_path)
    except Exception:
        try: os.unlink(tmp_tm)
        except: pass
        raise

# ============================================================================
# QUALITY METRICS — oblicz metryki jakości z tego cyklu tłumaczeń
# ============================================================================
quality_data = {}
all_recent = list(recent_translations)  # kopia przed obcięciem
if all_recent:
    en_lengths = [len(str(e.get("en", ""))) for e in all_recent]
    tr_lengths = [len(str(e.get("translated", ""))) for e in all_recent]
    avg_en = sum(en_lengths) / len(en_lengths) if en_lengths else 0
    avg_tr = sum(tr_lengths) / len(tr_lengths) if tr_lengths else 0
    length_ratio = avg_tr / avg_en if avg_en > 0 else 1.0

    # Source breakdown
    source_breakdown = {}
    for e in all_recent:
        src = e.get("source", "unknown")
        source_breakdown[src] = source_breakdown.get(src, 0) + 1

    # Identical to EN count
    identical_to_en_translatable = 0
    identical_to_en_exempt = 0
    for e in all_recent:
        en_text = str(e.get("en", "")).strip()
        tr_text = str(e.get("translated", "")).strip()
        if tr_text != en_text:
            continue
        if _is_probably_nontranslatable_text(en_text):
            identical_to_en_exempt += 1
        else:
            identical_to_en_translatable += 1

    # Very short/long
    very_short = sum(1 for e in all_recent if len(str(e.get("translated", ""))) < 2 and len(str(e.get("en", ""))) > 5)
    very_long = sum(1 for e in all_recent if len(str(e.get("translated", ""))) > 500 and len(str(e.get("en", ""))) < 50)

    quality_data = {
        "avg_en_len": round(avg_en, 1),
        "avg_translated_len": round(avg_tr, 1),
        "length_ratio": round(length_ratio, 3),
        "source_breakdown": source_breakdown,
        "suspicious_count": suspicious_detected,
        "suspicious_rejected": suspicious_rejected,
        "suspicious_high": suspicious_high,
        "gt_guard_fails": gt_guard_fail,
        "identical_to_en": identical_to_en_translatable,
        "identical_to_en_exempt": identical_to_en_exempt,
        "very_short_translations": very_short,
        "very_long_translations": very_long,
    }

# Zapisz quality_report.jsonl
try:
    os.makedirs(status_dir, exist_ok=True)
    quality_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "language": target_lang,
        "json_file": json_file,
        "translated": translated,
        "quality": quality_data,
    }
    with open(os.path.join(status_dir, "quality_report.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(quality_entry, ensure_ascii=False) + "\n")
except Exception:
    pass

# Zapisz quality_dashboard.json — aktualizuj per-język
try:
    dash_path = os.path.join(status_dir, "quality_dashboard.json")
    dashboard = {}
    if os.path.exists(dash_path):
        with open(dash_path, "r", encoding="utf-8") as f:
            dashboard = json.load(f)
    lang_entry = dashboard.get(target_lang, {})
    lang_entry["last_cycle"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    lang_entry["last_translated"] = translated
    lang_entry["total_suspicious"] = lang_entry.get("total_suspicious", 0) + suspicious_detected
    lang_entry["total_rejected"] = lang_entry.get("total_rejected", 0) + suspicious_rejected
    lang_entry["total_gt_guard_fail"] = lang_entry.get("total_gt_guard_fail", 0) + gt_guard_fail
    cycles_count = lang_entry.get("cycles", 0) + 1
    lang_entry["cycles"] = cycles_count
    # Rolling quality score (0-100)
    if quality_data:
        ratio = quality_data.get("length_ratio", 1.0)
        ratio_score = max(0, 100 - abs(ratio - 1.0) * 50)  # ideal=1.0
        reject_rate = (suspicious_rejected / max(translated, 1)) * 100
        reject_score = max(0, 100 - reject_rate * 5)
        new_score = round((ratio_score + reject_score) / 2, 1)
        old_score = lang_entry.get("quality_score", new_score)
        lang_entry["quality_score"] = round((old_score * (cycles_count - 1) + new_score) / cycles_count, 1)
    dashboard[target_lang] = lang_entry
    import tempfile as _qd_tmp
    fd, tmp_dash = _qd_tmp.mkstemp(dir=status_dir, suffix=".tmp")
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            json.dump(dashboard, f, indent=2, ensure_ascii=False)
        os.replace(tmp_dash, dash_path)
    except Exception:
        try: os.unlink(tmp_dash)
        except: pass
except Exception:
    pass

recent_translations = recent_translations[-20:]
try:
    os.makedirs(status_dir, exist_ok=True)
    recent_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "language": target_lang,
        "json_file": json_file,
        "translated": translated,
        "entries": recent_translations,
    }
    with open(os.path.join(status_dir, "translation_recent_latest.json"), "w", encoding="utf-8") as f:
        json.dump(recent_entry, f, indent=2, ensure_ascii=False)
    with open(os.path.join(status_dir, "translation_recent_report.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(recent_entry, ensure_ascii=False) + "\n")
except Exception:
    pass

# Quality warnings
quality_warnings = []
if quality_data:
    lr = quality_data.get("length_ratio", 1.0)
    if lr < 0.5 or lr > 3.0:
        quality_warnings.append(f"LENGTH_RATIO={lr:.2f}")
    if quality_data.get("suspicious_count", 0) > 20:
        quality_warnings.append(f"SUSPICIOUS={quality_data['suspicious_count']}")
    if translated > 0 and gt_guard_fail / max(translated, 1) > 0.2:
        quality_warnings.append(f"GT_FAIL_RATE={gt_guard_fail}/{translated}")
    if quality_data.get("very_long_translations", 0) > 0:
        quality_warnings.append(f"VERY_LONG={quality_data['very_long_translations']}")

print(f"✅ {target_lang}/{json_file}: {translated} przetłumaczonych (GT: {gt_translated}), {placeholders} placeholder'ów, TM+{tm_updates}, guard_fail={guard_fail}, guard_quality={guard_quality}, suspicious_existing={suspicious_existing}, suspicious_detected={suspicious_detected}, suspicious_high={suspicious_high}, suspicious_rejected={suspicious_rejected}, sanitized_existing={sanitized_existing}")

if quality_warnings:
    print(f"⚠️ QUALITY_WARNINGS: {', '.join(quality_warnings)}")

# ── Section 12.2: Translation Done Contract ──────────────────────────────────
# Formalna definicja "tłumaczenie gotowe" per plik/lang.
# Warunki: (1) brak CRITICAL token errors, (2) guard_command <= próg,
#           (3) no_progress nie rośnie, (4) wpis quality z timestamp.
done_contract = {
    "file": json_file,
    "lang": target_lang,
    "conditions": {},
    "is_done": False,
}

# Cond 1: No CRITICAL token errors
cond1_ok = (guard_placeholder == 0 and guard_pipe == 0)
done_contract["conditions"]["no_critical_token_errors"] = {
    "ok": cond1_ok,
    "guard_placeholder": guard_placeholder,
    "guard_pipe": guard_pipe,
}

# Cond 2: guard_command <= threshold (5)
guard_cmd_threshold = 5
cond2_ok = (guard_command <= guard_cmd_threshold)
done_contract["conditions"]["guard_command_below_threshold"] = {
    "ok": cond2_ok,
    "guard_command": guard_command,
    "threshold": guard_cmd_threshold,
}

# Cond 3: Coverage check — all EN keys present and translated
total_en_keys = len(en_data)
real_translations = sum(1 for k, v in lang_data.items() if k in en_data and not str(v).startswith(f"[{target_lang.upper()}]"))
coverage_pct = round(real_translations / max(total_en_keys, 1) * 100, 1)
cond3_ok = (coverage_pct >= 95.0)
done_contract["conditions"]["coverage_above_95pct"] = {
    "ok": cond3_ok,
    "coverage_pct": coverage_pct,
    "total_keys": total_en_keys,
    "real_translations": real_translations,
}

# Cond 4: Quality entry present with timestamp
cond4_ok = bool(quality_data)
done_contract["conditions"]["quality_entry_present"] = {
    "ok": cond4_ok,
    "has_quality_data": cond4_ok,
}

# Final verdict
done_contract["is_done"] = all([cond1_ok, cond2_ok, cond3_ok, cond4_ok])
done_contract["timestamp"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

# Zapisz done contract do pliku
try:
    done_dir = os.path.join(status_dir, "done_contracts")
    os.makedirs(done_dir, exist_ok=True)
    done_path = os.path.join(done_dir, f"{target_lang}_{json_file.replace('.json', '')}.json")
    with open(done_path, "w", encoding="utf-8") as f:
        json.dump(done_contract, f, indent=2, ensure_ascii=False)
    # JSONL append
    _append_jsonl(os.path.join(status_dir, "done_contract_history.jsonl"), done_contract)
except Exception:
    pass

if done_contract["is_done"]:
    print(f"🏁 DONE_CONTRACT: {target_lang}/{json_file} — SPEŁNIONY ✅ (coverage={coverage_pct}%)")
else:
    failed = [k for k, v in done_contract["conditions"].items() if not v.get("ok")]
    print(f"📋 DONE_CONTRACT: {target_lang}/{json_file} — NIESPEŁNIONY ({', '.join(failed)})")

print(f"__DONE_CONTRACT__ is_done={'1' if done_contract['is_done'] else '0'} coverage={coverage_pct} guard_placeholder={guard_placeholder} guard_pipe={guard_pipe} guard_command={guard_command}")

print(f"__AUTO_RESULT__ translated={translated} placeholders={placeholders} guard_fail={guard_fail} guard_placeholder={guard_placeholder} guard_command={guard_command} guard_pipe={guard_pipe} guard_quality={guard_quality} skipped_missing_file={skipped_missing_file} skipped_missing_key={skipped_missing_key} skipped_not_placeholder={skipped_not_placeholder} suspicious_existing={suspicious_existing} suspicious_detected={suspicious_detected} suspicious_high={suspicious_high} suspicious_rejected={suspicious_rejected} sanitized_existing={sanitized_existing} gt_translated={gt_translated} gt_guard_fail={gt_guard_fail}")
print(f"__QUALITY__ {json.dumps(quality_data, ensure_ascii=False)}")
AUTOTRANSPY
    2>&1)
    _at_rc=$?

    echo "$_at_out" >&2

    local _auto_result_line
    _auto_result_line=$(printf '%s\n' "$_at_out" | grep '__AUTO_RESULT__' | tail -n 1)

    _translated=$(extract_auto_result_metric "$_auto_result_line" "translated")
    _placeholders=$(extract_auto_result_metric "$_auto_result_line" "placeholders")
    _guard_fail=$(extract_auto_result_metric "$_auto_result_line" "guard_fail")
    _guard_placeholder=$(extract_auto_result_metric "$_auto_result_line" "guard_placeholder")
    _guard_command=$(extract_auto_result_metric "$_auto_result_line" "guard_command")
    _guard_pipe=$(extract_auto_result_metric "$_auto_result_line" "guard_pipe")
    _skipped_missing_file=$(extract_auto_result_metric "$_auto_result_line" "skipped_missing_file")
    _skipped_missing_key=$(extract_auto_result_metric "$_auto_result_line" "skipped_missing_key")
    _skipped_not_placeholder=$(extract_auto_result_metric "$_auto_result_line" "skipped_not_placeholder")
    _translated=${_translated:-0}
    _placeholders=${_placeholders:-0}
    _guard_fail=${_guard_fail:-0}
    _guard_placeholder=${_guard_placeholder:-0}
    _guard_command=${_guard_command:-0}
    _guard_pipe=${_guard_pipe:-0}
    _skipped_missing_file=${_skipped_missing_file:-0}
    _skipped_missing_key=${_skipped_missing_key:-0}
    _skipped_not_placeholder=${_skipped_not_placeholder:-0}

    # Parsuj __QUALITY__ — ostrzeżenia jakości
    local _quality_line
    _quality_line=$(printf '%s\n' "$_at_out" | grep '__QUALITY__' | tail -n 1)
    if [ -n "$_quality_line" ]; then
        local _quality_json="${_quality_line#__QUALITY__ }"
        log "${CYAN}📊 Quality metrics: ${_quality_json:0:200}${NC}"
    fi

    # Parsuj QUALITY_WARNINGS
    local _qwarn_line
    _qwarn_line=$(printf '%s\n' "$_at_out" | grep 'QUALITY_WARNINGS' | tail -n 1)
    if [ -n "$_qwarn_line" ]; then
        log "${YELLOW}⚠️ ${_qwarn_line}${NC}"
    fi

    # Parsuj __DONE_CONTRACT__
    local _done_line
    _done_line=$(printf '%s\n' "$_at_out" | grep '__DONE_CONTRACT__' | tail -n 1)
    if [ -n "$_done_line" ]; then
        local _is_done
        _is_done=$(printf '%s\n' "$_done_line" | grep -oE 'is_done=[01]' | cut -d= -f2)
        local _coverage
        _coverage=$(printf '%s\n' "$_done_line" | grep -oE 'coverage=[0-9.]+' | cut -d= -f2)
        if [ "${_is_done:-0}" = "1" ]; then
            log "${GREEN}🏁 Done Contract: SPEŁNIONY (coverage=${_coverage}%)${NC}"
        else
            log "${YELLOW}📋 Done Contract: NIESPEŁNIONY (coverage=${_coverage}%)${NC}"
        fi
    fi

    # stdout: "translated placeholders guard_fail guard_placeholder guard_command guard_pipe skipped_missing_file skipped_missing_key skipped_not_placeholder"
    echo "$_translated $_placeholders $_guard_fail $_guard_placeholder $_guard_command $_guard_pipe $_skipped_missing_file $_skipped_missing_key $_skipped_not_placeholder"
    
    log "${GREEN}✅ Auto-translate zakończone${NC}"
}

append_translation_guard_report() {
    local cycle="$1"
    local lang="$2"
    local json_file="$3"
    local translated="$4"
    local placeholders="$5"
    local guard_fail="$6"
    local guard_placeholder="$7"
    local guard_command="$8"
    local guard_pipe="$9"
    local strict_missing_file="${10}"
    local strict_missing_key="${11}"
    local strict_skipped_done="${12}"

    mkdir -p "$STATUS_DIR" 2>/dev/null || true

    python3 - "$STATUS_DIR" "$cycle" "$lang" "$json_file" "$translated" "$placeholders" "$guard_fail" "$guard_placeholder" "$guard_command" "$guard_pipe" "$strict_missing_file" "$strict_missing_key" "$strict_skipped_done" << 'PYGUARD'
import json
import os
import sys
from datetime import datetime, timezone

status_dir = sys.argv[1]
cycle = int(sys.argv[2]) if sys.argv[2].isdigit() else 0
lang = sys.argv[3]
json_file = sys.argv[4]
translated = int(sys.argv[5]) if sys.argv[5].isdigit() else 0
placeholders = int(sys.argv[6]) if sys.argv[6].isdigit() else 0
guard_fail = int(sys.argv[7]) if sys.argv[7].isdigit() else 0
guard_placeholder = int(sys.argv[8]) if sys.argv[8].isdigit() else 0
guard_command = int(sys.argv[9]) if sys.argv[9].isdigit() else 0
guard_pipe = int(sys.argv[10]) if sys.argv[10].isdigit() else 0
strict_missing_file = int(sys.argv[11]) if sys.argv[11].isdigit() else 0
strict_missing_key = int(sys.argv[12]) if sys.argv[12].isdigit() else 0
strict_skipped_done = int(sys.argv[13]) if sys.argv[13].isdigit() else 0

entry = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "cycle": cycle,
    "language": lang,
    "json_file": json_file,
    "translated": translated,
    "placeholders": placeholders,
    "guard_fail": guard_fail,
    "guard": {
        "placeholder": guard_placeholder,
        "command": guard_command,
        "pipe": guard_pipe,
    },
    "strict_missing_file": strict_missing_file,
    "strict_missing_key": strict_missing_key,
    "strict_skipped_done": strict_skipped_done,
}

jsonl_path = os.path.join(status_dir, "translation_guard_report.jsonl")
with open(jsonl_path, "a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False) + "\n")

latest_path = os.path.join(status_dir, "translation_guard_latest.json")
with open(latest_path, "w", encoding="utf-8") as f:
    json.dump(entry, f, indent=2, ensure_ascii=False)
PYGUARD
}

# === Runtime config: worker_config.json ===
# Persystentna konfiguracja runtime'owa, czytana co cykl bez restartu workera.
# Edytuj plik worker_config.json aby zmienić zachowanie workera w locie.
WORKER_CONFIG_FILE="worker_config.json"

save_default_worker_config() {
    [ -f "$WORKER_CONFIG_FILE" ] && return 0
    cat > "$WORKER_CONFIG_FILE" << 'WCEOF'
{
  "_comment": "Runtime config for i18n_worker_simple.sh — edytuj w dowolnym momencie, worker wczyta zmiany w następnym cyklu",
  "focus_lang": "",
  "focus_category": "",
  "use_gt": false,
  "gt_batch_size": 50,
  "gt_delay": 1.5,
  "translate_limit": 0,
  "parallel_langs": 3,
  "adaptive_batch": true,
  "crossref_auto_fix": false,
  "crossref_auto_fix_limit": 30,
  "paused": false,
  "test_lang": "",
  "test_all_langs_queue": []
}
WCEOF
    log "${GREEN}📄 Utworzono domyślny $WORKER_CONFIG_FILE${NC}"
}

load_worker_config() {
    [ ! -f "$WORKER_CONFIG_FILE" ] && return 0

    local cfg
    cfg=$(python3 - "$WORKER_CONFIG_FILE" << 'LOADCFGPY'
import json, sys, os

path = sys.argv[1]
defaults = {
    "focus_lang": "",
    "focus_category": "",
    "use_gt": False,
    "gt_batch_size": 50,
    "gt_delay": 1.5,
    "translate_limit": 0,
    "parallel_langs": 3,
    "adaptive_batch": True,
    "crossref_auto_fix": False,
    "crossref_auto_fix_limit": 30,
    "paused": False,
    "test_lang": "",
    "test_all_langs_queue": [],
}

try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    cfg = {}

# Merge with defaults
for k, v in defaults.items():
    if k not in cfg:
        cfg[k] = v

# Output: key=value lines for bash eval
out = []
def bval(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    return str(v)

out.append(f"CFG_FOCUS_LANG={cfg['focus_lang']}")
out.append(f"CFG_FOCUS_CATEGORY={cfg['focus_category']}")
out.append(f"CFG_USE_GT={bval(cfg['use_gt'])}")
out.append(f"CFG_GT_BATCH_SIZE={cfg['gt_batch_size']}")
out.append(f"CFG_GT_DELAY={cfg['gt_delay']}")
out.append(f"CFG_TRANSLATE_LIMIT={cfg['translate_limit']}")
out.append(f"CFG_PARALLEL_LANGS={cfg['parallel_langs']}")
out.append(f"CFG_ADAPTIVE_BATCH={bval(cfg['adaptive_batch'])}")
out.append(f"CFG_CROSSREF_AUTO_FIX={bval(cfg['crossref_auto_fix'])}")
out.append(f"CFG_CROSSREF_AUTO_FIX_LIMIT={cfg['crossref_auto_fix_limit']}")
out.append(f"CFG_PAUSED={bval(cfg['paused'])}")
out.append(f"CFG_TEST_LANG={cfg['test_lang']}")

# test_all_langs_queue as space-separated
queue = cfg.get("test_all_langs_queue", [])
if isinstance(queue, list):
    out.append(f"CFG_TEST_QUEUE={' '.join(str(x) for x in queue)}")
else:
    out.append("CFG_TEST_QUEUE=")

print("\n".join(out))
LOADCFGPY
    ) 2>/dev/null || true

    [ -z "$cfg" ] && return 0

    # Eval config values
    eval "$cfg"

    # Apply config to worker variables (config overrides CLI defaults, but explicit CLI flags take priority)
    local changed=""

    # use_gt
    if [ "$CFG_USE_GT" = "true" ] && [ "$USE_GOOGLE_TRANSLATE" != "true" ]; then
        USE_GOOGLE_TRANSLATE=true
        changed="${changed} gt=on"
    elif [ "$CFG_USE_GT" = "false" ] && [ "$USE_GOOGLE_TRANSLATE" = "true" ] && [ "${CLI_USE_GT:-}" != "true" ]; then
        USE_GOOGLE_TRANSLATE=false
        changed="${changed} gt=off"
    fi

    # gt_batch_size
    if [ "${CFG_GT_BATCH_SIZE:-0}" -gt 0 ] 2>/dev/null; then
        GT_BATCH_SIZE="$CFG_GT_BATCH_SIZE"
    fi

    # gt_delay
    if [ -n "$CFG_GT_DELAY" ]; then
        GT_DELAY="$CFG_GT_DELAY"
    fi

    # translate_limit (config override, 0 = let adaptive decide)
    if [ "${CFG_TRANSLATE_LIMIT:-0}" -gt 0 ] 2>/dev/null && [ "${USER_TRANSLATE_LIMIT:-0}" -eq 0 ] 2>/dev/null; then
        TRANSLATE_LIMIT="$CFG_TRANSLATE_LIMIT"
        changed="${changed} limit=$CFG_TRANSLATE_LIMIT"
    fi

    # parallel_langs
    if [ "${CFG_PARALLEL_LANGS:-0}" -gt 0 ] 2>/dev/null; then
        PARALLEL_LANGS_PER_CYCLE="$CFG_PARALLEL_LANGS"
    fi

    # adaptive_batch
    ADAPTIVE_BATCH_ENABLED="$CFG_ADAPTIVE_BATCH"

    # crossref
    CROSSREF_AUTO_FIX="$CFG_CROSSREF_AUTO_FIX"
    if [ "${CFG_CROSSREF_AUTO_FIX_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
        CROSSREF_AUTO_FIX_LIMIT="$CFG_CROSSREF_AUTO_FIX_LIMIT"
    fi

    # focus_lang → PINNED_AUTO_LANG
    if [ -n "$CFG_FOCUS_LANG" ]; then
        if [ "$CFG_FOCUS_LANG" != "${PINNED_AUTO_LANG:-}" ]; then
            PINNED_AUTO_LANG="$CFG_FOCUS_LANG"
            PINNED_AUTO_JSON="${CFG_FOCUS_CATEGORY:-}"
            PINNED_AUTO_LIMIT=0
            changed="${changed} focus=$CFG_FOCUS_LANG"
        fi
    elif [ -n "${PINNED_AUTO_LANG:-}" ] && [ -z "${CFG_FOCUS_LANG:-}" ]; then
        # Config cleared focus → unpin
        if [ "${_LAST_CFG_FOCUS:-SET}" != "" ]; then
            PINNED_AUTO_LANG=""
            PINNED_AUTO_JSON=""
            PINNED_AUTO_LIMIT=0
            changed="${changed} unfocus"
        fi
    fi
    _LAST_CFG_FOCUS="${CFG_FOCUS_LANG:-}"

    # test_lang → wymuszenie cyklu test
    if [ -n "$CFG_TEST_LANG" ]; then
        RUNTIME_TEST_LANG="$CFG_TEST_LANG"
        changed="${changed} test=$CFG_TEST_LANG"
    else
        RUNTIME_TEST_LANG=""
    fi

    # test_all_langs_queue
    RUNTIME_TEST_QUEUE="${CFG_TEST_QUEUE:-}"

    # paused
    if [ "$CFG_PAUSED" = "true" ]; then
        changed="${changed} PAUSED"
    fi
    RUNTIME_PAUSED="$CFG_PAUSED"

    if [ -n "$changed" ]; then
        log "${CYAN}⚙️ Config reload:${changed}${NC}"
    fi
}

# Zapisz wartość do worker_config.json (key=value)
update_worker_config() {
    local key="$1"
    local value="$2"
    python3 - "$WORKER_CONFIG_FILE" "$key" "$value" << 'UPDATECFGPY'
import json, sys, os

path = sys.argv[1]
key = sys.argv[2]
raw_value = sys.argv[3]

try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    cfg = {}

# Auto-detect type
if raw_value.lower() in ("true", "on", "yes", "1"):
    value = True
elif raw_value.lower() in ("false", "off", "no", "0"):
    value = False
else:
    try:
        value = int(raw_value)
    except ValueError:
        try:
            value = float(raw_value)
        except ValueError:
            value = raw_value

cfg[key] = value
with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
print(f"OK {key}={value}")
UPDATECFGPY
}

# Wyczyść test_lang z config po wykonaniu testu
clear_test_lang_from_config() {
    update_worker_config "test_lang" "" >/dev/null 2>&1 || true
}

# Pop next lang from test_all_langs_queue
pop_test_queue_lang() {
    python3 - "$WORKER_CONFIG_FILE" << 'POPQPY'
import json, sys, os

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    cfg = {}

queue = cfg.get("test_all_langs_queue", [])
if not queue:
    print("")
    sys.exit(0)

lang = queue.pop(0)
cfg["test_all_langs_queue"] = queue
with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
print(lang)
POPQPY
}

# === Sekcja 8.3: Adaptive batch tuning ===
# Analizuje ostatnie N cykli z guard_report i dynamicznie dostosowuje
# GT_BATCH_SIZE i efektywny translate_limit.
# Wynik: ustawia ADAPTIVE_BATCH_CURRENT (liczba kluczy/cykl) i GT_BATCH_SIZE.
compute_adaptive_batch() {
    if [ "${ADAPTIVE_BATCH_ENABLED:-true}" != "true" ]; then
        ADAPTIVE_BATCH_CURRENT="${ADAPTIVE_BATCH_DEFAULT:-20}"
        return 0
    fi

    local result
    result=$(python3 - "$STATUS_DIR" "$ADAPTIVE_BATCH_DEFAULT" "$ADAPTIVE_BATCH_MIN" \
        "$ADAPTIVE_BATCH_MAX" "$ADAPTIVE_BATCH_WINDOW" \
        "$ADAPTIVE_BATCH_HIGH_THRESHOLD" "$ADAPTIVE_BATCH_LOW_THRESHOLD" \
        "$GT_BATCH_SIZE" << 'ADAPTIVEPY'
import json
import os
import sys

status_dir = sys.argv[1]
default_batch = int(sys.argv[2] or "20")
min_batch = int(sys.argv[3] or "5")
max_batch = int(sys.argv[4] or "50")
window = int(sys.argv[5] or "10")
high_threshold = float(sys.argv[6] or "20")
low_threshold = float(sys.argv[7] or "5")
current_gt_batch = int(sys.argv[8] or "50")

guard_report_path = os.path.join(status_dir, "translation_guard_report.jsonl")
adaptive_state_path = os.path.join(status_dir, "adaptive_batch_state.json")

# Odczytaj ostatnich N wpisów z guard_report
entries = []
if os.path.exists(guard_report_path):
    try:
        with open(guard_report_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        for line in lines[-window:]:
            line = line.strip()
            if line:
                try:
                    entries.append(json.loads(line))
                except Exception:
                    pass
    except Exception:
        pass

# Oblicz guard_fail_rate z ostatnich N cykli
total_translated = 0
total_guard_fail = 0
total_attempts = 0
for e in entries:
    translated = int(e.get("translated", 0) or 0)
    guard_fail = int(e.get("guard_fail", 0) or 0)
    total_translated += translated
    total_guard_fail += guard_fail
    total_attempts += translated + guard_fail

if total_attempts == 0:
    # Brak danych — użyj domyślnego
    guard_fail_rate = 0.0
    new_batch = default_batch
    reason = "no_data"
else:
    guard_fail_rate = (total_guard_fail / total_attempts) * 100.0

    # Odczytaj poprzedni batch size
    prev_batch = default_batch
    try:
        if os.path.exists(adaptive_state_path):
            with open(adaptive_state_path, "r", encoding="utf-8") as f:
                prev_state = json.load(f)
            prev_batch = int(prev_state.get("batch_size", default_batch))
    except Exception:
        pass

    if guard_fail_rate > high_threshold:
        # Wysoki fail rate → zmniejsz batch o 25%
        new_batch = max(min_batch, int(prev_batch * 0.75))
        reason = f"decrease_high_fail_rate={guard_fail_rate:.1f}%"
    elif guard_fail_rate < low_threshold:
        # Niski fail rate → zwiększ batch o 25%
        new_batch = min(max_batch, int(prev_batch * 1.25))
        reason = f"increase_low_fail_rate={guard_fail_rate:.1f}%"
    else:
        # W normie → utrzymaj
        new_batch = prev_batch
        reason = f"stable_fail_rate={guard_fail_rate:.1f}%"

# Dostosuj GT_BATCH_SIZE: nie powinien być większy niż batch kluczy
new_gt_batch = min(current_gt_batch, new_batch)

# Zapisz stan
try:
    os.makedirs(status_dir, exist_ok=True)
    state = {
        "batch_size": new_batch,
        "gt_batch_size": new_gt_batch,
        "guard_fail_rate": round(guard_fail_rate, 2),
        "total_translated": total_translated,
        "total_guard_fail": total_guard_fail,
        "total_attempts": total_attempts,
        "window": window,
        "entries_used": len(entries),
        "reason": reason,
    }
    with open(adaptive_state_path, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
except Exception:
    pass

# Output: batch_size gt_batch_size guard_fail_rate reason
print(f"{new_batch} {new_gt_batch} {guard_fail_rate:.1f} {reason}")
ADAPTIVEPY
    ) 2>/dev/null || true

    if [ -n "$result" ]; then
        ADAPTIVE_BATCH_CURRENT=$(echo "$result" | awk '{print $1}')
        local new_gt_batch=$(echo "$result" | awk '{print $2}')
        local fail_rate=$(echo "$result" | awk '{print $3}')
        local reason=$(echo "$result" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')

        # Aktualizuj GT_BATCH_SIZE jeśli adaptive zmniejszył
        if [ "${new_gt_batch:-0}" -gt 0 ] 2>/dev/null; then
            GT_BATCH_SIZE="$new_gt_batch"
        fi

        # Jeśli TRANSLATE_LIMIT nie jest ustawiony ręcznie, użyj adaptive
        if [ "${TRANSLATE_LIMIT:-0}" -eq 0 ] 2>/dev/null; then
            TRANSLATE_LIMIT="$ADAPTIVE_BATCH_CURRENT"
        fi

        log "${CYAN}📊 Adaptive batch: keys=$ADAPTIVE_BATCH_CURRENT gt_batch=$GT_BATCH_SIZE fail_rate=${fail_rate}% ($reason)${NC}"
    else
        ADAPTIVE_BATCH_CURRENT="${ADAPTIVE_BATCH_DEFAULT:-20}"
        if [ "${TRANSLATE_LIMIT:-0}" -eq 0 ] 2>/dev/null; then
            TRANSLATE_LIMIT="$ADAPTIVE_BATCH_CURRENT"
        fi
        log "${YELLOW}⚠ Adaptive batch: fallback to default=$ADAPTIVE_BATCH_CURRENT${NC}"
    fi
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

# Kategorie do dokumentowania - dynamicznie z katalogu EN
en_dir = os.path.join(I18N_DIR, "en")
if not os.path.exists(en_dir):
    print("⚠️ Brak katalogu i18n/en")
    exit(0)

CATEGORIES = [f[:-5] for f in sorted(os.listdir(en_dir)) if f.endswith('.json')]

generated = 0

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
# Dynamicznie wykrywaj kategorie z katalogu EN
en_dir = os.path.join(I18N_DIR, "en")
if not os.path.exists(en_dir):
    print("⚠️ Brak katalogu i18n/en")
    exit(0)

CATEGORIES = [f[:-5] for f in sorted(os.listdir(en_dir)) if f.endswith('.json')]

en_data = {}  # {category: {key: text}}
for cat in CATEGORIES:
    en_file = os.path.join(en_dir, f"{cat}.json")
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

run_language_spotcheck() {
    local target_lang="${1:-}"
    local sample_size="${2:-20}"
    if [ -z "$target_lang" ]; then
        echo "SPOTCHECK_ERROR=missing_lang"
        return 1
    fi
    python3 tools/i18n_language_spotcheck.py --i18n-dir "$I18N_DIR" --lang "$target_lang" --sample "$sample_size" 2>/dev/null || true
}

run_language_grammar_fix() {
    local target_lang="${1:-}"
    local json_file="${2:-npc.json}"
    local fix_limit="${3:-20}"
    if [ -z "$target_lang" ]; then
        echo "GRAMMARFIX_ERROR=missing_lang"
        return 1
    fi
    local args=(tools/i18n_grammar_refine.py --i18n-dir "$I18N_DIR" --lang "$target_lang" --json "$json_file" --limit "$fix_limit")
    if [ "$USE_GOOGLE_TRANSLATE" = "true" ]; then
        args+=(--use-gt)
    fi
    python3 "${args[@]}" 2>/dev/null || true
}

#===============================================================================
# WALIDACJA PER-JĘZYK — pełen audyt jednego lub wszystkich języków (6.3)
#===============================================================================
# Skanuje WSZYSTKIE klucze tłumaczeń, uruchamia walidatory V1–V7 + script-specific
# Generuje: i18n/status/validation/{lang}_report.json + summary.json
#===============================================================================
LANG_VALIDATION_INTERVAL="${LANG_VALIDATION_INTERVAL:-50}"  # co ile cykli
LAST_LANG_VALIDATION_CYCLE=0

run_full_lang_validation() {
    local current_cycle="${1:-0}"
    local force_lang="${2:-}"  # jeśli pusty, waliduj active lang z aktualnego cyklu

    # Sprawdź interwał (chyba że wymuszony)
    if [ -z "$force_lang" ]; then
        local cycles_since=$(( current_cycle - LAST_LANG_VALIDATION_CYCLE ))
        if [ "$cycles_since" -lt "$LANG_VALIDATION_INTERVAL" ] && [ "$LAST_LANG_VALIDATION_CYCLE" -gt 0 ]; then
            return 0
        fi
    fi

    log "${CYAN}🔬 LANG VALIDATION: Pełna walidacja per-język (cykl $current_cycle)...${NC}"
    LAST_LANG_VALIDATION_CYCLE=$current_cycle

    mkdir -p "$STATUS_DIR/validation" 2>/dev/null || true

    local _val_out
    _val_out=$(python3 - "$I18N_DIR" "$STATUS_DIR" "$force_lang" << 'LANG_VALIDATION_PY'
import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone

I18N_DIR = sys.argv[1]
STATUS_DIR = sys.argv[2]
FORCE_LANG = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else ""

AUTO_FIX_CROSSREF = os.environ.get("CROSSREF_AUTO_FIX", "false").lower() == "true"
USE_GOOGLE_TRANSLATE = os.environ.get("USE_GOOGLE_TRANSLATE", "false").lower() == "true"
try:
    AUTO_FIX_CROSSREF_LIMIT = int(os.environ.get("CROSSREF_AUTO_FIX_LIMIT", "30") or "30")
except Exception:
    AUTO_FIX_CROSSREF_LIMIT = 30
AUTO_FIX_CROSSREF_LIMIT = max(0, min(AUTO_FIX_CROSSREF_LIMIT, 200))

en_dir = os.path.join(I18N_DIR, "en")
val_dir = os.path.join(STATUS_DIR, "validation")
os.makedirs(val_dir, exist_ok=True)

# ============================================================================
# Mapowania pism
# ============================================================================
LANG_SCRIPT_GROUP = {
    "az": "latin", "bs": "latin", "cs": "latin", "cy": "latin", "da": "latin",
    "de": "latin", "es": "latin", "et": "latin", "fi": "latin",
    "fr": "latin", "ga": "latin", "gl": "latin", "hr": "latin", "hu": "latin",
    "id": "latin", "it": "latin", "lt": "latin", "lv": "latin", "ms": "latin",
    "mt": "latin", "nl": "latin", "no": "latin", "pl": "latin", "pt": "latin",
    "pt-br": "latin", "ro": "latin", "sk": "latin", "sl": "latin", "sq": "latin",
    "sv": "latin", "sw": "latin", "tl": "latin", "tr": "latin", "vi": "latin",
    "bg": "cyrillic", "mk": "cyrillic", "ru": "cyrillic", "sr": "cyrillic", "uk": "cyrillic",
    "ja": "cjk", "ko": "cjk", "zh": "cjk", "zh-cn": "cjk", "zh-tw": "cjk", "zh_tw": "cjk",
    "ar": "rtl", "he": "rtl",
    "bn": "exotic", "el": "exotic", "hi": "exotic", "hy": "exotic", "ka": "exotic",
    "ml": "exotic", "ta": "exotic", "te": "exotic", "th": "exotic",
}

EXPECTED_SCRIPTS = {
    "bn": "BENGALI", "el": "GREEK", "hi": "DEVANAGARI", "hy": "ARMENIAN",
    "ka": "GEORGIAN", "ml": "MALAYALAM", "ta": "TAMIL", "te": "TELUGU", "th": "THAI",
}

# ============================================================================
# Załaduj EN data
# ============================================================================
if not os.path.isdir(en_dir):
    print("__LANGVAL__ error=no_en_dir")
    raise SystemExit(0)

en_data_all = {}  # {category: {key: text}}
categories = [f[:-5] for f in sorted(os.listdir(en_dir)) if f.endswith(".json")]
for cat in categories:
    try:
        with open(os.path.join(en_dir, f"{cat}.json"), "r", encoding="utf-8") as f:
            en_data_all[cat] = json.load(f)
    except Exception:
        pass

pl_data_all = {}
pl_dir = os.path.join(I18N_DIR, "pl")
if os.path.isdir(pl_dir):
    for cat in categories:
        pl_path = os.path.join(pl_dir, f"{cat}.json")
        if not os.path.exists(pl_path):
            continue
        try:
            with open(pl_path, "r", encoding="utf-8") as f:
                loaded = json.load(f)
            if isinstance(loaded, dict):
                pl_data_all[cat] = loaded
        except Exception:
            continue

total_en_keys = sum(len(v) for v in en_data_all.values())

# ============================================================================
# Determine which languages to validate
# ============================================================================
if FORCE_LANG:
    langs_to_check = [FORCE_LANG]
else:
    _SKIP_DIRS = {"en", "status", "reports", "scripts", "tools", "docs", "backup"}
    langs_to_check = sorted(
        d for d in os.listdir(I18N_DIR)
        if os.path.isdir(os.path.join(I18N_DIR, d))
        and d not in _SKIP_DIRS
        and not d.startswith(".")
        and len(d) <= 6  # language codes are short: pl, pt-br, zh_TW
    )

# ============================================================================
# Validators
# ============================================================================
PH_RE = re.compile(r'\{[^}]*\}')
CMD_RE = re.compile(r"''[^']+?''")   # Double-quoted commands: ''trade'', ''job''
PIPE_RE = re.compile(r'\|[^|]+\|')
ARTIFACT_RE = re.compile(r'\?\?\?|\[[A-Z]{2,}(?:[-_][A-Z]{2,})?\]|TODO|FIXME')

def validate_key(en_text: str, tr_text: str, lang: str, key: str):
    """Run all validators V1–V7 + script-specific. Returns list of issues."""
    issues = []
    en = str(en_text or "")
    tr = str(tr_text or "")

    # Skip identical (proper nouns, not-translated)
    if tr == en:
        return []
    # Skip placeholders [LANG] ...
    if tr.startswith("[") and "]" in tr[:8]:
        return []

    # V3: Empty check — return early, no point validating empty string
    if not tr.strip():
        return [{"type": "V3_empty", "severity": "LOW"}]

    # V1: Placeholder match
    en_ph = set(PH_RE.findall(en))
    tr_ph = set(PH_RE.findall(tr))
    if en_ph != tr_ph:
        issues.append({"type": "V1_placeholder_mismatch", "severity": "CRITICAL"})

    # V5: Pipe token check
    en_pipe = set(PIPE_RE.findall(en))
    tr_pipe = set(PIPE_RE.findall(tr))
    if en_pipe != tr_pipe:
        issues.append({"type": "V5_pipe_mismatch", "severity": "CRITICAL"})

    # V7: Command check (double-quoted commands ''trade'', ''job'')
    en_cmd = set(CMD_RE.findall(en))
    if en_cmd:
        tr_cmd = set(CMD_RE.findall(tr))
        if en_cmd != tr_cmd:
            issues.append({"type": "V7_command_mismatch", "severity": "MEDIUM"})

    # V2: Length ratio
    en_len = len(en.strip())
    tr_len = len(tr.strip())
    if en_len > 3:
        ratio = tr_len / en_len
        if ratio < 0.2 or ratio > 5.0:
            issues.append({"type": "V2_length_ratio", "severity": "MEDIUM", "ratio": round(ratio, 3)})

    # V4: Artifact check
    if ARTIFACT_RE.search(tr):
        issues.append({"type": "V4_artifact", "severity": "HIGH"})

    # V6: Newline count
    en_nl = en.count("\\n") + en.count("\n")
    tr_nl = tr.count("\\n") + tr.count("\n")
    if en_nl > 0 and en_nl != tr_nl:
        issues.append({"type": "V6_newline_mismatch", "severity": "MEDIUM"})

    # === Script-specific ===
    lang_lc = lang.lower().replace("_", "-")
    group = LANG_SCRIPT_GROUP.get(lang_lc, "latin")

    if group == "cyrillic":
        clean = re.sub(r'[{}\d|%\s]', '', tr)
        if len(clean) > 5:
            latin_c = sum(1 for c in clean if c.isalpha() and ord(c) < 0x0400)
            total_a = sum(1 for c in clean if c.isalpha())
            if total_a > 3 and (latin_c / total_a) > 0.3:
                issues.append({"type": "script_cyrillic_latin_mix", "severity": "HIGH",
                               "ratio": round(latin_c / total_a, 3)})

    elif group == "cjk":
        if en_len > 3:
            ratio = tr_len / en_len
            if ratio < 0.15 or ratio > 2.5:
                issues.append({"type": "script_cjk_ratio", "severity": "MEDIUM",
                               "ratio": round(ratio, 3)})

    elif group == "rtl":
        clean = re.sub(r'[{}\d|%\s]', '', tr)
        if len(clean) > 5:
            rtl_c = sum(1 for c in clean if unicodedata.bidirectional(c) in ('R', 'AL', 'AN'))
            total = len(clean)
            if total > 3 and (rtl_c / total) < 0.3:
                issues.append({"type": "script_rtl_insufficient", "severity": "HIGH",
                               "ratio": round(rtl_c / total, 3)})

    elif group == "exotic":
        exp = EXPECTED_SCRIPTS.get(lang_lc)
        if exp:
            clean = re.sub(r'[{}\d|%\s]', '', tr)
            total_a = sum(1 for c in clean if c.isalpha())
            if total_a > 5:
                correct = sum(1 for c in clean if c.isalpha() and exp in unicodedata.name(c, ''))
                if (correct / total_a) < 0.4:
                    issues.append({"type": "script_wrong_script", "severity": "HIGH",
                                   "expected": exp, "ratio": round(correct / total_a, 3)})

    return issues

def _is_placeholder_like(value):
    txt = str(value or "")
    return txt.startswith("[") and "]" in txt[:8]

def _is_meaningful_translation(value, en_text):
    txt = str(value or "").strip()
    if not txt:
        return False
    if _is_placeholder_like(txt):
        return False
    if txt == str(en_text or ""):
        return False
    return True

def _map_gt_target(lang_code: str) -> str:
    norm = str(lang_code or "").replace("_", "-").lower()
    if norm == "he":
        return "iw"
    if norm == "zh-tw":
        return "zh-TW"
    if norm == "zh-cn":
        return "zh-CN"
    return norm

def _protect_special_tokens(text: str):
    src = str(text or "")
    token_map = {}
    token_idx = 0

    def _put_token(match):
        nonlocal token_idx
        token = f"__I18N_TOKEN_{token_idx}__"
        token_idx += 1
        token_map[token] = match.group(0)
        return token

    for pattern in (PH_RE, PIPE_RE, CMD_RE):
        src = pattern.sub(_put_token, src)
    return src, token_map

def _restore_special_tokens(text: str, token_map: dict):
    restored = str(text or "")
    for token, original in token_map.items():
        restored = restored.replace(token, original)
    return restored

# ============================================================================
# Run validation for each language
# ============================================================================
summary_langs = {}

for lang in langs_to_check:
    lang_dir = os.path.join(I18N_DIR, lang)
    if not os.path.isdir(lang_dir):
        continue

    lang_issues = []
    issue_types = Counter()
    total_keys = 0
    translated_keys = 0
    identical_to_en = 0
    placeholder_keys = 0
    worst_keys = []  # top 20 worst
    consistency_map = defaultdict(set)      # en_text -> set(translations)
    consistency_examples = defaultdict(list)  # en_text -> [cat:key]
    pl_reference_issues = []
    ratio_crossref_issues = []
    auto_fix_candidates = []
    autofix_attempted = 0
    autofix_applied = 0
    autofix_skipped = 0
    autofix_errors = 0

    for cat in categories:
        en_cat = en_data_all.get(cat, {})
        lang_file = os.path.join(lang_dir, f"{cat}.json")
        if not os.path.exists(lang_file):
            continue
        try:
            with open(lang_file, "r", encoding="utf-8") as f:
                lang_cat = json.load(f)
        except Exception:
            continue

        for key, en_val in en_cat.items():
            total_keys += 1
            tr_val = lang_cat.get(key)
            if tr_val is None:
                continue

            tr_str = str(tr_val)
            en_str = str(en_val)

            # Classification
            if tr_str.startswith("[") and "]" in tr_str[:8]:
                placeholder_keys += 1
                continue
            if tr_str == en_str:
                identical_to_en += 1

                if lang != "pl":
                    pl_val = pl_data_all.get(cat, {}).get(key)
                    if _is_meaningful_translation(pl_val, en_str):
                        pl_reference_issues.append({
                            "key": key,
                            "category": cat,
                            "type": "pl_reference_missing_translation",
                            "severity": "MEDIUM",
                            "en": en_str,
                            "pl": str(pl_val),
                            "lang": tr_str,
                        })
                        auto_fix_candidates.append({
                            "key": key,
                            "category": cat,
                            "en": en_str,
                        })

                # Still count as "translated" if it's a proper noun
                translated_keys += 1
                continue

            translated_keys += 1

            if en_str.strip():
                consistency_map[en_str].add(tr_str)
                if len(consistency_examples[en_str]) < 5:
                    consistency_examples[en_str].append(f"{cat}:{key}")

            if lang != "pl":
                pl_val = pl_data_all.get(cat, {}).get(key)
                if _is_meaningful_translation(pl_val, en_str):
                    en_len = len(en_str.strip())
                    if en_len > 3:
                        lang_ratio = len(tr_str.strip()) / en_len
                        pl_ratio = len(str(pl_val).strip()) / en_len
                        if abs(lang_ratio - pl_ratio) > 1.8:
                            ratio_crossref_issues.append({
                                "key": key,
                                "category": cat,
                                "type": "crossref_length_ratio_diff",
                                "severity": "MEDIUM",
                                "en_len": en_len,
                                "lang_ratio": round(lang_ratio, 3),
                                "pl_ratio": round(pl_ratio, 3),
                            })

            # Validate
            issues = validate_key(en_str, tr_str, lang, key)
            for iss in issues:
                issue_types[iss["type"]] += 1
                lang_issues.append({
                    "key": key,
                    "category": cat,
                    "type": iss["type"],
                    "severity": iss.get("severity", "LOW"),
                })

    # Score: 100 - penalties
    critical_count = sum(1 for i in lang_issues if i["severity"] == "CRITICAL")
    high_count = sum(1 for i in lang_issues if i["severity"] == "HIGH")
    medium_count = sum(1 for i in lang_issues if i["severity"] == "MEDIUM")
    low_count = sum(1 for i in lang_issues if i["severity"] == "LOW")

    penalty = (critical_count * 3 + high_count * 1.5 + medium_count * 0.3 + low_count * 0.05)
    # Score as percentage of translations without issues
    issue_rate = penalty / max(translated_keys, 1)
    score = max(0, min(100, 100 * (1 - issue_rate)))
    score = round(score, 1)

    coverage = round(translated_keys / max(total_keys, 1) * 100, 1)

    # ========================================================================
    # Phase 4: Cross-referencing checks (run only when lang coverage >= 30%)
    # ========================================================================
    consistency_issues = []
    if coverage >= 30 and lang != "pl":
        for en_text, variants in consistency_map.items():
            if len(variants) <= 1:
                continue
            consistency_issues.append({
                "type": "crossref_inconsistent_translation",
                "severity": "MEDIUM",
                "en": en_text,
                "variants": sorted(variants),
                "variants_count": len(variants),
                "examples": consistency_examples.get(en_text, [])[:5],
            })

    # Cap lists for report readability
    consistency_issues = sorted(consistency_issues, key=lambda x: x.get("variants_count", 0), reverse=True)[:200]
    pl_reference_issues = pl_reference_issues[:400]
    ratio_crossref_issues = ratio_crossref_issues[:400]

    crossref_total = len(consistency_issues) + len(pl_reference_issues) + len(ratio_crossref_issues)

    auto_fix_enabled = bool(AUTO_FIX_CROSSREF and USE_GOOGLE_TRANSLATE and coverage >= 30 and lang != "pl")
    if auto_fix_enabled and AUTO_FIX_CROSSREF_LIMIT > 0 and auto_fix_candidates:
        gt_lang = _map_gt_target(lang)
        try:
            from deep_translator import GoogleTranslator
            translator = GoogleTranslator(source='en', target=gt_lang)

            by_cat = defaultdict(list)
            for cand in auto_fix_candidates[:AUTO_FIX_CROSSREF_LIMIT]:
                by_cat[cand["category"]].append(cand)

            for cat, cands in by_cat.items():
                lang_file = os.path.join(lang_dir, f"{cat}.json")
                if not os.path.exists(lang_file):
                    autofix_skipped += len(cands)
                    continue
                try:
                    with open(lang_file, "r", encoding="utf-8") as f:
                        lang_cat_data = json.load(f)
                    if not isinstance(lang_cat_data, dict):
                        autofix_skipped += len(cands)
                        continue
                except Exception:
                    autofix_skipped += len(cands)
                    continue

                changed = False
                for i in range(0, len(cands), 20):
                    batch = cands[i:i + 20]
                    protected = []
                    token_maps = []
                    for c in batch:
                        ptxt, pmap = _protect_special_tokens(c["en"])
                        protected.append(ptxt)
                        token_maps.append(pmap)

                    try:
                        gt_results = translator.translate_batch(protected)
                    except Exception:
                        autofix_errors += len(batch)
                        continue

                    if isinstance(gt_results, str):
                        gt_results = [gt_results]
                    if not isinstance(gt_results, list):
                        gt_results = []

                    while len(gt_results) < len(batch):
                        gt_results.append("")

                    for cand, gt_text, token_map in zip(batch, gt_results, token_maps):
                        autofix_attempted += 1
                        restored = _restore_special_tokens(str(gt_text or ""), token_map).strip()
                        if not restored or restored == cand["en"].strip():
                            autofix_skipped += 1
                            continue

                        fix_issues = validate_key(cand["en"], restored, lang, cand["key"])
                        has_critical = any(i.get("severity") == "CRITICAL" for i in fix_issues)
                        if has_critical:
                            autofix_skipped += 1
                            continue

                        lang_cat_data[cand["key"]] = restored
                        autofix_applied += 1
                        changed = True

                if changed:
                    try:
                        tmp = lang_file + ".tmp"
                        with open(tmp, "w", encoding="utf-8") as f:
                            json.dump(lang_cat_data, f, indent=2, ensure_ascii=False)
                        os.replace(tmp, lang_file)
                    except Exception:
                        autofix_errors += 1
        except Exception:
            autofix_errors += len(auto_fix_candidates[:AUTO_FIX_CROSSREF_LIMIT])

    crossref_report = {
        "lang": lang,
        "coverage_pct": coverage,
        "crossref_enabled": bool(coverage >= 30 and lang != "pl"),
        "auto_fix_enabled": auto_fix_enabled,
        "auto_fix_limit": AUTO_FIX_CROSSREF_LIMIT,
        "checked_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "issues_total": crossref_total,
        "issues_by_type": {
            "consistency_in_language": len(consistency_issues),
            "pl_reference_missing_translation": len(pl_reference_issues),
            "length_ratio_crosscheck": len(ratio_crossref_issues),
        },
        "consistency_issues": consistency_issues,
        "pl_reference_issues": pl_reference_issues,
        "length_ratio_issues": ratio_crossref_issues,
        "auto_fix": {
            "attempted": autofix_attempted,
            "applied": autofix_applied,
            "skipped": autofix_skipped,
            "errors": autofix_errors,
        },
    }

    crossref_path = os.path.join(val_dir, f"{lang}_crossref.json")
    try:
        tmp = crossref_path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(crossref_report, f, indent=2, ensure_ascii=False)
        os.replace(tmp, crossref_path)
    except Exception:
        pass

    # worst keys (by severity)
    sev_order = {"CRITICAL": 4, "HIGH": 3, "MEDIUM": 2, "LOW": 1}
    worst_keys = sorted(lang_issues, key=lambda x: sev_order.get(x["severity"], 0), reverse=True)[:20]

    group = LANG_SCRIPT_GROUP.get(lang.lower().replace("_", "-"), "latin")

    report = {
        "lang": lang,
        "script_group": group,
        "total_keys": total_keys,
        "translated": translated_keys,
        "identical_to_en": identical_to_en,
        "placeholder_keys": placeholder_keys,
        "coverage_pct": coverage,
        "issues_total": len(lang_issues),
        "issues_by_type": dict(issue_types.most_common()),
        "issues_by_severity": {
            "CRITICAL": critical_count,
            "HIGH": high_count,
            "MEDIUM": medium_count,
            "LOW": low_count,
        },
        "score": score,
        "worst_keys": worst_keys,
        "crossref": {
            "enabled": bool(coverage >= 30 and lang != "pl"),
            "issues_total": crossref_total,
            "consistency": len(consistency_issues),
            "pl_reference": len(pl_reference_issues),
            "length_ratio": len(ratio_crossref_issues),
            "auto_fix_applied": autofix_applied,
        },
        "validated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }

    # Save per-lang report
    report_path = os.path.join(val_dir, f"{lang}_report.json")
    try:
        tmp = report_path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        os.replace(tmp, report_path)
    except Exception:
        pass

    summary_langs[lang] = {
        "score": score,
        "coverage_pct": coverage,
        "issues": len(lang_issues),
        "critical": critical_count,
        "high": high_count,
        "crossref_issues": crossref_total,
        "crossref_autofix_applied": autofix_applied,
        "translated": translated_keys,
        "script_group": group,
    }

# ============================================================================
# Summary report
# ============================================================================
summary = {
    "total_languages": len(summary_langs),
    "total_en_keys": total_en_keys,
    "validated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "by_score": dict(sorted(summary_langs.items(), key=lambda x: x[1]["score"])),
    "avg_score": round(
        sum(v["score"] for v in summary_langs.values()) / max(len(summary_langs), 1), 1
    ),
    "by_group": {},
}

# Group stats
groups = defaultdict(list)
for lg, info in summary_langs.items():
    groups[info["script_group"]].append(lg)
summary["by_group"] = {g: sorted(ls) for g, ls in groups.items()}
summary["crossref_total_issues"] = int(sum(v.get("crossref_issues", 0) for v in summary_langs.values()))
summary["crossref_autofix_total_applied"] = int(sum(v.get("crossref_autofix_applied", 0) for v in summary_langs.values()))

summary_path = os.path.join(val_dir, "summary.json")
try:
    tmp = summary_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    os.replace(tmp, summary_path)
except Exception:
    pass

# Output for bash
langs_checked = len(summary_langs)
total_issues = sum(v["issues"] for v in summary_langs.values())
total_critical = sum(v["critical"] for v in summary_langs.values())
avg_score = summary.get("avg_score", 0)
autofix_total = summary.get("crossref_autofix_total_applied", 0)

# Worst 5 languages
worst5 = sorted(summary_langs.items(), key=lambda x: x[1]["score"])[:5]
worst_str = ", ".join(f"{l}({v['score']})" for l, v in worst5)

print(f"__LANGVAL__ langs={langs_checked} issues={total_issues} critical={total_critical} avg_score={avg_score} crossref_autofix={autofix_total} worst={worst_str}")
LANG_VALIDATION_PY
) 2>&1

    # Parse output
    local val_line
    val_line=$(echo "$_val_out" | grep "__LANGVAL__" | tail -1)
    if [ -n "$val_line" ]; then
        local langs_checked issues critical avg_score worst crossref_autofix
        langs_checked=$(echo "$val_line" | sed -n 's/.*langs=\([^ ]*\).*/\1/p')
        issues=$(echo "$val_line" | sed -n 's/.*issues=\([^ ]*\).*/\1/p')
        critical=$(echo "$val_line" | sed -n 's/.*critical=\([^ ]*\).*/\1/p')
        avg_score=$(echo "$val_line" | sed -n 's/.*avg_score=\([^ ]*\).*/\1/p')
        crossref_autofix=$(echo "$val_line" | sed -n 's/.*crossref_autofix=\([^ ]*\).*/\1/p')
        log "${GREEN}✅ LANG VALIDATION: ${langs_checked} języków, ${issues} problemów (${critical} krytycznych), avg score: ${avg_score}${NC}"
        if [ "${crossref_autofix:-0}" -gt 0 ] 2>/dev/null; then
            log "${GREEN}🛠️ CROSSREF AUTO-FIX: zastosowano ${crossref_autofix} poprawek${NC}"
        fi
    else
        log "${YELLOW}⚠️ LANG VALIDATION: brak wyniku${NC}" >&2
    fi
}

#===============================================================================
# CYKLICZNY AUDYT JAKOŚCI (co N cykli)
#===============================================================================
# Analizuje ostatnie tłumaczenia z quality_report.jsonl
# Sprawdza wzorce, powtórzenia cross-language, anomalie
# Wynik: quality_audit_latest.json + quality_dashboard.json
#===============================================================================
QUALITY_AUDIT_INTERVAL="${QUALITY_AUDIT_INTERVAL:-10}"  # co ile cykli
LAST_QUALITY_AUDIT_CYCLE=0

run_quality_audit() {
    local current_cycle="${1:-0}"
    
    # Sprawdź czy pora na audyt
    local cycles_since=$(( current_cycle - LAST_QUALITY_AUDIT_CYCLE ))
    if [ "$cycles_since" -lt "$QUALITY_AUDIT_INTERVAL" ] && [ "$LAST_QUALITY_AUDIT_CYCLE" -gt 0 ]; then
        return 0
    fi
    
    log "${CYAN}🔬 QUALITY AUDIT: Uruchamiam cykliczny audyt jakości (cykl $current_cycle)...${NC}"
    LAST_QUALITY_AUDIT_CYCLE=$current_cycle
    
    local _audit_out
    _audit_out=$(python3 << 'QUALITY_AUDIT_PY'
import os
import json
import re
from datetime import datetime, timezone
from collections import Counter, defaultdict

STATUS_DIR = "i18n/status"
I18N_DIR = "i18n"

# ============================================================================
# 1. Wczytaj ostatnie wpisy z quality_report.jsonl
# ============================================================================
quality_log_path = os.path.join(STATUS_DIR, "quality_report.jsonl")
recent_report_path = os.path.join(STATUS_DIR, "translation_recent_report.jsonl")

quality_entries = []
if os.path.exists(quality_log_path):
    try:
        with open(quality_log_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        # Ostatnie 200 wpisów
        for line in lines[-200:]:
            line = line.strip()
            if line:
                try:
                    quality_entries.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    except Exception:
        pass

# Wczytaj ostatnie wpisy z translation_recent_report.jsonl
recent_entries = []
if os.path.exists(recent_report_path):
    try:
        with open(recent_report_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        for line in lines[-100:]:
            line = line.strip()
            if line:
                try:
                    recent_entries.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    except Exception:
        pass

# ============================================================================
# 2. Analiza metryka jakości
# ============================================================================
issues = []

# 2a. Anomalie length_ratio per-język
lang_ratios = defaultdict(list)
for entry in quality_entries:
    q = entry.get("quality", {})
    lang = entry.get("language", "")
    lr = q.get("length_ratio", 1.0)
    if lang and lr:
        lang_ratios[lang].append(lr)

for lang, ratios in lang_ratios.items():
    if len(ratios) < 3:
        continue
    avg_ratio = sum(ratios) / len(ratios)
    if avg_ratio < 0.5 or avg_ratio > 3.0:
        issues.append({
            "type": "persistent_length_anomaly",
            "severity": "HIGH",
            "lang": lang,
            "avg_ratio": round(avg_ratio, 3),
            "samples": len(ratios),
            "message": f"Język {lang} ma trwale nieprawidłowy ratio długości: {avg_ratio:.2f}",
        })

# 2b. Wysoki wskaźnik odrzuceń per-język
lang_reject_rate = defaultdict(lambda: {"translated": 0, "rejected": 0, "gt_fail": 0})
for entry in quality_entries:
    q = entry.get("quality", {})
    lang = entry.get("language", "")
    t = entry.get("translated", 0)
    r = q.get("suspicious_rejected", 0)
    gf = q.get("gt_guard_fails", 0)
    lang_reject_rate[lang]["translated"] += t
    lang_reject_rate[lang]["rejected"] += r
    lang_reject_rate[lang]["gt_fail"] += gf

for lang, stats in lang_reject_rate.items():
    total = stats["translated"]
    rejected = stats["rejected"]
    gt_fail = stats["gt_fail"]
    if total >= 10:
        reject_pct = (rejected / total) * 100
        gt_fail_pct = (gt_fail / total) * 100
        if reject_pct > 15:
            issues.append({
                "type": "high_reject_rate",
                "severity": "HIGH",
                "lang": lang,
                "reject_pct": round(reject_pct, 1),
                "translated": total,
                "rejected": rejected,
                "message": f"Język {lang}: {reject_pct:.1f}% tłumaczeń odrzuconych ({rejected}/{total})",
            })
        if gt_fail_pct > 20:
            issues.append({
                "type": "high_gt_fail_rate",
                "severity": "MEDIUM",
                "lang": lang,
                "gt_fail_pct": round(gt_fail_pct, 1),
                "gt_fail": gt_fail,
                "message": f"Język {lang}: {gt_fail_pct:.1f}% GT odrzuceń ({gt_fail}/{total})",
            })

# 2c. Cross-language duplikaty — ten sam EN→TRANSLATED w 5+ językach
translation_map = defaultdict(set)  # en_text → set of (lang, translated)
for entry in recent_entries:
    for item in entry.get("entries", []):
        en = str(item.get("en", "")).strip()
        tr = str(item.get("translated", "")).strip()
        lang = entry.get("language", "")
        if en and tr and lang and en != tr:
            translation_map[en].add((lang, tr))

for en_text, lang_translations in translation_map.items():
    # Sprawdź czy wiele języków ma identyczne tłumaczenie
    tr_to_langs = defaultdict(list)
    for lang, tr in lang_translations:
        tr_to_langs[tr].append(lang)
    for tr, langs in tr_to_langs.items():
        if len(langs) >= 4 and tr != en_text:
            issues.append({
                "type": "cross_lang_duplicate",
                "severity": "MEDIUM",
                "en": en_text[:80],
                "translated": tr[:80],
                "langs": langs[:6],
                "count": len(langs),
                "message": f"To samo tłumaczenie \"{tr[:40]}\" w {len(langs)} językach — prawdopodobnie nietłumaczone",
            })

# 2d. Tłumaczenia zawierające artefakty z danych historycznych
suspicious_log_path = os.path.join(STATUS_DIR, "suspicious_log.jsonl")
suspicious_count_by_type = Counter()
if os.path.exists(suspicious_log_path):
    try:
        with open(suspicious_log_path, "r", encoding="utf-8") as f:
            for line in f.readlines()[-500:]:
                line = line.strip()
                if line:
                    try:
                        entry = json.loads(line)
                        for issue in entry.get("issues", []):
                            suspicious_count_by_type[issue.get("type", "unknown")] += 1
                    except json.JSONDecodeError:
                        pass
    except Exception:
        pass

# 2e. Podsumowanie źródeł tłumaczeń
source_totals = Counter()
for entry in quality_entries:
    q = entry.get("quality", {})
    for src, count in q.get("source_breakdown", {}).items():
        source_totals[src] += count

# ============================================================================
# 3. Budowa raportu audytu
# ============================================================================
severity_order = {"CRITICAL": 4, "HIGH": 3, "MEDIUM": 2, "LOW": 1}
issues.sort(key=lambda x: -severity_order.get(x.get("severity", "LOW"), 0))

audit_report = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "checked_quality_entries": len(quality_entries),
    "checked_recent_entries": len(recent_entries),
    "issues_found": len(issues),
    "issues_by_severity": {
        "CRITICAL": sum(1 for i in issues if i.get("severity") == "CRITICAL"),
        "HIGH": sum(1 for i in issues if i.get("severity") == "HIGH"),
        "MEDIUM": sum(1 for i in issues if i.get("severity") == "MEDIUM"),
        "LOW": sum(1 for i in issues if i.get("severity") == "LOW"),
    },
    "issues_by_type": dict(Counter(i.get("type", "unknown") for i in issues)),
    "source_breakdown_total": dict(source_totals),
    "suspicious_by_type_total": dict(suspicious_count_by_type),
    "issues": issues[:50],  # Top 50 issues
}

# Zapisz audit
os.makedirs(STATUS_DIR, exist_ok=True)
audit_path = os.path.join(STATUS_DIR, "quality_audit_latest.json")
try:
    import tempfile
    fd, tmp = tempfile.mkstemp(dir=STATUS_DIR, suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(audit_report, f, indent=2, ensure_ascii=False)
    os.replace(tmp, audit_path)
except Exception as e:
    try: os.unlink(tmp)
    except: pass
    print(f"⚠️ Nie udało się zapisać audytu: {e}")

# Zapisz historię audytów (JSONL)
try:
    audit_history_path = os.path.join(STATUS_DIR, "quality_audit_history.jsonl")
    summary = {
        "timestamp": audit_report["timestamp"],
        "issues_found": audit_report["issues_found"],
        "issues_by_severity": audit_report["issues_by_severity"],
    }
    with open(audit_history_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(summary, ensure_ascii=False) + "\n")
except Exception:
    pass

# ============================================================================
# 4. Output
# ============================================================================
print(f"🔬 QUALITY AUDIT: Sprawdzono {len(quality_entries)} wpisów jakości, {len(recent_entries)} ostatnich tłumaczeń")
print(f"   Znaleziono problemów: {len(issues)} (CRITICAL: {audit_report['issues_by_severity']['CRITICAL']}, HIGH: {audit_report['issues_by_severity']['HIGH']}, MEDIUM: {audit_report['issues_by_severity']['MEDIUM']})")

if source_totals:
    parts = [f"{src}={cnt}" for src, cnt in source_totals.most_common()]
    print(f"   Źródła tłumaczeń: {', '.join(parts)}")

if suspicious_count_by_type:
    parts = [f"{t}={c}" for t, c in suspicious_count_by_type.most_common(5)]
    print(f"   Top podejrzane typy: {', '.join(parts)}")

for issue in issues[:5]:
    sev = issue.get("severity", "?")
    msg = issue.get("message", "?")
    print(f"   [{sev}] {msg}")

if len(issues) > 5:
    print(f"   ... i {len(issues) - 5} więcej (szczegóły: {audit_path})")

# Return code for bash
if audit_report["issues_by_severity"]["CRITICAL"] > 0:
    print("__AUDIT_RESULT__ CRITICAL")
elif audit_report["issues_by_severity"]["HIGH"] > 3:
    print("__AUDIT_RESULT__ HIGH")
elif len(issues) > 10:
    print("__AUDIT_RESULT__ WARN")
else:
    print("__AUDIT_RESULT__ OK")
QUALITY_AUDIT_PY
    ) 2>&1
    local _audit_rc=$?
    
    echo "$_audit_out" >&2
    
    # Sprawdź wynik audytu
    local _audit_result
    _audit_result=$(printf '%s\n' "$_audit_out" | grep '__AUDIT_RESULT__' | tail -n 1 | awk '{print $2}')
    
    case "$_audit_result" in
        CRITICAL)
            log "${RED}🚨 QUALITY AUDIT: Znaleziono KRYTYCZNE problemy jakości!${NC}"
            # Zmniejsz batch na następne cykle
            if [ "${TRANSLATE_LIMIT:-20}" -gt 5 ]; then
                export TRANSLATE_LIMIT=5
                log "${YELLOW}⚠️ Zmniejszono batch do 5 z powodu problemów jakości${NC}"
            fi
            ;;
        HIGH)
            log "${YELLOW}⚠️ QUALITY AUDIT: Znaleziono poważne problemy jakości${NC}"
            ;;
        WARN)
            log "${YELLOW}📊 QUALITY AUDIT: Kilka problemów do sprawdzenia${NC}"
            ;;
        *)
            log "${GREEN}✅ QUALITY AUDIT: Jakość OK${NC}"
            ;;
    esac
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

# Zbierz statystyki — dynamicznie z i18n/en/
stats = {
    "npc_files": 0,
    "total_keys": 0,
    "translations": {},
    "quality_issues": 0
}

en_dir = os.path.join(I18N_DIR, "en")
if not os.path.exists(en_dir):
    print("⚠️ Brak katalogu i18n/en")
    exit(0)

all_categories = [f[:-5] for f in sorted(os.listdir(en_dir)) if f.endswith('.json')]

# Zlicz klucze z EN
en_data = {}
for cat in all_categories:
    fpath = os.path.join(en_dir, f"{cat}.json")
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        en_data[cat] = data
        stats["npc_files"] += 1
        stats["total_keys"] += len(data)
    except:
        pass

# Zlicz tłumaczenia w każdym języku
for lang_dir in os.listdir(I18N_DIR):
    lang_path = os.path.join(I18N_DIR, lang_dir)
    if not os.path.isdir(lang_path) or lang_dir == 'en':
        continue
    lang_translated = 0
    for cat in all_categories:
        lang_file = os.path.join(lang_path, f"{cat}.json")
        if not os.path.exists(lang_file):
            continue
        try:
            with open(lang_file, 'r', encoding='utf-8') as f:
                lang_data = json.load(f)
            en_keys = en_data.get(cat, {})
            translated = sum(1 for k, v in lang_data.items() if v and v != en_keys.get(k, ''))
            lang_translated += translated
        except:
            pass
    if lang_translated > 0:
        stats["translations"][lang_dir] = lang_translated

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
    status_update_activity "running" "${CYCLE:-0}" "VALIDATION" "validation_start" "-" "-" "quality validation" 0 0 "steps" 0
    validate_translation_quality
    status_update_activity "running" "${CYCLE:-0}" "VALIDATION" "validation_done" "-" "-" "validation complete" 0 0 "steps" 0
    
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
    export DISPATCHER_LANG_PRIORITY="$LANG_PRIORITY"
    export DISPATCHER_TARGET_LANGS="$TARGET_LANGS"
    python3 << 'DISPATCHERPY'
import os
import json
import glob
import re

I18N_DIR = "i18n"

def _split_langs(raw):
    if not raw:
        return []
    parts = re.split(r"[\s,;]+", raw.strip())
    out = []
    seen = set()
    for p in parts:
        if not p:
            continue
        lang = p.strip()
        if lang.lower() == "en":
            continue
        if lang not in seen:
            out.append(lang)
            seen.add(lang)
    return out

def _list_language_dirs(i18n_dir):
    langs = []
    seen = set()
    if not os.path.isdir(i18n_dir):
        return langs
    for name in sorted(os.listdir(i18n_dir)):
        p = os.path.join(i18n_dir, name)
        if not os.path.isdir(p):
            continue
        if name == "en":
            continue
        if re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            if name not in seen:
                langs.append(name)
                seen.add(name)
    return langs

DEFAULT_TARGET_LANGUAGES = [
    "de", "pl", "es", "pt", "fr", "it", "nl", "cs", "sk", "hu",
    "sv", "da", "no", "fi", "et", "lv", "lt", "ro", "bg", "el",
    "hr", "sl", "bs", "sr", "mk", "sq", "ru", "uk", "kk", "uz",
    "az", "hy", "ka", "tr", "ar", "he", "fa", "zh", "zh_TW", "ja",
    "ko", "hi", "th", "vi", "id", "ms", "tl", "bn", "ta", "te",
    "ml", "sw"
]

priority_from_env = _split_langs(os.environ.get("DISPATCHER_LANG_PRIORITY", ""))
if not priority_from_env:
    priority_from_env = ["de", "pl", "es", "pt", "fr", "it", "ru", "nl", "sv", "cs"]

langs_override = _split_langs(os.environ.get("DISPATCHER_TARGET_LANGS", ""))
langs_from_dirs = _list_language_dirs(I18N_DIR)

if langs_override:
    TARGET_LANGUAGES = langs_override
elif langs_from_dirs:
    ranked = []
    for l in priority_from_env:
        if l in langs_from_dirs and l not in ranked:
            ranked.append(l)
    for l in langs_from_dirs:
        if l not in ranked:
            ranked.append(l)
    TARGET_LANGUAGES = ranked
else:
    TARGET_LANGUAGES = DEFAULT_TARGET_LANGUAGES

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

# ============ HARD GATE — P0.2 Dispatcher transition guards ============

PHASE_ORDER = ["MIGRATION", "COMPACT_KEYS", "TRANSLATION_SYNC", "AUTO_TRANSLATE", "IDLE"]

def _phase_rank(phase):
    """Numerical rank of a phase; higher = later in pipeline."""
    p = str(phase or "").upper()
    try:
        return PHASE_ORDER.index(p)
    except ValueError:
        return -1

def _load_last_phase():
    """Load the last committed phase from dispatcher state."""
    try:
        dp = os.path.join(I18N_DIR, "status", "translation_dispatch_state.json")
        if os.path.exists(dp):
            with open(dp, "r", encoding="utf-8") as f:
                ds = json.load(f)
            return str(ds.get("last_phase", "")).upper() or None
    except Exception:
        pass
    return None

def _log_transition(from_phase, to_phase, gate_result, reason=""):
    """Append transition event to JSONL log."""
    import time as _tm
    entry = {
        "ts": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "from": str(from_phase or ""),
        "to": str(to_phase or ""),
        "gate": gate_result,  # "pass" | "block" | "forced"
        "reason": str(reason or ""),
    }
    try:
        log_path = os.path.join(I18N_DIR, "status", "transition_log.jsonl")
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass

def transition_gate(target_phase, cat_state, force=False):
    """Check hard gate conditions for transitioning to target_phase.
    Returns (allowed: bool, reason: str).
    If force=True, logs as 'forced' and always allows.
    """
    target = str(target_phase or "").upper()
    last_phase = _load_last_phase() or "MIGRATION"
    last_rank = _phase_rank(last_phase)
    target_rank = _phase_rank(target)

    # Rule 1: backwards movement is blocked (unless forced)
    if target_rank >= 0 and last_rank >= 0 and target_rank < last_rank:
        if not force:
            reason = f"backwards {last_phase}→{target} blocked (rank {last_rank}→{target_rank})"
            _log_transition(last_phase, target, "block", reason)
            return False, reason

    # Rule 2: MIGRATION → COMPACT_KEYS requires migrations_done
    if target == "COMPACT_KEYS":
        if not cat_state.get("migrations_done", False):
            reason = "COMPACT_KEYS blocked: migrations_done=False"
            if not force:
                _log_transition(last_phase, target, "block", reason)
                return False, reason

    # Rule 3: TRANSLATION_SYNC requires migrations_done
    if target == "TRANSLATION_SYNC":
        if not cat_state.get("migrations_done", False):
            reason = "TRANSLATION_SYNC blocked: migrations_done=False"
            if not force:
                _log_transition(last_phase, target, "block", reason)
                return False, reason

    # Rule 4: AUTO_TRANSLATE requires migrations_done (sync is optional — can translate what exists)
    if target == "AUTO_TRANSLATE":
        if not cat_state.get("migrations_done", False):
            reason = "AUTO_TRANSLATE blocked: migrations_done=False"
            if not force:
                _log_transition(last_phase, target, "block", reason)
                return False, reason

    gate_label = "forced" if force else "pass"
    _log_transition(last_phase, target, gate_label, "")
    return True, ""

def _commit_phase(phase):
    """Save the current phase to dispatcher state for future gate checks."""
    try:
        dp = os.path.join(I18N_DIR, "status", "translation_dispatch_state.json")
        ds = {}
        if os.path.exists(dp):
            with open(dp, "r", encoding="utf-8") as f:
                ds = json.load(f)
        ds["last_phase"] = str(phase or "").upper()
        ds["last_phase_ts"] = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
        tmp = dp + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(ds, f, indent=2, ensure_ascii=False)
        os.replace(tmp, dp)
    except Exception:
        pass

from datetime import datetime

# ============ GŁÓWNA LOGIKA DISPATCHERA ============

# 0. Sprawdź komendy sterowania
cmd = read_command()
if cmd:
    if cmd.startswith("FORCE:"):
        # Wymuś kategorię: FORCE:monsters lub FORCE:translation
        forced_cat = cmd.split(":")[1]
        
        # FORCE:translation - wymuś przejście do synchronizacji tłumaczeń
        if forced_cat == "translation":
            _log_transition(_load_last_phase() or "?", "TRANSLATION_SYNC", "forced", f"FORCE:{forced_cat}")
            _commit_phase("TRANSLATION_SYNC")
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
        _commit_phase("MIGRATION")
        print(f"MIGRATION:{cat_name}:{needs_work}")
        exit(0)

# Jeśli są kategorie na skip/backoff, nie przechodź do TRANSLATION_SYNC
if pending_skip:
    cat_state["migrations_done"] = False
    write_category_state(cat_state)
    if skip_has_work or total_needs > 0:
        _commit_phase("MIGRATION")
        print(f"MIGRATION:pending_skip:{total_needs}:WAIT")
        exit(0)
    # jeśli nie ma realnej pracy, pozwól przejść dalej

# Jeśli tu doszliśmy: brak pracy migracyjnej → uznaj migracje za zakończone
cat_state["migrations_done"] = True
write_category_state(cat_state)
_log_transition("MIGRATION", "post-migration", "pass", "all categories done")

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
    allowed, gate_reason = transition_gate("COMPACT_KEYS", cat_state)
    if not allowed:
        # Gate blocked — fall back to MIGRATION
        print(f"MIGRATION:gate_blocked:0:{gate_reason}")
        exit(0)
    _commit_phase("COMPACT_KEYS")
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
            # Hard gate check before TRANSLATION_SYNC
            allowed, gate_reason = transition_gate("TRANSLATION_SYNC", cat_state)
            if not allowed:
                print(f"MIGRATION:gate_blocked:0:{gate_reason}")
                exit(0)
            _commit_phase("TRANSLATION_SYNC")
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
    _commit_phase("IDLE")
    _log_transition("TRANSLATION_SYNC", "IDLE", "pass", "all_synced")
    print("IDLE:all_synced:0")
else:
    # Coś poszło nie tak - powtórz od początku
    print(f"TRANSLATION_SYNC:{TARGET_LANGUAGES[0]}:{json_files[0]}:retry")
DISPATCHERPY
}

select_translation_sync_target() {
    export TARGET_LANGS
    export LANG_PRIORITY
    python3 << 'SYNCSELECTPY'
import json
import os
import re

I18N_DIR = "i18n"

def split_langs(raw):
    if not raw:
        return []
    parts = re.split(r"[\s,;]+", raw.strip())
    out = []
    seen = set()
    for p in parts:
        if not p:
            continue
        lang = p.strip()
        if lang.lower() == "en":
            continue
        if lang not in seen:
            out.append(lang)
            seen.add(lang)
    return out

def list_language_dirs(i18n_dir):
    langs = []
    seen = set()
    if not os.path.isdir(i18n_dir):
        return langs
    for name in sorted(os.listdir(i18n_dir)):
        p = os.path.join(i18n_dir, name)
        if not os.path.isdir(p):
            continue
        if name == "en":
            continue
        if re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            if name not in seen:
                langs.append(name)
                seen.add(name)
    return langs

def count_missing_keys(lang, json_file):
    en_path = os.path.join(I18N_DIR, "en", json_file)
    lang_path = os.path.join(I18N_DIR, lang, json_file)
    if not os.path.exists(en_path):
        return 0
    try:
        with open(en_path, encoding="utf-8") as f:
            en_data = json.load(f)
        if not os.path.exists(lang_path):
            return len(en_data)
        with open(lang_path, encoding="utf-8") as f:
            lang_data = json.load(f)
        return sum(1 for key in en_data if key not in lang_data)
    except Exception:
        return 0

priority = split_langs(os.environ.get("LANG_PRIORITY", ""))
targets = split_langs(os.environ.get("TARGET_LANGS", ""))
if not targets:
    langs_from_dirs = list_language_dirs(I18N_DIR)
    if langs_from_dirs:
        ranked = [l for l in priority if l in langs_from_dirs]
        ranked += [l for l in langs_from_dirs if l not in ranked]
        targets = ranked

if not targets:
    targets = ["pl"]

en_dir = os.path.join(I18N_DIR, "en")
json_files = []
if os.path.isdir(en_dir):
    json_files = sorted([f for f in os.listdir(en_dir) if f.endswith(".json")])
if not json_files:
    json_files = ["npc.json"]

en_data_by_file = {}
for json_file in json_files:
    en_path = os.path.join(I18N_DIR, "en", json_file)
    if not os.path.exists(en_path):
        continue
    try:
        with open(en_path, encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            en_data_by_file[json_file] = data
    except Exception:
        continue

for lang in targets:
    for json_file in json_files:
        en_data = en_data_by_file.get(json_file)
        if not isinstance(en_data, dict):
            continue
        lang_path = os.path.join(I18N_DIR, lang, json_file)
        if not os.path.exists(lang_path):
            missing = len(en_data)
        else:
            try:
                with open(lang_path, encoding="utf-8") as f:
                    lang_data = json.load(f)
                missing = sum(1 for key in en_data if key not in lang_data)
            except Exception:
                missing = 0
        if missing > 0:
            print(f"{lang}:{json_file}:{missing}")
            raise SystemExit(0)

print(f"{targets[0]}:{json_files[0]}:0")
SYNCSELECTPY
}

select_auto_translate_target_strict() {
    export TARGET_LANGS
    export LANG_PRIORITY
    export BOOTSTRAP_PRIORITY_LANGS
    export STATUS_DIR
    export CURRENT_CYCLE
    export STRICT_SELECTOR_CACHE_TTL_CYCLES
    export TIER1_LANGS TIER2_LANGS TIER1_WEIGHT TIER2_WEIGHT TIER3_WEIGHT
    export CATEGORY_TRANSLATE_PRIORITY
    python3 << 'AUTOSTRICTPY'
import json
import os
import re
from datetime import datetime, timezone

I18N_DIR = "i18n"
status_dir = os.environ.get("STATUS_DIR", "i18n/status")
dispatch_state_path = os.path.join(status_dir, "translation_dispatch_state.json")
guard_latest_path = os.path.join(status_dir, "translation_guard_latest.json")
selector_cache_path = os.path.join(status_dir, "translation_strict_candidates_cache.json")

def _to_int(value, default=0):
    try:
        return int(value)
    except Exception:
        return default

current_cycle = _to_int(os.environ.get("CURRENT_CYCLE", "0"), 0)
cache_ttl_cycles = max(1, _to_int(os.environ.get("STRICT_SELECTOR_CACHE_TTL_CYCLES", "5"), 5))

def split_langs(raw):
    if not raw:
        return []
    parts = re.split(r"[\s,;]+", raw.strip())
    out = []
    seen = set()
    for p in parts:
        if not p:
            continue
        lang = p.strip()
        if lang.lower() == "en":
            continue
        if lang not in seen:
            out.append(lang)
            seen.add(lang)
    return out

def list_language_dirs(i18n_dir):
    langs = []
    if not os.path.isdir(i18n_dir):
        return langs
    for name in sorted(os.listdir(i18n_dir)):
        p = os.path.join(i18n_dir, name)
        if not os.path.isdir(p) or name == "en":
            continue
        if re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            langs.append(name)
    return langs

def _is_likely_proper_noun(key, en_value):
    """Heurystyka: klucz, którego wartość EN jest prawdopodobnie nazwą własną
    i identyczne tłumaczenie jest poprawne (nie wymaga tłumaczenia)."""
    # Nazwy przedmiotów, potworów, zaklęć, questów — często nie tłumaczymy
    proper_noun_prefixes = (
        "item.", "monster.", "spell.", "mount.", "quest.", "raid.",
        "achievement.", "npc.", "book.otbm."
    )
    proper_noun_suffixes = (".name", ".words", ".title", ".desc", ".announce")

    if any(key.startswith(p) for p in proper_noun_prefixes):
        if any(key.endswith(s) for s in proper_noun_suffixes):
            return True
        # Short text (1-4 words) starting with uppercase = likely a proper name
        words = en_value.strip().split()
        if words and len(words) <= 4 and words[0][0:1].isupper():
            return True

    # Krótkie wartości (<=3 znaki) typu "No", "Mana" — prawdopodobnie nazwy/komendy
    if len(en_value.strip()) <= 3:
        return True

    # Wartość jest tylko wielką literą/cyframi/znakami specjalnymi (skrót, kod)
    stripped = en_value.strip()
    if stripped and all(c.isupper() or c.isdigit() or c in ".-_/ " for c in stripped):
        return True

    # === Game-specific nontranslatable: fictional languages, animal sounds ===
    _animal_patterns = ('GRRR', 'YOOO', 'ZZZZ', 'ROAR', 'HISS', 'SNARL', 'RAWR',
                        'HOWL', 'GROWL', 'SCREE', 'CLANK', 'BOOM')
    if any(p in stripped.upper() for p in _animal_patterns):
        return True
    _fictional_words = re.compile(
        r'\b(?:gort|utash|karek|booz|omark|ikem|goshak|torilu[nm]?|garnum|'
        r'saethelon|zathroth|uthun|nortat|urghh?|brakka|morda|chakka|'
        r'batuk|goshak|charach|galunda|mugrah|gorak|shakk|uurgh|'
        r'tanjil|lanar|kull|ogar|azarak)\b', re.IGNORECASE
    )
    if _fictional_words.search(stripped):
        return True
    # Nonsensowne sylaby (fikcyjny język) — >=3 "słowa" ≤6 liter, brak angielskich
    words_re = re.findall(r'[A-Za-z]+', stripped)
    if len(words_re) >= 3:
        _common_en = {
            'a','i','an','am','as','at','be','by','do','go','he','if','in','is','it','me','my','no',
            'of','on','or','so','to','up','us','we','the','and','are','but','can','did','for','get',
            'got','had','has','her','him','his','how','its','let','may','new','nor','not','now','old',
            'one','our','out','own','put','ran','run','saw','say','set','she','sit','too','try',
            'two','use','was','way','who','why','win','won','yes','yet','you','all','any','ask','bad',
            'big','bit','boy','buy','cut','day','eat','end','far','few','fly','fun','god','hat','hit',
            'hot','job','key','lay','led','lie','lot','low','man','map','men','met','mix','off',
            'oil','pay','per','red','rid','sad','six','son','ten','top','war','wet',
            'able','also','back','been','best','body','both','call','came','case','come','could','each',
            'even','fact','feel','find','first','from','gave','give','goes','gone','good','great',
            'hand','have','head','help','here','high','home','hope','into','just','keep','kind','knew',
            'know','last','left','life','like','line','live','long','look','lost','made','make','many',
            'mind','more','most','much','must','name','need','next','only','open','over','part','plan',
            'play','real','rest','room','said','same','seem','show','side','some','soon','stop','such',
            'sure','take','talk','tell','than','that','them','then','they','this','time','told','took',
            'turn','upon','very','walk','want','well','went','were','what','when','will','with','word',
            'work','year','your','about','after','again','being','below','bring','carry','cause',
            'close','doing','don','every','found','going','house','human','large','later','leave',
            'light','might','money','never','night','often','order','other','place','point','right',
            'shall','should','since','small','sorry','start','still','story','study','thank','their',
            'there','these','thing','think','those','three','today','under','until','watch','water',
            'where','which','while','world','would','write','young','really','little','around',
            'before','always','people','already',
        }
        en_count = sum(1 for w in words_re if w.lower() in _common_en)
        if en_count == 0 and all(len(w) <= 6 for w in words_re):
            return True
    # Onomatopeja: powtórzenie wzorca 3+ razy
    if re.match(r'^([A-Za-z]{2,8})[,.\s]+\1(?:[,.\s]+\1)*[.!?]*$', stripped, re.IGNORECASE):
        return True

    return False

def is_untranslated(value, en_value, key=""):
    if value is None:
        return True
    text = str(value)
    if text.startswith("["):
        return True
    if text.strip() == "":
        return True
    if text == en_value:
        # Jeśli to prawdopodobnie nazwa własna, NIE traktuj jako nieprzetłumaczone
        if _is_likely_proper_noun(key, en_value):
            return False
        return True
    return False

def pending_for_translation(value, en_value, key=""):
    text = "" if value is None else str(value)
    if text == en_value:
        if _is_likely_proper_noun(key, en_value):
            return False
        return True
    return is_untranslated(value, en_value, key)

def is_simple_text(text):
    txt = str(text or "")
    if not txt.strip():
        return False
    if re.search(r"\{[^}]*\}|\|[^|]+\||'[^']+'", txt):
        return False
    if len(txt) > 80:
        return False
    words = re.findall(r"[A-Za-zÀ-ÿ]+", txt)
    if len(words) == 0 or len(words) > 6:
        return False
    if re.search(r"[\\/<>`$]", txt):
        return False
    return True

priority = split_langs(os.environ.get("LANG_PRIORITY", ""))
raw_targets = split_langs(os.environ.get("TARGET_LANGS", ""))
targets = list(raw_targets)
explicit_target_langs = bool(raw_targets)
if not targets:
    langs_from_dirs = list_language_dirs(I18N_DIR)
    ranked = [l for l in priority if l in langs_from_dirs]
    ranked += [l for l in langs_from_dirs if l not in ranked]
    targets = ranked
if not targets:
    targets = ["pl"]

en_dir = os.path.join(I18N_DIR, "en")
json_files = sorted([f for f in os.listdir(en_dir) if f.endswith(".json")]) if os.path.isdir(en_dir) else []
if not json_files:
    print("IDLE:translation_only_no_source:0:missing_en_json")
    raise SystemExit(0)

en_data_by_file = {}
for json_file in json_files:
    en_path = os.path.join(I18N_DIR, "en", json_file)
    if not os.path.exists(en_path):
        continue
    try:
        with open(en_path, encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            en_data_by_file[json_file] = data
    except Exception:
        continue

missing_lang_files_count = 0
missing_lang_file_examples = []
missing_keys_total = 0
candidates = []

def load_selector_cache(expected_targets, expected_json_files):
    if not os.path.exists(selector_cache_path):
        return None
    try:
        with open(selector_cache_path, "r", encoding="utf-8") as f:
            payload = json.load(f)
    except Exception:
        return None

    if payload.get("targets") != expected_targets:
        return None
    if payload.get("json_files") != expected_json_files:
        return None

    built_cycle = _to_int(payload.get("built_cycle", 0), 0)
    if current_cycle > 0 and built_cycle > 0 and (current_cycle - built_cycle) > cache_ttl_cycles:
        return None

    cached_candidates = payload.get("candidates", [])
    if not isinstance(cached_candidates, list):
        return None
    return payload

cache_payload = load_selector_cache(targets, json_files)
cache_hit = cache_payload is not None

if cache_hit:
    candidates = cache_payload.get("candidates", [])
    missing_lang_files_count = _to_int(cache_payload.get("missing_lang_files_count", 0), 0)
    cached_examples = cache_payload.get("missing_lang_file_examples", [])
    if isinstance(cached_examples, list):
        missing_lang_file_examples = [str(x) for x in cached_examples[:50]]
    missing_keys_total = _to_int(cache_payload.get("missing_keys_total", 0), 0)
else:
    for lang in targets:
        for json_file in json_files:
            lang_path = os.path.join(I18N_DIR, lang, json_file)
            en_data = en_data_by_file.get(json_file)
            if not isinstance(en_data, dict):
                continue

            if not os.path.exists(lang_path):
                missing_lang_files_count += 1
                if len(missing_lang_file_examples) < 50:
                    missing_lang_file_examples.append(f"{lang}/{json_file}")
                continue

            try:
                with open(lang_path, encoding="utf-8") as f:
                    lang_data = json.load(f)
            except Exception:
                continue

            missing_in_lang = sum(1 for key in en_data if key not in lang_data)
            missing_keys_total += missing_in_lang

            todo = 0
            simple_todo = 0
            for key, en_value in en_data.items():
                if key not in lang_data:
                    continue
                if pending_for_translation(lang_data.get(key), en_value, key):
                    todo += 1
                    if is_simple_text(en_value):
                        simple_todo += 1

            pending_total = todo + missing_in_lang
            if pending_total > 0:
                candidates.append({
                    "lang": lang,
                    "json_file": json_file,
                    "pending_total": int(pending_total),
                    "todo": int(todo),
                    "simple_todo": int(simple_todo),
                    "missing_in_lang": int(missing_in_lang),
                })

    try:
        os.makedirs(status_dir, exist_ok=True)
        cache_out = {
            "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "built_cycle": int(current_cycle),
            "cache_ttl_cycles": int(cache_ttl_cycles),
            "targets": targets,
            "json_files": json_files,
            "missing_lang_files_count": int(missing_lang_files_count),
            "missing_lang_file_examples": missing_lang_file_examples[:50],
            "missing_keys_total": int(missing_keys_total),
            "candidates": candidates,
        }
        with open(selector_cache_path, "w", encoding="utf-8") as f:
            json.dump(cache_out, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

if candidates:
    os.makedirs(status_dir, exist_ok=True)

    # === Sekcja 5: TIER-AWARE SCHEDULING ===
    # Tier config from environment
    TIER1_LANGS = set(split_langs(os.environ.get("TIER1_LANGS", "pl es")))
    TIER2_LANGS = set(split_langs(os.environ.get("TIER2_LANGS", "de pt ru tr fr it")))
    TIER1_WEIGHT = max(1, _to_int(os.environ.get("TIER1_WEIGHT", "4"), 4))
    TIER2_WEIGHT = max(1, _to_int(os.environ.get("TIER2_WEIGHT", "2"), 2))
    TIER3_WEIGHT = 1

    # Category translation priority (lower index = higher priority)
    CATEGORY_PRIO_RAW = os.environ.get("CATEGORY_TRANSLATE_PRIORITY",
        "items.json npc.json monsters.json server.json spells.json quests.json scripts.json actions.json raids.json")
    CATEGORY_PRIO_LIST = [c.strip() for c in CATEGORY_PRIO_RAW.split() if c.strip()]
    CATEGORY_PRIO_MAP = {cat: idx for idx, cat in enumerate(CATEGORY_PRIO_LIST)}
    DEFAULT_CAT_PRIO = len(CATEGORY_PRIO_LIST)  # categories not in list get lowest priority

    def get_tier(lang):
        if lang in TIER1_LANGS:
            return 1
        if lang in TIER2_LANGS:
            return 2
        return 3

    def get_tier_weight(lang):
        t = get_tier(lang)
        if t == 1:
            return TIER1_WEIGHT
        if t == 2:
            return TIER2_WEIGHT
        return TIER3_WEIGHT

    def get_cat_priority(json_file):
        return CATEGORY_PRIO_MAP.get(json_file, DEFAULT_CAT_PRIO)

    # Interleave: group by language, sort within language by category priority
    per_lang = {}
    for cand in candidates:
        per_lang.setdefault(cand.get("lang"), []).append(cand)

    for lang in list(per_lang.keys()):
        per_lang[lang].sort(
            key=lambda c: (
                get_cat_priority(c.get("json_file", "")),
                -int(c.get("simple_todo", 0) or 0),
                -int(c.get("pending_total", 0) or 0),
                str(c.get("json_file", "")),
            )
        )

    # Tier-weighted interleaving: In each super-round:
    #   - Tier 1 advances TIER1_WEIGHT files per language
    #   - Tier 2 advances TIER2_WEIGHT files per language
    #   - Tier 3 advances 1 file per language
    # This ensures high-priority languages cover more categories per cycle window.
    tier1_langs = [l for l in targets if l in TIER1_LANGS]
    tier2_langs = [l for l in targets if l in TIER2_LANGS]
    tier3_langs = [l for l in targets if l not in TIER1_LANGS and l not in TIER2_LANGS]

    ordered_candidates = []
    t1_idx = 0
    t2_idx = 0
    t3_idx = 0
    max_bucket = max((len(per_lang.get(l, [])) for l in per_lang), default=0)

    while t1_idx < max_bucket or t2_idx < max_bucket or t3_idx < max_bucket:
        added_any = False

        # Tier 1: advance TIER1_WEIGHT steps
        for _ in range(TIER1_WEIGHT):
            if t1_idx >= max_bucket:
                break
            for lang in tier1_langs:
                bucket = per_lang.get(lang, [])
                if t1_idx < len(bucket):
                    ordered_candidates.append(bucket[t1_idx])
                    added_any = True
            t1_idx += 1

        # Tier 2: advance TIER2_WEIGHT steps
        for _ in range(TIER2_WEIGHT):
            if t2_idx >= max_bucket:
                break
            for lang in tier2_langs:
                bucket = per_lang.get(lang, [])
                if t2_idx < len(bucket):
                    ordered_candidates.append(bucket[t2_idx])
                    added_any = True
            t2_idx += 1

        # Tier 3: advance 1 step
        if t3_idx < max_bucket:
            for lang in tier3_langs:
                bucket = per_lang.get(lang, [])
                if t3_idx < len(bucket):
                    ordered_candidates.append(bucket[t3_idx])
                    added_any = True
            t3_idx += 1

        if not added_any:
            break

    if ordered_candidates:
        candidates = ordered_candidates

    state = {}
    try:
        if os.path.exists(dispatch_state_path):
            with open(dispatch_state_path, "r", encoding="utf-8") as f:
                state = json.load(f)
    except Exception:
        state = {}

    last_key = str(state.get("last_target_key", "") or "")
    ordered_keys = [f"{c['lang']}:{c['json_file']}" for c in candidates]

    # Anti-loop z backoff: śledź ile razy z rzędu kandydat miał zero postępu.
    # Pomijaj kandydatów z >= MAX_NO_PROGRESS_VISITS wizytami bez postępu.
    MAX_NO_PROGRESS_VISITS = 3
    no_progress_map = state.get("no_progress_counts", {})

    # Odczytaj ostatni guard report aby zaktualizować no_progress_counts
    try:
        if os.path.exists(guard_latest_path):
            with open(guard_latest_path, "r", encoding="utf-8") as f:
                g = json.load(f)
            guard_key = f"{g.get('language', '')}:{g.get('json_file', '')}"
            guard_translated = int(g.get("translated", 0) or 0)
            if guard_key == last_key:
                if guard_translated == 0:
                    no_progress_map[guard_key] = no_progress_map.get(guard_key, 0) + 1
                else:
                    no_progress_map[guard_key] = 0  # reset po postępie
    except Exception:
        pass

    # --- Faza 3: guard_fail_rate blacklist z retry policy per reason ---
    # Odczytaj ostatnie N wpisów guard_report i oblicz guard_fail_rate per target.
    # Targets z >80% guard_fail rate w ostatnich 5 cyklach -> backoff.
    # Różne cooldowny per reason:
    #   placeholder/pipe → 15 cykli (krytyczne token errors, wymagają poprawy kodu)
    #   command → 5 cykli (zwykle false positive, krótszy cooldown)
    #   quality/shape → 8 cykli (umiarkowane, średni cooldown)
    #   provider_error → 3 cykle (tymczasowe, szybki retry)
    GUARD_FAIL_THRESHOLD = 0.80
    GUARD_FAIL_WINDOW = 5
    RETRY_COOLDOWN_PER_REASON = {
        "placeholder": 15,
        "pipe": 15,
        "command": 5,
        "quality": 8,
        "shape": 8,
        "provider_error": 3,
        "default": 10,
    }
    guard_fail_blacklist = state.get("guard_fail_blacklist", {})
    current_cycle_num = state.get("cycle_counter", 0) + 1
    state["cycle_counter"] = current_cycle_num

    try:
        guard_report_path = os.path.join(status_dir, "translation_guard_report.jsonl")
        if os.path.exists(guard_report_path):
            import collections
            target_stats = collections.defaultdict(lambda: {"translated": 0, "guard_fail": 0, "entries": 0, "reasons": collections.Counter()})
            # Odczytaj ostatnie 200 linii (wystarczy dla okna)
            with open(guard_report_path, "r", encoding="utf-8") as f:
                lines = f.readlines()
            for line in lines[-200:]:
                try:
                    entry = json.loads(line.strip())
                    tkey = f"{entry.get('language', '')}:{entry.get('json_file', '')}"
                    target_stats[tkey]["translated"] += int(entry.get("translated", 0) or 0)
                    gf_count = int(entry.get("guard_fail", 0) or 0)
                    target_stats[tkey]["guard_fail"] += gf_count
                    target_stats[tkey]["entries"] += 1
                    # Zbierz powody guard_fail
                    if gf_count > 0:
                        guard_detail = entry.get("guard", {})
                        for reason_key in ("placeholder", "command", "pipe"):
                            rc = int(guard_detail.get(reason_key, 0) or 0)
                            if rc > 0:
                                target_stats[tkey]["reasons"][reason_key] += rc
                except Exception:
                    continue

            # Zaktualizuj blacklist: jeśli target ma >THRESHOLD guard_fail rate w oknie
            # Cooldown zależy od dominującego powodu guard_fail
            for tkey, stats in target_stats.items():
                total_attempts = stats["translated"] + stats["guard_fail"]
                if stats["entries"] >= GUARD_FAIL_WINDOW and total_attempts > 0:
                    gf_rate = stats["guard_fail"] / total_attempts
                    if gf_rate >= GUARD_FAIL_THRESHOLD:
                        if tkey not in guard_fail_blacklist or guard_fail_blacklist[tkey] <= current_cycle_num:
                            # Wybierz cooldown na podstawie dominującej przyczyny
                            dominant_reason = "default"
                            if stats["reasons"]:
                                dominant_reason = stats["reasons"].most_common(1)[0][0]
                            cooldown_cycles = RETRY_COOLDOWN_PER_REASON.get(dominant_reason, RETRY_COOLDOWN_PER_REASON["default"])
                            guard_fail_blacklist[tkey] = current_cycle_num + cooldown_cycles
    except Exception:
        pass

    state["guard_fail_blacklist"] = guard_fail_blacklist

    # Przefiltruj kandydatów: pomiń tych z backoff LUB guard_fail blacklist
    active_candidates = []
    skipped_backoff = 0
    skipped_guard_fail = 0
    for i, c in enumerate(candidates):
        ckey = f"{c['lang']}:{c['json_file']}"
        visits = no_progress_map.get(ckey, 0)
        if visits >= MAX_NO_PROGRESS_VISITS:
            skipped_backoff += 1
        elif ckey in guard_fail_blacklist and guard_fail_blacklist[ckey] > current_cycle_num:
            skipped_guard_fail += 1
        else:
            active_candidates.append((i, c))

    # Jeśli WSZYSCY kandydaci są na backoff, zresetuj liczniki i zwróć IDLE-blocked
    if not active_candidates:
        reason = f"all_candidates_backoff total={len(candidates)} skipped_noprogress={skipped_backoff} skipped_guard_fail={skipped_guard_fail}"
        # Reset liczników co pełny cykl, aby spróbować ponownie za następnym razem
        no_progress_map = {}
        state["no_progress_counts"] = no_progress_map
        try:
            with open(dispatch_state_path, "w", encoding="utf-8") as f:
                json.dump(state, f, indent=2, ensure_ascii=False)
        except Exception:
            pass
        print(f"IDLE:translation_only_blocked:0:{reason}")
        raise SystemExit(0)

    # Round-robin wśród aktywnych kandydatów
    active_keys = [f"{c['lang']}:{c['json_file']}" for _, c in active_candidates]

    # ── Bootstrap kolejności (general mode): es -> pl -> reszta ───────────
    bootstrap_priority = [l for l in split_langs(os.environ.get("BOOTSTRAP_PRIORITY_LANGS", "es pl")) if l in targets]
    bootstrap_enabled = bool(bootstrap_priority) and not explicit_target_langs
    bootstrap_forced = False
    bootstrap_forced_lang = ""
    bootstrap_completed = []
    bootstrap_skipped_no_pending = []
    try:
        bootstrap_state = state.get("bootstrap_priority", {})
        if isinstance(bootstrap_state, dict):
            prev_completed = bootstrap_state.get("completed", [])
            if isinstance(prev_completed, list):
                bootstrap_completed = [str(x) for x in prev_completed if str(x) in bootstrap_priority]
        if bootstrap_enabled:
            pending_bootstrap = [l for l in bootstrap_priority if l not in bootstrap_completed]
            for b_lang in pending_bootstrap:
                lang_candidates = [(oi, bc) for oi, bc in active_candidates if bc.get("lang") == b_lang]
                if lang_candidates:
                    rest = [(oi, bc) for oi, bc in active_candidates if bc.get("lang") != b_lang]
                    active_candidates = lang_candidates + rest
                    active_keys = [f"{c2['lang']}:{c2['json_file']}" for _, c2 in active_candidates]
                    bootstrap_forced = True
                    bootstrap_forced_lang = b_lang
                    bootstrap_completed.append(b_lang)
                    break
                bootstrap_completed.append(b_lang)
                bootstrap_skipped_no_pending.append(b_lang)
    except Exception:
        pass

    # ── Twardy balans PL/ES (Section 12.4) ──────────────────────────────
    # Jeśli profil to pl,es: wymuszaj min. 35% udziału ES (i min. 35% PL).
    # Sprawdzamy ostatnie 20 wpisów guard_report — jeśli ES < 35%, wymuszaj ES.
    MIN_BALANCE_SHARE = 0.35
    BALANCE_WINDOW = 20
    balance_forced = False
    try:
        tier1_active_langs = set()
        for _, c in active_candidates:
            if c["lang"] in TIER1_LANGS:
                tier1_active_langs.add(c["lang"])
        if (not bootstrap_forced) and len(tier1_active_langs) >= 2 and "pl" in tier1_active_langs and "es" in tier1_active_langs:
            guard_report_path_bal = os.path.join(status_dir, "translation_guard_report.jsonl")
            if os.path.exists(guard_report_path_bal):
                recent_langs = []
                with open(guard_report_path_bal, "r", encoding="utf-8") as f:
                    bal_lines = f.readlines()
                for bline in bal_lines[-BALANCE_WINDOW:]:
                    try:
                        be = json.loads(bline.strip())
                        bl = be.get("language", "")
                        if bl in ("pl", "es"):
                            recent_langs.append(bl)
                    except Exception:
                        continue
                if len(recent_langs) >= BALANCE_WINDOW // 2:
                    pl_share = recent_langs.count("pl") / len(recent_langs)
                    es_share = recent_langs.count("es") / len(recent_langs)
                    # Wymuszaj język z mniejszym udziałem jeśli < MIN_BALANCE_SHARE
                    starved_lang = None
                    if es_share < MIN_BALANCE_SHARE:
                        starved_lang = "es"
                    elif pl_share < MIN_BALANCE_SHARE:
                        starved_lang = "pl"
                    if starved_lang:
                        # Przesuń pierwszego kandydata ze starved_lang na początek
                        for bi, (oi, bc) in enumerate(active_candidates):
                            if bc["lang"] == starved_lang:
                                # Jeśli round-robin wybrałby inny język, wymuś starved
                                starved_candidates = [(oi2, bc2) for oi2, bc2 in active_candidates if bc2["lang"] == starved_lang]
                                if starved_candidates:
                                    balance_forced = True
                                    # Docelowo: wstawiamy starved kandydatów na początek
                                    rest = [(oi2, bc2) for oi2, bc2 in active_candidates if bc2["lang"] != starved_lang]
                                    active_candidates = starved_candidates + rest
                                    active_keys = [f"{c2['lang']}:{c2['json_file']}" for _, c2 in active_candidates]
                                break
    except Exception:
        pass

    selected_idx = 0
    if last_key in active_keys:
        selected_idx = (active_keys.index(last_key) + 1) % len(active_candidates)

    _, selected = active_candidates[selected_idx]

    state_payload = {
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "cycle_counter": int(current_cycle_num),
        "last_target_key": f"{selected['lang']}:{selected['json_file']}",
        "last_pending_total": int(selected.get("pending_total", 0) or 0),
        "last_tier": get_tier(selected['lang']),
        "last_cat_priority": get_cat_priority(selected['json_file']),
        "candidates_count": len(candidates),
        "active_candidates_count": len(active_candidates),
        "skipped_backoff": skipped_backoff,
        "skipped_guard_fail": skipped_guard_fail,
        "guard_fail_blacklist": {k: v for k, v in guard_fail_blacklist.items() if v > current_cycle_num},
        "tier_config": {"tier1": sorted(TIER1_LANGS), "tier2": sorted(TIER2_LANGS),
                        "w1": TIER1_WEIGHT, "w2": TIER2_WEIGHT, "w3": TIER3_WEIGHT},
        "cache_hit": bool(cache_hit),
        "cache_ttl_cycles": int(cache_ttl_cycles),
        "cache_cycle": int(current_cycle),
        "no_progress_counts": no_progress_map,
        "bootstrap_priority": {
            "enabled": bool(bootstrap_enabled),
            "sequence": bootstrap_priority,
            "completed": bootstrap_completed,
            "skipped_no_pending": bootstrap_skipped_no_pending,
            "forced_lang": bootstrap_forced_lang,
        },
        "bootstrap_forced": bool(bootstrap_forced),
        "bootstrap_forced_lang": bootstrap_forced_lang,
        "balance_forced": bool(balance_forced),
    }
    try:
        with open(dispatch_state_path, "w", encoding="utf-8") as f:
            json.dump(state_payload, f, indent=2, ensure_ascii=False)
    except Exception:
        pass

    print(f"AUTO_TRANSLATE:{selected['lang']}:{selected['json_file']}:{selected['pending_total']}:STRICT")
    raise SystemExit(0)

os.makedirs(status_dir, exist_ok=True)
entry = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "mode": "translations_only_strict",
    "missing_lang_files": int(missing_lang_files_count),
    "missing_lang_file_examples": missing_lang_file_examples[:20],
    "missing_keys_total": int(missing_keys_total),
    "targets": targets,
    "json_files": len(json_files),
    "cache_hit": bool(cache_hit),
    "cache_ttl_cycles": int(cache_ttl_cycles),
    "cache_cycle": int(current_cycle),
}
with open(os.path.join(status_dir, "translation_blockers_latest.json"), "w", encoding="utf-8") as f:
    json.dump(entry, f, indent=2, ensure_ascii=False)
with open(os.path.join(status_dir, "translation_blockers_report.jsonl"), "a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False) + "\n")

if missing_lang_files_count > 0 or missing_keys_total > 0:
    reason = f"strict_blocked missing_lang_files={missing_lang_files_count} missing_keys={missing_keys_total}"
    print(f"IDLE:translation_only_blocked:0:{reason}")
else:
    print("IDLE:translation_only_done:0:all_translations_completed")
AUTOSTRICTPY
}

should_update_github_status() {
    local force_mode="${1:-}"
    local cycle_now="${CYCLE:-0}"
    local every_cycles="${STATUS_UPDATE_EVERY_CYCLES:-5}"
    local min_interval_sec="${STATUS_UPDATE_MIN_INTERVAL_SEC:-300}"
    local state_file="$STATUS_DIR/status_update_state.json"

    if [ "$force_mode" = "force" ]; then
        mkdir -p "$STATUS_DIR" 2>/dev/null || true
        python3 - "$state_file" "$cycle_now" << 'PY'
import json
import os
import sys
import time

state_file = sys.argv[1]
cycle_now = int(sys.argv[2]) if len(sys.argv) > 2 else 0
payload = {
    "last_cycle": cycle_now,
    "last_ts": int(time.time()),
    "reason": "forced",
}
tmp = state_file + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2, ensure_ascii=False)
os.replace(tmp, state_file)
PY
        return 0
    fi

    local decision
    decision=$(python3 - "$state_file" "$cycle_now" "$every_cycles" "$min_interval_sec" << 'PY'
import json
import os
import sys
import time

state_file = sys.argv[1]
cycle_now = int(sys.argv[2]) if len(sys.argv) > 2 else 0
every_cycles = max(1, int(sys.argv[3]) if len(sys.argv) > 3 else 5)
min_interval_sec = max(1, int(sys.argv[4]) if len(sys.argv) > 4 else 300)
now_ts = int(time.time())

last_cycle = -1
last_ts = 0
try:
    if os.path.exists(state_file):
        with open(state_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        last_cycle = int(data.get("last_cycle", -1) or -1)
        last_ts = int(data.get("last_ts", 0) or 0)
except Exception:
    last_cycle = -1
    last_ts = 0

cycle_delta = cycle_now - last_cycle if cycle_now >= 0 and last_cycle >= 0 else every_cycles
time_delta = now_ts - last_ts if last_ts > 0 else min_interval_sec

should = (last_cycle < 0) or (cycle_delta >= every_cycles) or (time_delta >= min_interval_sec)

if should:
    payload = {
        "last_cycle": cycle_now,
        "last_ts": now_ts,
        "every_cycles": every_cycles,
        "min_interval_sec": min_interval_sec,
        "cycle_delta": cycle_delta,
        "time_delta": time_delta,
    }
    tmp = state_file + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, state_file)
    print("1")
else:
    print("0")
PY
)

    [ "$decision" = "1" ]
}

should_force_status_update_on_metrics_delta() {
    local cycle_now="${CYCLE:-0}"
    local state_file="$STATUS_DIR/status_force_metrics_state.json"
    local overview_file="$STATUS_DIR/translation_global_overview.json"
    local guard_file="$STATUS_DIR/translation_guard_latest.json"
    local blockers_file="$STATUS_DIR/translation_blockers_latest.json"
    local recent_file="$STATUS_DIR/translation_recent_latest.json"
    local i18n_root="$I18N_DIR"

    local decision
    decision=$(python3 - "$state_file" "$cycle_now" "$overview_file" "$guard_file" "$blockers_file" "$recent_file" "$i18n_root" << 'PY'
import json
import hashlib
import os
import sys
from datetime import datetime, timezone

state_file = sys.argv[1]
cycle_now = int(sys.argv[2]) if len(sys.argv) > 2 else 0
overview_file = sys.argv[3] if len(sys.argv) > 3 else ""
guard_file = sys.argv[4] if len(sys.argv) > 4 else ""
blockers_file = sys.argv[5] if len(sys.argv) > 5 else ""
recent_file = sys.argv[6] if len(sys.argv) > 6 else ""
i18n_root = sys.argv[7] if len(sys.argv) > 7 else "i18n"

def _load_json(path):
    if not path or not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}

def _compute_i18n_signature(root_dir):
    parts = []
    json_files = 0
    try:
        lang_dirs = sorted(os.listdir(root_dir))
    except Exception:
        return "missing", 0

    for lang in lang_dirs:
        if lang == "status":
            continue
        lang_path = os.path.join(root_dir, lang)
        if not os.path.isdir(lang_path):
            continue
        try:
            names = sorted(os.listdir(lang_path))
        except Exception:
            continue

        for name in names:
            if not name.endswith(".json"):
                continue
            path = os.path.join(lang_path, name)
            try:
                st = os.stat(path)
                parts.append(f"{lang}/{name}:{int(st.st_mtime_ns)}:{int(st.st_size)}")
                json_files += 1
            except Exception:
                continue

    payload = "\n".join(parts).encode("utf-8")
    digest = hashlib.sha1(payload).hexdigest() if parts else "empty"
    return digest, json_files

overview = _load_json(overview_file)
guard = _load_json(guard_file)
blockers = _load_json(blockers_file)
recent = _load_json(recent_file)
i18n_sig, i18n_json_files = _compute_i18n_signature(i18n_root)

global_data = overview.get("global", {}) if isinstance(overview.get("global", {}), dict) else {}

current = {
    "translated_keys": int(global_data.get("translated_keys", 0) or 0),
    "total_reference_keys": int(global_data.get("total_reference_keys", 0) or 0),
    "missing_keys": int(global_data.get("missing_keys", 0) or 0),
    "missing_files": int(global_data.get("missing_files", 0) or 0),
    "guard_fail": int(guard.get("guard_fail", 0) or 0),
    "strict_missing_file": int(guard.get("strict_missing_file", 0) or 0),
    "strict_missing_key": int(guard.get("strict_missing_key", 0) or 0),
    "strict_skipped_done": int(guard.get("strict_skipped_done", 0) or 0),
    "blockers_missing_keys_total": int(blockers.get("missing_keys_total", 0) or 0),
    "blockers_missing_lang_files": int(blockers.get("missing_lang_files", 0) or 0),
    "recent_translated": int(recent.get("translated", 0) or 0),
    "i18n_live_json_files": int(i18n_json_files),
    "i18n_live_signature": str(i18n_sig),
}

previous = {}
if os.path.exists(state_file):
    try:
        with open(state_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        previous = data.get("metrics", {}) if isinstance(data.get("metrics", {}), dict) else {}
    except Exception:
        previous = {}

force = False
reason = ""

if not previous:
    force = True
    reason = "initial_metrics_baseline"
else:
    tracked = [
        "translated_keys",
        "total_reference_keys",
        "missing_keys",
        "missing_files",
        "guard_fail",
        "strict_missing_file",
        "strict_missing_key",
        "strict_skipped_done",
        "blockers_missing_keys_total",
        "blockers_missing_lang_files",
        "i18n_live_json_files",
    ]
    for key in tracked:
        if int(previous.get(key, 0) or 0) != int(current.get(key, 0) or 0):
            force = True
            reason = f"delta:{key}:{int(previous.get(key, 0) or 0)}->{int(current.get(key, 0) or 0)}"
            break

    if not force:
        prev_sig = str(previous.get("i18n_live_signature", "") or "")
        curr_sig = str(current.get("i18n_live_signature", "") or "")
        if prev_sig != curr_sig:
            force = True
            reason = f"delta:i18n_live_signature:{prev_sig[:8]}->{curr_sig[:8]}"

    if not force and int(current.get("recent_translated", 0) or 0) > 0:
        force = True
        reason = "recent_translated_gt_0"

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "cycle": cycle_now,
    "force": bool(force),
    "reason": reason,
    "metrics": current,
}

tmp = state_file + ".tmp"
os.makedirs(os.path.dirname(state_file) or ".", exist_ok=True)
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2, ensure_ascii=False)
os.replace(tmp, state_file)

print("1" if force else "0")
PY
)

    [ "$decision" = "1" ]
}

should_run_quality_audit() {
    local cycle_now="${CYCLE:-0}"
    local every_cycles="${QUALITY_AUDIT_EVERY_CYCLES:-10}"
    local min_interval_sec="${QUALITY_AUDIT_MIN_INTERVAL_SEC:-3600}"
    local state_file="$STATUS_DIR/quality_audit_state.json"

    local decision
    decision=$(python3 - "$state_file" "$cycle_now" "$every_cycles" "$min_interval_sec" << 'PY'
import json
import os
import sys
import time

state_file = sys.argv[1]
cycle_now = int(sys.argv[2]) if len(sys.argv) > 2 else 0
every_cycles = max(1, int(sys.argv[3]) if len(sys.argv) > 3 else 10)
min_interval_sec = max(1, int(sys.argv[4]) if len(sys.argv) > 4 else 3600)
now_ts = int(time.time())

last_cycle = -1
last_ts = 0
try:
    if os.path.exists(state_file):
        with open(state_file, "r", encoding="utf-8") as f:
            d = json.load(f)
        last_cycle = int(d.get("last_cycle", -1) or -1)
        last_ts = int(d.get("last_ts", 0) or 0)
except Exception:
    pass

cycle_delta = cycle_now - last_cycle if last_cycle >= 0 else every_cycles
time_delta = now_ts - last_ts if last_ts > 0 else min_interval_sec
should = (last_cycle < 0) or (cycle_delta >= every_cycles) or (time_delta >= min_interval_sec)

if should:
    payload = {
        "last_cycle": cycle_now,
        "last_ts": now_ts,
        "every_cycles": every_cycles,
        "min_interval_sec": min_interval_sec,
    }
    os.makedirs(os.path.dirname(state_file) or ".", exist_ok=True)
    tmp = state_file + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, state_file)
    print("1")
else:
    print("0")
PY
)

    [ "$decision" = "1" ]
}

run_quality_audit() {
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$STATUS_DIR" "$QUALITY_AUDIT_THRESHOLD" << 'QUALITY_AUDIT_PY'
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone

status_dir = sys.argv[1]
threshold = int(sys.argv[2]) if len(sys.argv) > 2 else 10

recent_path = os.path.join(status_dir, "translation_recent_report.jsonl")
suspicious_log_path = os.path.join(status_dir, "suspicious_log.jsonl")
suspicious_rejected_path = os.path.join(status_dir, "suspicious_rejected.jsonl")
audit_latest_path = os.path.join(status_dir, "quality_audit_latest.json")
dashboard_path = os.path.join(status_dir, "quality_dashboard.json")

entries = []
if os.path.exists(recent_path):
    with open(recent_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            for e in (obj.get("entries", []) if isinstance(obj.get("entries", []), list) else []):
                if not isinstance(e, dict):
                    continue
                entries.append({
                    "lang": obj.get("language", ""),
                    "json_file": obj.get("json_file", ""),
                    "key": e.get("key", ""),
                    "en": str(e.get("en", "") or ""),
                    "translated": str(e.get("translated", "") or ""),
                })

entries = entries[-100:]
issues = []
issue_counter = Counter()
lang_issue_counter = Counter()

def _is_probably_nontranslatable_text(text: str) -> bool:
    t = str(text or "").strip()
    if not t:
        return True
    if re.search(r"https?://|www\.", t, re.IGNORECASE):
        return True
    if "{{" in t or "}}" in t or "{%" in t or "%}" in t:
        return True
    if re.search(r"(?:^|\s)/(?:[A-Za-z0-9_.-]+/){1,}[A-Za-z0-9_.-]+", t):
        return True
    if "~" in t and re.search(r"[A-Za-z_]", t):
        return True
    if re.fullmatch(r"<[^<>]+>", t):
        return True
    tokens = [tok for tok in re.split(r"\s+", t) if tok]
    if tokens and all(re.fullmatch(r"[A-Za-z0-9_.:-]+", tok) for tok in tokens):
        if any(("/" in tok) or ("_" in tok) or ("-" in tok) or re.search(r"\d", tok) for tok in tokens):
            return True
        if len(tokens) == 1 and "." in tokens[0]:
            return True
    cleaned = re.sub(r'__PH\d+__|[{}\[\]|%$0-9\s_\-:;.,!?/\\()<>\"\'`~+=*&^#@]', '', t)
    if not cleaned:
        return True
    words = [w for w in re.findall(r"[A-Za-zÀ-ÖØ-öø-ÿ]{2,}", t)]
    if len(words) <= 1 and t.upper() == t and len(t) <= 20:
        return True
    return False

value_langs = defaultdict(set)
for e in entries:
    tr = e["translated"].strip()
    if tr:
        value_langs[tr].add(str(e["lang"] or ""))

for e in entries:
    en = e["en"]
    tr = e["translated"]
    lang = str(e["lang"] or "")
    key = str(e["key"] or "")
    if not en or not tr:
        continue

    ratio = (len(tr) / max(len(en), 1))
    if ratio < 0.3 or ratio > 4.0:
        issues.append({"key": key, "lang": lang, "type": "length_anomaly", "ratio": round(ratio, 3), "en": en, "translated": tr})
        issue_counter["length_anomaly"] += 1
        lang_issue_counter[lang] += 1

    if tr == en:
        if _is_probably_nontranslatable_text(en):
            issue_counter["identical_to_en_exempt"] += 1
        else:
            issues.append({"key": key, "lang": lang, "type": "identical_to_en", "en": en, "translated": tr})
            issue_counter["identical_to_en"] += 1
            lang_issue_counter[lang] += 1

    if re.search(r"\?\?\?|\[[A-Z]{2,}(?:[-_][A-Z]{2,})?\]|TODO|FIXME", tr):
        issues.append({"key": key, "lang": lang, "type": "artifact_token", "en": en, "translated": tr})
        issue_counter["artifact_token"] += 1
        lang_issue_counter[lang] += 1

    if len(value_langs.get(tr, set())) >= 5:
        issues.append({"key": key, "lang": lang, "type": "same_translation_many_langs", "langs": sorted(value_langs.get(tr, set()))[:12], "en": en, "translated": tr})
        issue_counter["same_translation_many_langs"] += 1
        lang_issue_counter[lang] += 1

for path, source in ((suspicious_log_path, "suspicious_log"), (suspicious_rejected_path, "suspicious_rejected")):
    if not os.path.exists(path):
        continue
    try:
        with open(path, "r", encoding="utf-8") as f:
            lines = [x.strip() for x in f if x.strip()][-200:]
        for line in lines:
            try:
                obj = json.loads(line)
            except Exception:
                continue
            lang = str(obj.get("lang", "") or "")
            typ = str(obj.get("severity", "") or "")
            if typ:
                issue_counter[f"{source}_{typ.lower()}"] += 1
                lang_issue_counter[lang] += 1
    except Exception:
        pass

checked_entries = len(entries)
issues_found = len(issues)
ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

audit_payload = {
    "timestamp": ts,
    "checked_entries": checked_entries,
    "issues_found": issues_found,
    "issues_by_type": dict(issue_counter),
    "issues": issues[:200],
    "threshold": threshold,
    "slow_mode": bool(issues_found > threshold),
}

tmp = audit_latest_path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(audit_payload, f, indent=2, ensure_ascii=False)
os.replace(tmp, audit_latest_path)

dashboard = {}
if os.path.exists(dashboard_path):
    try:
        with open(dashboard_path, "r", encoding="utf-8") as f:
            dashboard = json.load(f)
    except Exception:
        dashboard = {}

for lang, count in lang_issue_counter.items():
    if not lang:
        continue
    cur = dashboard.get(lang, {}) if isinstance(dashboard.get(lang, {}), dict) else {}
    prev_score = float(cur.get("quality_score", 100) or 100)
    penalty = min(40.0, float(count) * 2.0)
    score = max(0.0, round((prev_score * 0.6) + ((100.0 - penalty) * 0.4), 1))
    cur["last_audit"] = ts
    cur["issues_count"] = int(cur.get("issues_count", 0) or 0) + int(count)
    cur["quality_score"] = score
    dashboard[lang] = cur

tmp_dash = dashboard_path + ".tmp"
with open(tmp_dash, "w", encoding="utf-8") as f:
    json.dump(dashboard, f, indent=2, ensure_ascii=False)
os.replace(tmp_dash, dashboard_path)

print(f"__QUALITY_AUDIT__ checked={checked_entries} issues={issues_found} threshold={threshold} slow={1 if issues_found > threshold else 0}")
QUALITY_AUDIT_PY
}

#===============================================================================
# TIER QUALITY GATE — Faza 6: Formalna walidacja tierów
#===============================================================================
# Walidacja jakości per tier (coverage, guard_fail, krytyczne błędy).
# Uruchamiana co TIER_VALIDATION_INTERVAL cykli.
# Wynik: JSONL log + dynamiczne dostosowanie wag tierów.
#===============================================================================
TIER_VALIDATION_INTERVAL="${TIER_VALIDATION_INTERVAL:-15}"
TIER1_COVERAGE_TARGET="${TIER1_TARGET:-90}"
TIER2_COVERAGE_TARGET="${TIER2_TARGET:-50}"
TIER3_COVERAGE_TARGET="${TIER3_TARGET:-30}"

validate_tier_quality() {
    local cycle="$1"
    
    # Sprawdź interwał
    if (( cycle % TIER_VALIDATION_INTERVAL != 0 )); then
        return 0
    fi
    
    echo "📊 TIER VALIDATION: formalna walidacja jakości tierów (cykl $cycle)"
    
    local tier_result
    tier_result=$(python3 << 'TIER_VALIDATE_PY'
import json, os, re
from datetime import datetime, timezone
from collections import defaultdict

I18N_DIR = "i18n"
STATUS_DIR = os.path.join(I18N_DIR, "status")

# Konfiguracja tierów
TIER1_LANGS = set(os.environ.get("TIER1_LANGS", "pl es").split())
TIER2_LANGS = set(os.environ.get("TIER2_LANGS", "de pt ru tr fr it").split())
TIER1_TARGET = int(os.environ.get("TIER1_TARGET", "90"))
TIER2_TARGET = int(os.environ.get("TIER2_TARGET", "50"))
TIER3_TARGET = int(os.environ.get("TIER3_TARGET", "30"))

en_dir = os.path.join(I18N_DIR, "en")
json_files = [f for f in os.listdir(en_dir) if f.endswith(".json")] if os.path.isdir(en_dir) else []

# Wczytaj dane EN
en_data_all = {}
en_total_keys = 0
for jf in json_files:
    try:
        with open(os.path.join(en_dir, jf), encoding="utf-8") as f:
            data = json.load(f)
        en_data_all[jf] = data
        en_total_keys += len(data)
    except Exception:
        continue

# Oblicz pokrycie per język
lang_dirs = sorted([d for d in os.listdir(I18N_DIR)
                    if os.path.isdir(os.path.join(I18N_DIR, d)) and d != "en" and d != "status"
                    and re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", d)])

lang_coverage = {}
for lang in lang_dirs:
    translated = 0
    total = 0
    for jf, en_data in en_data_all.items():
        lang_path = os.path.join(I18N_DIR, lang, jf)
        if not os.path.exists(lang_path):
            continue
        try:
            with open(lang_path, encoding="utf-8") as f:
                ld = json.load(f)
        except Exception:
            continue
        for k, v in en_data.items():
            if k in ld:
                total += 1
                lv = str(ld[k])
                if not lv.startswith("[") and lv != str(v):
                    translated += 1
    cov = round(translated / total * 100, 1) if total > 0 else 0.0
    lang_coverage[lang] = {"coverage": cov, "translated": translated, "total": total}

# Guard fail rate z ostatnich 200 wpisów
guard_fail_per_lang = defaultdict(lambda: {"translated": 0, "guard_fail": 0})
try:
    guard_path = os.path.join(STATUS_DIR, "translation_guard_report.jsonl")
    if os.path.exists(guard_path):
        with open(guard_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        for line in lines[-200:]:
            try:
                e = json.loads(line.strip())
                lang = e.get("language", "")
                guard_fail_per_lang[lang]["translated"] += int(e.get("translated", 0) or 0)
                guard_fail_per_lang[lang]["guard_fail"] += int(e.get("guard_fail", 0) or 0)
            except Exception:
                continue
except Exception:
    pass

# Walidacja per tier
tier_results = {}
for tier_name, tier_langs, target in [
    ("tier1", TIER1_LANGS, TIER1_TARGET),
    ("tier2", TIER2_LANGS, TIER2_TARGET),
    ("tier3", set(lang_dirs) - TIER1_LANGS - TIER2_LANGS, TIER3_TARGET),
]:
    langs_in_tier = [l for l in lang_dirs if l in tier_langs]
    if not langs_in_tier:
        continue
    
    tier_coverages = []
    tier_gate_pass = True
    lang_details = {}
    
    for lang in langs_in_tier:
        lc = lang_coverage.get(lang, {"coverage": 0})
        cov = lc["coverage"]
        tier_coverages.append(cov)
        
        gf = guard_fail_per_lang.get(lang, {"translated": 0, "guard_fail": 0})
        total_attempts = gf["translated"] + gf["guard_fail"]
        gf_rate = round(gf["guard_fail"] / total_attempts * 100, 1) if total_attempts > 0 else 0.0
        
        gate_ok = cov >= target
        lang_details[lang] = {
            "coverage": cov,
            "target": target,
            "gate_pass": gate_ok,
            "guard_fail_rate": gf_rate,
        }
        if not gate_ok:
            tier_gate_pass = False
    
    avg_cov = round(sum(tier_coverages) / len(tier_coverages), 1) if tier_coverages else 0
    tier_results[tier_name] = {
        "langs": sorted(langs_in_tier),
        "avg_coverage": avg_cov,
        "target": target,
        "gate_pass": tier_gate_pass,
        "langs_passing": sum(1 for d in lang_details.values() if d["gate_pass"]),
        "langs_total": len(langs_in_tier),
        "lang_details": lang_details,
    }

# Zapisz wynik
result = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "en_total_keys": en_total_keys,
    "tier_results": tier_results,
    "recommendation": "",
}

# Rekomendacje
if tier_results.get("tier1", {}).get("gate_pass"):
    if tier_results.get("tier2", {}).get("gate_pass"):
        result["recommendation"] = "ALL_TIERS_PASS: można przejść do Tier 3 rollout"
    else:
        result["recommendation"] = "TIER1_PASS: kontynuuj Tier 2 z priorytetem"
else:
    result["recommendation"] = "TIER1_INCOMPLETE: priorytet na PL/ES"

# Zapisz raport
os.makedirs(STATUS_DIR, exist_ok=True)
report_path = os.path.join(STATUS_DIR, "tier_quality_gate.json")
try:
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
except Exception:
    pass

# JSONL log
log_path = os.path.join(STATUS_DIR, "tier_quality_gate.jsonl")
log_entry = {
    "t": result["timestamp"],
    "tier1_avg": tier_results.get("tier1", {}).get("avg_coverage", 0),
    "tier1_pass": tier_results.get("tier1", {}).get("gate_pass", False),
    "tier2_avg": tier_results.get("tier2", {}).get("avg_coverage", 0),
    "tier2_pass": tier_results.get("tier2", {}).get("gate_pass", False),
    "recommendation": result["recommendation"],
}
try:
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")
except Exception:
    pass

# Wynik na stdout
t1 = tier_results.get("tier1", {})
t2 = tier_results.get("tier2", {})
print(f"__TIER_GATE__ tier1_avg={t1.get('avg_coverage',0)}% pass={t1.get('gate_pass',False)} "
      f"tier2_avg={t2.get('avg_coverage',0)}% pass={t2.get('gate_pass',False)} "
      f"rec={result['recommendation']}")
TIER_VALIDATE_PY
    )
    
    echo "   $tier_result"
    status_log_op "$cycle" "AUTO_TRANSLATE" "TIER_QUALITY_GATE" "-" "-" "ok" "$tier_result"
}

# ── pending_skip 24h dedicated artifact (#14) ────────────────────────────────
# Zamiast parsować `worker_cycle_perf.detail`, logujemy pending_skip zdarzenia
# do dedykowanego JSONL i obliczamy metryki 24h z niego.
log_pending_skip_event() {
    # Użycie: log_pending_skip_event <cycle> <total_needs> <reason>
    local cycle="${1:-0}"
    local total_needs="${2:-0}"
    local reason="${3:-backoff}"
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$STATUS_DIR" "$cycle" "$total_needs" "$reason" << 'PSKIP_LOG_PY'
import json, os, sys
from datetime import datetime, timezone

status_dir = sys.argv[1]
cycle = int(sys.argv[2]) if len(sys.argv) > 2 else 0
total_needs = int(sys.argv[3]) if len(sys.argv) > 3 else 0
reason = sys.argv[4] if len(sys.argv) > 4 else "backoff"

jsonl_path = os.path.join(status_dir, "pending_skip_events.jsonl")
ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
entry = {
    "timestamp": ts,
    "cycle": cycle,
    "total_needs": total_needs,
    "reason": reason,
}
try:
    with open(jsonl_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
except Exception:
    pass
PSKIP_LOG_PY
}

compute_pending_skip_24h() {
    # Oblicza metryki pending_skip z ostatnich 24h z dedykowanego JSONL.
    # Wynik: pending_skip_24h_latest.json
    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$STATUS_DIR" << 'PSKIP_24H_PY'
import json, os, sys
from datetime import datetime, timezone, timedelta

status_dir = sys.argv[1]
jsonl_path = os.path.join(status_dir, "pending_skip_events.jsonl")
latest_path = os.path.join(status_dir, "pending_skip_24h_latest.json")
perf_path = os.path.join(status_dir, "worker_cycle_perf.jsonl")

now = datetime.now(timezone.utc)
cutoff = now - timedelta(hours=24)
cutoff_iso = cutoff.isoformat().replace("+00:00", "Z")

# Count pending_skip events in 24h window
skip_count = 0
skip_reasons = {}
total_needs_sum = 0

if os.path.exists(jsonl_path):
    try:
        with open(jsonl_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    ts = obj.get("timestamp", "")
                    if ts >= cutoff_iso:
                        skip_count += 1
                        r = obj.get("reason", "unknown")
                        skip_reasons[r] = skip_reasons.get(r, 0) + 1
                        total_needs_sum += int(obj.get("total_needs", 0))
                except Exception:
                    continue
    except Exception:
        pass

# Count total cycles in 24h for share calculation
total_cycles_24h = 0
if os.path.exists(perf_path):
    try:
        with open(perf_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    ts = obj.get("timestamp", "")
                    phase = obj.get("phase", "")
                    if ts >= cutoff_iso and phase == "cycle_total":
                        total_cycles_24h += 1
                except Exception:
                    continue
    except Exception:
        pass

share = round(skip_count / total_cycles_24h * 100, 1) if total_cycles_24h > 0 else 0.0

payload = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "window_hours": 24,
    "pending_skip_count": skip_count,
    "total_cycles_24h": total_cycles_24h,
    "pending_skip_share_pct": share,
    "reasons": skip_reasons,
    "total_needs_sum": total_needs_sum,
    "status": "ok" if share < 25.0 else ("warning" if share < 50.0 else "critical"),
}

try:
    tmp = latest_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, latest_path)
except Exception:
    pass

print(f"__PENDING_SKIP_24H__ count={skip_count} cycles={total_cycles_24h} share={share}% status={payload['status']}")
PSKIP_24H_PY
}

now_ms() {
    local ms=""
    ms=$(date +%s%3N 2>/dev/null || true)
    if [[ "$ms" =~ ^[0-9]+$ ]]; then
        echo "$ms"
        return 0
    fi
    python3 - << 'PY'
import time
print(int(time.time() * 1000))
PY
}

status_log_cycle_perf() {
    # Użycie: status_log_cycle_perf <cycle> <mode> <category> <phase> <duration_ms> [detail]
    [ "${WORKER_PROFILING:-1}" = "0" ] && return 0
    local cycle="${1:-0}"
    local mode="${2:-IDLE}"
    local category="${3:--}"
    local phase="${4:-unknown}"
    local duration_ms="${5:-0}"
    local detail="${6:-}"

    mkdir -p "$STATUS_DIR" 2>/dev/null || true
    python3 - "$STATUS_DIR" "$cycle" "$mode" "$category" "$phase" "$duration_ms" "$detail" << 'PY'
import json
import os
import sys
from datetime import datetime, timezone

status_dir = sys.argv[1]
cycle = int(sys.argv[2]) if len(sys.argv) > 2 else 0
mode = sys.argv[3] if len(sys.argv) > 3 else "IDLE"
category = sys.argv[4] if len(sys.argv) > 4 else "-"
phase = sys.argv[5] if len(sys.argv) > 5 else "unknown"
try:
    duration_ms = int(float(sys.argv[6])) if len(sys.argv) > 6 else 0
except Exception:
    duration_ms = 0
detail = sys.argv[7] if len(sys.argv) > 7 else ""

os.makedirs(status_dir, exist_ok=True)
jsonl_path = os.path.join(status_dir, "worker_cycle_perf.jsonl")
latest_path = os.path.join(status_dir, "worker_cycle_perf_latest.json")

ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
event = {
    "timestamp": ts,
    "cycle": cycle,
    "mode": mode,
    "category": category,
    "phase": phase,
    "duration_ms": duration_ms,
}
if detail:
    event["detail"] = detail

try:
    if os.path.exists(jsonl_path) and os.path.getsize(jsonl_path) > 0:
        with open(jsonl_path, "rb+") as fb:
            fb.seek(-1, os.SEEK_END)
            last = fb.read(1)
            if last not in (b"\n", b"\r"):
                fb.write(b"\n")
    with open(jsonl_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")
except Exception:
    pass

latest = {
    "timestamp": ts,
    "cycle": cycle,
    "mode": mode,
    "category": category,
    "events": {
        phase: duration_ms,
    },
}
try:
    if os.path.exists(latest_path):
        with open(latest_path, "r", encoding="utf-8") as f:
            prev = json.load(f)
        if isinstance(prev, dict) and int(prev.get("cycle", -1)) == cycle:
            events = prev.get("events", {}) if isinstance(prev.get("events", {}), dict) else {}
            events[phase] = duration_ms
            latest = {
                "timestamp": ts,
                "cycle": cycle,
                "mode": mode,
                "category": category,
                "events": events,
            }
except Exception:
    pass

tmp = latest_path + ".tmp"
try:
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(latest, f, indent=2, ensure_ascii=False)
    os.replace(tmp, latest_path)
except Exception:
    pass
PY
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
    --lang-validate)
        FORCE_LANG="${2:-}"
        if [ -z "$FORCE_LANG" ]; then
            echo "Użycie: $0 --lang-validate <lang>"
            exit 1
        fi
        echo "🔬 Wymuszona walidacja języka: $FORCE_LANG"
        run_full_lang_validation 0 "$FORCE_LANG"
        ;;
    --lang-validate-all)
        echo "🔬 Wymuszona walidacja wszystkich języków"
        run_full_lang_validation 0 ""
        ;;
    --continuous)
        # Tryb ciągły - pracuje cały czas, przełącza się między trybami
        PID_FILE=".worker_simple.pid"
        LEGACY_PID_FILE="i18n_worker_continuous.pid"
        START_LOCK_FILE=".worker_simple.start.lock"

        cleanup_pid_files_if_owner() {
            for _pidf in "$PID_FILE" "$LEGACY_PID_FILE"; do
                [ -f "$_pidf" ] || continue
                _owner=$(cat "$_pidf" 2>/dev/null || echo "")
                if [ "$_owner" = "$$" ]; then
                    rm -f "$_pidf" 2>/dev/null || true
                fi
            done
        }

        if command -v flock >/dev/null 2>&1; then
            exec 7>"$START_LOCK_FILE"
            if ! flock -n 7; then
                existing_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
                if [[ "$existing_pid" =~ ^[0-9]+$ ]]; then
                    echo "Inny worker już działa (PID: $existing_pid). Zatrzymuję uruchomienie."
                else
                    echo "Inny worker już działa (lock startup). Zatrzymuję uruchomienie."
                fi
                exit 1
            fi
        fi

        if [ -f "$PID_FILE" ]; then
            existing_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
            if [[ "$existing_pid" =~ ^[0-9]+$ ]] && kill -0 "$existing_pid" 2>/dev/null; then
                echo "Inny worker już działa (PID: $existing_pid). Zatrzymuję uruchomienie."
                exit 1
            fi
        fi
        echo $$ > "$PID_FILE"
        echo $$ > "$LEGACY_PID_FILE"
        
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
                --langs)
                    TARGET_LANGS="${2:-}"
                    shift 2
                    ;;
                --translations-only)
                    TRANSLATIONS_ONLY=true
                    TRANSLATIONS_STRICT=true
                    shift
                    ;;
                --use-gt)
                    USE_GOOGLE_TRANSLATE=true
                    shift
                    ;;
                --gt-batch)
                    GT_BATCH_SIZE="${2:-50}"
                    shift 2
                    ;;
                --gt-delay)
                    GT_DELAY="${2:-1.5}"
                    shift 2
                    ;;
                --auto-fix-crossref)
                    CROSSREF_AUTO_FIX=true
                    shift
                    ;;
                --auto-fix-crossref-limit)
                    CROSSREF_AUTO_FIX_LIMIT="${2:-30}"
                    shift 2
                    ;;
                --no-adaptive-batch)
                    ADAPTIVE_BATCH_ENABLED=false
                    shift
                    ;;
                --parallel-langs)
                    PARALLEL_LANGS_PER_CYCLE="${2:-3}"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done

            export TRANSLATIONS_ONLY
            export TRANSLATIONS_STRICT
            export TARGET_LANGS
            export LANG_PRIORITY
            export STRICT_SELECTOR_CACHE_TTL_CYCLES
            export STATUS_UPDATE_EVERY_CYCLES
            export STATUS_UPDATE_MIN_INTERVAL_SEC
            export QUALITY_AUDIT_EVERY_CYCLES
            export QUALITY_AUDIT_MIN_INTERVAL_SEC
            export QUALITY_AUDIT_THRESHOLD
            export USE_GOOGLE_TRANSLATE
            export GT_BATCH_SIZE
            export GT_DELAY
            export CROSSREF_AUTO_FIX
            export CROSSREF_AUTO_FIX_LIMIT

        # 8.3: Zapamiętaj user-specified translate limit (0 = nie ustawiony → adaptive)
        USER_TRANSLATE_LIMIT="${TRANSLATE_LIMIT:-0}"
        # CLI flags: zachowane żeby config nie nadpisywał explicit CLI
        CLI_USE_GT="${USE_GOOGLE_TRANSLATE:-false}"

        ensure_tibia_proper_nouns >/dev/null 2>&1 || true
        ensure_external_dictionary_files >/dev/null 2>&1 || true
        save_default_worker_config
        
        echo "╔════════════════════════════════════════════════════════════════════╗"
        echo "║   I18N WORKER v3.1 - FULL AUTONOMOUS (24/7)                        ║"
        echo "║   PID: $$                                                          ║"
        echo "║   Batch: $BATCH plików | Przerwa: ${DELAY}s                        ║"
        [ "$NO_GIT" = "true" ] && echo "║   🚫 --no-git: Git push WYŁĄCZONY                                ║"
        [ "$TRANSLATE_LIMIT" -gt 0 ] 2>/dev/null && echo "║   📊 --translate-limit: max $TRANSLATE_LIMIT kluczy/cykl                       ║"
        [ -n "$TARGET_LANGS" ] && echo "║   🌐 --langs: $TARGET_LANGS                                         ║"
        [ "$TRANSLATIONS_ONLY" = "true" ] && echo "║   🌐 --translations-only: tylko tłumaczenia (STRICT, bez nowych kluczy)║"
        [ "$USE_GOOGLE_TRANSLATE" = "true" ] && echo "║   🌍 --use-gt: Google Translate fallback WŁĄCZONY (batch=$GT_BATCH_SIZE)║"
        [ "$CROSSREF_AUTO_FIX" = "true" ] && echo "║   🛠️ --auto-fix-crossref: ON (limit=$CROSSREF_AUTO_FIX_LIMIT / język)            ║"
        [ "$ADAPTIVE_BATCH_ENABLED" = "true" ] && echo "║   📈 Adaptive batch: ON (default=$ADAPTIVE_BATCH_DEFAULT, range=$ADAPTIVE_BATCH_MIN-$ADAPTIVE_BATCH_MAX) ║"
        [ "$PARALLEL_LANGS_PER_CYCLE" -gt 1 ] 2>/dev/null && echo "║   🔀 Parallel langs: $PARALLEL_LANGS_PER_CYCLE języki/cykl                                    ║"
        echo "║   Tryby: NPC → SCRIPTS → MONSTERS → ITEMS → AUTO_TRANSLATE        ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Aby zatrzymać: kill $$ lub Ctrl+C"
        echo ""
        
        CYCLE=0
        
        # Obsługa Ctrl+C
        trap 'echo ""; echo "⛔ Zatrzymuję worker..."; status_update_activity "interrupted" "${CYCLE:-0}" "${MODE_TYPE:-IDLE}" "signal" "${MODE_CAT:-}" "-" "stopping" 0 0 "units" 0; if should_force_status_update_on_metrics_delta; then echo "📊 Smart force status update (signal)"; if should_update_github_status force; then update_github_status; fi; elif should_update_github_status; then update_github_status; else echo "⏭️ Smart force: brak istotnych zmian metryk (signal), pomijam full status"; fi; cleanup_pid_files_if_owner; exit 0' SIGINT SIGTERM
        
        while true; do
            ACTIVE_PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
            if [[ "$ACTIVE_PID" =~ ^[0-9]+$ ]] && [ "$ACTIVE_PID" != "$$" ] && kill -0 "$ACTIVE_PID" 2>/dev/null; then
                echo "🔁 Wykryto nowszą instancję workera (PID: $ACTIVE_PID). Kończę PID $$"
                exit 0
            fi

            CYCLE=$((CYCLE + 1))
            CURRENT_CYCLE="$CYCLE"
            export CURRENT_CYCLE
            CYCLE_T0=$(now_ms)
            STOP_AFTER_CYCLE="false"
            MODE_EXTRA2=""  # Ważne: reset na początku cyklu, aby dispatcher nie był pomijany
            FORCE_LANG_VALIDATION=""

            # === 8.3: Reset translate_limit na początku cyklu (dla adaptive batch recalc) ===
            TRANSLATE_LIMIT="${USER_TRANSLATE_LIMIT:-0}"

            # === Runtime config: wczytaj worker_config.json co cykl ===
            load_worker_config

            # Jeśli worker jest wstrzymany (paused), czekaj
            if [ "${RUNTIME_PAUSED:-false}" = "true" ]; then
                echo "⏸️ Worker PAUSED (ustaw paused=false w worker_config.json aby wznowić)"
                sleep 10
                continue
            fi

            # Jeśli jest test_lang w config, wymusz cykl testowy
            if [ -n "${RUNTIME_TEST_LANG:-}" ]; then
                echo "🧪 TEST: wymuszam pełny test języka '${RUNTIME_TEST_LANG}'"
                PINNED_AUTO_LANG="$RUNTIME_TEST_LANG"
                PINNED_AUTO_JSON=""
                PINNED_AUTO_LIMIT=0
                FORCE_LANG_VALIDATION="$RUNTIME_TEST_LANG"
                # Wyczyść test_lang z config (jednorazowe)
                clear_test_lang_from_config
            fi

            # Jeśli jest test_all_langs_queue, pop następny język
            if [ -z "${RUNTIME_TEST_LANG:-}" ] && [ -n "${RUNTIME_TEST_QUEUE:-}" ]; then
                NEXT_TEST_LANG=$(pop_test_queue_lang 2>/dev/null || true)
                if [ -n "$NEXT_TEST_LANG" ]; then
                    echo "🧪 TEST_ALL: kolejny język z kolejki: '$NEXT_TEST_LANG'"
                    PINNED_AUTO_LANG="$NEXT_TEST_LANG"
                    PINNED_AUTO_JSON=""
                    PINNED_AUTO_LIMIT=0
                    FORCE_LANG_VALIDATION="$NEXT_TEST_LANG"
                fi
            fi

            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "🔄 CYKL #$CYCLE - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "═══════════════════════════════════════════════════════════════"

            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "cycle_start" "${MODE_CAT:-}" "-" "cycle start" 0 0 "units" 0
            APPLIED_APPROVALS=$(apply_manual_review_approvals 2>/dev/null || echo 0)
            if [ "${APPLIED_APPROVALS:-0}" -gt 0 ] 2>/dev/null; then
                echo "🧾 Zastosowano manual review approvals: $APPLIED_APPROVALS"
            fi
            DISPATCH_T0=$(now_ms)
            
            # Sprawdź komendy sterowania z plików
            # Najpierw sprawdź worker_commands.txt (dla GitHub), potem .worker_command (lokalny)
            COMMANDS_TXT_PRIMARY=".github/worker_commands.txt"
            COMMANDS_TXT_FALLBACK="worker_commands.txt"
            COMMAND_FILE=".worker_command"
            CMD=""
            
            # 1. Komendy z GitHub:
            # Preferuj .github/worker_commands.txt z origin/$GIT_TRACK_BRANCH (działa bez git pull)
            CMD_SOURCE=""
            if [ -n "$REPO_ROOT" ]; then
                REMOTE_CMDS=$(git -C "$REPO_ROOT" show "origin/$GIT_TRACK_BRANCH:Tibia/silnik/canary_test/.github/worker_commands.txt" 2>/dev/null || true)
                if [ -n "$REMOTE_CMDS" ]; then
                    CMD=$(echo "$REMOTE_CMDS" | grep -v '^#' | grep -v '^$' | grep -E '^(FORCE:|AUTO:|SYNC:|SWITCH:|UNSWITCH|LANGVAL:|SPOTCHECK:|GRAMMARFIX:|RESTART|COMPACT_KEYS|IDLE|RANDOM|STATUS|SELFTEST|SELF_CHECK|SKIP|PAUSE:|NOTE:|SET:|TEST:|TEST_ALL|GT:|BATCH:|REPORT|LANGS|CONFIG|FOCUS:|UNFOCUS|LANG:)' | head -1)
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
    if (!done && line ~ /^(FORCE:|AUTO:|SYNC:|SWITCH:|UNSWITCH|LANGVAL:|SPOTCHECK:|GRAMMARFIX:|RESTART|COMPACT_KEYS|IDLE|RANDOM|STATUS|SKIP|PAUSE:|NOTE:|SET:|TEST:|TEST_ALL|GT:|BATCH:|REPORT|LANGS|CONFIG|FOCUS:|UNFOCUS|LANG:)/) {
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
                        CMD=$(grep -v '^#' "$COMMANDS_TXT" | grep -v '^$' | grep -E '^(FORCE:|AUTO:|SYNC:|SWITCH:|UNSWITCH|LANGVAL:|SPOTCHECK:|GRAMMARFIX:|RESTART|COMPACT_KEYS|IDLE|RANDOM|STATUS|SELFTEST|SELF_CHECK|SKIP|PAUSE:|NOTE:|SET:|TEST:|TEST_ALL|GT:|BATCH:|REPORT|LANGS|CONFIG|FOCUS:|UNFOCUS|LANG:)' | head -1)
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
                    SWITCH:*)
                        # Format: SWITCH:<lang>[:json_file[:limit]]
                        SW_LANG=$(echo "$CMD" | cut -d: -f2)
                        SW_JSON=$(echo "$CMD" | cut -d: -f3)
                        SW_LIMIT=$(echo "$CMD" | cut -d: -f4)
                        if [ -z "$SW_LANG" ]; then
                            echo "⚠️ SWITCH: brak języka (użyj SWITCH:<lang>[:json[:limit]])"
                        else
                            PINNED_AUTO_LANG="$SW_LANG"
                            PINNED_AUTO_JSON="$SW_JSON"
                            PINNED_AUTO_LIMIT="${SW_LIMIT:-0}"
                            echo "🔁 SWITCH: przypinam AUTO_TRANSLATE na '$PINNED_AUTO_LANG' (json='${PINNED_AUTO_JSON:-auto}', limit=${PINNED_AUTO_LIMIT:-0})"

                            MODE_TYPE="AUTO_TRANSLATE"
                            MODE_CAT="$PINNED_AUTO_LANG"
                            if [ -n "$PINNED_AUTO_JSON" ]; then
                                MODE_COUNT="$PINNED_AUTO_JSON"
                                MODE_EXTRA="${PINNED_AUTO_LIMIT:-0}"
                            else
                                STRICT_TARGET=$(TARGET_LANGS="$PINNED_AUTO_LANG" select_auto_translate_target_strict)
                                S_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                                S_LANG=$(echo "$STRICT_TARGET" | cut -d: -f2)
                                S_JSON=$(echo "$STRICT_TARGET" | cut -d: -f3)
                                S_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)
                                if [ "$S_TYPE" = "AUTO_TRANSLATE" ]; then
                                    MODE_CAT="$S_LANG"
                                    MODE_COUNT="$S_JSON"
                                    MODE_EXTRA="$S_EXTRA"
                                else
                                    MODE_TYPE="IDLE"
                                    MODE_CAT="switch_no_pending"
                                    MODE_COUNT="0"
                                    MODE_EXTRA="SWITCH"
                                fi
                            fi
                            MODE_EXTRA2="AUTO"
                        fi
                        ;;
                    UNSWITCH)
                        echo "🔓 UNSWITCH: zdejmuję przypięcie języka AUTO_TRANSLATE"
                        PINNED_AUTO_LANG=""
                        PINNED_AUTO_JSON=""
                        PINNED_AUTO_LIMIT=0
                        PINNED_AUTO_JSON_LIST=""
                        PINNED_AUTO_JSON_IDX=0
                        ;;
                    LANGVAL:*)
                        # Format: LANGVAL:all lub LANGVAL:<lang>
                        LV_ARG=$(echo "$CMD" | cut -d: -f2)
                        LV_ARG=${LV_ARG:-all}
                        if [ "$LV_ARG" = "all" ]; then
                            FORCE_LANG_VALIDATION="all"
                            echo "🔬 LANGVAL: wymuszam walidację wszystkich języków po tym cyklu"
                        else
                            FORCE_LANG_VALIDATION="$LV_ARG"
                            echo "🔬 LANGVAL: wymuszam walidację języka '$LV_ARG' po tym cyklu"
                        fi
                        ;;
                    SPOTCHECK:*)
                        # Format: SPOTCHECK:<lang>[:sample]
                        SC_LANG=$(echo "$CMD" | cut -d: -f2)
                        SC_SAMPLE=$(echo "$CMD" | cut -d: -f3)
                        SC_SAMPLE=${SC_SAMPLE:-20}
                        echo "🧪 SPOTCHECK: język '$SC_LANG' (sample=$SC_SAMPLE)"
                        SC_OUT=$(run_language_spotcheck "$SC_LANG" "$SC_SAMPLE")
                        [ -n "$SC_OUT" ] && echo "$SC_OUT"
                        if [ "$STOP_AFTER_CYCLE" = "true" ]; then
                            echo "🛑 TRYB JEDNORAZOWY: kończę po SPOTCHECK"
                            break
                        fi
                        continue
                        ;;
                    GRAMMARFIX:*)
                        # Format: GRAMMARFIX:<lang>[:json_file[:limit]]
                        GF_LANG=$(echo "$CMD" | cut -d: -f2)
                        GF_JSON=$(echo "$CMD" | cut -d: -f3)
                        GF_LIMIT=$(echo "$CMD" | cut -d: -f4)
                        GF_JSON=${GF_JSON:-npc.json}
                        GF_LIMIT=${GF_LIMIT:-20}
                        echo "🧠 GRAMMARFIX: język '$GF_LANG', plik '$GF_JSON', limit=$GF_LIMIT"
                        GF_OUT=$(run_language_grammar_fix "$GF_LANG" "$GF_JSON" "$GF_LIMIT")
                        [ -n "$GF_OUT" ] && echo "$GF_OUT"
                        if [ -n "$GF_LANG" ]; then
                            run_full_lang_validation "$CYCLE" "$GF_LANG"
                        fi
                        if [ "$STOP_AFTER_CYCLE" = "true" ]; then
                            echo "🛑 TRYB JEDNORAZOWY: kończę po GRAMMARFIX"
                            break
                        fi
                        continue
                        ;;
                    SELFTEST|SELF_CHECK)
                        echo "🧪 Wymuszam SELFTEST"
                        MODE_TYPE="SELFTEST"
                        MODE_CAT="-"
                        MODE_COUNT="0"
                        MODE_EXTRA="FORCED"
                        ;;
                    RESTART)
                        echo "🔄 RESTART: worker zakończy bieżący cykl i zrestartuje się"
                        echo "   → git pull + exec z tymi samymi argumentami"
                        RESTART_REQUESTED=true
                        STOP_AFTER_CYCLE=true
                        ;;
                    # ===== Nowe komendy runtime (continuous control) =====
                    FOCUS:*)
                        # Alias dla SWITCH — bardziej intuicyjny
                        SW_LANG=$(echo "$CMD" | cut -d: -f2)
                        SW_JSON=$(echo "$CMD" | cut -d: -f3)
                        SW_LIMIT=$(echo "$CMD" | cut -d: -f4)
                        if [ -n "$SW_LANG" ]; then
                            PINNED_AUTO_LANG="$SW_LANG"
                            PINNED_AUTO_JSON="${SW_JSON:-}"
                            PINNED_AUTO_LIMIT="${SW_LIMIT:-0}"
                            # Synchronizuj do config
                            update_worker_config "focus_lang" "$SW_LANG" >/dev/null 2>&1 || true
                            [ -n "$SW_JSON" ] && update_worker_config "focus_category" "$SW_JSON" >/dev/null 2>&1 || true
                            echo "🎯 FOCUS: przypinam na '$SW_LANG' (kategoria='${SW_JSON:-auto}', limit=${SW_LIMIT:-0})"
                            MODE_TYPE="AUTO_TRANSLATE"
                            MODE_CAT="$PINNED_AUTO_LANG"
                            if [ -n "$PINNED_AUTO_JSON" ]; then
                                MODE_COUNT="$PINNED_AUTO_JSON"
                                MODE_EXTRA="${PINNED_AUTO_LIMIT:-0}"
                            else
                                STRICT_TARGET=$(TARGET_LANGS="$PINNED_AUTO_LANG" select_auto_translate_target_strict)
                                S_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                                S_LANG=$(echo "$STRICT_TARGET" | cut -d: -f2)
                                S_JSON=$(echo "$STRICT_TARGET" | cut -d: -f3)
                                S_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)
                                if [ "$S_TYPE" = "AUTO_TRANSLATE" ]; then
                                    MODE_CAT="$S_LANG"
                                    MODE_COUNT="$S_JSON"
                                    MODE_EXTRA="$S_EXTRA"
                                else
                                    MODE_TYPE="IDLE"
                                    MODE_CAT="focus_no_pending"
                                    MODE_COUNT="0"
                                    MODE_EXTRA="FOCUS"
                                fi
                            fi
                            MODE_EXTRA2="AUTO"
                        else
                            echo "⚠️ FOCUS: brak języka (użyj FOCUS:<lang>[:json[:limit]])"
                        fi
                        ;;
                    UNFOCUS)
                        echo "🔓 UNFOCUS: zdejmuję przypięcie języka"
                        PINNED_AUTO_LANG=""
                        PINNED_AUTO_JSON=""
                        PINNED_AUTO_LIMIT=0
                        PINNED_AUTO_JSON_LIST=""
                        PINNED_AUTO_JSON_IDX=0
                        update_worker_config "focus_lang" "" >/dev/null 2>&1 || true
                        update_worker_config "focus_category" "" >/dev/null 2>&1 || true
                        ;;
                    LANG:*)
                        # Format: LANG:<lang> — przypiąj język (worker cyklicznie przechodzi pliki)
                        # Format: LANG:<lang>:<plik1>,<plik2>,... — przypiąj język + konkretne pliki
                        # Format: LANG:random — powrót do losowego trybu
                        LANG_ARG=$(echo "$CMD" | cut -d: -f2)
                        LANG_FILES=$(echo "$CMD" | cut -d: -f3-)
                        
                        if [ "$LANG_ARG" = "random" ] || [ "$LANG_ARG" = "RANDOM" ] || [ "$LANG_ARG" = "*" ]; then
                            echo "🎲 LANG:random — przywracam tryb losowy (wszystkie języki)"
                            PINNED_AUTO_LANG=""
                            PINNED_AUTO_JSON=""
                            PINNED_AUTO_LIMIT=0
                            PINNED_AUTO_JSON_LIST=""
                            PINNED_AUTO_JSON_IDX=0
                            update_worker_config "focus_lang" "" >/dev/null 2>&1 || true
                            update_worker_config "focus_category" "" >/dev/null 2>&1 || true
                        elif [ -z "$LANG_ARG" ]; then
                            echo "⚠️ LANG: brak języka (użyj LANG:<lang> lub LANG:<lang>:<plik1>,<plik2>,...  lub LANG:random)"
                        else
                            PINNED_AUTO_LANG="$LANG_ARG"
                            PINNED_AUTO_LIMIT=0
                            
                            if [ -n "$LANG_FILES" ]; then
                                # Multi-file mode: LANG:de:npc.json,items.json,spells.json
                                PINNED_AUTO_JSON_LIST="$LANG_FILES"
                                PINNED_AUTO_JSON_IDX=0
                                # Ustaw pierwszy plik jako aktualny
                                FIRST_FILE=$(echo "$LANG_FILES" | cut -d, -f1)
                                PINNED_AUTO_JSON="$FIRST_FILE"
                                
                                FILE_COUNT=$(echo "$LANG_FILES" | tr ',' '\n' | wc -l)
                                echo "🌐 LANG: przypinam język '$LANG_ARG' z $FILE_COUNT plikami: $LANG_FILES"
                                echo "   → zaczynamy od: $FIRST_FILE"
                            else
                                # Single-lang mode: auto-wybór plików
                                PINNED_AUTO_JSON=""
                                PINNED_AUTO_JSON_LIST=""
                                PINNED_AUTO_JSON_IDX=0
                                echo "🌐 LANG: przypinam język '$LANG_ARG' (auto-wybór plików z pending)"
                            fi
                            
                            update_worker_config "focus_lang" "$LANG_ARG" >/dev/null 2>&1 || true
                            [ -n "$LANG_FILES" ] && update_worker_config "focus_category" "$LANG_FILES" >/dev/null 2>&1 || true
                            
                            # Ustaw tryb na AUTO_TRANSLATE
                            MODE_TYPE="AUTO_TRANSLATE"
                            MODE_CAT="$PINNED_AUTO_LANG"
                            if [ -n "$PINNED_AUTO_JSON" ]; then
                                MODE_COUNT="$PINNED_AUTO_JSON"
                                MODE_EXTRA="${PINNED_AUTO_LIMIT:-0}"
                            else
                                STRICT_TARGET=$(TARGET_LANGS="$PINNED_AUTO_LANG" select_auto_translate_target_strict)
                                S_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                                S_LANG=$(echo "$STRICT_TARGET" | cut -d: -f2)
                                S_JSON=$(echo "$STRICT_TARGET" | cut -d: -f3)
                                S_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)
                                if [ "$S_TYPE" = "AUTO_TRANSLATE" ]; then
                                    MODE_CAT="$S_LANG"
                                    MODE_COUNT="$S_JSON"
                                    MODE_EXTRA="$S_EXTRA"
                                else
                                    MODE_TYPE="IDLE"
                                    MODE_CAT="lang_no_pending"
                                    MODE_COUNT="0"
                                    MODE_EXTRA="LANG"
                                fi
                            fi
                            MODE_EXTRA2="AUTO"
                        fi
                        ;;
                    TEST:*)
                        # Format: TEST:<lang> — pełen cykl testowy: translate + validate + crossref
                        T_LANG=$(echo "$CMD" | cut -d: -f2)
                        echo "🧪 TEST: wymuszam pełen cykl testowy dla języka '$T_LANG'"
                        PINNED_AUTO_LANG="$T_LANG"
                        PINNED_AUTO_JSON=""
                        PINNED_AUTO_LIMIT=0
                        FORCE_LANG_VALIDATION="$T_LANG"

                        # Automatyczny strict target
                        STRICT_TARGET=$(TARGET_LANGS="$T_LANG" select_auto_translate_target_strict)
                        S_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                        S_LANG=$(echo "$STRICT_TARGET" | cut -d: -f2)
                        S_JSON=$(echo "$STRICT_TARGET" | cut -d: -f3)
                        S_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)
                        if [ "$S_TYPE" = "AUTO_TRANSLATE" ]; then
                            MODE_TYPE="AUTO_TRANSLATE"
                            MODE_CAT="$S_LANG"
                            MODE_COUNT="$S_JSON"
                            MODE_EXTRA="$S_EXTRA"
                        else
                            MODE_TYPE="IDLE"
                            MODE_CAT="test_no_pending"
                            MODE_COUNT="0"
                            MODE_EXTRA="TEST"
                        fi
                        MODE_EXTRA2="AUTO"
                        STOP_AFTER_CYCLE="true"
                        ;;
                    TEST_ALL)
                        # Wstaw wszystkie języki do kolejki testowej
                        echo "🧪 TEST_ALL: tworzę kolejkę testową dla WSZYSTKICH języków"
                        python3 - "$WORKER_CONFIG_FILE" << 'TESTALLPY'
import json, os, re, sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    cfg = {}

i18n_dir = "i18n"
langs = []
if os.path.isdir(i18n_dir):
    for name in sorted(os.listdir(i18n_dir)):
        p = os.path.join(i18n_dir, name)
        if os.path.isdir(p) and name != "en" and re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            langs.append(name)

cfg["test_all_langs_queue"] = langs
with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
print(f"Dodano {len(langs)} języków do kolejki: {' '.join(langs[:10])}...")
TESTALLPY
                        ;;
                    GT:on|GT:ON)
                        echo "🌍 GT: włączam Google Translate"
                        USE_GOOGLE_TRANSLATE=true
                        update_worker_config "use_gt" "true" >/dev/null 2>&1 || true
                        ;;
                    GT:off|GT:OFF)
                        echo "🌍 GT: wyłączam Google Translate"
                        USE_GOOGLE_TRANSLATE=false
                        update_worker_config "use_gt" "false" >/dev/null 2>&1 || true
                        ;;
                    BATCH:*)
                        NEW_BATCH=$(echo "$CMD" | cut -d: -f2)
                        echo "📊 BATCH: ustawiam translate_limit=$NEW_BATCH"
                        TRANSLATE_LIMIT="$NEW_BATCH"
                        USER_TRANSLATE_LIMIT="$NEW_BATCH"
                        update_worker_config "translate_limit" "$NEW_BATCH" >/dev/null 2>&1 || true
                        ;;
                    SET:*)
                        # Format: SET:key=value — zmienia wartość w worker_config.json
                        SET_PAIR=$(echo "$CMD" | cut -d: -f2-)
                        SET_KEY=$(echo "$SET_PAIR" | cut -d= -f1)
                        SET_VAL=$(echo "$SET_PAIR" | cut -d= -f2-)
                        if [ -n "$SET_KEY" ] && [ -n "$SET_VAL" ]; then
                            echo "⚙️ SET: $SET_KEY=$SET_VAL"
                            update_worker_config "$SET_KEY" "$SET_VAL"
                            # Reload config aby zmiany zaczęły działać od razu
                            load_worker_config
                        else
                            echo "⚠️ SET: nieprawidłowy format (użyj SET:key=value)"
                        fi
                        ;;
                    REPORT)
                        # Wygeneruj skrócony raport statusu języków
                        echo "📊 REPORT: generuję raport..."
                        python3 << 'REPORTPY'
import json, os, re

i18n_dir = "i18n"
status_dir = os.path.join(i18n_dir, "status")
en_dir = os.path.join(i18n_dir, "en")

# Zlicz klucze EN
en_total = 0
en_files = {}
if os.path.isdir(en_dir):
    for f in sorted(os.listdir(en_dir)):
        if f.endswith(".json"):
            try:
                data = json.load(open(os.path.join(en_dir, f), encoding="utf-8"))
                en_files[f] = len(data)
                en_total += len(data)
            except Exception:
                pass

# Zlicz coverage per-lang
langs = []
if os.path.isdir(i18n_dir):
    for name in sorted(os.listdir(i18n_dir)):
        p = os.path.join(i18n_dir, name)
        if os.path.isdir(p) and name != "en" and re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            langs.append(name)

print(f"📊 Klucze EN: {en_total} (w {len(en_files)} plikach)")
print(f"📊 Języki: {len(langs)}")
print(f"{'─'*60}")
print(f"{'Język':<8} {'Kluczy':<10} {'Coverage':<10} {'Tier':<6}")
print(f"{'─'*60}")

# Load tier config
tier1 = set(os.environ.get("TIER1_LANGS", "pl es").split())
tier2 = set(os.environ.get("TIER2_LANGS", "de pt ru tr fr it").split())

for lang in langs:
    lang_total = 0
    translated = 0
    for fname, en_count in en_files.items():
        lpath = os.path.join(i18n_dir, lang, fname)
        if os.path.exists(lpath):
            try:
                ldata = json.load(open(lpath, encoding="utf-8"))
                lang_total += len(ldata)
                # Policz przetłumaczone (nie-placeholder, nie-identical do EN)
                en_data = json.load(open(os.path.join(en_dir, fname), encoding="utf-8"))
                for k, v in ldata.items():
                    ev = en_data.get(k, "")
                    if v and str(v) != str(ev) and not str(v).startswith("["):
                        translated += 1
            except Exception:
                pass

    pct = (translated / en_total * 100) if en_total > 0 else 0
    tier = "T1" if lang in tier1 else ("T2" if lang in tier2 else "T3")
    bar = "█" * int(pct / 5) + "░" * (20 - int(pct / 5))
    print(f"{lang:<8} {translated:<10} {pct:>5.1f}%     {tier}")

print(f"{'─'*60}")
REPORTPY
                        continue
                        ;;
                    LANGS)
                        # Lista dostępnych języków
                        echo "🌐 LANGS: dostępne języki:"
                        ls -d i18n/*/  2>/dev/null | sed 's|i18n/||;s|/||' | grep -v '^en$' | sort | tr '\n' ' '
                        echo ""
                        continue
                        ;;
                    CONFIG)
                        # Wyświetl aktualny config
                        echo "⚙️ CONFIG: aktualna konfiguracja runtime:"
                        if [ -f "$WORKER_CONFIG_FILE" ]; then
                            python3 -c "import json; cfg=json.load(open('$WORKER_CONFIG_FILE')); [print(f'  {k}: {v}') for k,v in cfg.items() if not k.startswith('_')]"
                        else
                            echo "  (brak pliku $WORKER_CONFIG_FILE)"
                        fi
                        echo ""
                        echo "📌 Zmienne aktywne:"
                        echo "  USE_GOOGLE_TRANSLATE=$USE_GOOGLE_TRANSLATE"
                        echo "  GT_BATCH_SIZE=$GT_BATCH_SIZE"
                        echo "  TRANSLATE_LIMIT=$TRANSLATE_LIMIT"
                        echo "  PARALLEL_LANGS_PER_CYCLE=$PARALLEL_LANGS_PER_CYCLE"
                        echo "  ADAPTIVE_BATCH_ENABLED=$ADAPTIVE_BATCH_ENABLED"
                        echo "  CROSSREF_AUTO_FIX=$CROSSREF_AUTO_FIX"
                        echo "  PINNED_AUTO_LANG=${PINNED_AUTO_LANG:-<none>}"
                        echo "  PINNED_AUTO_JSON=${PINNED_AUTO_JSON:-<auto>}"
                        echo "  PINNED_AUTO_JSON_LIST=${PINNED_AUTO_JSON_LIST:-<none>}"
                        echo "  PINNED_AUTO_JSON_IDX=${PINNED_AUTO_JSON_IDX:-0}"
                        continue
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
            
            # --translations-only strict: wyłącznie tłumaczenia istniejących kluczy, bez dodawania nowych.
            # Multi-file cycling: jeśli PINNED_AUTO_JSON_LIST jest ustawiona, cyklicznie przechodź pliki
            if [ -n "${PINNED_AUTO_JSON_LIST:-}" ] && [ -n "${PINNED_AUTO_LANG:-}" ] && [ "$MODE_EXTRA2" != "AUTO" ]; then
                # Oblicz ile plików w liście
                _FILE_COUNT=$(echo "$PINNED_AUTO_JSON_LIST" | tr ',' '\n' | wc -l)
                if [ "$_FILE_COUNT" -gt 1 ]; then
                    # Przejdź do następnego pliku w liście
                    PINNED_AUTO_JSON_IDX=$(( (PINNED_AUTO_JSON_IDX + 1) % _FILE_COUNT ))
                    _NEXT_FILE=$(echo "$PINNED_AUTO_JSON_LIST" | tr ',' '\n' | sed -n "$((PINNED_AUTO_JSON_IDX + 1))p" | tr -d ' ')
                    if [ -n "$_NEXT_FILE" ]; then
                        PINNED_AUTO_JSON="$_NEXT_FILE"
                        echo "📂 LANG multi-file: przechodzę do pliku [$((PINNED_AUTO_JSON_IDX + 1))/$_FILE_COUNT]: $_NEXT_FILE"
                    fi
                fi
            fi

            if [ "$TRANSLATIONS_ONLY" = "true" ] && [ -n "$PINNED_AUTO_LANG" ] && [ "$MODE_EXTRA2" != "AUTO" ] && [ "$MODE_EXTRA2" != "SYNC" ]; then
                if [ -n "$PINNED_AUTO_JSON" ]; then
                    MODE_TYPE="AUTO_TRANSLATE"
                    MODE_CAT="$PINNED_AUTO_LANG"
                    MODE_COUNT="$PINNED_AUTO_JSON"
                    MODE_EXTRA="${PINNED_AUTO_LIMIT:-0}"
                    MODE_EXTRA2="AUTO"
                    echo "📌 PINNED LANG: $PINNED_AUTO_LANG/$PINNED_AUTO_JSON (limit=${PINNED_AUTO_LIMIT:-0})"
                else
                    STRICT_TARGET=$(TARGET_LANGS="$PINNED_AUTO_LANG" select_auto_translate_target_strict)
                    S_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                    S_LANG=$(echo "$STRICT_TARGET" | cut -d: -f2)
                    S_JSON=$(echo "$STRICT_TARGET" | cut -d: -f3)
                    S_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)
                    if [ "$S_TYPE" = "AUTO_TRANSLATE" ]; then
                        MODE_TYPE="$S_TYPE"
                        MODE_CAT="$S_LANG"
                        MODE_COUNT="$S_JSON"
                        MODE_EXTRA="$S_EXTRA"
                        MODE_EXTRA2="AUTO"
                        echo "📌 PINNED LANG: $S_LANG/$S_JSON (pending=$S_EXTRA)"
                    fi
                fi
            fi

            if [ "$TRANSLATIONS_ONLY" = "true" ] && [ "$MODE_TYPE" != "AUTO_TRANSLATE" ] && [ "$MODE_EXTRA2" != "SYNC" ]; then
                echo "🌐 --translations-only: pomijam MIGRATION/SYNC, wybieram AUTO_TRANSLATE STRICT"
                STRICT_TARGET=$(select_auto_translate_target_strict)
                MODE_TYPE=$(echo "$STRICT_TARGET" | cut -d: -f1)
                MODE_CAT=$(echo "$STRICT_TARGET" | cut -d: -f2)
                MODE_COUNT=$(echo "$STRICT_TARGET" | cut -d: -f3)
                MODE_EXTRA=$(echo "$STRICT_TARGET" | cut -d: -f4)

                # P1: jeśli strict blokuje przez brakujące pliki/klucze, uruchom automatyczny backfill SYNC
                if [ "$MODE_TYPE" = "IDLE" ] && [ "$MODE_CAT" = "translation_only_blocked" ]; then
                    SYNC_TARGET=$(select_translation_sync_target)
                    SYNC_LANG=$(echo "$SYNC_TARGET" | cut -d: -f1)
                    SYNC_JSON=$(echo "$SYNC_TARGET" | cut -d: -f2)
                    SYNC_MISSING=$(echo "$SYNC_TARGET" | cut -d: -f3)
                    SYNC_MISSING=${SYNC_MISSING:-0}
                    if [ "$SYNC_MISSING" -gt 0 ] 2>/dev/null; then
                        echo "🔧 P1: strict blocked → przełączam na TRANSLATION_SYNC ($SYNC_LANG/$SYNC_JSON, missing=$SYNC_MISSING)"
                        MODE_TYPE="TRANSLATION_SYNC"
                        MODE_CAT="$SYNC_LANG"
                        MODE_COUNT="$SYNC_JSON"
                        MODE_EXTRA="$SYNC_MISSING"
                        MODE_EXTRA2="SYNC"
                    fi
                fi
            fi
            
            if [ "$MODE_TYPE" = "AUTO_TRANSLATE" ]; then
                echo "📋 Dispatcher: $MODE_TYPE | Język: $MODE_CAT | Plik: ${MODE_COUNT:--} | Pending: ${MODE_EXTRA:-0}"
            else
                echo "📋 Dispatcher: $MODE_TYPE | Kategoria: $MODE_CAT | Ilość: ${MODE_COUNT:-0}"
            fi
            echo ""

            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "dispatch" "${MODE_CAT:-}" "-" "selected" 0 "${MODE_COUNT:-0}" "items" 0
            DISPATCH_T1=$(now_ms)
            status_log_cycle_perf "$CYCLE" "${MODE_TYPE:-IDLE}" "${MODE_CAT:--}" "dispatch" "$((DISPATCH_T1 - DISPATCH_T0))" "count=${MODE_COUNT:-0}"
            
            # Zlicz klucze PRZED przetwarzaniem (do wykrycia czy coś dodano)
            KEYS_BEFORE=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
            MODE_T0=$(now_ms)
            
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
                        log_pending_skip_event "$CYCLE" "${MODE_COUNT:-0}" "backoff"
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
                    EXPORT_OUT=$(python3 tools/json_to_lua_locales.py --all --server-dir i18n --client-dir testyy/data/locales --compact-keys --i18n-dir i18n 2>&1)
                    EXPORT_RC=$?
                    if [ "$EXPORT_RC" -ne 0 ]; then
                        status_log_error "$CYCLE" "COMPACT_KEYS" "export" "-" "-" "json_to_lua_locales.py compact export failed" "check tool"
                        break
                    fi
                    # Policz wyeksportowane języki (compact lua pliki)
                    EXPORTED_LANGS=$(ls -1 testyy/data/locales/game_i18n_*_compact.lua 2>/dev/null | sed 's/.*game_i18n_//;s/_compact\.lua//' | sort | tr '\n' ',' | sed 's/,$//')
                    EXPORTED_LANGS_COUNT=$(echo "$EXPORTED_LANGS" | tr ',' '\n' | grep -c . 2>/dev/null || echo 0)
                    status_log_op "$CYCLE" "COMPACT_KEYS" "export_done" "-" "-" "ok" "exported_langs=${EXPORTED_LANGS} count=${EXPORTED_LANGS_COUNT}" "" "" "0"
                    status_update_activity "running" "$CYCLE" "COMPACT_KEYS" "done" "-" "-" "compact keys ready (${EXPORTED_LANGS_COUNT} langs)" "$MAPPED_NEW" "$MAPPED_NEW" "mapped" 0
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

                    # P1: po sync czyść cache strict selector, by następny wybór użył świeżych danych
                    if [ "$SYNCED_KEYS" -gt 0 ] 2>/dev/null; then
                        rm -f "$STATUS_DIR/translation_strict_candidates_cache.json" 2>/dev/null || true
                    fi

                    # LIVE: zakończ etap sync dla czytelnego dashboardu
                    status_update_activity "running" "$CYCLE" "TRANSLATION_SYNC" "sync_done" "$MODE_CAT" "$MODE_COUNT" "synced" "$SYNCED_KEYS" "$SYNCED_KEYS" "keys" 0
                    ;;
                AUTO_TRANSLATE)
                    echo "🌍 TRYB: AUTO TRANSLATE (język: $MODE_CAT, plik: $MODE_COUNT, kluczy: $MODE_EXTRA)"

                    # === 8.3: Adaptive batch tuning ===
                    compute_adaptive_batch

                    if [[ "$MODE_COUNT" =~ ^(client|php|html|ui|otclient_modules|otclient_data|otclient_src|otclient_mods|otclient_tools)\.json$ ]]; then
                        echo "   📁 Folder: ${MODE_CAT^^} - Klient"
                    else
                        echo "   📁 Folder: ${MODE_CAT^^} - Serwer"
                    fi
                    
                    # Automatyczne tłumaczenie BEZ interakcji!
                    status_update_activity "running" "$CYCLE" "AUTO_TRANSLATE" "auto_start" "$MODE_CAT" "$MODE_COUNT" "auto translate" 0 0 "keys" 0
                    read -r AT_TRANSLATED AT_PLACEHOLDERS AT_GUARD_FAIL AT_GUARD_PLACEHOLDER AT_GUARD_COMMAND AT_GUARD_PIPE AT_SKIPPED_MISSING_FILE AT_SKIPPED_MISSING_KEY AT_SKIPPED_NOT_PLACEHOLDER <<< "$(auto_translate_keys "$MODE_CAT" "$MODE_COUNT" "$MODE_EXTRA")"
                    AT_TRANSLATED=${AT_TRANSLATED:-0}
                    AT_PLACEHOLDERS=${AT_PLACEHOLDERS:-0}
                    AT_GUARD_FAIL=${AT_GUARD_FAIL:-0}
                    AT_GUARD_PLACEHOLDER=${AT_GUARD_PLACEHOLDER:-0}
                    AT_GUARD_COMMAND=${AT_GUARD_COMMAND:-0}
                    AT_GUARD_PIPE=${AT_GUARD_PIPE:-0}
                    AT_SKIPPED_MISSING_FILE=${AT_SKIPPED_MISSING_FILE:-0}
                    AT_SKIPPED_MISSING_KEY=${AT_SKIPPED_MISSING_KEY:-0}
                    AT_SKIPPED_NOT_PLACEHOLDER=${AT_SKIPPED_NOT_PLACEHOLDER:-0}
                    AT_FILES_CHANGED=0
                    if [ "$AT_TRANSLATED" -gt 0 ] 2>/dev/null || [ "$AT_PLACEHOLDERS" -gt 0 ] 2>/dev/null; then
                        AT_FILES_CHANGED=1
                    fi

                    append_translation_guard_report "$CYCLE" "$MODE_CAT" "$MODE_COUNT" "$AT_TRANSLATED" "$AT_PLACEHOLDERS" "$AT_GUARD_FAIL" "$AT_GUARD_PLACEHOLDER" "$AT_GUARD_COMMAND" "$AT_GUARD_PIPE" "$AT_SKIPPED_MISSING_FILE" "$AT_SKIPPED_MISSING_KEY" "$AT_SKIPPED_NOT_PLACEHOLDER"

                    AUTO_RESULT_STATUS="ok"
                    AUTO_DETAIL="lang=${MODE_CAT} file=${MODE_COUNT}"
                    if [ "$AT_SKIPPED_MISSING_FILE" -gt 0 ] 2>/dev/null || [ "$AT_SKIPPED_MISSING_KEY" -gt 0 ] 2>/dev/null; then
                        AUTO_RESULT_STATUS="warn"
                        AUTO_DETAIL="${AUTO_DETAIL} strict_skip missing_file=${AT_SKIPPED_MISSING_FILE} missing_key=${AT_SKIPPED_MISSING_KEY} skipped_done=${AT_SKIPPED_NOT_PLACEHOLDER}"
                        status_log_error "$CYCLE" "AUTO_TRANSLATE" "AUTO_TRANSLATE_STRICT_SKIP" "$MODE_CAT" "$MODE_COUNT" "strict_skip missing_file=$AT_SKIPPED_MISSING_FILE missing_key=$AT_SKIPPED_MISSING_KEY" "skipped_not_placeholder=$AT_SKIPPED_NOT_PLACEHOLDER"
                    fi
                    if [ "$AT_SKIPPED_NOT_PLACEHOLDER" -gt 0 ] 2>/dev/null; then
                        AUTO_RESULT_STATUS="warn"
                        AUTO_DETAIL="${AUTO_DETAIL} strict_skipped_done=${AT_SKIPPED_NOT_PLACEHOLDER}"
                        status_log_error "$CYCLE" "AUTO_TRANSLATE" "AUTO_TRANSLATE_NO_PROGRESS" "$MODE_CAT" "$MODE_COUNT" "strict_skipped_done=$AT_SKIPPED_NOT_PLACEHOLDER translated=$AT_TRANSLATED" "review placeholder/en-copy backlog"
                    fi
                    if [ "$AT_GUARD_FAIL" -gt 0 ] 2>/dev/null; then
                        AUTO_RESULT_STATUS="warn"
                        AUTO_DETAIL="${AUTO_DETAIL} guard_fail=${AT_GUARD_FAIL} placeholder=${AT_GUARD_PLACEHOLDER} command=${AT_GUARD_COMMAND} pipe=${AT_GUARD_PIPE}"
                        status_log_error "$CYCLE" "AUTO_TRANSLATE" "AUTO_TRANSLATE_GUARD" "$MODE_CAT" "$MODE_COUNT" "guard_fail=$AT_GUARD_FAIL" "placeholder=$AT_GUARD_PLACEHOLDER command=$AT_GUARD_COMMAND pipe=$AT_GUARD_PIPE"
                        echo "   ⚠️ Guard: fail=$AT_GUARD_FAIL (placeholder=$AT_GUARD_PLACEHOLDER, command=$AT_GUARD_COMMAND, pipe=$AT_GUARD_PIPE)"
                    fi

                    status_log_op "$CYCLE" "AUTO_TRANSLATE" "AUTO_TRANSLATE_DONE" "$MODE_CAT" "$MODE_COUNT" "$AUTO_RESULT_STATUS" "$AUTO_DETAIL" "" "$AT_FILES_CHANGED" "" "$AT_TRANSLATED" "$AT_PLACEHOLDERS"

                    # LIVE: zakończ etap auto dla czytelnego dashboardu
                    status_update_activity "running" "$CYCLE" "AUTO_TRANSLATE" "auto_done" "$MODE_CAT" "$MODE_COUNT" "translated=$AT_TRANSLATED guard_fail=$AT_GUARD_FAIL strict_missing_key=$AT_SKIPPED_MISSING_KEY strict_skipped_done=$AT_SKIPPED_NOT_PLACEHOLDER" "$AT_TRANSLATED" "$AT_TRANSLATED" "keys" 0

                    # === 8.4: Parallel language processing ===
                    # Po przetworzeniu głównego targetu, przetłumacz dodatkowe języki w tym samym cyklu
                    if [ "${PARALLEL_LANGS_PER_CYCLE:-1}" -gt 1 ] 2>/dev/null && [ "$TRANSLATIONS_ONLY" = "true" ]; then
                        PARALLEL_DONE=1  # już przetworzony 1 język
                        PARALLEL_PRIMARY_LANG="$MODE_CAT"
                        while [ "$PARALLEL_DONE" -lt "${PARALLEL_LANGS_PER_CYCLE:-3}" ]; do
                            # Wyczyść cache strict selector aby wybrał nowy target
                            rm -f "$STATUS_DIR/translation_strict_candidates_cache.json" 2>/dev/null || true
                            PARALLEL_TARGET=$(select_auto_translate_target_strict)
                            P_TYPE=$(echo "$PARALLEL_TARGET" | cut -d: -f1)
                            P_LANG=$(echo "$PARALLEL_TARGET" | cut -d: -f2)
                            P_FILE=$(echo "$PARALLEL_TARGET" | cut -d: -f3)
                            P_EXTRA=$(echo "$PARALLEL_TARGET" | cut -d: -f4)

                            # Jeśli selector zwrócił IDLE lub ten sam język, zakończ parallel
                            if [ "$P_TYPE" != "AUTO_TRANSLATE" ]; then
                                break
                            fi
                            if [ "$P_LANG" = "$PARALLEL_PRIMARY_LANG" ]; then
                                # Ten sam język — pomiń i zakończ (next cycle will advance)
                                break
                            fi

                            echo "   🔀 Parallel [$((PARALLEL_DONE+1))/${PARALLEL_LANGS_PER_CYCLE}]: $P_LANG/$P_FILE ($P_EXTRA kluczy)"
                            status_update_activity "running" "$CYCLE" "AUTO_TRANSLATE" "parallel_start" "$P_LANG" "$P_FILE" "parallel auto translate" 0 0 "keys" 0

                            read -r P_TRANSLATED P_PLACEHOLDERS P_GUARD_FAIL P_GUARD_PLACEHOLDER P_GUARD_COMMAND P_GUARD_PIPE P_SKIP_FILE P_SKIP_KEY P_SKIP_DONE <<< "$(auto_translate_keys "$P_LANG" "$P_FILE" "$P_EXTRA")"
                            P_TRANSLATED=${P_TRANSLATED:-0}
                            P_GUARD_FAIL=${P_GUARD_FAIL:-0}

                            append_translation_guard_report "$CYCLE" "$P_LANG" "$P_FILE" "${P_TRANSLATED:-0}" "${P_PLACEHOLDERS:-0}" "${P_GUARD_FAIL:-0}" "${P_GUARD_PLACEHOLDER:-0}" "${P_GUARD_COMMAND:-0}" "${P_GUARD_PIPE:-0}" "${P_SKIP_FILE:-0}" "${P_SKIP_KEY:-0}" "${P_SKIP_DONE:-0}"

                            echo "   🔀 Parallel result: $P_LANG/$P_FILE → translated=$P_TRANSLATED guard_fail=$P_GUARD_FAIL"
                            status_log_op "$CYCLE" "AUTO_TRANSLATE" "PARALLEL_TRANSLATE_DONE" "$P_LANG" "$P_FILE" "ok" "parallel lang=${P_LANG} file=${P_FILE}" "" "" "" "$P_TRANSLATED" "$P_PLACEHOLDERS"

                            PARALLEL_DONE=$((PARALLEL_DONE + 1))
                        done
                        echo "   📊 Parallel: przetworzono $PARALLEL_DONE język(ów) w cyklu $CYCLE"
                    fi

                    # === Sekcja 12.5: Repair identical_to_en bonus round ===
                    repair_identical_bonus_round "$CYCLE"

                    # Cykliczny audyt jakości (co QUALITY_AUDIT_INTERVAL cykli)
                    run_quality_audit "$CYCLE"

                    # === Faza 6: Formalna walidacja tierów ===
                    validate_tier_quality "$CYCLE"

                    # Pełna walidacja per-język (co LANG_VALIDATION_INTERVAL cykli)
                    if [ -n "$FORCE_LANG_VALIDATION" ] && [ "$FORCE_LANG_VALIDATION" != "all" ]; then
                        run_full_lang_validation "$CYCLE" "$FORCE_LANG_VALIDATION"
                    else
                        run_full_lang_validation "$CYCLE"
                    fi
                    ;;
                IDLE)
                    echo "✅ TRYB: IDLE - Wszystko zrobione!"
                    echo "   Migracja: ✅ | Tłumaczenia: ✅"
                    echo ""

                    if [ "$MODE_CAT" = "translation_only_blocked" ]; then
                        echo "⚠️ TRANSLATIONS_ONLY STRICT: blokery uniemożliwiają dalsze tłumaczenie bez dodawania kluczy."
                        echo "   Sprawdź: i18n/status/translation_blockers_latest.json"
                    fi

                    if [ "$TRANSLATIONS_ONLY" = "true" ]; then
                        echo "🌐 TRANSLATIONS_ONLY: pomijam skany migracji, wykonuję tylko walidację tłumaczeń"
                        status_update_activity "running" "$CYCLE" "VALIDATION" "validation_start" "-" "-" "translation-only validation" 0 0 "steps" 0
                        validate_translation_quality
                        status_update_activity "running" "$CYCLE" "VALIDATION" "validation_done" "-" "-" "validation complete" 0 0 "steps" 0
                        status_log_op "$CYCLE" "VALIDATION" "TRANSLATION_ONLY_IDLE_DONE" "-" "-" "ok" "validation only"
                        if [ "${STOP_AFTER_CYCLE:-false}" = "true" ]; then
                            echo "🛑 ONCE: kończę po cyklu translation-only"
                        else
                            sleep 30
                        fi
                        continue
                    fi
                    
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
                        # Aktualizuj heartbeat przed sleep, żeby dashboard nie pokazywał STALE
                        status_update_activity "running" "$CYCLE" "IDLE" "sleeping" "-" "-" "idle sleep 300s" 0 0 "units" 0
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
            MODE_T1=$(now_ms)
            status_log_cycle_perf "$CYCLE" "${MODE_TYPE:-IDLE}" "${MODE_CAT:--}" "mode_run" "$((MODE_T1 - MODE_T0))" "mode=${MODE_TYPE:-IDLE}"

            # Wymuszona walidacja po cyklu także dla trybów innych niż AUTO_TRANSLATE
            if [ -n "$FORCE_LANG_VALIDATION" ] && [ "${MODE_TYPE:-}" != "AUTO_TRANSLATE" ]; then
                if [ "$FORCE_LANG_VALIDATION" = "all" ]; then
                    run_full_lang_validation "$CYCLE"
                else
                    run_full_lang_validation "$CYCLE" "$FORCE_LANG_VALIDATION"
                fi
            fi

            if should_run_quality_audit; then
                QA_OUT=$(run_quality_audit 2>/dev/null || true)
                QA_LINE=$(printf '%s\n' "$QA_OUT" | grep '__QUALITY_AUDIT__' | tail -n 1)
                if [ -n "$QA_LINE" ]; then
                    echo "📊 QUALITY AUDIT: ${QA_LINE#__QUALITY_AUDIT__ }"
                    QA_ISSUES=$(printf '%s\n' "$QA_LINE" | grep -oE 'issues=[0-9]+' | cut -d= -f2)
                    QA_SLOW=$(printf '%s\n' "$QA_LINE" | grep -oE 'slow=[01]' | cut -d= -f2)
                    QA_ISSUES=${QA_ISSUES:-0}
                    QA_SLOW=${QA_SLOW:-0}
                    if [ "$QA_SLOW" = "1" ] && [ "$BATCH" -gt 5 ] 2>/dev/null; then
                        echo "⚠️ QUALITY AUDIT: issues=$QA_ISSUES > threshold=${QUALITY_AUDIT_THRESHOLD}, zmniejszam batch do 5"
                        BATCH=5
                    fi
                fi
            fi

            # ── pending_skip 24h artifact (#14) — co 10 cykli przelicz metryki ──
            if (( CYCLE % 10 == 0 )); then
                PS24_OUT=$(compute_pending_skip_24h 2>/dev/null || true)
                PS24_LINE=$(printf '%s\n' "$PS24_OUT" | grep '__PENDING_SKIP_24H__' | tail -n 1)
                if [ -n "$PS24_LINE" ]; then
                    echo "📊 PENDING_SKIP_24H: ${PS24_LINE#__PENDING_SKIP_24H__ }"
                fi
            fi
            
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
    processed_file = 'i18n_processed_files.txt'
    try:
        with open(status_file) as f:
            status_data = json.load(f)
        files = status_data.get('files', {})

        # Zlicz pliki (registry/live)
        completed = [f for f, info in files.items() if info.get('overall_status') == 'completed']
        scanned_files_live = len(files)
        scanned_files_history = 0
        try:
            with open(processed_file) as pf:
                scanned_files_history = len([l for l in pf if l.strip()])
        except Exception:
            scanned_files_history = 0

        # Zlicz klucze z rejestru workera
        files_with_keys = 0
        files_without_keys = 0
        total_keys_extracted_registry = 0

        for fpath in completed:
            keys = files[fpath].get('stages', {}).get('5_extraction_en', {}).get('keys_added', 0)
            if keys > 0:
                files_with_keys += 1
                total_keys_extracted_registry += keys
            else:
                files_without_keys += 1

        # LIVE liczba kluczy bezpośrednio z i18n/en/*.json
        total_keys_extracted_live = 0
        try:
            en_dir = os.path.join('i18n', 'en')
            for name in os.listdir(en_dir):
                if not name.endswith('.json'):
                    continue
                fpath = os.path.join(en_dir, name)
                try:
                    with open(fpath, encoding='utf-8') as f:
                        payload = json.load(f)
                    if isinstance(payload, dict):
                        total_keys_extracted_live += len(payload)
                except Exception:
                    continue
        except Exception:
            total_keys_extracted_live = 0

        keys_extracted_outside_worker_registry = max(0, total_keys_extracted_live - total_keys_extracted_registry)

        data['migration'] = {
            'files_scanned': len(completed),
            'files_scanned_live': scanned_files_live,
            'files_scanned_history': scanned_files_history,
            'files_scanned_history_minus_live': int(scanned_files_history - scanned_files_live),
            'files_with_keys': files_with_keys,
            'files_without_keys': files_without_keys,
            'keys_extracted': total_keys_extracted_live,
            'keys_extracted_live': total_keys_extracted_live,
            'keys_extracted_worker_registry': total_keys_extracted_registry,
            'keys_extracted_outside_worker_registry': keys_extracted_outside_worker_registry,
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
    guard_fail = 0
    strict_missing_key = 0
    strict_blocker = ""
    recent_translated = 0
    recent_examples = []
    try:
        gp = 'i18n/status/translation_guard_latest.json'
        if os.path.exists(gp):
            with open(gp) as f:
                gd = json.load(f)
            guard_fail = int(gd.get('guard_fail', 0) or 0)
            strict_missing_key = int(gd.get('strict_missing_key', 0) or 0)
    except Exception:
        pass
    try:
        bp = 'i18n/status/translation_blockers_latest.json'
        if os.path.exists(bp):
            with open(bp) as f:
                bd = json.load(f)
            missing_files = int(bd.get('missing_lang_files', 0) or 0)
            missing_keys = int(bd.get('missing_keys_total', 0) or 0)
            if missing_files > 0 or missing_keys > 0:
                strict_blocker = f"missing_files={missing_files},missing_keys={missing_keys}"
    except Exception:
        pass
    try:
        rp = 'i18n/status/translation_recent_latest.json'
        if os.path.exists(rp):
            with open(rp) as f:
                rd = json.load(f)
            if str(rd.get('language', '')) == str(mode_cat) and str(rd.get('json_file', '')) == str(mode_count):
                recent_translated = int(rd.get('translated', 0) or 0)
                recent_examples = rd.get('entries', []) if isinstance(rd.get('entries', []), list) else []
    except Exception:
        pass

    data['auto_translate'] = {
        'language': mode_cat,
        'json_file': mode_count,
        'keys_to_translate': to_int(mode_extra),
        'guard_fail': guard_fail,
        'strict_missing_key': strict_missing_key,
        'strict_blocker': strict_blocker,
        'recent_translated': recent_translated,
        'recent_examples': recent_examples[-20:]
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

# ── Niezależna sekcja migration (LIVE/registry) w każdym trybie ────────
# Dzięki temu migration.keys_extracted_live jest zawsze aktualne.
if 'migration' not in data or not isinstance(data.get('migration'), dict) or 'keys_extracted_live' not in data.get('migration', {}):
    try:
        status_file = 'i18n_file_status.json'
        processed_file = 'i18n_processed_files.txt'
        with open(status_file) as f:
            _fs = json.load(f)
        _files = _fs.get('files', {})
        _completed = [f for f, info in _files.items() if info.get('overall_status') == 'completed']
        _scanned_live = len(_files)
        _scanned_history = 0
        try:
            with open(processed_file) as pf:
                _scanned_history = len([l for l in pf if l.strip()])
        except Exception:
            _scanned_history = 0
        _keys_registry = 0
        _files_with = 0
        _files_without = 0
        for fp in _completed:
            k = _files[fp].get('stages', {}).get('5_extraction_en', {}).get('keys_added', 0)
            if k > 0:
                _files_with += 1
                _keys_registry += k
            else:
                _files_without += 1
        _keys_live = 0
        try:
            en_dir = os.path.join('i18n', 'en')
            for name in os.listdir(en_dir):
                if not name.endswith('.json'):
                    continue
                try:
                    with open(os.path.join(en_dir, name), encoding='utf-8') as f:
                        payload = json.load(f)
                    if isinstance(payload, dict):
                        _keys_live += len(payload)
                except Exception:
                    continue
        except Exception:
            pass
        _drift = max(0, _keys_live - _keys_registry)
        data['migration'] = {
            'files_scanned': len(_completed),
            'files_scanned_live': _scanned_live,
            'files_scanned_history': _scanned_history,
            'files_scanned_history_minus_live': int(_scanned_history - _scanned_live),
            'files_with_keys': _files_with,
            'files_without_keys': _files_without,
            'keys_extracted': _keys_live,
            'keys_extracted_live': _keys_live,
            'keys_extracted_worker_registry': _keys_registry,
            'keys_extracted_outside_worker_registry': _drift,
            'current_category': data.get('category', ''),
            'batch_size': 0
        }
    except Exception:
        pass

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

            status_update_activity "running" "$CYCLE" "${MODE_TYPE:-IDLE}" "cycle_end" "${MODE_CAT:-}" "-" "cycle end" 0 0 "units" 0
            
            # Aktualizuj pełny status z throttlingiem (P0: ograniczenie ciężkiego STATUSPY)
            STATUS_T0=$(now_ms)
            if should_update_github_status; then
                update_github_status
            else
                echo "⏭️ Pomijam pełny status (throttle: co ${STATUS_UPDATE_EVERY_CYCLES} cykli lub ${STATUS_UPDATE_MIN_INTERVAL_SEC}s)"
            fi
            STATUS_T1=$(now_ms)
            status_log_cycle_perf "$CYCLE" "${MODE_TYPE:-IDLE}" "${MODE_CAT:--}" "status_update" "$((STATUS_T1 - STATUS_T0))" "throttle_every=${STATUS_UPDATE_EVERY_CYCLES}"
            
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
                            git push origin "$GIT_TRACK_BRANCH" 2>/dev/null && echo "📤 Push OK ($GIT_TRACK_BRANCH)" || echo "⚠️ Push failed ($GIT_TRACK_BRANCH)"
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
                            git push origin "$GIT_TRACK_BRANCH" 2>/dev/null && echo "📤 Push OK ($GIT_TRACK_BRANCH)" || echo "⚠️ Push failed ($GIT_TRACK_BRANCH)"
                            rmdir "$GIT_LOCK_FILE" 2>/dev/null || true
                        fi
                    )
                fi
            fi
            
            echo ""
            echo "💤 Przerwa ${DELAY}s przed następnym cyklem..."

            CYCLE_T1=$(now_ms)
            status_log_cycle_perf "$CYCLE" "${MODE_TYPE:-IDLE}" "${MODE_CAT:--}" "cycle_total" "$((CYCLE_T1 - CYCLE_T0))" "delay=${DELAY}"

            if [ "$STOP_AFTER_CYCLE" = "true" ]; then
                # === RESTART ===
                if [ "${RESTART_REQUESTED:-false}" = "true" ]; then
                    echo "🔄 RESTART: pobieranie najnowszego kodu..."
                    git pull --rebase origin "$GIT_TRACK_BRANCH" 2>&1 | head -5 || true
                    echo "🔄 RESTART: exec z argumentami: ${WORKER_ORIGINAL_ARGS[*]}"
                    status_update_activity "restarting" "${CYCLE:-0}" "${MODE_TYPE:-IDLE}" "restart" "${MODE_CAT:-}" "-" "restart" 0 0 "units" 0
                    cleanup_pid_files_if_owner
                    exec bash "$WORKER_SCRIPT" "${WORKER_ORIGINAL_ARGS[@]}"
                fi
                echo "🛑 Kończę po cyklu (ONCE)"
                status_update_activity "stopped" "${CYCLE:-0}" "${MODE_TYPE:-IDLE}" "stop_after_cycle" "${MODE_CAT:-}" "-" "stop after cycle" 0 0 "units" 0
                if should_force_status_update_on_metrics_delta; then
                    echo "📊 Smart force status update (ONCE)"
                    if should_update_github_status force; then
                        update_github_status
                    fi
                elif should_update_github_status; then
                    update_github_status
                else
                    echo "⏭️ Smart force: brak istotnych zmian metryk (ONCE), pomijam full status"
                fi
                cleanup_pid_files_if_owner
                exit 0
            fi
            
            # Reset zmiennych wymuszenia przed następnym cyklem
            MODE_EXTRA=""
            MODE_EXTRA2=""
            MODE_TYPE=""
            MODE_CAT=""
            MODE_COUNT=""
            
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
        echo "  $0 --lang-validate L    Wymuś walidację pojedynczego języka (np. pl)"
        echo "  $0 --lang-validate-all  Wymuś walidację wszystkich języków"
        echo ""
        echo "Opcje --continuous:"
        echo "  --no-git                Wyłącz git add/commit/push"
        echo "  --translate-limit N     Max N kluczy do tłumaczenia na cykl"
        echo "  --translations-only     Tylko tłumaczenia (STRICT: bez nowych kluczy)"
        echo "  --use-gt                Używaj Google Translate jako fallback po słownikach"
        echo "  --gt-batch N            Rozmiar batcha GT (domyślnie 50)"
        echo "  --gt-delay N            Sekundy przerwy między batchami GT (domyślnie 1.5)"
        echo "  --auto-fix-crossref     Włącz auto-fix cross-reference (Faza 4.5, OFF domyślnie)"
        echo "  --auto-fix-crossref-limit N  Max poprawek crossref na język (domyślnie 30)"
        echo "  --no-adaptive-batch     Wyłącz adaptive batch tuning (8.3)"
        echo "  --parallel-langs N      Tłumacz N języków na cykl (domyślnie 3, sekcja 8.4)"
        echo ""
        echo "Komendy runtime (.worker_command / worker_commands.txt / worker_config.json):"
        echo ""
        echo "  === Sterowanie językiem ==="
        echo "  LANG:<lang>                    Przypiąj worker do jednego języka (auto-wybór plików)"
        echo "  LANG:<lang>:<f1>,<f2>,...       Przypiąj język + cyklicznie przechodź podane pliki"
        echo "  LANG:random                    Przywróć tryb losowy (wszystkie języki)"
        echo "  FOCUS:<lang>[:json[:limit]]    Skup się na jednym języku (persystentne)"
        echo "  UNFOCUS                        Zdejmij focus, wróć do tier-round-robin"
        echo "  SWITCH:<lang>[:json[:limit]]   Alias (kompatybilność wsteczna)"
        echo "  UNSWITCH                       Alias dla UNFOCUS"
        echo ""
        echo "  === Testowanie języków ==="
        echo "  TEST:<lang>               Pełny test: translate + validate + crossref (1 cykl)"
        echo "  TEST_ALL                  Dodaj WSZYSTKIE języki do kolejki testowej"
        echo "  LANGVAL:all | LANGVAL:<lang>  Wymuś walidację"
        echo "  SPOTCHECK:<lang>[:N]      Losowy audit N tłumaczeń"
        echo "  GRAMMARFIX:<lang>[:json[:N]]  Napraw EN-copy/artefakty + walidacja"
        echo ""
        echo "  === Konfiguracja w locie ==="
        echo "  GT:on / GT:off            Włącz/wyłącz Google Translate"
        echo "  BATCH:<N>                 Ustaw translate_limit na N kluczy/cykl"
        echo "  SET:<key>=<value>         Zmień dowolną wartość w worker_config.json"
        echo "  RESTART                   Restart workera z bieżącą konfiguracją"
        echo "  CONFIG                    Wyświetl aktualną konfigurację"
        echo "  REPORT                    Raport coverage wszystkich języków"
        echo "  LANGS                     Lista dostępnych języków"
        echo "  SKIP / PAUSE:<N> / IDLE   Kontrola cyklu"
        echo ""
        echo "  === Plik worker_config.json (edytuj ręcznie, worker wczyta co cykl) ==="
        echo "  focus_lang, use_gt, translate_limit, parallel_langs, paused, test_lang..."
        echo ""
        ;;
esac
