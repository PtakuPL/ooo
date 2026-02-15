# MIGRATION MODE — Master Plan
## Automatyczna migracja hardcoded tekstów → klucze i18n

**Data**: 2026-02-15  
**Cel**: Worker tryb MIGRATION — samoistna zamiana tekstów w kodzie na klucze i18n  
**Priorytet**: Musi działać autonomicznie przez tydzień bez interwencji  
**Ostatnia aktualizacja**: 2026-02-15 19:20 UTC

---

## 📊 POSTĘP REALIZACJI PLANU

### Sekcje planu — status:

| # | Sekcja | Status | Notatki |
|--:|--------|--------|---------|
| 1 | Statystyki PRE-MIGRACJI | ✅ Gotowe | 124,798 hitów, 6,358 plików, 32 kategorii |
| 2 | Klasyfikacja wzorców (Typ A-G) | ✅ Gotowe | 7 typów zdefiniowanych |
| 3 | Architektura trybu MIGRATION | ✅ Gotowe | Pipeline, reguły, konwencje kluczy |
| 4 | Strategie migracji per język | ✅ Gotowe | Lua, C++, XML, PHP, HTML |
| 5 | Priorytetyzacja faz (1-4) | ✅ Gotowe | 4 fazy zdefiniowane |
| 6 | Narzędzie `tools/i18n_migrate.py` | ✅ **ZAIMPLEMENTOWANE** | 600 linii, 4 klasy, 16 kategorii |
| 7 | Integracja z workerem | ✅ **ZAIMPLEMENTOWANE** | Dispatcher + komendy MIGRATION/DRYRUN |
| 8 | Trudne przypadki | ✅ Gotowe | Pluralizacja, gender, daty, multiline |
| 9 | Walidacja i safety | ✅ Gotowe | luac/php -l/xml, rollback |
| 10 | ACTION ITEMS (AI-1..AI-10) | 🔶 **6/10 DONE** | AI-1..AI-6 ✅, AI-7..AI-10 ⏳ |
| 11 | Podsumowanie ryzyk | ✅ Gotowe | 8 ryzyk z mitygacjami |
| 12 | Kompletna taksonomia źródeł | ✅ Gotowe | 19 podsekcji (12.0-12.19) |
| 13 | Status plików migracji | ✅ Gotowe | 608 plików zmapowanych |
| 14 | Status migracji per plik | ✅ Gotowe | Tabele z hitami per plik |
| 15 | Monsters XML migration | ✅ Gotowe | 1,703 hitów |
| 16 | PHP/WWW migration | ✅ Gotowe | 2,779 hitów |
| 17 | OTClient migration | ✅ Gotowe | 169+ hitów |
| 18 | Priorytety końcowe | ✅ Gotowe | P0-P4 ranking |
| 19 | Dodatkowe niezmigrowane wzorce | ✅ Gotowe | 11 deep-scan podsekcji |
| 20 | Kompletna matryca migracji | ✅ Gotowe | DONE / TODO / SKIP |
| 21 | Podsumowanie planu | ✅ Gotowe | Fazy 0-7, ~3,800 kluczy |
| 22 | Mapa plików statusu | ✅ Gotowe | 18 podsekcji, pełna mapa |
| 23 | Integracja migracji z systemem statusu | ✅ Gotowe | 7 podsekcji |
| 24 | Detekcja zakończenia PRE_MIGRATION | ✅ **ZAIMPLEMENTOWANE** | 32/32 kat., `pre_migration_complete.json` |

### ACTION ITEMS — postęp:

| AI | Zadanie | Status | Data | Szczegóły |
|---:|---------|--------|------|-----------|
| 1 | `tools/i18n_migrate.py` — MigrationEngine + klasy | ✅ Done | 2026-02-15 | 600 linii, 4 klasy główne |
| 2 | HitClassifier — reguły filtrowania | ✅ Done | 2026-02-15 | 22 SKIP patterns (SQL, CSS, debug, paths...) |
| 3 | CodeTransformer per język | ✅ Done | 2026-02-15 | 6 transformerów: lua×2, cpp, php, twig, xml |
| 4 | MIGRATION case w workerze | ✅ Done | 2026-02-15 | Gate `MIGRATION_ENABLED` + wywołanie engine |
| 5 | Komendy MIGRATION/DRYRUN | ✅ Done | 2026-02-15 | `MIGRATION:{cat}:{batch}:{scope}`, `MIGRATION_DRYRUN:` |
| 6 | Dry-run testy | ✅ Done | 2026-02-15 | errors=1,547 hits/3 files, cpp=9 hits/2 files |
| 7 | Test `errors` (141 plików) | ⏳ Pending | - | Wymaga `MIGRATION_ENABLED=true` |
| 8 | Test `libs` (35 plików) | ⏳ Pending | - | Wymaga `MIGRATION_ENABLED=true` |
| 9 | Test `mounts/XML` (8 plików) | ⏳ Pending | - | Wymaga `MIGRATION_ENABLED=true` |
| 10 | Faza 1 produkcja | ⏳ Pending | - | errors → libs → mounts → cpp proposals |

### Fazy migracji — postęp:

| Faza | Opis | Kluczy | Status |
|-----:|------|-------:|--------|
| 0 | Uzupełnienie pustaków (mounts, outfits...) | ~100 | ⏳ Czeka |
| 1 | XML Data Extraction (imbuements, charms...) | ~200 | ⏳ Czeka |
| 2 | Quest System (quests.lua) | ~2,400 | ⏳ Czeka |
| 3 | GameStore (kategorie, oferty) | ~1,000 | ⏳ Czeka |
| 4 | Misc Lua (map markers, modal buttons...) | ~50 | ⏳ Czeka |
| 5 | C++ Proposals | 2-3 | ⏳ Czeka |
| 6 | OTClient Sync Pipeline | (infra) | ⏳ Czeka |
| 7 | PHP Full Migration | TBD | ⏳ Czeka |

### PRE_MIGRATION — status:

| Metryka | Wartość |
|---------|---------|
| Kategorii przeskanowanych | **32/32** ✅ |
| Kategorii czystych (0 hitów) | 12 |
| Kategorii z hitami | 20 |
| Łącznie hitów | 124,798 |
| Plików z hitami | 6,358 |
| Stabilność skanów | ✅ stable |
| Plik statusu | `i18n/status/pre_migration_complete.json` |

### Infrastruktura — co zaimplementowano:

| Komponent | Plik | Linie | Status |
|-----------|------|------:|--------|
| Migration Engine | `tools/i18n_migrate.py` | ~600 | ✅ Nowy |
| HitClassifier | `tools/i18n_migrate.py` | — | ✅ 22 reguł SKIP |
| KeyGenerator | `tools/i18n_migrate.py` | — | ✅ 16 kategorii domen |
| CodeTransformer | `tools/i18n_migrate.py` | — | ✅ 6 transformerów |
| Worker MIGRATION case | `i18n_worker_simple.sh` | ~21610 | ✅ Rozbudowane |
| Worker commands regex | `i18n_worker_simple.sh` | ~20856 | ✅ +2 komendy |
| PRE_MIGRATION complete | `i18n_worker_simple.sh` | ~21670 | ✅ Nowy blok |
| PRE_MIGRATION status | `i18n/status/pre_migration_complete.json` | — | ✅ Nowy |
| Migration log | `i18n/status/migration_log.json` | — | ✅ Nowy |
| Migration proposals | `i18n/status/migration_proposals/` | — | ✅ Nowy dir |

### Blokady:

| Element | Wartość | Znaczenie |
|---------|---------|-----------|
| `MIGRATION_ENABLED` | `false` | 🔒 Migracja kodu permanentnie zablokowana |
| Komendy MIGRATION/DRYRUN | Zdefiniowane | Parser gotowy, ale engine zablokowany |
| C++ proposals | Auto-forced | Nigdy auto-modify, zawsze `.diff` |

### Commity tej sesji:

| Hash | Opis |
|------|------|
| `3669bf158` | PRE_MIGRATION completion detection (sekcja 24) |
| `d481a718e` | MIGRATION engine AI-1..AI-6 (tools/i18n_migrate.py + worker) |

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

- [x] **AI-1**: Napisać `tools/i18n_migrate.py` z klasami: MigrationEngine, HitClassifier, KeyGenerator, CodeTransformer ✅ (2026-02-15)
- [x] **AI-2**: Dodać HitClassifier reguły filtrowania (SQL, CSS, debug, paths) ✅ (2026-02-15, 22 SKIP patterns)
- [x] **AI-3**: Implementacja CodeTransformer per język (Lua, C++, PHP, XML) ✅ (2026-02-15, 6 transformerów: lua_literal, lua_concat, cpp_literal, php_literal, twig_text, xml_attribute)
- [x] **AI-4**: Dodać MIGRATION case do i18n_worker_simple.sh dispatcher ✅ (2026-02-15, if MIGRATION_ENABLED gate + python3 tools/i18n_migrate.py)
- [x] **AI-5**: Dodać komendy MIGRATION/MIGRATION:{cat}/MIGRATION_DRYRUN ✅ (2026-02-15, regex + case handlers)
- [x] **AI-6**: Przygotować 10 plików testowych i uruchomić dry-run ✅ (2026-02-15, tested: errors=1547 hits/3 files, cpp=9 hits/2 files)
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

---

## 12. KOMPLETNA TAKSONOMIA ŹRÓDEŁ TEKSTU (ROZSZERZENIE)

### 12.0. Stan aktualny — inwentaryzacja kluczy i18n

**AKTUALNIE ZMIGROWANE** (53,586 kluczy EN):

| Kategoria JSON | Klucze | Status |
|---|---:|---|
| items.json | 17,057 | ✅ Wyodrębnione z XML |
| npc.json | 13,769 | ✅ NPC dialogi zmigrowane |
| monsters.json | 5,915 | ✅ Nazwy/opisy monstrów |
| server.json | 2,574 | ✅ Lua system scripts |
| scripts.json | 2,170 | ✅ Quest/action scripts |
| otclient_modules.json | 1,987 | ✅ OTClient moduły |
| questlog.json | 1,918 | ✅ Quest log nazwy/opisy |
| spells.json | 1,534 | ✅ Zaklęcia |
| html.json | 1,495 | ✅ HTML templates |
| books.json | 1,403 | ✅ Książki/zwoje/listy |
| achievements.json | 1,048 | ✅ Osiągnięcia |
| cpp.json | 879 | ✅ C++ server messages |
| quests.json | 610 | ✅ Quest system |
| raids.json | 273 | ✅ Rajdy (announce msg) |
| client.json | 242 | ✅ Klient Lua |
| talkactions.json | 199 | ✅ Komendy/talkactions |
| npclib.json | 147 | ✅ NPC library |
| libs.json | 89 | ✅ Lua libraries |
| otclient_data.json | 72 | ✅ OTClient data |
| php.json | 59 | ✅ PHP WWW |
| Inne (10 plików) | ~111 | ✅ Różne |
| **RAZEM zmigrowane** | **53,586** | |

**BRAKUJĄCE** (jeszcze NIE zmigrowane):

| Źródło | Szacowana ilość | Kategoria JSON | Priorytet |
|---|---:|---|---|
| GameStore nazwy/opisy | ~760 | store.json | P2 |
| Quest nazwy/opisy (quests.lua) | ~505 + ~1950 missions | questlog.json (rozszerzenie) | P1 |
| House nazwy | ~993 | houses.json | P4 |
| Bestiary klasy/locations | ~30 klas + locations | bestiary.json | P2 |
| Bestiary charmy (nazwy+opisy) | ~26 | charms.json | P2 |
| Imbuement nazwy/opisy/kategorie | ~18 kat + ~50+ imbuements | imbuements.json | P2 |
| Map markers | ~38 | markers.json | P3 |
| Condition messages (C++) | ~5-10 | cpp.json (rozszerzenie) | P1 |
| OTClient src (C++ strings) | ? | otclient_src.json | P3 |
| Mounts (nazwy puste!) | ~50+ | mounts.json | P2 |
| Familiars (nazwy) | ~10+ | familiars.json | P2 |
| Outfits/vocations (nazwy) | ~25 outfits + ~8 voc | outfits.json / vocations.json | P2 |
| Groups (nazwy) | 4 | groups.json | P4 |
| Chat channels (nazwy) | ~10 | chatchannels.json (być może uzupełnić) | P3 |
| Attached effects | ~5+ | attachedeffects.json | P4 |
| Event nazwy/opisy (events.xml) | ~5+ | events.json (rozszerzenie) | P3 |
| C++ tile.cpp/item_parse.cpp resztki | 2-3 | cpp.json (rozszerzenie) | P1 |
| Bank receipts (hireling) | 1 format | libs.json (rozszerzenie) | P3 |
| Database defaults (VIP groups) | 3 | db.json | P4 |
| Config.lua (serverMotd, serverName) | 2 | Nie migrować (per-server) | SKIP |

---

### 12.1. ŹRÓDŁO: Quest System (quests.lua) — 503 questów, 1950 misji

**Plik**: `data-otservbr-global/lib/core/quests.lua` (6715 linii)

**Struktura danych**:
```lua
Quests = {
    [1] = {
        name = "The Queen of the Banshees",           -- TŁUMACZYĆ
        missions = {
            [1] = {
                name = "The Hidden Seal",              -- TŁUMACZYĆ
                description = "You broke the first seal.", -- TŁUMACZYĆ
            },
            [2] = {
                name = "The Plague Seal",
                description = function(player)         -- DYNAMICZNY! (patrz niżej)
                    ...
                end,
            },
        },
    },
}
```

**UWAGA KRYTYCZNA**: Niektóre opisy misji to FUNKCJE Lua, nie stringi!
```lua
description = function(player)
    local status = player:getStorageValue(Storage.Quest....)
    if status == 1 then return "Find the hidden passage." end
    if status == 2 then return "You found the passage." end
end
```

**Strategia migracji**:
```lua
-- Proste nazwy/opisy → klucz i18n:
name = "#i18n:questlog.banshee.name"
description = "#i18n:questlog.banshee.seal_1.desc"

-- Dynamiczne opisy (funkcje) → klucze wewnątrz funkcji:
description = function(player)
    local status = player:getStorageValue(...)
    if status == 1 then return "#i18n:questlog.banshee.seal_2.status_1" end
    if status == 2 then return "#i18n:questlog.banshee.seal_2.status_2" end
end
```

**Mechanizm**: System quest log już obsługuje `#i18n:` prefix w `translateQuestlogKey()`.
Wystarczy zmienić wartości w tablicy Quests.

---

### 12.2. ŹRÓDŁO: GameStore (gamestore.lua) — 760 ofert

**Plik**: `data/modules/scripts/gamestore/gamestore.lua` (6801 linii)

**Struktura**:
```lua
{
    name = "Consumables",          -- Nazwa kategorii
    offers = {
        {
            name = "Great Health Cask",   -- Nazwa oferty
            description = "...",           -- Opis oferty (z HTML: &#8226;)
            type = OFFER_TYPE_STACKABLE,
        }
    }
}
```

**Typy ofert** (27 typów):
OFFER_TYPE_ALLBLESSINGS, OFFER_TYPE_BLESSINGS, OFFER_TYPE_CHARGES,
OFFER_TYPE_CHARMS, OFFER_TYPE_EXPBOOST, OFFER_TYPE_HIRELING,
OFFER_TYPE_HIRELING_NAMECHANGE, OFFER_TYPE_HIRELING_OUTFIT,
OFFER_TYPE_HIRELING_SEXCHANGE, OFFER_TYPE_HIRELING_SKILL,
OFFER_TYPE_HOUSE, OFFER_TYPE_HUNTINGSLOT, OFFER_TYPE_INSTANT_REWARD_ACCESS,
OFFER_TYPE_ITEM_BED, OFFER_TYPE_ITEM_UNIQUE, OFFER_TYPE_MOUNT,
OFFER_TYPE_NAMECHANGE, OFFER_TYPE_NONE, OFFER_TYPE_OUTFIT,
OFFER_TYPE_OUTFIT_ADDON, OFFER_TYPE_PREMIUM, OFFER_TYPE_PREYBONUS,
OFFER_TYPE_PREYSLOT, OFFER_TYPE_PROMOTION, OFFER_TYPE_SEXCHANGE,
OFFER_TYPE_STACKABLE, OFFER_TYPE_TEMPLE

**Specjalna trudność**: Opisy blessingów zawierają HTML entities (`&#8226;`),
dynamiczne interpolacje (`{character}`, `{limit|5}`, `{info}`, `{activated}`)
i warunkową budowę tekstu (VIP bonusy):
```lua
if vipBonusExp > 0 then
    premiumDescription = premiumDescription .. "&#8226; +" .. vipBonusExp .. "% experience rate\n"
end
```

**Strategia**: 
1. Statyczne nazwy kategorii/ofert → proste klucze
2. Opisy z HTML → jeden klucz, zachować HTML entities
3. Dynamiczne opisy VIP → klucz z placeholder per linia + concat

```lua
name = i18n::t("store.category.consumables")
description = i18n::t("store.blessing.all_regular.desc") 
-- VIP description (dynamiczne):
premiumDescription = i18n::t("store.vip.desc_header")
if vipBonusExp > 0 then
    premiumDescription = premiumDescription .. "\n" .. 
        i18n::t("store.vip.bonus_exp", {tostring(vipBonusExp)})
end
```

---

### 12.3. ŹRÓDŁO: Bestiary System — klasy, lokacje, charmy

**Monster.Bestiary w plikach .lua** (1637 monstrów):
```lua
monster.Bestiary = {
    class = "Aquatic",                    -- TŁUMACZYĆ (30 unikalnych klas)
    race = BESTY_RACE_AQUATIC,            -- Enum, NIE tłumaczyć
    Locations = "Ancient Ancestorial Grounds and Sunken Temple.", -- TŁUMACZYĆ
}
```

**Bestiary klasy** (do wyodrębnienia):
Aquatic, Amphibic, Bird, Construct, Demon, Dragon, Elemental,
Extra Dimensional, Fey, Giant, Human, Humanoid, Lycanthrope,
Magical, Mammal, Plant, Reptile, Slime, Undead, Vermin, ...

**Bestiary charmy** (`data/scripts/systems/bestiary_charms.lua`, 26 charm):
```lua
{ name = "Wound", description = "Triggers on a creature with a certain chance and deals 5% ..." }
{ name = "Enflame", description = "..." }
{ name = "Dodge", description = "Dodges an attack with a certain chance without taking any damage at all." }
```

**Strategia**:
```lua
-- Klasy — klucz per klasa:
class = i18n::t("bestiary.class.aquatic") -- lub użyć ID klasy

-- Lokacje — klucz per monster:
Locations = i18n::t("bestiary.locations.deathling_spellsinger")

-- Charmy — klucz per charm:
name = i18n::t("bestiary.charm.wound.name")
description = i18n::t("bestiary.charm.wound.desc")
```

**C++ bestiary** — JUŻ ZMIGROWANY (iobestiary.cpp używa `tr.get/tr.format`)

---

### 12.4. ŹRÓDŁO: Imbuement System (imbuements.xml) — 18 kategorii, 50+ imbuements

**Plik**: `data/XML/imbuements.xml`

**Struktura**:
```xml
<base id="1" name="Basic" price="5000" ... />
<base id="2" name="Intricate" price="30000" ... />
<base id="3" name="Powerful" price="200000" ... />

<category id="0" name="Elemental Damage" agressive="1" />
<category id="11" name="Skillboost (Axe Fighting)" agressive="1" />

<imbuement name="Scorch" base="1" subgroup=" (Fire)" category="0">
    <attribute key="description" value="Converts 10% of the physical damage to fire damage." />
</imbuement>
```

**Do tłumaczenia**:
- 3 base names: "Basic", "Intricate", "Powerful"
- 18 category names: "Elemental Damage", "Life Leech", "Mana Leech", etc.
- ~50+ imbuement names: "Scorch", "Venom", "Frost", "Electrify", etc.
- ~50+ imbuement descriptions

**Strategia**: Parser C++ szuka tłumaczenia po `id`, podobnie jak items:
```
imbuement.base.1.name = "Basic"
imbuement.category.0.name = "Elemental Damage"
imbuement.scorch.1.name = "Scorch"
imbuement.scorch.1.desc = "Converts 10% of the physical damage to fire damage."
```

**C++ imbuement messages** — JUŻ ZMIGROWANE (sendImbuementResult używa `tr.get`)

---

### 12.5. ŹRÓDŁO: Houses (otservbr-house.xml) — 993 domów

**Plik**: `data-otservbr-global/world/otservbr-house.xml`

```xml
<house name="Castle of the Winds" houseid="2628" ... guildhall="true" />
<house name="Ab'Dendriel Clanhall" houseid="2629" ... />
<house name="Underwood 9" houseid="2630" ... />
```

**Priorytet**: P4 (niski) — nazwy domów są głównie lokacyjne/adresowe.
Wiele to nazwy ulic z numerami ("Underwood 9", "Treetop 13").
Guildhallom i zamkom warto nadać klucze.

**Strategia**: Parser C++ szuka `house.{houseid}.name`, fallback na XML `name=`.
Tylko guildhalle i zamki → tłumaczyć. Reszta → SKIP.

---

### 12.6. ŹRÓDŁO: XML Definitions (outfits, vocations, familiars, groups, channels)

#### Outfits (`data/XML/outfits.xml`) — ~25 base outfitów
```xml
<outfit name="Citizen" looktype="128" enabled="1" unlocked="1" premium="0"/>
<outfit name="Hunter" looktype="129" enabled="1" unlocked="1" premium="0"/>
```
Klucze: `outfit.{looktype}.name`

#### Vocations (`data/XML/vocations.xml`) — 8 vocacji
```xml
<vocation id="1" clientid="3" name="Sorcerer" description="a sorcerer" .../>
```
Klucze: `vocation.{id}.name`, `vocation.{id}.description`

**C++ vocation** — CZĘŚCIOWO zmigrowane (getVocationName w tools.cpp).
Ale `getSkillNameById()` w game.cpp zwraca RAW DB column names (`skill_fist`,
`skill_club`) — to NIE SĄ player-visible, to SQL kolumny. SKIP.

#### Familiars (`data/XML/familiars.xml`) — ~10 familiarów
```xml
<familiar id="1" name="Thundergiant" lookType="1549" .../>
```
Klucze: `familiar.{id}.name`

#### Groups (`data/XML/groups.xml`) — 4 grupy
```xml
<group id="1" name="player" flags="..." maxDepotItems="2000" maxVipEntries="200"/>
<group id="2" name="tutor" ... />
<group id="3" name="senior tutor" ... />
<group id="4" name="gamemaster" ... />
```
Klucze: `group.{id}.name` — niski priorytet, rzadko widoczne graczom.

#### Chat Channels (`data/chatchannels/chatchannels.xml`) — ~10 kanałów
```xml
<channel id="5" name="World Chat" script="worldchat.lua" public="1" />
<channel id="7" name="Help" script="help.lua" public="1" />
<channel id="12" name="Advertising" script="advertising.lua" public="1" />
```
Klucze: `chatchannel.{id}.name` — JUŻ mogą być w chatchannels.json (16 kluczy)

#### Attached Effects (`data/XML/attachedeffects.xml`)
```xml
<effect id="1" name="Outfit - Rainbow" />
```
Klucze: `attachedeffect.{id}.name` — niski priorytet

---

### 12.7. ŹRÓDŁO: Spells (Lua definitions) — 173 zaklęcia

**Pliki**: `data/scripts/spells/attack/*.lua`, `data/scripts/spells/support/*.lua`

```lua
spell:name("Annihilation")
spell:words("exori gran ico")      -- NIE TŁUMACZYĆ (inkantacja)
spell:group("attack")               -- OPCJONALNIE (kategoria)
```

**Status**: `spells.json` ma 1534 kluczy — prawdopodobnie JUŻ ZMIGROWANE.
`spell:words()` to inkantacje — BEZWZGLĘDNIE NIE TŁUMACZYĆ.
`spell:name()` — tłumaczyć (wyświetlane w spell list).
`spell:group()` — opcjonalnie (attack, healing, support).

---

### 12.8. ŹRÓDŁO: OTClient tr() calls — 1462 wywołań w 315 plikach

**Katalog**: `oryginall/otclient/modules/`

**Dystrybucja po modułach** (top 10):
| Moduł | tr() calls |
|---:|---:|
| game_bot | 203 |
| client_options | 99 |
| game_market | 79 |
| game_console | 53 |
| game_interface | 52 |
| game_skills | 43 |
| game_ruleviolation | 40 |
| client_entergame | 40 |
| game_spelllist | 33 |
| game_hotkeys | 32 |

**Mechanizm**: OTClient ma WŁASNĄ funkcję `tr()` (translate).
Przyjmuje string i zwraca tłumaczenie z wewnętrznego systemu.

```lua
-- OTClient pattern:
tr('You are poisoned')
tr('Health: %s / %s')
tr("If you shut down the program, your character might stay in the game.")
```

**Status**: `otclient_modules.json` ma 1987 kluczy — TE TEXTY mogą być
już wyodrębnione. Trzeba sprawdzić czy tr() w OTClient podłącza się
do naszego systemu i18n czy ma własny.

**Strategia**: JEŚLI OTClient ma własny system tłumaczeń i NIE jest
podłączony do naszego backend → SKIP (niech OTClient zarządza swoimi).
JEŚLI podłączony → synchronizować klucze.

---

### 12.9. ŹRÓDŁO: Map Markers (addMapMark) — 38 markerów

**Przykłady**:
```lua
player:addMapMark({ x = 32091, y = 32178, z = 7 }, MAPMARK_GREENNORTH, "North Exit")
player:addMapMark(Position(32823, 31161, 8), 4, "Sewer Problem 1")
```

**Strategia**: Zamienić na klucze i18n:
```lua
player:addMapMark(pos, type, player:getTranslation("npc.lily.marker_north_exit"))
```

Lub dodać `player:addLocalizedMapMark(pos, type, "npc.lily.marker_north_exit")`.

---

### 12.10. ŹRÓDŁO: Loyalty Titles — tytuły lojalnościowe

**Mechanizm**: JUŻ ZMIGROWANY.
C++ używa `getLocalizedLoyaltyTitle()` i prefix `lib.player.loyalty_title_`.
Klucze: `lib.player.loyalty_title_scout`, `lib.player.loyalty_title_veteran` etc.

---

### 12.11. ŹRÓDŁO: Bank Receipts (Hireling system)

**Plik**: `data/npclib/npc_system/bank_system.lua`

```lua
receipt:setAttribute(ITEM_ATTRIBUTE_TEXT, 
    receiptFormat:format(os.date("%d. %b %Y - %H:%M:%S"), 
    info.type, info.amount, info.owner, info.recipient, info.message))
```

**Strategia**: `receiptFormat` powinien być kluczem i18n z placeholderami.
```lua
local receiptFormat = player:getTranslation("lib.bank.receipt_format")
-- EN: "Date: {{}}\nType: {{}}\nAmount: {{}}\nFrom: {{}}\nTo: {{}}\nMessage: {{}}"
```

---

### 12.12. ŹRÓDŁO: Death/Kill Messages (C++) — JUŻ ZMIGROWANE

```cpp
// player.cpp — już używa kluczy:
lostExp << tr.format("cpp.player.death_exp_lost", loc, {std::to_string(expLoss)});
sendTextMessage(MESSAGE_EVENT_ADVANCE, tr.get("cpp.player.death_pvp", loc));
sendTextMessage(MESSAGE_EVENT_ADVANCE, tr.get("cpp.player.death_pve", loc));
```

**Status**: ✅ ZMIGROWANE

---

### 12.13. ŹRÓDŁO: Loot Messages (C++) — JUŻ ZMIGROWANE

```cpp
// creature.cpp — już używa:
std::string lootMessage = tr.format("cpp.creature.loot_of", loc, 
    {std::string(getNameDescription()), corpseContainer->getContentDescription(collorMessage)});
```

**Status**: ✅ ZMIGROWANE

---

### 12.14. ŹRÓDŁO: Item Descriptions/Inspect (C++) — JUŻ ZMIGROWANE

```cpp
// item.cpp — 245 tr.get/tr.format calls!
descriptions.emplace_back(tr.get("cpp.inspect.description", locStr), specialDescription);
descriptions.emplace_back(tr.get("cpp.inspect.capacity", locStr), ...);
descriptions.emplace_back(tr.get("cpp.inspect.charges", locStr), ...);
descriptions.emplace_back(tr.get("cpp.inspect.attack", locStr), ...);
```

**Status**: ✅ ZMIGROWANE (245 callów w item.cpp)

---

### 12.15. ŹRÓDŁO: ReturnValue Messages (C++) — JUŻ ZMIGROWANE

```cpp
// tools.cpp — 178 case statements w getReturnMessageI18nKey():
case RETURNVALUE_NOERROR: return "cpp.returnvalue.no_error";
case RETURNVALUE_NOTBOUGHTINSTORE: return "cpp.returnvalue.not_bought_in_store";
case RETURNVALUE_TOOFARAWAY: return "cpp.returnvalue.too_far_away";
// ...
```

**Status**: ✅ ZMIGROWANE (178 ReturnValue → i18n keys)

---

### 12.16. ŹRÓDŁO: Skill Names (C++) — JUŻ ZMIGROWANE

```cpp
// tools.cpp — getSkillName() z locale:
case SKILL_FIST: return tr.get("cpp.skill.fist_fighting", locStr);
case SKILL_CLUB: return tr.get("cpp.skill.club_fighting", locStr);
case SKILL_SWORD: return tr.get("cpp.skill.sword_fighting", locStr);
// ...
```

**Status**: ✅ ZMIGROWANE

---

### 12.17. ŹRÓDŁO: Pozostałe C++ resztki (2-3 hity)

**tile.cpp** (linia 723) — RAW string:
```cpp
fmt::format("You can only have {} character{} from your account outside of a protection zone.",
    maxOutsizePZ == 1 ? "one" : std::to_string(maxOutsizePZ), maxOutsizePZ > 1 ? "s" : "")
```
→ ZMIENIĆ na `tr.format("cpp.tile.max_outside_pz", loc, {...})`

**item_parse.cpp** (linia 135) — RAW string:
```cpp
itemType.description = fmt::format("A bag with {} slots where you can hold your loots.", pouchLimit);
```
→ ZMIENIĆ na `tr.format("cpp.item_parse.loot_pouch_desc", loc, {std::to_string(pouchLimit)})`

**Status**: ⏳ DO MIGRACJI (PROPOSALS ONLY)

---

### 12.18. ŹRÓDŁO: Book Texts — częściowo zmigrowane

- **17 tekstów** już używa `#i18n:book.*` prefix
- **Pozostałe** — `setAttribute(ITEM_ATTRIBUTE_TEXT, value.text)` przekazuje
  tekst z tablicy, która MOŻE już zawierać `#i18n:` prefix
- `translateBookText()` w C++ obsługuje `#i18n:` prefix automatycznie
- `books.json` ma 1403 kluczy

**Status**: ✅ PRAWIE GOTOWE — ale trzeba sprawdzić czy wszystkie
referencje `setAttribute(ITEM_ATTRIBUTE_TEXT, ...)` używają `#i18n:`.

---

### 12.19. ŹRÓDŁO: Raid Announcements — JUŻ ZMIGROWANE

```xml
<announce delay="1000" type="event" message="raids.darashia.pirates.msg_1" />
```

Raids XML już używa kluczy i18n zamiast raw text.
`raids.json` ma 273 kluczy.

**Status**: ✅ ZMIGROWANE

---

### 12.20. ŹRÓDŁO: Database defaults

```sql
INSERT INTO `account_vipgroups` ... VALUES (NEW.`id`, 'Enemies', 0);
INSERT INTO `account_vipgroups` ... VALUES (NEW.`id`, 'Friends', 0);
INSERT INTO `account_vipgroups` ... VALUES (NEW.`id`, 'Trading Partner', 0);
```

**Strategia**: Nazwy VIP grup są klient-side wyświetlane.
Mogą być tłumaczone w OTClient przy wyświetlaniu (lookup po angielskiej nazwie).
NIE modyfikować SQL — to dane startowe.

**Status**: SKIP (handle w kliencie)

---

### 12.21. ŹRÓDŁO: Config.lua

```lua
serverName = "Tibia 7.4 test"
serverMotd = ""
```

**Status**: SKIP — to per-server konfiguracja, nie tłumaczyć.

---

## 13. KOMPLETNA LISTA MECHANIZMÓW DOSTARCZANIA I18N

### 13.1. Mechanizmy w Lua (serwer → klient)

| # | Metoda | Użycie | Opis |
|---|---|---:|---|
| 1 | `npcSay(key, ...)` | 7,072 | NPC mówi zlokalizowany tekst |
| 2 | `sendLocalizedTextMessage(type, key, args)` | 1,348 | System message z kluczem |
| 3 | `:sayLocalized(key, ...)` | 773 | Creature mówi zlokalizowany tekst |
| 4 | `sendLocalizedMessage(type, key)` | 634 | System message (bez args) |
| 5 | `npcSayMultiple(keys)` | 128 | NPC mówi wiele zdań |
| 6 | `sendLocalizedCancelMessage(key)` | 92 | Cancel message z kluczem |
| 7 | `getTranslation(key)` | 81 | Pobierz tłumaczenie jako string |
| 8 | `i18nTranslate(key, locale)` | 17 | Niskopoziomowe tłumaczenie |
| 9 | `sendHirelingSelectionModal(...)` | 3 | Modal hirelings |

### 13.2. Mechanizmy w C++ (serwer → klient)

| # | Metoda | Opis |
|---|---|---|
| 1 | `tr.get(key, locale)` | Tłumaczenie prostego klucza |
| 2 | `tr.format(key, locale, args)` | Tłumaczenie z placeholderami |
| 3 | `sendLocalizedTextMessage(type, key)` | Protocol: localized message |
| 4 | `sendCreatureLocalizedSay(...)` | Protocol: creature speech z kluczem (opcode 0x99/0xC4) |
| 5 | `sendLocalizedMessageDialog(key)` | Dialog box z kluczem |
| 6 | `sendTextWindow(translateBookText)` | Automatyczne tłumaczenie #i18n: w książkach |
| 7 | `getReturnMessageI18nKey(value)` | ReturnValue → klucz i18n |
| 8 | `getSkillName(id, locale)` | Nazwa skilla z locale |
| 9 | `getLocalizedLoyaltyTitle(title)` | Tytuł lojalnościowy |
| 10 | `Item::getDescriptionLocalized(dist, locale)` | Opis itemu z locale |
| 11 | `Item::getNameDescription(it, item, sub, art, locale)` | Nazwa itemu z locale |
| 12 | `Achievement localized name` (player_achievement.cpp) | Tłumaczenie nazw osiągnięć |
| 13 | `sendImbuementResult(tr.get(...))` | Wynik imbuementu |
| 14 | `sendFYIBox(tr.get(...))` | FYI box z tłumaczeniem |

### 13.3. Mechanizmy specjalne

| # | Mechanizm | Opis |
|---|---|---|
| 1 | `#i18n:` prefix w tekście | Automatycznie rozwiązywany w C++ (`translateBookText`). Używany w książkach, questlog. |
| 2 | Dynamiczny klucz `fmt::format("item.{}.name", id)` | Klucz budowany w runtime z ID. |
| 3 | `i18n::g_keymap()` compact keys | Kompresja kluczy (opcjonalna, config). |
| 4 | Locale per-player `player->getLocale()` | Każdy gracz ma swój język. |
| 5 | OTClient `tr()` function | Osobny system i18n po stronie klienta. |
| 6 | Fallback chain: locale → "en" → raw text | Jeśli brak tłumaczenia → EN → oryginalny tekst. |

---

## 14. PEŁNA MAPA PLIKÓW → KATEGORIE I18N

```
SERWER (C++ src/)
├── game.cpp                → cpp.json (76 tr calls) ✅
├── player.cpp              → cpp.json (67 tr calls) ✅
├── item.cpp                → cpp.json (245 tr calls) ✅
├── creature.cpp            → cpp.json (1 tr call) ✅
├── iobestiary.cpp          → cpp.json ✅
├── io_bosstiary.cpp        → cpp.json ✅
├── tile.cpp                → ⏳ 1 raw string
├── item_parse.cpp          → ⏳ 1 raw string
├── spells.cpp              → server.json ✅
├── chat.cpp                → server.json ✅
├── npc.cpp                 → cpp.json ✅
├── tools.cpp               → cpp.json (skill names, ReturnValue) ✅
├── protocolgame.cpp        → cpp.json (sendCreatureLocalizedSay etc.) ✅
└── protocollogin.cpp       → cpp.json ✅

SERWER LUA (data/, data-otservbr-global/)
├── scripts/npc/*.lua       → npc.json (13,769 keys) ✅ 
├── scripts/quests/*.lua    → scripts.json + quests.json ✅
├── scripts/actions/*.lua   → actions.json ✅
├── scripts/talkactions/*.lua → talkactions.json ✅
├── scripts/globalevents/*.lua → globalevents.json ✅
├── scripts/creaturescripts/*.lua → creaturescripts.json ✅
├── scripts/movements/*.lua → movements.json ✅
├── lib/core/quests.lua     → questlog.json ⏳ (503 questy do rozszerzenia)
├── lib/npc/i18n.lua        → (infrastruktura, nie tłumaczyć)
├── libs/systems/hireling.lua → libs.json ✅
├── libs/systems/exaltation_forge.lua → libs.json ✅
├── libs/functions/boss_lever.lua → libs.json ✅
├── modules/scripts/gamestore/gamestore.lua → ⏳ NOWA KATEGORIA: store.json
├── scripts/lib/register_achievements.lua → achievements.json ✅
├── scripts/systems/bestiary_charms.lua → ⏳ charms.json (26 charms)
├── scripts/lib/shops.lua   → (item names → items.json) ✅
├── monster/*.lua (1637)    → monsters.json ✅
│   └── monster.Bestiary.class/Locations → ⏳ bestiary.json
└── startup/others/functions.lua → ✅ (używa #i18n: prefix)

DANE XML (data/XML/, data/, data-otservbr-global/)
├── items.xml (16,693)      → items.json ✅
├── mounts.xml              → mounts.json ⏳ (0 kluczy — wyodrębnić!)
├── outfits.xml             → ⏳ outfits.json
├── vocations.xml           → ⏳ vocations.json
├── familiars.xml           → ⏳ familiars.json
├── groups.xml              → ⏳ groups.json (P4)
├── chatchannels.xml        → chatchannels.json (16 kluczy, sprawdzić)
├── attachedeffects.xml     → ⏳ attachedeffects.json (P4)
├── events.xml              → events.json (14 kluczy, rozszerzyć?)
├── imbuements.xml          → ⏳ imbuements.json
└── raids/*.xml             → raids.json ✅

WORLD DATA
├── otservbr-house.xml (993)→ ⏳ houses.json (P4)
└── towns (in OTBM binary) → SKIP (binary format)

OTCLIENT (oryginall/otclient/)
├── modules/ (315 .lua files, 1462 tr() calls) → otclient_modules.json ✅
├── src/ (C++ client)       → otclient_src.json ⏳
└── data/                   → otclient_data.json ✅

WWW (PHP/Twig)
├── *.php (2779 plików, 53K hitów) → php.json ⏳ (po filtracji ~5-8K)
└── *.twig templates        → html.json ✅ (1495 kluczy)

DATABASE
└── schema.sql defaults     → SKIP (handle w kliencie)
```

---

## 15. ROZSZERZONA KOLEJNOŚĆ MIGRACJI (ZAKTUALIZOWANA)

### Faza 0 — "Verification" (zanim zaczniemy)
- [ ] Sprawdzić czy mounts.json jest PUSTY (0 kluczy!) — wyodrębnić z mounts.xml
- [ ] Sprawdzić czy outfits/vocations/familiars mają klucze → jeśli nie, wyodrębnić
- [ ] Sprawdzić 2-3 C++ resztki (tile.cpp, item_parse.cpp) → PROPOSALS
- [ ] Sprawdzić kompletność books (17 #i18n vs ile jest książek w grze)

### Faza 1 — "Quick Data Extraction" (1-2 dni)
| Co | Ilość | Opis |
|---|---:|---|
| mounts.xml → mounts.json | ~50 | Wyodrębnij nazwy mountów po ID |
| outfits.xml → outfits.json | ~25 | Wyodrębnij nazwy outfitów po looktype |
| vocations.xml → vocations.json | ~16 | Nazwy + opisy vocacji |
| familiars.xml → familiars.json | ~10 | Nazwy familiarów |
| imbuements.xml → imbuements.json | ~80 | Nazwy + opisy + kategorie |
| bestiary charms → charms.json | ~52 | 26 nazw + 26 opisów |
| bestiary classes → bestiary.json | ~60 | ~30 klas + ~30 lokacji |

### Faza 2 — "Quest Log Expansion" (3-5 dni)
| Co | Ilość | Opis |
|---|---:|---|
| quests.lua names → questlog.json | ~505 | Nazwy questów |
| quests.lua mission names | ~1950 | Nazwy misji |
| quests.lua descriptions (static) | ~1000 | Proste opisy |
| quests.lua descriptions (dynamic) | ~500 | Funkcje → klucze wewnątrz |

### Faza 3 — "GameStore" (2-3 dni)
| Co | Ilość | Opis |
|---|---:|---|
| store categories → store.json | ~50 | Nazwy kategorii |
| store offer names → store.json | ~700 | Nazwy ofert |
| store descriptions → store.json | ~200 | Opisy (uwaga: HTML!) |

### Faza 4 — "Map & World Data" (1-2 dni)
| Co | Ilość | Opis |
|---|---:|---|
| map markers → markers.json | ~38 | Opisy markerów |
| house names (guildhalls) | ~50 | Tylko guildhalle i zamki |
| groups.xml → groups.json | 4 | Nazwy grup |
| attachedeffects → effects.json | ~5 | Nazwy efektów |

### Faza 5 — "C++ Proposals" (1-2 dni)
| Co | Ilość | Opis |
|---|---:|---|
| tile.cpp PZ message | 1 | PROPOSAL ONLY |
| item_parse.cpp loot pouch | 1 | PROPOSAL ONLY |
| Inne znalezione resztki | ? | PROPOSAL ONLY |

### Faza 6 — "OTClient sync" (jeśli potrzeba)
Sprawdzić czy OTClient tr() system podłącza się do naszego backend i18n.

### Faza 7 — "WWW PHP full" (długoterminowe)
Pełna migracja PHP po filtracji (5-8K hitów).

---

## 16. WZORCE ZASTOSOWANIA KLUCZY — KOMPLETNA LISTA

### 16.1. Wzorzec NPC (Lua → Protocol → Klient)

```
[Lua Script] npcSay("npc.rook_guard.greeting", "|PLAYERNAME|", ...)
    ↓
[C++ NPC::luaNpcSay] → sendCreatureLocalizedSay(creature, type, key, fallback, args)
    ↓
[Protocol 0x99/0xC4] → opcode + key + args
    ↓
[OTClient] → lookup key in local i18n JSON → display translated text
```

### 16.2. Wzorzec System Message (Lua → Protocol → Klient)

```
[Lua Script] player:sendLocalizedTextMessage(MESSAGE_TYPE, "key", {arg1, arg2})
    ↓
[C++ Player::sendLocalizedTextMessage] → client->sendTextMessage(TextMessage(type, translatedText))
    ↓
[Protocol 0xB4] → opcode + type + translated text  
    ↓
[OTClient] → display text in console/game window
```

### 16.3. Wzorzec Item Name (XML → C++ Parser → Protocol)

```
[items.xml] name="magic plate armor"
    ↓
[C++ ItemType parser] → loads name into ItemType.name
    ↓
[C++ Item::getNameDescription()] → lookup "item.{id}.name" in i18n → fallback to ItemType.name
    ↓
[Protocol] → sends translated name to client
```

### 16.4. Wzorzec Book/Letter (#i18n: prefix)

```
[Lua Script] item:setAttribute(ITEM_ATTRIBUTE_TEXT, "#i18n:book.quest.note")
    ↓
[C++ sendTextWindow] → translateBookText(originalText)
    ↓
[translateBookText] → detects #i18n: prefix → lookup "book.quest.note" → returns translated text  
    ↓
[Protocol 0x96] → sends translated book content
```

### 16.5. Wzorzec Quest Log (#i18n: prefix)

```
[quests.lua] name = "#i18n:questlog.banshee.name"
    ↓  
[Lua quests.lua] → resolveQuestlogMarker(player, text)
    ↓
[resolveQuestlogMarker] → detects #i18n: → translateQuestlogKey() → i18nTranslate(key, locale)
    ↓
[Protocol] → sends translated quest name/description
```

### 16.6. Wzorzec Raid Announce (XML → C++)

```
[raids/*.xml] message="raids.darashia.pirates.msg_1"
    ↓
[C++ Raids::processAnnouncement] → lookup key in i18n → broadcast to all players
```

### 16.7. Wzorzec Achievement (C++)

```
[C++] player->sendLocalized... → tr.get("cpp.achievement.unlocked", loc) + achievement name
    ↓
[player_achievement.cpp] → std::string localizedName = tr.get(achievementKey, loc)
    ↓
[Protocol] → sends localized achievement notification
```

### 16.8. Wzorzec Condition/Status (C++)

```
[C++ condition.cpp] → auto &tr = i18n::g_translator()
    ↓
[tr.format] → "cpp.condition.regenerating" → translated status text
```

### 16.9. Wzorzec GameStore (Lua → Protocol)

```
[gamestore.lua] name = "Consumables", description = "..."
    ↓
[C++ ProtocolGame::sendShop] → currently sends raw text
    ↓
MIGRATION NEEDED: 
    name = i18n::t("store.category.consumables")
    → Lua resolves key → sends translated to protocol
```

### 16.10. Wzorzec XML Data (C++ Parser Lookup)

```
[mounts.xml] name="Widow Queen" id="1"
    ↓
[C++ Mount parser] → loads name into mount struct
    ↓
[Requested by client] → lookup "mount.1.name" in i18n → fallback to XML name
    ↓
[Protocol] → sends translated mount name
```

---

## 17. EDGE CASES I PUŁAPKI

### 17.1. Tekst z dynamicznym plural/gender

```lua
-- EN: "1 item" / "5 items"
-- PL: "1 przedmiot" / "2 przedmioty" / "5 przedmiotów" (3 formy!)
```

**Rekomendacja na teraz**: Użyj `(s)` w EN i pozwól tłumaczowi zdecydować.
W przyszłości: ICU MessageFormat dla pełnej pluralizacji.

### 17.2. Tekst ze zmienną na początku

```lua
player:getName() .. " has joined the party."
-- NIE rozbijać! Jeden klucz:
-- EN: "{{}} has joined the party."
```

### 17.3. Tekst z HTML entities

```lua
"&#8226; +10% experience rate\n"
-- Zachowaj HTML entities w kluczu:
-- EN: "&#8226; +{{}}% experience rate"
```

### 17.4. Wieloliniowy tekst z \z (Lua continuation)

```lua
"long text \z
 continued here"
-- → jeden klucz, usunąć \z, połączyć w jedną linię
```

### 17.5. os.date format strings

```lua
os.date("%B %d, %Y.")
-- %B, %d, %Y to parametry strftime — NIE TŁUMACZYĆ argumentów.
-- ALE format (kolejność) → klucz i18n:
-- EN: "%B %d, %Y" / PL: "%d %B %Y"
```

### 17.6. Tekst używany jako identyfikator

```lua
-- UWAGA! Niektóre "teksty" to identyfikatory wewnętrzne:
player:setStorageValue(Storage.Quest.QuestName, 1)
Game.createMonsterType("Demon")  -- nazwa monstera = identyfikator!
```
**Zasada**: `Game.createMonsterType("X")` — NIE TŁUMACZYĆ argument.
Parser szuka tłumaczenia po nazwie runtime.

### 17.7. Condition message z wartością liczbową

```cpp
// condition.cpp:
auto &tr = i18n::g_translator();
// Tekst z warunkami regeneracji — musi obsługiwać placeholder liczbowy
```

### 17.8. Texty w tablicach (items/shop lists)

```lua
{ itemName = "brown mushroom", clientId = 3725, buy = 10 }
```
`itemName` to lookup do items.json — NIE tłumaczyć bezpośrednio w tablicy.
Parser items rozwiązuje tłumaczenie przy wyświetlaniu na kliencie.

---

## 18. WALIDACJA KOMPLETNOŚCI

### Checklist: Czy pokryte WSZYSTKIE ścieżki tekstu gracz-visible?

- [x] NPC dialogi (7072 npcSay) ✅
- [x] System messages (1348 sendLocalizedTextMessage) ✅
- [x] Creature speech (773 sayLocalized) ✅
- [x] Cancel messages (92 sendLocalizedCancelMessage) ✅
- [x] Item names (17057 items.json) ✅
- [x] Item descriptions/inspect (245 tr calls in item.cpp) ✅
- [x] Monster names (5915 monsters.json) ✅
- [x] Spell names (1534 spells.json) ✅
- [x] Achievement names+desc (1048 achievements.json) ✅
- [x] Quest log names+desc (1918 questlog.json) ✅ (rozszerzyć o quests.lua)
- [x] Book/scroll/letter text (1403 books.json) ✅
- [x] Raid announcements (273 raids.json) ✅
- [x] Skill names (getSkillName with locale) ✅
- [x] ReturnValue messages (178 keys, getReturnMessageI18nKey) ✅
- [x] Loyalty titles (getLocalizedLoyaltyTitle) ✅
- [x] Death/exp messages ✅
- [x] Loot messages ✅
- [x] Bestiary charm messages (C++ iobestiary) ✅
- [x] Imbuement result messages (C++ sendImbuementResult) ✅
- [x] FYI boxes ✅
- [x] Boss lever messages ✅
- [x] Hireling messages ✅
- [x] OTClient UI (1987 otclient_modules.json) ✅
- [x] HTML/PHP www (1495+59 html/php json) ✅
- [ ] Mount names → ⏳ mounts.json (0 kluczy!)
- [ ] Outfit names → ⏳ do wyodrębnienia
- [ ] Vocation names+desc → ⏳ do wyodrębnienia
- [ ] Familiar names → ⏳ do wyodrębnienia
- [ ] Imbuement names+desc (XML) → ⏳ do wyodrębnienia
- [ ] Bestiary classes+locations → ⏳ do wyodrębnienia
- [ ] Bestiary charm names+desc (Lua data) → ⏳ do wyodrębnienia
- [ ] GameStore categories+offers → ⏳ ~760 elementów
- [ ] Quest names/missions (quests.lua) → ⏳ ~2400 elementów
- [ ] Map markers → ⏳ ~38 elementów
- [ ] C++ resztki (tile.cpp, item_parse.cpp) → ⏳ 2-3 PROPOSALS
- [ ] House names (guildhalls) → P4
- [ ] Group names → P4
- [ ] Chat channel names → sprawdzić kompletność
- [ ] Attached effects → P4
- [ ] Bank receipt format → P3
- [ ] Event names/descriptions → sprawdzić kompletność
- [ ] OTClient C++ src → P3

**ŁĄCZNA SZACOWANA ILOŚĆ POZOSTAŁEJ PRACY**: ~3,500-4,000 nowych kluczy

---

## 19. DODATKOWE NIEZMIGROWANE WZORCE (DEEP SCAN)

### 19.1. ModalWindow — buttons i choices z raw text

**Pliki** (5 użyć ModalWindow):
- `data/scripts/talkactions/player/reward.lua` — `addButton("Select")`, `addButton("Close")`
- `data/scripts/talkactions/gm/teleport_to_player.lua` — `addButton("Select")`, `addButton("Close")`
- `data/libs/systems/hireling.lua` — `addButton("Select")`, `addButton("Cancel")`
- `data/libs/functions/player.lua` — `showInfoModal()`, `showConfirmationModal()`

**Status**: `showInfoModal` i `showConfirmationModal` JUŻ UŻYWAJĄ `getTranslationOrFallback()`.
Ale `reward.lua` i `teleport_to_player.lua` mają hardcoded `"Select"`/`"Close"`.
`hireling.lua` ma hardcoded `"Select"`/`"Cancel"`.

**Strategia**:
```lua
-- PRZED:
window:addButton("Select")
window:addButton("Close")
-- PO:
local locale = player:getLocale()
window:addButton(i18nTranslate("lib.modal.button_select", locale))
window:addButton(i18nTranslate("lib.modal.button_close", locale))
```

**Ilość**: ~6 raw button labels, 4 unikalne: "Select", "Close", "Cancel", "Ok"
**Priorytet**: P2

---

### 19.2. Webhook Messages — wewnętrzne Discord/admin

**Pliki** (18 wywołań):
- `data/scripts/talkactions/gm/ban.lua`
- `data/scripts/talkactions/gm/kick.lua`
- `data/scripts/talkactions/gm/unban.lua`
- `data/scripts/talkactions/gm/namelock.lua`
- `data/scripts/talkactions/gm/push_town.lua`
- `data/scripts/globalevents/global_server_save.lua`
- `data-otservbr-global/scripts/globalevents/spawn/rashid.lua`
- `data-otservbr-global/scripts/world_changes/fury_gates.lua`
- `data-otservbr-global/scripts/world_changes/nightmare_isles.lua`

**Strategia**: Webhook messages to wiadomości ADMINA (Discord), NIE SĄ player-visible.
**Priorytet**: SKIP — nie tłumaczyć. Webhooks zawsze EN (admin channel).

---

### 19.3. setAttribute z raw text (3 hity)

**Pliki**:
1. `data/scripts/runes/magic_wall.lua:25` — `"Casted by: %s"` → description rune walls
2. `data/scripts/runes/wild_growth.lua:25` — `"Casted by: %s"` → description wild growth
3. `data-otservbr-global/scripts/actions/other/construction_kits.lua:128` — `"Unwrap it in your own house to create a <...>."`

**Strategia**:
```lua
-- PRZED:
item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, string.format("Casted by: %s", creature:getName()))
-- PO:
item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 
    string.format(player:getTranslation("scripts.rune.casted_by"), creature:getName()))
```

**Ilość**: 3 instancje
**Priorytet**: P2

---

### 19.4. doCreatureSayWithRadius z raw text (1 hit)

**Plik**: `data-otservbr-global/scripts/quests/raging_mage_tower/creaturescripts_energized_raging_mage_kill.lua`
```lua
doCreatureSayWithRadius(creature, "GNAAAAAHRRRG!! WHAT? WHAT DID YOU DO TO ME!! I... I feel the energies crawling away... from me... DIE!!!", TALKTYPE_MONSTER_SAY, 35, 71)
```

**Strategia**: Dodać wersję zlokalizowaną `doCreatureSayWithRadiusLocalized()` lub zamienić na `creature:sayLocalized()` z większym radiusem jeśli API na to pozwala.
**Priorytet**: P3 (flavour text monstera)

---

### 19.5. creature:say z raw text (1 hit)

**Plik**: `data/libs/functions/lever.lua:93`
```lua
creature:say('YUP!!', TALKTYPE_MONSTER_SAY)
```

**Strategia**: Debug/test code — można zamienić na klucz lub zostawić (nie jest to poważny tekst).
**Priorytet**: P4

---

### 19.6. OTClient tr() System — analiza

**Odkrycie**: OTClient `_G.tr()` (zdefiniowany w `corelib/util.lua`) MA WŁASNY system tłumaczeń: 
```lua
function _G.tr(text, ...)
  if currentLocale then
    local translation = currentLocale.translation[text]
    if not translation then
      translation = text  -- fallback to raw text
    end
    return string.format(translation, ...)
  end
  return text
end
```

**Mechanizm**: OTClient ładuje pliki z `modules/client_locales/locales/` (np. `locale-pl.lua`, `locale-es.lua`) zawierające tablice translation.

**Relacja z naszym systemem**: OTClient ma NIEZALEŻNY system i18n od serwera.
Serwer tłumaczy per-player na serwerze, OTClient tłumaczy UI client-side.

**Wnioski**:
1. OTClient UI strings (`tr("Select")`, `tr("Cancel")`, `tr("Health: %s / %s")`) — tłumaczone LOKALNIE przez klienta
2. Serwer → Klient messages (NPC dialogi, system messages) — tłumaczone NA SERWERZE i wysyłane jako przetłumaczony tekst lub klucz+args
3. Te dwa systemy NIE kolidują — każdy odpowiada za swoje
4. Nasza migracja dotyczy SERWERA. OTClient trzeba synchronizować OSOBNO.

**Status**: `otclient_modules.json` (1987 kluczy) to nasz GENERATOR kluczy do plików locale OTClient.
Trzeba dodać pipeline: `i18n/en/otclient_modules.json` → `modules/client_locales/locales/locale-{lang}.lua`

---

### 19.7. Game.broadcastMessage — analiza

**Odkrycie**: `Game.broadcastMessage()` w `data/libs/functions/game.lua` wywołuje `player:sendTextMessage()` w pętli. JUŻ ZASTĄPIONE przez `Game.broadcastLocalizedMessageLua()` wszędzie gdzie potrzeba. Stara funkcja pozostaje jako compat.

**Status**: ✅ ZMIGROWANE (Game.broadcastLocalizedMessageLua)

---

### 19.8. Spell ORIGIN_SPELL z nazwy (1 hit)

**Plik**: `data/scripts/spells/healing/mass_healing.lua:14`
```lua
doTargetCombatHealth(creature, target, COMBAT_HEALING, min, max, CONST_ME_NONE, ORIGIN_SPELL, "Mass Healing")
```

**Analiza**: Ostatni argument to IDENTYFIKATOR zaklęcia w systemie combat, używany do trackingu source of damage/healing. NIE jest player-visible text.
**Status**: SKIP (internal identifier, not displayed)

---

### 19.9. setDescription w talkactions (3 hity)

**Pliki**:
- `data/scripts/talkactions/god/icons_functions.lua` — opisy komend GM
- `data/scripts/talkactions/god/inbox_command.lua` — opis komendy GM
- `data/scripts/talkactions/player/commands.lua` — opis komendy !commands

**Analiza**: To opisy widoczne w `!commands` list. Mogą być tłumaczone.
```lua
-- PRZED:
commands:setDescription("[Usage]: !commands to see each command with its description")
-- PO:
commands:setDescription(i18nTranslate("talkactions.commands.description", "en"))
```

**Priorytet**: P3 (GM/admin commands głównie)

---

### 19.10. World Changes z raw string.format (2 hity)

**Pliki**:
- `data-otservbr-global/scripts/world_changes/fury_gates.lua:32` — `"Fury Gate will be active in %s today"` (webhook only!)
- `data-otservbr-global/scripts/world_changes/nightmare_isles.lua:24` — `"Nightmare Isle will be active %s today"` (webhook only!)
- `data-otservbr-global/scripts/globalevents/spawn/rashid.lua:28` — `"Rashid arrived at %s today."` (webhook)

**Status**: SKIP — to webhooks (admin Discord), nie player-visible.

---

### 19.11. Server Info Talkaction

**Plik**: `data/scripts/talkactions/player/server_info.lua`
Sprawdzić czy generuje tekst z raw strings.

**Priorytet**: P2 (jeśli zawiera player-visible raw text)

---

## 20. KOMPLETNA MATRYCA MIGRACJI — FINALNA

### ✅ PEŁNI ZMIGROWANE (nie wymagają dalszej pracy):

| System | Mechanizm | Kluczy |
|---|---|---:|
| NPC dialogi | npcSay(), :sayLocalized() | 13,769 |
| C++ sendTextMessage | tr.get(), tr.format() | ~2,000 |
| C++ sendCancelMessage | tr.get() | ~500 |
| ReturnValue messages | getReturnMessageI18nKey() | 178 |
| Skill names | getSkillName(locale) | ~15 |
| Loyalty titles | getLocalizedLoyaltyTitle() | ~20 |
| Bestiary C++ | tr.get/tr.format in iobestiary.cpp | ~50 |
| Bosstiary C++ | tr.get/tr.format in io_bosstiary.cpp | ~30 |
| Forge system | sendLocalizedTextMessage | ~50 |
| Boss Lever | sendLocalizedTextMessage | ~20 |
| Hireling system | sendLocalizedTextMessage | ~30 |
| Raid announcements | i18n keys in XML | 273 |
| Death messages | tr.format in player.cpp | ~10 |
| Loot messages | tr.format in creature.cpp | ~5 |
| Item inspect | tr.get/tr.format in item.cpp | ~245 |
| Broadcast messages | broadcastLocalizedMessageLua | ~10 |
| Server save | broadcastLocalizedMessageLua | ~5 |
| Online record | broadcastLocalizedMessageLua | ~2 |
| Book system | #i18n: prefix + translateBookText | 1,403 |
| Achievement system | i18n lookup | 1,048 |
| Quest log | #i18n: prefix | 1,918 |
| Spell names | spells.json | 1,534 |
| Monster names | monsters.json | 5,915 |
| Item names | items.json | 17,057 |
| OTClient modules | tr() wrapper | 1,987 |
| HTML/PHP | html.json + php.json | 1,554 |
| ModalWindow helper | getTranslationOrFallback | ~6 |

### ⏳ DO MIGRACJI (work remaining):

| System | Typ pracy | Szacowane klucze |
|---|---|---:|
| Quest system (quests.lua) | Wyodrębnij nazwy+opisy, dynamiczne desc | ~2,400 |
| GameStore | Wyodrębnij kategorie+oferty+opisy | ~1,000 |
| Mounts (XML) | Wyodrębnij nazwy po ID | ~50 |
| Outfits (XML) | Wyodrębnij nazwy po looktype | ~25 |
| Vocations (XML) | Wyodrębnij nazwy+opisy | ~16 |
| Familiars (XML) | Wyodrębnij nazwy po ID | ~10 |
| Imbuements (XML) | Wyodrębnij nazwy+opisy+kategorie | ~80 |
| Bestiary charms (Lua) | Wyodrębnij nazwy+opisy | ~52 |
| Bestiary classes (Lua) | Wyodrębnij klasy+lokacje | ~60 |
| Houses (XML) | Wyodrębnij nazwy guildhalls | ~50 |
| Map markers (Lua) | Zamień raw text | ~38 |
| Chat channels (XML) | Sprawdź kompletność | ~10 |
| Groups (XML) | Wyodrębnij nazwy | 4 |
| ModalWindow buttons | Zamień "Select"/"Close"/"Cancel" | ~6 |
| setAttribute raw | Zamień raw descriptions | 3 |
| C++ tile.cpp | PROPOSAL: PZ message | 1 |
| C++ item_parse.cpp | PROPOSAL: loot pouch desc | 1 |
| Talkaction descriptions | Zamień raw setDescription | ~5 |
| doCreatureSayRadius | Zamień raw text | 1 |
| Bank receipt format | Zamień receiptFormat | 1 |
| OTClient ↔ i18n sync | Pipeline JSON → locale-{lang}.lua | (infra) |

### SKIP (nie tłumaczyć):

| System | Powód |
|---|---|
| Config.lua (serverName, MOTD) | Per-server konfiguracja |
| Webhook messages (18x) | Discord admin-only, nie player-visible |
| Database VIP group defaults | Handle client-side |
| spell:words() inkantacje | Formulas, nie natural language |
| Monster type identifiers | Internal identifiers |
| SQL column names (skill_fist) | Database schema |
| Town names as constants | Internal identifiers (tłumaczenie opcjonalne P4) |
| g_logger() / debug text | Developer-only logs |
| creature:say('YUP!!') | Test/debug code |
| ORIGIN_SPELL name | Internal combat tracker |

---

## 21. PODSUMOWANIE PLANU MIGRACJI

### Statystyki finalne:
- **Zmigrowane**: 53,586 kluczy EN w 37 plikach JSON
- **Do zmigrowania**: ~3,800 nowych kluczy
- **Do pominięcia (SKIP)**: ~30+ instancji (webhooks, config, debug)
- **PROPOSALS C++ (wymagają rekompilacji)**: 2-3 zmiany

### Priorytetyzacja Faz:

| Faza | Opis | Szacowany czas | Kluczy |
|---|---|---|---:|
| 0 | Weryfikacja + uzupełnienie pustaków (mounts, outfits, vocations, familiars) | 1 dzień | ~100 |
| 1 | XML Data Extraction (imbuements, charms, bestiary, channels) | 1-2 dni | ~200 |
| 2 | Quest System (quests.lua — nazwy, misje, opisy) | 3-5 dni | ~2,400 |
| 3 | GameStore (kategorie, oferty, opisy) | 2-3 dni | ~1,000 |
| 4 | Misc Lua (map markers, setAttribute, modal buttons, talkactions) | 1 dzień | ~50 |
| 5 | C++ Proposals (tile.cpp, item_parse.cpp) | 1 dzień | 2-3 |
| 6 | OTClient Sync Pipeline | 1-2 dni | (infra) |
| 7 | PHP Full Migration | TBD | TBD |
| **TOTAL** | | **~10-15 dni** | **~3,800** |

### Zasady pracy workera:
1. ZAWSZE rób backup (`git stash` lub `cp`) przed modyfikacją
2. PO każdej modyfikacji: waliduj JSON (`python3 -c "import json; json.load(open(f))"`)
3. COMMIT natychmiast po udanej zmianie (~co 5-10 plików)
4. NIGDY nie modyfikuj C++ bez PROPOSAL (oznaczony komentarzem `// i18n-proposal:`)
5. Dynamiczne opisy questów (funkcje Lua) — modyfikuj WEWNĄTRZ funkcji, zamień zwracane stringi na klucze
6. GameStore opisy z HTML — zachowaj `&#8226;` i inne entities
7. OTClient → osobny pipeline (nie mieszać z serwerem)
8. Webhooks → SKIP (nie player-visible)
9. TESTUJ po każdej fazie: `./canary --dry-run` jeśli dostępne

---

## 22. MAPA PLIKÓW STATUSU I TRACKINGU (KOMPLETNA)

### 22.0. Cel tej sekcji
Każdy plik statusowy workera jest tu wymieniony z DOKŁADNĄ ścieżką, formatem danych,
informacją kto go zapisuje/czyta (skrypt/funkcja), kiedy, i co zawiera.
Dzięki temu można szukać pliku po nazwie i sprawdzić czy dane się zgadzają.

> **Konwencja ścieżek**:
> - Ścieżki ROOT = `./` (katalog roboczy repozytorium, `canary_test/`)
> - Ścieżki STATUS = `i18n/status/` (podkatalog `$STATUS_DIR`)
> - `{lang}` = kod języka ISO (pl, es, de, fr, …)
> - `{category}` = nazwa kategorii zasobów (npc, monsters, quests, items, …)
> - `{YYYY-MM-DD}` = data w formacie ISO

---

### 22.1. PLIKI KORZENIOWE (ROOT)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| R1 | `i18n_global_stats.json` | JSON | `i18n_worker_simple.sh` (inline heredoc python w `end_of_cycle`) | `I18N_STATUS.md` generator (linia 1462), `build-worker-state` | Master stats: `total_cycles`, `mode`, `category`, `last_update`, `migration{}`, `translation_sync{}`, `auto_translate{}`, `idle{}`, `pre_migration{}`, `documentation{}`, `extraction{}`, `pre_migration_categories{}` (28 kat.), `pre_migration_totals{}` |
| R2 | `i18n_file_status.json` | JSON | `i18n_worker_simple.sh` (func `update_file_status`, linia ~879) | STATUS generator (linia 1441, 1575) | Per-file stage tracking: `files.{path}.stages.{N_name}.status`, `.overall_status`, `.completed_at`, `.category` |
| R3 | `i18n_processed_files.txt` | TXT | Worker (każda przetworzona ścieżka — append) | STATUS generator (linia 1441) | Flat list per-line: ścieżka pliku przetworzonego. ~400KB |
| R4 | `i18n_progress_baseline.json` | JSON | Ręcznie / jednorazowo | Worker idle/comparison | Snapshot bazowy: `{total_keys, translated_keys, timestamp}` |
| R5 | `i18n_status_pusher.sh` | BASH | — (skrypt) | Ręcznie / cron | `git add I18N_STATUS.md && git commit && git push` do master |
| R6 | `I18N_STATUS.md` | Markdown | `i18n_worker_simple.sh` (inline Python, linia ~1190-2550) | Użytkownik, GitHub | Raport ludzko-czytelny: statystyki, postęp, KPI, jakość, per-język |

---

### 22.2. PLIKI LIVE / HEARTBEAT

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Aktualizacja | Opis |
|---|---|---|---|---|---|---|
| L1 | `i18n/status/activity.json` | JSON | `status_update_activity()` → `tools/i18n_status.py update-activity` | statusd, guardian, UI | **Co kilka sekund** (LIVE) | `{category, cycle, eta_seconds, file, generated_at_utc, message, phase, progress:{done,total,unit}, recent:[{action,category,cycle,file,phase,result,stage,t}×10], stage, status}` |
| L2 | `i18n/status/worker_state.json` | JSON | `tools/i18n_status.py build-worker-state` (end_of_cycle) | statusd, STATUS generator | **Co cykl** | Per-category state: `{schema_version, built_at_utc, categories.{cat}.{status, backoff:{consecutive_zeros,skip_until_utc}, last:{delta:{files_migrated}, updated_at_utc}}}` |

---

### 22.3. LOGI (APPEND-ONLY JSONL)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| J1 | `i18n/status/ops.jsonl` | JSONL | `status_log_op()` → `tools/i18n_status.py log-op` | `build-daily`, STATUS | Każda operacja: `{t, cycle, phase, stage, category, file, result, detail, keys_added, files_changed, mapped_new, translated, skipped}` |
| J2 | `i18n/status/errors.jsonl` | JSONL | `status_log_error()` → `tools/i18n_status.py log-error` | `build-daily`, STATUS | Każdy błąd: `{t, cycle, phase, stage, category, file, error, action}` — ~586KB |
| J3 | `i18n/status/worker_cycle_perf.jsonl` | JSONL | Worker (cycle profiling) | STATUS generator (linia 2283) | Per-cycle performance: `{timestamp, cycle, mode, category, events:{dispatch:N}}` |
| J4 | `i18n/status/worker_cycle_perf_latest.json` | JSON | Worker | STATUS generator (linia 2203) | Najnowszy wpis z J3: `{timestamp, cycle, mode, category, events}` |
| J5 | `i18n/status/suspicious_log.jsonl` | JSONL | Worker (guard) | STATUS generator (linia 2291) | Podejrzane tłumaczenia (flagged): `{t, lang, key, original, translated, reason}` |
| J6 | `i18n/status/suspicious_rejected.jsonl` | JSONL | Worker (guard reject) | — | Odrzucone tłumaczenia |
| J7 | `i18n/status/transition_log.jsonl` | JSONL | Worker (mode switch) | — | Przejścia między trybami: `{t, from_mode, to_mode, reason}` |
| J8 | `i18n/status/lang_sequence.log` | TXT | Worker | — | Sekwencja języków w fazie AUTO_TRANSLATE |

---

### 22.4. PLIKI PRE-MIGRATION (Skan źródeł)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| PM1 | `i18n/status/pre_migration_scan.json` | JSON | `tools/i18n_pre_migration_scan.py` | Worker, STATUS | Master wynik skanu: `{category}.{needs_migration, hits, files_with_hits, total_files_scanned, scanned_at}` — 28 kategorii |
| PM2 | `i18n/status/pre_migration_todo/{category}.json` | JSON | `tools/i18n_pre_migration_scan.py` | Worker (migration mode) | Per-category todo: lista plików+trafień do zmigrowania |
| PM3 | `i18n/status/pre_migration_todo/{category}.md` | Markdown | `tools/i18n_pre_migration_scan.py` | Użytkownik (do przeglądu) | Ludzko-czytelna wersja PM2 |
| PM4 | `i18n/status/pre_migration_todo/{category}.csv` | CSV | `tools/i18n_pre_migration_scan.py` | Excel / narzędzia | CSV wersja PM2 |
| PM5 | `i18n/status/pre_migration_todo/pre_migration_todo_latest.json` | JSON | `tools/i18n_pre_migration_scan.py` | Worker, STATUS | Podsumowanie: `{generated_at_utc, scope, categories_scanned, total_files_scanned, files_with_hits, hits, categories:{cat:{json_file, md_file, csv_file}}, entries_preview:[]}` |
| PM6 | `i18n/status/pre_migration_todo/pre_migration_todo_history.jsonl` | JSONL | `tools/i18n_pre_migration_scan.py` | — (audit trail) | Historia skanów (append-only) |
| PM7 | `i18n/status/pre_migration_todo/pre_migration_todo.csv` | CSV | `tools/i18n_pre_migration_scan.py` | Excel | Zbiorczy CSV ze wszystkich kategorii |

> **Uwaga**: Katalog `pre_migration_todo/` zawiera **99 plików** (33 kategorii × 3 formaty) |

---

### 22.5. PLIKI TŁUMACZEŃ

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| T1 | `i18n/status/translation_global_overview.json` | JSON | Worker (phase report) | STATUS | **1773 linii**: `{global:{total_reference_keys, translated_keys, completion_pct}, migration:{files_total, total_keys_extracted}, scope_totals:{server_keys, client_keys}, per_file_drift:[{file, live, registry, drift, drift_pct}×37]}` |
| T2 | `i18n/status/translation_guard_latest.json` | JSON | Worker (guard) | STATUS (linia 2189) | Najnowszy guard report: `{timestamp, total_checked, blocked, passed, block_rate}` |
| T3 | `i18n/status/translation_guard_report.jsonl` | JSONL | Worker (guard) | STATUS (linia 2287) | Per-operacja: `{t, lang, key, result:"ok"/"blocked", reason}` |
| T4 | `i18n/status/translation_recent_latest.json` | JSON | Worker | STATUS (linia 2177) | Najnowsze tłumaczenia: `{timestamp, entries:[{lang,key,value,t}]}` |
| T5 | `i18n/status/translation_recent_report.jsonl` | JSONL | Worker | — | Fullna historia tłumaczeń |
| T6 | `i18n/status/translation_grammar_audit_latest.json` | JSON | Worker (grammar audit) | STATUS | Wynik audytu gramatyki: `{timestamp, checked, issues}` |
| T7 | `i18n/status/translation_grammar_audit_history.jsonl` | JSONL | Worker | — | Historia audytów |
| T8 | `i18n/status/translation_domain_audit_latest.json` | JSON | Worker | — | Audyt domen tłumaczeń |
| T9 | `i18n/status/translation_dispatch_state.json` | JSON | Worker | Worker | Stan dispatch tłumaczeń: `{last_lang, last_category, queue_position}` |
| T10 | `i18n/status/translation_lang_stats_cache.json` | JSON | Worker | STATUS | Cache statystyk per-lang: `{lang:{translated, total, pct}}` |
| T11 | `i18n/status/translation_strict_candidates_cache.json` | JSON | Worker | Worker | Cache strict candidates |
| T12 | `i18n/status/deferred_translation_queue.jsonl` | JSONL | Worker | Worker | Kolejka odroczonych tłumaczeń — **7.8MB** |

---

### 22.6. PLIKI JAKOŚCI / QUALITY

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| Q1 | `i18n/status/quality_audit_latest.json` | JSON | Worker (quality audit) | STATUS (linia 2406) | `{timestamp, checked_entries, issues_found, slow_mode, issues_by_type:{}}` |
| Q2 | `i18n/status/quality_audit_state.json` | JSON | Worker | Worker | Stan audytu: cursor, progress |
| Q3 | `i18n/status/quality_dashboard.json` | JSON | Worker | STATUS (linia 2414) | Per-lang dashboard: `{lang:{checked, issues, quality_pct}}` |
| Q4 | `i18n/status/quality_report.jsonl` | JSONL | Worker | — | Pełna historia audytów |
| Q5 | `i18n/status/tier_quality_gate.json` | JSON | Worker | Worker | Brama jakości per-tier: `{tier, min_quality_pct, pass}` |
| Q6 | `i18n/status/tier_quality_gate.jsonl` | JSONL | Worker | — | Historia bramki jakości |

---

### 22.7. PLIKI EKSTRAKCJI / EXTRACTION

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| E1 | `i18n/status/extraction_catalog_latest.json` | JSON | Worker (extraction) | STATUS | Katalog ekstrakcji — **704KB**: `{timestamp, total_candidates, high_confidence, review_queue, entries:[]}` |
| E2 | `i18n/status/extraction_catalog_history.jsonl` | JSONL | Worker | — | Historia katalogów |
| E3 | `i18n/status/extraction_crossref.json` | JSON | Worker | STATUS | Cross-reference ekstrakcji — **223KB** |
| E4 | `i18n/status/extraction_manual_review_queue.json` | JSON | Worker | Użytkownik | Kolejka do ręcznego przeglądu — **138KB** |
| E5 | `i18n/status/extraction_parser_health.json` | JSON | Worker | — | Zdrowie parsera ekstrakcji |

---

### 22.8. PLIKI DOKUMENTACJI

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| D1 | `i18n/status/documentation_state.json` | JSON | `tools/i18n_generate_project_docs.py` | Worker | Cursor + progress fazy DOCUMENTATION |
| D2 | `i18n/status/documentation_latest.json` | JSON | `tools/i18n_generate_project_docs.py` | Worker, STATUS | Podsumowanie: `{timestamp, total_files, documented, remaining, quality_pct}` |
| D3 | `i18n/status/documentation_quality_report.json` | JSON | `tools/i18n_generate_project_docs.py` | — | Raport jakości dokumentacji |
| D4 | `i18n/status/documentation_unresolved_report.json` | JSON | `tools/i18n_generate_project_docs.py` | — | Nierozwiązane problemy dokumentacji |

---

### 22.9. PLIKI DAEMONÓW (statusd, guardian)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| S1 | `i18n/status/statusd_state.json` | JSON | statusd daemon | guardian, STATUS | `{timestamp, status:"running", last_cycle:"ok"}` |
| S2 | `i18n/status/statusd_report.json` | JSON | statusd daemon | Użytkownik, STATUS | Full report: `{worker:{pid, heartbeat_at, heartbeat_age_s, cycle, mode, pid_alive}, guardian:{state, throughput_per_h, guard_fail_rate_pct, issues:[]}, translation_kpi:{window_entries, total_translated, total_guard_fail, per_lang:{lang:{translated,guard_fail,pct}}}}` |
| S3 | `i18n/status/statusd_daily_report.json` | JSON | statusd | — | Raport dzienny statusd |
| S4 | `i18n/status/statusd_daily_report.md` | Markdown | statusd | — | Markdown wersja S3 |
| S5 | `i18n/status/statusd_doctor.json` | JSON | statusd | — | Diagnostyka statusd: auto-healing |
| S6 | `i18n/status/statusd.log` | TXT | statusd | — | Log demona statusd |
| S7 | `i18n/status/statusd_thresholds_snapshot.json` | JSON | statusd | — | Snapshot progów alertów |
| G1 | `i18n/status/guardian_daemon_state.json` | JSON | guardian daemon | statusd, STATUS | `{timestamp, state:"running", source, pid, reason, lock_age_sec}` |
| G2 | `i18n/status/guardian_health.json` | JSON | guardian | statusd | Zdrowie guardiana: `{timestamp, state, issues}` |
| G3 | `i18n/status/guardian_restart_metrics.json` | JSON | guardian | — | Metryki restartów workera |

---

### 22.10. KONTRAKTY TŁUMACZEŃ (done_contracts)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| C1 | `i18n/status/done_contracts/{lang}_{category}.json` | JSON | Worker (AUTO_TRANSLATE) | Worker, STATUS | Zakończone tłumaczenia: `{lang, category, keys_translated, timestamp}` — ~190 plików |
| C2 | `i18n/status/done_contract_history.jsonl` | JSONL | Worker | — | Historia kontraktów — **770KB** |

---

### 22.11. WALIDACJA (validation)

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| V1 | `i18n/status/validation/{lang}_crossref.json` | JSON | Worker (VALIDATION) | STATUS | Cross-reference per-lang: klucze vs EN |
| V2 | `i18n/status/validation/{lang}_report.json` | JSON | Worker (VALIDATION) | STATUS | Raport walidacji per-lang |
| V3 | `i18n/status/validation/{lang}_spotcheck.json` | JSON | Worker (VALIDATION) | — | Spotcheck próbki (losowa weryfikacja) |
| V4 | `i18n/status/validation/summary.json` | JSON | Worker (VALIDATION) | STATUS | Zbiorczy summary walidacji |

> **Aktualnie**: ~100 plików w validation/ (50+ języków × crossref + report)

---

### 22.12. SNAPSHOTY DZIENNE I HISTORYCZNE

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| H1 | `i18n/status/daily/{YYYY-MM-DD}.json` | JSON | `tools/i18n_status.py build-daily` | STATUS | Snapshot dzienny: `{date, ops_count, errors_count, categories:{}, translations:{}}` — 8 plików (2025-12-16 do 2026-02-15) |
| H2 | `i18n/status/historia_daily.json` | JSON | Worker | — | Zbiorczy raport dzienny |
| H3 | `i18n/status/historia_snapshots.jsonl` | JSONL | Worker | — | Snapshoty historyczne (append) |
| H4 | `i18n/status/weekly_multilang_history.json` | JSON | Worker | — | Tygodniowa historia per-lang |
| H5 | `i18n/status/weekly_multilang_report.json` | JSON | Worker | — | Raport tygodniowy |

---

### 22.13. BASELINE I RECONCILE

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| B1 | `i18n/status/baseline/baseline.json` | JSON | Worker | Worker | Bazowy snapshot do porównań |
| B2 | `i18n/status/baseline/baseline_{date}_{pid}.json` | JSON | Worker | — | Historyczne baseline'y (10 plików) |
| B3 | `i18n/status/registry_reconcile_latest.json` | JSON | Worker (reconcile) | STATUS (linia 1587-1615) | Wynik reconcile: `{timestamp, total_drift, per_file_drift:[]}` |
| B4 | `i18n/status/registry_reconcile_state.json` | JSON | Worker | Worker | Stan reconcile |

---

### 22.14. NAPRAWA / REPAIR

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| RP1 | `i18n/status/repair_backlog_trend.jsonl` | JSONL | Worker (repair) | STATUS | Trend backlogu napraw |
| RP2 | `i18n/status/repair_stagnation_alert.json` | JSON | Worker | — | Alert stagnacji naprawy |
| RP3 | `i18n/status/identical_to_en_repair_queue.json` | JSON | Worker | Worker | Kolejka napraw identycznych do EN |
| RP4 | `i18n/status/identical_to_en_repair_queue_report.jsonl` | JSONL | Worker | — | Historia napraw identical-to-EN |
| RP5 | `i18n/status/identical_to_en_repair_tuning.jsonl` | JSONL | Worker | — | Tuning napraw |

---

### 22.15. FORCED COMMANDS I KOMENDY

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| FC1 | `i18n/status/forced_command_epoch_state.json` | JSON | Worker/guardian | Worker | Stan epoki: `{schema_version, updated_at_utc, current_epoch_id, current_epoch_sources:{script_mtime, script_size, worker_pid, worker_cycle}, epoch_changed, auto_baseline_on_epoch_change}` |
| FC2 | `i18n/status/forced_command_metrics.jsonl` | JSONL | Worker | — | Historia wymuszeń komend |
| FC3 | `i18n/status/forced_command_metrics_latest.json` | JSON | Worker | — | Najnowsze metryki wymuszenia |
| FC4 | `i18n/status/forced_command_sla_probe_*.jsonl` | JSONL | Worker | — | SLA probe per day |

---

### 22.16. SŁOWNIKI I MATERIAŁY TŁUMACZENIOWE

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| DIC1 | `i18n/status/simple_translations.json` | JSON | `tools/i18n_dictionary_materialize.py` (via worker) | Worker (AUTO_TRANSLATE) | Proste tłumaczenia: `{en_phrase: {lang: translation}}` |
| DIC2 | `i18n/status/simple_translations_base.json` | JSON | Ręcznie | Worker | Bazowe proste tłumaczenia |
| DIC3 | `i18n/status/simple_translations_pl_candidates.json` | JSON | Worker | — | Kandydaci PL prostych tłumaczeń |
| DIC4 | `i18n/status/word_translations.json` | JSON | `tools/i18n_dictionary_materialize.py` (via worker) | Worker | Tłumaczenia słów: `{en_word: {lang: word}}` |
| DIC5 | `i18n/status/word_translations_base.json` | JSON | Ręcznie | Worker | Bazowe tłumaczenia słów |
| DIC6 | `i18n/status/word_translations_pl_candidates.json` | JSON | Worker | — | Kandydaci PL słów |
| DIC7 | `i18n/status/tibia_proper_nouns.json` | JSON | Worker (inline Python, linia 576) | Worker | Nazwy własne Tibii (nie tłumaczyć) |
| DIC8 | `i18n/status/top_phrases_en.json` | JSON | Worker | Worker | Top frazy EN |
| DIC9 | `i18n/status/top_words_en.json` | JSON | Worker | Worker | Top słowa EN |
| DIC10 | `i18n/status/npclib.json` | JSON | Worker | STATUS (linia 1328) | Biblioteka NPC: zliczenie kluczy |
| DIC11 | `i18n/status/dictionary_expansion_summary.json` | JSON | Worker | — | Podsumowanie ekspansji słownika |
| DIC12 | `i18n/status/dictionary_materialize_summary.json` | JSON | Worker | — | Podsumowanie materializacji |

---

### 22.17. PLIKI POZOSTAŁE / MISC

| # | Plik (dokładna ścieżka) | Format | Zapisuje | Czyta | Opis |
|---|---|---|---|---|---|
| M1 | `i18n/status/pending_skip_24h_latest.json` | JSON | Worker | STATUS (linia 2308) | Ostatnie pending_skip: `{count, timestamp}` |
| M2 | `i18n/status/pending_skip_events.jsonl` | JSONL | Worker | — | Historia pending_skip eventów |
| M3 | `i18n/status/priority_gate_watch_state.json` | JSON | Worker | Worker | Stan obserwatora bram priorytetów |
| M4 | `i18n/status/project_file_inventory_cache.json` | JSON | Worker (inline Python, linia 1509) | STATUS | Cache inwentarza plików projektu |
| M5 | `i18n/status/manual_review_queue.json` | JSON | Worker (inline Python, linia 735) | Użytkownik | Kolejka do ręcznego przeglądu |
| M6 | `i18n/status/adaptive_batch_state.json` | JSON | Worker | Worker | Stan adaptacyjnego batchowania |
| M7 | `i18n/status/grammar_audit_state.json` | JSON | Worker | Worker | Stan audytu gramatyki |
| M8 | `i18n/status/status_sections_latest.json` | JSON | Worker (STATUS gen) | — | Surowe sekcje statusu |
| M9 | `i18n/status/status_update_state.json` | JSON | Worker (STATUS gen) | — | Stan updatowania statusu |
| M10 | `i18n/status/status_force_metrics_state.json` | JSON | Worker | — | Stan metryki wymuszenia |
| M11 | `i18n/status/strict_hourly_window_latest.json` | JSON | Worker | STATUS | Najnowsze okno godzinowe strict |
| M12 | `i18n/status/auto_translate_progress.tmp.w` | TMP | Worker | Worker | Tymczasowy plik postępu (w trakcie cyklu) |
| M13 | `i18n/status/language_readiness.md` | Markdown | Worker | Użytkownik | Gotowość językowa (human readable) |
| M14 | `i18n/status/i18n_global_stats.json` | JSON | Worker (kopia) | — | Kopia pliku R1 wewnątrz status/ |

---

### 22.18. PODKATALOGI STATUSU

| Podkatalog | Ścieżka | Plików | Wzorzec nazw | Opis |
|---|---|---|---|---|
| **categories/** | `i18n/status/categories/` | 0 (aktualnie pusty) | `{category}.json` | Planowane: per-category status |
| **daily/** | `i18n/status/daily/` | 8 | `{YYYY-MM-DD}.json` | Snapshoty dzienne (2025-12-16 → 2026-02-15) |
| **done_contracts/** | `i18n/status/done_contracts/` | ~190 | `{lang}_{category}.json` | Zakończone tłumaczenia per-lang per-cat |
| **validation/** | `i18n/status/validation/` | ~100 | `{lang}_crossref.json`, `{lang}_report.json`, `{lang}_spotcheck.json`, `summary.json` | Raporty walidacji per-lang |
| **tm/** | `i18n/status/tm/` | ~90 | `{lang}.json`, `{lang}.json.bak` | Translation Memory per-lang |
| **baseline/** | `i18n/status/baseline/` | 10 | `baseline.json`, `baseline_{date}_{pid}.json` | Snapshoty bazowe |
| **pre_migration_todo/** | `i18n/status/pre_migration_todo/` | 99 | `{category}.json/.md/.csv`, `pre_migration_todo_latest.json`, `_history.jsonl`, `_todo.csv` | Wyniki skanów PRE_MIGRATION |

---

## 23. INTEGRACJA MIGRACJI Z SYSTEMEM STATUSU

### 23.1. Przepływ danych Worker → Status

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        i18n_worker_simple.sh                                │
│                                                                             │
│  ┌──────────────┐     ┌──────────────────┐     ┌────────────────────────┐  │
│  │ status_update │     │  status_log_op() │     │  status_log_error()   │  │
│  │ _activity()   │     │                  │     │                       │  │
│  └──────┬───────┘     └────────┬─────────┘     └──────────┬────────────┘  │
│         │                      │                           │               │
│         ▼                      ▼                           ▼               │
│  tools/i18n_status.py   tools/i18n_status.py      tools/i18n_status.py   │
│  update-activity         log-op                    log-error              │
│         │                      │                           │               │
│         ▼                      ▼                           ▼               │
│  activity.json           ops.jsonl                  errors.jsonl          │
│  (LIVE heartbeat)        (append-only)              (append-only)         │
│                                                                             │
│  end_of_cycle():                                                           │
│  ├── build-daily  ──────────►  daily/{date}.json                           │
│  ├── build-worker-state ────►  worker_state.json                           │
│  ├── inline Python  ────────►  i18n_global_stats.json (ROOT)              │
│  │                  ────────►  i18n_file_status.json (ROOT)               │
│  │                  ────────►  I18N_STATUS.md (ROOT)                      │
│  │                  ────────►  translation_global_overview.json           │
│  │                  ────────►  worker_cycle_perf_latest.json              │
│  └── i18n_status_pusher.sh ─►  git push I18N_STATUS.md                   │
│                                                                             │
│  PRE_MIGRATION:                                                            │
│  └── i18n_pre_migration_scan.py ──► pre_migration_scan.json               │
│                                  ──► pre_migration_todo/{cat}.json/md/csv │
│                                  ──► pre_migration_todo_latest.json       │
│                                                                             │
│  AUTO_TRANSLATE:                                                           │
│  ├── translation_guard  ────────►  translation_guard_latest.json          │
│  │                      ────────►  translation_guard_report.jsonl         │
│  ├── translation_recent ────────►  translation_recent_latest.json         │
│  ├── done_contracts     ────────►  done_contracts/{lang}_{cat}.json       │
│  │                      ────────►  done_contract_history.jsonl            │
│  ├── grammar_audit      ────────►  translation_grammar_audit_latest.json  │
│  ├── deferred_queue     ────────►  deferred_translation_queue.jsonl       │
│  └── dictionary         ────────►  simple_translations.json               │
│                         ────────►  word_translations.json                 │
│                                                                             │
│  VALIDATION:                                                               │
│  └── validation engine  ────────►  validation/{lang}_crossref.json        │
│                         ────────►  validation/{lang}_report.json          │
│                                                                             │
│  QUALITY:                                                                  │
│  └── quality audit      ────────►  quality_audit_latest.json              │
│                         ────────►  quality_dashboard.json                 │
│                                                                             │
│  DOCUMENTATION:                                                            │
│  └── i18n_generate_project_docs.py ►  documentation_state.json            │
│                                    ►  documentation_latest.json           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         DAEMON LAYER                                        │
│                                                                             │
│  statusd ─────► statusd_state.json, statusd_report.json                   │
│                  statusd_daily_report.json, statusd_doctor.json            │
│                                                                             │
│  guardian ────► guardian_daemon_state.json, guardian_health.json            │
│                  guardian_restart_metrics.json                              │
│                                                                             │
│  forced_cmd ──► forced_command_epoch_state.json                            │
│                  forced_command_metrics.jsonl                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 23.2. Komendy Workera (worker_command.sh)

| Komenda | Opis | Efekt na status |
|---|---|---|
| `force {category}` | Wymuś przetworzenie kategorii | `activity.json` → natychmiastowa zmiana |
| `random` | Losowa kategoria | `activity.json` → zmiana |
| `status` | Pokaż status | Brak zapisu |
| `skip` | Pomiń bieżącą kategorię | `pending_skip_events.jsonl` |
| `premig {category}` | Wymuś skan PRE_MIGRATION | `pre_migration_scan.json` + `pre_migration_todo/*` |
| `documentation` | Tryb dokumentacji | `documentation_state.json` |
| `docindex` | Indeksuj dokumentację | `documentation_latest.json` |

### 23.3. Narzędzia (tools/) a pliki statusu

| Narzędzie | Ścieżka | Zapisuje pliki |
|---|---|---|
| `i18n_status.py` | `tools/i18n_status.py` | `activity.json`, `ops.jsonl`, `errors.jsonl`, `daily/{date}.json`, `worker_state.json` |
| `i18n_pre_migration_scan.py` | `tools/i18n_pre_migration_scan.py` | `pre_migration_scan.json`, `pre_migration_todo/{cat}.json/md/csv`, `pre_migration_todo_latest.json`, `pre_migration_todo_history.jsonl`, `pre_migration_todo.csv` |
| `i18n_generate_project_docs.py` | `tools/i18n_generate_project_docs.py` | `documentation_state.json`, `documentation_latest.json` |
| `i18n_dictionary_materialize.py` | `tools/i18n_dictionary_materialize.py` | `simple_translations.json`, `word_translations.json`, `dictionary_materialize_summary.json` |

### 23.4. Tryby Workera (Phases) vs Pliki

| Tryb (MODE) | Fazy/Stages | Pliki zapisywane w trybie |
|---|---|---|
| **PRE_MIGRATION** | `pre_migration_scan`, `pending_skip`, `pre_migration_done` | PM1-PM7, R1, L1, J1-J3 |
| **TRANSLATION_SYNC** | `sync_start`, `sync_file_done`, `sync_done` | L1, J1, R1, R2, T1, T9 |
| **AUTO_TRANSLATE** | `auto_start`, `parallel_start`, `auto_done` | L1, J1, T1-T12, C1-C2, DIC1-DIC12 |
| **COMPACT_KEYS** | `keymap_sync`, `keymap_verify`, `export`, `done` | L1, J1, R1 |
| **VALIDATION** | `validation_start`, `validation_done` | L1, J1, V1-V4, Q1-Q6 |
| **IDLE** | `idle_cycle`, `sleeping` | L1, J1, R1 |
| **DOCUMENTATION** | (via `i18n_generate_project_docs.py`) | D1-D4 |
| **(lifecycle)** | `cycle_start`, `cycle_end`, `dispatch`, `signal`, `restart` | L1, L2, J1-J4, R1, R6, H1-H5 |

### 23.5. WYMAGANIA DLA TRYBU MIGRATION

Gdy MIGRATION zostanie włączony (`MIGRATION_ENABLED=true`), worker MUSI:

1. **Przed migracją pliku**:
   - `status_update_activity "running" $CYCLE "MIGRATION" "migration_start" $cat $file "migrating" 0 $total "files" $eta`
   - Zapisać backup do `i18n_file_status.json` (etap `1_started`)

2. **Po każdej modyfikacji pliku**:
   - `status_log_op $CYCLE "MIGRATION" "file_migrated" $cat $file "ok" "keys=$N" $keys_added $files_changed`
   - Zaktualizować `i18n_file_status.json` (etap odpowiedni do postępu)
   - Zaktualizować `i18n_global_stats.json` → `migration.files_scanned++`, `migration.keys_extracted+=N`

3. **Po błędzie**:
   - `status_log_error $CYCLE "MIGRATION" "migration_fail" $cat $file "error_msg" "rollback"`

4. **Po zakończeniu kategorii**:
   - Wywołać `build-daily` i `build-worker-state`
   - Zaktualizować `pre_migration_scan.json` (zmniejszyć `needs_migration`)
   - Dodać wpis do `pre_migration_todo_history.jsonl`

5. **Nowe pliki statusowe MIGRATION** (do stworzenia):
   - `i18n/status/migration_progress.json` — postęp migracji: `{category, files_done, files_total, keys_migrated, keys_total, started_at, eta}`
   - `i18n/status/migration_rollback_log.jsonl` — log rollbacków
   - `i18n/status/migration_validation_report.json` — wynik walidacji po migracji

### 23.6. SZYBKA TABELA WYSZUKIWANIA (File → Purpose)

```
activity.json                        → LIVE heartbeat workera (co kilka sek.)
adaptive_batch_state.json            → Stan adaptacyjnego batchowania
auto_translate_progress.tmp.w        → Tymczasowy plik postępu tłumaczeń
baseline/baseline.json               → Bazowy snapshot porównawczy
daily/{YYYY-MM-DD}.json              → Snapshot dzienny
deferred_translation_queue.jsonl     → Kolejka odroczonych tłumaczeń (7.8MB)
dictionary_expansion_summary.json    → Podsumowanie ekspansji słownika
dictionary_materialize_summary.json  → Podsumowanie materializacji słownika
documentation_latest.json            → Wynik ostatniego przebiegu dokumentacji
documentation_quality_report.json    → Jakość dokumentacji
documentation_state.json             → Cursor dokumentacji
documentation_unresolved_report.json → Nierozwiązane problemy dokumentacji
done_contract_history.jsonl          → Historia kontraktów tłumaczeń (770KB)
done_contracts/{lang}_{cat}.json     → Zakończony kontrakt tłumaczenia
errors.jsonl                         → Log błędów (586KB, append-only)
extraction_catalog_latest.json       → Katalog ekstrakcji (704KB)
extraction_catalog_history.jsonl     → Historia katalogów ekstrakcji
extraction_crossref.json             → Cross-ref ekstrakcji (223KB)
extraction_manual_review_queue.json  → Kolejka ręcznego przeglądu (138KB)
extraction_parser_health.json        → Zdrowie parsera
forced_command_epoch_state.json      → Stan epoki wymuszeń komend
forced_command_metrics.jsonl         → Metryki wymuszonych komend
forced_command_metrics_latest.json   → Najnowsze metryki wymuszenia
grammar_audit_state.json             → Stan audytu gramatyki
guardian_daemon_state.json           → Stan guardiana
guardian_health.json                 → Zdrowie guardiana
guardian_restart_metrics.json        → Metryki restartów
historia_daily.json                  → Zbiorczy raport dzienny
historia_snapshots.jsonl             → Historyczne snapshoty
i18n_file_status.json (ROOT)         → Per-file stage tracking
i18n_global_stats.json (ROOT)        → Master statystyki workera
i18n_global_stats.json (status/)     → Kopia master stats w status/
i18n_processed_files.txt (ROOT)      → Flat list przetworzonych plików
i18n_progress_baseline.json (ROOT)   → Bazowy snapshot postępu
I18N_STATUS.md (ROOT)                → Raport Markdown (pushowany do git)
identical_to_en_repair_queue.json    → Kolejka napraw identycznych do EN
identical_to_en_repair_queue_report.jsonl → Historia napraw
identical_to_en_repair_tuning.jsonl  → Tuning napraw
lang_sequence.log                    → Sekwencja języków
language_readiness.md                → Gotowość językowa (human readable)
manual_review_queue.json             → Kolejka ręcznego przeglądu
npclib.json                          → Biblioteka NPC
ops.jsonl                            → Log operacji (append-only)
pending_skip_24h_latest.json         → Ostatnie pending_skip
pending_skip_events.jsonl            → Historia pending_skip
pre_migration_scan.json              → Master wynik skanu PRE_MIGRATION
pre_migration_todo/{cat}.json        → Todo per-category (JSON)
pre_migration_todo/{cat}.md          → Todo per-category (Markdown)
pre_migration_todo/{cat}.csv         → Todo per-category (CSV)
pre_migration_todo_latest.json       → Podsumowanie najnowszego skanu
pre_migration_todo_history.jsonl     → Historia skanów
priority_gate_watch_state.json       → Stan bramki priorytetów
project_file_inventory_cache.json    → Cache inwentarza plików
quality_audit_latest.json            → Wynik audytu jakości
quality_audit_state.json             → Stan audytu jakości
quality_dashboard.json               → Dashboard jakości per-lang
quality_report.jsonl                 → Historia audytów jakości
registry_reconcile_latest.json       → Wynik reconcile
registry_reconcile_state.json        → Stan reconcile
repair_backlog_trend.jsonl           → Trend backlogu napraw
repair_stagnation_alert.json         → Alert stagnacji napraw
simple_translations.json             → Proste tłumaczenia (słownik)
simple_translations_base.json        → Bazowe proste tłumaczenia
statusd_daily_report.json            → Raport dzienny statusd
statusd_daily_report.md              → Markdown raport statusd
statusd_doctor.json                  → Diagnostyka statusd
statusd.log                          → Log demona statusd
statusd_report.json                  → Pełny raport statusd
statusd_state.json                   → Stan demona statusd
statusd_thresholds_snapshot.json     → Snapshot progów alertów
status_force_metrics_state.json      → Stan metryki wymuszenia
status_sections_latest.json          → Surowe sekcje statusu
status_update_state.json             → Stan updatowania statusu
strict_hourly_window_latest.json     → Najnowsze okno godzinowe
suspicious_log.jsonl                 → Podejrzane tłumaczenia
suspicious_rejected.jsonl            → Odrzucone podejrzane
tibia_proper_nouns.json              → Nazwy własne Tibii
tier_quality_gate.json               → Brama jakości per-tier
tier_quality_gate.jsonl              → Historia bramki
tm/{lang}.json                       → Translation Memory per-lang
top_phrases_en.json                  → Top frazy EN
top_words_en.json                    → Top słowa EN
transition_log.jsonl                 → Log przejść między trybami
translation_dispatch_state.json      → Stan dispatch tłumaczeń
translation_domain_audit_latest.json → Audyt domen
translation_global_overview.json     → Globalny przegląd (1773 linii)
translation_grammar_audit_history.jsonl → Historia audytu gramatyki
translation_grammar_audit_latest.json → Najnowszy audyt gramatyki
translation_guard_latest.json        → Najnowszy guard report
translation_guard_report.jsonl       → Pełny guard report
translation_lang_stats_cache.json    → Cache statystyk per-lang
translation_recent_latest.json       → Najnowsze tłumaczenia
translation_recent_report.jsonl      → Pełna historia tłumaczeń
translation_strict_candidates_cache.json → Cache strict candidates
validation/{lang}_crossref.json      → Cross-reference per-lang
validation/{lang}_report.json        → Raport walidacji per-lang
validation/{lang}_spotcheck.json     → Losowa weryfikacja
validation/summary.json              → Zbiorczy summary
weekly_multilang_history.json        → Historia tygodniowa per-lang
weekly_multilang_report.json         → Raport tygodniowy
word_translations.json               → Tłumaczenia słów (słownik)
word_translations_base.json          → Bazowe tłumaczenia słów
worker_cycle_perf.jsonl              → Historia wydajności cykli
worker_cycle_perf_latest.json        → Najnowsza wydajność cyklu
worker_state.json                    → Trwały stan workera per-category
```

### 23.7. TOTAL PLIKÓW STATUSU

| Lokalizacja | Plików | Wielkość |
|---|---|---|
| ROOT (`./`) | 6 | ~424KB |
| `i18n/status/` (flat) | ~105 | ~15MB+ |
| `i18n/status/baseline/` | 10 | |
| `i18n/status/categories/` | 0 (pusty) | |
| `i18n/status/daily/` | 8 | |
| `i18n/status/done_contracts/` | ~190 | |
| `i18n/status/pre_migration_todo/` | 99 | |
| `i18n/status/tm/` | ~90 | |
| `i18n/status/validation/` | ~100 | |
| **RAZEM** | **~608** | |

---

## 24. ZADANIE: DETEKCJA ZAKOŃCZENIA PRE_MIGRATION

### 24.1. Problem
Worker w trybie PRE_MIGRATION skanuje kategorie cyklicznie, ale nie ma mechanizmu
stwierdzającego "PRE_MIGRATION jest ZAKOŃCZONA — wszystkie kategorie przeskanowane,
wyniki stabilne". Bez tego worker bezcelowo powtarza te same skany w kółko.

### 24.2. Stan aktualny PRE_MIGRATION (2026-02-15)

| Status | Kategorii | Szczegóły |
|---|---|---|
| ✅ DONE (needs_migration=0) | 12 | actions, chatchannels, creaturescripts, events, globalevents, movements, npclib, otclient_mods, quests, scripts, talkactions, world |
| 🔍 NEEDS_MIGRATION (>0) | 20 | monsters(1703), php(2779), html(288), otclient_modules(169), errors(141), spells(191), libs(35), cpp(32), server(32), otclient_src(19), mounts(8), otclient_tools(8), items(9), modules(3), startup(3), dataroot(1), npc(1), otclient_data(1), raids(1), documentation(934) |
| **TOTAL** | **32** | hits=124,798 files=6,358 |

### 24.3. Definicja "PRE_MIGRATION zakończona"
PRE_MIGRATION jest zakończona gdy:
1. **Wszystkie 32 kategorii** zostały przeskanowane co najmniej 1 raz
2. **Wyniki są stabilne** — dwa kolejne pełne skany dają te same wyniki
3. **Pliki `pre_migration_todo/*.json`** są wygenerowane dla każdej kategorii

> **UWAGA**: "zakończona" NIE oznacza "needs_migration=0 wszędzie".
> To oznacza "skan jest kompletny, wiemy co pozostaje do zmigrowania".
> Kategorie z needs_migration>0 to BACKLOG — lista pracy do MIGRATION mode.

### 24.4. Implementacja w workerze

**Nowy plik statusu**: `i18n/status/pre_migration_complete.json`
```json
{
  "complete": true,
  "completed_at_utc": "2026-02-15T...",
  "total_categories": 32,
  "categories_scanned": 32,
  "categories_clean": 12,
  "categories_with_hits": 20,
  "total_hits": 124798,
  "total_files_with_hits": 6358,
  "scan_stable": true,
  "last_scan_utc": "2026-02-15T...",
  "backlog_summary": {
    "monsters": 1703,
    "php": 2779,
    "...": "..."
  }
}
```

**Logika w workerze** (w sekcji PRE_MIGRATION po `scan_done`):
1. Po każdym skanie: sprawdź `pre_migration_scan.json`
2. Jeśli wszystkie kategorie mają `scanned_at` (nie null) → skan kompletny
3. Porównaj z poprzednim wynikiem (`pre_migration_complete.json.prev`)
4. Jeśli wyniki stabilne przez 2 cykle → oznacz jako `complete: true`
5. Zapisz `pre_migration_complete.json`
6. Log: `status_log_op $CYCLE "PRE_MIGRATION" "pre_migration_complete" "all" "-" "ok" "complete"`
7. Worker NADAL skanuje (bo nowe pliki mogą się pojawić), ale:
   - Skip 60 min zamiast 30 min (rzadsze skanowanie)
   - Status: "PRE_MIGRATION complete — monitoring mode"

### 24.5. Zmiany w I18N_STATUS.md
Dodać sekcję:
```
### ✅ PRE_MIGRATION Status: ZAKOŃCZONA
- Przeskanowano: 32/32 kategorii
- Stabilne wyniki: TAK (od 2026-02-15T...)
- Backlog (do MIGRATION mode): 20 kategorii, 124,798 hitów
```

### 24.6. Zmiany w `activity.json`
Gdy complete=true, `activity.json` powinno zawierać:
```json
{
  "phase": "PRE_MIGRATION",
  "stage": "pre_migration_complete",
  "message": "PRE_MIGRATION complete — monitoring mode"
}
```
