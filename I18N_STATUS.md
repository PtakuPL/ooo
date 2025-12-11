# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 7500, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300} -->

> **Aktualizacja:** 2025-12-11 03:45:11 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 29134

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
| 🔑 Kluczy i18n (EN) | **29134** | ↑ |
| 🌍 Języków | **53** | ✓ |
| ⚠️ Konfliktów | **0** | ✓ |
| 🔄 Cykl | **#2** | - |

---

## 🔀 Etap 1 vs Etap 2

### 📦 Etap 1: Przygotowanie (SYNC kluczy EN → pliki językowe)
- Języki z plikami przygotowanymi: 52/53  
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

**Języki bez TM (AUTO → placeholdery):** ar, az, bg, bn, bs, cs, da, el...

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 5339/15000 (36%) | 15000 |
| 📜 Lua Scripts | 🔄 | 385/1000 (38%) | 1000 |
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
| 🇩🇪 Niemiecki | ✅ Sync | 28867 | [EN] prefix |
| 🇵🇱 Polski | ✅ Sync | 28967 | [EN] prefix |
| 🇪🇸 Hiszpański | ✅ Sync | 29017 | [EN] prefix |
| 🇫🇷 Francuski | ✅ Sync | 28867 | [EN] prefix |
| 🌐 Pozostałe (32/53) | ⏳ | 924476 | nie rozpoczęto |

### 📦 Etap 1: Przygotowanie (SYNC)
- Języki z plikami przygotowanymi: 52/53
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

**Języki bez TM (AUTO → placeholdery):** ar, az, bg, bn, bs, cs, da, el...
---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #     2 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    ✅ IDLE                                   │
│ Tryb:      MIGRATION (multi-category)               │
│ Kategoria: 🎒 CPP                                    │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Ostatnia aktywność: cpp                                            │
│ [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│ 0/500 kluczy (0%)                                          │
├─────────────────────────────────────────────────────────────────┤
│ ⏳ Total processed: 498 operacji               │
│ 🌍 Języki zsync: 32/53                                │
│ 📅 Ostatnia aktualizacja: 2025-12-11 03:45:11                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Operacji wykonanych | **498** | we wszystkich kategoriach |
| ✅ NPC zmigrowanych | **144** (318 z i18nKey) | z 1026 plików NPC |
| 🔑 Kluczy wyciągniętych | **29134** | we wszystkich kategoriach |
| 🌍 Języków zsynchronizowanych | **32**/53 | sv, hu, bs, ro, az... |
| 🔄 Cykli wykonanych | **#2** | continuous mode |
| 🎯 Aktywne kategorie | **15** | z danymi |
| ❌ Błędów krytycznych | **0** | ✓ wszystko OK |

---

## 📜 Historia ostatnich operacji

- ⚡ `cpp` +0 kluczy @ 03:45:10
- ⚡ `html` +0 kluczy @ 03:45:02
- ⚡ `php` +0 kluczy @ 03:44:55
- ⚡ `npclib` +0 kluczy @ 03:44:46
- ⚡ `startup` +0 kluczy @ 03:44:31
- ⚡ `modules` +0 kluczy @ 03:44:22
- ⚡ `chatchannels` +0 kluczy @ 03:44:13
- ⚡ `events` +0 kluczy @ 03:44:05


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
<summary>📜 8. Scripts - 🔄 (38%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 385 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 38% |
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
| items | 13749 | 0 | 2 | ⏭️ Skip 8m |
| monsters | 7341 | 0 | 2 | ⏭️ Skip 7m |
| npc | 5339 | 162 | 0 | ✅ Active |
| html | 1495 | 0 | 2 | ⏭️ Skip 9m |
| scripts | 385 | 0 | 2 | ⏭️ Skip 7m |
| spells | 304 | 294 | 0 | ✅ Active |
| client | 236 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 2 | ⏭️ Skip 7m |
| php | 54 | 42 | 2 | ⏭️ Skip 9m |
| startup | 23 | 0 | 2 | ⏭️ Skip 9m |
| libs | 21 | 0 | 2 | ⏭️ Skip 8m |
| modules | 16 | 0 | 2 | ⏭️ Skip 9m |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 2 | ⏭️ Skip 9m |
| events | 5 | 0 | 2 | ⏭️ Skip 8m |
| actions | 0 | 0 | 0 | ⏳ Empty |
| cpp | 0 | 0 | 2 | ⏭️ Skip 9m |
| errors | 0 | 0 | 0 | ⏳ Empty |
| npclib | 0 | 0 | 2 | ⏭️ Skip 9m |
| quests | 0 | 0 | 0 | ⏳ Empty |
| server | 0 | 0 | 0 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 2 | ⏭️ Skip 7m |

---

## 🤖 Worker Category State

| Kategoria | Skip pozostało | Seria zer | Powód |
|-----------|----------------|-----------|-------|
| scripts | 7m | 2x | Progresywny backoff |
| monsters | 7m | 2x | Progresywny backoff |
| raids | 7m | 2x | Progresywny backoff |
| world | 7m | 2x | Progresywny backoff |
| items | 8m | 2x | Progresywny backoff |
| libs | 8m | 2x | Progresywny backoff |
| events | 8m | 2x | Progresywny backoff |
| chatchannels | 9m | 2x | Progresywny backoff |
| modules | 9m | 2x | Progresywny backoff |
| startup | 9m | 2x | Progresywny backoff |
| npclib | 9m | 2x | Progresywny backoff |
| php | 9m | 2x | Progresywny backoff |
| html | 9m | 2x | Progresywny backoff |
| cpp | 9m | 2x | Progresywny backoff |

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #2 |
| Guardian v2.0 | 🟢 ACTIVE | Push co 2 min |

---

## 🌍 Tłumaczenia - Etap 1: Synchronizacja Kluczy

| Język | Kluczy | Status |
|-------|--------|--------|
| DE | 28,867 | ✅ |
| PL | 28,967 | ✅ |
| ES | 29,017 | ✅ |
| PT | 29,017 | ✅ |
| FR | 28,867 | ✅ |
| IT | 28,867 | ✅ |
| NL | 28,867 | ✅ |
| CS | 28,867 | ✅ |
| SK | 28,867 | ✅ |
| HU | 28,867 | ✅ |

> **Aktualnie:** IDLE / -  
> **Ukończone języki:** 32/53  
> **Prefix:** `[EN] ` (klucze do przetłumaczenia)


---

## 🗺️ Roadmap

| Kategoria | Kluczy | Postęp | Cel | Status |
|-----------|--------|--------|-----|--------|
| 🎒 Items | 13749 | ██████░░░░░░░░░░░░░░ | 40000 | 🔄 34% |
| 🧙 NPC | 5339 | ███████░░░░░░░░░░░░░ | 15000 | 🔄 36% |
| 📜 Scripts | 385 | ███████░░░░░░░░░░░░░ | 1000 | 🔄 38% |
| 👹 Monsters | 7341 | ███████████████████░ | 7500 | ✅ 98% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-11 03:45:11  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `znozel` - ukończono 2025-12-11 03:41
- ✅ `zirella` - ukończono 2025-12-11 03:41
- ✅ `zethra` - ukończono 2025-12-11 03:41
- ✅ `zebron` - ukończono 2025-12-11 03:41
- ✅ `yana` - ukończono 2025-12-11 03:41
- ✅ `wyrdin` - ukończono 2025-12-11 03:41
- ✅ `willard` - ukończono 2025-12-11 03:41
- ✅ `virgil` - ukończono 2025-12-11 03:41
- ✅ `vera` - ukończono 2025-12-11 03:41
- ✅ `valindara` - ukończono 2025-12-11 03:41

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
