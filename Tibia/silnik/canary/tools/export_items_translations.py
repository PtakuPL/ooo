#!/usr/bin/env python3

"""
Export item names from items.xml into JSON translation packs.

Usage examples:
  python tools/export_items_translations.py --locale en --locale pl
  python tools/export_items_translations.py --items path/to/items.xml --locale pl --i18n-root ./custom-i18n
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import xml.etree.ElementTree as ET


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ITEMS = PROJECT_ROOT / "data" / "items" / "items.xml"
DEFAULT_I18N = PROJECT_ROOT / "i18n"


def parse_ids(node: ET.Element) -> list[int]:
	if "id" in node.attrib:
		return [int(node.attrib["id"])]

	if "fromid" in node.attrib and "toid" in node.attrib:
		start = int(node.attrib["fromid"])
		end = int(node.attrib["toid"])
		return list(range(start, end + 1))

	return []


def load_items(items_path: Path) -> dict[str, str]:
	if not items_path.is_file():
		raise FileNotFoundError(f"items.xml not found: {items_path}")

	tree = ET.parse(items_path)
	root = tree.getroot()
	mapping: dict[str, str] = {}

	for node in root.findall("item"):
		name = (node.get("name") or "").strip()
		if not name:
			continue

		for item_id in parse_ids(node):
			mapping[f"items.{item_id}.name"] = name

	return mapping


def load_existing(path: Path) -> dict[str, str]:
	if not path.is_file():
		return {}
	with path.open(encoding="utf-8") as handle:
		return json.load(handle)


def write_locale(locale: str, values: dict[str, str], i18n_root: Path, backfill: bool) -> None:
	target_dir = i18n_root / locale
	target_dir.mkdir(parents=True, exist_ok=True)
	target_file = target_dir / "items.json"

	existing = load_existing(target_file)
	merged: dict[str, str] = {}

	for key, english_value in values.items():
		if locale == "en":
			merged[key] = english_value
			continue

		if key in existing and existing[key].strip():
			merged[key] = existing[key]
		elif backfill:
			merged[key] = english_value
		else:
			merged[key] = ""

	if locale != "en":
		for stale_key in set(existing.keys()) - set(values.keys()):
			merged.pop(stale_key, None)

	with target_file.open("w", encoding="utf-8") as handle:
		json.dump(dict(sorted(merged.items())), handle, ensure_ascii=False, indent=2)
		handle.write("\n")

	print(f"[i18n] Wrote {len(merged):,} entries to {target_file}")


def main(argv: list[str]) -> int:
	parser = argparse.ArgumentParser(description="Generate item translation packs")
	parser.add_argument("--items", type=Path, default=DEFAULT_ITEMS, help="Path to items.xml (default: %(default)s)")
	parser.add_argument("--locale", action="append", required=True, help="Locale to (re)generate. Pass multiple --locale flags for more than one language.")
	parser.add_argument("--i18n-root", type=Path, default=DEFAULT_I18N, help="Root directory where locale folders live (default: %(default)s)")
	parser.add_argument("--no-backfill", action="store_true", help="Do not prefill missing translations with English text.")
	args = parser.parse_args(argv)

	item_values = load_items(args.items)
	print(f"[i18n] Parsed {len(item_values):,} item names from {args.items}")

	for locale in args.locale:
		write_locale(locale, item_values, args.i18n_root, backfill=not args.no_backfill)

	return 0


if __name__ == "__main__":
	raise SystemExit(main(sys.argv[1:]))
