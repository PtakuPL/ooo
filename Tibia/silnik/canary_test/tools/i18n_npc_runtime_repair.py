#!/usr/bin/env python3
import argparse
import json
import os
import re
from difflib import SequenceMatcher
from typing import Dict, List, Optional, Tuple

from i18n_npc_migration_audit import (
    collect_original_npcsay_messages,
    extract_string_literal,
    normalize_text,
    scan_matching_paren,
    split_top_level_args,
)

FMT_PLACEHOLDER_RE = re.compile(r"\{(?:\d+)?(?:[:][^{}]+)?\}")
KEYWORD_RE = re.compile(r"\{([A-Za-z_][A-Za-z0-9_]*)\}")


def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def write_text(path: str, content: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def load_json(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        payload = json.load(f)
    return payload if isinstance(payload, dict) else {}


def save_json(path: str, payload: dict) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)


def collect_target_calls(content: str, npc_safe: str) -> List[dict]:
    patterns = [
        ("NPC_LIB.i18n.npcSayMultiple", "multiple"),
        ("NPC_LIB.i18n.npcSay", "single"),
    ]
    calls: List[Tuple[int, str, int, int, str]] = []
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
            args_str = content[p + 1 : close_idx]
            calls.append((idx, kind, p, close_idx, args_str))
            start = close_idx + 1

    prefix = f"npc.{npc_safe}."
    out: List[dict] = []
    def count_args_table(expr: str) -> Optional[int]:
        expr = expr.strip()
        if not (expr.startswith("{") and expr.endswith("}")):
            return None
        inner = expr[1:-1].strip()
        if not inner:
            return 0
        return len([x for x in split_top_level_args(inner) if x.strip()])

    for idx, kind, p, close_idx, args_str in sorted(calls, key=lambda x: x[0]):
        args = split_top_level_args(args_str)
        if len(args) < 4:
            continue

        if kind == "single":
            key = extract_string_literal(args[3])
            if not key or not key.startswith(prefix):
                continue
            argc = 0
            if len(args) >= 5:
                argc = count_args_table(args[4])
            entry = {"key": key, "new_key": key, "argc": argc if argc is not None else 0}
            out.append(
                {
                    "kind": kind,
                    "needle": "NPC_LIB.i18n.npcSay",
                    "start": idx,
                    "end": close_idx + 1,
                    "args": args,
                    "entries": [entry],
                    "table_items": [],
                }
            )
            continue

        table_expr = args[3].strip()
        if not (table_expr.startswith("{") and table_expr.endswith("}")):
            continue

        shared_argc = 0
        if len(args) >= 6:
            parsed = count_args_table(args[5])
            if parsed is not None:
                shared_argc = parsed

        table_items: List[dict] = []
        entries: List[dict] = []
        raw_entries = [e.strip() for e in split_top_level_args(table_expr[1:-1].strip()) if e.strip()]
        for raw in raw_entries:
            key = extract_string_literal(raw)
            if key is not None and key.startswith(prefix):
                entry = {"key": key, "new_key": key, "argc": shared_argc}
                entries.append(entry)
                table_items.append({"raw": raw, "tracked": True, "mode": "literal", "entry": entry, "rest": []})
                continue

            if raw.startswith("{") and raw.endswith("}"):
                inner = [x.strip() for x in split_top_level_args(raw[1:-1].strip()) if x.strip()]
                if inner:
                    key = extract_string_literal(inner[0])
                    if key is not None and key.startswith(prefix):
                        argc = shared_argc
                        if len(inner) >= 2:
                            parsed = count_args_table(inner[1])
                            if parsed is not None:
                                argc = parsed
                        entry = {"key": key, "new_key": key, "argc": argc}
                        entries.append(entry)
                        table_items.append(
                            {
                                "raw": raw,
                                "tracked": True,
                                "mode": "tuple",
                                "entry": entry,
                                "rest": inner[1:],
                            }
                        )
                        continue

            table_items.append({"raw": raw, "tracked": False, "mode": "raw", "entry": None, "rest": []})

        if not entries:
            continue

        out.append(
            {
                "kind": kind,
                "needle": "NPC_LIB.i18n.npcSayMultiple",
                "start": idx,
                "end": close_idx + 1,
                "args": args,
                "entries": entries,
                "table_items": table_items,
            }
        )

    return out


def next_say_index(en_data: dict, npc_safe: str) -> int:
    pat = re.compile(rf"^npc\.{re.escape(npc_safe)}\.say_(\d+)$")
    out = 0
    for key in en_data.keys():
        m = pat.match(str(key))
        if not m:
            continue
        try:
            out = max(out, int(m.group(1)))
        except Exception:
            continue
    return out


def placeholder_count(text: str) -> int:
    normalized = text.replace("{{", "").replace("}}", "")
    return len(FMT_PLACEHOLDER_RE.findall(normalized))


def normalize_placeholders(text: str) -> str:
    return FMT_PLACEHOLDER_RE.sub("{}", text)


def extract_keywords(text: str) -> set:
    return set(KEYWORD_RE.findall(text))


def sanitize_text_for_argc(text: str, argc: int) -> str:
    if placeholder_count(text) <= argc:
        return text
    out = text
    while placeholder_count(out) > argc:
        out = FMT_PLACEHOLDER_RE.sub("", out, count=1)
    out = out.replace("[]", "")
    out = out.replace("( )", "()")
    out = " ".join(out.split())
    out = re.sub(r"\s+([,.;!?])", r"\1", out)
    return out.strip()


def pair_cost(src: str, tgt: str, tgt_argc: int) -> float:
    src_norm = normalize_placeholders(src)
    tgt_norm = normalize_placeholders(tgt)

    if src_norm == tgt_norm:
        src_ph = placeholder_count(src_norm)
        if src_ph > tgt_argc:
            return (src_ph - tgt_argc) * 6.0
        return 0.0

    src_ph = placeholder_count(src_norm)
    tgt_ph = placeholder_count(tgt_norm)
    ph_penalty = abs(src_ph - tgt_ph) * 2.0
    argc_penalty = max(0, src_ph - tgt_argc) * 6.0
    sim = SequenceMatcher(None, src_norm, tgt_norm).ratio()
    sim_penalty = (1.0 - sim) * 2.0
    return ph_penalty + argc_penalty + sim_penalty


def align_sequences(source_msgs: List[str], target_msgs: List[str], target_argc: List[int]) -> List[Tuple[int, int]]:
    m = len(source_msgs)
    n = len(target_msgs)
    if m == 0 or n == 0:
        return []

    # Prefer full 1:1 remap whenever source and target have equal cardinality.
    if m == n:
        skip_source = 12.0
        skip_target = 12.0
    else:
        skip_source = 4.0
        skip_target = 4.5
    inf = 10**18

    dp = [[inf] * (n + 1) for _ in range(m + 1)]
    bt: List[List[Optional[Tuple[int, int, str]]]] = [[None] * (n + 1) for _ in range(m + 1)]
    dp[0][0] = 0.0

    for i in range(m + 1):
        for j in range(n + 1):
            cur = dp[i][j]
            if cur >= inf:
                continue
            if i < m and j < n:
                c = cur + pair_cost(source_msgs[i], target_msgs[j], target_argc[j])
                if c < dp[i + 1][j + 1]:
                    dp[i + 1][j + 1] = c
                    bt[i + 1][j + 1] = (i, j, "pair")
            if i < m:
                c = cur + skip_source
                if c < dp[i + 1][j]:
                    dp[i + 1][j] = c
                    bt[i + 1][j] = (i, j, "skip_source")
            if j < n:
                c = cur + skip_target
                if c < dp[i][j + 1]:
                    dp[i][j + 1] = c
                    bt[i][j + 1] = (i, j, "skip_target")

    i, j = m, n
    pairs_rev: List[Tuple[int, int]] = []
    while i > 0 or j > 0:
        prev = bt[i][j]
        if prev is None:
            break
        pi, pj, op = prev
        if op == "pair":
            pairs_rev.append((pi, pj))
        i, j = pi, pj
    pairs_rev.reverse()
    return pairs_rev


def repair_mapping(
    source_content: str,
    target_content: str,
    en_data: dict,
    npc_safe: str,
) -> Tuple[str, dict, dict]:
    source_msgs = collect_original_npcsay_messages(source_content)
    target_calls = collect_target_calls(target_content, npc_safe)
    target_entries: List[dict] = []
    for call in target_calls:
        target_entries.extend(call["entries"])

    if not source_msgs:
        raise RuntimeError("Brak wiadomości npcHandler:say w pliku źródłowym.")
    if not target_entries:
        raise RuntimeError("Brak kluczy NPC_LIB.i18n.npcSay* w pliku docelowym.")

    source_norm = [normalize_text(x) for x in source_msgs]
    target_norm: List[str] = []
    target_argc: List[int] = []
    for entry in target_entries:
        v = en_data.get(entry["key"])
        target_norm.append(normalize_text(v) if isinstance(v, str) else "")
        argc = entry.get("argc")
        target_argc.append(int(argc) if isinstance(argc, int) else 0)

    pairs = align_sequences(source_norm, target_norm, target_argc)
    if not pairs:
        raise RuntimeError("Nie udało się sparować wiadomości źródłowych z kluczami docelowymi.")

    source_count = len(source_norm)
    target_count = len(target_entries)
    pair_count = len(pairs)

    max_idx = next_say_index(en_data, npc_safe)
    key_expected_text: Dict[str, str] = {}
    en_updates: Dict[str, str] = {}
    renamed = 0
    fallback_sanitized = 0
    argc_splits = 0

    for src_i, tgt_i in pairs:
        entry = target_entries[tgt_i]
        expected = source_norm[src_i]
        if not expected:
            continue
        key = entry["key"]
        assigned = key

        prev_expected = key_expected_text.get(key)
        if prev_expected is None:
            key_expected_text[key] = expected
        elif prev_expected != expected:
            max_idx += 1
            assigned = f"npc.{npc_safe}.say_{max_idx}"
            key_expected_text[assigned] = expected
            renamed += 1

        entry["new_key"] = assigned
        en_updates[assigned] = expected

    # Fallback dla nadal błędnych runtime placeholderów:
    # sanitizuj per-entry i rozdziel klucze, aby nie psuć innych wywołań współdzielących ten sam key.
    for entry in target_entries:
        key = entry.get("new_key", entry["key"])
        argc = int(entry.get("argc") or 0)
        current_text = en_updates.get(key)
        if current_text is None:
            raw = en_data.get(key)
            current_text = normalize_text(raw) if isinstance(raw, str) else ""
        if not current_text:
            continue
        if placeholder_count(current_text) <= argc:
            continue
        fixed = sanitize_text_for_argc(current_text, argc)
        if not fixed:
            continue
        max_idx += 1
        split_key = f"npc.{npc_safe}.say_{max_idx}"
        entry["new_key"] = split_key
        en_updates[split_key] = fixed
        fallback_sanitized += 1
        argc_splits += 1

    for call in target_calls:
        if call["kind"] == "single":
            call["args"][3] = f"\"{call['entries'][0]['new_key']}\""
            continue

        rebuilt_items: List[str] = []
        for item in call["table_items"]:
            if not item["tracked"]:
                rebuilt_items.append(item["raw"])
                continue
            new_key = item["entry"]["new_key"]
            if item["mode"] == "literal":
                rebuilt_items.append(f"\"{new_key}\"")
            else:
                inner = [f"\"{new_key}\""] + item["rest"]
                rebuilt_items.append("{ " + ", ".join(inner) + " }")
        call["args"][3] = "{ " + ", ".join(rebuilt_items) + " }"

    repaired_content = target_content
    for call in sorted(target_calls, key=lambda x: x["start"], reverse=True):
        new_call = f"{call['needle']}(" + ", ".join(call["args"]) + ")"
        repaired_content = repaired_content[: call["start"]] + new_call + repaired_content[call["end"] :]

    repaired_en = dict(en_data)
    json_updates = 0
    for key, value in en_updates.items():
        if repaired_en.get(key) != value:
            repaired_en[key] = value
            json_updates += 1

    stats = {
        "source_messages": source_count,
        "target_entries": target_count,
        "paired": pair_count,
        "renamed_keys": renamed,
        "json_updates": json_updates,
        "fallback_sanitized": fallback_sanitized,
        "argc_splits": argc_splits,
        "source_unpaired": max(0, source_count - pair_count),
        "target_unpaired": max(0, target_count - pair_count),
    }
    return repaired_content, repaired_en, stats


def main() -> int:
    parser = argparse.ArgumentParser(description="Runtime repair mapowania NPC i18n z pliku źródłowego")
    parser.add_argument("--source", required=True, help="Źródłowy plik NPC (raw npcHandler:say)")
    parser.add_argument("--target", required=True, help="Docelowy plik NPC (zmigrowany NPC_LIB)")
    parser.add_argument("--en-json", required=True, help="i18n/en/npc.json")
    parser.add_argument("--npc-safe", required=True, help="Slug NPC, np. gnomargery")
    parser.add_argument("--apply", action="store_true", help="Zapisz zmiany do plików")
    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"ERROR: Brak źródła: {args.source}")
        return 1
    if not os.path.exists(args.target):
        print(f"ERROR: Brak pliku docelowego: {args.target}")
        return 1
    if not os.path.exists(args.en_json):
        print(f"ERROR: Brak EN JSON: {args.en_json}")
        return 1

    source_content = read_text(args.source)
    target_content = read_text(args.target)
    en_data = load_json(args.en_json)

    try:
        repaired_content, repaired_en, stats = repair_mapping(source_content, target_content, en_data, args.npc_safe)
    except RuntimeError as exc:
        print(f"ERROR: {exc}")
        return 1

    file_changed = repaired_content != target_content
    json_changed = repaired_en != en_data

    print(
        "REPAIR_OK "
        + " ".join(
            [
                f"paired={stats['paired']}",
                f"renamed={stats['renamed_keys']}",
                f"json_updates={stats['json_updates']}",
                f"fallback_sanitized={stats['fallback_sanitized']}",
                f"argc_splits={stats['argc_splits']}",
                f"file_changed={1 if file_changed else 0}",
                f"json_changed={1 if json_changed else 0}",
                f"source_unpaired={stats['source_unpaired']}",
                f"target_unpaired={stats['target_unpaired']}",
            ]
        )
    )

    if not args.apply:
        return 0

    if file_changed:
        write_text(args.target, repaired_content)
    if json_changed:
        save_json(args.en_json, repaired_en)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
