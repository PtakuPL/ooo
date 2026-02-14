# I18N: Plan naprawczy statusu, guardiana i 3. daemona (2026-02-13)

> **STATUS DOKUMENTU:** Ten dokument pozostaje źródłem analizy i decyzji pośrednich.
> Kanoniczny plan wykonawczy znajduje się w:
> `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`.
> W przypadku konfliktu zapisów, obowiązuje plan kanoniczny.

## 🛠️ Aktualizacja wykonania (2026-02-14 07:28 UTC — statusd drift + live scan counters)

Wykonane:
- ✅ `I18N_STATUS.md` ma teraz dwa liczniki skanu:
  - `Przeskanowane (historia)` (`i18n_processed_files.txt`),
  - `Przeskanowane (LIVE)` (`i18n_file_status.json`),
  - oraz różnicę `Historia minus LIVE`.
- ✅ `statusd_report.json` ma nowy blok `metrics_drift`:
  - `live_keys`,
  - `worker_registry_keys`,
  - `outside_worker_registry_keys`,
  - `% drift` + severity + progi.
- ✅ `statusd_doctor.json` używa nowego kontraktu driftu (liczbowo, nie tylko po tekstowych heurystykach).
- ✅ Alerting webhook ma reason codes:
  - `metrics_drift_high`,
  - `metrics_drift_elevated`.
- ✅ `statusd_daily_report.json/md` pokazuje sekcję `Metrics Drift (LIVE vs Registry)` + migration metrics LIVE/history/registry.

Walidacja:
- ✅ Runtime potwierdzony po wdrożeniu: worker/guardian/statusd aktywne, a nowe pola obecne w report/doctor/daily.

Nowe TODO:
- ⬜ Ujednolicić źródło progów `metrics_drift` dla wszystkich ścieżek uruchamiania statusd (daemon/manual), bo różne środowiska mogą dać inne severity.
- ⬜ Dodać artefakt `statusd_thresholds_snapshot` do łatwego audytu, jakie progi były aktywne przy danej agregacji/alarcie.

## 🛠️ Aktualizacja wykonania (2026-02-14 07:07 UTC — naprawa spójności key metrics)

Wykonane:
- ✅ `I18N_STATUS.md` pokazuje teraz oddzielnie:
  - metrykę LIVE (stan `i18n/en/*.json`),
  - metrykę registry (historia workera z `i18n_file_status.json`),
  - drift (klucze poza rejestrem workera).
- ✅ Sekcja `MIGRATION` dostała jawny, mieszany `source`:
  - `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt`.
- ✅ Rozszerzono payload telemetryczny o pola LIVE/registry/drift dla kluczy.
- ✅ Mechanizm force-update statusu wykrywa teraz zmianę sygnatury `i18n/*.json` (`i18n_live_signature`), więc ręczne zmiany poza workerem wyzwalają odświeżenie dashboardu.

Walidacja:
- ✅ Snapshot po wdrożeniu: LIVE `53,586`, registry `6,248`, drift `47,338`.

Nowe TODO dla status+guard+statusd:
- ✅ Dodać `metric_drift` check do `statusd_doctor`. → DONE 2026-02-14: check #10 `_read_metrics_drift()` z progami WARN/CRIT (keys + %).
- ✅ Dodać do sekcji `MIGRATION` równoległy licznik `scanned_files_live`. → DONE 2026-02-14: dashboard pokazuje historia + LIVE.
- ✅ Dodać reason code webhooka dla driftu (`metrics_drift_high`). → DONE 2026-02-14: reason codes `metrics_drift_critical/high/moderate`.

## 🛠️ Aktualizacja wykonania (2026-02-14 06:56 UTC — guardian/start-source + statusd quality watch)

Wykonane:
- ✅ **Guardian daemon single-source guard (kodowy)**
  - dodano lock `.guardian_daemon.lock` i stan `i18n/status/guardian_daemon_state.json`,
  - start daemona jest blokowany przy aktywnym locku (manual/scheduler/service nie dublują daemona).
- ✅ **Guardian health hardening**
  - nowe progi heartbeat (`aging/stale/stuck`) i detekcja aktywności procesu (`pid_alive`, `worker_log_age_s`, `guard_last_entry_age_s`),
  - ograniczono false-positive restarty `health_stuck` podczas długich cykli tłumaczeń.
- ✅ **Statusd quality watch (suspicious_high) end-to-end**
  - `statusd_report.json` publikuje `quality_watch`,
  - `statusd_doctor.json` podnosi `SUSPICIOUS_HIGH_SPIKE/ELEVATED`,
  - webhook wspiera `suspicious_high_spike` / `suspicious_high_elevated`,
  - `statusd_daily_report.json/md` ma KPI `suspicious_high_*` i `Repair Tuning 24h`,
  - raport 24h preferuje dedykowane źródło `pending_skip_24h_latest.json`.
- ✅ **Worker repair cadence odporna na restart**
  - runda `repair_identical_bonus_round()` używa globalnego `translation_dispatch_state.cycle_counter` do interwału.

Nowe problemy wykryte runtime:
- ⚠️ `statusd_doctor` przechodzi na `CRITICAL` przez `SUSPICIOUS_HIGH_SPIKE`:
  - snapshot: `suspicious_high_total=2759` / `translated_total=22167` w oknie 6h (`12.446%`),
  - top: `es`, kategoria `npc.json`.
- ⚠️ `repair_tuning_24h.samples_24h=0` mimo aktywnej kolejki backlogu `identical_to_en`:
  - wymaga potwierdzenia po kilku cyklach, że nowy interwał oparty o `cycle_counter` generuje próbki.
- ⚠️ Alerting webhook nadal nieskonfigurowany (`WEBHOOK_NOT_CONFIGURED`), więc sygnały CRITICAL nie wychodzą poza host.

Nowe TODO do planu:
- ⬜ Wprowadzić progi `suspicious_high` per domena/per-język (co najmniej `npc.json` + PL/ES), zamiast tylko globalnego count.
- ✅ Dodać check operacyjny: jeśli `repair_queue.entries_total` maleje, ale `repair_tuning_24h.samples_24h=0` przez >2h, zgłoś warning `REPAIR_TUNING_NO_SAMPLES`. → DONE 2026-02-14: doctor check #11 + webhook signal.
- ✅ Nadal domknąć organizacyjnie pojedyncze źródło uruchamiania guardiana (`service` vs `scheduler` vs `manual`) mimo locka kodowego. → DONE 2026-02-14: `i18n_start_all.sh` — kanoniczny start/stop/restart/status wszystkich demonów.

## 🚨 ANEKS DECYZYJNY (2026-02-13, FINAL)

### Decyzja właściciela projektu

- **NIE rozdzielamy** `I18N_STATUS.md` na wiele plików.
- Dashboard zostaje w **jednym pliku**: `I18N_STATUS.md`.
- Dane mają być **dokładnie uporządkowane** w jednym pliku i aktualizowane zależnie od rodzaju pracy workera.

### Co to oznacza dla implementacji

1. Sekcje statusu pozostają w jednym markdownie, ale są podzielone logicznie:
   - `META` (stałe informacje + freshness),
   - `LIVE` (co worker robi teraz),
   - `MIGRATION` (stan migracji),
   - `TRANSLATION` (stan tłumaczeń),
   - `QUALITY` (jakość/alerty),
   - `HISTORY` (ostatnie akcje).

2. Sekcje `MIGRATION` i `TRANSLATION` są zawsze obecne, ale:
   - tylko sekcja zgodna z aktualnym trybem ma status `active`,
   - druga ma status `inactive` z jasnym powodem (np. „worker w trybie MIGRATION”).

3. Aktualizacja „przed wykonaniem zadania” jest obowiązkowa:
   - `pre_cycle_snapshot` → dispatch → run → `post_cycle_snapshot` → render `I18N_STATUS.md`.

4. Źródłem prawdy pozostają JSON-y `i18n/status/*`, a `I18N_STATUS.md` jest czytelną projekcją.

### Nadpisanie wcześniejszych punktów dokumentu

Niniejszy aneks **nadpisuje** w tym dokumencie wszystkie fragmenty sugerujące split statusu na wiele markdownów, w szczególności:
- sekcję 3 (strategia statusu),
- backlog P1/P2 dotyczący wielu plików statusowych,
- testy regresji markdown opisane jako „wiele plików”.

Od teraz obowiązuje podejście: **jeden `I18N_STATUS.md`, porządek przez strukturę i reguły aktualizacji**.

## ✅ Stan wdrożenia krytycznego punktu (start)

Na dzień 2026-02-13 wdrożono krytyczne punkty z planu:

1. ✅ Guardian nie uruchamia już workera „na sztywno”.
2. ✅ Dodano profile uruchomienia workera przez plik:
   - `guardian_profile.json`
3. ✅ Aktywny profil startowy:
   - `mode = translations_general`
   - worker startuje tłumaczenie wszystkich języków (`--translations-only`, bez wymuszania `--langs`)
   - kolejność bootstrap: najpierw hiszpański (`es`), potem polski (`pl`), następnie rotacja pozostałych języków
4. ✅ `worker_config.json` naprawiony: `focus_lang=""`, `use_gt=true`, `parallel_langs=2`.
5. ✅ **guard_command whitelist (GAME_COMMANDS)** wdrożony:
   - Pattern 2 (single-quoted) sprawdza TYLKO whitelist prawdziwych komend gry (60+ słów)
   - Slash-command regex poprawiony: wyklucza URL-e i ścieżki plików
   - **Wynik: guard_fail_rate 10.6% → 3.5% (cel <5% ✅)**
6. ✅ **Baseline 24h (Faza 0)** domknięty:
   - skrypt `i18n_baseline_snapshot.sh` naprawiony (okna `--hours/--since`, unikalny output, filtr czasu po `datetime`)
   - artefakt: `i18n/status/baseline/baseline_2026-02-13_210014.json`
   - raport zawiera `quality_snapshot` (PL/ES), `daily_summary`, `guardian_log_summary`
7. ✅ **strict_hourly_window** wdrożony w baseline:
   - KPI godzinowe liczone wyłącznie z JSONL (`worker_cycle_perf.jsonl`, `translation_guard_report.jsonl`, `suspicious_log.jsonl`)
   - `daily_summary` pozostaje osobnym, pomocniczym agregatem dobowym
8. ✅ **strict_hourly_window** wdrożony w renderingu statusu:
   - `I18N_STATUS.md` pokazuje sekcję „Strict Hourly Window (JSONL-only)”
   - publikowany jest artefakt `i18n/status/strict_hourly_window_latest.json`
   - `translation_global_overview.json` zawiera pole `strict_hourly_window`
9. ✅ **Quality hardening PL/ES** domknięty po stronie runtime:
   - dla `pl/es` słownik bazowy ma priorytet nad zewnętrznym przy kolizji klucza,
   - dodano brakujące frazy ES wysokiej częstotliwości (NPC/UI),
   - `identical_to_en` rozdzielono na `translatable` vs `exempt` (techniczne wyjątki).
   - snapshot po wdrożeniu (2026-02-13 22:16 UTC, okno 100 wpisów): `identical_to_en` ~30, `identical_to_en_exempt` ~45-50.
10. ✅ **Runtime alignment + bootstrap state** (2026-02-13 22:38 UTC):
   - `guardian_profile.json` aktywnie pracuje w `translations_general` (`langs=""`),
   - fallbacki guardiana i auto-policy domyślnie wskazują `translations_general`,
   - `translation_dispatch_state.json` publikuje stan bootstrapu (`bootstrap_priority`, `bootstrap_forced_lang`, `cycle_counter`),
   - worker startuje od `es`, potem `pl`, potem rotuje dalej.
11. ✅ **Repair queue dla `identical_to_en (translatable)`** (2026-02-13 22:38 UTC):
   - artefakty: `i18n/status/identical_to_en_repair_queue.json` + `i18n/status/identical_to_en_repair_queue_report.jsonl`,
   - priorytet napraw: `es -> pl`, domeny `npc -> server -> talkactions -> ...`.
12. ✅ **Statusd repair stagnation + daily KPI** (2026-02-14 06:10 UTC):
   - `statusd_report.json` publikuje `repair_queue` + `stagnation`,
   - `run_status_doctor()` sygnalizuje `REPAIR_QUEUE_STAGNATION` / `REPAIR_QUEUE_STALE`,
   - webhook alerting obsługuje `reason_code=repair_queue_stagnation`,
   - `statusd_daily_report.json/md` ma sekcję `Repair Queue 24h` (trend + flaga stagnacji),
   - legacy `repair_stagnation_alert.json`/`repair_backlog_trend.jsonl` korzystają z tego samego sygnału progowego.

Cel tych kroków: skierować pracę workera na tłumaczenia wszystkich języków, z priorytetem startowym `es`/`pl`, i wyeliminować fałszywe blokady guard_command.

Kolejne kroki (do realizacji):
- ✅ health-based policy w guardianie: heartbeat age + progress delta + guard_fail trend + policy states (DONE 2026-02-13),
- ✅ dopracowanie sekcji dynamicznych w pojedynczym `I18N_STATUS.md` (DONE 2026-02-13: META/LIVE/MIGRATION/TRANSLATION/QUALITY/HISTORY z freshness/active|inactive),
- ✅ plan i wdrożenie 3. daemona wspierającego telemetry/status — ✅ DONE (2026-02-13: i18n-statusd.sh MVP, obecnie 8 modułów),
- ✅ guardian restart debounce/backoff dla ścieżki `mtime` (DONE 2026-02-13; `.guardian_restart_state.json` + `i18n/status/guardian_restart_metrics.json` + `.guardian_run.lock`),
- ✅ przy wydzielonym `statusd` utrzymać zgodność kontraktu `strict_hourly_window` (LIVE/KPI + alarmy) (DONE 2026-02-13),
- ✅ webhook alerting `stuck/no_progress/doctor_critical` + cooldown/deduplikacja (`statusd_alert_state.json`) (DONE 2026-02-13),
- ✅ dzienny executive report 24h (`statusd_daily_report.json` + `statusd_daily_report.md`) (DONE 2026-02-13),
- ✅ dodać jawny artefakt `pending_skip` dla okna 24h (DONE 2026-02-14: `pending_skip_events.jsonl` + `pending_skip_24h_latest.json`).
- ✅ dodano jawny gate rolloutu języków: `identical_to_en (translatable)` dla PL/ES musi być poniżej progu przez stabilne okno czasu (auto-policy guardiana).
- ✅ dodano dedykowany repair queue backlogu `identical_to_en` dla PL/ES (DONE 2026-02-13: `identical_to_en_repair_queue.json` + report JSONL).
- ✅ dodano alert stagnacji repair queue (`identical_to_en`) dla braku spadku top backlogu przez >=6h (DONE 2026-02-14: statusd report/doctor/webhook/daily report).
- ✅ ujednolicono semantykę nowego `repair_queue.stagnation` z legacy `repair_stagnation_alert.json` (DONE 2026-02-14: jedno źródło progów i reason/status).
- ✅ operacyjnie ustalić jedno źródło startu guardiana (service/scheduler/manual), aby nie powstawały konkurencyjne starty daemona. → DONE 2026-02-14: `i18n_start_all.sh` — kanoniczny skrypt start/stop/restart/status.
- ✅ po 24h obserwacji dostroić progi `STATUSD_REPAIR_QUEUE_STAGNATION_*` (window/min_samples/min_drop) do realnego tempa spadku backlogu. → DONE 2026-02-14: defaults OK (HOURS=6, MIN_SAMPLES=6, MIN_DROP=1).

## 🧭 ANEKS ORKIESTRACJI TRYBÓW (wszystkie funkcje workera)

Ten aneks odpowiada na wymaganie: **tryby i losowanie języków mają działać nie tylko dla tłumaczeń, ale dla wszystkich zadań workera** (migracja, tworzenie/aktualizacja kluczy, operacje `.lua`, analizy postępu, quality, sync).

## O1) Jedna maszyna stanów (State Machine)

Worker ma działać jako jedna maszyna stanów z poniższymi domenami pracy:

1. `MIGRATION`
   - skan kategorii,
   - migracja `.lua` / kodu do `i18nKey`,
   - wykrywanie braków i kandydatów.

2. `KEY_MANAGEMENT`
   - tworzenie nowych kluczy,
   - aktualizacja istniejących kluczy,
   - compact/normalizacja mapowań.

3. `TRANSLATION_SYNC`
   - synchronizacja plików językowych z EN,
   - przygotowanie brakujących wpisów.

4. `AUTO_TRANSLATE`
   - tłumaczenia automatyczne,
   - fallback GT/TM,
   - guard tokenów i quality gate.

5. `VALIDATION_QUALITY`
   - walidacja językowa,
   - spotcheck/grammarfix,
   - quality audit i naprawy.

6. `ANALYTICS_REPORTING`
   - liczenie KPI,
   - raport postępu,
   - odświeżenie sekcji statusu.

## O2) Reguły przełączania trybów (po zakończeniu pracy)

Przełączanie ma być warunkowe i deterministyczne:

1. `MIGRATION` → `KEY_MANAGEMENT`
   - gdy kategoria migracji zakończona lub brak nowych plików do migracji.

2. `KEY_MANAGEMENT` → `TRANSLATION_SYNC`
   - gdy brak zaległych operacji kluczy dla aktywnej kategorii.

3. `TRANSLATION_SYNC` → `AUTO_TRANSLATE`
   - gdy pliki językowe dla danej kategorii są zsynchronizowane.

4. `AUTO_TRANSLATE` → `VALIDATION_QUALITY`
   - po batchu tłumaczeń albo po przekroczeniu progu `guard_fail`/`suspicious`.

5. `VALIDATION_QUALITY` →
   - `AUTO_TRANSLATE` (gdy nadal są pending tłumaczeń),
   - albo `MIGRATION` (gdy tłumaczenia na danej kategorii są domknięte, a są inne pending migracje),
   - albo `ANALYTICS_REPORTING` (gdy brak pracy operacyjnej).

6. `ANALYTICS_REPORTING` → następny tryb wg dispatchera priorytetów.

## O3) Priorytety dispatchera (globalnie)

1. Krytyczne błędy jakości/tokenów (natychmiastowy `VALIDATION_QUALITY`).
2. Blokery migracji/kluczy (`MIGRATION`/`KEY_MANAGEMENT`).
3. `TRANSLATION_SYNC` dla kategorii gotowych do tłumaczeń.
4. `AUTO_TRANSLATE` wg tierów językowych.
5. `ANALYTICS_REPORTING` i housekeeping.

## O4) Rotacja języków i kategorii — nie tylko tłumaczenia

Wymagana rotacja ma obejmować wszystkie domeny pracy:

1. **Języki (`LANG/FOCUS/random`)** sterują:
   - `TRANSLATION_SYNC`,
   - `AUTO_TRANSLATE`,
   - `VALIDATION_QUALITY`.

2. **Kategorie (`FORCE/random`)** sterują:
   - `MIGRATION`,
   - `KEY_MANAGEMENT`,
   - analizą postępu per-kategoria.

3. Dispatcher ma wspierać tryb mieszany:
   - np. `MIGRATION` dla `scripts` + potem `AUTO_TRANSLATE` dla `pl/es` tej samej kategorii.

## O5) Definicja „kategoria zakończona”

Kategoria uznana za zakończoną dopiero gdy spełnia wszystkie warunki:

1. `MIGRATION`: brak pending migracji + brak wymaganych poprawek kluczy.
2. `KEY_MANAGEMENT`: brak konfliktów i brak nowych braków mapowań.
3. `TRANSLATION_SYNC`: wszystkie aktywne języki mają zsynchronizowane klucze.
4. `AUTO_TRANSLATE`: pending tłumaczeń poniżej progu roboczego.
5. `VALIDATION_QUALITY`: brak krytycznych błędów token/placeholder/pipe.

Dopiero wtedy worker przechodzi do następnej kategorii pracy.

## O6) `I18N_STATUS.md` — mapowanie sekcji do trybów

W jednym pliku statusu, ale z jasnym mapowaniem:

1. `LIVE`
   - zawsze: aktualny tryb, etap, kategoria, plik, heartbeat, ETA.

2. `MIGRATION`
   - aktywna gdy tryb `MIGRATION`/`KEY_MANAGEMENT`.
   - zawiera: pending, skip/backoff, ostatni rezultat kategorii.

3. `TRANSLATION`
   - aktywna gdy tryb `TRANSLATION_SYNC`/`AUTO_TRANSLATE`/`VALIDATION_QUALITY`.
   - zawiera: język, plik, translated/skipped/guard_fail, no-progress.

4. `QUALITY`
   - zawsze obecna: score, issue types, top ryzyka, status krytyczny.

5. `HISTORY`
   - ostatnie akcje z wyraźnym tagiem domeny (`MIGRATION`, `KEY`, `SYNC`, `AUTO`, `QUALITY`).

Reguła: sekcje nieaktywne mają znacznik `inactive` z powodem, a nie stare dane udające aktualne.

## O7) Guardian — wsparcie trybów wielodomenowych

`guardian_profile.json` musi obsłużyć profile nie tylko tłumaczeniowe:

1. `translations_general` (wszystkie języki, bootstrap priority: `es`, `pl`),
2. `translations_pl_es` (pilot/hotfix),
3. `translations_random` (wszystkie języki),
4. `migration_only`,
5. `hybrid` (migracja + tłumaczenia),
6. `quality_repair`,
7. `auto` (wybór profilu przez policy engine na podstawie metryk).

Guardian ma dobierać profil wg stanu:

- gdy `pending_skip` dominuje i brak nowych migracji → profil tłumaczeniowy,
- gdy pojawią się nowe braki kluczy/migracje → profil migracyjny/hybrid,
- gdy quality krytyczne rośnie → `quality_repair`.

## O8) 3. daemon — wsparcie orkiestracji

3rd daemon (`i18n-statusd`) ma wspierać orkiestrację poprzez:

1. agregację metryk z wszystkich domen pracy,
2. wyliczanie rekomendowanego trybu/profilu,
3. wykrywanie niespójności statusu (`LIVE` vs domeny),
4. publikację jednego, czytelnego `I18N_STATUS.md`.

## O9) Backlog implementacyjny (doprecyzowany)

### P0 (krytyczne)
1. Ujednolicić dispatcher i przejścia między domenami (`MIGRATION`/`KEY`/`SYNC`/`AUTO`/`QUALITY`).
2. Dodać formalny warunek „kategoria zakończona” (5 warunków z O5).
3. ✅ Zmapować każdy tryb do sekcji `I18N_STATUS.md` z `active|inactive` (DONE 2026-02-13; + `status_sections_latest.json`).
4. ✅ Dodać `strict_hourly_window` do raportu baseline (DONE 2026-02-13).
5. ✅ Dodać `strict_hourly_window` do telemetry statusu (LIVE + KPI) (DONE 2026-02-13).
6. ✅ Przy wydzieleniu `statusd`: utrzymać ten sam kontrakt i dodać alerting na tym źródle — DONE (2026-02-13: i18n-statusd.sh z doctor + audit trail).
7. ✅ Dodać debounce/cooldown/retry-backoff restartów guardiana dla triggera `mtime` + metryki `restart_cause` (DONE 2026-02-13; z singleton run-lock).

### P1
7. ✅ Rozszerzyć profile guardiana o wszystkie domeny pracy (DONE 2026-02-13: 6 profili w `guardian_profiles/`).
8. ✅ Dodać policy engine wyboru profilu (`auto`) na podstawie metryk (DONE 2026-02-13; fix triggera `translations_random` pod `languages[].completion_pct`).
9. ✅ Dopiąć logi historii z tagami domen (`MIGRATION`, `KEY`, `SYNC`, `AUTO`, `QUALITY`) — DONE 2026-02-14: `_derive_domain()` w `i18n_status.py` automatycznie dodaje pole `domain` do każdego wpisu `log-op` i `log-error` na podstawie phase/stage.
10. ✅ Dodać gate `identical_to_en (translatable)` do decyzji `translations_random` (DONE 2026-02-13; threshold konfigurowany w `guardian_profiles/auto.json`).
11. ✅ Dodać repair queue `identical_to_en (translatable)` dla PL/ES (DONE 2026-02-13: `identical_to_en_repair_queue.json` + `identical_to_en_repair_queue_report.jsonl`).

### P2
10. ✅ Wdrożyć `i18n-statusd` MVP (read-only telemetry + rendering jednego statusu) — DONE 2026-02-13: `i18n-statusd.sh` (rozszerzony do 8 modułów).
11. ✅ Dodać `status doctor` (spójność LIVE/sekcji) — DONE 2026-02-13: `--doctor` mode z 7 checkami.
12. ✅ Dodać webhook alerting dla `stuck/no_progress` + `doctor_critical` (DONE 2026-02-13: `STATUSD_WEBHOOK_URL`/`.statusd_webhook_url`, `statusd_alert_state.json`, `--alert-check`).
13. ✅ Dodać dzienny raport operatorski 24h (DONE 2026-02-13: `--daily-report`, `statusd_daily_report.json`, `statusd_daily_report.md`).
14. ✅ Ustabilizować źródło `pending_skip_share` dla 24h przez dedykowany artefakt (DONE 2026-02-14): `log_pending_skip_event()` → `pending_skip_events.jsonl`, `compute_pending_skip_24h()` → `pending_skip_24h_latest.json` (co 10 cykli).

## O10) Kryteria odbioru (Definition of Done dla tego zakresu)

1. Worker przełącza tryby między wszystkimi domenami pracy, nie tylko tłumaczeniami.
2. Przejście do kolejnej kategorii następuje dopiero po spełnieniu warunków zakończenia.
3. `I18N_STATUS.md` pokazuje jednocześnie pełny obraz i brak mieszania danych „starych jako live”.
4. Guardian potrafi uruchomić właściwy profil dla aktualnej domeny pracy.
5. Operator bez znajomości logów rozumie w 30-60 s co worker robi i dlaczego.

## 1) Cel dokumentu

Ten dokument łączy:
1. analizę rozjazdu między `I18N_STATUS.md` a realnym stanem workera,
2. plan uporządkowania statusu w jednym `I18N_STATUS.md`,
3. plan rozbudowy guardiana,
4. plan wdrożenia „3. daemona” wspierającego worker+guardian.

Docelowo status ma być czytelny dla człowieka i deterministyczny (jedno źródło prawdy), a automatyzacja ma działać stabilnie bez ręcznych interwencji.

---

## 2) Analiza: `I18N_STATUS.md` vs dane runtime

## 2.1 Źródła danych

- Dashboard markdown: `I18N_STATUS.md`
- Live runtime: `i18n/status/worker_state.json`
- Operacje cykli: `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/ops.jsonl`
- Błędy tłumaczeń: `i18n/status/errors.jsonl`, `i18n/status/translation_guard_report.jsonl`
- Stan kategorii/skip: `.i18n_category_state.json`
- Log watchdoga: `guardian.log`

## 2.2 Główne niespójności

1. **Status LIVE mówi MIGRATION/pending_skip**, ale w tym samym dashboardzie są sekcje sugerujące aktywne tłumaczenie (`Aktywny folder tłumaczeń`, `Ostatnie przetłumaczone klucze`) bez jasnego rozdziału czasu i fazy.
2. **Sekcje dublują się logicznie** (`Etap 1 vs Etap 2` oraz kolejne bloki etapów/checklist), co utrudnia szybkie odczytanie „co dzieje się teraz”.
3. **Mieszanie danych historycznych i LIVE** – użytkownik nie odróżnia, czy liczby są bieżące, z ostatniego cyklu, czy z poprzedniej epoki pracy workera.
4. **Brak kontraktu „freshness”** (TTL) per sekcja – nie wiadomo, które dane są świeże, a które tylko ostatnio zapisane.
5. **Generator statusu jest monolityczny** (duży blok w `update_github_status()`), więc trudno utrzymać spójność sekcji i testować je osobno.

## 2.3 Wnioski operacyjne

- Obecny dashboard jest bogaty informacyjnie, ale „nieliniowy poznawczo” dla operatora.
- Potrzebny jest **jeden status z czytelnymi sekcjami domenowymi** oraz jasna etykieta czasu i źródła dla każdej sekcji.
- Przed wykonaniem zadania (cyklu) system musi aktualizować „stan wejścia” i dopiero potem wykonywać pracę – obecnie to nie jest widoczne dla operatora.

---

## 3) Plan naprawy statusu (jeden `I18N_STATUS.md`)

## 3.1 Docelowe artefakty statusowe

- Jedyny artefakt operatorski: `I18N_STATUS.md`.
- Układ sekcji stały: `META`, `LIVE`, `MIGRATION`, `TRANSLATION`, `QUALITY`, `HISTORY`.
- Sekcje `MIGRATION` i `TRANSLATION` zawsze widoczne, ale z flagą `active|inactive`.





## 3.3 Kolejność aktualizacji (przed wykonaniem zadania)

Wymagany flow cyklu:
1. `pre_cycle_snapshot` (zapis stanu wejścia),
2. wybór zadania (dispatch),
3. wykonanie zadania,
4. `post_cycle_snapshot`,
5. render markdownów.

Dzięki temu operator zawsze widzi „zanim worker zaczął” i „po cyklu” – bez domysłów.

## 3.4 Refactor generatora

- Rozbić monolit `update_github_status()` na moduły:
   - `build_meta_section()`
  - `build_live_section()`
  - `build_migration_section()`
  - `build_translation_section()`
  - `build_quality_section()`
   - `build_history_section()`
   - `render_single_status_md()`
- Każda funkcja ma własny test kontraktu wejście/wyjście.

## 3.5 KPI i akceptacja

Akceptujemy wdrożenie, gdy:
- użytkownik w <30 sekund odczyta: „co worker robi teraz”, „co zrobił ostatni cykl”, „czy tłumaczenia stoją”.
- brak konfliktu „LIVE=MIGRATION” vs „sekcje tłumaczeń wyglądają jak aktywne teraz”.
- freshness jest jawny i automatycznie oznacza stale data.

---

## 4) Plan rozbudowy guardiana

## 4.1 Problemy obecne

1. Guardian monitoruje głównie PID/liveness, a nie „czy worker robi postęp”.
2. Restart command ma na sztywno profil uruchomienia workera (brak łatwego profilu trybów).
3. Brak polityki restartów opartej o objawy degradacji (np. długi `pending_skip`, heartbeat stale, no-progress).
4. Brak rozdzielenia „watchdog” od „publishera statusu”.

## 4.2 Docelowe funkcje guardiana (v4)

1. **Health checks wielowarstwowe**
   - PID alive,
   - heartbeat age,
   - progress delta (translated/migrated w oknie),
   - guard_fail/no_progress threshold.

2. **Policy engine**
   - `healthy`, `degraded`, `stuck`, `recovering`.
   - akcje: noop / soft-restart / hard-restart / cooldown.

3. **Profile run-mode**
   - profile w pliku konfiguracyjnym (np. `guardian_profile.json`):
     - `pilot_es_pl`,
     - `all_langs`,
     - `migration_only`,
     - `quality_repair`.
   - guardian uruchamia worker wg aktywnego profilu, nie hardcoded flag.

4. **Lepsza observability**
   - JSON log guardiana + licznik restart causes,
   - metryki: restart count, mean time to recovery, push success rate.

5. **Bezpieczny push statusów**
   - separacja commitów statusowych od roboczych,
   - fallback przy push fail z jawnie logowanym powodem.

## 4.3 Etapy wdrożenia

- Etap A: dodać health checks heartbeat/progress.
- Etap B: profile uruchomienia i odczyt config.
- Etap C: policy engine + cooldown.
- Etap D: testy chaos (kill worker, stale heartbeat, brak postępu).

## 4.4 KPI i akceptacja

- brak pętli restartów,
- MTTR (czas powrotu) < 2 min,
- push success > 99%,
- brak „false positive restart” przy zdrowym workerze.

---

## 5) Plan dla 3. daemona (wspierającego worker+guardian)

## 5.1 Stan obecny

- Aktywny daemon: `i18n-guardian.service` (guardian + worker pod nim).
- Nie znaleziono aktywnej usługi „status pusher” jako osobnego daemona.
- Historycznie w dokumentacji pojawia się `i18n_status_pusher.sh`, ale obecnie nie jest aktywnie używany.

## 5.2 Rola 3. daemona (propozycja)

Wprowadzić **`i18n-statusd`** (3. daemon) jako „Status & Orchestration Assistant”:

Funkcje:
1. render i publikacja jednego `I18N_STATUS.md` niezależnie od workera,
2. kontrola freshness i alerty staleness,
3. agregacja quality/guard/no-progress i rekomendacje,
4. opcjonalne generowanie bezpiecznych komend do `worker_commands.txt` (np. `UNFOCUS`, `LANG:random`) na podstawie reguł.

## 5.3 Dlaczego osobny daemon

- Odciąża workera (worker robi pracę i18n, nie ciężki rendering raportów).
- Upraszcza guardiana (watchdog nie musi implementować logiki dashboardu).
- Daje jeden punkt odpowiedzialny za czytelność statusu i telemetry.

## 5.4 Granice odpowiedzialności

- Worker: wykonanie migracji/tłumaczeń.
- Guardian: liveness/recovery + push.
- 3rd daemon (`i18n-statusd`): status/telemetria/rekomendacje.

## 5.5 Etapy wdrożenia 3rd daemon

1. MVP: read-only renderer statusów + freshness alerts.
2. v2: agregacja KPI i dzienny raport operatorski.
3. v3: rekomendacje komend (bez auto-wykonania).
4. v4 (opcjonalnie): auto-actions za feature flag (`auto_actions=true`).

## 5.6 KPI i akceptacja

- status odświeżany regularnie (np. co 60s),
- stale detection działa i jest widoczny,
- operator dostaje jeden „executive summary” bez czytania 600+ linii.

---

## 6) Backlog wdrożeniowy (dla Claude)

## P1 (must-have)

1. Uporządkować jeden `I18N_STATUS.md` (bez splitu na wiele plików).
2. Refactor `update_github_status()` na moduły renderujące.
3. Guardian: profile startu workera z configa.
4. Guardian: health check heartbeat+progress, nie tylko PID.

## P2 (should-have)

5. JSON telemetry guardiana (`guardian_metrics.jsonl`).
6. 3rd daemon MVP (`i18n-statusd`) – read-only status render.
7. CLI `status doctor` (diagnoza niespójności statusów).

## P3 (nice-to-have)

8. Auto-rekomendacje komend runtime.
9. ✅ Alerting (Telegram/Discord/webhook) przy stuck/no-progress — DONE 2026-02-13 (webhook + cooldown/deduplikacja).

---

## 7) Plan testów i walidacji

1. **Test spójności statusów**
   - porównanie wartości LIVE z `worker_state.json` i ostatnim cyklem.
2. **Test świeżości**
   - symulacja stale heartbeat i oznaczenie `stale=true`.
3. **Test watchdoga**
   - kill worker -> restart,
   - brak postępu -> recovery policy.
4. **Testy regresji markdown**
   - parser smoke-test jednego `I18N_STATUS.md` + walidacja sekcji `active|inactive`.

---

## 8) Ryzyka i mitigacje

- Ryzyko: dalsze mieszanie źródeł danych.
  - Mitigacja: tylko JSON `i18n/status` jako source-of-truth.
- Ryzyko: zbyt częste restarty.
  - Mitigacja: cooldown + progi + policy states.
- Ryzyko: 3rd daemon dubluje logikę.
  - Mitigacja: twardy podział odpowiedzialności i interfejsy danych.

---

## 9) Szybkie decyzje architektoniczne (do zatwierdzenia)

1. Czy `I18N_STATUS.md` zostaje jako landing + linki, czy pełny raport?
2. Czy 3rd daemon może automatycznie wpisywać komendy do `worker_commands.txt`, czy tylko rekomenduje?
3. Jakie progi oznaczają `stuck` (np. 15 min bez postępu)?

---

## 10) Definicja Done (całość)

- Status czytelny i uporządkowany domenowo w jednym pliku,
- Guardian zarządza workerem na podstawie zdrowia, nie tylko PID,
- 3rd daemon dostarcza telemetry i świeże statusy,
- dokumentacja operacyjna pokrywa uruchamianie, debug, recovery i rollback.
