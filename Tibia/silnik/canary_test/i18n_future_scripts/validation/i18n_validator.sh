#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N VALIDATOR - Walidacja tłumaczeń
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
I18N_DIR="$WORK_DIR/i18n"
REPORT_DIR="$WORK_DIR/i18n_analysis/validation"

# Wzorce zmiennych do sprawdzenia
VARIABLE_PATTERNS=(
    '%s'        # String
    '%d'        # Integer
    '%f'        # Float
    '%i'        # Integer
    '%x'        # Hex
    '{[0-9]+}'  # Numbered placeholders {0}, {1}
    '{[a-zA-Z_]+}'  # Named placeholders {name}, {player}
    '{{[^}]+}}' # Lua/Mustache style
    '\$[a-zA-Z_]+'  # PHP style
)

# === FUNKCJE ===

log() {
    local level="$1"
    local message="$2"
    echo "[$level] $message"
}

# Wyekstrahuj zmienne z tekstu
extract_variables() {
    local text="$1"
    local vars=()
    
    for pattern in "${VARIABLE_PATTERNS[@]}"; do
        while [[ "$text" =~ ($pattern) ]]; do
            vars+=("${BASH_REMATCH[1]}")
            text="${text/${BASH_REMATCH[1]}/}"
        done
    done
    
    # Sortuj dla porównania
    printf '%s\n' "${vars[@]}" | sort
}

# Porównaj zmienne w dwóch tekstach
compare_variables() {
    local original="$1"
    local translation="$2"
    
    local orig_vars=$(extract_variables "$original")
    local trans_vars=$(extract_variables "$translation")
    
    # Sprawdź brakujące
    local missing=$(comm -23 <(echo "$orig_vars") <(echo "$trans_vars") | tr '\n' ', ')
    
    # Sprawdź dodatkowe
    local extra=$(comm -13 <(echo "$orig_vars") <(echo "$trans_vars") | tr '\n' ', ')
    
    if [[ -n "$missing" || -n "$extra" ]]; then
        echo "FAIL"
        echo "missing:$missing"
        echo "extra:$extra"
        return 1
    fi
    
    echo "OK"
    return 0
}

# Walidacja pojedynczego klucza
validate_key() {
    local key="$1"
    local original="$2"
    local translation="$3"
    local errors=()
    
    # 1. Sprawdź zmienne
    local var_check=$(compare_variables "$original" "$translation")
    if [[ "$var_check" != "OK" ]]; then
        errors+=("VARIABLES: $var_check")
    fi
    
    # 2. Sprawdź długość (tłumaczenie nie powinno być >2x dłuższe lub <0.3x krótsze)
    local orig_len=${#original}
    local trans_len=${#translation}
    
    if [[ $orig_len -gt 0 ]]; then
        local ratio=$(echo "scale=2; $trans_len / $orig_len" | bc)
        
        if (( $(echo "$ratio > 3.0" | bc -l) )); then
            errors+=("LENGTH: Translation too long (${ratio}x)")
        elif (( $(echo "$ratio < 0.2" | bc -l) )); then
            errors+=("LENGTH: Translation too short (${ratio}x)")
        fi
    fi
    
    # 3. Sprawdź puste tłumaczenie
    if [[ -z "$translation" || "$translation" == "null" ]]; then
        errors+=("EMPTY: Translation is empty")
    fi
    
    # 4. Sprawdź niedokończone tłumaczenie
    if [[ "$translation" == *"[NEEDS_TRANSLATION]"* ]]; then
        errors+=("INCOMPLETE: Needs translation")
    fi
    
    # 5. Sprawdź znaki specjalne HTML (jeśli oryginał nie ma)
    if [[ "$original" != *"<"* && "$translation" == *"<"* ]]; then
        errors+=("HTML: Unexpected HTML tags in translation")
    fi
    
    # Zwróć wynik
    if [[ ${#errors[@]} -gt 0 ]]; then
        printf '%s\n' "${errors[@]}"
        return 1
    fi
    
    return 0
}

# Walidacja pliku JSON
validate_json_file() {
    local source_file="$1"
    local target_file="$2"
    local lang="$3"
    
    if [[ ! -f "$source_file" || ! -f "$target_file" ]]; then
        log "ERROR" "Brak pliku: $source_file lub $target_file"
        return 1
    fi
    
    local errors=()
    local warnings=()
    local valid=0
    local invalid=0
    
    # Iteruj przez klucze
    while IFS= read -r key; do
        local original=$(jq -r --arg k "$key" '.[$k]' "$source_file")
        local translation=$(jq -r --arg k "$key" '.[$k] // empty' "$target_file")
        
        if [[ -z "$translation" ]]; then
            warnings+=("$key: Missing translation")
            continue
        fi
        
        local validation=$(validate_key "$key" "$original" "$translation")
        
        if [[ $? -eq 0 ]]; then
            ((valid++))
        else
            ((invalid++))
            errors+=("$key: $validation")
        fi
    done < <(jq -r 'keys[]' "$source_file")
    
    # Zwróć statystyki
    echo "valid:$valid"
    echo "invalid:$invalid"
    echo "warnings:${#warnings[@]}"
    
    if [[ ${#errors[@]} -gt 0 ]]; then
        printf 'error:%s\n' "${errors[@]}"
    fi
}

# Walidacja całego języka
validate_language() {
    local lang="$1"
    local source_dir="$I18N_DIR/en"
    local target_dir="$I18N_DIR/$lang"
    
    log "INFO" "Walidacja języka: $lang"
    
    mkdir -p "$REPORT_DIR"
    local report_file="$REPORT_DIR/validation_${lang}.md"
    
    cat > "$report_file" << EOF
# 📋 Raport Walidacji: $lang

**Data**: $(date '+%Y-%m-%d %H:%M:%S')

---

## Wyniki

EOF
    
    local total_valid=0
    local total_invalid=0
    local total_warnings=0
    
    for source_json in "$source_dir"/*.json; do
        local filename=$(basename "$source_json")
        local target_json="$target_dir/$filename"
        
        echo "### $filename" >> "$report_file"
        echo "" >> "$report_file"
        
        if [[ ! -f "$target_json" ]]; then
            echo "⚠️ Plik nie istnieje" >> "$report_file"
            continue
        fi
        
        local result=$(validate_json_file "$source_json" "$target_json" "$lang")
        
        local valid=$(echo "$result" | grep "^valid:" | cut -d: -f2)
        local invalid=$(echo "$result" | grep "^invalid:" | cut -d: -f2)
        local warnings=$(echo "$result" | grep "^warnings:" | cut -d: -f2)
        
        ((total_valid += valid))
        ((total_invalid += invalid))
        ((total_warnings += warnings))
        
        echo "- ✅ Poprawne: $valid" >> "$report_file"
        echo "- ❌ Błędne: $invalid" >> "$report_file"
        echo "- ⚠️ Ostrzeżenia: $warnings" >> "$report_file"
        
        # Lista błędów
        local errors=$(echo "$result" | grep "^error:" | cut -d: -f2-)
        if [[ -n "$errors" ]]; then
            echo "" >> "$report_file"
            echo "**Błędy:**" >> "$report_file"
            echo "\`\`\`" >> "$report_file"
            echo "$errors" >> "$report_file"
            echo "\`\`\`" >> "$report_file"
        fi
        
        echo "" >> "$report_file"
    done
    
    # Podsumowanie
    cat >> "$report_file" << EOF
---

## Podsumowanie

| Metryka | Wartość |
|---------|---------|
| ✅ Poprawne | $total_valid |
| ❌ Błędne | $total_invalid |
| ⚠️ Ostrzeżenia | $total_warnings |
| **Wskaźnik poprawności** | $(echo "scale=1; $total_valid * 100 / ($total_valid + $total_invalid)" | bc)% |
EOF
    
    log "SUCCESS" "Raport: $report_file"
}

# Walidacja wszystkich języków
validate_all() {
    log "INFO" "Walidacja wszystkich języków..."
    
    for lang_dir in "$I18N_DIR"/*/; do
        local lang=$(basename "$lang_dir")
        [[ "$lang" == "en" ]] && continue
        
        validate_language "$lang"
    done
    
    # Generuj podsumowanie
    generate_summary_report
}

# Raport podsumowujący
generate_summary_report() {
    local summary_file="$REPORT_DIR/validation_summary.md"
    
    cat > "$summary_file" << EOF
# 📊 Podsumowanie Walidacji i18n

**Data**: $(date '+%Y-%m-%d %H:%M:%S')

---

## Wyniki według języków

| Język | Poprawne | Błędne | Wskaźnik |
|-------|----------|--------|----------|
EOF
    
    for report in "$REPORT_DIR"/validation_*.md; do
        [[ "$report" == *"summary"* ]] && continue
        
        local lang=$(basename "$report" | sed 's/validation_//;s/.md//')
        local valid=$(grep "✅ Poprawne" "$report" | tail -1 | grep -oP '\d+')
        local invalid=$(grep "❌ Błędne" "$report" | tail -1 | grep -oP '\d+')
        local rate=$(grep "Wskaźnik" "$report" | tail -1 | grep -oP '\d+\.?\d*')
        
        echo "| $lang | $valid | $invalid | ${rate}% |" >> "$summary_file"
    done
    
    log "SUCCESS" "Podsumowanie: $summary_file"
}

# Szybki test jednego klucza
quick_test() {
    local original="$1"
    local translation="$2"
    
    echo "Original: $original"
    echo "Translation: $translation"
    echo ""
    
    local result=$(validate_key "test" "$original" "$translation")
    
    if [[ $? -eq 0 ]]; then
        echo "✅ VALID"
    else
        echo "❌ INVALID"
        echo "$result"
    fi
}

# === CLI ===

main() {
    case "$1" in
        file)
            [[ -z "$2" || -z "$3" ]] && { echo "Użycie: $0 file <source.json> <target.json>"; exit 1; }
            validate_json_file "$2" "$3" "unknown"
            ;;
        lang)
            [[ -z "$2" ]] && { echo "Użycie: $0 lang <language_code>"; exit 1; }
            validate_language "$2"
            ;;
        all)
            validate_all
            ;;
        test)
            [[ -z "$2" || -z "$3" ]] && { echo "Użycie: $0 test <original> <translation>"; exit 1; }
            quick_test "$2" "$3"
            ;;
        summary)
            generate_summary_report
            ;;
        *)
            cat << EOF
I18N Validator - Walidacja tłumaczeń

Użycie: $0 <command> [options]

Komendy:
  file <src.json> <tgt.json>   Waliduj parę plików
  lang <code>                   Waliduj cały język
  all                           Waliduj wszystkie języki
  test <orig> <trans>           Szybki test jednej pary
  summary                       Generuj podsumowanie

Przykłady:
  $0 file i18n/en/npc.json i18n/pl/npc.json
  $0 lang pl
  $0 test "You have %d gold" "Masz %d złota"
  $0 all
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
