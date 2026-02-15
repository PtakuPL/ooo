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
        echo "  documentation [N] - generuj dokumentację projektu (batch=N, domyślnie 20)"
        echo "  docindex          - przebuduj indeks dokumentacji"
        echo "  premig [cat|all]  - wymuś skan PRE_MIGRATION"
        echo ""
        echo "Kategorie:"
        echo "  npc scripts monsters raids world spells items"
        echo "  libs events chatchannels modules startup npclib"
        echo ""
        echo "Przykłady:"
        echo "  $0 force monsters"
        echo "  $0 random"
        echo "  $0 documentation 50"
        echo "  $0 docindex"
        echo "  $0 premig all"
        ;;
    premig|PREMIG)
        PREMIG_CAT="${2:-all}"
        echo "PREMIG:$PREMIG_CAT" > "$COMMAND_FILE"
        echo "📨 Wysłano: PREMIG:$PREMIG_CAT"
        echo "   Worker uruchomi skan PRE_MIGRATION dla '$PREMIG_CAT' w następnym cyklu"
        ;;
    documentation|DOCUMENTATION)
        DOC_BATCH="${2:-20}"
        if [ "$DOC_BATCH" != "20" ] && [[ "$DOC_BATCH" =~ ^[0-9]+$ ]]; then
            echo "DOCUMENTATION:$DOC_BATCH" > "$COMMAND_FILE"
            echo "📨 Wysłano: DOCUMENTATION:$DOC_BATCH"
        else
            echo "DOCUMENTATION" > "$COMMAND_FILE"
            echo "📨 Wysłano: DOCUMENTATION"
        fi
        echo "   Worker uruchomi generowanie dokumentacji w następnym cyklu"
        ;;
    docindex|DOCINDEX)
        echo "DOCINDEX" > "$COMMAND_FILE"
        echo "📨 Wysłano: DOCINDEX"
        echo "   Worker przebuduje indeks dokumentacji w następnym cyklu"
        ;;
    *)
        # Passthrough: jeśli komenda pasuje do znanego wzorca workera, wyślij bezpośrednio
        if echo "$1" | grep -qE '^(FORCE:|PREMIG:|AUTO:|SYNC:|SWITCH:|UNSWITCH|LANGVAL:|SPOTCHECK:|GRAMMARFIX:|RESTART|COMPACT_KEYS|IDLE|RANDOM|STATUS|SELFTEST|SELF_CHECK|SKIP|PAUSE:|NOTE:|SET:|TEST:|TEST_ALL|GT:|BATCH:|REPORT|LANGS|CONFIG|FOCUS:|UNFOCUS|LANG:|DOCUMENTATION|DOCINDEX)'; then
            echo "$1" > "$COMMAND_FILE"
            echo "📨 Wysłano: $1"
        else
            echo "Nieznana komenda: $1"
            echo "Użyj '$0 help' aby zobaczyć dostępne komendy"
            exit 1
        fi
        ;;
esac
