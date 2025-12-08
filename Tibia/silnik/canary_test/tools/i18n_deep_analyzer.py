#!/usr/bin/env python3
"""
I18N Deep Analyzer - Szczegółowa analiza pokrycia i18n w kodzie źródłowym
=========================================================================

Funkcje:
- Wykrywa WSZYSTKIE hardkodowane stringi (nie tylko sendTextMessage)
- Analizuje kontekst użycia (NPC dialog, quest, system msg, error)
- Generuje raporty z priorytetyzacją
- Wykrywa potencjalne duplikaty i podobne teksty
- Sugeruje klucze i18n na podstawie kontekstu

Usage:
    python3 tools/i18n_deep_analyzer.py --roots data-otservbr-global src
    python3 tools/i18n_deep_analyzer.py --file data-otservbr-global/npc/some_npc.lua --detailed
"""

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

# Regex patterns for different string types
PATTERNS = {
    'lua_string_double': r'"([^"\\]|\\.){10,}"',
    'lua_string_single': r"'([^'\\]|\\.){10,}'",
    'lua_multiline': r'\[\[.{10,}?\]\]',
    'cpp_string': r'"([^"\\]|\\.){10,}"',
}

# Context detection patterns
CONTEXT_PATTERNS = {
    'npc_dialog': [
        r'npcHandler:say',
        r'selfSay',
        r'setMessage',
        r'npc:say',
        r'addFocusMessage',
    ],
    'player_message': [
        r'sendTextMessage',
        r'sendLocalizedTextMessage',
        r'player:sendTextMessage',
        r'sendMessageDialog',
    ],
    'quest_message': [
        r'QuestStatus',
        r'getStorageValue',
        r'setStorageValue',
        r'quest\.',
    ],
    'system_message': [
        r'MESSAGE_STATUS',
        r'MESSAGE_EVENT',
        r'MESSAGE_INFO',
        r'TALKTYPE_',
    ],
    'error_message': [
        r'error',
        r'cancel',
        r'failed',
        r'cannot',
        r'not enough',
        r'too heavy',
    ],
    'combat_message': [
        r'damage',
        r'heal',
        r'critical',
        r'blocked',
        r'resisted',
    ],
}

# Strings to skip (false positives)
SKIP_PATTERNS = [
    r'^[a-z_\.]+$',  # Pure keys like 'npc.name.greet'
    r'^[\d\s\.\-\+\*\/\(\)]+$',  # Numbers/math
    r'^[A-Z_]+$',  # Constants
    r'^https?://',  # URLs
    r'^[\{\}\[\]\(\)\<\>]+$',  # Brackets only
    r'^\s*$',  # Whitespace
    r'^function\s',  # Lua function definitions
    r'^local\s',  # Lua locals
    r'^\w+\s*=',  # Assignments
]


@dataclass
class StringOccurrence:
    """Single occurrence of a hardcoded string"""
    text: str
    file_path: str
    line_number: int
    context_type: str
    surrounding_code: str
    suggested_key: str = ""
    priority: int = 0  # 1=high, 2=medium, 3=low


@dataclass
class AnalysisResult:
    """Complete analysis result"""
    total_files: int = 0
    total_strings: int = 0
    by_context: Dict[str, List[StringOccurrence]] = field(default_factory=dict)
    duplicates: Dict[str, List[StringOccurrence]] = field(default_factory=dict)
    similar_strings: List[Tuple[str, str, float]] = field(default_factory=list)
    files_summary: Dict[str, int] = field(default_factory=dict)


class I18NDeepAnalyzer:
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.occurrences: List[StringOccurrence] = []
        self.existing_keys: Set[str] = set()
        
    def load_existing_translations(self, i18n_root: Path) -> None:
        """Load existing i18n keys to avoid suggesting duplicates"""
        if not i18n_root.exists():
            return
            
        en_dir = i18n_root / "en"
        if en_dir.exists():
            for json_file in en_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        self.existing_keys.update(data.keys())
                except Exception as e:
                    if self.verbose:
                        print(f"Warning: Could not load {json_file}: {e}")
                        
        if self.verbose:
            print(f"Loaded {len(self.existing_keys)} existing translation keys")
    
    def extract_strings_from_file(self, file_path: Path) -> List[StringOccurrence]:
        """Extract all hardcoded strings from a single file"""
        occurrences = []
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                lines = content.split('\n')
        except Exception as e:
            if self.verbose:
                print(f"Error reading {file_path}: {e}")
            return []
        
        suffix = file_path.suffix.lower()
        
        # Select appropriate patterns
        if suffix == '.lua':
            patterns = ['lua_string_double', 'lua_string_single', 'lua_multiline']
        elif suffix in ['.cpp', '.hpp', '.h', '.c']:
            patterns = ['cpp_string']
        else:
            return []
        
        for pattern_name in patterns:
            pattern = PATTERNS[pattern_name]
            
            for match in re.finditer(pattern, content, re.DOTALL):
                text = match.group(0)
                # Remove quotes
                if text.startswith('[['):
                    text = text[2:-2]
                else:
                    text = text[1:-1]
                
                # Skip if matches skip patterns
                if self._should_skip(text):
                    continue
                
                # Find line number
                start_pos = match.start()
                line_number = content[:start_pos].count('\n') + 1
                
                # Get surrounding context (3 lines before and after)
                start_line = max(0, line_number - 3)
                end_line = min(len(lines), line_number + 3)
                surrounding = '\n'.join(lines[start_line:end_line])
                
                # Detect context type
                context_type = self._detect_context(surrounding, text)
                
                # Generate suggested key
                suggested_key = self._suggest_key(text, file_path, context_type)
                
                # Calculate priority
                priority = self._calculate_priority(context_type, text)
                
                occurrence = StringOccurrence(
                    text=text,
                    file_path=str(file_path),
                    line_number=line_number,
                    context_type=context_type,
                    surrounding_code=surrounding,
                    suggested_key=suggested_key,
                    priority=priority
                )
                
                occurrences.append(occurrence)
        
        return occurrences
    
    def _should_skip(self, text: str) -> bool:
        """Check if string should be skipped"""
        for pattern in SKIP_PATTERNS:
            if re.match(pattern, text):
                return True
        
        # Skip very short strings
        if len(text.strip()) < 10:
            return True
            
        # Skip strings that are mostly non-letter characters
        letters = sum(1 for c in text if c.isalpha())
        if letters < len(text) * 0.4:
            return True
            
        return False
    
    def _detect_context(self, surrounding: str, text: str) -> str:
        """Detect the context type of the string"""
        surrounding_lower = surrounding.lower()
        text_lower = text.lower()
        
        for context_type, patterns in CONTEXT_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, surrounding_lower, re.IGNORECASE):
                    return context_type
                if re.search(pattern, text_lower, re.IGNORECASE):
                    return context_type
        
        return 'unknown'
    
    def _suggest_key(self, text: str, file_path: Path, context_type: str) -> str:
        """Generate a suggested i18n key based on context"""
        # Extract meaningful parts from file path
        parts = file_path.parts
        
        # Find category from path
        category = "system"
        if "npc" in parts:
            category = "npc"
            npc_name = file_path.stem.lower().replace(" ", "_")
        elif "quests" in parts or "quest" in str(file_path).lower():
            category = "quests"
        elif "scripts" in parts:
            category = "scripts"
        elif "game" in str(file_path).lower():
            category = "game"
        
        # Generate key suffix from text
        words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())[:3]
        suffix = "_".join(words) if words else "message"
        
        # Build key
        if category == "npc":
            npc_name = file_path.stem.lower().replace(" ", "_")
            return f"npc.{npc_name}.{suffix}"
        elif category == "quests":
            # Try to extract quest name from path
            for part in parts:
                if part not in ['scripts', 'quests', 'data-otservbr-global']:
                    quest_name = part.lower().replace(" ", "_")
                    return f"quests.{quest_name}.{suffix}"
        
        return f"{category}.{suffix}"
    
    def _calculate_priority(self, context_type: str, text: str) -> int:
        """Calculate priority (1=highest, 3=lowest)"""
        # Player-facing messages are highest priority
        if context_type in ['npc_dialog', 'player_message', 'quest_message']:
            return 1
        
        # System/combat messages are medium priority
        if context_type in ['system_message', 'combat_message']:
            return 2
        
        # Error messages and unknown are lower priority
        return 3
    
    def analyze_directory(self, root: Path, extensions: List[str] = None) -> None:
        """Analyze all files in a directory"""
        if extensions is None:
            extensions = ['.lua', '.cpp', '.hpp']
        
        for ext in extensions:
            for file_path in root.rglob(f"*{ext}"):
                if self.verbose:
                    print(f"Analyzing: {file_path}")
                
                file_occurrences = self.extract_strings_from_file(file_path)
                self.occurrences.extend(file_occurrences)
    
    def find_duplicates(self) -> Dict[str, List[StringOccurrence]]:
        """Find duplicate strings across files"""
        text_map: Dict[str, List[StringOccurrence]] = defaultdict(list)
        
        for occ in self.occurrences:
            # Normalize text for comparison
            normalized = occ.text.lower().strip()
            text_map[normalized].append(occ)
        
        # Return only actual duplicates (more than 1 occurrence)
        return {k: v for k, v in text_map.items() if len(v) > 1}
    
    def find_similar_strings(self, threshold: float = 0.8) -> List[Tuple[str, str, float]]:
        """Find similar (but not identical) strings"""
        unique_texts = list(set(occ.text for occ in self.occurrences))
        similar = []
        
        # Compare pairs (this is O(n²) but necessary for similarity)
        for i, text1 in enumerate(unique_texts):
            for text2 in unique_texts[i+1:]:
                ratio = SequenceMatcher(None, text1.lower(), text2.lower()).ratio()
                if ratio >= threshold and ratio < 1.0:
                    similar.append((text1, text2, ratio))
        
        return sorted(similar, key=lambda x: x[2], reverse=True)
    
    def generate_report(self) -> AnalysisResult:
        """Generate complete analysis report"""
        result = AnalysisResult()
        
        # Group by context
        result.by_context = defaultdict(list)
        for occ in self.occurrences:
            result.by_context[occ.context_type].append(occ)
        
        # Count by file
        result.files_summary = defaultdict(int)
        for occ in self.occurrences:
            result.files_summary[occ.file_path] += 1
        
        result.total_files = len(result.files_summary)
        result.total_strings = len(self.occurrences)
        result.duplicates = self.find_duplicates()
        result.similar_strings = self.find_similar_strings()
        
        return result
    
    def export_json(self, output_path: Path) -> None:
        """Export results to JSON"""
        result = self.generate_report()
        
        export_data = {
            "summary": {
                "total_files": result.total_files,
                "total_strings": result.total_strings,
                "by_context": {k: len(v) for k, v in result.by_context.items()},
                "duplicate_count": len(result.duplicates),
                "similar_strings_count": len(result.similar_strings),
            },
            "strings": [
                {
                    "text": occ.text,
                    "file": occ.file_path,
                    "line": occ.line_number,
                    "context": occ.context_type,
                    "suggested_key": occ.suggested_key,
                    "priority": occ.priority,
                }
                for occ in sorted(self.occurrences, key=lambda x: (x.priority, x.context_type))
            ],
            "duplicates": {
                text: [
                    {"file": occ.file_path, "line": occ.line_number}
                    for occ in occs
                ]
                for text, occs in result.duplicates.items()
            },
            "similar_strings": [
                {"text1": t1, "text2": t2, "similarity": sim}
                for t1, t2, sim in result.similar_strings[:50]  # Top 50
            ]
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)
    
    def export_csv(self, output_path: Path) -> None:
        """Export strings to CSV for translators"""
        import csv
        
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Priority', 'Context', 'Suggested Key', 'English Text', 
                'Translation (fill)', 'File', 'Line'
            ])
            
            for occ in sorted(self.occurrences, key=lambda x: (x.priority, x.context_type)):
                writer.writerow([
                    occ.priority,
                    occ.context_type,
                    occ.suggested_key,
                    occ.text,
                    '',  # Empty for translation
                    occ.file_path,
                    occ.line_number
                ])
    
    def print_summary(self) -> None:
        """Print analysis summary to console"""
        result = self.generate_report()
        
        print("\n" + "=" * 70)
        print("I18N DEEP ANALYSIS REPORT")
        print("=" * 70)
        
        print(f"\n📊 SUMMARY")
        print(f"   Total files analyzed: {result.total_files}")
        print(f"   Total strings found: {result.total_strings}")
        print(f"   Duplicate strings: {len(result.duplicates)}")
        print(f"   Similar strings: {len(result.similar_strings)}")
        
        print(f"\n📁 BY CONTEXT:")
        for context, occs in sorted(result.by_context.items(), key=lambda x: -len(x[1])):
            print(f"   {context}: {len(occs)} strings")
        
        print(f"\n⚡ TOP FILES (by string count):")
        for file_path, count in sorted(result.files_summary.items(), key=lambda x: -x[1])[:10]:
            print(f"   {count:4d} - {file_path}")
        
        print(f"\n🔁 MOST DUPLICATED STRINGS:")
        for text, occs in sorted(result.duplicates.items(), key=lambda x: -len(x[1]))[:5]:
            preview = text[:50] + "..." if len(text) > 50 else text
            print(f"   {len(occs)}x - \"{preview}\"")
        
        print(f"\n🎯 HIGH PRIORITY (P1) STRINGS:")
        p1_strings = [o for o in self.occurrences if o.priority == 1][:5]
        for occ in p1_strings:
            preview = occ.text[:40] + "..." if len(occ.text) > 40 else occ.text
            print(f"   [{occ.context_type}] \"{preview}\"")
            print(f"      → {occ.suggested_key}")
        
        print("\n" + "=" * 70)


def main():
    parser = argparse.ArgumentParser(description="Deep i18n analysis for Canary OTS")
    parser.add_argument('--roots', nargs='+', default=['data-otservbr-global', 'src'],
                        help='Root directories to analyze')
    parser.add_argument('--file', type=str, help='Analyze single file')
    parser.add_argument('--i18n-root', type=str, default='i18n',
                        help='i18n translations root directory')
    parser.add_argument('--output-json', type=str, help='Export results to JSON')
    parser.add_argument('--output-csv', type=str, help='Export strings to CSV')
    parser.add_argument('--detailed', action='store_true', help='Show detailed output')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose mode')
    
    args = parser.parse_args()
    
    analyzer = I18NDeepAnalyzer(verbose=args.verbose)
    
    # Load existing translations
    i18n_root = Path(args.i18n_root)
    analyzer.load_existing_translations(i18n_root)
    
    # Analyze
    if args.file:
        file_path = Path(args.file)
        if file_path.exists():
            occurrences = analyzer.extract_strings_from_file(file_path)
            analyzer.occurrences = occurrences
            print(f"Found {len(occurrences)} strings in {args.file}")
            
            if args.detailed:
                for occ in occurrences:
                    print(f"\n[{occ.context_type}] Line {occ.line_number}")
                    print(f"  Text: {occ.text[:60]}...")
                    print(f"  Key:  {occ.suggested_key}")
        else:
            print(f"File not found: {args.file}")
            sys.exit(1)
    else:
        for root in args.roots:
            root_path = Path(root)
            if root_path.exists():
                print(f"Analyzing {root}...")
                analyzer.analyze_directory(root_path)
            else:
                print(f"Warning: {root} not found, skipping")
    
    # Print summary
    analyzer.print_summary()
    
    # Export if requested
    if args.output_json:
        analyzer.export_json(Path(args.output_json))
        print(f"\n✅ JSON exported to: {args.output_json}")
    
    if args.output_csv:
        analyzer.export_csv(Path(args.output_csv))
        print(f"✅ CSV exported to: {args.output_csv}")


if __name__ == '__main__':
    main()
