# MIGRATION MODE — Master Plan
## Automatyczna migracja hardcoded tekstów → klucze i18n

**Data**: 2026-02-15  
**Cel**: Worker tryb MIGRATION — samoistna zamiana tekstów w kodzie na klucze i18n  
**Priorytet**: Musi działać autonomicznie przez tydzień bez interwencji  

---

## 1. STATYSTYKI PRE-MIGRACJI (stan aktualny)

| Kategoria | Pliki z hitami | Hity | Trudność | Priorytet |
|---|---:|---:|---|---|
| **php** (strona www) | 2779 | 53490 | 🔴 HARD | P3 |
| **documentation** | 916 | 12799 | 🟢 SKIP | — |
| **html** (www templates) | 288 | 11437 | 🟡 MEDIUM | P3 |
| **otclient_modules** | 169 | 6721 | 🟡 MEDIUM | P2 |
| **libs** (Lua libraries) | 35 | 1691 | 🟡 MEDIUM | P1 |
| **errors** (komunikaty błędów) | 141 | 849 | 🟢 EASY | P1 |
| **mounts** (XML nazwy) | 8 | 697 | 🟢 EASY | P2 |
| **spells** (zaklęcia) | 191 | 191 | 🟢 EASY-SKIP | P4 |
| **cpp** (serwer C++) | 32 | 109 | 🔴 HARD | P1 |
| **otclient_src** | 21 | 63 | 🟡 MEDIUM | P2 |
| **otclient_tools** | 8 | 154 | 🟡 MEDIUM | P3 |
| scripts/quests/etc | 0 | 0 | ✅ DONE | — |
| **RAZEM (do migracji)** | | **~86000** | | |

### Wykluczenia (NIE migrować):
- `documentation` — to pliki .md/.txt, nie kod
- `spells` — `spell.words` to inkantacje (###xxx, exori, utori) — NIE są player-visible tekst
- SQL queries w C++ — nie tłumaczyć (`SELECT`, `INSERT`, `DELETE`)
- CSS class names, HTML attributes (ids, classes) — nie tłumaczyć
- Regex patterns, format strings (`{:.2f}`, `%d`) — nie tłumaczyć
- Log/debug messages — opcjonalnie, niski priorytet

---

## 2. KLASYFIKACJA WZORCÓW TEKSTÓW

### 2.1. TYP A — Proste literały (najłatwiejsze)
**Opis**: Pojedynczy string bez zmiennych, bez concatenacji  
**Ilość szacowana**: ~60% wszystkich hitów  
**Ryzyko**: NISKIE  

**Przykłady**:
```lua
-- LUA (libs, quests)
"You broke the first seal."
"The Queen of the Banshees"
"Find the wyvern Heoni in the Edron mountains and take his sinew to Tereban."
```
```cpp
// C++ (server)
"Cannot load: {}"  // UWAGA: {} to fmt::format placeholder, NIE i18n placeholder
"A bag with {} slots where you can hold your loots."
```
```php
// PHP (www)
"Direct access not allowed!"
"This name is already used. Please choose another name!"
"Specified e-mail resulted with too many accounts."
```
```html
<!-- HTML (templates) -->
>Welcome to nginx!<
>Top 10 - Balance<
>Clear cache<
```

**Strategia migracji**:
```
PRZED:  "You broke the first seal."
PO:     i18n::t("quests.banshee.seal_1_broken")

PRZED:  player:sendTextMessage(MESSAGE_FAILURE, "Cannot load: " .. name)
PO:     player:sendLocalizedTextMessage(MESSAGE_FAILURE, "server.error.cannot_load", {name})
```

**Konwencja nazw kluczy**:
- `{domena}.{kontekst}.{opis}` — np. `quests.banshee.seal_1_broken`
- Domena: `npc`, `quests`, `items`, `server`, `cpp`, `ui`, `www`, `spells`
- Nazwa pochodzi od pliku/folderu + kontekst semantyczny

---

### 2.2. TYP B — String z interpolacją/placeholderami
**Opis**: Tekst ze zmiennymi wstawianymi dynamicznie  
**Ilość szacowana**: ~20% hitów  
**Ryzyko**: ŚREDNIE  

**Istniejące formaty placeholderów** (z aktualnych kluczy):
| Format | Użycie | Ilość kluczy | Kontekst |
|---|---|---:|---|
| `|PLAYERNAME|` | Nazwa gracza | 777 | NPC greet/farewell |
| `{keyword}` | NPC highlighted words | 1480 | NPC dialogi |
| `{{}}` | Pozycyjny argument Lua | 34 | NPC say z args |
| `{0}`, `{1}` | Pozycyjny C++ | ~50 | C++ fmt::format |

**WAŻNA ZASADA**: Jeden klucz = jeden tekst z placeholderami.  
**NIE** rozbijamy na wiele kluczy jak `key.part1 [ZMIENNA] key.part2`!

**Dlaczego**: Kolejność słów zmienia się w zależnych od języka. Po polsku:  
- EN: "Hello {player}, do you want to buy something?"  
- PL: "Witaj {player}, chcesz coś kupić?"  
- JP: "{player}さん、何か買いたいですか？"  

Rozbicie na 2 klucze uniemożliwiłoby poprawne tłumaczenie.

**Przykłady migracji**:
```lua
-- PRZED (concatenacja):
statusText = "Task name: " .. raceName .. ". Current kills: " .. kills .. ".\n"

-- PO (jeden klucz z placeholderami):
statusText = i18n::t("npc.grizzly_adams.task_status", {raceName, kills})
-- Klucz EN: "Task name: {{}}. Current kills: {{}}.\n"
-- Klucz PL: "Nazwa zadania: {{}}. Aktualne zabicia: {{}}.\n"
```

```cpp
// PRZED:
fmt::format("{} gained {} experience point{}.", ucfirst(getNameDescription()), gainExp, (gainExp != 1 ? "s" : ""))

// PO (jeden klucz z pluralizacją):
tr.format("cpp.creature.exp_gained", loc, {getNameDescription(), std::to_string(gainExp)})
// Klucz EN: "{0} gained {1} experience point(s)."
// Klucz PL: "{0} zdobył(a) {1} punktów doświadczenia."
```

```lua
-- PRZED (NPC item description):
"Unwrap it in your own house to create a <" .. ItemType(38707):getName() .. ">."

-- PO:
i18n::t("items.deco_kit.unwrap_desc", {ItemType(38707):getName()})
-- Klucz EN: "Unwrap it in your own house to create a <{{}}>."
```

---

### 2.3. TYP C — String z dynamiczną concatenacją (najtrudniejsze)
**Opis**: Tekst budowany przez `.concat` / `..` w pętli lub z wieloma zmiennymi  
**Ilość szacowana**: ~5% hitów  
**Ryzyko**: WYSOKIE  

**Przykłady**:

#### C1. Pętla budująca listę (Grizzly Adams task list):
```lua
-- PRZED:
local statusText = ""
for i = 1, #started do
    id = started[i]
    statusText = statusText .. "Task name: " .. tasks.GrizzlyAdams[id].raceName 
        .. ". Current kills: " .. player:getStorageValue(KillCounter + id) .. ".\n"
end
```
```lua
-- PO: Każdy element w pętli używa JEDNEGO klucza, wynik łączy
local statusLines = {}
for i = 1, #started do
    id = started[i]
    table.insert(statusLines, i18n::t("npc.grizzly_adams.task_line", {
        tasks.GrizzlyAdams[id].raceName,
        player:getStorageValue(KillCounter + id)
    }))
end
local statusText = table.concat(statusLines, "\n")
```

#### C2. Wedding ring description (Lynda NPC):
```lua
-- PRZED:
player:getName() .. " & " .. getPlayerNameById(candidate) .. " forever - married on " .. os.date("%B %d, %Y.")

-- PO (jeden klucz, 3 placeholdery):
i18n::t("npc.lynda.wedding_ring_desc", {
    player:getName(),
    getPlayerNameById(candidate),
    os.date("%B %d, %Y.")  -- UWAGA: datę też trzeba i18n-ować w przyszłości
})
-- Klucz EN: "{{}} & {{}} forever - married on {{}}"
-- Klucz PL: "{{}} & {{}} na zawsze - ślub {{}}"
```

#### C3. Frosty NPC item list:
```lua
-- PRZED:
items_list = items_list .. item[2] .. " " .. ItemType(item[1]):getName()

-- PO:
table.insert(items_parts, i18n::t("npc.frosty.item_entry", {item[2], ItemType(item[1]):getName()}))
-- Klucz EN: "{{}} {{}}"  -- ilość + nazwa
```

---

### 2.4. TYP D — C++ serwer (fmt::format + sendTextMessage)
**Opis**: Teksty w kodzie C++ serwera  
**Ryzyko**: WYSOKIE (wymaga kompilacji do weryfikacji)  

**Podtypy**:

#### D1. SQL Queries — NIE MIGROWAĆ
```cpp
fmt::format("SELECT `id` FROM `players` WHERE `account_id` = {} AND `name` = {}")
```
**Akcja**: SKIP — to nie są player-visible teksty

#### D2. Log/Debug messages — NISKI PRIORYTET
```cpp
fmt::format("[x:{}, y:{}, z:{}] Could not create house id: {}")
fmt::format("[PlayerWheelGem] uuid: {}, locked: {}, ...")
```
**Akcja**: Opcjonalnie migrować do `cpp.debug.*` kluczy, ale priorytet P4

#### D3. Player-visible messages — WYSOKI PRIORYTET
```cpp
// PRZED:
fmt::format("{} gained {} experience point{}.", ucfirst(getNameDescription()), gainExp, (gainExp != 1 ? "s" : ""))
// PO:
tr.format("cpp.creature.exp_gained", loc, {getNameDescription(), std::to_string(gainExp)})

// PRZED:
fmt::format("({} charm)", charm_name)
// PO:
tr.format("cpp.bestiary.charm_label", loc, {charm_name})

// PRZED:
fmt::format("{} {} {:02}:{:02}h", prefix, dateStr, hours, minutes)
// PO:
tr.format("cpp.item.time_display", loc, {prefix, dateStr, std::to_string(hours), std::to_string(minutes)})
```

#### D4. Dynamiczne key-generation — JUŻ ZMIGROWANE
```cpp
fmt::format("cpp.title.name_{}_female", id)  // Generuje klucz dynamicznie
fmt::format("cpp.vocation.desc_id_{}", id)
fmt::format("item.{}.name", itemId)
```
**Akcja**: SKIP — to generatory kluczy, nie hardcoded tekst

---

### 2.5. TYP E — XML nazwy i opisy
**Opis**: Atrybuty `name=`, `description=` w plikach XML  
**Ryzyko**: NISKIE (prosty pattern)  

```xml
<!-- PRZED: -->
<mount id="1" clientid="368" name="Widow Queen" speed="10" premium="yes"/>

<!-- PO (opcja 1 - klucz referencyjny): -->
<mount id="1" clientid="368" name="mounts.1.name" speed="10" premium="yes"/>

<!-- PO (opcja 2 - i18n lookup w parserze C++): -->
<!-- Sam XML nie zmienia się, parser szuka klucza "mount.{id}.name" -->
```

**Pliki**: `mounts.xml`, `familiars.xml`, `attachedeffects.xml`, `events.xml`  

**UWAGA**: Nazwy mountów/familiar mogą być używane programowo (w C++ comparisons).
Parser musi szukać tłumaczenia po `id`, nie po `name`.

---

### 2.6. TYP F — PHP (strona www MyAAC)
**Opis**: Teksty w PHP backendzie strony  
**Ryzyko**: ŚREDNIE-WYSOKIE (53K hitów, ale większość to CSS/HTML classes, SQL)  

**Podtypy**:

#### F1. UI Labels — MIGROWAĆ
```php
// PRZED:
echo "Direct access not allowed!";
// PO:
echo $t->get("www.admin.access_denied");
```

#### F2. SQL / CSS / HTML attributes — NIE MIGROWAĆ
```php
// Te NIE MIGRUJEMY:
"SELECT * FROM `accounts`"           // SQL
"col-12 col-sm-12 col-lg-10"        // CSS class
"card card-info card-outline"        // CSS class
"btn btn-success btn-sm"             // CSS class
"tab-pane fade active show"          // CSS class
"acc_datatable table table-striped"  // CSS class/id
```

#### F3. Twig templates — MIGROWAĆ
```twig
<!-- PRZED: -->
>Top 10 - Balance<
<!-- PO: -->
>{{ t('www.stats.top10_balance') }}<
```

**Filtrowanie**: Worker MUSI filtrować hity PHP aby pominąć:
- SQL queries (zawierają `SELECT|INSERT|UPDATE|DELETE|FROM|WHERE`)
- CSS classes (pasują do regex `^[a-z0-9\-_ ]+$` bez wielkich liter)
- HTML attributes (ids, data-*)
- Regexpy i ścieżki plików
- Nazwy zmiennych/kolumn bazy danych

---

### 2.7. TYP G — OTClient (Lua modules)
**Opis**: Teksty w interfejsie klienta gry  
**Ryzyko**: ŚREDNIE  

```lua
-- PRZED (modules):
label:setText("Health: " .. health)
-- PO:
label:setText(tr("otclient.ui.health_label", {health}))
```

**UWAGA**: OTClient ma WŁASNY system i18n (`tr()` function). Migracja wymaga:
1. Zamiana tekstu na `tr("klucz")` w .lua
2. Dodanie klucza do `i18n/en/otclient_modules.json`
3. NIE używamy `sendLocalizedTextMessage` — bo to client-side

---

## 3. ARCHITEKTURA TRYBU MIGRATION W WORKERZE

### 3.1. Pipeline migracji jednego pliku

```
┌─────────────────────────────────────────────────────┐
│                  MIGRATION PIPELINE                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. SCAN — odczyt pliku + identyfikacja hitów       │
│     └── pre_migration_scan.py → lista (line, text)  │
│                                                     │
│  2. CLASSIFY — klasyfikacja każdego hitu            │
│     ├── TYP A: prosty literał                       │
│     ├── TYP B: z placeholderami                     │
│     ├── TYP C: concatenacja dynamiczna              │
│     ├── TYP D: C++ fmt::format                      │
│     └── SKIP: SQL/CSS/debug/generowany klucz        │
│                                                     │
│  3. FILTER — odrzuć hity SKIP                       │
│     └── Reguły: SQL, CSS, regex, debug, short (<3ch)│
│                                                     │
│  4. GENERATE KEY — wygeneruj nazwę klucza i18n      │
│     └── Z ścieżki pliku + kontekstu semantycznego   │
│                                                     │
│  5. TRANSFORM — zamiana kodu                        │
│     ├── Stwórz nowy kod z kluczem i18n              │
│     ├── Zachowaj wcięcia i formatowanie              │
│     └── Upewnij się że zmiana jest ODWRACALNA       │
│                                                     │
│  6. EXTRACT EN VALUE — wyciągnij angielski tekst    │
│     └── Zapisz do i18n/en/{category}.json           │
│                                                     │
│  7. VALIDATE — walidacja zamienionego kodu           │
│     ├── Lua: loadstring() check                     │
│     ├── C++: syntax pattern check (nie kompilacja)  │
│     ├── PHP: php -l check                           │
│     └── XML: xml parser check                       │
│                                                     │
│  8. COMMIT — zatwierdź zmianę                       │
│     ├── Zapisz plik z zamianą                       │
│     ├── Zaktualizuj i18n/en/*.json                  │
│     └── Zaloguj operację                            │
│                                                     │
│  9. ROLLBACK — jeśli walidacja fail                 │
│     └── Przywróć oryginalny plik                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 3.2. Reguły bezpieczeństwa (krytyczne!)

1. **JEDEN plik na raz** — nie rób wielu plików jednocześnie
2. **Kopia zapasowa** — przed edycją stwórz `.bak` pliku
3. **Walidacja składni** — po każdej zamianie sprawdź składnię
4. **Atomowa zamiana** — albo WSZYSTKIE hity w pliku albo ŻADEN
5. **Deduplikacja kluczy** — NIE twórz duplikatów w JSON
6. **JSON sortowanie** — klucze w JSONie sortuj alfabetycznie
7. **Dry-run mode** — pierwszy przebieg bez zapisu (raportuje co zrobi)
8. **Limit na cykl** — max 5 plików na cykl workera
9. **Skip on conflict** — jeśli plik był edytowany od ostatniego scanu → skip

### 3.3. Konwencje nazewnictwa kluczy

```
{domena}.{kontekst}.{identyfikator}

Domeny:
  npc.{npc_name}.*           — NPC dialogi
  quests.{quest_name}.*      — Questy
  items.{category}.*         — Opisy itemów
  server.{module}.*          — Serwer (Lua skrypty)
  cpp.{source_file}.*        — Serwer (C++)
  www.{page}.*               — Strona PHP
  www.tpl.{template}.*       — Szablony Twig
  ui.{module}.*              — OTClient UI
  xml.{file}.{type}_{id}     — Dane XML (mounty, familiar, etc.)
  lib.{library}.*            — Lua biblioteki
  mount.{id}.name            — Nazwa mounta
  familiar.{id}.name         — Nazwa familiara
  event.{id}.name            — Nazwa eventu
  event.{id}.description     — Opis eventu

Identyfikator:
  - Opisowy, krótki, snake_case
  - Nie używaj numerów sekwencyjnych (say_1, say_2...) — to OK tylko dla NPC 
  - Używaj kontekstu semantycznego: "seal_broken", "exp_gained", "task_status"
```

---

## 4. STRATEGIE MIGRACJI PER JĘZYK/PLIK

### 4.1. Lua — NPC (niezmigrowane pozostałości)

**Problem**: Większość NPC jest ZMIGROWANA (13769 kluczy), ale pozostały:
- `setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "..." .. var .. "...")` — opisy itemów
- Pętlowe budowanie tekstu (Grizzly Adams)
- `string.format()` calls

**Strategia**:
```lua
-- Worker zamieni:
item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
    "Unwrap it in your own house to create a <" .. ItemType(38707):getName() .. ">.")
-- Na:
item:setLocalizedAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
    "items.deco_kit.unwrap_desc", {ItemType(38707):getName()})
```

**UWAGA**: `setLocalizedAttribute` MOŻE NIE ISTNIEĆ jeszcze w C++! 
Trzeba sprawdzić czy jest taki API. Jeśli nie — alternatywa:
```lua
item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
    i18n::t("items.deco_kit.unwrap_desc", {ItemType(38707):getName()}))
```

### 4.2. Lua — Biblioteki (libs)

**Pliki**: `data-otservbr-global/lib/core/quests.lua`, inne lib/*.lua  
**Wzorzec**: Głównie literały typu A (proste stringi)

```lua
-- PRZED:
{ name = "The Queen of the Banshees", ... }
-- PO:
{ name = i18n::t("quests.banshee.name"), ... }

-- PRZED:
"You broke the first seal."
-- PO:
i18n::t("quests.banshee.seal_1_broken")
```

**PROBLEM**: Literały w tablicach/definicjach — zamiana może złamać inicjalizację.  
**ROZWIĄZANIE**: Worker musi rozpoznać kontekst — czy string jest w:
- `{ name = "..." }` → zamienić na `{ name = i18n::t("klucz") }`
- `{ "..." }` → zamienić na element tablicy z kluczem
- argument funkcji → zamienić jak argument

### 4.3. Lua — Quests/Scripts

**Status**: ZERO hitów (0/971 plików) — **JUŻ ZMIGROWANE** ✅

### 4.4. C++ — Serwer

**Wzorce do migracji** (z 109 hitów, po odfiltracji SQL/debug):
- ~15 player-visible texts (fmt::format z message → widoczne graczom)
- ~50 SQL queries → SKIP
- ~20 debug/log → P4 (opcjonalny)
- ~24 dynamiczne key generators → SKIP (już i18n)

**Strategia**:
```cpp
// PRZED:
TextMessage message(MESSAGE_EXPERIENCE_OTHERS, 
    fmt::format("{} gained {} experience point{}.", 
        ucfirst(getNameDescription()), gainExp, (gainExp != 1 ? "s" : "")));

// PO:
auto &tr = i18n::g_translator();
const std::string loc(player->getLocale().empty() ? "en" : std::string(player->getLocale()));
TextMessage message(MESSAGE_EXPERIENCE_OTHERS, 
    tr.format("cpp.creature.exp_gained", loc, 
        {getNameDescription(), std::to_string(gainExp)}));
```

**OGRANICZENIE WORKERA**: Worker NIE POWINIEN samodzielnie migrować C++ bez 
późniejszej kompilacji testowej. Zamiast tego:
1. Worker generuje **propozycję zmiany** (diff)
2. Zapisuje do `i18n/status/migration_proposals/cpp/`
3. Człowiek/CI pipeline weryfikuje i zatwierdza

### 4.5. XML — Mounty/Familiars/Events

**Strategia**: Nie modyfikować XML — zamiast tego:
1. Worker czyta XML, wyciąga `name`/`description` po `id`
2. Generuje klucze: `mount.{id}.name`, `event.{id}.description`
3. Dodaje do `i18n/en/xml.json`
4. Parser C++ szuka tłumaczenia po kluczu, fallback na oryginalny text

### 4.6. PHP — Strona WWW

**Gigantyczny zakres (53K hitów)**, ale po filtrowaniu realnie: ~5000-8000

**Filtr Skip**:
```python
SKIP_PATTERNS_PHP = [
    r"^SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP",  # SQL
    r"^[a-z0-9\-_ ]+$",          # CSS classes (all lowercase)
    r"^(col|btn|card|tab|table|form|modal|nav|alert|badge)",  # Bootstrap
    r"^\$(this|config|db|query)",  # PHP variables
    r"^vendor/|^tools/|^includes/",  # paths
    r"^https?://",                  # URLs
    r"^[#.]",                       # CSS selectors 
    r"^\d+(\.\d+)*$",              # numbers/versions
    r"^[A-Z_]+$",                  # PHP CONSTANTS
]
```

**Strategia migracji** (dla Twig templates):
```twig
<!-- PRZED: -->
<h3>Top 10 - Balance</h3>

<!-- PO: -->
<h3>{{ t('www.stats.top10_balance') }}</h3>
```

**Strategia migracji** (dla PHP backend):
```php
// PRZED:
echo "Direct access not allowed!";
// PO:
echo t('www.admin.access_denied');
```

**UWAGA**: `t()` function musi istnieć w PHP frameworku.  
Sprawdzić czy MyAAC ma `t()` / `__()` / `gettext()` lub dodać.

### 4.7. HTML — Templates

Większość pokrywa się z PHP (Twig). Czyste HTML pliki:
```html
<!-- PRZED: -->
<title>Welcome to nginx!</title>
<!-- PO: -->
<!-- Skip — to nginx default page, nie nasza treść -->
```

Worker powinien mieć listę plików do pominięcia (nginx, vendor, 3rd party).

---

## 5. PRIORYTETYZACJA I KOLEJNOŚĆ MIGRACJI

### Faza 1 — "Quick Wins" (tydzień 1, autonomicznie)
| Co | Pliki | Trudność | Opis |
|---|---:|---|---|
| errors (Lua) | 141 | 🟢 | Proste literały w sendTextMessage |
| libs (Lua) | 35 | 🟡 | Literały w tablicach, quests.lua |
| mounts/XML | 8 | 🟢 | Wyciągnięcie name/desc do JSON |
| cpp proposals | 32 | 🟡 | Tylko PROPOZYCJE, nie auto-zapis |

### Faza 2 — "OTClient" (tydzień 2)
| Co | Pliki | Trudność |
|---|---:|---|
| otclient_modules | 169 | 🟡 |
| otclient_src | 21 | 🟡 |
| otclient_tools | 8 | 🟡 |

### Faza 3 — "WWW" (tydzień 3-4)
| Co | Pliki | Trudność |
|---|---:|---|
| php (po filtracji) | ~500 | 🟡 |
| html/twig | ~100 | 🟡 |

### Faza 4 — "Baza danych" (kiedyś)
- Nazwy itemów w DB
- Opisy skills/vocations w DB
- **Tylko jak nie będzie co robić** 😄

---

## 6. NARZĘDZIE: `tools/i18n_migrate.py`

### 6.1. Architektura

```
i18n_migrate.py
├── --category {errors|libs|mounts|cpp|php|html|otclient}
├── --scope {otservbr|canary|full}
├── --batch N              (max plików per uruchomienie)
├── --dry-run              (tylko raport, bez zmian)
├── --force-file PATH      (migruj konkretny plik)
├── --skip-validation      (pomiń walidację składni)
├── --proposals-only       (tylko propozycje, bez zapisu — dla C++)
└── --interactive          (pytaj przed każdą zamianą)
```

### 6.2. Moduły wewnętrzne

```python
class MigrationEngine:
    def scan_file(path) -> List[Hit]
    def classify_hit(hit) -> HitType  # A/B/C/D/SKIP
    def generate_key(hit, file_path) -> str
    def transform_code(hit, key) -> TransformResult
    def extract_en_value(hit) -> str
    def validate_syntax(path, language) -> bool
    def commit(path, transforms, en_values) -> bool
    def rollback(path) -> bool

class HitClassifier:
    def is_sql(text) -> bool
    def is_css_class(text) -> bool
    def is_debug_log(text) -> bool
    def is_dynamic_key(text) -> bool
    def has_interpolation(text) -> InterpolationType
    def has_concatenation(line_context) -> bool

class KeyGenerator:
    def from_npc_path(path) -> str       # npc.{name}.mig_{n}
    def from_quest_path(path) -> str     # quests.{name}.mig_{n}
    def from_lib_path(path) -> str       # lib.{name}.mig_{n}
    def from_cpp_path(path) -> str       # cpp.{source}.mig_{n}
    def from_php_path(path) -> str       # www.{page}.mig_{n}
    def from_xml_path(path, id) -> str   # xml.{file}.{type}_{id}

class CodeTransformer:
    def transform_lua_literal(hit) -> str
    def transform_lua_concat(hit) -> str
    def transform_lua_string_format(hit) -> str
    def transform_cpp_fmt_format(hit) -> str
    def transform_php_echo(hit) -> str
    def transform_twig_text(hit) -> str
    def transform_xml_attribute(hit) -> str
```

### 6.3. Output format

```json
// i18n/status/migration_log.json
{
  "last_run": "2026-02-15T18:00:00Z",
  "total_migrated": 150,
  "total_skipped": 3200,
  "total_errors": 2,
  "categories": {
    "errors": {"migrated": 50, "skipped": 80, "errors": 0},
    "libs": {"migrated": 100, "skipped": 120, "errors": 2}
  },
  "files": [
    {
      "path": "data-otservbr-global/lib/core/quests.lua",
      "hits": 45,
      "migrated": 40,
      "skipped": 5,
      "errors": 0,
      "keys_added": ["quests.banshee.name", "quests.banshee.seal_1_broken", ...]
    }
  ]
}
```

---

## 7. INTEGRACJA Z WORKEREM

### 7.1. Dispatcher case

```bash
MIGRATION)
    echo "🔄 TRYB: MIGRATION — automatyczna migracja kategorii '$MIGRATION_CATEGORY'"
    
    local _mig_tool="tools/i18n_migrate.py"
    if [ ! -f "$_mig_tool" ]; then
        echo "❌ Brak narzędzia $_mig_tool"
        return 1
    fi
    
    local _mig_out
    _mig_out=$(python3 "$_mig_tool" \
        --category "$MIGRATION_CATEGORY" \
        --scope "$I18N_SCOPE" \
        --batch "$MIGRATION_BATCH_SIZE" \
        2>&1)
    
    # Parse results
    local migrated=$(echo "$_mig_out" | grep -oP 'migrated=\K\d+')
    local skipped=$(echo "$_mig_out" | grep -oP 'skipped=\K\d+')
    local errors=$(echo "$_mig_out" | grep -oP 'errors=\K\d+')
    
    echo "   ✅ MIGRATION: migrated=$migrated skipped=$skipped errors=$errors"
    ;;
```

### 7.2. Komendy

```
MIGRATION                     — auto-select kategorii (round-robin)
MIGRATION:errors              — migruj kategorię errors
MIGRATION:libs:10             — migruj libs, batch=10
MIGRATION:cpp:proposals       — generuj propozycje C++
MIGRATION_DRYRUN              — dry-run (raport bez zmian)
```

### 7.3. Rotacja kategorii

Worker automatycznie wybiera kolejną kategorię:
```
errors → libs → mounts → otclient_modules → php → html → cpp(proposals)
```

Po przejściu pełnego cyklu bez zmian → worker raportuje "MIGRATION COMPLETE".

---

## 8. TRUDNE PRZYPADKI — SZCZEGÓŁOWE STRATEGIE

### 8.1. Pluralizacja (EN: 1 point vs 2 points)

```cpp
// C++ PRZED:
(gainExp != 1 ? "s" : "")
// PO: Jeden klucz ze specjalnym formatem
// Klucz EN: "{0} gained {1} experience point(s)."
// Każdy język obsługuje pluralizację po swojemu w tłumaczeniu
```

**Konwencja**: Używamy `(s)` w kluczu EN. Tłumacz decyduje jak przełożyć.
Ewentualnie w przyszłości: ICU MessageFormat `{count, plural, one{point} other{points}}`

### 8.2. Gender (PL: zdobył vs zdobyła)

Na razie: klucz contains `(a)` lub osobne klucze `*_male` / `*_female`
```
cpp.creature.exp_gained_male = "{0} zdobył {1} punktów doświadczenia."
cpp.creature.exp_gained_female = "{0} zdobyła {1} punktów doświadczenia."
```

### 8.3. Daty (`os.date` w Lua)

```lua
-- PRZED:
os.date("%B %d, %Y.")
-- PO:
i18n::formatDate(os.time(), "date.format.full")
-- Klucz EN: "%B %d, %Y"
-- Klucz PL: "%d %B %Y"
```

**UWAGA**: `i18n::formatDate()` MOŻE NIE ISTNIEĆ — dodać lub użyć workaround:
```lua
os.date(i18n::t("date.format.full"))
```

### 8.4. Texty z `\z` continuation (wieloliniowe NPC dialogi)

```lua
-- PRZED:
"I'd have been a much better captain then Kid was. \z
 I played several captains on stage..."
-- PO:
i18n::t("npc.bearded_woman.story_1")
-- Klucz EN zachowuje pełny tekst (bez \z)
```

### 8.5. Item descriptions dynamicznie budowane

```lua
-- Patterns:
"You bought this item in the Store.\nUnwrap it in your own house to create a " .. name .. "."
```

**Strategia**: JEDEN klucz z `{{}}` placeholder
```lua
i18n::t("items.store.unwrap_desc", {name})
-- EN: "You bought this item in the Store.\nUnwrap it in your own house to create a {{}}."
```

### 8.6. Texty które NIE WOLNO TŁUMACZYĆ

Niektóre teksty muszą pozostać w oryginale:
- Spell incantations: `"exori"`, `"utori mort"`, `"exevo gran mas flam"`
- NPC internal names used as identifiers
- Monster race names (used as keys in tables)
- File paths, URLs, database column names

Worker musi mieć whitelist/blacklist dla takich tekstów.

---

## 9. WALIDACJA I SAFETY

### 9.1. Walidacja składni per język

| Język | Komenda walidacji | Fallback |
|---|---|---|
| Lua | `loadstring(code)` lub `luac -p` | Cofnij zamianę |
| C++ | pattern matching (nie kompilacja) | PROPOSALS ONLY |
| PHP | `php -l file.php` | Cofnij zamianę |
| XML | `python3 -c "import xml.etree.ElementTree as ET; ET.parse(file)"` | Cofnij zamianę |
| Twig | Brak — sprawdź `{{ }}` balans | Cofnij zamianę |

### 9.2. Unit testy migracji

Przed włączeniem MIGRATION mode:
1. Przygotować 10 plików testowych (po 2 z każdego języka)
2. Uruchomić `--dry-run` i porównać wynik z oczekiwanym
3. Uruchomić na realnym pliku i sprawdzić:
   - Czy kod się uruchamia
   - Czy klucz pojawił się w `i18n/en/*.json`
   - Czy oryginalny tekst jest wartością klucza EN

### 9.3. Rollback mechanizm

```
i18n/status/migration_backups/{timestamp}/{file_path}.bak
```

Worker trzyma kopie zapasowe przez 7 dni. Po tym: git history.

---

## 10. KOLEJNE KROKI (ACTION ITEMS)

- [ ] **AI-1**: Napisać `tools/i18n_migrate.py` z klasami: MigrationEngine, HitClassifier, KeyGenerator, CodeTransformer
- [ ] **AI-2**: Dodać HitClassifier reguły filtrowania (SQL, CSS, debug, paths)
- [ ] **AI-3**: Implementacja CodeTransformer per język (Lua, C++, PHP, XML)
- [ ] **AI-4**: Dodać MIGRATION case do i18n_worker_simple.sh dispatcher
- [ ] **AI-5**: Dodać komendy MIGRATION/MIGRATION:{cat}/MIGRATION_DRYRUN
- [ ] **AI-6**: Przygotować 10 plików testowych i uruchomić dry-run
- [ ] **AI-7**: Test na kategorii `errors` (141 plików, proste wzorce)
- [ ] **AI-8**: Test na kategorii `libs` (35 plików, tablice quests.lua)
- [ ] **AI-9**: Test na `mounts/XML` (8 plików, xml name extraction)
- [ ] **AI-10**: Uruchomić Fazę 1 na produkcji (errors → libs → mounts → cpp proposals)

---

## 11. PODSUMOWANIE RYZYK

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|---|---|---|---|
| Złamanie składni pliku | Średnie | 🔴 Wysoki | Walidacja + rollback |
| Duplikaty kluczy | Niskie | 🟡 Średni | Dedup check w KeyGenerator |
| Guardian git pull overwrite | Średnie | 🔴 Wysoki | Commit natychmiast |
| Missing API (setLocalizedAttribute) | Pewne | 🟡 Średni | Workaround z i18n::t() |
| PHP bez t() function | Pewne | 🟡 Średni | Dodać t() helper do MyAAC |
| C++ zmiana wymaga rekompilacji | Pewne | 🔴 Wysoki | PROPOSALS ONLY mode |
| Worker loop na błędnym pliku | Niskie | 🟡 Średni | Skip + blacklist po 3 failures |
| Race condition (2 workers) | Niskie | 🟡 Średni | Lock file per plik |
