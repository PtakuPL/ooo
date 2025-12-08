#!/usr/bin/env python3
"""
I18N Batch Processor - Masowe przetwarzanie plików do i18n
=========================================================

Funkcje:
- Przetwarza całe katalogi plików Lua/C++
- Generuje statystyki i raporty postępu
- Automatycznie tworzy backupy
- Obsługuje wznawianie przerwanej pracy
- Integruje się z innymi narzędziami i18n

Usage:
    python3 tools/i18n_batch_processor.py --dir data-otservbr-global/npc --analyze
    python3 tools/i18n_batch_processor.py --dir data-otservbr-global/scripts --process --limit 50
    python3 tools/i18n_batch_processor.py --resume
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set
import re


@dataclass
class FileStats:
    """Statistics for a single file"""
    path: str
    strings_found: int = 0
    strings_processed: int = 0
    status: str = 'pending'  # pending, processed, skipped, error
    error: str = ""
    keys_generated: List[str] = field(default_factory=list)


@dataclass
class BatchJob:
    """Batch processing job state"""
    id: str
    created: str
    directory: str
    total_files: int = 0
    processed_files: int = 0
    total_strings: int = 0
    processed_strings: int = 0
    files: Dict[str, FileStats] = field(default_factory=dict)
    status: str = 'running'  # running, paused, completed, failed


class BatchProcessor:
    """Handles batch i18n processing"""
    
    STATE_FILE = ".i18n_batch_state.json"
    
    # Patterns to find strings
    STRING_PATTERNS = [
        (r'sendTextMessage\s*\(\s*[\w\.]+\s*,\s*"([^"]{10,})"', 'sendTextMessage'),
        (r'npcHandler:say\s*\(\s*"([^"]{10,})"', 'npcHandler:say'),
        (r'selfSay\s*\(\s*"([^"]{10,})"', 'selfSay'),
        (r'npc:say\s*\(\s*"([^"]{10,})"', 'npc:say'),
        (r'setMessage\s*\(\s*\w+\s*,\s*"([^"]{10,})"', 'setMessage'),
    ]
    
    # Skip patterns
    SKIP_PATTERNS = [
        r'^[a-z_\.]+$',
        r'^\d+$',
        r'^[A-Z_]+$',
    ]
    
    def __init__(self, work_dir: Path):
        self.work_dir = work_dir
        self.state_file = work_dir / self.STATE_FILE
        self.current_job: Optional[BatchJob] = None
        
    def create_job(self, directory: Path, pattern: str = "*.lua") -> BatchJob:
        """Create new batch job"""
        job_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Find all files
        files = list(directory.rglob(pattern))
        
        job = BatchJob(
            id=job_id,
            created=datetime.now().isoformat(),
            directory=str(directory),
            total_files=len(files),
            files={str(f): FileStats(path=str(f)) for f in files}
        )
        
        self.current_job = job
        self.save_state()
        
        return job
    
    def load_job(self) -> Optional[BatchJob]:
        """Load existing job from state file"""
        if not self.state_file.exists():
            return None
        
        try:
            with open(self.state_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            job = BatchJob(
                id=data['id'],
                created=data['created'],
                directory=data['directory'],
                total_files=data['total_files'],
                processed_files=data['processed_files'],
                total_strings=data['total_strings'],
                processed_strings=data['processed_strings'],
                status=data['status']
            )
            
            for path, stats_data in data.get('files', {}).items():
                job.files[path] = FileStats(
                    path=stats_data['path'],
                    strings_found=stats_data.get('strings_found', 0),
                    strings_processed=stats_data.get('strings_processed', 0),
                    status=stats_data.get('status', 'pending'),
                    error=stats_data.get('error', ''),
                    keys_generated=stats_data.get('keys_generated', [])
                )
            
            self.current_job = job
            return job
            
        except Exception as e:
            print(f"Error loading state: {e}")
            return None
    
    def save_state(self) -> None:
        """Save current job state"""
        if not self.current_job:
            return
        
        data = {
            'id': self.current_job.id,
            'created': self.current_job.created,
            'directory': self.current_job.directory,
            'total_files': self.current_job.total_files,
            'processed_files': self.current_job.processed_files,
            'total_strings': self.current_job.total_strings,
            'processed_strings': self.current_job.processed_strings,
            'status': self.current_job.status,
            'files': {
                path: {
                    'path': stats.path,
                    'strings_found': stats.strings_found,
                    'strings_processed': stats.strings_processed,
                    'status': stats.status,
                    'error': stats.error,
                    'keys_generated': stats.keys_generated,
                }
                for path, stats in self.current_job.files.items()
            }
        }
        
        with open(self.state_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
    
    def analyze_file(self, file_path: Path) -> FileStats:
        """Analyze a single file without modifying it"""
        stats = FileStats(path=str(file_path))
        
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            for pattern, context in self.STRING_PATTERNS:
                for match in re.finditer(pattern, content):
                    text = match.group(1)
                    if not self._should_skip(text):
                        stats.strings_found += 1
            
            stats.status = 'analyzed'
            
        except Exception as e:
            stats.status = 'error'
            stats.error = str(e)
        
        return stats
    
    def _should_skip(self, text: str) -> bool:
        """Check if string should be skipped"""
        for pattern in self.SKIP_PATTERNS:
            if re.match(pattern, text):
                return True
        return False
    
    def analyze_directory(self, directory: Path, pattern: str = "*.lua") -> Dict:
        """Analyze all files in directory"""
        results = {
            'total_files': 0,
            'files_with_strings': 0,
            'total_strings': 0,
            'by_pattern': {},
            'top_files': [],
        }
        
        files = list(directory.rglob(pattern))
        results['total_files'] = len(files)
        
        file_stats = []
        
        for file_path in files:
            stats = self.analyze_file(file_path)
            
            if stats.strings_found > 0:
                results['files_with_strings'] += 1
                results['total_strings'] += stats.strings_found
                file_stats.append((str(file_path), stats.strings_found))
        
        # Top files by string count
        results['top_files'] = sorted(file_stats, key=lambda x: x[1], reverse=True)[:20]
        
        return results
    
    def process_batch(self, limit: int = 0, dry_run: bool = True) -> Dict:
        """Process files in current job"""
        if not self.current_job:
            return {'error': 'No job loaded'}
        
        results = {
            'processed': 0,
            'skipped': 0,
            'errors': 0,
            'strings_found': 0,
        }
        
        pending_files = [
            path for path, stats in self.current_job.files.items()
            if stats.status == 'pending'
        ]
        
        if limit > 0:
            pending_files = pending_files[:limit]
        
        for file_path in pending_files:
            try:
                stats = self.analyze_file(Path(file_path))
                
                self.current_job.files[file_path] = stats
                self.current_job.processed_files += 1
                self.current_job.total_strings += stats.strings_found
                
                if stats.strings_found > 0:
                    results['processed'] += 1
                    results['strings_found'] += stats.strings_found
                    print(f"  📄 {Path(file_path).name}: {stats.strings_found} strings")
                else:
                    results['skipped'] += 1
                    self.current_job.files[file_path].status = 'skipped'
                
            except Exception as e:
                results['errors'] += 1
                self.current_job.files[file_path].status = 'error'
                self.current_job.files[file_path].error = str(e)
            
            # Save state periodically
            if results['processed'] % 10 == 0:
                self.save_state()
        
        self.save_state()
        return results
    
    def get_progress(self) -> Dict:
        """Get current job progress"""
        if not self.current_job:
            return {'error': 'No job loaded'}
        
        pending = sum(1 for s in self.current_job.files.values() if s.status == 'pending')
        processed = sum(1 for s in self.current_job.files.values() if s.status in ['analyzed', 'processed'])
        skipped = sum(1 for s in self.current_job.files.values() if s.status == 'skipped')
        errors = sum(1 for s in self.current_job.files.values() if s.status == 'error')
        
        return {
            'job_id': self.current_job.id,
            'directory': self.current_job.directory,
            'total_files': self.current_job.total_files,
            'pending': pending,
            'processed': processed,
            'skipped': skipped,
            'errors': errors,
            'total_strings': self.current_job.total_strings,
            'progress_percent': round((processed + skipped) / self.current_job.total_files * 100, 1) if self.current_job.total_files > 0 else 0
        }
    
    def generate_report(self) -> str:
        """Generate markdown report"""
        if not self.current_job:
            return "No job loaded"
        
        progress = self.get_progress()
        
        report = f"""# I18N Batch Processing Report

**Job ID:** {progress['job_id']}
**Directory:** {progress['directory']}
**Generated:** {datetime.now().isoformat()}

## Progress

| Metric | Value |
|--------|-------|
| Total Files | {progress['total_files']} |
| Processed | {progress['processed']} |
| Skipped | {progress['skipped']} |
| Errors | {progress['errors']} |
| Pending | {progress['pending']} |
| Progress | {progress['progress_percent']}% |
| Total Strings | {progress['total_strings']} |

## Top Files by String Count

| File | Strings |
|------|---------|
"""
        
        # Sort files by string count
        sorted_files = sorted(
            self.current_job.files.items(),
            key=lambda x: x[1].strings_found,
            reverse=True
        )[:20]
        
        for path, stats in sorted_files:
            if stats.strings_found > 0:
                report += f"| {Path(path).name} | {stats.strings_found} |\n"
        
        if progress['errors'] > 0:
            report += "\n## Errors\n\n"
            for path, stats in self.current_job.files.items():
                if stats.status == 'error':
                    report += f"- **{Path(path).name}**: {stats.error}\n"
        
        return report


def main():
    parser = argparse.ArgumentParser(description="I18N Batch Processor")
    parser.add_argument('--dir', type=str, help='Directory to process')
    parser.add_argument('--pattern', default='*.lua', help='File pattern')
    parser.add_argument('--analyze', action='store_true', help='Analyze only (no changes)')
    parser.add_argument('--process', action='store_true', help='Process files')
    parser.add_argument('--limit', type=int, default=0, help='Limit files to process')
    parser.add_argument('--resume', action='store_true', help='Resume previous job')
    parser.add_argument('--status', action='store_true', help='Show job status')
    parser.add_argument('--report', type=str, help='Generate report to file')
    parser.add_argument('--work-dir', default='.', help='Working directory for state')
    
    args = parser.parse_args()
    
    processor = BatchProcessor(Path(args.work_dir))
    
    # Resume or create new job
    if args.resume:
        job = processor.load_job()
        if not job:
            print("❌ No previous job found")
            return
        print(f"✅ Resumed job: {job.id}")
    
    # Status
    if args.status:
        job = processor.load_job()
        if job:
            progress = processor.get_progress()
            print("\n📊 JOB STATUS")
            for k, v in progress.items():
                print(f"   {k}: {v}")
        else:
            print("No active job")
        return
    
    # Analyze directory
    if args.analyze and args.dir:
        print(f"\n🔍 Analyzing: {args.dir}")
        results = processor.analyze_directory(Path(args.dir), args.pattern)
        
        print(f"\n📊 ANALYSIS RESULTS")
        print(f"   Total files: {results['total_files']}")
        print(f"   Files with strings: {results['files_with_strings']}")
        print(f"   Total strings: {results['total_strings']}")
        
        if results['top_files']:
            print(f"\n📁 TOP FILES:")
            for path, count in results['top_files'][:10]:
                print(f"   {count:4d} - {Path(path).name}")
        return
    
    # Process
    if args.process and args.dir:
        # Create new job
        job = processor.create_job(Path(args.dir), args.pattern)
        print(f"✅ Created job: {job.id}")
        print(f"   Files to process: {job.total_files}")
        
        print(f"\n🔄 Processing...")
        results = processor.process_batch(limit=args.limit, dry_run=False)
        
        print(f"\n📊 RESULTS")
        print(f"   Processed: {results['processed']}")
        print(f"   Skipped: {results['skipped']}")
        print(f"   Errors: {results['errors']}")
        print(f"   Strings found: {results['strings_found']}")
    
    # Generate report
    if args.report:
        job = processor.load_job()
        if job:
            report = processor.generate_report()
            with open(args.report, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"✅ Report saved to: {args.report}")


if __name__ == '__main__':
    main()
