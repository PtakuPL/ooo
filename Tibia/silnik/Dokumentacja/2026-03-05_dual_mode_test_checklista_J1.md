# J1 — Checklista testowa dual-mode (7.4 + modern) z expected result

**Data:** 2026-03-05  
**Owner:** Codex  
**Cel:** Domknięcie zadania J1 z `2026-03-05_plan_pracy_P1_P6_agents.md`

---

## 1) Warunki wejściowe

1. Test wykonywany na tej samej paczce Windows, której użyją gracze (source-of-truth).
2. API launchera działa (`launcher-version.php`, `update.php`, `server-status.php`, `launcher-token.php`).
3. Światy 7.4 i modern są osiągalne i mają poprawne wpisy serwerów/portów.
4. `CHALLENGE_REQUIRED` ustawione zgodnie z etapem rolloutu.
5. Logowanie security działa i zapisuje do JSONL.

---

## 2) Checklista D1..D5

| ID | Krok testu | Expected result |
|---|---|---|
| D1 | Uruchom launcher z docelowej paczki Windows, wykonaj check/update i restart launchera jeśli wymagany | Launcher kończy update bez błędu krytycznego, status przechodzi do `ready` |
| D2 | Z tego samego launchera uruchom sesję modern, potem sesję 7.4 (lub odwrotnie) | Oba tryby łączą się z poprawnymi światami, bez pomyłki kanału/portów |
| D3 | Wykonaj te same akcje gameplayowe podlegające ograniczeniom (hotkeys/runy) w obu trybach | 7.4: blokady aktywne; modern: brak tych blokad; zachowanie powtarzalne |
| D4 | Celowo zmodyfikuj 1 plik krytyczny klienta i kliknij `Graj` | Start jest blokowany przez integrity check, a `Napraw`/`Aktualizacja` przywraca stan |
| D5 | Podbij wersję launchera po stronie API i wykonaj self-update | Launcher pobiera nową wersję, restartuje się i zachowuje działający flow uruchomienia klienta |

---

## 3) Kryteria PASS/FAIL

1. PASS: wszystkie D1..D5 zakończone wynikiem zgodnym z expected result.
2. FAIL: dowolne odchylenie od expected result lub brak powtarzalności w D2/D3.
3. BLOCKED: brak spełnienia warunków wejściowych (sekcja 1).

---

## 4) Rejestr wyników (do uzupełnienia podczas testów)

| ID | Status (PASS/FAIL/BLOCKED) | Dowód (log/screenshot) | Uwagi |
|---|---|---|---|
| D1 | ⏳ |  |  |
| D2 | ⏳ |  |  |
| D3 | ⏳ |  |  |
| D4 | ⏳ |  |  |
| D5 | ⏳ |  |  |

---

## 5) Szybki template buga (J4)

```
ID: BUG-YYYYMMDD-XX
Krok: D?
Tryb: modern / 7.4 / oba
Objaw:
Expected:
Actual:
Właściciel: Copilot / Codex
Status: open / in_progress / fixed / verified
```
