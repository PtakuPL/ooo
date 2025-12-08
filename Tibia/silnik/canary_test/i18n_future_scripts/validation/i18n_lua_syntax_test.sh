#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N LUA SYNTAX TEST - Walidacja składni Lua po modyfikacji
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
REPORT_DIR="$WORK_DIR/i18n_analysis/lua_tests"
ERROR_LOG="$REPORT_DIR/syntax_errors.log"

# Ścieżka do luac (Lua compiler) - sprawdź wersję
LUAC=${LUAC:-$(which luac 2>/dev/null || which luac5.4 2>/dev/null || which luac5.3 2>/dev/null)}

# === FUNKCJE ===

log() {
    echo "[$(date '+%H:%M:%S')] [$1] $2"
}

# Sprawdź czy luac jest dostępny
check_luac() {
    if [[ -z "$LUAC" || ! -x "$LUAC" ]]; then
        log "ERROR" "luac nie znaleziony!"
        log "INFO" "Instalacja: sudo apt install lua5.4"
        return 1
    fi
    
    log "INFO" "Używam: $LUAC ($($LUAC -v 2>&1 | head -1))"
    return 0
}

# Test składni pojedynczego pliku
test_lua_syntax() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found"
        return 1
    fi
    
    # Użyj luac -p (parse only, no code generation)
    local output=$($LUAC -p "$file" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo "OK"
        return 0
    else
        echo "FAIL: $output"
        return 1
    fi
}

# Test z przywróceniem przy błędzie
test_with_rollback() {
    local file="$1"
    local backup_file="${file}.bak"
    
    # Sprawdź składnię
    local result=$(test_lua_syntax "$file")
    
    if [[ "$result" != "OK" ]]; then
        log "ERROR" "Błąd składni: $file"
        log "ERROR" "$result"
        
        # Przywróć z backup jeśli istnieje
        if [[ -f "$backup_file" ]]; then
            log "INFO" "Przywracam z backup..."
            cp "$backup_file" "$file"
            
            # Sprawdź czy backup jest OK
            local backup_result=$(test_lua_syntax "$file")
            if [[ "$backup_result" == "OK" ]]; then
                log "SUCCESS" "Przywrócono poprawny plik"
            else
                log "FATAL" "Backup również uszkodzony!"
            fi
        fi
        
        return 1
    fi
    
    return 0
}

# Test wszystkich plików w katalogu
test_directory() {
    local dir="$1"
    local total=0
    local passed=0
    local failed=0
    local failed_files=()
    
    log "INFO" "Testowanie katalogu: $dir"
    
    while IFS= read -r file; do
        ((total++))
        
        local result=$(test_lua_syntax "$file")
        
        if [[ "$result" == "OK" ]]; then
            ((passed++))
        else
            ((failed++))
            failed_files+=("$file: $result")
        fi
        
        # Pokaż postęp
        if ((total % 100 == 0)); then
            log "INFO" "Przetestowano $total plików..."
        fi
    done < <(find "$dir" -name "*.lua" -type f 2>/dev/null)
    
    # Podsumowanie
    log "INFO" "═══════════════════════════════════════"
    log "INFO" "Łącznie: $total"
    log "SUCCESS" "Poprawne: $passed"
    
    if [[ $failed -gt 0 ]]; then
        log "ERROR" "Błędne: $failed"
        
        # Zapisz błędy do pliku
        mkdir -p "$REPORT_DIR"
        printf '%s\n' "${failed_files[@]}" > "$ERROR_LOG"
        log "INFO" "Lista błędów: $ERROR_LOG"
    fi
    
    return $failed
}

# Szczegółowa analiza błędu
analyze_error() {
    local file="$1"
    
    log "INFO" "Analiza błędu: $file"
    
    # Pobierz szczegóły błędu
    local error_output=$($LUAC -p "$file" 2>&1)
    
    echo ""
    echo "=== BŁĄD SKŁADNI ==="
    echo "$error_output"
    echo ""
    
    # Wyekstrahuj numer linii
    local line_num=$(echo "$error_output" | grep -oP ':\d+:' | grep -oP '\d+' | head -1)
    
    if [[ -n "$line_num" ]]; then
        echo "=== KONTEKST (linia $line_num ±5) ==="
        local start=$((line_num - 5))
        [[ $start -lt 1 ]] && start=1
        local end=$((line_num + 5))
        
        sed -n "${start},${end}p" "$file" | nl -ba -v $start | while read -r num content; do
            if [[ $num -eq $line_num ]]; then
                echo ">>> $num: $content"
            else
                echo "    $num: $content"
            fi
        done
    fi
    
    echo ""
    echo "=== SUGESTIE ==="
    
    # Analiza typowych błędów
    if [[ "$error_output" == *"unexpected symbol"* ]]; then
        echo "- Sprawdź brakujące przecinki, nawiasy lub cudzysłowy"
    fi
    if [[ "$error_output" == *"'end' expected"* ]]; then
        echo "- Brakuje 'end' dla bloku if/for/while/function"
    fi
    if [[ "$error_output" == *"'then' expected"* ]]; then
        echo "- Brakuje 'then' po warunku if"
    fi
    if [[ "$error_output" == *"unfinished string"* ]]; then
        echo "- Niezamknięty string - sprawdź cudzysłowy"
    fi
}

# Batch test przed/po modyfikacji
batch_pre_post_test() {
    local files_list="$1"
    
    log "INFO" "Test batch przed/po modyfikacji..."
    
    local results=()
    
    while IFS= read -r file; do
        local before_result=$(test_lua_syntax "$file")
        local before_ok=$?
        
        # Tutaj byłaby modyfikacja...
        # modify_file "$file"
        
        local after_result=$(test_lua_syntax "$file")
        local after_ok=$?
        
        if [[ $before_ok -eq 0 && $after_ok -ne 0 ]]; then
            results+=("REGRESSION: $file - było OK, teraz błąd")
        elif [[ $before_ok -ne 0 && $after_ok -eq 0 ]]; then
            results+=("FIXED: $file - był błąd, teraz OK")
        elif [[ $after_ok -ne 0 ]]; then
            results+=("STILL_BROKEN: $file")
        fi
    done < "$files_list"
    
    printf '%s\n' "${results[@]}"
}

# Generowanie raportu
generate_report() {
    local dir="$1"
    local report_file="$REPORT_DIR/lua_syntax_report.md"
    
    mkdir -p "$REPORT_DIR"
    
    cat > "$report_file" << EOF
# 📋 Raport Testów Składni Lua

**Data**: $(date '+%Y-%m-%d %H:%M:%S')
**Katalog**: \`$dir\`

---

## Wyniki

EOF
    
    test_directory "$dir" >> "$report_file" 2>&1
    
    if [[ -f "$ERROR_LOG" ]]; then
        echo "" >> "$report_file"
        echo "## ❌ Lista błędów" >> "$report_file"
        echo "" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        cat "$ERROR_LOG" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
    fi
    
    log "SUCCESS" "Raport: $report_file"
}

# === CLI ===

main() {
    check_luac || exit 1
    
    case "$1" in
        file)
            [[ -z "$2" ]] && { echo "Użycie: $0 file <path.lua>"; exit 1; }
            result=$(test_lua_syntax "$2")
            echo "$result"
            [[ "$result" == "OK" ]] && exit 0 || exit 1
            ;;
        dir)
            [[ -z "$2" ]] && { echo "Użycie: $0 dir <directory>"; exit 1; }
            test_directory "$2"
            ;;
        analyze)
            [[ -z "$2" ]] && { echo "Użycie: $0 analyze <path.lua>"; exit 1; }
            analyze_error "$2"
            ;;
        report)
            dir="${2:-$WORK_DIR/data-otservbr-global}"
            generate_report "$dir"
            ;;
        all)
            log "INFO" "Test wszystkich katalogów Lua..."
            test_directory "$WORK_DIR/data-otservbr-global"
            test_directory "$WORK_DIR/data-canary"
            test_directory "$WORK_DIR/data"
            ;;
        *)
            cat << EOF
I18N Lua Syntax Test - Walidacja składni Lua

Użycie: $0 <command> [options]

Komendy:
  file <path>      Test pojedynczego pliku
  dir <directory>  Test wszystkich .lua w katalogu
  analyze <path>   Szczegółowa analiza błędu
  report [dir]     Generuj raport
  all              Test wszystkich katalogów

Przykłady:
  $0 file data-otservbr-global/npc/john.lua
  $0 dir data-otservbr-global/scripts
  $0 analyze broken_file.lua
  $0 report
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
