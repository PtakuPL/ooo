#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N C++ PARSER - Ekstrakcja stringów z kodu C++
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
SRC_DIR="$WORK_DIR/src"
OUTPUT_DIR="$WORK_DIR/i18n_analysis/cpp"
OUTPUT_FILE="$OUTPUT_DIR/cpp_strings.json"
REPORT_FILE="$OUTPUT_DIR/cpp_analysis_report.md"

# Wzorce do ekstrakcji (rozszerzone)
declare -a PATTERNS=(
    # Player messages
    'player->sendTextMessage\s*\([^,]+,\s*"([^"]+)"'
    'player->sendChannelMessage\s*\([^,]+,\s*"([^"]+)"'
    'player->sendCreatureSay\s*\([^,]+,\s*"([^"]+)"'
    
    # NPC messages
    'npc->say\s*\([^,]+,\s*"([^"]+)"'
    
    # Console output
    'std::cout\s*<<\s*"([^"]+)"'
    'SPDLOG_[A-Z]+\s*\(\s*"([^"]+)"'
    'g_logger\(\)\.([a-z]+)\s*\(\s*"([^"]+)"'
    
    # Error messages
    'throw\s+[a-zA-Z_]+\s*\(\s*"([^"]+)"'
    'setLastError\s*\(\s*"([^"]+)"'
    
    # Format strings
    'fmt::format\s*\(\s*"([^"]+)"'
    
    # Defines
    '#define\s+[A-Z_]+_MSG\s+"([^"]+)"'
    
    # String literals with message context
    'const\s+(?:std::)?string\s+\w*[Mm]sg\w*\s*=\s*"([^"]+)"'
    'const\s+char\s*\*\s*\w*[Mm]sg\w*\s*=\s*"([^"]+)"'
)

# Wzorce do IGNOROWANIA
declare -a IGNORE_PATTERNS=(
    # Ścieżki plików
    '^\s*[/\\]'
    '^[a-zA-Z]:[/\\]'
    '\.lua$'
    '\.xml$'
    '\.json$'
    
    # SQL
    '^SELECT\s'
    '^INSERT\s'
    '^UPDATE\s'
    '^DELETE\s'
    '^CREATE\s'
    
    # Formaty
    '^%[sdfixX]'
    '^\{\d+\}'
    
    # Techniczne
    '^[0-9]+$'
    '^0x[0-9a-fA-F]+$'
    '^\\[nrt]'
    
    # Zbyt krótkie
    '^.{0,3}$'
)

# === FUNKCJE ===

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Sprawdź czy string powinien być zignorowany
should_ignore() {
    local str="$1"
    
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$str" =~ $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# Ekstrakcja stringów z pojedynczego pliku
extract_from_file() {
    local file="$1"
    local relative_path="${file#$SRC_DIR/}"
    local basename=$(basename "$file" | sed 's/\.[^.]*$//')
    local results=()
    local line_num=0
    local string_count=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        for pattern in "${PATTERNS[@]}"; do
            while [[ "$line" =~ $pattern ]]; do
                local match="${BASH_REMATCH[1]}"
                
                # Pomiń jeśli na liście ignorowanych
                if ! should_ignore "$match"; then
                    ((string_count++))
                    local key="cpp.${basename}.line_${line_num}_${string_count}"
                    
                    # Dodaj do wyników
                    results+=("$(cat << EOF
{
    "key": "$key",
    "value": "$match",
    "file": "$relative_path",
    "line": $line_num,
    "pattern_matched": "$pattern"
}
EOF
)")
                fi
                
                # Usuń dopasowanie i szukaj dalej
                line="${line/${BASH_REMATCH[0]}/}"
            done
        done
    done < "$file"
    
    # Zwróć JSON array
    if [[ ${#results[@]} -gt 0 ]]; then
        printf '%s\n' "${results[@]}" | jq -s '.'
    else
        echo "[]"
    fi
}

# Analiza kontekstu (próba określenia kategorii)
analyze_context() {
    local file="$1"
    local line="$2"
    local string="$3"
    
    local context="unknown"
    
    # Na podstawie ścieżki pliku
    case "$file" in
        *game/*)        context="game" ;;
        *creatures/*)   context="creatures" ;;
        *items/*)       context="items" ;;
        *map/*)         context="map" ;;
        *server/*)      context="server" ;;
        *lua/*)         context="lua_binding" ;;
        *network/*)     context="network" ;;
        *io/*)          context="io" ;;
    esac
    
    # Na podstawie treści
    if [[ "$string" =~ [Ee]rror|[Ff]ailed|[Cc]annot ]]; then
        context="error"
    elif [[ "$string" =~ [Ww]elcome|[Hh]ello|[Gg]reetings ]]; then
        context="greeting"
    elif [[ "$string" =~ [Yy]ou\ have|[Yy]ou\ received ]]; then
        context="notification"
    fi
    
    echo "$context"
}

# Skanowanie całego katalogu src
scan_source_directory() {
    log "Skanowanie katalogu: $SRC_DIR"
    
    mkdir -p "$OUTPUT_DIR"
    
    local all_results="[]"
    local total_files=0
    local total_strings=0
    
    # Znajdź wszystkie pliki C++
    while IFS= read -r file; do
        ((total_files++))
        log "[$total_files] Analizuję: ${file#$SRC_DIR/}"
        
        local file_results=$(extract_from_file "$file")
        local file_count=$(echo "$file_results" | jq 'length')
        ((total_strings += file_count))
        
        # Połącz wyniki
        all_results=$(echo "$all_results" "$file_results" | jq -s '.[0] + .[1]')
        
    done < <(find "$SRC_DIR" -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) 2>/dev/null)
    
    # Zapisz wyniki
    echo "$all_results" | jq '.' > "$OUTPUT_FILE"
    
    log "Zakończono: $total_files plików, $total_strings stringów"
    echo "$total_strings"
}

# Generowanie raportu
generate_report() {
    log "Generowanie raportu..."
    
    cat > "$REPORT_FILE" << EOF
# 📊 Raport Analizy C++ - Stringi do i18n

**Data**: $(date '+%Y-%m-%d %H:%M:%S')
**Katalog źródłowy**: \`$SRC_DIR\`

---

## 📈 Statystyki

| Metryka | Wartość |
|---------|---------|
| Pliki przeanalizowane | $(find "$SRC_DIR" -type f \( -name "*.cpp" -o -name "*.hpp" \) | wc -l) |
| Stringi znalezione | $(jq 'length' "$OUTPUT_FILE") |
| Unikalne stringi | $(jq '[.[].value] | unique | length' "$OUTPUT_FILE") |

---

## 📁 Rozkład według plików

$(jq -r 'group_by(.file) | .[] | "| \(.[0].file) | \(length) |"' "$OUTPUT_FILE" | head -20)

---

## 🏷️ Przykładowe stringi

### Wiadomości gracza
$(jq -r '[.[] | select(.value | test("You|you|Your|your"))] | .[0:5] | .[] | "- \`\(.key)\`: \"\(.value)\""' "$OUTPUT_FILE")

### Błędy
$(jq -r '[.[] | select(.value | test("[Ee]rror|[Ff]ail"))] | .[0:5] | .[] | "- \`\(.key)\`: \"\(.value)\""' "$OUTPUT_FILE")

---

## ⚠️ Do ręcznej weryfikacji

Następujące stringi wymagają ręcznej weryfikacji przed migracją:

$(jq -r '[.[] | select(.value | length > 100)] | .[0:10] | .[] | "1. **\(.file):\(.line)**: \(.value | .[0:50])..."' "$OUTPUT_FILE")

---

## 📋 Następne kroki

1. [ ] Przejrzeć wyekstrahowane stringi
2. [ ] Oznaczyć stringi do tłumaczenia
3. [ ] Oznaczyć stringi techniczne (nie tłumaczyć)
4. [ ] Przygotować mapowanie kluczy
5. [ ] Zaimplementować loader i18n w C++

---

*Raport wygenerowany automatycznie przez i18n_cpp_parser.sh*
EOF

    log "Raport zapisany: $REPORT_FILE"
}

# Eksport do formatu dla workera
export_for_worker() {
    local output="$OUTPUT_DIR/cpp_strings_for_worker.json"
    
    jq '[.[] | {
        key: .key,
        value: .value,
        category: "cpp",
        source_file: .file,
        source_line: .line,
        needs_translation: true,
        reviewed: false
    }]' "$OUTPUT_FILE" > "$output"
    
    log "Eksportowano do: $output"
}

# === GŁÓWNA LOGIKA ===

main() {
    case "$1" in
        scan)
            scan_source_directory
            generate_report
            ;;
        report)
            generate_report
            ;;
        export)
            export_for_worker
            ;;
        file)
            [[ -z "$2" ]] && { echo "Podaj ścieżkę pliku"; exit 1; }
            extract_from_file "$2" | jq '.'
            ;;
        stats)
            if [[ -f "$OUTPUT_FILE" ]]; then
                echo "=== STATYSTYKI ==="
                echo "Łącznie stringów: $(jq 'length' "$OUTPUT_FILE")"
                echo "Plików źródłowych: $(jq '[.[].file] | unique | length' "$OUTPUT_FILE")"
                echo ""
                echo "=== TOP 10 PLIKÓW ==="
                jq -r 'group_by(.file) | sort_by(-length) | .[0:10] | .[] | "\(length)\t\(.[0].file)"' "$OUTPUT_FILE"
            else
                echo "Brak danych. Uruchom: $0 scan"
            fi
            ;;
        *)
            cat << EOF
I18N C++ Parser - Ekstrakcja stringów z kodu C++

Użycie: $0 <command>

Komendy:
  scan        Skanuj katalog src/ i wyeksportuj stringi
  report      Wygeneruj raport Markdown
  export      Eksportuj do formatu dla workera
  file <path> Analizuj pojedynczy plik
  stats       Pokaż statystyki

Przykłady:
  $0 scan
  $0 file src/game/game.cpp
  $0 stats
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
