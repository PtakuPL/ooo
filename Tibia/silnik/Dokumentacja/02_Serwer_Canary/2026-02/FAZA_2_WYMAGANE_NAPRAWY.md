# FAZA 2 - LISTA NAPRAW (WSZYSTKIE ZAIMPLEMENTOWANE)

Data aktualizacji: 2025-01-XX

## STATUS: WSZYSTKIE NAPRAWY ZAKOŃCZONE ✅

---

## 1. Unicode Case Conversion (DONE ✅)

**Plik:** `src/framework/stdext/string.cpp`

**Problem:** `toupper()`, `tolower()`, `ucwords()` używały ASCII konwersji - "żółw" nie zamieniało się na "Żółw"

**Rozwiązanie:**
- Dodano `#include <framework/text/Utf8.h>`
- Dodano helpery `unicodeToUpper()`, `unicodeToLower()` z mapowaniami dla:
  - Polskich znaków: ąćęłńóśźż ↔ ĄĆĘŁŃÓŚŹŻ
  - Niemieckich: äöüß ↔ ÄÖÜß
  - Czeskich/Słowackich: čďěňřšťůýž ↔ ČĎĚŇŘŠŤŮÝŽ
- Przepisano wszystkie trzy funkcje aby konwertować UTF-8 → UTF-32, aplikować konwersję per-codepoint, konwertować z powrotem

---

## 2. Kolorowy tekst dla TTF (DONE ✅)

**Pliki:** 
- `src/framework/graphics/bitmapfont.h`
- `src/framework/graphics/bitmapfont.cpp`
- `src/framework/ui/uiwidgettext.cpp`

**Problem:** `setColoredText()` nie działał dla TTF - tekst renderował się jednokolorowo

**Rozwiązanie:**
- Dodano nową metodę `BitmapFont::drawColoredText()`:
  - Konwertuje pozycje bajtowe z `textColors` na pozycje codepointów
  - Dzieli tekst na segmenty kolorowe
  - Renderuje każdy segment osobno z odpowiednim kolorem
- Zaktualizowano `UIWidget::drawText()` żeby używać `drawColoredText()` gdy są kolory

---

## 3. UITextEdit cursor operations (DONE ✅)

**Plik:** `src/framework/ui/uitextedit.cpp`

**Problem:** Wszystkie operacje kursora używały `m_text.length()` zamiast `m_text32.size()`

**Rozwiązanie:** Zamieniono we wszystkich miejscach:
- `onStyleApply`: `m_text.length()` → `m_text32.size()`
- `onFocusChange`: `m_text.length()` → `m_text32.size()`
- `onDoubleClick`: `m_text.length()` → `m_text32.size()`
- `drawSelf`: `textLength = m_text.length()` → `textLength = m_text32.size()`

---

## 4. UITextEdit::getTextPos() TTF branch (DONE ✅)

**Plik:** `src/framework/ui/uitextedit.cpp`

**Problem:** `getTextPos()` iterowała po bajtach dla pozycjonowania

**Rozwiązanie:** Dodano branch TTF który używa `TTFFont::measureTextWidth()` dla pomiaru

---

## 5. wrapText() TTF codepoint iteration (DONE ✅)

**Plik:** `src/framework/graphics/bitmapfont.cpp`

**Problem:** `wrapText()` iterował po bajtach zamiast codepointach dla TTF

**Rozwiązanie:** Dla TTF path używamy konwersji UTF-8 ↔ UTF-32 i iteracji po codepointach

---

## 6. calculateTextRectSize() multiline (DONE ✅)

**Plik:** `src/framework/graphics/bitmapfont.cpp`

**Problem:** Funkcja nie obsługiwała wieloliniowego tekstu dla TTF

**Rozwiązanie:** Dodano obsługę newline'ów (`\n`) dla TTF path

---

## 7. StaticText delay utf8Length() (DONE ✅)

**Plik:** `src/client/statictext.cpp`

**Problem:** Obliczanie opóźnienia używało bajtów zamiast codepointów

**Rozwiązanie:** Użyto `otc::text::utf8Length()` dla policzenia codepointów

---

## 8. Guard verification (DONE ✅)

Wszystkie bitmap-only funkcje mają poprawne guardy:

| Funkcja | Guard | Status |
|---------|-------|--------|
| `getDrawTextCoords()` | bitmap-only, nie wywoływana dla TTF | ✅ |
| `fillTextCoords()` | bitmap-only path w UIWidget::drawText() | ✅ |
| `fillTextColorCoords()` | bitmap-only path w UIWidget::drawText() | ✅ |
| `calculateGlyphsPositions()` | bitmap path + wymiar TTF w calculateTextRectSize | ✅ |

---

## 9. UIWidget TTF branches (DONE ✅)

**Plik:** `src/framework/ui/uiwidgettext.cpp`

- `drawText()`: TTF branch z `BitmapFont::drawText()`/`drawColoredText()`
- `updateText()`: TTF branch z `calculateTextRectSize()` która obsługuje TTF

---

## WERYFIKACJA PRZED BUILDEM

Wszystkie powyższe naprawy zostały zaimplementowane. Projekt gotowy do kompilacji i testów.

### Pliki zmodyfikowane w tej sesji:
1. `src/framework/stdext/string.cpp` - Unicode case conversion
2. `src/framework/graphics/bitmapfont.h` - deklaracja `drawColoredText()`
3. `src/framework/graphics/bitmapfont.cpp` - implementacja `drawColoredText()`, include `<algorithm>`
4. `src/framework/ui/uiwidgettext.cpp` - użycie `drawColoredText()` dla kolorowego tekstu
