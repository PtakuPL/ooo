#!/bin/bash
cd /home/ptaku/serweryt
git add I18N_STATUS.md Tibia/silnik/canary_test/I18N_STATUS.md 2>/dev/null
git commit -m "📊 I18N Status update $(date +%H:%M)" --allow-empty-message -q 2>/dev/null
git push origin master -q 2>/dev/null
