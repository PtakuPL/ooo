#!/usr/bin/env python3
"""
I18N Conflict Resolver - Rozwiązywanie konfliktów w tłumaczeniach
================================================================

Funkcje:
- Wykrywa konflikty między różnymi źródłami tłumaczeń
- Porównuje różne wersje tłumaczeń
- Interaktywny tryb rozwiązywania konfliktów
- Automatyczne rozwiązywanie na podstawie reguł

Usage:
    python3 tools/i18n_conflict_resolver.py --detect i18n/pl
    python3 tools/i18n_conflict_resolver.py --resolve --auto
    python3 tools/i18n_conflict_resolver.py --merge file1.json file2.json -o merged.json
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass
from datetime import datetime
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class Conflict:
    """Represents a translation conflict"""
    key: str
    source_a: str  # File A value
    source_b: str  # File B value
    file_a: str
    file_b: str
    similarity: float
    resolved: bool = False
    resolution: str = ""


class ConflictResolver:
    """Handles translation conflict detection and resolution"""
    
    def __init__(self, i18n_dir: Path):
        self.i18n_dir = i18n_dir
        self.conflicts: List[Conflict] = []
    
    def load_json(self, file_path: Path) -> Dict:
        """Load JSON file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading {file_path}: {e}")
            return {}
    
    def similarity(self, a: str, b: str) -> float:
        """Calculate similarity between two strings"""
        return SequenceMatcher(None, a.lower(), b.lower()).ratio()
    
    def detect_conflicts(self, lang: str = "pl") -> List[Conflict]:
        """Detect conflicts within a language directory"""
        conflicts = []
        lang_dir = self.i18n_dir / lang
        
        if not lang_dir.exists():
            print(f"❌ Language directory not found: {lang_dir}")
            return conflicts
        
        # Load all JSON files
        all_translations: Dict[str, List[Tuple[str, str]]] = {}  # key -> [(file, value), ...]
        
        for json_file in lang_dir.glob("*.json"):
            data = self.load_json(json_file)
            
            for key, value in data.items():
                if key not in all_translations:
                    all_translations[key] = []
                all_translations[key].append((str(json_file), value))
        
        # Find conflicts (same key, different values)
        for key, sources in all_translations.items():
            if len(sources) < 2:
                continue
            
            # Group by value
            values: Dict[str, List[str]] = {}
            for file_path, value in sources:
                if value not in values:
                    values[value] = []
                values[value].append(file_path)
            
            if len(values) > 1:
                # Conflict detected
                value_list = list(values.items())
                for i in range(len(value_list)):
                    for j in range(i + 1, len(value_list)):
                        val_a, files_a = value_list[i]
                        val_b, files_b = value_list[j]
                        
                        conflict = Conflict(
                            key=key,
                            source_a=val_a,
                            source_b=val_b,
                            file_a=files_a[0],
                            file_b=files_b[0],
                            similarity=self.similarity(val_a, val_b)
                        )
                        conflicts.append(conflict)
        
        self.conflicts = conflicts
        return conflicts
    
    def detect_cross_file_duplicates(self) -> Dict[str, List[Tuple[str, str]]]:
        """Find same translations used for different keys"""
        value_to_keys: Dict[str, List[Tuple[str, str]]] = {}  # value -> [(key, file), ...]
        
        for json_file in self.i18n_dir.rglob("*.json"):
            data = self.load_json(json_file)
            
            for key, value in data.items():
                if not isinstance(value, str):
                    continue
                if len(value) < 20:  # Skip short strings
                    continue
                    
                if value not in value_to_keys:
                    value_to_keys[value] = []
                value_to_keys[value].append((key, str(json_file)))
        
        # Return only duplicates
        return {v: k for v, k in value_to_keys.items() if len(k) > 1}
    
    def auto_resolve(self, strategy: str = "longer") -> int:
        """Automatically resolve conflicts using a strategy"""
        resolved_count = 0
        
        for conflict in self.conflicts:
            if conflict.resolved:
                continue
            
            if strategy == "longer":
                # Prefer longer translation
                if len(conflict.source_a) >= len(conflict.source_b):
                    conflict.resolution = conflict.source_a
                else:
                    conflict.resolution = conflict.source_b
                conflict.resolved = True
                resolved_count += 1
                
            elif strategy == "first":
                # Use first source
                conflict.resolution = conflict.source_a
                conflict.resolved = True
                resolved_count += 1
                
            elif strategy == "similar":
                # If very similar, use longer one
                if conflict.similarity > 0.9:
                    if len(conflict.source_a) >= len(conflict.source_b):
                        conflict.resolution = conflict.source_a
                    else:
                        conflict.resolution = conflict.source_b
                    conflict.resolved = True
                    resolved_count += 1
        
        return resolved_count
    
    def merge_files(self, file_a: Path, file_b: Path, output: Path, 
                    prefer: str = "a") -> Dict:
        """Merge two translation files"""
        data_a = self.load_json(file_a)
        data_b = self.load_json(file_b)
        
        merged = {}
        stats = {
            'from_a': 0,
            'from_b': 0,
            'conflicts': 0,
            'total': 0,
        }
        
        # All keys from both files
        all_keys = set(data_a.keys()) | set(data_b.keys())
        
        for key in sorted(all_keys):
            val_a = data_a.get(key)
            val_b = data_b.get(key)
            
            if val_a and val_b:
                if val_a != val_b:
                    stats['conflicts'] += 1
                    if prefer == "a":
                        merged[key] = val_a
                        stats['from_a'] += 1
                    elif prefer == "b":
                        merged[key] = val_b
                        stats['from_b'] += 1
                    elif prefer == "longer":
                        merged[key] = val_a if len(str(val_a)) >= len(str(val_b)) else val_b
                        stats['from_a' if merged[key] == val_a else 'from_b'] += 1
                else:
                    merged[key] = val_a
                    stats['from_a'] += 1
            elif val_a:
                merged[key] = val_a
                stats['from_a'] += 1
            else:
                merged[key] = val_b
                stats['from_b'] += 1
            
            stats['total'] += 1
        
        # Save merged file
        with open(output, 'w', encoding='utf-8') as f:
            json.dump(merged, f, indent=2, ensure_ascii=False)
        
        return stats
    
    def generate_conflict_report(self) -> str:
        """Generate detailed conflict report"""
        report = f"""# I18N Conflict Report

**Generated:** {datetime.now().isoformat()}
**Total Conflicts:** {len(self.conflicts)}
**Resolved:** {sum(1 for c in self.conflicts if c.resolved)}

## Conflicts by Similarity

"""
        
        # Group by similarity
        high_sim = [c for c in self.conflicts if c.similarity >= 0.8]
        med_sim = [c for c in self.conflicts if 0.5 <= c.similarity < 0.8]
        low_sim = [c for c in self.conflicts if c.similarity < 0.5]
        
        report += f"### High Similarity (>80%) - {len(high_sim)} conflicts\n\n"
        for c in high_sim[:10]:
            report += f"""**Key:** `{c.key}`
- A ({Path(c.file_a).name}): "{c.source_a[:100]}..."
- B ({Path(c.file_b).name}): "{c.source_b[:100]}..."
- Similarity: {c.similarity:.1%}
- Status: {'✅ Resolved' if c.resolved else '❌ Pending'}

"""
        
        report += f"### Medium Similarity (50-80%) - {len(med_sim)} conflicts\n\n"
        for c in med_sim[:10]:
            report += f"""**Key:** `{c.key}`
- Similarity: {c.similarity:.1%}
- Status: {'✅ Resolved' if c.resolved else '❌ Pending'}

"""
        
        report += f"### Low Similarity (<50%) - {len(low_sim)} conflicts\n\n"
        report += "These may be completely different translations that need manual review.\n\n"
        
        return report


def main():
    parser = argparse.ArgumentParser(description="I18N Conflict Resolver")
    parser.add_argument('--i18n-dir', default='i18n', help='I18N directory')
    parser.add_argument('--detect', type=str, help='Detect conflicts in language')
    parser.add_argument('--resolve', action='store_true', help='Resolve conflicts')
    parser.add_argument('--auto', action='store_true', help='Use automatic resolution')
    parser.add_argument('--strategy', default='longer', 
                        choices=['longer', 'first', 'similar'],
                        help='Auto-resolution strategy')
    parser.add_argument('--merge', nargs=2, type=str, 
                        metavar=('FILE_A', 'FILE_B'),
                        help='Merge two files')
    parser.add_argument('-o', '--output', type=str, help='Output file')
    parser.add_argument('--prefer', default='a', choices=['a', 'b', 'longer'],
                        help='Prefer which source in conflicts')
    parser.add_argument('--duplicates', action='store_true',
                        help='Find cross-file duplicates')
    parser.add_argument('--report', type=str, help='Save report to file')
    
    args = parser.parse_args()
    
    resolver = ConflictResolver(Path(args.i18n_dir))
    
    # Detect conflicts
    if args.detect:
        print(f"\n🔍 Detecting conflicts in: {args.detect}")
        conflicts = resolver.detect_conflicts(args.detect)
        
        print(f"\n📊 RESULTS")
        print(f"   Total conflicts: {len(conflicts)}")
        
        if conflicts:
            high_sim = sum(1 for c in conflicts if c.similarity >= 0.8)
            med_sim = sum(1 for c in conflicts if 0.5 <= c.similarity < 0.8)
            low_sim = sum(1 for c in conflicts if c.similarity < 0.5)
            
            print(f"   High similarity (>80%): {high_sim}")
            print(f"   Medium similarity (50-80%): {med_sim}")
            print(f"   Low similarity (<50%): {low_sim}")
            
            print(f"\n🔥 SAMPLE CONFLICTS:")
            for c in conflicts[:5]:
                print(f"\n   Key: {c.key}")
                print(f"   A: \"{c.source_a[:60]}...\"")
                print(f"   B: \"{c.source_b[:60]}...\"")
                print(f"   Similarity: {c.similarity:.1%}")
        
        # Auto-resolve if requested
        if args.auto:
            resolved = resolver.auto_resolve(args.strategy)
            print(f"\n✅ Auto-resolved {resolved} conflicts using '{args.strategy}' strategy")
        
        # Save report
        if args.report:
            report = resolver.generate_conflict_report()
            with open(args.report, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"\n📄 Report saved to: {args.report}")
    
    # Merge files
    if args.merge:
        file_a, file_b = args.merge
        output = args.output or "merged.json"
        
        print(f"\n🔄 Merging files:")
        print(f"   A: {file_a}")
        print(f"   B: {file_b}")
        print(f"   Output: {output}")
        print(f"   Prefer: {args.prefer}")
        
        stats = resolver.merge_files(Path(file_a), Path(file_b), Path(output), args.prefer)
        
        print(f"\n📊 MERGE RESULTS")
        print(f"   From A: {stats['from_a']}")
        print(f"   From B: {stats['from_b']}")
        print(f"   Conflicts: {stats['conflicts']}")
        print(f"   Total keys: {stats['total']}")
    
    # Find duplicates
    if args.duplicates:
        print(f"\n🔍 Finding cross-file duplicates...")
        duplicates = resolver.detect_cross_file_duplicates()
        
        print(f"\n📊 Found {len(duplicates)} duplicate translations")
        
        for value, keys in list(duplicates.items())[:5]:
            print(f"\n   Value: \"{value[:60]}...\"")
            for key, file in keys[:3]:
                print(f"     - {key} ({Path(file).name})")


if __name__ == '__main__':
    main()
