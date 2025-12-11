# 🌍 I18N Internationalization System - Live Dashboard

> **Aktualizacja:** 2025-12-11 02:36:05 UTC  
> **Worker:** i18n_worker_simple.sh (auto) | **Guardian:** aktywny | **Języki:** 53 | **Klucze EN:** 28 967

---

## 🔀 Podział: Przygotowanie vs Tłumaczenia

### 📦 Przygotowanie (ekstrakcja/migracja)
| Kategoria | Klucze EN | Stan |
|-----------|-----------|------|
| NPC | 5334 | ✅ |
| Scripts | 385 | ✅ |
| Monsters | 7341 | ✅ |
| Items | 13749 | ✅ |
| Spells | 65 | ✅ |
| Raids | 147 | ✅ |
| World/Modules/Libs/Events/Chatchannels/Startup | 16–1495 | ✅ |
| PHP (html_copy) | 31 | ✅ (cache/twig wykluczone) |
| Client (OTClient) | 236 | ✅ |

### 🌍 Tłumaczenia (AUTO_TRANSLATE + SYNC)
| Język | Tryb | Limit | Uwagi |
|-------|------|-------|-------|
| PL | AUTO + SYNC | 10/cykl | tłumaczy realnie |
| RU | AUTO + SYNC | 10/cykl | ~2100 realnych tłumaczeń |
| TR | AUTO + SYNC | 10/cykl | brak słownika → placeholdery |
| Pozostałe 50 | SYNC | - | wyrównane do EN |

> AUTO używa `translation_memory.json`; brak TM/słownika dla TR powoduje placeholdery `[TR] ...`. Jeśli dostarczymy glossary EN→TR, AUTO zacznie wypełniać realne tłumaczenia.

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | 🔄 | 5253/15000 (35%) | 15000 |
| 📜 Lua Scripts | 🔄 | 368/1000 (37%) | 1000 |
| 🎒 Items Database | ⏳ | 0/40000 (0%) | 40000 |
| 👹 Monsters | 🔄 | 4108/5000 (82%) | 5000 |
| ✨ Spells & Magic | ⏳ | 0/200 (0%) | 200 |
| ⚙️ Server C++ | ⏳ | 0/300 (0%) | 300 |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | 🔄 | 8/3000 (0%) | 3000 |
| 📄 HTML Views | 🔄 | 39/300 (13%) | 300 |
| 📦 JavaScript | ⏳ | 0/200 (0%) | 200 |

### ⏳ Faza 3: 📱 Instalka/Klient

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | ⏳ | 0/200 (0%) | 200 |
| 💿 Installer/C++ | 🔄 | 15/500 (3%) | 500 |

### ⏳ Faza 4: 🌍 Tłumaczenia

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🇵🇱 Polski | 🔄 | 1/1 | 1 |
| 🇩🇪 Niemiecki | 🔄 | 1/1 | 1 |
| 🇪🇸 Hiszpański | 🔄 | 1/1 | 1 |
| 🌐 Pozostałe (50) | ⏳ | 53/53 (100%) | 53 |

---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #    27 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    ✅ IDLE                                   │
│ Tryb:      MIGRATION (8 etapów)                     │
│ Kategoria: 🧙 NPC Dialogs                            │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Postęp migracji NPC:                                        │
│ [██████████████████████████████████████████████████] │
│ 318/318 plików (100%)                                          │
├─────────────────────────────────────────────────────────────────┤
│ ⏳ Pozostało: 0 plików NPC                              │
│ 🕐 ETA: ~0min 0s (przy 4s/plik)                             │
│ 📅 Ostatnia aktualizacja: 2025-12-10 19:38:15                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przetworzonych | **26** | z i18n_file_status.json |
| ✅ NPC zmigrowanych | **26** (318 z i18nKey) | z 1026 plików NPC |
| 🔑 Kluczy wyciągniętych | **9810** | we wszystkich kategoriach |
| 🌍 Języków z danymi | **53**/53 | ar, az, bg, bn, bs... |
| 🔄 Cykli wykonanych | **#27** | continuous mode |
| ⚠️ Plików do migracji | **0** | NPC z StdModule.say |
| ❌ Błędów krytycznych | **0** | ✓ wszystko OK |

---

## 📜 Historia ostatnich operacji

- ✅ `ser_tybald` - ukończono 2025-12-10 15:04
- ✅ `menesto` - ukończono 2025-12-10 15:04
- ✅ `garamond` - ukończono 2025-12-10 15:04
- ✅ `cranky_lizard_crone` - ukończono 2025-12-10 15:04
- ✅ `bertram` - ukończono 2025-12-10 15:04

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
<summary>🎒 2. Items - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 40000 |
| 📊 Postęp | 0% |
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
<summary>👹 4. Monsters - 🔄 (82%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 4108 |
| 🎯 Cel | 5000 |
| 📊 Postęp | 82% |
| 📁 Plik | i18n/en/monsters.json |

</details>

<details>
<summary>🧙 5. NPC - 🔄 (35%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 5253 |
| 🎯 Cel | 15000 |
| 📊 Postęp | 35% |
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
<summary>📜 8. Scripts - 🔄 (37%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 368 |
| 🎯 Cel | 1000 |
| 📊 Postęp | 37% |
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
<summary>✨ 10. Spells - ⏳ (0%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | 0 |
| 🎯 Cel | 200 |
| 📊 Postęp | 0% |
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

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #27 |
| Guardian v2.0 | 🟢 ACTIVE | Push co 2 min |

---

## 🗺️ Roadmap

```
[⏳] Items (0)      ░░░░░░░░░░░░░░░░░░░░  0%
[🔄] NPC (5253)            ███████░░░░░░░░░░░░░  35%
[🔄] Scripts (368)      ███████░░░░░░░░░░░░░  37%
[🔄] Monsters (4108)    ████████████████░░░░  82%
[⏳] Spells (0)       ░░░░░░░░░░░░░░░░░░░░  0%
[⏳] Server (0)       ░░░░░░░░░░░░░░░░░░░░  0%
[⏳] System (0)       ░░░░░░░░░░░░░░░░░░░░  0%
[⏳] UI (0)             ░░░░░░░░░░░░░░░░░░░░  0%
```

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-10 19:38:15  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `jack` - ukończono 2025-12-11 03:39
- ✅ `iwan` - ukończono 2025-12-11 03:39
- ✅ `imbuement_assistant` - ukończono 2025-12-11 03:39
- ✅ `hoggle` - ukończono 2025-12-11 03:39
- ✅ `gundralph` - ukończono 2025-12-11 03:39
- ✅ `guard_saros` - ukończono 2025-12-11 03:39
- ✅ `gnomillion` - ukończono 2025-12-11 03:39
- ✅ `gamel` - ukończono 2025-12-11 03:39
- ✅ `galuna` - ukończono 2025-12-11 03:39
- ✅ `florentine` - ukończono 2025-12-11 03:39
- ✅ `finarfin` - ukończono 2025-12-11 03:39
- ✅ `ferks` - ukończono 2025-12-11 03:39
- ✅ `fenech` - ukończono 2025-12-11 03:39
- ✅ `feizuhl` - ukończono 2025-12-11 03:39
- ✅ `faloriel` - ukończono 2025-12-11 03:39
- ✅ `eva` - ukończono 2025-12-11 03:39
- ✅ `eshaya` - ukończono 2025-12-11 03:39
- ✅ `emael` - ukończono 2025-12-11 03:39
- ✅ `elyen_ravenlock` - ukończono 2025-12-11 03:39
- ✅ `elgar` - ukończono 2025-12-11 03:39
- ✅ `eighty` - ukończono 2025-12-11 03:39
- ✅ `eclesius` - ukończono 2025-12-11 03:39
- ✅ `ebenizer` - ukończono 2025-12-11 03:39
- ✅ `cruleo` - ukończono 2025-12-11 03:39
- ✅ `cledwyn` - ukończono 2025-12-11 03:38
- ✅ `chester_kahs` - ukończono 2025-12-11 03:38
- ✅ `carlos` - ukończono 2025-12-11 03:38
- ✅ `cael` - ukończono 2025-12-11 03:38
- ✅ `busty_bonecrusher` - ukończono 2025-12-11 03:38
- ✅ `bo_ques` - ukończono 2025-12-11 03:38
- ✅ `benjamin` - ukończono 2025-12-11 03:38
- ✅ `benevola` - ukończono 2025-12-11 03:38
- ✅ `beatrice` - ukończono 2025-12-11 03:38
- ✅ `baxter` - ukończono 2025-12-11 03:38
- ✅ `atur` - ukończono 2025-12-11 03:38
- ✅ `asralius` - ukończono 2025-12-11 03:38
- ✅ `ashtamor` - ukończono 2025-12-11 03:38
- ✅ `aruda` - ukończono 2025-12-11 03:38
- ✅ `arkarra` - ukończono 2025-12-11 03:38
- ✅ `arito` - ukończono 2025-12-11 03:38
- ✅ `ariella` - ukończono 2025-12-11 03:38
- ✅ `an_orc_guard` - ukończono 2025-12-11 03:38
- ✅ `an_old_dragon_lord` - ukończono 2025-12-11 03:38
- ✅ `ambassador_of_rathleton` - ukończono 2025-12-11 03:38
- ✅ `a_dead_bureaucrat4` - ukończono 2025-12-11 03:38
- ✅ `a_dead_bureaucrat3` - ukończono 2025-12-11 03:38
- ✅ `a_dead_bureaucrat2` - ukończono 2025-12-11 03:38
- ✅ `a_dead_bureaucrat1` - ukończono 2025-12-11 03:38
- ✅ `shiriel` - ukończono 2025-12-10 21:24
- ✅ `seymour` - ukończono 2025-12-10 21:24
- ✅ `romir` - ukończono 2025-12-10 21:24
- ✅ `rock_in_a_hard_place` - ukończono 2025-12-10 21:13
- ✅ `nipuna` - ukończono 2025-12-10 21:13
- ✅ `nelly` - ukończono 2025-12-10 21:12
- ✅ `mordecai` - ukończono 2025-12-10 20:46
- ✅ `gnomegica` - ukończono 2025-12-10 20:45
- ✅ `ghorza` - ukończono 2025-12-10 20:45
- ✅ `frederik` - ukończono 2025-12-10 20:45
- ✅ `frans` - ukończono 2025-12-10 20:45
- ✅ `chuckles` - ukończono 2025-12-10 20:45
- ✅ `battlemart` - ukończono 2025-12-10 20:41
- ✅ `alaistar` - ukończono 2025-12-10 20:41
- ✅ `ser_tybald` - ukończono 2025-12-10 15:04
- ✅ `menesto` - ukończono 2025-12-10 15:04
- ✅ `garamond` - ukończono 2025-12-10 15:04
- ✅ `cranky_lizard_crone` - ukończono 2025-12-10 15:04
- ✅ `bertram` - ukończono 2025-12-10 15:04
- ✅ `canary` - ukończono 2025-12-10 15:01
- ✅ `the_lootmonger` - ukończono 2025-12-10 14:55
- ✅ `tandros` - ukończono 2025-12-10 14:55
- ✅ `sundara` - ukończono 2025-12-10 14:55
- ✅ `sigurd` - ukończono 2025-12-10 14:55

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
