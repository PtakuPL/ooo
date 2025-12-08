#!/usr/bin/env python3
"""
I18N String Deduplicator - Znajduje i łączy zduplikowane/podobne teksty
======================================================================

Funkcje:
- Wykrywa identyczne teksty w różnych plikach (do współdzielenia kluczy)
- Znajduje podobne teksty (fuzzy match) do ujednolicenia
- Generuje mapowanie: oryginalny tekst → wspólny klucz
- Sugeruje refaktoryzację (jeden klucz zamiast wielu)

Usage:
    python3 tools/i18n_deduplicator.py --threshold 0.85
    python3 tools/i18n_deduplicator.py --export-duplicates duplicates.json
"""

import argparse
import json
import re
from collections import defaultdict
from dataclasses import dataclass
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, List, Set, Tuple


@dataclass
class DuplicateGroup:
    """Group of duplicate/similar strings"""
    canonical_text: str
    canonical_key: str
    occurrences: List[Dict]  # [{key, text, file, similarity}]
    savings: int  # How many keys could be removed


class I18NDeduplicator:
    def __init__(self, i18n_root: Path, threshold: float = 0.9):
        self.i18n_root = i18n_root
        self.threshold = threshold
        self.all_strings: Dict[str, List[Dict]] = defaultdict(list)
        
    def load_translations(self, locale: str = "en") -> None:
        """Load all strings from a locale"""
        locale_dir = self.i18n_root / locale
        if not locale_dir.exists():
            return
            
        for json_file in locale_dir.glob("*.json"):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                category = json_file.stem
                self._extract_strings(data, category, str(json_file))
            except Exception as e:
                print(f"Warning: {json_file}: {e}")
    
    def _extract_strings(self, data: dict, prefix: str, source_file: str) -> None:
        """Recursively extract strings from JSON"""
        for key, value in data.items():
            full_key = f"{prefix}.{key}" if prefix else key
            
            if isinstance(value, dict):
                self._extract_strings(value, full_key, source_file)
            elif isinstance(value, str) and len(value) > 10:
                normalized = self._normalize(value)
                self.all_strings[normalized].append({
                    'key': full_key,
                    'text': value,
                    'file': source_file,
                })
    
    def _normalize(self, text: str) -> str:
        """Normalize text for comparison"""
        # Remove placeholders for comparison
        text = re.sub(r'\{\d+\}', '', text)
        text = re.sub(r'\{[a-zA-Z_]+\}', '', text)
        # Lowercase and strip
        return text.lower().strip()
    
    def find_exact_duplicates(self) -> List[DuplicateGroup]:
        """Find strings that are exactly the same"""
        groups = []
        
        for normalized, occurrences in self.all_strings.items():
            if len(occurrences) > 1:
                # Use shortest key as canonical
                sorted_occs = sorted(occurrences, key=lambda x: len(x['key']))
                canonical = sorted_occs[0]
                
                group = DuplicateGroup(
                    canonical_text=canonical['text'],
                    canonical_key=canonical['key'],
                    occurrences=[
                        {**occ, 'similarity': 1.0}
                        for occ in sorted_occs
                    ],
                    savings=len(occurrences) - 1
                )
                groups.append(group)
        
        return sorted(groups, key=lambda g: g.savings, reverse=True)
    
    def find_similar_strings(self) -> List[Tuple[str, str, float]]:
        """Find strings that are similar but not identical"""
        unique_texts = list(set(
            occ['text'] for occs in self.all_strings.values() for occ in occs
        ))
        
        similar = []
        checked = set()
        
        for i, text1 in enumerate(unique_texts):
            for text2 in unique_texts[i+1:]:
                if (text1, text2) in checked or (text2, text1) in checked:
                    continue
                    
                ratio = SequenceMatcher(None, text1.lower(), text2.lower()).ratio()
                
                if self.threshold <= ratio < 1.0:
                    similar.append((text1, text2, ratio))
                    checked.add((text1, text2))
        
        return sorted(similar, key=lambda x: x[2], reverse=True)
    
    def generate_report(self) -> dict:
        """Generate deduplication report"""
        exact = self.find_exact_duplicates()
        similar = self.find_similar_strings()
        
        total_strings = sum(len(occs) for occs in self.all_strings.values())
        duplicate_count = sum(g.savings for g in exact)
        
        return {
            'summary': {
                'total_strings': total_strings,
                'unique_strings': len(self.all_strings),
                'duplicate_groups': len(exact),
                'potential_savings': duplicate_count,
                'similar_pairs': len(similar),
            },
            'exact_duplicates': [
                {
                    'canonical_key': g.canonical_key,
                    'canonical_text': g.canonical_text[:100],
                    'count': len(g.occurrences),
                    'keys': [o['key'] for o in g.occurrences],
                }
                for g in exact[:50]
            ],
            'similar_strings': [
                {
                    'text1': t1[:80],
                    'text2': t2[:80],
                    'similarity': round(s, 2),
                }
                for t1, t2, s in similar[:30]
            ]
        }
    
    def print_report(self) -> None:
        """Print report to console"""
        report = self.generate_report()
        
        print("\n" + "=" * 70)
        print("I18N DEDUPLICATION REPORT")
        print("=" * 70)
        
        print(f"\n📊 SUMMARY")
        for k, v in report['summary'].items():
            print(f"   {k}: {v}")
        
        if report['exact_duplicates']:
            print(f"\n🔄 TOP EXACT DUPLICATES (can share same key)")
            for dup in report['exact_duplicates'][:10]:
                print(f"\n   [{dup['count']}x] \"{dup['canonical_text'][:50]}...\"")
                print(f"       Canonical: {dup['canonical_key']}")
                print(f"       Also at: {', '.join(dup['keys'][1:3])}")
                if len(dup['keys']) > 3:
                    print(f"       ... and {len(dup['keys']) - 3} more")
        
        if report['similar_strings']:
            print(f"\n🔍 SIMILAR STRINGS (consider unifying)")
            for sim in report['similar_strings'][:5]:
                print(f"\n   [{sim['similarity']}] Similar pair:")
                print(f"       A: \"{sim['text1']}\"")
                print(f"       B: \"{sim['text2']}\"")
        
        print("\n" + "=" * 70)


def main():
    parser = argparse.ArgumentParser(description="I18N Deduplicator")
    parser.add_argument('--i18n-root', default='i18n', help='i18n root directory')
    parser.add_argument('--locale', default='en', help='Locale to analyze')
    parser.add_argument('--threshold', type=float, default=0.85, help='Similarity threshold')
    parser.add_argument('--export', type=str, help='Export report to JSON')
    
    args = parser.parse_args()
    
    dedup = I18NDeduplicator(Path(args.i18n_root), args.threshold)
    dedup.load_translations(args.locale)
    dedup.print_report()
    
    if args.export:
        report = dedup.generate_report()
        with open(args.export, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"\n📄 Report exported to: {args.export}")


if __name__ == '__main__':
    main()
