#!/bin/bash
#===============================================================================
# i18n_baseline_snapshot.sh — Faza 0: generuje raport baseline
#===============================================================================
# Uzycie:
#   bash i18n_baseline_snapshot.sh
#   bash i18n_baseline_snapshot.sh --hours 10
#   bash i18n_baseline_snapshot.sh --since "2026-02-12T22:00:00Z"
#
# Output:
#   i18n/status/baseline/baseline_YYYY-MM-DD_HHMMSS.json
#   stdout: podsumowanie
#===============================================================================

set -euo pipefail

cd "$(dirname "$0")"
WORK_DIR="$(pwd)"

HOURS=24
SINCE=""

usage() {
    cat <<'EOF'
Usage:
  bash i18n_baseline_snapshot.sh [--hours N] [--since ISO8601]

Examples:
  bash i18n_baseline_snapshot.sh
  bash i18n_baseline_snapshot.sh --hours 10
  bash i18n_baseline_snapshot.sh --since "2026-02-12T22:00:00Z"
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --hours)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: --hours wymaga wartosci." >&2
                exit 2
            fi
            HOURS="$2"
            shift 2
            ;;
        --since)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: --since wymaga wartosci ISO8601." >&2
                exit 2
            fi
            SINCE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: nieznany argument: $1" >&2
            usage
            exit 2
            ;;
    esac
done

if ! [[ "$HOURS" =~ ^[0-9]+$ ]] || (( HOURS <= 0 )); then
    echo "ERROR: --hours musi byc dodatnia liczba calkowita." >&2
    exit 2
fi

BASELINE_DIR="$WORK_DIR/i18n/status/baseline"
mkdir -p "$BASELINE_DIR"

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
FILENAME="baseline_$(date -u +"%Y-%m-%d_%H%M%S")_$$.json"

export WORK_DIR
export HOURS
export SINCE
export BASELINE_DIR
export FILENAME
export TIMESTAMP

python3 <<'PYEOF'
import glob
import json
import os
import re
import sys
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone

WORK_DIR = os.environ["WORK_DIR"]
HOURS = int(os.environ["HOURS"])
SINCE = os.environ.get("SINCE", "")
BASELINE_DIR = os.environ["BASELINE_DIR"]
FILENAME = os.environ["FILENAME"]
TIMESTAMP = os.environ["TIMESTAMP"]

I18N_DIR = os.path.join(WORK_DIR, "i18n")
STATUS_DIR = os.path.join(I18N_DIR, "status")


def _to_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def parse_iso_utc(value):
    if not value or not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        dt = datetime.fromisoformat(text)
    except ValueError:
        fmts = [
            "%Y-%m-%d %H:%M:%S",
            "%Y-%m-%dT%H:%M:%S",
            "%Y-%m-%dT%H:%M",
            "%Y-%m-%d %H:%M",
        ]
        dt = None
        for fmt in fmts:
            try:
                dt = datetime.strptime(text, fmt)
                break
            except ValueError:
                continue
        if dt is None:
            return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)


def load_json(path, default=None):
    if default is None:
        default = {}
    if not os.path.exists(path):
        return default
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default


def parse_guardian_line(line):
    m = re.match(r"^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]\s*(.*)$", line.strip())
    if not m:
        return None, ""
    stamp = parse_iso_utc(m.group(1).replace(" ", "T") + "Z")
    return stamp, m.group(2)


now_utc = datetime.now(timezone.utc)
if SINCE:
    cutoff_dt = parse_iso_utc(SINCE)
    if cutoff_dt is None:
        print(f"ERROR: Niepoprawny --since: {SINCE}", file=sys.stderr)
        sys.exit(2)
else:
    cutoff_dt = now_utc - timedelta(hours=HOURS)

cutoff_date = cutoff_dt.date()
cutoff_str = cutoff_dt.strftime("%Y-%m-%dT%H:%M:%SZ")
window_hours = max((now_utc - cutoff_dt).total_seconds() / 3600.0, 0.001)
hours_label = f"{window_hours:.2f} (from --since)" if SINCE else str(HOURS)


def in_window(ts_value):
    ts = parse_iso_utc(ts_value)
    return ts is not None and ts >= cutoff_dt


print(f"Baseline snapshot — cutoff: {cutoff_str}, hours: {hours_label}")
print(f"Output: {os.path.join(BASELINE_DIR, FILENAME)}")
print()

# ---------------------------------------------------------------------------
# 1) Guard report
# ---------------------------------------------------------------------------
guard_path = os.path.join(STATUS_DIR, "translation_guard_report.jsonl")
guard_entries = []
if os.path.exists(guard_path):
    with open(guard_path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            if in_window(row.get("timestamp")):
                guard_entries.append(row)

target_stats = defaultdict(
    lambda: {
        "cycles": 0,
        "translated": 0,
        "guard_fail": 0,
        "guard_command": 0,
        "guard_placeholder": 0,
        "guard_pipe": 0,
        "guard_quality": 0,
    }
)

for row in guard_entries:
    target = f"{str(row.get('language', '?')).lower()}/{row.get('json_file', '?')}"
    stats = target_stats[target]
    stats["cycles"] += 1
    stats["translated"] += _to_int(row.get("translated"))
    stats["guard_fail"] += _to_int(row.get("guard_fail"))
    guard = row.get("guard") if isinstance(row.get("guard"), dict) else {}
    stats["guard_command"] += _to_int(guard.get("command"))
    stats["guard_placeholder"] += _to_int(guard.get("placeholder"))
    stats["guard_pipe"] += _to_int(guard.get("pipe"))
    stats["guard_quality"] += _to_int(row.get("guard_quality"))

total_translated = sum(v["translated"] for v in target_stats.values())
total_guard_fail = sum(v["guard_fail"] for v in target_stats.values())
total_attempts = total_translated + total_guard_fail
guard_fail_rate = (total_guard_fail / total_attempts) if total_attempts else 0.0

lang_agg = defaultdict(lambda: {"translated": 0, "guard_fail": 0, "cycles": 0, "files": set()})
for target, stats in target_stats.items():
    lang, _, file_name = target.partition("/")
    row = lang_agg[lang]
    row["translated"] += stats["translated"]
    row["guard_fail"] += stats["guard_fail"]
    row["cycles"] += stats["cycles"]
    row["files"].add(file_name)

# ---------------------------------------------------------------------------
# 2) Cycle perf
# ---------------------------------------------------------------------------
perf_path = os.path.join(STATUS_DIR, "worker_cycle_perf.jsonl")
perf_entries = []
if os.path.exists(perf_path):
    with open(perf_path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            if in_window(row.get("timestamp")):
                perf_entries.append(row)

mode_counts = defaultdict(int)
migration_cats = defaultdict(int)
auto_cats = defaultdict(int)
total_duration_ms = 0

for row in perf_entries:
    mode = str(row.get("mode", "?"))
    category = str(row.get("category", "?"))
    mode_counts[mode] += 1
    total_duration_ms += _to_int(row.get("duration_ms"))
    if mode == "MIGRATION":
        migration_cats[category] += 1
    elif mode == "AUTO_TRANSLATE":
        auto_cats[category] += 1

total_cycles = len(perf_entries)
migration_cycles = mode_counts.get("MIGRATION", 0)
pending_skip_count = migration_cats.get("pending_skip", 0)
pending_skip_share_total = (pending_skip_count / total_cycles) if total_cycles else 0.0
pending_skip_share_migration = (pending_skip_count / migration_cycles) if migration_cycles else 0.0

no_progress_entries = [d for d in guard_entries if _to_int(d.get("translated")) == 0]
no_progress_rate = (len(no_progress_entries) / len(guard_entries)) if guard_entries else 0.0

total_runtime_h = total_duration_ms / 3600000.0 if total_duration_ms > 0 else window_hours
throughput_keys_per_h = total_translated / total_runtime_h if total_runtime_h > 0 else 0.0

# ---------------------------------------------------------------------------
# 3) Suspicious log
# ---------------------------------------------------------------------------
susp_path = os.path.join(STATUS_DIR, "suspicious_log.jsonl")
susp_types = defaultdict(int)
susp_count = 0
if os.path.exists(susp_path):
    with open(susp_path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            if not in_window(row.get("timestamp")):
                continue
            susp_count += 1
            issues = row.get("issues") if isinstance(row.get("issues"), list) else []
            for issue in issues:
                if not isinstance(issue, dict):
                    continue
                key = f"{issue.get('severity', '?')}:{issue.get('type', '?')}"
                susp_types[key] += 1

# ---------------------------------------------------------------------------
# 4) Coverage
# ---------------------------------------------------------------------------
coverage = {}
en_dir = os.path.join(I18N_DIR, "en")
if os.path.isdir(en_dir):
    en_files = sorted(f for f in os.listdir(en_dir) if f.endswith(".json"))
    en_payload = {}
    en_keys_total = 0
    for fn in en_files:
        data = load_json(os.path.join(en_dir, fn), {})
        if not isinstance(data, dict):
            data = {}
        en_payload[fn] = data
        en_keys_total += len(data)

    lang_dirs = sorted(
        d
        for d in os.listdir(I18N_DIR)
        if os.path.isdir(os.path.join(I18N_DIR, d)) and d not in {"en", "status"}
    )

    for lang in lang_dirs:
        lang_dir = os.path.join(I18N_DIR, lang)
        stats = {
            "total": en_keys_total,
            "translated": 0,
            "identical": 0,
            "placeholder": 0,
            "missing_keys": 0,
            "missing_files": 0,
            "per_file": {},
        }

        for fn, en_data in en_payload.items():
            file_stats = {"translated": 0, "identical": 0, "placeholder": 0, "missing": 0}
            lang_file = os.path.join(lang_dir, fn)

            if not os.path.exists(lang_file):
                missing_count = len(en_data)
                file_stats["missing"] = missing_count
                stats["missing_keys"] += missing_count
                stats["missing_files"] += 1
            else:
                lang_data = load_json(lang_file, {})
                if not isinstance(lang_data, dict):
                    lang_data = {}
                for key, en_value in en_data.items():
                    candidate = lang_data.get(key)
                    if candidate is None:
                        file_stats["missing"] += 1
                        stats["missing_keys"] += 1
                    elif str(candidate).startswith("["):
                        file_stats["placeholder"] += 1
                        stats["placeholder"] += 1
                    elif str(candidate) == str(en_value):
                        file_stats["identical"] += 1
                        stats["identical"] += 1
                    else:
                        file_stats["translated"] += 1
                        stats["translated"] += 1

            if lang in {"pl", "es"}:
                stats["per_file"][fn] = file_stats

        stats["coverage_pct"] = round((stats["translated"] / stats["total"] * 100), 1) if stats["total"] else 0
        stats["real_remaining"] = stats["total"] - stats["translated"]
        coverage[lang] = stats

# ---------------------------------------------------------------------------
# 5) Quality dashboard (PL/ES)
# ---------------------------------------------------------------------------
quality_dashboard = load_json(os.path.join(STATUS_DIR, "quality_dashboard.json"), {})
quality_snapshot = {}
if isinstance(quality_dashboard, dict):
    for lang in ("pl", "es"):
        entry = quality_dashboard.get(lang, {})
        if not isinstance(entry, dict):
            continue
        quality_snapshot[lang] = {
            "quality_score": entry.get("quality_score"),
            "issues_count": _to_int(entry.get("issues_count")),
            "total_suspicious": _to_int(entry.get("total_suspicious")),
            "total_gt_guard_fail": _to_int(entry.get("total_gt_guard_fail")),
            "cycles": _to_int(entry.get("cycles")),
            "last_cycle": entry.get("last_cycle"),
            "last_audit": entry.get("last_audit"),
        }

# ---------------------------------------------------------------------------
# 6) Daily summary
# ---------------------------------------------------------------------------
daily_summary = {
    "days_in_window": 0,
    "cycles": 0,
    "errors": 0,
    "auto_translate_translated": {"pl": 0, "es": 0},
    "files": [],
}

for path in sorted(glob.glob(os.path.join(STATUS_DIR, "daily", "*.json"))):
    row = load_json(path, None)
    if not isinstance(row, dict):
        continue

    day_dt = parse_iso_utc(row.get("generated_at_utc"))
    if day_dt is None:
        day_raw = row.get("date")
        if isinstance(day_raw, str):
            try:
                parsed_day = date.fromisoformat(day_raw)
                day_dt = datetime.combine(parsed_day, datetime.min.time(), tzinfo=timezone.utc)
            except ValueError:
                day_dt = None
    if day_dt is None or day_dt.date() < cutoff_date:
        continue

    daily_summary["days_in_window"] += 1
    daily_summary["cycles"] += _to_int(row.get("cycles"))
    errors = row.get("errors") if isinstance(row.get("errors"), dict) else {}
    daily_summary["errors"] += _to_int(errors.get("count"))

    work = row.get("work") if isinstance(row.get("work"), dict) else {}
    auto_translate = work.get("auto_translate") if isinstance(work.get("auto_translate"), dict) else {}
    langs = auto_translate.get("langs") if isinstance(auto_translate.get("langs"), dict) else {}
    pl_data = langs.get("PL") if isinstance(langs.get("PL"), dict) else {}
    es_data = langs.get("ES") if isinstance(langs.get("ES"), dict) else {}
    daily_summary["auto_translate_translated"]["pl"] += _to_int(pl_data.get("translated"))
    daily_summary["auto_translate_translated"]["es"] += _to_int(es_data.get("translated"))
    daily_summary["files"].append(os.path.basename(path))

# ---------------------------------------------------------------------------
# 7) Guardian log summary
# ---------------------------------------------------------------------------
guardian_summary = {
    "entries": 0,
    "worker_ok": 0,
    "restarts": 0,
    "starts_ok": 0,
    "starts_failed": 0,
    "push_ok": 0,
}
guardian_path = os.path.join(WORK_DIR, "guardian.log")
if os.path.exists(guardian_path):
    with open(guardian_path, encoding="utf-8", errors="ignore") as f:
        for raw in f:
            stamp, msg = parse_guardian_line(raw)
            if stamp is None or stamp < cutoff_dt:
                continue
            guardian_summary["entries"] += 1
            if "Worker OK" in msg:
                guardian_summary["worker_ok"] += 1
            if "Restart workera" in msg:
                guardian_summary["restarts"] += 1
            if "Worker uruchomiony PID" in msg:
                guardian_summary["starts_ok"] += 1
            if "Worker nie wystartował prawidłowo" in msg:
                guardian_summary["starts_failed"] += 1
            if "Push do GitHub OK" in msg:
                guardian_summary["push_ok"] += 1

# ---------------------------------------------------------------------------
# 8) Worker config/state snapshot
# ---------------------------------------------------------------------------
config = load_json(os.path.join(WORK_DIR, "worker_config.json"), {})
if not isinstance(config, dict):
    config = {}

worker_state = load_json(os.path.join(STATUS_DIR, "worker_state.json"), {})
if not isinstance(worker_state, dict):
    worker_state = {}

top_guard_fail = sorted(
    [{"target": key, **value} for key, value in target_stats.items()],
    key=lambda x: x["guard_fail"],
    reverse=True,
)[:20]

strict_hourly_window = {
    "window_start_utc": cutoff_str,
    "window_end_utc": now_utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
    "window_hours": round(window_hours, 3),
    "sources": [
        "i18n/status/worker_cycle_perf.jsonl",
        "i18n/status/translation_guard_report.jsonl",
        "i18n/status/suspicious_log.jsonl",
    ],
    "total_cycles": total_cycles,
    "auto_translate_cycles": mode_counts.get("AUTO_TRANSLATE", 0),
    "migration_cycles": migration_cycles,
    "pending_skip_count": pending_skip_count,
    "pending_skip_share_pct": round(pending_skip_share_total * 100, 1),
    "pending_skip_share_migration_pct": round(pending_skip_share_migration * 100, 1),
    "translated": total_translated,
    "guard_fail": total_guard_fail,
    "guard_fail_rate_pct": round(guard_fail_rate * 100, 1),
    "no_progress_entries": len(no_progress_entries),
    "no_progress_rate_pct": round(no_progress_rate * 100, 1),
    "throughput_keys_per_h": round(throughput_keys_per_h, 1),
    "suspicious_total": susp_count,
    "top_guard_fail_targets": top_guard_fail[:10],
}

baseline = {
    "meta": {
        "generated_at": TIMESTAMP,
        "cutoff": cutoff_str,
        "hours": round(window_hours, 2),
        "hours_arg": HOURS,
        "since": SINCE or None,
        "window_start_utc": cutoff_str,
        "window_end_utc": now_utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "script": "i18n_baseline_snapshot.sh",
        "version": "1.2",
    },
    "summary": {
        "total_cycles": total_cycles,
        "mode_distribution": dict(mode_counts),
        "pending_skip_count": pending_skip_count,
        "pending_skip_share_pct": round(pending_skip_share_total * 100, 1),
        "pending_skip_share_migration_pct": round(pending_skip_share_migration * 100, 1),
        "total_translated": total_translated,
        "total_guard_fail": total_guard_fail,
        "total_attempts": total_attempts,
        "guard_fail_rate_pct": round(guard_fail_rate * 100, 1),
        "no_progress_entries": len(no_progress_entries),
        "no_progress_rate_pct": round(no_progress_rate * 100, 1),
        "throughput_keys_per_h": round(throughput_keys_per_h, 1),
        "total_runtime_h": round(total_runtime_h, 2),
        "suspicious_total": susp_count,
    },
    "guard_fail_breakdown": {
        "command": sum(v["guard_command"] for v in target_stats.values()),
        "placeholder": sum(v["guard_placeholder"] for v in target_stats.values()),
        "pipe": sum(v["guard_pipe"] for v in target_stats.values()),
        "quality": sum(v["guard_quality"] for v in target_stats.values()),
    },
    "suspicious_breakdown": dict(sorted(susp_types.items(), key=lambda x: -x[1])),
    "top_guard_fail_targets": top_guard_fail,
    "language_stats": {
        lang: {
            "translated": row["translated"],
            "guard_fail": row["guard_fail"],
            "cycles": row["cycles"],
            "files_count": len(row["files"]),
            "fail_rate_pct": round(
                row["guard_fail"] / (row["translated"] + row["guard_fail"]) * 100, 1
            )
            if (row["translated"] + row["guard_fail"]) > 0
            else 0,
        }
        for lang, row in sorted(lang_agg.items(), key=lambda x: -x[1]["translated"])
    },
    "coverage": {
        lang: {
            "total": row["total"],
            "translated": row["translated"],
            "coverage_pct": row["coverage_pct"],
            "identical": row["identical"],
            "placeholder": row["placeholder"],
            "missing_keys": row["missing_keys"],
            "missing_files": row.get("missing_files", 0),
            "real_remaining": row["real_remaining"],
            **({"per_file": row["per_file"]} if lang in {"pl", "es"} else {}),
        }
        for lang, row in sorted(coverage.items(), key=lambda x: -x[1]["translated"])
        if lang in {"pl", "es", "de", "fr", "pt", "it", "ru"}
    },
    "quality_snapshot": quality_snapshot,
    "strict_hourly_window": strict_hourly_window,
    "daily_summary": daily_summary,
    "guardian_log_summary": guardian_summary,
    "worker_config_snapshot": config,
    "worker_state_summary": {
        "cycle": worker_state.get("worker", {}).get("cycle", 0)
        if isinstance(worker_state.get("worker"), dict)
        else 0,
        "pid": worker_state.get("worker", {}).get("pid", 0)
        if isinstance(worker_state.get("worker"), dict)
        else 0,
        "status": worker_state.get("worker", {}).get("status", "?")
        if isinstance(worker_state.get("worker"), dict)
        else "?",
        "heartbeat": worker_state.get("worker", {}).get("heartbeat_at_utc", "?")
        if isinstance(worker_state.get("worker"), dict)
        else "?",
        "en_keys_total": worker_state.get("global", {}).get("en_keys_total", 0)
        if isinstance(worker_state.get("global"), dict)
        else 0,
        "categories_in_backoff": sum(
            1
            for cat in (
                worker_state.get("categories", {})
                if isinstance(worker_state.get("categories"), dict)
                else {}
            ).values()
            if isinstance(cat, dict) and cat.get("status") == "backoff"
        ),
    },
}

output_path = os.path.join(BASELINE_DIR, FILENAME)
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(baseline, f, indent=2, ensure_ascii=False)

print(f"Saved baseline: {output_path}")
print()

s = baseline["summary"]
print("=" * 70)
print(f" BASELINE SNAPSHOT — {TIMESTAMP}")
print(f" Okno: od {cutoff_str}")
print("=" * 70)
print()
print(f"  Total cykli:            {s['total_cycles']}")
print(f"  MIGRATION:              {mode_counts.get('MIGRATION', 0)}")
print(f"  AUTO_TRANSLATE:         {mode_counts.get('AUTO_TRANSLATE', 0)}")
print(
    f"  pending_skip:           {s['pending_skip_count']} "
    f"(all={s['pending_skip_share_pct']}%, migration={s['pending_skip_share_migration_pct']}%)"
)
print()
print(f"  Translated:             {s['total_translated']}")
print(f"  Guard fail:             {s['total_guard_fail']}")
print(f"  Guard fail rate:        {s['guard_fail_rate_pct']}%")
print(f"  No-progress entries:    {s['no_progress_entries']} ({s['no_progress_rate_pct']}%)")
print(f"  Throughput:             {s['throughput_keys_per_h']} kluczy/h")
print()

print("  Strict hourly window (JSONL-only):")
print(
    f"    hours={strict_hourly_window['window_hours']} "
    f"pending_skip={strict_hourly_window['pending_skip_share_pct']}% "
    f"guard_fail={strict_hourly_window['guard_fail_rate_pct']}% "
    f"throughput={strict_hourly_window['throughput_keys_per_h']}/h"
)
print()

gfb = baseline["guard_fail_breakdown"]
print("  Guard breakdown:")
print(f"    command:              {gfb['command']}")
print(f"    placeholder:          {gfb['placeholder']}")
print(f"    pipe:                 {gfb['pipe']}")
print(f"    quality:              {gfb['quality']}")
print()

print(f"  Suspicious total:       {s['suspicious_total']}")
for key, count in list(sorted(susp_types.items(), key=lambda x: -x[1]))[:5]:
    print(f"    {key}: {count}")
print()

print("  Quality snapshot (pilot):")
for lang in ("pl", "es"):
    row = baseline["quality_snapshot"].get(lang, {})
    if row:
        print(
            f"    {lang.upper()}: quality_score={row.get('quality_score')} "
            f"issues={row.get('issues_count')} gt_guard_fail={row.get('total_gt_guard_fail')}"
        )
print()

print("  Coverage (pilot):")
for lang in ("pl", "es"):
    if lang in baseline["coverage"]:
        row = baseline["coverage"][lang]
        print(
            f"    {lang.upper()}: {row['translated']}/{row['total']} ({row['coverage_pct']}%) "
            f"| identical={row['identical']} placeholder={row['placeholder']} missing={row['missing_keys']}"
        )
print()

print("  Guardian log summary:")
print(
    f"    entries={guardian_summary['entries']} push_ok={guardian_summary['push_ok']} "
    f"worker_ok={guardian_summary['worker_ok']} restarts={guardian_summary['restarts']} "
    f"starts_failed={guardian_summary['starts_failed']}"
)
print()

print("  Daily summary:")
print(
    f"    days={daily_summary['days_in_window']} cycles={daily_summary['cycles']} "
    f"errors={daily_summary['errors']} "
    f"auto_translate(pl={daily_summary['auto_translate_translated']['pl']}, "
    f"es={daily_summary['auto_translate_translated']['es']})"
)
print()

print("  Top guard_fail targets:")
for target in top_guard_fail[:8]:
    total = target["translated"] + target["guard_fail"]
    fail_rate = f"{target['guard_fail'] / total * 100:.0f}%" if total > 0 else "n/a"
    print(
        f"    {target['target']:<35} trans={target['translated']:>5} "
        f"gf={target['guard_fail']:>5} cmd={target['guard_command']:>5} rate={fail_rate}"
    )
print()

ws = baseline["worker_state_summary"]
print(f"  Worker: cycle={ws['cycle']} pid={ws['pid']} status={ws['status']}")
print(f"  Categories in backoff:  {ws['categories_in_backoff']}")
print(
    f"  Config: focus={config.get('focus_lang', '')}, "
    f"gt={config.get('use_gt', False)}, parallel={config.get('parallel_langs', 0)}"
)
print()

print("=" * 70)
print(" Progi sukcesu (cele planu naprawczego):")
print(
    f"   pending_skip < 25%     -> aktualnie {s['pending_skip_share_pct']}%  "
    f"{'YES' if s['pending_skip_share_pct'] < 25 else 'NO'}"
)
print(
    f"   no_progress < 20%      -> aktualnie {s['no_progress_rate_pct']}%  "
    f"{'YES' if s['no_progress_rate_pct'] < 20 else 'NO'}"
)
print(
    f"   guard_fail < 5%        -> aktualnie {s['guard_fail_rate_pct']}%  "
    f"{'YES' if s['guard_fail_rate_pct'] < 5 else 'NO'}"
)
print(
    f"   throughput > 100/h     -> aktualnie {s['throughput_keys_per_h']}/h  "
    f"{'YES' if s['throughput_keys_per_h'] > 100 else 'NO'}"
)
print(
    f"   PL coverage > 80%      -> aktualnie {baseline['coverage'].get('pl', {}).get('coverage_pct', 0)}%  "
    f"{'YES' if baseline['coverage'].get('pl', {}).get('coverage_pct', 0) > 80 else 'NO'}"
)
print(
    f"   ES coverage > 70%      -> aktualnie {baseline['coverage'].get('es', {}).get('coverage_pct', 0)}%  "
    f"{'YES' if baseline['coverage'].get('es', {}).get('coverage_pct', 0) > 70 else 'NO'}"
)
print("=" * 70)
PYEOF
