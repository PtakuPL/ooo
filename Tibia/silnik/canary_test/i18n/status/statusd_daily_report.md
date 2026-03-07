# I18N Daily Executive Report (24h)

- Generated: `2026-02-21T20:40:27.329375Z`
- Window: `2026-02-20T20:40:27.329375Z` -> `2026-02-21T20:40:27.329375Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 26885 |
| guard_fail | 58583 |
| guard_fail_rate | 68.54% |
| no_progress_entries | 42 |
| no_progress_rate | 2.74% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1120.2 |
| throughput_keys_per_h_active | 1190.0 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 106427 |
| suspicious_high_count | 105762 |
| suspicious_high_rate | 346.87% |
| suspicious_high_top_lang | es:29815 |
| identical_to_en_count | 3726 |
| gt_guard_fails_count | 22975 |
| latest_audit_issues_found | 40 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 300 |
| latest_entries_total | 755 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 43 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 8 |
| stagnation_detected | no |
| stagnation_span_h | 5.965 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 288 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 739.05% |
| translated_total | 3396 |
| guard_fail_total | 9300 |
| guard_fail_rate_pct | 73.25% |
| gt_mode_true_samples | 288 |
| latest_timestamp | 2026-02-21T19:09:08.339250Z |

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
| live_keys | 53770 |
| worker_registry_keys | 53770 |
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
| PL | 88.15% | 0 | 1841 | 88.9% | 78.8% |
| ES | 85.22% | 20 | 2225 | 85.7% | 79.5% |
| DE | 7.81% | 20 | 2902 | 8.2% | 3.0% |
| PT | 7.56% | 20 | 2816 | 7.9% | 2.9% |
| FR | 32.98% | 20 | 3952 | 30.4% | 66.1% |
| RU | 50.83% | 20 | 1648 | 49.1% | 72.6% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 7188 | 2636 | 26.83% | 1.07% |
| it | 4689 | 2688 | 36.44% | 1.13% |
| pl | 3798 | 30757 | 89.01% | 4.15% |
| es | 3295 | 15810 | 82.75% | 5.84% |
| ro | 2946 | 4362 | 59.69% | 1.53% |
| sr | 2492 | 1438 | 36.59% | 3.37% |
| sv | 1796 | 849 | 32.10% | 3.30% |
| tr | 30 | 0 | 0.00% | 0.00% |
| sk | 30 | 0 | 0.00% | 0.00% |
| no | 30 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 5570 | 12602 | 69.35% | 0.00% |
| monsters.json | 5073 | 1122 | 18.11% | 0.00% |
| items.json | 3616 | 33463 | 90.25% | 0.00% |
| server.json | 2104 | 3653 | 63.45% | 0.00% |
| scripts.json | 1668 | 1107 | 39.89% | 0.00% |
| questlog.json | 1559 | 991 | 38.86% | 0.00% |
| html.json | 1456 | 550 | 27.42% | 0.00% |
| raids.json | 1429 | 105 | 6.84% | 0.00% |
| otclient_modules.json | 904 | 771 | 46.03% | 0.00% |
| arena.json | 851 | 243 | 22.21% | 0.00% |
| cpp.json | 726 | 656 | 47.47% | 0.00% |
| books.json | 449 | 931 | 67.46% | 6.52% |

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
| total_keys_extracted | 53770 |
| total_keys_extracted_live | 53770 |
| total_keys_extracted_worker_registry | 53770 |
| keys_extracted_outside_worker_registry | 0 |
| npc_total | 1028 |
| npc_migrated | 700 |
| npc_needs_migration | 0 |

## Scope (Serwer vs Instalka)

- Serwer EN keys: **49915**
- Instalka EN keys: **3855**

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 45240 |
| backlog_es | 330 |
| backlog_pl | 164 |
| backlog_cs | 791 |
| backlog_de | 809 |
| backlog_fr | 728 |
| backlog_hu | 813 |
| backlog_it | 487 |
| backlog_nl | 841 |
| backlog_pt | 770 |
| backlog_ro | 517 |
| backlog_ru | 237 |
| backlog_sk | 813 |
| backlog_tr | 692 |
| backlog_ar | 1054 |
| backlog_az | 812 |
| backlog_bg | 842 |
| backlog_bn | 1054 |
| backlog_bs | 813 |
| backlog_da | 813 |
| backlog_el | 797 |
| backlog_et | 813 |
| backlog_fa | 1054 |
| backlog_fi | 813 |
| backlog_he | 1054 |
| backlog_hi | 1054 |
| backlog_hr | 813 |
| backlog_hy | 1055 |
| backlog_id | 1054 |
| backlog_ja | 1054 |
| backlog_ka | 1055 |
| backlog_kk | 813 |
| backlog_ko | 1055 |
| backlog_lt | 791 |
| backlog_lv | 813 |
| backlog_mk | 812 |
| backlog_ml | 1055 |
| backlog_ms | 1054 |
| backlog_no | 813 |
| backlog_sl | 813 |
| backlog_sq | 813 |
| backlog_sr | 246 |
| backlog_sv | 549 |
| backlog_sw | 1055 |
| backlog_ta | 1055 |
| backlog_te | 1055 |
| backlog_th | 1055 |
| backlog_tl | 1055 |
| backlog_uk | 813 |
| backlog_uz | 813 |
| backlog_vi | 1055 |
| backlog_zh | 1055 |
| backlog_zh_TW | 2606 |
| delta_24h | --7351 (--19.4%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.6% over 6.0h |
