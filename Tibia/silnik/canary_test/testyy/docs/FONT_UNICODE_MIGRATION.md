# Migracja fontów OTClient na Unicode (TTF)

## Data: 14 grudnia 2025
## Status: W TRAKCIE - Problem z ładowaniem TTF + Refaktor UI

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

**Status:** 🔴 Blokuje wszystko

```
ERROR loading otfont: /fonts/mono-12.otfont - C++ exception
```

| Zadanie | Plik | Opis |
|---------|------|------|
| **0.1** | `bitmapfont.cpp` | Dodać try/catch wokół całego bloku TTF |
| **0.2** | `bitmapfont.cpp` | Zmienić `fontNode->at()` na `fontNode->get()` + null check |
| **0.3** | `TTFFont.cpp` | Uprościć ścieżkę - użyć `getRealPath()` zamiast `resolvePath()+getRealDir()` |
| **0.4** | `TTFFont.cpp` | Dodać szczegółowe logowanie każdego kroku |

### FAZA 1: REFAKTOR UITextEdit [PRIORYTET WYSOKI]

**Status:** 🟡 Po naprawieniu FAZY 0

UITextEdit jest **najważniejszy** bo odpowiada za wprowadzanie tekstu w grze.

| Zadanie | Opis | Szczegóły |
|---------|------|-----------|
| **1.1** | Zmienić reprezentację tekstu | `std::string m_text` → `std::u32string m_text32` lub dodatkowy wektor codepointów |
| **1.2** | Przepisać `appendText()` | Użyć `utf8ToU32()` do konwersji wejścia |
| **1.3** | Przepisać `appendCharacter()` | Operować na codepointach, nie bajtach |
| **1.4** | Przepisać `removeCharacter()` | Usuwać codepoint, nie bajt |
| **1.5** | Naprawić kursor | `m_cursorPos` = indeks w codepointach |
| **1.6** | Naprawić selekcję | `m_selectionStart/End` = indeksy w codepointach |
| **1.7** | Naprawić `moveCursorLeft/Right` | Przesuwać o codepoint, nie bajt |
| **1.8** | Przepisać `calculateTextRectSize()` | Używać `TextShaper` i `TTFFont` |
| **1.9** | Dodać konwersję wyjścia | `u32string` → `std::string` UTF-8 gdy potrzebne |

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

**Status:** 🟢 Po ukończeniu FAZY 1

| Zadanie | Plik | Opis |
|---------|------|------|
| **2.1** | `uilabel.cpp` | Upewnić się że używa `utf8ToU32()` do renderowania |
| **2.2** | `uibutton.cpp` | Podobnie |
| **2.3** | `uitextlist.cpp` | Podobnie |
| **2.4** | `uiwidgettext.cpp` | Sprawdzić i naprawić |
| **2.5** | `console.cpp` | Sprawdzić obsługę wejścia |

### FAZA 3: REFAKTOR BITMAPFONT (ścieżka bitmap)

**Status:** 🟢 Opcjonalne - tylko jeśli chcemy zachować fonty bitmapowe

| Zadanie | Opis |
|---------|------|
| **3.1** | Przepisać `calculateGlyphPositions()` na codepoints |
| **3.2** | Przepisać `drawText()` na codepoints |
| **3.3** | Lub: usunąć obsługę bitmap fonts i wymusić TTF |

### FAZA 4: KONFIGURACJA FONTÓW

**Status:** 🟢 Po naprawieniu FAZY 0

| Zadanie | Opis |
|---------|------|
| **4.1** | Skonfigurować fallback fonts w `.otfont` dla JP/CJK |
| **4.2** | Upewnić się że pliki TTF są w instalacji |
| **4.3** | Ustawić domyślny font na noto-12 |

### FAZA 5: TESTOWANIE

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
│ Status: 🔴 BLOCKER                                          │
│ Pliki: bitmapfont.cpp, TTFFont.cpp                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 1: Refaktor UITextEdit na codepoints                   │
│ Status: 🟡 WYSOKI PRIORYTET                                 │
│ Pliki: uitextedit.cpp, uitextedit.h                         │
│ Zadania: 1.1-1.9 (9 zadań)                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 2: Refaktor pozostałych UI                             │
│ Status: 🟢 ŚREDNI PRIORYTET                                 │
│ Pliki: uilabel, uibutton, uitextlist, uiwidgettext          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 3: Refaktor BitmapFont (opcjonalne)                    │
│ Status: 🟢 NISKI PRIORYTET                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ FAZA 4: Konfiguracja fontów                                 │
│ FAZA 5: Testowanie                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## SZACOWANY NAKŁAD PRACY

| Faza | Zadania | Trudność | Czas |
|------|---------|----------|------|
| 0 | 4 | Średnia | 2-4h |
| 1 | 9 | Wysoka | 8-16h |
| 2 | 5 | Średnia | 4-8h |
| 3 | 3 | Średnia | 2-4h |
| 4 | 3 | Niska | 1-2h |
| 5 | 5 | Niska | 2-4h |
| **SUMA** | **29** | | **19-38h** |

---

## HISTORIA ZMIAN

### 14.12.2025 03:30 - Agent 2 (Claude)
- Audyt warstwy renderowania - wszystko OK
- Identyfikacja problemu z ładowaniem TTF

### 14.12.2025 04:00 - Agent 1 (ChatGPT) 
- Audyt warstwy UI - znalezione krytyczne problemy
- UITextEdit, UILabel, UIButton - operują na bajtach zamiast codepointów
- Szczegółowy plan refaktoru

---

## NASTĘPNY KROK

**Zaczynamy od FAZY 0 - naprawienie ładowania TTF.**

Po potwierdzeniu działania TTF, przechodzimy do FAZY 1 - refaktor UITextEdit.
