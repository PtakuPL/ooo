# 🌍 I18N Internationalization System - Live Dashboard

<!-- TARGETS {'game': 100, 'items': 40000, 'misc': 100, 'monsters': 5000, 'npc': 15000, 'player': 200, 'quests': 500, 'scripts': 1000, 'server': 300, 'spells': 400, 'system': 2000, 'ui': 200, 'php': 3000, 'cpp': 500, 'html': 1500, 'client': 300, 'otclient_modules': 500, 'otclient_data': 200, 'otclient_src': 300, 'otclient_mods': 100, 'otclient_tools': 50} -->

> **Aktualizacja:** 2025-12-12 06:06:57 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 53 | **Klucze EN:** 21648

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
| 📂 **Wszystkie pliki** | **16,230** | 100% | cały projekt |
| 📜 Do skanowania (kod) | **7,749** | 47.7% | pliki z kodem/tekstami |
| 🔍 **Przeskanowane** | **2,284** | **29.5%** | historia workera |
| ⏳ Nie przeskanowane | **5,465** | 70.5% | czekają na skan |

### 📊 Podział plików do skanowania
| Typ | Ilość | Info |
|-----|-------|------|
| 📜 Lua (.lua) | 5,413 | NPC, scripts, libs |
| 📄 XML (.xml) | 131 | items, monsters, spells |
| 🐘 PHP (.php) | 2 | backend AAC |
| 🌐 HTML (.html) | 6 | widoki |
| 📦 JavaScript (.js) | 0 | frontend |
| ⚙️ C++ (.cpp/.hpp/.h) | 825 | silnik serwera |
| 📋 JSON (.json) | 944 | konfiguracje |

### ✅ Status Migracji
| Status | Ilość | Procent | Opis |
|--------|-------|---------|------|
| ✅ Zmigrowane | **19** | 0.8% | mają klucze i18n |
| 🔄 Wymaga migracji | **0** | - | trzeba dodać i18n |
| ⚪ Czyste | **20** | - | bez tekstów |
| 🔧 W trakcie | **0** | - | obecnie przetwarzane |

### 🔑 Klucze i18n
| Metryka | Wartość | Info |
|---------|---------|------|
| 🔑 **Klucze EN (źródłowe)** | **21,648** | wszystkie kategorie |
| 📊 NPC | 5,339 | dialogi NPC |
| 📊 Items | 13,749 | przedmioty |
| 📊 Monsters | 132 | potwory |
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
| 🔄 Cykl aktualny | **#363** | od uruchomienia |
| 🔑 Kluczy wyekstrahowanych | **19** | w tej sesji |
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
│ 🔴 LIVE: Worker v2.0                          Cykl #   363 │
├─────────────────────────────────────────────────────────────────┤
│ Status:    🟢 RUNNING                                │
│ Tryb:      🔧 MIGRATION (skanowanie plików)          │
│ Kategoria: 📁 ERRORS                                 │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Pliki przeskanowane:     39 (wszystkie kategorie)          │
│    ├─ Kategoria ERRORS:      0 kluczy EN                    │
│    └─ Total kluczy EN:  21648                                 │
├─────────────────────────────────────────────────────────────────┤
│ 📅 Ostatnia aktualizacja: 2025-12-12 06:06:57            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przeskanowanych | **39** | w tej sesji |
| ✅ Plików z kluczami | **19** | zawierały hardcoded strings |
| ⬜ Plików bez kluczy | **20** | czyste (brak hardcoded) |
| 🔑 Kluczy wyciągniętych | **19** | przez workera w tej sesji |
| 🌍 Języków | **53** | EN + tłumaczenia |
| 🔄 Cykli wykonanych | **#363** | continuous mode |

---

## 📜 Historia ostatnich operacji

- ⚡ `errors` +0 kluczy @ 06:06:55
- ⚡ `otclient_tools` +0 kluczy @ 06:06:52
- ⚡ `otclient_data` +0 kluczy @ 06:06:47
- ⚡ `otclient_modules` +0 kluczy @ 06:06:43
- ⚡ `html` +0 kluczy @ 06:06:42
- ⚡ `php` +0 kluczy @ 06:06:36
- ⚡ `dataroot` +0 kluczy @ 06:06:20
- ⚡ `npclib` +0 kluczy @ 06:06:12


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
| items | 13749 | 0 | 12 | ⏭️ Skip 118m |
| npc | 5339 | 0 | 19 | ⏭️ Skip 108m |
| html | 1495 | 0 | 14 | ⏭️ Skip 119m |
| spells | 304 | 0 | 2 | ✅ Active |
| client | 242 | 0 | 0 | ✅ Active |
| raids | 147 | 0 | 14 | ⏭️ Skip 118m |
| monsters | 132 | 349888 | 6 | ⏭️ Skip 68m |
| scripts | 97 | 0 | 24 | ⏭️ Skip 111m |
| php | 59 | 0 | 18 | ⏭️ Skip 119m |
| startup | 23 | 0 | 14 | ⏭️ Skip 119m |
| libs | 21 | 0 | 11 | ⏭️ Skip 118m |
| modules | 16 | 0 | 11 | ⏭️ Skip 119m |
| example_merchant | 14 | 0 | 0 | ✅ Active |
| messages | 11 | 0 | 0 | ✅ Active |
| chatchannels | 8 | 0 | 12 | ⏭️ Skip 118m |
| events | 5 | 0 | 10 | ⏭️ Skip 118m |
| actions | 0 | 0 | 10 | ⏭️ Skip 117m |
| cpp | 0 | 0 | 2 | ⏳ Empty |
| errors | 0 | 0 | 14 | ⏭️ Skip 119m |
| npclib | 0 | 0 | 14 | ⏭️ Skip 119m |
| quests | 0 | 0 | 13 | ⏭️ Skip 117m |
| server | 0 | 0 | 2 | ⏳ Empty |
| ui | 0 | 0 | 0 | ⏳ Empty |
| world | 0 | 0 | 12 | ⏭️ Skip 118m |

---

## 🤖 Worker Category State

| Kategoria | Skip pozostało | Seria zer | Powód |
|-----------|----------------|-----------|-------|
| npc | 108m | 19x | Progresywny backoff |
| scripts | 111m | 24x | Progresywny backoff |
| actions | 117m | 10x | Progresywny backoff |
| quests | 117m | 13x | Progresywny backoff |
| raids | 118m | 14x | Progresywny backoff |
| world | 118m | 12x | Progresywny backoff |
| talkactions | 118m | 15x | Progresywny backoff |
| movements | 118m | 12x | Progresywny backoff |
| creaturescripts | 118m | 10x | Progresywny backoff |
| globalevents | 118m | 12x | Progresywny backoff |
| items | 118m | 12x | Progresywny backoff |
| libs | 118m | 11x | Progresywny backoff |
| events | 118m | 10x | Progresywny backoff |
| chatchannels | 118m | 12x | Progresywny backoff |
| modules | 119m | 11x | Progresywny backoff |
| startup | 119m | 14x | Progresywny backoff |
| npclib | 119m | 14x | Progresywny backoff |
| dataroot | 119m | 11x | Progresywny backoff |
| php | 119m | 18x | Progresywny backoff |
| html | 119m | 14x | Progresywny backoff |
| otclient_modules | 119m | 12x | Progresywny backoff |
| otclient_data | 119m | 12x | Progresywny backoff |
| otclient_tools | 119m | 12x | Progresywny backoff |
| errors | 119m | 14x | Progresywny backoff |
| monsters | 68m | 6x | Progresywny backoff |
| mounts | 34m | 5x | Progresywny backoff |

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #363 |
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
| 👹 Monsters | 132 | ░░░░░░░░░░░░░░░░░░░░ | 5000 | 🔄 3% |
| ✨ Spells | 304 | ███████████████░░░░░ | 400 | 🔄 76% |
| ⚙️ Server | 0 | ░░░░░░░░░░░░░░░░░░░░ | 300 | ⏳ 0% |
| 🖥️ System | 0 | ░░░░░░░░░░░░░░░░░░░░ | 2000 | ⏳ 0% |
| 🎨 UI | 0 | ░░░░░░░░░░░░░░░░░░░░ | 200 | ⏳ 0% |

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: 2025-12-12 06:06:57  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

- ✅ `guilds.accept_invite.html.twig` - ukończono 2025-12-12 06:06
- ✅ `forum.new_post.html.twig` - ukończono 2025-12-12 06:06
- ✅ `guilds.view.html.twig` - ukończono 2025-12-12 06:06
- ✅ `online.html.twig` - ukończono 2025-12-12 06:06
- ✅ `admin.changelog.html.twig` - ukończono 2025-12-12 06:06
- ✅ `forum.remove_post.html.twig` - ukończono 2025-12-12 06:06
- ✅ `language_selector.html.twig` - ukończono 2025-12-12 06:06
- ✅ `guilds.change_motd.html.twig` - ukończono 2025-12-12 06:06
- ✅ `faq.html.twig` - ukończono 2025-12-12 06:06
- ✅ `buttons.change_password.html.twig` - ukończono 2025-12-12 06:06

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
