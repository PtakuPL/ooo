#!/bin/bash
# ============================================
# I18N Key Extraction Script
# ============================================
# Extracts all i18n keys used in server code
# and compares with available translations.
#
# Usage: ./extract_i18n_keys.sh [--verbose]
# ============================================

set -e
cd "$(dirname "$0")/.."

VERBOSE=false
if [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "I18N Key Extraction"
echo "============================================"
echo ""

# Temporary files
KEYS_NPC_SAY="/tmp/keys_npc_say.txt"
KEYS_NPC_TABLE="/tmp/keys_npc_table.txt"
KEYS_MONSTER_VOICE="/tmp/keys_monster_voice.txt"
KEYS_NPC_VOICE="/tmp/keys_npc_voice.txt"
KEYS_ALL="/tmp/keys_all.txt"
KEYS_DICT="/tmp/keys_dict.txt"

# ============================================
# 1. Extract NPC dialog keys
# ============================================
echo "[1/5] Extracting NPC dialog keys..."

# NPC_LIB.i18n.npcSay(..., "key")
grep -roh 'NPC_LIB\.i18n\.npcSay[^"]*"[^"]*"' data-otservbr-global/npc/ 2>/dev/null | \
    grep -oP '"npc\.[^"]*"' | tr -d '"' | sort -u > "$KEYS_NPC_SAY" || true

# NPC_LIB.i18n.npcSayTable(..., {"key1", "key2"})
grep -roh 'NPC_LIB\.i18n\.npcSayTable[^}]*}' data-otservbr-global/npc/ 2>/dev/null | \
    grep -oP '"npc\.[^"]*"' | tr -d '"' | sort -u > "$KEYS_NPC_TABLE" || true

NPC_COUNT=$(wc -l < "$KEYS_NPC_SAY" 2>/dev/null || echo "0")
echo "   Found: $NPC_COUNT NPC dialog keys"

# ============================================
# 2. Extract Monster voice keys
# ============================================
echo "[2/5] Extracting Monster voice keys..."

# monsterType:addVoice(..., "mv.xxx")
grep -roh 'addVoice[^)]*"mv\.[^"]*"' data-otservbr-global/monster/ 2>/dev/null | \
    grep -oP '"mv\.[^"]*"' | tr -d '"' | sort -u > "$KEYS_MONSTER_VOICE" || true

MV_COUNT=$(wc -l < "$KEYS_MONSTER_VOICE" 2>/dev/null || echo "0")
echo "   Found: $MV_COUNT Monster voice keys"

# ============================================
# 3. Extract NPC voice keys
# ============================================
echo "[3/5] Extracting NPC voice keys..."

# npcType:addVoice(..., "nv.xxx") or i18nKey = "nv.xxx"
grep -roh 'i18nKey[^"]*"nv\.[^"]*"' data-otservbr-global/npc/ 2>/dev/null | \
    grep -oP '"nv\.[^"]*"' | tr -d '"' | sort -u > "$KEYS_NPC_VOICE" || true

NV_COUNT=$(wc -l < "$KEYS_NPC_VOICE" 2>/dev/null || echo "0")
echo "   Found: $NV_COUNT NPC voice keys"

# ============================================
# 4. Combine all keys
# ============================================
echo "[4/5] Combining all keys..."

cat "$KEYS_NPC_SAY" "$KEYS_NPC_TABLE" "$KEYS_MONSTER_VOICE" "$KEYS_NPC_VOICE" 2>/dev/null | \
    sort -u > "$KEYS_ALL"

TOTAL=$(wc -l < "$KEYS_ALL" 2>/dev/null || echo "0")
echo "   Total unique keys: $TOTAL"

# ============================================
# 5. Check against dictionaries
# ============================================
echo "[5/5] Checking translations..."

# Get all keys from English dictionary (base)
if [ -d "i18n/en" ]; then
    find i18n/en -name "*.json" -exec cat {} \; 2>/dev/null | \
        jq -r 'keys[]' 2>/dev/null | sort -u > "$KEYS_DICT" || true
    
    DICT_COUNT=$(wc -l < "$KEYS_DICT" 2>/dev/null || echo "0")
    echo "   Dictionary keys (en): $DICT_COUNT"
    
    # Find missing keys
    MISSING=$(comm -23 "$KEYS_ALL" "$KEYS_DICT" 2>/dev/null | wc -l)
    EXTRA=$(comm -13 "$KEYS_ALL" "$KEYS_DICT" 2>/dev/null | wc -l)
    
    echo ""
    echo "============================================"
    echo "SUMMARY"
    echo "============================================"
    echo "Keys used in code:    $TOTAL"
    echo "Keys in dictionary:   $DICT_COUNT"
    echo -e "Missing translations: ${RED}$MISSING${NC}"
    echo -e "Unused in dictionary: ${YELLOW}$EXTRA${NC}"
    
    if [ "$MISSING" -gt 0 ]; then
        echo ""
        echo -e "${RED}Missing keys (used but not in dictionary):${NC}"
        comm -23 "$KEYS_ALL" "$KEYS_DICT" | head -20
        if [ "$MISSING" -gt 20 ]; then
            echo "... and $(($MISSING - 20)) more"
        fi
    fi
    
    if $VERBOSE && [ "$EXTRA" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Unused keys (in dictionary but not in code):${NC}"
        comm -13 "$KEYS_ALL" "$KEYS_DICT" | head -20
        if [ "$EXTRA" -gt 20 ]; then
            echo "... and $(($EXTRA - 20)) more"
        fi
    fi
else
    echo "   Warning: i18n/en directory not found"
fi

# ============================================
# Generate report file
# ============================================
REPORT_FILE="i18n_keys_report.txt"
{
    echo "I18N Keys Report"
    echo "Generated: $(date)"
    echo "============================================"
    echo ""
    echo "NPC Dialog Keys ($NPC_COUNT):"
    cat "$KEYS_NPC_SAY" 2>/dev/null | sed 's/^/  /'
    echo ""
    echo "Monster Voice Keys ($MV_COUNT):"
    cat "$KEYS_MONSTER_VOICE" 2>/dev/null | sed 's/^/  /'
    echo ""
    echo "NPC Voice Keys ($NV_COUNT):"
    cat "$KEYS_NPC_VOICE" 2>/dev/null | sed 's/^/  /'
} > "$REPORT_FILE"

echo ""
echo "Report saved to: $REPORT_FILE"
echo "============================================"

# Cleanup
rm -f "$KEYS_NPC_SAY" "$KEYS_NPC_TABLE" "$KEYS_MONSTER_VOICE" "$KEYS_NPC_VOICE" "$KEYS_ALL" "$KEYS_DICT" 2>/dev/null

exit 0
