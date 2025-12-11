# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 7500, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300} -->

> **Aktualizacja:** 2025-12-11 03:55:50 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 29136

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

| Metryka | Wartość | Trend |
|---------|---------|-------|
| 📁 Plików przetworzonych | **144** | ↑ |
| ⏭️ Plików wykluczonych | **593** | - |
| 🔑 Kluczy i18n (EN) | **29136** | ↑ |
| 🌍 Języków | **53** | ✓ |
| ⚠️ Konfliktów | **0** | ✓ |
| 🔄 Cykl | **#11** | - |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 0/53  
- Ostatni sync: -

### 🌍 Etap 2: Tłumaczenia (AUTO + TM)
| Język | TM wpisy | Status |
|-------|----------|--------|
| DE | 2196 | ✅ TM |
| ES | 3352 | ✅ TM |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 3856 | ✅ TM |
| PT | 3610 | ✅ TM |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 3611 | ✅ TM |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** fr, tr

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 5339/15000 (36%) | 15000 |
| 📜 Lua Scripts | 🔄 | 387/1000 (39%) | 1000 |
| 🎒 Items Database | 🔄 | 13749/40000 (34%) | 40000 |
| 👹 Monsters | ✅ | 7341/7500 (98%) | 7500 |
| ✨ Spells & Magic | 🔄 | 304/400 (76%) | 400 |
| ⚙️ Server C++ | ⏳ | 0/300 (0%) | 300 |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | 🔄 | 54/3000 (2%) | 3000 |
| 📄 HTML Views | ✅ | 1495/300 (498%) | 300 |
| 📦 JavaScript | 🔄 | 236/300 (79%) | 300 |

### ⏳ Faza 3: 📱 Instalka/Klient

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | ⏳ | 0/200 (0%) | 200 |
| 💿 Installer/C++ | ⏳ | 0/500 (0%) | 500 |

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
| DE | 2196 | ✅ TM |
| ES | 3352 | ✅ TM |
| FR | 0 | ⚠️ placeholdery (brak TM) |
| IT | 0 | ⚠️ placeholdery (brak TM) |
| PL | 3856 | ✅ TM |
| PT | 3610 | ✅ TM |
| RO | 0 | ⚠️ placeholdery (brak TM) |
| RU | 3611 | ✅ TM |
| SV | 0 | ⚠️ placeholdery (brak TM) |
| TR | 0 | ⚠️ placeholdery (brak TM) |

**Języki bez TM (AUTO → placeholdery):** fr, tr
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #    11 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    ✅ IDLE                                   │
│ Tryb:      MIGRATION (multi-category)               │
│ Kategoria: 🎒 MODULES                                │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Ostatnia aktywność: modules                                        │
│ [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ 16/1000 kluczy (2%)                                          │
├─────────────────────────────────────────────────────────────────┤
│ ⏳ Total processed: 182 operacji               │
│ 🌍 Języki zsync: 0/53                                │
│ 📅 Ostatnia aktualizacja: 2025-12-11 03:55:50                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Operacji wykonanych | **182** | we wszystkich kategoriach |
| ✅ NPC zmigrowanych | **144** (318 z i18nKey) | z 1026 plików NPC |
| 🔑 Kluczy wyciągniętych | **29136** | we wszystkich kategoriach |
| 🌍 Języków zsynchronizowanych | **0**/53 | brak |
| 🔄 Cykli wykonanych | **#11** | continuous mode |
| 🎯 Aktywne kategorie | **15** | z danymi |
| ❌ Błędów krytycznych | **0** | ✓ wszystko OK |

---

## 📜 Historia ostatnich operacji

- ⚡ `modules` +0 kluczy @ 03:55:50
- ⚡ `chatchannels` +0 kluczy @ 03:55:43
- ⚡ `events` +0 kluczy @ 03:55:34
- ⚡ `libs` +0 kluczy @ 03:55:22
- 🎒 `items` +0 kluczy @ 03:55:09
- ⚡ `spells` +0 kluczy @ 03:55:01
- ⚡ `world` +0 kluczy @ 03:54:53
- ⚡ `raids` +0 kluczy @ 03:54:45


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
| ✅ Zmigrowanych | 318 |
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
<summary>📜 7. Quests - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 500 |
| 📊 Postęp | 0% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - 🔄 (39%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 387 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 39% |
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
| items | 13749 | 0 | 2 | ⏭️ Skip 9m |
| monsters | 7341 | 0 | 2 | ⏭️ Skip 8m |
| npc | 5339 | 100 | 0 | ✅ Active |
| html | 1495 | 0 | 0 | ✅ Active |
| scripts | 387 | 82 | 0 | ✅ Active |
| spells | 304 | 0 | 2 | ⏭️ Skip 9m |
| client | 236 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 2 | ⏭️ Skip 8m |
| php | 54 | 0 | 0 | ✅ Active |
| startup | 23 | 0 | 0 | ✅ Active |
| libs | 21 | 0 | 2 | ⏭️ Skip 9m |
| modules | 16 | 0 | 2 | ⏭️ Skip 9m |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 2 | ⏭️ Skip 9m |
| events | 5 | 0 | 2 | ⏭️ Skip 9m |
| actions | 0 | 0 | 0 | ⏳ Empty |
| cpp | 0 | 0 | 0 | ⏳ Empty |
| errors | 0 | 0 | 0 | ⏳ Empty |
| npclib | 0 | 0 | 0 | ⏳ Empty |
| quests | 0 | 0 | 0 | ⏳ Empty |
| server | 0 | 0 | 0 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 2 | ⏭️ Skip 9m |

---

## 🤖 Worker Category State

| Kategoria | Skip pozostało | Seria zer | Powód |
|-----------|----------------|-----------|-------|
| monsters | 8m | 2x | Progresywny backoff |
| raids | 8m | 2x | Progresywny backoff |
| world | 9m | 2x | Progresywny backoff |
| spells | 9m | 2x | Progresywny backoff |
| items | 9m | 2x | Progresywny backoff |
| libs | 9m | 2x | Progresywny backoff |
| events | 9m | 2x | Progresywny backoff |
| chatchannels | 9m | 2x | Progresywny backoff |
| modules | 9m | 2x | Progresywny backoff |

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #11 |
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
| 📜 Scripts | 387 | ███████░░░░░░░░░░░░░ | 1000 | 🔄 39% |
| 👹 Monsters | 7341 | ███████████████████░ | 7500 | ✅ 98% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-11 03:55:50  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `ghorza` - ukończono 2025-12-11 03:53
- ✅ `gamel` - ukończono 2025-12-11 03:53
- ✅ `galuna` - ukończono 2025-12-11 03:53
- ✅ `frederik` - ukończono 2025-12-11 03:53
- ✅ `frans` - ukończono 2025-12-11 03:53
- ✅ `florentine` - ukończono 2025-12-11 03:53
- ✅ `finarfin` - ukończono 2025-12-11 03:53
- ✅ `ferks` - ukończono 2025-12-11 03:53
- ✅ `fenech` - ukończono 2025-12-11 03:53
- ✅ `feizuhl` - ukończono 2025-12-11 03:53

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
