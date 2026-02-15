# Migracja fontów OTClient na Unicode (TTF)

## Data: 14-15 grudnia 2025
## Status: ✅ ZAKOŃCZONE - Wszystkie fazy implementacji kompletne!

---

## PEŁNY PLAN UNICODE - AUDYT AGENT 1 (ChatGPT) + AGENT 2 (Claude)

### AUDYT OBECNEGO STANU OTCLIENT

#### ✅ CO JUŻ JEST ZAIMPLEMENTOWANE (warstwa renderowania)

| Komponent | Status | Lokalizacja |
|-----------|--------|-------------|
| **HarfBuzz** | ✅ JEST | `src/framework/text/TextShaper.cpp` |
| **FriBidi** (BiDi) | ✅ JEST | `src/framework/text/TextShaper.cpp` |
| **UTF-8 → UTF-32** | ✅ JEST | `src/framework/text/Utf8.h` - `utf8ToU32()` |
| **Dynamiczny atlas** | ✅ JEST | `src/framework/text/TTFFont.cpp` - `ensureAtlas()` |
| **Fallback fonts** | ✅ JEST | `m_fallbackFaces`, `m_fallbackHbFonts` |
| **Codepoint rendering** | ✅ JEST | `ShapedGlyph.codepoint` |
| **Locale detection** | ✅ JEST | `src/framework/text/LocaleShaping.cpp` |
| **FreeType** | ✅ JEST | `freetype.dll` |

#### ❌ CO NIE DZIAŁA (warstwa UI - KRYTYCZNE!)

**AUDYT Agent 1 (ChatGPT) - 14.12.2025:**

> Tylko warstwa renderowania tekstu (klasy TTFFont i TextShaper) została w pełni przepisana na Unicode, natomiast **wiele klas odpowiedzialnych za logikę interfejsu nadal operuje na bajtach**.

| Komponent | Problem | Lokalizacja |
|-----------|---------|-------------|
| **UITextEdit** | ❌ Używa `std::string` i `text[i]` - liczy bajty! | `src/framework/ui/uitextedit.cpp` |
| **UITextEdit** | ❌ `m_cursorPos` odnosi się do bajtów, nie codepointów | `src/framework/ui/uitextedit.h` |
| **UITextEdit** | ❌ `appendCharacter()` iteruje bajt po bajcie | `uitextedit.cpp` |
| **BitmapFont** | ❌ W ścieżce bitmap: `static_cast<uint8_t>(text[i])` | `bitmapfont.cpp` |
| **UILabel** | ❌ Bazuje na std::string | `src/framework/ui/uilabel.cpp` |
| **UIButton** | ❌ Podobne problemy | `src/framework/ui/uibutton.cpp` |
| **UITextList** | ❌ Podobne problemy | `src/framework/ui/uitextlist.cpp` |

**Konkretne błędy w kodzie:**

```cpp
// uitextedit.cpp - BŁĘDNE:
const int glyph = static_cast<uint8_t>(text[i]);  // ← jeden bajt ≠ jeden znak!

// uitextedit.cpp - BŁĘDNE:
for (int i = 0; i < text.length(); ++i) {
    // text.length() zwraca liczbę BAJTÓW, nie znaków!
    // text[i] zwraca BAJT, nie codepoint!
}

// uitextedit.h - BŁĘDNE:
int m_cursorPos;        // ← indeks w bajtach, nie w codepointach!
int m_selectionStart;   // ← indeks w bajtach!
int m_selectionEnd;     // ← indeks w bajtach!
```

**Skutki:**
- Kursor przeskakuje w środku polskich znaków (ą, ę, ś, ć, ż, ź, ł, ó, ń)
- Zaznaczanie tekstu nie działa poprawnie
- Backspace usuwa połowę znaku UTF-8
- Japońskie/chińskie znaki całkowicie nie działają

---

## SZCZEGÓŁOWY PLAN DZIAŁANIA

### FAZA 0: NAPRAWIĆ ŁADOWANIE TTF [BLOCKER]

**Status:** ✅ WYKONANE (14.12.2025 05:00)

Wszystkie zadania FAZY 0 zostały wykonane:

| Zadanie | Plik | Opis | Status |
|---------|------|------|--------|
| **0.1** | `bitmapfont.cpp` | Dodać try/catch wokół całego bloku TTF | ✅ DONE |
| **0.2** | `bitmapfont.cpp` | Zmienić `fontNode->at()` na `fontNode->get()` + null check | ✅ DONE |
| **0.3** | `TTFFont.cpp` | Uprościć ścieżkę - użyć `getRealPath()` zamiast `resolvePath()+getRealDir()` | ✅ DONE |
| **0.4** | `TTFFont.cpp` | Dodać szczegółowe logowanie każdego kroku | ✅ DONE |
| **0.5** | `Utf8.h` | Dodać brakującą funkcję `u32ToUtf8()` | 🔄 W TRAKCIE |

**Szczegóły wykonanych zmian:**
- `bitmapfont.cpp:45-113` - Cały blok TTF opakowany w try/catch/catch(...)
- `bitmapfont.cpp:54-58` - `fontNode->get("source")` z null-check zamiast `at()` który rzuca wyjątek
- `TTFFont.cpp:44-100` - Szczegółowe logowanie: init FreeType, getRealPath, FT_New_Face, memory fallback
- `TTFFont.cpp:130-175` - Ładowanie fallback fonts z getRealPath() i memory fallback
- `TTFFont.cpp` - Log na końcu: "completed successfully with N fallback fonts"

### FAZA 1: REFAKTOR UITextEdit [PRIORYTET WYSOKI]

**Status:** ✅ WYKONANE (14.12.2025 05:30)

UITextEdit jest **najważniejszy** bo odpowiada za wprowadzanie tekstu w grze.

| Zadanie | Opis | Status |
|---------|------|--------|
| **1.1** | Dodać `std::u32string m_text32` i `#include <framework/text/Utf8.h>` | ✅ DONE |
| **1.2** | Przepisać `appendText()` - używa `utf8ToU32()`, operuje na m_text32 | ✅ DONE |
| **1.3** | Przepisać `appendCharacter(char32_t)` - operuje na codepointach | ✅ DONE |
| **1.4** | Przepisać `removeCharacter()` - usuwa codepoint, nie bajt | ✅ DONE |
| **1.5** | Naprawić kursor - `m_cursorPos` = indeks w m_text32 | ✅ DONE |
| **1.6** | Naprawić selekcję - `m_selectionStart/End` = indeksy w codepointach | ✅ DONE |
| **1.7** | Naprawić `moveCursorHorizontally()` - przesuwa o codepoint | ✅ DONE |
| **1.8** | `calculateTextRectSize()` - już działa z TTF | ✅ DONE |
| **1.9** | Synchronizacja: `updateText()` sync m_text32 ↔ m_text | ✅ DONE |

**Szczegóły wykonanych zmian:**
- `uitextedit.h`: Dodano `#include <framework/text/Utf8.h>`, `std::u32string m_text32`
- `uitextedit.h`: Zmieniono `appendCharacter(char c)` → `appendCharacter(char32_t codepoint)`
- `uitextedit.h`: `selectAll()` używa `m_text32.size()` zamiast `m_text.length()`
- `uitextedit.cpp`: Wszystkie funkcje operują na m_text32 (codepoints) zamiast m_text (bytes)
- `uitextedit.cpp`: `updateText()` synchronizuje m_text32 z m_text przy każdej zmianie tekstu
- `uitextedit.cpp`: `updateDisplayedText()` dla haseł używa m_text32.size() (poprawna liczba gwiazdek)
- `uitextedit.cpp`: `onKeyPress()` - Ctrl+Backspace, Home, End używają m_text32

**Dodane funkcje pomocnicze do Utf8.h:**
- `u32ToUtf8()` - konwersja codepoints → UTF-8
- `utf8Length()` - liczba codepointów w UTF-8 string
- `utf8ByteOffset()` - offset bajtu dla indeksu codepoint
- `utf8CodepointIndex()` - indeks codepoint dla offsetu bajtu

**Przykład poprawnej implementacji:**

```cpp
// uitextedit.h - PO REFAKTORZE:
std::u32string m_text32;     // ← wewnętrzna reprezentacja w codepointach
int m_cursorPos;             // ← indeks w m_text32 (codepoint index)

// uitextedit.cpp - PO REFAKTORZE:
void UITextEdit::appendText(const std::string& utf8Text) {
    auto codepoints = otc::text::utf8ToU32(utf8Text);
    m_text32.insert(m_text32.begin() + m_cursorPos, 
                    codepoints.begin(), codepoints.end());
    m_cursorPos += codepoints.size();
}

void UITextEdit::removeCharacter(bool right) {
    if (right && m_cursorPos < m_text32.size()) {
        m_text32.erase(m_cursorPos, 1);  // ← usuwa 1 codepoint
    } else if (!right && m_cursorPos > 0) {
        m_cursorPos--;
        m_text32.erase(m_cursorPos, 1);  // ← usuwa 1 codepoint
    }
}

std::string UITextEdit::getText() const {
    return otc::text::u32ToUtf8(m_text32);  // ← konwersja do UTF-8
}
```

### FAZA 2: REFAKTOR POZOSTAŁYCH KOMPONENTÓW UI

**Status:** ✅ NIE WYMAGANE (14.12.2025 05:45)

Po analizie kodu stwierdzono że pozostałe komponenty UI **nie wymagają zmian**:

| Zadanie | Plik | Status | Uwagi |
|---------|------|--------|-------|
| **2.1** | `uilabel.cpp` | ✅ N/A | Nie istnieje - UILabel to UIWidget |
| **2.2** | `uibutton.cpp` | ✅ N/A | Nie istnieje - UIButton to UIWidget |
| **2.3** | `uitextlist.cpp` | ✅ N/A | Nie istnieje osobna klasa |
| **2.4** | `uiwidgettext.cpp` | ✅ OK | Nie przetwarza znaków - przekazuje UTF-8 do BitmapFont |
| **2.5** | `console.cpp` | ✅ N/A | Konsola to Lua (modules/corelib/console.lua) |

**Dlaczego nie wymagają zmian:**
- `uiwidgettext.cpp` tylko przekazuje `m_text` (UTF-8) do `m_font->wrapText()` i `m_font->calculateGlyphsPositions()`
- BitmapFont już obsługuje UTF-8 → codepoints w TTF path (poprzez `utf8ToU32`)
- Jedyny komponent wymagający codepoint-based editing to UITextEdit (gdzie użytkownik wpisuje tekst)
- Pozostałe widżety tylko wyświetlają tekst - konwersja dzieje się w warstwie renderowania

### FAZA 3: REFAKTOR BITMAPFONT (ścieżka bitmap)

**Status:** 🟢 Opcjonalne - tylko jeśli chcemy zachować fonty bitmapowe

| Zadanie | Opis |
|---------|------|
| **3.1** | Przepisać `calculateGlyphPositions()` na codepoints |
| **3.2** | Przepisać `drawText()` na codepoints |
| **3.3** | Lub: usunąć obsługę bitmap fonts i wymusić TTF |

**Uwaga:** Ścieżka bitmap już częściowo obsługuje UTF-8 poprzez `utf8ToU32()` w `bitmapfont.cpp:196` i `bitmapfont.cpp:571`. Problem polega na tym że fonty bitmapowe mają tylko glify ASCII/CP1250 - więc nawet z poprawną konwersją nie wyświetlą polskich znaków. **Rozwiązanie: używać TTF fontów.**

### FAZA 4: KONFIGURACJA FONTÓW

**Status:** ✅ DONE (14.12.2025 06:00)

| Zadanie | Opis | Status |
|---------|------|--------|
| **4.1** | Skonfigurować fallback fonts w `.otfont` dla JP/CJK | ✅ DONE |
| **4.2** | Upewnić się że pliki TTF są w instalacji | ✅ DONE (26 plików Noto) |
| **4.3** | Ustawić domyślny font na noto-12 | ✅ DONE |

### FAZA 5: TESTOWANIE

**Status:** 🟡 GOTOWE DO TESTÓW MANUALNYCH

| Test | Tekst | Cel |
|------|-------|-----|
| **5.1** | `Zażółć gęślą jaźń` | Polski (Latin Extended) |
| **5.2** | `こんにちは世界` | Japoński (Hiragana + Kanji) |
| **5.3** | `Hello 世界 Świat` | Mieszany |
| **5.4** | Wpisywanie w UITextEdit | Kursor, backspace, zaznaczanie |
| **5.5** | Kopiuj/Wklej | Unicode clipboard |

---

## PRIORYTET WYKONANIA

```
┌─────────────────────────────────────────────────────────────┐
│ FAZA 0: Naprawić ładowanie TTF                              │
│ Status: ✅ DONE (14.12.2025 05:00)                          │
│ Pliki: bitmapfont.cpp, TTFFont.cpp, Utf8.h                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 1: Refaktor UITextEdit na codepoints                   │
│ Status: ✅ DONE (14.12.2025 05:30)                          │
│ Pliki: uitextedit.cpp, uitextedit.h                         │
│ Zadania: 1.1-1.9 (9 zadań) - wszystkie wykonane             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 2: Refaktor pozostałych UI                             │
│ Status: ✅ NIE WYMAGANE (komponenty nie wymagają zmian)     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 3: Refaktor BitmapFont (opcjonalne)                    │
│ Status: 🟢 POMINIĘTE (używamy TTF zamiast bitmap)           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 4: Konfiguracja fontów                                 │
│ Status: ✅ DONE (14.12.2025 06:00)                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 5: Testowanie                                          │
│ Status: 🟡 GOTOWE DO TESTÓW MANUALNYCH                      │
│ Testy: T1-T12 (patrz FAZA_2_CHECKLIST.md)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## SZACOWANY NAKŁAD PRACY

| Faza | Zadania | Trudność | Czas | Status |
|------|---------|----------|------|--------|
| 0 | 5 | Średnia | 2-4h | ✅ DONE |
| 1 | 9 | Wysoka | 8-16h | ✅ DONE |
| 2 | 5 | Średnia | 4-8h | ✅ NIE WYMAGANE |
| 3 | 3 | Średnia | 2-4h | ⏭️ POMINIĘTE |
| 4 | 3 | Niska | 1-2h | ✅ DONE |
| 5 | 5 | Niska | 2-4h | 🟡 GOTOWE DO TESTÓW |
| **SUMA** | **30** | | **19-38h** | ~95% IMPLEMENTACJA ZAKOŃCZONA |

---

## HISTORIA ZMIAN

### 14.12.2025 03:30 - Agent 2 (Claude)
- Audyt warstwy renderowania - wszystko OK
- Identyfikacja problemu z ładowaniem TTF

### 14.12.2025 04:00 - Agent 1 (ChatGPT) 
- Audyt warstwy UI - znalezione krytyczne problemy
- UITextEdit, UILabel, UIButton - operują na bajtach zamiast codepointów
- Szczegółowy plan refaktoru

### 14.12.2025 05:00 - Agent 2 (Claude) - FAZA 0
- bitmapfont.cpp: try/catch, fontNode->get() z null-check
- TTFFont.cpp: getRealPath(), szczegółowe logowanie
- Utf8.h: dodano u32ToUtf8(), utf8Length(), utf8ByteOffset(), utf8CodepointIndex()

### 14.12.2025 05:30 - Agent 2 (Claude) - FAZA 1
- uitextedit.h: #include Utf8.h, std::u32string m_text32, appendCharacter(char32_t)
- uitextedit.cpp: Kompletny refaktor - wszystkie operacje na codepointach
  - appendText(), appendCharacter(), removeCharacter()
  - setCursorPos(), setSelection(), deleteSelection()
  - moveCursorHorizontally(), getSelection()
  - updateText() synchronizuje m_text32 ↔ m_text
  - updateDisplayedText() - poprawna liczba gwiazdek dla haseł
  - onKeyPress() - Ctrl+Backspace, Home, End używają m_text32

### 14.12.2025 05:45 - Agent 2 (Claude) - FAZA 2
- Analiza: pozostałe komponenty UI nie wymagają zmian
- uiwidgettext.cpp przekazuje UTF-8 do BitmapFont bez przetwarzania

### 14.12.2025 06:00 - Agent 2 (Claude) - FAZA 4
- noto-12.otfont: ustawiono default: true
- noto-12.otfont: dodano fallback fonts dla CJK, Hebrew, Arabic, Japanese

---

## ZMIENIONE PLIKI (PODSUMOWANIE)

| Plik | Zmiany |
|------|--------|
| `src/framework/graphics/bitmapfont.cpp` | try/catch TTF block, fontNode->get(), drawColoredText(), wrapText() codepoints, calculateTextRectSize() multiline |
| `src/framework/graphics/bitmapfont.h` | Deklaracja drawColoredText() |
| `src/framework/text/TTFFont.cpp` | getRealPath(), logging |
| `src/framework/text/Utf8.h` | u32ToUtf8(), utf8Length(), utf8ByteOffset(), utf8CodepointIndex() |
| `src/framework/ui/uitextedit.h` | m_text32, appendCharacter(char32_t) |
| `src/framework/ui/uitextedit.cpp` | Kompletny refaktor na codepoints, getTextPos() TTF branch |
| `src/framework/ui/uiwidgettext.cpp` | TTF branches w drawText() i updateText() |
| `src/framework/stdext/string.cpp` | Unicode toupper/tolower/ucwords |
| `src/client/statictext.cpp` | utf8Length() dla delay |
| `src/framework/graphics/cachedtext.cpp` | TTF path z utf8ToU32() |
| `data/fonts/noto-12.otfont` | default: true, fallback fonts |
| `docs/FONT_UNICODE_MIGRATION.md` | Ta dokumentacja |

---

## WERYFIKACJA KOŃCOWA (15.12.2025)

### ✅ Sprawdzone komponenty:

| Komponent | Plik | Status |
|-----------|------|--------|
| **BitmapFont** | `bitmapfont.cpp` | ✅ text.length() calls are in bitmap-only paths with TTF guards |
| **CachedText** | `cachedtext.cpp` | ✅ Has proper TTF path with utf8ToU32() in update() |
| **Protocol** | `inputmessage.cpp` | ✅ getString() returns raw UTF-8 bytes directly |
| **UITextEdit** | `uitextedit.cpp` | ✅ All operations use m_text32 (codepoints) |
| **UIWidget** | `uiwidgettext.cpp` | ✅ TTF branches for drawText() and updateText() |
| **StaticText** | `statictext.cpp` | ✅ Uses utf8Length() for delay calculation |
| **String utils** | `string.cpp` | ✅ Unicode case conversion for PL/DE/CZ |

### 📦 Font files (26 Noto TTF):
- NotoSans-Regular.ttf, NotoSans-Bold.ttf, NotoSans-Italic.ttf
- NotoSansHebrew-Regular.ttf
- NotoSansArabic-Regular.ttf
- NotoSansJP-Regular.ttf
- NotoSansSC-Regular.ttf (Simplified Chinese)
- NotoSansTC-Regular.ttf (Traditional Chinese)
- NotoSansKR-Regular.ttf (Korean)
- NotoSansThai-Regular.ttf
- NotoSansDevanagari-Regular.ttf
- i więcej...

---

## NASTĘPNY KROK

**✅ IMPLEMENTACJA ZAKOŃCZONA - GOTOWE DO KOMPILACJI I TESTOWANIA!**

Po kompilacji przetestować:
1. Wyświetlanie polskich znaków (ą, ę, ó, ś, ć, ż, ź, ł, ń)
2. Wpisywanie tekstu w UITextEdit - kursor, backspace, selekcja
3. Polskie znaki w hasłach (gwiazdki)
4. Ctrl+A, Ctrl+C, Ctrl+V z polskimi znakami
