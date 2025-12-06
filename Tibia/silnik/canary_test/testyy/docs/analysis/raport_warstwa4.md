# Raport — Warstwa 4 (Code Safety & Format Consistency)

## Zakres
- Przeskanowano `Tibia/silnik/canary/src/**` pod kątem ryzykownych format stringów: `%s/%i/%d`, gołych `%`, gołych `{}` w kontekście `fmt::format` / loggerów.

## Wynik skanów
- Skan `fmt::` w `canary/src/**` → liczne użycia `fmt::format`/`fmt::underlying`/`fmt::print`, brak printf-owych tokenów `%s/%i/%d` wewnątrz formatów (trafienia z `%` dotyczyły dat `{:%Y-%m-%d}` itp.).
- Skan `printf\(` → tylko 2 wywołania `fprintf` w `game.cpp` (z klasycznymi argumentami, bez mieszania z `fmt`).
- Brak `tr()` w kodzie serwera (potwierdza warstwa 1 — brak lokalizacji).
- Wzorce logowania `spdlog` używają natywnego formatu (`[%Y-%d-%m %H:%M:%S.%e] [%^%l%$] %v`).
- W `canary_test/testyy` także dominują `fmt::format` (np. `client/tile.cpp`, `framework/otml/otmlnode.cpp`, `client/protocolgameparse.cpp`). Format stringi są twardo zakodowane i nie mieszają printf-owych tokenów z `fmt`, więc nie wykryto naruszeń placeholderów.

## Luki / uwagi
- Nie wykonywano automatycznego sprawdzania zgodności liczby placeholderów vs. argumentów w `fmt::format` (do rozważenia: clang-tidy `modernize-use-std-format` / własny skrypt z `fmt::detail::count`).
- Nie analizowano stringów z `{}` wewnątrz danych (np. treści z bazy) — tu potrzebne testy w runtime/logach.
- Lint nie był uruchamiany dla `canary_test/testyy`, gdzie `fmt::format` służy do logów i wyjątków (np. `docs/convert_stdext_format.py` aktualizuje te miejsca). Warto rozszerzyć skan, by mieć jedną politykę placeholderów po obu stronach.

## Rekomendacje
1) Dodać automatyczny lint (np. clang-tidy lub skrypt Python + `libfmt`) w CI, który:
   - wykrywa printf-owe `%` w `fmt::format`/loggerach,
   - porównuje liczbę placeholderów `{}` z liczbą argumentów.
2) Rozszerzyć skan o pliki Lua (jeśli używają fmt/`string.format`) oraz o generowane źródła, jeżeli pojawią się w repo.
3) Objawić ten sam lint także dla `canary_test/testyy` (zwłaszcza `framework/otml/*` i `client/*`), żeby upewnić się, że złożone wyjątki/logi nie łamią zasad placeholderów.
