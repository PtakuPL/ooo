# Raport — Warstwa 4 (Code Safety & Format Consistency)

## Zakres
- Przeskanowano `Tibia/silnik/canary/src/**` pod kątem ryzykownych format stringów: `%s/%i/%d`, gołych `%`, gołych `{}` w kontekście `fmt::format` / loggerów.

## Wynik skanów
- Nie znaleziono wywołań `fmt::format` / loggerów z printf-owymi tokenami `%s/%i/%d` (zapytanie regex: `fmt::...%[sdix]` → brak podejrzanych miejsc; trafienia dotyczyły jedynie formatów daty `{:%Y-%m-%d}` itp.).
- Brak plików z `tr()` → nie dotyczy fmt, ale potwierdza brak warstwy lokalizacji w kodzie serwera (opisane w warstwie 1).
- Znalezione użycia printf/`fprintf` (np. `game.cpp:8989`), ale są to klasyczne wywołania z poprawną liczbą argumentów i nie mieszają się z `fmt`/`spdlog`.
- Wzorce logowania w `spdlog` (`log_with_spd_log.cpp`) używają standardowego formatu biblioteki (`[%Y-%d-%m %H:%M:%S.%e] [%^%l%$] %v`).

## Luki / uwagi
- Nie wykonywano automatycznego sprawdzania zgodności liczby placeholderów vs. argumentów w `fmt::format` (do rozważenia: clang-tidy `modernize-use-std-format` / własny skrypt z `fmt::detail::count`).
- Nie analizowano stringów z `{}` wewnątrz danych (np. treści z bazy) — tu potrzebne testy w runtime/logach.

## Rekomendacje
1) Dodać automatyczny lint (np. clang-tidy lub skrypt Python + `libfmt`) w CI, który:
   - wykrywa printf-owe `%` w `fmt::format`/loggerach,
   - porównuje liczbę placeholderów `{}` z liczbą argumentów.
2) Rozszerzyć skan o pliki Lua (jeśli używają fmt/`string.format`) oraz o generowane źródła, jeżeli pojawią się w repo.
