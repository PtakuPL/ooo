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

---

## ✅ ZAIMPLEMENTOWANE FUNKCJE I18N W C++ (src/)

### System Translator (`src/utils/i18n/translator.hpp`)

Już istnieje kompletny system tłumaczeń w C++:

```cpp
namespace i18n {
class Translator {
    std::string get(const std::string &key, const std::string &locale = "en") const;
    std::string format(const std::string &key, const std::string &locale, const std::vector<std::string> &args) const;
    void loadLocale(const std::string &locale) const;
    static const std::vector<std::string> &supportedLocales();
};
Translator &g_translator(); // Globalny singleton
}
```

### Metody Player dostępne w Lua (`src/creatures/players/player.cpp`)

| Metoda C++ | Dostępne w Lua | Opis |
|------------|----------------|------|
| `sendLocalizedTextMessage()` | ✅ `player:sendLocalizedTextMessage(TYPE, key, args)` | Wysyła przetłumaczoną wiadomość |
| `sendLocalizedMessageDialog()` | ❌ Brak bindingu Lua | Dialog z tłumaczeniem |
| `getLocalizedItemName()` | ❌ Brak bindingu Lua | Nazwa przedmiotu w języku gracza |

**Istniejące użycie w C++:**
```cpp
// player.cpp - już używa i18n!
sendLocalizedTextMessage(MESSAGE_PARTY, "player.status.cleanse", { it->second });
sendLocalizedTextMessage(MESSAGE_FAILURE, "player.condition.poisoned");
sendLocalizedTextMessage(MESSAGE_FAILURE, "player.condition.drowning");
```

### Metody NPC dostępne w Lua (`data/npclib/`)

| Metoda Lua | Lokalizacja | Opis |
|------------|-------------|------|
| `npcHandler:sayLocalized(key, npc, player, args)` | `npc_handler.lua:754` | Używa `player:sendLocalizedTextMessage()` |
| `NPC_LIB.i18n.npcSay(...)` | **NIE ZNALEZIONO** | Używane w worker ale nie ma definicji! |

### Biblioteka Lua (`data/libs/server_i18n.lua`)

```lua
function t(key, vars, player) -- Pobiera tłumaczenie
function sendTextMessageEx(player, msgType, key, vars) -- Wrapper
function getPlayerLang(player) -- Język gracza ze storage
function setPlayerLang(player, lang) -- Ustawia język
```

---

## ⚠️ PROBLEM: BRAKUJĄCE IMPLEMENTACJE

### 1. `NPC_LIB.i18n.npcSay` - NIE ISTNIEJE!

Worker migruje do `NPC_LIB.i18n.npcSay(...)` ale **ta funkcja nie istnieje** w kodzie!

Znaleziono użycie w `custom_modules.lua`:
```lua
if parameters.i18nKey and NPC_LIB and NPC_LIB.i18n and NPC_LIB.i18n.npcSay then
    NPC_LIB.i18n.npcSay(parameters.npcHandler, npc, player, parameters.i18nKey, ...)
```

Ale nigdzie nie ma definicji `NPC_LIB.i18n = {...}`!

**ROZWIĄZANIE:** Trzeba stworzyć lub używać `npcHandler:sayLocalized()` zamiast `NPC_LIB.i18n.npcSay`

### 2. Brakujące bindingi C++ → Lua

Dla pełnej funkcjonalności i18n potrzeba dodać do `src/lua/functions/`:

| Funkcja | Plik docelowy | Status |
|---------|--------------|--------|
| `item:setLocalizedDescription(key)` | `item_functions.cpp` | ❌ BRAK |
| `item:setLocalizedName(key)` | `item_functions.cpp` | ❌ BRAK |
| `creature:sayLocalized(key, type)` | `creature_functions.cpp` | ❌ BRAK |
| `Game.broadcastLocalizedMessage(key)` | `game_functions.cpp` | ❌ BRAK |
| `player:showLocalizedTextDialog(item, key)` | `player_functions.cpp` | ❌ BRAK |

### 3. Hardcoded stringi w C++ (`src/game/game.cpp`)

Około **50+ miejsc** z hardcoded stringami w samym `game.cpp`:
```cpp
player->sendTextMessage(MESSAGE_FAILURE, "You are feared.");
player->sendTextMessage(MESSAGE_TRADE, "This item is already being traded.");
player->sendTextMessage(MESSAGE_FAILURE, "Sorry, not possible.");
```

Te muszą być zmienione na:
```cpp
player->sendLocalizedTextMessage(MESSAGE_FAILURE, "player.error.feared");
```

---

## 🔧 PLAN IMPLEMENTACJI BRAKUJĄCYCH ELEMENTÓW

### ETAP A: Naprawić definicję NPC_LIB.i18n

**Plik:** `data/npclib/npc_system/npc_lib.lua` (lub podobny)

```lua
NPC_LIB = NPC_LIB or {}
NPC_LIB.i18n = NPC_LIB.i18n or {}

-- Wrapper używający istniejącego npcHandler:sayLocalized
function NPC_LIB.i18n.npcSay(npcHandler, npc, player, key, args)
    npcHandler:sayLocalized(key, npc, player, args or {})
end

function NPC_LIB.i18n.npcSayTable(npcHandler, npc, player, keys, args)
    for _, key in ipairs(keys) do
        npcHandler:sayLocalized(key, npc, player, args or {})
    end
end
```

### ETAP B: Dodać brakujące bindingi C++ (opcjonalnie)

**Plik:** `src/lua/functions/items/item_functions.cpp`

```cpp
// item:setLocalizedName(key)
int ItemFunctions::luaItemSetLocalizedName(lua_State* L) {
    auto item = Lua::getUserdataShared<Item>(L, 1);
    if (!item) {
        Lua::pushBoolean(L, false);
        return 1;
    }
    // Store i18n key for name
    item->setAttribute(ItemAttribute_t::I18N_NAME_KEY, Lua::getString(L, 2));
    Lua::pushBoolean(L, true);
    return 1;
}
```

### ETAP C: Wrappery Lua (bez zmian C++)

Alternatywnie - wrappery w Lua bez modyfikacji C++:

**Plik:** `data/libs/i18n_wrappers.lua`

```lua
-- Wrapper dla item:setDescription z i18n
function Item:setLocalizedDescription(key, player)
    local text = t(key, nil, player)
    self:setDescription(text)
end

-- Wrapper dla creature:say z i18n
function Creature:sayLocalized(key, talkType, player)
    local text = t(key, nil, player)
    self:say(text, talkType)
end

-- Wrapper dla broadcastMessage z i18n
function Game.broadcastLocalizedMessage(key, ...)
    -- Dla każdego gracza online wysyła w jego języku
    for _, player in ipairs(Game.getPlayers()) do
        player:sendLocalizedTextMessage(MESSAGE_STATUS_WARNING, key, {...})
    end
end
```

---

## 📊 PODSUMOWANIE: CO TRZEBA ZROBIĆ

| Element | Status | Akcja |
|---------|--------|-------|
| `i18n::Translator` (C++) | ✅ Istnieje | - |
| `player:sendLocalizedTextMessage()` | ✅ Istnieje | - |
| `npcHandler:sayLocalized()` | ✅ Istnieje | - |
| `NPC_LIB.i18n.npcSay()` | ❌ **BRAK** | Stworzyć wrapper |
| `item:setLocalizedName/Description()` | ❌ Brak | Wrapper Lua lub C++ |
| `creature:sayLocalized()` | ❌ Brak | Wrapper Lua |
| `Game.broadcastLocalizedMessage()` | ❌ Brak | Wrapper Lua |
| Hardcoded C++ w game.cpp | ❌ ~50 miejsc | Migracja do kluczy |

**WNIOSEK:** System i18n istnieje i działa, ale:
1. Worker używa `NPC_LIB.i18n.npcSay` które **nie ma definicji**
2. Brakuje wrapperów Lua dla innych typów (items, creatures)
3. C++ nadal ma hardcoded stringi do migracji
