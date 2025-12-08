#!/usr/bin/env python3
"""Export missing translations for a locale into CSV/JSON, with base references."""
from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path
from typing import Dict, List

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.append(str(SCRIPT_DIR))

try:
    from check_locale_coverage import load_needed, load_locale  # type: ignore
except ImportError as exc:  # pragma: no cover
    raise SystemExit(f"Nie można załadować check_locale_coverage.py: {exc}")


def export_missing_rows(
    needed: List[str],
    base: Dict[str, str],
    target: Dict[str, str],
) -> List[Dict[str, str]]:
    rows: List[Dict[str, str]] = []
    for key in needed:
        if key not in target:
            rows.append(
                {
                    "key": key,
                    "base_translation": base.get(key, ""),
                    "target_translation": target.get(key, ""),
                }
            )
    return rows


def write_csv(rows: List[Dict[str, str]], output: Path | None) -> None:
    stream = output.open("w", encoding="utf-8", newline="") if output else sys.stdout
    close_stream = output is not None
    writer = csv.writer(stream)
    writer.writerow(["key", "base_translation", "target_translation"])
    for row in rows:
        writer.writerow(
            [
                row["key"],
                row["base_translation"],
                row["target_translation"],
            ]
        )
    if close_stream:
        stream.close()


def write_json(rows: List[Dict[str, str]], output: Path | None) -> None:
    data = json.dumps(rows, ensure_ascii=False, indent=2)
    if output:
        output.write_text(data, encoding="utf-8")
    else:
        sys.stdout.write(data)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Eksportuje brakujące tłumaczenia dla wskazanego języka.",
    )
    parser.add_argument(
        "locale",
        type=Path,
        help="Plik docelowy, np. data/locales/de.lua",
    )
    parser.add_argument(
        "--needed",
        type=Path,
        default=Path("modules/client_locales/neededtranslations.lua"),
        help="Ścieżka do neededtranslations.lua",
    )
    parser.add_argument(
        "--base",
        type=Path,
        default=Path("data/locales/pl.lua"),
        help="Plik bazowy z kompletnym tłumaczeniem (domyślnie polski)",
    )
    parser.add_argument(
        "--format",
        choices=("csv", "json"),
        default="csv",
        help="Format wyjściowy (domyślnie CSV)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Plik wyjściowy; gdy brak – wynik trafia na stdout",
    )
    args = parser.parse_args()

    needed_keys = load_needed(args.needed)
    base_trans = load_locale(args.base)
    target_trans = load_locale(args.locale)
    rows = export_missing_rows(needed_keys, base_trans, target_trans)

    if args.format == "json":
        write_json(rows, args.output)
    else:
        write_csv(rows, args.output)


if __name__ == "__main__":
    main()
