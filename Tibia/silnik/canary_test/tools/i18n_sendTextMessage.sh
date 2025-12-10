#!/bin/bash
# i18n_sendTextMessage.sh - Migracja player:sendTextMessage do i18n
# v1.0 - Sesja #4

set -e
WORK_DIR="/home/ptaku/serweryt/Tibia/silnik/canary_test"
cd "$WORK_DIR"

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[i18n-STM]${NC} $1"; }
warn() { echo -e "${YELLOW}[i18n-STM]${NC} $1"; }
error() { echo -e "${RED}[i18n-STM]${NC} $1"; }

# Liczniki
total_files=0
modified_files=0
keys_added=0

# =================================================================
# KROK 1: Dodaj klucz do messages.json (angielski)
# =================================================================
add_message_key() {
    local key="$1"
    local value="$2"
    
    for lang_dir in i18n/*/; do
        local json_file="${lang_dir}messages.json"
        if [[ -f "$json_file" ]]; then
            # Sprawdź czy klucz już istnieje
            if grep -q "\"$key\"" "$json_file" 2>/dev/null; then
                continue
            fi
            
            # Dodaj klucz do JSON
            local content
            content=$(cat "$json_file")
            if [[ "$content" == "{}" ]]; then
                echo "{
  \"$key\": \"$value\"
}" > "$json_file"
            else
                # Usuń ostatni } i dodaj klucz
                sed -i '$ d' "$json_file"
                echo ",
  \"$key\": \"$value\"
}" >> "$json_file"
            fi
        fi
    done
}

# =================================================================
# KROK 2: Dodaj główne klucze systemowe
# =================================================================
log "Dodaję klucze systemowe do messages.json..."

# Główny tekst sprzedaży - używa placeholderów {amount}, {item}, {gold}
add_message_key "system.trade.sold" "Sold {amount}x {item} for {gold} gold."
add_message_key "system.trade.bought" "Bought {amount}x {item} for {gold} gold."

# Inne często używane teksty
add_message_key "system.blessing.received" "You received the remaining {count} blesses."
add_message_key "system.blessing.already" "You are already blessed."
add_message_key "system.store.check_inbox" "Please make sure you have free slots in your store inbox."
add_message_key "system.experience.gained" "You gained {amount} experience points."
add_message_key "system.mission.points" "You earned {amount} point(s) on the {mission} mission."
add_message_key "system.mount.received" "Congratulations you received the {mount} mount."
add_message_key "system.item.received" "You gained a {item}."
add_message_key "system.stash.count" "Your supply stash contains {count} items."

keys_added=10
log "Dodano $keys_added kluczy systemowych"

# =================================================================
# KROK 3: Zamień pattern w plikach NPC
# =================================================================
log "Zamieniam player:sendTextMessage w plikach NPC..."

# Pattern do zamiany - główny tekst sprzedaży
# Używamy sendLocalizedTextMessage z args jako tabela
# player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
# -> player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})

# Znajdź wszystkie pliki z tym patternem
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        total_files=$((total_files + 1))
        
        # Użyj sed do zamiany - zamień na sendLocalizedTextMessage
        if sed -i 's|player:sendTextMessage(MESSAGE_TRADE, string\.format("Sold %ix %s for %i gold\.", amount, name, totalCost))|player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})|g' "$file" 2>/dev/null; then
            if grep -q "system.trade.sold" "$file" 2>/dev/null; then
                modified_files=$((modified_files + 1))
            fi
        fi
    fi
done < <(grep -rl 'string.format("Sold %ix %s for %i gold."' data-otservbr-global/npc/ 2>/dev/null)

log "Przetworzono $total_files plików, zmodyfikowano $modified_files"

# =================================================================
# KROK 4: Inne patterny sendTextMessage
# =================================================================
log "Zamieniam inne patterny sendTextMessage..."

# Pattern: "You are already blessed."
sed -i 's|player:sendTextMessage(MESSAGE_STATUS, "You are already blessed.")|player:sendLocalizedTextMessage(MESSAGE_STATUS, "system.blessing.already")|g' data-otservbr-global/npc/*.lua 2>/dev/null || true

# Pattern: "Please make sure you have free slots in your store inbox."
sed -i 's|player:sendTextMessage(MESSAGE_LOOK, "Please make sure you have free slots in your store inbox.")|player:sendLocalizedTextMessage(MESSAGE_LOOK, "system.store.check_inbox")|g' data-otservbr-global/npc/*.lua 2>/dev/null || true

# =================================================================
# KROK 5: Podsumowanie
# =================================================================
echo ""
echo "=========================================="
log "PODSUMOWANIE MIGRACJI sendTextMessage"
echo "=========================================="
echo "Klucze dodane:     $keys_added"
echo "Pliki przeszukane: $total_files"
echo "Pliki zmodyfikowane: $modified_files"
echo ""

# Sprawdź ile jeszcze zostało
remaining=$(grep -rn 'player:sendTextMessage.*string.format' data-otservbr-global/npc/*.lua 2>/dev/null | wc -l)
echo "Pozostało do migracji: $remaining"

log "Gotowe! Sprawdź zmiany przed commitem."
