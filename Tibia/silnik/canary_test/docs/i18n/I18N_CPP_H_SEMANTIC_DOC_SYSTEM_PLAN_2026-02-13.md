# Plan systemu semantycznej analizy C++/H dla i18n i dokumentacji technicznej

**Data:** 2026-02-13  
**Zakres:** repo Canary (`src/*.cpp`, `src/*.h`) + mapowanie do domen i18n  
**Cel:** zbudować pipeline, który tworzy dwa równoległe widoki: **Human View** i **Developer View**.

---

## 0j) Aktualizacja koordynacyjna (2026-02-14 11:22 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `statusd` odświeża `I18N_STATUS.md` autonomicznie (nie tylko przez cykl workera).
- ✅ `statusd` ma rozszerzony kontrakt reconcile (`always_sync_any_drift=true` + `cooldown_bypassed` telemetry).
- ✅ `statusd_doctor` publikuje nowy blok `translation_contract` (translations-only + ES/PL gate order).
- ✅ Audyt LT/CS/EL/IT potwierdził brak naruszeń placeholderów `{}` / `%` / `'keyword'` w `items/npc/quests`.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać pole `translation_contract_hint` (`ok|warning|broken`) do korelacji zmian kodu z runtime kontraktem tłumaczeń.
- ⬜ Dodać pole `status_projection_freshness_hint` (`fresh|stale`) zależne od nowego auto-refresh `I18N_STATUS.md`.
- ⬜ Rozszerzyć parsery semantyczne stringów o jawny marker `placeholder_integrity=true/false` dla przypadków `{}` i `%` (zgodny z metrykami statusd).

## 0i) Aktualizacja koordynacyjna (2026-02-14 10:18 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `i18n_start_all.sh` ma post-start health gate 30s (stabilność procesu po starcie).
- ✅ Zdiagnozowano rzeczywiste źródło startów `source=manual`: user systemd unit `~/.config/systemd/user/i18n-guardian.service`.
- ✅ Potwierdzono 20-min okno bez `REPAIR_QUEUE_STALE` (`statusd.log`), co stabilizuje kontrakt queue freshness.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać `orchestration_source_hint` (`start_all|user_systemd|manual_shell|unknown`) dla korelacji runtime.
- ⬜ Dodać `post_start_stability_hint` (`pass|fail`) kompatybilny z gate 30s w `start_all`.
- ⬜ Rozszerzyć `process_evidence` o `parent_cmdline`/`grandparent_cmdline` (throttled snapshot), bo to realnie wykryło konflikt źródeł startu.

## 0h) Aktualizacja koordynacyjna (2026-02-14 09:56 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ Worker runtime ma potwierdzony `heartbeat_tick` w `activity.json.recent[]` podczas AUTO_TRANSLATE (mid-cycle heartbeat).
- ✅ Snapshot `identical_to_en_repair_queue.json` odświeża się już także przez ścieżkę `queue_only` (niezależnie od pełnej rundy repair).
- ✅ Guardian lock owner jest walidowany po `cmdline` (`i18n_guardian.sh --daemon`), co ogranicza false-positive blokady locka przez reuse PID.
- ✅ `i18n_start_all.sh` ma twardszy check startu (`wait_for_stable_process`) dla guardian/statusd.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać sygnał `startup_stability_hint` (`stable|short_lived|background_killed`) dla modułów orkiestracyjnych, aby korelować zmiany semantyczne z realnym utrzymaniem procesów.
- ⬜ Dodać pole `repair_queue_freshness_hint` (`fresh|aging|stale`) kompatybilne z nowym kontraktem `queue_only`, żeby łatwo mapować wpływ zmian kodu na stale queue alerty.
- ⬜ Rozszerzyć `process_evidence` o `cmdline_verified` (bool), spójnie z nową walidacją lock owner PID w guardianie.

## 0g) Aktualizacja koordynacyjna (2026-02-14 09:12 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `statusd_doctor` ma dynamiczny kontrakt heartbeat:
  - progi `aging/stale/stuck` są pobierane z `guardian_health.json`,
  - klasyfikacja uwzględnia aktywność procesu/logów (`STALE_HEARTBEAT_BUT_ACTIVE`).
- ✅ `statusd_doctor` publikuje `worker_process_watch`:
  - topologia procesów workera (`main`, `descendant extra`, `foreign extra`),
  - wiek extra procesów i severity pod kątem realnej duplikacji.
- ✅ `statusd_report.worker` ma poprawione pola procesu:
  - `pid` (jawny),
  - `pid_alive` (potwierdzone przez `/proc/<pid>`).

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać pole `runtime_topology_hint` (`single_process|single_descendant|multi_descendant|foreign_duplicate`) kompatybilne z `worker_process_watch.status`.
- ⬜ Dodać pole `heartbeat_pressure_hint` (`fresh|aging|stale_active|stale`) kompatybilne z nowym kontraktem doctora.
- ⬜ Dodać `process_evidence` (`pid`, `ppid`, `cmdline_match`) w artefaktach semantycznych używanych do korelacji zmian runtime.

## 0f) Aktualizacja koordynacyjna (2026-02-14 08:40 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `statusd` ma workflow `registry_reconcile` (auto + ręczny), a metryki driftu są rozdzielone na `raw` i `effective`.
- ✅ `translation_global_overview.migration` i `i18n_global_stats.migration` mają nowe pola:
  - `total_keys_extracted_worker_registry_raw`,
  - `registry_reconcile_adjustment`,
  - `keys_extracted_outside_worker_registry_raw`.
- ✅ `statusd_report`/`statusd_doctor`/`statusd_daily_report` mają blok `priority_gate_watch` (aktywny gate ES/PL, cykle, quality-drop).
- ✅ `statusd --auto-action` ma wykonawczą akcję `SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK` (feature-flag), więc sygnał watchdoga może wywoływać realną zmianę profilu runtime.
- ✅ Guardian ma source-priority arbitration locka, co stabilizuje źródło uruchamiania daemona.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać sygnał `registry_view` (`raw|effective`) dla raportów semantycznych, aby korelacja z KPI driftu była jednoznaczna.
- ⬜ Dodać sygnał `priority_gate_impact` (czy zmiana modułu wiąże się z falą `priority_gate` i jej stuck/no-stuck).
- ⬜ Dodać `reconcile_granularity_hint` (`global_adjustment|per_file_backfill_needed`) pod planowany etap 2 reconcile.

## 0e) Aktualizacja koordynacyjna (2026-02-14 08:18 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ Worker ma nowy tryb `GLOBAL_QUALITY_MODE` (coverage target 100 + quality gate).
- ✅ Guardian przekazuje do workera `global_quality_*` i utrzymuje priorytet fali `es -> pl` przed pełnym rolloutem języków.
- ✅ `translation_dispatch_state.json` publikuje `priority_gate` (pending języki i completion), co daje nowy sygnał orkiestracyjny dla status/telemetrii.
- ✅ `statusd` zawsze scala metryki migracji z live snapshotem (`i18n_file_status.json + i18n/en/*.json`), więc metryki kluczy lepiej odzwierciedlają zmiany spoza workera.
- ✅ Zaostrzono progi `metrics_drift`, przez co rozjazd LIVE vs registry jest widoczny wcześniej.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać pole `priority_wave` (`pilot_es_pl|global_rollout`) kompatybilne z `translation_dispatch_state.priority_gate`, aby korelować zmiany kodu z fazą rolloutu językowego.
- ⬜ Dodać pole `registry_reconcile_hint` (czy zmiana C++/H może wymagać uzupełnienia `i18n_file_status.json`), bo drift LIVE vs registry jest teraz sygnałem krytycznym.
- ⬜ Emitować `quality_gate_impact` (wpływ zmian modułu na score/critical dla języków priorytetowych), aby statusd mógł lepiej sterować `quality_repair`.

## 0d) Aktualizacja koordynacyjna (2026-02-14 07:52 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `statusd` ma kanoniczne źródło progów w pliku `canary_test/statusd_thresholds.json` (daemon/manual używają tego samego kontraktu).
- ✅ `statusd_report.json` / `statusd_doctor.json` / `statusd_daily_report.json` publikują `thresholds_snapshot` z:
  - `source_of_truth`,
  - `config_file`,
  - `env_overrides_enabled`.
- ✅ `i18n_start_all.sh` raportuje realny stan daemonów po walidacji `/proc/<pid>/cmdline` (bez self-match fallback `pgrep`).

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Dodać mapowanie `threshold_impact_hint`:
  - które moduły semantyczne mogą wpływać na przekroczenia progów `suspicious_high` i `metrics_drift`.
- ⬜ Emitować `runtime_process_confidence` dla sygnałów automatyzacji:
  - czy sygnał pochodzi z potwierdzonego procesu (`pid+cmdline`) czy z fallback heurystycznego.
- ⬜ Dodać kompatybilność z `thresholds_snapshot.config_file`, żeby raport semantyczny mógł wskazać, pod jakim profilem progowym liczony był wpływ zmian.

## 0c) Aktualizacja koordynacyjna (2026-02-14 07:28 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ `I18N_STATUS.md` ma dwa niezależne liczniki skanu (`history` vs `live`) + różnicę.
- ✅ `statusd` ma pełny kontrakt `metrics_drift` (report + doctor + daily + webhook reason code).
- ✅ `statusd_daily_report` został spięty z aktywnymi progami driftu z `statusd_report.json`, żeby ograniczyć niespójności między raportami.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Emitować sygnał kompatybilny z `scanned_files_live/history` (`scan_source_hint`), aby łatwo mapować zmiany semantyczne na realny coverage skanowania.
- ⬜ Dodać `drift_explainer` (np. które moduły mogły zwiększyć `outside_worker_registry_keys`) do lepszej diagnostyki source-of-truth driftu.

## 0b) Aktualizacja koordynacyjna (2026-02-14 07:07 UTC)

Zmiany runtime/status istotne dla planu C++/H:
- ✅ Dashboard `I18N_STATUS.md` rozdziela metryki kluczy na:
  - LIVE (`i18n/en/*.json`),
  - registry (`i18n_file_status.json`),
  - drift (`outside_worker_registry`).
- ✅ Worker wymusza teraz refresh statusu po zmianie sygnatury `i18n/*.json` (`i18n_live_signature`), więc ręczne zmiany są szybciej widoczne w dashboardzie.
- ✅ Ujawniony został duży drift metryk (`53,586` LIVE vs `6,248` registry), co potwierdza potrzebę korelacji zmian semantycznych poza standardową ścieżką workera.

Nowe wymagania dla pipeline semantycznego C++/H:
- ⬜ Emitować znacznik `change_origin` (`worker|manual|agent|unknown`) tam, gdzie da się go wiarygodnie wywnioskować z artefaktów.
- ⬜ Dodać sygnał `metrics_drift_impact` (czy zmiana w module mogła zwiększyć drift LIVE vs registry), by statusd mógł priorytetyzować audyt.
- ⬜ Powiązać delta modułów C++/H z `scanned_files_live` (po wdrożeniu tej metryki), nie tylko z historią `processed_files`.

## 0a) Aktualizacja koordynacyjna (2026-02-14 06:56 UTC)

Domknięte zmiany po stronie runtime i ich wpływ na plan C++/H:
- ✅ `statusd_report.json` ma nowy blok `quality_watch` (agregacja `suspicious_high` w oknie 6h, top lang, top category).
- ✅ `statusd_daily_report.json/md` ma:
  - KPI `suspicious_high_count/rate/top_lang`,
  - sekcję `Repair Tuning 24h` (źródło: `identical_to_en_repair_tuning.jsonl`),
  - jawne `pending_skip_source` (preferowane `pending_skip_24h_latest.json`).
- ✅ Guardian health-check został doprecyzowany (aging/stale/stuck + sygnały aktywności procesu), co zmniejsza restarty zakłócające obserwację trendów jakości.
- ✅ Worker repair interwał korzysta z globalnego `translation_dispatch_state.cycle_counter`, a nie tylko lokalnego licznika po restarcie.

Nowe wymagania dla pipeline semantycznego C++/H (dopisane po wykrytych problemach):
- ⬜ Emitować sygnał `quality_watch_key = <lang>:<domain>` kompatybilny z `statusd_report.quality_watch.top_langs/top_categories`, żeby można było mapować wzrost `suspicious_high` do zmian semantycznych modułów.
- ⬜ Rozszerzyć kontrakt o `risk_scope` (`global|domain|lang|lang_domain`) — obecne alerty runtime pokazały, że globalny próg jest zbyt mało precyzyjny dla `npc.json`.
- ⬜ Dodać relację do artefaktu `identical_to_en_repair_tuning.jsonl`:
  - `repair_tuning_key` (`lang:json_file`),
  - `repair_tier`,
  - `suspicious_high_pct`,
  aby korelować zmianę C++/H z efektywnością realnej naprawy tłumaczeń.

## 0) Aktualizacja koordynacyjna (2026-02-13 22:14 UTC)

W tej iteracji wykonano Fazę 0 z planu workera (baseline 24h):
- artefakt: `i18n/status/baseline/baseline_2026-02-13_210014.json`.
- baseline raport ma już blok `strict_hourly_window` (JSONL-only KPI).
- `I18N_STATUS.md` renderuje już sekcję „Strict Hourly Window (JSONL-only)” z tego samego kontraktu.

Aktualizacja uzupełniająca (2026-02-13 22:25 UTC):
- ✅ Domknięto `P0.1 Spójny status` po stronie workera.
- ✅ Dodano kontrakt sekcji statusu do artefaktu `i18n/status/status_sections_latest.json` (state/freshness/source/last_update per sekcja).
- ✅ `TRANSLATION` freshness jest liczony z realnych timestampów tłumaczeń (`translation_guard_latest.json` / `translation_recent_latest.json`), a nie z `sync_last_ts`.
- ✅ Domknięto TODO operacyjny poza zakresem C++/H: debounce/backoff restartów guardiana dla triggera `mtime` (`.guardian_restart_state.json`, `i18n/status/guardian_restart_metrics.json`, `.guardian_run.lock`).

Aktualizacja uzupełniająca (2026-02-13 21:47 UTC):
- ✅ Domknięto operacyjnie `P2.1`: webhook alerting w `statusd` (`doctor_critical`, `guardian_stuck`, `no_progress`) z cooldown/deduplikacją (`statusd_alert_state.json`).
- ✅ Domknięto operacyjnie `P2.2`: raport 24h (`statusd_daily_report.json` + `statusd_daily_report.md`) z trendami per język/per kategoria.
- ✅ Naprawiono zgodność kontraktu coverage w `statusd` pod `translation_global_overview.json` (`languages[]`).
- ✅ Nowe TODO kontraktowe: dodać dedykowany artefakt `pending_skip` dla okna 24h (obecnie raport 24h bazuje na sygnałach z `worker_cycle_perf.detail`). → DONE 2026-02-14: `pending_skip_events.jsonl` + `pending_skip_24h_latest.json`.

Aktualizacja uzupełniająca (2026-02-13 — quality hardening PL/ES):
- ✅ Domknięto po stronie workera rozróżnienie `identical_to_en`:
  - translacyjne regresje vs techniczne wyjątki (`identical_to_en_exempt`).
- ✅ Heurystyka wyjątków obejmuje ścieżki, template markup, emotes i identyfikatory techniczne.
- ✅ Dzięki temu metryki quality lepiej odzwierciedlają realny problem językowy, a nie artefakty kodowe.
- ⬜ Nowe wymaganie dla pipeline C++/H:
  - dodać tag semantyczny `text_kind` (`natural_language` / `technical_token` / `script_path` / `template_fragment`) w emitowanych sygnałach,
  - przekazywać ten tag do i18n, aby quality gate i audyt miały wspólny kontrakt klasyfikacji.

Aktualizacja uzupełniająca (2026-02-13 22:23 UTC):
- ✅ Decyzja orkiestracyjna dla guardiana:
  - tryb startowy tłumaczeń: wszystkie języki (`translations_general`),
  - kolejność bootstrap: `es` -> `pl` -> pozostałe języki.
- Wpływ na pipeline C++/H:
  - sygnały priorytetu/domeny powinny uwzględniać, że PL/ES są pierwszą falą walidacyjną, a nie jedynym targetem.

Aktualizacja uzupełniająca (2026-02-13 22:38 UTC):
- ✅ Runtime alignment potwierdzony:
  - guardian pracuje na `translations_general` bez `--langs`,
  - selector publikuje stan bootstrapu `es -> pl` w `translation_dispatch_state.json` (`bootstrap_priority`, `bootstrap_forced_lang`, `cycle_counter`).
- ✅ Domknięto kolejkę naprawczą `identical_to_en (translatable)` dla PL/ES:
  - artefakty: `i18n/status/identical_to_en_repair_queue.json` + `i18n/status/identical_to_en_repair_queue_report.jsonl`,
  - priorytet domen queue: `npc -> server -> talkactions`.
- ⬜ Nowe wymaganie dla planu C++/H:
  - pipeline semantyczny powinien emitować tag domeny kompatybilny z queue repair (`npc/server/talkactions/...`), żeby statusd mógł korelować źródło zmian C++/H z realnym backlogiem tłumaczeń.

Aktualizacja uzupełniająca (2026-02-14 06:10 UTC):
- ✅ Statusd ma już pełny kontrakt telemetryczny repair queue:
  - `statusd_report.json` publikuje `repair_queue.stagnation`,
  - `statusd_daily_report.json/md` publikuje trend `Repair Queue 24h`,
  - webhook używa `reason_code=repair_queue_stagnation`.
- ✅ Worker/guardian tuning dla PL/ES:
  - adaptacyjne limity `REPAIR_IDENTICAL_LIMIT_*`,
  - profil `quality_repair` pracuje z `use_gt=true`, `translate_limit=60`.
- ⬜ Nowe wymaganie dla pipeline C++/H:
  - oprócz `domain` dodać mapowanie `repair_queue_key` (`lang:json_file`) i znacznik `repair_priority_tier`,
  - cel: korelacja zmian semantycznych C++/H z tym, czy backlog repair realnie maleje w `statusd_report`.

Wpływ na plan C++/H:
- semantyczny pipeline powinien emitować sygnały czasowe kompatybilne z `strict_hourly_window`, żeby statusd mógł łączyć dane C++/H i i18n bez mieszania metryk godzinowych z dobowymi.
- semantyczny pipeline powinien też zachować kompatybilność z kontraktem `status_sections_latest.json`, aby statusd mógł łączyć sygnały semantyczne z aktualnym stanem sekcji (active/inactive + freshness).
- semantyczny pipeline powinien publikować własne sygnały skip/no-progress w jawnych polach licznikowych (nie tylko w opisach tekstowych), żeby raport 24h miał spójne źródła KPI.

---

## 1) Problem do rozwiązania

Obecnie wiedza o kodzie C++/H jest rozproszona: funkcje, eventy, zależności i przepływy danych są trudne do odtworzenia bez ręcznego czytania wielu plików. To utrudnia:
- bezpieczne modyfikacje pod i18n,
- analizę ryzyk regresji,
- onboarding i szybkie diagnozowanie błędów.

Potrzebny jest system, który automatycznie buduje mapę semantyczną kodu i publikuje ją w formie użytecznej dla operatora i dewelopera.

---

## 2) Wynik docelowy (co ma powstać)

1. **Human View (skrót operacyjny):**
   - „co ten moduł robi”,
   - „jakie eventy uruchamia”,
   - „jakie są punkty ryzyka i18n”.

2. **Developer View (techniczny):**
   - graf funkcji (`caller -> callee`),
   - zależności plików (`include`, moduły, warstwy),
   - mapy eventów (`source -> handler -> side effect`),
   - punkty mutacji danych i I/O.

3. **Artefakty maszynowe:**
   - indeks symboli,
   - graf wywołań,
   - graf zależności include,
   - słownik eventów i hooków,
   - raport zmian semantycznych per commit.

---

## 3) Architektura pipeline

## 3.1 Wejścia
- `compile_commands.json`
- pliki `src/**/*.cpp`, `src/**/*.h`
- metadane build (`CMakeLists.txt`, konfiguracje)
- opcjonalnie logi runtime (dla walidacji event flow)

## 3.2 Etapy
1. **Parse & Index:** AST/IR symboli (funkcje, klasy, metody, pola, enumy).
2. **Graph Build:** graf wywołań, zależności includes, relacje modułowe.
3. **Event Extraction:** wykrycie event source/handler i efektów ubocznych.
4. **Semantic Tagging:** oznaczenie domen (`combat`, `quest`, `npc`, `network`, `i18n`).
5. **Dual Rendering:** generacja Human View + Developer View.
6. **Delta Engine:** porównanie wersji i raport zmian wpływających na i18n.

## 3.3 Wyjścia
- `docs/i18n/generated/human/*.md`
- `docs/i18n/generated/developer/*.md`
- `docs/i18n/generated/graphs/*.json|*.mmd`
- `docs/i18n/generated/delta/*.md`

---

## 4) Model danych semantycznych

## 4.1 Jednostki
- `Symbol`: funkcja/metoda/klasa/namespace.
- `Module`: logiczna domena kodu.
- `Event`: trigger + payload + handler.
- `Edge`: relacja (`calls`, `includes`, `emits`, `handles`, `reads`, `writes`).

## 4.2 Atrybuty wymagane
- plik, zakres linii, sygnatura, dostępność,
- zależności wejściowe/wyjściowe,
- poziom ryzyka i18n (`low|medium|high`),
- powiązane klucze i18n (jeśli wykryte).

## 4.3 Kontrakt kompatybilności
- każdy rekord ma `schema_version`,
- parser nie łamie starszych raportów (backward-compatible fields),
- brak danych oznaczany jawnie (`unknown`), nie pomijany.

---

## 5) Widoki: Human vs Developer

## 5.1 Human View (dla operatora/projektu)
Każdy moduł dostaje kartę:
1. Co robi moduł (2–5 zdań).
2. Najważniejsze eventy i skutki.
3. Punkty ryzyka (np. tekst dynamiczny, placeholdery, serializacja).
4. Ostatnie zmiany i wpływ na tłumaczenia.

## 5.2 Developer View (dla implementacji)
Każdy moduł dostaje:
1. listę symboli public/private,
2. call graph z poziomami głębokości,
3. dependency graph include,
4. event graph i side effects,
5. odnośniki do miejsc krytycznych dla i18n walidacji.

---

## 6) Integracja z workflow i18n

1. Pipeline uruchamiany cyklicznie (np. nightly) i przy większych zmianach w `src/`.
2. Raport delta trafia do statusu i checklisty pracy workera.
3. Jeśli delta wykrywa nowe źródła tekstów, tworzy zadanie do `KEY_MANAGEMENT`.
4. Jeśli delta wykrywa zmianę formatów/tokenów, podnosi priorytet `VALIDATION_QUALITY`.
5. Status operatorski pokazuje skrót: „które moduły C++/H zmieniły ryzyko i18n”.

---

## 7) Plan wdrożenia P0/P1/P2

## P0 — Fundament semantyczny
1. Parser AST + indeks symboli.
2. Graf wywołań i include dla krytycznych modułów (`game`, `npc`, `network`, `i18n`).
3. Minimalny Human View + Developer View dla top 10 modułów.

**DoD P0:** można wskazać dla każdej zmiany: dotknięte symbole, zależności i ryzyka i18n.

## P1 — Eventy i delta
1. Ekstrakcja eventów source/handler.
2. Delta engine między snapshotami.
3. Raport „zmiana semantyczna wpływa/nie wpływa na i18n”.

**DoD P1:** każdy większy PR ma automatyczny raport wpływu semantycznego.

## P2 — Automatyzacja i jakość
1. Ranking ryzyk modułów.
2. Sugestie testów regresji na podstawie graph delta.
3. Integracja z dashboardem i alertami.

**DoD P2:** automatyczne rekomendacje testów i zadań i18n z wysoką trafnością.

---

## 8) Testy i walidacja jakości danych

1. **Snapshot tests:** ten sam kod -> ten sam indeks/graf.
2. **Drift tests:** wykrywanie nieoczekiwanych zmian w parserze.
3. **Coverage tests:** procent symboli zmapowanych vs całkowitych.
4. **Accuracy review:** ręczna weryfikacja próbek top modułów.
5. **Latency budget:** pełny pipeline w akceptowalnym czasie CI.

Minimalne progi jakości:
- mapowanie symboli >= 95%,
- poprawność relacji `calls/includes` >= 90% na próbce kontrolnej,
- 0 krytycznych błędów schematu wyjściowego.

---

## 9) Ryzyka i mitigacje

1. **Różnice parserów/C++ dialect:**
   - mitigacja: bazowanie na `compile_commands.json` i stałej wersji toolchain.
2. **Duża objętość grafów:**
   - mitigacja: sharding per moduł + cache incremental.
3. **Fałszywe alarmy ryzyka i18n:**
   - mitigacja: scoring + whitelist + review loop.
4. **Nadmiar danych dla operatora:**
   - mitigacja: Human View jako krótki executive summary.

---

## 10) Deliverables do natychmiastowego uruchomienia

1. Specyfikacja JSON dla `Symbol`, `Event`, `Edge`.
2. Skeleton generatora raportów `human/developer`.
3. Lista modułów startowych i właścicieli przeglądu.
4. Checklista walidacyjna „go/no-go” dla publikacji raportu.

---

## 11) Kryteria odbioru końcowego

- Każda zmiana w C++/H ma automatyczną mapę wpływu i ryzyka.
- Human View jest czytelny dla osoby nietechnicznej w < 2 min.
- Developer View pozwala prześledzić przepływ funkcji/eventów bez ręcznego grepowania całego repo.
- System wspiera i18n worker przez konkretne sygnały do `KEY_MANAGEMENT` i `VALIDATION_QUALITY`.

---

## 12) Braki, które trzeba domknąć przed implementacją

### 12.1 Decyzja narzędziowa (parser)
- Brakowało jednoznacznej decyzji parsera AST.
- Decyzja startowa: parser oparty o `clang` z wejściem z `compile_commands.json`.
- Wymóg: ta sama wersja parsera w lokalnym środowisku i CI.

### 12.2 Kontrakt wejście/wyjście do i18n
- Brakowało twardego kontraktu dla integracji z workerem.
- Dodajemy artefakty:
   1. `semantic_delta.json` (zmienione symbole/eventy),
   2. `i18n_risk_signals.json` (sygnały do `KEY_MANAGEMENT`/`VALIDATION_QUALITY`),
   3. `module_summary.md` (human digest).

### 12.3 Ownership i cykl publikacji
- Brakowało odpowiedzialności za review danych semantycznych.
- Wymagane role:
   - owner parsera,
   - owner klasyfikacji i18n,
   - reviewer runtime.

### 12.4 Testy jakości klasyfikacji
- Brakowało testów błędnych klasyfikacji ryzyka i18n.
- Dodajemy zestaw walidacyjny dla false-positive i false-negative na próbce kontrolnej modułów.

### 12.5 Kontrakt czasowy dla metryk (nowe po Fazie 0)
- Brakowało jawnego rozróżnienia metryk godzinowych vs dobowych.
- Stan: `strict_hourly_window` jest już wdrożony w raporcie baseline i18n.
- Stan: kontrakt działa już także w renderingu `I18N_STATUS.md`.
- Wymagane dalej: pipeline semantyczny ma dostarczać znaczniki czasu i agregaty zgodne z tym kontraktem (`strict_hourly_window`, JSONL-first), aby status/KPI nie były zniekształcone przez sumy dzienne.

---

## 13) Najważniejsze luki dla trybu tłumaczeń (wynik z analizy C++/H)

### 13.1 Brak mapy źródeł tekstów runtime
- Potrzebna lista miejsc generujących teksty dynamiczne w C++ (`emit`, `message`, `description`, `dialog`).
- Bez tego worker nie dostaje pełnych sygnałów do tworzenia/aktualizacji kluczy.

### 13.2 Brak mapy placeholder contracts
- Potrzebne wykrywanie formatów (`%s`, `%d`, `{name}`, custom tokens) per moduł.
- Sygnał ma trafiać do quality gate tłumaczeń zanim klucz dostanie status done.

### 13.3 Brak mapy event -> locale impact
- Potrzebna zależność: który event wpływa na które locale/path.
- Pozwala to ustawić priorytet tłumaczeń po zmianach w kodzie.

### 13.4 Brak „translation hot paths”
- Potrzebny ranking krytycznych ścieżek (npc dialogi, quest outputs, item descriptions, client messages).
- Te ścieżki powinny mieć wyższy priorytet walidacji i krótszy czas reakcji.

### 13.5 Brak automatycznego triggera do Translation First
- Jeśli semantic delta dotyczy źródeł tekstu, system powinien automatycznie uruchomić etap `TRANSLATION_SYNC` + `VALIDATION_QUALITY` dla dotkniętych kategorii.

### 13.6 Nowy sygnał z runtime audytu (2026-02-14 11:55 UTC)
- W testach quest/NPC wykryto błędy typu "fragment contract drift":
  - utrata końcowej spacji w fragmentach łączonych runtime (`"You have to wait "` -> `"You have to wait"`),
  - błędne mapowanie semantyczne fragmentu (`"The chest is empty."` -> `"You found."`).
- Wniosek dla systemu semantycznego:
  1. trzeba jawnie oznaczać w C++/H/Lua klucze typu `fragment_concat_required`,
  2. trzeba emitować kontrakt `must_preserve_trailing_space=true` dla takich kluczy,
  3. `simple` dictionary nie może nadpisywać tych kluczy bez walidacji kontekstowej.
- Dodanie do backlogu semantycznego:
  - sygnał `placeholder_concat_contract_violation`,
  - sygnał `semantic_map_mismatch`,
  - trigger podniesienia priorytetu `VALIDATION_QUALITY` dla dotkniętych event-path.

### 13.7 Aktualizacja runtime (2026-02-14 12:35 UTC) — kontrakt świeżości i szybkie komendy

Wdrożone operacyjnie:
- ✅ `I18N_STATUS.md` (sekcja `MIGRATION`) korzysta ze świeżości live snapshot (`i18n_file_status.json` mtime), co usuwa fałszywie stare wskazania przy aktywnym systemie.
- ✅ Artefakty komend wymuszonych mają teraz pola SLA:
  - `forced_command_roundtrip_s`,
  - `forced_command_pending_age_s`,
  - `sla_target_s`,
  - `sla_met`.

Nowy sygnał semantyczno-operacyjny:
- Pomimo preemption końcówki cyklu, test `AUTO:lt:npc.json:20:ONCE` dał `pending_age_s=61`, `roundtrip_s=153` (`sla_met=false`).
- To znaczy, że semantycznie brakuje checkpointu „poll command” wewnątrz długiej fazy tłumaczenia (nie tylko między fazami high-level).

Dopisane zadania do warstwy semantycznej:
- [ ] `SEM-CMD-1`: sygnał `mid_cycle_pickup_delay_s` (czas od `received` do wejścia w wykonanie w obrębie aktywnego cyklu).
- [ ] `SEM-CMD-2`: oznaczenie etapów przerywalnych (`interruptible=true`) dla `AUTO_TRANSLATE` i `VALIDATION`.
- [ ] `SEM-CONCAT-1`: rozszerzyć klasyfikację `fragment_concat_required` o krótkie questowe komunikaty runtime (`msg_*/say_*`) dla LT/CS/EL/IT.

### 13.8 Aktualizacja runtime (2026-02-14 13:12 UTC) — domknięcie kontraktu short/concat po stronie worker

Wdrożone operacyjnie (warstwa wykonawcza):
- ✅ `npc short-dialog contract`: dla LT/CS/EL/IT uruchomiony dedykowany repair pass + hard reject EN-copy dla fraz:
  `Good bye.`, `Good bye!`, `Good bye then.`, `Then not.`, `Ok then.`, `Take this!`, `Greetings, |PLAYERNAME|.`
- ✅ `quest concat contract` dla `it/quests.json`: runtime fragmenty z trailing-space zostały naprawione deterministycznie.
- ✅ Wynik jakości: EN-copy dla wymuszonej listy short fraz spadł do `0/164` w `lt/cs/el/it`.

Wniosek semantyczny:
- wykonawczo kontrakty działają, ale warstwa semantyczna nadal nie publikuje jawnych metryk:
  - `mid_cycle_pickup_delay_s`,
  - `interruptible=true` per etap,
  - globalny sygnał concat-contract per domena.

Status backlogu semantycznego:
- `SEM-CMD-1`, `SEM-CMD-2`, `SEM-CONCAT-1` pozostają otwarte i są nadal wymagane do pełnej automatyzacji statusd/doctor.

### 13.9 Aktualizacja runtime (2026-02-14 14:07 UTC) — preemption checkpoints i kontrakt 55 języków

Wdrożone w warstwie wykonawczej (worker/guardian):
- ✅ etapy `AUTO_TRANSLATE` i końcówka cyklu są bardziej przerywalne:
  - dodatkowe checkpointy pending command przed/po repair,
  - przerwanie `parallel langs`, gdy czeka nowa komenda,
  - `mid-batch` poll zagęszczony do co 4 klucze.
- ✅ sleep końcowy i IDLE sleep są przerywalne przez `.worker_command`.
- ✅ guardian wymusza kontrakt pracy tłumaczeniowej (`--translations-only --use-gt --no-git`) na aktywnym workerze.

Pomiar kontrolny:
- `AUTO:cs:npc.json:1:ONCE` -> `pending_age_s=13`, `roundtrip_s=15` (`sla_met=true`).

Wniosek semantyczny:
- wykonawczo `interruptible` działa, ale semantyczna telemetria nadal nie emituje jawnego pola
  `mid_cycle_pickup_delay_s`, więc doctor nie rozróżnia pełnego opóźnienia wejścia do aktywnego etapu.

Nowe TODO semantyczne:
- [ ] `SEM-55-LANG-1` (P0): dodać semantyczny profil domenowy `items/npc/quests` dla pełnych 55 języków (gramatyka/styl + placeholder contract).
- [ ] `SEM-55-LANG-2` (P0): publikować per-język sygnał `grammar_style_risk` do kolejki quality-repair.

### 13.10 Aktualizacja runtime (2026-02-14 14:31 UTC) — materializacja `SEM-CMD-1` w telemetryce wykonawczej

Zrobione:
- ✅ `SEM-CMD-1` domknięte po stronie telemetry worker/statusd:
  - worker publikuje `mid_cycle_command_pickup_s`,
  - statusd doctor liczy `p95_mid_cycle_command_pickup_s` i `latest_mid_cycle_command_pickup_s`.
- ✅ Statusd dostał dodatkowy kontrakt orkiestracyjny:
  - `guardian_daemon_lock` (owner/age/threshold/stale_owner_dead) z alertingiem webhook reason code.

Wniosek semantyczny:
- sygnał „czas wejścia komendy do aktywnego etapu” jest już widoczny operacyjnie,
- ale mapowanie `interruptible=true` i semantyczne tagowanie etapów nadal wymaga domknięcia (`SEM-CMD-2` pozostaje otwarte).

Nowe TODO semantyczne:
- [x] `SEM-CMD-3` (P1): dodać semantyczny znacznik epoki telemetry (`runtime_epoch_id`), aby odróżniać próbki pre-fix/post-fix przy liczeniu p95 SLA. (DONE 2026-02-14 15:05 UTC)

### 13.11 Aktualizacja runtime (2026-02-14 14:44 UTC) — operational SLA view jako etap semantyczny

Zrobione:
- ✅ statusd ma teraz semantyczny podział SLA forced commands na:
  - `full_window` (historyczny kontekst),
  - `operational_window` (bieżąca praca),
  - aktywny wybór `analysis_view`.

Wniosek semantyczny:
- kontrakt „pre-fix vs post-fix” jest częściowo domknięty przez rolling operational window,
- pełne semantyczne odcięcie epoki nadal wymaga jawnego znacznika `runtime_epoch_id` / `baseline_ts`.

Nowe TODO semantyczne:
- [x] `SEM-CMD-4` (P1): mapować `analysis_view` + `operational_window_ready` do rekomendacji auto-akcji (np. różne progi dla rollback vs continue). (DONE 2026-02-14 15:05 UTC)

### 13.12 Aktualizacja runtime (2026-02-14 14:50 UTC) — baseline epoch jako fallback semantyczny

Zrobione:
- ✅ Wprowadzono opcjonalny `baseline_ts_utc` dla forced-command SLA:
  - pozwala ręcznie odciąć epokę pre-fix,
  - statusd publikuje poprawność i efektywny start baseline.

Wniosek semantyczny:
- `baseline_ts_utc` działa jako praktyczny fallback semantyczny dla rozdziału epok,
- docelowy, automatyczny `runtime_epoch_id` nadal pozostaje właściwym rozwiązaniem systemowym.

Nowe TODO semantyczne:
- [x] `SEM-CMD-5` (P1): zautomatyzować mapowanie `baseline_ts_utc` <-> `runtime_epoch_id` (spójny kontrakt semantyczny dla doctor/webhook/daily). (DONE 2026-02-14 15:05 UTC)

### 13.13 Aktualizacja runtime (2026-02-14 15:05 UTC) — domknięcie SEM-CMD-3/4/5 (kontrakt epoki + rekomendacje)

Zrobione:
- [x] `SEM-CMD-3` (P1): dodać semantyczny znacznik epoki telemetry (`runtime_epoch_id`), aby odróżniać próbki pre-fix/post-fix przy liczeniu p95 SLA. (DONE 2026-02-14 15:05 UTC)
- [x] `SEM-CMD-4` (P1): mapować `analysis_view` + `operational_window_ready` do rekomendacji auto-akcji (np. różne progi dla rollback vs continue). (DONE 2026-02-14 15:05 UTC)
- [x] `SEM-CMD-5` (P1): zautomatyzować mapowanie `baseline_ts_utc` <-> `runtime_epoch_id` (spójny kontrakt semantyczny dla doctor/webhook/daily). (DONE 2026-02-14 15:05 UTC)
- ✅ Semantyczny kontrakt epoki jest publikowany spójnie w:
  - `statusd_report.json`,
  - `statusd_doctor.json`,
  - `statusd_daily_report.json`,
  - webhook payload `forced_command_fast`.
- ✅ `recommended_action` materializuje decyzję operacyjną na podstawie semantyki aktywnego widoku (`operational_window` vs `full_window`) i gotowości próbek.

Wniosek semantyczny:
- Warstwa semantyczna ma już jawny kontrakt epoki runtime oraz deterministyczne mapowanie decyzji operacyjnych dla forced-command SLA.

Nowe TODO semantyczne:
- [ ] `SEM-CMD-6` (P1): dodać semantyczny tryb bootstrap pierwszej obserwacji epoki (`first_observation_no_baseline` -> opcjonalny auto-baseline), aby kontrakt epoki był kompletny także na pierwszym starcie mechanizmu.
