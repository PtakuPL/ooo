#!/usr/bin/env python3
"""i18n_keymap.py

Maintains a stable mapping from *semantic* i18n keys (e.g. "npc.foo.say_1")
into short *compact* keys (e.g. "KkKk31") for bandwidth / client-side i18n.

Design goals:
- Stable over time (do not reshuffle existing mappings)
- Deterministic allocation (monotonic counter stored in meta)
- Collision-safe
- Length bounded (default 6; configurable up to 7 as per project needs)

Files:
- i18n/keymap.json        semantic -> compact
- i18n/keymap_rev.json    compact  -> semantic (derived)
- i18n/keymap_meta.json   meta (alphabet, length, next_id)

Usage:
  python3 tools/i18n_keymap.py sync --i18n-dir i18n
  python3 tools/i18n_keymap.py verify --i18n-dir i18n

This tool is intentionally independent from the migration worker.
"""

from __future__ import annotations

import argparse
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, Tuple


DEFAULT_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
DEFAULT_MIN_LENGTH = 2
DEFAULT_MAX_LENGTH = 7


@dataclass
class KeymapMeta:
    version: int = 1
    alphabet: str = DEFAULT_ALPHABET
    min_length: int = DEFAULT_MIN_LENGTH
    max_length: int = DEFAULT_MAX_LENGTH
    next_id: int = 0


def _read_json(path: Path, default):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return default


def _write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, sort_keys=True)
    os.replace(tmp, path)


def _encode_base_n(value: int, alphabet: str) -> str:
    if value < 0:
        raise ValueError("value must be >= 0")
    base = len(alphabet)
    if base < 2:
        raise ValueError("alphabet must have at least 2 characters")
    if value == 0:
        return alphabet[0]
    out = []
    while value > 0:
        value, rem = divmod(value, base)
        out.append(alphabet[rem])
    out.reverse()
    return "".join(out)


def _format_compact(value: int, meta: KeymapMeta) -> str:
    encoded = _encode_base_n(value, meta.alphabet)
    if len(encoded) > meta.max_length:
        raise ValueError(
            f"Compact key overflow: id={value} enc_len={len(encoded)} > max_length={meta.max_length}"
        )
    pad_char = meta.alphabet[0]
    if len(encoded) < meta.min_length:
        return pad_char * (meta.min_length - len(encoded)) + encoded
    return encoded


def load_keymap_files(i18n_dir: Path) -> Tuple[KeymapMeta, Dict[str, str]]:
    meta_path = i18n_dir / "keymap_meta.json"
    keymap_path = i18n_dir / "keymap.json"

    meta_raw = _read_json(meta_path, None)
    if not meta_raw:
        meta = KeymapMeta()
    else:
        # Backward compatibility:
        # - Old schema might have a fixed `length` only.
        #   In that case, keep min=max=length to preserve existing mappings.
        old_length = meta_raw.get("length", None)
        min_len = meta_raw.get("min_length", None)
        max_len = meta_raw.get("max_length", None)

        if min_len is None and max_len is None and old_length is not None:
            min_len = int(old_length)
            max_len = int(old_length)
        else:
            min_len = int(min_len) if min_len is not None else DEFAULT_MIN_LENGTH
            max_len = int(max_len) if max_len is not None else DEFAULT_MAX_LENGTH

        meta = KeymapMeta(
            version=int(meta_raw.get("version", 1)),
            alphabet=str(meta_raw.get("alphabet", DEFAULT_ALPHABET)),
            min_length=min_len,
            max_length=max_len,
            next_id=int(meta_raw.get("next_id", 0)),
        )

    keymap = _read_json(keymap_path, {})

    # Defensive: ignore any accidental non-string mappings
    cleaned = {}
    for k, v in (keymap or {}).items():
        if isinstance(k, str) and isinstance(v, str) and not k.startswith("__"):
            cleaned[k] = v

    return meta, cleaned


def save_keymap_files(i18n_dir: Path, meta: KeymapMeta, keymap: Dict[str, str]) -> None:
    meta_path = i18n_dir / "keymap_meta.json"
    keymap_path = i18n_dir / "keymap.json"
    rev_path = i18n_dir / "keymap_rev.json"

    _write_json(
        meta_path,
        {
            "version": meta.version,
            "alphabet": meta.alphabet,
            "min_length": meta.min_length,
            "max_length": meta.max_length,
            "next_id": meta.next_id,
        },
    )
    _write_json(keymap_path, dict(sorted(keymap.items())))

    rev: Dict[str, str] = {}
    for semantic, compact in keymap.items():
        # In case of duplicate compacts, keep the first one deterministically
        rev.setdefault(compact, semantic)
    _write_json(rev_path, dict(sorted(rev.items())))


def iter_semantic_keys_from_en(i18n_dir: Path) -> Iterable[str]:
    en_dir = i18n_dir / "en"
    if not en_dir.is_dir():
        return []

    keys = set()
    for json_path in sorted(en_dir.glob("*.json")):
        try:
            with json_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
            if isinstance(data, dict):
                for k in data.keys():
                    if isinstance(k, str):
                        keys.add(k)
        except json.JSONDecodeError:
            # Keep behavior safe: ignore broken files here; validation happens elsewhere
            continue
    return sorted(keys)


def ensure_mapping_for_keys(
    semantic_keys: Iterable[str],
    i18n_dir: Path,
    *,
    meta: KeymapMeta | None = None,
    keymap: Dict[str, str] | None = None,
) -> Tuple[KeymapMeta, Dict[str, str], int]:
    if meta is None or keymap is None:
        meta, keymap = load_keymap_files(i18n_dir)

    reverse = {v: k for k, v in keymap.items()}

    created = 0
    for semantic in semantic_keys:
        if semantic in keymap:
            continue

        # Allocate until unique
        while True:
            compact = _format_compact(meta.next_id, meta)
            meta.next_id += 1
            if compact not in reverse:
                break

        keymap[semantic] = compact
        reverse[compact] = semantic
        created += 1

    return meta, keymap, created


def verify_keymap(i18n_dir: Path) -> Tuple[bool, str]:
    meta, keymap = load_keymap_files(i18n_dir)
    reverse: Dict[str, str] = {}

    alphabet_set = set(meta.alphabet)

    for semantic, compact in keymap.items():
        if not semantic or not compact:
            return False, "Empty semantic/compact entry found"
        if len(compact) < meta.min_length or len(compact) > meta.max_length:
            return False, f"Bad compact length for {semantic}: {compact}"
        if any(ch not in alphabet_set for ch in compact):
            return False, f"Bad compact alphabet for {semantic}: {compact}"
        if compact in reverse and reverse[compact] != semantic:
            return False, f"Collision: {compact} maps to both {reverse[compact]} and {semantic}"
        reverse[compact] = semantic

    # Ensure all EN keys have mapping
    en_keys = list(iter_semantic_keys_from_en(i18n_dir))
    missing = [k for k in en_keys if k not in keymap]
    if missing:
        return False, f"Missing mappings for {len(missing)} EN keys (run: sync)"

    return True, f"OK: {len(keymap)} mappings, next_id={meta.next_id}, len={meta.min_length}..{meta.max_length}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Maintain semantic->compact i18n key mapping")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_sync = sub.add_parser("sync", help="Ensure every EN key has a compact mapping")
    p_sync.add_argument("--i18n-dir", default="i18n", help="Path to i18n directory")
    p_sync.add_argument("--min-len", type=int, default=None, help="Minimum compact key length (default from meta or 2)")
    p_sync.add_argument("--max-len", type=int, default=None, help="Maximum compact key length (default from meta or 7)")
    p_sync.add_argument("--alphabet", default=None, help="Alphabet to use (default from meta)")

    p_verify = sub.add_parser("verify", help="Verify mapping integrity and coverage")
    p_verify.add_argument("--i18n-dir", default="i18n", help="Path to i18n directory")

    args = parser.parse_args()
    i18n_dir = Path(args.i18n_dir)

    if args.cmd == "sync":
        meta, keymap = load_keymap_files(i18n_dir)
        if args.min_len is not None:
            meta.min_length = int(args.min_len)
        if args.max_len is not None:
            meta.max_length = int(args.max_len)
        if args.alphabet is not None:
            meta.alphabet = str(args.alphabet)

        if meta.min_length < 1:
            raise SystemExit("min_length must be >= 1")
        if meta.max_length < meta.min_length:
            raise SystemExit("max_length must be >= min_length")

        en_keys = iter_semantic_keys_from_en(i18n_dir)
        meta, keymap, created = ensure_mapping_for_keys(en_keys, i18n_dir, meta=meta, keymap=keymap)
        save_keymap_files(i18n_dir, meta, keymap)
        print(
            f"OK: created {created} mappings (total={len(keymap)}), next_id={meta.next_id}, len={meta.min_length}..{meta.max_length}"
        )
        return 0

    if args.cmd == "verify":
        ok, msg = verify_keymap(i18n_dir)
        print(msg)
        return 0 if ok else 2

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
