# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T06:22:19.413066Z`
- Window: `2026-02-16T06:22:19.413066Z` -> `2026-02-17T06:22:19.413066Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 41854 |
| guard_fail | 29000 |
| guard_fail_rate | 40.93% |
| no_progress_entries | 24 |
| no_progress_rate | 2.23% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1743.9 |
| throughput_keys_per_h_active | 4133.4 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 90500 |
| suspicious_high_count | 90197 |
| suspicious_high_rate | 191.71% |
| suspicious_high_top_lang | ro:30882 |
| identical_to_en_count | 4828 |
| gt_guard_fails_count | 7598 |
| latest_audit_issues_found | 28 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 199 |
| latest_entries_total | 707 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 5.977 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 198 |
| avg_limit | 108.36 |
| avg_suspicious_high_pct | 294.31% |
| translated_total | 4592 |
| guard_fail_total | 161 |
| guard_fail_rate_pct | 3.39% |
| gt_mode_true_samples | 198 |
| latest_timestamp | 2026-02-17T06:21:55.589564Z |

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
| active_minutes | 486.451 |
| cycle_delta | 916 |
| best_quality_drop_pct | 61.30% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 47.96% | 0 | 1891 | 46.3% | 69.5% |
| ES | 74.97% | 0 | 2630 | 75.7% | 66.2% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.06% | 0 | 4023 | 30.5% | 66.1% |
| RU | 38.69% | 0 | 2564 | 36.1% | 72.3% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 8087 | 883 | 9.84% | 1.61% |
| ru | 7687 | 1466 | 16.02% | 1.62% |
| ro | 7157 | 2183 | 23.37% | 0.00% |
| pl | 5951 | 21497 | 78.32% | 5.92% |
| es | 4694 | 2109 | 31.00% | 4.94% |
| sv | 4192 | 427 | 9.24% | 0.00% |
| sr | 4086 | 435 | 9.62% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 7182 | 5483 | 43.29% | 0.00% |
| monsters.json | 5574 | 1796 | 24.37% | 0.00% |
| items.json | 5512 | 13176 | 70.51% | 0.00% |
| server.json | 5467 | 1309 | 19.32% | 2.29% |
| scripts.json | 2808 | 1663 | 37.20% | 0.00% |
| spells.json | 2417 | 1233 | 33.78% | 0.00% |
| html.json | 2111 | 237 | 10.09% | 0.00% |
| quests.json | 2075 | 567 | 21.46% | 0.00% |
| raids.json | 1637 | 216 | 11.66% | 6.98% |
| otclient_modules.json | 1512 | 401 | 20.96% | 0.00% |
| cpp.json | 1444 | 291 | 16.77% | 0.00% |
| books.json | 1331 | 819 | 38.09% | 0.00% |

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
| current_total | 38405 |
| backlog_es | 300 |
| backlog_pl | 174 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 586 |
| backlog_hu | 663 |
| backlog_it | 429 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 437 |
| backlog_ru | 107 |
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
| backlog_sv | 499 |
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
| delta_24h | -1646 (-4.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.6% over 6.0h |
