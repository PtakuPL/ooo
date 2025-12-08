#!/usr/bin/env python3

"""
Run the full server-side i18n tooling pipeline (extract ➜ sync ➜ items ➜ report)
with a single command so both agents can refresh data/CSV in one step.

Example:
    python tools/i18n_pipeline.py --locales pl
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path
from typing import Sequence

PROJECT_ROOT = Path(__file__).resolve().parents[1]
BUILD_I18N_DIR = PROJECT_ROOT / "build" / "i18n"
DEFAULT_MESSAGES = BUILD_I18N_DIR / "messages.json"
DEFAULT_REPORTS_DIR = PROJECT_ROOT / "i18n" / "reports"


def run_step(cmd: Sequence[str], *, cwd: Path = PROJECT_ROOT) -> None:
	print(f"[i18n] $ {' '.join(cmd)}")
	result = subprocess.run(cmd, cwd=cwd)
	if result.returncode != 0:
		raise SystemExit(result.returncode)


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
	parser = argparse.ArgumentParser(description="Run the full I18N tooling pipeline.")
	parser.add_argument(
		"--locales",
		nargs="+",
		default=["pl"],
		help="Locales to sync/report (default: %(default)s).",
	)
	parser.add_argument(
		"--messages-out",
		type=Path,
		default=DEFAULT_MESSAGES,
		help="Path for build/i18n/messages.json (default: %(default)s).",
	)
	parser.add_argument(
		"--reports-dir",
		type=Path,
		default=DEFAULT_REPORTS_DIR,
		help="Directory for CSV exports (default: %(default)s).",
	)
	parser.add_argument(
		"--i18n-root",
		type=Path,
		default=PROJECT_ROOT / "i18n",
		help="Root directory with locale folders (default: %(default)s).",
	)
	parser.add_argument(
		"--skip-items",
		action="store_true",
		help="Skip export_items_translations.py (useful for quick sync/report).",
	)
	return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
	args = parse_args(argv)
	locales = list(args.locales)
	messages_out = args.messages_out
	reports_dir = args.reports_dir
	i18n_root = args.i18n_root

	BUILD_I18N_DIR.mkdir(parents=True, exist_ok=True)
	reports_dir.mkdir(parents=True, exist_ok=True)

	run_step(["python3", "tools/i18n_extract_messages.py", "--out", str(messages_out)])

	for locale in locales:
		run_step([
			"python3",
			"tools/i18n_sync_messages.py",
			"--locale",
			locale,
			"--messages",
			str(messages_out),
			"--filename",
			"system.json",
			"--i18n-root",
			str(i18n_root),
		])

	if not args.skip_items:
		item_locales = sorted(set(["en", *locales]))
		cmd = ["python3", "tools/export_items_translations.py"]
		for locale in item_locales:
			cmd.extend(["--locale", locale])
		cmd.extend(["--i18n-root", str(i18n_root)])
		run_step(cmd)

	report_cmd = [
		"python3",
		"tools/i18n_report.py",
		"--base",
		"en",
		"--csv-dir",
		str(reports_dir),
		"--i18n-root",
		str(i18n_root),
		"--locales",
	]
	report_cmd.extend(locales)
	run_step(report_cmd)

	print("[i18n] Pipeline finished successfully.")
	return 0


if __name__ == "__main__":
	raise SystemExit(main(sys.argv[1:]))
