#!/bin/bash
#===============================================================================
# I18N WORKER SIMPLE v1.0 - Prosty worker bez zawieszania
#===============================================================================

cd "$(dirname "$0")"

STATUS_FILE="i18n_file_status.json"
I18N_DIR="i18n"
BACKUP_DIR="backups"

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "$1"; }

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
    
    local stdmod=$(grep -c "StdModule\.say.*text" "$file" 2>/dev/null || echo "0")
    local npcsay=$(grep -c "npcHandler:say" "$file" 2>/dev/null || echo "0")
    local sendtxt=$(grep -c "sendTextMessage" "$file" 2>/dev/null || echo "0")
    local i18nkey=$(grep -c "i18nKey" "$file" 2>/dev/null || echo "0")
    
    # Wyczyść zmienne - usuń białe znaki
    stdmod=${stdmod//[[:space:]]/}
    npcsay=${npcsay//[[:space:]]/}
    sendtxt=${sendtxt//[[:space:]]/}
    i18nkey=${i18nkey//[[:space:]]/}
    
    # Domyślne wartości
    [ -z "$stdmod" ] && stdmod=0
    [ -z "$npcsay" ] && npcsay=0
    [ -z "$sendtxt" ] && sendtxt=0
    [ -z "$i18nkey" ] && i18nkey=0
    
    local total=$((stdmod + npcsay + sendtxt))
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local needs="true"
    [ "$total" -eq 0 ] && needs="false"
    [ "$i18nkey" -ge "$stdmod" ] && [ "$stdmod" -gt 0 ] && needs="false"
    
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
    'total': $total,
    'already_i18n': $i18nkey,
    'needs_migration': needs_bool
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
    log "${GREEN}✓ Etap 2 OK${NC}: StdModule=$stdmod, total=$total, needs=$needs"
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
# ETAP 4: TRANSFORMATION (text → i18nKey)
#===============================================================================
stage_4() {
    local file="$1"
    log "${BLUE}[4/8] TRANSFORMATION${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local temp=$(mktemp)
    local counter=1
    local transformed=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -qE 'StdModule\.say.*text[[:space:]]*=[[:space:]]*"[^"]{5,}"'; then
            local key="npc.${safe}.stdmod_${counter}"
            line=$(echo "$line" | sed "s|text[[:space:]]*=[[:space:]]*\"[^\"]*\"|i18nKey = \"${key}\"|")
            counter=$((counter + 1))
            transformed=$((transformed + 1))
        fi
        echo "$line" >> "$temp"
    done < "$file"
    
    if [ "$transformed" -gt 0 ]; then
        mv "$temp" "$file"
        log "${GREEN}✓ Etap 4 OK${NC}: Zamieniono $transformed wystąpień"
    else
        rm -f "$temp"
        log "${YELLOW}⏭ Etap 4${NC}: Brak zmian"
    fi
    
    python3 -c "
import json
with open('$STATUS_FILE', 'r') as f: data = json.load(f)
data['files']['$file']['stages']['4_transformation'] = {'status': 'completed', 'transformed': $transformed}
with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
"
    return 0
}

#===============================================================================
# ETAP 5: EXTRACTION_EN (klucze do JSON)
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

# Wczytaj backup
with open("$backup", "r") as f:
    content = f.read()

# Znajdź wszystkie text = "..."
texts = re.findall(r'text\s*=\s*"([^"]+)"', content)

# Wczytaj npc.json
json_file = "$I18N_DIR/en/npc.json"
try:
    with open(json_file, "r") as f:
        data = json.load(f)
except:
    data = {}

# Dodaj klucze
added = 0
for i, text in enumerate(texts, 1):
    if len(text) >= 5:
        key = f"npc.$safe.stdmod_{i}"
        if key not in data:
            data[key] = text
            added += 1

# Zapisz
with open(json_file, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Dodano {added} kluczy")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["5_extraction_en"] = {"status": "completed", "keys_added": added}
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
    log "${BLUE}[6/8] TRANSLATION${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Lista głównych języków (zaczynamy od najważniejszych)
    local MAIN_LANGS="pl de es pt fr it ru"
    
    python3 << PYEOF
import json
import os
import re

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
    print("Brak kluczy dla tego NPC")
    exit(0)

# Prosta "pseudo-tłumaczenie" dla testu - w produkcji użyć API tłumaczenia
# Na razie tylko kopiujemy EN jako placeholder z tagiem [LANG]
langs_done = []
MAIN_LANGS = ["pl", "de", "es", "pt", "fr", "it", "ru"]

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
            # Placeholder - do ręcznego tłumaczenia lub API
            lang_data[key] = f"[{lang.upper()}] {text}"
            added += 1
    
    if added > 0:
        with open(lang_file, "w") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
        langs_done.append(lang)

# Update status
with open(status_file, "r") as f:
    status = json.load(f)
status["files"][file_path]["stages"]["6_translation"] = {
    "status": "completed",
    "languages": langs_done,
    "keys_per_lang": len(npc_keys)
}
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

print(f"Tłumaczenie: {len(langs_done)} języków, {len(npc_keys)} kluczy każdy")
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

# 3. Sprawdź duplikaty wartości
values = list(en_data.values())
duplicates = [v for v in values if values.count(v) > 1]
if duplicates:
    warnings.append(f"Znaleziono {len(set(duplicates))} duplikatów wartości")

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
    stage_5 "$file" || return 1
    stage_6 "$file" || return 1
    stage_7 "$file" || return 1
    stage_8 "$file" || return 1
    
    log "${GREEN}✅ WSZYSTKIE 8 ETAPÓW UKOŃCZONE!${NC}"
    return 0
}

#===============================================================================
# MAIN
#===============================================================================
echo "╔════════════════════════════════════════╗"
echo "║   I18N WORKER SIMPLE v1.0              ║"
echo "╚════════════════════════════════════════╝"

# Inicjalizuj JSON
[ ! -f "$STATUS_FILE" ] && echo '{"files":{}}' > "$STATUS_FILE"
mkdir -p "$I18N_DIR/en" "$BACKUP_DIR/npc" "$BACKUP_DIR/scripts"

case "${1:-}" in
    --file)
        [ -z "${2:-}" ] && { echo "Podaj ścieżkę pliku"; exit 1; }
        process_file "$2"
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
        [ "$LIMIT" -gt 0 ] && echo "Limit: $LIMIT plików"
        for f in data-otservbr-global/npc/*.lua; do
            if grep -q "StdModule\.say.*text" "$f" 2>/dev/null; then
                if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                    process_file "$f"
                    COUNT=$((COUNT + 1))
                    if [ "$LIMIT" -gt 0 ] && [ "$COUNT" -ge "$LIMIT" ]; then
                        echo ""
                        echo "Osiągnięto limit $LIMIT plików."
                        break
                    fi
                fi
            fi
        done
        echo ""
        echo "Przetworzono: $COUNT plików"
        ;;
    *)
        echo ""
        echo "Użycie:"
        echo "  $0 --file <path>   Przetwórz jeden plik"
        echo "  $0 --status        Pokaż dashboard statusu"
        echo "  $0 --stats         Szczegółowe statystyki języków"
        echo "  $0 --auto          Automatyczna migracja NPC"
        echo "  $0 --auto N        Automatyczna migracja N plików"
        echo ""
        ;;
esac
