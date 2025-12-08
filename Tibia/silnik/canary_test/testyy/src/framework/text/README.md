# Framework Text Stack

Ten katalog gromadzi wszystkie elementy odpowiedzialne za rendrowanie tekstu w kliencie (FreeType, HarfBuzz, FriBidi i logika fallbacków). Poniżej krótki przewodnik jak działa pipeline oraz jak dodawać nowe fonty.

## Architektura

```
UTF-8 tekst
   │
   ▼
LocaleShaping (BCP-47, kierunek pisma)
   │
   ▼
TextShaper (FriBidi + HarfBuzz → ShapedGlyph)
   │
   ▼
TTFFont (FreeType, atlas 2048×2048, glify + fallback)
   │
   ▼
CachedText / BitmapFont (CoordsBuffer + DrawPool)
```

### LocaleShaping (`LocaleShaping.cpp/.h`)
* Analizuje ciąg UTF-8 i zwraca `ShapeParams` (język, skrypt, kierunek).
* Obsługuje tagi BCP‑47, mapuje polskie nazwy języków oraz wymusza RTL dla skryptów `Arab`, `Hebr`, itp.

### TextShaper (`TextShaper.cpp/.h`)
* Łączy **FriBidi** (bidi reorder) i **HarfBuzz** (ligatury, kerning).
* Zwraca `std::vector<ShapedGlyph>` zawierający indeks glifu, codepoint, przesunięcia i advance.
* Wersja z grudnia 2025 ma prosty cache LRU (256 wpisów) unikający wielokrotnego shapingu popularnych tekstów.

### TTFFont (`TTFFont.cpp/.h`)
* Odpowiada za ładowanie TTF + fallbacków poprzez FreeType.
* Rasteryzacja jest pakowana do atlasów 2048×2048 i wysyłana do GPU przez `Texture::uploadSubPixels`.
* `drawText` grupuje quady per atlas i przekazuje je do `DrawPool`.
* API używane z `BitmapFont::drawText`, `CachedText::update` i widżetów UI.

### CachedText / BitmapFont
* `CachedText` wykrywa, czy font jest TTF (`m_font->isTTF()`), i buduje odpowiednie `CoordsBuffer` (TTF) lub klasyczny bitmapowy layout.
* `BitmapFont` nadal obsługuje starsze fonty `*.otfont` z teksturami PNG – przydatne dla konsoli, UI debugowego itd.

## Dodawanie nowego fontu TTF

1. **Plik .otfont**  
   Dodaj wpis w `data/fonts/*.otfont`. Minimalny przykład:
   ```
   Font
     name: noto-12
     type: ttf
     source: /fonts/ttf/NotoSans-Regular.ttf
     size: 12
     default: true         # jeśli ma być domyślny dla UI
     widget-default: true  # jeśli ma być domyślny dla widżetów
     fallback: [ /fonts/ttf/NotoSansSC-Regular.ttf, /fonts/ttf/NotoNaskhArabic-Regular.ttf ]
   ```
   Ścieżki są względem `data/fonts/`.

2. **Pliki .ttf**  
   Umieść TTF w `data/fonts/ttf/`. Repo zawiera już `NotoSans`, `NotoSansSC`, `NotoNaskhArabic`; kolejne warianty (np. `NotoColorEmoji`) można dołożyć w tym katalogu.

3. **Widżety/UI**  
   W `.otui` użyj `font: noto-12` (albo `font: !g_gameConfig.getSomething()` jeśli font wybierany dynamicznie).

4. **Fallbacki**  
   Łańcuch fallbacków jest ważny w przypadkach mieszanego języka, np. łaciński + CJK + arabskie. TTFFont, po nieudanym rastrze w głównym foncie, iteruje po fallbackach (`FT_Get_Char_Index`) i renderuje glif z odpowiedniego atlasu.

## Debugowanie / wskazówki

* `TTFFont::load` zwraca `false`, jeśli FreeType nie znalazł pliku – sprawdź logi `g_logger`.
* Gdy nowe teksty nie pojawiają się w tłumaczeniach, dopisz klucze w `modules/client_locales/neededtranslations.lua`.
* `g_drawPool` ma metody debugowe (`/showdrawpool`), które pomagają potwierdzić, że batching TTF działa.
* W testach (np. `tests/text/test_textshaper.cpp`) używamy systemowych fontów – jeśli chcesz testować TTF, pamiętaj o środowisku z kontekstem OpenGL.

## TODO / dalsze kroki

* Testy jednostkowe TTFFont (głównie w środowisku z GL).
* Smoke test UI w CI – wygenerowanie przykładowego tekstu w headless trybie.
* Obsługa caret/selection na poziomie grapheme clusters (wymaga danych Unicode/ICU).
