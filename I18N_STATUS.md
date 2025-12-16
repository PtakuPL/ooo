# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 5000, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja:** 2025-12-16 06:49:37 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 54 | **Klucze EN:** 21771  
> **LIVE:** Cykl #1 | Status: 🟢 RUNNING | Faza: MIGRATION | Etap: cycle_end | Kategoria: scripts | Plik: - | ETA: 0 | Heartbeat: 2025-12-16T05:49:36Z

---

## 🤖 AI Agent Integration

```
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n_file_status.json                              │
│  Worker: i18n_worker_simple.sh                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Globalny Postęp

### 📁 Pliki Projektu (pełny skan)
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 📂 **Wszystkie pliki** | **16,506** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **7,830** | 47.4% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **2,403** | **30.7%** | historia workera |
| ⏳ Nie przeskanowane | **5,427** | 69.3% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,469 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 839 | silnik serwera |
| 📋 JSON (.json) | 950 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **82** | 3.4% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **65** | - | bez tekstów |
| 🔧 W trakcie | **0** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **21,771** | wszystkie kategorie |
| 📊 NPC | 5,339 | dialogi NPC |
| 📊 Items | 13,749 | przedmioty |
| 📊 Monsters | 132 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 1,056 | scripts, spells, etc. |

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
| 🔄 Cykl aktualny | **#1** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **134** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 0/54  
- Ostatni sync: -

### 🌍 Etap 2: Tłumaczenia (AUTO + TM)
| Język | TM wpisy | Status |
|-------|----------|--------|
| DE | 0 | ⚠️ placeholdery (brak TM) |
| ES | 0 | ⚠️ placeholdery (brak TM) |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 0 | ⚠️ placeholdery (brak TM) |
| PT | 0 | ⚠️ placeholdery (brak TM) |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 0 | ⚠️ placeholdery (brak TM) |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** de, es, fr, pl, pt, ru, tr

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 5339/15000 (36%) | 15000 |
| 📜 Lua Scripts | 🔄 | 212/1000 (21%) | 1000 |
| 🎒 Items Database | 🔄 | 13749/40000 (34%) | 40000 |
| 👹 Monsters | 🔄 | 132/5000 (3%) | 5000 |
| ✨ Spells & Magic | 🔄 | 304/400 (76%) | 400 |
| ⚙️ Server C++ | ⏳ | 0/300 (0%) | 300 |

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
| 🎮 OTClient Modules | ⏳ | 0/500 (0%) | 500 |
| 📦 OTClient Data | ⏳ | 0/200 (0%) | 200 |
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
| DE | 0 | ⚠️ placeholdery (brak TM) |
| ES | 0 | ⚠️ placeholdery (brak TM) |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 0 | ⚠️ placeholdery (brak TM) |
| PT | 0 | ⚠️ placeholdery (brak TM) |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 0 | ⚠️ placeholdery (brak TM) |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** de, es, fr, pl, pt, ru, tr
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     1 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🔧 MIGRATION (cycle_end)                  │
│ Kategoria: 📁 SCRIPTS                                │
├─────────────────────────────────────────────────────────────────┤
│ Status: running                                               │
│ Plik: -                                                       │
│ Postęp: 0/0 units                                             │
│ Info: cycle end                                               │
├─────────────────────────────────────────────────────────────────┤
│ ❤️ Heartbeat: 2025-12-16T05:49:36Z           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔁 W tym cyklu

- 🔧 MIGRATION.category_done [scripts] ok (keys+79, files+45) — migration finished
- 🔧 MIGRATION.category_done [scripts] ok (keys+10, files+10) — migration finished
- 🔧 MIGRATION.category_done [scripts] ok (keys+0, files+0) — migration finished
- 🔧 MIGRATION.category_done [scripts] ok (keys+2, files+0) — migration finished
- ✅ IDLE.IDLE_SLEEP [-] ok — sleep_seconds=300
- ✅ IDLE.IDLE_CYCLE_DONE [-] ok — idle cycle complete
- 🤖 AUTO_TRANSLATE.AUTO_TRANSLATE_DONE [pl] ok (files+1, translated+0, skipped+3060) — lang=pl file=npc.json
- 🤖 AUTO_TRANSLATE.AUTO_TRANSLATE_DONE [pl] ok (files+1, translated+0, skipped+3060) — lang=pl file=npc.json
- 🌍 TRANSLATION_SYNC.SYNC_FILE_DONE [pl] ok (keys+0, files+0) — lang=pl file=npc.json
- 🔑 COMPACT_KEYS.export_done [-] ok (mapped_new+0) — export compact locales




## 📅 Dziś (UTC)

- Cykle: **13**
- MIGRATION: **+138** kluczy, **61** plików `.lua`
- Kategorie dotknięte: actions, creaturescripts, globalevents, items, monsters, mounts, movements, npc, quests, raids...
- Błędy: **0**


---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **147** | w tej sesji |
| ✅ Plików z kluczami | **82** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **65** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **134** | przez workera w tej sesji |
| 🌍 Języków | **54** | EN + tłumaczenia |
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
<summary>🧙 5. NPC - 🔄 (36%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 5339 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 36% |
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
<summary>📜 7. Quests - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 500 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - 🔄 (21%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 212 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 21% |
| 📁 Plik | i18n/en/scripts.json |

</details>

<details>
<summary>⚙️ 9. Server - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 300 |
| 📊 Postęp | 0% |
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
| npc | 5339 | 0 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| spells | 304 | 0 | 0 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
| scripts | 212 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 0 | ✅ Active |
| monsters | 132 | 0 | 0 | ✅ Active |
| php | 59 | 0 | 0 | ✅ Active |
| startup | 23 | 0 | 0 | ✅ Active |
| libs | 21 | 0 | 0 | ✅ Active |
| modules | 16 | 0 | 0 | ✅ Active |
| example_merchant | 14 | 0 | 0 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| actions | 8 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 0 | ✅ Active |
| events | 5 | 0 | 0 | ✅ Active |
| cpp | 0 | 0 | 0 | ⏳ Empty |
| errors | 0 | 0 | 0 | ⏳ Empty |
| npclib | 0 | 0 | 0 | ⏳ Empty |
| quests | 0 | 0 | 0 | ⏳ Empty |
| server | 0 | 0 | 0 | ⏳ Empty |
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

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
| 🎒 Items | 13749 | ██████░░░░░░░░░░░░░░ | 40000 | 🔄 34% |
| 🧙 NPC | 5339 | ███████░░░░░░░░░░░░░ | 15000 | 🔄 36% |
| 📜 Scripts | 212 | ████░░░░░░░░░░░░░░░░ | 1000 | 🔄 21% |
| 👹 Monsters | 132 | ░░░░░░░░░░░░░░░░░░░░ | 5000 | 🔄 3% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-16 06:49:37  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `mirror` - ukończono 2025-12-16 06:49
- ✅ `actions_formula` - ukończono 2025-12-16 06:49
- ✅ `quara_leader_kill` - ukończono 2025-12-16 06:49
- ✅ `movements_last_fight_teleport` - ukończono 2025-12-16 06:49
- ✅ `movements_quara_vortex` - ukończono 2025-12-16 06:49
- ✅ `creaturescritps_diseased_trio_kill` - ukończono 2025-12-16 06:49
- ✅ `actions_matrix` - ukończono 2025-12-16 06:49
- ✅ `creaturescritps_azerus_kill` - ukończono 2025-12-16 06:49
- ✅ `movements_morik` - ukończono 2025-12-16 06:49
- ✅ `movements_demon_teleport` - ukończono 2025-12-16 06:49

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
