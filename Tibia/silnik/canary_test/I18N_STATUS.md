# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 5000, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 2000, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja (UTC):** 2025-12-17 00:06:25  |  **Lokalnie:** 2025-12-17 01:06:25 CET  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 54 | **Klucze EN:** 25619  
> **LIVE:** Cykl #18 | Status: 🟢 RUNNING | Faza: MIGRATION | Etap: file | Kategoria: npc | Plik: data-otservbr-global/npc/rock_with_a_soft_spot.lua | ETA: 0 | Heartbeat: 2025-12-17T00:06:24Z

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
| 📂 **Wszystkie pliki** | **17,658** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **8,151** | 46.2% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **5,449** | **66.9%** | historia workera |
| ⏳ Nie przeskanowane | **2,702** | 33.1% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,469 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 839 | silnik serwera |
| 📋 JSON (.json) | 1,270 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **16** | 0.3% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **0** | - | bez tekstów |
| 🔧 W trakcie | **0** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **25,619** | wszystkie kategorie |
| 📊 NPC | 6,510 | dialogi NPC |
| 📊 Items | 13,749 | przedmioty |
| 📊 Monsters | 132 | potwory (pliki źródłowe: 1,704) |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 3,733 | scripts, spells, etc. |

### 🔐 COMPACT_KEYS (2–7 znaków)
> **Status:** ✅ OK (keymap 31,982 ≥ EN 25,619; export missing: -)  
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
| 🔄 Cykl aktualny | **#18** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **16** | w tej sesji |
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
| 🧙 NPC Dialogs | 🔄 | 6510/15000 (43%) | 15000 |
| 📜 Lua Scripts | 🔄 | 634/1000 (63%) | 1000 |
| 🎒 Items Database | 🔄 | 13749/40000 (34%) | 40000 |
| 👹 Monsters | 🔄 | 132/5000 (3%) | 5000 |
| ✨ Spells & Magic | 🔄 | 304/400 (76%) | 400 |
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
│ 🔴 LIVE: Worker v2.0                          Cykl #    18 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🔧 MIGRATION (file)                       │
│ Kategoria: 📁 NPC                                    │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: data-otservbr-global/npc/rock_with_a_soft_spot.lua      │
│ Postęp: 8/190 files                                           │
│ Info: processing                                              │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2025-12-17T00:06:24Z           │
└─────────────────────────────────────────────────────────────────┘
```

### 🧾 Ostatnie akcje (dla czytelności)

- 2025-12-17 00:06:24 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/rock_with_a_soft_spot.lua
- 2025-12-17 00:06:22 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/charos.lua
- 2025-12-17 00:06:22 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/robson.lua
- 2025-12-17 00:06:20 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/riddler.lua
- 2025-12-17 00:06:18 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/richard.lua
- 2025-12-17 00:06:17 UTC | MIGRATION:file | npc | ok | data-otservbr-global/npc/rehon.lua

---

## 🔁 W tym cyklu

- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [bg] → ok (files+1, translated+0, skipped+3) — lang=bg file=dataroot.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [es] → ok (files+1, translated+0, skipped+3390) — lang=es file=npc.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [ro] → ok (files+1, translated+0, skipped+634) — lang=ro file=scripts.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [lt] → ok (files+1, translated+0, skipped+21) — lang=lt file=libs.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [lt] → ok (files+1, translated+0, skipped+13749) — lang=lt file=items.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+72) — lang=de file=otclient_data.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+147) — lang=de file=raids.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+7) — lang=de file=chatchannels.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [pl] → ok (files+1, translated+0, skipped+12) — lang=pl file=libs.json
- 🤖 AUTO_TRANSLATE: AUTO_TRANSLATE_DONE [de] → ok (files+1, translated+0, skipped+21) — lang=de file=actions.json




## 📅 Dziś (UTC)

- Cykle: **8**
- MIGRATION: **+895** kluczy, **322** plików `.lua`
- Kategorie dotknięte: npc
- Błędy: **0**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **16** | w tej sesji |
| ✅ Plików z kluczami | **16** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **0** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **16** | przez workera w tej sesji |
| 🌍 Języków | **54** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#18** | continuous mode |

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
<summary>🧙 5. NPC - 🔄 (43%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 6510 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 43% |
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
<summary>✨ 10. Spells - 🔄 (76%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 304 |
| 🎯 Cel | 400 |
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
| items | 13749 | 0 | 0 | ✅ Active |
| npc | 6510 | 0 | 0 | ✅ Active |
| otclient_modules | 1987 | 0 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| scripts | 634 | 0 | 0 | ✅ Active |
| spells | 304 | 0 | 0 | ✅ Active |
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
| Worker v1.1 | 🟢 RUNNING | Cykl #18 |
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
| 🧙 NPC | 6510 | ████████░░░░░░░░░░░░ | 15000 | 🔄 43% |
| 📜 Scripts | 634 | ████████████░░░░░░░░ | 1000 | 🔄 63% |
| 👹 Monsters | 132 | ░░░░░░░░░░░░░░░░░░░░ | 5000 | 🔄 3% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 66 | ████░░░░░░░░░░░░░░░░ | 300 | 🔄 22% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last (UTC): 2025-12-17 00:06:25 | Local: 2025-12-17 01:06:25 CET  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `riddler` - ukończono 2025-12-17 01:06
- ✅ `richard` - ukończono 2025-12-17 01:06
- ✅ `rehon` - ukończono 2025-12-17 01:06
- ✅ `red_lilly` - ukończono 2025-12-17 01:06
- ✅ `razan` - ukończono 2025-12-17 01:06
- ✅ `raymond_striker` - ukończono 2025-12-17 01:06
- ✅ `rata_mari` - ukończono 2025-12-17 01:06
- ✅ `rashid` - ukończono 2025-12-17 01:06
- ✅ `rashid_custom` - ukończono 2025-12-17 01:06
- ✅ `rapanaio_isle_of_evil` - ukończono 2025-12-17 01:06

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
