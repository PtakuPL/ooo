#!/usr/bin/env python3

"""
Migrate item description literals from data/items/items.xml to i18n keys.

What it does:
1) Replaces every <attribute key="description" value="..."/> with #i18n:item.<id>.desc
2) Writes English source texts to i18n/en/items.json under matching keys

The script preserves items.xml formatting by editing only attribute values in place.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ITEMS_XML = PROJECT_ROOT / "data" / "items" / "items.xml"
DEFAULT_EN_ITEMS_JSON = PROJECT_ROOT / "i18n" / "en" / "items.json"

ITEM_BLOCK_RE = re.compile(r"(<item\b[^>]*[^/]>)(.*?)(</item>)", re.DOTALL)
DESCRIPTION_ATTR_RE = re.compile(
	r'(<attribute\b[^>]*key="description"[^>]*value=")(.*?)("(?=[^>]*\/>))',
	re.DOTALL,
)
ITEM_ID_RE = re.compile(r'\sid="(\d+)"')
ITEM_FROM_ID_RE = re.compile(r'\sfromid="(\d+)"')
ITEM_DESC_KEY_RE = re.compile(r"^item\.\d+\.desc(?:_\d+)*$")


def make_unique_key(base_key: str, text: str, descriptions: dict[str, str]) -> str:
	key = base_key
	suffix = 2
	while key in descriptions and descriptions[key] != text:
		key = f"{base_key}_{suffix}"
		suffix += 1
	return key


def migrate_items_xml(xml_text: str, existing_desc: dict[str, str]) -> tuple[str, dict[str, str], int, int]:
	descriptions: dict[str, str] = {}
	replaced_literals = 0
	already_localized = 0
	new_parts: list[str] = []
	cursor = 0

	for match in ITEM_BLOCK_RE.finditer(xml_text):
		new_parts.append(xml_text[cursor:match.start()])
		start_tag, body, end_tag = match.groups()
		cursor = match.end()

		id_match = ITEM_ID_RE.search(start_tag)
		from_id_match = ITEM_FROM_ID_RE.search(start_tag)
		base_id = id_match.group(1) if id_match else (from_id_match.group(1) if from_id_match else None)
		if not base_id:
			new_parts.append(match.group(0))
			continue

		desc_index = [0]

		def replace_attr(desc_match: re.Match[str]) -> str:
			nonlocal replaced_literals, already_localized

			desc_index[0] += 1
			prefix, raw_value, suffix = desc_match.groups()

			if raw_value.startswith("#i18n:"):
				already_localized += 1
				key = raw_value[6:]
				if key in existing_desc:
					descriptions[key] = existing_desc[key]
				return f"{prefix}{raw_value}{suffix}"

			decoded_value = html.unescape(raw_value)
			base_key = f"item.{base_id}.desc" if desc_index[0] == 1 else f"item.{base_id}.desc_{desc_index[0]}"
			key = make_unique_key(base_key, decoded_value, descriptions)
			descriptions[key] = decoded_value
			replaced_literals += 1
			return f"{prefix}#i18n:{key}{suffix}"

		new_body, _ = DESCRIPTION_ATTR_RE.subn(replace_attr, body)
		new_parts.append(start_tag + new_body + end_tag)

	new_parts.append(xml_text[cursor:])
	new_xml_text = "".join(new_parts)

	# Validate XML integrity after in-place replacement
	ET.fromstring(new_xml_text)
	return new_xml_text, descriptions, replaced_literals, already_localized


def load_json(path: Path) -> dict[str, str]:
	if not path.exists():
		return {}
	with path.open(encoding="utf-8") as handle:
		return json.load(handle)


def save_json(path: Path, payload: dict[str, str]) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	with path.open("w", encoding="utf-8") as handle:
		json.dump(payload, handle, ensure_ascii=False, indent=2)
		handle.write("\n")


def sort_key(key: str) -> tuple[int, int, str]:
	if key.startswith("item.") and key.endswith(".name"):
		item_id = int(key.split(".")[1])
		return (0, item_id, key)
	if ITEM_DESC_KEY_RE.match(key):
		item_id = int(key.split(".")[1])
		return (1, item_id, key)
	return (2, 0, key)


def main() -> int:
	parser = argparse.ArgumentParser(description="Migrate items.xml description literals to i18n keys")
	parser.add_argument("--items-xml", type=Path, default=DEFAULT_ITEMS_XML, help=f"Path to items.xml (default: {DEFAULT_ITEMS_XML})")
	parser.add_argument("--en-items-json", type=Path, default=DEFAULT_EN_ITEMS_JSON, help=f"Path to i18n/en/items.json (default: {DEFAULT_EN_ITEMS_JSON})")
	parser.add_argument("--write", action="store_true", help="Apply changes to files (default is dry-run)")
	args = parser.parse_args()

	if not args.items_xml.is_file():
		raise FileNotFoundError(f"items.xml not found: {args.items_xml}")

	existing_en = load_json(args.en_items_json)
	existing_desc = {k: v for k, v in existing_en.items() if ITEM_DESC_KEY_RE.match(k)}

	xml_text = args.items_xml.read_text(encoding="iso-8859-1")
	new_xml_text, new_desc, replaced_literals, already_localized = migrate_items_xml(xml_text, existing_desc)

	non_desc = {k: v for k, v in existing_en.items() if not ITEM_DESC_KEY_RE.match(k)}
	merged = {**non_desc, **new_desc}
	sorted_payload = dict(sorted(merged.items(), key=lambda entry: sort_key(entry[0])))

	print(f"[items-i18n] Description attributes found: {replaced_literals + already_localized}")
	print(f"[items-i18n] Replaced literal descriptions: {replaced_literals}")
	print(f"[items-i18n] Already localized descriptions: {already_localized}")
	print(f"[items-i18n] EN description keys after migration: {len(new_desc)}")

	if not args.write:
		print("[items-i18n] Dry-run complete. Use --write to apply changes.")
		return 0

	args.items_xml.write_text(new_xml_text, encoding="iso-8859-1")
	save_json(args.en_items_json, sorted_payload)
	print(f"[items-i18n] Updated: {args.items_xml}")
	print(f"[items-i18n] Updated: {args.en_items_json}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
