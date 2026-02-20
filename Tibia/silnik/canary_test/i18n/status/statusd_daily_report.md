# I18N Daily Executive Report (24h)

- Generated: `2026-02-20T20:13:33.147776Z`
- Window: `2026-02-19T20:13:33.147776Z` -> `2026-02-20T20:13:33.147776Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 13646 |
| guard_fail | 26946 |
| guard_fail_rate | 66.38% |
| no_progress_entries | 56 |
| no_progress_rate | 9.48% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 568.6 |
| throughput_keys_per_h_active | 568.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 70931 |
| suspicious_high_count | 70582 |
| suspicious_high_rate | 431.56% |
| suspicious_high_top_lang | ro:29581 |
| identical_to_en_count | 1427 |
| gt_guard_fails_count | 8004 |
| latest_audit_issues_found | 45 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 118 |
| latest_entries_total | 700 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 3.931 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 111 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 300.32% |
| translated_total | 2454 |
| guard_fail_total | 2952 |
| guard_fail_rate_pct | 54.61% |
| gt_mode_true_samples | 111 |
| latest_timestamp | 2026-02-20T20:12:02.319451Z |

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
| active_minutes | 5637.678 |
| cycle_delta | 5413 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.83% | 0 | 1830 | 88.5% | 78.8% |
| ES | 84.81% | 0 | 2160 | 85.2% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.37% | 0 | 1457 | 48.6% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 3083 | 382 | 11.02% | 7.48% |
| it | 2604 | 823 | 24.02% | 11.01% |
| es | 2019 | 7528 | 78.85% | 13.16% |
| ro | 2016 | 1181 | 36.94% | 8.33% |
| pl | 1974 | 16817 | 89.49% | 10.28% |
| sr | 1071 | 9 | 0.83% | 3.45% |
| sv | 879 | 206 | 18.99% | 3.45% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 4046 | 6415 | 61.32% | 3.05% |
| monsters.json | 3054 | 670 | 17.99% | 1.96% |
| items.json | 2385 | 15812 | 86.89% | 6.52% |
| server.json | 1208 | 812 | 40.20% | 4.08% |
| scripts.json | 569 | 397 | 41.10% | 0.00% |
| raids.json | 475 | 143 | 23.14% | 11.11% |
| questlog.json | 460 | 258 | 35.93% | 10.53% |
| html.json | 376 | 76 | 16.81% | 21.43% |
| otclient_modules.json | 244 | 200 | 45.05% | 0.00% |
| spells.json | 198 | 1300 | 86.78% | 15.38% |
| achievements.json | 164 | 66 | 28.70% | 25.00% |
| books.json | 100 | 320 | 76.19% | 27.27% |

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
| current_total | 37892 |
| backlog_es | 277 |
| backlog_pl | 148 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 440 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 424 |
| backlog_ru | 59 |
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
| backlog_sr | 50 |
| backlog_sv | 535 |
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
| delta_24h | -21 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.0% over 3.5h |
