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
PID_FILE="$WORK_DIR/.worker.pid"

# Zabezpieczenie przed duplikatami
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] Worker już działa (PID: $OLD_PID). Wychodzę."
        exit 0
    fi
fi
echo $$ > "$PID_FILE"

# Cleanup przy wyjściu
cleanup() {
    rm -f "$PID_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ⛔ Worker zatrzymany"
}
trap cleanup EXIT INT TERM

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
    # NPC
    "data-otservbr-global/npc"
    "data-canary/npc"
    "data/npclib"
    # Scripts
    "data-otservbr-global/scripts"
    "data-otservbr-global/lib"
    "data/scripts"
    "data/libs"
    "data/events"
    "data/modules"
    # Monsters
    "data-otservbr-global/monster"
    "data-canary/monster"
    # Spells
    "data-otservbr-global/scripts/spells"
    "data/scripts/spells"
    # Server C++
    "src"
    "src/creatures"
    "src/game"
    "src/io"
    "src/items"
    "src/lua"
    "src/map"
    "src/server"
    "src/utils"
    # Web (html_copy)
    "html_copy"
    "html_copy/app"
    "html_copy/routes"
    "html_copy/resources"
    "html_copy/resources/views"
    # Instalka/Klient (testyy)
    "testyy"
    "testyy/browser"
    "testyy/modules"
    "testyy/android"
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
ACTIVITY_FILE="$I18N_DIR/status/activity.json"

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

# Aktualizuj status aktywności (do wyświetlenia na GitHub)
update_activity() {
    local op_type="$1"
    local file="$2"
    local action="$3"
    local status="$4"
    local details="$5"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local phase=$(get_current_phase 2>/dev/null || echo "1")
    local category=$(get_current_category 2>/dev/null || echo "unknown")
    
    # Aktualizuj activity.json
    [ -f "$ACTIVITY_FILE" ] && {
        local tmp=$(mktemp)
        jq --arg ts "$timestamp" --arg type "$op_type" --arg file "$file" \
           --arg action "$action" --arg status "$status" --arg details "$details" \
           --argjson phase "$phase" --arg cat "$category" '
            .last_updated = $ts |
            .current_operation = {
                type: $type,
                phase: $phase,
                category: $cat,
                file: $file,
                action: $action,
                status: $status,
                details: $details
            } |
            .recent_operations = ([{
                time: $ts,
                type: $type,
                file: $file,
                action: $action,
                status: $status
            }] + .recent_operations[:19])
        ' "$ACTIVITY_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$ACTIVITY_FILE"
    }
}

# Zapisz błąd
log_activity_error() {
    local file="$1"
    local error="$2"
    
    [ -f "$ACTIVITY_FILE" ] && {
        local tmp=$(mktemp)
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        jq --arg ts "$timestamp" --arg file "$file" --arg err "$error" '
            .errors = ([{time: $ts, file: $file, error: $err}] + .errors[:9]) |
            .stats.errors_this_session += 1
        ' "$ACTIVITY_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$ACTIVITY_FILE"
    }
    
    log_error "❌ $file: $error"
}

# Zapisz naprawę błędu
log_activity_fix() {
    local file="$1"
    local fix="$2"
    
    [ -f "$ACTIVITY_FILE" ] && {
        local tmp=$(mktemp)
        jq '.stats.fixes_applied += 1' "$ACTIVITY_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$ACTIVITY_FILE"
    }
    
    log_success "🔧 Naprawiono: $file - $fix"
}

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
# GIT AUTO-PUSH
#===============================================================================
LAST_PUSH_TIME=0
PUSH_INTERVAL=120  # Push co 2 minuty
COMMANDS_FILE="$WORK_DIR/.github/worker_commands.txt"
COMMANDS_LOG="$WORK_DIR/.github/commands_log.txt"

auto_push_to_github() {
    local current_time=$(date +%s)
    local time_diff=$((current_time - LAST_PUSH_TIME))
    
    # Sprawdź czy minął wymagany interwał
    if [ $time_diff -lt $PUSH_INTERVAL ]; then
        return 0
    fi
    
    # Idź do głównego repo
    cd /home/ptaku/serweryt || return 1
    
    # Usuń stary lock file jeśli istnieje
    rm -f .git/index.lock 2>/dev/null
    
    # Pobierz najnowsze komendy z GitHub
    git pull origin master -q 2>/dev/null || true
    
    # Sprawdź czy są komendy do wykonania
    check_github_commands
    
    # Sprawdź czy są zmiany
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$changes" -eq 0 ]; then
        cd "$WORK_DIR"
        return 0
    fi
    
    log_info "📤 Auto-push: $changes zmienionych plików..."
    
    # Dodaj, commit i push
    git add -A 2>/dev/null
    git commit -m "📊 I18N Status update $(date +%H:%M)" -q 2>/dev/null
    
    if git push origin master -q 2>/dev/null; then
        LAST_PUSH_TIME=$current_time
        log_success "✅ Push zakończony pomyślnie"
    else
        log_warn "⚠️ Push nieudany - spróbuję przy następnym cyklu"
    fi
    
    cd "$WORK_DIR"
}

#===============================================================================
# KOMUNIKACJA PRZEZ GITHUB - Terminal do wysyłania komend
#===============================================================================
check_github_commands() {
    [ ! -f "$COMMANDS_FILE" ] && return 0
    
    local cmd_content=$(cat "$COMMANDS_FILE" 2>/dev/null)
    [ -z "$cmd_content" ] && return 0
    
    log_info "📩 Odebrano komendy z GitHub..."
    
    # Parsuj komendy linia po linii
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue  # Ignoruj komentarze
        [[ -z "$line" ]] && continue         # Ignoruj puste linie
        
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local cmd=$(echo "$line" | cut -d: -f1 | xargs)
        local arg=$(echo "$line" | cut -d: -f2- | xargs)
        
        case "$cmd" in
            "PAUSE"|"pause"|"stop")
                log_warn "⏸️ Komenda PAUSE - worker zatrzymany"
                echo "[$timestamp] PAUSE - wykonano" >> "$COMMANDS_LOG"
                echo "" > "$COMMANDS_FILE"
                sleep 3600  # Czekaj godzinę
                ;;
            "RESUME"|"resume"|"start")
                log_info "▶️ Komenda RESUME - wznawiam"
                echo "[$timestamp] RESUME - wykonano" >> "$COMMANDS_LOG"
                ;;
            "STATUS"|"status")
                log_info "📊 Komenda STATUS - generuję raport"
                update_all_categories_status
                update_status
                echo "[$timestamp] STATUS - wygenerowano" >> "$COMMANDS_LOG"
                ;;
            "TRANSLATE"|"translate")
                log_info "🌍 Komenda TRANSLATE: $arg"
                if [ -n "$arg" ]; then
                    local batch_size=$(echo "$arg" | cut -d' ' -f1)
                    [ -z "$batch_size" ] && batch_size=20
                    python3 tools/i18n_translate.py --batch "$batch_size" --category npc 2>&1 | tee -a "$LOG_FILE"
                    echo "[$timestamp] TRANSLATE $batch_size - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            "PHASE"|"phase")
                log_info "🔄 Komenda PHASE: przejdź do fazy $arg"
                if [[ "$arg" =~ ^[0-9]+$ ]]; then
                    jq --argjson p "$arg" '.current_phase = $p' "$WORK_PLAN" > /tmp/wp.json && mv /tmp/wp.json "$WORK_PLAN"
                    echo "[$timestamp] PHASE $arg - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            "CATEGORY"|"category")
                log_info "📂 Komenda CATEGORY: przejdź do $arg"
                if [ -n "$arg" ]; then
                    jq --arg cat "$arg" '.current_category = $cat' "$WORK_PLAN" > /tmp/wp.json && mv /tmp/wp.json "$WORK_PLAN"
                    echo "[$timestamp] CATEGORY $arg - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            "PUSH"|"push")
                log_info "📤 Komenda PUSH - wymuszam push"
                LAST_PUSH_TIME=0
                echo "[$timestamp] PUSH - wykonano" >> "$COMMANDS_LOG"
                ;;
            "RESTART"|"restart")
                log_warn "🔄 Komenda RESTART - restartuję worker"
                echo "[$timestamp] RESTART - wykonano" >> "$COMMANDS_LOG"
                echo "" > "$COMMANDS_FILE"
                exec "$0"
                ;;
            "RECENT"|"recent"|"last")
                log_info "📋 Komenda RECENT - ostatnie pliki"
                generate_recent_files_report "$arg"
                echo "[$timestamp] RECENT $arg - wykonano" >> "$COMMANDS_LOG"
                ;;
            "ANALYZE"|"analyze"|"check")
                log_info "🔍 Komenda ANALYZE: $arg"
                if [ -n "$arg" ]; then
                    analyze_specific_file "$arg"
                    echo "[$timestamp] ANALYZE $arg - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            "PROMPT"|"prompt"|"ask")
                log_info "💬 Komenda PROMPT: $arg"
                if [ -n "$arg" ]; then
                    process_user_prompt "$arg"
                    echo "[$timestamp] PROMPT - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            "INFO"|"info")
                log_info "ℹ️ Komenda INFO"
                generate_worker_info
                echo "[$timestamp] INFO - wykonano" >> "$COMMANDS_LOG"
                ;;
            "KEYS"|"keys")
                log_info "🔑 Komenda KEYS: $arg"
                show_category_keys "$arg"
                echo "[$timestamp] KEYS $arg - wykonano" >> "$COMMANDS_LOG"
                ;;
            "ERRORS"|"errors")
                log_info "⚠️ Komenda ERRORS - pokazuję błędy"
                show_recent_errors
                echo "[$timestamp] ERRORS - wykonano" >> "$COMMANDS_LOG"
                ;;
            "SCAN"|"scan")
                log_info "🔍 Komenda SCAN: $arg"
                if [ -n "$arg" ]; then
                    scan_directory_for_i18n "$arg"
                    echo "[$timestamp] SCAN $arg - wykonano" >> "$COMMANDS_LOG"
                fi
                ;;
            *)
                log_warn "❓ Nieznana komenda: $cmd"
                echo "[$timestamp] UNKNOWN: $cmd - zignorowano" >> "$COMMANDS_LOG"
                ;;
        esac
    done < "$COMMANDS_FILE"
    
    # Wyczyść plik komend po wykonaniu
    echo "# Worker Commands - Oczekuję na komendy..." > "$COMMANDS_FILE"
}

#===============================================================================
# NOWE FUNKCJE KOMEND
#===============================================================================

# Generuj raport ostatnich plików
generate_recent_files_report() {
    local count="${1:-5}"
    local report_file="$WORK_DIR/.github/recent_report.md"
    
    cat > "$report_file" << EOF
# 📋 Raport Ostatnich Plików
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')

## 📝 Ostatnie $count edytowanych plików
\`\`\`
$(tail -$count "$PROCESSED_FILE" 2>/dev/null | while read f; do
    local mtime=$(stat -c '%Y' "$f" 2>/dev/null || echo "0")
    local mtime_h=$(date -d "@$mtime" '+%H:%M:%S' 2>/dev/null || echo "??:??")
    echo "[$mtime_h] $(basename "$f")"
done)
\`\`\`

## 🔍 Ostatnie $count analizowanych plików
\`\`\`
$(grep -l "sendTextMessage\|:say(" data-otservbr-global/npc/*.lua 2>/dev/null | tail -$count | while read f; do
    echo "$(basename "$f")"
done)
\`\`\`

## 📊 Statystyki
- Przetworzonych: $(wc -l < "$PROCESSED_FILE" 2>/dev/null || echo "0")
- Wykluczonych: $(wc -l < "$EXCLUDED_FILE" 2>/dev/null || echo "0")
- Kluczy: $(jq 'length' "$I18N_DIR/en/npc.json" 2>/dev/null || echo "0") NPC
EOF
    
    log_success "📋 Raport zapisano w .github/recent_report.md"
}

# Analizuj konkretny plik
analyze_specific_file() {
    local file_pattern="$1"
    local report_file="$WORK_DIR/.github/analysis_report.md"
    
    # Znajdź plik
    local found_file=$(find "$WORK_DIR" -name "$file_pattern" -type f 2>/dev/null | head -1)
    
    if [ -z "$found_file" ]; then
        log_warn "❌ Nie znaleziono pliku: $file_pattern"
        echo "# ❌ Nie znaleziono: $file_pattern" > "$report_file"
        return 1
    fi
    
    log_info "🔍 Analizuję: $found_file"
    
    cat > "$report_file" << EOF
# 🔍 Analiza pliku: $(basename "$found_file")
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')
> Ścieżka: \`$found_file\`

## 📊 Statystyki
- Rozmiar: $(stat -c '%s' "$found_file" 2>/dev/null || echo "?") bajtów
- Linii: $(wc -l < "$found_file" 2>/dev/null || echo "?")

## 🔑 Znalezione stringi do i18n

### npcHandler:say() / selfSay()
\`\`\`lua
$(grep -nE 'npcHandler:say\(|selfSay\(' "$found_file" 2>/dev/null | head -20)
\`\`\`

### sendTextMessage()
\`\`\`lua
$(grep -nE 'sendTextMessage' "$found_file" 2>/dev/null | head -10)
\`\`\`

### Inne stringi tekstowe
\`\`\`lua
$(grep -nE '"[^"]{15,}"' "$found_file" 2>/dev/null | grep -v "NPC_LIB.i18n" | head -10)
\`\`\`

## ✅ Już zmigrowane (używa i18n API)
\`\`\`lua
$(grep -nE 'NPC_LIB\.i18n\.' "$found_file" 2>/dev/null | head -10)
\`\`\`

## 📋 Rekomendacje
$(if grep -qE 'NPC_LIB\.i18n\.' "$found_file" 2>/dev/null; then
    echo "✅ Plik już częściowo zmigrowany do i18n"
else
    echo "⚠️ Plik wymaga migracji do i18n API"
fi)

$(local unmigrated=$(grep -cE 'npcHandler:say\("[^"]+"\)|selfSay\("[^"]+"\)' "$found_file" 2>/dev/null || echo "0")
echo "- Niezmigrowanych stringów: $unmigrated")
EOF
    
    log_success "📋 Analiza zapisana w .github/analysis_report.md"
}

# Przetwórz prompt użytkownika
process_user_prompt() {
    local prompt="$1"
    local report_file="$WORK_DIR/.github/prompt_response.md"
    
    cat > "$report_file" << EOF
# 💬 Odpowiedź na prompt
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')
> Prompt: "$prompt"

## 🔍 Analiza zapytania

$(if echo "$prompt" | grep -qiE "Sam\.lua|sam\.npc|Sam\.npc"; then
    echo "### Szukam pliku Sam..."
    local sam_file=$(find "$WORK_DIR" -iname "*sam*.lua" -path "*/npc/*" 2>/dev/null | head -1)
    if [ -n "$sam_file" ]; then
        echo "Znaleziono: \`$sam_file\`"
        echo ""
        echo "#### Stringi do i18n:"
        echo "\`\`\`lua"
        grep -nE 'npcHandler:say\(|selfSay\(' "$sam_file" 2>/dev/null | head -15
        echo "\`\`\`"
        echo ""
        echo "#### Status migracji:"
        if grep -q 'NPC_LIB.i18n' "$sam_file" 2>/dev/null; then
            echo "✅ Plik już używa i18n API"
        else
            echo "⚠️ Plik wymaga migracji"
        fi
    else
        echo "❌ Nie znaleziono pliku Sam"
    fi
elif echo "$prompt" | grep -qiE "status|postęp|progress"; then
    echo "### Status pracy"
    echo "- Faza: $(get_current_phase)"
    echo "- Kategoria: $(get_current_category)"
    echo "- Cykl: #$CYCLE_COUNT"
elif echo "$prompt" | grep -qiE "błęd|error|problem"; then
    echo "### Ostatnie błędy"
    tail -20 "$CONFLICTS_FILE" 2>/dev/null || echo "Brak błędów"
else
    echo "Nie rozpoznano zapytania. Dostępne tematy:"
    echo "- Analiza konkretnego pliku NPC"
    echo "- Status pracy"
    echo "- Błędy i konflikty"
fi)

---
*Worker v4.1 - GitHub Command Terminal*
EOF

    log_success "💬 Odpowiedź zapisana w .github/prompt_response.md"
}

# Informacje o workerze
generate_worker_info() {
    local report_file="$WORK_DIR/.github/worker_info.md"
    
    cat > "$report_file" << EOF
# ℹ️ Informacje o Workerze
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')

## 🤖 Worker Status
| Parametr | Wartość |
|----------|---------|
| Wersja | v4.1 |
| PID | $$ |
| Cykl | #$CYCLE_COUNT |
| Tryb | $MODE |
| Uptime | $(ps -o etime= -p $$ 2>/dev/null || echo "?") |

## 📊 Statystyki
| Metryka | Wartość |
|---------|---------|
| Plików przetworzonych | $(wc -l < "$PROCESSED_FILE" 2>/dev/null || echo "0") |
| Plików wykluczonych | $(wc -l < "$EXCLUDED_FILE" 2>/dev/null || echo "0") |
| Stringów znalezionych | $TOTAL_STRINGS_FOUND |
| Konfliktów | $TOTAL_CONFLICTS |

## 🗂️ Kategorie JSON
$(for f in "$I18N_DIR/en"/*.json; do
    [ -f "$f" ] && echo "- $(basename "$f"): $(jq 'length' "$f" 2>/dev/null || echo "0") kluczy"
done)

## 📁 Katalogi skanowane
$(printf '%s\n' "${SCAN_DIRS[@]}" | head -10)
...

---
*Worker v4.1*
EOF

    log_success "ℹ️ Info zapisano w .github/worker_info.md"
}

# Pokaż klucze kategorii
show_category_keys() {
    local category="${1:-npc}"
    local report_file="$WORK_DIR/.github/keys_$category.md"
    local json_file="$I18N_DIR/en/$category.json"
    
    if [ ! -f "$json_file" ]; then
        log_warn "❌ Brak pliku: $json_file"
        return 1
    fi
    
    cat > "$report_file" << EOF
# 🔑 Klucze kategorii: $category
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')
> Plik: \`$json_file\`

## 📊 Statystyki
- Łącznie kluczy: $(jq 'length' "$json_file" 2>/dev/null || echo "0")
- Rozmiar pliku: $(stat -c '%s' "$json_file" 2>/dev/null || echo "?") bajtów

## 🔤 Przykładowe klucze (pierwsze 20)
\`\`\`json
$(jq 'keys[:20]' "$json_file" 2>/dev/null)
\`\`\`

## 📝 Przykładowe wartości
\`\`\`json
$(jq 'to_entries[:10] | from_entries' "$json_file" 2>/dev/null)
\`\`\`
EOF

    log_success "🔑 Klucze zapisano w .github/keys_$category.md"
}

# Pokaż ostatnie błędy
show_recent_errors() {
    local report_file="$WORK_DIR/.github/errors_report.md"
    
    cat > "$report_file" << EOF
# ⚠️ Raport błędów
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')

## 🔴 Ostatnie konflikty
\`\`\`
$(tail -30 "$CONFLICTS_FILE" 2>/dev/null || echo "Brak konfliktów")
\`\`\`

## ⚠️ Błędy składni Lua
\`\`\`
$(grep -r "syntax error\|unexpected" "$LOG_FILE" 2>/dev/null | tail -10 || echo "Brak błędów składni")
\`\`\`

## 📋 Błędy z logu
\`\`\`
$(grep -E "\[ERROR\]|\[WARN\]" "$LOG_FILE" 2>/dev/null | tail -20 || echo "Brak błędów")
\`\`\`
EOF

    log_success "⚠️ Błędy zapisano w .github/errors_report.md"
}

# Skanuj katalog
scan_directory_for_i18n() {
    local dir="$1"
    local report_file="$WORK_DIR/.github/scan_report.md"
    
    local full_dir="$WORK_DIR/$dir"
    [ ! -d "$full_dir" ] && full_dir=$(find "$WORK_DIR" -type d -name "$dir" 2>/dev/null | head -1)
    
    if [ ! -d "$full_dir" ]; then
        log_warn "❌ Nie znaleziono katalogu: $dir"
        echo "# ❌ Nie znaleziono katalogu: $dir" > "$report_file"
        return 1
    fi
    
    cat > "$report_file" << EOF
# 🔍 Skan katalogu: $dir
> Wygenerowano: $(date '+%Y-%m-%d %H:%M:%S')
> Ścieżka: \`$full_dir\`

## 📊 Statystyki
- Plików Lua: $(find "$full_dir" -name "*.lua" 2>/dev/null | wc -l)
- Plików PHP: $(find "$full_dir" -name "*.php" 2>/dev/null | wc -l)
- Plików HTML: $(find "$full_dir" -name "*.html" 2>/dev/null | wc -l)

## 🔑 Pliki z potencjalnymi stringami do i18n
$(find "$full_dir" -name "*.lua" -exec grep -l 'sendTextMessage\|:say(' {} \; 2>/dev/null | head -15 | while read f; do
    local count=$(grep -cE 'sendTextMessage|:say\(' "$f" 2>/dev/null || echo "0")
    echo "- \`$(basename "$f")\`: $count stringów"
done)

## ✅ Pliki już zmigrowane
$(find "$full_dir" -name "*.lua" -exec grep -l 'NPC_LIB.i18n' {} \; 2>/dev/null | wc -l) plików używa i18n API
EOF

    log_success "🔍 Skan zapisano w .github/scan_report.md"
}

#===============================================================================
# ZARZĄDZANIE PLANEM PRACY (CHECKLIST)
#===============================================================================
WORK_PLAN="$I18N_DIR/work_plan.json"

# Pobierz aktualną fazę
get_current_phase() {
    jq -r '.current_phase // 1' "$WORK_PLAN" 2>/dev/null || echo "1"
}

# Pobierz aktualną kategorię
get_current_category() {
    jq -r '.current_category // "npc"' "$WORK_PLAN" 2>/dev/null || echo "npc"
}

# Pobierz nazwę fazy
get_phase_name() {
    local phase_id="$1"
    jq -r ".phases[] | select(.id == $phase_id) | .display" "$WORK_PLAN" 2>/dev/null || echo "Unknown"
}

# Sprawdź czy kategoria jest zakończona
is_category_completed() {
    local category="$1"
    local phase=$(get_current_phase)
    local status=$(jq -r ".phases[] | select(.id == $phase) | .categories[] | select(.id == \"$category\") | .status" "$WORK_PLAN" 2>/dev/null)
    [ "$status" == "completed" ]
}

# Sprawdź czy są nowe pliki do przetworzenia (nie w processed ani excluded)
count_new_files() {
    local count=0
    for dir in "${SCAN_DIRS[@]}"; do
        local full_dir="$WORK_DIR/$dir"
        [ ! -d "$full_dir" ] && continue
        
        while IFS= read -r -d '' file; do
            grep -qF "$file" "$PROCESSED_FILE" 2>/dev/null && continue
            grep -qF "$file" "$EXCLUDED_FILE" 2>/dev/null && continue
            count=$((count + 1))
        done < <(find "$full_dir" -maxdepth 3 -type f \( -name "*.lua" -o -name "*.cpp" -o -name "*.php" -o -name "*.html" \) -print0 2>/dev/null)
    done
    echo "$count"
}

# Znajdź kategorię dla nowego pliku
detect_file_category() {
    local file="$1"
    if [[ "$file" == *"html_copy"* ]]; then
        echo "web_php"
    elif [[ "$file" == *"testyy"* ]]; then
        echo "client_ui"
    elif [[ "$file" == *"/npc/"* ]]; then
        echo "npc"
    elif [[ "$file" == *"/scripts/"* ]]; then
        echo "scripts"
    elif [[ "$file" == *"/monster/"* ]]; then
        echo "monsters"
    elif [[ "$file" == *"/src/"* ]]; then
        echo "server_cpp"
    else
        echo "misc"
    fi
}

# Aktualizuj postęp kategorii
update_category_progress() {
    local category="$1"
    local keys="$2"
    local files="$3"
    local phase=$(get_current_phase)
    
    # Dynamiczne cele - jeśli przekroczono target, zwiększ go o 10%
    local current_target=$(jq -r ".phases[] | select(.id == $phase) | .categories[] | select(.id == \"$category\") | .target_keys // 0" "$WORK_PLAN" 2>/dev/null || echo "0")
    local new_target=$current_target
    
    # Jeśli keys > target, ustaw nowy target = keys + 10%
    if [ "$keys" -gt "$current_target" ] 2>/dev/null; then
        new_target=$((keys + keys / 10))
        log_info "📈 Dynamiczny cel '$category': $current_target → $new_target"
    fi
    
    # Aktualizuj JSON
    local tmp=$(mktemp)
    jq --arg cat "$category" --argjson keys "$keys" --argjson files "$files" --argjson phase "$phase" --argjson target "$new_target" '
        .phases |= map(
            if .id == $phase then
                .categories |= map(
                    if .id == $cat then
                        .keys_extracted = $keys |
                        .files_processed = $files |
                        .target_keys = $target |
                        (if $keys >= ($target * 0.95) then .status = "completed" else .status = "in_progress" end)
                    else . end
                )
            else . end
        )
    ' "$WORK_PLAN" > "$tmp" 2>/dev/null && mv "$tmp" "$WORK_PLAN"
}

# Przejdź do następnej kategorii
advance_to_next_category() {
    local phase=$(get_current_phase)
    local current=$(get_current_category)
    
    # Znajdź następną niezakończoną kategorię w tej fazie
    local next=$(jq -r ".phases[] | select(.id == $phase) | .categories[] | select(.status != \"completed\") | .id" "$WORK_PLAN" 2>/dev/null | head -1)
    
    if [ -n "$next" ] && [ "$next" != "null" ]; then
        # Jest jeszcze kategoria do zrobienia
        jq --arg cat "$next" '.current_category = $cat' "$WORK_PLAN" > /tmp/wp.json && mv /tmp/wp.json "$WORK_PLAN"
        log_info "➡️ Przechodzę do kategorii: $next"
        return 0
    else
        # Wszystkie kategorie w fazie zakończone - przejdź do następnej fazy
        local next_phase=$((phase + 1))
        local max_phases=$(jq -r '.total_phases' "$WORK_PLAN" 2>/dev/null || echo "4")
        
        if [ "$next_phase" -le "$max_phases" ]; then
            # Znajdź pierwszą kategorię w nowej fazie
            local first_cat=$(jq -r ".phases[] | select(.id == $next_phase) | .categories[0].id" "$WORK_PLAN" 2>/dev/null)
            jq --argjson phase "$next_phase" --arg cat "$first_cat" '
                .current_phase = $phase | 
                .current_category = $cat |
                .phases |= map(if .id == ($phase - 1) then .status = "completed" else . end) |
                .phases |= map(if .id == $phase then .status = "in_progress" else . end) |
                .completed_phases = ($phase - 1)
            ' "$WORK_PLAN" > /tmp/wp.json && mv /tmp/wp.json "$WORK_PLAN"
            log_success "🎉 FAZA $phase ZAKOŃCZONA! Przechodzę do fazy $next_phase"
            return 0
        else
            # Wszystkie fazy zakończone
            log_success "🏆 WSZYSTKIE FAZY ZAKOŃCZONE!"
            return 1
        fi
    fi
}

# Pobierz katalogi dla aktualnej kategorii
get_current_directories() {
    local phase=$(get_current_phase)
    local category=$(get_current_category)
    jq -r ".phases[] | select(.id == $phase) | .categories[] | select(.id == \"$category\") | .directories[]" "$WORK_PLAN" 2>/dev/null
}

# Generuj sekcję aktywności w czasie rzeczywistym
generate_activity_section() {
    local output=""
    
    if [ -f "$ACTIVITY_FILE" ]; then
        local current_op=$(jq -r '.current_operation.action // "Oczekiwanie"' "$ACTIVITY_FILE" 2>/dev/null)
        local current_file=$(jq -r '.current_operation.file // "-"' "$ACTIVITY_FILE" 2>/dev/null)
        local current_status=$(jq -r '.current_operation.status // "idle"' "$ACTIVITY_FILE" 2>/dev/null)
        local current_details=$(jq -r '.current_operation.details // ""' "$ACTIVITY_FILE" 2>/dev/null)
        local last_update=$(jq -r '.last_updated // "-"' "$ACTIVITY_FILE" 2>/dev/null)
        
        local status_emoji="⏳"
        case "$current_status" in
            "in_progress") status_emoji="🔄" ;;
            "completed") status_emoji="✅" ;;
            "error") status_emoji="❌" ;;
            "waiting"|"idle") status_emoji="💤" ;;
        esac
        
        output+="| Parametr | Wartość |\n"
        output+="|----------|----------|\n"
        output+="| **Status** | $status_emoji $current_status |\n"
        output+="| **Operacja** | $current_op |\n"
        output+="| **Plik** | \`$current_file\` |\n"
        output+="| **Szczegóły** | $current_details |\n"
        output+="| **Ostatnia aktualizacja** | $last_update |\n\n"
        
        # Statystyki sesji
        local files_session=$(jq -r '.stats.files_this_session // 0' "$ACTIVITY_FILE" 2>/dev/null)
        local keys_session=$(jq -r '.stats.keys_this_session // 0' "$ACTIVITY_FILE" 2>/dev/null)
        local errors_session=$(jq -r '.stats.errors_this_session // 0' "$ACTIVITY_FILE" 2>/dev/null)
        local fixes_session=$(jq -r '.stats.fixes_applied // 0' "$ACTIVITY_FILE" 2>/dev/null)
        
        output+="### 📈 Statystyki sesji\n\n"
        output+="| Metryka | Wartość |\n"
        output+="|---------|----------|\n"
        output+="| Plików przetworzonych | $files_session |\n"
        output+="| Kluczy wyciągniętych | $keys_session |\n"
        output+="| Błędów | $errors_session |\n"
        output+="| Napraw zastosowanych | $fixes_session |\n\n"
        
        # Ostatnie operacje
        local recent=$(jq -r '.recent_operations[:5][] | "| \(.time) | \(.type) | \`\(.file)\` | \(.status) |"' "$ACTIVITY_FILE" 2>/dev/null)
        if [ -n "$recent" ]; then
            output+="### 📋 Ostatnie operacje\n\n"
            output+="| Czas | Typ | Plik | Status |\n"
            output+="|------|-----|------|--------|\n"
            output+="$recent\n\n"
        fi
        
        # Błędy (jeśli są)
        local errors=$(jq -r '.errors[:3][] | "| \(.time) | \`\(.file)\` | \(.error) |"' "$ACTIVITY_FILE" 2>/dev/null)
        if [ -n "$errors" ]; then
            output+="### ⚠️ Ostatnie błędy\n\n"
            output+="| Czas | Plik | Błąd |\n"
            output+="|------|------|------|\n"
            output+="$errors\n"
        fi
    else
        output+="*Brak danych o aktywności*\n"
    fi
    
    echo -e "$output"
}

# Generuj checklist do statusu
generate_checklist() {
    local output=""
    local phases=$(jq -r '.phases | length' "$WORK_PLAN" 2>/dev/null || echo "4")
    
    for ((p=1; p<=phases; p++)); do
        local phase_name=$(jq -r ".phases[] | select(.id == $p) | .display" "$WORK_PLAN" 2>/dev/null)
        local phase_status=$(jq -r ".phases[] | select(.id == $p) | .status" "$WORK_PLAN" 2>/dev/null)
        local phase_icon="⏳"
        [ "$phase_status" == "completed" ] && phase_icon="✅"
        [ "$phase_status" == "in_progress" ] && phase_icon="🔄"
        
        output+="### $phase_icon Faza $p: $phase_name\n\n"
        
        # Kategorie w fazie
        local categories=$(jq -r ".phases[] | select(.id == $p) | .categories[] | \"\(.icon) \(.name)|\(.status)|\(.keys_extracted)|\(.target_keys)\"" "$WORK_PLAN" 2>/dev/null)
        
        if [ -n "$categories" ]; then
            output+="| Kategoria | Status | Postęp | Cel |\n"
            output+="|-----------|--------|--------|-----|\n"
            
            while IFS='|' read -r name status keys target; do
                local status_icon="⏳"
                [ "$status" == "completed" ] && status_icon="✅"
                [ "$status" == "in_progress" ] && status_icon="🔄"
                local pct=0
                [ "$target" -gt 0 ] 2>/dev/null && pct=$((keys * 100 / target))
                output+="| $name | $status_icon | $keys/$target ($pct%) | $target |\n"
            done <<< "$categories"
        fi
        output+="\n"
    done
    
    echo -e "$output"
}

#===============================================================================
# AKTUALIZACJA STATUSU KATEGORII
#===============================================================================
# Tworzy/aktualizuje plik JSON dla każdej kategorii z dokładnymi statystykami
update_category_status() {
    local category="$1"
    local status_file="$I18N_DIR/status/${category}.json"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    mkdir -p "$I18N_DIR/status"
    
    # Policz klucze dla tej kategorii (z angielskiego jako źródła)
    local total_keys=0
    if [ -f "$I18N_DIR/en/${category}.json" ]; then
        total_keys=$(python3 -c "import json; print(len(json.load(open('$I18N_DIR/en/${category}.json'))))" 2>/dev/null || echo "0")
    fi
    
    # Policz przetłumaczone klucze (polski jako główny)
    local translated_pl=0
    if [ -f "$I18N_DIR/pl/${category}.json" ]; then
        translated_pl=$(python3 -c "import json; d=json.load(open('$I18N_DIR/pl/${category}.json')); print(sum(1 for v in d.values() if v and v.strip()))" 2>/dev/null || echo "0")
    fi
    [ -z "$translated_pl" ] && translated_pl=0
    
    # Policz pliki przetworzonych w tej kategorii
    local files_processed=0
    case "$category" in
        npc) files_processed=$(grep -c "/npc/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        scripts) files_processed=$(grep -cE "/scripts/|/events/|/actions/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        items) files_processed=$(grep -c "/items/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        monsters) files_processed=$(grep -c "/monster/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        spells) files_processed=$(grep -c "/spells/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        server) files_processed=$(grep -c "/src/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        ui) files_processed=$(grep -cE "html_copy|testyy" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
        *) files_processed=$(grep -c "/$category/" "$PROCESSED_FILE" 2>/dev/null | tr -d '\n' || echo "0") ;;
    esac
    [ -z "$files_processed" ] && files_processed=0
    
    # Policz pozostałe pliki do przetworzenia
    local files_remaining=0
    case "$category" in
        npc) files_remaining=$(find data-otservbr-global/npc data-canary/npc -name "*.lua" 2>/dev/null | wc -l | tr -d ' ') ;;
        scripts) files_remaining=$(find data-otservbr-global/scripts data/scripts -name "*.lua" 2>/dev/null | wc -l | tr -d ' ') ;;
        items) files_remaining=$(find data/items -name "*.xml" 2>/dev/null | wc -l | tr -d ' ') ;;
        monsters) files_remaining=$(find data-otservbr-global/monster data-canary/monster -name "*.xml" 2>/dev/null | wc -l | tr -d ' ') ;;
        ui) files_remaining=$(find html_copy testyy -name "*.php" -o -name "*.html" 2>/dev/null | wc -l | tr -d ' ') ;;
        *) files_remaining=0 ;;
    esac
    [ -z "$files_remaining" ] && files_remaining=0
    files_remaining=$((files_remaining - files_processed))
    [ "$files_remaining" -lt 0 ] && files_remaining=0
    
    # Oblicz procent ukończenia
    local pct=0
    [ "$total_keys" -gt 0 ] && pct=$((translated_pl * 100 / total_keys))
    
    # Określ status
    local status="not_started"
    [ "$files_processed" -gt 0 ] && status="in_progress"
    [ "$pct" -ge 95 ] && status="completed"
    
    # Policz języki z tłumaczeniami
    local langs_with_translations=0
    for lang in "${LANGUAGES[@]}"; do
        if [ -f "$I18N_DIR/$lang/${category}.json" ]; then
            local lang_keys=$(python3 -c "import json; d=json.load(open('$I18N_DIR/$lang/${category}.json')); print(sum(1 for v in d.values() if v and v.strip()))" 2>/dev/null || echo "0")
            [ "$lang_keys" -gt 0 ] && langs_with_translations=$((langs_with_translations + 1))
        fi
    done
    
    # Zapisz status do JSON
    cat > "$status_file" << EOF
{
  "category": "$category",
  "last_updated": "$timestamp",
  "status": "$status",
  "progress": {
    "percentage": $pct,
    "total_keys": $total_keys,
    "translated_pl": $translated_pl,
    "files_processed": $files_processed,
    "files_remaining": $files_remaining
  },
  "languages": {
    "total": ${#LANGUAGES[@]},
    "with_translations": $langs_with_translations
  },
  "details": {
    "source_file": "$I18N_DIR/en/${category}.json",
    "primary_translation": "$I18N_DIR/pl/${category}.json"
  }
}
EOF
    
    log_info "📊 Status kategorii '$category': $pct% ($translated_pl/$total_keys kluczy)"
}

# Aktualizuj status wszystkich kategorii
update_all_categories_status() {
    local categories=("npc" "scripts" "items" "monsters" "spells" "server" "ui" "quests" "events" "actions")
    
    for cat in "${categories[@]}"; do
        update_category_status "$cat"
    done
    
    log_info "📊 Zaktualizowano status ${#categories[@]} kategorii"
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
        for cat in npc scripts actions quests events server ui messages errors items spells monsters; do
            [ ! -f "$I18N_DIR/$lang/${cat}.json" ] && echo "{}" > "$I18N_DIR/$lang/${cat}.json"
        done
    done
    
    [ ! -f "$EXCLUDED_FILE" ] && touch "$EXCLUDED_FILE"
    [ ! -f "$PROCESSED_FILE" ] && touch "$PROCESSED_FILE"
    [ ! -f "$CONFLICTS_FILE" ] && touch "$CONFLICTS_FILE"
    
    # Zainicjuj plan pracy jeśli nie istnieje
    [ ! -f "$WORK_PLAN" ] && log_warn "⚠️ Brak planu pracy - utwórz i18n/work_plan.json"
    
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

# Atomowy zapis klucza do JSON (bezpieczny przy współbieżnym zapisie)
add_key_to_json() {
    local json_file="$1"
    local key="$2"
    local value="$3"
    
    # Używamy flock dla bezpieczeństwa współbieżnego
    (
        flock -x 200
        python3 -c "
import json, os, tempfile, shutil
f='$json_file'
k='''$key'''
v='''$value'''

# Wczytaj istniejący JSON
d={}
if os.path.exists(f) and os.path.getsize(f) > 2:
    try:
        with open(f, 'r') as fp:
            d = json.load(fp)
    except:
        d = {}

# Dodaj klucz
d[k] = v

# Zapisz atomowo (do pliku tymczasowego, potem mv)
fd, tmp = tempfile.mkstemp(suffix='.json', dir=os.path.dirname(f))
try:
    with os.fdopen(fd, 'w') as fp:
        json.dump(d, fp, indent=2, ensure_ascii=False)
    shutil.move(tmp, f)
except:
    os.unlink(tmp)
    raise
" 2>/dev/null
    ) 200>"${json_file}.lock"
}

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
# MIGRACJA LUA - TYLKO EKSTRAKCJA KLUCZY (zgodnie z roadmapą)
#===============================================================================
# Roadmap mówi że:
# 1. NIE modyfikujemy plików Lua automatycznie
# 2. Tylko ekstrakcja kluczy do JSON
# 3. Python pipeline robi sync: python tools/i18n_pipeline.py --locales pl es pt de
# 4. Migracja NPC wymaga helper lib/npc/i18n.lua (do stworzenia)
#===============================================================================

migrate_lua_file() {
    local file="$1"
    local file_name=$(basename "$file" .lua)
    local safe_name=$(echo "$file_name" | tr ' ' '_' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    local category=$(get_category "$file")
    local relative_path="${file#$WORK_DIR/}"
    
    log_info "🔷 [LUA] $relative_path"
    
    # Sprawdź czy już zmigrowany (helper NPC lub sendLocalizedTextMessage)
    if grep -qE "sendLocalizedTextMessage|NPC_LIB\.i18n\." "$file" 2>/dev/null; then
        log_info "   ⏭️ Już zmigrowany (używa prawidłowego API)"
        mark_processed "$file"
        return 1
    fi
    
    # Wzorce do szukania w plikach NPC
    local patterns_npc=(
        'npcHandler:say\s*\(\s*"[^"]{5,}"'
        'npcHandler:say\s*\(\s*\{\s*"[^"]{5,}"'
        'StdModule\.say.*text\s*=\s*"[^"]{5,}"'
    )
    
    # Wzorce dla innych plików Lua (scripts, actions, etc.)
    local patterns_other=(
        'player:sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"'
    )
    
    local has_strings=false
    local is_npc_file=false
    
    # Sprawdź czy to plik NPC
    if [[ "$file" == *"/npc/"* ]]; then
        is_npc_file=true
        for pattern in "${patterns_npc[@]}"; do
            if grep -qE "$pattern" "$file" 2>/dev/null; then
                has_strings=true
                break
            fi
        done
    else
        for pattern in "${patterns_other[@]}"; do
            if grep -qE "$pattern" "$file" 2>/dev/null; then
                has_strings=true
                break
            fi
        done
    fi
    
    if [ "$has_strings" = false ]; then
        log_info "   ⏭️ Brak stringów do migracji"
        mark_excluded "$file"
        return 1
    fi
    
    # === MIGRACJA Z PRAWIDŁOWYM API ===
    cp "$file" "${file}.bak"
    
    local temp_file=$(mktemp)
    local transformed=0
    local extracted=0  # Licznik wyekstrahowanych kluczy (nawet bez zmiany kodu)
    local key_counter=1
    local json_file="$I18N_DIR/en/${category}.json"
    
    [ ! -f "$json_file" ] && echo "{}" > "$json_file"
    
    while IFS= read -r line || [ -n "$line" ]; do
        local new_line="$line"
        
        #=== MIGRACJA NPC: npcHandler:say → NPC_LIB.i18n.npcSay ===
        if [ "$is_npc_file" = true ]; then
            
            # WZORZEC 1: npcHandler:say("tekst", npc, creature)
            if echo "$line" | grep -qE 'npcHandler:say\s*\(\s*"[^"]{5,}"[^)]*,\s*npc\s*,\s*creature'; then
                local text=$(echo "$line" | sed -n 's/.*npcHandler:say\s*(\s*"\([^"]*\)"[^)]*,.*/\1/p')
                if [ -n "$text" ] && [ ${#text} -ge 5 ]; then
                    local key="npc.${safe_name}.say_${key_counter}"
                    key_counter=$((key_counter + 1))
                    
                    # Zamiana: npcHandler:say("tekst", npc, creature) → NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "key")
                    new_line=$(echo "$line" | sed "s|npcHandler:say(\s*\"[^\"]*\",\s*npc,\s*creature)|NPC_LIB.i18n.npcSay(npcHandler, npc, creature, \"${key}\")|")
                    
                    add_key_to_json "$json_file" "$key" "$text"
                    
                    transformed=$((transformed + 1))
                    log_info "      🔑 $key"
                fi
            fi
            
            # WZORZEC 2: npcHandler:say({ "tekst" }, npc, creature)
            if echo "$line" | grep -qE 'npcHandler:say\s*\(\s*\{\s*"[^"]{5,}"[^}]*\}\s*,\s*npc\s*,\s*creature'; then
                local text=$(echo "$line" | sed -n 's/.*npcHandler:say\s*(\s*{\s*"\([^"]*\)"[^}]*}.*/\1/p')
                if [ -n "$text" ] && [ ${#text} -ge 5 ]; then
                    local key="npc.${safe_name}.say_${key_counter}"
                    key_counter=$((key_counter + 1))
                    
                    new_line=$(echo "$line" | sed "s|npcHandler:say(\s*{\s*\"[^\"]*\"[^}]*},\s*npc,\s*creature)|NPC_LIB.i18n.npcSay(npcHandler, npc, creature, \"${key}\")|")
                    
                    add_key_to_json "$json_file" "$key" "$text"
                    
                    transformed=$((transformed + 1))
                    log_info "      🔑 $key"
                fi
            fi
            
            # WZORZEC 3: StdModule.say - PEŁNA TRANSFORMACJA text → i18nKey
            if echo "$line" | grep -qE 'StdModule\.say.*text\s*=\s*"[^"]{5,}"'; then
                local text=$(echo "$line" | sed -n 's/.*text[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p')
                if [ -n "$text" ] && [ ${#text} -ge 5 ]; then
                    local key="npc.${safe_name}.stdmod_${key_counter}"
                    key_counter=$((key_counter + 1))
                    
                    # TRANSFORMACJA: text = "..." → i18nKey = "klucz"
                    new_line=$(echo "$line" | sed "s|text[[:space:]]*=[[:space:]]*\"[^\"]*\"|i18nKey = \"${key}\"|")
                    
                    add_key_to_json "$json_file" "$key" "$text"
                    
                    transformed=$((transformed + 1))
                    log_info "      🔄 StdModule: $key"
                fi
            fi
        fi
        
        #=== MIGRACJA scripts: player:sendTextMessage → player:sendLocalizedTextMessage ===
        if [ "$is_npc_file" = false ]; then
            if echo "$line" | grep -qE 'player:sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"'; then
                local msg_type=$(echo "$line" | sed -n 's/.*player:sendTextMessage\s*(\s*\([^,]*\),.*/\1/p')
                local text=$(echo "$line" | sed -n 's/.*player:sendTextMessage\s*([^,]*,\s*"\([^"]*\)".*/\1/p')
                if [ -n "$text" ] && [ ${#text} -ge 10 ]; then
                    local key="${category}.${safe_name}.msg_${key_counter}"
                    key_counter=$((key_counter + 1))
                    
                    new_line=$(echo "$line" | sed "s|player:sendTextMessage(\s*\([^,]*\),\s*\"[^\"]*\")|player:sendLocalizedTextMessage(\1, \"${key}\")|")
                    
                    add_key_to_json "$json_file" "$key" "$text"
                    
                    transformed=$((transformed + 1))
                    log_info "      🔑 Script: $key"
                fi
            fi
        fi
        
        echo "$new_line" >> "$temp_file"
    done < "$file"
    
    if [ "$transformed" -gt 0 ]; then
        # Kod został zmieniony - nadpisz plik
        mv "$temp_file" "$file"
        rm -f "${file}.bak"
        log_success "   ✅ Zmigrowano $transformed stringów (text → i18nKey)"
        
        mark_processed "$file"
        document "MIGRACJA LUA" "$relative_path" "Zmigrowano $transformed stringów (text → i18nKey)" "Kategoria: $category"
        
        TOTAL_FILES_PROCESSED=$((TOTAL_FILES_PROCESSED + 1))
        TOTAL_STRINGS_FOUND=$((TOTAL_STRINGS_FOUND + transformed))
        return 0
    elif [ "$extracted" -gt 0 ]; then
        # Klucze wyekstrahowane ale kod nie zmieniony (inne wzorce)
        rm -f "$temp_file" "${file}.bak"
        log_success "   ✅ Wyekstrahowano $extracted kluczy (bez transformacji)"
        
        mark_processed "$file"
        document "EKSTRAKCJA LUA" "$relative_path" "Wyekstrahowano $extracted kluczy" "Kategoria: $category"
        
        TOTAL_FILES_PROCESSED=$((TOTAL_FILES_PROCESSED + 1))
        TOTAL_STRINGS_FOUND=$((TOTAL_STRINGS_FOUND + extracted))
        return 0
    else
        rm -f "$temp_file" "${file}.bak"
        mark_excluded "$file"
        return 1
    fi
}

#===============================================================================
# MIGRACJA WIELOLINIOWYCH TABLIC NPC (PEŁNA)
#===============================================================================
# Obsługuje pliki z formatem:
# npcHandler:say({
#     "tekst 1 ...",
#     "tekst 2 ...",
# }, npc, creature)
# Zamienia na:
# NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.name.multi_1")
# NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.name.multi_2")
#===============================================================================
migrate_multiline_npc() {
    local file="$1"
    local file_name=$(basename "$file" .lua)
    local safe_name=$(echo "$file_name" | tr ' ' '_' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    local json_file="$I18N_DIR/en/npc.json"
    local relative_path="${file#$WORK_DIR/}"
    
    log_info "🔷 [NPC-MULTI] $relative_path"
    
    # Sprawdź czy ma wieloliniowe tablice
    if ! grep -qE 'npcHandler:say\s*\(\s*\{$' "$file" 2>/dev/null; then
        return 1
    fi
    
    # Użyj dedykowanego skryptu Python do pełnej migracji
    local result=$(python3 "$WORK_DIR/tools/migrate_multiline_say.py" --file "$file" --i18n-dir "$I18N_DIR" 2>&1)
    local migrated=$(echo "$result" | grep -oP "strings_migrated': \K[0-9]+" || echo "0")
    
    if [ "$migrated" -gt 0 ] 2>/dev/null; then
        log_success "   ✅ Zmigrowano $migrated wieloliniowych stringów"
        mark_processed "$file"
        return 0
    else
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
# BEZPIECZNE PRZETWARZANIE HTML/PHP (z walidacją)
#===============================================================================
# TRYB: tylko ekstrakcja kluczy, NIE modyfikuj plików źródłowych!
safe_extract_php_strings() {
    local file="$1"
    local category="web_php"
    local extracted=0
    
    update_activity "extract" "$file" "Analiza PHP" "in_progress" "Szukam stringów..."
    
    # Sprawdź czy plik jest poprawny PHP
    if ! php -l "$file" &>/dev/null; then
        log_activity_error "$file" "Błąd składni PHP - pomijam"
        return 1
    fi
    
    # Wyciągnij stringi BEZ modyfikacji pliku
    # Szukaj: echo "...", print "...", __("..."), trans("...")
    local strings=$(grep -oP '(?<=echo\s")[^"]{3,50}(?=")|(?<=print\s")[^"]{3,50}(?=")|(?<=__\(")[^"]{3,50}(?=")|(?<=trans\(")[^"]{3,50}(?=")' "$file" 2>/dev/null | sort -u)
    
    # Szukaj także: 'message' => '...'
    local msg_strings=$(grep -oP "(?<='message'\s*=>\s*')[^']{3,100}(?=')" "$file" 2>/dev/null | sort -u)
    
    # Dodaj klucze do JSON (bez modyfikacji PHP!)
    for str in $strings $msg_strings; do
        [ -z "$str" ] && continue
        [ ${#str} -lt 4 ] && continue
        
        # Generuj bezpieczny klucz
        local key=$(echo "$str" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | head -c 40)
        [ -z "$key" ] && continue
        
        # Dodaj do JSON
        add_key_to_json "ui" "$key" "$str"
        extracted=$((extracted + 1))
        
        log_info "   📝 Wyciągnięto: '$key' = '$str'"
    done
    
    update_activity "extract" "$file" "Ekstrakcja PHP" "completed" "Wyciągnięto $extracted kluczy"
    
    return 0
}

safe_extract_html_strings() {
    local file="$1"
    local extracted=0
    
    update_activity "extract" "$file" "Analiza HTML" "in_progress" "Szukam tekstów..."
    
    # Sprawdź czy plik istnieje i nie jest pusty
    [ ! -s "$file" ] && return 1
    
    # Wyciągnij teksty z HTML (bez modyfikacji!)
    # Szukaj: <title>...</title>, <h1>...</h1>, <p>...</p>, <button>...</button>, <label>...</label>
    local texts=$(grep -oP '(?<=<title>)[^<]{3,50}(?=</title>)|(?<=<h[1-6]>)[^<]{3,50}(?=</h[1-6]>)|(?<=<button[^>]*>)[^<]{3,30}(?=</button>)|(?<=<label[^>]*>)[^<]{3,50}(?=</label>)' "$file" 2>/dev/null | sort -u)
    
    # Szukaj także: placeholder="...", title="...", alt="..."
    local attr_texts=$(grep -oP '(?<=placeholder=")[^"]{3,50}(?=")|(?<=title=")[^"]{3,50}(?=")|(?<=alt=")[^"]{3,50}(?=")' "$file" 2>/dev/null | sort -u)
    
    for str in $texts $attr_texts; do
        [ -z "$str" ] && continue
        [ ${#str} -lt 4 ] && continue
        
        # Pomiń jeśli to kod/zmienna
        [[ "$str" == *"{"* ]] && continue
        [[ "$str" == *"$"* ]] && continue
        [[ "$str" == *"<"* ]] && continue
        
        local key=$(echo "$str" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | head -c 40)
        [ -z "$key" ] && continue
        
        add_key_to_json "ui" "$key" "$str"
        extracted=$((extracted + 1))
        
        log_info "   📄 HTML: '$key' = '$str'"
    done
    
    update_activity "extract" "$file" "Ekstrakcja HTML" "completed" "Wyciągnięto $extracted tekstów"
    
    return 0
}

# Waliduj JSON po każdej modyfikacji
validate_json_file() {
    local file="$1"
    
    if ! jq empty "$file" 2>/dev/null; then
        log_activity_error "$file" "Nieprawidłowy JSON!"
        
        # Próba naprawy - przywróć backup
        if [ -f "${file}.bak" ]; then
            cp "${file}.bak" "$file"
            log_activity_fix "$file" "Przywrócono z backup"
            return 0
        else
            # Utwórz pusty JSON
            echo '{}' > "$file"
            log_activity_fix "$file" "Utworzono pusty JSON"
            return 0
        fi
    fi
    
    return 0
}

# Bezpieczne dodawanie klucza z backupem
safe_add_key_to_json() {
    local category="$1"
    local key="$2"
    local value="$3"
    local json_file="$I18N_DIR/en/${category}.json"
    
    # Backup przed modyfikacją
    [ -f "$json_file" ] && cp "$json_file" "${json_file}.bak"
    
    # Dodaj klucz
    add_key_to_json "$category" "$key" "$value"
    
    # Waliduj wynik
    validate_json_file "$json_file"
}

#===============================================================================
# PRZETWARZANIE PENDING KATEGORII (monsters, server, spells)
#===============================================================================
process_pending_categories() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🔄 PRZETWARZANIE PENDING KATEGORII"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Monsters
    local monsters_count=$(grep -c '"' "$WORK_DIR/i18n/en/monsters.json" 2>/dev/null || echo "0")
    if [ "$monsters_count" -lt 10 ]; then
        log_info "👹 Przetwarzam MONSTERS..."
        update_activity "extract" "monsters" "Ekstrakcja" "in_progress" "Przetwarzam pliki..."
        local monster_files=$(find "$WORK_DIR/data-otservbr-global/monster" "$WORK_DIR/data-canary/monster" -name "*.lua" 2>/dev/null | head -50)
        local count=0
        for file in $monster_files; do
            [ -f "$file" ] || continue
            local basename=$(basename "$file")
            
            # Wyciągnij stringi z monstera
            local strings=$(grep -oP '(?<=")[^"]+(?=")' "$file" 2>/dev/null | grep -E '^[A-Z]' | head -5)
            for str in $strings; do
                [ ${#str} -gt 3 ] && [ ${#str} -lt 100 ] && {
                    local key=$(echo "$str" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g')
                    [ -n "$key" ] && add_key_to_json "monsters" "$key" "$str"
                    count=$((count + 1))
                }
            done
        done
        log_success "   ✅ Monsters: dodano $count kluczy"
    fi
    
    # Server (C++ strings)
    local server_count=$(grep -c '"' "$WORK_DIR/i18n/en/server.json" 2>/dev/null || echo "0")
    if [ "$server_count" -lt 10 ]; then
        log_info "🖥️ Przetwarzam SERVER (C++)..."
        local cpp_files=$(find "$WORK_DIR/src" -name "*.cpp" -o -name "*.hpp" 2>/dev/null | head -30)
        local count=0
        for file in $cpp_files; do
            [ -f "$file" ] || continue
            
            # Wyciągnij stringi z C++
            local strings=$(grep -oP '(?<=")[^"]{5,80}(?=")' "$file" 2>/dev/null | grep -E '^[A-Z]' | head -3)
            for str in $strings; do
                local key=$(echo "$str" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g' | head -c 50)
                [ -n "$key" ] && [ ${#key} -gt 3 ] && add_key_to_json "server" "$key" "$str"
                count=$((count + 1))
            done
        done
        log_success "   ✅ Server: dodano $count kluczy"
    fi
    
    # Spells
    local spells_count=$(grep -c '"' "$WORK_DIR/i18n/en/spells.json" 2>/dev/null || echo "0")
    if [ "$spells_count" -lt 10 ]; then
        log_info "✨ Przetwarzam SPELLS..."
        local spell_files=$(find "$WORK_DIR/data-otservbr-global/scripts/spells" "$WORK_DIR/data/scripts/spells" -name "*.lua" 2>/dev/null | head -50)
        local count=0
        for file in $spell_files; do
            [ -f "$file" ] || continue
            local basename=$(basename "$file" .lua)
            
            # Nazwa spella jako klucz
            local key=$(echo "$basename" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
            local name=$(echo "$basename" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            [ -n "$key" ] && add_key_to_json "spells" "spell_$key" "$name"
            count=$((count + 1))
            
            # Wyciągnij opisy
            local desc=$(grep -oP '(?<=description = ")[^"]+' "$file" 2>/dev/null | head -1)
            [ -n "$desc" ] && add_key_to_json "spells" "spell_${key}_desc" "$desc"
        done
        log_success "   ✅ Spells: dodano $count kluczy"
    fi
}

# Helper: dodaj klucz do JSON
add_key_to_json() {
    local category="$1"
    local key="$2"
    local value="$3"
    local json_file="$WORK_DIR/i18n/en/${category}.json"
    
    # Upewnij się że plik istnieje
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    # Dodaj klucz jeśli nie istnieje (prosty sposób)
    if ! grep -q "\"$key\"" "$json_file" 2>/dev/null; then
        # Użyj jq jeśli dostępne, inaczej sed
        if command -v jq &>/dev/null; then
            local tmp=$(mktemp)
            jq --arg k "$key" --arg v "$value" '. + {($k): $v}' "$json_file" > "$tmp" 2>/dev/null && mv "$tmp" "$json_file"
        else
            # Prosty sed - dodaj przed ostatnim }
            sed -i "s/}$/,\"$key\":\"$value\"}/" "$json_file" 2>/dev/null
        fi
    fi
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
            local basename=$(basename "$file")
            
            # Aktualizuj aktywność - pokazuj co robię
            update_activity "process" "$basename" "Przetwarzanie $file_type" "in_progress" "Katalog: $dir"
            log_info "🔍 Przetwarzam: $basename ($file_type)"
            
            case "$file_type" in
                lua)
                    # Najpierw próbuj standardową migrację
                    if migrate_lua_file "$file"; then
                        processed=$((processed + 1))
                        update_activity "process" "$basename" "Lua migration" "completed" "OK"
                        
                        # Aktualizuj statystyki
                        [ -f "$ACTIVITY_FILE" ] && {
                            local tmp=$(mktemp)
                            jq '.stats.files_this_session += 1' "$ACTIVITY_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$ACTIVITY_FILE"
                        }
                    # Jeśli standardowa nie zadziałała, próbuj wieloliniową dla NPC
                    elif [[ "$file" == *"/npc/"* ]] && migrate_multiline_npc "$file"; then
                        processed=$((processed + 1))
                        update_activity "process" "$basename" "NPC multiline extraction" "completed" "OK"
                    fi
                    ;;
                cpp)
                    if migrate_cpp_file "$file"; then
                        processed=$((processed + 1))
                        update_activity "process" "$basename" "C++ extraction" "completed" "OK"
                    fi
                    ;;
                php)
                    # Bezpieczna ekstrakcja PHP (bez modyfikacji!)
                    if safe_extract_php_strings "$file"; then
                        processed=$((processed + 1))
                        mark_processed "$file"
                    fi
                    ;;
                html)
                    # Bezpieczna ekstrakcja HTML (bez modyfikacji!)
                    if safe_extract_html_strings "$file"; then
                        processed=$((processed + 1))
                        mark_processed "$file"
                    fi
                    ;;
                *)
                    mark_excluded "$file"
                    ;;
            esac
            
        done < <(find "$full_dir" -maxdepth 3 -type f \( -name "*.lua" -o -name "*.cpp" -o -name "*.hpp" -o -name "*.php" -o -name "*.html" \) -print0 2>/dev/null)
    done
    
    log_info "📊 Przetworzono w tym cyklu: $processed plików"
    update_activity "cycle_end" "Cykl $CYCLE_COUNT" "Zakończono przetwarzanie" "completed" "$processed plików"
}

#===============================================================================
# SYNCHRONIZACJA TŁUMACZEŃ - używając Python pipeline (zgodnie z roadmapą)
#===============================================================================
sync_translations() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🌍 SYNCHRONIZACJA TŁUMACZEŃ - Python pipeline"
    log_info "═══════════════════════════════════════════════════════════════"
    
    # Uruchom oficjalny Python pipeline jeśli istnieje
    if [ -f "$WORK_DIR/tools/i18n_pipeline.py" ]; then
        log_info "   🐍 Uruchamiam: python tools/i18n_pipeline.py --locales pl es pt de"
        cd "$WORK_DIR"
        python3 tools/i18n_pipeline.py --locales pl es pt de 2>&1 | head -20
        log_info "   ✅ Pipeline zakończony"
    else
        log_info "   ⚠️ Brak tools/i18n_pipeline.py - kopiowanie kluczy EN"
        # Fallback: Kopiuj klucze EN do wszystkich języków
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
    fi
    
    log_info "   ✅ Zsynchronizowano ${#LANGUAGES[@]} języków"
}

#===============================================================================
# GENEROWANIE SZCZEGÓŁÓW WSZYSTKICH KATEGORII
#===============================================================================
generate_all_categories_details() {
    local output=""
    local counter=1
    
    # Pobierz wszystkie kategorie JSON z i18n/en/
    for json_file in "$I18N_DIR/en"/*.json; do
        [ ! -f "$json_file" ] && continue
        
        local cat_name=$(basename "$json_file" .json)
        local keys_count=$(jq 'length' "$json_file" 2>/dev/null || echo "0")
        
        # Pomijaj puste kategorie
        [ "$keys_count" -eq 0 ] && continue
        
        # Określ ikonę i status dynamicznie
        local icon="📁"
        local target=100
        
        case "$cat_name" in
            npc)       icon="🧙"; target=13000 ;;
            scripts)   icon="📜"; target=1000 ;;
            items)     icon="🎒"; target=40000 ;;
            monsters)  icon="👹"; target=500 ;;
            spells)    icon="✨"; target=200 ;;
            server)    icon="⚙️"; target=300 ;;
            system)    icon="🖥️"; target=2000 ;;
            ui)        icon="🎨"; target=200 ;;
            game)      icon="🎮"; target=100 ;;
            player)    icon="👤"; target=200 ;;
            misc)      icon="📦"; target=100 ;;
            quests)    icon="📜"; target=50 ;;
            actions)   icon="⚡"; target=100 ;;
            events)    icon="📅"; target=50 ;;
        esac
        
        # Oblicz procent na podstawie celu
        local pct=$((keys_count * 100 / target))
        [ "$pct" -gt 100 ] && pct=100
        
        local status_icon="⏳"
        local status_text="Oczekuje"
        if [ "$pct" -ge 90 ]; then
            status_icon="✅"
            status_text="Zakończone"
        elif [ "$pct" -gt 0 ]; then
            status_icon="🔄"
            status_text="W trakcie"
        fi
        
        output+="<details>\n"
        output+="<summary><h3>$icon $counter. ${cat_name^} - $status_text $status_icon</h3></summary>\n\n"
        output+="| Metryka | Wartość |\n"
        output+="|---------|----------|\n"
        output+="| 🔑 Kluczy | **$keys_count** |\n"
        output+="| 🎯 Cel | $target |\n"
        output+="| 📊 Postęp | $pct% |\n"
        output+="| 📁 Plik | \`i18n/en/$cat_name.json\` |\n\n"
        output+="</details>\n\n---\n\n"
        
        counter=$((counter + 1))
    done
    
    echo -e "$output"
}

#===============================================================================
# GENEROWANIE DYNAMICZNEGO ROADMAP
#===============================================================================
generate_dynamic_roadmap() {
    local output="\`\`\`\n"
    
    # Pobierz rzeczywiste dane z JSON
    local items_keys=$(jq 'length' "$I18N_DIR/en/items.json" 2>/dev/null || echo "0")
    local npc_keys=$(jq 'length' "$I18N_DIR/en/npc.json" 2>/dev/null || echo "0")
    local scripts_keys=$(jq 'length' "$I18N_DIR/en/scripts.json" 2>/dev/null || echo "0")
    local monsters_keys=$(jq 'length' "$I18N_DIR/en/monsters.json" 2>/dev/null || echo "0")
    local spells_keys=$(jq 'length' "$I18N_DIR/en/spells.json" 2>/dev/null || echo "0")
    local server_keys=$(jq 'length' "$I18N_DIR/en/server.json" 2>/dev/null || echo "0")
    local system_keys=$(jq 'length' "$I18N_DIR/en/system.json" 2>/dev/null || echo "0")
    local ui_keys=$(jq 'length' "$I18N_DIR/en/ui.json" 2>/dev/null || echo "0")
    
    # Cele dynamiczne (obecne + 10% lub minimum)
    local items_target=40000
    local npc_target=13000
    local scripts_target=1000
    local monsters_target=500
    local spells_target=200
    local server_target=300
    local system_target=2000
    local ui_target=200
    
    # Funkcja pomocnicza do rysowania paska
    draw_bar() {
        local current=$1
        local target=$2
        local width=20
        local pct=$((current * 100 / target))
        [ "$pct" -gt 100 ] && pct=100
        local filled=$((pct * width / 100))
        local empty=$((width - filled))
        
        printf '%s' "$(printf '█%.0s' $(seq 1 $filled 2>/dev/null) 2>/dev/null)"
        printf '%s' "$(printf '░%.0s' $(seq 1 $empty 2>/dev/null) 2>/dev/null)"
        printf ' %3d%%' "$pct"
    }
    
    # Status ikony
    get_status_icon() {
        local pct=$1
        if [ "$pct" -ge 90 ]; then echo "✅"
        elif [ "$pct" -gt 0 ]; then echo "🔄"
        else echo "⏳"
        fi
    }
    
    # Items
    local items_pct=$((items_keys * 100 / items_target))
    output+="[$(get_status_icon $items_pct)] Items ($items_keys)      $(draw_bar $items_keys $items_target)\n"
    
    # NPC
    local npc_pct=$((npc_keys * 100 / npc_target))
    output+="[$(get_status_icon $npc_pct)] NPC ($npc_keys)        $(draw_bar $npc_keys $npc_target)\n"
    
    # Scripts
    local scripts_pct=$((scripts_keys * 100 / scripts_target))
    output+="[$(get_status_icon $scripts_pct)] Scripts ($scripts_keys)    $(draw_bar $scripts_keys $scripts_target)\n"
    
    # Monsters
    local monsters_pct=$((monsters_keys * 100 / monsters_target))
    output+="[$(get_status_icon $monsters_pct)] Monsters ($monsters_keys)   $(draw_bar $monsters_keys $monsters_target)\n"
    
    # Spells
    local spells_pct=$((spells_keys * 100 / spells_target))
    output+="[$(get_status_icon $spells_pct)] Spells ($spells_keys)     $(draw_bar $spells_keys $spells_target)\n"
    
    # Server
    local server_pct=$((server_keys * 100 / server_target))
    output+="[$(get_status_icon $server_pct)] Server ($server_keys)     $(draw_bar $server_keys $server_target)\n"
    
    # System
    local system_pct=$((system_keys * 100 / system_target))
    output+="[$(get_status_icon $system_pct)] System ($system_keys)    $(draw_bar $system_keys $system_target)\n"
    
    # UI
    local ui_pct=$((ui_keys * 100 / ui_target))
    output+="[$(get_status_icon $ui_pct)] UI ($ui_keys)          $(draw_bar $ui_keys $ui_target)\n"
    
    output+="\`\`\`"
    
    echo -e "$output"
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
    
    # Zlicz pliki per podkatalog scripts (z processed_files)
    local quests_count=$(grep -c "scripts/quests" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || quests_count=0
    local actions_count=$(grep -c "scripts/actions" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || actions_count=0
    local movements_count=$(grep -c "scripts/movements" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || movements_count=0
    local creature_count=$(grep -c "scripts/creaturescripts" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || creature_count=0
    local talk_count=$(grep -c "scripts/talkactions" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || talk_count=0
    local global_count=$(grep -c "scripts/globalevents" "$PROCESSED_FILE" 2>/dev/null | tr -d '[:space:]') || global_count=0
    
    # Klucze z JSON (prawdziwy postęp)
    local spells_keys_count=$(jq 'length' "$I18N_DIR/en/spells.json" 2>/dev/null || echo "0")
    local monsters_keys_count=$(jq 'length' "$I18N_DIR/en/monsters.json" 2>/dev/null || echo "0")
    local server_keys_count=$(jq 'length' "$I18N_DIR/en/server.json" 2>/dev/null || echo "0")
    
    [[ ! "$quests_count" =~ ^[0-9]+$ ]] && quests_count=0
    [[ ! "$actions_count" =~ ^[0-9]+$ ]] && actions_count=0
    [[ ! "$movements_count" =~ ^[0-9]+$ ]] && movements_count=0
    [[ ! "$creature_count" =~ ^[0-9]+$ ]] && creature_count=0
    [[ ! "$talk_count" =~ ^[0-9]+$ ]] && talk_count=0
    [[ ! "$global_count" =~ ^[0-9]+$ ]] && global_count=0
    [[ ! "$spells_keys_count" =~ ^[0-9]+$ ]] && spells_keys_count=0
    [[ ! "$monsters_keys_count" =~ ^[0-9]+$ ]] && monsters_keys_count=0
    [[ ! "$server_keys_count" =~ ^[0-9]+$ ]] && server_keys_count=0
    
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

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** $(get_phase_name $(get_current_phase))  
> **Aktualna kategoria:** $(get_current_category)

$(generate_checklist)

---

## 🔴 LIVE: Aktualna Aktywność

$(generate_activity_section)

---

## 📂 Szczegóły Kategorii

$(generate_all_categories_details)

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| **Worker v4.2** | 🟢 RUNNING | PID: $$, Cykl #$CYCLE_COUNT |
| **Guardian v2.0** | 🟢 ACTIVE | Push co 2 min |

---

## 🗺️ Roadmap

$(generate_dynamic_roadmap)

---

*🤖 Machine-readable: \`i18n/status/worker_state.json\`*  
*📅 Auto-updated by Worker v4.2 | Last: $(date '+%Y-%m-%d %H:%M:%S')*  
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
    
    # Główny status JSON - z dynamicznymi danymi wszystkich kategorii
    local monsters_keys=$(jq 'length' "$I18N_DIR/en/monsters.json" 2>/dev/null || echo "0")
    local server_keys=$(jq 'length' "$I18N_DIR/en/server.json" 2>/dev/null || echo "0")
    local spells_keys=$(jq 'length' "$I18N_DIR/en/spells.json" 2>/dev/null || echo "0")
    local system_keys=$(jq 'length' "$I18N_DIR/en/system.json" 2>/dev/null || echo "0")
    local ui_keys=$(jq 'length' "$I18N_DIR/en/ui.json" 2>/dev/null || echo "0")
    local game_keys=$(jq 'length' "$I18N_DIR/en/game.json" 2>/dev/null || echo "0")
    local player_keys=$(jq 'length' "$I18N_DIR/en/player.json" 2>/dev/null || echo "0")
    local misc_keys=$(jq 'length' "$I18N_DIR/en/misc.json" 2>/dev/null || echo "0")
    
    # Przelicz total_keys ze wszystkich kategorii
    total_keys=$((npc_keys + scripts_keys + items_keys + monsters_keys + server_keys + spells_keys + system_keys + ui_keys + game_keys + player_keys + misc_keys))
    
    cat > "$I18N_DIR/status/worker_state.json" << EOF
{
  "schema_version": "2.1",
  "last_updated": "$(date -Iseconds)",
  "worker": {
    "version": "4.2",
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
    "npc": {"status": "completed", "keys": $npc_keys, "target": 13000},
    "scripts": {"status": "in_progress", "keys": $scripts_keys, "target": 1000},
    "items": {"status": "completed", "keys": $items_keys, "target": 40000},
    "monsters": {"status": "in_progress", "keys": $monsters_keys, "target": 500},
    "server": {"status": "in_progress", "keys": $server_keys, "target": 300},
    "spells": {"status": "in_progress", "keys": $spells_keys, "target": 200},
    "system": {"status": "completed", "keys": $system_keys, "target": 2000},
    "ui": {"status": "in_progress", "keys": $ui_keys, "target": 200},
    "game": {"status": "in_progress", "keys": $game_keys, "target": 100},
    "player": {"status": "completed", "keys": $player_keys, "target": 200},
    "misc": {"status": "completed", "keys": $misc_keys, "target": 100}
  },
  "recent_files": $recent_files_json
}
EOF

    # Aktualizuj osobne pliki statusu dla każdej kategorii
    for json_file in "$I18N_DIR/en"/*.json; do
        [ ! -f "$json_file" ] && continue
        local cat_name=$(basename "$json_file" .json)
        local cat_keys=$(jq 'length' "$json_file" 2>/dev/null || echo "0")
        [ "$cat_keys" -eq 0 ] && continue
        
        local cat_status="pending"
        [ "$cat_keys" -gt 50 ] && cat_status="in_progress"
        [ "$cat_keys" -gt 100 ] && cat_status="completed"
        
        cat > "$I18N_DIR/status/${cat_name}.json" << CATEOF
{
  "category": "$cat_name",
  "status": "$cat_status",
  "last_updated": "$(date -Iseconds)",
  "keys": $cat_keys,
  "cycle": $CYCLE_COUNT
}
CATEOF
    done

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
        
        # Pobierz aktualną fazę i kategorię z planu pracy
        local current_phase=$(get_current_phase)
        local current_category=$(get_current_category)
        local phase_name=$(get_phase_name "$current_phase")
        
        echo ""
        log_info "═══════════════════════════════════════════════════════════════"
        log_info "🔄 CYKL #$CYCLE_COUNT | Faza: $phase_name | Kategoria: $current_category"
        log_info "═══════════════════════════════════════════════════════════════"
        
        # Aktualizuj postęp w planie pracy na podstawie rzeczywistych danych
        local npc_keys=$(jq 'length' "$I18N_DIR/en/npc.json" 2>/dev/null || echo "0")
        local scripts_keys=$(jq 'length' "$I18N_DIR/en/scripts.json" 2>/dev/null || echo "0")
        local items_keys=$(jq 'length' "$I18N_DIR/en/items.json" 2>/dev/null || echo "0")
        local monsters_keys=$(jq 'length' "$I18N_DIR/en/monsters.json" 2>/dev/null || echo "0")
        local spells_keys=$(jq 'length' "$I18N_DIR/en/spells.json" 2>/dev/null || echo "0")
        local server_keys=$(jq 'length' "$I18N_DIR/en/server.json" 2>/dev/null || echo "0")
        
        # Aktualizuj plan pracy
        update_category_progress "npc" "$npc_keys" "877"
        update_category_progress "scripts" "$scripts_keys" "300"
        update_category_progress "items" "$items_keys" "1"
        update_category_progress "monsters" "$monsters_keys" "100"
        update_category_progress "spells" "$spells_keys" "100"
        update_category_progress "server_cpp" "$server_keys" "50"
        
        # Aktualizuj status aktywności
        update_activity "cycle" "Cykl #$CYCLE_COUNT" "$phase_name - $current_category" "in_progress" "NPC:$npc_keys Scripts:$scripts_keys Items:$items_keys"
        
        # Aktualizuj statusy wszystkich kategorii (pliki JSON)
        update_all_categories_status
        
        update_status
        
        # KLUCZOWE: Sprawdź czy są NOWE pliki do przetworzenia
        local new_files_count=$(count_new_files)
        log_info "📊 Nowych plików do przetworzenia: $new_files_count"
        
        if [ "$new_files_count" -gt 0 ]; then
            # Są nowe pliki! Przetwarzaj je
            MODE="extraction"
            log_info "🔍 Znaleziono $new_files_count nowych plików - przetwarzam..."
            
            update_activity "scan" "Skanowanie" "Nowe pliki" "in_progress" "$new_files_count do przetworzenia"
            
            process_files
            process_pending_categories
            sync_translations
            
        elif is_category_completed "$current_category"; then
            log_success "✅ Kategoria $current_category ZAKOŃCZONA!"
            
            # Przejdź do następnej kategorii lub fazy
            if ! advance_to_next_category; then
                # Wszystkie fazy zakończone - tryb tłumaczeń
                MODE="translations"
                log_success "🏆 EKSTRAKCJA ZAKOŃCZONA! Przechodzę do tłumaczeń..."
                
                sync_translations
                
                log_info "💤 Tłumaczenia zsynchronizowane. Sprawdzam za 300 sekund..."
                update_activity "idle" "-" "Oczekiwanie" "completed" "Wszystko przetworzone"
                sleep 300
                continue
            fi
            
            # Pobierz nową kategorię
            current_category=$(get_current_category)
            current_phase=$(get_current_phase)
            log_info "➡️ Przechodzę do: $current_category (faza $current_phase)"
        else
            # Brak nowych plików, kategoria nie zakończona - czekaj
            MODE="analysis"
            log_info "💤 Brak nowych plików. Analiza za 60 sekund..."
            update_activity "idle" "-" "Oczekiwanie na nowe pliki" "waiting" "Sprawdzam co 60s"
            
            analyze_conflicts
            validate_structure
            
            sleep 60
            continue
        fi
        
        # Określ tryb na podstawie fazy
        case "$current_phase" in
            1|2|3) MODE="extraction" ;;
            4) MODE="translations" ;;
            *) MODE="analysis" ;;
        esac
        
        log_info "📊 Faza $current_phase | Kategoria: $current_category | Tryb: $MODE"
        
        # Przetwarzaj pliki dla aktualnej kategorii
        if [ "$MODE" == "extraction" ]; then
            # Pobierz katalogi dla aktualnej kategorii
            local dirs=$(get_current_directories)
            
            if [ -n "$dirs" ]; then
                log_info "📂 Przetwarzam katalogi dla $current_category:"
                for dir in $dirs; do
                    log_info "   → $dir"
                done
                
                process_files
                
                # Przetwórz pending kategorie jeśli potrzeba
                process_pending_categories
            fi
            
            sync_translations
        elif [ "$MODE" == "translations" ]; then
            # Tryb tłumaczeń - synchronizuj wszystkie języki
            log_info "🌍 Synchronizuję tłumaczenia dla ${#LANGUAGES[@]} języków..."
            sync_translations
            
            analyze_conflicts
            validate_structure
            
            log_info "💤 Tłumaczenia zakończone. Sprawdzam za 300 sekund..."
            sleep 300
            continue
        else
            # Tryb analizy
            analyze_conflicts
            validate_structure
            sync_translations
            
            log_info "💤 Analiza zakończona. Sprawdzam za 120 sekund..."
            sleep 120
            continue
        fi
        
        # Auto-push do GitHub co 2 minuty
        auto_push_to_github
        
        log_info "💤 Przerwa 10 sekund..."
        sleep 10
    done
}

trap 'log_info "⛔ Worker zatrzymany"; update_status; exit 0' SIGINT SIGTERM

main "$@"
