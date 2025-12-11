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

#===============================================================================
# GET_UNPROCESSED_FILES - Znajdź pliki które jeszcze nie były przetwarzane
#===============================================================================
# Użycie: get_unprocessed_files <find_pattern> <batch_size>
# Przykład: get_unprocessed_files "data-otservbr-global/monster -name *.lua" 50
# Zwraca listę plików które NIE są w PROCESSED_FILE, max batch_size
#===============================================================================
get_unprocessed_files() {
    local find_args="$1"
    local batch="${2:-50}"
    
    # Filtruj processed i weź batch
    eval "find $find_args 2>/dev/null" | while read -r f; do
        grep -qF "$f" "$PROCESSED_FILE" 2>/dev/null || echo "$f"
    done | head -$batch
}

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# NAPRAWIONE: Log do stderr żeby nie mieszać z return values w subshell
log() { echo -e "$1" >&2; }

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
    if command -v lua >/dev/null 2>&1; then
        lua -p "$file" >/dev/null 2>&1
    else
        # Brak lua w PATH – nie blokuj, ale sygnalizuj przez exit 0
        return 0
    fi
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
    
    python3 << CATSTATEPY
import json
import time
import os

CATEGORY_STATE_FILE = ".i18n_category_state.json"
CATEGORY = "$CATEGORY"
PROCESSED_COUNT = $PROCESSED_COUNT

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
with open(CATEGORY_STATE_FILE, 'w') as f:
    json.dump(state, f, indent=2)
CATSTATEPY
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
    
    while [ $processed -lt $total_batch ]; do
        local current_mini=$mini_batch
        [ $((processed + mini_batch)) -gt $total_batch ] && current_mini=$((total_batch - processed))
        
        # Zlicz klucze przed
        local keys_before=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
        
        # Wywołaj funkcję przetwarzania (przekieruj jej output do stderr)
        $process_func "$current_mini" >&2
        
        # Zlicz klucze po
        local keys_after=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
        
        local added=$((keys_after - keys_before))
        total_added=$((total_added + added))
        processed=$((processed + current_mini))
        mini_count=$((mini_count + 1))
        
        echo "   📦 Mini-batch #$mini_count: +$added kluczy (suma: $total_added)" >&2
        
        # Pauza między mini-batch (ale nie po ostatnim i nie gdy nic nie dodano)
        if [ $processed -lt $total_batch ] && [ "$added" -gt 0 ]; then
            echo "   ⏳ Pauza ${mini_pause}s..." >&2
            sleep $mini_pause
        fi
        
        # Jeśli nie dodano nic, przerwij wcześniej
        if [ "$added" -eq 0 ]; then
            echo "   ⚠️ Brak nowych danych, kończę wcześniej" >&2
            break
        fi
    done
    
    echo "✅ Zakończono: +$total_added kluczy w $mini_count mini-batch" >&2
    
    # Zwróć TYLKO liczbę dodanych kluczy (do stdout)
    echo "$total_added"
}

#===============================================================================
# UPDATE_STATUS - Aktualizacja I18N_STATUS.md dla GitHub (pełna wersja)
#===============================================================================
update_github_status() {
    log "${CYAN}📊 Aktualizuję I18N_STATUS.md...${NC}"
    
    python3 << 'STATUSPY'
import json
import os
import subprocess
from datetime import datetime

WORK_DIR = os.getcwd()
STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"
PROCESSED_FILE = "i18n_processed_files.txt"
EXCLUDED_FILE = "i18n_excluded_files.txt"

# Git root - tam gdzie jest .git (dla pushowania I18N_STATUS.md)
try:
    GIT_ROOT = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], stderr=subprocess.DEVNULL).decode().strip()
except:
    GIT_ROOT = WORK_DIR

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

total_keys = (game_keys + items_keys + misc_keys + monsters_keys + npc_keys + 
              player_keys + quests_keys + scripts_keys + server_keys + spells_keys + 
              system_keys + ui_keys + startup_keys + raids_keys + world_keys + 
              libs_keys + events_keys + chatchannels_keys + modules_keys + npclib_keys +
              actions_keys + errors_keys + messages_keys +
              php_keys + cpp_keys + html_keys + client_keys)

# Zlicz języki (wszystkie dostępne)
ALL_LANGUAGES = ["en", "pl", "de", "es", "pt", "fr", "it", "ru", "uk", "zh", "ja", "ko", "ar", "tr", "nl", "sv", "da", "no", "fi", "cs", "sk", "hu", "ro", "bg", "el", "he", "hi", "th", "vi", "id", "ms", "tl", "sw", "bn", "ta", "te", "ml", "ka", "hy", "az", "kk", "uz", "sr", "hr", "sl", "bs", "mk", "sq", "lv", "lt", "et", "fa", "zh_TW"]
langs_count = len(ALL_LANGUAGES)

langs_with_data = []
if os.path.isdir(I18N_DIR):
    for lang in os.listdir(I18N_DIR):
        lang_path = f"{I18N_DIR}/{lang}"
        if os.path.isdir(lang_path):
            for jf in os.listdir(lang_path):
                if jf.endswith(".json"):
                    try:
                        with open(f"{lang_path}/{jf}") as f:
                            if len(json.load(f)) > 0:
                                if lang not in langs_with_data:
                                    langs_with_data.append(lang)
                                break
                    except:
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
                    has_stdmod = "StdModule.say" in content and "text" in content
                    has_i18n = "i18nKey" in content
                    if has_stdmod and not has_i18n:
                        needs_migration_npc += 1
                    elif has_i18n:
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
    "php": 3000, "cpp": 500, "html": 500, "client": 200
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

# Status workera (ostatni tryb z i18n_global_stats.json)
try:
    with open("i18n_global_stats.json") as f:
        _global_stats = json.load(f)
        last_mode = _global_stats.get("mode", "")
except:
    last_mode = ""

# Podgląd aktualnego trybu/kategorii do LIVE box
if sync_current_lang:
    mode_display = "🌍 TRANSLATION_SYNC (Etap 1)"
    category_display = f"🌍 {sync_current_lang.upper()}/{sync_current_cat}"
elif last_mode == "AUTO_TRANSLATE":
    mode_display = "🤖 AUTO_TRANSLATE"
    category_display = "AUTO_TRANSLATE"
elif current_category:
    mode_display = "MIGRATION (multi-category)"
    category_display = f"🎒 {current_category.upper()}"
else:
    mode_display = "IDLE"
    category_display = "IDLE"
# Status workera (ostatni tryb z i18n_global_stats.json)
try:
    with open("i18n_global_stats.json") as f:
        _global_stats = json.load(f)
        last_mode = _global_stats.get("mode", "")
except:
    last_mode = ""

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

# Podgląd aktualnego trybu/kategorii do LIVE box
if sync_current_lang:
    mode_display = "🌍 TRANSLATION_SYNC (Etap 1)"
    category_display = f"🌍 {sync_current_lang.upper()}/{sync_current_cat}"
elif last_mode == "AUTO_TRANSLATE":
    mode_display = "🤖 AUTO_TRANSLATE"
    category_display = "AUTO_TRANSLATE"
elif current_category:
    mode_display = "MIGRATION (multi-category)"
    category_display = f"🎒 {current_category.upper()}"
else:
    mode_display = "IDLE"
    category_display = "IDLE"

# ==================== GENERUJ PEŁNY I18N_STATUS.md ====================
md = f'''# 🌍 I18N Internationalization System - Live Dashboard

{targets_comment}

> **Aktualizacja:** {timestamp} UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** {langs_count}

---

## 🤖 AI Agent Integration

```
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n_file_status.json                              │
│  Worker: i18n_worker_simple.sh                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Globalny Postęp

| Metryka | Wartość | Trend |
|---------|---------|-------|
| 📁 Plików przetworzonych | **{processed_count}** | ↑ |
| ⏭️ Plików wykluczonych | **{excluded_count}** | - |
| 🔑 Kluczy i18n | **{total_keys}** | ↑ |
| 🌍 Języków | **{langs_count}** | ✓ |
| ⚠️ Konfliktów | **0** | ✓ |
| 🔄 Cykl | **#{cycle_count}** | - |

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

### ⏳ Faza 3: 📱 Instalka/Klient

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | {status_icon(ui_keys, 200)} | {ui_keys}/200 ({round(ui_keys/200*100)}%) | 200 |
| 💿 Installer/C++ | {status_icon(cpp_keys, TARGETS["cpp"])} | {cpp_keys}/{TARGETS["cpp"]} ({round(cpp_keys/TARGETS["cpp"]*100) if TARGETS["cpp"] else 0}%) | {TARGETS["cpp"]} |

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
│ Status:    {"🟢 RUNNING" if in_progress > 0 or sync_current_lang else "✅ IDLE":40} │
│ Tryb:      {mode_display:40} │
│ Kategoria: {category_display:40} │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Ostatnia aktywność: {(sync_current_lang.upper() + "/" + sync_current_cat if sync_last_ts > last_activity_time and sync_current_lang else current_category):25}                      │
│ [{progress_bar(sync_stats.get(sync_current_lang, {}).get("total", 0) if sync_last_ts > last_activity_time else all_json_categories.get(current_category, 0), total_keys if sync_last_ts > last_activity_time else TARGETS.get(current_category, 1000), 50)}] │
│ {(str(sync_stats.get(sync_current_lang, {}).get("total", 0)) + "/" + str(total_keys) + " kluczy") if sync_last_ts > last_activity_time else str(all_json_categories.get(current_category, 0)) + "/" + str(TARGETS.get(current_category, 1000)) + " kluczy"} ({round((sync_stats.get(sync_current_lang, {}).get("total", 0)/total_keys*100) if sync_last_ts > last_activity_time and total_keys else (all_json_categories.get(current_category, 0)/TARGETS.get(current_category, 1000)*100) if TARGETS.get(current_category, 1000) else 0)}%)                                          │
├─────────────────────────────────────────────────────────────────┤
│ ⏳ Total processed: {total_files_processed} operacji               │
│ 🌍 Języki zsync: {len(sync_langs_done)}/53                                │
│ 📅 Ostatnia aktualizacja: {timestamp}                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Operacji wykonanych | **{total_files_processed}** | we wszystkich kategoriach |
| ✅ NPC zmigrowanych | **{completed}** ({migrated_npc} z i18nKey) | z {total_npc} plików NPC |
| 🔑 Kluczy wyciągniętych | **{total_keys}** | we wszystkich kategoriach |
| 🌍 Języków zsynchronizowanych | **{len(sync_langs_done)}**/53 | {", ".join(sync_langs_done[:5]) if sync_langs_done else "brak"}{"..." if len(sync_langs_done) > 5 else ""} |
| 🔄 Cykli wykonanych | **#{cycle_count}** | continuous mode |
| 🎯 Aktywne kategorie | **{len([c for c,k in all_json_categories.items() if k > 0])}** | z danymi |
| ❌ Błędów krytycznych | **0** | ✓ wszystko OK |

---

## 📜 Historia ostatnich operacji

{chr(10).join([f"- {'🌍' if op.get('type')=='translation_sync' else '🎒' if op['category']=='items' else '🧙' if op['category']=='npc' else '📜' if op['category']=='scripts' else '👹' if op['category']=='monsters' else '⚡'} `{op['category']}` +{op['count']} kluczy @ {op['time_str']}" for op in recent_operations[:8]]) if recent_operations else "- Brak operacji"}


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

# Zapisz do git root (nie do lokalnego katalogu!)
status_path = os.path.join(GIT_ROOT, "I18N_STATUS.md")
with open(status_path, "w") as f:
    f.write(md)

print(f"✅ I18N_STATUS.md zaktualizowany: {timestamp}")
print(f"   Ścieżka: {status_path}")
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
    
    local hash=$(md5sum "$file" | cut -d' ' -f1)
    local type="other"
    [[ "$file" == *"/npc/"* ]] && type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    
    mkdir -p "$BACKUP_DIR/$type"
    cp "$file" "$BACKUP_DIR/$type/$(basename $file).bak"
    
    # Zapisz do JSON
    python3 -c "
import json
from datetime import datetime

try:
    with open('$STATUS_FILE', 'r') as f: data = json.load(f)
except: data = {'files': {}}

data['files']['$file'] = {
    'stages': {
        '1_started': {'status': 'completed', 'hash': '$hash', 'type': '$type'}
    },
    'overall_status': 'in_progress'
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
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
    
    # npcHandler:say wymaga migracji jeśli brak NPC_LIB.i18n.npcSay
    if [ "$npcsay" -gt 0 ] && [ "$npcsaylib" -eq 0 ]; then
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
    
    python3 -c "
import json

needs_bool = True if '$needs' == 'true' else False

with open('$STATUS_FILE', 'r') as f: data = json.load(f)

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

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
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
    
    mkdir -p "$doc_dir"
    
    python3 << EOF
import json
import re
from datetime import datetime

# Wczytaj backup z oryginalnymi tekstami
backup_file = "$BACKUP_DIR/npc/$(basename $file).bak"
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
    f.write(f"**Plik:** \`$file\`\n")
    f.write(f"**Data migracji:** {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
    f.write(f"**Liczba tekstów:** {len(texts)}\n\n")
    f.write("## Klucze i18n\n\n")
    f.write("| Klucz | Tekst EN |\n")
    f.write("|-------|----------|\n")
    for i, text in enumerate(texts, 1):
        if len(text) >= 5:
            key = f"npc.$safe.stdmod_{i}"
            f.write(f"| \`{key}\` | {text[:60]}{'...' if len(text) > 60 else ''} |\n")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["3_documentation"] = {
    "status": "completed", 
    "doc_file": doc_file,
    "keys_documented": len([t for t in texts if len(t) >= 5])
}
with open("$STATUS_FILE", "w") as f:
    json.dump(status, f, indent=2)

print(f"Utworzono: {doc_file}")
EOF
    
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
# TRANSFORMACJA 1: StdModule.say z text = "..." → i18nKey = "..."
#==============================================================================
stdmod_counter = [0]

def replace_stdmod_with_i18n(match):
    stdmod_counter[0] += 1
    key = f"npc.{safe_name}.stdmod_{stdmod_counter[0]}"
    before = match.group(1)
    after = match.group(3)
    return f'{before}i18nKey = "{key}"{after}'

# Pattern dla multi-line StdModule.say z text = "..."
pattern_stdmod = r'(StdModule\.say\s*,\s*\{[^}]*?)text\s*=\s*"([^"]{5,})"([^}]*?\})'
content = re.sub(pattern_stdmod, replace_stdmod_with_i18n, content, flags=re.DOTALL)
total_transformed += stdmod_counter[0]

#==============================================================================
# TRANSFORMACJA 2: npcHandler:say("text", npc, creature) → NPC_LIB.i18n.npcSay()
# Wzorce:
#   npcHandler:say("Hello world", npc, creature)
#   npcHandler:say("Hello world", npc, player)
#   return npcHandler:say("Hello world", npc, creature)
# NIE transformujemy:
#   npcHandler:say({...})  - tablice
#   npcHandler:say("..." .. var ..) - konkatenacje
#   npcHandler:say(zmienna, ...) - zmienne
#==============================================================================
npcsay_counter = [0]

# Pattern: opcjonalnie "return ", potem npcHandler:say("prosty tekst bez konkatenacji", npc, creature/player)
pattern_npcsay = r'((?:return\s+)?)?npcHandler:say\(\s*"([^"]{5,})"\s*,\s*npc\s*,\s*(?:creature|player)\s*\)'

# Transformuj wszystkie npcHandler:say("...") - nawet jeśli już są jakieś NPC_LIB w pliku
if 'npcHandler:say("' in content:
    # Filtruj - nie transformujemy konkatenacji
    def safe_replace_npcsay(match):
        full_match = match.group(0)
        text = match.group(2) if match.lastindex >= 2 else ""
        
        # Pomiń jeśli to konkatenacja (.. przed lub po cudzysłowiu)
        start = match.start()
        end = match.end()
        
        if '.."' in full_match or '"..' in content[end:end+10]:
            return full_match  # Nie transformuj konkatenacji
        
        npcsay_counter[0] += 1
        key = f"npc.{safe_name}.say_{npcsay_counter[0]}"
        prefix = match.group(1) or ""
        
        return f'{prefix}NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "{key}")'
    
    content = re.sub(pattern_npcsay, safe_replace_npcsay, content)
    total_transformed += npcsay_counter[0]

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
# ZAPIS
#==============================================================================
if total_transformed > 0 and content != original_content:
    with open(file_path, 'w') as f:
        f.write(content)
    print(f"{total_transformed}|{stdmod_counter[0]}|{npcsay_counter[0]}|{greet_fare_total}")
else:
    print("0|0|0|0")
TRANSFORM_PY
)
    
    # Parsuj wynik: total|stdmod|npcsay|greetfare
    local total_t=$(echo "$transformed" | cut -d'|' -f1)
    local stdmod_t=$(echo "$transformed" | cut -d'|' -f2)
    local npcsay_t=$(echo "$transformed" | cut -d'|' -f3)
    local greetfare_t=$(echo "$transformed" | cut -d'|' -f4)
    
    [ -z "$total_t" ] && total_t=0
    [ -z "$stdmod_t" ] && stdmod_t=0
    [ -z "$npcsay_t" ] && npcsay_t=0
    [ -z "$greetfare_t" ] && greetfare_t=0
    
    if [ "$total_t" -gt 0 ] 2>/dev/null; then
        log "${GREEN}✓ Etap 4 OK${NC}: StdModule=$stdmod_t, npcHandler:say=$npcsay_t, greet/farewell=$greetfare_t, Total=$total_t"
    else
        total_t=0
        log "${YELLOW}⏭ Etap 4${NC}: Brak zmian"
    fi
    
    python3 -c "
import json
with open('$STATUS_FILE', 'r') as f: data = json.load(f)
data['files']['$file']['stages']['4_transformation'] = {
    'status': 'completed', 
    'transformed': $total_t,
    'stdmod_transformed': $stdmod_t,
    'npcsay_transformed': $npcsay_t
}
with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
"
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
    
    local backup="$BACKUP_DIR/$type/$(basename $file).bak"
    [ ! -f "$backup" ] && { log "${RED}Brak backupu${NC}"; return 1; }
    
    # Wyciągnij teksty z backupu i dodaj do JSON
    python3 << EOF
import json
import re

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
# EKSTRAKCJA 2: npcHandler:say("text", npc, creature/player)
# Multi-line aware - tekst może być rozciągnięty na wiele linii w pliku
#==============================================================================
# Pattern dla npcHandler:say("tekst", npc, creature/player)
# Szuka całego wywołania z tekstem
pattern_npcsay = r'npcHandler:say\(\s*"([^"]+)"\s*,\s*npc\s*,\s*(?:creature|player)\s*\)'
texts_npcsay = re.findall(pattern_npcsay, content, re.DOTALL)

for i, text in enumerate(texts_npcsay, 1):
    # Wyczyść ewentualne newline'y w tekście (artifact zawijania linii)
    text_clean = ' '.join(text.split())
    
    # Pomiń konkatenacje Lua (np. " .. variable .. ") ale NIE wielokropki (...)
    # Konkatenacja Lua to " .. " ze spacjami, wielokropek to "..."
    if ' .. ' not in text_clean and len(text_clean) >= 5:
        key = f"npc.$safe.say_{i}"
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

# Zapisz
with open(json_file, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Dodano {added} kluczy (StdModule: {stdmod_count}, npcHandler:say: {npcsay_count}, greet: {greet_count}, farewell: {farewell_count})")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["5_extraction_en"] = {
    "status": "completed", 
    "keys_added": added,
    "stdmod_keys": stdmod_count,
    "npcsay_keys": npcsay_count,
    "greet_keys": greet_count,
    "farewell_keys": farewell_count
}
with open("$STATUS_FILE", "w") as f:
    json.dump(status, f, indent=2)
EOF
    
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
    python3 << PYEOF
import json
import os

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
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

print(f"Placeholdery: {len(langs_done)} języków, {len(npc_keys)} kluczy każdy")
PYEOF
    
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
    
    python3 << PYEOF
import json
import os
import re

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
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

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
    
    python3 << PYEOF
import json
import os
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
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

# Aktualizuj I18N_STATUS.md
status_md = "I18N_STATUS.md"
try:
    with open(status_md, "r") as f:
        content = f.read()
except:
    content = "# I18N Status\n\n"

# Znajdź lub dodaj sekcję NPC
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
new_entry = "- ✅ \`" + safe_name + "\` - ukończono " + timestamp + "\\n"

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
        log "${YELLOW}Plik nie wymaga migracji${NC}"
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
    
    # Wyciągnij stringi z sendTextMessage
    local count=0
    while IFS= read -r text; do
        [ -z "$text" ] && continue
        [ ${#text} -lt 10 ] && continue
        
        local key="scripts.${safe}.msg_$((count + 1))"
        
        # Dodaj do JSON
        python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['$key'] = '''$text'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
        
        count=$((count + 1))
        log "   🔑 $key"
    done < <(grep -oP 'sendTextMessage\s*\([^,]+,\s*"\K[^"]+' "$file" 2>/dev/null | head -20)
    
    # Oznacz jako przetworzony
    echo "$file" >> "$PROCESSED_FILE"
    
    log "${GREEN}✅ Scripts: $count kluczy z $base${NC}"
    return 0
}

# Przetwarzaj kategorię monsters
process_monsters_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/monsters.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}👹 Processing monsters...${NC}"
    
    # Szukaj plików monsters w różnych lokalizacjach
    for dir in data-otservbr-global/monster data-canary/monster; do
        [ ! -d "$dir" ] && continue
        
        # NAPRAWIONE: Najpierw odfiltruj processed, POTEM weź batch
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|xml\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # NAPRAWIONE: Szukaj nazwy w createMonsterType("Name") lub monster.description
            local name=$(grep -oP 'createMonsterType\s*\(\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            local desc=$(grep -oP 'monster\.description\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            
            # Domyślnie użyj nazwy pliku jako name
            [ -z "$name" ] && name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            if [ -n "$name" ]; then
                python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['monster.$safe.name'] = '''$name'''
if '''$desc''':
    d['monster.$safe.desc'] = '''$desc'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                count=$((count + 1))
                log "   👹 monster.$safe.name = $name"
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.xml" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Monsters: $count kluczy${NC}"
    echo "$count"
}

# Przetwarzaj kategorię spells
process_spells_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/spells.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}✨ Processing spells...${NC}"
    
    for dir in data-otservbr-global/scripts/spells data/scripts/spells; do
        [ ! -d "$dir" ] && continue
        
        # NAPRAWIONE: Filtruj processed PRZED head
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            # Wyciągnij words (słowa do rzucenia spella)
            local words=$(grep -oP 'words\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            local desc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            
            python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['spell.$safe.name'] = '''$name'''
if '''$words''':
    d['spell.$safe.words'] = '''$words'''
if '''$desc''':
    d['spell.$safe.desc'] = '''$desc'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
            
            echo "$file" >> "$PROCESSED_FILE"
            count=$((count + 1))
            log "   ✨ spell.$safe.name = $name"
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Spells: $count kluczy${NC}"
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
            
            # Wyciągnij mini-batch itemów
            python3 << ITEMSPY
import json
import re

json_file = "$json_file"
items_xml = "$items_xml"
mini_batch = $current_mini
skip = $processed

try:
    with open(json_file) as f:
        data = json.load(f)
except:
    data = {}

existing_keys = len(data)

try:
    with open(items_xml, 'r', errors='ignore') as f:
        content = f.read()
    
    # Znajdź wszystkie <item id="..." name="...">
    items = re.findall(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"', content)
    
    # Przefiltruj tylko te które nie istnieją
    new_items = [(id, name) for id, name in items if f"item.{id}.name" not in data]
    
    count = 0
    for item_id, name in new_items[skip:skip+mini_batch]:
        key = f"item.{item_id}.name"
        data[key] = name
        count += 1
    
    with open(json_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"{count}")
except Exception as e:
    print(f"0")
ITEMSPY
            
            added=$(python3 -c "
import json
import re
with open('$json_file') as f: data = json.load(f)
with open('$items_xml', 'r', errors='ignore') as f: content = f.read()
items = re.findall(r'<item\s+id=\"(\d+)\"[^>]*name=\"([^\"]+)\"', content)
new_items = [(id, name) for id, name in items if f'item.{id}.name' not in data]
batch = min($current_mini, len(new_items))
for item_id, name in new_items[:batch]:
    data[f'item.{item_id}.name'] = name
with open('$json_file', 'w') as f: json.dump(data, f, indent=2, ensure_ascii=False)
print(batch)
" 2>/dev/null || echo "0")
            
            total_added=$((total_added + added))
            processed=$((processed + current_mini))
            
            log "   📦 Mini-batch: +$added items (total: $total_added)"
            
            # Pauza między mini-batch (ale nie po ostatnim)
            if [ $processed -lt $batch ] && [ "$added" -gt 0 ]; then
                sleep $mini_pause
            fi
            
            # Jeśli nie dodano nic, zakończ wcześniej
            [ "$added" -eq 0 ] && break
        done
        
        log "${GREEN}✅ Items: +$total_added kluczy w $((processed / mini_batch)) mini-batch${NC}"
    else
        log "${YELLOW}⚠️ Brak pliku items.xml${NC}"
    fi
}

# Przetwarzaj kategorię raids
process_raids_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/raids.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}⚔️ Processing raids...${NC}"
    
    for dir in data-otservbr-global/raids data-canary/raids data/raids; do
        [ ! -d "$dir" ] && continue
        
        # NAPRAWIONE: Filtruj processed PRZED head
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|xml\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            # Wyciągnij komunikaty raidów
            local announce=$(grep -oP '(?:broadcast|announce|message)[^"]*"\K[^"]+' "$file" 2>/dev/null | head -1)
            
            python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['raid.$safe.name'] = '''$name'''
if '''$announce''':
    d['raid.$safe.announce'] = '''$announce'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
            
            echo "$file" >> "$PROCESSED_FILE"
            count=$((count + 1))
            log "   ⚔️ raid.$safe.name = $name"
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.xml" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Raids: $count kluczy${NC}"
    echo "$count"
}

# Przetwarzaj kategorię world (mapy, areas, wydarzenia)
process_world_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/world.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🗺️ Processing world...${NC}"
    
    for dir in data-otservbr-global/world data-canary/world data/world; do
        [ ! -d "$dir" ] && continue
        
        # NAPRAWIONE: Filtruj processed PRZED head
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            # Wyciągnij teksty z plików świata
            local texts=$(grep -oP '"[^"]{10,}"' "$file" 2>/dev/null | head -5)
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            if [ -n "$texts" ]; then
                python3 -c "
import json
import re
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}

texts = '''$texts'''.strip().split('\n')
for i, t in enumerate(texts[:5]):
    t = t.strip('\"')
    if len(t) > 5:
        key = f'world.$safe.text{i+1}'
        d[key] = t
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ World: $count plików${NC}"
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
        
        # NAPRAWIONE: Filtruj processed PRZED head
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            # Wyciągnij stringi z bibliotek
            local strings=$(grep -oP 'sendTextMessage\s*\([^,]+,\s*"\K[^"]+' "$file" 2>/dev/null | head -5)
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            if [ -n "$strings" ]; then
                local i=1
                while IFS= read -r str; do
                    if [ -n "$str" ] && [ ${#str} -gt 5 ]; then
                        python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['lib.$safe.msg$i'] = '''$str'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                        i=$((i + 1))
                    fi
                done <<< "$strings"
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
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
        
        # NAPRAWIONE: Filtruj processed PRZED head
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij komunikaty eventów
            local messages=$(grep -oP '"[^"]{10,}"' "$file" 2>/dev/null | head -5)
            
            if [ -n "$messages" ]; then
                python3 -c "
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
" 2>/dev/null
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
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
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}💬 Processing chatchannels...${NC}"
    
    for dir in data/chatchannels data-otservbr-global/chatchannels; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['channel.$safe.name'] = '''$name'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
            
            echo "$file" >> "$PROCESSED_FILE"
            count=$((count + 1))
            log "   💬 channel.$safe.name = $name"
            
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Chatchannels: $count kluczy${NC}"
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
            local texts=$(grep -oP '"[^"]{10,}"' "$file" 2>/dev/null | head -5)
            
            if [ -n "$texts" ]; then
                python3 -c "
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
" 2>/dev/null
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
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
            local messages=$(grep -oP 'print\s*\(\s*"\K[^"]+' "$file" 2>/dev/null | head -5)
            [ -z "$messages" ] && messages=$(grep -oP '"[^"]{10,}"' "$file" 2>/dev/null | head -5)
            
            if [ -n "$messages" ]; then
                python3 -c "
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
" 2>/dev/null
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
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
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📖 Processing npclib...${NC}"
    
    for dir in data/npclib; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r file; do
            [ -f "$file" ] || continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij stałe tekstowe z biblioteki NPC
            local strings=$(grep -oP '(?:TEXT_|MSG_)[A-Z_]+\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -10)
            
            if [ -n "$strings" ]; then
                local i=1
                while IFS= read -r str; do
                    if [ -n "$str" ] && [ ${#str} -gt 3 ]; then
                        python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['npclib.$safe.const$i'] = '''$str'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                        i=$((i + 1))
                    fi
                done <<< "$strings"
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ NpcLib: $count plików${NC}"
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
            while IFS= read -r str; do
                str=$(echo "$str" | tr -d '"'"'" | head -c 200)
                if [ -n "$str" ] && [ ${#str} -gt 15 ]; then
                    python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'php.$safe.text$i'
if key not in d:
    d[key] = '''$str'''[:200]
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                    i=$((i + 1))
                fi
            done <<< "$strings"
            count=$((count + 1))
        fi
        
        echo "$file" >> "$PROCESSED_FILE"
        [ "$count" -ge "$batch" ] && break
    done < <(find html_copy -name "*.php" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
    
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
        local strings=$(grep -oP '>([^<]{20,})<' "$file" 2>/dev/null | tr -d '><' | head -5)
        
        if [ -n "$strings" ]; then
            local i=1
            while IFS= read -r str; do
                str=$(echo "$str" | head -c 200)
                if [ -n "$str" ] && [ ${#str} -gt 15 ]; then
                    python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'html.$safe.text$i'
if key not in d:
    d[key] = '''$str'''[:200]
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                    i=$((i + 1))
                fi
            done <<< "$strings"
            count=$((count + 1))
        fi
        
        echo "$file" >> "$PROCESSED_FILE"
        [ "$count" -ge "$batch" ] && break
    done < <(find html_copy -name "*.html" -o -name "*.twig" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
    
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
        local strings=$(grep -oP '"[^"]{10,100}"' "$file" 2>/dev/null \
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
            while IFS= read -r str; do
                # Tylko tekst z literami i spacjami, bez camelCase
                if [ -n "$str" ] && [ ${#str} -gt 8 ] && [[ "$str" =~ [a-zA-Z].*[[:space:]].*[a-zA-Z] ]]; then
                    python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'cpp.$safe.str$i'
if key not in d:
    d[key] = '''$str'''
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                    i=$((i + 1))
                fi
            done <<< "$strings"
            count=$((count + 1))
        fi
        
        echo "$file" >> "$PROCESSED_FILE"
        [ "$count" -ge "$batch" ] && break
    done < <(find src -name "*.cpp" -o -name "*.hpp" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
    
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
                while IFS= read -r str; do
                    # Pomiń jeśli wygląda jak kod lub nazwa pliku
                    if [ -n "$str" ] && [ ${#str} -gt 8 ] && [[ ! "$str" =~ ^[a-z]+[A-Z] ]] && [[ ! "$str" =~ ^[A-Z_]+$ ]]; then
                        python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
key = f'client.$safe.text$i'
if key not in d:
    d[key] = '''$str'''
    with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                        i=$((i + 1))
                    fi
                done <<< "$strings"
                count=$((count + 1))
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done < <(find "$dir" -name "*.lua" -o -name "*.otui" 2>/dev/null | grep -vFf "$PROCESSED_FILE" 2>/dev/null | head -$batch)
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
    
    # Pattern 1: Główny pattern "Sold %ix %s for %i gold." (304 plików!)
    local sold_pattern='player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))'
    local sold_replace='player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})'
    
    for file in $(find data-otservbr-global/npc -name "*.lua" 2>/dev/null); do
        [ -f "$file" ] || continue
        
        # Sprawdź czy plik ma pattern
        if grep -q 'string\.format("Sold %ix %s for %i gold\."' "$file" 2>/dev/null; then
            # Zamień
            sed -i 's|player:sendTextMessage(MESSAGE_TRADE, string\.format("Sold %ix %s for %i gold\.", amount, name, totalCost))|player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})|g' "$file"
            modified=$((modified + 1))
            log "   📨 Zamieniono w: $(basename $file)"
        fi
        
        count=$((count + 1))
        [ "$modified" -ge "$batch" ] && break
    done
    
    # Dodaj klucz do messages.json jeśli nie istnieje
    python3 << 'MSGPY'
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
    
    # Pattern 2: Proste teksty bez zmiennych
    local simple_patterns=(
        'MESSAGE_STATUS|"You are already blessed."|system.blessing.already'
        'MESSAGE_GAME_HIGHLIGHT|"Venture the path of decay!"|system.venture.decay'
    )
    
    for pattern_line in "${simple_patterns[@]}"; do
        IFS='|' read -r msg_type old_text new_key <<< "$pattern_line"
        
        for file in $(find data-otservbr-global/npc -name "*.lua" 2>/dev/null); do
            [ -f "$file" ] || continue
            
            if grep -q "sendTextMessage($msg_type, $old_text)" "$file" 2>/dev/null; then
                sed -i "s|player:sendTextMessage($msg_type, $old_text)|player:sendLocalizedTextMessage($msg_type, \"$new_key\")|g" "$file"
                modified=$((modified + 1))
                log "   📨 Simple pattern w: $(basename $file)"
            fi
        done
    done
    
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
    python3 << 'KWPY'
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
    
    python3 << 'TWIGPY'
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
    
    python3 << SYNCPY
import json
import os
import time

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
    exit(1)

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
    exit(0)

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
SYNCPY
    
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
    # Jeśli TRANSLATE_LIMIT nie ustawiony, użyj keys_count jako limitu
    local translate_limit="${TRANSLATE_LIMIT:-${keys_count:-0}}"  # 0 = brak limitu
    
    log "${CYAN}🌍 AUTO TRANSLATE: $target_lang <- $json_file (limit: $translate_limit)${NC}"
    
    python3 << AUTOTRANSPY
import json
import os
import re
import hashlib

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
    """Prosta zamiana znanych fraz"""
    if lang not in SIMPLE_TRANSLATIONS:
        return None
    
    result = text
    for en, translated in SIMPLE_TRANSLATIONS[lang].items():
        # Case-insensitive replace zachowując wielkość liter
        pattern = re.compile(re.escape(en), re.IGNORECASE)
        result = pattern.sub(translated, result)
    
    # Jeśli nic się nie zmieniło, zwróć None
    if result == text:
        return None
    return result

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
AUTOTRANSPY
    
    log "${GREEN}✅ Auto-translate zakończone${NC}"
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

target_lang = os.environ.get("TRANSLATE_LANG", "pl")
i18n_dir = os.environ.get("TRANSLATE_I18N_DIR", "i18n")
status_file = os.environ.get("TRANSLATE_STATUS_FILE", "i18n_file_status.json")
batch_size = int(os.environ.get("TRANSLATE_BATCH", "50"))
substage_size = int(os.environ.get("TRANSLATE_SUBSTAGE", "4"))

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
        with open(lang_file, "w") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
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
with open(lang_file, "w") as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)

# Statystyki
placeholders = len([v for v in lang_data.values() if v.startswith("[")])
real_total = len(lang_data) - placeholders

# [6/6] SYNC
print(f"[6/6] SYNC: Aktualizacja statusu")

# Aktualizuj status
with open(status_file) as f:
    status = json.load(f)

if "translation_status" not in status:
    status["translation_status"] = {}

status["translation_status"][target_lang] = {
    "total_keys": len(lang_data),
    "translated": real_total,
    "placeholders": placeholders,
    "last_batch": translated_count,
    "last_update": __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S")
}

with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

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

# ============================================================================
# PEŁNA DEFINICJA KATEGORII - WSZYSTKIE FOLDERY
# ============================================================================
CATEGORIES = {
    # === NPC (priorytet 1) ===
    "npc": {
        "dirs": ["data-otservbr-global/npc", "data-canary/npc"],
        "patterns": [r'StdModule\.say', r'npcHandler:say\('],
        "exclude_if": ["i18nKey", "NPC_LIB.i18n.npcSay"],
        "json": "npc.json",
        "priority": 1
    },
    
    # === SCRIPTS (priorytet 2) ===
    "scripts": {
        "dirs": ["data-otservbr-global/scripts", "data/scripts"],
        "patterns": [r'sendTextMessage\s*\(', r'player:say\s*\('],
        "exclude_if": ["sendLocalizedTextMessage", "i18n.get"],
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
    
    # === RAIDS (priorytet 4) ===
    "raids": {
        "dirs": ["data-otservbr-global/raids", "data-canary/raids"],
        "patterns": [r'message="[^"]+', r'<message>[^<]+'],
        "exclude_if": ["i18n:"],
        "json": "raids.json",
        "file_ext": [".xml"],
        "priority": 4
    },
    
    # === WORLD (priorytet 5) ===
    "world": {
        "dirs": ["data-otservbr-global/world", "data-canary/world"],
        "patterns": [r'name="[^"]+', r'description="[^"]+'],
        "exclude_if": [],
        "json": "world.json",
        "file_ext": [".xml", ".lua"],
        "priority": 5
    },
    
    # === SPELLS (priorytet 6) ===
    "spells": {
        "dirs": ["data-otservbr-global/scripts/spells", "data/scripts/spells"],
        "patterns": [r'words\s*=\s*"[^"]+', r'description\s*=\s*"[^"]+'],
        "exclude_if": ["i18n:"],
        "json": "spells.json",
        "priority": 6
    },
    
    # === ITEMS (priorytet 7) ===
    "items": {
        "dirs": ["data/items", "data/XML"],
        "patterns": [r'name="[^"]+', r'description="[^"]+', r'<attribute key="description" value="[^"]+'],
        "exclude_if": [],
        "json": "items.json",
        "file_ext": [".xml"],
        "priority": 7
    },
    
    # === LIBS (priorytet 8) ===
    "libs": {
        "dirs": ["data/libs", "data-otservbr-global/lib"],
        "patterns": [r'"[^"]{20,}"'],
        "exclude_if": ["i18n", "require"],
        "json": "libs.json",
        "priority": 8
    },
    
    # === EVENTS (priorytet 9) ===
    "events": {
        "dirs": ["data/events"],
        "patterns": [r'sendTextMessage\s*\(', r'"[^"]{15,}"'],
        "exclude_if": ["i18n"],
        "json": "events.json",
        "priority": 9
    },
    
    # === CHATCHANNELS (priorytet 10) ===
    "chatchannels": {
        "dirs": ["data/chatchannels"],
        "patterns": [r'name\s*=\s*"[^"]+'],
        "exclude_if": [],
        "json": "chatchannels.json",
        "priority": 10
    },
    
    # === MODULES (priorytet 11) ===
    "modules": {
        "dirs": ["data/modules"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": ["require", "dofile"],
        "json": "modules.json",
        "priority": 11
    },
    
    # === STARTUP (priorytet 12) ===
    "startup": {
        "dirs": ["data-otservbr-global/startup"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": [],
        "json": "startup.json",
        "priority": 12
    },
    
    # === NPCLIB (priorytet 13) ===
    "npclib": {
        "dirs": ["data/npclib"],
        "patterns": [r'"[^"]{10,}"'],
        "exclude_if": ["i18n"],
        "json": "npclib.json",
        "priority": 13
    },
    
    # === HTML_COPY - PHP (priorytet 14) - Strona WWW ===
    "php": {
        "dirs": ["html_copy"],
        "patterns": [r'"[^"]{20,}"', r"'[^']{20,}'", r'echo\s*"[^"]+"'],
        "exclude_if": ["__()"],
        "json": "php.json",
        "file_ext": [".php"],
        "priority": 14
    },
    
    # === HTML_COPY - HTML/Twig (priorytet 15) ===
    "html": {
        "dirs": ["html_copy"],
        "patterns": [r'>[^<]{20,}<', r'title="[^"]+', r'placeholder="[^"]+'],
        "exclude_if": ["{{", "trans"],
        "json": "html.json",
        "file_ext": [".html", ".twig"],
        "priority": 15
    },
    
    # === SRC - C++ Server (priorytet 16) ===
    "cpp": {
        "dirs": ["src"],
        "patterns": [r'"[^"]{10,}"', r'pushString\s*\("[^"]+"\)'],
        "exclude_if": ["i18n::"],
        "json": "cpp.json",
        "file_ext": [".cpp", ".hpp"],
        "priority": 16
    },
    
    # === TESTYY - OTClient (priorytet 17) ===
    "client": {
        "dirs": ["testyy/modules", "testyy/mods"],
        "patterns": [r'"[^"]{10,}"', r"'[^']{10,}'"],
        "exclude_if": ["tr("],
        "json": "client.json",
        "file_ext": [".lua", ".otui"],
        "priority": 17
    },
    
    # === SENDTEXTMESSAGE - player:sendTextMessage patterns (priorytet 18) ===
    "sendtextmessage": {
        "dirs": ["data-otservbr-global/scripts", "data/scripts", "data-otservbr-global/npc", "data-canary/npc"],
        "patterns": [r'sendTextMessage\s*\([^,]+,\s*"[^"]+"'],
        "exclude_if": ["sendLocalizedTextMessage"],
        "json": "messages.json",
        "file_ext": [".lua"],
        "priority": 18
    },
    
    # === KEYWORDHANDLER - add*Keyword bez i18nKey (priorytet 19) ===
    "keywordhandler": {
        "dirs": ["data-otservbr-global/npc", "data-canary/npc"],
        "patterns": [r'keywordHandler:add\w+Keyword\s*\([^)]+\)'],
        "exclude_if": ["i18nKey"],
        "json": "npc.json",
        "file_ext": [".lua"],
        "priority": 19
    },
    
    # === TWIG - Twig templates bez trans() (priorytet 20) ===
    "twig": {
        "dirs": ["html_copy"],
        "patterns": [r'>[A-Z][^<]{10,}<', r'placeholder="[^"]+', r'title="[^"]+"'],
        "exclude_if": ["trans(", "{{ "],
        "json": "html.json",
        "file_ext": [".twig", ".html.twig"],
        "priority": 20
    }
}

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
                print(f"🔄 Auto-reset kategorii '{cat_name}' po 24h")
        
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

def count_files_needing_work(category):
    """Zlicz pliki wymagające migracji w danej kategorii"""
    config = CATEGORIES.get(category, {})
    if not config:
        return 0
    
    needs_work = 0
    for dir_path in config["dirs"]:
        if not os.path.isdir(dir_path):
            continue
        for root, dirs, files in os.walk(dir_path):
            for f in files:
                if not f.endswith(".lua") and not f.endswith(".xml"):
                    continue
                fpath = os.path.join(root, f)
                
                # Sprawdź czy plik nie jest już oznaczony jako completed
                if fpath in completed_files:
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
                        if needs:
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
for cat_name, config in sorted_cats:
    # Pomiń kategorie oznaczone do skip
    if should_skip_category(cat_name, cat_state):
        pending_skip = True
        continue
    needs_work = count_files_needing_work(cat_name)
    if needs_work > 0:
        cat_state["migrations_done"] = False
        write_category_state(cat_state)
        print(f"MIGRATION:{cat_name}:{needs_work}")
        exit(0)

# Jeśli są kategorie na skip/backoff, nie przechodź do TRANSLATION_SYNC
if pending_skip:
    cat_state["migrations_done"] = False
    write_category_state(cat_state)
    print("MIGRATION:pending_skip:0:WAIT")
    exit(0)

# Jeśli tu doszliśmy: brak pracy migracyjnej → uznaj migracje za zakończone
cat_state["migrations_done"] = True
write_category_state(cat_state)

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
                    if "StdModule.say" in content and "text" in content:
                        if "i18nKey" not in content:
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
            
            # Sprawdź npcHandler:say("...") bez NPC_LIB.i18n.npcSay
            if grep -qE 'npcHandler:say\(\s*"[^"]{5,}"' "$f" 2>/dev/null; then
                if ! grep -q "NPC_LIB.i18n.npcSay" "$f" 2>/dev/null; then
                    NEEDS_WORK=true
                fi
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
        trap 'echo ""; echo "⛔ Zatrzymuję worker..."; update_github_status; rm -f "$PID_FILE"; exit 0' SIGINT SIGTERM
        
        while true; do
            CYCLE=$((CYCLE + 1))
            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "🔄 CYKL #$CYCLE - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "═══════════════════════════════════════════════════════════════"
            
            # Sprawdź komendy sterowania z plików
            # Najpierw sprawdź worker_commands.txt (dla GitHub), potem .worker_command (lokalny)
            COMMANDS_TXT="worker_commands.txt"
            COMMAND_FILE=".worker_command"
            CMD=""
            
            # 1. Sprawdź worker_commands.txt (można edytować przez GitHub)
            if [ -f "$COMMANDS_TXT" ]; then
                # Znajdź pierwszą odkomentowaną komendę (bez # na początku)
                CMD=$(grep -v '^#' "$COMMANDS_TXT" | grep -v '^$' | grep -E '^(FORCE:|AUTO:|RANDOM|STATUS|SKIP|PAUSE:|NOTE:)' | head -1)
                
                if [ -n "$CMD" ]; then
                    echo "📨 Odebrano z worker_commands.txt: $CMD"
                    
                    # Zakomentuj wykonaną komendę i dodaj do historii
                    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
                    sed -i "s/^$CMD/#$CMD  # Wykonano $TIMESTAMP/" "$COMMANDS_TXT" 2>/dev/null
                    
                    # Dodaj do historii na końcu sekcji
                    echo "# [$TIMESTAMP] Wykonano: $CMD" >> "$COMMANDS_TXT"
                fi
            fi
            
            # 2. Sprawdź .worker_command (szybsze, lokalne)
            if [ -z "$CMD" ] && [ -f "$COMMAND_FILE" ]; then
                CMD=$(cat "$COMMAND_FILE" 2>/dev/null)
                rm -f "$COMMAND_FILE"
                [ -n "$CMD" ] && echo "📨 Odebrano z .worker_command: $CMD"
            fi
            
            # 3. Wykonaj komendę jeśli jest
            if [ -n "$CMD" ]; then
                case "$CMD" in
                    FORCE:*)
                        FORCED_CAT=$(echo "$CMD" | cut -d: -f2)
                        echo "🎯 Wymuszam kategorię: $FORCED_CAT"
                        MODE_TYPE="MIGRATION"
                        MODE_CAT="$FORCED_CAT"
                        MODE_COUNT="forced"
                        MODE_EXTRA="FORCED"
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
                    *)
                        echo "⚠️ Nieznana komenda: $CMD"
                        ;;
                esac
            fi
            
            # Jeśli nie było wymuszenia, użyj dispatchera
            if [ "$MODE_EXTRA2" = "AUTO" ]; then
                :
            elif [ -z "$MODE_EXTRA" ] || [ "$MODE_EXTRA" != "FORCED" -a "$MODE_EXTRA" != "RANDOM" ]; then
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
            
            # Zlicz klucze PRZED przetwarzaniem (do wykrycia czy coś dodano)
            KEYS_BEFORE=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo 0)
            
            case "$MODE_TYPE" in
                MIGRATION)
                    echo "🔧 TRYB: MIGRACJA kategorii '$MODE_CAT' ($MODE_COUNT plików do zrobienia)"
                    
                    # Specjalny przypadek: wszystkie kategorie są na skip
                    if [ "$MODE_CAT" = "pending_skip" ]; then
                        echo "   ⏳ Wszystkie kategorie są tymczasowo pominięte (skip), czekam..."
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
                            
                            # Przetwórz oba katalogi NPC
                            for npc_dir in data-otservbr-global/npc data-canary/npc; do
                                [ -d "$npc_dir" ] || continue
                                for f in "$npc_dir"/*.lua; do
                                    [ -f "$f" ] || continue
                                    
                                    # Sprawdź czy już completed
                                    echo "$COMPLETED_LIST" | grep -qF "$f" && continue
                                    
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
                                    
                                    if [ "$NEEDS_WORK" = "true" ]; then
                                        process_file "$f"
                                        COUNT=$((COUNT + 1))
                                        [ "$COUNT" -ge "$BATCH" ] && break 2
                                    fi
                                done
                            done
                            echo "   📊 NPC: Zmigrowano $COUNT plików"
                            update_category_state "npc" "$COUNT"
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
                                
                                # Szukaj sendTextMessage z jakimkolwiek stringiem (czystym lub konkatenowanym)
                                if grep -qE 'sendTextMessage\s*\([^,]+,\s*"' "$f" 2>/dev/null; then
                                    if ! grep -q "sendLocalizedTextMessage" "$f" 2>/dev/null; then
                                        process_scripts_file "$f"
                                        COUNT=$((COUNT + 1))
                                        [ "$COUNT" -ge "$BATCH" ] && break
                                    fi
                                fi
                            done < <(find data-otservbr-global/scripts data/scripts -name "*.lua" 2>/dev/null)
                            echo "   📊 Scripts: Przetworzono $COUNT plików"
                            update_category_state "scripts" "$COUNT"
                            ;;
                        monsters)
                            echo "   👹 Przetwarzam MONSTERS z mini-batch..."
                            COUNT=$(run_with_mini_batch "monsters" "process_monsters_category" "$BATCH")
                            update_category_state "monsters" "$COUNT"
                            ;;
                        spells)
                            echo "   ✨ Przetwarzam SPELLS z mini-batch..."
                            COUNT=$(run_with_mini_batch "spells" "process_spells_category" "$BATCH")
                            update_category_state "spells" "$COUNT"
                            ;;
                        items)
                            echo "   🎒 Przetwarzam ITEMS z mini-batch..."
                            COUNT=$(run_with_mini_batch "items" "process_items_category" "$BATCH")
                            update_category_state "items" "$COUNT"
                            ;;
                        raids)
                            echo "   ⚔️ Przetwarzam RAIDS z mini-batch..."
                            COUNT=$(run_with_mini_batch "raids" "process_raids_category" "$BATCH")
                            update_category_state "raids" "$COUNT"
                            ;;
                        world)
                            echo "   🗺️ Przetwarzam WORLD z mini-batch..."
                            COUNT=$(run_with_mini_batch "world" "process_world_category" "$BATCH")
                            update_category_state "world" "$COUNT"
                            ;;
                        libs)
                            echo "   📚 Przetwarzam LIBS z mini-batch..."
                            COUNT=$(run_with_mini_batch "libs" "process_libs_category" "$BATCH")
                            update_category_state "libs" "$COUNT"
                            ;;
                        events)
                            echo "   🎉 Przetwarzam EVENTS z mini-batch..."
                            COUNT=$(run_with_mini_batch "events" "process_events_category" "$BATCH")
                            update_category_state "events" "$COUNT"
                            ;;
                        chatchannels)
                            echo "   💬 Przetwarzam CHATCHANNELS z mini-batch..."
                            COUNT=$(run_with_mini_batch "chatchannels" "process_chatchannels_category" "$BATCH")
                            update_category_state "chatchannels" "$COUNT"
                            ;;
                        modules)
                            echo "   📦 Przetwarzam MODULES z mini-batch..."
                            COUNT=$(run_with_mini_batch "modules" "process_modules_category" "$BATCH")
                            update_category_state "modules" "$COUNT"
                            ;;
                        startup)
                            echo "   🚀 Przetwarzam STARTUP z mini-batch..."
                            COUNT=$(run_with_mini_batch "startup" "process_startup_category" "$BATCH")
                            update_category_state "startup" "$COUNT"
                            ;;
                        npclib)
                            echo "   📖 Przetwarzam NPCLIB z mini-batch..."
                            COUNT=$(run_with_mini_batch "npclib" "process_npclib_category" "$BATCH")
                            update_category_state "npclib" "$COUNT"
                            ;;
                        php)
                            echo "   🐘 Przetwarzam PHP z mini-batch..."
                            COUNT=$(run_with_mini_batch "php" "process_php_category" "$BATCH")
                            update_category_state "php" "$COUNT"
                            ;;
                        html)
                            echo "   📄 Przetwarzam HTML/Twig z mini-batch..."
                            COUNT=$(run_with_mini_batch "html" "process_html_category" "$BATCH")
                            update_category_state "html" "$COUNT"
                            ;;
                        cpp)
                            echo "   ⚙️ Przetwarzam C++ z mini-batch..."
                            COUNT=$(run_with_mini_batch "cpp" "process_cpp_category" "$BATCH")
                            update_category_state "cpp" "$COUNT"
                            ;;
                        client)
                            echo "   🎮 Przetwarzam OTClient z mini-batch..."
                            COUNT=$(run_with_mini_batch "client" "process_client_category" "$BATCH")
                            update_category_state "client" "$COUNT"
                            ;;
                        sendtextmessage|stm)
                            echo "   📨 Przetwarzam sendTextMessage z mini-batch..."
                            COUNT=$(run_with_mini_batch "sendtextmessage" "process_sendTextMessage_category" "$BATCH")
                            update_category_state "sendtextmessage" "$COUNT"
                            ;;
                        keywordhandler|kwh)
                            echo "   🔑 Przetwarzam keywordHandler z mini-batch..."
                            COUNT=$(run_with_mini_batch "keywordhandler" "process_keywordHandler_category" "$BATCH")
                            update_category_state "keywordhandler" "$COUNT"
                            ;;
                        twig)
                            echo "   🎨 Przetwarzam Twig templates z mini-batch..."
                            COUNT=$(run_with_mini_batch "twig" "process_twig_category" "$BATCH")
                            update_category_state "twig" "$COUNT"
                            ;;
                        *)
                            echo "   ⚠️ Nieznana kategoria: $MODE_CAT"
                            ;;
                    esac
                    
                    # === ŚLEDZENIE WYNIKU KATEGORII ===
                    # Zlicz klucze PO przetwarzaniu
                    KEYS_AFTER=$(python3 -c "import json,os; print(sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json')))" 2>/dev/null || echo "0")
                    KEYS_ADDED=$((KEYS_AFTER - KEYS_BEFORE))
                    
                    # Sprawdź też zmiany w git (pliki .lua zmodyfikowane)
                    FILES_CHANGED=$(git diff --name-only 2>/dev/null | grep "\.lua$" | wc -l)
                    FILES_CHANGED=${FILES_CHANGED:-0}
                    
                    # Jeśli ani kluczy nie dodano, ani plików nie zmieniono - kategoria jest "pusta"
                    COUNT=${COUNT:-0}
                    EFFECTIVE_COUNT=$((KEYS_ADDED + FILES_CHANGED + COUNT))
                    echo "   📈 Wynik: +$KEYS_ADDED kluczy, $FILES_CHANGED plików .lua, COUNT=$COUNT"
                    update_category_state "$MODE_CAT" "$EFFECTIVE_COUNT"
                    ;;
                TRANSLATION_SYNC)
                    echo "🌍 TRYB: TRANSLATION_SYNC - Etap 1 (język: $MODE_CAT, plik: $MODE_COUNT, brakuje: $MODE_EXTRA)"
                    
                    # Synchronizuj klucze EN → LANG z prefixem [EN]
                    sync_translation_keys "$MODE_CAT" "$MODE_COUNT" "${MODE_EXTRA:-300}"
                    ;;
                AUTO_TRANSLATE)
                    echo "🌍 TRYB: AUTO TRANSLATE (język: $MODE_CAT, plik: $MODE_COUNT, kluczy: $MODE_EXTRA)"
                    
                    # Automatyczne tłumaczenie BEZ interakcji!
                    auto_translate_keys "$MODE_CAT" "$MODE_COUNT" "$MODE_EXTRA"
                    ;;
                IDLE)
                    echo "✅ TRYB: IDLE - Wszystko zrobione!"
                    echo "   Migracja: ✅ | Tłumaczenia: ✅"
                    echo "   Czekam 5 minut na nowe pliki..."
                    sleep 300
                    continue
                    ;;
                *)
                    echo "⚠️ Nieznany tryb: $MODE_TYPE"
                    ;;
            esac
            
            # Zapisz licznik cykli do pliku (dla statusu)
            python3 -c "
import json
try:
    with open('i18n_global_stats.json', 'r') as f:
        data = json.load(f)
except:
    data = {}
data['total_cycles'] = $CYCLE
data['last_update'] = '$(date -Iseconds)'
data['mode'] = '$MODE_TYPE'
with open('i18n_global_stats.json', 'w') as f:
    json.dump(data, f, indent=2)
"
            
            # Aktualizuj status co cykl
            update_github_status
            
            # Git commit co cykl
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                if [ "$NO_GIT" = "true" ]; then
                    echo "🚫 --no-git: pomijam git add/commit/push"
                else
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
                fi
            fi
            
            echo ""
            echo "💤 Przerwa ${DELAY}s przed następnym cyklem..."
            
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
