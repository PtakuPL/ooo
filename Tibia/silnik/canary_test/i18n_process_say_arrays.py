#!/usr/bin/env python3
"""
Skrypt do konwersji npcHandler:say({...}) na NPC_LIB.i18n.npcSayMultiple
"""

import os
import re
import json
import shutil
from datetime import datetime

# Ścieżki
NPC_DIR = "/home/ptaku/serweryt/Tibia/silnik/canary_test/data-otservbr-global/npc"
EN_FILE = "/home/ptaku/serweryt/Tibia/silnik/canary_test/i18n/en/npc.json"
BACKUP_DIR = "/home/ptaku/serweryt/Tibia/silnik/canary_test/backups/npc"

# Kolory
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
CYAN = '\033[0;36m'
NC = '\033[0m'

def log(msg):
    print(f"{CYAN}[{datetime.now().strftime('%H:%M:%S')}]{NC} {msg}")

def backup_file(filepath):
    """Tworzy backup pliku"""
    os.makedirs(BACKUP_DIR, exist_ok=True)
    backup_name = f"{os.path.basename(filepath)}.{datetime.now().strftime('%Y%m%d_%H%M%S')}.bak"
    backup_path = os.path.join(BACKUP_DIR, backup_name)
    shutil.copy2(filepath, backup_path)
    return backup_path

def load_translations():
    """Wczytuje istniejące tłumaczenia"""
    if os.path.exists(EN_FILE):
        with open(EN_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def save_translations(translations):
    """Zapisuje tłumaczenia"""
    os.makedirs(os.path.dirname(EN_FILE), exist_ok=True)
    with open(EN_FILE, 'w', encoding='utf-8') as f:
        json.dump(translations, f, ensure_ascii=False, indent=2, sort_keys=True)

def get_base_key(filepath):
    """Zwraca bazowy klucz i18n dla pliku"""
    filename = os.path.basename(filepath).replace('.lua', '')
    return f"npc.{filename}"

def find_max_key_number(translations, base_key):
    """Znajduje najwyższy numer klucza dla danego NPC"""
    max_num = 0
    pattern = re.compile(rf'^{re.escape(base_key)}\.say_(\d+)$')
    for key in translations:
        match = pattern.match(key)
        if match:
            num = int(match.group(1))
            if num > max_num:
                max_num = num
    return max_num

def extract_strings_from_array(array_content):
    """Wyodrębnia stringi z zawartości tablicy Lua"""
    strings = []
    
    # Wzorzec dla stringów (obsługuje \z i wieloliniowe)
    # Szukamy stringów w cudzysłowach, ale uwzględniamy \z i escape'y
    pattern = r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\''
    
    matches = re.findall(pattern, array_content, re.DOTALL)
    
    for match in matches:
        s = match[0] if match[0] else match[1]
        if s:
            # Oczyść string (usuń \z i nadmiarowe spacje)
            cleaned = re.sub(r'\s*\\z\s*', ' ', s)
            cleaned = re.sub(r'\s+', ' ', cleaned).strip()
            if cleaned:
                strings.append(cleaned)
    
    return strings

def process_file(filepath, translations, dry_run=False):
    """Przetwarza plik NPC"""
    base_key = get_base_key(filepath)
    max_num = find_max_key_number(translations, base_key)
    
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Sprawdź czy plik ma tablice w npcHandler:say
    if "npcHandler:say({" not in content:
        return 0, 0, {}
    
    new_translations = {}
    changes = 0
    
    # Wzorzec: npcHandler:say({ ... }, npc, creature, delay)
    # Musi być wystarczająco elastyczny dla wieloliniowych tablic
    pattern = r'npcHandler:say\(\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}\s*,\s*npc\s*,\s*creature\s*(?:,\s*(\d+))?\s*\)'
    
    def replace_match(match):
        nonlocal max_num, changes, new_translations
        
        array_content = match.group(1)
        delay = match.group(2) if match.group(2) else "100"
        
        # Wyodrębnij stringi
        strings = extract_strings_from_array(array_content)
        
        if not strings:
            return match.group(0)  # Zwróć oryginał
        
        # Generuj klucze dla każdego stringa
        keys = []
        for s in strings:
            max_num += 1
            key = f"{base_key}.say_{max_num}"
            keys.append(key)
            new_translations[key] = s
        
        changes += 1
        
        # Generuj nowy kod
        keys_str = ', '.join([f'"{k}"' for k in keys])
        return f'NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {{{keys_str}}}, {delay})'
    
    new_content = re.sub(pattern, replace_match, content, flags=re.DOTALL)
    
    if changes > 0 and not dry_run:
        # Backup
        backup_file(filepath)
        
        # Zapisz zmodyfikowany plik
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        # Dodaj nowe tłumaczenia do słownika
        translations.update(new_translations)
    
    return changes, len(new_translations), new_translations

def main():
    log("=== Konwersja npcHandler:say({...}) na npcSayMultiple ===")
    
    # Wczytaj istniejące tłumaczenia
    translations = load_translations()
    log(f"Wczytano {len(translations)} istniejących tłumaczeń")
    
    # Znajdź pliki z tablicami
    files_to_process = []
    for filename in os.listdir(NPC_DIR):
        if filename.endswith('.lua'):
            filepath = os.path.join(NPC_DIR, filename)
            with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
                if 'npcHandler:say({' in f.read():
                    files_to_process.append(filepath)
    
    log(f"Znaleziono {len(files_to_process)} plików z tablicami")
    
    total_changes = 0
    total_keys = 0
    processed_files = 0
    
    for filepath in sorted(files_to_process):
        filename = os.path.basename(filepath)
        changes, keys, new_trans = process_file(filepath, translations, dry_run=False)
        
        if changes > 0:
            log(f"  {GREEN}✓{NC} {filename}: {changes} tablic -> {keys} kluczy")
            total_changes += changes
            total_keys += keys
            processed_files += 1
        else:
            log(f"  {YELLOW}○{NC} {filename}: brak prostych tablic (skomplikowany format?)")
    
    # Zapisz tłumaczenia
    if total_keys > 0:
        save_translations(translations)
        log(f"\n{GREEN}Zapisano tłumaczenia do {EN_FILE}{NC}")
    
    log(f"\n=== Podsumowanie ===")
    log(f"Plików z tablicami: {len(files_to_process)}")
    log(f"Przetworzonych: {processed_files}")
    log(f"Tablic przekonwertowanych: {total_changes}")
    log(f"Nowych kluczy i18n: {total_keys}")
    log(f"Łączna liczba kluczy: {len(translations)}")

if __name__ == '__main__':
    main()
