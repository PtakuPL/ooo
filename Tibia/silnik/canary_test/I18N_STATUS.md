# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 02:09:35

> **Aktualizacja:** 2026-02-14 02:09:35 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #10 | Status: ✅ IDLE | Faza: IDLE | Etap: cycle_start | Kategoria: - | Plik: - | ETA: 0 | Heartbeat: 2026-02-14T02:09:04Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=89 | pending_skip=0.0% | guard_fail=2.5% | throughput=1721.6/h  
> **Net effective translated:** 50,405

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 02:09:35 |
| LIVE | 🟢 ACTIVE | 32s temu | - | `activity.json / worker_state.json` | 2026-02-14T02:09:04Z |
| MIGRATION | 🔒 INACTIVE | 7h temu | worker w trybie IDLE | `i18n_file_status.json` | 2026-02-14 02:09:35 |
| TRANSLATION | 🔒 INACTIVE | 2min temu | worker w trybie IDLE | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T02:06:42.883283Z |
| QUALITY | 🔒 INACTIVE | 41s temu | worker w trybie IDLE | `quality_audit_latest.json` | 2026-02-14T02:08:55.376662Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 02:09:35 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 32s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T02:09:04Z

- **Faza:** `IDLE`
- **Etap:** `cycle_start`
- **Kategoria:** `-`
- **Plik:** `-`
- **Status:** ✅ IDLE
- **Heartbeat:** `2026-02-14T02:09:04Z`

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

> **[MIGRATION]** 🔒 INACTIVE (worker w trybie IDLE)  
> Świeżość: 7h temu | Źródło: `i18n_file_status.json` | Ostatnia aktualizacja: 2026-02-14 02:09:35

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,250** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,386** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,443** | **68.6%** | historia workera |
| ⏳ Nie przeskanowane | **2,943** | 31.4% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,490 | konfiguracje |

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

> **[TRANSLATION]** 🔒 INACTIVE (worker w trybie IDLE)  
> Świeżość: 2min temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T02:06:42.883283Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 42,105/53,586 | 78.57% | 13,346 | 232 |
| PL (Polski) | 39,709/53,586 | 74.10% | 2,917 | 2,083 |
| AR (Arabski) | 11,687/53,586 | 21.81% | 31,153 | 2,150 |
| ID (ID) | 11,541/53,586 | 21.54% | 29,276 | 2,155 |
| BN (BN) | 11,533/53,586 | 21.52% | 29,284 | 2,155 |
| FA (FA) | 11,533/53,586 | 21.52% | 29,284 | 2,155 |
| HE (HE) | 11,530/53,586 | 21.52% | 29,281 | 2,155 |
| HI (HI) | 11,532/53,586 | 21.52% | 29,284 | 2,155 |
| HY (HY) | 11,533/53,586 | 21.52% | 29,284 | 2,155 |
| KA (KA) | 11,533/53,586 | 21.52% | 29,284 | 2,155 |
| KO (Koreański) | 11,533/53,586 | 21.52% | 29,276 | 2,155 |
| SW (SW) | 11,532/53,586 | 21.52% | 29,277 | 2,155 |
| TA (TA) | 11,532/53,586 | 21.52% | 29,277 | 2,155 |
| TE (TE) | 11,532/53,586 | 21.52% | 29,277 | 2,155 |
| TH (TH) | 11,532/53,586 | 21.52% | 29,277 | 2,155 |
| TL (TL) | 11,532/53,586 | 21.52% | 29,278 | 2,155 |
| VI (VI) | 11,534/53,586 | 21.52% | 29,275 | 2,155 |
| ML (ML) | 11,529/53,586 | 21.51% | 29,281 | 2,155 |
| JA (Japoński) | 11,503/53,586 | 21.47% | 29,309 | 2,155 |
| ZH_TW (ZH_TW) | 11,499/53,586 | 21.46% | 29,306 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** ES - Hiszpański - Klient
- **Plik JSON:** html.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- All our reinforcements arrive at the crystal teleporter to the east of the cave  → Todos nuestros refuerzos llegan al teletransportador de cristal al este del sist (npc.gnomus.multi_18)
- Hideous creatures and hot lava makes travelling extremely dangerous. And on top  → Las horribles criaturas y la lava caliente hacen que viajar sea extremadamente p (npc.gnomus.multi_19)
- Take one from the stack here next to me and map as many structures as possible.  → Tome uno de la pila que está a mi lado y mapee tantas estructuras como sea posib (npc.gnomus.multi_2)
- Are you willing to help? → ¿Estás dispuesto a ayudar? (npc.gnomus.multi_20)
- I am constantly waiting for ordnance to arrive. A lot of gnomes intend to travel → Estoy constantemente esperando que lleguen las municiones. Muchos gnomos tienen  (npc.gnomus.multi_21)
- Tragically we lost several gnomes after an outbreak of what I can only describe  → Trágicamente perdimos varios gnomos después de un brote de lo que sólo puedo des (npc.gnomus.multi_22)
- All our reinforcements arrive at the crystal teleporter to the east of the cave  → Todos nuestros refuerzos llegan al teletransportador de cristal al este del sist (npc.gnomus.multi_23)
- Hideous creatures and hot lava makes travelling extremely dangerous. And on top  → Las horribles criaturas y la lava caliente hacen que viajar sea extremadamente p (npc.gnomus.multi_24)
- Are you willing to help? → ¿Estás dispuesto a ayudar? (npc.gnomus.multi_25)
- How fortunate! There are some trignometres lying around next to that device behi → ¡Qué suerte! Hay algunos trignometros al lado de ese dispositivo detrás de mí. T (npc.gnomus.multi_26)
- If you gathered enough data, you will actually smell it from the device. ... → Si recopiló suficientes datos, los olerá desde el dispositivo. ... (npc.gnomus.multi_27)
- Return to me with the results afterwards. Best of luck, we count on you! → Vuelve conmigo con los resultados después. ¡Mucha suerte, contamos contigo! (npc.gnomus.multi_28)
- Excellent, you returned with more data! Let me see... hmm. ... → Excelente, regresaste con más datos! Déjame ver... mmm. ... (npc.gnomus.multi_29)
- If you manage to map one of each structure around these parts - I assume there m → Si logras mapear una de cada estructura alrededor de estas partes (supongo que d (npc.gnomus.multi_3)
- Well, we need more data on this but first I will have to show this to our grand  → Bueno, necesitamos más datos sobre esto pero primero tendré que mostrárselo a nu (npc.gnomus.multi_30)
- The heat down here is not the only problem we have but one of our greatest conce → El calor aquí abajo no es el único problema que tenemos sino una de nuestras may (npc.gnomus.multi_31)
- We need to find out if this is true and what that means for this place - and for → Necesitamos descubrir si esto es cierto y qué significa para este lugar y para n (npc.gnomus.multi_32)
- We'd need at least 5 measurements. Are you willing to do this? → Necesitaríamos al menos 5 medidas. ¿Estás dispuesto a hacer esto? (npc.gnomus.multi_33)
- The heat down here is not the only problem we have but one of our greatest conce → El calor aquí abajo no es el único problema que tenemos sino una de nuestras may (npc.gnomus.multi_34)
- We need to find out if this is true and what that means for this place - and for → Necesitamos descubrir si esto es cierto y qué significa para este lugar y para n (npc.gnomus.multi_35)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **1777**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1727**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **20.43%** (569,253/2,786,472)
- **EN-copy łącznie:** **1,337,625**
- **Braki kluczy łącznie:** **110,060**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **warm-cache** | hit **52**, miss **0**, hit-rate **100.0%**
- **Cache STATUSPY (per-file):** hit **1976**, miss **0**, hit-rate **100.0%**
- **Profiler cyklu (ostatni):** cykl #9 (AUTO_TRANSLATE): dispatch 516ms, mode 138716ms, status 4405ms, total 144629ms
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T01:09:36.165731Z → 2026-02-14T02:09:36.165731Z) |
| Cykle | **89** (AUTO=89, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **2.5%** |
| No progress rate | **0.0%** |
| Throughput | **1721.6 kluczy/h** |
| Suspicious | **845** |
| Top guard_fail targets | ja/npc.json (gf=29), zh_tw/npc.json (gf=29), pl/client.json (gf=10), sr/npc.json (gf=9), es/html.json (gf=7) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie IDLE)  
> Świeżość: 41s temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T02:08:55.376662Z

- **Ostatni audyt:** SLOW_MODE | 37 issue(s) / 100 entries | 2026-02-14T02:08:55.376662Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_high=161, identical_to_en=37, suspicious_log_low=21, identical_to_en_exempt=18
- **Języki o najsłabszej jakości:** es(60.1, issues=119157), pl(60.1, issues=95511), ru(60.3, issues=3598), he(60.4, issues=785), te(60.5, issues=789)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#10** | od uruchomienia |
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

> **Aktualna faza:** IDLE  
> **Aktualna kategoria:** -


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
> Świeżość: 32s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T02:09:04Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #    10 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    ✅ IDLE                                   │
│ Tryb:      ✅ IDLE (cycle_start)                     │
│ Kategoria: -                                        │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: -                                                       │
│ Postęp: 0/0 units                                             │
│ Info: cycle start                                             │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T02:09:04Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 02:06:43 | AUTO_TRANSLATE:auto_done | es | ok | html.json
- 2026-02-14 02:06:36 | AUTO_TRANSLATE:auto_start | es | ok | html.json
- 2026-02-14 02:06:25 | AUTO_TRANSLATE:parallel_start | pl | ok | client.json
- 2026-02-14 02:05:43 | AUTO_TRANSLATE:auto_done | zh_TW | ok | npc.json
- 2026-02-14 02:04:57 | AUTO_TRANSLATE:auto_start | zh_TW | ok | npc.json
- 2026-02-14 02:04:49 | AUTO_TRANSLATE:parallel_start | zh | ok | npc.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 74.1% | 2,083 | 2,917 | 464 | 191 (29.2%) | 16 |
| 🟡 ES | 78.6% | 232 | 13,346 | 668 | 143 (17.6%) | 17 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **50,405** | — | 📊 |
| Adaptive batch | batch=50, gf_rate=5.33%, reason=stable_fail_rate=5.3% | gf <5% → increase | 📊 |
| Throughput (last window) | 1,132 keys / 33 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 02:09:35

- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [kk] → ok (translated+80, skipped+0) — parallel lang=kk file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ka] → warn (files+1, translated+80, skipped+0) — lang=ka file=npc.json strict_skipped_done=1141
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [de] → ok (translated+80, skipped+0) — parallel lang=de file=items.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+80, skipped+0) — lang=es file=server.json strict_skipped_done=102
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [bs] → ok (translated+80, skipped+0) — parallel lang=bs file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [bn] → warn (files+1, translated+80, skipped+0) — lang=bn file=npc.json strict_skipped_done=575
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+4, skipped+0) — parallel lang=pl file=client.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+80, skipped+0) — lang=es file=questlog.json strict_skipped_done=189
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+0, skipped+0) — parallel lang=pl file=example_merchant.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+0, translated+0, skipped+0) — lang=es file=chatchannels.json strict_skipped_done=16 guard_fail=1 placeholder=0 command=0 pipe=0




## 📅 Dziś (UTC)

- Cykle: **47**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **71**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **2299** | w tej sesji |
| ✅ Plików z kluczami | **1897** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **402** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **6248** | przez workera w tej sesji |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#10** | continuous mode |

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
| Worker v1.1 | 🟢 RUNNING | Cykl #10 |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 02:09:35  
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
