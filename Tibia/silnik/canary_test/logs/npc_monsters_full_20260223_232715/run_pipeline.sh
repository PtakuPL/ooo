#!/usr/bin/env bash
set -euo pipefail
ROOT="/home/ptaku/serweryt/Tibia/silnik/canary_test"
LOGDIR="${PIPELINE_LOGDIR:?PIPELINE_LOGDIR is required}"
cd "$ROOT"

{
  echo "=== START $(date '+%F %T') ==="
  echo "ROOT=$ROOT"
  echo "LOGDIR=$LOGDIR"

  echo "=== STEP 1: NPC FULL ==="
  export NPC_DOCUMENTATION_ENABLED=false
  export NPC_STAGE6_SYNC_LANGS="pl ru"
  export NPC_STAGE6_REAL_TRANSLATION_ENABLED=true
  export NPC_STAGE6_REAL_TRANSLATION_LANGS="pl ru"
  export NPC_STAGE6_USE_GT=true
  bash ./i18n_worker_simple.sh --npc-full

  echo "=== STEP 2: MONSTERS FULL ==="
  export MONSTERS_SYNC_LANGS="pl ru"
  export MONSTERS_REAL_TRANSLATION_ENABLED=true
  export MONSTERS_REAL_TRANSLATION_LANGS="pl ru"
  export MONSTERS_USE_GT=true
  bash ./i18n_worker_simple.sh --monsters-full

  echo "=== STEP 3: FINAL STATUS ==="
  bash ./i18n_worker_simple.sh --status
  echo "=== END $(date '+%F %T') ==="
} >> "$LOGDIR/pipeline.log" 2>&1
