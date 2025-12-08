#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N CHECKPOINT MANAGER - System checkpointów i resume
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
CHECKPOINT_FILE="$WORK_DIR/.i18n_checkpoint.json"
CHECKPOINT_INTERVAL=100  # Co ile plików zapisywać checkpoint

# === FUNKCJE ===

# Utwórz nowy checkpoint
create_checkpoint() {
    local current_dir="$1"
    local current_file="$2"
    local processed_count="$3"
    local total_keys="$4"
    local processed_files_array="$5"  # JSON array
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > "$CHECKPOINT_FILE" << EOF
{
    "version": "1.0",
    "created_at": "$timestamp",
    "state": {
        "current_directory": "$current_dir",
        "current_file": "$current_file",
        "processed_count": $processed_count,
        "total_keys": $total_keys
    },
    "processed_files": $processed_files_array,
    "stats": {
        "started_at": "$(jq -r '.stats.started_at // empty' "$CHECKPOINT_FILE" 2>/dev/null || echo "$timestamp")",
        "last_checkpoint": "$timestamp",
        "checkpoints_count": $(($(jq -r '.stats.checkpoints_count // 0' "$CHECKPOINT_FILE" 2>/dev/null) + 1))
    }
}
EOF
    
    log "CHECKPOINT" "Zapisano checkpoint: $processed_count plików"
}

# Sprawdź czy istnieje checkpoint
has_checkpoint() {
    [[ -f "$CHECKPOINT_FILE" ]]
}

# Wczytaj checkpoint
load_checkpoint() {
    if [[ ! -f "$CHECKPOINT_FILE" ]]; then
        echo "{}"
        return 1
    fi
    
    cat "$CHECKPOINT_FILE"
}

# Pobierz wartość z checkpointu
get_checkpoint_value() {
    local key="$1"
    jq -r "$key // empty" "$CHECKPOINT_FILE" 2>/dev/null
}

# Usuń checkpoint (po zakończeniu)
clear_checkpoint() {
    if [[ -f "$CHECKPOINT_FILE" ]]; then
        # Archiwizuj checkpoint przed usunięciem
        local archive_dir="$WORK_DIR/.i18n_checkpoints_archive"
        mkdir -p "$archive_dir"
        local archive_name="checkpoint_$(date +%Y%m%d_%H%M%S).json"
        mv "$CHECKPOINT_FILE" "$archive_dir/$archive_name"
        log "INFO" "Checkpoint zarchiwizowany: $archive_name"
    fi
}

# Zapytaj użytkownika o resume
prompt_resume() {
    if ! has_checkpoint; then
        return 1
    fi
    
    local created_at=$(get_checkpoint_value '.created_at')
    local processed=$(get_checkpoint_value '.state.processed_count')
    local current_dir=$(get_checkpoint_value '.state.current_directory')
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║           ZNALEZIONO NIEZAKOŃCZONĄ SESJĘ                     ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║ Data rozpoczęcia: $created_at"
    echo "║ Przetworzono: $processed plików"
    echo "║ Ostatni katalog: $current_dir"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║ [R] Resume - kontynuuj od miejsca przerwania                 ║"
    echo "║ [N] New    - zacznij od nowa (usuń checkpoint)               ║"
    echo "║ [Q] Quit   - wyjdź bez zmian                                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Wybór [R/N/Q]: " choice
    
    case "${choice^^}" in
        R) return 0 ;;  # Resume
        N) clear_checkpoint; return 1 ;;  # New
        Q) exit 0 ;;
        *) prompt_resume ;;  # Powtórz
    esac
}

# Sprawdź czy plik był już przetworzony
was_file_processed() {
    local file="$1"
    
    if ! has_checkpoint; then
        return 1
    fi
    
    jq -e --arg f "$file" '.processed_files | index($f) != null' "$CHECKPOINT_FILE" &>/dev/null
}

# Dodaj plik do listy przetworzonych
mark_file_processed() {
    local file="$1"
    
    # To będzie wywoływane przez główny worker
    # Aktualizacja przez główną funkcję create_checkpoint
    :
}

# Wrapper dla głównego workera
checkpoint_wrapper() {
    local process_function="$1"
    shift
    local files=("$@")
    
    local processed_count=0
    local total_keys=0
    local processed_files="[]"
    local current_dir=""
    
    # Sprawdź czy jest checkpoint do wznowienia
    if has_checkpoint; then
        if prompt_resume; then
            processed_count=$(get_checkpoint_value '.state.processed_count')
            total_keys=$(get_checkpoint_value '.state.total_keys')
            processed_files=$(get_checkpoint_value '.processed_files')
            log "INFO" "Wznawiam od pliku $processed_count"
        fi
    fi
    
    # Przetwarzaj pliki
    for file in "${files[@]}"; do
        # Pomiń jeśli już przetworzone
        if echo "$processed_files" | jq -e --arg f "$file" 'index($f) != null' &>/dev/null; then
            continue
        fi
        
        # Przetwórz plik
        current_dir=$(dirname "$file")
        local keys=$($process_function "$file")
        ((total_keys += keys))
        ((processed_count++))
        
        # Dodaj do listy przetworzonych
        processed_files=$(echo "$processed_files" | jq --arg f "$file" '. + [$f]')
        
        # Checkpoint co CHECKPOINT_INTERVAL plików
        if ((processed_count % CHECKPOINT_INTERVAL == 0)); then
            create_checkpoint "$current_dir" "$file" "$processed_count" "$total_keys" "$processed_files"
        fi
    done
    
    # Zakończono - usuń checkpoint
    clear_checkpoint
    
    log "SUCCESS" "Zakończono przetwarzanie $processed_count plików"
}

# Logowanie
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# === CLI ===

show_status() {
    if ! has_checkpoint; then
        echo "Brak aktywnego checkpointu"
        return
    fi
    
    echo "=== STATUS CHECKPOINTU ==="
    jq '.' "$CHECKPOINT_FILE"
}

# Główna funkcja CLI
main() {
    case "$1" in
        status)
            show_status
            ;;
        clear)
            clear_checkpoint
            echo "Checkpoint usunięty"
            ;;
        test)
            # Test tworzenia checkpointu
            create_checkpoint "/test/dir" "test_file.lua" 50 1234 '["file1.lua", "file2.lua"]'
            echo "Test checkpoint utworzony"
            show_status
            ;;
        *)
            echo "Użycie: $0 {status|clear|test}"
            echo ""
            echo "Ten skrypt jest biblioteką do użycia w innych skryptach."
            echo "Import: source i18n_checkpoint_manager.sh"
            ;;
    esac
}

# Uruchom CLI jeśli wykonywany bezpośrednio
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
