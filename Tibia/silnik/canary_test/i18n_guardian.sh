#!/bin/bash
# Guardian - automatyczny restart workera i18n
# Uruchamiany przez cron co minutę

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
WORKER_SCRIPT="i18n_autonomous_worker.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker.pid"

cd "$WORK_DIR" || exit 1

# Sprawdź czy worker działa
if ! pgrep -f "$WORKER_SCRIPT" > /dev/null 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GUARDIAN] Worker nie działa - restartuję..." >> "$LOG_FILE"
    nohup "./$WORKER_SCRIPT" >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GUARDIAN] Worker uruchomiony PID: $!" >> "$LOG_FILE"
fi

# Co 2 minuty - push do GitHub
MINUTE=$(date +%M)
if [ $((MINUTE % 2)) -eq 0 ]; then
    cd "$WORK_DIR"
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "🤖 Auto-sync i18n [$(date '+%Y-%m-%d %H:%M')]" --quiet 2>/dev/null
        git push origin master --quiet 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GUARDIAN] ✅ Git push wykonany" >> "$LOG_FILE"
    fi
fi
