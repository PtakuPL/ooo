# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 5000, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 1500, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja (UTC):** 2025-12-17 07:42:08  |  **Lokalnie:** 2025-12-17 08:42:08 CET  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 54 | **Klucze EN:** 27177  
> **LIVE:** Cykl #64 | Status: 🟢 RUNNING | Faza: MIGRATION | Etap: pending_skip | Kategoria: pending_skip | Plik: - | ETA: 0 | Heartbeat: 2025-12-17T07:42:04Z

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

---

## 📊 Globalny Postęp

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **17,772** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **8,153** | 45.9% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,283** | **77.1%** | historia workera |
| ⏳ Nie przeskanowane | **1,870** | 22.9% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,469 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 839 | silnik serwera |
| 📋 JSON (.json) | 1,271 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **3** | 0.0% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **0** | - | bez tekstów |
| 🔧 W trakcie | **14** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **27,177** | wszystkie kategorie |
| 📊 NPC | 6,946 | dialogi NPC |
| 📊 Items | 13,749 | przedmioty |
| 📊 Monsters | 132 | potwory (pliki źródłowe: 1,704) |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 4,855 | scripts, spells, etc. |

### 🔐 COMPACT_KEYS (2–7 znaków)
> **Status:** ✅ OK (keymap 33,523 ≥ EN 27,177; export missing: -)  
> **Dlaczego czasem nie uruchamia COMPACT_KEYS:** gdy status jest OK, worker przechodzi dalej do `TRANSLATION_SYNC` / `AUTO_TRANSLATE`.

### 🌍 Języki i Tłumaczenia
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **54** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **53** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **53** | **98.1%** | prawdziwe tłumaczenia |
| ⏳ Do tłumaczenia | **0** | - | tylko placeholdery |

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#64** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **3** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 0/54  
- Ostatni sync: -

### 🌍 Etap 2: Tłumaczenia (AUTO + TM)
| Język | TM wpisy | Status |
|-------|----------|--------|
| DE | 55 | ✅ TM |
| ES | 55 | ✅ TM |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 60 | ✅ TM |
| PT | 55 | ✅ TM |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 0 | ⚠️ placeholdery (brak TM) |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** fr, ru, tr

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 6946/15000 (46%) | 15000 |
| 📜 Lua Scripts | 🔄 | 634/1000 (63%) | 1000 |
| 🎒 Items Database | 🔄 | 13749/40000 (34%) | 40000 |
| 👹 Monsters | 🔄 | 132/5000 (3%) | 5000 |
| ✨ Spells & Magic | ✅ | 1426/1500 (95%) | 1500 |
| ⚙️ Server C++ | 🔄 | 66/300 (22%) | 300 |

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
| 💿 Server C++ | ⏳ | 0/500 (0%) | 500 |
| 🎮 OTClient Modules | ✅ | 1987/2000 (99%) | 2000 |
| 📦 OTClient Data | 🔄 | 72/200 (36%) | 200 |
| ⚙️ OTClient Src | ⏳ | 0/300 (0%) | 300 |
| 🔧 OTClient Mods | ⏳ | 0/100 (0%) | 100 |
| 🛠️ OTClient Tools | ⏳ | 0/50 (0%) | 50 |

### ⏳ Faza 4: 🌍 Tłumaczenia (Etap 1: Sync Kluczy)

| Język | Status | Kluczy | Etap |
|-------|--------|--------|------|
| 🇩🇪 Niemiecki | ⏳ Czeka | 0 | nie rozpoczęto |
| 🇵🇱 Polski | ⏳ Czeka | 0 | nie rozpoczęto |
| 🇪🇸 Hiszpański | ⏳ Czeka | 0 | nie rozpoczęto |
| 🇫🇷 Francuski | ⏳ Czeka | 0 | nie rozpoczęto |
| 🌐 Pozostałe (0/53) | ⏳ | 0 | nie rozpoczęto |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 0/54
- Ostatni sync: -

### 🌍 Etap 2: Tłumaczenia (AUTO)
| Język | TM wpisy | Status |
|-------|----------|--------|
| DE | 55 | ✅ TM |
| ES | 55 | ✅ TM |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 60 | ✅ TM |
| PT | 55 | ✅ TM |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 0 | ⚠️ placeholdery (brak TM) |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** fr, ru, tr
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #    64 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🔧 MIGRATION (pending_skip)               │
│ Kategoria: 📁 PENDING_SKIP                           │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: -                                                       │
│ Postęp: 0/0 files                                             │
│ Info: all categories skipped                                  │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2025-12-17T07:42:04Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2025-12-17 07:05:36 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/woblin.lua
- 2025-12-17 07:05:31 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/ser_tybald.lua
- 2025-12-17 07:05:30 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/riddler.lua
- 2025-12-17 07:05:29 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/rafzan.lua
- 2025-12-17 07:05:28 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/plunderpurse.lua
- 2025-12-17 07:05:27 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/oressa.lua

---

## 🔁 W tym cyklu

- 🔧 MIGRATION: zakończono kategorię [otclient_data] → ok (keys+0, files+0) — migration finished
- 🔧 MIGRATION: mini-batch stop [otclient_data] → ok (keys+0) — no new data
- 🔧 MIGRATION: mini-batch [otclient_data] → ok (keys+0) — mini_batch=1 processed=10/20
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [it] → ok (files+1, translated+0, skipped+8) — lang=it file=chatchannels.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=libs.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pt] → ok (files+1, translated+0, skipped+2) — lang=pt file=creaturescripts.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pt] → ok (files+1, translated+0, skipped+295) — lang=pt file=spells.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json




## 📅 Dziś (UTC)

- Cykle: **766**
- MIGRATION: **+30808** kluczy, **515** plików `.lua`
- Kategorie dotknięte: actions, chatchannels, cpp, creaturescripts, dataroot, errors, events, globalevents, items, libs...
- Błędy: **0**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **17** | w tej sesji |
| ✅ Plików z kluczami | **3** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **14** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **3** | przez workera w tej sesji |
| 🌍 Języków | **54** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#64** | continuous mode |

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
<summary>🎒 2. Items - 🔄 (34%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 13749 |
| 🎯 Cel | 40000 |
| 📊 Postęp | 34% |
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
<summary>👹 4. Monsters - 🔄 (3%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 132 |
| 🎯 Cel | 5000 |
| 📊 Postęp | 3% |
| 📁 Plik | i18n/en/monsters.json |

</details>

<details>
<summary>🧙 5. NPC - 🔄 (46%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 6946 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 46% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | 1027 |
| ✅ Zmigrowanych | 678 |
| 🔄 Do migracji | 19 |

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
<summary>📜 7. Quests - 🔄 (23%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 117 |
| 🎯 Cel | 500 |
| 📊 Postęp | 23% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - 🔄 (63%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 634 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 63% |
| 📁 Plik | i18n/en/scripts.json |

</details>

<details>
<summary>⚙️ 9. Server - 🔄 (22%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 66 |
| 🎯 Cel | 300 |
| 📊 Postęp | 22% |
| 📁 Plik | i18n/en/server.json |

</details>

<details>
<summary>✨ 10. Spells - ✅ (95%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 1426 |
| 🎯 Cel | 1500 |
| 📊 Postęp | 95% |
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
| items | 13749 | 0 | 0 | ✅ Active |
| npc | 6946 | 0 | 0 | ✅ Active |
| otclient_modules | 1987 | 0 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| spells | 1426 | 0 | 0 | ✅ Active |
| scripts | 634 | 0 | 0 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 0 | ✅ Active |
| monsters | 132 | 0 | 0 | ✅ Active |
| quests | 117 | 0 | 0 | ✅ Active |
| otclient_data | 72 | 0 | 0 | ✅ Active |
| server | 66 | 0 | 0 | ✅ Active |
| php | 59 | 0 | 0 | ✅ Active |
| startup | 23 | 0 | 0 | ✅ Active |
| actions | 21 | 0 | 0 | ✅ Active |
| libs | 21 | 0 | 0 | ✅ Active |
| modules | 16 | 0 | 0 | ✅ Active |
| example_merchant | 14 | 0 | 0 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 0 | ✅ Active |
| events | 5 | 0 | 0 | ✅ Active |
| dataroot | 3 | 0 | 0 | ✅ Active |
| creaturescripts | 2 | 0 | 0 | ✅ Active |
| cpp | 0 | 0 | 0 | ⏳ Empty |
| errors | 0 | 0 | 0 | ⏳ Empty |
| globalevents | 0 | 0 | 0 | ⏳ Empty |
| mounts | 0 | 0 | 0 | ⏳ Empty |
| movements | 0 | 0 | 0 | ⏳ Empty |
| npclib | 0 | 0 | 0 | ⏳ Empty |
| otclient_mods | 0 | 0 | 0 | ⏳ Empty |
| otclient_src | 0 | 0 | 0 | ⏳ Empty |
| otclient_tools | 0 | 0 | 0 | ⏳ Empty |
| talkactions | 0 | 0 | 0 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 0 | ⏳ Empty |

---

## 🤖 Worker Category State

*Brak kategorii z aktywnym skip*

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #64 |
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

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
| 🎒 Items | 13749 | ██████░░░░░░░░░░░░░░ | 40000 | 🔄 34% |
| 🧙 NPC | 6946 | █████████░░░░░░░░░░░ | 15000 | 🔄 46% |
| 📜 Scripts | 634 | ████████████░░░░░░░░ | 1000 | 🔄 63% |
| 👹 Monsters | 132 | ░░░░░░░░░░░░░░░░░░░░ | 5000 | 🔄 3% |
| ✨ Spells | 1426 | ███████████████████░ | 1500 | ✅ 95% |
| ⚙️ Server | 66 | ████░░░░░░░░░░░░░░░░ | 300 | 🔄 22% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last (UTC): 2025-12-17 07:42:08 | Local: 2025-12-17 08:42:08 CET  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `extended_holy_chain` - ukończono 2025-12-17 08:30
- ✅ `root` - ukończono 2025-12-17 08:30
- ✅ `elder_bonelord_paralyze` - ukończono 2025-12-17 08:30

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
