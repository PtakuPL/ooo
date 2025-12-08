#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N INCREMENTAL WORKER - Przetwarzanie tylko zmienionych plików
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
HASH_FILE="$WORK_DIR/.i18n_file_hashes.json"
I18N_DIR="$WORK_DIR/i18n"

# === KOLORY ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === FUNKCJE ===

# Inicjalizacja pliku hashy jeśli nie istnieje
init_hash_file() {
    if [[ ! -f "$HASH_FILE" ]]; then
        echo '{"files": {}, "last_full_scan": null}' > "$HASH_FILE"
        log "INFO" "Utworzono nowy plik hashy"
    fi
}

# Oblicz hash MD5 pliku
calculate_hash() {
    local file="$1"
    md5sum "$file" 2>/dev/null | cut -d' ' -f1
}

# Pobierz zapisany hash z pliku JSON
get_stored_hash() {
    local file="$1"
    local relative_path="${file#$WORK_DIR/}"
    jq -r ".files[\"$relative_path\"].hash // empty" "$HASH_FILE" 2>/dev/null
}

# Zapisz hash do pliku JSON
store_hash() {
    local file="$1"
    local hash="$2"
    local keys_count="$3"
    local relative_path="${file#$WORK_DIR/}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Użyj jq do aktualizacji
    local tmp_file=$(mktemp)
    jq --arg path "$relative_path" \
       --arg hash "$hash" \
       --arg ts "$timestamp" \
       --argjson keys "$keys_count" \
       '.files[$path] = {"hash": $hash, "last_processed": $ts, "keys_count": $keys}' \
       "$HASH_FILE" > "$tmp_file" && mv "$tmp_file" "$HASH_FILE"
}

# Sprawdź czy plik wymaga przetworzenia
needs_processing() {
    local file="$1"
    
    # Jeśli plik nie istnieje - pomiń
    [[ ! -f "$file" ]] && return 1
    
    local current_hash=$(calculate_hash "$file")
    local stored_hash=$(get_stored_hash "$file")
    
    # Jeśli brak zapisanego hashu - nowy plik
    [[ -z "$stored_hash" ]] && return 0
    
    # Jeśli hash się zmienił - plik zmodyfikowany
    [[ "$current_hash" != "$stored_hash" ]] && return 0
    
    # Plik nie zmieniony
    return 1
}

# Znajdź wszystkie pliki do skanowania
find_all_files() {
    local scan_dirs=(
        "data-otservbr-global/npc"
        "data-otservbr-global/scripts"
        "data-canary/npc"
        "data/scripts"
    )
    
    for dir in "${scan_dirs[@]}"; do
        if [[ -d "$WORK_DIR/$dir" ]]; then
            find "$WORK_DIR/$dir" -name "*.lua" -type f 2>/dev/null
        fi
    done
}

# Znajdź tylko zmienione pliki
find_changed_files() {
    local changed_files=()
    
    while IFS= read -r file; do
        if needs_processing "$file"; then
            changed_files+=("$file")
        fi
    done < <(find_all_files)
    
    printf '%s\n' "${changed_files[@]}"
}

# Znajdź usunięte pliki (hash istnieje, plik nie)
find_deleted_files() {
    jq -r '.files | keys[]' "$HASH_FILE" 2>/dev/null | while read -r relative_path; do
        local full_path="$WORK_DIR/$relative_path"
        if [[ ! -f "$full_path" ]]; then
            echo "$relative_path"
        fi
    done
}

# Usuń klucze dla usuniętych plików
cleanup_deleted_files() {
    local deleted_files=$(find_deleted_files)
    
    if [[ -n "$deleted_files" ]]; then
        log "INFO" "Znaleziono usunięte pliki - czyszczenie kluczy..."
        
        while IFS= read -r relative_path; do
            log "WARN" "Plik usunięty: $relative_path"
            
            # Usuń hash z pliku
            local tmp_file=$(mktemp)
            jq --arg path "$relative_path" 'del(.files[$path])' "$HASH_FILE" > "$tmp_file" && mv "$tmp_file" "$HASH_FILE"
            
            # TODO: Usuń powiązane klucze z plików JSON i18n
            # remove_keys_for_file "$relative_path"
        done <<< "$deleted_files"
    fi
}

# Przetwórz pojedynczy plik (placeholder)
process_file() {
    local file="$1"
    local keys_found=0
    
    # TODO: Implementacja ekstrakcji stringów
    # keys_found=$(extract_strings "$file")
    
    # Po przetworzeniu - zapisz nowy hash
    local current_hash=$(calculate_hash "$file")
    store_hash "$file" "$current_hash" "$keys_found"
    
    echo "$keys_found"
}

# Logowanie
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")    echo -e "${BLUE}[$timestamp]${NC} [INFO] $message" ;;
        "SUCCESS") echo -e "${GREEN}[$timestamp]${NC} [SUCCESS] $message" ;;
        "WARN")    echo -e "${YELLOW}[$timestamp]${NC} [WARN] $message" ;;
        "ERROR")   echo -e "${RED}[$timestamp]${NC} [ERROR] $message" ;;
    esac
}

# === GŁÓWNA LOGIKA ===

main() {
    local dry_run=false
    local force_full=false
    
    # Parsowanie argumentów
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)  dry_run=true; shift ;;
            --full)     force_full=true; shift ;;
            *)          shift ;;
        esac
    done
    
    log "INFO" "═══════════════════════════════════════════════════"
    log "INFO" "🔄 I18N INCREMENTAL WORKER"
    log "INFO" "═══════════════════════════════════════════════════"
    
    # Inicjalizacja
    init_hash_file
    
    # Znajdź zmienione pliki
    if [[ "$force_full" == true ]]; then
        log "INFO" "Tryb pełnego skanowania (--full)"
        mapfile -t files_to_process < <(find_all_files)
    else
        log "INFO" "Szukam zmienionych plików..."
        mapfile -t files_to_process < <(find_changed_files)
    fi
    
    local total_files=${#files_to_process[@]}
    log "INFO" "Znaleziono $total_files plików do przetworzenia"
    
    if [[ "$dry_run" == true ]]; then
        log "WARN" "Tryb DRY-RUN - nie wprowadzam zmian"
        for file in "${files_to_process[@]}"; do
            echo "  [DRY-RUN] $file"
        done
        return 0
    fi
    
    # Przetwórz zmienione pliki
    local processed=0
    local total_keys=0
    
    for file in "${files_to_process[@]}"; do
        ((processed++))
        log "INFO" "[$processed/$total_files] Przetwarzam: ${file#$WORK_DIR/}"
        
        local keys=$(process_file "$file")
        ((total_keys += keys))
    done
    
    # Wyczyść usunięte pliki
    cleanup_deleted_files
    
    # Podsumowanie
    log "SUCCESS" "═══════════════════════════════════════════════════"
    log "SUCCESS" "✅ Przetworzono: $processed plików"
    log "SUCCESS" "🔑 Kluczy: $total_keys"
    log "SUCCESS" "═══════════════════════════════════════════════════"
}

# Uruchom jeśli skrypt wykonywany bezpośrednio
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
