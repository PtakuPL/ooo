# I18N Daily Executive Report (24h)

- Generated: `2026-02-20T18:12:12.555930Z`
- Window: `2026-02-19T18:12:12.555930Z` -> `2026-02-20T18:12:12.555930Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 8296 |
| guard_fail | 16943 |
| guard_fail_rate | 67.13% |
| no_progress_entries | 457 |
| no_progress_rate | 61.34% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 345.7 |
| throughput_keys_per_h_active | 346.0 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 34334 |
| suspicious_high_count | 34113 |
| suspicious_high_rate | 345.13% |
| suspicious_high_top_lang | ro:12310 |
| identical_to_en_count | 907 |
| gt_guard_fails_count | 5077 |
| latest_audit_issues_found | 31 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 155 |
| latest_entries_total | 699 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 51 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 1.928 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 146 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 283.62% |
| translated_total | 1331 |
| guard_fail_total | 1576 |
| guard_fail_rate_pct | 54.21% |
| gt_mode_true_samples | 146 |
| latest_timestamp | 2026-02-20T18:11:50.513722Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 308.70% | 2130 | low_backlog+suspicious_guard | 108 |

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
| detected | yes |
| severity | critical |
| reason | active_time_without_quality_drop |
| pending_langs | es,it,pl,ro,ru,sr,sv |
| active_minutes | 5516.332 |
| cycle_delta | 5117 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 87.82% | 0 | 1829 | 88.5% | 78.8% |
| ES | 84.70% | 0 | 2163 | 85.1% | 79.5% |
| DE | 7.84% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.09% | 0 | 3788 | 30.5% | 66.1% |
| RU | 50.35% | 0 | 1457 | 48.6% | 72.5% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| ru | 1714 | 299 | 14.85% | 55.36% |
| it | 1536 | 526 | 25.51% | 57.98% |
| es | 1254 | 4865 | 79.51% | 55.74% |
| pl | 1248 | 10263 | 89.16% | 53.85% |
| ro | 1195 | 834 | 41.10% | 56.60% |
| sr | 742 | 8 | 1.07% | 79.76% |
| sv | 607 | 148 | 19.60% | 80.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 2310 | 3867 | 62.60% | 24.68% |
| monsters.json | 1552 | 461 | 22.90% | 26.67% |
| items.json | 1236 | 9555 | 88.55% | 34.48% |
| server.json | 901 | 558 | 38.25% | 39.13% |
| scripts.json | 418 | 293 | 41.21% | 48.28% |
| questlog.json | 354 | 214 | 37.68% | 57.14% |
| raids.json | 333 | 105 | 23.97% | 59.26% |
| html.json | 316 | 62 | 16.40% | 66.67% |
| otclient_modules.json | 206 | 133 | 39.23% | 60.87% |
| achievements.json | 165 | 66 | 28.57% | 75.00% |
| spells.json | 163 | 1005 | 86.04% | 47.73% |
| books.json | 96 | 264 | 73.33% | 73.91% |

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
| current_total | 37894 |
| backlog_es | 277 |
| backlog_pl | 147 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 443 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 424 |
| backlog_ru | 59 |
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
| backlog_sr | 50 |
| backlog_sv | 535 |
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
| delta_24h | -19 (-0.1%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.0% over 1.4h |
