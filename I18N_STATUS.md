# 🌍 System Tłumaczeń I18N — Dashboard na żywo

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'arena': 184, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 📝 PODSUMOWANIE

> Worker tłumaczy **53** języków. Klucze EN: **74,536**. Pokrycie globalne: **nominal 18.41% / real 11.37%**. Tempo: **1088.0 kluczy/h**. Tłumaczeń netto: **156,325**.

## 🧭 META

> **[META]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-04-30 20:26:36

> **Aktualizacja:** 2026-04-30 20:26:36 UTC
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 74536
> **Publikacja:** git-enabled
> **LIVE:** Cykl #19,011 | Status: 🟢 DZIAŁA | Faza: AUTO_TRANSLATE | Etap: heartbeat_tick | Kategoria: de | Plik: npc.json | Heartbeat: 2026-04-30T20:25:18Z
> **Okno godzinowe:** okno=1.0h | cykli=60 | pominięte=0.0% | odrzucone=1.0% | przepustowość=1088.0/h  
> **Tłumaczeń netto:** 156,325

### 🧩 Status sekcji
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 AKTYWNY | teraz | - | `update_github_status()` | 2026-04-30 20:26:36 |
| LIVE | 🟢 AKTYWNY | 1min temu | - | `activity.json / worker_state.json` | 2026-04-30T20:25:18Z |
| PRE_MIGRATION | 🔒 NIEAKTYWNY | 16s temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-04-30 20:26:36 |
| TRANSLATION | 🟢 AKTYWNY | 3min temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-04-30T20:23:25.574212Z |
| QUALITY | 🔒 NIEAKTYWNY | 1min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-04-30T20:25:17.412749Z |
| HISTORY | 🟢 AKTYWNY | teraz | - | `daily/*.json / ops.jsonl` | 2026-04-30 20:26:36 |
| DOCTOR | 🟠 AKTYWNY | 0s temu | 1 alarmów | `doctor_alerts_latest.json` | 2026-04-30T20:26:41.238995Z |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🤖 Worker Live

> **[LIVE]** 🟢 AKTYWNY  
> Świeżość: 1min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-04-30T20:25:18Z

| Metryka | Wartość |
|---------|---------|
| 🛠️ **Co robi** | Tłumaczenie automatyczne (Google Translate + TM) |
| 🌍 **Aktywne języki (10 min)** | DE, ES, IT |
| 📝 **Faza** | AUTO_TRANSLATE |
| 📋 **Etap** | sygnał życia |
| 📂 **Kategoria / Język** | de |
| 📄 **Plik** | npc.json |
| 🧭 **Surface** | Serwer |
| 📊 **Status** | 🟢 DZIAŁA |
| 📈 **Postęp** | Batch: 30 keys/cykl |
| 🔧 **Metoda** | Google Translate + TM fallback |
| 🧠 **Detail** | auto translate in progress |
| 🔑 **Current key** | `de:npc.json` |
| 🔄 **Ostatni cykl** | 64 kluczy, 0 odrzuconych, 123.0s, tryb: AUTO_TRANSLATE, cel: es/items.json |
| ❤️ **Heartbeat** | 2026-04-30T20:25:18Z |

**Ostatnie operacje:**
- → REPAIR_IDENTICAL_DONE (ES) [ok]
- → AUTO_TRANSLATE_DONE (ES) [warn]
- → AUTO_TRANSLATE_DONE (IT) [warn]
- → REPAIR_IDENTICAL_DONE (ES) [ok]
- → AUTO_TRANSLATE_DONE (RO) [warn]

---

## ✍️ Recent Writes

| Czas UTC | Lang | Surface | Plik | Count | Source | Sample key | Sample |
|----------|------|---------|------|-------|--------|------------|--------|
| 20:23:16 | ES | Serwer | items.json | 64 | `openai:openai/gpt-4o-...` | `item.12407.name` | muro rocoso |
| 20:21:05 | IT | Serwer | items.json | 98 | `openai:openai/gpt-4o-...` | `item.14928.name` | piccolo ruscello |
| 20:18:32 | ES | Serwer | npc.json | 2 | `tm` | `npc.charos.say_4` | Bien. Te quedan {} sintonizaciones. ¿Cuál es la nueva ciudad de tu elección? ¿Thais, ... |
| 20:14:29 | RO | Serwer | items.json | 60 | `openai:openai/gpt-4o-...` | `item.11669.name` | draken abominație moartă |
| 20:12:17 | CS | Serwer | items.json | 86 | `openai:openai/gpt-4.1...` | `item.15543.name` | titanická houba |
| 20:07:52 | RU | Serwer | items.json | 60 | `openai:openai/gpt-4.1...` | `item.15394.name` | моховые пятна |
| 20:05:23 | TR | Serwer | items.json | 31 | `simple` | `item.14592.name` | AYRILMIŞ SPRİTE |
| 20:03:51 | ES | Serwer | npc.json | 4 | `tm` | `npc.charles.voice_1` | Pasajes a Thais, Darashia, Edron, Venore, Ankrahmun, Liberty Bay y Yalahar. |
| 19:59:49 | DE | Serwer | npc.json | 115 | `google_translate` | `npc.billy.stdmod_41` | Diese alte Hexe findet immer jemanden, der ihre Arbeit erledigt. Ich habe keine Ahnun... |
| 19:56:50 | ES | Serwer | items.json | 64 | `openai:openai/gpt-4.1...` | `item.12851.name` | estructura de colmena |
| 19:52:44 | IT | Serwer | items.json | 60 | `openai:openai/gpt-4.1...` | `item.14696.name` | capolavoro di un gozzler |
| 19:50:36 | RO | Serwer | items.json | 60 | `openai:openai/gpt-4.1...` | `item.11669.name` | draken abominație moartă |
| 19:48:25 | ES | Serwer | npc.json | 2 | `tm` | `npc.cerdras.farewell_msg_1` | Que Crunor te bendiga y te guíe, \|PLAYERNAME\|. |
| 19:44:27 | CS | Serwer | items.json | 156 | `openai:openai/gpt-4o-...` | `item.16369.name` | blátivá kamenná zeď |
| 19:41:50 | RU | Serwer | items.json | 60 | `openai:openai/gpt-4.1...` | `item.14917.name` | маленький ручей |
| 19:36:47 | TR | Serwer | items.json | 30 | `simple` | `item.14564.name` | AYRILMIŞ SPRİTE |



> Źródło: `translation_recent_report.jsonl` + fizyczne `i18n/<lang>/<plik>` (ostatnie 20 wpisów z próbką nadal zgodną z plikiem)

---

## 🚫 Recent Rejects

| Czas UTC | Lang | Surface | Kategoria | Guard | Decision | Reject types | Key |
|----------|------|---------|-----------|-------|----------|--------------|-----|
| 20:06:40 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.14670.name` |
| 20:06:38 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.11541.name` |
| 19:58:12 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.say_15` |
| 19:58:12 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.multi_16` |
| 19:58:12 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.angelo.say_14` |
| 19:40:12 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.14670.name` |
| 19:40:11 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.11541.name` |
| 19:33:21 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.say_15` |
| 19:33:21 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.multi_16` |
| 19:33:19 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.angelo.say_14` |
| 19:10:37 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.14670.name` |
| 19:10:36 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.11541.name` |
| 19:03:30 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.say_15` |
| 19:03:30 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.multi_16` |
| 19:03:30 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.angelo.say_14` |
| 18:45:33 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.14670.name` |
| 18:45:31 | RU | Serwer | items.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `item.11541.name` |
| 18:37:37 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.say_15` |
| 18:37:34 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.arkulius.multi_16` |
| 18:37:34 | DE | Serwer | npc.json | `hard_block` | `too_many_issues` | `canonical_term_missing, canonical_term_missin...` | `npc.angelo.say_14` |

> Źródło: `suspicious_rejected.jsonl` (ostatnie 20 hard-blocków)

---

## 📦 Queue Health

| Metryka | Wartość |
|---------|---------|
| 🔒 Blockers state | `active` |
| 📌 Blocker candidates | 96 |
| 📨 Pending queue (visible tail) | 396 z ostatnich 400 poprawnych wpisów JSONL |
| ⏳ Oldest pending (visible tail) | 95346 s |
| 🌍 Top języki | RU(376), DE(20) |
| 🧱 Top reason_bucket | quality(377), default(13), word_salad(3), placeholder(2) |
| 🗂️ Deferred state keys | 9151 |
| 🕒 Deferred state freshness | fresh (33s) |
| ♻️ Deferred stats | enqueued=0, cooldown=0, deduped=0, manual_review=1, partial_staged=0, partial_completed=0 |

> Źródła: `deferred_translation_queue.jsonl`, `deferred_retry_state.json`, `translation_blockers_latest.json`

---

## 🔀 Provider Routing

| Metryka | Wartość |
|---------|---------|
| 🧭 Active provider | `OpenAI model pool` |
| 🧠 Active model | `openai/gpt-4o-mini` |
| 🪜 Runtime chain | `TM/simple -> Free Google Translate -> OpenAI model pool` |
| 🎯 Target chain | `TM/simple -> Free Google Translate -> OpenAI model pool -> Google Cloud` |
| 🗂 Router registry | `provider_router_registry.json` |
| 🎨 Style authority | `free_google_translate` |
| 🧪 OpenAI scope | langs=DE, PL, ES, PT, FR, IT, +8; surfaces=items, npc, monsters, books, quests, +2 |
| ⚠️ Switch reasons | quota_exhausted, rate_limit, model_unavailable |
| 🧮 OpenAI budget | `194/250 (77.6%); policy=telemetry_only` |
| ♻️ Provider debt | `767` |
| 🌍 Recent provider mix | OpenAI model pool(366), Free Google Translate(71), TM/simple(69), canonical_name_semantic_autofix(21), term... |
| 🔁 Latest fallback | - |
| 📉 Fallback breakdown | - |
| ☁️ Cloud policy | `disabled` |
| 🤖 OpenAI pool | `active` |
| 🩺 Health signals | provider_consistency_debt:767 |
| ❤️ Pool health | `degraded` (writes=530, fallbacks=0) |

> Źródła: `translation_provider_status_latest.json`, `translation_recent_report.jsonl`, `suspicious_log.jsonl`

---

## 🧩 Term Consistency

| Metryka | Wartość |
|---------|---------|
| 📂 Surface | `server` |
| 🌍 Lang / plik | `es` / `server.json` |
| 🗂 Registry terms | `16918` |
| 🔎 Keys with term usages | `0` / `0` scanned |
| ⚠️ Keys with conflicts | `0` |
| 🧮 Conflict rate | `0.0%` (Δ `0.0pp`) |
| 🛠 Auto-fixed EN leaks | `0` |
| 🧭 Name semantic autofix | `0` fixed / `0` blocked |
| 🛡 Name quality cleanup | `0` fail-closed |
| 🧬 Inflection suspects | `0` |
| 🧾 Manual review | `0` |
| 🧷 Top conflicts | - |

> Źródła: `term_conflicts_latest.json`, `term_conflict_summary.json`, `term_registry_enriched.json`

---

## 🛡️ Launcher Quality Gate

| Metryka | Wartość |
|---------|---------|
| 🧭 Gate status | `🟢 PASS` |
| 📁 Files | client.json, otclient_modules.json |
| 🌍 Langs evaluated | 51/51 |
| 🚫 Failing langs | - |
| 📈 Trend 24h | pass=203/203 (100.00%), fail=0, Δchecks=+0, dir=stable |
| 📏 Thresholds | identical<=35.00% ; word_salad<=5 ; placeholder<=3 |
| 🧪 Reject window | tail=1200 wpisów suspicious_rejected |
| 🧠 Recommendation | Launcher quality gate PASS: brak naruszeń progów dla client/otclient_modules. |

| Plik | Langs PASS/TOTAL | Max identical_to_en | Word-salad rejects | Placeholder rejects | Gate |
|------|------------------|---------------------|--------------------|---------------------|------|
| client.json | 51/51 | 31.40% | 0 | 0 | ✅ PASS |
| otclient_modules.json | 51/51 | 29.79% | 0 | 0 | ✅ PASS |

> Źródła: `launcher_quality_gate_latest.json`, `suspicious_rejected.jsonl`, `translation_global_overview.json`

---

## 🚨 Doctor Alerts

| Alarm | Status | Severity | Value | Threshold | Detail |
|-------|--------|----------|-------|-----------|--------|
| `HEARTBEAT_STALE` | OK | OK | `66` | `300` | Heartbeat świeży (66s, src=worker_runtime_heartbeat) Runtime[status=healthy, reason=heartbeat_fresh, phase=... |
| `NO_WRITE` | OK | OK | `204` | `900` | Recent writes wyglądają zdrowo. |
| `LEASE_CONFLICT` | OK | OK | `0` | `0` | Brak konfliktów lease/lock w oknie 1800s. |
| `QUEUE_STARVATION` | ALERT | WARNING | `{'pending': 396, 'oldest_s': 95346}` | `{'pending_min': 200, 'oldest_s': 3600}` | Duży pending i stara kolejka sugerują głodzenie queue. |
| `DLQ_GROWTH` | OK | OK | `{'count': 0, 'delta': 0}` | `{'growth_step': 25}` | DLQ precursor bez niepokojącego wzrostu. |

> Źródło: `doctor_alerts_latest.json` (checks: HEARTBEAT_STALE, NO_WRITE, LEASE_CONFLICT, QUEUE_STARVATION, DLQ_GROWTH)

---

## 🛠️ Doctor Remediation

| Metryka | Wartość |
|---------|---------|
| 🔔 Open alarms | 4 |
| 🆕 Newly opened (cycle) | - |
| ✅ Resolved (cycle) | - |
| 📌 Active alarm codes | NATIVE_READINESS_BELOW_THRESHOLD, QUEUE_STARVATION_DETECTED, SURFACE_COVERAGE_IMBALANCE, TERM_CONSISTENCY_R... |
| 🧠 Tracked alarm codes | 33 |
| 🛠️ Recommended action | `force_auto` |
| ▶️ Selected action | `none` |
| 📨 Selected command | `-` |
| 📍 Action result | `pending` |
| ℹ️ Action reason | write_starvation_or_queue_starvation |
| 🧊 Cooldown active | tak (pozostało: 2 cykli) |

> Źródło: `worker_alarm_bridge_latest.json` (ingest `statusd_doctor.json` + lifecycle alarmów open/resolved + auto-remediation action)

---

## ⏱️ Ta godzina

| Metryka | Wartość |
|---------|---------|
| � PRE_MIGRATION cykli | **0** (kategorii przeskanowanych: 0) |
| 🔍 Hits (stringów do migracji) | **112,434** w 18,063 plikach |
| �📊 Przetłumaczono | **1,088** kluczy |
| ❌ Odrzucone (guard) | 11 |
| 🔁 Cykli | 60 |
| 🌍 Języków | 7 |
| 🏆 Najaktywniejszy | CS (242 kluczy) |
| 📄 Najczęstszy plik | items.json |
| ⚡ Przepustowość | ~1088 kluczy/h |
| 🛡️ Odrzucone (strażnik) | 1.0% |
| ⚠️ Podejrzane | 2385 |

---

## 🌍 Języki — ostatnia godzina

| Język | Przetłumaczono | Odrzucone | GF% | Pliki |
|-------|---------------|-----------|-----|-------|
| CS | 242 | 0 | 0.0% | 1 |
| DE | 195 | 7 | 3.5% | 1 |
| ES | 192 | 0 | 0.0% | 1 |
| IT | 158 | 0 | 0.0% | 1 |
| RU | 120 | 4 | 3.2% | 1 |
| RO | 120 | 0 | 0.0% | 1 |
| TR | 61 | 0 | 0.0% | 1 |

> Źródło: `translation_guard_report.jsonl` (okno 1.0h)

---

## 🗺️ Pokrycie per język (TOP 20)

| Język | Przetłumaczono | Kluczy EN | Pokrycie | Kopie EN |
|-------|---------------|-----------|----------|----------|
| PL | 62,753 | 74,536 | 84.19% →0% | 5,023 |
| ES | 59,540 | 74,536 | 79.88% ↑+0.08% | 9,501 |
| IT | 53,765 | 74,536 | 72.13% | 10,029 |
| RO | 52,091 | 74,536 | 69.89% | 12,941 |
| RU | 34,633 | 74,536 | 46.46% →0% | 4,775 |
| FR | 42,864 | 74,536 | 57.51% →0% | 26,153 |
| CS | 38,910 | 74,536 | 52.2% | 29,600 |
| PT | 60,516 | 74,536 | 81.19% →0% | 48,839 |
| TR | 26,920 | 74,536 | 36.12% | 3,838 |
| SR | 24,827 | 74,536 | 33.31% | 1,218 |
| NL | 57,814 | 74,536 | 77.57% | 49,478 |
| DE | 52,013 | 74,536 | 69.78% ↑+0.13% | 63,673 |
| BN | 4,787 | 74,536 | 6.42% | 3,991 |
| AR | 4,662 | 74,536 | 6.25% | 3,974 |
| LT | 3,606 | 74,536 | 4.84% | 2,792 |
| FA | 4,661 | 74,536 | 6.25% | 4,199 |
| HI | 4,294 | 74,536 | 5.76% | 3,960 |
| ID | 4,287 | 74,536 | 5.75% | 4,006 |
| AZ | 3,511 | 74,536 | 4.71% | 2,997 |
| BG | 3,502 | 74,536 | 4.7% | 3,019 |

> Źródło: `translation_global_overview.json`

---

## 📈 Postęp i ETA (cel: 95%)

> **ETA globalne:** ~114 dni (2,968,334 kluczy do celu 95%)

| Język | Pasek | Pokrycie | Przetłumaczono | ETA do 95% |
|-------|-------|----------|---------------|------------|
| PL | ████████████████░░░░ | 84.2% | 62,753/74,536 | ~7h |
| ES | ███████████████░░░░░ | 79.9% | 59,540/74,536 | ~10h |
| IT | ██████████████░░░░░░ | 72.1% | 53,765/74,536 | ~16h |
| RO | █████████████░░░░░░░ | 69.9% | 52,091/74,536 | ~17h |
| RU | █████████░░░░░░░░░░░ | 46.5% | 34,633/74,536 | ~33h |
| FR | ███████████░░░░░░░░░ | 57.5% | 42,864/74,536 | ~26h |
| CS | ██████████░░░░░░░░░░ | 52.2% | 38,910/74,536 | ~29h |
| PT | ████████████████░░░░ | 81.2% | 60,516/74,536 | ~9h |
| TR | ███████░░░░░░░░░░░░░ | 36.1% | 26,920/74,536 | ~40h |
| SR | ██████░░░░░░░░░░░░░░ | 33.3% | 24,827/74,536 | ~42h |
| NL | ███████████████░░░░░ | 77.6% | 57,814/74,536 | ~12h |
| DE | █████████████░░░░░░░ | 69.8% | 52,013/74,536 | ~17h |
| BN | █░░░░░░░░░░░░░░░░░░░ | 6.4% | 4,787/74,536 | ~3d |
| AR | █░░░░░░░░░░░░░░░░░░░ | 6.2% | 4,662/74,536 | ~3d |
| LT | ░░░░░░░░░░░░░░░░░░░░ | 4.8% | 3,606/74,536 | ~3d |
| FA | █░░░░░░░░░░░░░░░░░░░ | 6.2% | 4,661/74,536 | ~3d |
| HI | █░░░░░░░░░░░░░░░░░░░ | 5.8% | 4,294/74,536 | ~3d |
| ID | █░░░░░░░░░░░░░░░░░░░ | 5.8% | 4,287/74,536 | ~3d |
| AZ | ░░░░░░░░░░░░░░░░░░░░ | 4.7% | 3,511/74,536 | ~3d |
| BG | ░░░░░░░░░░░░░░░░░░░░ | 4.7% | 3,502/74,536 | ~3d |

> Tempo obliczone na bazie ostatniej godziny: ~1088 kluczy/h.

---

## 🤖 AI Agent Integration

```
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n_file_status.json                              │
│  Worker: i18n_worker_simple.sh                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🕹️ Komendy przez GitHub (sterowanie workerem)

- Edytuj plik: `Tibia/silnik/canary_test/.github/worker_commands.txt`
- Wpisz **jedną** komendę w nowej linii (bez `#`), np.: `FORCE:scripts:ONCE` lub `COMPACT_KEYS:ONCE`
- Worker sam zakomentuje wykonaną komendę i dopisze historię.

#### Sterowanie językiem
| Komenda | Opis |
|---------|------|
| `LANG:<lang>` | Przypiąj worker do jednego języka (auto-wybór plików) |
| `LANG:<lang>:<plik1>,<plik2>,...` | Przypiąj język + cyklicznie przechodź podane pliki |
| `LANG:random` | Przywróć tryb losowy (wszystkie języki) |
| `FOCUS:<lang>[:json[:limit]]` | Skup na języku (persystentne, zapis do config) |
| `UNFOCUS` | Zdejmij focus, wróć do tier-round-robin |

#### Tłumaczenie i testy
| Komenda | Opis |
|---------|------|
| `AUTO:<lang>:<json>:<limit>` | Jednorazowe tłumaczenie (lang/plik/limit) |
| `TEST:<lang>` | Pełny test: translate + validate + crossref (1 cykl) |
| `TEST_ALL` | Dodaj WSZYSTKIE języki do kolejki testowej |
| `LANGVAL:all` / `LANGVAL:<lang>` | Wymuś walidację |
| `SPOTCHECK:<lang>[:N]` | Losowy audit N tłumaczeń |
| `GRAMMARFIX:<lang>[:json[:N]]` | Napraw EN-copy/artefakty + walidacja |

#### Konfiguracja w locie
| Komenda | Opis |
|---------|------|
| `GT:on` / `GT:off` | Włącz/wyłącz Google Translate |
| `BATCH:<N>` | Ustaw translate_limit na N kluczy/cykl |
| `SET:<key>=<value>` | Zmień wartość w worker_config.json |
| `RESTART` | Restart workera (git pull + exec) |
| `CONFIG` | Wyświetl aktualną konfigurację |
| `REPORT` / `LANGS` | Raport coverage / lista języków |
| `PREMIG:<cat lub all>` | Wymuś szczegółowy skan PRE_MIGRATION (plik/linia/treść) |
| `SKIP` / `PAUSE:<N>` / `IDLE` | Kontrola cyklu |

---

## 🔍 PRE_MIGRATION — Skan plików źródłowych

> **[PRE_MIGRATION]** 🔒 NIEAKTYWNY (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 16s temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-04-30 20:26:36

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **22,181** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **10,418** | 47.0% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,443** | **61.8%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **15** | **0.1%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **3,975** | 38.2% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **10,403** | 99.9% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,493 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 841 | silnik serwera |
| 📋 JSON (.json) | 3,487 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **7** | 0.1% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **8** | - | bez tekstów |
| 🔧 W trakcie | **0** | - | obecnie przetwarzane |

### � PRE_MIGRATION — Wyniki skanów per kategoria
| Kategoria | Hits (stringów) | Plików z hitami | Plików przeskanowanych | Status |
|-----------|-----------------|-----------------|------------------------|--------|
| php | **53,490** | 2,779 | 5,587 | 🔍 53490 do migracji |
| monsters | **18,665** | 1,703 | 1,704 | 🔍 18665 do migracji |
| items | **17,390** | 9 | 10 | 🔍 17390 do migracji |
| html | **11,437** | 288 | 677 | 🔍 11437 do migracji |
| otclient_modules | **6,587** | 168 | 294 | 🔍 6587 do migracji |
| libs | **1,691** | 35 | 86 | 🔍 1691 do migracji |
| modules | **965** | 3 | 7 | 🔍 965 do migracji |
| errors | **849** | 141 | 2,696 | 🔍 849 do migracji |
| mounts | **697** | 8 | 9 | 🔍 697 do migracji |
| spells | **191** | 191 | 766 | 🔍 191 do migracji |
| otclient_tools | **154** | 8 | 8 | 🔍 154 do migracji |
| cpp | **109** | 32 | 437 | 🔍 109 do migracji |
| server | **109** | 32 | 437 | 🔍 109 do migracji |
| otclient_src | **60** | 19 | 366 | 🔍 60 do migracji |
| startup | **36** | 3 | 20 | 🔍 36 do migracji |
| dataroot | **1** | 1 | 4 | 🔍 1 do migracji |
| npc | **1** | 1 | 1,028 | 🔍 1 do migracji |
| otclient_data | **1** | 1 | 183 | 🔍 1 do migracji |
| raids | **1** | 1 | 90 | 🔍 1 do migracji |
| actions | **0** | 0 | 200 | ✅ Czysta |
| chatchannels | **0** | 0 | 8 | ✅ Czysta |
| creaturescripts | **0** | 0 | 48 | ✅ Czysta |
| events | **0** | 0 | 4 | ✅ Czysta |
| globalevents | **0** | 0 | 16 | ✅ Czysta |
| movements | **0** | 0 | 53 | ✅ Czysta |
| npclib | **0** | 0 | 7 | ✅ Czysta |
| otclient_mods | **0** | 0 | 0 | ✅ Czysta |
| quests | **0** | 0 | 971 | ✅ Czysta |
| scripts | **0** | 0 | 2,259 | ✅ Czysta |
| talkactions | **0** | 0 | 88 | ✅ Czysta |
| world | **0** | 0 | 0 | ✅ Czysta |
| **SUMA** | **112,434** | **5,423** | **18,063** | 🔍 Wymaga pracy |

### 📋 Przykłady znalezionych tekstów (do migracji)
| Kategoria | Plik | Linia | Tekst (EN) | Wzorzec |
|-----------|------|-------|------------|---------|
| php | html_copy/admin/includes/debugbar.php | 3 | debugbar_admin_head_end | php.literal |
| php | html_copy/admin/includes/debugbar.php | 10 | vendor/maximebf/debugbar/src/DebugBar/Resources/ | php.literal |
| php | html_copy/admin/includes/debugbar.php | 13 | debugbar_admin_body_end | php.literal |
| monsters | data-canary/monster/amphibics/azure_frog.lua | 4 | an azure frog | monster.description |
| monsters | data-canary/monster/amphibics/azure_frog.lua | 78 | gold coin | monster.name |
| monsters | data-canary/monster/amphibics/azure_frog.lua | 79 | worm | monster.name |
| items | data/XML/attachedeffects.xml | 3 | 8 aura | xml.name |
| items | data/XML/attachedeffects.xml | 5 | Outfit - Rainbow | xml.name |
| items | data/XML/attachedeffects.xml | 6 | Outfit - Ghost | xml.name |
| html | html_copy/admin/pages/modules/templates/balance.html.twig | 5 | Top 10 - Balance | html.node_text |
| html | html_copy/admin/pages/modules/templates/coins.html.twig | 5 | Top 10 - Most coins | html.node_text |
| html | html_copy/admin/pages/modules/templates/coins.html.twig | 13 | Tibia coins | html.node_text |
| otclient_modules | testyy/modules/client/client.lua | 1 | sounds/startup | otui.literal.single |
| otclient_modules | testyy/modules/client/client.lua | 36 | gdi generic | otui.literal.single |
| otclient_modules | testyy/modules/client/client.lua | 51 | enableAudio | otui.literal.single |

### �🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **74,536** | wszystkie kategorie |
| 🧮 **Klucze wyekstrahowane (LIVE)** | **74,536** | realny stan `i18n/en/*.json` |
| 🤖 Klucze z rejestru workera (efektywne) | **74,536** | `5_extraction_en.keys_added` + reconcile |
| 🧾 Klucze z rejestru workera (raw) | **7** | suma `5_extraction_en.keys_added` |
| 🧩 Reconcile korekta rejestru | **74,529** | zmiany EN poza workerem |
| ➕ Klucze poza rejestrem workera | **0** | ręczne zmiany / starsze migracje |
| 📊 NPC | 14,815 | dialogi NPC |
| 📊 Items | 36,733 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 15,578 | scripts, spells, etc. |

## 🌍 TŁUMACZENIA

> **[TRANSLATION]** 🟢 AKTYWNY  
> Świeżość: 3min temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-04-30T20:23:25.574212Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Nominal % | Real % | Kopie EN | Placeholdery | Braki kluczy |
|-------|-----------|--------|----------|--------------|--------------|
| PL (Polski) | 84.19% (62,753/74,536) | 79.41% (59,187/74,536) | 5,023 | 10,352 | 0 |
| ES (Hiszpański) | 79.88% (59,540/74,536) | 69.00% (51,428/74,536) | 9,501 | 13,631 | 0 |
| IT (Włoski) | 72.13% (53,765/74,536) | 63.92% (47,640/74,536) | 10,029 | 16,892 | 0 |
| RO (Rumuński) | 69.89% (52,091/74,536) | 56.93% (42,436/74,536) | 12,941 | 19,184 | 0 |
| RU (Rosyjski) | 46.46% (34,633/74,536) | 44.90% (33,463/74,536) | 4,775 | 36,316 | 0 |
| FR (Francuski) | 57.51% (42,864/74,536) | 41.87% (31,206/74,536) | 26,153 | 17,199 | 0 |
| CS (Czeski) | 52.20% (38,910/74,536) | 34.78% (25,922/74,536) | 29,600 | 19,040 | 0 |
| PT (Portugalski) | 81.19% (60,516/74,536) | 32.91% (24,530/74,536) | 48,839 | 1,189 | 0 |
| TR (Turecki) | 36.12% (26,920/74,536) | 32.62% (24,317/74,536) | 3,838 | 46,395 | 0 |
| SR (SR) | 33.31% (24,827/74,536) | 32.04% (23,885/74,536) | 1,218 | 28,698 | 20,793 |
| NL (Niderlandzki) | 77.57% (57,814/74,536) | 31.96% (23,823/74,536) | 49,478 | 1,260 | 0 |
| DE (Niemiecki) | 69.78% (52,013/74,536) | 12.94% (9,648/74,536) | 63,673 | 1,240 | 0 |
| BN (BN) | 6.42% (4,787/74,536) | 2.57% (1,912/74,536) | 3,991 | 47,898 | 20,793 |
| AR (Arabski) | 6.25% (4,662/74,536) | 2.42% (1,804/74,536) | 3,974 | 48,023 | 20,793 |
| LT (LT) | 4.84% (3,606/74,536) | 2.22% (1,654/74,536) | 2,792 | 49,355 | 20,793 |
| FA (FA) | 6.25% (4,661/74,536) | 2.12% (1,578/74,536) | 4,199 | 48,024 | 20,793 |
| HI (HI) | 5.76% (4,294/74,536) | 1.95% (1,450/74,536) | 3,960 | 48,391 | 20,793 |
| ID (ID) | 5.75% (4,287/74,536) | 1.87% (1,397/74,536) | 4,006 | 48,398 | 20,793 |
| AZ (AZ) | 4.71% (3,511/74,536) | 1.84% (1,375/74,536) | 2,997 | 49,429 | 20,793 |
| BG (BG) | 4.70% (3,502/74,536) | 1.84% (1,374/74,536) | 3,019 | 49,408 | 20,793 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** DE - Niemiecki - Serwer
- **Plik JSON:** npc.json
- **Ostatnie klucze (10-20):** 0

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- Brak nowych tłumaczeń w ostatnim cyklu

### 🚫 Raporty strażnika jakości
- Raporty strażnika jakości: **5108**  
- Raporty blokad: **0**  
- Widoczne raporty 'nie mogę przetłumaczyć': **4960**

### 🧱 Blockers snapshot (strict)
| State | Candidates | Missing files | Missing keys | Reason | Timestamp |
|-------|------------|---------------|--------------|--------|-----------|
| 🟠 active | 96 | 0 | 0 | - | 2026-04-30T20:25:43.415574Z |

### 🌐 Globalne info wszystkich języków
- **Pokrycie globalne (nominal):** **18.41%** (713,734/3,875,872)
- **Pokrycie globalne (real):** **11.37%** (440,743/3,875,872)
- **Kopie EN (łącznie):** **407,955**
- **Placeholdery [EN]/puste (łącznie):** **2,173,052**
- **Referencje `#i18n:` (łącznie):** **7,969**
- **Braki kluczy (łącznie):** **856,235**
- **Brakujące pliki językowe:** **11**
- **Cache STATUSPY (per-lang):** **warm-cache** | hit **52**, miss **0**, hit-rate **100.0%**
- **Cache STATUSPY (per-file):** hit **2028**, miss **0**, hit-rate **100.0%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 📌 KPI backlog `[EN]` (HU/SK/TR)
| Język | Backlog `[EN]` | EN kluczy | Udział backlogu |
|-------|----------------|-----------|-----------------|
| HU | 49,854 | 74,536 | 66.89% |
| SK | 49,937 | 74,536 | 67.00% |
| TR | 46,395 | 74,536 | 62.25% |

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **70,637** |
| 📦 **Instalka** (klient/OTClient) | **3,899** |

| Język | Serwer | Serwer % (nominal/real) | Instalka | Instalka % (nominal/real) |
|-------|--------|--------------------------|----------|----------------------------|
| PL | 59,605/70,637 | 84.4% / 79.5% | 3,148/3,899 | 80.7% / 78.4% |
| ES | 56,380/70,637 | 79.8% / 68.4% | 3,160/3,899 | 81.0% / 79.2% |
| IT | 50,792/70,637 | 71.9% / 63.4% | 2,973/3,899 | 76.2% / 73.1% |
| RO | 49,305/70,637 | 69.8% / 56.2% | 2,786/3,899 | 71.5% / 69.6% |
| RU | 31,489/70,637 | 44.6% / 43.0% | 3,144/3,899 | 80.6% / 79.3% |
| FR | 39,937/70,637 | 56.5% / 40.1% | 2,927/3,899 | 75.1% / 73.7% |
| CS | 37,220/70,637 | 52.7% / 34.5% | 1,690/3,899 | 43.3% / 39.0% |
| PT | 58,449/70,637 | 82.8% / 32.0% | 2,067/3,899 | 53.0% / 50.0% |
| TR | 24,961/70,637 | 35.3% / 31.7% | 1,959/3,899 | 50.2% / 48.7% |
| SR | 24,726/70,637 | 35.0% / 33.7% | 101/3,899 | 2.6% / 2.3% |
| NL | 55,803/70,637 | 79.0% / 31.1% | 2,011/3,899 | 51.6% / 47.2% |
| DE | 50,043/70,637 | 70.8% / 11.0% | 1,970/3,899 | 50.5% / 47.5% |

### 🌐 Launcher/WWW per język (nominal% / real%)
| Język | `html.json` | `php.json` | `client.json` | `otclient_modules.json` |
|-------|-------------|------------|---------------|-------------------------|
| PL | 53.5% / 53.4% | 81.4% / 78.0% | 92.6% / 90.1% | 98.7% / 94.9% |
| ES | 55.1% / 55.0% | 81.4% / 79.7% | 94.2% / 91.7% | 98.0% / 94.8% |
| IT | 55.2% / 55.0% | 83.0% / 79.7% | 90.9% / 88.4% | 89.0% / 83.7% |
| RO | 54.4% / 54.1% | 71.2% / 66.1% | 85.1% / 82.6% | 81.5% / 78.6% |
| RU | 65.5% / 65.4% | 79.7% / 76.3% | 99.2% / 96.7% | 88.9% / 86.8% |
| FR | 49.4% / 49.2% | 74.6% / 69.5% | 82.6% / 80.2% | 92.3% / 90.2% |
| CS | 39.6% / 39.3% | 69.5% / 64.4% | 74.4% / 71.9% | 40.3% / 32.7% |
| PT | 40.5% / 40.2% | 62.7% / 57.6% | 71.1% / 68.6% | 58.6% / 53.6% |
| TR | 56.0% / 56.0% | 93.2% / 88.1% | 93.4% / 90.9% | 37.9% / 35.4% |
| SR | 0.0% / 0.0% | 0.0% / 0.0% | 21.1% / 19.4% | 2.5% / 2.0% |
| NL | 39.5% / 39.2% | 71.2% / 66.1% | 80.6% / 78.1% | 55.3% / 47.9% |
| DE | 37.4% / 37.1% | 66.1% / 61.0% | 77.7% / 75.2% | 55.6% / 50.6% |
| BN | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| AR | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| LT | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| FA | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| HI | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| ID | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| AZ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| BG | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| KO | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| HE | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| JA | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| ML | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| EL | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| MK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| ET | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| HR | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| KK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| KA | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| HY | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| LV | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| MS | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| SQ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| DA | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| FI | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| HU | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| TE | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| TH | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| SW | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| TA | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| NO | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| SK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| SL | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| UZ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| UK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| VI | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| SV | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| BS | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| TL | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |
| ZH | 0.3% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% |

### 🌐 Network surface parity (real coverage + delta 24h)
| Metryka | Wartość |
|---------|---------|
| 🕸️ Surfaces | 4 (`server/website/launcher/installer`) |
| 🥇 Best | Launcher 18.31% |
| 🥉 Worst | Website 10.85% |
| ↕️ Spread | 7.46 pp |
| 📉 Largest regression 24h | Launcher (+0.00 pp) |
| 🕒 Window | 24h, samples=203 |

| Rank | Surface | Real coverage | Δ24h | Langs | Regression focus (lowest langs) |
|------|---------|---------------|------|-------|----------------------------------|
| #1 | 🔴 Launcher | 18.31% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #2 | 🔴 Installer | 14.73% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #3 | 🔴 Server | 11.47% | +0.07 pp | 51 | ZH 0.2%, TL 0.8%, BS 0.9% |
| #4 | 🔴 Website | 10.85% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |

> Źródła: `surface_parity_latest.json`, `surface_parity_report.jsonl`, `translation_global_overview.json`

### ✅ Launcher 100% readiness contract
| Metryka | Wartość |
|---------|---------|
| ✅ Contract state | `🟡 IN_PROGRESS` |
| 🧪 Checks passed | 1/4 |
| 🌍 Production langs | PL, DE, AR |
| 📄 Claim table open tasks | B23-02 |
| 🚫 Failed checks | tasks_closed_claim_table, doctor_alerts_clean_3_waves, bridge_consistency_prod_langs |
| 🕒 Evidence window | 24h (span=24.03h) |
| 🧠 Recommendation | Domknij check: tasks_closed_claim_table |

| Check | Status | Detail |
|-------|--------|--------|
| Claim table `B23-02..B23-08` | ❌ FAIL | open dependencies: B23-02; contract B23-08=🟢 in_progress (2026-04-23, 90%) |
| 3 launcher waves bez stale alerts | ❌ FAIL | insufficient/dirty waves (0/3); recent=- |
| Trend 24h `identical_to_en` + `word_salad` | ✅ PASS | window=24.03h; client.json: id=+0.00pp, ws=+0, otclient_modules.json: id=+0.00pp, ws=+0 |
| Bridge launcher-rust (`missing=0`, `extra=0`) | ❌ FAIL | failed langs: AR |

> Źródła: `launcher_readiness_latest.json`, `launcher_readiness_report.jsonl`, `launcher_quality_gate_latest.json`, `translation_dispatch_state.json`, `doctor_alerts_latest.json`, `docs/i18n/launcher_rust_bridge_apply_latest.json`

### ⏱️ Ścisłe okno godzinowe (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-04-30T19:26:36.383776Z → 2026-04-30T20:26:36.383776Z) |
| Cykle | **60** (TŁUMACZENIE=60, PRE_MIGRATION=0) |
| Pominięte (kat. nieaktywna) | **0** (ogółem=0.0%, migracja=0.0%) |
| Odrzucone (strażnik jakości) % | **1.0%** |
| Cykle bez postępu % | **0.0%** |
| Przepustowość (kluczy/h) | **1088.0 kluczy/h** |
| Podejrzane tłumaczenia | **2385** |
| Najgorsze cele (strażnik) | de/npc.json (gf=7), ru/items.json (gf=4), es/items.json (gf=0), tr/items.json (gf=0), cs/items.json (gf=0) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl`, `i18n/status/deferred_translation_queue.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

### 🚫 Odrzucenia wg reason (1h)
| Reason | Odrzucone | Udział | TOP język/plik |
|--------|-----------|--------|----------------|
| `existing_canonical_name_quality_cyrillic_latin_mix` | 57 | 87.7% | ru/items.json (57) |
| `existing_canonical_name_quality_mixed_scripts` | 7 | 10.8% | ru/items.json (7) |
| `gt_partial_validate_word_salad` | 1 | 1.5% | de/npc.json (1) |

## 🔬 JAKOŚĆ TŁUMACZEŃ

> **[QUALITY]** 🔒 NIEAKTYWNY (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 1min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-04-30T20:25:17.412749Z

- **Ostatni audyt:** OK | 0 issue(s) / 100 entries | 2026-04-30T20:25:17.412749Z
- **Top 5 typów problemów:** suspicious_log_low=148, suspicious_rejected_critical=146, suspicious_rejected_high=54, suspicious_log_high=50, suspicious_log_critical=1
- **Języki o najsłabszej jakości:** es(60.1, issues=758326), ro(60.1, issues=452565), ru(60.1, issues=381677), de(60.1, issues=135265), cs(60.1, issues=133489)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#29** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **74,536** | realny stan EN |
| 🤖 Kluczy z rejestru workera (efektywne) | **74,536** | raw + reconcile |
| 🧾 Kluczy z rejestru workera (raw) | **7** | historia runów workera |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## ⚠️ Problemy i uwagi

⚠️ **TR**: jakość 60%, 60672 problemów
⚠️ **PL**: jakość 65%, 389619 problemów
⚠️ **AZ**: jakość 70%, 1417 problemów
⚠️ **ES**: jakość 60%, 758326 problemów
⚠️ **PT**: jakość 91%, 57675 problemów
⚠️ **FR**: jakość 60%, 60621 problemów
⚠️ **IT**: jakość 68%, 181781 problemów
⚠️ **RU**: jakość 60%, 381677 problemów
⚠️ **NL**: jakość 94%, 72797 problemów
⚠️ **SV**: jakość 74%, 68647 problemów

---

## 📜 Ostatnie komendy

- Brak dostępnych komend.

---

## 🏥 Zdrowie systemu

| Komponent | Status | Szczegóły |
|-----------|--------|-----------|
| Worker | 🟢 DZIAŁA | Cykl #19,011 |
| Heartbeat | 83s temu | 2026-04-30T20:25:18Z |
| Uptime | - | od startu workera |

---

## � Kolejka napraw (kopie EN)

- **Łącznie kopii EN do naprawy:** 733
- **TOP 5 języków:** DE (18,776), CS (15,153), NL (14,061), FR (13,129), PT (11,471)
- **Aktualnie naprawia:** ES / -
- **Ostatnia aktualizacja:** 2026-04-30T20:23:40.798364Z

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** AUTO_TRANSLATE  
> **Aktualna kategoria:** de


### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | ✅ | 14815/15000 (99%) | 15000 |
| 📜 Lua Scripts | 🔄 | 2170/2500 (87%) | 2500 |
| 🎒 Items Database | ✅ | 36733/40000 (92%) | 40000 |
| 👹 Monsters | ✅ | 5915/6000 (99%) | 6000 |
| ✨ Spells & Magic | 🔄 | 1534/2000 (77%) | 2000 |
| ⚙️ Server C++ | 🔄 | 2574/3000 (86%) | 3000 |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | 🔄 | 59/3000 (2%) | 3000 |
| 📄 HTML Views | ✅ | 1495/1500 (100%) | 1500 |
| 📦 JavaScript | 🔄 | 242/300 (81%) | 300 |

### ⏳ Faza 3: 📱 OTClient / Testyy

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | ⏳ | 0/200 (0%) | 200 |
| 💿 Server C++ | ✅ | 879/900 (98%) | 900 |
| 🎮 OTClient Modules | 🔄 | 2031/2500 (81%) | 2500 |
| 📦 OTClient Data | 🔄 | 72/200 (36%) | 200 |
| ⚙️ OTClient Src | ⏳ | 0/300 (0%) | 300 |
| 🔧 OTClient Mods | ⏳ | 0/100 (0%) | 100 |
| 🛠️ OTClient Tools | ⏳ | 0/50 (0%) | 50 |

### ⏳ Faza 4: 🌍 Tłumaczenia (Etap 1: Sync Kluczy)

| Język | Status | Kluczy | Etap |
|-------|--------|--------|------|
| 🇩🇪 Niemiecki | ✅ Sync | 3641 | [EN] prefix |
| 🇵🇱 Polski | ✅ Sync | 61066 | [EN] prefix |
| 🇪🇸 Hiszpański | ✅ Sync | 55189 | [EN] prefix |
| 🇫🇷 Francuski | ✅ Sync | 40374 | [EN] prefix |
| 🌐 Pozostałe (11/53) | 🔄 | 810030 | Aktualnie: TR |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 52/53
- Ostatni sync: TR/arena.json

### 🌍 Etap 2: Tłumaczenia (AUTO)
| Język | TM wpisy | Status |
|-------|----------|--------|
| DE | 55 | ✅ TM |
| ES | 55 | ✅ TM |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 424 | ✅ TM |
| PT | 55 | ✅ TM |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 0 | ⚠️ placeholdery (brak TM) |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 582 | ✅ TM |

**Języki bez TM (AUTO → placeholdery):** ar, az, bg, bn, bs, cs, da, el...
---

## 🔴 LIVE: Szczegóły wykonania

> **[LIVE]** 🟢 AKTYWNY  
> Świeżość: 1min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-04-30T20:25:18Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #19,011 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 DZIAŁA                                 │
│ Tryb:      🤖 AUTO_TRANSLATE (heartbeat_tick)        │
│ Kategoria: 📁 DE                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: npc.json                                                │
│ Postęp: batch: 30 keys/cykl                                   │
│ Info: auto translate in progress                              │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-04-30T20:25:18Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-04-30 20:25:44 | AUTO_TRANSLATE:heartbeat_tick | de | ok | npc.json
- 2026-04-30 20:25:43 | AUTO_TRANSLATE:auto_start | de | ok | npc.json
- 2026-04-30 20:25:09 | AUTO_TRANSLATE:heartbeat_tick | es | ok | server.json
- 2026-04-30 20:23:41 | AUTO_TRANSLATE:heartbeat_tick | es | ok | server.json
- 2026-04-30 20:23:25 | AUTO_TRANSLATE:auto_done | es | ok | items.json
- 2026-04-30 20:22:52 | AUTO_TRANSLATE:heartbeat_tick | es | ok | items.json

---

## 📊 Wskaźniki KPI — Zdrowie Pilotów (PL/ES)

| Język | Pokrycie | Brakujące | Kopie EN | Przetłumaczone(200) | Odrzucone | Wpisy |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟢 PL | 84.2% | 0 | 5,023 | 0 | 0 (0.0%) | 0 |
| 🟡 ES | 79.9% | 0 | 9,501 | 1,124 | 0 (0.0%) | 25 |

| Wskaźnik | Wartość | Cel | Status |
|-----|---------|--------|--------|
| Tłumaczeń netto | **156,325** | — | 📊 |
| Adaptacyjna paczka | batch=50, gf_rate=0.71%, reason=increase_low_fail_rate=0.7%, filter=exclude_repair | odrzucenia <5% → zwiększ | 📊 |
| Przepustowość (okno) | 1,124 kluczy / 25 wpisów | >50/h | 📊 |

---

## 📜 HISTORIA

> **[HISTORY]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-04-30 20:26:36

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ro] → warn (files+1, translated+60, skipped+0) — lang=ro file=items.json strict_skipped_done=1665
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+22, skipped+0) — lang=es file=items.json strict_skipped_done=2027
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+4) — repair_identical lang=es file=npc.json target_identical=2 limit=108 tier=low_backlog+suspicious_guard domain_cap=260 gt=true suspicious_pct=218.18
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+18, skipped+0) — lang=es file=items.json strict_skipped_done=1322
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+6) — repair_identical lang=es file=npc.json target_identical=2 limit=108 tier=low_backlog+suspicious_guard domain_cap=260 gt=true suspicious_pct=240.21
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → warn (files+1, translated+34, skipped+0) — lang=de file=npc.json strict_skipped_done=75 guard_fail=1 placeholder=0 command=0 pipe=0
- • DOCTOR_REMEDIATION: ALARM_RESOLVED [-] → ok — resolved_count=1
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+1) — repair_identical lang=es file=quests.json target_identical=1 limit=180 tier=low_backlog domain_cap=180 gt=true suspicious_pct=100.00
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+20, skipped+0) — lang=es file=monsters.json strict_skipped_done=5885 guard_fail=2 placeholder=0 command=0 pipe=0
- • DOCTOR_REMEDIATION: ALARM_RESOLVED [-] → ok — resolved_count=1


## 📅 Dziś (2026-04-30)

| Metryka | Wartość |
|---------|---------|
| ✅ Przetłumaczono | **2,196** kluczy |
| ⏭️ Pominięte | 0 |
| 🔁 Cykli | 28 |
| ❌ Błędów | 40 |
| 🌍 Aktywnych języków | 7 |
| 🏆 TOP 5 | **CS** (472), **DE** (356), **IT** (340), **RU** (323), **ES** (314) |
| 📊 Porównanie | ↓ 87.2% vs wczoraj (17,153) |

## 📆 Ten tydzień (7 dni)

> Suma tygodnia: **32,765** kluczy

| Dzień | Wykres | Przetłumaczono | Cykli |
|-------|--------|---------------|-------|
| 2026-04-24 | ░ | 0 | 0 |
| 2026-04-25 | ░ | 0 | 0 |
| 2026-04-26 | ░ | 0 | 0 |
| 2026-04-27 | ██████████████████████████████████████████████████ | 5,188 | 19 |
| 2026-04-28 | ██████████████████████████████████████████████████ | 8,228 | 128 |
| 2026-04-29 | ██████████████████████████████████████████████████ | 17,153 | 216 |
| 2026-04-30 | ██████████████████████████████████████████████████ | 2,196 | 28 |

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych (LIVE registry) | **15** | z `i18n_file_status.json` |
| 📚 Plików przeskanowanych (historia) | **6,443** | z `i18n_processed_files.txt` |
| ↕️ Historia minus LIVE | **+6,428** | dodatnie = historia > LIVE |
| ✅ Plików z kluczami | **7** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **8** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych (LIVE) | **74,536** | realny stan `i18n/en/*.json` |
| 🤖 Kluczy wyciągniętych przez workera (efektywne) | **74,536** | raw + reconcile |
| 🧾 Kluczy wyciągniętych przez workera (raw) | **7** | z `i18n_file_status.json` |
| 🧩 Reconcile korekta rejestru | **74,529** | zmiany EN poza workerem |
| ➕ Kluczy poza rejestrem workera | **0** | ręczne/Codex/Claude/starsze |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#19,011** | continuous mode |

---

## 📂 Szczegóły Kategorii

<details>
<summary>🎮 1. Game - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 100 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/game.json |

</details>

<details>
<summary>🎒 2. Items - ✅ (92%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 36733 |
| 🎯 Cel | 40000 |
| 📊 Postęp | 92% |
| 📁 Plik | i18n/en/items.json |

</details>

<details>
<summary>📦 3. Misc - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 100 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/misc.json |

</details>

<details>
<summary>👹 4. Monsters - ✅ (99%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 5915 |
| 🎯 Cel | 6000 |
| 📊 Postęp | 99% |
| 📁 Plik | i18n/en/monsters.json |

</details>

<details>
<summary>🧙 5. NPC - ✅ (99%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 14815 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 99% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | 1028 |
| ✅ Zmigrowanych | 700 |
| 🔄 Do migracji | 0 |

</details>

<details>
<summary>👤 6. Player - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 200 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/player.json |

</details>

<details>
<summary>📜 7. Quests - 🔄 (87%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 610 |
| 🎯 Cel | 700 |
| 📊 Postęp | 87% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - 🔄 (87%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 2170 |
| 🎯 Cel | 2500 |
| 📊 Postęp | 87% |
| 📁 Plik | i18n/en/scripts.json |

</details>

<details>
<summary>⚙️ 9. Server - 🔄 (86%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 2574 |
| 🎯 Cel | 3000 |
| 📊 Postęp | 86% |
| 📁 Plik | i18n/en/server.json |

</details>

<details>
<summary>✨ 10. Spells - 🔄 (77%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 1534 |
| 🎯 Cel | 2000 |
| 📊 Postęp | 77% |
| 📁 Plik | i18n/en/spells.json |

</details>

<details>
<summary>🖥️ 11. System - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 2000 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/system.json |

</details>

<details>
<summary>🎨 12. UI - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 200 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/ui.json |

</details>

---

## 📊 Wszystkie Kategorie JSON (Dynamiczne)

| Kategoria | Kluczy | Przetworzono | Seria zer | Status |
|-----------|--------|--------------|-----------|--------|
| items | 36733 | 0 | 0 | ✅ Active |
| npc | 14815 | 0 | 0 | ✅ Active |
| monsters | 5915 | 0 | 0 | ✅ Active |
| server | 2574 | 0 | 0 | ✅ Active |
| scripts | 2170 | 0 | 0 | ✅ Active |
| otclient_modules | 2031 | 0 | 0 | ✅ Active |
| questlog | 1918 | 0 | 0 | ✅ Active |
| spells | 1534 | 0 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| books | 1403 | 0 | 0 | ✅ Active |
| achievements | 1048 | 0 | 0 | ✅ Active |
| cpp | 879 | 0 | 0 | ✅ Active |
| quests | 610 | 0 | 0 | ✅ Active |
| raids | 273 | 0 | 0 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
| talkactions | 199 | 0 | 0 | ✅ Active |
| arena | 184 | 0 | 0 | ✅ Active |
| npclib | 147 | 0 | 0 | ✅ Active |
| libs | 89 | 0 | 0 | ✅ Active |
| otclient_data | 72 | 0 | 0 | ✅ Active |
| php | 59 | 0 | 0 | ✅ Active |
| actions | 35 | 0 | 0 | ✅ Active |
| startup | 23 | 0 | 0 | ✅ Active |
| modules | 19 | 0 | 0 | ✅ Active |
| chatchannels | 16 | 0 | 0 | ✅ Active |
| events | 14 | 0 | 0 | ✅ Active |
| example_merchant | 14 | 0 | 0 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| globalevents | 5 | 0 | 0 | ✅ Active |
| creaturescripts | 4 | 0 | 0 | ✅ Active |
| dataroot | 3 | 0 | 0 | ✅ Active |
| movements | 2 | 0 | 0 | ✅ Active |
| errors | 0 | 0 | 0 | ⏳ Empty |
| mounts | 0 | 0 | 0 | ⏳ Empty |
| otclient_mods | 0 | 0 | 0 | ⏳ Empty |
| otclient_src | 0 | 0 | 0 | ⏳ Empty |
| otclient_tools | 0 | 0 | 0 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 0 | ⏳ Empty |

---

## 🤖 Stan kategorii workera

*Brak kategorii z aktywnym skip*

---

## 🔧 Worker i Guardian

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 DZIAŁA | Cykl #19,011 |
| Guardian v2.0 | 🟢 AKTYWNY | Push co 2 min |

---

## 🌍 Tłumaczenia - Etap 1: Synchronizacja Kluczy

| Język | Kluczy | Status |
|-------|--------|--------|
| DE | 0 | ⏳ |
| PL | 0 | ⏳ |
| ES | 0 | ⏳ |
| PT | 0 | ⏳ |
| FR | 0 | ⏳ |
| IT | 0 | ⏳ |
| NL | 0 | ⏳ |
| CS | 0 | ⏳ |
| SK | 0 | ⏳ |
| HU | 0 | ⏳ |

> **Aktualnie:** IDLE / -  
> **Ukończone języki:** 0/53  
> **Prefix:** `[EN] ` (klucze do przetłumaczenia)

---

## ⚡ System tierów (Sekcja 5)

| Tier | Języki | Waga | Cel pokrycia |
|------|--------|------|-------------|
| **Tier 1** | es, pl | ×4 | 90% |
| **Tier 2** | cs, de, fr, hu, it, nl, pt, ro, ru, sk, tr | ×3 | 50% |
| **Tier 3** | reszta (39) | ×1 | 30% |

**Priorytet kategorii:** items → npc → monsters → server → spells → quests → scripts → actions → raids

> Tier 1 przetwarza 4 pliki per super-rundę, Tier 2 przetwarza 2, Tier 3 przetwarza 1.


---

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
| 🏆 Achievements | 1048 | ████████████████████ | 1048 | ✅ 100% |
| ⚡ Actions | 35 | ███████░░░░░░░░░░░░░ | 100 | 🔄 35% |
| 📁 Arena | 184 | ████████████████████ | 184 | ✅ 100% |
| 📖 Books | 1403 | ████████████████████ | 1403 | ✅ 100% |
| 💬 Chatchannels | 16 | ███░░░░░░░░░░░░░░░░░ | 100 | 🔄 16% |
| 🖥️ Client | 242 | ████████████████░░░░ | 300 | 🔄 81% |
| ⚙️ Cpp | 879 | ███████████████████░ | 900 | ✅ 98% |
| 🐾 Creaturescripts | 4 | ░░░░░░░░░░░░░░░░░░░░ | 100 | 🔄 4% |
| 📂 Dataroot | 3 | ░░░░░░░░░░░░░░░░░░░░ | 100 | 🔄 3% |
| ❌ Errors | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |
| 🎉 Events | 14 | ██░░░░░░░░░░░░░░░░░░ | 100 | 🔄 14% |
| 📁 Example_merchant | 14 | ██░░░░░░░░░░░░░░░░░░ | 100 | 🔄 14% |
| 🌐 Globalevents | 5 | █░░░░░░░░░░░░░░░░░░░ | 100 | 🔄 5% |
| 🌍 Html | 1495 | ███████████████████░ | 1500 | ✅ 100% |
| 🎒 Items | 36733 | ██████████████████░░ | 40000 | ✅ 92% |
| 📚 Libs | 89 | █████████████████░░░ | 100 | 🔄 89% |
| ✉️ Messages | 11 | ██░░░░░░░░░░░░░░░░░░ | 100 | 🔄 11% |
| 📦 Modules | 19 | ███░░░░░░░░░░░░░░░░░ | 100 | 🔄 19% |
| 👹 Monsters | 5915 | ███████████████████░ | 6000 | ✅ 99% |
| 🐴 Mounts | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |
| 🚶 Movements | 2 | ░░░░░░░░░░░░░░░░░░░░ | 100 | 🔄 2% |
| 🧙 Npc | 14815 | ███████████████████░ | 15000 | ✅ 99% |
| 📜 Npclib | 147 | ████████████████████ | 147 | ✅ 100% |
| 📊 Otclient_data | 72 | ███████░░░░░░░░░░░░░ | 200 | 🔄 36% |
| 🔧 Otclient_mods | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |
| 🧩 Otclient_modules | 2031 | ████████████████░░░░ | 2500 | 🔄 81% |
| 💻 Otclient_src | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🛠️ Otclient_tools | 0 | ░░░░░░░░░░░░░░░░░░░░ | 50 | ⏳ 0% |
| 🐘 Php | 59 | ░░░░░░░░░░░░░░░░░░░░ | 3000 | 🔄 2% |
| 📋 Questlog | 1918 | ████████████████████ | 1918 | ✅ 100% |
| 🗡️ Quests | 610 | █████████████████░░░ | 700 | 🔄 87% |
| ⚔️ Raids | 273 | ████████████████████ | 273 | ✅ 100% |
| 📜 Scripts | 2170 | █████████████████░░░ | 2500 | 🔄 87% |
| 🖧 Server | 2574 | █████████████████░░░ | 3000 | 🔄 86% |
| ✨ Spells | 1534 | ███████████████░░░░░ | 2000 | 🔄 77% |
| 🚀 Startup | 23 | ████░░░░░░░░░░░░░░░░ | 100 | 🔄 23% |
| 🗣️ Talkactions | 199 | ████████████████████ | 199 | ✅ 100% |
| 🎨 Ui | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |
| 🌎 World | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2026-04-30 20:26:36  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `items_classification.hpp` - ukończono 2026-02-14 14:43
- ✅ `pch.hpp` - ukończono 2026-02-14 14:43
- ✅ `canary_server.cpp` - ukończono 2026-02-14 14:43
- ✅ `account.cpp` - ukończono 2026-02-14 14:43
- ✅ `account_info.hpp` - ukończono 2026-02-14 14:43
- ✅ `account_repository_db.hpp` - ukończono 2026-02-14 14:43
- ✅ `account.hpp` - ukończono 2026-02-14 14:43
- ✅ `pch.cpp` - ukończono 2026-02-14 14:43
- ✅ `game_definitions.hpp` - ukończono 2026-02-14 14:43
- ✅ `zone.hpp` - ukończono 2026-02-14 14:43

---

## 🚀 Jak uruchomić

```bash
# Pojedynczy plik
./i18n_worker_simple.sh --file data-otservbr-global/npc/nazwa.lua

# Status lokalny
./i18n_worker_simple.sh --status

# Auto migracja (5 plików)
./i18n_worker_simple.sh --auto 5

# Aktualizuj I18N_STATUS.md
./i18n_worker_simple.sh --update-status
```

---

*Wygenerowano automatycznie przez i18n_worker_simple.sh v1.1*

---

## 🏷️ Legenda

| Symbol | Znaczenie |
|--------|-----------|
| 🟢 | Aktywny / OK |
| 🔴 | Nieaktywny / błąd |
| 🟡 | Uwaga / ostrzeżenie |
| 🔒 | Sekcja wyłączona |
| ✅ | Zakończone / gotowe |
| ⚠️ | Wymaga uwagi |
| ██░░ | Pasek postępu (wypełniony/pusty) |
| **DZIAŁA** | Worker jest aktywny i przetwarza |
| **BEZCZYNNY** | Worker czeka na następny cykl |
| **NIEAKTYWNY** | Sekcja/moduł wyłączony |
| **ZATRZYMANY** | Worker został zatrzymany sygnałem |
| **Tier 1** | Języki priorytetowe: ES, PL, PT-BR, DE, FR |
| **Tier 2** | Języki średnio-priorytetowe (10 języków) |
| **Tier 3** | Pozostałe języki |
| **GF%** | Guard Fail Rate — % odrzuconych tłumaczeń |
| **Kopie EN** | Klucze z tłumaczeniem identycznym do EN |
| **TM** | Translation Memory — pamięć tłumaczeń |
| **GT** | Google Translate — tłumaczenie maszynowe |
