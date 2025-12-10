#!/bin/bash
# Skrypt do wysyłania komend do i18n_worker_simple.sh
# Użycie:
#   ./worker_command.sh force monsters   - wymuś kategorię monsters
#   ./worker_command.sh random           - losowa kategoria
#   ./worker_command.sh status           - pokaż status wszystkich kategorii
#   ./worker_command.sh skip             - pomiń aktualny cykl

COMMAND_FILE=".worker_command"

case "$1" in
    force|FORCE)
        if [ -z "$2" ]; then
            echo "Użycie: $0 force <kategoria>"
            echo ""
            echo "Dostępne kategorie:"
            echo "  npc, scripts, monsters, raids, world, spells,"
            echo "  items, libs, events, chatchannels, modules, startup, npclib"
            exit 1
        fi
        echo "FORCE:$2" > "$COMMAND_FILE"
        echo "📨 Wysłano: FORCE:$2"
        echo "   Worker przejdzie do kategorii '$2' w następnym cyklu"
        ;;
    random|RANDOM)
        echo "RANDOM" > "$COMMAND_FILE"
        echo "📨 Wysłano: RANDOM"
        echo "   Worker wylosuje kategorię w następnym cyklu"
        ;;
    status|STATUS)
        echo "STATUS" > "$COMMAND_FILE"
        echo "📨 Wysłano: STATUS"
        echo "   Worker wyświetli status w następnym cyklu"
        ;;
    skip|SKIP)
        echo "SKIP" > "$COMMAND_FILE"
        echo "📨 Wysłano: SKIP"
        echo "   Worker pominie następny cykl"
        ;;
    help|--help|-h)
        echo "Worker Command - Sterowanie i18n_worker_simple.sh"
        echo ""
        echo "Użycie: $0 <komenda> [parametr]"
        echo ""
        echo "Komendy:"
        echo "  force <kategoria>  - wymuś przejście do podanej kategorii"
        echo "  random            - wylosuj kategorię"
        echo "  status            - wyświetl status wszystkich kategorii"
        echo "  skip              - pomiń aktualny cykl"
        echo ""
        echo "Kategorie:"
        echo "  npc scripts monsters raids world spells items"
        echo "  libs events chatchannels modules startup npclib"
        echo ""
        echo "Przykłady:"
        echo "  $0 force monsters"
        echo "  $0 random"
        ;;
    *)
        echo "Nieznana komenda: $1"
        echo "Użyj '$0 help' aby zobaczyć dostępne komendy"
        exit 1
        ;;
esac
