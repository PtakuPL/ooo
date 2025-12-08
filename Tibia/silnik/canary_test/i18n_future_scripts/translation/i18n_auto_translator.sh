#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# I18N AUTO TRANSLATOR - Automatyczne tłumaczenie przez API
# ═══════════════════════════════════════════════════════════════════════════════
# Status: SZKIC - NIE ZAIMPLEMENTOWANY
# Wersja: 1.0-draft
# ═══════════════════════════════════════════════════════════════════════════════

# === KONFIGURACJA ===
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
I18N_DIR="$WORK_DIR/i18n"
CONFIG_FILE="$WORK_DIR/i18n_future_scripts/translation/config/translation_config.json"
CACHE_FILE="$WORK_DIR/.i18n_translation_cache.json"

# Domyślna konfiguracja
TRANSLATION_API=${TRANSLATION_API:-"libretranslate"}
RATE_LIMIT=${RATE_LIMIT:-10}  # requests per second
BATCH_SIZE=${BATCH_SIZE:-50}  # strings per batch

# API endpoints
declare -A API_ENDPOINTS=(
    ["libretranslate"]="https://libretranslate.com/translate"
    ["lingva"]="https://lingva.ml/api/v1"
    ["mymemory"]="https://api.mymemory.translated.net/get"
)

# Mapowanie kodów języków
declare -A LANG_CODES=(
    ["pl"]="pl" ["de"]="de" ["es"]="es" ["pt"]="pt" ["fr"]="fr"
    ["it"]="it" ["nl"]="nl" ["ru"]="ru" ["uk"]="uk" ["cs"]="cs"
    ["zh"]="zh" ["ja"]="ja" ["ko"]="ko" ["ar"]="ar" ["tr"]="tr"
)

# === FUNKCJE ===

log() {
    echo "[$(date '+%H:%M:%S')] [$1] $2"
}

# Inicjalizacja cache
init_cache() {
    if [[ ! -f "$CACHE_FILE" ]]; then
        echo '{"translations": {}, "stats": {"hits": 0, "misses": 0}}' > "$CACHE_FILE"
    fi
}

# Sprawdź cache
check_cache() {
    local text="$1"
    local target_lang="$2"
    local cache_key=$(echo -n "${text}|${target_lang}" | md5sum | cut -d' ' -f1)
    
    local cached=$(jq -r --arg key "$cache_key" '.translations[$key] // empty' "$CACHE_FILE" 2>/dev/null)
    
    if [[ -n "$cached" ]]; then
        # Increment hits
        jq '.stats.hits += 1' "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
        echo "$cached"
        return 0
    fi
    
    jq '.stats.misses += 1' "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
    return 1
}

# Zapisz do cache
save_to_cache() {
    local text="$1"
    local target_lang="$2"
    local translation="$3"
    local cache_key=$(echo -n "${text}|${target_lang}" | md5sum | cut -d' ' -f1)
    
    jq --arg key "$cache_key" --arg val "$translation" \
        '.translations[$key] = $val' "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
}

# === API TRANSLATORS ===

# LibreTranslate API
translate_libretranslate() {
    local text="$1"
    local source_lang="${2:-en}"
    local target_lang="$3"
    local api_key="${LIBRETRANSLATE_API_KEY:-}"
    
    local response=$(curl -s -X POST "${API_ENDPOINTS[libretranslate]}" \
        -H "Content-Type: application/json" \
        -d "{
            \"q\": $(echo "$text" | jq -Rs '.'),
            \"source\": \"$source_lang\",
            \"target\": \"$target_lang\",
            \"api_key\": \"$api_key\"
        }")
    
    echo "$response" | jq -r '.translatedText // empty'
}

# Lingva Translate API (darmowe)
translate_lingva() {
    local text="$1"
    local source_lang="${2:-en}"
    local target_lang="$3"
    
    local encoded_text=$(echo "$text" | jq -sRr @uri)
    local response=$(curl -s "${API_ENDPOINTS[lingva]}/${source_lang}/${target_lang}/${encoded_text}")
    
    echo "$response" | jq -r '.translation // empty'
}

# MyMemory API (darmowe, 1000/day)
translate_mymemory() {
    local text="$1"
    local source_lang="${2:-en}"
    local target_lang="$3"
    
    local encoded_text=$(echo "$text" | jq -sRr @uri)
    local response=$(curl -s "${API_ENDPOINTS[mymemory]}?q=${encoded_text}&langpair=${source_lang}|${target_lang}")
    
    echo "$response" | jq -r '.responseData.translatedText // empty'
}

# Główna funkcja tłumaczenia
translate() {
    local text="$1"
    local target_lang="$2"
    local source_lang="${3:-en}"
    
    # Sprawdź cache
    local cached=$(check_cache "$text" "$target_lang")
    if [[ -n "$cached" ]]; then
        echo "$cached"
        return 0
    fi
    
    # Rate limiting
    sleep $(echo "scale=3; 1/$RATE_LIMIT" | bc)
    
    # Wybierz API
    local translation=""
    case "$TRANSLATION_API" in
        libretranslate)
            translation=$(translate_libretranslate "$text" "$source_lang" "$target_lang")
            ;;
        lingva)
            translation=$(translate_lingva "$text" "$source_lang" "$target_lang")
            ;;
        mymemory)
            translation=$(translate_mymemory "$text" "$source_lang" "$target_lang")
            ;;
        *)
            log "ERROR" "Nieznane API: $TRANSLATION_API"
            return 1
            ;;
    esac
    
    if [[ -n "$translation" ]]; then
        save_to_cache "$text" "$target_lang" "$translation"
        echo "$translation"
        return 0
    fi
    
    return 1
}

# Tłumaczenie pliku JSON
translate_json_file() {
    local source_file="$1"
    local target_lang="$2"
    local output_file="$3"
    
    if [[ ! -f "$source_file" ]]; then
        log "ERROR" "Plik nie istnieje: $source_file"
        return 1
    fi
    
    log "INFO" "Tłumaczenie $source_file -> $target_lang"
    
    local total_keys=$(jq 'length' "$source_file")
    local translated=0
    local failed=0
    
    # Utwórz output
    echo "{}" > "$output_file"
    
    # Przetwarzaj klucze
    jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$source_file" | while IFS=$'\t' read -r key value; do
        ((translated++))
        
        # Pokaż postęp
        if ((translated % 10 == 0)); then
            log "INFO" "Postęp: $translated/$total_keys"
        fi
        
        # Tłumacz
        local translation=$(translate "$value" "$target_lang")
        
        if [[ -n "$translation" ]]; then
            # Dodaj do output
            jq --arg k "$key" --arg v "$translation" '. + {($k): $v}' "$output_file" > "${output_file}.tmp"
            mv "${output_file}.tmp" "$output_file"
        else
            ((failed++))
            # Użyj oryginału z prefixem
            jq --arg k "$key" --arg v "[NEEDS_TRANSLATION] $value" '. + {($k): $v}' "$output_file" > "${output_file}.tmp"
            mv "${output_file}.tmp" "$output_file"
        fi
    done
    
    log "SUCCESS" "Zakończono: $translated przetłumaczonych, $failed nieudanych"
}

# Tłumaczenie wszystkich języków
translate_all_languages() {
    local source_lang="en"
    local priority_langs=(pl de es pt fr)
    local all_langs=($(ls -d "$I18N_DIR"/*/ 2>/dev/null | xargs -n1 basename | grep -v "^en$"))
    
    # Najpierw priorytetowe
    for lang in "${priority_langs[@]}"; do
        if [[ " ${all_langs[*]} " =~ " ${lang} " ]]; then
            log "INFO" "=== Tłumaczenie: $lang (priorytetowy) ==="
            
            for json_file in "$I18N_DIR/$source_lang"/*.json; do
                local filename=$(basename "$json_file")
                local target_file="$I18N_DIR/$lang/$filename"
                
                translate_json_file "$json_file" "$lang" "$target_file"
            done
        fi
    done
    
    # Potem pozostałe (w tle?)
    for lang in "${all_langs[@]}"; do
        if [[ ! " ${priority_langs[*]} " =~ " ${lang} " ]]; then
            log "INFO" "=== Tłumaczenie: $lang ==="
            
            for json_file in "$I18N_DIR/$source_lang"/*.json; do
                local filename=$(basename "$json_file")
                local target_file="$I18N_DIR/$lang/$filename"
                
                translate_json_file "$json_file" "$lang" "$target_file"
            done
        fi
    done
}

# Statystyki tłumaczeń
show_stats() {
    echo "=== STATYSTYKI TŁUMACZEŃ ==="
    echo ""
    
    if [[ -f "$CACHE_FILE" ]]; then
        local hits=$(jq '.stats.hits' "$CACHE_FILE")
        local misses=$(jq '.stats.misses' "$CACHE_FILE")
        local cache_size=$(jq '.translations | length' "$CACHE_FILE")
        
        echo "Cache:"
        echo "  Trafienia: $hits"
        echo "  Pudła: $misses"
        echo "  Rozmiar: $cache_size wpisów"
    fi
    
    echo ""
    echo "Pokrycie według języków:"
    
    for lang_dir in "$I18N_DIR"/*/; do
        local lang=$(basename "$lang_dir")
        local total=0
        local translated=0
        
        for json_file in "$lang_dir"/*.json; do
            if [[ -f "$json_file" ]]; then
                local file_total=$(jq 'length' "$json_file" 2>/dev/null || echo 0)
                local file_needs=$(jq '[.[] | select(startswith("[NEEDS_TRANSLATION]"))] | length' "$json_file" 2>/dev/null || echo 0)
                
                ((total += file_total))
                ((translated += file_total - file_needs))
            fi
        done
        
        if [[ $total -gt 0 ]]; then
            local percent=$((translated * 100 / total))
            printf "  %-5s: %d/%d (%d%%)\n" "$lang" "$translated" "$total" "$percent"
        fi
    done
}

# === CLI ===

main() {
    init_cache
    
    case "$1" in
        translate)
            [[ -z "$2" || -z "$3" ]] && { echo "Użycie: $0 translate <text> <lang>"; exit 1; }
            translate "$2" "$3"
            ;;
        file)
            [[ -z "$2" || -z "$3" ]] && { echo "Użycie: $0 file <source.json> <target_lang>"; exit 1; }
            local output="${4:-${2%.json}_$3.json}"
            translate_json_file "$2" "$3" "$output"
            ;;
        all)
            translate_all_languages
            ;;
        stats)
            show_stats
            ;;
        cache-clear)
            rm -f "$CACHE_FILE"
            init_cache
            log "INFO" "Cache wyczyszczony"
            ;;
        test)
            log "INFO" "Test tłumaczenia..."
            local result=$(translate "Hello world" "pl")
            echo "EN: Hello world"
            echo "PL: $result"
            ;;
        *)
            cat << EOF
I18N Auto Translator - Automatyczne tłumaczenie

Użycie: $0 <command> [options]

Komendy:
  translate <text> <lang>          Przetłumacz tekst
  file <source.json> <lang> [out]  Przetłumacz plik JSON
  all                              Przetłumacz wszystkie języki
  stats                            Pokaż statystyki
  cache-clear                      Wyczyść cache
  test                             Test API

Zmienne środowiskowe:
  TRANSLATION_API      API do użycia (libretranslate, lingva, mymemory)
  RATE_LIMIT           Zapytania na sekundę (domyślnie: 10)
  LIBRETRANSLATE_API_KEY  Klucz API dla LibreTranslate

Przykłady:
  $0 translate "Hello" pl
  $0 file i18n/en/npc.json de
  TRANSLATION_API=lingva $0 all
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
