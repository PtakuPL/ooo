3.59 Klient: `StaticText` / `SpriteManager` / `ThingType` — różnice i skutki

3.60 Grafika: system cząsteczek — `Particle`, `ParticleEmitter`, `ParticleSystem`, `UIParticles`
- Upstream vs Redemption: Upstream posiada prostszy `ParticleSystem` z ograniczonym batchingiem; Redemption dodaje warstwowanie i integrację z `DrawPool` oraz UI (`UIParticles`). Emisja cząsteczek respektuje aktualny `draw order` i `hash` pipeline’u, pozwalając na mieszanie z efektami mapy/UI bez naruszenia batched renderingu.
- Klasy/plikI: `testyy/src/framework/graphics/particle.h/.cpp`, `particleemitter.h/.cpp`, `particlesystem.h/.cpp`; dla UI: `testyy/src/framework/ui/uiparticles.h/.cpp`.
- Różnice kluczowe:
  - Batching: Redemption pakuje cząsteczki w identyczne `CoordsBuffer` grupami według `textureId` i trybu blend, minimalizując `glDraw*` wywołania. Upstream częściej renderuje cząsteczki pojedynczo lub w mniejszych paczkach.
  - Życie cząstki: Ujednolicony update w `ParticleSystem::update(dt)` z deterministycznym seedem per-emiter dla replikowalności na kliencie, co stabilizuje efekty w warunkach zmiennego FPS.
  - Shadery: Redemption używa istniejących programów shaderów (`PainterShaderProgram`) z flagami na `additive`/`alpha` blend; Upstream nierzadko przełącza stan globalnie.
- Skutki:
  - Wydajność: Lepsze FPS przy gęstych efektach (deszcz, ogień) przez ograniczenie przełączeń stanu i większe paczki.
  - Spójność wizualna: Efekty cząsteczek poprawnie przechodzą przez ten sam pipeline co sprites/tile — brak „przeskoków” Z, brak „depth buffer”, zgodnie z naszymi zasadami.
  - Integracja UI: `UIParticles` pozwala na lekkie overleje (np. konfetti w UI) bez zaburzania renderingu gry; cząstki UI mają własną kolejkę `DrawPoolType::UIOverlay`.
- Wskazówki implementacyjne:
  - Nie dodawać bufora głębokości do cząsteczek; warstwowanie osiągać przez kolejność w `DrawPool` i grupowanie hash.
  - Emiterzy powinni używać czasu rzeczywistego z `g_clock` i przekazywać `dt` do systemu; nie używać osobnych timerów w wątku.
  - Dla efektów addytywnych ustawić odpowiednie blend state przez istniejące API `Painter::setCompositionMode` lub flagę batchu.

3.61 UI: grafy i efekty — `UIGraph`, `UIGraphPlot`, `UIGraphRenderer`
- Upstream vs Redemption: Upstream posiada podstawowe widgety graficzne; Redemption dodaje zoptymalizowany widget wykresu (`uigraph*.h/.cpp`) z bezpośrednią integracją `CoordsBuffer` i własną, stałą atlasą linii/punktów.
- Pliki: `testyy/src/framework/ui/uigraph.h/.cpp`, `uigraphplot.h/.cpp`, `uigraphrenderer.h/.cpp`.
- Różnice:
  - Rysowanie: Redemption renderuje wykresy w jednym przejściu per warstwa (siatka, linie, punkty) korzystając z buforów współrzędnych i z góry przygotowanych UV w atlasie; Upstream częściej używa osobnego rysowania dla każdego elementu UI.
  - Pamięć: Przechowywanie danych wykresu w strukturach `std::vector<float>` z „ring buffer” dla danych czasu rzeczywistego; rozmiary buforów są przycinane do okna widoku.
- Skutki: Wykresy diagnostyczne mają niskie koszty rysowania, dobrze nadają się do HUD/debug bez degradowania FPS.
- Wskazówki: Aktualizacje danych wykonywać w `onUpdate(dt)` i tylko wtedy przepakowywać `CoordsBuffer`, aby unikać zbędnego CPU.

3.62 Mapy i widoki — `MapView`, `MiniMap`, `UIMap`
- Upstream vs Redemption: Redemption przebudowuje `MapView` pod pełny batching przez `DrawPool` oraz usuwa wszelkie ścieżki zależne od `depth buffer`. `MiniMap` odświeża kafle regionami i renderuje do własnego `FrameBuffer` cache, a `UIMap` jest lekką nakładką umożliwiającą interakcję (panning/zoom) bez zmiany pipeline’u.
- Pliki: `testyy/src/framework/graphics/mapview.h/.cpp`, `minimap.h/.cpp`, `ui/uimap.h/.cpp`.
- Różnice:
  - `MapView`:
    - Render kafli, obiektów i efektów jest dzielony na warstwy (`Ground`, `Objects`, `Top`, `Overlays`) i każda warstwa posiada własne grupy batchu według tekstury i shader state.
    - Przeliczanie widoku używa macierzy ortho bez depth; sortowanie Z to czysto logiczna kolejność rysowania.
    - Obsługa animacji (np. wodą) realizowana przez zmiany UV/time uniforms w shaderze, nie przez dodatkowe passy.
  - `MiniMap`:
    - Regionowy cache: kafelki są rysowane do `FrameBuffer` przy zmianie danych; przesuwanie/zoom używa tekstury FBO, co minimalizuje koszt.
    - Zastosowanie prostych kolorów/legend bez nakładania głębi.
  - `UIMap`:
    - Input: panning, zoom, marker selection — zdarzenia przenoszone do `MapView` przez API, bez rysowania „poza kolejką”.
- Skutki:
  - Wydajność: Stabilny FPS na dużych mapach dzięki warstwowanemu batchowaniu i FBO cache dla minimapy.
  - Kompatybilność: Brak zależności od depth buffer ułatwia porty (ES2); spójność z całym pipeline’em.
- Wskazówki:
  - Nie wprowadzać dodatkowego render pass z buforem głębokości; ewentualne „nakładki” realizować jako warstwy w `DrawPool`.
  - Dbać o spójne hashe batchu (tekstura, shader, blend) — to warunek skuteczności.

  3.63 UI: wspólne widgety — `UIButton`, `UICheckBox`, `UIPanel`, `UIMenu`
  - Upstream vs Redemption: Redemption utrzymuje API kompatybilne, ale ogranicza nadmiarowe rysowanie tła/ramki przez agregację w `DrawPool` i unika per-widget `Painter` zmian stanu. Menu (`UIMenu`) otrzymuje zbuforowaną listę pozycji i rysowanie w jednym przejściu.
  - Pliki: `testyy/src/framework/ui/ui*.h/.cpp` (konkretne klasy: `uiButton`, `uiCheckBox`, `uiPanel`, `uiMenu`).
  - Różnice:
    - Stylowanie: Redemption preferuje atlasę UI i stałe UV zamiast dynamicznego generowania geometry dla prostych ramek — mniej CPU.
    - Zdarzenia: Debouncing kliknięć i klawiatury w ramach głównego dispatchera; upstream częściej reaguje natychmiast, co może skutkować drganiami.
  - Skutki: Stabilny FPS i responsywność UI, brak migotania przy najeżdżaniu i aktywacji.
  - Wskazówki: Nie używać `glLine*` ani osobnych passów na obwódki — wszystko przez atlasę i `CoordsBuffer`.

  3.64 UI: pasek postępu i elementy gry — `UIProgressBar`, `UIItem`
  - Upstream vs Redemption: `UIProgressBar` korzysta z prekomponowanych segmentów (atlas) zamiast wielu prostokątów; `UIItem` ściśle integruje się ze `SpriteManager` i `ThingType` przez cache sprite’ów i właściwości, aby nie wykonywać lookupu w czasie rysowania.
  - Pliki: `testyy/src/framework/ui/uiprogressbar.h/.cpp`, `uiitem.h/.cpp`.
  - Różnice:
    - `UIProgressBar`: Aktualizuje geometrię tylko przy zmianie wartości; kolor i styl mapowane na UV w atlasie.
    - `UIItem`: Render przez pojedynczy batch sprite’u itemu; dodatkowe nakładki (np. licznik) jako tekst w osobnej warstwie UI batch.
  - Skutki: Niska cena renderu HUD/ekwipunku, przewidywalne zachowanie przy szybkim odświeżaniu.
  - Wskazówki: Unikać per-frame przebudowy buforów przy stałej wartości; łączyć aktualizacje w tickach UI.

  3.65 UI: layout i hierarchia — `UIWidget` bazowy, układ, clipping
  - Upstream vs Redemption: Redemption utrzymuje prosty layout oparty na kolejności i właściwościach anchoringu; clipping realizuje shaderem i współrzędnymi bez użycia depth buffer lub scissor na każdą kontrolkę.
  - Pliki: `testyy/src/framework/ui/uiwidget.h/.cpp`, powiązane layout helpers.
  - Różnice:
    - Clipping: Preferowane jest scissor na poziomie grupy UI, nie per-widget, aby nie mnożyć zmian stanu.
    - Z-index: Kolejność rysowania zastępuje głębię — zgodnie z pipeline’em, widget nadrzędny zawsze przed podrzędnym.
  - Skutki: Mniejsze przełączenia stanu, prostszy, przewidywalny stacking.
  - Wskazówki: Grupować widgety według wspólnego stylu/tekstyury, aby uzyskać maksymalny batching.

  3.66 UI: menu kontekstowe i interakcje — `UIMenu` rozbudowane
  - Upstream vs Redemption: Redemption dodaje opóźnione budowanie pozycji menu i asynchroniczne wypełnianie (np. z Lua) przez `g_asyncDispatcher`, ale rysuje synchronizowane w głównym wątku w jednym przejściu.
  - Pliki: `testyy/src/framework/ui/uimenu.h/.cpp`.
  - Różnice:
    - Budowa: Pozycje są cache’owane i zmieniane tylko przy aktualizacji modelu; na hover/active nie przebudowuje się całego bufora.
    - Input: Obsługa klawiatury, skrótów i nawigacji strzałkami z debouncingiem.
  - Skutki: Brak „lagów” przy dużych menu, niskie koszty rysowania.
  - Wskazówki: Wszelkie dynamiczne dane dostarczać przez Lua, a w C++ ograniczyć się do przygotowania buforów i wywołań `DrawPool`.

  3.67 UI: przewijanie — `UIScrollArea`
  - Upstream vs Redemption: Upstream używa częstych zmian scissor i osobnych passów; Redemption ogranicza scissor do obszaru przewijania i renderuje zawartość w jednym batched przejściu z przesuniętym originem.
  - Pliki: `testyy/src/framework/ui/uiscrollarea.h/.cpp`.
  - Różnice:
    - Origin: Przewijanie realizowane przez offset współrzędnych w `CoordsBuffer`, nie przez translację macierzy globalnej.
    - Lazy render: Elementy poza viewportem nie trafiają do bufora — selekcja jest wykonywana przy pakowaniu batchu.
  - Skutki: Mniejsze koszty przy dużych listach, płynne przewijanie bez skoków.
  - Wskazówki: Grupować dzieci według tekstury/stylu; aktualizować bufor tylko przy zmianie scroll/rozmiaru.

  3.68 UI: zakładki — `UIPanelTab`
  - Upstream vs Redemption: Redemption utrzymuje taby jako odrębne warstwy UI z prekomponowanym tłem w atlasie; przełączanie tabów nie przebudowuje całego drzewa widgetów.
  - Pliki: `testyy/src/framework/ui/uipaneltab.h/.cpp`.
  - Różnice:
    - Cache: Widoczność/ukrycie sekcji kontrolowane flagą, a rysowanie tabów używa współdzielonego bufora dla labeli i ikon.
    - Input: Klawiatura i skróty do przełączania tabów są debounced i emitują zdarzenia do Lua.
  - Skutki: Szybkie przełączanie bez czkawki GPU/CPU.
  - Wskazówki: Unikać reflow całego układu; ograniczyć się do zmiany widoczności i pozycji.

  3.69 UI: podpowiedzi — `UITooltip`
  - Upstream vs Redemption: Redemption rysuje tooltip jako lekką nakładkę w `DrawPoolType::UIOverlay`, z atlasowym tłem i `CachedText` dla zawartości.
  - Pliki: `testyy/src/framework/ui/uitooltip.h/.cpp`.
  - Różnice:
    - Pozycjonowanie: Tooltip „przykleja się” do kursora/punktu odniesienia z marginesem; clipping grupowy zapobiega wyjściu poza ekran.
    - Tekst: Użycie `CachedText`/`TTFFont` z shaperem zapewnia i18n i poprawne zawijanie.
  - Skutki: Minimalny koszt renderu, brak migotania przy szybkim ruchu kursora.
  - Wskazówki: Aktualizować tekst cache tylko przy zmianie treści; stylować przez atlasę, nie przez dynamiczne rysowanie ramek.

  3.70 Map: zaznaczenia i wybór — `SelectionHighlight`
  - Upstream vs Redemption: Upstream rysuje selekcję jako serię prostokątów; Redemption wykorzystuje pojedynczy batch z atlasową ramką (narożniki + krawędzie) i półprzezroczystym wypełnieniem.
  - Pliki: `testyy/src/framework/graphics/selectionhighlight.h/.cpp` (lub odpowiednik w `mapview` nakładkach).
  - Różnice:
    - Geometria: Ramka budowana z 9-slice (4 rogi, 4 krawędzie, wypełnienie) z UV z atlasu UI.
    - Integracja: Render jako `DrawPoolType::Overlay` nad warstwą obiektów, bez depth.
  - Skutki: Spójna stylistyka i niski koszt renderu przy dużych zaznaczeniach.
  - Wskazówki: Aktualizować bufor tylko przy zmianie obszaru zaznaczenia.

  3.71 Map: ścieżka i nawigacja — `PathOverlay`
  - Upstream vs Redemption: Redemption rysuje wskazanie ścieżki jako serię strzałek/punktów z atlasu, pakowanych w jeden batch; Upstream częściej rysuje każdy segment oddzielnie.
  - Pliki: `testyy/src/framework/graphics/pathoverlay.h/.cpp` (lub moduł w `mapview`).
  - Różnice:
    - Pakowanie: Segmenty ścieżki są filtrowane do widocznego obszaru i grupowane według wspólnej tekstury.
    - Animacja: Opcjonalne „pulsowanie” realizowane przez uniform czasu w shaderze, nie przez przebudowę geometrii.
  - Skutki: Czytelna wskazówka drogi bez obciążenia GPU/CPU.
  - Wskazówki: Używać atlasowych strzałek/punktów; unikać dynamicznego rysowania linii.

  3.72 Map: światło i cienie — `LightSystem`
  - Upstream vs Redemption: Upstream może używać dodatkowych passów/trybów; Redemption pozostaje w ES2-kompatybilnym pipeline, realizując światło jako „lightmap overlay” lub modulację w shaderze bez bufora głębokości.
  - Pliki: `testyy/src/framework/graphics/lightsystem.h/.cpp` i integracja z `MapView`.
  - Różnice:
    - Lightmap: Prekomponowaną teksturę światła nakłada się jako warstwę z mnożeniem (`multiply`) lub addytywnie według trybu; generowanie może być zoptymalizowane regionowo.
    - Shader: Uniformy czasu i intensywności dla efektów migotania; brak per-pixel normali (prostszy model, stabilny FPS).
  - Skutki: Dobre wizualnie, tanie w utrzymaniu efekty świetlne kompatybilne z ES2.
  - Wskazówki: Unikać eksperymentów z G-buffer i depth; trzymać się lightmap i prostych modulacji.

  3.73 Map: debug overlay — siatka, FPS, informacje kafli
  - Upstream vs Redemption: Debugowe nakładki w Redemption są renderowane przez dedykowaną warstwę `DrawPoolType::DebugOverlay`, korzystają z atlasu linii/znaczników i `CachedText` dla podpisów. Upstream częściej używa oddzielnych wywołań rysowania i tekstu bez batching.
  - Pliki: `testyy/src/framework/graphics/debugoverlay.h/.cpp`, integracja z `MapView`.
  - Różnice:
    - Siatka: Rysowana jako zoptymalizowane linie z atlasu (nie `glLine*`), pakowana w jeden `CoordsBuffer` dla widocznego obszaru.
    - Tekst: Opisy kafli/koordynatów jako `CachedText` w jednej paczce UI overlay.
  - Skutki: Aktywne debugowanie nie degraduje wydajności w zauważalny sposób.
  - Wskazówki: Włączać/wyłączać overlay przez flagę; budować geometrię tylko przy zmianie widoku.

  3.74 Grafika: pomocnicze narzędzia — batching, hash, kompozycja
  - Upstream vs Redemption: Redemption wprowadza spójny system batchowania w `DrawPool` oparty o hashe stanu (tekstura, shader, blend, samplowanie, klucz UV) i minimalizuje zmiany GL; upstream posiada bardziej rozproszone decyzje renderujące.
  - Pliki: `testyy/src/framework/graphics/drawpool.h/.cpp` (rozszerzenia), `painter.h/.cpp` (kompozycja), `color.h/.cpp` (transformacje), `coordsbuffer.h/.cpp` (pakowanie geometrii).
  - Różnice:
    - Hash: Klucz batchu budowany jest deterministycznie; zmiany trybu blend lub programu shader automatycznie rozbijają paczki.
    - Kompozycja: `Painter::setCompositionMode` mapuje na ściśle ograniczony zestaw stanów (alpha, additive, multiply) zgodny z ES2; brak niestandardowych trybów psujących batching.
    - Kolor: Transformacje (tint, alpha) nakładane jako uniformy lub per-vertex kolor w buforze, nie przez dodatkowe passy.
  - Skutki: Bardziej przewidywalny i szybki rendering, prostsze debugowanie.
  - Wskazówki: Dodając nowy typ rysunku, zadbać o poprawny hash i unikać wprowadzania nowych trybów kompozycji bez realnej potrzeby.

  3.75 Grafika: czas i animacje — `Timing`, `Animator`
  - Upstream vs Redemption: Redemption centralizuje czas w `g_clock` i wprowadza lekkie animatory operujące na uniformach/UV bez przebudowy geometrii.
  - Pliki: `testyy/src/framework/graphics/animator.h/.cpp`, `timing.h/.cpp`.
  - Różnice:
    - Uniform time: Shadery otrzymują jednolite źródło czasu do efektów (falowanie, pulsowanie), co zmniejsza koszt CPU.
    - UV anim: Płynne przesunięcia UV dla efektów (np. woda) bez dodawania nowych verteksów.
  - Skutki: Niskokosztowe animacje spójne w całym pipeline.
  - Wskazówki: Unikać reimplementacji zegarów; używać animatorów bazujących na uniformach.

# Ogólny opis modyfikacji

Ten dokument opisuje główne różnice między tym repozytorium a oryginalnymi projektami:
- serwer Canary z repozytorium `opentibiabr/canary`
- klient otclient z modyfikacjami TTF/i18n (repozytorium bazowe + własne zmiany)

## 1. Zakres projektu

- Serwer: oparty na Canary 14.x, z własnymi poprawkami i konfiguracją.
- Klient: otclient z obsługą TTF i internacjonalizacją (i18n), trzymany w katalogu `testyy/`.
- Dane: dostosowane dane świata / zasobów, częściowo pochodzące z otservbr-global i/lub innych źródeł.

## 2. Kluczowe różnice względem oryginalnego Canary

### 2.1. `CMakeLists.txt` – konfiguracja kompilacji

Porównanie:
- oryginał: `oryginall/canary-serwer/CMakeLists.txt`
- nasz projekt: `CMakeLists.txt`

Zakres zmian:
- logika konfiguracji VCPKG i minimalnej wersji CMake jest zachowana funkcjonalnie taka sama,
  ale nasz plik jest uproszczony i czytelniej skomentowany pod nasze użycie.
- konfiguracja flag kompilatora dla CPU została uproszczona (brak rozgałęzienia na x86_64/ARM),
  ponieważ skupiamy się na architekturze x86-64.
- sposób obsługi testów różni się: my korzystamy z prostych opcji `BUILD_TESTS` i
  ewentualnie `PACKAGE_TESTS`, a oryginał używa mechanizmu `CTest` i zmiennej `BUILD_TESTING`.

Szczegóły różnic:

1. **Nagłówek i sekcja VCPKG**
   - U nas:
     - krótki komentarz opisujący użycie VCPKG pod Linuxa/Windows,
     - ustawienie `CMAKE_TOOLCHAIN_FILE` na podstawie zmiennej środowiskowej `VCPKG_ROOT`,
     - ustawienie `VCPKG_TARGET_TRIPLET` na podstawie `VCPKG_DEFAULT_TRIPLET`,
     - jawne `set(VCPKG_FEATURE_FLAGS "versions")` i `set(VCPKG_BUILD_TYPE "release")`,
       oraz `set(CMAKE_EXPORT_COMPILE_COMMANDS ON)` w jednej, zwartej sekcji.
   - W oryginale:
     - te same zmienne są ustawiane, ale z mocno rozbitym formatowaniem CMake (każdy argument
       w osobnej linii),
     - komentarze są bardziej ogólne i zorientowane na główny projekt Canary.
   - **Cel zmiany:** poprawa czytelności dla nas i dopasowanie komentarzy do naszego procesu
     (w tym buildów na GitHub Actions i lokalnie z vcpkg).

2. **Flagi kompilatora i obsługa architektur**
   - U nas:
     - dla `NOT MSVC` ustawiamy globalnie:
       - `-march=x86-64 -mtune=generic -mno-avx -mno-sse4` dla C i C++.
     - nie rozróżniamy architektury CPU – zakładamy x86-64.
   - W oryginale:
     - logika jest bardziej rozbudowana:
       - dla `x86_64|AMD64` ustawiane są dokładnie te same flagi,
       - dla `arm64|aarch64` są dodatkowe gałęzie:
         - osobne ustawienia dla macOS/APPLE (`-mcpu=apple-a14`),
         - osobne, generyczne flagi ARM64 (`-march=armv8-a -mtune=generic`).
   - **Cel naszej wersji:** uproszczenie pod dominującą platformę x86-64 (głównie Windows/Linux
     na serwer), bez oficjalnego wsparcia ARM64 z poziomu tego pliku. To ułatwia debugowanie,
     ale oznacza, że dla ARM64 trzeba będzie kiedyś przywrócić lub przenieść logikę z oryginału.

3. **Projekt i moduły CMake**
   - Logika `project(canary / canary-debug)` w zależności od `CMAKE_BUILD_TYPE` jest spójna
     z oryginałem – zachowujemy dwie nazwy targetów w zależności od trybu.
   - Ścieżka do modułów:
     - oba pliki dodają `${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules` do `CMAKE_MODULE_PATH`.
   - **Cel:** tutaj nie zmienialiśmy zachowania, jedynie formatowanie i drobne komentarze.

4. **Opcje `ccache`, `sccache`, LTO i metrics**
   - Zarówno u nas, jak i w oryginale istnieją te same opcje:
     - `OPTIONS_ENABLE_CCACHE`, `OPTIONS_ENABLE_SCCACHE`, `OPTIONS_ENABLE_IPO`, `FEATURE_METRICS`.
   - Różnice są kosmetyczne (formatowanie CMake, sposób zapisu `set(...)`),
     logika włączania/wyłączania ccachy/sccachy jest identyczna.
   - **Cel:** zachowanie pełnej zgodności z oryginalnym Canary w tej części.

5. **Obsługa testów**
   - U nas:
     - wprowadziliśmy własne opcje:
       - `option(BUILD_TESTS "Build tests" OFF)` – czy w ogóle budować testy,
       - `option(RUN_TESTS_AFTER_BUILD "Run tests when building" OFF)` – czy uruchamiać
         testy automatycznie po buildzie (przyszłościowo, do integracji z CI).
     - logika na końcu pliku:
       - `if(BUILD_TESTS OR PACKAGE_TESTS) add_subdirectory(tests) endif()`.
   - W oryginale:
     - używane jest standardowe CTest:
       - `include(CTest)`;
       - jeśli `BUILD_TESTING` jest włączone:
         - logowanie opcji "tests",
         - `add_subdirectory(tests)` i `enable_testing()`.
   - **Cel naszych zmian:** uproszczenie sterowania testami pod nasze potrzeby
     i podział na "buduj" vs "uruchamiaj po buildzie". To jest baza do późniejszej integracji
     z workflow GitHub Actions, gdzie możemy łatwo kontrolować, czy testy mają się
     budować/uruchamiać.

6. **Podsumowanie wpływu zmian w `CMakeLists.txt`**
   - build serwera pozostaje zgodny z oryginałem pod względem wymaganych bibliotek (vcpkg),
     ale jest mocniej nastawiony na x86-64 i nasze środowisko (Linux + Windows statyczny).
   - testy są pod większą kontrolą przez nasze opcje `BUILD_TESTS`/`RUN_TESTS_AFTER_BUILD`,
     zamiast domyślnego `BUILD_TESTING` z CTest.
   - uproszczone formatowanie i komentarze mają ułatwić pracę osobom, które znają projekt
     Ptaku/otclient, ale niekoniecznie cały ekosystem Canary.

### 2.2. `CMakePresets.json` – presety budowania

Porównanie:
- oryginał: `oryginall/canary-serwer/CMakePresets.json`
- nasz projekt: `CMakePresets.json`

Najważniejsze różnice:

1. **Minimalna wersja CMake**
   - u nas: `cmakeMinimumRequired` = 3.22.0,
   - w oryginale: 3.24.0.
   - **Efekt:** świadomie trzymamy się niższej wersji, żeby dało się budować na systemach
     z nieco starszym CMake, kosztem rezygnacji z kilku najnowszych ficzerów presetów.

2. **Preset `base`**
   - u nas w `cacheVariables`:
     - `CMAKE_TOOLCHAIN_FILE`, `BUILD_STATIC_LIBRARY`, `SPEED_UP_BUILD_UNITY`,
       `OPTIONS_ENABLE_SCCACHE`, `CMAKE_BUILD_TYPE` = `RelWithDebInfo`.
   - w oryginale dodatkowo:
     - `CMAKE_COLOR_DIAGNOSTICS` = `ON`,
     - `BUILD_TESTING` = `OFF`.
   - **Cel różnicy:** uproszczenie – nie sterujemy tutaj globalnie `BUILD_TESTING`, bo testami
     zarządzamy własnymi opcjami (`BUILD_TESTS`), a kolorowe diagnostyki CMake nie są dla nas krytyczne.

3. **Presety Windows** (`windows-release`, `windows-release-asan`, `windows-debug`)
   - układ presetów jest bardzo zbliżony:
     - te same nazwy, dziedziczenie po `base`, użycie `VCPKG_TARGET_TRIPLET` (`x64-windows-static`
       oraz `x64-windows` w trybach bez statycznej biblioteki),
     - `ASAN_ENABLED`, `DEBUG_LOG`, `BUILD_STATIC_LIBRARY`, `SPEED_UP_BUILD_UNITY`.
   - różnica: oryginał dodatkowo ustawia `BUILD_TESTING` (ON/OFF) dla tych presetów, my – nie.
   - **Efekt:** nasze presety Windows skupiają się na tym, żeby build przechodził na GitHub Actions
     i lokalnie, bez automatycznego włączania testów – to zostawiamy logice w `CMakeLists.txt`.

4. **Presety Linux** (`linux-release`, `linux-debug`, `linux-debug-asan`, `linux-test`)
   - u nas:
     - `linux-release` odziedzicza z `base` i ma warunek `hostSystemName == Linux`,
     - `linux-debug`, `linux-debug-asan` ustawiają odpowiednio `CMAKE_BUILD_TYPE`, `DEBUG_LOG`,
       `ASAN_ENABLED`, `SPEED_UP_BUILD_UNITY`,
     - `linux-test` ustawia `BUILD_TESTS = ON` – to jest kluczowy preset do budowania testów
       w CI albo lokalnie.
   - w oryginale:
     - zamiast `BUILD_TESTS` używany jest `BUILD_TESTING`,
     - brak naszego precyzyjnego podziału na "linux-test" (my dodatkowo zaznaczamy, że chodzi
       o build testów).
   - **Cel:** spójność z naszym podejściem z `CMakeLists.txt` (własne flagi testów) i jasny
     preset do "builduj serwer + testy".

5. **Presety macOS i testPresets**
   - w oryginale są presetów `macos-release` / `macos-debug` oraz sekcja `testPresets` dla
     Windows/Linux/macOS.
   - u nas **brak** presetów dla macOS i brak sekcji `testPresets`.
   - **Efekt:** oficjalnie nie wspieramy/nie konfigurujemy macOS w tym repo, a testy
     uruchamiamy (jeśli potrzeba) ręcznie lub przez własne zadania CI.

Podsumowanie: nasze `CMakePresets.json` jest uproszczone i skupione na Linux + Windows z vcpkg,
ze specjalnym presetem `linux-test` do budowy testów. Rezygnujemy z części ogólnej logiki
`BUILD_TESTING` i wsparcia macOS z oryginału.

### 2.3. `config.lua.dist` – konfiguracja serwera

Porównanie:
- oryginał: `oryginall/canary-serwer/config.lua.dist`
- nasz projekt: `config.lua.dist`

Na podstawie porównania (pierwsze ~400 linii) widać, że:
- struktura pliku jest **identyczna** – te same sekcje (core/combat/connection/prey/forge itd.),
- wszystkie wartości domyślne (np. `dataPackDirectory`, `worldType`, limity depotów, ustawienia
  systemów jak Forge, Prey, Task Hunting, Wheel, Hazard, itp.) są takie same jak w oryginale.

Wnioski:
- `config.lua.dist` w naszym repozytorium **nie jest modyfikowaną kopią**, tylko wiernym
  przeniesieniem wersji z oryginalnego Canary,
- wszystkie nasze zmiany konfiguracji wchodzą do **`config.lua`** (użytkownikowa kopia),
  podczas gdy `.dist` pozostaje referencją do wartości upstream.

Znaczenie dla dokumentacji:
- w tym pliku nie opisujemy różnic funkcjonalnych względem oryginału,
- ważne jest natomiast rozróżnienie ról:
  - `config.lua.dist` – domyślna, upstreamowa konfiguracja (nie zmieniamy),
  - `config.lua` – nasza lokalna konfiguracja serwera (opisujemy w osobnej sekcji,
    jeśli pojawią się tam istotne modyfikacje).

### 2.4. `README.md` – opis projektu serwera

Porównanie:
- oryginał: `oryginall/canary-serwer/README.md` – oficjalny opis projektu "OpenTibiaBR - Canary",
  z odznakami GitHub Actions, linkami do Gitbooka, Wiki, Discorda, sponsorów, partnerów itd.
- nasz `README.md` – (tutaj uzupełnij po przejrzeniu swojego pliku, np. różnice w opisie,
  linkach do Twojego forka, wzmiankach o `testyy/` i kliencie TTF/i18n).

Docelowo w tej sekcji powinniśmy opisać:
- czy Twój `README`:
  - zachowuje oryginalny opis projektu,
  - dodaje informacje o Twoich modyfikacjach (np. integracja z otclientem w `testyy/`),
  - zmienia linki (np. do Twojego repo/forków, własnego Discorda).
- jakie jest **przeznaczenie** Twojego forka względem upstreamu (np. testowe środowisko TTF/i18n,
  build Windows, konkretne ustawienia datapacka).

Przykładowe kategorie różnic (poza wymienionymi plikami):
- konfiguracja builda (Windows / Linux, użycie vcpkg, presety CMake)
- integracja z danymi `data-otservbr-global` / `data-canary`
- dodatkowe skrypty narzędziowe (np. `recompile.sh`, skrypty debugowe)

## 3. Kluczowe różnice względem oryginalnego otclienta

### 3.1. Struktura projektu klienta (`testyy/` vs `oryginall/otclient`)

Porównanie katalogów głównych:
- oryginał: `oryginall/otclient` – czysty `otclientv8` z repozytorium `opentibiabr/otcv8`,
  z podstawową strukturą (`src/`, `modules/`, `data/`, `cmake/`, `android/`, `vc17/`, `vcpkg.json`, `CMakeLists.txt`, `README.md` itd.).
- nasz klient: `testyy/` – projekt oparty na forku "OTClient - Redemption" (repozytorium `mehah/otclient`),
  zawierający dodatkowe pliki z prac nad TTF/i18n i organizacją pracy (np. `I18N_Progress.md`, `I18N_Next_Steps.md`,
  `WszystkieSRCLOG.md`, `plan.md`, `worklog_all.md`, `wykonane_zadania.md`, `errory-actions.md`, `analiza copilota.md`).

Najważniejsze konsekwencje:
- **kod źródłowy klienta** jest bliższy "OTClient Redemption" niż oryginalnemu `otclientv8` od `opentibiabr`,
  ale wciąż kompatybilny z serwerem Canary (obsługa protokołów, marketu itd. jest zachowana),
- `testyy/` pełni rolę **laboratorium** do eksperymentów z TTF/i18n oraz integracją z Twoim serwerem,
  dlatego pojawia się wiele plików `.md` i logów, których nie ma w upstreamach.

### 3.2. `CMakeLists.txt` klienta – integracja "text stack" (TTF/HarfBuzz/FriBidi)

Porównanie:
- oryginał: `oryginall/otclient/CMakeLists.txt`
- nasz klient: `testyy/CMakeLists.txt`

Zakres zmian:
- w oryginalnym `otclientv8` plik `CMakeLists.txt` kończy się po dodaniu katalogu `src/`:
  ```cmake
  # *****************************************************************************
  # Add project
  # *****************************************************************************

  # Src
  add_subdirectory(src)
  ```
- w `testyy/CMakeLists.txt` zachowujesz całą oryginalną konfigurację (VCPKG, `OPTIONS_ENABLE_CCACHE`,
  `OPTIONS_ENABLE_SCCACHE`, `OPTIONS_ENABLE_IPO` itd.), ale **dodajesz nowy blok** odpowiedzialny
  za "text stack" – integrację TTF/HarfBuzz/FriBidi:
  - definicje opcji:
    - `OTC_ENABLE_TTF` – włączenie renderowania tekstu przez FreeType,
    - `OTC_ENABLE_HARFBUZZ` – włączenie kształtowania tekstu przez HarfBuzz,
    - `OTC_ENABLE_FRIBIDI` – włączenie obsługi kierunków RTL przez FriBidi,
  - utworzenie interfejsowego targetu `otc_textstack` (biblioteka INTERFACE),
  - `find_package(...)` i `pkg_check_modules(...)` dla Freetype, HarfBuzz i FriBidi,
    z priorytetem dla pakietów z vcpkg (`CONFIG`),
  - dodanie odpowiednich `target_link_libraries` i `target_compile_definitions`.

Cel zmian:
- zapewnić **spójną warstwę tekstową** dla i18n, działającą zarówno na systemach z vcpkg,
  jak i z bibliotekami zainstalowanymi systemowo (fallback przez pkg-config),
- wprowadzić czytelną, przełączalną konfigurację (flagi `OTC_ENABLE_*`), którą można sterować
  w razie potrzeby z poziomu presetów CMake albo IDE,
- zachować prostotę – cały "text stack" jest zebrany w jednym miejscu (INTERFACE target),
  a reszta projektu tylko dołącza ten target.

Wpływ na build:
- budowanie klienta wymaga teraz obecności bibliotek FreeType, HarfBuzz i FriBidi (lub wyłączenia
  odpowiednich opcji `OTC_ENABLE_*`),
- w środowisku z vcpkg konfiguracja jest względnie prosta – wystarczy zainstalować odpowiednie
  porty i wskazać `VCPKG_ROOT`,
- dzięki INTERFACE targetowi późniejsze moduły (np. `src/` i `modules/`) nie muszą znać szczegółów
  linkowania – wystarczy, że linkują się do `otc_textstack`.

### 3.3. `README.md` klienta – źródło i cel projektu

Porównanie:
- oryginał: `oryginall/otclient/README.md` – opisuje projekt **OTClientV8** od `opentibiabr`:
  - klasyczne nagłówki: "What is otclient?", lista funkcji (nowy renderer, pathfinding, shop, layouts itd.),
  - wsparcie platform (Windows, Android, Linux, MacOS przez XQuartz),
  - link do Gitbooka i oficjalnego Discorda,
  - standardowe sekcje "Issues", "Pull requests", "Credits", "License".
- nasz `testyy/README.md` – jest praktycznie **README od projektu "OTClient - Redemption"** (`mehah/otclient`):
  - tytuł: "OTClient - Redemption" z ikoną klienta,
  - rozbudowana lista funkcji engine/UI (multi-threading, async texture loading, attached effects, HTML/CSS w UI,
    latency-adaptive camera, obsługa DirectX, protokołów 12.85–13.40 itd.),
  - linki i badge do workflowów z repozytorium `mehah/otclient`,
  - szczegółowe opisy systemów graficznych i UI w formie sekcji `details` ze zrzutami ekranu i GIF-ami.

Wnioski i znaczenie dokumentacyjne:
- **bazowy klient** to nie klasyczny `otclientv8`, tylko forkująca gałąź "Redemption" z własnym zestawem ficzerów,
  zoptymalizowanym rendererem i rozbudowanym UI,
- Twoje prace nad TTF/i18n budujesz **na tej bazie**, więc dokumentując klienta, należy pamiętać, że:
  - część funkcji (multi-threading, asynchroniczne ładowanie tekstur, zaawansowany UI) pochodzi bezpośrednio
    z "Redemption" i nie jest Twoją modyfikacją,
  - Twoje kluczowe zmiany dotyczą warstwy tekstowej (TTF + shaping + bidi) i integracji i18n,
    a nie całości engine.

Szczegółowy postęp i plany dotyczące i18n:
- patrz `../testyy/I18N_Progress.md` oraz `../testyy/I18N_Next_Steps.md`.

### 3.4. `vcpkg.json` – zestaw zależności klienta

Porównanie:
- oryginał: `oryginall/otclient/vcpkg.json` (`name`: `otcv8`)
- nasz klient: `testyy/vcpkg.json` (`name`: `otclient`)

Najważniejsze różnice w zależnościach:
- w `otcv8` dominują klasyczne biblioteki dla klienta Tibii:
  - `asio`, `bzip2`, `luajit`, `glew`, `pugixml`, `physfs`, `openal-soft`, `openssl`,
    `libogg`, `libvorbis`, `liblzma`, `zlib`, `libzip`, `stduuid`, `angle`, `directxsdk`,
  - brak bezpośrednich zależności zorientowanych na zaawansowaną obsługę tekstu / i18n.
- w `testyy/vcpkg.json` lista jest znacznie rozszerzona i dostosowana do "Redemption" + TTF/i18n:
  - klasyczne elementy: `asio`, `luajit`, `glew`, `physfs`, `openal-soft`, `openssl`,
    `libogg`, `libvorbis`, `liblzma`, `zlib`, `stduuid`,
  - **nowe biblioteki ogólne**: `abseil`, `fmt`, `cpp-httplib`, `nlohmann-json`,
    `parallel-hashmap`, `bshoshany-thread-pool`, `discord-rpc`, `pugixml`, `protobuf`,
  - **biblioteki tekstowe i i18n**: `harfbuzz`, `freetype`, `fribidi`,
  - platformowe: `angle`, `opengl`, `glew` (Windows/Linux/macOS), `pkgconf` jako zależność hosta.

Znaczenie dla projektu:
- zestaw zależności odzwierciedla przejście z klasycznego klienta na bardziej rozbudowaną
  bazę "Redemption" z nowym rendererem i systemem tekstowym,
- dodane biblioteki (w szczególności `harfbuzz`, `freetype`, `fribidi`) są bezpośrednio
  powiązane z blokiem "text stack" w `CMakeLists.txt` i umożliwiają poprawne renderowanie
  tekstu w wielu językach (w tym skryptach złożonych i RTL).

### 3.5. `init.lua` – start klienta i ładowanie modułów

Porównanie:
- oryginał: `oryginall/otclient/init.lua` – skoncentrowany wokół:
  - stałych `APP_NAME`, `APP_VERSION`, `DEFAULT_LAYOUT`,
  - tablicy `Services` (website/updater/stats/crash/feedback/status),
  - prostego `Servers` z przykładową konfiguracją `LocalTestServ`,
  - ustawiania layoutu (`retro`/`mobile` itp.) i ładowania modułów (`corelib`, `gamelib`, `client`,
    `game_interface`),
  - opcjonalnego modułu `crash_reporter` i integracji z updaterem,
  - wymaga istnienia katalogów `/data` i `/modules`.
- nasz klient: `testyy/init.lua` – plik jest dostosowany do "Redemption" i Twojego środowiska:
  - `Services` zawiera tylko zakomentowane przykłady URL-i (updater/status/websites/createAccount),
  - brak globalnych stałych `APP_NAME`/`APP_VERSION`; zamiast tego od razu ustawiasz:
    - `g_app.setName("OTClient - Redemption")`,
    - `g_app.setCompactName("otclient")`,
    - `g_app.setOrganizationName("otcr")`,
  - definiujesz funkcję `g_app.hasUpdater()` opartą o `Services.updater` i dostępność modułu `updater`,
  - dodajesz obsługę zdalnego debuggera Lua (VSCode `LOCAL_LUA_DEBUGGER_VSCODE`),
  - ścieżki danych/modules/mods są oparte o `g_resources.getWorkDir()` i nazwę aplikacji,
  - konfiguracja użytkownika trafia do katalogu zapisywalnego (`setupUserWriteDir` z `g_app.getCompactName()`),
  - proces ładowania modułów jest rozbity na dwie fazy (`discoverModules` + `autoLoadModules`
    w kilku zakresach oraz `ensureModuleLoaded` dla kluczowych modułów jak `corelib`, `gamelib`,
    `modulelib`, `startup`, `game_shaders`, `client`, `game_interface`, `client_mods`).

Różnice funkcjonalne:
- oryginał mocno eksponuje **ustawienia layoutu i konfigurację serwerów/updatera** (w tym HTTP/WS),
  Twój `init.lua` jest bardziej skoncentrowany na:
  - logowaniu startu klienta (OS, wersja, commit, data, architektura),
  - debugowaniu (integracja z VSCode Lua debugger),
  - uporządkowanym ładowaniu modułów i shaderów,
  - elastycznym dodawaniu katalogów (`data`, `modules`, `mods`) do ścieżki zasobów.

Znaczenie dla TTF/i18n:
- choć sam `init.lua` nie dotyka bezpośrednio i18n, jest **punktem wejścia**, który zapewnia,
  że potrzebne moduły (np. odpowiedzialne za UI/teksty) zostaną załadowane w odpowiedniej kolejności,
  a konfiguracja katalogów i pakietów (`.otpkg`) pozwoli na odczyt plików fontów i zasobów językowych.

### 3.6. `src/main.cpp` – uruchamianie klienta

Porównanie:
- oryginał: `oryginall/otclient/src/main.cpp`
  - prosty `main()` ustawiający nazwę "OTClientV8", wersję "3.2" i katalog zapisu,
  - obsługa `--encrypt` (przez `WITH_ENCRYPTION`) i `--test`,
  - inicjalizacja `g_app`, `g_client`, `g_http`, ładowanie `init.lua`, opcjonalne `test.lua`,
  - Windows ładuje `progdn32.dll`, Android ma własną `android_main` z obsługą `ANativeActivity`.
- nasz klient: `testyy/src/main.cpp`
  - zaktualizowane copyrighty (2010–2025) i większy zestaw nagłówków (`client/game.h`,
    `client/gameconfig.h`, `client/localplayer.h`, `framework/discord/discord.h`, `framework/net/protocolhttp.h`),
  - wsparcie Androida przez `g_androidManager.unZipAssetData()` i `g_resources.init(nullptr)`,
  - rozbudowana logika szyfrowania (`ENABLE_ENCRYPTION`, `ENABLE_ENCRYPTION_BUILDER`) – po switchu `--encrypt`
    uruchamia `g_resources.runEncryption` na hasle zadanym argumentem lub makrem,
  - dynamiczne wykrywanie `init.lua` poprzez `g_resources.discoverWorkDir("init.lua")`,
  - inicjalizacja `g_app` z `GraphicalApplicationContext(g_gameConfig.getSpriteSize(), ApplicationDrawEventsPtr(&g_client))`
    – kontekst grafiki powiązany z konfiguracją sprite'ów i zdarzeniami rysowania,
  - integracja z Discord RPC (jeśli `ENABLE_DISCORD_RPC`): lambdy `canUpdate` / `onUpdate`
    z opcjami `SHOW_CHARACTER_*`, wykorzystujące `g_game` i `g_game.getLocalPlayer()`,
  - warunkowe inicjalizowanie `g_http` (`FRAMEWORK_NET`),
  - brak `test.lua`, brak `progdn32.dll`, uproszczone zakończenie (ale zachowana sekwencja `g_client.terminate()`, `g_app.terminate()`, `g_http.terminate()`).

Znaczenie zmian:
- `main.cpp` w "Redemption" jest **mocniej zintegrowany** z systemami klienta (Discord RPC, HTTP, konfiguracja sprite'ów),
  podczas gdy `otcv8` jest bardziej ogólny.
- Dla projektów TTF/i18n ważne jest, że już w `main.cpp` pojawia się `GraphicalApplicationContext`
  z odpowiednim rozmiarem sprite'ów – to wpływa na sposób renderowania tekstu/GUI.

### 3.7. `src/client/statictext.cpp` – rysowanie tekstów nad postaciami

Porównanie:
- oryginał (`oryginall/otclient/src/client/statictext.cpp`):
  - posługuje się stałymi `Otc::STATIC_DURATION_PER_CHARACTER` i `Otc::MIN_STATIC_TEXT_DURATION`,
    przechowuje wiadomości jako wektory naprzemiennych fragmentów tekst/kolor,
  - korzysta z `m_cachedText.setColoredText(...)` i zakłada stałą czcionkę `verdana-11px-rounded`,
  - prosty `Rect boundRect = rect; boundRect.bind(parentRect);` – brak skalowania pod DPI,
  - usuwanie tekstu wywołuje `g_map.removeThing(self)`.
- nasz klient (`testyy/src/client/statictext.cpp`):
  - używa `g_gameConfig` do pobrania czcionki i parametrów czasu (`getStaticTextFont()`, `getStaticDurationPerCharacter()`, `getMinStatictextDuration()`),
  - modyfikuje pozycjonowanie tekstu o `g_app.getStaticTextScale()` i uwzględnia `PlatformWindow::DEFAULT_DISPLAY_DENSITY`,
  - upraszcza strukturę wiadomości do `std::deque<std::pair<std::string, ticks>>` – brak kolorowania fragmentów, kolor wybierany globalnie,
  - planowanie czyszczenia wykorzystuje `g_textDispatcher.addEvent([self] { g_map.removeStaticText(self); });`,
  - zawiera dodatkowe optymalizacje (`if (g_app.mustOptimize()) delay /= 2;`) oraz `m_cachedText.wrapText(275)` na końcu.

Wpływ na TTF/i18n:
- tekst statyczny korzysta z fontu skonfigurowanego w `gameconfig` (który z kolei wskazuje na nowe TTF-y),
  dzięki czemu np. znaki diakrytyczne lub skrypty dwukierunkowe mogą używać tej samej logiki co UI,
- blok `m_cachedText` korzysta pośrednio z "text stack" (Freetype/HarfBuzz/FriBidi), więc uproszczone przechowywanie
  tekstu (bez kolorów per fragment) ułatwia renderowanie wielojęzyczne i ewentualne shapingi.

### 3.8. `src/framework/graphics/fontmanager.cpp` – zarządzanie czcionkami

Porównanie:
- oryginał: `oryginall/otclient/src/framework/graphics/fontmanager.cpp`
  - inicjuje „pusty” font (`BitmapFont("emptyfont")`) i w razie potrzeby przełącza się na niego,
  - `importFont` działa asynchronicznie: jeżeli wywołanie nie nastąpiło z wątku graficznego, przekłada operację na `g_graphicsDispatcher`,
  - brak rozróżnienia na domyślny font widgetów vs ogólny, brak API zwracającego informację o sukcesie/próbie,
  - `clearFonts()` zawsze tworzy nowy `emptyfont`.
- nasz klient: `testyy/src/framework/graphics/fontmanager.cpp`
  - uproszczone zarządzanie – brak przełączania wątków, `importFont` zwraca `bool` i zgłasza błędy przez logger,
  - przechowuje osobno `m_defaultFont` oraz `m_defaultWidgetFont`, z możliwością ustawienia ich flagami `default` / `widget-default` w pliku `.otfont`,
  - korzysta z `std::shared_ptr<BitmapFont>` i usuwa istniejące fonty o tej samej nazwie przed dodaniem nowego,
  - `clearFonts()` czyści kontener i resetuje wszystkie wskaźniki (bez „emptyfont”).

Wpływ na TTF/i18n:
- możliwość wskazania osobnych domyślnych fontów dla UI i widżetów upraszcza kontrolę nad wyborem TTF-ów (np. interfejs może używać pełnej czcionki Unicode, a mniejsze widżety – lekkiej wersji),
- brak wymogu obsługi wielu wątków w `importFont` jest możliwy dzięki jednemu, dobrze zdefiniowanemu miejscu ładowania fontów – to z kolei ułatwia integrację z dynamicznie ładowanymi plikami `.otfont` opisującymi TTF-y.

### 3.9. `src/framework/graphics/cachedtext.cpp` – renderowanie tekstów (bitmapowe vs TTF)

Porównanie:
- oryginał (`oryginall/otclient/.../cachedtext.cpp`):
  - opiera się w całości na `BitmapFont` – `drawText`/`drawColoredText`, tablica kolorów (`m_textColors`) i flagi rekalkulacji (`m_textMustRecache`),
  - brak wsparcia dla TTF/HarfBuzz, brak wiedzy o wyrównaniu pionowym/poziomym w czasie rzeczywistym,
  - `wrapText` deleguje do bitmapowej implementacji, z opcjonalnym przekazywaniem kolorów.
- nasz klient (`testyy/.../cachedtext.cpp`):
  - rozróżnia dwa tryby: klasyczne bitmapy oraz nowy tryb TTF (`m_font->isTTF()`),
  - dla TTF używa dedykowanych struktur (`GlyphQuad`, `CachedGlyph`, `m_ttfGlyphs`, `m_ttfBatches`) oraz klas z `framework/text` (`TextShaper`, `LocaleShaping`, `Utf8`),
  - potrafi dzielić glify na paczki per teksturę (`CoordBuffer` per atlas) i docinać je do aktualnego prostokąta rysowania,
  - wyrównanie (`AlignBottom`, `AlignHorizontalCenter`, itd.) jest liczone ręcznie, by poprawnie przesuwać TTF-y w ramce,
  - `wrapText` najpierw przepuszcza treść przez `font->wrapText`, a potem od razu `update()` przebudowujący glify TTF.

Znaczenie dla i18n:
- `CachedText` stał się pomostem między logiką UI/Lua a HarfBuzz/FriBidi: potrafi konwertować UTF-8 → UTF-32, pobrać parametry językowe (`LocaleShaping`) i wygenerować dokładne kwady w `TTFFont`,
- renderowanie wielojęzycznych UI/stylingu jest teraz możliwe bez ręcznego dzielenia tekstu na segmenty kolorów/ASCII, co było sporym ograniczeniem w `otcv8`.

### 3.10. `src/framework/text/*` – nowy stos TTF/HarfBuzz/FriBidi

- W `oryginall/otclient` nie ma katalogu `framework/text` – całe renderowanie opiera się na bitmapowych czcionkach (`BitmapFont`).
- W `testyy/` pojawił się kompletny podsystem tekstowy:
  - `TTFFont` – zarządza FreeType, atlasami 2048×2048, batchingiem glifów i renderowaniem przez `CoordsBuffer`/`g_drawPool`;
  - `TextShaper` – opakowanie na HarfBuzz, buduje listę `ShapedGlyph` z przesunięciami/advances;
  - `LocaleShaping` – ustala parametry językowe (np. kierunek pisma, wybór fallback fontów) na podstawie ciągu UTF-8;
  - `Utf8.h` – helpery do konwersji UTF-8 ↔ UTF-32.

Znaczenie:
- te pliki są fundamentem dla wszystkich sekcji 3.6–3.9 – `main.cpp` inicjuje środowisko, `fontmanager` ładuje `.otfont` wskazujące na pliki TTF, `cachedtext` i `statictext` renderują teksty, a `LocaleShaping` gwarantuje poprawny kierunek i ligatury.
- Dzięki temu klient obsługuje **pełne Unicode** (w tym języki RTL i skrypty z ligaturami), co było jednym z głównych celów Ptaka (TTF + i18n).

### 3.11. `modules/client_locales` – wybór języka i synchronizacja z serwerem

Porównanie modułów `client_locales`:
- oryginał (`oryginall/otclient/modules/client_locales`) zapewnia podstawowy picker języków, zapisywanie ustawień i proste logowanie braków tłumaczeń.
- nasz klient (`testyy/modules/client_locales`):
  - wysyła aktualne ustawienie języka do serwera przez rozszerzony opcode (`ExtendedIds.Locale`) w `ProtocolGame`,
  - reaguje na `onGameStart` i `onExtendedLocales`, dzięki czemu serwer może wymusić zmianę języka (np. gdy gracz wybierze go w UI serwera),
  - udostępnia API `modules.client_locales.openLanguagePicker` dla innych modułów (np. button w topmenu),
  - łączy się z `g_app` (`onRun`/`onUpdateFinished`) by pokazać okno wyboru języka przy pierwszym uruchomieniu lub po aktualizacji,
  - przechowuje listę wymaganych tłumaczeń (`neededTranslations`), loguje brakujące i oferuje helper `generateNewTranslationTable`,
  - ma dodatkowe pliki (`locales_bridge_openLanguagePicker.lua`, `locales1.lua`) pomagające w integracji z UI.

Znaczenie:
- mechanizm tłumaczeń nie jest już tylko kosmetyką UI – klient wymienia informację o języku z serwerem, co pozwala np. serwerowi dostarczać odpowiednie teksty (dialogi NPC, wiadomości systemowe),
- dzięki modułowi topmenu/entergame gracz ma spójne doświadczenie wyboru języka zanim zaloguje się do gry.

### 3.12. `modules/client_topmenu` – przycisk języka i rozszerzony HUD

- `testyy/modules/client_topmenu/topmenu.lua` pochodzi z "Redemption" i zawiera rozbudowany HUD (panele YouTube/Discord, zoom dla urządzeń mobilnych, Keybind API). W ramach prac nad i18n dodany został **dedykowany przycisk językowy**:
  - w `init()` po pobraniu paneli topmenu tworzony jest `languageButton = modules.client_topmenu.addRightToggleButton(...)`,
  - callback przycisku wywołuje `modules.client_locales.openLanguagePicker()` (z fallbackami na `createWindow()` lub globalne `createWindow`),
  - w `terminate()` przycisk jest niszczony podobnie jak inne elementy.
- W `oryginall/otclient/modules/client_topmenu` (otcv8) nie ma takiego przycisku ani integracji z modułem `client_locales` – topmenu ogranicza się do FPS/Ping i podstawowych przycisków gry.

Znaczenie:
- wybór języka stał się częścią głównego HUD-a, co zachęca graczy do zmiany języka „w locie” i natychmiastowego odświeżenia modułów,
- to drobne, ale ważne sprzężenie między i18n w kliencie a doświadczeniem użytkownika.

### 3.13. `src/framework/graphics/bitmapfont.*` – wsparcie typu `ttf`

- klasyczny `otcv8` zakładał, że każdy font to bitmapa (atlas 16×16 glifów) i ładował dane z `texture`/`glyph-size`. Wersja w `testyy/` nadal wspiera bitmapy, ale dodaje **blok typu `ttf`** na początku `BitmapFont::load()`:
  - parser `.otfont` sprawdza `type = "ttf"`, ładuje główne źródło (`source`) oraz listę fallbacków, wywołuje `TTFFont::load()` i ustawia `m_isTTF = true`,
  - dalszy kod rysowania/generowania współrzędnych w `drawText`, `fillTextCoords`, `wrapText` rozgałęzia się na dwa przypadki (TTF vs bitmapa),
  - dla TTF liczone są baseline, wyrównanie i bounding box w `float`, a renderowanie delegowane jest do `TTFFont::drawText()` z parametrami `LocaleShaping`.
- Dzięki temu `.otfont` może wskazywać zarówno klasyczne czcionki (np. `verdana`) jak i nowe TTF-y (np. `NotoSans-Regular.ttf`), a reszta UI nie musi wiedzieć, jaki typ fontu jest aktualnie używany.

### 3.14. `data/fonts` – nowe czcionki TTF i konfiguracje `.otfont`

- katalog `testyy/data/fonts` został rozszerzony względem `otcv8`:
  - dodano podkatalog `ttf/` z realnymi plikami `NotoSans` (Latin, CJK, Arabic) oraz `NotoNaskhArabic`,
  - pojawiły się nowe `.otfont` (np. `NotoSans-12.otfont`, `noto-12.otfont`, `mono-12.otfont`) z `type = "ttf"` i wskazaniem na powyższe pliki,
  - zachowano oryginalne bitmapy Cipsoft/Verdana, więc moduły mogą mieszkać oba typy fontów.
- w `oryginall/otclient/data/fonts` brak jest fizycznych plików TTF – wszystkie `.otfont` wskazują na `.png` z atlasami.

Znaczenie:
- przygotowanie własnych TTF-ów w repo eliminuje zależność graczy od systemowych czcionek i gwarantuje identyczny wygląd UI na każdym systemie,
- to także baza dla tłumaczeń – `NotoSans` pokrywa zdecydowaną większość znaków Unicode, a fallbacki (np. `NotoSansSC` dla chińskiego) można konfigurować w `.otfont`.

### 3.15. Pliki `textstack.patch` / `textstack-fix.patch`

- w katalogu głównym `testyy/` leżą dwa patche, które dokumentują ewolucję integracji TTF:
  - `textstack.patch` – pierwszy blok zmian dodający interfejs `otc_textstack` i opcje `OTC_ENABLE_*`,
  - `textstack-fix.patch` – poprawki po testach (m.in. lepsze fallbacki HarfBuzz/FriBidi, drobne zmiany w `add_library` i `target_compile_definitions`).
- Oryginalny `otclientv8` nie ma analogicznych plików – nie było potrzeby utrzymywania out-of-tree patchy.

Znaczenie:
- zachowałeś historię zmian jako patch, dzięki czemu łatwiej portować te modyfikacje do przyszłych commitów upstreamu albo zaktualizować repo bez utraty kontekstu.

### 3.16. Dokumenty progresu (`I18N_Progress.md`, `I18N_Next_Steps.md`)

- w katalogu `testyy/` znajdują się dwa kluczowe pliki planistyczne, których nie ma w oryginalnym repo:
  - `I18N_Progress.md` – lista wykonanych zadań (MSVC `/utf-8`, szybka ścieżka TTF w `UITextEdit`, preflight vcpkg, fallback baseline) oraz rejestr błędów CI (asyncdispatcher, vcpkg, warnings),
  - `I18N_Next_Steps.md` – roadmapa kolejnych działań z priorytetami (naprawa asyncdispatchera, aktualizacja baseline, batching w `TTFFont`, testy jednostkowe modułu tekstowego, smoke testy UI).
- te dokumenty stanowią **operacyjny plan** i są powiązane z plikami `.md` w katalogu `dokumentacja/` – można je traktować jako źródło prawdy dla sekcji 3.

  ### 3.17. Workflow GitHub Actions (`testyy/.github/workflows`)

  - `testyy/` zawiera dużo szerszy zestaw workflowów niż `opentibiabr/otcv8` (tam tylko Android/Ubuntu/Windows + drobne automatyzacje). Tutaj mamy m.in. `analysis-sonarcloud.yml`, `build-browser.yml`, `build-docker.yml`, `build-linux.yml`, `build-windows-solution.yml`, `tests-lua.yml`, `cron-stale.yml`.
  - Zmiany wprowadzone pod kątem i18n/TTF/CI:
    - kroki `vcpkg install --manifest` i `vcpkg search` w `build-ubuntu.yml` oraz `analysis-sonarcloud.yml` (walidacja manifestu zanim zacznie się budować klient),
    - fallback `builtin-baseline` w workflowach (na wypadek rozjazdu z `vcpkg.json`),
    - dodatkowe pipeline'y (browser/docker) pozwalają testować klienta na WebGL i w kontenerach.
  - Jednocześnie `build-linux.yml` nadal zawiera konfigurację Windows (TODO opisany w `I18N_Next_Steps.md`), więc trzeba go jeszcze zgrać z rzeczywistością – ale sama obecność tych workflowów jest dużą różnicą względem upstreamu.

  ### 3.18. `src/framework/ui/uitextedit.cpp` – edytor tekstu z TTF

  - `UITextEdit` w `testyy/` został gruntownie przerobiony, aby współpracował z nowym stosem TTF:
    - `drawSelf` pozwala na brak tekstury (`m_font->getTexture()`) jeśli font jest TTF i korzysta z `BitmapFont::drawText`, które pod spodem uruchamia `TTFFont`;
    - zaznaczenie i kursor dla TTF liczone są na podstawie szerokości podciągów (`calculateTextRectSize`) i wyrównania, zamiast indeksów glifów jak w wersji bitmapowej;
    - dla bitmap zachowano poprzedni kod (rysowanie `addTexturedCoordsBuffer`, `m_glyphsCoords`), dla TTF – prostokąty i wypełnienia (z racji braku per-glif texture coords);
    - `update()` ma rozgałęzienia: dla TTF nie wywołuje `recacheGlyphs` ani `calculateGlyphsPositions`, tylko liczy bounding box, czyści cache i dostosowuje auto-scroll.
  - W `otcv8` edytor zakładał wyłącznie bitmapowe fonty, dlatego nie potrafił narysować tekstu gdy `getTexture()` było `null` i zawsze opierał selection/cursor na `m_glyphsCoords`.

  Efekt: pola tekstowe (chat, konsola, inputy w UI) renderują znaki Unicode i pozwalają pisać w dowolnym języku, choć dokument `I18N_Next_Steps.md` notuje dalsze TODO (precyzyjne selection oparte na grapheme clusters).

### 3.19. `modules/startup/startup.lua` – konfiguracja okna i UUID

Porównanie:
- upstream `otclientv8` nie dostarcza samodzielnego modułu `startup`; ustawienia okna zapisuje szczątkowo w `init.lua`.
- w `testyy/modules/startup/startup.lua` powstał dedykowany moduł, który:
  1. ustawia minimalne wymiary w zależności od platformy (`1020×644` desktop vs `640×360` mobile) i natychmiast przywraca ostatnio zapamiętany rozmiar/pozycję/max state z `g_settings`;
  2. dba o prawidłowe ustawienie ikony (`/images/clienticon`) i tytułu (`g_app.getName()`) zanim UI zostanie wyrenderowane;
  3. reaguje na `g_app.onExit`, aby zapisać bieżące parametry okna i szybko zamknąć aplikację bez utraty ustawień;
  4. generuje/przechowuje UUID maszyny (`g_crypt.setMachineUUID(...)`), co jest wymagane przez inne moduły przy szyfrowaniu haseł.

Efekt: klient uruchamia się w spójny sposób na wszystkich platformach, a zaszyfrowane dane logowania zawsze używają tego samego identyfikatora urządzenia – rozwiązanie nieobecne w czystym `otclient`.

### 3.20. `modules/client_entergame/entergame.lua` – launcher z integracjami HTTP

- Oryginał (`oryginall/otclient/modules/client_entergame/entergame.lua`) skupia się na walidacji plików `Tibia.dat/.spr`, obsłudze kont CipSoft i prostym zapisie konta/hasła.
- Wersja z `testyy/` jest dużo bardziej rozbudowana:
  1. **UI i ustawienia** – dodatkowe checkboxy `stayLogged`, `rememberEmail`, `httpLogin`, obsługa `Servers_init` (możliwość predefiniowania serwerów i ukrycia pól host/port), dynamiczna nazwa okna („Journey Onwards” dla protokołów >1080) oraz hotkey `Ctrl+G` do szybkiego przełączania postaci.
  2. **Bezpieczny `ServerList`** – konto i hasło są szyfrowane przez `g_crypt` i przypisywane do konkretnego hosta, co pozwala mieć różne poświadczenia dla kilku serwerów; ustawienia `stay logged` i `autologin` są przechowywane w `g_settings`.
  3. **Seria żądań HTTP** – funkcje `postRequests/postEventScheduler/postBoostedCreature` wysyłają `HTTP.post` do adresów z `Services` i przekazują wyniki do innych modułów: `modules.client_topmenu` (Discord/YT/Twitch licznik, bannery), `modules.client_bottommenu` (kalendarz eventów, boosted creature), `modules.client_options` (alerty). Błędy serwisu są logowane przez `reportRequestWarning`.
  4. **Ochrona przed spamem** – przed wysłaniem kolejnego żądania moduł sprawdza `g_game.isOnline()` i `CharacterList.isVisible()`, żeby nie zalewać API przy szybkim reconnect.

Efekt: ekran logowania pełni rolę launchera pokazującego statystyki społeczności, wydarzenia i oferty sklepu zanim gracz wybierze postać – tego w upstreamie nie ma.

### 3.21. `modules/game_textmessage/textmessage.lua` – dedykowana zakładka „Loot”

Różnice względem oryginału:
1. Dodano `MessageSettings.loot` kierujący łupy do osobnej zakładki konsoli „Loot” oraz na ekran (`highCenterLabel`). Teksty są kolorowane przez `ItemsDatabase.setColorLootMessage`, a widoczność można wyłączyć opcją `showLootMessagesOnScreen`.
2. Pojawiły się nowe grupy (`othersStatus`, `statusSmall`) oraz obsługa dodatkowych `MessageModes` (np. `GameHighlight`, `BoostedCreature`, `Transaction`, `OfflineTrainning`), co pozwala lepiej kategoryzować komunikaty.
3. Czas wyświetlania komunikatów na ekranie wydłużono do `max(#text * 50, 4000)` (upstream: 3000 ms).
4. Wszystkie wiadomości, które trafiają do konsoli, przechodzą przez wspólne miejsce – dzięki temu moduł może przesyłać loot równocześnie do `Server Log` i nowej zakładki.

Efekt: gracze łatwo filtrują łupy oraz statusy walki, a kolorowanie wiadomości wykorzystuje `ItemsDatabase`, co wpisuje się w ogólną filozofię i18n (konwertowanie tekstu zanim trafi do UI).

### 3.22. `modules/client_bottommenu/bottommenu.lua` – kalendarz eventów i boosted creature

- Upstream nie zawiera modułu `client_bottommenu`; interfejs kończy się na top-menu.
- Nasze rozwiązanie dostarcza nowy panel na dole ekranu z trzema funkcjami:
  1. **Show-off / Store** – przewija wskazówki lub oferty. Potrafi pobierać grafiki z HTTP i w razie braku serwisu korzysta z lokalnych wpisów `default_info`.
  2. **Kalendarz** – generuje siatkę na dwa lata, renderuje wydarzenia, pozwala przełączać miesiące i pokazuje aktywne/nadchodzące eventy w mini-kartach. Dane wypełnia `EnterGame.postEventScheduler()`.
  3. **Boosted creature/boss** – funkcja `setBoostedCreatureAndBoss` mapuje identyfikatory ras na outfity (`g_things.getRaceData`) i włącza animacje. Jeżeli ID nie istnieje, widget pokazuje placeholder z ikoną znaku zapytania.

Panel jest schludnie spięty z modułem entergame (HTTP endpointy) i pozwala informować graczy o eventach i promocjach jeszcze na ekranie logowania.

### 3.23. `modules/client_topmenu/topmenu.lua` – rozbudowany HUD społecznościowy

Porównanie:
- upstream `otclientv8` rysuje proste top-menu (`TopMenu`), które pokazuje jedynie FPS/ping (jeśli włączone) oraz parę przycisków konfigurowanych przez inne moduły; przyciski są przechwytywane przez `modules.game_buttons`.
- w `testyy/modules/client_topmenu/topmenu.lua` top-menu pełni rolę mini-HUD-u i launchera:
  1. **Nowe panele i widżety** – oddzielne kontenery dla przycisków lewych/prawych, paneli gry i dwóch etykiet statystyk. W wyświetlaczu pojawiają się liczniki (online players, Discord streamers, YouTube viewers/streams) oraz ikony prowadzące do linków `g_platform.openUrl`.
  2. **Integracja społecznościowa** – metody `setDiscordStreams`, `setYoutubeStreams/Viewers`, `setLinkYoutube/Discord` współpracują z modułem entergame (`HTTP.post` do Services) i aktualizują top-menu bez konieczności otwierania klienta.
  3. **Nowe kontrolki UX** – przycisk języka (obok ikon dźwięku) wywołuje `modules.client_locales.openLanguagePicker`, przycisk „Manage Account” kieruje do `Services.websites`, a na urządzeniach mobilnych pojawiają się przyciski `Zoom In/Out` z logiką `hudScale`.
  4. **Ping/FPS overlay** – dla graczy online moduł wstrzykuje widżet `pingFps.otui` do mapy, pokazując graficzne wskaźniki latencji (`/images/ui/*_ping`) i dodatkowy label FPS, jednocześnie zachowując dotychczasowe etykiety tekstowe (widoczne tylko w rozszerzonym widoku).
  5. **Zaawansowane sterowanie** – przyciski dodawane do paneli gry korzystają z `modules.game_mainpanel` (zamiast `game_buttons`) i mają obejścia na sytuację, gdy moduł nie jest jeszcze załadowany (wykorzystujemy `scheduleEvent`).

Efekt: top-menu w naszym kliencie staje się centrum informacji (statystyki społeczności, linki, wybór języka, zoom), co znacząco odbiega od minimalistycznego rozwiązania upstreamu.

### 3.24. `modules/client_options` – kontroler zakładek, keybindy i rozszerzona konfiguracja

- Upstream `client_options` opiera się na prostym `optionsWindow` z kilkoma statycznymi zakładkami, które przechowują wartości w tablicy `defaultOptions`. Każdy toggle ma ręcznie przypisane efekty (np. `setDrawNames`).
- W `testyy/` moduł został całkowicie przepisany: zamiast jednego okna używany jest `Controller` z własnym UI (`options.otui`) oraz strukturą przycisków/kategorii zagnieżdżonych (Controls/Interface/Graphics/Sound/Misc). Najważniejsze różnice:
  1. **Konfiguracja danych** – wszystkie opcje (wraz z akcjami) pochodzą z `data_options.lua`, dzięki czemu można dodawać ustawienia bez zmian w kodzie. `panels` ładowane są z osobnych plików `.otui` pogrupowanych tematycznie (`styles/interface/*`, `styles/graphics/*`).
  2. **Integracja z keybindami** – moduł tworzy kategorie presetów (`panels.keybindsPanel`), wiąże się z `Keybind` API (preset list, auto-switch per postać, rejestracja skrótów do fullscreen, HUD names, ping/fps overlay, audio mute). Przełączanie presetów potrafi automatycznie zaktualizować UI po wejściu do gry.
  3. **Rozbudowane UI** – boczny pasek kategorii/subkategorii wykorzystuje widgety `OptionsCategory` i dynamicznie dodaje/usuwa wpisy przez funkcje `createCategory`, `addButton`, `removeCategory`, itd. Można wstrzykiwać własne panele (`modules.client_options.addButton('Interface', 'HP/MP Circle', optionPanel)`) z innych modułów.
  4. **Topmenu + game_mainpanel** – przyciski Audio/Options/Exit dodawane są do prawego panelu topmenu, natomiast główne wejście do okna opcji trafia też do `modules.game_mainpanel` (funkcja `setupOptionsMainButton`).
  5. **Nowe opcje graficzne/HUD** – comboboxy `crosshair`, `antialiasingMode`, `floorViewMode`, `framesRarity`, `profile` itd. mają większy zakres wartości niż upstream; dodatkowo dostępna jest sekcja „Interface Console” i „HUD” z ustawieniami loot tabów, dodatkowych overlayów czy skalowania HUD.

Efekt: panel opcji jest modularny, rozszerzalny i zintegrowany z systemem keybindów/redemption UI – podczas gdy upstream ma jeden statyczny formularz z kilkudziesięcioma polami.

### 3.25. `modules/game_console/console.lua` – konsola z keybindami, read-only i drag & drop

- W `otclientv8` konsola jest zbliżona do oryginalnej Tibii: zakładki są statyczne, interakcja odbywa się przez kilka skrótów (`Ctrl+O/E/H`), a `toggleChat` jedynie przełącza tryb WASD.
- Nasza wersja (ponad 2400 linii) rozbudowuje moduł o następujące elementy:
  1. **Nowe skróty i API Keybind** – wszystkie akcje (otwieranie kanałów, wysyłanie wiadomości, zmiana zakładki, włączanie czatu) są rejestrowane przez `Keybind.new/bind`, dzięki czemu użytkownik może je przełączać w panelu opcji. Dodatkowo `switchChat` automatycznie zdejmuje i zakłada bindowanie WASD (`modules.game_walk`).
  2. **Tryb read-only / przeciąganie** – dodano `readOnlyButton` oraz `readOnlyPanel`; zakładkę można przeciągnąć na panel aby zamrozić jej zawartość (np. kanał `Server Log`). Przyciski reagują na PPM (konfiguracja), a `consoleTabBar:setDropTarget(...)` obsługuje Drag&Drop.
  3. **Rozszerzone UI** – konsola ładuje się w `modules.game_interface.getBottomPanel()` razem z przyciskami „prev/next channel”, wskaźnikiem czatu i dodatkowymi panelami (`communicationWindow`, `violationsWindow`). Panel reaguje na `onDragEnter/onDragMove`, co pozwala w przyszłości wprowadzić tryb floating.
  4. **Historia, selekcja, clipboard** – zachowano klasyczne funkcje, ale u nas `consolePanel.onKeyPress` działa również dla nowych zakładek, a `consoleBuffer.selection` jest resetowane helperami `clearSelection/selectAll` (potrzebne do mechanizmu drag-readonly).
  5. **Integracja z opcjami** – `consoleToggleChat` jest zsynchronizowany z ustawieniem `wsadWalking`, ma etykiety `Chat On/Off`, reaguje też na hotkeye mobilne i informuje moduł `modules.client_options` o zmianach.

Efekt: konsola w kliencie zachowuje się jak nowoczesny komunikator (drag&drop zakładek, skróty konfigurowalne, wsparcie read-only), co znacząco wykracza poza prosty panel z upstreamu.

### 3.26. `modules/game_interface/gameinterface.lua` – layout wielopanelowy + profile mobilne

- Upstream `game_interface` utrzymuje klasyczny układ (lewy/prawy panel, top bar, kilka akcji) i prosty zestaw hotkeyów. U nas plik został rozbudowany (~1460 linii) aby obsłużyć nowy HUD Redemption:
  1. **Wiele paneli bocznych** – osobno zarządzamy `gameRightPanel`, `gameRightExtraPanel`, `gameLeftPanel`, `gameLeftExtraPanel`. Grupy radiowe `panelsRadioGroup` i przyciski (`leftIncreaseSidePanels`, etc.) pozwalają użytkownikowi dynamicznie chować/pokazywać dodatkowe kolumny i wybierać aktywny panel do dokowania modułów.
  2. **Widoki mobilne** – moduł przechowuje w `mobileConfig` aktualne wymiary joysticka/skrótów i wywołuje `setupViewMode(0/1/2)` aby przełączać się między layoutami (desktop, landscape mobile, portrait). W zależności od platformy zmieniane są marginesy paneli oraz ograniczenia zoomu.
  3. **Integracja z Keybind API** – wszystkie kluczowe akcje (Stop All Actions, Logout, Clear All Texts, zmiana view mode) są rejestrowane w `Keybind`, dzięki czemu gracz może je przekonfigurować. Dodatkowo `showTopMenuButton` na mapie wywołuje `modules.client_topmenu.toggle()` – przydatne w trybach mobilnych, gdzie topmenu jest ukryte.
  4. **Zaawansowana obsługa wyjścia** – obok klasycznych `tryLogout/tryExit` mamy okno `forceExit`, osobny `logOutMainButton`, a przy zamknięciu aplikacji moduł wstrzykuje `onClose = tryExit`. Do tego `limitedZoom` może być zniesiony dla GM i odświeżany po wejściu do gry.
  5. **Integracja z nowymi modułami** – `StatsBar.init()`/`terminate()` obsługują dolny pasek statystyk, `modules.client_background` jest chowany/pokazywany przy wejściu/wyjściu, `modules.game_mainpanel` dostaje dodatkowe przyciski (np. globalny logout). Na mobilu mapPanel marginesy zsynchronizowane są z `modules.game_joystick` i `modules.game_shortcuts`.

Efekt: interfejs gry jest elastyczny (desktop/mobile), wspiera dodatkowe kolumny i panele, oraz używa systemu keybindów – czego nie zapewnia podstawowe UI z `otclientv8`.

### 3.27. `modules/game_inventory/inventory.lua` – podwójny layout, timery i kontrola walki

Porównanie:
- upstream (`oryginall/otclient/modules/game_inventory/inventory.lua`) to klasyczne mini-okno z przyciskiem w topmenu, prostymi przełącznikami walki i statusem (soul/cap + ikony kondycji), bez wsparcia na rzeczy z czasem trwania;
- nasz `testyy/modules/game_inventory/inventory.lua` przepisał moduł na `Controller` dokowany do `modules.game_interface.getMainRightPanel()` i rozdzielił UI na dwa panele (`onPanel` i `offPanel`), między którymi przełączamy się przez `inventoryShrink`/`changeInventorySize()` zapisywane w `g_settings` oraz zsynchronizowane z `modules.game_mainpanel.reloadMainPanelSizes()`.

Najważniejsze zmiany funkcjonalne:
1. **Obsługa czasu trwania i ładunków** – tablica `itemSlotsWithDuration` + zdarzenie `updateSlotsDuration` śledzą timer każdego przedmiotu opartego o `GameThingClock`. Wyświetlanie timerów/ładunków jest sterowane opcją `modules.client_options.getOption('showExpiryInInvetory')`, a same ekrany integrują się z `ItemsDatabase.setCharges/setTier`.
2. **Sterowanie walką a la posture/combat** – zestaw przycisków `stand/follow` i `attack/balanced/defense` pozwala przełączać `g_game.setChaseMode` i `g_game.setFightMode`, jednocześnie blokując aktywne przyciski (`setEnabled(false)`). Dodatkowe haki (`walkEvent`, `combatEvent`) współpracują z opcją `autoChaseOverride` i automatycznie przełączają postawę przy zmianie trybu walki.
3. **PVP i bezpieczeństwo** – radiogrupa `pvpModeRadioGroup` mapuje wszystkie tryby (white dove/hand/yellow/red fist), a `onSetSafeFight` synchronizuje checkboxy na obu panelach, zapisuje stan w `LastCombatControls` i w razie potrzeby anuluje atak (`g_game.cancelAttack()`).
4. **Integracja z pozostałym HUD-em** – moduł dodaje ikonę w topmenu tylko w trybie „extended view” (`extendedView()`), obsługuje przycisk sakiewki (`purseButton`) i udostępnia helpery `getIconsPanelOn/Off()` dla innych modułów, co pozwala na spięcie inventory z nowym `StatsBar`.

Efekt: inwentarz stał się częścią prawego panelu Redemption, potrafi pokazywać upływ czasu/ładunki i scalił kontrolę walki w jednym miejscu – to funkcje nieobecne w wersji upstream.

### 3.28. `modules/game_mainpanel/mainpanel.lua` – nowy kontroler przycisków akcji

Upstream OTClient w ogóle nie ma modułu `game_mainpanel` – przyciski gry dokują się do prostego top-menu. W `testyy/modules/game_mainpanel/mainpanel.lua` pojawia się dedykowany `Controller`, który zarządza trzema sekcjami (Options/Specials/Store) w głównym prawym panelu i udostępnia API dla innych modułów.

Najważniejsze elementy:
1. **Dynamiczny layout** – funkcje `calculatePanelHeight()` i `reloadMainPanelSizes()` liczą wysokość każdego segmentu, uwzględniając liczbę ikon i stan sklepu, a wynik przekazywany jest do `modules.game_interface.getMainRightPanel()` tak, aby dokowane mini-okna (inventory, skills, vip) nie zachodziły na siebie. Użytkownik może dodatkowo schować sekcję Options (`optionsShrink`, `changeOptionsSize()`).
2. **API na przyciski** – `addToggleButton`, `addSpecialToggleButton` i `addStoreButton` tworzą jednolite kafelki (z obsługą PPM) i rejestrują je w słowniku `buttonConfigs`. Dzięki temu moduły (np. `game_skills`, `game_viplist`, sklep) dodają własne ikonki bez znania struktury UI.
3. **Personalizacja kolejności** – panel konfiguracyjny ładowany przez `option_control_buttons.otui` (wstrzykiwany do `modules.client_options`) pozwala chować/przesuwać przyciski. Konfiguracja żyje w `g_settings` (`control_buttons.buttons/order`), a helpery `updateDisplayedButtonsList`/`moveButtonUp/Down` dbają o natychmiastowe odświeżenie UI.
4. **Tryb extended view** – `toggleExtendedViewButtons()` potrafi przenieść wszystkie ikonki z panelu głównego do `modules.client_topmenu.getRightGameButtonsPanel()`, dzięki czemu te same kontrolki działają także w wariancie okienkowym (HUD dokowany poza mapą).

W praktyce moduł pełni rolę „dockera” dla całego HUD-u, czego upstream nie posiada.

### 3.29. `modules/game_healthinfo/healthinfo.lua` – minimalistyczny pasek HP/MP

- W `oryginall/otclient/modules/game_healthinfo/healthinfo.lua` znajdziemy rozbudowane okno (HP/MP/XP, soul/cap, ikony stanów i nakładkę kół w rogu mapy).
- W `testyy/modules/game_healthinfo/healthinfo.lua` moduł został zredukowany do kontrolera wyświetlającego wyłącznie paski zdrowia/many w głównym prawym panelu. Za kondycje, XP i overlay odpowiadają inne komponenty (`StatsBar`, `inventory`, `game_interface`).

Najważniejsze różnice:
1. Moduł działa jako `Controller` i dziedziczy logikę dokowania/extended view – w trybie rozszerzonym tworzy przycisk w top-menu (`modules.client_topmenu.addTopRightToggleButton`) i zmienia ramkę widgetu (czarna obwódka), a w widoku klasycznym dokuje się zawsze na pozycji 2 w `mainRightPanel`.
2. Rejestrowane są tylko zdarzenia `onHealthChange/onManaChange` (brak obsługi soul/cap/states). Funkcja `healthManaEvent()` aktualizuje szerokość pasków, wykorzystując całe dostępne pole (min. 12 px), co pasuje do nowej formy StatsBar.
3. Ze względu na uproszczenie nie powstają już dodatkowe widgety (overlay na mapie, condition icons), więc moduł szybciej się ładuje i nie duplikuje informacji, które i tak pokazują `StatsBar` i `inventory`.

### 3.30. `modules/game_skills/skills.lua` – panel statystyk z dodatkowymi systemami

Porównanie:
- upstreamowy `skills.lua` ma ~430 linii, statyczne mini-okno z kilkoma polami i prostym sortowaniem, przycisk w top-menu i brak keybindów;
- wersja `testyy/modules/game_skills/skills.lua` to prawie 800 linii zintegrowanych z Redemption: przycisk trafia do `modules.game_mainpanel`, istnieje skrót `Alt+S` zarządzany przez `Keybind`, a moduł współpracuje z nowymi atrybutami serwera (AdditionalSkills, ExperienceRate, Forge).

Wyróżnione dodatki:
1. **Nowe statystyki** – obsługujemy zdarzenia `onFlatDamageHealingChange`, `onAttackInfoChange`, `onImbuementsChange`, `onDefenseInfoChange`, `onCombatAbsorbValuesChange`, `onForgeBonusesChange` czy `onExperienceRateChange`. Każdy wpis tworzy własny kafelek z tooltipem, kolorem i możliwością ukrycia, co pozwala prezentować dane z systemów 14.12+, imbuementów i kuźni.
2. **Personalizacja widoku** – kliknięcie na kafelek (`onSkillButtonClick`) zwija/rozwija pasek procentowy, a preferencje są zapisywane per postać w `g_settings` (`skills-hide`). `updateHeight()` dynamicznie zmienia wysokość okna zależnie od widocznych elementów.
3. **Integracje HUD** – moduł rejestruje się w `modules.game_mainpanel` (ikona w prawej kolumnie), wprowadza keybind „Windows/Show-hid skills window” i podczas otwierania próbuje znaleźć wolny panel przez `modules.game_interface.findContentPanelAvailable`.
4. **Monitoring exp** – logika `checkExpSpeed()` i `ExpRating` liczy tempo expienia na podstawie historii 30 próbek oraz rozbija źródła exp boosta (voucher, store boost, stamina multiplier), pokazując wynik w widgecie `xpGainRate` z kolorowaniem progu.

Z perspektywy użytkownika panel skills zamienił się w centrum diagnostyki postaci – upstreamowy odpowiednik nie obsługuje żadnej z powyższych funkcji.

### 3.31. `modules/game_battle/battle.lua` – battle list z drzewem i filtrami

Porównanie:
- w `oryginall/otclient` battle lista przechowuje stałą pulę 30 przycisków, aktualizuje się co 100 ms i sortuje zwykły wektor; filtry są podstawowe, a moduł działa wyłącznie jako mini-okno w top-menu;
- `testyy/modules/game_battle/battle.lua` to ponad 1100 linii z przebudowaną architekturą: przycisk żyje w `modules.game_mainpanel`, jest keybind `Ctrl+B`, a dane o stworzeniach trzymane są w drzewie binarnym (`binaryTree`) zsynchronizowanym z pulą obiektów `BattleButtonPool`.

Kluczowe różnice:
1. **Sortowanie i wydajność** – `binaryInsert/binarySearch` utrzymują posortowaną listę wg wybranego kryterium (`name/distance/age/health`), co eliminuje kosztowne pełne sortowania przy każdej zmianie. Przyciski są pobierane z puli `ObjectPool`, dzięki czemu battle list scales wraz z liczbą stworzeń.
2. **Zaawansowane filtry** – panel filtrów przechowuje checkboxy w `hideButtons`, pozwala zapisywać stan (`g_settings`), a `toggleFilterPanel()` umożliwia jego całkowite schowanie (wraz z zapamiętaniem preferencji). Dostępne opcje obejmują graczy/NPC/monstery/skulls/party.
3. **Integracje z UI** – moduł reaguje na `UIMap.onZoomChange`, `LocalPlayer.onPositionChange` oraz `Creature` events (appear/disappear/outfit/skull), dzięki czemu battle list aktualizuje się natychmiast po zmianie widoczności, a nie w stałym interwale. Funkcja `attackNext()` pozwala cyklicznie przechodzić po widocznych celach (w przód/tył).
4. **Lepszy UX** – dodatkowy `mouseWidget` rozróżnia kombinacje kliknięć (look/attack/menu), a logika `onAttack/onFollow` potrafi podświetlić aktualny cel nawet wtedy, gdy battle okno jest schowane (creature otrzymuje `showStaticSquare`).

### 3.32. `modules/game_viplist/viplist.lua` – kontroler VIP z grupami i skrótami

Porównanie:
- upstreamowy `viplist.lua` posiada wyłącznie listę kontaktów z trzema trybami sortowania i przyciskiem w top-menu;
- `testyy/modules/game_viplist/viplist.lua` przenosi logikę do `Controller`, dodaje ikonę w `game_mainpanel`, skrót `Ctrl+P` zarządzany przez `Keybind`, obsługuje grupy VIP (`GameVipGroups`) oraz lokalny cache informacji (`vipInfo`) gdy serwer nie wysyła rozszerzonych danych.

Rozszerzenia Redemption:
1. **Grupowanie i edycja** – moduł potrafi tworzyć/edytować/usunąć grupy (`createAddGroupWindow`, `g_game.editVipGroups`) i wyświetlać VIP-ów w sekcjach (`VipGroupList`) z możliwością ukrywania offline. Kontekstowe menu rozróżnia kliknięcia na grupach vs graczach i pozwala edytować grupę tylko gdy jest oznaczona jako `editable`.
2. **Zaawansowane sortowanie** – `globalSettings.vipSortOrder` przechowuje stos priorytetów (status → typ → nazwa), który użytkownik może zmieniać poprzez menu, a funkcja `compareVips()` stosuje tę kolejność zarówno dla widoku płaskiego jak i grupowego.
3. **Integracja z klientem** – przycisk znajduje wolny panel (jak w skills/vip), okno pamięta preferencje (`Grouped`, `OfflineVips`), a menu kontekstowe rozszerzono o akcje klientowe (zaproszenia do prywatnego kanału, kopiowanie nazw, przełączanie trybu grupowego). Moduł rozpoznaje też `GameAdditionalVipInfo` i w razie braku tej funkcji samemu przechowuje opisy/ikony powiązane z kontem.

W efekcie lista VIP stała się rozbudowanym menedżerem kontaktów zgodnym z funkcjami Tibii 12+, podczas gdy upstream ogranicza się do prostej tablicy nazw.

### 3.33. `modules/game_hotkeys/hotkeys_manager.lua` – keybindy, akcje i per-serwer pamięć

Porównanie:
- upstream (`oryginall/otclient/modules/game_hotkeys/hotkeys_manager.lua`) działa na prostym oknie z selektorem profili (`configSelector`) i zapisuje hotkeye w plikach `hotkeys_X.otml`; wymaga ręcznej zmiany aktywnego profilu i nie komunikuje się z systemem `Keybind`.
- nasz moduł (`testyy/modules/game_hotkeys/hotkeys_manager.lua`) jest spięty z globalnym `Keybind` API, wystawia przełącznik w prawym top-menu (`modules.client_topmenu.addRightGameToggleButton`) i zapisuje hotkeye w `g_settings` z kluczami per host i per postać (opcja `configure(savePerServer, savePerCharacter)`).

Najważniejsze różnice funkcjonalne:
1. **Akcje klienckie** – poza klasycznym użyciem przedmiotów/tekstów można przypisać akcje sterujące (`HOTKEY_ACTION_*`), np. przełączanie WASD, cykliczny atak z listy battle, zmianę trybu chase; po wyborze akcji UI automatycznie czyści pola item/spell i aktualizuje opis.
2. **Spójność z Keybind** – moduł rejestruje skrót otwierający okno (`Ctrl+K`) i udostępnia `modules.game_hotkeys.createHotkeyBlock` innym oknom (np. kreator zaklęć/actionbara), dzięki czemu żadne okno modalne nie przechwytuje skrótów podczas edycji.
3. **Elastyczne przechowywanie** – konfiguracje są przechowywane w `g_settings` jako drzewo `game_hotkeys -> host -> postać`, co pozwala mieć inne hotkeye na różnych serwerach oraz automatycznie przełączać profil po zalogowaniu; upstream użytkownik musi ręcznie wskazać numer konfiguracji dla każdej kombinacji klient/postać.
4. **Lepsze UI listy** – lista hotkeyów wspiera auto-sortowanie według długości/nazwy kombinacji, fokusowanie strzałkami i szybkie dodawanie domyślnych klawiszy (`F1–F12`, `Shift+F1–F4`). Dodatkowe kolorowanie (`HotkeyColors.action`) odróżnia sloty na akcje klientowe.

Ostatecznie system hotkeyów w Redemption jest częścią tej samej infrastruktury co pozostałe skróty klienta (Keybind + ustawienia per serwer/postać), podczas gdy upstream ogranicza się do statycznych profili `otml` przełączanych manualnie.

### 3.34. `modules/game_actionbar/game_actionbar.lua` – pojedynczy pasek slotów kontra wielopanelowy actionbar_v2

Porównanie:
- upstream (`oryginall/otclient/modules/game_actionbar/actionbar.lua`) tworzy aż dziewięć dokowanych pasków (3 dolne, 6 bocznych), każdy z 50 przyciskami `ActionButton`; konfiguracja zapisywana jest we wspólnym JSON-ie (`actionbar_v2.json`), wspierane są typy `TEXT/SPELL/ITEM` oraz akcje `USE/USE_SELF/USE_TARGET`.
- nasz moduł w `testyy/modules/game_actionbar/game_actionbar.lua` zastępuje tę konstrukcję jednym poziomym paskiem o 60 slotach dokowanym do `modules.game_interface.getBottomPanel()`. Całość zapisujemy per postać w `g_settings` (`game_actionbar -> <character> -> slotX`) wraz z hotkeyem, parametrem i informacją o tierze przedmiotu.

Kluczowe różnice:
1. **Okna przypisań** – zamiast wspólnego okna „Assign” każde źródło ma dedykowany panel (`assign_spell.otui`, `assign_text.otui`, `assign_object.otui`) z podglądem ikon, filtrem (`SpelllistSettings`) i integracją z `modules.game_hotkeys` (blokadą skrótów podczas wpisywania). Dzięki temu gracz widzi pełną listę profili zaklęć Redemption (ikony, słowa, parametry).
2. **Obsługa przedmiotów i tierów** – slot przechowuje `itemId`, `subType`, `useType` i opcjonalny `getTier`, które są renderowane przez `ItemsDatabase.setTier`; użycie obiektu automatycznie wybiera tryb `use with` jeśli to przedmiot wielokrotnego użycia.
3. **Hotkeye w samym pasku** – każdy slot może mieć własny skrót; UI wyświetla skrót w wersji skróconej (S/A/C zamiast Shift/Alt/Ctrl), a rebind powoduje natychmiastowe odpięcie poprzedniego handlera (`unbindHotkeys`). Upstream przypisuje hotkeye do przycisków, ale są one rozproszone per pasek i zależą od tego, czy przycisk jest aktywny.
4. **Integracja z cooldownami** – moduł nasłuchuje `onSpellCooldown` i `onSpellGroupCooldown` i rysuje półprzezroczyste prostokąty (`SpellProgressRect`) bezpośrednio na slocie, licząc czas pozostały w sekundach. Actionbar_v2 również śledzi cooldown, ale robi to per przycisk i wymaga aktualizacji całego słownika `settings`; tutaj cooldown jest doklejony do konkretnego widgetu i znika automatycznie gdy zdarzenie dobiegnie końca.
5. **Scroll i blokada** – pasek posiada własny suwak poziomy, przyciski przewijania oraz tryb blokady (zatrzymuje drag&drop i zamianę slotów). Ponieważ wszystkie sloty są w jednym panelu, przełączanie stron działa przez przesuwanie w poziomie, a nie przez aktywowanie kolejnego docka.

W efekcie actionbar Redemption jest bliższy układowi CipSoft (jedna listwa + przewijanie), przechowuje komplet danych w `g_settings` i współpracuje z naszym Keybind/hotkey managerem, podczas gdy actionbar_v2 z upstreamu to zestaw niezależnych paneli z własnym formatem JSON.

### 3.35. `modules/game_shortcuts/shortcuts.lua` – mobilne skróty dotykowe

Ten moduł nie ma odpowiednika w `oryginall/otclient`. `testyy/modules/game_shortcuts/shortcuts.lua` ładuje się tylko na urządzeniach mobilnych (`if not g_platform.isMobile() then return end`) i tworzy panel z kilkoma ikonami dotykowymi (widok `shortcuts.otui`). Każda ikona zachowuje stan zaznaczenia oraz timestamp ostatniego kliknięcia, co ułatwia implementację gestów podwójnego dotknięcia po stronie innych modułów.

Najważniejsze cechy:
1. **Lifecycle spięty z grą** – panel jest pokazywany/ukrywany w `onGameStart/onGameEnd`, dzięki czemu na ekranie logowania nie zasłania UI. Przyciski można też ukryć ręcznie (`hide()/show()`), co wykorzystuje `modules.game_interface` przy zmianie layoutu.
2. **Reset i odczyt stanu** – helpery `resetShortcuts()` i `getShortcut()` pozwalają innym modułom (np. `game_interface` albo akcji specjalnych) w prosty sposób sprawdzić, która ikona jest aktywna, i natychmiast wyczyścić wybór po użyciu.
3. **Obsługa tylko na mobile** – wszystkie operacje (tworzenie UI, podpinanie eventów) są strzeżone sprawdzeniem `g_platform.isMobile()`, więc moduł nie wpływa na desktopowy build klienta.

W praktyce jest to warstwa pomocnicza pod mobilne HUD-y Redemption: upstream nie posiada żadnego panelu skrótów dotykowych, więc omawiany moduł to czysta nowość.

### 3.36. `modules/game_joystick/joystick.lua` – wirtualny d-pad na ekran dotykowy

Podobnie jak skróty, joystick istnieje wyłącznie w `testyy/modules/game_joystick/joystick.lua`. Upstreamowy otclient nie oferuje żadnego joysticka ekranowego – sterowanie mobilne opiera się jedynie na przyciskach mapy.

Najważniejsze elementy implementacji:
1. **UI i obsługa zdarzeń** – moduł ładuje `joystick.otui` i podpina gesty `onMousePress/onMouseMove/onMouseRelease` bezpośrednio do tarczy kierunkowej. Każde zdarzenie przelicza współrzędne kursora na wartości znormalizowane 0–1, dzięki czemu joystick działa niezależnie od rozdzielczości.
2. **Symulacja ruchu** – funkcja `executeWalk()` harmonogramuje się co 20 ms i na podstawie offsetu względem środka decyduje o kierunku (`Directions.NorthWest` itd.). Wspiera również ruch kardynalny przy niewielkich odchyleniach oraz przekazuje informację `firstStep`, tak aby moduł chodzenia mógł zacząć od kliknięcia, a potem przejść w ciągły ruch.
3. **Integracja z innymi modułami** – zewnętrzne systemy (np. `modules.game_walk`) mogą zarejestrować `moveListener`, aby otrzymywać kierunki bezpośrednio z joysticka i decydować, czy wysłać `g_game.walk`. Dodatkowo joystick automatycznie ukrywa/pokazuje się przy logowaniu/wylogowaniu, więc nie zakłóca ekranów startowych.

Wersja upstreamowa nie ma odpowiednika, dlatego obsługa ruchu dotykowego to jedna z większych przewag Redemption na urządzeniach mobilnych.

### 3.37. `modules/game_minimap/minimap.lua` – kontroler panelu, warstwy i zegar dnia

Porównanie:
- upstream (`oryginall/otclient/modules/game_minimap/minimap.lua`) tworzy jedno okno `MiniWindow` z guzikiem w top-menu, opcją „Full Map” i prostymi skrótami (Ctrl+M, Alt+strzałki). Data/dzień, warstwy czy osadzenie w panelach nie są rozwinięte.
- nasz moduł (`testyy/modules/game_minimap/minimap.lua`) to pełnoprawny `Controller` osadzony w `modules.game_interface.getMainRightPanel()`, wyposażony w panel warstw, kompas („rose panel”), pasek dnia/nocy oraz tryb „extended view”, który potrafi przenieść widżet do osobnego top-menu buttona.

Różnice w funkcjonalności:
1. **Warstwy i floor marker** – klient śledzi `virtualFloor` (bazowo 7) i zapala odpowiedni marker na pionowej liście w UI. Zmiany pozycji gracza (`onPositionChange`) aktualizują zarówno kamerę, jak i highlight w panelu, a przyciski `upLayer/downLayer` sterują `floorUp/floorDown` minimapy niezależnie od trymerów wbudowanych w widget.
2. **Zegar świata i kompas** – `onChangeWorldTime` (wywoływany z serwera) rysuje segment na 124-pikselowym pasku, rozdzielając go na część główną i poszerzaną, dzięki czemu UI odzwierciedla wschód/zachód słońca. Dodatkowo obramowanie „rose” pozwala przesuwać mapę o osiem kierunków poprzez kliknięcie odpowiedniego przycisku.
3. **Tryb fullscreen i extended view** – przycisk `fullscreen()` przenosi widget na `game_interface.getRootPanel()`, ustawia dedykowany zoom (`zoomFullmap`) i wiąże klawisz `Escape` do powrotu; `extendedView(true)` zamiast tego tworzy przycisk w top-menu i pozwala przenieść okno do prawej kolumny z czarną ramką (dla małych ekranów). Upstream zna tylko prosty `toggleFullMap()` i nie zmienia wyglądu okna.
4. **Formaty minimapy** – moduł potrafi ładować zarówno `minimap.otmm` (domyślnie) jak i `minimap_<version>.otcm`, przełączając funkcje `g_minimap.loadOtmm`/`g_map.loadOtcm` w zależności od flagi `otmm`. Przy zapisie analogicznie wybiera rozszerzenie.

Efekt: minimapa w Redemption jest zintegrowana z nowym HUD-em (wielo-panelowy interfejs, top-menu, extended view) i dostarcza dodatkowe informacje (pory dnia, warstwy, przyciski kierunków). Upstreamowy moduł jest prostym oknem pobieranym z `modules.game_interface.getRightPanel()` i nie zapewnia tych rozszerzeń.

### 3.38. `modules/game_questlog/game_questlog.lua` – nowy kontroler logu i tracker miniwindow

Porównanie:
- upstream (`oryginall/otclient/modules/game_questlog/questlog.lua`) używa jednego okna `QuestLogWindow`, które przełącza się między listą questów a misjami, zapisuje dane w `/settings/questlog.json` i ma prosty panel trackera dokowany do prawego panelu; sortowanie/filtry są minimalne.
- `testyy/modules/game_questlog/game_questlog.lua` wprowadza `Controller` z własnym layoutem HTML/OTUI (`game_questlog.html`), przycisk w `game_mainpanel`, skrót Keybind i oddzielny miniwindow trackera (`QuestLogTracker`) otwierany też przyciskiem w mainpanelu.

Kluczowe rozszerzenia:
1. **Cache i filtry** – moduł utrzymuje `questLogCache` (liczba ukończonych, ukrytych, widocznych) i dynamicznie koloruje wiersze („zebra stripes”). Panel filtrów pozwala przełączać widoczność ukończonych/ukrytych z licznikiem, a lista wspiera wyszukiwarkę tekstową i sortowanie według kilku kryteriów (`Alphabetically`, `Completed on Top/Bottom`). Każdy wpis ma ikony ukrycia/pinia dostępne z poziomu kliknięć.
2. **Tracker persistowany per postać** – zamiast prostego `settings[player][trackdata] = bool` używamy pliku `/settings/questtracking.json`, gdzie każda postać ma listę misji (`settings[namePlayer]`) wraz z nazwami. Funkcja `sendQuestTracker` mapuje listę na parę `questId -> questName` i wysyła przez `g_game.sendRequestTrackerQuestLog`, pozwalając serwerowi zsynchronizować widoczność trackera.
3. **Miniwindow i menu** – tracker ma własne menu (czyszczenie listy, planowane auto-tracki) i przycisk otwierający pełny Quest Log. W trybie 1280+ przycisk jest dostępny bezpośrednio w `game_mainpanel`; przy niższych wersjach klienta opcje trackera znikają, co jest obsłużone w `onGameStart` (chowa checkbox `showInQuestTracker`).
4. **Integracja z Keybind i UI** – okno questów jest osadzane w centrum ekranu i reaguje na Keybind „Show/hide quest log”. Podczas zaznaczania misji UI od razu aktualizuje panel opisu, stan checkboxa „Show in tracker” oraz przycisk paska bocznego.

Efekt: log questów w Redemption jest rozbudowanym narzędziem zarządzania misjami (sortowanie, ukrywanie, pinowanie, tracker z osobnym oknem), podczas gdy upstreamowy moduł oferuje jedynie podstawowe przejrzenie questów i ręczne śledzenie kilku misji.

### 3.39. `src/framework/graphics/drawpool.*` – nowa warstwa renderera (brak odpowiednika w upstreamie)

Porównanie:
- upstream: **brak** `drawpool.h/.cpp` – rysowanie odbywa się bezpośrednio przez `Painter` i garść wyspecjalizowanych kolejek (mapa, światło, UI), zarządzanych z poziomu `MapView` / modułów Lua;
- nasz klient: `testyy/src/framework/graphics/drawpool.h/.cpp` – wprowadza klasę `DrawPool` oraz pomocniczy `DrawHashController`, które tworzą dodatkową warstwę nad `Painterem`.

Najważniejsze różnice funkcjonalne i skutki:

1. **Logiczne pule rysowania zamiast „gołych” wywołań Painter**
   - Upstream:
     - logika jest rozproszona: `MapView`/UI pilnują kolejności rysowania (np. mapa → światło → UI) i same decydują, kiedy zmienić stan `Painter` (tekstura, shader, clip, opacity, transforms).
     - brak pojęcia „puli” – nie ma obiektu, który kolekcjonuje draw call-e do późniejszego przetworzenia.
   - U nas:
     - `enum class DrawPoolType` (`MAP`, `CREATURE_INFORMATION`, `LIGHT`, `FOREGROUND_MAP`, `FOREGROUND`) oraz `enum DrawOrder` (`FIRST`–`FIFTH`) definiują **stałe, wysokopoziomowe kolejki**;
     - każda kolejka ma osobny obiekt `DrawPool`, który przyjmuje żądania rysowania (prostokąty, trójkąty itp.), buforuje je i dopiero później wypuszcza do OpenGL.
   - **Efekt:**
     - łatwiej sterować globalną kolejnością renderowania (np. włącz/wyłącz cały `LIGHT` albo `CREATURE_INFORMATION` bez zmian w dziesiątkach miejsc);
     - warstwa renderera staje się wymienialna: kod gry/GUI nie musi znać szczegółów glDraw*, wystarczy, że „wrzuca” rzeczy do odpowiedniego poola.

2. **Agresywne łączenie draw call-i na podstawie hasha stanu**
   - Upstream:
     - stan `Painter` jest zmieniany „w locie” (setTexture, setOpacity, setClipRect, setShaderProgram, setTransformMatrix);
     - grupowanie draw call-i jest ograniczone – zwykle jedna mapa/warstwa = kilka wywołań, ale **brak centralnego mechanizmu** scalania kilku wywołań o identycznym stanie.
   - U nas:
     - `DrawPool::PoolState` przechowuje kompletny stan rysowania: macierz transformacji, opacity, tryb mieszania (`CompositionMode`/`BlendEquation`), clipRect, wskaźnik shadera, kolor, teksturę/ID tekstury, identyfikator macierzy tekstury oraz gotowy `hash`;
     - `DrawPool::updateHash` buduje hash z powyższych pól **oraz** z geometrii (`dest`/`src`, wierzchołki trójkąta, parametry bounding rect);
     - `DrawHashController` pamięta ostatni hash i może:
       - pominąć kolejne rysowanie, jeśli nowy hash jest identyczny (`isLast`) – oszczędzamy CPU/GPU gdy zawartość FBO się nie zmieniła;
       - gromadzić unikalne hashe, by później stwierdzić, czy w ogóle trzeba odświeżyć dany pool (`wasModified`).
     - przy dodawaniu nowych obiektów:
       - jeśli ostatni element listy ma ten sam `PoolState`, to tylko dokładamy dane do istniejącego `CoordsBuffer` (brak dodatkowego draw call);
       - jeśli `m_alwaysGroupDrawings` jest ustawione (np. dla tekstu/CREATURE_INFORMATION), obiekty o tym samym hash-u są **zawsze** scalane w jeden bufor, niezależnie od tego, kiedy zostały dodane.
   - **Efekt:**
     - drastyczne ograniczenie liczby wywołań `glDrawArrays` / `glDrawElements` przy renderowaniu powtarzalnych elementów (tile mapy, tekst, ikony);
     - łatwiej zachować 60 FPS nawet przy dużej liczbie obiektów, bo koszt „podejmowania decyzji” jest wykonywany raz, przy budowaniu poola.

3. **Ścisła integracja z atlasami tekstur (`TextureAtlas`)**
   - Upstream:
     - atlasowanie (jeśli występuje) jest silnie związane z konkretnymi miejscami (np. mapą); brak jednolitej obsługi w samym rendererze;
     - `Painter` nie wie, czy dana tekstura jest częścią atlasu, więc nie może uogólnić optymalizacji.
   - U nas:
     - `DrawPool` współpracuje z `TextureAtlas` przez `m_atlas`:
       - przy dodawaniu obiektu, jeśli tekstura ma przypisany region w atlasie, geometryczne `src` jest przesuwane o offset regionu, a `PoolState` używa **ID atlasu** zamiast ID pojedynczej tekstury;
       - jeśli tekstura może być cache’owana, a nie ma jeszcze regionu, `PoolState::execute` dodaje ją do atlasu „w locie”.
   - **Efekt:**
     - mapa, teksty i UI mogą korzystać z jednego (lub kilku) atlasów, co zamienia setki tekstur w kilka dużych powierzchni;
     - GPU widzi znacznie mniej przełączeń tekstur, co przekłada się na stabilniejsze FPS.

4. **Obsługa framebufferów (FBO) jako części kolejki, a nie osobnej warstwy**
   - Upstream:
     - `FrameBuffer` i `FrameBufferManager` są używane wprost z kodu gry/UI – komponenty same decydują, kiedy bindować/zwalniać FBO i co na nie rysować;
     - kolejność „bind FBO → rysuj → release → narysuj na ekran” jest rozproszona po wielu miejscach.
   - U nas:
     - `DrawPool::bindFrameBuffer` i `releaseFrameBuffer` dodają do `m_objects` **specjalne akcje** (`DrawObject` ze `std::function<void()>`), które:
       - w odpowiednim momencie bindują tymczasowy FBO (`getTemporaryFrameBuffer`),
       - po zakończeniu rysowania zdejmują FBO i rysują jego zawartość na ekran (lub do innego FBO) przez `frame->draw(dest)`;
       - przy okazji aktualizują hash w `DrawHashController`, aby zmiana treści FBO wymuszała repaint całej puli.
   - **Efekt:**
     - `DrawPool` ma pełną wiedzę o tym, kiedy i po co używane są framebuffery (np. mapa, światło, postprocessing w `FOREGROUND`);
     - rozwiązuje to część problemów z „przypadkowym” rysowaniem w niewłaściwym FBO i ułatwia debugowanie złożonych efektów (lightmapa, filtry, efekty pogodowe).

5. **Transformacje 2D jako stan puli, nie globalny `Painter`**
   - Upstream:
     - transformacje (translate/scale/rotate) są zwykle wywoływane bezpośrednio na `Painter` lub na poziomie `MapView`/UI;
     - aby narysować kilka elementów z różnymi przekształceniami, kod ręcznie wstawia `pushTransformMatrix`/`popTransformMatrix` i pilnuje kolejności.
   - U nas:
     - `DrawPool` przechowuje w `PoolState::transformMatrix` macierz transformacji dla **konkretnego obiektu/pakietu obiektów**;
     - metody `scale`, `translate`, `rotate`, `pushTransformMatrix`, `popTransformMatrix` modyfikują tę macierz jeszcze **przed** zbudowaniem PoolState (a więc i hasha);
     - podczas wykonania (`PoolState::execute`) macierz jest ustawiana w `Painter` dopiero na czas rysowania danego pakietu.
   - **Efekt:**
     - transformacje są częścią stanu, który można porównywać i grupować (np. wszystkie obiekty mapy na tym samym piętrze, z tym samym zoomem);
     - łatwiej jest wprowadzić efekty globalne (np. skalowanie mapy pod DPI) bez modyfikacji setek wywołań `Painter::scale` w innych plikach.

6. **Parametry „only once” i dodatkowe parametry puli**
   - Upstream:
     - brak budowanego mechanizmu „tylko na jeden draw” – wywołujący musi pamiętać, by po zmianie np. clipRect ręcznie przywrócić poprzedni stan;
     - brak miejsca na przekazywanie parametrów pomocniczych (np. rect źródłowy/dest) między warstwami.
   - U nas:
     - flagi `STATE_OPACITY`, `STATE_CLIP_RECT`, `STATE_SHADER_PROGRAM`, `STATE_COMPOSITE_MODE`, `STATE_BLEND_EQUATION` pozwalają oznaczyć, że dana zmiana stanu ma obowiązywać tylko dla **następnego** obiektu; po dodaniu obiektu `resetOnlyOnceParameters()` cofa te zmiany;
     - prosty słownik `m_parameters` (`std::any`) umożliwia zapisywanie dodatkowych danych po nazwie (`setParameter/getParameter/containsParameter/removeParameter`) – wykorzystywane m.in. przez `DrawPoolManager` i moduły shaderów.
   - **Efekt:**
     - mniej błędów typu „zostawiony clipRect/opacity” wpływających na kolejne obiekty;
     - możliwość dodawania nowych, wysokopoziomowych funkcji renderera bez zmian w API `Painter`.

7. **Ponowne użycie buforów współrzędnych (`CoordsBuffer`)**
   - Upstream:
     - `CoordsBuffer` istnieje, ale jego życiem zarządzają bezpośrednio pojedyncze komponenty; recykling buforów jest ograniczony.
   - U nas:
     - `DrawPool` przechowuje własny cache buforów (`m_coordsCache`) i `getCoordsBuffer()` zwraca `shared_ptr` z niestandardowym deleterem, który po zakończeniu rysowania czyści bufor i odkłada go z powrotem do puli, o ile `DrawPool` jest wciąż włączony;
     - przy flushowaniu (`flush()` / `release()`) kolekcje obiektów są scalane i buforowane z myślą o następnym kadrze.
   - **Efekt:**
     - mniej alokacji i dealokacji na ścieżce renderującej (ważne przy 60+ FPS);
     - deterministyczne zarządzanie pamięcią GPU/CPU z jednego miejsca.

Podsumowując: `DrawPool` jest **nową warstwą renderera**, której w upstreamowym otclient nie ma w ogóle. Zamyka w jednym miejscu:
- logikę kolejek (pule i podkolejki),
- optymalizacje (hashowanie, atlasowanie, grupowanie, recykling buforów),
- zarządzanie framebufferami i transformacjami.

Skutkiem jest znacznie bardziej wydajne i przewidywalne renderowanie, kosztem większej złożoności kodu frameworka graficznego – ale ta złożoność jest schowana pod nową, spójną abstrakcją.

### 3.40. `src/framework/graphics/framebuffer.h/.cpp` – uproszczone FBO bez depth, spięte z DrawPool

Porównanie:
- upstream: `oryginall/otclient/src/framework/graphics/framebuffer.h/.cpp` – klasa `FrameBuffer` dziedzicząca po `stdext::shared_object`, z opcjonalnym depth bufferem (`WITH_DEPTH_BUFFER`), własnym zarządzaniem renderbufferem głębi i API mocno splecionym z `Painterem` (save/restore state, `setResolution` itp.);
- nasz klient: `testyy/src/framework/graphics/framebuffer.h/.cpp` – `FrameBuffer` to zwykła klasa, która trzyma tylko **kolorowe FBO** (bez depth), współpracuje z `Painterem` przez prosty interfejs (`bind()/release()/draw()`/`prepare()`), a zarządzanie głębią przenosimy na wyższy poziom (w praktyce klient 2D nie korzysta z depth buffer).

Najważniejsze różnice i ich konsekwencje:

1. **Rezygnacja z wbudowanego depth buffer**
   - Upstream:
     - konstruktor przyjmuje `bool withDepth`; jeśli `WITH_DEPTH_BUFFER` jest zdefiniowane, tworzy dodatkowy renderbuffer (`m_depthRbo`) i podpina go jako `GL_DEPTH_ATTACHMENT`;
     - `bind()` może pożyczać depth z innego `FrameBuffer` (parametr `depthFramebuffer`), dzięki czemu kilka FBO może dzielić jedną bufor głębi;
     - `clear()` czyści zarówno kolor, jak i depth (`glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)`).
   - U nas:
     - w ogóle nie ma opcji depth – `FrameBuffer` obsługuje tylko kolor; pola `m_depthRbo`, `m_depth` itp. zniknęły;
     - cała logika „dzielenia” depth pomiędzy FBO jest usunięta;
     - czyszczenie głębi (jeśli potrzebne) byłoby robione na zewnątrz przez `Painter`, ale w praktyce **klient 2D w Redemption nie używa bufora głębi** do mapy/GUI.
   - **Efekt:**
     - uproszczenie kodu i mniejsze ryzyko błędów związanych z nieprawidłową obsługą depth (np. artefakty przy niezsynchronizowanych FBO);
     - pełna funkcjonalność 2D pozostaje – depth w oryginalnym otclient był głównie mechanizmem do eksperymentów/bajerów, a nie kluczowym elementem renderera.

2. **Inne podejście do rozmiaru, tekstury i macierzy projekcji**
   - Upstream:
     - `resize(const Size&)` zawsze tworzy nową teksturę (`Texture(size, false, m_smooth, true)`) i podmienia ją w FBO;
     - rozdzielczość `Painter`a ustawiana jest w `bind()` przez `g_painter->setResolution(m_texture->getSize())`;
     - `draw()`/`draw(dest, src)` rysują pełny prostokąt przez `g_painter->drawTexturedRect(...)` i zakładają, że tekstura nie jest odwrócona.
   - U nas:
     - `resize(const Size&)` tworzy `Texture(size)`, wymusza `setSmooth(m_smooth)` oraz **ustawia ją do góry nogami** (`setUpsideDown(true)`), po czym wylicza własną macierz projekcji (`m_textureMatrix = g_painter->getTransformMatrix(size)`);
     - dodatkowo wypełniamy `m_screenCoordsBuffer` (stały quad pełnoekranowy dla FBO), żeby szybciej rysować tło/clear;
     - metoda `prepare(dest, src, colorClear)` buduje osobny bufor `m_coordsBuffer` z geometrią „gdzie i co narysować”, a `draw()` używa tej geometrii i tekstury do `g_painter->drawCoords(...)`.
   - **Efekt:**
     - `FrameBuffer` staje się bardziej „świadomy” geometrii i może być bezpośrednio wykorzystywany przez `DrawPool` (który operuje na `CoordsBuffer`), a nie tylko przez `drawTexturedRect`;
     - odwrócenie tekstury (`setUpsideDown`) dopasowuje współrzędne do standardowej orientacji w naszym pipeline (ważne przy screenshotach/eksporcie).

3. **Zmienione zarządzanie stanem `Painter`a podczas bind/release**
   - Upstream:
     - `bind()` zapisuje pełen stan `Painter`a (`saveAndResetState`), ustawia rozdzielczość na rozmiar FBO, a `release()` go przywraca (`restoreSavedState`);
     - `FrameBuffer` więc bezpośrednio wymusza reset wszystkich parametrów (shader, kolor, clipRect, itp.).
   - U nas:
     - `bind()` zapisuje tylko **rozmiar i macierz projekcji** (`m_oldSize`, `m_oldTextureMatrix`) i ustawia `setResolution(getSize(), m_textureMatrix)` oraz flagę alpha writing;
     - jeśli `m_isScene` jest ustawione, resetuje stan `Painter`a, ale w przypadku zwykłych FBO pozostawia część wcześniejszych ustawień (np. shader może być ustawiony przez `DrawPool`);
     - `release()` przywraca tylko rozdzielczość i macierz – reszta stanu jest kontrolowana „wyżej”.
   - **Efekt:**
     - `FrameBuffer` jest mniej inwazyjny – nie resetuje pełnego stanu za każdym razem, co lepiej współgra z warstwą `DrawPool`/`DrawPoolManager`;
     - łatwiej łączyć efekty post-processingu (shadery) z FBO, bo nie są automatycznie kasowane przy każdym wyjściu z `bind()`.

4. **Asynchroniczne screenshoty oparte na dispatcherach**
   - Upstream:
     - `doScreenshot(fileName)` sprawdza, czy jest na głównym wątku; jeśli nie, przekazuje zadanie na `g_graphicsDispatcher`, a później w `g_asyncDispatcher` zapisuje PNG przez `Image::savePNG`;
     - piksele są też ręcznie obracane horyzontalnie i wertykalnie, żeby uzyskać poprawny układ.
   - U nas:
     - `doScreenshot(file, x, y)` zawsze „owija” całość w `g_mainDispatcher.addEvent`, dzięki czemu operacja GL jest na pewno na wątku renderującym;
     - po `glReadPixels` (już z przesunięciem `x/y`) wywołujemy `g_asyncDispatcher.submit(...)` i wewnątrz tworzymy `Image`, odwracamy obraz (`flipVertically`) i ustawiamy pełną nieprzezroczystość (`setOpacity(255)`), po czym zapisujemy PNG;
     - dodatkowo `extractTexture()` umożliwia wyciągnięcie zawartości FBO jako nowej `Texture` (z `Image`), co w upstreamie nie istnieje.
   - **Efekt:**
     - screenshotowanie i eksport FBO jest bezpieczniejsze w wielowątkowym środowisku (jasny podział: GL na main thread, I/O na async),
     - można łatwo wykorzystać zawartość FBO jako zwykłą teksturę (np. dla efektu mini-mapy, podglądu).

Podsumowanie: nasz `FrameBuffer` jest mocno „odchudzony” z perspektywy depth, ale lepiej dopasowany do 2D + warstwy `DrawPool`. Konsekwencją jest prostszy kod i szczelniejsze spięcie z `Painterem` i `CoordsBuffer`, kosztem rezygnacji z nieużywanego w praktyce bufora głębi.

### 3.41. `src/framework/graphics/paintershaderprogram.cpp` – inny model stanu shaderów (kolor/opacity/macierze)

Porównanie:
- upstream: `oryginall/otclient/src/framework/graphics/paintershaderprogram.cpp` – `PainterShaderProgram` dziedziczy po `ShaderProgram(name)`, śledzi kolor, głębokość (`m_depth`), czas (`m_time`), pełną macierz koloru (`m_useColorMatrix`) oraz szereg uniformów dla atlasów (`u_Atlas`, `u_Fonts`), offsetu, centrum itd.; używany jest zarówno dla zwykłego rysowania, jak i outfit layerów, tekstu, mapy;
- nasz klient: `testyy/src/framework/graphics/paintershaderprogram.cpp` – `PainterShaderProgram` jest uproszczoną klasą skupioną na **podstawowym 2D bez depth**: kolor + osobna wartość opacity, transform/projection/texture matrix i wieloteksturowość, ale bez matrix color i bez dodatkowych atlasowych uniformów.

Najważniejsze różnice:

1. **Kolor + opacity vs kolor + matrix koloru + depth**
   - Upstream:
     - uniform `u_Color` służy zarówno do zwykłego koloru, jak i do przekazywania macierzy koloru (4×4) – wtedy `m_useColorMatrix` steruje tym, co jest aktualnie ustawiane;
     - do tego dochodzi `u_Depth` (`setDepth` w warunku `WITH_DEPTH_BUFFER`), co umożliwia prostą pseudo-3D z wykorzystaniem bufora głębi;
     - brak osobnego uniformu `u_Opacity` – alpha jest zawarta w `u_Color`.
   - U nas:
     - kolor (`m_color`) i krycie (`m_opacity`) są rozdzielone – mamy osobne uniformy `u_Color` i `u_Opacity` oraz metody `setColor`, `setOpacity`;
     - w ogóle rezygnujemy z depth (`m_depth`, `u_Depth`) i matrix koloru – uproszczenie pod 2D;
     - `setColor` i `setOpacity` pilnują, żeby nie wysyłać wartości, które się nie zmieniły.
   - **Efekt:**
     - prościej sterować efektami typu „fade”/„flash” – wiele miejsc w kodzie może manipulować `opacity` bez utraty informacji o kolorze;
     - brak wsparcia dla bardziej skomplikowanych efektów post-processingu opartych o matrix koloru, ale w praktyce Redemption korzysta z prostszego zestawu shaderów 2D.

2. **Brak atlasowych i „scenicznych” uniformów**
   - Upstream:
     - w `setupUniforms()` wiążemy dodatkowe lokacje `u_Atlas`, `u_Fonts`, `u_Offset`, `u_Center`, `u_Resolution` i ustawiamy ich wartości – to jest część rozbudowanego pipeline'u z multi-teksturami atlasów i shaderów specjalnych;
   - U nas:
     - ograniczamy uniformy do absolutnego minimum: transform/projection/texture, kolor, opacity, czas, 4 sloty tekstur (`u_Tex0`–`u_Tex3`) i `u_Resolution`;
     - brak `u_Atlas`/`u_Fonts`, więc logika atlasów siedzi po stronie `DrawPool` / `TextureAtlas`, a shader jest „głupi” i prosty.
   - **Efekt:**
     - mniejszy koszt utrzymania shaderów i łatwiejsza ich wymiana (GLSL jest prostszy);
     - atlasowanie jest w pełni kontrolowane przez C++ (`DrawPool` + `TextureAtlas`), co wpisuje się w ogólną architekturę Redemption.

3. **Inne API tekstury macierzy**
   - Upstream:
     - `setTextureMatrix(const Matrix3& textureMatrix)` – przechowuje macierz w `m_textureMatrix` i wysyła ją do uniformu;
   - U nas:
     - `setTextureMatrix(const Matrix3* textureMatrix)` – przechowujemy **wskaźnik** na macierz (`m_textureMatrix`), a gdy jest `nullptr`, używamy `DEFAULT_MATRIX3`;
   - **Efekt:**
     - `Painter` może współdzielić macierz tekstury pomiędzy różnymi shaderami bez kopiowania (ważne przy atlasach i transformacjach UI);
     - umożliwia to lepszą integrację z `TextureManager` (który trzyma macierze transformacji po ID tekstury).

4. **Multi-textury – zachowana funkcja, ale uproszczone logowanie**
   - W obu wersjach istnieją `addMultiTexture` i `bindMultiTextures`, różnią się tylko szczegółami (komunikat błędu, inicjalizacja tekstur).
   - **Efekt:**
     - nasze shadery nadal mogą korzystać z dodatkowych tekstur (np. maski, efekty), ale główny „sterownik” i tak jest po stronie `DrawPool`/`Painter`.

Podsumowując: nasz `PainterShaderProgram` jest „odchudzoną” wersją skupioną na 2D i integracji z nowym `Painterem` i `TextureManagerem`. Rezygnujemy z depth i zaawansowanej matrix koloru, a w zamian zyskujemy prostsze sterowanie kolorem/opacity i lepszą integrację z atlasami przez C++ zamiast przez GLSL.

### 3.42. `src/framework/graphics/painter.cpp` – od stanu globalnego do klasy zarządzanej przez `unique_ptr`

Porównanie:
- upstream: `oryginall/otclient/src/framework/graphics/painter.cpp` – globalny wskaźnik `Painter* g_painter`, klasa obsługująca zarówno fixed-pipeline jak i depth buffer (jeśli włączony), z wieloma domyślnymi shaderami (`m_drawTexturedProgram`, `m_drawNewProgram`, `m_drawTextProgram`, `m_drawOutfitLayersProgram` itd.);
- nasz klient: `testyy/src/framework/graphics/painter.cpp` – `std::unique_ptr<Painter> g_painter`, uproszczony `Painter` nastawiony na pracę z `CoordsBuffer` i `PainterShaderProgram` w wersji 2D (bez depth, bez nowego/outfitowego/tekstowego shadera w tym pliku – te funkcje są rozbite na inne komponenty w Redemption).

Najważniejsze zmiany i ich skutki:

1. **Globalny wskaźnik vs RAII (`unique_ptr`)**
   - Upstream:
     - `Painter* g_painter = nullptr;` i ręczne zarządzanie cyklem życia (init/terminate) z zewnątrz;
   - U nas:
     - `std::unique_ptr<Painter> g_painter = nullptr;` – jasno określony właściciel, konstrukcja/destrukcja kontrolowana w jednym miejscu;
   - **Efekt:**
     - mniejsze ryzyko wycieków i użycia `Painter`a po zwolnieniu (RAII);
     - ułatwione testowanie (można łatwo podmienić globalny `Painter` w kontrolowanych warunkach).

2. **API rysowania: z `drawTexturedRect` na `drawCoords`**
   - Upstream:
     - `Painter` ma zestaw metod rysujących prymitywy bezpośrednio z parametrów (`drawRect`, `drawFilledRect`, `drawTexturedRect`, `drawBoundingRect` itd.); w wielu miejscach kod buduje współrzędne „na piechotę” i przekazuje tylko doc/src rect;
   - U nas:
     - centralną metodą jest `drawCoords(const CoordsBuffer&, DrawMode)`:
       - przyjmuje gotowy `CoordsBuffer` (z vertexami + texcoordami);
       - wybiera shader (`m_drawProgram`) w zależności od tego, czy jest aktywna tekstura i czy nadpisaliśmy shader `setShaderProgram`;
       - ustawia transform/projection/opacity/kolor/rezolucję, teksturę i multi-textury, po czym wywołuje `glDrawArrays`.
   - **Efekt:**
     - renderer jest ściśle spięty z `CoordsBuffer` i `DrawPool` – to właśnie one przygotowują geometrię, a `Painter` jest czystą warstwą „GPU driver + shader state”;
     - łatwiej optymalizować (większe batche, mniej bezpośrednich alokacji/operacji per sprite).

3. **Inny model stanu: brak depth, uproszczone blend/clip/alpha writing**
   - Upstream:
     - `Painter` trzyma m.in. `m_depth`, `m_depthFunc`, różne tryby blend equation (ADD/MAX/SUBTRACT), składane composition modes, włączanie/dezaktywacja depth testu itp.; wiele z nich jest powiązanych z opcjonalnym buforem głębi;
   - U nas:
     - `Painter` skupia się na tym, co potrzebne w nowym 2D:
       - `m_opacity`, `m_color`, `m_compositionMode`, `m_blendEquation`, `m_clipRect`, `m_alphaWriting`, `m_transformMatrix`, `m_projectionMatrix`, `m_textureMatrix`, `m_glTextureId`;
       - brak wszelkiej logiki głębi;
       - `setResolution` przyjmuje dodatkowo macierz projekcji (jeśli nie podana – wylicza ją przez `getTransformMatrix`).
   - **Efekt:**
     - mniejsza złożoność, lepsza czytelność przy debugowaniu renderera 2D;
     - brak wsparcia depth = brak potencjalnych błędów z Z-fightingiem, ale też brak możliwości łatwego rozszerzenia w stronę 3D (co w tym projekcie i tak nie jest celem).

4. **Ścisła współpraca z `TextureManager` i macierzami atlasów**
   - Upstream:
     - `setTexture(const TexturePtr&)` ustawia `m_glTextureId` i `m_textureMatrix` na bazie pojedynczej tekstury;
   - U nas:
     - mamy dwie wersje:
       - `setTexture(const TexturePtr&)` – bierze ID tekstury i ID macierzy transformacji z `Texture`;
       - `setTexture(uint32_t textureId, uint16_t textureMatrixId)` – pozwala ustawić teksturę **po ID i ID macierzy**, bez wskaźnika na `Texture`;
     - `setTextureMatrix` korzysta z `g_textures.getMatrixById(textureMatrixId)`.
   - **Efekt:**
     - renderer może pracować na teksturach z atlasów zarządzanych centralnie (identyfikatory zamiast wskaźników), co jest kluczowe dla `TextureAtlas` + `DrawPool`;
     - mniejsza liczba dereferencji wskaźników i lepsza lokalność danych przy renderowaniu.

Podsumowanie: nasz `Painter` jest mocniej „sprzęgnięty” z nowym pipeline (CoordsBuffer + DrawPool + TextureManager po ID) i zrywa z częścią funkcji oryginału (depth, zestaw domyślnych shaderów w jednym miejscu). W zamian dostajemy prostszy, ściśle 2D-owy renderer, który lepiej skaluje się z nową architekturą klienta.

### 3.43. `src/framework/graphics/coordsbuffer.h/.cpp` – uproszczony bufor współrzędnych bez locków i hardware cache

Porównanie:
- upstream: `oryginall/otclient/src/framework/graphics/coordsbuffer.h/.cpp` – `CoordsBuffer` trzyma dwa `std::shared_ptr<VertexArray>` (vertexy i texcoordy), ma mechanizm `m_locked`/`unlock()`/`cache()`, a także dostęp do potencjalnego hardware cache (`HardwareBuffer` przez `getVertexHardwareCache()`/`getTextureHardwareCache()`);
- nasz klient: `testyy/src/framework/graphics/coordsbuffer.h/.cpp` – `CoordsBuffer` trzyma **dwa obiekty `VertexArray` na stosie**, bez wskaźników, locków i hardware cache; API jest odchudzone do operacji faktycznie używanych przez `DrawPool` i nowy renderer.

Różnice w szczegółach i skutki:

1. **Model pamięci: shared_ptr + lock vs proste obiekty na stosie**
   - Upstream:
     - konstruktor tworzy dwa `std::shared_ptr<VertexArray>`;
     - `clear()`/`unlock(bool)` mogą wymieniać cały obiekt `VertexArray` (tworząc nowe instancje) w zależności od flagi `m_locked`;
     - `cache()` ustawia `m_locked = true` i wywołuje `cache()` na VertexArray, co potencjalnie przenosi dane do bufora na GPU.
   - U nas:
     - `CoordsBuffer(const size_t size = 64)` tworzy dwa zwykłe `VertexArray` z rezerwacją miejsca;
     - `clear()` tylko czyści zawartość, bez nowych alokacji;
     - brak mechanizmu lock/cache – zarządzanie życiem bufora jest przeniesione na warstwy wyżej (`DrawPool` recykluje całe obiekty `CoordsBuffer`).
   - **Efekt:**
     - mniej kosztownych alokacji/dereferencji w gorącej ścieżce renderującej;
     - uproszczenie logiki – `CoordsBuffer` jest „tępym” kontenerem na floaty, a decyzje o cachowaniu hardware-owym podejmują inne warstwy (jeśli w ogóle).

2. **API dopasowane do DrawPool (append, upside-down rect)**
   - Upstream:
     - ma `addRect/addQuad/addUpsideDownQuad/addBoudingRect/addRepeatedRects` i `getTextureRect()` – przydatne przy klasycznym rysowaniu direct z Painter;
   - U nas:
     - zachowujemy te metody, ale dodatkowo:
       - `addUpsideDownRect(const Rect& dest, const Rect& src)` – dedykowana dla przypadków, gdzie tekstura musi być odwrócona wertykalnie;
       - `append(const CoordsBuffer* buffer)` – pozwala skleić dwa bufory w jeden (kopiując vertexy i texcoordy), co jest bezpośrednio używane w `DrawPool::flush`/`release` przy scalaniu batched draw call-i;
       - rezygnujemy z `getTextureRect()` i hardware cache.
   - **Efekt:**
     - `CoordsBuffer` idealnie wpisuje się w koncepcję „zbieramy współrzędne w mniejszych buforach, a potem łączymy je w większe pakiety” w `DrawPool`;
     - mniej kodu związanego z analizą zawartości (np. `getTextureRect`) – w nowym pipeline ta informacja jest niepotrzebna.

3. **Brak integracji z HardwareBuffer**
   - Upstream:
     - `getVertexHardwareCache()`/`getTextureHardwareCache()` sugerują możliwość uploadu danych do VBO i ponownego wykorzystania bez kopiowania z RAM;
   - U nas:
     - takie metody w ogóle nie istnieją; `CoordsBuffer` dostarcza tylko zwykłe wskaźniki na tablice floatów i liczbę wierzchołków;
   - **Efekt:**
     - uproszczenie kosztem potencjalnie mniejszego wykorzystania VBO – ale w zamian mamy bardziej elastyczne batchowanie po stronie C++ (`DrawPool`) i proste API do `glDrawArrays`.

Podsumowanie: nasz `CoordsBuffer` jest prostszą, szybszą w zarządzaniu strukturą dopasowaną do `DrawPool` i nowego `Painter`a. Rezygnujemy z locków, shared_ptr i hardware cache, bo batching i recykling buforów jest rozwiązany wyżej w pipeline.

### 3.44. `src/framework/graphics/shader.h/.cpp` – kompilacja shaderów i logowanie błędów

Porównanie:
- upstream: klasa `Shader` kompiluje programy GL z tekstu/pliku, loguje błędy przez `g_logger.error("… {}", …)`; proste API do attachowania i kompilacji;
- nasz klient (`testyy/src/framework/graphics/shader.*`): API zgodne koncepcyjnie, ale spięte mocniej z `PainterShaderProgram` i menedżerem shaderów; brak printf‑stylu w logach.

Różnice i skutki:
- U nas logowanie błędów kompilacji/linkowania jest w pełni `{}`‑style; dzięki temu unikamy kompilacyjnych pułapek mieszania `%` z fmt.
- Integracja z dispatcherem (tworzenie shaderów w tle) w `shadermanager.cpp` wymaga, aby `Shader` był bezpieczny w użyciu z asynchronicznym przygotowaniem – utrzymujemy minimalny, deterministyczny stan.

### 3.45. `src/framework/graphics/shaderprogram.h/.cpp` – linkowanie programów i obsługa uniformów

Porównanie:
- upstream: `ShaderProgram` zarządza attach/link/bind, lookup uniformów/atrybutów;
- nasz klient: zachowujemy ten podział, ale stosujemy ujednolicony sposób pobierania lokacji i ustawiania wartości pod `PainterShaderProgram` (opacity, matrices, multi‑textures).

Różnice i skutki:
- W naszym pipeline uniformy są ustawiane konsekwentnie przez `PainterShaderProgram` (np. `u_Opacity` zamiast głębi); `ShaderProgram` dostarcza tylko bezpieczne API, bez wiedzy o atlasach.
- Zachowujemy `{}`‑style w logach na błędy linkowania, co jest istotne dla stabilności buildów.

### 3.46. `src/framework/graphics/shadermanager.h/.cpp` – rejestracja i asynchroniczne tworzenie shaderów

Porównanie:
- upstream: prosty manager bez wątku głównego; tworzy programy na miejscu;
- nasz klient: `shadermanager.cpp` używa `g_mainDispatcher` do bezpiecznej inicjalizacji shaderów po stronie GL oraz utrzymuje stałe identyfikatory/uniformy dla modułów.

Różnice i skutki:
- Asynchroniczne tworzenie shaderów wiąże się z jasnym rozdziałem: GL na main thread, przygotowanie danych w tle; to eliminuje wyścigi.
- Manager udostępnia setup dla shaderów map/item/UI, ale realna logika efektów pozostaje w Lua – zgodnie z „Lua‑first”.

### 3.47. `src/framework/graphics/texturemanager.h/.cpp` – cache tekstur, live‑reload i identyfikatory macierzy

Porównanie:
- upstream: manager tekstur z prostym cache i ładowaniem z plików PNG;
- nasz klient: rozszerzenia o APNG, asynchroniczne ładowanie, live‑reload, oraz przechowywanie ID macierzy transformacji dla atlasów.

Różnice i skutki:
- Logowanie używa `{}`‑style; ścieżki i błędy ładowania raportowane są spójnie (`Unable to load texture '{}': {}`).
- Przechowywanie `textureId` i `textureMatrixId` pozwala `Painter`owi pracować bezpośrednio na identyfikatorach, co zmniejsza koszty dereferencji i scala się z `DrawPool`.
- Live‑reload pozwala na hot‑swap assetów bez restartu klienta – istotne dla szybkiej iteracji Lua/UI.

### 3.48. `src/framework/graphics/textureatlas.h/.cpp` – pakowanie regionów i redukcja draw‑calli

Porównanie:
- upstream: podstawowy atlas z prostą alokacją regionów;
- nasz klient: użycie `phmap::flat_hash_map` i własnych funkcji hashujących; mechanizmy `freeRegions` i `flush` zoptymalizowane pod `DrawPool`.

Różnice i skutki:
- Zacieśniona współpraca z `DrawPool` (batche po wspólnej teksturze); atlasowanie przekłada się na mniejszą liczbę wywołań `glDrawArrays`.
- API pozostaje niewiedzące o shaderach – atlas służy wyłącznie do układania UV.

### 3.49. `src/framework/graphics/image.h/.cpp` – dekodowanie/zapis PNG, mipmapy i kopiowanie

Porównanie:
- upstream: `Image` obsługuje PNG oraz proste operacje na pikselach;
- nasz klient: podobnie, z dodatkami dot. mipmap i asynchronicznego zapisu (wywołania przez `g_asyncDispatcher`).

Różnice i skutki:
- Wyjątki używają `stdext::exception`, ale unikamy ciężkiego formatowania w nagłówkach; to zmniejsza presję na kompilator.
- `flipVertically`, `setOpacity` i szybkie tworzenie `Texture` z `Image` wykorzystywane w `FrameBuffer::extractTexture`.

### 3.50. `src/framework/graphics/apngloader.h/.cpp` – wsparcie APNG z ostrożnością na rozmiary i EOF

Porównanie:
- upstream: ładowanie APNG oparte o klasyczny parser chunków;
- nasz klient: zachowane funkcje, ze wzmocnieniem odczytów i walidacji (EOF, rozmiary, opcjonalny CRC), by uniknąć błędów runtime.

Różnice i skutki:
- Bez fmt w wyjątkach; odczyty i alokacje z kontrolą błędów → stabilniejszy dekoder przy uszkodzonych plikach.
- APNG używany przez system attached effects – poprawna obsługa jest kluczowa dla wizualnych dodatków.

### 3.51. `src/framework/graphics/cachedtext.h/.cpp` – cache tekstu pod pipeline CoordsBuffer

Porównanie:
- upstream: cache tekstu wiązany z `BitmapFont`/atlasem;
- nasz klient: cache generuje współrzędne (`CoordsBuffer`) zgodne z `DrawPool`/`Painter`, z opcją integracji ścieżki TTF.

Różnice i skutki:
- Dla tekstów opartych o bitmapę zachowujemy dotychczasowe metryki; dla TTF metryki pochodzą z shaper’a, a cache trzyma gotowe quady do rysowania.
- Dzięki temu `StaticText` i UI mogą korzystać z jednej warstwy cache niezależnie od backendu fontu.

### 3.52. `src/framework/graphics/animatedtexture.h/.cpp` – animowane tekstury z dispatcherem

Porównanie:
- upstream: prosta lista klatek z timerem;
- nasz klient: integracja z `EventDispatcher` i generowanie mipmap po zmianie klatki.

Różnice i skutki:
- Animacje są bezpieczne w środowisku wielowątkowym (GL operacje na głównym wątku), a aktualizacje klatek nie blokują renderu.

### 3.53. `src/framework/text/bitmapfont.h/.cpp` – ścieżka bitmapowa (atlas 0–255)

Porównanie:
- upstream: klasyczny atlas glifów, auto‑pomiar szerokości z kanału alfa;
- nasz klient: utrzymujemy kompatybilność, ale dodajemy heurystyki i czystsze logi, oraz współdziałanie z nowym cache tekstu.

Różnice i skutki:
- Dla TTF ścieżka bitmap jest pomijana; dla atlasów zachowujemy funkcje `wrapText`, `calculateGlyphsPositions` zgodne z pipeline’em `CoordsBuffer`.
- Logi w `{}`‑style (np. przy błędnym źródle tekstury) – bez printf.

### 3.54. `src/framework/text/TTFFont.h/.cpp` – TTF + HarfBuzz, opacity i fallback chain (tor nowego tekstu)

Porównanie:
- upstream: brak pełnej integracji TTF; render oparty głównie o bitmapy;
- nasz klient: pełny tor TTF (FreeType + HarfBuzz) z metrykami, shapingiem i opcjonalnym fallbackiem czcionek.

Różnice i skutki:
- Normalizacja parametrów język/script/direction (LocaleShaping) → poprawny RTL/CJK/Cyrylica bez ręcznego przełączania.
- Metryki i quady budowane pod `CoordsBuffer`; cache współdziała z `CachedText`/`DrawPool`.
- Dzięki temu UI/świat mogą wyświetlać „znaki świata” bez ograniczeń atlasu bitmap.

### 3.55. `src/framework/text/TextShaper.h/.cpp` – warstwa kształtowania (HarfBuzz) z auto‑heurystyką

Porównanie:
- upstream: ograniczony albo brak shaper’a;
- nasz klient: `TextShaper` bierze UTF‑8/UTF‑32, normalizuje parametry i zwraca „shaped runs” z poprawnymi pozycjami.

Różnice i skutki:
- Kierunek RTL ustawiany automatycznie dla odpowiednich skryptów; poprawne ligatury i kerning.
- API lekkie w nagłówku, ciężkie zależności (HB/FT) trzymane w `.cpp`.

### 3.56. `src/framework/ui/uiwidget.h/.cpp`, `uiwidgettext.cpp` – UI oparte o Lua, przejście na TTF

Porównanie:
- upstream: UI wiązane ściśle z `BitmapFont`;
- nasz klient: pozostawiamy zgodność, ale wprowadzamy ścieżkę TTF i docelowo abstrakcję fontu, aby UI działało z shapingiem.

Różnice i skutki:
- `setFont(...)` może wskazywać TTF/fallback chain; `getTextSize`/wrap działają na metrykach shaper’a gdy potrzeba.
- Dzięki temu moduły Lua (np. `StaticText`, `UITextEdit`) mogą renderować Unicode poprawnie.

### 3.57. `src/framework/ui/uitextedit.h/.cpp` – edytor tekstu: caret/selection po klastrach

Porównanie:
- upstream: logika oparta o bajty/atlas; zawęża się do ASCII/Latin‑1;
- nasz klient: dostosowanie do klastrów shaper’a (pozycje kursora/selection/liczenie szerokości), zachowując wydajność.

Różnice i skutki:
- Edycja i zaznaczanie działają poprawnie dla RTL/CJK/ligatur; bufor `CachedText` aktualizowany pod TTF.

### 3.58. `src/client/statictext.h/.cpp` – teksty w świecie gry (dymki, says)

Porównanie:
- upstream: korzysta z bitmapowego fontu i prostego cache;
- nasz klient: korzysta z `GameConfig` i `CachedText` z możliwością użycia TTF (metryki shaper’a).

Różnice i skutki:
- Teksty „nad głową” renderują się poprawnie w Unicode; batching przez `DrawPool` redukuje koszty.

### 3.59. `src/client/spritemanager.h/.cpp`, `thingtype.h/.cpp` – zarządzanie sprite’ami i metadanymi obiektów

Porównanie:
- upstream: klasyczne ładowanie z paczek i mapy typów;
- nasz klient: rozszerzenia pod async loading, APNG, oraz lepsze mapowanie appearance → atlas.

Różnice i skutki:
- Stabilniejszy loader (bez mieszania `%` w logach), szybszy dostęp do danych; spójność z `TextureManager`.
- **Transform/parameter stack** – API wystawia `push/pop`, `setParameter`, `flush`, `resetOnlyOnceParameters` itd., co pozwala modułom (np. efektom świetlnym) modyfikować stan tylko na jedno wywołanie. Upstreamowy kod nie miał żadnego porównywalnego mechanizmu – wszystko odbywało się poprzez natychmiastowe `g_painter->setX()`.

Nagłówek stanowi publiczny kontrakt dla `DrawPoolManager` oraz modułów korzystających z nowego pipeline’u; jest całkowitą nowością względem oryginalnego klienta.

### 3.43. `src/framework/graphics/framebuffer.h` – uproszczony interfejs FBO bez depth

W upstreamowym otclient klasa `FrameBuffer` dziedziczy po `stdext::shared_object` i wspiera opcjonalne depth buffery (kompilacja z `WITH_DEPTH_BUFFER`). Redemption całkowicie usuwa depth support i shared_object, skupiając się na kolorowych render targetach dla mapy/UI/effektów:
- **Brak depth** – usunięte `m_depth`, `m_depthRbo`, metody `hasDepth()`, `getDepthRenderBuffer()`. W Redemption framebuffery służą wyłącznie do offscreen rendering kolorów (mapa, światło, overlay), bez Z-buffera.
- **Nowe API** – dodane `setAutoClear(bool)`, `setAlphaWriting(bool)`, `setAutoResetState(bool)` do kontrolowania czyszczenia i alpha blendingu. Metoda `extractTexture()` pozwala wyciągnąć zawartość jako nową teksturę (np. dla screenshotów).
- **Przygotowanie coords** – `prepare(const Rect& dest, const Rect& src, const Color& colorClear)` ustawia wewnętrzne `CoordsBuffer` dla późniejszego rysowania, co integruje się z nowym `Painter` i pozwala na elastyczne skalowanie/rendering.
- **Uproszczony bind** – `bind()` bez parametrów, automatycznie resetuje painter state jeśli `m_isScene`, ustawia resolution i alpha writing. W upstreamie bind wymagał opcjonalnego depth framebuffer’a i ręcznego zarządzania stanem.

W skrócie: header definiuje lżejszy, bardziej zautomatyzowany framebuffer skoncentrowany na 2D rendering, bez legacy depth i shared pointers.

### 3.44. `src/framework/graphics/framebuffer.cpp` – nowoczesne zarządzanie FBO i async screenshot

Implementacja w Redemption jest znacznie prostsza i zintegrowana z nowym systemem graficznym:
- **Konstruktor/destruktor** – brak depth, dodane asynchroniczne usuwanie FBO w `g_mainDispatcher` (żeby uniknąć problemów z kontekstem OpenGL przy zamknięciu aplikacji).
- **Resize i bind** – `resize()` zwraca `bool` czy faktycznie zmienił rozmiar, automatycznie tworzy `CoordsBuffer` dla screen quad. `bind()` resetuje painter jeśli scena, ustawia resolution i alpha, czyści kolor jeśli `m_autoClear`.
- **Rysowanie** – `draw()` używa `CoordsBuffer` zamiast prostych rect, pozwala na `disableBlend` i custom `CompositionMode`. Brak depth attachments.
- **Screenshot** – `doScreenshot()` używa `g_asyncDispatcher.submit()` zamiast deprecated `detach_task`, czyta pixele z offsetem (x/3, y/1.5) i zapisuje PNG z flipem. W upstreamie screenshot był synchroniczny i wymagał ręcznego dispatchingu.
- **Extract texture** – nowa metoda czyta pixele do `std::vector<uint8_t>`, tworzy `Image` i zwraca jako `TexturePtr` (np. dla dalszego przetwarzania bez zapisywania do pliku).

Efekt: framebuffer stał się bardziej niezawodny i zintegrowany z Redemption pipeline, tracąc depth na rzecz lepszego async I/O i coords-based rendering.

### 3.41. `src/framework/graphics/drawpoolmanager.cpp` – scheduler render-passów

Podobnie jak `drawpool.cpp`, także `drawpoolmanager.cpp` nie występuje w klasycznym otclient. Tam pętle rysujące są zakodowane w `MapView`/`UI::draw`, a dane trafiają bezpośrednio do `Painter`. Redemption zastąpił to centralnym menedżerem, który steruje kolejką pooli, ich atlasami i framebufferami:
- **Inicjalizacja atlasów i pooli** – `init()` tworzy dwa współdzielone atlasy (`TextureAtlas` dla mapy i foregroundu) i przypina je do wybranych `DrawPoolType`. W upstreamie każda tekstura była ładowana osobno, więc nie było wspólnego cachowania.
- **Viewport-aware transform** – `draw()` porównuje `m_size` z bieżącym viewportem, przelicza macierz w `Painter` i dopiero potem odpala każdy pool, dzięki czemu cały UI/mapa reagują na zmianę rozdzielczości/skalę bez dodatkowych wywołań w modułach.
- **Dwubuforowanie obiektów** – `drawObjects()` trzyma dwa wektory `m_objectsDraw`, które są swapowane pod spinlockiem i oznaczane przez `m_shouldRepaint`. Dzięki temu wątki produkujące wpisy nie blokują głównego wątku renderującego.
- **Obsługa framebufferów** – jeśli pool operuje na własnym `FrameBuffer`, menedżer binduje go przed rysowaniem, wywołuje wszystkie akcje (lambda/instrukcje) i na końcu wykonuje `framebuffer->draw()` wraz z hookami `m_beforeDraw/m_afterDraw`. W starym kliencie framebuffery były opcjonalne i konfigurowalne ręcznie w kilku miejscach.
- **preDraw i akcje** – `preDraw()` pozwala modułowi przygotować pool w wydzielonym etapie (np. map lighting). Funkcja może zlecić `alwaysDraw`, wstrzyknąć akcję przygotowującą framebuffer (`addAction`) i dopiero potem zwolnić kolejkę. Upstreamowy kod bez tej warstwy robił wszystko natychmiastowo, często duplikując logikę.

### 3.42. `src/framework/graphics/drawpoolmanager.h` – publiczny interfejs renderera

Nowy nagłówek udostępnia wysokopoziomowe API, które zastępuje bezpośrednie użycie `Painter`a. Najważniejsze różnice względem upstreamu:
- **Bogate metody rysujące** – `addTexturedRect`, `addUpsideDownTexturedRect`, `addBoundingRect`, `addAction`, `addTexturedCoordsBuffer` itp. wpinają dane do aktualnie wybranego poola i automatycznie obsługują atlas/parametry. W klasycznym `g_painter->draw*` nie było żadnego buforowania ani kontekstu pooli.
- **Kontrola stanu** – wszystkie ustawienia (`setOpacity`, `setClipRect`, `setShaderProgram`, `setDrawOrder`, `setScaleFactor` itd.) są delegowane do `DrawPool`, który może zresetować je po jednym użyciu. Upstream operatorzy ustawiali globalny stan painter’a, co wymagało par ręcznych `push/pop` i było podatne na błędy.
- **Transformacje i parametry** – publiczne metody translate/rotate/scale/parameters wchodzą bezpośrednio w stack `DrawPool`. Dzięki temu moduły UI/MapView mogą działać równolegle, nie dotykając wspólnego painter state.
- **Integracja z shaderami** – `setShaderProgram()` sprawdza czy dany shader wymaga framebuffer’a (np. efekty świetlne) i pozwala przekazać callback ustawiający uniformy. W oryginale trzeba było ręcznie wiązać shader i pilnować czyszczenia stanu.

Nagłówek w praktyce definiuje jakikolwiek kontakt modułów z systemem graficznym – historia `g_painter->draw*` zostaje całkowicie zastąpiona operacjami na `DrawPoolManager`.


## 4. Struktura danych i duże pliki

- duże katalogi danych klienta i serwera nie są trzymane bezpośrednio w historii gita.
- użyto podejścia z archiwami podzielonymi na części (pliki `.zip.*`) – patrz notatki w `testyy/worklog_all.md` i powiązane wpisy.

## 5. Jak porównywać z oryginałem

Przy porównywaniu z oryginalnymi repozytoriami sugerowana metoda:
- dla serwera: porównywać względem `opentibiabr/canary` (ten sam lub zbliżony commit bazowy).
- dla klienta: porównywać względem forka otclienta użytego jako baza (lokalny diff po stronie użytkownika).

Ten dokument jest punktem startowym – w razie potrzeby można dodawać osobne podrozdziały dla konkretnych systemów (np. market, bestiary, metrics, itp.).
