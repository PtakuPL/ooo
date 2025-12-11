# Rozmowa nad workerem 2 - Kompleksowy Plan Migracji i18n

## Data: 2025-12-11 | Aktualizacja: 2025-12-12

---

## 📊 Status aktualny

### Worker
- **Worker działa**: PID aktywny, tryb MIGRATION
- **i18n_file_status.json**: 96 plików z pełnymi metadanymi
- **i18n_processed_files.txt**: 416 plików
- **Funkcja `mark_file_completed()`**: ✅ NAPRAWIONA

### Hard strings reports
| Źródło | Wpisów | Lokalizacja |
|--------|--------|-------------|
| **Serwer** | 24205 | `docs/i18n/generated/hard_strings.csv` |
| **Klient** | 51254 | `testyy_hard_strings.csv` |

**ZASADA:** Wszystkie teksty są równie ważne. Brak priorytetów - cały niezmigrowany tekst wymaga migracji.

---

## 🔍 KLUCZOWE ODKRYCIE: Częściowa Migracja

### Problem
Worker migruje CZĘŚĆ wzorców w pliku i oznacza go jako "completed".  
Pliki mają jednocześnie:
- ✅ Zmigrowane wywołania (np. `NPC_LIB.i18n.npcSay(...)`)
- ❌ Niezmigrowane wywołania (np. `npcHandler:say("...")`)

**Znaleziono: 71+ plików częściowo zmigrowanych**

### Rozwiązanie
Plik jest "completed" TYLKO gdy NIE zawiera ŻADNEGO niezmigrowanego wzorca z listy poniżej.

---

## 📋 KOMPLETNA LISTA METOD WYŚWIETLANIA TEKSTU

### 🖥️ SERWER (canary_test)

#### 1. Dialogi NPC
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `npcHandler:say("text", ...)` | `NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "key")` | `data-*/npc/*.lua` |
| `npcHandler:say({ "text1", "text2" }, ...)` | `NPC_LIB.i18n.npcSayTable(...)` | `data-*/npc/*.lua` |
| `npc:say("text", ...)` | `NPC_LIB.i18n.npcSay(...)` | `data-*/npc/*.lua` |
| `StdModule.say { text = "..." }` | `StdModule.say { i18nKey = "..." }` | `data-*/npc/*.lua` |

#### 2. Wiadomości systemowe do gracza
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `sendTextMessage(TYPE, "text")` | `sendLocalizedMessage(TYPE, "key")` lub wrapper | `data-*/scripts/**/*.lua` |
| `player:sendTextMessage(TYPE, "text")` | `player:sendLocalizedMessage(TYPE, "key")` | wszędzie |

#### 3. Mowa postaci
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `player:say("text", TALKTYPE_*)` | `player:sayLocalized("key", TALKTYPE_*)` | `data-*/scripts/**/*.lua` |
| `creature:say("text", ...)` | `creature:sayLocalized("key", ...)` | `data-*/scripts/**/*.lua` |
| `monster:say("text", ...)` | `monster:sayLocalized("key", ...)` | `data-*/monster/*.lua` |
| `doCreatureSay(cid, "text", ...)` | `doCreatureSayLocalized(cid, "key", ...)` | legacy scripts |

#### 4. Głosy (voices)
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `monster.voices = { { text = "..." } }` | `monster.voices = { { i18nKey = "..." } }` | `data-*/monster/**/*.lua` |
| `npcConfig.voices = { { text = "..." } }` | `npcConfig.voices = { { i18nKey = "..." } }` | `data-*/npc/*.lua` |

#### 5. Broadcasty i globalne wiadomości
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `Game.broadcastMessage("text")` | `Game.broadcastLocalizedMessage("key")` | `data-*/scripts/**/*.lua` |
| `broadcastMessage("text")` | `broadcastLocalizedMessage("key")` | `data-*/scripts/**/*.lua` |

#### 6. Dialogi i okna tekstowe
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `player:showTextDialog(item, "text")` | `player:showLocalizedTextDialog(item, "key")` | `data-*/scripts/**/*.lua` |

#### 7. Przedmioty (Items)
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `name="Iron Sword"` (XML) | `nameKey="item.iron_sword.name"` | `data/items/*.xml` |
| `description="A rusty sword"` (XML) | `descriptionKey="item.iron_sword.desc"` | `data/items/*.xml` |
| `item:setName("text")` (Lua) | `item:setLocalizedName("key")` | `data-*/scripts/**/*.lua` |
| `item:setDescription("text")` (Lua) | `item:setLocalizedDescription("key")` | `data-*/scripts/**/*.lua` |

#### 8. Questy i wydarzenia
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `player:setStorageValue(...)` z tekstem | i18n wrapper | `data-*/scripts/quests/**/*.lua` |
| Dialogi questowe (różne formy) | standardowa migracja | `data-*/scripts/quests/**/*.lua` |

#### 9. Typy wiadomości (MESSAGE_*)
```
MESSAGE_EVENT_ADVANCE    - postęp w grze
MESSAGE_FAILURE          - błędy/niepowodzenia
MESSAGE_GREET            - powitania
MESSAGE_STATUS_CONSOLE   - status w konsoli
MESSAGE_EVENT_DEFAULT    - domyślne wydarzenia
MESSAGE_HEALED           - leczenie
MESSAGE_DAMAGE_DEALT     - zadane obrażenia
MESSAGE_DAMAGE_RECEIVED  - otrzymane obrażenia
MESSAGE_GAME_HIGHLIGHT   - ważne informacje
MESSAGE_LOOT            - zdobycze
... i inne
```

#### 10. Typy mowy (TALKTYPE_*)
```
TALKTYPE_SAY             - zwykła mowa
TALKTYPE_WHISPER         - szept
TALKTYPE_YELL            - krzyk
TALKTYPE_MONSTER_SAY     - mowa potworów
TALKTYPE_MONSTER_YELL    - krzyk potworów
TALKTYPE_NPC_FROM        - od NPC
TALKTYPE_BROADCAST       - ogłoszenie
... i inne
```

---

### 💻 KLIENT (testyy = OTClient)

#### 1. Funkcja tłumaczenia `tr()`
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `"Hard coded text"` | `tr("Hard coded text")` | `modules/**/*.lua` |
| `string.format("text %s", var)` | `tr("text %s"):format(var)` | `modules/**/*.lua` |

#### 2. Ustawianie tekstu UI
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `widget:setText("text")` | `widget:setText(tr("text"))` | `modules/**/*.lua` |
| `widget:setTooltip("text")` | `widget:setTooltip(tr("text"))` | `modules/**/*.lua` |
| `addOption("text")` | `addOption(tr("text"))` | `modules/**/*.lua` |

#### 3. Okna dialogowe
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `displayInfoBox("title", "text")` | `displayInfoBox(tr("title"), tr("text"))` | `modules/**/*.lua` |
| `displayGeneralBox("title", ...)` | `displayGeneralBox(tr("title"), ...)` | `modules/**/*.lua` |

#### 4. Pliki OTUI
| Wzorzec przed migracją | Wzorzec po migracji | Lokalizacja |
|------------------------|---------------------|-------------|
| `text: Hard coded` | `!text: tr('Hard coded')` | `modules/**/*.otui` |
| `tooltip: Some tip` | `!tooltip: tr('Some tip')` | `modules/**/*.otui` |
| `placeholder: Enter...` | `!placeholder: tr('Enter...')` | `modules/**/*.otui` |

---

## 🔄 PRZEPŁYW INTEGRACJI

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYKL WYKRYWANIA I MIGRACJI                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. SKAN (IDLE mode)                                             │
│    - Uruchom hard_strings_report.py                             │
│    - Wygeneruj hard_strings.csv (serwer + klient)               │
│    - Zapisz do i18n/hard_strings_status.json                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. ANALIZA                                                      │
│    - Porównaj hard_strings z i18n_file_status.json              │
│    - Znajdź pliki z niezmigrowanymi wzorcami                    │
│    - Znajdź pliki CZĘŚCIOWO zmigrowane                          │
│    - Wygeneruj listę pracy                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. MIGRACJA (MIGRATION mode)                                    │
│    - Pobierz plik z listy pracy                                 │
│    - Wykryj TYP wzorca (npc/monster/script/item/client)         │
│    - Zastosuj odpowiednią transformację                         │
│    - Wygeneruj klucze i18n                                      │
│    - Dodaj do translation_queue                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. WALIDACJA                                                    │
│    - Sprawdź czy plik NIE MA już żadnego niezmigrowanego wzorca │
│    - Jeśli ma → NIE oznaczaj jako completed, wróć do migracji   │
│    - Jeśli nie ma → mark_file_completed()                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. TŁUMACZENIE                                                  │
│    - translation_queue → tłumaczenia                            │
│    - Zapisz do i18n/{lang}/*.json                               │
│    - Aktualizuj statystyki                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 WYKRYWANIE CZĘŚCIOWEJ MIGRACJI

### Algorytm sprawdzania pliku

```python
def is_file_fully_migrated(filepath):
    """
    Zwraca True tylko gdy plik NIE zawiera ŻADNEGO niezmigrowanego wzorca.
    """
    content = read_file(filepath)
    
    # Wzorce do sprawdzenia zależą od typu pliku
    patterns_by_type = {
        "npc": [
            r'npcHandler:say\s*\(\s*"',           # npcHandler:say("...")
            r'npcHandler:say\s*\(\s*\{',          # npcHandler:say({...})
            r'npc:say\s*\(\s*"',                  # npc:say("...")
            r'StdModule\.say.*text\s*=\s*"',      # StdModule.say { text = "..." }
            r'voices\s*=.*text\s*=\s*"',          # voices = { text = "..." }
        ],
        "monster": [
            r'monster:say\s*\(\s*"',              # monster:say("...")
            r'voices\s*=.*text\s*=\s*"',          # voices = { text = "..." }
        ],
        "script": [
            r'sendTextMessage\s*\([^,]+,\s*"',    # sendTextMessage(TYPE, "...")
            r'player:say\s*\(\s*"',               # player:say("...")
            r'creature:say\s*\(\s*"',             # creature:say("...")
            r'Game\.broadcastMessage\s*\(\s*"',   # Game.broadcastMessage("...")
            r'showTextDialog\s*\([^,]+,\s*"',     # showTextDialog(item, "...")
        ],
        "client_lua": [
            r'(?<!tr\()"[^"]{4,}"(?!\))',         # "text" nie otoczony tr()
            r'setText\s*\(\s*"',                  # setText("...")
            r'setTooltip\s*\(\s*"',               # setTooltip("...")
            r'displayInfoBox\s*\(\s*"',           # displayInfoBox("...")
        ],
        "client_otui": [
            r'^\s*text:\s*[^!]',                  # text: ... (nie !text:)
            r'^\s*tooltip:\s*[^!]',               # tooltip: ... (nie !tooltip:)
        ],
    }
    
    file_type = detect_file_type(filepath)
    patterns = patterns_by_type.get(file_type, [])
    
    for pattern in patterns:
        if re.search(pattern, content):
            return False  # Znaleziono niezmigrowany wzorzec
    
    return True  # Wszystko zmigrowane
```

---

## 📂 STRUKTURA KATALOGÓW I TYPY PLIKÓW

| Katalog | Typ plików | Metody wyświetlania tekstu |
|---------|------------|---------------------------|
| `data-*/npc/` | NPC Lua | npcHandler:say, StdModule.say, voices |
| `data-*/monster/` | Monster Lua | monster.voices, monster:say |
| `data-*/scripts/actions/` | Actions Lua | sendTextMessage, player:say |
| `data-*/scripts/creaturescripts/` | CreatureScripts | sendTextMessage, creature:say |
| `data-*/scripts/quests/` | Quest Lua | wszystkie metody |
| `data-*/scripts/spells/` | Spells Lua | sendTextMessage |
| `data-*/scripts/talkactions/` | TalkActions | sendTextMessage |
| `data/items/` | Items XML | name, description |
| `data/libs/` | Libraries | różne metody |
| `testyy/modules/` | Client Lua | tr(), setText() |
| `testyy/modules/**/*.otui` | Client OTUI | text:, tooltip: |

---

## 📊 STRUKTURA DANYCH

### i18n/hard_strings_status.json
```json
{
  "last_scan": "2025-12-12T10:00:00",
  "server": {
    "total_entries": 24205,
    "migrated": 15000,
    "pending": 9205,
    "partial": 71
  },
  "client": {
    "total_entries": 51254,
    "migrated": 0,
    "pending": 51254,
    "partial": 0
  },
  "files": {
    "data-otservbr-global/npc/a_prisoner.lua": {
      "status": "partial",
      "total_strings": 25,
      "migrated_strings": 20,
      "pending_strings": 5,
      "patterns_found": ["npcHandler:say"]
    }
  }
}
```

### Aktualizacja i18n_global_stats.json
```json
{
  "hard_strings_server_total": 24205,
  "hard_strings_server_pending": 9205,
  "hard_strings_client_total": 51254,
  "hard_strings_client_pending": 51254,
  "partial_files_count": 71,
  "last_hard_scan": "2025-12-12T10:00:00"
}
```

---

## ✅ ZADANIA DO WYKONANIA

### Implementacja w workerze

- [ ] **Dodać wykrywanie częściowej migracji**
  - Funkcja `is_file_fully_migrated()` z wszystkimi wzorcami
  - Modyfikacja `mark_file_completed()` - sprawdzaj przed oznaczeniem
  - Lista 71+ częściowo zmigrowanych plików do ponownej migracji

- [ ] **Rozszerzyć dispatcher o wszystkie typy**
  - Dodać kategorie: monster_voices, script_messages, item_names, client_ui
  - Każda kategoria ma swoje wzorce i transformacje
  - Wspólny przepływ: wykryj → migruj → waliduj → oznacz

- [ ] **Integracja hard_strings**
  - Parsować hard_strings.csv do JSON
  - Porównywać z i18n_file_status.json
  - Dodać do dispatchera jako źródło pracy

- [ ] **Obsługa klienta (testyy)**
  - Dodać kategorię `client` do workera
  - Wzorce: `tr()`, `.otui text:`
  - Osobne statystyki dla klienta

- [ ] **Aktualizacja statusu**
  - Sekcja "Hard-coded Strings" w I18N_STATUS.md
  - Podział na serwer/klient
  - Liczba częściowo zmigrowanych plików

---

## 📋 LISTA CZĘŚCIOWO ZMIGROWANYCH PLIKÓW (71+)

Pliki które mają zarówno zmigrowane jak i niezmigrowane wzorce:

```
a_dead_bureaucrat1    gnomally           lokur
a_dead_bureaucrat3    gnomargery         lynda
albinius              gnombold           maeryn
alexander             gnomerik           miraia
angus                 gnomilly           nilsor
arkulius              gnomission         ninos
asima                 gnomus             nokmir
benjamin              grizzly_adams      oldrak
captain_dreadnought   halvar             olrik
cassino               hamish             paulie
charos                henricus           plunderpurse
chrystal              hireling           rachel
cledwyn               hjaern             richard
daniel_steelsoul      imbuement_assistant ruprecht
dove                  inkaef             sandomo
duncan                jeronimo           spectulus
eruaran               jorge              storkus
fenech                khanna             sven
frosty                klom_stonecutter   the_oracle
gnomadness            kroox              the_orc_king
                      lardoc_bashsmite   topsy
                      liane              vascalir
                                         walter_jaeger
                                         wentworth
                                         xodet
                                         yana
                                         zebron
```

---

## 🔧 FUNKCJE DO IMPLEMENTACJI

### 1. check_all_patterns(filepath)
```bash
# Sprawdza WSZYSTKIE wzorce w pliku, zwraca listę znalezionych
check_all_patterns() {
    local file="$1"
    local patterns_found=""
    
    # NPC patterns
    grep -q 'npcHandler:say\s*(\s*"' "$file" && patterns_found+="npcHandler:say,"
    grep -q 'StdModule\.say.*text\s*=' "$file" && patterns_found+="StdModule.say,"
    
    # Monster patterns
    grep -q 'monster:say\s*(\s*"' "$file" && patterns_found+="monster:say,"
    grep -q 'voices.*text\s*=' "$file" && patterns_found+="voices.text,"
    
    # Script patterns
    grep -q 'sendTextMessage\s*([^,]*,\s*"' "$file" && patterns_found+="sendTextMessage,"
    grep -q 'player:say\s*(\s*"' "$file" && patterns_found+="player:say,"
    grep -q 'creature:say\s*(\s*"' "$file" && patterns_found+="creature:say,"
    grep -q 'Game\.broadcastMessage\s*(\s*"' "$file" && patterns_found+="broadcastMessage,"
    
    echo "$patterns_found"
}
```

### 2. is_fully_migrated(filepath)
```bash
is_fully_migrated() {
    local file="$1"
    local patterns=$(check_all_patterns "$file")
    
    if [[ -z "$patterns" ]]; then
        return 0  # Plik w pełni zmigrowany
    else
        return 1  # Plik częściowo zmigrowany
    fi
}
```

### 3. Zmodyfikowany mark_file_completed()
```bash
mark_file_completed() {
    local file="$1"
    local category="$2"
    local keys_added="${3:-0}"
    
    # NOWE: Sprawdź czy plik jest w pełni zmigrowany
    if ! is_fully_migrated "$file"; then
        log "WARN" "Plik $file ma niezmigrowane wzorce - NIE oznaczam jako completed"
        return 1
    fi
    
    # Reszta bez zmian...
    echo "$file" >> "$PROCESSED_FILE"
    # ...
}
```

---

## Log działań

| Data | Akcja |
|------|-------|
| 2025-12-11 22:50 | Utworzenie planu |
| 2025-12-11 23:10 | Odkrycie 71 częściowo zmigrowanych plików |
| 2025-12-12 | Przepisanie planu - wszystkie typy plików, bez priorytetów |
| | |

---

*Ten plik dokumentuje kompleksowy plan migracji i18n dla całego projektu (serwer + klient).*
