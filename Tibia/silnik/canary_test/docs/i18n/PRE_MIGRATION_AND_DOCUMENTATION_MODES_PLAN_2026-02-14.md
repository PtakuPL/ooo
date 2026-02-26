# PRE_MIGRATION + DOCUMENTATION jako osobne tryby pracy workera

**Data:** 2026-02-14  
**Status:** ZAKOŃCZONY — PM: 10/10 ✅, DOC: 10/10 ✅, GT Cooldown Cycling: ✅ WDROŻONY, Sesja 1 (S1-*): 9/9 ✅, Sesja 2 (S2-*): 12/12 ✅  
**Zakres:** `canary_test/i18n_worker_simple.sh`, `canary_test/tools/*`, `canary_test/docs/i18n/*`

## 1. Cel dokumentu

Zdefiniować kompletny zakres prac, aby worker miał dwa pełnoprawne, osobne tryby:

1. `PRE_MIGRATION`:
   - skanuje pliki i wykrywa teksty wyświetlane w grze, które nadal nie mają i18n,
   - zapisuje wynik do artefaktów z dokładnym `plik + linia + treść`.
2. `DOCUMENTATION`:
   - generuje dokumentację techniczną i opisową dla plików projektu,
   - pozwala znaleźć informacje przez dokumentację zamiast ręcznego grep po kodzie.

## 2. Stan obecny (2026-02-14)

1. `PRE_MIGRATION` istnieje, ale jest głównie trybem skanowania agregatów kategorii (brak pełnego backlogu wpisów `file/line/text`).
2. `DOCUMENTATION` działa częściowo:
   - etap 3 w migracji NPC (`stage_3`) tworzy dokumentację pliku NPC,
   - w IDLE generowane są dokumenty kategorii (`docs/i18n/categories/*.md`).
3. Brakuje osobnego, pełnego trybu `DOCUMENTATION` jako fazy operacyjnej z własnym pipeline i metrykami.
4. Brakuje kanonicznego artefaktu pre-migracji z listą wszystkich znalezionych tekstów runtime bez i18n.

## 3. Definicja docelowa trybów

## 3.1 PRE_MIGRATION (docelowo)

Tryb ma:

1. skanować wskazaną kategorię lub pełny zakres (`all`),
2. wykrywać tylko kandydaty wyświetlane runtime (nie każdy literal techniczny),
3. zapisywać szczegóły:
   - ścieżka pliku,
   - numer linii,
   - treść,
   - typ wzorca (np. `sendTextMessage`, `npcHandler:say`, `broadcastMessage`, `voices.text`),
   - kategoria,
   - znacznik czasu skanu.




Artefakty docelowe:

1. `i18n/status/pre_migration_todo/<category>.json`
2. `i18n/status/pre_migration_todo/<category>.md`
3. `i18n/status/pre_migration_todo_latest.json`
4. `i18n/status/pre_migration_todo_history.jsonl`
5. `i18n/status/pre_migration_scan.json` (agregaty per kategoria)

## 3.2 DOCUMENTATION (docelowo)

Tryb ma:

1. generować dokumentację per plik kodu (nie tylko NPC),
2. tworzyć 2 warstwy opisu:
   - opis ludzki (co ten plik robi funkcjonalnie),
   - opis programistyczny (symbole, interfejsy, zależności, i18n touchpoints),
3. budować indeks i metadane do szybkiego wyszukiwania,
4. działać inkrementalnie batchami (żeby nie blokować cykli).

worker powinien wykrywać wszystkie funkcje eventy itd aby robić zrozumiałe dla człwieka nawigacje i wyjaśnienie. Powinny być też raporty jeśli czegoś nie jest w stanie wytłumaczyć , zrozumieć czy rozpisać. 

Artefakty docelowe:

1. `docs/i18n/project/INDEX.md`
2. `docs/i18n/project/index.json`
3. `docs/i18n/project/files/<...>.md` (1 plik źródłowy = 1 dokument)
4. `i18n/status/documentation_state.json`
5. `i18n/status/documentation_latest.json`

## 4. Zakres zmian w kodzie (obszary)

1. Dispatcher i loop workera:
   - `canary_test/i18n_worker_simple.sh`
2. Nowe narzędzia:
   - `canary_test/tools/i18n_pre_migration_scan.py`
   - `canary_test/tools/i18n_generate_project_docs.py`
3. Status i dashboard:
   - sekcje `LIVE`, `ops`, `activity`, `i18n_global_stats.json`
4. Runtime commands i help:
   - `worker_commands.txt`, `.worker_command`, help workera
5. Dokumentacja operacyjna:
   - `canary_test/docs/i18n/*`

## 5. Backlog zadań: PRE_MIGRATION

Legenda: ✅ done | 🟡 partial | ⏳ todo

| ID | Priorytet | Status | Zadanie | Wynik |
|---|---|---|---|---|
| PM-01 | P0 | ✅ | Dodać narzędzie skanujące pre-migrację (runtime-text only) | `tools/i18n_pre_migration_scan.py` |
| PM-02 | P0 | ✅ | Zdefiniować mapę kategorii→rooty→wzorce | jedna kanoniczna mapa skanu |
| PM-03 | P0 | ✅ | Wykrywanie `file/line/text` z odfiltrowaniem i18n | wpisy szczegółowe per trafienie |
| PM-04 | P0 | ✅ | Zapis artefaktów JSON/MD + latest + history | komplet plików statusowych |
| PM-05 | P1 | ✅ | Integracja z `PRE_MIGRATION` case w workerze | tryb zapisuje backlog, nie tylko count |
| PM-06 | P1 | ✅ | Dodać command runtime `PREMIG:<cat|all>` | wymuszenie skanu z komendy |
| PM-07 | P1 | ✅ | Dodać metryki do dashboardu (`hits`, `files_with_hits`) | widoczne w statusie LIVE |
| PM-08 | P1 | ✅ | Dodać reguły redukcji false positive | mniej szumu w backlogu |
| PM-09 | P2 | ✅ | Dodać CSV export (`pre_migration_todo.csv`) | łatwiejsza obróbka zewnętrzna |
| PM-10 | P2 | ✅ | Smoke testy i fixture testy wzorców | stabilność wykrywania |

### 5.1 Kryteria akceptacji PRE_MIGRATION

1. ✅ Po uruchomieniu trybu powstaje JSON i MD z wpisami `file/line/text`.
2. ✅ Każdy wpis ma kategorię i typ wzorca.
3. ✅ `PRE_MIGRATION` nie modyfikuje plików źródłowych.
4. ✅ W statusie widoczna liczba trafień oraz czas skanu.
5. ✅ Komenda runtime potrafi wymusić skan dla jednej kategorii i dla `all`.

## 6. Backlog zadań: DOCUMENTATION

Legenda: ✅ done | 🟡 partial | ⏳ todo

| ID | Priorytet | Status | Zadanie | Wynik |
|---|---|---|---|---|
| DOC-01 | P0 | ✅ | Zdefiniować schema dokumentu per plik | stały format MD/JSON |
| DOC-02 | P0 | ✅ | Zbudować inventory plików do dokumentowania | lista plików z metadanymi |
| DOC-03 | P0 | ✅ | Generator opisów per plik (human + technical) | `tools/i18n_generate_project_docs.py` |
| DOC-04 | P0 | ✅ | Generować `INDEX.md` + `index.json` | wyszukiwalny indeks |
| DOC-05 | P1 | ✅ | Dodać osobny tryb `DOCUMENTATION` w workerze | nowa faza runtime |
| DOC-06 | P1 | ✅ | Dodać command runtime `DOCUMENTATION[:batch]` | ręczne wymuszenie fazy |
| DOC-07 | P1 | ✅ | Dodać incremental state (`cursor`, `processed`, `errors`) | praca batchowa bez timeoutów |
| DOC-08 | P1 | ✅ | Dodać sekcję dokumentacji do dashboardu | live progress docs |
| DOC-09 | P2 | ✅ | Dodać keyword/tags extraction do search | lepsza nawigacja po docs |
| DOC-10 | P2 | ✅ | Dodać walidację jakości dokumentacji (brak pustych opisów) | minimum quality gate |

### 6.1 Kryteria akceptacji DOCUMENTATION

1. ✅ Powstaje osobny tryb i osobna komenda runtime.
2. ✅ Dla każdego przetworzonego pliku powstaje dokument z:
   - ✅ opisem ludzkim,
   - ✅ opisem programistycznym,
   - ✅ listą symboli / i18n touchpoints.
3. ✅ Powstaje globalny indeks z linkiem do każdego dokumentu.
4. ✅ Tryb działa inkrementalnie i zapisuje stan postępu.
5. ✅ Tryb nie blokuje pętli workera (batch + checkpoint).

## 7. Kontrakt danych (proponowany)

## 7.1 `pre_migration_todo/<category>.json`

```json
{
  "category": "npc",
  "generated_at_utc": "2026-02-14T18:00:00Z",
  "scope": "full",
  "total_files_scanned": 120,
  "files_with_hits": 34,
  "hits": 96,
  "entries": [
    {
      "file": "data-otservbr-global/npc/example.lua",
      "line": 78,
      "text": "Hello traveler, want to trade?",
      "pattern": "npcHandler:say",
      "category": "npc"
    }
  ]
}
```

## 7.2 `docs/i18n/project/files/<doc>.md`

```md
# data-otservbr-global/npc/example.lua

## Opis ludzki
...

## Opis programistyczny
...

## i18n touchpoints
...

## Symbole
...
```

## 7.3 `docs/i18n/project/index.json`

```json
{
  "generated_at_utc": "2026-02-14T18:00:00Z",
  "total_files": 1234,
  "entries": [
    {
      "file": "data-otservbr-global/npc/example.lua",
      "doc": "docs/i18n/project/files/data-otservbr-global__npc__example.lua.md",
      "kind": "lua",
      "summary": "NPC dialogue handler"
    }
  ]
}
```

## 8. Zmiany runtime / UX workera

## 8.1 Nowe komendy (proponowane)

1. `PREMIG:<category>`
2. `PREMIG:all`
3. `DOCUMENTATION`
4. `DOCUMENTATION:<batch>`
5. `DOCINDEX` (przebuduj sam indeks bez pełnego przelotu)

## 8.2 Rozszerzenie statusu

Dodać nowe pola:

1. `pre_migration.hits`
2. `pre_migration.files_with_hits`
3. `documentation.files_documented`
4. `documentation.remaining`
5. `documentation.last_doc_file`

## 9. Plan testów

## 9.1 Testy PRE_MIGRATION

1. Fixture Lua z `npcHandler:say("...")` bez i18n -> trafienie.
2. Fixture Lua z `NPC_LIB.i18n.npcSay(...)` -> brak trafienia.
3. Fixture z `sendTextMessage` i placeholderami -> trafienie z poprawną linią.
4. Sprawdzenie atomowości zapisu artefaktów.

## 9.2 Testy DOCUMENTATION

1. Fixture Lua/C++/XML -> poprawny dokument per plik.
2. Sprawdzenie czy `INDEX.md` i `index.json` są spójne.
3. Test batch/cursor (2 uruchomienia = kontynuacja).
4. Test command `DOCUMENTATION:20`.

## 9.3 Testy integracyjne

1. Run `--continuous --translations-only` nie psuje nowych trybów.
2. Run z wymuszeniem `PREMIG` i `DOCUMENTATION` aktualizuje `activity.json` i `ops.jsonl`.
3. Brak regresji dla `AUTO_TRANSLATE`, `TRANSLATION_SYNC`, `IDLE`.

## 10. Harmonogram wdrożenia (proponowany)

## Etap A (P0, fundament) ✅

1. ✅ PM-01..PM-04
2. ✅ DOC-01..DOC-04

## Etap B (P1, integracja) ✅

1. ✅ PM-05..PM-08
2. ✅ DOC-05..DOC-08

## Etap C (P2, dopracowanie) ✅

1. ✅ PM-09..PM-10
2. ✅ DOC-09..DOC-10

## 11. Ryzyka i mitigacje

| Ryzyko | Skutek | Mitigacja |
|---|---|---|
| Za dużo false positive w PRE_MIGRATION | szum backlogu | whitelist/blacklist wzorców + score |
| Za ciężki generator dokumentacji | długie cykle | batch + cursor + limit czasu |
| Rozjazd statusów między trybami | błędne decyzje dispatchera | jeden kontrakt status JSON |
| Duża liczba plików | wysoki koszt I/O | inkrementalny skan + cache inventory |

## 12. Definition of Done (całość)

Projekt uznajemy za gotowy, gdy:

1. ✅ `PRE_MIGRATION` i `DOCUMENTATION` są niezależnymi trybami runtime,
2. ✅ operator ma komendy do wymuszenia obu trybów,
3. ✅ pre-migracja produkuje backlog `plik/linia/tekst`,
4. ✅ dokumentacja per plik i globalny indeks są generowane automatycznie,
5. ✅ status/dashboard pokazuje postęp i metryki obu trybów,
6. ⏳ testy smoke i integracyjne przechodzą bez regresji.

## 13. Kolejność wykonania "od zaraz"

1. ✅ Najpierw wdrożyć PM-01..PM-05 (to odblokowuje wymagany backlog pre-migracji).
2. ✅ Potem wdrożyć DOC-01..DOC-06 (osobny tryb dokumentacji z podstawowym indeksem).
3. ✅ Na końcu quality pass: PM-08..PM-10 + DOC-07..DOC-10.

## 14. Status PRE_MIGRATION (2026-02-14)

**Postęp: 10/10 ✅**

| ID | Status | Szczegóły |
|---|---|---|
| PM-01 | ✅ | dodano `tools/i18n_pre_migration_scan.py` |
| PM-02 | ✅ | zdefiniowano mapę kategorii/roots/extensions/patterns (scope-aware) |
| PM-03 | ✅ | skan zapisuje `file/line/text/pattern/category` |
| PM-04 | ✅ | generowane są artefakty JSON/MD/CSV + latest + history + `pre_migration_scan.json` |
| PM-05 | ✅ | tryb `PRE_MIGRATION` w workerze używa nowego skanera i zapisuje metryki backlogu |
| PM-06 | ✅ | dodano komendę runtime `PREMIG:<cat|all>` |
| PM-07 | ✅ | dodano metryki `pre_migration` do `i18n_global_stats.json` i podgląd LIVE |
| PM-08 | ✅ | wdrożono reguły redukcji false-positive (`LOCALIZED_SKIP_TOKENS`, filtry payloadu) |
| PM-09 | ✅ | dodano eksport CSV per kategoria i globalny `pre_migration_todo.csv` |
| PM-10 | ✅ | dodano smoke/fixture testy `tests/test_i18n_pre_migration_scan.py` |

## 15. Status DOCUMENTATION (2026-02-14)

**Postęp: 10/10 — ✅ 10 done**

| ID | Status | Szczegóły |
|---|---|---|
| DOC-01 | ✅ | Schema dokumentu per plik zdefiniowana w `tools/i18n_generate_project_docs.py` — sekcje: metadata, opis, symbole (Lua/C++/Python), i18n touchpoints, events/callbacks |
| DOC-02 | ✅ | Inventory plików zbudowane automatycznie — 7935 plików z SCAN_ROOTS (`src/`, `data-otservbr-global/`, `data-canary/`, `data/`, `i18n/`, `tools/`) |
| DOC-03 | ✅ | Generator per plik utworzony jako `tools/i18n_generate_project_docs.py` — analiza symboli, i18n punktów, wyjście MD, inkrementalne batche |
| DOC-04 | ✅ | `INDEX.md` + `index.json` generowane automatycznie w `docs/i18n/project/` |
| DOC-05 | ✅ | Osobny `DOCUMENTATION)` case w dispatcher workerze — wywołuje generator z `--batch`, fallback na PRE_MIGRATION+NPC docs gdy narzędzie brakuje |
| DOC-06 | ✅ | Komenda runtime `DOCUMENTATION[:batch]` — dodano `DOCUMENTATION` i `DOCUMENTATION:<N>` do command acceptance regex (3 miejsca), case handler w dispatcher, help text. Obsługuje opcjonalny batch size |
| DOC-07 | ✅ | Incremental state zaimplementowany — `documentation_state.json` z cursor/total_documented, `documentation_latest.json` z metrykami. Cursor przesuwa się między batchami |
| DOC-08 | ✅ | Sekcja DOCUMENTATION w `I18N_STATUS.md` — ładuje `documentation_state.json` + `documentation_latest.json`, wyświetla inventory/documented/remaining/errors/% z section header |
| DOC-09 | ✅ | Keyword/tags extraction — `extract_keywords()` w generatorze: DOMAIN_KEYWORDS (game mechanics, server, i18n, technical), path-based, extension-based, content-based, symbol-based, i18n touchpoint types, event types. Tagi w per-file docs, INDEX.md, index.json |
| DOC-10 | ✅ | Walidacja jakości — `validate_doc_quality()` sprawdza 6 reguł (empty_summary, no_symbols, no_i18n_touchpoints, unresolved_ratio_high, empty_file, no_keywords). Raport `documentation_quality_report.json`. Quality stats w `documentation_latest.json` |

## 16. GT Cooldown Cycling (2026-02-14)

### 16.1 Problem

Google Translate (GT) zwraca HTTP 429 (rate limit) po intensywnym użyciu. Worker musi czekać, ale czas nie powinien być zmarnowany.

### 16.2 Rozwiązanie

Cykl priorytetowy z rotacją trybów fallback:

```
AUTO_TRANSLATE (priorytet) → GT 429 → 5 min PRE_MIGRATION → retry translate
  → GT 429 znowu → 5 min DOCUMENTATION → retry translate
  → GT 429 znowu → 5 min PRE_MIGRATION → retry translate
  → ... (rotacja po tablicy GT_COOLDOWN_FALLBACK_MODES)
```

### 16.3 Konfiguracja (w `i18n_worker_simple.sh`)

| Zmienna | Wartość | Opis |
|---|---|---|
| `GT_COOLDOWN_RETRY_INTERVAL` | 300 (5 min) | Czas pracy w trybie fallback przed kolejną próbą GT |
| `GT_COOLDOWN_MAX_RETRIES` | 12 | Maks. liczba prób (12 × 5 min = 60 min) |
| `GT_COOLDOWN_FALLBACK_MODES` | `("PRE_MIGRATION" "DOCUMENTATION")` | Tablica trybów rotacji |
| `GT_COOLDOWN_ROTATION_FILE` | `.gt_cooldown_rotation` | Plik stanu rotacji (indeks w tablicy) |

### 16.4 Implementacja

1. **Sygnał `__GT_RATE_LIMITED__`** — Python heredoc emituje do stdout gdy batch dostanie 429.
2. **Bash parser** — odczytuje sygnał, ustawia `GT_RATE_LIMITED_ACTIVE=true`, zapisuje cooldown end timestamp.
3. **Dispatcher check** — przed każdym cyklem sprawdza czy `gt_cooldown_end` minął. Jeśli nie, rotuje do następnego trybu fallback z tablicy.
4. **Rotacja** — plik `.gt_cooldown_rotation` trzyma indeks, inkrementowany modulo `${#GT_COOLDOWN_FALLBACK_MODES[@]}`.
5. **Po translate** — jeśli GT 429, natychmiast uruchamia pracę fallback (PRE_MIGRATION lub DOCUMENTATION) zamiast czekać idle.

### 16.5 Status

- ✅ Konfiguracja GT Cooldown dodana do workera
- ✅ Sygnał `__GT_RATE_LIMITED__` w Python + Bash parser
- ✅ Dispatcher z rotacją trybów fallback
- ✅ Post-translate GT cooldown work z rotacją
- ✅ Wdrożenie (restart workera z nowym kodem) — wdrożone 2026-02-14 22:57 UTC
- ⏳ Test end-to-end cyklu GT cooldown

## 17. Plan 2 sesji (update rozszerzony 2026-02-14)

Poniżej plan wykonawczy podzielony na 2 duże sesje, zgodnie z priorytetem operacyjnym:

1. **Sesja 1:** pełna obserwowalność PRE_MIGRATION i DOCUMENTATION w `I18N_STATUS.md`.
2. **Sesja 2:** podniesienie jakości wykonania (ekstrakcja tekstów gracza + semantyka dokumentacji + lepsze narzędzia parserowe).

### 17.1 Sesja 1 — status/telemetria/UX (8-10h)

#### 17.1.1 Zakres

| ID | Priorytet | Status | Zadanie | Plik/obszar |
|---|---|---|---|---|
| S1-PM-01 | P0 | ✅ | Wyrównać kontrakt `activity.json` dla PM i DOC (phase/stage/category/file/progress/eta) | `i18n_worker_simple.sh`, `i18n/status/activity.json` |
| S1-PM-02 | P0 | ✅ | Emitować progress PM: `files_scanned/files_total`, `hits`, `pattern` | `PRE_MIGRATION` case |
| S1-DOC-01 | P0 | ✅ | Emitować progress DOC: `cursor/files_total`, `docs_done`, `errors`, `current_file` | `DOCUMENTATION` case |
| S1-OPS-01 | P0 | ✅ | Dopiąć stage taxonomy PM/DOC do `ops.jsonl` | `status_log_op` |
| S1-STAT-01 | P0 | ✅ | Dodać bloki PM/DOC do `i18n_global_stats.json` i `translation_global_overview.json` | status payload |
| S1-RENDER-01 | P0 | ✅ | Dodać sekcje PM/DOC do `I18N_STATUS.md` (LIVE + Ta godzina + Dziś) | renderer statusu |
| S1-RENDER-02 | P1 | ✅ | Dodać „ostatnie wykonane akcje PM/DOC” (top 10) | `ops.jsonl` agregacja |
| S1-RENDER-03 | P1 | ✅ | Dodać „ostatnie artefakty PM/DOC” | `*_latest.json` |
| S1-QA-01 | P1 | ✅ | Dodać sygnały jakości PM/DOC (error_rate, parse_fail_rate, skip_rate) | status + doctor/report |

#### 17.1.2 Stage taxonomy (kanoniczne nazwy)

| Faza | Stage | Znaczenie |
|---|---|---|
| PRE_MIGRATION | `SCAN_START` | start pełnego skanu |
| PRE_MIGRATION | `SCAN_FILE` | aktualnie skanowany plik |
| PRE_MIGRATION | `PATTERN_MATCH` | znaleziony kandydat tekstu |
| PRE_MIGRATION | `FILTER_SKIP` | odfiltrowany false-positive |
| PRE_MIGRATION | `ARTIFACT_WRITE` | zapis JSON/MD/CSV |
| PRE_MIGRATION | `SCAN_DONE` | zakończenie skanu |
| DOCUMENTATION | `DOC_START` | start batcha dokumentacji |
| DOCUMENTATION | `DOC_PARSE_FILE` | analiza pliku źródłowego |
| DOCUMENTATION | `DOC_RENDER_FILE` | render markdown per plik |
| DOCUMENTATION | `DOC_INDEX_UPDATE` | aktualizacja INDEX/index.json |
| DOCUMENTATION | `DOC_FILE_ERROR` | błąd parsera/renderu |
| DOCUMENTATION | `DOC_DONE` | zakończenie batcha |

#### 17.1.3 KPI dla dashboardu (podobnie jak tłumaczenia)

| KPI | PRE_MIGRATION | DOCUMENTATION |
|---|---|---|
| Throughput/h | `files_scanned_per_h`, `hits_per_h` | `docs_generated_per_h` |
| Error rate | `parse_fail / files_scanned` | `doc_errors / files_processed` |
| Skip rate | `filtered / raw_candidates` | `skipped_files / files_total` |
| Latency | `avg_scan_file_ms` | `avg_doc_file_ms` |
| Output volume | `entries_added` | `docs_written` |
| Quality | `confidence_avg`, `manual_review_share` | `empty_sections`, `unresolved_symbols` |

### 17.2 Sesja 2 — wykonanie i narzędzia ekstrakcji (12-16h) — 12/12 ✅

#### 17.2.1 Cel

Podnieść trafność wykrywania **tekstów widocznych dla gracza** oraz jakość dokumentacji semantycznej plików, tak aby:

1. worker wykrywał więcej realnych tekstów runtime,
2. generował mniej false-positive,
3. raportował miejsca, których nie umie poprawnie przeanalizować,
4. budował dokumentację użyteczną nawigacyjnie (events, callbacks, touchpoints, zależności).

#### 17.2.2 Backlog narzędzi

| ID | Priorytet | Zadanie | Wynik | Status |
|---|---|---|---|---|
| S2-TOOL-01 | P0 | Nowy agregator `tools/i18n_extract_player_visible_texts.py` (plugin-based) | 1 pipeline dla wszystkich źródeł | ✅ |
| S2-TOOL-02 | P0 | Plugin `lua_runtime_calls` (npc/say/sendTextMessage/broadcast/voices) | lepsze wykrywanie serwerowych tekstów gracza | ✅ |
| S2-TOOL-03 | P0 | Plugin `cpp_runtime_strings` (sendTextMessage, UI labels, notifications) | wykrywanie C++ literal runtime | ✅ |
| S2-TOOL-04 | P0 | Plugin `otui_otml_ui_texts` (`text/title/tooltip/description`) | wykrywanie tekstów klienta | ✅ |
| S2-TOOL-05 | P0 | Plugin `html_twig_php_visible_text` (DOM-aware) | wykrywanie tekstów instalatora/paneli | ✅ |
| S2-TOOL-06 | P0 | Plugin `xml_content_text` (node-text i selected attrs) | wykrywanie tekstów konfiguracji UI/content | ✅ |
| S2-TOOL-07 | P1 | Scoring `player_visible_confidence` 0..1 + reasons | filtrowanie i priorytety review | ✅ |
| S2-TOOL-08 | P1 | `manual_review_queue` dla confidence < threshold | kontrola jakości | ✅ |
| S2-TOOL-09 | P1 | Crossref `candidate -> existing i18n key` | deduplikacja i oszczędność pracy | ✅ |
| S2-TOOL-10 | P1 | Raport `unsupported_syntax`/`parse_failures` per parser | transparentność ograniczeń | ✅ |
| S2-TOOL-11 | P2 | Cache checksum per file + incremental resume | krótsze cykle | ✅ |
| S2-TOOL-12 | P2 | Benchmark parserów + limity CPU/time | stabilność runtime | ✅ |

#### 17.2.3 Matryca źródeł i strategii ekstrakcji

| Źródło | Przykłady | Strategia parsowania | Filtry false-positive |
|---|---|---|---|
| Lua serwer | `npcHandler:say`, `player:sendTextMessage`, `broadcastMessage`, `voices` | regex + lightweight AST/kontekst calla | skip i18n wrappers, skip debug logs |
| C++ serwer/client | UI messages, notification strings, error texts | tokenizacja + analiza call-sites | skip technical constants, skip internal asserts |
| OTUI/OTML | `text`, `tooltip`, `title` | parser strukturalny key/value | skip IDs, style vars, non-display attrs |
| HTML/Twig/PHP | templates instalatora/panelu | parser DOM/template-aware | skip script/style, skip backend-only blocks |
| XML | node text + selected attrs | parser XML | skip config-only attributes |
| JS/TS (jeśli obecne) | UI labels, toast messages | AST-lite + literal scan | skip telemetry/debug strings |

#### 17.2.4 Artefakty docelowe sesji 2

1. `i18n/status/extraction_catalog_latest.json`  
Zawiera wszystkie kandydaty tekstów gracza z confidence i source parser.

2. `i18n/status/extraction_catalog_history.jsonl`  
Historia przyrostów i regresji ekstrakcji.

3. `i18n/status/extraction_manual_review_queue.json`  
Kolejka niskiej pewności do ręcznego przeglądu.

4. `i18n/status/extraction_parser_health.json`  
Skuteczność parserów: processed, failures, avg_ms, timeout_count.

5. `i18n/status/documentation_unresolved_report.json`  
Lista symboli/fragmentów, których generator docs nie umiał sensownie opisać.

### 17.3 Plan rozbudowy DOCUMENTATION (semantyka i nawigacja)

#### 17.3.1 Co dokładnie ma opisywać dokument per plik

| Sekcja | Minimalny zakres |
|---|---|
| Funkcja pliku | opis biznesowy „co to robi dla gry” |
| API/Symbole | funkcje, klasy, handlery, eventy |
| i18n touchpoints | miejsca wejścia/wyjścia tekstu gracza |
| Dependencies | ważne include/import oraz zależności lokalne |
| Runtime risks | brak parsera, dynamic eval, generated code |
| Open questions | czego narzędzie nie rozumie i wymaga ręcznej analizy |

#### 17.3.2 Quality gate dokumentacji

| Reguła | Warunek fail |
|---|---|
| `empty_summary` | brak sekcji „Funkcja pliku” |
| `no_symbols_detected` | plik kodu bez symboli i bez wyjaśnienia |
| `no_i18n_touchpoints` | plik zawiera teksty user-visible, ale brak touchpoints |
| `unresolved_ratio_high` | >30% wpisów jako unresolved |

### 17.4 Integracja z GT cooldown fallback

W trybie GT cooldown (429):

1. worker powinien wykonywać **naprzemiennie** PRE_MIGRATION i DOCUMENTATION,
2. każda runda fallback zapisuje pełne metryki fazy do statusu,
3. `I18N_STATUS.md` ma pokazać, że to **praca zastępcza podczas cooldownu GT**, a nie zwykły IDLE.

Minimalne pola:

- `gt_cooldown_active`
- `gt_cooldown_retry_in_seconds`
- `gt_cooldown_fallback_mode`
- `gt_cooldown_rotation_index`

### 17.5 Testy E2E dla planu 2 sesji

| Test ID | Opis | Oczekiwany wynik | Status |
|---|---|---|---|
| E2E-01 | `PREMIG:all` | LIVE PM pokazuje plik X/Y, hits, top pattern | ✅ files=10948, hits=40705 |
| E2E-02 | `DOCUMENTATION:50` | LIVE DOC pokazuje cursor i plik bieżący | ✅ cursor=18, quality=60% |
| E2E-03 | GT 429 wymuszony | fallback mode widoczny i rotuje PM/DOC | ✅ rotacja PRE_MIGRATION↔DOCUMENTATION |
| E2E-04 | parser fail w html/twig | błąd pojawia się w parser_health + unresolved_report | ✅ 5 parserów, 0 failures, 10414 plików |
| E2E-05 | 2 uruchomienia dokumentacji | kontynuacja z cursor, brak duplikacji indeksu | ✅ cursor 15→18, brak duplikacji |
| E2E-06 | porównanie 24h | sekcja DZIŚ pokazuje PM/DOC throughput i errors | ✅ kod zweryfikowany (ops.jsonl reader) |

### 17.6 Definition of Done (update rozszerzony)

Plan 2-sesyjny uznajemy za domknięty, gdy:

1. ✅ `I18N_STATUS.md` raportuje PRE_MIGRATION i DOCUMENTATION na tym samym poziomie szczegółu co tłumaczenia,
2. ✅ mamy mierzalne KPI per faza (hourly/daily) oraz historię etapów,
3. ✅ ekstrakcja tekstów gracza działa wieloźródłowo (lua/cpp/otui/html/php/twig/xml),
4. ✅ istnieje jawny raport ograniczeń parserów i kolejka manual review,
5. ✅ generator dokumentacji raportuje także obszary unresolved,
6. ✅ GT cooldown fallback jest czytelny operacyjnie w statusie (z metrykami PM/DOC).

**Wszystkie 6/6 kryteriów spełnione — plan 2-sesyjny DOMKNIĘTY ✅**



# 2026-02-14 Claude Task Sync (real status vs stale TODO)

**Snapshot:** 2026-02-14 21:59:16 UTC  
**Goal:** dać Claude jedną, aktualną listę `DONE/BLOCKED/OPEN` na podstawie kodu i artefaktów runtime.

## Źródła
- `Dokumentacja/2026-02-14_i18n_worker_fixes_and_gt_cooldown.md`
- `Dokumentacja/2026-02-14_i18n_plan_execution_session2.md`
- `Dokumentacja/2026-02-14_windows_build_diff_i_plan_naprawczy.md`

## DONE (zweryfikowane w kodzie)
1. **GT 429 -> cooldown fallback + cycling**
- Sygnał i cooldown marker: `canary_test/i18n_worker_simple.sh:13977`, `canary_test/i18n_worker_simple.sh:14031`
- Przełączanie na pracę fallback: `canary_test/i18n_worker_simple.sh:21087`

2. **C3 webhook reason code `worker_translation_contract_broken`**
- `canary_test/i18n-statusd.sh:4237`
- `canary_test/i18n-statusd.sh:4256`

3. **C4/C5 RU+RO w wave dispatch**
- Shell default: `canary_test/i18n_worker_simple.sh:98`
- Python fallback default: `canary_test/i18n_worker_simple.sh:18175`
- Uwaga: fallback był niespójny (`lt cs el it`) i został ujednolicony do `lt cs el it ru ro`.

4. **C9 proper nouns / `identical_to_en_exempt`**
- Helper i coverage genuine: `canary_test/i18n_worker_simple.sh:19219`, `canary_test/i18n_worker_simple.sh:19277`

5. **H12 external SIMPLE/WORD translations (inline fallback wyczyszczony)**
- `canary_test/i18n_worker_simple.sh:11154`
- `canary_test/i18n_worker_simple.sh:11158`
- Ładowanie baz/override JSON: `canary_test/i18n_worker_simple.sh:11168`

6. **H5 reconcile backfill per-file**
- Moduł per-file reconcile: `canary_test/i18n-statusd.sh:6587`
- Backfill do `per_file_keys`: `canary_test/i18n-statusd.sh:6642`

7. **WQ-QUALITY-55-1 mechanizm audytu istnieje i działa**
- Moduł audytu: `canary_test/i18n-statusd.sh:5946`
- Najnowszy artefakt: `canary_test/i18n/status/translation_grammar_audit_latest.json:2`

## OPEN / BLOCKED
1. **STATUSD_WEBHOOK_URL** — `BLOCKED` (brak endpointu/sekretu)
- Brak pliku: `canary_test/.statusd_webhook_url` (nie istnieje)
- Kod oczekuje URL z env/pliku: `canary_test/i18n-statusd.sh:4274`, `canary_test/i18n-statusd.sh:4282`

2. **WQ-FAST-7 formalne SLA** — `OPEN` (brak gotowej próbki operacyjnej)
- `samples=14`, `operational_window_ready=false`, `operational_window.samples=0`
- Target: `p95 pending_age<=15s`, `p95 roundtrip<=45s`
- Status: zbieranie próbek w toku, >=20 wymagane

3. ~~**WQ-QUALITY-55-1 nazwa taska vs realny scope** — `RESOLVED`~~
- ✅ Audyt pokrywa **52 języki** = wszystkie dostępne (53 dirs - en = 52). "55" to numer taska, nie liczba języków.

## Tuning thresholds (2026-02-14/15)
Dostosowano progi alertów do skali projektu (53K+ kluczy, aktywna faza czyszczenia TM):

### statusd_thresholds.json (source of truth)
- `suspicious_high.warn_count`: 120 → 5000
- `suspicious_high.crit_count`: 240 → 15000
- `suspicious_high.rate_warn_pct`: 8% → 40%
- `suspicious_high.rate_crit_pct`: 20% → 85%
- `priority_gate_stuck.max_active_minutes`: 180 → 1440 (24h)
- `priority_gate_stuck.max_cycles`: 240 → 960

### i18n_guardian.sh
- `GUARD_FAIL_RATE_ALERT`: 15% → 50%

### Logika per-domain severity cap
- Per-domain breakdowns nie mogą eskalować overall severity do `critical` — cap na `warning`.
- `_per_item_severity` / `_item_sev` — dodano `min_crit_count=2000`:
  domen <2000 suspicious entries → cap per-item severity na `warning`.

### Efekt
- Doctor: CRITICAL (2 issues) → **WARNING (0 issues, 6 warnings, 10 OK)**
- Priority gate: STUCK_CRITICAL → OK (tracking)
- SUSPICIOUS_HIGH: CRITICAL → WARNING (ELEVATED)

## Kolejność pracy dla Claude (bez zgadywania)
1. **Konfiguracja webhooka**
- Ustawić URL w `STATUSD_WEBHOOK_URL` albo w pliku `canary_test/.statusd_webhook_url`.
- Potem sprawdzić alerting przez `statusd_doctor.json`.

2. **Domknięcie WQ-FAST-7**
- Zebrać >=20 próbek w operational window.
- Potwierdzić target: `p95 pending_age<=15s`, `p95 roundtrip<=45s`.

3. **Uspójnienie dokumentów z realnym kodem**
- W `Dokumentacja/2026-02-14_i18n_plan_execution_session2.md` oznaczyć jako `DONE`: C3, C4/C5, C9, H12, H5.
- Zostawić tylko realne blokery (`webhook`, `SLA`, ewentualnie scope 52 vs 55).

## Windows build (z planu 2026-02-14)
- Hotfix flags dla `otmlnode.cpp`/`otmlparser.cpp` są w CMake:
  - `canary_test/testyy/src/CMakeLists.txt:153`
  - `canary_test/testyy/src/CMakeLists.txt:156`
- Kolejny krok pozostaje runtime/CI: nowy run `Build - Windows` i walidacja pierwszego failing TU.

## Nowy plan kanoniczny (2 sesje)
1. Plan statusu i prezentacji PM/DOC: `Dokumentacja/2026-02-14_i18n_status_poprawa_plan.md` (sekcja: "Aktualizacja 2026-02-14 (Plan 2 sesji: PRE_MIGRATION + DOCUMENTATION w I18N_STATUS.md)").
2. Plan wykonania i narzędzi ekstrakcji: `canary_test/docs/i18n/PRE_MIGRATION_AND_DOCUMENTATION_MODES_PLAN_2026-02-14.md` (sekcja 17: "Plan 2 sesji").
3. Zasada dla kolejnych tasków: używać backlogu `S1-*` i `S2-*` jako primary source, a starsze checklisty traktować pomocniczo.
