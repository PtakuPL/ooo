# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 11:15:14

> **Aktualizacja:** 2026-02-14 11:15:14 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #1 | Status: 🟢 RUNNING | Faza: AUTO_TRANSLATE | Etap: heartbeat_tick | Kategoria: es | Plik: npc.json | ETA: 0 | Heartbeat: 2026-02-14T11:09:57Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=6 | pending_skip=0.0% | guard_fail=13.9% | throughput=71401.6/h  
> **Net effective translated:** 66,243

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 11:15:14 |
| LIVE | 🟢 ACTIVE | 5min temu | - | `activity.json / worker_state.json` | 2026-02-14T11:09:57Z |
| MIGRATION | 🔒 INACTIVE | 16h temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-02-14 11:15:14 |
| TRANSLATION | 🟢 ACTIVE | 7min temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T11:07:31.532021Z |
| QUALITY | 🔒 INACTIVE | 3min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-02-14T11:11:27.785819Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 11:15:14 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 5min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T11:09:57Z

- **Faza:** `AUTO_TRANSLATE`
- **Etap:** `heartbeat_tick`
- **Kategoria:** `es`
- **Plik:** `npc.json`
- **Status:** 🟢 RUNNING
- **Heartbeat:** `2026-02-14T11:09:57Z`

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
> Świeżość: 16h temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-02-14 11:15:14

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,323** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,434** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,443** | **68.3%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **2,299** | **24.4%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **2,991** | 31.7% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **7,135** | 75.6% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,538 | konfiguracje |

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
> Świeżość: 7min temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T11:07:31.532021Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 47,024/53,586 | 87.75% | 11,255 | 232 |
| PL (Polski) | 40,432/53,586 | 75.45% | 2,841 | 2,083 |
| RU (Rosyjski) | 30,046/53,586 | 56.07% | 37,635 | 174 |
| FR (Francuski) | 29,713/53,586 | 55.45% | 29,762 | 174 |
| RO (Rumuński) | 13,985/53,586 | 26.10% | 24,000 | 174 |
| BN (BN) | 13,116/53,586 | 24.48% | 33,937 | 2,155 |
| AR (Arabski) | 13,114/53,586 | 24.47% | 34,050 | 2,150 |
| FA (FA) | 12,966/53,586 | 24.20% | 34,334 | 2,155 |
| ID (ID) | 12,641/53,586 | 23.59% | 34,488 | 2,155 |
| HI (HI) | 12,636/53,586 | 23.58% | 34,486 | 2,155 |
| HE (HE) | 12,581/53,586 | 23.48% | 34,537 | 2,155 |
| KO (Koreański) | 12,575/53,586 | 23.47% | 34,559 | 2,155 |
| HY (HY) | 12,520/53,586 | 23.36% | 34,756 | 2,155 |
| JA (Japoński) | 12,520/53,586 | 23.36% | 34,563 | 2,155 |
| MS (MS) | 12,493/53,586 | 23.31% | 34,810 | 2,155 |
| KA (KA) | 12,486/53,586 | 23.30% | 34,644 | 2,155 |
| ML (ML) | 12,469/53,586 | 23.27% | 34,633 | 2,155 |
| SW (SW) | 12,324/53,586 | 23.00% | 34,913 | 2,155 |
| TE (TE) | 12,300/53,586 | 22.95% | 34,946 | 2,155 |
| TH (TH) | 12,290/53,586 | 22.94% | 34,966 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** HI - HI - Serwer
- **Plik JSON:** monsters.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- By the way: If your hitpoints are below 150, you will regenerate back to 150 hit → Por cierto: si tus puntos de vida están por debajo de 150, te regenerarás a 150  (npc.santiago.multi_2)
- Oh, what's wrong? As I said, simply go to my house south of here and go upstairs → Ah, ¿qué pasa? Como dije, simplemente ve a mi casa al sur de aquí y sube las esc (npc.santiago.say_1)
- That's just great! Now you have more health points, can carry more stuff and wal → ¡Eso es simplemente genial! Ahora tienes más puntos de salud, puedes cargar más  (npc.santiago.say_10)
- Really? You look fine to me, must have been just a scratch. Well, there are much → ¿En realidad? Te ves bien para mí, debe haber sido sólo un rasguño. Bueno, hay m (npc.santiago.say_11)
- This is an important lesson from me - an experienced veteran fighter. Take this! → Esta es una lección importante para mí, un luchador veterano y experimentado. ¡T (npc.santiago.say_12)
- I knew you'd get it right away. You can loot food from many creatures, such as d → Sabía que lo entenderías de inmediato. Puedes saquear comida de muchas criaturas (npc.santiago.say_13)
- Really?? She was looking for someone to help her. Maybe you could go and see her → ¿¿En realidad?? Estaba buscando a alguien que la ayudara. Tal vez podrías ir a v (npc.santiago.say_14)
- This is an important lesson from me - an experienced veteran fighter. Take this! → Esta es una lección importante para mí, un luchador veterano y experimentado. ¡T (npc.santiago.say_15)
- I knew I could count on you. Here, take this good and sturdy weapon in your hand → Sabía que podía contar contigo. Toma, toma esta buena y resistente arma en tu ma (npc.santiago.say_16)
- I knew you'd get it right away. You can loot food from many creatures, such as d → Sabía que lo entenderías de inmediato. Puedes saquear comida de muchas criaturas (npc.santiago.say_17)
- I've forgotten to tell you something. Of course I need proof that you killed coc → Se me olvidó decirte algo. Por supuesto que necesito pruebas de que mataste cuca (npc.santiago.say_2)
- I've forgotten to tell you something. Of course I need proof that you killed coc → Se me olvidó decirte algo. Por supuesto que necesito pruebas de que mataste cuca (npc.santiago.say_3)
- Great, please go to my house, just a few steps south of here. Upstairs in my roo → Genial, por favor ve a mi casa, solo unos pasos al sur de aquí. Arriba, en mi ha (npc.santiago.say_4)
- Alright! Do you see the button called 'Quest Log'? There you can check the statu → ¡Está bien! ¿Ves el botón llamado 'Quest Log'? Allí podrás comprobar el estado d (npc.santiago.say_5)
- Ah, no need to say anything, I can see it suits you perfectly. Now we're getting → Ah, no hace falta que digas nada, veo que te queda perfecto. Ahora llegamos a la (npc.santiago.say_6)
- Oh, you don't wear it properly yet. You need to drag and drop it from your bag t → Oh, aún no lo usas apropiadamente. Debes arrastrarlo y soltarlo desde tu bolso a (npc.santiago.say_7)
- Oh no, did you lose my coat? Well, lucky you, I have a spare one here. Don't los → Oh no, ¿perdiste mi abrigo? Bueno, qué suerte tienes, tengo uno de repuesto aquí (npc.santiago.say_8)
- I knew I could count on you. Here, take this good and sturdy weapon in your hand → Sabía que podía contar contigo. Toma, toma esta buena y resistente arma en tu ma (npc.santiago.say_9)
- Evil little beasts... I hope someone helps me fight them. → Pequeñas bestias malvadas... Espero que alguien me ayude a luchar contra ellas. (npc.santiago.voice_1)
- Hey! You over there, could you help me with a little quest? Just say 'hi' or 'he → ¡Ey! Tú estás ahí, ¿podrías ayudarme con una pequeña búsqueda? ¡Solo di 'hi' o ' (npc.santiago.voice_3)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **2048**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1998**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **23.86%** (664,719/2,786,472)
- **EN-copy łącznie:** **1,594,551**
- **Braki kluczy łącznie:** **98,174**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **mixed** | hit **41**, miss **11**, hit-rate **78.8%**
- **Cache STATUSPY (per-file):** hit **1965**, miss **11**, hit-rate **99.4%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **49,731** |
| 📦 **Instalka** (klient/OTClient) | **3,855** |

| Język | Serwer | Serwer % | Instalka | Instalka % |
|-------|--------|----------|----------|------------|
| ES | 44,409/49,731 | 89.3% | 2,615/3,855 | 67.8% |
| PL | 37,684/49,731 | 75.8% | 2,748/3,855 | 71.3% |
| RU | 26,590/49,731 | 53.5% | 3,456/3,855 | 89.7% |
| FR | 26,488/49,731 | 53.3% | 3,225/3,855 | 83.7% |
| RO | 13,983/49,731 | 28.1% | 2/3,855 | 0.1% |
| BN | 13,103/49,731 | 26.4% | 13/3,855 | 0.3% |
| AR | 13,101/49,731 | 26.3% | 13/3,855 | 0.3% |
| FA | 12,953/49,731 | 26.1% | 13/3,855 | 0.3% |
| ID | 12,628/49,731 | 25.4% | 13/3,855 | 0.3% |
| HI | 12,623/49,731 | 25.4% | 13/3,855 | 0.3% |
| HE | 12,568/49,731 | 25.3% | 13/3,855 | 0.3% |
| KO | 12,562/49,731 | 25.3% | 13/3,855 | 0.3% |

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T10:15:14.485469Z → 2026-02-14T11:15:14.485469Z) |
| Cykle | **6** (AUTO=6, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **13.9%** |
| No progress rate | **12.5%** |
| Throughput | **71401.6 kluczy/h** |
| Suspicious | **73** |
| Top guard_fail targets | es/books.json (gf=4), pl/talkactions.json (gf=4), pl/otclient_data.json (gf=3), es/modules.json (gf=2), es/cpp.json (gf=2) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 3min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T11:11:27.785819Z

- **Ostatni audyt:** OK | 2 issue(s) / 100 entries | 2026-02-14T11:11:27.785819Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_low=139, suspicious_log_critical=57, identical_to_en_exempt=9, suspicious_log_high=4
- **Języki o najsłabszej jakości:** es(60.1, issues=142545), pl(60.1, issues=111135), tl(64.2, issues=466), zh_TW(64.8, issues=337), fr(65.2, issues=2470)
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
> **Aktualna kategoria:** es


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
> Świeżość: 5min temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T11:09:57Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     1 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🤖 AUTO_TRANSLATE (heartbeat_tick)        │
│ Kategoria: 📁 ES                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: npc.json                                                │
│ Postęp: 0/0 keys                                              │
│ Info: auto translate in progress                              │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T11:09:57Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 11:09:57 | AUTO_TRANSLATE:heartbeat_tick | es | ok | npc.json
- 2026-02-14 11:08:27 | AUTO_TRANSLATE:heartbeat_tick | es | ok | npc.json
- 2026-02-14 11:07:32 | AUTO_TRANSLATE:auto_done | pl | ok | items.json
- 2026-02-14 11:06:01 | AUTO_TRANSLATE:heartbeat_tick | pl | ok | items.json
- 2026-02-14 11:06:01 | AUTO_TRANSLATE:auto_start | pl | ok | items.json
- 2026-02-14 11:03:50 | AUTO_TRANSLATE:heartbeat_tick | es | ok | npc.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 75.5% | 2,083 | 2,841 | 867 | 476 (35.4%) | 37 |
| 🟡 ES | 87.8% | 232 | 11,255 | 933 | 359 (27.8%) | 32 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **66,243** | — | 📊 |
| Adaptive batch | batch=5, gf_rate=30.19%, reason=decrease_high_fail_rate=30.2% | gf <5% → increase | 📊 |
| Throughput (last window) | 1,800 keys / 69 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 11:15:14

- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+96) — repair_identical lang=es file=npc.json target_identical=2306 limit=260 tier=high_backlog+domain_cap domain_cap=260 gt=true suspicious_pct=3.85
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+80, skipped+0) — lang=pl file=items.json strict_skip missing_file=0 missing_key=163 skipped_done=8319 strict_skipped_done=8319 guard_fail=1 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+95) — repair_identical lang=es file=npc.json target_identical=1122 limit=260 tier=base+domain_cap domain_cap=260 gt=true suspicious_pct=3.78
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+0, skipped+0) — parallel lang=pl file=otclient_data.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+7, skipped+0) — lang=es file=cpp.json strict_skip missing_file=0 missing_key=2 skipped_done=870 strict_skipped_done=870 guard_fail=2 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+95) — repair_identical lang=es file=npc.json target_identical=1156 limit=260 tier=base+domain_cap domain_cap=260 gt=true suspicious_pct=3.80
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+2, skipped+0) — lang=pl file=talkactions.json strict_skipped_done=197 guard_fail=4 placeholder=0 command=0 pipe=1
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+96) — repair_identical lang=es file=npc.json target_identical=1218 limit=260 tier=base+domain_cap domain_cap=260 gt=true suspicious_pct=3.73
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [es] → ok (translated+1, skipped+0) — parallel lang=es file=modules.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+8, skipped+0) — lang=pl file=startup.json strict_skipped_done=15 guard_fail=1 placeholder=0 command=0 pipe=0




## 📅 Dziś (UTC)

- Cykle: **49**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **324**


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
| **Tier 2** | cs, de, fr, hu, it, nl, pt, ru, sk, tr | ×3 | 50% |
| **Tier 3** | reszta (40) | ×1 | 30% |

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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 11:15:14  
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
