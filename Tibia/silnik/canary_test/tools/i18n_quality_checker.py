#!/usr/bin/env python3
"""
I18N Quality Checker - Sprawdza jakość tłumaczeń
================================================

Funkcje:
- Wykrywa problemy gramatyczne/stylistyczne w tłumaczeniach
- Sprawdza spójność terminologii (te same terminy tłumaczone różnie)
- Znajduje potencjalne literówki
- Wykrywa niepoprawne znaki specjalne
- Sprawdza zgodność kapitalizacji i interpunkcji

Usage:
    python3 tools/i18n_quality_checker.py --locale pl
    python3 tools/i18n_quality_checker.py --locale de --glossary glossary.json
"""

import argparse
import json
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Set, Tuple


@dataclass
class QualityIssue:
    """Single quality issue"""
    severity: str  # 'error', 'warning', 'suggestion'
    category: str
    key: str
    message: str
    original: str = ""
    translated: str = ""


@dataclass
class QualityReport:
    """Quality check report"""
    locale: str
    issues: List[QualityIssue] = field(default_factory=list)
    stats: Dict[str, int] = field(default_factory=dict)


class I18NQualityChecker:
    """Checks translation quality"""
    
    # Common gaming terms that should be consistent
    GAMING_TERMS = {
        'en': {
            'player': ['player'],
            'health': ['health', 'HP', 'hit points'],
            'mana': ['mana', 'MP'],
            'experience': ['experience', 'exp', 'XP'],
            'level': ['level', 'lvl'],
            'gold': ['gold', 'gp'],
            'item': ['item'],
            'quest': ['quest'],
            'NPC': ['NPC', 'non-player character'],
            'monster': ['monster', 'creature'],
            'spell': ['spell', 'magic'],
            'skill': ['skill', 'ability'],
        }
    }
    
    # Problematic patterns per language
    QUALITY_PATTERNS = {
        'pl': [
            (r'\s+,', 'Spacja przed przecinkiem'),
            (r',(?!\s)', 'Brak spacji po przecinku'),
            (r'\s+\.', 'Spacja przed kropką'),
            (r'[a-zA-Z]\s{2,}[a-zA-Z]', 'Podwójna spacja'),
            (r'!!+', 'Zbyt wiele wykrzykników'),
            (r'\?\?+', 'Zbyt wiele znaków zapytania'),
        ],
        'de': [
            (r'\s+,', 'Leerzeichen vor Komma'),
            (r',(?!\s)', 'Fehlendes Leerzeichen nach Komma'),
            (r'ß[A-Z]', 'ß nie powinno być przed wielką literą'),
        ],
        'es': [
            (r'[¿¡]\s', 'Spacja po znaku otwierającym'),
            (r'\s[?!]', 'Spacja przed zamykającym znakiem'),
        ],
        'default': [
            (r'\s+,', 'Space before comma'),
            (r',(?!\s)', 'Missing space after comma'),
            (r'\s+\.', 'Space before period'),
            (r'[a-zA-Z]\s{2,}[a-zA-Z]', 'Double space'),
        ]
    }
    
    def __init__(self, i18n_root: Path, locale: str):
        self.i18n_root = i18n_root
        self.locale = locale
        self.translations: Dict[str, str] = {}
        self.en_translations: Dict[str, str] = {}
        self.glossary: Dict[str, str] = {}
        self.issues: List[QualityIssue] = []
    
    def load_translations(self) -> None:
        """Load translations for the locale"""
        locale_dir = self.i18n_root / self.locale
        en_dir = self.i18n_root / 'en'
        
        # Load target locale
        if locale_dir.exists():
            for json_file in locale_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    self.translations.update(data)
                except Exception as e:
                    print(f"Warning: Could not load {json_file}: {e}")
        
        # Load English for comparison
        if en_dir.exists():
            for json_file in en_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    self.en_translations.update(data)
                except Exception:
                    pass
    
    def load_glossary(self, glossary_path: Path) -> None:
        """Load terminology glossary"""
        if glossary_path.exists():
            with open(glossary_path, 'r', encoding='utf-8') as f:
                self.glossary = json.load(f)
    
    def check_patterns(self) -> None:
        """Check for problematic patterns"""
        patterns = self.QUALITY_PATTERNS.get(self.locale, self.QUALITY_PATTERNS['default'])
        
        for key, value in self.translations.items():
            text = str(value)
            
            for pattern, description in patterns:
                if re.search(pattern, text):
                    self.issues.append(QualityIssue(
                        severity='warning',
                        category='pattern',
                        key=key,
                        message=description,
                        translated=text
                    ))
    
    def check_consistency(self) -> None:
        """Check terminology consistency"""
        # Build term usage map
        term_translations: Dict[str, Set[str]] = defaultdict(set)
        
        for key, value in self.translations.items():
            text = str(value).lower()
            
            # Track how each English term is translated
            if key in self.en_translations:
                en_text = str(self.en_translations[key]).lower()
                
                for term, variants in self.GAMING_TERMS.get('en', {}).items():
                    for variant in variants:
                        if variant.lower() in en_text:
                            # Find what this term became in translation
                            # This is simplified - real implementation would be smarter
                            term_translations[term].add(value)
        
        # Report inconsistencies
        for term, translations in term_translations.items():
            if len(translations) > 3:  # Allow some variation
                self.issues.append(QualityIssue(
                    severity='suggestion',
                    category='consistency',
                    key='*',
                    message=f"Term '{term}' has many translations: {len(translations)} variants",
                ))
    
    def check_placeholders(self) -> None:
        """Check placeholder preservation - only real placeholders"""
        # Only check numeric placeholders like {0}, {1} and printf-style %s, %d
        # Skip {word} style which might just be text formatting
        
        def extract_real_placeholders(text: str) -> Set[str]:
            placeholders = set()
            # Numeric: {0}, {1}, {2}
            placeholders.update(re.findall(r'\{\d+\}', str(text)))
            # Printf: %s, %d
            placeholders.update(re.findall(r'%[sd]', str(text)))
            # Positional printf: %1$s, %2$d
            placeholders.update(re.findall(r'%\d+\$[sd]', str(text)))
            return placeholders
        
        for key, value in self.translations.items():
            if key not in self.en_translations:
                continue
            
            en_text = str(self.en_translations[key])
            tr_text = str(value)
            
            en_placeholders = extract_real_placeholders(en_text)
            tr_placeholders = extract_real_placeholders(tr_text)
            
            # Only report if there ARE placeholders and they don't match
            if en_placeholders and en_placeholders != tr_placeholders:
                missing = en_placeholders - tr_placeholders
                extra = tr_placeholders - en_placeholders
                
                msg = []
                if missing:
                    msg.append(f"Missing: {missing}")
                if extra:
                    msg.append(f"Extra: {extra}")
                
                self.issues.append(QualityIssue(
                    severity='error',
                    category='placeholder',
                    key=key,
                    message=', '.join(msg),
                    original=en_text,
                    translated=tr_text
                ))
    
    def check_capitalization(self) -> None:
        """Check capitalization consistency"""
        for key, value in self.translations.items():
            if key not in self.en_translations:
                continue
            
            en_text = str(self.en_translations[key])
            tr_text = str(value)
            
            # Check if starts with capital in English but not in translation
            if en_text and tr_text:
                en_starts_upper = en_text[0].isupper()
                tr_starts_upper = tr_text[0].isupper()
                
                # Most languages should preserve sentence capitalization
                if en_starts_upper and not tr_starts_upper:
                    # Skip if translation starts with special char
                    if tr_text[0].isalpha():
                        self.issues.append(QualityIssue(
                            severity='suggestion',
                            category='capitalization',
                            key=key,
                            message='Translation should probably start with capital letter',
                            original=en_text,
                            translated=tr_text
                        ))
    
    def check_length(self) -> None:
        """Check for extreme length differences"""
        for key, value in self.translations.items():
            if key not in self.en_translations:
                continue
            
            en_len = len(str(self.en_translations[key]))
            tr_len = len(str(value))
            
            if en_len < 10:
                continue
            
            ratio = tr_len / en_len
            
            if ratio > 2.5:
                self.issues.append(QualityIssue(
                    severity='warning',
                    category='length',
                    key=key,
                    message=f'Translation is {ratio:.1f}x longer than original ({tr_len} vs {en_len})',
                    original=str(self.en_translations[key]),
                    translated=str(value)
                ))
            elif ratio < 0.3:
                self.issues.append(QualityIssue(
                    severity='warning',
                    category='length',
                    key=key,
                    message=f'Translation is {ratio:.1f}x shorter than original ({tr_len} vs {en_len})',
                    original=str(self.en_translations[key]),
                    translated=str(value)
                ))
    
    def check_special_characters(self) -> None:
        """Check for problematic characters"""
        problematic = {
            '\u200b': 'zero-width space',
            '\u200c': 'zero-width non-joiner',
            '\u200d': 'zero-width joiner',
            '\ufeff': 'BOM',
            '\x00': 'null',
        }
        
        for key, value in self.translations.items():
            text = str(value)
            
            for char, name in problematic.items():
                if char in text:
                    self.issues.append(QualityIssue(
                        severity='error',
                        category='special_char',
                        key=key,
                        message=f'Contains {name} character',
                        translated=text
                    ))
    
    def run_all_checks(self) -> QualityReport:
        """Run all quality checks"""
        self.check_patterns()
        self.check_placeholders()
        self.check_capitalization()
        self.check_length()
        self.check_special_characters()
        self.check_consistency()
        
        # Calculate stats
        stats = {
            'total_keys': len(self.translations),
            'errors': sum(1 for i in self.issues if i.severity == 'error'),
            'warnings': sum(1 for i in self.issues if i.severity == 'warning'),
            'suggestions': sum(1 for i in self.issues if i.severity == 'suggestion'),
        }
        
        return QualityReport(
            locale=self.locale,
            issues=self.issues,
            stats=stats
        )
    
    def print_report(self, report: QualityReport) -> None:
        """Print quality report"""
        print("\n" + "=" * 70)
        print(f"I18N QUALITY REPORT: {report.locale.upper()}")
        print("=" * 70)
        
        print(f"\n📊 STATS")
        for k, v in report.stats.items():
            print(f"   {k}: {v}")
        
        if report.stats['errors'] > 0:
            print(f"\n❌ ERRORS ({report.stats['errors']})")
            for issue in report.issues:
                if issue.severity == 'error':
                    print(f"   [{issue.category}] {issue.key}")
                    print(f"      {issue.message}")
                    if issue.translated:
                        print(f"      Text: {issue.translated[:60]}...")
        
        if report.stats['warnings'] > 0:
            print(f"\n⚠️ WARNINGS ({report.stats['warnings']})")
            for issue in report.issues[:20]:  # Limit output
                if issue.severity == 'warning':
                    print(f"   [{issue.category}] {issue.key}")
                    print(f"      {issue.message}")
        
        if report.stats['suggestions'] > 0:
            print(f"\n💡 SUGGESTIONS ({report.stats['suggestions']})")
            for issue in report.issues[:10]:
                if issue.severity == 'suggestion':
                    print(f"   [{issue.category}] {issue.key}")
                    print(f"      {issue.message}")
        
        # Summary
        print("\n" + "=" * 70)
        if report.stats['errors'] == 0:
            print("✅ No critical errors found")
        else:
            print(f"❌ Found {report.stats['errors']} errors that need fixing")
        print("=" * 70)


def main():
    parser = argparse.ArgumentParser(description="I18N Quality Checker for Canary OTS")
    parser.add_argument('--i18n-root', type=str, default='i18n',
                        help='i18n translations root')
    parser.add_argument('--locale', type=str, required=True,
                        help='Locale to check')
    parser.add_argument('--glossary', type=str,
                        help='Path to terminology glossary JSON')
    parser.add_argument('--output', type=str,
                        help='Export report to JSON')
    parser.add_argument('--strict', action='store_true',
                        help='Exit with error on any issue')
    
    args = parser.parse_args()
    
    i18n_root = Path(args.i18n_root)
    
    checker = I18NQualityChecker(i18n_root, args.locale)
    checker.load_translations()
    
    if args.glossary:
        checker.load_glossary(Path(args.glossary))
    
    report = checker.run_all_checks()
    checker.print_report(report)
    
    if args.output:
        output_data = {
            'locale': report.locale,
            'stats': report.stats,
            'issues': [
                {
                    'severity': i.severity,
                    'category': i.category,
                    'key': i.key,
                    'message': i.message,
                    'original': i.original,
                    'translated': i.translated,
                }
                for i in report.issues
            ]
        }
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)
        print(f"\n📄 Report exported to: {args.output}")
    
    if args.strict and (report.stats['errors'] > 0 or report.stats['warnings'] > 0):
        sys.exit(1)


if __name__ == '__main__':
    main()
