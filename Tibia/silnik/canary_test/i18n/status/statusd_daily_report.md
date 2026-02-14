# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T17:06:55.061236Z`
- Window: `2026-02-13T17:06:55.061236Z` -> `2026-02-14T17:06:55.061236Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 53100 |
| guard_fail | 8403 |
| guard_fail_rate | 13.66% |
| no_progress_entries | 42 |
| no_progress_rate | 3.84% |
| pending_skip_count | 15 |
| pending_skip_share | 2.70% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 2212.5 |
| throughput_keys_per_h_active | 2471.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 21156 |
| suspicious_high_count | 18102 |
| suspicious_high_rate | 26.71% |
| suspicious_high_top_lang | es:8991 |
| identical_to_en_count | 18468 |
| gt_guard_fails_count | 12577 |
| latest_audit_issues_found | 15 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 176 |
| latest_entries_total | 706 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 16 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 5652 |
| stagnation_detected | no |
| stagnation_span_h | 5.971 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 86 |
| avg_limit | 135.26 |
| avg_suspicious_high_pct | 179.49% |
| translated_total | 2903 |
| guard_fail_total | 2329 |
| guard_fail_rate_pct | 44.52% |
| gt_mode_true_samples | 86 |
| latest_timestamp | 2026-02-14T17:06:47.419521Z |

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
| detected | yes |
| severity | warning |
| reason | active_time_without_quality_drop |
| pending_langs | es,pl |
| active_minutes | 304.444 |
| cycle_delta | 192 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 45.88% | 0 | 2055 | 44.0% | 69.7% |
| ES | 75.18% | 0 | 2745 | 75.8% | 67.0% |
| DE | 8.07% | 0 | 2863 | 8.5% | 3.0% |
| PT | 7.81% | 0 | 2776 | 8.2% | 2.9% |
| FR | 33.31% | 0 | 4149 | 30.8% | 66.1% |
| RU | 33.67% | 0 | 2894 | 30.8% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 12659 | 1909 | 13.10% | 6.53% |
| pl | 11264 | 5938 | 34.52% | 4.78% |
| pt | 1447 | 0 | 0.00% | 5.00% |
| it | 1371 | 0 | 0.00% | 5.56% |
| de | 1370 | 0 | 0.00% | 0.00% |
| fr | 1297 | 0 | 0.00% | 0.00% |
| tr | 1206 | 24 | 1.95% | 0.00% |
| ru | 1137 | 0 | 0.00% | 0.00% |
| cs | 816 | 5 | 0.61% | 0.00% |
| el | 744 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 13815 | 999 | 6.74% | 1.05% |
| items.json | 13382 | 2873 | 17.67% | 2.29% |
| monsters.json | 7136 | 356 | 4.75% | 2.08% |
| server.json | 3758 | 558 | 12.93% | 1.89% |
| html.json | 3377 | 462 | 12.03% | 0.00% |
| scripts.json | 1973 | 725 | 26.87% | 3.45% |
| otclient_modules.json | 1857 | 659 | 26.19% | 0.00% |
| quests.json | 1730 | 428 | 19.83% | 0.00% |
| questlog.json | 1549 | 95 | 5.78% | 13.04% |
| books.json | 980 | 276 | 21.97% | 7.89% |
| spells.json | 869 | 82 | 8.62% | 0.00% |
| raids.json | 748 | 55 | 6.85% | 0.00% |

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
| current_total | 39284 |
| backlog_es | 298 |
| backlog_pl | 209 |
| backlog_cs | 641 |
| backlog_de | 660 |
| backlog_fr | 586 |
| backlog_hu | 663 |
| backlog_it | 630 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 689 |
| backlog_ru | 164 |
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
| backlog_zh_TW | 2456 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 95.0% over 5.8h |
