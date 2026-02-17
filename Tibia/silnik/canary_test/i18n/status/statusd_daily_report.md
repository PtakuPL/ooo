# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T00:17:20.907065Z`
- Window: `2026-02-16T00:17:20.907065Z` -> `2026-02-17T00:17:20.907065Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 19387 |
| guard_fail | 9450 |
| guard_fail_rate | 32.77% |
| no_progress_entries | 11 |
| no_progress_rate | 2.44% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 807.8 |
| throughput_keys_per_h_active | 4792.8 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 44391 |
| suspicious_high_count | 44263 |
| suspicious_high_rate | 202.77% |
| suspicious_high_top_lang | ro:16427 |
| identical_to_en_count | 2080 |
| gt_guard_fails_count | 1780 |
| latest_audit_issues_found | 8 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 80 |
| latest_entries_total | 711 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 4.039 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 79 |
| avg_limit | 108.91 |
| avg_suspicious_high_pct | 246.36% |
| translated_total | 1840 |
| guard_fail_total | 57 |
| guard_fail_rate_pct | 3.00% |
| gt_mode_true_samples | 79 |
| latest_timestamp | 2026-02-17T00:14:42.947622Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 320.66% | 2437 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 320.66% | 2437 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 320.48% | 2410 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 320.48% | 2410 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 320.48% | 2410 | low_backlog+suspicious_guard | 108 |

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
| active_minutes | 121.476 |
| cycle_delta | 212 |
| best_quality_drop_pct | 25.34% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 44.29% | 0 | 1922 | 42.3% | 69.4% |
| ES | 74.16% | 0 | 2633 | 74.8% | 65.2% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.05% | 0 | 4028 | 30.5% | 66.1% |
| RU | 36.04% | 0 | 2622 | 33.4% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 3497 | 80 | 2.24% | 2.67% |
| ru | 3157 | 528 | 14.33% | 2.70% |
| ro | 3025 | 546 | 15.29% | 0.00% |
| sv | 2559 | 91 | 3.43% | 0.00% |
| sr | 2483 | 117 | 4.50% | 0.00% |
| pl | 2430 | 7596 | 75.76% | 8.06% |
| es | 2236 | 492 | 18.04% | 3.23% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 3914 | 1986 | 33.66% | 0.00% |
| server.json | 3446 | 629 | 15.44% | 3.90% |
| monsters.json | 3396 | 944 | 21.75% | 0.00% |
| items.json | 3340 | 4658 | 58.24% | 0.00% |
| scripts.json | 893 | 175 | 16.39% | 0.00% |
| spells.json | 811 | 139 | 14.63% | 0.00% |
| html.json | 589 | 39 | 6.21% | 0.00% |
| otclient_modules.json | 508 | 49 | 8.80% | 0.00% |
| quests.json | 494 | 94 | 15.99% | 0.00% |
| questlog.json | 412 | 204 | 33.12% | 0.00% |
| raids.json | 396 | 150 | 27.47% | 16.67% |
| books.json | 358 | 142 | 28.40% | 0.00% |

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
| current_total | 38661 |
| backlog_es | 298 |
| backlog_pl | 217 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 589 |
| backlog_hu | 663 |
| backlog_it | 496 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 512 |
| backlog_ru | 127 |
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
| backlog_sr | 494 |
| backlog_sv | 547 |
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
| delta_24h | -1390 (-3.5%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 3.4% over 3.6h |
