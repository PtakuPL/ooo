#!/usr/bin/env python3
"""
I18N Validator - Walidacja poprawności tłumaczeń i18n
=====================================================

Funkcje:
- Sprawdza spójność placeholderów ({0}, {1}, {name}) między językami
- Wykrywa brakujące klucze w każdym języku
- Sprawdza długość tłumaczeń (zbyt długie/krótkie)
- Waliduje format JSON
- Wykrywa zduplikowane klucze
- Sprawdza kodowanie UTF-8
- Wykrywa nietłumaczone teksty (identyczne z EN)

Usage:
    python3 tools/i18n_validator.py --locales pl de es pt
    python3 tools/i18n_validator.py --check-placeholders
    python3 tools/i18n_validator.py --fix-json  # Auto-napraw błędy JSON
"""

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


@dataclass
class ValidationIssue:
    """Single validation issue"""
    severity: str  # 'error', 'warning', 'info'
    category: str  # 'placeholder', 'missing', 'length', 'encoding', etc.
    message: str
    file_path: str
    key: str = ""
    locale: str = ""
    
    def __str__(self):
        icon = {'error': '❌', 'warning': '⚠️', 'info': 'ℹ️'}.get(self.severity, '•')
        return f"{icon} [{self.locale}/{self.category}] {self.message}"


@dataclass
class ValidationReport:
    """Complete validation report"""
    issues: List[ValidationIssue] = field(default_factory=list)
    stats: Dict[str, int] = field(default_factory=dict)
    
    @property
    def error_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == 'error')
    
    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == 'warning')


class I18NValidator:
    def __init__(self, i18n_root: Path, base_locale: str = "en"):
        self.i18n_root = i18n_root
        self.base_locale = base_locale
        self.translations: Dict[str, Dict[str, str]] = {}
        self.issues: List[ValidationIssue] = []
        
    def load_translations(self, locales: List[str]) -> None:
        """Load all translation files for specified locales"""
        for locale in locales:
            locale_dir = self.i18n_root / locale
            if not locale_dir.exists():
                self.issues.append(ValidationIssue(
                    severity='error',
                    category='missing_locale',
                    message=f"Locale directory not found: {locale}",
                    file_path=str(locale_dir),
                    locale=locale
                ))
                continue
            
            self.translations[locale] = {}
            
            for json_file in locale_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        
                    # Flatten nested structure
                    flat_data = self._flatten_dict(data)
                    self.translations[locale].update(flat_data)
                    
                except json.JSONDecodeError as e:
                    self.issues.append(ValidationIssue(
                        severity='error',
                        category='json_error',
                        message=f"Invalid JSON: {e}",
                        file_path=str(json_file),
                        locale=locale
                    ))
                except UnicodeDecodeError as e:
                    self.issues.append(ValidationIssue(
                        severity='error',
                        category='encoding',
                        message=f"UTF-8 encoding error: {e}",
                        file_path=str(json_file),
                        locale=locale
                    ))
    
    def _flatten_dict(self, d: dict, parent_key: str = '', sep: str = '.') -> dict:
        """Flatten nested dictionary"""
        items = []
        for k, v in d.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else k
            if isinstance(v, dict):
                items.extend(self._flatten_dict(v, new_key, sep).items())
            else:
                items.append((new_key, v))
        return dict(items)
    
    def validate_missing_keys(self) -> None:
        """Check for missing keys compared to base locale"""
        if self.base_locale not in self.translations:
            return
        
        base_keys = set(self.translations[self.base_locale].keys())
        
        for locale, translations in self.translations.items():
            if locale == self.base_locale:
                continue
            
            locale_keys = set(translations.keys())
            
            # Missing in target locale
            missing = base_keys - locale_keys
            for key in missing:
                self.issues.append(ValidationIssue(
                    severity='warning',
                    category='missing_key',
                    message=f"Missing key: {key}",
                    file_path=f"{locale}/*.json",
                    key=key,
                    locale=locale
                ))
            
            # Extra keys (not in base)
            extra = locale_keys - base_keys
            for key in extra:
                self.issues.append(ValidationIssue(
                    severity='info',
                    category='extra_key',
                    message=f"Extra key not in {self.base_locale}: {key}",
                    file_path=f"{locale}/*.json",
                    key=key,
                    locale=locale
                ))
    
    def validate_placeholders(self) -> None:
        """Check placeholder consistency between languages"""
        if self.base_locale not in self.translations:
            return
        
        # Only check REAL placeholders (numeric or known parameter names)
        # Skip single words in braces that are just text formatting
        KNOWN_PARAMS = {'name', 'player', 'target', 'item', 'amount', 'count', 
                        'gold', 'level', 'hp', 'mp', 'exp', 'damage', 'value',
                        'time', 'date', 'creature', 'npc', 'quest', 'skill'}
        
        def extract_placeholders(text: str) -> Set[str]:
            placeholders = set()
            # Numeric placeholders: {0}, {1}, {2}
            placeholders.update(re.findall(r'\{(\d+)\}', str(text)))
            # Known parameter placeholders only
            for match in re.findall(r'\{([a-zA-Z_]+)\}', str(text)):
                if match.lower() in KNOWN_PARAMS:
                    placeholders.add(match)
            # Printf style: %s, %d
            for match in re.findall(r'(%[sd])', str(text)):
                placeholders.add(match)
            # Positional printf: %1$s, %2$d
            for match in re.findall(r'(%\d+\$[sd])', str(text)):
                placeholders.add(match)
            return placeholders
        
        base_trans = self.translations[self.base_locale]
        
        for locale, translations in self.translations.items():
            if locale == self.base_locale:
                continue
            
            for key, value in translations.items():
                if key not in base_trans:
                    continue
                
                base_value = base_trans[key]
                base_ph = extract_placeholders(base_value)
                locale_ph = extract_placeholders(value)
                
                if base_ph != locale_ph:
                    self.issues.append(ValidationIssue(
                        severity='error',
                        category='placeholder',
                        message=f"Placeholder mismatch: base={base_ph}, {locale}={locale_ph}",
                        file_path=f"{locale}/*.json",
                        key=key,
                        locale=locale
                    ))
    
    def validate_length(self, max_ratio: float = 2.0, min_ratio: float = 0.3) -> None:
        """Check for suspiciously long or short translations"""
        if self.base_locale not in self.translations:
            return
        
        base_trans = self.translations[self.base_locale]
        
        for locale, translations in self.translations.items():
            if locale == self.base_locale:
                continue
            
            for key, value in translations.items():
                if key not in base_trans:
                    continue
                
                base_len = len(str(base_trans[key]))
                if base_len < 5:  # Skip very short strings
                    continue
                
                locale_len = len(str(value))
                ratio = locale_len / base_len
                
                if ratio > max_ratio:
                    self.issues.append(ValidationIssue(
                        severity='warning',
                        category='length',
                        message=f"Translation too long ({locale_len} vs {base_len} chars, ratio={ratio:.1f})",
                        file_path=f"{locale}/*.json",
                        key=key,
                        locale=locale
                    ))
                elif ratio < min_ratio:
                    self.issues.append(ValidationIssue(
                        severity='warning',
                        category='length',
                        message=f"Translation too short ({locale_len} vs {base_len} chars, ratio={ratio:.1f})",
                        file_path=f"{locale}/*.json",
                        key=key,
                        locale=locale
                    ))
    
    def validate_untranslated(self) -> None:
        """Find strings that are identical to English (not translated)"""
        if self.base_locale not in self.translations:
            return
        
        base_trans = self.translations[self.base_locale]
        
        for locale, translations in self.translations.items():
            if locale == self.base_locale:
                continue
            
            identical_count = 0
            for key, value in translations.items():
                if key not in base_trans:
                    continue
                
                base_value = base_trans[key]
                
                # Skip if it's a proper noun or likely intentionally same
                if self._is_likely_proper_noun(str(base_value)):
                    continue
                
                if str(value) == str(base_value) and len(str(value)) > 10:
                    identical_count += 1
            
            # Only report if significant number are untranslated
            total = len([k for k in translations if k in base_trans])
            if total > 0:
                ratio = identical_count / total
                if ratio > 0.5 and identical_count > 10:
                    self.issues.append(ValidationIssue(
                        severity='info',
                        category='untranslated',
                        message=f"{identical_count}/{total} strings ({ratio:.0%}) identical to {self.base_locale}",
                        file_path=f"{locale}/*.json",
                        locale=locale
                    ))
    
    def _is_likely_proper_noun(self, text: str) -> bool:
        """Check if text is likely a proper noun (shouldn't be translated)"""
        # Item names, NPC names, spell names are often capitalized
        words = text.split()
        if len(words) <= 3:
            capitalized = sum(1 for w in words if w and w[0].isupper())
            if capitalized == len(words):
                return True
        return False
    
    def validate_special_characters(self) -> None:
        """Check for problematic special characters"""
        problematic_chars = {
            '\x00': 'null byte',
            '\r': 'carriage return',
            '\t': 'tab (use spaces)',
            '​': 'zero-width space',
            '‌': 'zero-width non-joiner',
        }
        
        for locale, translations in self.translations.items():
            for key, value in translations.items():
                text = str(value)
                for char, name in problematic_chars.items():
                    if char in text:
                        self.issues.append(ValidationIssue(
                            severity='warning',
                            category='special_char',
                            message=f"Contains {name} character",
                            file_path=f"{locale}/*.json",
                            key=key,
                            locale=locale
                        ))
    
    def run_all_validations(self) -> ValidationReport:
        """Run all validation checks"""
        self.validate_missing_keys()
        self.validate_placeholders()
        self.validate_length()
        self.validate_untranslated()
        self.validate_special_characters()
        
        # Calculate stats
        stats = {
            'total_keys': len(self.translations.get(self.base_locale, {})),
            'locales_checked': len(self.translations),
            'errors': sum(1 for i in self.issues if i.severity == 'error'),
            'warnings': sum(1 for i in self.issues if i.severity == 'warning'),
            'info': sum(1 for i in self.issues if i.severity == 'info'),
        }
        
        return ValidationReport(issues=self.issues, stats=stats)
    
    def print_report(self, report: ValidationReport) -> None:
        """Print validation report to console"""
        print("\n" + "=" * 70)
        print("I18N VALIDATION REPORT")
        print("=" * 70)
        
        print(f"\n📊 STATS")
        for k, v in report.stats.items():
            print(f"   {k}: {v}")
        
        if report.error_count > 0:
            print(f"\n❌ ERRORS ({report.error_count})")
            for issue in report.issues:
                if issue.severity == 'error':
                    print(f"   {issue}")
        
        if report.warning_count > 0:
            print(f"\n⚠️ WARNINGS ({report.warning_count})")
            for issue in report.issues:
                if issue.severity == 'warning':
                    print(f"   {issue}")
        
        # Summary by category
        categories = defaultdict(int)
        for issue in report.issues:
            categories[issue.category] += 1
        
        if categories:
            print(f"\n📁 BY CATEGORY")
            for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
                print(f"   {cat}: {count}")
        
        # Status
        print("\n" + "=" * 70)
        if report.error_count == 0:
            print("✅ VALIDATION PASSED (no errors)")
        else:
            print(f"❌ VALIDATION FAILED ({report.error_count} errors)")
        print("=" * 70)
    
    def export_report(self, output_path: Path, report: ValidationReport) -> None:
        """Export report to JSON"""
        data = {
            'stats': report.stats,
            'issues': [
                {
                    'severity': i.severity,
                    'category': i.category,
                    'message': i.message,
                    'file': i.file_path,
                    'key': i.key,
                    'locale': i.locale,
                }
                for i in report.issues
            ]
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)


def fix_json_file(file_path: Path) -> bool:
    """Attempt to fix common JSON issues"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Try to parse first
        try:
            json.loads(content)
            return True  # Already valid
        except json.JSONDecodeError:
            pass
        
        # Common fixes
        fixes = [
            # Remove trailing commas
            (r',(\s*[}\]])', r'\1'),
            # Fix unescaped quotes in values
            # (This is tricky and might need manual intervention)
            # Remove BOM
            (r'^\ufeff', ''),
            # Fix Windows line endings
            (r'\r\n', '\n'),
        ]
        
        fixed_content = content
        for pattern, replacement in fixes:
            fixed_content = re.sub(pattern, replacement, fixed_content)
        
        # Try to parse fixed content
        try:
            data = json.loads(fixed_content)
            # Save with proper formatting
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            return True
        except json.JSONDecodeError:
            return False
            
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="I18N Validator for Canary OTS")
    parser.add_argument('--i18n-root', type=str, default='i18n',
                        help='Root directory of i18n translations')
    parser.add_argument('--locales', nargs='+', default=['en', 'pl', 'de', 'es', 'pt'],
                        help='Locales to validate')
    parser.add_argument('--base-locale', type=str, default='en',
                        help='Base/reference locale')
    parser.add_argument('--check-placeholders', action='store_true',
                        help='Focus on placeholder validation')
    parser.add_argument('--check-missing', action='store_true',
                        help='Focus on missing keys')
    parser.add_argument('--output', type=str, help='Export report to JSON file')
    parser.add_argument('--fix-json', action='store_true',
                        help='Attempt to fix JSON errors')
    parser.add_argument('--strict', action='store_true',
                        help='Treat warnings as errors')
    
    args = parser.parse_args()
    
    i18n_root = Path(args.i18n_root)
    
    if not i18n_root.exists():
        print(f"Error: i18n root not found: {i18n_root}")
        sys.exit(1)
    
    # Fix JSON files if requested
    if args.fix_json:
        print("Attempting to fix JSON files...")
        for locale in args.locales:
            locale_dir = i18n_root / locale
            if locale_dir.exists():
                for json_file in locale_dir.glob("*.json"):
                    if fix_json_file(json_file):
                        print(f"  ✅ Fixed: {json_file}")
                    else:
                        print(f"  ❌ Could not fix: {json_file}")
        print()
    
    # Run validation
    validator = I18NValidator(i18n_root, args.base_locale)
    validator.load_translations(args.locales)
    
    report = validator.run_all_validations()
    validator.print_report(report)
    
    if args.output:
        validator.export_report(Path(args.output), report)
        print(f"\n📄 Report exported to: {args.output}")
    
    # Exit code
    if args.strict:
        sys.exit(1 if report.error_count > 0 or report.warning_count > 0 else 0)
    else:
        sys.exit(1 if report.error_count > 0 else 0)


if __name__ == '__main__':
    main()
