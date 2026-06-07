# 🌍 System Tłumaczeń I18N — Dashboard na żywo

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 2500, 'client': 300, 'otclient_modules': 2500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'arena': 184, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 358, 'website_i18n': 2345, 'world': 100} -->

## 📝 PODSUMOWANIE

> Worker tłumaczy **53** języków. Klucze EN: **4,466**. Pokrycie globalne: **nominal 4.83% / real 4.77%**. Tempo: **277.3 kluczy/h**. Tłumaczeń netto: **172,841**.

## 🧭 META

> **[META]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-06-07 19:10:42

> **Aktualizacja:** 2026-06-07 19:10:42 UTC
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 4466
> **Publikacja:** git-enabled
> **LIVE:** Cykl #21,218 | Status: 🟢 DZIAŁA | Faza: AUTO_TRANSLATE | Etap: cycle_end | Kategoria: it | Plik: html.json | Heartbeat: 2026-06-07T19:08:18Z
> **Okno godzinowe:** okno=1.0h | cykli=352 | pominięte=0.0% | odrzucone=3.4% | przepustowość=277.3/h  
> **Tłumaczeń netto:** 172,841

### 🧩 Status sekcji
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 AKTYWNY | teraz | - | `update_github_status()` | 2026-06-07 19:10:42 |
| LIVE | 🟢 AKTYWNY | 2min temu | - | `activity.json / worker_state.json` | 2026-06-07T19:08:18Z |
| PRE_MIGRATION | 🔒 NIEAKTYWNY | 2min temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-06-07 19:10:42 |
| TRANSLATION | 🟢 AKTYWNY | 9s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-06-07T19:10:35.027528Z |
| QUALITY | 🔒 NIEAKTYWNY | 8s temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-06-07T19:10:36.017210Z |
| HISTORY | 🟢 AKTYWNY | teraz | - | `daily/*.json / ops.jsonl` | 2026-06-07 19:10:42 |
| DOCTOR | 🟠 AKTYWNY | 0s temu | 1 alarmów | `doctor_alerts_latest.json` | 2026-06-07T19:10:44.914348Z |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🤖 Worker Live

> **[LIVE]** 🟢 AKTYWNY  
> Świeżość: 2min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-06-07T19:08:18Z

| Metryka | Wartość |
|---------|---------|
| 🛠️ **Co robi** | Tłumaczenie automatyczne (Google Translate + TM) → cycle_end |
| 🌍 **Aktywne języki (10 min)** | CS, IT, RO, TR |
| 📝 **Faza** | AUTO_TRANSLATE |
| 📋 **Etap** | koniec cyklu |
| 📂 **Kategoria / Język** | it |
| 📄 **Plik** | html.json |
| 🧭 **Surface** | WWW |
| 📊 **Status** | 🟢 DZIAŁA |
| 📈 **Postęp** | - |
| 🔧 **Metoda** | Google Translate + TM fallback |
| 🧠 **Detail** | cycle end |
| 🔑 **Current key** | `it:html.json` |
| 🔄 **Ostatni cykl** | 10 kluczy, 0 odrzuconych, 28.3s, tryb: AUTO_TRANSLATE, cel: it/html.json |
| ❤️ **Heartbeat** | 2026-06-07T19:08:18Z |

**Ostatnie operacje:**
- → AUTO_TRANSLATE_DONE (IT) [warn]
- → AUTO_TRANSLATE_DONE (RO) [warn]
- → WEBSITE_I18N_APPLY (TR) [ok]
- → AUTO_TRANSLATE_DONE (TR) [warn]
- → WEBSITE_I18N_APPLY (CS) [ok]

---

## ✍️ Recent Writes

| Czas UTC | Lang | Surface | Plik | Count | Source | Sample key | Sample |
|----------|------|---------|------|-------|--------|------------|--------|
| 19:10:30 | IT | WWW | html.json | 10 | `tm` | `web.tpl.buttons.change_email.set_2` | _sbutton_changeemail |
| 19:09:38 | RO | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:09:01 | TR | WWW | website_i18n.json | 23 | `google_translate` | `account.guilds.applications.none` | Açık yerel Tibia lonca uygulamanız yok. |
| 19:08:05 | CS | WWW | website_i18n.json | 1 | `google_translate` | `account.guilds.active_instances_label` | Aktivní servery |
| 19:07:15 | NL | WWW | website_i18n.json | 17 | `google_translate` | `account.guilds.invites.none` | Je hebt geen actieve lokale Tibia gilde-uitnodigingen. |
| 19:06:25 | PT | WWW | website_i18n.json | 9 | `tm` | `account.guilds.local_panel.server_label` | Mundo |
| 19:05:36 | DE | WWW | website_i18n.json | 2 | `google_translate` | `account.guilds.create_link` | Eine Gilde gegründet |
| 19:04:32 | FR | WWW | website_i18n.json | 6 | `google_translate` | `account.guilds.profile_label` | Profil de guilde actif : |
| 19:03:28 | IT | WWW | website_i18n.json | 1 | `google_translate` | `account.email_request.notice_suffix` | puoi accettare il nuovo indirizzo email e completare il processo. Per favore cancella... |
| 19:01:47 | TR | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:01:02 | CS | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:00:26 | IT | WWW | html.json | 13 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 18:59:43 | RO | WWW | html.json | 10 | `tm` | `web.tpl.guilds.list.set_2` | _sbutton_foundguild |
| 18:58:49 | TR | WWW | website_i18n.json | 6 | `google_translate` | `account.email` | Adres e-postası |
| 18:58:07 | CS | WWW | website_i18n.json | 2 | `google_translate` | `account.email_request.notice_suffix` | můžete přijmout novou e-mailovou adresu a dokončit proces. Zrušte prosím požadavek, p... |
| 18:57:26 | NL | WWW | website_i18n.json | 4 | `google_translate` | `account.guilds.browse_link` | Blader door gilden |
| 18:56:39 | PT | WWW | website_i18n.json | 8 | `google_translate` | `account.guilds.local_panel.guild_label` | Guild |
| 18:55:33 | DE | WWW | website_i18n.json | 2 | `google_translate` | `account.guilds.applications_label` | Meine Bewerbungen: |
| 18:54:33 | FR | WWW | website_i18n.json | 5 | `google_translate` | `account.guilds.navigation_label` | Navigation: |



> Źródło: `translation_recent_report.jsonl` + fizyczne `i18n/<lang>/<plik>` (ostatnie 20 wpisów z próbką nadal zgodną z plikiem)

### 🌐 Recent Writes (WWW + Launcher)

| Czas UTC | Lang | Surface | Plik | Count | Source | Sample key | Sample |
|----------|------|---------|------|-------|--------|------------|--------|
| 19:10:30 | IT | WWW | html.json | 10 | `tm` | `web.tpl.buttons.change_email.set_2` | _sbutton_changeemail |
| 19:09:38 | RO | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:09:01 | TR | WWW | website_i18n.json | 23 | `google_translate` | `account.guilds.applications.none` | Açık yerel Tibia lonca uygulamanız yok. |
| 19:08:05 | CS | WWW | website_i18n.json | 1 | `google_translate` | `account.guilds.active_instances_label` | Aktivní servery |
| 19:07:15 | NL | WWW | website_i18n.json | 17 | `google_translate` | `account.guilds.invites.none` | Je hebt geen actieve lokale Tibia gilde-uitnodigingen. |
| 19:06:25 | PT | WWW | website_i18n.json | 9 | `tm` | `account.guilds.local_panel.server_label` | Mundo |
| 19:05:36 | DE | WWW | website_i18n.json | 2 | `google_translate` | `account.guilds.create_link` | Eine Gilde gegründet |
| 19:04:32 | FR | WWW | website_i18n.json | 6 | `google_translate` | `account.guilds.profile_label` | Profil de guilde actif : |
| 19:03:28 | IT | WWW | website_i18n.json | 1 | `google_translate` | `account.email_request.notice_suffix` | puoi accettare il nuovo indirizzo email e completare il processo. Per favore cancella... |
| 19:01:47 | TR | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:01:02 | CS | WWW | html.json | 14 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 19:00:26 | IT | WWW | html.json | 13 | `tm` | `html.coins.html.text1` | {{ result.name ?? result.id }} |
| 18:59:43 | RO | WWW | html.json | 10 | `tm` | `web.tpl.guilds.list.set_2` | _sbutton_foundguild |
| 18:58:49 | TR | WWW | website_i18n.json | 6 | `google_translate` | `account.email` | Adres e-postası |
| 18:58:07 | CS | WWW | website_i18n.json | 2 | `google_translate` | `account.email_request.notice_suffix` | můžete přijmout novou e-mailovou adresu a dokončit proces. Zrušte prosím požadavek, p... |
| 18:57:26 | NL | WWW | website_i18n.json | 4 | `google_translate` | `account.guilds.browse_link` | Blader door gilden |
| 18:56:39 | PT | WWW | website_i18n.json | 8 | `google_translate` | `account.guilds.local_panel.guild_label` | Guild |
| 18:55:33 | DE | WWW | website_i18n.json | 2 | `google_translate` | `account.guilds.applications_label` | Meine Bewerbungen: |
| 18:54:33 | FR | WWW | website_i18n.json | 5 | `google_translate` | `account.guilds.navigation_label` | Navigation: |



---

## 🚫 Recent Rejects

| Czas UTC | Lang | Surface | Kategoria | Guard | Decision | Reject types | Key |
|----------|------|---------|-----------|-------|----------|--------------|-----|
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.admin.changelog.form.html.text3` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.welcome_mail.html.text2` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.management.html.text4` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.management.html.text2` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.login.html.text2` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.create.html.text3` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.create.html.text2` |
| 18:18:18 | RU | WWW | html.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `html.account.change_email.html.text1` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.admin.changelog.form.html.text3` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.welcome_mail.html.text2` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.management.html.text4` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.management.html.text2` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.login.html.text2` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.create.html.text3` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `validate_wrong_script` | `wrong_script` | `html.account.create.html.text2` |
| 18:09:57 | RU | WWW | html.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `html.account.change_email.html.text1` |
| 18:04:13 | RU | WWW | php.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `php.rfc6238.text3` |
| 18:04:13 | RU | WWW | php.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `php.rfc6238.text2` |
| 18:04:13 | RU | WWW | php.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `php.monsters.text2` |
| 18:04:13 | RU | WWW | php.json | `hard_block` | `high_reject_types` | `mixed_scripts` | `php.monsters.text1` |

> Źródło: `suspicious_rejected.jsonl` (ostatnie 20 hard-blocków)

---

## 📦 Queue Health

| Metryka | Wartość |
|---------|---------|
| 🔒 Blockers state | `active` |
| 📌 Blocker candidates | 33 |
| 📨 Pending queue (visible tail) | 350 z ostatnich 400 poprawnych wpisów JSONL |
| ⏳ Oldest pending (visible tail) | 3153619 s |
| 🌍 Top języki | RU(242), DE(25), PL(15), FR(13) |
| 🧱 Top reason_bucket | quality(191), default(149), placeholder(4), command(2) |
| 🗂️ Deferred state keys | 9835 |
| 🕒 Deferred state freshness | fresh (10s) |
| ♻️ Deferred stats | enqueued=0, cooldown=0, deduped=0, manual_review=0, partial_staged=0, partial_completed=0 |

> Źródła: `deferred_translation_queue.jsonl`, `deferred_retry_state.json`, `translation_blockers_latest.json`

---

## 🔀 Provider Routing

| Metryka | Wartość |
|---------|---------|
| 🧭 Active provider | `TM/simple` |
| 🧠 Active model | `-` |
| 🔄 Interleave | enabled=True; openai_cycles=3; free_gt_cycles=1; only_when_both=True |
| 🛟 Emergency reserve | enabled(min=2500, max=3000); not_applicable(cap=250) |
| 🪜 Runtime chain | `TM/simple -> Free Google Translate -> OpenAI model pool` |
| 🎯 Target chain | `TM/simple -> Free Google Translate -> OpenAI model pool -> Google Cloud` |
| 🗂 Router registry | `provider_router_registry.json` |
| 🎨 Style authority | `free_google_translate` |
| 🧪 OpenAI scope | langs=DE, PL, ES, PT, FR, IT, +8; surfaces=items, npc, monsters, books, quests, +2 |
| ⚠️ Switch reasons | quota_exhausted, rate_limit, model_unavailable |
| ❓ OpenAI/GPT teraz | pool_reason=all_models_blocked; models_blocked=3 (next_unblock~41 min); tm_or_free_gt_currently_serving |
| 🧮 OpenAI budget | `15/250 (6.0%); policy=telemetry_only` |
| ♻️ Provider debt | `711` |
| 🌍 Recent provider mix | TM/simple(112), tm_dedup_file(89), Free Google Translate(85) |
| 🔁 Latest fallback | OpenAI model pool → fallback to google translate all models blocked [all_models_blocked] website_i18n.json |
| 📉 Fallback breakdown | fallback to google translate all models blocked(79), fallback to google translate high(1), fallback to goog... |
| ☁️ Cloud policy | `disabled` |
| 🤖 OpenAI pool | `degraded` |
| ⛔ OpenAI blocked models | `3` (next unblock: `41 min`) |
| 🩺 Health signals | recent_fallback, provider_consistency_debt:711 |
| ❤️ Pool health | `degraded` (writes=286, fallbacks=81) |

> Źródła: `translation_provider_status_latest.json`, `translation_recent_report.jsonl`, `suspicious_log.jsonl`

---

## 🧩 Term Consistency

| Metryka | Wartość |
|---------|---------|
| 📂 Surface | `html` |
| 🌍 Lang / plik | `it` / `html.json` |
| 🗂 Registry terms | `18410` |
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
| 📁 Files | scope-skip: client.json, otclient_modules.json |
| 🌍 Langs evaluated | 0/51 |
| 🚫 Failing langs | - |
| 📈 Trend 24h | pass=17/439 (3.87%), fail=422, Δchecks=-102, dir=improving |
| 📏 Thresholds | identical<=35.00% ; word_salad<=5 ; placeholder<=3 |
| 🧪 Reject window | tail=1200 wpisów suspicious_rejected |
| 🧠 Recommendation | Launcher quality gate PASS (scope-skip): brak launcherowych plików referencyjnych w aktywnym I18N_SCOPE. |

| Plik | Langs PASS/TOTAL | Max identical_to_en | Word-salad rejects | Placeholder rejects | Gate |
|------|------------------|---------------------|--------------------|---------------------|------|
| - | - | - | - | - | - |

> Źródła: `launcher_quality_gate_latest.json`, `suspicious_rejected.jsonl`, `translation_global_overview.json`

---

## 🚨 Doctor Alerts

| Alarm | Status | Severity | Value | Threshold | Detail |
|-------|--------|----------|-------|-----------|--------|
| `HEARTBEAT_STALE` | OK | OK | `47` | `300` | Heartbeat świeży (47s, src=worker_runtime_heartbeat) Runtime[status=healthy, reason=heartbeat_fresh, phase=... |
| `NO_WRITE` | OK | OK | `14` | `900` | Recent writes wyglądają zdrowo. |
| `LEASE_CONFLICT` | OK | OK | `0` | `0` | Brak konfliktów lease/lock w oknie 1800s. |
| `QUEUE_STARVATION` | ALERT | WARNING | `{'pending': 350, 'oldest_s': 3153619}` | `{'pending_min': 200, 'oldest_s': 3600}` | Duży pending i stara kolejka sugerują głodzenie queue. |
| `DLQ_GROWTH` | OK | OK | `{'count': 0, 'delta': 0}` | `{'growth_step': 25}` | DLQ precursor bez niepokojącego wzrostu. |

> Źródło: `doctor_alerts_latest.json` (checks: HEARTBEAT_STALE, NO_WRITE, LEASE_CONFLICT, QUEUE_STARVATION, DLQ_GROWTH)

---

## 🛠️ Doctor Remediation

| Metryka | Wartość |
|---------|---------|
| 🔔 Open alarms | 7 |
| 🆕 Newly opened (cycle) | - |
| ✅ Resolved (cycle) | - |
| 📌 Active alarm codes | BLACKLISTED_TARGET, LANG_PARITY_WARN, NATIVE_READINESS_BELOW_THRESHOLD, QUEUE_STARVATION_DETECTED, REPAIR_T... |
| 🧠 Tracked alarm codes | 36 |
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
| �📊 Przetłumaczono | **402** kluczy |
| ❌ Odrzucone (guard) | 14 |
| 🔁 Cykli | 352 |
| 🌍 Języków | 9 |
| 🏆 Najaktywniejszy | TR (87 kluczy) |
| 📄 Najczęstszy plik | website_i18n.json |
| ⚡ Przepustowość | ~277 kluczy/h |
| 🛡️ Odrzucone (strażnik) | 3.4% |
| ⚠️ Podejrzane | 455 |

---

## 🌍 Języki — ostatnia godzina

| Język | Przetłumaczono | Odrzucone | GF% | Pliki |
|-------|---------------|-----------|-----|-------|
| TR | 87 | 0 | 0.0% | 3 |
| PT | 62 | 0 | 0.0% | 2 |
| RO | 58 | 6 | 9.4% | 2 |
| IT | 56 | 0 | 0.0% | 3 |
| NL | 51 | 0 | 0.0% | 3 |
| FR | 47 | 0 | 0.0% | 2 |
| CS | 36 | 0 | 0.0% | 2 |
| DE | 4 | 0 | 0.0% | 2 |
| RU | 1 | 8 | 88.9% | 1 |

> Źródło: `translation_guard_report.jsonl` (okno 1.0h)

---

## 🗺️ Pokrycie per język (TOP 20)

| Język | Przetłumaczono | Kluczy EN | Pokrycie | Kopie EN |
|-------|---------------|-----------|----------|----------|
| PL | 2,664 | 4,466 | 59.65% →0% | 54 |
| RU | 1,112 | 4,466 | 24.9% →0% | 12 |
| ES | 973 | 4,466 | 21.79% →0% | 29 |
| TR | 966 | 4,466 | 21.63% | 45 |
| IT | 896 | 4,466 | 20.06% | 77 |
| FR | 877 | 4,466 | 19.64% ↑+0.20% | 67 |
| RO | 803 | 4,466 | 17.98% | 72 |
| PT | 762 | 4,466 | 17.06% ↑+0.29% | 168 |
| NL | 722 | 4,466 | 16.17% | 187 |
| CS | 698 | 4,466 | 15.63% | 190 |
| DE | 658 | 4,466 | 14.73% ↑+0.09% | 215 |
| ZH_TW | 7 | 4,466 | 0.16% | 775 |
| AR | 4 | 4,466 | 0.09% | 219 |
| BN | 4 | 4,466 | 0.09% | 219 |
| FA | 4 | 4,466 | 0.09% | 219 |
| HE | 4 | 4,466 | 0.09% | 219 |
| HI | 4 | 4,466 | 0.09% | 219 |
| HY | 4 | 4,466 | 0.09% | 219 |
| ID | 4 | 4,466 | 0.09% | 219 |
| JA | 4 | 4,466 | 0.09% | 219 |

> Źródło: `translation_global_overview.json`

---

## 📈 Postęp i ETA (cel: 95%)

> **ETA globalne:** ~31 dni (209,370 kluczy do celu 95%)

| Język | Pasek | Pokrycie | Przetłumaczono | ETA do 95% |
|-------|-------|----------|---------------|------------|
| PL | ███████████░░░░░░░░░ | 59.6% | 2,664/4,466 | ~6h |
| RU | ████░░░░░░░░░░░░░░░░ | 24.9% | 1,112/4,466 | ~11h |
| ES | ████░░░░░░░░░░░░░░░░ | 21.8% | 973/4,466 | ~12h |
| TR | ████░░░░░░░░░░░░░░░░ | 21.6% | 966/4,466 | ~12h |
| IT | ████░░░░░░░░░░░░░░░░ | 20.1% | 896/4,466 | ~12h |
| FR | ███░░░░░░░░░░░░░░░░░ | 19.6% | 877/4,466 | ~12h |
| RO | ███░░░░░░░░░░░░░░░░░ | 18.0% | 803/4,466 | ~12h |
| PT | ███░░░░░░░░░░░░░░░░░ | 17.1% | 762/4,466 | ~13h |
| NL | ███░░░░░░░░░░░░░░░░░ | 16.2% | 722/4,466 | ~13h |
| CS | ███░░░░░░░░░░░░░░░░░ | 15.6% | 698/4,466 | ~13h |
| DE | ██░░░░░░░░░░░░░░░░░░ | 14.7% | 658/4,466 | ~13h |
| ZH_TW | ░░░░░░░░░░░░░░░░░░░░ | 0.2% | 7/4,466 | ~15h |
| AR | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| BN | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| FA | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| HE | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| HI | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| HY | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| ID | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |
| JA | ░░░░░░░░░░░░░░░░░░░░ | 0.1% | 4/4,466 | ~15h |

> Tempo obliczone na bazie ostatniej godziny: ~277 kluczy/h.

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
> Świeżość: 2min temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-06-07 19:10:42

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **22,464** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **10,478** | 46.6% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,546** | **62.5%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **119** | **1.1%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **3,932** | 37.5% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **10,359** | 98.9% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,498 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 8 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 852 | silnik serwera |
| 📋 JSON (.json) | 3,525 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **51** | 0.8% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **68** | - | bez tekstów |
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
| 🔑 **Klucze EN (źródłowe)** | **4,466** | wszystkie kategorie |
| 🧮 **Klucze wyekstrahowane (LIVE)** | **4,466** | realny stan `i18n/en/*.json` |
| 🤖 Klucze z rejestru workera (efektywne) | **75,129** | `5_extraction_en.keys_added` + reconcile |
| 🧾 Klucze z rejestru workera (raw) | **600** | suma `5_extraction_en.keys_added` |
| 🧩 Reconcile korekta rejestru | **74,529** | zmiany EN poza workerem |
| ➕ Klucze poza rejestrem workera | **0** | ręczne zmiany / starsze migracje |
| 📊 NPC | 14,815 | dialogi NPC |
| 📊 Items | 36,733 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 2,062 | widoki web |
| 📊 Pozostałe | -55,059 | scripts, spells, etc. |

## 🌍 TŁUMACZENIA

> **[TRANSLATION]** 🟢 AKTYWNY  
> Świeżość: 9s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-06-07T19:10:35.027528Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Nominal % | Real % | Kopie EN | Placeholdery | Braki kluczy |
|-------|-----------|--------|----------|--------------|--------------|
| PL (Polski) | 59.65% (2,664/4,466) | 59.56% (2,660/4,466) | 54 | 1,752 | 0 |
| RU (Rosyjski) | 24.90% (1,112/4,466) | 24.88% (1,111/4,466) | 12 | 3,343 | 0 |
| ES (Hiszpański) | 21.79% (973/4,466) | 21.72% (970/4,466) | 29 | 3,467 | 0 |
| TR (Turecki) | 21.63% (966/4,466) | 21.54% (962/4,466) | 45 | 3,459 | 0 |
| IT (Włoski) | 20.06% (896/4,466) | 19.95% (891/4,466) | 77 | 3,498 | 0 |
| FR (Francuski) | 19.64% (877/4,466) | 19.50% (871/4,466) | 67 | 3,528 | 0 |
| RO (Rumuński) | 17.98% (803/4,466) | 17.82% (796/4,466) | 72 | 3,598 | 0 |
| PT (Portugalski) | 17.06% (762/4,466) | 16.88% (754/4,466) | 168 | 3,544 | 0 |
| NL (Niderlandzki) | 16.17% (722/4,466) | 15.99% (714/4,466) | 187 | 3,565 | 0 |
| CS (Czeski) | 15.63% (698/4,466) | 15.45% (690/4,466) | 190 | 3,586 | 0 |
| DE (Niemiecki) | 14.73% (658/4,466) | 14.55% (650/4,466) | 215 | 3,601 | 0 |
| ZH_TW (ZH_TW) | 0.16% (7/4,466) | 0.00% (0/4,466) | 775 | 788 | 2,912 |
| AR (Arabski) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| BN (BN) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| FA (FA) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| HE (HE) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| HI (HI) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| HY (HY) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| ID (ID) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |
| JA (Japoński) | 0.09% (4/4,466) | 0.00% (0/4,466) | 219 | 1,335 | 2,912 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** IT - Włoski - WWW
- **Plik JSON:** html.json
- **Ostatnie klucze (10-50):** 33

### 📝 Ostatnie 10-50 przetłumaczonych kluczy
- `IT/html.json` button.delete_character → button.delete_character (`web.tpl.buttons.delete_character.set_3`, `tm`)
- `IT/html.json` _sbutton_deletecharacter → _sbutton_deletecharacter (`web.tpl.buttons.delete_character.set_2`, `tm`)
- `IT/html.json` _sbutton_submit → _sbutton_submit (`web.tpl.buttons.submit.set_3`, `tm`)
- `IT/html.json` button.account_lost → button.account_lost (`web.tpl.buttons.account_lost.set_3`, `tm`)
- `IT/html.json` _sbutton_accountlost → _sbutton_accountlost (`web.tpl.buttons.account_lost.set_2`, `tm`)
- `IT/html.json` _sbutton_view → _sbutton_view (`web.tpl.buttons.view.set_3`, `tm`)
- `IT/html.json` _sbutton_registeraccount → _sbutton_registeraccount (`web.tpl.buttons.register_account.set_3`, `tm`)
- `IT/html.json` button.register_account → button.register_account (`web.tpl.buttons.register_account.set_2`, `tm`)
- `IT/html.json` _sbutton_changesex → _sbutton_changesex (`web.tpl.buttons.change_sex.set_2`, `tm`)
- `IT/html.json` _sbutton_changeemail → _sbutton_changeemail (`web.tpl.buttons.change_email.set_2`, `tm`)
- `IT/html.json` HTML/Javascript/CSS: → HTML/Javascript/CSS: (`html.admin.open_source.html.text2`, `tm_dedup_file`)
- `IT/html.json` {{ count.total_accounts }} → {{ count.total_accounts }} (`html.admin.statistics.html.text1`, `tm_dedup_file`)
- `IT/html.json` {{ count.total_players }} → {{ count.total_players }} (`html.admin.statistics.html.text2`, `tm_dedup_file`)
- `IT/html.json` ' ~ player_name ~ ' → ' ~ player_name ~ ' (`web.tpl.guilds.kick_player.b_1`, `tm`)
- `IT/html.json` ' ~ player_name ~ ' → ' ~ player_name ~ ' (`web.tpl.guilds.delete_invite.b_1`, `tm`)
- `IT/html.json` _sbutton_leaveguild → _sbutton_leaveguild (`web.tpl.guilds.view.set_10`, `tm`)
- `IT/html.json` _sbutton_editranks → _sbutton_editranks (`web.tpl.guilds.view.set_8`, `tm`)
- `IT/html.json` _sbutton_invitecharacter → _sbutton_invitecharacter (`web.tpl.guilds.view.set_6`, `tm`)
- `IT/html.json` HTML/Javascript/CSS: → HTML/Javascript/CSS: (`web.tpl.admin.open_source.b_1`, `tm`)
- `IT/html.json` {{ count.total_monsters }} → {{ count.total_monsters }} (`html.statistics.html.text3`, `tm`)
- `IT/html.json` {{ count.total_players }} → {{ count.total_players }} (`html.statistics.html.text2`, `tm`)
- `IT/html.json` {{ count.total_accounts }} → {{ count.total_accounts }} (`html.statistics.html.text1`, `tm`)
- `IT/html.json` {{ result.name ?? result.id }} → {{ result.name ?? result.id }} (`html.coins.html.text1`, `tm`)
- `IT/html.json` {{ result.lastlogin|date("M d Y, H:i:s") }} → {{ result.lastlogin|date("M d Y, H:i:s") }} (`html.lastlogin.html.text1`, `tm`)
- `IT/html.json` {{ result.balance }} → {{ result.balance }} (`html.balance.html.text1`, `tm`)
- `IT/html.json` {{ result.premium_points }} → {{ result.premium_points }} (`html.points.html.text2`, `tm`)
- `IT/html.json` {{ closed_message }} → {{ closed_message }} (`html.web_status.text2`, `tm`)
- `IT/html.json`  {% if is_closed %}Closed{% else %}Open{% endif %} → {% if is_closed %}Chiuso{% else %}Aperto{% endif %} (`html.web_status.text1`, `tm`)
- `IT/html.json` {{ result.created|date("M d Y, H:i:s") }} → {{ result.created|date("M d Y, H:i:s") }} (`html.created.html.text1`, `tm`)
- `IT/html.json` ' ~ leader_name ~ ' → ' ~ leader_name ~ ' (`web.tpl.guilds.create.success.b_3`, `tm`)
- `IT/html.json` ' ~ guild_name ~ ' → ' ~ guild_name ~ ' (`web.tpl.guilds.create.success.b_2`, `tm`)
- `IT/html.json` _sbutton_foundguild → _sbutton_foundguild (`web.tpl.guilds.list.set_4`, `tm`)
- `IT/html.json` _sbutton_foundguild → _sbutton_foundguild (`web.tpl.guilds.list.set_2`, `tm`)



### 🚫 Raporty strażnika jakości
- Raporty strażnika jakości: **5591**  
- Raporty blokad: **0**  
- Widoczne raporty 'nie mogę przetłumaczyć': **5294**

### 🧱 Blockers snapshot (strict)
| State | Candidates | Missing files | Missing keys | Reason | Timestamp |
|-------|------------|---------------|--------------|--------|-----------|
| 🟠 active | 33 | 0 | 0 | - | 2026-06-07T19:10:10.387056Z |

### 🌐 Globalne info wszystkich języków
- **Pokrycie globalne (nominal):** **4.83%** (11,214/232,232)
- **Pokrycie globalne (real):** **4.77%** (11,069/232,232)
- **Kopie EN (łącznie):** **6,052**
- **Placeholdery [EN]/puste (łącznie):** **95,728**
- **Referencje `#i18n:` (łącznie):** **0**
- **Braki kluczy (łącznie):** **119,392**
- **Brakujące pliki językowe:** **41**
- **Cache STATUSPY (per-lang):** **mixed** | hit **49**, miss **3**, hit-rate **94.2%**
- **Cache STATUSPY (per-file):** hit **153**, miss **3**, hit-rate **98.1%**
- **Profiler cyklu (ostatni):** cykl #26 (AUTO_TRANSLATE): dispatch 1217ms, mode 25103ms, status 47ms, total 28327ms
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 📌 KPI backlog `[EN]` (HU/SK/TR)
| Język | Backlog `[EN]` | EN kluczy | Udział backlogu |
|-------|----------------|-----------|-----------------|
| HU | 1,554 | 4,466 | 34.80% |
| SK | 1,554 | 4,466 | 34.80% |
| TR | 3,459 | 4,466 | 77.45% |

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **0** |
| 📦 **Instalka** (klient/OTClient) | **4,466** |

| Język | Serwer | Serwer % (nominal/real) | Instalka | Instalka % (nominal/real) |
|-------|--------|--------------------------|----------|----------------------------|
| PL | 0/0 | 0.0% / 0.0% | 2,664/4,466 | 59.6% / 59.6% |
| RU | 0/0 | 0.0% / 0.0% | 1,112/4,466 | 24.9% / 24.9% |
| ES | 0/0 | 0.0% / 0.0% | 973/4,466 | 21.8% / 21.7% |
| TR | 0/0 | 0.0% / 0.0% | 966/4,466 | 21.6% / 21.5% |
| IT | 0/0 | 0.0% / 0.0% | 896/4,466 | 20.1% / 19.9% |
| FR | 0/0 | 0.0% / 0.0% | 877/4,466 | 19.6% / 19.5% |
| RO | 0/0 | 0.0% / 0.0% | 803/4,466 | 18.0% / 17.8% |
| PT | 0/0 | 0.0% / 0.0% | 762/4,466 | 17.1% / 16.9% |
| NL | 0/0 | 0.0% / 0.0% | 722/4,466 | 16.2% / 16.0% |
| CS | 0/0 | 0.0% / 0.0% | 698/4,466 | 15.6% / 15.4% |
| DE | 0/0 | 0.0% / 0.0% | 658/4,466 | 14.7% / 14.6% |
| ZH_TW | 0/0 | 0.0% / 0.0% | 7/4,466 | 0.2% / 0.0% |

### 🌐 Launcher/WWW per język (nominal% / real%)
| Język | `website_i18n.json` | `html.json` | `php.json` | `client.json` | `otclient_modules.json` |
|-------|---------------------|-------------|------------|---------------|-------------------------|
| PL | 79.1% / 79.1% | 37.0% / 36.9% | 81.4% / 78.0% | - | - |
| RU | 3.6% / 3.6% | 47.4% / 47.4% | 83.0% / 83.0% | - | - |
| ES | 6.5% / 6.5% | 37.4% / 37.3% | 81.4% / 79.7% | - | - |
| TR | 6.6% / 6.6% | 36.7% / 36.6% | 93.2% / 88.1% | - | - |
| IT | 4.9% / 4.9% | 35.5% / 35.4% | 83.0% / 79.7% | - | - |
| FR | 7.9% / 7.9% | 31.4% / 31.3% | 74.6% / 69.5% | - | - |
| RO | 1.6% / 1.6% | 35.1% / 34.9% | 71.2% / 66.1% | - | - |
| PT | 7.4% / 7.3% | 26.8% / 26.6% | 62.7% / 57.6% | - | - |
| NL | 6.1% / 6.1% | 26.0% / 25.9% | 71.2% / 66.1% | - | - |
| CS | 4.5% / 4.5% | 26.7% / 26.5% | 69.5% / 64.4% | - | - |
| DE | 5.2% / 5.2% | 24.1% / 23.9% | 66.1% / 61.0% | - | - |
| AR | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| BN | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| FA | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| HE | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| HI | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| HY | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| ID | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| JA | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| KA | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| KO | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| ML | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| MS | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| SW | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| TA | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| TE | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| TH | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| TL | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| VI | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| ZH | 0.0% / 0.0% | 0.2% / 0.0% | 0.0% / 0.0% | - | - |
| AZ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| BG | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| BS | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| DA | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| EL | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| ET | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| FI | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| HR | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| HU | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| KK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| LT | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| LV | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| MK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| NO | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| SK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| SL | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| SQ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| SR | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| SV | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| UK | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |
| UZ | 0.0% / 0.0% | 0.0% / 0.0% | 0.0% / 0.0% | - | - |

### 🌐 WWW RedAxe/Tibia — czytelność zakresów
| Metryka | Wartość |
|---------|---------|
| Workplan | `worker_paused_investigation_only` |
| Safety gate | 🔴 PAUSED |
| Provider calls now | `OFF` |
| Last preflight | `blocked` |
| Preflight scope | `server` |
| Preflight blockers | `item_name_grammar_audit` |
| Preflight warnings | `model_pool_config` |
| OpenAI/GPT pool teraz | `degraded` (pool_reason=all_models_blocked; models_blocked=3 (next_unblock~41 min); tm_or_free_gt_current...) |
| Item-name audit | 🔴 REVIEW (49,761 issues, 52 langs) |

| Obszar | Scope | Pliki z EN kluczami | Klucze EN (źródło) | Do tłumaczenia (IT) | Pokrycie (IT, nominal/real) |
|--------|-------|---------------------|--------------------|------------------------------|--------------------------------------------|
| RedAxe/MyAAC strona WWW | `website` | 3/3 | 4,466 | 3,570 | 20.1% / 19.9% |
| Tibia WWW/Wiki publiczne | `www_tibia` | 3/14 | 4,466 | 3,570 | 20.1% / 19.9% |

> Do tłumaczenia liczone dla języka `IT` jako `EN keys - nominal_translated` (z fallbackiem do EN gdy brak wiersza per-file).

| Obszar | Scope | Pliki i18n | Co oznacza dla człowieka |
|--------|-------|------------|--------------------------|
| RedAxe/MyAAC strona WWW | `website` | `website_i18n.json`, `html.json`, `php.json` | UI, HTML/PHP i zasoby strony |
| Tibia WWW/Wiki publiczne | `www_tibia` | `website_i18n.json`, `html.json`, `php.json`, `items.json`, `npc.json`, `monsters.json`, `quests.json`, `questlog.json`, +6 | UI + itemy/NPC/potwory/questy renderowane na stronie |

**Już przygotowane dla publicznego WWW:**
- Local item and monster images are used by public WWW pages.
- Item images have zoom/lightbox behavior.
- NPC profiles expose trade, services, dialogue, access notes, clickable acquisition NPC links, and real minimap tiles.
- Website resources bridge exists for html_copy/resources/i18n <-> i18n/<lang>/website_i18n.json.

> Źródła: `i18n/status/website_translation_workplan.json`, `i18n/status/worker_resume_preflight_latest.json`, `i18n/status/item_name_grammar_audit_latest.json`

### 🌐 Network surface parity (real coverage + delta 24h)
| Metryka | Wartość |
|---------|---------|
| 🕸️ Surfaces | 4 (`server/website/launcher/installer`) |
| 🥇 Best | Website 4.86% |
| 🥉 Worst | Server 0.00% |
| ↕️ Spread | 4.86 pp |
| 📉 Largest regression 24h | Website (-0.38 pp) |
| 🕒 Window | 24h, samples=439 |

| Rank | Surface | Real coverage | Δ24h | Langs | Regression focus (lowest langs) |
|------|---------|---------------|------|-------|----------------------------------|
| #1 | 🔴 Website | 4.86% | -0.38 pp | 51 | AR 0.0%, AZ 0.0%, BG 0.0% |
| #2 | 🔴 Installer | 0.00% | +0.00 pp | 0 | - |
| #3 | 🔴 Launcher | 0.00% | +0.00 pp | 0 | - |
| #4 | 🔴 Server | 0.00% | +0.00 pp | 0 | - |

> Źródła: `surface_parity_latest.json`, `surface_parity_report.jsonl`, `translation_global_overview.json`

### ✅ Launcher 100% readiness contract
| Metryka | Wartość |
|---------|---------|
| ✅ Contract state | `🟡 IN_PROGRESS` |
| 🧪 Checks passed | 1/4 |
| 🌍 Production langs | PL, DE, AR |
| 📄 Claim table open tasks | B23-02 |
| 🚫 Failed checks | tasks_closed_claim_table, doctor_alerts_clean_3_waves, bridge_consistency_prod_langs |
| 🕒 Evidence window | 24h (span=337.63h) |
| 🧠 Recommendation | Domknij check: tasks_closed_claim_table |

| Check | Status | Detail |
|-------|--------|--------|
| Claim table `B23-02..B23-08` | ❌ FAIL | open dependencies: B23-02; contract B23-08=🟢 in_progress (2026-04-23, 90%) |
| 3 launcher waves bez stale alerts | ❌ FAIL | insufficient/dirty waves (0/3); recent=- |
| Trend 24h `identical_to_en` + `word_salad` | ✅ PASS | window=337.63h; client.json: id=-31.40pp, ws=+0, otclient_modules.json: id=-29.79pp, ws=+0 |
| Bridge launcher-rust (`missing=0`, `extra=0`) | ❌ FAIL | failed langs: DE, AR |

> Źródła: `launcher_readiness_latest.json`, `launcher_readiness_report.jsonl`, `launcher_quality_gate_latest.json`, `translation_dispatch_state.json`, `doctor_alerts_latest.json`, `docs/i18n/launcher_rust_bridge_apply_latest.json`

### ⏱️ Ścisłe okno godzinowe (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-06-07T18:10:42.488859Z → 2026-06-07T19:10:42.488859Z) |
| Cykle | **352** (TŁUMACZENIE=244, PRE_MIGRATION=0) |
| Pominięte (kat. nieaktywna) | **0** (ogółem=0.0%, migracja=0.0%) |
| Odrzucone (strażnik jakości) % | **3.4%** |
| Cykle bez postępu % | **19.7%** |
| Przepustowość (kluczy/h) | **277.3 kluczy/h** |
| Podejrzane tłumaczenia | **455** |
| Najgorsze cele (strażnik) | ru/html.json (gf=8), ro/html.json (gf=6), it/html.json (gf=0), nl/html.json (gf=0), it/website_i18n.json (gf=0) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl`, `i18n/status/deferred_translation_queue.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

### 🚫 Odrzucenia wg reason (1h)
| Reason | Odrzucone | Udział | TOP język/plik |
|--------|-----------|--------|----------------|
| `retry_loop_cooldown_default` | 24 | 61.5% | it/website_i18n.json (7) |
| `gt_identity_retry_identical_to_en` | 13 | 33.3% | cs/website_i18n.json (4) |
| `gt_structure_retry_placeholder` | 2 | 5.1% | ro/html.json (2) |

## 🔬 JAKOŚĆ TŁUMACZEŃ

> **[QUALITY]** 🔒 NIEAKTYWNY (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 8s temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-06-07T19:10:36.017210Z

- **Ostatni audyt:** OK | 5 issue(s) / 100 entries | 2026-06-07T19:10:36.017210Z
- **Top 5 typów problemów:** suspicious_rejected_high=104, suspicious_log_critical=99, suspicious_rejected_critical=96, suspicious_log_warning=80, identical_to_en_exempt=38
- **Języki o najsłabszej jakości:** ru(60.1, issues=431156), it(60.1, issues=191428), de(60.1, issues=164512), cs(60.1, issues=163276), nl(60.1, issues=80011)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 🧾 Item Name Grammar Audit
| Metryka | Wartość |
|---------|---------|
| Status | 🔴 REVIEW |
| Lang | ALL |
| Checked languages | 52 |
| Checked item names | 931,384 |
| Equipment/weapon candidates | 57,308 |
| Issues | 49,761 |
| Issues shown in report | 1,200 |
| Generated | 2026-05-24T17:30:13.680537Z |

| Lang | Issues | High | Medium | Equipment candidates |
|------|--------|------|--------|----------------------|
| `de` | 1,149 | 1,149 | 0 | 1,244 |
| `ar` | 1,064 | 1,064 | 0 | 1,064 |
| `zh` | 1,063 | 1,063 | 0 | 1,064 |
| `zh_TW` | 1,063 | 1,063 | 0 | 1,064 |
| `ja` | 1,061 | 1,061 | 0 | 1,064 |
| `tl` | 1,061 | 1,061 | 0 | 1,064 |
| `sv` | 1,060 | 1,060 | 0 | 1,064 |
| `bn` | 1,059 | 1,059 | 0 | 1,064 |
| `fa` | 1,059 | 1,059 | 0 | 1,064 |
| `he` | 1,059 | 1,059 | 0 | 1,064 |
| `hi` | 1,059 | 1,059 | 0 | 1,064 |
| `hr` | 1,059 | 1,059 | 0 | 1,064 |

| Key | EN | Current | Suggested | Severity |
|-----|----|---------|-----------|----------|
| `item.10009.name` | flask of crown polisher | [EN] flask of crown polisher | provider_retranslate | high |
| `item.10183.name` | flask of poison | [EN] flask of poison | provider_retranslate | high |
| `item.10189.name` | flask of extra greasy oil | [EN] flask of extra greasy oil | provider_retranslate | high |
| `item.10200.name` | crystal boots | [EN] crystal boots | provider_retranslate | high |
| `item.10201.name` | dragon scale boots | [EN] dragon scale boots | provider_retranslate | high |
| `item.10323.name` | guardian boots | [EN] guardian boots | provider_retranslate | high |
| `item.10384.name` | Zaoan armor | [EN] Zaoan armor | provider_retranslate | high |
| `item.10385.name` | Zaoan helmet | [EN] Zaoan helmet | provider_retranslate | high |
| `item.10387.name` | Zaoan legs | [EN] Zaoan legs | provider_retranslate | high |
| `item.10390.name` | Zaoan sword | [EN] Zaoan sword | provider_retranslate | high |
| `item.10438.name` | spellweaver's robe | [EN] spellweaver's robe | provider_retranslate | high |
| `item.10439.name` | Zaoan robe | [EN] Zaoan robe | provider_retranslate | high |

> Źródło: `i18n/status/item_name_grammar_audit_latest.json` (read-only, bez providerów i bez modyfikacji tłumaczeń)

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#26** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **4,466** | realny stan EN |
| 🤖 Kluczy z rejestru workera (efektywne) | **75,129** | raw + reconcile |
| 🧾 Kluczy z rejestru workera (raw) | **600** | historia runów workera |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## ⚠️ Problemy i uwagi

⚠️ **TR**: jakość 66%, 68904 problemów
⚠️ **PL**: jakość 76%, 397882 problemów
⚠️ **AZ**: jakość 70%, 1417 problemów
⚠️ **ES**: jakość 82%, 782883 problemów
⚠️ **PT**: jakość 60%, 64123 problemów
⚠️ **FR**: jakość 62%, 69551 problemów
⚠️ **IT**: jakość 60%, 191428 problemów
⚠️ **RU**: jakość 60%, 431156 problemów
⚠️ **NL**: jakość 60%, 80011 problemów
⚠️ **SV**: jakość 74%, 68647 problemów

---

## 📜 Ostatnie komendy

- Brak dostępnych komend.

---

## 🏥 Zdrowie systemu

| Komponent | Status | Szczegóły |
|-----------|--------|-----------|
| Worker | 🟢 DZIAŁA | Cykl #21,218 |
| Heartbeat | 146s temu | 2026-06-07T19:08:18Z |
| Uptime | - | od startu workera |

---

## � Kolejka napraw (kopie EN)

- **Łącznie kopii EN do naprawy:** 741
- **TOP 5 języków:** DE (17,948), CS (14,502), NL (13,405), FR (12,501), PT (10,805)
- **Aktualnie naprawia:** ES / -
- **Ostatnia aktualizacja:** 2026-06-07T19:09:59.153806Z

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** AUTO_TRANSLATE  
> **Aktualna kategoria:** it


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
| 📄 HTML Views | 🔄 | 2062/2500 (82%) | 2500 |
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
| 🇩🇪 Niemiecki | ✅ Sync | 8048 | [EN] prefix |
| 🇵🇱 Polski | ✅ Sync | 65483 | [EN] prefix |
| 🇪🇸 Hiszpański | ✅ Sync | 59606 | [EN] prefix |
| 🇫🇷 Francuski | ✅ Sync | 44781 | [EN] prefix |
| 🌐 Pozostałe (11/53) | 🔄 | 858527 | Aktualnie: TR |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 52/53
- Ostatni sync: TR/html.json

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
> Świeżość: 2min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-06-07T19:08:18Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #21,218 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 DZIAŁA                                 │
│ Tryb:      🤖 AUTO_TRANSLATE (cycle_end)             │
│ Kategoria: 📁 IT                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: -                                                       │
│ Postęp: -                                                     │
│ Info: cycle end                                               │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-06-07T19:08:18Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-06-07 19:10:35 | AUTO_TRANSLATE:auto_done | it | ok | html.json
- 2026-06-07 19:10:11 | AUTO_TRANSLATE:heartbeat_tick | it | ok | html.json
- 2026-06-07 19:10:11 | AUTO_TRANSLATE:auto_start | it | ok | html.json
- 2026-06-07 19:09:59 | AUTO_TRANSLATE:auto_done | ro | ok | html.json
- 2026-06-07 19:09:18 | AUTO_TRANSLATE:heartbeat_tick | ro | ok | html.json
- 2026-06-07 19:09:17 | AUTO_TRANSLATE:auto_start | ro | ok | html.json

---

## 📊 Wskaźniki KPI — Zdrowie Pilotów (PL/ES)

| Język | Pokrycie | Brakujące | Kopie EN | Przetłumaczone(200) | Odrzucone | Wpisy |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 59.6% | 0 | 54 | 0 | 0 (0.0%) | 10 |
| 🔴 ES | 21.8% | 0 | 29 | 0 | 0 (0.0%) | 11 |

| Wskaźnik | Wartość | Cel | Status |
|-----|---------|--------|--------|
| Tłumaczeń netto | **172,841** | — | 📊 |
| Adaptacyjna paczka | batch=50, gf_rate=0.0%, reason=increase_low_fail_rate=0.0%, filter=exclude_repair | odrzucenia <5% → zwiększ | 📊 |
| Przepustowość (okno) | 0 kluczy / 21 wpisów | >50/h | 📊 |

---

## 📜 HISTORIA

> **[HISTORY]** 🟢 AKTYWNY  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-06-07 19:10:42

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [it] → warn (files+1, translated+10, skipped+0) — lang=it file=html.json strict_skipped_done=47
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ru] → warn (files+0, translated+0, skipped+0) — lang=ru file=php.json strict_skipped_done=9 guard_fail=5 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [cs] → error (files+0, translated+0, skipped+0) — lang=cs file=website_i18n.json runtime_error=1
- 🤖 AUTO_TRANSLATE: WEBSITE_I18N_APPLY [de] → ok — keys_updated=100 files_changed=1
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+41, skipped+0) — lang=de file=website_i18n.json
- • DOCTOR_REMEDIATION: AUTO_COMMAND [-] → ok — action=force_auto reason=write_starvation_or_queue_starvation
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+0) — repair_identical lang=es file=npc.json target_identical=2 limit=108 tier=low_backlog+suspicious_guard domain_cap=260 gt=true suspicious_pct=79.27
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ro] → warn (files+1, translated+24, skipped+0) — lang=ro file=items.json strict_skipped_done=1496
- • DOCTOR_REMEDIATION: ALARM_RESOLVED [-] → ok — resolved_count=1
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+2) — repair_identical lang=es file=npc.json target_identical=2 limit=108 tier=low_backlog+suspicious_guard domain_cap=260 gt=true suspicious_pct=133.87


## 📅 Dziś (2026-06-07)

| Metryka | Wartość |
|---------|---------|
| ✅ Przetłumaczono | **1,929** kluczy |
| ⏭️ Pominięte | 0 |
| 🔁 Cykli | 97 |
| ❌ Błędów | 509 |
| 🌍 Aktywnych języków | 11 |
| 🏆 TOP 5 | **TR** (249), **FR** (220), **IT** (216), **ES** (209), **PT** (196) |
| 📊 Porównanie | brak danych z wczoraj |

## 📆 Ten tydzień (7 dni)

> Suma tygodnia: **1,929** kluczy

| Dzień | Wykres | Przetłumaczono | Cykli |
|-------|--------|---------------|-------|
| 2026-06-01 | ░ | 0 | 0 |
| 2026-06-02 | ░ | 0 | 0 |
| 2026-06-03 | ░ | 0 | 0 |
| 2026-06-04 | ░ | 0 | 0 |
| 2026-06-05 | ░ | 0 | 0 |
| 2026-06-06 | ░ | 0 | 0 |
| 2026-06-07 | ██████████████████████████████████████████████████ | 1,929 | 97 |

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych (LIVE registry) | **119** | z `i18n_file_status.json` |
| 📚 Plików przeskanowanych (historia) | **6,546** | z `i18n_processed_files.txt` |
| ↕️ Historia minus LIVE | **+6,427** | dodatnie = historia > LIVE |
| ✅ Plików z kluczami | **51** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **68** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych (LIVE) | **4,466** | realny stan `i18n/en/*.json` |
| 🤖 Kluczy wyciągniętych przez workera (efektywne) | **75,129** | raw + reconcile |
| 🧾 Kluczy wyciągniętych przez workera (raw) | **600** | z `i18n_file_status.json` |
| 🧩 Reconcile korekta rejestru | **74,529** | zmiany EN poza workerem |
| ➕ Kluczy poza rejestrem workera | **0** | ręczne/Codex/Claude/starsze |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#21,218** | continuous mode |

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
| website_i18n | 2345 | 0 | 0 | ✅ Active |
| scripts | 2170 | 0 | 0 | ✅ Active |
| html | 2062 | 0 | 0 | ✅ Active |
| otclient_modules | 2031 | 0 | 0 | ✅ Active |
| questlog | 1918 | 0 | 0 | ✅ Active |
| spells | 1534 | 0 | 0 | ✅ Active |
| books | 1403 | 0 | 0 | ✅ Active |
| achievements | 1048 | 0 | 0 | ✅ Active |
| cpp | 879 | 0 | 0 | ✅ Active |
| quests | 610 | 0 | 0 | ✅ Active |
| talkactions | 358 | 0 | 0 | ✅ Active |
| raids | 273 | 0 | 0 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
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
| Worker v1.1 | 🟢 DZIAŁA | Cykl #21,218 |
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
| 🌍 Html | 2062 | ████████████████░░░░ | 2500 | 🔄 82% |
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
| 🗣️ Talkactions | 358 | ████████████████████ | 358 | ✅ 100% |
| 🎨 Ui | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |
| 📁 Website_i18n | 2345 | ████████████████████ | 2345 | ✅ 100% |
| 🌎 World | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2026-06-07 19:10:42  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `GuildInvite.php` - ukończono 2026-06-07 21:08
- ✅ `Gallery.php` - ukończono 2026-06-07 21:08
- ✅ `MigrateToCommand.php` - ukończono 2026-06-07 21:08
- ✅ `Forum.php` - ukończono 2026-06-07 21:02
- ✅ `ServerRecord.php` - ukończono 2026-06-07 21:02
- ✅ `Weapon.php` - ukończono 2026-06-07 20:58
- ✅ `BugTracker.php` - ukończono 2026-06-07 20:58
- ✅ `PlayerStorage.php` - ukończono 2026-06-07 20:52
- ✅ `Changelog.php` - ukończono 2026-06-07 20:52
- ✅ `PlayerItem.php` - ukończono 2026-06-07 20:45

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
