#!/usr/bin/env python3
import argparse
import json
import os
import re
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class MigrationResult:
    keys_added: int
    calls_migrated: int
    file_changed: bool
    skipped_calls: int


_STRING_LITERAL_RE = re.compile(
    r"^(?P<q>['\"])(?P<body>(?:\\.|(?!\1).)*)\1$",
    re.DOTALL,
)


def _read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def _write_text_atomic(path: str, content: str) -> None:
    tmp_path = f"{path}.tmp"
    with open(tmp_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
    os.replace(tmp_path, path)


def _load_json(path: str) -> dict:
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data_sorted = dict(sorted(data.items(), key=lambda kv: kv[0]))
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data_sorted, f, indent=2, ensure_ascii=False)


def _scan_matching_paren(content: str, open_paren_idx: int) -> Optional[int]:
    depth = 1
    i = open_paren_idx + 1
    in_str: Optional[str] = None
    esc = False

    while i < len(content):
        ch = content[i]

        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue

        if ch == '"' or ch == "'":
            in_str = ch
            i += 1
            continue

        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1

    return None


def _split_top_level_args(arg_str: str) -> List[str]:
    args: List[str] = []
    buf: List[str] = []
    depth = 0
    in_str: Optional[str] = None
    esc = False

    for ch in arg_str:
        if in_str:
            buf.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == in_str:
                in_str = None
            continue

        if ch == '"' or ch == "'":
            in_str = ch
            buf.append(ch)
            continue

        if ch == "(":
            depth += 1
            buf.append(ch)
            continue
        if ch == ")":
            depth = max(0, depth - 1)
            buf.append(ch)
            continue

        if ch == "," and depth == 0:
            args.append("".join(buf).strip())
            buf = []
            continue

        buf.append(ch)

    tail = "".join(buf).strip()
    if tail:
        args.append(tail)
    return args


def _unescape_lua_string(s: str) -> str:
    s = s.replace("\\\"", '"').replace("\\'", "'")
    s = s.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t")
    s = s.replace("\\\\", "\\")
    return s


def _extract_string_literal(expr: str) -> Optional[str]:
    expr = expr.strip()
    m = _STRING_LITERAL_RE.match(expr)
    if not m:
        return None
    return _unescape_lua_string(m.group("body"))


def _looks_like_key(s: str) -> bool:
    # Heuristic: semantic keys typically contain dots and no spaces
    if " " in s or "\t" in s or "\n" in s:
        return False
    if "." not in s:
        return False
    return bool(re.fullmatch(r"[A-Za-z0-9_.:-]+", s))


def _next_key_index(existing: dict, key_prefix: str) -> int:
    pat = re.compile(rf"^{re.escape(key_prefix)}\.tr_(\d+)$")
    max_idx = 0
    for k in existing.keys():
        m = pat.match(k)
        if m:
            try:
                max_idx = max(max_idx, int(m.group(1)))
            except ValueError:
                pass
    return max_idx + 1


def migrate_file(file_path: str, json_path: str, key_prefix: str, backup_dir: Optional[str]) -> MigrationResult:
    original = _read_text(file_path)
    content = original

    data = _load_json(json_path)
    next_idx = _next_key_index(data, key_prefix)

    keys_added = 0
    calls_migrated = 0
    skipped_calls = 0

    # Find tr( occurrences
    positions: List[int] = []
    start = 0
    while True:
        idx = content.find("tr", start)
        if idx == -1:
            break
        # ensure word boundary
        before = content[idx - 1] if idx > 0 else ""
        after = content[idx + 2] if idx + 2 < len(content) else ""
        if (before.isalnum() or before == "_"):
            start = idx + 2
            continue
        j = idx + 2
        while j < len(content) and content[j].isspace():
            j += 1
        if j < len(content) and content[j] == "(":
            positions.append(j)  # store '(' position
        start = idx + 2

    # Process from end
    positions.sort(reverse=True)

    for open_paren in positions:
        close_idx = _scan_matching_paren(content, open_paren)
        if close_idx is None:
            skipped_calls += 1
            continue

        # Find the 'tr' token start
        tr_idx = content.rfind("tr", 0, open_paren)
        if tr_idx == -1:
            skipped_calls += 1
            continue

        args_str = content[open_paren + 1 : close_idx]
        args = _split_top_level_args(args_str)
        if not args:
            skipped_calls += 1
            continue

        first = args[0].strip()
        raw = _extract_string_literal(first)
        if raw is None:
            skipped_calls += 1
            continue

        # If it already looks like a semantic key, keep it
        if _looks_like_key(raw):
            continue

        key = f"{key_prefix}.tr_{next_idx}"
        next_idx += 1

        if key not in data:
            data[key] = raw
            keys_added += 1

        # Replace first arg with key literal, preserve other args
        new_args = [f'"{key}"'] + [a.strip() for a in args[1:]]
        new_call = "tr(" + ", ".join(new_args) + ")"

        old_call = content[tr_idx : close_idx + 1]
        content = content[:tr_idx] + new_call + content[close_idx + 1 :]
        calls_migrated += 1

    file_changed = content != original
    if file_changed:
        if backup_dir:
            os.makedirs(backup_dir, exist_ok=True)
            backup_path = os.path.join(backup_dir, os.path.basename(file_path) + ".bak")
            if not os.path.exists(backup_path):
                _write_text_atomic(backup_path, original)
        _write_text_atomic(file_path, content)

    if keys_added > 0:
        _save_json(json_path, data)

    return MigrationResult(
        keys_added=keys_added,
        calls_migrated=calls_migrated,
        file_changed=file_changed,
        skipped_calls=skipped_calls,
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True)
    ap.add_argument("--json", required=True, dest="json_path")
    ap.add_argument("--key-prefix", required=True)
    ap.add_argument("--backup-dir", default="")
    args = ap.parse_args()

    res = migrate_file(args.file, args.json_path, args.key_prefix, args.backup_dir or None)

    print(
        f"__MIGRATE_RESULT__ keys_added={res.keys_added} calls_migrated={res.calls_migrated} "
        f"file_changed={1 if res.file_changed else 0} skipped_calls={res.skipped_calls}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
