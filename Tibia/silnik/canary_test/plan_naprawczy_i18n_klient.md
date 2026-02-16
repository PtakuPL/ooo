# Plan naprawczy i18n — rendering tekstu w kliencie OTClient

**Data:** 2026-02-16  
**Status:** Do realizacji  
**Priorytet:** Krytyczny — klient wyświetla tekst z brakującymi znakami

---

## 1. Opis problemu

Po wdrożeniu systemu i18n (wybór języka działa poprawnie, tłumaczenia ładują się), pojawiły się poważne problemy z renderowaniem tekstu:

### Objawy (ze screenów użytkownika):

| Element UI | Powinno być | Jest | Brakuje |
|---|---|---|---|
| Opcje – zakładki | General Hotkeys | eneral otkeys | G, H |
| Opcje – zakładki | Interface | nterface | I |
| Opcje – zakładki | Graphics | raphics | G |
| Opcje – zakładki | Misc. | isc. | M |
| Opcje – etykiety | Move stacks | ove stacks | M |
| Opcje – etykiety | Display text | isplay text | D |
| Opcje – etykiety | Hotkey delay | otkey delay | H |
| Opcje – etykiety | Talk delay | alk delay | T |
| Opcje – etykiety | Hotkeys Manager | otkeys anager | H, M |
| Opcje – etykiety | maximized | maximi ed | z |
| Login (PL) | Opcje | cje | Op |
| Picker języka | Deutsch | eutsch | D |
| Picker języka | Español | Espa ol | ñ |
| Picker języka | Français | Fran ais | ç |
| Picker języka | Português | Portugu s | ê |
| Picker języka | Русский | (pusto, tylko flaga) | cały tekst |
| Picker języka | 日本語 | (pusto, tylko flaga) | cały tekst |

### Dodatkowe obserwacje:
- Przy pierwszym uruchomieniu pojawił się prefix `[EN]` przed tekstami, zniknął po przełączeniu języka
- Zmiana języka zmienia KTÓRE znaki są ucinane w innych miejscach
- Brak błędów w konsoli klienta (in-game)
- Angielski, Polski, Svenska w pickerze renderują się poprawnie

---

## 2. Analiza kodu — zidentyfikowane błędy

### BUG #1 (KRYTYCZNY): Podwójne naliczanie pozycji glifów w `buildQuads()`

**Plik:** `src/framework/text/TTFFont.cpp` — `buildQuads()` linia ~501  
**Plik powiązany:** `src/framework/text/TextShaper.cpp` — `shape()` linia ~213

**Problem:**  
W `TextShaper::shape()` pole `ShapedGlyph::x` jest pozycją **absolutną** (suma wszystkich poprzednich advance'ów + x_offset bieżącego glifu):
```cpp
// TextShaper.cpp:213
g.x = x + (pos[i].x_offset / 64.0f);   // x = suma advance'ów glifów 0..i-1
g.advanceX = pos[i].x_advance / 64.0f;
x += g.advanceX;                          // akumulacja advance
```

W `TTFFont::buildQuads()` pole `penX` RÓWNIEŻ akumuluje advance'y, a potem jest DODAWANE do `sg.x`:
```cpp
// TTFFont.cpp:501
const float dx = penX + ag->bearingX + sg.x;
//                ^^^^                ^^^^
//           sum(adv[0..i-1])      sum(adv[0..i-1]) + xoff[i]
//           = 2 * sum(adv[0..i-1]) + bearingX + xoff[i]  <-- PODWÓJNIE!

penX += sg.advanceX;  // akumulacja (tak samo jak x w TextShaper)
```

**Matematyczny dowód** (dla glifu o indeksie i ≥ 1):
```
dx_actual   = penX + bearingX + sg.x
            = Σ(adv[0..i-1]) + bearingX + Σ(adv[0..i-1]) + xoff[i]
            = 2·Σ(adv[0..i-1]) + bearingX + xoff[i]

dx_correct  = Σ(adv[0..i-1]) + bearingX + xoff[i]
```

**Efekt:** Każdy kolejny glif (od drugiego) jest rysowany w pozycji 2× dalszej od początku niż powinien. Tekst jest „rozciągnięty" — np. przy foncie 12px z advance ~7px, odstęp między literami wynosi ~14px zamiast ~7px. Tekst jest ~2× szerszy niż mierzony przez `measureTextWidth()`, co powoduje:
- Przy wyrównaniu LEFT: litery „wypływają" poza widget — część tekstu niewidoczna
- Przy wyrównaniu CENTER: tekst zaczyna się dalej w lewo niż przewidziano i kończy dalej w prawo
- `measureTextWidth()` zwraca poprawną (mniejszą) szerokość, ale `buildQuads()` rysuje tekst ~2× szerszy

**Fix:**
```cpp
// ZMIANA w TTFFont.cpp, buildQuads():
// BYŁO:
const float dx = penX + ag->bearingX + sg.x;
const float dy = penY - ag->bearingY - sg.y;
// ...
penX += sg.advanceX;
penY += sg.advanceY;

// MA BYĆ (sg.x/sg.y już zawierają pozycję absolutną):
const float dx = ag->bearingX + sg.x;
const float dy = -ag->bearingY - sg.y;
// Usunąć penX/penY — nie są potrzebne, bo sg.x/sg.y już zawierają akumulację
// LUB zostawić penX tylko dla obliczania bounds na końcu:
```

**Alternatywny fix** (zmiana w TextShaper zamiast TTFFont):
```cpp
// ZMIANA w TextShaper.cpp, shape():
// BYŁO:
g.x = x + (pos[i].x_offset / 64.0f);
g.y = y - (pos[i].y_offset / 64.0f);

// MA BYĆ (sg.x/sg.y = TYLKO offset, nie pozycja absolutna):
g.x = pos[i].x_offset / 64.0f;
g.y = -(pos[i].y_offset / 64.0f);
// Wtedy penX w buildQuads poprawnie obsłuży pozycjonowanie
```

**Rekomendacja:** Wybrać opcję 2 (zmiana w TextShaper), bo:
- sg.x jako „offset" jest bardziej intuicyjne niż „pozycja absolutna"
- Zgodne ze standardowym użyciem HarfBuzz (cursor + offset + bearing)
- Nie psuje measureTextWidth (który nie używa sg.x)

---

### BUG #2 (WAŻNY): `g_fonts.clearAllFontCaches()` — metoda nie istnieje

**Plik:** `modules/client_locales/locales.lua` linia 277  
**Plik powiązany:** `src/framework/luafunctions.cpp` linie 437-441

**Problem:**  
`setLocale()` wywołuje `g_fonts.clearAllFontCaches()` (linia 277), ale ta metoda **NIE ISTNIEJE** w C++. FontManager ma tylko 3 metody bindowane do Lua:
```cpp
// luafunctions.cpp:437-441
g_lua.registerSingletonClass("g_fonts");
g_lua.bindSingletonFunction("g_fonts", "clearFonts", ...);      // czyści WSZYSTKO
g_lua.bindSingletonFunction("g_fonts", "importFont", ...);
g_lua.bindSingletonFunction("g_fonts", "fontExists", ...);
// BRAK clearAllFontCaches!
```

**Efekt:**  
1. Lua szuka `clearAllFontCaches` w tabeli `g_fonts` → zwraca `nil`
2. Próba wywołania `nil()` → Lua error: "attempt to call a nil value"
3. `setLocale()` przerywa się na linii 277
4. Linie 279-281 (`onLocaleChanged` callback) NIGDY się nie wykonują
5. Funkcja NIE zwraca `true` → caller nie wie czy się udało

**ALE:** `currentLocale` (linia 274) i `g_settings.set` (linia 275) wykonują się PRZED błędem, więc tłumaczenia działają. Jedynie callback i return value są utracone.

**Dodatkowy kontekst:** `onLocaleChanged` nigdy nie jest zdefiniowane nigdzie w kodzie (grep potwierdza — 0 definicji), więc nawet gdyby linia 279 się wykonała, nic by nie zrobiła. Mimo to błąd powinien być naprawiony.

**Fix (Lua — natychmiastowy, bez przebudowy C++):**
```lua
-- locales.lua:277
-- BYŁO:
g_fonts.clearAllFontCaches()

-- MA BYĆ (pcall + fallback):
if g_fonts.clearAllFontCaches then
  pcall(g_fonts.clearAllFontCaches, g_fonts)
elseif g_fonts.clearFonts then
  -- clearFonts istnieje ale czyści za dużo — nie używać na razie
  -- pcall(g_fonts.clearFonts, g_fonts)
end
```

**Fix docelowy (C++ — wymaga przebudowy):**  
Dodać metodę `clearGlyphCaches()` do FontManager i TTFFont:
```cpp
// fontmanager.h/cpp:
void FontManager::clearGlyphCaches() {
    for (auto& [name, font] : m_fonts) {
        if (font->isTTF() && font->getTTFFont()) {
            font->getTTFFont()->clearCache();
        }
    }
}

// TTFFont.h/cpp:
void TTFFont::clearCache() {
    m_glyphs.clear();  // wyczyść pamięć podręczną glifów
    // Nie czyść atlasów — będą uzupełnione przy kolejnym rysowaniu
}

// luafunctions.cpp:
g_lua.bindSingletonFunction("g_fonts", "clearGlyphCaches", &FontManager::clearGlyphCaches, &g_fonts);
```

I w locales.lua:
```lua
if g_fonts.clearGlyphCaches then
  g_fonts.clearGlyphCaches()
end
```

---

### BUG #3 (ŚREDNI): `setDefaultLocaleTag()` nie jest zbindowane do Lua

**Plik:** `src/framework/text/LocaleShaping.cpp`  
**Plik powiązany:** `src/framework/luafunctions.cpp`

**Problem:**  
`LocaleShaping::setDefaultLocaleTag(tag)` istnieje w C++ ale NIE jest dostępne z Lua. Statyczny tag domyślny `g_defaultLocaleTag` jest zawsze `"en"`. Przy zmianie języka na np. niemiecki, HarfBuzz nadal shapuje tekst z parametrami języka angielskiego.

**Efekt:**  
- Dla prostego tekstu łacińskiego: minimalne różnice (kerning, ligatury mogą się różnić między językami)
- Dla tekstów z akcentami i specjalnymi znakami: HarfBuzz może stosować niewłaściwe reguły shaping
- Cache kluczy shapingu zawsze używa `"en"` → po przełączeniu języka cache nie jest czyszczony (bo klucz się nie zmienia)

**Fix (C++ — wymaga przebudowy):**
```cpp
// luafunctions.cpp — dodać binding:
g_lua.bindClassStaticFunction("LocaleShaping", "setDefaultLocaleTag",
    &otc::text::LocaleShaping::setDefaultLocaleTag);
```

I w locales.lua, w setLocale():
```lua
-- Po ustawieniu currentLocale:
if LocaleShaping and LocaleShaping.setDefaultLocaleTag then
  LocaleShaping.setDefaultLocaleTag(locale.languageTag or name)
end
```

---

### BUG #4 (NISKI): FontManager `else if` na default/widget-default

**Plik:** `src/framework/graphics/fontmanager.cpp`

**Problem:**  
Fonty noto-12 mają zarówno `default: true` jak i `widget-default: true`, ale kod FontManager używa `else if`:
```cpp
if (font->isDefaultFont())
    m_defaultFont = font;
else if (font->isDefaultWidgetFont())  // NIGDY nie wchodzi gdy default=true
    m_defaultWidgetFont = font;
```

**Efekt:** `m_defaultWidgetFont` może nie być ustawiony, co skutkuje fallbackiem na `m_defaultFont`. W praktyce efekt jest minimalny, bo oba wskazują na ten sam font (noto-12).

**Fix:**
```cpp
if (font->isDefaultFont())
    m_defaultFont = font;
if (font->isDefaultWidgetFont())   // 'if' zamiast 'else if'
    m_defaultWidgetFont = font;
```

---

### BUG #5 (KOSMETYCZNY): Prefix `[EN]` w plikach game_i18n nieanglojęzycznych

**Plik:** `data/locales/game_i18n_ja.lua`, `game_i18n_de.lua`, inne

**Problem:**  
Klucze w plikach game_i18n dla języków nieprzetłumaczonych mają prefix `[EN]`:
```lua
["otclient_modules.entergame.tr_17"] = "[EN] Journey Onwards",
```
- game_i18n_ja.lua: **5348 z 5828** wpisów ma prefix [EN]
- game_i18n_de.lua: podobna sytuacja

**Efekt:** Użytkownik widzi `[EN] Journey Onwards` zamiast `Journey Onwards` gdy włączy język japoński.

**Fix:**  
Skrypt Python do usunięcia prefixu `[EN] ` ze wszystkich plików game_i18n:
```python
import re, glob
for f in glob.glob('data/locales/game_i18n_*.lua'):
    text = open(f).read()
    text = re.sub(r'\[EN\]\s*', '', text)
    open(f, 'w').write(text)
```

---

### BUG #6 (MOŻLIWY): Cache shapingu TextShaper nie jest czyszczony przy zmianie lokalizacji

**Plik:** `src/framework/text/TextShaper.cpp`

**Problem:**  
`g_shapeCache` (statyczny LRU cache, max 256 wpisów) nie ma publicznego API do czyszczenia. Klucz cache to `(font, text, direction, script, language)`. Ponieważ `language` jest zawsze `"en"` (BUG #3), cache nie jest automatycznie inwalidowany przy zmianie języka.

**Efekt:** Po przełączeniu języka, stare wyniki shapingu mogą być zwracane z cache dla tych samych tekstów.

**Fix:** Dodać `TextShaper::clearCache()`:
```cpp
// TextShaper.h/cpp:
static void clearCache() {
    std::lock_guard lock(g_shapeCacheMutex);
    g_shapeCache.clear();
    g_shapeCacheTick = 0;
}
```

Wywołać z `FontManager::clearGlyphCaches()` lub bindować do Lua.

---

## 3. Hipoteza główna — dlaczego znikają pierwsze litery

Najbardziej prawdopodobne wyjaśnienie łączące obserwacje:

1. **BUG #1 (buildQuads double-counting)** powoduje, że tekst renderowany jest ~2× szerszy niż mierzony przez `measureTextWidth()`
2. Przy wyrównaniu **CENTER** (zakładki w Opcjach):
   - `bx = widgetLeft + (widgetWidth - measuredWidth) / 2` → pozycja startowa jest obliczona dla MNIEJSZEGO tekstu
   - Ale `buildQuads` rysuje tekst 2× szerszy → litery wypływają zarówno w lewo jak i w prawo poza widget
   - W zależności od tego jak DrawPool clipuje quady do okna, pewne litery mogą być niewidoczne
3. Przy wyrównaniu **LEFT** (etykiety jak "Move stacks"):
   - Tekst zaczyna się we właściwym miejscu, ale każda kolejna litera jest przesunięta dalej
   - Od pewnego momentu litery są rysowane pod innymi widgetami (z-order) lub poza ekranem

Dlaczego znikają **konkretne litery** (D, G, H, I, M, T, W, z, ñ, ç, ê):
- Te litery mogą mieć specyficzne wartości `bearingX` lub `advanceX` w foncie NotoSans
- Rozciągnięty tekst + clipowanie widgetami powoduje, że akurat te litery wypadają w „martwą strefę"
- ñ, ç, ê mogą mieć problemy z fallback fontami lub shapingiem HarfBuzz przy złym tagu języka

**Zmiana zachowania po przełączeniu języka** — logiczna, bo:
- Inne tłumaczenia → inne długości tekstów → inne pozycje clipowania
- Inne znaki → inne wartości bearingX/advanceX → inne miejsce „rozjazdu"

---

## 4. Plan zadań — kolejność realizacji

### Zadanie 1: Fix buildQuads double-counting (C++)
**Priorytet:** 🔴 KRYTYCZNY  
**Plik:** `src/framework/text/TextShaper.cpp`  
**Typ:** Zmiana C++ — wymaga przebudowy klienta

Zmienić kalkulację `g.x` i `g.y` w TextShaper::shape() tak, aby przechowywały TYLKO offset (nie pozycję absolutną):
```cpp
g.x = pos[i].x_offset / 64.0f;       // BYŁO: x + (pos[i].x_offset / 64.0f)
g.y = -(pos[i].y_offset / 64.0f);    // BYŁO: y - (pos[i].y_offset / 64.0f)
```
`penX` w buildQuads() poprawnie obsłuży pozycjonowanie.

**Test**: Tekst "General Hotkeys" powinien renderować się z normalnym odstępem liter.

---

### Zadanie 2: Fix clearAllFontCaches w locales.lua (Lua)
**Priorytet:** 🟡 WAŻNY  
**Plik:** `modules/client_locales/locales.lua`  
**Typ:** Zmiana Lua — NIE wymaga przebudowy

Zamienić linię 277:
```lua
-- BYŁO:
g_fonts.clearAllFontCaches()

-- MA BYĆ:
if g_fonts.clearGlyphCaches then
  g_fonts.clearGlyphCaches()
elseif g_fonts.clearAllFontCaches then
  pcall(g_fonts.clearAllFontCaches)
end
```

**Test**: `setLocale()` nie powinno rzucać błędu. Przełączanie języka powinno działać bez przerywania.

---

### Zadanie 3: Dodać clearGlyphCaches + clearShapeCache (C++)
**Priorytet:** 🟡 WAŻNY  
**Pliki:** `TTFFont.h/cpp`, `TextShaper.h/cpp`, `fontmanager.h/cpp`, `luafunctions.cpp`  
**Typ:** Zmiana C++ — wymaga przebudowy

a) `TTFFont::clearCache()` — czyści `m_glyphs` (ale nie atlasy — zostaną uzupełnione)  
b) `TextShaper::clearCache()` — czyści `g_shapeCache`  
c) `FontManager::clearGlyphCaches()` — wywołuje a) dla każdego fontu + b)  
d) Bindowanie `g_fonts.clearGlyphCaches` do Lua w `luafunctions.cpp`

**Test**: Po wywołaniu z Lua `g_fonts.clearGlyphCaches()`, ponowne renderowanie tekstu powinno działać normalnie.

---

### Zadanie 4: Bindowanie setDefaultLocaleTag do Lua (C++)
**Priorytet:** 🟢 ŚREDNI  
**Pliki:** `luafunctions.cpp`, `locales.lua`  
**Typ:** Zmiana C++ + Lua — wymaga przebudowy

a) Dodać binding w `luafunctions.cpp`:
```cpp
g_lua.bindClassStaticFunction("LocaleShaping", "setDefaultLocaleTag",
    &otc::text::LocaleShaping::setDefaultLocaleTag);
```

b) Wywołać w `setLocale()` w locales.lua:
```lua
if LocaleShaping and LocaleShaping.setDefaultLocaleTag then
  LocaleShaping.setDefaultLocaleTag(locale.languageTag or locale.name)
end
```

c) Dodać pole `languageTag` do definicji lokalizacji (np. `languageTag = "de"` dla German)

**Test**: Po przełączeniu na niemiecki, `HarfBuzz::shape()` powinno używać tagu `"de"`.

---

### Zadanie 5: Fix FontManager else-if (C++)
**Priorytet:** 🔵 NISKI  
**Plik:** `src/framework/graphics/fontmanager.cpp`  
**Typ:** Zmiana C++ — wymaga przebudowy

Zmienić `else if` na `if`:
```cpp
if (font->isDefaultFont())
    m_defaultFont = font;
if (font->isDefaultWidgetFont())
    m_defaultWidgetFont = font;
```

**Test**: Obie flagi powinny być ustawione po załadowaniu noto-12.

---

### Zadanie 6: Usunąć prefix [EN] z plików game_i18n (skrypt)
**Priorytet:** 🟢 ŚREDNI  
**Pliki:** `data/locales/game_i18n_*.lua`  
**Typ:** Skrypt — nie wymaga przebudowy

Uruchomić skrypt (Python lub sed) usuwający `[EN] ` prefix ze WSZYSTKICH plików game_i18n:
```bash
find data/locales -name 'game_i18n_*.lua' -exec sed -i 's/\[EN\] //g' {} +
```

**Test**: `grep -c '\[EN\]' data/locales/game_i18n_ja.lua` powinno zwrócić 0.

---

### Zadanie 7: Diagnostyka renderowania (opcjonalne, jeśli Zadanie 1 nie rozwiąże problemu)
**Priorytet:** 🟡 WAŻNY (warunkowo)  
**Plik:** `src/framework/text/TTFFont.cpp`  
**Typ:** Tymczasowe logowanie — do usunięcia po diagnozowaniu

Dodać debug logging w `buildQuads()`:
```cpp
for (const auto& sg : shaped) {
    const AtlasGlyph* ag = cacheGlyph(sg.glyphIndex, sg.codepoint);
    
    // DEBUG: loguj pozycje glifów
    if (ag) {
        g_logger.debug("buildQuads: cp=U+{:04X} glyph={} penX={:.1f} sg.x={:.1f} "
                       "bearingX={} dx={:.1f} w={} adv={:.1f}",
                       static_cast<uint32_t>(sg.codepoint), sg.glyphIndex,
                       penX, sg.x, ag->bearingX,
                       penX + ag->bearingX + sg.x,  // dx
                       ag->w, sg.advanceX);
    }
    ...
```

I w `measureTextWidth()`:
```cpp
float TTFFont::measureTextWidth(...) {
    ...
    g_logger.debug("measureTextWidth: '{}' = {:.1f}px", 
                   otc::text::u32ToUtf8(text32), penX);
    return penX;
}
```

**Test**: Sprawdzić w logach czy dx narasta poprawnie (bez podwójnego naliczania).

---

### Zadanie 8: Czyszczenie cache shapingu po zmianie lokalizacji (C++/Lua)
**Priorytet:** 🟢 ŚREDNI  
**Zależność:** Zadanie 3 (clearShapeCache API)

Po realizacji Zadania 3, dodać wywołanie `TextShaper::clearCache()` w `FontManager::clearGlyphCaches()`.

**Test**: Po przełączeniu języka, cache shapingu jest pusty, nowe teksty są shapione od nowa.

---

### Zadanie 9: Test pełnego cyklu i18n
**Priorytet:** 🟡 WAŻNY  
**Zależność:** Zadania 1-6

Scenariusz testowy:
1. Uruchomić klienta → powinien pokazać język z ustawień
2. Otworzyć Options → wszystkie zakładki i etykiety renderują się poprawnie
3. Ctrl+L → otworzyć picker języka → wszystkie nazwy kompletne (w tym Deutsch, Español, Русский)
4. Przełączyć na niemiecki → teksty UI zmieniają się na niemieckie
5. Przełączyć z powrotem na angielski → wszystko wraca do normy, żadne litery nie znikają
6. Przełączyć na japoński → teksty bez prefixu [EN]
7. Sprawdzić konsolę klienta → 0 błędów Lua

---

## 5. Kolejność realizacji i zależności

```
Zadanie 1 (buildQuads fix)         ──┐
Zadanie 2 (clearAllFontCaches fix) ──┤
Zadanie 5 (else-if fix)           ──┤── Przebudowa C++ ──→ Zadanie 9 (test)
Zadanie 3 (clearGlyphCaches API)  ──┤
Zadanie 4 (setDefaultLocaleTag)   ──┘
                                        
Zadanie 6 ([EN] prefix)           ────→ Niezależne, bez przebudowy

Zadanie 7 (diagnostyka)           ────→ Tylko jeśli Zadanie 1 nie rozwiąże problemu

Zadanie 8 (cache clearing)        ────→ Zależne od Zadania 3
```

**Minimalna ścieżka do naprawy renderowania:** Zadanie 1 + Zadanie 2 + przebudowa klienta na Windows

---

## 6. Pliki do modyfikacji — podsumowanie

| Plik | Zadanie | Typ zmiany |
|---|---|---|
| `src/framework/text/TextShaper.cpp` | 1, 8 | C++ — pozycja glifów + clearCache |
| `src/framework/text/TextShaper.h` | 1, 8 | C++ — dodanie clearCache() |
| `src/framework/text/TTFFont.cpp` | 3, 7 | C++ — clearCache + diagnostyka |
| `src/framework/text/TTFFont.h` | 3 | C++ — dodanie clearCache() |
| `src/framework/graphics/fontmanager.cpp` | 3, 5 | C++ — clearGlyphCaches + else-if |
| `src/framework/graphics/fontmanager.h` | 3 | C++ — dodanie clearGlyphCaches() |
| `src/framework/luafunctions.cpp` | 3, 4 | C++ — bindings Lua |
| `modules/client_locales/locales.lua` | 2, 4 | Lua — fix setLocale() |
| `data/locales/game_i18n_*.lua` | 6 | Skrypt — usunięcie [EN] |

---

## 7. Dodatkowe wzmianki

### Kwestia braku pliku log
Użytkownik zgłosił, że klient po zamknięciu nie tworzy już pliku log (wcześniej tworzył). To osobny problem, niezwiązany z i18n. Do zbadania po naprawie renderowania.

### Kompilacja klienta
Klient jest kompilowany na Windows (Visual Studio). Zmiany C++ (Zadania 1, 3, 4, 5) wymagają przebudowy. Zmiany Lua (Zadanie 2) i skryptowe (Zadanie 6) NIE wymagają przebudowy.

---

*Autor: GitHub Copilot — analiza kodu 2026-02-16*
