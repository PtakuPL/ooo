# CHECKLIST TESTOWANIA UNICODE RENDERU

Data: 15 grudnia 2025  
Status: Gotowy do wykonania BEZPOŚREDNIO PO KOMPILACJI

---

## 📋 PRE-TEST CHECKLIST

### Krok 1: Przygotowanie logów
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy

# Oczyść stare logi
rm -f client.log compile.log

# Skompiluj (jeśli nie zrobione)
./recompile.sh 2>&1 | tee compile.log

# Uruchom z logowaniem
./otclient 2>&1 | tee client.log

# W innym terminalu - monitor logi
tail -f client.log | grep -i "font\|ttf\|fallback\|glyph"
```

### Krok 2: Sprawdzenie czy TTF się załadował
Poszukaj w logach:
```
✅ Poprawnie:
[INFO] TTF: loading font source='...'
[INFO] TTF: resolved mainPath='...'
[INFO] TTF: font '...' loaded successfully
[INFO] TTF: X fallback fonts configured
[INFO] BitmapFont::drawText: using TTF path (first time)

❌ Błąd:
[ERROR] TTF: failed to load main font by any method
[ERROR] TTF: exception while loading: ...
[WARN] TTF: fallback 'xxx' exception: ...
```

---

## 🇵🇱 TEST #1: POLSKIE ZNAKI

### Scenariusz:
1. Otwórz client
2. Przejdź do **Login Screen**
3. Kliknij na pole "hasło" (password field)
4. Wpisz: `Zapamiętaj hasło`
5. Obserwuj każdy znak

### Oczekiwany rezultat:
- ✅ `Z` - OK (ASCII)
- ✅ `a` - OK (ASCII)
- ✅ `p` - OK (ASCII)
- ✅ `a` - OK (ASCII)
- ✅ `m` - OK (ASCII)
- ✅ `i` - OK (ASCII)
- ✅ `ę` - **MUSI BYĆ** (U+0119) - NIE `[?]`
- ✅ `t` - OK (ASCII)
- ✅ `a` - OK (ASCII)
- ✅ `j` - OK (ASCII)
- ✅ `h` - OK (ASCII)
- ✅ `a` - OK (ASCII)
- ✅ `s` - OK (ASCII)
- ✅ `ł` - **MUSI BYĆ** (U+0142) - NIE `[?]`
- ✅ `o` - OK (ASCII)

### Co sprawdzić w logach:
```bash
# Szukaj:
grep "U+0119\|U+0142" client.log  # ę i ł powinny być

# Możliwe wyniki:
✅ [INFO] TTFFont: using fallback font #X for codepoint U+0119 (ę)
✅ [INFO] TTFFont: using fallback font #X for codepoint U+0142 (ł)

lub

✅ [OK - no warning] - oznacza że są w głównym NotoSans-Regular.ttf
```

### Diagnoza jeśli FAIL:
```
Widzisz: "Zapamiętaj ha sło" (brakuje ę i ł)
         ↓
Log: [WARN] no fallback font has glyph for codepoint U+0119
         ↓
PRZYCZYNA: NotoSansSC-Regular.ttf (Chinese) nie ma polskich znaków
         ↓
ROZWIĄZANIE: Zmień kolejność fallback fontów w noto-12.otfont
            (polskie znaki są w prawie każdym Noto Sans)
```

---

## 🇷🇺 TEST #2: ROSYJSKI (CYRYLICA)

### Scenariusz:
1. Jeśli gra obsługuje rosyjski
2. Zmień język na Русский / Russian w ustawieniach
3. Obserwuj tekst UI (przyciski, menu, etc)
4. Obserwuj czy całość tekstu się mieści w obramce

### Oczekiwany rezultat:
- ✅ Znaki cyrylicy widoczne (не kwadraty)
- ✅ Tekst nie ucieka poza obramkę
- ✅ Tekst jest wyśrodkowany w buttonach
- ✅ Brak fragmentacji (tekst się nie rozrywa w połowie słowa)

### Konkretne znaki do szukania:
```
П р и в е т      (Privet - Hello)
А Б В Г Д Е Ё    (Alphabet)
А́ Е́ И́ О́ У́   (Accented - jeśli są)
```

### Co sprawdzić w logach:
```bash
grep "U+04" client.log  # Czyrylica jest w U+0400..U+04FF

✅ [INFO] TTFFont: using fallback font #X for codepoint U+0430 (а)
✅ [INFO] TTFFont: using fallback font #X for codepoint U+0440 (р)
```

### Diagnoza jeśli FAIL - Tekst ucieka:
```
Przed POPRAWKĄ: "Привет" ucieka w prawo
                ↓
Po POPRAWCE: "Привет" mieści się w obramce

Jeśli DALEJ ucieka:
  - Sprawdź czy fontScale został zmieniany
  - Sprawdź czy lua zmienia text-offset
  - Może być problem z advance width z HarfBuzz
```

---

## 🇯🇵 TEST #3: JAPOŃSKI (CJK)

### Scenariusz:
1. Jeśli gra obsługuje japoński
2. Zmień język na 日本語 / Japanese w ustawieniach
3. Obserwuj tekst UI - powinny być znaki, NIE kwadraty
4. Wpisz coś w chat jeśli jest możliwe

### Oczekiwany rezultat:
- ✅ Znaki hiragana (ひらがな)
- ✅ Znaki katakana (カタカナ)
- ✅ Znaki kanji (漢字)
- ❌ NIE mogą być [] [] [] (squares = .notdef glyph)

### Konkretne znaki do szukania:
```
あいうえお      (Hiragana)
アイウエオ      (Katakana)
日本語         (Kanji: Japan + Language)
```

### Co sprawdzić w logach:
```bash
# Hiragana
grep "U+304" client.log  # U+3040..U+309F

# Katakana
grep "U+30" client.log   # U+30A0..U+30FF

# Kanji
grep "U+4E\|U+9F" client.log  # CJK Unified U+4E00..U+9FFF

✅ [INFO] TTFFont: using fallback font #3 for codepoint U+3042 (あ)
✅ [INFO] TTFFont: using fallback font #3 for codepoint U+65E5 (日)
```

### Diagnoza jeśli FAIL - Kwadraty:
```
Widzisz: [] [] []
         ↓
Log: [WARN] no fallback font has glyph for codepoint U+3042
         ↓
PRZYCZYNA: NotoSansJP-Regular.otf się nie załadował
         ↓
SPRAWDZENIA:
  1. Czy plik istnieje: ls /path/to/fonts/ttf/NotoSansJP-Regular.otf
  2. Czy jest w fallback list: grep NotoSansJP noto-12.otfont
  3. Czy się załadował: grep "fallback.*NotoSansJP" client.log
  4. Czy kolejność jest OK (JP powinien być PRZED SC dla CJK)
```

---

## 🇸🇦 TEST #4: ARABSKI (RTL - Right-To-Left)

### Scenariusz:
1. Jeśli gra obsługuje arabski
2. Zmień język na العربية / Arabic
3. Obserwuj czy tekst czyta się od prawej do lewej

### Oczekiwany rezultat:
- ✅ Tekst czyta się od prawej do lewej
- ✅ Znaki arabskie (ا ب ت ث ج...) widoczne
- ✅ Brak [] (squares)

### Co sprawdzić w logach:
```bash
grep "NotoNaskhArabic\|U+06" client.log  # Arabic U+0600..U+06FF

✅ [INFO] TTFFont: ... fallback ... for codepoint U+0627 (ا)
```

---

## 🎯 TEST #5: FONT SCALE (NAJWAŻNIEJSZY)

### Scenariusz:
1. Otwórz jakiekolwiek okno z tekstem (chat, inventory, etc)
2. **Zmień rozmiar okna** (jeśli ma resizable borders)
3. Obserwuj czy tekst:
   - ✅ Skaluje się razem z oknem
   - ✅ Pozostaje w obramce
   - ✅ Nie ucieka poza prawy/dolny brzeg

### Konkretny test (jeśli lua pozwala):
```lua
-- W konzoli klienta:
local label = g_ui.createWidget('UILabel')
label:setText('Zapamiętaj hasło')
label:setWidth(100)    -- Wąskie okno
label:setFontScale(2.0) -- 2x większy font

-- Obserwuj: tekst powinien się zawierać w obramce
```

### Oczekiwany rezultat:
- ✅ Tekst się **nie ucina** poza obramkę
- ✅ Tekst się **skaluje** razem z rozmiarem
- ✅ Tekst jest **wyśrodkowany** jeśli font-size się zmienia

### Diagnoza jeśli FAIL:
```
Widzisz: Tekst wybiega poza obramkę (prawy, dolny brzeg)
         ↓
PRZYCZYNA: g_drawPool.scale() był używany zamiast skalowania koordynatów
           ↓
POPRAWKA JUŻ WDROŻONA w uiwidgettext.cpp:118-147
```

---

## ✅ PODSUMOWANIE

Po każdym TEST'cie zaznacz:

| Test | Rezultat | Uwagi | Logi OK? |
|------|----------|-------|---------|
| #1 Polskie | ✅/❌ | | ✅/❌ |
| #2 Rosyjski | ✅/❌ | | ✅/❌ |
| #3 Japoński | ✅/❌ | | ✅/❌ |
| #4 Arabski | ✅/❌ | | ✅/❌ |
| #5 Font-scale | ✅/❌ | | ✅/❌ |

---

## 🚨 ZNANE PROBLEMY

### Jeśli test FAIL:

1. **Polskie znaki brakują**
   - Sprawdź czy NotoSans-Regular.ttf rzeczywiście zawiera U+0105 (ą)
   - Fallback mogą być nie w tej kolejności
   - Rozwiązanie: `ttf:clearCache()` w lucie

2. **Japoński - same kwadraty**
   - Najprawdopodobniej NotoSansJP-Regular.otf nie załadował się
   - Sprawdź czy plik istnieje i ścieżka jest prawidłowa
   - Sprawdź czy .otf (nie .ttf) się załadowuje poprawnie

3. **Tekst ucieka poza obramkę**
   - Kompilacja mogła się nie wziąć (cache C++ compiler)
   - Sprawdź czy `uiwidgettext.cpp:118-147` ma poprawkę
   - Rebuild: `cd testyy && ./recompile.sh`

4. **Logi są puste lub mówią "font not ready"**
   - TTF się nie załadował wcale
   - Sprawdź czy `noto-12.otfont` ma `type: ttf`
   - Sprawdzenie: `grep "type: ttf" data/fonts/noto-12.otfont`

---

## 📞 SUPPORT

Jeśli coś nie działa:

1. **Zbierz logi:**
   ```bash
   ./otclient 2>&1 | tee full_test_log.txt
   ```

2. **Szukaj kluczowych slow:**
   ```bash
   grep -E "ERROR|WARN|fallback|TTF" full_test_log.txt
   ```

3. **Sprawdź konfigurację:**
   ```bash
   cat data/fonts/noto-12.otfont
   ls -la data/fonts/ttf/
   ```

