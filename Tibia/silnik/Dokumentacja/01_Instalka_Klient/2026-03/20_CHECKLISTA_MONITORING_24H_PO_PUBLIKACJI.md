# Checklista Monitoringu Pierwszych 24h po Publikacji

Data: 2026-03-06
Zakres: K109

## 1. Okno 0-1h
1. Monitoruj bledy `LCH_*` per kod i kanal.
2. Monitoruj odsetek fail update oraz fail launch.
3. Monitoruj rate-limit i token rejection.
4. Monitoruj tempo self-update launchera.

## 2. Okno 1-6h
1. Sprawdz trendy `LCH_MANIFEST_*`, `LCH_FILE_*`, `LCH_TOKEN_*`.
2. Sprawdz, czy nie rosna `LCH_PREFLIGHT_*` (miejsce/uprawnienia).
3. Sprawdz, czy nie rosnie `LCH_LAUNCHER_UPDATE_REQUIRED` ponad baseline.

## 3. Okno 6-24h
1. Potwierdz stabilny poziom bledow i brak nowych regresji.
2. Potwierdz poprawny dzialajacy fallback/rollback.
3. Potwierdz zgodnosc support tickets z mapa kodow i KB.

## 4. Progi alarmowe (start)
1. P0 alarm: >5% update failure przez 15 min.
2. P0 alarm: >3% launch failure przez 15 min.
3. P0 alarm: masowy `LCH_MANIFEST_SIGNATURE_INVALID` lub `LCH_TLS_REQUIRED`.
4. P1 alarm: >10% wzrost `LCH_PREFLIGHT_INSUFFICIENT_SPACE`.

## 5. Akcje przy alarmie
1. Zastosuj runbook support.
2. Jesli trzeba: rollback kanal/self-update.
3. Udokumentuj incydent i decyzje go/no-go.
