# FAZA 2 - Kompletna obsługa Unicode w OTClient

## Spis treści
1. [Przegląd architektury](#przegląd-architektury)
2. [FAZA 2A - UIWidget i komponenty pochodne](#faza-2a---uiwidget-i-komponenty-pochodne)
3. [FAZA 2B - Client-side text rendering](#faza-2b---client-side-text-rendering)
4. [Checklist kompilacji](#checklist-kompilacji)
5. [Krytyczne uwagi implementacyjne](#krytyczne-uwagi-implementacyjne)

---

## Przegląd architektury

### Hierarchia komponentów tekstowych w OTC

```
BitmapFont (bitmapfont.cpp)
├── isTTF() → TTF path (drawText via TTFFont)
└── !isTTF() → Bitmap path (8-bit glyph indexing)

CachedText (cachedtext.cpp)
├── draw() → sprawdza isTTF()
│   ├── TTF: drawTTF() → używa m_ttfGlyphs, m_ttfBatches
│   └── Bitmap: fillTextCoords() → używa m_glyphsPositions
└── Używany przez: StaticText, AnimatedText, Creature names

UIWidget (uiwidget.h/uiwidgettext.cpp)
├── m_text (UTF-8 string)
├── m_font (BitmapFontPtr)
├── drawText() → bitmap-only path currently
└── Dziedziczą: UILabel, UIButton, UITextList, UICheckBox, etc.

UITextEdit (uitextedit.cpp) ← NAPRAWIONY W FAZIE 1
├── m_text32 (std::u32string - codepoints)
├── m_cursorPos, m_selectionStart, m_selectionEnd → indeksy codepoint
└── Guardy dla TTF vs bitmap
```

### Stan obecny po FAZIE 0 i FAZIE 1

| Komponent | Stan | Uwagi |
|-----------|------|-------|
| TTFFont.cpp | ✅ Kompletny | getRealPath(), fallback fonts |
| BitmapFont.cpp | ✅ Kompletny | TTF loading, guardy |
| Utf8.h | ✅ Kompletny | Wszystkie funkcje pomocnicze |
| UITextEdit | ✅ Naprawiony | m_text32, codepoint-based operations |
| UIWidget/text | ⚠️ Do naprawy | Bitmap-only drawText() |
| CachedText | ⚠️ Częściowo | TTF path istnieje, ale wymaga review |
| StaticText | ⚠️ Do sprawdzenia | text.length() dla delay |
| AnimatedText | ⚠️ Do sprawdzenia | merge logic |

---

## FAZA 2A - UIWidget i komponenty pochodne

### 2A.1 - uiwidgettext.cpp - drawText() dla TTF

**Problem**: `UIWidget::drawText()` używa wyłącznie bitmap path:
- `fillTextCoords()` / `fillTextColorCoords()` - tylko bitmap
- `g_drawPool.addTexturedCoordsBuffer()` - zakłada bitmap texture

**Rozwiązanie**: Dodać TTF branch podobny do UITextEdit:

```cpp
void UIWidget::drawText(const Rect& screenCoords)
{
    if (m_drawText.empty() || m_color.aF() == 0.f || !m_font)
        return;

    // TTF font path - use font's drawText which handles shaping
    if (m_font->isTTF()) {
        auto coords = screenCoords;
        auto textOffset = m_textOffset;
        textOffset.scale(m_fontScale);
        coords.translate(textOffset);
        
        g_drawPool.scale(m_fontScale);
        g_drawPool.setDrawOrder(m_textDrawOrder);
        m_font->drawText(m_drawText, coords, m_color, m_textAlign);
        g_drawPool.resetDrawOrder();
        g_drawPool.scale(1.f);
        return;
    }

    // Bitmap font path (existing code)
    // ... existing bitmap code ...
}
```

**Pliki do edycji**:
- `src/framework/ui/uiwidgettext.cpp` - główna zmiana

**Zadania**:
- [ ] 2A.1.1 - Dodać guard `if (m_font->isTTF())` na początku `drawText()`
- [ ] 2A.1.2 - Implementować TTF rendering przez `m_font->drawText()`
- [ ] 2A.1.3 - Zachować existing bitmap code w else branch
- [ ] 2A.1.4 - Test: UILabel z polskimi znakami

---

### 2A.2 - uiwidgettext.cpp - updateText() dla TTF

**Problem**: `UIWidget::updateText()` wywołuje:
```cpp
m_font->calculateGlyphsPositions(m_drawText, m_textAlign, m_glyphsPositionsCache, &m_textSize);
```

Dla TTF fontów `calculateGlyphsPositions()` nie robi nic sensownego (glyphsPositions nie są używane).

**Rozwiązanie**: Dla TTF używać `calculateTextRectSize()`:

```cpp
void UIWidget::updateText()
{
    if (isTextWrap() && m_rect.isValid()) {
        m_drawTextColors = m_textColors;
        m_drawText = m_font->wrapText(m_text, getWidth() - m_textOffset.x);
    } else {
        m_drawText = m_text;
        m_drawTextColors = m_textColors;
    }

    if (m_font) {
        if (m_font->isTTF()) {
            // TTF: use calculateTextRectSize for bounding box only
            m_textSize = m_font->calculateTextRectSize(m_drawText);
            m_glyphsPositionsCache.clear(); // not used for TTF
        } else {
            // Bitmap: calculate per-glyph positions
            m_font->calculateGlyphsPositions(m_drawText, m_textAlign, m_glyphsPositionsCache, &m_textSize);
        }
    }

    // ... rest of existing code ...
}
```

**Zadania**:
- [ ] 2A.2.1 - Dodać TTF branch w `updateText()`
- [ ] 2A.2.2 - Użyć `calculateTextRectSize()` dla TTF
- [ ] 2A.2.3 - Wyczyścić `m_glyphsPositionsCache` dla TTF
- [ ] 2A.2.4 - Test: auto-resize widgets z TTF

---

### 2A.3 - Kolorowy tekst dla TTF

**Problem**: `setColoredText()` i `m_drawTextColors` nie działają z TTF.

**Obecny stan**: TTF path w `drawText()` ignoruje kolory (używa pojedynczego `m_color`).

**Rozwiązanie**: Dla TTF z kolorami trzeba:
1. Parse color ranges
2. Dla każdego range wywołać `m_font->drawText()` z odpowiednim substring

**To jest OPCJONALNE** - można to pominąć jeśli kolorowy tekst nie jest używany w UI.

**Zadania**:
- [ ] 2A.3.1 - Sprawdzić czy `setColoredText()` jest używane w Lua/OTUI
- [ ] 2A.3.2 - Jeśli tak: implementować per-color-range rendering dla TTF
- [ ] 2A.3.3 - Jeśli nie: dodać warning log gdy TTF + colors

---

### 2A.4 - Font scale dla TTF

**Problem**: `m_fontScale` jest używane do skalowania bitmap rendering. Dla TTF może wymagać innego podejścia.

**Sprawdzić**:
- Czy `g_drawPool.scale()` działa poprawnie z TTF?
- Czy tekstury TTF są skalowane prawidłowo?

**Zadania**:
- [ ] 2A.4.1 - Test: `font-scale: 2.0` w OTUI z TTF font
- [ ] 2A.4.2 - Jeśli nie działa: naprawić skalowanie w TTF path

---

### 2A.5 - Include Utf8.h gdzie potrzebne

**Problem**: Niektóre pliki mogą potrzebować funkcji z Utf8.h.

**Pliki do sprawdzenia**:
- `uiwidgettext.cpp` - czy używa długości tekstu?
- `uiwidget.cpp` - onTextChange, etc.

**Zadania**:
- [ ] 2A.5.1 - Przejrzeć wszystkie `m_text.length()` w UI
- [ ] 2A.5.2 - Ocenić czy powinny być w codepoints
- [ ] 2A.5.3 - Dodać `#include <framework/text/Utf8.h>` gdzie potrzebne

---

## FAZA 2B - Client-side text rendering

### 2B.1 - CachedText - review TTF path

**Stan**: `CachedText::draw()` już ma TTF branch (`drawTTF()`).

**Do sprawdzenia**:
1. Czy `update()` poprawnie buduje `m_ttfGlyphs` dla Unicode?
2. Czy `rebuildTTFCoords()` działa z polskimi znakami?
3. Czy `wrapText()` działa z Unicode?

**Pliki**:
- `src/framework/graphics/cachedtext.cpp`
- `src/framework/graphics/cachedtext.h`

**Zadania**:
- [ ] 2B.1.1 - Review `CachedText::update()` dla TTF
- [ ] 2B.1.2 - Test: StaticText z polskimi znakami
- [ ] 2B.1.3 - Test: AnimatedText z polskimi znakami

---

### 2B.2 - StaticText - delay calculation

**Problem** (linia 74 w statictext.cpp):
```cpp
int delay = std::max<int>(g_gameConfig.getStaticDurationPerCharacter() * text.length(), ...);
```

`text.length()` zwraca bajty UTF-8, nie znaki! Dla "żółć" (4 znaki polskie) zwróci 8 bajtów.

**Rozwiązanie**:
```cpp
#include <framework/text/Utf8.h>

int delay = std::max<int>(
    g_gameConfig.getStaticDurationPerCharacter() * otc::text::utf8Length(text), 
    g_gameConfig.getMinStatictextDuration()
);
```

**Zadania**:
- [ ] 2B.2.1 - Dodać include Utf8.h do statictext.cpp
- [ ] 2B.2.2 - Zmienić `text.length()` na `otc::text::utf8Length(text)`
- [ ] 2B.2.3 - Test: Say "żółć" i sprawdzić czas wyświetlania

---

### 2B.3 - AnimatedText - merge logic

**Problem**: `AnimatedText::merge()` może mieć problemy z tekstem Unicode.

**Do sprawdzenia**:
- `safe_cast<int>(m_cachedText.getText())` - czy działa z Unicode digits?
- Prawdopodobnie OK bo używa tylko cyfr (damage numbers)

**Zadania**:
- [ ] 2B.3.1 - Review `AnimatedText::merge()`
- [ ] 2B.3.2 - Upewnić się że działa z numerycznymi tekstami

---

### 2B.4 - Creature names / health bars

**Problem**: Nazwy stworzeń są wyświetlane przez system tekstowy.

**Pliki**:
- `src/client/creature.cpp` - `m_name`, `drawInformation()`

**Zadania**:
- [ ] 2B.4.1 - Sprawdzić jak nazwy są renderowane
- [ ] 2B.4.2 - Test: Stworzenie z polską nazwą (NPC)
- [ ] 2B.4.3 - Test: Gracz z polską nazwą

---

### 2B.5 - Item/Tile text

**Pliki**:
- `src/client/item.cpp` - `setText()`
- `src/client/tile.cpp` - `setText()`

**Zadania**:
- [ ] 2B.5.1 - Review Item::setText()
- [ ] 2B.5.2 - Review Tile::setText()
- [ ] 2B.5.3 - Test: Item description z polskimi znakami

---

### 2B.6 - Console / Chat messages

**Problem**: Wiadomości czatu muszą obsługiwać Unicode.

**Ścieżka renderowania**:
1. `protocolgameparse.cpp` - odbiera tekst z serwera
2. `game.cpp` - processuje wiadomości
3. UI (Lua) - wyświetla w konsoli

**Zadania**:
- [ ] 2B.6.1 - Sprawdzić czy protokół przesyła UTF-8
- [ ] 2B.6.2 - Test: NPC mówi po polsku
- [ ] 2B.6.3 - Test: Gracz pisze po polsku w czacie

---

## Checklist kompilacji

### Wymagane pliki do modyfikacji

| Plik | FAZA | Priorytet | Status |
|------|------|-----------|--------|
| `src/framework/ui/uiwidgettext.cpp` | 2A.1, 2A.2 | HIGH | ⬜ |
| `src/client/statictext.cpp` | 2B.2 | MEDIUM | ⬜ |
| `src/framework/graphics/cachedtext.cpp` | 2B.1 | MEDIUM | ⬜ |
| `src/client/creature.cpp` | 2B.4 | LOW | ⬜ |

### Testy do przeprowadzenia

| Test | Komponent | Opis |
|------|-----------|------|
| T1 | UILabel | Wyświetl "Zapamiętaj hasło" |
| T2 | UIButton | Przycisk "Połącz" |
| T3 | UITextEdit | Wpisz "żółć" i backspace |
| T4 | StaticText | NPC mówi "Cześć!" |
| T5 | AnimatedText | Damage number (nie Unicode) |
| T6 | Creature name | NPC z polską nazwą |
| T7 | Chat | Wiadomość "Witaj świecie!" |

### Kolejność implementacji

```
1. FAZA 2A.1 - UIWidget::drawText() TTF branch (KRYTYCZNE)
2. FAZA 2A.2 - UIWidget::updateText() TTF branch
3. FAZA 2B.1 - CachedText review
4. FAZA 2B.2 - StaticText delay fix
5. BUILD & TEST podstawowy
6. FAZA 2B.4-2B.6 - pozostałe komponenty client-side
7. FAZA 2A.3-2A.5 - opcjonalne (colored text, font scale)
```

---

## Notatki techniczne

### Różnica między text.length() a codepoint count

```cpp
std::string text = "żółć";       // 4 polskie znaki
text.length();                   // = 8 (bajty UTF-8!)
otc::text::utf8Length(text);     // = 4 (codepoints)
```

### Konwersja w razie potrzeby

```cpp
#include <framework/text/Utf8.h>

// UTF-8 → codepoints
std::u32string codepoints = otc::text::utf8ToU32(utf8String);

// Codepoints → UTF-8
std::string utf8 = otc::text::u32ToUtf8(codepoints);

// Liczba znaków
size_t charCount = otc::text::utf8Length(utf8String);

// Offset bajtu dla n-tego codepoint
size_t byteOffset = otc::text::utf8ByteOffset(utf8String, codepointIndex);
```

### TTF vs Bitmap flow

```
TTF Font:
  setText() → updateText() → calculateTextRectSize()
  drawText() → m_font->drawText() → TTFFont::drawText() → HarfBuzz shaping → Glyph atlas

Bitmap Font:
  setText() → updateText() → calculateGlyphsPositions()
  drawText() → fillTextCoords() → static_cast<uint8_t>(text[i]) → 8-bit glyph lookup
```

---

## Podsumowanie

**FAZA 2A** (UI Framework):
- Główne zadanie: Dodać TTF path do `UIWidget::drawText()` i `updateText()`
- Priorytet: **KRYTYCZNY** - bez tego żaden UI widget nie wyświetli polskich znaków

**FAZA 2B** (Client-side):
- Główne zadanie: Fix `text.length()` → `utf8Length()`, review CachedText
- Priorytet: **WYSOKI** - dotyczy in-game text (NPC, chat, damage)

**Szacowany czas**:
- FAZA 2A: ~2-3h implementacji + testy
- FAZA 2B: ~2-4h review + implementacji + testy

---

## Krytyczne uwagi implementacyjne

### ⚠️ UWAGA 1: DrawPool state management (2A.1)

**Problem**: `g_drawPool.scale(m_fontScale)` + `g_drawPool.scale(1.f)` może:
- Nie przywrócić poprzedniego stanu (jeśli był zagnieżdżony)
- Spowodować "losowe" bugi w UI przy zagnieżdżonym rysowaniu

**Aktualna implementacja DrawPool::scale()**:
```cpp
void DrawPool::scale(const float factor) {
    if (m_scale == factor) return;
    m_scale = factor;
    getCurrentState().transformMatrix = DEFAULT_MATRIX3 * Matrix3{...};
}
```

**Problem**: Nie ma push/pop! Ustawia absolutną wartość.

**Rozwiązanie**: Zapisać poprzedni stan przed zmianą:
```cpp
// TTF path in UIWidget::drawText()
if (m_font->isTTF()) {
    const float prevScale = g_drawPool.getScale();  // jeśli istnieje getter
    // ... lub użyj m_fontScale tylko jeśli != 1.0
    
    if (m_fontScale != 1.0f) {
        g_drawPool.scale(m_fontScale);
    }
    
    m_font->drawText(...);
    
    if (m_fontScale != 1.0f) {
        g_drawPool.scale(prevScale);  // przywróć poprzedni stan
    }
    return;
}
```

**Alternatywa** (jeśli brak gettera): Nie używać scale() wcale dla TTF, tylko przekazać fontScale do TTFFont::drawText() i skalować tam.

---

### ⚠️ UWAGA 2: wrapText i fontScale (2A.2)

**Problem**: W `updateText()`:
```cpp
m_drawText = m_font->wrapText(m_text, getWidth() - m_textOffset.x);
```

Dla `font-scale: 2.0` szerokość dostępna powinna być:
```cpp
int availableWidth = (getWidth() - m_textOffset.x) / m_fontScale;
```

Inaczej tekst będzie łamany "za wcześnie" lub "za późno".

**Dodatkowo**: `wrapText()` iteruje po bajtach (`word[j]`), co może rozbić multibyte UTF-8!

```cpp
// PROBLEM w bitmapfont.cpp wrapText():
for (uint32_t j = 0; j < word.length(); ++j) {
    std::string candidate = newWord + word[j];  // word[j] = BAJT, nie znak!
```

**Rozwiązanie dla TTF**: Implementować osobny `wrapTextTTF()` który:
1. Iteruje po codepoints (nie bajtach)
2. Uwzględnia fontScale

---

### ⚠️ UWAGA 3: calculateTextRectSize() multiline (2A.2)

**KRYTYCZNY BUG**: Obecna implementacja dla TTF NIE obsługuje `\n`!

```cpp
Size BitmapFont::calculateTextRectSize(const std::string_view text) {
    if (m_isTTF && m_ttf) {
        const auto text32 = otc::text::utf8ToU32(text);
        const int w = static_cast<int>(std::lround(m_ttf->measureTextWidth(text32, sp)));
        return Size(w, m_glyphHeight);  // ❌ Zwraca wysokość JEDNEJ linii!
    }
    // ...
}
```

**Dla tekstu "Linia 1\nLinia 2"**:
- Zwraca: `Size(szerokość całego tekstu, wysokość 1 linii)`
- Powinno: `Size(max szerokość linii, wysokość 2 linii)`

**Rozwiązanie**: Naprawić `calculateTextRectSize()` dla TTF:
```cpp
if (m_isTTF && m_ttf) {
    const auto text32 = otc::text::utf8ToU32(text);
    
    // Split by newlines
    int maxWidth = 0;
    int lineCount = 1;
    std::u32string currentLine;
    
    for (char32_t cp : text32) {
        if (cp == U'\n') {
            maxWidth = std::max(maxWidth, measureLine(currentLine));
            currentLine.clear();
            ++lineCount;
        } else {
            currentLine += cp;
        }
    }
    maxWidth = std::max(maxWidth, measureLine(currentLine));
    
    return Size(maxWidth, m_glyphHeight * lineCount);
}
```

---

### ⚠️ UWAGA 4: Colored text - świadoma decyzja (2A.3)

**Opcja A** (jeśli NIE używane w UI):
```cpp
if (m_font->isTTF() && !m_drawTextColors.empty()) {
    g_logger.warning("TTF fonts do not support colored text segments yet");
    // Render single-color fallback
    m_font->drawText(m_drawText, coords, m_color, m_textAlign);
    return;
}
```

**Opcja B** (jeśli UŻYWANE):
```cpp
// Render per-color-range segments
int lastEnd = 0;
for (const auto& [startIdx, color] : m_drawTextColors) {
    std::string segment = m_drawText.substr(lastEnd, startIdx - lastEnd);
    // ... calculate segment offset, render with color
}
```

**Decyzja**: Sprawdzić grep `setColoredText` w modules/ i podjąć decyzję.

---

### Dodatkowe testy

| Test | Komponent | Opis |
|------|-----------|------|
| T8 | RTL/Arabic | UILabel z "مرحبا" (Arabic: "Hello") |
| T9 | Multiline | UILabel z "Linia 1\nLinia 2\nLinia 3" |
| T10 | FontScale | UILabel z font-scale: 2.0 i polskim tekstem |
| T11 | WrapText | Długi tekst w wąskim UIWidget |

---

*Dokument zaktualizowany: 14 grudnia 2025*
*Status: GOTOWY DO IMPLEMENTACJI (z uwagami krytycznymi)*
