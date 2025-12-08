#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N ROLLBACK - System przywracania z backup
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
BACKUP_DIR="$WORK_DIR/.i18n_backups"
MAX_BACKUPS=50
BACKUP_RETENTION_DAYS=7

# === KOLORY ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === FUNKCJE ===

log() {
    local level="$1"
    local message="$2"
    echo -e "[$level] $message"
}

# Inicjalizacja systemu backup
init_backup_system() {
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/files"
    mkdir -p "$BACKUP_DIR/snapshots"
    
    # Plik indeksu backupów
    if [[ ! -f "$BACKUP_DIR/index.json" ]]; then
        echo '{"backups": [], "snapshots": []}' > "$BACKUP_DIR/index.json"
    fi
}

# Utwórz backup pojedynczego pliku przed modyfikacją
backup_file() {
    local file="$1"
    local reason="${2:-manual}"
    
    if [[ ! -f "$file" ]]; then
        log "WARN" "Plik nie istnieje: $file"
        return 1
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local relative_path="${file#$WORK_DIR/}"
    local safe_name=$(echo "$relative_path" | tr '/' '_')
    local backup_name="${safe_name}_${timestamp}.bak"
    local backup_path="$BACKUP_DIR/files/$backup_name"
    
    # Kopiuj plik
    cp "$file" "$backup_path"
    
    # Dodaj do indeksu
    local index_entry=$(cat << EOF
{
    "original_path": "$relative_path",
    "backup_path": "files/$backup_name",
    "timestamp": "$timestamp",
    "reason": "$reason",
    "size": $(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0),
    "hash": "$(md5sum "$file" | cut -d' ' -f1)"
}
EOF
)
    
    local tmp_file=$(mktemp)
    jq --argjson entry "$index_entry" '.backups += [$entry]' "$BACKUP_DIR/index.json" > "$tmp_file"
    mv "$tmp_file" "$BACKUP_DIR/index.json"
    
    log "SUCCESS" "Backup: $relative_path -> $backup_name"
    echo "$backup_path"
}

# Przywróć plik z backup
restore_file() {
    local original_path="$1"
    local backup_timestamp="${2:-latest}"
    
    local relative_path="${original_path#$WORK_DIR/}"
    
    # Znajdź backup
    local backup_info
    if [[ "$backup_timestamp" == "latest" ]]; then
        backup_info=$(jq -r --arg path "$relative_path" \
            '[.backups[] | select(.original_path == $path)] | sort_by(.timestamp) | last' \
            "$BACKUP_DIR/index.json")
    else
        backup_info=$(jq -r --arg path "$relative_path" --arg ts "$backup_timestamp" \
            '.backups[] | select(.original_path == $path and .timestamp == $ts)' \
            "$BACKUP_DIR/index.json")
    fi
    
    if [[ -z "$backup_info" || "$backup_info" == "null" ]]; then
        log "ERROR" "Nie znaleziono backup dla: $relative_path"
        return 1
    fi
    
    local backup_path=$(echo "$backup_info" | jq -r '.backup_path')
    local full_backup_path="$BACKUP_DIR/$backup_path"
    
    if [[ ! -f "$full_backup_path" ]]; then
        log "ERROR" "Plik backup nie istnieje: $full_backup_path"
        return 1
    fi
    
    # Przywróć
    local full_original="$WORK_DIR/$relative_path"
    cp "$full_backup_path" "$full_original"
    
    log "SUCCESS" "Przywrócono: $relative_path z $backup_path"
}

# Utwórz snapshot całego katalogu i18n
create_snapshot() {
    local name="${1:-snapshot}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_name="${name}_${timestamp}"
    local snapshot_dir="$BACKUP_DIR/snapshots/$snapshot_name"
    
    mkdir -p "$snapshot_dir"
    
    # Kopiuj wszystkie pliki i18n
    cp -r "$WORK_DIR/i18n" "$snapshot_dir/"
    
    # Zapisz metadane
    cat > "$snapshot_dir/metadata.json" << EOF
{
    "name": "$snapshot_name",
    "timestamp": "$timestamp",
    "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "files_count": $(find "$snapshot_dir/i18n" -type f | wc -l),
    "total_size": "$(du -sh "$snapshot_dir/i18n" | cut -f1)",
    "git_commit": "$(git -C "$WORK_DIR" rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF
    
    # Dodaj do indeksu
    local tmp_file=$(mktemp)
    jq --arg name "$snapshot_name" --arg ts "$timestamp" \
        '.snapshots += [{"name": $name, "timestamp": $ts}]' \
        "$BACKUP_DIR/index.json" > "$tmp_file"
    mv "$tmp_file" "$BACKUP_DIR/index.json"
    
    log "SUCCESS" "Snapshot utworzony: $snapshot_name"
    echo "$snapshot_name"
}

# Przywróć z snapshotu
restore_snapshot() {
    local snapshot_name="$1"
    local snapshot_dir="$BACKUP_DIR/snapshots/$snapshot_name"
    
    if [[ ! -d "$snapshot_dir" ]]; then
        log "ERROR" "Snapshot nie istnieje: $snapshot_name"
        return 1
    fi
    
    # Backup aktualnego stanu przed przywróceniem
    create_snapshot "pre_restore"
    
    # Przywróć
    rm -rf "$WORK_DIR/i18n"
    cp -r "$snapshot_dir/i18n" "$WORK_DIR/"
    
    log "SUCCESS" "Przywrócono snapshot: $snapshot_name"
}

# Lista backupów dla pliku
list_backups() {
    local file_path="$1"
    
    if [[ -n "$file_path" ]]; then
        local relative_path="${file_path#$WORK_DIR/}"
        jq -r --arg path "$relative_path" \
            '.backups[] | select(.original_path == $path) | "\(.timestamp) | \(.reason) | \(.size) bytes"' \
            "$BACKUP_DIR/index.json"
    else
        echo "=== BACKUPY PLIKÓW ==="
        jq -r '.backups | group_by(.original_path) | .[] | "\(.[0].original_path): \(length) backupów"' \
            "$BACKUP_DIR/index.json"
        echo ""
        echo "=== SNAPSHOTY ==="
        jq -r '.snapshots[] | "\(.name) | \(.timestamp)"' "$BACKUP_DIR/index.json"
    fi
}

# Wyczyść stare backupy
cleanup_old_backups() {
    log "INFO" "Czyszczenie starych backupów..."
    
    local cutoff_date=$(date -d "-${BACKUP_RETENTION_DAYS} days" +%Y%m%d 2>/dev/null || \
                        date -v-${BACKUP_RETENTION_DAYS}d +%Y%m%d)
    
    local removed=0
    
    # Usuń stare backupy plików
    for backup_file in "$BACKUP_DIR/files"/*.bak; do
        if [[ -f "$backup_file" ]]; then
            local file_date=$(basename "$backup_file" | grep -oP '\d{8}(?=_)' | head -1)
            if [[ -n "$file_date" && "$file_date" < "$cutoff_date" ]]; then
                rm "$backup_file"
                ((removed++))
            fi
        fi
    done
    
    # Ogranicz liczbę snapshotów
    local snapshot_count=$(ls -d "$BACKUP_DIR/snapshots"/*/ 2>/dev/null | wc -l)
    if [[ $snapshot_count -gt $MAX_BACKUPS ]]; then
        local to_remove=$((snapshot_count - MAX_BACKUPS))
        ls -dt "$BACKUP_DIR/snapshots"/*/ | tail -$to_remove | xargs rm -rf
        ((removed += to_remove))
    fi
    
    # Aktualizuj indeks
    # TODO: Synchronizacja indeksu z rzeczywistymi plikami
    
    log "SUCCESS" "Usunięto $removed starych backupów"
}

# Automatyczny rollback przy błędzie
auto_rollback_on_error() {
    local file="$1"
    local error_code="$2"
    
    if [[ $error_code -ne 0 ]]; then
        log "ERROR" "Błąd przetwarzania $file (kod: $error_code)"
        log "INFO" "Automatyczny rollback..."
        restore_file "$file" "latest"
    fi
}

# === CLI ===

show_help() {
    cat << EOF
I18N Rollback System - Zarządzanie backupami

Użycie: $0 <command> [options]

Komendy:
  init                    Inicjalizacja systemu backup
  backup <file>           Utwórz backup pliku
  restore <file> [ts]     Przywróć plik (ts = timestamp, domyślnie latest)
  snapshot [name]         Utwórz snapshot całego i18n
  restore-snapshot <name> Przywróć z snapshotu
  list [file]             Lista backupów
  cleanup                 Wyczyść stare backupy
  status                  Pokaż status systemu backup

Przykłady:
  $0 backup data-otservbr-global/npc/john.lua
  $0 restore data-otservbr-global/npc/john.lua
  $0 snapshot "przed_zmianami"
  $0 restore-snapshot "przed_zmianami_20251208_180000"
EOF
}

main() {
    init_backup_system
    
    case "$1" in
        init)
            log "SUCCESS" "System backup zainicjalizowany"
            ;;
        backup)
            [[ -z "$2" ]] && { echo "Podaj ścieżkę pliku"; exit 1; }
            backup_file "$WORK_DIR/$2" "manual"
            ;;
        restore)
            [[ -z "$2" ]] && { echo "Podaj ścieżkę pliku"; exit 1; }
            restore_file "$WORK_DIR/$2" "${3:-latest}"
            ;;
        snapshot)
            create_snapshot "${2:-manual}"
            ;;
        restore-snapshot)
            [[ -z "$2" ]] && { echo "Podaj nazwę snapshotu"; exit 1; }
            restore_snapshot "$2"
            ;;
        list)
            list_backups "$2"
            ;;
        cleanup)
            cleanup_old_backups
            ;;
        status)
            echo "=== STATUS SYSTEMU BACKUP ==="
            echo "Katalog: $BACKUP_DIR"
            echo "Backupy plików: $(ls "$BACKUP_DIR/files"/*.bak 2>/dev/null | wc -l)"
            echo "Snapshoty: $(ls -d "$BACKUP_DIR/snapshots"/*/ 2>/dev/null | wc -l)"
            echo "Rozmiar: $(du -sh "$BACKUP_DIR" | cut -f1)"
            ;;
        *)
            show_help
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
