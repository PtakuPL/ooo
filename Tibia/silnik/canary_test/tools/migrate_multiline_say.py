#!/usr/bin/env python3
"""
Narzędzie do migracji wieloliniowych tablic npcHandler:say({...}) do NPC_LIB.i18n.npcSay
Obsługuje skomplikowane przypadki których bash nie może obsłużyć.

Autor: GitHub Copilot + PtakuPL
Data: 2025-12-09
"""

import re
import json
import os
import sys
from pathlib import Path

class MultilineSayMigrator:
    def __init__(self, i18n_dir: str):
        self.i18n_dir = Path(i18n_dir)
        self.json_file = self.i18n_dir / "en" / "npc.json"
        self.keys_added = 0
        self.files_processed = 0
        self.strings_migrated = 0
        
    def load_json(self) -> dict:
        """Wczytaj istniejący plik JSON"""
        if self.json_file.exists():
            try:
                with open(self.json_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def save_json(self, data: dict):
        """Zapisz plik JSON"""
        with open(self.json_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    
    def get_npc_name(self, filepath: str) -> str:
        """Wyciągnij nazwę NPC z ścieżki pliku"""
        name = Path(filepath).stem
        # Zamień znaki specjalne na _
        name = re.sub(r'[^a-zA-Z0-9]', '_', name)
        return name.lower()
    
    def find_multiline_say_blocks(self, content: str) -> list:
        """
        Znajdź wszystkie bloki npcHandler:say({ ... }, npc, creature)
        które są wieloliniowe
        """
        blocks = []
        
        # Wzorzec początkowy: npcHandler:say({
        pattern_start = r'npcHandler:say\s*\(\s*\{'
        
        lines = content.split('\n')
        i = 0
        while i < len(lines):
            line = lines[i]
            
            # Szukaj początku bloku
            if re.search(pattern_start, line):
                # Sprawdź czy to nie jest jednolinijkowe (już obsłużone)
                if re.search(r'npcHandler:say\s*\(\s*\{[^}]+\}\s*,\s*npc\s*,\s*creature\s*\)', line):
                    i += 1
                    continue
                
                # Zbierz cały blok
                block_start = i
                block_lines = [line]
                brace_count = line.count('{') - line.count('}')
                
                j = i + 1
                while j < len(lines) and brace_count > 0:
                    block_lines.append(lines[j])
                    brace_count += lines[j].count('{') - lines[j].count('}')
                    j += 1
                
                # Sprawdź czy kończy się na , npc, creature)
                block_text = '\n'.join(block_lines)
                if re.search(r'\}\s*,\s*npc\s*,\s*creature\s*\)', block_text):
                    blocks.append({
                        'start_line': block_start,
                        'end_line': j - 1,
                        'text': block_text,
                        'lines': block_lines
                    })
                
                i = j
            else:
                i += 1
        
        return blocks
    
    def extract_strings_from_block(self, block_text: str) -> list:
        """Wyciągnij wszystkie stringi z bloku say({...})"""
        strings = []
        
        # Znajdź zawartość między { a }
        match = re.search(r'\{\s*(.*?)\s*\}\s*,\s*npc\s*,\s*creature', block_text, re.DOTALL)
        if not match:
            return strings
        
        inner_content = match.group(1)
        
        # Wyciągnij stringi (obsłuż różne rodzaje cudzysłowów)
        # Wzorzec: "tekst" lub 'tekst'
        string_pattern = r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\''
        
        for m in re.finditer(string_pattern, inner_content):
            text = m.group(1) if m.group(1) else m.group(2)
            if text and len(text) >= 5:  # Minimum 5 znaków
                strings.append(text)
        
        return strings
    
    def generate_migration_code(self, npc_name: str, strings: list, key_start: int) -> tuple:
        """
        Generuj kod migracji - zwraca (nowy_kod, lista_kluczy)
        """
        keys = []
        code_lines = []
        
        for i, text in enumerate(strings):
            key = f"npc.{npc_name}.multi_{key_start + i}"
            keys.append((key, text))
            code_lines.append(f'NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "{key}")')
        
        return code_lines, keys
    
    def migrate_file(self, filepath: str) -> dict:
        """Migruj pojedynczy plik"""
        result = {
            'file': filepath,
            'blocks_found': 0,
            'strings_migrated': 0,
            'keys_added': []
        }
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Znajdź wieloliniowe bloki
        blocks = self.find_multiline_say_blocks(content)
        if not blocks:
            return result
        
        result['blocks_found'] = len(blocks)
        
        npc_name = self.get_npc_name(filepath)
        json_data = self.load_json()
        
        # Znajdź najwyższy numer klucza multi_ dla tego NPC
        existing_keys = [k for k in json_data.keys() if k.startswith(f"npc.{npc_name}.multi_")]
        if existing_keys:
            max_num = max(int(k.split('_')[-1]) for k in existing_keys)
            key_counter = max_num + 1
        else:
            key_counter = 1
        
        # Przetwarzaj bloki od końca (żeby nie psuć numerów linii)
        new_lines = content.split('\n')
        
        for block in reversed(blocks):
            strings = self.extract_strings_from_block(block['text'])
            if not strings:
                continue
            
            # Generuj nowy kod
            new_code_lines, keys = self.generate_migration_code(npc_name, strings, key_counter)
            key_counter += len(strings)
            
            # Dodaj klucze do JSON
            for key, text in keys:
                json_data[key] = text
                result['keys_added'].append(key)
            
            result['strings_migrated'] += len(strings)
            
            # Znajdź wcięcie oryginalne
            original_line = block['lines'][0]
            indent = len(original_line) - len(original_line.lstrip())
            indent_str = original_line[:indent]
            
            # Zastąp blok nowymi liniami
            replacement_lines = [indent_str + line for line in new_code_lines]
            
            # Zamień w tablicy linii
            new_lines[block['start_line']:block['end_line'] + 1] = replacement_lines
        
        # Zapisz zmodyfikowany plik
        if result['strings_migrated'] > 0:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('\n'.join(new_lines))
            
            # Zapisz JSON
            self.save_json(json_data)
            
            self.files_processed += 1
            self.strings_migrated += result['strings_migrated']
            self.keys_added += len(result['keys_added'])
        
        return result
    
    def migrate_directory(self, directory: str, limit: int = None) -> list:
        """Migruj wszystkie pliki NPC w katalogu"""
        results = []
        npc_dir = Path(directory)
        
        if not npc_dir.exists():
            print(f"❌ Katalog nie istnieje: {directory}")
            return results
        
        lua_files = list(npc_dir.glob("*.lua"))
        
        if limit:
            lua_files = lua_files[:limit]
        
        print(f"🔍 Znaleziono {len(lua_files)} plików do sprawdzenia")
        
        for filepath in lua_files:
            try:
                result = self.migrate_file(str(filepath))
                if result['strings_migrated'] > 0:
                    print(f"  ✅ {filepath.name}: {result['strings_migrated']} stringów, {len(result['keys_added'])} kluczy")
                    results.append(result)
            except Exception as e:
                print(f"  ❌ {filepath.name}: {e}")
        
        return results


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Migracja wieloliniowych tablic npcHandler:say')
    parser.add_argument('--i18n-dir', default='i18n', help='Katalog i18n')
    parser.add_argument('--npc-dir', default='data-otservbr-global/npc', help='Katalog z plikami NPC')
    parser.add_argument('--limit', type=int, help='Limit plików do przetworzenia')
    parser.add_argument('--file', help='Pojedynczy plik do migracji')
    
    args = parser.parse_args()
    
    migrator = MultilineSayMigrator(args.i18n_dir)
    
    print("=" * 60)
    print("🔄 MIGRACJA WIELOLINIOWYCH TABLIC npcHandler:say")
    print("=" * 60)
    
    if args.file:
        result = migrator.migrate_file(args.file)
        print(f"\nWynik: {result}")
    else:
        results = migrator.migrate_directory(args.npc_dir, args.limit)
        
        print("\n" + "=" * 60)
        print("📊 PODSUMOWANIE")
        print("=" * 60)
        print(f"  Plików przetworzonych: {migrator.files_processed}")
        print(f"  Stringów zmigrowanych: {migrator.strings_migrated}")
        print(f"  Kluczy dodanych: {migrator.keys_added}")


if __name__ == "__main__":
    main()
