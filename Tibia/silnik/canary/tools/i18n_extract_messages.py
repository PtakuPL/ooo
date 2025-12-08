#!/usr/bin/env python3

"""
Extract literal NPC/system texts (Lua/C++) and emit a JSON scaffold that can be
remapped to translation keys.

Example:
    python tools/i18n_extract_messages.py \
        --roots data-otservbr-global scripts \
        --patterns sendTextMessage setMessage \
        --out build/i18n/messages.json
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Iterable, List, Dict

ROOT_DIR = Path(__file__).resolve().parents[1]

DEFAULT_ROOTS = [
	ROOT_DIR / "data-otservbr-global",
	ROOT_DIR / "src",
]

DEFAULT_PATTERNS = [
	r"sendTextMessage\s*\([^,]+,\s*\"([^\"]+)\"",
	r"sendTextMessage\s*\([^,]+,\s*'([^']+)'",
	r"setMessage\s*\([^,]+,\s*\"([^\"]+)\"",
]

def compile_patterns(raw_patterns: Iterable[str]) -> List[re.Pattern]:
	return [re.compile(pattern) for pattern in raw_patterns]


def make_key(path: Path, line_no: int, counter: int) -> str:
	stem = path.with_suffix("").as_posix()
	stem = stem.replace("../", "").replace("./", "")
	stem = re.sub(r"[^a-zA-Z0-9]+", ".", stem).strip(".")
	return f"{stem}.L{line_no}.{counter}"


def scan_file(path: Path, patterns: List[re.Pattern], counter_start: int = 0) -> List[Dict[str, str]]:
	results: List[Dict[str, str]] = []
	if not path.is_file():
		return results

	text = path.read_text(encoding="utf-8", errors="ignore")
	counter = counter_start
	for line_no, line in enumerate(text.splitlines(), start=1):
		for pattern in patterns:
			for match in pattern.finditer(line):
				message = match.group(1).strip()
				if not message:
					continue

				counter += 1
				results.append({
					"key": make_key(path.relative_to(ROOT_DIR), line_no, counter),
					"text": message,
					"file": str(path.relative_to(ROOT_DIR)),
					"line": line_no,
				})
	return results


def iter_source_files(root: Path, extensions: Iterable[str]) -> Iterable[Path]:
	for ext in extensions:
		yield from root.rglob(f"*{ext}")


def main():
	parser = argparse.ArgumentParser(description="Extract literal messages to bootstrap i18n keys.")
	parser.add_argument("--roots", nargs="+", type=Path, default=DEFAULT_ROOTS, help="Source roots to scan.")
	parser.add_argument("--extensions", nargs="+", default=[".lua", ".cpp", ".hpp"], help="File extensions to include.")
	parser.add_argument("--patterns", nargs="+", default=DEFAULT_PATTERNS, help="Regexes that capture the literal text (first capture group).")
	parser.add_argument("--out", type=Path, default=Path("build/i18n/messages.json"), help="Output JSON file.")
	args = parser.parse_args()

	patterns = compile_patterns(args.patterns)
	results: List[Dict[str, str]] = []

	for root in [Path(p).resolve() for p in args.roots]:
		if not root.is_dir():
			print(f"[warn] source root '{root}' not found, skipping.")
			continue

		for path in iter_source_files(root, args.extensions):
			results.extend(scan_file(path.resolve(), patterns, counter_start=len(results)))

	out_path = args.out
	out_path.parent.mkdir(parents=True, exist_ok=True)
	with out_path.open("w", encoding="utf-8") as handle:
		json.dump(results, handle, ensure_ascii=False, indent=2)

	print(f"[i18n] Extracted {len(results)} messages → {out_path}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
