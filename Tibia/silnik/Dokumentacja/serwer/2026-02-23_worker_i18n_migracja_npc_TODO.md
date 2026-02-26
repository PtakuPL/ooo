# Worker i18n: Poprawki migracji NPC — TODO
**Data**: 2026-02-23  
**Status**: W TRAKCIE (migration-first)  
**Referencja**: `Dokumentacja/serwer/2026-02-22_oressa_i18n_fix.md` (poprawnie zmigrowany NPC)

---

## Aktualizacja 2026-02-23 (6 trybów workera)

Pełna analiza i plan 6 trybów znajduje się w:
- `Dokumentacja/serwer/2026-02-23_worker_i18n_6_trybow_plan_analiza.md`

Najważniejsze ustalenia operacyjne:
- Migracja jest nadal najbardziej krytyczna (blokuje poprawność dialogów NPC i gameplay).
- Worker ma mieć jawne tryby: `SCAN`, `RESYNC`, `MIGRATION`, `TRANSLATION`, `QUALITY`, `DOCUMENTATION`.
- Domyślne uruchomienie bez trybu ma wykonywać pełny łańcuch 1→2→3→4→5→6.
- Implementację finalnego CLI `--mode ...` odkładamy na końcowy etap (po stabilizacji wszystkich rodzajów pracy).

### Synchronizacja z ostatnimi dokumentacjami workera (2026-02-14/15)
- Uwzględniono `canary_test/docs/i18n/PRE_MIGRATION_AND_DOCUMENTATION_MODES_PLAN_2026-02-14.md` oraz `canary_test/docs/i18n/I18N_MULTILANG_QUALITY_PLAN_2026-02-14.md`.
- Wniosek reconciliation: część funkcji jest historycznie oznaczona jako DONE w dokumentacji, ale obecny dispatcher nadal nie ma osobnego runtime mode `DOCUMENTATION`, a `MIGRATION` jest wyłączony (`MIGRATION_ENABLED=false`).
- Plan nadrzędny po synchronizacji: `Dokumentacja/serwer/2026-02-23_worker_i18n_6_trybow_plan_analiza.md`.

### Snapshot techniczny (NPC)
- Pliki NPC: `1027`
- Pliki NPC używające numerowanych kluczy `say_*`: `448`
- Odwołania do `say_*` w kodzie NPC: `4315`
- Klucze EN w `i18n/en/npc.json`: `13773`
- Języki (regex workerowy): `52`
- Braki kluczy Oressa (`healing_healed`, `healing_not_needed`, `distance_prompt`, `decided_prompt`): `51/52` języków

### Priorytet wykonawczy (kolejne kroki)
- [ ] Uruchomić i zweryfikować pełny pipeline dla pojedynczego NPC (scan -> resync -> migration -> quality), zaczynając od `oressa`.
- [ ] Wydzielić jawny tryb `MIGRATION` dla NPC (niezależnie od pozostałych faz).
- [x] Dodać audit post-migration dla NPC: key-exists, placeholder parity, keyword parity, brak `\\z`.
- [x] Wymusić twardy gate (pilot NPC): bez przejścia audytu migracja pliku jest wycofywana (rollback Lua + EN JSON snapshot).
- [ ] Uzupełnić brakujące klucze Oressa (`healing_healed`, `healing_not_needed`, `distance_prompt`, `decided_prompt`) we wszystkich językach.
- [ ] Domknąć tryb `DOCUMENTATION` jako osobny etap dispatchera.

---

## Wdrożone teraz (przygotowanie workera)

Zmiany wykonane w kodzie workera i toolingu:

- `canary_test/i18n_worker_simple.sh`:
  - snapshot `en/npc.json` przed migracją pojedynczego NPC i rollback przy błędzie,
  - audit po `stage_5` z twardym zatrzymaniem (`NPC_MIGRATION_AUDIT_ENABLED`, `NPC_MIGRATION_AUDIT_STRICT`),
  - stabilizacja indeksacji `say_*` (start od istniejącego `max+1`),
  - normalizacja tekstów (`\\z` + whitespace) w etapach 4/5,
  - preferowane mapowanie `npcHandler:say` po realnie wygenerowanych kluczach z pliku po transformacji (`npcsay_mapping_mode=transformed_order`).

- `canary_test/tools/i18n_npc_migration_audit.py`:
  - nowy audyt spójności migracji NPC (key/text/placeholder/keyword/`\\z`),
  - raport: `i18n/status/npc_migration_audit/<npc>.json`,
  - wsparcie `--en-json-before` do odfiltrowania starych kluczy przy audycie bieżącej migracji.

Status tej iteracji: worker jest przygotowany bezpieczniej do kolejnych testów migracji NPC, ale nadal wymaga domknięcia semantycznych kluczy (`npc.oressa.healing_*` itd.) i rolloutu na wszystkie języki.

---

## Aktualizacja 2026-02-23 (testy innych NPC + status gate)

Wykonano testy `--file` na wielu NPC i poprawiono logikę analizy:

- Testy kontrolne `--file`:
  - `oressa.lua` -> `needs=false`, `runtimeMismatch=0/29`, poprawny skip + aktualizacja `I18N_STATUS.md`.
  - `the_oracle.lua`, `captain_jack.lua` -> poprawny skip (`needs=false`).
  - `gnomargery.lua`, `gnombold.lua`, `gnomadness.lua` -> runtime gate zatrzymuje plik (`rc=1`) z powodu brakujących args do placeholderów.
- Naprawiono fałszywe wykrycie migracji:
  - `stage_2` liczy teraz tylko `npcHandler:say(`, nie łapie `npcHandler:sayLocalized(`.
  - Przykład: `herbert.lua` po poprawce ma `needs=false` (wcześniej fałszywe `needs=true`).
- Dodano runtime gate w `stage_2`:
  - nowe flagi: `NPC_RUNTIME_PLACEHOLDER_CHECK_ENABLED`, `NPC_RUNTIME_PLACEHOLDER_CHECK_STRICT`,
  - gate blokuje plik tylko gdy `placeholder_count > args_count` (nadmiar args jest akceptowalny),
  - wspierane placeholdery fmt: `{}`, `{0}`, `{1:.2f}`.
- Status pliku po blokadzie jest teraz poprawny:
  - `overall_status=failed`,
  - `stages.8_sync.status=failed`,
  - `last_error=runtime_placeholder_mismatch`.

### Metryki po poprawce logiki placeholderów

- Globalnie: `151` runtime mismatchów w `46` plikach NPC (po korekcie: `{0}` + tolerancja nadmiarowych args).
- Błędy level-related (potwierdzone): `5` (m.in. `gnomargery.lua`, `gnomadness.lua`).
- Spójność kluczy po ekstrakcji/resync:
  - `used_refs=14165`,
  - `unique_used_keys=13746`,
  - `missing_in_en=0`.

Wniosek: worker przestał oznaczać błędne NPC jako „completed/OK” i poprawnie wykrywa krytyczne rozjazdy runtime w placeholderach.

---

## Aktualizacja 2026-02-23 (auto-repair runtime mismatch)

Wdrożono automatyczną naprawę NPC po wykryciu runtime mismatch w `stage_2`.

### Co zostało dodane

- `canary_test/i18n_worker_simple.sh`:
  - `NPC_RUNTIME_AUTO_REPAIR_ENABLED`,
  - `NPC_RUNTIME_REPAIR_SOURCE_DIRS`,
  - `find_npc_runtime_repair_source`,
  - `attempt_runtime_repair_from_source` (naprawa + walidacja w tym samym przebiegu workera).
- nowy tool:
  - `canary_test/tools/i18n_npc_runtime_repair.py`
  - mapuje kolejność wiadomości z pliku źródłowego (`canary/...`) na istniejące wywołania `NPC_LIB.i18n.npcSay*`,
  - rozwiązuje kolizje kluczy (`say_*` użyte dla różnych tekstów),
  - aktualizuje `i18n/en/npc.json`,
  - ma fallback sanitizacji placeholderów gdy źródło/docelowy plik mają różną liczbę wpisów.

### NPC naprawione automatycznie przez workera (`--file`)

- `gnomargery` (`runtimeMismatch: 8 -> 0`)
- `gnombold` (`runtimeMismatch: 8 -> 0`)
- `gnomadness` (`runtimeMismatch: 1 -> 0`)
- `eruaran` (`runtimeMismatch: 20 -> 0`)
- `grizzly_adams` (`runtimeMismatch: 12 -> 0`)
- `paulie` (`runtimeMismatch: 10 -> 0`)
- `plunderpurse` (`runtimeMismatch: 9 -> 0`)
- `wentworth` (`runtimeMismatch: 9 -> 0`)
- `gnomilly` (`runtimeMismatch: 8 -> 0`)
- Batch auto-repair (`37/37` pozostałych plików z runtime mismatch) zakończony sukcesem:
  - `ok=37`, `fail=0`
  - każdy plik po przebiegu ma `runtimeMismatch=0`.

Wszystkie powyższe po naprawie mają:
- `needs_migration=false`,
- `runtime_placeholder_mismatch=0`,
- `overall_status=completed`.

### Metryki globalne po tej fali napraw

- Runtime mismatch: `151 -> 0`
- Pliki z runtime mismatch: `46 -> 0`
- `level_related_mismatch`: `5 -> 0`
- Brak surowych tekstów NPC (scan):
  - `raw_npcHandler_say_files=0`
  - `voices_text_entries=0`
  - `greet_farewell_text_entries=0`
- `setMessage_text_entries=0`

---

## Aktualizacja 2026-02-23 (semantic gate + weryfikacja linia-po-linii)

Wdrożono dodatkową kontrolę semantyczną dla już zmigrowanych NPC (nie tylko runtime placeholder gate).

### Co dodano w workerze

- `canary_test/tools/i18n_npc_migration_audit.py`:
  - nowy zakres audytu `--key-scope all_npc_keys` (nie tylko `say_*`),
  - porównanie tekstu odporne na różnicę placeholderów `{}` vs `{0}`,
  - nowa metryka `message_count_mismatch`.
- `canary_test/i18n_worker_simple.sh`:
  - nowe flagi:
    - `NPC_MIGRATION_AUDIT_KEY_SCOPE` (domyślnie `all_npc_keys`),
    - `NPC_SEMANTIC_AUDIT_ENABLED`,
    - `NPC_SEMANTIC_AUDIT_STRICT`,
    - `NPC_SEMANTIC_AUDIT_KEY_SCOPE`.
  - `stage_2` uruchamia semantic audit dla plików już na `NPC_LIB.i18n.npcSay*`,
  - źródło porównania bierze z raw NPC (`find_npc_runtime_repair_source`, np. `../canary/...`), nie tylko z lokalnego backupu,
  - status zapisuje nowe pola (`semantic_*`) oraz `semantic_gate_blocked`,
  - nowy kod wyjścia `return 4` dla semantic gate.
- `process_file`:
  - nowa ścieżka błędu `semantic_migration_mismatch`,
  - status pliku ustawiany jako `failed` (`stages.8_sync.status=failed`) gdy semantyka jest błędna.
- `attempt_runtime_repair_from_source`:
  - po nieudanym auto-repair i rollbacku plików odświeżane jest `stage_2`, żeby `i18n_file_status.json` pokazywał faktyczny stan po rollbacku (a nie stan chwilowy z nieudanego patcha).
- `canary_test/tools/i18n_npc_runtime_repair.py`:
  - poprawione parowanie (dużo większy koszt `skip`, preferencja 1:1 gdy liczba wpisów source/target jest równa).

### Raport line-by-line (fizyczna kontrola)

- raport końcowy:
  - `canary_test/i18n/status/npc_migration_audit/line_by_line_worker_check_allkeys_2026-02-23_post_worker_pass.json`
- raporty stage_2 semantic (per NPC):
  - `canary_test/i18n/status/npc_migration_audit/*_stage2_semantic.json`

### Wynik po przebiegu na 13 NPC (po finalnym fallback-rebuild)

Wdrożono dodatkowy fallback w `attempt_runtime_repair_from_source`:
- gdy szybki remap nie domyka semantic gate, worker robi pełną przebudowę pliku z raw source NPC i uruchamia cały pipeline migracji od nowa.

Dodatkowo naprawiono błąd w `stage_4` (obsługa `literal` w liczniku transformacji), który blokował fallback-rebuild na części NPC.

Raport końcowy line-by-line (po poprawkach):
- `canary_test/i18n/status/npc_migration_audit/line_by_line_worker_check_allkeys_2026-02-23_post_worker_pass_v2.json`

Wynik:
- wszystkie 13/13 NPC mają `mismatch=0`, `placeholder=0`, `keyword=0`, `countMismatch=0`.
- wszystkie 13/13 mają w statusie:
  - `overall_status=completed`
  - `needs_migration=false`
  - `semantic_mismatch_text=0`
  - `semantic_placeholder_mismatch=0`
  - `semantic_keyword_mismatch=0`
  - `semantic_message_count_mismatch=0`

### Dodatkowa stabilizacja reguł (task NPC)

Po naprawie taskowych NPC dodano regułę anty-pętli:
- jeśli NPC dialog (`npcHandler:say` -> `NPC_LIB.i18n.npcSay*`) ma `semantic=0` i `runtime=0`, worker nie wymusza ponownej migracji tylko na podstawie wzorców z innych podsystemów (np. `StdModule`), żeby nie wpadać w fałszywe przebiegi `stage_4/5` i rollback.

### TODO po tej iteracji

- [ ] Rozszerzyć migrację `StdModule.say` w zagnieżdżonych `node:addChildKeyword(...)` (to osobna ścieżka poza NPC dialog `npcHandler:say`).
- [ ] Dodać osobny raport „blocking_vs_nonblocking semantic mismatch” dla łatwiejszego triage.
- [ ] Dodać batch raportujący procent NPC domkniętych fallback-rebuild vs szybki remap.

## Aktualizacja 2026-02-23 (task rules: StdModule + status integrity)

Wdrożono kolejną falę poprawek pod kątem NPC taskowych, gdzie worker wcześniej oznaczał pliki jako „OK” mimo braków w `StdModule.say`.

- `stage_2`:
  - dokładna metryka `StdModule_missing_i18n` (zamiast heurystyki globalnego `i18nKey`),
  - nowa metryka `npcHandler_say_migratable` (nie liczy dynamicznych `npcHandler:say(parameters.text, ...)` jako dług migracyjny),
  - anti-loop działa tylko gdy `legacy_migration_pending=false`.
- `stage_4`:
  - aktywowana realna transformacja `StdModule.say`/`StdModule.promotePlayer`:
    - `text = "..."` -> dopięcie `i18nKey`,
    - `text = "..." .. expr` / `string.format(...)` -> `i18nKey` + `i18nArgs`,
    - klucze EN są uzupełniane bezpośrednio w trakcie transformacji (żeby uniknąć driftu numeracji).
- `run_npc_migration_audit`:
  - source do audytu bierze raw NPC (`find_npc_runtime_repair_source`) z fallbackiem do lokalnego backupu.
- `process_file`:
  - dodany post-check po `stage_5`/audycie; jeśli `stage_2` nadal zwraca `needs=true`, plik dostaje `failed` (`residual_migration_needs`) zamiast fałszywego `completed`.

Wynik testów `--file`:

- `lynda.lua`: `StdModule_missing_i18n 8 -> 0`, status końcowy `completed`, `needs=false`.
- `klom_stonecutter.lua`: `StdModule_missing_i18n 6 -> 3` (pozostały bloki `text={...}`), status końcowy `failed` przez post-check.
- `captain_dreadnought.lua`: pozostaje `failed` (residual dynamiczny `text = text or ...`).

Raport residual po tej iteracji:

- `canary_test/i18n/status/npc_migration_audit/stdmodule_residual_report_2026-02-23.json`
- `files_with_residual_stdmodule=46`
- `total_residual_entries=60`
- rozkład: `dynamic=56`, `table=3`, `concat=1`

Wniosek operacyjny:

- ścieżka migracji `npcHandler:say -> NPC_LIB.i18n.npcSay*` jest stabilna,
- część taskowych `StdModule.say` jest już naprawiana automatycznie,
- pozostał osobny backlog parsera dla `text={...}` i dynamicznych fallbacków (`text = text or ...`).

## Aktualizacja 2026-02-23 (Captain Dreadnought: forensic + stabilizacja worker)

Zdiagnozowano i naprawiono regresję NPC `captain_dreadnought` zgłaszaną w grze (złe odpowiedzi nawet dla `{yes}`).

### Root cause (potwierdzone)

- `process_file`: przy fail post-check (`residual_migration_needs`) worker zostawiał częściowo zmigrowany Lua + EN JSON bez rollbacku.
- `process_file`: dla `ret=2` (brak migracji) kończył na etapie 3, więc nie wykonywał resync tłumaczeń (etap 6) i walidacji (7/8).
- `stage_6`: wcześniej dodawał tylko brakujące klucze; nie odświeżał istniejących, rozjechanych mapowań.
- `stage_5`: ekstrakcja `npcConfig.voices` łapała tylko pierwszy wpis (regex kończył blok na pierwszym `}`).
- `stage_7`: walidacja wykrywała błędy, ale nie przerywała pipeline (return code był zawsze 0).
- `stage_4`: przy dopinaniu `i18nKey` do `StdModule` mógł generować podwójny przecinek (`..., , i18nKey`) przy braku parsera Lua w środowisku.

### Wdrożone poprawki w workerze

- `stage_2`:
  - `StdModule_missing_i18n` liczy tylko migratable przypadki;
  - `text={...}` i dynamiczne `text = var` są traktowane jako non-migratable (nie blokują post-check).
- `process_file`:
  - post-check fail robi rollback Lua + EN snapshot i próbuje `attempt_runtime_repair_from_source`;
  - ścieżka `ret=2` wykonuje teraz etapy `6->7->8` (resync + validation + sync).
- `stage_5`:
  - zapisuje `keys_updated` + `updated_keys` dla etapu 6;
  - nie nadpisuje istniejących `stdmod_*` z uproszczonego regex backupu (żeby nie psuć placeholderów concat);
  - ekstrakcja `voices` przepisana na skan bloku z liczeniem nawiasów klamrowych.
- `stage_6`:
  - odświeża klucze zmienione w EN (`updated_keys`);
  - ma full-resync języka, gdy wykryje duży drift (`missing>=3` lub `missing_ratio>=20%`).
- `stage_7`:
  - błędy walidacji kończą etap kodem != 0 (pipeline nie idzie dalej).
- `stage_4`:
  - bezpieczne dopinanie separatora przy `i18nKey` (bez podwójnych przecinków).
- nowy tryb naprawczy:
  - `NPC_FORCE_REBUILD_FROM_SOURCE=true` (rebuild NPC z raw source),
  - `NPC_FORCE_REBUILD_PURGE_PREFIX=true` (purge prefixu `npc.<safe>.` w `en` + `pl,de,es,pt,fr,it,ru` przed rebuild).

### Wynik po naprawie `captain_dreadnought`

- `i18n_worker_simple.sh --file data-otservbr-global/npc/captain_dreadnought.lua`:
  - `StdModule_missing_i18n=0`,
  - `runtimeMismatch=0/15`,
  - `semanticMismatch=0/15`,
  - `needs=false`,
  - `overall_status=completed`.
- Spójność kluczy:
  - klucze użyte w Lua: `33`,
  - brakujące w `i18n/en/npc.json`: `0`,
  - brakujące w `i18n/pl/npc.json`: `0`.

---

## Problemy wykryte przy migracji NPC Oressa

### 1. Złe mapowanie kluczy `say_*`
Worker automatycznie numerował klucze `say_1`, `say_2`, ... ale łączył je z NIEWŁAŚCIWYMI wiadomościami. Np. klucz `say_1` zawierał tekst rycerza (knight) zamiast tekstu leczenia (healing).

**Wymaganie**: Worker musi mapować klucze semantycznie:
- `npc.oressa.healing_healed` zamiast `npc.oressa.say_1`
- `npc.oressa.distance_prompt` zamiast `npc.oressa.say_5`
- `npc.oressa.decided_prompt` zamiast `npc.oressa.say_6`

### 2. `npcSayMultiple` — brakująca funkcja
Worker generował wywołania `NPC_LIB.i18n.npcSayMultiple(...)` ale ta funkcja nie istniała w `i18n_wrappers.lua` (była tylko `npcSayTable` bez opóźnień).

**Naprawione**: Dodano `NPC_LIB.i18n.npcSayMultiple()` z obsługą opóźnień (delay) — tłumaczy klucze, buduje tabelę i przekazuje do `npcHandler:say(table, npc, player, delay)`.

### 3. Dynamiczne fragmenty wiadomości utracone przy migracji
Oryginał NPC często ma:
```lua
npcHandler:say("SO BE IT. RISE, NOBLE " .. player:getVocation():getName():upper() .. "! ...", npc, creature)
```
Worker rozdzielił to na osobne klucze `say_18` + `say_19` — **tracąc dynamiczną nazwę profesji**.

**Wymaganie**: Worker musi wykrywać konkatenacje `..` z dynamicznymi wartościami i zamieniać na placeholdery `{0}`, `{1}`:
```lua
-- Klucz: "SO BE IT. RISE, NOBLE {0}! ..."
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oressa.say_18", {player:getVocation():getName():upper()})
```

### 4. `\z` Lua escape w tłumaczeniach JSON
Worker kopiował surowe stringi Lua z `\z` (Lua whitespace eater) do JSON. JSON nie rozumie `\z` — pojawia się dosłownie w tekście NPC.

**Wymaganie**: Worker musi usuwać `\z` i normalizować whitespace przed wstawieniem do JSON.

---

## Tłumaczenia komend NPC ({keywords})

### Problem
W oryginalnym (EN) kodzie NPC mówi np.:
```
"Do you like to keep your {distance}, or do you like {close} combat?"
```
`{distance}` i `{close}` to **klikalne komendy** w kliencie — gracz klika i automatycznie wysyła tę komendę do NPC.

### Wymaganie: Komendy muszą być przetłumaczone ALE pozostać angielskie w NPC
**UWAGA**: Komendy NPC (`{distance}`, `{close}`, `{heal}`, `{magic}`, `{bow}`, `{spear}`, `{vocation}`, `{knight}`, `{paladin}`, `{druid}`, `{sorcerer}`, `{trade}`, `{yes}`, `{choosing}`, `{decided}`, `{healing}`) to słowa kluczowe rozpoznawane przez `MsgContains()` na serwerze.

**Serwer rozpoznaje TYLKO angielskie keywords** (hardcoded w `MsgContains(message, "knight")`). Dlatego:
- `{knight}` musi POZOSTAĆ jako `{knight}` w tłumaczeniu (nie zmieniać na `{rycerz}`)
- Gracz klika `{knight}` → wysyła "knight" → serwer rozpoznaje

### Opcje do rozważenia (TODO):
1. **Opcja A — Keywords po angielsku**: Wszystkie `{keyword}` zostają angielskie we WSZYSTKICH językach. Tekst wokół jest tłumaczony. Np. PL: `"Czy lubisz zachować {distance}, czy wolisz walkę w {close}?"`
2. **Opcja B — Dwujęzyczne keywords**: `{distance|dystans}` — klient wyświetla "dystans" ale wysyła "distance". Wymaga zmiany klienta.
3. **Opcja C — Tłumaczone keywords + server-side mapping**: Serwer mapuje `MsgContains(message, "rycerz")` → rozpoznaje jako "knight". Wymaga zmian w KAŻDYM NPC.

**Aktualne rozwiązanie**: Opcja A — keywords po angielsku, reszta przetłumaczona.

### Lista keywords wymagających uwagi przy tłumaczeniu:
| Keyword | Kontekst | Uwagi |
|---------|----------|-------|
| `{knight}` | Wybór profesji | Nie tłumaczyć — MsgContains("knight") |
| `{paladin}` | Wybór profesji | Nie tłumaczyć |
| `{druid}` | Wybór profesji | Nie tłumaczyć |
| `{sorcerer}` | Wybór profesji | Nie tłumaczyć |
| `{trade}` | Handel NPC | Nie tłumaczyć — otwiera okno handlu |
| `{distance}` | Dialog Oressa | Nie tłumaczyć — MsgContains("distance") |
| `{close}` | Dialog Oressa | Nie tłumaczyć |
| `{heal}` | Dialog Oressa | Nie tłumaczyć |
| `{magic}` | Dialog Oressa | Nie tłumaczyć |
| `{bow}` | Dialog Oressa | Nie tłumaczyć |
| `{spear}` | Dialog Oressa | Nie tłumaczyć |
| `{yes}` | Potwierdzenie | Nie tłumaczyć |
| `{vocation}` | Opis profesji | Nie tłumaczyć |
| `{choosing}` | Greet Oressa | Nie tłumaczyć |
| `{decided}` | Greet Oressa | Nie tłumaczyć |
| `{healing}` | Greet Oressa | Nie tłumaczyć |
| `{healer}` | Opis Oressa | Nie tłumaczyć |

---

## Checklist dla workera przy migracji NPC

- [ ] Klucze i18n semantyczne (nie `say_1`, `say_2` — tylko `healing_healed`, `distance_prompt` itp.)
- [ ] Dynamiczne `..` konkatenacje → placeholdery `{0}`, `{1}` z argumentami w Lua
- [ ] `\z` escape usunięty przed wstawieniem do JSON
- [ ] `{keyword}` zachowane bez tłumaczenia we WSZYSTKICH językach
- [ ] `npcSayMultiple` używane dla multi-message dialogów (z delay)
- [ ] Tłumaczenia kompletne — żadnych angielskich słów w środku polskiego tekstu
- [ ] Testy: greet → vocation → knight/paladin/druid/sorcerer → yes → teleport

---

## Referencja: Poprawnie zmigrowany NPC
Patrz: `Dokumentacja/serwer/2026-02-22_oressa_i18n_fix.md` — kompletny opis poprawek NPC Oressa z listą wszystkich błędów i napraw.

Plik NPC: `data-otservbr-global/npc/oressa.lua`  
Tłumaczenia: `i18n/en/npc.json` + `i18n/pl/npc.json` (klucze `npc.oressa.*`)

---

## Aktualizacja 2026-02-23 (NPC full pipeline bez dokumentacji + realne tłumaczenia PL/RU)

Wdrożone w workerze (`canary_test/i18n_worker_simple.sh`):

- nowy tryb uruchomienia:
  - `--npc-full [N]` -> wykonuje pełny pipeline tylko dla NPC (`stage_1`, `stage_2`, `stage_3_or_skip`, `stage_6`, `stage_7`, `stage_8`) dla wszystkich plików lub z limitem;
- `stage_3` może być pomijany konfiguracyjnie:
  - `NPC_DOCUMENTATION_ENABLED=false`,
  - w statusie zapisuje `3_documentation.status=skipped` (zamiast braku etapu);
- `stage_6` przestał być tylko placeholderem:
  - zapisuje status jako `6_translation` (zgodnie z dashboardem),
  - robi sync/resync dla języków z `NPC_STAGE6_SYNC_LANGS` (domyślnie `pl ru`),
  - uruchamia realny auto-translate dla języków z `NPC_STAGE6_REAL_TRANSLATION_LANGS` (domyślnie `pl ru`);
- auto-translate dostał scope po prefiksie kluczy:
  - `AUTO_TRANSLATE_KEY_PREFIXES="npc.<safe>."`,
  - dzięki temu stage6 tłumaczy tylko klucze danego NPC, a nie cały `npc.json`.

Weryfikacja wykonania:

- test `--file`:
  - `NPC_DOCUMENTATION_ENABLED=false ... --file data-otservbr-global/npc/captain_dreadnought.lua`;
  - wynik:
    - `3_documentation=skipped`,
    - `6_translation.real_translation_languages_done=["pl","ru"]`,
    - `6_translation.real_translation_totals.translated=66`,
    - `7_validation=completed`,
    - `overall_status=completed`;
- test `--npc-full 1`:
  - pipeline działa poprawnie w trybie bez dokumentacji (`DOCUMENTATION: false`), status końcowy `ok=1 fail=0`.

Kontrola jakości po wdrożeniu (Captain Dreadnought):

- klucze w scope: `33`,
- `pl`: `missing=0`, `placeholders=0`, `en_copy=0`,
- `ru`: `missing=0`, `placeholders=0`, `en_copy=0`,
- placeholdery komend NPC (`{yes}`, `{no}`) zostały zachowane.

Otwarte kwestie quality (do dalszej iteracji):

- dla RU część wpisów nadal wpada w `suspicious_high` (nieblokujące) mimo przejścia guardów;
- dodać twardy gate dla `suspicious_high` w stage6 NPC lub osobny automatyczny pass naprawczy (`QUALITY -> TRANSLATION_REPAIR`) przed oznaczeniem finalnego `done`.
