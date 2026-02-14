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
#   bash i18n-statusd.sh --reconcile-registry  # uzgodnij registry z LIVE
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
STATUSD_THRESHOLDS_FILE="${STATUSD_THRESHOLDS_FILE:-$WORK_DIR/statusd_thresholds.json}"
# Domyślnie ignorujemy env overrides, żeby daemon/manual czytały ten sam config file.
STATUSD_USE_ENV_OVERRIDES="${STATUSD_USE_ENV_OVERRIDES:-0}"

DEFAULT_REPAIR_QUEUE_STAGNATION_HOURS=6
DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_SAMPLES=6
DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_DROP=1
DEFAULT_SUSPICIOUS_HIGH_WINDOW_HOURS=6
DEFAULT_SUSPICIOUS_HIGH_WARN_COUNT=120
DEFAULT_SUSPICIOUS_HIGH_CRIT_COUNT=240
DEFAULT_SUSPICIOUS_HIGH_RATE_WARN_PCT=8
DEFAULT_SUSPICIOUS_HIGH_RATE_CRIT_PCT=20
DEFAULT_METRICS_DRIFT_WARN_KEYS=50000
DEFAULT_METRICS_DRIFT_CRIT_KEYS=100000
DEFAULT_METRICS_DRIFT_WARN_PCT=95
DEFAULT_METRICS_DRIFT_CRIT_PCT=99
DEFAULT_PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES=180
DEFAULT_PRIORITY_GATE_STUCK_MAX_CYCLES=240
DEFAULT_PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT=1
DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS=1000
DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_PCT=2
DEFAULT_REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS=1800
DEFAULT_REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT=true
DEFAULT_QUEUE_FRESHNESS_WARN_S=900
DEFAULT_QUEUE_FRESHNESS_CRIT_S=1800

REPAIR_QUEUE_STAGNATION_HOURS="$DEFAULT_REPAIR_QUEUE_STAGNATION_HOURS"
REPAIR_QUEUE_STAGNATION_MIN_SAMPLES="$DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_SAMPLES"
REPAIR_QUEUE_STAGNATION_MIN_DROP="$DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_DROP"
SUSPICIOUS_HIGH_WINDOW_HOURS="$DEFAULT_SUSPICIOUS_HIGH_WINDOW_HOURS"
SUSPICIOUS_HIGH_WARN_COUNT="$DEFAULT_SUSPICIOUS_HIGH_WARN_COUNT"
SUSPICIOUS_HIGH_CRIT_COUNT="$DEFAULT_SUSPICIOUS_HIGH_CRIT_COUNT"
SUSPICIOUS_HIGH_RATE_WARN_PCT="$DEFAULT_SUSPICIOUS_HIGH_RATE_WARN_PCT"
SUSPICIOUS_HIGH_RATE_CRIT_PCT="$DEFAULT_SUSPICIOUS_HIGH_RATE_CRIT_PCT"
METRICS_DRIFT_WARN_KEYS="$DEFAULT_METRICS_DRIFT_WARN_KEYS"
METRICS_DRIFT_CRIT_KEYS="$DEFAULT_METRICS_DRIFT_CRIT_KEYS"
METRICS_DRIFT_WARN_PCT="$DEFAULT_METRICS_DRIFT_WARN_PCT"
METRICS_DRIFT_CRIT_PCT="$DEFAULT_METRICS_DRIFT_CRIT_PCT"
PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES="$DEFAULT_PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES"
PRIORITY_GATE_STUCK_MAX_CYCLES="$DEFAULT_PRIORITY_GATE_STUCK_MAX_CYCLES"
PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT="$DEFAULT_PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT"
REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS="$DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS"
REGISTRY_RECONCILE_MIN_OUTSIDE_PCT="$DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_PCT"
REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS="$DEFAULT_REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS"
REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT="$DEFAULT_REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT"
QUEUE_FRESHNESS_WARN_S="$DEFAULT_QUEUE_FRESHNESS_WARN_S"
QUEUE_FRESHNESS_CRIT_S="$DEFAULT_QUEUE_FRESHNESS_CRIT_S"
DAEMON_INTERVAL_SECONDS=60
STATUS_MD_REFRESH_ENABLED="${STATUSD_STATUS_MD_REFRESH_ENABLED:-true}"
STATUS_MD_REFRESH_MIN_INTERVAL_SECONDS="${STATUSD_STATUS_MD_REFRESH_MIN_INTERVAL_SECONDS:-300}"
STATUS_MD_REFRESH_STALE_SECONDS="${STATUSD_STATUS_MD_REFRESH_STALE_SECONDS:-240}"
STATUS_MD_REFRESH_TIMEOUT_SECONDS="${STATUSD_STATUS_MD_REFRESH_TIMEOUT_SECONDS:-180}"
STATUS_MD_REFRESH_FORCE_ON_RECONCILE="${STATUSD_STATUS_MD_REFRESH_FORCE_ON_RECONCILE:-true}"
STATUS_MD_REFRESH_LAST_TS_FILE="$STATUS_DIR/.statusd_status_md_refresh_last_ts"

export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$WORK_DIR" || exit 1

log_statusd() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$STATUSD_LOG"
}

statusd_bool() {
    case "${1:-}" in
        1|true|TRUE|yes|YES|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

ensure_statusd_thresholds_file() {
    if [ -f "$STATUSD_THRESHOLDS_FILE" ]; then
        return 0
    fi
    cat > "$STATUSD_THRESHOLDS_FILE" <<EOF
{
  "schema_version": "1.0",
  "source_of_truth": "statusd_thresholds",
  "generated_by": "i18n-statusd.sh",
  "updated_at_utc": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "repair_queue_stagnation": {
    "window_hours": $DEFAULT_REPAIR_QUEUE_STAGNATION_HOURS,
    "min_samples": $DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_SAMPLES,
    "min_drop": $DEFAULT_REPAIR_QUEUE_STAGNATION_MIN_DROP
  },
  "suspicious_high": {
    "window_hours": $DEFAULT_SUSPICIOUS_HIGH_WINDOW_HOURS,
    "warn_count": $DEFAULT_SUSPICIOUS_HIGH_WARN_COUNT,
    "crit_count": $DEFAULT_SUSPICIOUS_HIGH_CRIT_COUNT,
    "rate_warn_pct": $DEFAULT_SUSPICIOUS_HIGH_RATE_WARN_PCT,
    "rate_crit_pct": $DEFAULT_SUSPICIOUS_HIGH_RATE_CRIT_PCT
  },
  "metrics_drift": {
    "warn_keys": $DEFAULT_METRICS_DRIFT_WARN_KEYS,
    "crit_keys": $DEFAULT_METRICS_DRIFT_CRIT_KEYS,
    "warn_pct": $DEFAULT_METRICS_DRIFT_WARN_PCT,
    "crit_pct": $DEFAULT_METRICS_DRIFT_CRIT_PCT
  },
  "priority_gate_stuck": {
    "max_active_minutes": $DEFAULT_PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES,
    "max_cycles": $DEFAULT_PRIORITY_GATE_STUCK_MAX_CYCLES,
    "min_quality_drop_pct": $DEFAULT_PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT
  },
  "registry_reconcile": {
    "min_outside_keys": $DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS,
    "min_outside_pct": $DEFAULT_REGISTRY_RECONCILE_MIN_OUTSIDE_PCT,
    "min_interval_seconds": $DEFAULT_REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS,
    "always_sync_any_drift": $DEFAULT_REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT
  }
}
EOF
}

load_statusd_thresholds_from_file() {
    [ -f "$STATUSD_THRESHOLDS_FILE" ] || return 0
    local parsed
    parsed=$(python3 - "$STATUSD_THRESHOLDS_FILE" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        cfg = json.load(f)
except Exception:
    cfg = {}

def out(k, v):
    if v is None:
        return
    print(f"{k}={v}")

rq = cfg.get("repair_queue_stagnation", {}) if isinstance(cfg.get("repair_queue_stagnation", {}), dict) else {}
sh = cfg.get("suspicious_high", {}) if isinstance(cfg.get("suspicious_high", {}), dict) else {}
md = cfg.get("metrics_drift", {}) if isinstance(cfg.get("metrics_drift", {}), dict) else {}
pg = cfg.get("priority_gate_stuck", {}) if isinstance(cfg.get("priority_gate_stuck", {}), dict) else {}
rr = cfg.get("registry_reconcile", {}) if isinstance(cfg.get("registry_reconcile", {}), dict) else {}

out("REPAIR_QUEUE_STAGNATION_HOURS", rq.get("window_hours"))
out("REPAIR_QUEUE_STAGNATION_MIN_SAMPLES", rq.get("min_samples"))
out("REPAIR_QUEUE_STAGNATION_MIN_DROP", rq.get("min_drop"))

out("SUSPICIOUS_HIGH_WINDOW_HOURS", sh.get("window_hours"))
out("SUSPICIOUS_HIGH_WARN_COUNT", sh.get("warn_count"))
out("SUSPICIOUS_HIGH_CRIT_COUNT", sh.get("crit_count"))
out("SUSPICIOUS_HIGH_RATE_WARN_PCT", sh.get("rate_warn_pct"))
out("SUSPICIOUS_HIGH_RATE_CRIT_PCT", sh.get("rate_crit_pct"))

out("METRICS_DRIFT_WARN_KEYS", md.get("warn_keys"))
out("METRICS_DRIFT_CRIT_KEYS", md.get("crit_keys"))
out("METRICS_DRIFT_WARN_PCT", md.get("warn_pct"))
out("METRICS_DRIFT_CRIT_PCT", md.get("crit_pct"))

out("PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES", pg.get("max_active_minutes"))
out("PRIORITY_GATE_STUCK_MAX_CYCLES", pg.get("max_cycles"))
out("PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT", pg.get("min_quality_drop_pct"))

out("REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS", rr.get("min_outside_keys"))
out("REGISTRY_RECONCILE_MIN_OUTSIDE_PCT", rr.get("min_outside_pct"))
out("REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS", rr.get("min_interval_seconds"))
out("REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT", str(rr.get("always_sync_any_drift")).lower() if "always_sync_any_drift" in rr else None)
PY
)

    while IFS='=' read -r key value; do
        [ -z "${key:-}" ] && continue
        case "$key" in
            REPAIR_QUEUE_STAGNATION_HOURS) REPAIR_QUEUE_STAGNATION_HOURS="$value" ;;
            REPAIR_QUEUE_STAGNATION_MIN_SAMPLES) REPAIR_QUEUE_STAGNATION_MIN_SAMPLES="$value" ;;
            REPAIR_QUEUE_STAGNATION_MIN_DROP) REPAIR_QUEUE_STAGNATION_MIN_DROP="$value" ;;
            SUSPICIOUS_HIGH_WINDOW_HOURS) SUSPICIOUS_HIGH_WINDOW_HOURS="$value" ;;
            SUSPICIOUS_HIGH_WARN_COUNT) SUSPICIOUS_HIGH_WARN_COUNT="$value" ;;
            SUSPICIOUS_HIGH_CRIT_COUNT) SUSPICIOUS_HIGH_CRIT_COUNT="$value" ;;
            SUSPICIOUS_HIGH_RATE_WARN_PCT) SUSPICIOUS_HIGH_RATE_WARN_PCT="$value" ;;
            SUSPICIOUS_HIGH_RATE_CRIT_PCT) SUSPICIOUS_HIGH_RATE_CRIT_PCT="$value" ;;
            METRICS_DRIFT_WARN_KEYS) METRICS_DRIFT_WARN_KEYS="$value" ;;
            METRICS_DRIFT_CRIT_KEYS) METRICS_DRIFT_CRIT_KEYS="$value" ;;
            METRICS_DRIFT_WARN_PCT) METRICS_DRIFT_WARN_PCT="$value" ;;
            METRICS_DRIFT_CRIT_PCT) METRICS_DRIFT_CRIT_PCT="$value" ;;
            PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES) PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES="$value" ;;
            PRIORITY_GATE_STUCK_MAX_CYCLES) PRIORITY_GATE_STUCK_MAX_CYCLES="$value" ;;
            PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT) PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT="$value" ;;
            REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS) REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS="$value" ;;
            REGISTRY_RECONCILE_MIN_OUTSIDE_PCT) REGISTRY_RECONCILE_MIN_OUTSIDE_PCT="$value" ;;
            REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS) REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS="$value" ;;
            REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT) REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT="$value" ;;
        esac
    done <<< "$parsed"
}

apply_statusd_env_overrides() {
    [ "$STATUSD_USE_ENV_OVERRIDES" = "1" ] || return 0
    REPAIR_QUEUE_STAGNATION_HOURS="${STATUSD_REPAIR_QUEUE_STAGNATION_HOURS:-$REPAIR_QUEUE_STAGNATION_HOURS}"
    REPAIR_QUEUE_STAGNATION_MIN_SAMPLES="${STATUSD_REPAIR_QUEUE_STAGNATION_MIN_SAMPLES:-$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES}"
    REPAIR_QUEUE_STAGNATION_MIN_DROP="${STATUSD_REPAIR_QUEUE_STAGNATION_MIN_DROP:-$REPAIR_QUEUE_STAGNATION_MIN_DROP}"
    SUSPICIOUS_HIGH_WINDOW_HOURS="${STATUSD_SUSPICIOUS_HIGH_WINDOW_HOURS:-$SUSPICIOUS_HIGH_WINDOW_HOURS}"
    SUSPICIOUS_HIGH_WARN_COUNT="${STATUSD_SUSPICIOUS_HIGH_WARN_COUNT:-$SUSPICIOUS_HIGH_WARN_COUNT}"
    SUSPICIOUS_HIGH_CRIT_COUNT="${STATUSD_SUSPICIOUS_HIGH_CRIT_COUNT:-$SUSPICIOUS_HIGH_CRIT_COUNT}"
    SUSPICIOUS_HIGH_RATE_WARN_PCT="${STATUSD_SUSPICIOUS_HIGH_RATE_WARN_PCT:-$SUSPICIOUS_HIGH_RATE_WARN_PCT}"
    SUSPICIOUS_HIGH_RATE_CRIT_PCT="${STATUSD_SUSPICIOUS_HIGH_RATE_CRIT_PCT:-$SUSPICIOUS_HIGH_RATE_CRIT_PCT}"
    METRICS_DRIFT_WARN_KEYS="${STATUSD_METRICS_DRIFT_WARN_KEYS:-$METRICS_DRIFT_WARN_KEYS}"
    METRICS_DRIFT_CRIT_KEYS="${STATUSD_METRICS_DRIFT_CRIT_KEYS:-$METRICS_DRIFT_CRIT_KEYS}"
    METRICS_DRIFT_WARN_PCT="${STATUSD_METRICS_DRIFT_WARN_PCT:-$METRICS_DRIFT_WARN_PCT}"
    METRICS_DRIFT_CRIT_PCT="${STATUSD_METRICS_DRIFT_CRIT_PCT:-$METRICS_DRIFT_CRIT_PCT}"
    PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES="${STATUSD_PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES:-$PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES}"
    PRIORITY_GATE_STUCK_MAX_CYCLES="${STATUSD_PRIORITY_GATE_STUCK_MAX_CYCLES:-$PRIORITY_GATE_STUCK_MAX_CYCLES}"
    PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT="${STATUSD_PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT:-$PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT}"
    REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS="${STATUSD_REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS:-$REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS}"
    REGISTRY_RECONCILE_MIN_OUTSIDE_PCT="${STATUSD_REGISTRY_RECONCILE_MIN_OUTSIDE_PCT:-$REGISTRY_RECONCILE_MIN_OUTSIDE_PCT}"
    REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS="${STATUSD_REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS:-$REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS}"
    REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT="${STATUSD_REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT:-$REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT}"
}

ensure_statusd_thresholds_file
load_statusd_thresholds_from_file
apply_statusd_env_overrides

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 1: Agregacja telemetrii
# ═══════════════════════════════════════════════════════════════════════════════

aggregate_telemetry() {
    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_REPORT_FILE" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" "$SUSPICIOUS_HIGH_WINDOW_HOURS" "$SUSPICIOUS_HIGH_WARN_COUNT" "$SUSPICIOUS_HIGH_CRIT_COUNT" "$METRICS_DRIFT_WARN_KEYS" "$METRICS_DRIFT_CRIT_KEYS" "$METRICS_DRIFT_WARN_PCT" "$METRICS_DRIFT_CRIT_PCT" "$SUSPICIOUS_HIGH_RATE_WARN_PCT" "$SUSPICIOUS_HIGH_RATE_CRIT_PCT" "$STATUSD_THRESHOLDS_FILE" "$STATUSD_USE_ENV_OVERRIDES" "$PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES" "$PRIORITY_GATE_STUCK_MAX_CYCLES" "$PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT" "$REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS" "$REGISTRY_RECONCILE_MIN_OUTSIDE_PCT" "$REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS" "$REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT" <<'PYAGG'
import json, sys, os, time
from datetime import datetime, timezone, timedelta
from pathlib import Path
from collections import Counter

work_dir = sys.argv[1]
status_dir = sys.argv[2]
report_file = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))
suspicious_window_h = float(sys.argv[7] or "6")
suspicious_warn_count = int(float(sys.argv[8] or "120"))
suspicious_crit_count = int(float(sys.argv[9] or "240"))
metrics_drift_warn_keys = int(float(sys.argv[10] or "50000"))
metrics_drift_crit_keys = int(float(sys.argv[11] or "100000"))
metrics_drift_warn_pct = float(sys.argv[12] or "95")
metrics_drift_crit_pct = float(sys.argv[13] or "99")
suspicious_rate_warn_pct = float(sys.argv[14] if len(sys.argv) > 14 and sys.argv[14] else "8")
suspicious_rate_crit_pct = float(sys.argv[15] if len(sys.argv) > 15 and sys.argv[15] else "20")
thresholds_file = str(sys.argv[16]) if len(sys.argv) > 16 else ""
thresholds_env_override = bool(str(sys.argv[17]).strip() == "1") if len(sys.argv) > 17 else False
priority_gate_max_active_min = float(sys.argv[18] if len(sys.argv) > 18 and sys.argv[18] else "180")
priority_gate_max_cycles = int(float(sys.argv[19] if len(sys.argv) > 19 and sys.argv[19] else "240"))
priority_gate_min_quality_drop_pct = float(sys.argv[20] if len(sys.argv) > 20 and sys.argv[20] else "1")
registry_reconcile_min_outside_keys = int(float(sys.argv[21] if len(sys.argv) > 21 and sys.argv[21] else "1000"))
registry_reconcile_min_outside_pct = float(sys.argv[22] if len(sys.argv) > 22 and sys.argv[22] else "2")
registry_reconcile_min_interval_s = int(float(sys.argv[23] if len(sys.argv) > 23 and sys.argv[23] else "1800"))
registry_reconcile_always_sync_any_drift = bool(str(sys.argv[24]).strip().lower() in ("1", "true", "yes", "on")) if len(sys.argv) > 24 else True

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

def _read_json_retry(path, retries=3, delay_s=0.05):
    for idx in range(max(1, retries)):
        try:
            with open(path, encoding="utf-8") as f:
                payload = json.load(f)
            return payload if isinstance(payload, dict) else {}
        except Exception:
            if idx + 1 < retries:
                time.sleep(delay_s)
    return {}

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

def _analyze_suspicious_high(status_dir, now, window_h, warn_count, crit_count, rate_warn_pct=8.0, rate_crit_pct=20.0):
    quality_path = os.path.join(status_dir, "quality_report.jsonl")
    window_h = max(float(window_h), 0.1)
    warn_count = max(int(warn_count), 1)
    crit_count = max(int(crit_count), warn_count + 1)
    window_start = now - timedelta(hours=window_h)

    rows = []
    latest_ts = None
    latest_ts = None
    if os.path.exists(quality_path):
        with open(quality_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except Exception:
                    continue
                dt = _parse_ts(row.get("timestamp"))
                if dt is None or dt < window_start:
                    continue
                lang = str(row.get("language", "") or "").lower()
                category = str(row.get("json_file", "") or "").lower()
                translated = _safe_int(row.get("translated", 0))
                q = row.get("quality", {}) if isinstance(row.get("quality", {}), dict) else {}
                suspicious_high = _safe_int(q.get("suspicious_high", 0))
                rows.append({
                    "timestamp": dt.isoformat().replace("+00:00", "Z"),
                    "lang": lang,
                    "category": category,
                    "translated": translated,
                    "suspicious_high": suspicious_high,
                })

    rows.sort(key=lambda x: x["timestamp"])
    translated_total = sum(int(r.get("translated", 0)) for r in rows)
    suspicious_high_total = sum(int(r.get("suspicious_high", 0)) for r in rows)
    by_lang = Counter()
    by_category = Counter()
    for r in rows:
        sh = int(r.get("suspicious_high", 0))
        if sh <= 0:
            continue
        lang = str(r.get("lang", "") or "")
        category = str(r.get("category", "") or "")
        if lang:
            by_lang[lang] += sh
        if category:
            by_category[category] += sh

    rate_pct = (float(suspicious_high_total) / float(max(translated_total, 1))) * 100.0
    if suspicious_high_total >= crit_count:
        severity = "critical"
        status = "spike"
    elif suspicious_high_total >= warn_count:
        severity = "warning"
        status = "elevated"
    elif suspicious_high_total > 0:
        severity = "info"
        status = "observed"
    else:
        severity = "ok"
        status = "clean"

    # ── Per-lang / per-domain breakdown z rate-based severity ──────────────
    translated_by_lang = Counter()
    translated_by_cat = Counter()
    for r in rows:
        lang = str(r.get("lang", "") or "")
        cat = str(r.get("category", "") or "")
        tr = int(r.get("translated", 0))
        if lang:
            translated_by_lang[lang] += tr
        if cat:
            translated_by_cat[cat] += tr

    def _per_item_severity(sh_count, tr_count, rw=rate_warn_pct, rc=rate_crit_pct):
        r = (float(sh_count) / float(max(tr_count, 1))) * 100.0
        if r >= rc:
            return "critical", round(r, 3)
        elif r >= rw:
            return "warning", round(r, 3)
        elif sh_count > 0:
            return "info", round(r, 3)
        return "ok", 0.0

    per_lang = []
    for lang, sh_cnt in by_lang.most_common(8):
        sev, r = _per_item_severity(sh_cnt, translated_by_lang.get(lang, 0))
        per_lang.append({"lang": lang, "suspicious_high": int(sh_cnt), "translated": int(translated_by_lang.get(lang, 0)), "rate_pct": r, "severity": sev})
    per_domain = []
    for cat, sh_cnt in by_category.most_common(10):
        sev, r = _per_item_severity(sh_cnt, translated_by_cat.get(cat, 0))
        per_domain.append({"domain": cat, "suspicious_high": int(sh_cnt), "translated": int(translated_by_cat.get(cat, 0)), "rate_pct": r, "severity": sev})

    # Najgorszy severity z per-lang/per-domain
    all_sevs = [severity]  # global
    all_sevs += [x["severity"] for x in per_lang]
    all_sevs += [x["severity"] for x in per_domain]
    sev_rank = {"critical": 3, "warning": 2, "info": 1, "ok": 0}
    worst_sev = max(all_sevs, key=lambda s: sev_rank.get(s, 0))

    return {
        "window_hours": float(window_h),
        "warn_count": int(warn_count),
        "critical_count": int(crit_count),
        "rate_warn_pct": float(rate_warn_pct),
        "rate_crit_pct": float(rate_crit_pct),
        "entries": len(rows),
        "translated_total": int(translated_total),
        "suspicious_high_total": int(suspicious_high_total),
        "suspicious_high_rate_pct": round(rate_pct, 3),
        "status": status,
        "severity": severity,
        "worst_severity": worst_sev,
        "top_langs": [{"lang": k, "suspicious_high": int(v)} for k, v in by_lang.most_common(8)],
        "top_categories": [{"category": k, "suspicious_high": int(v)} for k, v in by_category.most_common(10)],
        "per_lang": per_lang,
        "per_domain": per_domain,
        "latest_timestamp": rows[-1]["timestamp"] if rows else "",
    }

def _analyze_priority_gate_watch(status_dir, dispatch, quality_watch, now, max_active_minutes=180.0, max_cycles=240, min_quality_drop_pct=1.0):
    watch_state_path = os.path.join(status_dir, "priority_gate_watch_state.json")
    pg = dispatch.get("priority_gate", {}) if isinstance(dispatch.get("priority_gate", {}), dict) else {}
    enabled = bool(pg.get("enabled", False))
    active = bool(pg.get("active", False))
    pending_langs = sorted({str(x).lower() for x in (pg.get("pending_langs", []) if isinstance(pg.get("pending_langs", []), list) else []) if str(x).strip()})
    pending_key = ",".join(pending_langs)
    cycle_counter = _safe_int(dispatch.get("cycle_counter", 0))
    current_quality_rate = float(quality_watch.get("suspicious_high_rate_pct", 0) or 0.0)

    lang_completion = {}
    try:
        for k, v in (pg.get("lang_completion", {}) if isinstance(pg.get("lang_completion", {}), dict) else {}).items():
            lang_completion[str(k).lower()] = float(v or 0.0)
    except Exception:
        lang_completion = {}

    out = {
        "available": bool(enabled),
        "enabled": bool(enabled),
        "active": bool(active),
        "pending_langs": pending_langs,
        "pending_key": pending_key,
        "cycle_counter": int(cycle_counter),
        "start_cycle": int(cycle_counter),
        "cycle_delta": 0,
        "started_at": "",
        "active_minutes": 0.0,
        "baseline_quality_rate_pct": round(current_quality_rate, 3),
        "current_quality_rate_pct": round(current_quality_rate, 3),
        "best_quality_rate_pct": round(current_quality_rate, 3),
        "quality_drop_pct": 0.0,
        "best_quality_drop_pct": 0.0,
        "lang_completion": lang_completion,
        "detected": False,
        "severity": "ok",
        "reason": "inactive",
        "thresholds": {
            "max_active_minutes": float(max_active_minutes),
            "max_cycles": int(max_cycles),
            "min_quality_drop_pct": float(min_quality_drop_pct),
        },
    }

    state = _read_json_retry(watch_state_path)
    if not enabled:
        out["reason"] = "priority_gate_disabled"
    elif not active or not pending_langs:
        out["reason"] = "priority_gate_inactive"
    else:
        prev_active = bool(state.get("active", False))
        prev_pending_key = str(state.get("pending_key", "") or "")
        prev_started_at = _parse_ts(state.get("started_at", ""))
        prev_start_cycle = _safe_int(state.get("start_cycle", cycle_counter))
        prev_baseline_rate = float(state.get("baseline_quality_rate_pct", current_quality_rate) or current_quality_rate)
        prev_best_rate = float(state.get("best_quality_rate_pct", prev_baseline_rate) or prev_baseline_rate)

        continuing = prev_active and prev_pending_key == pending_key and prev_started_at is not None
        if continuing:
            started_at = prev_started_at
            start_cycle = prev_start_cycle
            baseline_rate = prev_baseline_rate
            best_rate = min(prev_best_rate, current_quality_rate)
        else:
            started_at = now
            start_cycle = cycle_counter
            baseline_rate = current_quality_rate
            best_rate = current_quality_rate

        active_minutes = max(0.0, (now - started_at).total_seconds() / 60.0)
        cycle_delta = max(0, int(cycle_counter - start_cycle))
        quality_drop = float(baseline_rate - current_quality_rate)
        best_quality_drop = float(baseline_rate - best_rate)

        detected = False
        reason = "tracking"
        if active_minutes >= float(max_active_minutes) and best_quality_drop < float(min_quality_drop_pct):
            detected = True
            reason = "active_time_without_quality_drop"
        elif cycle_delta >= int(max_cycles) and best_quality_drop < float(min_quality_drop_pct):
            detected = True
            reason = "cycle_budget_without_quality_drop"

        severity = "ok"
        if detected:
            if active_minutes >= (float(max_active_minutes) * 2.0) or cycle_delta >= (int(max_cycles) * 2):
                severity = "critical"
            else:
                severity = "warning"
        elif active_minutes >= (float(max_active_minutes) * 0.75) or cycle_delta >= int(int(max_cycles) * 0.75):
            severity = "info"

        out.update({
            "start_cycle": int(start_cycle),
            "cycle_delta": int(cycle_delta),
            "started_at": started_at.isoformat().replace("+00:00", "Z"),
            "active_minutes": round(active_minutes, 3),
            "baseline_quality_rate_pct": round(baseline_rate, 3),
            "current_quality_rate_pct": round(current_quality_rate, 3),
            "best_quality_rate_pct": round(best_rate, 3),
            "quality_drop_pct": round(quality_drop, 3),
            "best_quality_drop_pct": round(best_quality_drop, 3),
            "detected": bool(detected),
            "severity": severity,
            "reason": reason,
        })

    try:
        persisted = {
            "timestamp": now.isoformat().replace("+00:00", "Z"),
            "enabled": bool(out.get("enabled", False)),
            "active": bool(out.get("active", False)),
            "pending_key": str(out.get("pending_key", "") or ""),
            "pending_langs": out.get("pending_langs", []),
            "started_at": str(out.get("started_at", "") or ""),
            "start_cycle": int(out.get("start_cycle", 0) or 0),
            "cycle_counter": int(out.get("cycle_counter", 0) or 0),
            "baseline_quality_rate_pct": float(out.get("baseline_quality_rate_pct", 0.0) or 0.0),
            "best_quality_rate_pct": float(out.get("best_quality_rate_pct", 0.0) or 0.0),
            "current_quality_rate_pct": float(out.get("current_quality_rate_pct", 0.0) or 0.0),
            "active_minutes": float(out.get("active_minutes", 0.0) or 0.0),
            "detected": bool(out.get("detected", False)),
            "severity": str(out.get("severity", "ok") or "ok"),
            "reason": str(out.get("reason", "") or ""),
            "lang_completion": out.get("lang_completion", {}),
        }
        with open(watch_state_path, "w", encoding="utf-8") as wf:
            json.dump(persisted, wf, indent=2, ensure_ascii=False)
    except Exception:
        pass

    return out

# ── Heartbeat / worker state ─────────────────────────────────────────────
worker_state = {}
try:
    with open(os.path.join(status_dir, "worker_state.json"), encoding="utf-8") as f:
        worker_state = json.load(f)
except Exception:
    pass

heartbeat_at = ""
heartbeat_age_s = -1
worker_pid = 0
worker_pid_alive = False
try:
    w = worker_state.get("worker", {})
    heartbeat_at = w.get("heartbeat_at_utc", "")
    if heartbeat_at:
        hb_dt = datetime.fromisoformat(heartbeat_at.replace("Z", "+00:00"))
        heartbeat_age_s = (now - hb_dt).total_seconds()
    worker_pid = _safe_int(w.get("pid", 0), 0)
except Exception:
    pass

try:
    pid_path = os.path.join(work_dir, ".worker_simple.pid")
    if os.path.exists(pid_path):
        with open(pid_path, encoding="utf-8") as f:
            pid_from_file = _safe_int(str(f.read()).strip(), 0)
        if pid_from_file > 0:
            worker_pid = pid_from_file
except Exception:
    pass
worker_pid_alive = bool(worker_pid > 0 and os.path.exists(f"/proc/{worker_pid}"))

report["worker"] = {
    "pid": int(worker_pid),
    "heartbeat_at": heartbeat_at,
    "heartbeat_age_s": round(heartbeat_age_s, 1),
    "cycle": worker_state.get("worker", {}).get("cycle", -1),
    "mode": worker_state.get("worker", {}).get("mode", "?"),
    "category": worker_state.get("worker", {}).get("category", "?"),
    "pid_alive": worker_pid_alive,
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
    "cycle_counter": _safe_int(dispatch.get("cycle_counter", 0)),
    "pending_total": dispatch.get("last_pending_total", 0),
    "candidates": dispatch.get("active_candidates_count", 0),
    "skipped_backoff": dispatch.get("skipped_backoff", 0),
    "skipped_guard_fail": dispatch.get("skipped_guard_fail", 0),
    "priority_gate": dispatch.get("priority_gate", {}) if isinstance(dispatch.get("priority_gate", {}), dict) else {},
}

# ── Coverage (z translation_global_overview) ────────────────────────────
overview = {}
overview = _read_json_retry(os.path.join(status_dir, "translation_global_overview.json"))

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

# ── Migration stats (z file_status + overview) ─────────────────────────
migration = overview.get("migration", {})
if not isinstance(migration, dict):
    migration = {}

def _collect_live_migration_snapshot():
    try:
        fs_path = os.path.join(work_dir, "i18n_file_status.json")
        with open(fs_path, encoding="utf-8") as f:
            fs = json.load(f)
        fs_files = fs.get("files", {})
        if not isinstance(fs_files, dict):
            fs_files = {}
        fs_global = fs.get("global_stats", {})
        if not isinstance(fs_global, dict):
            fs_global = {}

        fs_completed = 0
        fs_keys_registry_raw = 0
        for info in fs_files.values():
            if not isinstance(info, dict):
                continue
            if str(info.get("overall_status", "")) == "completed":
                fs_completed += 1
            stages = info.get("stages", {}) if isinstance(info.get("stages", {}), dict) else {}
            fs_keys_registry_raw += _safe_int(
                (stages.get("5_extraction_en", {}) if isinstance(stages.get("5_extraction_en", {}), dict) else {}).get("keys_added", 0)
            )

        fs_keys_live = 0
        en_dir = os.path.join(work_dir, "i18n", "en")
        if os.path.isdir(en_dir):
            for name in os.listdir(en_dir):
                if not name.endswith(".json"):
                    continue
                try:
                    with open(os.path.join(en_dir, name), encoding="utf-8") as ef:
                        payload = json.load(ef)
                    if isinstance(payload, dict):
                        fs_keys_live += len(payload)
                except Exception:
                    continue

        reconcile_adjustment = max(0, _safe_int(fs_global.get("reconciled_external_keys", 0)))
        fs_keys_registry_effective = max(0, int(fs_keys_registry_raw + reconcile_adjustment))
        if fs_keys_live > 0:
            fs_keys_registry_effective = min(fs_keys_registry_effective, int(fs_keys_live))
        outside_raw = max(0, int(fs_keys_live - fs_keys_registry_raw))
        outside_effective = max(0, int(fs_keys_live - fs_keys_registry_effective))

        snapshot = {
            "files_total": len(fs_files),
            "files_completed": int(fs_completed),
            "scanned_files_live": len(fs_files),
            "total_keys_extracted": int(fs_keys_live),
            "total_keys_extracted_live": int(fs_keys_live),
            "total_keys_extracted_worker_registry": int(fs_keys_registry_effective),
            "total_keys_extracted_worker_registry_raw": int(fs_keys_registry_raw),
            "registry_reconcile_adjustment": int(reconcile_adjustment),
            "keys_extracted_outside_worker_registry": int(outside_effective),
            "keys_extracted_outside_worker_registry_raw": int(outside_raw),
            "statusd_live_snapshot_at_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "statusd_live_snapshot_source": "i18n_file_status+en_json",
        }
        return snapshot
    except Exception:
        return {}

live_snapshot = _collect_live_migration_snapshot()
if live_snapshot:
    if not migration:
        migration = {}
    migration["files_total"] = int(live_snapshot.get("files_total", migration.get("files_total", 0)))
    migration["files_completed"] = int(live_snapshot.get("files_completed", migration.get("files_completed", 0)))
    migration["scanned_files_live"] = int(live_snapshot.get("scanned_files_live", migration.get("scanned_files_live", 0)))
    migration["total_keys_extracted"] = int(live_snapshot.get("total_keys_extracted_live", migration.get("total_keys_extracted", 0)))
    migration["total_keys_extracted_live"] = int(live_snapshot.get("total_keys_extracted_live", migration.get("total_keys_extracted_live", 0)))
    migration["total_keys_extracted_worker_registry"] = int(
        live_snapshot.get("total_keys_extracted_worker_registry", migration.get("total_keys_extracted_worker_registry", 0))
    )
    migration["total_keys_extracted_worker_registry_raw"] = int(
        live_snapshot.get("total_keys_extracted_worker_registry_raw", migration.get("total_keys_extracted_worker_registry_raw", 0))
    )
    migration["registry_reconcile_adjustment"] = int(
        live_snapshot.get("registry_reconcile_adjustment", migration.get("registry_reconcile_adjustment", 0))
    )
    migration["keys_extracted_outside_worker_registry"] = int(
        live_snapshot.get("keys_extracted_outside_worker_registry", migration.get("keys_extracted_outside_worker_registry", 0))
    )
    migration["keys_extracted_outside_worker_registry_raw"] = int(
        live_snapshot.get("keys_extracted_outside_worker_registry_raw", migration.get("keys_extracted_outside_worker_registry_raw", 0))
    )
    migration["statusd_live_snapshot_at_utc"] = str(
        live_snapshot.get("statusd_live_snapshot_at_utc", migration.get("statusd_live_snapshot_at_utc", ""))
    )
    migration["statusd_live_snapshot_source"] = str(
        live_snapshot.get("statusd_live_snapshot_source", migration.get("statusd_live_snapshot_source", ""))
    )
report["migration"] = migration

# ── Metrics drift (LIVE vs worker registry) ──────────────────────────────
live_keys = _safe_int(migration.get("total_keys_extracted_live", migration.get("total_keys_extracted", 0)))
registry_keys = _safe_int(migration.get("total_keys_extracted_worker_registry", migration.get("keys_extracted", 0)))
registry_keys_raw = _safe_int(migration.get("total_keys_extracted_worker_registry_raw", registry_keys))
registry_reconcile_adjustment = _safe_int(migration.get("registry_reconcile_adjustment", max(0, registry_keys - registry_keys_raw)))
outside_registry = _safe_int(
    migration.get("keys_extracted_outside_worker_registry", max(0, live_keys - registry_keys))
)
outside_registry_raw = _safe_int(
    migration.get("keys_extracted_outside_worker_registry_raw", max(0, live_keys - registry_keys_raw))
)
outside_registry = max(0, outside_registry)
outside_registry_raw = max(0, outside_registry_raw)
drift_pct = round((outside_registry / live_keys * 100.0), 3) if live_keys > 0 else 0.0
drift_pct_raw = round((outside_registry_raw / live_keys * 100.0), 3) if live_keys > 0 else 0.0
if outside_registry >= metrics_drift_crit_keys or drift_pct >= metrics_drift_crit_pct:
    drift_severity = "critical"
    drift_status = "high"
elif outside_registry >= metrics_drift_warn_keys or drift_pct >= metrics_drift_warn_pct:
    drift_severity = "warning"
    drift_status = "elevated"
else:
    drift_severity = "ok"
    drift_status = "stable"
report["metrics_drift"] = {
    "available": bool(migration),
    "status": drift_status,
    "severity": drift_severity,
    "live_keys": int(live_keys),
    "worker_registry_keys": int(registry_keys),
    "worker_registry_keys_raw": int(registry_keys_raw),
    "registry_reconcile_adjustment": int(max(0, registry_reconcile_adjustment)),
    "outside_worker_registry_keys": int(outside_registry),
    "outside_worker_registry_pct": drift_pct,
    "outside_worker_registry_keys_raw": int(outside_registry_raw),
    "outside_worker_registry_pct_raw": drift_pct_raw,
    "warn_threshold_keys": int(metrics_drift_warn_keys),
    "critical_threshold_keys": int(metrics_drift_crit_keys),
    "warn_threshold_pct": float(metrics_drift_warn_pct),
    "critical_threshold_pct": float(metrics_drift_crit_pct),
}

# ── Coverage by scope (serwer vs instalka) ──────────────────────────────
scope_totals = overview.get("scope_totals", {})
coverage_by_scope = {}
for row in languages if isinstance(languages, list) else []:
    lang = str(row.get("lang", "")).lower()
    if not lang:
        continue
    coverage_by_scope[lang] = {
        "server_keys": int(row.get("server_keys", 0) or 0),
        "server_translated": int(row.get("server_translated", 0) or 0),
        "server_pct": float(row.get("server_pct", 0) or 0),
        "client_keys": int(row.get("client_keys", 0) or 0),
        "client_translated": int(row.get("client_translated", 0) or 0),
        "client_pct": float(row.get("client_pct", 0) or 0),
    }
report["coverage_by_scope"] = {
    "scope_totals": scope_totals,
    "per_lang": {k: coverage_by_scope[k] for k in sorted(coverage_by_scope.keys())},
}

# ── Repair queue health (identical_to_en backlog) ────────────────────────
report["repair_queue"] = _analyze_repair_queue(
    status_dir=status_dir,
    now=now,
    window_h=repair_window_h,
    min_samples=repair_min_samples,
    min_drop=repair_min_drop,
)
report["quality_watch"] = _analyze_suspicious_high(
    status_dir=status_dir,
    now=now,
    window_h=suspicious_window_h,
    warn_count=suspicious_warn_count,
    crit_count=suspicious_crit_count,
    rate_warn_pct=suspicious_rate_warn_pct,
    rate_crit_pct=suspicious_rate_crit_pct,
)
report["priority_gate_watch"] = _analyze_priority_gate_watch(
    status_dir=status_dir,
    dispatch=dispatch,
    quality_watch=report["quality_watch"],
    now=now,
    max_active_minutes=priority_gate_max_active_min,
    max_cycles=priority_gate_max_cycles,
    min_quality_drop_pct=priority_gate_min_quality_drop_pct,
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

# ── Thresholds snapshot (kanoniczne źródło aktywnych progów) ─────────────
report["thresholds_snapshot"] = {
    "source_of_truth": "statusd_thresholds_file",
    "config_file": thresholds_file,
    "env_overrides_enabled": bool(thresholds_env_override),
    "repair_queue_stagnation": {
        "window_hours": float(repair_window_h),
        "min_samples": int(repair_min_samples),
        "min_drop": int(repair_min_drop),
    },
    "suspicious_high": {
        "window_hours": float(suspicious_window_h),
        "warn_count": int(suspicious_warn_count),
        "crit_count": int(suspicious_crit_count),
        "rate_warn_pct": float(suspicious_rate_warn_pct),
        "rate_crit_pct": float(suspicious_rate_crit_pct),
    },
    "metrics_drift": {
        "warn_keys": int(metrics_drift_warn_keys),
        "crit_keys": int(metrics_drift_crit_keys),
        "warn_pct": float(metrics_drift_warn_pct),
        "crit_pct": float(metrics_drift_crit_pct),
    },
    "priority_gate_stuck": {
        "max_active_minutes": float(priority_gate_max_active_min),
        "max_cycles": int(priority_gate_max_cycles),
        "min_quality_drop_pct": float(priority_gate_min_quality_drop_pct),
    },
    "registry_reconcile": {
        "min_outside_keys": int(registry_reconcile_min_outside_keys),
        "min_outside_pct": float(registry_reconcile_min_outside_pct),
        "min_interval_seconds": int(registry_reconcile_min_interval_s),
        "always_sync_any_drift": bool(registry_reconcile_always_sync_any_drift),
    },
}

# Zapisz snapshot progów jako osobny artefakt audytowy
try:
    thresholds_path = os.path.join(status_dir, "statusd_thresholds_snapshot.json")
    with open(thresholds_path, "w", encoding="utf-8") as f:
        json.dump({
            "timestamp": report["timestamp"],
            **report["thresholds_snapshot"],
        }, f, indent=2, ensure_ascii=False)
except Exception:
    pass

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
    QUEUE_FRESHNESS_WARN_S="$QUEUE_FRESHNESS_WARN_S" QUEUE_FRESHNESS_CRIT_S="$QUEUE_FRESHNESS_CRIT_S" \
    python3 - "$WORK_DIR" "$STATUS_DIR" "$STATUSD_DOCTOR_FILE" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" "$SUSPICIOUS_HIGH_WINDOW_HOURS" "$SUSPICIOUS_HIGH_WARN_COUNT" "$SUSPICIOUS_HIGH_CRIT_COUNT" "$METRICS_DRIFT_WARN_KEYS" "$METRICS_DRIFT_CRIT_KEYS" "$METRICS_DRIFT_WARN_PCT" "$METRICS_DRIFT_CRIT_PCT" "$SUSPICIOUS_HIGH_RATE_WARN_PCT" "$SUSPICIOUS_HIGH_RATE_CRIT_PCT" "$STATUSD_THRESHOLDS_FILE" "$STATUSD_USE_ENV_OVERRIDES" "$PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES" "$PRIORITY_GATE_STUCK_MAX_CYCLES" "$PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT" "$REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS" "$REGISTRY_RECONCILE_MIN_OUTSIDE_PCT" "$REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS" "$REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT" <<'PYDOCTOR'
import json, sys, os, subprocess
from datetime import datetime, timezone, timedelta
from collections import Counter

work_dir = sys.argv[1]
status_dir = sys.argv[2]
doctor_file = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))
suspicious_window_h = float(sys.argv[7] or "6")
suspicious_warn_count = int(float(sys.argv[8] or "120"))
suspicious_crit_count = int(float(sys.argv[9] or "240"))
metrics_drift_warn_keys = int(float(sys.argv[10] or "50000"))
metrics_drift_crit_keys = int(float(sys.argv[11] or "100000"))
metrics_drift_warn_pct = float(sys.argv[12] or "95")
metrics_drift_crit_pct = float(sys.argv[13] or "99")
suspicious_rate_warn_pct = float(sys.argv[14] if len(sys.argv) > 14 and sys.argv[14] else "8")
suspicious_rate_crit_pct = float(sys.argv[15] if len(sys.argv) > 15 and sys.argv[15] else "20")
thresholds_file = str(sys.argv[16]) if len(sys.argv) > 16 else ""
thresholds_env_override = bool(str(sys.argv[17]).strip() == "1") if len(sys.argv) > 17 else False
priority_gate_max_active_min = float(sys.argv[18] if len(sys.argv) > 18 and sys.argv[18] else "180")
priority_gate_max_cycles = int(float(sys.argv[19] if len(sys.argv) > 19 and sys.argv[19] else "240"))
priority_gate_min_quality_drop_pct = float(sys.argv[20] if len(sys.argv) > 20 and sys.argv[20] else "1")
registry_reconcile_min_outside_keys = int(float(sys.argv[21] if len(sys.argv) > 21 and sys.argv[21] else "1000"))
registry_reconcile_min_outside_pct = float(sys.argv[22] if len(sys.argv) > 22 and sys.argv[22] else "2")
registry_reconcile_min_interval_s = int(float(sys.argv[23] if len(sys.argv) > 23 and sys.argv[23] else "1800"))
registry_reconcile_always_sync_any_drift = bool(str(sys.argv[24]).strip().lower() in ("1", "true", "yes", "on")) if len(sys.argv) > 24 else True

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

def _read_worker_process_health():
    data = {
        "available": False,
        "severity": "info",
        "status": "unknown",
        "reason": "not_checked",
        "main_pid": 0,
        "matched_pids": [],
        "extra_pids": [],
        "descendant_extra_pids": [],
        "foreign_extra_pids": [],
        "total_matching": 0,
        "extra_count": 0,
        "descendant_extra_count": 0,
        "foreign_extra_count": 0,
        "oldest_descendant_age_s": 0,
        "oldest_foreign_age_s": 0,
        "warn_persist_seconds": 900,
        "critical_persist_seconds": 1800,
    }
    pid_file = os.path.join(work_dir, ".worker_simple.pid")
    if not os.path.exists(pid_file):
        data["status"] = "no_pid_file"
        data["reason"] = "worker_pid_file_missing"
        return data

    try:
        with open(pid_file, encoding="utf-8") as f:
            main_pid = int(str(f.read()).strip() or "0")
    except Exception:
        main_pid = 0
    if main_pid <= 0:
        data["status"] = "invalid_pid_file"
        data["reason"] = "worker_pid_file_invalid"
        return data
    data["main_pid"] = int(main_pid)
    data["available"] = True
    if not os.path.exists(f"/proc/{main_pid}"):
        data["severity"] = "critical"
        data["status"] = "main_pid_not_alive"
        data["reason"] = "worker_pid_file_points_to_dead_process"
        return data

    pattern = "i18n_worker_simple.sh --continuous"
    matched = set()
    try:
        raw = subprocess.check_output(
            ["pgrep", "-f", pattern],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        for line in raw.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                pid = int(line)
            except Exception:
                continue
            if pid > 0 and os.path.exists(f"/proc/{pid}"):
                matched.add(pid)
    except Exception:
        pass

    if not matched:
        try:
            for entry in os.listdir("/proc"):
                if not entry.isdigit():
                    continue
                pid = int(entry)
                cmdline_path = os.path.join("/proc", entry, "cmdline")
                if not os.path.exists(cmdline_path):
                    continue
                try:
                    with open(cmdline_path, "rb") as f:
                        cmd = f.read().decode("utf-8", errors="ignore").replace("\x00", " ")
                except Exception:
                    continue
                if pattern in cmd:
                    matched.add(pid)
        except Exception:
            pass

    matched.add(main_pid)
    matched = sorted([pid for pid in matched if os.path.exists(f"/proc/{pid}")])

    ppid_map = {}
    etimes_map = {}
    if matched:
        try:
            raw = subprocess.check_output(
                ["ps", "-o", "pid=,ppid=,etimes=", "-p", ",".join(str(pid) for pid in matched)],
                stderr=subprocess.DEVNULL,
                text=True,
            )
            for line in raw.splitlines():
                parts = line.split()
                if len(parts) < 3:
                    continue
                try:
                    pid = int(parts[0])
                    ppid = int(parts[1])
                    etimes = int(parts[2])
                except Exception:
                    continue
                ppid_map[pid] = ppid
                etimes_map[pid] = max(0, etimes)
        except Exception:
            pass

    def _is_descendant(pid, root):
        seen = set()
        cur = int(pid)
        while cur > 1 and cur not in seen:
            seen.add(cur)
            parent = ppid_map.get(cur)
            if parent is None:
                return False
            if parent == root:
                return True
            cur = parent
        return False

    extra = [pid for pid in matched if pid != main_pid]
    descendant_extra = [pid for pid in extra if _is_descendant(pid, main_pid)]
    foreign_extra = [pid for pid in extra if pid not in descendant_extra]
    oldest_desc = max([etimes_map.get(pid, 0) for pid in descendant_extra], default=0)
    oldest_foreign = max([etimes_map.get(pid, 0) for pid in foreign_extra], default=0)

    data.update({
        "matched_pids": matched,
        "extra_pids": extra,
        "descendant_extra_pids": descendant_extra,
        "foreign_extra_pids": foreign_extra,
        "total_matching": len(matched),
        "extra_count": len(extra),
        "descendant_extra_count": len(descendant_extra),
        "foreign_extra_count": len(foreign_extra),
        "oldest_descendant_age_s": int(oldest_desc),
        "oldest_foreign_age_s": int(oldest_foreign),
    })

    warn_persist_s = int(data["warn_persist_seconds"])
    crit_persist_s = int(data["critical_persist_seconds"])

    if foreign_extra:
        data["status"] = "foreign_processes_detected"
        data["reason"] = "non_descendant_worker_process_present"
        if len(foreign_extra) >= 2 or oldest_foreign >= crit_persist_s:
            data["severity"] = "critical"
        else:
            data["severity"] = "warning"
    elif len(descendant_extra) >= 2:
        data["status"] = "extra_descendants_detected"
        data["reason"] = "multiple_descendant_worker_processes"
        if oldest_desc >= crit_persist_s:
            data["severity"] = "critical"
        elif oldest_desc >= warn_persist_s:
            data["severity"] = "warning"
        else:
            data["severity"] = "info"
    elif len(descendant_extra) == 1:
        data["status"] = "single_descendant_observed"
        data["reason"] = "single_descendant_worker_subprocess"
        if oldest_desc >= crit_persist_s:
            data["severity"] = "warning"
        elif oldest_desc >= warn_persist_s:
            data["severity"] = "info"
        else:
            data["severity"] = "ok"
    else:
        data["severity"] = "ok"
        data["status"] = "clean"
        data["reason"] = "single_worker_process"

    return data

def _read_worker_translation_contract():
    data = {
        "available": False,
        "severity": "info",
        "status": "unknown",
        "reason": "not_checked",
        "worker_pid": 0,
        "worker_cmdline": "",
        "has_translations_only": False,
        "has_use_gt": False,
        "has_no_git": False,
        "dispatch_available": False,
        "global_quality_mode": False,
        "priority_gate_enabled": False,
        "priority_gate_active": False,
        "priority_langs": [],
        "es_pl_priority_ok": False,
        "pending_langs": [],
    }

    pid_file = os.path.join(work_dir, ".worker_simple.pid")
    if not os.path.exists(pid_file):
        data["status"] = "no_pid_file"
        data["reason"] = "worker_pid_file_missing"
        return data

    try:
        with open(pid_file, encoding="utf-8") as f:
            worker_pid = int(str(f.read()).strip() or "0")
    except Exception:
        worker_pid = 0
    if worker_pid <= 0:
        data["status"] = "invalid_pid_file"
        data["reason"] = "worker_pid_file_invalid"
        return data

    data["available"] = True
    data["worker_pid"] = int(worker_pid)
    proc_cmdline_path = os.path.join("/proc", str(worker_pid), "cmdline")
    if not os.path.exists(proc_cmdline_path):
        data["severity"] = "critical"
        data["status"] = "worker_not_alive"
        data["reason"] = "worker_pid_not_running"
        return data

    argv = []
    try:
        with open(proc_cmdline_path, "rb") as f:
            raw = f.read()
        argv = [x for x in raw.decode("utf-8", errors="ignore").split("\x00") if x]
    except Exception:
        argv = []

    cmdline = " ".join(argv)
    argset = set(argv)
    has_translations_only = "--translations-only" in argset
    has_use_gt = "--use-gt" in argset
    has_no_git = "--no-git" in argset

    data.update({
        "worker_cmdline": cmdline,
        "has_translations_only": bool(has_translations_only),
        "has_use_gt": bool(has_use_gt),
        "has_no_git": bool(has_no_git),
    })

    dispatch = {}
    try:
        with open(os.path.join(status_dir, "translation_dispatch_state.json"), encoding="utf-8") as f:
            dispatch = json.load(f)
    except Exception:
        dispatch = {}

    if isinstance(dispatch, dict) and dispatch:
        data["dispatch_available"] = True
        pg = dispatch.get("priority_gate", {}) if isinstance(dispatch.get("priority_gate", {}), dict) else {}
        priority_langs = [str(x).lower().strip() for x in (pg.get("priority_langs", []) if isinstance(pg.get("priority_langs", []), list) else []) if str(x).strip()]
        pending_langs = [str(x).lower().strip() for x in (pg.get("pending_langs", []) if isinstance(pg.get("pending_langs", []), list) else []) if str(x).strip()]
        es_pl_priority_ok = len(priority_langs) >= 2 and priority_langs[0] == "es" and priority_langs[1] == "pl"
        data.update({
            "global_quality_mode": bool(dispatch.get("global_quality_mode", False)),
            "priority_gate_enabled": bool(pg.get("enabled", False)),
            "priority_gate_active": bool(pg.get("active", False)),
            "priority_langs": priority_langs,
            "pending_langs": pending_langs,
            "es_pl_priority_ok": bool(es_pl_priority_ok),
        })

    if not has_translations_only:
        data["severity"] = "critical"
        data["status"] = "worker_not_in_translations_only"
        data["reason"] = "missing_flag_translations_only"
    elif data.get("global_quality_mode", False) and not data.get("priority_gate_enabled", False):
        data["severity"] = "warning"
        data["status"] = "priority_gate_disabled"
        data["reason"] = "global_quality_without_priority_gate"
    elif data.get("priority_gate_enabled", False) and not data.get("es_pl_priority_ok", False):
        data["severity"] = "warning"
        data["status"] = "priority_lang_order_mismatch"
        data["reason"] = "priority_langs_not_es_pl"
    else:
        data["severity"] = "ok"
        data["status"] = "contract_ok"
        data["reason"] = "translations_general_runtime_contract_ok"

    return data

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

def _read_suspicious_high_health():
    quality_path = os.path.join(status_dir, "quality_report.jsonl")
    data = {
        "window_hours": float(max(suspicious_window_h, 0.1)),
        "warn_count": int(max(suspicious_warn_count, 1)),
        "critical_count": int(max(suspicious_crit_count, suspicious_warn_count + 1)),
        "rate_warn_pct": float(suspicious_rate_warn_pct),
        "rate_crit_pct": float(suspicious_rate_crit_pct),
        "entries": 0,
        "translated_total": 0,
        "suspicious_high_total": 0,
        "suspicious_high_rate_pct": 0.0,
        "top_lang": "",
        "top_lang_count": 0,
        "severity": "ok",
        "status": "clean",
        "per_lang": [],
        "per_domain": [],
        "worst_severity": "ok",
    }
    if not os.path.exists(quality_path):
        data["status"] = "missing_quality_report"
        return data

    window_start = now - timedelta(hours=data["window_hours"])
    by_lang = Counter()
    by_domain = Counter()
    translated_by_lang = Counter()
    translated_by_domain = Counter()
    rows = 0
    translated_total = 0
    suspicious_high_total = 0
    with open(quality_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            ts = _parse_ts(row.get("timestamp"))
            if ts is None or ts < window_start:
                continue
            rows += 1
            translated = _safe_int(row.get("translated", 0))
            q = row.get("quality", {}) if isinstance(row.get("quality", {}), dict) else {}
            sh = _safe_int(q.get("suspicious_high", 0))
            translated_total += translated
            suspicious_high_total += sh
            lang = str(row.get("language", "") or "").lower()
            domain = str(row.get("json_file", "") or "").lower()
            if lang:
                translated_by_lang[lang] += translated
                if sh > 0:
                    by_lang[lang] += sh
            if domain:
                translated_by_domain[domain] += translated
                if sh > 0:
                    by_domain[domain] += sh

    rate_pct = (float(suspicious_high_total) / float(max(translated_total, 1))) * 100.0
    top_lang = ""
    top_lang_count = 0
    if by_lang:
        top_lang, top_lang_count = by_lang.most_common(1)[0]

    severity = "ok"
    status = "clean"
    if suspicious_high_total >= data["critical_count"]:
        severity = "critical"
        status = "spike"
    elif suspicious_high_total >= data["warn_count"]:
        severity = "warning"
        status = "elevated"
    elif suspicious_high_total > 0:
        severity = "info"
        status = "observed"

    # ── Per-lang / per-domain rate-based severity ────────────────────────
    rw = data["rate_warn_pct"]
    rc = data["rate_crit_pct"]

    def _item_sev(sh_count, tr_count):
        r = (float(sh_count) / float(max(tr_count, 1))) * 100.0
        if r >= rc:
            return "critical", round(r, 3)
        elif r >= rw:
            return "warning", round(r, 3)
        elif sh_count > 0:
            return "info", round(r, 3)
        return "ok", 0.0

    per_lang = []
    for lang, cnt in by_lang.most_common(8):
        sev, r = _item_sev(cnt, translated_by_lang.get(lang, 0))
        per_lang.append({"lang": lang, "suspicious_high": int(cnt), "translated": int(translated_by_lang.get(lang, 0)), "rate_pct": r, "severity": sev})
    per_domain = []
    for dom, cnt in by_domain.most_common(10):
        sev, r = _item_sev(cnt, translated_by_domain.get(dom, 0))
        per_domain.append({"domain": dom, "suspicious_high": int(cnt), "translated": int(translated_by_domain.get(dom, 0)), "rate_pct": r, "severity": sev})

    sev_rank = {"critical": 3, "warning": 2, "info": 1, "ok": 0}
    all_sevs = [severity] + [x["severity"] for x in per_lang] + [x["severity"] for x in per_domain]
    worst_sev = max(all_sevs, key=lambda s: sev_rank.get(s, 0))

    data.update({
        "entries": rows,
        "translated_total": int(translated_total),
        "suspicious_high_total": int(suspicious_high_total),
        "suspicious_high_rate_pct": round(rate_pct, 3),
        "top_lang": str(top_lang),
        "top_lang_count": int(top_lang_count),
        "severity": severity,
        "worst_severity": worst_sev,
        "status": status,
        "per_lang": per_lang,
        "per_domain": per_domain,
    })
    return data

def _read_metrics_drift():
    data = {
        "available": False,
        "status": "missing",
        "severity": "info",
        "live_keys": 0,
        "worker_registry_keys": 0,
        "worker_registry_keys_raw": 0,
        "registry_reconcile_adjustment": 0,
        "outside_worker_registry_keys": 0,
        "outside_worker_registry_pct": 0.0,
        "outside_worker_registry_keys_raw": 0,
        "outside_worker_registry_pct_raw": 0.0,
        "warn_threshold_keys": int(metrics_drift_warn_keys),
        "critical_threshold_keys": int(metrics_drift_crit_keys),
        "warn_threshold_pct": float(metrics_drift_warn_pct),
        "critical_threshold_pct": float(metrics_drift_crit_pct),
    }
    overview_path = os.path.join(status_dir, "translation_global_overview.json")
    if not os.path.exists(overview_path):
        return data
    try:
        with open(overview_path, encoding="utf-8") as f:
            overview = json.load(f)
    except Exception:
        return data
    migration = overview.get("migration", {}) if isinstance(overview.get("migration", {}), dict) else {}
    if not migration:
        return data

    live_keys = _safe_int(migration.get("total_keys_extracted_live", migration.get("total_keys_extracted", 0)))
    worker_registry_keys_effective = _safe_int(
        migration.get("total_keys_extracted_worker_registry", migration.get("keys_extracted", 0))
    )
    worker_registry_keys_raw = _safe_int(
        migration.get("total_keys_extracted_worker_registry_raw", worker_registry_keys_effective)
    )
    registry_reconcile_adjustment = _safe_int(
        migration.get("registry_reconcile_adjustment", max(0, worker_registry_keys_effective - worker_registry_keys_raw))
    )
    if registry_reconcile_adjustment <= 0:
        try:
            with open(os.path.join(work_dir, "i18n_file_status.json"), encoding="utf-8") as f:
                fs = json.load(f)
            gs = fs.get("global_stats", {}) if isinstance(fs.get("global_stats", {}), dict) else {}
            fs_adjust = max(0, _safe_int(gs.get("reconciled_external_keys", 0)))
            if fs_adjust > registry_reconcile_adjustment:
                worker_registry_keys_effective = min(int(live_keys), int(worker_registry_keys_raw + fs_adjust))
                registry_reconcile_adjustment = int(fs_adjust)
        except Exception:
            pass
    outside_worker_registry_keys = max(0, int(live_keys - worker_registry_keys_effective))
    outside_worker_registry_keys_raw = max(0, int(live_keys - worker_registry_keys_raw))
    outside_pct = round((outside_worker_registry_keys / float(max(live_keys, 1))) * 100.0, 3) if live_keys > 0 else 0.0
    outside_pct_raw = round((outside_worker_registry_keys_raw / float(max(live_keys, 1))) * 100.0, 3) if live_keys > 0 else 0.0

    severity = "ok"
    status = "stable"
    if outside_worker_registry_keys >= metrics_drift_crit_keys or outside_pct >= metrics_drift_crit_pct:
        severity = "critical"
        status = "high"
    elif outside_worker_registry_keys >= metrics_drift_warn_keys or outside_pct >= metrics_drift_warn_pct:
        severity = "warning"
        status = "elevated"

    data.update({
        "available": True,
        "status": status,
        "severity": severity,
        "live_keys": int(live_keys),
        "worker_registry_keys": int(worker_registry_keys_effective),
        "worker_registry_keys_raw": int(worker_registry_keys_raw),
        "registry_reconcile_adjustment": int(max(0, registry_reconcile_adjustment)),
        "outside_worker_registry_keys": int(outside_worker_registry_keys),
        "outside_worker_registry_pct": float(outside_pct),
        "outside_worker_registry_keys_raw": int(outside_worker_registry_keys_raw),
        "outside_worker_registry_pct_raw": float(outside_pct_raw),
    })
    return data

def _read_priority_gate_watch():
    data = {
        "available": False,
        "enabled": False,
        "active": False,
        "detected": False,
        "severity": "ok",
        "reason": "missing",
        "pending_langs": [],
        "active_minutes": 0.0,
        "cycle_delta": 0,
        "best_quality_drop_pct": 0.0,
        "thresholds": {
            "max_active_minutes": float(priority_gate_max_active_min),
            "max_cycles": int(priority_gate_max_cycles),
            "min_quality_drop_pct": float(priority_gate_min_quality_drop_pct),
        },
    }
    report_path = os.path.join(status_dir, "statusd_report.json")
    if not os.path.exists(report_path):
        return data
    try:
        with open(report_path, encoding="utf-8") as f:
            report = json.load(f)
    except Exception:
        return data
    pg = report.get("priority_gate_watch", {}) if isinstance(report.get("priority_gate_watch", {}), dict) else {}
    if not pg:
        return data
    data.update({
        "available": True,
        "enabled": bool(pg.get("enabled", False)),
        "active": bool(pg.get("active", False)),
        "detected": bool(pg.get("detected", False)),
        "severity": str(pg.get("severity", "ok") or "ok"),
        "reason": str(pg.get("reason", "unknown") or "unknown"),
        "pending_langs": [str(x) for x in (pg.get("pending_langs", []) if isinstance(pg.get("pending_langs", []), list) else [])],
        "active_minutes": float(pg.get("active_minutes", 0.0) or 0.0),
        "cycle_delta": int(pg.get("cycle_delta", 0) or 0),
        "best_quality_drop_pct": float(pg.get("best_quality_drop_pct", 0.0) or 0.0),
        "thresholds": pg.get("thresholds", data["thresholds"]) if isinstance(pg.get("thresholds", {}), dict) else data["thresholds"],
    })
    return data

# ── 1. Freshness: heartbeat (dynamiczny kontrakt pod długie cykle) ─────
try:
    ws = {}
    with open(os.path.join(status_dir, "worker_state.json"), encoding="utf-8") as f:
        ws = json.load(f)
    hb = str(ws.get("worker", {}).get("heartbeat_at_utc", "") or "")
    if not hb:
        try:
            with open(os.path.join(status_dir, "activity.json"), encoding="utf-8") as af:
                activity = json.load(af)
            hb = str(activity.get("generated_at_utc", "") or "")
        except Exception:
            hb = ""

    heartbeat_aging_s = 180.0
    heartbeat_stale_s = 240.0
    heartbeat_stuck_s = 420.0
    active_grace_s = 150.0
    pid_alive_hint = False
    worker_log_age_s = -1.0
    guard_last_entry_age_s = -1.0
    try:
        with open(os.path.join(status_dir, "guardian_health.json"), encoding="utf-8") as gf:
            gh = json.load(gf)
        heartbeat_aging_s = max(30.0, float(gh.get("heartbeat_aging_seconds", heartbeat_aging_s) or heartbeat_aging_s))
        heartbeat_stale_s = max(heartbeat_aging_s + 1.0, float(gh.get("heartbeat_stale_seconds", heartbeat_stale_s) or heartbeat_stale_s))
        heartbeat_stuck_s = max(heartbeat_stale_s + 1.0, float(gh.get("heartbeat_stuck_seconds", heartbeat_stuck_s) or heartbeat_stuck_s))
        active_grace_s = max(30.0, float(gh.get("active_log_grace_seconds", active_grace_s) or active_grace_s))
        pid_alive_hint = bool(gh.get("pid_alive", False))
        worker_log_age_s = float(gh.get("worker_log_age_s", -1) or -1)
        guard_last_entry_age_s = float(gh.get("guard_last_entry_age_s", -1) or -1)
    except Exception:
        pass

    if not pid_alive_hint:
        try:
            pid_path = os.path.join(work_dir, ".worker_simple.pid")
            if os.path.exists(pid_path):
                with open(pid_path, encoding="utf-8") as pf:
                    pid = int(str(pf.read()).strip() or "0")
                pid_alive_hint = bool(pid > 0 and os.path.exists(f"/proc/{pid}"))
        except Exception:
            pid_alive_hint = False

    if hb:
        hb_dt = datetime.fromisoformat(hb.replace("Z", "+00:00"))
        age_s = (now - hb_dt).total_seconds()
        active_reasons = []
        if pid_alive_hint:
            active_reasons.append("pid_alive")
        if 0 <= worker_log_age_s <= (active_grace_s + 60):
            active_reasons.append(f"log_age={worker_log_age_s:.0f}s")
        if 0 <= guard_last_entry_age_s <= (active_grace_s + 60):
            active_reasons.append(f"guard_age={guard_last_entry_age_s:.0f}s")

        if age_s > heartbeat_stuck_s:
            if active_reasons:
                warnings.append(
                    f"STALE_HEARTBEAT_BUT_ACTIVE: heartbeat sprzed {age_s:.0f}s "
                    f"(stuck>{heartbeat_stuck_s:.0f}s), active=[{','.join(active_reasons)}]"
                )
            else:
                issues.append(
                    f"STALE_HEARTBEAT: heartbeat sprzed {age_s:.0f}s "
                    f"(stuck>{heartbeat_stuck_s:.0f}s, stale>{heartbeat_stale_s:.0f}s)"
                )
        elif age_s > heartbeat_stale_s:
            warnings.append(
                f"STALE_HEARTBEAT_WARNING: heartbeat sprzed {age_s:.0f}s "
                f"(stale>{heartbeat_stale_s:.0f}s)"
            )
        elif age_s > heartbeat_aging_s:
            warnings.append(
                f"AGING_HEARTBEAT: heartbeat sprzed {age_s:.0f}s "
                f"(aging>{heartbeat_aging_s:.0f}s)"
            )
        else:
            ok_checks.append(
                f"heartbeat_fresh ({age_s:.0f}s, aging/stale/stuck="
                f"{heartbeat_aging_s:.0f}/{heartbeat_stale_s:.0f}/{heartbeat_stuck_s:.0f}s)"
            )
    else:
        issues.append("NO_HEARTBEAT: brak heartbeat w worker_state/activity")
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

# ── 5b. Worker process topology (subprocessy / dublowanie instancji) ───
worker_process_watch_info = {}
try:
    worker_process_watch_info = _read_worker_process_health()
    if not worker_process_watch_info.get("available", False):
        warnings.append(
            f"WORKER_PROCESS_WATCH_UNAVAILABLE: status={worker_process_watch_info.get('status', 'unknown')} "
            f"reason={worker_process_watch_info.get('reason', 'unknown')}"
        )
    else:
        desc = (
            f"main={worker_process_watch_info.get('main_pid', 0)} "
            f"matching={worker_process_watch_info.get('total_matching', 0)} "
            f"extras={worker_process_watch_info.get('extra_count', 0)} "
            f"desc={worker_process_watch_info.get('descendant_extra_count', 0)} "
            f"foreign={worker_process_watch_info.get('foreign_extra_count', 0)} "
            f"oldest_desc={worker_process_watch_info.get('oldest_descendant_age_s', 0)}s "
            f"oldest_foreign={worker_process_watch_info.get('oldest_foreign_age_s', 0)}s "
            f"status={worker_process_watch_info.get('status', 'unknown')}"
        )
        sev = str(worker_process_watch_info.get("severity", "ok") or "ok").lower()
        if sev == "critical":
            issues.append(f"WORKER_PROCESS_DUPLICATION: {desc}")
        elif sev == "warning":
            warnings.append(f"WORKER_PROCESS_DUPLICATION_WARNING: {desc}")
        elif sev == "info":
            ok_checks.append(f"worker_subprocess_observed ({desc})")
        else:
            ok_checks.append(f"worker_process_topology_ok ({desc})")
except Exception as e:
    warnings.append(f"WORKER_PROCESS_WATCH_ERROR: {e}")

# ── 5c. Kontrakt runtime tłumaczeń (translations-only + ES/PL gate) ────
translation_contract_info = {}
try:
    translation_contract_info = _read_worker_translation_contract()
    if not translation_contract_info.get("available", False):
        warnings.append(
            f"WORKER_TRANSLATION_CONTRACT_UNAVAILABLE: status={translation_contract_info.get('status', 'unknown')} "
            f"reason={translation_contract_info.get('reason', 'unknown')}"
        )
    else:
        priority_langs = ",".join(translation_contract_info.get("priority_langs", [])) or "-"
        pending_langs = ",".join(translation_contract_info.get("pending_langs", [])) or "-"
        desc = (
            f"pid={translation_contract_info.get('worker_pid', 0)} "
            f"translations_only={int(bool(translation_contract_info.get('has_translations_only', False)))} "
            f"use_gt={int(bool(translation_contract_info.get('has_use_gt', False)))} "
            f"no_git={int(bool(translation_contract_info.get('has_no_git', False)))} "
            f"priority_gate={int(bool(translation_contract_info.get('priority_gate_enabled', False)))} "
            f"priority_langs=[{priority_langs}] pending=[{pending_langs}]"
        )
        sev = str(translation_contract_info.get("severity", "ok") or "ok").lower()
        reason = str(translation_contract_info.get("reason", "unknown") or "unknown")
        if sev == "critical":
            issues.append(f"WORKER_TRANSLATION_CONTRACT_BROKEN: {desc} reason={reason}")
        elif sev == "warning":
            warnings.append(f"WORKER_TRANSLATION_CONTRACT_WARNING: {desc} reason={reason}")
        else:
            ok_checks.append(f"worker_translation_contract_ok ({desc})")
except Exception as e:
    warnings.append(f"WORKER_TRANSLATION_CONTRACT_CHECK_ERROR: {e}")

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
            qf_warn = float(os.environ.get("QUEUE_FRESHNESS_WARN_S", "900"))
            qf_crit = float(os.environ.get("QUEUE_FRESHNESS_CRIT_S", "1800"))
            if rq_age > qf_crit:
                issues.append(f"QUEUE_FRESHNESS_CRIT: queue snapshot sprzed {rq_age:.0f}s (>{qf_crit:.0f}s)")
            elif rq_age > qf_warn:
                warnings.append(f"QUEUE_FRESHNESS_WARN: queue snapshot sprzed {rq_age:.0f}s (>{qf_warn:.0f}s)")
            else:
                ok_checks.append(f"queue_freshness_ok ({rq_age:.0f}s, WARN>{qf_warn:.0f}s CRIT>{qf_crit:.0f}s)")
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

# ── 9. suspicious_high trend (quality regression early signal) ───────────
try:
    sh = _read_suspicious_high_health()
    if sh.get("status") == "missing_quality_report":
        warnings.append("NO_QUALITY_REPORT: brak quality_report.jsonl")
    else:
        worst = str(sh.get("worst_severity", sh.get("severity", "ok")))
        desc = (
            f"suspicious_high={sh.get('suspicious_high_total', 0)} "
            f"rate={sh.get('suspicious_high_rate_pct', 0)}% "
            f"window={sh.get('window_hours', 0)}h "
            f"top_lang={sh.get('top_lang','-')}:{sh.get('top_lang_count', 0)}"
        )
        # Per-lang/per-domain breakdowns
        per_lang_issues = []
        for pl in sh.get("per_lang", []):
            if pl.get("severity") in ("critical", "warning"):
                per_lang_issues.append(f"{pl['lang']}:{pl['suspicious_high']}({pl['rate_pct']}%/{pl['severity']})")
        per_domain_issues = []
        for pd in sh.get("per_domain", []):
            if pd.get("severity") in ("critical", "warning"):
                per_domain_issues.append(f"{pd['domain']}:{pd['suspicious_high']}({pd['rate_pct']}%/{pd['severity']})")

        if per_lang_issues:
            desc += f" per_lang=[{','.join(per_lang_issues[:5])}]"
        if per_domain_issues:
            desc += f" per_domain=[{','.join(per_domain_issues[:5])}]"

        if worst == "critical":
            issues.append(f"SUSPICIOUS_HIGH_SPIKE: {desc}")
        elif worst == "warning":
            warnings.append(f"SUSPICIOUS_HIGH_ELEVATED: {desc}")
        else:
            ok_checks.append(f"suspicious_high_ok ({desc})")
except Exception as e:
    warnings.append(f"SUSPICIOUS_HIGH_CHECK_ERROR: {e}")

# ── 10. Drift metryk LIVE vs worker-registry ──────────────────────────────
metrics_drift_info = {}
try:
    metrics_drift_info = _read_metrics_drift()
    if not metrics_drift_info.get("available", False):
        warnings.append("METRICS_DRIFT_UNAVAILABLE: brak danych migracji LIVE/registry")
    else:
        desc = (
            f"outside={metrics_drift_info.get('outside_worker_registry_keys', 0)} "
            f"({metrics_drift_info.get('outside_worker_registry_pct', 0):.2f}%) "
            f"live={metrics_drift_info.get('live_keys', 0)} "
            f"registry={metrics_drift_info.get('worker_registry_keys', 0)}"
        )
        sev = str(metrics_drift_info.get("severity", "ok"))
        if sev == "critical":
            issues.append(f"METRICS_DRIFT_HIGH: {desc}")
        elif sev == "warning":
            warnings.append(f"METRICS_DRIFT_ELEVATED: {desc}")
        else:
            ok_checks.append(f"metrics_drift_ok ({desc})")
except Exception as e:
    warnings.append(f"METRICS_DRIFT_CHECK_ERROR: {e}")

# ── 11. Priority gate watchdog (ES/PL stuck detector) ───────────────────
priority_gate_watch_info = {}
try:
    priority_gate_watch_info = _read_priority_gate_watch()
    if not priority_gate_watch_info.get("available", False):
        warnings.append("PRIORITY_GATE_WATCH_UNAVAILABLE: brak priority_gate_watch w statusd_report.json")
    elif not priority_gate_watch_info.get("enabled", False):
        ok_checks.append("priority_gate_watch_disabled")
    elif not priority_gate_watch_info.get("active", False):
        ok_checks.append("priority_gate_inactive")
    else:
        pending = ",".join(priority_gate_watch_info.get("pending_langs", [])) or "-"
        desc = (
            f"pending=[{pending}] active_minutes={priority_gate_watch_info.get('active_minutes', 0):.1f} "
            f"cycle_delta={priority_gate_watch_info.get('cycle_delta', 0)} "
            f"best_quality_drop={priority_gate_watch_info.get('best_quality_drop_pct', 0):.3f}%"
        )
        if priority_gate_watch_info.get("detected", False):
            sev = str(priority_gate_watch_info.get("severity", "warning"))
            reason = str(priority_gate_watch_info.get("reason", "stuck"))
            if sev == "critical":
                issues.append(f"PRIORITY_GATE_STUCK_CRITICAL: {desc} reason={reason}")
            else:
                warnings.append(f"PRIORITY_GATE_STUCK: {desc} reason={reason}")
        else:
            ok_checks.append(f"priority_gate_tracking ({desc})")
except Exception as e:
    warnings.append(f"PRIORITY_GATE_WATCH_CHECK_ERROR: {e}")

# ── 12. Repair tuning samples check ────────────────────────────────────
try:
    rq_available = False
    rq_entries_total = 0
    try:
        rq_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
        if os.path.exists(rq_path):
            with open(rq_path, encoding="utf-8") as f:
                rq_data = json.load(f)
            rq_available = True
            rq_entries_total = _safe_int(rq_data.get("entries_total", 0))
    except Exception:
        pass

    tuning_path = os.path.join(status_dir, "identical_to_en_repair_tuning.jsonl")
    if rq_available and rq_entries_total > 0:
        tuning_samples_2h = 0
        window_2h = now - timedelta(hours=2)
        if os.path.exists(tuning_path):
            with open(tuning_path, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        row = json.loads(line)
                        ts = _parse_ts(row.get("timestamp"))
                        if ts and ts >= window_2h:
                            tuning_samples_2h += 1
                    except Exception:
                        continue
        if tuning_samples_2h == 0:
            warnings.append(
                f"REPAIR_TUNING_NO_SAMPLES: backlog={rq_entries_total} ale samples_2h=0 "
                f"(repair tuning nie generuje próbek mimo aktywnej kolejki)"
            )
        else:
            ok_checks.append(f"repair_tuning_active (samples_2h={tuning_samples_2h})")
    elif rq_available and rq_entries_total == 0:
        ok_checks.append("repair_tuning_not_needed (entries_total=0)")
except Exception as e:
    warnings.append(f"REPAIR_TUNING_CHECK_ERROR: {e}")

# ── Check: Lang parity alert (T2 backlog / genuine translations) ──────────
# Jeśli T2 lang ma >5000 [EN]-backlog po 48h → WARN
# Jeśli T2 lang ma <100 genuine translations po 72h → CRIT
try:
    i18n_dir = os.path.join(work_dir, "i18n")
    en_dir = os.path.join(i18n_dir, "en")
    tier2_langs_set = {"de","pt","ru","tr","fr","it","nl","cs","sk","hu"}
    # Sprawdź ile godzin statusd działa (od pierwszego doctor_file timestamp)
    statusd_first_ts = None
    try:
        if os.path.exists(doctor_file):
            with open(doctor_file, encoding="utf-8") as f:
                old_doc = json.load(f)
            statusd_first_ts = _parse_ts(old_doc.get("first_run_ts"))
    except Exception:
        pass
    if not statusd_first_ts:
        statusd_first_ts = now

    hours_running = (now - statusd_first_ts).total_seconds() / 3600.0

    if hours_running > 24 and os.path.isdir(en_dir):
        en_files = sorted([f for f in os.listdir(en_dir) if f.endswith(".json")])
        lang_parity_ok = 0
        lang_parity_warn = 0
        lang_parity_crit = 0

        for lang_code in sorted(tier2_langs_set):
            lang_dir = os.path.join(i18n_dir, lang_code)
            if not os.path.isdir(lang_dir):
                continue
            en_backlog = 0
            genuine = 0
            for jf in en_files:
                en_path = os.path.join(en_dir, jf)
                lang_path = os.path.join(lang_dir, jf)
                if not os.path.exists(lang_path):
                    continue
                try:
                    with open(en_path, encoding="utf-8") as f:
                        en_data = json.load(f)
                    with open(lang_path, encoding="utf-8") as f:
                        lang_data = json.load(f)
                    for k, v in en_data.items():
                        lv = lang_data.get(k)
                        if lv is None:
                            continue
                        slv = str(lv)
                        if slv.startswith("[EN]") or slv.startswith("["):
                            en_backlog += 1
                        elif slv != str(v) and slv.strip():
                            genuine += 1
                except Exception:
                    continue

            if hours_running > 72 and genuine < 100:
                issues.append(f"LANG_PARITY_CRIT: {lang_code} has only {genuine} genuine translations after {hours_running:.0f}h (need ≥100)")
                lang_parity_crit += 1
            elif hours_running > 48 and en_backlog > 5000:
                warnings.append(f"LANG_PARITY_WARN: {lang_code} has {en_backlog} [EN]-backlog after {hours_running:.0f}h (should be ≤5000)")
                lang_parity_warn += 1
            else:
                lang_parity_ok += 1

        if lang_parity_ok > 0 and lang_parity_warn == 0 and lang_parity_crit == 0:
            ok_checks.append(f"lang_parity_t2_ok ({lang_parity_ok} langs within bounds)")
except Exception as e:
    warnings.append(f"LANG_PARITY_CHECK_ERROR: {e}")

# ── Ocena ogólna ───────────────────────────────────────────────────────
if issues:
    overall = "CRITICAL"
elif warnings:
    overall = "WARNING"
else:
    overall = "HEALTHY"

doctor_report = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "first_run_ts": (statusd_first_ts or now).isoformat().replace("+00:00", "Z"),
    "overall": overall,
    "issues_count": len(issues),
    "warnings_count": len(warnings),
    "ok_count": len(ok_checks),
    "issues": issues,
    "warnings": warnings,
    "ok": ok_checks,
    "metrics_drift": metrics_drift_info if isinstance(metrics_drift_info, dict) else {},
    "priority_gate_watch": priority_gate_watch_info if isinstance(priority_gate_watch_info, dict) else {},
    "worker_process_watch": worker_process_watch_info if isinstance(worker_process_watch_info, dict) else {},
    "translation_contract": translation_contract_info if isinstance(translation_contract_info, dict) else {},
    "thresholds_snapshot": {
        "source_of_truth": "statusd_thresholds_file",
        "config_file": thresholds_file,
        "env_overrides_enabled": bool(thresholds_env_override),
        "repair_queue_stagnation": {
            "window_hours": float(max(repair_window_h, 0.1)),
            "min_samples": int(max(repair_min_samples, 1)),
            "min_drop": int(max(repair_min_drop, 0)),
        },
        "suspicious_high": {
            "window_hours": float(max(suspicious_window_h, 0.1)),
            "warn_count": int(max(suspicious_warn_count, 1)),
            "crit_count": int(max(suspicious_crit_count, suspicious_warn_count + 1)),
            "rate_warn_pct": float(suspicious_rate_warn_pct),
            "rate_crit_pct": float(suspicious_rate_crit_pct),
        },
        "metrics_drift": {
            "warn_keys": int(metrics_drift_warn_keys),
            "crit_keys": int(metrics_drift_crit_keys),
            "warn_pct": float(metrics_drift_warn_pct),
            "crit_pct": float(metrics_drift_crit_pct),
        },
        "priority_gate_stuck": {
            "max_active_minutes": float(priority_gate_max_active_min),
            "max_cycles": int(priority_gate_max_cycles),
            "min_quality_drop_pct": float(priority_gate_min_quality_drop_pct),
        },
        "registry_reconcile": {
            "min_outside_keys": int(registry_reconcile_min_outside_keys),
            "min_outside_pct": float(registry_reconcile_min_outside_pct),
            "min_interval_seconds": int(registry_reconcile_min_interval_s),
            "always_sync_any_drift": bool(registry_reconcile_always_sync_any_drift),
        },
    },
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

# Multilang: genuine / en_backlog / diacritics_rate per T2 language
try:
    import re
    i18n_dir = "i18n"
    en_dir_p = os.path.join(i18n_dir, "en")
    t2_langs = ["de","pt","ru","tr","fr","it","nl","cs","sk","hu"]
    EXPECTED_DIACRITICS = {
        "de": r"[äöüßÄÖÜ]", "fr": r"[àâæçéèêëîïôûùüÿœÀÂÆÇÉÈÊËÎÏÔÛÙÜŸŒ]",
        "pt": r"[ãáàâçéêíóôõúüÃÁÀÂÇÉÊÍÓÔÕÚÜ]", "it": r"[àèéìíîòóùúÀÈÉÌÍÎÒÓÙÚ]",
        "nl": r"[ëïéèêüóáàäöËÏÉÈÊÜÓÁÀÄÖ]", "cs": r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]",
        "sk": r"[áäčďéíľĺňóôŕšťúýžÁÄČĎÉÍĽĹŇÓÔŔŠŤÚÝŽ]", "hu": r"[áéíóöőúüűÁÉÍÓÖŐÚÜŰ]",
        "tr": r"[çğıöşüÇĞİÖŞÜ]", "ru": r"[а-яА-ЯёЁ]",
    }
    en_files_p = sorted([f for f in os.listdir(en_dir_p) if f.endswith(".json")]) if os.path.isdir(en_dir_p) else []
    print(f"\n{'─'*60}")
    print(f"{'Lang':>4} {'Genuine':>8} {'[EN]bkl':>8} {'Diacr%':>7} {'Tier':>4}")
    print(f"{'─'*60}")
    for lc in t2_langs:
        ld = os.path.join(i18n_dir, lc)
        if not os.path.isdir(ld):
            continue
        genuine = 0
        en_bkl = 0
        total_genuine_chars = 0
        diacritics_chars = 0
        diac_re = EXPECTED_DIACRITICS.get(lc)
        for jf in en_files_p:
            ep = os.path.join(en_dir_p, jf)
            lp = os.path.join(ld, jf)
            if not os.path.exists(lp):
                continue
            try:
                with open(ep, encoding="utf-8") as f:
                    ed = json.load(f)
                with open(lp, encoding="utf-8") as f:
                    ld_ = json.load(f)
            except:
                continue
            for k, ev in ed.items():
                lv = ld_.get(k)
                if lv is None:
                    continue
                slv = str(lv)
                sev = str(ev)
                if slv.startswith("[EN]") or slv.startswith("["):
                    en_bkl += 1
                elif slv != sev and slv.strip():
                    genuine += 1
                    if diac_re and len(slv) > 30:
                        total_genuine_chars += 1
                        if re.search(diac_re, slv):
                            diacritics_chars += 1
        diac_pct = (diacritics_chars / max(total_genuine_chars, 1)) * 100
        print(f"{lc:>4} {genuine:>8} {en_bkl:>8} {diac_pct:>6.1f}%   T2")
    print(f"{'─'*60}")
except Exception as ex:
    print(f"⚠️ Multilang KPI error: {ex}")

# Queue freshness SLA
try:
    rq_path = os.path.join(status_dir, "identical_to_en_repair_queue.json")
    if os.path.exists(rq_path):
        rq_mtime = os.path.getmtime(rq_path)
        rq_age_s = (now - datetime.fromtimestamp(rq_mtime, tz=timezone.utc)).total_seconds()
        qf_warn = 900
        qf_crit = 1800
        if rq_age_s > qf_crit:
            status_label = "🔴 CRIT"
        elif rq_age_s > qf_warn:
            status_label = "🟡 WARN"
        else:
            status_label = "🟢 OK"
        print(f"\nQueue freshness SLA: {status_label} (age={rq_age_s:.0f}s, WARN>{qf_warn}s, CRIT>{qf_crit}s)")
    else:
        print(f"\nQueue freshness SLA: ⚫ N/A (brak pliku)")
except Exception as ex:
    print(f"\nQueue freshness SLA: ⚠️ error: {ex}")

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

# Rekomendacja 1b: priority gate stuck (ES/PL)
try:
    with open(os.path.join(status_dir, "statusd_report.json"), encoding="utf-8") as f:
        latest_report = json.load(f)
    pg = latest_report.get("priority_gate_watch", {}) if isinstance(latest_report.get("priority_gate_watch", {}), dict) else {}
    if pg.get("detected", False):
        pending = ",".join([str(x) for x in (pg.get("pending_langs", []) if isinstance(pg.get("pending_langs", []), list) else [])]) or "?"
        recommendations.append({
            "priority": "HIGH" if str(pg.get("severity", "warning")).lower() == "critical" else "MEDIUM",
            "action": "SWITCH_PROFILE quality_repair (short)",
            "reason": (
                f"priority_gate_stuck pending=[{pending}] active={float(pg.get('active_minutes', 0) or 0):.1f}m "
                f"cycles={int(pg.get('cycle_delta', 0) or 0)} drop={float(pg.get('best_quality_drop_pct', 0) or 0):.3f}%"
            ),
        })
except Exception:
    pass

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
    "SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK": {
        "cooldown_minutes": 90,
        "description": "Przełącz profil guardiana na quality_repair przy stuck fali ES/PL",
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

priority_gate_watch = {}
try:
    with open(os.path.join(status_dir, "statusd_report.json"), encoding="utf-8") as f:
        rep = json.load(f)
    priority_gate_watch = rep.get("priority_gate_watch", {}) if isinstance(rep.get("priority_gate_watch", {}), dict) else {}
except Exception:
    priority_gate_watch = {}

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

# ── Akcja 5: SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK ──────
action = "SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK"
pg_detected = bool(priority_gate_watch.get("detected", False))
pg_sev = str(priority_gate_watch.get("severity", "ok") or "ok").lower()
if pg_detected and pg_sev in ("warning", "critical"):
    pg_pending = ",".join([str(x) for x in (priority_gate_watch.get("pending_langs", []) if isinstance(priority_gate_watch.get("pending_langs", []), list) else [])]) or "-"
    pg_minutes = float(priority_gate_watch.get("active_minutes", 0) or 0.0)
    pg_cycles = int(priority_gate_watch.get("cycle_delta", 0) or 0)
    trigger = f"severity={pg_sev} pending={pg_pending} active_minutes={pg_minutes:.1f} cycles={pg_cycles}"
    fingerprint = f"{action}:{pg_sev}:{pg_pending}:{int(pg_cycles//20)}"
    precheck = f"priority_gate_stuck detected, severity={pg_sev}"
    if _cooldown_ok(action) and _idempotent_check(action, fingerprint):
        try:
            guardian_profile_path = os.path.join(work_dir, "guardian_profile.json")
            quality_profile_path = os.path.join(work_dir, "guardian_profiles", "quality_repair.json")
            if not os.path.exists(quality_profile_path):
                _audit_log(action, trigger, precheck, "SKIPPED (missing quality_repair profile)", "", status="skipped")
            else:
                with open(guardian_profile_path, encoding="utf-8") as f:
                    current_profile = json.load(f)
                with open(quality_profile_path, encoding="utf-8") as f:
                    quality_profile = json.load(f)

                old_mode = str(current_profile.get("mode", "") or "")
                if old_mode == "quality_repair":
                    _audit_log(action, trigger, precheck, "SKIPPED (already quality_repair)", "", status="skipped")
                else:
                    merged_profile = dict(current_profile)
                    for k, v in quality_profile.items():
                        if str(k).startswith("_"):
                            continue
                        merged_profile[k] = v
                    with open(guardian_profile_path, "w", encoding="utf-8") as f:
                        json.dump(merged_profile, f, indent=2, ensure_ascii=False)

                    restarted = False
                    pid_path = os.path.join(work_dir, ".worker_simple.pid")
                    if os.path.exists(pid_path):
                        try:
                            with open(pid_path, encoding="utf-8") as f:
                                pid = int(str(f.read()).strip() or "0")
                            if pid > 0 and os.path.exists(f"/proc/{pid}"):
                                os.kill(pid, 15)
                                restarted = True
                        except Exception:
                            restarted = False

                    result = (
                        f"guardian_profile mode: {old_mode or '-'} -> quality_repair, "
                        f"worker_restart={'sent_sigterm' if restarted else 'no_pid_or_not_running'}"
                    )
                    postcheck = "guardian_profile zapisany, guardian zastosuje profil quality_repair"
                    _audit_log(action, trigger, precheck, result, postcheck)
                    executed.append(f"🛠️ {action}: {result}")
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
quality_watch = report.get("quality_watch", {}) if isinstance(report.get("quality_watch", {}), dict) else {}
quality_watch_severity = str(quality_watch.get("severity", "ok") or "ok").lower()
quality_watch_total = int(quality_watch.get("suspicious_high_total", 0) or 0)
quality_watch_rate_pct = float(quality_watch.get("suspicious_high_rate_pct", 0) or 0.0)
quality_watch_window_h = float(quality_watch.get("window_hours", 0) or 0.0)
metrics_drift = report.get("metrics_drift", {}) if isinstance(report.get("metrics_drift", {}), dict) else {}
metrics_drift_severity = str(metrics_drift.get("severity", "info") or "info").lower()
metrics_drift_outside = int(metrics_drift.get("outside_worker_registry_keys", 0) or 0)
metrics_drift_pct = float(metrics_drift.get("outside_worker_registry_pct", 0) or 0.0)
metrics_drift_live = int(metrics_drift.get("live_keys", 0) or 0)
metrics_drift_registry = int(metrics_drift.get("worker_registry_keys", 0) or 0)
priority_gate_watch = report.get("priority_gate_watch", {}) if isinstance(report.get("priority_gate_watch", {}), dict) else {}
priority_gate_detected = bool(priority_gate_watch.get("detected", False))
priority_gate_severity = str(priority_gate_watch.get("severity", "ok") or "ok").lower()
priority_gate_pending = [str(x) for x in (priority_gate_watch.get("pending_langs", []) if isinstance(priority_gate_watch.get("pending_langs", []), list) else [])]
priority_gate_active_minutes = float(priority_gate_watch.get("active_minutes", 0) or 0.0)
priority_gate_cycle_delta = int(priority_gate_watch.get("cycle_delta", 0) or 0)
priority_gate_best_drop = float(priority_gate_watch.get("best_quality_drop_pct", 0) or 0.0)
priority_gate_reason = str(priority_gate_watch.get("reason", "") or "")
quality_watch_top_lang = ""
try:
    top_langs = quality_watch.get("top_langs", [])
    if isinstance(top_langs, list) and top_langs:
        quality_watch_top_lang = str(top_langs[0].get("lang", "") or "")
except Exception:
    quality_watch_top_lang = ""

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
if priority_gate_detected:
    pending_label = ",".join(priority_gate_pending) if priority_gate_pending else "-"
    pg_signal_severity = "CRITICAL" if priority_gate_severity == "critical" else "WARNING"
    signals.append((
        pg_signal_severity,
        "priority_gate_stuck",
        f"priority_gate stuck pending=[{pending_label}] active={priority_gate_active_minutes:.1f}m cycles={priority_gate_cycle_delta} drop={priority_gate_best_drop:.3f}% reason={priority_gate_reason}",
    ))
if quality_watch_severity == "critical":
    signals.append((
        "CRITICAL",
        "suspicious_high_spike",
        f"suspicious_high spike count={quality_watch_total} rate={quality_watch_rate_pct:.2f}% in {quality_watch_window_h:.1f}h",
    ))
elif quality_watch_severity == "warning":
    signals.append((
        "WARNING",
        "suspicious_high_elevated",
        f"suspicious_high elevated count={quality_watch_total} rate={quality_watch_rate_pct:.2f}% in {quality_watch_window_h:.1f}h",
    ))

# ── Signal: metric drift LIVE vs registry ──────────────────────────────
doctor_warnings = [str(x) for x in doctor.get("warnings", [])]
drift_warnings = [w for w in doctor_warnings if "METRICS_DRIFT" in w]
drift_issues = [i for i in doctor_issues if "METRICS_DRIFT" in i]
if metrics_drift_severity == "critical":
    signals.append((
        "CRITICAL",
        "metrics_drift_high",
        f"metric drift LIVE vs registry: outside={metrics_drift_outside} ({metrics_drift_pct:.2f}%) "
        f"live={metrics_drift_live} registry={metrics_drift_registry}",
    ))
elif metrics_drift_severity == "warning":
    signals.append((
        "WARNING",
        "metrics_drift_elevated",
        f"metric drift LIVE vs registry: outside={metrics_drift_outside} ({metrics_drift_pct:.2f}%) "
        f"live={metrics_drift_live} registry={metrics_drift_registry}",
    ))
elif drift_issues:
    signals.append((
        "CRITICAL",
        "metrics_drift_high",
        f"metric drift LIVE vs registry: {drift_issues[0]}",
    ))
elif drift_warnings:
    signals.append((
        "WARNING",
        "metrics_drift_elevated",
        f"metric drift LIVE vs registry: {drift_warnings[0]}",
    ))

# ── Signal: repair tuning no samples ──────────────────────────────────
tuning_warnings = [w for w in doctor_warnings if "REPAIR_TUNING_NO_SAMPLES" in w]
if tuning_warnings:
    signals.append((
        "WARNING",
        "repair_tuning_no_samples",
        f"{tuning_warnings[0]}",
    ))

if not signals:
    print("NO_ALERT_CONDITION")
    raise SystemExit(0)

severity_rank = {"CRITICAL": 3, "WARNING": 2, "INFO": 1}
reason_rank = {
    "guardian_stuck": 8,
    "doctor_critical": 7,
    "metrics_drift_high": 6,
    "priority_gate_stuck": 6,
    "suspicious_high_spike": 5,
    "repair_queue_stagnation": 4,
    "metrics_drift_elevated": 3,
    "suspicious_high_elevated": 3,
    "repair_tuning_no_samples": 2,
    "no_progress": 1,
}
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
    "quality_watch": {
        "severity": quality_watch_severity,
        "window_hours": round(quality_watch_window_h, 3),
        "suspicious_high_total": quality_watch_total,
        "suspicious_high_rate_pct": round(quality_watch_rate_pct, 3),
        "top_lang": quality_watch_top_lang,
    },
    "metrics_drift": {
        "severity": metrics_drift_severity,
        "outside_worker_registry_keys": metrics_drift_outside,
        "outside_worker_registry_pct": round(metrics_drift_pct, 3),
        "live_keys": metrics_drift_live,
        "worker_registry_keys": metrics_drift_registry,
    },
    "priority_gate_watch": {
        "detected": bool(priority_gate_detected),
        "severity": priority_gate_severity,
        "reason": priority_gate_reason,
        "pending_langs": priority_gate_pending,
        "active_minutes": round(priority_gate_active_minutes, 3),
        "cycle_delta": int(priority_gate_cycle_delta),
        "best_quality_drop_pct": round(priority_gate_best_drop, 3),
    },
    "content": (
        f"[i18n-statusd][{severity}] {reason_text} | "
        f"doctor={doctor_overall} guardian={guardian_state} hb_age={worker.get('heartbeat_age_s', -1)}s "
        f"repair_stagnation={'yes' if repair_stagnation_detected else 'no'} "
        f"suspicious_high={quality_watch_total} metrics_drift={metrics_drift_outside} "
        f"priority_gate_stuck={'yes' if priority_gate_detected else 'no'}"
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
    python3 - "$STATUS_DIR" "$STATUSD_DAILY_REPORT_JSON" "$STATUSD_DAILY_REPORT_MD" "$REPAIR_QUEUE_STAGNATION_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" "$METRICS_DRIFT_WARN_KEYS" "$METRICS_DRIFT_CRIT_KEYS" "$METRICS_DRIFT_WARN_PCT" "$METRICS_DRIFT_CRIT_PCT" "$STATUSD_THRESHOLDS_FILE" "$STATUSD_USE_ENV_OVERRIDES" "$PRIORITY_GATE_STUCK_MAX_ACTIVE_MINUTES" "$PRIORITY_GATE_STUCK_MAX_CYCLES" "$PRIORITY_GATE_STUCK_MIN_QUALITY_DROP_PCT" "$REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS" "$REGISTRY_RECONCILE_MIN_OUTSIDE_PCT" "$REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS" "$REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT" <<'PYDAILY'
import json, sys, os, re
from collections import defaultdict, Counter
from datetime import datetime, timezone, timedelta

status_dir = sys.argv[1]
report_json_path = sys.argv[2]
report_md_path = sys.argv[3]
repair_window_h = float(sys.argv[4] or "6")
repair_min_samples = int(float(sys.argv[5] or "6"))
repair_min_drop = int(float(sys.argv[6] or "1"))
metrics_drift_warn_keys = int(float(sys.argv[7] or "50000"))
metrics_drift_crit_keys = int(float(sys.argv[8] or "100000"))
metrics_drift_warn_pct = float(sys.argv[9] or "95")
metrics_drift_crit_pct = float(sys.argv[10] or "99")
thresholds_file = str(sys.argv[11]) if len(sys.argv) > 11 else ""
thresholds_env_override = bool(str(sys.argv[12]).strip() == "1") if len(sys.argv) > 12 else False
priority_gate_max_active_min = float(sys.argv[13] if len(sys.argv) > 13 and sys.argv[13] else "180")
priority_gate_max_cycles = int(float(sys.argv[14] if len(sys.argv) > 14 and sys.argv[14] else "240"))
priority_gate_min_quality_drop_pct = float(sys.argv[15] if len(sys.argv) > 15 and sys.argv[15] else "1")
registry_reconcile_min_outside_keys = int(float(sys.argv[16] if len(sys.argv) > 16 and sys.argv[16] else "1000"))
registry_reconcile_min_outside_pct = float(sys.argv[17] if len(sys.argv) > 17 and sys.argv[17] else "2")
registry_reconcile_min_interval_s = int(float(sys.argv[18] if len(sys.argv) > 18 and sys.argv[18] else "1800"))
registry_reconcile_always_sync_any_drift = bool(str(sys.argv[19]).strip().lower() in ("1", "true", "yes", "on")) if len(sys.argv) > 19 else True

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

def _analyze_repair_tuning(now, window_start, status_dir):
    tuning_path = os.path.join(status_dir, "identical_to_en_repair_tuning.jsonl")
    out = {
        "samples_24h": 0,
        "translated_total": 0,
        "guard_fail_total": 0,
        "guard_fail_rate_pct": 0.0,
        "avg_limit": 0.0,
        "avg_suspicious_high_pct": 0.0,
        "gt_mode_true_samples": 0,
        "latest_timestamp": "",
        "top_langs_by_samples": [],
        "tier_distribution": {},
        "top_risky_targets": [],
    }
    if not os.path.exists(tuning_path):
        return out

    rows = []
    latest_ts = None
    with open(tuning_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            ts = _parse_ts(row.get("timestamp"))
            if ts is None or ts < window_start:
                continue
            rows.append(row)
            if latest_ts is None or ts > latest_ts:
                latest_ts = ts

    if not rows:
        return out

    by_lang = Counter()
    by_tier = Counter()
    translated_total = 0
    guard_fail_total = 0
    limit_sum = 0.0
    suspicious_pct_sum = 0.0
    gt_mode_true_samples = 0
    risk_rows = []

    for row in rows:
        lang = str(row.get("lang", "") or "").lower()
        tier = str(row.get("tier", "") or "unknown")
        translated = _safe_int(row.get("translated", 0))
        guard_fail = _safe_int(row.get("guard_fail", 0))
        limit = _safe_float(row.get("limit", 0))
        suspicious_pct = _safe_float(row.get("suspicious_high_pct", 0.0))
        suspicious_count = _safe_int(row.get("suspicious_high_count", 0))
        json_file = str(row.get("json_file", "") or "")
        gt_mode = str(row.get("gt_mode", "") or "").strip().lower()

        translated_total += translated
        guard_fail_total += guard_fail
        limit_sum += limit
        suspicious_pct_sum += suspicious_pct
        if gt_mode in ("1", "true", "yes", "on"):
            gt_mode_true_samples += 1
        if lang:
            by_lang[lang] += 1
        by_tier[tier] += 1
        risk_rows.append({
            "lang": lang,
            "json_file": json_file,
            "suspicious_high_pct": round(suspicious_pct, 3),
            "suspicious_high_count": suspicious_count,
            "translated": translated,
            "guard_fail": guard_fail,
            "tier": tier,
            "limit": int(limit),
        })

    rows_sorted = sorted(
        risk_rows,
        key=lambda r: (r["suspicious_high_pct"], r["suspicious_high_count"], r["translated"]),
        reverse=True,
    )[:6]

    out.update({
        "samples_24h": len(rows),
        "translated_total": int(translated_total),
        "guard_fail_total": int(guard_fail_total),
        "guard_fail_rate_pct": round((guard_fail_total / max(translated_total + guard_fail_total, 1)) * 100.0, 3),
        "avg_limit": round(limit_sum / max(len(rows), 1), 2),
        "avg_suspicious_high_pct": round(suspicious_pct_sum / max(len(rows), 1), 3),
        "gt_mode_true_samples": int(gt_mode_true_samples),
        "latest_timestamp": latest_ts.isoformat().replace("+00:00", "Z") if latest_ts is not None else "",
        "top_langs_by_samples": [{"lang": k, "samples": int(v)} for k, v in by_lang.most_common(8)],
        "tier_distribution": {str(k): int(v) for k, v in by_tier.items()},
        "top_risky_targets": rows_sorted,
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
pending_skip_source = "worker_cycle_perf.detail"
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

# Prefer dedykowany artefakt 24h (dokładniejsze źródło), fallback: worker_cycle_perf.detail
pending_skip_24h_path = os.path.join(status_dir, "pending_skip_24h_latest.json")
if os.path.exists(pending_skip_24h_path):
    try:
        with open(pending_skip_24h_path, encoding="utf-8") as f:
            ps = json.load(f)
        pending_skip_count = _safe_int(ps.get("pending_skip_count", pending_skip_count))
        cycle_total_entries = _safe_int(ps.get("total_cycles_24h", cycle_total_entries))
        pending_skip_share_pct = _safe_float(ps.get("pending_skip_share_pct", pending_skip_share_pct))
        pending_skip_source = "pending_skip_24h_latest.json"
    except Exception:
        pass

quality_report_file = os.path.join(status_dir, "quality_report.jsonl")
quality_entries = 0
quality_suspicious = 0
quality_suspicious_high = 0
quality_identical_to_en = 0
quality_gt_guard_fails = 0
quality_translated_total = 0
quality_suspicious_high_by_lang = Counter()
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
            quality_translated_total += _safe_int(row.get("translated", 0))
            lang = str(row.get("language", "") or "").lower()
            q = row.get("quality", {}) or {}
            quality_suspicious += _safe_int(q.get("suspicious_count", 0))
            sh = _safe_int(q.get("suspicious_high", 0))
            quality_suspicious_high += sh
            quality_identical_to_en += _safe_int(q.get("identical_to_en", 0))
            quality_gt_guard_fails += _safe_int(q.get("gt_guard_fails", 0))
            if lang and sh > 0:
                quality_suspicious_high_by_lang[lang] += sh

quality_suspicious_high_rate_pct = (quality_suspicious_high / max(quality_translated_total, 1)) * 100.0
quality_suspicious_high_top_lang = ""
quality_suspicious_high_top_lang_count = 0
if quality_suspicious_high_by_lang:
    quality_suspicious_high_top_lang, quality_suspicious_high_top_lang_count = quality_suspicious_high_by_lang.most_common(1)[0]

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
statusd_latest_report = {}
statusd_latest_report_path = os.path.join(status_dir, "statusd_report.json")
if os.path.exists(statusd_latest_report_path):
    try:
        with open(statusd_latest_report_path, encoding="utf-8") as f:
            statusd_latest_report = json.load(f)
    except Exception:
        statusd_latest_report = {}
md_cfg = statusd_latest_report.get("metrics_drift", {}) if isinstance(statusd_latest_report.get("metrics_drift", {}), dict) else {}
if md_cfg:
    metrics_drift_warn_keys = _safe_int(md_cfg.get("warn_threshold_keys", metrics_drift_warn_keys), metrics_drift_warn_keys)
    metrics_drift_crit_keys = _safe_int(md_cfg.get("critical_threshold_keys", metrics_drift_crit_keys), metrics_drift_crit_keys)
    metrics_drift_warn_pct = _safe_float(md_cfg.get("warn_threshold_pct", metrics_drift_warn_pct), metrics_drift_warn_pct)
    metrics_drift_crit_pct = _safe_float(md_cfg.get("critical_threshold_pct", metrics_drift_crit_pct), metrics_drift_crit_pct)
priority_gate_watch = statusd_latest_report.get("priority_gate_watch", {}) if isinstance(statusd_latest_report.get("priority_gate_watch", {}), dict) else {}
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
        "server_keys": _safe_int(row.get("server_keys", 0)),
        "server_translated": _safe_int(row.get("server_translated", 0)),
        "server_pct": _safe_float(row.get("server_pct", 0)),
        "client_keys": _safe_int(row.get("client_keys", 0)),
        "client_translated": _safe_int(row.get("client_translated", 0)),
        "client_pct": _safe_float(row.get("client_pct", 0)),
    }

migration_snapshot = overview.get("migration", {})
if not isinstance(migration_snapshot, dict):
    migration_snapshot = {}
md_live = _safe_int(migration_snapshot.get("total_keys_extracted_live", migration_snapshot.get("total_keys_extracted", 0)))
md_registry = _safe_int(
    migration_snapshot.get("total_keys_extracted_worker_registry", migration_snapshot.get("keys_extracted", 0))
)
md_outside = _safe_int(
    migration_snapshot.get("keys_extracted_outside_worker_registry", max(0, md_live - md_registry))
)
md_outside = max(0, md_outside)
md_pct = round((md_outside / max(md_live, 1)) * 100.0, 3) if md_live > 0 else 0.0
if md_outside >= metrics_drift_crit_keys or md_pct >= metrics_drift_crit_pct:
    md_severity = "critical"
    md_status = "high"
elif md_outside >= metrics_drift_warn_keys or md_pct >= metrics_drift_warn_pct:
    md_severity = "warning"
    md_status = "elevated"
else:
    md_severity = "ok"
    md_status = "stable"
metrics_drift_snapshot = {
    "available": bool(migration_snapshot),
    "severity": md_severity,
    "status": md_status,
    "live_keys": int(md_live),
    "worker_registry_keys": int(md_registry),
    "outside_worker_registry_keys": int(md_outside),
    "outside_worker_registry_pct": float(md_pct),
    "warn_threshold_keys": int(metrics_drift_warn_keys),
    "critical_threshold_keys": int(metrics_drift_crit_keys),
    "warn_threshold_pct": float(metrics_drift_warn_pct),
    "critical_threshold_pct": float(metrics_drift_crit_pct),
}

repair_queue_24h = _analyze_repair_queue(
    now=now,
    window_start=window_start,
    status_dir=status_dir,
    stagnation_window_h=repair_window_h,
    stagnation_min_samples=repair_min_samples,
    stagnation_min_drop=repair_min_drop,
)
repair_tuning_24h = _analyze_repair_tuning(
    now=now,
    window_start=window_start,
    status_dir=status_dir,
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
        "pending_skip_source": pending_skip_source,
        "throughput_keys_per_h_window": round(throughput_keys_per_h_window, 1),
        "throughput_keys_per_h_active": round(throughput_keys_per_h_active, 1),
        "guard_entries": guard_entries,
    },
    "quality_24h": {
        "quality_entries": quality_entries,
        "suspicious_count": quality_suspicious,
        "suspicious_high_count": quality_suspicious_high,
        "suspicious_high_rate_pct": round(quality_suspicious_high_rate_pct, 3),
        "suspicious_high_top_lang": quality_suspicious_high_top_lang,
        "suspicious_high_top_lang_count": int(quality_suspicious_high_top_lang_count),
        "identical_to_en_count": quality_identical_to_en,
        "gt_guard_fails_count": quality_gt_guard_fails,
        "latest_audit_timestamp": quality_audit_latest.get("timestamp", ""),
        "latest_audit_issues_found": _safe_int(quality_audit_latest.get("issues_found", 0)),
        "latest_audit_issues_by_type": quality_audit_latest.get("issues_by_type", {}),
    },
    "coverage_snapshot": {
        lang: coverage_map.get(lang, {})
        for lang in ("pl", "es", "de", "pt", "fr", "ru")
    },
    "migration": migration_snapshot,
    "metrics_drift": metrics_drift_snapshot,
    "priority_gate_watch": priority_gate_watch,
    "thresholds_snapshot": {
        "source_of_truth": "statusd_thresholds_file",
        "config_file": thresholds_file,
        "env_overrides_enabled": bool(thresholds_env_override),
        "repair_queue_stagnation": {
            "window_hours": float(max(repair_window_h, 0.1)),
            "min_samples": int(max(repair_min_samples, 1)),
            "min_drop": int(max(repair_min_drop, 0)),
        },
        "metrics_drift": {
            "warn_keys": int(metrics_drift_warn_keys),
            "crit_keys": int(metrics_drift_crit_keys),
            "warn_pct": float(metrics_drift_warn_pct),
            "crit_pct": float(metrics_drift_crit_pct),
        },
        "priority_gate_stuck": {
            "max_active_minutes": float(priority_gate_max_active_min),
            "max_cycles": int(priority_gate_max_cycles),
            "min_quality_drop_pct": float(priority_gate_min_quality_drop_pct),
        },
        "registry_reconcile": {
            "min_outside_keys": int(registry_reconcile_min_outside_keys),
            "min_outside_pct": float(registry_reconcile_min_outside_pct),
            "min_interval_seconds": int(registry_reconcile_min_interval_s),
            "always_sync_any_drift": bool(registry_reconcile_always_sync_any_drift),
        },
    },
    "scope_totals": overview.get("scope_totals", {}),
    "trend_per_language": lang_stats_final,
    "trend_per_category": category_stats_final,
    "top": {
        "languages_by_translated": [{"lang": k, **v} for k, v in top_langs],
        "categories_by_translated": [{"category": k, **v} for k, v in top_categories],
    },
    "strict_hourly_snapshot": strict_hourly,
    "repair_queue_24h": repair_queue_24h,
    "repair_tuning_24h": repair_tuning_24h,
    "notes": [
        "pending_skip_share preferuje pending_skip_24h_latest.json; fallback: worker_cycle_perf.detail.",
        "no_progress_rate bazuje na translation_guard_report (translated<=0).",
        "repair_queue_24h bazuje na identical_to_en_repair_queue_report.jsonl.",
        "repair_tuning_24h bazuje na identical_to_en_repair_tuning.jsonl.",
        "metrics_drift rozdziela registry raw i registry effective po registry_reconcile.",
        "priority_gate_watch śledzi aktywność fali ES/PL i wykrywa stuck bez spadku quality rate.",
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
lines.append(f"| pending_skip_source | {report['kpi_24h'].get('pending_skip_source', '-') or '-'} |")
lines.append(f"| throughput_keys_per_h_window | {report['kpi_24h']['throughput_keys_per_h_window']} |")
lines.append(f"| throughput_keys_per_h_active | {report['kpi_24h']['throughput_keys_per_h_active']} |")
lines.append("")
lines.append("## Quality 24h")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
lines.append(f"| suspicious_count | {report['quality_24h']['suspicious_count']} |")
lines.append(f"| suspicious_high_count | {report['quality_24h'].get('suspicious_high_count', 0)} |")
lines.append(f"| suspicious_high_rate | {_fmt_pct(report['quality_24h'].get('suspicious_high_rate_pct', 0))} |")
lines.append(
    f"| suspicious_high_top_lang | "
    f"{(report['quality_24h'].get('suspicious_high_top_lang', '') or '-')}:{report['quality_24h'].get('suspicious_high_top_lang_count', 0)} |"
)
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
lines.append("## Repair Tuning 24h")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
rt = report.get("repair_tuning_24h", {}) or {}
lines.append(f"| samples_24h | {rt.get('samples_24h', 0)} |")
lines.append(f"| avg_limit | {rt.get('avg_limit', 0)} |")
lines.append(f"| avg_suspicious_high_pct | {_fmt_pct(rt.get('avg_suspicious_high_pct', 0))} |")
lines.append(f"| translated_total | {rt.get('translated_total', 0)} |")
lines.append(f"| guard_fail_total | {rt.get('guard_fail_total', 0)} |")
lines.append(f"| guard_fail_rate_pct | {_fmt_pct(rt.get('guard_fail_rate_pct', 0))} |")
lines.append(f"| gt_mode_true_samples | {rt.get('gt_mode_true_samples', 0)} |")
lines.append(f"| latest_timestamp | {rt.get('latest_timestamp', '') or '-'} |")
top_risky = rt.get("top_risky_targets", [])
if isinstance(top_risky, list) and top_risky:
    lines.append("")
    lines.append("| Risky Target | Suspicious High % | Suspicious High Count | Tier | Limit |")
    lines.append("|---|---:|---:|---|---:|")
    for row in top_risky[:5]:
        target = f"{row.get('lang','?')}:{row.get('json_file','?')}"
        lines.append(
            f"| {target} | {_fmt_pct(row.get('suspicious_high_pct', 0))} | {row.get('suspicious_high_count', 0)} | "
            f"{row.get('tier', '')} | {row.get('limit', 0)} |"
        )
lines.append("")
lines.append("## Metrics Drift (LIVE vs Registry)")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
md = report.get("metrics_drift", {}) or {}
lines.append(f"| status | {md.get('status', '-')} |")
lines.append(f"| severity | {md.get('severity', '-')} |")
lines.append(f"| live_keys | {md.get('live_keys', 0)} |")
lines.append(f"| worker_registry_keys | {md.get('worker_registry_keys', 0)} |")
lines.append(f"| worker_registry_keys_raw | {md.get('worker_registry_keys_raw', 0)} |")
lines.append(f"| registry_reconcile_adjustment | {md.get('registry_reconcile_adjustment', 0)} |")
lines.append(f"| outside_worker_registry_keys | {md.get('outside_worker_registry_keys', 0)} |")
lines.append(f"| outside_worker_registry_pct | {_fmt_pct(md.get('outside_worker_registry_pct', 0))} |")
lines.append(f"| outside_worker_registry_keys_raw | {md.get('outside_worker_registry_keys_raw', 0)} |")
lines.append(f"| outside_worker_registry_pct_raw | {_fmt_pct(md.get('outside_worker_registry_pct_raw', 0))} |")
lines.append(f"| warn_threshold_keys | {md.get('warn_threshold_keys', 0)} |")
lines.append(f"| critical_threshold_keys | {md.get('critical_threshold_keys', 0)} |")
lines.append(f"| warn_threshold_pct | {_fmt_pct(md.get('warn_threshold_pct', 0))} |")
lines.append(f"| critical_threshold_pct | {_fmt_pct(md.get('critical_threshold_pct', 0))} |")
th = report.get("thresholds_snapshot", {}) if isinstance(report.get("thresholds_snapshot", {}), dict) else {}
lines.append(f"| threshold_source | {th.get('source_of_truth', '-') or '-'} |")
lines.append(f"| threshold_config_file | {th.get('config_file', '-') or '-'} |")
lines.append(f"| env_overrides_enabled | {'yes' if bool(th.get('env_overrides_enabled', False)) else 'no'} |")
lines.append("")
lines.append("## Priority Gate Watch")
lines.append("")
lines.append("| Metric | Value |")
lines.append("|---|---:|")
pg = report.get("priority_gate_watch", {}) or {}
lines.append(f"| enabled | {'yes' if bool(pg.get('enabled', False)) else 'no'} |")
lines.append(f"| active | {'yes' if bool(pg.get('active', False)) else 'no'} |")
lines.append(f"| detected | {'yes' if bool(pg.get('detected', False)) else 'no'} |")
lines.append(f"| severity | {pg.get('severity', '-')} |")
lines.append(f"| reason | {pg.get('reason', '-')} |")
lines.append(f"| pending_langs | {','.join(pg.get('pending_langs', [])) if isinstance(pg.get('pending_langs', []), list) else '-'} |")
lines.append(f"| active_minutes | {pg.get('active_minutes', 0)} |")
lines.append(f"| cycle_delta | {pg.get('cycle_delta', 0)} |")
lines.append(f"| best_quality_drop_pct | {_fmt_pct(pg.get('best_quality_drop_pct', 0))} |")
lines.append("")
lines.append("## Coverage Snapshot")
lines.append("")
lines.append("| Lang | Completion | Missing Keys | EN Copy Keys | Serwer | Instalka |")
lines.append("|---|---:|---:|---:|---:|---:|")
for lang in ("pl", "es", "de", "pt", "fr", "ru"):
    row = report["coverage_snapshot"].get(lang, {}) or {}
    s_pct = row.get("server_pct", 0)
    c_pct = row.get("client_pct", 0)
    s_str = f"{s_pct:.1f}%" if s_pct else "-"
    c_str = f"{c_pct:.1f}%" if c_pct else "-"
    lines.append(
        f"| {lang.upper()} | {row.get('completion_pct', 0):.2f}% | {row.get('missing_keys', 0)} | {row.get('english_copy_keys', 0)} | {s_str} | {c_str} |"
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

# Migration section
mig = report.get("migration", {})
if mig:
    lines.append("")
    lines.append("## Migration (tworzenie kluczy EN)")
    lines.append("")
    lines.append("| Metric | Value |")
    lines.append("|---|---:|")
    lines.append(f"| files_total | {mig.get('files_total', '?')} |")
    lines.append(f"| files_completed | {mig.get('files_completed', '?')} |")
    lines.append(f"| files_migrated | {mig.get('files_migrated', '?')} |")
    if "scanned_files_live" in mig:
        lines.append(f"| scanned_files_live | {mig.get('scanned_files_live', '?')} |")
    if "scanned_files_history" in mig:
        lines.append(f"| scanned_files_history | {mig.get('scanned_files_history', '?')} |")
    if "scanned_files_history_minus_live" in mig:
        lines.append(f"| scanned_files_history_minus_live | {mig.get('scanned_files_history_minus_live', '?')} |")
    lines.append(f"| total_keys_extracted | {mig.get('total_keys_extracted', '?')} |")
    if "total_keys_extracted_live" in mig:
        lines.append(f"| total_keys_extracted_live | {mig.get('total_keys_extracted_live', '?')} |")
    if "total_keys_extracted_worker_registry" in mig:
        lines.append(f"| total_keys_extracted_worker_registry | {mig.get('total_keys_extracted_worker_registry', '?')} |")
    if "keys_extracted_outside_worker_registry" in mig:
        lines.append(f"| keys_extracted_outside_worker_registry | {mig.get('keys_extracted_outside_worker_registry', '?')} |")
    npc_total = mig.get("npc_total", 0)
    npc_migrated = mig.get("npc_migrated", 0)
    npc_needs = mig.get("npc_needs_migration", 0)
    if npc_total:
        lines.append(f"| npc_total | {npc_total} |")
        lines.append(f"| npc_migrated | {npc_migrated} |")
        lines.append(f"| npc_needs_migration | {npc_needs} |")

# Scope totals section
st = report.get("scope_totals", {})
if st:
    lines.append("")
    lines.append("## Scope (Serwer vs Instalka)")
    lines.append("")
    lines.append(f"- Serwer EN keys: **{st.get('server_keys', '?')}**")
    lines.append(f"- Instalka EN keys: **{st.get('client_keys', '?')}**")

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
# MODUŁ 7a: Auto-refresh I18N_STATUS.md (niezależnie od pętli workera)
# ═══════════════════════════════════════════════════════════════════════════════

run_status_md_refresh() {
    local reason="${1:-periodic}"
    local timeout_s="${STATUS_MD_REFRESH_TIMEOUT_SECONDS:-180}"
    [[ "$timeout_s" =~ ^[0-9]+$ ]] || timeout_s=180
    (( timeout_s < 30 )) && timeout_s=30

    local result rc now_ts
    result=$(python3 - "$WORK_DIR" "$timeout_s" <<'PYSTATUSREFRESH'
import os, subprocess, sys, time

work_dir = sys.argv[1]
timeout_s = int(float(sys.argv[2] or "180"))
cmd = ["bash", os.path.join(work_dir, "i18n_worker_simple.sh"), "--update-status"]
started = time.time()

try:
    proc = subprocess.run(
        cmd,
        cwd=work_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=max(timeout_s, 30),
    )
    elapsed = time.time() - started
    lines = [ln.strip() for ln in (proc.stdout or "").splitlines() if ln.strip()]
    tail = " | ".join(lines[-4:])
    tail = tail[:360]
    if proc.returncode == 0:
        print(f"OK elapsed_s={elapsed:.1f} rc=0 tail={tail}")
    else:
        print(f"ERROR elapsed_s={elapsed:.1f} rc={proc.returncode} tail={tail}")
        raise SystemExit(proc.returncode)
except subprocess.TimeoutExpired as e:
    elapsed = time.time() - started
    out = e.stdout if isinstance(e.stdout, str) else ""
    lines = [ln.strip() for ln in out.splitlines() if ln.strip()]
    tail = " | ".join(lines[-4:])[:360]
    print(f"TIMEOUT elapsed_s={elapsed:.1f} timeout_s={timeout_s} tail={tail}")
    raise SystemExit(124)
except Exception as e:
    print(f"ERROR exception={e}")
    raise SystemExit(1)
PYSTATUSREFRESH
)
    rc=$?

    if [ "$rc" -eq 0 ]; then
        now_ts=$(date +%s)
        echo "$now_ts" > "$STATUS_MD_REFRESH_LAST_TS_FILE"
        log_statusd "📝 Status MD refresh OK (reason=$reason): $result"
    else
        log_statusd "⚠️ Status MD refresh FAIL (reason=$reason, rc=$rc): $result"
    fi
    return "$rc"
}

maybe_refresh_status_md() {
    statusd_bool "$STATUS_MD_REFRESH_ENABLED" || return 0

    local stale_s min_interval_s now_ts md_mtime md_age last_ts elapsed
    stale_s="${STATUS_MD_REFRESH_STALE_SECONDS:-240}"
    min_interval_s="${STATUS_MD_REFRESH_MIN_INTERVAL_SECONDS:-300}"
    [[ "$stale_s" =~ ^[0-9]+$ ]] || stale_s=240
    [[ "$min_interval_s" =~ ^[0-9]+$ ]] || min_interval_s=300
    (( stale_s < 60 )) && stale_s=60
    (( min_interval_s < 30 )) && min_interval_s=30

    local reconcile_result="${1:-}"
    local reason=""
    local force_refresh=0
    local md_path="$WORK_DIR/I18N_STATUS.md"
    now_ts=$(date +%s)

    if [ ! -f "$md_path" ]; then
        reason="missing_status_md"
        force_refresh=1
    else
        md_mtime=$(stat -c %Y "$md_path" 2>/dev/null || echo 0)
        md_age=$((now_ts - md_mtime))
        if [ "$md_age" -ge "$stale_s" ]; then
            reason="status_md_stale_${md_age}s"
        fi
    fi

    if statusd_bool "$STATUS_MD_REFRESH_FORCE_ON_RECONCILE" && printf '%s' "$reconcile_result" | grep -q "RECONCILE_APPLIED"; then
        if [ -n "$reason" ]; then
            reason="${reason}+reconcile_applied"
        else
            reason="reconcile_applied"
        fi
        force_refresh=1
    fi

    [ -n "$reason" ] || return 0

    last_ts=0
    if [ -f "$STATUS_MD_REFRESH_LAST_TS_FILE" ]; then
        last_ts=$(cat "$STATUS_MD_REFRESH_LAST_TS_FILE" 2>/dev/null || echo 0)
    fi
    [[ "$last_ts" =~ ^[0-9]+$ ]] || last_ts=0
    elapsed=$((now_ts - last_ts))
    if [ "$force_refresh" -ne 1 ] && [ "$elapsed" -lt "$min_interval_s" ]; then
        log_statusd "⏭️ Status MD refresh skip (reason=$reason, cooldown=${elapsed}s<${min_interval_s}s)"
        return 0
    fi

    run_status_md_refresh "$reason" || true
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 7b: Stagnation alert — repair queue backlog monitoring
# ═══════════════════════════════════════════════════════════════════════════════
#
# Legacy artefakty stagnacji (`repair_stagnation_alert.json` + trend JSONL).
# Źródło decyzji o stagnacji: `statusd_report.json -> repair_queue.stagnation`
# (wspólna logika z doctor/webhook/daily report).
#

STAGNATION_WINDOW_HOURS="${STATUSD_STAGNATION_WINDOW_HOURS:-$REPAIR_QUEUE_STAGNATION_HOURS}"
STAGNATION_CHECK_INTERVAL="${STATUSD_STAGNATION_CHECK_INTERVAL:-1800}"
STAGNATION_ALERT_FILE="$STATUS_DIR/repair_stagnation_alert.json"
BACKLOG_TREND_FILE="$STATUS_DIR/repair_backlog_trend.jsonl"

run_repair_stagnation_check() {
    python3 - "$STATUS_DIR" "$STATUSD_REPORT_FILE" "$STAGNATION_WINDOW_HOURS" "$REPAIR_QUEUE_STAGNATION_MIN_SAMPLES" "$REPAIR_QUEUE_STAGNATION_MIN_DROP" "$STAGNATION_ALERT_FILE" "$BACKLOG_TREND_FILE" <<'PYSTAGNATION'
import sys, json, os
from datetime import datetime, timezone, timedelta

status_dir = sys.argv[1]
statusd_report_path = sys.argv[2]
window_hours = float(sys.argv[3] or "6")
min_samples = int(float(sys.argv[4] or "6"))
min_drop_required = int(float(sys.argv[5] or "1"))
alert_file = sys.argv[6]
trend_file = sys.argv[7]

report_jsonl = os.path.join(status_dir, "identical_to_en_repair_queue_report.jsonl")

def _read_json(path, default=None):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default if default is not None else {}

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

def _parse_ts(s):
    try:
        return datetime.fromisoformat(str(s).replace("Z", "+00:00"))
    except Exception:
        return None

now = datetime.now(timezone.utc)
now_z = now.isoformat().replace("+00:00", "Z")
statusd_report = _read_json(statusd_report_path, {})
rq = statusd_report.get("repair_queue", {}) if isinstance(statusd_report.get("repair_queue", {}), dict) else {}
st = rq.get("stagnation", {}) if isinstance(rq.get("stagnation", {}), dict) else {}

top_target = rq.get("top_target", {}) if isinstance(rq.get("top_target", {}), dict) else {}
top_key = str(top_target.get("key", "") or "")
top_count = _safe_int(top_target.get("identical_to_en", 0))
entries_by_lang = rq.get("entries_by_lang", {}) if isinstance(rq.get("entries_by_lang", {}), dict) else {}
new_total = sum(_safe_int(v) for v in entries_by_lang.values()) if entries_by_lang else _safe_int(rq.get("entries_total", 0))

# Trend per-lang i total liczymy z queue_report JSONL, ale status stagnacji
# bierzemy z jednego źródła prawdy: statusd_report.repair_queue.stagnation.
samples = []
if os.path.exists(report_jsonl):
    with open(report_jsonl, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except Exception:
                continue
            ts = _parse_ts(rec.get("timestamp", ""))
            if ts is None:
                continue
            by_lang = rec.get("entries_by_lang", {})
            if not isinstance(by_lang, dict):
                by_lang = {}
            total = sum(_safe_int(v) for v in by_lang.values())
            samples.append({"ts": ts, "total": total, "by_lang": by_lang})

samples.sort(key=lambda x: x["ts"])
old_total = 0
hours_elapsed = _safe_float(st.get("span_hours", 0.0))
per_lang_trend = {}
old_ts = ""
new_ts = now_z

if samples:
    newest = samples[-1]
    new_ts = newest["ts"].isoformat().replace("+00:00", "Z")
    cutoff = newest["ts"] - timedelta(hours=max(window_hours, 0.1))
    old_candidates = [e for e in samples if e["ts"] <= cutoff]
    oldest = old_candidates[-1] if old_candidates else samples[0]
    old_ts = oldest["ts"].isoformat().replace("+00:00", "Z")
    old_total = _safe_int(oldest.get("total", 0))
    if new_total <= 0:
        new_total = _safe_int(newest.get("total", 0))
    if hours_elapsed <= 0:
        hours_elapsed = (newest["ts"] - oldest["ts"]).total_seconds() / 3600.0
    langs = set(list(oldest.get("by_lang", {}).keys()) + list(newest.get("by_lang", {}).keys()))
    for lang in sorted(langs):
        old_v = _safe_int(oldest.get("by_lang", {}).get(lang, 0))
        new_v = _safe_int(newest.get("by_lang", {}).get(lang, 0))
        delta = old_v - new_v
        pct = (delta / old_v * 100.0) if old_v > 0 else 0.0
        per_lang_trend[lang] = {
            "old": old_v,
            "new": new_v,
            "delta": delta,
            "decrease_pct": round(pct, 2),
        }
else:
    old_total = _safe_int(st.get("baseline_count", 0))
    if new_total <= 0:
        new_total = _safe_int(st.get("latest_count", 0))

decrease_pct = ((old_total - new_total) / old_total * 100.0) if old_total > 0 else 0.0
detected = bool(st.get("detected", False))
reason = str(st.get("reason", "") or "")
sample_count = _safe_int(st.get("sample_count", 0))

if detected:
    status = "stagnation"
    alert = True
    message = (
        f"Repair queue stagnation ({top_key or 'unknown'}): "
        f"no effective drop in {hours_elapsed:.2f}h "
        f"(baseline={_safe_int(st.get('baseline_count', old_total))}, latest={_safe_int(st.get('latest_count', top_count))})."
    )
elif reason in {"window_too_short", "insufficient_samples", "empty_window", "no_report_samples", "focus_key_missing_in_history"}:
    status = "warming_up"
    alert = False
    message = f"Stagnation window not ready ({reason}), span={hours_elapsed:.2f}h samples={sample_count}"
elif not rq.get("available", False):
    status = "no_data"
    alert = False
    message = "Repair queue artifact unavailable"
else:
    status = "ok"
    alert = False
    message = f"Repair queue healthy ({reason or 'drop_detected'})"

result = {
    "timestamp": now_z,
    "window_hours": window_hours,
    "min_samples": min_samples,
    "min_drop_required": min_drop_required,
    "status": status,
    "alert": alert,
    "message": message,
    "reason": reason,
    "top_key": top_key,
    "top_count": top_count,
    "old_total": old_total,
    "new_total": new_total,
    "decrease_pct": round(decrease_pct, 2),
    "old_ts": old_ts,
    "new_ts": new_ts,
    "hours_elapsed": round(hours_elapsed, 3),
    "sample_count": sample_count,
    "per_lang_trend": per_lang_trend,
}

with open(alert_file, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

trend_entry = {
    "timestamp": now_z,
    "total": new_total,
    "decrease_pct": result["decrease_pct"],
    "hours_elapsed": result["hours_elapsed"],
    "status": status,
    "alert": alert,
    "top_key": top_key,
    "top_count": top_count,
    "reason": reason,
}
for lang, info in per_lang_trend.items():
    trend_entry[f"{lang}_total"] = info["new"]
    trend_entry[f"{lang}_delta"] = info["delta"]

with open(trend_file, "a", encoding="utf-8") as f:
    f.write(json.dumps(trend_entry, ensure_ascii=False) + "\n")

try:
    with open(trend_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    if len(lines) > 500:
        with open(trend_file, "w", encoding="utf-8") as f:
            f.writelines(lines[-500:])
except Exception:
    pass

if alert:
    print(
        f"STAGNATION_ALERT top={top_key or '?'} old_total={old_total} new_total={new_total} "
        f"span_h={result['hours_elapsed']} reason={reason}"
    )
else:
    print(
        f"STAGNATION_{status.upper()} top={top_key or '?'} old_total={old_total} new_total={new_total} "
        f"span_h={result['hours_elapsed']} reason={reason}"
    )
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
# MODUŁ 7c: Registry reconcile (LIVE vs worker registry)
# ═══════════════════════════════════════════════════════════════════════════════

run_registry_reconcile() {
    python3 - "$WORK_DIR" "$STATUS_DIR" "$REGISTRY_RECONCILE_MIN_OUTSIDE_KEYS" "$REGISTRY_RECONCILE_MIN_OUTSIDE_PCT" "$REGISTRY_RECONCILE_MIN_INTERVAL_SECONDS" "$REGISTRY_RECONCILE_ALWAYS_SYNC_ANY_DRIFT" <<'PYRECON'
import json, os, sys
from datetime import datetime, timezone

work_dir = sys.argv[1]
status_dir = sys.argv[2]
min_outside_keys = int(float(sys.argv[3] or "1000"))
min_outside_pct = float(sys.argv[4] or "2")
min_interval_s = int(float(sys.argv[5] or "1800"))
always_sync_any_drift = bool(str(sys.argv[6]).strip().lower() in ("1", "true", "yes", "on")) if len(sys.argv) > 6 else True

now = datetime.now(timezone.utc)
now_z = now.isoformat().replace("+00:00", "Z")
state_path = os.path.join(status_dir, "registry_reconcile_state.json")
latest_path = os.path.join(status_dir, "registry_reconcile_latest.json")
status_file = os.path.join(work_dir, "i18n_file_status.json")
en_dir = os.path.join(work_dir, "i18n", "en")

def _safe_int(v, default=0):
    try:
        return int(v)
    except Exception:
        return int(default)

def _safe_float(v, default=0.0):
    try:
        return float(v)
    except Exception:
        return float(default)

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

def _write_json_atomic(path, payload):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
    os.replace(tmp, path)

out = {
    "timestamp": now_z,
    "status": "ok",
    "action": "skipped",
    "reason": "",
    "thresholds": {
        "min_outside_keys": int(min_outside_keys),
        "min_outside_pct": float(min_outside_pct),
        "min_interval_seconds": int(min_interval_s),
        "always_sync_any_drift": bool(always_sync_any_drift),
    },
    "live_keys": 0,
    "registry_keys_raw": 0,
    "registry_adjustment_before": 0,
    "registry_adjustment_after": 0,
    "registry_keys_effective_before": 0,
    "registry_keys_effective_after": 0,
    "outside_keys_raw": 0,
    "outside_pct_raw": 0.0,
    "outside_keys_effective_before": 0,
    "outside_keys_effective_after": 0,
    "cooldown_ok": True,
    "last_applied_at": "",
}

if not os.path.exists(status_file):
    out["status"] = "error"
    out["action"] = "error"
    out["reason"] = "missing_i18n_file_status"
    _write_json_atomic(latest_path, out)
    print("ERROR missing_i18n_file_status")
    raise SystemExit(1)

status_payload = _read_json(status_file, {})
files = status_payload.get("files", {})
if not isinstance(files, dict):
    files = {}
global_stats = status_payload.get("global_stats", {})
if not isinstance(global_stats, dict):
    global_stats = {}

registry_raw = 0
for info in files.values():
    if not isinstance(info, dict):
        continue
    stages = info.get("stages", {}) if isinstance(info.get("stages", {}), dict) else {}
    registry_raw += _safe_int((stages.get("5_extraction_en", {}) if isinstance(stages.get("5_extraction_en", {}), dict) else {}).get("keys_added", 0))

live_keys = 0
if os.path.isdir(en_dir):
    for name in os.listdir(en_dir):
        if not name.endswith(".json"):
            continue
        try:
            with open(os.path.join(en_dir, name), encoding="utf-8") as f:
                payload = json.load(f)
            if isinstance(payload, dict):
                live_keys += len(payload)
        except Exception:
            continue

adjust_before = max(0, _safe_int(global_stats.get("reconciled_external_keys", 0)))
effective_before = max(0, registry_raw + adjust_before)
if live_keys > 0:
    effective_before = min(effective_before, live_keys)
outside_raw = max(0, live_keys - registry_raw)
outside_effective_before = max(0, live_keys - effective_before)
outside_pct_raw = (outside_raw / float(max(live_keys, 1))) * 100.0 if live_keys > 0 else 0.0

state = _read_json(state_path, {})
last_applied_dt = _parse_ts(state.get("last_applied_at", ""))
cooldown_ok = True
if last_applied_dt is not None:
    cooldown_ok = (now - last_applied_dt).total_seconds() >= max(min_interval_s, 1)

target_adjust = max(0, live_keys - registry_raw)
needs_sync = target_adjust != adjust_before
threshold_trigger = (outside_raw >= min_outside_keys) or (outside_pct_raw >= min_outside_pct)
force_sync = needs_sync and (target_adjust == 0 or adjust_before > 0)
should_reconcile = bool(needs_sync and (always_sync_any_drift or threshold_trigger or force_sync))
cooldown_bypassed = bool(always_sync_any_drift and needs_sync and not cooldown_ok)
if cooldown_bypassed:
    cooldown_ok = True

out.update({
    "live_keys": int(live_keys),
    "registry_keys_raw": int(registry_raw),
    "registry_adjustment_before": int(adjust_before),
    "registry_adjustment_after": int(adjust_before),
    "registry_keys_effective_before": int(effective_before),
    "registry_keys_effective_after": int(effective_before),
    "outside_keys_raw": int(outside_raw),
    "outside_pct_raw": round(outside_pct_raw, 3),
    "outside_keys_effective_before": int(outside_effective_before),
    "outside_keys_effective_after": int(outside_effective_before),
    "cooldown_ok": bool(cooldown_ok),
    "cooldown_bypassed": bool(cooldown_bypassed),
    "should_reconcile": bool(should_reconcile),
    "target_adjustment": int(target_adjust),
    "last_applied_at": state.get("last_applied_at", ""),
})

if not should_reconcile:
    out["action"] = "skipped_threshold"
    if not needs_sync:
        out["reason"] = "no_sync_needed"
    else:
        out["reason"] = "outside_raw_below_threshold"
elif not cooldown_ok:
    out["action"] = "skipped_cooldown"
    out["reason"] = "min_interval_not_elapsed"
else:
    status_payload.setdefault("global_stats", {})
    if not isinstance(status_payload["global_stats"], dict):
        status_payload["global_stats"] = {}
    status_payload["global_stats"]["reconciled_external_keys"] = int(target_adjust)
    status_payload["global_stats"]["reconciled_external_keys_updated_at"] = now_z
    status_payload["global_stats"]["reconciled_external_keys_source"] = "statusd_registry_reconcile"
    status_payload["global_stats"]["reconciled_external_keys_reason"] = "live_vs_registry_drift"
    status_payload["global_stats"]["total_keys_effective_registry"] = int(registry_raw + target_adjust)
    _write_json_atomic(status_file, status_payload)

    out["action"] = "applied" if target_adjust != adjust_before else "already_synced"
    out["reason"] = "registry_adjustment_updated" if target_adjust != adjust_before else "adjustment_already_current"
    out["registry_adjustment_after"] = int(target_adjust)
    effective_after = max(0, registry_raw + target_adjust)
    if live_keys > 0:
        effective_after = min(effective_after, live_keys)
    out["registry_keys_effective_after"] = int(effective_after)
    out["outside_keys_effective_after"] = int(max(0, live_keys - effective_after))

    state["last_applied_at"] = now_z
    state["last_action"] = out["action"]
    state["last_reason"] = out["reason"]
    state["last_target_adjustment"] = int(target_adjust)
    state["last_outside_keys_raw"] = int(outside_raw)
    state["last_outside_pct_raw"] = round(outside_pct_raw, 3)
    _write_json_atomic(state_path, state)

state.setdefault("last_checked_at", now_z)
state["last_checked_at"] = now_z
state["last_action"] = out["action"]
state["last_reason"] = out["reason"]
_write_json_atomic(state_path, state)
_write_json_atomic(latest_path, out)

if out["action"] in ("applied", "already_synced"):
    print(f"RECONCILE_{out['action'].upper()} target_adjust={target_adjust} outside_raw={outside_raw}")
else:
    print(f"RECONCILE_{out['action'].upper()} reason={out['reason']} outside_raw={outside_raw}")

# ── Per-file reconcile (backfill per_file_keys in registry) ──────────────
# Uzupełnia brakujące dane per-plik: mapuje każdy i18n/en/*.json
# do faktycznej liczby kluczy, niezależnie od registry NPC stages.

per_file_keys_before = status_payload.get("per_file_keys", {})
if not isinstance(per_file_keys_before, dict):
    per_file_keys_before = {}

per_file_keys_new = {}
per_file_changed = 0
per_file_added = 0

if os.path.isdir(en_dir):
    for name in sorted(os.listdir(en_dir)):
        if not name.endswith(".json"):
            continue
        fpath = os.path.join(en_dir, name)
        try:
            with open(fpath, encoding="utf-8") as f:
                payload = json.load(f)
            count = len(payload) if isinstance(payload, dict) else 0
        except Exception:
            count = 0

        old_count = per_file_keys_before.get(name, {}).get("keys", -1) if isinstance(per_file_keys_before.get(name), dict) else -1
        per_file_keys_new[name] = {
            "keys": count,
            "updated_at": now_z,
        }
        if name not in per_file_keys_before:
            per_file_added += 1
        elif old_count != count:
            per_file_changed += 1

# Only write if something changed
if per_file_added > 0 or per_file_changed > 0:
    status_payload["per_file_keys"] = per_file_keys_new
    _write_json_atomic(status_file, status_payload)
    print(f"PER_FILE_RECONCILE added={per_file_added} changed={per_file_changed} total={len(per_file_keys_new)}")
    out["per_file_reconcile"] = {
        "added": per_file_added,
        "changed": per_file_changed,
        "total": len(per_file_keys_new),
    }
elif per_file_keys_before != per_file_keys_new and per_file_keys_new:
    # First run — save even if no changes
    status_payload["per_file_keys"] = per_file_keys_new
    _write_json_atomic(status_file, status_payload)
    print(f"PER_FILE_RECONCILE initial_backfill total={len(per_file_keys_new)}")
    out["per_file_reconcile"] = {
        "added": len(per_file_keys_new),
        "changed": 0,
        "total": len(per_file_keys_new),
    }
else:
    out["per_file_reconcile"] = {
        "added": 0,
        "changed": 0,
        "total": len(per_file_keys_new),
        "status": "no_change",
    }

_write_json_atomic(latest_path, out)
PYRECON
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 9: Historia postępu (i18n_status_historia.md)
# ═══════════════════════════════════════════════════════════════════════════════

HISTORIA_ENABLED="${HISTORIA_ENABLED:-true}"
HISTORIA_INTERVAL="${HISTORIA_INTERVAL:-3600}"
HISTORIA_MAX_HOURLY_SNAPSHOTS="${HISTORIA_MAX_HOURLY_SNAPSHOTS:-168}"
HISTORIA_MAX_DAILY_SUMMARIES="${HISTORIA_MAX_DAILY_SUMMARIES:-30}"
HISTORIA_MAX_WEEKLY_SUMMARIES="${HISTORIA_MAX_WEEKLY_SUMMARIES:-12}"
HISTORIA_MD_PATH="${HISTORIA_MD_PATH:-docs/i18n/i18n_status_historia.md}"
HISTORIA_SNAPSHOTS_FILE="${HISTORIA_SNAPSHOTS_FILE:-i18n/status/historia_snapshots.jsonl}"
HISTORIA_DAILY_FILE="${HISTORIA_DAILY_FILE:-i18n/status/historia_daily.json}"
HISTORIA_WEEKLY_FILE="${HISTORIA_WEEKLY_FILE:-i18n/status/historia_weekly.json}"
HISTORIA_DAILY_FIRST_THRESHOLD="${HISTORIA_DAILY_FIRST_THRESHOLD:-5}"
HISTORIA_DAILY_STEP="${HISTORIA_DAILY_STEP:-5}"
HISTORIA_CLEANUP_HOURLY_AFTER_DAILY="${HISTORIA_CLEANUP_HOURLY_AFTER_DAILY:-true}"
HISTORIA_TIER_TARGETS="${HISTORIA_TIER_TARGETS:-{\"T1\":90,\"T2\":50,\"T3\":30}}"
HISTORIA_LAST_RUN_FILE="${HISTORIA_LAST_RUN_FILE:-$STATUS_DIR/.historia_last_run}"

maybe_run_historia() {
    [ "$HISTORIA_ENABLED" = "true" ] || return 0

    local now_epoch last_epoch
    now_epoch=$(date +%s)
    last_epoch=0
    if [ -f "$HISTORIA_LAST_RUN_FILE" ]; then
        last_epoch=$(cat "$HISTORIA_LAST_RUN_FILE" 2>/dev/null || echo 0)
    fi

    local elapsed=$(( now_epoch - last_epoch ))
    if [ "$elapsed" -lt "$HISTORIA_INTERVAL" ]; then
        return 0
    fi

    log_statusd "📜 Historia: uruchamiam snapshot (elapsed=${elapsed}s)"
    run_historia_snapshot
    echo "$now_epoch" > "$HISTORIA_LAST_RUN_FILE"
}

run_historia_snapshot() {
    python3 - "$WORK_DIR" "$STATUS_DIR" \
        "$HISTORIA_SNAPSHOTS_FILE" "$HISTORIA_DAILY_FILE" "$HISTORIA_WEEKLY_FILE" \
        "$HISTORIA_MD_PATH" \
        "$HISTORIA_MAX_HOURLY_SNAPSHOTS" "$HISTORIA_MAX_DAILY_SUMMARIES" "$HISTORIA_MAX_WEEKLY_SUMMARIES" \
        "$HISTORIA_DAILY_FIRST_THRESHOLD" "$HISTORIA_DAILY_STEP" \
        "$HISTORIA_CLEANUP_HOURLY_AFTER_DAILY" "$HISTORIA_TIER_TARGETS" <<'PYHISTORIA'
import json, sys, os, re
from datetime import datetime, timezone, timedelta
from pathlib import Path
from collections import defaultdict

# ── args ──
WORK = sys.argv[1]
STATUS = sys.argv[2]
SNAPSHOTS_PATH  = os.path.join(WORK, sys.argv[3])
DAILY_PATH      = os.path.join(WORK, sys.argv[4])
WEEKLY_PATH     = os.path.join(WORK, sys.argv[5])
MD_PATH         = os.path.join(WORK, sys.argv[6])
MAX_HOURLY      = int(sys.argv[7])
MAX_DAILY       = int(sys.argv[8])
MAX_WEEKLY      = int(sys.argv[9])
DAILY_FIRST_H   = int(sys.argv[10])
DAILY_STEP       = int(sys.argv[11])
CLEANUP_HOURLY   = sys.argv[12].lower() == "true"
try:
    TIER_TARGETS = json.loads(sys.argv[13])
except Exception:
    TIER_TARGETS = {"T1": 90, "T2": 50, "T3": 30}

NOW = datetime.now(timezone.utc)
NOW_Z = NOW.isoformat(timespec="seconds").replace("+00:00", "Z")
TODAY = NOW.strftime("%Y-%m-%d")
HOUR = NOW.hour

# ── tier mapping ──
T1 = {"pl", "es"}
T2 = {"de", "pt", "ru", "tr", "fr", "it", "nl", "cs", "sk", "hu"}

def tier_of(lang):
    if lang in T1: return "T1"
    if lang in T2: return "T2"
    return "T3"

def _read_json(path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}

def _read_jsonl_window(path, hours=1):
    """Read JSONL entries from last N hours."""
    cutoff = NOW - timedelta(hours=hours)
    entries = []
    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                    ts_str = d.get("timestamp", "")
                    if ts_str:
                        ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
                        if ts >= cutoff:
                            entries.append(d)
                except Exception:
                    continue
    except FileNotFoundError:
        pass
    return entries

def _write_json_atomic(path, data):
    tmp = path + ".tmp"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp, path)

def _append_jsonl(path, record):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")

def _trim_jsonl(path, max_lines):
    """Keep only last max_lines."""
    try:
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()
    except FileNotFoundError:
        return
    if len(lines) <= max_lines:
        return
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines[-max_lines:])

# ════════════════════════════════════════════
# 1) Collect hourly snapshot data
# ════════════════════════════════════════════

# 1a) Guard report → translated, guard_fail, per-lang
guard_entries = _read_jsonl_window(
    os.path.join(STATUS, "translation_guard_report.jsonl"), 1
)
total_translated = 0
total_guard_fail = 0
per_lang = defaultdict(lambda: {"t": 0, "gf": 0})
per_cat = defaultdict(lambda: {"t": 0, "gf": 0})
for e in guard_entries:
    t = e.get("translated", 0)
    gf = e.get("guard_fail", 0)
    total_translated += t
    total_guard_fail += gf
    lang = e.get("language", "?")
    per_lang[lang]["t"] += t
    per_lang[lang]["gf"] += gf
    cat = e.get("json_file", "?")
    per_cat[cat]["t"] += t
    per_cat[cat]["gf"] += gf

# 1b) Quality report → suspicious_high, identical_to_en
quality_entries = _read_jsonl_window(
    os.path.join(STATUS, "quality_report.jsonl"), 1
)
total_suspicious_high = 0
total_identical_to_en = 0
for e in quality_entries:
    q = e.get("quality", {})
    total_suspicious_high += q.get("suspicious_count", 0)
    total_identical_to_en += q.get("identical_to_en", 0)

# 1c) Worker cycle perf → cycles count, mode distribution
perf_entries = _read_jsonl_window(
    os.path.join(STATUS, "worker_cycle_perf.jsonl"), 1
)
total_cycles = 0
mode_dist = defaultdict(int)
seen_cycles = set()
for e in perf_entries:
    cid = e.get("cycle", 0)
    if cid not in seen_cycles:
        seen_cycles.add(cid)
        total_cycles += 1
    mode = e.get("mode", "UNKNOWN")
    mode_dist[mode] += 1

# 1d) Coverage from global_overview
overview = _read_json(os.path.join(STATUS, "translation_global_overview.json"))
coverage_global = overview.get("global", {}).get("completion_pct", 0)
lang_coverage = {}
for ld in overview.get("languages", []):
    lang_coverage[ld["lang"]] = ld.get("completion_pct", 0)

# 1e) Repair backlog from daily report
daily_report = _read_json(os.path.join(STATUS, "statusd_daily_report.json"))
repair_backlog = daily_report.get("repair_backlog", {})
repair_total = repair_backlog.get("current_total", 0)

# Previous snapshot for delta
prev_repair = 0
try:
    with open(SNAPSHOTS_PATH, encoding="utf-8") as f:
        lines = f.readlines()
        if lines:
            prev = json.loads(lines[-1])
            prev_repair = prev.get("repair_total", 0)
except Exception:
    pass
repair_delta = repair_total - prev_repair

# 1f) Migration info
migration = overview.get("migration", {})

# Merge per_lang with coverage
for lang in per_lang:
    per_lang[lang]["cov"] = round(lang_coverage.get(lang, 0), 2)

# Guard fail pct
gf_pct = round(100.0 * total_guard_fail / max(1, total_translated + total_guard_fail), 2)

# Average batch
avg_batch = round(total_translated / max(1, total_cycles), 1)

# Build snapshot
window_start = (NOW - timedelta(hours=1)).strftime("%H:%M")
window_end = NOW.strftime("%H:%M")

snapshot = {
    "ts": NOW_Z,
    "date": TODAY,
    "hour": HOUR,
    "window": f"{window_start}-{window_end}",
    "translated": total_translated,
    "guard_fail": total_guard_fail,
    "guard_fail_pct": gf_pct,
    "suspicious_high": total_suspicious_high,
    "identical_to_en": total_identical_to_en,
    "repair_total": repair_total,
    "repair_delta": repair_delta,
    "cycles": total_cycles,
    "avg_batch": avg_batch,
    "coverage_global": coverage_global,
    "mode_distribution": dict(mode_dist),
    "migration_completed": migration.get("files_completed", 0),
    "migration_total": migration.get("files_total", 0),
    "per_lang": {k: dict(v) for k, v in sorted(per_lang.items())},
    "per_cat": {k: dict(v) for k, v in sorted(per_cat.items(), key=lambda x: -x[1]["t"])[:10]},
}

# ════════════════════════════════════════════
# 2) Append snapshot to JSONL
# ════════════════════════════════════════════
_append_jsonl(SNAPSHOTS_PATH, snapshot)
_trim_jsonl(SNAPSHOTS_PATH, MAX_HOURLY)

print(f"SNAPSHOT saved: translated={total_translated} gf={total_guard_fail} cycles={total_cycles}")

# ════════════════════════════════════════════
# 3) Progressive daily aggregation
# ════════════════════════════════════════════

def load_all_snapshots():
    """Load all snapshots from JSONL."""
    result = []
    try:
        with open(SNAPSHOTS_PATH, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        result.append(json.loads(line))
                    except Exception:
                        pass
    except FileNotFoundError:
        pass
    return result

def aggregate_daily_progressive():
    """
    Progressive daily: create/update summary after DAILY_FIRST_H hours,
    then update every DAILY_STEP hours (5→10→15→20→24).
    """
    all_snaps = load_all_snapshots()
    today_snaps = [s for s in all_snaps if s.get("date") == TODAY]

    if not today_snaps:
        return None

    hours_covered = len(today_snaps)  # ~1 per hour
    # Check if we've passed a threshold
    thresholds = list(range(DAILY_FIRST_H, 25, DAILY_STEP))
    if 24 not in thresholds:
        thresholds.append(24)

    # Find current applicable threshold
    current_threshold = None
    for th in thresholds:
        if hours_covered >= th:
            current_threshold = th

    if current_threshold is None:
        return None  # Not enough hours yet

    # Load existing daily
    daily_data = []
    try:
        with open(DAILY_PATH, encoding="utf-8") as f:
            daily_data = json.load(f)
    except Exception:
        daily_data = []

    # Check if we already have this day+threshold
    existing_idx = None
    for i, dd in enumerate(daily_data):
        if dd.get("date") == TODAY:
            existing_idx = i
            break

    # Aggregate today's snapshots
    summary = {
        "date": TODAY,
        "hours_covered": hours_covered,
        "threshold": current_threshold,
        "is_final": current_threshold >= 24 or hours_covered >= 24,
        "ts_first": today_snaps[0].get("ts", ""),
        "ts_last": today_snaps[-1].get("ts", ""),
        "translated": sum(s.get("translated", 0) for s in today_snaps),
        "guard_fail": sum(s.get("guard_fail", 0) for s in today_snaps),
        "suspicious_high": sum(s.get("suspicious_high", 0) for s in today_snaps),
        "identical_to_en": sum(s.get("identical_to_en", 0) for s in today_snaps),
        "repair_start": today_snaps[0].get("repair_total", 0),
        "repair_end": today_snaps[-1].get("repair_total", 0),
        "cycles": sum(s.get("cycles", 0) for s in today_snaps),
        "coverage_start": today_snaps[0].get("coverage_global", 0),
        "coverage_end": today_snaps[-1].get("coverage_global", 0),
    }

    # Guard fail rate
    total_attempts = summary["translated"] + summary["guard_fail"]
    summary["guard_fail_pct"] = round(100.0 * summary["guard_fail"] / max(1, total_attempts), 2)

    # Throughput
    summary["throughput_per_h"] = round(summary["translated"] / max(1, hours_covered), 1)

    # Per-lang aggregation
    lang_agg = defaultdict(lambda: {"t": 0, "gf": 0})
    for s in today_snaps:
        for lang, ld in s.get("per_lang", {}).items():
            lang_agg[lang]["t"] += ld.get("t", 0)
            lang_agg[lang]["gf"] += ld.get("gf", 0)
    # Add latest coverage
    for lang in lang_agg:
        lang_agg[lang]["cov"] = lang_coverage.get(lang, 0)
    summary["per_lang"] = {k: dict(v) for k, v in sorted(lang_agg.items(), key=lambda x: -x[1]["t"])[:15]}

    # Per-cat aggregation
    cat_agg = defaultdict(lambda: {"t": 0, "gf": 0})
    for s in today_snaps:
        for cat, cd in s.get("per_cat", {}).items():
            cat_agg[cat]["t"] += cd.get("t", 0)
            cat_agg[cat]["gf"] += cd.get("gf", 0)
    summary["per_cat"] = {k: dict(v) for k, v in sorted(cat_agg.items(), key=lambda x: -x[1]["t"])[:10]}

    # Mode distribution
    mode_agg = defaultdict(int)
    for s in today_snaps:
        for m, c in s.get("mode_distribution", {}).items():
            mode_agg[m] += c
    summary["mode_distribution"] = dict(mode_agg)

    # Migration
    summary["migration_completed"] = today_snaps[-1].get("migration_completed", 0)
    summary["migration_total"] = today_snaps[-1].get("migration_total", 0)

    if existing_idx is not None:
        daily_data[existing_idx] = summary
    else:
        daily_data.append(summary)

    # Trim
    daily_data = daily_data[-MAX_DAILY:]
    _write_json_atomic(DAILY_PATH, daily_data)

    return summary

daily_summary = aggregate_daily_progressive()
if daily_summary:
    print(f"DAILY progressive: hours={daily_summary['hours_covered']} threshold={daily_summary['threshold']} translated={daily_summary['translated']}")

# ════════════════════════════════════════════
# 4) Weekly aggregation (on Sunday or when 7 daily finals exist)
# ════════════════════════════════════════════

def aggregate_weekly():
    """Aggregate completed daily summaries into weekly."""
    try:
        with open(DAILY_PATH, encoding="utf-8") as f:
            daily_data = json.load(f)
    except Exception:
        return None

    # Find final dailies (is_final=true)
    finals = [d for d in daily_data if d.get("is_final")]
    if len(finals) < 7:
        return None

    # Check last weekly
    weekly_data = []
    try:
        with open(WEEKLY_PATH, encoding="utf-8") as f:
            weekly_data = json.load(f)
    except Exception:
        weekly_data = []

    # Find dates covered by existing weeklies
    covered_dates = set()
    for w in weekly_data:
        for d in w.get("dates", []):
            covered_dates.add(d)

    # Find 7 consecutive finals not yet covered
    uncovered = [d for d in finals if d.get("date") not in covered_dates]
    if len(uncovered) < 7:
        return None

    week_batch = uncovered[:7]
    week_dates = [d["date"] for d in week_batch]

    weekly = {
        "week_start": week_dates[0],
        "week_end": week_dates[-1],
        "dates": week_dates,
        "ts": NOW_Z,
        "translated": sum(d.get("translated", 0) for d in week_batch),
        "guard_fail": sum(d.get("guard_fail", 0) for d in week_batch),
        "cycles": sum(d.get("cycles", 0) for d in week_batch),
        "coverage_start": week_batch[0].get("coverage_start", 0),
        "coverage_end": week_batch[-1].get("coverage_end", 0),
        "coverage_delta": round(week_batch[-1].get("coverage_end", 0) - week_batch[0].get("coverage_start", 0), 2),
        "repair_start": week_batch[0].get("repair_start", 0),
        "repair_end": week_batch[-1].get("repair_end", 0),
        "throughput_per_h": round(sum(d.get("translated", 0) for d in week_batch) / max(1, sum(d.get("hours_covered", 24) for d in week_batch)), 1),
    }

    # ETA per tier
    eta = {}
    week_translated = weekly["translated"]
    if week_translated > 0:
        glo = overview.get("global", {})
        total_ref = glo.get("total_reference_keys", 0)
        translated_now = glo.get("translated_keys", 0)
        missing_now = total_ref - translated_now
        if missing_now > 0:
            weeks_to_done = missing_now / max(1, week_translated)
            eta["global"] = f"{weeks_to_done:.1f} tygodni"

    # Per-lang coverage in week end
    per_lang_weekly = {}
    for d in week_batch:
        for lang, ld in d.get("per_lang", {}).items():
            if lang not in per_lang_weekly:
                per_lang_weekly[lang] = {"t": 0, "gf": 0, "cov": 0}
            per_lang_weekly[lang]["t"] += ld.get("t", 0)
            per_lang_weekly[lang]["gf"] += ld.get("gf", 0)
    # Latest coverage
    for lang in per_lang_weekly:
        per_lang_weekly[lang]["cov"] = lang_coverage.get(lang, 0)

    weekly["per_lang"] = {k: v for k, v in sorted(per_lang_weekly.items(), key=lambda x: -x[1]["t"])[:15]}
    weekly["eta"] = eta

    # Migration
    weekly["migration_completed"] = week_batch[-1].get("migration_completed", 0)
    weekly["migration_total"] = week_batch[-1].get("migration_total", 0)

    weekly_data.append(weekly)
    weekly_data = weekly_data[-MAX_WEEKLY:]
    _write_json_atomic(WEEKLY_PATH, weekly_data)

    print(f"WEEKLY aggregated: {week_dates[0]}..{week_dates[-1]} translated={weekly['translated']}")
    return weekly

weekly_summary = aggregate_weekly()

# ════════════════════════════════════════════
# 5) Render Markdown
# ════════════════════════════════════════════

def render_historia_md():
    """
    Generate or update i18n_status_historia.md.
    - Only current day hourly snapshots in .md
    - Progressive daily (5h→10h→15h→20h→24h)
    - After 24h daily close: hourly removed from .md
    - Weekly summary at top
    """
    all_snaps = load_all_snapshots()
    today_snaps = [s for s in all_snaps if s.get("date") == TODAY]

    # Load daily
    daily_data = []
    try:
        with open(DAILY_PATH, encoding="utf-8") as f:
            daily_data = json.load(f)
    except Exception:
        pass

    # Load weekly
    weekly_data = []
    try:
        with open(WEEKLY_PATH, encoding="utf-8") as f:
            weekly_data = json.load(f)
    except Exception:
        pass

    # Get today's daily
    today_daily = None
    for d in daily_data:
        if d.get("date") == TODAY:
            today_daily = d
            break

    lines = []
    lines.append("# i18n — Historia postępu\n")
    lines.append(f"> Ostatnia aktualizacja: {NOW_Z}  ")
    lines.append(f"> Globalny coverage: **{coverage_global}%**  ")
    lines.append(f"> Repair backlog: **{repair_total}** kluczy\n")
    lines.append("---\n")

    # ── Weekly summary ──
    if weekly_data:
        w = weekly_data[-1]
        lines.append("## 📊 Ostatni tydzień\n")
        lines.append(f"**{w.get('week_start','')} — {w.get('week_end','')}**\n")
        lines.append("| Metryka | Wartość |")
        lines.append("|---------|---------|")
        lines.append(f"| Kluczy przetłumaczonych | **{w.get('translated',0):,}** |")
        lines.append(f"| Throughput | {w.get('throughput_per_h',0):,} kluczy/h |")
        lines.append(f"| Guard fail | {w.get('guard_fail',0):,} |")
        lines.append(f"| Cykli workera | {w.get('cycles',0):,} |")
        cd = w.get('coverage_delta', 0)
        sign = "+" if cd >= 0 else ""
        lines.append(f"| Coverage Δ | {sign}{cd}% ({w.get('coverage_start',0)}% → {w.get('coverage_end',0)}%) |")
        lines.append(f"| Repair queue | {w.get('repair_start',0):,} → {w.get('repair_end',0):,} |")
        lines.append(f"| Migracja | {w.get('migration_completed',0)}/{w.get('migration_total',0)} plików |")
        if w.get("eta"):
            lines.append(f"\n**ETA do 100%:** {w['eta'].get('global', 'brak danych')}\n")
        # Per-lang top5 weekly
        pl = w.get("per_lang", {})
        if pl:
            top5 = sorted(pl.items(), key=lambda x: -x[1].get("t", 0))[:5]
            lines.append("\n**Top 5 języków (tydzień):**\n")
            lines.append("| Język | Przetłum. | Guard fail | Coverage |")
            lines.append("|-------|-----------|------------|----------|")
            for lang, ld in top5:
                lines.append(f"| {lang} | {ld.get('t',0):,} | {ld.get('gf',0)} | {ld.get('cov',0)}% |")
        lines.append("\n---\n")

    # ── Daily summary (progressive) ──
    if today_daily:
        th = today_daily.get("threshold", "?")
        hrs = today_daily.get("hours_covered", 0)
        is_final = today_daily.get("is_final", False)
        label = "FINALNE" if is_final else f"progresywne ({hrs}h / {th}h)"
        lines.append(f"## 📅 Dzisiaj: {TODAY} — {label}\n")
        lines.append("| Metryka | Wartość |")
        lines.append("|---------|---------|")
        lines.append(f"| Kluczy przetłumaczonych | **{today_daily.get('translated',0):,}** |")
        lines.append(f"| Throughput | {today_daily.get('throughput_per_h',0):,} kluczy/h |")
        lines.append(f"| Guard fail rate | {today_daily.get('guard_fail_pct',0)}% ({today_daily.get('guard_fail',0):,} / {today_daily.get('translated',0) + today_daily.get('guard_fail',0):,}) |")
        lines.append(f"| Cykli workera | {today_daily.get('cycles',0):,} |")
        lines.append(f"| Coverage | {today_daily.get('coverage_start',0)}% → {today_daily.get('coverage_end',0)}% |")
        rs = today_daily.get("repair_start", 0)
        re_ = today_daily.get("repair_end", 0)
        rd = re_ - rs
        sign = "+" if rd >= 0 else ""
        lines.append(f"| Repair queue | {rs:,} → {re_:,} ({sign}{rd}) |")

        # Mode distribution
        md = today_daily.get("mode_distribution", {})
        if md:
            lines.append(f"\n**Tryby workera:** {', '.join(f'{m}: {c}' for m, c in sorted(md.items()))}\n")

        # Migration
        mc = today_daily.get("migration_completed", 0)
        mt = today_daily.get("migration_total", 0)
        if mt > 0:
            mpct = round(100.0 * mc / mt, 1)
            lines.append(f"**Migracja:** {mc}/{mt} plików ({mpct}%)\n")

        # Top languages today
        pl = today_daily.get("per_lang", {})
        if pl:
            top = sorted(pl.items(), key=lambda x: -x[1].get("t", 0))[:8]
            lines.append("\n<details><summary>Top języki dzisiaj</summary>\n")
            lines.append("| Język | Przetłum. | Guard fail | Coverage |")
            lines.append("|-------|-----------|------------|----------|")
            for lang, ld in top:
                lines.append(f"| {lang} | {ld.get('t',0):,} | {ld.get('gf',0)} | {ld.get('cov',0)}% |")
            lines.append("\n</details>\n")

        # Top categories today
        pc = today_daily.get("per_cat", {})
        if pc:
            topc = sorted(pc.items(), key=lambda x: -x[1].get("t", 0))[:5]
            lines.append("\n<details><summary>Top kategorie dzisiaj</summary>\n")
            lines.append("| Kategoria | Przetłum. | Guard fail |")
            lines.append("|-----------|-----------|------------|")
            for cat, cd in topc:
                lines.append(f"| {cat} | {cd.get('t',0):,} | {cd.get('gf',0)} |")
            lines.append("\n</details>\n")
        lines.append("\n---\n")

    # ── Hourly snapshots (today only) ──
    # If today's daily is final (24h), skip hourly section per config
    show_hourly = True
    if today_daily and today_daily.get("is_final") and CLEANUP_HOURLY:
        show_hourly = False

    if show_hourly and today_snaps:
        # Sort chronologically
        today_snaps.sort(key=lambda s: s.get("ts", ""))
        lines.append(f"## ⏱️ Snapshoty godzinowe: {TODAY}\n")
        lines.append("| Okno | Przetłum. | Guard fail | GF% | Suspicious | Repair Δ | Cykli |")
        lines.append("|------|-----------|------------|-----|------------|----------|-------|")
        for s in today_snaps:
            lines.append(
                f"| {s.get('window','-')} "
                f"| {s.get('translated',0):,} "
                f"| {s.get('guard_fail',0)} "
                f"| {s.get('guard_fail_pct',0)}% "
                f"| {s.get('suspicious_high',0)} "
                f"| {'+' if s.get('repair_delta',0) >= 0 else ''}{s.get('repair_delta',0)} "
                f"| {s.get('cycles',0)} |"
            )
        lines.append("")

        # Per-lang detail from latest snapshot
        if today_snaps:
            latest = today_snaps[-1]
            pl = latest.get("per_lang", {})
            if pl:
                lines.append("\n<details><summary>Szczegóły per język (ostatnia godzina)</summary>\n")
                lines.append("| Język | Przetłum. | Guard fail | Coverage |")
                lines.append("|-------|-----------|------------|----------|")
                for lang, ld in sorted(pl.items(), key=lambda x: -x[1].get("t", 0)):
                    if ld.get("t", 0) > 0 or ld.get("gf", 0) > 0:
                        lines.append(f"| {lang} | {ld.get('t',0)} | {ld.get('gf',0)} | {ld.get('cov',0)}% |")
                lines.append("\n</details>\n")
        lines.append("\n---\n")

    # ── Previous daily summaries (archiwum) ──
    prev_dailies = [d for d in daily_data if d.get("date") != TODAY]
    if prev_dailies:
        lines.append("## 📂 Poprzednie dni\n")
        lines.append("| Data | Przetłum. | GF% | Throughput | Coverage | Repair |")
        lines.append("|------|-----------|-----|-----------|----------|--------|")
        for d in reversed(prev_dailies[-14:]):
            lines.append(
                f"| {d.get('date','-')} "
                f"| {d.get('translated',0):,} "
                f"| {d.get('guard_fail_pct',0)}% "
                f"| {d.get('throughput_per_h',0):,}/h "
                f"| {d.get('coverage_end',0)}% "
                f"| {d.get('repair_end',0):,} |"
            )
        lines.append("\n---\n")

    # ── Previous weekly summaries ──
    prev_weeklies = weekly_data[:-1] if len(weekly_data) > 1 else []
    if prev_weeklies:
        lines.append("## 📅 Poprzednie tygodnie\n")
        lines.append("| Tydzień | Przetłum. | Throughput | Coverage Δ |")
        lines.append("|---------|-----------|-----------|-----------|")
        for w in reversed(prev_weeklies[-8:]):
            cd = w.get('coverage_delta', 0)
            sign = "+" if cd >= 0 else ""
            lines.append(
                f"| {w.get('week_start','-')}..{w.get('week_end','-')} "
                f"| {w.get('translated',0):,} "
                f"| {w.get('throughput_per_h',0):,}/h "
                f"| {sign}{cd}% |"
            )
        lines.append("")

    # Write MD
    os.makedirs(os.path.dirname(MD_PATH), exist_ok=True)
    with open(MD_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"MD rendered: {MD_PATH} ({len(lines)} lines)")

render_historia_md()

print("HISTORIA_OK")
PYHISTORIA
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 10: Tygodniowy raport wielojęzyczny (4c)
# ═══════════════════════════════════════════════════════════════════════════════
#
# Generuje czytelny raport .md + .json z pokryciem per-tier, per-lang,
# najszybciej/najwolniej rosnącymi językami, ETA do 100%.
# Uruchamiany co 7 dni (konfigurowalny interwał) lub ręcznie --weekly-multilang.
#

WEEKLY_MULTILANG_ENABLED="${WEEKLY_MULTILANG_ENABLED:-true}"
WEEKLY_MULTILANG_INTERVAL="${WEEKLY_MULTILANG_INTERVAL:-604800}"  # 7 dni w sekundach
WEEKLY_MULTILANG_JSON="${WEEKLY_MULTILANG_JSON:-i18n/status/weekly_multilang_report.json}"
WEEKLY_MULTILANG_MD="${WEEKLY_MULTILANG_MD:-docs/i18n/i18n_weekly_multilang_report.md}"
WEEKLY_MULTILANG_HISTORY="${WEEKLY_MULTILANG_HISTORY:-i18n/status/weekly_multilang_history.json}"
WEEKLY_MULTILANG_MAX_HISTORY="${WEEKLY_MULTILANG_MAX_HISTORY:-52}"
WEEKLY_MULTILANG_LAST_RUN_FILE="${WEEKLY_MULTILANG_LAST_RUN_FILE:-.weekly_multilang_last_run}"

TIER1_LANGS_LIST="${TIER1_LANGS_LIST:-pl es}"
TIER2_LANGS_LIST="${TIER2_LANGS_LIST:-de pt ru tr fr it nl cs sk hu}"
# TIER3 = all remaining languages

maybe_run_weekly_multilang() {
    if [ "$WEEKLY_MULTILANG_ENABLED" != "true" ]; then
        return 0
    fi
    local now_ts last_ts age_s
    now_ts=$(date +%s)
    last_ts=0
    if [ -f "$WEEKLY_MULTILANG_LAST_RUN_FILE" ]; then
        last_ts=$(cat "$WEEKLY_MULTILANG_LAST_RUN_FILE" 2>/dev/null || echo 0)
    fi
    age_s=$((now_ts - last_ts))
    if [ "$age_s" -ge "$WEEKLY_MULTILANG_INTERVAL" ]; then
        run_weekly_multilang
    fi
}

run_weekly_multilang() {
    if [ "$WEEKLY_MULTILANG_ENABLED" != "true" ]; then
        echo "WEEKLY_MULTILANG_DISABLED"
        return 0
    fi
    local result
    result=$(python3 - "$STATUS_DIR" "$WEEKLY_MULTILANG_JSON" "$WEEKLY_MULTILANG_MD" \
        "$WEEKLY_MULTILANG_HISTORY" "$WEEKLY_MULTILANG_MAX_HISTORY" \
        "$TIER1_LANGS_LIST" "$TIER2_LANGS_LIST" <<'PYWEEKLYMULTILANG'
import json, sys, os, re
from datetime import datetime, timezone, timedelta
from collections import defaultdict

STATUS   = sys.argv[1]
OUT_JSON = sys.argv[2]
OUT_MD   = sys.argv[3]
HIST_FILE = sys.argv[4]
MAX_HIST = int(sys.argv[5])
TIER1    = set(sys.argv[6].split())
TIER2    = set(sys.argv[7].split())

WORK = os.environ.get("WORK_DIR", os.getcwd())
NOW  = datetime.now(timezone.utc)
NOW_Z = NOW.isoformat().replace("+00:00", "Z")
WEEK_NUM = NOW.isocalendar()[1]

def _read_json(path, default=None):
    try:
        with open(os.path.join(WORK, path) if not os.path.isabs(path) else path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default if default is not None else {}

def _write_json(path, data):
    full = os.path.join(WORK, path) if not os.path.isabs(path) else path
    os.makedirs(os.path.dirname(full), exist_ok=True)
    tmp = full + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp, full)

# ── 1) Collect current per-language coverage ──
overview = _read_json(os.path.join(STATUS, "translation_global_overview.json"))
glo = overview.get("global", {})
total_ref = glo.get("total_reference_keys", 0)
total_translated = glo.get("translated_keys", 0)
global_pct = round(100.0 * total_translated / max(1, total_ref), 2)

langs_list = overview.get("languages", [])
lang_data = {}
for entry in langs_list:
    lang = str(entry.get("lang", "")).lower()
    if not lang or lang == "en":
        continue
    lang_data[lang] = {
        "lang": lang,
        "name": entry.get("language_name", lang),
        "translated": entry.get("translated_keys", 0),
        "total": entry.get("total_reference_keys", total_ref),
        "en_copy": entry.get("english_copy_keys", 0),
        "missing": entry.get("missing_keys", 0),
        "pct": entry.get("completion_pct", 0),
    }

# ── 2) Load previous report for delta calculation ──
history = _read_json(HIST_FILE, [])
prev = history[-1] if history else None
prev_by_lang = {}
if prev:
    for ld in prev.get("languages", []):
        prev_by_lang[ld.get("lang", "")] = ld

# ── 3) Calculate deltas and tier grouping ──
def tier_of(lang):
    if lang in TIER1:
        return "T1"
    if lang in TIER2:
        return "T2"
    return "T3"

tier_groups = {"T1": [], "T2": [], "T3": []}
all_langs_report = []

for lang, ld in sorted(lang_data.items(), key=lambda x: -x[1]["pct"]):
    prev_ld = prev_by_lang.get(lang, {})
    prev_pct = prev_ld.get("pct", ld["pct"])
    prev_translated = prev_ld.get("translated", ld["translated"])
    delta_pct = round(ld["pct"] - prev_pct, 2)
    delta_keys = ld["translated"] - prev_translated

    entry = {
        "lang": lang,
        "name": ld["name"],
        "pct": ld["pct"],
        "translated": ld["translated"],
        "total": ld["total"],
        "en_copy": ld["en_copy"],
        "missing": ld["missing"],
        "delta_pct": delta_pct,
        "delta_keys": delta_keys,
        "tier": tier_of(lang),
    }
    all_langs_report.append(entry)
    tier_groups[tier_of(lang)].append(entry)

# Sort within tiers by coverage desc
for t in tier_groups:
    tier_groups[t].sort(key=lambda x: -x["pct"])

# ── 4) Find fastest/slowest growing ──
with_delta = [e for e in all_langs_report if e["delta_pct"] != 0]
if not with_delta:
    with_delta = all_langs_report
fastest = max(with_delta, key=lambda x: x["delta_pct"]) if with_delta else None
slowest = min(with_delta, key=lambda x: x["delta_pct"]) if with_delta else None

# ── 5) ETA calculation ──
eta_global = None
if prev:
    prev_global_pct = prev.get("global_pct", 0)
    delta_global = global_pct - prev_global_pct
    if delta_global > 0:
        remaining = 100.0 - global_pct
        weeks_to_done = remaining / delta_global
        eta_global = f"{weeks_to_done:.1f} tygodni"

# ── 6) Quality summary ──
quality = overview.get("quality", {})

# ── 7) Build report JSON ──
report = {
    "timestamp": NOW_Z,
    "week_number": WEEK_NUM,
    "global_pct": global_pct,
    "total_ref": total_ref,
    "total_translated": total_translated,
    "languages": all_langs_report,
    "tier_summary": {},
    "fastest": fastest,
    "slowest": slowest,
    "eta_global": eta_global,
}

for tier_name, langs in tier_groups.items():
    if langs:
        avg_pct = round(sum(l["pct"] for l in langs) / len(langs), 2)
        total_t = sum(l["translated"] for l in langs)
        total_d = sum(l["delta_keys"] for l in langs)
        report["tier_summary"][tier_name] = {
            "count": len(langs),
            "avg_pct": avg_pct,
            "total_translated": total_t,
            "total_delta_keys": total_d,
        }

_write_json(OUT_JSON, report)

# ── 8) Append to history ──
history.append(report)
history = history[-MAX_HIST:]
_write_json(HIST_FILE, history)

# ── 9) Render Markdown ──
lines = []
lines.append(f"# 🌍 Raport wielojęzyczny (tydzień {WEEK_NUM})")
lines.append("")
lines.append(f"> Wygenerowano: {NOW_Z}  ")
lines.append(f"> Globalny coverage: **{global_pct}%** ({total_translated:,} / {total_ref:,} kluczy)  ")
if eta_global:
    lines.append(f"> ETA do 100%: **{eta_global}**  ")
if prev:
    lines.append(f"> Porównanie z: tydzień {prev.get('week_number', '?')} ({prev.get('timestamp', '?')[:10]})")
lines.append("")
lines.append("---")
lines.append("")

# Tier overview (compact format matching plan spec)
lines.append("## Przegląd per Tier")
lines.append("")

for tier_name, tier_label, target in [("T1", "Tier 1 (priorytet)", "90%"), ("T2", "Tier 2 (rozszerzony)", "50%"), ("T3", "Tier 3 (reszta)", "30%")]:
    langs = tier_groups.get(tier_name, [])
    if not langs:
        continue
    ts = report["tier_summary"].get(tier_name, {})
    lines.append(f"### {tier_label} — cel: {target} | avg: {ts.get('avg_pct', 0)}%")
    lines.append("")
    parts = []
    for l in langs:
        sign = "+" if l["delta_pct"] >= 0 else ""
        parts.append(f"**{l['lang'].upper()}** {l['pct']}% ({sign}{l['delta_pct']}%)")
    # Wrap to multiple lines if many
    line = " | ".join(parts)
    lines.append(line)
    lines.append("")

lines.append("---")
lines.append("")

# Fastest / slowest
lines.append("## Dynamika wzrostu")
lines.append("")
if fastest:
    lines.append(f"⚡ **Najszybciej rosnący:** {fastest['lang'].upper()} ({fastest['name']}) — +{fastest['delta_pct']}% (+{fastest['delta_keys']:,} kluczy)")
if slowest:
    sign = "+" if slowest["delta_pct"] >= 0 else ""
    lines.append(f"🐌 **Najwolniejszy:** {slowest['lang'].upper()} ({slowest['name']}) — {sign}{slowest['delta_pct']}% ({sign}{slowest['delta_keys']:,} kluczy)")
lines.append("")
lines.append("---")
lines.append("")

# Detailed table
lines.append("## Szczegółowa tabela")
lines.append("")
lines.append("| # | Tier | Język | Nazwa | Coverage | Δ% | Przetłum. | Δ kluczy | EN-copy | Brakujące |")
lines.append("|---|------|-------|-------|----------|-------|-----------|----------|---------|-----------|")
for i, l in enumerate(sorted(all_langs_report, key=lambda x: ({"T1":0,"T2":1,"T3":2}[x["tier"]], -x["pct"])), 1):
    sign = "+" if l["delta_pct"] >= 0 else ""
    dsign = "+" if l["delta_keys"] >= 0 else ""
    lines.append(
        f"| {i} | {l['tier']} | {l['lang'].upper()} | {l['name']} "
        f"| {l['pct']}% | {sign}{l['delta_pct']}% "
        f"| {l['translated']:,} | {dsign}{l['delta_keys']:,} "
        f"| {l['en_copy']:,} | {l['missing']:,} |"
    )
lines.append("")

# Tier statistics
lines.append("---")
lines.append("")
lines.append("## Statystyki per Tier")
lines.append("")
lines.append("| Tier | Języków | Avg coverage | Przetłum. łącznie | Δ kluczy (tydzień) |")
lines.append("|------|---------|-------------|-------------------|-------------------|")
for tn in ["T1", "T2", "T3"]:
    ts = report["tier_summary"].get(tn, {})
    if ts:
        lines.append(f"| {tn} | {ts['count']} | {ts['avg_pct']}% | {ts['total_translated']:,} | +{ts['total_delta_keys']:,} |")
lines.append("")

# History trend (if >=2 entries)
if len(history) >= 2:
    lines.append("---")
    lines.append("")
    lines.append("## Trend historyczny")
    lines.append("")
    lines.append("| Tydzień | Data | Global % | Δ% |")
    lines.append("|---------|------|----------|-----|")
    for h in history[-12:]:
        hprev_idx = history.index(h) - 1
        hprev_pct = history[hprev_idx].get("global_pct", 0) if hprev_idx >= 0 else h.get("global_pct", 0)
        hd = round(h.get("global_pct", 0) - hprev_pct, 2)
        sign = "+" if hd >= 0 else ""
        lines.append(f"| W{h.get('week_number','?')} | {h.get('timestamp','')[:10]} | {h.get('global_pct', 0)}% | {sign}{hd}% |")
    lines.append("")

lines.append("---")
lines.append(f"*Raport wygenerowany automatycznie przez i18n-statusd MODUŁ 10*")

# Write MD
md_full = os.path.join(WORK, OUT_MD) if not os.path.isabs(OUT_MD) else OUT_MD
os.makedirs(os.path.dirname(md_full), exist_ok=True)
with open(md_full, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print(f"WEEKLY_MULTILANG week={WEEK_NUM} global={global_pct}% langs={len(all_langs_report)} md_lines={len(lines)}")

PYWEEKLYMULTILANG
    )
    echo "$result"
    date +%s > "$WEEKLY_MULTILANG_LAST_RUN_FILE"
    log_statusd "📊 Weekly multilang: $result"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODUŁ 8: Daemon loop
# ═══════════════════════════════════════════════════════════════════════════════

run_statusd_cycle() {
    local result reconcile_result
    reconcile_result=$(run_registry_reconcile 2>/dev/null || true)
    if [ -n "$reconcile_result" ]; then
        log_statusd "🧩 Registry reconcile: $reconcile_result"
    fi
    maybe_refresh_status_md "$reconcile_result" >> "$STATUSD_LOG" 2>&1 || true

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

    # Historia postępu (MODUŁ 9 — co 1h)
    local historia_result
    historia_result=$(maybe_run_historia 2>/dev/null || true)
    if [ -n "$historia_result" ]; then
        log_statusd "📜 Historia: $historia_result"
    fi

    # Tygodniowy raport wielojęzyczny (MODUŁ 10 — co 7 dni)
    local weekly_ml_result
    weekly_ml_result=$(maybe_run_weekly_multilang 2>/dev/null || true)
    if [ -n "$weekly_ml_result" ]; then
        log_statusd "📊 Weekly multilang: $weekly_ml_result"
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
        reconcile_result=""
        echo "═══ i18n-statusd: jednorazowy raport ═══"
        reconcile_result=$(run_registry_reconcile 2>/dev/null || true)
        if [ -n "$reconcile_result" ]; then
            echo "$reconcile_result"
        fi
        maybe_refresh_status_md "$reconcile_result"
        aggregate_telemetry
        echo ""
        run_status_doctor
        echo ""
        generate_kpi_snapshot
        echo ""
        generate_recommendations
        echo ""
        generate_daily_report
        echo ""
        echo "═══ Historia snapshot ═══"
        run_historia_snapshot
        echo ""
        echo "═══ Weekly multilang raport ═══"
        run_weekly_multilang
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
    --reconcile-registry)
        reconcile_result=$(run_registry_reconcile 2>/dev/null || true)
        if [ -n "$reconcile_result" ]; then
            echo "$reconcile_result"
        fi
        maybe_refresh_status_md "$reconcile_result"
        ;;
    --historia)
        HISTORIA_ENABLED=true
        echo "═══ Historia snapshot (ręczne uruchomienie) ═══"
        run_historia_snapshot
        ;;
    --weekly-multilang)
        WEEKLY_MULTILANG_ENABLED=true
        echo "═══ Weekly multilang raport (ręczne uruchomienie) ═══"
        run_weekly_multilang
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
        echo "Użycie: $0 {--once|--daemon|--doctor|--kpi|--recommend|--aggregate|--reconcile-registry|--daily-report|--alert-check|--auto-action|--enable-auto|--disable-auto|--audit|--weekly-multilang}"
        echo ""
        echo "  --once       Jednorazowy pełny raport (telemetria + doctor + KPI + rekomendacje + raport 24h)"
        echo "  --daemon     Ciągła pętla co ${DAEMON_INTERVAL_SECONDS}s"
        echo "  --doctor     Diagnostyka spójności statusu"
        echo "  --kpi        KPI snapshot"
        echo "  --recommend  Rekomendacje profilu/akcji"
        echo "  --aggregate  Agregacja telemetrii do JSON"
        echo "  --reconcile-registry Uzgodnij registry keys z LIVE (zapis korekty w i18n_file_status.json)"
        echo "  --historia   Ręczny snapshot historii postępu → i18n_status_historia.md"
        echo "  --weekly-multilang  Ręczny raport tygodniowy wielojęzyczny → i18n_weekly_multilang_report.md"
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
