#!/bin/bash
# Guardian v2.1 - automatyczny restart workera i18n + push do GitHub
# Uruchamiany przez cron co minutę

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
WORKER_SCRIPT="i18n_autonomous_worker.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker.pid"
GUARDIAN_LOG="$WORK_DIR/guardian.log"

# Ustawienia Git dla cron
export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$WORK_DIR" || exit 1

# Logowanie Guardian
log_guardian() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$GUARDIAN_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GUARDIAN] $1" >> "$LOG_FILE"
}

# Sprawdź czy worker działa
if ! pgrep -f "$WORKER_SCRIPT" > /dev/null 2>&1; then
    log_guardian "⚠️ Worker nie działa - restartuję..."
    nohup bash "$WORK_DIR/$WORKER_SCRIPT" >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    log_guardian "✅ Worker uruchomiony PID: $!"
fi

# Co 2 minuty - push do GitHub (parzysta minuta)
MINUTE=$(date +%M)
if [ $((MINUTE % 2)) -eq 0 ]; then
    cd "$WORK_DIR"
    
    # Sprawdź czy są zmiany
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git add I18N_STATUS.md i18n/status/ 2>/dev/null
        git commit -m "🤖 Auto-sync i18n [$(date '+%H:%M')]" --quiet 2>/dev/null
        
        # Push z pełnym logowaniem błędów
        if git push origin master 2>&1 | tee -a "$GUARDIAN_LOG"; then
            log_guardian "✅ Git push OK"
        else
            log_guardian "❌ Git push FAILED"
        fi
    else
        log_guardian "ℹ️ Brak zmian do push"
    fi
fi
