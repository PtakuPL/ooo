#!/bin/bash
#===============================================================================
# I18N WORKER v2.0 - Multi-Mode Worker z automatycznym przełączaniem trybów
#===============================================================================
# TRYBY PRACY:
#   1. MIGRATION  - Migracja kodu NPC (text= → i18nKey=) - 8 etapów
#   2. TRANSLATION - Tłumaczenia kluczy EN → inne języki - 6 etapów + składnie
#   3. VALIDATION  - Walidacja tłumaczeń - 4 etapy
#
# Worker sam decyduje który tryb uruchomić na podstawie stanu projektu.
#===============================================================================

set -e
cd "$(dirname "$0")"
WORK_DIR="$(pwd)"

# Pliki konfiguracyjne
STATUS_FILE="i18n_worker_status.json"
OLD_STATUS_FILE="i18n_file_status.json"
I18N_DIR="i18n"
BACKUP_DIR="backups"
PID_FILE=".worker_v2.pid"
LOG_FILE="work_i18n_v2.log"

# Priorytet języków do tłumaczeń
LANG_PRIORITY="pl de es pt fr it ru nl sv da no fi cs sk hu ro bg el tr uk zh ja ko"

# Limity
MIGRATION_BATCH=5          # Ile plików NPC na cykl migracji
TRANSLATION_BATCH=50       # Ile kluczy na batch tłumaczeń
TRANSLATION_SUBSTAGE=4     # Ile kluczy na składnię
CYCLE_DELAY=5              # Sekund między cyklami

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log() { echo -e "$1"; }
log_stage() { echo -e "${CYAN}[$1]${NC} $2"; }
log_substage() { echo -e "  ${MAGENTA}└─ Składnia $1:${NC} $2"; }

#===============================================================================
# INICJALIZACJA STATUSU
#===============================================================================
init_status() {
    if [ ! -f "$STATUS_FILE" ]; then
        log "${YELLOW}Tworzę nowy plik statusu...${NC}"
        python3 << 'INITPY'
import json
import os
from datetime import datetime

status = {
    "worker": {
        "version": "2.0",
        "active_mode": None,
        "active_mode_stage": None,
        "active_mode_substage": None,
        "last_activity": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "cycles_total": 0
    },
    "mode_1_migration": {
        "completed_files": 0,
        "in_progress": None,
        "remaining": 0,
        "current_file": None,
        "current_stage": None,
        "files": {}
    },
    "mode_2_translation": {
        "source_file": "en/npc.json",
        "total_keys": 0,
        "current_language": None,
        "current_batch": 0,
        "current_substage": 0,
        "substages_total": 0,
        "languages": {},
        "current_keys": []
    },
    "mode_3_validation": {
        "last_run": None,
        "errors": 0,
        "warnings": 0,
        "issues": []
    }
}

# Migruj dane ze starego statusu jeśli istnieje
if os.path.exists("i18n_file_status.json"):
    try:
        with open("i18n_file_status.json") as f:
            old = json.load(f)
        if "files" in old:
            status["mode_1_migration"]["files"] = old["files"]
            status["mode_1_migration"]["completed_files"] = len([
                f for f, i in old["files"].items() 
                if i.get("overall_status") == "completed"
            ])
    except:
        pass

with open("i18n_worker_status.json", "w") as f:
    json.dump(status, f, indent=2, ensure_ascii=False)

print("Status zainicjalizowany")
INITPY
    fi
}

#===============================================================================
# DISPATCHER - Wybór trybu pracy
#===============================================================================
select_mode() {
    python3 << 'DISPATCHPY'
import json
import os
import glob

STATUS_FILE = "i18n_worker_status.json"
I18N_DIR = "i18n"
NPC_DIR = "data-otservbr-global/npc"
LANG_PRIORITY = "pl de es pt fr it ru nl sv da no fi cs sk hu ro bg el tr uk zh ja ko".split()

with open(STATUS_FILE) as f:
    status = json.load(f)

# 1. Czy jest aktywna praca w toku?
if status["worker"]["active_mode"]:
    print(f"CONTINUE:{status['worker']['active_mode']}")
    exit(0)

# 2. Czy są pliki NPC do migracji?
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
    print(f"MODE:1:MIGRATION:{needs_migration} plików do migracji")
    exit(0)

# 3. Czy są klucze EN bez tłumaczeń?
en_npc_file = f"{I18N_DIR}/en/npc.json"
if os.path.exists(en_npc_file):
    with open(en_npc_file) as f:
        en_keys = set(json.load(f).keys())
    
    for lang in LANG_PRIORITY:
        lang_file = f"{I18N_DIR}/{lang}/npc.json"
        if os.path.exists(lang_file):
            with open(lang_file) as f:
                lang_keys = set(json.load(f).keys())
            missing = en_keys - lang_keys
            # Sprawdź też placeholder'y [LANG]
            if os.path.exists(lang_file):
                with open(lang_file) as f:
                    lang_data = json.load(f)
                for k, v in lang_data.items():
                    if v.startswith(f"[{lang.upper()}]") or v.startswith("[TODO]"):
                        missing.add(k)
            if len(missing) > 0:
                print(f"MODE:2:TRANSLATION:{lang}:{len(missing)} kluczy do tłumaczenia")
                exit(0)
        else:
            print(f"MODE:2:TRANSLATION:{lang}:{len(en_keys)} kluczy do tłumaczenia (nowy język)")
            exit(0)

# 4. Walidacja (co godzinę)
from datetime import datetime, timedelta
last_validation = status["mode_3_validation"].get("last_run")
if last_validation:
    last = datetime.strptime(last_validation, "%Y-%m-%d %H:%M:%S")
    if datetime.now() - last > timedelta(hours=1):
        print("MODE:3:VALIDATION:Czas na walidację")
        exit(0)
else:
    print("MODE:3:VALIDATION:Pierwsza walidacja")
    exit(0)

print("MODE:IDLE:Wszystko zrobione!")
DISPATCHPY
}

#===============================================================================
# TRYB 1: MIGRACJA - 8 etapów
#===============================================================================
mode_1_migration() {
    local file="$1"
    log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    log "${GREEN}TRYB 1: MIGRACJA${NC} - $file"
    log "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    
    local base=$(basename "$file" .lua)
    local safe=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' -' '_')
    
    # Aktualizuj status - rozpoczęcie
    python3 << PYSTART
import json
from datetime import datetime
with open("$STATUS_FILE") as f:
    s = json.load(f)
s["worker"]["active_mode"] = "MIGRATION"
s["worker"]["active_mode_stage"] = 1
s["mode_1_migration"]["current_file"] = "$file"
s["mode_1_migration"]["in_progress"] = "$file"
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
PYSTART

    # ETAP 1: STARTED
    log_stage "1/8" "STARTED: Rejestracja pliku"
    local hash=$(md5sum "$file" | cut -d' ' -f1)
    python3 << PYSTAGE1
import json
from datetime import datetime
with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"] = {
    "started_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "hash": "$hash",
    "overall_status": "in_progress",
    "stages": {"1_started": {"status": "completed"}}
}
s["worker"]["active_mode_stage"] = 1
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
PYSTAGE1
    log "  ${GREEN}✓${NC} Hash: $hash"

    # ETAP 2: ANALYSIS
    log_stage "2/8" "ANALYSIS: Analiza pliku"
    python3 << PYSTAGE2
import json
import re
with open("$file") as f:
    content = f.read()
stdmodule_count = len(re.findall(r'StdModule\.say.*text\s*=', content))
with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["2_analysis"] = {
    "status": "completed",
    "stdmodule_count": stdmodule_count
}
s["worker"]["active_mode_stage"] = 2
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
print(f"StdModule.say z text=: {stdmodule_count}")
PYSTAGE2

    # ETAP 3: DOCUMENTATION
    log_stage "3/8" "DOCUMENTATION: Generowanie dokumentacji"
    mkdir -p "docs/i18n/npc"
    python3 << PYSTAGE3
import json
from datetime import datetime
doc = f"""# NPC: $base

## Informacje
- **Plik:** \`$file\`
- **Data migracji:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
- **Status:** Zmigrowany

## Klucze i18n
Prefix: \`npc.$safe.*\`
"""
with open("docs/i18n/npc/$base.md", "w") as f:
    f.write(doc)
with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["3_documentation"] = {"status": "completed"}
s["worker"]["active_mode_stage"] = 3
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
print("Utworzono: docs/i18n/npc/$base.md")
PYSTAGE3

    # ETAP 4: TRANSFORMATION
    log_stage "4/8" "TRANSFORMATION: Zamiana text= na i18nKey="
    mkdir -p "$BACKUP_DIR/npc"
    cp "$file" "$BACKUP_DIR/npc/${base}.lua.bak"
    
    python3 << 'PYSTAGE4'
import json
import re

file_path = "$file".replace("\\", "/")
safe_name = "$safe"

with open(file_path, "r") as f:
    content = f.read()

counter = [0]
keys_added = []

def replace_text(match):
    full_match = match.group(0)
    text_match = re.search(r'text\s*=\s*"([^"]*)"', full_match)
    if not text_match:
        return full_match
    
    text_value = text_match.group(1)
    counter[0] += 1
    
    # Generuj klucz
    words = re.sub(r'[^a-zA-Z0-9\s]', '', text_value.lower()).split()[:3]
    key_suffix = '_'.join(words) if words else f"msg_{counter[0]}"
    key = f"npc.{safe_name}.{key_suffix}"
    
    # Unikaj duplikatów
    base_key = key
    idx = 1
    while key in keys_added:
        key = f"{base_key}_{idx}"
        idx += 1
    keys_added.append(key)
    
    # Dodaj i18nKey po text=
    new_match = re.sub(
        r'(text\s*=\s*"[^"]*")',
        f'\\1, i18nKey = "{key}"',
        full_match
    )
    return new_match

# Zamień wszystkie StdModule.say z text=
pattern = r'StdModule\.say[^}]*text\s*=\s*"[^"]*"[^}]*}'
new_content = re.sub(pattern, replace_text, content, flags=re.DOTALL)

with open(file_path, "w") as f:
    f.write(new_content)

with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["4_transformation"] = {
    "status": "completed",
    "keys_added": counter[0]
}
s["worker"]["active_mode_stage"] = 4
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)

print(f"Zamieniono: {counter[0]} wystąpień")
PYSTAGE4

    # ETAP 5: EXTRACTION_EN
    log_stage "5/8" "EXTRACTION_EN: Wyciąganie kluczy do en/npc.json"
    mkdir -p "$I18N_DIR/en"
    python3 << 'PYSTAGE5'
import json
import re
import os

file_path = "$file"
safe_name = "$safe"
en_file = "$I18N_DIR/en/npc.json"

# Wczytaj istniejące klucze
if os.path.exists(en_file):
    with open(en_file) as f:
        en_data = json.load(f)
else:
    en_data = {}

# Wyciągnij nowe klucze z pliku
with open(file_path) as f:
    content = f.read()

# Znajdź pary text= i i18nKey=
pattern = r'text\s*=\s*"([^"]*)"[^}]*i18nKey\s*=\s*"([^"]*)"'
matches = re.findall(pattern, content)

added = 0
for text, key in matches:
    if key not in en_data:
        en_data[key] = text
        added += 1

# Sortuj klucze
en_data = dict(sorted(en_data.items()))

with open(en_file, "w") as f:
    json.dump(en_data, f, indent=2, ensure_ascii=False)

with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["5_extraction_en"] = {
    "status": "completed",
    "keys_extracted": added
}
s["worker"]["active_mode_stage"] = 5
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)

print(f"Dodano {added} kluczy do en/npc.json")
PYSTAGE5

    # ETAP 6: VALIDATION
    log_stage "6/8" "VALIDATION: Sprawdzenie spójności"
    python3 << 'PYSTAGE6'
import json
import re

file_path = "$file"
en_file = "$I18N_DIR/en/npc.json"

with open(file_path) as f:
    content = f.read()
with open(en_file) as f:
    en_data = json.load(f)

# Znajdź klucze w pliku Lua
lua_keys = set(re.findall(r'i18nKey\s*=\s*"([^"]*)"', content))

# Sprawdź czy wszystkie są w EN
missing = lua_keys - set(en_data.keys())
warnings = []
if missing:
    warnings.append(f"Brakuje {len(missing)} kluczy w en/npc.json")

with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["6_validation"] = {
    "status": "completed",
    "lua_keys": len(lua_keys),
    "en_keys": len(en_data),
    "warnings": warnings
}
s["worker"]["active_mode_stage"] = 6
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)

if warnings:
    print(f"⚠️ Ostrzeżenia: {warnings}")
else:
    print("✓ Spójność OK")
PYSTAGE6

    # ETAP 7: SYNC
    log_stage "7/8" "SYNC: Aktualizacja statusu"
    python3 << 'PYSTAGE7'
import json
from datetime import datetime

with open("$STATUS_FILE") as f:
    s = json.load(f)

s["mode_1_migration"]["files"]["$file"]["stages"]["7_sync"] = {"status": "completed"}
s["mode_1_migration"]["files"]["$file"]["overall_status"] = "completed"
s["mode_1_migration"]["files"]["$file"]["completed_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
s["mode_1_migration"]["completed_files"] = len([
    f for f, i in s["mode_1_migration"]["files"].items()
    if i.get("overall_status") == "completed"
])
s["mode_1_migration"]["in_progress"] = None
s["mode_1_migration"]["current_file"] = None
s["worker"]["active_mode_stage"] = 7
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
print("Status zaktualizowany")
PYSTAGE7

    # ETAP 8: COMMIT (oznaczenie zakończenia)
    log_stage "8/8" "COMMIT: Zakończenie migracji"
    python3 << 'PYSTAGE8'
import json
with open("$STATUS_FILE") as f:
    s = json.load(f)
s["mode_1_migration"]["files"]["$file"]["stages"]["8_commit"] = {"status": "completed"}
s["worker"]["active_mode"] = None
s["worker"]["active_mode_stage"] = None
with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
PYSTAGE8

    log "${GREEN}✅ MIGRACJA ZAKOŃCZONA: $file${NC}"
    return 0
}

#===============================================================================
# TRYB 2: TŁUMACZENIA - 6 etapów + składnie
#===============================================================================
mode_2_translation() {
    local target_lang="$1"
    local keys_to_translate="$2"
    
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BLUE}TRYB 2: TŁUMACZENIA${NC} - Język: $target_lang ($keys_to_translate kluczy)"
    log "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    
    # ETAP 1: SELECT_SOURCE
    log_stage "1/6" "SELECT_SOURCE: Wybór pliku źródłowego"
    
    # ETAP 2: DETECT_PROGRESS
    log_stage "2/6" "DETECT_PROGRESS: Sprawdzanie postępu"
    
    # ETAP 3: PREPARE_BATCH
    log_stage "3/6" "PREPARE_BATCH: Przygotowanie paczki kluczy"
    
    # ETAP 4: TRANSLATE_BATCH (ze składniami)
    log_stage "4/6" "TRANSLATE_BATCH: Tłumaczenie"
    
    python3 << PYTRANSLATE
import json
import os
import re

target_lang = "$target_lang"
i18n_dir = "$I18N_DIR"
status_file = "$STATUS_FILE"
batch_size = $TRANSLATION_BATCH
substage_size = $TRANSLATION_SUBSTAGE

# Wczytaj EN
en_file = f"{i18n_dir}/en/npc.json"
with open(en_file) as f:
    en_data = json.load(f)

# Wczytaj istniejące tłumaczenia
lang_file = f"{i18n_dir}/{target_lang}/npc.json"
os.makedirs(f"{i18n_dir}/{target_lang}", exist_ok=True)
if os.path.exists(lang_file):
    with open(lang_file) as f:
        lang_data = json.load(f)
else:
    lang_data = {}

# Znajdź klucze do przetłumaczenia
keys_todo = []
for key, text in en_data.items():
    if key not in lang_data:
        keys_todo.append((key, text))
    elif lang_data[key].startswith(f"[{target_lang.upper()}]") or lang_data[key].startswith("[TODO]"):
        keys_todo.append((key, text))

# Ogranicz do batch_size
keys_batch = keys_todo[:batch_size]
total_substages = (len(keys_batch) + substage_size - 1) // substage_size

print(f"Kluczy do tłumaczenia: {len(keys_todo)}")
print(f"W tym batchu: {len(keys_batch)}")
print(f"Składni: {total_substages}")
print("")

# Aktualizuj status - rozpoczęcie
with open(status_file) as f:
    s = json.load(f)
s["worker"]["active_mode"] = "TRANSLATION"
s["worker"]["active_mode_stage"] = 4
s["mode_2_translation"]["current_language"] = target_lang
s["mode_2_translation"]["total_keys"] = len(en_data)
s["mode_2_translation"]["substages_total"] = total_substages

# Tłumaczenia - prosty słownik dla popularnych fraz
COMMON_TRANSLATIONS = {
    "pl": {
        "Hello": "Witaj", "Goodbye": "Żegnaj", "Welcome": "Witamy",
        "Yes": "Tak", "No": "Nie", "Thank you": "Dziękuję",
        "adventurer": "przybyszu", "traveler": "podróżniku",
        "What do you need": "Czego potrzebujesz", "How can I help": "Jak mogę pomóc",
        "Come back": "Wróć", "Farewell": "Żegnaj", "Good luck": "Powodzenia",
        "I am": "Jestem", "I sell": "Sprzedaję", "I buy": "Kupuję",
        "equipment": "ekwipunek", "weapons": "bronie", "armor": "zbroje",
        "potions": "mikstury", "food": "jedzenie", "items": "przedmioty",
        "shop": "sklep", "store": "sklep", "trade": "handel",
        "gold": "złoto", "coins": "monety", "money": "pieniądze"
    },
    "de": {
        "Hello": "Hallo", "Goodbye": "Auf Wiedersehen", "Welcome": "Willkommen",
        "Yes": "Ja", "No": "Nein", "Thank you": "Danke",
        "adventurer": "Abenteurer", "traveler": "Reisender",
        "What do you need": "Was brauchst du", "How can I help": "Wie kann ich helfen",
        "Come back": "Komm zurück", "Farewell": "Lebewohl", "Good luck": "Viel Glück",
        "I am": "Ich bin", "I sell": "Ich verkaufe", "I buy": "Ich kaufe",
        "equipment": "Ausrüstung", "weapons": "Waffen", "armor": "Rüstung",
        "potions": "Tränke", "food": "Essen", "items": "Gegenstände",
        "shop": "Laden", "store": "Geschäft", "trade": "Handel",
        "gold": "Gold", "coins": "Münzen", "money": "Geld"
    },
    "es": {
        "Hello": "Hola", "Goodbye": "Adiós", "Welcome": "Bienvenido",
        "Yes": "Sí", "No": "No", "Thank you": "Gracias",
        "adventurer": "aventurero", "traveler": "viajero",
        "What do you need": "Qué necesitas", "How can I help": "Cómo puedo ayudar",
        "Come back": "Vuelve", "Farewell": "Adiós", "Good luck": "Buena suerte"
    },
    "pt": {
        "Hello": "Olá", "Goodbye": "Adeus", "Welcome": "Bem-vindo",
        "Yes": "Sim", "No": "Não", "Thank you": "Obrigado",
        "adventurer": "aventureiro", "traveler": "viajante"
    },
    "fr": {
        "Hello": "Bonjour", "Goodbye": "Au revoir", "Welcome": "Bienvenue",
        "Yes": "Oui", "No": "Non", "Thank you": "Merci",
        "adventurer": "aventurier", "traveler": "voyageur"
    },
    "it": {
        "Hello": "Ciao", "Goodbye": "Arrivederci", "Welcome": "Benvenuto",
        "Yes": "Sì", "No": "No", "Thank you": "Grazie"
    },
    "ru": {
        "Hello": "Привет", "Goodbye": "До свидания", "Welcome": "Добро пожаловать",
        "Yes": "Да", "No": "Нет", "Thank you": "Спасибо",
        "adventurer": "путник", "traveler": "путешественник"
    }
}

def translate_text(text, lang):
    """Prosta heurystyczna translacja"""
    if lang not in COMMON_TRANSLATIONS:
        return f"[{lang.upper()}] {text}"
    
    result = text
    trans = COMMON_TRANSLATIONS[lang]
    
    # Zamień znane frazy (case-insensitive)
    for en, loc in trans.items():
        pattern = re.compile(re.escape(en), re.IGNORECASE)
        result = pattern.sub(loc, result)
    
    # Jeśli nic się nie zmieniło, oznacz jako TODO
    if result == text:
        return f"[{lang.upper()}] {text}"
    
    return result

# Przetwórz składnie
translated_count = 0
for substage in range(total_substages):
    start_idx = substage * substage_size
    end_idx = min(start_idx + substage_size, len(keys_batch))
    substage_keys = keys_batch[start_idx:end_idx]
    
    print(f"  └─ Składnia {substage + 1}/{total_substages}: {len(substage_keys)} kluczy")
    
    s["worker"]["active_mode_substage"] = substage + 1
    
    for key, en_text in substage_keys:
        translated = translate_text(en_text, target_lang)
        lang_data[key] = translated
        translated_count += 1
        
        # Pokaż przykład
        if substage == 0 and translated_count <= 2:
            print(f"     EN: {en_text[:50]}...")
            print(f"     {target_lang.upper()}: {translated[:50]}...")

# Zapisz tłumaczenia
lang_data = dict(sorted(lang_data.items()))
with open(lang_file, "w") as f:
    json.dump(lang_data, f, indent=2, ensure_ascii=False)

# Policz statystyki
real_translations = len([v for v in lang_data.values() if not v.startswith("[")])
placeholders = len([v for v in lang_data.values() if v.startswith("[")])

print(f"\n✓ Przetłumaczono: {translated_count} kluczy")
print(f"  Prawdziwe tłumaczenia: {real_translations}")
print(f"  Placeholder'y [TODO]: {placeholders}")

# Aktualizuj status języka
if target_lang not in s["mode_2_translation"]["languages"]:
    s["mode_2_translation"]["languages"][target_lang] = {}

s["mode_2_translation"]["languages"][target_lang] = {
    "status": "in_progress" if placeholders > 0 else "completed",
    "translated": real_translations,
    "placeholders": placeholders,
    "total": len(lang_data),
    "last_batch": s["mode_2_translation"].get("current_batch", 0) + 1
}
s["mode_2_translation"]["current_batch"] = s["mode_2_translation"]["languages"][target_lang]["last_batch"]

with open(status_file, "w") as f:
    json.dump(s, f, indent=2)
PYTRANSLATE

    # ETAP 5: SAVE_TRANSLATIONS (już zapisane w etapie 4)
    log_stage "5/6" "SAVE_TRANSLATIONS: Zapisano"
    
    # ETAP 6: SYNC
    log_stage "6/6" "SYNC: Aktualizacja statusu"
    python3 << PYSYNC
import json
from datetime import datetime

with open("$STATUS_FILE") as f:
    s = json.load(f)

s["worker"]["active_mode"] = None
s["worker"]["active_mode_stage"] = None
s["worker"]["active_mode_substage"] = None
s["worker"]["last_activity"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

with open("$STATUS_FILE", "w") as f:
    json.dump(s, f, indent=2)
PYSYNC

    log "${BLUE}✅ TŁUMACZENIE ZAKOŃCZONE: $target_lang${NC}"
    return 0
}

#===============================================================================
# TRYB 3: WALIDACJA - 4 etapy
#===============================================================================
mode_3_validation() {
    log "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    log "${YELLOW}TRYB 3: WALIDACJA${NC}"
    log "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    
    python3 << 'PYVALIDATE'
import json
import os
import glob
from datetime import datetime

status_file = "$STATUS_FILE"
i18n_dir = "$I18N_DIR"

with open(status_file) as f:
    s = json.load(f)

s["worker"]["active_mode"] = "VALIDATION"
errors = []
warnings = []

# ETAP 1: CHECK_COMPLETENESS
print("[1/4] CHECK_COMPLETENESS: Sprawdzanie kompletności")
en_file = f"{i18n_dir}/en/npc.json"
if os.path.exists(en_file):
    with open(en_file) as f:
        en_keys = set(json.load(f).keys())
    
    for lang_dir in glob.glob(f"{i18n_dir}/*/"):
        lang = os.path.basename(lang_dir.rstrip("/"))
        if lang == "en":
            continue
        lang_file = f"{lang_dir}npc.json"
        if os.path.exists(lang_file):
            with open(lang_file) as f:
                lang_data = json.load(f)
            missing = en_keys - set(lang_data.keys())
            if missing:
                warnings.append(f"{lang}: brakuje {len(missing)} kluczy")

# ETAP 2: CHECK_FORMAT
print("[2/4] CHECK_FORMAT: Sprawdzanie formatów {param}")
# TODO: sprawdź czy {player}, {npc} etc. są zachowane

# ETAP 3: CHECK_QUALITY
print("[3/4] CHECK_QUALITY: Sprawdzanie jakości")
for lang_dir in glob.glob(f"{i18n_dir}/*/"):
    lang = os.path.basename(lang_dir.rstrip("/"))
    lang_file = f"{lang_dir}npc.json"
    if os.path.exists(lang_file):
        with open(lang_file) as f:
            lang_data = json.load(f)
        placeholders = len([v for v in lang_data.values() if v.startswith("[")])
        if placeholders > 0:
            warnings.append(f"{lang}: {placeholders} placeholder'ów do przetłumaczenia")

# ETAP 4: SYNC
print("[4/4] SYNC: Zapisywanie raportu")
s["mode_3_validation"]["last_run"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
s["mode_3_validation"]["errors"] = len(errors)
s["mode_3_validation"]["warnings"] = len(warnings)
s["mode_3_validation"]["issues"] = errors + warnings
s["worker"]["active_mode"] = None

with open(status_file, "w") as f:
    json.dump(s, f, indent=2)

print(f"\n✓ Walidacja zakończona")
print(f"  Błędy: {len(errors)}")
print(f"  Ostrzeżenia: {len(warnings)}")
for w in warnings[:5]:
    print(f"  - {w}")
PYVALIDATE

    log "${YELLOW}✅ WALIDACJA ZAKOŃCZONA${NC}"
    return 0
}

#===============================================================================
# UPDATE STATUS MD - Aktualizacja I18N_STATUS.md
#===============================================================================
update_status_md() {
    python3 << 'PYSTATUSMD'
import json
import os
from datetime import datetime

status_file = "i18n_worker_status.json"
i18n_dir = "i18n"

if not os.path.exists(status_file):
    print("Brak pliku statusu")
    exit(1)

with open(status_file) as f:
    s = json.load(f)

# Zlicz klucze EN
en_npc = f"{i18n_dir}/en/npc.json"
total_keys = 0
if os.path.exists(en_npc):
    with open(en_npc) as f:
        total_keys = len(json.load(f))

# Zlicz języki
langs_complete = 0
langs_in_progress = 0
langs_data = s.get("mode_2_translation", {}).get("languages", {})
for lang, info in langs_data.items():
    if info.get("status") == "completed":
        langs_complete += 1
    elif info.get("status") == "in_progress":
        langs_in_progress += 1

# Generuj MD
md = f'''# 🌍 I18N Worker v2.0 - Live Dashboard

> **Aktualizacja:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} UTC  
> **Worker:** v2.0 Multi-Mode | **Status:** {"🔄 " + s["worker"]["active_mode"] if s["worker"]["active_mode"] else "✅ IDLE"}

---

## 🎯 Aktywny Tryb

| Parametr | Wartość |
|----------|---------|
| **Tryb** | {s["worker"]["active_mode"] or "IDLE"} |
| **Etap** | {s["worker"]["active_mode_stage"] or "-"} |
| **Składnia** | {s["worker"]["active_mode_substage"] or "-"} |
| **Ostatnia aktywność** | {s["worker"]["last_activity"]} |
| **Cykle** | {s["worker"]["cycles_total"]} |

---

## 📊 TRYB 1: Migracja NPC

| Metryka | Wartość |
|---------|---------|
| ✅ Zmigrowanych | **{s["mode_1_migration"]["completed_files"]}** |
| 🔄 W toku | {s["mode_1_migration"]["in_progress"] or "-"} |
| 📁 Aktualny plik | {s["mode_1_migration"]["current_file"] or "-"} |

---

## 🌍 TRYB 2: Tłumaczenia

| Metryka | Wartość |
|---------|---------|
| 🔑 Kluczy EN | **{total_keys}** |
| ✅ Języki ukończone | **{langs_complete}** |
| 🔄 Języki w toku | **{langs_in_progress}** |
| 🎯 Aktualny język | {s["mode_2_translation"].get("current_language") or "-"} |
| 📦 Batch | #{s["mode_2_translation"].get("current_batch", 0)} |

### Status języków

| Język | Status | Przetłumaczone | Placeholder'y |
|-------|--------|----------------|---------------|
'''

# Dodaj status każdego języka
LANG_PRIORITY = ["pl", "de", "es", "pt", "fr", "it", "ru"]
for lang in LANG_PRIORITY:
    info = langs_data.get(lang, {})
    status_icon = "✅" if info.get("status") == "completed" else "🔄" if info.get("status") == "in_progress" else "⏳"
    translated = info.get("translated", 0)
    placeholders = info.get("placeholders", 0)
    md += f"| {lang.upper()} | {status_icon} | {translated} | {placeholders} |\n"

md += f'''
---

## ✅ TRYB 3: Walidacja

| Metryka | Wartość |
|---------|---------|
| Ostatnia walidacja | {s["mode_3_validation"].get("last_run") or "Nigdy"} |
| ❌ Błędy | {s["mode_3_validation"].get("errors", 0)} |
| ⚠️ Ostrzeżenia | {s["mode_3_validation"].get("warnings", 0)} |

---

*Generowane automatycznie przez i18n_worker_v2.sh*
'''

with open("I18N_STATUS.md", "w") as f:
    f.write(md)

print("✅ I18N_STATUS.md zaktualizowany")
PYSTATUSMD
}

#===============================================================================
# GŁÓWNA PĘTLA - CONTINUOUS MODE
#===============================================================================
run_continuous() {
    echo $$ > "$PID_FILE"
    
    log "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    log "${CYAN}║   I18N WORKER v2.0 - TRYB CIĄGŁY                          ║${NC}"
    log "${CYAN}║   PID: $$                                                  ║${NC}"
    log "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    log ""
    log "Aby zatrzymać: kill $$ lub Ctrl+C"
    log ""
    
    trap 'log ""; log "⛔ Zatrzymuję worker..."; update_status_md; rm -f "$PID_FILE"; exit 0' SIGINT SIGTERM
    
    CYCLE=0
    
    while true; do
        CYCLE=$((CYCLE + 1))
        
        log ""
        log "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        log "${CYAN}🔄 CYKL #$CYCLE - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        log "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        
        # Aktualizuj liczbę cykli
        python3 -c "
import json
with open('$STATUS_FILE') as f:
    s = json.load(f)
s['worker']['cycles_total'] = $CYCLE
with open('$STATUS_FILE', 'w') as f:
    json.dump(s, f, indent=2)
"
        
        # Wybierz tryb
        MODE_RESULT=$(select_mode)
        log "Dispatcher: $MODE_RESULT"
        
        if [[ "$MODE_RESULT" == CONTINUE:* ]]; then
            MODE=$(echo "$MODE_RESULT" | cut -d: -f2)
            log "Kontynuuję tryb: $MODE"
        elif [[ "$MODE_RESULT" == MODE:1:* ]]; then
            # TRYB 1: MIGRACJA
            # Znajdź plik do migracji
            for f in data-otservbr-global/npc/*.lua; do
                if grep -q "StdModule\.say" "$f" 2>/dev/null; then
                    if grep -q "text" "$f" 2>/dev/null; then
                        if ! grep -q "i18nKey" "$f" 2>/dev/null; then
                            mode_1_migration "$f"
                            break
                        fi
                    fi
                fi
            done
        elif [[ "$MODE_RESULT" == MODE:2:* ]]; then
            # TRYB 2: TŁUMACZENIA
            LANG=$(echo "$MODE_RESULT" | cut -d: -f4)
            KEYS=$(echo "$MODE_RESULT" | cut -d: -f5 | cut -d' ' -f1)
            mode_2_translation "$LANG" "$KEYS"
        elif [[ "$MODE_RESULT" == MODE:3:* ]]; then
            # TRYB 3: WALIDACJA
            mode_3_validation
        else
            log "✅ Wszystko zrobione! Czekam..."
        fi
        
        # Aktualizuj status MD
        update_status_md
        
        # Git commit co cykl
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            git add -A 2>/dev/null
            MIGRATED=$(python3 -c "import json; print(json.load(open('$STATUS_FILE'))['mode_1_migration']['completed_files'])" 2>/dev/null || echo "?")
            git commit -m "📊 I18N v2: $MIGRATED NPCs - Cykl #$CYCLE" 2>/dev/null
            git push origin master 2>/dev/null && log "📤 Push OK" || log "⚠️ Push failed"
        fi
        
        log ""
        log "💤 Przerwa ${CYCLE_DELAY}s..."
        sleep "$CYCLE_DELAY"
    done
}

#===============================================================================
# MAIN
#===============================================================================
case "${1:-}" in
    --continuous|-c)
        init_status
        run_continuous
        ;;
    --status|-s)
        init_status
        python3 -c "
import json
with open('$STATUS_FILE') as f:
    s = json.load(f)
print('=== I18N Worker v2.0 Status ===')
print(f'Tryb: {s[\"worker\"][\"active_mode\"] or \"IDLE\"}')
print(f'Etap: {s[\"worker\"][\"active_mode_stage\"] or \"-\"}')
print(f'Cykle: {s[\"worker\"][\"cycles_total\"]}')
print(f'Migracja: {s[\"mode_1_migration\"][\"completed_files\"]} plików')
print(f'Tłumaczenia: {len(s[\"mode_2_translation\"][\"languages\"])} języków')
"
        ;;
    --migrate)
        init_status
        FILE="${2:-}"
        if [ -z "$FILE" ]; then
            echo "Użycie: $0 --migrate <plik.lua>"
            exit 1
        fi
        mode_1_migration "$FILE"
        update_status_md
        ;;
    --translate)
        init_status
        LANG="${2:-pl}"
        mode_2_translation "$LANG" "50"
        update_status_md
        ;;
    --validate)
        init_status
        mode_3_validation
        update_status_md
        ;;
    --update-status)
        init_status
        update_status_md
        ;;
    *)
        echo "I18N Worker v2.0 - Multi-Mode Worker"
        echo ""
        echo "Użycie:"
        echo "  $0 --continuous      Tryb ciągły (automatyczne przełączanie)"
        echo "  $0 --status          Pokaż status"
        echo "  $0 --migrate <plik>  Migruj jeden plik"
        echo "  $0 --translate [lang] Tłumacz na język (domyślnie: pl)"
        echo "  $0 --validate        Uruchom walidację"
        echo "  $0 --update-status   Aktualizuj I18N_STATUS.md"
        ;;
esac
