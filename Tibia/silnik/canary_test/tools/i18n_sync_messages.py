#!/usr/bin/env python3

"""
Sync the extracted message catalog (build/i18n/messages.json) with locale JSON
files so translators get an up-to-date scaffold.

Example:
    python tools/i18n_sync_messages.py --locale pl
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = PROJECT_ROOT.parents[2]
DEFAULT_MESSAGES = REPO_ROOT / "build" / "i18n" / "messages.json"
DEFAULT_I18N_ROOT = PROJECT_ROOT / "i18n"


def load_messages(path: Path) -> Dict[str, str]:
	if not path.is_file():
		raise FileNotFoundError(f"messages catalog not found: {path}")

	with path.open(encoding="utf-8") as handle:
		data = json.load(handle)

	mapping: Dict[str, str] = {}
	for entry in data:
		key = (entry.get("key") or "").strip()
		text = (entry.get("text") or "").strip()
		if not key:
			continue
		mapping[key] = text
	return mapping


def load_locale(path: Path) -> Dict[str, str]:
	if not path.is_file():
		return {}
	with path.open(encoding="utf-8") as handle:
		return json.load(handle)


def write_locale(path: Path, entries: Dict[str, str]) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	with path.open("w", encoding="utf-8") as handle:
		json.dump(dict(sorted(entries.items())), handle, ensure_ascii=False, indent=2)
		handle.write("\n")


def sync_locale(locale: str, *,
                messages: Dict[str, str],
                target_dir: Path,
                filename: str,
                base_locale: str,
                backfill: bool) -> Tuple[int, int, int]:
	target_file = target_dir / filename
	existing = load_locale(target_file)
	result: Dict[str, str] = {}

	for key, base_text in messages.items():
		if locale == base_locale:
			result[key] = base_text
			continue

		current = (existing.get(key) or "").strip()
		if current:
			result[key] = current
		elif backfill:
			result[key] = base_text
		else:
			result[key] = ""

	write_locale(target_file, result)
	missing = sum(1 for value in result.values() if not value)
	removed = len(set(existing.keys()) - set(messages.keys()))
	return len(result), missing, removed


def main() -> int:
	parser = argparse.ArgumentParser(description="Sync extracted messages into locale JSON files.")
	parser.add_argument("--messages", type=Path, default=DEFAULT_MESSAGES, help="Path to build/i18n/messages.json.")
	parser.add_argument("--i18n-root", type=Path, default=DEFAULT_I18N_ROOT, help="Root directory holding locale folders.")
	parser.add_argument("--base", default="en", help="Base locale (default: en).")
	parser.add_argument("--locale", action="append", help="Additional locales to sync besides the base locale.")
	parser.add_argument("--filename", default="system.json", help="Name of the JSON file to write inside each locale directory.")
	parser.add_argument("--no-backfill", action="store_true", help="Leave target locale entries blank instead of copying the base text.")
	args = parser.parse_args()

	messages = load_messages(args.messages)
	if not messages:
		raise SystemExit(f"No messages found in {args.messages}")

	if not args.i18n_root.is_dir():
		raise SystemExit(f"i18n root not found: {args.i18n_root}")

	sorted_messages = dict(sorted(messages.items()))
	locales = set(args.locale or [])
	locales.add(args.base)

	for locale in sorted(locales):
		total, missing, removed = sync_locale(
			locale,
			messages=sorted_messages,
			target_dir=args.i18n_root / locale,
			filename=args.filename,
			base_locale=args.base,
			backfill=not args.no_backfill,
		)
		parts = [f"[{locale}] wrote {total} entries to {args.filename}"]
		if missing:
			parts.append(f"missing {missing}")
		if removed:
			parts.append(f"removed {removed}")
		print("; ".join(parts))

	return 0


if __name__ == "__main__":
	raise SystemExit(main())
