#!/usr/bin/env python3
import argparse
import json
import os
import re
from typing import List, Optional, Tuple


STRING_LITERAL_RE = re.compile(
    r"^(?P<q>['\"])(?P<body>(?:\\.|(?!\1).)*)\1$",
    re.DOTALL,
)
FMT_SPEC_RE = re.compile(r"%(?:[0-9#+\-\.]*)(?:[diuoxXfFeEgGaAcsp])")
KEYWORD_RE = re.compile(r"\{([A-Za-z_][A-Za-z0-9_]*)\}")
FMT_PLACEHOLDER_RE = re.compile(r"\{(?:\d+)?(?:[:][^{}]+)?\}")


def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def load_json(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        payload = json.load(f)
    return payload if isinstance(payload, dict) else {}


def scan_matching_paren(content: str, open_idx: int) -> Optional[int]:
    depth = 1
    i = open_idx + 1
    in_str = None
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
        if ch in ("'", '"'):
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


def strip_wrapping_parens(expr: str) -> str:
    expr = expr.strip()
    while expr.startswith("(") and expr.endswith(")"):
        close_idx = scan_matching_paren(expr, 0)
        if close_idx == len(expr) - 1:
            expr = expr[1:-1].strip()
        else:
            break
    return expr


def split_top_level_args(arg_str: str) -> List[str]:
    args: List[str] = []
    buf: List[str] = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
    esc = False

    i = 0
    while i < len(arg_str):
        ch = arg_str[i]
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
        if ch in ("'", '"'):
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if ch == "," and depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            args.append("".join(buf).strip())
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1

    tail = "".join(buf).strip()
    if tail:
        args.append(tail)
    return args


def split_concat(expr: str) -> List[str]:
    parts: List[str] = []
    buf: List[str] = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    in_str = None
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
        if ch in ("'", '"'):
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch == "(":
            depth_paren += 1
        elif ch == ")":
            depth_paren = max(0, depth_paren - 1)
        elif ch == "{":
            depth_brace += 1
        elif ch == "}":
            depth_brace = max(0, depth_brace - 1)
        elif ch == "[":
            depth_bracket += 1
        elif ch == "]":
            depth_bracket = max(0, depth_bracket - 1)
        if depth_paren == 0 and depth_brace == 0 and depth_bracket == 0 and ch == ".":
            if i + 1 < len(expr) and expr[i + 1] == "." and not (i + 2 < len(expr) and expr[i + 2] == "."):
                parts.append("".join(buf).strip())
                buf = []
                i += 2
                continue
        buf.append(ch)
        i += 1

    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return [p for p in parts if p]


def extract_string_literal(expr: str) -> Optional[str]:
    expr = strip_wrapping_parens(expr)
    m = STRING_LITERAL_RE.match(expr)
    if not m:
        return None
    s = m.group("body")
    s = s.replace("\\z", "")
    s = s.replace('\\"', '"').replace("\\'", "'")
    s = s.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t")
    s = s.replace("\\\\", "\\")
    return s


def normalize_text(text: str) -> str:
    text = re.sub(r"\\z\s*", "", text)
    text = text.replace("\\n", " ").replace("\\r", " ").replace("\\t", " ")
    return " ".join(text.split())


def parse_string_format(expr: str) -> Optional[str]:
    expr = strip_wrapping_parens(expr)
    m = re.match(r"^string\.format\s*\((.*)\)\s*$", expr, re.DOTALL)
    if not m:
        return None
    parts = split_top_level_args(m.group(1))
    if not parts:
        return None
    fmt_literal = extract_string_literal(parts[0])
    if fmt_literal is None:
        return None
    return FMT_SPEC_RE.sub("{}", fmt_literal.replace("%%", "%"))


def parse_concat(expr: str) -> Optional[str]:
    expr = strip_wrapping_parens(expr)
    parts = split_concat(expr)
    if len(parts) <= 1:
        return None
    out: List[str] = []
    has_literal = False
    for part in parts:
        lit = extract_string_literal(part)
        if lit is None:
            out.append("{}")
        else:
            out.append(lit)
            has_literal = True
    if not has_literal:
        return None
    return "".join(out)


def parse_message_expr(expr: str) -> Optional[str]:
    expr = expr.strip()
    if not expr:
        return None
    lit = extract_string_literal(expr)
    if lit is not None:
        return lit
    fmt = parse_string_format(expr)
    if fmt is not None:
        return fmt
    return parse_concat(expr)


def is_comment_call(content: str, idx: int) -> bool:
    line_start = content.rfind("\n", 0, idx) + 1
    return "--" in content[line_start:idx]


def parse_table_expr(expr: str) -> Optional[List[str]]:
    expr = expr.strip()
    if not (expr.startswith("{") and expr.endswith("}")):
        return None
    inner = expr[1:-1].strip()
    elems = [e.strip() for e in split_top_level_args(inner) if e.strip()]
    if len(elems) >= 3 and elems[-3] == "npc" and elems[-2] in ("creature", "player"):
        elems = elems[:-3]
    elif len(elems) >= 2 and elems[-2] == "npc" and elems[-1] in ("creature", "player"):
        elems = elems[:-2]
    return elems


def collect_original_npcsay_messages(content: str) -> List[str]:
    out: List[str] = []
    needle = "npcHandler:say"
    start = 0
    while True:
        idx = content.find(needle, start)
        if idx == -1:
            break
        start = idx + len(needle)
        if is_comment_call(content, idx):
            continue
        p = start
        while p < len(content) and content[p].isspace():
            p += 1
        if p >= len(content) or content[p] != "(":
            continue
        close_idx = scan_matching_paren(content, p)
        if close_idx is None:
            continue
        args = split_top_level_args(content[p + 1 : close_idx])
        if not args:
            continue
        msg_expr = args[0].strip()
        table_entries = parse_table_expr(msg_expr)
        if table_entries is not None:
            for elem in table_entries:
                parsed = parse_message_expr(elem)
                if parsed is None:
                    continue
                normalized = normalize_text(parsed)
                if normalized:
                    out.append(normalized)
            continue
        parsed = parse_message_expr(msg_expr)
        if parsed is None:
            continue
        normalized = normalize_text(parsed)
        if normalized:
            out.append(normalized)
    return out


def key_matches_scope(key: str, npc_safe: str, key_scope: str) -> bool:
    if key_scope == "all_npc_keys":
        return key.startswith(f"npc.{npc_safe}.")
    return key.startswith(f"npc.{npc_safe}.say_")


def collect_migrated_npcsay_keys(content: str, npc_safe: str, key_scope: str) -> List[str]:
    calls: List[Tuple[int, str, int, int]] = []
    patterns = [
        ("NPC_LIB.i18n.npcSayMultiple", "multiple"),
        ("NPC_LIB.i18n.npcSay", "single"),
    ]
    for needle, kind in patterns:
        start = 0
        while True:
            idx = content.find(needle, start)
            if idx == -1:
                break
            p = idx + len(needle)
            while p < len(content) and content[p].isspace():
                p += 1
            if p >= len(content) or content[p] != "(":
                start = idx + len(needle)
                continue
            close_idx = scan_matching_paren(content, p)
            if close_idx is None:
                start = idx + len(needle)
                continue
            calls.append((idx, kind, p, close_idx))
            start = close_idx + 1

    out: List[str] = []
    for _, kind, p, close_idx in sorted(calls, key=lambda x: x[0]):
        args = split_top_level_args(content[p + 1 : close_idx])
        if kind == "single":
            if len(args) < 4:
                continue
            key = extract_string_literal(args[3])
            if key and key_matches_scope(key, npc_safe, key_scope):
                out.append(key)
            continue

        if len(args) < 4:
            continue
        table_expr = args[3].strip()
        if not (table_expr.startswith("{") and table_expr.endswith("}")):
            continue
        entries = split_top_level_args(table_expr[1:-1].strip())
        for entry in entries:
            entry = entry.strip()
            key = extract_string_literal(entry)
            if key and key_matches_scope(key, npc_safe, key_scope):
                out.append(key)
                continue
            if entry.startswith("{") and entry.endswith("}"):
                inner = split_top_level_args(entry[1:-1].strip())
                if inner:
                    key = extract_string_literal(inner[0])
                    if key and key_matches_scope(key, npc_safe, key_scope):
                        out.append(key)
    return out


def count_args_table(expr: str) -> Optional[int]:
    expr = expr.strip()
    if not (expr.startswith("{") and expr.endswith("}")):
        return None
    inner = expr[1:-1].strip()
    if not inner:
        return 0
    return len([e for e in split_top_level_args(inner) if e.strip()])


def collect_migrated_key_argpairs(
    content: str,
    npc_safe: str,
    key_scope: str,
) -> List[Tuple[str, Optional[int]]]:
    calls: List[Tuple[int, str, int, int]] = []
    patterns = [
        ("NPC_LIB.i18n.npcSayMultiple", "multiple"),
        ("NPC_LIB.i18n.npcSay", "single"),
    ]
    for needle, kind in patterns:
        start = 0
        while True:
            idx = content.find(needle, start)
            if idx == -1:
                break
            p = idx + len(needle)
            while p < len(content) and content[p].isspace():
                p += 1
            if p >= len(content) or content[p] != "(":
                start = idx + len(needle)
                continue
            close_idx = scan_matching_paren(content, p)
            if close_idx is None:
                start = idx + len(needle)
                continue
            calls.append((idx, kind, p, close_idx))
            start = close_idx + 1

    out: List[Tuple[str, Optional[int]]] = []
    for _, kind, p, close_idx in sorted(calls, key=lambda x: x[0]):
        args = split_top_level_args(content[p + 1 : close_idx])
        if kind == "single":
            if len(args) < 4:
                continue
            key = extract_string_literal(args[3])
            if not key or not key_matches_scope(key, npc_safe, key_scope):
                continue
            argc: Optional[int] = 0
            if len(args) >= 5:
                argc = count_args_table(args[4])
            out.append((key, argc))
            continue

        if len(args) < 4:
            continue
        table_expr = args[3].strip()
        if not (table_expr.startswith("{") and table_expr.endswith("}")):
            continue

        shared_argc: Optional[int] = 0
        if len(args) >= 6:
            shared_argc = count_args_table(args[5])

        entries = split_top_level_args(table_expr[1:-1].strip())
        for entry in entries:
            entry = entry.strip()
            key = extract_string_literal(entry)
            if key is not None and key_matches_scope(key, npc_safe, key_scope):
                out.append((key, shared_argc))
                continue
            if not (entry.startswith("{") and entry.endswith("}")):
                continue
            inner = split_top_level_args(entry[1:-1].strip())
            if not inner:
                continue
            key = extract_string_literal(inner[0])
            if not key or not key_matches_scope(key, npc_safe, key_scope):
                continue
            argc = shared_argc
            if len(inner) >= 2:
                argc = count_args_table(inner[1])
            out.append((key, argc))

    return out


def count_placeholders(text: str) -> int:
    # fmt placeholders: {}, {0}, {1:.2f}, {:d}; ignore NPC keywords like {trade}
    normalized = text.replace("{{", "").replace("}}", "")
    return len(FMT_PLACEHOLDER_RE.findall(normalized))


def extract_keywords(text: str) -> List[str]:
    return sorted(set(KEYWORD_RE.findall(text)))


def canonicalize_for_text_compare(text: str) -> str:
    # Treat {} and {0}/{1:.2f} as semantically equivalent.
    collapsed = FMT_PLACEHOLDER_RE.sub("{}", text)
    return " ".join(collapsed.split())


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit mapowania migracji NPC i18n")
    parser.add_argument("--backup", required=True, help="Backup NPC przed migracją")
    parser.add_argument("--migrated", required=True, help="Plik NPC po migracji")
    parser.add_argument("--en-json", required=True, help="i18n/en/npc.json")
    parser.add_argument(
        "--en-json-before",
        default="",
        help="Snapshot en/npc.json sprzed migracji (do odfiltrowania starych kluczy)",
    )
    parser.add_argument("--npc-safe", required=True, help="Slug NPC (np. oressa)")
    parser.add_argument(
        "--key-scope",
        choices=["say_only", "all_npc_keys"],
        default="say_only",
        help="Zakres kluczy NPC branych do audytu",
    )
    parser.add_argument("--report", default="", help="Ścieżka raportu JSON")
    args = parser.parse_args()

    errors: List[str] = []
    warnings: List[str] = []

    if not os.path.exists(args.backup):
        errors.append(f"Brak backupu: {args.backup}")
    if not os.path.exists(args.migrated):
        errors.append(f"Brak pliku po migracji: {args.migrated}")
    if not os.path.exists(args.en_json):
        errors.append(f"Brak EN JSON: {args.en_json}")
    if errors:
        report = {"ok": False, "errors": errors, "warnings": warnings, "stats": {}}
        if args.report:
            os.makedirs(os.path.dirname(args.report), exist_ok=True)
            with open(args.report, "w", encoding="utf-8") as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
        for e in errors:
            print(f"ERROR: {e}")
        return 1

    backup_content = read_text(args.backup)
    migrated_content = read_text(args.migrated)
    en_data = load_json(args.en_json)
    before_data = {}
    if args.en_json_before and os.path.exists(args.en_json_before):
        try:
            before_data = load_json(args.en_json_before)
        except Exception:
            before_data = {}
    before_keys = set(before_data.keys())

    original_msgs = collect_original_npcsay_messages(backup_content)
    all_migrated_keys = collect_migrated_npcsay_keys(migrated_content, args.npc_safe, args.key_scope)
    migrated_keys = all_migrated_keys
    use_before_filter = False
    if before_keys:
        filtered_keys = [k for k in all_migrated_keys if k not in before_keys]
        if filtered_keys:
            migrated_keys = filtered_keys
            use_before_filter = True
        else:
            warnings.append(
                "Brak nowych kluczy po filtrze --en-json-before; fallback do pełnej walidacji istniejących kluczy."
            )

    missing_keys = 0
    mismatch_text = 0
    placeholder_mismatch = 0
    keyword_mismatch = 0
    runtime_placeholder_mismatch = 0
    runtime_pairs_checked = 0
    bad_escape_z = 0
    empty_values = 0

    message_count_mismatch = abs(len(original_msgs) - len(migrated_keys))
    if len(original_msgs) != len(migrated_keys):
        errors.append(
            f"Mismatch liczby wiadomości npcHandler:say: backup={len(original_msgs)} migrated_keys={len(migrated_keys)}"
        )

    pair_count = min(len(original_msgs), len(migrated_keys))
    for i in range(pair_count):
        key = migrated_keys[i]
        expected = original_msgs[i]
        value = en_data.get(key)
        if value is None:
            missing_keys += 1
            errors.append(f"Brak klucza w EN JSON: {key}")
            continue
        if not isinstance(value, str):
            missing_keys += 1
            errors.append(f"Wartość EN nie jest stringiem: {key}")
            continue
        if "\\z" in value:
            bad_escape_z += 1
            errors.append(f"Niedozwolone \\z w EN JSON: {key}")
        normalized = normalize_text(value)
        if not normalized:
            empty_values += 1
            errors.append(f"Pusta wartość EN po normalizacji: {key}")
            continue
        if canonicalize_for_text_compare(normalized) != canonicalize_for_text_compare(expected):
            mismatch_text += 1
            errors.append(f"Rozjazd mapowania tekstu: {key}")
        if count_placeholders(normalized) != count_placeholders(expected):
            placeholder_mismatch += 1
            errors.append(f"Rozjazd placeholderów {{}}: {key}")
        if extract_keywords(normalized) != extract_keywords(expected):
            keyword_mismatch += 1
            errors.append(f"Rozjazd keywordów {{keyword}}: {key}")

    # Dodatkowy audit runtime: liczba argumentów w npcSay/npcSayMultiple vs placeholders w EN.
    for key, argc in collect_migrated_key_argpairs(migrated_content, args.npc_safe, args.key_scope):
        if use_before_filter and key in before_keys:
            continue
        if argc is None:
            continue
        value = en_data.get(key)
        if not isinstance(value, str):
            continue
        normalized = normalize_text(value)
        ph = count_placeholders(normalized)
        runtime_pairs_checked += 1
        # Nadmiar args jest akceptowalny (fmt ignoruje nieużyte argumenty).
        if ph > argc:
            runtime_placeholder_mismatch += 1
            errors.append(f"Runtime placeholder mismatch: {key} placeholders={ph} args={argc}")

    stats = {
        "original_say_messages": len(original_msgs),
        "migrated_say_keys": len(migrated_keys),
        "message_count_mismatch": message_count_mismatch,
        "key_scope": args.key_scope,
        "checked_pairs": pair_count,
        "missing_keys": missing_keys,
        "mismatch_text": mismatch_text,
        "placeholder_mismatch": placeholder_mismatch,
        "keyword_mismatch": keyword_mismatch,
        "runtime_pairs_checked": runtime_pairs_checked,
        "runtime_placeholder_mismatch": runtime_placeholder_mismatch,
        "bad_escape_z": bad_escape_z,
        "empty_values": empty_values,
    }

    report = {"ok": len(errors) == 0, "errors": errors, "warnings": warnings, "stats": stats}
    if args.report:
        os.makedirs(os.path.dirname(args.report), exist_ok=True)
        with open(args.report, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

    if errors:
        print(
            "AUDIT_FAIL "
            + " ".join(
                [
                    f"pairs={pair_count}",
                    f"missing={missing_keys}",
                    f"mismatch={mismatch_text}",
                    f"placeholder={placeholder_mismatch}",
                    f"keyword={keyword_mismatch}",
                    f"runtime={runtime_placeholder_mismatch}",
                    f"bad_z={bad_escape_z}",
                ]
            )
        )
        return 1

    print(f"AUDIT_OK pairs={pair_count} keys={len(migrated_keys)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
