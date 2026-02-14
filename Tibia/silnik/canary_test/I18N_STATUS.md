# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 700, 'scripts': 2500, 'server': 3000, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 900, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50, 'achievements': 1048, 'actions': 100, 'books': 1403, 'chatchannels': 100, 'creaturescripts': 100, 'dataroot': 100, 'errors': 100, 'events': 100, 'example_merchant': 100, 'globalevents': 100, 'libs': 100, 'messages': 100, 'modules': 100, 'mounts': 100, 'movements': 100, 'npclib': 147, 'questlog': 1918, 'raids': 273, 'startup': 100, 'talkactions': 199, 'world': 100} -->

## 🧭 META

> **[META]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `update_github_status()` | Ostatnia aktualizacja: 2026-02-14 07:06:13

> **Aktualizacja:** 2026-02-14 07:06:13 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 53586  
> **LIVE:** Cykl #1 | Status: 🟢 RUNNING | Faza: AUTO_TRANSLATE | Etap: parallel_start | Kategoria: th | Plik: npc.json | ETA: 0 | Heartbeat: 2026-02-14T07:05:20Z  
> **Strict hourly (JSONL-only):** okno=1.0h | cycles=40 | pending_skip=0.0% | guard_fail=2.2% | throughput=3330.2/h  
> **Net effective translated:** 63,040

### 🧩 Status sekcji (P0.1)
| Sekcja | Stan | Świeżość | Powód | Źródło | Ostatnia aktualizacja |
|--------|------|----------|-------|--------|-----------------------|
| META | 🟢 ACTIVE | teraz | - | `update_github_status()` | 2026-02-14 07:06:13 |
| LIVE | 🟢 ACTIVE | 54s temu | - | `activity.json / worker_state.json` | 2026-02-14T07:05:20Z |
| MIGRATION | 🔒 INACTIVE | 12h temu | worker w trybie AUTO_TRANSLATE | `i18n_file_status.json` | 2026-02-14 07:06:13 |
| TRANSLATION | 🟢 ACTIVE | 4s temu | - | `translation_guard_latest.json / translation_recent_latest.json` | 2026-02-14T07:06:09.539633Z |
| QUALITY | 🔒 INACTIVE | 15min temu | worker w trybie AUTO_TRANSLATE | `quality_audit_latest.json` | 2026-02-14T06:50:33.339457Z |
| HISTORY | 🟢 ACTIVE | teraz | - | `daily/*.json / ops.jsonl` | 2026-02-14 07:06:13 |

> Artefakt machine-readable: `i18n/status/status_sections_latest.json`

---

## 🔴 LIVE

> **[LIVE]** 🟢 ACTIVE  
> Świeżość: 54s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T07:05:20Z

- **Faza:** `AUTO_TRANSLATE`
- **Etap:** `parallel_start`
- **Kategoria:** `th`
- **Plik:** `npc.json`
- **Status:** 🟢 RUNNING
- **Heartbeat:** `2026-02-14T07:05:20Z`

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
> Świeżość: 12h temu | Źródło: `i18n_file_status.json` | Ostatnia aktualizacja: 2026-02-14 07:06:13

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **20,265** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **9,395** | 46.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,443** | **68.6%** | historia workera |
| ⏳ Nie przeskanowane | **2,952** | 31.4% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,471 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 840 | silnik serwera |
| 📋 JSON (.json) | 2,499 | konfiguracje |

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
> Świeżość: 4s temu | Źródło: `translation_guard_latest.json / translation_recent_latest.json` | Ostatnia aktualizacja: 2026-02-14T07:06:09.539633Z

| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **0** | **0.0%** | >=95% pokrycia i 0 braków kluczy |
| ⏳ Do tłumaczenia | **52** | - | wymagają dalszego uzupełnienia |

### 🎯 Pokrycie tłumaczeń per język (EN → LANG)
| Język | Przetłumaczone | % poprawnie przetłumaczonych | EN-copy | Braki kluczy |
|-------|----------------|-------------------------------|---------|--------------|
| ES (Hiszpański) | 45,433/53,586 | 84.79% | 11,460 | 232 |
| PL (Polski) | 40,166/53,586 | 74.96% | 2,857 | 2,083 |
| AR (Arabski) | 11,927/53,586 | 22.26% | 31,209 | 2,150 |
| ID (ID) | 11,779/53,586 | 21.98% | 29,236 | 2,155 |
| BN (BN) | 11,773/53,586 | 21.97% | 29,239 | 2,155 |
| FA (FA) | 11,773/53,586 | 21.97% | 29,239 | 2,155 |
| HI (HI) | 11,772/53,586 | 21.97% | 29,241 | 2,155 |
| HY (HY) | 11,773/53,586 | 21.97% | 29,240 | 2,155 |
| KA (KA) | 11,773/53,586 | 21.97% | 29,241 | 2,155 |
| SW (SW) | 11,771/53,586 | 21.97% | 29,235 | 2,155 |
| TE (TE) | 11,772/53,586 | 21.97% | 29,233 | 2,155 |
| TH (TH) | 11,772/53,586 | 21.97% | 29,233 | 2,155 |
| KO (Koreański) | 11,767/53,586 | 21.96% | 29,232 | 2,155 |
| ML (ML) | 11,769/53,586 | 21.96% | 29,237 | 2,155 |
| HE (HE) | 11,690/53,586 | 21.82% | 29,287 | 2,155 |
| MS (MS) | 11,692/53,586 | 21.82% | 29,285 | 2,155 |
| TL (TL) | 11,692/53,586 | 21.82% | 29,301 | 2,155 |
| VI (VI) | 11,694/53,586 | 21.82% | 29,280 | 2,155 |
| JA (Japoński) | 11,659/53,586 | 21.76% | 29,289 | 2,155 |
| TA (TA) | 11,612/53,586 | 21.67% | 29,282 | 2,155 |

### 🧭 Aktywny folder tłumaczeń
- **Folder:** LV - LV - Serwer
- **Plik JSON:** npc.json
- **Ostatnie klucze (10-20):** 20

### 📝 Ostatnie 10-20 przetłumaczonych kluczy
- If another prince comes to kiss me, I'll kick his ass so bad that he'll need a s → ถ้าเจ้าชายอีกคนมาจูบฉัน ฉันจะเตะตูดเขาจนต้องนั่งเกวียนหนีไป. (npc.a_frog.stdmod_1)
- If another prince comes to kiss me, I'll kick his ass so bad that he'll need a s → ถ้าเจ้าชายอีกคนมาจูบฉัน ฉันจะเตะตูดเขาจนต้องนั่งเกวียนหนีไป. (npc.a_frog.stdmod_2)
- Don't even try to kiss me or I'll rondhouse kick you! → อย่าแม้แต่จะจูบฉัน ไม่งั้นฉันจะเตะคุณ! (npc.a_frog.stdmod_3)
- Talking frogs don't exist, idiot. It's your fucking imagination tricking you. An → กบพูดได้ไม่มีอยู่จริง ไอ้โง่ มันเป็นจินตนาการร่วมเพศของคุณที่หลอกคุณ และตอนนี้จิ (npc.a_frog.stdmod_4)
- Finally someone notices I'm a FROG. Congratulations, you're VERY observant... *s → ในที่สุดก็มีคนสังเกตเห็นว่าฉันเป็นกบ ยินดีด้วย คุณช่างสังเกตมาก... *ถอนหายใจ* (npc.a_frog.stdmod_5)
- A quest? Yeah I got a quest! Go and tell King Tibianus his son tried to kiss me  → ภารกิจ? ใช่แล้ว ฉันมีภารกิจ! ไปบอกกษัตริย์ Tibianus ลูกชายของเขาว่าพยายามจะจูบฉั (npc.a_frog.stdmod_6)
- Pyrale? That idiot transformed me into an human once. But my wife came and kisse → ไพเรล? ไอ้โง่นั่นทำให้ฉันกลายเป็นมนุษย์ครั้งหนึ่ง แต่เมียมาจูบฉัน ฉันก็กลายเป็นก (npc.a_frog.stdmod_7)
- Pyrale? That idiot transformed me into an human once. But my wife came and kisse → ไพเรล? ไอ้โง่นั่นทำให้ฉันกลายเป็นมนุษย์ครั้งหนึ่ง แต่เมียมาจูบฉัน ฉันก็กลายเป็นก (npc.a_frog.stdmod_8)
- Hah! That idiot finally left. → ฮ่า! ในที่สุดคนโง่คนนั้นก็จากไป. (npc.a_frog.walkaway_msg_1)
- Ah, I feel a mortal walks these ancient halls again. Pardon me, I barely notice  → อา ฉันรู้สึกว่ามนุษย์กำลังเดินอยู่ในห้องโถงโบราณเหล่านี้อีกครั้ง ขอโทษที ฉันแทบจ (npc.a_ghostly_sage.greet_msg_1)
- You will now be travelled out of here. Are you sure that you want to face that t → ตอนนี้คุณจะถูกเดินทางออกจากที่นี่ คุณแน่ใจหรือว่าต้องการเผชิญกับเทเลพอร์ตนั้น? (npc.a_ghostly_sage.stdmod_1)
- Then stay here in these ghostly halls. → ถ้าอย่างนั้นก็อยู่ที่นี่ในห้องโถงผีสิงเหล่านี้. (npc.a_ghostly_sage.stdmod_2)
- I can offer you a {teleport}. → ฉันสามารถเสนอ {teleport} ให้คุณได้. (npc.a_ghostly_sage.stdmod_3)
- Dont mind me. → อย่ารังเกียจฉันเลย. (npc.a_ghostly_sage.stdmod_4)
- Alone ... so alone. So cold. → คนเดียว...เดียวดาย.. หนาวจังเลย. (npc.a_ghostly_woman.farewell_msg_1)
- I feel you. I hear your thoughts. You are ... alive. → ฉันรู้สึกถึงคุณ ฉันได้ยินความคิดของคุณ คุณ...มีชีวิตอยู่. (npc.a_ghostly_woman.greet_msg_1)
- Once I was a member of the order of the nightmare knights. Now I am but a shadow → ครั้งหนึ่งฉันเคยเป็นสมาชิกลำดับอัศวินฝันร้าย ตอนนี้ฉันเป็นเพียงเงาที่เดินอยู่ในห (npc.a_ghostly_woman.stdmod_1)
- The north has a puzzle to complete. → ภาคเหนือมีปริศนาให้แก้. (npc.a_ghostly_woman.stdmod_2)
- Alone ... so alone. So cold. → คนเดียว...เดียวดาย.. หนาวจังเลย. (npc.a_ghostly_woman.voice_1)
- Alone ... so alone. So cold. → คนเดียว...เดียวดาย.. หนาวจังเลย. (npc.a_ghostly_woman.walkaway_msg_1)

### 🚫 Raporty "nie mogę przetłumaczyć"
- Guard reports: **1972**  
- Blocker reports: **0**  
- Widoczne raporty 'nie mogę tłumaczyć': **1922**

### 🌐 Globalne info wszystkich języków
- **Global completion:** **21.0%** (585,227/2,786,472)
- **EN-copy łącznie:** **1,333,716**
- **Braki kluczy łącznie:** **110,060**
- **Brakujące pliki językowe:** **0**
- **Cache STATUSPY (per-lang):** **mixed** | hit **50**, miss **2**, hit-rate **96.2%**
- **Cache STATUSPY (per-file):** hit **1974**, miss **2**, hit-rate **99.9%**
- **Profiler cyklu (ostatni):** -
- **Osobny raport:** `i18n/status/translation_global_overview.json`

### 🖥️ Serwer vs 📦 Instalka (OTClient)
| Zakres | EN kluczy |
|--------|-----------|
| 🖥️ **Serwer** | **49,731** |
| 📦 **Instalka** (klient/OTClient) | **3,855** |

| Język | Serwer | Serwer % | Instalka | Instalka % |
|-------|--------|----------|----------|------------|
| ES | 42,906/49,731 | 86.3% | 2,527/3,855 | 65.5% |
| PL | 37,406/49,731 | 75.2% | 2,760/3,855 | 71.6% |
| AR | 11,914/49,731 | 24.0% | 13/3,855 | 0.3% |
| ID | 11,766/49,731 | 23.7% | 13/3,855 | 0.3% |
| BN | 11,760/49,731 | 23.6% | 13/3,855 | 0.3% |
| FA | 11,760/49,731 | 23.6% | 13/3,855 | 0.3% |
| HI | 11,759/49,731 | 23.6% | 13/3,855 | 0.3% |
| HY | 11,760/49,731 | 23.6% | 13/3,855 | 0.3% |
| KA | 11,760/49,731 | 23.6% | 13/3,855 | 0.3% |
| SW | 11,758/49,731 | 23.6% | 13/3,855 | 0.3% |
| TE | 11,759/49,731 | 23.6% | 13/3,855 | 0.3% |
| TH | 11,759/49,731 | 23.6% | 13/3,855 | 0.3% |

### ⏱️ Strict Hourly Window (JSONL-only)
| Metryka | Wartość |
|---------|---------|
| Okno | **1.0h** (2026-02-14T06:06:13.493188Z → 2026-02-14T07:06:13.493188Z) |
| Cykle | **40** (AUTO=40, MIGRATION=0) |
| Pending skip | **0** (all=0.0%, migration=0.0%) |
| Guard fail rate | **2.2%** |
| No progress rate | **0.0%** |
| Throughput | **3330.2 kluczy/h** |
| Suspicious | **902** |
| Top guard_fail targets | ja/npc.json (gf=50), it/server.json (gf=0), tr/server.json (gf=0), da/npc.json (gf=0), no/npc.json (gf=0) |
| Źródła | `i18n/status/worker_cycle_perf.jsonl`, `i18n/status/translation_guard_report.jsonl`, `i18n/status/suspicious_log.jsonl` |
| Plik | `i18n/status/strict_hourly_window_latest.json` |

## 🔬 QUALITY

> **[QUALITY]** 🔒 INACTIVE (worker w trybie AUTO_TRANSLATE)  
> Świeżość: 15min temu | Źródło: `quality_audit_latest.json` | Ostatnia aktualizacja: 2026-02-14T06:50:33.339457Z

- **Ostatni audyt:** OK | 0 issue(s) / 100 entries | 2026-02-14T06:50:33.339457Z
- **Top 5 typów problemów:** suspicious_rejected_critical=200, suspicious_log_high=160, suspicious_log_low=33, suspicious_log_medium=6, suspicious_log_critical=1
- **Języki o najsłabszej jakości:** es(60.1, issues=136162), pl(60.1, issues=106978), ar(62.5, issues=2666), it(66.0, issues=2695), fr(67.3, issues=2437)
- **Pliki:** `i18n/status/quality_audit_latest.json`, `i18n/status/quality_dashboard.json`, `i18n/status/quality_report.jsonl`

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#1** | od uruchomienia |
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
> **Aktualna kategoria:** th


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
> Świeżość: 54s temu | Źródło: `activity.json / worker_state.json` | Ostatnia aktualizacja: 2026-02-14T07:05:20Z

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     1 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🤖 AUTO_TRANSLATE (parallel_start)        │
│ Kategoria: 📁 TH                                     │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: npc.json                                                │
│ Postęp: 0/0 keys                                              │
│ Info: parallel auto translate                                 │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2026-02-14T07:05:20Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2026-02-14 07:05:20 | AUTO_TRANSLATE:parallel_start | th | ok | npc.json
- 2026-02-14 07:04:10 | AUTO_TRANSLATE:auto_done | te | ok | npc.json
- 2026-02-14 07:03:39 | AUTO_TRANSLATE:auto_start | te | ok | npc.json
- 2026-02-14 07:01:41 | AUTO_TRANSLATE:auto_done | sw | ok | npc.json
- 2026-02-14 07:00:50 | AUTO_TRANSLATE:auto_start | sw | ok | npc.json
- 2026-02-14 06:58:59 | AUTO_TRANSLATE:auto_done | sq | ok | npc.json

---

## 📊 KPI Dashboard — Pilot Health (PL/ES)

| Język | Coverage | Brakujące | EN-copy | Translated(200) | Guard fail | Entries |
|-------|----------|-----------|---------|-----------------|------------|---------|
| 🟡 PL | 75.0% | 2,083 | 2,857 | 686 | 254 (27.0%) | 21 |
| 🟡 ES | 84.8% | 232 | 11,460 | 612 | 241 (28.3%) | 21 |

| KPI | Wartość | Target | Status |
|-----|---------|--------|--------|
| Net effective translated | **63,040** | — | 📊 |
| Adaptive batch | batch=50, gf_rate=6.25%, reason=stable_fail_rate=6.2% | gf <5% → increase | 📊 |
| Throughput (last window) | 1,298 keys / 42 entries | >50/h | 📊 |

---

## 📜 HISTORY

> **[HISTORY]** 🟢 ACTIVE  
> Świeżość: teraz | Źródło: `daily/*.json / ops.jsonl` | Ostatnia aktualizacja: 2026-02-14 07:06:13

- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [th] → ok (translated+80, skipped+0) — parallel lang=th file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [te] → warn (files+1, translated+80, skipped+0) — lang=te file=npc.json strict_skipped_done=1220
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [sw] → warn (files+1, translated+80, skipped+0) — lang=sw file=npc.json strict_skipped_done=1220
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [sq] → warn (files+1, translated+80, skipped+0) — lang=sq file=npc.json strict_skipped_done=1220
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [sk] → warn (files+1, translated+80, skipped+0) — lang=sk file=npc.json strict_skipped_done=1220
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [mk] → ok (translated+80, skipped+0) — parallel lang=mk file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [lv] → warn (files+1, translated+80, skipped+0) — lang=lv file=npc.json strict_skipped_done=1220
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [ja] → ok (translated+30, skipped+0) — parallel lang=ja file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [id] → warn (files+1, translated+80, skipped+0) — lang=id file=npc.json strict_skipped_done=1225
- 🤖 AUTO_TRANSLATE: PARALLEL_TRANSLATE_DONE [hr] → ok (translated+80, skipped+0) — parallel lang=hr file=npc.json




## 📅 Dziś (UTC)

- Cykle: **49**
- MIGRATION: **+0** kluczy, **0** plików `.lua`
- Kategorie dotknięte: -
- Błędy: **247**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **2299** | w tej sesji |
| ✅ Plików z kluczami | **1897** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **402** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **6248** | przez workera w tej sesji |
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
📅 Auto-updated by Worker v1.1 | Last: 2026-02-14 07:06:13  
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
