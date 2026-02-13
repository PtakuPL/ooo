#!/usr/bin/env python3
"""Lightweight status writer for the i18n worker.

Goal: provide atomic JSON writes + append-only JSONL logs so the worker can
reliably expose LIVE (activity.json), durable state (worker_state.json), and
daily summaries (daily/YYYY-MM-DD.json).

This tool is intentionally dependency-free (std lib only).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Dict, Optional


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


# ── P1.9: Domain tag derivation ─────────────────────────────────────────────
_PHASE_TO_DOMAIN = {
    "MIGRATION": "MIGRATION",
    "COMPACT_KEYS": "KEY",
    "KEY_SYNC": "KEY",
    "TRANSLATION_SYNC": "SYNC",
    "AUTO_TRANSLATE": "AUTO",
    "QUALITY": "QUALITY",
    "QUALITY_AUDIT": "QUALITY",
    "IDLE": "QUALITY",
    "SELFTEST": "QUALITY",
}


def _derive_domain(phase: str, stage: str = "") -> str:
    """Derive normalized domain tag from phase/stage."""
    p = (phase or "").upper()
    if p in _PHASE_TO_DOMAIN:
        return _PHASE_TO_DOMAIN[p]
    # Fallback: check stage for clues
    s = (stage or "").upper()
    for key, domain in _PHASE_TO_DOMAIN.items():
        if key in s:
            return domain
    return "AUTO"  # default


def atomic_write_json(path: str, data: Dict[str, Any]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp_path = f"{path}.tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")
    os.replace(tmp_path, path)


def append_jsonl(path: str, event: Dict[str, Any]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False, sort_keys=True))
        f.write("\n")


def load_json(path: str) -> Optional[Dict[str, Any]]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return None
    except Exception:
        return None


def safe_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except Exception:
        return default


def utc_iso_from_epoch_seconds(value: Any) -> Optional[str]:
    try:
        seconds = float(value)
        return datetime.fromtimestamp(seconds, tz=timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    except Exception:
        return None


def count_en_keys_total(repo_root: str) -> int:
    en_dir = os.path.join(repo_root, "i18n", "en")
    total = 0
    try:
        for name in os.listdir(en_dir):
            if not name.endswith(".json"):
                continue
            path = os.path.join(en_dir, name)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    total += len(data)
            except Exception:
                continue
    except Exception:
        return 0
    return total


def count_languages_total(repo_root: str) -> int:
    i18n_dir = os.path.join(repo_root, "i18n")
    if not os.path.isdir(i18n_dir):
        return 0

    ignored = {"status"}
    count = 0
    for name in os.listdir(i18n_dir):
        if name in ignored:
            continue
        path = os.path.join(i18n_dir, name)
        if not os.path.isdir(path):
            continue
        try:
            if any(p.endswith(".json") for p in os.listdir(path)):
                count += 1
        except Exception:
            continue
    return count


def count_jsonl_lines(path: str) -> int:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return sum(1 for _ in f)
    except Exception:
        return 0


@dataclass
class StatusPaths:
    base_dir: str

    @property
    def activity_json(self) -> str:
        return os.path.join(self.base_dir, "activity.json")

    @property
    def worker_state_json(self) -> str:
        return os.path.join(self.base_dir, "worker_state.json")

    @property
    def ops_jsonl(self) -> str:
        return os.path.join(self.base_dir, "ops.jsonl")

    @property
    def errors_jsonl(self) -> str:
        return os.path.join(self.base_dir, "errors.jsonl")

    def daily_json(self, date_utc: str) -> str:
        return os.path.join(self.base_dir, "daily", f"{date_utc}.json")


def cmd_update_activity(args: argparse.Namespace) -> None:
    paths = StatusPaths(args.status_dir)

    current = {
        "generated_at_utc": utc_now_iso(),
        "status": args.status,
        "cycle": safe_int(args.cycle, 0),
        "phase": args.phase,
        "stage": args.stage,
        "category": args.category,
        "file": args.file,
        "message": args.message,
        "progress": {
            "done": safe_int(args.progress_done, 0),
            "total": safe_int(args.progress_total, 0),
            "unit": args.progress_unit,
        },
        "eta_seconds": safe_int(args.eta_seconds, 0),
    }

    prev = load_json(paths.activity_json) or {}
    prev_recent = prev.get("recent") if isinstance(prev.get("recent"), list) else []

    if args.recent_action or (args.file and args.file != "-"):
        recent_item = {
            "t": current["generated_at_utc"],
            "cycle": current["cycle"],
            "phase": current["phase"],
            "stage": current["stage"],
            "category": current["category"],
            "action": args.recent_action or "update",
            "file": current.get("file") or "-",
            "result": args.recent_result or "ok",
        }
        prev_recent = [recent_item] + prev_recent

    current["recent"] = prev_recent[:10]
    atomic_write_json(paths.activity_json, current)


def cmd_log_op(args: argparse.Namespace) -> None:
    paths = StatusPaths(args.status_dir)

    event: Dict[str, Any] = {
        "t": utc_now_iso(),
        "cycle": safe_int(args.cycle, 0),
        "phase": args.phase,
        "stage": args.stage,
        "category": args.category,
        "file": args.file,
        "result": args.result,
        "domain": _derive_domain(args.phase, args.stage),
    }

    delta: Dict[str, Any] = {}
    if args.keys_added is not None:
        delta["keys_added"] = safe_int(args.keys_added, 0)
    if args.files_changed is not None:
        delta["files_changed"] = safe_int(args.files_changed, 0)
    if args.translated is not None:
        delta["translated"] = safe_int(args.translated, 0)
    if args.skipped is not None:
        delta["skipped"] = safe_int(args.skipped, 0)
    if args.mapped_new is not None:
        delta["mapped_new"] = safe_int(args.mapped_new, 0)

    if delta:
        event["delta"] = delta

    if args.detail:
        event["detail"] = args.detail

    append_jsonl(paths.ops_jsonl, event)


def cmd_log_error(args: argparse.Namespace) -> None:
    paths = StatusPaths(args.status_dir)

    event: Dict[str, Any] = {
        "t": utc_now_iso(),
        "cycle": safe_int(args.cycle, 0),
        "phase": args.phase,
        "stage": args.stage,
        "category": args.category,
        "file": args.file,
        "error": args.error,
        "action": args.action,
        "domain": _derive_domain(args.phase, args.stage),
    }

    append_jsonl(paths.errors_jsonl, event)


def cmd_build_daily(args: argparse.Namespace) -> None:
    paths = StatusPaths(args.status_dir)

    date_utc = args.date or datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Aggregate from ops/errors JSONL.
    work: Dict[str, Any] = {
        "migration": {"files_changed": 0, "keys_added": 0, "categories_touched": []},
        "translation_sync": {"langs": {}},
        "auto_translate": {"langs": {}},
        "compact_keys": {"mapped_new": 0, "exported_langs": []},
    }

    migration_categories_touched = set()
    cycles = set()

    def iter_jsonl(path: str):
        try:
            with open(path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        yield json.loads(line)
                    except Exception:
                        continue
        except FileNotFoundError:
            return

    def is_date(event_t: str) -> bool:
        return isinstance(event_t, str) and event_t.startswith(date_utc)

    for ev in iter_jsonl(paths.ops_jsonl):
        t = ev.get("t")
        if not is_date(t):
            continue

        cycles.add(safe_int(ev.get("cycle"), 0))

        phase = (ev.get("phase") or "").upper()
        category = ev.get("category") or ""

        delta = ev.get("delta") if isinstance(ev.get("delta"), dict) else {}

        if phase == "MIGRATION":
            if category:
                migration_categories_touched.add(category)
            work["migration"]["files_changed"] += safe_int(delta.get("files_changed"), 0)
            work["migration"]["keys_added"] += safe_int(delta.get("keys_added"), 0)
        elif phase == "TRANSLATION_SYNC":
            lang = (ev.get("detail") or "").upper() if isinstance(ev.get("detail"), str) else ""
            # If detail contains lang=XX, parse it; else store under '?'
            lang_key = "?"
            if "lang=" in (ev.get("detail") or ""):
                try:
                    lang_key = (ev.get("detail").split("lang=", 1)[1].split()[0]).upper()
                except Exception:
                    lang_key = "?"
            lang_entry = work["translation_sync"]["langs"].setdefault(lang_key, {"keys_added": 0})
            lang_entry["keys_added"] += safe_int(delta.get("keys_added"), 0)
        elif phase == "AUTO_TRANSLATE":
            lang_key = "?"
            if "lang=" in (ev.get("detail") or ""):
                try:
                    lang_key = (ev.get("detail").split("lang=", 1)[1].split()[0]).upper()
                except Exception:
                    lang_key = "?"
            lang_entry = work["auto_translate"]["langs"].setdefault(lang_key, {"translated": 0, "skipped": 0})
            lang_entry["translated"] += safe_int(delta.get("translated"), 0)
            lang_entry["skipped"] += safe_int(delta.get("skipped"), 0)
        elif phase == "COMPACT_KEYS":
            work["compact_keys"]["mapped_new"] += safe_int(delta.get("mapped_new"), 0)

    err_count = 0
    for ev in iter_jsonl(paths.errors_jsonl):
        t = ev.get("t")
        if not is_date(t):
            continue
        err_count += 1

    work["migration"]["categories_touched"] = sorted(migration_categories_touched)

    daily = {
        "date": date_utc,
        "cycles": len([c for c in cycles if c != 0]) or len(cycles),
        "work": work,
        "errors": {"count": err_count},
        "generated_at_utc": utc_now_iso(),
    }

    atomic_write_json(paths.daily_json(date_utc), daily)


def cmd_build_worker_state(args: argparse.Namespace) -> None:
    paths = StatusPaths(args.status_dir)

    repo_root = args.repo_root
    activity = load_json(paths.activity_json) or {}
    global_stats = load_json(os.path.join(repo_root, "i18n_global_stats.json")) or {}
    legacy_worker_state = load_json(os.path.join(repo_root, "i18n_worker_state.json")) or {}
    category_state = load_json(os.path.join(repo_root, ".i18n_category_state.json")) or {}

    worker_pid: Optional[int] = None
    try:
        pid_path = os.path.join(repo_root, ".worker_simple.pid")
        with open(pid_path, "r", encoding="utf-8") as f:
            worker_pid = safe_int(f.read().strip(), 0) or None
    except Exception:
        worker_pid = None

    en_keys_total = count_en_keys_total(repo_root)
    languages_total = count_languages_total(repo_root)

    processed_total = 0
    try:
        processed_path = os.path.join(repo_root, "i18n_processed_files.txt")
        with open(processed_path, "r", encoding="utf-8") as f:
            processed_total = len([ln for ln in f if ln.strip()])
    except Exception:
        processed_total = 0

    errors_total = count_jsonl_lines(paths.errors_jsonl)

    current_phase = str(activity.get("phase") or "IDLE")
    current_stage = str(activity.get("stage") or "-")
    current_category = str(activity.get("category") or "-")
    current_file = str(activity.get("file") or "-")
    current_detail = str(activity.get("message") or "")
    current_cycle = safe_int(activity.get("cycle"), safe_int(global_stats.get("total_cycles"), 0))
    current_status = str(activity.get("status") or "running")

    progress = activity.get("progress") if isinstance(activity.get("progress"), dict) else {}
    current_progress = {
        "done": safe_int(progress.get("done"), 0),
        "total": safe_int(progress.get("total"), 0),
        "unit": str(progress.get("unit") or "units"),
    }

    categories: Dict[str, Any] = {}
    skip_until = category_state.get("skip_until") if isinstance(category_state.get("skip_until"), dict) else {}
    consecutive_zeros = (
        category_state.get("consecutive_zeros") if isinstance(category_state.get("consecutive_zeros"), dict) else {}
    )
    last_processed = category_state.get("last_processed") if isinstance(category_state.get("last_processed"), dict) else {}

    for cat in sorted(set(list(skip_until.keys()) + list(consecutive_zeros.keys()) + list(last_processed.keys()))):
        lu = last_processed.get(cat) if isinstance(last_processed.get(cat), dict) else {}
        ts = lu.get("timestamp")
        categories[cat] = {
            "status": "backoff" if cat in skip_until else "idle",
            "backoff": {
                "skip_until_utc": utc_iso_from_epoch_seconds(skip_until.get(cat)) if cat in skip_until else None,
                "consecutive_zeros": safe_int(consecutive_zeros.get(cat), 0),
            },
            "last": {
                "updated_at_utc": utc_iso_from_epoch_seconds(ts) if ts else None,
                "delta": {"files_migrated": safe_int(lu.get("count"), 0)},
            },
        }

    worker_state: Dict[str, Any] = {
        "schema_version": "3.0",
        "generated_at_utc": utc_now_iso(),
        "worker": {
            "name": "i18n_worker_simple.sh",
            "version": str(args.worker_version or "unknown"),
            "pid": worker_pid,
            "host": os.uname().nodename if hasattr(os, "uname") else "unknown",
            "status": current_status,
            "mode": "continuous" if os.path.exists(os.path.join(repo_root, ".worker_simple.pid")) else "manual",
            "cycle": current_cycle,
            "heartbeat_at_utc": str(activity.get("generated_at_utc") or utc_now_iso()),
            "current": {
                "phase": current_phase,
                "stage": current_stage,
                "category": current_category,
                "file": current_file,
                "detail": current_detail,
                "progress": current_progress,
                "eta_seconds": safe_int(activity.get("eta_seconds"), 0),
            },
        },
        "global": {
            "languages_total": languages_total,
            "en_keys_total": en_keys_total,
            "files_processed_total": processed_total,
            "errors_total": errors_total,
        },
        "legacy": {
            "i18n_worker_state": legacy_worker_state,
            "i18n_global_stats": global_stats,
        },
        "categories": categories,
    }

    atomic_write_json(paths.worker_state_json, worker_state)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="i18n_status.py")
    p.add_argument("--status-dir", default=os.path.join("i18n", "status"))

    sub = p.add_subparsers(dest="cmd", required=True)

    upd = sub.add_parser("update-activity")
    upd.add_argument("--status", default="running")
    upd.add_argument("--cycle", default="0")
    upd.add_argument("--phase", default="IDLE")
    upd.add_argument("--stage", default="-")
    upd.add_argument("--category", default="-")
    upd.add_argument("--file", default="-")
    upd.add_argument("--message", default="")
    upd.add_argument("--progress-done", default="0")
    upd.add_argument("--progress-total", default="0")
    upd.add_argument("--progress-unit", default="units")
    upd.add_argument("--eta-seconds", default="0")
    upd.add_argument("--recent-action", default="")
    upd.add_argument("--recent-result", default="ok")
    upd.set_defaults(func=cmd_update_activity)

    op = sub.add_parser("log-op")
    op.add_argument("--cycle", default="0")
    op.add_argument("--phase", default="IDLE")
    op.add_argument("--stage", default="-")
    op.add_argument("--category", default="-")
    op.add_argument("--file", default="-")
    op.add_argument("--result", default="ok")
    op.add_argument("--detail", default="")
    op.add_argument("--keys-added")
    op.add_argument("--files-changed")
    op.add_argument("--translated")
    op.add_argument("--skipped")
    op.add_argument("--mapped-new")
    op.set_defaults(func=cmd_log_op)

    err = sub.add_parser("log-error")
    err.add_argument("--cycle", default="0")
    err.add_argument("--phase", default="-")
    err.add_argument("--stage", default="-")
    err.add_argument("--category", default="-")
    err.add_argument("--file", default="-")
    err.add_argument("--error", required=True)
    err.add_argument("--action", default="")
    err.set_defaults(func=cmd_log_error)

    daily = sub.add_parser("build-daily")
    daily.add_argument("--date", default="")
    daily.set_defaults(func=cmd_build_daily)

    ws = sub.add_parser("build-worker-state")
    ws.add_argument("--repo-root", default=".", help="Repository root (default: .)")
    ws.add_argument("--worker-version", default=None, help="Optional worker version string")
    ws.set_defaults(func=cmd_build_worker_state)

    return p


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        args.func(args)
        return 0
    except Exception as e:
        print(f"i18n_status.py error: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
