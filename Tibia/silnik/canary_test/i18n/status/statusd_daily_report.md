# I18N Daily Executive Report (24h)

- Generated: `2026-02-14T10:17:02.499989Z`
- Window: `2026-02-13T10:17:02.499989Z` -> `2026-02-14T10:17:02.499989Z`

## KPI 24h

| KPI | Value |
|---|---:|
| translated | 45646 |
| guard_fail | 2727 |
| guard_fail_rate | 5.64% |
| no_progress_entries | 25 |
| no_progress_rate | 2.75% |
| pending_skip_count | 0 |
| pending_skip_share | 0.00% |
| pending_skip_source | pending_skip_24h_latest.json |
| throughput_keys_per_h_window | 1901.9 |
| throughput_keys_per_h_active | 3161.7 |

## Quality 24h

| Metric | Value |
|---|---:|
| suspicious_count | 11980 |
| suspicious_high_count | 8957 |
| suspicious_high_rate | 15.78% |
| suspicious_high_top_lang | es:2580 |
| identical_to_en_count | 17487 |
| gt_guard_fails_count | 9618 |
| latest_audit_issues_found | 27 |

## Repair Queue 24h

| Metric | Value |
|---|---:|
| samples_24h | 77 |
| latest_entries_total | 1245 |
| top_target_latest | es:npc.json |
| top_backlog_latest | 1266 |
| top_target_start_24h | es:npc.json |
| top_target_drop_24h | 4402 |
| stagnation_detected | no |
| stagnation_span_h | 5.948 |
| stagnation_reason | window_too_short |

## Repair Tuning 24h

| Metric | Value |
|---|---:|
| samples_24h | 8 |
| avg_limit | 260.0 |
| avg_suspicious_high_pct | 3.15% |
| translated_total | 826 |
| guard_fail_total | 1248 |
| guard_fail_rate_pct | 60.17% |
| gt_mode_true_samples | 8 |
| latest_timestamp | 2026-02-14T10:07:28.597593Z |

| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |
|---|---:|---:|---|---:|
| es:npc.json | 3.55% | 111 | base+domain_cap | 260 |
| es:npc.json | 3.33% | 105 | base+domain_cap | 260 |
| es:npc.json | 3.27% | 103 | base+domain_cap | 260 |
| es:npc.json | 3.18% | 100 | high_backlog+domain_cap | 260 |
| es:npc.json | 3.18% | 100 | base+domain_cap | 260 |

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
| active_minutes | 16.203 |
| cycle_delta | 3 |
| best_quality_drop_pct | 0.00% |

## Coverage Snapshot

| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |
|---|---:|---:|---:|---:|---:|
| PL | 75.31% | 2083 | 2839 | 75.6% | 71.3% |
| ES | 86.93% | 232 | 10377 | 88.4% | 67.8% |
| DE | 16.92% | 174 | 17726 | 18.0% | 3.1% |
| PT | 19.98% | 2155 | 23636 | 21.0% | 6.4% |
| FR | 54.46% | 174 | 23962 | 52.2% | 83.7% |
| RU | 55.37% | 174 | 31695 | 52.7% | 89.7% |

## Top Languages (by translated)

| Lang | Translated | Guard Fail | GF Rate | No Progress |
|---|---:|---:|---:|---:|
| es | 9942 | 832 | 7.72% | 5.76% |
| pl | 7390 | 1431 | 16.22% | 3.36% |
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
| items.json | 12835 | 234 | 1.79% | 1.80% |
| npc.json | 12672 | 791 | 5.88% | 0.00% |
| monsters.json | 6269 | 176 | 2.73% | 0.00% |
| server.json | 3040 | 0 | 0.00% | 0.00% |
| html.json | 2709 | 208 | 7.13% | 0.00% |
| otclient_modules.json | 1714 | 527 | 23.52% | 0.00% |
| scripts.json | 1495 | 191 | 11.33% | 0.00% |
| questlog.json | 1440 | 0 | 0.00% | 14.29% |
| quests.json | 1080 | 67 | 5.84% | 0.00% |
| books.json | 639 | 48 | 6.99% | 6.90% |
| cpp.json | 417 | 242 | 36.72% | 0.00% |
| talkactions.json | 377 | 46 | 10.87% | 0.00% |

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
| current_total | 799578 |
| backlog_es | 4177 |
| backlog_pl | 479 |
| backlog_cs | 15470 |
| backlog_de | 10459 |
| backlog_fr | 10136 |
| backlog_hu | 15558 |
| backlog_it | 15283 |
| backlog_nl | 10817 |
| backlog_pt | 15256 |
| backlog_ru | 17358 |
| backlog_sk | 15627 |
| backlog_tr | 15069 |
| backlog_ar | 18584 |
| backlog_az | 15444 |
| backlog_bg | 17358 |
| backlog_bn | 16906 |
| backlog_bs | 15645 |
| backlog_da | 15558 |
| backlog_el | 15534 |
| backlog_et | 15508 |
| backlog_fa | 16562 |
| backlog_fi | 15540 |
| backlog_he | 17184 |
| backlog_hi | 17155 |
| backlog_hr | 15533 |
| backlog_hy | 17214 |
| backlog_id | 17150 |
| backlog_ja | 17204 |
| backlog_ka | 17187 |
| backlog_kk | 15577 |
| backlog_ko | 17196 |
| backlog_lt | 15570 |
| backlog_lv | 15577 |
| backlog_mk | 15055 |
| backlog_ml | 17200 |
| backlog_ms | 16753 |
| backlog_no | 15634 |
| backlog_ro | 10829 |
| backlog_sl | 15683 |
| backlog_sq | 15608 |
| backlog_sr | 15694 |
| backlog_sv | 15710 |
| backlog_sw | 17291 |
| backlog_ta | 17329 |
| backlog_te | 17325 |
| backlog_th | 17335 |
| backlog_tl | 17411 |
| backlog_uk | 15732 |
| backlog_uz | 15687 |
| backlog_vi | 17416 |
| backlog_zh | 17578 |
| backlog_zh_TW | 17433 |
| stagnation_status | 🟢 warming_up |
| stagnation_decrease | -12715.8% over 5.8h |
