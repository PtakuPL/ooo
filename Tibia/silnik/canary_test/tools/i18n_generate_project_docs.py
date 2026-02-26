#!/usr/bin/env python3
"""
DOCUMENTATION generator — per-file project documentation for i18n worker.

Generates:
  - docs/i18n/project/files/<sanitized_path>.md   (per file)
  - docs/i18n/project/INDEX.md                    (global index)
  - docs/i18n/project/index.json                  (machine-readable index)
  - i18n/status/documentation_state.json           (cursor + progress)
  - i18n/status/documentation_latest.json          (last run summary)

Usage:
  python3 tools/i18n_generate_project_docs.py --batch 20
  python3 tools/i18n_generate_project_docs.py --batch 50 --reset
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


# ── File inventory ──────────────────────────────────────────────────────────
SCAN_ROOTS = [
    "src",
    "data-otservbr-global/npc",
    "data-otservbr-global/scripts",
    "data-otservbr-global/monster",
    "data-otservbr-global/lib",
    "data/scripts",
    "data/npc",
    "data/monster",
    "data/lib",
    "data/libs",
    "i18n",
    "tools",
]

SCAN_EXTENSIONS = {
    ".lua", ".cpp", ".h", ".hpp", ".py", ".sh", ".json", ".xml",
}

SKIP_DIRS = {
    ".git", "node_modules", "__pycache__", ".cache", "build", "vcpkg",
    "vcpkg_installed", "CMakeFiles", "html_copy",
}

SKIP_FILES = {
    "compile_commands.json", "CMakeCache.txt", "package-lock.json",
}


def build_file_inventory(base_dir: str) -> List[str]:
    """Collect all documentable files from scan roots."""
    files: List[str] = []
    base = Path(base_dir)

    for root_name in SCAN_ROOTS:
        root_path = base / root_name
        if not root_path.exists():
            continue
        if root_path.is_file():
            files.append(str(root_path.relative_to(base)))
            continue

        for dirpath_obj, dirnames, filenames in os.walk(root_path):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for fname in sorted(filenames):
                if fname in SKIP_FILES:
                    continue
                fpath = Path(dirpath_obj) / fname
                if fpath.suffix.lower() in SCAN_EXTENSIONS:
                    files.append(str(fpath.relative_to(base)))

    return sorted(set(files))


# ── File analysis ───────────────────────────────────────────────────────────

I18N_PATTERNS = [
    (re.compile(r'(?:npcHandler|NPC_LIB)[\.:]\w*[Ss]ay\s*\('), "npc_say"),
    (re.compile(r'sendTextMessage\s*\('), "sendTextMessage"),
    (re.compile(r'broadcastMessage\s*\('), "broadcastMessage"),
    (re.compile(r'i18n\.\w+\s*\('), "i18n_call"),
    (re.compile(r'getI18nText\s*\('), "getI18nText"),
    (re.compile(r'player:sendTextMessage\s*\('), "player_sendText"),
    (re.compile(r'doPlayerSendTextMessage\s*\('), "doPlayerSendText"),
    (re.compile(r'voices\s*=\s*\{'), "voices_table"),
]

SYMBOL_PATTERNS = {
    "lua_function": re.compile(r'^(?:local\s+)?function\s+(\w[\w.:]*)\s*\(', re.MULTILINE),
    "lua_variable": re.compile(r'^local\s+(\w+)\s*=', re.MULTILINE),
    "cpp_function": re.compile(r'^(?:\w[\w:*&<> ]+)\s+(\w+)\s*\([^)]*\)\s*(?:const\s*)?(?:override\s*)?[{;]', re.MULTILINE),
    "cpp_class": re.compile(r'^(?:class|struct)\s+(\w+)', re.MULTILINE),
    "python_function": re.compile(r'^def\s+(\w+)\s*\(', re.MULTILINE),
    "python_class": re.compile(r'^class\s+(\w+)', re.MULTILINE),
    "xml_element": re.compile(r'<(\w+)\s', re.MULTILINE),
}

EVENT_PATTERNS = {
    "event_register": re.compile(r'(?:Event|CreatureEvent|MoveEvent|Action|TalkAction|GlobalEvent)\s*[:.]?\s*(?:new|register)\w*\s*\(', re.IGNORECASE),
    "event_callback": re.compile(r'(?:onUse|onSay|onLogin|onLogout|onThink|onHealth|onDeath|onAdvance|onLook|onStepIn|onStepOut|onEquip|onDeEquip|onAddItem|onMoveItem)\s*[=(]', re.IGNORECASE),
}

# ── Keyword/tag extraction ──────────────────────────────────────────────────

# Domain-specific keywords for Tibia/OTServ
DOMAIN_KEYWORDS = {
    # Game mechanics
    "npc", "quest", "spell", "monster", "creature", "player", "item",
    "action", "talkaction", "movement", "combat", "loot", "reward",
    "vocation", "outfit", "mount", "addon", "teleport", "lever",
    "door", "chest", "boss", "raid", "event", "shop", "trade",
    "depot", "house", "guild", "party", "war", "pvp", "pve",
    # Server
    "login", "logout", "broadcast", "ban", "admin", "gamemaster",
    "save", "load", "config", "database", "map", "tile", "position",
    # i18n
    "i18n", "translation", "localization", "locale", "language",
    "migration", "key", "fallback",
    # Technical
    "handler", "callback", "event", "register", "listener",
    "storage", "global", "condition", "effect", "animation",
}

def extract_keywords(rel_path: str, content: str, symbols: List[Dict], i18n_tps: List[Dict], events: List[Dict]) -> List[str]:
    """Extract keywords/tags from file for search and navigation."""
    keywords: Set[str] = set()

    # 1. Path-based tags
    parts = rel_path.replace("\\", "/").lower().split("/")
    for p in parts:
        clean = re.sub(r'[^a-z0-9]', '', p)
        if clean and len(clean) >= 3 and clean in DOMAIN_KEYWORDS:
            keywords.add(clean)

    # Tag from directory structure
    if "npc" in parts:
        keywords.add("npc")
    if "monster" in parts:
        keywords.add("monster")
    if "scripts" in parts:
        keywords.add("script")
    if "lib" in parts or "libs" in parts:
        keywords.add("library")
    if "i18n" in parts:
        keywords.add("i18n")
    if "src" in parts:
        keywords.add("engine")

    # 2. Extension-based tags
    ext = Path(rel_path).suffix.lower()
    ext_tags = {".lua": "lua", ".cpp": "cpp", ".h": "cpp", ".hpp": "cpp",
                ".py": "python", ".sh": "shell", ".json": "json", ".xml": "xml"}
    if ext in ext_tags:
        keywords.add(ext_tags[ext])

    # 3. Content-based domain keywords
    content_lower = content.lower()
    for kw in DOMAIN_KEYWORDS:
        if kw in content_lower:
            keywords.add(kw)

    # 4. Symbol-based tags
    for sym in symbols[:100]:
        name_lower = sym["name"].lower()
        # Extract meaningful prefixes/words from symbol names
        words = re.findall(r'[a-z]{3,}', name_lower)
        for w in words:
            if w in DOMAIN_KEYWORDS:
                keywords.add(w)

    # 5. i18n touchpoint types as tags
    for tp in i18n_tps:
        keywords.add(f"i18n:{tp['type']}")

    # 6. Event types as tags
    for ev in events:
        keywords.add(f"event:{ev['type']}")

    # 7. Special tags based on content patterns
    if re.search(r'\bregisterCreatureEvent\b', content, re.IGNORECASE):
        keywords.add("creature_event")
    if re.search(r'\bTalkAction\b', content, re.IGNORECASE):
        keywords.add("talkaction")
    if re.search(r'\bAction\b.*register', content, re.IGNORECASE):
        keywords.add("action")
    if re.search(r'\bMoveEvent\b', content, re.IGNORECASE):
        keywords.add("movement")
    if re.search(r'\bGlobalEvent\b', content, re.IGNORECASE):
        keywords.add("global_event")

    return sorted(keywords)


def classify_file(rel_path: str) -> str:
    """Return human-readable file kind."""
    ext = Path(rel_path).suffix.lower()
    parts = rel_path.replace("\\", "/").split("/")

    kind_map = {
        ".lua": "Lua script",
        ".cpp": "C++ source",
        ".h": "C++ header",
        ".hpp": "C++ header",
        ".py": "Python script",
        ".sh": "Shell script",
        ".json": "JSON data",
        ".xml": "XML data",
    }

    base_kind = kind_map.get(ext, "file")

    if "npc" in parts:
        return f"NPC {base_kind}"
    if "monster" in parts:
        return f"Monster {base_kind}"
    if "scripts" in parts:
        return f"Game script ({base_kind})"
    if "lib" in parts or "libs" in parts:
        return f"Library {base_kind}"
    if "i18n" in parts:
        return f"i18n {base_kind}"
    if "tools" in parts:
        return f"Tool {base_kind}"
    if "src" in parts:
        return f"Engine {base_kind}"

    return base_kind


def analyze_file(base_dir: str, rel_path: str) -> Dict:
    """Analyze a single file and return documentation data."""
    full_path = os.path.join(base_dir, rel_path)
    result = {
        "file": rel_path,
        "kind": classify_file(rel_path),
        "size_bytes": 0,
        "lines": 0,
        "symbols": [],
        "i18n_touchpoints": [],
        "events": [],
        "keywords": [],
        "summary": "",
        "errors": [],
    }

    try:
        content = Path(full_path).read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        result["errors"].append(f"read error: {e}")
        return result

    result["size_bytes"] = len(content.encode("utf-8", errors="replace"))
    lines = content.split("\n")
    result["lines"] = len(lines)

    # Extract symbols
    ext = Path(rel_path).suffix.lower()
    symbol_types = []
    if ext == ".lua":
        symbol_types = ["lua_function", "lua_variable"]
    elif ext in (".cpp", ".h", ".hpp"):
        symbol_types = ["cpp_function", "cpp_class"]
    elif ext == ".py":
        symbol_types = ["python_function", "python_class"]
    elif ext == ".xml":
        symbol_types = ["xml_element"]

    for stype in symbol_types:
        pattern = SYMBOL_PATTERNS.get(stype)
        if pattern:
            for m in pattern.finditer(content):
                line_no = content[:m.start()].count("\n") + 1
                result["symbols"].append({
                    "name": m.group(1),
                    "type": stype,
                    "line": line_no,
                })

    # Deduplicate XML elements by name
    if ext == ".xml":
        seen = set()
        unique = []
        for s in result["symbols"]:
            if s["name"] not in seen:
                seen.add(s["name"])
                unique.append(s)
        result["symbols"] = unique

    # i18n touchpoints
    for pattern, tp_name in I18N_PATTERNS:
        for m in pattern.finditer(content):
            line_no = content[:m.start()].count("\n") + 1
            line_text = lines[line_no - 1].strip() if line_no <= len(lines) else ""
            result["i18n_touchpoints"].append({
                "type": tp_name,
                "line": line_no,
                "text": line_text[:120],
            })

    # Events
    for evt_name, pattern in EVENT_PATTERNS.items():
        for m in pattern.finditer(content):
            line_no = content[:m.start()].count("\n") + 1
            result["events"].append({
                "type": evt_name,
                "line": line_no,
                "match": m.group(0).strip()[:80],
            })

    # Generate summary
    n_symbols = len(result["symbols"])
    n_i18n = len(result["i18n_touchpoints"])
    n_events = len(result["events"])

    # Extract keywords/tags (DOC-09)
    result["keywords"] = extract_keywords(rel_path, content, result["symbols"], result["i18n_touchpoints"], result["events"])

    parts = [result["kind"]]
    if n_symbols > 0:
        parts.append(f"{n_symbols} symbols")
    if n_i18n > 0:
        parts.append(f"{n_i18n} i18n touchpoints")
    if n_events > 0:
        parts.append(f"{n_events} events")
    parts.append(f"{result['lines']} lines")
    result["summary"] = " | ".join(parts)

    return result


# ── Markdown generation ─────────────────────────────────────────────────────

def sanitize_path_for_filename(rel_path: str) -> str:
    return rel_path.replace("/", "__").replace("\\", "__")


def generate_file_doc(data: Dict) -> str:
    """Generate markdown documentation for a single file."""
    lines = [f"# {data['file']}\n"]
    lines.append(f"**Kind:** {data['kind']}  ")
    lines.append(f"**Size:** {data['size_bytes']} bytes | **Lines:** {data['lines']}  ")
    if data.get("keywords"):
        lines.append(f"**Tags:** {', '.join(f'`{k}`' for k in data['keywords'])}\n")
    else:
        lines.append("")

    # Human description
    lines.append("## Opis funkcjonalny\n")
    lines.append(f"{data['kind']} — {data['summary']}\n")

    # Symbols
    if data["symbols"]:
        lines.append("## Symbole\n")
        lines.append("| Nazwa | Typ | Linia |")
        lines.append("|---|---|---|")
        for s in data["symbols"][:50]:  # limit display
            lines.append(f"| `{s['name']}` | {s['type']} | L{s['line']} |")
        if len(data["symbols"]) > 50:
            lines.append(f"\n*...i {len(data['symbols']) - 50} więcej*\n")
        lines.append("")

    # i18n touchpoints
    if data["i18n_touchpoints"]:
        lines.append("## i18n Touchpoints\n")
        lines.append("| Typ | Linia | Fragment |")
        lines.append("|---|---|---|")
        for tp in data["i18n_touchpoints"][:30]:
            text_escaped = tp["text"].replace("|", "\\|")
            lines.append(f"| {tp['type']} | L{tp['line']} | `{text_escaped}` |")
        if len(data["i18n_touchpoints"]) > 30:
            lines.append(f"\n*...i {len(data['i18n_touchpoints']) - 30} więcej*\n")
        lines.append("")

    # Events
    if data["events"]:
        lines.append("## Eventy / Callbacki\n")
        lines.append("| Typ | Linia | Fragment |")
        lines.append("|---|---|---|")
        for ev in data["events"][:20]:
            lines.append(f"| {ev['type']} | L{ev['line']} | `{ev['match']}` |")
        lines.append("")

    # Errors
    if data["errors"]:
        lines.append("## Błędy analizy\n")
        for err in data["errors"]:
            lines.append(f"- ⚠️ {err}")
        lines.append("")

    return "\n".join(lines)


def generate_index_md(entries: List[Dict]) -> str:
    """Generate global INDEX.md."""
    lines = [
        "# Dokumentacja projektu — Indeks\n",
        f"**Wygenerowano:** {utc_now_iso()}  ",
        f"**Plików:** {len(entries)}\n",
        "## Pliki\n",
        "| Plik | Typ | Symbole | i18n | Linie | Tagi |",
        "|---|---|---|---|---|---|",
    ]
    for e in entries:
        doc_link = f"files/{sanitize_path_for_filename(e['file'])}.md"
        n_sym = e.get("symbols_count", 0)
        n_i18n = e.get("i18n_count", 0)
        tags_str = ", ".join(e.get("keywords", [])[:5]) or "-"
        lines.append(f"| [{e['file']}]({doc_link}) | {e['kind']} | {n_sym} | {n_i18n} | {e.get('lines', 0)} | {tags_str} |")

    lines.append("")
    return "\n".join(lines)


# ── Quality validation (DOC-10) ───────────────────────────────────────────────

QUALITY_RULES = [
    "empty_summary",         # brak sekcji 'Opis funkcjonalny' lub jest pusta
    "no_symbols_detected",   # plik kodu bez symboli i bez wyjaśnienia
    "no_i18n_touchpoints",   # plik zawiera teksty user-visible, ale brak touchpoints
    "unresolved_ratio_high", # >30% wpisów jako errors
    "empty_file",            # plik źródłowy jest pusty (0 bytes)
    "no_keywords",           # brak keywordów/tagów
]

CODE_EXTENSIONS = {".lua", ".cpp", ".h", ".hpp", ".py", ".sh"}


def validate_doc_quality(data: Dict) -> List[Dict]:
    """Validate quality of generated documentation. Returns list of quality issues."""
    issues: List[Dict] = []
    ext = Path(data["file"]).suffix.lower()

    # Rule: empty_file
    if data.get("size_bytes", 0) == 0:
        issues.append({
            "rule": "empty_file",
            "severity": "warning",
            "detail": "Source file is empty (0 bytes)",
        })

    # Rule: empty_summary
    summary = data.get("summary", "")
    if not summary or summary == data.get("kind", ""):
        issues.append({
            "rule": "empty_summary",
            "severity": "warning",
            "detail": "Documentation has no meaningful summary",
        })

    # Rule: no_symbols_detected (only for code files)
    if ext in CODE_EXTENSIONS and data.get("lines", 0) > 5:
        if not data.get("symbols"):
            issues.append({
                "rule": "no_symbols_detected",
                "severity": "info",
                "detail": f"Code file ({ext}) with {data.get('lines', 0)} lines but no symbols detected",
            })

    # Rule: no_i18n_touchpoints
    kind = data.get("kind", "").lower()
    if ("npc" in kind or "game script" in kind) and not data.get("i18n_touchpoints"):
        issues.append({
            "rule": "no_i18n_touchpoints",
            "severity": "info",
            "detail": f"File kind '{data.get('kind')}' expected to have i18n touchpoints but none found",
        })

    # Rule: unresolved_ratio_high
    n_errors = len(data.get("errors", []))
    total_sections = max(1, len(data.get("symbols", [])) + len(data.get("i18n_touchpoints", [])) + len(data.get("events", [])))
    if total_sections > 0 and n_errors > 0 and (n_errors / total_sections) > 0.3:
        issues.append({
            "rule": "unresolved_ratio_high",
            "severity": "warning",
            "detail": f"High error ratio: {n_errors}/{total_sections} ({n_errors/total_sections*100:.0f}%)",
        })

    # Rule: no_keywords
    if not data.get("keywords"):
        issues.append({
            "rule": "no_keywords",
            "severity": "info",
            "detail": "No keywords/tags extracted",
        })

    return issues


def generate_quality_report(all_quality_issues: Dict[str, List[Dict]], report_path: str):
    """Generate quality validation report to JSON."""
    total_files = len(all_quality_issues)
    files_with_issues = sum(1 for issues in all_quality_issues.values() if issues)
    issues_by_rule: Dict[str, int] = {}
    for issues in all_quality_issues.values():
        for iss in issues:
            rule = iss["rule"]
            issues_by_rule[rule] = issues_by_rule.get(rule, 0) + 1

    report = {
        "generated_at_utc": utc_now_iso(),
        "total_files_checked": total_files,
        "files_with_issues": files_with_issues,
        "files_ok": total_files - files_with_issues,
        "quality_pct": round((total_files - files_with_issues) / max(1, total_files) * 100, 1),
        "issues_by_rule": dict(sorted(issues_by_rule.items(), key=lambda x: -x[1])),
        "top_issues": [
            {
                "file": f,
                "issues": issues,
            }
            for f, issues in sorted(all_quality_issues.items(), key=lambda x: -len(x[1]))
            if issues
        ][:50],
    }

    # Generate unresolved sub-report
    unresolved_entries = []
    for f, issues in all_quality_issues.items():
        unresolved_issues = [i for i in issues if i["rule"] in ("no_symbols_detected", "unresolved_ratio_high", "no_i18n_touchpoints")]
        if unresolved_issues:
            unresolved_entries.append({"file": f, "issues": unresolved_issues})

    if unresolved_entries:
        unresolved_report = {
            "generated_at_utc": utc_now_iso(),
            "total_unresolved_files": len(unresolved_entries),
            "description": "Files the documentation generator could not properly analyze — need manual review or parser improvements",
            "entries": sorted(unresolved_entries, key=lambda x: -len(x["issues"]))[:200],
        }
        unresolved_path = os.path.join(os.path.dirname(report_path), "documentation_unresolved_report.json")
        with open(unresolved_path, "w", encoding="utf-8") as fu:
            json.dump(unresolved_report, fu, indent=2, ensure_ascii=False)
        report["unresolved_files"] = len(unresolved_entries)

    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    with open(report_path, "w", encoding="utf-8") as fout:
        json.dump(report, fout, indent=2, ensure_ascii=False)

    return report


# ── State management ────────────────────────────────────────────────────────

def load_state(state_path: str) -> Dict:
    if os.path.exists(state_path):
        try:
            with open(state_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"cursor": 0, "processed": [], "errors": [], "total": 0}


def save_state(state_path: str, state: Dict):
    os.makedirs(os.path.dirname(state_path), exist_ok=True)
    with open(state_path, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)


# ── Main ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Generate project documentation per file")
    parser.add_argument("--batch", type=int, default=20, help="Number of files to process per batch")
    parser.add_argument("--reset", action="store_true", help="Reset cursor and reprocess all files")
    parser.add_argument("--base-dir", default=".", help="Project base directory")
    args = parser.parse_args()

    base_dir = os.path.abspath(args.base_dir)
    status_dir = os.path.join(base_dir, "i18n", "status")
    docs_dir = os.path.join(base_dir, "docs", "i18n", "project")
    files_dir = os.path.join(docs_dir, "files")
    state_path = os.path.join(status_dir, "documentation_state.json")
    latest_path = os.path.join(status_dir, "documentation_latest.json")

    os.makedirs(files_dir, exist_ok=True)

    # Build inventory
    inventory = build_file_inventory(base_dir)
    print(f"📖 DOCUMENTATION: inventory={len(inventory)} files")

    # Load state
    state = load_state(state_path)
    if args.reset:
        state = {"cursor": 0, "processed": [], "errors": [], "total": 0}

    state["total"] = len(inventory)
    cursor = state.get("cursor", 0)
    processed_set: Set[str] = set(state.get("processed", []))

    # Process batch
    generated = 0
    errors = 0
    batch_entries = []
    batch_quality_issues: Dict[str, List[Dict]] = {}

    for i in range(cursor, min(cursor + args.batch, len(inventory))):
        rel_path = inventory[i]
        if rel_path in processed_set:
            continue

        try:
            data = analyze_file(base_dir, rel_path)

            # Quality validation (DOC-10)
            quality_issues = validate_doc_quality(data)
            batch_quality_issues[rel_path] = quality_issues

            doc_md = generate_file_doc(data)

            # Write per-file doc
            doc_filename = sanitize_path_for_filename(rel_path) + ".md"
            doc_path = os.path.join(files_dir, doc_filename)
            with open(doc_path, "w", encoding="utf-8") as f:
                f.write(doc_md)

            batch_entries.append({
                "file": rel_path,
                "kind": data["kind"],
                "summary": data["summary"],
                "symbols_count": len(data["symbols"]),
                "i18n_count": len(data["i18n_touchpoints"]),
                "events_count": len(data["events"]),
                "keywords": data.get("keywords", []),
                "lines": data["lines"],
                "errors": data["errors"],
            })

            processed_set.add(rel_path)
            generated += 1

        except Exception as e:
            errors += 1
            state.setdefault("errors", []).append({
                "file": rel_path,
                "error": str(e),
                "timestamp": utc_now_iso(),
            })

    # Update cursor
    new_cursor = min(cursor + args.batch, len(inventory))
    state["cursor"] = new_cursor
    state["processed"] = sorted(processed_set)

    # Rebuild index from all existing docs
    all_entries = []
    for doc_file in sorted(Path(files_dir).glob("*.md")):
        rel_name = doc_file.stem.replace("__", "/")
        # Try to find in batch_entries first
        entry = next((e for e in batch_entries if sanitize_path_for_filename(e["file"]) == doc_file.stem), None)
        if entry:
            all_entries.append(entry)
        else:
            all_entries.append({
                "file": rel_name,
                "kind": classify_file(rel_name),
                "summary": "",
                "symbols_count": 0,
                "i18n_count": 0,
                "lines": 0,
            })

    # Write INDEX.md
    index_md = generate_index_md(all_entries)
    with open(os.path.join(docs_dir, "INDEX.md"), "w", encoding="utf-8") as f:
        f.write(index_md)

    # Write index.json
    index_json = {
        "generated_at_utc": utc_now_iso(),
        "total_files": len(all_entries),
        "entries": [{
            "file": e["file"],
            "doc": f"docs/i18n/project/files/{sanitize_path_for_filename(e['file'])}.md",
            "kind": e["kind"],
            "summary": e.get("summary", ""),
            "keywords": e.get("keywords", []),
        } for e in all_entries],
    }
    with open(os.path.join(docs_dir, "index.json"), "w", encoding="utf-8") as f:
        json.dump(index_json, f, indent=2, ensure_ascii=False)

    # Save state
    save_state(state_path, state)

    # Quality report (DOC-10)
    quality_report_path = os.path.join(status_dir, "documentation_quality_report.json")
    quality_report = {}
    if batch_quality_issues:
        quality_report = generate_quality_report(batch_quality_issues, quality_report_path)

    # Save latest
    remaining = len(inventory) - len(processed_set)
    quality_ok = quality_report.get("files_ok", generated) if quality_report else generated
    quality_issues_total = quality_report.get("files_with_issues", 0) if quality_report else 0
    latest = {
        "generated_at_utc": utc_now_iso(),
        "batch_size": args.batch,
        "generated": generated,
        "errors": errors,
        "remaining": remaining,
        "total_inventory": len(inventory),
        "total_documented": len(processed_set),
        "cursor": new_cursor,
        "index_entries": len(all_entries),
        "quality": {
            "files_checked": quality_report.get("total_files_checked", 0),
            "files_ok": quality_ok,
            "files_with_issues": quality_issues_total,
            "quality_pct": quality_report.get("quality_pct", 100.0),
            "issues_by_rule": quality_report.get("issues_by_rule", {}),
        },
    }
    save_state(latest_path, latest)

    # Output for bash parsing
    print(f"generated={generated} remaining={remaining} errors={errors} total={len(inventory)} documented={len(processed_set)}")
    print(f"✅ DOCUMENTATION: {generated} new docs, {remaining} remaining, {errors} errors")

    return 0


if __name__ == "__main__":
    sys.exit(main())
