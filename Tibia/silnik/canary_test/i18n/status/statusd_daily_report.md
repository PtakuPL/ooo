# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T11:23:11.404217Z`
- Window: `2026-02-16T11:23:11.404217Z` -> `2026-02-17T11:23:11.404217Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 53859 |
| guard_fail | 40545 |
| guard_fail_rate | 42.95% |
| no_progress_entries | 28 |
| no_progress_rate | 1.91% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 2244.1 |
| throughput_keys_per_h_active | 3558.0 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 115363 |
| suspicious_high_count | 114918 |
| suspicious_high_rate | 187.72% |
| suspicious_high_top_lang | ro:37618 |
| identical_to_en_count | 6413 |
| gt_guard_fails_count | 13750 |
| latest_audit_issues_found | 16 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 280 |
| latest_entries_total | 698 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | -27 |
| stagnation_detected | no |
| stagnation_span_h | 5.977 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 277 |
| avg_limit | 108.26 |
| avg_suspicious_high_pct | 285.36% |
| translated_total | 6755 |
| guard_fail_total | 2220 |
| guard_fail_rate_pct | 24.73% |
| gt_mode_true_samples | 277 |
| latest_timestamp | 2026-02-17T11:22:57.253285Z |

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
| active_minutes | 787.306 |
| cycle_delta | 1346 |
| best_quality_drop_pct | 66.17% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.35% | 0 | 1810 | 88.0% | 78.8% |
| ES | 84.26% | 0 | 2149 | 84.6% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3798 | 30.5% | 66.1% |
| RU | 50.21% | 0 | 1460 | 48.5% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 10869 | 1859 | 14.61% | 1.14% |
| ru | 10435 | 2060 | 16.49% | 1.53% |
| ro | 9350 | 3527 | 27.39% | 0.00% |
| pl | 7175 | 28296 | 79.77% | 4.52% |
| es | 5616 | 3711 | 39.79% | 5.00% |
| sv | 5270 | 614 | 10.44% | 0.00% |
| sr | 5144 | 478 | 8.50% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 8948 | 7932 | 46.99% | 0.00% |
| items.json | 6974 | 17358 | 71.34% | 0.00% |
| monsters.json | 6955 | 2132 | 23.46% | 0.00% |
| server.json | 6622 | 1785 | 21.23% | 1.86% |
| scripts.json | 3634 | 2220 | 37.92% | 0.00% |
| html.json | 3123 | 455 | 12.72% | 0.00% |
| spells.json | 2799 | 2201 | 44.02% | 0.00% |
| otclient_modules.json | 2244 | 730 | 24.55% | 0.00% |
| quests.json | 2233 | 753 | 25.22% | 4.00% |
| raids.json | 2190 | 221 | 9.17% | 5.26% |
| cpp.json | 2066 | 519 | 20.08% | 0.00% |
| questlog.json | 1809 | 1669 | 47.99% | 0.00% |

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
| current_total | 37977 |
| backlog_es | 277 |
| backlog_pl | 139 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 462 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 430 |
| backlog_ru | 60 |
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
| backlog_sr | 95 |
| backlog_sv | 555 |
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
| delta_24h | -2074 (-5.2%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 1.3% over 6.0h |
