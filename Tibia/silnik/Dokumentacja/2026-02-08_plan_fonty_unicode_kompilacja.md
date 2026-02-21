# Plan prac: Rendering fontów Unicode + Kompilacja multi-platform

**Data:** 2026-02-08  
**Ostatnia aktualizacja:** 2026-02-09  
**Status:** W TRAKCIE  
**Priorytet:** WYSOKI — blokuje release wielojęzyczny

---

## 1. Problem z renderingiem liter Unicode (OTC Klient)

### Opis problemu
Litery spoza ASCII (polskie: ą, ć, ę, ł, ń, ó, ś, ź, ż, oraz inne języki) nie wyświetlają się poprawnie w kliencie:
- **Niepoprawne odstępy** między literami (spacing/kerning)
- **Niepoprawna wielkość** glyphów — za duże lub za małe w porównaniu do oryginalnych angielskich liter
- **Cel:** Litery Unicode muszą wyglądać identycznie jak oryginalne angielskie w każdym rozmiarze (8px cipsoft, 10px verdana, 12px noto, itd.)

### Architektura systemu fontów OTC

**Pliki źródłowe C++:**
- `src/framework/text/TTFFont.cpp` (655 linii) — renderer TTF, FreeType + HarfBuzz, atlasy glyphów
- `src/framework/text/TTFFont.h` (194 linii) — definicja klasy, metryki: bearingX, advance, glyph atlas
- `src/framework/text/TextShaper.cpp` (234 linii) — HarfBuzz text shaping (odpowiada za kerning/spacing)
- `src/framework/text/TextShaper.h` (34 linii)
- `src/framework/graphics/bitmapfont.cpp` (870 linii) — renderer bitmap fontów (legacy) + integracja TTF
- `src/framework/graphics/bitmapfont.h` (110 linii)
- `src/framework/graphics/fontmanager.cpp/h` — ładowanie i zarządzanie fontami

**Konfiguracje fontów (`data/fonts/`):**
- `noto-12.otfont` — **domyślny TTF font**, NotoSans-Regular.ttf, size 12, z fallbackami na inne skrypty (chiński, hebrajski, arabski, japoński)
- `cipsoftFont.otfont` — bitmap 8×8, oryginalny font Cipsoft
- `verdana-10px.otfont`, `verdana-11px-antialised.otfont` — bitmap fonty z cp1250 (polskie znaki)
- `sans-bold-16px.otfont` — bitmap z cp1250/cp1252

**Fonty TTF dostępne (`data/fonts/ttf/`):**
- NotoSans-Regular.ttf (główny)
- NotoSans-Bold.ttf
- NotoSansMono-Regular.ttf
- + fallbacki: arabski, hebrajski, chiński (SC), japoński, bengalski, devanagari, etiopski, armeński, gruziński, khmerski, malajalam, birmański, gudźarati, tamilski, telugu, tajski

**Stos technologiczny:**
- FreeType — rasteryzacja TTF → bitmapy glyphów
- HarfBuzz — text shaping (kerning, ligatures, advance widths, bidi)
- Atlas glyphów — cachowanie zrasteryzowanych glyphów w teksturach GPU
- BitmapFont — fallback na bitmap fonty (legacy, cp1250/1252)

### Co trzeba naprawić

1. **Metryki advance/spacing w TTFFont.cpp** — sprawdzić czy HarfBuzz poprawnie oblicza advance widths dla polskich znaków
2. **Glyph rendering size** — zweryfikować że m_glyphHeight i bearingX/Y są spójne z angielskimi literami
3. **TextShaper** — upewnić się że shaping poprawnie obsługuje Latin Extended (ąćęłńóśźż)
4. **Atlas cache** — sprawdzić czy glyphs Unicode nie mają artefaktów (overflow na atlas texture)
5. **Font fallback chain** — NotoSans-Regular.ttf pokrywa Latin Extended, więc nie wymaga fallbacku, ale sprawdzić
6. **line height** — BitmapFont::drawText oblicza lineHeightPx jako max(ttf->lineHeight(), m_glyphHeight, ascent+descent) — może powodować niespójności

### Pliki do modyfikacji (C++ klient — wymaga rekompilacji)
- `src/framework/text/TTFFont.cpp` — główne poprawki renderingu
- `src/framework/text/TextShaper.cpp` — poprawki shaping
- `src/framework/graphics/bitmapfont.cpp` — integracja TTF, metryki
- Ewentualnie konfiguracje `.otfont` — parametry glyph-size, height, spacing

---

## 2. Kompilacja OTC na platformy

### A) Kompilacja WWW (Emscripten/WASM)
- **Istnieje** pełne wsparcie Emscripten w `src/CMakeLists.txt` (browserwindow, browserplatform, webconnection)
- **Istnieje** `browser/shell.html` + `browser/overlay-ports/` (abseil, physfs, protobuf, lua51)
- **Utworzono** workflow `.github/workflows/build-wasm.yml` — Emscripten 3.1.56, vcpkg wasm32-emscripten, Ninja
- FreeType i HarfBuzz kompilują się pod WASM (wsparcie w vcpkg)

### B) Kompilacja Android
- **Istnieje** katalog `android/` z Gradle build (GameActivity, Kotlin)
- **Istnieje** w CMakeLists.txt: `VCPKG_TARGET_ANDROID` + `vcpkg_android.cmake`
- **Utworzono** workflow `.github/workflows/build-android.yml` — NDK r27, Gradle, vcpkg (arm64-v8a, armeabi-v7a)
- **Zaktualizowano** `build.gradle`: stabilny NDK 27.2.12479018, CI-overridable ABI filter via `-Pabi=`

### C) Kompilacja Windows (GitHub Actions)
- **Utworzono** workflow `.github/workflows/build-windows.yml` — MSVC + Ninja + vcpkg x64-windows-static
- Statyczny runtime library (/MT), GHA binary caching

### D) Kompilacja Linux (GitHub Actions)
- **Naprawiono** workflow `.github/workflows/build-linux.yml` — re-enabled, lukka/run-vcpkg@v11, GHA binary caching

---

## 3. Kolejność prac

### Faza 1: Weryfikacja i18n completeness (TERAZ — Codex tłumaczy EN→PL)
- [x] Server-side: 1,048 kluczy achievementów
- [x] OTC-side: character.lua → tr() z fallback
- [ ] Codex tłumaczy wszystkie klucze EN→PL
- [ ] Weryfikacja kompletności tłumaczeń

### Faza 2: Fix renderingu fontów Unicode ✅ (commit `e94513e4c`)
- [x] Analiza problemu spacing/sizing polskich znaków
- [x] **KRYTYCZNY BUG**: Bitmap fonty przetwarzały tekst bajt-po-bajcie (`uint8_t text[i]`) — UTF-8 polskie znaki (np. 'ą' = 0xC4 0x85) renderowały się jako 2 śmieciowe glyphe
- [x] Konwersja 11 bitmap fontów na TTF (NotoSans) — bypass uszkodzonego bitmap path
- [x] Atlas `setSmooth(false)` — ostra tekstura zamiast rozmytego bilinear filtering
- [x] FreeType `FT_LOAD_TARGET_LIGHT` / `FT_RENDER_MODE_LIGHT` — lżejszy hinting dla akcent chars
- [x] Multi-line rendering TTF w `BitmapFont::drawText()` i `CachedText::update()` — split po '\n'
- [ ] Testy wizualne — porównanie EN vs PL liter w każdym rozmiarze fontu (wymaga kompilacji)
- [ ] Fine-tuning rozmiarów TTF (obecne mapowania to estymaty)
- [ ] Fix bitmapfont.cpp jeśli legacy fonty nadal używane (konwersja na TTF już zastosowana)

### Faza 3: Kompilacja multi-platform ✅ (commit `48a5dea99`)
- [x] Naprawić kompilację Linux (workflow re-enabled, lukka/run-vcpkg@v11)
- [x] Naprawić kompilację Windows (workflow `build-windows.yml` — MSVC + Ninja + vcpkg)
- [x] Naprawić kompilację Android (workflow `build-android.yml` — NDK r27 + Gradle + vcpkg)
- [x] Zbadać kompilację WWW (workflow `build-wasm.yml` — Emscripten + vcpkg wasm32-emscripten)

### Faza 4: Testing & Release
- [ ] Test PL w kliencie Windows
- [ ] Test PL w kliencie Android
- [ ] Test PL w kliencie WWW (jeśli gotowy)
- [ ] Test innych języków (DE, FR, ES, itd.)

---

## 4. Dodatkowe uwagi

- **Server Canary nie renderuje fontów** — serwer wysyła klucze i18n, klient tłumaczy i renderuje
- **OTC C++ parser achievementów** — nadal `break;` (ignoruje dane z serwera). Klient korzysta z lokalnej tabeli Lua + tr(). To jest OK na teraz.
- **Protobuf StaticDataAchievement** — tylko deklaracja, nigdzie w kodzie nie jest używana
- **bed.cpp / item.cpp** — brak kontekstu Player* (znane ograniczenie, odłożone na później)


Now I have a very thorough understanding of the font rendering system. Let me identify the potential issues:

TTFFont.cpp - The core rendering is:

FreeType rasterizes at pixelSize
HarfBuzz shapes and provides advance/offset values
buildQuads() positions glyphs using HB advances + FT bearing
cacheGlyph() handles fallback fonts
TextShaper.cpp - HarfBuzz shaping:

Uses FriBidi for bidi reordering
Calls hb_shape() with script/language/direction params
Returns glyph indices, codepoints, and positioning offsets with advance values
BitmapFont.cpp - Integration:

TTF path: calls m_ttf->drawText() with baseline position
Bitmap path: uses 8-bit glyph indices (0-255), cp1250 texture
Now I'm thinking about what could cause spacing or sizing problems with Polish characters. The texture smoothing in ensureAtlas() enables bilinear filtering, which might be affecting how the glyphs appear when rendered.

I'm also considering the atlas size constraints and glyph packing padding, though those seem reasonable. The real issue might be with how m_glyphHeight is set when loading TTF fonts — FreeType's line height metrics could differ from the requested pixel size, especially with fonts like Noto.

The baseline calculation in the TTF rendering path takes the maximum of three different height values, which could create inconsistencies if they don't align. And there's a potential size mismatch too — the bitmap fonts use specific sizes like verdana 10px or 11px, but the TTF font is 12px, which might look oversized if the UI expects smaller fonts in certain places.

Looking more closely at how fonts are loaded, TTF fonts take one path while bitmap fonts take another. So when text contains Polish characters like ąćę, I need to figure out which font actually renders them. The bitmap fonts declare support for cp1250 charset, which should cover those characters...

but there's a critical issue: the bitmap rendering code treats each byte as a glyph index directly, and UTF-8 encoded Polish characters are multi-byte sequences. So a character like 'ą' (encoded as 0xC4 0x85 in UTF-8) would try to render as two separate glyphs instead of one, which is fundamentally broken.

However, looking at the actual font configuration, noto-12 is set as the default font with TTF rendering enabled, which means the game UI should be using the proper TTF path that handles UTF-8 correctly. The bitmap fonts like verdana and terminus are just legacy fallbacks that wouldn't be used for normal text rendering.

The real problem might be that NotoSans at 12 pixels doesn't match the visual metrics of the original bitmap fonts—the character sizes, spacing, and line heights could all be different from what the UI was designed for. The user reported wrong letter spacing and character sizes, so I should trace through how the advance values are being calculated in the text shaping code to see if there's a conversion issue between HarfBuzz's fixed-point output and the final pixel values. I'm checking how empty glyphs are handled in the cache — the advance gets stored but never actually used since HarfBuzz provides the positioning. Now I'm wondering about other font issues, particularly how m_glyphHeight is being used throughout the codebase when it's set from the loaded font size.

Looking at the line height calculations across different places, I'm seeing that for NotoSans at 12px, the final line height ends up being around 15px when taking the maximum of FreeType's metrics, the stored glyph height, and the ascent/descent sum. The glyph rendering itself should be correct since FreeType is working at the requested size, so I'm starting to think the real issue might be elsewhere.

Re-reading what the user described about Polish character spacing and size being wrong, I'm realizing this could be two separate problems: either the spacing between characters is off, or the characters themselves appear the wrong size. Since we switched from Verdana 11px to NotoSans 12px, these are fundamentally different fonts with different metrics and proportions, which would naturally make everything look different. The core question is whether we should be generating pre-rendered bitmap fonts for each size or adjusting how we're rendering the TTF to match the original appearance. Given that the user needs proper support for Polish and other languages, I need to figure out which approach makes sense.

The TTF rendering approach is the right direction since bitmap fonts can't handle the full character set, but the rendering itself might be the issue. Smooth filtering on the texture atlas could be making small text look blurry or distorted at the pixel level, which would be wrong for a pixel-based game—I should check if that's set to sharp rendering instead. FreeType's hinting settings might also need adjustment for small font sizes to improve readability, and there could be rounding issues with how character positions are being calculated. I'm realizing the smooth filtering on the atlas texture is likely the main culprit — when glyphs are interpolated between pixels, the characters look blurry and spacing gets distorted from color bleeding. Let me systematically check what needs fixing, starting with whether the bitmap font path uses smooth textures and how the rasterized TTF glyphs differ from hand-crafted pixel atlases.

Checking atlas texture smoothing... TTFFont::ensureAtlas() should probably use setSmooth(false) for pixel-crisp rendering to match Tibia's style. The FreeType load flags could be optimized—maybe FT_LOAD_TARGET_LIGHT for better hinting at small sizes or FT_RENDER_MODE_MONO for purely bitmap rendering like the original fonts. There's also an inconsistency in how line height is calculated across the code. Looking at the multi-line text handling, I notice the TTF path doesn't split on newlines at all—buildQuads only advances penY by sg.advanceY which is typically zero for horizontal text, so multi-line text would just render as a single line. them properly in the TTF path. I'm realizing the text might be getting split at a higher layer in the UI system, but I should still add newline handling to drawText to be safe. Let me organize the fixes: first, I'll adjust the texture smoothing for crisp pixel rendering, then add proper newline splitting to the TTF drawing code, and finally consider whether to make smoothing configurable depending on the use case.

Looking at what the user actually reported—incorrect letter spacing in Polish and wrong font sizes—I need to focus on matching the exact rendering behavior of the original English text display. The font size mismatch is a real issue since the noto-12 font is 12px but Tibia UI typically expects 10-11px elements, and I should investigate whether FreeType's hinting mode affects how letters are spaced and rendered at small sizes. The real issue is that bitmap fonts like cipsoftFont have limited glyph sets and can't render Polish characters—they'd either disappear or display as corrupted text since the bitmap path treats each byte as a single glyph index rather than handling multi-byte UTF-8 sequences properly.

The cleanest fix would be to implement a fallback mechanism where bitmap fonts automatically switch to TTF rendering for any characters outside their glyph range, or convert all fonts to use the TTF path while matching the original pixel sizes. I'm realizing the default font manager might already be handling most text through TTF, so the real problem is likely specific fonts that game modules are explicitly requesting. Let me trace through how fonts are actually being referenced in the code and then tackle the concrete issues: first the multi-line TTF rendering bug where newlines aren't being processed, then adding a bitmap-to-TTF fallback for non-ASCII characters, testing atlas smoothing for crisper pixels, and finally creating the missing font size definitions to match the original bitmap fonts. I should start implementing these fixes rather than continuing to analyze.

The user mentioned this work hasn't been touched in a while, so there's existing code that needs repair. Looking at the current setup, I see noto-12.otfont is already the default TTF font, and I need to check whether mono-12 is also TTF or if it's still using the old bitmap system with cp1250 textures.

Running cat data/fonts/mono-12.otfont && echo "---" && cat...
cat data/fonts/mono-12.otfont && echo "---" && cat data/fonts/sans-bold-16px.otfont && echo "---" && cat data/fonts/small-9px.otfont && echo "---" && cat data/fonts/terminus-10px.otfont && echo "---" && cat data/fonts/terminus-14px-bold.otfont && echo "---" && cat data/fonts/verdana-10px.otfont
