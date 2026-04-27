# 🌍 System Tłumaczeń I18N — Dashboard na żywo

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'arena': 184, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 📝 PODSUMOWANIE

> Worker tłumaczy **53** języków. Klucze EN: **74,536**. Pokrycie globalne: **nominal 17.65% / real 10.53%**. Tempo: **300.6 kluczy/h**. Tłumaczeń netto: **126,238**.

## 🧭 META

> **[META]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-04-27 15:57:32

> **Aktualizacja:** 2026-04-27 15:57:32 UTC
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 74536
> **Publikacja:** git-enabled
> **LIVE:** Cykl #16,378 | Status: 🟢 DZIAŁA | Faza: AUTO_TRANSLATE | Etap: auto_done | Kategoria: pt | Plik: server.json | Heartbeat: 2026-04-27T15:56:22Z  
> **Okno godzinowe:** okno=1.0h | cykli=50 | pominięte=0.0% | odrzucone=24.2% | przepustowość=300.6/h  
> **Tłumaczeń netto:** 126,238

### 🧩 Status sekcji
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 AKTYWNY | teraz | - | `update_github_status()` | 2026-04-27 15:57:32 |
| LIVE | 🟢 AKTYWNY | 1min temu | - | `activity.json / worker_state.json` | 2026-04-27T15:56:22Z |
| PRE_MIGRATION | 🔒 NIEAKTYWNY | 1min temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-04-27 15:57:32 |
| TRANSLATION | 🟢 AKTYWNY | 16s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-04-27T15:57:29.110440Z |
| QUALITY | 🔒 NIEAKTYWNY | 1min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-04-27T15:56:21.875389Z |
| HISTORY | 🟢 AKTYWNY | teraz | - | `daily/*.json / ops.jsonl` | 2026-04-27 15:57:32 |
| DOCTOR | 🟠 AKTYWNY | 0s temu | 1 alarmów | `doctor_alerts_latest.json` | 2026-04-27T15:57:45.113768Z |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🤖 Worker Live

> **[LIVE]** 🟢 AKTYWNY  
> Świeżość: 1min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-04-27T15:56:22Z

| Metryka | Wartość |
|---------|---------|
| 🛠️ **Co robi** | Tłumaczenie automatyczne (Google Translate + TM) → zakończone |
| 🌍 **Aktywne języki (10 min)** | ES, NL, PT, TR |
| 📝 **Faza** | AUTO_TRANSLATE |
| 📋 **Etap** | tłumaczenie zakończone |
| 📂 **Kategoria / Język** | pt |
| 📄 **Plik** | server.json |
| 🧭 **Surface** | Serwer |
| 📊 **Status** | 🟢 DZIAŁA |
| 📈 **Postęp** | ██████████░░░░░░░░░░ 10/20 keys (50.0%) |
| 🔧 **Metoda** | Google Translate + TM fallback |
| 🧠 **Detail** | auto translate in progress |
| 🔑 **Current key** | `tr:spells.json` |
| 🔄 **Ostatni cykl** | 10 kluczy, 28 odrzuconych, 0s, tryb: AUTO_TRANSLATE, cel: pt/server.json |
| ❤️ **Heartbeat** | 2026-04-27T15:56:22Z |

**Ostatnie operacje:**
- → AUTO_TRANSLATE_DONE (PT) [warn]
- → AUTO_TRANSLATE_DONE (TR) [warn]
- → REPAIR_IDENTICAL_DONE (ES) [ok]
- → AUTO_TRANSLATE_DONE (NL) [warn]
- → AUTO_TRANSLATE_DONE (PT) [warn]

---

## ✍️ Recent Writes

| Czas UTC | Lang | Surface | Plik | Count | Source | Sample key | Sample |
|----------|------|---------|------|-------|--------|------------|--------|
| 15:57:25 | PT | Serwer | server.json | 10 | `google_translate` | `data.otservbr.global.npc.noodles.L105.679` | <sniff> Uau! <sniff> |
| 15:56:14 | TR | Serwer | spells.json | 2 | `-` | `-` | - |
| 15:55:29 | ES | Serwer | server.json | 3 | `google_translate` | `data.otservbr.global.npc.noodles.L105.679` | <sniff> ¡Guau! <sniff> |
| 15:53:27 | NL | Serwer | monsters.json | 42 | `openai:openai/gpt-4o-...` | `monster.corym_charlatan.desc` | een corym charlatan |
| 15:51:20 | PT | Serwer | monsters.json | 37 | `simple` | `monster.apprentice_sheng.voice_8` | Você já sabe demais. |
| 15:49:56 | ES | Serwer | npc.json | 5 | `openai:openai/gpt-4o-...` | `npc.a_beggar.say_6` | Lo pensé. Tendrás que hablar con el rey, sin embargo. El rey mendigo, quiero decir. E... |
| 15:47:27 | TR | Serwer | monsters.json | 27 | `term_consistency_autofix` | `monster.the_percht_queen.desc` | Levrek Kraliçesi |
| 15:45:54 | NL | Serwer | items.json | 21 | `simple` | `item.10001.name` | Zaoaanse decoratie |
| 15:45:02 | NL | Serwer | npc.json | 50 | `openai:openai/gpt-4.1...` | `npc.a_fluffy_squirrel.stdmod_1` | Tsj? Tsjj?? <though you don't understand squirrelish, that one seems really excited> |
| 15:44:33 | ES | Serwer | server.json | 27 | `google_translate` | `data.otservbr.global.npc.noodles.L105.679` | <sniff> ¡Guau! <sniff> |
| 15:41:47 | RU | Serwer | monsters.json | 20 | `transliteration_cyrillic` | `monster.ancient_scarab.name` | Анциент Скараб |
| 15:40:02 | TR | Serwer | items.json | 31 | `tm` | `item.1000.name` | [EN] kuru ot |
| 15:37:28 | PT | Serwer | npc.json | 40 | `tm` | `npc.captain_bluebear.stdmod_1` | Passagens para Carlin, Ab'Dendriel, Edron, Venore, Port Hope, Liberty Bay, Yalahar, R... |
| 15:31:00 | ES | Serwer | npc.json | 20 | `simple` | `npc.a_majestic_warwolf.say_3` | GRRRRRRRRRRRRR |
| 15:28:07 | DE | Serwer | monsters.json | 99 | `google_translate` | `monster.memory_of_an_elf.name` | Erinnerung einen Elf |
| 15:22:36 | CS | Serwer | items.json | 32 | `tm` | `item.1000.name` | [EN] suchá tráva |
| 15:21:39 | IT | Serwer | items.json | 36 | `tm` | `item.10002.name` | [EN] decorazione zaoan |
| 19:18:27 | ES | Serwer | quests.json | 1 | `tm` | `quests.oramond.sewer_fix_2` | <clong!> <clong!> <scrit scrit scrit>Esto debería ser suficiente. |
| 19:17:58 | ES | Serwer | monsters.json | 20 | `tm` | `monster.the_pit_lord.voice_2` | ¡LOS CONSEGUIRÉ A TODOS! |
| 19:17:22 | PL | Serwer | monsters.json | 9 | `tm` | `monster.schiach.voice_2` | Psz psz psz!! |



> Źródło: `translation_recent_report.jsonl` (ostatnie 20 poprawnych wpisów JSONL)

---

## 🚫 Recent Rejects

| Czas UTC | Lang | Surface | Kategoria | Guard | Decision | Reject types | Key |
|----------|------|---------|-----------|-------|----------|--------------|-----|
| 15:57:24 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.tigo.L59.857` |
| 15:57:24 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.rock.with.a.soft.spot.L143.551` |
| 15:57:18 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.guard.saros.L67.314` |
| 15:57:18 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.guard.saros.L64.313` |
| 15:57:18 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.grizzly.adams.L146.91` |
| 15:57:18 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.grizzly.adams.L136.89` |
| 15:57:18 | PT | Serwer | server.json | `hard_block` | `validate_identical_to_en` | `identical_to_en` | `data.otservbr.global.npc.eroth.L103.511` |
| 15:57:14 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.cornell.L73.81` |
| 15:57:14 | PT | Serwer | server.json | `hard_block` | `critical_issue` | `garble_en_chunk` | `data.otservbr.global.npc.chartan.L107.1622` |
| 15:57:14 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.buddel.tyrsung.L135.726` |
| 15:57:14 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.buddel.raider.camp.L135.1246` |
| 15:57:14 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.buddel.okolnir.L134.1427` |
| 15:57:09 | PT | Serwer | server.json | `hard_block` | `validate_placeholder` | `placeholder` | `data.otservbr.global.npc.buddel.helheim.L130.794` |
| 15:57:09 | PT | Serwer | server.json | `hard_block` | `validate_identical_to_en` | `identical_to_en` | `data.otservbr.global.npc.brasith.L61.1213` |
| 15:57:09 | PT | Serwer | server.json | `hard_block` | `validate_identical_to_en` | `identical_to_en` | `data.otservbr.global.npc.brasith.L60.1212` |
| 15:57:09 | PT | Serwer | server.json | `hard_block` | `validate_identical_to_en` | `identical_to_en` | `data.otservbr.global.npc.anerui.L73.1489` |
| 15:57:08 | PT | Serwer | server.json | `hard_block` | `validate_identical_to_en` | `identical_to_en` | `data.otservbr.global.npc.anerui.L72.1488` |
| 15:57:05 | PT | Serwer | server.json | `hard_block` | `critical_issue` | `garble_en_chunk` | `data.otservbr.global.scripts.quests.the.secret.library.quest.the.lame...` |
| 15:57:04 | PT | Serwer | server.json | `hard_block` | `critical_issue` | `semantic_map_mismatch` | `data.otservbr.global.scripts.quests.the.inquisition.quest.actions.rew...` |
| 15:57:04 | PT | Serwer | server.json | `hard_block` | `critical_issue` | `semantic_map_mismatch` | `data.otservbr.global.scripts.quests.the.first.dragon.actions.rewards....` |

> Źródło: `suspicious_rejected.jsonl` (ostatnie 20 hard-blocków)

---

## 📦 Queue Health

| Metryka | Wartość |
|---------|---------|
| 🔒 Blockers state | `active` |
| 📌 Blocker candidates | 69 |
| 📨 Pending queue (visible tail) | 400 z ostatnich 400 poprawnych wpisów JSONL |
| ⏳ Oldest pending (visible tail) | 333623 s |
| 🌍 Top języki | ES(112), PL(97), PT(94), NL(83) |
| 🧱 Top reason_bucket | provider_error(174), placeholder(137), default(59), word_salad(11) |
| 🗂️ Deferred state keys | 7733 |
| 🕒 Deferred state freshness | fresh (9s) |
| ♻️ Deferred stats | enqueued=18, cooldown=0, deduped=0, manual_review=0, partial_staged=1, partial_completed=0 |

> Źródła: `deferred_translation_queue.jsonl`, `deferred_retry_state.json`, `translation_blockers_latest.json`

---

## 🔀 Provider Routing

| Metryka | Wartość |
|---------|---------|
| 🧭 Active provider | `Free Google Translate` |
| 🧠 Active model | `openai/gpt-4o-mini` |
| 🪜 Runtime chain | `TM/simple -> OpenAI model pool` |
| 🎯 Target chain | `TM/simple -> Free Google Translate -> OpenAI model pool -> Google Cloud` |
| 🗂 Router registry | `provider_router_registry.json` |
| 🎨 Style authority | `free_google_translate` |
| 🧪 OpenAI scope | langs=DE, PL, ES, PT, FR, IT, +8; surfaces=items, npc, monsters, books, quests, +1 |
| ⚠️ Switch reasons | quota_exhausted, rate_limit, model_unavailable |
| 🧮 OpenAI budget | `40/250` |
| ♻️ Provider debt | `305` |
| 🌍 Recent provider mix | TM/simple(169), OpenAI model pool(139), term_consistency_autofix(50), Free Google Translate(43) |
| 🔁 Latest fallback | TM/simple → fallback to google translate high [high_reject_types] server.json |
| 📉 Fallback breakdown | fallback chain exhausted validate fail placeholder(52), fallback chain exhausted validate fail identical to... |
| ☁️ Cloud policy | `disabled` |
| 🤖 OpenAI pool | `active` |
| 🩺 Health signals | recent_fallback, provider_consistency_debt:305, provider_circuit:provider_error_threshold_critical |
| ❤️ Pool health | `critical` (writes=401, fallbacks=116) |

> Źródła: `translation_provider_status_latest.json`, `translation_recent_report.jsonl`, `suspicious_log.jsonl`

---

## 🧩 Term Consistency

| Metryka | Wartość |
|---------|---------|
| 📂 Surface | `server` |
| 🌍 Lang / plik | `pt` / `server.json` |
| 🗂 Registry terms | `5579` |
| 🔎 Keys with term usages | `0` / `0` scanned |
| ⚠️ Keys with conflicts | `0` |
| 🧮 Conflict rate | `0.0%` (Δ `0.0pp`) |
| 🛠 Auto-fixed EN leaks | `0` |
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
| 📈 Trend 24h | pass=74/74 (100.00%), fail=0, Δchecks=+0, dir=stable |
| 📏 Thresholds | identical<=35.00% ; word_salad<=5 ; placeholder<=3 |
| 🧪 Reject window | tail=1200 wpisów suspicious_rejected |
| 🧠 Recommendation | Launcher quality gate PASS: brak naruszeń progów dla client/otclient_modules. |

| Plik | Langs PASS/TOTAL | Max identical_to_en | Word-salad rejects | Placeholder rejects | Gate |
|------|------------------|---------------------|--------------------|---------------------|------|
| client.json | 51/51 | 31.40% | 0 | 0 | ✅ PASS |
| otclient_modules.json | 51/51 | 31.56% | 0 | 0 | ✅ PASS |

> Źródła: `launcher_quality_gate_latest.json`, `suspicious_rejected.jsonl`, `translation_global_overview.json`

---

## 🚨 Doctor Alerts

| Alarm | Status | Severity | Value | Threshold | Detail |
|-------|--------|----------|-------|-----------|--------|
| `HEARTBEAT_STALE` | OK | OK | `10` | `300` | Heartbeat świeży (10s, src=worker_runtime_heartbeat) Runtime[status=healthy, reason=heartbeat_fresh, phase=... |
| `NO_WRITE` | OK | OK | `19` | `900` | Recent writes wyglądają zdrowo. |
| `LEASE_CONFLICT` | OK | OK | `0` | `0` | Brak konfliktów lease/lock w oknie 1800s. |
| `QUEUE_STARVATION` | ALERT | WARNING | `{'pending': 400, 'oldest_s': 333623}` | `{'pending_min': 200, 'oldest_s': 3600}` | Duży pending i stara kolejka sugerują głodzenie queue. |
| `DLQ_GROWTH` | OK | OK | `{'count': 0, 'delta': 0}` | `{'growth_step': 25}` | DLQ precursor bez niepokojącego wzrostu. |

> Źródło: `doctor_alerts_latest.json` (checks: HEARTBEAT_STALE, NO_WRITE, LEASE_CONFLICT, QUEUE_STARVATION, DLQ_GROWTH)

---

## 🛠️ Doctor Remediation

| Metryka | Wartość |
|---------|---------|
| 🔔 Open alarms | 9 |
| 🆕 Newly opened (cycle) | - |
| ✅ Resolved (cycle) | - |
| 📌 Active alarm codes | DEFERRED_RETRY_PIPELINE_WARNING, FIXTURE_REGRESSION, LANG_PARITY_WARN, NATIVE_READINESS_BELOW_THRESHOLD, PR... |
| 🧠 Tracked alarm codes | 31 |
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
| �📊 Przetłumaczono | **361** kluczy |
| ❌ Odrzucone (guard) | 115 |
| 🔁 Cykli | 50 |
| 🌍 Języków | 8 |
| 🏆 Najaktywniejszy | DE (99 kluczy) |
| 📄 Najczęstszy plik | items.json |
| ⚡ Przepustowość | ~301 kluczy/h |
| 🛡️ Odrzucone (strażnik) | 24.2% |
| ⚠️ Podejrzane | 436 |

---

## 🌍 Języki — ostatnia godzina

| Język | Przetłumaczono | Odrzucone | GF% | Pliki |
|-------|---------------|-----------|-----|-------|
| DE | 99 | 1 | 1.0% | 1 |
| PT | 87 | 104 | 54.5% | 3 |
| NL | 63 | 1 | 1.6% | 2 |
| TR | 60 | 3 | 4.8% | 3 |
| CS | 32 | 0 | 0.0% | 1 |
| RU | 20 | 6 | 23.1% | 1 |
| ES | 0 | 0 | 0% | 1 |
| RO | 0 | 0 | 0% | 1 |

> Źródło: `translation_guard_report.jsonl` (okno 1.0h)

---

## 🗺️ Pokrycie per język (TOP 20)

| Język | Przetłumaczono | Kluczy EN | Pokrycie | Kopie EN |
|-------|---------------|-----------|----------|----------|
| ES | 58,331 | 74,536 | 78.26% ↑+0.01% | 9,794 |
| PL | 52,904 | 74,536 | 70.98% →0% | 5,867 |
| IT | 50,537 | 74,536 | 67.8% | 10,045 |
| RO | 51,498 | 74,536 | 69.09% | 13,066 |
| RU | 33,106 | 74,536 | 44.42% →0% | 4,817 |
| FR | 42,864 | 74,536 | 57.51% →0% | 26,153 |
| SR | 24,827 | 74,536 | 33.31% | 1,218 |
| CS | 36,004 | 74,536 | 48.3% | 30,258 |
| TR | 23,832 | 74,536 | 31.97% | 3,785 |
| NL | 55,099 | 74,536 | 73.92% | 51,897 |
| PT | 57,030 | 74,536 | 76.51% →0% | 52,122 |
| DE | 50,489 | 74,536 | 67.74% ↑+0.02% | 65,113 |
| BN | 4,787 | 74,536 | 6.42% | 3,991 |
| AR | 4,723 | 74,536 | 6.34% | 4,038 |
| LT | 3,606 | 74,536 | 4.84% | 2,792 |
| FA | 4,661 | 74,536 | 6.25% | 4,199 |
| HI | 4,325 | 74,536 | 5.8% | 3,992 |
| ID | 4,287 | 74,536 | 5.75% | 4,006 |
| AZ | 3,511 | 74,536 | 4.71% | 2,997 |
| BG | 3,502 | 74,536 | 4.7% | 3,019 |

> Źródło: `translation_global_overview.json`

---

## 📈 Postęp i ETA (cel: 95%)

> **ETA globalne:** ~416 dni (2,998,055 kluczy do celu 95%)

| Język | Pasek | Pokrycie | Przetłumaczono | ETA do 95% |
|-------|-------|----------|---------------|------------|
| ES | ███████████████░░░░░ | 78.3% | 58,331/74,536 | ~42h |
| PL | ██████████████░░░░░░ | 71.0% | 52,904/74,536 | ~2d |
| IT | █████████████░░░░░░░ | 67.8% | 50,537/74,536 | ~3d |
| RO | █████████████░░░░░░░ | 69.1% | 51,498/74,536 | ~3d |
| RU | ████████░░░░░░░░░░░░ | 44.4% | 33,106/74,536 | ~5d |
| FR | ███████████░░░░░░░░░ | 57.5% | 42,864/74,536 | ~4d |
| SR | ██████░░░░░░░░░░░░░░ | 33.3% | 24,827/74,536 | ~6d |
| CS | █████████░░░░░░░░░░░ | 48.3% | 36,004/74,536 | ~5d |
| TR | ██████░░░░░░░░░░░░░░ | 32.0% | 23,832/74,536 | ~7d |
| NL | ██████████████░░░░░░ | 73.9% | 55,099/74,536 | ~2d |
| PT | ███████████████░░░░░ | 76.5% | 57,030/74,536 | ~46h |
| DE | █████████████░░░░░░░ | 67.7% | 50,489/74,536 | ~3d |
| BN | █░░░░░░░░░░░░░░░░░░░ | 6.4% | 4,787/74,536 | ~9d |
| AR | █░░░░░░░░░░░░░░░░░░░ | 6.3% | 4,723/74,536 | ~9d |
| LT | ░░░░░░░░░░░░░░░░░░░░ | 4.8% | 3,606/74,536 | ~9d |
| FA | █░░░░░░░░░░░░░░░░░░░ | 6.2% | 4,661/74,536 | ~9d |
| HI | █░░░░░░░░░░░░░░░░░░░ | 5.8% | 4,325/74,536 | ~9d |
| ID | █░░░░░░░░░░░░░░░░░░░ | 5.8% | 4,287/74,536 | ~9d |
| AZ | ░░░░░░░░░░░░░░░░░░░░ | 4.7% | 3,511/74,536 | ~9d |
| BG | ░░░░░░░░░░░░░░░░░░░░ | 4.7% | 3,502/74,536 | ~9d |

> Tempo obliczone na bazie ostatniej godziny: ~301 kluczy/h.

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
> Świeżość: 1min temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-04-27 15:57:32

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **22,164** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **10,409** | 47.0% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,443** | **61.9%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **15** | **0.1%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **3,966** | 38.1% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **10,394** | 99.9% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,493 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 841 | silnik serwera |
| 📋 JSON (.json) | 3,478 | konfiguracje |

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
> Świeżość: 16s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-04-27T15:57:29.110440Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Nominal % | Real % | Kopie EN | Placeholdery | Braki kluczy |
|-------|-----------|--------|----------|--------------|--------------|
| ES (Hiszpański) | 78.26% (58,331/74,536) | 67.00% (49,936/74,536) | 9,794 | 14,830 | 0 |
| PL (Polski) | 70.98% (52,904/74,536) | 65.06% (48,494/74,536) | 5,867 | 20,201 | 0 |
| IT (Włoski) | 67.80% (50,537/74,536) | 59.56% (44,396/74,536) | 10,045 | 20,120 | 0 |
| RO (Rumuński) | 69.09% (51,498/74,536) | 55.97% (41,718/74,536) | 13,066 | 19,777 | 0 |
| RU (Rosyjski) | 44.42% (33,106/74,536) | 42.79% (31,894/74,536) | 4,817 | 37,843 | 0 |
| FR (Francuski) | 57.51% (42,864/74,536) | 41.87% (31,206/74,536) | 26,153 | 17,199 | 0 |
| SR (SR) | 33.31% (24,827/74,536) | 32.04% (23,885/74,536) | 1,218 | 28,698 | 20,793 |
| CS (Czeski) | 48.30% (36,004/74,536) | 30.00% (22,358/74,536) | 30,258 | 21,946 | 0 |
| TR (Turecki) | 31.97% (23,832/74,536) | 28.55% (21,280/74,536) | 3,785 | 49,485 | 0 |
| NL (Niderlandzki) | 73.92% (55,099/74,536) | 28.22% (21,032/74,536) | 51,897 | 1,633 | 0 |
| PT (Portugalski) | 76.51% (57,030/74,536) | 28.11% (20,950/74,536) | 52,122 | 1,487 | 0 |
| DE (Niemiecki) | 67.74% (50,489/74,536) | 10.49% (7,819/74,536) | 65,113 | 1,630 | 0 |
| BN (BN) | 6.42% (4,787/74,536) | 2.57% (1,912/74,536) | 3,991 | 47,898 | 20,793 |
| AR (Arabski) | 6.34% (4,723/74,536) | 2.42% (1,801/74,536) | 4,038 | 47,962 | 20,793 |
| LT (LT) | 4.84% (3,606/74,536) | 2.22% (1,654/74,536) | 2,792 | 49,355 | 20,793 |
| FA (FA) | 6.25% (4,661/74,536) | 2.12% (1,578/74,536) | 4,199 | 48,024 | 20,793 |
| HI (HI) | 5.80% (4,325/74,536) | 1.94% (1,449/74,536) | 3,992 | 48,360 | 20,793 |
| ID (ID) | 5.75% (4,287/74,536) | 1.87% (1,397/74,536) | 4,006 | 48,398 | 20,793 |
| AZ (AZ) | 4.71% (3,511/74,536) | 1.84% (1,375/74,536) | 2,997 | 49,429 | 20,793 |
| BG (BG) | 4.70% (3,502/74,536) | 1.84% (1,374/74,536) | 3,019 | 49,408 | 20,793 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** TR - Turecki - Serwer
- **Plik JSON:** spells.json
- **Ostatnie klucze (10-20):** 1

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- <sniff> Woof! <sniff> → <sniff> Uau! <sniff> (data.otservbr.global.npc.noodles.L105.679)

### 🚫 Raporty strażnika jakości
- Raporty strażnika jakości: **4431**  
- Raporty blokad: **0**  
- Widoczne raporty 'nie mogę przetłumaczyć': **4286**

### 🧱 Blockers snapshot (strict)
| State | Candidates | Missing files | Missing keys | Reason | Timestamp |
|-------|------------|---------------|--------------|--------|-----------|
| 🟠 active | 69 | 0 | 0 | - | 2026-04-27T15:56:38.877325Z |

### 🌐 Globalne info wszystkich języków
- **Pokrycie globalne (nominal):** **17.65%** (684,013/3,875,872)
- **Pokrycie globalne (real):** **10.53%** (408,211/3,875,872)
- **Kopie EN (łącznie):** **417,441**
- **Placeholdery [EN]/puste (łącznie):** **2,196,101**
- **Referencje `#i18n:` (łącznie):** **8,132**
- **Braki kluczy (łącznie):** **856,235**
- **Brakujące pliki językowe:** **11**
- **Cache STATUSPY (per-lang):** **mixed** | hit **51**, miss **1**, hit-rate **98.1%**
- **Cache STATUSPY (per-file):** hit **2027**, miss **1**, hit-rate **100.0%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 📌 KPI backlog `[EN]` (HU/SK/TR)
| Język | Backlog `[EN]` | EN kluczy | Udział backlogu |
|-------|----------------|-----------|-----------------|
| HU | 49,854 | 74,536 | 66.89% |
| SK | 49,937 | 74,536 | 67.00% |
| TR | 49,485 | 74,536 | 66.39% |

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **70,637** |
| 📦 **Instalka** (klient/OTClient) | **3,899** |

| Język | Serwer | Serwer % (nominal/real) | Instalka | Instalka % (nominal/real) |
|-------|--------|--------------------------|----------|----------------------------|
| ES | 55,171/70,637 | 78.1% / 66.3% | 3,160/3,899 | 81.0% / 79.2% |
| PL | 49,756/70,637 | 70.4% / 64.3% | 3,148/3,899 | 80.7% / 78.4% |
| IT | 47,564/70,637 | 67.3% / 58.8% | 2,973/3,899 | 76.2% / 73.1% |
| RO | 48,712/70,637 | 69.0% / 55.2% | 2,786/3,899 | 71.5% / 69.6% |
| RU | 29,962/70,637 | 42.4% / 40.8% | 3,144/3,899 | 80.6% / 79.3% |
| FR | 39,937/70,637 | 56.5% / 40.1% | 2,927/3,899 | 75.1% / 73.7% |
| SR | 24,726/70,637 | 35.0% / 33.7% | 101/3,899 | 2.6% / 2.3% |
| CS | 34,314/70,637 | 48.6% / 29.5% | 1,690/3,899 | 43.3% / 39.0% |
| TR | 21,873/70,637 | 31.0% / 27.4% | 1,959/3,899 | 50.2% / 48.7% |
| NL | 53,475/70,637 | 75.7% / 27.7% | 1,624/3,899 | 41.6% / 37.4% |
| PT | 55,286/70,637 | 78.3% / 27.4% | 1,744/3,899 | 44.7% / 41.7% |
| DE | 48,894/70,637 | 69.2% / 9.0% | 1,595/3,899 | 40.9% / 38.0% |

### 🌐 Launcher/WWW per język (nominal% / real%)
| Język | `html.json` | `php.json` | `client.json` | `otclient_modules.json` |
|-------|-------------|------------|---------------|-------------------------|
| ES | 55.1% / 55.0% | 81.4% / 79.7% | 94.2% / 91.7% | 98.0% / 94.8% |
| PL | 53.5% / 53.4% | 81.4% / 78.0% | 92.6% / 90.1% | 98.7% / 94.9% |
| IT | 55.2% / 55.0% | 83.0% / 79.7% | 90.9% / 88.4% | 89.0% / 83.7% |
| RO | 54.4% / 54.1% | 71.2% / 66.1% | 85.1% / 82.6% | 81.5% / 78.6% |
| RU | 65.5% / 65.4% | 79.7% / 76.3% | 99.2% / 96.7% | 88.9% / 86.8% |
| FR | 49.4% / 49.2% | 74.6% / 69.5% | 82.6% / 80.2% | 92.3% / 90.2% |
| SR | 0.0% / 0.0% | 0.0% / 0.0% | 21.1% / 19.4% | 2.5% / 2.0% |
| CS | 39.6% / 39.3% | 69.5% / 64.4% | 74.4% / 71.9% | 40.3% / 32.7% |
| TR | 56.0% / 56.0% | 93.2% / 88.1% | 93.4% / 90.9% | 37.9% / 35.4% |
| NL | 39.4% / 39.1% | 76.3% / 71.2% | 80.6% / 78.1% | 36.2% / 28.8% |
| PT | 40.5% / 40.2% | 67.8% / 62.7% | 71.1% / 68.6% | 42.5% / 37.6% |
| DE | 37.3% / 37.1% | 69.5% / 64.4% | 77.7% / 75.2% | 37.1% / 32.4% |
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
| 🥉 Worst | Server 10.60% |
| ↕️ Spread | 7.71 pp |
| 📉 Largest regression 24h | Launcher (+0.00 pp) |
| 🕒 Window | 24h, samples=74 |

| Rank | Surface | Real coverage | Δ24h | Langs | Regression focus (lowest langs) |
|------|---------|---------------|------|-------|----------------------------------|
| #1 | 🔴 Launcher | 18.31% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #2 | 🔴 Installer | 13.69% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #3 | 🔴 Website | 10.85% | +0.00 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #4 | 🔴 Server | 10.60% | +0.00 pp | 51 | ZH 0.2%, TL 0.8%, BS 0.9% |

> Źródła: `surface_parity_latest.json`, `surface_parity_report.jsonl`, `translation_global_overview.json`

### ✅ Launcher 100% readiness contract
| Metryka | Wartość |
|---------|---------|
| ✅ Contract state | `🟡 IN_PROGRESS` |
| 🧪 Checks passed | 2/4 |
| 🌍 Production langs | PL, DE, AR |
| 📄 Claim table open tasks | B23-02 |
| 🚫 Failed checks | tasks_closed_claim_table, doctor_alerts_clean_3_waves |
| 🕒 Evidence window | 24h (span=68.81h) |
| 🧠 Recommendation | Domknij check: tasks_closed_claim_table |

| Check | Status | Detail |
|-------|--------|--------|
| Claim table `B23-02..B23-08` | ❌ FAIL | open dependencies: B23-02; contract B23-08=🟢 in_progress (2026-04-23, 90%) |
| 3 launcher waves bez stale alerts | ❌ FAIL | insufficient/dirty waves (0/3); recent=- |
| Trend 24h `identical_to_en` + `word_salad` | ✅ PASS | window=68.81h; client.json: id=+0.00pp, ws=+0, otclient_modules.json: id=+0.00pp, ws=+0 |
| Bridge launcher-rust (`missing=0`, `extra=0`) | ✅ PASS | all prod langs clean |

> Źródła: `launcher_readiness_latest.json`, `launcher_readiness_report.jsonl`, `launcher_quality_gate_latest.json`, `translation_dispatch_state.json`, `doctor_alerts_latest.json`, `docs/i18n/launcher_rust_bridge_apply_latest.json`

### ⏱️ Ścisłe okno godzinowe (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-04-27T14:57:32.950335Z → 2026-04-27T15:57:32.950335Z) |
| Cykle | **50** (TŁUMACZENIE=50, PRE_MIGRATION=0) |
| Pominięte (kat. nieaktywna) | **0** (ogółem=0.0%, migracja=0.0%) |
| Odrzucone (strażnik jakości) % | **24.2%** |
| Cykle bez postępu % | **15.4%** |
| Przepustowość (kluczy/h) | **300.6 kluczy/h** |
| Podejrzane tłumaczenia | **436** |
| Najgorsze cele (strażnik) | pt/npc.json (gf=69), pt/server.json (gf=28), pt/monsters.json (gf=7), ru/monsters.json (gf=6), tr/monsters.json (gf=3) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl`, `i18n/status/deferred_translation_queue.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

### 🚫 Odrzucenia wg reason (1h)
| Reason | Odrzucone | Udział | TOP język/plik |
|--------|-----------|--------|----------------|
| `gt_validate_fail_placeholder` | 137 | 60.6% | pt/npc.json (54) |
| `gt_validate_fail_identical_to_en` | 51 | 22.6% | nl/npc.json (28) |
| `gt_partial_validate_word_salad` | 11 | 4.9% | es/server.json (10) |
| `gt_rejected_critical` | 10 | 4.4% | pt/npc.json (6) |
| `gt_rejected_high_mixed_scripts` | 6 | 2.7% | ru/monsters.json (6) |

## 🔬 JAKOŚĆ TŁUMACZEŃ

> **[QUALITY]** 🔒 NIEAKTYWNY (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 1min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-04-27T15:56:21.875389Z

- **Ostatni audyt:** OK | 2 issue(s) / 100 entries | 2026-04-27T15:56:21.875389Z
- **Top 5 typów problemów:** suspicious_rejected_critical=191, suspicious_log_high=99, suspicious_log_critical=85, suspicious_log_low=11, suspicious_rejected_high=9
- **Języki o najsłabszej jakości:** fr(60.1, issues=60621), nl(60.1, issues=50732), tr(60.1, issues=47032), es(60.3, issues=711685), pt(60.3, issues=42772)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#8** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **74,536** | realny stan EN |
| 🤖 Kluczy z rejestru workera (efektywne) | **74,536** | raw + reconcile |
| 🧾 Kluczy z rejestru workera (raw) | **7** | historia runów workera |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## ⚠️ Problemy i uwagi

⚠️ **TR**: jakość 60%, 47032 problemów
⚠️ **PL**: jakość 82%, 389218 problemów
⚠️ **AZ**: jakość 70%, 1417 problemów
⚠️ **ES**: jakość 60%, 711685 problemów
⚠️ **PT**: jakość 60%, 42772 problemów
⚠️ **FR**: jakość 60%, 60621 problemów
⚠️ **IT**: jakość 63%, 164651 problemów
⚠️ **RU**: jakość 62%, 349747 problemów
⚠️ **NL**: jakość 60%, 50732 problemów
⚠️ **SV**: jakość 74%, 68647 problemów

---

## 📜 Ostatnie komendy

- Brak dostępnych komend.

---

## 🏥 Zdrowie systemu

| Komponent | Status | Szczegóły |
|-----------|--------|-----------|
| Worker | 🟢 DZIAŁA | Cykl #16,378 |
| Heartbeat | 83s temu | 2026-04-27T15:56:22Z |
| Uptime | - | od startu workera |

---

## � Kolejka napraw (kopie EN)

- **Łącznie kopii EN do naprawy:** 774
- **TOP 5 języków:** DE (19,929), NL (16,470), CS (15,290), PT (14,660), FR (13,232)
- **Aktualnie naprawia:** ES / -
- **Ostatnia aktualizacja:** 2026-04-27T15:53:52.142973Z

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** AUTO_TRANSLATE  
> **Aktualna kategoria:** pt


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
> Świeżość: 1min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-04-27T15:56:22Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #16,378 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 DZIAŁA                                 │
│ Tryb:      🤖 AUTO_TRANSLATE (auto_done)             │
│ Kategoria: 📁 PT                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: server.json                                             │
│ Postęp: 10/20 keys                                            │
│ … guard_fail=28 strict_missing_key=0 strict_skipped_done=2572 │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-04-27T15:56:22Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-04-27 15:57:29 | AUTO_TRANSLATE:auto_done | pt | ok | server.json
- 2026-04-27 15:56:40 | AUTO_TRANSLATE:heartbeat_tick | pt | ok | server.json
- 2026-04-27 15:56:40 | AUTO_TRANSLATE:auto_start | pt | ok | server.json
- 2026-04-27 15:56:20 | AUTO_TRANSLATE:auto_done | tr | ok | spells.json
- 2026-04-27 15:56:02 | AUTO_TRANSLATE:heartbeat_tick | tr | ok | spells.json
- 2026-04-27 15:56:01 | AUTO_TRANSLATE:auto_start | tr | ok | spells.json

---

## 📊 Wskaźniki KPI — Zdrowie Pilotów (PL/ES)

| Język | Pokrycie | Brakujące | Kopie EN | Przetłumaczone(200) | Odrzucone | Wpisy |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 71.0% | 0 | 5,867 | 254 | 964 (79.1%) | 18 |
| 🟡 ES | 78.3% | 0 | 9,794 | 702 | 425 (37.7%) | 36 |

| Wskaźnik | Wartość | Cel | Status |
|-----|---------|--------|--------|
| Tłumaczeń netto | **126,238** | — | 📊 |
| Adaptacyjna paczka | batch=5, gf_rate=19.86%, reason=stable_fail_rate=19.9%, filter=exclude_repair | odrzucenia <5% → zwiększ | 📊 |
| Przepustowość (okno) | 956 kluczy / 54 wpisów | >50/h | 📊 |

---

## 📜 HISTORIA

> **[HISTORY]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-04-27 15:57:32

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pt] → warn (files+1, translated+10, skipped+0) — lang=pt file=server.json strict_skipped_done=2572 guard_fail=28 placeholder=11 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [cs] → warn (files+1, translated+66, skipped+0) — lang=cs file=server.json strict_skipped_done=811 guard_fail=11 placeholder=10 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+1) — repair_identical lang=es file=quests.json target_identical=1 limit=180 tier=low_backlog domain_cap=180 gt=true suspicious_pct=100.00
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ru] → warn (files+1, translated+20, skipped+0) — lang=ru file=monsters.json strict_skipped_done=3176 guard_fail=23 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+0) — repair_identical lang=es file=otclient_modules.json target_identical=35 limit=180 tier=low_backlog domain_cap=220 gt=true suspicious_pct=0.00
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [tr] → warn (files+1, translated+224, skipped+0) — lang=tr file=items.json strict_skipped_done=4434 guard_fail=11 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [it] → warn (files+1, translated+63, skipped+0) — lang=it file=items.json strict_skipped_done=16966 guard_fail=28 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → warn (files+1, translated+21, skipped+0) — lang=de file=monsters.json strict_skipped_done=292 guard_fail=5 placeholder=0 command=0 pipe=0
- • DOCTOR_REMEDIATION: ALARM_RESOLVED [-] → ok — resolved_count=1
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [fr] → warn (files+1, translated+38, skipped+0) — lang=fr file=server.json strict_skipped_done=892 guard_fail=16 placeholder=10 command=0 pipe=0


## 📅 Dziś (2026-04-27)

| Metryka | Wartość |
|---------|---------|
| ✅ Przetłumaczono | **406** kluczy |
| ⏭️ Pominięte | 0 |
| 🔁 Cykli | 7 |
| ❌ Błędów | 20 |
| 🌍 Aktywnych języków | 7 |
| 🏆 TOP 5 | **DE** (99), **PT** (77), **NL** (63), **TR** (60), **ES** (55) |
| 📊 Porównanie | brak danych z wczoraj |

## 📆 Ten tydzień (7 dni)

> Suma tygodnia: **26,706** kluczy

| Dzień | Wykres | Przetłumaczono | Cykli |
|-------|--------|---------------|-------|
| 2026-04-21 | ██████████████████████████████████████████████████ | 8,628 | 89 |
| 2026-04-22 | ██████████████████████████████████████████████████ | 12,108 | 106 |
| 2026-04-23 | ██████████████████████████████████████████████████ | 5,564 | 168 |
| 2026-04-24 | ░ | 0 | 0 |
| 2026-04-25 | ░ | 0 | 0 |
| 2026-04-26 | ░ | 0 | 0 |
| 2026-04-27 | ██████████████████████████████████████████████████ | 406 | 7 |

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
| 🔄 Cykli wykonanych | **#16,378** | continuous mode |

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
| Worker v1.1 | 🟢 DZIAŁA | Cykl #16,378 |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-04-27 15:57:32  
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
