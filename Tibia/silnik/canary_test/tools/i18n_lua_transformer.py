#!/usr/bin/env python3
"""
I18N Lua Code Transformer - Automatycznie konwertuje hardkodowane stringi na i18n
=================================================================================

Funkcje:
- Parsuje pliki Lua i znajduje hardkodowane stringi
- Automatycznie generuje klucze i18n
- Tworzy zmodyfikowaną wersję pliku z wywołaniami i18n
- Generuje odpowiedni plik JSON z tłumaczeniami
- Tworzy backup oryginalnego pliku

Usage:
    python3 tools/i18n_lua_transformer.py --file data-otservbr-global/npc/some_npc.lua
    python3 tools/i18n_lua_transformer.py --dir data-otservbr-global/scripts/quests --dry-run
    python3 tools/i18n_lua_transformer.py --file script.lua --apply --backup
"""

import argparse
import json
import os
import re
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class StringMatch:
    """Represents a found string in Lua code"""
    text: str
    start: int
    end: int
    line_number: int
    context: str  # 'npc_say', 'send_message', 'set_message', etc.
    full_match: str
    suggested_key: str = ""
    replacement: str = ""


class LuaI18NTransformer:
    """Transforms Lua files to use i18n"""
    
    # Patterns for different string usages
    PATTERNS = [
        # npcHandler:say("text", ...) -> npcHandler:say(i18n.get(player, "key"), ...)
        (
            r'(npcHandler:say\s*\(\s*)"([^"]+)"',
            'npc_say',
            r'\1i18n.get(player, "{key}")'
        ),
        # player:sendTextMessage(TYPE, "text") -> player:sendLocalizedTextMessage(TYPE, "key")
        (
            r'(player:sendTextMessage\s*\(\s*[\w\.]+\s*,\s*)"([^"]+)"(\s*\))',
            'send_message',
            r'player:sendLocalizedTextMessage(\1"{key}"\3'
        ),
        # selfSay("text") -> selfSay(i18n.get(player, "key"))
        (
            r'(selfSay\s*\(\s*)"([^"]+)"',
            'self_say',
            r'\1i18n.get(player, "{key}")'
        ),
        # npc:say("text", ...) -> npc:say(i18n.get(player, "key"), ...)
        (
            r'(npc:say\s*\(\s*)"([^"]+)"',
            'npc_direct_say',
            r'\1i18n.get(player, "{key}")'
        ),
    ]
    
    # Strings to skip
    SKIP_PATTERNS = [
        r'^[a-z_\.]+$',          # Pure keys
        r'^\d+$',                # Numbers only
        r'^(yes|no|hi|bye)$',    # Single keywords
        r'^[A-Z_]+$',            # Constants
    ]
    
    def __init__(self, i18n_root: Path):
        self.i18n_root = i18n_root
        self.generated_keys: Dict[str, str] = {}
        
    def should_skip(self, text: str) -> bool:
        """Check if string should be skipped"""
        if len(text) < 5:
            return True
        for pattern in self.SKIP_PATTERNS:
            if re.match(pattern, text, re.IGNORECASE):
                return True
        return False
    
    def generate_key(self, text: str, file_path: Path, context: str) -> str:
        """Generate i18n key from text and context"""
        # Get base from filename
        base = file_path.stem.lower().replace(' ', '_').replace('-', '_')
        
        # Determine category from path
        path_str = str(file_path).lower()
        if '/npc/' in path_str:
            category = 'npc'
        elif '/quest' in path_str:
            category = 'quests'
        elif '/scripts/' in path_str:
            category = 'scripts'
        else:
            category = 'system'
        
        # Generate suffix from text
        words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())[:4]
        suffix = '_'.join(words) if words else 'message'
        
        # Build key
        key = f"{category}.{base}.{suffix}"
        
        # Handle duplicates
        if key in self.generated_keys:
            counter = 2
            while f"{key}_{counter}" in self.generated_keys:
                counter += 1
            key = f"{key}_{counter}"
        
        self.generated_keys[key] = text
        return key
    
    def find_strings(self, content: str, file_path: Path) -> List[StringMatch]:
        """Find all translatable strings in Lua content"""
        matches = []
        lines = content.split('\n')
        
        for pattern, context, replacement_template in self.PATTERNS:
            for match in re.finditer(pattern, content, re.MULTILINE):
                text = match.group(2)
                
                if self.should_skip(text):
                    continue
                
                # Calculate line number
                start_pos = match.start()
                line_number = content[:start_pos].count('\n') + 1
                
                # Generate key
                key = self.generate_key(text, file_path, context)
                
                # Generate replacement
                replacement = replacement_template.replace('{key}', key)
                
                string_match = StringMatch(
                    text=text,
                    start=match.start(),
                    end=match.end(),
                    line_number=line_number,
                    context=context,
                    full_match=match.group(0),
                    suggested_key=key,
                    replacement=replacement
                )
                matches.append(string_match)
        
        # Sort by position (reverse for replacement)
        return sorted(matches, key=lambda m: m.start, reverse=True)
    
    def transform_content(self, content: str, matches: List[StringMatch]) -> str:
        """Transform content by replacing strings with i18n calls"""
        result = content
        
        for match in matches:
            # Find and replace the full match
            before = result[:match.start]
            after = result[match.end:]
            
            # Build replacement preserving the prefix
            original = result[match.start:match.end]
            new_text = re.sub(
                f'"{re.escape(match.text)}"',
                f'i18n.get(player, "{match.suggested_key}")',
                original
            )
            
            result = before + new_text + after
        
        return result
    
    def process_file(self, file_path: Path, dry_run: bool = True, backup: bool = True) -> Dict:
        """Process a single Lua file"""
        result = {
            'file': str(file_path),
            'strings_found': 0,
            'keys_generated': {},
            'success': False,
            'error': None,
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                original_content = f.read()
            
            matches = self.find_strings(original_content, file_path)
            result['strings_found'] = len(matches)
            
            if not matches:
                result['success'] = True
                return result
            
            # Generate transformed content
            transformed = self.transform_content(original_content, matches)
            
            # Collect keys
            for match in matches:
                result['keys_generated'][match.suggested_key] = match.text
            
            if not dry_run:
                # Create backup
                if backup:
                    backup_path = file_path.with_suffix(f'.lua.bak.{datetime.now().strftime("%Y%m%d_%H%M%S")}')
                    shutil.copy(file_path, backup_path)
                
                # Write transformed file
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(transformed)
            
            result['success'] = True
            
        except Exception as e:
            result['error'] = str(e)
        
        return result
    
    def save_translations(self, keys: Dict[str, str], locale: str = 'en') -> Path:
        """Save generated translations to JSON"""
        # Group by category
        grouped: Dict[str, Dict] = {}
        
        for key, text in keys.items():
            parts = key.split('.')
            category = parts[0] if parts else 'system'
            
            if category not in grouped:
                grouped[category] = {}
            
            # Build nested structure
            current = grouped[category]
            for part in parts[1:-1]:
                if part not in current:
                    current[part] = {}
                current = current[part]
            
            current[parts[-1]] = text
        
        # Save each category
        locale_dir = self.i18n_root / locale
        locale_dir.mkdir(parents=True, exist_ok=True)
        
        for category, data in grouped.items():
            json_path = locale_dir / f"{category}.json"
            
            # Merge with existing
            existing = {}
            if json_path.exists():
                with open(json_path, 'r', encoding='utf-8') as f:
                    existing = json.load(f)
            
            # Deep merge
            self._deep_merge(existing, data)
            
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(existing, f, indent=2, ensure_ascii=False, sort_keys=True)
        
        return locale_dir
    
    def _deep_merge(self, base: dict, update: dict) -> None:
        """Recursively merge update into base"""
        for key, value in update.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                self._deep_merge(base[key], value)
            else:
                base[key] = value


def main():
    parser = argparse.ArgumentParser(description="Lua to I18N Transformer")
    parser.add_argument('--file', type=str, help='Single file to transform')
    parser.add_argument('--dir', type=str, help='Directory to process recursively')
    parser.add_argument('--i18n-root', default='i18n', help='i18n root directory')
    parser.add_argument('--dry-run', action='store_true', help='Show changes without applying')
    parser.add_argument('--apply', action='store_true', help='Apply changes to files')
    parser.add_argument('--backup', action='store_true', default=True, help='Create backups')
    parser.add_argument('--save-keys', action='store_true', help='Save generated keys to JSON')
    
    args = parser.parse_args()
    
    transformer = LuaI18NTransformer(Path(args.i18n_root))
    
    files_to_process = []
    
    if args.file:
        files_to_process.append(Path(args.file))
    elif args.dir:
        dir_path = Path(args.dir)
        files_to_process.extend(dir_path.rglob('*.lua'))
    else:
        parser.print_help()
        return
    
    all_keys = {}
    total_strings = 0
    
    print("\n" + "=" * 70)
    print("LUA I18N TRANSFORMER")
    print("=" * 70)
    
    for file_path in files_to_process:
        if not file_path.exists():
            print(f"❌ File not found: {file_path}")
            continue
        
        result = transformer.process_file(
            file_path,
            dry_run=not args.apply,
            backup=args.backup
        )
        
        if result['strings_found'] > 0:
            print(f"\n📄 {file_path}")
            print(f"   Found: {result['strings_found']} strings")
            
            if result['keys_generated']:
                for key, text in list(result['keys_generated'].items())[:3]:
                    preview = text[:40] + "..." if len(text) > 40 else text
                    print(f"   • {key}")
                    print(f"     \"{preview}\"")
                
                if len(result['keys_generated']) > 3:
                    print(f"   ... and {len(result['keys_generated']) - 3} more")
            
            all_keys.update(result['keys_generated'])
            total_strings += result['strings_found']
            
            if args.apply:
                print(f"   ✅ File transformed")
    
    print(f"\n📊 SUMMARY")
    print(f"   Files processed: {len(files_to_process)}")
    print(f"   Strings found: {total_strings}")
    print(f"   Keys generated: {len(all_keys)}")
    
    if args.save_keys and all_keys:
        output_dir = transformer.save_translations(all_keys)
        print(f"\n✅ Keys saved to: {output_dir}")
    
    if not args.apply:
        print(f"\n💡 Run with --apply to transform files")
    
    print("=" * 70)


if __name__ == '__main__':
    main()
