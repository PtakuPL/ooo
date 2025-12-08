#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N PARALLEL WORKER - Wielowątkowe przetwarzanie plików
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# Wymaga: GNU parallel
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
I18N_DIR="$WORK_DIR/i18n"
TEMP_DIR="$WORK_DIR/.i18n_parallel_temp"
LOCK_DIR="$WORK_DIR/.i18n_locks"

# Liczba równoległych procesów (domyślnie: liczba CPU - 1)
NUM_JOBS=${NUM_JOBS:-$(($(nproc) - 1))}
[[ $NUM_JOBS -lt 1 ]] && NUM_JOBS=1

# Rozmiar partii
BATCH_SIZE=${BATCH_SIZE:-50}

# === KOLORY ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# === FUNKCJE ===

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $message"
}

# Sprawdź czy GNU parallel jest dostępny
check_dependencies() {
    if ! command -v parallel &> /dev/null; then
        log "ERROR" "GNU parallel nie jest zainstalowany!"
        log "INFO" "Instalacja: sudo apt install parallel"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log "ERROR" "jq nie jest zainstalowany!"
        log "INFO" "Instalacja: sudo apt install jq"
        exit 1
    fi
}

# Przygotuj katalogi tymczasowe
setup_temp_dirs() {
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR/results"
    mkdir -p "$TEMP_DIR/batches"
    mkdir -p "$LOCK_DIR"
}

# Podziel pliki na partie
create_batches() {
    local files_list="$1"
    local batch_num=0
    local file_count=0
    local batch_file="$TEMP_DIR/batches/batch_$batch_num.txt"
    
    while IFS= read -r file; do
        echo "$file" >> "$batch_file"
        ((file_count++))
        
        if [[ $file_count -ge $BATCH_SIZE ]]; then
            ((batch_num++))
            batch_file="$TEMP_DIR/batches/batch_$batch_num.txt"
            file_count=0
        fi
    done < "$files_list"
    
    echo $((batch_num + 1))
}

# Funkcja przetwarzająca pojedynczy plik (eksportowana dla parallel)
process_single_file() {
    local file="$1"
    local result_dir="$2"
    local filename=$(basename "$file" .lua)
    local result_file="$result_dir/${filename}_result.json"
    
    # Ekstrakcja stringów z pliku Lua
    local strings_found=0
    local keys_json="{}"
    
    # Wzorce do szukania
    local patterns=(
        'sendTextMessage[^"]*"([^"]+)"'
        'player:say[^"]*"([^"]+)"'
        'npc:say[^"]*"([^"]+)"'
        'addEvent[^"]*"([^"]+)"'
    )
    
    for pattern in "${patterns[@]}"; do
        while IFS= read -r match; do
            if [[ -n "$match" ]]; then
                ((strings_found++))
                local key="parallel.${filename}.msg_${strings_found}"
                keys_json=$(echo "$keys_json" | jq --arg k "$key" --arg v "$match" '. + {($k): $v}')
            fi
        done < <(grep -oP "$pattern" "$file" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    done
    
    # Zapisz wynik
    echo "$keys_json" > "$result_file"
    echo "$strings_found"
}

# Przetwórz partię plików
process_batch() {
    local batch_file="$1"
    local batch_id="$2"
    local result_dir="$TEMP_DIR/results/batch_$batch_id"
    
    mkdir -p "$result_dir"
    
    local total_keys=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local keys=$(process_single_file "$file" "$result_dir")
            ((total_keys += keys))
        fi
    done < "$batch_file"
    
    echo "$total_keys" > "$result_dir/total_keys.txt"
}

# Połącz wyniki z wszystkich partii
merge_results() {
    log "INFO" "Łączenie wyników..."
    
    local final_json="{}"
    local total_keys=0
    
    for result_dir in "$TEMP_DIR/results"/batch_*; do
        if [[ -d "$result_dir" ]]; then
            # Połącz JSON z tej partii
            for json_file in "$result_dir"/*_result.json; do
                if [[ -f "$json_file" ]]; then
                    local content=$(cat "$json_file")
                    if [[ "$content" != "{}" ]]; then
                        final_json=$(echo "$final_json" "$content" | jq -s '.[0] * .[1]')
                    fi
                fi
            done
            
            # Dodaj licznik kluczy
            if [[ -f "$result_dir/total_keys.txt" ]]; then
                local batch_keys=$(cat "$result_dir/total_keys.txt")
                ((total_keys += batch_keys))
            fi
        fi
    done
    
    # Zapisz końcowy wynik
    echo "$final_json" | jq '.' > "$I18N_DIR/en/parallel_extracted.json"
    
    log "SUCCESS" "Połączono $total_keys kluczy"
}

# Blokada pliku (mutex)
acquire_lock() {
    local lock_name="$1"
    local lock_file="$LOCK_DIR/${lock_name}.lock"
    
    while ! mkdir "$lock_file" 2>/dev/null; do
        sleep 0.1
    done
}

release_lock() {
    local lock_name="$1"
    local lock_file="$LOCK_DIR/${lock_name}.lock"
    rmdir "$lock_file" 2>/dev/null
}

# Czyszczenie
cleanup() {
    rm -rf "$TEMP_DIR"
    rm -rf "$LOCK_DIR"
}

# === GŁÓWNA LOGIKA ===

main() {
    log "INFO" "═══════════════════════════════════════════════════"
    log "INFO" "🚀 I18N PARALLEL WORKER"
    log "INFO" "═══════════════════════════════════════════════════"
    log "INFO" "Procesy równoległe: $NUM_JOBS"
    log "INFO" "Rozmiar partii: $BATCH_SIZE"
    
    # Sprawdź zależności
    check_dependencies
    
    # Przygotuj katalogi
    setup_temp_dirs
    
    # Znajdź wszystkie pliki Lua
    local files_list="$TEMP_DIR/all_files.txt"
    find "$WORK_DIR/data-otservbr-global" -name "*.lua" -type f > "$files_list" 2>/dev/null
    
    local total_files=$(wc -l < "$files_list")
    log "INFO" "Znaleziono $total_files plików"
    
    # Podziel na partie
    local num_batches=$(create_batches "$files_list")
    log "INFO" "Utworzono $num_batches partii"
    
    # Przetwórz partie równolegle
    log "INFO" "Rozpoczynam przetwarzanie równoległe..."
    
    local start_time=$(date +%s)
    
    # Użyj GNU parallel do przetwarzania partii
    export -f process_batch process_single_file
    export TEMP_DIR I18N_DIR
    
    ls "$TEMP_DIR/batches"/*.txt 2>/dev/null | \
        parallel -j "$NUM_JOBS" --bar \
        'batch_id=$(basename {} .txt | sed "s/batch_//"); process_batch {} $batch_id'
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Połącz wyniki
    merge_results
    
    # Podsumowanie
    log "SUCCESS" "═══════════════════════════════════════════════════"
    log "SUCCESS" "✅ Przetworzono $total_files plików w $duration sekund"
    log "SUCCESS" "⚡ Szybkość: $(echo "scale=2; $total_files / $duration" | bc) plików/s"
    log "SUCCESS" "═══════════════════════════════════════════════════"
    
    # Czyszczenie
    cleanup
}

# Uruchom
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
