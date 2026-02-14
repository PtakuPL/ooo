# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T12:18:36.399289Z`
- Window: `2026-02-13T12:18:36.399289Z` -> `2026-02-14T12:18:36.399289Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 46414 |
| guard_fail | 2935 |
| guard_fail_rate | 5.95% |
| no_progress_entries | 26 |
| no_progress_rate | 2.78% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1933.9 |
| throughput_keys_per_h_active | 2784.3 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 12724 |
| suspicious_high_count | 9692 |
| suspicious_high_rate | 16.39% |
| suspicious_high_top_lang | es:2968 |
| identical_to_en_count | 17736 |
| gt_guard_fails_count | 10881 |
| latest_audit_issues_found | 32 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 95 |
| latest_entries_total | 745 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 14 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 5654 |
| stagnation_detected | no |
| stagnation_span_h | 5.885 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 15 |
| avg_limit | 254.67 |
| avg_suspicious_high_pct | 3.72% |
| translated_total | 1409 |
| guard_fail_total | 2232 |
| guard_fail_rate_pct | 61.30% |
| gt_mode_true_samples | 15 |
| latest_timestamp | 2026-02-14T12:00:38.538902Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 5.95% | 191 | low_backlog | 180 |
| es:npc.json | 5.89% | 188 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.85% | 124 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.80% | 121 | base+domain_cap | 260 |
| es:npc.json | 3.78% | 121 | base+domain_cap | 260 |

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
| active_minutes | 16.23 |
| cycle_delta | 6 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 45.32% | 0 | 1747 | 43.5% | 68.4% |
| ES | 76.76% | 0 | 2807 | 77.7% | 64.7% |
| DE | 7.96% | 0 | 2738 | 8.3% | 3.0% |
| PT | 7.62% | 0 | 2652 | 8.0% | 3.0% |
| FR | 34.70% | 0 | 4306 | 32.0% | 70.1% |
| RU | 33.87% | 0 | 4056 | 30.7% | 74.9% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 10145 | 922 | 8.33% | 5.61% |
| pl | 7796 | 1505 | 16.18% | 3.57% |
| pt | 1447 | 0 | 0.00% | 0.00% |
| de | 1360 | 0 | 0.00% | 0.00% |
| fr | 1287 | 0 | 0.00% | 0.00% |
| it | 1207 | 0 | 0.00% | 0.00% |
| tr | 1206 | 24 | 1.95% | 0.00% |
| ru | 1127 | 0 | 0.00% | 0.00% |
| cs | 639 | 5 | 0.78% | 0.00% |
| el | 580 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| items.json | 12995 | 246 | 1.86% | 1.78% |
| npc.json | 12727 | 895 | 6.57% | 0.00% |
| monsters.json | 6416 | 190 | 2.88% | 0.00% |
| server.json | 3213 | 43 | 1.32% | 0.00% |
| html.json | 2709 | 208 | 7.13% | 0.00% |
| otclient_modules.json | 1714 | 527 | 23.52% | 0.00% |
| scripts.json | 1516 | 202 | 11.76% | 0.00% |
| questlog.json | 1440 | 0 | 0.00% | 14.29% |
| quests.json | 1208 | 75 | 5.85% | 0.00% |
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
| current_total | 61175 |
| backlog_es | 214 |
| backlog_pl | 123 |
| backlog_cs | 667 |
| backlog_de | 667 |
| backlog_fr | 614 |
| backlog_hu | 671 |
| backlog_it | 642 |
| backlog_nl | 699 |
| backlog_pt | 628 |
| backlog_ro | 699 |
| backlog_ru | 499 |
| backlog_sk | 671 |
| backlog_tr | 715 |
| backlog_ar | 920 |
| backlog_az | 670 |
| backlog_bg | 699 |
| backlog_bn | 920 |
| backlog_bs | 671 |
| backlog_da | 671 |
| backlog_el | 665 |
| backlog_et | 671 |
| backlog_fa | 1134 |
| backlog_fi | 671 |
| backlog_he | 920 |
| backlog_hi | 920 |
| backlog_hr | 671 |
| backlog_hy | 921 |
| backlog_id | 920 |
| backlog_ja | 920 |
| backlog_ka | 921 |
| backlog_kk | 671 |
| backlog_ko | 921 |
| backlog_lt | 657 |
| backlog_lv | 671 |
| backlog_mk | 670 |
| backlog_ml | 921 |
| backlog_ms | 920 |
| backlog_no | 671 |
| backlog_sl | 671 |
| backlog_sq | 769 |
| backlog_sr | 671 |
| backlog_sv | 671 |
| backlog_sw | 921 |
| backlog_ta | 921 |
| backlog_te | 921 |
| backlog_th | 921 |
| backlog_tl | 921 |
| backlog_uk | 671 |
| backlog_uz | 671 |
| backlog_vi | 921 |
| backlog_zh | 921 |
| backlog_zh_TW | 23108 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | -965.4% over 5.9h |
