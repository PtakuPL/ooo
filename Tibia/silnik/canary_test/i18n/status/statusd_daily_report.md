# I18N Daily Executive Report (24h)

- Generated: `2026-02-15T13:18:18.008268Z`
- Window: `2026-02-14T13:18:18.008268Z` -> `2026-02-15T13:18:18.008268Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 22725 |
| guard_fail | 26697 |
| guard_fail_rate | 54.02% |
| no_progress_entries | 82 |
| no_progress_rate | 12.52% |
| pending_skip_count | 258 |
| pending_skip_share | 43.40% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 946.9 |
| throughput_keys_per_h_active | 949.5 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 26820 |
| suspicious_high_count | 25849 |
| suspicious_high_rate | 39.28% |
| suspicious_high_top_lang | es:18076 |
| identical_to_en_count | 1960 |
| gt_guard_fails_count | 22830 |
| latest_audit_issues_found | 19 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 369 |
| latest_entries_total | 702 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 11 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 11 |
| stagnation_detected | no |
| stagnation_span_h | 5.905 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 281 |
| avg_limit | 108.51 |
| avg_suspicious_high_pct | 152.56% |
| translated_total | 6069 |
| guard_fail_total | 5059 |
| guard_fail_rate_pct | 45.46% |
| gt_mode_true_samples | 281 |
| latest_timestamp | 2026-02-15T13:18:09.692717Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 314.53% | 2359 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 305.70% | 2308 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 305.70% | 2308 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 305.70% | 2308 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 305.70% | 2308 | low_backlog+suspicious_guard | 108 |

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
| pending_langs | es,pl |
| active_minutes | 1515.802 |
| cycle_delta | 822 |
| best_quality_drop_pct | 18.50% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.42% | 0 | 2332 | 88.1% | 78.8% |
| ES | 83.73% | 0 | 2627 | 84.1% | 79.5% |
| DE | 8.07% | 0 | 2863 | 8.5% | 3.0% |
| PT | 7.81% | 0 | 2776 | 8.2% | 2.9% |
| FR | 33.32% | 0 | 3922 | 30.8% | 66.1% |
| RU | 33.86% | 0 | 1755 | 31.0% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| pl | 11061 | 18897 | 63.08% | 13.27% |
| es | 10980 | 7799 | 41.53% | 11.85% |
| cs | 177 | 0 | 0.00% | 0.00% |
| it | 164 | 0 | 0.00% | 50.00% |
| el | 164 | 0 | 0.00% | 0.00% |
| lt | 139 | 1 | 0.71% | 0.00% |
| ru | 10 | 0 | 0.00% | 0.00% |
| ro | 10 | 0 | 0.00% | 0.00% |
| fr | 10 | 0 | 0.00% | 0.00% |
| de | 10 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| monsters.json | 5999 | 1982 | 24.83% | 9.21% |
| npc.json | 3421 | 6898 | 66.85% | 13.56% |
| html.json | 3363 | 1508 | 30.96% | 4.00% |
| server.json | 2181 | 1552 | 41.58% | 19.44% |
| items.json | 1577 | 8308 | 84.05% | 13.64% |
| spells.json | 1285 | 259 | 16.77% | 6.58% |
| scripts.json | 1235 | 2309 | 65.15% | 10.64% |
| questlog.json | 727 | 756 | 50.98% | 0.00% |
| raids.json | 725 | 179 | 19.80% | 9.76% |
| otclient_modules.json | 650 | 399 | 38.04% | 7.14% |
| quests.json | 497 | 911 | 64.70% | 13.51% |
| cpp.json | 418 | 176 | 29.63% | 16.67% |

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
| current_total | 39100 |
| backlog_es | 532 |
| backlog_pl | 314 |
| backlog_cs | 641 |
| backlog_de | 660 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 630 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 689 |
| backlog_ru | 65 |
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
| backlog_sr | 663 |
| backlog_sv | 663 |
| backlog_sw | 905 |
| backlog_ta | 905 |
| backlog_te | 905 |
| backlog_th | 905 |
| backlog_tl | 905 |
| backlog_uk | 663 |
| backlog_uz | 663 |
| backlog_vi | 905 |
| backlog_zh | 905 |
| backlog_zh_TW | 2040 |
| delta_24h | -947 (-2.4%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.2% over 5.8h |
