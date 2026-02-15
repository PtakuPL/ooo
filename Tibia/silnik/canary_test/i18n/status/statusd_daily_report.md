# I18N Daily Executive Report (24h)

- Generated: `2026-02-15T19:32:18.750226Z`
- Window: `2026-02-14T19:32:18.750226Z` -> `2026-02-15T19:32:18.750226Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 12084 |
| guard_fail | 13934 |
| guard_fail_rate | 53.56% |
| no_progress_entries | 69 |
| no_progress_rate | 19.01% |
| pending_skip_count | 246 |
| pending_skip_share | 38.30% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 503.5 |
| throughput_keys_per_h_active | 504.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 11294 |
| suspicious_high_count | 10342 |
| suspicious_high_rate | 20.33% |
| suspicious_high_top_lang | es:6316 |
| identical_to_en_count | 1269 |
| gt_guard_fails_count | 27834 |
| latest_audit_issues_found | 24 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 211 |
| latest_entries_total | 702 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 11 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 12 |
| stagnation_detected | no |
| stagnation_span_h | 5.951 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 116 |
| avg_limit | 108.0 |
| avg_suspicious_high_pct | 111.43% |
| translated_total | 2122 |
| guard_fail_total | 8876 |
| guard_fail_rate_pct | 80.71% |
| gt_mode_true_samples | 116 |
| latest_timestamp | 2026-02-15T19:31:02.115026Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 159.40% | 1119 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 159.40% | 1119 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 159.40% | 1119 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 159.40% | 1119 | low_backlog+suspicious_guard | 108 |
| es:npc.json | 159.40% | 1119 | low_backlog+suspicious_guard | 108 |

## Metrics Drift (LIVE vs Registry)

| Metric | Value |
|---|---:|
| status | stable |
| severity | ok |
| live_keys | 55980 |
| worker_registry_keys | 55980 |
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
| pending_langs | es,pl |
| active_minutes | 1889.731 |
| cycle_delta | 886 |
| best_quality_drop_pct | 18.50% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 83.76% | 2394 | 2329 | 84.1% | 78.8% |
| ES | 80.54% | 2394 | 2623 | 80.6% | 79.5% |
| DE | 7.72% | 2394 | 2863 | 8.1% | 3.0% |
| PT | 7.48% | 2394 | 2776 | 7.8% | 2.9% |
| FR | 31.90% | 2394 | 3922 | 29.4% | 66.1% |
| RU | 32.41% | 2394 | 1755 | 29.6% | 70.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| pl | 5994 | 5673 | 48.62% | 19.38% |
| es | 5917 | 8241 | 58.21% | 18.03% |
| el | 68 | 13 | 16.05% | 0.00% |
| it | 45 | 2 | 4.26% | 40.00% |
| cs | 32 | 2 | 5.88% | 40.00% |
| lt | 28 | 3 | 9.68% | 20.00% |

## Top Categories (by translated)

| Category | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| monsters.json | 4012 | 2265 | 36.08% | 10.64% |
| html.json | 1872 | 1300 | 40.98% | 8.33% |
| items.json | 1791 | 633 | 26.11% | 20.00% |
| server.json | 1216 | 1446 | 54.32% | 23.53% |
| npc.json | 1015 | 4411 | 81.29% | 22.22% |
| questlog.json | 690 | 918 | 57.09% | 0.00% |
| scripts.json | 524 | 968 | 64.88% | 13.04% |
| otclient_modules.json | 373 | 166 | 30.80% | 12.50% |
| spells.json | 229 | 217 | 48.65% | 10.00% |
| cpp.json | 185 | 67 | 26.59% | 28.57% |
| quests.json | 55 | 276 | 83.38% | 52.63% |
| books.json | 35 | 835 | 95.98% | 16.67% |

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
| total_keys_extracted | 55980 |
| total_keys_extracted_live | 55980 |
| total_keys_extracted_worker_registry | 55980 |
| keys_extracted_outside_worker_registry | 0 |
| npc_total | 1027 |
| npc_migrated | 699 |
| npc_needs_migration | 0 |

## Scope (Serwer vs Instalka)

- Serwer EN keys: **52125**
- Instalka EN keys: **3855**

## Repair Backlog (identical_to_en)

| Metric | Value |
|---|---:|
| current_total | 39095 |
| backlog_es | 530 |
| backlog_pl | 311 |
| backlog_cs | 641 |
| backlog_de | 660 |
| backlog_fr | 578 |
| backlog_hu | 663 |
| backlog_it | 630 |
| backlog_nl | 691 |
| backlog_pt | 620 |
| backlog_ro | 689 |
| backlog_ru | 65 |
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
| backlog_sr | 663 |
| backlog_sv | 663 |
| backlog_sw | 905 |
| backlog_ta | 905 |
| backlog_te | 905 |
| backlog_th | 905 |
| backlog_tl | 905 |
| backlog_uk | 663 |
| backlog_uz | 663 |
| backlog_vi | 905 |
| backlog_zh | 905 |
| backlog_zh_TW | 2040 |
| delta_24h | -155 (-0.4%) |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | 0.0% over 5.9h |
