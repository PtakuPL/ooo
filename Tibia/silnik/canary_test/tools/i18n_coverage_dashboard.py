#!/usr/bin/env python3
"""
I18N Coverage Dashboard - Generuje interaktywny raport HTML z pokryciem i18n
===========================================================================

Funkcje:
- Generuje interaktywny dashboard HTML
- Pokazuje postęp tłumaczeń per język
- Wizualizuje pokrycie per kategoria (NPC, quests, system, etc.)
- Lista brakujących tłumaczeń z możliwością filtrowania
- Eksport do PDF (opcjonalnie)

Usage:
    python3 tools/i18n_coverage_dashboard.py
    python3 tools/i18n_coverage_dashboard.py --output reports/coverage.html
"""

import argparse
import json
import os
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


@dataclass
class LocaleStats:
    """Statistics for a single locale"""
    code: str
    name: str
    total_keys: int
    translated: int
    missing: int
    identical_to_en: int
    by_category: Dict[str, Dict[str, int]]


class CoverageDashboard:
    """Generates coverage dashboard"""
    
    LOCALE_NAMES = {
        'en': 'English', 'pl': 'Polish', 'de': 'German', 'es': 'Spanish',
        'pt': 'Portuguese', 'fr': 'French', 'it': 'Italian', 'nl': 'Dutch',
        'ru': 'Russian', 'uk': 'Ukrainian', 'cs': 'Czech', 'sk': 'Slovak',
        'hu': 'Hungarian', 'ro': 'Romanian', 'bg': 'Bulgarian', 'hr': 'Croatian',
        'sr': 'Serbian', 'el': 'Greek', 'tr': 'Turkish', 'ar': 'Arabic',
        'zh': 'Chinese (Simplified)', 'ja': 'Japanese', 'ko': 'Korean',
        'sv': 'Swedish', 'da': 'Danish', 'no': 'Norwegian', 'fi': 'Finnish',
        'th': 'Thai', 'vi': 'Vietnamese', 'id': 'Indonesian',
    }
    
    def __init__(self, i18n_root: Path):
        self.i18n_root = i18n_root
        self.base_locale = 'en'
        self.translations: Dict[str, Dict[str, str]] = {}
        self.stats: Dict[str, LocaleStats] = {}
    
    def load_all_translations(self) -> None:
        """Load all translation files"""
        for locale_dir in self.i18n_root.iterdir():
            if not locale_dir.is_dir():
                continue
            
            locale = locale_dir.name
            self.translations[locale] = {}
            
            for json_file in locale_dir.glob("*.json"):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    
                    # Add category prefix based on filename
                    category = json_file.stem
                    for key, value in data.items():
                        full_key = f"{category}.{key}" if not key.startswith(category) else key
                        self.translations[locale][full_key] = value
                        
                except Exception as e:
                    print(f"Warning: Could not load {json_file}: {e}")
    
    def calculate_stats(self) -> None:
        """Calculate statistics for each locale"""
        if self.base_locale not in self.translations:
            return
        
        base_keys = set(self.translations[self.base_locale].keys())
        base_values = self.translations[self.base_locale]
        
        for locale, trans in self.translations.items():
            locale_keys = set(trans.keys())
            
            # Count identical to English
            identical = 0
            for key in locale_keys & base_keys:
                if trans[key] == base_values.get(key) and len(str(trans[key])) > 10:
                    identical += 1
            
            # Group by category
            by_category = defaultdict(lambda: {'total': 0, 'translated': 0, 'missing': 0})
            for key in base_keys:
                category = key.split('.')[0] if '.' in key else 'other'
                by_category[category]['total'] += 1
                if key in locale_keys:
                    by_category[category]['translated'] += 1
                else:
                    by_category[category]['missing'] += 1
            
            self.stats[locale] = LocaleStats(
                code=locale,
                name=self.LOCALE_NAMES.get(locale, locale),
                total_keys=len(base_keys),
                translated=len(locale_keys & base_keys),
                missing=len(base_keys - locale_keys),
                identical_to_en=identical if locale != self.base_locale else 0,
                by_category=dict(by_category)
            )
    
    def generate_html(self) -> str:
        """Generate HTML dashboard"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        # Prepare data for charts
        locales_data = []
        for code, stats in sorted(self.stats.items(), key=lambda x: -x[1].translated):
            if stats.total_keys > 0:
                coverage = (stats.translated / stats.total_keys) * 100
            else:
                coverage = 0
            
            locales_data.append({
                'code': code,
                'name': stats.name,
                'total': stats.total_keys,
                'translated': stats.translated,
                'missing': stats.missing,
                'identical': stats.identical_to_en,
                'coverage': round(coverage, 1)
            })
        
        # Get categories
        categories = set()
        for stats in self.stats.values():
            categories.update(stats.by_category.keys())
        categories = sorted(categories)
        
        html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>I18N Coverage Dashboard - Canary OTS</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #eee;
            min-height: 100vh;
            padding: 20px;
        }}
        .container {{ max-width: 1400px; margin: 0 auto; }}
        
        header {{
            text-align: center;
            padding: 30px 0;
            border-bottom: 1px solid #333;
            margin-bottom: 30px;
        }}
        h1 {{ font-size: 2.5em; margin-bottom: 10px; color: #00d4ff; }}
        .subtitle {{ color: #888; }}
        
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }}
        .stat-card {{
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            border: 1px solid rgba(255,255,255,0.1);
        }}
        .stat-number {{ font-size: 2.5em; font-weight: bold; color: #00d4ff; }}
        .stat-label {{ color: #888; margin-top: 5px; }}
        
        .charts-row {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }}
        @media (max-width: 900px) {{
            .charts-row {{ grid-template-columns: 1fr; }}
        }}
        
        .chart-container {{
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 20px;
            border: 1px solid rgba(255,255,255,0.1);
        }}
        .chart-title {{ margin-bottom: 20px; font-size: 1.2em; }}
        
        .locale-table {{
            width: 100%;
            border-collapse: collapse;
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            overflow: hidden;
        }}
        .locale-table th, .locale-table td {{
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }}
        .locale-table th {{ background: rgba(0,212,255,0.1); color: #00d4ff; }}
        .locale-table tr:hover {{ background: rgba(255,255,255,0.05); }}
        
        .progress-bar {{
            height: 20px;
            background: #333;
            border-radius: 10px;
            overflow: hidden;
        }}
        .progress-fill {{
            height: 100%;
            border-radius: 10px;
            transition: width 0.3s;
        }}
        .progress-fill.high {{ background: linear-gradient(90deg, #00d4ff, #00ff88); }}
        .progress-fill.medium {{ background: linear-gradient(90deg, #ffaa00, #ff6600); }}
        .progress-fill.low {{ background: linear-gradient(90deg, #ff4444, #ff0000); }}
        
        .badge {{
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.8em;
        }}
        .badge-success {{ background: rgba(0,255,136,0.2); color: #00ff88; }}
        .badge-warning {{ background: rgba(255,170,0,0.2); color: #ffaa00; }}
        .badge-danger {{ background: rgba(255,68,68,0.2); color: #ff4444; }}
        
        footer {{
            text-align: center;
            padding: 30px 0;
            color: #666;
            margin-top: 40px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🌍 I18N Coverage Dashboard</h1>
            <p class="subtitle">Canary OTS Translation Progress • Generated: {timestamp}</p>
        </header>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">{len(self.stats)}</div>
                <div class="stat-label">Languages</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{self.stats.get('en', LocaleStats('en','',0,0,0,0,{})).total_keys:,}</div>
                <div class="stat-label">Total Keys</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{len(categories)}</div>
                <div class="stat-label">Categories</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{sum(s.translated for s in self.stats.values()):,}</div>
                <div class="stat-label">Total Translations</div>
            </div>
        </div>
        
        <div class="charts-row">
            <div class="chart-container">
                <h3 class="chart-title">📊 Coverage by Language</h3>
                <canvas id="coverageChart"></canvas>
            </div>
            <div class="chart-container">
                <h3 class="chart-title">📁 Coverage by Category</h3>
                <canvas id="categoryChart"></canvas>
            </div>
        </div>
        
        <h2 style="margin-bottom: 20px;">📋 Detailed Language Stats</h2>
        <table class="locale-table">
            <thead>
                <tr>
                    <th>Language</th>
                    <th>Coverage</th>
                    <th>Translated</th>
                    <th>Missing</th>
                    <th>Identical to EN</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
'''
        
        for data in locales_data:
            coverage = data['coverage']
            progress_class = 'high' if coverage >= 90 else ('medium' if coverage >= 50 else 'low')
            badge_class = 'success' if coverage >= 90 else ('warning' if coverage >= 50 else 'danger')
            status = 'Complete' if coverage >= 99 else ('In Progress' if coverage >= 10 else 'Not Started')
            
            html += f'''
                <tr>
                    <td><strong>{data['name']}</strong> ({data['code']})</td>
                    <td>
                        <div class="progress-bar">
                            <div class="progress-fill {progress_class}" style="width: {coverage}%"></div>
                        </div>
                        <small>{coverage}%</small>
                    </td>
                    <td>{data['translated']:,}</td>
                    <td>{data['missing']:,}</td>
                    <td>{data['identical']:,}</td>
                    <td><span class="badge badge-{badge_class}">{status}</span></td>
                </tr>
'''
        
        html += '''
            </tbody>
        </table>
        
        <footer>
            <p>Generated by i18n_coverage_dashboard.py</p>
        </footer>
    </div>
    
    <script>
        // Coverage Chart
        const coverageCtx = document.getElementById('coverageChart').getContext('2d');
        new Chart(coverageCtx, {
            type: 'bar',
            data: {
                labels: ''' + json.dumps([d['name'] for d in locales_data[:10]]) + ''',
                datasets: [{
                    label: 'Coverage %',
                    data: ''' + json.dumps([d['coverage'] for d in locales_data[:10]]) + ''',
                    backgroundColor: 'rgba(0, 212, 255, 0.6)',
                    borderColor: 'rgba(0, 212, 255, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: { color: '#888' },
                        grid: { color: 'rgba(255,255,255,0.1)' }
                    },
                    x: {
                        ticks: { color: '#888' },
                        grid: { color: 'rgba(255,255,255,0.1)' }
                    }
                },
                plugins: {
                    legend: { labels: { color: '#eee' } }
                }
            }
        });
        
        // Category Chart (using English as reference)
        const categoryCtx = document.getElementById('categoryChart').getContext('2d');
        const enStats = ''' + json.dumps(self.stats.get('en', LocaleStats('en','',0,0,0,0,{})).by_category) + ''';
        new Chart(categoryCtx, {
            type: 'doughnut',
            data: {
                labels: Object.keys(enStats),
                datasets: [{
                    data: Object.values(enStats).map(c => c.total),
                    backgroundColor: [
                        '#00d4ff', '#00ff88', '#ffaa00', '#ff6600',
                        '#ff4444', '#aa44ff', '#44aaff', '#88ff44'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { color: '#eee' }
                    }
                }
            }
        });
    </script>
</body>
</html>
'''
        
        return html
    
    def save_html(self, output_path: Path) -> None:
        """Save HTML dashboard to file"""
        html = self.generate_html()
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)


def main():
    parser = argparse.ArgumentParser(description="I18N Coverage Dashboard Generator")
    parser.add_argument('--i18n-root', type=str, default='i18n',
                        help='i18n translations root directory')
    parser.add_argument('--output', type=str, default='i18n/reports/coverage_dashboard.html',
                        help='Output HTML file path')
    
    args = parser.parse_args()
    
    i18n_root = Path(args.i18n_root)
    output_path = Path(args.output)
    
    if not i18n_root.exists():
        print(f"Error: i18n root not found: {i18n_root}")
        return
    
    print("Loading translations...")
    dashboard = CoverageDashboard(i18n_root)
    dashboard.load_all_translations()
    
    print("Calculating statistics...")
    dashboard.calculate_stats()
    
    print(f"Generating dashboard...")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    dashboard.save_html(output_path)
    
    print(f"✅ Dashboard saved to: {output_path}")
    print(f"   Open in browser to view!")


if __name__ == '__main__':
    main()
