#!/usr/bin/env python3
"""
I18N Quest & GameStore Extractor
==================================
Extracts translatable strings from Lua definition files:
  - quests.lua → i18n/en/questlog.json (quest names, mission names, string descriptions)
  - gamestore.lua → i18n/en/store.json (category names, offer names, descriptions)

Handles dynamic descriptions (functions) by extracting return strings inside them.

Usage:
  python3 tools/i18n_extract_lua_definitions.py
  python3 tools/i18n_extract_lua_definitions.py --only quests
  python3 tools/i18n_extract_lua_definitions.py --only gamestore
  python3 tools/i18n_extract_lua_definitions.py --dry-run
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import OrderedDict
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple


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


def slugify(text: str) -> str:
    """Convert text to a short snake_case slug."""
    t = text[:40].strip().lower()
    t = re.sub(r"[^a-z0-9]+", "_", t)
    t = t.strip("_")
    if len(t) > 30:
        t = t[:30].rsplit("_", 1)[0]
    return t or "unnamed"


# ─────────────────────────────────────────────────────────────────────────────
# Quest Extractor
# ─────────────────────────────────────────────────────────────────────────────

def extract_quests(lua_path: str) -> Dict[str, str]:
    """Extract quest names, mission names, and string descriptions from quests.lua.

    Returns dict of i18n keys → EN values.
    Pattern: questlog.{slug}.name, questlog.{slug}.mission.{n}.name, etc.
    """
    keys: Dict[str, str] = {}

    with open(lua_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    # State machine parser for the Quests table
    quest_id = 0
    current_quest_name = ""
    current_quest_slug = ""
    mission_id = 0
    in_quest = False
    in_mission = False
    in_function = False
    func_depth = 0
    func_return_count = 0

    for line in content.splitlines():
        stripped = line.strip()

        # Detect quest block: [N] = {
        m_quest = re.match(r"\[(\d+)\]\s*=\s*\{", stripped)
        if m_quest and not in_mission:
            quest_id = int(m_quest.group(1))
            in_quest = True
            current_quest_name = ""
            current_quest_slug = ""
            mission_id = 0
            continue

        # Quest name
        if in_quest and not in_mission:
            m_name = re.match(r'name\s*=\s*"([^"]+)"', stripped)
            if m_name:
                current_quest_name = m_name.group(1)
                current_quest_slug = slugify(current_quest_name)
                key = f"questlog.{current_quest_slug}.name"
                keys[key] = current_quest_name
                continue

        # Mission block
        m_mission = re.match(r"\[(\d+)\]\s*=\s*\{", stripped)
        if m_mission and in_quest and "missions" not in stripped:
            # Check if we're inside missions table
            mission_id = int(m_mission.group(1))
            in_mission = True
            in_function = False
            func_depth = 0
            func_return_count = 0
            continue

        if in_mission:
            # Mission name
            m_mname = re.match(r'name\s*=\s*"([^"]+)"', stripped)
            if m_mname:
                mname = m_mname.group(1)
                key = f"questlog.{current_quest_slug}.mission.{mission_id}.name"
                keys[key] = mname
                continue

            # String description (not function)
            m_desc = re.match(r'description\s*=\s*"([^"]*)"', stripped)
            if m_desc and not in_function:
                desc = m_desc.group(1)
                if desc:
                    key = f"questlog.{current_quest_slug}.mission.{mission_id}.description"
                    keys[key] = desc
                continue

            # Function description start
            if "description = function" in stripped:
                in_function = True
                func_depth = 1
                func_return_count = 0
                continue

            # Inside function — extract return strings
            if in_function:
                # Track depth
                func_depth += stripped.count("{") + stripped.count("function")
                func_depth -= stripped.count("}")

                # Extract return "..." strings
                m_return = re.search(r'return\s+"([^"]+)"', stripped)
                if m_return:
                    func_return_count += 1
                    ret_text = m_return.group(1)
                    key = f"questlog.{current_quest_slug}.mission.{mission_id}.desc_fn.{func_return_count}"
                    keys[key] = ret_text

                if func_depth <= 0 or stripped == "end,":
                    in_function = False
                continue

            # End of mission block
            if stripped == "},":
                in_mission = False
                continue

    return keys


# ─────────────────────────────────────────────────────────────────────────────
# GameStore Extractor
# ─────────────────────────────────────────────────────────────────────────────

def extract_gamestore(lua_path: str) -> Dict[str, str]:
    """Extract GameStore category names, offer names and descriptions.

    Returns dict of i18n keys → EN values.
    Pattern: store.category.{slug}.name, store.offer.{n}.name, store.offer.{n}.description
    """
    keys: Dict[str, str] = {}

    with open(lua_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    # Extract category names: name = "..."
    # In gamestore.lua, categories have icons and names
    cat_count = 0
    offer_count = 0
    in_category = False
    in_offer = False
    current_cat_slug = ""

    for line in content.splitlines():
        stripped = line.strip()

        # Category detection (various patterns)
        # GameStore.Categories = { { name = "..." }, ... }
        m_cat_name = re.match(r'name\s*=\s*"([^"]+)"', stripped)
        if m_cat_name:
            name = m_cat_name.group(1)
            # Skip very short or technical names
            if len(name) >= 3 and not name.startswith("$"):
                # Determine if this is a category or offer based on context
                cat_count += 1
                slug = slugify(name)
                key = f"store.item.{cat_count}.name"
                keys[key] = name
                current_cat_slug = slug

        # Description strings
        m_desc = re.match(r'description\s*=\s*"([^"]{5,})"', stripped)
        if m_desc:
            desc = m_desc.group(1)
            if not desc.startswith("http") and not desc.startswith("$"):
                offer_count += 1
                key = f"store.desc.{offer_count}"
                keys[key] = desc

    return keys


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

LUA_SOURCES = {
    "quests": {
        "lua_paths": [
            "data-otservbr-global/lib/core/quests.lua",
            "data-canary/lib/core/quests.lua",
            "data/lib/core/quests.lua",
        ],
        "json_target": "questlog.json",
        "extractor": extract_quests,
    },
    "gamestore": {
        "lua_paths": [
            "data/modules/scripts/gamestore/gamestore.lua",
            "data-otservbr-global/modules/scripts/gamestore/gamestore.lua",
        ],
        "json_target": "store.json",
        "extractor": extract_gamestore,
    },
}


def run(project_root: str, i18n_dir: str, only: Optional[List[str]] = None, dry_run: bool = False) -> int:
    sources = LUA_SOURCES if not only else {k: v for k, v in LUA_SOURCES.items() if k in only}
    total_added = 0

    for src_name, cfg in sorted(sources.items()):
        json_path = os.path.join(i18n_dir, "en", cfg["json_target"])
        extractor = cfg["extractor"]

        # Find first existing Lua file
        lua_path = None
        for lp in cfg["lua_paths"]:
            full = os.path.join(project_root, lp)
            if os.path.exists(full):
                lua_path = full
                break

        if not lua_path:
            print(f"  ⏭️  {src_name}: Lua file not found ({cfg['lua_paths']})")
            continue

        # Extract
        try:
            new_keys = extractor(lua_path)
        except Exception as e:
            print(f"  ❌ {src_name}: extraction error: {e}")
            import traceback
            traceback.print_exc()
            continue

        if not new_keys:
            print(f"  ⏭️  {src_name}: 0 keys extracted")
            continue

        # Load existing and merge
        existing = load_json(json_path)
        keys_before = len(existing)
        merged = dict(existing)
        added = 0
        for k, v in new_keys.items():
            if k not in merged:
                added += 1
            merged[k] = v  # Update value too

        keys_after = len(merged)
        total_added += added

        if not dry_run:
            sorted_merged = dict(sorted(merged.items()))
            atomic_write_json(json_path, sorted_merged)

        status = "DRY" if dry_run else "OK"
        print(f"  ✅ {src_name}: {keys_after} keys total ({added} new) [{status}] → {cfg['json_target']}")
        print(f"     Source: {os.path.relpath(lua_path, project_root)}")

    print(f"\n__LUA_EXTRACT__ total_new_keys={total_added}")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="Extract translatable strings from Lua definition files")
    p.add_argument("--project-root", default=".", help="Project root")
    p.add_argument("--i18n-dir", default="i18n", help="i18n directory")
    p.add_argument("--only", default=None, help="Comma-separated: quests,gamestore")
    p.add_argument("--dry-run", action="store_true", help="Don't write files")
    args = p.parse_args()

    only = args.only.split(",") if args.only else None
    print(f"🔄 Lua Definition Extraction (dry_run={args.dry_run})")
    return run(args.project_root, args.i18n_dir, only, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
