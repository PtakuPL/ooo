# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 7500, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja:** 2025-12-11 22:19:00 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 28857

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
| 📂 **Wszystkie pliki** | **16,208** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **7,742** | 47.8% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **121** | **1.6%** | historia workera |
| ⏳ Nie przeskanowane | **7,621** | 98.4% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,409 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 825 | silnik serwera |
| 📋 JSON (.json) | 942 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **0** | 0.0% | mają klucze i18n |
| 🔄 Wymaga migracji | **20** | - | trzeba dodać i18n |
| ⚪ Czyste | **0** | - | bez tekstów |
| 🔧 W trakcie | **0** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **28,857** | wszystkie kategorie |
| 📊 NPC | 5,339 | dialogi NPC |
| 📊 Items | 13,749 | przedmioty |
| 📊 Monsters | 7,341 | potwory |
| 📊 HTML | 1,495 | widoki web |
| 📊 Pozostałe | 933 | scripts, spells, etc. |

### 🌍 Języki i Tłumaczenia
| Metryka | Wartość | Procent | Info |
|---------|---------|---------|------|
| 🌐 Wszystkie języki | **53** | 100% | foldery w i18n/ |
| 📋 Przygotowane | **52** | 98% | mają pliki [EN] |
| ✅ **Przetłumaczone** | **52** | **98.1%** | prawdziwe tłumaczenia |
| ⏳ Do tłumaczenia | **0** | - | tylko placeholdery |

### 📈 Statystyki Pracy
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔄 Cykl aktualny | **#3** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **0** | w tej sesji |
| ⚠️ Konfliktów | **0** | merge conflicts |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 0/53  
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
| 📜 Lua Scripts | 🔄 | 97/1000 (10%) | 1000 |
| 🎒 Items Database | 🔄 | 13749/40000 (34%) | 40000 |
| 👹 Monsters | ✅ | 7341/7500 (98%) | 7500 |
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
- Języki z plikami przygotowanymi: 0/53
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
│ 🔴 LIVE: Worker v2.0                          Cykl #     3 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🔧 MIGRATION (skanowanie plików)          │
│ Kategoria: 📁 ACTIONS                                │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Pliki przeskanowane:     20 (wszystkie kategorie)          │
│    ├─ Kategoria ACTIONS:      0 kluczy EN                    │
│    └─ Total kluczy EN:  28857                                 │
├─────────────────────────────────────────────────────────────────┤
│ 📅 Ostatnia aktualizacja: 2025-12-11 22:19:00            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **20** | w tej sesji |
| ✅ Plików z kluczami | **0** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **20** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **0** | przez workera w tej sesji |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#3** | continuous mode |

---

## 📜 Historia ostatnich operacji

- ⚡ `actions` +0 kluczy @ 22:18:58
- 👹 `monsters` +0 kluczy @ 22:18:48
- 📜 `scripts` +0 kluczy @ 22:18:35
- 🧙 `npc` +0 kluczy @ 22:15:45
- ⚡ `errors` +0 kluczy @ 17:41:10
- ⚡ `otclient_tools` +0 kluczy @ 17:41:03
- ⚡ `otclient_src` +0 kluczy @ 17:22:35
- ⚡ `otclient_data` +0 kluczy @ 17:22:22


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
<summary>👹 4. Monsters - ✅ (98%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 7341 |
| 🎯 Cel | 7500 |
| 📊 Postęp | 98% |
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
| 📁 Plików NPC | 1026 |
| ✅ Zmigrowanych | 677 |
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
<summary>📜 8. Scripts - 🔄 (10%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 97 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 10% |
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
| items | 13749 | 0 | 2 | ✅ Active |
| monsters | 7341 | 0 | 4 | ⏭️ Skip 59m |
| npc | 5339 | 13620 | 2 | ⏭️ Skip 6m |
| html | 1495 | 0 | 2 | ✅ Active |
| spells | 304 | 0 | 2 | ✅ Active |
| client | 242 | 0 | 2 | ✅ Active |
| raids | 147 | 0 | 2 | ✅ Active |
| scripts | 97 | 273 | 2 | ⏭️ Skip 9m |
| php | 59 | 15 | 0 | ✅ Active |
| startup | 23 | 0 | 2 | ✅ Active |
| libs | 21 | 0 | 2 | ✅ Active |
| modules | 16 | 0 | 2 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 2 | ✅ Active |
| events | 5 | 0 | 2 | ✅ Active |
| actions | 0 | 0 | 4 | ⏭️ Skip 59m |
| cpp | 0 | 0 | 2 | ⏳ Empty |
| errors | 0 | 0 | 2 | ⏳ Empty |
| npclib | 0 | 0 | 2 | ⏳ Empty |
| quests | 0 | 0 | 2 | ⏳ Empty |
| server | 0 | 0 | 2 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 2 | ⏳ Empty |

---

## 🤖 Worker Category State

| Kategoria | Skip pozostało | Seria zer | Powód |
|-----------|----------------|-----------|-------|
| monsters | 59m | 4x | Progresywny backoff |
| actions | 59m | 4x | Progresywny backoff |
| npc | 6m | 2x | Progresywny backoff |
| scripts | 9m | 2x | Progresywny backoff |

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #3 |
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
| 📜 Scripts | 97 | █░░░░░░░░░░░░░░░░░░░ | 1000 | 🔄 10% |
| 👹 Monsters | 7341 | ███████████████████░ | 7500 | ✅ 98% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-11 22:19:00  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `gnomegica` - ukończono 2025-12-11 22:14
- ✅ `ghorza` - ukończono 2025-12-11 22:14
- ✅ `frederik` - ukończono 2025-12-11 22:14
- ✅ `frans` - ukończono 2025-12-11 22:14
- ✅ `cranky_lizard_crone` - ukończono 2025-12-11 22:14
- ✅ `chuckles` - ukończono 2025-12-11 22:14
- ✅ `bertram` - ukończono 2025-12-11 22:14
- ✅ `battlemart` - ukończono 2025-12-11 22:14
- ✅ `alaistar` - ukończono 2025-12-11 22:14
- ✅ `the_lootmonger` - ukończono 2025-12-11 22:14

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
