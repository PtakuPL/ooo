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

_FMT_SPEC_RE = re.compile(r"%(?:[0-9#+\-\.]*)(?:[diuoxXfFeEgGaAcsp])")


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


def _is_comment_call(content: str, idx: int) -> bool:
    line_start = content.rfind("\n", 0, idx) + 1
    before = content[line_start:idx]
    return before.find("--") != -1


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


def _printf_to_braces(s: str) -> str:
    # Keep conservative: map printf-like to '{}' for client+server shared keys.
    s = s.replace("%%", "%")
    return _FMT_SPEC_RE.sub("{}", s)


def _next_key_index(existing: dict, key_prefix: str, suffix: str) -> int:
    pat = re.compile(rf"^{re.escape(key_prefix)}\.{re.escape(suffix)}_(\d+)$")
    max_idx = 0
    for k in existing.keys():
        m = pat.match(k)
        if m:
            try:
                max_idx = max(max_idx, int(m.group(1)))
            except ValueError:
                pass
    return max_idx + 1


def migrate_file(
    file_path: str,
    json_path: str,
    key_prefix: str,
    backup_dir: Optional[str],
    target: str,
    suffix: str,
) -> MigrationResult:
    original = _read_text(file_path)
    content = original

    data = _load_json(json_path)
    next_idx = _next_key_index(data, key_prefix, suffix)

    keys_added = 0
    calls_migrated = 0
    skipped_calls = 0

    # Only rewrite colon calls (safer for Lua semantics)
    if target == "npc_handler":
        needles = ["npcHandler:say"]
    else:
        needles = [":say"]

    positions: List[Tuple[int, str]] = []
    for n in needles:
        start = 0
        while True:
            idx = content.find(n, start)
            if idx == -1:
                break
            # Avoid migrating already-localized calls
            if content.startswith("npcHandler:sayLocalized", idx) or content.startswith(":sayLocalized", idx):
                start = idx + len(n)
                continue
            positions.append((idx, n))
            start = idx + len(n)

    positions.sort(key=lambda t: t[0], reverse=True)

    for idx, needle in positions:
        if _is_comment_call(content, idx):
            skipped_calls += 1
            continue

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
        if not args:
            skipped_calls += 1
            continue

        msg_expr = args[0].strip()

        raw_text = _extract_string_literal(msg_expr)
        fmt_args: List[str] = []

        if raw_text is not None:
            translation = raw_text
        else:
            m = re.match(r"^string\.format\s*\((.*)\)\s*$", msg_expr, re.DOTALL)
            if not m:
                skipped_calls += 1
                continue
            inner = m.group(1)
            fmt_parts = _split_top_level_args(inner)
            if not fmt_parts:
                skipped_calls += 1
                continue
            fmt_literal = _extract_string_literal(fmt_parts[0])
            if fmt_literal is None:
                skipped_calls += 1
                continue
            translation = _printf_to_braces(fmt_literal)
            fmt_args = [p.strip() for p in fmt_parts[1:] if p.strip()]

        key = f"{key_prefix}.{suffix}_{next_idx}"
        next_idx += 1

        if key not in data:
            data[key] = translation
            keys_added += 1

        if target == "npc_handler":
            # npcHandler:say(message, npc, player, delay, textType)
            # -> npcHandler:sayLocalized(key, npc, player, args, delay, textType)
            # args slot must exist if delay/textType are present.
            if len(args) < 3:
                skipped_calls += 1
                continue
            npc_expr = args[1].strip()
            player_expr = args[2].strip()
            tail = [a.strip() for a in args[3:]]  # delay, textType

            new_args: List[str] = [f"\"{key}\"", npc_expr, player_expr]
            if fmt_args:
                new_args.append("{" + ", ".join(fmt_args) + "}")
            elif tail:
                new_args.append("nil")
            new_args.extend(tail)

            new_call = f"npcHandler:sayLocalized(" + ", ".join(new_args) + ")"
        else:
            # creature:say(text, type, ghost, target, position)
            # -> creature:sayLocalized(key, type, ghost, target, position, argsTable?)
            tail = [a.strip() for a in args[1:]]
            new_args = [f"\"{key}\""] + tail
            if fmt_args:
                new_args.append("{" + ", ".join(fmt_args) + "}")
            new_call = needle.replace(":say", ":sayLocalized") + "(" + ", ".join(new_args) + ")"

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
    ap.add_argument("--target", choices=["creature", "npc_handler"], default="creature")
    ap.add_argument("--suffix", default="say")
    args = ap.parse_args()

    res = migrate_file(
        file_path=args.file,
        json_path=args.json_path,
        key_prefix=args.key_prefix,
        backup_dir=args.backup_dir or None,
        target=args.target,
        suffix=args.suffix,
    )

    print(
        f"__MIGRATE_RESULT__ keys_added={res.keys_added} calls_migrated={res.calls_migrated} "
        f"file_changed={1 if res.file_changed else 0} skipped_calls={res.skipped_calls}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
