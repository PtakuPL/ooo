# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T02:18:57.585942Z`
- Window: `2026-02-16T02:18:57.585942Z` -> `2026-02-17T02:18:57.585942Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 27564 |
| guard_fail | 17002 |
| guard_fail_rate | 38.15% |
| no_progress_entries | 16 |
| no_progress_rate | 2.41% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1148.5 |
| throughput_keys_per_h_active | 4537.0 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 61381 |
| suspicious_high_count | 61196 |
| suspicious_high_rate | 198.13% |
| suspicious_high_top_lang | ro:22135 |
| identical_to_en_count | 3027 |
| gt_guard_fails_count | 3411 |
| latest_audit_issues_found | 25 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 118 |
| latest_entries_total | 711 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 5.945 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 117 |
| avg_limit | 108.62 |
| avg_suspicious_high_pct | 271.91% |
| translated_total | 2720 |
| guard_fail_total | 89 |
| guard_fail_rate_pct | 3.17% |
| gt_mode_true_samples | 117 |
| latest_timestamp | 2026-02-17T02:17:12.677948Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 328.09% | 2441 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.82% | 2439 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.69% | 2438 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.55% | 2437 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 327.42% | 2436 | low_backlog+suspicious_guard | 108 |

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
| active_minutes | 243.087 |
| cycle_delta | 453 |
| best_quality_drop_pct | 31.14% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 45.79% | 0 | 1914 | 44.0% | 69.4% |
| ES | 74.56% | 0 | 2629 | 75.3% | 65.4% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.05% | 0 | 4027 | 30.5% | 66.1% |
| RU | 37.13% | 0 | 2592 | 34.5% | 71.1% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 5062 | 266 | 4.99% | 2.70% |
| ru | 4695 | 805 | 14.64% | 2.73% |
| ro | 4404 | 1017 | 18.76% | 0.00% |
| pl | 3897 | 13469 | 77.56% | 6.06% |
| es | 3240 | 1026 | 24.05% | 4.04% |
| sv | 3173 | 196 | 5.82% | 0.00% |
| sr | 3093 | 223 | 6.72% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 5217 | 3159 | 37.71% | 0.00% |
| server.json | 4383 | 842 | 16.11% | 3.00% |
| monsters.json | 4134 | 1314 | 24.12% | 0.00% |
| items.json | 4117 | 8873 | 68.31% | 0.00% |
| scripts.json | 1671 | 601 | 26.45% | 0.00% |
| spells.json | 1598 | 452 | 22.05% | 0.00% |
| quests.json | 1105 | 221 | 16.67% | 0.00% |
| html.json | 1073 | 83 | 7.18% | 0.00% |
| raids.json | 834 | 204 | 19.65% | 12.50% |
| otclient_modules.json | 720 | 81 | 10.11% | 0.00% |
| books.json | 720 | 380 | 34.55% | 0.00% |
| questlog.json | 696 | 408 | 36.96% | 0.00% |

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
| current_total | 38601 |
| backlog_es | 300 |
| backlog_pl | 214 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 588 |
| backlog_hu | 663 |
| backlog_it | 478 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 502 |
| backlog_ru | 113 |
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
| delta_24h | -1450 (-3.6%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 3.6% over 5.6h |
