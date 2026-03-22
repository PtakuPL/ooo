#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# E2E Smoke Test — pełne flow (interaktywny)
# ═══════════════════════════════════════════════════════════════
# TEST-003 → TEST-007, TEST-022, TEST-023
#
# Ten skrypt to interaktywna checklista — wykonujesz kroki ręcznie,
# a skrypt pyta o wynik. Wymaga: uruchomiony serwer + launcher + klient.
#
# Uruchomienie: bash smoke_test_e2e.sh

set -euo pipefail

PASS=0; FAIL=0; SKIP=0

ask() {
    local label="$1"
    echo ""
    echo "  ▶ $label"
    echo -n "    Wynik? [p]ass / [f]ail / [s]kip: "
    read -r answer
    case "$answer" in
        p|P|pass) PASS=$((PASS+1)); echo "    ✅ PASS" ;;
        f|F|fail) FAIL=$((FAIL+1)); echo "    ❌ FAIL" ;;
        *)        SKIP=$((SKIP+1)); echo "    ⏭️  SKIP" ;;
    esac
}

echo "═══════════════════════════════════════════════"
echo "  E2E SMOKE TEST — Interaktywna checklista"
echo "═══════════════════════════════════════════════"
echo ""
echo "  Upewnij się, że masz uruchomione:"
echo "  • Serwer Canary (oba: Modern + Classic 7.4)"
echo "  • MyAAC (WWW)"
echo "  • API backend"
echo ""

# ── TEST-003: Launcher → klient → auto-login ──
echo "━━━ TEST-003: Launcher → klient → auto-login ━━━"
ask "1. Otwórz launcher i zaloguj się"
ask "2. Kliknij 'Uruchom Tibia'"
ask "3. Klient OTC startuje?"
ask "4. Auto-login działa? (brak ekranu email/hasło, od razu lista postaci)"

# ── TEST-004: Wybór postaci → ticket → gra ──
echo ""
echo "━━━ TEST-004: Wybór postaci → ticket → gra ━━━"
ask "5. Lista postaci wyświetla się poprawnie?"
ask "6. Wybierz postać i kliknij 'Enter Game'"
ask "7. Ticket wydany, połączenie z serwerem gry udane?"
ask "8. Gracz pojawia się w grze?"

# ── TEST-005: Classic 7.4 → poprawny world mapping ──
echo ""
echo "━━━ TEST-005: Classic 7.4 world mapping ━━━"
ask "9. Utwórz postać na świecie Classic 7.4 (np. 'RedDAXE 7.4')"
ask "10. Po wybraniu postaci Classic 7.4 — trafia na właściwy serwer?"
ask "11. Hotkeye na runy/itemy ZABLOKOWANE? (drag rune na hotkey bar = brak efektu)"
ask "12. Inne systemy (market, bestiary, prey) DOSTĘPNE?"

# ── TEST-006: Modern → poprawny world mapping ──
echo ""
echo "━━━ TEST-006: Modern world mapping ━━━"
ask "13. Utwórz postać na świecie Modern (np. 'RedDAXE Modern')"
ask "14. Po wybraniu postaci Modern — trafia na właściwy serwer?"
ask "15. Wszystkie systemy dostępne? (hotkeye, market, bestiary, etc.)"

# ── TEST-007: WWW → deep link → launcher → sesja ──
echo ""
echo "━━━ TEST-007: WWW → launcher deep link ━━━"
ask "16. Zaloguj się na stronie WWW (reddaxe)"
ask "17. Kliknij 'Graj w launcherze' — launcher się otworzył?"
ask "18. Launcher automatycznie zalogował i odświeżył sesję?"
ask "19. Jeśli launcher nie otworzy się — pojawił się fallback 'Pobierz launcher'?"

# ── TEST-008: Player mode sealed ──
echo ""
echo "━━━ TEST-008: Player mode sealed ━━━"
ask "20. W kliencie kliknij 'Add Server' — ZABLOKOWANE?"
ask "21. Pola host/port UKRYTE?"
ask "22. Pole email/hasło UKRYTE (player mode, auto-login)?"
ask "23. Nie da się ręcznie wpisać adresu serwera?"

# ── TEST-022: Pełny flow Classic 7.4 ──
echo ""
echo "━━━ TEST-022: Pełny flow E2E — Classic 7.4 ━━━"
ask "24. Launcher → login → uruchom → auto-login → lista postaci → Classic 7.4 → gra"
ask "25. Hotkeye runy/itemy zablokowane, reszta systemów włączona"

# ── TEST-023: Pełny flow Modern ──
echo ""
echo "━━━ TEST-023: Pełny flow E2E — Modern ━━━"
ask "26. Launcher → login → uruchom → auto-login → lista postaci → Modern → gra"
ask "27. Wszystkie systemy w pełni dostępne"

echo ""
echo "═══════════════════════════════════════════════"
echo "  WYNIK: ✅ $PASS  ❌ $FAIL  ⏭️ $SKIP"
echo "═══════════════════════════════════════════════"
[ "$FAIL" -eq 0 ] || exit 1
