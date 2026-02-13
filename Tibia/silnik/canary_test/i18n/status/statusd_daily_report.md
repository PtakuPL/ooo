# I18N Daily Executive Report (24h)

- Generated: `2026-02-13T21:50:11.822469Z`
- Window: `2026-02-12T21:50:11.822469Z` -> `2026-02-13T21:50:11.822469Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 35184 |
| guard_fail | 3236 |
| guard_fail_rate | 8.42% |
| no_progress_entries | 27 |
| no_progress_rate | 1.92% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| throughput_keys_per_h_window | 1466.0 |
| throughput_keys_per_h_active | 1469.0 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 17258 |
| identical_to_en_count | 21251 |
| gt_guard_fails_count | 2675 |
| latest_audit_issues_found | 58 |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys |
|---|---:|---:|---:|
| PL | 72.54% | 2083 | 2994 |
| ES | 68.85% | 232 | 16315 |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 17728 | 1493 | 7.77% | 0.63% |
| pl | 16186 | 1572 | 8.85% | 1.28% |
| de | 774 | 7 | 0.90% | 6.06% |
| az | 55 | 7 | 11.29% | 8.33% |
| tr | 41 | 0 | 0.00% | 0.00% |
| pt | 37 | 4 | 9.76% | 0.00% |
| ru | 36 | 14 | 28.00% | 0.00% |
| it | 36 | 4 | 10.00% | 0.00% |
| fr | 36 | 4 | 10.00% | 0.00% |
| sv | 21 | 4 | 16.00% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| monsters.json | 7732 | 6 | 0.08% | 0.00% |
| otclient_modules.json | 3696 | 412 | 10.03% | 0.00% |
| items.json | 3608 | 779 | 17.76% | 0.58% |
| questlog.json | 2564 | 0 | 0.00% | 5.77% |
| scripts.json | 2461 | 612 | 19.92% | 0.00% |
| html.json | 2322 | 69 | 2.89% | 0.00% |
| raids.json | 2282 | 0 | 0.00% | 0.00% |
| books.json | 1963 | 585 | 22.96% | 1.33% |
| npc.json | 1930 | 177 | 8.40% | 1.43% |
| client.json | 1592 | 39 | 2.39% | 0.00% |
| talkactions.json | 1451 | 79 | 5.16% | 0.00% |
| server.json | 993 | 0 | 0.00% | 0.00% |

## Notes

- pending_skip_share bazuje na worker_cycle_perf.detail (sygnały pending_skip=*).
- no_progress_rate bazuje na translation_guard_report (translated<=0).
