#!/bin/bash
#===============================================================================
# I18N AUTONOMOUS WORKER - Autonomiczny worker i18n
#===============================================================================

set -e

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
LOG_FILE="$WORK_DIR/i18n_worker.log"
CHANGES_LOG="$WORK_DIR/i18n_changes_documentation.md"
NPC_DIR="$WORK_DIR/data-otservbr-global/npc"
I18N_DIR="$WORK_DIR/i18n"

TOTAL_FILES_MIGRATED=0
TOTAL_STRINGS_PROCESSED=0
CYCLE_COUNT=0

log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$1"; }
log_success() { log "SUCCESS" "$1"; }

document_change() {
    local file="$1"
    local action="$2"
    local details="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "" >> "$CHANGES_LOG"
    echo "## [$timestamp] $action" >> "$CHANGES_LOG"
    echo "" >> "$CHANGES_LOG"
    echo "**Plik:** \`$file\`" >> "$CHANGES_LOG"
    echo "" >> "$CHANGES_LOG"
    echo "$details" >> "$CHANGES_LOG"
    echo "" >> "$CHANGES_LOG"
    echo "---" >> "$CHANGES_LOG"
    
    log_info "📝 Udokumentowano: $action"
}

init_documentation() {
    if [ ! -f "$CHANGES_LOG" ]; then
        echo "# I18N Changes Documentation" > "$CHANGES_LOG"
        echo "" >> "$CHANGES_LOG"
        echo "Automatyczna dokumentacja zmian." >> "$CHANGES_LOG"
        echo "" >> "$CHANGES_LOG"
        echo "---" >> "$CHANGES_LOG"
    fi
}

run_tool() {
    local tool="$1"
    shift
    python3 "$WORK_DIR/tools/$tool" "$@" 2>&1
}

count_migrated_npcs() {
    local migrated=0
    local total=0
    
    for npc_file in "$NPC_DIR"/*.lua; do
        if [ -f "$npc_file" ]; then
            total=$((total + 1))
            if grep -q "sayLocalized" "$npc_file" 2>/dev/null; then
                migrated=$((migrated + 1))
            fi
        fi
    done
    
    echo "$migrated/$total"
}

migrate_single_npc() {
    local npc_file="$1"
    local npc_name=$(basename "$npc_file" .lua)
    
    log_info "🎭 Migruję NPC: $npc_name"
    
    if grep -q "sayLocalized" "$npc_file" 2>/dev/null; then
        log_info "   ⏭️ Już zmigrowany"
        return 1
    fi
    
    if ! grep -qE 'npcHandler:say\s*\(\s*"[^"]{10,}"' "$npc_file" 2>/dev/null; then
        log_info "   ⏭️ Brak stringów"
        return 1
    fi
    
    local backup_file="${npc_file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$npc_file" "$backup_file"
    log_info "   💾 Backup: $(basename "$backup_file")"
    
    local temp_file=$(mktemp)
    local transformed=0
    local key_counter=1
    
    while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -qE 'npcHandler:say\s*\(\s*"[^"]{10,}"'; then
            local original_text=$(echo "$line" | sed -n 's/.*npcHandler:say\s*(\s*"\([^"]*\)".*/\1/p')
            
            if [ -n "$original_text" ] && [ ${#original_text} -gt 10 ]; then
                local key_words=$(echo "$original_text" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z ]//g' | awk '{print $1"_"$2"_"$3}')
                key_words=$(echo "$key_words" | sed 's/_*$//' | head -c 25)
                local full_key="npc.${npc_name}.${key_words}_${key_counter}"
                key_counter=$((key_counter + 1))
                
                local new_line=$(echo "$line" | sed "s|npcHandler:say(\s*\"[^\"]*\"|npcHandler:sayLocalized(\"${full_key}\"|")
                echo "$new_line" >> "$temp_file"
                transformed=$((transformed + 1))
                
                python3 << PYEOF
import json
npc_json = "$I18N_DIR/en/npc.json"
key = "$full_key"
text = '''$original_text'''
try:
    with open(npc_json, 'r', encoding='utf-8') as f:
        data = json.load(f)
except:
    data = {}
data[key] = text
with open(npc_json, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PYEOF
                
                log_info "      🔑 $full_key"
            else
                echo "$line" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$npc_file"
    
    if [ "$transformed" -gt 0 ]; then
        mv "$temp_file" "$npc_file"
        
        log_success "   ✅ ZMIGROWANO $transformed stringów!"
        
        document_change "$npc_file" "Migracja NPC: $npc_name" "Stringów: $transformed, Metoda: sayLocalized()"
        
        TOTAL_FILES_MIGRATED=$((TOTAL_FILES_MIGRATED + 1))
        TOTAL_STRINGS_PROCESSED=$((TOTAL_STRINGS_PROCESSED + transformed))
        
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

phase_npc_migration() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "📦 FAZA 1: MIGRACJA NPC"
    log_info "═══════════════════════════════════════════════════════════════"
    
    local status=$(count_migrated_npcs)
    log_info "Status NPC: $status"
    
    local migrated_count=0
    
    for npc_file in "$NPC_DIR"/*.lua; do
        if [ -f "$npc_file" ]; then
            if ! grep -q "sayLocalized" "$npc_file" 2>/dev/null; then
                if grep -qE 'npcHandler:say\s*\(\s*"[^"]{10,}"' "$npc_file" 2>/dev/null; then
                    if migrate_single_npc "$npc_file"; then
                        migrated_count=$((migrated_count + 1))
                        if [ "$migrated_count" -ge 3 ]; then
                            break
                        fi
                    fi
                fi
            fi
        fi
    done
    
    log_info "📊 Zmigrowano w tym cyklu: $migrated_count NPC"
}

phase_validation() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🔍 FAZA 2: WALIDACJA"
    log_info "═══════════════════════════════════════════════════════════════"
    
    log_info "📸 Snapshot postępu..."
    run_tool "i18n_progress_tracker.py" --update 2>&1 | tail -5
    
    log_info "🔍 Kontrola jakości..."
    run_tool "i18n_quality_checker.py" --locale en 2>&1 | grep -E "errors:|warnings:" | head -2 || echo "OK"
    
    log_info "📊 Dashboard..."
    run_tool "i18n_coverage_dashboard.py" 2>&1 | tail -2
}

phase_analysis() {
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "🔬 FAZA 3: ANALIZA"
    log_info "═══════════════════════════════════════════════════════════════"
    
    local random_npc=$(ls "$NPC_DIR"/*.lua 2>/dev/null | shuf -n 1)
    if [ -n "$random_npc" ]; then
        log_info "📊 Analiza: $(basename "$random_npc")"
        run_tool "i18n_deep_analyzer.py" --file "$random_npc" 2>&1 | tail -10
    fi
    
    log_info "🧠 Translation Memory..."
    run_tool "i18n_translation_memory.py" --build 2>&1 | tail -2
    
    log_info "🔮 Status..."
    run_tool "i18n_progress_tracker.py" --status 2>&1 | tail -8
}

main() {
    cd "$WORK_DIR"
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║     I18N AUTONOMOUS WORKER - Canary Server v2.1                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    init_documentation
    log_info "🚀 Worker uruchomiony"
    log_info "📁 Katalog: $WORK_DIR"
    
    while true; do
        CYCLE_COUNT=$((CYCLE_COUNT + 1))
        
        echo ""
        log_info "═══════════════════════════════════════════════════════════════"
        log_info "🔄 CYKL #$CYCLE_COUNT"
        log_info "═══════════════════════════════════════════════════════════════"
        
        local npc_status=$(count_migrated_npcs)
        log_info "📊 NPC: $npc_status | Plików: $TOTAL_FILES_MIGRATED | Stringów: $TOTAL_STRINGS_PROCESSED"
        
        phase_npc_migration
        phase_validation
        phase_analysis
        
        echo ""
        log_info "📊 RAPORT CYKLU #$CYCLE_COUNT"
        log_info "   NPC: $(count_migrated_npcs)"
        log_info "   Plików: $TOTAL_FILES_MIGRATED"
        log_info "   Stringów: $TOTAL_STRINGS_PROCESSED"
        
        log_info "💤 Przerwa 20 sekund..."
        sleep 20
    done
}

trap 'log_info "⛔ Worker zatrzymany"; exit 0' SIGINT SIGTERM

main "$@"
