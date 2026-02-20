# I18N Daily Executive Report (24h)

- Generated: `2026-02-20T23:14:44.861551Z`
- Window: `2026-02-19T23:14:44.861551Z` -> `2026-02-20T23:14:44.861551Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 17805 |
| guard_fail | 38544 |
| guard_fail_rate | 68.40% |
| no_progress_entries | 25 |
| no_progress_rate | 3.14% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 741.9 |
| throughput_keys_per_h_active | 2552.2 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 108468 |
| suspicious_high_count | 107978 |
| suspicious_high_rate | 498.86% |
| suspicious_high_top_lang | ro:46923 |
| identical_to_en_count | 1658 |
| gt_guard_fails_count | 10255 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 159 |
| latest_entries_total | 700 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 5.936 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 156 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 302.55% |
| translated_total | 3650 |
| guard_fail_total | 4194 |
| guard_fail_rate_pct | 53.47% |
| gt_mode_true_samples | 156 |
| latest_timestamp | 2026-02-20T23:08:36.434082Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |

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
| active_minutes | 5818.872 |
| cycle_delta | 5794 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.85% | 0 | 1831 | 88.5% | 78.8% |
| ES | 85.13% | 0 | 2151 | 85.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.43% | 0 | 1469 | 48.7% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 4297 | 488 | 10.20% | 2.00% |
| it | 3431 | 1041 | 23.28% | 4.03% |
| es | 2676 | 10991 | 80.42% | 5.30% |
| ro | 2554 | 1449 | 36.20% | 3.10% |
| pl | 2470 | 24277 | 90.77% | 2.88% |
| sr | 1289 | 61 | 4.52% | 0.00% |
| sv | 1088 | 237 | 17.89% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 5790 | 9332 | 61.71% | 0.00% |
| monsters.json | 4479 | 832 | 15.67% | 0.00% |
| items.json | 3601 | 23936 | 86.92% | 0.00% |
| server.json | 1066 | 1220 | 53.37% | 1.69% |
| scripts.json | 640 | 450 | 41.28% | 0.00% |
| questlog.json | 475 | 214 | 31.06% | 0.00% |
| raids.json | 471 | 122 | 20.57% | 15.00% |
| html.json | 316 | 83 | 20.80% | 0.00% |
| otclient_modules.json | 202 | 279 | 58.00% | 0.00% |
| spells.json | 159 | 1309 | 89.17% | 13.64% |
| cpp.json | 93 | 78 | 45.61% | 0.00% |
| achievements.json | 74 | 39 | 34.51% | 33.33% |

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
| current_total | 37791 |
| backlog_es | 269 |
| backlog_pl | 149 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 423 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 424 |
| backlog_ru | 72 |
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
| backlog_sr | 96 |
| backlog_sv | 399 |
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
| delta_24h | -104 (-0.3%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.2% over 6.0h |
