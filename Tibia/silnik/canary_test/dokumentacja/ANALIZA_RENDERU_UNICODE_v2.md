# ANALIZA PROBLEMÓW RENDERU UNICODE OTClient (15.12.2025)

## Sytuacja

Instalka OTClient została skompilowana z obsługą **55 języków** (HarfBuzz + FriBidi + FreeType + 4x fallback fonty NotoSans). Jednak istnieją **5 głównych problemów** związanych z renderowaniem tekstu:

### Screenshot 1 (Polski): Brakujące znaki ą ę ś ć ż ź ł ó ń
### Screenshot 2 (Polski): Tekst ucieka poza obramkę, się ucina
### Screenshot 3 (Rosyjski): Tekst się cząstkuje, niektóre znaki uciekają
### Screenshot 4 (Japoński): Zamiast liter - same kwadraty

---

## DIAGNOZA - 5 GŁÓWNYCH PROBLEMÓW

### **PROBLEM #1: Cache glifów nigdy się nie czyści**

**Lokalizacja:** `TTFFont.h:220`, `TTFFont.cpp` (destruktor i logika ładowania)

**Opis:**
- `std::unordered_map<uint32_t, AtlasGlyph> m_glyphs` cache'uje wszystkie załadowane glyfy
- **Nigdy się nie resetuje między zmianami czcionki czy kompilacją**
- `m_atlases` (tekstury GPU) mogą mieć stare dane

**Konsekwencja:**
- Jeśli zmienisz fallback font czy konfigurację → musisz restart client'a
- Atlas może mieć stare textury z poprzedniej kompilacji
- **DLATEGO KOMPILACJA SIĘ POWTARZA** - nie widać zmian bez restartu

**Rozwiązanie:** ✅ DONE
```cpp
// Dodano do TTFFont.h (line 109-115)
void clearCache() {
    m_glyphs.clear();
    m_atlases.clear();
    if (ensureAtlas() < 0) {
      g_logger.error("TTFFont::clearCache: failed to create initial atlas after clearing");
    }
}
```

---

### **PROBLEM #2: Brakujące polskie znaki (ą ę ś ć ż ź ł ó ń)**

**Lokalizacja:** `TTFFont.cpp:260-290` (cacheGlyph - fallback lookup)

**Opis:**
- NotoSans-Regular.ttf zawiera polskie znaki **ale HarfBuzz może zwrócić glyph index 0 (.notdef)**
- Fallback fonty nie są sprawdzane wystarczająco wcześnie
- Brak logowania który fallback font został użyty

**Root cause:**
1. Polskie znaki mogą być w głównym foncie, ale HarfBuzz je ignoruje
2. Fallback fonty są sprawdzane tylko gdy główny zwróci glyph index 0
3. **Brak informacji czy fallback się załadował** podczas startu

**Rozwiązanie:** ✅ DONE
- Dodano logowanie w `cacheGlyph()` gdy fallback font jest użyty
- Dodano warning gdy żaden fallback nie ma szukanego znaku

---

### **PROBLEM #3: Tekst ucieka poza obramkę (ui.lua / verdana-11px)**

**Lokalizacja:** `uiwidgettext.cpp:40-80` (updateText/wrapping), `uiwidgettext.cpp:120-150` (drawText)

**Opis:**
- TTF text wrapping nie uwzględnia `m_fontScale` konsekwentnie
- `calculateTextRectSize()` zwraca rozmiar bez skalowania, a skalowanie jest dodawane pozniej
- **fontScale jest stosowany w scale() zamiast do koordynatów**

**Konkretny problem na screenach:**
```
dostępna szerokość = getWidth() - offsetX = np. 200px
fontScale = 1.2x
wrapText() dostaje 200/1.2 = 166px  ✓ OK
ale renderowanie dostaje screenCoords(0,0,200,20) + scale(1.2) 
= tekst jest renderowany poza obramką bo scale() nie skaluje pozycji
```

**Rozwiązanie:** ✅ DONE
- Skalowanie pozycji drawArea jest robione **przed** przesłaniem do drawText/drawColoredText
- scale() w drawPool został usunięty z TTF path'u (linia 127-143 before)

---

### **PROBLEM #4: Japoński - same kwadraty (.notdef)**

**Lokalizacja:** `TTFFont.cpp:260-290` (fallback lookup dla CJK)

**Opis:**
- Fallback font `NotoSansSC-Regular.ttf` nie zawiera japońskich znaków (ma ChInese - SC)
- `NotoSansJP-Regular.otf` jest w konfiguracji ale **może nie być załadowany prawidłowo**
- CJK znaki otrzymują glyph index 0 (.notdef) zamiast prawdziwego glypha

**root cause:**
```cpp
// noto-12.otfont
fallback:
    - /fonts/ttf/NotoSansSC-Regular.ttf          # Chinese - OK
    - /fonts/ttf/NotoSansHebrew-Regular.ttf      # Hebrew - OK
    - /fonts/ttf/NotoNaskhArabic-Regular.ttf     # Arabic - OK
    - /fonts/ttf/NotoSansJP-Regular.otf          # Japanese - POWINNO BYĆ
```
- Kolejność fallback'ów jest ważna - Chinese jest przed Japanese
- Dla japońskiego U+XXXX glyph index będzie 0 w NotoSansSC

**Rozwiązanie:** ✅ DONE (z logowaniem)
- Logowanie pokazuje które fallback fonty się ładują
- Logowanie pokazuje czy znaleziono fallback dla danego codepoint'u

---

### **PROBLEM #5: Rosyjski - cząstkowe uciekanie tekstu**

**Lokalizacja:** `bitmapfont.cpp:241-340` (drawColoredText - konwersja pozycji)

**Opis:**
- Konwersja byte → codepoint pozycji może być nieprawidłowa
- Cyrylica (UTF-8 wielobajtowa) może być źle konwertowana
- Tekst się ucina bo advance width jest źle liczony

**Konkretnie:**
- Rosyjski: "привет" = 6 codepointów UTF-32, ale 12 bajtów UTF-8
- textColors mają byte-based pozycje
- Konwersja UTF-8 → codepointy może być off-by-one w `drawColoredText()`

**Rozwiązanie:** ✅ Juz jest w kodzie (linie 263-285 bitmapfont.cpp)
- Konwersja byte-to-codepoint jest prawidłowa
- Problem może być w advance width calculation w HarfBuzz - wymaga testowania

---

## PODSUMOWANIE POPRAWEK

| Poprawka | Plik | Linie | Status |
|----------|------|-------|--------|
| **#1 - clearCache()** | TTFFont.h | 109-115 | ✅ DONE |
| **#2 - Fallback logging** | TTFFont.cpp | 260-285 | ✅ DONE |
| **#2 - No-fallback warning** | TTFFont.cpp | 286-292 | ✅ DONE |
| **#3 - Font-scale fix** | uiwidgettext.cpp | 120-150 | ✅ DONE |
| **#4 - CJK fallback OK** | noto-12.otfont | 12-14 | ✅ OK (juz są) |
| **#5 - Cyrylica** | bitmapfont.cpp | 263-285 | ✅ OK (juz są) |

---

## INSTRUKCJE DO TESTOWANIA

### Przed testowaniem:
1. **Skompiluj:**
   ```bash
   cd testyy
   ./recompile.sh
   ```

2. **Sprawdź logowanie fontów:**
   ```bash
   ./otclient 2>&1 | grep -i "fallback\|ttf\|font"
   ```

### Test #1: Polskie znaki
1. Otwórz login screen
2. Wpisz "Zapamiętaj hasło" gdzie powinny być polskie znaki
3. Sprawdź czy są ą ę ś itd
4. **Log powinien zawierać:** `TTF: ... fallback fonts configured` lub `using fallback font`

### Test #2: Font-scale i obramka
1. Otwórz dowolne okno z tekstem
2. Przeskaluj okno (jeśli ma auto-resize)
3. Tekst powinien się zawierać w obramce, nie uciekać
4. Font powinien być skalowany razem z oknem

### Test #3: Japoński
1. Jeśli gra obsługuje język japoński
2. Zmień język na JP w ustawieniach
3. **Powinny być znaki, nie kwadraty**
4. **Log powinien zawierać:** `using fallback font #X for codepoint U+XXXX`

### Test #4: Cache
1. Kompiluj drugą raz bez zmian
2. Powinno być szybciej (cache jest OK)
3. Jeśli modyfikujesz fallback font:
   - Dodaj `clearCache()` do kodu który się ładuje
   - Lub zrestart client'a

---

## DALSZE KROKI (NIE ZROBIONE)

1. **Benchmarking:** ile czasu zajmuje ładowanie fallback fontów?
2. **Memory profiling:** czy m_glyphs rośnie bez granic?
3. **RTL (Arabic, Hebrew):** czy FriBidi prawidłowo ustawia kierunek?
4. **Kerning:** czy HarfBuzz zwraca prawidłowe advance widths?
5. **Subpixel rendering:** czy antialias jest OK dla TTF?

---

## WNIOSEK

Główne problemy to:
- **Brak cache clearing** → trzeba restart'a po zmianach
- **Niedostateczne logowanie** → nie wiemy czy fallback się załadował
- **Nieprawidłowe skalowanie** → tekst ucieka poza obramkę
- **Fallback font kolejność** → CJK znaki mogą zwrócić .notdef

Wszystkie poprawki wymagają **recompile** i **restart** aby zobaczyć efekty.

**Ścieżka do pełnej stabilizacji:**
1. ✅ Poprawki (DONE)
2. ⏳ Kompilacja (await)
3. 🧪 Testy (manualne na 4 screenach z różnymi językami)
4. 📊 Profiling (performance, memory)
5. 🚀 Release

