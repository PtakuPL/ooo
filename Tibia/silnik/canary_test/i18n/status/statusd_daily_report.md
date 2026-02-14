# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T11:17:52.955642Z`
- Window: `2026-02-13T11:17:52.955642Z` -> `2026-02-14T11:17:52.955642Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 45751 |
| guard_fail | 2744 |
| guard_fail_rate | 5.66% |
| no_progress_entries | 26 |
| no_progress_rate | 2.83% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1906.3 |
| throughput_keys_per_h_active | 2951.8 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 12033 |
| suspicious_high_count | 9010 |
| suspicious_high_rate | 15.71% |
| suspicious_high_top_lang | es:2625 |
| identical_to_en_count | 17487 |
| gt_guard_fails_count | 10448 |
| latest_audit_issues_found | 2 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 85 |
| latest_entries_total | 1242 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 2306 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 3362 |
| stagnation_detected | no |
| stagnation_span_h | 5.904 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 13 |
| avg_limit | 260.0 |
| avg_suspicious_high_pct | 3.38% |
| translated_total | 1304 |
| guard_fail_total | 2065 |
| guard_fail_rate_pct | 61.29% |
| gt_mode_true_samples | 13 |
| latest_timestamp | 2026-02-14T11:11:27.536393Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 3.85% | 124 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.80% | 121 | base+domain_cap | 260 |
| es:npc.json | 3.78% | 121 | base+domain_cap | 260 |
| es:npc.json | 3.73% | 118 | base+domain_cap | 260 |
| es:npc.json | 3.62% | 114 | base+domain_cap | 260 |

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
| pending_langs | es,pl |
| active_minutes | 77.058 |
| cycle_delta | 13 |
| best_quality_drop_pct | 0.90% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 75.45% | 2083 | 2841 | 75.8% | 71.3% |
| ES | 87.75% | 232 | 11255 | 89.3% | 67.8% |
| DE | 17.57% | 174 | 21750 | 18.7% | 3.1% |
| PT | 19.67% | 2155 | 29574 | 20.7% | 6.0% |
| FR | 55.45% | 174 | 29762 | 53.3% | 83.7% |
| RU | 56.07% | 174 | 37635 | 53.5% | 89.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 9955 | 840 | 7.78% | 5.69% |
| pl | 7482 | 1440 | 16.14% | 3.66% |
| pt | 1447 | 0 | 0.00% | 0.00% |
| de | 1360 | 0 | 0.00% | 0.00% |
| fr | 1287 | 0 | 0.00% | 0.00% |
| it | 1207 | 0 | 0.00% | 0.00% |
| tr | 1206 | 24 | 1.95% | 0.00% |
| ru | 1127 | 0 | 0.00% | 0.00% |
| no | 560 | 0 | 0.00% | 0.00% |
| kk | 560 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| items.json | 12915 | 235 | 1.79% | 1.79% |
| npc.json | 12672 | 791 | 5.88% | 0.00% |
| monsters.json | 6269 | 176 | 2.73% | 0.00% |
| server.json | 3040 | 0 | 0.00% | 0.00% |
| html.json | 2709 | 208 | 7.13% | 0.00% |
| otclient_modules.json | 1714 | 527 | 23.52% | 0.00% |
| scripts.json | 1495 | 191 | 11.33% | 0.00% |
| questlog.json | 1440 | 0 | 0.00% | 14.29% |
| quests.json | 1080 | 67 | 5.84% | 0.00% |
| books.json | 644 | 52 | 7.47% | 6.67% |
| cpp.json | 424 | 244 | 36.53% | 0.00% |
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
| files_total | 2299 |
| files_completed | 2297 |
| files_migrated | 1897 |
| scanned_files_live | 2299 |
| scanned_files_history | 6443 |
| scanned_files_history_minus_live | 4144 |
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
| current_total | 1084776 |
| backlog_es | 5217 |
| backlog_pl | 481 |
| backlog_cs | 21217 |
| backlog_de | 14503 |
| backlog_fr | 15745 |
| backlog_hu | 21274 |
| backlog_it | 20993 |
| backlog_nl | 16594 |
| backlog_pt | 21004 |
| backlog_ru | 23110 |
| backlog_sk | 21388 |
| backlog_tr | 20873 |
| backlog_ar | 22421 |
| backlog_az | 21079 |
| backlog_bg | 22982 |
| backlog_bn | 22418 |
| backlog_bs | 21426 |
| backlog_da | 21316 |
| backlog_el | 21287 |
| backlog_et | 21212 |
| backlog_fa | 22543 |
| backlog_fi | 21272 |
| backlog_he | 22891 |
| backlog_hi | 22816 |
| backlog_hr | 21226 |
| backlog_hy | 22931 |
| backlog_id | 22812 |
| backlog_ja | 22937 |
| backlog_ka | 22915 |
| backlog_kk | 21296 |
| backlog_ko | 22896 |
| backlog_lt | 21289 |
| backlog_lv | 21297 |
| backlog_mk | 21108 |
| backlog_ml | 22901 |
| backlog_ms | 22884 |
| backlog_no | 21396 |
| backlog_ro | 16635 |
| backlog_sl | 21468 |
| backlog_sq | 21357 |
| backlog_sr | 21478 |
| backlog_sv | 21492 |
| backlog_sw | 23044 |
| backlog_ta | 23102 |
| backlog_te | 23068 |
| backlog_th | 23078 |
| backlog_tl | 23199 |
| backlog_uk | 21548 |
| backlog_uz | 21475 |
| backlog_vi | 23232 |
| backlog_zh | 23398 |
| backlog_zh_TW | 23252 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | -13242.9% over 5.9h |
