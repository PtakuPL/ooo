# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 11:30:47

> **Aktualizacja:** 2026-02-14 11:30:47 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #1 | Status: 🟢 RUNNING | Faza: AUTO_TRANSLATE | Etap: heartbeat_tick | Kategoria: pl | Plik: spells.json | ETA: 0 | Heartbeat: 2026-02-14T11:30:40Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=7 | pending_skip=0.0% | guard_fail=23.0% | throughput=182239.8/h  
> **Net effective translated:** 66,459

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 11:30:47 |
| LIVE | 🟢 ACTIVE | 8s temu | - | `activity.json / worker_state.json` | 2026-02-14T11:30:40Z |
| MIGRATION | 🔒 INACTIVE | 16h temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-02-14 11:30:47 |
| TRANSLATION | 🟢 ACTIVE | 8s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T11:30:39.363617Z |
| QUALITY | 🔒 INACTIVE | 19min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-02-14T11:11:27.785819Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 11:30:47 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 8s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T11:30:40Z

- **Faza:** `AUTO_TRANSLATE`
- **Etap:** `heartbeat_tick`
- **Kategoria:** `pl`
- **Plik:** `spells.json`
- **Status:** 🟢 RUNNING
- **Heartbeat:** `2026-02-14T11:30:40Z`

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
> Świeżość: 16h temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-02-14 11:30:47

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,325** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,435** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,443** | **68.3%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **2,299** | **24.4%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **2,992** | 31.7% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **7,136** | 75.6% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,539 | konfiguracje |

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
| 🧮 **Klucze wyekstrahowane (LIVE)** | **53,586** | realny stan `i18n/en/*.json` |
| 🤖 Klucze z rejestru workera (efektywne) | **53,586** | `5_extraction_en.keys_added` + reconcile |
| 🧾 Klucze z rejestru workera (raw) | **6,248** | suma `5_extraction_en.keys_added` |
| 🧩 Reconcile korekta rejestru | **47,338** | zmiany EN poza workerem |
| ➕ Klucze poza rejestrem workera | **0** | ręczne zmiany / starsze migracje |
| 📊 NPC | 13,769 | dialogi NPC |
| 📊 Items | 17,057 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 15,350 | scripts, spells, etc. |

## 🌍 TRANSLATION

> **[TRANSLATION]** 🟢 ACTIVE  
> Świeżość: 8s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T11:30:39.363617Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 44,986/53,586 | 83.95% | 11,173 | 232 |
| PL (Polski) | 39,871/53,586 | 74.41% | 2,861 | 2,083 |
| RU (Rosyjski) | 29,622/53,586 | 55.28% | 37,555 | 174 |
| FR (Francuski) | 28,738/53,586 | 53.63% | 29,690 | 174 |
| RO (Rumuński) | 13,778/53,586 | 25.71% | 23,957 | 174 |
| BN (BN) | 13,116/53,586 | 24.48% | 33,937 | 2,155 |
| AR (Arabski) | 13,114/53,586 | 24.47% | 34,050 | 2,150 |
| FA (FA) | 13,008/53,586 | 24.27% | 34,256 | 2,155 |
| HI (HI) | 12,764/53,586 | 23.82% | 34,326 | 2,155 |
| ID (ID) | 12,700/53,586 | 23.70% | 34,332 | 2,155 |
| JA (Japoński) | 12,648/53,586 | 23.60% | 34,403 | 2,155 |
| HE (HE) | 12,633/53,586 | 23.58% | 34,475 | 2,155 |
| KO (Koreański) | 12,618/53,586 | 23.55% | 34,479 | 2,155 |
| HY (HY) | 12,557/53,586 | 23.43% | 34,699 | 2,155 |
| ML (ML) | 12,552/53,586 | 23.42% | 34,475 | 2,155 |
| MS (MS) | 12,530/53,586 | 23.38% | 34,676 | 2,155 |
| KA (KA) | 12,510/53,586 | 23.35% | 34,600 | 2,155 |
| TE (TE) | 12,343/53,586 | 23.03% | 34,866 | 2,155 |
| SW (SW) | 12,330/53,586 | 23.01% | 34,786 | 2,155 |
| TH (TH) | 12,331/53,586 | 23.01% | 34,886 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** HI - HI - Serwer
- **Plik JSON:** monsters.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- Greetings, member of the Bigfoot Brigade. We could really use some {help} from y → Saludos, miembro de la Brigada Bigfoot. Realmente nos vendría bien algo de {help (data.otservbr.global.npc.gnomus.L335.1016)
- Oh, please come in, |PLAYERNAME|. What do you need? → Oh, por favor entra, |PLAYERNAME|. ¿Qué necesitas? (data.otservbr.global.npc.gorn.L109.58)
- Of course, just browse through my wares. {Footballs} have to be purchased separa → Por supuesto, simplemente navega por mis productos. {Footballs} debe comprarse p (data.otservbr.global.npc.gorn.L112.61)
- Ahoi, young man |PLAYERNAME|. Looking for work on my ship? → Ahoi, joven |PLAYERNAME|. ¿Buscas trabajo en mi barco? (data.otservbr.global.npc.graubart.L65.179)
- Greetings, |PLAYERNAME|. What do you want? → Saludos, |PLAYERNAME|. ¿Qué deseas? (data.otservbr.global.npc.gregor.L347.159)
- Be careful on your journeys. → Tenga cuidado en sus viajes. (data.otservbr.global.npc.gregor.L348.160)
- Be careful on your journeys. → Tenga cuidado en sus viajes. (data.otservbr.global.npc.gregor.L349.161)
- Welcome to the 'Paw and Fur - Hunting Elite' |PLAYERNAME|. Feel free to do {task → Bienvenido al '__PH0__' |PLAYERNAME|. Siéntete libre de hacer {tasks} por nosotr (data.otservbr.global.npc.grizzly.adams.L146.91)
- STOP RIGHT THERE!..... Oh, just a human. What's up big guy? → ¡DETENTE AQUÍ!..... Oh, solo un humano. ¿Qué pasa, grandullón? (data.otservbr.global.npc.grombur.L93.1129)
- I hope to see you soon. → Espero verte pronto. (data.otservbr.global.npc.guard.saros.L256.315)
- Good bye, |PLAYERNAME|. I really hope we'll talk again soon. → Adiós, |PLAYERNAME|. Realmente espero que volvamos a hablar pronto. (data.otservbr.global.npc.guard.saros.L257.316)
- Welcome to Carlin, |PLAYERNAME| Would you like some information and a map guide? → Bienvenido a Carlin, |PLAYERNAME| ¿Quieres información y una guía de mapas? (data.otservbr.global.npc.guide.alexena.L104.1375)
- Good bye and enjoy your stay in Carlin, |PLAYERNAME| → Adiós y disfruta de tu estancia en Carlin, |PLAYERNAME| (data.otservbr.global.npc.guide.alexena.L106.1377)
- Daraman's blessings, Black Sabbatth, welcome to Darashia! Would you like some in → Bendiciones de Daraman, Black Sabbatth, ¡bienvenidos a Darashia! ¿Quieres inform (data.otservbr.global.npc.guide.behil.L102.612)
- Daraman's blessings, enjoy your stay in Darashia, |PLAYERNAME| → Bendiciones de Daraman, disfrute su estadía en Darashia, |PLAYERNAME| (data.otservbr.global.npc.guide.behil.L104.614)
- Hello there, |PLAYERNAME| and welcome to Liberty Bay! Would you like some inform → ¡Hola, |PLAYERNAME| y bienvenido a Liberty Bay! ¿Quieres información y una guía  (data.otservbr.global.npc.guide.davina.L103.1064)
- Good bye and enjoy your stay in Liberty Bay, |PLAYERNAME| → Adiós y disfruta de tu estancia en Liberty Bay, |PLAYERNAME| (data.otservbr.global.npc.guide.davina.L105.1066)
- Meow, welcome to Yalahar |PLAYERNAME|! Even though I might not look like it, I c → ¡Miau, bienvenido a Yalahar |PLAYERNAME|! Aunque no lo parezca, puedo darte una  (data.otservbr.global.npc.guide.edna.L100.147)
- Enjoy your stay in Yalahar, |PLAYERNAME|. Meow. → Disfrute de su estancia en Yalahar, |PLAYERNAME|. Maullido. (data.otservbr.global.npc.guide.edna.L102.149)
- Welcome to Venore, |PLAYERNAME| Would you like some information and a map guide? → Bienvenido a Venore, |PLAYERNAME| ¿Quieres información y una guía de mapas? (data.otservbr.global.npc.guide.elena.L107.11)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **2053**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **2003**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **23.71%** (660,576/2,786,472)
- **EN-copy łącznie:** **1,591,001**
- **Braki kluczy łącznie:** **98,174**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **mixed** | hit **44**, miss **8**, hit-rate **84.6%**
- **Cache STATUSPY (per-file):** hit **1967**, miss **9**, hit-rate **99.5%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **49,731** |
| 📦 **Instalka** (klient/OTClient) | **3,855** |

| Język | Serwer | Serwer % | Instalka | Instalka % |
|-------|--------|----------|----------|------------|
| ES | 42,481/49,731 | 85.4% | 2,505/3,855 | 65.0% |
| PL | 37,198/49,731 | 74.8% | 2,673/3,855 | 69.3% |
| RU | 26,171/49,731 | 52.6% | 3,451/3,855 | 89.5% |
| FR | 25,971/49,731 | 52.2% | 2,767/3,855 | 71.8% |
| RO | 13,776/49,731 | 27.7% | 2/3,855 | 0.1% |
| BN | 13,103/49,731 | 26.4% | 13/3,855 | 0.3% |
| AR | 13,101/49,731 | 26.3% | 13/3,855 | 0.3% |
| FA | 12,995/49,731 | 26.1% | 13/3,855 | 0.3% |
| HI | 12,751/49,731 | 25.6% | 13/3,855 | 0.3% |
| ID | 12,687/49,731 | 25.5% | 13/3,855 | 0.3% |
| JA | 12,635/49,731 | 25.4% | 13/3,855 | 0.3% |
| HE | 12,620/49,731 | 25.4% | 13/3,855 | 0.3% |

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T10:30:47.650074Z → 2026-02-14T11:30:47.650074Z) |
| Cykle | **7** (AUTO=7, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **23.0%** |
| No progress rate | **9.1%** |
| Throughput | **182239.8 kluczy/h** |
| Suspicious | **403** |
| Top guard_fail targets | es/npc.json (gf=65), pl/server.json (gf=15), pl/monsters.json (gf=8), es/monsters.json (gf=6), pl/talkactions.json (gf=4) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 19min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T11:11:27.785819Z

- **Ostatni audyt:** OK | 2 issue(s) / 100 entries | 2026-02-14T11:11:27.785819Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_low=139, suspicious_log_critical=57, identical_to_en_exempt=9, suspicious_log_high=4
- **Języki o najsłabszej jakości:** es(60.1, issues=142545), pl(60.2, issues=111135), tl(64.2, issues=466), zh_TW(64.8, issues=337), fr(65.2, issues=2470)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#1** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **53,586** | realny stan EN |
| 🤖 Kluczy z rejestru workera (efektywne) | **53,586** | raw + reconcile |
| 🧾 Kluczy z rejestru workera (raw) | **6,248** | historia runów workera |
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
> **Aktualna kategoria:** pl


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
> Świeżość: 8s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T11:30:40Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     1 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🤖 AUTO_TRANSLATE (heartbeat_tick)        │
│ Kategoria: 📁 PL                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: spells.json                                             │
│ Postęp: 0/0 keys                                              │
│ Info: auto translate in progress                              │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T11:30:40Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 11:30:40 | AUTO_TRANSLATE:heartbeat_tick | pl | ok | spells.json
- 2026-02-14 11:30:40 | AUTO_TRANSLATE:parallel_start | pl | ok | spells.json
- 2026-02-14 11:30:39 | AUTO_TRANSLATE:auto_done | es | ok | server.json
- 2026-02-14 11:29:09 | AUTO_TRANSLATE:heartbeat_tick | es | ok | server.json
- 2026-02-14 11:29:08 | AUTO_TRANSLATE:auto_start | es | ok | server.json
- 2026-02-14 11:26:39 | AUTO_TRANSLATE:heartbeat_tick | pl | ok | server.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 74.4% | 2,083 | 2,861 | 871 | 442 (33.7%) | 36 |
| 🟡 ES | 84.0% | 232 | 11,173 | 1,087 | 419 (27.8%) | 33 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **66,459** | — | 📊 |
| Adaptive batch | batch=5, gf_rate=27.79%, reason=decrease_high_fail_rate=27.8% | gf <5% → increase | 📊 |
| Throughput (last window) | 1,958 keys / 69 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 11:30:47

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+80, skipped+0) — lang=es file=server.json strict_skipped_done=404
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+18, skipped+0) — parallel lang=pl file=server.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+74, skipped+0) — lang=es file=monsters.json strict_skipped_done=5798 guard_fail=6 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+73, skipped+0) — parallel lang=pl file=monsters.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+15, skipped+0) — lang=es file=npc.json strict_skipped_done=11609 guard_fail=65 placeholder=62 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+96) — repair_identical lang=es file=npc.json target_identical=2306 limit=260 tier=high_backlog+domain_cap domain_cap=260 gt=true suspicious_pct=3.85
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+80, skipped+0) — lang=pl file=items.json strict_skip missing_file=0 missing_key=163 skipped_done=8319 strict_skipped_done=8319 guard_fail=1 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+95) — repair_identical lang=es file=npc.json target_identical=1122 limit=260 tier=base+domain_cap domain_cap=260 gt=true suspicious_pct=3.78
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+0, skipped+0) — parallel lang=pl file=otclient_data.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+7, skipped+0) — lang=es file=cpp.json strict_skip missing_file=0 missing_key=2 skipped_done=870 strict_skipped_done=870 guard_fail=2 placeholder=0 command=0 pipe=0




## 📅 Dziś (UTC)

- Cykle: **49**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **329**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych (LIVE registry) | **2,299** | z `i18n_file_status.json` |
| 📚 Plików przeskanowanych (historia) | **6,443** | z `i18n_processed_files.txt` |
| ↕️ Historia minus LIVE | **+4,144** | dodatnie = historia > LIVE |
| ✅ Plików z kluczami | **1897** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **400** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych (LIVE) | **53,586** | realny stan `i18n/en/*.json` |
| 🤖 Kluczy wyciągniętych przez workera (efektywne) | **53,586** | raw + reconcile |
| 🧾 Kluczy wyciągniętych przez workera (raw) | **6,248** | z `i18n_file_status.json` |
| 🧩 Reconcile korekta rejestru | **47,338** | zmiany EN poza workerem |
| ➕ Kluczy poza rejestrem workera | **0** | ręczne/Codex/Claude/starsze |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#1** | continuous mode |

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
| Worker v1.1 | 🟢 RUNNING | Cykl #1 |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 11:30:47  
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
