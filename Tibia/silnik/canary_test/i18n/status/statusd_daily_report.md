# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T01:15:57.658992Z`
- Window: `2026-02-20T01:15:57.658992Z` -> `2026-02-21T01:15:57.658992Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 21220 |
| guard_fail | 44819 |
| guard_fail_rate | 67.87% |
| no_progress_entries | 32 |
| no_progress_rate | 3.21% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 884.2 |
| throughput_keys_per_h_active | 2358.9 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 119985 |
| suspicious_high_count | 119401 |
| suspicious_high_rate | 462.22% |
| suspicious_high_top_lang | ro:49915 |
| identical_to_en_count | 2139 |
| gt_guard_fails_count | 12914 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 196 |
| latest_entries_total | 700 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 5.981 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 192 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 294.90% |
| translated_total | 4372 |
| guard_fail_total | 5020 |
| guard_fail_rate_pct | 53.45% |
| gt_mode_true_samples | 192 |
| latest_timestamp | 2026-02-21T01:14:46.973708Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 314.00% | 1884 | low_backlog+suspicious_guard | 108 |
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
| active_minutes | 5940.063 |
| cycle_delta | 6022 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.87% | 0 | 1831 | 88.6% | 78.8% |
| ES | 85.23% | 0 | 2152 | 85.7% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.42% | 0 | 1538 | 48.7% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 5152 | 938 | 15.40% | 1.64% |
| it | 4050 | 1296 | 24.24% | 3.30% |
| es | 3067 | 12898 | 80.79% | 5.43% |
| pl | 3005 | 27041 | 90.00% | 4.42% |
| ro | 2914 | 2025 | 41.00% | 3.07% |
| sr | 1653 | 282 | 14.57% | 0.00% |
| sv | 1379 | 339 | 19.73% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6301 | 10348 | 62.15% | 0.00% |
| monsters.json | 5015 | 942 | 15.81% | 0.00% |
| items.json | 4028 | 27090 | 87.06% | 0.00% |
| server.json | 1431 | 1849 | 56.37% | 1.25% |
| scripts.json | 987 | 613 | 38.31% | 0.00% |
| questlog.json | 718 | 361 | 33.46% | 0.00% |
| raids.json | 702 | 131 | 15.73% | 10.71% |
| html.json | 507 | 153 | 23.18% | 0.00% |
| otclient_modules.json | 349 | 427 | 55.03% | 0.00% |
| spells.json | 213 | 1615 | 88.35% | 12.50% |
| cpp.json | 197 | 141 | 41.72% | 0.00% |
| quests.json | 123 | 244 | 66.49% | 2.56% |

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
| current_total | 37851 |
| backlog_es | 269 |
| backlog_pl | 149 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 420 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 421 |
| backlog_ru | 138 |
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
| delta_24h | -44 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.2% over 6.0h |
