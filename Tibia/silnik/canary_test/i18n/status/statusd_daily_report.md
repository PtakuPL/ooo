# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T09:23:08.091853Z`
- Window: `2026-02-16T09:23:08.091853Z` -> `2026-02-17T09:23:08.091853Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 49071 |
| guard_fail | 35536 |
| guard_fail_rate | 42.00% |
| no_progress_entries | 27 |
| no_progress_rate | 2.06% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 2044.6 |
| throughput_keys_per_h_active | 3734.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 103856 |
| suspicious_high_count | 103496 |
| suspicious_high_rate | 186.13% |
| suspicious_high_top_lang | ro:33922 |
| identical_to_en_count | 5799 |
| gt_guard_fails_count | 10993 |
| latest_audit_issues_found | 44 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 246 |
| latest_entries_total | 699 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | -27 |
| stagnation_detected | no |
| stagnation_span_h | 5.989 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 244 |
| avg_limit | 108.3 |
| avg_suspicious_high_pct | 286.63% |
| translated_total | 5930 |
| guard_fail_total | 1362 |
| guard_fail_rate_pct | 18.68% |
| gt_mode_true_samples | 244 |
| latest_timestamp | 2026-02-17T09:23:01.282309Z |

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
| active_minutes | 667.252 |
| cycle_delta | 1172 |
| best_quality_drop_pct | 66.17% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.26% | 0 | 1794 | 87.9% | 78.8% |
| ES | 84.26% | 0 | 2127 | 84.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3798 | 30.5% | 66.1% |
| RU | 50.04% | 0 | 1460 | 48.3% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 9791 | 1531 | 13.52% | 1.28% |
| ru | 9339 | 1834 | 16.41% | 1.73% |
| ro | 8514 | 2945 | 25.70% | 0.00% |
| pl | 6714 | 25092 | 78.89% | 5.00% |
| es | 5224 | 3052 | 36.88% | 5.10% |
| sv | 4794 | 605 | 11.21% | 0.00% |
| sr | 4695 | 477 | 9.22% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 8148 | 6590 | 44.71% | 0.00% |
| monsters.json | 6331 | 1990 | 23.92% | 0.00% |
| items.json | 6297 | 15690 | 71.36% | 0.00% |
| server.json | 6118 | 1656 | 21.30% | 2.01% |
| scripts.json | 3308 | 1987 | 37.53% | 0.00% |
| html.json | 2710 | 358 | 11.67% | 0.00% |
| spells.json | 2668 | 1739 | 39.46% | 0.00% |
| quests.json | 2215 | 700 | 24.01% | 2.94% |
| raids.json | 2046 | 219 | 9.67% | 5.66% |
| otclient_modules.json | 1952 | 578 | 22.85% | 0.00% |
| cpp.json | 1806 | 419 | 18.83% | 0.00% |
| questlog.json | 1611 | 1407 | 46.62% | 0.00% |

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
| current_total | 38167 |
| backlog_es | 262 |
| backlog_pl | 139 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 472 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 434 |
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
| backlog_sr | 275 |
| backlog_sv | 566 |
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
| delta_24h | -1884 (-4.7%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.1% over 6.0h |
