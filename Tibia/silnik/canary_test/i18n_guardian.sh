#!/bin/bash
# Guardian v3.0 - automatyczny restart workera i18n + push do GitHub
# Uruchamiany przez cron co minutę
# Monitoruje i18n_worker_simple.sh w trybie --continuous

WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
REPO_ROOT="/home/ptaku/serweryt"
WORKER_SCRIPT="i18n_worker_simple.sh"
LOG_FILE="$WORK_DIR/work_i18n_live.log"
PID_FILE="$WORK_DIR/.worker_simple.pid"
GUARDIAN_LOG="$WORK_DIR/guardian.log"
MTIME_FILE="$WORK_DIR/.worker_script_mtime"
PROFILE_FILE="$WORK_DIR/guardian_profile.json"
PROFILES_DIR="$WORK_DIR/guardian_profiles"
POLICY_STATE_FILE="$WORK_DIR/.guardian_policy_state.json"
RESTART_STATE_FILE="$WORK_DIR/.guardian_restart_state.json"
RESTART_METRICS_FILE="$WORK_DIR/i18n/status/guardian_restart_metrics.json"
GIT_TRACK_BRANCH="${GIT_TRACK_BRANCH:-$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo master)}"
if [ -z "$GIT_TRACK_BRANCH" ] || [ "$GIT_TRACK_BRANCH" = "HEAD" ]; then
    GIT_TRACK_BRANCH="master"
fi

# Co ile sekund wykonywać push dashboardu
PUSH_INTERVAL_SECONDS=120
LAST_PUSH_TS_FILE="$WORK_DIR/.guardian_last_push_ts"

# Restart policy (P0.5): debounce/backoff/cooldown
MTIME_RESTART_MIN_INTERVAL_SEC="${MTIME_RESTART_MIN_INTERVAL_SEC:-90}"
RESTART_FAILURE_BACKOFF_BASE_SEC="${RESTART_FAILURE_BACKOFF_BASE_SEC:-20}"
RESTART_FAILURE_BACKOFF_MAX_SEC="${RESTART_FAILURE_BACKOFF_MAX_SEC:-300}"
RUN_LOCK_DIR="$WORK_DIR/.guardian_run.lock"
RUN_LOCK_STALE_SEC="${RUN_LOCK_STALE_SEC:-600}"
DAEMON_LOCK_DIR="$WORK_DIR/.guardian_daemon.lock"
DAEMON_LOCK_STALE_SEC="${GUARDIAN_DAEMON_LOCK_STALE_SEC:-600}"
DAEMON_LOCK_PREEMPT_MIN_SEC="${GUARDIAN_DAEMON_LOCK_PREEMPT_MIN_SEC:-30}"
DAEMON_STATE_FILE="$WORK_DIR/i18n/status/guardian_daemon_state.json"

export HOME="/home/ptaku"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export GIT_TRACK_BRANCH

cd "$WORK_DIR" || exit 1

log_guardian() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$GUARDIAN_LOG"
}

GUARDIAN_PID_FILE="$WORK_DIR/.guardian.pid"

truthy() {
    local v="${1:-}"
    case "${v,,}" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

daemon_source_priority() {
    case "${1:-unknown}" in
        start_all) echo "400" ;;
        service|systemd) echo "350" ;;
        scheduler|cron) echo "300" ;;
        manual) echo "100" ;;
        *) echo "50" ;;
    esac
}

acquire_run_lock() {
    local now_ts lock_ts owner_pid lock_age
    if mkdir "$RUN_LOCK_DIR" 2>/dev/null; then
        echo "$$" > "$RUN_LOCK_DIR/pid"
        date +%s > "$RUN_LOCK_DIR/ts"
        return 0
    fi

    owner_pid=$(cat "$RUN_LOCK_DIR/pid" 2>/dev/null || echo "")
    lock_ts=$(cat "$RUN_LOCK_DIR/ts" 2>/dev/null || echo "0")
    now_ts=$(date +%s)
    lock_age=$(( now_ts - ${lock_ts:-0} ))

    if [ -n "$owner_pid" ] && ps -p "$owner_pid" >/dev/null 2>&1 && [ "$lock_age" -lt "$RUN_LOCK_STALE_SEC" ]; then
        log_guardian "⏭️ Pomijam run_once: aktywny lock (pid=$owner_pid, age=${lock_age}s)"
        return 1
    fi

    rm -rf "$RUN_LOCK_DIR" 2>/dev/null || true
    if mkdir "$RUN_LOCK_DIR" 2>/dev/null; then
        echo "$$" > "$RUN_LOCK_DIR/pid"
        date +%s > "$RUN_LOCK_DIR/ts"
        log_guardian "🧹 Przejęto stale run-lock guardiana (old_pid=${owner_pid:-?}, age=${lock_age}s)"
        return 0
    fi

    log_guardian "⏭️ Pomijam run_once: nie udało się przejąć run-lock"
    return 1
}

release_run_lock() {
    local owner_pid
    [ -d "$RUN_LOCK_DIR" ] || return 0
    owner_pid=$(cat "$RUN_LOCK_DIR/pid" 2>/dev/null || echo "")
    if [ "$owner_pid" = "$$" ]; then
        rm -rf "$RUN_LOCK_DIR" 2>/dev/null || true
    fi
}

write_daemon_state() {
    local state="${1:-unknown}"
    local source="${2:-unknown}"
    local pid="${3:-0}"
    local reason="${4:-}"
    local owner_pid="${5:-}"
    local owner_source="${6:-}"
    local lock_age="${7:-0}"
    python3 - "$DAEMON_STATE_FILE" "$state" "$source" "$pid" "$reason" "$owner_pid" "$owner_source" "$lock_age" <<'PYDSTATE'
import json, os, sys
from datetime import datetime, timezone

path = sys.argv[1]
state = sys.argv[2]
source = sys.argv[3]
pid = sys.argv[4]
reason = sys.argv[5]
owner_pid = sys.argv[6]
owner_source = sys.argv[7]
lock_age = sys.argv[8]

def _to_int(v, default=0):
    try:
        return int(float(v))
    except Exception:
        return int(default)

payload = {
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "state": str(state or "unknown"),
    "source": str(source or "unknown"),
    "pid": _to_int(pid, 0),
    "reason": str(reason or ""),
    "owner_pid": _to_int(owner_pid, 0),
    "owner_source": str(owner_source or ""),
    "lock_age_sec": _to_int(lock_age, 0),
}

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2, ensure_ascii=False)
PYDSTATE
}

acquire_daemon_lock() {
    local source="${1:-manual}"
    local now_ts lock_ts owner_pid owner_source lock_age
    local source_prio owner_prio

    if mkdir "$DAEMON_LOCK_DIR" 2>/dev/null; then
        echo "$$" > "$DAEMON_LOCK_DIR/pid"
        date +%s > "$DAEMON_LOCK_DIR/ts"
        echo "$source" > "$DAEMON_LOCK_DIR/source"
        write_daemon_state "running" "$source" "$$" "lock_acquired" "" "" "0"
        return 0
    fi

    owner_pid=$(cat "$DAEMON_LOCK_DIR/pid" 2>/dev/null || echo "")
    owner_source=$(cat "$DAEMON_LOCK_DIR/source" 2>/dev/null || echo "unknown")
    lock_ts=$(cat "$DAEMON_LOCK_DIR/ts" 2>/dev/null || echo "0")
    now_ts=$(date +%s)
    lock_age=$(( now_ts - ${lock_ts:-0} ))
    source_prio=$(daemon_source_priority "$source")
    owner_prio=$(daemon_source_priority "$owner_source")

    if [ -n "$owner_pid" ] && ps -p "$owner_pid" >/dev/null 2>&1; then
        log_guardian "⏭️ Guardian daemon już działa (pid=$owner_pid, source=$owner_source, age=${lock_age}s)"
        write_daemon_state "blocked" "$source" "$$" "active_daemon_lock" "$owner_pid" "$owner_source" "$lock_age"
        return 1
    fi

    # Świeży lock po padniętym ownerze: źródła o niższym priorytecie nie mogą
    # przejąć daemona (chroni przed późnym/manualnym przejęciem po start_all).
    if [ "$lock_age" -lt "$DAEMON_LOCK_STALE_SEC" ]; then
        if [ "$source_prio" -le "$owner_prio" ]; then
            log_guardian "⏭️ Pomijam start daemona: świeży lock owner_source=$owner_source(prio=$owner_prio) > source=$source(prio=$source_prio), age=${lock_age}s"
            write_daemon_state "blocked" "$source" "$$" "fresh_lock_source_priority" "$owner_pid" "$owner_source" "$lock_age"
            return 1
        fi
        if [ "$lock_age" -lt "$DAEMON_LOCK_PREEMPT_MIN_SEC" ]; then
            log_guardian "⏭️ Pomijam start daemona: preempt cooldown (${lock_age}s < ${DAEMON_LOCK_PREEMPT_MIN_SEC}s) source=$source owner_source=$owner_source"
            write_daemon_state "blocked" "$source" "$$" "fresh_lock_preempt_cooldown" "$owner_pid" "$owner_source" "$lock_age"
            return 1
        fi
    fi

    rm -rf "$DAEMON_LOCK_DIR" 2>/dev/null || true
    if mkdir "$DAEMON_LOCK_DIR" 2>/dev/null; then
        echo "$$" > "$DAEMON_LOCK_DIR/pid"
        date +%s > "$DAEMON_LOCK_DIR/ts"
        echo "$source" > "$DAEMON_LOCK_DIR/source"
        log_guardian "🧹 Przejęto stale daemon-lock guardiana (old_pid=${owner_pid:-?}, source=${owner_source:-?}, age=${lock_age}s)"
        write_daemon_state "running" "$source" "$$" "stale_lock_recovered" "$owner_pid" "$owner_source" "$lock_age"
        return 0
    fi

    log_guardian "⏭️ Pomijam start daemona: nie udało się przejąć daemon-lock"
    write_daemon_state "blocked" "$source" "$$" "daemon_lock_unavailable" "$owner_pid" "$owner_source" "$lock_age"
    return 1
}

release_daemon_lock() {
    local source="${1:-manual}"
    local owner_pid owner_source
    [ -d "$DAEMON_LOCK_DIR" ] || return 0
    owner_pid=$(cat "$DAEMON_LOCK_DIR/pid" 2>/dev/null || echo "")
    owner_source=$(cat "$DAEMON_LOCK_DIR/source" 2>/dev/null || echo "")
    if [ "$owner_pid" = "$$" ]; then
        rm -rf "$DAEMON_LOCK_DIR" 2>/dev/null || true
        write_daemon_state "stopped" "$source" "$$" "daemon_exit" "$owner_pid" "$owner_source" "0"
    fi
}

load_guardian_profile() {
    RUN_MODE="translations_general"
    RUN_BATCH="20"
    RUN_DELAY="4"
    RUN_USE_GT="true"
    RUN_NO_GIT="true"
    RUN_TRANSLATIONS_ONLY="true"
    RUN_LANGS=""
    RUN_TRANSLATE_LIMIT="80"
    RUN_PARALLEL_LANGS="2"
    RUN_AUTO_MODE_ON_MIGRATION_PENDING="true"
    RUN_GLOBAL_QUALITY_MODE="true"
    RUN_GLOBAL_QUALITY_COVERAGE_TARGET="100"
    RUN_GLOBAL_QUALITY_SCORE_TARGET="100"
    RUN_GLOBAL_QUALITY_MAX_CRITICAL="0"
    RUN_GLOBAL_QUALITY_PRIORITY_LANGS="es pl"
    RUN_GLOBAL_QUALITY_PRIORITY_GATE_ENABLED="true"
    RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL="15"
    RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT="80"

    [ ! -f "$PROFILE_FILE" ] && return 0

    local parsed
    parsed=$(python3 - "$PROFILE_FILE" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding='utf-8') as f:
        d = json.load(f)
except Exception:
    d = {}

def out(k, v):
    if v is None:
        return
    print(f"{k}={v}")

out('RUN_MODE', d.get('mode'))
out('RUN_BATCH', d.get('batch'))
out('RUN_DELAY', d.get('delay'))
out('RUN_USE_GT', str(d.get('use_gt')).lower() if 'use_gt' in d else None)
out('RUN_NO_GIT', str(d.get('no_git')).lower() if 'no_git' in d else None)
out('RUN_TRANSLATIONS_ONLY', str(d.get('translations_only')).lower() if 'translations_only' in d else None)
out('RUN_LANGS', d.get('langs'))
out('RUN_TRANSLATE_LIMIT', d.get('translate_limit'))
out('RUN_PARALLEL_LANGS', d.get('parallel_langs'))
out('RUN_AUTO_MODE_ON_MIGRATION_PENDING', str(d.get('auto_mode_on_migration_pending')).lower() if 'auto_mode_on_migration_pending' in d else None)
out('RUN_GLOBAL_QUALITY_MODE', str(d.get('global_quality_mode')).lower() if 'global_quality_mode' in d else None)
out('RUN_GLOBAL_QUALITY_COVERAGE_TARGET', d.get('global_quality_coverage_target'))
out('RUN_GLOBAL_QUALITY_SCORE_TARGET', d.get('global_quality_score_target'))
out('RUN_GLOBAL_QUALITY_MAX_CRITICAL', d.get('global_quality_max_critical'))
out('RUN_GLOBAL_QUALITY_PRIORITY_LANGS', d.get('global_quality_priority_langs'))
out('RUN_GLOBAL_QUALITY_PRIORITY_GATE_ENABLED', str(d.get('global_quality_priority_gate_enabled')).lower() if 'global_quality_priority_gate_enabled' in d else None)
out('RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL', d.get('global_quality_lang_validation_interval'))
out('RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT', d.get('global_quality_crossref_auto_fix_limit'))
PY
)

    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        case "$key" in
            RUN_MODE) RUN_MODE="$value" ;;
            RUN_BATCH) RUN_BATCH="$value" ;;
            RUN_DELAY) RUN_DELAY="$value" ;;
            RUN_USE_GT) RUN_USE_GT="$value" ;;
            RUN_NO_GIT) RUN_NO_GIT="$value" ;;
            RUN_TRANSLATIONS_ONLY) RUN_TRANSLATIONS_ONLY="$value" ;;
            RUN_LANGS) RUN_LANGS="$value" ;;
            RUN_TRANSLATE_LIMIT) RUN_TRANSLATE_LIMIT="$value" ;;
            RUN_PARALLEL_LANGS) RUN_PARALLEL_LANGS="$value" ;;
            RUN_AUTO_MODE_ON_MIGRATION_PENDING) RUN_AUTO_MODE_ON_MIGRATION_PENDING="$value" ;;
            RUN_GLOBAL_QUALITY_MODE) RUN_GLOBAL_QUALITY_MODE="$value" ;;
            RUN_GLOBAL_QUALITY_COVERAGE_TARGET) RUN_GLOBAL_QUALITY_COVERAGE_TARGET="$value" ;;
            RUN_GLOBAL_QUALITY_SCORE_TARGET) RUN_GLOBAL_QUALITY_SCORE_TARGET="$value" ;;
            RUN_GLOBAL_QUALITY_MAX_CRITICAL) RUN_GLOBAL_QUALITY_MAX_CRITICAL="$value" ;;
            RUN_GLOBAL_QUALITY_PRIORITY_LANGS) RUN_GLOBAL_QUALITY_PRIORITY_LANGS="$value" ;;
            RUN_GLOBAL_QUALITY_PRIORITY_GATE_ENABLED) RUN_GLOBAL_QUALITY_PRIORITY_GATE_ENABLED="$value" ;;
            RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL) RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL="$value" ;;
            RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT) RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT="$value" ;;
        esac
    done <<< "$parsed"
}

# ── load_named_profile: wczytaj profil z guardian_profiles/<name>.json ──────
# Jeśli plik istnieje, nadpisuje bieżący guardian_profile.json i wczytuje go.
load_named_profile() {
    local name="${1:-}"
    [ -z "$name" ] && return 1
    local src="$PROFILES_DIR/${name}.json"
    [ ! -f "$src" ] && { log_guardian "⚠️ Profil '$name' nie znaleziony: $src"; return 1; }
    cp "$src" "$PROFILE_FILE"
    log_guardian "🔄 Załadowano profil '$name' z $src"
    load_guardian_profile
    return 0
}

# ── list_available_profiles ─────────────────────────────────────────────────
list_available_profiles() {
    local profiles=()
    if [ -d "$PROFILES_DIR" ]; then
        for f in "$PROFILES_DIR"/*.json; do
            [ -f "$f" ] || continue
            profiles+=("$(basename "$f" .json)")
        done
    fi
    echo "${profiles[*]}"
}

# ── auto_select_profile: policy engine dla mode=auto ────────────────────────
# Czyta metryki runtime i wybiera najlepszy profil.
# Zapisuje stan przejścia do POLICY_STATE_FILE.
auto_select_profile() {
    local selected
    selected=$(python3 - "$WORK_DIR" "$PROFILES_DIR" "$POLICY_STATE_FILE" <<'PYPOLICY'
import json, sys, os
from datetime import datetime, timezone, timedelta

work_dir = sys.argv[1]
profiles_dir = sys.argv[2]
policy_state_file = sys.argv[3]

now = datetime.now(timezone.utc)

# ── Load auto policy config ───────────────────────────────────────────────
auto_profile_path = os.path.join(profiles_dir, "auto.json")
policy_cfg = {}
try:
    with open(auto_profile_path, encoding="utf-8") as f:
        d = json.load(f)
    policy_cfg = d.get("auto_policy", {})
except Exception:
    pass

default_profile = policy_cfg.get("default_profile", "translations_general")

# ── Load previous policy state (cooldowns) ────────────────────────────────
prev_state = {}
try:
    with open(policy_state_file, encoding="utf-8") as f:
        prev_state = json.load(f)
except Exception:
    pass

def _cooldown_ok(profile_name: str, cooldown_min: int) -> bool:
    """Check if enough time has passed since last activation of this profile."""
    last_ts = prev_state.get(f"last_{profile_name}_ts", "")
    if not last_ts:
        return True
    try:
        last_dt = datetime.fromisoformat(last_ts.replace("Z", "+00:00"))
        return (now - last_dt).total_seconds() >= cooldown_min * 60
    except Exception:
        return True

# ── 1. Check quality_repair trigger ───────────────────────────────────────
qr_cfg = policy_cfg.get("quality_repair_trigger", {})
qr_gf_above = qr_cfg.get("guard_fail_rate_above_pct", 20)
qr_min_entries = qr_cfg.get("min_entries_to_evaluate", 30)
qr_cooldown = qr_cfg.get("cooldown_minutes", 60)

guard_file = os.path.join(work_dir, "i18n/status/translation_guard_report.jsonl")
try:
    entries = []
    with open(guard_file, encoding="utf-8") as f:
        for line in f:
            try:
                entries.append(json.loads(line.strip()))
            except Exception:
                continue
    recent = entries[-qr_min_entries:] if len(entries) >= qr_min_entries else entries
    total_t = sum(e.get("translated", 0) for e in recent)
    total_gf = sum(e.get("guard_fail", 0) for e in recent)
    gf_rate = total_gf / max(total_t + total_gf, 1) * 100
    if gf_rate > qr_gf_above and len(recent) >= qr_min_entries and _cooldown_ok("quality_repair", qr_cooldown):
        print("quality_repair")
        # Save state
        prev_state["last_quality_repair_ts"] = now.isoformat().replace("+00:00", "Z")
        prev_state["last_decision"] = "quality_repair"
        prev_state["last_decision_reason"] = f"guard_fail_rate={gf_rate:.1f}% > {qr_gf_above}%"
        prev_state["last_decision_ts"] = now.isoformat().replace("+00:00", "Z")
        with open(policy_state_file, "w", encoding="utf-8") as f:
            json.dump(prev_state, f, indent=2, ensure_ascii=False)
        raise SystemExit(0)
except Exception as e:
    if "quality_repair" in str(e):
        raise SystemExit(0)

# ── 2. Check migration trigger ────────────────────────────────────────────
mig_cfg = policy_cfg.get("migration_trigger", {})
mig_cooldown = mig_cfg.get("cooldown_minutes", 30)

cat_state_file = os.path.join(work_dir, ".i18n_category_state.json")
migrations_pending = False
try:
    with open(cat_state_file, encoding="utf-8") as f:
        cs = json.load(f)
    migrations_pending = not bool(cs.get("migrations_done", False))
except Exception:
    pass

if migrations_pending and _cooldown_ok("migration_only", mig_cooldown):
    print("migration_only")
    prev_state["last_migration_only_ts"] = now.isoformat().replace("+00:00", "Z")
    prev_state["last_decision"] = "migration_only"
    prev_state["last_decision_reason"] = "pending_migrations_exist"
    prev_state["last_decision_ts"] = now.isoformat().replace("+00:00", "Z")
    with open(policy_state_file, "w", encoding="utf-8") as f:
        json.dump(prev_state, f, indent=2, ensure_ascii=False)
    raise SystemExit(0)

# ── 3. Check translations_random trigger (pilot coverage high enough) ─────
tr_cfg = policy_cfg.get("translations_random_trigger", {})
tr_coverage_above = tr_cfg.get("pilot_coverage_above_pct", 85)
tr_cooldown = tr_cfg.get("cooldown_minutes", 120)
tr_gf_below = tr_cfg.get("guard_fail_rate_below_pct", 8)
tr_np_below = tr_cfg.get("no_progress_rate_below_pct", 1)
tr_identical_below = tr_cfg.get("identical_to_en_translatable_below_pct", 5)

try:
    overview_file = os.path.join(work_dir, "i18n/status/translation_global_overview.json")
    with open(overview_file, encoding="utf-8") as f:
        overview = json.load(f)
    lang_rows = overview.get("languages", [])
    lang_map = {}
    if isinstance(lang_rows, list):
        for row in lang_rows:
            if not isinstance(row, dict):
                continue
            code = str(row.get("lang", "")).lower().strip()
            if not code:
                continue
            lang_map[code] = row
    pl_cov = float((lang_map.get("pl", {}) or {}).get("completion_pct", 0) or 0)
    es_cov = float((lang_map.get("es", {}) or {}).get("completion_pct", 0) or 0)
    min_pilot_cov = min(pl_cov, es_cov)
    strict = overview.get("strict_hourly_window", {})
    gf_rate = float(strict.get("guard_fail_rate_pct", 999) or 999)
    no_progress_rate = float(strict.get("no_progress_rate_pct", 999) or 999)
    qa_file = os.path.join(work_dir, "i18n/status/quality_audit_latest.json")
    qa_checked = 0.0
    qa_identical_translatable = 9999.0
    qa_identical_pct = 999.0
    try:
        with open(qa_file, encoding="utf-8") as f:
            qa = json.load(f)
        qa_checked = float(qa.get("checked_entries", 0) or 0)
        issues_by_type = qa.get("issues_by_type", {})
        if isinstance(issues_by_type, dict):
            qa_identical_translatable = float(issues_by_type.get("identical_to_en", 0) or 0)
        if qa_checked > 0:
            qa_identical_pct = (qa_identical_translatable / qa_checked) * 100.0
    except Exception:
        pass
    rollout_ready = (
        min_pilot_cov >= tr_coverage_above and
        gf_rate <= tr_gf_below and
        no_progress_rate <= tr_np_below and
        qa_checked > 0 and
        qa_identical_pct <= tr_identical_below
    )
    if rollout_ready and _cooldown_ok("translations_random", tr_cooldown):
        print("translations_random")
        prev_state["last_translations_random_ts"] = now.isoformat().replace("+00:00", "Z")
        prev_state["last_decision"] = "translations_random"
        prev_state["last_decision_reason"] = (
            f"pilot_coverage_min={min_pilot_cov:.1f}% >= {tr_coverage_above}%, "
            f"guard_fail_rate={gf_rate:.1f}% <= {tr_gf_below}%, "
            f"no_progress_rate={no_progress_rate:.1f}% <= {tr_np_below}%, "
            f"identical_to_en_translatable={qa_identical_pct:.1f}% <= {tr_identical_below}%"
        )
        prev_state["last_decision_ts"] = now.isoformat().replace("+00:00", "Z")
        with open(policy_state_file, "w", encoding="utf-8") as f:
            json.dump(prev_state, f, indent=2, ensure_ascii=False)
        raise SystemExit(0)
except Exception as e:
    if "translations_random" in str(e):
        raise SystemExit(0)

# ── 4. Default profile ───────────────────────────────────────────────────
print(default_profile)
prev_state["last_decision"] = default_profile
prev_state["last_decision_reason"] = "default_fallback"
prev_state["last_decision_ts"] = now.isoformat().replace("+00:00", "Z")
try:
    with open(policy_state_file, "w", encoding="utf-8") as f:
        json.dump(prev_state, f, indent=2, ensure_ascii=False)
except Exception:
    pass
PYPOLICY
)

    local chosen="${selected:-translations_pl_es}"
    log_guardian "🤖 Auto policy → profil '$chosen'"
    echo "$chosen"
}

has_pending_migration() {
    local state_file="$WORK_DIR/.i18n_category_state.json"
    [ ! -f "$state_file" ] && return 1

    python3 - "$state_file" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding='utf-8') as f:
        d = json.load(f)
except Exception:
    print("0")
    raise SystemExit(0)

print("1" if not bool(d.get("migrations_done", False)) else "0")
PY
}

build_worker_args() {
    load_guardian_profile

    local selected_mode="$RUN_MODE"

    # ── Tryb auto: policy engine wybiera profil ────────────────────────────
    if [ "$selected_mode" = "auto" ]; then
        local auto_chosen
        auto_chosen=$(auto_select_profile 2>/dev/null)
        if [ -n "$auto_chosen" ] && [ -f "$PROFILES_DIR/${auto_chosen}.json" ]; then
            load_named_profile "$auto_chosen"
            selected_mode="$RUN_MODE"
        else
            # Fallback: stary prosty mechanizm
            if truthy "$RUN_AUTO_MODE_ON_MIGRATION_PENDING"; then
                if [ "$(has_pending_migration 2>/dev/null || echo 0)" = "1" ]; then
                    selected_mode="migration"
                else
                    selected_mode="translations_general"
                fi
            else
                selected_mode="translations_general"
            fi
        fi
    fi

    WORKER_ARGS=(--continuous --batch "$RUN_BATCH" --delay "$RUN_DELAY")

    case "$selected_mode" in
        migration|migration_only)
            # Tryb migracji — bez --translations-only
            ;;
        translations_only)
            WORKER_ARGS+=(--translations-only)
            ;;
        translations_pl_es)
            WORKER_ARGS+=(--translations-only --langs "${RUN_LANGS:-pl,es}")
            ;;
        translations_general)
            WORKER_ARGS+=(--translations-only)
            # Bez --langs → worker przetwarza wszystkie języki wg tier rotation
            ;;
        translations_random)
            WORKER_ARGS+=(--translations-only)
            # Brak --langs → worker użyje losowej rotacji tierów
            ;;
        hybrid)
            # Tryb hybrydowy — bez --translations-only, ale z --langs
            if [ -n "$RUN_LANGS" ]; then
                WORKER_ARGS+=(--langs "$RUN_LANGS")
            fi
            ;;
        quality_repair)
            WORKER_ARGS+=(--translations-only --langs "${RUN_LANGS:-pl,es}")
            # Mniejszy batch i limit — worker skupia się na naprawie
            ;;
        *)
            log_guardian "⚠️ Nieznany mode '$selected_mode' w guardian_profile.json, fallback: translations_random"
            selected_mode="translations_random"
            WORKER_ARGS+=(--translations-only)
            ;;
    esac

    if truthy "$RUN_USE_GT"; then
        WORKER_ARGS+=(--use-gt)
    fi
    if truthy "$RUN_NO_GIT"; then
        WORKER_ARGS+=(--no-git)
    fi
    if [ -n "$RUN_TRANSLATE_LIMIT" ] && [ "$RUN_TRANSLATE_LIMIT" != "0" ]; then
        WORKER_ARGS+=(--translate-limit "$RUN_TRANSLATE_LIMIT")
    fi
    if [ -n "$RUN_PARALLEL_LANGS" ] && [ "$RUN_PARALLEL_LANGS" != "0" ]; then
        WORKER_ARGS+=(--parallel-langs "$RUN_PARALLEL_LANGS")
    fi

    WORKER_ENV_OVERRIDES=()
    if truthy "$RUN_GLOBAL_QUALITY_MODE"; then
        WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_MODE=true")
    else
        WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_MODE=false")
    fi
    [ -n "$RUN_GLOBAL_QUALITY_COVERAGE_TARGET" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_COVERAGE_TARGET=$RUN_GLOBAL_QUALITY_COVERAGE_TARGET")
    [ -n "$RUN_GLOBAL_QUALITY_SCORE_TARGET" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_SCORE_TARGET=$RUN_GLOBAL_QUALITY_SCORE_TARGET")
    [ -n "$RUN_GLOBAL_QUALITY_MAX_CRITICAL" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_MAX_CRITICAL=$RUN_GLOBAL_QUALITY_MAX_CRITICAL")
    [ -n "$RUN_GLOBAL_QUALITY_PRIORITY_LANGS" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_PRIORITY_LANGS=$RUN_GLOBAL_QUALITY_PRIORITY_LANGS")
    if truthy "$RUN_GLOBAL_QUALITY_PRIORITY_GATE_ENABLED"; then
        WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_PRIORITY_GATE_ENABLED=true")
    else
        WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_PRIORITY_GATE_ENABLED=false")
    fi
    [ -n "$RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL=$RUN_GLOBAL_QUALITY_LANG_VALIDATION_INTERVAL")
    [ -n "$RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT" ] && WORKER_ENV_OVERRIDES+=("GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT=$RUN_GLOBAL_QUALITY_CROSSREF_AUTO_FIX_LIMIT")
    [ -n "$RUN_GLOBAL_QUALITY_PRIORITY_LANGS" ] && WORKER_ENV_OVERRIDES+=("BOOTSTRAP_PRIORITY_LANGS=$RUN_GLOBAL_QUALITY_PRIORITY_LANGS")

    log_guardian "🧭 Profile mode=$selected_mode batch=$RUN_BATCH delay=$RUN_DELAY langs=${RUN_LANGS:-auto} gt=$RUN_USE_GT no_git=$RUN_NO_GIT global_quality=$RUN_GLOBAL_QUALITY_MODE priority_langs=${RUN_GLOBAL_QUALITY_PRIORITY_LANGS:-es pl}"
}

run_once() {
    if ! acquire_run_lock; then
        return 0
    fi
    trap 'release_run_lock' RETURN

restart_policy_precheck() {
    local cause="${1:-unknown}"
    python3 - "$RESTART_STATE_FILE" "$cause" "$(date +%s)" "$MTIME_RESTART_MIN_INTERVAL_SEC" <<'PYRSPRE'
import json, sys

state_path = sys.argv[1]
cause = sys.argv[2]
now_s = int(float(sys.argv[3]))
mtime_min = int(float(sys.argv[4]))

state = {}
try:
    with open(state_path, encoding="utf-8") as f:
        state = json.load(f)
except Exception:
    state = {}

next_allowed_ts = int(state.get("next_allowed_ts", 0) or 0)
last_restart_ts = int(state.get("last_restart_ts", 0) or 0)

allow = True
reason = "ok"
wait_sec = 0

if next_allowed_ts > now_s:
    allow = False
    reason = "failure_backoff"
    wait_sec = next_allowed_ts - now_s
elif cause == "mtime" and last_restart_ts > 0:
    elapsed = now_s - last_restart_ts
    if elapsed < mtime_min:
        allow = False
        reason = "mtime_debounce"
        wait_sec = mtime_min - elapsed

print(f"allow={1 if allow else 0}")
print(f"reason={reason}")
print(f"wait_sec={max(0, int(wait_sec))}")
PYRSPRE
}

restart_policy_record_event() {
    local mode="${1:-result}"         # blocked | result
    local cause="${2:-unknown}"
    local success="${3:-0}"           # 1 | 0 (for mode=result)
    local pid="${4:-}"
    local reason="${5:-}"
    local wait_sec="${6:-0}"          # for mode=blocked
    python3 - "$RESTART_STATE_FILE" "$RESTART_METRICS_FILE" "$mode" "$cause" "$success" "$pid" "$reason" "$wait_sec" "$(date +%s)" "$RESTART_FAILURE_BACKOFF_BASE_SEC" "$RESTART_FAILURE_BACKOFF_MAX_SEC" "$MTIME_RESTART_MIN_INTERVAL_SEC" <<'PYRSEVT'
import json, os, sys
from datetime import datetime, timezone

state_path = sys.argv[1]
metrics_path = sys.argv[2]
mode = sys.argv[3]
cause = sys.argv[4]
success_raw = sys.argv[5]
pid = sys.argv[6]
reason = sys.argv[7]
wait_raw = sys.argv[8]
now_s = int(float(sys.argv[9]))
backoff_base = max(1, int(float(sys.argv[10])))
backoff_max = max(backoff_base, int(float(sys.argv[11])))
mtime_min = max(0, int(float(sys.argv[12])))

def _iso(ts: int) -> str:
    return datetime.fromtimestamp(int(ts), tz=timezone.utc).isoformat().replace("+00:00", "Z")

def _to_int(value, default=0):
    try:
        return int(value)
    except Exception:
        return int(default)

def _default_state():
    return {
        "schema_version": "1.0",
        "last_restart_ts": 0,
        "last_restart_cause": "",
        "last_restart_success": None,
        "last_restart_pid": "",
        "failure_streak": 0,
        "next_allowed_ts": 0,
        "totals": {
            "attempts": 0,
            "successes": 0,
            "failures": 0,
            "blocked": 0,
        },
        "causes": {},
        "recent_events": [],
    }

state = _default_state()
try:
    with open(state_path, encoding="utf-8") as f:
        loaded = json.load(f)
    if isinstance(loaded, dict):
        state.update({k: v for k, v in loaded.items() if k in state})
except Exception:
    pass

if not isinstance(state.get("totals"), dict):
    state["totals"] = {"attempts": 0, "successes": 0, "failures": 0, "blocked": 0}
for k in ("attempts", "successes", "failures", "blocked"):
    state["totals"][k] = _to_int(state["totals"].get(k, 0), 0)

if not isinstance(state.get("causes"), dict):
    state["causes"] = {}
if not isinstance(state.get("recent_events"), list):
    state["recent_events"] = []

def _cause_record(name: str):
    rec = state["causes"].get(name)
    if not isinstance(rec, dict):
        rec = {"attempts": 0, "successes": 0, "failures": 0, "blocked": 0}
    for k in ("attempts", "successes", "failures", "blocked"):
        rec[k] = _to_int(rec.get(k, 0), 0)
    state["causes"][name] = rec
    return rec

event = {
    "timestamp": _iso(now_s),
    "type": mode,
    "cause": cause,
}

if mode == "blocked":
    wait_sec = max(0, _to_int(wait_raw, 0))
    state["totals"]["blocked"] += 1
    crec = _cause_record(cause)
    crec["blocked"] += 1
    event["reason"] = reason or "blocked"
    event["wait_sec"] = wait_sec
elif mode == "result":
    ok = str(success_raw).strip() in ("1", "true", "True", "yes")
    state["totals"]["attempts"] += 1
    crec = _cause_record(cause)
    crec["attempts"] += 1
    state["last_restart_ts"] = now_s
    state["last_restart_cause"] = cause
    state["last_restart_success"] = bool(ok)
    state["last_restart_pid"] = str(pid or "")

    if ok:
        state["totals"]["successes"] += 1
        crec["successes"] += 1
        state["failure_streak"] = 0
        state["next_allowed_ts"] = 0
        event["success"] = True
        event["pid"] = str(pid or "")
        event["reason"] = reason or "started"
        event["backoff_sec"] = 0
    else:
        state["totals"]["failures"] += 1
        crec["failures"] += 1
        failure_streak = _to_int(state.get("failure_streak", 0), 0) + 1
        state["failure_streak"] = failure_streak
        backoff_sec = min(backoff_max, backoff_base * (2 ** max(0, failure_streak - 1)))
        state["next_allowed_ts"] = now_s + int(backoff_sec)
        event["success"] = False
        event["pid"] = ""
        event["reason"] = reason or "start_failed"
        event["backoff_sec"] = int(backoff_sec)
else:
    event["reason"] = "unknown_mode"

state["recent_events"].append(event)
state["recent_events"] = state["recent_events"][-120:]

state["failure_streak"] = _to_int(state.get("failure_streak", 0), 0)
state["next_allowed_ts"] = _to_int(state.get("next_allowed_ts", 0), 0)
state["last_restart_ts"] = _to_int(state.get("last_restart_ts", 0), 0)

os.makedirs(os.path.dirname(state_path), exist_ok=True)
with open(state_path, "w", encoding="utf-8") as f:
    json.dump(state, f, indent=2, ensure_ascii=False)

cooldown_remaining_sec = max(0, state["next_allowed_ts"] - now_s)
metrics = {
    "schema_version": "1.0",
    "generated_at_utc": _iso(now_s),
    "config": {
        "mtime_restart_min_interval_sec": mtime_min,
        "restart_failure_backoff_base_sec": backoff_base,
        "restart_failure_backoff_max_sec": backoff_max,
    },
    "last_restart": {
        "timestamp": _iso(state["last_restart_ts"]) if state["last_restart_ts"] > 0 else "",
        "cause": state.get("last_restart_cause", ""),
        "success": state.get("last_restart_success"),
        "pid": state.get("last_restart_pid", ""),
    },
    "failure_streak": state["failure_streak"],
    "cooldown_active": cooldown_remaining_sec > 0,
    "cooldown_remaining_sec": cooldown_remaining_sec,
    "next_allowed_utc": _iso(state["next_allowed_ts"]) if state["next_allowed_ts"] > 0 else "",
    "totals": state["totals"],
    "causes": state["causes"],
    "recent_events": state["recent_events"][-20:],
}
os.makedirs(os.path.dirname(metrics_path), exist_ok=True)
with open(metrics_path, "w", encoding="utf-8") as f:
    json.dump(metrics, f, indent=2, ensure_ascii=False)
PYRSEVT
}

sync_worker_mtime_checkpoint() {
    local current_mtime
    current_mtime=$(stat -c %Y "$WORK_DIR/$WORKER_SCRIPT" 2>/dev/null || echo "")
    if [ -n "$current_mtime" ]; then
        echo "$current_mtime" > "$MTIME_FILE"
    fi
}

restart_worker() {
    local cause="${1:-unknown}"
    local precheck allow reason wait_sec
    precheck=$(restart_policy_precheck "$cause")
    allow="0"
    reason="unknown"
    wait_sec="0"
    while IFS='=' read -r k v; do
        case "$k" in
            allow) allow="$v" ;;
            reason) reason="$v" ;;
            wait_sec) wait_sec="$v" ;;
        esac
    done <<< "$precheck"

    if [ "$allow" != "1" ]; then
        log_guardian "⏳ Restart pominięty (cause=$cause, reason=$reason, wait=${wait_sec}s)"
        restart_policy_record_event "blocked" "$cause" "0" "" "$reason" "$wait_sec"
        return 1
    fi

    log_guardian "⚠️ Restart workera... cause=$cause"
    pkill -9 -f "$WORKER_SCRIPT" 2>/dev/null
    sleep 1
    # Czyść locki workera — inaczej nowy worker odmówi startu ("Inny worker już działa")
    rm -f "$PID_FILE" "$WORK_DIR/.worker_simple.start.lock" "$WORK_DIR/i18n_worker_continuous.pid"
    build_worker_args
    nohup env "${WORKER_ENV_OVERRIDES[@]}" bash "$WORK_DIR/$WORKER_SCRIPT" "${WORKER_ARGS[@]}" >> "$LOG_FILE" 2>&1 &
    sleep 4
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
            log_guardian "✅ Worker uruchomiony PID: $pid"
            restart_policy_record_event "result" "$cause" "1" "$pid" "pid_file" "0"
            sync_worker_mtime_checkpoint
            return 0
        fi
    fi

    local fallback_pid
    fallback_pid=$(pgrep -n -f "$WORKER_SCRIPT --continuous" 2>/dev/null || true)
    if [ -n "$fallback_pid" ] && ps -p "$fallback_pid" >/dev/null 2>&1; then
        echo "$fallback_pid" > "$PID_FILE"
        log_guardian "✅ Worker uruchomiony PID: $fallback_pid (fallback pgrep)"
        restart_policy_record_event "result" "$cause" "1" "$fallback_pid" "fallback_pgrep" "0"
        sync_worker_mtime_checkpoint
        return 0
    else
        log_guardian "❌ Worker nie wystartował prawidłowo"
        restart_policy_record_event "result" "$cause" "0" "" "start_failed" "0"
        return 1
    fi
}

# Sprawdź czy worker działa przez PID file
worker_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# ── Health check: heartbeat, postęp, guard_fail trend ──────────────────────
# Zwraca: healthy | degraded | stuck
# Zapisuje metryki do guardian_health.json
HEALTH_STATE_FILE="$WORK_DIR/.guardian_health_state"
HEARTBEAT_AGING_SECONDS="${GUARDIAN_HEARTBEAT_AGING_SECONDS:-150}"
HEARTBEAT_STALE_SECONDS="${GUARDIAN_HEARTBEAT_STALE_SECONDS:-240}"
HEARTBEAT_STUCK_SECONDS="${GUARDIAN_HEARTBEAT_STUCK_SECONDS:-420}"
HEARTBEAT_ACTIVE_LOG_GRACE_SECONDS="${GUARDIAN_HEARTBEAT_ACTIVE_LOG_GRACE_SECONDS:-150}"
STUCK_WINDOW_MINUTES="${GUARDIAN_STUCK_WINDOW_MINUTES:-15}"
GUARD_FAIL_RATE_ALERT="${GUARDIAN_GUARD_FAIL_RATE_ALERT:-15}"

check_worker_health() {
    local health
    health=$(python3 - "$WORK_DIR" "$HEARTBEAT_AGING_SECONDS" "$HEARTBEAT_STALE_SECONDS" "$HEARTBEAT_STUCK_SECONDS" "$HEARTBEAT_ACTIVE_LOG_GRACE_SECONDS" "$STUCK_WINDOW_MINUTES" "$GUARD_FAIL_RATE_ALERT" "$PID_FILE" "$LOG_FILE" <<'PYHEALTH'
import json, sys, os
from collections import deque
from datetime import datetime, timezone, timedelta

work_dir = sys.argv[1]
heartbeat_aging_s = int(sys.argv[2])
heartbeat_stale_s = int(sys.argv[3])
heartbeat_stuck_s = int(sys.argv[4])
active_log_grace_s = int(sys.argv[5])
stuck_window_min = int(sys.argv[6])
gf_rate_alert = int(sys.argv[7])
pid_file = sys.argv[8]
worker_log_file = sys.argv[9]

state_file = os.path.join(work_dir, "i18n/status/worker_state.json")
guard_file = os.path.join(work_dir, "i18n/status/translation_guard_report.jsonl")
health_file = os.path.join(work_dir, "i18n/status/guardian_health.json")

def _to_float(v, default=-1.0):
    try:
        return float(v)
    except Exception:
        return float(default)

def _get_tail_lines(path, n=200):
    try:
        with open(path, encoding="utf-8") as f:
            return list(deque(f, maxlen=max(int(n), 1)))
    except Exception:
        return []

now = datetime.now(timezone.utc)
issues = []
state = "healthy"
worker_pid = ""
pid_alive = False
worker_log_age_s = -1.0
guard_last_entry_age_s = -1.0
recent_activity_reasons = []
guard_tail_lines = _get_tail_lines(guard_file, 200)

try:
    with open(pid_file, encoding="utf-8") as f:
        worker_pid = f.read().strip()
    if worker_pid.isdigit() and os.path.exists(f"/proc/{worker_pid}"):
        pid_alive = True
except Exception:
    worker_pid = ""

try:
    if os.path.exists(worker_log_file):
        mtime = datetime.fromtimestamp(os.path.getmtime(worker_log_file), tz=timezone.utc)
        worker_log_age_s = (now - mtime).total_seconds()
except Exception:
    worker_log_age_s = -1.0

try:
    last_guard_dt = None
    for line in guard_tail_lines:
        try:
            entry = json.loads(line)
            ts_str = entry.get("timestamp", "")
            if not ts_str:
                continue
            ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            if last_guard_dt is None or ts > last_guard_dt:
                last_guard_dt = ts
        except Exception:
            continue
    if last_guard_dt is not None:
        guard_last_entry_age_s = (now - last_guard_dt).total_seconds()
except Exception:
    guard_last_entry_age_s = -1.0

# ── 1. Heartbeat age ────────────────────────────────────────────────────────
heartbeat_age_s = -1
try:
    with open(state_file, encoding="utf-8") as f:
        ws = json.load(f)
    hb_str = ws.get("worker", {}).get("heartbeat_at_utc") or ws.get("generated_at_utc", "")
    if hb_str:
        hb_dt = datetime.fromisoformat(hb_str.replace("Z", "+00:00"))
        heartbeat_age_s = (now - hb_dt).total_seconds()
        if heartbeat_age_s > heartbeat_stuck_s:
            if worker_log_age_s >= 0 and worker_log_age_s <= active_log_grace_s:
                recent_activity_reasons.append(f"log_age={worker_log_age_s:.0f}s")
            if guard_last_entry_age_s >= 0 and guard_last_entry_age_s <= active_log_grace_s:
                recent_activity_reasons.append(f"guard_age={guard_last_entry_age_s:.0f}s")
            if pid_alive and recent_activity_reasons:
                issues.append(
                    f"heartbeat_stale_but_active ({heartbeat_age_s:.0f}s > {heartbeat_stuck_s}s; "
                    + ", ".join(recent_activity_reasons)
                    + ")"
                )
                if state == "healthy":
                    state = "degraded"
            else:
                issues.append(f"heartbeat_stale ({heartbeat_age_s:.0f}s > {heartbeat_stuck_s}s)")
                state = "stuck"
        elif heartbeat_age_s > heartbeat_stale_s:
            issues.append(f"heartbeat_stale_warning ({heartbeat_age_s:.0f}s > {heartbeat_stale_s}s)")
            if state == "healthy":
                state = "degraded"
        elif heartbeat_age_s > heartbeat_aging_s:
            issues.append(f"heartbeat_aging ({heartbeat_age_s:.0f}s)")
            if state == "healthy":
                state = "degraded"
except Exception as e:
    issues.append(f"heartbeat_read_error: {e}")
    state = "degraded"

# ── 2. Progress delta (last N guard entries in window) ───────────────────────
translated_window = 0
guard_fail_window = 0
entries_in_window = 0
try:
    cutoff = now - timedelta(minutes=stuck_window_min)
    for line in guard_tail_lines:
        try:
            entry = json.loads(line)
            ts_str = entry.get("timestamp", "")
            if not ts_str:
                continue
            ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            if ts >= cutoff:
                entries_in_window += 1
                translated_window += entry.get("translated", 0)
                guard_fail_window += entry.get("guard_fail", 0)
        except Exception:
            continue

    if entries_in_window >= 3 and translated_window == 0:
        issues.append(f"no_progress ({entries_in_window} entries, 0 translated in {stuck_window_min}min)")
        state = "stuck"
    elif entries_in_window == 0 and heartbeat_age_s > 60:
        issues.append(f"no_recent_entries (window={stuck_window_min}min)")
        if state == "healthy":
            state = "degraded"
except Exception as e:
    issues.append(f"progress_read_error: {e}")

# ── 3. Guard fail rate trend ────────────────────────────────────────────────
gf_rate_pct = 0.0
try:
    total_attempts = translated_window + guard_fail_window
    if total_attempts > 10:
        gf_rate_pct = guard_fail_window / total_attempts * 100
        if gf_rate_pct > gf_rate_alert:
            issues.append(f"high_guard_fail_rate ({gf_rate_pct:.1f}% > {gf_rate_alert}%)")
            if state == "healthy":
                state = "degraded"
except Exception:
    pass

# ── 3.5 Productivity watchdog (translated/h) ────────────────────────────────
throughput_per_h = 0.0
THROUGHPUT_MIN_PER_H = 50
try:
    if entries_in_window >= 3 and stuck_window_min > 0:
        throughput_per_h = translated_window / (stuck_window_min / 60.0)
        if throughput_per_h < THROUGHPUT_MIN_PER_H and translated_window > 0:
            issues.append(f"low_throughput ({throughput_per_h:.0f}/h < {THROUGHPUT_MIN_PER_H}/h)")
            if state == "healthy":
                state = "degraded"
except Exception:
    pass

# ── 4. Cycle count (from worker_state) ──────────────────────────────────────
worker_cycle = -1
try:
    worker_cycle = ws.get("worker", {}).get("cycle", -1)
except Exception:
    pass

# ── Save health report ──────────────────────────────────────────────────────
report = {
    "timestamp": now.isoformat().replace("+00:00", "Z"),
    "state": state,
    "heartbeat_age_s": round(heartbeat_age_s, 1),
    "heartbeat_aging_seconds": int(heartbeat_aging_s),
    "heartbeat_stale_seconds": int(heartbeat_stale_s),
    "heartbeat_stuck_seconds": int(heartbeat_stuck_s),
    "active_log_grace_seconds": int(active_log_grace_s),
    "worker_pid": worker_pid,
    "pid_alive": bool(pid_alive),
    "worker_log_age_s": round(_to_float(worker_log_age_s, -1.0), 1),
    "guard_last_entry_age_s": round(_to_float(guard_last_entry_age_s, -1.0), 1),
    "translated_window": translated_window,
    "guard_fail_window": guard_fail_window,
    "guard_fail_rate_pct": round(gf_rate_pct, 1),
    "throughput_per_h": round(throughput_per_h, 1),
    "entries_in_window": entries_in_window,
    "worker_cycle": worker_cycle,
    "issues": issues,
}
try:
    with open(health_file, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
except Exception:
    pass

print(state)
PYHEALTH
)

    echo "${health:-unknown}"
}

# Auto-restart jeśli zmienił się mtime skryptu workera
if [ -f "$WORK_DIR/$WORKER_SCRIPT" ]; then
    CURRENT_MTIME=$(stat -c %Y "$WORK_DIR/$WORKER_SCRIPT" 2>/dev/null || echo "")
    LAST_MTIME=$(cat "$MTIME_FILE" 2>/dev/null || echo "")
    if [ -n "$CURRENT_MTIME" ]; then
        if [ "$CURRENT_MTIME" != "$LAST_MTIME" ]; then
            log_guardian "🔄 Wykryto zmianę $WORKER_SCRIPT (mtime $LAST_MTIME -> $CURRENT_MTIME) - restart"
            # Zawsze aktualizuj mtime po wykryciu — debounce policy i tak kontroluje częstotliwość
            echo "$CURRENT_MTIME" > "$MTIME_FILE"
            restart_worker "mtime" || true
        else
            echo "$CURRENT_MTIME" > "$MTIME_FILE"
        fi
    fi
fi

# Restart workera jeśli nie działa
if ! worker_running; then
    log_guardian "⚠️ Worker nie działa - restartuję..."
    restart_worker "worker_missing"
    else
        # Worker działa — sprawdź zdrowie
        HEALTH=$(check_worker_health)
        PID=$(cat "$PID_FILE" 2>/dev/null)

        case "$HEALTH" in
            healthy)
                MINUTE=$((10#$(date +%M)))
                if [ $((MINUTE % 5)) -eq 0 ]; then
                    log_guardian "✓ Worker OK (PID: $PID) health=$HEALTH"
                fi
                ;;
            degraded)
                log_guardian "⚠️ Worker degraded (PID: $PID) — $(cat "$WORK_DIR/i18n/status/guardian_health.json" 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(", ".join(d.get("issues",[])))' 2>/dev/null || echo 'unknown')"
                ;;
            stuck)
                # Read previous state to implement cooldown
                PREV_HEALTH=$(cat "$HEALTH_STATE_FILE" 2>/dev/null || echo "healthy")
                if [ "$PREV_HEALTH" = "stuck" ]; then
                    log_guardian "🔴 Worker STUCK dwukrotnie (PID: $PID) — wymuszam restart"
                    restart_worker "health_stuck"
                else
                    log_guardian "🟡 Worker STUCK (PID: $PID) — czekam 1 cykl przed restartem — $(cat "$WORK_DIR/i18n/status/guardian_health.json" 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(", ".join(d.get("issues",[])))' 2>/dev/null || echo 'unknown')"
                fi
                ;;
            *)
                log_guardian "⚠️ Health check unknown (PID: $PID) — traktuję jak degraded"
                ;;
        esac

        echo "$HEALTH" > "$HEALTH_STATE_FILE"
    fi

# Co ~2 minuty - push dashboardu do GitHub (zależne od czasu, nie od minuty zegara)
now_ts=$(date +%s)
last_ts=$(cat "$LAST_PUSH_TS_FILE" 2>/dev/null || echo 0)
if [ "$last_ts" -eq 0 ] || [ $((now_ts - last_ts)) -ge "$PUSH_INTERVAL_SECONDS" ]; then
    # Zawsze odśwież dashboard tuż przed pushem
    cd "$WORK_DIR" || exit 1
    bash "$WORK_DIR/$WORKER_SCRIPT" --update-status >/dev/null 2>&1 || true

    # Git operations MUSZĄ być w repo root (PtakuPL/ooo)
    cd "$REPO_ROOT" || exit 1

        # Pobierz najnowsze komendy z GitHub bez robienia merge/pull (bezpieczne przy lokalnych zmianach)
        # Worker odczyta komendy z origin/master (git show) i zapisze ACK lokalnie.
        git fetch origin "$GIT_TRACK_BRANCH" -q 2>/dev/null || true

    # Staging TYLKO plików statusu (bez przypadkowego commitowania migracji/kodu)
        git add \
            I18N_STATUS.md \
            Tibia/silnik/canary_test/I18N_STATUS.md \
            Tibia/silnik/canary_test/.github/worker_commands.txt \
            Tibia/silnik/canary_test/worker_commands.txt \
            2>/dev/null || true

    if ! git diff --cached --quiet 2>/dev/null; then
        MIGRATED=$(python3 - <<'PY'
import json
try:
    d=json.load(open('Tibia/silnik/canary_test/i18n_file_status.json'))
    print(len([f for f,i in d.get('files',{}).items() if i.get('overall_status')=='completed']))
except Exception:
    print('?')
PY
)
        git commit -m "📊 I18N status (guardian) | migrated=${MIGRATED} | $(date -u +%H:%M:%S) UTC" 2>/dev/null || true
        if git push origin "$GIT_TRACK_BRANCH" 2>/dev/null; then
            log_guardian "📤 Push do GitHub OK (branch: $GIT_TRACK_BRANCH)"
            echo "$now_ts" > "$LAST_PUSH_TS_FILE"
        else
            log_guardian "❌ Push nieudany (branch: $GIT_TRACK_BRANCH)"
        fi
    else
        # Brak zmian w statusie - ale i tak odśwież znacznik czasu, żeby nie spamować
        echo "$now_ts" > "$LAST_PUSH_TS_FILE"
    fi
fi

    trap - RETURN
    release_run_lock
}

# Tryb działania:
# - default: single-run (pod cron)
# - --daemon: działa non-stop i sam pilnuje interwału
case "${1:-}" in
    --daemon)
        daemon_source="${GUARDIAN_START_SOURCE:-manual}"
        if ! acquire_daemon_lock "$daemon_source"; then
            exit 0
        fi
        echo $$ > "$GUARDIAN_PID_FILE"
        log_guardian "▶️ Guardian daemon start (pid=$$, source=$daemon_source)"
        trap 'rm -f "$GUARDIAN_PID_FILE"; release_daemon_lock "$daemon_source"; exit 0' SIGINT SIGTERM EXIT
        while true; do
            run_once
            sleep 30
        done
        ;;
    *)
        run_once
        ;;
esac

exit 0
