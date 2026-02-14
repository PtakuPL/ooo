# PRE_MIGRATION + DOCUMENTATION jako osobne tryby pracy workera

**Data:** 2026-02-14  
**Status:** PLAN WYKONAWCZY (przed implementacją)  
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

| ID | Priorytet | Zadanie | Wynik |
|---|---|---|---|
| PM-01 | P0 | Dodać narzędzie skanujące pre-migrację (runtime-text only) | `tools/i18n_pre_migration_scan.py` |
| PM-02 | P0 | Zdefiniować mapę kategorii→rooty→wzorce | jedna kanoniczna mapa skanu |
| PM-03 | P0 | Wykrywanie `file/line/text` z odfiltrowaniem i18n | wpisy szczegółowe per trafienie |
| PM-04 | P0 | Zapis artefaktów JSON/MD + latest + history | komplet plików statusowych |
| PM-05 | P1 | Integracja z `PRE_MIGRATION` case w workerze | tryb zapisuje backlog, nie tylko count |
| PM-06 | P1 | Dodać command runtime `PREMIG:<cat|all>` | wymuszenie skanu z komendy |
| PM-07 | P1 | Dodać metryki do dashboardu (`hits`, `files_with_hits`) | widoczne w statusie LIVE |
| PM-08 | P1 | Dodać reguły redukcji false positive | mniej szumu w backlogu |
| PM-09 | P2 | Dodać CSV export (`pre_migration_todo.csv`) | łatwiejsza obróbka zewnętrzna |
| PM-10 | P2 | Smoke testy i fixture testy wzorców | stabilność wykrywania |

### 5.1 Kryteria akceptacji PRE_MIGRATION

1. Po uruchomieniu trybu powstaje JSON i MD z wpisami `file/line/text`.
2. Każdy wpis ma kategorię i typ wzorca.
3. `PRE_MIGRATION` nie modyfikuje plików źródłowych.
4. W statusie widoczna liczba trafień oraz czas skanu.
5. Komenda runtime potrafi wymusić skan dla jednej kategorii i dla `all`.

## 6. Backlog zadań: DOCUMENTATION

| ID | Priorytet | Zadanie | Wynik |
|---|---|---|---|
| DOC-01 | P0 | Zdefiniować schema dokumentu per plik | stały format MD/JSON |
| DOC-02 | P0 | Zbudować inventory plików do dokumentowania | lista plików z metadanymi |
| DOC-03 | P0 | Generator opisów per plik (human + technical) | `tools/i18n_generate_project_docs.py` |
| DOC-04 | P0 | Generować `INDEX.md` + `index.json` | wyszukiwalny indeks |
| DOC-05 | P1 | Dodać osobny tryb `DOCUMENTATION` w workerze | nowa faza runtime |
| DOC-06 | P1 | Dodać command runtime `DOCUMENTATION[:batch]` | ręczne wymuszenie fazy |
| DOC-07 | P1 | Dodać incremental state (`cursor`, `processed`, `errors`) | praca batchowa bez timeoutów |
| DOC-08 | P1 | Dodać sekcję dokumentacji do dashboardu | live progress docs |
| DOC-09 | P2 | Dodać keyword/tags extraction do search | lepsza nawigacja po docs |
| DOC-10 | P2 | Dodać walidację jakości dokumentacji (brak pustych opisów) | minimum quality gate |

### 6.1 Kryteria akceptacji DOCUMENTATION

1. Powstaje osobny tryb i osobna komenda runtime.
2. Dla każdego przetworzonego pliku powstaje dokument z:
   - opisem ludzkim,
   - opisem programistycznym,
   - listą symboli / i18n touchpoints.
3. Powstaje globalny indeks z linkiem do każdego dokumentu.
4. Tryb działa inkrementalnie i zapisuje stan postępu.
5. Tryb nie blokuje pętli workera (batch + checkpoint).

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

## Etap A (P0, fundament)

1. PM-01..PM-04
2. DOC-01..DOC-04

## Etap B (P1, integracja)

1. PM-05..PM-08
2. DOC-05..DOC-08

## Etap C (P2, dopracowanie)

1. PM-09..PM-10
2. DOC-09..DOC-10

## 11. Ryzyka i mitigacje

| Ryzyko | Skutek | Mitigacja |
|---|---|---|
| Za dużo false positive w PRE_MIGRATION | szum backlogu | whitelist/blacklist wzorców + score |
| Za ciężki generator dokumentacji | długie cykle | batch + cursor + limit czasu |
| Rozjazd statusów między trybami | błędne decyzje dispatchera | jeden kontrakt status JSON |
| Duża liczba plików | wysoki koszt I/O | inkrementalny skan + cache inventory |

## 12. Definition of Done (całość)

Projekt uznajemy za gotowy, gdy:

1. `PRE_MIGRATION` i `DOCUMENTATION` są niezależnymi trybami runtime,
2. operator ma komendy do wymuszenia obu trybów,
3. pre-migracja produkuje backlog `plik/linia/tekst`,
4. dokumentacja per plik i globalny indeks są generowane automatycznie,
5. status/dashboard pokazuje postęp i metryki obu trybów,
6. testy smoke i integracyjne przechodzą bez regresji.

## 13. Kolejność wykonania "od zaraz"

1. Najpierw wdrożyć PM-01..PM-05 (to odblokowuje wymagany backlog pre-migracji).
2. Potem wdrożyć DOC-01..DOC-06 (osobny tryb dokumentacji z podstawowym indeksem).
3. Na końcu quality pass: PM-08..PM-10 + DOC-07..DOC-10.

## 14. Status PRE_MIGRATION (2026-02-14)

Zrealizowane zadania PM:

1. `PM-01` DONE: dodano `tools/i18n_pre_migration_scan.py`.
2. `PM-02` DONE: zdefiniowano mapę kategorii/roots/extensions/patterns (scope-aware).
3. `PM-03` DONE: skan zapisuje `file/line/text/pattern/category`.
4. `PM-04` DONE: generowane są artefakty JSON/MD/CSV + latest + history + `pre_migration_scan.json`.
5. `PM-05` DONE: tryb `PRE_MIGRATION` w workerze używa nowego skanera i zapisuje metryki backlogu.
6. `PM-06` DONE: dodano komendę runtime `PREMIG:<cat|all>`.
7. `PM-07` DONE: dodano metryki `pre_migration` do `i18n_global_stats.json` i podgląd LIVE.
8. `PM-08` DONE: wdrożono reguły redukcji false-positive (`LOCALIZED_SKIP_TOKENS`, filtry payloadu).
9. `PM-09` DONE: dodano eksport CSV per kategoria i globalny `pre_migration_todo.csv`.
10. `PM-10` DONE: dodano smoke/fixture testy `tests/test_i18n_pre_migration_scan.py`.
