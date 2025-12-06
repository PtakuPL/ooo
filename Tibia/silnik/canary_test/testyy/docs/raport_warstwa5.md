# Raport — Warstwa 5 (Runtime Simulation / Dry Run)

## Zakres
- Celem było uruchomienie offline shapingu dla ~30 języków z użyciem HarfBuzz/FriBidi i fontów z warstwy 2.

## Status
- **Nie wykonano symulacji** — brak kompletu fontów w głównym drzewie `canary/` (TTF wyłącznie w `canary_test/testyy/data/fonts/ttf/`) oraz brak warstwy renderującej tekst (HarfBuzz/FriBidi) w tym repo.

## Wymagane, aby uruchomić symulację
1) Dostarczyć zestaw fontów używanych w produkcyjnym buildzie (TTF/OTF + aktualne `.otfont`) w `canary/data/fonts/...`.
2) Zapewnić środowisko z bibliotekami HarfBuzz/FriBidi (lub udostępnić kod klienta, który wywołuje shaping).
3) Przygotować próbki tekstów 30 języków (RTL, CJK, Indic, Latin) oraz ścieżkę kodu, która kieruje je do shapera.
4) Wykonać skrypt testowy (np. Python + `uharfbuzz`/`fontTools`) i zbudować tabelę: język → status glyphów / kierunek RTL/LTR / UV atlasu.

## Rekomendacja
- Po dostarczeniu fontów i kodu klienta uruchomić dedykowany test offline i dopisać wyniki do tego raportu.
