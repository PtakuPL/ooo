# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T07:56:48.209291Z`
- Window: `2026-02-13T07:56:48.209291Z` -> `2026-02-14T07:56:48.209291Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 44059 |
| guard_fail | 2254 |
| guard_fail_rate | 4.87% |
| no_progress_entries | 23 |
| no_progress_rate | 2.64% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1835.8 |
| throughput_keys_per_h_active | 3576.6 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 11279 |
| suspicious_high_count | 8256 |
| suspicious_high_rate | 15.14% |
| suspicious_high_top_lang | es:2265 |
| identical_to_en_count | 17014 |
| gt_guard_fails_count | 8416 |
| latest_audit_issues_found | 52 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 70 |
| latest_entries_total | 31 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 1510 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 4158 |
| stagnation_detected | no |
| stagnation_span_h | 5.973 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 4 |
| avg_limit | 260.0 |
| avg_suspicious_high_pct | 2.98% |
| translated_total | 427 |
| guard_fail_total | 611 |
| guard_fail_rate_pct | 58.86% |
| gt_mode_true_samples | 4 |
| latest_timestamp | 2026-02-14T07:43:29.131649Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 3.18% | 100 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.02% | 95 | high_backlog+domain_cap | 260 |
| es:npc.json | 2.90% | 91 | high_backlog+domain_cap | 260 |
| es:npc.json | 2.80% | 88 | high_backlog+domain_cap | 260 |

## Metrics Drift (LIVE vs Registry)

| Metric | Value |
|---|---:|
| status | stable |
| severity | ok |
| live_keys | 53586 |
| worker_registry_keys | 6248 |
| outside_worker_registry_keys | 47338 |
| outside_worker_registry_pct | 88.34% |
| warn_threshold_keys | 50000 |
| critical_threshold_keys | 100000 |
| warn_threshold_pct | 95.00% |
| critical_threshold_pct | 99.00% |
| threshold_source | statusd_thresholds_file |
| threshold_config_file | /home/ptaku/serweryt/Tibia/silnik/canary_test/statusd_thresholds.json |
| env_overrides_enabled | no |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 74.96% | 2083 | 2857 | 75.2% | 71.6% |
| ES | 85.91% | 232 | 11272 | 87.4% | 66.7% |
| DE | 18.42% | 2155 | 25847 | 19.6% | 3.1% |
| PT | 19.49% | 2155 | 24106 | 20.5% | 6.4% |
| FR | 17.25% | 2155 | 24201 | 18.6% | 0.1% |
| RU | 19.17% | 2155 | 24251 | 20.3% | 5.0% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 9503 | 642 | 6.33% | 5.30% |
| pl | 7020 | 1170 | 14.29% | 3.57% |
| pt | 1447 | 0 | 0.00% | 0.00% |
| de | 1360 | 0 | 0.00% | 0.00% |
| fr | 1287 | 0 | 0.00% | 0.00% |
| it | 1207 | 0 | 0.00% | 0.00% |
| tr | 1206 | 24 | 1.95% | 0.00% |
| ru | 1127 | 0 | 0.00% | 0.00% |
| no | 560 | 0 | 0.00% | 0.00% |
| fi | 560 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| items.json | 12755 | 231 | 1.78% | 1.81% |
| npc.json | 12551 | 583 | 4.44% | 0.00% |
| monsters.json | 5402 | 134 | 2.42% | 0.00% |
| server.json | 2960 | 0 | 0.00% | 0.00% |
| html.json | 2493 | 182 | 6.80% | 0.00% |
| otclient_modules.json | 1654 | 432 | 20.71% | 0.00% |
| scripts.json | 1466 | 168 | 10.28% | 0.00% |
| questlog.json | 1360 | 0 | 0.00% | 15.00% |
| quests.json | 1074 | 64 | 5.62% | 0.00% |
| books.json | 634 | 44 | 6.49% | 7.14% |
| cpp.json | 391 | 208 | 34.72% | 0.00% |
| talkactions.json | 375 | 42 | 10.07% | 0.00% |

## Notes

- pending_skip_share preferuje pending_skip_24h_latest.json; fallback: worker_cycle_perf.detail.
- no_progress_rate bazuje na translation_guard_report (translated<=0).
- repair_queue_24h bazuje na identical_to_en_repair_queue_report.jsonl.
- repair_tuning_24h bazuje na identical_to_en_repair_tuning.jsonl.

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
| total_keys_extracted_worker_registry | 6248 |
| keys_extracted_outside_worker_registry | 47338 |
| npc_total | 1027 |
| npc_migrated | 699 |
| npc_needs_migration | 0 |

## Scope (Serwer vs Instalka)

- Serwer EN keys: **49731**
- Instalka EN keys: **3855**

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 4994 |
| backlog_es | 4477 |
| backlog_pl | 517 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 32.0% over 6.0h |
