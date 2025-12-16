#!/bin/bash
# Guardian v3.0 - automatyczny restart workera i18n + push do GitHub
# Uruchamiany przez cron co minutę
# Monitoruje i18n_worker_simple.sh w trybie --continuous

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
REPO_ROOT="/home/ptaku/serweryt"
WORKER_SCRIPT="i18n_worker_simple.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker_simple.pid"
GUARDIAN_LOG="$WORK_DIR/guardian.log"
MTIME_FILE="$WORK_DIR/.worker_script_mtime"

# Co ile sekund wykonywać push dashboardu
PUSH_INTERVAL_SECONDS=120
LAST_PUSH_TS_FILE="$WORK_DIR/.guardian_last_push_ts"

export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$WORK_DIR" || exit 1

log_guardian() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$GUARDIAN_LOG"
}

GUARDIAN_PID_FILE="$WORK_DIR/.guardian.pid"

run_once() {

restart_worker() {
    log_guardian "⚠️ Restart workera..."
    pkill -9 -f "$WORKER_SCRIPT" 2>/dev/null
    sleep 1
    rm -f "$PID_FILE"
    # Uruchamiaj workera bez git push (guardian zajmuje się tylko statusem na GitHub)
    nohup bash "$WORK_DIR/$WORKER_SCRIPT" --continuous --batch 20 --delay 4 --no-git >> "$LOG_FILE" 2>&1 &
    sleep 2
    if [ -f "$PID_FILE" ]; then
        log_guardian "✅ Worker uruchomiony PID: $(cat $PID_FILE)"
    else
        log_guardian "❌ Worker nie wystartował prawidłowo"
    fi
}

# Sprawdź czy worker działa przez PID file
worker_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Auto-restart jeśli zmienił się mtime skryptu workera
if [ -f "$WORK_DIR/$WORKER_SCRIPT" ]; then
    CURRENT_MTIME=$(stat -c %Y "$WORK_DIR/$WORKER_SCRIPT" 2>/dev/null || echo "")
    LAST_MTIME=$(cat "$MTIME_FILE" 2>/dev/null || echo "")
    if [ -n "$CURRENT_MTIME" ]; then
        if [ "$CURRENT_MTIME" != "$LAST_MTIME" ]; then
            log_guardian "🔄 Wykryto zmianę $WORKER_SCRIPT (mtime $LAST_MTIME -> $CURRENT_MTIME) - restart"
            restart_worker
        fi
        echo "$CURRENT_MTIME" > "$MTIME_FILE"
    fi
fi

# Restart workera jeśli nie działa
if ! worker_running; then
    log_guardian "⚠️ Worker nie działa - restartuję..."
    restart_worker
else
    # Worker działa - cichy log co 5 minut
    MINUTE=$(date +%M)
    if [ $((MINUTE % 5)) -eq 0 ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        log_guardian "✓ Worker OK (PID: $PID)"
    fi
fi

# Co ~2 minuty - push dashboardu do GitHub (zależne od czasu, nie od minuty zegara)
now_ts=$(date +%s)
last_ts=$(cat "$LAST_PUSH_TS_FILE" 2>/dev/null || echo 0)
if [ "$last_ts" -eq 0 ] || [ $((now_ts - last_ts)) -ge "$PUSH_INTERVAL_SECONDS" ]; then
    # Zawsze odśwież dashboard tuż przed pushem
    cd "$WORK_DIR" || exit 1
    bash "$WORK_DIR/$WORKER_SCRIPT" --update-status >/dev/null 2>&1 || true

    # Git operations MUSZĄ być w repo root (PtakuPL/ooo)
    cd "$REPO_ROOT" || exit 1

        # Pobierz najnowsze komendy z GitHub bez robienia merge (bezpieczne przy lokalnych zmianach)
        git fetch origin master -q 2>/dev/null || true
        git checkout -q origin/master -- Tibia/silnik/canary_test/.github/worker_commands.txt 2>/dev/null || true
        git checkout -q origin/master -- Tibia/silnik/canary_test/worker_commands.txt 2>/dev/null || true

    # Staging TYLKO plików statusu (bez przypadkowego commitowania migracji/kodu)
        git add \
            I18N_STATUS.md \
            Tibia/silnik/canary_test/I18N_STATUS.md \
            Tibia/silnik/canary_test/.github/worker_commands.txt \
            Tibia/silnik/canary_test/worker_commands.txt \
            2>/dev/null || true

    if ! git diff --cached --quiet 2>/dev/null; then
        MIGRATED=$(python3 - <<'PY'
import json
try:
    d=json.load(open('Tibia/silnik/canary_test/i18n_file_status.json'))
    print(len([f for f,i in d.get('files',{}).items() if i.get('overall_status')=='completed']))
except Exception:
    print('?')
PY
)
        git commit -m "📊 I18N status (guardian) | migrated=${MIGRATED} | $(date -u +%H:%M:%S) UTC" 2>/dev/null || true
        if git push origin master 2>/dev/null; then
            log_guardian "📤 Push do GitHub OK"
            echo "$now_ts" > "$LAST_PUSH_TS_FILE"
        else
            log_guardian "❌ Push nieudany"
        fi
    else
        # Brak zmian w statusie - ale i tak odśwież znacznik czasu, żeby nie spamować
        echo "$now_ts" > "$LAST_PUSH_TS_FILE"
    fi
fi

}

# Tryb działania:
# - default: single-run (pod cron)
# - --daemon: działa non-stop i sam pilnuje interwału
case "${1:-}" in
    --daemon)
        echo $$ > "$GUARDIAN_PID_FILE"
        log_guardian "▶️ Guardian daemon start (pid=$$)"
        while true; do
            run_once
            sleep 30
        done
        ;;
    *)
        run_once
        ;;
esac

exit 0
