#!/usr/bin/env python3
"""
Audit all key-introduction patterns (hardcoded text -> i18n key) for server + installer.

Outputs:
  - i18n/status/migration_pattern_audit/latest.json
  - i18n/status/migration_pattern_audit/latest.md
  - i18n/status/migration_pattern_audit/latest.csv
  - i18n/status/migration_pattern_audit/history.jsonl

The audit classifies each matched pattern as:
  - supported_by_worker=true  : currently migrated automatically
  - supported_by_worker=false : currently not auto-migrated (gap)
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Pattern, Sequence, Tuple


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


@dataclass(frozen=True)
class PatternSpec:
    id: str
    description: str
    regex: Pattern[str]
    extensions: Tuple[str, ...]
    family: str
    supported_by_worker: bool
    migration_path: str
    recommendation: str
    skip_if_contains: Tuple[str, ...] = ()


ROOTS_SCOPE_SERVER: Tuple[str, ...] = (
    "data-otservbr-global",
    "data-canary",
    "data",
    "src",
)

ROOTS_SCOPE_FULL: Tuple[str, ...] = ROOTS_SCOPE_SERVER + (
    "testyy/modules",
    "testyy/mods",
    "testyy/data",
    "testyy/src",
    "testyy/tools",
)

# "all" currently equals "full" for this repository layout.
ROOTS_SCOPE_ALL: Tuple[str, ...] = ROOTS_SCOPE_FULL

SKIP_LINE_TOKENS: Tuple[str, ...] = (
    "i18nKey",
    "NPC_LIB.i18n",
    "sendLocalizedTextMessage",
    "sayLocalized",
    "broadcastLocalizedMessage",
    "i18n.get",
    "i18n:",
    "i18n::",
)


def _rx(pattern: str, flags: int = 0) -> Pattern[str]:
    return re.compile(pattern, flags)


PATTERNS: Tuple[PatternSpec, ...] = (
    # Lua message APIs (server)
    PatternSpec(
        id="lua_sendtext_literal",
        description="sendTextMessage(..., \"literal\")",
        regex=_rx(r"(?<!Localized)sendTextMessage\s*\(\s*[^,\n]+,\s*['\"][^'\"]{3,}['\"]"),
        extensions=(".lua",),
        family="lua_sendtext",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_lua_sendtext.py",
        recommendation="covered",
    ),
    PatternSpec(
        id="lua_sendtext_string_format",
        description="sendTextMessage(..., string.format(\"...\", ...))",
        regex=_rx(r"(?<!Localized)sendTextMessage\s*\(\s*[^,\n]+,\s*string\.format\s*\("),
        extensions=(".lua",),
        family="lua_sendtext",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_lua_sendtext.py",
        recommendation="covered",
    ),
    PatternSpec(
        id="lua_sendtext_concat_or_dynamic",
        description="sendTextMessage with concat/variable expression",
        regex=_rx(r"(?<!Localized)sendTextMessage\s*\(\s*[^,\n]+,\s*([^,\n]+)\)"),
        extensions=(".lua",),
        family="lua_sendtext",
        supported_by_worker=False,
        migration_path="-",
        recommendation="extend i18n_migrate_lua_sendtext.py for concat/variable sources",
        skip_if_contains=("string.format", "\"", "'"),
    ),
    PatternSpec(
        id="lua_say_literal",
        description=":say(\"literal\") / npcHandler:say(\"literal\")",
        regex=_rx(r"(?<!Localized)\b(?:npcHandler:say|NpcHandler:say|[A-Za-z_][A-Za-z0-9_]*:say)\s*\(\s*['\"][^'\"]{3,}['\"]"),
        extensions=(".lua",),
        family="lua_say",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_lua_say.py + NPC stage4 transformer",
        recommendation="covered",
    ),
    PatternSpec(
        id="lua_say_string_format",
        description=":say(string.format(\"...\", ...))",
        regex=_rx(r"(?<!Localized)\b(?:npcHandler:say|NpcHandler:say|[A-Za-z_][A-Za-z0-9_]*:say)\s*\(\s*string\.format\s*\("),
        extensions=(".lua",),
        family="lua_say",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_lua_say.py + NPC stage4 transformer",
        recommendation="covered",
    ),
    PatternSpec(
        id="lua_say_concat_or_dynamic",
        description=":say with concat/variable expression",
        regex=_rx(r"(?<!Localized)\b(?:npcHandler:say|NpcHandler:say|[A-Za-z_][A-Za-z0-9_]*:say)\s*\(\s*([^)]+)\)"),
        extensions=(".lua",),
        family="lua_say",
        supported_by_worker=False,
        migration_path="-",
        recommendation="extend generic i18n_migrate_lua_say.py for concat/table/dynamic outside NPC stage4",
        skip_if_contains=("string.format", "\"", "'"),
    ),
    PatternSpec(
        id="lua_broadcast_literal_or_format",
        description="broadcastMessage/Game.broadcastMessage literal/format",
        regex=_rx(r"(?<!Localized)\b(?:Game\.)?broadcastMessage\s*\(\s*(?:['\"][^'\"]{3,}['\"]|string\.format\s*\()"),
        extensions=(".lua",),
        family="lua_broadcast",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_lua_broadcast.py",
        recommendation="covered",
    ),
    PatternSpec(
        id="lua_broadcast_dynamic",
        description="broadcastMessage dynamic expression",
        regex=_rx(r"(?<!Localized)\b(?:Game\.)?broadcastMessage\s*\(\s*([^)]+)\)"),
        extensions=(".lua",),
        family="lua_broadcast",
        supported_by_worker=False,
        migration_path="-",
        recommendation="extend i18n_migrate_lua_broadcast.py for concat/variables",
        skip_if_contains=("string.format", "\"", "'"),
    ),
    # NPC-specific insertion styles
    PatternSpec(
        id="npc_stdmodule_text",
        description="StdModule.say/promotePlayer with text=...",
        regex=_rx(r"StdModule\.(?:say|promotePlayer).{0,220}\btext\s*=\s*(?:['\"][^'\"]{3,}['\"]|\{)"),
        extensions=(".lua",),
        family="npc_dialogue",
        supported_by_worker=True,
        migration_path="i18n_worker_simple.sh stage4 (StdModule -> i18nKey)",
        recommendation="covered",
        skip_if_contains=("i18nKey",),
    ),
    PatternSpec(
        id="npc_greet_farewell_text",
        description="addGreetKeyword/addFarewellKeyword with text=",
        regex=_rx(r"add(?:Greet|Farewell)Keyword\s*\([^)]*\btext\s*=\s*['\"][^'\"]{3,}['\"]"),
        extensions=(".lua",),
        family="npc_dialogue",
        supported_by_worker=True,
        migration_path="i18n_worker_simple.sh stage4 (keyword text -> i18nKey)",
        recommendation="covered",
        skip_if_contains=("i18nKey",),
    ),
    PatternSpec(
        id="npc_voices_text",
        description="npcConfig.voices with text=...",
        regex=_rx(r"\bnpcConfig\.voices\b"),
        extensions=(".lua",),
        family="npc_dialogue",
        supported_by_worker=True,
        migration_path="i18n_worker_simple.sh stage4 (voices text -> i18nKey)",
        recommendation="covered",
        skip_if_contains=("i18nKey",),
    ),
    # OTClient/UI
    PatternSpec(
        id="otui_text_literal",
        description="OTUI line: text: \"literal\" / !text: \"literal\"",
        regex=_rx(r"^\s*!?text\s*:\s*['\"][^'\"]{2,}['\"]\s*$"),
        extensions=(".otui", ".otml", ".otmod"),
        family="otclient_otui",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_otclient_otui_text.py",
        recommendation="covered",
        skip_if_contains=("tr(",),
    ),
    PatternSpec(
        id="otui_other_visible_attrs_literal",
        description="OTUI tooltip/title/description/placeholder/label literal",
        regex=_rx(r"^\s*!?(tooltip|title|description|placeholder|label)\s*:\s*['\"][^'\"]{2,}['\"]\s*$", re.IGNORECASE),
        extensions=(".otui", ".otml", ".otmod"),
        family="otclient_otui",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_otclient_otui_text.py",
        recommendation="covered",
        skip_if_contains=("tr(",),
    ),
    PatternSpec(
        id="otclient_tr_literal",
        description="tr(\"literal\") in client lua/otui",
        regex=_rx(r"\btr\s*\(\s*['\"][^'\"]{2,}['\"]"),
        extensions=(".lua", ".otui", ".otml", ".otmod"),
        family="otclient_tr",
        supported_by_worker=True,
        migration_path="tools/i18n_migrate_otclient_tr.py",
        recommendation="covered",
    ),
    PatternSpec(
        id="otclient_tr_dynamic",
        description="tr(dynamic_expr)",
        regex=_rx(r"\btr\s*\(\s*[^'\"][^)]+\)"),
        extensions=(".lua", ".otui", ".otml", ".otmod"),
        family="otclient_tr",
        supported_by_worker=False,
        migration_path="-",
        recommendation="manual review: dynamic tr() source cannot be key-generated safely",
    ),
    # C++ runtime user text (server + installer sources)
    PatternSpec(
        id="cpp_runtime_text_calls",
        description="C++ runtime text in sendTextMessage/fmt::format/pushString/setText",
        regex=_rx(r"\b(?:sendTextMessage|fmt::format|pushString|setText|setTooltip|setTitle|showNotification)\s*\(\s*\"([^\"]{3,})\""),
        extensions=(".cpp", ".hpp", ".h"),
        family="cpp_runtime",
        supported_by_worker=False,
        migration_path="-",
        recommendation="add dedicated C++ migrator (wrapper i18n::get / key registry) before auto-migration",
        skip_if_contains=("i18n::",),
    ),
    PatternSpec(
        id="xml_items_name_desc_literal",
        description="items.xml name/description literals (id + fromid/toid ranges)",
        regex=_rx(r"\b(?:name|description)\s*=\s*\"([^\"]{3,})\"", re.IGNORECASE),
        extensions=(".xml",),
        family="xml_visible",
        supported_by_worker=True,
        migration_path="tools/i18n_resync_items_xml.py",
        recommendation="covered (resync to i18n/en/items.json, range-aware)",
        skip_if_contains=("i18n:",),
    ),
    # XML/OT data visible attrs (mostly extraction only right now)
    PatternSpec(
        id="xml_visible_attrs_literal",
        description="XML name/description/text/title/label literal",
        regex=_rx(r"\b(?:name|description|text|title|label)\s*=\s*\"([^\"]{3,})\"", re.IGNORECASE),
        extensions=(".xml",),
        family="xml_visible",
        supported_by_worker=False,
        migration_path="-",
        recommendation="define xml-to-i18n migration policy per domain (items/monsters/ui xml)",
        skip_if_contains=("i18n:",),
    ),
)


def _is_comment_line(line: str, ext: str) -> bool:
    s = line.strip()
    if not s:
        return True
    if ext == ".lua":
        return s.startswith("--")
    if ext in (".cpp", ".hpp", ".h"):
        return s.startswith("//") or s.startswith("/*") or s.startswith("*")
    if ext in (".otui", ".otml", ".otmod"):
        return s.startswith("//") or s.startswith("#")
    if ext in (".xml",):
        return s.startswith("<!--")
    return False


def _line_has_skip_tokens(line: str) -> bool:
    return any(tok in line for tok in SKIP_LINE_TOKENS)


def _iter_files(project_root: Path, roots: Sequence[str], exts: Sequence[str]) -> Iterable[Path]:
    ext_set = set(exts)
    seen: set[str] = set()
    for rel_root in roots:
        root = project_root / rel_root
        if not root.exists() or not root.is_dir():
            continue
        for dirpath, _, filenames in os.walk(root):
            for name in filenames:
                p = Path(dirpath) / name
                if p.suffix not in ext_set:
                    continue
                rel = str(p.relative_to(project_root))
                if rel in seen:
                    continue
                seen.add(rel)
                yield p


def _is_ignored_file(rel_path: str) -> bool:
    rel = rel_path.replace("\\", "/")
    ignored_substrings = (
        "/backups/",
        "/.git/",
        "/build/",
        "/cmake-build-",
        "/testyy/tools/katepart-syntax/",
    )
    return any(token in rel for token in ignored_substrings)


_SQL_PREFIX_RE = re.compile(
    r"^(?:select|insert|update|delete|replace|alter|create|drop|from|where|join|left join|right join|inner join|order by|group by)\b",
    re.IGNORECASE,
)


def _looks_like_key_literal(text: str) -> bool:
    t = str(text or "").strip()
    if not t:
        return False
    if " " in t or "\t" in t:
        return False
    if "." not in t:
        return False
    return bool(re.fullmatch(r"[A-Za-z0-9_.:-]+", t))


def _is_items_xml(rel_path: str) -> bool:
    rel = rel_path.replace("\\", "/").lower()
    return rel.endswith("data/items/items.xml") or rel.endswith("data-otservbr-global/items/items.xml")


def _should_skip_match(spec_id: str, rel_path: str, line: str, captured_text: str, project_root: Path) -> bool:
    rel = rel_path.replace("\\", "/").lower()
    low = line.lower()
    txt = str(captured_text or "").strip()
    txt_low = txt.lower()

    if spec_id == "xml_items_name_desc_literal":
        # This dedicated pattern is only for items.xml.
        if not _is_items_xml(rel_path):
            return True

    if spec_id == "cpp_runtime_text_calls":
        # SQL and query templates are technical payload, not player-visible text.
        if _SQL_PREFIX_RE.search(txt):
            return True
        if any(tok in txt_low for tok in ("select ", " from ", " where ", " insert ", " update ", " delete ")):
            return True
        # Key-like literals are not user-facing text.
        if _looks_like_key_literal(txt):
            return True
        # Pure format skeletons with placeholders only.
        if re.fullmatch(r"[{}0-9:.,+\-_%]*", txt):
            return True

    if spec_id == "xml_visible_attrs_literal":
        # items.xml is covered by xml_items_name_desc_literal and dedicated worker resync.
        if _is_items_xml(rel_path):
            return True
        # Monster/NPC/house spawn refs in world XML are data identifiers, not UI text.
        if ("<monster " in low or "<npc " in low or "<house " in low) and ("x=\"" in low and "y=\"" in low):
            return True
        if "spawntime=" in low:
            return True
        if rel.endswith("otservbr-monster.xml") or rel.endswith("otservbr-npc.xml") or rel.endswith("otservbr-house.xml"):
            if "<monster " in low or "<npc " in low or "<house " in low:
                return True
        # ID-like XML literals are not player-facing strings.
        if re.fullmatch(r"[A-Za-z0-9_.:-]{1,64}", txt) and " " not in txt:
            return True

    if spec_id == "otclient_tr_dynamic":
        # Do not flag placeholders/dynamic keys with quoted prefix parts.
        if "i18n." in low or "loc" in low:
            return True

    return False


def _render_md(summary: dict, patterns: List[dict], entries: List[dict], sample_limit: int = 80) -> str:
    lines: List[str] = []
    lines.append("# Migration Pattern Audit")
    lines.append("")
    lines.append(f"- Generated: `{summary['generated_at_utc']}`")
    lines.append(f"- Scope: `{summary['scope']}`")
    lines.append(f"- Files scanned: **{summary['files_scanned']}**")
    lines.append(f"- Total hits: **{summary['hits_total']}**")
    lines.append(f"- Supported hits: **{summary['hits_supported']}**")
    lines.append(f"- Unsupported hits: **{summary['hits_unsupported']}**")
    lines.append("")
    lines.append("## Pattern Summary")
    lines.append("")
    lines.append("| Pattern | Family | Supported | Hits | Recommendation |")
    lines.append("|---|---|---|---:|---|")
    for p in patterns:
        supported = "yes" if p["supported_by_worker"] else "no"
        lines.append(
            f"| `{p['id']}` | `{p['family']}` | {supported} | {p['hits']} | {p['recommendation']} |"
        )
    lines.append("")
    lines.append("## Unsupported Samples")
    lines.append("")
    lines.append("| Pattern | File | Line | Snippet |")
    lines.append("|---|---|---:|---|")
    shown = 0
    for row in entries:
        if row.get("supported_by_worker"):
            continue
        snippet = str(row.get("snippet", "")).replace("|", "\\|")
        lines.append(
            f"| `{row['pattern_id']}` | `{row['file']}` | {row['line']} | {snippet[:160]} |"
        )
        shown += 1
        if shown >= sample_limit:
            break
    if shown == 0:
        lines.append("| - | - | - | No unsupported samples |")
    lines.append("")
    return "\n".join(lines)


def _scope_roots(scope: str) -> Tuple[str, ...]:
    s = (scope or "full").strip().lower()
    if s in ("server", "canary", "server_only", "server-only"):
        return ROOTS_SCOPE_SERVER
    if s in ("all", "everything"):
        return ROOTS_SCOPE_ALL
    return ROOTS_SCOPE_FULL


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Audit migration patterns: hardcoded text -> i18n key")
    p.add_argument("--project-root", default=".", help="Project root (default: .)")
    p.add_argument("--status-dir", default="i18n/status", help="Status dir (default: i18n/status)")
    p.add_argument("--scope", default="full", help="Scope: server | full | all")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    status_dir = Path(args.status_dir)
    if not status_dir.is_absolute():
        status_dir = (project_root / status_dir).resolve()
    out_dir = status_dir / "migration_pattern_audit"
    out_dir.mkdir(parents=True, exist_ok=True)

    roots = _scope_roots(args.scope)
    all_exts = sorted({ext for p in PATTERNS for ext in p.extensions})
    files = list(_iter_files(project_root, roots, all_exts))

    pattern_hits: Dict[str, int] = {p.id: 0 for p in PATTERNS}
    rows: List[dict] = []
    file_count = 0

    patterns_by_ext: Dict[str, List[PatternSpec]] = {}
    for p in PATTERNS:
        for ext in p.extensions:
            patterns_by_ext.setdefault(ext, []).append(p)

    for path in files:
        file_count += 1
        rel = str(path.relative_to(project_root))
        if _is_ignored_file(rel):
            continue
        ext = path.suffix
        ext_patterns = patterns_by_ext.get(ext, [])
        if not ext_patterns:
            continue

        try:
            lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        except Exception:
            continue

        for line_no, line in enumerate(lines, 1):
            if _is_comment_line(line, ext):
                continue
            if _line_has_skip_tokens(line):
                continue
            for spec in ext_patterns:
                if spec.skip_if_contains and any(tok in line for tok in spec.skip_if_contains):
                    continue
                m = spec.regex.search(line)
                if not m:
                    continue
                captured = m.group(1) if m.lastindex else ""
                if _should_skip_match(spec.id, rel, line, captured, project_root):
                    continue
                pattern_hits[spec.id] += 1
                rows.append(
                    {
                        "pattern_id": spec.id,
                        "family": spec.family,
                        "description": spec.description,
                        "supported_by_worker": spec.supported_by_worker,
                        "migration_path": spec.migration_path,
                        "recommendation": spec.recommendation,
                        "file": rel,
                        "line": line_no,
                        "snippet": line.strip(),
                    }
                )

    pattern_summary: List[dict] = []
    hits_total = 0
    hits_supported = 0
    hits_unsupported = 0
    for spec in PATTERNS:
        hits = int(pattern_hits.get(spec.id, 0) or 0)
        hits_total += hits
        if spec.supported_by_worker:
            hits_supported += hits
        else:
            hits_unsupported += hits
        pattern_summary.append(
            {
                "id": spec.id,
                "family": spec.family,
                "description": spec.description,
                "supported_by_worker": spec.supported_by_worker,
                "migration_path": spec.migration_path,
                "recommendation": spec.recommendation,
                "hits": hits,
            }
        )

    pattern_summary.sort(key=lambda x: (-x["hits"], x["id"]))
    rows.sort(key=lambda x: (x["supported_by_worker"], x["pattern_id"], x["file"], x["line"]))

    generated_at = utc_now_iso()
    summary = {
        "generated_at_utc": generated_at,
        "scope": args.scope,
        "roots": list(roots),
        "files_scanned": file_count,
        "hits_total": hits_total,
        "hits_supported": hits_supported,
        "hits_unsupported": hits_unsupported,
        "unsupported_ratio_pct": round((hits_unsupported / hits_total * 100.0), 2) if hits_total else 0.0,
    }
    payload = {
        "summary": summary,
        "patterns": pattern_summary,
        "entries": rows,
    }

    latest_json = out_dir / "latest.json"
    latest_md = out_dir / "latest.md"
    latest_csv = out_dir / "latest.csv"
    history_jsonl = out_dir / "history.jsonl"

    # JSON
    tmp_json = latest_json.with_suffix(".json.tmp")
    with tmp_json.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    os.replace(tmp_json, latest_json)

    # MD
    md = _render_md(summary, pattern_summary, rows)
    tmp_md = latest_md.with_suffix(".md.tmp")
    tmp_md.write_text(md, encoding="utf-8")
    os.replace(tmp_md, latest_md)

    # CSV
    tmp_csv = latest_csv.with_suffix(".csv.tmp")
    with tmp_csv.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "pattern_id",
                "family",
                "supported_by_worker",
                "migration_path",
                "recommendation",
                "file",
                "line",
                "snippet",
            ]
        )
        for row in rows:
            w.writerow(
                [
                    row["pattern_id"],
                    row["family"],
                    1 if row["supported_by_worker"] else 0,
                    row["migration_path"],
                    row["recommendation"],
                    row["file"],
                    row["line"],
                    row["snippet"],
                ]
            )
    os.replace(tmp_csv, latest_csv)

    # History
    with history_jsonl.open("a", encoding="utf-8") as f:
        f.write(json.dumps(summary, ensure_ascii=False) + "\n")

    print(
        f"__PATTERN_AUDIT__ files={file_count} hits_total={hits_total} "
        f"supported={hits_supported} unsupported={hits_unsupported} "
        f"unsupported_ratio_pct={summary['unsupported_ratio_pct']}"
    )
    print(f"JSON: {latest_json}")
    print(f"MD:   {latest_md}")
    print(f"CSV:  {latest_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
