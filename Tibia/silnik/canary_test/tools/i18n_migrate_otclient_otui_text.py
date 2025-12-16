#!/usr/bin/env python3
import argparse
import json
import os
import re
from dataclasses import dataclass
from typing import Optional


@dataclass
class MigrationResult:
    keys_added: int
    calls_migrated: int
    file_changed: bool
    skipped_calls: int


_TEXT_LINE_RE = re.compile(
    r"^(?P<indent>\s*)(?P<prop>!?text)\s*:\s*(?P<q>['\"])(?P<val>[^'\"\n]*)(?P=q)\s*$"
)


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
    data_sorted = dict(sorted(data.items(), key=lambda kv: kv[0]))
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data_sorted, f, indent=2, ensure_ascii=False)


def _looks_like_key(s: str) -> bool:
    if not s:
        return False
    if " " in s or "\t" in s or "\n" in s:
        return False
    if "." not in s:
        return False
    return bool(re.fullmatch(r"[A-Za-z0-9_.:-]+", s))


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


def migrate_file(file_path: str, json_path: str, key_prefix: str, backup_dir: Optional[str], suffix: str) -> MigrationResult:
    original = _read_text(file_path)
    lines = original.splitlines(True)

    data = _load_json(json_path)
    next_idx = _next_key_index(data, key_prefix, suffix)

    keys_added = 0
    calls_migrated = 0
    skipped = 0

    changed = False

    for i, line in enumerate(lines):
        m = _TEXT_LINE_RE.match(line.rstrip("\n"))
        if not m:
            continue

        val = (m.group("val") or "").strip()
        if not val:
            skipped += 1
            continue

        # Skip placeholder/sample numeric texts and format specs
        if not any(ch.isalpha() for ch in val):
            skipped += 1
            continue
        if "%" in val:
            skipped += 1
            continue

        # If it's already a key-ish value, don't migrate
        if _looks_like_key(val):
            skipped += 1
            continue

        key = f"{key_prefix}.{suffix}_{next_idx}"
        next_idx += 1

        if key not in data:
            data[key] = val
            keys_added += 1

        indent = m.group("indent")
        prop = m.group("prop")
        # Keep OTUI style: tr('...')
        new_line = f"{indent}{prop}: tr('{key}')\n"

        if lines[i] != new_line:
            lines[i] = new_line
            changed = True
            calls_migrated += 1

    if changed:
        if backup_dir:
            os.makedirs(backup_dir, exist_ok=True)
            backup_path = os.path.join(backup_dir, os.path.basename(file_path) + ".bak")
            if not os.path.exists(backup_path):
                _write_text_atomic(backup_path, original)
        _write_text_atomic(file_path, "".join(lines))

    if keys_added > 0:
        _save_json(json_path, data)

    return MigrationResult(keys_added=keys_added, calls_migrated=calls_migrated, file_changed=changed, skipped_calls=skipped)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True)
    ap.add_argument("--json", required=True, dest="json_path")
    ap.add_argument("--key-prefix", required=True)
    ap.add_argument("--backup-dir", default="")
    ap.add_argument("--suffix", default="otui_text")
    args = ap.parse_args()

    res = migrate_file(
        file_path=args.file,
        json_path=args.json_path,
        key_prefix=args.key_prefix,
        backup_dir=args.backup_dir or None,
        suffix=args.suffix,
    )

    print(
        f"__MIGRATE_RESULT__ keys_added={res.keys_added} calls_migrated={res.calls_migrated} "
        f"file_changed={1 if res.file_changed else 0} skipped_calls={res.skipped_calls}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
