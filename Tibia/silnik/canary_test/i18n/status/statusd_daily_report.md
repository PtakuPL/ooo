# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T09:27:25.526435Z`
- Window: `2026-02-20T09:27:25.526435Z` -> `2026-02-21T09:27:25.526435Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 23122 |
| guard_fail | 48285 |
| guard_fail_rate | 67.62% |
| no_progress_entries | 37 |
| no_progress_rate | 3.31% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 963.4 |
| throughput_keys_per_h_active | 1345.1 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 125422 |
| suspicious_high_count | 124797 |
| suspicious_high_rate | 446.74% |
| suspicious_high_top_lang | ro:50287 |
| identical_to_en_count | 2492 |
| gt_guard_fails_count | 14991 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 224 |
| latest_entries_total | 701 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 0.0 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 218 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 329.31% |
| translated_total | 4554 |
| guard_fail_total | 5956 |
| guard_fail_rate_pct | 56.67% |
| gt_mode_true_samples | 218 |
| latest_timestamp | 2026-02-21T02:50:52.070608Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 972.22% | 2100 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 901.29% | 2091 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 839.52% | 2082 | low_backlog+suspicious_guard | 108 |

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
| enabled | no |
| active | no |
| detected | no |
| severity | ok |
| reason | priority_gate_disabled |
| pending_langs |  |
| active_minutes | 0.0 |
| cycle_delta | 0 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.87% | 0 | 1831 | 88.6% | 78.8% |
| ES | 85.25% | 0 | 2152 | 85.7% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.62% | 0 | 1497 | 48.9% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 5711 | 1154 | 16.81% | 1.47% |
| it | 4402 | 1512 | 25.57% | 2.97% |
| pl | 3263 | 28611 | 89.76% | 4.93% |
| es | 3215 | 13677 | 80.97% | 6.44% |
| ro | 3077 | 2463 | 44.46% | 2.72% |
| sr | 1878 | 424 | 18.42% | 0.00% |
| sv | 1516 | 444 | 22.65% | 0.00% |
| nl | 30 | 0 | 0.00% | 0.00% |
| cs | 30 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6498 | 11123 | 63.12% | 0.00% |
| monsters.json | 5361 | 1028 | 16.09% | 0.00% |
| items.json | 4287 | 28496 | 86.92% | 0.00% |
| server.json | 1567 | 2146 | 57.80% | 1.12% |
| scripts.json | 1130 | 710 | 38.59% | 0.00% |
| questlog.json | 897 | 482 | 34.95% | 0.00% |
| raids.json | 790 | 133 | 14.41% | 9.68% |
| html.json | 677 | 238 | 26.01% | 0.00% |
| otclient_modules.json | 459 | 553 | 54.64% | 0.00% |
| cpp.json | 294 | 210 | 41.67% | 0.00% |
| spells.json | 251 | 1727 | 87.31% | 13.11% |
| books.json | 181 | 609 | 77.09% | 12.00% |

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
| current_total | 37811 |
| backlog_es | 269 |
| backlog_pl | 149 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 421 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 421 |
| backlog_ru | 97 |
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
| delta_24h | -84 (-0.2%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.2% over 6.0h |
