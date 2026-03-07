# J4 — Wyniki testów z paczki Windows (D1..D5)

**Data startu:** 2026-03-05  
**Źródło scenariusza:** `2026-03-05_dual_mode_test_checklista_J1.md`  
**Owner:** Codex (zapis wyników), Copilot (wykonanie/review)

---

## Status wykonania testów akceptacyjnych

| ID | Test | Status | Data | Wersja launchera | Paczka Windows | Dowód | Uwagi |
|---|---|---|---|---|---|---|---|
| D1 | Start z paczki usera + check/update | ⏳ |  |  |  |  |  |
| D2 | Równoległe uruchomienie 7.4 + modern | ⏳ |  |  |  |  |  |
| D3 | Różnice anti-cheat 7.4 vs modern | ⏳ |  |  |  |  |  |
| D4 | Naruszenie pliku krytycznego + repair/update | ⏳ |  |  |  |  |  |
| D5 | Self-update launchera + dystrybucja poprawki | ⏳ |  |  |  |  |  |

---

## Zasada aktualizacji tego pliku

1. Po KAŻDYM teście wpisujemy status `PASS/FAIL/BLOCKED`.
2. Dla `FAIL` lub `BLOCKED` dodajemy wpis do rejestru bugów (`2026-03-05_ui_installer_bug_registry_J6.md`).
3. Pole "Paczka Windows" musi zawierać jednoznaczny identyfikator paczki testowej (source-of-truth).
