#!/usr/bin/env python3
"""
I18N Progress Tracker - Śledzenie postępu prac i18n
====================================================

Funkcje:
- Śledzenie postępu tłumaczeń
- Historia zmian
- Statystyki per język
- Prognozowanie czasu zakończenia
- Integracja z CI/CD

Usage:
    python3 tools/i18n_progress_tracker.py --update
    python3 tools/i18n_progress_tracker.py --status
    python3 tools/i18n_progress_tracker.py --history
    python3 tools/i18n_progress_tracker.py --forecast
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class LanguageStats:
    """Statistics for a single language"""
    lang: str
    total_keys: int = 0
    translated_keys: int = 0
    untranslated_keys: int = 0
    verified_keys: int = 0
    files_count: int = 0
    last_updated: str = ""
    
    @property
    def progress(self) -> float:
        if self.total_keys == 0:
            return 0.0
        return (self.translated_keys / self.total_keys) * 100


@dataclass
class Snapshot:
    """Point-in-time snapshot of i18n state"""
    timestamp: str
    languages: Dict[str, Dict] = field(default_factory=dict)
    total_keys: int = 0
    total_translations: int = 0
    npc_migrated: int = 0
    npc_total: int = 0


class ProgressTracker:
    """Tracks i18n progress over time"""
    
    HISTORY_FILE = "i18n/progress_history.json"
    
    def __init__(self, i18n_dir: Path):
        self.i18n_dir = i18n_dir
        self.history: List[Snapshot] = []
        self.load_history()
    
    def load_history(self) -> None:
        """Load progress history"""
        history_path = self.i18n_dir / "progress_history.json"
        
        if history_path.exists():
            try:
                with open(history_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                for snap_data in data.get('snapshots', []):
                    snap = Snapshot(
                        timestamp=snap_data['timestamp'],
                        total_keys=snap_data.get('total_keys', 0),
                        total_translations=snap_data.get('total_translations', 0),
                        npc_migrated=snap_data.get('npc_migrated', 0),
                        npc_total=snap_data.get('npc_total', 0),
                        languages=snap_data.get('languages', {})
                    )
                    self.history.append(snap)
            except Exception as e:
                print(f"Error loading history: {e}")
    
    def save_history(self) -> None:
        """Save progress history"""
        history_path = self.i18n_dir / "progress_history.json"
        
        data = {
            'last_updated': datetime.now().isoformat(),
            'snapshots': [
                {
                    'timestamp': s.timestamp,
                    'total_keys': s.total_keys,
                    'total_translations': s.total_translations,
                    'npc_migrated': s.npc_migrated,
                    'npc_total': s.npc_total,
                    'languages': s.languages
                }
                for s in self.history
            ]
        }
        
        # Create directory if needed
        history_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(history_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    
    def collect_current_stats(self) -> Snapshot:
        """Collect current i18n statistics"""
        snapshot = Snapshot(
            timestamp=datetime.now().isoformat()
        )
        
        # Scan each language directory
        for lang_dir in self.i18n_dir.iterdir():
            if not lang_dir.is_dir():
                continue
            if lang_dir.name.startswith('.'):
                continue
            if lang_dir.name in ['reports', 'templates', 'backups']:
                continue
            
            lang = lang_dir.name
            stats = self._scan_language(lang_dir)
            
            snapshot.languages[lang] = {
                'total_keys': stats.total_keys,
                'translated_keys': stats.translated_keys,
                'untranslated_keys': stats.untranslated_keys,
                'files_count': stats.files_count,
                'progress': round(stats.progress, 2)
            }
            
            snapshot.total_keys = max(snapshot.total_keys, stats.total_keys)
            snapshot.total_translations += stats.translated_keys
        
        # Count NPC migration status
        npc_dirs = [
            Path("data-otservbr-global/npc"),
            Path("data-canary/npc")
        ]
        
        migrated = 0
        total = 0
        
        for npc_dir in npc_dirs:
            if npc_dir.exists():
                for npc_file in npc_dir.glob("*.lua"):
                    total += 1
                    try:
                        content = npc_file.read_text(encoding='utf-8', errors='ignore')
                        if 'sayLocalized' in content or 'i18n' in content:
                            migrated += 1
                    except:
                        pass
        
        snapshot.npc_migrated = migrated
        snapshot.npc_total = total
        
        return snapshot
    
    def _scan_language(self, lang_dir: Path) -> LanguageStats:
        """Scan a language directory for statistics"""
        stats = LanguageStats(lang=lang_dir.name)
        
        for json_file in lang_dir.glob("*.json"):
            stats.files_count += 1
            
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                for key, value in data.items():
                    stats.total_keys += 1
                    
                    if value and isinstance(value, str):
                        # Check if translated (not just empty or placeholder)
                        if value.strip() and not value.startswith('TODO:'):
                            stats.translated_keys += 1
                        else:
                            stats.untranslated_keys += 1
                    else:
                        stats.untranslated_keys += 1
                        
            except Exception as e:
                print(f"Error reading {json_file}: {e}")
        
        return stats
    
    def take_snapshot(self) -> Snapshot:
        """Take and save a new snapshot"""
        snapshot = self.collect_current_stats()
        self.history.append(snapshot)
        self.save_history()
        return snapshot
    
    def get_progress_delta(self, days: int = 7) -> Dict:
        """Calculate progress change over time period"""
        if len(self.history) < 2:
            return {'error': 'Not enough history data'}
        
        cutoff = datetime.now() - timedelta(days=days)
        
        # Find oldest snapshot within period
        old_snap = None
        for snap in self.history:
            snap_time = datetime.fromisoformat(snap.timestamp)
            if snap_time >= cutoff:
                old_snap = snap
                break
        
        if not old_snap:
            old_snap = self.history[0]
        
        current = self.history[-1]
        
        return {
            'period_days': days,
            'keys_added': current.total_keys - old_snap.total_keys,
            'translations_added': current.total_translations - old_snap.total_translations,
            'npc_migrated_delta': current.npc_migrated - old_snap.npc_migrated,
            'languages_progress': {
                lang: {
                    'old': old_snap.languages.get(lang, {}).get('progress', 0),
                    'new': current.languages.get(lang, {}).get('progress', 0),
                    'delta': current.languages.get(lang, {}).get('progress', 0) - 
                             old_snap.languages.get(lang, {}).get('progress', 0)
                }
                for lang in current.languages
            }
        }
    
    def forecast_completion(self) -> Dict:
        """Forecast when i18n work will be complete"""
        if len(self.history) < 3:
            return {'error': 'Not enough history data (need at least 3 snapshots)'}
        
        # Calculate average daily progress
        recent = self.history[-7:] if len(self.history) >= 7 else self.history
        
        if len(recent) < 2:
            return {'error': 'Not enough recent data'}
        
        first = recent[0]
        last = recent[-1]
        
        first_time = datetime.fromisoformat(first.timestamp)
        last_time = datetime.fromisoformat(last.timestamp)
        
        days_elapsed = max(1, (last_time - first_time).days)
        
        translations_added = last.total_translations - first.total_translations
        npc_migrated = last.npc_migrated - first.npc_migrated
        
        daily_translations = translations_added / days_elapsed if days_elapsed > 0 else 0
        daily_npc = npc_migrated / days_elapsed if days_elapsed > 0 else 0
        
        # Estimate remaining work
        # Assuming 53 languages with ~40k keys each = ~2.1M total translations needed
        # Current: calculate from last snapshot
        
        target_languages = 53
        current_languages = len(last.languages)
        keys_per_lang = last.total_keys
        
        total_needed = target_languages * keys_per_lang
        current_done = last.total_translations
        remaining_translations = total_needed - current_done
        
        npc_remaining = last.npc_total - last.npc_migrated
        
        days_for_translations = remaining_translations / daily_translations if daily_translations > 0 else float('inf')
        days_for_npc = npc_remaining / daily_npc if daily_npc > 0 else float('inf')
        
        return {
            'current_progress': {
                'languages': current_languages,
                'target_languages': target_languages,
                'translations_done': current_done,
                'translations_needed': total_needed,
                'npc_migrated': last.npc_migrated,
                'npc_total': last.npc_total,
            },
            'daily_rate': {
                'translations': round(daily_translations, 0),
                'npc_migrations': round(daily_npc, 2),
            },
            'forecast': {
                'days_for_translations': round(days_for_translations, 0) if days_for_translations != float('inf') else 'Unknown',
                'days_for_npc': round(days_for_npc, 0) if days_for_npc != float('inf') else 'Unknown',
                'estimated_completion': (
                    (datetime.now() + timedelta(days=max(days_for_translations, days_for_npc))).strftime('%Y-%m-%d')
                    if days_for_translations != float('inf') and days_for_npc != float('inf')
                    else 'Unknown'
                )
            }
        }
    
    def generate_status_report(self) -> str:
        """Generate status report"""
        current = self.collect_current_stats()
        
        report = f"""# I18N Progress Status

**Generated:** {datetime.now().isoformat()}

## Overview

| Metric | Value |
|--------|-------|
| Languages | {len(current.languages)} |
| Total Keys | {current.total_keys:,} |
| Total Translations | {current.total_translations:,} |
| NPC Migrated | {current.npc_migrated}/{current.npc_total} ({current.npc_migrated/current.npc_total*100:.1f}%) |

## Language Progress

| Language | Keys | Translated | Progress |
|----------|------|------------|----------|
"""
        
        for lang, data in sorted(current.languages.items()):
            report += f"| {lang} | {data['total_keys']:,} | {data['translated_keys']:,} | {data['progress']:.1f}% |\n"
        
        # Add history if available
        if len(self.history) >= 2:
            delta = self.get_progress_delta(7)
            
            report += f"""
## Progress (Last 7 Days)

- Keys added: {delta.get('keys_added', 0):,}
- Translations added: {delta.get('translations_added', 0):,}
- NPCs migrated: {delta.get('npc_migrated_delta', 0)}

"""
        
        # Add forecast
        forecast = self.forecast_completion()
        if 'error' not in forecast:
            report += f"""
## Forecast

- Daily translation rate: ~{forecast['daily_rate']['translations']:,.0f}
- Estimated completion: {forecast['forecast']['estimated_completion']}
"""
        
        return report


def main():
    parser = argparse.ArgumentParser(description="I18N Progress Tracker")
    parser.add_argument('--i18n-dir', default='i18n', help='I18N directory')
    parser.add_argument('--update', action='store_true', help='Take new snapshot')
    parser.add_argument('--status', action='store_true', help='Show current status')
    parser.add_argument('--history', action='store_true', help='Show history')
    parser.add_argument('--forecast', action='store_true', help='Show forecast')
    parser.add_argument('--report', type=str, help='Save report to file')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    
    args = parser.parse_args()
    
    tracker = ProgressTracker(Path(args.i18n_dir))
    
    # Update (take snapshot)
    if args.update:
        print("📸 Taking snapshot...")
        snapshot = tracker.take_snapshot()
        print(f"✅ Snapshot saved: {snapshot.timestamp}")
        print(f"   Languages: {len(snapshot.languages)}")
        print(f"   Total keys: {snapshot.total_keys:,}")
        print(f"   Translations: {snapshot.total_translations:,}")
        print(f"   NPCs: {snapshot.npc_migrated}/{snapshot.npc_total}")
    
    # Status
    if args.status:
        snapshot = tracker.collect_current_stats()
        
        if args.json:
            print(json.dumps({
                'timestamp': snapshot.timestamp,
                'languages': snapshot.languages,
                'total_keys': snapshot.total_keys,
                'total_translations': snapshot.total_translations,
                'npc_migrated': snapshot.npc_migrated,
                'npc_total': snapshot.npc_total,
            }, indent=2))
        else:
            print("\n📊 CURRENT STATUS")
            print(f"   Languages: {len(snapshot.languages)}")
            print(f"   Total keys: {snapshot.total_keys:,}")
            print(f"   Translations: {snapshot.total_translations:,}")
            print(f"   NPC Migration: {snapshot.npc_migrated}/{snapshot.npc_total}")
            
            print("\n📈 BY LANGUAGE:")
            for lang, data in sorted(snapshot.languages.items()):
                bar = '█' * int(data['progress'] / 5) + '░' * (20 - int(data['progress'] / 5))
                print(f"   {lang:5s} [{bar}] {data['progress']:.1f}%")
    
    # History
    if args.history:
        print(f"\n📜 HISTORY ({len(tracker.history)} snapshots)")
        
        for snap in tracker.history[-10:]:
            print(f"\n   {snap.timestamp}")
            print(f"     Keys: {snap.total_keys:,} | Trans: {snap.total_translations:,} | NPC: {snap.npc_migrated}/{snap.npc_total}")
        
        if len(tracker.history) >= 2:
            delta = tracker.get_progress_delta(7)
            print(f"\n📊 LAST 7 DAYS:")
            print(f"   Keys added: {delta.get('keys_added', 0):,}")
            print(f"   Translations added: {delta.get('translations_added', 0):,}")
    
    # Forecast
    if args.forecast:
        forecast = tracker.forecast_completion()
        
        if 'error' in forecast:
            print(f"\n⚠️ {forecast['error']}")
        else:
            print("\n🔮 FORECAST")
            print(f"   Current progress:")
            print(f"     Languages: {forecast['current_progress']['languages']}/{forecast['current_progress']['target_languages']}")
            print(f"     Translations: {forecast['current_progress']['translations_done']:,}/{forecast['current_progress']['translations_needed']:,}")
            print(f"     NPC: {forecast['current_progress']['npc_migrated']}/{forecast['current_progress']['npc_total']}")
            
            print(f"\n   Daily rate:")
            print(f"     Translations: ~{forecast['daily_rate']['translations']:,.0f}/day")
            print(f"     NPC migrations: ~{forecast['daily_rate']['npc_migrations']:.1f}/day")
            
            print(f"\n   Estimated completion: {forecast['forecast']['estimated_completion']}")
    
    # Generate report
    if args.report:
        report = tracker.generate_status_report()
        with open(args.report, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"\n📄 Report saved to: {args.report}")


if __name__ == '__main__':
    main()
