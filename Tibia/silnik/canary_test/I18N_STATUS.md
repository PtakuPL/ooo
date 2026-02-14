# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 04:21:29

> **Aktualizacja:** 2026-02-14 04:21:29 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #8 | Status: 🟢 RUNNING | Faza: AUTO_TRANSLATE | Etap: auto_start | Kategoria: de | Plik: items.json | ETA: 0 | Heartbeat: 2026-02-14T04:21:04Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=86 | pending_skip=0.0% | guard_fail=12.6% | throughput=1130.3/h  
> **Net effective translated:** 55,842

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 04:21:29 |
| LIVE | 🟢 ACTIVE | 25s temu | - | `activity.json / worker_state.json` | 2026-02-14T04:21:04Z |
| MIGRATION | 🔒 INACTIVE | 9h temu | worker w trybie AUTO_TRANSLATE | `i18n_file_status.json` | 2026-02-14 04:21:29 |
| TRANSLATION | 🟢 ACTIVE | 35s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T04:20:54.696695Z |
| QUALITY | 🔒 INACTIVE | 34s temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-02-14T04:20:54.992021Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 04:21:29 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 25s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T04:21:04Z

- **Faza:** `AUTO_TRANSLATE`
- **Etap:** `auto_start`
- **Kategoria:** `de`
- **Plik:** `items.json`
- **Status:** 🟢 RUNNING
- **Heartbeat:** `2026-02-14T04:21:04Z`

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
| `SKIP` / `PAUSE:<N>` / `IDLE` | Kontrola cyklu |

---

## 🛠️ MIGRATION

> **[MIGRATION]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 9h temu | Źródło: `i18n_file_status.json` | Ostatnia aktualizacja: 2026-02-14 04:21:29

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,257** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,393** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,443** | **68.6%** | historia workera |
| ⏳ Nie przeskanowane | **2,950** | 31.4% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,497 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **1897** | 29.4% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **400** | - | bez tekstów |
| 🔧 W trakcie | **2** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **53,586** | wszystkie kategorie |
| 📊 NPC | 13,769 | dialogi NPC |
| 📊 Items | 17,057 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 15,350 | scripts, spells, etc. |

## 🌍 TRANSLATION

> **[TRANSLATION]** 🟢 ACTIVE  
> Świeżość: 35s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T04:20:54.696695Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 43,627/53,586 | 81.41% | 12,325 | 232 |
| PL (Polski) | 40,165/53,586 | 74.95% | 2,856 | 2,083 |
| AR (Arabski) | 11,767/53,586 | 21.96% | 31,208 | 2,150 |
| ID (ID) | 11,621/53,586 | 21.69% | 29,282 | 2,155 |
| BN (BN) | 11,613/53,586 | 21.67% | 29,289 | 2,155 |
| FA (FA) | 11,613/53,586 | 21.67% | 29,289 | 2,155 |
| HE (HE) | 11,610/53,586 | 21.67% | 29,287 | 2,155 |
| HI (HI) | 11,612/53,586 | 21.67% | 29,290 | 2,155 |
| HY (HY) | 11,613/53,586 | 21.67% | 29,289 | 2,155 |
| KA (KA) | 11,613/53,586 | 21.67% | 29,289 | 2,155 |
| KO (Koreański) | 11,610/53,586 | 21.67% | 29,281 | 2,155 |
| SW (SW) | 11,612/53,586 | 21.67% | 29,283 | 2,155 |
| TA (TA) | 11,612/53,586 | 21.67% | 29,282 | 2,155 |
| TE (TE) | 11,612/53,586 | 21.67% | 29,282 | 2,155 |
| TH (TH) | 11,612/53,586 | 21.67% | 29,282 | 2,155 |
| TL (TL) | 11,612/53,586 | 21.67% | 29,291 | 2,155 |
| VI (VI) | 11,614/53,586 | 21.67% | 29,280 | 2,155 |
| ML (ML) | 11,609/53,586 | 21.66% | 29,286 | 2,155 |
| JA (Japoński) | 11,567/53,586 | 21.59% | 29,314 | 2,155 |
| ZH_TW (ZH_TW) | 11,541/53,586 | 21.54% | 29,311 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** PL - Polski - Serwer
- **Plik JSON:** quests.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- Come back whenever you're in need of wisdom. → Vuelve cuando necesites sabiduría. (data.otservbr.global.npc.edowir.L63.1250)
- Welcome to Edron Furniture Store, |PLAYERNAME|. → Bienvenido a la tienda de muebles Edron, |PLAYERNAME|. (data.otservbr.global.npc.edvard.L61.1319)
- Have a look. Most furniture comes in handy kits. Just use them in your house to  → Échale un vistazo. La mayoría de los muebles vienen en prácticos kits. Utilízalo (data.otservbr.global.npc.edvard.L62.1320)
- Welcome to the paladins' guild, |PLAYERNAME|! How can I help you? → ¡Bienvenido al gremio de paladines, |PLAYERNAME|! ¿Le puedo ayudar en algo? (data.otservbr.global.npc.elane.L242.585)
- Be greeted |PLAYERNAME|. What is your {business} near the {hellgate}? → Sea saludado |PLAYERNAME|. ¿Cuál es tu {business} cerca del {hellgate}? (data.otservbr.global.npc.elathriel.L236.784)
- Be greeted. What brings you {here}? → Sea saludado. ¿Qué te trae {here}? (data.otservbr.global.npc.eleonore.L145.243)
- Be greeted, |PLAYERNAME|. Which of my fine gems do you {need}? → Sea saludado, |PLAYERNAME|. ¿Cuál de mis finas gemas prefieres {need}? (data.otservbr.global.npc.eliyas.L68.1302)
- Daraman's blessings and good bye. → Bendiciones de Daraman y adiós. (data.otservbr.global.npc.eliyas.L69.1303)
- Daraman's blessings and good bye. → Bendiciones de Daraman y adiós. (data.otservbr.global.npc.eliyas.L70.1304)
- <nods> Yeah. → <nods> Sí. (data.otservbr.global.npc.elliott.L130.32)
- A shadow preceded you. You wish a {scroll} or a {mission}? → Una sombra te precedió. ¿Quieres un {scroll} o un {mission}? (data.otservbr.global.npc.elyen.ravenlock.L106.387)
- I wish you a good hunt. Goodbye! → Te deseo una buena caza. ¡Adiós! (data.otservbr.global.npc.emael.L95.1464)
- LONG LIVE THE QUEEN! You may leave now! → ¡VIVA LA REINA! ¡Puedes irte ahora! (data.otservbr.global.npc.emma.L294.239)
- What the... I mean, of course I sensed you. → ¿Qué...? Quiero decir, por supuesto que te sentí. (data.otservbr.global.npc.erayo.L130.1378)
- Welcome to my little garden, adventurer |PLAYERNAME|! → ¡Bienvenido a mi pequeño jardín, aventurero |PLAYERNAME|! (data.otservbr.global.npc.eremo.L218.525)
- It was a pleasure to help you, |PLAYERNAME|. → Fue un placer ayudarte, |PLAYERNAME|. (data.otservbr.global.npc.eremo.L219.526)
- It was a pleasure to help you, |PLAYERNAME|. → Fue un placer ayudarte, |PLAYERNAME|. (data.otservbr.global.npc.eremo.L220.527)
- Asha Thrazi. Go, where you have to go. → Asha Thrázi. Ve, donde tienes que ir. (data.otservbr.global.npc.eroth.L102.510)
- Ashari Lillithy, so we meet {again}! What brings you here this time, general {in → Ashari Lillithy, ¡entonces conocemos a {again}! ¿Qué te trae por aquí esta vez,  (data.otservbr.global.npc.eruaran.L210.791)
- Suon's and Bastesh's blessing, dear guest! → ¡La bendición de Suon y Bastesh, querido invitado! (data.otservbr.global.npc.eshaya.L133.672)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **1873**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1823**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **20.68%** (576,123/2,786,472)
- **EN-copy łącznie:** **1,336,325**
- **Braki kluczy łącznie:** **110,060**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **warm-cache** | hit **52**, miss **0**, hit-rate **100.0%**
- **Cache STATUSPY (per-file):** hit **1976**, miss **0**, hit-rate **100.0%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T03:21:29.639139Z → 2026-02-14T04:21:29.639139Z) |
| Cykle | **86** (AUTO=86, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **12.6%** |
| No progress rate | **2.4%** |
| Throughput | **1130.3 kluczy/h** |
| Suspicious | **604** |
| Top guard_fail targets | es/npc.json (gf=69), pl/npc.json (gf=41), zh/items.json (gf=38), zh_tw/items.json (gf=38), pl/otclient_modules.json (gf=29) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 34s temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T04:20:54.992021Z

- **Ostatni audyt:** OK | 0 issue(s) / 100 entries | 2026-02-14T04:20:54.992021Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_critical=171, identical_to_en_exempt=28, suspicious_log_low=28, suspicious_log_high=1
- **Języki o najsłabszej jakości:** es(60.1, issues=128599), pl(60.1, issues=101755), ru(61.5, issues=4093), ar(61.7, issues=1608), sr(63.4, issues=645)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#8** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **6,248** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 52/53  
- Ostatni sync: PL/scripts.json

### 🌍 Etap 2: Tłumaczenia (AUTO + TM)
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

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** AUTO_TRANSLATE  
> **Aktualna kategoria:** de


### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | ✅ | 13769/15000 (92%) | 15000 |
| 📜 Lua Scripts | 🔄 | 2170/2500 (87%) | 2500 |
| 🎒 Items Database | 🔄 | 17057/40000 (43%) | 40000 |
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
| 🎮 OTClient Modules | ✅ | 1987/2000 (99%) | 2000 |
| 📦 OTClient Data | 🔄 | 72/200 (36%) | 200 |
| ⚙️ OTClient Src | ⏳ | 0/300 (0%) | 300 |
| 🔧 OTClient Mods | ⏳ | 0/100 (0%) | 100 |
| 🛠️ OTClient Tools | ⏳ | 0/50 (0%) | 50 |

### ⏳ Faza 4: 🌍 Tłumaczenia (Etap 1: Sync Kluczy)

| Język | Status | Kluczy | Etap |
|-------|--------|--------|------|
| 🇩🇪 Niemiecki | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🇵🇱 Polski | 🔄 Sync... | 3596 | [EN] prefix |
| 🇪🇸 Hiszpański | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🇫🇷 Francuski | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🌐 Pozostałe (0/53) | 🔄 | 388981 | Aktualnie: PL |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 52/53
- Ostatni sync: PL/scripts.json

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

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 25s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T04:21:04Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     8 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🤖 AUTO_TRANSLATE (auto_start)            │
│ Kategoria: 📁 DE                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: items.json                                              │
│ Postęp: 0/0 keys                                              │
│ Info: auto translate                                          │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T04:21:04Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 04:21:04 | AUTO_TRANSLATE:auto_start | de | ok | items.json
- 2026-02-14 04:20:51 | AUTO_TRANSLATE:parallel_start | es | ok | server.json
- 2026-02-14 04:20:08 | AUTO_TRANSLATE:auto_done | pl | ok | quests.json
- 2026-02-14 04:20:04 | AUTO_TRANSLATE:auto_start | pl | ok | quests.json
- 2026-02-14 04:17:15 | AUTO_TRANSLATE:parallel_start | es | ok | monsters.json
- 2026-02-14 04:16:33 | AUTO_TRANSLATE:auto_done | pl | ok | monsters.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 75.0% | 2,083 | 2,856 | 686 | 254 (27.0%) | 21 |
| 🟡 ES | 81.4% | 232 | 12,325 | 594 | 250 (29.6%) | 21 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **55,842** | — | 📊 |
| Adaptive batch | batch=9, gf_rate=21.98%, reason=decrease_high_fail_rate=22.0% | gf <5% → increase | 📊 |
| Throughput (last window) | 1,280 keys / 42 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 04:21:29

- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [es] → ok (translated+80, skipped+0) — parallel lang=es file=questlog.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+5, skipped+0) — lang=pl file=otclient_modules.json strict_skipped_done=1982 guard_fail=29 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+2, skipped+0) — parallel lang=pl file=client.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [zh_TW] → warn (files+1, translated+51, skipped+0) — lang=zh_TW file=npc.json strict_skipped_done=1169 guard_fail=29 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [hy] → ok (translated+80, skipped+0) — parallel lang=hy file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [hu] → warn (files+1, translated+80, skipped+0) — lang=hu file=npc.json strict_skipped_done=1145
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+76, skipped+0) — parallel lang=pl file=monsters.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+38, skipped+0) — lang=es file=npc.json strict_skipped_done=4687 guard_fail=42 placeholder=39 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [ar] → ok (translated+80, skipped+0) — parallel lang=ar file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [cs] → warn (files+1, translated+80, skipped+0) — lang=cs file=npc.json strict_skipped_done=582




## 📅 Dziś (UTC)

- Cykle: **49**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **162**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **2299** | w tej sesji |
| ✅ Plików z kluczami | **1897** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **402** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **6248** | przez workera w tej sesji |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#8** | continuous mode |

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
<summary>🎒 2. Items - 🔄 (43%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 17057 |
| 🎯 Cel | 40000 |
| 📊 Postęp | 43% |
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
<summary>🧙 5. NPC - ✅ (92%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 13769 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 92% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | 1027 |
| ✅ Zmigrowanych | 699 |
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
| items | 17057 | 0 | 0 | ✅ Active |
| npc | 13769 | 0 | 0 | ✅ Active |
| monsters | 5915 | 0 | 0 | ✅ Active |
| server | 2574 | 0 | 0 | ✅ Active |
| scripts | 2170 | 0 | 0 | ✅ Active |
| otclient_modules | 1987 | 0 | 0 | ✅ Active |
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

## 🤖 Worker Category State

*Brak kategorii z aktywnym skip*

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #8 |
| Guardian v2.0 | 🟢 ACTIVE | Push co 2 min |

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
| **Tier 2** | de, fr, it, pt, ru, tr | ×2 | 50% |
| **Tier 3** | reszta (44) | ×1 | 30% |

**Priorytet kategorii:** items → npc → monsters → server → spells → quests → scripts → actions → raids

> Tier 1 przetwarza 4 pliki per super-rundę, Tier 2 przetwarza 2, Tier 3 przetwarza 1.


---

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
| 🏆 Achievements | 1048 | ████████████████████ | 1048 | ✅ 100% |
| ⚡ Actions | 35 | ███████░░░░░░░░░░░░░ | 100 | 🔄 35% |
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
| 🎒 Items | 17057 | ████████░░░░░░░░░░░░ | 40000 | 🔄 43% |
| 📚 Libs | 89 | █████████████████░░░ | 100 | 🔄 89% |
| ✉️ Messages | 11 | ██░░░░░░░░░░░░░░░░░░ | 100 | 🔄 11% |
| 📦 Modules | 19 | ███░░░░░░░░░░░░░░░░░ | 100 | 🔄 19% |
| 👹 Monsters | 5915 | ███████████████████░ | 6000 | ✅ 99% |
| 🐴 Mounts | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |
| 🚶 Movements | 2 | ░░░░░░░░░░░░░░░░░░░░ | 100 | 🔄 2% |
| 🧙 Npc | 13769 | ██████████████████░░ | 15000 | ✅ 92% |
| 📜 Npclib | 147 | ████████████████████ | 147 | ✅ 100% |
| 📊 Otclient_data | 72 | ███████░░░░░░░░░░░░░ | 200 | 🔄 36% |
| 🔧 Otclient_mods | 0 | ░░░░░░░░░░░░░░░░░░░░ | 100 | ⏳ 0% |
| 🧩 Otclient_modules | 1987 | ███████████████████░ | 2000 | ✅ 99% |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 04:21:29  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `account_repository_db.hpp` - ukończono 2026-02-13 18:50
- ✅ `account.hpp` - ukończono 2026-02-13 18:50
- ✅ `pch.cpp` - ukończono 2026-02-13 18:50
- ✅ `game_definitions.hpp` - ukończono 2026-02-13 18:50
- ✅ `zone.hpp` - ukończono 2026-02-13 18:50
- ✅ `npc_handler` - ukończono 2026-02-13 18:49
- ✅ `modules` - ukończono 2026-02-13 18:49
- ✅ `bank_system` - ukończono 2026-02-13 18:49
- ✅ `keyword_handler` - ukończono 2026-02-13 18:49
- ✅ `custom_modules` - ukończono 2026-02-13 18:49

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
