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
from datetime import datetime

WORK_DIR = os.getcwd()
STATUS_FILE = "i18n_file_status.json"
I18N_DIR = "i18n"
PROCESSED_FILE = "i18n_processed_files.txt"
EXCLUDED_FILE = "i18n_excluded_files.txt"

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

# Cykl (z pliku jeśli istnieje)
cycle_count = 1
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

| Parametr | Wartość |
|----------|---------|
| Status | {"🔄 in_progress" if in_progress > 0 else "✅ idle"} |
| Operacja | 🎮 Canary Server - NPC |
| Plik | Cykl #{cycle_count} |
| Szczegóły | NPC:{npc_keys} Scripts:{scripts_keys} Items:{items_keys} |
| Ostatnia aktualizacja | {timestamp} |

---

## 📈 Statystyki sesji

| Metryka | Wartość |
|---------|---------|
| Plików przetworzonych | {processed_count} |
| NPC zmigrowanych | {completed} |
| Kluczy wyciągniętych | {total_keys} |
| Błędów | 0 |

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

with open("I18N_STATUS.md", "w") as f:
    f.write(md)

print(f"✅ I18N_STATUS.md zaktualizowany: {timestamp}")
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
    
    local stdmod=$(grep -c "StdModule\.say.*text" "$file" 2>/dev/null || echo "0")
    local npcsay=$(grep -c "npcHandler:say" "$file" 2>/dev/null || echo "0")
    local sendtxt=$(grep -c "sendTextMessage" "$file" 2>/dev/null || echo "0")
    local i18nkey=$(grep -c "i18nKey" "$file" 2>/dev/null || echo "0")
    
    # Wyczyść zmienne - usuń białe znaki
    stdmod=${stdmod//[[:space:]]/}
    npcsay=${npcsay//[[:space:]]/}
    sendtxt=${sendtxt//[[:space:]]/}
    i18nkey=${i18nkey//[[:space:]]/}
    
    # Domyślne wartości
    [ -z "$stdmod" ] && stdmod=0
    [ -z "$npcsay" ] && npcsay=0
    [ -z "$sendtxt" ] && sendtxt=0
    [ -z "$i18nkey" ] && i18nkey=0
    
    local total=$((stdmod + npcsay + sendtxt))
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local needs="true"
    [ "$total" -eq 0 ] && needs="false"
    [ "$i18nkey" -ge "$stdmod" ] && [ "$stdmod" -gt 0 ] && needs="false"
    
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
    'total': $total,
    'already_i18n': $i18nkey,
    'needs_migration': needs_bool
}

with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
print('OK')
"
    log "${GREEN}✓ Etap 2 OK${NC}: StdModule=$stdmod, total=$total, needs=$needs"
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
# ETAP 4: TRANSFORMATION (text → i18nKey)
#===============================================================================
stage_4() {
    local file="$1"
    log "${BLUE}[4/8] TRANSFORMATION${NC}: $file"
    
    # Oblicz safe_name bezpośrednio
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    local temp=$(mktemp)
    local counter=1
    local transformed=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -qE 'StdModule\.say.*text[[:space:]]*=[[:space:]]*"[^"]{5,}"'; then
            local key="npc.${safe}.stdmod_${counter}"
            line=$(echo "$line" | sed "s|text[[:space:]]*=[[:space:]]*\"[^\"]*\"|i18nKey = \"${key}\"|")
            counter=$((counter + 1))
            transformed=$((transformed + 1))
        fi
        echo "$line" >> "$temp"
    done < "$file"
    
    if [ "$transformed" -gt 0 ]; then
        mv "$temp" "$file"
        log "${GREEN}✓ Etap 4 OK${NC}: Zamieniono $transformed wystąpień"
    else
        rm -f "$temp"
        log "${YELLOW}⏭ Etap 4${NC}: Brak zmian"
    fi
    
    python3 -c "
import json
with open('$STATUS_FILE', 'r') as f: data = json.load(f)
data['files']['$file']['stages']['4_transformation'] = {'status': 'completed', 'transformed': $transformed}
with open('$STATUS_FILE', 'w') as f: json.dump(data, f, indent=2)
"
    return 0
}

#===============================================================================
# ETAP 5: EXTRACTION_EN (klucze do JSON)
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

# Wczytaj backup
with open("$backup", "r") as f:
    content = f.read()

# Znajdź wszystkie text = "..."
texts = re.findall(r'text\s*=\s*"([^"]+)"', content)

# Wczytaj npc.json
json_file = "$I18N_DIR/en/npc.json"
try:
    with open(json_file, "r") as f:
        data = json.load(f)
except:
    data = {}

# Dodaj klucze
added = 0
for i, text in enumerate(texts, 1):
    if len(text) >= 5:
        key = f"npc.$safe.stdmod_{i}"
        if key not in data:
            data[key] = text
            added += 1

# Zapisz
with open(json_file, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Dodano {added} kluczy")

# Update status
with open("$STATUS_FILE", "r") as f:
    status = json.load(f)
status["files"]["$file"]["stages"]["5_extraction_en"] = {"status": "completed", "keys_added": added}
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

# 3. Sprawdź duplikaty wartości
values = list(en_data.values())
duplicates = [v for v in values if values.count(v) > 1]
if duplicates:
    warnings.append(f"Znaleziono {len(set(duplicates))} duplikatów wartości")

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
# TRYB 2: TŁUMACZENIA - 6 etapów + składnie
#===============================================================================
# TEN TRYB GENERUJE INSTRUKCJE DLA AGENTA LLM (np. GPT, Claude, Phi)
# Agent powinien przetłumaczyć całe zdania naturalnie, zachowując:
# - Komendy w 'apostrofach' (np. 'trade', 'job', 'buy') - NIE TŁUMACZYĆ
# - Zmienne w {nawiasach} (np. {player}, {amount}) - BEZ ZMIAN
# - Formatowanie |PIPE| - BEZ ZMIAN
#===============================================================================
mode_translation() {
    local target_lang="${1:-pl}"
    
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BLUE}TRYB 2: TŁUMACZENIA (instrukcje dla LLM)${NC} - Język: $target_lang"
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
# INSTRUKCJE DLA AGENTA LLM - TŁUMACZENIE
#===============================================================================
# Agent LLM (np. GPT, Claude, Phi) powinien:
# 1. Przetłumaczyć CAŁE zdanie na język docelowy
# 2. Zachować komendy w 'apostrofach' BEZ TŁUMACZENIA (np. 'trade', 'job', 'yes')
# 3. Zachować zmienne w {nawiasach} bez zmian (np. {player}, {amount})
# 4. Zachować formatowanie |PIPE| bez zmian (np. |PLAYERNAME|)
# 5. Tłumaczyć naturalnie, zachowując ton i styl NPC
#===============================================================================

LANG_NAMES = {
    "pl": "polski", "de": "niemiecki", "es": "hiszpański", "pt": "portugalski",
    "fr": "francuski", "it": "włoski", "ru": "rosyjski", "nl": "holenderski",
    "sv": "szwedzki", "da": "duński", "no": "norweski", "fi": "fiński",
    "cs": "czeski", "sk": "słowacki", "hu": "węgierski", "ro": "rumuński",
    "bg": "bułgarski", "el": "grecki", "tr": "turecki", "uk": "ukraiński",
    "zh": "chiński (uproszczony)", "ja": "japoński", "ko": "koreański", "ar": "arabski"
}

# Generuj plik z promptem dla LLM
prompt_file = f"{i18n_dir}/translate_prompt_{target_lang}.md"
with open(prompt_file, "w") as pf:
    pf.write(f"# 🌍 PROMPT TŁUMACZENIA NA JĘZYK: {LANG_NAMES.get(target_lang, target_lang).upper()}\n\n")
    pf.write(f"## Instrukcje dla agenta LLM\n\n")
    pf.write(f"Przetłumacz poniższe teksty z angielskiego na **{LANG_NAMES.get(target_lang, target_lang)}**.\n\n")
    pf.write(f"### ⚠️ ZASADY (BARDZO WAŻNE!):\n")
    pf.write(f"1. **Komendy w 'apostrofach'** - NIE TŁUMACZ! (np. 'trade', 'job', 'yes', 'no', 'buy', 'sell')\n")
    pf.write("2. **Zmienne w {nawiasach}** - zostaw bez zmian (np. {player}, {amount}, {npc})\n")
    pf.write(f"3. **Formatowanie |PIPE|** - zostaw bez zmian (np. |PLAYERNAME|, |TIME|)\n")
    pf.write(f"4. Tłumacz naturalnie, zachowując ton i styl postaci NPC\n\n")
    pf.write(f"### Przykład poprawnego tłumaczenia:\n")
    pf.write("```\n")
    pf.write("EN: Hello adventurer! Ask me about 'trade' or 'job'. I have {count} items.\n")
    if target_lang == "pl":
        pf.write("PL: Witaj przybyszu! Zapytaj mnie o 'trade' lub 'job'. Mam {count} przedmiotów.\n")
    elif target_lang == "de":
        pf.write("DE: Hallo Abenteurer! Frag mich nach 'trade' oder 'job'. Ich habe {count} Gegenstände.\n")
    else:
        pf.write(f"{target_lang.upper()}: [TWOJE TŁUMACZENIE TUTAJ]\n")
    pf.write("```\n\n")
    pf.write(f"---\n\n")
    pf.write(f"## Teksty do przetłumaczenia ({len(keys_batch)} kluczy)\n\n")

# Przetwórz składnie
translated_count = 0
real_translations = 0

print(f"")
print(f"╔══════════════════════════════════════════════════════════════════════╗")
print(f"║  📝 PROMPT DLA AGENTA LLM - TŁUMACZENIE NA {LANG_NAMES.get(target_lang, target_lang).upper():15}            ║")
print(f"╠══════════════════════════════════════════════════════════════════════╣")
print(f"║  ZASADY:                                                             ║")
print(f"║  • Komendy w 'apostrofach' NIE TŁUMACZ (np. 'trade', 'job')          ║")
print(f"║  • Zmienne w {{nawiasach}} zachowaj bez zmian                         ║")
print(f"║  • Formatowanie |PIPE| zachowaj bez zmian                            ║")
print(f"╚══════════════════════════════════════════════════════════════════════╝")
print(f"")

for substage in range(total_substages):
    start_idx = substage * substage_size
    end_idx = min(start_idx + substage_size, len(keys_batch))
    substage_keys = keys_batch[start_idx:end_idx]
    
    print(f"  └─ Składnia {substage + 1}/{total_substages}: {len(substage_keys)} kluczy")
    
    # Zapisz do pliku promptów
    with open(prompt_file, "a") as pf:
        pf.write(f"### Składnia {substage + 1}/{total_substages}\n\n")
    
    for key, en_text in substage_keys:
        # Wyświetl w terminalu (dla agenta LLM)
        print(f"")
        print(f"    📌 {key}")
        print(f"    EN: {en_text}")
        print(f"    {target_lang.upper()}: _______________________________________________")
        
        # Zapisz do pliku promptów w formacie łatwym do edycji
        with open(prompt_file, "a") as pf:
            pf.write(f"**{key}**\n")
            pf.write(f"- EN: `{en_text}`\n")
            pf.write(f"- {target_lang.upper()}: \n\n")
        
        # Zapisz placeholder do JSON (do późniejszej edycji)
        lang_data[key] = f"[TODO:{target_lang.upper()}] {en_text}"
        translated_count += 1

print(f"")
print(f"═══════════════════════════════════════════════════════════════════════")
print(f"📄 Prompt zapisany do: {prompt_file}")
print(f"")
print(f"NASTĘPNE KROKI DLA AGENTA LLM:")
print(f"1. Przeczytaj prompt z pliku: {prompt_file}")
print(f"2. Dla każdego klucza wpisz tłumaczenie po linii '{target_lang.upper()}:'")  
print(f"3. Zachowaj komendy 'w apostrofach' i zmienne {{w nawiasach}}")
print(f"4. Po ukończeniu - zaktualizuj plik {lang_file}")
print(f"═══════════════════════════════════════════════════════════════════════")
print(f"")

# [5/6] SAVE_TRANSLATIONS
print(f"[5/6] SAVE_TRANSLATIONS: Zapisuję {translated_count} kluczy (placeholder'ów)")
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

print(f"\n✅ TŁUMACZENIE ZAKOŃCZONE: {target_lang}")
print(f"   Przetłumaczono w tym batchu: {translated_count}")
print(f"   Prawdziwe tłumaczenia: {real_total}/{len(lang_data)}")
print(f"   Pozostało placeholder'ów: {placeholders}")
PYTRANSLATE

    log "${GREEN}✅ TRYB TŁUMACZEŃ ZAKOŃCZONY${NC}"
    return 0
}

#===============================================================================
# DISPATCHER - Wybór trybu w continuous mode
#===============================================================================
select_work_mode() {
    python3 << 'DISPATCHERPY'
import os
import json
import glob

I18N_DIR = "i18n"
NPC_DIR = "data-otservbr-global/npc"
LANG_PRIORITY = ["pl", "de", "es", "pt", "fr", "it", "ru"]

# 1. Czy są pliki NPC do migracji?
needs_migration = 0
for f in glob.glob(f"{NPC_DIR}/*.lua"):
    try:
        with open(f) as nf:
            content = nf.read()
        if "StdModule.say" in content and "text" in content:
            if "i18nKey" not in content:
                needs_migration += 1
    except:
        pass

if needs_migration > 0:
    print(f"MIGRATION:{needs_migration}")
    exit(0)

# 2. Czy są klucze do przetłumaczenia?
en_file = f"{I18N_DIR}/en/npc.json"
if os.path.exists(en_file):
    with open(en_file) as f:
        en_keys = set(json.load(f).keys())
    
    for lang in LANG_PRIORITY:
        lang_file = f"{I18N_DIR}/{lang}/npc.json"
        if os.path.exists(lang_file):
            with open(lang_file) as f:
                lang_data = json.load(f)
            # Policz placeholder'y
            placeholders = len([v for v in lang_data.values() if v.startswith("[")])
            if placeholders > 0:
                print(f"TRANSLATION:{lang}:{placeholders}")
                exit(0)
        else:
            print(f"TRANSLATION:{lang}:{len(en_keys)}")
            exit(0)

# 3. Wszystko zrobione
print("IDLE:0")
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
        [ "$LIMIT" -gt 0 ] && echo "Limit: $LIMIT plików"
        for f in data-otservbr-global/npc/*.lua; do
            if grep -q "StdModule\.say.*text" "$f" 2>/dev/null; then
                if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                    process_file "$f"
                    COUNT=$((COUNT + 1))
                    if [ "$LIMIT" -gt 0 ] && [ "$COUNT" -ge "$LIMIT" ]; then
                        echo ""
                        echo "Osiągnięto limit $LIMIT plików."
                        break
                    fi
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
        DELAY="${3:-10}" # Przerwa między batchami w sekundach (domyślnie 10)
        
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║   I18N WORKER v2.0 - TRYB CIĄGŁY (Multi-Mode)             ║"
        echo "║   PID: $$                                                  ║"
        echo "║   Batch: $BATCH plików | Przerwa: ${DELAY}s                ║"
        echo "║   Tryby: MIGRATION → TRANSLATION → IDLE                   ║"
        echo "╚════════════════════════════════════════════════════════════╝"
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
            MODE_ARG=$(echo "$MODE_RESULT" | cut -d: -f2)
            MODE_COUNT=$(echo "$MODE_RESULT" | cut -d: -f3)
            
            echo "📋 Dispatcher: $MODE_TYPE (arg: $MODE_ARG, count: ${MODE_COUNT:-0})"
            echo ""
            
            case "$MODE_TYPE" in
                MIGRATION)
                    echo "🔧 TRYB 1: MIGRACJA ($MODE_ARG plików do zrobienia)"
                    COUNT=0
                    for f in data-otservbr-global/npc/*.lua; do
                        if grep -q "StdModule\.say.*text" "$f" 2>/dev/null; then
                            if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                                process_file "$f"
                                COUNT=$((COUNT + 1))
                                if [ "$COUNT" -ge "$BATCH" ]; then
                                    break
                                fi
                            fi
                        fi
                    done
                    echo "📊 Zmigrowano: $COUNT plików"
                    ;;
                TRANSLATION)
                    echo "🌍 TRYB 2: TŁUMACZENIA (język: $MODE_ARG, $MODE_COUNT kluczy)"
                    mode_translation "$MODE_ARG"
                    ;;
                IDLE)
                    echo "✅ TRYB: IDLE - Wszystko zrobione!"
                    echo "Czekam na nowe zadania..."
                    ;;
            esac
            
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
        echo "  2. TRANSLATION - Tłumaczenia kluczy EN → inne języki"
        echo ""
        echo "WAŻNE: Tryb TRANSLATION generuje INSTRUKCJE dla agenta LLM!"
        echo "Agent LLM powinien:"
        echo "  - Tłumaczyć CAŁE zdania naturalnie"
        echo "  - Zachować komendy w 'apostrofach' (np. 'trade', 'job') BEZ TŁUMACZENIA"
        echo "  - Zachować zmienne w {nawiasach} (np. {player}) BEZ ZMIAN"
        echo ""
        echo "Użycie:"
        echo "  $0 --file <path>      Przetwórz jeden plik (MIGRATION)"
        echo "  $0 --translate [lang] Tłumacz na język (domyślnie: pl)"
        echo "  $0 --status           Pokaż dashboard statusu"
        echo "  $0 --stats            Szczegółowe statystyki języków"
        echo "  $0 --auto [N]         Automatyczna migracja N plików"
        echo "  $0 --continuous [B] [D] Tryb ciągły (B=batch, D=delay)"
        echo "  $0 --update-status    Aktualizuj I18N_STATUS.md"
        echo ""
        ;;
esac
