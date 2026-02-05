#!/usr/bin/env python3
"""
Extract book/letter/scroll texts from Lua scripts and .otbm map file.
Generate i18n/en/books.json with all texts as translation keys.

Usage: python3 tools/extract_book_texts.py
"""

import json
import re
import os
import hashlib
import subprocess
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data-otservbr-global")
I18N_DIR = os.path.join(BASE_DIR, "i18n")
OTBM_FILE = os.path.join(DATA_DIR, "world", "otservbr.otbm")

def slugify(text, max_words=6, max_len=60):
    """Convert text to a slug for i18n key."""
    # Take first line or first N words
    first_line = text.strip().split('\n')[0].strip()
    # Remove special chars
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', first_line).lower()
    words = clean.split()[:max_words]
    slug = '_'.join(words)
    return slug[:max_len]

def text_hash(text):
    """Generate short hash from text content."""
    return hashlib.md5(text.encode('utf-8')).hexdigest()[:8]

def extract_lua_texts():
    """Extract all known book/letter/scroll texts from Lua scripts."""
    texts = {}
    
    # ============================================================
    # quest_system2.lua
    # ============================================================
    qs2_path = os.path.join(DATA_DIR, "scripts/actions/other/others/quest_system2.lua")
    with open(qs2_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract multiline [[...]] texts
    # Pattern: text = [[\n...\n]]
    multiline_pattern = re.compile(r'text\s*=\s*\[\[(.*?)\]\]', re.DOTALL)
    quoted_pattern = re.compile(r'text\s*=\s*"((?:[^"\\]|\\.)*)"')
    
    for match in multiline_pattern.finditer(content):
        raw_text = match.group(1).strip()
        if len(raw_text) < 10:
            continue
        slug = slugify(raw_text)
        key = f"book.quest_system2.{slug}"
        # Deduplicate
        if raw_text not in [v for v in texts.values()]:
            texts[key] = raw_text
    
    for match in quoted_pattern.finditer(content):
        raw_text = match.group(1).strip()
        if len(raw_text) < 10:
            continue
        slug = slugify(raw_text)
        key = f"book.quest_system2.{slug}"
        texts[key] = raw_text
    
    # ============================================================
    # koshei_the_deathless_quest/action_bag.lua
    # ============================================================
    koshei_path = os.path.join(DATA_DIR, "scripts/quests/koshei_the_deathless_quest/action_bag.lua")
    if os.path.exists(koshei_path):
        with open(koshei_path, 'r', encoding='utf-8') as f:
            content = f.read()
        for match in multiline_pattern.finditer(content):
            raw_text = match.group(1).strip()
            if len(raw_text) < 10:
                continue
            texts["book.koshei.famous_inhabitants_page_2"] = raw_text
    
    # ============================================================
    # the_new_frontier/action_hidden_note.lua
    # ============================================================
    tnf_path = os.path.join(DATA_DIR, "scripts/quests/the_new_frontier/action_hidden_note.lua")
    if os.path.exists(tnf_path):
        with open(tnf_path, 'r', encoding='utf-8') as f:
            content = f.read()
        for match in quoted_pattern.finditer(content):
            raw_text = match.group(1).strip()
            if "secret door" in raw_text.lower():
                texts["book.new_frontier.hidden_note"] = raw_text
    
    # Also handle setAttribute patterns
    attr_pattern = re.compile(r'setAttribute\s*\(\s*ITEM_ATTRIBUTE_TEXT\s*,\s*"((?:[^"\\]|\\.)*)"', re.DOTALL)
    for match in attr_pattern.finditer(content):
        raw_text = match.group(1).strip()
        if len(raw_text) >= 10 and raw_text not in texts.values():
            texts["book.new_frontier.hidden_note"] = raw_text
    
    # ============================================================
    # the_cursed_crystal/actions_Misc.lua
    # ============================================================
    tcc_path = os.path.join(DATA_DIR, "scripts/quests/the_cursed_crystal/actions_Misc.lua")
    if os.path.exists(tcc_path):
        with open(tcc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # This file uses setAttribute with long string
        attr_pattern2 = re.compile(r'setAttribute\s*\(\s*\n?\s*ITEM_ATTRIBUTE_TEXT\s*,\s*\n?\s*"((?:[^"\\]|\\.)*)"', re.DOTALL)
        for match in attr_pattern2.finditer(content):
            raw_text = match.group(1).strip()
            if len(raw_text) >= 50:
                texts["book.cursed_crystal.crystal_gardens_diary"] = raw_text
    
    # ============================================================
    # dawnport/actions_vocation_reward.lua
    # ============================================================
    dawn_path = os.path.join(DATA_DIR, "scripts/quests/dawnport/actions_vocation_reward.lua")
    if os.path.exists(dawn_path):
        with open(dawn_path, 'r', encoding='utf-8') as f:
            content = f.read()
        for match in multiline_pattern.finditer(content):
            raw_text = match.group(1).strip()
            if "adventurer" in raw_text.lower():
                texts["book.dawnport.adventurers_guild_letter"] = raw_text
    
    # ============================================================
    # quest_reward_common.lua - AttributeTable
    # ============================================================
    qrc_path = os.path.join(DATA_DIR, "scripts/actions/system/quest_reward_common.lua")
    if os.path.exists(qrc_path):
        with open(qrc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract texts from AttributeTable
        for match in multiline_pattern.finditer(content):
            raw_text = match.group(1).strip()
            if len(raw_text) < 10:
                continue
            if "Hardek" in raw_text:
                texts["book.quest_reward.wanted_list"] = raw_text
            elif "dream master" in raw_text:
                texts["book.quest_reward.nightmare_knights_diary"] = raw_text
            elif "fox" in raw_text.lower():
                texts["book.quest_reward.horned_fox_note"] = raw_text
    
    # ============================================================
    # parchment_room/parchment.lua
    # ============================================================
    parch_path = os.path.join(DATA_DIR, "scripts/quests/parchment_room/parchment.lua")
    if os.path.exists(parch_path):
        with open(parch_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # Uses setText("...")
        set_text_pattern = re.compile(r'setText\s*\(\s*"((?:[^"\\]|\\.)*)"', re.DOTALL)
        for match in set_text_pattern.finditer(content):
            raw_text = match.group(1).strip()
            if len(raw_text) >= 10:
                texts["book.parchment_room.demon_seal"] = raw_text
    
    return texts

def extract_otbm_texts():
    """Extract readable texts from .otbm map file using strings."""
    texts = {}
    
    if not os.path.exists(OTBM_FILE):
        print(f"WARNING: .otbm file not found: {OTBM_FILE}")
        return texts
    
    try:
        # Extract strings > 20 chars from binary .otbm
        result = subprocess.run(
            ['strings', '-n', '20', OTBM_FILE],
            capture_output=True, text=True, timeout=30
        )
        raw_strings = result.stdout.strip().split('\n')
    except Exception as e:
        print(f"WARNING: Failed to extract strings from .otbm: {e}")
        return texts
    
    # Filter for likely book/letter/scroll content
    skip_patterns = [
        r'^otservbr',  # Map metadata
        r'^Saved with',  # Editor info
        r'^No map description',
        r'^\s*$',
    ]
    
    for raw_text in raw_strings:
        raw_text = raw_text.strip()
        
        # Skip too short
        if len(raw_text) < 25:
            continue
        
        # Skip metadata/binary garbage
        skip = False
        for pattern in skip_patterns:
            if re.match(pattern, raw_text, re.IGNORECASE):
                skip = True
                break
        if skip:
            continue
        
        # Must contain at least 2 spaces (actual sentences)
        if raw_text.count(' ') < 2:
            continue
        
        # Skip if mostly non-printable
        printable = sum(1 for c in raw_text if c.isprintable())
        if printable / len(raw_text) < 0.9:
            continue
        
        # Skip already-extracted Lua texts (exact match)
        # These will be handled separately
        
        # Generate key
        slug = slugify(raw_text, max_words=5, max_len=50)
        if not slug or len(slug) < 3:
            slug = f"h_{text_hash(raw_text)}"
        
        key = f"book.otbm.{slug}"
        
        # Handle duplicate keys
        if key in texts:
            # Add hash suffix to make unique
            key = f"book.otbm.{slug}_{text_hash(raw_text)}"
        
        texts[key] = raw_text
    
    return texts

def add_hardcoded_cpp_texts():
    """Add hardcoded C++ texts that need translation."""
    return {
        "ui.readable.you_read_prefix": "You read: ",
        "ui.readable.nothing_written": "Nothing is written on it",
        "ui.readable.too_far_to_read": "You are too far away to read it",
        "ui.readable.wrote_on_date": " wrote on ",
        "ui.readable.wrote": " wrote",
        "ui.house.rent_warning_prefix": "Warning! \\nThe ",
        "ui.house.rent_warning_suffix": " rent of {amount} gold for your house \"{house}\" is payable. Have it within {days} days or you will lose this house.",
        "ui.house.rent_period_daily": "daily",
        "ui.house.rent_period_weekly": "weekly",
        "ui.house.rent_period_monthly": "monthly",
        "ui.house.rent_period_yearly": "annual",
    }

def main():
    print("=== Book/Letter/Scroll Text Extraction for i18n ===")
    print()
    
    # Phase 1: Extract Lua texts
    print("Phase 1: Extracting texts from Lua scripts...")
    lua_texts = extract_lua_texts()
    print(f"  Found {len(lua_texts)} texts from Lua scripts")
    for key in sorted(lua_texts.keys()):
        preview = lua_texts[key][:80].replace('\n', '\\n')
        print(f"  - {key}: {preview}...")
    print()
    
    # Phase 2: Extract .otbm texts
    print("Phase 2: Extracting texts from .otbm map file...")
    otbm_texts = extract_otbm_texts()
    print(f"  Found {len(otbm_texts)} texts from .otbm")
    print()
    
    # Phase 3: Add hardcoded C++ texts
    print("Phase 3: Adding hardcoded C++ texts...")
    cpp_texts = add_hardcoded_cpp_texts()
    print(f"  Found {len(cpp_texts)} hardcoded C++ texts")
    print()
    
    # Merge all texts
    all_texts = {}
    all_texts.update(cpp_texts)
    all_texts.update(lua_texts)
    all_texts.update(otbm_texts)
    
    print(f"=== TOTAL: {len(all_texts)} translation keys ===")
    print()
    
    # Sort keys
    sorted_texts = dict(sorted(all_texts.items()))
    
    # Write to i18n/en/books.json
    en_path = os.path.join(I18N_DIR, "en", "books.json")
    os.makedirs(os.path.dirname(en_path), exist_ok=True)
    
    with open(en_path, 'w', encoding='utf-8') as f:
        json.dump(sorted_texts, f, ensure_ascii=False, indent=2)
    
    print(f"Written {len(sorted_texts)} keys to {en_path}")
    
    # Also copy to all other language directories
    lang_dirs = [d for d in os.listdir(I18N_DIR) 
                 if os.path.isdir(os.path.join(I18N_DIR, d)) and d != "en"]
    
    copied = 0
    for lang in sorted(lang_dirs):
        lang_path = os.path.join(I18N_DIR, lang, "books.json")
        with open(lang_path, 'w', encoding='utf-8') as f:
            json.dump(sorted_texts, f, ensure_ascii=False, indent=2)
        copied += 1
    
    print(f"Copied books.json to {copied} language directories")
    
    # Print statistics
    print()
    print("=== Statistics ===")
    total_chars = sum(len(v) for v in all_texts.values())
    long_texts = sum(1 for v in all_texts.values() if len(v) > 200)
    very_long = sum(1 for v in all_texts.values() if len(v) > 500)
    print(f"  Total keys: {len(all_texts)}")
    print(f"  Total characters: {total_chars:,}")
    print(f"  Texts > 200 chars: {long_texts}")
    print(f"  Texts > 500 chars: {very_long}")
    print(f"  Lua texts: {len(lua_texts)}")
    print(f"  .otbm texts: {len(otbm_texts)}")
    print(f"  C++ texts: {len(cpp_texts)}")

if __name__ == "__main__":
    main()
