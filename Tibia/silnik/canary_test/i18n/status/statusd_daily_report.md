# I18N Daily Executive Report (24h)

- Generated: `2026-02-20T17:12:09.769042Z`
- Window: `2026-02-19T17:12:09.769042Z` -> `2026-02-20T17:12:09.769042Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 5848 |
| guard_fail | 11763 |
| guard_fail_rate | 66.79% |
| no_progress_entries | 693 |
| no_progress_rate | 79.11% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 243.7 |
| throughput_keys_per_h_active | 243.9 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 22266 |
| suspicious_high_count | 22094 |
| suspicious_high_rate | 320.95% |
| suspicious_high_top_lang | ro:8285 |
| identical_to_en_count | 650 |
| gt_guard_fails_count | 3629 |
| latest_audit_issues_found | 26 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 178 |
| latest_entries_total | 699 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 0.926 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 170 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 278.15% |
| translated_total | 802 |
| guard_fail_total | 932 |
| guard_fail_rate_pct | 53.75% |
| gt_mode_true_samples | 170 |
| latest_timestamp | 2026-02-20T17:11:44.620165Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 307.51% | 2128 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 306.34% | 2126 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 305.17% | 2124 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 301.71% | 2118 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 300.57% | 2116 | low_backlog+suspicious_guard | 108 |

## Metrics Drift (LIVE vs Registry)

| Metric | Value |
|---|---:|
| status | stable |
| severity | ok |
| live_keys | 53586 |
| worker_registry_keys | 53586 |
| worker_registry_keys_raw | 0 |
| registry_reconcile_adjustment | 0 |
| outside_worker_registry_keys | 0 |
| outside_worker_registry_pct | 0.00% |
| outside_worker_registry_keys_raw | 0 |
| outside_worker_registry_pct_raw | 0.00% |
| warn_threshold_keys | 5000 |
| critical_threshold_keys | 20000 |
| warn_threshold_pct | 20.00% |
| critical_threshold_pct | 50.00% |
| threshold_source | statusd_thresholds_file |
| threshold_config_file | /home/ptaku/serweryt/Tibia/silnik/canary_test/statusd_thresholds.json |
| env_overrides_enabled | no |

## Priority Gate Watch

| Metric | Value |
|---|---:|
| enabled | yes |
| active | yes |
| detected | yes |
| severity | critical |
| reason | active_time_without_quality_drop |
| pending_langs | es,it,pl,ro,ru,sr,sv |
| active_minutes | 5456.28 |
| cycle_delta | 4983 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.77% | 0 | 1831 | 88.5% | 78.8% |
| ES | 84.62% | 0 | 2162 | 85.0% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3791 | 30.5% | 66.1% |
| RU | 50.35% | 0 | 1457 | 48.6% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 1158 | 222 | 16.09% | 76.69% |
| it | 1080 | 341 | 24.00% | 77.14% |
| pl | 892 | 7469 | 89.33% | 73.81% |
| es | 880 | 3032 | 77.51% | 73.48% |
| ro | 862 | 575 | 40.01% | 76.19% |
| sr | 542 | 8 | 1.45% | 89.91% |
| sv | 434 | 116 | 21.09% | 90.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 1649 | 2810 | 63.02% | 46.38% |
| monsters.json | 1063 | 368 | 25.72% | 50.88% |
| items.json | 785 | 6322 | 88.95% | 60.71% |
| server.json | 686 | 490 | 41.67% | 61.22% |
| scripts.json | 324 | 207 | 38.98% | 71.43% |
| questlog.json | 257 | 161 | 38.52% | 80.00% |
| raids.json | 219 | 69 | 23.96% | 78.79% |
| html.json | 200 | 21 | 9.50% | 87.50% |
| otclient_modules.json | 150 | 80 | 34.78% | 83.33% |
| achievements.json | 137 | 58 | 29.74% | 83.33% |
| spells.json | 130 | 711 | 84.54% | 63.04% |
| books.json | 65 | 235 | 78.33% | 87.88% |

## Notes

- pending_skip_share preferuje pending_skip_24h_latest.json; fallback: worker_cycle_perf.detail.
- no_progress_rate bazuje na translation_guard_report (translated<=0).
- repair_queue_24h bazuje na identical_to_en_repair_queue_report.jsonl.
- repair_tuning_24h bazuje na identical_to_en_repair_tuning.jsonl.
- metrics_drift rozdziela registry raw i registry effective po registry_reconcile.
- priority_gate_watch śledzi aktywność fali ES/PL i wykrywa stuck bez spadku quality rate.

## Migration (tworzenie kluczy EN)

| Metric | Value |
|---|---:|
| files_total | 15 |
| files_completed | 15 |
| files_migrated | 7 |
| scanned_files_live | 15 |
| scanned_files_history | 6443 |
| scanned_files_history_minus_live | 6428 |
| total_keys_extracted | 53586 |
| total_keys_extracted_live | 53586 |
| total_keys_extracted_worker_registry | 53586 |
| keys_extracted_outside_worker_registry | 0 |
| npc_total | 1027 |
| npc_migrated | 699 |
| npc_needs_migration | 0 |

## Scope (Serwer vs Instalka)

- Serwer EN keys: **49731**
- Instalka EN keys: **3855**

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 37894 |
| backlog_es | 277 |
| backlog_pl | 146 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 445 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 424 |
| backlog_ru | 59 |
| backlog_sk | 663 |
| backlog_tr | 542 |
| backlog_ar | 904 |
| backlog_az | 662 |
| backlog_bg | 691 |
| backlog_bn | 904 |
| backlog_bs | 663 |
| backlog_da | 663 |
| backlog_el | 647 |
| backlog_et | 663 |
| backlog_fa | 904 |
| backlog_fi | 663 |
| backlog_he | 904 |
| backlog_hi | 904 |
| backlog_hr | 663 |
| backlog_hy | 905 |
| backlog_id | 904 |
| backlog_ja | 904 |
| backlog_ka | 905 |
| backlog_kk | 663 |
| backlog_ko | 905 |
| backlog_lt | 641 |
| backlog_lv | 663 |
| backlog_mk | 662 |
| backlog_ml | 905 |
| backlog_ms | 904 |
| backlog_no | 663 |
| backlog_sl | 663 |
| backlog_sq | 663 |
| backlog_sr | 50 |
| backlog_sv | 534 |
| backlog_sw | 905 |
| backlog_ta | 905 |
| backlog_te | 905 |
| backlog_th | 905 |
| backlog_tl | 905 |
| backlog_uk | 663 |
| backlog_uz | 663 |
| backlog_vi | 905 |
| backlog_zh | 905 |
| backlog_zh_TW | 2456 |
| delta_24h | -19 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.0% over 0.4h |
