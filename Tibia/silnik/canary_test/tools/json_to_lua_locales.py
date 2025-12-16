#!/usr/bin/env python3
"""
JSON to Lua Locales Converter for OTClient

Converts server-side i18n JSON files to client-side Lua locale format.

Usage:
    python3 json_to_lua_locales.py --input i18n/pl/npc.json --output testyy/data/locales/game_i18n_pl.lua
    python3 json_to_lua_locales.py --all --server-dir i18n --client-dir testyy/data/locales
"""

import json
import os
import sys
import argparse
from pathlib import Path

try:
    # Optional: compact-key export for client-side i18n bandwidth optimization
    from i18n_keymap import ensure_mapping_for_keys, load_keymap_files, save_keymap_files
except Exception:
    ensure_mapping_for_keys = None
    load_keymap_files = None
    save_keymap_files = None

def discover_languages(server_dir: str):
    """Discover available language directories under server_dir.

    We intentionally avoid a hardcoded list because this repo supports many languages.
    """
    base = Path(server_dir)
    if not base.is_dir():
        return []

    langs = []
    for child in base.iterdir():
        if not child.is_dir():
            continue
        name = child.name
        # Accept common patterns: en, pl, zh_TW, etc.
        if len(name) < 2:
            continue
        # Must contain at least one JSON file to be considered a locale directory.
        if any(p.suffix == ".json" for p in child.iterdir() if p.is_file()):
            langs.append(name)
    return sorted(langs)


def iter_lang_json_files(lang_dir: Path):
    """Yield JSON translation files for a given lang directory, skipping backups/corrupted files."""
    for p in sorted(lang_dir.glob("*.json")):
        name = p.name
        if ".bak" in name or ".corrupted" in name:
            continue
        yield p

def escape_lua_string(s):
    """Escape special characters for Lua string literals"""
    if s is None:
        return ""
    s = str(s)
    s = s.replace('\\', '\\\\')
    s = s.replace('"', '\\"')
    s = s.replace('\n', '\\n')
    s = s.replace('\r', '\\r')
    s = s.replace('\t', '\\t')
    return s

def json_to_lua(input_file, output_file=None):
    """Convert a single JSON file to Lua format"""
    
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    lines = []
    lines.append(f"-- Generated from: {os.path.basename(input_file)}")
    lines.append(f"-- Keys: {len(data)}")
    lines.append("")
    lines.append("local translations = {")
    
    for key in sorted(data.keys()):
        value = escape_lua_string(data[key])
        lines.append(f'  ["{key}"] = "{value}",')
    
    lines.append("}")
    lines.append("")
    lines.append("return translations")
    
    result = '\n'.join(lines)
    
    if output_file:
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(result)
        print(f"✓ Generated: {output_file} ({len(data)} translations)")
    
    return result, len(data)

def generate_game_i18n(lang, server_i18n_dir, client_locales_dir, *, compact_keys=False, i18n_dir="i18n"):
    """Generate comprehensive game_i18n_{lang}.lua from all server i18n files.

    If compact_keys=True, keys are remapped using i18n/keymap.json (semantic->compact).
    This is intended for client-side translation keyed by short IDs.
    """
    
    all_translations = {}
    stats = {}
    
    lang_dir = Path(server_i18n_dir) / lang
    if not lang_dir.is_dir():
        print(f"  No translations found for {lang}")
        return 0

    # Collect translations from all JSON files in the language directory.
    for json_path in iter_lang_json_files(lang_dir):
        category = json_path.stem
        try:
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                if not isinstance(data, dict):
                    print(f"    [{category}] WARN: expected object/dict, got {type(data)}")
                    continue
                all_translations.update(data)
                stats[category] = len(data)
                print(f"    [{category}] {len(data)} keys")
        except json.JSONDecodeError as e:
            print(f"    [{category}] ERROR: {e}")
    
    if not all_translations:
        print(f"  No translations found for {lang}")
        return 0
    
    if compact_keys:
        if ensure_mapping_for_keys is None:
            raise RuntimeError("Compact keys requested but tools/i18n_keymap.py is not available")

        i18n_dir_path = Path(i18n_dir)
        meta, keymap = load_keymap_files(i18n_dir_path)
        # Ensure mapping exists at least for EN keys; for other langs we still map by semantic keys.
        meta, keymap, created = ensure_mapping_for_keys(all_translations.keys(), i18n_dir_path, meta=meta, keymap=keymap)
        if created:
            save_keymap_files(i18n_dir_path, meta, keymap)

        remapped = {}
        collisions = 0
        for semantic_key, value in all_translations.items():
            compact_key = keymap.get(semantic_key)
            if not compact_key:
                # Should not happen due to ensure_mapping_for_keys, but keep safe.
                continue
            if compact_key in remapped and remapped[compact_key] != value:
                collisions += 1
                continue
            remapped[compact_key] = value

        if collisions:
            print(f"  [WARN] Compact export dropped {collisions} collisions")
        all_translations = remapped

    # Generate Lua file
    output_suffix = "_compact" if compact_keys else ""
    output_file = os.path.join(client_locales_dir, f'game_i18n_{lang}{output_suffix}.lua')
    
    lines = []
    lines.append("-- ============================================")
    lines.append(f"-- GAME I18N TRANSLATIONS - {lang.upper()}")
    lines.append("-- ============================================")
    lines.append("-- Auto-generated by json_to_lua_locales.py")
    lines.append(f"-- Total translations: {len(all_translations)}")
    lines.append("--")
    for cat, count in stats.items():
        lines.append(f"--   {cat}: {count}")
    lines.append("-- ============================================")
    lines.append("")
    lines.append("local gameTranslations = {")
    
    # Group by category prefix (semantic keys only). For compact keys, skip grouping.
    current_prefix = ""
    for key in sorted(all_translations.keys()):
        if not compact_keys:
            prefix = key.split('.')[0] if '.' in key else "other"
            
            if prefix != current_prefix:
                if current_prefix:
                    lines.append("")
                lines.append(f"  -- {prefix.upper()}")
                current_prefix = prefix
        
        value = escape_lua_string(all_translations[key])
        lines.append(f'  ["{key}"] = "{value}",')
    
    lines.append("}")
    lines.append("")
    lines.append("-- Merge with existing locale translations")
    lines.append("if locale and locale.translation then")
    lines.append("  for key, value in pairs(gameTranslations) do")
    lines.append("    locale.translation[key] = value")
    lines.append("  end")
    lines.append("else")
    lines.append(f"  -- Store for later if locale not yet loaded")
    lines.append(f"  _G.gameTranslations_{lang} = gameTranslations")
    lines.append("end")
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"  ✓ Generated: {output_file}")
    return len(all_translations)

def process_all_languages(server_dir, client_dir):
    """Process all languages and generate client locale files"""
    
    total_stats = {}
    
    langs = discover_languages(server_dir)
    for lang in langs:
        print(f"\n[{lang.upper()}]")
        count = generate_game_i18n(lang, server_dir, client_dir)
        total_stats[lang] = count
    
    print("\n" + "=" * 50)
    print("SUMMARY")
    print("=" * 50)
    for lang, count in total_stats.items():
        print(f"  {lang}: {count} translations")
    print(f"  TOTAL: {sum(total_stats.values())} translations")

def main():
    parser = argparse.ArgumentParser(
        description='Convert server i18n JSON files to client Lua locales'
    )
    parser.add_argument('--input', '-i', help='Input JSON file')
    parser.add_argument('--output', '-o', help='Output Lua file')
    parser.add_argument('--all', '-a', action='store_true', 
                        help='Process all languages')
    parser.add_argument('--server-dir', default='i18n',
                        help='Server i18n directory (default: i18n)')
    parser.add_argument('--client-dir', default='testyy/data/locales',
                        help='Client locales directory')
    parser.add_argument('--compact-keys', action='store_true',
                        help='Export client locales using compact keys from i18n/keymap.json')
    parser.add_argument('--i18n-dir', default='i18n',
                        help='Base i18n dir for keymap files (default: i18n)')
    
    args = parser.parse_args()
    
    if args.all:
        if args.compact_keys:
            total_stats = {}
            langs = discover_languages(args.server_dir)
            for lang in langs:
                print(f"\n[{lang.upper()} - COMPACT]")
                count = generate_game_i18n(
                    lang,
                    args.server_dir,
                    args.client_dir,
                    compact_keys=True,
                    i18n_dir=args.i18n_dir,
                )
                total_stats[lang] = count
            print("\n" + "=" * 50)
            print("SUMMARY (COMPACT)")
            print("=" * 50)
            for lang, count in total_stats.items():
                print(f"  {lang}: {count} translations")
            print(f"  TOTAL: {sum(total_stats.values())} translations")
        else:
            process_all_languages(args.server_dir, args.client_dir)
    elif args.input:
        output = args.output or args.input.replace('.json', '.lua')
        json_to_lua(args.input, output)
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
