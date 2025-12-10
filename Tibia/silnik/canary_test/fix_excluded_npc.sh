#!/bin/bash
#===============================================================================
# FIX EXCLUDED NPC - Naprawia błędnie excluded pliki NPC
#===============================================================================

cd /home/ptaku/serweryt/Tibia/silnik/canary_test

EXCLUDED_FILE="i18n_excluded_files.txt"
BACKUP_FILE="i18n_excluded_files.txt.bak.$(date +%Y%m%d_%H%M%S)"

echo "=== FIX EXCLUDED NPC ==="
echo "Backup: $BACKUP_FILE"
cp "$EXCLUDED_FILE" "$BACKUP_FILE"

# Plik tymczasowy na poprawioną listę
temp_file=$(mktemp)
removed=0
kept=0

while IFS= read -r line; do
    # Ignoruj puste linie i komentarze
    [[ -z "$line" || "$line" == \#* ]] && { echo "$line" >> "$temp_file"; continue; }
    
    # Jeśli to plik NPC
    if [[ "$line" == *"/npc/"* ]]; then
        # Sprawdź czy plik istnieje
        if [ -f "$line" ]; then
            # Sprawdź czy ma tekst do migracji (text = "..." lub text = {...})
            has_text=$(grep -cE 'text\s*=\s*["{]|npcHandler:say\s*\(' "$line" 2>/dev/null || echo 0)
            # Sprawdź czy jest już zmigrowany
            has_i18n=$(grep -c "i18n\|I18N\|Localized" "$line" 2>/dev/null || echo 0)
            
            if [ "$has_text" -gt 0 ] && [ "$has_i18n" -eq 0 ]; then
                # Ma tekst ale nie jest zmigrowany - USUŃ z excluded
                echo "  ✅ Usunięto: $(basename "$line")"
                removed=$((removed + 1))
                continue
            fi
        fi
    fi
    
    # Zachowaj linię
    echo "$line" >> "$temp_file"
    kept=$((kept + 1))
    
done < "$EXCLUDED_FILE"

# Zastąp plik
mv "$temp_file" "$EXCLUDED_FILE"

echo ""
echo "=== PODSUMOWANIE ==="
echo "Usunięto z excluded: $removed plików NPC"
echo "Zachowano: $kept wpisów"
echo ""
echo "Teraz uruchom worker, aby przetworzyć te pliki:"
echo "  ./i18n_autonomous_worker.sh"
