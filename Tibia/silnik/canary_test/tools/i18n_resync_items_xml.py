#!/usr/bin/env python3
"""
Resync i18n/en/items.json from data/items/items.xml (or data-otservbr-global/items/items.xml).

This tool is intentionally domain-specific for items.xml and supports:
  - <item id="...">
  - <item fromid="..." toid="...">
  - self-closing and block items
  - description markers (#i18n:...) without writing marker values into EN JSON

Output lines:
  - __ITEMS_NEEDS_WORK__ 0|1            (with --check-only)
  - __ITEMS_RESULT__ keys_added=N items_processed=M repaired_values=R
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import shutil
import sys
from typing import Dict, Iterable, List, Optional


ITEM_BLOCK_RE = re.compile(r"<item\b([^>]*)>(.*?)</item>", re.IGNORECASE | re.DOTALL)
ITEM_SELF_RE = re.compile(r"<item\b([^>]*)/>", re.IGNORECASE | re.DOTALL)
ATTR_RE = re.compile(r'(\w+)\s*=\s*"([^"]*)"')
DESC_RE = re.compile(
    r'<attribute\b[^>]*\bkey\s*=\s*"description"[^>]*\bvalue\s*=\s*"([^"]*)"',
    re.IGNORECASE,
)
ITEM_DESC_KEY_RE = re.compile(r"^item\.\d+\.desc(?:_\d+)?$")


def read_text_autodetect(path: str) -> str:
    for enc in ("utf-8", "iso-8859-1", "latin-1"):
        try:
            with open(path, "r", encoding=enc) as f:
                return f.read()
        except Exception:
            continue
    raise OSError(f"failed to read {path} with supported encodings")


def load_json(path: str) -> Dict[str, str]:
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            return data
    except Exception:
        pass
    return {}


def decode_text(value: str) -> str:
    text = html.unescape(value or "")
    text = text.replace("\\n", " ").replace("\\t", " ")
    return re.sub(r"\s+", " ", text).strip()


def parse_item_ids(attrs: Dict[str, str]) -> List[int]:
    item_id = attrs.get("id", "").strip()
    if item_id.isdigit():
        return [int(item_id)]

    from_id = attrs.get("fromid", "").strip()
    to_id = attrs.get("toid", "").strip()
    if from_id.isdigit() and to_id.isdigit():
        a = int(from_id)
        b = int(to_id)
        if a <= b:
            return list(range(a, b + 1))
    return []


def iter_items(xml_text: str) -> Iterable[Dict[str, object]]:
    # Block items first
    for m in ITEM_BLOCK_RE.finditer(xml_text):
        attrs = dict(ATTR_RE.findall(m.group(1) or ""))
        ids = parse_item_ids(attrs)
        if not ids:
            continue
        desc = None
        dm = DESC_RE.search(m.group(2) or "")
        if dm:
            desc = dm.group(1)
        yield {
            "ids": ids,
            "name": decode_text(attrs.get("name", "")),
            "desc_raw": desc,
        }

    # Self-closing items
    for m in ITEM_SELF_RE.finditer(xml_text):
        attrs = dict(ATTR_RE.findall(m.group(1) or ""))
        ids = parse_item_ids(attrs)
        if not ids:
            continue
        yield {
            "ids": ids,
            "name": decode_text(attrs.get("name", "")),
            "desc_raw": None,
        }


def resolve_marker_to_text(marker_key: str, data: Dict[str, str], depth: int = 6) -> Optional[str]:
    key = marker_key
    visited = set()
    for _ in range(max(1, depth)):
        if key in visited:
            return None
        visited.add(key)
        value = data.get(key)
        if not isinstance(value, str) or not value:
            return None
        if value.startswith("#i18n:"):
            key = value[6:]
            continue
        return value
    return None


def repair_marker_values(data: Dict[str, str]) -> int:
    repaired = 0
    for k, v in list(data.items()):
        if not isinstance(v, str):
            continue
        if not ITEM_DESC_KEY_RE.match(str(k)):
            continue
        if not v.startswith("#i18n:"):
            continue
        resolved = resolve_marker_to_text(v[6:], data)
        if resolved and resolved != v:
            data[k] = resolved
            repaired += 1
    return repaired


def needs_work(data: Dict[str, str], xml_text: str) -> bool:
    for item in iter_items(xml_text):
        ids = item["ids"]
        name = item["name"]
        desc_raw = item["desc_raw"]

        if name:
            for item_id in ids:
                if f"item.{item_id}.name" not in data:
                    return True

        if isinstance(desc_raw, str) and desc_raw:
            if desc_raw.startswith("#i18n:"):
                # Marker-based descriptions are already keyed in runtime.
                continue
            for item_id in ids:
                if f"item.{item_id}.desc" not in data:
                    return True

    # Marker aliases in EN JSON should be repaired to plain source text.
    for k, v in data.items():
        if not isinstance(v, str):
            continue
        if ITEM_DESC_KEY_RE.match(str(k)) and v.startswith("#i18n:"):
            return True

    return False


def atomic_write_json(path: str, payload: Dict[str, str]) -> None:
    tmp = f"{path}.tmp"
    if os.path.exists(path):
        try:
            shutil.copy2(path, f"{path}.bak")
        except Exception:
            pass
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tmp, path)


def resync_items(data: Dict[str, str], xml_text: str, batch: int) -> tuple[int, int, int]:
    keys_added = 0
    items_processed = 0
    repaired_values = repair_marker_values(data)

    candidates: List[Dict[str, object]] = []
    for item in iter_items(xml_text):
        ids = item["ids"]
        name = item["name"]
        desc_raw = item["desc_raw"]

        missing_name_ids: List[int] = []
        if name:
            for item_id in ids:
                if f"item.{item_id}.name" not in data:
                    missing_name_ids.append(item_id)

        desc_text: Optional[str] = None
        if isinstance(desc_raw, str) and desc_raw:
            if desc_raw.startswith("#i18n:"):
                # Keep marker-based description keys in XML runtime path.
                desc_text = None
            else:
                desc_text = decode_text(desc_raw)

        missing_desc_ids: List[int] = []
        if desc_text:
            for item_id in ids:
                if f"item.{item_id}.desc" not in data:
                    missing_desc_ids.append(item_id)

        if missing_name_ids or missing_desc_ids:
            candidates.append(
                {
                    "name": name,
                    "desc_text": desc_text,
                    "missing_name_ids": missing_name_ids,
                    "missing_desc_ids": missing_desc_ids,
                }
            )

    for candidate in candidates[: max(1, int(batch))]:
        added_any = False

        name = candidate["name"]
        desc_text = candidate["desc_text"]

        for item_id in candidate["missing_name_ids"]:
            data[f"item.{item_id}.name"] = name
            keys_added += 1
            added_any = True

        if desc_text:
            for item_id in candidate["missing_desc_ids"]:
                data[f"item.{item_id}.desc"] = desc_text
                keys_added += 1
                added_any = True

        if added_any:
            items_processed += 1

    return keys_added, items_processed, repaired_values


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Resync i18n/en/items.json from items.xml")
    p.add_argument("--json", required=True, help="Path to i18n/en/items.json")
    p.add_argument("--items-xml", required=True, help="Path to items.xml")
    p.add_argument("--batch", type=int, default=10, help="How many item entries to process")
    p.add_argument("--check-only", action="store_true", help="Do not write; only report if work exists")
    return p.parse_args()


def main() -> int:
    args = parse_args()

    data = load_json(args.json)
    try:
        xml_text = read_text_autodetect(args.items_xml)
    except Exception:
        print("__ITEMS_NEEDS_WORK__ 0")
        print("__ITEMS_RESULT__ keys_added=0 items_processed=0 repaired_values=0")
        return 1

    if args.check_only:
        print(f"__ITEMS_NEEDS_WORK__ {1 if needs_work(data, xml_text) else 0}")
        print("__ITEMS_RESULT__ keys_added=0 items_processed=0 repaired_values=0")
        return 0

    keys_added, items_processed, repaired_values = resync_items(
        data=data,
        xml_text=xml_text,
        batch=max(1, int(args.batch)),
    )

    if keys_added > 0 or repaired_values > 0:
        atomic_write_json(args.json, data)

    print(
        f"__ITEMS_RESULT__ keys_added={keys_added} items_processed={items_processed} repaired_values={repaired_values}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
