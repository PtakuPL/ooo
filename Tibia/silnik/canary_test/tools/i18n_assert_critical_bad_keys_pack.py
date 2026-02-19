#!/usr/bin/env python3
import argparse
import json
import os
import sys
from datetime import datetime, timezone


def _parse_iso(value: str):
    if not value:
        return None
    try:
        s = value.strip()
        if s.endswith("Z"):
            s = s[:-1] + "+00:00"
        return datetime.fromisoformat(s)
    except Exception:
        return None


def _load_json(path: str):
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        payload = json.load(f)
    return payload if isinstance(payload, dict) else {}


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Regression check: critical_bad_keys_pack for PL/ES must be non-empty when CRITICAL rejected entries exist in the time window."
    )
    parser.add_argument("--status-dir", default="i18n/status", help="Path to i18n status directory")
    parser.add_argument("--i18n-dir", default="i18n", help="Path to i18n root directory")
    parser.add_argument("--window-minutes", type=int, default=60, help="Lookback window in minutes")
    args = parser.parse_args()

    status_dir = args.status_dir
    i18n_dir = args.i18n_dir
    window_minutes = max(1, int(args.window_minutes or 60))

    now = datetime.now(timezone.utc)
    window_start = now.timestamp() - (window_minutes * 60)

    rejected_path = os.path.join(status_dir, "suspicious_rejected.jsonl")
    critical_by_lang = {"pl": 0, "es": 0}

    if os.path.exists(rejected_path):
        with open(rejected_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                lang = str(row.get("lang", "")).lower()
                if lang not in critical_by_lang:
                    continue
                if str(row.get("severity", "")).upper() != "CRITICAL":
                    continue
                ts = _parse_iso(str(row.get("timestamp", "")))
                if ts is not None and ts.timestamp() < window_start:
                    continue
                critical_by_lang[lang] += 1

    review_dir = os.path.join(i18n_dir, "overrides", "review_queue")
    failed = False
    rows = {}

    for lang in ("pl", "es"):
        pack_path = os.path.join(review_dir, f"critical_bad_keys_pack_{lang}_latest.json")
        pack_payload = _load_json(pack_path)
        entries = pack_payload.get("entries", []) if isinstance(pack_payload, dict) else []
        pack_count = len(entries) if isinstance(entries, list) else 0
        critical_count = int(critical_by_lang.get(lang, 0) or 0)
        ok = (critical_count == 0) or (pack_count > 0)
        if not ok:
            failed = True
        rows[lang] = {
            "critical_in_window": critical_count,
            "pack_entries": pack_count,
            "ok": ok,
        }

    print(json.dumps({
        "timestamp": now.isoformat().replace("+00:00", "Z"),
        "window_minutes": window_minutes,
        "by_lang": rows,
        "failed": failed,
    }, ensure_ascii=False, indent=2))

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
