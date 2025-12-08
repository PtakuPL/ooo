#!/usr/bin/env python3
"""
I18N NPC Migrator - Automatyczna migracja NPC do systemu i18n
============================================================

Funkcje:
- Analizuje plik NPC i wyodrębnia wszystkie teksty do tłumaczenia
- Generuje sugerowane klucze i18n
- Tworzy plik JSON z tłumaczeniami
- Opcjonalnie modyfikuje plik NPC (zamienia stringi na wywołania i18n)
- Generuje raport różnic (patch)

Usage:
    python3 tools/i18n_npc_migrator.py --npc a_beggar
    python3 tools/i18n_npc_migrator.py --file data-otservbr-global/npc/nah_bob.lua --apply
    python3 tools/i18n_npc_migrator.py --batch --limit 10
"""

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class NPCString:
    """Represents a string found in NPC file"""
    text: str
    line_number: int
    context: str  # 'say', 'setMessage', 'sendTextMessage', etc.
    function_call: str  # Full function call for replacement
    suggested_key: str = ""


@dataclass
class MigrationResult:
    """Result of NPC migration"""
    npc_name: str
    file_path: str
    strings_found: List[NPCString] = field(default_factory=list)
    keys_generated: Dict[str, str] = field(default_factory=dict)
    modified_content: str = ""
    success: bool = False
    error: str = ""


class NPCMigrator:
    """Handles NPC i18n migration"""
    
    # Patterns to find translatable strings
    STRING_PATTERNS = [
        # npcHandler:say("text") or npcHandler:say("text", ...)
        (r'npcHandler:say\s*\(\s*"([^"]+)"', 'say'),
        # selfSay("text")
        (r'selfSay\s*\(\s*"([^"]+)"', 'selfSay'),
        # setMessage(TYPE, "text")
        (r'setMessage\s*\(\s*\w+\s*,\s*"([^"]+)"', 'setMessage'),
        # player:sendTextMessage(TYPE, "text")
        (r'sendTextMessage\s*\(\s*[\w\.]+\s*,\s*"([^"]+)"', 'sendTextMessage'),
        # addFocusMessage("text")
        (r'addFocusMessage\s*\(\s*"([^"]+)"', 'addFocusMessage'),
        # npc:say("text")
        (r'npc:say\s*\(\s*"([^"]+)"', 'npcSay'),
    ]
    
    # Strings to skip
    SKIP_PATTERNS = [
        r'^[a-z_\.]+$',  # Pure keys
        r'^\d+$',  # Numbers
        r'^yes$|^no$',  # Simple keywords
        r'^trade$|^buy$|^sell$',  # Trade keywords
        r'^hi$|^hello$|^bye$|^farewell$',  # Very common greetings (often handled by module)
    ]
    
    def __init__(self, npc_dir: Path, i18n_root: Path):
        self.npc_dir = npc_dir
        self.i18n_root = i18n_root
        self.existing_keys: Dict[str, str] = {}
        self._load_existing_keys()
    
    def _load_existing_keys(self) -> None:
        """Load existing NPC translation keys"""
        npc_json = self.i18n_root / "en" / "npc.json"
        if npc_json.exists():
            try:
                with open(npc_json, 'r', encoding='utf-8') as f:
                    self.existing_keys = json.load(f)
            except Exception:
                pass
    
    def find_npc_file(self, npc_name: str) -> Optional[Path]:
        """Find NPC file by name"""
        # Try exact match
        exact = self.npc_dir / f"{npc_name}.lua"
        if exact.exists():
            return exact
        
        # Try case-insensitive search
        for f in self.npc_dir.glob("*.lua"):
            if f.stem.lower() == npc_name.lower():
                return f
        
        return None
    
    def extract_strings(self, file_path: Path) -> List[NPCString]:
        """Extract all translatable strings from NPC file"""
        strings = []
        
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.split('\n')
        
        for pattern, context in self.STRING_PATTERNS:
            for match in re.finditer(pattern, content):
                text = match.group(1)
                
                # Skip if matches skip patterns
                if self._should_skip(text):
                    continue
                
                # Find line number
                start_pos = match.start()
                line_number = content[:start_pos].count('\n') + 1
                
                # Get full function call for replacement reference
                function_call = match.group(0)
                
                npc_string = NPCString(
                    text=text,
                    line_number=line_number,
                    context=context,
                    function_call=function_call
                )
                
                strings.append(npc_string)
        
        return strings
    
    def _should_skip(self, text: str) -> bool:
        """Check if string should be skipped"""
        if len(text) < 5:
            return True
        
        for pattern in self.SKIP_PATTERNS:
            if re.match(pattern, text, re.IGNORECASE):
                return True
        
        return False
    
    def generate_keys(self, npc_name: str, strings: List[NPCString]) -> Dict[str, str]:
        """Generate i18n keys for extracted strings"""
        keys = {}
        key_counter = {}
        
        for s in strings:
            # Generate key based on context and content
            base_key = self._generate_key_name(npc_name, s)
            
            # Handle duplicates
            if base_key in key_counter:
                key_counter[base_key] += 1
                key = f"{base_key}_{key_counter[base_key]}"
            else:
                key_counter[base_key] = 1
                key = base_key
            
            s.suggested_key = key
            keys[key] = s.text
        
        return keys
    
    def _generate_key_name(self, npc_name: str, s: NPCString) -> str:
        """Generate a descriptive key name"""
        # Normalize NPC name
        npc_slug = npc_name.lower().replace(" ", "_").replace("-", "_")
        
        # Generate suffix from text
        words = re.findall(r'\b[a-zA-Z]{3,}\b', s.text.lower())[:3]
        
        # Map context to key prefix
        context_map = {
            'say': 'dialog',
            'selfSay': 'dialog',
            'setMessage': 'greeting' if 'greet' in s.function_call.lower() else 'message',
            'sendTextMessage': 'notify',
            'addFocusMessage': 'focus',
            'npcSay': 'dialog',
        }
        
        prefix = context_map.get(s.context, 'text')
        
        if words:
            suffix = "_".join(words)
            return f"npc.{npc_slug}.{prefix}.{suffix}"
        else:
            return f"npc.{npc_slug}.{prefix}"
    
    def generate_migration(self, file_path: Path) -> MigrationResult:
        """Generate complete migration for an NPC file"""
        npc_name = file_path.stem
        result = MigrationResult(npc_name=npc_name, file_path=str(file_path))
        
        try:
            # Extract strings
            result.strings_found = self.extract_strings(file_path)
            
            if not result.strings_found:
                result.success = True
                result.error = "No translatable strings found"
                return result
            
            # Generate keys
            result.keys_generated = self.generate_keys(npc_name, result.strings_found)
            
            # Generate modified content
            result.modified_content = self._generate_modified_content(file_path, result.strings_found)
            
            result.success = True
            
        except Exception as e:
            result.error = str(e)
            result.success = False
        
        return result
    
    def _generate_modified_content(self, file_path: Path, strings: List[NPCString]) -> str:
        """Generate modified NPC file content with i18n calls"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Sort by line number descending (to replace from end to start)
        sorted_strings = sorted(strings, key=lambda x: x.line_number, reverse=True)
        
        for s in sorted_strings:
            if not s.suggested_key:
                continue
            
            # Generate replacement based on context
            replacement = self._generate_replacement(s)
            
            # Replace in content
            content = content.replace(f'"{s.text}"', replacement, 1)
        
        return content
    
    def _generate_replacement(self, s: NPCString) -> str:
        """Generate i18n replacement call"""
        key = s.suggested_key
        
        if s.context in ['say', 'selfSay', 'npcSay']:
            return f'NPC_LIB.i18n.getText(player, "{key}")'
        elif s.context == 'setMessage':
            return f'NPC_LIB.i18n.getText(player, "{key}")'
        elif s.context == 'sendTextMessage':
            return f'i18n.translate(player, "{key}")'
        else:
            return f'i18n.translate(player, "{key}")'
    
    def save_translations(self, result: MigrationResult, locales: List[str] = None) -> None:
        """Save generated translations to JSON files"""
        if locales is None:
            locales = ['en', 'pl', 'de', 'es', 'pt']
        
        for locale in locales:
            locale_dir = self.i18n_root / locale
            locale_dir.mkdir(parents=True, exist_ok=True)
            
            npc_json = locale_dir / "npc.json"
            
            # Load existing
            existing = {}
            if npc_json.exists():
                with open(npc_json, 'r', encoding='utf-8') as f:
                    existing = json.load(f)
            
            # Merge new keys
            existing.update(result.keys_generated)
            
            # Save
            with open(npc_json, 'w', encoding='utf-8') as f:
                json.dump(existing, f, indent=2, ensure_ascii=False, sort_keys=True)
    
    def apply_migration(self, result: MigrationResult) -> bool:
        """Apply migration to NPC file"""
        if not result.success or not result.modified_content:
            return False
        
        try:
            # Backup original
            backup_path = Path(result.file_path + ".bak")
            with open(result.file_path, 'r', encoding='utf-8') as f:
                backup_content = f.read()
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(backup_content)
            
            # Write modified
            with open(result.file_path, 'w', encoding='utf-8') as f:
                f.write(result.modified_content)
            
            return True
        except Exception as e:
            print(f"Error applying migration: {e}")
            return False
    
    def print_report(self, result: MigrationResult) -> None:
        """Print migration report"""
        print("\n" + "=" * 70)
        print(f"NPC MIGRATION REPORT: {result.npc_name}")
        print("=" * 70)
        
        if not result.success:
            print(f"❌ ERROR: {result.error}")
            return
        
        print(f"\n📁 File: {result.file_path}")
        print(f"📊 Strings found: {len(result.strings_found)}")
        print(f"🔑 Keys generated: {len(result.keys_generated)}")
        
        if result.strings_found:
            print(f"\n📝 EXTRACTED STRINGS:")
            for s in result.strings_found[:10]:  # Show first 10
                preview = s.text[:50] + "..." if len(s.text) > 50 else s.text
                print(f"   L{s.line_number:4d} [{s.context:15s}] \"{preview}\"")
                print(f"         → {s.suggested_key}")
            
            if len(result.strings_found) > 10:
                print(f"   ... and {len(result.strings_found) - 10} more")
        
        print(f"\n🔑 GENERATED KEYS:")
        for key, value in list(result.keys_generated.items())[:5]:
            preview = value[:40] + "..." if len(value) > 40 else value
            print(f"   {key}")
            print(f"      = \"{preview}\"")
        
        if len(result.keys_generated) > 5:
            print(f"   ... and {len(result.keys_generated) - 5} more")
        
        print("\n" + "=" * 70)


def main():
    parser = argparse.ArgumentParser(description="NPC i18n Migrator for Canary OTS")
    parser.add_argument('--npc', type=str, help='NPC name to migrate')
    parser.add_argument('--file', type=str, help='Direct path to NPC file')
    parser.add_argument('--npc-dir', type=str, default='data-otservbr-global/npc',
                        help='NPC directory')
    parser.add_argument('--i18n-root', type=str, default='i18n',
                        help='i18n translations root')
    parser.add_argument('--apply', action='store_true',
                        help='Apply changes to NPC file')
    parser.add_argument('--save-json', action='store_true',
                        help='Save translations to JSON')
    parser.add_argument('--batch', action='store_true',
                        help='Process all NPCs')
    parser.add_argument('--limit', type=int, default=10,
                        help='Limit batch processing')
    parser.add_argument('--output-diff', type=str,
                        help='Save diff to file')
    
    args = parser.parse_args()
    
    npc_dir = Path(args.npc_dir)
    i18n_root = Path(args.i18n_root)
    
    migrator = NPCMigrator(npc_dir, i18n_root)
    
    if args.batch:
        # Batch processing
        processed = 0
        for npc_file in sorted(npc_dir.glob("*.lua")):
            if processed >= args.limit:
                break
            
            result = migrator.generate_migration(npc_file)
            
            if result.strings_found:
                migrator.print_report(result)
                
                if args.save_json:
                    migrator.save_translations(result)
                    print("✅ Translations saved to JSON")
                
                if args.apply:
                    if migrator.apply_migration(result):
                        print("✅ Migration applied to NPC file")
                
                processed += 1
        
        print(f"\n📊 Processed {processed} NPCs")
        
    elif args.npc or args.file:
        # Single NPC
        if args.file:
            file_path = Path(args.file)
        else:
            file_path = migrator.find_npc_file(args.npc)
            if not file_path:
                print(f"Error: NPC '{args.npc}' not found")
                sys.exit(1)
        
        result = migrator.generate_migration(file_path)
        migrator.print_report(result)
        
        if args.output_diff and result.modified_content:
            with open(args.output_diff, 'w', encoding='utf-8') as f:
                f.write(result.modified_content)
            print(f"📄 Modified content saved to: {args.output_diff}")
        
        if args.save_json:
            migrator.save_translations(result)
            print("✅ Translations saved to JSON")
        
        if args.apply:
            if migrator.apply_migration(result):
                print("✅ Migration applied to NPC file")
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
