# Zmiany na gałęzi `feature/i18n-multilanguage` — Fix generacji liter TTF
**Data**: 2026-02-22  
**Commit**: `e74e30ad5` — `fix(ttf): extract flushPendingUploads, fix glyph metrics & CachedText rendering`  
**Gałąź**: `feature/i18n-multilanguage`  
**Build Linux**: ✅ PRZESZEDŁ (2 warningi — naprawione w `30a897eea`)  
**Build Windows**: ✅ PRZESZEDŁ  

**Dodatkowe commity wypuszczone 2026-02-22:**  
- `30a897eea` — `fix(warnings): handle fribidi_reorder_line return value, fix g_client shared_ptr UB`  
- `564ce5c5f` — `feat(i18n): auto-size buttons, sidebar, text-wrap panels + tr() categories`  
- `6c6291b4d` — `fix(ttf): use g_mainDispatcher for glyph uploads, add lazy texture bind` ← **FIX BRAKUJĄCYCH LITER**  

---

## 1. Zmienione pliki (4 pliki, +60/-38 linii)

### 1.1 `src/framework/graphics/bitmapfont.cpp` (+8/-3)

**Problem (L-2 z planu):** `m_glyphHeight = size;` — używano surowego pixel size (np. 12) zamiast prawdziwej metryki font'a. Reszta silnika (widgety, layout, multiline) używa `m_glyphHeight` do:
- Obliczania wysokości okien dialogowych
- Pozycji kolejnych linii tekstu
- Rozmiaru scrollbar'a w konsoli
- `getTextSize().height` → anchor layout

Efekt buga: tekst obcinany od dołu, linie nachodzą na siebie, widgety za małe.

**Zmiana:**
```cpp
// PRZED:
m_glyphHeight = size;
g_logger.info("TTF: font '{}' loaded successfully", m_name);

// PO:
m_glyphHeight = m_ttf->lineHeight();
g_logger.info("TTF: font '{}' loaded successfully (glyphHeight={}, ascent={}, descent={}, lineHeight={})",
              m_name, m_glyphHeight, m_ttf->ascent(), m_ttf->descent(), m_ttf->lineHeight());
```

**Dlaczego `lineHeight()` a nie `size`:** `lineHeight()` = ascent + descent (z FreeType face metrics). To jest odległość między baseline'ami kolejnych linii — jedyna poprawna metryka do layoutu UI. `size` to tylko żądany pixel size przekazywany do FreeType, nie musi odpowiadać rzeczywistej wysokości renderowanych glifów.

---

### 1.2 `src/framework/text/TTFFont.h` (+4)

**Problem (L-3 z planu):** Logika flush (upload glifów na GPU) była inline w `drawText()`, ale `CachedText::drawTTF()` — inna ścieżka renderowania — nie miała dostępu do tej logiki. Potrzebna publiczna metoda.

**Zmiana:**
```cpp
// DODANO:
/// Uploads any pending glyph rasterizations to the GPU (via DrawPool).
/// Must be called before rendering quads that reference atlas textures.
void flushPendingUploads();
```

---

### 1.3 `src/framework/text/TTFFont.cpp` (+42/-35 netto po ekstrakcji)

**Problem:** Logika flush była zakodowana inline w `drawText()` (linie ~488-510). To powodowało:
- Duplikacja kodu gdyby ktoś chciał flushować z innego miejsca
- `CachedText::drawTTF()` NIE mogła wywołać flush — nie miała dostępu
- Brak modularności — trudno testować/debugować flush osobno

**Zmiana — ekstrakcja metody:**

Blok inline w `drawText()`:
```cpp
// PRZED (inline w drawText()):
for (auto& atlas : m_atlases) {
    if (!atlas.texture || atlas.pendingUploads.empty()) continue;
    auto texture = atlas.texture;
    auto atlasImage = atlas.image;
    auto uploads = std::move(atlas.pendingUploads);
    atlas.pendingUploads.clear();
    g_drawPool.addAction([texture, atlasImage, uploads = std::move(uploads)]() mutable {
        // ... create texture or sub-pixel upload ...
    });
}
```

Zastąpiony wywołaniem:
```cpp
// PO (w drawText()):
flushPendingUploads();
```

Nowa osobna metoda `TTFFont::flushPendingUploads()` dodana przed `drawText()`, z pełnym Doxygen komentarzem. Logika identyczna, zero zmian semantycznych.

---

### 1.4 `src/framework/graphics/cachedtext.cpp` (+6)

**Problem (KRYTYCZNY BUG):** `CachedText::drawTTF()` wywoływał `update()` → `buildQuads()` → `cacheGlyph()` → `rasterizeGlyph()` co dodawało glify do `atlas.pendingUploads`. Ale **NIGDY nie wywoływał flush** — atlas textures nie były przesyłane na GPU! Efekt: tekst renderowany przez CachedText był **całkowicie niewidoczny** na GPU (quady rysowane z pustymi/niezainicjalizowanymi teksturami).

**Kiedy to się objawia:**
- Każdy widget z `CachedText` (UILabel, UITextEdit, UIButton z text-auto-resize)
- Konsola czatu (chat console)
- NPC dialogi
- Nazwy graczy nad postaciami

**Zmiana:**
```cpp
// DODANO w CachedText::drawTTF(), przed renderowaniem quadów:
if (m_font && m_font->getTTFFont())
    m_font->getTTFFont()->flushPendingUploads();
```

---

## 2. Ścieżki renderowania — analiza kompletności flush

Po zmianach — status flush w każdej ścieżce:

| Ścieżka renderowania | Flush | Status |
|-----------------------|-------|--------|
| `TTFFont::drawText()` → inline quady | `flushPendingUploads()` | ✅ NAPRAWIONE (ekstrakcja) |
| `BitmapFont::drawText()` TTF path → `m_ttf->drawText()` | Przez `drawText()` | ✅ OK (deleguje) |
| `BitmapFont::drawColoredText()` TTF path → `m_ttf->drawText()` per segment | Przez `drawText()` | ✅ OK (deleguje) |
| `CachedText::drawTTF()` → cached quady | `flushPendingUploads()` | ✅ **NAPRAWIONE** (dodany flush) |
| `CachedText::draw()` → bitmap path | N/A (nie TTF) | ✅ N/A |

---

## 3. Potencjalne ryzyka kompilacji

| # | Ryzyko | Prawdopodobieństwo | Opis |
|---|--------|-------------------|------|
| 1 | MSVC ICE na nowym kodzie | NISKIE | Nowy `flushPendingUploads()` to prosta metoda, brak szablonów — ICE mało prawdopodobne |
| 2 | Linker: undefined symbol | NISKIE | Metoda zdefiniowana w .cpp, zadeklarowana w .h — standard |
| 3 | Warning: unused variable | NISKIE | `wasEmpty` w lambda — używane w `if` |
| 4 | getBitmap font accessor | NISKIE | `m_font->getTTFFont()` — metoda istnieje, sprawdzane `if != null` |

---

## 4. Weryfikacja — co sprawdzić po buildzie

### ✅ Build Linux PASS (commit `e74e30ad5`):
- Kompilacja przeszła pomyślnie
- **2 warningi** — fixy przygotowane w staging (nie pushowane jeszcze):

#### Warning 1: `TextShaper.cpp:132` — `fribidi_reorder_line` return value ignored
```
warning: ignoring return value of 'FriBidiLevel fribidi_reorder_line(...)' 
declared with attribute 'warn_unused_result' [-Wunused-result]
```
**Przyczyna**: `fribidi_reorder_line()` jest oznaczona `warn_unused_result`, a my ignorowaliśmy return value.  
**Fix (staging)**: Przechwytujemy return value i sprawdzamy → jeśli 0, zwracamy oryginalną kolejność.

#### Warning 2: `main.cpp:82` — `operator delete` na obiekcie nie z heap'a (**PRAWDZIWY BUG!**)
```
warning: 'operator delete' called on unallocated object 'g_client' [-Wfree-nonheap-object]
```
**Przyczyna**: `ApplicationDrawEventsPtr(&g_client)` tworzy `shared_ptr` z adresu **globalnego** obiektu `Client g_client;`. Gdy `shared_ptr` się zniszczy → `delete` na nie-heap obiekcie → **undefined behavior**!  
**Fix (staging)**: No-op deleter: `ApplicationDrawEventsPtr(&g_client, [](ApplicationDrawEvents*){})` — `shared_ptr` nie wywoła `delete`.  
**Uwaga**: Ten bug mógł powodować crashe przy zamykaniu aplikacji na niektórych platformach.

### 🔄 Build Windows — W TOKU

### ❌ Build FAIL:
1. Sprawdzić logi GitHub Actions → konkretny błąd kompilacji
2. Jeśli ICE C1001 → dodać `flushPendingUploads()` do pliku z niższą optymalizacją
3. Jeśli linker error → sprawdzić czy `.cpp` jest w CMakeLists.txt (jest — `TTFFont.cpp`)
4. Jeśli warning-as-error → poprawić warning i re-push

---

## 5. Co dalej — plan kolejnych commitów na i18n

| # | Commit | Status | Zależność |
|---|--------|--------|-----------|
| 1 | `fix(ttf): extract flushPendingUploads, fix glyph metrics` | ✅ PUSHED (`e74e30ad5`) — Linux ✅, Windows ✅ | — |
| 1b | `fix(warnings): fribidi return value + g_client no-op deleter` | ✅ PUSHED (`30a897eea`) | — |
| 2 | `feat(i18n): auto-size buttons, sidebar, text-wrap + tr()` | ✅ PUSHED (`564ce5c5f`) — skopiowane do Windows kopia | — |
| 3 | `fix(ttf): g_mainDispatcher for uploads + lazy bind` | ✅ PUSHED (`6c6291b4d`) — **ROOT CAUSE FIX brakujących liter** | — |

---

## 6. Podsumowanie sugestii GPT (ocena)

| # | Sugestia GPT | Status w kodzie i18n |
|---|-------------|---------------------|
| 1 | "Jedna ścieżka pomiarowo-renderowa" | ✅ Zaimplementowane — HarfBuzz shaping w obu `measureTextWidth()` i `buildQuads()` |
| 2 | "TTF + shaping + fallback zamiast ASCII-only" | ✅ Wszystkie fonty TTF+HarfBuzz (oprócz jednego bitmap cipsoftFont) |
| 3 | "Nigdy nie pomijaj glifu, fallback zamiast brak" | ✅ `cacheGlyph()` próbuje main → fallback fonts → cachuje sentinel. Opcjonalnie: U+FFFD w przyszłości |
| 4 | "Stały zestaw fontów" | ✅ NotoSans + Hebrew + Arabic + SC + JP w każdym .otfont |
---

## 7. ROOT CAUSE — Brakujące/niewidoczne litery (commit `6c6291b4d`)

### 7.1 Objawy

Po kompilacji na Windows (build z commitu `e74e30ad5`) **wiele liter się nie wyświetlało**:
- EN: "eneral Hotkeys" (brak G), "nter ace" (brak I,f), "raphics" (brak G), "isc." (brak M), "ove stacks" (brak M), "maximi ed" (brak z), "isplay" (brak D), "alk delay a ter" (brak W,f), "oor change" (brak fl), "Hotkeys anager" (brak M)
- PL: "lasyczna" (brak K), "po cigu" (brak ś), "Przenie stosy bezpo rednio" (brak ś), "aksymalnie" (brak M), "Wy wietlaj wiadomo ci" (brak ś), "enedzer" (brak M)

**Wzorzec**: Brakujące litery nie były specyficzne dla jednego fontu czy języka — to były losowe glify których tekstura atlasu nigdy nie była uploadowana na GPU.

### 7.2 Root Cause — DrawPool throttling kasuje upload tekstur

**Mechanizm awarii:**

1. `flushPendingUploads()` używał `g_drawPool.addAction(lambda)` do schedulowania uploadu glifów na GL thread
2. **FOREGROUND DrawPool** (do którego trafia UI/tekst) ma `setFPS(10)` — działa z throttlingiem 10 FPS
3. W `DrawPool::release()`:
   - Gdy `canRepaint()` zwraca `false` (hash UI się nie zmienił + timer 100ms nie minął)
   - **WSZYSTKIE obiekty w pool'u są kasowane** — w tym lambdy z `addAction()`!
4. Efekt: upload tekstury glifa schedulowany w Frame N → `canRepaint()=false` w Frame N → lambda **usunięta bez wykonania** → atlas region pusty → litera niewidoczna

**Dlaczego zależało od konkretnych liter:** Glify cache'owane "na żądanie" (lazy). Litera renderowana pierwszy raz → rasteryzacja → pending upload → addAction → **wyścig z canRepaint()**. Jeśli w tej samej klatce hash UI się nie zmienił (np. panel już narysowany), upload ginął.

### 7.3 Fix (2 pliki)

**`src/framework/text/TTFFont.cpp`:**
```cpp
// PRZED (broken):
g_drawPool.addAction([texture, atlasImage, uploads = std::move(uploads)]() mutable { ... });

// PO (fixed):
g_mainDispatcher.addEvent([texture, atlasImage, uploads = std::move(uploads)]() mutable { ... });
```
- `g_mainDispatcher.addEvent()` → eventy procesowane **w każdej klatce** w `mainPoll()`, **przed** `g_drawPool.draw()`
- Gwarantuje: tekstura gotowa zanim quady ją referencują
- Nie podlega throttlingowi draw pool'a

**`src/framework/graphics/texture.cpp`:**
```cpp
void Texture::bind() {
    // DODANO — lazy creation safety net:
    if (m_id == 0 && m_image && g_graphics.ok()) {
        create();
    }
    // ...existing bind code...
}
```
- Ostatnia linia obrony: jeśli event z `g_mainDispatcher` nie zdążył się wykonać przed renderingiem
- `bind()` woła `create()` tworząc GL texturę z `m_image` (dane CPU) na miejscu

### 7.4 Dlaczego commit `e74e30ad5` nie naprawił tego problemu

Commit `e74e30ad5` naprawił **3 inne bugi**:
1. `m_glyphHeight` = lineHeight() → poprawne metryki layoutu (litery nie obcinane)
2. `flushPendingUploads()` wydzielone → reużywalne
3. CachedText wołał flush → ale flush wciąż używał `g_drawPool.addAction()` (→ gubił uploady!)

Te fixy były konieczne ale niewystarczające — root cause (addAction vs addEvent) ujawnił się dopiero po testach wizualnych na screenshotach.