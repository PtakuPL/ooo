#!/bin/bash
# Guardian v2.2 - automatyczny restart workera i18n + push do GitHub
# Uruchamiany przez cron co minutę

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
WORKER_SCRIPT="i18n_autonomous_worker.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker.pid"
GUARDIAN_LOG="$WORK_DIR/guardian.log"

export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$WORK_DIR" || exit 1

log_guardian() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$GUARDIAN_LOG"
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

# Restart workera jeśli nie działa
if ! worker_running; then
    log_guardian "⚠️ Worker nie działa - restartuję..."
    # Zabij ewentualne zombie procesy
    pkill -9 -f "i18n_autonomous_worker.sh" 2>/dev/null
    sleep 1
    rm -f "$PID_FILE"
    nohup bash "$WORK_DIR/$WORKER_SCRIPT" >> "$LOG_FILE" 2>&1 &
    sleep 2
    if [ -f "$PID_FILE" ]; then
        log_guardian "✅ Worker uruchomiony PID: $(cat $PID_FILE)"
    else
        log_guardian "❌ Worker nie wystartował prawidłowo"
    fi
fi

# Co 2 minuty - push do GitHub
MINUTE=$(date +%M)
if [ $((MINUTE % 2)) -eq 0 ]; then
    GIT_ROOT="/home/ptaku/serweryt"
    cd "$GIT_ROOT" || exit 1
    
    # Aktualizuj I18N_STATUS.md
    if [ -f "$WORK_DIR/I18N_STATUS.md" ]; then
        cp "$WORK_DIR/I18N_STATUS.md" "$GIT_ROOT/I18N_STATUS.md" 2>/dev/null
    fi
    
    # Git operations
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git add -A 2>/dev/null
        git commit -m "📊 I18N Status update $(date +%H:%M)" 2>/dev/null
        if git push origin master 2>/dev/null; then
            log_guardian "📤 Push do GitHub OK"
        else
            log_guardian "❌ Push nieudany"
        fi
    fi
fi

exit 0
