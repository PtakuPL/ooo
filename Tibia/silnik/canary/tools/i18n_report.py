#!/usr/bin/env python3

"""
Generate translation coverage reports and CSV exports for translators.

Examples:
    python tools/i18n_report.py --locales pl
    python tools/i18n_report.py --base en --locales pl de --csv-dir Tibia/silnik/canary/i18n/reports
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
from typing import Dict

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_I18N_ROOT = ROOT_DIR / "i18n"


def flatten_json(node, prefix="", output=None):
	if output is None:
		output = {}

	if isinstance(node, dict):
		for key, value in node.items():
			child_key = key if not prefix else f"{prefix}.{key}"
			flatten_json(value, child_key, output)
	elif isinstance(node, list):
		for index, value in enumerate(node):
			child_key = f"{prefix}[{index}]"
			flatten_json(value, child_key, output)
	else:
		output[prefix] = "" if node is None else str(node)
	return output


def load_locale(locale_dir: Path) -> Dict[str, str]:
	values: Dict[str, str] = {}
	for json_path in sorted(locale_dir.rglob("*.json")):
		with json_path.open(encoding="utf-8") as handle:
			try:
				data = json.load(handle)
			except json.JSONDecodeError as err:
				raise RuntimeError(f"Failed to parse {json_path}: {err}") from err
		values.update(flatten_json(data))
	return values


def ensure_csv_dir(path: Path) -> Path:
	path.mkdir(parents=True, exist_ok=True)
	return path


def write_csv(locale: str, csv_dir: Path, rows):
	target = ensure_csv_dir(csv_dir) / f"{locale}.csv"
	with target.open("w", encoding="utf-8", newline="") as handle:
		writer = csv.writer(handle)
		writer.writerow(["key", "en", locale, "status"])
		writer.writerows(rows)
	return target


def calculate_stats(base_map: Dict[str, str], locale_map: Dict[str, str]):
	stats = {
		"total": len(base_map),
		"translated": 0,
		"missing": 0,
		"identical": 0,
	}
	rows = []

	for key, base_value in base_map.items():
		value = locale_map.get(key, "").strip()
		if not value:
			stats["missing"] += 1
			status = "missing"
		elif value == base_value:
			stats["identical"] += 1
			stats["translated"] += 1
			status = "identical"
		else:
			stats["translated"] += 1
			status = "translated"

		rows.append((key, base_value, value, status))

	return stats, rows


def main():
	parser = argparse.ArgumentParser(description="Report translation coverage and export CSVs.")
	parser.add_argument("--i18n-root", type=Path, default=DEFAULT_I18N_ROOT, help="Root directory containing locale folders.")
	parser.add_argument("--base", default="en", help="Base locale to compare against (default: en).")
	parser.add_argument("--locales", nargs="+", help="Locales to inspect (default: all subdirectories except base).")
	parser.add_argument("--csv-dir", type=Path, help="Optional directory to write CSV exports.")
	args = parser.parse_args()

	if not args.i18n_root.is_dir():
		raise SystemExit(f"i18n root not found: {args.i18n_root}")

	base_dir = args.i18n_root / args.base
	if not base_dir.is_dir():
		raise SystemExit(f"Base locale '{args.base}' not found under {args.i18n_root}")

	base_map = load_locale(base_dir)
	if not base_map:
		raise SystemExit(f"Base locale '{args.base}' has no entries.")

	locales = args.locales
	if not locales:
		locales = sorted(
			locale_dir.name
			for locale_dir in args.i18n_root.iterdir()
			if locale_dir.is_dir() and locale_dir.name != args.base
		)

	for locale in locales:
		locale_dir = args.i18n_root / locale
		if not locale_dir.is_dir():
			print(f"[warn] locale '{locale}' not found, skipping.")
			continue

		locale_map = load_locale(locale_dir)
		stats, rows = calculate_stats(base_map, locale_map)

		coverage = (stats["translated"] / stats["total"]) * 100 if stats["total"] else 0.0
		print(f"[{locale}] {stats['translated']}/{stats['total']} translated ({coverage:.2f}%). Missing: {stats['missing']}, identical to EN: {stats['identical']}.")

		if args.csv_dir:
			target = write_csv(locale, args.csv_dir, rows)
			print(f"    ↳ CSV exported to {target}")

	return 0


if __name__ == "__main__":
	raise SystemExit(main())
