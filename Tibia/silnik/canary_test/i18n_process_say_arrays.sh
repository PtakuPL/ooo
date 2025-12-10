#!/bin/bash
# Skrypt do konwersji npcHandler:say({...}) na NPC_LIB.i18n.npcSayMultiple
# Ten skrypt przetwarza tablice w npcHandler:say

set -e

I18N_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test/i18n"
EN_FILE="$I18N_DIR/en/npc.json"
LOG_FILE="/home/ptaku/serweryt/Tibia/silnik/canary_test/build/i18n/array_processing.log"

mkdir -p "$(dirname "$LOG_FILE")"

# Kolory
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"; }

# Backup pliku
backup_file() {
    local file="$1"
    local backup_dir="/home/ptaku/serweryt/Tibia/silnik/canary_test/backups/npc"
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
}

# Funkcja pomocnicza do uzyskania klucza bazowego z nazwy pliku
get_base_key() {
    local filepath="$1"
    local filename=$(basename "$filepath" .lua)
    echo "npc.${filename}"
}

# Znajdź najwyższy numer klucza dla danego NPC
find_max_key_number() {
    local base_key="$1"
    local max=0
    
    if [ -f "$EN_FILE" ]; then
        while IFS= read -r num; do
            if [ -n "$num" ] && [ "$num" -gt "$max" ]; then
                max="$num"
            fi
        done < <(grep -oP "\"${base_key}\.say_\K\d+" "$EN_FILE" 2>/dev/null)
    fi
    
    echo "$max"
}

# Przetwarza plik z tablicami
process_file_with_arrays() {
    local file="$1"
    local base_key=$(get_base_key "$file")
    local max_num=$(find_max_key_number "$base_key")
    local changes_made=0
    
    log "Przetwarzam: $file (base: $base_key, max_num: $max_num)"
    
    # Sprawdź czy plik ma tablice w npcHandler:say
    if ! grep -q "npcHandler:say({" "$file"; then
        log "  Brak tablic do przetworzenia"
        return 0
    fi
    
    # Backup
    backup_file "$file"
    
    # Użyj Pythona do przetworzenia tablic (bash nie radzi sobie z wieloliniowym parsowaniem)
    python3 << PYTHON_SCRIPT
import re
import json
import sys

file_path = "$file"
base_key = "$base_key"
en_file = "$EN_FILE"
max_num = int("$max_num") if "$max_num".isdigit() else 0

# Wczytaj plik
with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Wczytaj istniejące tłumaczenia
translations = {}
if en_file:
    try:
        with open(en_file, 'r', encoding='utf-8') as f:
            translations = json.load(f)
    except:
        pass

changes = 0
new_translations = {}

# Regex do znajdowania npcHandler:say z tablicą
# Format: npcHandler:say({ "msg1", "msg2", ... }, npc, creature, delay)
pattern = r'npcHandler:say\(\s*\{([^}]+)\}\s*,\s*npc\s*,\s*creature\s*,?\s*(\d+)?\s*\)'

def process_match(match):
    global max_num, changes, new_translations
    
    array_content = match.group(1)
    delay = match.group(2) if match.group(2) else "100"
    
    # Wyodrębnij stringi z tablicy (może być wieloliniowe)
    # Obsługuje zarówno "string" jak i tekst z \z
    string_pattern = r'"([^"\\]*(?:\\.[^"\\]*)*)"'
    strings = re.findall(string_pattern, array_content)
    
    if not strings:
        return match.group(0)  # Zwróć oryginał jeśli nie znaleziono stringów
    
    # Generuj klucze dla każdego stringa
    keys = []
    for s in strings:
        # Oczyść string (usuń \z, nadmiarowe spacje)
        cleaned = re.sub(r'\s*\\z\s*', ' ', s)
        cleaned = re.sub(r'\s+', ' ', cleaned).strip()
        
        if not cleaned:
            continue
            
        max_num += 1
        key = f"{base_key}.say_{max_num}"
        keys.append(key)
        new_translations[key] = cleaned
    
    if not keys:
        return match.group(0)
    
    changes += 1
    
    # Generuj nowy kod
    keys_str = ', '.join([f'"{k}"' for k in keys])
    return f'NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {{{keys_str}}}, {delay})'

# Zastąp wszystkie wystąpienia
new_content = re.sub(pattern, process_match, content, flags=re.DOTALL)

if changes > 0:
    # Zapisz zmodyfikowany plik
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    # Dodaj nowe tłumaczenia
    if new_translations:
        translations.update(new_translations)
        with open(en_file, 'w', encoding='utf-8') as f:
            json.dump(translations, f, ensure_ascii=False, indent=2, sort_keys=True)
    
    print(f"OK:{changes}:{len(new_translations)}")
else:
    print("NOCHANGE")

PYTHON_SCRIPT

}

# Główna pętla
main() {
    log "=== Rozpoczynam przetwarzanie tablic npcHandler:say ==="
    
    # Znajdź wszystkie pliki z tablicami
    local files=$(grep -l "npcHandler:say({" /home/ptaku/serweryt/Tibia/silnik/canary_test/data-otservbr-global/npc/*.lua 2>/dev/null)
    
    if [ -z "$files" ]; then
        log "Nie znaleziono plików z tablicami"
        exit 0
    fi
    
    local total_files=0
    local processed_files=0
    local total_arrays=0
    local total_keys=0
    
    for file in $files; do
        ((total_files++))
        result=$(process_file_with_arrays "$file")
        
        if [[ "$result" == OK:* ]]; then
            IFS=':' read -r _ arrays keys <<< "$result"
            log "  ${GREEN}✓${NC} Przekonwertowano $arrays tablic, dodano $keys kluczy"
            ((processed_files++))
            ((total_arrays += arrays))
            ((total_keys += keys))
        elif [[ "$result" == "NOCHANGE" ]]; then
            log "  ${YELLOW}○${NC} Brak zmian (tablice już przetworzone lub skomplikowane)"
        else
            log "  ${RED}✗${NC} Błąd: $result"
        fi
    done
    
    log ""
    log "=== Podsumowanie ==="
    log "Plików z tablicami: $total_files"
    log "Przetworzonych: $processed_files"
    log "Tablic przekonwertowanych: $total_arrays"
    log "Nowych kluczy i18n: $total_keys"
}

main "$@"
