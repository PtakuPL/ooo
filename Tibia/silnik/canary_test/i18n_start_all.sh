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
pid_matches_name() {
    local pid="$1" name="$2"
    [[ "$pid" =~ ^[0-9]+$ ]] || return 1
    ps -p "$pid" >/dev/null 2>&1 || return 1
    [ -r "/proc/$pid/cmdline" ] || return 1
    local cmdline
    cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || echo "")
    [ -n "$cmdline" ] || return 1
    [[ "$cmdline" == *"$name"* ]] || return 1
    [[ "$cmdline" == *"pgrep "* ]] && return 1
    [[ "$cmdline" == *"i18n_start_all.sh"* ]] && return 1
    return 0
}

is_running() {
    local pidfile="$1" name="$2"
    if [[ -f "$pidfile" ]]; then
        local pid
        pid=$(cat "$pidfile" 2>/dev/null || echo "")
        if pid_matches_name "$pid" "$name"; then
            echo "$pid"
            return 0
        fi
        rm -f "$pidfile" 2>/dev/null || true
    fi

    # Fallback: szukamy procesu po cmdline i dodatkowo walidujemy /proc/<pid>/cmdline
    # Unikamy self-match: $$ (ten shell), $PPID, $BASHPID, oraz procesy grep/pgrep
    local candidate self_pids
    self_pids=("$$" "$PPID" "${BASHPID:-}")
    while read -r candidate; do
        [[ -n "${candidate:-}" ]] || continue
        local skip=0
        for sp in "${self_pids[@]}"; do
            [[ "$candidate" = "$sp" ]] && skip=1 && break
        done
        [[ "$skip" = "1" ]] && continue
        if pid_matches_name "$candidate" "$name"; then
            echo "$candidate"
            return 0
        fi
    done < <(pgrep -f "$name" -u "$(whoami)" 2>/dev/null | grep -v "^$$\$" || true)

    return 1
}

wait_for_stable_process() {
    local pidfile="$1" name="$2"
    local min_consecutive="${3:-3}" max_wait_sec="${4:-12}"
    local stable_hits=0 waited=0 pid
    while (( waited < max_wait_sec )); do
        pid=$(is_running "$pidfile" "$name") || pid=""
        if [[ -n "$pid" ]]; then
            stable_hits=$((stable_hits + 1))
            if (( stable_hits >= min_consecutive )); then
                echo "$pid"
                return 0
            fi
        else
            stable_hits=0
        fi
        sleep 1
        waited=$((waited + 1))
    done
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
    pid=$(wait_for_stable_process "$GUARDIAN_PID_FILE" "i18n_guardian.sh --daemon" 3 12) || true
    if [[ -n "$pid" ]]; then
        log "✅  Guardian uruchomiony (pid=$pid, source=start_all)"
    else
        log "❌  Guardian nie potwierdził startu"
        if [[ -f "$WORK_DIR/guardian.log" ]]; then
            log "↳ Ostatnie logi guardian:"
            tail -n 20 "$WORK_DIR/guardian.log" | sed 's/^/[guardian] /' | tee -a "$LOGFILE" >/dev/null || true
        fi
        return 1
    fi
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
    pid=$(wait_for_stable_process "$STATUSD_PID_FILE" "i18n-statusd.sh --daemon" 3 12) || true
    if [[ -n "$pid" ]]; then
        log "✅  Statusd uruchomiony (pid=$pid)"
    else
        log "❌  Statusd nie potwierdził startu"
        if [[ -f "$WORK_DIR/statusd.log" ]]; then
            log "↳ Ostatnie logi statusd:"
            tail -n 20 "$WORK_DIR/statusd.log" | sed 's/^/[statusd] /' | tee -a "$LOGFILE" >/dev/null || true
        fi
        return 1
    fi
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
        waited=$((waited + 1))
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

    local g_pid s_pid w_count w_pid w_child_count
    g_pid=$(is_running "$GUARDIAN_PID_FILE" "i18n_guardian.sh --daemon") || true
    s_pid=$(is_running "$STATUSD_PID_FILE" "i18n-statusd.sh --daemon") || true
    w_pid=$(cat "$WORK_DIR/.worker_simple.pid" 2>/dev/null || echo "")
    if [[ "$w_pid" =~ ^[0-9]+$ ]] && ps -p "$w_pid" >/dev/null 2>&1; then
        w_child_count=$( { pgrep -P "$w_pid" -f "i18n_worker_simple.sh --continuous" -u "$(whoami)" 2>/dev/null || true; } | wc -l )
    else
        w_pid=""
        w_child_count=0
        w_count=$( { pgrep -f "(^|/)i18n_worker_simple.sh --continuous" -u "$(whoami)" 2>/dev/null || true; } | wc -l )
    fi

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

    if [[ -n "$w_pid" ]]; then
        echo "  Worker:    ✅ RUNNING  (main pid=$w_pid, subprocessy=$w_child_count)"
    else
        echo "  Worker:    ❌ STOPPED  (detected=$w_count)"
    fi

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
        w_pids=$(pgrep -f "(^|/)i18n_worker_simple.sh --continuous" -u "$(whoami)" 2>/dev/null || true)
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
        bash "$WORK_DIR/i18n_start_all.sh" --stop
        sleep 2
        bash "$WORK_DIR/i18n_start_all.sh" start
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
