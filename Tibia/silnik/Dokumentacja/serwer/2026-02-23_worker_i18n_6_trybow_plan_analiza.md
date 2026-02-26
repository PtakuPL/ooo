# Worker i18n: 6 trybów pracy — plan i analiza (v5 po auto-repair)
**Data**: 2026-02-23  
**Status**: PLAN WYKONAWCZY V5 (migration-first + runtime auto-repair)  
**Zakres**: `canary_test/` (serwer + NPC + i18n + statusy)

---

## 0. Co zostało uwzględnione z ostatnich dokumentacji

Plan został zaktualizowany o ostatnio edytowane dokumenty workera i ich statusy:

- `canary_test/docs/i18n/PRE_MIGRATION_AND_DOCUMENTATION_MODES_PLAN_2026-02-14.md`
- `canary_test/docs/i18n/I18N_MULTILANG_QUALITY_PLAN_2026-02-14.md`
- `canary_test/docs/i18n/WORKER_IMPLEMENTATION_PROGRESS.md`
- `canary_test/docs/i18n/i18n_worker_simple_audit.md`
- `canary_test/docs/i18n/WORKER_MASTER_PLAN.md`
- `Dokumentacja/serwer/2026-02-23_worker_i18n_migracja_npc_TODO.md`
- `Dokumentacja/serwer/2026-02-22_oressa_i18n_fix.md`

Wniosek po synchronizacji: mamy dużo wykonanej pracy w narzędziach i statusach, ale aktualny dispatcher workera nie odzwierciedla pełnego modelu 6 trybów.

---

## 1. Wymaganie biznesowe i warunek od operatora

Docelowo worker ma obsłużyć 6 jawnych rodzajów pracy:

1. `SCAN`
2. `RESYNC`
3. `MIGRATION`
4. `TRANSLATION`
5. `QUALITY`
6. `DOCUMENTATION`

Bez trybu (`default`) ma uruchamiać całość w kolejności:

`SCAN -> RESYNC -> MIGRATION -> TRANSLATION -> QUALITY -> DOCUMENTATION`

Ustalenie operacyjne na teraz: implementację jawnego CLI `--mode ...` odkładamy na ostatni etap, gdy wszystkie rodzaje pracy będą działały poprawnie end-to-end.

---

## 2. Stan faktyczny: kod vs dokumentacja

### 2.1 Fakty z kodu (`canary_test/i18n_worker_simple.sh`)

- Dispatcher pracuje na fazach: `PRE_MIGRATION`, `COMPACT_KEYS`, `TRANSLATION_SYNC`, `AUTO_TRANSLATE`, `VALIDATION`, `IDLE`.
- Migracja kodu jest globalnie wyłączona: `MIGRATION_ENABLED=false`.
- W runtime commandach i helpie nie ma osobnego trybu `DOCUMENTATION`.
- Dokumentacja jest uruchamiana z `IDLE` przez `generate_npc_documentation` (kategorie), a nie jako niezależny mode dispatchera.

### 2.2 Fakty z narzędzi i artefaktów

- Narzędzia istnieją i są gotowe:
  - `tools/i18n_pre_migration_scan.py`
  - `tools/i18n_generate_project_docs.py`
  - `tools/i18n_npc_migrator.py` (obsługuje `--npc` i `--file`, czyli test jednego NPC)
  - `tools/i18n_migrate_lua_say.py`
- Artefakty `PRE_MIGRATION` są aktywne i aktualizowane.
- Artefakty dokumentacji projektu istnieją, ale wyglądają na zatrzymane na wcześniejszym przebiegu.

### 2.3 Reconciliation (co było DONE historycznie, a co jest dziś)

| Obszar | Status historyczny w docs (2026-02-14/15) | Status bieżący (2026-02-23, kod/artefakty) | Decyzja |
|---|---|---|---|
| `PRE_MIGRATION` | 10/10 DONE | Działa i emituje backlog | Trzymać jako bazę SCAN |
| `DOCUMENTATION` mode | 10/10 DONE | Brak osobnego mode w dispatcherze (tylko IDLE docs) | Odtworzyć jako osobny tryb na końcowym etapie |
| `MIGRATION` | Pipeline historycznie obecny | Zablokowane przez `MIGRATION_ENABLED=false` | Priorytet #1: odblokowanie i stabilizacja |
| `TRANSLATION` | Rozbudowane quality/waves | Działa, ale duży debt jakościowy | Utrzymać, ale powiązać twardo z QUALITY |
| `QUALITY` | Dużo mechanizmów DONE | Działa, brak pełnego gate do migracji i tłumaczeń | Dopięcie gate krytycznych |

### 2.4 Aktualizacja implementacyjna 2026-02-23 (przygotowanie workera)

Wdrożone bez ręcznych zmian w plikach serwera/klienta/i18n (zmiany tylko w workerze i narzędziach):

- `canary_test/i18n_worker_simple.sh`:
  - dodano snapshot i rollback `en/npc.json` per migrowany NPC (`backup_en_npc_json_snapshot`, `restore_en_npc_json_snapshot`),
  - dodano twardy audit po `stage_5` (`run_npc_migration_audit`) z rollbackiem przy błędzie,
  - dodano flagi sterujące: `NPC_MIGRATION_AUDIT_ENABLED`, `NPC_MIGRATION_AUDIT_STRICT`,
  - `stage_4` i `stage_5` startują numerację `say_*` od maksymalnego istniejącego indeksu (`max+1`) zamiast od `1`,
  - `stage_4` i `stage_5` normalizują teksty (usuwanie `\z`, normalizacja whitespace),
  - `stage_5` mapuje `npcHandler:say` preferencyjnie po kolejności faktycznie wygenerowanych kluczy w pliku po transformacji (`npcsay_mapping_mode=transformed_order`), z fallbackiem sekwencyjnym.

- nowy tool: `canary_test/tools/i18n_npc_migration_audit.py`:
  - waliduje: `key exists`, `text parity`, `placeholder parity`, `keyword parity`, brak `\z`, brak pustych wartości,
  - raportuje do `i18n/status/npc_migration_audit/<npc>.json`,
  - wspiera `--en-json-before` (filtrowanie starych kluczy przy audycie bieżącej migracji).

### 2.5 Aktualizacja implementacyjna 2026-02-23 (runtime gate + status integrity)

Dodatkowe poprawki wdrożone po testach `--file` na innych NPC:

- `stage_2`:
  - naprawa detekcji: liczony jest tylko wzorzec `npcHandler:say(` (bez `npcHandler:sayLocalized(`),
  - dodana weryfikacja runtime placeholderów `{}` / `{0}` / `{1:.2f}` vs args przekazane do `NPC_LIB.i18n.npcSay*`,
  - gate blokuje plik tylko gdy `placeholders_required > args_passed`.
- nowe flagi:
  - `NPC_RUNTIME_PLACEHOLDER_CHECK_ENABLED`,
  - `NPC_RUNTIME_PLACEHOLDER_CHECK_STRICT`.
- poprawiona integralność statusu:
  - przy runtime gate plik jest oznaczany jako `overall_status=failed`,
  - `stages.8_sync` dostaje `status=failed` + `reason=runtime_placeholder_mismatch`.
- poprawka audytu:
  - `tools/i18n_npc_migration_audit.py` liczy także placeholdery numerowane (`{0}`),
  - runtime mismatch raportowany tylko przy brakujących argumentach (nadmiar args nie jest błędem).

### 2.6 Aktualizacja implementacyjna 2026-02-23 (auto-repair z pliku źródłowego)

Dodatkowe wdrożenie po testach na kolejnych NPC:

- `i18n_worker_simple.sh`:
  - auto-repair przy `runtime gate`:
    - `NPC_RUNTIME_AUTO_REPAIR_ENABLED`,
    - `NPC_RUNTIME_REPAIR_SOURCE_DIRS`,
    - `find_npc_runtime_repair_source`,
    - `attempt_runtime_repair_from_source`.
- nowy tool:
  - `tools/i18n_npc_runtime_repair.py`:
    - mapuje wiadomości z surowego pliku źródłowego (`canary/...`) na istniejące wywołania `NPC_LIB.i18n.npcSay*`,
    - rozwiązuje kolizje kluczy `say_*`,
    - aktualizuje `i18n/en/npc.json`,
    - fallback: sanitizacja placeholderów, gdy źródło i docelowy plik mają rozjazd liczby wiadomości.
- poprawka niezależna:
  - `stage_4` / `stage_5`: poprawione escape `\\z` w Python heredoc, żeby nie blokować przebiegów naprawczych.

---

## 3. Snapshot metryk po synchronizacji

### 3.1 Migracja NPC i klucze

- Pliki NPC: `1027`
- Odwołania do `npc.*.say_<N>` w kodzie NPC: `4315`
- Pliki NPC używające numerowanych `say_*`: `448`
- Klucze EN w `i18n/en/npc.json`: `13773`
- Języki (regex workerowy): `52`

### 3.2 SCAN (`PRE_MIGRATION`) — stan globalny

Źródło: `i18n/status/pre_migration_scan.json` (ostatni skan: `2026-02-15T13:45:42Z`)

- Kategorie: `31`
- Łącznie przeskanowanych plików: `18063`
- Wykryte trafienia: `112434`
- Oznaczone jako wymagające migracji: `5423`

### 3.3 DOCUMENTATION — stan artefaktów

Źródła:
- `i18n/status/documentation_state.json`
- `i18n/status/documentation_latest.json`

Snapshot:

- `cursor=18`
- `total=7967`
- `processed_count=18`
- `errors=0`
- ostatni batch: `2026-02-14T22:44:59Z`
- `quality_pct=66.7`

Wniosek: dokumentacja projektowa istnieje, ale nie jest aktywnie domykana w bieżącym flow dispatchera.

### 3.4 Problemy jakości tłumaczeń NPC

- Klucze Oressa (`healing_healed`, `healing_not_needed`, `distance_prompt`, `decided_prompt`) brakują w `51/52` językach (są domknięte w EN/PL).
- W `npc.json`:
  - wpisy z `[EN]`: `654957` łącznie (średnio `12595` na język),
  - wpisy z `\z`: `16528` łącznie (średnio `317.85` na język, wszystkie 52 języki dotknięte).
- `quality_dashboard.json` (sumarycznie 52 języki):
  - `issues_total=448029`
  - `suspicious_total=54727`
  - `gt_guard_fail_total=37129`
  - `rejected_total=3149`

### 3.5 Runtime mismatch (po poprawce licznika placeholderów)

- Wynik globalny (przed auto-repair): `151` mismatchów runtime w `46` plikach NPC.
- Najczęściej dotknięte pliki: `eruaran.lua` (20), `grizzly_adams.lua` (12), `paulie.lua` (10), `plunderpurse.lua` (9), `wentworth.lua` (9).
- Przypadki level-related: `5` (m.in. `gnomargery.lua`, `gnomadness.lua`).
- Weryfikacja `--file`:
  - `oressa.lua` -> `runtimeMismatch=0/29`, poprawny skip (`needs=false`),
  - `gnomargery.lua`, `gnombold.lua`, `gnomadness.lua` -> poprawna blokada runtime gate (`rc=1`).
- Spójność kluczy EN po resync/ekstrakcji: `missing_in_en=0` dla wszystkich kluczy użytych przez NPC.

### 3.6 Runtime mismatch po auto-repair (snapshot po fali napraw)

- Wynik globalny (po auto-repair): `0` mismatchów runtime w `0` plikach NPC.
- `level_related_mismatch`: `0` (zredukowane z `5`).
- Potwierdzone naprawy wykonane automatycznie przez worker:
  - `gnomargery`, `gnombold`, `gnomadness`, `eruaran`, `grizzly_adams`, `paulie`, `plunderpurse`, `wentworth`, `gnomilly`.
- Batch końcowy:
  - pozostałe pliki z mismatch (`37`) przetworzone automatycznie (`ok=37`, `fail=0`),
  - po batchu globalny runtime gate backlog = `0`.
- Dla powyższych plików status po naprawie:
  - `needs_migration=false`,
  - `runtime_placeholder_mismatch=0`,
  - `overall_status=completed`.

### 3.7 Semantic mismatch (nowy gate + line-by-line verification)

Wdrożono semantic gate w `stage_2`, który porównuje:
- source raw NPC (`../canary/...` przez `find_npc_runtime_repair_source`),
- zmigrowane wywołania `NPC_LIB.i18n.npcSay*`,
- EN wartości kluczy.

Nowe flagi:
- `NPC_SEMANTIC_AUDIT_ENABLED`
- `NPC_SEMANTIC_AUDIT_STRICT`
- `NPC_SEMANTIC_AUDIT_KEY_SCOPE`
- + dla audytu migracji: `NPC_MIGRATION_AUDIT_KEY_SCOPE` (domyślnie `all_npc_keys`).

Nowy status integrity:
- semantic fail oznacza plik jako:
  - `overall_status=failed`
  - `stages.8_sync.status=failed`
  - `last_error=semantic_migration_mismatch`
- po nieudanym auto-repair i rollbacku worker odświeża `stage_2`, aby metryki `semantic_*` odpowiadały stanowi faktycznemu pliku po rollbacku.

Wynik kontroli 13 NPC (line-by-line):
- raport finalny: `canary_test/i18n/status/npc_migration_audit/line_by_line_worker_check_allkeys_2026-02-23_post_worker_pass_v2.json`

Po finalnych przebiegach `--file`:
- domknięte semantycznie 13/13 (`mismatch=0`, `placeholder=0`, `keyword=0`, `countMismatch=0`):
  - `bozo`, `captain_dreadnought`, `gnomargery`, `gnombold`, `gnomilly`,
  - `grizzly_adams`, `klom_stonecutter`, `lynda`, `oressa`, `paulie`,
  - `plunderpurse`, `walter_jaeger`, `wentworth`

Nowy fallback naprawczy:
- gdy szybki remap nie zamyka semantic gate, worker wykonuje pełną przebudowę NPC z raw source i odpala pełny pipeline migracji.
- to domknęło przypadki taskowe dla ścieżki `npcHandler:say` (`gnomargery`, `grizzly_adams`, `oressa`, `paulie`, `plunderpurse`, `wentworth`).

Wniosek operacyjny:
- runtime gate + semantic gate + fallback rebuild stabilizują główną migrację dialogów NPC (`npcHandler:say`).
- dla `StdModule.say` wdrożono dodatkowo:
  - precyzyjny licznik `StdModule_missing_i18n`,
  - post-check po migracji (blokuje fałszywe `completed` przy residual patterns),
  - transformację literal/concat/format -> `i18nKey` + `i18nArgs`.
- aktualny backlog residual `StdModule` (raport):
  - `canary_test/i18n/status/npc_migration_audit/stdmodule_residual_report_2026-02-23.json`
  - `files_with_residual_stdmodule=46`
  - `total_residual_entries=60` (`dynamic=56`, `table=3`, `concat=1`).

---

## 4. Mapowanie 6 trybów na obecny worker

| Tryb docelowy | Co mamy teraz | Ocena |
|---|---|---|
| `SCAN` | `PRE_MIGRATION` + `i18n_pre_migration_scan.py` + backlog `file/line/text` | Działa |
| `RESYNC` | `TRANSLATION_SYNC` (EN -> LANG) | Częściowo (brak pełnego `resync-en`) |
| `MIGRATION` | Pipeline jest, ale wyłączony (`MIGRATION_ENABLED=false`) | Krytyczna luka |
| `TRANSLATION` | `AUTO_TRANSLATE` + strict + wave + guardy | Działa, ale z dużym debt |
| `QUALITY` | `VALIDATION`, audyty i raporty statusowe | Częściowo (brak pełnych gate) |
| `DOCUMENTATION` | IDLE docs + osobne narzędzie project docs | Częściowo/regres (brak niezależnego mode) |

---

## 5. Plan wykonawczy (migration-first, z uwzględnieniem dotychczasowych prac)

## Etap E0: Reconciliation i freeze założeń

Cel:

- Zamknąć rozjazd między „DONE w dokumentacji” a bieżącym kodem.
- Potwierdzić artefakty, które realnie są source-of-truth.

Zakres:

1. Spiąć dokumentację 2026-02-14/15 z bieżącym planem operacyjnym.
2. Oznaczyć elementy „historycznie done, wymagają reaktywacji” (głównie `DOCUMENTATION mode`).
3. Ustalić ten plik jako plan nadrzędny dla 6 trybów.

Kryterium wyjścia:

- Jedna aktualna mapa: `co działa`, `co jest częściowe`, `co jest zablokowane`.

## Etap E1: MIGRATION dla pojedynczego NPC (pilot, obowiązkowy)

Cel:

- Dać bezpieczny tor: `1 NPC -> scan -> resync -> migration -> quality`.

Zakres:

1. Wykorzystać istniejące narzędzia single-target:
   - `tools/i18n_npc_migrator.py --npc <name>` lub `--file <path>`.
2. Dodać walidację potoku dla jednego NPC:
   - key exists in EN,
   - placeholder parity,
   - keyword parity,
   - brak `\z`,
   - brak pustych wartości.
3. Potwierdzić przypadek krytyczny na `oressa.lua`.

Kryterium wyjścia:

- Single-NPC flow daje powtarzalny wynik bez regresji gameplay.

## Etap E2: Stabilizacja silnika MIGRATION (NPC)

Cel:

- Naprawa źródła błędów `say_*` i dynamicznych konkatenacji.

Zakres:

1. Klucze:
   - preferować reuse istniejącego klucza po tekście EN,
   - nowe klucze tworzyć semantycznie,
   - `say_*` zostawić tylko jako fallback legacy.
2. Dynamiczne teksty:
   - `..` -> placeholdery `{0}`, `{1}`, z prawidłowym przekazaniem argumentów.
3. Normalizacja:
   - usuwanie `\z`,
   - normalizacja whitespace.
4. Keyword safety:
   - zachowanie `{knight}`, `{trade}`, `{yes}` itd. bez tłumaczenia komendy.

Kryterium wyjścia:

- Migrator nie wprowadza błędów logicznych na krytycznych NPC (rook/vocation/heal/trade).

## Etap E3: Skalowanie MIGRATION na całe NPC

Cel:

- Przejście z pilota 1-NPC na batch dla całej kategorii `npc`.

Zakres:

1. Batch migracji z checkpointami i rollbackiem per plik.
2. Twarde stopery krytyczne:
   - brak klucza EN,
   - placeholder/keyword mismatch,
   - artefakty `\z`.
3. Raport dzienny postępu migracji NPC.

Kryterium wyjścia:

- `npc` przechodzi migrację bez krytycznych błędów.

## Etap E4: RESYNC pełny (po stabilizacji migracji)

Cel:

- Domknąć dwie strony synchronizacji.

Zakres:

1. `resync-en`: kod -> EN (drift report: `missing_in_en`, `orphan_in_en`).
2. `resync-lang`: EN -> LANG (`missing_in_lang`).
3. Tryb resync ograniczony do pojedynczego NPC (`npc.<name>.*`) do szybkich testów.

Kryterium wyjścia:

- Brak driftu kluczy dla `npc`.

## Etap E5: TRANSLATION + QUALITY (domknięcie jakości)

Cel:

- Zmniejszyć debt jakościowy i nie przepuszczać krytycznych regresji.

Zakres:

1. Podział tłumaczeń:
   - `translation-fill` (uzupełnianie braków),
   - `translation-repair` (naprawa jakości).
2. QUALITY jako gate:
   - `critical/major/minor`,
   - blokada dalszego etapu na `critical`.
3. Priorytet:
   - domknięcie brakujących kluczy Oressa w 51 językach,
   - naprawa `[EN]` leakage i `\z` dla `npc.json`.
4. PL-first review:
   - osobny quality pass dla PL (zgodnie z obecnymi problemami językowymi).

Kryterium wyjścia:

- Krytyczne klucze gameplay w NPC mają 0 błędów krytycznych.

## Etap E6: DOCUMENTATION mode + finalny interfejs 6 trybów

Cel:

- Dopiero na końcu spinamy operator-friendly obsługę trybów.

Zakres:

1. Odtworzyć osobny `DOCUMENTATION` mode w dispatcherze.
2. Podłączyć `i18n_generate_project_docs.py` do bieżącego loopa.
3. Dodać finalny interfejs 6 trybów (`SCAN/RESYNC/MIGRATION/TRANSLATION/QUALITY/DOCUMENTATION`) oraz `FULL`.
4. Utrzymać domyślny brak trybu jako pełny łańcuch.

Kryterium wyjścia:

- Operator uruchamia jeden tryb lub full chain bez ręcznego obchodzenia pipeline.

---

## 6. Backlog priorytetowy (kolejność wdrożenia)

| ID | Priorytet | Zadanie | Status |
|---|---|---|---|
| B1 | P0 | Odblokować/naprawić MIGRATION dla NPC (bez globalnego rolloutu) | IN PROGRESS |
| B2 | P0 | Wdrożyć single-NPC pipeline testowy (`oressa` jako referencja) | OPEN |
| B3 | P0 | Dodać audyt post-migration jako twardy gate | DONE (pilot NPC, rollback aktywny) |
| B4 | P1 | Domknąć `resync-en` (nie tylko EN->LANG) | OPEN |
| B5 | P1 | Domknąć brakujące klucze Oressa w 51 językach | OPEN |
| B6 | P1 | QUALITY gate: blokada `TRANSLATION` przy `critical` | OPEN |
| B7 | P2 | Reaktywować niezależny `DOCUMENTATION` mode | OPEN |
| B8 | P2 | Dodać finalne CLI 6 trybów (`--mode`) | OPEN (celowo ostatni etap) |

---

## 7. Ryzyka i mitygacje

1. Ryzyko: ponowne błędne mapowanie `say_*`.
   Mitygacja: mapping semantyczny + reuse po EN + single-NPC gate przed batch.

2. Ryzyko: przepchnięcie tłumaczeń z błędnymi keywordami NPC.
   Mitygacja: keyword parity jako `critical`.

3. Ryzyko: fałszywy progres przez `[EN]` i artefakty.
   Mitygacja: KPI jakości nie liczy `[EN]` jako genuine.

4. Ryzyko: dokumentacja opisuje stan „idealny”, a kod działa inaczej.
   Mitygacja: reconciliation na starcie każdej iteracji + źródło prawdy w status JSON.

---

## 8. TODO do dalszej analizy (jawnie odłożone)

Z uwagi na rozmiar workera i narzędzi (dziesiątki tysięcy linii), poniższe tematy zostają jawnie oznaczone do osobnej analizy:

- pełna analiza wpływu `pending_skip/backoff` na jakość przejść między fazami,
- dokładna integracja telemetryczna `i18n/status/*` vs `I18N_STATUS.md` vs `i18n_file_status.json`,
- finalna decyzja o roli `COMPACT_KEYS` względem łańcucha 6 trybów,
- strategia tłumaczeń języków pokrewnych (pivot language, np. słowiańskie z PL) z testami jakości A/B,
- pełna mapa runtime commandów (`FOCUS`, `SWITCH`, `LANGVAL`, `GRAMMARFIX`) do nowego modelu 6 trybów.

---

## 9. Decyzja operacyjna na teraz

Priorytetem pozostaje migracja NPC i stabilizacja gameplay (`Rook`, `healing`, wybór profesji, dialogi krytyczne).  
Interfejs finalny 6 trybów (`--mode ...`) robimy dopiero po domknięciu poprawnego działania wszystkich etapów.

---

## 10. Update wdrożeniowy 2026-02-23 (bridge do modelu 6 trybów, scope NPC)

W tej iteracji dodano operacyjny bridge pod wymagany model 6 trybów, ale tylko dla domeny NPC:

- `--npc-full [N]`:
  - uruchamia pełny pipeline dla NPC bez konieczności ręcznego sklejania komend;
  - domyślnie wyłącza dokumentację (`NPC_DOCUMENTATION_ENABLED=false`) zgodnie z aktualnym priorytetem migracja+translation;
- `stage_3_or_skip`:
  - etap dokumentacji jest jawnie oznaczany jako `skipped` w `i18n_file_status.json` (integralność statusu);
- `stage_6`:
  - działa jako rzeczywiste `TRANSLATION` (status `6_translation`, nie `6_placeholder`);
  - sync/resync i realne tłumaczenia są rozdzielone i raportowane;
  - domyślne języki dla ścieżki NPC: `pl`, `ru`;
- `AUTO_TRANSLATE`:
  - dodany scope kluczy (`AUTO_TRANSLATE_KEY_PREFIXES`) pozwala tłumaczyć tylko `npc.<safe>.*` dla bieżącego NPC.

Walidacja wykonania:

- `captain_dreadnought.lua` przetworzony przez `--file` z `NPC_DOCUMENTATION_ENABLED=false`:
  - `overall_status=completed`,
  - `3_documentation=skipped`,
  - `6_translation.real_translation_languages_done=["pl","ru"]`,
  - `6_translation.real_translation_totals.translated=66`,
  - `validation_passed=true`.

Wpływ na plan 6 trybów:

- `SCAN`: bez zmian.
- `RESYNC`: w scope NPC działa per-prefiks (`npc.<safe>.*`) w stage6.
- `MIGRATION`: bez zmian (nadal priorytet główny).
- `TRANSLATION`: podniesione do realnego etapu w ścieżce `--file`/`--npc-full` (PL/RU).
- `QUALITY`: częściowo, bo `suspicious_high` jest logowane, ale nie blokuje completion.
- `DOCUMENTATION`: świadomie wyłączana w `--npc-full`, zgodnie z decyzją migration-first.

Otwarte do dalszej analizy:

- czy `suspicious_high` dla NPC ma stać się blokadą (`critical gate`) czy tylko triggerem kolejki `translation_repair`;
- kiedy przełączyć `--npc-full` z domyślnego PL/RU na pełny zestaw języków po domknięciu jakości.

---

## 11. Update 2026-02-24 (SCAN: pełny audit typów migracji server+instalka)

Wdrożono i podłączono do workera pełny audit wzorców key-insertion:

- tool: `canary_test/tools/i18n_migration_pattern_audit.py`
- worker mode: `i18n_worker_simple.sh --pattern-audit [server|full|all]`
- raport: `Dokumentacja/serwer/2026-02-24_worker_migration_pattern_audit_server_instalka.md`

Snapshot metryk:

- `server`: `files_scanned=5736`, `hits_total=15413`, `unsupported=15135` (`98.2%`)
- `full`: `files_scanned=6652`, `hits_total=17586`, `unsupported=15231` (`86.61%`)

Wniosek dla modelu 6 trybów:

- `SCAN` ma teraz twardą inwentaryzację wszystkich wykrytych typów migracji i backlog per plik,
- następna iteracja to rozszerzenia `MIGRATION` wg priorytetów z raportu (concat/dynamic, C++, XML policy, OTUI attrs),
- tłumaczenia (`TRANSLATION`) pozostają etapem po domknięciu krytycznych luk migracyjnych.

---

## 12. Update 2026-02-24 (P1: concat/dynamic parser w migratorach Lua)

Zrealizowano pierwszy krok rozszerzenia `MIGRATION`:

- `tools/i18n_migrate_lua_sendtext.py`:
  - obsługa konkatenacji `..` -> key + `args`,
  - normalizacja `\\z`/whitespace.
- `tools/i18n_migrate_lua_say.py`:
  - obsługa konkatenacji `..` -> `:sayLocalized(...)` / `npcHandler:sayLocalized(...)` z `args`.
- `tools/i18n_migrate_lua_broadcast.py`:
  - obsługa konkatenacji `..` -> `Game.broadcastLocalizedMessage(..., args)`,
  - poprawka regresji (`Game.Game.broadcastLocalizedMessage`).

Weryfikacja line-by-line została wykonana na fizycznych plikach staging z kopiami realnych NPC (`hireling`, `klom_stonecutter`) oraz fixture dla `say`/`broadcast`.

Stan po `P1`:

- domknięte: literal + `string.format` + concat (literal+dynamic),
- otwarte: pure dynamic bez literalu (wymaga osobnego gate/polityki).

---

## 13. Update 2026-02-24 (P2: OTUI visible attrs + tr(dynamic) policy)

Zrealizowano `P2` w ścieżce OTClient/UI:

- `tools/i18n_migrate_otclient_otui_text.py`:
  - migracja literalnych atrybutów widocznych:
    - `text`, `tooltip`, `title`, `description`, `placeholder`, `label`,
    - także warianty z `!` (`!text`, `!tooltip`...).
- `tools/i18n_migrate_otclient_tr.py`:
  - dodany raport `dynamic tr` (`--dynamic-report`) do manual review,
  - `tr(dynamic)` pozostaje niemigrowane automatycznie (bezpieczny gate).
- `i18n_worker_simple.sh`:
  - OTUI migrator uruchamiany dla `.otui/.otmod/.otml`,
  - `tr` migrator dostaje ścieżkę raportu:
    - `i18n/status/otclient_tr_dynamic_review.jsonl`.

Weryfikacja line-by-line:

- realny `.otmod` z audytu (`language_picker_override.otmod`) został poprawnie zmigrowany (`description -> tr('key')`),
- fixture OTUI potwierdził poprawną migrację wszystkich nowych atrybutów,
- fixture + realny `option_healthcircle.otui` potwierdziły poprawne logowanie `tr(dynamic)` do kolejki review.

Wpływ na 6 trybów:

- `MIGRATION` (UI): rozszerzone pokrycie (OTUI attrs poza `text`),
- `QUALITY`: jawna kolejka manual-review dla `otclient_tr_dynamic` zamiast ryzykownej automigracji.

---

## 14. Update 2026-02-24 (P3 XML: items.xml range-aware resync)

Wdrożono P3 dla XML z naciskiem na największy backlog (`items.xml`):

- nowy tool: `tools/i18n_resync_items_xml.py`
  - obsługa `id` oraz `fromid..toid` (range-aware),
  - poprawna ekstrakcja `item.<id>.name` dla zakresów,
  - opisy `#i18n:*` nie są zapisywane jako literal do EN JSON,
  - repair istniejących aliasów markerów w `i18n/en/items.json` (`item.*.desc` z wartością `#i18n:*` -> realny EN tekst, jeśli możliwe),
  - tryb `--check-only` do szybkiego gate w dispatcherze.
- worker:
  - `process_items_category` używa teraz `tools/i18n_resync_items_xml.py` zamiast starego parsera inline.
  - `count_files_needing_work(items)` w dispatcherze korzysta z `--check-only` (spójna logika detect/resync).
  - `self_check` rozszerzony o obecność nowego narzędzia.

Weryfikacja:

- staging (`items_small.xml`) potwierdził:
  - poprawne dodanie kluczy dla zakresu (`item.200.name`, `item.201.name`, `item.202.name`),
  - brak zapisu markerów `#i18n:*` jako treści EN.
- `--check-only` na realnym `data/items/items.xml` zwraca `__ITEMS_NEEDS_WORK__ 1`, co potwierdza realny backlog XML do domknięcia.

Wpływ:

- `SCAN`: dokładniejsze wykrywanie braków w `items.xml` (bez regresji markerów),
- `RESYNC`: domknięcie najcięższego źródła XML backlogu w sposób bezpieczny dla runtime,
- `MIGRATION`: brak bezpośrednich zmian w `items.xml` (tylko EN JSON), więc niski risk runtime.

---

## 15. Update 2026-02-24 (Run wykonawczy XML: `--items-full` / `--xml-full`)

Wykonano realny run workera na produkcyjnych danych XML:

- komenda: `bash i18n_worker_simple.sh --items-full`
- nowy tryb one-shot: `--items-full` (alias: `--xml-full`)
- przebieg:
  - resync `items.xml` -> `i18n/en/items.json`,
  - sync struktury EN -> `pl/items.json`, `ru/items.json`,
  - auto-translate dla items domyślnie wyłączony (`ITEMS_REAL_TRANSLATION_ENABLED=false`).

Wynik runu:

- `Items: +20499` nowych kluczy EN (`items processed: 2606`, `repaired=163`),
- sync:
  - `pl/items.json: +19734`,
  - `ru/items.json: +20154`,
- finalnie:
  - `en/items.json = 36733`,
  - `pl/items.json = 36733`,
  - `ru/items.json = 36733`.

Twarda walidacja po runie:

- `python3 tools/i18n_resync_items_xml.py --check-only ...` zwraca:
  - `__ITEMS_NEEDS_WORK__ 0`.

Wniosek:

- największy backlog XML (items) jest już nie tylko wspierany capability workera, ale także faktycznie wykonany na danych repo.
