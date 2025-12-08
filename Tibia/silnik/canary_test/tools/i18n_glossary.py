#!/usr/bin/env python3
"""
I18N Glossary Manager - Zarządzanie terminologią gier
====================================================

Funkcje:
- Tworzy i zarządza słownikiem terminów (glossary)
- Sprawdza spójność użycia terminów w tłumaczeniach
- Eksportuje/importuje słownik do formatów TBX/CSV
- Sugeruje tłumaczenia terminów na podstawie kontekstu

Usage:
    python3 tools/i18n_glossary.py --add "health" --pl "zdrowie" --de "Gesundheit"
    python3 tools/i18n_glossary.py --check-usage --locale pl
    python3 tools/i18n_glossary.py --export-csv glossary.csv
    python3 tools/i18n_glossary.py --import-csv glossary.csv
"""

import argparse
import csv
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set
import re


@dataclass
class GlossaryTerm:
    """Single glossary term with translations"""
    term: str  # English term
    translations: Dict[str, str] = field(default_factory=dict)  # locale -> translation
    context: str = ""  # Where this term is used
    definition: str = ""  # Explanation
    forbidden: List[str] = field(default_factory=list)  # Forbidden translations
    notes: str = ""


class GlossaryManager:
    """Manages i18n terminology glossary"""
    
    # Default gaming terms
    DEFAULT_TERMS = {
        'player': {'pl': 'gracz', 'de': 'Spieler', 'es': 'jugador', 'pt': 'jogador'},
        'health': {'pl': 'zdrowie', 'de': 'Gesundheit', 'es': 'salud', 'pt': 'saúde'},
        'mana': {'pl': 'mana', 'de': 'Mana', 'es': 'maná', 'pt': 'mana'},
        'experience': {'pl': 'doświadczenie', 'de': 'Erfahrung', 'es': 'experiencia', 'pt': 'experiência'},
        'level': {'pl': 'poziom', 'de': 'Stufe', 'es': 'nivel', 'pt': 'nível'},
        'gold': {'pl': 'złoto', 'de': 'Gold', 'es': 'oro', 'pt': 'ouro'},
        'item': {'pl': 'przedmiot', 'de': 'Gegenstand', 'es': 'objeto', 'pt': 'item'},
        'quest': {'pl': 'zadanie', 'de': 'Quest', 'es': 'misión', 'pt': 'missão'},
        'NPC': {'pl': 'NPC', 'de': 'NPC', 'es': 'NPC', 'pt': 'NPC'},
        'monster': {'pl': 'potwór', 'de': 'Monster', 'es': 'monstruo', 'pt': 'monstro'},
        'creature': {'pl': 'stworzenie', 'de': 'Kreatur', 'es': 'criatura', 'pt': 'criatura'},
        'spell': {'pl': 'zaklęcie', 'de': 'Zauber', 'es': 'hechizo', 'pt': 'feitiço'},
        'skill': {'pl': 'umiejętność', 'de': 'Fähigkeit', 'es': 'habilidad', 'pt': 'habilidade'},
        'damage': {'pl': 'obrażenia', 'de': 'Schaden', 'es': 'daño', 'pt': 'dano'},
        'armor': {'pl': 'zbroja', 'de': 'Rüstung', 'es': 'armadura', 'pt': 'armadura'},
        'weapon': {'pl': 'broń', 'de': 'Waffe', 'es': 'arma', 'pt': 'arma'},
        'potion': {'pl': 'mikstura', 'de': 'Trank', 'es': 'poción', 'pt': 'poção'},
        'rune': {'pl': 'runa', 'de': 'Rune', 'es': 'runa', 'pt': 'runa'},
        'backpack': {'pl': 'plecak', 'de': 'Rucksack', 'es': 'mochila', 'pt': 'mochila'},
        'depot': {'pl': 'schowek', 'de': 'Depot', 'es': 'depósito', 'pt': 'depósito'},
        'guild': {'pl': 'gildia', 'de': 'Gilde', 'es': 'gremio', 'pt': 'guilda'},
        'party': {'pl': 'drużyna', 'de': 'Gruppe', 'es': 'grupo', 'pt': 'grupo'},
        'blessing': {'pl': 'błogosławieństwo', 'de': 'Segen', 'es': 'bendición', 'pt': 'bênção'},
        'vocation': {'pl': 'profesja', 'de': 'Beruf', 'es': 'vocación', 'pt': 'vocação'},
        'knight': {'pl': 'rycerz', 'de': 'Ritter', 'es': 'caballero', 'pt': 'cavaleiro'},
        'paladin': {'pl': 'paladyn', 'de': 'Paladin', 'es': 'paladín', 'pt': 'paladino'},
        'sorcerer': {'pl': 'czarodziej', 'de': 'Zauberer', 'es': 'hechicero', 'pt': 'feiticeiro'},
        'druid': {'pl': 'druid', 'de': 'Druide', 'es': 'druida', 'pt': 'druida'},
    }
    
    def __init__(self, glossary_path: Path):
        self.glossary_path = glossary_path
        self.terms: Dict[str, GlossaryTerm] = {}
        self.load()
    
    def load(self) -> None:
        """Load glossary from file"""
        if self.glossary_path.exists():
            with open(self.glossary_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            for term_data in data.get('terms', []):
                term = GlossaryTerm(
                    term=term_data['term'],
                    translations=term_data.get('translations', {}),
                    context=term_data.get('context', ''),
                    definition=term_data.get('definition', ''),
                    forbidden=term_data.get('forbidden', []),
                    notes=term_data.get('notes', '')
                )
                self.terms[term.term.lower()] = term
        else:
            # Initialize with defaults
            for term, translations in self.DEFAULT_TERMS.items():
                self.terms[term.lower()] = GlossaryTerm(
                    term=term,
                    translations=translations
                )
    
    def save(self) -> None:
        """Save glossary to file"""
        data = {
            'version': '1.0',
            'terms': [
                {
                    'term': t.term,
                    'translations': t.translations,
                    'context': t.context,
                    'definition': t.definition,
                    'forbidden': t.forbidden,
                    'notes': t.notes,
                }
                for t in sorted(self.terms.values(), key=lambda x: x.term.lower())
            ]
        }
        
        self.glossary_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.glossary_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    
    def add_term(self, term: str, translations: Dict[str, str], 
                 context: str = "", definition: str = "") -> None:
        """Add or update a term"""
        key = term.lower()
        
        if key in self.terms:
            # Update existing
            self.terms[key].translations.update(translations)
            if context:
                self.terms[key].context = context
            if definition:
                self.terms[key].definition = definition
        else:
            # Add new
            self.terms[key] = GlossaryTerm(
                term=term,
                translations=translations,
                context=context,
                definition=definition
            )
    
    def get_translation(self, term: str, locale: str) -> Optional[str]:
        """Get translation for a term"""
        key = term.lower()
        if key in self.terms:
            return self.terms[key].translations.get(locale)
        return None
    
    def check_usage(self, i18n_root: Path, locale: str) -> List[Dict]:
        """Check if glossary terms are used consistently"""
        issues = []
        
        locale_dir = i18n_root / locale
        if not locale_dir.exists():
            return issues
        
        # Load all translations
        all_translations = {}
        for json_file in locale_dir.glob("*.json"):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                self._flatten_json(data, json_file.stem, all_translations)
            except Exception:
                pass
        
        # Load English for reference
        en_dir = i18n_root / "en"
        en_translations = {}
        for json_file in en_dir.glob("*.json"):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                self._flatten_json(data, json_file.stem, en_translations)
            except Exception:
                pass
        
        # Check each term
        for term_key, glossary_term in self.terms.items():
            expected = glossary_term.translations.get(locale)
            if not expected:
                continue
            
            # Find where this term appears in English
            for key, en_text in en_translations.items():
                if term_key in en_text.lower():
                    # Check if translation uses correct term
                    if key in all_translations:
                        tr_text = all_translations[key]
                        if expected.lower() not in tr_text.lower():
                            # Check for forbidden translations
                            for forbidden in glossary_term.forbidden:
                                if forbidden.lower() in tr_text.lower():
                                    issues.append({
                                        'type': 'forbidden',
                                        'term': glossary_term.term,
                                        'expected': expected,
                                        'found': forbidden,
                                        'key': key,
                                        'translation': tr_text[:100]
                                    })
        
        return issues
    
    def _flatten_json(self, data: dict, prefix: str, result: dict) -> None:
        """Flatten nested JSON"""
        for key, value in data.items():
            full_key = f"{prefix}.{key}"
            if isinstance(value, dict):
                self._flatten_json(value, full_key, result)
            elif isinstance(value, str):
                result[full_key] = value
    
    def export_csv(self, output_path: Path) -> None:
        """Export glossary to CSV"""
        # Get all locales
        locales = set()
        for term in self.terms.values():
            locales.update(term.translations.keys())
        locales = sorted(locales)
        
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            
            # Header
            header = ['Term (EN)', 'Context', 'Definition'] + [f'Translation ({loc})' for loc in locales]
            writer.writerow(header)
            
            # Terms
            for term in sorted(self.terms.values(), key=lambda x: x.term.lower()):
                row = [term.term, term.context, term.definition]
                for loc in locales:
                    row.append(term.translations.get(loc, ''))
                writer.writerow(row)
    
    def import_csv(self, input_path: Path) -> int:
        """Import glossary from CSV"""
        count = 0
        
        with open(input_path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            
            # Parse header to find locale columns
            locale_cols = {}
            for i, col in enumerate(header):
                if col.startswith('Translation ('):
                    locale = col[13:-1]  # Extract locale code
                    locale_cols[i] = locale
            
            for row in reader:
                if len(row) < 3:
                    continue
                
                term = row[0]
                context = row[1] if len(row) > 1 else ''
                definition = row[2] if len(row) > 2 else ''
                
                translations = {}
                for col_idx, locale in locale_cols.items():
                    if col_idx < len(row) and row[col_idx]:
                        translations[locale] = row[col_idx]
                
                if term and translations:
                    self.add_term(term, translations, context, definition)
                    count += 1
        
        return count
    
    def print_glossary(self, locale: str = None) -> None:
        """Print glossary to console"""
        print("\n" + "=" * 70)
        print("GLOSSARY / SŁOWNIK TERMINÓW")
        print("=" * 70)
        
        for term in sorted(self.terms.values(), key=lambda x: x.term.lower()):
            print(f"\n📚 {term.term}")
            if term.definition:
                print(f"   Definition: {term.definition}")
            
            if locale:
                trans = term.translations.get(locale)
                if trans:
                    print(f"   {locale}: {trans}")
            else:
                for loc, trans in sorted(term.translations.items()):
                    print(f"   {loc}: {trans}")
        
        print("\n" + "=" * 70)
        print(f"Total terms: {len(self.terms)}")


def main():
    parser = argparse.ArgumentParser(description="I18N Glossary Manager")
    parser.add_argument('--glossary', default='i18n/glossary.json', help='Glossary file path')
    parser.add_argument('--i18n-root', default='i18n', help='i18n root directory')
    parser.add_argument('--add', type=str, help='Add term (English)')
    parser.add_argument('--pl', type=str, help='Polish translation')
    parser.add_argument('--de', type=str, help='German translation')
    parser.add_argument('--es', type=str, help='Spanish translation')
    parser.add_argument('--pt', type=str, help='Portuguese translation')
    parser.add_argument('--check-usage', action='store_true', help='Check glossary usage')
    parser.add_argument('--locale', default='pl', help='Locale to check/show')
    parser.add_argument('--export-csv', type=str, help='Export to CSV')
    parser.add_argument('--import-csv', type=str, help='Import from CSV')
    parser.add_argument('--list', action='store_true', help='List all terms')
    
    args = parser.parse_args()
    
    manager = GlossaryManager(Path(args.glossary))
    
    # Add term
    if args.add:
        translations = {}
        if args.pl:
            translations['pl'] = args.pl
        if args.de:
            translations['de'] = args.de
        if args.es:
            translations['es'] = args.es
        if args.pt:
            translations['pt'] = args.pt
        
        manager.add_term(args.add, translations)
        manager.save()
        print(f"✅ Added/updated term: {args.add}")
    
    # Check usage
    if args.check_usage:
        issues = manager.check_usage(Path(args.i18n_root), args.locale)
        if issues:
            print(f"\n⚠️ Found {len(issues)} glossary issues in {args.locale}:")
            for issue in issues[:10]:
                print(f"\n   Term: {issue['term']}")
                print(f"   Expected: {issue['expected']}")
                print(f"   Issue: {issue['type']}")
                print(f"   Key: {issue['key']}")
        else:
            print(f"✅ No glossary issues found in {args.locale}")
    
    # Export CSV
    if args.export_csv:
        manager.export_csv(Path(args.export_csv))
        print(f"✅ Exported to: {args.export_csv}")
    
    # Import CSV
    if args.import_csv:
        count = manager.import_csv(Path(args.import_csv))
        manager.save()
        print(f"✅ Imported {count} terms from: {args.import_csv}")
    
    # List
    if args.list:
        manager.print_glossary(args.locale)


if __name__ == '__main__':
    main()
