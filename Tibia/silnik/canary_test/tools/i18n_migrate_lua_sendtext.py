#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class MigrationResult:
    keys_added: int
    calls_migrated: int
    file_changed: bool
    skipped_calls: int


def _read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def _write_text_atomic(path: str, content: str) -> None:
    original_mode = None
    try:
        original_mode = os.stat(path).st_mode & 0o777
    except FileNotFoundError:
        original_mode = None
    tmp_path = f"{path}.tmp"
    with open(tmp_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
    if original_mode is not None:
        try:
            os.chmod(tmp_path, original_mode)
        except Exception:
            pass
    os.replace(tmp_path, path)
    if original_mode is not None:
        try:
            os.chmod(path, original_mode)
        except Exception:
            pass


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
    # keep stable order for diffs
    data_sorted = dict(sorted(data.items(), key=lambda kv: kv[0]))
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data_sorted, f, indent=2, ensure_ascii=False)


def _is_comment_call(content: str, idx: int) -> bool:
    """Best-effort: ignore matches on lines where '--' appears before idx."""
    line_start = content.rfind("\n", 0, idx) + 1
    before = content[line_start:idx]
    # strip string literals in the prefix is hard; keep simple
    comment_pos = before.find("--")
    return comment_pos != -1


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


_STRING_LITERAL_RE = re.compile(
    r"^(?P<q>['\"])(?P<body>(?:\\.|(?!\1).)*)\1$",
    re.DOTALL,
)


def _unescape_lua_string(s: str) -> str:
    # Keep conservative: only common escapes.
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


_FMT_SPEC_RE = re.compile(r"%(?:[0-9#+\-\.]*)(?:[diuoxXfFeEgGaAcsp])")


def _printf_to_fmt(s: str) -> str:
    # Handle '%%' first (literal %)
    s = s.replace("%%", "%")
    # Replace common printf specs with {}
    return _FMT_SPEC_RE.sub("{}", s)


def _strip_wrapping_parens(expr: str) -> str:
    expr = expr.strip()
    while expr.startswith("(") and expr.endswith(")"):
        end = _scan_matching_paren(expr, 0)
        if end != len(expr) - 1:
            break
        expr = expr[1:-1].strip()
    return expr


def _split_concat(expr: str) -> List[str]:
    expr = expr.strip()
    if not expr:
        return []

    parts: List[str] = []
    buf: List[str] = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str: Optional[str] = None
    esc = False
    i = 0

    while i < len(expr):
        ch = expr[i]
        if in_str:
            buf.append(ch)
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
            buf.append(ch)
            i += 1
            continue

        if ch == "(":
            depth_paren += 1
            buf.append(ch)
            i += 1
            continue
        if ch == ")":
            depth_paren = max(0, depth_paren - 1)
            buf.append(ch)
            i += 1
            continue
        if ch == "{":
            depth_brace += 1
            buf.append(ch)
            i += 1
            continue
        if ch == "}":
            depth_brace = max(0, depth_brace - 1)
            buf.append(ch)
            i += 1
            continue
        if ch == "[":
            depth_bracket += 1
            buf.append(ch)
            i += 1
            continue
        if ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
            buf.append(ch)
            i += 1
            continue

        if (
            ch == "."
            and i + 1 < len(expr)
            and expr[i + 1] == "."
            and depth_paren == 0
            and depth_brace == 0
            and depth_bracket == 0
        ):
            part = "".join(buf).strip()
            if part:
                parts.append(part)
            buf = []
            i += 2
            continue

        buf.append(ch)
        i += 1

    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return parts


def _has_top_level_bool_or_compare(expr: str) -> bool:
    expr = expr.strip()
    if not expr:
        return False

    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str: Optional[str] = None
    esc = False
    i = 0

    while i < len(expr):
        ch = expr[i]
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
            depth_paren += 1
            i += 1
            continue
        if ch == ")":
            depth_paren = max(0, depth_paren - 1)
            i += 1
            continue
        if ch == "{":
            depth_brace += 1
            i += 1
            continue
        if ch == "}":
            depth_brace = max(0, depth_brace - 1)
            i += 1
            continue
        if ch == "[":
            depth_bracket += 1
            i += 1
            continue
        if ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
            i += 1
            continue

        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            if expr.startswith("==", i) or expr.startswith("~=", i) or expr.startswith("<=", i) or expr.startswith(">=", i):
                return True
            if ch == "<" or ch == ">":
                return True
            if expr.startswith("and", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 3] if i + 3 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
            if expr.startswith("or", i):
                prev = expr[i - 1] if i > 0 else " "
                nxt = expr[i + 2] if i + 2 < len(expr) else " "
                if not (prev.isalnum() or prev == "_") and not (nxt.isalnum() or nxt == "_"):
                    return True
        i += 1
    return False


def _parse_string_format(expr: str) -> Optional[dict]:
    expr = _strip_wrapping_parens(expr)
    m = re.match(r"^string\.format\s*\((.*)\)\s*$", expr, re.DOTALL)
    if not m:
        return None
    inner = m.group(1)
    fmt_parts = _split_top_level_args(inner)
    if not fmt_parts:
        return None
    fmt_literal = _extract_string_literal(fmt_parts[0])
    if fmt_literal is None:
        return None
    return {
        "text": _printf_to_fmt(fmt_literal),
        "args": [p.strip() for p in fmt_parts[1:] if p.strip()],
        "kind": "format",
    }


def _parse_concat(expr: str) -> Optional[dict]:
    expr = _strip_wrapping_parens(expr)
    if _has_top_level_bool_or_compare(expr):
        return None
    parts = _split_concat(expr)
    if len(parts) <= 1:
        return None
    text_parts: List[str] = []
    args: List[str] = []
    literal_seen = False
    for part in parts:
        lit = _extract_string_literal(part)
        if lit is not None:
            text_parts.append(lit)
            literal_seen = True
        else:
            text_parts.append("{}")
            args.append(part.strip())
    if not literal_seen:
        return None
    return {"text": "".join(text_parts), "args": args, "kind": "concat"}


def _parse_message_expr(expr: str) -> Optional[dict]:
    expr = expr.strip()
    if not expr:
        return None
    literal = _extract_string_literal(expr)
    if literal is not None:
        return {"text": literal, "args": [], "kind": "literal"}
    fmt = _parse_string_format(expr)
    if fmt:
        return fmt
    concat = _parse_concat(expr)
    if concat:
        return concat
    return None


def _normalize_text(text: str) -> str:
    text = re.sub(r"\\z\s*", "", text)
    text = text.replace("\n", " ").replace("\r", " ").replace("\t", " ")
    return " ".join(text.split())


def _next_key_index(existing: dict, key_prefix: str) -> int:
    # key_prefix like 'scripts.foo'
    pat = re.compile(rf"^{re.escape(key_prefix)}\.msg_(\d+)$")
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

    # Find both :sendTextMessage( and .sendTextMessage(
    needles = [":sendTextMessage", ".sendTextMessage"]
    positions: List[Tuple[int, str]] = []
    for n in needles:
        start = 0
        while True:
            idx = content.find(n, start)
            if idx == -1:
                break
            positions.append((idx, n))
            start = idx + len(n)

    # Process from end so indices remain valid when replacing
    positions.sort(key=lambda t: t[0], reverse=True)

    for idx, needle in positions:
        if _is_comment_call(content, idx):
            skipped_calls += 1
            continue

        # Find '(' after the needle
        p = idx + len(needle)
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != "(":
            skipped_calls += 1
            continue

        close_idx = _scan_matching_paren(content, p)
        if close_idx is None:
            skipped_calls += 1
            continue

        args_str = content[p + 1 : close_idx]
        args = _split_top_level_args(args_str)
        if len(args) < 2:
            skipped_calls += 1
            continue

        type_expr = args[0].strip()
        msg_expr = args[1].strip()

        msg_info = _parse_message_expr(msg_expr)
        if not msg_info:
            skipped_calls += 1
            continue

        translation = _normalize_text(msg_info["text"])
        fmt_args: List[str] = list(msg_info.get("args") or [])
        if not translation:
            skipped_calls += 1
            continue

        # Generate key
        key = f"{key_prefix}.msg_{next_idx}"
        next_idx += 1

        if key not in data:
            data[key] = translation
            keys_added += 1

        # Build replacement call
        if fmt_args:
            args_table = "{" + ", ".join(fmt_args) + "}"
            new_call = f"{needle.replace('sendTextMessage', 'sendLocalizedTextMessage')}({type_expr}, \"{key}\", {args_table})"
        else:
            new_call = f"{needle.replace('sendTextMessage', 'sendLocalizedTextMessage')}({type_expr}, \"{key}\")"

        # Replace whole call "<needle>(... )" including parens
        old_call = content[idx : close_idx + 1]
        content = content[:idx] + new_call + content[close_idx + 1 :]
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

    backup_dir = args.backup_dir or None

    res = migrate_file(args.file, args.json_path, args.key_prefix, backup_dir)

    # machine-readable line for bash
    print(
        f"__MIGRATE_RESULT__ keys_added={res.keys_added} calls_migrated={res.calls_migrated} "
        f"file_changed={1 if res.file_changed else 0} skipped_calls={res.skipped_calls}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
