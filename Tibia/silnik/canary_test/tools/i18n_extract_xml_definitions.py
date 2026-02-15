#!/usr/bin/env python3
"""
I18N XML Definition Extractor
==============================
Extracts translatable names/descriptions from XML definition files:
  - mounts.xml       → i18n/en/mounts.json
  - outfits.xml      → i18n/en/outfits.json
  - familiars.xml    → i18n/en/familiars.json
  - vocations.xml    → i18n/en/vocations.json
  - groups.xml       → i18n/en/groups.json
  - chatchannels.xml → i18n/en/chatchannels.json (merge)
  - imbuements.xml   → i18n/en/imbuements.json

Usage:
  python3 tools/i18n_extract_xml_definitions.py
  python3 tools/i18n_extract_xml_definitions.py --only mounts,outfits
  python3 tools/i18n_extract_xml_definitions.py --dry-run
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def atomic_write_json(path: str, data: Any, indent: int = 2) -> None:
    tmp = path + ".tmp"
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=indent, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def load_json(path: str) -> Dict:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


@dataclass
class ExtractionResult:
    source: str
    target: str
    keys_before: int = 0
    keys_after: int = 0
    keys_added: int = 0
    keys_list: List[str] = field(default_factory=list)


# ─────────────────────────────────────────────────────────────────────────────
# Extractors per XML type
# ─────────────────────────────────────────────────────────────────────────────

def extract_mounts(xml_path: str) -> Dict[str, str]:
    """Extract mount names from mounts.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for mount in root.findall(".//mount"):
        mid = mount.get("id", "")
        name = mount.get("name", "")
        if name and mid:
            key = f"mount.{mid}.name"
            keys[key] = name
    return keys


def extract_outfits(xml_path: str) -> Dict[str, str]:
    """Extract outfit names from outfits.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    seen_names: Set[str] = set()
    for outfit in root.findall(".//outfit"):
        name = outfit.get("name", "")
        looktype = outfit.get("looktype", "")
        otype = outfit.get("type", "0")  # 0=female, 1=male
        if name and looktype:
            # Deduplicate — same name appears for male and female
            if name not in seen_names:
                seen_names.add(name)
                key = f"outfit.{looktype}.name"
                keys[key] = name
    return keys


def extract_familiars(xml_path: str) -> Dict[str, str]:
    """Extract familiar names from familiars.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    seen: Set[str] = set()
    for fam in root.findall(".//familiar"):
        name = fam.get("name", "")
        look = fam.get("lookType", "")
        if name and look and name not in seen:
            seen.add(name)
            key = f"familiar.{look}.name"
            keys[key] = name
    return keys


def extract_vocations(xml_path: str) -> Dict[str, str]:
    """Extract vocation names and descriptions from vocations.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for voc in root.findall(".//vocation"):
        vid = voc.get("id", "")
        name = voc.get("name", "")
        desc = voc.get("description", "")
        if name and vid:
            key = f"vocation.{vid}.name"
            keys[key] = name
        if desc and vid and desc != "none":
            key = f"vocation.{vid}.description"
            keys[key] = desc
    return keys


def extract_groups(xml_path: str) -> Dict[str, str]:
    """Extract group names from groups.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for grp in root.findall(".//group"):
        gid = grp.get("id", "")
        name = grp.get("name", "")
        if name and gid:
            key = f"group.{gid}.name"
            keys[key] = name
    return keys


def extract_chatchannels(xml_path: str) -> Dict[str, str]:
    """Extract chat channel names from chatchannels.xml."""
    keys = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for ch in root.findall(".//channel"):
        cid = ch.get("id", "")
        name = ch.get("name", "")
        if name and cid:
            key = f"chatchannel.{cid}.name"
            keys[key] = name
    return keys


def extract_imbuements(xml_path: str) -> Dict[str, str]:
    """Extract imbuement names/categories from imbuements.xml."""
    keys = {}
    if not os.path.exists(xml_path):
        return keys
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Categories
    for cat in root.findall(".//category"):
        cid = cat.get("id", "")
        name = cat.get("name", "")
        if name and cid:
            keys[f"imbuement.category.{cid}.name"] = name

    # Imbuements
    for imb in root.findall(".//imbuement"):
        iid = imb.get("id", "")
        name = imb.get("name", "")
        if name and iid:
            keys[f"imbuement.{iid}.name"] = name

    # Base imbuements (some XMLs structure differently)
    for base in root.findall(".//baseimbuement"):
        bid = base.get("id", "")
        name = base.get("name", "")
        if name and bid:
            keys[f"imbuement.base.{bid}.name"] = name

    return keys


# ─────────────────────────────────────────────────────────────────────────────
# Source definitions
# ─────────────────────────────────────────────────────────────────────────────

XML_SOURCES = {
    "mounts": {
        "xml_paths": ["data/XML/mounts.xml"],
        "json_target": "mounts.json",
        "extractor": extract_mounts,
    },
    "outfits": {
        "xml_paths": ["data/XML/outfits.xml"],
        "json_target": "outfits.json",
        "extractor": extract_outfits,
    },
    "familiars": {
        "xml_paths": ["data/XML/familiars.xml"],
        "json_target": "familiars.json",
        "extractor": extract_familiars,
    },
    "vocations": {
        "xml_paths": ["data/XML/vocations.xml"],
        "json_target": "vocations.json",
        "extractor": extract_vocations,
    },
    "groups": {
        "xml_paths": ["data/XML/groups.xml"],
        "json_target": "groups.json",
        "extractor": extract_groups,
    },
    "chatchannels": {
        "xml_paths": ["data/chatchannels/chatchannels.xml"],
        "json_target": "chatchannels.json",
        "extractor": extract_chatchannels,
    },
    "imbuements": {
        "xml_paths": [
            "data/XML/imbuements.xml",
            "data/items/imbuements.xml",
        ],
        "json_target": "imbuements.json",
        "extractor": extract_imbuements,
    },
}


def run_extraction(
    project_root: str,
    i18n_dir: str,
    only: Optional[List[str]] = None,
    dry_run: bool = False,
) -> List[ExtractionResult]:
    results = []
    sources = XML_SOURCES if not only else {k: v for k, v in XML_SOURCES.items() if k in only}

    for source_name, cfg in sorted(sources.items()):
        json_path = os.path.join(i18n_dir, "en", cfg["json_target"])
        extractor = cfg["extractor"]

        # Find first existing XML
        xml_path = None
        for xp in cfg["xml_paths"]:
            full = os.path.join(project_root, xp)
            if os.path.exists(full):
                xml_path = full
                break

        if not xml_path:
            print(f"  ⏭️  {source_name}: XML not found ({cfg['xml_paths']})")
            continue

        # Extract keys
        try:
            new_keys = extractor(xml_path)
        except Exception as e:
            print(f"  ❌ {source_name}: extraction error: {e}")
            continue

        if not new_keys:
            print(f"  ⏭️  {source_name}: 0 keys extracted")
            continue

        # Load existing
        existing = load_json(json_path)
        keys_before = len(existing)

        # Merge
        merged = dict(existing)
        added = []
        for k, v in sorted(new_keys.items()):
            if k not in merged:
                added.append(k)
            merged[k] = v  # Always update value (XML is source of truth)

        keys_after = len(merged)

        result = ExtractionResult(
            source=os.path.relpath(xml_path, project_root),
            target=os.path.relpath(json_path, project_root) if os.path.exists(json_path) else json_path,
            keys_before=keys_before,
            keys_after=keys_after,
            keys_added=len(added),
            keys_list=added[:20],  # Show first 20
        )
        results.append(result)

        # Write
        if not dry_run:
            sorted_merged = dict(sorted(merged.items()))
            atomic_write_json(json_path, sorted_merged)

        status = "DRY" if dry_run else "OK"
        print(f"  ✅ {source_name}: {keys_after} keys ({len(added)} new) [{status}] → {cfg['json_target']}")
        if added and len(added) <= 10:
            for k in added:
                print(f"      + {k}: {new_keys[k]}")
        elif added:
            print(f"      + {added[0]}: {new_keys[added[0]]}")
            print(f"      ... and {len(added)-1} more")

    return results


def main() -> int:
    p = argparse.ArgumentParser(description="Extract translatable names from XML definition files")
    p.add_argument("--project-root", default=".", help="Project root")
    p.add_argument("--i18n-dir", default="i18n", help="i18n directory")
    p.add_argument("--only", default=None, help="Comma-separated list: mounts,outfits,familiars,vocations,groups,chatchannels,imbuements")
    p.add_argument("--dry-run", action="store_true", help="Don't write files")
    args = p.parse_args()

    only = args.only.split(",") if args.only else None
    print(f"🔄 XML Definition Extraction (dry_run={args.dry_run})")
    results = run_extraction(args.project_root, args.i18n_dir, only, args.dry_run)

    total_added = sum(r.keys_added for r in results)
    total_keys = sum(r.keys_after for r in results)
    print(f"\n__XML_EXTRACT__ sources={len(results)} total_keys={total_keys} new_keys={total_added}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
