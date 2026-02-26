#!/usr/bin/env bash
set -uo pipefail
ROOT="/home/ptaku/serweryt/Tibia/silnik/canary_test"
LOGDIR="${PIPELINE_LOGDIR:?PIPELINE_LOGDIR is required}"
cd "$ROOT"

STEP1_RC=0
STEP2_RC=0
STEP3_RC=0

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
  bash ./i18n_worker_simple.sh --npc-full || STEP1_RC=$?
  echo "STEP1_RC=$STEP1_RC"

  echo "=== STEP 2: MONSTERS FULL ==="
  export MONSTERS_SYNC_LANGS="pl ru"
  export MONSTERS_REAL_TRANSLATION_ENABLED=true
  export MONSTERS_REAL_TRANSLATION_LANGS="pl ru"
  export MONSTERS_USE_GT=true
  bash ./i18n_worker_simple.sh --monsters-full || STEP2_RC=$?
  echo "STEP2_RC=$STEP2_RC"

  echo "=== STEP 3: FINAL STATUS ==="
  bash ./i18n_worker_simple.sh --status || STEP3_RC=$?
  echo "STEP3_RC=$STEP3_RC"

  FINAL_RC=0
  if [ "$STEP1_RC" -ne 0 ] || [ "$STEP2_RC" -ne 0 ] || [ "$STEP3_RC" -ne 0 ]; then
    FINAL_RC=1
  fi
  echo "FINAL_RC=$FINAL_RC"
  echo "=== END $(date '+%F %T') ==="
} >> "$LOGDIR/pipeline.log" 2>&1
