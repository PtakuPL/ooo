#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  i18n_start_all.sh  —  Kanoniczne źródło startu i18n pipeline
# ═══════════════════════════════════════════════════════════════
#
#  Użycie:
#    bash i18n_start_all.sh           # start guardian + statusd
#    bash i18n_start_all.sh --stop    # zatrzymaj wszystkie daemony
#    bash i18n_start_all.sh --status  # pokaż status
#    bash i18n_start_all.sh --restart # restart all
#
#  Guardian sam zarządza workerami (start/restart/health).
#  Ten skrypt to JEDNO ŹRÓDŁO startu — eliminuje duplikaty.
# ═══════════════════════════════════════════════════════════════

set -euo pipefail
WORK_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORK_DIR"

GUARDIAN_SCRIPT="$WORK_DIR/i18n_guardian.sh"
STATUSD_SCRIPT="$WORK_DIR/i18n-statusd.sh"
GUARDIAN_PID_FILE="$WORK_DIR/.guardian.pid"
STATUSD_PID_FILE="$WORK_DIR/.statusd.pid"
LOGFILE="$WORK_DIR/i18n/logs/start_all.log"

mkdir -p "$WORK_DIR/i18n/logs"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

# ── Helpers ──────────────────────────────────────────────────────
is_running() {
    local pidfile="$1" name="$2"
    if [[ -f "$pidfile" ]]; then
        local pid
        pid=$(cat "$pidfile" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null 2>&1; then
            echo "$pid"
            return 0
        fi
    fi
    # Fallback: szukamy procesu po nazwie
    pgrep -f "$name" -u "$(whoami)" 2>/dev/null | head -1 || true
    return 1
}

start_guardian() {
    local pid
    pid=$(is_running "$GUARDIAN_PID_FILE" "i18n_guardian.sh --daemon") || true
    if [[ -n "$pid" ]]; then
        log "⏭️  Guardian już działa (pid=$pid)"
        return 0
    fi
    log "▶️  Startuję Guardian daemon..."
    GUARDIAN_START_SOURCE=start_all nohup bash "$GUARDIAN_SCRIPT" --daemon >> "$WORK_DIR/i18n/logs/guardian.log" 2>&1 &
    sleep 1
    pid=$(cat "$GUARDIAN_PID_FILE" 2>/dev/null || pgrep -f "i18n_guardian.sh --daemon" -u "$(whoami)" | head -1 || echo "?")
    log "✅  Guardian uruchomiony (pid=$pid, source=start_all)"
}

start_statusd() {
    local pid
    pid=$(is_running "$STATUSD_PID_FILE" "i18n-statusd.sh --daemon") || true
    if [[ -n "$pid" ]]; then
        log "⏭️  Statusd już działa (pid=$pid)"
        return 0
    fi
    log "▶️  Startuję Statusd daemon..."
    nohup bash "$STATUSD_SCRIPT" --daemon >> "$WORK_DIR/i18n/logs/statusd.log" 2>&1 &
    sleep 1
    pid=$(cat "$STATUSD_PID_FILE" 2>/dev/null || pgrep -f "i18n-statusd.sh --daemon" -u "$(whoami)" | head -1 || echo "?")
    log "✅  Statusd uruchomiony (pid=$pid)"
}

stop_daemon() {
    local pidfile="$1" name="$2" label="$3"
    local pid
    pid=$(is_running "$pidfile" "$name") || true
    if [[ -z "$pid" ]]; then
        log "⏹️  $label nie działa"
        return 0
    fi
    log "⛔  Zatrzymuję $label (pid=$pid)..."
    kill "$pid" 2>/dev/null || true
    local waited=0
    while ps -p "$pid" >/dev/null 2>&1 && (( waited < 10 )); do
        sleep 1
        (( waited++ ))
    done
    if ps -p "$pid" >/dev/null 2>&1; then
        kill -9 "$pid" 2>/dev/null || true
        log "⚠️  $label wymuszone zamknięcie (SIGKILL)"
    else
        log "✅  $label zatrzymany"
    fi
    rm -f "$pidfile"
}

show_status() {
    echo "═══════════════════════════════════════════════════"
    echo "  i18n Pipeline — Status daemonów"
    echo "═══════════════════════════════════════════════════"

    local g_pid s_pid w_count
    g_pid=$(is_running "$GUARDIAN_PID_FILE" "i18n_guardian.sh --daemon") || true
    s_pid=$(is_running "$STATUSD_PID_FILE" "i18n-statusd.sh --daemon") || true
    w_count=$(pgrep -f "i18n_worker_simple.sh" -u "$(whoami)" 2>/dev/null | wc -l || echo 0)

    if [[ -n "$g_pid" ]]; then
        echo "  Guardian:  ✅ RUNNING  (pid=$g_pid)"
    else
        echo "  Guardian:  ❌ STOPPED"
    fi

    if [[ -n "$s_pid" ]]; then
        echo "  Statusd:   ✅ RUNNING  (pid=$s_pid)"
    else
        echo "  Statusd:   ❌ STOPPED"
    fi

    echo "  Workers:   $w_count instancja(-e)"

    # Coverage snapshot
    if [[ -f "i18n/status/coverage.json" ]]; then
        echo ""
        echo "  Coverage:"
        python3 -c "
import json
with open('i18n/status/coverage.json') as f:
    d = json.load(f)
for lang in sorted(d, key=lambda x: d[x].get('percent', 0), reverse=True)[:6]:
    p = d[lang].get('percent', 0)
    print(f'    {lang:4s}  {p:5.1f}%')
" 2>/dev/null || true
    fi

    echo "═══════════════════════════════════════════════════"
}

# ── Main ─────────────────────────────────────────────────────────
case "${1:-start}" in
    start|"")
        log "═══ i18n_start_all: START ═══"
        start_guardian
        start_statusd
        show_status
        ;;
    --stop|stop)
        log "═══ i18n_start_all: STOP ═══"
        stop_daemon "$STATUSD_PID_FILE" "i18n-statusd.sh --daemon" "Statusd"
        stop_daemon "$GUARDIAN_PID_FILE" "i18n_guardian.sh --daemon" "Guardian"
        # Workers zostaną zatrzymane przez guardian trap lub osobno
        w_pids=$(pgrep -f "i18n_worker_simple.sh" -u "$(whoami)" 2>/dev/null || true)
        if [[ -n "$w_pids" ]]; then
            log "⛔  Zatrzymuję workery..."
            echo "$w_pids" | xargs kill 2>/dev/null || true
            sleep 2
            echo "$w_pids" | xargs kill -9 2>/dev/null || true
            log "✅  Workery zatrzymane"
        fi
        show_status
        ;;
    --restart|restart)
        log "═══ i18n_start_all: RESTART ═══"
        "$0" --stop
        sleep 2
        "$0" start
        ;;
    --status|status)
        show_status
        ;;
    --help|-h)
        echo "Użycie: $0 {start|--stop|--restart|--status}"
        echo ""
        echo "  start      Uruchom Guardian + Statusd (domyślne)"
        echo "  --stop     Zatrzymaj wszystkie daemony i workery"
        echo "  --restart  Restart all"
        echo "  --status   Pokaż status pipeline"
        echo ""
        echo "Guardian sam zarządza workerami (start/restart/health)."
        echo "Ten skrypt to JEDNO ŹRÓDŁO startu — używaj zamiast ręcznego uruchamiania."
        ;;
    *)
        echo "Nieznana opcja: $1 (użyj --help)"
        exit 1
        ;;
esac
