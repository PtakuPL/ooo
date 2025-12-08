#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N MONITORING - System monitoringu i alertów
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
I18N_DIR="$WORK_DIR/i18n"
METRICS_DIR="$WORK_DIR/metrics/i18n"
METRICS_FILE="$METRICS_DIR/metrics.json"
HISTORY_FILE="$METRICS_DIR/history.json"

# Alerty
DISCORD_WEBHOOK=${DISCORD_WEBHOOK:-""}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-""}
TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID:-""}

# Progi alertów
ALERT_WORKER_DOWN_MINUTES=5
ALERT_COVERAGE_DROP_PERCENT=5
ALERT_NEW_KEYS_THRESHOLD=100
ALERT_ERROR_THRESHOLD=10

# === FUNKCJE ===

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2"
}

# Inicjalizacja
init_monitoring() {
    mkdir -p "$METRICS_DIR"
    
    if [[ ! -f "$METRICS_FILE" ]]; then
        echo '{"last_update": null, "metrics": {}}' > "$METRICS_FILE"
    fi
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo '{"history": []}' > "$HISTORY_FILE"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ZBIERANIE METRYK
# ═══════════════════════════════════════════════════════════════════════════════

# Metryki workera
collect_worker_metrics() {
    local worker_running=false
    local worker_pid=""
    local worker_uptime=0
    
    if pgrep -f "i18n_autonomous_worker" > /dev/null; then
        worker_running=true
        worker_pid=$(pgrep -f "i18n_autonomous_worker" | head -1)
        
        # Oblicz uptime
        if [[ -n "$worker_pid" ]]; then
            local start_time=$(ps -o lstart= -p "$worker_pid" 2>/dev/null)
            if [[ -n "$start_time" ]]; then
                local start_epoch=$(date -d "$start_time" +%s 2>/dev/null)
                local now_epoch=$(date +%s)
                worker_uptime=$((now_epoch - start_epoch))
            fi
        fi
    fi
    
    echo "{\"running\": $worker_running, \"pid\": \"$worker_pid\", \"uptime_seconds\": $worker_uptime}"
}

# Metryki tłumaczeń
collect_translation_metrics() {
    local total_keys=0
    local translated_keys=0
    local languages=0
    local categories=0
    
    # Policz klucze EN
    for json_file in "$I18N_DIR/en"/*.json; do
        if [[ -f "$json_file" ]]; then
            local count=$(jq 'length' "$json_file" 2>/dev/null || echo 0)
            ((total_keys += count))
            ((categories++))
        fi
    done
    
    # Policz języki
    for lang_dir in "$I18N_DIR"/*/; do
        ((languages++))
    done
    
    # Policz przetłumaczone (nie-EN)
    for lang_dir in "$I18N_DIR"/*/; do
        local lang=$(basename "$lang_dir")
        [[ "$lang" == "en" ]] && continue
        
        for json_file in "$lang_dir"/*.json; do
            if [[ -f "$json_file" ]]; then
                # Policz nie-puste wartości
                local count=$(jq '[.[] | select(. != "" and . != null and (startswith("[NEEDS") | not))] | length' "$json_file" 2>/dev/null || echo 0)
                ((translated_keys += count))
            fi
        done
    done
    
    echo "{\"total_keys\": $total_keys, \"translated_keys\": $translated_keys, \"languages\": $languages, \"categories\": $categories}"
}

# Metryki pokrycia według języka
collect_coverage_per_language() {
    local result="{"
    local first=true
    
    # Baseline z EN
    local en_total=0
    for json_file in "$I18N_DIR/en"/*.json; do
        [[ -f "$json_file" ]] && ((en_total += $(jq 'length' "$json_file" 2>/dev/null || echo 0)))
    done
    
    for lang_dir in "$I18N_DIR"/*/; do
        local lang=$(basename "$lang_dir")
        [[ "$lang" == "en" ]] && continue
        
        local lang_total=0
        for json_file in "$lang_dir"/*.json; do
            if [[ -f "$json_file" ]]; then
                local count=$(jq '[.[] | select(. != "" and . != null and (startswith("[NEEDS") | not))] | length' "$json_file" 2>/dev/null || echo 0)
                ((lang_total += count))
            fi
        done
        
        local coverage=0
        [[ $en_total -gt 0 ]] && coverage=$((lang_total * 100 / en_total))
        
        [[ "$first" == "false" ]] && result+=", "
        result+="\"$lang\": $coverage"
        first=false
    done
    
    result+="}"
    echo "$result"
}

# Zbierz wszystkie metryki
collect_all_metrics() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local worker=$(collect_worker_metrics)
    local translations=$(collect_translation_metrics)
    local coverage=$(collect_coverage_per_language)
    
    cat << EOF
{
    "timestamp": "$timestamp",
    "worker": $worker,
    "translations": $translations,
    "coverage_by_language": $coverage
}
EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# ALERTY
# ═══════════════════════════════════════════════════════════════════════════════

# Wyślij alert Discord
send_discord_alert() {
    local title="$1"
    local message="$2"
    local color="${3:-15158332}"  # Czerwony domyślnie
    
    [[ -z "$DISCORD_WEBHOOK" ]] && return
    
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{
            \"embeds\": [{
                \"title\": \"$title\",
                \"description\": \"$message\",
                \"color\": $color,
                \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
            }]
        }" \
        "$DISCORD_WEBHOOK" > /dev/null
    
    log "ALERT" "Discord: $title"
}

# Wyślij alert Telegram
send_telegram_alert() {
    local message="$1"
    
    [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]] && return
    
    curl -s -X POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=HTML" > /dev/null
    
    log "ALERT" "Telegram: $message"
}

# Sprawdź i wyślij alerty
check_alerts() {
    local metrics=$(collect_all_metrics)
    
    # Alert: Worker nie działa
    local worker_running=$(echo "$metrics" | jq -r '.worker.running')
    if [[ "$worker_running" == "false" ]]; then
        send_discord_alert "🚨 I18N Worker Down" "Worker nie działa! Sprawdź serwer." 15158332
        send_telegram_alert "🚨 <b>I18N Worker Down</b>\nWorker nie działa!"
    fi
    
    # Alert: Spadek pokrycia
    if [[ -f "$HISTORY_FILE" ]]; then
        local prev_total=$(jq -r '.history[-1].translations.total_keys // 0' "$HISTORY_FILE")
        local curr_total=$(echo "$metrics" | jq -r '.translations.total_keys')
        
        if [[ $prev_total -gt 0 && $curr_total -lt $((prev_total * (100 - ALERT_COVERAGE_DROP_PERCENT) / 100)) ]]; then
            send_discord_alert "⚠️ Coverage Drop" "Pokrycie spadło z $prev_total do $curr_total kluczy!" 15105570
        fi
    fi
    
    # Alert: Dużo nowych kluczy
    local total_keys=$(echo "$metrics" | jq -r '.translations.total_keys')
    if [[ -f "$HISTORY_FILE" ]]; then
        local prev_keys=$(jq -r '.history[-1].translations.total_keys // 0' "$HISTORY_FILE")
        local new_keys=$((total_keys - prev_keys))
        
        if [[ $new_keys -gt $ALERT_NEW_KEYS_THRESHOLD ]]; then
            send_discord_alert "📈 Many New Keys" "$new_keys nowych kluczy do przetłumaczenia!" 3447003
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# HISTORIA I TRENDY
# ═══════════════════════════════════════════════════════════════════════════════

# Zapisz metryki do historii
save_to_history() {
    local metrics="$1"
    local max_entries=1000
    
    # Dodaj do historii
    local tmp_file=$(mktemp)
    jq --argjson m "$metrics" \
        '.history += [$m] | .history = .history[-'"$max_entries"':]' \
        "$HISTORY_FILE" > "$tmp_file" && mv "$tmp_file" "$HISTORY_FILE"
}

# Generuj raport trendów
generate_trend_report() {
    local days="${1:-7}"
    
    echo "# 📈 I18N Trend Report (Last $days days)"
    echo ""
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo "No history data available"
        return
    fi
    
    # Średnie z ostatnich dni
    local cutoff=$(date -d "-${days} days" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -v-${days}d +%Y-%m-%dT%H:%M:%S)
    
    echo "## Key Statistics"
    echo ""
    jq -r --arg cutoff "$cutoff" '
        .history | 
        map(select(.timestamp > $cutoff)) |
        if length > 0 then
            "- First measurement: \(.[0].timestamp)\n" +
            "- Last measurement: \(.[-1].timestamp)\n" +
            "- Total keys (start): \(.[0].translations.total_keys)\n" +
            "- Total keys (end): \(.[-1].translations.total_keys)\n" +
            "- Change: \(.[-1].translations.total_keys - .[0].translations.total_keys)"
        else
            "No data in timeframe"
        end
    ' "$HISTORY_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════════

# Wyświetl dashboard w terminalu
show_dashboard() {
    clear
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "                    📊 I18N MONITORING DASHBOARD"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    
    local metrics=$(collect_all_metrics)
    
    # Worker status
    local worker_running=$(echo "$metrics" | jq -r '.worker.running')
    local worker_uptime=$(echo "$metrics" | jq -r '.worker.uptime_seconds')
    
    if [[ "$worker_running" == "true" ]]; then
        local uptime_formatted=$(printf '%dd %dh %dm' $((worker_uptime/86400)) $((worker_uptime%86400/3600)) $((worker_uptime%3600/60)))
        echo "🟢 Worker: RUNNING (uptime: $uptime_formatted)"
    else
        echo "🔴 Worker: STOPPED"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "                         TRANSLATION STATS"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    
    local total_keys=$(echo "$metrics" | jq -r '.translations.total_keys')
    local languages=$(echo "$metrics" | jq -r '.translations.languages')
    
    echo "📝 Total Keys: $total_keys"
    echo "🌍 Languages: $languages"
    echo ""
    
    echo "Coverage by language:"
    echo "$metrics" | jq -r '.coverage_by_language | to_entries | sort_by(-.value) | .[] | "  \(.key): \(.value)%"' | head -10
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "Last update: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Ciągły monitoring
watch_mode() {
    while true; do
        show_dashboard
        check_alerts
        
        local metrics=$(collect_all_metrics)
        save_to_history "$metrics"
        
        sleep 60
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    init_monitoring
    
    case "$1" in
        collect)
            collect_all_metrics | jq '.'
            ;;
        dashboard)
            show_dashboard
            ;;
        watch)
            watch_mode
            ;;
        alerts)
            check_alerts
            ;;
        trends)
            generate_trend_report "${2:-7}"
            ;;
        test-alert)
            send_discord_alert "🧪 Test Alert" "This is a test alert from i18n monitoring" 3447003
            send_telegram_alert "🧪 <b>Test Alert</b>\nThis is a test"
            ;;
        *)
            cat << EOF
I18N Monitoring - System monitoringu

Użycie: $0 <command>

Komendy:
  collect     Zbierz i wyświetl metryki
  dashboard   Pokaż dashboard
  watch       Ciągły monitoring (co 60s)
  alerts      Sprawdź i wyślij alerty
  trends [n]  Raport trendów z ostatnich n dni
  test-alert  Wyślij testowy alert

Zmienne środowiskowe:
  DISCORD_WEBHOOK      URL webhooka Discord
  TELEGRAM_BOT_TOKEN   Token bota Telegram
  TELEGRAM_CHAT_ID     ID chatu Telegram
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
