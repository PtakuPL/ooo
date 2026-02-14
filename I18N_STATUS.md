# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 08:22:03

> **Aktualizacja:** 2026-02-14 08:22:03 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #1 | Status: 🟢 RUNNING | Faza: AUTO_TRANSLATE | Etap: parallel_start | Kategoria: es | Plik: npc.json | ETA: 0 | Heartbeat: 2026-02-14T08:21:51Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=51 | pending_skip=0.0% | guard_fail=3.0% | throughput=2062.5/h  
> **Net effective translated:** 65,607

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 08:22:03 |
| LIVE | 🟢 ACTIVE | 13s temu | - | `activity.json / worker_state.json` | 2026-02-14T08:21:51Z |
| MIGRATION | 🔒 INACTIVE | 13h temu | worker w trybie AUTO_TRANSLATE | `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | 2026-02-14 08:22:03 |
| TRANSLATION | 🟢 ACTIVE | 14s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T08:21:49.995869Z |
| QUALITY | 🔒 INACTIVE | 12min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-02-14T08:10:03.763425Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 08:22:03 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 13s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T08:21:51Z

- **Faza:** `AUTO_TRANSLATE`
- **Etap:** `parallel_start`
- **Kategoria:** `es`
- **Plik:** `npc.json`
- **Status:** 🟢 RUNNING
- **Heartbeat:** `2026-02-14T08:21:51Z`

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
> Świeżość: 13h temu | Źródło: `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt` | Ostatnia aktualizacja: 2026-02-14 08:22:03

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,302** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,425** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane (historia)** | **6,443** | **68.4%** | `i18n_processed_files.txt` |
| 🧭 Przeskanowane (LIVE) | **2,299** | **24.4%** | `i18n_file_status.json` |
| ⏳ Nie przeskanowane (historia) | **2,982** | 31.6% | wg historii workera |
| ⏳ Nie przeskanowane (LIVE) | **7,126** | 75.6% | wg rejestru LIVE |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,529 | konfiguracje |

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
| 🤖 Klucze z rejestru workera | **6,248** | suma `5_extraction_en.keys_added` |
| ➕ Klucze poza rejestrem workera | **47,338** | ręczne zmiany / starsze migracje |
| 📊 NPC | 13,769 | dialogi NPC |
| 📊 Items | 17,057 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 15,350 | scripts, spells, etc. |

## 🌍 TRANSLATION

> **[TRANSLATION]** 🟢 ACTIVE  
> Świeżość: 14s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T08:21:49.995869Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 46,380/53,586 | 86.55% | 11,047 | 232 |
| PL (Polski) | 40,200/53,586 | 75.02% | 2,823 | 2,083 |
| AR (Arabski) | 12,006/53,586 | 22.41% | 31,222 | 2,150 |
| ID (ID) | 11,859/53,586 | 22.13% | 29,253 | 2,155 |
| BN (BN) | 11,853/53,586 | 22.12% | 29,252 | 2,155 |
| FA (FA) | 11,853/53,586 | 22.12% | 29,250 | 2,155 |
| HI (HI) | 11,851/53,586 | 22.12% | 29,253 | 2,155 |
| HY (HY) | 11,852/53,586 | 22.12% | 29,258 | 2,155 |
| KO (Koreański) | 11,833/53,586 | 22.08% | 29,246 | 2,155 |
| KA (KA) | 11,773/53,586 | 21.97% | 29,241 | 2,155 |
| SW (SW) | 11,771/53,586 | 21.97% | 29,235 | 2,155 |
| TE (TE) | 11,772/53,586 | 21.97% | 29,233 | 2,155 |
| TH (TH) | 11,772/53,586 | 21.97% | 29,233 | 2,155 |
| HE (HE) | 11,769/53,586 | 21.96% | 29,302 | 2,155 |
| ML (ML) | 11,769/53,586 | 21.96% | 29,237 | 2,155 |
| JA (Japoński) | 11,734/53,586 | 21.90% | 29,300 | 2,155 |
| TL (TL) | 11,727/53,586 | 21.88% | 29,298 | 2,155 |
| MS (MS) | 11,692/53,586 | 21.82% | 29,285 | 2,155 |
| VI (VI) | 11,694/53,586 | 21.82% | 29,280 | 2,155 |
| TA (TA) | 11,612/53,586 | 21.67% | 29,282 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** HI - HI - Serwer
- **Plik JSON:** monsters.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- I'm very thankful. Please go to the Druid of Crunor and tell him what you've see → Jestem bardzo wdzięczny. Proszę, idź do Druid Crunora i powiedz mu, co widziałeś (npc.jamesfrancis.greet_msg_4)
- Time to have a sweet drink! Let's pour the bug milk into my cauldron and heat it → Czas na słodki napój! Wlejmy mleko owadów do mojego kociołka i podgrzejmy na ogn (npc.jean_pierre.multi_1)
- We'll add some other vegetables and spices for the delicate and distinctive tast → Dla delikatnego i wyrazistego smaku dodamy jeszcze trochę innych warzyw i przypr (npc.jean_pierre.multi_102)
- The name is just for the effect it has on people. <winks> Bring me the following → Nazwa pochodzi tylko od wpływu, jaki wywiera na ludzi. <winks> Przynieś mi nastę (npc.jean_pierre.multi_105)
- Now add whole potatoes and let everything cook at high temperature until the pot → Teraz dodaj całe ziemniaki i gotuj wszystko w wysokiej temperaturze, aż ziemniak (npc.jean_pierre.multi_14)
- Yes yes, I know, don't give me that look! You'll be surprised! Now just add the  → Tak, tak, wiem, nie patrz tak na mnie! Będziesz zaskoczony! Teraz wystarczy doda (npc.jean_pierre.multi_15)
- You're wondering why I chose a simple recipe like that for my famous menu? You'l → Zastanawiacie się, dlaczego do swojego słynnego menu wybrałam właśnie taki prost (npc.jean_pierre.multi_16)
- And voilà, we're done! The girls of Carlin swear that it sharpens their eyesight → I voila, gotowe! Dziewczyny z Carlin twierdzą, że to wyostrza ich wzrok, przynaj (npc.jean_pierre.multi_27)
- Nicely decorate it on a plate, and voilà, we're done already! Can't tell you muc → Ładnie udekoruj na talerzu i gotowe! Nie mogę zbyt wiele powiedzieć o efektach,  (npc.jean_pierre.multi_33)
- Nicely decorate it on a plate, and voilà, we're done already! Can't tell you muc → Ładnie udekoruj na talerzu i gotowe! Nie mogę zbyt wiele powiedzieć o efektach,  (npc.jean_pierre.multi_34)
- The filling will melt nicely, just be careful that it doesn't drip out! And voil → Nadzienie ładnie się rozpuści, trzeba tylko uważać, żeby nie wyciekło! I voila,  (npc.jean_pierre.multi_42)
- So let's start! <rubs hands together and chops the vegetables> This is a dish es → Więc zaczynajmy! <rubs hands together and chops the vegetables> To danie szczegó (npc.jean_pierre.multi_44)
- Great! Let's get it done! <mixes and shakes faster than any human could> An easy → Świetnie! Zróbmy to! <mixes and shakes faster than any human could> Znowu łatwe, (npc.jean_pierre.multi_48)
- Voilà, we're done! To be honest, I don't know what this drink does, but at least → Voilà, skończyliśmy! Szczerze mówiąc, nie wiem, co ten napój robi, ale przynajmn (npc.jean_pierre.multi_51)
- Pour it over the salad, and voilà, we're done! This is a Venorean recipe and ver → Polej nim sałatkę i gotowe! To jest przepis Venoreański i bardzo smaczny. Poleca (npc.jean_pierre.multi_62)
- Aah, so let's see! <prepares the food quickly while he explains it to you> We co → Ach, więc zobaczmy! <prepares the food quickly while he explains it to you> Mięs (npc.jean_pierre.multi_63)
- And voilà, we're done. I developed this recipe while talking to Maryza in the Jo → I voila, gotowe. Ten przepis opracowałam podczas rozmowy z Maryzą w Wesołym Topo (npc.jean_pierre.multi_65)
- Weren't you surprised by the great taste of our main dish? In case you still hav → Nie zaskoczył Cię wspaniały smak naszego dania głównego? Jeśli zostało Ci jeszcz (npc.jean_pierre.multi_70)
- Bring me the following ingredients and I'll show you how it's done: one northern → Przynieś mi następujące składniki, a pokażę Ci, jak to się robi: jeden szczupak  (npc.jean_pierre.multi_86)
- Bring me the following ingredients and I'll show you how it's done: one northern → Przynieś mi następujące składniki, a pokażę Ci, jak to się robi: jeden szczupak  (npc.jean_pierre.multi_87)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **2011**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1961**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **21.13%** (588,863/2,786,472)
- **EN-copy łącznie:** **1,333,557**
- **Braki kluczy łącznie:** **110,060**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **mixed** | hit **51**, miss **1**, hit-rate **98.1%**
- **Cache STATUSPY (per-file):** hit **1975**, miss **1**, hit-rate **99.9%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **49,731** |
| 📦 **Instalka** (klient/OTClient) | **3,855** |

| Język | Serwer | Serwer % | Instalka | Instalka % |
|-------|--------|----------|----------|------------|
| ES | 43,808/49,731 | 88.1% | 2,572/3,855 | 66.7% |
| PL | 37,440/49,731 | 75.3% | 2,760/3,855 | 71.6% |
| AR | 11,993/49,731 | 24.1% | 13/3,855 | 0.3% |
| ID | 11,846/49,731 | 23.8% | 13/3,855 | 0.3% |
| BN | 11,840/49,731 | 23.8% | 13/3,855 | 0.3% |
| FA | 11,840/49,731 | 23.8% | 13/3,855 | 0.3% |
| HI | 11,838/49,731 | 23.8% | 13/3,855 | 0.3% |
| HY | 11,839/49,731 | 23.8% | 13/3,855 | 0.3% |
| KO | 11,820/49,731 | 23.8% | 13/3,855 | 0.3% |
| KA | 11,760/49,731 | 23.6% | 13/3,855 | 0.3% |
| SW | 11,758/49,731 | 23.6% | 13/3,855 | 0.3% |
| TE | 11,759/49,731 | 23.6% | 13/3,855 | 0.3% |

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T07:22:04.034548Z → 2026-02-14T08:22:04.034548Z) |
| Cykle | **51** (AUTO=51, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **3.0%** |
| No progress rate | **0.0%** |
| Throughput | **2062.5 kluczy/h** |
| Suspicious | **1344** |
| Top guard_fail targets | pl/npc.json (gf=41), ko/monsters.json (gf=14), tr/scripts.json (gf=6), ja/monsters.json (gf=5), tr/quests.json (gf=4) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 12min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T08:10:03.763425Z

- **Ostatni audyt:** SLOW_MODE | 19 issue(s) / 100 entries | 2026-02-14T08:10:03.763425Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_low=174, suspicious_log_high=23, identical_to_en=19, suspicious_log_critical=3
- **Języki o najsłabszej jakości:** es(60.1, issues=137817), pl(60.1, issues=108210), tl(64.2, issues=466), zh_TW(64.8, issues=337), fr(65.2, issues=2470)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#1** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych (LIVE) | **53,586** | realny stan EN |
| 🤖 Kluczy z rejestru workera | **6,248** | historia runów workera |
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
> Świeżość: 13s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T08:21:51Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     1 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🤖 AUTO_TRANSLATE (parallel_start)        │
│ Kategoria: 📁 ES                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: npc.json                                                │
│ Postęp: 0/0 keys                                              │
│ Info: parallel auto translate                                 │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T08:21:51Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 08:21:51 | AUTO_TRANSLATE:parallel_start | es | ok | npc.json
- 2026-02-14 08:21:50 | AUTO_TRANSLATE:auto_done | pl | ok | npc.json
- 2026-02-14 08:20:56 | AUTO_TRANSLATE:auto_start | pl | ok | npc.json
- 2026-02-14 08:20:49 | AUTO_TRANSLATE:auto_start | pl | ok | items.json
- 2026-02-14 08:18:14 | AUTO_TRANSLATE:parallel_start | ko | ok | monsters.json
- 2026-02-14 08:17:30 | AUTO_TRANSLATE:auto_done | kk | ok | monsters.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 75.0% | 2,083 | 2,823 | 444 | 247 (35.7%) | 17 |
| 🟡 ES | 86.5% | 232 | 11,047 | 481 | 161 (25.1%) | 15 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **65,607** | — | 📊 |
| Adaptive batch | batch=50, gf_rate=2.75%, reason=increase_low_fail_rate=2.8% | gf <5% → increase | 📊 |
| Throughput (last window) | 925 keys / 32 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 08:22:03

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+39, skipped+0) — lang=pl file=npc.json strict_skipped_done=13590 guard_fail=41 placeholder=3 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [ko] → ok (translated+66, skipped+0) — parallel lang=ko file=monsters.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [kk] → warn (files+1, translated+80, skipped+0) — lang=kk file=monsters.json strict_skipped_done=1163
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ja] → warn (files+1, translated+75, skipped+0) — lang=ja file=monsters.json strict_skipped_done=4750 guard_fail=5 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+103) — repair_identical lang=es file=npc.json target_identical=1493 limit=260 tier=base+domain_cap domain_cap=260 gt=true suspicious_pct=3.18
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [et] → ok (translated+80, skipped+0) — parallel lang=et file=monsters.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [el] → warn (files+1, translated+80, skipped+0) — lang=el file=monsters.json strict_skipped_done=1287
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [sv] → ok (translated+80, skipped+0) — parallel lang=sv file=monsters.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [nl] → warn (files+1, translated+80, skipped+0) — lang=nl file=monsters.json strict_skipped_done=1287
- 🤖 AUTO_TRANSLATE: REPAIR_IDENTICAL_DONE [es] → ok (translated+103) — repair_identical lang=es file=npc.json target_identical=1510 limit=260 tier=high_backlog+domain_cap domain_cap=260 gt=true suspicious_pct=3.18




## 📅 Dziś (UTC)

- Cykle: **49**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **281**


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
| 🤖 Kluczy wyciągniętych przez workera | **6,248** | z `i18n_file_status.json` |
| ➕ Kluczy poza rejestrem workera | **47,338** | ręczne/Codex/Claude/starsze |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 08:22:03  
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
