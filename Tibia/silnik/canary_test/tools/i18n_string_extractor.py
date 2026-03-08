#!/usr/bin/env python3
"""
I18N String Extractor Pro - Zaawansowane ekstraktor stringów z kodu
===================================================================

Funkcje:
- Ekstrakcja stringów z różnych typów plików (Lua, C++, Python)
- Inteligentna kategoryzacja stringów
- Automatyczne generowanie kluczy i18n
- Wykrywanie kontekstu użycia
- Obsługa placeholderów i formatowania

Usage:
    python3 tools/i18n_string_extractor.py --file src/game/game.cpp
    python3 tools/i18n_string_extractor.py --dir data-otservbr-global/scripts --output extracted.json
    python3 tools/i18n_string_extractor.py --file npc.lua --generate-keys
"""

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


@dataclass
class ExtractedString:
    """Represents an extracted string"""
    text: str
    file: str
    line: int
    context: str  # function/method name
    category: str  # npc, combat, quest, system, etc.
    suggested_key: str
    placeholders: List[str] = field(default_factory=list)
    function_call: str = ""


class StringExtractor:
    """Advanced string extraction from source files"""
    
    # Lua patterns
    LUA_PATTERNS = [
        # NPC patterns
        (r'npcHandler:say\s*\(\s*"([^"]+)"', 'npc', 'npcHandler:say'),
        (r'npcHandler:say\s*\(\s*\'([^\']+)\'', 'npc', 'npcHandler:say'),
        (r'selfSay\s*\(\s*"([^"]+)"', 'npc', 'selfSay'),
        (r'npc:say\s*\(\s*"([^"]+)"', 'npc', 'npc:say'),
        
        # Player messages
        (r'player:sendTextMessage\s*\(\s*[\w\.]+\s*,\s*"([^"]+)"', 'player_message', 'sendTextMessage'),
        (r'sendTextMessage\s*\(\s*[\w\.]+\s*,\s*"([^"]+)"', 'player_message', 'sendTextMessage'),
        
        # Creature messages
        (r'creature:say\s*\(\s*"([^"]+)"', 'creature', 'creature:say'),
        (r'monster:say\s*\(\s*"([^"]+)"', 'creature', 'monster:say'),
        
        # Quest/Action messages
        (r'setMessage\s*\(\s*\w+\s*,\s*"([^"]+)"', 'quest', 'setMessage'),
        (r'doPlayerSendTextMessage\s*\([^,]+,\s*"([^"]+)"', 'quest', 'doPlayerSendTextMessage'),
        
        # Channel messages
        (r'broadcastMessage\s*\(\s*"([^"]+)"', 'broadcast', 'broadcastMessage'),
        
        # General strings
        (r'print\s*\(\s*"([^"]+)"', 'debug', 'print'),
    ]
    
    # C++ patterns
    CPP_PATTERNS = [
        (r'sendTextMessage\s*\(\s*\w+\s*,\s*"([^"]+)"', 'player_message', 'sendTextMessage'),
        (r'player->sendTextMessage\s*\([^,]+,\s*"([^"]+)"', 'player_message', 'sendTextMessage'),
        (r'Translator::translate\s*\(\s*"([^"]+)"', 'translated', 'Translator::translate'),
        (r'fmt::format\s*\(\s*"([^"]+)"', 'formatted', 'fmt::format'),
        (r'g_logger\(\)\.\w+\s*\(\s*"([^"]+)"', 'log', 'g_logger'),
    ]
    
    # Skip patterns (not translatable)
    SKIP_PATTERNS = [
        r'^[a-z_]+$',  # Single word identifiers
        r'^[A-Z_]+$',  # Constants
        r'^\d+$',  # Numbers
        r'^[a-z]+\.[a-z]+$',  # File extensions
        r'^https?://',  # URLs
        r'^\{[^}]+:[^}]+\}$',  # JSON object-like payloads
        r'^SELECT|INSERT|UPDATE|DELETE',  # SQL
        r'^[<>/]',  # XML/HTML tags
    ]
    
    # Placeholder patterns
    PLACEHOLDER_PATTERNS = [
        r'\{\d+\}',  # {0}, {1}
        r'\{\w+\}',  # {name}, {player}
        r'%[sdif]',  # %s, %d, %i, %f
        r'\|[A-Z]+\|',  # |PLAYERNAME|
        r'\[[A-Za-z_][A-Za-z0-9_]*(?:\s+[A-Za-z_][A-Za-z0-9_]*)*\]',  # [player name]
    ]
    
    # Category keywords for auto-detection
    CATEGORY_KEYWORDS = {
        'combat': ['damage', 'health', 'mana', 'attack', 'defense', 'kill', 'die', 'hit', 'critical'],
        'quest': ['quest', 'mission', 'reward', 'complete', 'accept', 'decline', 'objective'],
        'npc': ['hello', 'greet', 'goodbye', 'farewell', 'trade', 'offer', 'buy', 'sell'],
        'item': ['item', 'weapon', 'armor', 'potion', 'rune', 'backpack', 'equipment'],
        'system': ['error', 'warning', 'info', 'loading', 'saving', 'config', 'server'],
        'player': ['level', 'experience', 'skill', 'vocation', 'premium', 'account'],
    }
    
    def __init__(self, min_length: int = 10):
        self.min_length = min_length
        self.extracted: List[ExtractedString] = []
    
    def extract_from_file(self, file_path: Path) -> List[ExtractedString]:
        """Extract strings from a single file"""
        strings = []
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                lines = content.split('\n')
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return strings
        
        # Determine file type
        suffix = file_path.suffix.lower()
        
        if suffix == '.lua':
            patterns = self.LUA_PATTERNS
        elif suffix in ['.cpp', '.hpp', '.c', '.h']:
            patterns = self.CPP_PATTERNS
        else:
            return strings
        
        for pattern, default_category, func_call in patterns:
            for match in re.finditer(pattern, content, re.MULTILINE):
                text = match.group(1)
                
                # Skip if too short
                if len(text) < self.min_length:
                    continue
                
                # Skip non-translatable strings
                if self._should_skip(text):
                    continue
                
                # Find line number
                start_pos = match.start()
                line_num = content[:start_pos].count('\n') + 1
                
                # Detect category
                category = self._detect_category(text, default_category)
                
                # Find placeholders
                placeholders = self._find_placeholders(text)
                
                # Generate suggested key
                suggested_key = self._generate_key(text, file_path, category)
                
                extracted = ExtractedString(
                    text=text,
                    file=str(file_path),
                    line=line_num,
                    context=self._find_context(lines, line_num),
                    category=category,
                    suggested_key=suggested_key,
                    placeholders=placeholders,
                    function_call=func_call
                )
                strings.append(extracted)
        
        self.extracted.extend(strings)
        return strings
    
    def _should_skip(self, text: str) -> bool:
        """Check if string should be skipped"""
        for pattern in self.SKIP_PATTERNS:
            if re.match(pattern, text, re.IGNORECASE):
                return True
        return False
    
    def _detect_category(self, text: str, default: str) -> str:
        """Detect category based on content"""
        text_lower = text.lower()
        
        for category, keywords in self.CATEGORY_KEYWORDS.items():
            for keyword in keywords:
                if keyword in text_lower:
                    return category
        
        return default
    
    def _find_placeholders(self, text: str) -> List[str]:
        """Find placeholders in text"""
        placeholders = []
        
        for pattern in self.PLACEHOLDER_PATTERNS:
            placeholders.extend(match.group(0) for match in re.finditer(pattern, text))
        
        return list(dict.fromkeys(placeholders))
    
    def _find_context(self, lines: List[str], line_num: int) -> str:
        """Find function/method context"""
        # Look backwards for function definition
        for i in range(line_num - 1, max(0, line_num - 20), -1):
            line = lines[i]
            
            # Lua function
            func_match = re.search(r'function\s+(\w+)', line)
            if func_match:
                return func_match.group(1)
            
            # C++ function
            cpp_match = re.search(r'(\w+)\s*\([^)]*\)\s*{', line)
            if cpp_match:
                return cpp_match.group(1)
        
        return "unknown"
    
    def _generate_key(self, text: str, file_path: Path, category: str) -> str:
        """Generate i18n key from text"""
        # Get file name without extension
        file_name = file_path.stem.lower()
        
        # Clean text for key
        words = re.findall(r'[a-zA-Z]+', text.lower())[:5]
        key_part = '_'.join(words)
        
        # Truncate if too long
        if len(key_part) > 30:
            key_part = key_part[:30]
        
        return f"{category}.{file_name}.{key_part}"
    
    def extract_from_directory(self, directory: Path, 
                               patterns: List[str] = ["*.lua", "*.cpp"]) -> List[ExtractedString]:
        """Extract from all files in directory"""
        all_strings = []
        
        for pattern in patterns:
            for file_path in directory.rglob(pattern):
                strings = self.extract_from_file(file_path)
                all_strings.extend(strings)
        
        return all_strings
    
    def to_json(self) -> Dict:
        """Convert extracted strings to JSON format"""
        result = {
            "extracted_at": datetime.now().isoformat(),
            "total_strings": len(self.extracted),
            "by_category": {},
            "strings": []
        }
        
        # Count by category
        for s in self.extracted:
            if s.category not in result["by_category"]:
                result["by_category"][s.category] = 0
            result["by_category"][s.category] += 1
        
        # Add strings
        for s in self.extracted:
            result["strings"].append({
                "text": s.text,
                "file": s.file,
                "line": s.line,
                "context": s.context,
                "category": s.category,
                "suggested_key": s.suggested_key,
                "placeholders": s.placeholders,
                "function_call": s.function_call,
            })
        
        return result
    
    def generate_i18n_keys(self) -> Dict[str, str]:
        """Generate i18n keys dictionary"""
        keys = {}
        
        for s in self.extracted:
            # Ensure unique key
            key = s.suggested_key
            counter = 1
            while key in keys:
                key = f"{s.suggested_key}_{counter}"
                counter += 1
            
            keys[key] = s.text
        
        return keys
    
    def generate_report(self) -> str:
        """Generate extraction report"""
        report = f"""# I18N String Extraction Report

**Generated:** {datetime.now().isoformat()}
**Total Strings:** {len(self.extracted)}

## By Category

| Category | Count |
|----------|-------|
"""
        
        # Count by category
        by_cat: Dict[str, int] = {}
        for s in self.extracted:
            if s.category not in by_cat:
                by_cat[s.category] = 0
            by_cat[s.category] += 1
        
        for cat, count in sorted(by_cat.items(), key=lambda x: x[1], reverse=True):
            report += f"| {cat} | {count} |\n"
        
        report += "\n## By File\n\n"
        
        # Count by file
        by_file: Dict[str, int] = {}
        for s in self.extracted:
            fname = Path(s.file).name
            if fname not in by_file:
                by_file[fname] = 0
            by_file[fname] += 1
        
        for fname, count in sorted(by_file.items(), key=lambda x: x[1], reverse=True)[:20]:
            report += f"- {fname}: {count}\n"
        
        report += "\n## Sample Strings\n\n"
        
        for cat in by_cat.keys():
            strings = [s for s in self.extracted if s.category == cat][:3]
            report += f"\n### {cat.upper()}\n\n"
            for s in strings:
                report += f"- `{s.suggested_key}`: \"{s.text[:80]}...\"\n"
        
        return report


def main():
    parser = argparse.ArgumentParser(description="I18N String Extractor Pro")
    parser.add_argument('--file', type=str, help='Single file to extract from')
    parser.add_argument('--dir', type=str, help='Directory to extract from')
    parser.add_argument('--patterns', nargs='+', default=['*.lua', '*.cpp'],
                        help='File patterns to match')
    parser.add_argument('--min-length', type=int, default=10,
                        help='Minimum string length')
    parser.add_argument('--output', type=str, help='Output JSON file')
    parser.add_argument('--generate-keys', action='store_true',
                        help='Generate i18n keys file')
    parser.add_argument('--report', type=str, help='Generate report to file')
    parser.add_argument('--category', type=str, help='Filter by category')
    
    args = parser.parse_args()
    
    extractor = StringExtractor(min_length=args.min_length)
    
    # Extract from file
    if args.file:
        print(f"\n🔍 Extracting from: {args.file}")
        strings = extractor.extract_from_file(Path(args.file))
        print(f"   Found: {len(strings)} strings")
    
    # Extract from directory
    if args.dir:
        print(f"\n🔍 Extracting from: {args.dir}")
        print(f"   Patterns: {args.patterns}")
        strings = extractor.extract_from_directory(Path(args.dir), args.patterns)
        print(f"   Found: {len(strings)} strings")
    
    # Filter by category
    if args.category:
        extractor.extracted = [s for s in extractor.extracted 
                               if s.category == args.category]
        print(f"   Filtered to {args.category}: {len(extractor.extracted)}")
    
    # Show results
    if extractor.extracted:
        print(f"\n📊 RESULTS")
        
        # By category
        by_cat: Dict[str, int] = {}
        for s in extractor.extracted:
            if s.category not in by_cat:
                by_cat[s.category] = 0
            by_cat[s.category] += 1
        
        print(f"\n   By Category:")
        for cat, count in sorted(by_cat.items(), key=lambda x: x[1], reverse=True):
            print(f"     {cat}: {count}")
        
        # Sample
        print(f"\n📝 SAMPLE STRINGS:")
        for s in extractor.extracted[:5]:
            print(f"\n   Key: {s.suggested_key}")
            print(f"   Text: \"{s.text[:80]}...\"")
            print(f"   File: {Path(s.file).name}:{s.line}")
            if s.placeholders:
                print(f"   Placeholders: {s.placeholders}")
    
    # Save output
    if args.output:
        data = extractor.to_json()
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"\n✅ Saved to: {args.output}")
    
    # Generate keys
    if args.generate_keys:
        keys = extractor.generate_i18n_keys()
        keys_file = args.output or "i18n_keys.json"
        keys_file = keys_file.replace('.json', '_keys.json')
        
        with open(keys_file, 'w', encoding='utf-8') as f:
            json.dump(keys, f, indent=2, ensure_ascii=False)
        print(f"\n✅ Generated {len(keys)} keys: {keys_file}")
    
    # Generate report
    if args.report:
        report = extractor.generate_report()
        with open(args.report, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"\n📄 Report saved to: {args.report}")


if __name__ == '__main__':
    main()
