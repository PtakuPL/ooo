# Raport — Warstwa 2 (Unicode Coverage Scanner)

## Zakres
- Przeszukane pliki fontów i konfiguracji w repozytorium.
- Lokalizacja zasobów: brak fontów w `canary/data`, jedyny zestaw w `canary_test/testyy/data/fonts/`.

## Znalezione fonty i konfiguracje
- W katalogu produkcyjnym `canary/data` **nie ma żadnych fontów ani konfiguracji** (brak `fonts/ttf`, brak `.otfont`). Jedynym miejscem z TTF jest `canary_test/testyy/data/fonts/ttf/`.
- Pod `/canary_test/testyy/data/fonts/ttf/` znajdują się cztery pliki: `NotoSans-Regular.ttf`, `NotoSans-Bold.ttf`, `NotoSansSC-Regular.ttf`, `NotoNaskhArabic-Regular.ttf`. Wszystkie są wykorzystywane przez klienta testowego.
- Zestaw `.otfont` w `canary_test/testyy/data/fonts/` obejmuje `NotoSans-12.otfont`, `noto-12.otfont`, bitmapowe `cipsoftFont`, `mono-12`, `sans-bold-16px`, `terminus-*`, `verdana-*`, `small-9px`. Tylko `NotoSans-12` i `noto-12` deklarują fallbacky.
- **`NotoSans-12.otfont`** wskazuje: `source: "fonts/NotoSans-Regular.ttf"`, `fallback: ["NotoSansCJK-Regular.ttf", "NotoNaskhArabic.ttf"]`. Te nazwy nie istnieją (fakt: są `NotoSansSC-Regular.ttf` i `NotoNaskhArabic-Regular.ttf`), więc pełne pokrycie CJK/Arabic nie występuje w konfiguracji.
- **`noto-12.otfont`** ma poprawne ścieżki (`/fonts/ttf/NotoSans-Regular.ttf`, `/fonts/ttf/NotoSans-Bold.ttf`) i fallback (`NotoSansSC-Regular.ttf`, `NotoNaskhArabic-Regular.ttf`). Ten atlas jest zgodny z dostępną strukturą katalogów i nie wymaga korekty.
- Pozostałe `.otfont` to bitmapy bez fallbacków (np. `cipsoftFont` używa atlasu `cipsoftFont`, `verdana*` odwołują się do bitmapowych tekstur), więc nie zachodzi kwestia zewnętrznych TTF.

## Luki / ryzyka
- Brak fontów w katalogu produkcyjnym (`canary/data/fonts/...`). Zasoby istnieją wyłącznie w `canary_test/testyy`, więc nie można zweryfikować możliwości renderowania Unicode na serwerze lub w instalatorze, który jest budowany z drzewem `canary/`.
- `NotoSans-12.otfont` odwołuje się do `NotoSansCJK-Regular.ttf` i `NotoNaskhArabic.ttf`, które nie istnieją w `fonts/ttf/`. W efekcie fallback dla języków CJK i arabskich nigdy się nie uruchomi i renderowanie jest ograniczone do podstawowego `NotoSans-Regular`.
- Brakuje metadanych/etykiet językowych w `.otfont` (np. brak `script: "arabic"`), więc nie wiadomo, jak rozdzielać fonty dla RTL vs. LTR. Dodatkowo brak narzędzi do ekstrakcji `OS/2.ulUnicodeRange*` uniemożliwia potwierdzenie faktycznego zestawu glyphów dla każdej czcionki.

## Rekomendacje
1) Wprowadzić zestaw fontów produkcyjnych (TTF/OTF + `.otfont`) do `canary/data/fonts/ttf`, bo audyt warstwy 2 musi opierać się na tym artefakcie, a nie tylko na testowym drzewie.
2) Zaktualizować `NotoSans-12.otfont`, aby używał faktycznych nazw `NotoSansSC-Regular.ttf` i `NotoNaskhArabic-Regular.ttf` (najlepiej z pełną ścieżką `/fonts/ttf/...`). W ten sposób fallback faktycznie zapewni glify CJK/Arabic.
3) Dodać meta-informacje (np. `script`, `language`) do `.otfont` dla kluczowych atlasów, żeby renderer mógł wybierać właściwe fonty dla RTL i LTR.
4) Po wzbogaceniu katalogu fontów uruchomić narzędzie (historyczne `fontTools`/`pyftsubset`) i zebrać `OS/2.ulUnicodeRange*` dla każdego TTF, aby zmapować zakresy Unicode vs. języki (posłuży do raportu o pokryciu Unicode).
