#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# i18n-statusd  —  3. daemon MVP (Status & Telemetry Aggregator)
# ═══════════════════════════════════════════════════════════════════════════════
#
# Rola:
#   1. Agregacja telemetrii z i18n/status/*
#   2. Walidacja spójności statusu (status doctor)
#   3. Generowanie KPI i rekomendacji
#   4. Opcjonalnie: odświeżenie I18N_STATUS.md niezależnie od workera
#
# Uruchomienie:
#   bash i18n-statusd.sh --once          # jednorazowy raport
#   bash i18n-statusd.sh --daemon        # ciągła pętla co 60s
#   bash i18n-statusd.sh --doctor        # tylko diagnostyka spójności
#   bash i18n-statusd.sh --kpi           # tylko KPI snapshot
#   bash i18n-statusd.sh --recommend     # rekomendacje profilu
#   bash i18n-statusd.sh --daily-report  # raport zarządczy 24h (JSON + MD)
#
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
STATUS_DIR="$WORK_DIR/i18n/status"
STATUSD_LOG="$WORK_DIR/statusd.log"
STATUSD_PID_FILE="$WORK_DIR/.statusd.pid"
STATUSD_STATE_FILE="$STATUS_DIR/statusd_state.json"
STATUSD_REPORT_FILE="$STATUS_DIR/statusd_report.json"
STATUSD_DOCTOR_FILE="$STATUS_DIR/statusd_doctor.json"
STATUSD_AUDIT_FILE="$STATUS_DIR/statusd_audit.jsonl"
STATUSD_ALERT_STATE_FILE="$STATUS_DIR/statusd_alert_state.json"
STATUSD_DAILY_REPORT_JSON="$STATUS_DIR/statusd_daily_report.json"
STATUSD_DAILY_REPORT_MD="$STATUS_DIR/statusd_daily_report.md"
AUTO_ACTIONS_ENABLED_FILE="$WORK_DIR/.statusd_auto_actions"
ALERT_WEBHOOK_URL_FILE="$WORK_DIR/.statusd_webhook_url"
ALERT_COOLDOWN_SECONDS="${STATUSD_ALERT_COOLDOWN_SECONDS:-900}"
DAILY_REPORT_MIN_INTERVAL_SECONDS="${STATUSD_DAILY_REPORT_MIN_INTERVAL_SECONDS:-3600}"
REPAIR_QUEUE_STAGNATION_HOURS="${STATUSD_REPAIR_QUEUE_STAGNATION_HOURS:-6}"
REPAIR_QUEUE_STAGNATION_MIN_SAMPLES="${STATUSD_REPAIR_QUEUE_STAGNATION_MIN_SAMPLES:-6}"
REPAIR_QUEUE_STAGNATION_MIN_DROP="${STATUSD_REPAIR_QUEUE_STAGNATION_MIN_DROP:-1}"
DAEMON_INTERVAL_SECONDS=60

export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$WORK_DIR" || exit 1

log_statusd() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$STATUSD_LOG"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 1: Agregacja telemetrii
# ═══════════════════════════════════════════════════════════════════════════════

aggregate_telemetry() {
    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_REPORT_FILE" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" <<'PYAGG'
import json, sys, os
from datetime import datetime, timezone, timedelta
from pathlib import Path

work_dir = sys.argv[1]
status_dir = sys.argv[2]
report_file = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))

now = datetime.now(timezone.utc)
report = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "version": "statusd-mvp-1.0",
}

def _safe_int(v, default=0):
    try:
        return int(v)
    except Exception:
        return default

def _parse_ts(ts):
    if not ts:
        return None
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
    except Exception:
        return None

def _analyze_repair_queue(status_dir, now, window_h, min_samples, min_drop):
    queue_latest_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
    queue_report_path = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")
    result = {
        "available": False,
        "latest_timestamp": "",
        "entries_total": 0,
        "entries_by_lang": {},
        "top_target": {
            "lang": "",
            "json_file": "",
            "key": "",
            "identical_to_en": 0,
        },
        "history_samples_total": 0,
        "history_latest_timestamp": "",
        "stagnation": {
            "window_hours": float(window_h),
            "min_samples": int(min_samples),
            "min_drop_required": int(min_drop),
            "detected": False,
            "reason": "no_data",
            "top_key": "",
            "sample_count": 0,
            "span_hours": 0.0,
            "top_locked_in_window": False,
            "baseline_count": 0,
            "latest_count": 0,
            "min_count_seen": 0,
            "best_drop": 0,
            "latest_drop": 0,
            "window_start": "",
            "window_end": "",
        },
    }

    latest = {}
    try:
        with open(queue_latest_path, encoding="utf-8") as f:
            latest = json.load(f)
    except Exception:
        latest = {}

    if isinstance(latest, dict) and latest:
        result["available"] = True
        result["latest_timestamp"] = str(latest.get("timestamp", "") or "")
        result["entries_total"] = _safe_int(latest.get("entries_total", 0))
        ebl = latest.get("entries_by_lang", {})
        if isinstance(ebl, dict):
            result["entries_by_lang"] = {str(k): _safe_int(v) for k, v in ebl.items()}
        sel = latest.get("selected", {})
        if isinstance(sel, dict):
            lang = str(sel.get("lang", "") or "")
            json_file = str(sel.get("json_file", "") or "")
            key = f"{lang}:{json_file}" if lang and json_file else ""
            cnt = _safe_int(sel.get("identical_to_en", 0))
            result["top_target"] = {
                "lang": lang,
                "json_file": json_file,
                "key": key,
                "identical_to_en": cnt,
            }

    samples = []
    if os.path.exists(queue_report_path):
        with open(queue_report_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                dt = _parse_ts(row.get("timestamp"))
                sel = row.get("selected", {})
                if not isinstance(sel, dict):
                    continue
                lang = str(sel.get("lang", "") or "")
                json_file = str(sel.get("json_file", "") or "")
                cnt = _safe_int(sel.get("identical_to_en", 0))
                if dt is None or not lang or not json_file or cnt <= 0:
                    continue
                key = f"{lang}:{json_file}"
                samples.append({
                    "dt": dt,
                    "timestamp": dt.isoformat().replace("+00:00", "Z"),
                    "lang": lang,
                    "json_file": json_file,
                    "key": key,
                    "count": cnt,
                })

    samples.sort(key=lambda x: x["dt"])
    result["history_samples_total"] = len(samples)
    if samples:
        result["history_latest_timestamp"] = samples[-1]["timestamp"]

    stagnation = result["stagnation"]
    if not samples:
        stagnation["reason"] = "no_report_samples"
        return result

    latest_sample = samples[-1]
    if not result["top_target"].get("key"):
        result["top_target"] = {
            "lang": latest_sample["lang"],
            "json_file": latest_sample["json_file"],
            "key": latest_sample["key"],
            "identical_to_en": latest_sample["count"],
        }

    focus_key = result["top_target"].get("key") or latest_sample["key"]
    focus_samples = [s for s in samples if s["key"] == focus_key]
    if not focus_samples:
        stagnation["reason"] = "focus_key_missing_in_history"
        return result

    window_h = max(float(window_h), 0.1)
    min_samples = max(int(min_samples), 1)
    min_drop = max(int(min_drop), 0)

    window_start_dt = focus_samples[-1]["dt"] - timedelta(hours=window_h)
    window_focus = [s for s in focus_samples if s["dt"] >= window_start_dt]
    window_all = [s for s in samples if s["dt"] >= window_start_dt]

    if not window_focus:
        stagnation["reason"] = "empty_window"
        return result

    counts = [s["count"] for s in window_focus]
    baseline = counts[0]
    latest_count = counts[-1]
    min_seen = min(counts)
    best_drop = baseline - min_seen
    latest_drop = baseline - latest_count
    span_h = (window_focus[-1]["dt"] - window_focus[0]["dt"]).total_seconds() / 3600.0
    has_span = span_h >= window_h
    has_samples = len(window_focus) >= min_samples
    top_locked = bool(window_all) and all(s["key"] == focus_key for s in window_all)
    no_drop = best_drop < min_drop

    detected = bool(top_locked and has_span and has_samples and no_drop and latest_count > 0)

    if detected:
        reason = "top_backlog_no_drop"
    elif not top_locked:
        reason = "top_target_changed"
    elif not has_span:
        reason = "window_too_short"
    elif not has_samples:
        reason = "insufficient_samples"
    elif not no_drop:
        reason = "drop_detected"
    else:
        reason = "not_detected"

    stagnation.update({
        "detected": detected,
        "reason": reason,
        "top_key": focus_key,
        "sample_count": len(window_focus),
        "span_hours": round(span_h, 3),
        "top_locked_in_window": bool(top_locked),
        "baseline_count": int(baseline),
        "latest_count": int(latest_count),
        "min_count_seen": int(min_seen),
        "best_drop": int(best_drop),
        "latest_drop": int(latest_drop),
        "window_start": window_focus[0]["timestamp"],
        "window_end": window_focus[-1]["timestamp"],
    })

    return result

# ── Heartbeat / worker state ─────────────────────────────────────────────
worker_state = {}
try:
    with open(os.path.join(status_dir, "worker_state.json"), encoding="utf-8") as f:
        worker_state = json.load(f)
except Exception:
    pass

heartbeat_at = ""
heartbeat_age_s = -1
try:
    w = worker_state.get("worker", {})
    heartbeat_at = w.get("heartbeat_at_utc", "")
    if heartbeat_at:
        hb_dt = datetime.fromisoformat(heartbeat_at.replace("Z", "+00:00"))
        heartbeat_age_s = (now - hb_dt).total_seconds()
except Exception:
    pass

report["worker"] = {
    "heartbeat_at": heartbeat_at,
    "heartbeat_age_s": round(heartbeat_age_s, 1),
    "cycle": worker_state.get("worker", {}).get("cycle", -1),
    "mode": worker_state.get("worker", {}).get("mode", "?"),
    "category": worker_state.get("worker", {}).get("category", "?"),
    "pid_alive": os.path.exists(os.path.join(work_dir, ".worker_simple.pid")),
}

# ── Guardian health ──────────────────────────────────────────────────────
guardian_health = {}
try:
    with open(os.path.join(status_dir, "guardian_health.json"), encoding="utf-8") as f:
        guardian_health = json.load(f)
except Exception:
    pass

report["guardian"] = {
    "state": guardian_health.get("state", "unknown"),
    "throughput_per_h": guardian_health.get("throughput_per_h", 0),
    "guard_fail_rate_pct": guardian_health.get("guard_fail_rate_pct", 0),
    "issues": guardian_health.get("issues", []),
}

# ── Guard report (ostatnie N wpisów) ────────────────────────────────────
guard_entries = []
guard_file = os.path.join(status_dir, "translation_guard_report.jsonl")
try:
    with open(guard_file, encoding="utf-8") as f:
        for line in f:
            try:
                guard_entries.append(json.loads(line.strip()))
            except Exception:
                continue
except Exception:
    pass

last_200 = guard_entries[-200:]
total_translated = sum(e.get("translated", 0) for e in last_200)
total_gf = sum(e.get("guard_fail", 0) for e in last_200)
gf_rate = total_gf / max(total_translated + total_gf, 1) * 100

# Per-lang stats
lang_stats = {}
for e in last_200:
    lang = e.get("language", "?")
    if lang not in lang_stats:
        lang_stats[lang] = {"translated": 0, "guard_fail": 0, "cycles": 0}
    lang_stats[lang]["translated"] += e.get("translated", 0)
    lang_stats[lang]["guard_fail"] += e.get("guard_fail", 0)
    lang_stats[lang]["cycles"] += 1

report["translation_kpi"] = {
    "window_entries": len(last_200),
    "total_translated": total_translated,
    "total_guard_fail": total_gf,
    "guard_fail_rate_pct": round(gf_rate, 2),
    "per_lang": lang_stats,
}

# ── Adaptive batch state ────────────────────────────────────────────────
adaptive = {}
try:
    with open(os.path.join(status_dir, "adaptive_batch_state.json"), encoding="utf-8") as f:
        adaptive = json.load(f)
except Exception:
    pass

report["adaptive_batch"] = {
    "batch_size": adaptive.get("batch_size", "?"),
    "guard_fail_rate": adaptive.get("guard_fail_rate", "?"),
    "reason": adaptive.get("reason", "?"),
}

# ── Dispatch state ──────────────────────────────────────────────────────
dispatch = {}
try:
    with open(os.path.join(status_dir, "translation_dispatch_state.json"), encoding="utf-8") as f:
        dispatch = json.load(f)
except Exception:
    pass

report["dispatch"] = {
    "last_target": dispatch.get("last_target_key", "?"),
    "pending_total": dispatch.get("last_pending_total", 0),
    "candidates": dispatch.get("active_candidates_count", 0),
    "skipped_backoff": dispatch.get("skipped_backoff", 0),
    "skipped_guard_fail": dispatch.get("skipped_guard_fail", 0),
}

# ── Coverage (z translation_global_overview) ────────────────────────────
overview = {}
try:
    with open(os.path.join(status_dir, "translation_global_overview.json"), encoding="utf-8") as f:
        overview = json.load(f)
except Exception:
    pass

coverage = {}
languages = overview.get("languages", [])

# Aktualny kontrakt: languages[] z completion_pct/missing_keys/english_copy_keys.
if isinstance(languages, list) and languages:
    for row in languages:
        lang = str(row.get("lang", "")).lower()
        if not lang:
            continue
        coverage[lang] = {
            "coverage_pct": row.get("completion_pct", row.get("coverage_pct", 0)),
            "missing": row.get("missing_keys", row.get("missing", 0)),
            "en_copy": row.get("english_copy_keys", row.get("en_copy", 0)),
        }

# Fallback dla starszego kontraktu.
if not coverage:
    per_lang_summary = overview.get("per_language_summary", {})
    for lang, ls in per_lang_summary.items():
        coverage[str(lang).lower()] = {
            "coverage_pct": ls.get("coverage_pct", 0),
            "missing": ls.get("missing", 0),
            "en_copy": ls.get("en_copy", 0),
        }

for lang in ["pl", "es", "de", "fr", "pt", "it", "ru"]:
    coverage.setdefault(lang, {"coverage_pct": 0, "missing": 0, "en_copy": 0})

report["coverage"] = {k: coverage[k] for k in sorted(coverage.keys())}

# ── Repair queue health (identical_to_en backlog) ────────────────────────
report["repair_queue"] = _analyze_repair_queue(
    status_dir=status_dir,
    now=now,
    window_h=repair_window_h,
    min_samples=repair_min_samples,
    min_drop=repair_min_drop,
)

# ── Transition log (ostatnie 5 przejść) ─────────────────────────────────
transitions = []
trans_file = os.path.join(status_dir, "transition_log.jsonl")
try:
    with open(trans_file, encoding="utf-8") as f:
        for line in f:
            try:
                transitions.append(json.loads(line.strip()))
            except Exception:
                continue
    report["recent_transitions"] = transitions[-5:]
except Exception:
    report["recent_transitions"] = []

# ── Errors (ostatnie 3) ────────────────────────────────────────────────
errors = []
err_file = os.path.join(status_dir, "errors.jsonl")
try:
    with open(err_file, encoding="utf-8") as f:
        for line in f:
            try:
                errors.append(json.loads(line.strip()))
            except Exception:
                continue
    report["recent_errors"] = errors[-3:]
except Exception:
    report["recent_errors"] = []

# ── Zapis raportu ───────────────────────────────────────────────────────
try:
    with open(report_file, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print("OK")
except Exception as e:
    print(f"ERROR: {e}")
PYAGG
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 2: Status Doctor (wykrywanie niespójności)
# ═══════════════════════════════════════════════════════════════════════════════

run_status_doctor() {
    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_DOCTOR_FILE" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" <<'PYDOCTOR'
import json, sys, os
from datetime import datetime, timezone, timedelta

work_dir = sys.argv[1]
status_dir = sys.argv[2]
doctor_file = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))

now = datetime.now(timezone.utc)
issues = []
warnings = []
ok_checks = []

def _safe_int(v, default=0):
    try:
        return int(v)
    except Exception:
        return default

def _parse_ts(ts):
    if not ts:
        return None
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
    except Exception:
        return None

def _read_repair_queue_health():
    queue_latest_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
    queue_report_path = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")
    data = {
        "available": False,
        "latest_timestamp": "",
        "top_key": "",
        "top_count": 0,
        "stagnation": {
            "detected": False,
            "reason": "no_data",
            "sample_count": 0,
            "span_hours": 0.0,
            "baseline_count": 0,
            "latest_count": 0,
            "best_drop": 0,
        },
    }

    latest = {}
    try:
        with open(queue_latest_path, encoding="utf-8") as f:
            latest = json.load(f)
    except Exception:
        latest = {}

    if isinstance(latest, dict) and latest:
        data["available"] = True
        data["latest_timestamp"] = str(latest.get("timestamp", "") or "")
        sel = latest.get("selected", {})
        if isinstance(sel, dict):
            lang = str(sel.get("lang", "") or "")
            json_file = str(sel.get("json_file", "") or "")
            if lang and json_file:
                data["top_key"] = f"{lang}:{json_file}"
            data["top_count"] = _safe_int(sel.get("identical_to_en", 0))

    samples = []
    if os.path.exists(queue_report_path):
        with open(queue_report_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                dt = _parse_ts(row.get("timestamp"))
                sel = row.get("selected", {})
                if not isinstance(sel, dict):
                    continue
                lang = str(sel.get("lang", "") or "")
                json_file = str(sel.get("json_file", "") or "")
                count = _safe_int(sel.get("identical_to_en", 0))
                if dt is None or not lang or not json_file or count <= 0:
                    continue
                samples.append({
                    "dt": dt,
                    "key": f"{lang}:{json_file}",
                    "count": count,
                })

    samples.sort(key=lambda x: x["dt"])
    if not samples:
        data["stagnation"]["reason"] = "no_report_samples"
        return data

    latest_sample = samples[-1]
    focus_key = data["top_key"] or latest_sample["key"]
    focus_samples = [s for s in samples if s["key"] == focus_key]
    if not focus_samples:
        data["stagnation"]["reason"] = "focus_key_missing_in_history"
        return data

    window_h = max(float(repair_window_h), 0.1)
    min_samples = max(int(repair_min_samples), 1)
    min_drop = max(int(repair_min_drop), 0)
    window_start_dt = focus_samples[-1]["dt"] - timedelta(hours=window_h)
    window_focus = [s for s in focus_samples if s["dt"] >= window_start_dt]
    window_all = [s for s in samples if s["dt"] >= window_start_dt]
    if not window_focus:
        data["stagnation"]["reason"] = "empty_window"
        return data

    counts = [s["count"] for s in window_focus]
    baseline = counts[0]
    latest_count = counts[-1]
    min_seen = min(counts)
    best_drop = baseline - min_seen
    span_h = (window_focus[-1]["dt"] - window_focus[0]["dt"]).total_seconds() / 3600.0
    top_locked = bool(window_all) and all(s["key"] == focus_key for s in window_all)
    has_span = span_h >= window_h
    has_samples = len(window_focus) >= min_samples
    no_drop = best_drop < min_drop
    detected = bool(top_locked and has_span and has_samples and no_drop and latest_count > 0)

    if detected:
        reason = "top_backlog_no_drop"
    elif not top_locked:
        reason = "top_target_changed"
    elif not has_span:
        reason = "window_too_short"
    elif not has_samples:
        reason = "insufficient_samples"
    elif not no_drop:
        reason = "drop_detected"
    else:
        reason = "not_detected"

    data["stagnation"] = {
        "detected": detected,
        "reason": reason,
        "sample_count": len(window_focus),
        "span_hours": round(span_h, 3),
        "baseline_count": int(baseline),
        "latest_count": int(latest_count),
        "best_drop": int(best_drop),
    }
    if not data["top_key"]:
        data["top_key"] = focus_key
    if data["top_count"] <= 0:
        data["top_count"] = int(latest_count)
    return data

# ── 1. Freshness: heartbeat nie starszy niż 3 min ───────────────────────
try:
    with open(os.path.join(status_dir, "worker_state.json"), encoding="utf-8") as f:
        ws = json.load(f)
    hb = ws.get("worker", {}).get("heartbeat_at_utc", "")
    if hb:
        hb_dt = datetime.fromisoformat(hb.replace("Z", "+00:00"))
        age_s = (now - hb_dt).total_seconds()
        if age_s > 300:
            issues.append(f"STALE_HEARTBEAT: heartbeat sprzed {age_s:.0f}s (>300s)")
        elif age_s > 180:
            warnings.append(f"AGING_HEARTBEAT: heartbeat sprzed {age_s:.0f}s (>180s)")
        else:
            ok_checks.append(f"heartbeat_fresh ({age_s:.0f}s)")
    else:
        issues.append("NO_HEARTBEAT: brak heartbeat w worker_state.json")
except Exception as e:
    issues.append(f"HEARTBEAT_READ_ERROR: {e}")

# ── 2. Spójność LIVE vs worker_state ────────────────────────────────────
try:
    md_path = os.path.join(work_dir, "I18N_STATUS.md")
    if os.path.exists(md_path):
        md_age = (now - datetime.fromtimestamp(os.path.getmtime(md_path), tz=timezone.utc)).total_seconds()
        if md_age > 600:
            warnings.append(f"STATUS_MD_STALE: I18N_STATUS.md nie aktualizowany od {md_age:.0f}s")
        else:
            ok_checks.append(f"status_md_fresh ({md_age:.0f}s)")
    else:
        issues.append("NO_STATUS_MD: brak I18N_STATUS.md")
except Exception as e:
    warnings.append(f"STATUS_MD_CHECK_ERROR: {e}")

# ── 3. Guard report JSONL rośnie ────────────────────────────────────────
try:
    guard_file = os.path.join(status_dir, "translation_guard_report.jsonl")
    if os.path.exists(guard_file):
        file_age = (now - datetime.fromtimestamp(os.path.getmtime(guard_file), tz=timezone.utc)).total_seconds()
        if file_age > 600:
            warnings.append(f"GUARD_REPORT_STALE: guard_report nie aktualizowany od {file_age:.0f}s")
        else:
            ok_checks.append(f"guard_report_fresh ({file_age:.0f}s)")
    else:
        issues.append("NO_GUARD_REPORT: brak translation_guard_report.jsonl")
except Exception:
    pass

# ── 4. Dispatch state spójny ───────────────────────────────────────────
try:
    with open(os.path.join(status_dir, "translation_dispatch_state.json"), encoding="utf-8") as f:
        ds = json.load(f)
    ts_str = ds.get("timestamp", "")
    if ts_str:
        ds_dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        ds_age = (now - ds_dt).total_seconds()
        if ds_age > 600:
            warnings.append(f"DISPATCH_STALE: dispatch state sprzed {ds_age:.0f}s")
        else:
            ok_checks.append(f"dispatch_fresh ({ds_age:.0f}s)")
    blacklist = ds.get("guard_fail_blacklist", {})
    if blacklist:
        for k, v in blacklist.items():
            if v >= 10:
                warnings.append(f"BLACKLISTED_TARGET: {k} ma {v} guard_fail w blackliście")
except Exception:
    pass

# ── 5. PID alive vs heartbeat ──────────────────────────────────────────
try:
    pid_file = os.path.join(work_dir, ".worker_simple.pid")
    pid_exists = os.path.exists(pid_file)
    if pid_exists:
        with open(pid_file) as f:
            pid = f.read().strip()
        proc_alive = os.path.exists(f"/proc/{pid}")
        if not proc_alive:
            issues.append(f"ZOMBIE_PID: PID file istnieje ({pid}), ale proces nie żyje")
        else:
            ok_checks.append(f"worker_pid_alive ({pid})")
    else:
        warnings.append("NO_PID_FILE: brak .worker_simple.pid")
except Exception:
    pass

# ── 6. Guardian health spójny ──────────────────────────────────────────
try:
    with open(os.path.join(status_dir, "guardian_health.json"), encoding="utf-8") as f:
        gh = json.load(f)
    gh_state = gh.get("state", "unknown")
    if gh_state == "stuck":
        issues.append(f"GUARDIAN_STUCK: guardian raportuje stuck")
    elif gh_state == "degraded":
        warnings.append(f"GUARDIAN_DEGRADED: guardian raportuje degraded")
    elif gh_state == "healthy":
        ok_checks.append("guardian_healthy")
except Exception:
    warnings.append("NO_GUARDIAN_HEALTH: brak guardian_health.json")

# ── 7. Weryfikacja krytycznych plików ──────────────────────────────────
required_files = [
    "worker_state.json",
    "translation_guard_report.jsonl",
    "translation_dispatch_state.json",
    "worker_cycle_perf.jsonl",
]
for rf in required_files:
    path = os.path.join(status_dir, rf)
    if not os.path.exists(path):
        issues.append(f"MISSING_FILE: {rf}")
    elif os.path.getsize(path) == 0:
        warnings.append(f"EMPTY_FILE: {rf}")

# ── 8. Repair queue health / stagnacja backlogu ─────────────────────────
try:
    rq = _read_repair_queue_health()
    if not rq.get("available", False):
        warnings.append("NO_REPAIR_QUEUE: brak identical_to_en_repair_queue.json")
    else:
        rq_ts = _parse_ts(rq.get("latest_timestamp", ""))
        if rq_ts is not None:
            rq_age = (now - rq_ts).total_seconds()
            if rq_age > 1800:
                warnings.append(f"REPAIR_QUEUE_STALE: queue snapshot sprzed {rq_age:.0f}s (>1800s)")
            else:
                ok_checks.append(f"repair_queue_fresh ({rq_age:.0f}s)")
        st = rq.get("stagnation", {}) if isinstance(rq.get("stagnation", {}), dict) else {}
        if st.get("detected", False):
            warnings.append(
                f"REPAIR_QUEUE_STAGNATION: {rq.get('top_key','?')} brak spadku przez ~{st.get('span_hours', 0)}h "
                f"(baseline={st.get('baseline_count', 0)} latest={st.get('latest_count', 0)})"
            )
        elif st.get("reason", "") == "drop_detected":
            ok_checks.append(
                f"repair_queue_drop_detected ({rq.get('top_key','?')} best_drop={st.get('best_drop', 0)})"
            )
except Exception as e:
    warnings.append(f"REPAIR_QUEUE_CHECK_ERROR: {e}")

# ── Ocena ogólna ───────────────────────────────────────────────────────
if issues:
    overall = "CRITICAL"
elif warnings:
    overall = "WARNING"
else:
    overall = "HEALTHY"

doctor_report = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "overall": overall,
    "issues_count": len(issues),
    "warnings_count": len(warnings),
    "ok_count": len(ok_checks),
    "issues": issues,
    "warnings": warnings,
    "ok": ok_checks,
}

try:
    with open(doctor_file, "w", encoding="utf-8") as f:
        json.dump(doctor_report, f, indent=2, ensure_ascii=False)
except Exception:
    pass

# Wypisz na stdout czytelne podsumowanie
icon = {"HEALTHY": "🟢", "WARNING": "🟡", "CRITICAL": "🔴"}.get(overall, "⚪")
print(f"{icon} Status Doctor: {overall} ({len(issues)} issues, {len(warnings)} warnings, {len(ok_checks)} OK)")
for i in issues:
    print(f"  🔴 {i}")
for w in warnings:
    print(f"  🟡 {w}")
for o in ok_checks:
    print(f"  🟢 {o}")
PYDOCTOR
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 3: KPI Snapshot
# ═══════════════════════════════════════════════════════════════════════════════

generate_kpi_snapshot() {
    python3 - "$STATUS_DIR" <<'PYKPI'
import json, sys, os
from datetime import datetime, timezone

status_dir = sys.argv[1]
now = datetime.now(timezone.utc)

# Guard report KPI
entries = []
guard_file = os.path.join(status_dir, "translation_guard_report.jsonl")
try:
    with open(guard_file, encoding="utf-8") as f:
        for line in f:
            try: entries.append(json.loads(line.strip()))
            except: continue
except: pass

last_50 = entries[-50:]
last_200 = entries[-200:]

def _kpi(window):
    t = sum(e.get("translated", 0) for e in window)
    gf = sum(e.get("guard_fail", 0) for e in window)
    rate = gf / max(t + gf, 1) * 100
    langs = {}
    for e in window:
        l = e.get("language", "?")
        langs[l] = langs.get(l, 0) + 1
    return {"translated": t, "guard_fail": gf, "gf_rate_pct": round(rate, 2), "entries": len(window), "lang_distribution": langs}

print("═══ KPI Snapshot ═══")
print(f"Czas: {now.isoformat().replace('+00:00', 'Z')}")
print()

k50 = _kpi(last_50)
k200 = _kpi(last_200)

print(f"Ostatnie 50 cykli:")
print(f"  translated={k50['translated']}  guard_fail={k50['guard_fail']}  gf_rate={k50['gf_rate_pct']}%")
print(f"  języki: {k50['lang_distribution']}")
print()
print(f"Ostatnie 200 cykli:")
print(f"  translated={k200['translated']}  guard_fail={k200['guard_fail']}  gf_rate={k200['gf_rate_pct']}%")
print(f"  języki: {k200['lang_distribution']}")

# Adaptive batch
try:
    with open(os.path.join(status_dir, "adaptive_batch_state.json")) as f:
        ab = json.load(f)
    print(f"\nAdaptive batch: size={ab.get('batch_size','?')} reason={ab.get('reason','?')}")
except: pass

# Guardian health
try:
    with open(os.path.join(status_dir, "guardian_health.json")) as f:
        gh = json.load(f)
    print(f"Guardian: state={gh.get('state','?')} throughput={gh.get('throughput_per_h',0)}/h issues={gh.get('issues',[])}")
except: pass

# Coverage PL/ES
try:
    with open(os.path.join(status_dir, "translation_global_overview.json")) as f:
        ov = json.load(f)
    lang_map = {}
    for row in ov.get("languages", []):
        lang = str(row.get("lang", "")).lower()
        if not lang:
            continue
        lang_map[lang] = {
            "coverage_pct": row.get("completion_pct", row.get("coverage_pct", 0)),
            "missing": row.get("missing_keys", row.get("missing", 0)),
            "en_copy": row.get("english_copy_keys", row.get("en_copy", 0)),
        }
    if not lang_map:
        for lang, row in ov.get("per_language_summary", {}).items():
            lang_map[str(lang).lower()] = {
                "coverage_pct": row.get("coverage_pct", 0),
                "missing": row.get("missing", 0),
                "en_copy": row.get("en_copy", 0),
            }
    for lang in ["pl", "es"]:
        ls = lang_map.get(lang, {})
        print(f"Coverage {lang}: {ls.get('coverage_pct',0):.1f}% missing={ls.get('missing',0)} en_copy={ls.get('en_copy',0)}")
except: pass

# Gate checks
print()
gf_ok = k200["gf_rate_pct"] < 8
ps_zero = True  # pending_skip sprawdzane osobno
print(f"Gate 1 checks:")
print(f"  guard_fail_rate < 8%: {'PASS' if gf_ok else 'FAIL'} ({k200['gf_rate_pct']}%)")
PYKPI
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 4: Rekomendacje profilu
# ═══════════════════════════════════════════════════════════════════════════════

generate_recommendations() {
    python3 - "$WORK_DIR" "$STATUS_DIR" <<'PYREC'
import json, sys, os
from datetime import datetime, timezone

work_dir = sys.argv[1]
status_dir = sys.argv[2]

now = datetime.now(timezone.utc)
recommendations = []

# Guard report
entries = []
try:
    with open(os.path.join(status_dir, "translation_guard_report.jsonl"), encoding="utf-8") as f:
        for line in f:
            try: entries.append(json.loads(line.strip()))
            except: continue
except: pass

last_100 = entries[-100:]
total_t = sum(e.get("translated", 0) for e in last_100)
total_gf = sum(e.get("guard_fail", 0) for e in last_100)
gf_rate = total_gf / max(total_t + total_gf, 1) * 100

# Rekomendacja 1: guard_fail_rate
if gf_rate > 15:
    recommendations.append({
        "priority": "HIGH",
        "action": "SWITCH_PROFILE quality_repair",
        "reason": f"guard_fail_rate={gf_rate:.1f}% — wymagana naprawa jakości",
    })
elif gf_rate > 8:
    recommendations.append({
        "priority": "MEDIUM",
        "action": "REDUCE_BATCH",
        "reason": f"guard_fail_rate={gf_rate:.1f}% — rozważ zmniejszenie batcha",
    })

# Rekomendacja 2: coverage pilot
try:
    with open(os.path.join(status_dir, "translation_global_overview.json"), encoding="utf-8") as f:
        ov = json.load(f)
    lang_map = {}
    for row in ov.get("languages", []):
        lang = str(row.get("lang", "")).lower()
        if not lang:
            continue
        lang_map[lang] = row
    if lang_map:
        pl_cov = lang_map.get("pl", {}).get("completion_pct", 0)
        es_cov = lang_map.get("es", {}).get("completion_pct", 0)
    else:
        legacy = ov.get("per_language_summary", {})
        pl_cov = legacy.get("pl", {}).get("coverage_pct", 0)
        es_cov = legacy.get("es", {}).get("coverage_pct", 0)
    if min(pl_cov, es_cov) >= 85:
        recommendations.append({
            "priority": "LOW",
            "action": "SWITCH_PROFILE translations_random",
            "reason": f"PL={pl_cov:.1f}% ES={es_cov:.1f}% — pilot prawie gotowy, rozważ rollout",
        })
    elif abs(pl_cov - es_cov) > 15:
        slower_lang = "ES" if es_cov < pl_cov else "PL"
        recommendations.append({
            "priority": "MEDIUM",
            "action": f"FOCUS_LANG {slower_lang.lower()}",
            "reason": f"Nierównowaga PL={pl_cov:.1f}% vs ES={es_cov:.1f}%",
        })
except Exception:
    pass

# Rekomendacja 3: migrations
try:
    with open(os.path.join(work_dir, ".i18n_category_state.json"), encoding="utf-8") as f:
        cs = json.load(f)
    if not cs.get("migrations_done", False):
        recommendations.append({
            "priority": "INFO",
            "action": "CONSIDER migration_only PROFILE",
            "reason": "Są oczekujące migracje — rozważ profil migration_only",
        })
except Exception:
    pass

# Rekomendacja 4: throughput
try:
    with open(os.path.join(status_dir, "guardian_health.json"), encoding="utf-8") as f:
        gh = json.load(f)
    tp = gh.get("throughput_per_h", 0)
    if tp < 50 and tp > 0:
        recommendations.append({
            "priority": "MEDIUM",
            "action": "INVESTIGATE_LOW_THROUGHPUT",
            "reason": f"throughput={tp:.0f}/h — poniżej minimum 50/h",
        })
except Exception:
    pass

# Wypisz
if not recommendations:
    print("✅ Brak rekomendacji — system działa optymalnie")
else:
    print(f"📋 {len(recommendations)} rekomendacji:")
    for r in recommendations:
        icon = {"HIGH": "🔴", "MEDIUM": "🟡", "LOW": "🟢", "INFO": "ℹ️"}.get(r["priority"], "⚪")
        print(f"  {icon} [{r['priority']}] {r['action']}")
        print(f"     Powód: {r['reason']}")
PYREC
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 5: Guardrails auto-akcji (P1.3)
# ═══════════════════════════════════════════════════════════════════════════════
#
# Wymagania:
#   1. Idempotencja — ten sam trigger nie wykonuje komendy wielokrotnie
#   2. Cooldown — minimalny odstęp czasu między auto-akcjami per typ
#   3. Walidacja pre/post — akcja tylko po przejściu kontroli wejścia
#   4. Audit trail — pełny log „kto/co/dlaczego/jaki efekt"
#
# Auto-akcje wyłączone domyślnie. Włączenie: touch .statusd_auto_actions
# Wyłączenie jedną flagą: rm .statusd_auto_actions
# ═══════════════════════════════════════════════════════════════════════════════

auto_actions_enabled() {
    [ -f "$AUTO_ACTIONS_ENABLED_FILE" ]
}

run_auto_actions() {
    if ! auto_actions_enabled; then
        echo "ℹ️  Auto-akcje wyłączone (brak pliku .statusd_auto_actions)"
        return 0
    fi

    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_AUDIT_FILE" <<'PYGUARDRAILS'
import json, sys, os
from datetime import datetime, timezone, timedelta

work_dir = sys.argv[1]
status_dir = sys.argv[2]
audit_file = sys.argv[3]

now = datetime.now(timezone.utc)

# ── Konfiguracja auto-akcji ──────────────────────────────────────────────
AUTO_ACTION_DEFS = {
    "REDUCE_BATCH_ON_HIGH_GF": {
        "cooldown_minutes": 30,
        "description": "Zmniejsz batch gdy guard_fail_rate > 15%",
    },
    "INCREASE_BATCH_ON_LOW_GF": {
        "cooldown_minutes": 60,
        "description": "Zwiększ batch gdy guard_fail_rate < 3%",
    },
    "UNFOCUS_LANG_ON_IMBALANCE": {
        "cooldown_minutes": 120,
        "description": "Usuń focus_lang gdy nierównowaga PL/ES > 30pp",
    },
    "PAUSE_ON_CRITICAL": {
        "cooldown_minutes": 15,
        "description": "Pauza workera gdy status doctor = CRITICAL",
    },
}

# ── Załaduj historię audytu (ostatnie 50 wpisów) ────────────────────────
audit_history = []
try:
    with open(audit_file, encoding="utf-8") as f:
        for line in f:
            try:
                audit_history.append(json.loads(line.strip()))
            except Exception:
                continue
except FileNotFoundError:
    pass

def _last_execution_ts(action_type: str) -> str:
    """Znajdź ostatni timestamp wykonania danej akcji."""
    for entry in reversed(audit_history):
        if entry.get("action_type") == action_type and entry.get("status") == "executed":
            return entry.get("timestamp", "")
    return ""

def _cooldown_ok(action_type: str) -> bool:
    """Sprawdź cooldown dla akcji."""
    cfg = AUTO_ACTION_DEFS.get(action_type, {})
    cooldown_min = cfg.get("cooldown_minutes", 60)
    last_ts = _last_execution_ts(action_type)
    if not last_ts:
        return True
    try:
        last_dt = datetime.fromisoformat(last_ts.replace("Z", "+00:00"))
        return (now - last_dt).total_seconds() >= cooldown_min * 60
    except Exception:
        return True

def _idempotent_check(action_type: str, trigger_fingerprint: str) -> bool:
    """Sprawdź czy ta sama akcja z tym samym triggerem nie była już wykonana."""
    for entry in reversed(audit_history[-20:]):
        if (entry.get("action_type") == action_type
            and entry.get("trigger_fingerprint") == trigger_fingerprint
            and entry.get("status") == "executed"):
            return False  # już wykonano — idempotencja blokuje
    return True

def _audit_log(action_type, trigger, precheck, result, postcheck, status="executed"):
    """Zapisz wpis audytowy."""
    entry = {
        "timestamp": now.isoformat().replace("+00:00", "Z"),
        "action_type": action_type,
        "trigger": trigger,
        "trigger_fingerprint": f"{action_type}:{trigger}",
        "precheck": precheck,
        "result": result,
        "postcheck": postcheck,
        "status": status,
        "source": "i18n-statusd",
    }
    try:
        with open(audit_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass
    return entry

def _write_worker_command(cmd: str):
    """Zapisz komendę do worker_commands.txt (worker ją odczyta)."""
    cmd_file = os.path.join(work_dir, "worker_commands.txt")
    try:
        with open(cmd_file, "a", encoding="utf-8") as f:
            f.write(cmd + "\n")
    except Exception:
        pass

# ── Załaduj metryki ──────────────────────────────────────────────────────
guard_entries = []
try:
    with open(os.path.join(status_dir, "translation_guard_report.jsonl"), encoding="utf-8") as f:
        for line in f:
            try:
                guard_entries.append(json.loads(line.strip()))
            except Exception:
                continue
except Exception:
    pass

last_50 = guard_entries[-50:]
total_t = sum(e.get("translated", 0) for e in last_50)
total_gf = sum(e.get("guard_fail", 0) for e in last_50)
gf_rate = total_gf / max(total_t + total_gf, 1) * 100

# PL/ES balance
pl_cycles = sum(1 for e in last_50 if e.get("language") == "pl")
es_cycles = sum(1 for e in last_50 if e.get("language") == "es")
balance_diff = abs(pl_cycles - es_cycles) / max(len(last_50), 1) * 100

# Doctor state
doctor_overall = "HEALTHY"
try:
    with open(os.path.join(status_dir, "statusd_doctor.json"), encoding="utf-8") as f:
        doc = json.load(f)
    doctor_overall = doc.get("overall", "HEALTHY")
except Exception:
    pass

executed = []

# ── Akcja 1: REDUCE_BATCH_ON_HIGH_GF ────────────────────────────────────
action = "REDUCE_BATCH_ON_HIGH_GF"
if gf_rate > 15 and len(last_50) >= 20:
    trigger = f"gf_rate={gf_rate:.1f}%"
    fingerprint = f"{action}:gf>{15}"
    precheck = f"gf_rate={gf_rate:.1f}%, entries={len(last_50)}"
    if _cooldown_ok(action) and _idempotent_check(action, fingerprint):
        # Wykonaj: zmniejsz batch w worker_config.json
        try:
            cfg_path = os.path.join(work_dir, "worker_config.json")
            with open(cfg_path, encoding="utf-8") as f:
                cfg = json.load(f)
            old_limit = cfg.get("translate_limit", 80)
            new_limit = max(20, old_limit // 2)
            cfg["translate_limit"] = new_limit
            with open(cfg_path, "w", encoding="utf-8") as f:
                json.dump(cfg, f, indent=2, ensure_ascii=False)
            result = f"translate_limit: {old_limit} → {new_limit}"
            postcheck = f"config zapisany, nowy limit={new_limit}"
            _audit_log(action, trigger, precheck, result, postcheck)
            executed.append(f"🔴 {action}: {result}")
        except Exception as e:
            _audit_log(action, trigger, precheck, f"ERROR: {e}", "", status="failed")
    else:
        _audit_log(action, trigger, precheck, "SKIPPED (cooldown/idempotent)", "", status="skipped")

# ── Akcja 2: INCREASE_BATCH_ON_LOW_GF ───────────────────────────────────
action = "INCREASE_BATCH_ON_LOW_GF"
if gf_rate < 3 and len(last_50) >= 30:
    trigger = f"gf_rate={gf_rate:.1f}%"
    fingerprint = f"{action}:gf<{3}"
    precheck = f"gf_rate={gf_rate:.1f}%, entries={len(last_50)}"
    if _cooldown_ok(action) and _idempotent_check(action, fingerprint):
        try:
            cfg_path = os.path.join(work_dir, "worker_config.json")
            with open(cfg_path, encoding="utf-8") as f:
                cfg = json.load(f)
            old_limit = cfg.get("translate_limit", 80)
            new_limit = min(120, int(old_limit * 1.5))
            if new_limit != old_limit:
                cfg["translate_limit"] = new_limit
                with open(cfg_path, "w", encoding="utf-8") as f:
                    json.dump(cfg, f, indent=2, ensure_ascii=False)
                result = f"translate_limit: {old_limit} → {new_limit}"
                postcheck = f"config zapisany, nowy limit={new_limit}"
                _audit_log(action, trigger, precheck, result, postcheck)
                executed.append(f"🟢 {action}: {result}")
            else:
                _audit_log(action, trigger, precheck, "SKIPPED (already at max)", "", status="skipped")
        except Exception as e:
            _audit_log(action, trigger, precheck, f"ERROR: {e}", "", status="failed")

# ── Akcja 3: UNFOCUS_LANG_ON_IMBALANCE ──────────────────────────────────
action = "UNFOCUS_LANG_ON_IMBALANCE"
if balance_diff > 30 and len(last_50) >= 20:
    trigger = f"balance_diff={balance_diff:.0f}pp (PL={pl_cycles}, ES={es_cycles})"
    fingerprint = f"{action}:diff>{30}"
    precheck = f"PL={pl_cycles}, ES={es_cycles}, diff={balance_diff:.0f}pp"
    if _cooldown_ok(action) and _idempotent_check(action, fingerprint):
        try:
            cfg_path = os.path.join(work_dir, "worker_config.json")
            with open(cfg_path, encoding="utf-8") as f:
                cfg = json.load(f)
            old_focus = cfg.get("focus_lang", "")
            if old_focus:
                cfg["focus_lang"] = ""
                with open(cfg_path, "w", encoding="utf-8") as f:
                    json.dump(cfg, f, indent=2, ensure_ascii=False)
                result = f"focus_lang: '{old_focus}' → '' (usunięto)"
                postcheck = "config zapisany, focus_lang wyczyszczony"
                _audit_log(action, trigger, precheck, result, postcheck)
                executed.append(f"🟡 {action}: {result}")
            else:
                _audit_log(action, trigger, precheck, "SKIPPED (focus_lang already empty)", "", status="skipped")
        except Exception as e:
            _audit_log(action, trigger, precheck, f"ERROR: {e}", "", status="failed")

# ── Akcja 4: PAUSE_ON_CRITICAL ──────────────────────────────────────────
action = "PAUSE_ON_CRITICAL"
if doctor_overall == "CRITICAL":
    trigger = f"doctor_overall=CRITICAL"
    fingerprint = f"{action}:critical"
    precheck = f"doctor={doctor_overall}"
    if _cooldown_ok(action) and _idempotent_check(action, fingerprint):
        try:
            cfg_path = os.path.join(work_dir, "worker_config.json")
            with open(cfg_path, encoding="utf-8") as f:
                cfg = json.load(f)
            if not cfg.get("paused", False):
                cfg["paused"] = True
                with open(cfg_path, "w", encoding="utf-8") as f:
                    json.dump(cfg, f, indent=2, ensure_ascii=False)
                result = "paused: false → true"
                postcheck = "worker zapauzowany do ręcznej inspekcji"
                _audit_log(action, trigger, precheck, result, postcheck)
                executed.append(f"🔴 {action}: {result}")
            else:
                _audit_log(action, trigger, precheck, "SKIPPED (already paused)", "", status="skipped")
        except Exception as e:
            _audit_log(action, trigger, precheck, f"ERROR: {e}", "", status="failed")

# ── Podsumowanie ─────────────────────────────────────────────────────────
if executed:
    print(f"⚡ Wykonano {len(executed)} auto-akcji:")
    for e in executed:
        print(f"  {e}")
else:
    print("✅ Brak potrzebnych auto-akcji (system w normie)")
PYGUARDRAILS
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 6: Webhook alerting (P2.1)
# ═══════════════════════════════════════════════════════════════════════════════

run_webhook_alerting() {
    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_DOCTOR_FILE" "$STATUSD_REPORT_FILE" "$STATUSD_ALERT_STATE_FILE" "$ALERT_WEBHOOK_URL_FILE" "${STATUSD_WEBHOOK_URL:-}" "$ALERT_COOLDOWN_SECONDS" <<'PYALERT'
import json, sys, os
from datetime import datetime, timezone
from urllib import request, error

work_dir = sys.argv[1]
status_dir = sys.argv[2]
doctor_file = sys.argv[3]
report_file = sys.argv[4]
alert_state_file = sys.argv[5]
webhook_file = sys.argv[6]
env_webhook = sys.argv[7].strip()
cooldown_s = int(sys.argv[8] or "900")

now = datetime.now(timezone.utc)
now_z = now.isoformat().replace("+00:00", "Z")

def _parse_ts(ts):
    if not ts:
        return None
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
    except Exception:
        return None

def _read_json(path, default):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default

doctor = _read_json(doctor_file, {})
report = _read_json(report_file, {})
overview = _read_json(os.path.join(status_dir, "translation_global_overview.json"), {})

guardian = report.get("guardian", {})
guardian_state = str(guardian.get("state", "unknown")).lower()
guardian_issues = [str(x) for x in guardian.get("issues", [])]
doctor_overall = str(doctor.get("overall", "HEALTHY")).upper()
doctor_issues = [str(x) for x in doctor.get("issues", [])]

strict_window = overview.get("strict_hourly_window", {})
no_progress_rate = float(strict_window.get("no_progress_rate_pct", 0) or 0)
repair_queue = report.get("repair_queue", {}) if isinstance(report.get("repair_queue", {}), dict) else {}
repair_top = repair_queue.get("top_target", {}) if isinstance(repair_queue.get("top_target", {}), dict) else {}
repair_stagnation = repair_queue.get("stagnation", {}) if isinstance(repair_queue.get("stagnation", {}), dict) else {}
repair_stagnation_detected = bool(repair_stagnation.get("detected", False))
repair_top_key = str(repair_top.get("key", "") or "")
repair_top_backlog = int(repair_top.get("identical_to_en", 0) or 0)
repair_span_h = float(repair_stagnation.get("span_hours", 0) or 0.0)
repair_baseline = int(repair_stagnation.get("baseline_count", 0) or 0)
repair_latest = int(repair_stagnation.get("latest_count", repair_top_backlog) or repair_top_backlog)

signals = []
if guardian_state == "stuck":
    signals.append(("CRITICAL", "guardian_stuck", "Guardian state=stuck"))
if doctor_overall == "CRITICAL":
    signals.append(("CRITICAL", "doctor_critical", "Status doctor=CRITICAL"))
if any("no_progress" in s.lower() for s in guardian_issues) or no_progress_rate > 0:
    signals.append(("WARNING", "no_progress", f"no_progress detected (rate={no_progress_rate:.1f}%)"))
if repair_stagnation_detected:
    top_label = repair_top_key or "unknown"
    signals.append((
        "WARNING",
        "repair_queue_stagnation",
        f"repair_queue stagnation {top_label} ({repair_baseline}->{repair_latest}, span={repair_span_h:.1f}h)",
    ))

if not signals:
    print("NO_ALERT_CONDITION")
    raise SystemExit(0)

severity_rank = {"CRITICAL": 3, "WARNING": 2, "INFO": 1}
reason_rank = {"guardian_stuck": 4, "doctor_critical": 3, "repair_queue_stagnation": 2, "no_progress": 1}
signals.sort(key=lambda x: (severity_rank.get(x[0], 0), reason_rank.get(x[1], 0)), reverse=True)
severity, reason_code, reason_text = signals[0]
alert_key = f"{reason_code}:{severity}"

webhook_url = env_webhook
if not webhook_url and os.path.exists(webhook_file):
    try:
        with open(webhook_file, encoding="utf-8") as f:
            webhook_url = f.read().strip()
    except Exception:
        webhook_url = ""
if not webhook_url:
    print("WEBHOOK_NOT_CONFIGURED")
    raise SystemExit(0)

state = _read_json(alert_state_file, {})
last_key = state.get("last_key", "")
last_sent_dt = _parse_ts(state.get("last_sent_at", ""))
if last_key == alert_key and last_sent_dt is not None:
    age_s = (now - last_sent_dt).total_seconds()
    if age_s < cooldown_s:
        wait_s = int(cooldown_s - age_s)
        print(f"SKIP_COOLDOWN reason={reason_code} wait_s={wait_s}")
        raise SystemExit(0)

worker = report.get("worker", {})
payload = {
    "source": "i18n-statusd",
    "event": "stuck_no_progress_alert",
    "timestamp": now_z,
    "severity": severity,
    "reason_code": reason_code,
    "message": reason_text,
    "doctor_overall": doctor_overall,
    "doctor_issues": doctor_issues[:10],
    "guardian_state": guardian_state,
    "guardian_issues": guardian_issues[:10],
    "worker_cycle": worker.get("cycle", -1),
    "worker_mode": worker.get("mode", "?"),
    "worker_heartbeat_age_s": worker.get("heartbeat_age_s", -1),
    "strict_no_progress_rate_pct": round(no_progress_rate, 2),
    "repair_queue_top_key": repair_top_key,
    "repair_queue_top_backlog": repair_top_backlog,
    "repair_queue_stagnation": {
        "detected": repair_stagnation_detected,
        "span_hours": round(repair_span_h, 3),
        "baseline_count": repair_baseline,
        "latest_count": repair_latest,
        "sample_count": int(repair_stagnation.get("sample_count", 0) or 0),
        "reason": str(repair_stagnation.get("reason", "") or ""),
    },
    "content": (
        f"[i18n-statusd][{severity}] {reason_text} | "
        f"doctor={doctor_overall} guardian={guardian_state} hb_age={worker.get('heartbeat_age_s', -1)}s "
        f"repair_stagnation={'yes' if repair_stagnation_detected else 'no'}"
    ),
}

req = request.Request(
    webhook_url,
    data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
    headers={"Content-Type": "application/json"},
    method="POST",
)

status = None
response_preview = ""
event = {
    "timestamp": now_z,
    "alert_key": alert_key,
    "severity": severity,
    "reason_code": reason_code,
}
try:
    with request.urlopen(req, timeout=10) as resp:
        status = getattr(resp, "status", 200)
        response_preview = resp.read(200).decode("utf-8", errors="ignore")
    event.update({"result": "sent", "http_status": status})
    print(f"ALERT_SENT reason={reason_code} severity={severity} status={status}")
except error.HTTPError as e:
    status = e.code
    response_preview = e.read(200).decode("utf-8", errors="ignore")
    event.update({"result": "failed", "http_status": status, "error": f"HTTPError: {e}"})
    print(f"ALERT_HTTP_ERROR reason={reason_code} status={status}")
except Exception as e:
    event.update({"result": "failed", "error": str(e)})
    print(f"ALERT_ERROR reason={reason_code} error={e}")

recent = state.get("recent", [])
if not isinstance(recent, list):
    recent = []
recent.append(event)
recent = recent[-25:]

next_state = {
    "updated_at": now_z,
    "last_key": alert_key if event.get("result") == "sent" else state.get("last_key", ""),
    "last_sent_at": now_z if event.get("result") == "sent" else state.get("last_sent_at", ""),
    "last_result": event.get("result", "failed"),
    "last_http_status": status,
    "last_response_preview": response_preview[:200],
    "cooldown_seconds": cooldown_s,
    "recent": recent,
}

try:
    with open(alert_state_file, "w", encoding="utf-8") as f:
        json.dump(next_state, f, indent=2, ensure_ascii=False)
except Exception:
    pass
PYALERT
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 7: Dzienny raport zarządczy (P2.2)
# ═══════════════════════════════════════════════════════════════════════════════

generate_daily_report() {
    python3 - "$STATUS_DIR" "$STATUSD_DAILY_REPORT_JSON" "$STATUSD_DAILY_REPORT_MD" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" <<'PYDAILY'
import json, sys, os, re
from collections import defaultdict
from datetime import datetime, timezone, timedelta

status_dir = sys.argv[1]
report_json_path = sys.argv[2]
report_md_path = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))

now = datetime.now(timezone.utc)
window_start = now - timedelta(hours=24)

def _parse_ts(ts):
    if not ts:
        return None
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
    except Exception:
        return None

def _safe_int(v, default=0):
    try:
        return int(v)
    except Exception:
        return default

def _safe_float(v, default=0.0):
    try:
        return float(v)
    except Exception:
        return default

def _analyze_repair_queue(now, window_start, status_dir, stagnation_window_h, stagnation_min_samples, stagnation_min_drop):
    queue_latest_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
    queue_report_path = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")

    out = {
        "latest_timestamp": "",
        "entries_total_latest": 0,
        "entries_by_lang_latest": {},
        "top_target_latest": {
            "lang": "",
            "json_file": "",
            "key": "",
            "identical_to_en": 0,
        },
        "samples_24h": 0,
        "first_timestamp_24h": "",
        "last_timestamp_24h": "",
        "top_target_start_24h": {
            "lang": "",
            "json_file": "",
            "key": "",
            "identical_to_en": 0,
        },
        "top_target_latest_24h": {
            "lang": "",
            "json_file": "",
            "key": "",
            "identical_to_en": 0,
        },
        "top_target_changed_24h": False,
        "top_target_drop_24h": 0,
        "stagnation": {
            "window_hours": float(stagnation_window_h),
            "min_samples": int(stagnation_min_samples),
            "min_drop_required": int(stagnation_min_drop),
            "detected": False,
            "reason": "no_data",
            "top_key": "",
            "sample_count": 0,
            "span_hours": 0.0,
            "top_locked_in_window": False,
            "baseline_count": 0,
            "latest_count": 0,
            "best_drop": 0,
        },
    }

    latest = {}
    try:
        with open(queue_latest_path, encoding="utf-8") as f:
            latest = json.load(f)
    except Exception:
        latest = {}

    if isinstance(latest, dict) and latest:
        out["latest_timestamp"] = str(latest.get("timestamp", "") or "")
        out["entries_total_latest"] = _safe_int(latest.get("entries_total", 0))
        ebl = latest.get("entries_by_lang", {})
        if isinstance(ebl, dict):
            out["entries_by_lang_latest"] = {str(k): _safe_int(v) for k, v in ebl.items()}
        sel = latest.get("selected", {})
        if isinstance(sel, dict):
            lang = str(sel.get("lang", "") or "")
            json_file = str(sel.get("json_file", "") or "")
            key = f"{lang}:{json_file}" if lang and json_file else ""
            out["top_target_latest"] = {
                "lang": lang,
                "json_file": json_file,
                "key": key,
                "identical_to_en": _safe_int(sel.get("identical_to_en", 0)),
            }

    all_samples = []
    if os.path.exists(queue_report_path):
        with open(queue_report_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                dt = _parse_ts(row.get("timestamp"))
                sel = row.get("selected", {})
                if not isinstance(sel, dict):
                    continue
                lang = str(sel.get("lang", "") or "")
                json_file = str(sel.get("json_file", "") or "")
                count = _safe_int(sel.get("identical_to_en", 0))
                if dt is None or not lang or not json_file or count <= 0:
                    continue
                all_samples.append({
                    "dt": dt,
                    "timestamp": dt.isoformat().replace("+00:00", "Z"),
                    "lang": lang,
                    "json_file": json_file,
                    "key": f"{lang}:{json_file}",
                    "count": count,
                })

    all_samples.sort(key=lambda x: x["dt"])
    samples_24h = [s for s in all_samples if s["dt"] >= window_start]
    out["samples_24h"] = len(samples_24h)
    if samples_24h:
        first_24 = samples_24h[0]
        last_24 = samples_24h[-1]
        out["first_timestamp_24h"] = first_24["timestamp"]
        out["last_timestamp_24h"] = last_24["timestamp"]
        out["top_target_start_24h"] = {
            "lang": first_24["lang"],
            "json_file": first_24["json_file"],
            "key": first_24["key"],
            "identical_to_en": int(first_24["count"]),
        }
        out["top_target_latest_24h"] = {
            "lang": last_24["lang"],
            "json_file": last_24["json_file"],
            "key": last_24["key"],
            "identical_to_en": int(last_24["count"]),
        }
        top_changed = first_24["key"] != last_24["key"]
        out["top_target_changed_24h"] = bool(top_changed)
        if not top_changed:
            out["top_target_drop_24h"] = int(first_24["count"] - last_24["count"])

    st = out["stagnation"]
    if not all_samples:
        st["reason"] = "no_report_samples"
        return out

    latest_sample = all_samples[-1]
    focus_key = out["top_target_latest"].get("key") or latest_sample["key"]
    focus_samples = [s for s in all_samples if s["key"] == focus_key]
    if not focus_samples:
        st["reason"] = "focus_key_missing_in_history"
        return out

    window_h = max(float(stagnation_window_h), 0.1)
    min_samples = max(int(stagnation_min_samples), 1)
    min_drop = max(int(stagnation_min_drop), 0)
    window_start_dt = focus_samples[-1]["dt"] - timedelta(hours=window_h)
    window_focus = [s for s in focus_samples if s["dt"] >= window_start_dt]
    window_all = [s for s in all_samples if s["dt"] >= window_start_dt]

    if not window_focus:
        st["reason"] = "empty_window"
        return out

    counts = [s["count"] for s in window_focus]
    baseline = counts[0]
    latest_count = counts[-1]
    min_seen = min(counts)
    best_drop = baseline - min_seen
    span_h = (window_focus[-1]["dt"] - window_focus[0]["dt"]).total_seconds() / 3600.0
    top_locked = bool(window_all) and all(s["key"] == focus_key for s in window_all)
    has_span = span_h >= window_h
    has_samples = len(window_focus) >= min_samples
    no_drop = best_drop < min_drop
    detected = bool(top_locked and has_span and has_samples and no_drop and latest_count > 0)

    if detected:
        reason = "top_backlog_no_drop"
    elif not top_locked:
        reason = "top_target_changed"
    elif not has_span:
        reason = "window_too_short"
    elif not has_samples:
        reason = "insufficient_samples"
    elif not no_drop:
        reason = "drop_detected"
    else:
        reason = "not_detected"

    st.update({
        "detected": detected,
        "reason": reason,
        "top_key": focus_key,
        "sample_count": len(window_focus),
        "span_hours": round(span_h, 3),
        "top_locked_in_window": bool(top_locked),
        "baseline_count": int(baseline),
        "latest_count": int(latest_count),
        "best_drop": int(best_drop),
    })
    return out

guard_file = os.path.join(status_dir, "translation_guard_report.jsonl")
lang_stats = defaultdict(lambda: {"entries": 0, "translated": 0, "guard_fail": 0, "no_progress_entries": 0})
category_stats = defaultdict(lambda: {"entries": 0, "translated": 0, "guard_fail": 0, "no_progress_entries": 0})
guard_entries = 0
total_translated = 0
total_guard_fail = 0
no_progress_entries = 0
guard_first_ts = None
guard_last_ts = None

if os.path.exists(guard_file):
    with open(guard_file, encoding="utf-8") as f:
        for line in f:
            try:
                row = json.loads(line.strip())
            except Exception:
                continue
            ts = _parse_ts(row.get("timestamp"))
            if ts is None or ts < window_start:
                continue
            guard_entries += 1
            if guard_first_ts is None:
                guard_first_ts = ts
            guard_last_ts = ts
            translated = _safe_int(row.get("translated", 0))
            guard_fail = _safe_int(row.get("guard_fail", 0))
            lang = str(row.get("language", "?")).lower()
            category = str(row.get("json_file", "?")).lower()
            no_prog = 1 if translated <= 0 else 0

            total_translated += translated
            total_guard_fail += guard_fail
            no_progress_entries += no_prog

            lang_stats[lang]["entries"] += 1
            lang_stats[lang]["translated"] += translated
            lang_stats[lang]["guard_fail"] += guard_fail
            lang_stats[lang]["no_progress_entries"] += no_prog

            category_stats[category]["entries"] += 1
            category_stats[category]["translated"] += translated
            category_stats[category]["guard_fail"] += guard_fail
            category_stats[category]["no_progress_entries"] += no_prog

guard_fail_rate_pct = (total_guard_fail / max(total_translated + total_guard_fail, 1)) * 100
no_progress_rate_pct = (no_progress_entries / max(guard_entries, 1)) * 100

window_h = 24.0
throughput_keys_per_h_window = total_translated / window_h
if guard_first_ts and guard_last_ts:
    active_h = max((guard_last_ts - guard_first_ts).total_seconds() / 3600.0, 1.0 / 60.0)
else:
    active_h = 0.0
throughput_keys_per_h_active = (total_translated / active_h) if active_h > 0 else 0.0

cycle_perf_file = os.path.join(status_dir, "worker_cycle_perf.jsonl")
pending_skip_count = 0
cycle_total_entries = 0
pending_skip_hits = 0
pending_skip_regex = re.compile(r"pending_skip(?:_count)?[=: ](\\d+)", re.IGNORECASE)
if os.path.exists(cycle_perf_file):
    with open(cycle_perf_file, encoding="utf-8") as f:
        for line in f:
            try:
                row = json.loads(line.strip())
            except Exception:
                continue
            ts = _parse_ts(row.get("timestamp"))
            if ts is None or ts < window_start:
                continue
            if str(row.get("phase", "")).lower() == "cycle_total":
                cycle_total_entries += 1
            detail = str(row.get("detail", ""))
            m = pending_skip_regex.search(detail)
            if m:
                pending_skip_count += _safe_int(m.group(1), 0)
                pending_skip_hits += 1
            elif "pending_skip" in detail.lower():
                pending_skip_count += 1
                pending_skip_hits += 1
pending_skip_share_pct = pending_skip_count / max(cycle_total_entries, 1) * 100

quality_report_file = os.path.join(status_dir, "quality_report.jsonl")
quality_entries = 0
quality_suspicious = 0
quality_identical_to_en = 0
quality_gt_guard_fails = 0
if os.path.exists(quality_report_file):
    with open(quality_report_file, encoding="utf-8") as f:
        for line in f:
            try:
                row = json.loads(line.strip())
            except Exception:
                continue
            ts = _parse_ts(row.get("timestamp"))
            if ts is None or ts < window_start:
                continue
            quality_entries += 1
            q = row.get("quality", {}) or {}
            quality_suspicious += _safe_int(q.get("suspicious_count", 0))
            quality_identical_to_en += _safe_int(q.get("identical_to_en", 0))
            quality_gt_guard_fails += _safe_int(q.get("gt_guard_fails", 0))

quality_audit_latest = {}
qa_path = os.path.join(status_dir, "quality_audit_latest.json")
if os.path.exists(qa_path):
    try:
        with open(qa_path, encoding="utf-8") as f:
            quality_audit_latest = json.load(f)
    except Exception:
        quality_audit_latest = {}

overview = {}
ov_path = os.path.join(status_dir, "translation_global_overview.json")
if os.path.exists(ov_path):
    try:
        with open(ov_path, encoding="utf-8") as f:
            overview = json.load(f)
    except Exception:
        overview = {}
strict_hourly = overview.get("strict_hourly_window", {})
coverage_map = {}
for row in overview.get("languages", []):
    lang = str(row.get("lang", "")).lower()
    if not lang:
        continue
    coverage_map[lang] = {
        "completion_pct": _safe_float(row.get("completion_pct", 0)),
        "missing_keys": _safe_int(row.get("missing_keys", 0)),
        "english_copy_keys": _safe_int(row.get("english_copy_keys", 0)),
    }

repair_queue_24h = _analyze_repair_queue(
    now=now,
    window_start=window_start,
    status_dir=status_dir,
    stagnation_window_h=repair_window_h,
    stagnation_min_samples=repair_min_samples,
    stagnation_min_drop=repair_min_drop,
)

def _materialize_stats(src):
    out = {}
    for key, data in src.items():
        translated = _safe_int(data.get("translated", 0))
        guard_fail = _safe_int(data.get("guard_fail", 0))
        entries = _safe_int(data.get("entries", 0))
        out[key] = {
            "entries": entries,
            "translated": translated,
            "guard_fail": guard_fail,
            "guard_fail_rate_pct": round(guard_fail / max(translated + guard_fail, 1) * 100, 2),
            "no_progress_entries": _safe_int(data.get("no_progress_entries", 0)),
            "no_progress_rate_pct": round(_safe_int(data.get("no_progress_entries", 0)) / max(entries, 1) * 100, 2),
        }
    return out

lang_stats_final = _materialize_stats(lang_stats)
category_stats_final = _materialize_stats(category_stats)

top_langs = sorted(lang_stats_final.items(), key=lambda x: (x[1]["translated"], x[0]), reverse=True)[:12]
top_categories = sorted(category_stats_final.items(), key=lambda x: (x[1]["translated"], x[0]), reverse=True)[:15]

report = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "window": {
        "start_utc": window_start.isoformat().replace("+00:00", "Z"),
        "end_utc": now.isoformat().replace("+00:00", "Z"),
        "hours": 24,
    },
    "kpi_24h": {
        "translated": total_translated,
        "guard_fail": total_guard_fail,
        "guard_fail_rate_pct": round(guard_fail_rate_pct, 2),
        "no_progress_entries": no_progress_entries,
        "no_progress_rate_pct": round(no_progress_rate_pct, 2),
        "pending_skip_count": pending_skip_count,
        "pending_skip_share_pct": round(pending_skip_share_pct, 2),
        "pending_skip_signal_hits": pending_skip_hits,
        "cycle_total_entries": cycle_total_entries,
        "throughput_keys_per_h_window": round(throughput_keys_per_h_window, 1),
        "throughput_keys_per_h_active": round(throughput_keys_per_h_active, 1),
        "guard_entries": guard_entries,
    },
    "quality_24h": {
        "quality_entries": quality_entries,
        "suspicious_count": quality_suspicious,
        "identical_to_en_count": quality_identical_to_en,
        "gt_guard_fails_count": quality_gt_guard_fails,
        "latest_audit_timestamp": quality_audit_latest.get("timestamp", ""),
        "latest_audit_issues_found": _safe_int(quality_audit_latest.get("issues_found", 0)),
        "latest_audit_issues_by_type": quality_audit_latest.get("issues_by_type", {}),
    },
    "coverage_snapshot": {
        "pl": coverage_map.get("pl", {}),
        "es": coverage_map.get("es", {}),
    },
    "trend_per_language": lang_stats_final,
    "trend_per_category": category_stats_final,
    "top": {
        "languages_by_translated": [{"lang": k, **v} for k, v in top_langs],
        "categories_by_translated": [{"category": k, **v} for k, v in top_categories],
    },
    "strict_hourly_snapshot": strict_hourly,
    "repair_queue_24h": repair_queue_24h,
    "notes": [
        "pending_skip_share bazuje na worker_cycle_perf.detail (sygnały pending_skip=*).",
        "no_progress_rate bazuje na translation_guard_report (translated<=0).",
        "repair_queue_24h bazuje na identical_to_en_repair_queue_report.jsonl.",
    ],
}

# --- Repair backlog trend ---
repair_queue_file = os.path.join(status_dir, "identical_to_en_repair_queue.json")
stagnation_alert_file = os.path.join(status_dir, "repair_stagnation_alert.json")
repair_report_jsonl = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")

repair_backlog = {}
if os.path.exists(repair_queue_file):
    try:
        with open(repair_queue_file, encoding="utf-8") as f:
            rq = json.load(f)
        repair_backlog["current_total"] = sum(int(v) for v in rq.get("entries_by_lang", {}).values()) if "entries_by_lang" in rq else rq.get("entries_total", 0)
        repair_backlog["entries_total"] = rq.get("entries_total", 0)
        repair_backlog["by_lang"] = rq.get("entries_by_lang", {})
        repair_backlog["timestamp"] = rq.get("timestamp", "")
    except:
        pass

if os.path.exists(stagnation_alert_file):
    try:
        with open(stagnation_alert_file, encoding="utf-8") as f:
            sa = json.load(f)
        repair_backlog["stagnation_status"] = sa.get("status", "unknown")
        repair_backlog["stagnation_decrease_pct"] = sa.get("decrease_pct", 0)
        repair_backlog["stagnation_hours"] = sa.get("hours_elapsed", 0)
        repair_backlog["stagnation_alert"] = sa.get("alert", False)
        repair_backlog["per_lang_trend"] = sa.get("per_lang_trend", {})
    except:
        pass

# 24h backlog delta z JSONL
if os.path.exists(repair_report_jsonl):
    try:
        rr_entries = []
        with open(repair_report_jsonl, encoding="utf-8") as f:
            for line in f:
                try:
                    rec = json.loads(line.strip())
                    ts = _parse_ts(rec.get("timestamp", ""))
                    if ts:
                        by_lang = rec.get("entries_by_lang", {})
                        total = sum(int(v) for v in by_lang.values())
                        rr_entries.append({"ts": ts, "total": total})
                except:
                    continue
        oldest_24h = [e for e in rr_entries if e["ts"] <= window_start]
        if oldest_24h and rr_entries:
            old_t = oldest_24h[-1]["total"]
            new_t = rr_entries[-1]["total"]
            repair_backlog["delta_24h"] = old_t - new_t
            repair_backlog["delta_24h_pct"] = round((old_t - new_t) / old_t * 100, 2) if old_t > 0 else 0.0
    except:
        pass

report["repair_backlog"] = repair_backlog

with open(report_json_path, "w", encoding="utf-8") as f:
    json.dump(report, f, indent=2, ensure_ascii=False)

def _fmt_pct(v):
    return f"{_safe_float(v):.2f}%"

lines = []
lines.append("# I18N Daily Executive Report (24h)")
lines.append("")
lines.append(f"- Generated: `{report['timestamp']}`")
lines.append(f"- Window: `{report['window']['start_utc']}` -> `{report['window']['end_utc']}`")
lines.append("")
lines.append("## KPI 24h")
lines.append("")
lines.append("| KPI | Value |")
lines.append("|---|---:|")
lines.append(f"| translated | {report['kpi_24h']['translated']} |")
lines.append(f"| guard_fail | {report['kpi_24h']['guard_fail']} |")
lines.append(f"| guard_fail_rate | {_fmt_pct(report['kpi_24h']['guard_fail_rate_pct'])} |")
lines.append(f"| no_progress_entries | {report['kpi_24h']['no_progress_entries']} |")
lines.append(f"| no_progress_rate | {_fmt_pct(report['kpi_24h']['no_progress_rate_pct'])} |")
lines.append(f"| pending_skip_count | {report['kpi_24h']['pending_skip_count']} |")
lines.append(f"| pending_skip_share | {_fmt_pct(report['kpi_24h']['pending_skip_share_pct'])} |")
lines.append(f"| throughput_keys_per_h_window | {report['kpi_24h']['throughput_keys_per_h_window']} |")
lines.append(f"| throughput_keys_per_h_active | {report['kpi_24h']['throughput_keys_per_h_active']} |")
lines.append("")
lines.append("## Quality 24h")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
lines.append(f"| suspicious_count | {report['quality_24h']['suspicious_count']} |")
lines.append(f"| identical_to_en_count | {report['quality_24h']['identical_to_en_count']} |")
lines.append(f"| gt_guard_fails_count | {report['quality_24h']['gt_guard_fails_count']} |")
lines.append(f"| latest_audit_issues_found | {report['quality_24h']['latest_audit_issues_found']} |")
lines.append("")
lines.append("## Repair Queue 24h")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
rq = report.get("repair_queue_24h", {}) or {}
rq_st = rq.get("stagnation", {}) if isinstance(rq.get("stagnation", {}), dict) else {}
rq_latest = rq.get("top_target_latest", {}) if isinstance(rq.get("top_target_latest", {}), dict) else {}
rq_start = rq.get("top_target_start_24h", {}) if isinstance(rq.get("top_target_start_24h", {}), dict) else {}
lines.append(f"| samples_24h | {rq.get('samples_24h', 0)} |")
lines.append(f"| latest_entries_total | {rq.get('entries_total_latest', 0)} |")
lines.append(f"| top_target_latest | {rq_latest.get('key', '-') or '-'} |")
lines.append(f"| top_backlog_latest | {rq_latest.get('identical_to_en', 0)} |")
lines.append(f"| top_target_start_24h | {rq_start.get('key', '-') or '-'} |")
if rq.get("top_target_changed_24h", False):
    lines.append("| top_target_drop_24h | n/a (top_changed) |")
else:
    lines.append(f"| top_target_drop_24h | {rq.get('top_target_drop_24h', 0)} |")
lines.append(f"| stagnation_detected | {'yes' if rq_st.get('detected', False) else 'no'} |")
lines.append(f"| stagnation_span_h | {rq_st.get('span_hours', 0)} |")
lines.append(f"| stagnation_reason | {rq_st.get('reason', '')} |")
lines.append("")
lines.append("## Coverage Snapshot")
lines.append("")
lines.append("| Lang | Completion | Missing Keys | EN Copy Keys |")
lines.append("|---|---:|---:|---:|")
for lang in ("pl", "es"):
    row = report["coverage_snapshot"].get(lang, {}) or {}
    lines.append(
        f"| {lang.upper()} | {row.get('completion_pct', 0):.2f}% | {row.get('missing_keys', 0)} | {row.get('english_copy_keys', 0)} |"
    )
lines.append("")
lines.append("## Top Languages (by translated)")
lines.append("")
lines.append("| Lang | Translated | Guard Fail | GF Rate | No Progress |")
lines.append("|---|---:|---:|---:|---:|")
for row in report["top"]["languages_by_translated"][:10]:
    lines.append(
        f"| {row['lang']} | {row['translated']} | {row['guard_fail']} | {_fmt_pct(row['guard_fail_rate_pct'])} | {_fmt_pct(row['no_progress_rate_pct'])} |"
    )
lines.append("")
lines.append("## Top Categories (by translated)")
lines.append("")
lines.append("| Category | Translated | Guard Fail | GF Rate | No Progress |")
lines.append("|---|---:|---:|---:|---:|")
for row in report["top"]["categories_by_translated"][:12]:
    lines.append(
        f"| {row['category']} | {row['translated']} | {row['guard_fail']} | {_fmt_pct(row['guard_fail_rate_pct'])} | {_fmt_pct(row['no_progress_rate_pct'])} |"
    )
lines.append("")
lines.append("## Notes")
lines.append("")
for n in report["notes"]:
    lines.append(f"- {n}")

# Repair backlog section
rb = report.get("repair_backlog", {})
if rb:
    lines.append("")
    lines.append("## Repair Backlog (identical_to_en)")
    lines.append("")
    lines.append("| Metric | Value |")
    lines.append("|---|---:|")
    lines.append(f"| current_total | {rb.get('current_total', '?')} |")
    for lang, count in rb.get("by_lang", {}).items():
        lines.append(f"| backlog_{lang} | {count} |")
    if "delta_24h" in rb:
        lines.append(f"| delta_24h | -{rb['delta_24h']} (-{rb.get('delta_24h_pct',0):.1f}%) |")
    if "stagnation_status" in rb:
        status_emoji = "🔴" if rb.get("stagnation_alert") else "🟢"
        lines.append(f"| stagnation_status | {status_emoji} {rb['stagnation_status']} |")
        lines.append(f"| stagnation_decrease | {rb.get('stagnation_decrease_pct',0):.1f}% over {rb.get('stagnation_hours',0):.1f}h |")

with open(report_md_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines).rstrip() + "\n")

print(f"OK daily-report entries={guard_entries} translated={total_translated}")
PYDAILY
}

maybe_refresh_daily_report() {
    local now_ts mtime_ts age_s
    if [ ! -f "$STATUSD_DAILY_REPORT_JSON" ]; then
        generate_daily_report
        return 0
    fi
    now_ts=$(date +%s)
    mtime_ts=$(stat -c %Y "$STATUSD_DAILY_REPORT_JSON" 2>/dev/null || echo 0)
    age_s=$((now_ts - mtime_ts))
    if [ "$age_s" -ge "$DAILY_REPORT_MIN_INTERVAL_SECONDS" ]; then
        generate_daily_report
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 7b: Stagnation alert — repair queue backlog monitoring
# ═══════════════════════════════════════════════════════════════════════════════
#
# Czyta identical_to_en_repair_queue_report.jsonl i sprawdza czy top backlog
# (suma per-lang) spada w oknie 6h. Jeśli nie — generuje alert.
# Artefakty: repair_stagnation_alert.json, repair_backlog_trend.jsonl
#

STAGNATION_WINDOW_HOURS="${STATUSD_STAGNATION_WINDOW_HOURS:-6}"
STAGNATION_MIN_DECREASE_PCT="${STATUSD_STAGNATION_MIN_DECREASE_PCT:-2}"
STAGNATION_CHECK_INTERVAL="${STATUSD_STAGNATION_CHECK_INTERVAL:-1800}"
STAGNATION_ALERT_FILE="$STATUS_DIR/repair_stagnation_alert.json"
BACKLOG_TREND_FILE="$STATUS_DIR/repair_backlog_trend.jsonl"

run_repair_stagnation_check() {
    python3 - "$STATUS_DIR" "$STAGNATION_WINDOW_HOURS" "$STAGNATION_MIN_DECREASE_PCT" "$STAGNATION_ALERT_FILE" "$BACKLOG_TREND_FILE" <<'PYSTAGNATION'
import sys, json, os
from datetime import datetime, timezone, timedelta

status_dir = sys.argv[1]
window_hours = float(sys.argv[2])
min_decrease_pct = float(sys.argv[3])
alert_file = sys.argv[4]
trend_file = sys.argv[5]

report_jsonl = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")
queue_json = os.path.join(status_dir, "identical_to_en_repair_queue.json")

def _read_json(path, default=None):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except:
        return default if default is not None else {}

def _parse_ts(s):
    try:
        s = s.replace("Z", "+00:00")
        return datetime.fromisoformat(s)
    except:
        return None

# --- Zbierz historię z JSONL ---
entries = []
if os.path.exists(report_jsonl):
    with open(report_jsonl, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
                ts = _parse_ts(rec.get("timestamp", ""))
                if ts:
                    by_lang = rec.get("entries_by_lang", {})
                    total = sum(int(v) for v in by_lang.values())
                    entries.append({"ts": ts, "total": total, "by_lang": by_lang})
            except:
                continue

now = datetime.now(timezone.utc)
result = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "window_hours": window_hours,
    "min_decrease_pct": min_decrease_pct,
    "status": "ok",
    "alert": False,
    "message": "",
}

if len(entries) < 2:
    result["status"] = "insufficient_data"
    result["message"] = f"Only {len(entries)} data points, need ≥2"
    with open(alert_file, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)
    print(f"STAGNATION_CHECK insufficient_data entries={len(entries)}")
    sys.exit(0)

# --- Oblicz trend ---
cutoff = now - timedelta(hours=window_hours)
old_entries = [e for e in entries if e["ts"] <= cutoff]
new_entries = [e for e in entries if e["ts"] > cutoff]

if not old_entries:
    # Brak danych sprzed window — użyj najstarszego wpisu
    oldest = entries[0]
    newest = entries[-1]
else:
    oldest = old_entries[-1]  # ostatni wpis bez tego okna
    newest = entries[-1]

old_total = oldest["total"]
new_total = newest["total"]

if old_total == 0:
    decrease_pct = 100.0
else:
    decrease_pct = ((old_total - new_total) / old_total) * 100.0

result["old_total"] = old_total
result["new_total"] = new_total
result["decrease_pct"] = round(decrease_pct, 2)
result["old_ts"] = oldest["ts"].isoformat().replace("+00:00", "Z")
result["new_ts"] = newest["ts"].isoformat().replace("+00:00", "Z")

# Per-lang breakdown
per_lang_trend = {}
for lang in set(list(oldest.get("by_lang", {}).keys()) + list(newest.get("by_lang", {}).keys())):
    old_v = int(oldest.get("by_lang", {}).get(lang, 0))
    new_v = int(newest.get("by_lang", {}).get(lang, 0))
    delta = old_v - new_v
    pct = (delta / old_v * 100.0) if old_v > 0 else 0.0
    per_lang_trend[lang] = {
        "old": old_v, "new": new_v, "delta": delta,
        "decrease_pct": round(pct, 2)
    }
result["per_lang_trend"] = per_lang_trend

# --- Sprawdź stagnację ---
hours_elapsed = (newest["ts"] - oldest["ts"]).total_seconds() / 3600.0
result["hours_elapsed"] = round(hours_elapsed, 2)

if hours_elapsed >= window_hours and decrease_pct < min_decrease_pct:
    result["status"] = "stagnation"
    result["alert"] = True
    result["message"] = (
        f"Repair queue stagnation: backlog decreased only {decrease_pct:.1f}% "
        f"(threshold: {min_decrease_pct}%) over {hours_elapsed:.1f}h. "
        f"Old={old_total}, New={new_total}."
    )
    print(f"STAGNATION_ALERT decrease={decrease_pct:.1f}% hours={hours_elapsed:.1f} old={old_total} new={new_total}")
elif hours_elapsed < window_hours:
    result["status"] = "warming_up"
    result["message"] = f"Only {hours_elapsed:.1f}h of data, need {window_hours}h window"
    print(f"STAGNATION_CHECK warming_up hours={hours_elapsed:.1f}")
else:
    result["status"] = "ok"
    result["message"] = f"Backlog decreasing: {decrease_pct:.1f}% over {hours_elapsed:.1f}h"
    print(f"STAGNATION_OK decrease={decrease_pct:.1f}% hours={hours_elapsed:.1f} old={old_total} new={new_total}")

# --- Zapisz alert ---
with open(alert_file, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2)

# --- Dopisz do trendu JSONL ---
trend_entry = {
    "timestamp": result["timestamp"],
    "total": new_total,
    "decrease_pct": result["decrease_pct"],
    "hours_elapsed": result["hours_elapsed"],
    "status": result["status"],
}
for lang, info in per_lang_trend.items():
    trend_entry[f"{lang}_total"] = info["new"]
    trend_entry[f"{lang}_delta"] = info["delta"]

with open(trend_file, "a", encoding="utf-8") as f:
    f.write(json.dumps(trend_entry) + "\n")
# Trim do 500 wpisów
try:
    with open(trend_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    if len(lines) > 500:
        with open(trend_file, "w", encoding="utf-8") as f:
            f.writelines(lines[-500:])
except:
    pass

PYSTAGNATION
}

maybe_run_stagnation_check() {
    local now_ts mtime_ts age_s
    if [ ! -f "$STAGNATION_ALERT_FILE" ]; then
        run_repair_stagnation_check
        return 0
    fi
    now_ts=$(date +%s)
    mtime_ts=$(stat -c %Y "$STAGNATION_ALERT_FILE" 2>/dev/null || echo 0)
    age_s=$((now_ts - mtime_ts))
    if [ "$age_s" -ge "$STAGNATION_CHECK_INTERVAL" ]; then
        run_repair_stagnation_check
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 8: Daemon loop
# ═══════════════════════════════════════════════════════════════════════════════

run_statusd_cycle() {
    local result
    result=$(aggregate_telemetry 2>/dev/null)
    if [ "$result" = "OK" ]; then
        log_statusd "📊 Telemetria zagregowana"
    else
        log_statusd "⚠️ Błąd agregacji: $result"
    fi

    run_status_doctor >> "$STATUSD_LOG" 2>&1 || true

    # Alerting webhook (P2.1)
    run_webhook_alerting >> "$STATUSD_LOG" 2>&1 || true

    # Raport 24h (P2.2) odświeżany interwałowo
    maybe_refresh_daily_report >> "$STATUSD_LOG" 2>&1 || true

    # Stagnation alert — repair queue backlog monitoring (co 30 min)
    maybe_run_stagnation_check >> "$STATUSD_LOG" 2>&1 || true

    # Auto-akcje z guardrailami (jeśli włączone)
    if auto_actions_enabled; then
        run_auto_actions >> "$STATUSD_LOG" 2>&1 || true
    fi

    # Zapisz stan daemona
    python3 -c "
import json
from datetime import datetime, timezone
state = {
    'timestamp': datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
    'status': 'running',
    'last_cycle': 'ok',
}
with open('$STATUSD_STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null || true
}

daemon_loop() {
    echo $$ > "$STATUSD_PID_FILE"
    log_statusd "▶️ statusd daemon start (pid=$$, interval=${DAEMON_INTERVAL_SECONDS}s)"

    trap 'log_statusd "⛔ statusd daemon stop (pid=$$)"; rm -f "$STATUSD_PID_FILE"; exit 0' SIGINT SIGTERM

    while true; do
        run_statusd_cycle
        sleep "$DAEMON_INTERVAL_SECONDS"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

case "${1:-}" in
    --once)
        echo "═══ i18n-statusd: jednorazowy raport ═══"
        aggregate_telemetry
        echo ""
        run_status_doctor
        echo ""
        generate_kpi_snapshot
        echo ""
        generate_recommendations
        echo ""
        generate_daily_report
        ;;
    --daemon)
        daemon_loop
        ;;
    --doctor)
        run_status_doctor
        ;;
    --kpi)
        generate_kpi_snapshot
        ;;
    --recommend)
        generate_recommendations
        ;;
    --aggregate)
        aggregate_telemetry
        ;;
    --daily-report)
        generate_daily_report
        ;;
    --alert-check)
        run_webhook_alerting
        ;;
    --auto-action)
        run_auto_actions
        ;;
    --enable-auto)
        touch "$AUTO_ACTIONS_ENABLED_FILE"
        echo "✅ Auto-akcje WŁĄCZONE (plik: .statusd_auto_actions)"
        ;;
    --disable-auto)
        rm -f "$AUTO_ACTIONS_ENABLED_FILE"
        echo "⛔ Auto-akcje WYŁĄCZONE"
        ;;
    --audit)
        echo "═══ Audit Trail (ostatnie 20 wpisów) ═══"
        tail -20 "$STATUSD_AUDIT_FILE" 2>/dev/null | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        d = json.loads(line.strip())
        ts = d.get('timestamp','?')[:19]
        at = d.get('action_type','?')
        st = d.get('status','?')
        res = d.get('result','?')[:60]
        icon = {'executed':'⚡','skipped':'⏭️','failed':'❌'}.get(st,'?')
        print(f'  {icon} {ts} {at:<35s} {st:<10s} {res}')
    except: pass
" || echo "  (brak wpisów)"
        ;;
    *)
        echo "Użycie: $0 {--once|--daemon|--doctor|--kpi|--recommend|--aggregate|--daily-report|--alert-check|--auto-action|--enable-auto|--disable-auto|--audit}"
        echo ""
        echo "  --once       Jednorazowy pełny raport (telemetria + doctor + KPI + rekomendacje + raport 24h)"
        echo "  --daemon     Ciągła pętla co ${DAEMON_INTERVAL_SECONDS}s"
        echo "  --doctor     Diagnostyka spójności statusu"
        echo "  --kpi        KPI snapshot"
        echo "  --recommend  Rekomendacje profilu/akcji"
        echo "  --aggregate  Agregacja telemetrii do JSON"
        echo "  --daily-report Wygeneruj raport zarządczy 24h (JSON + MD)"
        echo "  --alert-check Jednorazowa ewaluacja i ewentualny webhook alert"
        echo "  --auto-action Wykonaj auto-akcje z guardrailami"
        echo "  --enable-auto Włącz auto-akcje (feature flag)"
        echo "  --disable-auto Wyłącz auto-akcje"
        echo "  --audit      Wyświetl audit trail auto-akcji"
        exit 1
        ;;
esac

exit 0
