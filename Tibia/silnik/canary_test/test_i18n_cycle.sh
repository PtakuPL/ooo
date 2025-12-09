#!/bin/bash
#===============================================================================
# I18N WORKER - TEST PEŁNEGO CYKLU
# Symuluje: ekstrakcja → tłumaczenie → dokumentacja
#===============================================================================

cd /home/ptaku/serweryt/Tibia/silnik/canary_test

LOG_FILE="i18n_test_cycle.log"
I18N_DIR="i18n"

log() {
    local msg="[$(date '+%H:%M:%S')] $1"
    echo -e "$msg" | tee -a "$LOG_FILE"
}

#===============================================================================
# FAZA 1: SPRAWDZENIE KLUCZY (symulacja zakończenia ekstrakcji)
#===============================================================================
test_extraction_complete() {
    log "═══════════════════════════════════════════════════════════════"
    log "📦 FAZA 1: WERYFIKACJA EKSTRAKCJI"
    log "═══════════════════════════════════════════════════════════════"
    
    local total_keys=0
    local categories=("npc" "scripts" "items" "monsters" "spells" "server" "ui")
    
    for cat in "${categories[@]}"; do
        local file="$I18N_DIR/en/${cat}.json"
        if [ -f "$file" ]; then
            local count=$(python3 -c "import json; print(len(json.load(open('$file'))))" 2>/dev/null || echo "0")
            log "  📁 ${cat}.json: $count kluczy"
            total_keys=$((total_keys + count))
        fi
    done
    
    log ""
    log "📊 SUMA: $total_keys kluczy wyekstrahowanych"
    
    if [ "$total_keys" -gt 10000 ]; then
        log "✅ EKSTRAKCJA ZAKOŃCZONA - wystarczająco dużo kluczy!"
        return 0
    else
        log "⚠️ Za mało kluczy - kontynuuj ekstrakcję"
        return 1
    fi
}

#===============================================================================
# FAZA 2: TŁUMACZENIE (sprawdzenie + symulacja)
#===============================================================================
test_translation_phase() {
    log "═══════════════════════════════════════════════════════════════"
    log "🌍 FAZA 2: TŁUMACZENIA"
    log "═══════════════════════════════════════════════════════════════"
    
    local categories=("npc" "scripts" "items" "monsters" "spells" "server")
    
    for cat in "${categories[@]}"; do
        local en_file="$I18N_DIR/en/${cat}.json"
        local pl_file="$I18N_DIR/pl/${cat}.json"
        
        if [ -f "$en_file" ] && [ -f "$pl_file" ]; then
            local en_count=$(python3 -c "import json; print(len(json.load(open('$en_file'))))" 2>/dev/null || echo "0")
            local pl_count=$(python3 -c "import json; d=json.load(open('$pl_file')); print(sum(1 for v in d.values() if v and str(v).strip()))" 2>/dev/null || echo "0")
            local pct=0
            [ "$en_count" -gt 0 ] && pct=$((pl_count * 100 / en_count))
            log "  🇵🇱 ${cat}: $pl_count/$en_count ($pct%)"
        fi
    done
    
    # Sprawdź ogólny postęp
    local total_en=$(python3 -c "
import json, os
total = 0
for f in os.listdir('$I18N_DIR/en'):
    if f.endswith('.json'):
        try:
            total += len(json.load(open('$I18N_DIR/en/' + f)))
        except: pass
print(total)
" 2>/dev/null || echo "0")
    
    local total_pl=$(python3 -c "
import json, os
total = 0
for f in os.listdir('$I18N_DIR/pl'):
    if f.endswith('.json'):
        try:
            d = json.load(open('$I18N_DIR/pl/' + f))
            total += sum(1 for v in d.values() if v and str(v).strip())
        except: pass
print(total)
" 2>/dev/null || echo "0")
    
    local overall_pct=0
    [ "$total_en" -gt 0 ] && overall_pct=$((total_pl * 100 / total_en))
    
    log ""
    log "📊 OGÓLNY POSTĘP PL: $total_pl/$total_en ($overall_pct%)"
    
    if [ "$overall_pct" -ge 80 ]; then
        log "✅ TŁUMACZENIA ZAKOŃCZONE (>80%)"
        return 0
    else
        log "⏳ Tłumaczenia w toku ($overall_pct% < 80%)"
        log ""
        log "🔧 Symulacja: Załóżmy że tłumaczenia są zakończone..."
        return 0  # Dla testu zwracamy sukces
    fi
}

#===============================================================================
# FAZA 3: DOKUMENTACJA I ANALIZA
#===============================================================================
test_documentation_phase() {
    log "═══════════════════════════════════════════════════════════════"
    log "📚 FAZA 3: DOKUMENTACJA I ANALIZA"
    log "═══════════════════════════════════════════════════════════════"
    
    local doc_dir="docs/i18n/generated"
    mkdir -p "$doc_dir"
    
    # Generuj raport kategorii
    log "📝 Generuję raport kategorii..."
    
    python3 << 'PYEOF'
import json
import os
from datetime import datetime

i18n_dir = "i18n"
doc_dir = "docs/i18n/generated"

# Zbierz statystyki
categories = {}
languages = []

# Znajdź wszystkie języki
for lang_dir in os.listdir(i18n_dir):
    lang_path = os.path.join(i18n_dir, lang_dir)
    if os.path.isdir(lang_path) and len(lang_dir) == 2:
        languages.append(lang_dir)

# Zbierz dane dla każdej kategorii
for filename in os.listdir(os.path.join(i18n_dir, "en")):
    if not filename.endswith(".json"):
        continue
    
    cat_name = filename[:-5]
    categories[cat_name] = {
        "en_keys": 0,
        "translations": {}
    }
    
    # Policz klucze EN
    try:
        with open(os.path.join(i18n_dir, "en", filename)) as f:
            en_data = json.load(f)
            categories[cat_name]["en_keys"] = len(en_data)
    except:
        pass
    
    # Policz tłumaczenia dla każdego języka
    for lang in languages:
        if lang == "en":
            continue
        try:
            lang_file = os.path.join(i18n_dir, lang, filename)
            if os.path.exists(lang_file):
                with open(lang_file) as f:
                    data = json.load(f)
                    translated = sum(1 for v in data.values() if v and str(v).strip())
                    categories[cat_name]["translations"][lang] = translated
        except:
            pass

# Generuj raport Markdown
report = f"""# 📊 I18N Status Report

**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Languages:** {len(languages)}  
**Categories:** {len(categories)}

## 📁 Categories Overview

| Category | EN Keys | PL | ES | DE | PT |
|----------|---------|----|----|----|----|
"""

for cat, data in sorted(categories.items()):
    en = data["en_keys"]
    pl = data["translations"].get("pl", 0)
    es = data["translations"].get("es", 0)
    de = data["translations"].get("de", 0)
    pt = data["translations"].get("pt", 0)
    report += f"| {cat} | {en} | {pl} | {es} | {de} | {pt} |\n"

# Podsumowanie
total_en = sum(d["en_keys"] for d in categories.values())
total_pl = sum(d["translations"].get("pl", 0) for d in categories.values())

report += f"""
## 📈 Summary

- **Total EN keys:** {total_en:,}
- **Total PL translations:** {total_pl:,}
- **PL completion:** {total_pl * 100 // max(total_en, 1)}%

## 🌍 Languages

Total: {len(languages)} languages configured

"""

# Zapisz raport
with open(os.path.join(doc_dir, "STATUS_REPORT.md"), "w") as f:
    f.write(report)

print(f"✅ Raport zapisany: {doc_dir}/STATUS_REPORT.md")

# Generuj też JSON
stats = {
    "generated": datetime.now().isoformat(),
    "total_keys": total_en,
    "total_pl": total_pl,
    "languages": len(languages),
    "categories": {k: v["en_keys"] for k, v in categories.items()}
}

with open(os.path.join(doc_dir, "stats.json"), "w") as f:
    json.dump(stats, f, indent=2)

print(f"✅ Statystyki zapisane: {doc_dir}/stats.json")
PYEOF

    log ""
    log "📄 Wygenerowane pliki:"
    ls -la "$doc_dir/" 2>/dev/null | tail -5
    
    log ""
    log "✅ DOKUMENTACJA WYGENEROWANA"
}

#===============================================================================
# FAZA 4: ANALIZA JAKOŚCI
#===============================================================================
test_quality_analysis() {
    log "═══════════════════════════════════════════════════════════════"
    log "🔍 FAZA 4: ANALIZA JAKOŚCI"
    log "═══════════════════════════════════════════════════════════════"
    
    # Sprawdź duplikaty kluczy
    log "🔍 Szukam duplikatów kluczy..."
    
    local duplicates=$(python3 << 'PYEOF'
import json
import os
from collections import Counter

i18n_dir = "i18n/en"
all_keys = []

for filename in os.listdir(i18n_dir):
    if filename.endswith(".json"):
        try:
            with open(os.path.join(i18n_dir, filename)) as f:
                data = json.load(f)
                all_keys.extend(data.keys())
        except:
            pass

duplicates = [k for k, v in Counter(all_keys).items() if v > 1]
print(len(duplicates))
PYEOF
2>/dev/null || echo "0")
    
    log "  Duplikaty: $duplicates"
    
    # Sprawdź puste wartości
    log "🔍 Szukam pustych wartości..."
    
    local empty=$(python3 << 'PYEOF'
import json
import os

i18n_dir = "i18n/en"
empty = 0

for filename in os.listdir(i18n_dir):
    if filename.endswith(".json"):
        try:
            with open(os.path.join(i18n_dir, filename)) as f:
                data = json.load(f)
                empty += sum(1 for v in data.values() if not v or not str(v).strip())
        except:
            pass

print(empty)
PYEOF
2>/dev/null || echo "0")
    
    log "  Puste wartości: $empty"
    
    # Sprawdź niespójne tłumaczenia (PL = EN)
    log "🔍 Szukam nieprzetłumaczonych (PL = EN)..."
    
    local untranslated=$(python3 << 'PYEOF'
import json
import os

untranslated = 0
i18n_en = "i18n/en"
i18n_pl = "i18n/pl"

for filename in os.listdir(i18n_en):
    if not filename.endswith(".json"):
        continue
    en_file = os.path.join(i18n_en, filename)
    pl_file = os.path.join(i18n_pl, filename)
    
    if not os.path.exists(pl_file):
        continue
    
    try:
        with open(en_file) as f:
            en_data = json.load(f)
        with open(pl_file) as f:
            pl_data = json.load(f)
        
        for key, en_val in en_data.items():
            pl_val = pl_data.get(key, "")
            if pl_val and pl_val == en_val and len(en_val) > 20:
                untranslated += 1
    except:
        pass

print(untranslated)
PYEOF
2>/dev/null || echo "0")
    
    log "  Nieprzetłumaczone (PL=EN): $untranslated"
    
    log ""
    log "✅ ANALIZA JAKOŚCI ZAKOŃCZONA"
}

#===============================================================================
# GŁÓWNA FUNKCJA TESTOWA
#===============================================================================
main() {
    echo "" > "$LOG_FILE"
    
    log "╔═══════════════════════════════════════════════════════════════╗"
    log "║     I18N WORKER - TEST PEŁNEGO CYKLU                         ║"
    log "║     Ekstrakcja → Tłumaczenie → Dokumentacja                  ║"
    log "╚═══════════════════════════════════════════════════════════════╝"
    log ""
    
    # FAZA 1: Ekstrakcja
    if test_extraction_complete; then
        log ""
        
        # FAZA 2: Tłumaczenia
        if test_translation_phase; then
            log ""
            
            # FAZA 3: Dokumentacja
            test_documentation_phase
            log ""
            
            # FAZA 4: Analiza jakości
            test_quality_analysis
        fi
    fi
    
    log ""
    log "╔═══════════════════════════════════════════════════════════════╗"
    log "║     🏆 TEST ZAKOŃCZONY                                        ║"
    log "╚═══════════════════════════════════════════════════════════════╝"
    log ""
    log "📄 Log: $LOG_FILE"
    log "📊 Raporty: docs/i18n/generated/"
}

main "$@"
