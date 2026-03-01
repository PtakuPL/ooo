# Worker i18n: audyt wzorców migracji key-insertion (serwer + instalka)
**Data**: 2026-02-24  
**Zakres**: `canary_test/` (`server + installer/testyy`, bez ręcznej edycji plików gry)  
**Cel**: wykryć wszystkie typy miejsc, gdzie hardcoded text powinien być zamieniony na klucz i18n, oraz wskazać luki migratorów workera.

---

## 1. Co zostało wdrożone

Dodano nowe narzędzie:

- `canary_test/tools/i18n_migration_pattern_audit.py`

Dodano nowy tryb workera:

- `bash i18n_worker_simple.sh --pattern-audit [server|full|all]`

Generowane artefakty:

- `canary_test/i18n/status/migration_pattern_audit/latest.json`
- `canary_test/i18n/status/migration_pattern_audit/latest.md`
- `canary_test/i18n/status/migration_pattern_audit/latest.csv`
- `canary_test/i18n/status/migration_pattern_audit/history.jsonl`

---

## 2. Potwierdzenie: skan każdego pliku

Wykonano pełny audit dla obu scope:

1. `server`:
   - `files_scanned=5736`
   - `hits_total=15413`
   - `hits_supported=278`
   - `hits_unsupported=15135`
   - `unsupported_ratio_pct=98.2`
   - pliki z trafieniami: `390` (`unsupported` w `126` plikach)

2. `full` (serwer + instalka):
   - `files_scanned=6652`
   - `hits_total=17586`
   - `hits_supported=2355`
   - `hits_unsupported=15231`
   - `unsupported_ratio_pct=86.61`
   - pliki z trafieniami: `594` (`unsupported` w `161` plikach)

Wniosek: audit fizycznie przeskanował wszystkie pliki w zadanym zakresie; `latest.csv` zawiera wpisy `file:line` dla każdego trafienia.

---

## 3. Pełna macierz typów wzorców (17)

Legenda:
- `full_hits`: serwer + instalka
- `server_hits`: sam serwer
- `instalka_delta = full_hits - server_hits`

| Pattern ID | supported_by_worker | full_hits | server_hits | instalka_delta | Migration path |
|---|---|---:|---:|---:|---|
| `xml_visible_attrs_literal` | `false` | 14922 | 14910 | 12 | `-` |
| `otclient_tr_literal` | `true` | 2063 | 0 | 2063 | `tools/i18n_migrate_otclient_tr.py` |
| `npc_voices_text` | `true` | 257 | 257 | 0 | `i18n_worker_simple.sh stage4 (voices text -> i18nKey)` |
| `cpp_runtime_text_calls` | `false` | 165 | 101 | 64 | `-` |
| `lua_say_concat_or_dynamic` | `false` | 66 | 66 | 0 | `-` |
| `otclient_tr_dynamic` | `false` | 61 | 42 | 19 | `-` |
| `otui_text_literal` | `true` | 14 | 0 | 14 | `tools/i18n_migrate_otclient_otui_text.py` |
| `lua_sendtext_concat_or_dynamic` | `false` | 13 | 13 | 0 | `-` |
| `lua_sendtext_string_format` | `true` | 10 | 10 | 0 | `tools/i18n_migrate_lua_sendtext.py` |
| `lua_sendtext_literal` | `true` | 5 | 5 | 0 | `tools/i18n_migrate_lua_sendtext.py` |
| `lua_say_literal` | `true` | 4 | 4 | 0 | `tools/i18n_migrate_lua_say.py + NPC stage4 transformer` |
| `lua_broadcast_dynamic` | `false` | 3 | 3 | 0 | `-` |
| `lua_say_string_format` | `true` | 1 | 1 | 0 | `tools/i18n_migrate_lua_say.py + NPC stage4 transformer` |
| `npc_stdmodule_text` | `true` | 1 | 1 | 0 | `i18n_worker_simple.sh stage4 (StdModule -> i18nKey)` |
| `otui_other_visible_attrs_literal` | `false` | 1 | 0 | 1 | `-` |
| `lua_broadcast_literal_or_format` | `true` | 0 | 0 | 0 | `tools/i18n_migrate_lua_broadcast.py` |
| `npc_greet_farewell_text` | `true` | 0 | 0 | 0 | `i18n_worker_simple.sh stage4 (keyword text -> i18nKey)` |

---

## 4. Największe luki do wdrożenia w workerze

1. `xml_visible_attrs_literal` (`14922`)  
   Brak polityki domenowej XML (`items.xml`, `XML/*.xml`, raid xml). To największy backlog.

2. `cpp_runtime_text_calls` (`165`)  
   Brak bezpiecznego migratora C++ dla player-visible stringów (z filtrami na SQL/techniczne przypadki).

3. `lua_say_concat_or_dynamic` (`66`)  
   Generic migrator `i18n_migrate_lua_say.py` nie domyka concat/dynamic poza ścieżką NPC.

4. `otclient_tr_dynamic` (`61`)  
   Wymaga policy/manual-review; auto-keygen byłby ryzykowny.

5. `lua_sendtext_concat_or_dynamic` (`13`) + `lua_broadcast_dynamic` (`3`)  
   Wymaga rozszerzenia obecnych migratorów o dynamiczne argumenty.

6. `otui_other_visible_attrs_literal` (`1`)  
   Brak obsługi atrybutów poza `text` (`tooltip/title/description/placeholder/label`).

---

## 5. Najważniejsze pliki backlogu (unsupported)

- `data/items/items.xml` (`14362`)
- `data/XML/mounts.xml` (`169`)
- `data/XML/outfits.xml` (`134`)
- `data/XML/imbuements.xml` (`36`)
- `data/scripts/talkactions/player/server_info.lua` (`28`)
- `src/items/item.cpp` (`19`)
- `src/server/network/protocol/protocolgame.cpp` (`16`)
- `data/XML/vocations.xml` (`16`)

---

## 6. Plan wdrożenia do workera (kolejność)

1. **P1 (szybki zysk, niski risk)**  
   Rozszerzyć `i18n_migrate_lua_sendtext.py`, `i18n_migrate_lua_say.py`, `i18n_migrate_lua_broadcast.py` o concat/dynamic z mapowaniem na placeholdery `{0}`, `{1}`, ...

2. **P2 (instalka/UI)**  
   Rozszerzyć `i18n_migrate_otclient_otui_text.py` na atrybuty widoczne inne niż `text` oraz domknąć policy dla `otclient_tr_dynamic`.

3. **P3 (C++ runtime)**  
   Dodać dedykowany migrator C++ tylko dla jednoznacznych player-visible call sites.

4. **P4 (XML policy + migrator)**  
   Rozdzielić XML na:
   - auto-migration,
   - extract-only (resync),
   - never-migrate (techniczne identyfikatory).

5. **P5 (quality gate)**  
   Dla przypadków dynamicznych i niejednoznacznych: automatycznie oznaczać `manual_review_required`, nie oznaczać jako `completed`.

---

## 7. Uwaga operacyjna

`--pattern-audit` jest teraz gate wejściowym przed migracją masową:

1. uruchomić `--pattern-audit full`,
2. wdrożyć brakujące migratory wg P1..P5,
3. wykonać ponowny `--pattern-audit full`,
4. dopiero wtedy uruchomić pełny run `npc/monsters/ui` i przejść do tłumaczeń.

---

## 8. Update 2026-02-24 (P1 wdrożone + weryfikacja linia-po-linii)

Wdrożono `P1` w trzech migratorach:

- `canary_test/tools/i18n_migrate_lua_sendtext.py`
- `canary_test/tools/i18n_migrate_lua_say.py`
- `canary_test/tools/i18n_migrate_lua_broadcast.py`

Nowe zachowanie:

- obsługa konkatenacji `..` (literal + dynamiczne fragmenty),
- mapowanie konkatenacji na placeholdery `{}` + `args`,
- normalizacja tekstu przed zapisem do EN (`\\z` usuwane, whitespace normalizowany),
- zachowanie trybu bezpiecznego: pure dynamic bez literalu nadal `skip`.

### Weryfikacja fizyczna (line-by-line)

Wykonano testy na fizycznych kopiach realnych plików + fixture:

- staging:
  - `canary_test/testyy/staging_p1_verify/files/`
  - `canary_test/testyy/staging_p1_verify/backups/`
  - `canary_test/testyy/staging_p1_verify/json/en.json`

Pliki realne (kopie) zweryfikowane linia-po-linii:

1. `klom_stonecutter.lua`
   - `sendTextMessage("You earned " .. count .. ...)`
   - zmiana -> `sendLocalizedTextMessage(..., "npc.klom_stonecutter.msg_*", {count[playerId], plural})`
   - zmienione linie: `171`, `184`, `197` (staging copy).

2. `hireling.lua`
   - `sendTextMessage(string.format(...))` -> `sendLocalizedTextMessage(..., key, {amount, name, totalCost})`
   - `sendTextMessage("... " .. player:getStashCount() .. ...)` -> `sendLocalizedTextMessage(..., key, {player:getStashCount(), (...)})`
   - zmienione linie: `381`, `653`, `735` (staging copy).

Fixture `say`:

- `creature:say("Welcome, " .. player:getName() .. "!")`
- `npcHandler:say("You earned " .. player:getLevel() .. " points.", npc, player)`
- wynik:
  - `creature:sayLocalized("...say_3", TALKTYPE_SAY, {player:getName()})`
  - `npcHandler:sayLocalized("...say_1", npc, player, {player:getLevel()})`
  - pure dynamic (`npcHandler:say(dynamicMessage, ...)`) poprawnie pozostał bez zmian.

Fixture `broadcast`:

- `Game.broadcastMessage("Server will restart in " .. 10 .. " minutes.", ...)`
- wynik:
  - `Game.broadcastLocalizedMessage("...broadcast_2", ..., {10})`
  - pure dynamic (`Game.broadcastMessage(dynamicMessage, ...)`) poprawnie pozostał bez zmian.

### Wykryty i naprawiony błąd w trakcie walidacji

Podczas kontroli line-by-line wykryto bug:

- błędny rewrite `Game.Game.broadcastLocalizedMessage(...)` (podwójny prefiks).

Naprawa:

- migrator `i18n_migrate_lua_broadcast.py` ignoruje match `broadcastMessage` będący częścią `Game.broadcastMessage`,
- wynik końcowy: poprawny rewrite `Game.broadcastLocalizedMessage(...)`.

### Pozostały backlog po P1

- przypadki pure dynamic bez literalu (np. `sendTextMessage(..., message)`, `npcHandler:say(message, ...)`, `broadcastMessage(message, ...)`) pozostają świadomie niemigrowane automatycznie;
- wymagają osobnej polityki (`manual_review` / dataflow / source mapping), żeby nie psuć runtime.

---

## 9. Update 2026-02-24 (P2 wdrożone + weryfikacja linia-po-linii)

Wdrożono `P2`:

- rozszerzono `tools/i18n_migrate_otclient_otui_text.py`:
  - obsługa atrybutów widocznych: `text`, `tooltip`, `title`, `description`, `placeholder`, `label`
  - działa również dla prefiksu `!` (np. `!tooltip`).
- rozszerzono `tools/i18n_migrate_otclient_tr.py`:
  - dodano politykę dla `tr(dynamic)`:
    - dynamiczne przypadki są pomijane automatycznie,
    - zapisywane do raportu manual review `jsonl` (`--dynamic-report`).
- worker (`i18n_worker_simple.sh`) uruchamia migrator OTUI dla:
  - `.otui`, `.otmod`, `.otml`,
  - z detekcją wszystkich powyższych atrybutów.

### Weryfikacja fizyczna (line-by-line, staging)

Staging:
- `canary_test/testyy/staging_p2_verify/files/`
- `canary_test/testyy/staging_p2_verify/backups/`
- `canary_test/testyy/staging_p2_verify/json/en.json`
- `canary_test/testyy/staging_p2_verify/status/otclient_tr_dynamic_review.jsonl`

Przypadki sprawdzone:

1. Realny plik `.otmod` (z audytu):
   - `language_picker_override.otmod`
   - `description: "..."` -> `description: tr('otclient_mods.language_picker_override.otui_text_1')`

2. Fixture `.otui`:
   - `text`, `!text`, `tooltip`, `!tooltip`, `title`, `description`, `placeholder`, `label`
   - wszystkie literalne linie przepisane do `tr('key')` i kluczy EN.

3. Fixture `tr(dynamic)` + realny `option_healthcircle.otui`:
   - literal `tr("Simple title")` -> zmigrowany do klucza,
   - dynamiczne:
     - `tr(userProvidedTitle)`
     - `tr('Distance from center' .. ':')`
     - `tr('Opacity' .. ':')`
   - poprawnie oznaczone jako `dynamic_skipped` i zapisane do raportu JSONL.

### Snapshot audytu po P2

Po uruchomieniu `--pattern-audit full`:

- `files_scanned=6652`
- `hits_total=17587`
- `hits_supported=2357`
- `hits_unsupported=15230`
- `unsupported_ratio_pct=86.6`

Zmiana względem poprzedniego snapshotu:

- `otui_other_visible_attrs_literal`: teraz `supported_by_worker=true` (hits: `2`).

### Policy dla `otclient_tr_dynamic` (P2)

- `tr(dynamic)` nie jest migrowane automatycznie (ryzyko błędnego keygen),
- worker zapisuje przypadki do kolejki review:
  - `i18n/status/otclient_tr_dynamic_review.jsonl` (w produkcyjnym przebiegu workera),
  - aby domykać je ręcznie/quality pass bez psucia działania UI.

---

## 10. Update 2026-02-24 (P3 XML: items.xml jako wzorzec wspierany)

### Co wdrożono

- dodano nowy migrator/resync:
  - `tools/i18n_resync_items_xml.py`
  - pokrywa `items.xml` z obsługą:
    - `id`,
    - `fromid..toid`,
    - markerów `#i18n:*` (bez zapisu markerów jako treści EN),
    - naprawy aliasów markerów w `i18n/en/items.json`.
- `process_items_category` w workerze używa teraz tego narzędzia.
- dispatcher (`count_files_needing_work` dla `items`) używa `--check-only` tego samego toola (spójny gate).

### Zmiana klasyfikacji pattern-audit

W audycie dodano dedykowany wzorzec:

- `xml_items_name_desc_literal` -> `supported_by_worker=true`
  - migration path: `tools/i18n_resync_items_xml.py`.

I wyłączono dublowanie tych linii w ogólnym:

- `xml_visible_attrs_literal` pomija `data/items/items.xml` (bo ten plik ma teraz własny, wspierany wzorzec).

### Snapshot po P3 (`--pattern-audit server`)

- `files_scanned=5736`
- `hits_total=17744`
- `hits_supported=16971`
- `hits_unsupported=773`
- `unsupported_ratio_pct=4.36`

Kluczowe:

- `xml_items_name_desc_literal`: `hits=16693` (supported),
- `xml_visible_attrs_literal`: `hits=548` (pozostały realny backlog XML poza `items.xml`).

### Wniosek

Największy blok XML (`items.xml`) jest teraz formalnie domknięty po stronie capability workera (resync range-aware + gate).
Pozostały backlog XML dotyczy głównie innych domen (`mounts/outfits/vocations/imbuements` oraz wybrane XML runtime), które są następnym krokiem P3b.

---

## 11. Update 2026-02-24 (Run wykonawczy: XML items done)

Wykonano pełny run one-shot:

- `bash i18n_worker_simple.sh --items-full` (alias `--xml-full`).

Wynik:

- EN (`items.json`): `+20499` nowych kluczy, `163` naprawionych wartości markerów,
- sync:
  - `pl/items.json`: `+19734`,
  - `ru/items.json`: `+20154`,
- po runie wszystkie trzy pliki mają po `36733` klucze.

Walidacja końcowa:

- `tools/i18n_resync_items_xml.py --check-only` -> `__ITEMS_NEEDS_WORK__ 0`.

Uwagi:

- snapshot `pattern-audit server` po runie pozostaje:
  - `hits_total=17744`, `supported=16971`, `unsupported=773` (ratio `4.36%`),
  - ponieważ audit mierzy capability/pattern coverage, a nie wolumen już zsynchronizowanych kluczy.
