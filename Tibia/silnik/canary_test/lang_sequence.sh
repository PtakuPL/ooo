#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CMD_FILE="worker_commands.txt"
RECENT_REPORT="i18n/status/translation_recent_report.jsonl"
LOG_FILE="i18n/status/lang_sequence.log"

langs=("$@")
if [ ${#langs[@]} -eq 0 ]; then
  langs=(pl es ro ru)
fi

ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
  echo "[$(ts)] $*" | tee -a "$LOG_FILE"
}

enqueue_cmd() {
  local cmd="$1"
  printf "%s\n" "$cmd" >> "$CMD_FILE"
  log "ENQUEUE: $cmd"
}

report_lines() {
  if [ -f "$RECENT_REPORT" ]; then
    wc -l < "$RECENT_REPORT"
  else
    echo 0
  fi
}

lang_done_check() {
  local lang="$1"
  local start_line="$2"
  python3 - "$RECENT_REPORT" "$lang" "$start_line" <<'PY'
import json
import sys
from pathlib import Path

report = Path(sys.argv[1])
lang = sys.argv[2]
start_line = int(sys.argv[3])

if not report.exists():
    print("0 0 0")
    raise SystemExit(0)

lines = report.read_text(encoding="utf-8").splitlines()
new_lines = lines[start_line:] if start_line < len(lines) else []
rows = []
for ln in new_lines:
    ln = ln.strip()
    if not ln:
        continue
    try:
        obj = json.loads(ln)
    except Exception:
        continue
    if obj.get("language") == lang:
        rows.append(obj)

if not rows:
    print("0 0 0")
    raise SystemExit(0)

last = rows[-10:]
translated_sum = sum(int(r.get("translated", 0) or 0) for r in last)
guard_sum = sum(int(r.get("guard_fail", 0) or 0) for r in last)
print(f"{len(rows)} {translated_sum} {guard_sum}")
PY
}

log "START lang sequence: ${langs[*]}"

for lang in "${langs[@]}"; do
  log "SWITCH start -> $lang"
  start_line=$(report_lines)
  enqueue_cmd "LANG:$lang"
  enqueue_cmd "LANGVAL:$lang"

  idle_rounds=0
  waited=0

  while true; do
    sleep 60
    waited=$((waited + 60))

    read -r rows translated_sum guard_sum < <(lang_done_check "$lang" "$start_line")
    log "CHECK lang=$lang rows=$rows translated_last10=$translated_sum guard_last10=$guard_sum waited=${waited}s"

    if [ "$rows" -ge 10 ] && [ "$translated_sum" -eq 0 ]; then
      idle_rounds=$((idle_rounds + 1))
    else
      idle_rounds=0
    fi

    if [ "$idle_rounds" -ge 3 ]; then
      log "DONE lang=$lang (3x idle windows)"
      enqueue_cmd "LANGVAL:$lang"
      break
    fi

    if [ "$waited" -ge 21600 ]; then
      log "TIMEOUT lang=$lang after ${waited}s -> moving next"
      enqueue_cmd "LANGVAL:$lang"
      break
    fi
  done

done

enqueue_cmd "UNFOCUS"
log "END lang sequence"
