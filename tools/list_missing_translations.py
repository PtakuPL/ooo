#!/usr/bin/env python3
"""
Utility script to list missing locale strings compared to neededtranslations.lua.

Examples:
    python tools/list_missing_translations.py pl
    python tools/list_missing_translations.py ro --stub --output ro_missing.lua
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
import re


RE_NEEDED = re.compile(r"""['"]((?:\\.|[^'"\\])*)['"]""")
RE_TRANSLATION = re.compile(r"""\["((?:\\.|[^"\\])*)"\]\s*=\s*"((?:\\.|[^"\\])*)",""", re.DOTALL)


def lua_unescape(value: str) -> str:
    try:
        return bytes(value, "utf-8").decode("unicode_escape")
    except Exception:
        return value.replace(r"\"", '"').replace(r"\'", "'").replace("\\n", "\n").replace("\\t", "\t")


def lua_escape(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace('"', r"\"")
        .replace("\t", r"\t")
        .replace("\n", r"\n")
    )


def load_needed(root: Path) -> list[str]:
    text = (root / "modules/client_locales/neededtranslations.lua").read_text(encoding="utf-8")
    result = []
    seen = set()
    for match in RE_NEEDED.finditer(text):
        value = lua_unescape(match.group(1))
        if not value or value in seen or value.startswith("--"):
            continue
        seen.add(value)
        result.append(value)
    return result


def load_locale(locale_path: Path) -> dict[str, str]:
    text = locale_path.read_text(encoding="utf-8")
    translations = {}
    for match in RE_TRANSLATION.finditer(text):
        key = lua_unescape(match.group(1))
        value = lua_unescape(match.group(2))
        translations[key] = value
    return translations


def main() -> int:
    parser = argparse.ArgumentParser(description="List missing translations for a locale.")
    parser.add_argument("locale", help="Locale code (e.g. pl, ro) or path to .lua file.")
    parser.add_argument("--root", default="Tibia/silnik/canary_test/testyy", help="Project root relative to script (default: %(default)s).")
    parser.add_argument("--stub", action="store_true", help="Output results as Lua stubs [\"key\"] = false,")
    parser.add_argument("--output", "-o", type=Path, help="Write output to file instead of stdout.")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    needed = load_needed(root)

    locale_path = Path(args.locale)
    if not locale_path.suffix:
        locale_path = root / f"data/locales/{args.locale}.lua"
    if not locale_path.exists():
        parser.error(f"Locale file not found: {locale_path}")

    translations = load_locale(locale_path)
    missing = [key for key in needed if key not in translations]

    lines = []
    if args.stub:
        for key in missing:
            lines.append(f'  ["{lua_escape(key)}"] = false,')
    else:
        lines.extend(missing)

    destination = args.output
    if destination:
        destination.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")

    print(f"{locale_path.name}: {len(missing)} missing entries")
    if not destination:
        for entry in lines:
            print(entry)
    elif lines:
        print(f"Wrote {len(lines)} entries to {destination}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
