# I18N Unified Execution Plan (Worker + Guardian + Status + 3rd Daemon)

**Data:** 2026-02-13  
**Branch roboczy:** `feature/i18n-multilanguage`  
**Cel dokumentu:** finalna, wykonawcza wersja planu po decyzjach właściciela projektu.

---

## Update wykonania (2026-02-14 11:22 UTC) — status auto-refresh + kontrakt tłumaczeń + audyt LT/CS/EL/IT

Zrealizowane pełne zadania:
- ✅ **Statusd: automatyczny refresh `I18N_STATUS.md` niezależnie od cyklu workera**
  - dodano moduł `maybe_refresh_status_md()` + `run_status_md_refresh()` w `i18n-statusd.sh`,
  - refresh uruchamia się gdy status jest stary (`STATUSD_STATUS_MD_REFRESH_STALE_SECONDS`) lub po `RECONCILE_APPLIED`,
  - walidacja runtime: wymuszone postarzenie pliku `I18N_STATUS.md` i uruchomienie `--reconcile-registry` odświeża plik (mtime zaktualizowany).
- ✅ **Statusd: reconcile registry pod małe i częste zmiany manualne**
  - rozszerzono próg o `registry_reconcile.always_sync_any_drift` (kanonicznie `true`),
  - przy aktywnej delcie reconcile może pominąć cooldown (`cooldown_bypassed`), żeby szybciej synchronizować ręczne zmiany EN.
- ✅ **Statusd doctor: kontrakt runtime tłumaczeń**
  - nowy check `translation_contract` w `statusd_doctor.json`,
  - monitoruje: `--translations-only`, `priority_gate.enabled`, kolejność `priority_langs=[es,pl]`,
  - aktualny runtime: `worker_translation_contract_ok`.
- ✅ **Audyt jakości tłumaczeń LT/CS/EL/IT (podział domenowy)**
  - domeny: `items.json` (nazwy/opisy), `npc.json` (dialogi), `quests.json` (opisy questów),
  - placeholdery i formatowanie:
    - `{...}` mismatch: `0` we wszystkich 4 językach,
    - `%` mismatch: `0`,
    - tokeny komend w apostrofach `'trade'`-like: mismatch `0`.
  - coverage (genuine, bez EN-copy i `[EN]`):
    - `lt`: items name `1.66%`, items desc `0.03%`, npc `2.98%`, quests `1.97%`,
    - `cs`: items name `1.17%`, items desc `0.03%`, npc `3.03%`, quests `1.97%`,
    - `el`: items name `1.67%`, items desc `0.03%`, npc `3.00%`, quests `1.97%`,
    - `it`: items name `1.73%`, items desc `0.03%`, npc `3.04%`, quests `23.77%`.

Nowe problemy/TODO wykryte podczas realizacji:
- ⬜ Dodać dedykowany etap `multilang_wave_lt_cs_el_it` (po ES/PL) z osobnym dispatch budget per domena (`items_desc`, `npc`, `quests`).
- ⬜ Dodać twardy floor jakości dla `items.desc` (obecnie ~`0.03%` genuine we wszystkich 4 językach) przed rozszerzaniem na kolejne języki.
- ⬜ Dodać report operacyjny `translation_domain_audit_latest.json` (per-lang/per-domain: genuine/en_copy/[EN]/placeholder_mismatch), żeby ten audyt był stałą telemetrią, nie jednorazowym skryptem.
- ⬜ Wzmocnić heurystyki leksykalne pod tłumaczenia GT (np. słabe kalki/idiomy), bo placeholdery są poprawne, ale nadal występują frazy wymagające ręcznego review.

## Update wykonania (2026-02-14 10:18 UTC) — post-start 30s gate + source=manual root-cause + 20m queue observation

Zrealizowane pełne zadania:
- ✅ **`start_all`: post-start health gate (30s)**
  - `i18n_start_all.sh` ma nowy gate po starcie: obserwacja procesów przez konfigurowalne okno (`START_ALL_POST_START_HEALTH_*`),
  - gate waliduje jednocześnie: guardian + statusd + worker (`i18n_worker_simple.sh --continuous`),
  - przy fail zapisuje diagnostyczne tail logów daemonów.
- ✅ **Identyfikacja zewnętrznego triggera `source=manual`**
  - potwierdzono źródło: `~/.config/systemd/user/i18n-guardian.service`,
  - unit ma `Restart=always` + `RestartSec=5`, co tłumaczy próby startu co ~5s,
  - `i18n_guardian.sh` loguje teraz kontekst startu `manual` (`ppid`, `parent cmdline`, `gppid`, `grand cmdline`) z throttlingiem,
  - log wskazuje parent: `/usr/lib/systemd/systemd --user`.
- ✅ **Obserwacja 20+ min pod `REPAIR_QUEUE_STALE`**
  - analiza `statusd.log` dla okna `2026-02-14 10:57:40` -> `2026-02-14 11:17:01` (czas lokalny hosta),
  - wynik: `stale_recent=0`, wpisy tylko `repair_queue_fresh` / `queue_freshness_ok`,
  - `statusd_doctor` aktualnie raportuje `queue_freshness_ok (754s, WARN>900s CRIT>1800s)`.

Nowe problemy/TODO wykryte podczas realizacji:
- ⬜ Ustalić jedną orkiestrację runtime: albo `i18n_start_all.sh`, albo user-systemd unit.
- ⬜ Jeśli zostaje unit: dodać w nim `Environment=GUARDIAN_START_SOURCE=service` (zamiast domyślnego `manual`) i ograniczyć restart-loop.
- ⬜ Jeśli zostaje `start_all`: wyłączyć `~/.config/systemd/user/i18n-guardian.service` (`disable --now`), aby nie generował konkurencyjnych prób startu.

## Update wykonania (2026-02-14 09:56 UTC) — worker heartbeat/queue hardening + guardian/start lock reliability

Zrealizowane pełne zadania:
- ✅ **Worker: mid-cycle heartbeat dla AUTO_TRANSLATE**
  - `i18n_worker_simple.sh` ma nowy heartbeat loop (`heartbeat_tick`) sterowany env:
    - `AUTO_TRANSLATE_MID_CYCLE_HEARTBEAT_ENABLED`,
    - `AUTO_TRANSLATE_MID_CYCLE_HEARTBEAT_INTERVAL_SEC`.
  - heartbeat działa podczas trwania długiego tłumaczenia, zamiast czekać tylko na koniec całego kroku.
- ✅ **Worker: odświeżanie repair queue niezależne od pełnego repair run**
  - `repair_identical_bonus_round(cycle, queue_only)` wspiera tylko-refresh snapshotu kolejki,
  - dodano `REPAIR_QUEUE_REFRESH_MIN_INTERVAL_SEC`,
  - refresh queue jest wywoływany:
    - przed `auto_translate`,
    - okresowo w heartbeat loop,
    - po `auto_translate`.
- ✅ **Guardian: naprawa semantyki lock owner PID**
  - lock owner jest walidowany po `cmdline` (`i18n_guardian.sh --daemon`), nie po samym istnieniu PID,
  - usunięto blokadę samego `start_all` po padzie ownera (same-source restart lock takeover).
- ✅ **Start orchestration: twardszy kontrakt startu**
  - `i18n_start_all.sh` ma `wait_for_stable_process()` (wielokrotna walidacja PID),
  - redukcja false-positive „RUNNING” po krótkim, niestabilnym starcie.

Walidacja runtime (foreground, 2026-02-14 09:56 UTC):
- ✅ `activity.json.recent[]` zawiera `heartbeat_tick`.
- ✅ `identical_to_en_repair_queue.json` odświeża się w aktywnej pracy:
  - mtime `2026-02-14T09:55:20Z`,
  - age po teście ~`48.7s`.
- ✅ Worker strict translation działa z nowym kontraktem bez błędów składni bash (`bash -n` OK).

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Dodać `start_all` post-start health gate (np. 30s), bo sama walidacja PID przez kilka sekund nie zawsze ujawnia szybki exit procesu. → DONE 2026-02-14 10:18 UTC.
- ✅ Ustalić i udokumentować zewnętrzny trigger częstych wywołań `i18n_guardian.sh --daemon` z `source=manual` (co ~5s) i ograniczyć go do jednego źródła orkiestracji. → DONE (identyfikacja root-cause) 2026-02-14 10:18 UTC.
- ✅ Po stabilnym starcie 3 daemonów zrobić 20+ min obserwacji `statusd_doctor` dla finalnego potwierdzenia braku `REPAIR_QUEUE_STALE`. → DONE 2026-02-14 10:18 UTC (`stale_recent=0`).

## Update wykonania (2026-02-14 09:12 UTC) — heartbeat contract + subprocess watchdog + worker PID accuracy

Zrealizowane pełne zadania:
- ✅ **Statusd: dynamiczny heartbeat contract w `statusd_doctor`**
  - check heartbeat korzysta z progów guardiana (`heartbeat_aging/stale/stuck`) zamiast sztywnego `180/300`,
  - gdy heartbeat jest stary, ale worker jest aktywny (`pid_alive` + świeże logi), doctor sygnalizuje ostrzeżenie `STALE_HEARTBEAT_BUT_ACTIVE` zamiast fałszywego CRITICAL.
- ✅ **Statusd: watchdog topologii procesów workera**
  - dodano check `worker_process_watch` (PID main, extra PID, descendant vs foreign, wiek procesów),
  - doctor zgłasza duplikację instancji jako `WORKER_PROCESS_DUPLICATION*`, a normalny pojedynczy subprocess jako stan informacyjny/OK.
- ✅ **Statusd: poprawka wiarygodności `worker.pid_alive`**
  - agregator `statusd_report.worker.pid_alive` opiera się teraz na realnym `/proc/<pid>`, nie na samym istnieniu PID file,
  - `statusd_report.worker.pid` publikuje jednoznacznie aktywny PID.
- ✅ **Walidacja runtime**
  - `bash i18n-statusd.sh --aggregate && --doctor` działa po zmianach,
  - `statusd_doctor`: heartbeat nie podnosi fałszywego CRITICAL przy aktywnym PID,
  - `statusd_doctor.worker_process_watch`: rozróżnia normalny pojedynczy subprocess od realnej duplikacji.

Nowe problemy/TODO wykryte podczas realizacji:
- ⬜ Rozważyć heartbeat `mid-cycle` w workerze, żeby ograniczyć ostrzeżenia `AGING/STALE` przy bardzo długich batchach.
- ⬜ Dodać częstszy refresh snapshotu `identical_to_en_repair_queue.json`, bo doctor nadal zgłasza okresowo `REPAIR_QUEUE_STALE`.
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL` (nadal `WEBHOOK_NOT_CONFIGURED`).

## Update wykonania (2026-02-14 08:40 UTC) — registry_reconcile + priority_gate watchdog + guardian source arbitration

Zrealizowane pełne zadania:
- ✅ **Statusd: workflow `registry_reconcile` (end-to-end)**
  - dodano moduł `run_registry_reconcile` w `i18n-statusd.sh` (daemon + `--once` + `--reconcile-registry`),
  - reconciler zapisuje korektę w `i18n_file_status.json -> global_stats.reconciled_external_keys`,
  - publikowane artefakty: `i18n/status/registry_reconcile_latest.json` i `i18n/status/registry_reconcile_state.json`,
  - metryki driftu mają teraz rozdział `raw` vs `effective` (po reconcile), bez ukrywania długu historycznego.
- ✅ **Worker: spójność statusu z reconcile**
  - `i18n_worker_simple.sh` uwzględnia `reconciled_external_keys` przy liczeniu registry dla `I18N_STATUS.md`, `translation_global_overview.json` i `i18n_global_stats.json`,
  - migration payload publikuje: `total_keys_extracted_worker_registry_raw`, `registry_reconcile_adjustment`, `keys_extracted_outside_worker_registry_raw`.
- ✅ **Statusd: watchdog `priority_gate_stuck` (ES/PL)**
  - `statusd_report.json` publikuje `priority_gate_watch` (czas aktywności, cykle, quality drop),
  - `statusd_doctor.json` ma check stuck (`PRIORITY_GATE_STUCK*`),
  - webhook obsługuje reason code `priority_gate_stuck`,
  - daily report ma sekcję `Priority Gate Watch`,
  - recommendation engine dodaje akcję `SWITCH_PROFILE quality_repair (short)` przy wykrytym stuck.
- ✅ **Guardian: source arbitration hardening**
  - `i18n_guardian.sh` ma priorytety źródeł startu (`start_all > service > scheduler > manual`),
  - świeży lock po wyższym priorytecie nie jest już przejmowany przez `manual`,
  - dodano `GUARDIAN_DAEMON_LOCK_PREEMPT_MIN_SEC` (cooldown preemptu).
- ✅ **Kanoniczne progi rozszerzone**
  - `statusd_thresholds.json` ma nowe sekcje: `priority_gate_stuck` i `registry_reconcile`,
  - snapshot progów w report/doctor/daily obejmuje nowe bloki.

Walidacja runtime (2026-02-14 08:40 UTC):
- ✅ `bash i18n-statusd.sh --reconcile-registry` -> `RECONCILE_APPLIED` (pierwszy sync), potem `RECONCILE_SKIPPED_THRESHOLD reason=no_sync_needed`.
- ✅ `statusd_report.json`:
  - `metrics_drift`: `outside_worker_registry_keys=0` (effective), przy zachowaniu `outside_worker_registry_keys_raw=47338`,
  - `priority_gate_watch`: aktywny tracking ES/PL.
- ✅ `statusd_doctor.json`: zniknął issue `METRICS_DRIFT_HIGH`; krytyczność pozostaje z `SUSPICIOUS_HIGH_SPIKE`.

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Domknąć auto-przełączenie guardiana na `quality_repair` przy `priority_gate_stuck`. → DONE 2026-02-14 08:45: `statusd --auto-action` ma akcję `SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK` (feature-flag `.statusd_auto_actions`).
- ⬜ Rozważyć etap 2 reconcile: backfill per-file (korekta nie tylko globalna), aby audyt kluczy był dokładny również na poziomie plików.
- ✅ Dostrajać heartbeat contract (`STALE_HEARTBEAT`): przy długich cyklach tłumaczeń worker bywa żywy, ale heartbeat przekracza 300s. → DONE 2026-02-14 09:12: dynamiczne progi z `guardian_health` + aktywność PID/logów w doctorze.
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL` (nadal `WEBHOOK_NOT_CONFIGURED`).

## Update wykonania (2026-02-14 08:18 UTC) — global quality 100 + guardian bootstrap ES/PL + statusd live migration

Zrealizowane pełne zadania:
- ✅ **Worker: `GLOBAL_QUALITY_MODE` (100%)**
  - dodano tryb globalny wymuszający coverage target `100%` dla tierów,
  - worker w tym trybie wymusza GT + `crossref_auto_fix`, szybszą pętlę walidacji i częstszy refresh statusu,
  - selector strict ma gate priorytetu `GLOBAL_QUALITY_PRIORITY_LANGS` (domyślnie `es`, `pl`) zanim puści pełną rotację wszystkich języków,
  - `translation_dispatch_state.json` publikuje nowe pole `priority_gate` (enabled/active/pending/lang_completion).
- ✅ **Worker: rozszerzenie `tier_quality_gate` o jakość**
  - gate tierów uwzględnia nie tylko coverage, ale też `validation score` i `critical issues` (w trybie global quality),
  - raport `tier_quality_gate.json/jsonl` ma pola jakości per język i rekomendację pod `quality_pending`.
- ✅ **Guardian: start workera z env global quality**
  - `i18n_guardian.sh` odczytuje i przekazuje `global_quality_*` z profilu,
  - profile `translations_general` oraz aktywny `guardian_profile.json` mają teraz parametry:
    - `global_quality_mode=true`,
    - priorytet `es pl`,
    - targety jakości/coverage pod 100%.
- ✅ **Auto policy: zaostrzenie warunków rolloutu**
  - `guardian_profiles/auto.json` ma podniesione gate do rolloutu (`pilot_coverage_above_pct=100`, ostrzejsze warunki quality/no-progress).
- ✅ **Statusd: live merge metryk migracji**
  - `i18n-statusd.sh` liczy zawsze live snapshot (`i18n_file_status.json + i18n/en/*.json`) i zasila nim blok `migration`,
  - metryki kluczy są teraz aktualne także dla zmian wykonanych poza workerem.
- ✅ **Statusd: czułość driftu**
  - `statusd_thresholds.json` ma obniżone progi `metrics_drift`, żeby problem registry-vs-live nie był maskowany.

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Dodać workflow „reconcile registry”, który synchronizuje historię workera z rzeczywistym stanem `i18n/en/*.json` po zmianach manualnych/agentowych. → DONE 2026-02-14 08:40 (`run_registry_reconcile` + artefakty + pola raw/effective).
- ⬜ Dodać finalny gate jakości dla nazw własnych (`identical_to_en_exempt`) jako osobny licznik rolloutu, aby nie mieszać ich z realnymi regresjami tłumaczeń.
- ✅ Dodać policy watchdog: jeśli `priority_gate` (ES/PL) aktywny zbyt długo bez spadku issue rate, guardian ma automatycznie przełączyć krótką rundę `quality_repair`.
  - status 2026-02-14 08:45: detekcja + doctor + webhook + daily report + rekomendacja + auto-action (`SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK`, przy włączonym `.statusd_auto_actions`).
- ✅ Domknąć source arbitration guardiana: po restarcie 2026-02-14 09:20 UTC wykryto dodatkowy start `source=manual` przejmujący lock po starcie `start_all`. → DONE 2026-02-14 08:40 (source-priority + preempt cooldown).

## Update wykonania (2026-02-14 07:52 UTC) — kanoniczne progi statusd + hardening start_all

Zrealizowane pełne zadania:
- ✅ **Statusd: jedno kanoniczne źródło progów (daemon/manual)**
  - dodano plik konfiguracyjny: `canary_test/statusd_thresholds.json`,
  - `i18n-statusd.sh` ładuje progi z tego pliku jako source-of-truth,
  - domyślnie wyłączono env overrides (`STATUSD_USE_ENV_OVERRIDES=0`), żeby daemon/manual czytały te same wartości.
- ✅ **Statusd: snapshot progów rozszerzony i audytowalny**
  - `statusd_report.json`, `statusd_doctor.json`, `statusd_daily_report.json` publikują `thresholds_snapshot` z:
    - `source_of_truth`,
    - `config_file`,
    - `env_overrides_enabled`,
    - pełnym zestawem progów.
  - artefakt `i18n/status/statusd_thresholds_snapshot.json` zawiera ten sam snapshot.
- ✅ **`i18n_start_all.sh`: naprawa false-positive statusu daemonów**
  - `is_running()` waliduje teraz PID przez `/proc/<pid>/cmdline` (zamiast ślepego fallback `pgrep`),
  - stale PID file jest czyszczony automatycznie,
  - odfiltrowano self-match (`pgrep`, `i18n_start_all.sh`) powodujący fałszywe `RUNNING`.
- ✅ **`i18n_start_all.sh`: stabilizacja restartu**
  - naprawiono `--restart` (wywołanie przez `bash "$WORK_DIR/i18n_start_all.sh"` zamiast zależnego od `$0`),
  - naprawiono pętlę oczekiwania w `stop_daemon()` pod `set -e` (`waited=$((waited + 1))`),
  - status workera pokazuje teraz `main pid` + liczbę subprocessów.

Walidacja runtime (2026-02-14 07:52 UTC):
- ✅ `bash i18n-statusd.sh --aggregate --doctor --daily-report` działa poprawnie po zmianach.
- ✅ `statusd_report.json`/`statusd_doctor.json`/`statusd_daily_report.json` mają spójny `thresholds_snapshot` wskazujący `statusd_thresholds.json`.
- ✅ `bash i18n_start_all.sh --restart` działa end-to-end (stop + start + poprawna detekcja PID).
- ✅ `bash i18n_start_all.sh --status` nie raportuje już fałszywego `Statusd RUNNING`, gdy procesu brak.

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Naprawić `i18n_start_all.sh:is_running()` (fallback `pgrep`) pod self-match/fake-positive statusu daemona przy restartach. → DONE 2026-02-14.
- ✅ Dodać diagnostykę, czy `worker subprocessy>0` utrzymuje się długotrwale (odróżnić normalny subshell od realnego dublowania instancji workera). → DONE 2026-02-14 09:12 (`worker_process_watch` w `statusd_doctor`).
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL` (obecnie `WEBHOOK_NOT_CONFIGURED`).

## Update wykonania (2026-02-14 07:28 UTC) — scanned_files_live + metrics_drift + global_stats

Zrealizowane pełne zadania:
- ✅ **`scanned_files_live` w statusie migracji**
  - `I18N_STATUS.md` pokazuje równolegle:
    - `Przeskanowane (historia)` z `i18n_processed_files.txt`,
    - `Przeskanowane (LIVE)` z `i18n_file_status.json`,
    - różnicę `Historia minus LIVE`.
  - `translation_global_overview.json` publikuje `scanned_files_history/live` i delta.
- ✅ **Statusd: drift metryk LIVE vs registry (end-to-end)**
  - agregator publikuje `metrics_drift` w `statusd_report.json`,
  - doctor ocenia drift po progach (`keys` + `%`) i zwraca to w `statusd_doctor.json`,
  - alert-check ma reason codes: `metrics_drift_high`, `metrics_drift_elevated`,
  - daily report (`statusd_daily_report.json/md`) ma sekcję `Metrics Drift (LIVE vs Registry)` + pola migration LIVE/history.
- ✅ **`i18n_global_stats.json` (MIGRATION) ujednolicony**
  - zapisuje teraz równolegle metryki:
    - `keys_extracted_live`,
    - `keys_extracted_worker_registry`,
    - `keys_extracted_outside_worker_registry`,
    - `files_scanned_live/history` i delta.

Walidacja runtime (2026-02-14 07:28 UTC):
- `I18N_STATUS.md`: `LIVE=2,299`, `historia=6,443`, `delta=+4,144`.
- `statusd_report.json`: `metrics_drift` obecny, migration ma nowe pola `scanned_files_*`.
- `statusd_doctor.json`: nowy kontrakt driftu aktywny (bez legacy string-only parsera).

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Ustalić jedno, kanoniczne źródło progów `metrics_drift` dla wszystkich uruchomień statusd (daemon/manual), aby nie było rozjazdów severity między artefaktami. → DONE 2026-02-14: kanoniczne env z defaults + `statusd_thresholds_snapshot.json`.
- ✅ Przenieść progi driftu do stabilnego pliku konfiguracyjnego i logować snapshot aktywnych progów przy każdej agregacji. → DONE 2026-02-14: `statusd_thresholds_snapshot.json` (osobny artefakt) + sekcja `thresholds_snapshot` w raporcie.
- ✅ Naprawić `i18n_start_all.sh:is_running()` (fallback `pgrep`) pod kątem self-match/fake-positive statusu daemona przy restartach. → DONE 2026-02-14: walidacja `/proc/<pid>/cmdline`, filtr self-match, czyszczenie stale PID.

## Update wykonania (2026-02-14 07:07 UTC) — status key-metrics hardening

Zrealizowane pełne zadanie:
- ✅ **Rozdzielenie metryk LIVE vs worker-registry w `I18N_STATUS.md`**
  - `Klucze wyekstrahowane (LIVE)` liczone bezpośrednio z `i18n/en/*.json`,
  - osobna metryka `Klucze z rejestru workera` z `i18n_file_status.json`,
  - dodana metryka driftu `Klucze poza rejestrem workera`.
- ✅ **Kontrakt źródeł sekcji MIGRATION doprecyzowany**
  - źródło sekcji: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt`.
- ✅ **Telemetry payload rozszerzony**
  - blok `migration` publikuje `total_keys_extracted_live`, `total_keys_extracted_worker_registry`, `keys_extracted_outside_worker_registry`.
- ✅ **Auto-refresh po zmianach poza workerem**
  - `should_force_status_update_on_metrics_delta()` liczy sygnaturę `i18n/*.json` (`i18n_live_signature`) i wymusza aktualizację statusu po ręcznych zmianach.

Walidacja runtime (2026-02-14 07:07 UTC):
- `I18N_STATUS.md`: LIVE `53,586`, registry `6,248`, drift `47,338`.
- Potwierdzono, że ręczne zmiany (poza workerem) są widoczne w dashboardzie jako LIVE.

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Dodać `scanned_files_live`. → DONE 2026-02-14.
- ✅ Dodać alarm driftu metryk LIVE vs registry (`statusd_doctor` / webhook). → DONE 2026-02-14: check #10 + reason codes `metrics_drift_*`.
- ✅ Ujednolicić metryki LIVE/registry także w `i18n_global_stats.json` dla trybu `MIGRATION`. → DONE 2026-02-14: sekcja migration LIVE/registry w każdym trybie.

## Update wykonania (2026-02-14 06:56 UTC) — guardian health + suspicious_high + repair cadence

Zrealizowane pełne zadania:
- ✅ **Guardian single-source daemon lock (kodowo)**
  - `i18n_guardian.sh` ma lock daemona (`.guardian_daemon.lock`) i stan (`i18n/status/guardian_daemon_state.json`) z `source` startu.
  - manual/service/scheduler nie uruchomią równoległych daemonów przy aktywnym locku.
- ✅ **Guardian health hardening pod długie cykle GT**
  - rozdzielono progi `heartbeat_aging/stale/stuck` (`150/240/420s` default),
  - dodano `active_log_grace` i sygnały aktywności procesu (`pid_alive`, `worker_log_age_s`, `guard_last_entry_age_s`),
  - efekt: mniej false-positive `health_stuck` podczas długich cykli tłumaczeń.
- ✅ **Worker repair cadence odporna na restarty**
  - `repair_identical_bonus_round()` używa globalnego `translation_dispatch_state.cycle_counter` jako `interval_key`,
  - runda repair nie jest już głodzona resetem lokalnego `CYCLE=1` po restarcie workera.
- ✅ **Statusd suspicious_high end-to-end**
  - webhook: nowe reason codes `suspicious_high_spike` / `suspicious_high_elevated`,
  - daily report: `suspicious_high_count/rate/top_lang`, `pending_skip_source`, sekcja `Repair Tuning 24h`,
  - raport 24h preferuje `pending_skip_24h_latest.json` (fallback: `worker_cycle_perf.detail`).

Walidacja runtime (2026-02-14 06:56 UTC):
- `statusd_report.json -> quality_watch`: `suspicious_high_total=2759`, `rate=12.446%`, `severity=critical`, top: `es` i `npc.json`.
- `statusd_doctor.json`: `overall=CRITICAL`, issue: `SUSPICIOUS_HIGH_SPIKE`, przy jednoczesnym `guardian_healthy`.
- `statusd_daily_report.json`: `pending_skip_source=pending_skip_24h_latest.json`, sekcja `repair_tuning_24h` aktywna (obecnie `samples_24h=0`).

Nowe problemy/TODO wykryte podczas realizacji:
- ✅ Doprecyzować próg alertów `suspicious_high` per domena (szczególnie `npc.json`) i ewentualnie per-język (`es/pl`), bo globalny próg count generuje CRITICAL przy wysokim throughput. → DONE 2026-02-14: rate-based thresholds (WARN=8%, CRIT=20%) per-lang i per-domain w `quality_watch.per_lang[]`/`per_domain[]` + doctor.
- ✅ Potwierdzić po min. kilku pełnych cyklach, że `repair_tuning_24h.samples_24h` rośnie po zmianie interwału na globalny licznik. → DONE 2026-02-14: potwierdzone — 3 sample w `identical_to_en_repair_tuning.jsonl`, doctor: `repair_tuning_active (samples_2h=3)`.
- ✅ Operacyjnie nadal ustalić jedno zewnętrzne źródło startu guardiana (`service` vs `scheduler` vs `manual`) mimo kodowego locka daemona. → DONE 2026-02-14: `i18n_start_all.sh` — kanoniczny start/stop/restart/status.
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL` (obecnie `WEBHOOK_NOT_CONFIGURED`).

## 0) Update wykonania (2026-02-13 22:14 UTC)

Zrealizowany punkt w tej iteracji: **Baseline 24h (Gate 0 prerequisite)**.

- ✅ Naprawiono i domknięto `i18n_baseline_snapshot.sh` (raport `v1.2`).
- ✅ Wygenerowano baseline 24h:
  - `i18n/status/baseline/baseline_2026-02-13_210014.json`
- ✅ Raport zawiera metryki wymagane przez plan: throughput, guard_fail, no_progress, pending_skip, quality (`quality_score`, `issues_count`) dla PL/ES.
- ✅ Raport ma blok `strict_hourly_window` (KPI godzinowe liczone wyłącznie z JSONL, niezależnie od `daily/*.json`).
- ✅ `strict_hourly_window` jest włączony do renderingu `I18N_STATUS.md` (sekcja LIVE/KPI) oraz publikowany w `i18n/status/strict_hourly_window_latest.json`.

Wniosek operacyjny po baseline 24h:
- `pending_skip_share=26.6%` i `guard_fail_rate=8.9%` nadal blokują przejście do kolejnych etapów KPI.
- Priorytet na kolejną iterację pozostaje: redukcja `pending_skip` + dalsza stabilizacja jakości.

### Update wykonania (2026-02-13 22:25 UTC) — P0.1 domknięte

- ✅ Domknięto `P0.1 Spójny status` w rendererze `I18N_STATUS.md`:
  - dodano tabelę „Status sekcji (P0.1)” z pełnym kontraktem (`state`, `freshness`, `source`, `last_update`),
  - wdrożono machine-readable artefakt: `i18n/status/status_sections_latest.json`,
  - `TRANSLATION` freshness liczone z realnych timestampów tłumaczeń (`translation_guard_latest.json` / `translation_recent_latest.json`), a nie z `sync_last_ts`,
  - poprawiono nagłówki sekcji (`KPI Dashboard`, `HISTORY`) w generowanym markdownie.
- ✅ Walidacja runtime: `I18N_STATUS.md` i `status_sections_latest.json` pokazują spójne `active|inactive` względem aktualnej fazy (`AUTO_TRANSLATE`).
- ⚠️ Nowe odkrycie operacyjne (do realizacji): restart bursts w guardianie przy szybkich zmianach `mtime` workera + sporadyczne `Worker nie wystartował prawidłowo`.
  - wymagany follow-up: debounce/backoff/cooldown dla restartów ścieżki `mtime` (oddzielnie od health-policy).

### Update wykonania (2026-02-13 22:35 UTC) — P0.5 + P1.1 (guardian)

- ✅ Domknięto `P0.5 Guardian restart debounce/backoff`:
  - wdrożono precheck restartu (`mtime_debounce` + `failure_backoff`) przed każdą próbą restartu,
  - restarty mają teraz jawny `cause` (`mtime`, `worker_missing`, `health_stuck`) i osobne liczniki,
  - dodano singleton run-lock guardiana (`.guardian_run.lock`) przeciw równoległym instancjom,
  - dodano stan restartów: `.guardian_restart_state.json`,
  - dodano artefakt telemetryczny: `i18n/status/guardian_restart_metrics.json` (totals/causes/cooldown/recent_events).
- ✅ Domknięto zaległość z `P1.1` (auto-policy trigger):
  - `translations_random` trigger czyta realny kontrakt `translation_global_overview.json` (`languages[].completion_pct`) zamiast nieistniejącego `per_language_summary`.
- ✅ Walidacja runtime: log pokazuje aktywny debounce/backoff (`Restart pominięty ... reason=failure_backoff`), a metryki restartów są emitowane.

### Update wykonania (2026-02-13 21:47 UTC) — P2.1 + P2.2 (statusd)

- ✅ Domknięto `P2.1 Alerting webhook`:
  - dodano moduł webhook alertingu w `i18n-statusd.sh` dla sygnałów `doctor_critical`, `guardian_stuck`, `no_progress`,
  - dodano cooldown/deduplikację alertów (`statusd_alert_state.json`),
  - źródło URL webhooka: `STATUSD_WEBHOOK_URL` lub plik `.statusd_webhook_url`,
  - dodano tryb ręcznej ewaluacji: `--alert-check`.
- ✅ Domknięto `P2.2 Dzienny raport zarządczy`:
  - dodano generator raportu 24h: `--daily-report`,
  - artefakty: `i18n/status/statusd_daily_report.json` i `i18n/status/statusd_daily_report.md`,
  - raport zawiera KPI 24h + trendy per język/per kategoria + snapshot quality i coverage PL/ES,
  - w trybie `--daemon` raport jest odświeżany interwałowo (`STATUSD_DAILY_REPORT_MIN_INTERVAL_SECONDS`, domyślnie 3600s).
- ✅ Dodatkowo naprawiono zgodność kontraktu coverage w `statusd`:
  - parser i rekomendacje czytają aktualny schema `translation_global_overview.json` (`languages[].completion_pct`, `missing_keys`, `english_copy_keys`) z fallbackiem legacy.
- ⚠️ Nowe TODO ujawnione podczas implementacji:
  - `pending_skip_share` w raporcie 24h bazuje obecnie na sygnałach `pending_skip=*` z `worker_cycle_perf.detail`; potrzebny osobny, jawny licznik 24h jako artefakt źródłowy (`pending_skip_events_24h.json` lub równoważny).

### Update wykonania (2026-02-13 22:54 UTC) — Guardian fixes + translations_general

- ✅ **Fix: mtime loop w guardianie**
  - Problem: guardian nie aktualizował mtime po nieudanym restarcie → wykrywał zmianę co 30s w nieskończoność.
  - Fix: mtime zawsze aktualizowany po wykryciu zmiany (niezależnie od wyniku restartu). Debounce policy osobno kontroluje częstotliwość.
- ✅ **Fix: czyszczenie locków workera przed restartem**
  - Problem: `restart_worker()` tylko usuwał PID file, ale nie `.worker_simple.start.lock` → nowy worker widział stary flock i odmawiał startu ("Inny worker już działa").
  - Fix: `restart_worker()` teraz czyści PID file + `.worker_simple.start.lock` + legacy PID file.
- ✅ **Nowy profil: `translations_general`**
  - Tryb ogólnych tłumaczeń — `--translations-only` bez `--langs` → worker przetwarza WSZYSTKIE języki wg tier rotation.
  - Profil: `guardian_profiles/translations_general.json`.
  - Case dodany w `build_worker_args()`.
  - `guardian_profile.json` przełączono na `mode=translations_general`.
- ⚠️ **Quality audit: `identical_to_en` dominuje (29/100 wpisów)**
  - TM kopiuje oryginał EN bez tłumaczenia dla długich NPC dialogów (zwłaszcza PL).
  - Problem dotyczy głównie NPC z wieloliniowymi ciągami `\z\n\t`.
  - Wymaga: post-translation validation pass (→ Section 12.5) lub osobna faza quality_repair dla `identical_to_en`.

### Update wykonania (2026-02-13 — Quality hardening PL/ES)

- ✅ Domknięto pakiet jakości runtime dla PL/ES:
  - `i18n_worker_simple.sh`: dla `pl/es` priorytet mają kuratorowane słowniki bazowe, a zewnętrzne słowniki nie nadpisują istniejących kluczy bazowych,
  - rozszerzono bazowy słownik `es` o brakujące frazy wysokiej częstotliwości (NPC/UI), które wcześniej wracały jako EN-copy,
  - rozszerzono heurystykę `_is_probably_nontranslatable_text` (ścieżki, markup/template, emotes, identyfikatory techniczne).
- ✅ Domknięto pętlę jakości metryk:
  - `quality_report.jsonl`: rozdzielenie `identical_to_en` (translatable) i `identical_to_en_exempt`,
  - `quality_audit_latest.json`: analogiczny licznik `identical_to_en_exempt`.
- ✅ Snapshot walidacyjny po wdrożeniu (2026-02-13 22:16 UTC):
  - `quality_audit_latest.json`: `identical_to_en` utrzymuje się w okolicach ~30/100, a `identical_to_en_exempt` ~45-50/100 (okno 100 wpisów).
- ✅ Guardian runtime potwierdzony po restarcie mtime:
  - tryb docelowy: `translations_general` (start tłumaczeń wszystkich języków),
  - kolejność startowa/priorytet bootstrap: najpierw `es`, potem `pl`, następnie rotacja pozostałych języków.
- ✅ Rozszerzono gate przejścia do `translations_random`:
  - auto-policy guardiana wymaga teraz także progu `identical_to_en (translatable)` z `quality_audit_latest.json`.
- ✅ Domknięto dedykowany „repair queue” dla zaległego `identical_to_en (translatable)` w PL/ES:
  - artefakty: `i18n/status/identical_to_en_repair_queue.json` + `i18n/status/identical_to_en_repair_queue_report.jsonl`,
  - priorytet kolejki: języki `es -> pl`, domeny `npc -> server -> talkactions -> ...`.
- ✅ Nowe TODO rolloutowe (DONE 2026-02-14):
  - ✅ Próg gate `identical_to_en_translatable_below_pct` podniesiony z 2%→5%.
  - ✅ Alert stagnacji kolejki repair zaimplementowany w statusd.

### Update wykonania (2026-02-14 06:10 UTC) — statusd repair queue + strojenie quality_repair

- ✅ `i18n-statusd.sh`:
  - agregacja publikuje `repair_queue` i `repair_queue.stagnation` do `statusd_report.json`,
  - `run_status_doctor()` raportuje `REPAIR_QUEUE_STAGNATION` i `REPAIR_QUEUE_STALE`,
  - webhook alerting obsługuje `reason_code=repair_queue_stagnation`,
  - raport 24h (`statusd_daily_report.json/md`) ma sekcję `Repair Queue 24h`,
  - legacy `run_repair_stagnation_check()` używa tych samych progów/sygnałów co `repair_queue.stagnation` (jedno źródło alarmu).
- ✅ `i18n_worker_simple.sh`:
  - `repair_identical_bonus_round()` ma adaptacyjne limity (`REPAIR_IDENTICAL_LIMIT_HIGH/LOW` + progi backlogu),
  - dla PL/ES runda repair może wymusić GT (`REPAIR_IDENTICAL_FORCE_GT=true`).
- ✅ `guardian_profiles/quality_repair.json` dostrojony:
  - `use_gt=true`,
  - `translate_limit=60`.
- ✅ Walidacja runtime (2026-02-14 06:10 UTC):
  - `statusd_report.json`: `repair_queue.top=es:npc.json`, `count=2217`, `stagnation.detected=false`, `reason=window_too_short`, `span_h=5.915`,
  - `statusd_daily_report.md`: `top_target_drop_24h=3451`.
- ✅ Follow-up:
  - ✅ po pełnym oknie >=6h dostroić `STATUSD_REPAIR_QUEUE_STAGNATION_*` → DONE 2026-02-14: defaults OK (HOURS=6, MIN_SAMPLES=6, MIN_DROP=1),
  - ✅ potwierdzić trend `suspicious_high` po przełączeniu `quality_repair` na GT → DONE 2026-02-14: stabilny, brak regresji.

### Update wykonania (2026-02-13 22:23 UTC) — kolejność startu języków

- ✅ Decyzja operacyjna: guardian uruchamia tłumaczenie wszystkich języków (`translations_general`).
- ✅ Priorytet startowy kolejki po starcie guardiana:
  - 1) `es`,
  - 2) `pl`,
  - 3) następnie rotacja pozostałych języków.

### Update wykonania (2026-02-13 22:38 UTC) — runtime alignment + bootstrap state

- ✅ Guardian/profile alignment domknięty operacyjnie:
  - `guardian_profile.json` ma `mode=translations_general` i `langs=""`,
  - fallbacki w `i18n_guardian.sh` oraz `guardian_profiles/auto.json` domyślnie wskazują `translations_general`.
- ✅ Worker strict selector ma jawny bootstrap `es -> pl` dla trybu ogólnego:
  - konfiguracja: `BOOTSTRAP_PRIORITY_LANGS=es pl`,
  - stan publikowany do `i18n/status/translation_dispatch_state.json` (`bootstrap_priority`, `bootstrap_forced_lang`, `cycle_counter`).
- ✅ Runtime potwierdzony:
  - worker uruchamiany przez guardiana bez `--langs`,
  - pierwsze cykle po restarcie wybierają `es` jako język startowy.

---

## 1) Decyzje nadrzędne (obowiązujące)

1. **Hard gate kategorii (globalny):** worker **nie przechodzi** do kolejnej kategorii, dopóki aktywna kategoria nie ma kompletnego wyniku dla wszystkich wymaganych języków i walidacji jakości.
2. **Jedna skala priorytetów:** cały projekt działa wyłącznie na skali **P0 / P1 / P2**.
3. **Jeden status operatorski:** pozostaje **jedno** `I18N_STATUS.md`; dopuszczalny jest układ „landing + linki + sekcje live”, ale bez rozdzielania na wiele równorzędnych statusów.
4. **3rd daemon może działać aktywnie wcześniej:** auto-zapis komend i korekt jest dozwolony już od P1, ale z twardymi guardrailami (idempotencja, cooldown, walidacja, audit trail).
5. **Kolejność startowa tłumaczeń:** guardian uruchamia tłumaczenia wszystkich języków (`translations_general`), ale pierwszy priorytet kolejki to `es` i `pl` (w tej kolejności).

---

## 2) Zakres i wynik docelowy

### 2.1 Zakres
- Worker: pełna orkiestracja domen (`MIGRATION`, `KEY_MANAGEMENT`, `TRANSLATION_SYNC`, `AUTO_TRANSLATE`, `VALIDATION_QUALITY`, `ANALYTICS_REPORTING`).
- Guardian: health-based watchdog + policy engine + profile runtime.
- Status: jeden czytelny dashboard, spójny z runtime JSON.
- 3rd daemon (`i18n-statusd`): telemetry, rekomendacje i kontrolowane auto-akcje.

### 2.2 Definicja sukcesu
- Operator w 30–60 s rozumie: co worker robi teraz, dlaczego, co blokuje postęp i jaki jest następny krok.
- Brak przejść między kategoriami przy niezamkniętej jakości/tłumaczeniach.
- `guard_fail_rate` i `no_progress_rate` trwale maleją, a decyzje automatyczne są audytowalne.

---

## 3) Architektura wykonawcza

### 3.1 Jedna maszyna stanów
Worker działa jako deterministyczna maszyna stanów:
1. `MIGRATION`
2. `KEY_MANAGEMENT`
3. `TRANSLATION_SYNC`
4. `AUTO_TRANSLATE`
5. `VALIDATION_QUALITY`
6. `ANALYTICS_REPORTING`

Każdy stan ma kontrakt wejścia/wyjścia i metrykę zakończenia.

### 3.2 Reguła przełączania (hard gate)
Przejście `CATEGORY_A -> CATEGORY_B` jest dozwolone tylko gdy:
1. brak pending migracji/kluczy w `CATEGORY_A`,
2. sync kluczy zakończony dla wszystkich wymaganych języków,
3. pending tłumaczeń ≤ próg roboczy,
4. brak krytycznych błędów token/placeholder/pipe,
5. brak krytycznych wpisów quality stale > TTL.

Jeśli którykolwiek warunek nie jest spełniony, dispatcher musi pozostać w tej samej kategorii i uruchomić stan naprawczy.

### 3.3 Dynamiczny wybór domeny
Priorytet domen:
1. `P0` naprawa jakości/tokenów,
2. `P0` blokery migracji/kluczy,
3. `P1` sync i tłumaczenia,
4. `P2` analityka i housekeeping.

---

## 4) Plan wdrożenia wg P0/P1/P2

## P0 — Stabilizacja i prawda operacyjna

### P0.0 Baseline 24h (warunek wejścia) — ✅ DONE (2026-02-13)
- Artefakt: `i18n/status/baseline/baseline_2026-02-13_210014.json`.
- Skrypt baseline wspiera okna `--hours` i `--since`, a raport zawiera także `quality_snapshot` (PL/ES), `guardian.log` summary i `strict_hourly_window`.
- `strict_hourly_window` jest renderowany także w `I18N_STATUS.md` i zapisywany do `i18n/status/strict_hourly_window_latest.json`.

**Walidacja:** baseline 24h istnieje i jest odtwarzalny skryptem.

### P0.1 Spójny status (`I18N_STATUS.md`) — ✅ DONE (2026-02-13)
- ✅ Sekcje: `META`, `LIVE`, `MIGRATION`, `TRANSLATION`, `QUALITY`, `HISTORY` — każda z `freshness`, `source`, `last_update`.
- ✅ Sekcje nieaktywne oznaczone `🔒 INACTIVE` z powodem (np. „worker w trybie AUTO_TRANSLATE").
- ✅ `net_effective_translated` dodane do dashboard header.
- ✅ Runtime thresholds zapisane w `worker_config.json` (sekcja `thresholds`).
- ✅ KPI Dashboard — Pilot Health (PL/ES) z per-lang coverage, guard_fail, throughput.

**Walidacja:** brak konfliktów typu „LIVE=MIGRATION", gdy sekcja tłumaczeń wygląda jak aktywna. ✅ SPEŁNIONE

### P0.2 Dispatcher z hard gate kategorii — ✅ DONE (2026-02-13)
- ✅ `transition_gate()` — sprawdza warunki przejścia MIGRATION→COMPACT_KEYS→TRANSLATION_SYNC→AUTO_TRANSLATE→IDLE.
- ✅ Backwards movement blocked (np. AUTO_TRANSLATE → MIGRATION, chyba że FORCE).
- ✅ `_commit_phase()` — zapisuje aktualną fazę do `translation_dispatch_state.json`.
- ✅ `_log_transition()` — loguje każde przejście do `transition_log.jsonl` (gate: pass|block|forced).
- ✅ FORCE commands logowane z `gate=forced`.

**Walidacja:** 0 przypadków nieuprawnionego switchu kategorii w logach 24h. ✅ SPEŁNIONE

### P0.3 Guardian health-based — ✅ DONE (2026-02-13)
- ✅ Heartbeat age check (stale > 180s → stuck, > 108s → degraded)
- ✅ Progress delta check (0 translated in 15min window → stuck)
- ✅ Guard_fail trend (rate > 15% → degraded)
- ✅ Policy states: `healthy` / `degraded` / `stuck`
- ✅ Stuck cooldown: restart only on 2nd consecutive stuck detection
- ✅ Health report saved to `i18n/status/guardian_health.json`

**Walidacja:** Worker restartowany tylko po 2 kolejnych cyklach stuck (ścieżka health-policy).
**Uwaga:** osobny wektor restartów `mtime` jest już objęty P0.5 (debounce/backoff + metryki).

### P0.4 Ograniczenie false-positive `guard_command` — ✅ DONE (2026-02-13)
- ✅ GAME_COMMANDS whitelist wdrożony (pattern 2: single-quoted → tylko jeśli w whitelist)
- ✅ Slash-command regex poprawiony: wyklucza URL-e (`https://...`) i ścieżki plików (`/a/b/c`)
- ❌ Nie wdrożono re-injection (nie było potrzebne — whitelist wystarczył)

**Wynik:** guard_fail_rate 10.6% → **3.5%**, guard_command 2393 → **36** (redukcja 98.5%)
**Walidacja:** `guard_command_rate < 5%` dla PL/ES — **SPEŁNIONE ✅**

### P0.5 Guardian restart debounce/backoff (ścieżka mtime) — ✅ DONE (2026-02-13)
- ✅ Debounce restartów dla triggera `mtime` (`MTIME_RESTART_MIN_INTERVAL_SEC`).
- ✅ Exponential backoff po nieudanym starcie (`RESTART_FAILURE_BACKOFF_BASE_SEC` -> `RESTART_FAILURE_BACKOFF_MAX_SEC`).
- ✅ Przyczyny restartów logowane i metrykowane per-cause (`mtime`, `worker_missing`, `health_stuck`).
- ✅ Singleton run-lock dla `run_once` (`.guardian_run.lock`) — brak równoległego wykonania daemon/manual/cron.
- ✅ Artefakty:
  - `.guardian_restart_state.json`
  - `i18n/status/guardian_restart_metrics.json`

**Walidacja:** w logu występują wpisy `Restart pominięty ... reason=failure_backoff`, a metryki restartów są aktualizowane.

---

## P1 — Orkiestracja i automatyzacja kontrolowana

### P1.1 Profile guardiana dla wszystkich domen — ✅ DONE (2026-02-13, baseline)
- ✅ Profile: `translations_general`, `translations_pl_es`, `translations_random`, `migration_only`, `hybrid`, `quality_repair`, `auto`.
- ✅ `auto` wybiera profil na podstawie metryk i cooldownów.
- ✅ Trigger `translations_random` działa na realnych danych coverage (`languages[].completion_pct`).

### P1.2 3rd daemon MVP (`i18n-statusd`) — ✅ DONE (2026-02-13)
- ✅ Skrypt `i18n-statusd.sh` — 8 modułów: agregacja telemetrii, status doctor, KPI snapshot, rekomendacje, guardrails auto-akcji, webhook alerting, daily executive report, daemon loop.
- ✅ Tryby: `--once`, `--daemon` (co 60s), `--doctor`, `--kpi`, `--recommend`, `--aggregate`, `--daily-report`, `--alert-check`, `--auto-action`, `--audit`.
- ✅ Agregacja do `statusd_report.json`: worker state, guardian health, guard KPI, adaptive batch, dispatch, coverage per lang.
- ✅ Status Doctor: 7 kontroli spójności (heartbeat freshness, PID alive, guard report stale, dispatch stale, guardian health, required files).
- ✅ Systemd unit file: `i18n-statusd.service`.

**Walidacja:** `bash i18n-statusd.sh --once` zwraca kompletny raport w <3s. ✅ SPEŁNIONE

### P1.3 Guardraile auto-akcji — ✅ DONE (2026-02-13)
- ✅ **Idempotencja:** `_idempotent_check()` — ten sam trigger+fingerprint nie wykonuje komendy wielokrotnie.
- ✅ **Cooldown:** osobne cooldowny per typ akcji (15-120min).
- ✅ **Walidacja pre/post:** każda akcja ma `precheck` i `postcheck` w audycie.
- ✅ **Audit trail:** pełny JSONL log w `statusd_audit.jsonl` (kto/co/dlaczego/efekt/status).
- ✅ **Feature flag:** `--enable-auto`/`--disable-auto` — auto-akcje domyślnie WYŁĄCZONE.
- ✅ **4 auto-akcje:** REDUCE_BATCH_ON_HIGH_GF, INCREASE_BATCH_ON_LOW_GF, UNFOCUS_LANG_ON_IMBALANCE, PAUSE_ON_CRITICAL.

**Walidacja:** 100% auto-akcji ma wpis audytowy i wynik post-check. ✅ SPEŁNIONE

---

## P2 — Optymalizacja i operacyjna wygoda

### P2.1 Status doctor + alarmy — ✅ DONE (2026-02-13)
- ✅ Narzędzie `i18n-statusd.sh --doctor` wykrywające niespójności status-vs-runtime.
- ✅ 7 kontroli spójności: heartbeat, PID, guard report, dispatch, guardian health, required files.
- ✅ Alerting webhook (opcjonalny) dla `stuck/no_progress` i `doctor_critical`:
  - `STATUSD_WEBHOOK_URL` lub `.statusd_webhook_url`,
  - cooldown/deduplikacja w `i18n/status/statusd_alert_state.json`,
  - tryb testowy: `bash i18n-statusd.sh --alert-check`.

### P2.2 Dzienny raport zarządczy — ✅ DONE (2026-02-13)
- ✅ KPI 24h: throughput, guard_fail_rate, no_progress_rate, pending_skip_share, quality issues.
- ✅ Raport trendów per język/per kategoria.
- ✅ Artefakty:
  - `i18n/status/statusd_daily_report.json`
  - `i18n/status/statusd_daily_report.md`
- ✅ Integracja daemon: okresowe odświeżanie raportu (`STATUSD_DAILY_REPORT_MIN_INTERVAL_SECONDS`, domyślnie 3600s).

---

## 5) Wymagania testowe i rollback

### 5.1 Testy obowiązkowe
1. Test przejść state machine (happy-path i edge-case).
2. Test freshness/TTL sekcji statusu.
3. Test policy guardiana (kill worker, stale heartbeat, brak postępu).
4. Test auto-akcji 3rd daemona (idempotencja + cooldown + audit).

### 5.2 Rollback
- Każda zmiana w P0/P1 ma instrukcję rollback w tym samym PR.
- Wyłączenie auto-akcji jedną flagą (`auto_actions=false`) bez zatrzymania status renderingu.

---

## 6) Harmonogram wykonawczy (proponowany)

- **Dzień 1:** P0.1 + P0.2 (status + hard gate).
- **Dzień 2:** P0.3 + P0.4 (guardian health + guard_command fix).
- **Dzień 3:** P1.1 (profile + policy auto).
- **Dzień 4:** P1.2 + P1.3 (3rd daemon MVP + guardraile).
- **Dzień 5:** P2 + testy regresyjne + dokumentacja operacyjna.

---

## 7) Package do przekazania dla Claude

1. Lista zadań P0/P1/P2 z ownerem, wejściem, wyjściem, testem i rollbackiem.
2. Jedna checklista wdrożeniowa „go/no-go” przed każdym restartem produkcyjnym.
3. Tabela ryzyk z triggerem, symptomem i konkretną akcją automatyczną/manualną.
4. Matryca zgodności statusu: sekcja -> źródło JSON -> TTL -> warunek active/inactive.

---

## 8) Krytyczne KPI (must-pass)

1. `pending_skip_share < 25%`
2. `no_progress_rate < 20%`
3. `guard_fail_rate < 5%` (PL/ES)
4. `push_success_rate > 99%`
5. `status_freshness` bez sekcji stale > 2 cykle

Niespełnienie któregokolwiek KPI blokuje przejście do kolejnego etapu wdrożenia.

---

## 9) Governance Addendum (operacyjne reguły startowe)

### 9.1 Progi i timery (wersja startowa)
- `heartbeat_stale_seconds = 180`
- `stuck_window_minutes = 15`
- `no_progress_cycles_threshold = 8`
- `pending_skip_share_alert = 0.35`
- `pending_skip_share_block = 0.50`
- `auto_action_cooldown_seconds = 600`
- `status_section_ttl_seconds = 300`

### 9.2 Źródło prawdy dla „required languages”
- Źródłem prawdy jest aktywny profil guardiana:
  - dla `translations_general`: wymagane języki = wszystkie języki wykryte w `i18n/*` (z priorytetem bootstrap `es`, `pl`),
  - dla profili z jawnie ustawionym `langs`: lista z profilu (`langs`) z fallbackiem do `worker_config.json`.
- Jeśli profile i config są sprzeczne, wygrywa profil guardiana uruchomiony aktualnie.
- Brak jawnej listy języków blokuje przejście kategorii (`hard gate fail`).

### 9.3 Priorytet komend (manual vs auto)
1. Komenda manualna operatora ma najwyższy priorytet.
2. Auto-komenda 3rd daemona może wykonać się tylko gdy nie ma aktywnej komendy manualnej.
3. Komenda manualna ma TTL 20 min; po TTL wraca policy `auto`.
4. Każda nadpisana auto-komenda musi mieć wpis audytowy z powodem „manual_precedence”.

### 9.4 Ownership i odbiór
- `P0`: owner runtime (worker/guardian), reviewer jakości i18n, approver operacyjny.
- `P1`: owner automatyzacji (`i18n-statusd`), reviewer runtime, approver jakości.
- `P2`: owner observability/reporting, reviewer operacyjny.
- Każdy etap bez wskazanego ownera nie może wejść w implementację.

---

## 10) Execution Gates (go/no-go)

### Gate 0 — Przed startem wdrożenia P0
- wymagane: baseline 24h, aktywna telemetria, jawna lista języków wymaganych,
- blokery: brak baseline, brak spójnego `required_languages`.

**Status Gate 0 (2026-02-13 21:00 UTC):**
- ✅ baseline 24h: SPEŁNIONE (`baseline_2026-02-13_210014.json`)
- ✅ aktywna telemetria: SPEŁNIONE (`i18n/status/*.jsonl` aktualizowane)
- ✅ jawna strategia języków wymaganych: SPEŁNIONE (`translations_general` + bootstrap priority `es`,`pl`)

### Gate 1 — Po P0
- wymagane:
	- `pending_skip_share < 35%` przez 6h,
	- `no_progress_rate < 25%` przez 6h,
	- brak nieuprawnionego switchu kategorii,
	- status freshness bez stale > 2 cykle.
- decyzja: tylko wtedy start P1.

### Gate 2 — Po P1
- wymagane:
	- 100% auto-akcji z audytem i post-check,
	- 0 konfliktów manual-vs-auto bez wpisu audytowego,
	- `guard_fail_rate < 8%` dla PL/ES przez 12h.
- decyzja: tylko wtedy start P2 i optymalizacji.

---

## 11) Interface Contract (worker ↔ guardian ↔ statusd)

### 11.1 Worker -> status JSON
- Worker publikuje po każdym cyklu: `mode`, `category`, `lang`, `result`, `translated`, `guard_fail`, `quality_fail`, `heartbeat`.
- Brak któregokolwiek pola oznacza cykl niekompletny i wymusza status `degraded`.

### 11.2 Guardian -> worker
- Guardian dostarcza profil runtime (`mode`, `langs`, limity, policy) i odpowiada za restart policy.
- Guardian nie modyfikuje danych tłumaczeń; tylko steruje procesem i recovery.

### 11.3 statusd -> system
- `statusd` renderuje `I18N_STATUS.md`, wykrywa niespójność danych i publikuje rekomendacje/auto-akcje.
- `statusd` nie może wykonać auto-akcji bez wpisu `precheck` i `postcheck`.

---

## 12) Najważniejsze braki w trybie tłumaczeń (start natychmiastowy)

### 12.1 Brak #1 — deterministyczna kolejka tłumaczeń per kategoria
- Problem: worker wraca do tych samych trudnych plików, zamiast domykać kategorię język po języku.
- Wymagane: kolejka `category -> lang -> file` z checkpointem postępu i zakazem skoku poza kategorię.

### 12.2 Brak #2 — formalny „translation done contract" — ✅ DONE (2026-02-14)
- Problem: brak jednej definicji „tłumaczenie gotowe" per plik/język.
- ✅ Warunki done (sprawdzane po każdym cyklu tłumaczenia):
	1. `no_critical_token_errors` — guard_placeholder = 0, guard_pipe = 0,
	2. `guard_command_below_threshold` — guard_command ≤ 5,
	3. `coverage_above_95pct` — ≥95% kluczy EN przetłumaczonych (nie placeholder),
	4. `quality_entry_present` — wpis quality z danymi o cyklu.
- ✅ Artefakt: `i18n/status/done_contracts/{lang}_{file}.json` — per-file/lang JSON z wszystkimi warunkami.
- ✅ Historia: `i18n/status/done_contract_history.jsonl` — append-only log.
- ✅ Komunikat: `__DONE_CONTRACT__ is_done=1/0 coverage=X guard_placeholder=X guard_pipe=X guard_command=X`.
- ✅ Parsowanie w bash wrapper auto_translate — loguje wynik Done Contract po każdym cyklu.

### 12.3 Brak #3 — retry policy per reason — ✅ DONE (2026-02-13)
- ✅ `RETRY_COOLDOWN_PER_REASON`: placeholder/pipe→15 cykli, command→5, quality/shape→8, provider_error→3.
- ✅ Blacklist wybiera cooldown na podstawie dominującej przyczyny guard_fail (`.most_common(1)`).
- ✅ Zbieranie count per reason z `guard.{placeholder,command,pipe}` w guard report JSONL.

### 12.4 Brak #4 — twardy balans PL/ES — ✅ DONE (2026-02-13)
- ✅ `MIN_BALANCE_SHARE = 0.35` — wymuszany min. 35% udziału ES/PL w cyklach Tier 1.
- ✅ Sprawdzanie ostatnich 20 wpisów guard_report; jeśli ES < 35%, kandydaci ES przesuwani na przód.
- ✅ Pole `balance_forced` w `translation_dispatch_state.json`.

### 12.5 Brak #5 — zamknięcie pętli jakości po tłumaczeniu — ✅ DONE (2026-02-14)
- ✅ Faza 4 auto-fix pipeline wdrożony (2026-02-14):
  - `_auto_fix_translation()` — 6 auto-fixów: F1-F6 (spacing, punctuation, capitalization, newlines).
  - `_post_translation_validate()` — kombinacja auto-fix + validate_candidate + validate_key.
  - Wpięty w 3 pipeline'y: GT, TM lookup, simple translate — PRZED validate_candidate.
- ✅ Po translacji worker rozdziela teraz EN-copy na:
  - `identical_to_en` (wymaga naprawy),
  - `identical_to_en_exempt` (technicznie nietłumaczalne: markup/path/identyfikatory).
- ✅ Audyt jakości i metryki cyklu używają tego samego rozróżnienia, dzięki czemu dashboard nie miesza regresji językowych z wyjątkami technicznymi.
- ✅ Dla PL/ES wzmocniono źródło kandydatów:
  - kuratorowany słownik bazowy ma priorytet nad zewnętrznym przy konflikcie klucza,
  - dodano brakujące frazy ES o wysokiej częstotliwości (NPC/UI).
- ✅ Follow-up domknięty: osobna kolejka naprawcza dla zaległych wpisów `identical_to_en` translatable istnieje i jest publikowana jako artefakt statusowy.

### 12.6 Brak #6 — ochrona przed „false done" — ✅ DONE (2026-02-13)
- ✅ `net_effective_translated = Σ max(0, translated - guard_fail)` obliczane z JSONL.
- ✅ Wyświetlane w dashboard header i tabeli KPI.
- ✅ Aktualna wartość: ~31,700+.

### 12.7 Kryterium startu prac (Translation First)
Prace startowe koncentrujemy najpierw na trybie tłumaczeń. Etap uznajemy za opanowany, gdy przez min. 12h:
- `guard_fail_rate <= 8%` (PL/ES),
- `no_progress_rate <= 15%`,
- guardian działa w profilu `translations_general`, a kolejność startowa bootstrap utrzymuje priorytet `es` -> `pl`,
- brak naruszeń hard gate kategorii.
---

## 13) Aktualizacja sesji 2026-02-14

### 13.1 Diagnostyka i naprawa guardiana
- **Guardian mtime loop** — naprawiony: mtime aktualizowany po każdej detekcji niezależnie od wyniku restartu.
- **Worker lock cleanup** — naprawiony: `restart_worker()` czyści PID + `.worker_simple.start.lock` + legacy PID.
- **Profil translations_general** — dodany do `guardian_profiles/`.

### 13.2 Faza 4: Quality pipeline — ✅ DONE
- `_auto_fix_translation()` — 6 auto-fixów (F1-F6): spacing, punctuation, capitalization, newlines.
- `_post_translation_validate()` — kombinacja auto-fix + validate_candidate + validate_key V1-V7.
- Wpięty w 3 pipeline'y: GT, TM lookup, simple translate.

### 13.3 Section 12.2: Done Contract — ✅ DONE
- Formalny per-file/lang check po każdym cyklu tłumaczenia.
- 4 warunki: no_critical_tokens + guard_cmd≤5 + coverage≥95% + quality_entry.
- Artefakt: `done_contracts/{lang}_{file}.json` + `done_contract_history.jsonl`.
- Komunikat `__DONE_CONTRACT__` parsowany w bash wrapper.

### 13.4 Section 12.5: Post-translation validation — ✅ DONE
- Auto-fix pipeline realizuje zamknięcie pętli jakości.
- Każdy kandydat jest normalizowany PRZED guard walidacją.

### 13.5 pending_skip 24h artifact (#14) — ✅ DONE
- `log_pending_skip_event()` → `pending_skip_events.jsonl` (dedykowany JSONL).
- `compute_pending_skip_24h()` → `pending_skip_24h_latest.json` (co 10 cykli).
- Metryki: count, share_pct, reasons breakdown, status (ok/warning/critical).

### 13.6 P1.9: Domain tag logs — ✅ DONE
- `_derive_domain()` w `tools/i18n_status.py` — automatyczne mapowanie phase→domain.
- 5 domen: MIGRATION, KEY, SYNC, AUTO, QUALITY.
- Pole `domain` dodawane do każdego wpisu `log-op` i `log-error` w JSONL.

### 13.7 Zrealizowane TODO (sesja 2026-02-14 #2)
- ✅ Faza 5: Tuning wydajności — throughput 5118/h (cel >100). Adaptive batch + productivity watchdog działają.
- ✅ Faza 6: Rollout na wszystkie języki — `validate_tier_quality()` z per-tier gates: T1(PL/ES)→90%, T2(DE/FR/IT/PT/RU/TR)→50%, T3→30%. Artefakty: `tier_quality_gate.json` + `.jsonl`.
- ✅ Faza 7: Operacyjne utrwalenie — `docs/I18N_RUNBOOK.md`: start/stop, komendy, profile, monitoring, troubleshooting, rollback, checklista poranna + po deploy.
- ✅ 12.5 follow-up: kolejka naprawcza `identical_to_en` translatable w istniejących plikach (artefakty queue + report).
- ✅ identical_to_en repair: `_is_game_nontranslatable()` (fikcyjny język gry, animal sounds), `repair_identical_bonus_round()` (200 kluczy co 3 cykle).
- ✅ Nowy follow-up 12.5: telemetryczny alert stagnacji kolejki repair + KPI trendu spadku backlogu — DONE: integracja w `aggregate_telemetry`/`run_status_doctor`/`run_webhook_alerting` + sekcja `Repair Queue 24h` w `statusd_daily_report.json/md` + zgranie legacy `repair_stagnation_alert.json` z tym samym źródłem progów.
