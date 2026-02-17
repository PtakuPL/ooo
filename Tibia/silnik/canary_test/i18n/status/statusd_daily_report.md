# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T10:23:10.098855Z`
- Window: `2026-02-16T10:23:10.098855Z` -> `2026-02-17T10:23:10.098855Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 51909 |
| guard_fail | 39622 |
| guard_fail_rate | 43.29% |
| no_progress_entries | 28 |
| no_progress_rate | 2.00% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 2162.9 |
| throughput_keys_per_h_active | 3669.5 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 111100 |
| suspicious_high_count | 110670 |
| suspicious_high_rate | 187.92% |
| suspicious_high_top_lang | ro:36241 |
| identical_to_en_count | 6172 |
| gt_guard_fails_count | 12530 |
| latest_audit_issues_found | 16 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 265 |
| latest_entries_total | 698 |
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
| samples_24h | 262 |
| avg_limit | 108.27 |
| avg_suspicious_high_pct | 285.90% |
| translated_total | 6380 |
| guard_fail_total | 1830 |
| guard_fail_rate_pct | 22.29% |
| gt_mode_true_samples | 262 |
| latest_timestamp | 2026-02-17T10:17:55.087376Z |

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
| active_minutes | 727.291 |
| cycle_delta | 1274 |
| best_quality_drop_pct | 66.17% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.34% | 0 | 1808 | 88.0% | 78.8% |
| ES | 84.25% | 0 | 2148 | 84.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3798 | 30.5% | 66.1% |
| RU | 50.14% | 0 | 1460 | 48.4% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 10417 | 1695 | 13.99% | 1.20% |
| ru | 9945 | 1953 | 16.41% | 1.61% |
| ro | 9000 | 3262 | 26.60% | 0.00% |
| pl | 7074 | 28184 | 79.94% | 4.67% |
| es | 5453 | 3442 | 38.70% | 5.24% |
| sv | 5075 | 609 | 10.71% | 0.00% |
| sr | 4945 | 477 | 8.80% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 8698 | 7929 | 47.69% | 0.00% |
| monsters.json | 6749 | 2088 | 23.63% | 0.00% |
| items.json | 6729 | 17348 | 72.05% | 0.00% |
| server.json | 6370 | 1723 | 21.29% | 1.94% |
| scripts.json | 3472 | 2111 | 37.81% | 0.00% |
| html.json | 2917 | 406 | 12.22% | 0.00% |
| spells.json | 2753 | 2004 | 42.13% | 0.00% |
| quests.json | 2224 | 734 | 24.81% | 4.17% |
| raids.json | 2118 | 220 | 9.41% | 5.45% |
| otclient_modules.json | 2098 | 654 | 23.76% | 0.00% |
| cpp.json | 1937 | 468 | 19.46% | 0.00% |
| questlog.json | 1710 | 1538 | 47.35% | 0.00% |

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
| current_total | 38031 |
| backlog_es | 277 |
| backlog_pl | 139 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 464 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 433 |
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
| backlog_sr | 138 |
| backlog_sv | 561 |
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
| delta_24h | -2020 (-5.0%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.2% over 6.0h |
