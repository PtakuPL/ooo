# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T07:01:03.264974Z`
- Window: `2026-02-13T07:01:03.264974Z` -> `2026-02-14T07:01:03.264974Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 42046 |
| guard_fail | 2153 |
| guard_fail_rate | 4.87% |
| no_progress_entries | 23 |
| no_progress_rate | 2.73% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1751.9 |
| throughput_keys_per_h_active | 1784.8 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 10717 |
| suspicious_high_count | 7785 |
| suspicious_high_rate | 15.08% |
| suspicious_high_top_lang | es:2206 |
| identical_to_en_count | 16039 |
| gt_guard_fails_count | 7395 |
| latest_audit_issues_found | 0 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 64 |
| latest_entries_total | 31 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 1746 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 3922 |
| stagnation_detected | no |
| stagnation_span_h | 5.978 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 0 |
| avg_limit | 0.0 |
| avg_suspicious_high_pct | 0.00% |
| translated_total | 0 |
| guard_fail_total | 0 |
| guard_fail_rate_pct | 0.00% |
| gt_mode_true_samples | 0 |
| latest_timestamp | - |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 74.96% | 2083 | 2857 | 75.2% | 71.6% |
| ES | 84.79% | 232 | 11460 | 86.3% | 65.5% |
| DE | 18.17% | 2155 | 25984 | 19.3% | 3.1% |
| PT | 19.25% | 2155 | 24238 | 20.2% | 6.4% |
| FR | 17.14% | 2155 | 24260 | 18.5% | 0.1% |
| RU | 18.93% | 2155 | 24381 | 20.0% | 5.0% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 9505 | 625 | 6.17% | 5.28% |
| pl | 7081 | 1179 | 14.27% | 3.59% |
| pt | 1287 | 0 | 0.00% | 0.00% |
| de | 1280 | 0 | 0.00% | 0.00% |
| fr | 1207 | 0 | 0.00% | 0.00% |
| tr | 1047 | 14 | 1.32% | 0.00% |
| ru | 1047 | 0 | 0.00% | 0.00% |
| it | 1047 | 0 | 0.00% | 0.00% |
| sq | 480 | 0 | 0.00% | 0.00% |
| sk | 480 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| items.json | 12755 | 231 | 1.78% | 1.81% |
| npc.json | 12073 | 501 | 3.98% | 0.00% |
| monsters.json | 4523 | 133 | 2.86% | 0.00% |
| server.json | 2960 | 0 | 0.00% | 0.00% |
| html.json | 2493 | 182 | 6.80% | 0.00% |
| otclient_modules.json | 1684 | 429 | 20.30% | 0.00% |
| questlog.json | 1360 | 0 | 0.00% | 15.00% |
| scripts.json | 1026 | 167 | 14.00% | 0.00% |
| quests.json | 840 | 61 | 6.77% | 0.00% |
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
| total_keys_extracted | 6248 |
| npc_total | 1027 |
| npc_migrated | 699 |
| npc_needs_migration | 0 |

## Scope (Serwer vs Instalka)

- Serwer EN keys: **49731**
- Instalka EN keys: **3855**

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 5230 |
| backlog_es | 4713 |
| backlog_pl | 517 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 31.4% over 5.9h |
