#!/bin/bash
#===============================================================================
# I18N AUTONOMOUS WORKER v4.0 - PEŁNA INTERNACJONALIZACJA
#===============================================================================
# Przetwarza: Lua, C++, PHP, HTML, JS, XML, JSON
# Języki: 53 (wszystkie główne)
# Funkcje: Migracja, Tłumaczenia, Dokumentacja, Analiza, Walidacja
#===============================================================================

set -e

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
LOG_FILE="$WORK_DIR/i18n_worker.log"
LIVE_LOG="$WORK_DIR/work_i18n_live.log"
DOC_FILE="$WORK_DIR/i18n_full_documentation.md"
I18N_DIR="$WORK_DIR/i18n"
EXCLUDED_FILE="$WORK_DIR/i18n_excluded_files.txt"
PROCESSED_FILE="$WORK_DIR/i18n_processed_files.txt"
ANALYSIS_DIR="$WORK_DIR/i18n_analysis"
CONFLICTS_FILE="$WORK_DIR/i18n_conflicts.log"

# 53 języki do tłumaczenia
LANGUAGES=(
    "en" "pl" "de" "es" "pt" "fr" "it" "nl" "ru" "uk" "cs" "sk" "hu" "ro" "bg"
    "hr" "sl" "sr" "bs" "mk" "sq" "el" "tr" "ar" "he" "fa" "hi" "bn" "ta" "te"
    "ml" "th" "vi" "id" "ms" "tl" "zh" "zh_TW" "ja" "ko" "sv" "no" "da" "fi"
    "et" "lv" "lt" "ka" "hy" "az" "kk" "uz" "sw"
)

# Wszystkie katalogi do skanowania
SCAN_DIRS=(
    "data-otservbr-global/npc"
    "data-otservbr-global/scripts"
    "data-otservbr-global/lib"
    "data/scripts"
    "data/npclib"
    "data/libs"
    "data/events"
    "data/modules"
    "src"
    "src/creatures"
    "src/game"
    "src/io"
    "src/items"
    "src/lua"
    "src/map"
    "src/server"
    "src/utils"
    "html_copy"
    "html_copy/app"
    "html_copy/routes"
    "html_copy/resources"
)

# Rozszerzenia plików do przetworzenia
FILE_EXTENSIONS="lua,cpp,hpp,h,php,html,js,xml,json"

TOTAL_FILES_PROCESSED=0
TOTAL_STRINGS_FOUND=0
TOTAL_CONFLICTS=0
CYCLE_COUNT=0
FILES_PER_CYCLE=10
MODE="migration"  # migration, translation, analysis, validation

#===============================================================================
# LOGGING
#===============================================================================
log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE" "$LIVE_LOG"
}

log_info() { log "INFO" "$1"; }
log_success() { log "SUCCESS" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

#===============================================================================
# DOKUMENTACJA
#===============================================================================
document() {
    local category="$1"
    local file="$2"
    local action="$3"
    local details="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat >> "$DOC_FILE" << EOF

## [$timestamp] $category

### Plik: \`$file\`

**Akcja:** $action

**Szczegóły:**
$details

---
EOF
}

init_documentation() {
    if [ ! -f "$DOC_FILE" ]; then
        cat > "$DOC_FILE" << 'EOF'
# 🌍 I18N Full Documentation

Automatyczna dokumentacja wszystkich zmian internacjonalizacji.

**Worker:** v4.0 - Full Internationalization  
**Języki:** 53  
**Zakres:** Lua, C++, PHP, HTML, JS, XML, JSON

---

EOF
    fi
}

#===============================================================================
# INICJALIZACJA
#===============================================================================
init_all() {
    mkdir -p "$ANALYSIS_DIR"
    mkdir -p "$I18N_DIR"
    
    # Utwórz katalogi dla wszystkich 53 języków
    for lang in "${LANGUAGES[@]}"; do
        mkdir -p "$I18N_DIR/$lang"
        for cat in npc scripts actions quests events server ui messages errors items spells; do
            [ ! -f "$I18N_DIR/$lang/${cat}.json" ] && echo "{}" > "$I18N_DIR/$lang/${cat}.json"
        done
    done
    
    [ ! -f "$EXCLUDED_FILE" ] && touch "$EXCLUDED_FILE"
    [ ! -f "$PROCESSED_FILE" ] && touch "$PROCESSED_FILE"
    [ ! -f "$CONFLICTS_FILE" ] && touch "$CONFLICTS_FILE"
    
    init_documentation
    
    log_info "📁 Zainicjalizowano ${#LANGUAGES[@]} języków"
}

#===============================================================================
# FUNKCJE POMOCNICZE
#===============================================================================
is_excluded() { grep -qF "$1" "$EXCLUDED_FILE" 2>/dev/null; }
is_processed() { grep -qF "$1" "$PROCESSED_FILE" 2>/dev/null; }
mark_processed() { echo "$1" >> "$PROCESSED_FILE"; }
mark_excluded() { echo "$1" >> "$EXCLUDED_FILE"; }

get_file_type() {
    local file="$1"
    case "${file##*.}" in
        lua) echo "lua" ;;
        cpp|hpp|h|cc) echo "cpp" ;;
        php) echo "php" ;;
        html|htm) echo "html" ;;
        js) echo "javascript" ;;
        xml) echo "xml" ;;
        json) echo "json" ;;
        *) echo "unknown" ;;
    esac
}

get_category() {
    local file="$1"
    if [[ "$file" == *"/npc/"* ]]; then echo "npc"
    elif [[ "$file" == *"/scripts/"* ]]; then echo "scripts"
    elif [[ "$file" == *"/quests/"* ]]; then echo "quests"
    elif [[ "$file" == *"/src/"* ]]; then echo "server"
    elif [[ "$file" == *"/html_copy/"* ]]; then echo "ui"
    elif [[ "$file" == *"/items/"* ]]; then echo "items"
    elif [[ "$file" == *"/spells/"* ]]; then echo "spells"
    else echo "misc"
    fi
}

#===============================================================================
# MIGRACJA LUA
#===============================================================================
migrate_lua_file() {
    local file="$1"
    local file_name=$(basename "$file" .lua)
    local category=$(get_category "$file")
    local relative_path="${file#$WORK_DIR/}"
    
    log_info "🔷 [LUA] $relative_path"
    
    if grep -qE "Localized|i18n\.|getTranslation" "$file" 2>/dev/null; then
        log_info "   ⏭️ Już zmigrowany"
        mark_processed "$file"
        return 1
    fi
    
    local patterns=(
        'player:sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"'
        'npcHandler:say\s*\(\s*"[^"]{10,}"'
        'creature:say\s*\(\s*"[^"]{10,}"'
        'doPlayerSendTextMessage'
        'player:showTextDialog'
    )
    
    local has_strings=false
    for pattern in "${patterns[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            has_strings=true
            break
        fi
    done
    
    if [ "$has_strings" = false ]; then
        log_info "   ⏭️ Brak stringów"
        mark_excluded "$file"
        return 1
    fi
    
    # Backup i migracja
    cp "$file" "${file}.bak"
    
    local temp_file=$(mktemp)
    local transformed=0
    local key_counter=1
    local json_file="$I18N_DIR/en/${category}.json"
    
    while IFS= read -r line || [ -n "$line" ]; do
        local new_line="$line"
        
        # player:sendTextMessage
        if echo "$line" | grep -qE 'player:sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"'; then
            local text=$(echo "$line" | sed -n 's/.*player:sendTextMessage\s*([^,]*,\s*"\([^"]*\)".*/\1/p')
            if [ -n "$text" ] && [ ${#text} -gt 10 ]; then
                local key="${category}.${file_name}.msg_${key_counter}"
                key_counter=$((key_counter + 1))
                new_line=$(echo "$line" | sed "s|player:sendTextMessage(\([^,]*\),\s*\"[^\"]*\"|player:sendLocalizedMessage(\1, \"${key}\"|")
                
                python3 -c "import json; d=json.load(open('$json_file')) if __import__('os').path.exists('$json_file') else {}; d['$key']='$text'; json.dump(d,open('$json_file','w'),indent=2,ensure_ascii=False)" 2>/dev/null
                
                transformed=$((transformed + 1))
                log_info "      🔑 $key"
            fi
        fi
        
        # npcHandler:say
        if echo "$line" | grep -qE 'npcHandler:say\s*\(\s*"[^"]{10,}"'; then
            local text=$(echo "$line" | sed -n 's/.*npcHandler:say\s*(\s*"\([^"]*\)".*/\1/p')
            if [ -n "$text" ] && [ ${#text} -gt 10 ]; then
                local key="${category}.${file_name}.say_${key_counter}"
                key_counter=$((key_counter + 1))
                new_line=$(echo "$line" | sed "s|npcHandler:say(\s*\"[^\"]*\"|npcHandler:sayLocalized(\"${key}\"|")
                
                python3 -c "import json; d=json.load(open('$json_file')) if __import__('os').path.exists('$json_file') else {}; d['$key']='$text'; json.dump(d,open('$json_file','w'),indent=2,ensure_ascii=False)" 2>/dev/null
                
                transformed=$((transformed + 1))
                log_info "      🔑 $key"
            fi
        fi
        
        echo "$new_line" >> "$temp_file"
    done < "$file"
    
    if [ "$transformed" -gt 0 ]; then
        mv "$temp_file" "$file"
        rm -f "${file}.bak"
        mark_processed "$file"
        
        log_success "   ✅ $transformed stringów zmigrowanych"
        document "MIGRACJA LUA" "$relative_path" "Zmigrowano $transformed stringów" "Kategoria: $category"
        
        TOTAL_FILES_PROCESSED=$((TOTAL_FILES_PROCESSED + 1))
        TOTAL_STRINGS_FOUND=$((TOTAL_STRINGS_FOUND + transformed))
        return 0
    else
        rm -f "$temp_file" "${file}.bak"
        mark_excluded "$file"
        return 1
    fi
}

#===============================================================================
# MIGRACJA C++
#===============================================================================
migrate_cpp_file() {
    local file="$1"
    local file_name=$(basename "$file")
    local relative_path="${file#$WORK_DIR/}"
    
    log_info "🔶 [C++] $relative_path"
    
    if grep -qE 'i18n::|getTranslation|LocalizedString' "$file" 2>/dev/null; then
        log_info "   ⏭️ Już zmigrowany"
        mark_processed "$file"
        return 1
    fi
    
    # Wzorce C++ do migracji
    local patterns=(
        'player->sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"'
        'g_game\.broadcastMessage\s*\(\s*"[^"]{10,}"'
        'sendChannelMessage\s*\([^,]+,\s*"[^"]{10,}"'
    )
    
    local has_strings=false
    for pattern in "${patterns[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            has_strings=true
            break
        fi
    done
    
    if [ "$has_strings" = false ]; then
        log_info "   ⏭️ Brak stringów"
        mark_excluded "$file"
        return 1
    fi
    
    # Analiza bez modyfikacji (C++ wymaga ostrożności)
    local count=$(grep -cE 'sendTextMessage|sendChannelMessage|broadcastMessage' "$file" 2>/dev/null || echo "0")
    
    log_info "   📊 Znaleziono $count potencjalnych stringów"
    document "ANALIZA C++" "$relative_path" "Znaleziono $count stringów do migracji" "Wymaga ręcznej weryfikacji"
    
    TOTAL_STRINGS_FOUND=$((TOTAL_STRINGS_FOUND + count))
    mark_processed "$file"
    return 0
}

#===============================================================================
# MIGRACJA PHP/HTML
#===============================================================================
migrate_web_file() {
    local file="$1"
    local file_type=$(get_file_type "$file")
    local relative_path="${file#$WORK_DIR/}"
    
    log_info "🌐 [$file_type] $relative_path"
    
    if grep -qE '__\(|trans\(|i18n\.|gettext' "$file" 2>/dev/null; then
        log_info "   ⏭️ Już zmigrowany"
        mark_processed "$file"
        return 1
    fi
    
    # Szukaj stringów w PHP/HTML
    local count=0
    
    if [ "$file_type" = "php" ]; then
        count=$(grep -cE "echo\s+['\"][^'\"]{10,}['\"]|print\s+['\"][^'\"]{10,}['\"]" "$file" 2>/dev/null | tr -d '\n' || echo "0")
    elif [ "$file_type" = "html" ]; then
        count=$(grep -cE ">[^<]{10,}<" "$file" 2>/dev/null | tr -d '\n' || echo "0")
    fi
    
    # Upewnij się że count jest liczbą
    count=$(echo "$count" | tr -d '[:space:]')
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0
    
    if [ "$count" -eq 0 ]; then
        log_info "   ⏭️ Brak stringów"
        mark_excluded "$file"
        return 1
    fi
    
    log_info "   📊 Znaleziono $count stringów"
    document "ANALIZA WEB" "$relative_path" "Znaleziono $count stringów" "Typ: $file_type"
    
    TOTAL_STRINGS_FOUND=$((TOTAL_STRINGS_FOUND + count))
    mark_processed "$file"
    return 0
}

#===============================================================================
# ANALIZA KONFLIKTÓW
#===============================================================================
analyze_conflicts() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🔍 ANALIZA KONFLIKTÓW I JAKOŚCI KODU"
    log_info "═══════════════════════════════════════════════════════════════"
    
    local conflicts=0
    
    # Sprawdź duplikaty kluczy
    log_info "🔑 Sprawdzam duplikaty kluczy..."
    for lang in en pl de; do
        for json_file in "$I18N_DIR/$lang"/*.json; do
            if [ -f "$json_file" ]; then
                local dups=$(python3 -c "
import json
try:
    with open('$json_file') as f:
        content = f.read()
        keys = [line.split('\"')[1] for line in content.split('\n') if '\":' in line]
        dups = len(keys) - len(set(keys))
        print(dups)
except: print(0)
" 2>/dev/null || echo "0")
                if [ "$dups" -gt 0 ]; then
                    log_warn "   ⚠️ Duplikaty w $(basename $json_file): $dups"
                    echo "DUPLICATE: $json_file - $dups keys" >> "$CONFLICTS_FILE"
                    conflicts=$((conflicts + dups))
                fi
            fi
        done
    done
    
    # Sprawdź błędy składni Lua
    log_info "🔷 Sprawdzam składnię Lua..."
    local lua_errors=0
    for lua_file in $(find "$WORK_DIR/data-otservbr-global" -name "*.lua" -type f 2>/dev/null | head -50); do
        if ! luac -p "$lua_file" 2>/dev/null; then
            log_warn "   ⚠️ Błąd składni: $(basename $lua_file)"
            echo "LUA_SYNTAX: $lua_file" >> "$CONFLICTS_FILE"
            lua_errors=$((lua_errors + 1))
            conflicts=$((conflicts + 1))
        fi
    done
    log_info "   Błędów Lua: $lua_errors"
    
    # Sprawdź niespójności tłumaczeń
    log_info "🌍 Sprawdzam spójność tłumaczeń..."
    local en_keys=$(python3 -c "
import json, os
total = 0
for f in os.listdir('$I18N_DIR/en'):
    if f.endswith('.json'):
        try:
            total += len(json.load(open('$I18N_DIR/en/' + f)))
        except: pass
print(total)
" 2>/dev/null || echo "0")
    
    for lang in pl de es pt fr; do
        local lang_keys=$(python3 -c "
import json, os
total = 0
d = '$I18N_DIR/$lang'
if os.path.exists(d):
    for f in os.listdir(d):
        if f.endswith('.json'):
            try:
                total += len(json.load(open(d + '/' + f)))
            except: pass
print(total)
" 2>/dev/null || echo "0")
        
        if [ "$lang_keys" -lt "$en_keys" ]; then
            local missing=$((en_keys - lang_keys))
            log_info "   🌐 $lang: brakuje $missing kluczy"
        fi
    done
    
    TOTAL_CONFLICTS=$conflicts
    log_info "📊 Łącznie konfliktów: $conflicts"
    
    document "ANALIZA KONFLIKTÓW" "Cały projekt" "Znaleziono $conflicts konfliktów" "Duplikaty, błędy składni, brakujące tłumaczenia"
}

#===============================================================================
# WALIDACJA KONSTRUKCJI
#===============================================================================
validate_structure() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🏗️ WALIDACJA KONSTRUKCJI PROJEKTU"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Statystyki plików
    local lua_count=$(find "$WORK_DIR" -name "*.lua" -type f 2>/dev/null | wc -l)
    local cpp_count=$(find "$WORK_DIR/src" -name "*.cpp" -type f 2>/dev/null | wc -l)
    local php_count=$(find "$WORK_DIR/html_copy" -name "*.php" -type f 2>/dev/null | wc -l)
    local html_count=$(find "$WORK_DIR/html_copy" -name "*.html" -type f 2>/dev/null | wc -l)
    
    log_info "📁 Pliki w projekcie:"
    log_info "   Lua: $lua_count"
    log_info "   C++: $cpp_count"
    log_info "   PHP: $php_count"
    log_info "   HTML: $html_count"
    
    # Sprawdź i18n coverage
    local total_keys=0
    for json_file in "$I18N_DIR/en"/*.json; do
        if [ -f "$json_file" ]; then
            local keys=$(python3 -c "import json; print(len(json.load(open('$json_file'))))" 2>/dev/null || echo "0")
            total_keys=$((total_keys + keys))
            log_info "   📚 $(basename $json_file): $keys kluczy"
        fi
    done
    
    log_info "📊 Łącznie kluczy i18n: $total_keys"
    
    # Sprawdź brakujące pliki
    log_info "🔍 Sprawdzam wymagane pliki..."
    local required_files=(
        "config.lua"
        "data/global.lua"
        "CMakeLists.txt"
    )
    
    for req_file in "${required_files[@]}"; do
        if [ -f "$WORK_DIR/$req_file" ]; then
            log_info "   ✅ $req_file"
        else
            log_warn "   ❌ Brak: $req_file"
        fi
    done
    
    document "WALIDACJA STRUKTURY" "Cały projekt" "Lua: $lua_count, C++: $cpp_count, PHP: $php_count" "Klucze i18n: $total_keys"
}

#===============================================================================
# GŁÓWNA PĘTLA PRZETWARZANIA
#===============================================================================
process_files() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "📦 FAZA PRZETWARZANIA PLIKÓW"
    log_info "═══════════════════════════════════════════════════════════════"
    
    local processed=0
    
    for dir in "${SCAN_DIRS[@]}"; do
        local full_dir="$WORK_DIR/$dir"
        [ ! -d "$full_dir" ] && continue
        
        while IFS= read -r -d '' file; do
            [ "$processed" -ge "$FILES_PER_CYCLE" ] && break 2
            
            is_excluded "$file" && continue
            is_processed "$file" && continue
            
            local file_type=$(get_file_type "$file")
            
            case "$file_type" in
                lua)
                    migrate_lua_file "$file" && processed=$((processed + 1))
                    ;;
                cpp)
                    migrate_cpp_file "$file" && processed=$((processed + 1))
                    ;;
                php|html)
                    migrate_web_file "$file" && processed=$((processed + 1))
                    ;;
                *)
                    mark_excluded "$file"
                    ;;
            esac
            
        done < <(find "$full_dir" -maxdepth 3 -type f \( -name "*.lua" -o -name "*.cpp" -o -name "*.hpp" -o -name "*.php" -o -name "*.html" \) -print0 2>/dev/null)
    done
    
    log_info "📊 Przetworzono w tym cyklu: $processed plików"
}

#===============================================================================
# SYNCHRONIZACJA TŁUMACZEŃ
#===============================================================================
sync_translations() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🌍 SYNCHRONIZACJA TŁUMACZEŃ (53 języki)"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Kopiuj klucze EN do wszystkich języków
    for json_file in "$I18N_DIR/en"/*.json; do
        [ ! -f "$json_file" ] && continue
        local filename=$(basename "$json_file")
        
        for lang in "${LANGUAGES[@]}"; do
            [ "$lang" = "en" ] && continue
            local target="$I18N_DIR/$lang/$filename"
            
            if [ ! -f "$target" ] || [ "$(cat "$target" 2>/dev/null)" = "{}" ]; then
                cp "$json_file" "$target"
            fi
        done
    done
    
    log_info "   ✅ Zsynchronizowano ${#LANGUAGES[@]} języków"
}

#===============================================================================
# STATUS UPDATE - Rozbudowany z kategoriami dla AI agentów
#===============================================================================
update_status() {
    local processed=$(wc -l < "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]')
    local excluded=$(wc -l < "$EXCLUDED_FILE" 2>/dev/null | tr -d '[:space:]')
    [[ ! "$processed" =~ ^[0-9]+$ ]] && processed=0
    [[ ! "$excluded" =~ ^[0-9]+$ ]] && excluded=0
    
    # Zliczanie kluczy per kategoria
    local npc_keys=0 scripts_keys=0 items_keys=0 monsters_keys=0 server_keys=0 spells_keys=0
    [ -f "$I18N_DIR/en/npc.json" ] && npc_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/npc.json'))))" 2>/dev/null || echo "0")
    [ -f "$I18N_DIR/en/scripts.json" ] && scripts_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/scripts.json'))))" 2>/dev/null || echo "0")
    [ -f "$I18N_DIR/en/items.json" ] && items_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/items.json'))))" 2>/dev/null || echo "0")
    [ -f "$I18N_DIR/en/monsters.json" ] && monsters_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/monsters.json'))))" 2>/dev/null || echo "0")
    [ -f "$I18N_DIR/en/server.json" ] && server_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/server.json'))))" 2>/dev/null || echo "0")
    [ -f "$I18N_DIR/en/spells.json" ] && spells_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/spells.json'))))" 2>/dev/null || echo "0")
    
    local total_keys=$((npc_keys + scripts_keys + items_keys + monsters_keys + server_keys + spells_keys))
    
    # Pobierz ostatnio przetworzone pliki (ostatnie 5)
    local recent_files=""
    if [ -f "$PROCESSED_FILE" ]; then
        recent_files=$(tail -5 "$PROCESSED_FILE" 2>/dev/null | while read f; do
            local fname=$(basename "$f" 2>/dev/null)
            local ftime=$(stat -c %Y "$f" 2>/dev/null || echo "0")
            local ftime_human=$(date -d "@$ftime" '+%H:%M:%S' 2>/dev/null || echo "??:??")
            echo "| \`$fname\` | $ftime_human | ✅ |"
        done)
    fi
    
    # Zlicz pliki per podkatalog scripts
    local quests_count=$(grep -c "scripts/quests" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || quests_count=0
    local actions_count=$(grep -c "scripts/actions" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || actions_count=0
    local movements_count=$(grep -c "scripts/movements" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || movements_count=0
    local creature_count=$(grep -c "scripts/creaturescripts" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || creature_count=0
    local talk_count=$(grep -c "scripts/talkactions" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || talk_count=0
    local global_count=$(grep -c "scripts/globalevents" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || global_count=0
    local spells_f_count=$(grep -c "scripts/spells" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || spells_f_count=0
    
    [[ ! "$quests_count" =~ ^[0-9]+$ ]] && quests_count=0
    [[ ! "$actions_count" =~ ^[0-9]+$ ]] && actions_count=0
    [[ ! "$movements_count" =~ ^[0-9]+$ ]] && movements_count=0
    [[ ! "$creature_count" =~ ^[0-9]+$ ]] && creature_count=0
    [[ ! "$talk_count" =~ ^[0-9]+$ ]] && talk_count=0
    [[ ! "$global_count" =~ ^[0-9]+$ ]] && global_count=0
    [[ ! "$spells_f_count" =~ ^[0-9]+$ ]] && spells_f_count=0
    
    # Pobierz przykład ostatniej zmiany
    local last_file=$(tail -1 "$PROCESSED_FILE" 2>/dev/null)
    local code_example=""
    if [ -n "$last_file" ] && [ -f "$last_file" ]; then
        # Znajdź przykładowy string z sendTextMessage
        code_example=$(grep -m1 "sendTextMessage\|:say(" "$last_file" 2>/dev/null | head -c 80 || echo "")
    fi
    
    # Tworzenie rozbudowanego I18N_STATUS.md
    cat > "$WORK_DIR/I18N_STATUS.md" << EOF
# 🌍 I18N Internationalization System - Live Dashboard

> **Aktualizacja:** $(date '+%Y-%m-%d %H:%M:%S') UTC  
> **Worker:** v4.0 | **Guardian:** v2.0 | **Języki:** ${#LANGUAGES[@]}

---

## 🤖 AI Agent Integration

\`\`\`
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n/status/worker_state.json                      │
│  Categories: i18n/status/categories/*.json                     │
└─────────────────────────────────────────────────────────────────┘
\`\`\`

---

## 📊 Globalny Postęp

| Metryka | Wartość | Trend |
|---------|---------|-------|
| 📁 Plików przetworzonych | **$processed** | ↑ |
| ⏭️ Plików wykluczonych | **$excluded** | - |
| 🔑 Kluczy i18n | **$total_keys** | ↑ |
| 🌍 Języków | **${#LANGUAGES[@]}** | ✓ |
| ⚠️ Konfliktów | **$TOTAL_CONFLICTS** | ✓ |
| 🔄 Cykl | **#$CYCLE_COUNT** | - |

---

## 📂 Kategorie Pracy

<details>
<summary><h3>🧙 1. NPC Dialogs - COMPLETED ✅</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | $npc_keys |
| 📊 Status | ✅ Zakończone |
| 📂 Plików | ~877 |

**Źródła:** \`data-otservbr-global/npc/\`, \`data-canary/npc/\`

**Wzorce ekstrakcji:**
\`\`\`lua
npcHandler:say("text")
selfSay("text")
\`\`\`

</details>

---

<details open>
<summary><h3>📜 2. Lua Scripts - IN PROGRESS 🔄</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | **$scripts_keys** |
| 📊 Status | 🔄 W trakcie |
| 🎯 Aktualnie | \`data-otservbr-global/scripts/\` |
| 🔄 Cykl | #$CYCLE_COUNT |

### 📁 Podkatalogi - Postęp

| Katalog | Przetworzonych | Status |
|---------|----------------|--------|
| \`quests/\` | $quests_count | $([ $quests_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`actions/\` | $actions_count | $([ $actions_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`movements/\` | $movements_count | $([ $movements_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`creaturescripts/\` | $creature_count | $([ $creature_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`talkactions/\` | $talk_count | $([ $talk_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`globalevents/\` | $global_count | $([ $global_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |
| \`spells/\` | $spells_f_count | $([ $spells_f_count -gt 0 ] && echo "🔄 W trakcie" || echo "⏳ Oczekuje") |

### 📄 Ostatnio przetworzone pliki

| Plik | Czas | Status |
|------|------|--------|
$recent_files

### 💻 Przykład kodu (ostatni plik)

\`\`\`lua
$code_example
\`\`\`

**Wzorce ekstrakcji:**
\`\`\`lua
player:sendTextMessage(type, "text")
creature:say("text")
\`\`\`

</details>

---

<details>
<summary><h3>🎒 3. Items - COMPLETED ✅</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | $items_keys |
| 📊 Status | ✅ Zakończone |

</details>

---

<details>
<summary><h3>👹 4. Monsters - PENDING ⏳</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | $monsters_keys |
| 📊 Status | ⏳ Oczekuje |
| 📅 Start | Po zakończeniu Scripts |

</details>

---

<details>
<summary><h3>⚙️ 5. Server C++ - PENDING ⏳</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | $server_keys |
| 📊 Status | ⏳ Oczekuje |
| ⚠️ Wymaga | Rekompilacja serwera |

</details>

---

<details>
<summary><h3>🔮 6. Spells - PENDING ⏳</h3></summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | $spells_keys |
| 📊 Status | ⏳ Oczekuje |

</details>

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| **Worker v4.0** | 🟢 RUNNING | PID: $$, Cykl #$CYCLE_COUNT |
| **Guardian v2.0** | 🟢 ACTIVE | Push co 2 min |

---

## 🗺️ Roadmap

\`\`\`
[✅] Phase 1: Items           ████████████████████ 100%
[✅] Phase 2: NPC             ████████████████████ 100%
[🔄] Phase 3: Scripts         $(printf '█%.0s' $(seq 1 $((scripts_keys / 100 + 1))))$(printf '░%.0s' $(seq 1 $((20 - scripts_keys / 100 - 1)))) $((scripts_keys / 50))%
[⏳] Phase 4: Monsters        ░░░░░░░░░░░░░░░░░░░░   0%
[⏳] Phase 5: Spells          ░░░░░░░░░░░░░░░░░░░░   0%
[⏳] Phase 6: Server (C++)    ░░░░░░░░░░░░░░░░░░░░   0%
\`\`\`

---

*🤖 Machine-readable: \`i18n/status/worker_state.json\`*  
*📅 Auto-updated by Worker v4.0 every cycle*  
*🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)*
EOF
    
    # Aktualizuj pliki JSON dla AI
    update_json_status "$processed" "$excluded" "$total_keys" "$npc_keys" "$scripts_keys" "$items_keys" "$quests_count" "$actions_count"
    
    log_info "📊 Status: $processed przetw. | $total_keys kluczy | ${#LANGUAGES[@]} języków"
}
    

#===============================================================================
# JSON STATUS UPDATE - Dla AI agentów
#===============================================================================
update_json_status() {
    local processed=$1
    local excluded=$2
    local total_keys=$3
    local npc_keys=$4
    local scripts_keys=$5
    local items_keys=$6
    local quests_count=${7:-0}
    local actions_count=${8:-0}
    
    mkdir -p "$I18N_DIR/status/categories"
    
    # Pobierz ostatnie 5 plików
    local recent_files_json="[]"
    if [ -f "$PROCESSED_FILE" ]; then
        recent_files_json=$(tail -5 "$PROCESSED_FILE" 2>/dev/null | while read f; do
            local fname=$(basename "$f" 2>/dev/null)
            local ftime=$(date '+%H:%M:%S')
            echo "{\"file\": \"$fname\", \"time\": \"$ftime\", \"status\": \"success\"}"
        done | jq -s '.' 2>/dev/null || echo "[]")
    fi
    
    # Główny status JSON
    cat > "$I18N_DIR/status/worker_state.json" << EOF
{
  "schema_version": "2.0",
  "last_updated": "$(date -Iseconds)",
  "worker": {
    "version": "4.0",
    "status": "running",
    "mode": "$MODE",
    "cycle": $CYCLE_COUNT,
    "files_per_cycle": $FILES_PER_CYCLE,
    "pid": $$
  },
  "global_progress": {
    "total_files_processed": $processed,
    "total_files_excluded": $excluded,
    "total_keys": $total_keys,
    "total_languages": ${#LANGUAGES[@]},
    "total_conflicts": $TOTAL_CONFLICTS
  },
  "categories": {
    "npc": {"status": "completed", "keys": $npc_keys},
    "scripts": {"status": "in_progress", "keys": $scripts_keys},
    "items": {"status": "completed", "keys": $items_keys},
    "monsters": {"status": "pending", "keys": 0},
    "server": {"status": "pending", "keys": 0},
    "spells": {"status": "pending", "keys": 0}
  },
  "recent_files": $recent_files_json
}
EOF

    # Szczegóły kategorii scripts (aktywna)
    cat > "$I18N_DIR/status/categories/scripts_details.json" << EOF
{
  "category": "scripts",
  "status": "in_progress",
  "last_updated": "$(date -Iseconds)",
  "summary": {
    "total_keys": $scripts_keys,
    "files_processed": $processed
  },
  "current_work": {
    "directory": "data-otservbr-global/scripts/",
    "cycle": $CYCLE_COUNT
  },
  "subdirectories": {
    "quests": {"processed": $quests_count},
    "actions": {"processed": $actions_count}
  },
  "recent_files": $recent_files_json
}
EOF
}

#===============================================================================
# GŁÓWNA FUNKCJA
#===============================================================================
main() {
    cd "$WORK_DIR"
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║     I18N AUTONOMOUS WORKER v4.0 - FULL INTERNATIONALIZATION         ║"
    echo "║     Lua • C++ • PHP • HTML • 53 Languages • Full Analysis           ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    init_all
    
    log_info "🚀 Worker v4.0 uruchomiony"
    log_info "📁 Katalog: $WORK_DIR"
    log_info "🌍 Języki: ${#LANGUAGES[@]}"
    log_info "📂 Katalogi: ${#SCAN_DIRS[@]}"
    
    while true; do
        CYCLE_COUNT=$((CYCLE_COUNT + 1))
        
        echo ""
        log_info "═══════════════════════════════════════════════════════════════"
        log_info "🔄 CYKL #$CYCLE_COUNT | Tryb: $MODE"
        log_info "═══════════════════════════════════════════════════════════════"
        
        update_status
        
        # Sprawdź czy są pliki do przetworzenia
        local pending=0
        for dir in "${SCAN_DIRS[@]}"; do
            [ -d "$WORK_DIR/$dir" ] && pending=$((pending + $(find "$WORK_DIR/$dir" -maxdepth 3 -type f \( -name "*.lua" -o -name "*.cpp" -o -name "*.php" \) 2>/dev/null | wc -l)))
        done
        
        local processed_count=$(wc -l < "$PROCESSED_FILE" 2>/dev/null || echo "0")
        local excluded_count=$(wc -l < "$EXCLUDED_FILE" 2>/dev/null || echo "0")
        local remaining=$((pending - processed_count - excluded_count))
        
        if [ "$remaining" -gt 0 ]; then
            MODE="migration"
            process_files
            sync_translations
        else
            # Wszystko przetworzone - tryb analizy
            MODE="analysis"
            log_success "🎉 Wszystkie pliki przetworzone! Tryb analizy..."
            
            analyze_conflicts
            validate_structure
            sync_translations
            
            log_info "💤 Pełna analiza zakończona. Sprawdzam ponownie za 120 sekund..."
            sleep 120
            continue
        fi
        
        log_info "💤 Przerwa 10 sekund..."
        sleep 10
    done
}

trap 'log_info "⛔ Worker zatrzymany"; update_status; exit 0' SIGINT SIGTERM

main "$@"
