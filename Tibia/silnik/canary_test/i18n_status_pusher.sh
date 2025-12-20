#!/bin/bash
set -euo pipefail

cd /home/ptaku/serweryt

git add I18N_STATUS.md Tibia/silnik/canary_test/I18N_STATUS.md 2>/dev/null || true

if git diff --cached --quiet 2>/dev/null; then
	exit 0
fi

git commit -m "📊 I18N Status update $(date -u +%H:%M:%S) UTC" -q 2>/dev/null || true
git push origin master -q 2>/dev/null || true
