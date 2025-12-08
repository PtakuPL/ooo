#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N PHP PARSER - Ekstrakcja stringów z kodu PHP
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
PHP_DIR="$WORK_DIR/html_copy"
OUTPUT_DIR="$WORK_DIR/i18n_analysis/php"
OUTPUT_FILE="$OUTPUT_DIR/php_strings.json"
REPORT_FILE="$OUTPUT_DIR/php_analysis_report.md"

# Wzorce do ekstrakcji
declare -a PATTERNS=(
    # Echo i print
    "echo\s+['\"]([^'\"]+)['\"]"
    "print\s+['\"]([^'\"]+)['\"]"
    
    # Przypisania do zmiennych z msg/text/error w nazwie
    '\$\w*[Mm]sg\w*\s*=\s*["\x27]([^"\x27]+)["\x27]'
    '\$\w*[Tt]ext\w*\s*=\s*["\x27]([^"\x27]+)["\x27]'
    '\$\w*[Ee]rror\w*\s*=\s*["\x27]([^"\x27]+)["\x27]'
    '\$\w*[Ll]abel\w*\s*=\s*["\x27]([^"\x27]+)["\x27]'
    
    # Tablice językowe
    '\$_\[["\x27]([^"\x27]+)["\x27]\]\s*=\s*["\x27]([^"\x27]+)["\x27]'
    '\$lang\[["\x27]([^"\x27]+)["\x27]\]\s*=\s*["\x27]([^"\x27]+)["\x27]'
    
    # Define
    "define\s*\(\s*['\"]([A-Z_]+)['\"],\s*['\"]([^'\"]+)['\"]"
    
    # Smarty/Twig przypisania
    '\$smarty->assign\s*\(["\x27]([^"\x27]+)["\x27],\s*["\x27]([^"\x27]+)["\x27]'
    
    # Atrybuty HTML w PHP
    'title\s*=\s*["\x27]([^"\x27]+)["\x27]'
    'placeholder\s*=\s*["\x27]([^"\x27]+)["\x27]'
    'alt\s*=\s*["\x27]([^"\x27]+)["\x27]'
    'value\s*=\s*["\x27]([^"\x27]+)["\x27]'
    
    # Funkcje tłumaczeń (jeśli istnieją)
    '__\s*\(\s*["\x27]([^"\x27]+)["\x27]'
    '_e\s*\(\s*["\x27]([^"\x27]+)["\x27]'
    'gettext\s*\(\s*["\x27]([^"\x27]+)["\x27]'
)

# Wzorce do IGNOROWANIA
declare -a IGNORE_PATTERNS=(
    # SQL
    '^SELECT\s'
    '^INSERT\s'
    '^UPDATE\s'
    '^DELETE\s'
    '^CREATE\s'
    '^ALTER\s'
    
    # Ścieżki
    '^[/.]'
    '^https?://'
    '\.php$'
    '\.css$'
    '\.js$'
    
    # HTML/CSS techniczne
    '^<'
    '^#[0-9a-fA-F]{3,6}$'
    '^rgb\('
    '^[0-9]+px$'
    
    # Zmienne PHP
    '^\$'
    
    # Zbyt krótkie
    '^.{0,2}$'
    
    # Tylko cyfry/znaki
    '^[0-9\s.,;:-]+$'
    '^[!@#$%^&*()]+$'
)

# === FUNKCJE ===

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

should_ignore() {
    local str="$1"
    
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$str" =~ $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# Kategoryzacja na podstawie ścieżki
get_category() {
    local file="$1"
    
    case "$file" in
        *admin*)        echo "admin" ;;
        *login*)        echo "auth" ;;
        *register*)     echo "auth" ;;
        *account*)      echo "account" ;;
        *character*)    echo "character" ;;
        *guild*)        echo "guild" ;;
        *shop*)         echo "shop" ;;
        *news*)         echo "news" ;;
        *forum*)        echo "forum" ;;
        *highscores*)   echo "highscores" ;;
        *template*)     echo "template" ;;
        *)              echo "general" ;;
    esac
}

# Ekstrakcja z pliku PHP
extract_from_php_file() {
    local file="$1"
    local relative_path="${file#$PHP_DIR/}"
    local basename=$(basename "$file" .php)
    local category=$(get_category "$file")
    local results=()
    local string_count=0
    
    # Użyj grep z Perl regex dla lepszej ekstrakcji
    for pattern in "${PATTERNS[@]}"; do
        while IFS= read -r match; do
            if [[ -n "$match" ]] && ! should_ignore "$match"; then
                ((string_count++))
                local key="php.${category}.${basename}.msg_${string_count}"
                
                results+=("$(cat << EOF
{
    "key": "$key",
    "value": $(echo "$match" | jq -Rs '.'),
    "file": "$relative_path",
    "category": "$category",
    "pattern": "$pattern"
}
EOF
)")
            fi
        done < <(grep -oP "$pattern" "$file" 2>/dev/null | sed "s/.*['\"]\\([^'\"]*\\)['\"].*/\\1/")
    done
    
    if [[ ${#results[@]} -gt 0 ]]; then
        printf '%s\n' "${results[@]}" | jq -s '.'
    else
        echo "[]"
    fi
}

# Ekstrakcja z plików HTML/TPL
extract_from_template() {
    local file="$1"
    local relative_path="${file#$PHP_DIR/}"
    local basename=$(basename "$file" | sed 's/\.[^.]*$//')
    local results=()
    local string_count=0
    
    # Tekst między tagami HTML
    while IFS= read -r text; do
        if [[ -n "$text" ]] && ! should_ignore "$text"; then
            ((string_count++))
            local key="tpl.${basename}.text_${string_count}"
            
            results+=("$(cat << EOF
{
    "key": "$key",
    "value": $(echo "$text" | jq -Rs '.'),
    "file": "$relative_path",
    "type": "html_text"
}
EOF
)")
        fi
    done < <(sed -n 's/<[^>]*>//gp' "$file" | grep -v '^[[:space:]]*$' | head -100)
    
    # Atrybuty title, alt, placeholder
    for attr in title alt placeholder label; do
        while IFS= read -r value; do
            if [[ -n "$value" ]] && ! should_ignore "$value"; then
                ((string_count++))
                local key="tpl.${basename}.${attr}_${string_count}"
                
                results+=("$(cat << EOF
{
    "key": "$key",
    "value": $(echo "$value" | jq -Rs '.'),
    "file": "$relative_path",
    "type": "html_attr_$attr"
}
EOF
)")
            fi
        done < <(grep -oP "${attr}\s*=\s*['\"]\\K[^'\"]+(?=['\"])" "$file" 2>/dev/null)
    done
    
    if [[ ${#results[@]} -gt 0 ]]; then
        printf '%s\n' "${results[@]}" | jq -s '.'
    else
        echo "[]"
    fi
}

# Skanowanie katalogu
scan_php_directory() {
    log "Skanowanie katalogu: $PHP_DIR"
    
    mkdir -p "$OUTPUT_DIR"
    
    local all_results="[]"
    local total_files=0
    local total_strings=0
    
    # Pliki PHP
    while IFS= read -r file; do
        ((total_files++))
        
        local file_results=$(extract_from_php_file "$file")
        local file_count=$(echo "$file_results" | jq 'length')
        ((total_strings += file_count))
        
        all_results=$(echo "$all_results" "$file_results" | jq -s '.[0] + .[1]')
        
        if ((total_files % 50 == 0)); then
            log "Przetworzono $total_files plików..."
        fi
    done < <(find "$PHP_DIR" -type f -name "*.php" 2>/dev/null)
    
    # Pliki szablonów
    while IFS= read -r file; do
        ((total_files++))
        
        local file_results=$(extract_from_template "$file")
        local file_count=$(echo "$file_results" | jq 'length')
        ((total_strings += file_count))
        
        all_results=$(echo "$all_results" "$file_results" | jq -s '.[0] + .[1]')
    done < <(find "$PHP_DIR" -type f \( -name "*.html" -o -name "*.tpl" -o -name "*.twig" \) 2>/dev/null)
    
    # Zapisz wyniki
    echo "$all_results" | jq '.' > "$OUTPUT_FILE"
    
    log "Zakończono: $total_files plików, $total_strings stringów"
}

# Generowanie raportu
generate_report() {
    cat > "$REPORT_FILE" << EOF
# 📊 Raport Analizy PHP/HTML - Stringi do i18n

**Data**: $(date '+%Y-%m-%d %H:%M:%S')
**Katalog źródłowy**: \`$PHP_DIR\`

---

## 📈 Statystyki

| Metryka | Wartość |
|---------|---------|
| Stringi znalezione | $(jq 'length' "$OUTPUT_FILE") |
| Unikalne stringi | $(jq '[.[].value] | unique | length' "$OUTPUT_FILE") |

---

## 🏷️ Rozkład według kategorii

$(jq -r 'group_by(.category) | .[] | "| \(.[0].category // "unknown") | \(length) |"' "$OUTPUT_FILE")

---

## 📁 TOP 10 plików z najwięcej stringami

$(jq -r 'group_by(.file) | sort_by(-length) | .[0:10] | .[] | "| \(.[0].file) | \(length) |"' "$OUTPUT_FILE")

---

## 💡 Sugestie

1. **Priorytet wysoki**: Stringi w plikach login/register (auth)
2. **Priorytet średni**: Stringi w account/character
3. **Priorytet niski**: Stringi admin (tylko dla adminów)

---

*Raport wygenerowany automatycznie*
EOF

    log "Raport: $REPORT_FILE"
}

# Eksport do JSON dla tłumaczeń
export_for_translation() {
    local output="$OUTPUT_DIR/php_translation_ready.json"
    
    # Grupuj według kategorii i utwórz strukturę
    jq 'group_by(.category) | 
        map({
            (.[0].category): (
                [.[] | {(.key): .value}] | add
            )
        }) | add' "$OUTPUT_FILE" > "$output"
    
    log "Eksportowano: $output"
}

# === CLI ===

main() {
    case "$1" in
        scan)
            scan_php_directory
            generate_report
            ;;
        report)
            generate_report
            ;;
        export)
            export_for_translation
            ;;
        file)
            [[ -z "$2" ]] && { echo "Podaj plik"; exit 1; }
            if [[ "$2" == *.php ]]; then
                extract_from_php_file "$2" | jq '.'
            else
                extract_from_template "$2" | jq '.'
            fi
            ;;
        stats)
            if [[ -f "$OUTPUT_FILE" ]]; then
                echo "=== STATYSTYKI PHP ==="
                echo "Łącznie: $(jq 'length' "$OUTPUT_FILE")"
                echo ""
                echo "=== WEDŁUG KATEGORII ==="
                jq -r 'group_by(.category) | .[] | "\(.[0].category): \(length)"' "$OUTPUT_FILE"
            else
                echo "Brak danych. Uruchom: $0 scan"
            fi
            ;;
        *)
            cat << EOF
I18N PHP Parser - Ekstrakcja stringów z PHP/HTML

Użycie: $0 <command>

Komendy:
  scan        Skanuj html_copy/ i wyeksportuj stringi
  report      Wygeneruj raport
  export      Eksportuj do formatu tłumaczeń
  file <path> Analizuj pojedynczy plik
  stats       Pokaż statystyki
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
