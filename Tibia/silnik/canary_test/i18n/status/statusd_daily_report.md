# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T05:21:26.322435Z`
- Window: `2026-02-16T05:21:26.322435Z` -> `2026-02-17T05:21:26.322435Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 38259 |
| guard_fail | 25704 |
| guard_fail_rate | 40.19% |
| no_progress_entries | 23 |
| no_progress_rate | 2.36% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1594.1 |
| throughput_keys_per_h_active | 4196.3 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 84269 |
| suspicious_high_count | 84014 |
| suspicious_high_rate | 195.54% |
| suspicious_high_top_lang | ro:29387 |
| identical_to_en_count | 4371 |
| gt_guard_fails_count | 6575 |
| latest_audit_issues_found | 27 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 178 |
| latest_entries_total | 708 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 5.994 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 177 |
| avg_limit | 108.41 |
| avg_suspicious_high_pct | 290.47% |
| translated_total | 4104 |
| guard_fail_total | 145 |
| guard_fail_rate_pct | 3.41% |
| gt_mode_true_samples | 177 |
| latest_timestamp | 2026-02-17T05:20:18.205373Z |

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
| active_minutes | 425.567 |
| cycle_delta | 800 |
| best_quality_drop_pct | 61.30% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 47.42% | 0 | 1894 | 45.7% | 69.5% |
| ES | 74.92% | 0 | 2630 | 75.6% | 66.0% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.06% | 0 | 4023 | 30.5% | 66.1% |
| RU | 38.30% | 0 | 2569 | 35.7% | 71.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 7315 | 690 | 8.62% | 1.81% |
| ru | 6894 | 1300 | 15.87% | 1.82% |
| ro | 6417 | 1873 | 22.59% | 0.00% |
| pl | 5510 | 19142 | 77.65% | 5.88% |
| es | 4370 | 1912 | 30.44% | 5.41% |
| sv | 3941 | 378 | 8.75% | 0.00% |
| sr | 3812 | 409 | 9.69% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6768 | 4498 | 39.93% | 0.00% |
| server.json | 5295 | 1231 | 18.86% | 2.38% |
| monsters.json | 5191 | 1729 | 24.99% | 0.00% |
| items.json | 5160 | 12105 | 70.11% | 0.00% |
| scripts.json | 2482 | 1422 | 36.42% | 0.00% |
| spells.json | 2308 | 1092 | 32.12% | 0.00% |
| quests.json | 1937 | 503 | 20.61% | 0.00% |
| html.json | 1809 | 182 | 9.14% | 0.00% |
| raids.json | 1418 | 212 | 13.01% | 7.89% |
| otclient_modules.json | 1275 | 344 | 21.25% | 0.00% |
| questlog.json | 1150 | 814 | 41.45% | 0.00% |
| books.json | 1150 | 700 | 37.84% | 0.00% |

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
| current_total | 38463 |
| backlog_es | 300 |
| backlog_pl | 184 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 586 |
| backlog_hu | 663 |
| backlog_it | 448 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 465 |
| backlog_ru | 108 |
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
| backlog_sr | 492 |
| backlog_sv | 499 |
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
| delta_24h | -1588 (-4.0%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.8% over 6.0h |
