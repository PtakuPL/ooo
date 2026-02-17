# Dopasowanie UI do wielojęzycznych tekstów — Analiza i Plan
**Data**: 2026-02-17  
**Status**: Analiza + Planowanie  
**Dotyczy**: OTClient Redemption — panel ustawień (Options) i system layoutu UI  

---

## 1. Stan obecny — Mechanizmy auto-resize w silniku

OTClient posiada **już wbudowane** mechanizmy auto-dopasowania tekstu w C++, ale prawie żaden element w panelu ustawień z nich **nie korzysta**.

### 1.1 Dostępne właściwości OTUI (C++ → `uiwidgettext.cpp`)

| Właściwość OTUI | Metoda C++ | Opis |
|---|---|---|
| `text-horizontal-auto-resize: true` | `PropTextHorizontalAutoResize` | Szerokość widgetu rośnie do rozmiaru tekstu |
| `text-vertical-auto-resize: true` | `PropTextVerticalAutoResize` | Wysokość rośnie do rozmiaru tekstu |
| `text-auto-resize: true` | Obie flagi | Obie osie naraz |
| `text-wrap: true` | `isTextWrap()` | Łamanie tekstu w wielu liniach |
| `min-width` / `max-width` | `setMinWidth()` / `setMaxWidth()` | Ograniczenia min/max szerokości |
| `min-height` / `max-height` | `setMinHeight()` / `setMaxHeight()` | Ograniczenia min/max wysokości |

### 1.2 Mechanizm `fit-children` (layout → rodzic)

W `UIVerticalLayout` i `UIHorizontalLayout` istnieje `fit-children: true`:
- Działa TYLKO z box layoutem (verticalBox / horizontalBox)
- Oblicza `preferredHeight` ze zsumowanych wysokości dzieci
- Ustawia `parentWidget->setHeight(preferredHeight)` via `g_dispatcher.deferEvent()`
- ALE: opcje (settings) nie używają box layoutu — używają **anchor layout** (ręczne pozycjonowanie)

### 1.3 Łańcuch propagacji rozmiaru (C++)

```
updateText() → setSize() → resize() → setRect()
  ↓
setRect() → updateLayout() → m_layout->update()
  ↓                            ↓
onGeometryChange()      parent->getLayout()->updateLater()  
  ↓                            ↓
callLuaField("onResize")  Przeliczenie anchors dzieci
```

**Kluczowa obserwacja**: Gdy widget zmienia rozmiar:
1. `setRect()` wywołuje `updateLayout()` — aktualizuje swój layout (dzieci)
2. Jednocześnie wywołuje `parentLayout->updateLater()` — rodzic przelicza pozycje dzieci
3. `onGeometryChange()` — jeśli `text-wrap`, to tekst jest ponownie łamany

ALE: **nie ma automatycznej propagacji "w górę"** — czyli jeśli dziecko urośnie, rodzic **NIE** rośnie automatycznie (chyba że `fit-children` w box layout).

---

## 2. Katalog problematycznych elementów

### 2.1 Panel ustawień — Okno główne

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `options.otui` | `optionsWindow` (MainWindow) | `size: 686 534` | **STAŁY** — nie rośnie nawet gdy treść większa |
| `options.otui` | `optionsTabBar` (sidebar) | `size: 128 453` | **STAŁY** — za wąski na długie kategorie |
| `options.otui` | `OptionsCategory` | `size: 115 22` | **STAŁY** — "Общие горячие клавиши" nie zmieści się |
| `options.otui` | `OptionsCategory > Button` | `size: 115 20` | **STAŁY** — tło przycisku kategorii |
| `options.otui` | OK Button | `size: 64 20` | Przycisk "Ok" — OK dla krótkich tłumaczeń |

### 2.2 Panel kontrolek (Controls → General)

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `general.otui` | `SmallReversedQtPanel` (x10+) | `height: 22` | **STAŁY** — zawinięty tekst nie będzie widoczny |
| `general.otui` | `hotkeysButton` | `size: 120 20` | **STAŁY** — "Менеджер горячих клавиш" nie zmieści się |

### 2.3 Panel grafiki (Graphics)

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `graphics.otui` | `SmallReversedQtPanel` (x5+) | `height: 22` | **STAŁY** |
| `graphics.otui` | `QtComboBox` (AntiAliasing) | `width: 180` | **STAŁY** — opcje mogą mieć dłuższe nazwy |
| `effects.otui` | `SmallReversedQtPanel` (x5+) | `height: 22` | **STAŁY** |
| `effects.otui` | `QtComboBox` (shadingType) | `width: 180` | **STAŁY** |

### 2.4 Panel interfejsu (Interface)

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `interface.otui` | `SmallReversedQtPanel` (x5+) | `height: 22` | **STAŁY** |
| `interface.otui` | `QtComboBox` (crosshair/skin) | `width: 120` | **STAŁY** |
| `console.otui` | `SmallReversedQtPanel` (x9) | `height: 22` | **STAŁY** |
| `HUD.otui` | `SmallReversedQtPanel` (x8+) | `height: 22` | **STAŁY** |

### 2.5 Inne panele

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `audio.otui` | `SmallReversedQtPanel` | `height: 22` / `44` | Częściowo stały |
| `misc.otui` | `SmallReversedQtPanel` | `height: 22` / `55` | Większe, ale nadal stałe |
| `help.otui` | Przyciski (report bug, FAQ) | `size: 130 20` | **STAŁY** |

### 2.6 Bazowe style przycisków (globalne)

| Plik | Element | Obecny rozmiar | Problem |
|---|---|---|---|
| `10-buttons.otui` | `Button` | `size: 106 23` | **STAŁY** — każdy przycisk z tłumaczeniem |
| `10-buttons.otui` | `QtButton` | `size: 106 23` | **STAŁY** — to samo |
| `10-buttons.otui` | `BigPremiumButton` | `size: 128 37` | **STAŁY** — graficzny, raczej OK |
| `10-checkboxes.otui` | `QtCheckBox` | `size: 14 14` | Tylko ikonka — tekst przez text-offset |

### 2.7 Elementy (częściowo) elastyczne

| Element | Dlaczego OK |
|---|---|
| `OptionCheckBox` / `OptionCheckBoxMarked` | anchored `left+right` → pełna szerokość rodzica |
| `OptionScaleScroll` label | anchored `left+right` ale scrollbar `width: 174` zajmuje dużo |
| `Title` label w `OptionsCategory` | Ma `text-auto-resize: true` — ale parent ma stałą szer. 115px |

---

## 3. DODATKOWY PROBLEM: Kategorie sidebar NIE SĄ tłumaczone

Nazwy kategorii w sidebarze (`options.lua` linia 15-68):
```lua
-- NIE owinięte w tr() !!!
text = "Controls"
text = "Interface"
text = "Graphics"
text = "Sound"
text = "Misc."
text = "General Hotkeys"
text = "HUD"
text = "Console"
text = "Effects"
text = "Help"
```

---

## 4. Przykłady overflow (angielski vs rosyjski)

| Klucz tłumaczenia | Angielski | Rosyjski | Stosunek |
|---|---|---|---|
| `tr_1` (hotkeysButton) | "Hotkeys Manager" (15 zn.) | "Горячие клавиши Manager" (24 zn.) | 1.6x |
| `tr_10` (displayText) | "Display text messages" (21 zn.) | "Показывать текстовые сообщения" (30 zn.) | 1.4x |
| `tr_13` (smartWalk) | "Enable smart walking" (20 zn.) | "Включить smart walking" (22 zn.) | 1.1x |
| `tr_18` (showPing) | "Show connection ping" (20 zn.) | "Показать connection ping" (24 zn.) | 1.2x |

Rosyjski jest ~1.2-1.6x dłuższy. Chińskie znaki są szersze per-glyph (choć tekst krótszy).

---

## 5. Istniejące użycie auto-resize w projekcie

Wyszukanie `text-auto-resize|text-wrap|text-horizontal-auto-resize|text-vertical-auto-resize`:

### W module ustawień (client_options):
- `options.otui:38` — `Title` label w `OptionsCategory`: `text-auto-resize: true` ✅
- `keybinds.otui:156,162` — 2x `text-horizontal-auto-resize: true`
- `key_edit.otui:25-26` — `text-wrap: true` + `text-auto-resize: true`

### W globalnych stylach (data/styles):
- `30-messageboxes.otui` — messagebox tekst: `text-wrap: true` + `text-auto-resize: true`
- `40-console.otui` — konsola: `text-wrap: true` + `text-auto-resize: true`
- `20-tables.otui` — tabele: `text-wrap: true`
- `10-items.otui` — itemy: `text-auto-resize: true`

**Wniosek**: Mechanizm ISTNIEJE i jest UŻYWANY — ale NIE w panelu ustawień.

---

## 6. Plan naprawy — 6 punktów

### Punkt 1: Sidebar (OptionsCategory) — powiększenie
**Problem**: `OptionsCategory` ma `size: 115 22`, wewnętrzny Button `size: 115 20`  
**Rozwiązanie**: Powiększyć do ~150px, sidebar (`optionsTabBar`) do ~148px  
```
OptionsCategory:  size: 150 22  →  Button: size: 150 20
optionsTabBar:    size: 148 453  (było 128)
```

### Punkt 2: Button / QtButton — auto-resize z min-width
**Problem**: Bazowy styl `Button`/`QtButton` ma stały `size: 106 23`  
**Rozwiązanie**: Dodać `text-horizontal-auto-resize: true` + `min-width: 106`  
```
QtButton:
  text-horizontal-auto-resize: true
  min-width: 106
  height: 23
```

### Punkt 3: hotkeysButton — auto-resize
**Problem**: `size: 120 20` — "Менеджер горячих клавиш" nie zmieści się  
**Rozwiązanie**: Zamienić `size` na auto-resize  
```
  text-horizontal-auto-resize: true
  min-width: 120
  height: 20
```

### Punkt 4: OptionCheckBox — text-wrap
**Problem**: Checkboxy rozciągają się na pełną szer. rodzica (anchors), ale tekst nie zawija się  
**Rozwiązanie**: Dodać `text-wrap: true` do `OptionCheckBox`  

### Punkt 5: Kategorie sidebar — owinięcie w tr()
**Problem**: Nazwy kategorii ("Controls", "Graphics" itd.) nie są tłumaczone  
**Rozwiązanie**: Owinąć w `tr()`:
```lua
text = tr("otclient_modules.options.category_controls"),
```

### Punkt 6: OptionScaleScroll — więcej miejsca na tekst
**Problem**: ScrollBar zajmuje `width: 174` z 500px panelu — mało miejsca na label  
**Rozwiązanie**: Zmniejszyć scrollbar width z 174 na 150  

---

## 7. KLUCZOWY WYMÓG UŻYTKOWNIKA: Kaskadowe powiększanie okien

**Wymóg**: "Wszystkie okienka powinny się powiększać gdy teksty dłuższe niż dane okienko. Nawet jedno okienko może zmienić wielkość innych okienek. Jeśli 'General Hotkeys' po rosyjsku jest za duże to całe okno ustawień powinno się powiększyć."

### 7.1 Co to oznacza technicznie

Użytkownik chce **kaskadowej propagacji rozmiaru w górę**:
```
Tekst "Горячие клавиши" jest za długi na OptionsCategory (115px)
  ↓ OptionsCategory się powiększa do np. 180px
    ↓ optionsTabBar (sidebar) musi się powiększyć bo dziecko urosło
      ↓ Okno optionsWindow musi się powiększyć bo sidebar jest szerszy
        ↓ Wszystko pozostaje graficznie spójne
```

### 7.2 Aktualnie brakujące mechanizmy

1. **Brak propagacji child→parent w anchor layout** — `fit-children` istnieje tylko w box layout
2. **Brak automatycznego min-width na podstawie dzieci** — rodzic nie wie, że dziecko jest za duże
3. **Brak onTextResize callback** — nie ma sposóbu na reakcję Lua-side gdy tekst zmienia rozmiar widgetu
4. **MainWindow ma hardcoded size** — `size: 686 534` jest stałe

### 7.3 Możliwe podejścia do implementacji

#### Podejście A: Czyste OTUI/Lua (bez zmian C++)
- Zmienić wszystkie stałe `size:` na `min-width`/`min-height` + auto-resize
- Dodać `onGeometryChange` callback w Lua do propagacji rozmiarów w górę
- W `configureCharacterCategories()` po setText obliczać max szer. kategorii i ustawiać sidebar
- W Lua callback na zmianę tekstu: przeliczać rozmiar okna

#### Podejście B: Nowy mechanizm C++ `fit-children` dla anchor layout
- Zaimplementować `fit-children` w `UIAnchorLayout` (obecnie brak)
- Obliczać bounding box wszystkich dzieci i dopasowywać rodzica
- Automatyczne kaskadowe powiększanie

#### Podejście C: Hybrydowe — Lua `onSetup` + minimalny C++
- W `OptionsCategory` `onSetup`: oblicz rozmiar tekstu, ustaw min-width
- W `options.lua` po załadowaniu paneli: oblicz max szerokość kategorii → ustaw sidebar → ustaw okno
- Dodać `min-width`/`min-height` wszędzie zamiast `size`
- Minimalnie: dodać do C++ `PropAutoFitParent` (dziecko mówi rodzicowi: dopasuj się do mnie)

---

## 8. Status font rendering (do kontekstu sesji)

W tej samej sesji naprawiono renderowanie fontów TTF:
- ✅ Przywrócono `ascent()/descent()/lineHeight()` w TTFFont.h
- ✅ Przywrócono derywację metryk z FreeType w `TTFFont::load()`
- ✅ Zamieniono bezpośredni `uploadSubPixels()` na odeferred `pendingUploads` + `flushPendingUploads()`
- ✅ Dodano `flushPendingUploads()` w `CachedText::drawTTF()`
- ✅ Naprawiono `buildQuads()` — `m_lineHeight` zamiast `m_pixelSize`
- ✅ Naprawiono duplikat `addTexturedCoordsBuffer`
- 🔲 Commit lokalny (guardian: `e47a21870`), potrzebny push + build na GitHub Actions

---

## 9. Wynik badania — Kaskadowe auto-resize (szczegółowy)

### 9.1 Architektura zmian rozmiaru w OTClient

Łańcuch zdarzeń gdy widget zmienia rozmiar:
```
setSize()/setWidth()/setHeight()
  → resize(w, h)
    → setRect(Rect)
      → if(m_minSize/m_maxSize) clamp()          [1] Respektuje min/max
      → if(clampedRect == m_rect) return false    [2] Brak zmian = brak propagacji
      → updateLayout()                           [3] Aktualizuje dzieci
        → m_layout->update()                     [3a] Layout przelicza pozycje/rozmiary dzieci
        → parent->getLayout()->updateLater()     [3b] Rodzic przelicza pozycje
      → deferred: onGeometryChange()             [4] Callback — jeśli text-wrap, updateText()
      → deferred: callLuaField("onResize")       [5] Lua callback
      → deferred: callLuaField("onWidthChange")  [6] Lua callback specyficzny
      → deferred: callLuaField("onHeightChange") [7] Lua callback specyficzny
```

### 9.2 Kluczowe obserwacje z badania

1. **`fit-children` ISTNIEJE** ale TYLKO w `UIVerticalLayout` i `UIHorizontalLayout` (box layout):
   - `uiverticallayout.cpp:96`: `if(m_fitChildren) parentWidget->setHeight(preferredHeight)`
   - `uihorizontallayout.cpp:94`: `if(m_fitChildren) parentWidget->setWidth(preferredWidth)`
   - Resize rodzica jest **deferred** przez `g_dispatcher.deferEvent()` — bezpiecznie

2. **Anchor layout NIE MA `fit-children`** — `uianchorlayout.cpp` tylko przelicza pozycje/rozmiary
   dzieci na podstawie anchors, ale NIGDY nie zmienia rodzica

3. **Panel ustawień używa wyłącznie anchor layout** — `anchors.top: prev.bottom` zamiast box layout

4. **`text-auto-resize: true` działa prawidłowo** — testowane w `Title` label w `OptionsCategory`
   - Label `Title` rośnie do rozmiaru tekstu
   - ALE: jego rodzic `Button` (size: 115 20) NIE rośnie za nim
   - ANI: dziadek `OptionsCategory` (size: 115 22)

5. **9-patch image (image-border) automatycznie się rozciąga** do rozmiaru widgetu:
   - `Button` ma `image-source: /images/ui/button-grey-up` + `image-border: 5`
   - Jeśli Button urośnie → tło automatycznie się rozciągnie
   - Jeśli OptionsCategory urośnie → ramka `1pixel-down-frame` się rozciągnie
   - Jeśli MainWindow urośnie → tło `window_new` się rozciągnie

6. **`min-width` / `max-width` respektowane w `setRect()`** — clamping działa poprawnie

7. **Lua API kompletne** — `getTextSize()`, `setWidth()`, `setHeight()`, `setMinWidth()`,
   `setMinHeight()`, `getWidth()`, `getHeight()`, `resizeToText()` — wszystko wyeksportowane

### 9.3 Analiza podejść

#### Podejście A: Czyste Lua (BEZ zmian C++) ✅ REKOMENDOWANE
**Idea**: Po utworzeniu kategorii w `configureCharacterCategories()`, zmierz max szerokość
tekstu i kaskadowo ustaw rozmiary od dołu do góry.

**Implementacja**:
```lua
-- W configureCharacterCategories() po pętli tworzenia widgetów:
local function adjustSidebarWidth()
    local maxTextWidth = 0
    local sidebar = controller.ui.optionsTabBar
    
    -- Zmierz max szerokość tekstu w kategoriach i podkategoriach
    for i = 1, sidebar:getChildCount() do
        local widget = sidebar:getChildByIndex(i)
        if widget and widget.Button and widget.Button.Title then
            local textSize = widget.Button.Title:getTextSize()
            -- Icon (13px) + marginLeft (10) + tekst + Arrow (7) + marginRight (5) + padding
            local neededWidth = 10 + 13 + 10 + textSize.width + 5 + 7 + 5
            maxTextWidth = math.max(maxTextWidth, neededWidth)
        end
        -- sprawdź podkategorie
        if widget and widget.subCategories then
            for subId, _ in ipairs(widget.subCategories) do
                local subWidget = widget:getChildById(subId)
                if subWidget and subWidget.Button and subWidget.Button.Title then
                    local textSize = subWidget.Button.Title:getTextSize()
                    local neededWidth = 10 + 13 + 10 + textSize.width + 5 + 7 + 5
                    maxTextWidth = math.max(maxTextWidth, neededWidth)
                end
            end
        end
    end
    
    -- Minimum 115 (obecny rozmiar)
    local sidebarWidth = math.max(115, maxTextWidth + 5) -- +5 dla marginesu
    local sidebarWidthWithBorder = sidebarWidth + 13     -- 128 - 115 = 13 (obecna różnica)
    
    -- Ustaw sidebar
    sidebar:setWidth(sidebarWidthWithBorder)
    
    -- Ustaw wszystkie kategorie
    for i = 1, sidebar:getChildCount() do
        local widget = sidebar:getChildByIndex(i)
        if widget then
            widget:setWidth(sidebarWidth)
            if widget.Button then
                widget.Button:setWidth(sidebarWidth)
            end
            -- podkategorie
            -- ... analogicznie
        end
    end
    
    -- KASKADA: Powiększ okno główne
    local window = controller.ui
    local widthDiff = sidebarWidthWithBorder - 128 -- różnica od domyślnego
    if widthDiff > 0 then
        local currentWindowWidth = window:getWidth()
        window:setWidth(currentWindowWidth + widthDiff)
    end
end
```

**Zalety**:
- Zero zmian C++ — bez ryzyka regresji
- Łatwe do testowania i iterowania
- Pełna kontrola nad logiką (co rośnie, co nie)
- Można dodać `min-width` w OTUI jako fallback

**Wady**:
- Manualna propagacja (ale to jednorazowe obliczenie, nie per-frame)
- Trzeba obsłużyć też panele treści (SmallReversedQtPanel)

#### Podejście B: fit-children w UIAnchorLayout (C++) — SZCZEGÓŁOWA ANALIZA

##### B.1 Istniejący wzorzec: fit-children w UIVerticalLayout

W `uiverticallayout.cpp` (linia 96) i `uihorizontallayout.cpp` (linia 94) mechanizm jest prosty:
```cpp
// UIVerticalLayout::internalUpdate()
if (m_fitChildren && preferredHeight != parentWidget->getHeight()) {
    g_dispatcher.deferEvent([=] {
        parentWidget->setHeight(preferredHeight);
    });
}
```
- `preferredHeight` = suma (margin + height + spacing) wszystkich widocznych dzieci + padding
- Resize rodzica jest **deferred** przez `g_dispatcher.deferEvent()` — unika recursion
- Box layout zna dokładną kolejność dzieci (liniowa) więc obliczenie jest trywialne

##### B.2 Problem z anchor layout

`UIAnchorLayout::internalUpdate()` (plik `uianchorlayout.cpp:268-286`) NIE OBLICZA preferowanego
rozmiaru — iteruje po `m_anchorsGroups` i wywołuje `updateWidget()` który pozycjonuje dziecko
na podstawie anchors. Nie sumuje niczego.

Anchory definiują **relacje** nie **kolejność**:
- `anchors.top: prev.bottom` — top tego = bottom poprzedniego
- `anchors.left: parent.left` + `anchors.right: parent.right` — wypełnij poziomo

Dzieci w anchor layout mogą:
1. Być anchored do `parent` → ich rozmiar zależy od rodzica
2. Być anchored do `prev` → tworzą łańcuch (jak w opcjach — SmallReversedQtPanel)
3. Być anchored do siebie nawzajem → potencjalny cykl
4. Mieć stały `size:` → niezależne od rodzica/rodzeństwa

##### B.3 Implementacja fit-children dla anchor layout

**Podejście**: Po aktualizacji wszystkich anchors w `internalUpdate()`, obliczyć **bounding box**
wszystkich widocznych dzieci i porównać z rozmiarem rodzica.

```cpp
// W UIAnchorLayout — nowe pola:
class UIAnchorLayout : public UILayout {
    // ...
    void applyStyle(const OTMLNodePtr& styleNode) override; // NOWY
    void setFitChildren(bool fitWidth, bool fitHeight);
    
    bool m_fitChildrenWidth{ false };
    bool m_fitChildrenHeight{ false };
};
```

```cpp
// UIAnchorLayout::internalUpdate() — modyfikacja:
bool UIAnchorLayout::internalUpdate()
{
    // ... istniejący kod: reset + updateWidget dla każdego dziecka ...

    // NOWY KOD: fit-children — oblicz bounding box dzieci
    if ((m_fitChildrenWidth || m_fitChildrenHeight) && changed) {
        const auto& parentWidget = getParentWidget();
        if (!parentWidget)
            return changed;

        int maxRight = 0;
        int maxBottom = 0;
        const auto& parentRect = parentWidget->getRect();
        const auto& paddingRect = parentWidget->getPaddingRect();

        for (const auto& [widget, anchorGroup] : m_anchorsGroups) {
            if (!widget->isExplicitlyVisible())
                continue;
            
            // Ignoruj dzieci anchored do parent z OBYDWU stron
            // (left+right lub top+bottom) — te są rozciągnięte, nie definiują rozmiaru
            bool anchoredBothHorizontal = false;
            bool anchoredBothVertical = false;
            bool anchoredToParentRight = false;
            bool anchoredToParentBottom = false;
            
            for (const auto& anchor : anchorGroup->getAnchors()) {
                // (uproszczona analiza anchors)
            }
            
            const auto& childRect = widget->getRect();
            
            if (m_fitChildrenWidth && !anchoredBothHorizontal) {
                int childRight = childRect.right() + widget->getMarginRight() 
                               - parentRect.left() + parentWidget->getPaddingRight();
                maxRight = std::max(maxRight, childRight);
            }
            
            if (m_fitChildrenHeight && !anchoredBothVertical) {
                int childBottom = childRect.bottom() + widget->getMarginBottom()
                                - parentRect.top() + parentWidget->getPaddingBottom();
                maxBottom = std::max(maxBottom, childBottom);
            }
        }

        // Deferred resize — unika recursion
        int newWidth = m_fitChildrenWidth ? std::max(maxRight, parentWidget->getWidth()) : parentWidget->getWidth();
        int newHeight = m_fitChildrenHeight ? std::max(maxBottom, parentWidget->getHeight()) : parentWidget->getHeight();
        
        if (newWidth != parentWidget->getWidth() || newHeight != parentWidget->getHeight()) {
            g_dispatcher.deferEvent([parentWidget, newWidth, newHeight] {
                parentWidget->resize(newWidth, newHeight);
            });
        }
    }

    return changed;
}
```

##### B.4 Parser OTUI dla anchor layout fit-children

W `UIAnchorLayout::applyStyle()` (nowa metoda):
```cpp
void UIAnchorLayout::applyStyle(const OTMLNodePtr& styleNode)
{
    UILayout::applyStyle(styleNode);
    for (const auto& node : styleNode->children()) {
        if (node->tag() == "fit-children")
            setFitChildren(node->value<bool>(), node->value<bool>());
        else if (node->tag() == "fit-children-width")
            setFitChildren(node->value<bool>(), m_fitChildrenHeight);
        else if (node->tag() == "fit-children-height")
            setFitChildren(m_fitChildrenWidth, node->value<bool>());
    }
}
```

OTUI użycie:
```yaml
# W options.otui — sidebar
UIWidget
  id: optionsTabBar
  layout:
    type: anchor
    fit-children-width: true
```

##### B.5 Kaskadowa propagacja fit-children

Mechanizm propagacji jest **wbudowany** w istniejący kod:
1. `parentWidget->resize(newWidth, newHeight)` w deferred event
2. `resize()` → `setRect()` → `updateLayout()` 
3. `updateLayout()` → `m_layout->update()` (aktualizuje swoich dzieci)
4. PLUS: `parent->getLayout()->updateLater()` (informuje dziadka)

Jeżeli dziadek (okno główne) też ma `fit-children`, to kaskada działa automatycznie:
```
Title rośnie (text-auto-resize)
  → Button (rodzic Title) fit-children → rośnie
    → OptionsCategory (rodzic Button) fit-children → rośnie  
      → optionsTabBar (rodzic OptionsCategory) fit-children → rośnie
        → optionsWindow — fit-children → rośnie
```

##### B.6 Problem z cyklami i rozwiązanie

**Scenariusz niebezpieczny**: Dziecko A anchored do `parent.left` + `parent.right`
→ dziecko rozciąga się na pełną szer. rodzica → mierząc bounding box wychodzi == rodzic
→ brak powiększenia → OK, brak cyklu.

ALE: jeśli dziecko ma `text-auto-resize` + anchors do parent:
- Text rośnie → widget rośnie → parent fit-children → parent rośnie
- Parent rośnie → anchors przeliczane → dziecko rozciąga się (bo left+right) → bounding box = parent
- Brak dalszego powiększenia → STOP

**Rozwiązanie**: W bounding box **ignorować** dzieci anchored do `parent` z OBYDWU stron
(left+right lub top+bottom) — te są "rozciągnięte" i nie definiują wymaganego minimum.
Liczyć tylko dzieci z jednym anchorem lub z `text-auto-resize`.

**Guard na recursion**: Dodać flagę `m_fitChildrenUpdating`:
```cpp
if (m_fitChildrenUpdating)
    return changed;
m_fitChildrenUpdating = true;
// ... obliczenia ...
m_fitChildrenUpdating = false;
```

##### B.7 Pliki do modyfikacji (opcja B)

| Plik | Zmiana |
|---|---|
| `uianchorlayout.h` | Dodać: `m_fitChildrenWidth`, `m_fitChildrenHeight`, `m_fitChildrenUpdating`, `setFitChildren()`, `applyStyle()` override |
| `uianchorlayout.cpp` | Dodać: `applyStyle()`, bounding box obliczenie w `internalUpdate()` |
| `uiwidget.h` | Brak zmian |
| `uiwidget.cpp` | Brak zmian |
| `luafunctions.cpp` | Opcjonalnie: expose `setFitChildren` na Lua |

**Ryzyko**: ŚREDNIE — deferred resize + guard na recursion powinny zapobiec cyklom.
Ale wymaga dokładnych testów na wielu konfiguracjach anchors.

**Zaleta**: Działanie automatyczne — wystarczy dodać `fit-children: true` w OTUI, nie
trzeba pisać żadnego kodu Lua, nie trzeba ręcznie przeliczać. Każdy widget z tym flagiem
automatycznie dopasowuje się do dzieci.

---

#### Podejście C: PropAutoFitParent — dziecko informuje rodzica (C++) — SZCZEGÓŁOWA ANALIZA

##### C.1 Idea

Odwrotny kierunek niż `fit-children`: zamiast rodzic mierzy dzieci, to **dziecko** mówi
rodzicowi "jestem za duże, powiększ się". Nowa properta `auto-fit-parent: true` na dziecku.

##### C.2 Nowe flagi w FlagProp

```cpp
enum FlagProp : uint32_t
{
    // ... istniejące (0-26) ...
    PropAutoFitParentWidth = 1 << 27,   // NOWE
    PropAutoFitParentHeight = 1 << 28,  // NOWE
};
```

##### C.3 Mechanizm działania

Gdy widget z `PropAutoFitParentWidth/Height` zmienia rozmiar (w `setRect()`), sprawdza
czy jego nowy rozmiar przekracza przestrzeń rodzica i jeśli tak — powiększa rodzica.

```cpp
// W UIWidget::setRect() — NOWY KOD po linii 1067 (po m_rect = clampedRect):
bool UIWidget::setRect(const Rect& rect)
{
    // ... istniejący clamp + early return ...

    Rect oldRect = m_rect;
    m_rect = clampedRect;

    // NOWY: auto-fit-parent propagation
    if (hasProp(PropAutoFitParentWidth) || hasProp(PropAutoFitParentHeight)) {
        if (const auto& parent = getParent()) {
            autoFitParent(parent);
        }
    }

    // updates own layout
    updateLayout();
    // ... reszta istniejącego kodu ...
}
```

##### C.4 Metoda autoFitParent()

```cpp
void UIWidget::autoFitParent(const UIWidgetPtr& parent)
{
    if (!parent || parent->isDestroyed())
        return;

    const auto& parentPaddingRect = parent->getPaddingRect();
    bool needsResize = false;
    int newParentWidth = parent->getWidth();
    int newParentHeight = parent->getHeight();

    if (hasProp(PropAutoFitParentWidth)) {
        // Oblicz ile przestrzeni dziecko potrzebuje
        int childRight = getRect().right() + getMarginRight();
        int parentContentRight = parentPaddingRect.right();
        
        if (childRight > parentContentRight) {
            int overflow = childRight - parentContentRight;
            newParentWidth += overflow;
            needsResize = true;
        }
    }

    if (hasProp(PropAutoFitParentHeight)) {
        int childBottom = getRect().bottom() + getMarginBottom();
        int parentContentBottom = parentPaddingRect.bottom();
        
        if (childBottom > parentContentBottom) {
            int overflow = childBottom - parentContentBottom;
            newParentHeight += overflow;
            needsResize = true;
        }
    }

    if (needsResize) {
        // DEFERRED — unika recursion w setRect() → updateLayout() → setRect()
        g_dispatcher.deferEvent([parent, newParentWidth, newParentHeight] {
            if (!parent->isDestroyed())
                parent->resize(newParentWidth, newParentHeight);
        });
    }
}
```

##### C.5 Kaskadowa propagacja

Jeśli rodzic (np. Button) też ma `auto-fit-parent`, to gdy on się powiększy:
1. `parent->resize()` → `setRect()`
2. W `setRect()` sprawdza `PropAutoFitParentWidth` → tak → wywołuje `autoFitParent(grandparent)`
3. Itd. aż do korzenia (MainWindow)

```
Title (text-auto-resize + auto-fit-parent: true)
  → Title rośnie → autoFitParent(Button)
    → Button rośnie → autoFitParent(OptionsCategory)
      → OptionsCategory rośnie → autoFitParent(optionsTabBar)
        → optionsTabBar rośnie → autoFitParent(optionsWindow)
          → optionsWindow rośnie → STOP (brak PropAutoFitParent)
```

##### C.6 Parser OTUI

W `uiwidgetbasestyle.cpp` (po linii 101 — po `max-height`):
```cpp
else if (node->tag() == "auto-fit-parent")
    setAutoFitParent(node->value<bool>());
else if (node->tag() == "auto-fit-parent-width")
    setProp(PropAutoFitParentWidth, node->value<bool>());
else if (node->tag() == "auto-fit-parent-height")
    setProp(PropAutoFitParentHeight, node->value<bool>());
```

Użycie w OTUI:
```yaml
Label
  id: Title
  text-auto-resize: true
  auto-fit-parent: true     # ← NOWE: gdy tekst urośnie, powiększ rodzica

UIWidget
  id: Button
  auto-fit-parent: true     # ← kaskada: Button → OptionsCategory

OptionsCategory < UIWidget
  auto-fit-parent: true     # ← kaskada: OptionsCategory → sidebar

UIWidget
  id: optionsTabBar
  auto-fit-parent-width: true  # ← sidebar → okno (tylko szerokość)
```

##### C.7 Nowe metody w UIWidget

```cpp
// uiwidget.h
void setAutoFitParent(bool enabled);
void setAutoFitParentWidth(bool enabled) { setProp(PropAutoFitParentWidth, enabled); }
void setAutoFitParentHeight(bool enabled) { setProp(PropAutoFitParentHeight, enabled); }
bool isAutoFitParent() { return hasProp(PropAutoFitParentWidth) || hasProp(PropAutoFitParentHeight); }

// uiwidget.cpp
void UIWidget::setAutoFitParent(bool enabled) {
    setProp(PropAutoFitParentWidth, enabled);
    setProp(PropAutoFitParentHeight, enabled);
}
```

##### C.8 Lua bindings

```cpp
// luafunctions.cpp
g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParent", &UIWidget::setAutoFitParent);
g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParentWidth", &UIWidget::setAutoFitParentWidth);
g_lua.bindClassMemberFunction<UIWidget>("setAutoFitParentHeight", &UIWidget::setAutoFitParentHeight);
g_lua.bindClassMemberFunction<UIWidget>("isAutoFitParent", &UIWidget::isAutoFitParent);
```

##### C.9 Problem z cyklami i rozwiązanie

**Scenariusz niebezpieczny**: 
- Dziecko anchored `left+right` do parent → zmiana rozmiaru parent → przeliczenie anchors → dziecko się rozciąga → dziecko ma auto-fit-parent → chce powiększyć parent → ...

**Rozwiązanie**: W `autoFitParent()` sprawdzać czy dziecko jest **anchored do parent z obydwu stron**:
```cpp
void UIWidget::autoFitParent(const UIWidgetPtr& parent)
{
    // Nie powiększaj rodzica jeśli jestem rozciągnięty na jego pełną szerokość/wysokość
    if (isAnchored()) {
        if (const auto& anchorLayout = parent->getAnchoredLayout()) {
            auto it = anchorLayout->getAnchorsGroup().find(static_self_cast<UIWidget>());
            if (it != anchorLayout->getAnchorsGroup().end()) {
                bool anchoredLeftToParent = false, anchoredRightToParent = false;
                bool anchoredTopToParent = false, anchoredBottomToParent = false;
                
                for (const auto& anchor : it->second->getAnchors()) {
                    auto hookedWidget = anchor->getHookedWidget(static_self_cast<UIWidget>(), parent);
                    if (hookedWidget == parent) {
                        if (anchor->getAnchoredEdge() == Fw::AnchorLeft) anchoredLeftToParent = true;
                        if (anchor->getAnchoredEdge() == Fw::AnchorRight) anchoredRightToParent = true;
                        if (anchor->getAnchoredEdge() == Fw::AnchorTop) anchoredTopToParent = true;
                        if (anchor->getAnchoredEdge() == Fw::AnchorBottom) anchoredBottomToParent = true;
                    }
                }
                
                // Jeśli rozciągnięty na obie strony — NIE powiększaj w tej osi
                if (anchoredLeftToParent && anchoredRightToParent && hasProp(PropAutoFitParentWidth))
                    return; // skip width fit
                if (anchoredTopToParent && anchoredBottomToParent && hasProp(PropAutoFitParentHeight))
                    return; // skip height fit
            }
        }
    }
    // ... reszta logiki powiększania ...
}
```

##### C.10 Pliki do modyfikacji (opcja C)

| Plik | Zmiana |
|---|---|
| `uiwidget.h` | Dodać: `PropAutoFitParentWidth` (1<<27), `PropAutoFitParentHeight` (1<<28), metody `setAutoFitParent()`, `autoFitParent()`, `isAutoFitParent()` |
| `uiwidget.cpp` | Dodać: `autoFitParent()` impl, modyfikacja `setRect()` — wywołanie autoFitParent po zmianie rect |
| `uiwidgetbasestyle.cpp` | Dodać: parser `auto-fit-parent`, `auto-fit-parent-width`, `auto-fit-parent-height` |
| `luafunctions.cpp` | Dodać: 4 nowe Lua bindings |
| .otui pliki | Dodać: `auto-fit-parent: true` na elementach hierarchii |

---

### Porównanie B vs C

| Cecha | B (fit-children na layout) | C (auto-fit-parent na widget) |
|---|---|---|
| **Zmiany C++** | 2 pliki (anchor layout .h/.cpp) | 4 pliki (widget .h/.cpp, basestyle, luafunctions) |
| **Kierunek propagacji** | Rodzic mierzy dzieci (top-down) | Dziecko informuje rodzica (bottom-up) |
| **Granularność** | Per-layout (jeden flag na cały kontener) | Per-widget (każde dziecko osobno) |
| **Kaskada** | Automatyczna przez istniejący updateLayout→parent | Jawna: dziecko→rodzic→dziadek, każdy musi mieć flag |
| **Ochrona przed cyklami** | Guard flag `m_fitChildrenUpdating` | Sprawdzanie dual-anchored do parent |
| **OTUI użycie** | `layout: { fit-children: true }` na kontenerze | `auto-fit-parent: true` na każdym elemencie łańcucha |
| **Kompatybilność** | Wzorzec identyczny jak w UIBoxLayout | Nowy wzorzec, ale spójny z PropFlags |
| **Ryzyko** | ŚREDNIE — bounding box w anchor może być nieprecyzyjny | NISKIE — deferred + dual-anchor guard |
| **Uniwersalność** | Działa automatycznie na WSZYSTKIE dzieci kontenera | Precyzyjne: tylko oznaczone elementy propagują |

**REKOMENDACJA**: Podejście **C (PropAutoFitParent)** jest lepsze ponieważ:
1. Bardziej precyzyjne — tylko elementy z tłumaczeniami potrzebują propagacji
2. Nie wymaga zmiany layoutu — anchor layout zostaje jak jest
3. Łatwiejsze do debugowania — wiadomo który widget propaguje
4. Niższe ryzyko regresji — nie zmienia logiki layoutu
5. Spójne z istniejącym systemem PropFlags (TextAutoResize, FixedSize itd.)
6. Kaskada jest jawna i kontrolowana

### 9.4 Rekomendacja: Podejście A (czyste Lua)

**Dlaczego**:
1. Panel ustawień otwiera się RAZ — nie jest to real-time UI
2. Obliczenie rozmiarów to jednorazowa operacja w `configureCharacterCategories()`
3. Lua API jest kompletne — mamy `getTextSize()`, `setWidth()`, `setHeight()`
4. 9-patch tła automatycznie się rozciągają — graficznie wszystko będzie spójne
5. Brak zmian C++ = brak ryzyka regresji build/rendering
6. Łatwe do rozszerzenia na inne panele

### 9.5 Szczegółowy plan implementacji

#### Faza 1: OTUI — zamiana `size:` na `min-width`/`height` + auto-resize

**`options.otui` — OptionsCategory**:
```diff
 OptionsCategory < UIWidget
-  size: 115 22
+  min-width: 115
+  height: 22
   image-source: /images/game/actionbar/1pixel-down-frame
   image-border: 5
   UIWidget
     id: Button
-    size: 115 20
+    anchors.left: parent.left
+    anchors.right: parent.right
+    height: 20
```

**`10-buttons.otui` — Button/QtButton**:
```diff
 Button < UIButton
   font: noto-12
-  size: 106 23
+  min-width: 106
+  height: 23
+  text-horizontal-auto-resize: true
```

**`general.otui` — hotkeysButton**:
```diff
   QtButton
     id: hotkeysButton
-    size: 120 20
+    min-width: 120
+    height: 20
+    text-horizontal-auto-resize: true
```

**`options.otui` — OptionCheckBox**:
```diff
 OptionCheckBox < QtCheckBox
   anchors.left: parent.left
   anchors.right: parent.right
   anchors.top: parent.top
   color: #c0c0c0ff
+  text-wrap: true
```

#### Faza 2: Lua — kaskadowe przeliczanie rozmiarów

W `options.lua` — nowa funkcja `adjustLayoutForTranslations()` wywoływana na końcu
`configureCharacterCategories()`:

1. Iteruj po wszystkich kategoriach sidebar
2. Zmierz `getTextSize()` każdego Title
3. Oblicz `maxNeededWidth` = max(icon + text + arrow + margins)
4. Jeśli `maxNeededWidth > 115`:
   - Ustaw `OptionsCategory:setWidth(maxNeededWidth)`
   - Ustaw `Button:setWidth(maxNeededWidth)`
   - Ustaw `optionsTabBar:setWidth(maxNeededWidth + 13)`
   - Ustaw `optionsWindow:setWidth(686 + (maxNeededWidth - 115))`

#### Faza 3: kategorie sidebar — owinięcie w tr()

W `options.lua` zamienić:
```lua
-- PRZED:
text = "Controls"
-- PO:
text = tr("category_controls")
```

I dodać klucze do plików i18n.

#### Faza 4: Panele treści — SmallReversedQtPanel

Dla paneli z checkboxami i sliderami:
- Checkboxy mają `anchors.left/right` = pełna szer. → wystarczy `text-wrap: true`
- SmallReversedQtPanel `height: 22` → zmienić na `min-height: 22` + Lua callback
- OptionScaleScroll: zmniejszyć scrollbar width z 174 na 150

---

## 10. Dalsze kroki

1. **Implementacja Fazy 1**: Zmiany OTUI (min-width, auto-resize, text-wrap)
2. **Implementacja Fazy 2**: Funkcja Lua `adjustLayoutForTranslations()`
3. **Implementacja Fazy 3**: tr() dla kategorii sidebar
4. **Implementacja Fazy 4**: SmallReversedQtPanel elastyczność
5. **Push**: Font rendering fixes + UI layout fixes → GitHub Actions build
6. **Testy**: Sprawdzenie wyglądu w en, ru, pl, zh
