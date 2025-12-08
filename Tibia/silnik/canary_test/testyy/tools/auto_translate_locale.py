#!/usr/bin/env python3
"""Utility to auto-translate missing locale keys via googletrans."""
from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from typing import Dict, List, Sequence, Tuple

from deep_translator import GoogleTranslator

from check_locale_coverage import load_locale, load_needed


def escape_lua(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")
        .replace("\t", "\\t")
        .replace("\r", "\\r")
    )


def protect_text(text: str) -> Tuple[str, Dict[str, str]]:
    replacements: Dict[str, str] = {}
    protected = []
    i = 0
    token_id = 0
    while i < len(text):
        char = text[i]
        if char == "%":
            j = i + 1
            while j < len(text) and text[j] in "0123456789$":
                j += 1
            if j < len(text):
                spec = text[j]
                if spec in "sdifuxXcp%":
                    placeholder = text[i : j + 1]
                    token = f"__PH{token_id}__"
                    replacements[token] = placeholder
                    protected.append(token)
                    i = j + 1
                    token_id += 1
                    continue
        if char == "\\" and i + 1 < len(text):
            protected.append(char)
            protected.append(text[i + 1])
            i += 2
            continue
        if char == "\n":
            token = f"__NL{token_id}__"
            replacements[token] = "\n"
            protected.append(token)
            token_id += 1
            i += 1
            continue
        protected.append(char)
        i += 1
    return "".join(protected), replacements


def restore_text(text: str, replacements: Dict[str, str]) -> str:
    for token, original in replacements.items():
        text = text.replace(token, original)
    return text


def translate_batch(translator: GoogleTranslator, entries: Sequence[str], retries: int = 3) -> List[str]:
    for attempt in range(1, retries + 1):
        try:
            translated = translator.translate_batch(list(entries))
            if translated is None:
                return list(entries)
            if len(translated) != len(entries):
                raise ValueError("Mismatched translation batch length.")
            return [orig if result is None else result for orig, result in zip(entries, translated)]
        except Exception:
            if attempt == retries:
                raise
            time.sleep(1.5 * attempt)
    raise RuntimeError("unreachable")


def main() -> None:
    parser = argparse.ArgumentParser(description="Auto translate missing locale keys")
    parser.add_argument("--needed", type=Path, default=Path("modules/client_locales/neededtranslations.lua"))
    parser.add_argument("--locale", type=Path, required=True)
    parser.add_argument("--dest-lang", default="ru")
    parser.add_argument("--src-lang", default="en")
    parser.add_argument("--batch-size", type=int, default=40)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    needed = load_needed(args.needed)
    translations = load_locale(args.locale)

    missing = [key for key in needed if key not in translations]
    if not missing:
        print("No missing keys detected. Nothing to do.")
        return

    print(f"Translating {len(missing)} keys into '{args.dest_lang}'...")
    translator = GoogleTranslator(source=args.src_lang, target=args.dest_lang)

    new_entries: Dict[str, str] = {}
    batch_size = max(1, args.batch_size)
    for start in range(0, len(missing), batch_size):
        chunk = missing[start : start + batch_size]
        prepared: List[str] = []
        metadata: List[Dict[str, str]] = []
        for key in chunk:
            protected, repl = protect_text(key)
            prepared.append(protected)
            metadata.append(repl)
        translations_chunk = translate_batch(translator, prepared)
        for key, translated, repl in zip(chunk, translations_chunk, metadata):
            restored = restore_text(translated, repl)
            new_entries[key] = restored
        progress = start + len(chunk)
        print(f"  -> {progress}/{len(missing)} done")

    if args.dry_run:
        for key, value in new_entries.items():
            print(f"{key} => {value}")
        return

    text = args.locale.read_text(encoding="utf-8")
    insert_pos = text.rfind("  }\n}")
    if insert_pos == -1:
        raise RuntimeError("Unable to find end of translation table.")

    lines = ["\n    -- Auto-generated translations\n"]
    for key in missing:
        value = new_entries[key]
        line = f'    ["{escape_lua(key)}"] = "{escape_lua(value)}",\n'
        lines.append(line)
    lines.append("\n")
    updated = text[:insert_pos] + "".join(lines) + text[insert_pos:]
    args.locale.write_text(updated, encoding="utf-8")
    print(f"Inserted {len(missing)} translations into {args.locale}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
