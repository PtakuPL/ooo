# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-13 22:56:03

> **Aktualizacja:** 2026-02-13 22:56:03 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #7 | Status: ✅ IDLE | Faza: IDLE | Etap: cycle_start | Kategoria: - | Plik: - | ETA: 0 | Heartbeat: 2026-02-13T22:55:57Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=242 | pending_skip=0.0% | guard_fail=13.5% | throughput=2392.1/h  
> **Net effective translated:** 37,870

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-13 22:56:03 |
| LIVE | 🟢 ACTIVE | 7s temu | - | `activity.json / worker_state.json` | 2026-02-13T22:55:57Z |
| MIGRATION | 🔒 INACTIVE | 3h temu | worker w trybie IDLE | `i18n_file_status.json` | 2026-02-13 22:56:03 |
| TRANSLATION | 🔒 INACTIVE | 2min temu | worker w trybie IDLE | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-13T22:53:22.165154Z |
| QUALITY | 🔒 INACTIVE | 15s temu | worker w trybie IDLE | `quality_audit_latest.json` | 2026-02-13T22:55:48.785139Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-13 22:56:03 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 7s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-13T22:55:57Z

- **Faza:** `IDLE`
- **Etap:** `cycle_start`
- **Kategoria:** `-`
- **Plik:** `-`
- **Status:** ✅ IDLE
- **Heartbeat:** `2026-02-13T22:55:57Z`

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
> Świeżość: 3h temu | Źródło: `i18n_file_status.json` | Ostatnia aktualizacja: 2026-02-13 22:56:03

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,139** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,276** | 46.1% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,443** | **69.5%** | historia workera |
| ⏳ Nie przeskanowane | **2,833** | 30.5% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,380 | konfiguracje |

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
> Świeżość: 2min temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-13T22:53:22.165154Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| PL (Polski) | 39,517/53,586 | 73.75% | 2,949 | 2,083 |
| ES (Hiszpański) | 38,222/53,586 | 71.33% | 15,349 | 232 |
| AR (Arabski) | 11,447/53,586 | 21.36% | 30,982 | 2,150 |
| ID (ID) | 11,301/53,586 | 21.09% | 29,171 | 2,155 |
| VI (VI) | 11,294/53,586 | 21.08% | 29,170 | 2,155 |
| BN (BN) | 11,293/53,586 | 21.07% | 29,180 | 2,155 |
| FA (FA) | 11,293/53,586 | 21.07% | 29,180 | 2,155 |
| HE (HE) | 11,290/53,586 | 21.07% | 29,177 | 2,155 |
| HI (HI) | 11,292/53,586 | 21.07% | 29,179 | 2,155 |
| HY (HY) | 11,293/53,586 | 21.07% | 29,180 | 2,155 |
| JA (Japoński) | 11,292/53,586 | 21.07% | 29,179 | 2,155 |
| KA (KA) | 11,293/53,586 | 21.07% | 29,180 | 2,155 |
| KO (Koreański) | 11,293/53,586 | 21.07% | 29,171 | 2,155 |
| ML (ML) | 11,289/53,586 | 21.07% | 29,176 | 2,155 |
| MS (MS) | 11,292/53,586 | 21.07% | 29,173 | 2,155 |
| SW (SW) | 11,292/53,586 | 21.07% | 29,172 | 2,155 |
| TA (TA) | 11,292/53,586 | 21.07% | 29,172 | 2,155 |
| TE (TE) | 11,292/53,586 | 21.07% | 29,172 | 2,155 |
| TH (TH) | 11,292/53,586 | 21.07% | 29,172 | 2,155 |
| TL (TL) | 11,292/53,586 | 21.07% | 29,173 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** SV - Szwedzki - Serwer
- **Plik JSON:** npc.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- It is said that the orcish shamans cursed the Red Legion. <m> → Se dice que los chamanes orcos maldijeron a la Legión Roja. <m> (npc.aneus.multi_10)
- Nobody knows. But one third of the soldiers died by a disease on the way back. < → Nadie lo sabe. Pero un tercio de los soldados murió a causa de una enfermedad en (npc.aneus.multi_11)
- And the orcs wanted to take revenge, and after some days they stroke back! <m> → ¡Y los orcos quisieron vengarse y después de unos días contraatacaron! <m> (npc.aneus.multi_12)
- The orcs and many allied cyclopses and minotaurs from all ...<m> → Los orcos y muchos cíclopes y minotauros aliados de todo...<m> (npc.aneus.multi_13)
- ... over Tibia came to avenge their friends, and they killed nearly all ... <m> → ...sobre Tibia vinieron a vengar a sus amigos, y mataron a casi todos... <m> (npc.aneus.multi_14)
- ... workers and soldiers in the castle. The HELP of the king's sister came too l → ... trabajadores y soldados en el castillo. La AYUDA de la hermana del rey llegó (npc.aneus.multi_15)
- Most of the Red Legion went to the island by night. The orcs ... <m> → La mayor parte de la Legión Roja fue a la isla de noche. Los orcos... <m> (npc.aneus.multi_16)
- ... were not prepared and the Red Legion killed hundreds of orcs ... <m> → ...no estaban preparados y la Legión Roja mató a cientos de orcos... <m> (npc.aneus.multi_17)
- ... with nearly no loss. After they were satisfied they WALKED BACK to the castl → ... casi sin pérdidas. Una vez satisfechos, REGRESARON al castillo. (npc.aneus.multi_18)
- She ordered her loyal druids and hunters to disguise themselves ... <m> → Ella ordenó a sus leales druidas y cazadores que se disfrazaran... <m> (npc.aneus.multi_19)
- ... started to fight their non-orcish-allies. After a bloody long fight ... <m> → ... comenzaron a luchar contra sus aliados no orcos. Después de una larga y sang (npc.aneus.multi_2)
- ... as orcs from the near ISLAND and to ATTACK the Red Legion by night over and  → ... como orcos de la ISLA cercana y para ATACAR a la Legión Roja de noche una y  (npc.aneus.multi_20)
- The king's sister was pretty upset about the situation there but her brother ... → La hermana del rey estaba bastante molesta por la situación allí pero su hermano (npc.aneus.multi_21)
- ... didn't want to do anything about this matter. So she made a PLAN to destroy  → ... no quería hacer nada al respecto. Entonces ella hizo un PLAN para destruir a (npc.aneus.multi_22)
- All rebels were brought to the giant castle. Guarded by the Red Legion, ... <m> → Todos los rebeldes fueron llevados al castillo gigante. Custodiado por la Legión (npc.aneus.multi_23)
- ... they had to work and live in even worser conditions. Also some FRIENDS of th → ... tuvieron que trabajar y vivir en condiciones aún peores. También fueron llev (npc.aneus.multi_24)
- The development of the city was fine. Also a giant castle was build ... <m> → El desarrollo de la ciudad fue bueno. También se construyó un castillo gigante.. (npc.aneus.multi_25)
- ... northeast of the city. But more and more workers started to REBEL because of → ... al noreste de la ciudad. Pero cada vez más trabajadores comenzaron a REBELAR (npc.aneus.multi_26)
- The works on this new city began and the king sent his best ... <m> → Se iniciaron las obras de esta nueva ciudad y el rey envió lo mejor... <m> (npc.aneus.multi_27)
- ... SOLDIERS to protect the workers from ORCS and to make them WORK HARDER. → ... SOLDADOS para proteger a los trabajadores de los ORCS y hacerlos TRABAJAR MÁ (npc.aneus.multi_28)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **1600**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1550**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **19.87%** (553,617/2,786,472)
- **EN-copy łącznie:** **1,334,813**
- **Braki kluczy łącznie:** **110,060**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **warm-cache** | hit **52**, miss **0**, hit-rate **100.0%**
- **Cache STATUSPY (per-file):** hit **1976**, miss **0**, hit-rate **100.0%**
- **Profiler cyklu (ostatni):** cykl #6 (AUTO_TRANSLATE): dispatch 499ms, mode 192168ms, status 4136ms, total 197843ms
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-13T21:56:04.004111Z → 2026-02-13T22:56:04.004111Z) |
| Cykle | **242** (AUTO=242, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **13.5%** |
| No progress rate | **13.2%** |
| Throughput | **2392.1 kluczy/h** |
| Suspicious | **2720** |
| Top guard_fail targets | pl/otclient_modules.json (gf=87), pl/html.json (gf=80), es/monsters.json (gf=53), pl/cpp.json (gf=48), pl/npc.json (gf=46) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie IDLE)  
> Świeżość: 15s temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-13T22:55:48.785139Z

- **Ostatni audyt:** SLOW_MODE | 69 issue(s) / 100 entries | 2026-02-13T22:55:48.785139Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_low=87, identical_to_en=69, suspicious_log_high=69, suspicious_log_medium=42
- **Języki o najsłabszej jakości:** es(60.1, issues=107103), pl(60.1, issues=84109), ru(65.1, issues=2268), it(65.9, issues=1692), tr(66.9, issues=1197)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#7** | od uruchomienia |
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
> Świeżość: 7s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-13T22:55:57Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     7 │
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
│ ❤️ Heartbeat: 2026-02-13T22:55:57Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-13 22:53:20 | AUTO_TRANSLATE:parallel_start | da | ok | npc.json
- 2026-02-13 22:52:39 | AUTO_TRANSLATE:auto_done | sv | ok | npc.json
- 2026-02-13 22:52:36 | AUTO_TRANSLATE:auto_start | sv | ok | npc.json
- 2026-02-13 22:52:28 | AUTO_TRANSLATE:parallel_start | nl | ok | npc.json
- 2026-02-13 22:51:46 | AUTO_TRANSLATE:auto_done | tr | ok | server.json
- 2026-02-13 22:51:44 | AUTO_TRANSLATE:auto_start | tr | ok | server.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 73.8% | 2,083 | 2,949 | 2,097 | 506 (19.4%) | 84 |
| 🟡 ES | 71.3% | 232 | 15,349 | 3,060 | 232 (7.0%) | 94 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **37,870** | — | 📊 |
| Adaptive batch | batch=7, gf_rate=0.0%, reason=increase_low_fail_rate=0.0% | gf <5% → increase | 📊 |
| Throughput (last window) | 5,157 keys / 178 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-13 22:56:03

- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+17, skipped+0) — parallel lang=pl file=scripts.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+80, skipped+0) — lang=es file=server.json strict_skipped_done=202
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [es] → ok (translated+0, skipped+0) — parallel lang=es file=modules.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+1, skipped+0) — lang=pl file=talkactions.json strict_skipped_done=198 guard_fail=5 placeholder=0 command=0 pipe=1
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+2, skipped+0) — lang=es file=otclient_data.json strict_skipped_done=70
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [es] → ok (translated+80, skipped+0) — parallel lang=es file=questlog.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → warn (files+1, translated+18, skipped+0) — lang=pl file=cpp.json strict_skip missing_file=0 missing_key=2 skipped_done=859 strict_skipped_done=859 guard_fail=9 placeholder=0 command=0 pipe=0
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [pl] → ok (translated+1, skipped+0) — parallel lang=pl file=otclient_data.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → warn (files+1, translated+2, skipped+0) — lang=es file=otclient_data.json strict_skipped_done=70
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [es] → ok (translated+3, skipped+0) — parallel lang=es file=modules.json




## 📅 Dziś (UTC)

- Cykle: **471**
- MIGRATION: **+330** kluczy, **0** plików `.lua`
- Kategorie dotknięte: actions, chatchannels, cpp, creaturescripts, dataroot, errors, events, items, libs, mounts...
- Błędy: **986**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **2299** | w tej sesji |
| ✅ Plików z kluczami | **1897** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **402** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **6248** | przez workera w tej sesji |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#7** | continuous mode |

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
| Worker v1.1 | 🟢 RUNNING | Cykl #7 |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-13 22:56:03  
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
