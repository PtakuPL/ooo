# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T08:40:23.028788Z`
- Window: `2026-02-13T08:40:23.028788Z` -> `2026-02-14T08:40:23.028788Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 45260 |
| guard_fail | 2466 |
| guard_fail_rate | 5.17% |
| no_progress_entries | 23 |
| no_progress_rate | 2.58% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1885.8 |
| throughput_keys_per_h_active | 3478.1 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 11713 |
| suspicious_high_count | 8690 |
| suspicious_high_rate | 15.48% |
| suspicious_high_top_lang | es:2513 |
| identical_to_en_count | 17403 |
| gt_guard_fails_count | 9240 |
| latest_audit_issues_found | 23 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 75 |
| latest_entries_total | 31 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 1268 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 4400 |
| stagnation_detected | no |
| stagnation_span_h | 5.948 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 7 |
| avg_limit | 260.0 |
| avg_suspicious_high_pct | 3.10% |
| translated_total | 729 |
| guard_fail_total | 1086 |
| guard_fail_rate_pct | 59.84% |
| gt_mode_true_samples | 7 |
| latest_timestamp | 2026-02-14T08:10:03.530908Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 3.33% | 105 | base+domain_cap | 260 |
| es:npc.json | 3.27% | 103 | base+domain_cap | 260 |
| es:npc.json | 3.18% | 100 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.18% | 100 | base+domain_cap | 260 |
| es:npc.json | 3.02% | 95 | high_backlog+domain_cap | 260 |

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
| active_minutes | 1.38 |
| cycle_delta | 1 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 75.14% | 2083 | 2837 | 75.4% | 71.4% |
| ES | 86.70% | 232 | 10858 | 88.2% | 66.7% |
| DE | 16.40% | 174 | 18319 | 17.4% | 3.1% |
| PT | 19.49% | 2155 | 24106 | 20.5% | 6.4% |
| FR | 54.05% | 174 | 24565 | 51.8% | 83.7% |
| RU | 54.88% | 174 | 32175 | 52.2% | 89.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 9722 | 719 | 6.89% | 5.19% |
| pl | 7224 | 1283 | 15.08% | 3.49% |
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
| items.json | 12755 | 231 | 1.78% | 1.81% |
| npc.json | 12619 | 675 | 5.08% | 0.00% |
| monsters.json | 6269 | 176 | 2.73% | 0.00% |
| server.json | 3040 | 0 | 0.00% | 0.00% |
| html.json | 2559 | 198 | 7.18% | 0.00% |
| otclient_modules.json | 1659 | 468 | 22.00% | 0.00% |
| scripts.json | 1495 | 191 | 11.33% | 0.00% |
| questlog.json | 1440 | 0 | 0.00% | 14.29% |
| quests.json | 1080 | 67 | 5.84% | 0.00% |
| books.json | 634 | 44 | 6.49% | 7.14% |
| cpp.json | 391 | 208 | 34.72% | 0.00% |
| talkactions.json | 375 | 42 | 10.07% | 0.00% |

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
| current_total | 4752 |
| backlog_es | 4235 |
| backlog_pl | 517 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 33.3% over 5.9h |
