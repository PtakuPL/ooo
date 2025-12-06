# Raport — Warstwa 2 (Unicode Coverage Scanner)

## Zakres
- Przeszukane pliki fontów i konfiguracji w repozytorium.
- Lokalizacja zasobów: brak fontów w `canary/data`, jedyny zestaw w `canary_test/testyy/data/fonts/`.

## Znalezione fonty i konfiguracje
- Pliki TTF (wyłącznie w `canary_test/testyy/data/fonts/ttf/`):
  - `NotoSans-Regular.ttf`, `NotoSans-Bold.ttf`
  - `NotoSansSC-Regular.ttf`
  - `NotoNaskhArabic-Regular.ttf`
- Pliki `.otfont` (również tylko w `canary_test/testyy/data/fonts/`), m.in. `NotoSans-12.otfont`, `noto-12.otfont`, `cipsoftFont.otfont`, `terminus-*.otfont`, `verdana-*.otfont`.
- Przykładowe fallbacki:
  - `NotoSans-12.otfont` → `source: "fonts/NotoSans-Regular.ttf"`, `fallback: [ "NotoSansCJK-Regular.ttf", "NotoNaskhArabic.ttf" ]` (obie nazwy fallbacków **nie występują** w repo; istnieją warianty `NotoSansSC-Regular.ttf` i `NotoNaskhArabic-Regular.ttf`).
  - `noto-12.otfont` → `source: /fonts/ttf/NotoSans-Regular.ttf`, fallback `[ /fonts/ttf/NotoSansSC-Regular.ttf, /fonts/ttf/NotoNaskhArabic-Regular.ttf ]` (te pliki istnieją w katalogu testowym).
- Brak konfiguracji fontów / fallback chain w głównym drzewie `canary/` → nie wiadomo, z czego korzysta realna build/instalka.

## Luki / ryzyka
- Brak fontów w katalogu produkcyjnym (`canary/data/fonts/...`). Zasoby są jedynie w katalogu testowym, więc nie ma podstaw do audytu pokrycia Unicode w realnym artefakcie.
- Fallback w `NotoSans-12.otfont` wskazuje na pliki nieobecne w repo (błędne nazwy). To może skutkować brakiem glifów dla CJK/Arabic w środowisku testowym.
- Nie przeprowadzono ekstrakcji `ulUnicodeRange`/mapy skryptów (brak pewności co do docelowego zestawu fontów). 

## Rekomendacje
1) Dostarczyć pełny zestaw fontów (TTF) używany w produkcyjnej instalki/kliencie w `canary/data/fonts/ttf` oraz aktualne `.otfont` z fallback chainem.
2) Ujednolicić nazwy w `.otfont` z faktycznymi plikami (`NotoSansCJK-Regular` → `NotoSansSC-Regular`, `NotoNaskhArabic` → `NotoNaskhArabic-Regular`).
3) Po dostarczeniu fontów uruchomić skrypt do odczytu zakresów Unicode (np. `fontTools.ttLib` → `OS/2.ulUnicodeRange*`) i zbudować mapę skryptów vs. języki obsługiwane.
4) Zweryfikować łańcuch fallback dla języków RTL (arabski, hebrajski) i CJK, tak aby pokrywał 100% znaków z listy języków (warstwa 1).
