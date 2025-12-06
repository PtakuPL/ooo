# Raport — Warstwa 3 (HarfBuzz/FriBidi Compliance Checker)

## Zakres
- Przeszukane źródła w `Tibia/silnik/canary/src/**` oraz konfiguracje w `docs/`.
- Szukane elementy: pliki `TextShaper*.{cpp,h}`, `TTFFont*.{cpp,h}`, moduły `ui*text*`, `drawpooltext`, wywołania `hb_*` (HarfBuzz) i `fribidi*` (FriBidi).

## Wynik
- W drzewie `canary/` (serwer) nadal **brak** komponentów `TextShaper`, `TTFFont`, `drawpooltext` czy `ui*text*` – ta gałąź nie zawiera kodu renderującego UI.
- W `canary_test/testyy/src/framework/text/` znajdują się pełne implementacje shapingowej ścieżki: `TTFFont` ładuje FreeType + HarfBuzz (`hb_ft_font_create`/`hb_font_destroy`), `TextShaper` wywołuje `hb_shape` po ustawieniu skryptu/direction/języka, a `LocaleShaping` dostarcza BCP-47 parsing, heurystyczne wykrywanie skryptu z UTF-8 oraz przypisywanie `ShapeParams` (język/script/direction). Dzięki temu klient testowy już obsługuje skrypty Latin, Cyrillic, Greek, Arabic, Hanitczy, a `TextDirection` może być ustawiony na `RTL` lub `LTR`.
- `TextShaper` i `LocaleShaping` sięgają również po FriBidi (nagłówek `<fribidi.h>` importowany w `TextShaper.h`), ale w kodzie nie znalazłem jeszcze jawnej logiki re-orderingu Fakt z `fribidi` nie jest użyty – można dodać wsparcie w kolejnych iteracjach.

-## Wnioski / luki
- `canary/` pozostaje backendem bez implementacji shapingowej; samo repo nie pozwala na ocenę compliance, ale `canary_test/testyy` udostępnia niezbędne komponenty.
- We własnym kliencie trzeba jeszcze zdysponować: 1) integrację FriBidi (obecnie tylko `#include <fribidi.h>` bez użycia), 2) zobrazowanie fallbacków TTL (np. `TTFFont` ma `m_fallbackFaces`/`m_fallbackHbFonts`, ale nie są one jeszcze wykorzystywane), 3) testy RTL/LTR – `TextShaper` ustawia direction na podstawie `ShapeParams`, ale nie ma wysokopoziomowych scenariuszy (np. mieszany tekst z Latin+Arabic).

## Rekomendacje
1) Utrzymać wdrożony klient (testyy) jako punkt odniesienia: `TTFFont` + `TextShaper` + `LocaleShaping` pokazują, że pipeline HarfBuzz działa, dlatego w kolejnych krokach należy go przenieść do gałęzi `canary/`/instalki, aby backend też mógł weryfikować coverage.
2) Dodać brakujące fazy integracji: wykorzystać `m_fallbackFaces`/`m_fallbackHbFonts` w `TTFFont::buildQuads`, wprowadzić kod FriBidi (re-ordering, bidi marks) i walidować `ShapeParams` dla mieszanych skryptów.
3) Po przeniesieniu kodu na warstwę produkcyjną dodać testy sanity: 1) `hb_shape` nie powinno zmieniać liczb glyphów/o argu, 2) `LocaleShaping::probeUtf8` poprawnie rozpoznaje CJK/RTL, 3) `TextShaper::shape` nie generuje `HB_DIRECTION_INVALID`.
