#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N LOGGER - Zaawansowany system logowania
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
LOG_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test/logs/i18n"
LOG_LEVEL=${LOG_LEVEL:-"INFO"}  # DEBUG, INFO, WARN, ERROR, FATAL
LOG_MAX_SIZE=$((10 * 1024 * 1024))  # 10MB
LOG_MAX_FILES=10
LOG_TO_CONSOLE=${LOG_TO_CONSOLE:-true}
LOG_TO_FILE=${LOG_TO_FILE:-true}

# Pliki logów
LOG_FILE_MAIN="$LOG_DIR/worker.log"
LOG_FILE_ERROR="$LOG_DIR/errors.log"
LOG_FILE_DEBUG="$LOG_DIR/debug.log"
LOG_FILE_GIT="$LOG_DIR/git.log"
LOG_FILE_GUARDIAN="$LOG_DIR/guardian.log"

# Discord webhook (opcjonalnie)
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL:-""}
DISCORD_NOTIFY_LEVELS="ERROR,FATAL"

# === KOLORY ===
declare -A LOG_COLORS=(
    ["DEBUG"]="\033[0;37m"     # Szary
    ["INFO"]="\033[0;34m"      # Niebieski
    ["SUCCESS"]="\033[0;32m"   # Zielony
    ["WARN"]="\033[1;33m"      # Żółty
    ["ERROR"]="\033[0;31m"     # Czerwony
    ["FATAL"]="\033[1;31m"     # Jasny czerwony
)
NC="\033[0m"

# === POZIOMY LOGOWANIA ===
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["SUCCESS"]=1
    ["WARN"]=2
    ["ERROR"]=3
    ["FATAL"]=4
)

# === FUNKCJE ===

# Inicjalizacja systemu logowania
init_logging() {
    mkdir -p "$LOG_DIR"
    
    # Utwórz pliki jeśli nie istnieją
    touch "$LOG_FILE_MAIN" "$LOG_FILE_ERROR" "$LOG_FILE_DEBUG" "$LOG_FILE_GIT" "$LOG_FILE_GUARDIAN"
    
    # Rotacja logów przy starcie
    rotate_logs
    
    log "INFO" "SYSTEM" "System logowania zainicjalizowany"
}

# Rotacja logów
rotate_logs() {
    for log_file in "$LOG_FILE_MAIN" "$LOG_FILE_ERROR" "$LOG_FILE_DEBUG" "$LOG_FILE_GIT" "$LOG_FILE_GUARDIAN"; do
        if [[ -f "$log_file" ]]; then
            local size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo 0)
            
            if [[ $size -gt $LOG_MAX_SIZE ]]; then
                # Przesuń stare logi
                for ((i = LOG_MAX_FILES - 1; i >= 1; i--)); do
                    local prev=$((i - 1))
                    [[ -f "${log_file}.$prev" ]] && mv "${log_file}.$prev" "${log_file}.$i"
                done
                
                # Zarchiwizuj aktualny
                mv "$log_file" "${log_file}.0"
                touch "$log_file"
                
                log "DEBUG" "LOGGER" "Rotacja logu: $log_file"
            fi
        fi
    done
}

# Sprawdź czy poziom powinien być logowany
should_log() {
    local level="$1"
    local configured_level=${LOG_LEVELS[$LOG_LEVEL]:-1}
    local message_level=${LOG_LEVELS[$level]:-1}
    
    [[ $message_level -ge $configured_level ]]
}

# Formatowanie wiadomości
format_message() {
    local level="$1"
    local component="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [$level] [$component] $message"
}

# Główna funkcja logowania
log() {
    local level="${1:-INFO}"
    local component="${2:-MAIN}"
    local message="$3"
    
    # Sprawdź czy logować
    if ! should_log "$level"; then
        return
    fi
    
    local formatted=$(format_message "$level" "$component" "$message")
    
    # Log do konsoli
    if [[ "$LOG_TO_CONSOLE" == true ]]; then
        local color="${LOG_COLORS[$level]:-$NC}"
        echo -e "${color}${formatted}${NC}"
    fi
    
    # Log do pliku
    if [[ "$LOG_TO_FILE" == true ]]; then
        echo "$formatted" >> "$LOG_FILE_MAIN"
        
        # Błędy dodatkowo do errors.log
        if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
            echo "$formatted" >> "$LOG_FILE_ERROR"
        fi
        
        # Debug do debug.log
        if [[ "$level" == "DEBUG" ]]; then
            echo "$formatted" >> "$LOG_FILE_DEBUG"
        fi
    fi
    
    # Powiadomienia Discord
    if [[ -n "$DISCORD_WEBHOOK_URL" && "$DISCORD_NOTIFY_LEVELS" == *"$level"* ]]; then
        send_discord_notification "$level" "$component" "$message"
    fi
    
    # Rotacja jeśli potrzebna
    rotate_logs
}

# Specjalizowane funkcje logowania
log_debug() { log "DEBUG" "$1" "$2"; }
log_info() { log "INFO" "$1" "$2"; }
log_success() { log "SUCCESS" "$1" "$2"; }
log_warn() { log "WARN" "$1" "$2"; }
log_error() { log "ERROR" "$1" "$2"; }
log_fatal() { log "FATAL" "$1" "$2"; }

# Logowanie dla Guardian
log_guardian() {
    local level="$1"
    local message="$2"
    local formatted=$(format_message "$level" "GUARDIAN" "$message")
    echo "$formatted" >> "$LOG_FILE_GUARDIAN"
    log "$level" "GUARDIAN" "$message"
}

# Logowanie dla Git
log_git() {
    local level="$1"
    local message="$2"
    local formatted=$(format_message "$level" "GIT" "$message")
    echo "$formatted" >> "$LOG_FILE_GIT"
    log "$level" "GIT" "$message"
}

# Wysyłanie powiadomienia Discord
send_discord_notification() {
    local level="$1"
    local component="$2"
    local message="$3"
    
    local color
    case "$level" in
        "ERROR")  color=15158332 ;;  # Czerwony
        "FATAL")  color=10038562 ;;  # Ciemny czerwony
        "WARN")   color=15105570 ;;  # Pomarańczowy
        *)        color=3447003 ;;   # Niebieski
    esac
    
    local payload=$(cat << EOF
{
    "embeds": [{
        "title": "🚨 I18N Worker Alert",
        "description": "$message",
        "color": $color,
        "fields": [
            {"name": "Level", "value": "$level", "inline": true},
            {"name": "Component", "value": "$component", "inline": true}
        ],
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }]
}
EOF
)
    
    curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$DISCORD_WEBHOOK_URL" &>/dev/null &
}

# Logowanie z kontekstem (stack trace)
log_with_context() {
    local level="$1"
    local component="$2"
    local message="$3"
    
    # Pobierz stack trace
    local stack=""
    local frame=0
    while caller $frame; do
        ((frame++))
    done 2>/dev/null | while read -r line func file; do
        stack+="  at $func ($file:$line)\n"
    done
    
    log "$level" "$component" "$message"
    if [[ -n "$stack" && "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        echo -e "Stack trace:\n$stack" >> "$LOG_FILE_ERROR"
    fi
}

# Metryki czasu wykonania
declare -A TIMERS

timer_start() {
    local name="$1"
    TIMERS["$name"]=$(date +%s%3N)
}

timer_stop() {
    local name="$1"
    local start=${TIMERS["$name"]:-$(date +%s%3N)}
    local end=$(date +%s%3N)
    local duration=$((end - start))
    
    log_debug "TIMER" "$name completed in ${duration}ms"
    unset TIMERS["$name"]
    
    echo $duration
}

# Podsumowanie logów
log_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    PODSUMOWANIE LOGÓW"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    for log_file in "$LOG_FILE_MAIN" "$LOG_FILE_ERROR"; do
        if [[ -f "$log_file" ]]; then
            local errors=$(grep -c '\[ERROR\]' "$log_file" 2>/dev/null || echo 0)
            local warnings=$(grep -c '\[WARN\]' "$log_file" 2>/dev/null || echo 0)
            local size=$(du -h "$log_file" | cut -f1)
            
            echo "📄 $(basename "$log_file")"
            echo "   Rozmiar: $size"
            echo "   Błędy: $errors"
            echo "   Ostrzeżenia: $warnings"
            echo ""
        fi
    done
}

# === CLI ===

main() {
    case "$1" in
        init)
            init_logging
            ;;
        tail)
            tail -f "$LOG_FILE_MAIN"
            ;;
        errors)
            tail -f "$LOG_FILE_ERROR"
            ;;
        summary)
            log_summary
            ;;
        clear)
            read -p "Czy na pewno usunąć wszystkie logi? [y/N]: " confirm
            if [[ "${confirm,,}" == "y" ]]; then
                rm -f "$LOG_DIR"/*.log*
                echo "Logi usunięte"
            fi
            ;;
        test)
            init_logging
            log_debug "TEST" "To jest debug"
            log_info "TEST" "To jest info"
            log_success "TEST" "To jest success"
            log_warn "TEST" "To jest warning"
            log_error "TEST" "To jest error"
            log_summary
            ;;
        *)
            echo "I18N Logger - System logowania"
            echo ""
            echo "Użycie: $0 {init|tail|errors|summary|clear|test}"
            echo ""
            echo "Jako biblioteka:"
            echo "  source i18n_logger.sh"
            echo "  init_logging"
            echo "  log \"INFO\" \"COMPONENT\" \"Message\""
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
