#!/bin/bash
# Guardian v3.0 - automatyczny restart workera i18n + push do GitHub
# Uruchamiany przez cron co minutę
# Monitoruje i18n_worker_simple.sh w trybie --continuous

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
WORKER_SCRIPT="i18n_worker_simple.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker_simple.pid"
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
    pkill -9 -f "i18n_worker_simple.sh" 2>/dev/null
    sleep 1
    rm -f "$PID_FILE"
    # Uruchom worker w trybie continuous (5 plików na batch, 10s przerwy)
    nohup bash "$WORK_DIR/$WORKER_SCRIPT" --continuous 5 10 >> "$LOG_FILE" 2>&1 &
    sleep 2
    if [ -f "$PID_FILE" ]; then
        log_guardian "✅ Worker uruchomiony PID: $(cat $PID_FILE)"
    else
        log_guardian "❌ Worker nie wystartował prawidłowo"
    fi
else
    # Worker działa - cichy log co 5 minut
    MINUTE=$(date +%M)
    if [ $((MINUTE % 5)) -eq 0 ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        log_guardian "✓ Worker OK (PID: $PID)"
    fi
fi

# Co 2 minuty - push do GitHub (dodatkowy backup push)
MINUTE=$(date +%M)
if [ $((MINUTE % 2)) -eq 0 ]; then
    cd "$WORK_DIR" || exit 1
    
    # Git operations
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git add -A 2>/dev/null
        MIGRATED=$(cat "i18n_file_status.json" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len([f for f,i in d.get('files',{}).items() if i.get('overall_status')=='completed']))" 2>/dev/null || echo "?")
        git commit -m "📊 I18N: $MIGRATED NPCs - Guardian backup $(date +%H:%M)" 2>/dev/null
        if git push origin master 2>/dev/null; then
            log_guardian "📤 Push do GitHub OK"
        else
            log_guardian "❌ Push nieudany"
        fi
    fi
fi

exit 0
