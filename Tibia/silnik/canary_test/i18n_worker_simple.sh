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

with open('$STATUS_FILE', 'r') as f: data = json.load(f)

data['files']['$file']['stages']['2_analysis'] = {
    'status': 'completed',
    'safe_name': '$safe',
    'StdModule_say': $stdmod,
    'npcHandler_say': $npcsay,
    'sendTextMessage': $sendtxt,
    'total': $total,
    'already_i18n': $i18nkey,
    'needs_migration': "$needs" == "true"
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
    log "${GREEN}✓ Etap 2 OK${NC}: StdModule=$stdmod, total=$total, needs=$needs"
    [ "$needs" = "true" ] && return 0 || return 2
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
    
    stage_4 "$file" || return 1
    stage_5 "$file" || return 1
    
    log "${GREEN}✅ GOTOWE!${NC}"
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
        echo "Status plików:"
        python3 -c "
import json
with open('$STATUS_FILE') as f: d=json.load(f)
for path, info in d.get('files',{}).items():
    stages = list(info.get('stages',{}).keys())
    print(f'  {path}: {stages}')
print(f'Razem: {len(d.get(\"files\",{}))} plików')
"
        ;;
    --auto)
        echo "Tryb AUTO - szukam plików NPC do migracji..."
        for f in data-otservbr-global/npc/*.lua; do
            if grep -q "StdModule\.say.*text" "$f" 2>/dev/null; then
                if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                    process_file "$f"
                fi
            fi
        done
        ;;
    *)
        echo "Użycie:"
        echo "  $0 --file <path>   Przetwórz jeden plik"
        echo "  $0 --status        Pokaż status"
        echo "  $0 --auto          Automatyczna migracja NPC"
        ;;
esac
