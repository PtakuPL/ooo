# Naprawa warningów kompilacji Linux — OTClient

**Data:** 2026-02-17  
**Commit:** `322727516` — `fix: resolve all compiler warnings from Linux build`  
**Dotyczy:** OTClient (instalka) — build Linux (Release) na GitHub Actions  

## Problem

Build Linux przeszedł pomyślnie, ale generował ~30 warningów kompilatora GCC. Warningi te mogą maskować prawdziwe błędy i utrudniają czysty odczyt logów CI.

## Naprawione warningi

### 1. `-Wunused-result` — TextShaper.cpp:139
**Problem:** Ignorowany wynik `fribidi_reorder_line()` z atrybutem `warn_unused_result`.  
**Naprawa:** Jawne castowanie na `(void)` — sygnalizuje kompilatorowi że celowo ignorujemy wynik.

### 2. `-Woverloaded-virtual` — uiwidget.h:89 / uimap.h:38
**Problem:** `UIMap::draw(DrawPoolType)` ukrywa `UIWidget::draw(const Rect&, DrawPoolType)`.  
**Naprawa:** Dodanie `using UIWidget::draw;` w `UIMap` — obie sygnatury widoczne.

### 3. `-Wunused-variable` — localplayer.cpp (20 zmiennych)
**Problem:** Zmienne `oldFlatBonus`, `oldAttackValue`, `oldDefense`, `oldMomentum` itp. były deklarowane ale nigdy używane.  
**Naprawa:** Usunięcie 20 nieużywanych zmiennych `old*` z metod set*.

### 4. `-Wunused-variable` — protocolgame.cpp:70
**Problem:** Zmienna `padding` nie była używana.  
**Naprawa:** Zamiana na `inputMessage->getU8();` bez przypisania.

### 5. `-Wswitch` — protocolgameparse.cpp:4741
**Problem:** Brakujący case `CYCLOPEDIA_CHARACTERINFO_WHEEL` w switch.  
**Naprawa:** Dodanie `case Otc::CYCLOPEDIA_CHARACTERINFO_WHEEL: break;`.

### 6. `-Wunused-variable` — tile.cpp:137
**Problem:** Zmienna `newDest` deklarowana ale nigdzie nie używana w funkcji.  
**Naprawa:** Usunięcie zmiennej (reszta kodu i tak używa `dest` i `drawElevation` bezpośrednio).

### 7. `-Wunused-but-set-variable` — TTFFont.cpp:461
**Problem:** Zmienna `bounds` ustawiana z `buildQuads()` ale nigdy odczytywana.  
**Naprawa:** Wywołanie `buildQuads()` bez przypisania do zmiennej.

### 8. `-Wparentheses` — drawpool.cpp:171, image.cpp:186
**Problem:** Brak nawiasów wokół `&&` w wyrażeniu z `||` — niejednoznaczna kolejność operacji.  
**Naprawa:** Dodanie nawiasów: `(a && b) || c` zamiast `a && b || c`.

### 9. `-Wswitch` — drawpoolmanager.cpp:49
**Problem:** Brakujące case'y `LIGHT`, `FOREGROUND`, `LAST` w switch na `DrawPoolType`.  
**Naprawa:** Dodanie brakujących case'ów z pustym `break;`.

## Zmienione pliki (10)

| Plik | Zmiana |
|---|---|
| `framework/text/TextShaper.cpp` | `(void)fribidi_reorder_line(...)` |
| `client/uimap.h` | `using UIWidget::draw;` |
| `client/localplayer.cpp` | Usunięcie 20 zmiennych old* |
| `client/protocolgame.cpp` | Usunięcie `padding` |
| `client/protocolgameparse.cpp` | Dodanie case WHEEL |
| `client/tile.cpp` | Usunięcie `newDest` |
| `framework/text/TTFFont.cpp` | Usunięcie `bounds` |
| `framework/graphics/drawpool.cpp` | Dodanie nawiasów |
| `framework/graphics/image.cpp` | Dodanie nawiasów |
| `framework/graphics/drawpoolmanager.cpp` | Dodanie case LIGHT/FOREGROUND/LAST |

## Rezultat

Build Linux powinien teraz kompilować się bez warningów (0 warnings).
