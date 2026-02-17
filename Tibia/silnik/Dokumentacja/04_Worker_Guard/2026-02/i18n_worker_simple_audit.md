# Audyt: `i18n_worker_simple.sh` (worker i18n) — przegląd nieprawidłowości i rekomendacji

Data: 2025-12-17  
Plik: `i18n_worker_simple.sh`  
Liczba linii: 8086  
SHA256 pliku (dla stabilności numerów linii): `26b78b14ceff5e7bb42ec4bf155aee528627ad8b68c9d604338dd8a52d3dd526`

## Cel dokumentu

To jest **audyt statyczny** skryptu `i18n_worker_simple.sh` pod kątem:
- błędów logicznych i ryzyk “pending_skip / zero-work”,
- kruchych miejsc (Bash + Python heredoc),
- utraty danych statusu,
- bezpieczeństwa/odporności (race conditions, brak locków, atomowość zapisu),
- jakości kodu (duplikacje, “magic numbers”, rozjazdy konfiguracji),
- rzeczy do poprawy lub dodania, wraz z **konkretnymi numerami linii**.

> Uwaga: numery linii odnoszą się do pliku o powyższym SHA256. Po zmianach w skrypcie numery mogą się przesunąć.

---

## Aktualizacja audytu (2026-02-12)

W najnowszych zmianach workera wdrożono dodatkowo:

- tryb `--translations-only` jako strict (bez dodawania nowych kluczy i bez tworzenia brakujących plików),
- priorytetyzację tłumaczeń dla braków EN→LANG i EN-copy,
- raporty blokad/guardów (`translation_guard_*`, `translation_blockers_*`),
- historię ostatnich tłumaczeń (`translation_recent_*`),
- globalny przegląd języków (`translation_global_overview.json`) oraz rozszerzone sekcje statusu LIVE.

Te zmiany nie zamykają audytu całościowego; pozostaje temat pełnej normalizacji metryk statusu i spójnego jednego źródła prawdy dla liczników EN/coverage.

## Aktualizacja audytu (2026-02-12, Faza 4 — cross-reference)

W `run_full_lang_validation()` wdrożono pipeline cross-referencing EN↔PL↔LANG:

- consistency check w obrębie języka (wykrywanie wielu tłumaczeń dla tego samego EN),
- PL-reference check (flagowanie EN-copy w LANG, gdy PL ma sensowne tłumaczenie),
- length-ratio cross-check (odchylenie ratio LANG/EN względem PL/EN).

Wyniki są zapisywane per język do `i18n/status/validation/{lang}_crossref.json`, a agregacja trafia do `i18n/status/validation/summary.json` (`crossref_issues` per język + `crossref_total_issues`).

Weryfikacja po wdrożeniu (krótki run `:ONCE`):
- wygenerowano raporty `*_crossref.json` dla 52 języków,
- `summary.json` zawiera `crossref_total_issues` (aktualny snapshot: `24609`),
- worker kończy cykl poprawnie i nie wywraca walidacji per-język.

## Aktualizacja audytu (2026-02-12, Faza 4.5 + Faza 6)

Wdrożono flagowany Tryb 2 auto-fix dla cross-reference:

- nowe flagi runtime: `--auto-fix-crossref` i `--auto-fix-crossref-limit N` (domyślnie OFF),
- aktywacja tylko z `--use-gt` i tylko dla języków z coverage `>=30%` (`lang != pl`),
- auto-fix dotyczy oczywistych EN-copy z PL-reference i zapisuje wynik z metrykami `attempted/applied/skipped/errors` do `validation/{lang}_crossref.json`.

Rozszerzenia raportów walidacji (sekcja 6):

- `validation/summary.json` zawiera teraz `crossref_autofix_total_applied`,
- parser logu walidacji zwraca dodatkowo `crossref_autofix=...`, aby sygnalizować zastosowane poprawki.

Weryfikacja runtime:

- uruchomiono bounded test `timeout 40s` z `--auto-fix-crossref --auto-fix-crossref-limit 1`,
- worker poprawnie rozpoznał flagi i uruchomił cykl bez awarii,
- pełny przebieg walidacji 52 języków nie zamknął się w 40s (oczekiwane dla krótkiego okna testowego).

## Aktualizacja audytu (2026-02-13, runtime switch + readiness)

Wdrożono sterowanie językiem w trakcie działania workera (na granicy cyklu):

- `SWITCH:<lang>[:json[:limit]]` — natychmiastowe przełączenie i przypięcie języka AUTO_TRANSLATE na kolejne cykle,
- `UNSWITCH` — zdjęcie przypięcia,
- `LANGVAL:all|<lang>` — wymuszenie walidacji języków po bieżącym cyklu,
- CLI: `--lang-validate <lang>` i `--lang-validate-all`.

Weryfikacja runtime:

- test `SWITCH:ru:npc.json:1:ONCE` (40s) potwierdził przełączenie dispatchera na RU i wykonanie AUTO_TRANSLATE,
- dodano raport gotowości języków przed runem nocnym: `tools/i18n_language_readiness_report.py` generuje `i18n/status/language_readiness.md`.

---

## TL;DR — najważniejsze problemy do naprawy (kolejność sugerowana)

### Krytyczne
1. **Utrata danych statusu pliku**: `mark_file_completed()` nadpisuje cały wpis w `i18n_file_status.json`, kasując etapy 1–8 zapisane wcześniej (m.in. dla NPC).  
   - Lokalizacja: `i18n_worker_simple.sh:155`, `i18n_worker_simple.sh:187`, wywołanie w NPC pipeline: `i18n_worker_simple.sh:2955`.  
   - Skutek: dashboard i logika “co było zrobione” tracą szczegóły, a debug staje się losowy.
2. **Błędne logowanie kodu błędu w mini‑batch**: `run_with_mini_batch()` zapisuje `rc=$?` po `if ! cmd; then`, więc `rc` będzie **0** mimo błędu.  
   - Lokalizacja: `i18n_worker_simple.sh:355`, `i18n_worker_simple.sh:361`.
3. **Walidacja Lua używa złego narzędzia**: `validate_lua_file()` próbuje `lua -p`, a standardowe `lua` zwykle nie ma opcji `-p` (to jest typowo `luac -p`).  
   - Lokalizacja: `i18n_worker_simple.sh:231`.  
   - Skutek: w środowisku z `lua` może błędnie przywracać backupy mimo poprawnego Lua.
4. **Krucha integracja Bash→Python**: w kilku heredocach Python dostaje “wstrzyknięty” goły `$VAR` poza stringiem (np. `data['total_cycles'] = $CYCLE`). Jeśli zmienna jest pusta / nienumeryczna → **SyntaxError** w Pythonie i cichy brak zapisu.  
   - Lokalizacja: `i18n_worker_simple.sh:260` (CATSTATEPY), `i18n_worker_simple.sh:3234` (ITEMSPY), `i18n_worker_simple.sh:7917` (SAVEPY).
5. **`process_items_category()` wygląda na logicznie zepsute**: ma podwójną ścieżkę dodawania itemów (heredoc `ITEMSPY` + osobny `python3 -c`), niespójne “skip”, potencjalne podwójne dodawanie i mylące liczenie `added`.  
   - Lokalizacja: `i18n_worker_simple.sh:3234`–`i18n_worker_simple.sh:3287`.

### Wysoki priorytet
6. **Niebezpieczny `eval`** w `get_unprocessed_files()`.  
   - Lokalizacja: `i18n_worker_simple.sh:147`.  
   - Skutek: ryzyko wykonania dowolnego kodu jeśli `find_args` kiedykolwiek będzie pochodzić z zewnątrz.
7. **Stały DEBUG do `/tmp`**: `stage_4()` zawsze dopisuje log do `/tmp/i18n_debug.log`.  
   - Lokalizacja: `i18n_worker_simple.sh:2426`, `i18n_worker_simple.sh:2429`.  
   - Skutek: długotrwała praca → rosnący plik i spowolnienie.
8. **Niepoprawne/przestarzałe konstrukcje `head -$batch`** (i brak walidacji, że `batch` jest liczbą).  
   - Lokalizacje: m.in. `i18n_worker_simple.sh:3150`, `i18n_worker_simple.sh:3201`, `i18n_worker_simple.sh:4191`.

---

## Indeks funkcji (dla orientacji)

Poniżej lista funkcji i linie startu (przydatne do nawigacji w pliku):

| Linia | Funkcja |
|---:|---|
| 48 | `status_update_activity()` |
| 79 | `status_log_op()` |
| 106 | `status_log_error()` |
| 124 | `status_build_daily()` |
| 142 | `get_unprocessed_files()` |
| 155 | `mark_file_completed()` |
| 217 | `log()` |
| 222 | `restore_backup_file()` |
| 231 | `validate_lua_file()` |
| 242 | `smoke_test_lua()` |
| 256 | `update_category_state()` |
| 326 | `run_with_mini_batch()` |
| 406 | `update_github_status()` |
| 1935 | `stage_1()` |
| 1974 | `stage_2()` |
| 2120 | `stage_3()` |
| 2182 | `stage_4()` |
| 2494 | `stage_5()` |
| 2711 | `stage_6()` |
| 2793 | `stage_7()` |
| 2891 | `stage_8()` |
| 2916 | `process_file()` |
| 3019 | `process_scripts_file()` |
| 3106 | `process_monsters_category()` |
| 3159 | `process_spells_category()` |
| 3209 | `process_items_category()` |
| 3310 | `process_raids_category()` |
| 3358 | `process_world_category()` |
| 3409 | `process_libs_category()` |
| 3517 | `process_events_category()` |
| 3625 | `process_chatchannels_category()` |
| 3667 | `process_modules_category()` |
| 3774 | `process_startup_category()` |
| 3882 | `process_npclib_category()` |
| 3932 | `process_php_category()` |
| 4012 | `process_html_category()` |
| 4060 | `process_cpp_category()` |
| 4118 | `process_client_category()` |
| 4205 | `process_sendTextMessage_category()` |
| 4299 | `process_keywordHandler_category()` |
| 4454 | `process_twig_category()` |
| 4580 | `process_generic_category()` |
| 4862 | `sync_translation_keys()` |
| 5014 | `auto_translate_keys()` |
| 5271 | `scan_new_files()` |
| 5361 | `generate_npc_documentation()` |
| 5469 | `validate_translation_quality()` |
| 5631 | `generate_daily_report()` |
| 5737 | `idle_full_cycle()` |
| 5778 | `mode_translation()` |
| 6019 | `select_work_mode()` |

---

## Audyt szczegółowy (problemy + rekomendacje)

### 1) Helpery / podstawy: Bash‑owe pułapki i utrata spójności

#### 1.1 `get_unprocessed_files()` — `eval` + brak bezpiecznego przekazywania argumentów
- Lokalizacja: `i18n_worker_simple.sh:147`
- Problem:
  - `eval "find $find_args"` jest niebezpieczne (wystarczy `find_args='.; rm -rf /'`).
  - trudne do debugowania: quoting/escaping argumentów find.
- Rekomendacja:
  - usuń `eval` i przekaż argumenty jako tablicę Bash (`find "${args[@]}"`),
  - albo: ogranicz `find_args` do whitelisty i/lub buduj go wewnętrznie (bez wejścia z zewnątrz).
- Status: DONE — usunięto `eval`, funkcja przyjmuje teraz args jako tablicę (opcjonalny ostatni `batch`), zaktualizowano komentarz użycia.

#### 1.2 `log()` — `echo -e` jest nieprzewidywalne i potencjalnie psuje logi
- Lokalizacja: `i18n_worker_simple.sh:217`
- Problem:
  - `echo -e` interpretuje sekwencje `\...` w danych; jeśli message zawiera backslash, log może się “rozjechać”.
- Rekomendacja:
  - użyj `printf '%s\n' "$1" >&2` albo `printf '%b\n'` tylko gdy **świadomie** logujesz sekwencje.
- Status: DONE — `log()` używa teraz `printf '%b\n'` (zachowane kolory, bez `echo -e`).

#### 1.3 `mark_file_completed()` — **nadpisywanie statusu** (utrata danych etapów)
- Lokalizacja: `i18n_worker_simple.sh:155`–`i18n_worker_simple.sh:206`, szczególnie `i18n_worker_simple.sh:187`
- Problem:
  - `status[\"files\"][file_path] = {...}` zastępuje cały obiekt pliku.
  - To kasuje wcześniejsze dane etapów (np. `2_analysis`, `3_documentation`, `4_transformation`, `7_validation`, itp.).
  - Dla pipeline NPC jest to szczególnie bolesne, bo `stage_1..8` zapisuje bogaty stan, a na końcu i tak zostaje “ubogi” wpis.
- Skutek:
  - statusy/raporty stają się nieprawdziwe,
  - detekcja “czy plik już był zrobiony” może działać przypadkowo,
  - regresje typu “dispatcher mówi pending_skip” trudniej wytłumaczyć.
- Rekomendacja:
  - zamiast przypisywać cały obiekt, **zmerge’uj** z istniejącym wpisem (update tylko `overall_status`, `completed_at`, ewentualnie `global_stats`),
  - nigdy nie kasuj `stages` jeśli istnieją.
- Status: DONE — `mark_file_completed()` teraz scala istniejący wpis i nie nadpisuje `stages`.

#### 1.4 `validate_lua_file()` — `lua -p` jest w praktyce błędne
- Lokalizacja: `i18n_worker_simple.sh:231`
- Problem:
  - standardowy interpreter `lua` nie ma opcji `-p` (częściej `luac -p`).
- Skutek:
  - jeśli `lua` jest zainstalowane: walidacja może zawsze failować → niepotrzebne restore backup.
- Rekomendacja:
  - wykryj `luac` i użyj `luac -p`,
  - albo (najprościej) usuń `validate_lua_file()` i korzystaj z `smoke_test_lua()` (`loadfile`) jako jedynej walidacji.
- Status: DONE — `validate_lua_file()` używa `luac -p`, a gdy brak `luac`, fallback na `lua` + `loadfile`.

#### 1.5 `run_with_mini_batch()` — błędne `rc=$?` po `! cmd`
- Lokalizacja: `i18n_worker_simple.sh:355`–`i18n_worker_simple.sh:366`
- Problem:
  - w konstrukcji `if ! cmd; then rc=$?; fi` kod `$?` zwraca status operatora `!`, a nie oryginalnego `cmd`.
  - w praktyce `rc` będzie 0 w bloku błędu (czyli log wprowadza w błąd).
- Rekomendacja:
  - użyj `if cmd; then ... else rc=$?; ... fi`.
- Status: DONE — poprawiono logikę `rc=$?` w `run_with_mini_batch()` (brak `!` przed komendą).

#### 1.6 `run_with_mini_batch()` — “added” może być ujemne i psuje logikę
- Lokalizacja: `i18n_worker_simple.sh:371`–`i18n_worker_simple.sh:391`
- Problem:
  - `added=$((keys_after - keys_before))` może wyjść ujemne (np. sprzątanie kluczy, przebudowa JSON).
  - warunek kończenia działa tylko dla `added == 0`, więc ujemne wartości będą traktowane jak “było coś zrobione” → brak skip/backoff.
- Rekomendacja:
  - clamp `added` do `>= 0` albo traktuj `<= 0` jako “brak postępu”.
- Status: DONE — `added` jest teraz klamrowane do `>= 0` przed logiką “brak postępu”.

---

### 2) Pipeline NPC (etapy 1–8): stabilność i spójność

#### 2.1 `stage_1()` — backup: niecytowany `basename`
- Lokalizacja: `i18n_worker_simple.sh:1947`
- Problem:
  - `cp \"$file\" \"$BACKUP_DIR/$type/$(basename $file).bak\"` ma `basename $file` bez cudzysłowów.
  - to samo dotyczy wielu miejsc użycia `$(basename $file)` (patrz sekcja “quoting” niżej).
- Rekomendacja:
  - `cp \"$file\" \"$BACKUP_DIR/$type/$(basename \"$file\").bak\"`.
- Status: DONE — `basename` w `stage_1()` jest teraz cytowany.

#### 2.2 `stage_1()` — zależność od `md5sum` bez fallback
- Lokalizacja: `i18n_worker_simple.sh:1941`
- Problem:
  - `md5sum` może nie być dostępny w minimalnych środowiskach.
- Rekomendacja:
  - fallback na `sha256sum` albo wylicz hash w Pythonie (`hashlib`).
- Status: DONE — dodano fallback na `sha256sum`, a w ostateczności obliczanie hash w Pythonie.

#### 2.3 `stage_3()` / `stage_5()` — backup ścieżki z `$(basename $file)`
- Lokalizacje:
  - `i18n_worker_simple.sh:2136` (w Pythonie: `backup_file = \"$BACKUP_DIR/npc/$(basename $file).bak\"`)
  - `i18n_worker_simple.sh:2506` (Bash: `local backup=\"$BACKUP_DIR/$type/$(basename $file).bak\"`)
- Problem:
  - `basename $file` bez cytowania,
  - w dodatku w Python heredoc zmieniasz ścieżkę “w locie”, trudniej to utrzymać.
- Rekomendacja:
  - licz backup path w Bash i przekazuj jako string do Pythona.
- Status: DONE — `stage_3()` używa teraz `backup_file` z Bash, a `stage_5()` ma cytowany `basename`.

#### 2.4 `stage_3()` i `stage_8()` — Python generuje ostrzeżenia “invalid escape sequence”
- Lokalizacje:
  - `i18n_worker_simple.sh:2150` oraz `i18n_worker_simple.sh:2159` (w doc generatorze NPC)
  - `i18n_worker_simple.sh:2945` (wpis w `I18N_STATUS.md`)
- Problem:
  - w Pythonie `\`` (backslash + backtick) jest “invalid escape sequence” → warningi, które mieszają się z innym outputem.
- Rekomendacja:
  - usuń backslash i zostaw sam backtick: `` ` ``.
- Status: DONE — usunięto `\`` w generatorach dokumentacji (Python nie generuje już warningów).

#### 2.5 `stage_4()` — stały debug do `/tmp`
- Lokalizacja: `i18n_worker_simple.sh:2426`, `i18n_worker_simple.sh:2429`
- Problem:
  - debug log jest zawsze włączony.
- Rekomendacja:
  - dodaj flagę `I18N_DEBUG=1` i tylko wtedy loguj,
  - albo usuń debug i loguj tylko w razie błędu (np. gdy nie da się sparsować liczb).
- Status: DONE — debug w `stage_4()` jest teraz warunkowy (`I18N_DEBUG_STAGE4=1`).

#### 2.6 `process_file()` — wywołanie `mark_file_completed()` psuje status (patrz 1.3)
- Lokalizacja: `i18n_worker_simple.sh:2955`
- Problem:
  - po `stage_8()` nadpisujesz status pliku przez `mark_file_completed()`.
- Rekomendacja:
  - `mark_file_completed()` powinno tylko dopisać do `i18n_processed_files.txt` i ewentualnie update’ować `overall_status` w istniejącym wpisie, nie kasować etapów.
- Status: DONE — po poprawce `mark_file_completed()` call w `process_file()` jest bezpieczny (nie kasuje etapów).

---

### 3) Kategorie “non‑NPC”: duplikacja, kruchość, błędy w zliczaniu

#### 3.1 “`head -$batch`” i brak walidacji batch
- Lokalizacje: m.in. `i18n_worker_simple.sh:3150`, `i18n_worker_simple.sh:3201`, `i18n_worker_simple.sh:4006`, `i18n_worker_simple.sh:4191`
- Problem:
  - `head -$batch` to stary skrót; łatwo o błąd gdy `batch` jest puste/nienumeryczne.
- Rekomendacja:
  - używaj `head -n \"$batch\"` i waliduj `batch` (`[[ \"$batch\" =~ ^[0-9]+$ ]]`).
- Status: DONE — dodano `sanitize_batch()` i wszystkie miejsca z `head -$batch` używają teraz `head -n "$(sanitize_batch ...)"`.

#### 3.2 `grep -oP` (PCRE) — zależność od GNU grep
- Lokalizacje: `i18n_worker_simple.sh:3127`, `i18n_worker_simple.sh:3180`, `i18n_worker_simple.sh:3332`, `i18n_worker_simple.sh:4078` i inne (łącznie 14)
- Problem:
  - `grep -P` nie jest przenośny (na części systemów to nie działa).
  - `-oP` + regexy “na skróty” często łapią stringi z komentarzy.
- Rekomendacja:
  - w miejscach kluczowych przenieś parsowanie do Pythona (jedno źródło prawdy).
- Status: DONE — usunięto `grep -oP`, dodano helper `py_regex_matches()` oparty o Pythona.

#### 3.3 `sed 's/\\b...'` — nie robi “capitalize” tak jak sugeruje komentarz
- Lokalizacje: `i18n_worker_simple.sh:3131`, `i18n_worker_simple.sh:3177`, `i18n_worker_simple.sh:3329`, `i18n_worker_simple.sh:3643`
- Problem:
  - `\\b` w regexie sed to zwykle backspace, nie “word boundary” → wynik często nie jest tytułowany.
- Rekomendacja:
  - użyj Pythona (`str.title()` albo własna funkcja) lub sed z `\\<`/`\\>` (GNU sed).
- Status: DONE — dodano helper `title_case()` (Python) i zastąpiono wszystkie użycia `sed 's/\\b...'`.

#### 3.4 `process_items_category()` — logicznie niespójne (podwójna ścieżka)
- Lokalizacja: `i18n_worker_simple.sh:3234`–`i18n_worker_simple.sh:3287`
- Problemy:
  - uruchamiasz heredoc `ITEMSPY` który zapisuje JSON i wypisuje `count`, ale tego `count` nie przechwytujesz,
  - zaraz potem uruchamiasz drugi `python3 -c` który **znowu** modyfikuje JSON i zwraca `batch`,
  - `skip`/`processed` w praktyce nie kontroluje dodawania w drugiej ścieżce,
  - oba fragmenty wstrzykują do Pythona gołe `$current_mini` / `$processed` (SyntaxError jeśli puste).
- Skutek:
  - trudne do przewidzenia ile itemów dodasz na iterację,
  - log `added` i `total_added` może być fałszywy,
  - ryzyko “wyzerowania” kategorii przez błędy Pythona i wejście w skip.
- Rekomendacja:
  - zostaw **jedną** implementację (najlepiej jedną funkcję w Pythonie), zwracaj liczbę dodanych kluczy i ją przechwytuj,
  - przenieś parametry do env (`os.environ`) zamiast wstrzykiwać `$var` do kodu.
- Status: DONE — `process_items_category()` używa jednego bloku Pythona z parametrami z argv; usunięto podwójne zapisy.

#### 3.5 “python3 -c ... 2>/dev/null; mark_file_completed ...” — ciche błędy i fałszywy “processed”
- Przykłady:
  - `i18n_worker_simple.sh:3134`–`i18n_worker_simple.sh:3148` (monsters)
  - `i18n_worker_simple.sh:3334`–`i18n_worker_simple.sh:3346` (raids)
- Problem:
  - jeśli Python nie zapisze JSON (np. przez błąd quoting), stderr jest wyciszony, a plik i tak jest oznaczany jako completed.
- Rekomendacja:
  - nie wyciszaj błędów Pythona w ciemno; sprawdzaj RC i tylko wtedy oznaczaj “processed”.
- Status: DONE — dodano kontrolę RC dla bloków `python3 -c` w kategoriach i pomijanie `mark_file_completed` przy błędzie (m.in. monsters/spells/raids/world/libs/events/chatchannels/modules/startup/npclib/php/html/cpp/client); usunięto `2>/dev/null` przy tych zapisach.

#### 3.6 `process_sendTextMessage_category()` — word splitting + brak “processed” + niejednoznaczne sed
- Lokalizacje:
  - iteracja po plikach: `i18n_worker_simple.sh:4219`, `i18n_worker_simple.sh:4279`
  - `sed -i` na stałych stringach: `i18n_worker_simple.sh:4225`, `i18n_worker_simple.sh:4283`
- Problemy:
  - `for file in $(find ...)` rozbije ścieżki po whitespace,
  - brak integracji z `i18n_processed_files.txt` → powtarzalna praca,
  - `sed -i` z dynamicznymi fragmentami jest kruche jeśli tekst zawiera delimiter `|` lub znaki specjalne.
- Rekomendacja:
  - iteruj `find ... -print0 | while IFS= read -r -d '' file; do ...`,
  - dodaj markery processed,
  - przenieś transformacje do Pythona (bezpieczniejsze).
- Status: DONE — iteracja używa `find -print0` + `read -d ''`, dodano markery `STM:` w `i18n_processed_files.txt`, a zamiany wykonuje Python zamiast `sed -i` (bezpieczne literalne replace).

#### 3.7 `process_keywordHandler_category()` — ignoruje parametr `batch` z Bash
- Lokalizacja: `i18n_worker_simple.sh:4299`, `i18n_worker_simple.sh:4308`, `i18n_worker_simple.sh:4314`
- Problem:
  - Bash przyjmuje `batch`, ale Python czyta `sys.argv[1]`, a skrypt jest odpalany bez argumentów.
- Skutek:
  - `batch` z dispatchera/mini-batch nic nie zmienia.
- Rekomendacja:
  - przekaż `\"$batch\"` jako argument do `python3` (np. `python3 - \"$batch\" << 'KWPY'`), albo czytaj z env.
- Status: DONE — `process_keywordHandler_category()` przekazuje `batch` do Pythona (`python3 - "$max_batch"`), z walidacją przez `sanitize_batch()`.

---

### 4) Tryb `--continuous`: sterowanie, skip/backoff, git

#### 4.1 PID file bez sprawdzenia istniejącego procesu
- Lokalizacja: `i18n_worker_simple.sh:7280`–`i18n_worker_simple.sh:7281`
- Problem:
  - zapisujesz `.worker_simple.pid`, ale nie sprawdzasz czy inny worker już działa.
- Rekomendacja:
  - dodaj `flock` lub weryfikację PID (i czy proces istnieje).
- Status: DONE — dodano sprawdzenie istniejącego PID (kill -0) i blokadę startu przy aktywnym procesie; stale PID jest nadpisywany.

#### 4.2 Komendy GitHub: ACK nadpisuje plik, potencjalnie gubi kolejkę
- Lokalizacja: `i18n_worker_simple.sh:7364`–`i18n_worker_simple.sh:7369`
- Problem:
  - po wykryciu komendy na GitHub, lokalnie nadpisujesz `.github/worker_commands.txt` samym ACK.
  - jeśli ktoś doda kilka komend (kolejka) — zostanie skasowana.
- Rekomendacja:
  - komentuj tylko pierwszą niezakomentowaną komendę, zachowując resztę pliku.
- Status: DONE — ACK dla komend z GitHub teraz komentuje tylko pierwszą niezakomentowaną komendę i zachowuje resztę kolejki (z dopisaniem wpisu wykonania).

#### 4.3 Użycie `-a` w `[` test
- Lokalizacja: `i18n_worker_simple.sh:7504`
- Problem:
  - `-a` w `[` ma nieintuicyjną precedencję i bywa źródłem błędów.
- Rekomendacja:
  - zastąp przez `&&` w `[[ ... ]]`.
- Status: DONE — zastąpiono `-a` w `[` przez jedno `[[ ... ]]` z `&&`, bez niejednoznacznej precedencji.

#### 4.4 Git operacje co cykl
- Lokalizacja: `i18n_worker_simple.sh:8016`–`i18n_worker_simple.sh:8038`
- Problem:
  - `git add -A` + commit + push w pętli: ryzyko konfliktów z guardianem/innymi procesami,
  - brak locka na repo (równoległe `git` może korumpować working tree lub generować konflikty).
- Rekomendacja:
  - dodać lock repo (np. `flock .i18n_git.lock`),
  - rozważyć commit/push rzadziej, np. tylko gdy `EFFECTIVE_COUNT > 0`.
- Status: DONE — dodano lock repo na operacje git (`flock` jeśli dostępny, fallback na `mkdir .i18n_git.lock`); przy braku locka cykl pomija git.

---

### 5) Python heredoc: mapa i ryzyka (Bash→Python)

Skrypt zawiera 23 duże bloki `python3 << ...` (plus dodatkowe w command‑substitution).
Najważniejsze ryzyka:
- **wstrzykiwanie gołych zmiennych** (`= $VAR`) → SyntaxError gdy puste lub wstrzyknięcie gdy zawiera znaki specjalne,
- brak atomowych zapisów JSON,
- częste `except:` zamiast `except Exception:` (łapie wszystko, także `KeyboardInterrupt`),
- część bloków nie jest cytowana (shell rozszerza `$...` wszędzie).

Tabela (start/end/delimiter/`<<-`/quoted):

| start | end | delim | `<<-` | quoted |
|---:|---:|---|:---:|:---:|
| 166 | 205 | PYMARK | no | no |
| 260 | 317 | CATSTATEPY | no | no |
| 415 | 1929 | STATUSPY | no | yes |
| 2130 | 2173 | EOF | no | no |
| 2510 | 2703 | EOF | no | no |
| 2720 | 2785 | PYEOF | no | no |
| 2801 | 2882 | PYEOF | no | no |
| 2898 | 2961 | PYEOF | no | no |
| 3235 | 3274 | ITEMSPY | no | no |
| 4235 | 4268 | MSGPY | no | yes |
| 4308 | 4444 | KWPY | no | yes |
| 4464 | 4570 | TWIGPY | no | yes |
| 4587 | 4852 | GENERICPY | no | no |
| 5275 | 5356 | SCANNEWPY | no | yes |
| 5365 | 5464 | GENDOCPY | no | yes |
| 5473 | 5626 | VALIDATEPY | no | yes |
| 5635 | 5726 | DAILYPY | no | yes |
| 5793 | 6008 | PYTRANSLATE | no | yes |
| 6021 | 7011 | DISPATCHERPY | yes | yes |
| 7037 | 7208 | STATUSEOF | no | yes |
| 7822 | 7845 | AUTODONEPY | no | no |
| 7862 | 7878 | DOCSDONEPY | no | yes |
| 7918 | 8007 | SAVEPY | no | no |

Rekomendacja “systemowa”:
- docelowo: **wszystkie** heredoci cytowane (`<< 'PY'`) + dane przekazywane przez env/argv/JSON, bez `$VAR` w kodzie,
- każdy zapis JSON atomowo (`write temp` → `rename`),
- `except Exception:` zamiast `except:`.

Dodatkowa obserwacja:
- w pliku jest bardzo dużo `except:` (78 wystąpień) — to utrudnia debug, bo ukrywa realne przyczyny problemów i potrafi “połknąć” np. `KeyboardInterrupt`.  
  - Przykładowe linie: `i18n_worker_simple.sh:178`, `i18n_worker_simple.sh:276`, `i18n_worker_simple.sh:445`.

---

## Lista “quoting / whitespace” — konkretne miejsca do poprawy

Poniższe miejsca mają `basename $file` bez cytowania (potencjalny problem ze spacjami / znakami specjalnymi):
- `i18n_worker_simple.sh:1947`
- `i18n_worker_simple.sh:2136`
- `i18n_worker_simple.sh:2506`
- `i18n_worker_simple.sh:4227`
- `i18n_worker_simple.sh:4285`
- Status: DONE — wszystkie `basename` są teraz cytowane; sendTextMessage przeniesione do Pythona, więc problematyczne logi zniknęły.

---

## Co jeszcze warto dodać (funkcjonalnie)

1. `--self-check` (lub `SELFTEST` jako komenda GitHub) który robi:
   - `bash -n i18n_worker_simple.sh`,
   - szybki sanity check: czy `tools/i18n_status.py` i inne narzędzia istnieją,
   - walidacja JSON (`python3 -m json.tool`) dla krytycznych plików statusu,
   - test “dispatcher” (czy `select_work_mode` daje sensowny wynik).
- Status: DONE — dodano `self_check`, flagę `--self-check` oraz obsługę `SELFTEST|SELF_CHECK` z weryfikacją bash/tools/JSON/dispatcher.
2. Locking:
   - lock na `.worker_simple.pid` (żeby nie odpalić dwóch instancji),
   - lock na `i18n_file_status.json`, `.i18n_category_state.json` i na repo (git).
- Status: DONE — dodano sprawdzanie PID, locki dla statusu i stanu kategorii oraz blokadę repo w sekcji git.
3. Atomowe zapisy JSON + backup statusów (minimalny journaling) na wypadek przerwania procesu.
- Status: DONE — zapisy statusów są atomowe z `.bak`, a `i18n_global_stats.json` i status tłumaczeń zapisują się atomowo.
4. Flagi debug (`I18N_DEBUG`, `I18N_DEBUG_STAGE4`, itp.) zamiast stałych zapisów do `/tmp`.
- Status: DONE — debug w stage_4 jest warunkowy (`I18N_DEBUG_STAGE4=1`).

---

## Aneks: “hardcoded” wzorce NPC, których stage_4 nadal nie przerabia

Stan na dziś (zliczenia po `rg` w katalogach NPC):
- Konkatenacje: `npcHandler:say(\"...\" .. ...)` — DONE (obsługiwane przez parser stage_4/5); pozostają złożone wyrażenia z `and/or` lub porównaniami na top‑level.
- Tablicowe `npcHandler:say({ ... })` — DONE dla tablic z literalami/concat/format oraz wariantu z `npc/creature/delay` w tablicy; pomijane tablice z elementami nieliteralnymi (np. `hints[i]`).
- `StdModule.promotePlayer` z `text = \"...\"` — 6 wystąpień (brak migracji).
- Dodatkowe parametry w `npcHandler:say(\"...\", npc, creature/player, ...)` — 1 wystąpienie (regex stage_4 tego nie obsługuje).

---

## Rozszerzenie: “wszystkie kategorie na wzór NPC” (2025-12-17)

### Zrobione (worker + narzędzia)
- Dodano migrator `broadcastMessage` → `Game.broadcastLocalizedMessage` (`tools/i18n_migrate_lua_broadcast.py`) i integrację w: `scripts`, `generic`, `libs`, `events`, `modules`, `startup`, `spells`, `raids`, `world`, `chatchannels`, `npclib`.
- `spells`: klucze `spell.<safe>.name/words/desc` + migracje `sendTextMessage` / `:say` / `broadcastMessage` z backupem i walidacją Lua.
- `items`: ekstrakcja `item.<id>.name` + `item.<id>.desc` z `items.xml` (atomowy zapis JSON).
- `raids`: klucze `raid.<safe>.name/announce` + migracje `sendTextMessage` / `:say` / `broadcastMessage` (Lua).
- `world`: ekstrakcja literalnych tekstów do `world.<safe>.textN` + migracje `sendTextMessage` / `:say` / `broadcastMessage` (Lua).
- `chatchannels`: nazwa z pliku (fallback do nazwy pliku) + migracje `sendTextMessage` / `:say` / `broadcastMessage` + poprawka `mark_file_completed`.
- `npclib`: migracje `sendTextMessage` / `:say` / `broadcastMessage` + poprawka `mark_file_completed`.
- NPC: pipeline zawsze wykonuje `stage_3` (documentation) nawet gdy `stage_2` mówi “no migration”; brakujące `2_analysis/3_documentation` są dopełniane przez reprocess w pętli NPC.
- NPC: stage_4/5 obsługuje `npcHandler:say` z konkatenacjami, `string.format` i tablicami (`npcSayMultiple` z args), z bezpiecznym pomijaniem przypadków nieliteralnych.
- Dispatcher: `REPEAT_CATEGORIES` (reprocess), specjalne wykrywanie dla `spells/items/raids/world/chatchannels/npclib`, a dla pozostałych kategorii tekstowych detekcja tylko przez `sendTextMessage`/`:say`/`broadcastMessage`.
- `process_twig_category` respektuje `batch`.
- Korekty kategorii w `mark_file_completed` dla `php/html/cpp/client`.

### Luki / do zrobienia (brak runtime lub brak pełnej migracji)
- `spells`: brak wsparcia runtime dla i18n nazw/words/desc (serwer nadal używa literalów).
- `items`: brak wsparcia runtime dla i18n nazw/opisów z `items.xml` (potrzebne pole i18nKey w ItemType lub Lua hook używający `Item:setLocalizedName/Description`).
- `raids/world`: XML komunikaty nie są mapowane na i18nKey w runtime (Lua już wspiera).
- `chatchannels`: brak mechanizmu użycia i18n dla nazw kanałów po stronie serwera/klienta (wymaga integracji).
- `keywordHandler` bez i18nKey: nadal tylko ekstrakcja kluczy, brak transformacji kodu (do wdrożenia).
- Pozostałe hardcoded wzorce NPC z aneksu nadal wymagają osobnych migratorów (np. `StdModule.promotePlayer` text, `npcHandler:say` z dodatkowymi parametrami, tablice z nieliteralnymi elementami, złożone konkatenacje z `and/or` lub porównaniami).

---

## Audyt sesji 2026-02-XX: Poprawki workera (9 fixów)

### Kontekst
Codex i głęboka analiza zidentyfikowały 14 bugów (2 CRITICAL, 3 HIGH, 5 MEDIUM, 4 LOW). 
Zaimplementowano 9 poprawek opisanych poniżej.

### Fix #1: MODE_EXTRA2 nigdy nie resetowane (CRITICAL)
**Problem:** `MODE_EXTRA2` ustawiane przez komendy `SYNC`/`AUTO` (linie ~10941/10987) nigdy nie było czyszczone między cyklami. Sprawdzenie `if [ "$MODE_EXTRA2" = "AUTO" ]` w pętli ciągłej powodowało permanentne pomijanie dispatchera → nieskończona pętla tego samego zadania.  
**Fix:** Dodano `MODE_EXTRA2=""` + `MODE_TYPE=""` + `MODE_CAT=""` + `MODE_COUNT=""` na końcu każdego cyklu oraz na początku pętli ciągłej.  
**Linie:** ~11737 (reset cyklu), ~10823 (inicjalizacja cyklu).

### Fix #2: Anti-loop z backoffem per kandydat
**Problem:** `select_auto_translate_target_strict()` miał jednopoziomowy guard — gdy jedyny kandydat miał 0 postępu, pętla się zapętlała.  
**Fix:** Wprowadzono `no_progress_counts` dict śledzący liczbę wizyt z zerowym postępem per kandydat. Po ≥3 wizytach kandydat jest pomijany. Gdy wszyscy wyczerpani — reset liczników.  
**Linia:** ~10420.

### Fix #3: Niecytowany heredoc AUTOTRANSPY
**Problem:** `<< AUTOTRANSPY` (bez cudzysłowów) powodował ekspansję zmiennych Basha wewnątrz kodu Pythona. Zmienne `$target_lang`, `$json_file` itp. były rozwijane przez Bash zamiast przekazywane jako argumenty.  
**Fix:** Zmieniono na `<< 'AUTOTRANSPY'` + `python3 - "$target_lang" "$json_file" "$translate_limit" "$strict_mode"` + użycie `sys.argv` w Pythonie.  
**Linia:** ~7867.

### Fix #4: EN-copy fałszywie traktowane jako nieprzetłumaczone
**Problem:** `_is_untranslated()` (w 3 lokalizacjach: STATUSPY, select_auto_translate_target_strict, auto_translate_keys) traktowała WSZYSTKIE `lang_value == en_value` jako nieprzetłumaczone. Tysiące kluczy (nazwy itemów, potworów, zaklęć) są poprawnie identyczne z EN.  
**Fix:** Dodano `_is_likely_proper_noun()` / `_is_proper_noun_key()` rozpoznające:
- klucze `item.*.name`, `monster.*.name`, `spell.*.words`
- wartości ≤3 znaków
- wartości wyłącznie wielkie litery (skróty)  
**Linie:** ~1208 (STATUSPY), ~10308 (strict dispatcher), ~8084 (auto_translate_keys).

### Fix #5: Próg STALE vs IDLE sleep
**Problem:** IDLE sleep 300s > stale_threshold 120s → dashboard raportował STALE podczas normalnego IDLE.  
**Fix:** Zwiększono `stale_threshold_seconds` z 120 na 360. Dodano `status_update_activity` przed snem IDLE.  
**Linie:** ~1517 (próg), ~11759 (heartbeat przed sleep).

### Fix #6: Hardcoded kategorie w walidacji/dokumentacji/raportach
**Problem:**  
- `validate_translation_quality()`: tylko 7 kategorii hardcoded  
- `generate_npc_documentation()`: tylko 8 kategorii hardcoded  
- `generate_daily_report()`: skanował tylko 3 podkatalogi (`npc`, `scripts`, `monsters`) zamiast struktury `i18n/{lang}/`
- Realnie istnieje 38 kategorii w `i18n/en/`  
**Fix:** Wszystkie 3 funkcje teraz dynamicznie odkrywają kategorie z `os.listdir(i18n/en/)`.  
**Linie:** ~8788 (validate), ~8603 (generate_npc_doc), ~8849 (daily_report).

### Fix #7: Nieatomowy zapis TM i lang_file
**Problem:** `translation_memory.json` i pliki `i18n/{lang}/{cat}.json` zapisywane bezpośrednio — crash w trakcie zapisu = utrata/zniszczenie danych.  
**Fix:** Użycie `tempfile.mkstemp()` + `os.replace()` (atomowy rename) dla obu zapisów w `auto_translate_keys()`.  
**Linie:** ~8346 (lang_file), ~8358 (TM).

### Fix #8: Dashboard roadmap + targets dynamicznie
**Problem:**  
- `category_current` miał tylko 12 ręcznie wymienionych kategorii → targets auto-adjust nie działał dla 26 pozostałych  
- Roadmap w `I18N_STATUS.md` pokazywał tylko 8 wierszy → 30 kategorii niewidocznych  
- Nowe kategorie nie miały celów → procent postępu = 0% lub brak  
**Fix:**  
- `category_current` teraz używa `all_json_categories` (dynamicznie z `i18n/en/`)
- Nowe kategorie automatycznie dostają cel = `auto_adjust_target(current, max(current, 100))`
- Roadmap generowany pętlą po wszystkich kategoriach z ikonami
**Linie:** ~1115 (category_current), ~1144 (roadmap_rows_list), ~2345 (template).

### Znane pozostałe problemy (niezaimplementowane)
1. **SIMPLE_TRANSLATIONS** pokrywa tylko 5 języków × ~20 słów → 48+ języków ma zero realnych tłumaczeń (potrzebna integracja z API tłumaczeń lub większy słownik)
2. **`simple_translate()` ignoruje casing** — "Hello" i "hello" traktowane jednakowo
3. **`generate_daily_report()` — stara sekcja "Tłumaczenia według języków"** — teraz zlicza poprawnie, ale format raportu mógłby być bogatszy
4. **`count_untranslated_keys()` (~line 9917)** — martwy kod, nigdzie nie wywoływany
5. **Brak retry/fallback** przy niepowodzeniu tłumaczenia — kandydat jest po prostu pomijany

### Aktualizacja 2026-02-12 — domknięcie Fazy 0

- ✅ **0.1 GT_LANG_MAP**: dodano mapowanie `he -> iw` oraz normalizację `zh_TW/zh_tw`.
- ✅ **0.2 Cache target selection**: strict dispatcher korzysta z cache kandydatów z TTL cykli.
- ✅ **0.3 Throttle STATUSPY**: aktywne `should_update_github_status()` + smart-force.
- ✅ **0.4 Spójność struktury języków**: brakujące pliki JSON uzupełnione; walidacja `missing_total=0`.
- ✅ **0.5 Test wydajności 2 min**: wykonany bounded run workera + odczyt profiler `cycle_total`.

Wynik 0.5 (6 ostatnich pełnych `cycle_total`): min `4089 ms`, p50 `12771 ms`, avg `10810 ms`, max `20444 ms`.
