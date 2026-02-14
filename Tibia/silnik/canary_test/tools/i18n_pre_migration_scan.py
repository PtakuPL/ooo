#!/usr/bin/env python3
"""
PRE_MIGRATION scanner for runtime-visible strings that are still not localized.

Outputs:
  - i18n/status/pre_migration_todo/<category>.json
  - i18n/status/pre_migration_todo/<category>.md
  - i18n/status/pre_migration_todo/<category>.csv
  - i18n/status/pre_migration_todo/pre_migration_todo_latest.json
  - i18n/status/pre_migration_todo/pre_migration_todo_history.jsonl
  - i18n/status/pre_migration_todo/pre_migration_todo.csv
  - i18n/status/pre_migration_scan.json
"""

from __future__ import annotations

import argparse
import csv
import html
import json
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Pattern, Sequence, Tuple


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def compile_rx(pattern: str, flags: int = 0) -> Pattern[str]:
    return re.compile(pattern, flags)


@dataclass(frozen=True)
class PatternDef:
    name: str
    regex: Pattern[str]


@dataclass(frozen=True)
class CategoryDef:
    name: str
    roots: Tuple[str, ...]
    extensions: Tuple[str, ...]
    patterns: Tuple[PatternDef, ...]
    recursive: bool = True
    skip_tokens: Tuple[str, ...] = ()


LOCALIZED_SKIP_TOKENS: Tuple[str, ...] = (
    "i18nKey",
    "NPC_LIB.i18n",
    "sendLocalizedTextMessage",
    "sayLocalized",
    "broadcastLocalized",
    "i18n.get",
    "i18n:",
    "tr(",
)


BASE_RUNTIME_PATTERNS_LUA: Tuple[PatternDef, ...] = (
    PatternDef("sendTextMessage", compile_rx(r"sendTextMessage\s*\([^\"\n]*\"([^\"]{3,})\"")),
    PatternDef("method:say", compile_rx(r"[A-Za-z0-9_]+:say\s*\(\s*\"([^\"]{3,})\"")),
    PatternDef("broadcastMessage", compile_rx(r"broadcastMessage\s*\(\s*\"([^\"]{3,})\"")),
    PatternDef("Game.broadcastMessage", compile_rx(r"Game\.broadcastMessage\s*\(\s*\"([^\"]{3,})\"")),
)


NPC_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("npcHandler:say", compile_rx(r"npcHandler:say\s*\(\s*\"([^\"]{3,})\"")),
    PatternDef("NpcHandler:say", compile_rx(r"NpcHandler:say\s*\(\s*\"([^\"]{3,})\"")),
    PatternDef("StdModule.say.text", compile_rx(r"StdModule\.(?:say|promotePlayer).{0,180}text\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("keyword.text", compile_rx(r"add(?:Greet|Farewell)Keyword.{0,180}text\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("voices.text", compile_rx(r"text\s*=\s*\"([^\"]{3,})\"")),
) + BASE_RUNTIME_PATTERNS_LUA


MONSTER_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("monster.description", compile_rx(r"(?:monster\.description|description)\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("monster.name", compile_rx(r"(?:monster\.name|name)\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("monster.voice", compile_rx(r"text\s*=\s*\"([^\"]{3,})\"")),
)


SPELL_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("spell.words", compile_rx(r"(?:spell:words|words)\s*\(?\s*\"([^\"]{3,})\"")),
    PatternDef("spell.description", compile_rx(r"(?:spell:description|description)\s*\(?\s*\"([^\"]{3,})\"")),
) + BASE_RUNTIME_PATTERNS_LUA


RAID_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("raid.message.attr", compile_rx(r"message\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("raid.message.node", compile_rx(r"<message[^>]*>([^<]{3,})</message>", re.IGNORECASE)),
) + BASE_RUNTIME_PATTERNS_LUA


WORLD_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("world.name", compile_rx(r"name\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("world.description", compile_rx(r"description\s*=\s*\"([^\"]{3,})\"")),
) + BASE_RUNTIME_PATTERNS_LUA


XML_ITEM_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("xml.name", compile_rx(r"\bname\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("xml.description", compile_rx(r"\bdescription\s*=\s*\"([^\"]{3,})\"")),
    PatternDef("xml.attribute.description", compile_rx(r"<attribute[^>]*key\s*=\s*\"description\"[^>]*value\s*=\s*\"([^\"]{3,})\"")),
)


CHAT_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("channel.name", compile_rx(r"\bname\s*=\s*\"([^\"]{3,})\"")),
) + BASE_RUNTIME_PATTERNS_LUA


CPP_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("cpp.sendTextMessage", compile_rx(r"sendTextMessage\s*\([^\"\n]*\"([^\"]{3,})\"")),
    PatternDef("cpp.pushString", compile_rx(r"pushString\s*\(\s*\"([^\"]{3,})\"")),
    PatternDef("cpp.fmt::format", compile_rx(r"fmt::format\s*\(\s*\"([^\"]{3,})\"")),
)


PHP_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("php.echo", compile_rx(r"echo\s+[\"']([^\"']{8,})[\"']")),
    PatternDef("php.literal", compile_rx(r"[\"']([^\"']{20,})[\"']")),
)


HTML_PATTERNS: Tuple[PatternDef, ...] = (
    PatternDef("html.node_text", compile_rx(r">([^<>]{8,})<")),
    PatternDef("html.title", compile_rx(r"title\s*=\s*\"([^\"]{8,})\"")),
    PatternDef("html.placeholder", compile_rx(r"placeholder\s*=\s*\"([^\"]{8,})\"")),
    PatternDef("html.alt", compile_rx(r"alt\s*=\s*\"([^\"]{8,})\"")),
)


CATEGORY_DEFS: Dict[str, CategoryDef] = {
    "npc": CategoryDef(
        name="npc",
        roots=("data-otservbr-global/npc", "data-canary/npc"),
        extensions=(".lua",),
        patterns=NPC_PATTERNS,
        skip_tokens=("i18nKey", "NPC_LIB.i18n.npcSay"),
    ),
    "scripts": CategoryDef(
        name="scripts",
        roots=("data-otservbr-global/scripts", "data/scripts", "data-canary/scripts"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "monsters": CategoryDef(
        name="monsters",
        roots=("data-otservbr-global/monster", "data-canary/monster"),
        extensions=(".lua", ".xml"),
        patterns=MONSTER_PATTERNS,
    ),
    "actions": CategoryDef(
        name="actions",
        roots=("data-otservbr-global/scripts/actions", "data/scripts/actions", "data-canary/scripts/actions"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "quests": CategoryDef(
        name="quests",
        roots=("data-otservbr-global/scripts/quests", "data/scripts/quests", "data-canary/scripts/quests"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "raids": CategoryDef(
        name="raids",
        roots=("data-otservbr-global/raids", "data-canary/raids"),
        extensions=(".lua", ".xml"),
        patterns=RAID_PATTERNS,
    ),
    "world": CategoryDef(
        name="world",
        roots=("data-otservbr-global/world", "data-canary/world"),
        extensions=(".lua",),
        patterns=WORLD_PATTERNS,
    ),
    "spells": CategoryDef(
        name="spells",
        roots=("data-otservbr-global/scripts/spells", "data/scripts/spells", "data-canary/scripts/spells"),
        extensions=(".lua",),
        patterns=SPELL_PATTERNS,
    ),
    "talkactions": CategoryDef(
        name="talkactions",
        roots=("data-otservbr-global/scripts/talkactions", "data/scripts/talkactions", "data-canary/scripts/talkactions"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "movements": CategoryDef(
        name="movements",
        roots=("data-otservbr-global/scripts/movements", "data/scripts/movements", "data-canary/scripts/movements"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "creaturescripts": CategoryDef(
        name="creaturescripts",
        roots=("data-otservbr-global/scripts/creaturescripts", "data/scripts/creaturescripts", "data-canary/scripts/creaturescripts"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "globalevents": CategoryDef(
        name="globalevents",
        roots=("data-otservbr-global/scripts/globalevents", "data/scripts/globalevents", "data-canary/scripts/globalevents"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "items": CategoryDef(
        name="items",
        roots=("data/items", "data/XML"),
        extensions=(".xml",),
        patterns=XML_ITEM_PATTERNS,
    ),
    "mounts": CategoryDef(
        name="mounts",
        roots=("data/XML",),
        extensions=(".xml",),
        patterns=XML_ITEM_PATTERNS,
    ),
    "libs": CategoryDef(
        name="libs",
        roots=("data/libs", "data-otservbr-global/lib", "data-canary/lib"),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("lua.long_literal", compile_rx(r"\"([^\"]{20,})\"")),
        ),
    ),
    "events": CategoryDef(
        name="events",
        roots=("data/events",),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA,
    ),
    "chatchannels": CategoryDef(
        name="chatchannels",
        roots=("data/chatchannels",),
        extensions=(".lua",),
        patterns=CHAT_PATTERNS,
    ),
    "modules": CategoryDef(
        name="modules",
        roots=("data/modules",),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("lua.long_literal", compile_rx(r"\"([^\"]{20,})\"")),
        ),
    ),
    "startup": CategoryDef(
        name="startup",
        roots=("data-otservbr-global/startup",),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("lua.long_literal", compile_rx(r"\"([^\"]{20,})\"")),
        ),
    ),
    "npclib": CategoryDef(
        name="npclib",
        roots=("data/npclib",),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("npclib.constant", compile_rx(r"(?:TEXT_|MSG_)[A-Z0-9_]+\s*=\s*\"([^\"]{3,})\"")),
        ),
    ),
    "dataroot": CategoryDef(
        name="dataroot",
        roots=("data",),
        extensions=(".lua",),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("lua.long_literal", compile_rx(r"\"([^\"]{20,})\"")),
        ),
        recursive=False,
    ),
    "php": CategoryDef(
        name="php",
        roots=("html_copy",),
        extensions=(".php",),
        patterns=PHP_PATTERNS,
        skip_tokens=("__(",),
    ),
    "html": CategoryDef(
        name="html",
        roots=("html_copy",),
        extensions=(".html", ".twig"),
        patterns=HTML_PATTERNS,
        skip_tokens=("{{", " trans", "|trans"),
    ),
    "cpp": CategoryDef(
        name="cpp",
        roots=("src",),
        extensions=(".cpp", ".hpp", ".h"),
        patterns=CPP_PATTERNS,
        skip_tokens=("i18n::",),
    ),
    "otclient_modules": CategoryDef(
        name="otclient_modules",
        roots=("testyy/modules",),
        extensions=(".lua", ".otui"),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("otui.literal", compile_rx(r"\"([^\"]{10,})\"")),
            PatternDef("otui.literal.single", compile_rx(r"'([^']{10,})'")),
        ),
    ),
    "otclient_mods": CategoryDef(
        name="otclient_mods",
        roots=("testyy/mods",),
        extensions=(".lua", ".otui"),
        patterns=BASE_RUNTIME_PATTERNS_LUA + (
            PatternDef("otui.literal", compile_rx(r"\"([^\"]{10,})\"")),
            PatternDef("otui.literal.single", compile_rx(r"'([^']{10,})'")),
        ),
    ),
    "otclient_data": CategoryDef(
        name="otclient_data",
        roots=("testyy/data",),
        extensions=(".lua", ".otui", ".xml"),
        patterns=BASE_RUNTIME_PATTERNS_LUA + XML_ITEM_PATTERNS,
    ),
    "otclient_src": CategoryDef(
        name="otclient_src",
        roots=("testyy/src",),
        extensions=(".cpp", ".hpp", ".h"),
        patterns=CPP_PATTERNS,
    ),
    "otclient_tools": CategoryDef(
        name="otclient_tools",
        roots=("testyy/tools",),
        extensions=(".lua", ".py", ".sh"),
        patterns=(
            PatternDef("tool.literal.double", compile_rx(r"\"([^\"]{10,})\"")),
            PatternDef("tool.literal.single", compile_rx(r"'([^']{10,})'")),
        ),
    ),
    "server": CategoryDef(
        name="server",
        roots=("src",),
        extensions=(".cpp", ".hpp", ".h"),
        patterns=CPP_PATTERNS,
        skip_tokens=("i18n::",),
    ),
    "errors": CategoryDef(
        name="errors",
        roots=("data-otservbr-global/scripts", "data/scripts", "data-canary/scripts", "src"),
        extensions=(".lua", ".cpp", ".hpp", ".h"),
        patterns=BASE_RUNTIME_PATTERNS_LUA + CPP_PATTERNS + (
            PatternDef("error.literal", compile_rx(r"(?:Error|error)[^\"]*\"([^\"]{3,})\"")),
        ),
        skip_tokens=("i18n::",),
    ),
}


def category_list_for_scope(scope: str) -> List[str]:
    names = list(CATEGORY_DEFS.keys())
    scope = (scope or "full").strip().lower()
    if scope in {"server", "canary", "server_only", "server-only"}:
        return [n for n in names if n not in {"php", "html"} and not n.startswith("otclient_")]
    if scope in {"full", "installer", "server+installer", "server_installer", "server+otclient"}:
        return [n for n in names if n not in {"php", "html"}]
    if scope in {"all", "everything"}:
        return names
    return [n for n in names if n not in {"php", "html"}]


def is_comment_line(line: str) -> bool:
    stripped = line.strip()
    return (
        stripped.startswith("--")
        or stripped.startswith("//")
        or stripped.startswith("/*")
        or stripped.startswith("*")
        or stripped.startswith("#")
    )


def normalize_text(raw: str) -> str:
    text = html.unescape(raw or "")
    text = text.replace("\\n", " ").replace("\\t", " ").strip()
    text = re.sub(r"\s+", " ", text)
    return text


def looks_like_non_text_payload(text: str) -> bool:
    if not text:
        return True
    if len(text) < 3:
        return True
    if len(text) > 600:
        return True
    if re.search(r"https?://", text, re.IGNORECASE):
        return True
    if text.startswith("[") and text.endswith("]") and len(text) <= 8:
        return True
    if re.fullmatch(r"[A-Z0-9_]+", text):
        return True
    if re.fullmatch(r"[0-9._:/\\-]+", text):
        return True
    if re.fullmatch(r"[A-Za-z0-9_.:/\\-]+", text) and " " not in text and "." in text:
        return True
    if re.fullmatch(r"%[0-9sdifxX%.+-]*", text):
        return True
    if re.fullmatch(r"[{}%_./\\-]+", text):
        return True
    if text.lower() in {"true", "false", "nil", "none", "null"}:
        return True
    return False


def is_probably_runtime_text(text: str, line: str) -> bool:
    if looks_like_non_text_payload(text):
        return False
    if not re.search(r"[A-Za-z]", text):
        return False
    if "require(" in line or "dofile(" in line:
        return False
    return True


def line_has_localized_tokens(line: str, category_skip_tokens: Sequence[str]) -> bool:
    for token in LOCALIZED_SKIP_TOKENS:
        if token in line:
            return True
    for token in category_skip_tokens:
        if token in line:
            return True
    return False


def iter_category_files(project_root: Path, category: CategoryDef) -> Iterable[Path]:
    for root in category.roots:
        abs_root = project_root / root
        if not abs_root.exists() or not abs_root.is_dir():
            continue

        if category.recursive:
            for dirpath, _, filenames in os.walk(abs_root):
                for name in filenames:
                    if name.endswith(category.extensions):
                        yield Path(dirpath) / name
        else:
            for child in abs_root.iterdir():
                if child.is_file() and child.name.endswith(category.extensions):
                    yield child


def scan_file(path: Path, rel_path: str, category: CategoryDef) -> List[Dict[str, object]]:
    try:
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except Exception:
        return []

    entries: List[Dict[str, object]] = []
    seen: set[Tuple[int, str]] = set()

    for line_no, line in enumerate(lines, 1):
        if is_comment_line(line):
            continue
        if line_has_localized_tokens(line, category.skip_tokens):
            continue

        for pattern in category.patterns:
            for match in pattern.regex.finditer(line):
                raw_text = ""
                if match.lastindex:
                    raw_text = match.group(1)
                else:
                    raw_text = match.group(0)
                text = normalize_text(raw_text)
                if not is_probably_runtime_text(text, line):
                    continue

                dedupe_key = (line_no, text)
                if dedupe_key in seen:
                    continue
                seen.add(dedupe_key)

                entries.append(
                    {
                        "file": rel_path,
                        "line": line_no,
                        "text": text,
                        "pattern": pattern.name,
                        "category": category.name,
                    }
                )

    return entries


def atomic_write_text(path: Path, payload: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(payload, encoding="utf-8")
    os.replace(tmp, path)


def atomic_write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
    os.replace(tmp, path)


def write_category_csv(path: Path, entries: Sequence[Dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["category", "file", "line", "pattern", "text"])
        for row in entries:
            writer.writerow([row["category"], row["file"], row["line"], row["pattern"], row["text"]])
    os.replace(tmp, path)


def render_category_md(
    category: str,
    generated_at_utc: str,
    total_files_scanned: int,
    files_with_hits: int,
    entries: Sequence[Dict[str, object]],
    max_rows: int,
) -> str:
    rows = []
    for row in entries[:max_rows]:
        safe_text = str(row["text"]).replace("|", "\\|")
        rows.append(
            f"| `{row['file']}` | {row['line']} | `{row['pattern']}` | {safe_text} |"
        )

    md = [
        f"# PRE_MIGRATION TODO: {category}",
        "",
        f"- Generated: `{generated_at_utc}`",
        f"- Files scanned: **{total_files_scanned}**",
        f"- Files with hits: **{files_with_hits}**",
        f"- Hits: **{len(entries)}**",
        "",
        "| File | Line | Pattern | Text |",
        "|---|---:|---|---|",
    ]
    md.extend(rows)
    if len(entries) > max_rows:
        md.append("")
        md.append(f"_Truncated: showing {max_rows} of {len(entries)} entries._")
    md.append("")
    return "\n".join(md)


def load_json_or_default(path: Path, default: object) -> object:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception:
        return default


def update_scan_index(
    scan_path: Path,
    generated_at_utc: str,
    category_results: Dict[str, Dict[str, object]],
) -> None:
    current = load_json_or_default(scan_path, {})
    if not isinstance(current, dict):
        current = {}

    for category, result in category_results.items():
        current[category] = {
            "needs_migration": int(result.get("files_with_hits", 0) or 0),
            "hits": int(result.get("hits", 0) or 0),
            "files_with_hits": int(result.get("files_with_hits", 0) or 0),
            "total_files_scanned": int(result.get("total_files_scanned", 0) or 0),
            "scanned_at": generated_at_utc,
        }

    atomic_write_json(scan_path, current)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scan runtime-visible non-i18n texts for PRE_MIGRATION")
    parser.add_argument("--category", default="all", help="Category to scan or 'all'")
    parser.add_argument("--scope", default="full", help="Scope: server | full | all")
    parser.add_argument("--project-root", default=".", help="Project root")
    parser.add_argument("--status-dir", default="i18n/status", help="Status directory")
    parser.add_argument("--md-limit", type=int, default=2000, help="Max rows in markdown tables")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    status_dir = Path(args.status_dir)
    if not status_dir.is_absolute():
        status_dir = (project_root / status_dir).resolve()

    todo_dir = status_dir / "pre_migration_todo"
    todo_dir.mkdir(parents=True, exist_ok=True)

    selected_scope_categories = category_list_for_scope(args.scope)
    requested_category = (args.category or "all").strip()
    if requested_category.lower() == "all":
        categories = selected_scope_categories
    else:
        if requested_category not in CATEGORY_DEFS:
            print(f"ERROR: unknown category '{requested_category}'", file=sys.stderr)
            return 2
        if requested_category not in selected_scope_categories:
            print(
                f"ERROR: category '{requested_category}' excluded by scope '{args.scope}'",
                file=sys.stderr,
            )
            return 3
        categories = [requested_category]

    generated_at_utc = utc_now_iso()
    category_results: Dict[str, Dict[str, object]] = {}
    merged_entries: List[Dict[str, object]] = []

    for category_name in categories:
        category = CATEGORY_DEFS[category_name]
        entries: List[Dict[str, object]] = []
        files_scanned = 0
        files_with_hits = 0

        for path in iter_category_files(project_root, category):
            files_scanned += 1
            rel_path = os.path.relpath(path, project_root)
            hits = scan_file(path, rel_path, category)
            if hits:
                files_with_hits += 1
                entries.extend(hits)

        entries.sort(key=lambda item: (str(item["file"]), int(item["line"]), str(item["pattern"]), str(item["text"])))
        merged_entries.extend(entries)

        category_json = {
            "category": category_name,
            "generated_at_utc": generated_at_utc,
            "scope": args.scope,
            "total_files_scanned": files_scanned,
            "files_with_hits": files_with_hits,
            "hits": len(entries),
            "entries": entries,
        }
        category_json_path = todo_dir / f"{category_name}.json"
        category_md_path = todo_dir / f"{category_name}.md"
        category_csv_path = todo_dir / f"{category_name}.csv"

        atomic_write_json(category_json_path, category_json)
        atomic_write_text(
            category_md_path,
            render_category_md(
                category=category_name,
                generated_at_utc=generated_at_utc,
                total_files_scanned=files_scanned,
                files_with_hits=files_with_hits,
                entries=entries,
                max_rows=max(1, int(args.md_limit)),
            ),
        )
        write_category_csv(category_csv_path, entries)

        category_results[category_name] = {
            "category": category_name,
            "total_files_scanned": files_scanned,
            "files_with_hits": files_with_hits,
            "hits": len(entries),
            "json_file": str(category_json_path.relative_to(project_root)),
            "md_file": str(category_md_path.relative_to(project_root)),
            "csv_file": str(category_csv_path.relative_to(project_root)),
        }

    merged_entries.sort(key=lambda item: (str(item["category"]), str(item["file"]), int(item["line"])))
    total_files_scanned = sum(int(item.get("total_files_scanned", 0) or 0) for item in category_results.values())
    total_files_with_hits = sum(int(item.get("files_with_hits", 0) or 0) for item in category_results.values())
    total_hits = sum(int(item.get("hits", 0) or 0) for item in category_results.values())

    latest_payload = {
        "generated_at_utc": generated_at_utc,
        "scope": args.scope,
        "requested_category": requested_category,
        "categories_scanned": categories,
        "total_files_scanned": total_files_scanned,
        "files_with_hits": total_files_with_hits,
        "hits": total_hits,
        "categories": category_results,
        "entries_preview": merged_entries[:500],
    }
    latest_path = todo_dir / "pre_migration_todo_latest.json"
    atomic_write_json(latest_path, latest_payload)

    combined_csv_path = todo_dir / "pre_migration_todo.csv"
    write_category_csv(combined_csv_path, merged_entries)

    history_path = todo_dir / "pre_migration_todo_history.jsonl"
    history_entry = {
        "generated_at_utc": generated_at_utc,
        "scope": args.scope,
        "requested_category": requested_category,
        "categories_scanned": categories,
        "total_files_scanned": total_files_scanned,
        "files_with_hits": total_files_with_hits,
        "hits": total_hits,
        "categories": {
            k: {
                "total_files_scanned": int(v.get("total_files_scanned", 0) or 0),
                "files_with_hits": int(v.get("files_with_hits", 0) or 0),
                "hits": int(v.get("hits", 0) or 0),
            }
            for k, v in category_results.items()
        },
    }
    with history_path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(history_entry, ensure_ascii=False) + "\n")

    update_scan_index(status_dir / "pre_migration_scan.json", generated_at_utc, category_results)

    for category_name in categories:
        result = category_results[category_name]
        print(
            "PREMIG[{cat}] files_scanned={scanned} files_with_hits={with_hits} hits={hits}".format(
                cat=category_name,
                scanned=result["total_files_scanned"],
                with_hits=result["files_with_hits"],
                hits=result["hits"],
            )
        )

    print(
        "__PREMIG__ category={category} scope={scope} files_scanned={files_scanned} files_with_hits={files_with_hits} hits={hits}".format(
            category=requested_category,
            scope=args.scope,
            files_scanned=total_files_scanned,
            files_with_hits=total_files_with_hits,
            hits=total_hits,
        )
    )
    print(f"__PREMIG_LATEST__ {latest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
