# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T15:06:19.779476Z`
- Window: `2026-02-13T15:06:19.779476Z` -> `2026-02-14T15:06:19.779476Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 48172 |
| guard_fail | 3252 |
| guard_fail_rate | 6.32% |
| no_progress_entries | 28 |
| no_progress_rate | 2.88% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 2007.2 |
| throughput_keys_per_h_active | 2473.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 13825 |
| suspicious_high_count | 10785 |
| suspicious_high_rate | 17.62% |
| suspicious_high_top_lang | es:3519 |
| identical_to_en_count | 17866 |
| gt_guard_fails_count | 10983 |
| latest_audit_issues_found | 14 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 108 |
| latest_entries_total | 706 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 5644 |
| stagnation_detected | no |
| stagnation_span_h | 5.147 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 19 |
| avg_limit | 231.37 |
| avg_suspicious_high_pct | 5.82% |
| translated_total | 1457 |
| guard_fail_total | 2232 |
| guard_fail_rate_pct | 60.50% |
| gt_mode_true_samples | 19 |
| latest_timestamp | 2026-02-14T15:04:20.759192Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 19.69% | 413 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 15.48% | 338 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 10.18% | 262 | low_backlog | 180 |
| es:npc.json | 9.43% | 265 | low_backlog | 180 |
| es:npc.json | 5.95% | 191 | low_backlog | 180 |

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
| active_minutes | 183.446 |
| cycle_delta | 49 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 42.36% | 0 | 1861 | 40.3% | 68.8% |
| ES | 73.32% | 0 | 2679 | 74.0% | 64.3% |
| DE | 7.83% | 0 | 2739 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.07% | 0 | 4167 | 30.5% | 66.1% |
| RU | 32.82% | 0 | 3747 | 29.9% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 10654 | 937 | 8.08% | 5.46% |
| pl | 8341 | 1759 | 17.42% | 3.42% |
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
| npc.json | 13551 | 943 | 6.51% | 0.00% |
| items.json | 13075 | 330 | 2.46% | 1.76% |
| monsters.json | 6496 | 190 | 2.84% | 0.00% |
| server.json | 3403 | 129 | 3.65% | 0.00% |
| html.json | 2776 | 228 | 7.59% | 0.00% |
| otclient_modules.json | 1714 | 527 | 23.52% | 0.00% |
| scripts.json | 1556 | 202 | 11.49% | 4.00% |
| questlog.json | 1440 | 0 | 0.00% | 14.29% |
| quests.json | 1296 | 119 | 8.41% | 0.00% |
| books.json | 644 | 52 | 7.47% | 6.67% |
| cpp.json | 503 | 258 | 33.90% | 0.00% |
| talkactions.json | 379 | 50 | 11.66% | 0.00% |

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
| current_total | 39526 |
| backlog_es | 265 |
| backlog_pl | 165 |
| backlog_cs | 641 |
| backlog_de | 660 |
| backlog_fr | 589 |
| backlog_hu | 663 |
| backlog_it | 630 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 689 |
| backlog_ru | 480 |
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
| stagnation_decrease | -731.8% over 5.1h |
