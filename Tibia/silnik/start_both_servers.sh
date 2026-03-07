#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLASSIC_DIR="$ROOT_DIR/canary_test"
MODERN_DIR="$ROOT_DIR/canary_modern"
RUN_DIR="$ROOT_DIR/run"
LOG_DIR="$ROOT_DIR/logs"

CLASSIC_PID_FILE="$RUN_DIR/canary_classic.pid"
MODERN_PID_FILE="$RUN_DIR/canary_modern.pid"

mkdir -p "$RUN_DIR" "$LOG_DIR"

is_running() {
  local pid_file="$1"
  [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null
}

start_one() {
  local name="$1"
  local dir="$2"
  local pid_file="$3"
  local log_file="$4"

  if is_running "$pid_file"; then
    echo "[SKIP] $name already running (pid=$(cat "$pid_file"))."
    return 0
  fi

  rm -f "$pid_file"
  (
    cd "$dir"
    nohup ./canary >> "$log_file" 2>&1 &
    echo $! > "$pid_file"
  )

  sleep 2
  if is_running "$pid_file"; then
    echo "[OK] $name started (pid=$(cat "$pid_file"), log=$log_file)."
  else
    echo "[ERR] $name failed to start. Check log: $log_file" >&2
    return 1
  fi
}

wait_for_ports() {
  local timeout_seconds="${1:-30}"
  local elapsed=0
  local listening=0

  while (( elapsed < timeout_seconds )); do
    listening=$(ss -ltn | rg -c ':7171\b|:7172\b|:7173\b|:7174\b' || true)
    if (( listening >= 4 )); then
      echo "[OK] Ports 7171-7174 are listening."
      ss -ltnp | rg ':717[1-4]\b' || true
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done

  echo "[WARN] Not all ports are listening after ${timeout_seconds}s."
  ss -ltnp | rg ':717[1-4]\b' || true
}

TODAY="$(date +%F)"
CLASSIC_LOG="$LOG_DIR/server_classic_${TODAY}.log"
MODERN_LOG="$LOG_DIR/server_modern_${TODAY}.log"

start_one "Canary Classic 7.4" "$CLASSIC_DIR" "$CLASSIC_PID_FILE" "$CLASSIC_LOG"
start_one "Canary Modern" "$MODERN_DIR" "$MODERN_PID_FILE" "$MODERN_LOG"

wait_for_ports 30
