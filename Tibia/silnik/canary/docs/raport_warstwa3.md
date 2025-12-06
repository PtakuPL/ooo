# Raport — Warstwa 3 (HarfBuzz/FriBidi Compliance Checker)

## Zakres
- Przeszukane źródła w `Tibia/silnik/canary/src/**` oraz konfiguracje w `docs/`.
- Szukane elementy: pliki `TextShaper*.{cpp,h}`, `TTFFont*.{cpp,h}`, moduły `ui*text*`, `drawpooltext`, wywołania `hb_*` (HarfBuzz) i `fribidi*` (FriBidi).

## Wynik
- **Brak** plików implementujących renderowanie/shaping tekstu (brak `TextShaper`, `TTFFont`, `drawpooltext`, `ui*text*`).
- **Brak** jakichkolwiek odwołań do HarfBuzz (`hb_*`) lub FriBidi w kodzie źródłowym.
- Drzewo `canary/` wygląda na backend/serwer (bez warstwy klienta UI), więc ścieżka renderowania tekstu nie jest obecna w tym repozytorium.

## Wnioski / luki
- Nie można przeprowadzić kontroli compliance dla HarfBuzz/FriBidi, bo brak kodu odpowiedzialnego za shaping/RTL w tej gałęzi.
- Aby wykonać pełną warstwę 3, potrzebne są źródła klienta (warstwa renderowania tekstu) lub moduł, który faktycznie używa HarfBuzz/FriBidi.

## Rekomendacje
1) Udostępnić repo/ścieżkę z kodem klienta (renderer tekstu) lub potwierdzić, że warstwa 3 nie dotyczy serwera.
2) Po uzyskaniu kodu klienta sprawdzić: brak ścieżek ASCII-only, wymuszone `hb_shape()` przed rysowaniem, poprawną detekcję RTL (`HB_DIRECTION_RTL`), przekazywanie script/lang do HarfBuzz oraz upload atlasu TTF do draw pool.
