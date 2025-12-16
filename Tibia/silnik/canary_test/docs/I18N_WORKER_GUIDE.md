# 🤖 Worker I18N Migration Guide

> **Dokument**: Instrukcja dla workera automatyzującego migrację i18n  
> **Data**: 2025-12-12  
> **Status**: W przygotowaniu

---

## 📋 CEL

Worker ma za zadanie:
1. **Ekstrakcję** kluczy i18n z plików serwera
2. **Konwersję** słowników JSON → Lua locales
3. **Generowanie** plików `game_i18n_*.lua` dla klienta
4. **Weryfikację** kompletności tłumaczeń
5. **(Opcjonalnie) Optymalizację bandwidth** przez generowanie krótkich kluczy compact (2–7 znaków)

---

## 🔄 PRZEPŁYW PRACY

```
SERWER                          WORKER                         KLIENT
┌──────────────────┐           ┌────────────────┐           ┌────────────────┐
│ i18n/en/npc.json │  ──────►  │ Ekstrakcja     │  ──────►  │ game_i18n_en   │
│ i18n/pl/npc.json │           │ Konwersja      │           │ game_i18n_pl   │
│ NPC Lua files    │           │ Generowanie    │           │ game_i18n_de   │
└──────────────────┘           └────────────────┘           └────────────────┘

Opcja (bandwidth):

SERWER (semantyczne)            WORKER (mapowanie)            KLIENT (compact)
┌──────────────────┐           ┌────────────────┐           ┌────────────────────────┐
│ i18n/en/*.json   │  ──────►  │ keymap sync    │  ──────►  │ game_i18n_*_compact.lua│
│ (source-of-truth)│           │ export compact │           │ locale.translation[ID] │
└──────────────────┘           └────────────────┘           └────────────────────────┘
```

---

## 📂 ŹRÓDŁA DANYCH (SERWER)

### 1. Pliki JSON słowników (`i18n/*/npc.json`)
```json
// i18n/pl/npc.json
{
  "npc.the_oracle.say_1": "WRÓĆ KIEDY OSIĄGNIESZ POZIOM 8!",
  "npc.the_oracle.say_2": "JUŻ WYBRAŁEŚ SWOJĄ DROGĘ. ŻEGNAJ!",
  ...
}
```

### 2. Pliki NPC Lua (`data-otservbr-global/npc/*.lua`)
Zawierają wywołania:
```lua
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_oracle.say_1")
npcHandler:say("HARDCODED TEXT", npc, creature)  -- DO ZMIGROWANIA!
```

### 3. Pliki Monster Lua (`data-otservbr-global/monster/*.lua`)
Zawierają:
```lua
monsterType:addVoice("ROAR!", 2000, 10, true)  -- Stary format
monsterType:addVoice("ROAR!", 2000, 10, true, "mv.dragon.1")  -- Nowy z i18n
```

---

## 📤 CEL DANYCH (KLIENT)

### Pliki game_i18n_*.lua (`testyy/data/locales/`)

```lua
-- game_i18n_pl.lua
local gameTranslations = {
  -- NPC DIALOGS
  ["npc.the_oracle.say_1"] = "WRÓĆ KIEDY OSIĄGNIESZ POZIOM 8!",
  
  -- MONSTER VOICES
  ["mv.dragon.1"] = "CZUJĘ ZAPACH STRACHU!",
  
  -- MONSTER NAMES
  ["mn.dragon"] = "Smok",
}

if locale and locale.translation then
  for key, value in pairs(gameTranslations) do
    locale.translation[key] = value
  end
end

### Pliki game_i18n_*_compact.lua (opcjonalnie)

Wariant compact nie zmienia źródeł na serwerze — mapuje tylko klucze po stronie eksportu:

```lua
-- game_i18n_pl_compact.lua
local gameTranslations = {
    ["Aa"] = "WRÓĆ KIEDY OSIĄGNIESZ POZIOM 8!",
    ["Ab"] = "JUŻ WYBRAŁEŚ SWOJĄ DROGĘ. ŻEGNAJ!",
}
```

Mapping (source-of-truth):
- `i18n/keymap.json`: semantyczny → compact
- `i18n/keymap_rev.json`: compact → semantyczny (debug)
- `i18n/keymap_meta.json`: parametry + licznik `next_id`

Dokładny plan wdrożenia: `docs/i18n/COMPACT_KEYS_PLAN.md`
```

---

## 🔧 ALGORYTM WORKERA

### ETAP 1: Ekstrakcja kluczy używanych

```bash
#!/bin/bash
# extract_i18n_keys.sh

# Znajdź wszystkie klucze NPC
grep -roh 'NPC_LIB\.i18n\.npcSay[^"]*"[^"]*"' data-otservbr-global/npc/ | \
  grep -oP '"[^"]+"' | sort -u > keys_npc_used.txt

# Znajdź wszystkie klucze monster voices (nowy format)
grep -roh "addVoice([^)]*)" data-otservbr-global/monster/ | \
  grep -oP '"mv\.[^"]*"' | sort -u > keys_monster_voices.txt

echo "Found $(wc -l < keys_npc_used.txt) NPC keys"
echo "Found $(wc -l < keys_monster_voices.txt) monster voice keys"
```

### ETAP 2: Konwersja JSON → Lua

```python
#!/usr/bin/env python3
# json_to_lua_locales.py

import json
import os
import sys

def json_to_lua(input_file, output_file, category=""):
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    lines = []

---

## 🔑 COMPACT KEYS (2–7) — kiedy i jak

### Kiedy używać
- Gdy priorytetem jest zmniejszenie payload serwer→klient (protokół i18n wysyła krótkie ID).
- Gdy chcemy zachować czytelne klucze semantyczne w kodzie i repo.

### Jak wygenerować mapping
```bash
python3 tools/i18n_keymap.py sync --i18n-dir i18n --min-len 2 --max-len 7
python3 tools/i18n_keymap.py verify --i18n-dir i18n
```

### Jak wygenerować locale compact dla klienta
```bash
python3 tools/json_to_lua_locales.py --lang en --compact-keys --i18n-dir i18n
python3 tools/json_to_lua_locales.py --lang pl --compact-keys --i18n-dir i18n
```

Uwaga: worker powinien traktować mapping jako **append-only** — nie wolno regenerować od zera.
    lines.append(f"-- Generated from: {os.path.basename(input_file)}")
    lines.append("local translations = {")
    
    for key, value in sorted(data.items()):
        # Escape special characters
        value = value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        lines.append(f'  ["{key}"] = "{value}",')
    
    lines.append("}")
    lines.append("")
    lines.append("return translations")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Generated: {output_file} ({len(data)} translations)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: json_to_lua_locales.py <input.json> <output.lua>")
        sys.exit(1)
    
    json_to_lua(sys.argv[1], sys.argv[2])
```

### ETAP 3: Generowanie plików zbiorczych

```python
#!/usr/bin/env python3
# generate_game_i18n.py

import json
import os

LANGUAGES = ['en', 'pl', 'de', 'es', 'pt', 'fr']
CATEGORIES = ['npc', 'monster', 'item', 'spell', 'system']

def generate_game_i18n(lang, server_i18n_dir, client_locales_dir):
    """Generate game_i18n_{lang}.lua from server i18n JSONs"""
    
    all_translations = {}
    
    for category in CATEGORIES:
        json_file = os.path.join(server_i18n_dir, lang, f'{category}.json')
        if os.path.exists(json_file):
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                all_translations.update(data)
                print(f"  Loaded {len(data)} keys from {category}.json")
    
    # Generate Lua file
    output_file = os.path.join(client_locales_dir, f'game_i18n_{lang}.lua')
    
    lines = []
    lines.append(f"-- GAME I18N TRANSLATIONS - {lang.upper()}")
    lines.append(f"-- Generated automatically from server i18n files")
    lines.append(f"-- Total translations: {len(all_translations)}")
    lines.append("")
    lines.append("local gameTranslations = {")
    
    # Group by category
    current_prefix = ""
    for key in sorted(all_translations.keys()):
        prefix = key.split('.')[0] if '.' in key else key
        if prefix != current_prefix:
            if current_prefix:
                lines.append("")
            lines.append(f"  -- {prefix.upper()}")
            current_prefix = prefix
        
        value = all_translations[key]
        value = value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        lines.append(f'  ["{key}"] = "{value}",')
    
    lines.append("}")
    lines.append("")
    lines.append("if locale and locale.translation then")
    lines.append("  for key, value in pairs(gameTranslations) do")
    lines.append("    locale.translation[key] = value")
    lines.append("  end")
    lines.append("end")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Generated: {output_file}")
    return len(all_translations)

if __name__ == "__main__":
    SERVER_I18N = "i18n"
    CLIENT_LOCALES = "../testyy/data/locales"
    
    for lang in LANGUAGES:
        print(f"\nProcessing {lang}...")
        count = generate_game_i18n(lang, SERVER_I18N, CLIENT_LOCALES)
        print(f"  Total: {count} translations")
```

### ETAP 4: Weryfikacja

```bash
#!/bin/bash
# verify_i18n_coverage.sh

echo "=== I18N Coverage Report ==="

# Klucze używane na serwerze
grep -roh '"[a-z_]*\.[a-z_]*\.[a-z_0-9]*"' data-otservbr-global/npc/ | \
  sort -u > /tmp/server_keys.txt

# Klucze w słownikach serwera
find i18n -name "*.json" -exec cat {} \; | \
  jq -r 'keys[]' 2>/dev/null | sort -u > /tmp/dict_keys.txt

# Porównanie
echo "Keys used in NPC files: $(wc -l < /tmp/server_keys.txt)"
echo "Keys in server dictionaries: $(wc -l < /tmp/dict_keys.txt)"

# Brakujące klucze
echo ""
echo "Missing keys (used but not in dictionary):"
comm -23 /tmp/server_keys.txt /tmp/dict_keys.txt | head -20
```

---

## 📝 MIGRACJA HARDCODED TEKSTÓW

### Problem
Wiele plików NPC nadal używa hardcoded tekstów:
```lua
npcHandler:say("Hello adventurer!", npc, creature)
```

### Rozwiązanie - automatyczna migracja

```python
#!/usr/bin/env python3
# migrate_hardcoded_npc_texts.py

import re
import os
import json

def migrate_npc_file(filepath, translations_dict, key_counter):
    """
    Znajdź npcHandler:say("...") i zamień na NPC_LIB.i18n.npcSay
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern: npcHandler:say("text", npc, creature)
    pattern = r'npcHandler:say\("([^"]+)",\s*npc,\s*creature\)'
    
    npc_name = os.path.basename(filepath).replace('.lua', '')
    changes = []
    
    def replacer(match):
        nonlocal key_counter
        text = match.group(1)
        key = f"npc.{npc_name}.say_{key_counter}"
        key_counter += 1
        
        translations_dict[key] = text
        changes.append((text, key))
        
        return f'NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "{key}")'
    
    new_content = re.sub(pattern, replacer, content)
    
    if changes:
        print(f"  Migrated {len(changes)} texts in {filepath}")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
    
    return key_counter, changes

# Użycie:
# translations = {}
# counter = 1
# for npc_file in glob.glob("data-otservbr-global/npc/*.lua"):
#     counter, _ = migrate_npc_file(npc_file, translations, counter)
# 
# with open("i18n/en/npc_migrated.json", 'w') as f:
#     json.dump(translations, f, indent=2)
```

---

## 🔁 WORKFLOW WORKERA

### Codzienna synchronizacja

```bash
#!/bin/bash
# i18n_sync_worker.sh

echo "=== I18N Sync Worker Started ==="
cd /home/ptaku/serweryt/Tibia/silnik/canary_test

# 1. Ekstrakcja kluczy
echo "Step 1: Extracting keys..."
./tools/extract_i18n_keys.sh

# 2. Generowanie plików dla klienta
echo "Step 2: Generating client locales..."
python3 tools/generate_game_i18n.py

# 3. Weryfikacja
echo "Step 3: Verifying coverage..."
./tools/verify_i18n_coverage.sh

# 4. Raport
echo "Step 4: Generating report..."
date >> i18n_sync.log
echo "Sync completed" >> i18n_sync.log

echo "=== I18N Sync Worker Completed ==="
```

---

## ✅ CHECKLIST DLA NOWYCH NPC

Gdy dodajesz nowy NPC, upewnij się że:

- [ ] Wszystkie teksty używają `NPC_LIB.i18n.npcSay()` lub `npcHandler:sayLocalized()`
- [ ] Klucze są dodane do `i18n/en/npc.json` (angielski bazowy)
- [ ] Klucze są przetłumaczone w `i18n/pl/npc.json` (i innych językach)
- [ ] Głosy NPC używają `npcType:addVoice(text, interval, chance, yell, i18nKey)`
- [ ] Uruchomiono worker aby zsynchronizować z klientem

---

## 📚 POWIĄZANE PLIKI

- `docs/I18N_PROTOCOL_IMPLEMENTATION.md` - Dokumentacja protokołu
- `testyy/docs/i18n/CLIENT_LOCALIZATION_SYSTEM.md` - System klienta
- `data/libs/i18n_wrappers.lua` - Wrappery serwera
- `tools/json_to_lua_locales.py` - Konwerter JSON→Lua
- `tools/generate_game_i18n.py` - Generator zbiorczy
