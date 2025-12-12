# Internacjonalizacja Testyy — Kolejne Kroki i Priorytety

Dokument utworzony: 2025-01-XX  
Ostatnia aktualizacja: **2025-12-12**

---

## 🔴 NOWA FAZA: PROTOKÓŁ KLIENT-SERWER (2025-12-12)

### Cel
Zmodyfikować protokół komunikacji tak, aby **serwer wysyłał klucze i18n**, a **klient tłumaczył teksty lokalnie** używając istniejącej funkcji `tr()`.

### Dlaczego ta zmiana?
| Poprzednie podejście | Nowe podejście |
|---------------------|----------------|
| Serwer tłumaczy teksty | Serwer wysyła tylko klucze |
| Duże obciążenie CPU/RAM | Minimalne obciążenie serwera |
| Większy bandwidth | Mniejsze pakiety |
| Mutex contention | Brak synchronizacji |

### Co trzeba zrobić po stronie KLIENTA (testyy)

#### Etap 1: Analiza protocolgame.cpp
- [ ] Przeanalizować `parseTextMessage()` w `src/client/protocolgame.cpp`
- [ ] Zidentyfikować format pakietu tekstowego (opcode, type, text)
- [ ] Sprawdzić jak działa integracja z `tr()` w `modules/corelib/keyboard.lua`

#### Etap 2: Modyfikacja parsera
- [ ] Rozszerzyć `parseTextMessage()` o odczyt opcjonalnego pola `i18nKey`
- [ ] Format pakietu: `[opcode][type][text][hasI18nKey:byte][i18nKey:string?]`
- [ ] Jeśli `hasI18nKey == 1` → wywołać `tr(i18nKey)`
- [ ] Fallback: jeśli `tr()` zwraca ten sam klucz → użyć `text`

#### Etap 3: Integracja z systemem tłumaczeń
- [ ] Upewnić się że `tr()` działa poprawnie z kluczami z serwera
- [ ] Przenieść klucze z `canary_test/i18n/en/*.json` do `testyy/data/locales/`
- [ ] Stworzyć skrypt konwersji JSON → Lua locales

### Pliki do modyfikacji

| Plik | Ścieżka | Co zrobić |
|------|---------|-----------|
| protocolgame.cpp | `src/client/` | Rozszerzyć parseTextMessage() |
| keyboard.lua | `modules/corelib/` | Upewnić się że tr() działa |
| *.lua | `data/locales/` | Dodać klucze z serwera |

### Współpraca z serwerem

Równolegle modyfikowany jest serwer (canary_test):
- `src/server/network/protocol/protocolgame.cpp` - wysyłanie kluczy
- Dokumentacja serwera: `canary_test/docs/I18N_PROTOCOL_IMPLEMENTATION.md`

---

## 🎉 OSIĄGNIĘTE CELE (2025-12-05)

### ✅ KOMPLETNE - 53 Języki
Wszystkie 53 lokalizacje mają teraz 150-500+ ciągów tekstowych!

### ✅ KOMPLETNE - Fix Emscripten/WASM Build
CMake używa standardowego FindLua dla WASM.

### ✅ KOMPLETNE - Dokumentacja
- BUILD_GUIDE.md, DEPENDENCIES.md, ARCHITECTURE.md
- TEXT_RENDERING.md, MODULES.md, SOURCE_CODE.md
- I18N_SUMMARY.md, CI_STATUS.md

---

## Spis treści
1. [Priorytety naprawcze (CI)](#priorytety-naprawcze-ci)
2. [Optymalizacje i dopracowanie](#optymalizacje-i-dopracowanie)
3. [Testy i dokumentacja](#testy-i-dokumentacja)
4. [Długoterminowe cele](#długoterminowe-cele)
5. [Szczegóły techniczne](#szczegóły-techniczne)

---

## Priorytety naprawcze (CI)

### 1. Naprawić konflikt typów w asyncdispatcher (KRYTYCZNE) ✅ 2025-12-06
- **Błąd:** `error: conflicting declaration 'thread_pool<...auto...> g_asyncDispatcher'` w `asyncdispatcher.cpp:41`.
- **Przyczyna:** Nagłówek deklaruje `extern BS::thread_pool g_asyncDispatcher;`, implementacja definiuje `BS::thread_pool g_asyncDispatcher{ ... };` z domyślnymi parametrami.
- **Działania:** [WYKONANE] Nagłówek i implementacja używają `BS::thread_pool<>`.
- **Weryfikacja:** lokalny build `cmake --build . --target otclient` bez błędu; logi SonarCloud czyste.

### 2. Zaktualizować vcpkg baseline / wersje portów (KRYTYCZNE) ✅ 2025-12-06
- **Błąd:** Brak wpisów dla `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0` w bazie wersji (`builtin-baseline = b322346f...`).
- **Działania:** [WYKONANE] `vcpkg.json` wskazuje baseline `5b1214315250939257ef5d62ecdcbca18cf4fb1c`, który zawiera wymagane wersje portów.
- **Weryfikacja:** `vcpkg install --manifest --x-manifest-root=Tibia/silnik/canary_test/testyy` przechodzi na Windows i Linux.

### 3. Uprzątnąć ostrzeżenia kompilatora (ŚREDNIE) ⏳ częściowo done
- **eventdispatcher.h:104:** [OK] sformatowano `enum class ThreadTaskEventState` bez zbędnych separatorów.
- **platformwindow.h:84:** [OK] domyślna implementacja jawnie ignoruje parametr (`static_cast<void>(color);`).
- **Cel:** utrzymać czysty build bez warningów; pozostałe ostrzeżenia analizować na bieżąco.

### 4. Naprawić `build-linux.yml` (NISKIE, ale mylące) ✅ 2025-12-06
- Dodano nowy workflow `testyy/.github/workflows/build-linux.yml` uruchamiający build na Ubuntu (Ninja + manifest vcpkg + basic tests).

---

## Optymalizacje i dopracowanie

### A. Batching w `TTFFont::drawText` (WYSOKI)
- Grupować quady według atlasu i wysyłać do `DrawPool` jednym wywołaniem.
- Dodać API `addTexturedRectsBatch` lub podobne.
- Korzyść: mniejsza liczba draw calli i lepsza wydajność UI.

### B. `uploadSubImage` dla atlasu (ŚREDNI)
- Zamiast re-uploadować cały atlas, aktualizować tylko region nowego glifu.
- Wymaga wsparcia po stronie `Texture` (np. `updateSubRegion`).

### C. Cache shapingu (ŚREDNI) ✅ 2025-12-06
- `TextShaper::shape` posiada teraz prosty cache LRU (256 wpisów / 256 znaków max), więc wielokrotne renderowanie tych samych tekstów w różnych widżetach nie wykonuje ponownie HarfBuzz/FriBidi.

---

## Testy i dokumentacja

### 1. Testy jednostkowe `TTFFont` (WYSOKI)
- Załadowanie fontu, pomiar szerokości, obsługa UTF-8 wielobajtowego.
- Plik docelowy: `tests/framework/text/ttffont_test.cpp`.

### 2. Testy `TextShaper` (ŚREDNI)
- ASCII, RTL, kombinowane znaki (np. `e + ́`).

### 3. Smoke test UI w CI (ŚREDNI)
- Headless test rysujący przykładowy tekst i porównujący obraz (lub sprawdzający brak crasha).

### 4. Dokumentacja modułu tekstowego (NISKI) ✅ 2025-12-06
- Plik `src/framework/text/README.md` opisuje pipeline (LocaleShaping → TextShaper → TTFFont → CachedText) i zawiera instrukcje dodawania nowych fontów oraz fallbacków.

---

## Długoterminowe cele

### Pełna obsługa caret/selection z grapheme clusters
- Wymaga biblioteki ICU lub tabel Unicode.
- Integracja z `UITextEdit` i klawiaturą.

### Font fallback i paczki językowe
- Konfiguracja fallbacków (np. Noto Sans CJK, Noto Emoji).
- Automatyczny dobór fontu gdy glif nie istnieje.

### Kolorowe emoji
- Obsługa COLR/CPAL lub CBDT w FreeType.
- Potrzebne wsparcie RGBA w atlasie i DrawPool.

---

## Szczegóły techniczne

### Asyncdispatcher — przykład zmiany
```cpp
// asyncdispatcher.h
extern BS::thread_pool<> g_asyncDispatcher;

// asyncdispatcher.cpp
BS::thread_pool<> g_asyncDispatcher{ getThreadCount() };
```

### Aktualizacja `vcpkg.json`
```json
{
  "builtin-baseline": "<nowy_commit>",
  "dependencies": [
    { "name": "abseil" },
    { "name": "angle" },
    { "name": "asio" }
  ]
  // overrides opcjonalnie, jeśli potrzebne
}
```

### TTFFont batching — szkic
```cpp
std::unordered_map<int, std::vector<TexturedQuad>> batches;
for (const auto& glyph : shaped) {
    auto info = cacheGlyph(glyph.codepoint);
    batches[info.atlasId].push_back({destRect, info.texCoords});
}
for (auto& [atlasId, quads] : batches) {
    g_drawPool.addTexturedRectsBatch(m_atlases[atlasId].texture, quads);
}
```

---

## Tabela priorytetów

| # | Zadanie | Priorytet | ETA | Zależności |
|---|---------|-----------|-----|------------|
| 1 | Naprawić asyncdispatcher | 🔥 | 5 min | brak |
| 2 | Zaktualizować vcpkg baseline | 🔥 | 30 min | brak |
| 3 | Ostrzeżenia eventdispatcher/platformwindow | ⚠️ | 5 min | #1 |
| 4 | build-linux.yml cleanup | ⚠️ | 10 min | #1 |
| 5 | TTFFont batching | ⬆️ | 1-2 h | #1-4 |
| 6 | Cache shapingu | ⬆️ | 1 h | #5 |
| 7 | Atlas subimage upload | ⬇️ | 1 h | #5 |
| 8 | Testy TTFFont/TextShaper | ⬆️ | 3 h | #5-6 |
| 9 | Smoke test UI w CI | ⬆️ | 2 h | #8 |
| 10 | Dokumentacja modułu tekstu | ⬇️ | 1 h | #8-9 |

Legenda: 🔥 krytyczne, ⚠️ średnie, ⬆️ ważne po CI, ⬇️ nice-to-have.

---

Aktualizuj ten dokument po każdym wykonanym kroku — zaznaczaj ✅/⏳/❌ przy zadaniach oraz dopisuj daty wdrożeń.
- [x] Dodać `vcpkg install --manifest` step do workflowów (preflight) plus `vcpkg search` diagnostyka (done).

## Checklista implementacyjna (small PRs)
1. PR: dodanie `/utf-8` dla MSVC (zrobione).
2. PR: `uitextedit` – TTF fast path + selection logic (zrobione).
3. PR: `TTFFont` — batch per atlas + uploadSubImage; testy performance.
4. PR: `CachedText` — shaper run buffer for TTF; cursor selection fix based on clusters.
5. PR: Database migrations & tests for `utf8mb4`.
6. PR: Reintroduce `libobfuscate` as overlay port OR add docs/instructions for re-adding the port.
7. PR: Unit tests + Phantom smoke tests in GH Action.

---

Jeśli chcesz, mogę od razu dodać pierwszy test jak `NetworkMessage` binary-safe (jeden niewielki test w `tests/unit`), a następnie zaplanować PR do TTFFont batchowania. Który krok preferujesz? (Proponuję teraz testy C.)
