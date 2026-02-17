# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T03:19:49.520153Z`
- Window: `2026-02-16T03:19:49.520153Z` -> `2026-02-17T03:19:49.520153Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 31304 |
| guard_fail | 19789 |
| guard_fail_rate | 38.73% |
| no_progress_entries | 17 |
| no_progress_rate | 2.21% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1304.3 |
| throughput_keys_per_h_active | 4417.4 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 70019 |
| suspicious_high_count | 69811 |
| suspicious_high_rate | 198.81% |
| suspicious_high_top_lang | ro:24984 |
| identical_to_en_count | 3450 |
| gt_guard_fails_count | 4353 |
| latest_audit_issues_found | 11 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 139 |
| latest_entries_total | 710 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 5.998 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 138 |
| avg_limit | 108.52 |
| avg_suspicious_high_pct | 279.88% |
| translated_total | 3208 |
| guard_fail_total | 105 |
| guard_fail_rate_pct | 3.17% |
| gt_mode_true_samples | 138 |
| latest_timestamp | 2026-02-17T03:18:44.454175Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.09% | 2441 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.82% | 2439 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.69% | 2438 | low_backlog+suspicious_guard | 108 |

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
| severity | ok |
| reason | tracking |
| pending_langs | es,it,pl,ro,ru,sr,sv |
| active_minutes | 303.953 |
| cycle_delta | 572 |
| best_quality_drop_pct | 31.14% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 46.37% | 0 | 1910 | 44.6% | 69.5% |
| ES | 74.73% | 0 | 2630 | 75.4% | 65.6% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.06% | 0 | 4025 | 30.5% | 66.1% |
| RU | 37.61% | 0 | 2581 | 35.0% | 71.1% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 5926 | 402 | 6.35% | 2.29% |
| ru | 5490 | 977 | 15.11% | 2.31% |
| ro | 5096 | 1284 | 20.13% | 0.00% |
| pl | 4454 | 15397 | 77.56% | 5.13% |
| es | 3631 | 1251 | 25.62% | 4.31% |
| sv | 3393 | 226 | 6.24% | 0.00% |
| sr | 3314 | 252 | 7.07% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 5836 | 3581 | 38.03% | 0.00% |
| server.json | 4755 | 921 | 16.23% | 2.75% |
| items.json | 4518 | 9948 | 68.77% | 0.00% |
| monsters.json | 4498 | 1486 | 24.83% | 0.00% |
| scripts.json | 1927 | 928 | 32.50% | 0.00% |
| spells.json | 1878 | 672 | 26.35% | 0.00% |
| quests.json | 1374 | 306 | 18.21% | 0.00% |
| html.json | 1255 | 108 | 7.92% | 0.00% |
| raids.json | 1028 | 206 | 16.69% | 10.34% |
| otclient_modules.json | 893 | 152 | 14.55% | 0.00% |
| books.json | 860 | 440 | 33.85% | 0.00% |
| questlog.json | 820 | 506 | 38.16% | 0.00% |

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
| current_total | 38569 |
| backlog_es | 300 |
| backlog_pl | 207 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 586 |
| backlog_hu | 663 |
| backlog_it | 470 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 488 |
| backlog_ru | 112 |
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
| backlog_sv | 533 |
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
| delta_24h | -1482 (-3.7%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.7% over 6.0h |
