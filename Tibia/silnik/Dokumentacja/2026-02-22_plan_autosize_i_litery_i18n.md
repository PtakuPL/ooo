# Plan: Auto-size + Poprawa generacji liter na gałęzi i18n
**Data**: 2026-02-22  
**Status**: PLAN — bez zmian w kodzie  
**Warunek wejścia**: Build Windows #4396 na master NIE przechodzi  
**Cel**: Przenieść zmiany na gałąź `feature/i18n-multilanguage` (gdzie Windows build przechodzi) i tam naprawić auto-size + generację liter  

---

## 0. KONTEKST — Stan gałęzi

| Gałąź | Windows Build | Opis |
|-------|---------------|------|
| `master` | ❌ (ICE C1001, #4394 failed, #4396 in progress) | Wszystkie fixy MSVC (Faza 1-5), 68 plików zmian |
| `feature/i18n-multilanguage` | ✅ (przechodzi) | Prostsza mitygacja ICE: globalne `/O1` + 2 TU z `/Od` |
| `serwer-7.4` | ≈ i18n | Praktycznie identyczna z i18n (tylko +blockItemHotkeys) |

**Dlaczego i18n przechodzi a master nie**: i18n ma prostszą mitygację ICE w CMakeLists.txt (globalne `/O1` zamiast per-file Groups 1-7). Master ma agresywniejsze zmiany (refaktoryzacja szablonów, split plików, fold expressions) które mogą generować nowe ICE.

---

## 1. PROBLEM A: Litery nie generują się poprawnie po kompilacji

### 1.1 Objawy
Po kompilacji instalki na gałęzi 7.4 i i18n — litery TTF nie wyświetlają się poprawnie (brak tekstu, puste glify, nieprawidłowe pozycje).

### 1.2 Diagnoza — Pipeline renderowania TTF

```
BitmapFont::load() → type=="ttf" → TTFFont::load() → FreeType + HarfBuzz
         ↓
BitmapFont::drawText() → m_isTTF → TTFFont::drawText()
         ↓
TextShaper::shape(text32, hbFont, params) → HarfBuzz shaping
         ↓
TTFFont::buildQuads() → cacheGlyph() → rasterizeGlyph() → Atlas
         ↓
flushPendingUploads() → GPU upload → g_drawPool.addTexturedCoordsBuffer()
```

### 1.3 Znane potencjalne problemy z generacją liter

| # | Problem | Plik | Opis |
|---|---------|------|------|
| L1 | **Atlas texture id=0** | `TTFFont.cpp:ensureAtlas()` | Tekstura tworzona z `atlasSize=1024` — może być za duża dla niektórych GPU (max texture size check istnieje ale może być za późno) |
| L2 | **flushPendingUploads timing** | `TTFFont.cpp:407` | Upload odbywa się przez `g_drawPool.addAction()` — jeśli akcja wykona się PO renderowaniu quadów, glify będą niewidoczne |
| L3 | **buildQuads baseline** | `TTFFont.cpp:562-563` | `dy = penY - ag->bearingY - sg.y` — odwrócony sign na `sg.y` może powodować błędne pozycje na Windowsie (FreeType koordinaty vs OpenGL) |
| L4 | **CachedText::update multiline** | `cachedtext.cpp:152-220` | Multiline TTF tekst dzieli na linie i kumuluje offsetY — jeśli lineHeight różni się od rzeczywistej wysokości liter, linie nachodzą na siebie |
| L5 | **m_glyphHeight = size** | `bitmapfont.cpp:109` | `m_glyphHeight` ustawione na pixel size TTF — ale powinno być na `lineHeight()` (ascent+descent+leading), bo reszta silnika używa glyphHeight do layoutu |
| L6 | **Brak bold-source w CachedText** | `cachedtext.cpp` + `TTFFont.h` | Fonty z `bold-source` ładowane, ale CachedText nie obsługuje przełączania na bold |
| L7 | ~~advance.x w 26.6 fixed-point~~ | `TTFFont.cpp:389` | ✅ NIE BUG — `ag.advance` nie jest używane w renderingu; HarfBuzz advance jest konwertowane w TextShaper (`/64.0f`) |

### 1.4 Plan naprawy generacji liter — 5 kroków

#### Krok L-1: Weryfikacja advance.x — NIE jest bugiem ← **SPRAWDZONE**
**Plik**: `src/framework/text/TTFFont.cpp` linia 389  
**Obecny kod**: `ag.advance = static_cast<int>(g->advance.x);`  
**Status**: ✅ **Nie wymaga zmiany** — komentarz w `TTFFont.h:34` jasno mówi:  
`"advance from FreeType (26.6 fixed) – HB advance is used at draw time"`  
- `ag.advance` (26.6) jest TYLKO w cache — nie jest używane do rysowania
- `TextShaper::shape()` konwertuje HarfBuzz advance: `pos[i].x_advance / 64.0f` → `sg.advanceX` w pikselach
- `buildQuads()` i `measureTextWidth()` używają `sg.advanceX` (piksele) — POPRAWNE
- `ag.advance` jest reliktem diagnostycznym — można zostawić lub skonwertować, ale nie wpływa na rendering

**WNIOSEK**: Advance path jest poprawny. Problem z literami leży gdzie indziej.

#### Krok L-2: Fix m_glyphHeight vs lineHeight
**Plik**: `src/framework/graphics/bitmapfont.cpp` linia 109  
**Obecny kod**: `m_glyphHeight = size;`  
**Propozycja**: Po `m_ttf->load(...)`, użyć `m_glyphHeight = m_ttf->lineHeight();`  
**Dlaczego**: `size` to żądany pixel size, ale `lineHeight()` to ascent+descent — prawidłowa metryka dla layoutu widgetów.

#### Krok L-3: Weryfikacja flushPendingUploads timing
**Pliki**: `TTFFont.cpp:460`, `cachedtext.cpp:68-69`  
**Sprawdzić**: Czy `flushPendingUploads()` jest wywoływane PRZED `addTexturedCoordsBuffer()` w każdej ścieżce:
- `TTFFont::drawText()` — ✅ line 460 (przed buildQuads)
- `CachedText::drawTTF()` — ✅ line 68-69
- `BitmapFont::drawText()` — ⚠️ brak! Wywołuje `m_ttf->drawText()` ale ten sam flush powinien wystarczyć
- `BitmapFont::drawColoredText()` — ⚠️ sprawdzić
**Poprawka**: Dodać `m_ttf->flushPendingUploads()` na początku `BitmapFont::drawText()` i `drawColoredText()` w ścieżce TTF.

#### Krok L-4: Weryfikacja baseline y-coords
**Plik**: `TTFFont.cpp` linia 562  
**Sprawdzić**: `dy = penY - ag->bearingY - sg.y`  
- Na Windowsie FreeType zwraca `bearingY` w górę (pozytywne = w górę)
- OpenGL ma Y=0 na górze ekranu
- Jeśli baseline jest źle, litery „uciekają" w dół lub nakładają się
**Test**: Dodać log z `bearingY`, `sg.y`, `dy` dla pierwszych 5 znaków — porównać Linux vs Windows

#### Krok L-5: Atlas creation robustness
**Plik**: `TTFFont.cpp:223-253`  
**Sprawdzić**: 
- Czy `g_graphics.getMaxTextureSize()` zwraca poprawną wartość na Windows OpenGL/DirectX
- Czy atlas size 1024×1024 nie przekracza limitu
- Czy `texture->create()` nie zwraca błędu po `updateImage()`
**Poprawka**: Dodać diagnostykę (`g_logger.info`) po stworzeniu atlasu z teksturą.

---

## 2. PROBLEM B: Auto-size widgetów dla wielojęzycznych tekstów

### 2.1 Stan obecny

Silnik OTClient **MA** mechanizmy auto-resize (patrz dok `2026-02-17_i18n_ui_layout_auto_resize.md`):
- `text-auto-resize: true` — oba kierunki
- `text-horizontal-auto-resize: true` — tylko szerokość
- `text-vertical-auto-resize: true` — tylko wysokość
- `min-width` / `max-width` / `min-height` / `max-height`

Ale **prawie żaden element UI** z nich nie korzysta — mają hardcoded `size:`.

### 2.2 Kaskadowe powiększanie okien

Użytkownik wymaga: "Jeśli tekst w jednym elemencie jest za długi, cały kontener aż do okna głównego powinien się powiększyć."

**Architekturalne ograniczenie**: Anchor layout NIE ma `fit-children` (jest tylko w box layout). Propagacja child→parent wymaga albo:
- (A) Lua callback `onResize` → ręczna aktualizacja rodzica
- (B) Nowy mechanizm C++ `fit-children` w anchor layout
- (C) Hybrydowe: Lua `onSetup` + pomiar tekstu → ustawienie rozmiarów

### 2.3 Plan implementacji auto-size — 4 fazy

#### Faza A-1: Globalny styl I18NButton / I18NQtButton → auto-resize (OTUI)
**Pliki**: `data/styles/10-buttons.otui`  
**Zmiany**:
```otui
# Dodać na końcu pliku:
I18NButton < Button
  text-horizontal-auto-resize: true
  min-width: 106

I18NQtButton < QtButton
  text-horizontal-auto-resize: true
  min-width: 106
```
**Gdzie użyć**: Wszędzie gdzie przycisk ma tekst i18n — zamienić `Button` na `I18NButton`.

#### Faza A-2: Panel ustawień — sidebar (OTUI + Lua)
**Pliki**: 
- `data/modules/client_options/options.otui` — style panelu
- `data/modules/client_options/options.lua` — logika Lua

**Zmiany OTUI**:
```otui
optionsTabBar:
  min-width: 128       # zamiast size: 128 453
  height: 453

OptionsCategory:
  min-width: 115       # zamiast size: 115 22
  height: 22
  
  Button:
    text-horizontal-auto-resize: true
    min-width: 115
```

**Zmiany Lua** (`options.lua`):
```lua
-- Po configureCharacterCategories():
function adjustSidebarWidth()
    local sidebar = controller.ui.optionsTabBar
    local maxWidth = 128  -- minimum
    for i = 1, sidebar:getChildCount() do
        local w = sidebar:getChildByIndex(i)
        if w then
            local tw = w:getTextSize().width + 30  -- margins
            maxWidth = math.max(maxWidth, tw)
        end
    end
    sidebar:setWidth(maxWidth)
    -- Propagacja do okna głównego
    local window = controller.ui.optionsWindow
    local delta = maxWidth - 128
    if delta > 0 then
        window:setWidth(686 + delta)
    end
end
```

#### Faza A-3: Checkboxy i panele kontrolek — text-wrap (OTUI)
**Pliki**: `general.otui`, `graphics.otui`, `interface.otui`, `console.otui`, `HUD.otui`, `effects.otui`, `audio.otui`, `misc.otui`

**Zmiany**: Dla każdego `SmallReversedQtPanel`:
```otui
SmallReversedQtPanel:
  text-wrap: true
  text-vertical-auto-resize: true
  min-height: 22
```

#### Faza A-4: Kategorie sidebar — owinięcie w tr() (Lua)
**Plik**: `data/modules/client_options/options.lua`  
**Zmiany**: Owinięcie wszystkich nazw kategorii w `tr()`:
```lua
text = tr("Controls")      -- zamiast text = "Controls"
text = tr("Interface")
text = tr("Graphics")
-- itd.
```

---

## 3. KOLEJNOŚĆ WDROŻENIA NA GAŁĄŹ i18n

### Etap 0: Przygotowanie gałęzi
```bash
git checkout feature/i18n-multilanguage
git pull origin feature/i18n-multilanguage
```

### Etap 1: Fix generacji liter (Kroków L-1 do L-5) — 1 commit
**Commit**: `fix(ttf): fix glyph advance, baseline, atlas timing on i18n branch`  
**Pliki**: 
- `src/framework/text/TTFFont.cpp` (advance fix, atlas diagnostyka)
- `src/framework/graphics/bitmapfont.cpp` (glyphHeight fix, flush timing)
- ewentualnie `src/framework/text/TextShaper.cpp` (jeśli advance też w 26.6)

**Walidacja**: 
- Build Linux ✅
- Build Windows ✅ 
- Test ręczny: uruchomić klienta, sprawdzić czy litery wyświetlają się poprawnie (NPC dialog, konsola, opcje)

### Etap 2: Auto-size — Faza A-1 (przyciski) — 1 commit
**Commit**: `feat(i18n): add I18NButton/I18NQtButton with text-horizontal-auto-resize`  
**Pliki**: `data/styles/10-buttons.otui`  
**Walidacja**: Build + sprawdzić czy przyciski rosną do tekstu

### Etap 3: Auto-size — Faza A-2 (sidebar) — 1 commit  
**Commit**: `feat(i18n): auto-resize sidebar categories and window`  
**Pliki**: `options.otui`, `options.lua`  
**Walidacja**: Przełączyć język na rosyjski, sprawdzić czy sidebar i okno rosną

### Etap 4: Auto-size — Faza A-3 (panele kontrolek) — 1 commit
**Commit**: `feat(i18n): add text-wrap and vertical auto-resize to option panels`  
**Pliki**: 6-8 plików .otui  
**Walidacja**: Sprawdzić checkboxy z długimi tłumaczeniami

### Etap 5: Kategorie tr() — Faza A-4 — 1 commit
**Commit**: `feat(i18n): wrap sidebar category names in tr()`  
**Pliki**: `options.lua`  
**Walidacja**: Zmienić język — nazwy kategorii powinny się tłumaczyć

---

## 4. PLAN AWARYJNY — jeśli master build PRZEJDZIE

Jeśli Build Windows #4396 na master **przejdzie**:
1. NIE przenosimy się na i18n
2. Kontynuujemy na master z Fazą 6 (PIMPL, extern template, etc.)
3. Auto-size i litery naprawiamy bezpośrednio na master
4. Plan z sekcji 1-3 powyżej nadal obowiązuje merytorycznie — zmieni się jedynie gałąź docelowa

---

## 5. DIAGNOSTYKA — komendy do uruchomienia przed zmianami

```bash
# 1. Sprawdź status CI
# GitHub Actions → Build Windows #4396

# 2. Sprawdź stan gałęzi i18n
git log --oneline -5 feature/i18n-multilanguage

# 3. Porównaj TTFFont advance w kodzie:
grep -n "advance" src/framework/text/TTFFont.cpp
grep -n "advanceX\|advanceY" src/framework/text/TextShaper.cpp

# 4. Sprawdź HarfBuzz output format:
# hb_glyph_position_t.x_advance jest w 26.6? TAK — HarfBuzz zwraca w 1/64 px
grep -n "x_advance\|y_advance" src/framework/text/TextShaper.cpp

# 5. Test lokalny (Linux):
cd canary_test/testyy && mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug && make -j$(nproc)
```

---

## 6. WERYFIKACJA advance.x — ✅ ROZWIĄZANE

**Wynik analizy** (sprawdzone 2026-02-22):
- `TextShaper.cpp:229`: `g.advanceX = pos[i].x_advance / 64.0f;` — HarfBuzz advance skonwertowane na piksele ✅
- `TextShaper.cpp:227-228`: `g.x / g.y` — offsets też skonwertowane z 26.6 ✅  
- `TTFFont.h:34`: `ag.advance` — oznaczony komentarzem jako 26.6 referencyjne, NIE używany w renderingu ✅
- `TTFFont::buildQuads()` — używa `sg.advanceX` (piksele od TextShaper) ✅
- `TTFFont::measureTextWidth()` — używa `sg.advanceX` (piksele) ✅

**Advance.x NIE jest przyczyną problemów z renderowaniem liter.**

Najbardziej prawdopodobne przyczyny to:
1. **m_glyphHeight = size** (Krok L-2) — zły metryka layoutu
2. **flushPendingUploads timing** (Krok L-3) — glify nie zdążyły się załadować na GPU
3. **Baseline y-coords** (Krok L-4) — bearingY/sg.y sign convention
4. **Windows-specific OpenGL** (Krok L-5) — różnice w tworzeniu tekstur

---

## 7. MAPA PLIKÓW DO ZMIANY

### Litery (Etap 1):
| Plik | Zmiana | Priorytet |
|------|--------|-----------|
| `src/framework/text/TTFFont.cpp` | advance.x fix, atlas diag | 🔴 KRYTYCZNY |
| `src/framework/text/TextShaper.cpp` | sprawdzić advance format | 🔴 KRYTYCZNY |
| `src/framework/graphics/bitmapfont.cpp` | glyphHeight, flush timing | 🟡 WYSOKI |
| `src/framework/graphics/cachedtext.cpp` | multiline baseline | 🟡 WYSOKI |

### Auto-size (Etapy 2-5):
| Plik | Zmiana | Priorytet |
|------|--------|-----------|
| `data/styles/10-buttons.otui` | I18NButton style | 🟡 WYSOKI |
| `data/modules/client_options/options.otui` | sidebar min-width | 🟡 WYSOKI |
| `data/modules/client_options/options.lua` | adjustSidebarWidth + tr() | 🟡 WYSOKI |
| `data/modules/client_options/general.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/graphics.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/interface.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/console.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/HUD.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/effects.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/audio.otui` | text-wrap panels | 🟢 NORMALNY |
| `data/modules/client_options/misc.otui` | text-wrap panels | 🟢 NORMALNY |

---

## 8. DEFINICJA SUKCESU

| # | Kryterium | Jak sprawdzić |
|---|-----------|---------------|
| 1 | Build Windows na i18n przechodzi z nowymi zmianami | GitHub Actions green |
| 2 | Build Linux przechodzi | GitHub Actions green |
| 3 | Litery TTF wyświetlają się poprawnie po kompilacji na Windows | Ręczny test klienta — tekst w NPC dialog, konsola, opcje |
| 4 | Prawidłowe odstępy między literami | Porównanie wizualne z oryginalnym klientem |
| 5 | Przyciski z długimi tłumaczeniami auto-resize'ują | Przełączenie na rosyjski/chiński |
| 6 | Okno opcji rośnie gdy sidebar za wąski | Przełączenie na rosyjski |
| 7 | Checkboxy z długim tekstem zawijają tekst | Przełączenie na niemiecki |
