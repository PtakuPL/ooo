# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T00:15:37.345891Z`
- Window: `2026-02-20T00:15:37.345891Z` -> `2026-02-21T00:15:37.345891Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 19682 |
| guard_fail | 40337 |
| guard_fail_rate | 67.21% |
| no_progress_entries | 29 |
| no_progress_rate | 3.20% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 820.1 |
| throughput_keys_per_h_active | 2461.6 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 113791 |
| suspicious_high_count | 113273 |
| suspicious_high_rate | 471.40% |
| suspicious_high_top_lang | ro:48347 |
| identical_to_en_count | 1960 |
| gt_guard_fails_count | 11614 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 179 |
| latest_entries_total | 700 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 5.973 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 177 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 296.55% |
| translated_total | 4133 |
| guard_fail_total | 4614 |
| guard_fail_rate_pct | 52.75% |
| gt_mode_true_samples | 177 |
| latest_timestamp | 2026-02-21T00:14:06.577928Z |

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
| active_minutes | 5879.742 |
| cycle_delta | 5919 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.85% | 0 | 1831 | 88.5% | 78.8% |
| ES | 85.15% | 0 | 2151 | 85.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.51% | 0 | 1469 | 48.8% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 4746 | 690 | 12.69% | 1.80% |
| it | 3757 | 1157 | 23.54% | 3.64% |
| es | 2883 | 11753 | 80.30% | 5.88% |
| ro | 2778 | 1729 | 38.36% | 2.72% |
| pl | 2726 | 24508 | 89.99% | 3.70% |
| sr | 1528 | 197 | 11.42% | 0.00% |
| sv | 1264 | 303 | 19.34% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6004 | 9427 | 61.09% | 0.00% |
| monsters.json | 4716 | 871 | 15.59% | 0.00% |
| items.json | 3825 | 24465 | 86.48% | 0.00% |
| server.json | 1264 | 1559 | 55.22% | 1.43% |
| scripts.json | 851 | 539 | 38.78% | 0.00% |
| questlog.json | 659 | 330 | 33.37% | 0.00% |
| raids.json | 616 | 127 | 17.09% | 12.00% |
| html.json | 477 | 146 | 23.43% | 0.00% |
| otclient_modules.json | 306 | 367 | 54.53% | 0.00% |
| spells.json | 188 | 1460 | 88.59% | 12.00% |
| cpp.json | 160 | 98 | 37.98% | 0.00% |
| books.json | 114 | 406 | 78.08% | 6.25% |

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
| current_total | 37786 |
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
| backlog_ru | 72 |
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
| delta_24h | -109 (-0.3%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.2% over 6.0h |
