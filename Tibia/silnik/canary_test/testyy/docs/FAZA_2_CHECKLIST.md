# FAZA 2 - Quick Checklist

## ✅ ZROBIONE (FAZA 0 + FAZA 1)
- [x] TTFFont.cpp - getRealPath(), fallback fonts
- [x] BitmapFont.cpp - TTF loading block, graceful failure
- [x] Utf8.h - utf8ToU32, u32ToUtf8, utf8Length, utf8ByteOffset, utf8CodepointIndex
- [x] UITextEdit - m_text32, codepoint-based cursor/selection, TTF guardy

## ✅ ZROBIONE (FAZA 2A + 2B) - KOMPLETNE
- [x] **2A.1** UIWidget::drawText() - TTF branch z m_font->drawText()
- [x] **2A.2** UIWidget::updateText() - TTF branch z calculateTextRectSize()
- [x] **2A.2.1** calculateTextRectSize() - naprawiona obsługa multiline (\n)
- [x] **2A.2.2** wrapText() - NAPRAWIONE! TTF iteruje po codepoints
- [x] **2A.3** Colored text - warning log dla TTF (świadoma decyzja)
- [x] **2B.2** StaticText delay - utf8Length() zamiast text.length()
- [x] **UITextEdit** - wszystkie m_text.length() → m_text32.size()
- [x] **UITextEdit::getTextPos()** - TTF branch z width-based approximation

---

## FAZA 2A - UI Framework

### 2A.1 UIWidget::drawText() [✅ ZROBIONE]
```
Plik: src/framework/ui/uiwidgettext.cpp
Zmiana: Dodano TTF branch z m_font->drawText() + warning dla colored text
```
- [x] Dodać TTF branch
- [x] ⚠️ UWAGA: DrawPool scale state - if (fontScale != 1.0f) guard
- [ ] Test UILabel "Zapamiętaj"

### 2A.2 UIWidget::updateText() [✅ ZROBIONE]
```
Plik: src/framework/ui/uiwidgettext.cpp
Zmiana: TTF używa calculateTextRectSize(), fontScale w wrapText()
```
- [x] Dodać TTF branch
- [x] ⚠️ UWAGA: wrapText() uwzględnia fontScale
- [ ] Test auto-resize

### 2A.2.1 calculateTextRectSize() multiline [✅ NAPRAWIONE]
```
Plik: src/framework/graphics/bitmapfont.cpp
Zmiana: TTF path dzieli tekst po \n i sumuje wysokości linii
```
- [x] Naprawić obsługę \n w calculateTextRectSize() dla TTF
- [ ] Test: "Linia 1\nLinia 2" - sprawdzić wysokość

### 2A.2.2 wrapText() Unicode [✅ NAPRAWIONE]
```
Plik: src/framework/graphics/bitmapfont.cpp
Zmiana: TTF path iteruje po codepoints (u32string) zamiast bajtów
```
- [x] NAPRAWIONE - TTF używa utf8ToU32/u32ToUtf8 dla word splitting

### 2A.3 Colored text [✅ ROZWIĄZANE]
- [x] Warning log dla TTF + colored text
- [ ] Opcjonalnie: per-color-range rendering w przyszłości

### 2A.4 Font scale [DO TESTÓW]
- [ ] Test font-scale z TTF

### 2A.5 UITextEdit cursor operations [✅ NAPRAWIONE]
```
Plik: src/framework/ui/uitextedit.cpp
Zmiana: Wszystkie m_text.length() → m_text32.size() dla kursora
```
- [x] onStyleApply: setCursorPos(m_text32.size())
- [x] onFocusChange: setCursorPos(m_text32.size())
- [x] onDoubleClick: !m_text32.empty()
- [x] drawSelf: textLength dla TTF = m_text32.size()
- [x] getTextPos: TTF branch z width-based click detection

---

## FAZA 2B - Client-side

### 2B.1 CachedText [✅ OK]
```
Plik: src/framework/graphics/cachedtext.cpp
Stan: Używa utf8ToU32() w update() - poprawnie
```
- [x] Review - używa UTF-32 wewnętrznie

### 2B.2 StaticText delay [✅ NAPRAWIONE]
```
Plik: src/client/statictext.cpp
Zmiana: utf8Length(text) zamiast text.length()
```
- [x] Dodać include Utf8.h
- [x] Zmienić text.length() na utf8Length()

### 2B.3 AnimatedText [✅ OK - TYLKO CYFRY]
- [x] Review merge() - OK (tylko damage numbers)

### 2B.4 Creature names [✅ OK]
- [x] Używa CachedText który ma TTF path

### 2B.5 Item/Tile text [✅ N/A]
- [x] Nie operują na tekście użytkownika

### 2B.6 Chat/Console [✅ OK]
- [x] W Lua modules - używa UITextEdit

---

## TESTY

| ID | Komponent | Opis | Status |
|----|-----------|------|--------|
| T1 | UILabel | "Zapamiętaj hasło" | ⬜ |
| T2 | UIButton | "Połącz" | ⬜ |
| T3 | UITextEdit | "żółć" + backspace | ⬜ |
| T4 | StaticText | NPC: "Cześć!" | ⬜ |
| T5 | AnimatedText | Damage (cyfry) | ⬜ |
| T6 | Creature | Polska nazwa NPC | ⬜ |
| T7 | Chat | "Witaj świecie!" | ⬜ |
| **T8** | **RTL** | **Arabic: "مرحبا"** | ⬜ |
| **T9** | **Multiline** | **"Linia 1\nLinia 2"** | ⬜ |
| **T10** | **FontScale** | **font-scale: 2.0** | ⬜ |
| **T11** | **WrapText** | **Długi tekst w wąskim widget** | ⬜ |
| **T12** | **UITextEdit click** | **Klik na polskie znaki** | ⬜ |

---

## WYKONANE ZMIANY - LOG

### 2024-12-14 (sesja 2): FAZA 2A KOMPLETNA + FAZA 2B KOMPLETNA

**Pliki zmodyfikowane (dodatkowo):**

1. `src/framework/ui/uitextedit.cpp`
   - `onStyleApply`: m_text.length() → m_text32.size()
   - `onFocusChange`: m_text.length() → m_text32.size()
   - `onDoubleClick`: m_text.length() > 0 → !m_text32.empty()
   - `drawSelf`: textLength dla TTF używa m_text32.size()
   - `getTextPos()`: Nowy TTF branch z width-based click detection

2. `src/framework/graphics/bitmapfont.cpp`
   - `wrapText()`: TTF branch iteruje po codepoints (utf8ToU32/u32ToUtf8)

### 2024-12-14 (sesja 1): FAZA 2A.1 + 2A.2 + 2A.2.1 + 2B.2

**Pliki zmodyfikowane:**

1. `src/framework/ui/uiwidgettext.cpp`
   - Dodano `#include <framework/core/logger.h>`
   - `updateText()`: TTF branch z calculateTextRectSize(), fontScale w wrapText()
   - `drawText()`: TTF branch z m_font->drawText(), warning dla colored text

2. `src/framework/graphics/bitmapfont.cpp`
   - `calculateTextRectSize()`: Naprawiona obsługa multiline (\n) dla TTF

3. `src/client/statictext.cpp`
   - Dodano `#include <framework/text/Utf8.h>`
   - `addMessage()`: utf8Length() zamiast text.length()

---

## NASTĘPNE KROKI

```
1. [TERAZ]  BUILD - skompilować całość
2. [POTEM]  TEST T1-T12 
3. [POTEM]  Commit zmian
```

---

## KOMENDY

```bash
# Build
cd /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy
./recompile.sh

# Git status
git status --short

# Diff wszystkich zmian
git diff src/framework/ui/uitextedit.cpp
git diff src/framework/ui/uiwidgettext.cpp
git diff src/framework/graphics/bitmapfont.cpp
git diff src/client/statictext.cpp
```
git diff src/client/statictext.cpp
```
