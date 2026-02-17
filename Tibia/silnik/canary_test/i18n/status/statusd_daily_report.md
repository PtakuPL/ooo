# I18N Daily Executive Report (24h)

- Generated: `2026-02-17T04:20:40.128874Z`
- Window: `2026-02-16T04:20:40.128874Z` -> `2026-02-17T04:20:40.128874Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 34752 |
| guard_fail | 22199 |
| guard_fail_rate | 38.98% |
| no_progress_entries | 21 |
| no_progress_rate | 2.41% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1448.0 |
| throughput_keys_per_h_active | 4286.1 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 75794 |
| suspicious_high_count | 75585 |
| suspicious_high_rate | 193.84% |
| suspicious_high_top_lang | ro:26482 |
| identical_to_en_count | 3991 |
| gt_guard_fails_count | 5477 |
| latest_audit_issues_found | 29 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 158 |
| latest_entries_total | 710 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 24 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 0 |
| stagnation_detected | no |
| stagnation_span_h | 5.947 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 157 |
| avg_limit | 108.46 |
| avg_suspicious_high_pct | 285.72% |
| translated_total | 3640 |
| guard_fail_total | 129 |
| guard_fail_rate_pct | 3.42% |
| gt_mode_true_samples | 157 |
| latest_timestamp | 2026-02-17T04:18:45.725229Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 333.15% | 2382 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 328.61% | 2412 | low_backlog+suspicious_guard | 108 |

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
| pending_langs | es,it,pl,ro,ru,sr,sv |
| active_minutes | 364.79 |
| cycle_delta | 681 |
| best_quality_drop_pct | 59.61% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 46.79% | 0 | 1900 | 45.0% | 69.5% |
| ES | 74.79% | 0 | 2632 | 75.5% | 65.7% |
| DE | 7.83% | 0 | 2738 | 8.2% | 3.0% |
| PT | 7.58% | 0 | 2652 | 8.0% | 2.9% |
| FR | 33.06% | 0 | 4025 | 30.5% | 66.1% |
| RU | 37.95% | 0 | 2579 | 35.4% | 71.4% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| it | 6624 | 551 | 7.68% | 2.03% |
| ru | 6210 | 1113 | 15.20% | 2.04% |
| ro | 5819 | 1561 | 21.15% | 0.00% |
| pl | 4943 | 16733 | 77.20% | 5.93% |
| es | 3929 | 1583 | 28.72% | 5.34% |
| sv | 3642 | 327 | 8.24% | 0.00% |
| sr | 3585 | 331 | 8.45% | 0.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| npc.json | 6115 | 3602 | 37.07% | 0.00% |
| server.json | 4952 | 1074 | 17.82% | 2.59% |
| monsters.json | 4829 | 1591 | 24.78% | 0.00% |
| items.json | 4775 | 11014 | 69.76% | 0.00% |
| scripts.json | 2216 | 1004 | 31.18% | 0.00% |
| spells.json | 2073 | 827 | 28.52% | 0.00% |
| html.json | 1622 | 155 | 8.72% | 0.00% |
| quests.json | 1599 | 382 | 19.28% | 0.00% |
| raids.json | 1274 | 210 | 14.15% | 8.82% |
| otclient_modules.json | 1158 | 273 | 19.08% | 0.00% |
| books.json | 1068 | 632 | 37.18% | 0.00% |
| questlog.json | 1043 | 727 | 41.07% | 0.00% |

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
| current_total | 38529 |
| backlog_es | 300 |
| backlog_pl | 197 |
| backlog_cs | 641 |
| backlog_de | 659 |
| backlog_fr | 586 |
| backlog_hu | 663 |
| backlog_it | 460 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 477 |
| backlog_ru | 112 |
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
| backlog_sr | 492 |
| backlog_sv | 524 |
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
| delta_24h | -1522 (-3.8%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.9% over 6.0h |
