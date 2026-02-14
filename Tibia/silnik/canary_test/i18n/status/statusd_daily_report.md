# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T06:10:17.717083Z`
- Window: `2026-02-13T06:10:17.717083Z` -> `2026-02-14T06:10:17.717083Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 43057 |
| guard_fail | 2419 |
| guard_fail_rate | 5.32% |
| no_progress_entries | 23 |
| no_progress_rate | 2.55% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| throughput_keys_per_h_window | 1794.0 |
| throughput_keys_per_h_active | 1795.6 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 11860 |
| identical_to_en_count | 17696 |
| gt_guard_fails_count | 6923 |
| latest_audit_issues_found | 75 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 59 |
| latest_entries_total | 31 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 2217 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 3451 |
| stagnation_detected | no |
| stagnation_span_h | 5.915 |
| stagnation_reason | window_too_short |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys |
|---|---:|---:|---:|
| PL | 74.96% | 2083 | 2857 |
| ES | 82.90% | 232 | 11939 |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 10515 | 793 | 7.01% | 4.64% |
| pl | 8572 | 1327 | 13.41% | 3.11% |
| de | 1580 | 0 | 0.00% | 0.00% |
| pt | 1287 | 0 | 0.00% | 0.00% |
| fr | 1207 | 0 | 0.00% | 0.00% |
| tr | 1047 | 14 | 1.32% | 0.00% |
| ru | 1047 | 0 | 0.00% | 0.00% |
| it | 1047 | 0 | 0.00% | 0.00% |
| vi | 400 | 0 | 0.00% | 0.00% |
| uz | 400 | 0 | 0.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| items.json | 13213 | 335 | 2.47% | 1.64% |
| npc.json | 10333 | 451 | 4.18% | 0.00% |
| monsters.json | 5623 | 133 | 2.31% | 0.00% |
| server.json | 2960 | 0 | 0.00% | 0.00% |
| html.json | 2637 | 194 | 6.85% | 0.00% |
| otclient_modules.json | 2143 | 465 | 17.83% | 0.00% |
| questlog.json | 1410 | 0 | 0.00% | 14.29% |
| scripts.json | 1282 | 263 | 17.02% | 0.00% |
| quests.json | 868 | 95 | 9.87% | 0.00% |
| books.json | 656 | 72 | 9.89% | 6.90% |
| talkactions.json | 431 | 46 | 9.64% | 0.00% |
| cpp.json | 409 | 208 | 33.71% | 0.00% |

## Notes

- pending_skip_share bazuje na worker_cycle_perf.detail (sygnały pending_skip=*).
- no_progress_rate bazuje na translation_guard_report (translated<=0).
- repair_queue_24h bazuje na identical_to_en_repair_queue_report.jsonl.

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 5701 |
| backlog_es | 5184 |
| backlog_pl | 517 |
