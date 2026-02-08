#!/usr/bin/env python3

"""
Export quest log names/descriptions/states from quests.lua into JSON translation packs.

Usage examples:
  python tools/export_questlog_translations.py --locale en
  python tools/export_questlog_translations.py --locale en --locale pl --i18n-root ./i18n --no-backfill
"""

from __future__ import annotations

import argparse
import json
import re
import string
from dataclasses import dataclass
from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_QUESTS_FILE = PROJECT_ROOT / "data-otservbr-global" / "lib" / "core" / "quests.lua"
DEFAULT_I18N = PROJECT_ROOT / "i18n"

QUEST_ENTRY_RE = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{\s*$")
MISSION_ENTRY_RE = QUEST_ENTRY_RE
STRING_FIELD_RE = re.compile(r"^\s*(name|description)\s*=\s*([\"'])")
STATE_RE = re.compile(r"^\s*\[(\d+)\]\s*=\s*([\"'])")
DYNAMIC_DESCRIPTION_RE = re.compile(r"^\s*description\s*=\s*function\s*\(")
DYNAMIC_FORMAT_CALL_RE = re.compile(r"string\.format\s*\(\s*([\"'])(?P<txt>(?:\\.|(?!\1).)*?)\1", re.DOTALL)
DYNAMIC_COLON_FORMAT_RE = re.compile(r"\(\s*([\"'])(?P<txt>(?:\\.|(?!\1).)*?)\1\s*\)\s*:format\s*\(", re.DOTALL)


@dataclass
class ExtractStats:
	quests: int = 0
	mission_names: int = 0
	descriptions: int = 0
	dynamic_descriptions: int = 0
	states: int = 0

	@property
	def total(self) -> int:
		return self.quests + self.mission_names + self.descriptions + self.dynamic_descriptions + self.states


def count_leading_tabs(line: str) -> int:
	count = 0
	for ch in line:
		if ch == "\t":
			count += 1
		elif ch == " ":
			continue
		else:
			break
	return count


def parse_quoted_string(lines: list[str], start_line: int, start_col: int, quote: str) -> tuple[str, int]:
	"""Parse Lua string content (without delimiters) starting at lines[start_line][start_col]."""
	if lines[start_line][start_col] != quote:
		raise ValueError("parse_quoted_string called with invalid start position")

	chunks: list[str] = []
	line_idx = start_line
	col = start_col + 1

	while line_idx < len(lines):
		line = lines[line_idx]
		while col < len(line):
			ch = line[col]
			if ch == "\\":
				if col + 1 < len(line):
					chunks.append(ch)
					chunks.append(line[col + 1])
					col += 2
					continue
				# Trailing backslash at end-of-line (invalid in Lua, but keep stable)
				chunks.append(ch)
				col += 1
				continue

			if ch == quote:
				return "".join(chunks), line_idx

			chunks.append(ch)
			col += 1

		line_idx += 1
		col = 0
		if line_idx < len(lines):
			chunks.append("\n")

	raise ValueError(f"Unterminated Lua string starting at line {start_line + 1}")


def decode_lua_string(raw: str) -> str:
	"""Decode the subset of Lua escapes used in quest strings."""
	out: list[str] = []
	i = 0
	length = len(raw)
	hexdigits = set(string.hexdigits)

	simple_escapes = {
		"a": "\a",
		"b": "\b",
		"f": "\f",
		"n": "\n",
		"r": "\r",
		"t": "\t",
		"v": "\v",
		"\\": "\\",
		'"': '"',
		"'": "'",
	}

	while i < length:
		ch = raw[i]
		if ch != "\\":
			out.append(ch)
			i += 1
			continue

		if i + 1 >= length:
			out.append("\\")
			break

		next_ch = raw[i + 1]
		if next_ch in simple_escapes:
			out.append(simple_escapes[next_ch])
			i += 2
			continue

		if next_ch == "z":
			# \z removes all following whitespace (incl. newlines/tabs/spaces)
			i += 2
			while i < length and raw[i].isspace():
				i += 1
			continue

		if next_ch.isdigit():
			j = i + 1
			digits: list[str] = []
			while j < length and len(digits) < 3 and raw[j].isdigit():
				digits.append(raw[j])
				j += 1
			if digits:
				out.append(chr(int("".join(digits)) % 256))
				i = j
				continue

		if next_ch in {"x", "X"} and i + 3 < length:
			hex_part = raw[i + 2 : i + 4]
			if all(c in hexdigits for c in hex_part):
				out.append(chr(int(hex_part, 16)))
				i += 4
				continue

		# Fallback: keep escaped char as-is (without backslash)
		out.append(next_ch)
		i += 2

	return "".join(out)


def extract_dynamic_template(lines: list[str], start_idx: int) -> tuple[str | None, int]:
	"""
	Extract first string.format template from a dynamic mission description function.
	Returns (template_or_none, end_line_idx_of_function).
	"""
	idx = start_idx + 1
	while idx < len(lines):
		stripped = lines[idx].strip()
		tabs = count_leading_tabs(lines[idx])
		if tabs == 5 and stripped == "end,":
			block = "\n".join(lines[start_idx : idx + 1])
			match = DYNAMIC_FORMAT_CALL_RE.search(block) or DYNAMIC_COLON_FORMAT_RE.search(block)
			if not match:
				return None, idx
			return decode_lua_string(match.group("txt")), idx

		idx += 1

	return None, len(lines) - 1


def extract_questlog_strings(quests_file: Path) -> tuple[dict[str, str], ExtractStats]:
	lines = quests_file.read_text(encoding="utf-8").splitlines()
	result: dict[str, str] = {}
	stats = ExtractStats()

	quest_id: int | None = None
	mission_id: int | None = None
	in_missions = False
	in_states = False

	idx = 0
	while idx < len(lines):
		line = lines[idx]
		stripped = line.strip()
		tabs = count_leading_tabs(line)

		if in_states and tabs == 5 and stripped == "},":
			in_states = False
			idx += 1
			continue

		if in_states:
			match_state = STATE_RE.match(line)
			if match_state and quest_id is not None and mission_id is not None:
				state_id = int(match_state.group(1))
				quote = match_state.group(2)
				start_col = line.find(quote)
				raw_text, idx = parse_quoted_string(lines, idx, start_col, quote)
				decoded = decode_lua_string(raw_text)
				key = f"questlog.quest_{quest_id}.mission_{mission_id}.state_{state_id}"
				result[key] = decoded
				stats.states += 1
				idx += 1
				continue

		if mission_id is not None:
			if tabs == 5 and stripped == "states = {":
				in_states = True
				idx += 1
				continue

			if tabs == 4 and stripped == "},":
				mission_id = None
				idx += 1
				continue

			match_field = STRING_FIELD_RE.match(line)
			if match_field and quest_id is not None:
				field_name = match_field.group(1)
				quote = match_field.group(2)
				start_col = line.find(quote)
				raw_text, idx = parse_quoted_string(lines, idx, start_col, quote)
				decoded = decode_lua_string(raw_text)
				if field_name == "name":
					key = f"questlog.quest_{quest_id}.mission_{mission_id}.name"
					stats.mission_names += 1
				else:
					key = f"questlog.quest_{quest_id}.mission_{mission_id}.description"
					stats.descriptions += 1
				result[key] = decoded
				idx += 1
				continue

			if DYNAMIC_DESCRIPTION_RE.match(line) and quest_id is not None:
				template, function_end_idx = extract_dynamic_template(lines, idx)
				if template:
					key = f"questlog.quest_{quest_id}.mission_{mission_id}.description_dynamic"
					result[key] = template
					stats.dynamic_descriptions += 1
				idx = function_end_idx + 1
				continue

		if in_missions and mission_id is None:
			if tabs == 3 and stripped == "},":
				in_missions = False
				idx += 1
				continue

			match_mission = MISSION_ENTRY_RE.match(stripped)
			if match_mission and tabs == 4:
				mission_id = int(match_mission.group(1))
				idx += 1
				continue

		if quest_id is not None and not in_missions:
			if tabs == 3 and stripped == "missions = {":
				in_missions = True
				idx += 1
				continue

			if tabs == 2 and stripped == "},":
				quest_id = None
				idx += 1
				continue

			match_name = STRING_FIELD_RE.match(line)
			if match_name and match_name.group(1) == "name":
				quote = match_name.group(2)
				start_col = line.find(quote)
				raw_text, idx = parse_quoted_string(lines, idx, start_col, quote)
				decoded = decode_lua_string(raw_text)
				key = f"questlog.quest_{quest_id}.name"
				result[key] = decoded
				stats.quests += 1
				idx += 1
				continue

		if quest_id is None:
			match_quest = QUEST_ENTRY_RE.match(stripped)
			if match_quest and tabs == 2:
				quest_id = int(match_quest.group(1))
				idx += 1
				continue

		idx += 1

	result["questlog.common.mission_completed_format"] = "%s (completed)"
	return dict(sorted(result.items())), stats


def load_existing(path: Path) -> dict[str, str]:
	if not path.is_file():
		return {}
	with path.open(encoding="utf-8") as handle:
		return json.load(handle)


def write_locale(locale: str, values: dict[str, str], i18n_root: Path, backfill: bool) -> None:
	target_dir = i18n_root / locale
	target_dir.mkdir(parents=True, exist_ok=True)
	target_file = target_dir / "questlog.json"

	existing = load_existing(target_file)
	merged: dict[str, str] = {}

	for key, english_value in values.items():
		if locale == "en":
			if english_value:
				merged[key] = english_value
			else:
				merged[key] = existing.get(key, "")
			continue

		if key in existing and str(existing[key]).strip():
			merged[key] = existing[key]
		elif backfill:
			merged[key] = english_value
		else:
			merged[key] = ""

	for stale_key in set(existing.keys()) - set(values.keys()):
		merged.pop(stale_key, None)

	with target_file.open("w", encoding="utf-8") as handle:
		json.dump(dict(sorted(merged.items())), handle, ensure_ascii=False, indent=2)
		handle.write("\n")

	print(f"[i18n] Wrote {len(merged):,} entries to {target_file}")


def main(argv: list[str]) -> int:
	parser = argparse.ArgumentParser(description="Generate questlog translation packs")
	parser.add_argument("--quests-file", type=Path, default=DEFAULT_QUESTS_FILE, help="Path to quests.lua (default: %(default)s)")
	parser.add_argument("--locale", action="append", default=["en"], help="Locale to (re)generate. Pass multiple --locale flags for more than one language.")
	parser.add_argument("--i18n-root", type=Path, default=DEFAULT_I18N, help="Root directory where locale folders live (default: %(default)s)")
	parser.add_argument("--no-backfill", action="store_true", help="Do not prefill missing translations with English text.")
	args = parser.parse_args(argv)

	if not args.quests_file.is_file():
		raise FileNotFoundError(f"quests.lua not found: {args.quests_file}")

	quest_values, stats = extract_questlog_strings(args.quests_file)
	print(
		"[i18n] Parsed "
		f"{stats.total:,} questlog keys "
		f"(quests: {stats.quests}, mission names: {stats.mission_names}, descriptions: {stats.descriptions}, dynamic: {stats.dynamic_descriptions}, states: {stats.states})"
	)

	# argparse append + default duplicates "en" when passed explicitly; de-duplicate preserving order
	locales: list[str] = []
	for locale in args.locale:
		if locale not in locales:
			locales.append(locale)

	for locale in locales:
		write_locale(locale, quest_values, args.i18n_root, backfill=not args.no_backfill)

	return 0


if __name__ == "__main__":
	raise SystemExit(main(sys.argv[1:]))
