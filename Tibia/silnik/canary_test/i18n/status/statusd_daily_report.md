# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T08:23:06.745183Z`
- Window: `2026-02-16T08:23:06.745183Z` -> `2026-02-17T08:23:06.745183Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 46418 |
| guard_fail | 32230 |
| guard_fail_rate | 40.98% |
| no_progress_entries | 25 |
| no_progress_rate | 2.05% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1934.1 |
| throughput_keys_per_h_active | 3825.6 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 98931 |
| suspicious_high_count | 98612 |
| suspicious_high_rate | 187.65% |
| suspicious_high_top_lang | ro:33063 |
| identical_to_en_count | 5440 |
| gt_guard_fails_count | 9588 |
| latest_audit_issues_found | 19 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 229 |
| latest_entries_total | 699 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | -27 |
| stagnation_detected | no |
| stagnation_span_h | 5.969 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 228 |
| avg_limit | 108.32 |
| avg_suspicious_high_pct | 289.94% |
| translated_total | 5530 |
| guard_fail_total | 946 |
| guard_fail_rate_pct | 14.61% |
| gt_mode_true_samples | 228 |
| latest_timestamp | 2026-02-17T08:22:41.763921Z |

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
| active_minutes | 607.233 |
| cycle_delta | 1076 |
| best_quality_drop_pct | 63.24% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.21% | 0 | 1786 | 87.9% | 78.8% |
| ES | 84.23% | 0 | 2122 | 84.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3798 | 30.5% | 66.1% |
| RU | 49.80% | 0 | 1461 | 48.0% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 9168 | 1360 | 12.92% | 1.39% |
| ru | 8728 | 1715 | 16.42% | 1.40% |
| ro | 8043 | 2699 | 25.13% | 0.00% |
| pl | 6370 | 22719 | 78.10% | 5.35% |
| es | 5016 | 2659 | 34.64% | 4.95% |
| sv | 4598 | 601 | 11.56% | 0.00% |
| sr | 4495 | 477 | 9.59% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 7698 | 5929 | 43.51% | 0.00% |
| monsters.json | 6021 | 1934 | 24.31% | 0.00% |
| items.json | 6015 | 14037 | 70.00% | 0.00% |
| server.json | 5864 | 1522 | 20.61% | 2.11% |
| scripts.json | 3156 | 1938 | 38.04% | 0.00% |
| spells.json | 2601 | 1556 | 37.43% | 0.00% |
| html.json | 2501 | 311 | 11.06% | 0.00% |
| quests.json | 2206 | 666 | 23.19% | 1.56% |
| raids.json | 1928 | 218 | 10.16% | 6.00% |
| otclient_modules.json | 1785 | 523 | 22.66% | 0.00% |
| cpp.json | 1674 | 371 | 18.14% | 0.00% |
| questlog.json | 1512 | 1276 | 45.77% | 0.00% |

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
| current_total | 38169 |
| backlog_es | 262 |
| backlog_pl | 139 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 462 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 435 |
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
| backlog_sr | 282 |
| backlog_sv | 570 |
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
| delta_24h | -1882 (-4.7%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.1% over 6.0h |
