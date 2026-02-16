# I18N Daily Executive Report (24h)

- Generated: `2026-02-16T23:16:37.659448Z`
- Window: `2026-02-15T23:16:37.659448Z` -> `2026-02-16T23:16:37.659448Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 15480 |
| guard_fail | 8361 |
| guard_fail_rate | 35.07% |
| no_progress_entries | 5 |
| no_progress_rate | 1.45% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 645.0 |
| throughput_keys_per_h_active | 5136.4 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 38990 |
| suspicious_high_count | 38880 |
| suspicious_high_rate | 222.30% |
| suspicious_high_top_lang | ro:15007 |
| identical_to_en_count | 1572 |
| gt_guard_fails_count | 1269 |
| latest_audit_issues_found | 7 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 61 |
| latest_entries_total | 706 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 3.024 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 60 |
| avg_limit | 109.2 |
| avg_suspicious_high_pct | 223.30% |
| translated_total | 1408 |
| guard_fail_total | 32 |
| guard_fail_rate_pct | 2.22% |
| gt_mode_true_samples | 60 |
| latest_timestamp | 2026-02-16T23:13:47.721150Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 319.06% | 2444 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 317.50% | 2467 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 315.96% | 2474 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 314.89% | 2475 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 314.89% | 2475 | low_backlog+suspicious_guard | 108 |

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
| active_minutes | 60.757 |
| cycle_delta | 92 |
| best_quality_drop_pct | 5.81% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 43.84% | 0 | 1862 | 41.9% | 68.7% |
| ES | 74.00% | 0 | 2607 | 74.7% | 64.6% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.05% | 0 | 4031 | 30.5% | 66.1% |
| RU | 35.31% | 0 | 2767 | 32.6% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 2677 | 35 | 1.29% | 1.79% |
| ru | 2429 | 390 | 13.83% | 1.79% |
| ro | 2244 | 409 | 15.42% | 0.00% |
| sv | 2162 | 38 | 1.73% | 0.00% |
| sr | 2125 | 75 | 3.41% | 0.00% |
| es | 1932 | 361 | 15.74% | 0.00% |
| pl | 1911 | 7053 | 78.68% | 6.82% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 3577 | 1676 | 31.91% | 0.00% |
| server.json | 3172 | 603 | 15.97% | 4.23% |
| items.json | 3107 | 4638 | 59.88% | 0.00% |
| monsters.json | 3059 | 845 | 21.64% | 0.00% |
| scripts.json | 696 | 117 | 14.39% | 0.00% |
| spells.json | 447 | 53 | 10.60% | 0.00% |
| quests.json | 346 | 75 | 17.81% | 0.00% |
| html.json | 346 | 25 | 6.74% | 0.00% |
| questlog.json | 237 | 107 | 31.10% | 0.00% |
| otclient_modules.json | 217 | 27 | 11.07% | 0.00% |
| raids.json | 127 | 96 | 43.05% | 20.00% |
| books.json | 103 | 97 | 48.50% | 0.00% |

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
| current_total | 38771 |
| backlog_es | 296 |
| backlog_pl | 169 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 589 |
| backlog_hu | 663 |
| backlog_it | 511 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 532 |
| backlog_ru | 254 |
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
| backlog_sr | 494 |
| backlog_sv | 545 |
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
| delta_24h | -1280 (-3.2%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 3.1% over 2.5h |
