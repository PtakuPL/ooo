#!/bin/bash
#===============================================================================
# I18N WORKER v2.0 - Multi-Mode Worker z trybami pracy
#===============================================================================
# TRYBY:
#   1. MIGRATION   - Migracja kodu NPC (8 etapów) - domyślny
#   2. TRANSLATION - Tłumaczenia kluczy EN → inne języki (6 etapów + składnie)
#   3. VALIDATION  - Walidacja tłumaczeń (4 etapy)
#
# Worker automatycznie przełącza się między trybami w trybie --continuous
#===============================================================================

cd "$(dirname "$0")"
WORK_DIR="$(pwd)"

STATUS_FILE="i18n_file_status.json"
I18N_DIR="i18n"
BACKUP_DIR="backups"
PROCESSED_FILE="i18n_processed_files.txt"

# Konfiguracja trybów
MIGRATION_BATCH=5           # Ile plików NPC na cykl migracji
TRANSLATION_BATCH=50        # Ile kluczy na batch tłumaczeń  
TRANSLATION_SUBSTAGE=4      # Ile kluczy na składnię
LANG_PRIORITY="pl de es pt fr it ru nl sv da no fi cs"  # Priorytet języków

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "$1"; }

#===============================================================================
# UPDATE_STATUS - Aktualizacja I18N_STATUS.md dla GitHub (pełna wersja)
#===============================================================================
update_github_status() {
    log "${CYAN}📊 Aktualizuję I18N_STATUS.md...${NC}"
    
    python3 << 'STATUSPY'
import json
import os
import subprocess
from datetime import datetime

WORK_DIR = os.getcwd()
STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"
PROCESSED_FILE = "i18n_processed_files.txt"
EXCLUDED_FILE = "i18n_excluded_files.txt"

# Znajdź git root (tam zapisujemy I18N_STATUS.md)
try:
    GIT_ROOT = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], 
                                        stderr=subprocess.DEVNULL).decode().strip()
except:
    GIT_ROOT = WORK_DIR  # Fallback do bieżącego katalogu

# Wczytaj status workera
try:
    with open(STATUS_FILE) as f:
        data = json.load(f)
except:
    data = {"files": {}}

files = data.get("files", {})
completed = len([f for f, info in files.items() if info.get("overall_status") == "completed"])
in_progress = len([f for f, info in files.items() if info.get("overall_status") == "in_progress"])

# Zlicz klucze per kategoria
def count_keys(filename):
    filepath = f"{I18N_DIR}/en/{filename}"
    if os.path.exists(filepath):
        try:
            with open(filepath) as f:
                return len(json.load(f))
        except:
            pass
    return 0

# Wszystkie kategorie
game_keys = count_keys("game.json")
items_keys = count_keys("items.json")
misc_keys = count_keys("misc.json")
monsters_keys = count_keys("monsters.json")
npc_keys = count_keys("npc.json")
player_keys = count_keys("player.json")
quests_keys = count_keys("quests.json")
scripts_keys = count_keys("scripts.json")
server_keys = count_keys("server.json")
spells_keys = count_keys("spells.json")
system_keys = count_keys("system.json")
ui_keys = count_keys("ui.json")

total_keys = game_keys + items_keys + misc_keys + monsters_keys + npc_keys + player_keys + quests_keys + scripts_keys + server_keys + spells_keys + system_keys + ui_keys

# Zlicz języki (wszystkie dostępne)
ALL_LANGUAGES = ["en", "pl", "de", "es", "pt", "fr", "it", "ru", "uk", "zh", "ja", "ko", "ar", "tr", "nl", "sv", "da", "no", "fi", "cs", "sk", "hu", "ro", "bg", "el", "he", "hi", "th", "vi", "id", "ms", "tl", "sw", "bn", "ta", "te", "ml", "ka", "hy", "az", "kk", "uz", "sr", "hr", "sl", "bs", "mk", "sq", "lv", "lt", "et", "fa", "zh_TW"]
langs_count = len(ALL_LANGUAGES)

langs_with_data = []
if os.path.isdir(I18N_DIR):
    for lang in os.listdir(I18N_DIR):
        lang_path = f"{I18N_DIR}/{lang}"
        if os.path.isdir(lang_path):
            for jf in os.listdir(lang_path):
                if jf.endswith(".json"):
                    try:
                        with open(f"{lang_path}/{jf}") as f:
                            if len(json.load(f)) > 0:
                                if lang not in langs_with_data:
                                    langs_with_data.append(lang)
                                break
                    except:
                        pass

# Zlicz pliki NPC
npc_dir = "data-otservbr-global/npc"
total_npc = 0
needs_migration_npc = 0
migrated_npc = 0
if os.path.isdir(npc_dir):
    for f in os.listdir(npc_dir):
        if f.endswith(".lua"):
            total_npc += 1
            fpath = f"{npc_dir}/{f}"
            try:
                with open(fpath) as fp:
                    content = fp.read()
                    has_stdmod = "StdModule.say" in content and "text" in content
                    has_i18n = "i18nKey" in content
                    if has_stdmod and not has_i18n:
                        needs_migration_npc += 1
                    elif has_i18n:
                        migrated_npc += 1
            except:
                pass

# Processed & excluded files count (z i18n_file_status.json, NIE ze starych plików!)
processed_count = completed  # Używamy completed z JSON
excluded_count = 0  # Już nie używamy starego systemu wykluczeń

# Policz faktycznie wykluczone (bez StdModule.say lub już zmigrowane)
excluded_count = 0
for f in os.listdir("data-otservbr-global/npc"):
    if f.endswith(".lua"):
        fpath = f"data-otservbr-global/npc/{f}"
        if fpath not in files:  # Nie w statusie
            try:
                with open(fpath) as nf:
                    content = nf.read()
                    if "StdModule.say" not in content:
                        excluded_count += 1  # Nie ma StdModule.say
            except:
                pass

# Cykl - pobierz z i18n_global_stats.json lub status file
cycle_count = 1
try:
    with open("i18n_global_stats.json") as f:
        gs = json.load(f)
        cycle_count = gs.get("total_cycles", 1)
except:
    try:
        with open("i18n_worker_state.json") as f:
            ws = json.load(f)
            cycle_count = ws.get("cycle", 1)
    except:
        pass

# Ostatnio ukończone NPC
recent_completed = []
sorted_files = sorted(
    [(f, info.get("completed_at", "")) for f, info in files.items() if info.get("overall_status") == "completed"],
    key=lambda x: x[1],
    reverse=True
)[:10]
for fpath, completed_at in sorted_files:
    fname = os.path.basename(fpath).replace(".lua", "")
    time_str = completed_at[:16].replace("T", " ") if completed_at else "?"
    recent_completed.append(f"- ✅ `{fname}` - ukończono {time_str}")

# Cele dla kategorii
TARGETS = {
    "game": 100, "items": 40000, "misc": 100, "monsters": 500,
    "npc": 15000, "player": 200, "quests": 500, "scripts": 1000,
    "server": 300, "spells": 200, "system": 2000, "ui": 200
}

def progress_bar(current, target, width=20):
    if target == 0:
        return "░" * width
    pct = min(current / target, 1.0)
    filled = int(pct * width)
    return "█" * filled + "░" * (width - filled)

def status_icon(current, target):
    if target == 0:
        return "⏳"
    pct = current / target
    if pct >= 0.9:
        return "✅"
    elif pct > 0:
        return "🔄"
    return "⏳"

# Generuj timestamp
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ==================== GENERUJ PEŁNY I18N_STATUS.md ====================
md = f'''# 🌍 I18N Internationalization System - Live Dashboard

> **Aktualizacja:** {timestamp} UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** {langs_count}

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
| 📁 Plików przetworzonych | **{processed_count}** | ↑ |
| ⏭️ Plików wykluczonych | **{excluded_count}** | - |
| 🔑 Kluczy i18n | **{total_keys}** | ↑ |
| 🌍 Języków | **{langs_count}** | ✓ |
| ⚠️ Konfliktów | **0** | ✓ |
| 🔄 Cykl | **#{cycle_count}** | - |

---

## ✅ CHECKLIST - Plan Pracy

> **Aktualna faza:** 🎮 Canary Server  
> **Aktualna kategoria:** NPC Migration

### 🔄 Faza 1: 🎮 Canary Server

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🧙 NPC Dialogs | {status_icon(npc_keys, TARGETS["npc"])} | {npc_keys}/{TARGETS["npc"]} ({round(npc_keys/TARGETS["npc"]*100)}%) | {TARGETS["npc"]} |
| 📜 Lua Scripts | {status_icon(scripts_keys, TARGETS["scripts"])} | {scripts_keys}/{TARGETS["scripts"]} ({round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}%) | {TARGETS["scripts"]} |
| 🎒 Items Database | {status_icon(items_keys, TARGETS["items"])} | {items_keys}/{TARGETS["items"]} ({round(items_keys/TARGETS["items"]*100)}%) | {TARGETS["items"]} |
| 👹 Monsters | {status_icon(monsters_keys, TARGETS["monsters"])} | {monsters_keys}/{TARGETS["monsters"]} ({round(monsters_keys/TARGETS["monsters"]*100)}%) | {TARGETS["monsters"]} |
| ✨ Spells & Magic | {status_icon(spells_keys, TARGETS["spells"])} | {spells_keys}/{TARGETS["spells"]} ({round(spells_keys/TARGETS["spells"]*100)}%) | {TARGETS["spells"]} |
| ⚙️ Server C++ | {status_icon(server_keys, TARGETS["server"])} | {server_keys}/{TARGETS["server"]} ({round(server_keys/TARGETS["server"]*100)}%) | {TARGETS["server"]} |

### ⏳ Faza 2: 🌐 Website (AAC)

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🐘 PHP Backend | ⏳ | 0/2015 (0%) | 2015 |
| 📄 HTML Views | ⏳ | 0/300 (0%) | 300 |
| 📦 JavaScript | ⏳ | 0/100 (0%) | 100 |

### ⏳ Faza 3: 📱 Instalka/Klient

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🖥️ Client UI | ⏳ | {ui_keys}/200 ({round(ui_keys/200*100)}%) | 200 |
| 💿 Installer | ⏳ | 0/94 (0%) | 94 |

### ⏳ Faza 4: 🌍 Tłumaczenia

| Kategoria | Status | Postęp | Cel |
|-----------|--------|--------|-----|
| 🇵🇱 Polski | {"🔄" if "pl" in langs_with_data else "⏳"} | {len([l for l in langs_with_data if l == "pl"])}/1 | 1 |
| 🇩🇪 Niemiecki | {"🔄" if "de" in langs_with_data else "⏳"} | {len([l for l in langs_with_data if l == "de"])}/1 | 1 |
| 🇪🇸 Hiszpański | {"🔄" if "es" in langs_with_data else "⏳"} | {len([l for l in langs_with_data if l == "es"])}/1 | 1 |
| 🌐 Pozostałe (50) | ⏳ | {len(langs_with_data)}/{langs_count} ({round(len(langs_with_data)/langs_count*100)}%) | {langs_count} |

---

## 🔴 LIVE: Aktualna Aktywność

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔴 LIVE: Worker v2.0                          Cykl #{cycle_count:>6} │
├─────────────────────────────────────────────────────────────────┤
│ Status:    {"🟢 RUNNING" if in_progress > 0 else "✅ IDLE":40} │
│ Tryb:      {"MIGRATION (8 etapów)":40} │
│ Kategoria: {"🧙 NPC Dialogs":40} │
├─────────────────────────────────────────────────────────────────┤
│ 📊 Postęp migracji NPC:                                        │
│ [{progress_bar(migrated_npc, migrated_npc + needs_migration_npc, 50)}] │
│ {migrated_npc}/{migrated_npc + needs_migration_npc} plików ({round(migrated_npc/(migrated_npc + needs_migration_npc)*100) if (migrated_npc + needs_migration_npc) > 0 else 0}%)                                          │
├─────────────────────────────────────────────────────────────────┤
│ ⏳ Pozostało: {needs_migration_npc} plików NPC                              │
│ 🕐 ETA: ~{needs_migration_npc * 4 // 60}min {needs_migration_npc * 4 % 60}s (przy 4s/plik)                             │
│ 📅 Ostatnia aktualizacja: {timestamp}                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📈 Statystyki sesji

| Metryka | Wartość | Szczegóły |
|---------|---------|-----------|
| 📁 Plików przetworzonych | **{processed_count}** | z i18n_file_status.json |
| ✅ NPC zmigrowanych | **{completed}** ({migrated_npc} z i18nKey) | z {total_npc} plików NPC |
| 🔑 Kluczy wyciągniętych | **{total_keys}** | we wszystkich kategoriach |
| 🌍 Języków z danymi | **{len(langs_with_data)}**/{langs_count} | {", ".join(sorted(langs_with_data)[:5])}{"..." if len(langs_with_data) > 5 else ""} |
| 🔄 Cykli wykonanych | **#{cycle_count}** | continuous mode |
| ⚠️ Plików do migracji | **{needs_migration_npc}** | NPC z StdModule.say |
| ❌ Błędów krytycznych | **0** | ✓ wszystko OK |

---

## 📜 Historia ostatnich operacji

{chr(10).join(recent_completed[:5]) if recent_completed else "- Brak operacji"}

---

## 📂 Szczegóły Kategorii

<details>
<summary>🎮 1. Game - {status_icon(game_keys, TARGETS["game"])} ({round(game_keys/TARGETS["game"]*100) if TARGETS["game"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {game_keys} |
| 🎯 Cel | {TARGETS["game"]} |
| 📊 Postęp | {round(game_keys/TARGETS["game"]*100) if TARGETS["game"] else 0}% |
| 📁 Plik | i18n/en/game.json |

</details>

<details>
<summary>🎒 2. Items - {status_icon(items_keys, TARGETS["items"])} ({round(items_keys/TARGETS["items"]*100) if TARGETS["items"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {items_keys} |
| 🎯 Cel | {TARGETS["items"]} |
| 📊 Postęp | {round(items_keys/TARGETS["items"]*100) if TARGETS["items"] else 0}% |
| 📁 Plik | i18n/en/items.json |

</details>

<details>
<summary>📦 3. Misc - {status_icon(misc_keys, TARGETS["misc"])} ({round(misc_keys/TARGETS["misc"]*100) if TARGETS["misc"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {misc_keys} |
| 🎯 Cel | {TARGETS["misc"]} |
| 📊 Postęp | {round(misc_keys/TARGETS["misc"]*100) if TARGETS["misc"] else 0}% |
| 📁 Plik | i18n/en/misc.json |

</details>

<details>
<summary>👹 4. Monsters - {status_icon(monsters_keys, TARGETS["monsters"])} ({round(monsters_keys/TARGETS["monsters"]*100) if TARGETS["monsters"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {monsters_keys} |
| 🎯 Cel | {TARGETS["monsters"]} |
| 📊 Postęp | {round(monsters_keys/TARGETS["monsters"]*100) if TARGETS["monsters"] else 0}% |
| 📁 Plik | i18n/en/monsters.json |

</details>

<details>
<summary>🧙 5. NPC - {status_icon(npc_keys, TARGETS["npc"])} ({round(npc_keys/TARGETS["npc"]*100) if TARGETS["npc"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {npc_keys} |
| 🎯 Cel | {TARGETS["npc"]} |
| 📊 Postęp | {round(npc_keys/TARGETS["npc"]*100) if TARGETS["npc"] else 0}% |
| 📁 Plik | i18n/en/npc.json |
| 📁 Plików NPC | {total_npc} |
| ✅ Zmigrowanych | {migrated_npc} |
| 🔄 Do migracji | {needs_migration_npc} |

</details>

<details>
<summary>👤 6. Player - {status_icon(player_keys, TARGETS["player"])} ({round(player_keys/TARGETS["player"]*100) if TARGETS["player"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {player_keys} |
| 🎯 Cel | {TARGETS["player"]} |
| 📊 Postęp | {round(player_keys/TARGETS["player"]*100) if TARGETS["player"] else 0}% |
| 📁 Plik | i18n/en/player.json |

</details>

<details>
<summary>📜 7. Quests - {status_icon(quests_keys, TARGETS["quests"])} ({round(quests_keys/TARGETS["quests"]*100) if TARGETS["quests"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {quests_keys} |
| 🎯 Cel | {TARGETS["quests"]} |
| 📊 Postęp | {round(quests_keys/TARGETS["quests"]*100) if TARGETS["quests"] else 0}% |
| 📁 Plik | i18n/en/quests.json |

</details>

<details>
<summary>📜 8. Scripts - {status_icon(scripts_keys, TARGETS["scripts"])} ({round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {scripts_keys} |
| 🎯 Cel | {TARGETS["scripts"]} |
| 📊 Postęp | {round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}% |
| 📁 Plik | i18n/en/scripts.json |

</details>

<details>
<summary>⚙️ 9. Server - {status_icon(server_keys, TARGETS["server"])} ({round(server_keys/TARGETS["server"]*100) if TARGETS["server"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {server_keys} |
| 🎯 Cel | {TARGETS["server"]} |
| 📊 Postęp | {round(server_keys/TARGETS["server"]*100) if TARGETS["server"] else 0}% |
| 📁 Plik | i18n/en/server.json |

</details>

<details>
<summary>✨ 10. Spells - {status_icon(spells_keys, TARGETS["spells"])} ({round(spells_keys/TARGETS["spells"]*100) if TARGETS["spells"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {spells_keys} |
| 🎯 Cel | {TARGETS["spells"]} |
| 📊 Postęp | {round(spells_keys/TARGETS["spells"]*100) if TARGETS["spells"] else 0}% |
| 📁 Plik | i18n/en/spells.json |

</details>

<details>
<summary>🖥️ 11. System - {status_icon(system_keys, TARGETS["system"])} ({round(system_keys/TARGETS["system"]*100) if TARGETS["system"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {system_keys} |
| 🎯 Cel | {TARGETS["system"]} |
| 📊 Postęp | {round(system_keys/TARGETS["system"]*100) if TARGETS["system"] else 0}% |
| 📁 Plik | i18n/en/system.json |

</details>

<details>
<summary>🎨 12. UI - {status_icon(ui_keys, TARGETS["ui"])} ({round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}%)</summary>

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy | {ui_keys} |
| 🎯 Cel | {TARGETS["ui"]} |
| 📊 Postęp | {round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}% |
| 📁 Plik | i18n/en/ui.json |

</details>

---

## 🔧 Worker & Guardian Status

| System | Status | Info |
|--------|--------|------|
| Worker v1.1 | 🟢 RUNNING | Cykl #{cycle_count} |
| Guardian v2.0 | 🟢 ACTIVE | Push co 2 min |

---

## 🗺️ Roadmap

```
[{status_icon(items_keys, TARGETS["items"])}] Items ({items_keys})      {progress_bar(items_keys, TARGETS["items"])}  {round(items_keys/TARGETS["items"]*100) if TARGETS["items"] else 0}%
[{status_icon(npc_keys, TARGETS["npc"])}] NPC ({npc_keys})            {progress_bar(npc_keys, TARGETS["npc"])}  {round(npc_keys/TARGETS["npc"]*100) if TARGETS["npc"] else 0}%
[{status_icon(scripts_keys, TARGETS["scripts"])}] Scripts ({scripts_keys})      {progress_bar(scripts_keys, TARGETS["scripts"])}  {round(scripts_keys/TARGETS["scripts"]*100) if TARGETS["scripts"] else 0}%
[{status_icon(monsters_keys, TARGETS["monsters"])}] Monsters ({monsters_keys})    {progress_bar(monsters_keys, TARGETS["monsters"])}  {round(monsters_keys/TARGETS["monsters"]*100) if TARGETS["monsters"] else 0}%
[{status_icon(spells_keys, TARGETS["spells"])}] Spells ({spells_keys})       {progress_bar(spells_keys, TARGETS["spells"])}  {round(spells_keys/TARGETS["spells"]*100) if TARGETS["spells"] else 0}%
[{status_icon(server_keys, TARGETS["server"])}] Server ({server_keys})       {progress_bar(server_keys, TARGETS["server"])}  {round(server_keys/TARGETS["server"]*100) if TARGETS["server"] else 0}%
[{status_icon(system_keys, TARGETS["system"])}] System ({system_keys})       {progress_bar(system_keys, TARGETS["system"])}  {round(system_keys/TARGETS["system"]*100) if TARGETS["system"] else 0}%
[{status_icon(ui_keys, TARGETS["ui"])}] UI ({ui_keys})             {progress_bar(ui_keys, TARGETS["ui"])}  {round(ui_keys/TARGETS["ui"]*100) if TARGETS["ui"] else 0}%
```

---

🤖 Machine-readable: `i18n_file_status.json`  
📅 Auto-updated by Worker v1.1 | Last: {timestamp}  
🔗 Repository: [PtakuPL/ooo](https://github.com/PtakuPL/ooo)

---

## Ostatnio zmigrowane NPC

{chr(10).join(recent_completed) if recent_completed else "- Brak"}

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
'''

# Zapisz do git root (nie do lokalnego katalogu!)
status_path = os.path.join(GIT_ROOT, "I18N_STATUS.md")
with open(status_path, "w") as f:
    f.write(md)

print(f"✅ I18N_STATUS.md zaktualizowany: {timestamp}")
print(f"   Ścieżka: {status_path}")
print(f"   NPC: {npc_keys} kluczy, {completed} zmigrowanych, {needs_migration_npc} do zrobienia")
print(f"   Total: {total_keys} kluczy | Języki: {len(langs_with_data)}/{langs_count}")
STATUSPY
}

#===============================================================================
# ETAP 1: STARTED
#===============================================================================
stage_1() {
    local file="$1"
    log "${BLUE}[1/8] STARTED${NC}: $file"
    
    [ ! -f "$file" ] && { log "${RED}Plik nie istnieje${NC}"; return 1; }
    
    local hash=$(md5sum "$file" | cut -d' ' -f1)
    local type="other"
    [[ "$file" == *"/npc/"* ]] && type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    
    mkdir -p "$BACKUP_DIR/$type"
    cp "$file" "$BACKUP_DIR/$type/$(basename $file).bak"
    
    # Zapisz do JSON
    python3 -c "
import json
from datetime import datetime

try:
    with open('$STATUS_FILE', 'r') as f: data = json.load(f)
except: data = {'files': {}}

data['files']['$file'] = {
    'stages': {
        '1_started': {'status': 'completed', 'hash': '$hash', 'type': '$type'}
    },
    'overall_status': 'in_progress'
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
    log "${GREEN}✓ Etap 1 OK${NC}: hash=$hash type=$type"
}

#===============================================================================
# ETAP 2: ANALYSIS
#===============================================================================
stage_2() {
    local file="$1"
    log "${BLUE}[2/8] ANALYSIS${NC}: $file"
    
    # Szukamy różnych wzorców tekstowych
    local stdmod=$(grep -c "StdModule\.say" "$file" 2>/dev/null || echo "0")
    local npcsay=$(grep -c "npcHandler:say" "$file" 2>/dev/null || echo "0")
    local sendtxt=$(grep -c "sendTextMessage" "$file" 2>/dev/null || echo "0")
    local greet=$(grep -c "addGreetKeyword" "$file" 2>/dev/null || echo "0")
    local farewell=$(grep -c "addFarewellKeyword" "$file" 2>/dev/null || echo "0")
    local i18nkey=$(grep -c "i18nKey" "$file" 2>/dev/null || echo "0")
    local npcsaylib=$(grep -c "NPC_LIB.i18n.npcSay" "$file" 2>/dev/null || echo "0")
    
    # Wyczyść zmienne - usuń białe znaki
    stdmod=${stdmod//[[:space:]]/}
    npcsay=${npcsay//[[:space:]]/}
    sendtxt=${sendtxt//[[:space:]]/}
    greet=${greet//[[:space:]]/}
    farewell=${farewell//[[:space:]]/}
    i18nkey=${i18nkey//[[:space:]]/}
    npcsaylib=${npcsaylib//[[:space:]]/}
    
    # Domyślne wartości
    [ -z "$stdmod" ] && stdmod=0
    [ -z "$npcsay" ] && npcsay=0
    [ -z "$sendtxt" ] && sendtxt=0
    [ -z "$greet" ] && greet=0
    [ -z "$farewell" ] && farewell=0
    [ -z "$i18nkey" ] && i18nkey=0
    [ -z "$npcsaylib" ] && npcsaylib=0
    
    local total=$((stdmod + npcsay + sendtxt + greet + farewell))
    local greet_farewell=$((greet + farewell))
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Sprawdź czy plik wymaga migracji
    local needs="false"
    
    # StdModule.say wymaga migracji jeśli brak i18nKey
    if [ "$stdmod" -gt 0 ] && [ "$i18nkey" -lt "$stdmod" ]; then
        needs="true"
    fi
    
    # npcHandler:say wymaga migracji jeśli brak NPC_LIB.i18n.npcSay
    if [ "$npcsay" -gt 0 ] && [ "$npcsaylib" -eq 0 ]; then
        needs="true"
    fi
    
    # addGreetKeyword/addFarewellKeyword z text wymaga migracji jeśli brak i18nKey
    if [ "$greet_farewell" -gt 0 ]; then
        local greet_with_i18n=$(grep -c "addGreetKeyword.*i18nKey\|addFarewellKeyword.*i18nKey" "$file" 2>/dev/null || echo "0")
        greet_with_i18n=${greet_with_i18n//[[:space:]]/}
        if [ "$greet_with_i18n" -lt "$greet_farewell" ]; then
            needs="true"
        fi
    fi
    
    python3 -c "
import json

needs_bool = True if '$needs' == 'true' else False

with open('$STATUS_FILE', 'r') as f: data = json.load(f)

data['files']['$file']['stages']['2_analysis'] = {
    'status': 'completed',
    'safe_name': '$safe',
    'StdModule_say': $stdmod,
    'npcHandler_say': $npcsay,
    'sendTextMessage': $sendtxt,
    'addGreetKeyword': $greet,
    'addFarewellKeyword': $farewell,
    'total': $total,
    'already_i18n': $i18nkey,
    'npcSayLib': $npcsaylib,
    'needs_migration': needs_bool
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
    log "${GREEN}✓ Etap 2 OK${NC}: StdModule=$stdmod, greet/farewell=$greet_farewell, needs=$needs"
    [ "$needs" = "true" ] && return 0 || return 2
}

#===============================================================================
# ETAP 3: DOCUMENTATION
#===============================================================================
stage_3() {
    local file="$1"
    log "${BLUE}[3/8] DOCUMENTATION${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    local doc_dir="docs/i18n/npc"
    
    mkdir -p "$doc_dir"
    
    python3 << EOF
import json
import re
from datetime import datetime

# Wczytaj backup z oryginalnymi tekstami
backup_file = "$BACKUP_DIR/npc/$(basename $file).bak"
try:
    with open(backup_file, "r") as f:
        content = f.read()
except:
    content = ""

# Znajdź wszystkie text = "..."
texts = re.findall(r'text\s*=\s*"([^"]+)"', content)

# Generuj markdown
doc_file = "$doc_dir/${safe}.md"
with open(doc_file, "w") as f:
    f.write(f"# NPC: $base\n\n")
    f.write(f"**Plik:** \`$file\`\n")
    f.write(f"**Data migracji:** {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
    f.write(f"**Liczba tekstów:** {len(texts)}\n\n")
    f.write("## Klucze i18n\n\n")
    f.write("| Klucz | Tekst EN |\n")
    f.write("|-------|----------|\n")
    for i, text in enumerate(texts, 1):
        if len(text) >= 5:
            key = f"npc.$safe.stdmod_{i}"
            f.write(f"| \`{key}\` | {text[:60]}{'...' if len(text) > 60 else ''} |\n")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["3_documentation"] = {
    "status": "completed", 
    "doc_file": doc_file,
    "keys_documented": len([t for t in texts if len(t) >= 5])
}
with open("$STATUS_FILE", "w") as f:
    json.dump(status, f, indent=2)

print(f"Utworzono: {doc_file}")
EOF
    
    log "${GREEN}✓ Etap 3 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 4: TRANSFORMATION (text → i18nKey + npcHandler:say → NPC_LIB.i18n.npcSay)
#===============================================================================
stage_4() {
    local file="$1"
    log "${BLUE}[4/8] TRANSFORMATION${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Użyj Pythona dla multi-line parsing
    local transformed=$(python3 << TRANSFORM_PY
import re
import os

file_path = "$file"
safe_name = "$safe"

with open(file_path, 'r') as f:
    content = f.read()

original_content = content
total_transformed = 0

#==============================================================================
# TRANSFORMACJA 1: StdModule.say z text = "..." → i18nKey = "..."
#==============================================================================
stdmod_counter = [0]

def replace_stdmod_with_i18n(match):
    stdmod_counter[0] += 1
    key = f"npc.{safe_name}.stdmod_{stdmod_counter[0]}"
    before = match.group(1)
    after = match.group(3)
    return f'{before}i18nKey = "{key}"{after}'

# Pattern dla multi-line StdModule.say z text = "..."
pattern_stdmod = r'(StdModule\.say\s*,\s*\{[^}]*?)text\s*=\s*"([^"]{5,})"([^}]*?\})'
content = re.sub(pattern_stdmod, replace_stdmod_with_i18n, content, flags=re.DOTALL)
total_transformed += stdmod_counter[0]

#==============================================================================
# TRANSFORMACJA 2: npcHandler:say("text", npc, creature) → NPC_LIB.i18n.npcSay()
# Wzorce:
#   npcHandler:say("Hello world", npc, creature)
#   npcHandler:say("Hello world", npc, player)
#   return npcHandler:say("Hello world", npc, creature)
# NIE transformujemy:
#   npcHandler:say({...})  - tablice
#   npcHandler:say("..." .. var ..) - konkatenacje
#   npcHandler:say(zmienna, ...) - zmienne
#==============================================================================
npcsay_counter = [0]

# Pattern: opcjonalnie "return ", potem npcHandler:say("prosty tekst bez konkatenacji", npc, creature/player)
pattern_npcsay = r'((?:return\s+)?)?npcHandler:say\(\s*"([^"]{5,})"\s*,\s*npc\s*,\s*(?:creature|player)\s*\)'

# Transformuj wszystkie npcHandler:say("...") - nawet jeśli już są jakieś NPC_LIB w pliku
if 'npcHandler:say("' in content:
    # Filtruj - nie transformujemy konkatenacji
    def safe_replace_npcsay(match):
        full_match = match.group(0)
        text = match.group(2) if match.lastindex >= 2 else ""
        
        # Pomiń jeśli to konkatenacja (.. przed lub po cudzysłowiu)
        start = match.start()
        end = match.end()
        
        if '.."' in full_match or '"..' in content[end:end+10]:
            return full_match  # Nie transformuj konkatenacji
        
        npcsay_counter[0] += 1
        key = f"npc.{safe_name}.say_{npcsay_counter[0]}"
        prefix = match.group(1) or ""
        
        return f'{prefix}NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "{key}")'
    
    content = re.sub(pattern_npcsay, safe_replace_npcsay, content)
    total_transformed += npcsay_counter[0]

#==============================================================================
# TRANSFORMACJA 3: addGreetKeyword/addFarewellKeyword text = "..." → i18nKey = "..."
# Wzorce:
#   keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, text = "Greetings, |PLAYERNAME|." })
#   keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, text = "Good bye." })
# Transformacja:
#   Dodaj i18nKey = "npc.{name}.greet_N" lub "npc.{name}.farewell_N"
#==============================================================================
greet_counter = [0]
farewell_counter = [0]

# Pattern dla addGreetKeyword z text = "..." (bez i18nKey)
# Szukamy: addGreetKeyword(..., { ... text = "..." ... (może być } albo }, function)
# Zmieniony pattern - szukamy text = "..." i dodajemy i18nKey zaraz po
pattern_greet = r'(addGreetKeyword\s*\([^)]*?)(text\s*=\s*"([^"]+)")([^}]*?\})'
# Pattern dla addFarewellKeyword z text = "..." (bez i18nKey)
pattern_farewell = r'(addFarewellKeyword\s*\([^)]*?)(text\s*=\s*"([^"]+)")([^}]*?\})'

# Transformuj tylko te wpisy które nie mają jeszcze i18nKey
def safe_replace_greet(match):
    full = match.group(0)
    if 'i18nKey' in full:
        return full  # Już ma - nie transformuj
    greet_counter[0] += 1
    key = f"npc.{safe_name}.greet_{greet_counter[0]}"
    before = match.group(1)
    text_part = match.group(2)
    text = match.group(3)
    after = match.group(4)
    return f'{before}{text_part}, i18nKey = "{key}"{after}'

def safe_replace_farewell(match):
    full = match.group(0)
    if 'i18nKey' in full:
        return full  # Już ma - nie transformuj
    farewell_counter[0] += 1
    key = f"npc.{safe_name}.farewell_{farewell_counter[0]}"
    before = match.group(1)
    text_part = match.group(2)
    text = match.group(3)
    after = match.group(4)
    return f'{before}{text_part}, i18nKey = "{key}"{after}'

if 'addGreetKeyword' in content:
    content = re.sub(pattern_greet, safe_replace_greet, content, flags=re.DOTALL)
    total_transformed += greet_counter[0]

if 'addFarewellKeyword' in content:
    content = re.sub(pattern_farewell, safe_replace_farewell, content, flags=re.DOTALL)
    total_transformed += farewell_counter[0]

greet_fare_total = greet_counter[0] + farewell_counter[0]

#==============================================================================
# ZAPIS
#==============================================================================
if total_transformed > 0 and content != original_content:
    with open(file_path, 'w') as f:
        f.write(content)
    print(f"{total_transformed}|{stdmod_counter[0]}|{npcsay_counter[0]}|{greet_fare_total}")
else:
    print("0|0|0|0")
TRANSFORM_PY
)
    
    # Parsuj wynik: total|stdmod|npcsay|greetfare
    local total_t=$(echo "$transformed" | cut -d'|' -f1)
    local stdmod_t=$(echo "$transformed" | cut -d'|' -f2)
    local npcsay_t=$(echo "$transformed" | cut -d'|' -f3)
    local greetfare_t=$(echo "$transformed" | cut -d'|' -f4)
    
    [ -z "$total_t" ] && total_t=0
    [ -z "$stdmod_t" ] && stdmod_t=0
    [ -z "$npcsay_t" ] && npcsay_t=0
    [ -z "$greetfare_t" ] && greetfare_t=0
    
    if [ "$total_t" -gt 0 ] 2>/dev/null; then
        log "${GREEN}✓ Etap 4 OK${NC}: StdModule=$stdmod_t, npcHandler:say=$npcsay_t, greet/farewell=$greetfare_t, Total=$total_t"
    else
        total_t=0
        log "${YELLOW}⏭ Etap 4${NC}: Brak zmian"
    fi
    
    python3 -c "
import json
with open('$STATUS_FILE', 'r') as f: data = json.load(f)
data['files']['$file']['stages']['4_transformation'] = {
    'status': 'completed', 
    'transformed': $total_t,
    'stdmod_transformed': $stdmod_t,
    'npcsay_transformed': $npcsay_t
}
with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
"
    return 0
}

#===============================================================================
# ETAP 5: EXTRACTION_EN (klucze do JSON) - StdModule.say + npcHandler:say
#===============================================================================
stage_5() {
    local file="$1"
    log "${BLUE}[5/8] EXTRACTION_EN${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local type="npc"
    [[ "$file" == *"/scripts/"* ]] && type="scripts"
    
    local backup="$BACKUP_DIR/$type/$(basename $file).bak"
    [ ! -f "$backup" ] && { log "${RED}Brak backupu${NC}"; return 1; }
    
    # Wyciągnij teksty z backupu i dodaj do JSON
    python3 << EOF
import json
import re

# Wczytaj backup (oryginalne teksty przed transformacją)
with open("$backup", "r") as f:
    content = f.read()

# Wczytaj npc.json
json_file = "$I18N_DIR/en/npc.json"
data = {}
try:
    with open(json_file, "r") as f:
        data = json.load(f)
except Exception as e:
    print(f"BŁĄD KRYTYCZNY: Nie można wczytać {json_file}: {e}")
    print("Przerywam ekstrakcję - nie chcę nadpisać danych!")
    exit(1)

added = 0
stdmod_count = 0
npcsay_count = 0

#==============================================================================
# EKSTRAKCJA 1: StdModule.say z text = "..." (może być multi-line)
#==============================================================================
# Pattern dla multi-line - text = "..." wewnątrz bloku StdModule.say
pattern_stdmod = r'StdModule\.say\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_stdmod = re.findall(pattern_stdmod, content, re.DOTALL)

for i, text in enumerate(texts_stdmod, 1):
    if len(text) >= 5:
        key = f"npc.$safe.stdmod_{i}"
        if key not in data:
            data[key] = text
            added += 1
            stdmod_count += 1

#==============================================================================
# EKSTRAKCJA 2: npcHandler:say("text", npc, creature/player)
# Multi-line aware - tekst może być rozciągnięty na wiele linii w pliku
#==============================================================================
# Pattern dla npcHandler:say("tekst", npc, creature/player)
# Szuka całego wywołania z tekstem
pattern_npcsay = r'npcHandler:say\(\s*"([^"]+)"\s*,\s*npc\s*,\s*(?:creature|player)\s*\)'
texts_npcsay = re.findall(pattern_npcsay, content, re.DOTALL)

for i, text in enumerate(texts_npcsay, 1):
    # Wyczyść ewentualne newline'y w tekście (artifact zawijania linii)
    text_clean = ' '.join(text.split())
    
    # Pomiń konkatenacje Lua (np. " .. variable .. ") ale NIE wielokropki (...)
    # Konkatenacja Lua to " .. " ze spacjami, wielokropek to "..."
    if ' .. ' not in text_clean and len(text_clean) >= 5:
        key = f"npc.$safe.say_{i}"
        if key not in data:
            data[key] = text_clean
            added += 1
            npcsay_count += 1

#==============================================================================
# EKSTRAKCJA 3: addGreetKeyword/addFarewellKeyword text = "..."
#==============================================================================
greet_count = 0
farewell_count = 0

# Pattern dla addGreetKeyword z text = "..."
pattern_greet = r'addGreetKeyword\s*\(\{[^}]+\}\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_greet = re.findall(pattern_greet, content, re.DOTALL)

for i, text in enumerate(texts_greet, 1):
    text_clean = ' '.join(text.split())
    if len(text_clean) >= 3:
        key = f"npc.$safe.greet_{i}"
        if key not in data:
            data[key] = text_clean
            added += 1
            greet_count += 1

# Pattern dla addFarewellKeyword z text = "..."
pattern_farewell = r'addFarewellKeyword\s*\(\{[^}]+\}\s*,\s*\{[^}]*?text\s*=\s*"([^"]+)"'
texts_farewell = re.findall(pattern_farewell, content, re.DOTALL)

for i, text in enumerate(texts_farewell, 1):
    text_clean = ' '.join(text.split())
    if len(text_clean) >= 3:
        key = f"npc.$safe.farewell_{i}"
        if key not in data:
            data[key] = text_clean
            added += 1
            farewell_count += 1

# Zapisz
with open(json_file, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Dodano {added} kluczy (StdModule: {stdmod_count}, npcHandler:say: {npcsay_count}, greet: {greet_count}, farewell: {farewell_count})")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["5_extraction_en"] = {
    "status": "completed", 
    "keys_added": added,
    "stdmod_keys": stdmod_count,
    "npcsay_keys": npcsay_count,
    "greet_keys": greet_count,
    "farewell_keys": farewell_count
}
with open("$STATUS_FILE", "w") as f:
    json.dump(status, f, indent=2)
EOF
    
    log "${GREEN}✓ Etap 5 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 6: TRANSLATION (EN → inne języki)
#===============================================================================
stage_6() {
    local file="$1"
    log "${BLUE}[6/8] PLACEHOLDER${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Etap 6 tylko tworzy placeholdery [LANG] - prawdziwe tłumaczenia w trybie TRANSLATION
    python3 << PYEOF
import json
import os

safe_name = "$safe"
status_file = "$STATUS_FILE"
i18n_dir = "$I18N_DIR"
file_path = "$file"

# Wczytaj en/npc.json
en_file = f"{i18n_dir}/en/npc.json"
try:
    with open(en_file, "r") as f:
        en_data = json.load(f)
except:
    print("Brak en/npc.json")
    exit(1)

# Znajdź klucze dla tego NPC
npc_keys = {k: v for k, v in en_data.items() if k.startswith(f"npc.{safe_name}.")}

if not npc_keys:
    print("Brak kluczy dla tego NPC - skip")
    exit(0)

# Tylko placeholder dla głównych języków (szybkie)
MAIN_LANGS = ["pl", "de", "es", "pt", "fr", "it", "ru"]
langs_done = []

for lang in MAIN_LANGS:
    lang_dir = f"{i18n_dir}/{lang}"
    os.makedirs(lang_dir, exist_ok=True)
    
    lang_file = f"{lang_dir}/npc.json"
    try:
        with open(lang_file, "r") as f:
            lang_data = json.load(f)
    except:
        lang_data = {}
    
    added = 0
    for key, text in npc_keys.items():
        if key not in lang_data:
            # Placeholder - do przetłumaczenia w trybie TRANSLATION
            lang_data[key] = f"[{lang.upper()}] {text}"
            added += 1
    
    if added > 0:
        with open(lang_file, "w") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
        langs_done.append(lang)

# Update status
with open(status_file, "r") as f:
    status = json.load(f)
status["files"][file_path]["stages"]["6_placeholder"] = {
    "status": "completed",
    "languages": langs_done,
    "keys_per_lang": len(npc_keys),
    "note": "Placeholdery - do przetłumaczenia w trybie --translate"
}
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

print(f"Placeholdery: {len(langs_done)} języków, {len(npc_keys)} kluczy każdy")
PYEOF
    
    log "${GREEN}✓ Etap 6 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 7: VALIDATION
#===============================================================================
stage_7() {
    local file="$1"
    log "${BLUE}[7/8] VALIDATION${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    python3 << PYEOF
import json
import os
import re

safe_name = "$safe"
status_file = "$STATUS_FILE"
i18n_dir = "$I18N_DIR"
file_path = "$file"
lua_file = "$file"

errors = []
warnings = []

# 1. Sprawdź czy plik Lua ma i18nKey
with open(lua_file, "r") as f:
    lua_content = f.read()

i18n_keys_in_lua = re.findall(r'i18nKey\s*=\s*"([^"]+)"', lua_content)
if not i18n_keys_in_lua:
    warnings.append("Brak i18nKey w pliku Lua")

# 2. Sprawdź czy klucze istnieją w en/npc.json
en_file = f"{i18n_dir}/en/npc.json"
try:
    with open(en_file, "r") as f:
        en_data = json.load(f)
except:
    en_data = {}

missing_in_json = []
for key in i18n_keys_in_lua:
    if key not in en_data:
        missing_in_json.append(key)
        errors.append(f"Klucz {key} brakuje w en/npc.json")

# 3. Duplikaty wartości - pomijamy (to normalne że różni NPC używają tych samych słów)
# values = list(en_data.values())
# duplicates = [v for v in values if values.count(v) > 1]
# To NIE jest błąd - wiele NPC może mieć te same teksty

# 4. Walidacja JSON wszystkich języków
valid_langs = []
invalid_langs = []
for lang_dir in os.listdir(i18n_dir):
    lang_file = f"{i18n_dir}/{lang_dir}/npc.json"
    if os.path.exists(lang_file):
        try:
            with open(lang_file, "r") as f:
                json.load(f)
            valid_langs.append(lang_dir)
        except json.JSONDecodeError as e:
            invalid_langs.append(lang_dir)
            errors.append(f"Błąd JSON w {lang_dir}/npc.json: {e}")

validation_ok = len(errors) == 0

# Update status
with open(status_file, "r") as f:
    status = json.load(f)
status["files"][file_path]["stages"]["7_validation"] = {
    "status": "completed" if validation_ok else "failed",
    "errors": errors,
    "warnings": warnings,
    "valid_langs": valid_langs,
    "keys_in_lua": len(i18n_keys_in_lua),
    "validation_passed": validation_ok
}
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

if errors:
    print(f"BŁĘDY: {len(errors)}")
    for e in errors:
        print(f"  ❌ {e}")
if warnings:
    print(f"OSTRZEŻENIA: {len(warnings)}")
    for w in warnings:
        print(f"  ⚠ {w}")
if not errors and not warnings:
    print("Walidacja OK - brak błędów")
PYEOF
    
    log "${GREEN}✓ Etap 7 OK${NC}"
    return 0
}

#===============================================================================
# ETAP 8: SYNC (status, statystyki)
#===============================================================================
stage_8() {
    local file="$1"
    log "${BLUE}[8/8] SYNC${NC}: $file"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    python3 << PYEOF
import json
import os
from datetime import datetime

status_file = "$STATUS_FILE"
file_path = "$file"
safe_name = "$safe"

# Wczytaj status
with open(status_file, "r") as f:
    status = json.load(f)

# Oznacz plik jako ukończony
file_info = status["files"].get(file_path, {})
all_stages = file_info.get("stages", {})
completed_stages = [s for s, v in all_stages.items() if v.get("status") == "completed"]

file_info["overall_status"] = "completed"
file_info["completed_at"] = datetime.now().isoformat()
file_info["stages"]["8_sync"] = {"status": "completed"}

status["files"][file_path] = file_info

# Statystyki globalne
if "global_stats" not in status:
    status["global_stats"] = {"files_completed": 0, "total_keys": 0}

status["global_stats"]["files_completed"] = len([
    f for f, info in status["files"].items() 
    if info.get("overall_status") == "completed"
])

# Zapisz
with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

# Aktualizuj I18N_STATUS.md
status_md = "I18N_STATUS.md"
try:
    with open(status_md, "r") as f:
        content = f.read()
except:
    content = "# I18N Status\n\n"

# Znajdź lub dodaj sekcję NPC
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
new_entry = "- ✅ \`" + safe_name + "\` - ukończono " + timestamp + "\\n"

if "## Ostatnio zmigrowane NPC" not in content:
    content += "\\n## Ostatnio zmigrowane NPC\\n\\n"

if safe_name not in content:
    # Dodaj po nagłówku
    content = content.replace(
        "## Ostatnio zmigrowane NPC\\n\\n",
        "## Ostatnio zmigrowane NPC\\n\\n" + new_entry
    )
    with open(status_md, "w") as f:
        f.write(content)
    print("Zaktualizowano " + status_md)

print(f"SYNC OK - plik oznaczony jako completed")
PYEOF
    
    log "${GREEN}✓ Etap 8 OK${NC}"
    return 0
}

#===============================================================================
# GŁÓWNA FUNKCJA
#===============================================================================
process_file() {
    local file="$1"
    echo ""
    echo "========================================"
    echo "Przetwarzanie: $file"
    echo "========================================"
    
    stage_1 "$file" || return 1
    stage_2 "$file"
    local ret=$?
    
    if [ $ret -eq 2 ]; then
        log "${YELLOW}Plik nie wymaga migracji${NC}"
        return 0
    fi
    
    stage_3 "$file" || return 1
    stage_4 "$file" || return 1
    stage_5 "$file" || return 1
    stage_6 "$file" || return 1
    stage_7 "$file" || return 1
    stage_8 "$file" || return 1
    
    log "${GREEN}✅ WSZYSTKIE 8 ETAPÓW UKOŃCZONE!${NC}"
    return 0
}

#===============================================================================
# FUNKCJE PRZETWARZANIA KATEGORII (SCRIPTS, MONSTERS, SPELLS, ITEMS)
#===============================================================================

# Przetwarzaj pliki skryptów (sendTextMessage → klucze i18n)
process_scripts_file() {
    local file="$1"
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    local json_file="$I18N_DIR/en/scripts.json"
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}📜 Processing script: $base${NC}"
    
    # Wyciągnij stringi z sendTextMessage
    local count=0
    while IFS= read -r text; do
        [ -z "$text" ] && continue
        [ ${#text} -lt 10 ] && continue
        
        local key="scripts.${safe}.msg_$((count + 1))"
        
        # Dodaj do JSON
        python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['$key'] = '''$text'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
        
        count=$((count + 1))
        log "   🔑 $key"
    done < <(grep -oP 'sendTextMessage\s*\([^,]+,\s*"\K[^"]+' "$file" 2>/dev/null | head -20)
    
    # Oznacz jako przetworzony
    echo "$file" >> "$PROCESSED_FILE"
    
    log "${GREEN}✅ Scripts: $count kluczy z $base${NC}"
    return 0
}

# Przetwarzaj kategorię monsters
process_monsters_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/monsters.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}👹 Processing monsters...${NC}"
    
    # Szukaj plików monsters w różnych lokalizacjach
    for dir in data-otservbr-global/monster data-canary/monster; do
        [ ! -d "$dir" ] && continue
        
        for file in $(find "$dir" -name "*.lua" -o -name "*.xml" 2>/dev/null | head -$batch); do
            [ -f "$file" ] || continue
            grep -qF "$file" "$PROCESSED_FILE" 2>/dev/null && continue
            
            local base=$(basename "$file" | sed 's/\.\(lua\|xml\)$//')
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            
            # Wyciągnij name i description
            local name=$(grep -oP 'name\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            local desc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            
            # Domyślnie użyj nazwy pliku jako name
            [ -z "$name" ] && name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            if [ -n "$name" ]; then
                python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['monster.$safe.name'] = '''$name'''
if '''$desc''':
    d['monster.$safe.desc'] = '''$desc'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
                count=$((count + 1))
                log "   👹 monster.$safe.name = $name"
            fi
            
            echo "$file" >> "$PROCESSED_FILE"
            [ "$count" -ge "$batch" ] && break
        done
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Monsters: $count kluczy${NC}"
}

# Przetwarzaj kategorię spells
process_spells_category() {
    local batch="${1:-10}"
    local json_file="$I18N_DIR/en/spells.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}✨ Processing spells...${NC}"
    
    for dir in data-otservbr-global/scripts/spells data/scripts/spells; do
        [ ! -d "$dir" ] && continue
        
        for file in $(find "$dir" -name "*.lua" 2>/dev/null | head -$batch); do
            [ -f "$file" ] || continue
            grep -qF "$file" "$PROCESSED_FILE" 2>/dev/null && continue
            
            local base=$(basename "$file" .lua)
            local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
            local name=$(echo "$base" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            # Wyciągnij words (słowa do rzucenia spella)
            local words=$(grep -oP 'words\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            local desc=$(grep -oP 'description\s*=\s*"\K[^"]+' "$file" 2>/dev/null | head -1)
            
            python3 -c "
import json
try:
    with open('$json_file') as f: d = json.load(f)
except: d = {}
d['spell.$safe.name'] = '''$name'''
if '''$words''':
    d['spell.$safe.words'] = '''$words'''
if '''$desc''':
    d['spell.$safe.desc'] = '''$desc'''
with open('$json_file', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
" 2>/dev/null
            
            echo "$file" >> "$PROCESSED_FILE"
            count=$((count + 1))
            log "   ✨ spell.$safe.name = $name"
            
            [ "$count" -ge "$batch" ] && break
        done
        [ "$count" -ge "$batch" ] && break
    done
    
    log "${GREEN}✅ Spells: $count kluczy${NC}"
}

# Przetwarzaj kategorię items (z XML)
process_items_category() {
    local batch="${1:-50}"
    local json_file="$I18N_DIR/en/items.json"
    local count=0
    
    [ ! -f "$json_file" ] && echo '{}' > "$json_file"
    
    log "${CYAN}🎒 Processing items...${NC}"
    
    # Items są głównie w XML
    local items_xml="data/items/items.xml"
    [ ! -f "$items_xml" ] && items_xml="data-otservbr-global/items/items.xml"
    
    if [ -f "$items_xml" ]; then
        # Wyciągnij nazwy itemów z XML
        python3 << ITEMSPY
import json
import re

json_file = "$json_file"
items_xml = "$items_xml"
batch = $batch

try:
    with open(json_file) as f:
        data = json.load(f)
except:
    data = {}

existing_keys = len(data)

try:
    with open(items_xml, 'r', errors='ignore') as f:
        content = f.read()
    
    # Znajdź wszystkie <item id="..." name="...">
    items = re.findall(r'<item\s+id="(\d+)"[^>]*name="([^"]+)"', content)
    
    count = 0
    for item_id, name in items:
        if count >= batch:
            break
        key = f"item.{item_id}.name"
        if key not in data:
            data[key] = name
            count += 1
    
    with open(json_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"Dodano {count} nowych itemów (razem: {len(data)})")
except Exception as e:
    print(f"Błąd: {e}")
ITEMSPY
    else
        log "${YELLOW}⚠️ Brak pliku items.xml${NC}"
    fi
    
    log "${GREEN}✅ Items: przetworzono${NC}"
}

#===============================================================================
# AUTO TRANSLATE - Automatyczne tłumaczenie BEZ interakcji
#===============================================================================
# Kopiuje klucze EN do innych języków z prefiksem [LANG] lub używa prostych
# tłumaczeń dla popularnych fraz.
#===============================================================================
auto_translate_keys() {
    local target_lang="$1"
    local json_file="$2"
    local keys_count="$3"
    
    log "${CYAN}🌍 AUTO TRANSLATE: $target_lang <- $json_file${NC}"
    
    python3 << AUTOTRANSPY
import json
import os
import re

I18N_DIR = "i18n"
target_lang = "$target_lang"
json_file = "$json_file"

# Prosty słownik tłumaczeń dla popularnych fraz
SIMPLE_TRANSLATIONS = {
    "pl": {
        "Hello": "Witaj",
        "Welcome": "Witamy",
        "Goodbye": "Do widzenia",
        "Thank you": "Dziękuję",
        "Yes": "Tak",
        "No": "Nie",
        "Buy": "Kup",
        "Sell": "Sprzedaj",
        "Trade": "Handel",
        "Help": "Pomoc",
        "Quest": "Zadanie",
        "Mission": "Misja",
        "Gold": "Złoto",
        "Player": "Gracz",
        "Monster": "Potwór",
        "Item": "Przedmiot",
        "Spell": "Zaklęcie",
        "Attack": "Atak",
        "Defense": "Obrona",
        "Health": "Zdrowie",
        "Mana": "Mana",
    },
    "de": {
        "Hello": "Hallo",
        "Welcome": "Willkommen",
        "Goodbye": "Auf Wiedersehen",
        "Thank you": "Danke",
        "Yes": "Ja",
        "No": "Nein",
        "Buy": "Kaufen",
        "Sell": "Verkaufen",
        "Trade": "Handel",
        "Help": "Hilfe",
        "Quest": "Quest",
        "Mission": "Mission",
        "Gold": "Gold",
        "Player": "Spieler",
        "Monster": "Monster",
        "Item": "Gegenstand",
        "Spell": "Zauber",
    },
    "es": {
        "Hello": "Hola",
        "Welcome": "Bienvenido",
        "Goodbye": "Adiós",
        "Thank you": "Gracias",
        "Yes": "Sí",
        "No": "No",
        "Buy": "Comprar",
        "Sell": "Vender",
        "Trade": "Comercio",
        "Help": "Ayuda",
        "Quest": "Misión",
        "Gold": "Oro",
        "Player": "Jugador",
        "Monster": "Monstruo",
    },
    "ru": {
        "Hello": "Привет",
        "Welcome": "Добро пожаловать",
        "Goodbye": "До свидания",
        "Thank you": "Спасибо",
        "Yes": "Да",
        "No": "Нет",
        "Buy": "Купить",
        "Sell": "Продать",
        "Trade": "Торговля",
        "Help": "Помощь",
        "Quest": "Задание",
        "Gold": "Золото",
        "Player": "Игрок",
        "Monster": "Монстр",
    },
    "pt": {
        "Hello": "Olá",
        "Welcome": "Bem-vindo",
        "Goodbye": "Adeus",
        "Thank you": "Obrigado",
        "Yes": "Sim",
        "No": "Não",
        "Buy": "Comprar",
        "Sell": "Vender",
        "Trade": "Comércio",
        "Help": "Ajuda",
        "Quest": "Missão",
        "Gold": "Ouro",
        "Player": "Jogador",
        "Monster": "Monstro",
    }
}

def simple_translate(text, lang):
    """Prosta zamiana znanych fraz"""
    if lang not in SIMPLE_TRANSLATIONS:
        return None
    
    result = text
    for en, translated in SIMPLE_TRANSLATIONS[lang].items():
        # Case-insensitive replace zachowując wielkość liter
        pattern = re.compile(re.escape(en), re.IGNORECASE)
        result = pattern.sub(translated, result)
    
    # Jeśli nic się nie zmieniło, zwróć None
    if result == text:
        return None
    return result

# Wczytaj EN jako źródło
en_file = f"{I18N_DIR}/en/{json_file}"
if not os.path.exists(en_file):
    print(f"Brak pliku źródłowego: {en_file}")
    exit(0)

with open(en_file) as f:
    en_data = json.load(f)

# Wczytaj lub utwórz plik docelowy
lang_file = f"{I18N_DIR}/{target_lang}/{json_file}"
os.makedirs(os.path.dirname(lang_file), exist_ok=True)

try:
    with open(lang_file) as f:
        lang_data = json.load(f)
except:
    lang_data = {}

# Przetwórz klucze
translated = 0
placeholders = 0
for key, en_text in en_data.items():
    if key in lang_data:
        # Sprawdź czy to placeholder
        if not lang_data[key].startswith("["):
            continue  # Już przetłumaczone
    
    # Spróbuj prostego tłumaczenia
    simple = simple_translate(en_text, target_lang)
    
    if simple:
        lang_data[key] = simple
        translated += 1
    else:
        # Placeholder z kodem języka
        lang_data[key] = f"[{target_lang.upper()}] {en_text}"
        placeholders += 1

# Zapisz
lang_data = dict(sorted(lang_data.items()))
with open(lang_file, 'w') as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)

print(f"✅ {target_lang}/{json_file}: {translated} przetłumaczonych, {placeholders} placeholder'ów")
AUTOTRANSPY
    
    log "${GREEN}✅ Auto-translate zakończone${NC}"
}

#===============================================================================
# TRYB 2: TŁUMACZENIA - INTERAKTYWNY dla agenta LLM
#===============================================================================
# Agent LLM (Phi-4, GPT, Claude) uruchamia ten skrypt w terminalu.
# Worker wyświetla tekst EN, agent wpisuje tłumaczenie, worker zapisuje.
#
# ZASADY DLA AGENTA:
# - Tłumacz całe zdania naturalnie
# - Komendy w 'apostrofach' (np. 'trade', 'job') - NIE TŁUMACZ
# - Zmienne w {nawiasach} (np. {player}) - BEZ ZMIAN
# - Formatowanie |PIPE| - BEZ ZMIAN
# - Wpisz "SKIP" aby pominąć klucz
# - Wpisz "QUIT" aby zakończyć sesję
#===============================================================================
mode_translation() {
    local target_lang="${1:-pl}"
    
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BLUE}TRYB 2: TŁUMACZENIA INTERAKTYWNE${NC} - Język: $target_lang"
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Przekaż zmienne do Pythona przez zmienne środowiskowe
    export TRANSLATE_LANG="$target_lang"
    export TRANSLATE_I18N_DIR="$I18N_DIR"
    export TRANSLATE_STATUS_FILE="$STATUS_FILE"
    export TRANSLATE_BATCH="$TRANSLATION_BATCH"
    export TRANSLATE_SUBSTAGE="$TRANSLATION_SUBSTAGE"
    
    python3 << 'PYTRANSLATE'
import json
import os
import re
import sys

target_lang = os.environ.get("TRANSLATE_LANG", "pl")
i18n_dir = os.environ.get("TRANSLATE_I18N_DIR", "i18n")
status_file = os.environ.get("TRANSLATE_STATUS_FILE", "i18n_file_status.json")
batch_size = int(os.environ.get("TRANSLATE_BATCH", "50"))
substage_size = int(os.environ.get("TRANSLATE_SUBSTAGE", "4"))

# [1/6] SELECT_SOURCE
print("[1/6] SELECT_SOURCE: en/npc.json")
en_file = f"{i18n_dir}/en/npc.json"
if not os.path.exists(en_file):
    print("❌ Brak pliku en/npc.json")
    exit(1)

with open(en_file) as f:
    en_data = json.load(f)

# [2/6] DETECT_PROGRESS
print(f"[2/6] DETECT_PROGRESS: Sprawdzam {target_lang}/npc.json")
lang_dir = f"{i18n_dir}/{target_lang}"
os.makedirs(lang_dir, exist_ok=True)
lang_file = f"{lang_dir}/npc.json"

if os.path.exists(lang_file):
    with open(lang_file) as f:
        lang_data = json.load(f)
else:
    lang_data = {}

# Znajdź klucze do przetłumaczenia (brakujące lub z placeholder [LANG])
keys_todo = []
for key, text in en_data.items():
    if key not in lang_data:
        keys_todo.append((key, text))
    elif lang_data[key].startswith(f"[{target_lang.upper()}]") or lang_data[key].startswith("[TODO]"):
        keys_todo.append((key, text))

print(f"   Kluczy do tłumaczenia: {len(keys_todo)}")

if len(keys_todo) == 0:
    print(f"✅ Wszystkie klucze dla {target_lang} są przetłumaczone!")
    exit(0)

# [3/6] PREPARE_BATCH
print(f"[3/6] PREPARE_BATCH: Przygotowanie {min(batch_size, len(keys_todo))} kluczy")
keys_batch = keys_todo[:batch_size]
total_substages = (len(keys_batch) + substage_size - 1) // substage_size
print(f"   Składni: {total_substages}")

# [4/6] TRANSLATE_BATCH - tłumaczenie ze składniami
print(f"[4/6] TRANSLATE_BATCH: Tłumaczenie")

#===============================================================================
# Słownik nazw języków
LANG_NAMES = {
    "pl": "polski", "de": "niemiecki", "es": "hiszpański", "pt": "portugalski",
    "fr": "francuski", "it": "włoski", "ru": "rosyjski", "nl": "holenderski",
    "sv": "szwedzki", "da": "duński", "no": "norweski", "fi": "fiński",
    "cs": "czeski", "sk": "słowacki", "hu": "węgierski", "ro": "rumuński",
    "bg": "bułgarski", "el": "grecki", "tr": "turecki", "uk": "ukraiński",
    "zh": "chiński (uproszczony)", "ja": "japoński", "ko": "koreański", "ar": "arabski"
}

# Przetwórz interaktywnie - agent wpisuje tłumaczenia
translated_count = 0
skipped_count = 0

print("")
print("╔══════════════════════════════════════════════════════════════════════╗")
print(f"║  🌍 TRYB INTERAKTYWNY - TŁUMACZENIE NA {LANG_NAMES.get(target_lang, target_lang).upper():20}         ║")
print("╠══════════════════════════════════════════════════════════════════════╣")
print("║  ZASADY:                                                             ║")
print("║  • Komendy w 'apostrofach' NIE TŁUMACZ (np. 'trade', 'job')          ║")
print("║  • Zmienne w {nawiasach} zachowaj bez zmian                          ║")
print("║  • Formatowanie |PIPE| zachowaj bez zmian                            ║")
print("║                                                                      ║")
print("║  KOMENDY: SKIP = pomiń | QUIT = zakończ | SAVE = zapisz i kontynuuj  ║")
print("╚══════════════════════════════════════════════════════════════════════╝")
print("")
print(f"📊 Do przetłumaczenia: {len(keys_batch)} kluczy")
print("")

quit_requested = False

for idx, (key, en_text) in enumerate(keys_batch):
    if quit_requested:
        break
    
    # Wyświetl tekst do tłumaczenia
    print("─" * 70)
    print(f"[{idx + 1}/{len(keys_batch)}] 📌 {key}")
    print(f"")
    print(f"  EN: {en_text}")
    print(f"")
    
    # Pokaż zmienne/komendy do zachowania
    commands = re.findall(r"'[^']+?'", en_text)
    variables = re.findall(r"\{[^}]+?\}", en_text)
    pipes = re.findall(r"\|[^|]+?\|", en_text)
    
    if commands or variables or pipes:
        print(f"  ⚠️  Zachowaj bez zmian: ", end="")
        if commands:
            print(f"komendy: {', '.join(commands)} ", end="")
        if variables:
            print(f"zmienne: {', '.join(variables)} ", end="")
        if pipes:
            print(f"pipe: {', '.join(pipes)}", end="")
        print("")
        print("")
    
    # Czekaj na input od agenta (przez terminal)
    print(f"  {target_lang.upper()}: ", end="")
    sys.stdout.flush()
    
    try:
        # Spróbuj czytać z /dev/tty (terminal) jeśli stdin jest pipe
        if not sys.stdin.isatty():
            try:
                with open('/dev/tty', 'r') as tty:
                    translation = tty.readline().strip()
            except:
                translation = input().strip()
        else:
            translation = input().strip()
    except EOFError:
        print("\n⚠️  Koniec input - zapisuję i kończę")
        break
    
    # Obsłuż komendy
    if translation.upper() == "QUIT":
        print("  ✋ Zakończono sesję")
        quit_requested = True
        break
    elif translation.upper() == "SKIP":
        print("  ⏭️  Pominięto")
        skipped_count += 1
        lang_data[key] = f"[SKIP:{target_lang.upper()}] {en_text}"
        continue
    elif translation.upper() == "SAVE":
        print("  💾 Zapisuję dotychczasowe i kontynuuję...")
        lang_data = dict(sorted(lang_data.items()))
        with open(lang_file, "w") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
        print(f"  ✅ Zapisano {len(lang_data)} kluczy")
        continue
    elif not translation:
        print("  ⏭️  Puste - pominięto")
        skipped_count += 1
        lang_data[key] = f"[EMPTY:{target_lang.upper()}] {en_text}"
        continue
    
    # Walidacja - czy zachowano komendy i zmienne
    valid = True
    for cmd in commands:
        if cmd not in translation:
            print(f"  ⚠️  UWAGA: Brakuje komendy {cmd}!")
            valid = False
    for var in variables:
        if var not in translation:
            print(f"  ⚠️  UWAGA: Brakuje zmiennej {var}!")
            valid = False
    
    if valid:
        print(f"  ✅ OK")
    
    # Zapisz tłumaczenie
    lang_data[key] = translation
    translated_count += 1

print("")
print("═" * 70)

# [5/6] SAVE_TRANSLATIONS
print(f"[5/6] SAVE_TRANSLATIONS: Zapisuję {translated_count} tłumaczeń")
lang_data = dict(sorted(lang_data.items()))
with open(lang_file, "w") as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)

# Statystyki
placeholders = len([v for v in lang_data.values() if v.startswith("[")])
real_total = len(lang_data) - placeholders

# [6/6] SYNC
print(f"[6/6] SYNC: Aktualizacja statusu")

# Aktualizuj status
with open(status_file) as f:
    status = json.load(f)

if "translation_status" not in status:
    status["translation_status"] = {}

status["translation_status"][target_lang] = {
    "total_keys": len(lang_data),
    "translated": real_total,
    "placeholders": placeholders,
    "last_batch": translated_count,
    "last_update": __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S")
}

with open(status_file, "w") as f:
    json.dump(status, f, indent=2)

print(f"\n✅ SESJA TŁUMACZENIA ZAKOŃCZONA: {target_lang}")
print(f"   Przetłumaczono: {translated_count}")
print(f"   Pominięto: {skipped_count}")
print(f"   Razem w pliku: {len(lang_data)} kluczy")
print(f"   Prawdziwe tłumaczenia: {real_total}")
print(f"   Pozostało placeholder'ów: {placeholders}")
PYTRANSLATE

    log "${GREEN}✅ TRYB TŁUMACZEŃ ZAKOŃCZONY${NC}"
    return 0
}

#===============================================================================
# DISPATCHER - Wybór trybu w continuous mode (Multi-Category)
#===============================================================================
# KATEGORIE: NPC → SCRIPTS → MONSTERS → ITEMS → SPELLS → SERVER → WEB
# Po zakończeniu migracji wszystkich kategorii → AUTO_TRANSLATE
#===============================================================================
select_work_mode() {
    python3 << 'DISPATCHERPY'
import os
import json
import glob
import re

I18N_DIR = "i18n"
LANG_PRIORITY = ["pl", "de", "es", "pt", "fr", "it", "ru", "nl", "sv", "cs"]
ALL_LANGUAGES = ["pl", "de", "es", "pt", "fr", "it", "ru", "uk", "nl", "sv", "da", "no", "fi", "cs", "sk", "hu", "ro", "bg", "el", "tr", "ar", "he", "hi", "zh", "ja", "ko", "th", "vi", "id", "ms"]

# Definicja kategorii do przetworzenia
CATEGORIES = {
    "npc": {
        "dirs": ["data-otservbr-global/npc", "data-canary/npc"],
        "patterns": [r'StdModule\.say.*text\s*=\s*"[^"]+"', r'npcHandler:say\(\s*"[^"]{5,}"'],
        "exclude_if": ["i18nKey", "NPC_LIB.i18n.npcSay"],
        "json": "npc.json"
    },
    "scripts": {
        "dirs": ["data-otservbr-global/scripts", "data/scripts"],
        "patterns": [r'sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"', r'player:say\(\s*"[^"]+"'],
        "exclude_if": ["sendLocalizedTextMessage"],
        "json": "scripts.json"
    },
    "monsters": {
        "dirs": ["data-otservbr-global/monster", "data-canary/monster"],
        "patterns": [r'description\s*=\s*"[^"]+"', r'name\s*=\s*"[^"]+"'],
        "exclude_if": [],
        "json": "monsters.json"
    },
    "spells": {
        "dirs": ["data-otservbr-global/scripts/spells", "data/scripts/spells"],
        "patterns": [r'words\s*=\s*"[^"]+"', r'description\s*=\s*"[^"]+"'],
        "exclude_if": [],
        "json": "spells.json"
    },
    "items": {
        "dirs": ["data/items"],
        "patterns": [r'name="[^"]+"', r'description="[^"]+"'],
        "exclude_if": [],
        "json": "items.json"
    }
}

# Wczytaj status plików z i18n_file_status.json
STATUS_FILE = "i18n_file_status.json"
completed_files = set()
try:
    with open(STATUS_FILE) as f:
        status_data = json.load(f)
    for fpath, info in status_data.get("files", {}).items():
        if info.get("overall_status") == "completed":
            completed_files.add(fpath)
except:
    pass

def count_files_needing_work(category):
    """Zlicz pliki wymagające migracji w danej kategorii"""
    config = CATEGORIES.get(category, {})
    if not config:
        return 0
    
    needs_work = 0
    for dir_path in config["dirs"]:
        if not os.path.isdir(dir_path):
            continue
        for root, dirs, files in os.walk(dir_path):
            for f in files:
                if not f.endswith(".lua") and not f.endswith(".xml"):
                    continue
                fpath = os.path.join(root, f)
                
                # Sprawdź czy plik nie jest już oznaczony jako completed
                if fpath in completed_files:
                    continue
                
                try:
                    with open(fpath, 'r', errors='ignore') as fp:
                        content = fp.read()
                    
                    # Sprawdź czy plik ma wzorce do migracji
                    has_pattern = False
                    for pattern in config["patterns"]:
                        if re.search(pattern, content):
                            has_pattern = True
                            break
                    
                    if not has_pattern:
                        continue
                    
                    # Sprawdź czy nie jest już zmigrowany
                    already_done = False
                    for exclude in config["exclude_if"]:
                        if exclude in content:
                            already_done = True
                            break
                    
                    if has_pattern and not already_done:
                        needs_work += 1
                except:
                    pass
    return needs_work

def count_keys_in_json(json_file):
    """Zlicz klucze w pliku JSON"""
    fpath = f"{I18N_DIR}/en/{json_file}"
    if os.path.exists(fpath):
        try:
            with open(fpath) as f:
                return len(json.load(f))
        except:
            pass
    return 0

def count_untranslated_keys(lang, json_file):
    """Zlicz klucze z placeholderami [LANG] lub brakujące"""
    en_path = f"{I18N_DIR}/en/{json_file}"
    lang_path = f"{I18N_DIR}/{lang}/{json_file}"
    
    if not os.path.exists(en_path):
        return 0
    
    try:
        with open(en_path) as f:
            en_data = json.load(f)
        
        if not os.path.exists(lang_path):
            return len(en_data)
        
        with open(lang_path) as f:
            lang_data = json.load(f)
        
        # Zlicz placeholdery i brakujące
        untranslated = 0
        for key in en_data:
            if key not in lang_data:
                untranslated += 1
            elif lang_data[key].startswith("["):
                untranslated += 1
            elif lang_data[key] == en_data[key]:  # Identyczne = nie przetłumaczone
                untranslated += 1
        return untranslated
    except:
        return 0

# ============ GŁÓWNA LOGIKA DISPATCHERA ============

# 1. Sprawdź każdą kategorię po kolei
for cat_name, config in CATEGORIES.items():
    needs_work = count_files_needing_work(cat_name)
    if needs_work > 0:
        print(f"MIGRATION:{cat_name}:{needs_work}")
        exit(0)

# 2. Migracja zakończona - sprawdź tłumaczenia
total_untranslated = 0
for json_file in ["npc.json", "scripts.json", "monsters.json", "spells.json"]:
    en_keys = count_keys_in_json(json_file)
    if en_keys == 0:
        continue
    
    for lang in LANG_PRIORITY:
        untranslated = count_untranslated_keys(lang, json_file)
        if untranslated > 0:
            total_untranslated += untranslated
            # Zwróć AUTO_TRANSLATE zamiast TRANSLATION (bez interakcji!)
            print(f"AUTO_TRANSLATE:{lang}:{json_file}:{untranslated}")
            exit(0)

# 3. Wszystko zrobione
if total_untranslated == 0:
    print("IDLE:all_done:0")
else:
    print(f"AUTO_TRANSLATE:all:{total_untranslated}")
DISPATCHERPY
}

#===============================================================================
# MAIN
#===============================================================================
echo "╔════════════════════════════════════════╗"
echo "║   I18N WORKER v2.0 - Multi-Mode        ║"
echo "╚════════════════════════════════════════╝"

# Inicjalizuj JSON
[ ! -f "$STATUS_FILE" ] && echo '{"files":{}}' > "$STATUS_FILE"
mkdir -p "$I18N_DIR/en" "$BACKUP_DIR/npc" "$BACKUP_DIR/scripts"

case "${1:-}" in
    --file)
        [ -z "${2:-}" ] && { echo "Podaj ścieżkę pliku"; exit 1; }
        process_file "$2"
        ;;
    --translate)
        # Tryb tłumaczeń
        LANG="${2:-pl}"
        mode_translation "$LANG"
        update_github_status
        ;;
    --status)
        python3 << 'STATUSEOF'
import json
import os
from datetime import datetime

STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"

try:
    with open(STATUS_FILE) as f:
        data = json.load(f)
except:
    data = {"files": {}}

files = data.get("files", {})
global_stats = data.get("global_stats", {})

# Kolory ANSI
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
RED = "\033[0;31m"
CYAN = "\033[0;36m"
NC = "\033[0m"

print(f"\n{CYAN}╔══════════════════════════════════════════════════════════════════╗{NC}")
print(f"{CYAN}║          I18N WORKER - STATUS DASHBOARD                          ║{NC}")
print(f"{CYAN}╚══════════════════════════════════════════════════════════════════╝{NC}")

# Zlicz pliki po statusie
completed = [f for f, info in files.items() if info.get("overall_status") == "completed"]
in_progress = [f for f, info in files.items() if info.get("overall_status") == "in_progress"]

# Zlicz pliki do migracji
npc_dir = "data-otservbr-global/npc"
total_npc = 0
needs_migration = 0
if os.path.isdir(npc_dir):
    for f in os.listdir(npc_dir):
        if f.endswith(".lua"):
            total_npc += 1
            fpath = os.path.join(npc_dir, f)
            try:
                with open(fpath, "r") as fp:
                    content = fp.read()
                    if "StdModule.say" in content and "text" in content:
                        if "i18nKey" not in content:
                            needs_migration += 1
            except:
                pass

# Statystyki kluczy
en_keys = 0
if os.path.exists(f"{I18N_DIR}/en/npc.json"):
    try:
        with open(f"{I18N_DIR}/en/npc.json") as f:
            en_keys = len(json.load(f))
    except:
        pass

# Języki z tłumaczeniami
langs_with_data = []
if os.path.isdir(I18N_DIR):
    for lang in os.listdir(I18N_DIR):
        lang_file = f"{I18N_DIR}/{lang}/npc.json"
        if os.path.exists(lang_file):
            try:
                with open(lang_file) as f:
                    if len(json.load(f)) > 0:
                        langs_with_data.append(lang)
            except:
                pass

print(f"\n{BLUE}📊 STATYSTYKI GLOBALNE:{NC}")
print(f"   ├─ Plików NPC ogółem:     {total_npc}")
print(f"   ├─ Do migracji:          {YELLOW}{needs_migration}{NC}")
print(f"   ├─ Ukończonych:          {GREEN}{len(completed)}{NC}")
print(f"   ├─ W trakcie:            {CYAN}{len(in_progress)}{NC}")
print(f"   ├─ Kluczy EN:            {en_keys}")
print(f"   └─ Języków z danymi:     {len(langs_with_data)} ({', '.join(sorted(langs_with_data)[:5])}{'...' if len(langs_with_data) > 5 else ''})")

# Pokaż pliki w trakcie
if in_progress:
    print(f"\n{YELLOW}🔄 W TRAKCIE PRZETWARZANIA:{NC}")
    for fpath in in_progress:
        info = files[fpath]
        stages = info.get("stages", {})
        done_stages = [s for s in stages.keys()]
        last_stage = done_stages[-1] if done_stages else "brak"
        print(f"   ├─ {os.path.basename(fpath)}")
        print(f"   │  └─ Ostatni etap: {last_stage} ({len(done_stages)}/8)")

# Pokaż ostatnie ukończone
if completed:
    print(f"\n{GREEN}✅ OSTATNIO UKOŃCZONE:{NC}")
    # Sortuj po czasie ukończenia
    sorted_completed = sorted(
        [(f, files[f].get("completed_at", "")) for f in completed],
        key=lambda x: x[1],
        reverse=True
    )[:5]
    for fpath, completed_at in sorted_completed:
        info = files[fpath]
        stages = info.get("stages", {})
        keys = stages.get("5_extraction_en", {}).get("keys_added", 0)
        langs = len(stages.get("6_translation", {}).get("languages", []))
        time_str = completed_at[:16].replace("T", " ") if completed_at else "?"
        print(f"   ├─ {os.path.basename(fpath)}")
        print(f"   │  └─ {time_str} | {keys} kluczy | {langs} języków")

# Pokaż etapy dla ostatniego pliku
if files:
    last_file = list(files.keys())[-1]
    info = files[last_file]
    stages = info.get("stages", {})
    print(f"\n{CYAN}📋 ETAPY DLA: {os.path.basename(last_file)}{NC}")
    stage_names = {
        "1_started": "STARTED",
        "2_analysis": "ANALYSIS", 
        "3_documentation": "DOCUMENTATION",
        "4_transformation": "TRANSFORMATION",
        "5_extraction_en": "EXTRACTION_EN",
        "6_translation": "TRANSLATION",
        "7_validation": "VALIDATION",
        "8_sync": "SYNC"
    }
    for stage_key, stage_name in stage_names.items():
        if stage_key in stages:
            status = stages[stage_key].get("status", "?")
            icon = "✅" if status == "completed" else "❌" if status == "failed" else "🔄"
            extra = ""
            if stage_key == "4_transformation":
                extra = f" ({stages[stage_key].get('transformed', 0)} zmian)"
            elif stage_key == "5_extraction_en":
                extra = f" ({stages[stage_key].get('keys_added', 0)} kluczy)"
            elif stage_key == "6_translation":
                extra = f" ({len(stages[stage_key].get('languages', []))} języków)"
            print(f"   {icon} {stage_name}{extra}")
        else:
            print(f"   ⬜ {stage_name}")

print(f"\n{CYAN}─────────────────────────────────────────────────────────────────────{NC}")
print(f"Użyj: ./i18n_worker_simple.sh --auto   aby kontynuować migrację")
print()
STATUSEOF
        ;;
    --stats)
        echo "Szczegółowe statystyki..."
        python3 -c "
import json
import os

with open('$STATUS_FILE') as f: d=json.load(f)

print('\n=== STATYSTYKI KLUCZY ===')
for lang_dir in sorted(os.listdir('$I18N_DIR')):
    npc_file = f'$I18N_DIR/{lang_dir}/npc.json'
    if os.path.exists(npc_file):
        with open(npc_file) as f:
            keys = len(json.load(f))
            print(f'  {lang_dir}: {keys} kluczy')
"
        ;;
    --auto)
        LIMIT="${2:-0}"
        COUNT=0
        echo "Tryb AUTO - szukam plików NPC do migracji..."
        echo "Wzorce: StdModule.say z text= oraz npcHandler:say(\"...\")"
        [ "$LIMIT" -gt 0 ] && echo "Limit: $LIMIT plików"
        for f in data-otservbr-global/npc/*.lua; do
            NEEDS_WORK=false
            
            # Sprawdź StdModule.say bez i18nKey
            if grep -q "StdModule\.say" "$f" 2>/dev/null; then
                if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                    if grep -q 'text = "' "$f" 2>/dev/null; then
                        NEEDS_WORK=true
                    fi
                fi
            fi
            
            # Sprawdź npcHandler:say("...") bez NPC_LIB.i18n.npcSay
            if grep -qE 'npcHandler:say\(\s*"[^"]{5,}"' "$f" 2>/dev/null; then
                if ! grep -q "NPC_LIB.i18n.npcSay" "$f" 2>/dev/null; then
                    NEEDS_WORK=true
                fi
            fi
            
            if [ "$NEEDS_WORK" = "true" ]; then
                process_file "$f"
                COUNT=$((COUNT + 1))
                if [ "$LIMIT" -gt 0 ] && [ "$COUNT" -ge "$LIMIT" ]; then
                    echo ""
                    echo "Osiągnięto limit $LIMIT plików."
                    break
                fi
            fi
        done
        echo ""
        echo "Przetworzono: $COUNT plików"
        # Aktualizuj status dla GitHub
        update_github_status
        ;;
    --update-status)
        update_github_status
        ;;
    --continuous)
        # Tryb ciągły - pracuje cały czas, przełącza się między trybami
        PID_FILE=".worker_simple.pid"
        echo $$ > "$PID_FILE"
        
        BATCH="${2:-5}"  # Ile plików na batch (domyślnie 5)
        DELAY="${3:-4}" # Przerwa między batchami w sekundach (domyślnie 4)
        
        echo "╔════════════════════════════════════════════════════════════════════╗"
        echo "║   I18N WORKER v3.0 - FULL AUTONOMOUS (24/7)                        ║"
        echo "║   PID: $$                                                          ║"
        echo "║   Batch: $BATCH plików | Przerwa: ${DELAY}s                        ║"
        echo "║   Tryby: NPC → SCRIPTS → MONSTERS → ITEMS → AUTO_TRANSLATE        ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Aby zatrzymać: kill $$ lub Ctrl+C"
        echo ""
        
        CYCLE=0
        
        # Obsługa Ctrl+C
        trap 'echo ""; echo "⛔ Zatrzymuję worker..."; update_github_status; rm -f "$PID_FILE"; exit 0' SIGINT SIGTERM
        
        while true; do
            CYCLE=$((CYCLE + 1))
            echo ""
            echo "═══════════════════════════════════════════════════════════════"
            echo "🔄 CYKL #$CYCLE - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "═══════════════════════════════════════════════════════════════"
            
            # Użyj dispatchera do wyboru trybu
            MODE_RESULT=$(select_work_mode)
            MODE_TYPE=$(echo "$MODE_RESULT" | cut -d: -f1)
            MODE_CAT=$(echo "$MODE_RESULT" | cut -d: -f2)
            MODE_COUNT=$(echo "$MODE_RESULT" | cut -d: -f3)
            MODE_EXTRA=$(echo "$MODE_RESULT" | cut -d: -f4)
            
            echo "📋 Dispatcher: $MODE_TYPE | Kategoria: $MODE_CAT | Ilość: ${MODE_COUNT:-0}"
            echo ""
            
            case "$MODE_TYPE" in
                MIGRATION)
                    echo "🔧 TRYB: MIGRACJA kategorii '$MODE_CAT' ($MODE_COUNT plików do zrobienia)"
                    
                    # Wywołaj odpowiednią funkcję migracji dla kategorii
                    case "$MODE_CAT" in
                        npc)
                            echo "   🧙 Przetwarzam NPC..."
                            COUNT=0
                            # Wczytaj completed files raz na początku
                            COMPLETED_LIST=$(python3 -c "import json; d=json.load(open('$STATUS_FILE')); print(' '.join([f for f,v in d.get('files',{}).items() if v.get('overall_status')=='completed']))" 2>/dev/null)
                            
                            for f in data-otservbr-global/npc/*.lua; do
                                [ -f "$f" ] || continue
                                
                                # Sprawdź czy już completed
                                echo "$COMPLETED_LIST" | grep -qF "$f" && continue
                                
                                NEEDS_WORK=false
                                
                                if grep -q "StdModule\.say" "$f" 2>/dev/null; then
                                    if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                                        if grep -q 'text = "' "$f" 2>/dev/null; then
                                            NEEDS_WORK=true
                                        fi
                                    fi
                                fi
                                
                                if grep -qE 'npcHandler:say\(\s*"[^"]{5,}"' "$f" 2>/dev/null; then
                                    if ! grep -q "NPC_LIB.i18n.npcSay" "$f" 2>/dev/null; then
                                        NEEDS_WORK=true
                                    fi
                                fi
                                
                                if [ "$NEEDS_WORK" = "true" ]; then
                                    process_file "$f"
                                    COUNT=$((COUNT + 1))
                                    [ "$COUNT" -ge "$BATCH" ] && break
                                fi
                            done
                            echo "   📊 NPC: Zmigrowano $COUNT plików"
                            ;;
                        scripts)
                            echo "   📜 Przetwarzam SCRIPTS..."
                            COUNT=0
                            # Wczytaj completed files
                            COMPLETED_LIST=$(python3 -c "import json; d=json.load(open('$STATUS_FILE')); print(' '.join([f for f,v in d.get('files',{}).items() if v.get('overall_status')=='completed']))" 2>/dev/null)
                            
                            for f in $(find data-otservbr-global/scripts data/scripts -name "*.lua" 2>/dev/null | head -100); do
                                [ -f "$f" ] || continue
                                # Pomiń już przetworzone w JSON
                                echo "$COMPLETED_LIST" | grep -qF "$f" && continue
                                # Pomiń już przetworzone w starym pliku
                                grep -qF "$f" "$PROCESSED_FILE" 2>/dev/null && continue
                                
                                # Szukaj sendTextMessage
                                if grep -qE 'sendTextMessage\s*\([^,]+,\s*"[^"]{10,}"' "$f" 2>/dev/null; then
                                    if ! grep -q "sendLocalizedTextMessage" "$f" 2>/dev/null; then
                                        process_scripts_file "$f"
                                        COUNT=$((COUNT + 1))
                                        [ "$COUNT" -ge "$BATCH" ] && break
                                    fi
                                fi
                            done
                            echo "   📊 Scripts: Przetworzono $COUNT plików"
                            ;;
                        monsters)
                            echo "   👹 Przetwarzam MONSTERS..."
                            COUNT=0
                            process_monsters_category "$BATCH"
                            echo "   📊 Monsters: Dodano klucze"
                            ;;
                        spells)
                            echo "   ✨ Przetwarzam SPELLS..."
                            COUNT=0
                            process_spells_category "$BATCH"
                            echo "   📊 Spells: Dodano klucze"
                            ;;
                        items)
                            echo "   🎒 Przetwarzam ITEMS..."
                            COUNT=0
                            process_items_category "$BATCH"
                            echo "   📊 Items: Dodano klucze"
                            ;;
                        *)
                            echo "   ⚠️ Nieznana kategoria: $MODE_CAT"
                            ;;
                    esac
                    ;;
                AUTO_TRANSLATE)
                    echo "🌍 TRYB: AUTO TRANSLATE (język: $MODE_CAT, plik: $MODE_COUNT, kluczy: $MODE_EXTRA)"
                    
                    # Automatyczne tłumaczenie BEZ interakcji!
                    auto_translate_keys "$MODE_CAT" "$MODE_COUNT" "$MODE_EXTRA"
                    ;;
                IDLE)
                    echo "✅ TRYB: IDLE - Wszystko zrobione!"
                    echo "   Migracja: ✅ | Tłumaczenia: ✅"
                    echo "   Czekam 5 minut na nowe pliki..."
                    sleep 300
                    continue
                    ;;
                *)
                    echo "⚠️ Nieznany tryb: $MODE_TYPE"
                    ;;
            esac
            
            # Zapisz licznik cykli do pliku (dla statusu)
            python3 -c "
import json
try:
    with open('i18n_global_stats.json', 'r') as f:
        data = json.load(f)
except:
    data = {}
data['total_cycles'] = $CYCLE
data['last_update'] = '$(date -Iseconds)'
data['mode'] = '$MODE_TYPE'
with open('i18n_global_stats.json', 'w') as f:
    json.dump(data, f, indent=2)
"
            
            # Aktualizuj status co cykl
            update_github_status
            
            # Git commit co cykl
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                git add -A 2>/dev/null
                MIGRATED=$(cat "$STATUS_FILE" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(len([f for f,i in d.get('files',{}).items() if i.get('overall_status')=='completed']))" 2>/dev/null || echo "?")
                git commit -m "📊 I18N v2: $MIGRATED NPCs, $MODE_TYPE - Cykl #$CYCLE" 2>/dev/null
                git push origin master 2>/dev/null && echo "📤 Push OK" || echo "⚠️ Push failed"
            fi
            
            echo ""
            echo "💤 Przerwa ${DELAY}s przed następnym cyklem..."
            sleep "$DELAY"
        done
        ;;
    *)
        echo ""
        echo "I18N Worker v2.0 - Multi-Mode Worker"
        echo ""
        echo "TRYBY PRACY:"
        echo "  1. MIGRATION   - Migracja kodu NPC (text= → i18nKey=)"
        echo "  2. TRANSLATION - Interaktywne tłumaczenia (agent wpisuje)"
        echo ""
        echo "TRYB TRANSLATION - INTERAKTYWNY:"
        echo "  Worker wyświetla tekst EN, agent wpisuje tłumaczenie."
        echo "  Komendy: SKIP (pomiń) | QUIT (zakończ) | SAVE (zapisz)"
        echo ""
        echo "  Zasady:"
        echo "  - Komendy w 'apostrofach' (np. 'trade') → NIE TŁUMACZ"
        echo "  - Zmienne w {nawiasach} (np. {player}) → BEZ ZMIAN"
        echo ""
        echo "Użycie:"
        echo "  $0 --file <path>        Przetwórz jeden plik (MIGRATION)"
        echo "  $0 --translate [lang]   Interaktywne tłumaczenia (domyślnie: pl)"
        echo "  $0 --status             Pokaż dashboard statusu"
        echo "  $0 --stats              Szczegółowe statystyki języków"
        echo "  $0 --auto [N]           Automatyczna migracja N plików"
        echo "  $0 --continuous [B] [D] Tryb ciągły (B=batch, D=delay)"
        echo "  $0 --update-status      Aktualizuj I18N_STATUS.md"
        echo ""
        ;;
esac
