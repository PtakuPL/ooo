# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 6000, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 2000, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja:** 2025-12-21 10:06:03 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 54 | **Klucze EN:** 36454  
> **LIVE:** Cykl #243 | Status: 🟢 RUNNING | Faza: MIGRATION | Etap: pending_skip | Kategoria: pending_skip | Plik: - | ETA: 0 | Heartbeat: 2025-12-21T09:05:33Z

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
| 📂 **Wszystkie pliki** | **18,913** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **8,156** | 43.1% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **6,418** | **78.7%** | historia workera |
| ⏳ Nie przeskanowane | **1,738** | 21.3% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,469 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 839 | silnik serwera |
| 📋 JSON (.json) | 1,273 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **1891** | 29.5% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **346** | - | bez tekstów |
| 🔧 W trakcie | **3** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **36,454** | wszystkie kategorie |
| 📊 NPC | 7,243 | dialogi NPC |
| 📊 Items | 16,761 | przedmioty |
| 📊 Monsters | 5,915 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 5,040 | scripts, spells, etc. |

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
| 🔄 Cykl aktualny | **#243** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **6,242** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 52/54  
- Ostatni sync: SW/spells.json

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

**Języki bez TM (AUTO → placeholdery):** ar, az, bg, bn, bs, cs, da, el...

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 7243/15000 (48%) | 15000 |
| 📜 Lua Scripts | 🔄 | 641/1000 (64%) | 1000 |
| 🎒 Items Database | 🔄 | 16761/40000 (42%) | 40000 |
| 👹 Monsters | ✅ | 5915/6000 (99%) | 6000 |
| ✨ Spells & Magic | 🔄 | 1526/2000 (76%) | 2000 |
| ⚙️ Server C++ | 🔄 | 66/300 (22%) | 300 |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | 🔄 | 59/3000 (2%) | 3000 |
| 📄 HTML Views | ✅ | 1495/300 (498%) | 300 |
| 📦 JavaScript | 🔄 | 242/300 (81%) | 300 |

### ⏳ Faza 3: 📱 OTClient / Testyy

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | ⏳ | 0/200 (0%) | 200 |
| 💿 Server C++ | ⏳ | 0/500 (0%) | 500 |
| 🎮 OTClient Modules | ✅ | 1987/500 (397%) | 500 |
| 📦 OTClient Data | 🔄 | 72/200 (36%) | 200 |
| ⚙️ OTClient Src | ⏳ | 0/300 (0%) | 300 |
| 🔧 OTClient Mods | ⏳ | 0/100 (0%) | 100 |
| 🛠️ OTClient Tools | ⏳ | 0/50 (0%) | 50 |

### ⏳ Faza 4: 🌍 Tłumaczenia (Etap 1: Sync Kluczy)

| Język | Status | Kluczy | Etap |
|-------|--------|--------|------|
| 🇩🇪 Niemiecki | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🇵🇱 Polski | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🇪🇸 Hiszpański | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🇫🇷 Francuski | 📊 1426 kluczy | 1426 | [EN] prefix |
| 🌐 Pozostałe (0/53) | 🔄 | 386722 | Aktualnie: SW |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 52/54
- Ostatni sync: SW/spells.json

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

**Języki bez TM (AUTO → placeholdery):** ar, az, bg, bn, bs, cs, da, el...
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #   243 │
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
│ ❤️ Heartbeat: 2025-12-21T09:05:33Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2025-12-21 08:12:08 | MIGRATION:file | npc | ok | data-otservbr-global/npc/frodo.lua
- 2025-12-21 08:12:06 | MIGRATION:file | npc | ok | data-otservbr-global/npc/freezhild.lua
- 2025-12-21 08:12:04 | MIGRATION:file | npc | ok | data-otservbr-global/npc/frank_the_plank.lua
- 2025-12-21 08:12:01 | MIGRATION:file | npc | ok | data-otservbr-global/npc/frafnar.lua
- 2025-12-21 08:12:00 | MIGRATION:file | npc | ok | data-otservbr-global/npc/florentine.lua
- 2025-12-21 08:11:57 | MIGRATION:file | npc | ok | data-otservbr-global/npc/flora.lua

---

## 🔁 W tym cyklu

- 🌍 TRANSLATION_SYNC: SYNC_FILE_DONE [ro] → ok (keys+1122, files+1) — lang=ro file=spells.json
- 🌍 TRANSLATION_SYNC: SYNC_FILE_DONE [lt] → ok (keys+1541, files+1) — lang=lt file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=libs.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [fi] → ok (files+1, translated+0, skipped+8) — lang=fi file=chatchannels.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json
- 🌍 TRANSLATION_SYNC: SYNC_FILE_DONE [mk] → ok (keys+66, files+1) — lang=mk file=server.json




## 📅 Dziś (UTC)

- Cykle: **185**
- MIGRATION: **+17946** kluczy, **943** plików `.lua`
- Kategorie dotknięte: actions, chatchannels, cpp, creaturescripts, dataroot, errors, events, globalevents, items, libs...
- Błędy: **0**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **2240** | w tej sesji |
| ✅ Plików z kluczami | **1891** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **349** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **6242** | przez workera w tej sesji |
| 🌍 Języków | **54** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#243** | continuous mode |

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
<summary>🎒 2. Items - 🔄 (42%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 16761 |
| 🎯 Cel | 40000 |
| 📊 Postęp | 42% |
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
<summary>🧙 5. NPC - 🔄 (48%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 7243 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 48% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | 1027 |
| ✅ Zmigrowanych | 695 |
| 🔄 Do migracji | 2 |

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
<summary>📜 7. Quests - 🔄 (26%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 132 |
| 🎯 Cel | 500 |
| 📊 Postęp | 26% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - 🔄 (64%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 641 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 64% |
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
<summary>✨ 10. Spells - 🔄 (76%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 1526 |
| 🎯 Cel | 2000 |
| 📊 Postęp | 76% |
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
| items | 16761 | 0 | 0 | ✅ Active |
| npc | 7243 | 0 | 0 | ✅ Active |
| monsters | 5915 | 0 | 0 | ✅ Active |
| otclient_modules | 1987 | 0 | 0 | ✅ Active |
| spells | 1526 | 0 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| scripts | 641 | 0 | 0 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 0 | ✅ Active |
| quests | 132 | 0 | 0 | ✅ Active |
| otclient_data | 72 | 0 | 0 | ✅ Active |
| server | 66 | 0 | 0 | ✅ Active |
| php | 59 | 0 | 0 | ✅ Active |
| npclib | 40 | 0 | 0 | ✅ Active |
| libs | 29 | 0 | 0 | ✅ Active |
| actions | 28 | 0 | 0 | ✅ Active |
| startup | 23 | 0 | 0 | ✅ Active |
| modules | 18 | 0 | 0 | ✅ Active |
| example_merchant | 14 | 0 | 0 | ✅ Active |
| events | 11 | 0 | 0 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 0 | ✅ Active |
| dataroot | 3 | 0 | 0 | ✅ Active |
| creaturescripts | 2 | 0 | 0 | ✅ Active |
| cpp | 0 | 0 | 0 | ⏳ Empty |
| errors | 0 | 0 | 0 | ⏳ Empty |
| globalevents | 0 | 0 | 0 | ⏳ Empty |
| mounts | 0 | 0 | 0 | ⏳ Empty |
| movements | 0 | 0 | 0 | ⏳ Empty |
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
| Worker v1.1 | 🟢 RUNNING | Cykl #243 |
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
| 🎒 Items | 16761 | ████████░░░░░░░░░░░░ | 40000 | 🔄 42% |
| 🧙 NPC | 7243 | █████████░░░░░░░░░░░ | 15000 | 🔄 48% |
| 📜 Scripts | 641 | ████████████░░░░░░░░ | 1000 | 🔄 64% |
| 👹 Monsters | 5915 | ███████████████████░ | 6000 | ✅ 99% |
| ✨ Spells | 1526 | ███████████████░░░░░ | 2000 | 🔄 76% |
| ⚙️ Server | 66 | ████░░░░░░░░░░░░░░░░ | 300 | 🔄 22% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-21 10:06:03  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `items_classification.hpp` - ukończono 2025-12-21 09:48
- ✅ `pch.hpp` - ukończono 2025-12-21 09:48
- ✅ `canary_server.cpp` - ukończono 2025-12-21 09:48
- ✅ `account.cpp` - ukończono 2025-12-21 09:48
- ✅ `account_info.hpp` - ukończono 2025-12-21 09:48
- ✅ `account_repository_db.hpp` - ukończono 2025-12-21 09:48
- ✅ `account.hpp` - ukończono 2025-12-21 09:48
- ✅ `pch.cpp` - ukończono 2025-12-21 09:48
- ✅ `game_definitions.hpp` - ukończono 2025-12-21 09:48
- ✅ `zone.hpp` - ukończono 2025-12-21 09:48

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
