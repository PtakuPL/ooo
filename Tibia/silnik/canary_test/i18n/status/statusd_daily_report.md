# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T07:22:38.560144Z`
- Window: `2026-02-16T07:22:38.560144Z` -> `2026-02-17T07:22:38.560144Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 44040 |
| guard_fail | 30043 |
| guard_fail_rate | 40.55% |
| no_progress_entries | 24 |
| no_progress_rate | 2.09% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1835.0 |
| throughput_keys_per_h_active | 3954.2 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 94759 |
| suspicious_high_count | 94455 |
| suspicious_high_rate | 190.00% |
| suspicious_high_top_lang | ro:32354 |
| identical_to_en_count | 5103 |
| gt_guard_fails_count | 8377 |
| latest_audit_issues_found | 0 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 213 |
| latest_entries_total | 699 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | -27 |
| stagnation_detected | no |
| stagnation_span_h | 5.941 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 211 |
| avg_limit | 108.34 |
| avg_suspicious_high_pct | 295.05% |
| translated_total | 5072 |
| guard_fail_total | 459 |
| guard_fail_rate_pct | 8.30% |
| gt_mode_true_samples | 211 |
| latest_timestamp | 2026-02-17T07:19:05.274397Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 333.15% | 2382 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 330.05% | 2449 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 330.05% | 2449 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 330.05% | 2449 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.75% | 2413 | low_backlog+suspicious_guard | 108 |

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
| detected | no |
| severity | info |
| reason | tracking |
| pending_langs | es,it,pl,ro,ru,sr,sv |
| active_minutes | 546.75 |
| cycle_delta | 992 |
| best_quality_drop_pct | 61.30% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.21% | 0 | 1753 | 87.9% | 78.8% |
| ES | 84.24% | 0 | 2058 | 84.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3798 | 30.5% | 66.1% |
| RU | 49.65% | 0 | 1470 | 47.9% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 8607 | 1018 | 10.58% | 1.49% |
| ru | 8207 | 1601 | 16.32% | 1.51% |
| ro | 7575 | 2402 | 24.08% | 0.00% |
| pl | 6134 | 21772 | 78.02% | 5.65% |
| es | 4824 | 2285 | 32.14% | 4.71% |
| sv | 4398 | 489 | 10.01% | 0.00% |
| sr | 4295 | 476 | 9.98% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 7423 | 5492 | 42.52% | 0.00% |
| monsters.json | 5754 | 1884 | 24.67% | 0.00% |
| items.json | 5740 | 13201 | 69.70% | 0.00% |
| server.json | 5610 | 1416 | 20.15% | 2.21% |
| scripts.json | 3002 | 1886 | 38.58% | 0.00% |
| spells.json | 2521 | 1379 | 35.36% | 0.00% |
| html.json | 2281 | 274 | 10.72% | 0.00% |
| quests.json | 2197 | 632 | 22.34% | 0.00% |
| raids.json | 1808 | 218 | 10.76% | 6.38% |
| otclient_modules.json | 1617 | 469 | 22.48% | 0.00% |
| cpp.json | 1539 | 326 | 17.48% | 0.00% |
| questlog.json | 1413 | 1145 | 44.76% | 0.00% |

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
| current_total | 37884 |
| backlog_es | 213 |
| backlog_pl | 129 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 304 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 382 |
| backlog_ru | 60 |
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
| backlog_sr | 374 |
| backlog_sv | 463 |
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
| delta_24h | -2167 (-5.4%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.9% over 5.9h |
