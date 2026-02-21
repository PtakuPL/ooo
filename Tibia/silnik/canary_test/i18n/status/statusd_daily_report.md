# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T10:27:31.050289Z`
- Window: `2026-02-20T10:27:31.050289Z` -> `2026-02-21T10:27:31.050289Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 24621 |
| guard_fail | 52304 |
| guard_fail_rate | 67.99% |
| no_progress_entries | 38 |
| no_progress_rate | 3.20% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1025.9 |
| throughput_keys_per_h_active | 1360.5 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 131206 |
| suspicious_high_count | 130542 |
| suspicious_high_rate | 441.93% |
| suspicious_high_top_lang | ro:50605 |
| identical_to_en_count | 2651 |
| gt_guard_fails_count | 16101 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 239 |
| latest_entries_total | 701 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 0.914 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 233 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 372.34% |
| translated_total | 4659 |
| guard_fail_total | 6496 |
| guard_fail_rate_pct | 58.23% |
| gt_mode_true_samples | 233 |
| latest_timestamp | 2026-02-21T10:24:11.884697Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 999.05% | 2098 | low_backlog+suspicious_guard | 108 |

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
| ES | 85.30% | 0 | 2151 | 85.8% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.54% | 0 | 1541 | 48.8% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 5951 | 1346 | 18.45% | 1.42% |
| it | 4533 | 1591 | 25.98% | 2.87% |
| pl | 3439 | 30886 | 89.98% | 5.16% |
| es | 3334 | 14899 | 81.71% | 6.10% |
| ro | 3139 | 2641 | 45.69% | 2.60% |
| sr | 1938 | 454 | 18.98% | 0.00% |
| sv | 1606 | 444 | 21.66% | 0.00% |
| tr | 30 | 0 | 0.00% | 0.00% |
| sk | 30 | 0 | 0.00% | 0.00% |
| no | 30 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 7380 | 12105 | 62.12% | 0.00% |
| monsters.json | 5689 | 1110 | 16.33% | 0.00% |
| items.json | 4483 | 31224 | 87.45% | 0.00% |
| server.json | 1606 | 2278 | 58.65% | 1.08% |
| scripts.json | 1165 | 735 | 38.68% | 0.00% |
| questlog.json | 897 | 482 | 34.95% | 0.00% |
| raids.json | 806 | 140 | 14.80% | 9.38% |
| html.json | 677 | 238 | 26.01% | 0.00% |
| otclient_modules.json | 459 | 553 | 54.64% | 0.00% |
| cpp.json | 294 | 210 | 41.67% | 0.00% |
| spells.json | 253 | 1785 | 87.59% | 14.29% |
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
| current_total | 37856 |
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
| backlog_ru | 141 |
| backlog_sk | 663 |
| backlog_tr | 542 |
| backlog_ar | 904 |
| backlog_az | 662 |
| backlog_bg | 692 |
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
| delta_24h | -39 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | -0.0% over 0.5h |
