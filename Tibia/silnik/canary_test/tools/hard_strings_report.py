#!/usr/bin/env python3
"""
Szybki raport hard-strings w plikach Lua.
Zbiera literale tekstowe (">=10 znaków") spoza i18n i zapisuje CSV + MD.

Użycie:
  python tools/hard_strings_report.py \
    --roots data-otservbr-global/npc data-otservbr-global/scripts data/scripts \
    --out-csv docs/i18n/generated/hard_strings.csv \
    --out-md docs/i18n/generated/hard_strings.md
"""
import argparse
import csv
import os
import re
from pathlib import Path
from typing import Iterable, List, Tuple


STRING_RE = re.compile(r'"([^"]{10,})"')
SKIP_PATTERNS = [
    "i18nKey",
    "NPC_LIB.i18n",
    "sendLocalizedTextMessage",
    "localized",
    "translation_memory",
]


def scan_file(path: Path) -> List[Tuple[int, str]]:
    results = []
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return results
    for lineno, line in enumerate(text.splitlines(), 1):
        if any(pat in line for pat in SKIP_PATTERNS):
            continue
        for match in STRING_RE.finditer(line):
            literal = match.group(1).strip()
            if len(literal) < 10:
                continue
            # Pomiń typowe komendy, adresy i wzorce techniczne
            if re.search(r"\bhttp[s]?://", literal):
                continue
            results.append((lineno, literal))
    return results


def iter_lua_files(roots: Iterable[str]) -> Iterable[Path]:
    for root in roots:
        root_path = Path(root)
        if not root_path.exists():
            continue
        for path in root_path.rglob("*.lua"):
            yield path


def write_csv(rows: List[Tuple[str, int, str]], out_csv: Path) -> None:
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["file", "line", "text"])
        writer.writerows(rows)


def write_md(rows: List[Tuple[str, int, str]], out_md: Path) -> None:
    out_md.parent.mkdir(parents=True, exist_ok=True)
    with out_md.open("w", encoding="utf-8") as f:
        f.write("# Hard strings report\n\n")
        f.write(f"Liczba trafień: {len(rows)}\n\n")
        f.write("| Plik | Linia | Tekst |\n|------|-------|-------|\n")
        for file, line, text in rows[:500]:  # ogranicz do 500 w tabeli
            safe = text.replace("|", "\\|")
            f.write(f"| `{file}` | {line} | {safe} |\n")
        if len(rows) > 500:
            f.write(f"\n_(Ucięto do 500 z {len(rows)} wyników)_\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Raport hard-strings dla plików Lua")
    parser.add_argument("--roots", nargs="+", required=True, help="Katalogi do skanowania")
    parser.add_argument("--out-csv", required=True, help="Ścieżka CSV")
    parser.add_argument("--out-md", required=True, help="Ścieżka Markdown")
    args = parser.parse_args()

    rows: List[Tuple[str, int, str]] = []
    for path in iter_lua_files(args.roots):
        hits = scan_file(path)
        for lineno, literal in hits:
            rel = os.path.relpath(path, Path.cwd())
            rows.append((rel, lineno, literal))

    rows.sort()
    write_csv(rows, Path(args.out_csv))
    write_md(rows, Path(args.out_md))
    print(f"Zapisano {len(rows)} wpisów do {args.out_csv} i {args.out_md}")


if __name__ == "__main__":
    main()
