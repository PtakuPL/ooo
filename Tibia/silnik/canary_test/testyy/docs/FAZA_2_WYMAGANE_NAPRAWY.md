# FAZA 2 - WYMAGANE NAPRAWY PRZED BUILDEM

## STATUS: 🔴 NIE GOTOWE DO BUILDU

Ten dokument zawiera **WSZYSTKIE** rzeczy które MUSZĄ być naprawione przed kompilacją.
NIE MA "zrobimy później" - wszystko tutaj musi być zaimplementowane.

---

## 1. FUNKCJE STRING - CASE CONVERSION (KRYTYCZNE)

### 1.1 `stdext::ucwords()` - ❌ NIE NAPRAWIONE

**Plik**: `src/framework/stdext/string.cpp` linia 169

**Problem**: Iteruje po bajtach, nie codepoints:
```cpp
void ucwords(std::string& str) {
    bool capitalize = true;
    for (char& c : str) {  // ❌ iteruje po BAJTACH!
        if (std::isspace(static_cast<unsigned char>(c)))
            capitalize = true;
        else if (capitalize) {
            c = std::toupper(static_cast<unsigned char>(c));  // ❌ tylko ASCII!
            capitalize = false;
        }
    }
}
```

**Skutki**:
- "żółw" → "Żółw" NIE ZADZIAŁA (ż jest multi-byte)
- Polskie znaki: ą→Ą, ć→Ć, ę→Ę, ł→Ł, ń→Ń, ó→Ó, ś→Ś, ź→Ź, ż→Ż NIE DZIAŁAJĄ

**Gdzie używane**:
- `src/client/creatures.cpp` linia 69, 158, 295, 341
- Lua global function `ucwords()`

**Rozwiązanie**: Użyć ICU lub własnej mapy Polish uppercase:
```cpp
#include <framework/text/Utf8.h>

void ucwords(std::string& str) {
    auto text32 = otc::text::utf8ToU32(str);
    bool capitalize = true;
    for (char32_t& cp : text32) {
        if (cp == U' ' || cp == U'\t' || cp == U'\n') {
            capitalize = true;
        } else if (capitalize) {
            cp = unicodeToUpper(cp);  // mapa dla polskich znaków
            capitalize = false;
        }
    }
    str = otc::text::u32ToUtf8(text32);
}

// Pomocnicza funkcja dla polskich znaków
char32_t unicodeToUpper(char32_t cp) {
    switch (cp) {
        case U'ą': return U'Ą';
        case U'ć': return U'Ć';
        case U'ę': return U'Ę';
        case U'ł': return U'Ł';
        case U'ń': return U'Ń';
        case U'ó': return U'Ó';
        case U'ś': return U'Ś';
        case U'ź': return U'Ź';
        case U'ż': return U'Ż';
        default:
            if (cp < 128) return static_cast<char32_t>(std::toupper(static_cast<int>(cp)));
            return cp;  // Inne znaki - bez zmiany
    }
}
```

---

### 1.2 `stdext::toupper()` - ❌ NIE NAPRAWIONE

**Plik**: `src/framework/stdext/string.cpp` linia 161

**Problem**:
```cpp
void toupper(std::string& str) { 
    std::ranges::transform(str, str.begin(), ::toupper);  // ❌ tylko ASCII!
}
```

**Gdzie używane**:
- `src/framework/ui/uiwidgettext.cpp` linia 203, 253 (PropTextOnlyUpperCase)
- Powoduje że `text-only-upper-case: true` w OTUI NIE DZIAŁA dla polskich znaków

**Rozwiązanie**: Podobna jak ucwords, użyć mapy Polish uppercase.

---

### 1.3 `stdext::tolower()` - ❌ NIE NAPRAWIONE

**Plik**: `src/framework/stdext/string.cpp` linia 162

**Problem**: Analogiczny do toupper.

**Rozwiązanie**: Analogiczna mapa lowercase.

---

## 2. COLORED TEXT dla TTF (WAŻNE)

### 2.1 Status obecny

**Plik**: `src/framework/ui/uiwidgettext.cpp` drawText()

**Problem**: TTF path tylko loguje warning i renderuje jednym kolorem:
```cpp
if (!m_drawTextColors.empty()) {
    static bool warnedOnce = false;
    if (!warnedOnce) {
        g_logger.warning("UIWidget: Colored text not yet supported with TTF fonts");
        warnedOnce = true;
    }
}
m_font->drawText(m_drawText, drawArea, m_color, m_textAlign);  // ignoruje kolory!
```

### 2.2 Sprawdzenie czy używane

**Komenda do wykonania**:
```bash
grep -r "setColoredText\|coloredText" testyy/modules/
grep -r "coloredText" testyy/data/
```

**JEŚLI UŻYWANE**: Wymaga implementacji per-segment rendering:
```cpp
if (m_font->isTTF() && !m_drawTextColors.empty()) {
    // Renderuj każdy segment osobno z odpowiednim kolorem
    int currentPos = 0;
    for (size_t i = 0; i < m_drawTextColors.size(); ++i) {
        const int startIdx = (i == 0) ? 0 : m_drawTextColors[i-1].first;
        const int endIdx = m_drawTextColors[i].first;
        const Color& segColor = (i == 0) ? m_color : m_drawTextColors[i-1].second;
        
        // Oblicz offset dla segmentu
        std::string prefix = m_drawText.substr(0, startIdx);
        int offsetX = m_font->calculateTextRectSize(prefix).width();
        
        std::string segment = m_drawText.substr(startIdx, endIdx - startIdx);
        Rect segRect = drawArea;
        segRect.translate(offsetX, 0);
        
        m_font->drawText(segment, segRect, segColor, Fw::AlignLeft);
    }
    return;
}
```

**JEŚLI NIE UŻYWANE**: Zostawić warning log (obecny stan jest OK).

---

## 3. WERYFIKACJA GUARDÓW TTF vs BITMAP

### 3.1 Funkcje które MUSZĄ mieć guard `if (!m_font->isTTF())`

Te funkcje operują na indeksach bajtowych i są TYLKO dla bitmap:

| Funkcja | Plik | Guard |
|---------|------|-------|
| `calculateGlyphsPositions()` | bitmapfont.cpp | ✅ Wewnętrzna (bitmap-only) |
| `getDrawTextCoords()` | bitmapfont.cpp | ✅ Wewnętrzna (bitmap-only) |
| `fillTextCoords()` | bitmapfont.cpp | ✅ Wewnętrzna (bitmap-only) |
| `fillTextColorCoords()` | bitmapfont.cpp | ✅ Wewnętrzna (bitmap-only) |

### 3.2 Miejsca wywołań - weryfikacja guardów

| Wywołanie | Plik | Linia | Guard TTF |
|-----------|------|-------|-----------|
| `calculateGlyphsPositions()` | uiwidgettext.cpp | 60 | ✅ `if (!m_font->isTTF())` |
| `fillTextCoords()` | uiwidgettext.cpp | 173 | ✅ (w else branch) |
| `fillTextColorCoords()` | uiwidgettext.cpp | 175 | ✅ (w else branch) |
| `calculateGlyphsPositions()` | uitextedit.cpp | 211 | ✅ `if (!m_font->isTTF())` |
| `fillTextCoords()` | cachedtext.cpp | 54 | ✅ (w else branch po isTTF check) |
| `calculateGlyphsPositions()` | cachedtext.cpp | 172 | ✅ (w else branch) |
| `calculateGlyphsPositions()` | bitmapfont.cpp | 224 | ✅ (wewnątrz drawText bitmap path) |
| `getDrawTextCoords()` | bitmapfont.cpp | 225 | ✅ (wewnątrz drawText bitmap path) |
| `calculateGlyphsPositions()` | bitmapfont.cpp | 612 | ✅ (wewnątrz calculateTextRectSize bitmap path) |

**STATUS**: ✅ Wszystkie wywołania mają poprawne guardy.

---

## 4. FUNKCJE NAPRAWIONE - WERYFIKACJA

### 4.1 `wrapText()` - ✅ NAPRAWIONE

**Plik**: `src/framework/graphics/bitmapfont.cpp` linia 647-725

**Zmiana**: TTF path iteruje po codepoints:
```cpp
if (m_isTTF) {
    const std::u32string word32 = otc::text::utf8ToU32(word);
    std::u32string newWord32;
    for (size_t j = 0; j < word32.size(); ++j) {
        // ... iteruje po codepoints
    }
}
```

### 4.2 `calculateTextRectSize()` multiline - ✅ NAPRAWIONE

**Plik**: `src/framework/graphics/bitmapfont.cpp` linia 569-610

**Zmiana**: Obsługuje `\n` dla TTF.

### 4.3 `StaticText::addMessage()` delay - ✅ NAPRAWIONE

**Plik**: `src/client/statictext.cpp` linia 73

**Zmiana**: `utf8Length(text)` zamiast `text.length()`.

### 4.4 UITextEdit cursor operations - ✅ NAPRAWIONE

**Plik**: `src/framework/ui/uitextedit.cpp`

**Zmiany**:
- `onStyleApply`: `m_text32.size()` zamiast `m_text.length()`
- `onFocusChange`: `m_text32.size()` zamiast `m_text.length()`
- `onDoubleClick`: `!m_text32.empty()` zamiast `m_text.length() > 0`
- `drawSelf textLength`: TTF używa `m_text32.size()`
- `getTextPos()`: Nowy TTF branch z width-based detection

---

## 5. CHECKLIST PRZED BUILDEM

### 5.1 Wymagane naprawy (BLOKUJĄCE)

- [ ] **1.1** `stdext::ucwords()` - naprawić dla Unicode
- [ ] **1.2** `stdext::toupper()` - naprawić dla Unicode
- [ ] **1.3** `stdext::tolower()` - naprawić dla Unicode
- [ ] **2.1** Sprawdzić czy colored text jest używane w modules/

### 5.2 Opcjonalne (NIE BLOKUJĄCE)

- [ ] **2.2** Jeśli colored text używane: implementować per-segment rendering
- [ ] Test RTL (Arabic) - może działać przez HarfBuzz

### 5.3 Zrobione

- [x] `wrapText()` TTF codepoint iteration
- [x] `calculateTextRectSize()` multiline
- [x] `StaticText::addMessage()` utf8Length
- [x] UITextEdit cursor operations
- [x] UIWidget::drawText() TTF branch
- [x] UIWidget::updateText() TTF branch
- [x] Weryfikacja guardów bitmap-only functions

---

## 6. PO NAPRAWACH - TESTY

| ID | Test | Opis | Status |
|----|------|------|--------|
| T1 | UILabel | "Zapamiętaj hasło" | ⬜ |
| T2 | UIButton | "Połącz" | ⬜ |
| T3 | UITextEdit | "żółć" + backspace | ⬜ |
| T4 | StaticText | NPC: "Cześć!" | ⬜ |
| T5 | Creature name | Creature z "Żółw" | ⬜ |
| T6 | ucwords | "żółw wielki" → "Żółw Wielki" | ⬜ |
| T7 | toupper | "żółć" → "ŻÓŁĆ" | ⬜ |
| T8 | Multiline | "Linia 1\nLinia 2" | ⬜ |
| T9 | WrapText | Długi polski tekst | ⬜ |
| T10 | FontScale | font-scale: 2.0 | ⬜ |

---

*Ostatnia aktualizacja: 14 grudnia 2025*
*Status: WYMAGA NAPRAW PRZED BUILDEM*
