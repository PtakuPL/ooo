#!/usr/bin/env python3
"""
I18N Translation Memory - System pamięci tłumaczeń dla spójności
================================================================

Funkcje:
- Buduje bazę dotychczasowych tłumaczeń (translation memory)
- Automatycznie sugeruje tłumaczenia dla nowych tekstów na podstawie podobnych
- Wykrywa niespójności (te same frazy tłumaczone różnie)
- Eksportuje/importuje pamięć tłumaczeń do wymiany z tłumaczami
- Format TMX (Translation Memory eXchange) compatible

Usage:
    python3 tools/i18n_translation_memory.py --build
    python3 tools/i18n_translation_memory.py --suggest "Your health is low"
    python3 tools/i18n_translation_memory.py --find-inconsistencies --locale pl
"""

import argparse
import json
import re
from collections import defaultdict
from dataclasses import dataclass
from difflib import SequenceMatcher, get_close_matches
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import xml.etree.ElementTree as ET
from datetime import datetime


@dataclass
class TranslationUnit:
    """Single translation memory entry"""
    source: str
    target: str
    source_lang: str
    target_lang: str
    context: str = ""
    key: str = ""
    score: float = 1.0


class TranslationMemory:
    """Translation Memory system"""
    
    def __init__(self, i18n_root: Path):
        self.i18n_root = i18n_root
        self.memory: Dict[str, List[TranslationUnit]] = defaultdict(list)
        self.source_lang = "en"
        
    def build_from_i18n(self, target_locales: List[str] = None) -> int:
        """Build TM from existing i18n files"""
        if target_locales is None:
            target_locales = ['pl', 'de', 'es', 'pt']
        
        # Load English as source
        en_dir = self.i18n_root / "en"
        if not en_dir.exists():
            return 0
        
        en_strings = {}
        for json_file in en_dir.glob("*.json"):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                self._flatten_json(data, json_file.stem, en_strings)
            except Exception:
                pass
        
        count = 0
        
        # Load target languages and create TM entries
        for locale in target_locales:
            locale_dir = self.i18n_root / locale
            if not locale_dir.exists():
                continue
            
            target_strings = {}
            for json_file in locale_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    self._flatten_json(data, json_file.stem, target_strings)
                except Exception:
                    pass
            
            # Create TU for each matching pair
            for key, source in en_strings.items():
                if key in target_strings:
                    target = target_strings[key]
                    
                    # Skip if identical (not translated)
                    if source == target:
                        continue
                    
                    tu = TranslationUnit(
                        source=source,
                        target=target,
                        source_lang=self.source_lang,
                        target_lang=locale,
                        context=key.split('.')[0],
                        key=key
                    )
                    
                    # Index by normalized source
                    normalized = self._normalize(source)
                    self.memory[f"{locale}:{normalized}"].append(tu)
                    count += 1
        
        return count
    
    def _flatten_json(self, data: dict, prefix: str, result: dict) -> None:
        """Flatten nested JSON to key-value pairs"""
        for key, value in data.items():
            full_key = f"{prefix}.{key}"
            if isinstance(value, dict):
                self._flatten_json(value, full_key, result)
            elif isinstance(value, str):
                result[full_key] = value
    
    def _normalize(self, text: str) -> str:
        """Normalize text for matching"""
        text = text.lower().strip()
        # Remove placeholders
        text = re.sub(r'\{\d+\}', '{N}', text)
        text = re.sub(r'\{[a-zA-Z_]+\}', '{X}', text)
        return text
    
    def suggest_translation(self, source_text: str, target_lang: str, 
                           min_similarity: float = 0.7) -> List[Tuple[str, float, str]]:
        """Suggest translations based on TM"""
        normalized = self._normalize(source_text)
        suggestions = []
        
        # First check for exact match
        exact_key = f"{target_lang}:{normalized}"
        if exact_key in self.memory:
            for tu in self.memory[exact_key]:
                suggestions.append((tu.target, 1.0, tu.key))
        
        # Fuzzy match
        for tm_key, tus in self.memory.items():
            if not tm_key.startswith(f"{target_lang}:"):
                continue
            
            stored_normalized = tm_key.split(':', 1)[1]
            ratio = SequenceMatcher(None, normalized, stored_normalized).ratio()
            
            if ratio >= min_similarity and ratio < 1.0:
                for tu in tus:
                    suggestions.append((tu.target, ratio, tu.key))
        
        # Sort by similarity and deduplicate
        suggestions.sort(key=lambda x: x[1], reverse=True)
        seen = set()
        unique = []
        for trans, score, key in suggestions:
            if trans not in seen:
                seen.add(trans)
                unique.append((trans, score, key))
        
        return unique[:5]
    
    def find_inconsistencies(self, target_lang: str) -> List[Dict]:
        """Find same source text with different translations"""
        source_to_targets: Dict[str, Dict[str, List[str]]] = defaultdict(lambda: defaultdict(list))
        
        for tm_key, tus in self.memory.items():
            if not tm_key.startswith(f"{target_lang}:"):
                continue
            
            for tu in tus:
                source_to_targets[tu.source][tu.target].append(tu.key)
        
        inconsistencies = []
        for source, targets_dict in source_to_targets.items():
            if len(targets_dict) > 1:
                inconsistencies.append({
                    'source': source,
                    'translations': {
                        target: keys for target, keys in targets_dict.items()
                    },
                    'count': len(targets_dict)
                })
        
        return sorted(inconsistencies, key=lambda x: x['count'], reverse=True)
    
    def export_tmx(self, output_path: Path, target_lang: str) -> None:
        """Export TM to TMX format"""
        root = ET.Element('tmx', version="1.4")
        header = ET.SubElement(root, 'header',
            creationtool="canary-i18n",
            creationtoolversion="1.0",
            datatype="plaintext",
            segtype="sentence",
            adminlang="en",
            srclang=self.source_lang,
            creationdate=datetime.now().strftime("%Y%m%dT%H%M%SZ")
        )
        
        body = ET.SubElement(root, 'body')
        
        seen_sources = set()
        for tm_key, tus in self.memory.items():
            if not tm_key.startswith(f"{target_lang}:"):
                continue
            
            for tu in tus:
                if tu.source in seen_sources:
                    continue
                seen_sources.add(tu.source)
                
                tu_elem = ET.SubElement(body, 'tu')
                
                # Source
                tuv_src = ET.SubElement(tu_elem, 'tuv', lang=self.source_lang)
                seg_src = ET.SubElement(tuv_src, 'seg')
                seg_src.text = tu.source
                
                # Target
                tuv_tgt = ET.SubElement(tu_elem, 'tuv', lang=target_lang)
                seg_tgt = ET.SubElement(tuv_tgt, 'seg')
                seg_tgt.text = tu.target
        
        tree = ET.ElementTree(root)
        tree.write(output_path, encoding='utf-8', xml_declaration=True)
    
    def import_tmx(self, tmx_path: Path) -> int:
        """Import TMX file into memory"""
        tree = ET.parse(tmx_path)
        root = tree.getroot()
        
        count = 0
        for tu_elem in root.findall('.//tu'):
            tuvs = tu_elem.findall('tuv')
            if len(tuvs) < 2:
                continue
            
            source_tuv = tuvs[0]
            target_tuv = tuvs[1]
            
            source_lang = source_tuv.get('lang', source_tuv.get('{http://www.w3.org/XML/1998/namespace}lang', 'en'))
            target_lang = target_tuv.get('lang', target_tuv.get('{http://www.w3.org/XML/1998/namespace}lang', ''))
            
            source_text = source_tuv.find('seg').text or ""
            target_text = target_tuv.find('seg').text or ""
            
            if source_text and target_text:
                tu = TranslationUnit(
                    source=source_text,
                    target=target_text,
                    source_lang=source_lang,
                    target_lang=target_lang
                )
                
                normalized = self._normalize(source_text)
                self.memory[f"{target_lang}:{normalized}"].append(tu)
                count += 1
        
        return count
    
    def save(self, output_path: Path) -> None:
        """Save TM to JSON"""
        data = {
            'version': '1.0',
            'created': datetime.now().isoformat(),
            'entries': {}
        }
        
        for tm_key, tus in self.memory.items():
            data['entries'][tm_key] = [
                {
                    'source': tu.source,
                    'target': tu.target,
                    'source_lang': tu.source_lang,
                    'target_lang': tu.target_lang,
                    'context': tu.context,
                    'key': tu.key,
                }
                for tu in tus
            ]
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    
    def load(self, input_path: Path) -> None:
        """Load TM from JSON"""
        with open(input_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for tm_key, entries in data.get('entries', {}).items():
            for entry in entries:
                tu = TranslationUnit(
                    source=entry['source'],
                    target=entry['target'],
                    source_lang=entry.get('source_lang', 'en'),
                    target_lang=entry.get('target_lang', ''),
                    context=entry.get('context', ''),
                    key=entry.get('key', '')
                )
                self.memory[tm_key].append(tu)


def main():
    parser = argparse.ArgumentParser(description="I18N Translation Memory")
    parser.add_argument('--i18n-root', default='i18n', help='i18n root directory')
    parser.add_argument('--build', action='store_true', help='Build TM from i18n files')
    parser.add_argument('--suggest', type=str, help='Suggest translation for text')
    parser.add_argument('--locale', default='pl', help='Target locale')
    parser.add_argument('--find-inconsistencies', action='store_true', help='Find translation inconsistencies')
    parser.add_argument('--export-tmx', type=str, help='Export to TMX file')
    parser.add_argument('--import-tmx', type=str, help='Import TMX file')
    parser.add_argument('--save', type=str, help='Save TM to JSON')
    parser.add_argument('--load', type=str, help='Load TM from JSON')
    
    args = parser.parse_args()
    
    tm = TranslationMemory(Path(args.i18n_root))
    
    # Load existing TM if specified
    if args.load:
        tm.load(Path(args.load))
        print(f"✅ Loaded TM from: {args.load}")
    
    # Import TMX if specified
    if args.import_tmx:
        count = tm.import_tmx(Path(args.import_tmx))
        print(f"✅ Imported {count} entries from: {args.import_tmx}")
    
    # Build TM
    if args.build:
        count = tm.build_from_i18n()
        print(f"✅ Built TM with {count} translation units")
    
    # Suggest translation
    if args.suggest:
        if not tm.memory:
            tm.build_from_i18n([args.locale])
        
        suggestions = tm.suggest_translation(args.suggest, args.locale)
        
        print(f"\n💡 Suggestions for: \"{args.suggest}\" -> {args.locale}")
        if suggestions:
            for trans, score, key in suggestions:
                print(f"   [{score:.0%}] \"{trans}\"")
                print(f"         from: {key}")
        else:
            print("   No suggestions found")
    
    # Find inconsistencies
    if args.find_inconsistencies:
        if not tm.memory:
            tm.build_from_i18n([args.locale])
        
        inconsistencies = tm.find_inconsistencies(args.locale)
        
        print(f"\n⚠️ Found {len(inconsistencies)} inconsistencies in {args.locale}")
        for inc in inconsistencies[:10]:
            print(f"\n   Source: \"{inc['source'][:50]}...\"")
            print(f"   Translations ({inc['count']}):")
            for trans, keys in inc['translations'].items():
                print(f"      • \"{trans[:40]}...\" ({len(keys)} keys)")
    
    # Export TMX
    if args.export_tmx:
        if not tm.memory:
            tm.build_from_i18n([args.locale])
        tm.export_tmx(Path(args.export_tmx), args.locale)
        print(f"✅ Exported TMX to: {args.export_tmx}")
    
    # Save TM
    if args.save:
        tm.save(Path(args.save))
        print(f"✅ Saved TM to: {args.save}")


if __name__ == '__main__':
    main()
