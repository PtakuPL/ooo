# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T02:16:11.307441Z`
- Window: `2026-02-20T02:16:11.307441Z` -> `2026-02-21T02:16:11.307441Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 22472 |
| guard_fail | 47859 |
| guard_fail_rate | 68.05% |
| no_progress_entries | 37 |
| no_progress_rate | 3.43% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 936.3 |
| throughput_keys_per_h_active | 2246.4 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 123298 |
| suspicious_high_count | 122674 |
| suspicious_high_rate | 451.01% |
| suspicious_high_top_lang | ro:50131 |
| identical_to_en_count | 2345 |
| gt_guard_fails_count | 14295 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 213 |
| latest_entries_total | 701 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 5.978 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 209 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 307.20% |
| translated_total | 4491 |
| guard_fail_total | 5632 |
| guard_fail_rate_pct | 55.64% |
| gt_mode_true_samples | 209 |
| latest_timestamp | 2026-02-21T02:11:02.333516Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 621.04% | 2037 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 589.53% | 2028 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 560.83% | 2019 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 534.57% | 2010 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 510.46% | 2001 | low_backlog+suspicious_guard | 108 |

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
| active_minutes | 6000.296 |
| cycle_delta | 6115 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.87% | 0 | 1831 | 88.6% | 78.8% |
| ES | 85.25% | 0 | 2152 | 85.7% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.61% | 0 | 1469 | 48.9% | 72.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 5490 | 1090 | 16.57% | 1.53% |
| it | 4267 | 1437 | 25.19% | 3.08% |
| pl | 3216 | 28569 | 89.88% | 5.05% |
| es | 3202 | 13623 | 80.97% | 6.57% |
| ro | 3008 | 2288 | 43.20% | 2.84% |
| sr | 1821 | 421 | 18.78% | 0.00% |
| sv | 1468 | 431 | 22.70% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6441 | 11016 | 63.10% | 0.00% |
| monsters.json | 5184 | 989 | 16.02% | 0.00% |
| items.json | 4167 | 28462 | 87.23% | 0.00% |
| server.json | 1565 | 2118 | 57.51% | 1.14% |
| scripts.json | 1077 | 673 | 38.46% | 0.00% |
| questlog.json | 848 | 441 | 34.21% | 0.00% |
| raids.json | 760 | 133 | 14.89% | 10.00% |
| html.json | 622 | 202 | 24.51% | 0.00% |
| otclient_modules.json | 423 | 508 | 54.56% | 0.00% |
| cpp.json | 262 | 189 | 41.91% | 0.00% |
| spells.json | 251 | 1727 | 87.31% | 13.11% |
| books.json | 152 | 578 | 79.18% | 13.04% |

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
| current_total | 37854 |
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
| backlog_ru | 140 |
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
| delta_24h | -41 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.3% over 6.0h |
