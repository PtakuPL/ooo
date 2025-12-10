#!/bin/bash
#===============================================================================
# I18N AUTONOMOUS WORKER v5.0 - Full Pipeline
#===============================================================================
# Autonomiczny worker do migracji i18n z pełnym śledzeniem etapów
# 
# ETAPY:
# 1. STARTED      - Rozpoczęcie, hash, backup
# 2. ANALYSIS     - Skanowanie wzorców, kontekst
# 3. DOCUMENTATION- Generowanie dokumentacji
# 4. TRANSFORMATION- text= → i18nKey=
# 5. EXTRACTION_EN - Klucze do en/*.json
# 6. TRANSLATION  - Tłumaczenie na 53 języki
# 7. VALIDATION   - Sprawdzenie składni
# 8. SYNC         - Git commit, statystyki
#
# UŻYCIE:
#   ./i18n_worker_v5.sh                    # Tryb AUTO
#   ./i18n_worker_v5.sh --focus npc        # Tylko NPC
#   ./i18n_worker_v5.sh --file <path>      # Jeden plik
#   ./i18n_worker_v5.sh --status           # Pokaż status
#   ./i18n_worker_v5.sh --resume           # Kontynuuj
#===============================================================================

set -euo pipefail

#===============================================================================
# KONFIGURACJA
#===============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Pliki statusu
STATUS_FILE="i18n_file_status.json"
GLOBAL_STATS_FILE="i18n_global_stats.json"
LOG_FILE="i18n_worker_v5.log"

# Katalogi
I18N_DIR="i18n"
BACKUP_DIR="backups"
DOCS_DIR="docs/i18n/generated"

# Języki do tłumaczenia (53)
LANGUAGES=(
    "en" "pl" "de" "es" "pt" "fr" "it" "ru" "uk" "zh" 
    "ja" "ko" "ar" "tr" "nl" "sv" "da" "no" "fi" "cs" 
    "sk" "hu" "ro" "bg" "hr" "sr" "sl" "et" "lv" "lt" 
    "el" "he" "th" "vi" "id" "ms" "tl" "hi" "bn" "ta" 
    "te" "mr" "gu" "kn" "ml" "pa" "ur" "fa" "sw" "am" 
    "zu" "af" "ca"
)

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

#===============================================================================
# LOGOWANIE
#===============================================================================
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)  echo -e "${CYAN}[INFO]${NC} $msg" ;;
        OK)    echo -e "${GREEN}[OK]${NC} $msg" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $msg" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $msg" ;;
        STAGE) echo -e "${BLUE}[STAGE]${NC} $msg" ;;
    esac
    
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

#===============================================================================
# FUNKCJE JSON - ZARZĄDZANIE STATUSEM
#===============================================================================

# Inicjalizacja pliku statusu jeśli nie istnieje
init_status_file() {
    if [ ! -f "$STATUS_FILE" ]; then
        echo '{"files": {}, "meta": {"version": "5.0", "created": "'$(date -Iseconds)'"}}' > "$STATUS_FILE"
        log INFO "Utworzono $STATUS_FILE"
    fi
}

# Inicjalizacja pliku globalnych statystyk
init_global_stats() {
    if [ ! -f "$GLOBAL_STATS_FILE" ]; then
        cat > "$GLOBAL_STATS_FILE" << 'EOF'
{
    "last_updated": null,
    "total_files": {"npc": 0, "scripts": 0, "quests": 0, "libs": 0},
    "processed_files": {"npc": 0, "scripts": 0, "quests": 0, "libs": 0},
    "total_keys": {},
    "stages_summary": {
        "1_started": 0, "2_analysis": 0, "3_documentation": 0,
        "4_transformation": 0, "5_extraction_en": 0, "6_translation": 0,
        "7_validation": 0, "8_sync": 0
    },
    "errors": {"total": 0, "by_stage": {}}
}
EOF
        log INFO "Utworzono $GLOBAL_STATS_FILE"
    fi
}

# Pobierz status pliku
get_file_status() {
    local file_path="$1"
    python3 << EOF
import json
import sys

try:
    with open("$STATUS_FILE", "r") as f:
        data = json.load(f)
    
    file_status = data.get("files", {}).get("$file_path", None)
    if file_status:
        print(json.dumps(file_status))
    else:
        print("null")
except Exception as e:
    print("null", file=sys.stderr)
EOF
}

# Pobierz status konkretnego etapu
get_stage_status() {
    local file_path="$1"
    local stage="$2"
    
    python3 << EOF
import json

try:
    with open("$STATUS_FILE", "r") as f:
        data = json.load(f)
    
    stages = data.get("files", {}).get("$file_path", {}).get("stages", {})
    stage_data = stages.get("$stage", {})
    print(stage_data.get("status", "pending"))
except:
    print("pending")
EOF
}

# Ustaw status etapu (atomowy zapis)
set_stage_status() {
    local file_path="$1"
    local stage="$2"
    local status="$3"
    local result="${4:-}"
    
    python3 << EOF
import json
import os
import tempfile
from datetime import datetime

file_path = "$file_path"
stage = "$stage"
status = "$status"
result_str = '''$result'''

try:
    with open("$STATUS_FILE", "r") as f:
        data = json.load(f)
except:
    data = {"files": {}, "meta": {"version": "5.0"}}

# Inicjalizuj strukturę pliku jeśli nie istnieje
if file_path not in data["files"]:
    # Określ typ pliku
    if "/npc/" in file_path:
        file_type = "npc"
    elif "/scripts/" in file_path:
        file_type = "scripts"
    elif "/quests/" in file_path:
        file_type = "quests"
    else:
        file_type = "other"
    
    data["files"][file_path] = {
        "file_path": file_path,
        "file_type": file_type,
        "stages": {},
        "overall_status": "in_progress",
        "errors": []
    }

# Ustaw status etapu
stage_data = {
    "status": status,
    "timestamp": datetime.now().isoformat()
}

# Dodaj wynik jeśli podany
if result_str and result_str != "":
    try:
        stage_data["result"] = json.loads(result_str)
    except:
        stage_data["result"] = result_str

data["files"][file_path]["stages"][stage] = stage_data

# Oblicz overall progress
stages = data["files"][file_path]["stages"]
completed = sum(1 for s in stages.values() if s.get("status") == "completed")
total = 8
data["files"][file_path]["overall_progress"] = f"{completed}/{total}"

if completed == total:
    data["files"][file_path]["overall_status"] = "completed"

# Atomowy zapis
fd, temp_path = tempfile.mkstemp(dir=".")
with os.fdopen(fd, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
os.rename(temp_path, "$STATUS_FILE")

print("ok")
EOF
}

# Pobierz listę plików do przetworzenia (niezakończone)
get_pending_files() {
    local file_type="${1:-all}"
    local stage="${2:-any}"
    
    python3 << EOF
import json
import os
import glob

file_type = "$file_type"
stage_filter = "$stage"

# Zbierz wszystkie pliki Lua
all_files = []
patterns = {
    "npc": "data-otservbr-global/npc/*.lua",
    "scripts": "data-otservbr-global/scripts/**/*.lua",
    "quests": "data-otservbr-global/scripts/quests/**/*.lua"
}

if file_type == "all":
    for pattern in patterns.values():
        all_files.extend(glob.glob(pattern, recursive=True))
elif file_type in patterns:
    all_files = glob.glob(patterns[file_type], recursive=True)

# Wczytaj status
try:
    with open("$STATUS_FILE", "r") as f:
        data = json.load(f)
except:
    data = {"files": {}}

# Filtruj pliki
pending = []
for f in all_files:
    file_status = data.get("files", {}).get(f, {})
    overall = file_status.get("overall_status", "pending")
    
    if overall == "completed":
        continue
    
    if stage_filter != "any":
        stage_status = file_status.get("stages", {}).get(stage_filter, {}).get("status", "pending")
        if stage_status == "completed":
            continue
    
    pending.append(f)

# Sortuj: najpierw te w trakcie, potem nowe
in_progress = [f for f in pending if data.get("files", {}).get(f, {}).get("overall_status") == "in_progress"]
new_files = [f for f in pending if f not in in_progress]

for f in sorted(in_progress) + sorted(new_files):
    print(f)
EOF
}

# Pobierz następny etap do wykonania dla pliku
get_next_stage() {
    local file_path="$1"
    
    python3 << EOF
import json

stages_order = [
    "1_started", "2_analysis", "3_documentation", "4_transformation",
    "5_extraction_en", "6_translation", "7_validation", "8_sync"
]

try:
    with open("$STATUS_FILE", "r") as f:
        data = json.load(f)
    
    file_data = data.get("files", {}).get("$file_path", {})
    stages = file_data.get("stages", {})
    
    for stage in stages_order:
        status = stages.get(stage, {}).get("status", "pending")
        if status != "completed":
            print(stage)
            exit(0)
    
    print("all_done")
except:
    print("1_started")
EOF
}

#===============================================================================
# ETAP 1: STARTED - Rozpoczęcie pracy nad plikiem
#===============================================================================
stage_1_started() {
    local file="$1"
    log STAGE "1/8 STARTED: $file"
    
    # Sprawdź czy plik istnieje
    if [ ! -f "$file" ]; then
        log ERROR "Plik nie istnieje: $file"
        set_stage_status "$file" "1_started" "error" '{"error": "file_not_found"}'
        return 1
    fi
    
    # Oblicz hash
    local file_hash=$(md5sum "$file" | cut -d' ' -f1)
    
    # Określ typ i kategorię
    local file_type="other"
    local category="other"
    local backup_dir="$BACKUP_DIR/other"
    
    if [[ "$file" == *"/npc/"* ]]; then
        file_type="npc"
        category="npc"
        backup_dir="$BACKUP_DIR/npc"
    elif [[ "$file" == *"/scripts/quests/"* ]]; then
        file_type="quest"
        category="quests"
        backup_dir="$BACKUP_DIR/quests"
    elif [[ "$file" == *"/scripts/"* ]]; then
        file_type="script"
        category="scripts"
        backup_dir="$BACKUP_DIR/scripts"
    fi
    
    # Utwórz backup
    mkdir -p "$backup_dir"
    local backup_path="$backup_dir/$(basename "$file").bak"
    cp "$file" "$backup_path"
    
    # Zapisz status
    local result=$(cat << EOF
{
    "file_hash": "$file_hash",
    "file_type": "$file_type",
    "category": "$category",
    "backup_path": "$backup_path",
    "file_size": $(stat -c%s "$file")
}
EOF
)
    
    set_stage_status "$file" "1_started" "completed" "$result"
    log OK "Etap 1 zakończony: hash=$file_hash, backup=$backup_path"
    return 0
}

#===============================================================================
# ETAP 2: ANALYSIS - Analiza pliku
#===============================================================================
stage_2_analysis() {
    local file="$1"
    log STAGE "2/8 ANALYSIS: $file"
    
    # Pobierz info z etapu 1
    local file_type=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('file_type','unknown'))
")
    
    # Wyodrębnij nazwę (bez rozszerzenia)
    local base_name=$(basename "$file" .lua)
    local safe_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Skanuj wzorce
    local stdmodule_count=$(grep -c "StdModule\.say.*text[[:space:]]*=" "$file" 2>/dev/null || echo 0)
    local npchandler_say_count=$(grep -c "npcHandler:say" "$file" 2>/dev/null || echo 0)
    local sendtext_count=$(grep -c "sendTextMessage" "$file" 2>/dev/null || echo 0)
    local i18nkey_count=$(grep -c "i18nKey" "$file" 2>/dev/null || echo 0)
    local total_strings=$((stdmodule_count + npchandler_say_count + sendtext_count))
    
    # Wykryj wzorce
    local patterns_found="[]"
    local patterns_list=""
    
    if [ "$stdmodule_count" -gt 0 ]; then
        patterns_list="${patterns_list}\"StdModule.say\","
    fi
    if [ "$npchandler_say_count" -gt 0 ]; then
        patterns_list="${patterns_list}\"npcHandler:say\","
    fi
    if [ "$sendtext_count" -gt 0 ]; then
        patterns_list="${patterns_list}\"sendTextMessage\","
    fi
    
    # Usuń końcowy przecinek i zbuduj JSON array
    patterns_list="${patterns_list%,}"
    if [ -n "$patterns_list" ]; then
        patterns_found="[$patterns_list]"
    fi
    
    # Kontekst NPC
    local npc_name=""
    local keywords=""
    
    if [ "$file_type" = "npc" ]; then
        # Wyciągnij nazwę NPC
        npc_name=$(grep -oP 'internalNpcName\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
        [ -z "$npc_name" ] && npc_name="$base_name"
        
        # Wyciągnij słowa kluczowe
        keywords=$(grep -oP 'addKeyword\s*\(\s*\{\s*"\K[^"]+' "$file" 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')
    fi
    
    # Określ czy plik wymaga migracji
    local needs_migration="true"
    if [ "$total_strings" -eq 0 ] || [ "$i18nkey_count" -ge "$stdmodule_count" ]; then
        needs_migration="false"
    fi
    
    # Zapisz wynik
    local result=$(cat << EOF
{
    "safe_name": "$safe_name",
    "npc_name": "$npc_name",
    "patterns_found": $patterns_found,
    "strings_count": $total_strings,
    "strings_by_pattern": {
        "StdModule.say": $stdmodule_count,
        "npcHandler:say": $npchandler_say_count,
        "sendTextMessage": $sendtext_count
    },
    "already_migrated": $i18nkey_count,
    "needs_migration": $needs_migration,
    "keywords": "$keywords"
}
EOF
)
    
    set_stage_status "$file" "2_analysis" "completed" "$result"
    log OK "Etap 2 zakończony: $total_strings stringów, wzorce: $patterns_found"
    
    # Zwróć czy potrzebna migracja
    [ "$needs_migration" = "true" ] && return 0 || return 2
}

#===============================================================================
# ETAP 3: DOCUMENTATION - Generowanie dokumentacji
#===============================================================================
stage_3_documentation() {
    local file="$1"
    log STAGE "3/8 DOCUMENTATION: $file"
    
    # Pobierz dane z poprzednich etapów
    local analysis=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
result = data.get('files',{}).get('$file',{}).get('stages',{}).get('2_analysis',{}).get('result',{})
print(json.dumps(result))
")
    
    local safe_name=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('safe_name','unknown'))")
    local npc_name=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('npc_name',''))")
    local strings_count=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('strings_count',0))")
    local keywords=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('keywords',''))")
    
    # Określ katalog dokumentacji
    local file_type=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('category','other'))
")
    
    local doc_dir="$DOCS_DIR/$file_type"
    mkdir -p "$doc_dir"
    local doc_file="$doc_dir/${safe_name}.md"
    
    # Wyciągnij teksty do dokumentacji
    local texts=""
    if [ -f "$file" ]; then
        texts=$(grep -oP 'text[[:space:]]*=[[:space:]]*"\K[^"]+' "$file" 2>/dev/null | head -30 | while read -r t; do
            echo "| \`npc.${safe_name}.*\` | $t |"
        done)
    fi
    
    # Generuj dokumentację
    cat > "$doc_file" << EOF
# ${npc_name:-$safe_name}

> Auto-generowana dokumentacja i18n  
> Data: $(date '+%Y-%m-%d %H:%M')  
> Plik źródłowy: \`$file\`

## Informacje podstawowe

| Pole | Wartość |
|------|---------|
| **Nazwa** | ${npc_name:-$safe_name} |
| **Plik** | \`$file\` |
| **Typ** | $file_type |
| **Stringów** | $strings_count |

## Słowa kluczowe

\`\`\`
$keywords
\`\`\`

## Dialogi / Teksty

| Klucz i18n | Tekst EN |
|------------|----------|
$texts

## Historia zmian

- **$(date '+%Y-%m-%d')**: Utworzono dokumentację (worker v5.0)
EOF
    
    set_stage_status "$file" "3_documentation" "completed" "{\"doc_file\": \"$doc_file\"}"
    log OK "Etap 3 zakończony: $doc_file"
    return 0
}

#===============================================================================
# ETAP 4: TRANSFORMATION - Transformacja kodu
#===============================================================================
stage_4_transformation() {
    local file="$1"
    log STAGE "4/8 TRANSFORMATION: $file"
    
    # Pobierz dane z analizy
    local analysis=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
result = data.get('files',{}).get('$file',{}).get('stages',{}).get('2_analysis',{}).get('result',{})
print(json.dumps(result))
")
    
    local safe_name=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('safe_name','unknown'))")
    local needs_migration=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('needs_migration',True))")
    
    if [ "$needs_migration" = "False" ] || [ "$needs_migration" = "false" ]; then
        log INFO "Plik nie wymaga migracji (już zmigrowany lub brak stringów)"
        set_stage_status "$file" "4_transformation" "completed" '{"transformed": 0, "skipped": true}'
        return 0
    fi
    
    # Wykonaj transformację
    local temp_file=$(mktemp)
    local transformed=0
    local key_counter=1
    
    while IFS= read -r line || [ -n "$line" ]; do
        local new_line="$line"
        
        # Transformacja StdModule.say text= → i18nKey=
        if echo "$line" | grep -qE 'StdModule\.say.*text[[:space:]]*=[[:space:]]*"[^"]{5,}"'; then
            local text=$(echo "$line" | sed -n 's/.*text[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p')
            if [ -n "$text" ] && [ ${#text} -ge 5 ]; then
                local key="npc.${safe_name}.stdmod_${key_counter}"
                key_counter=$((key_counter + 1))
                
                new_line=$(echo "$line" | sed "s|text[[:space:]]*=[[:space:]]*\"[^\"]*\"|i18nKey = \"${key}\"|")
                transformed=$((transformed + 1))
            fi
        fi
        
        echo "$new_line" >> "$temp_file"
    done < "$file"
    
    # Zapisz zmiany jeśli były
    if [ "$transformed" -gt 0 ]; then
        mv "$temp_file" "$file"
        log OK "Przekształcono $transformed stringów"
    else
        rm -f "$temp_file"
    fi
    
    set_stage_status "$file" "4_transformation" "completed" "{\"transformed\": $transformed}"
    log OK "Etap 4 zakończony: $transformed transformacji"
    return 0
}

#===============================================================================
# ETAP 5: EXTRACTION_EN - Ekstrakcja do angielskiego JSON
#===============================================================================
stage_5_extraction_en() {
    local file="$1"
    log STAGE "5/8 EXTRACTION_EN: $file"
    
    # Pobierz dane
    local analysis=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
result = data.get('files',{}).get('$file',{}).get('stages',{}).get('2_analysis',{}).get('result',{})
print(json.dumps(result))
")
    
    local safe_name=$(echo "$analysis" | python3 -c "import json,sys; print(json.load(sys.stdin).get('safe_name','unknown'))")
    local category=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('category','other'))
")
    
    # Pobierz backup (oryginalne teksty)
    local backup_path=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('backup_path',''))
")
    
    local source_file="$file"
    [ -f "$backup_path" ] && source_file="$backup_path"
    
    local json_file="$I18N_DIR/en/${category}.json"
    [ ! -f "$json_file" ] && echo "{}" > "$json_file"
    
    # Ekstrahuj klucze i teksty
    local keys_added=0
    
    keys_added=$(python3 << EOF
import json
import re
import os
import tempfile

safe_name = "$safe_name"
source_file = "$source_file"
json_file = "$json_file"

# Wczytaj istniejące klucze
try:
    with open(json_file, "r") as f:
        data = json.load(f)
except:
    data = {}

# Parsuj plik źródłowy
keys_added = 0
key_counter = 1

with open(source_file, "r") as f:
    content = f.read()

# Wzorzec: text = "..." 
pattern = r'text\s*=\s*"([^"]+)"'
matches = re.findall(pattern, content)

for text in matches:
    if len(text) >= 5:
        key = f"npc.{safe_name}.stdmod_{key_counter}"
        if key not in data:
            data[key] = text
            keys_added += 1
        key_counter += 1

# Atomowy zapis
fd, temp_path = tempfile.mkstemp(dir=os.path.dirname(json_file))
with os.fdopen(fd, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
os.rename(temp_path, json_file)

print(keys_added)
EOF
)
    
    set_stage_status "$file" "5_extraction_en" "completed" "{\"keys_added\": $keys_added, \"json_file\": \"$json_file\"}"
    log OK "Etap 5 zakończony: $keys_added kluczy do $json_file"
    return 0
}

#===============================================================================
# ETAP 6: TRANSLATION - Tłumaczenie na inne języki
#===============================================================================
stage_6_translation() {
    local file="$1"
    log STAGE "6/8 TRANSLATION: $file"
    
    # Pobierz dane
    local safe_name=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('2_analysis',{}).get('result',{}).get('safe_name','unknown'))
")
    
    local category=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('category','other'))
")
    
    local en_json="$I18N_DIR/en/${category}.json"
    local languages_done=0
    
    # Kopiuj klucze do innych języków (na razie bez tłumaczenia - placeholder)
    for lang in "${LANGUAGES[@]}"; do
        [ "$lang" = "en" ] && continue
        
        local lang_dir="$I18N_DIR/$lang"
        mkdir -p "$lang_dir"
        local lang_json="$lang_dir/${category}.json"
        
        # Synchronizuj klucze
        python3 << EOF
import json
import os
import tempfile

safe_name = "$safe_name"
en_file = "$en_json"
lang_file = "$lang_json"

# Wczytaj EN
with open(en_file, "r") as f:
    en_data = json.load(f)

# Wczytaj lub utwórz plik językowy
try:
    with open(lang_file, "r") as f:
        lang_data = json.load(f)
except:
    lang_data = {}

# Kopiuj brakujące klucze (z prefiksem npc.{safe_name})
prefix = f"npc.{safe_name}."
for key, value in en_data.items():
    if key.startswith(prefix) and key not in lang_data:
        # Na razie kopiujemy EN, później tłumaczenie
        lang_data[key] = value

# Zapisz
fd, temp_path = tempfile.mkstemp(dir=os.path.dirname(lang_file) if os.path.dirname(lang_file) else ".")
with os.fdopen(fd, 'w') as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)
os.rename(temp_path, lang_file)
EOF
        languages_done=$((languages_done + 1))
    done
    
    set_stage_status "$file" "6_translation" "completed" "{\"languages_synced\": $languages_done}"
    log OK "Etap 6 zakończony: zsynchronizowano $languages_done języków"
    return 0
}

#===============================================================================
# ETAP 7: VALIDATION - Walidacja
#===============================================================================
stage_7_validation() {
    local file="$1"
    log STAGE "7/8 VALIDATION: $file"
    
    local errors=""
    local lua_ok="true"
    local json_ok="true"
    
    # Sprawdź składnię Lua
    if command -v luac &> /dev/null; then
        if ! luac -p "$file" 2>/dev/null; then
            lua_ok="false"
            errors="Lua syntax error"
        fi
    fi
    
    # Sprawdź JSONy
    local category=$(python3 -c "
import json
with open('$STATUS_FILE') as f:
    data = json.load(f)
print(data.get('files',{}).get('$file',{}).get('stages',{}).get('1_started',{}).get('result',{}).get('category','other'))
")
    
    local en_json="$I18N_DIR/en/${category}.json"
    if [ -f "$en_json" ]; then
        if ! python3 -m json.tool "$en_json" > /dev/null 2>&1; then
            json_ok="false"
            errors="${errors}; JSON invalid"
        fi
    fi
    
    local status="completed"
    [ "$lua_ok" = "false" ] || [ "$json_ok" = "false" ] && status="error"
    
    set_stage_status "$file" "7_validation" "$status" "{\"lua_syntax\": $lua_ok, \"json_valid\": $json_ok, \"errors\": \"$errors\"}"
    log OK "Etap 7 zakończony: lua=$lua_ok, json=$json_ok"
    return 0
}

#===============================================================================
# ETAP 8: SYNC - Synchronizacja i finalizacja
#===============================================================================
stage_8_sync() {
    local file="$1"
    log STAGE "8/8 SYNC: $file"
    
    # Aktualizuj globalne statystyki
    python3 << EOF
import json
import os
import tempfile
from datetime import datetime

# Wczytaj statystyki
try:
    with open("$GLOBAL_STATS_FILE", "r") as f:
        stats = json.load(f)
except:
    stats = {"processed_files": {}, "stages_summary": {}}

# Pobierz kategorię
with open("$STATUS_FILE", "r") as f:
    status_data = json.load(f)

file_data = status_data.get("files", {}).get("$file", {})
category = file_data.get("stages", {}).get("1_started", {}).get("result", {}).get("category", "other")

# Aktualizuj liczniki
if category not in stats.get("processed_files", {}):
    stats["processed_files"][category] = 0
stats["processed_files"][category] += 1

# Aktualizuj etapy
for stage in ["1_started", "2_analysis", "3_documentation", "4_transformation", "5_extraction_en", "6_translation", "7_validation", "8_sync"]:
    if stage not in stats.get("stages_summary", {}):
        stats["stages_summary"][stage] = 0
    stage_status = file_data.get("stages", {}).get(stage, {}).get("status", "")
    if stage_status == "completed":
        stats["stages_summary"][stage] += 1

stats["last_updated"] = datetime.now().isoformat()

# Zapisz
fd, temp_path = tempfile.mkstemp(dir=".")
with os.fdopen(fd, 'w') as f:
    json.dump(stats, f, indent=2, ensure_ascii=False)
os.rename(temp_path, "$GLOBAL_STATS_FILE")
EOF
    
    set_stage_status "$file" "8_sync" "completed" "{\"synced\": true}"
    log OK "Etap 8 zakończony: plik w pełni przetworzony!"
    return 0
}

#===============================================================================
# GŁÓWNA PĘTLA - Przetwarzanie jednego pliku (wszystkie etapy)
#===============================================================================
process_file() {
    local file="$1"
    
    echo ""
    echo "========================================"
    log INFO "Przetwarzanie: $file"
    echo "========================================"
    
    # Pobierz następny etap
    local next_stage=$(get_next_stage "$file")
    
    while [ "$next_stage" != "all_done" ]; do
        case "$next_stage" in
            "1_started")
                stage_1_started "$file" || return 1
                ;;
            "2_analysis")
                stage_2_analysis "$file"
                local ret=$?
                # ret=2 oznacza że plik nie wymaga migracji
                ;;
            "3_documentation")
                stage_3_documentation "$file" || return 1
                ;;
            "4_transformation")
                stage_4_transformation "$file" || return 1
                ;;
            "5_extraction_en")
                stage_5_extraction_en "$file" || return 1
                ;;
            "6_translation")
                stage_6_translation "$file" || return 1
                ;;
            "7_validation")
                stage_7_validation "$file" || return 1
                ;;
            "8_sync")
                stage_8_sync "$file" || return 1
                ;;
        esac
        
        next_stage=$(get_next_stage "$file")
    done
    
    log OK "✅ Plik $file w pełni przetworzony!"
    return 0
}

#===============================================================================
# WYŚWIETLANIE STATUSU
#===============================================================================
show_status() {
    echo ""
    echo "========================================"
    echo "        I18N WORKER v5.0 - STATUS"
    echo "========================================"
    
    python3 << 'EOF'
import json

try:
    with open("i18n_file_status.json", "r") as f:
        status = json.load(f)
    
    files = status.get("files", {})
    total = len(files)
    completed = sum(1 for f in files.values() if f.get("overall_status") == "completed")
    in_progress = sum(1 for f in files.values() if f.get("overall_status") == "in_progress")
    
    print(f"\n📊 Pliki:")
    print(f"   Łącznie śledzonych: {total}")
    print(f"   ✅ Zakończonych: {completed}")
    print(f"   🔄 W trakcie: {in_progress}")
    
    # Statystyki etapów
    stages = {}
    for f in files.values():
        for stage, data in f.get("stages", {}).items():
            if stage not in stages:
                stages[stage] = {"completed": 0, "error": 0}
            if data.get("status") == "completed":
                stages[stage]["completed"] += 1
            elif data.get("status") == "error":
                stages[stage]["error"] += 1
    
    print(f"\n📈 Etapy:")
    for stage in sorted(stages.keys()):
        c = stages[stage]["completed"]
        e = stages[stage]["error"]
        print(f"   {stage}: {c} ✅, {e} ❌")

except FileNotFoundError:
    print("Brak pliku statusu. Uruchom workera aby rozpocząć.")
except Exception as e:
    print(f"Błąd: {e}")
EOF
    
    echo ""
}

#===============================================================================
# GŁÓWNA FUNKCJA
#===============================================================================
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           I18N AUTONOMOUS WORKER v5.0 - Full Pipeline          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Parsuj argumenty
    local mode="auto"
    local focus=""
    local target_file=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status)
                show_status
                exit 0
                ;;
            --focus)
                mode="focus"
                focus="$2"
                shift 2
                ;;
            --file)
                mode="file"
                target_file="$2"
                shift 2
                ;;
            --resume)
                mode="resume"
                shift
                ;;
            --help)
                echo "Użycie:"
                echo "  $0                    # Tryb AUTO"
                echo "  $0 --status           # Pokaż status"
                echo "  $0 --focus npc        # Tylko NPC"
                echo "  $0 --file <path>      # Jeden plik"
                echo "  $0 --resume           # Kontynuuj przerwane"
                exit 0
                ;;
            *)
                log ERROR "Nieznany argument: $1"
                exit 1
                ;;
        esac
    done
    
    # Inicjalizacja
    init_status_file
    init_global_stats
    
    log INFO "Tryb: $mode"
    
    # Przetwarzanie
    case "$mode" in
        "file")
            if [ -z "$target_file" ]; then
                log ERROR "Nie podano pliku!"
                exit 1
            fi
            process_file "$target_file"
            ;;
        "focus"|"auto"|"resume")
            local file_type="all"
            [ "$mode" = "focus" ] && file_type="$focus"
            
            log INFO "Szukam plików do przetworzenia (typ: $file_type)..."
            
            local pending_files=$(get_pending_files "$file_type")
            local count=$(echo "$pending_files" | grep -c "." || echo 0)
            
            log INFO "Znaleziono $count plików do przetworzenia"
            
            if [ -z "$pending_files" ]; then
                log OK "Wszystkie pliki przetworzone!"
                exit 0
            fi
            
            # Przetwarzaj pliki
            local processed=0
            local errors=0
            
            echo "$pending_files" | head -20 | while read -r file; do
                [ -z "$file" ] && continue
                
                if process_file "$file"; then
                    processed=$((processed + 1))
                else
                    errors=$((errors + 1))
                fi
                
                # Przerwa między plikami
                sleep 0.5
            done
            
            echo ""
            echo "========================================"
            log OK "Sesja zakończona!"
            log INFO "Uruchom ponownie aby kontynuować z następnymi plikami"
            echo "========================================"
            ;;
    esac
    
    show_status
}

# Uruchom
main "$@"
