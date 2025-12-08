#!/usr/bin/env python3
"""
Utility script that compares locale files against neededtranslations.lua
and reports missing or extra keys.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Dict, Iterable, List, Set


def _unescape(value: str) -> str:
    """Decode a Lua-style string literal fragment."""
    out: List[str] = []
    i = 0
    length = len(value)
    while i < length:
        char = value[i]
        if char == "\\" and i + 1 < length:
            nxt = value[i + 1]
            if nxt == "n":
                out.append("\n")
                i += 2
                continue
            if nxt == "t":
                out.append("\t")
                i += 2
                continue
            if nxt == "r":
                out.append("\r")
                i += 2
                continue
            if nxt in ('\\', '"', "'"):
                out.append(nxt)
                i += 2
                continue
        out.append(char)
        i += 1
    return "".join(out)


def load_needed(path: Path) -> List[str]:
    """Read neededtranslations.lua and return the ordered list of keys."""
    text = path.read_text(encoding="utf-8")
    strings: List[str] = []
    i = 0
    length = len(text)
    while i < length:
        char = text[i]
        if char == "-" and i + 1 < length and text[i + 1] == "-":
            while i < length and text[i] != "\n":
                i += 1
            continue
        if char in ("'", '"'):
            quote = char
            i += 1
            start = i
            buf: List[str] = []
            while i < length:
                c = text[i]
                if c == "\\" and i + 1 < length:
                    buf.append(c)
                    buf.append(text[i + 1])
                    i += 2
                    continue
                if c == quote:
                    literal = "".join(buf)
                    strings.append(_unescape(literal))
                    i += 1
                    break
                buf.append(c)
                i += 1
            continue
        i += 1
    return strings


def load_locale(path: Path) -> Dict[str, str]:
    """Parse a locale Lua file and return the translation dictionary."""
    text = path.read_text(encoding="utf-8")
    pattern = re.compile(
        r'\["((?:\\.|[^"])*)"]\s*=\s*"((?:\\.|[^"])*)"', re.MULTILINE)
    translations: Dict[str, str] = {}
    for match in pattern.finditer(text):
        key = _unescape(match.group(1))
        value = _unescape(match.group(2))
        translations[key] = value
    return translations


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Check locale completeness against needed translations.")
    parser.add_argument(
        "--needed",
        default="modules/client_locales/neededtranslations.lua",
        type=Path,
        help="Path to neededtranslations.lua (default: %(default)s)",
    )
    parser.add_argument(
        "locale",
        type=Path,
        help="Path to the locale file to verify (e.g., data/locales/pl.lua)",
    )
    parser.add_argument(
        "--show-extra",
        action="store_true",
        help="List translations that exist in the locale but not in neededtranslations.",
    )
    args = parser.parse_args()

    needed = load_needed(args.needed)
    translations = load_locale(args.locale)

    needed_set: Set[str] = set(needed)
    translation_keys: Set[str] = set(translations)

    missing = [key for key in needed if key not in translation_keys]
    extra = sorted(translation_keys - needed_set)

    locale_name = args.locale.name
    print(f"Locale: {locale_name}")
    print(f"Total required strings : {len(needed)}")
    print(f"Available translations : {len(translations)}")
    print(f"Missing translations   : {len(missing)}")

    if missing:
        print("\nMissing keys:")
        for key in missing:
            print(f"- {key}")

    if args.show_extra and extra:
        print("\nExtra keys (not defined in neededtranslations.lua):")
        for key in extra:
            print(f"- {key}")


if __name__ == "__main__":
    main()
