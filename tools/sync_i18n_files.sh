#!/bin/bash
# Skrypt do synchronizacji plików i18n we wszystkich językach
# Dodaje brakujące pliki JSON na podstawie struktury EN

set -e

I18N_DIR="/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/i18n"
EN_DIR="$I18N_DIR/en"

# Kolory dla outputu
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🌍 Synchronizacja plików i18n..."
echo "================================"

# Wszystkie języki (bez EN)
LANGUAGES="ar az bg bn bs cs da de el es et fa fi fr he hi hr hu hy id it ja ka kk ko lt lv mk ml ms nl no pl pt ro ru sk sl sq sr sv sw ta te th tl tr uk uz vi zh zh_TW"

# Wszystkie pliki które powinny istnieć (z EN)
FILES_TO_SYNC="client.json cpp.json example_merchant.json globalevents.json html.json mounts.json movements.json npclib.json otclient_mods.json otclient_src.json otclient_tools.json php.json talkactions.json world.json"

total_created=0
total_checked=0

# Dla każdego języka
for lang in $LANGUAGES; do
    lang_dir="$I18N_DIR/$lang"
    
    if [ ! -d "$lang_dir" ]; then
        echo "⚠️  Katalog $lang nie istnieje, pomijam"
        continue
    fi
    
    lang_created=0
    
    # Dla każdego pliku
    for file in $FILES_TO_SYNC; do
        total_checked=$((total_checked + 1))
        target_file="$lang_dir/$file"
        source_file="$EN_DIR/$file"
        
        # Sprawdź czy plik istnieje
        if [ ! -f "$target_file" ]; then
            # Skopiuj plik z EN
            cp "$source_file" "$target_file"
            lang_created=$((lang_created + 1))
            total_created=$((total_created + 1))
            echo -e "${GREEN}✓${NC} Utworzono: $lang/$file"
        fi
    done
    
    if [ $lang_created -gt 0 ]; then
        echo -e "${BLUE}[$lang]${NC} Utworzono $lang_created plików"
    fi
done

echo ""
echo "================================"
echo -e "${GREEN}✅ Zakończono!${NC}"
echo "Sprawdzono: $total_checked lokalizacji"
echo "Utworzono: $total_created nowych plików"
