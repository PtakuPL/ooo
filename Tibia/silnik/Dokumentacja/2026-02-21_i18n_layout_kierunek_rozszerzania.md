# I18N Layout — Kierunek rozszerzania widgetów: analiza, zależności, architektura
**Data**: 2026-02-21  
**Status**: Analiza + Plan architektoniczny  
**Dotyczy**: OTClient — system auto-resize w kontekście i18n, mechanizm anchorów, propagacja rozmiaru  
**Bazuje na**: `2026-02-17_i18n_ui_layout_auto_resize.md` (rozbudowa)

---

## 1. Problem: „Losowy" kierunek rozszerzania

Obecna implementacja i18n layoutu jest **hybrydowa**:
- Część globalnych stylów (`I18NButton`, `I18NQtButton`) z `text-horizontal-auto-resize: true`
- Część ręcznych override'ów per język (`data/i18n_layout/de.lua`, `ru.lua`, `es.lua`, `fr.lua`)
- Większość widgetów ma **stały `size:`** bez żadnego auto-resize

To powoduje, że kierunek rozszerzania jest niespójny i zależy od anchorów konkretnego widgetu — a nie od intencji projektanta UI.

---

## 2. Skąd silnik „wie" w którą stronę rozszerzać

### 2.1 Mechanizm w C++ (`uianchorlayout.cpp`)

Silnik **nie wie** w którą stronę rozszerzać na podstawie języka czy długości tekstu. Wie **wyłącznie** z anchorów i layoutu:

```
anchors.right: parent.right   → trzyma prawą krawędź → wzrost szerokości idzie W LEWO
anchors.left: parent.left     → trzyma lewą krawędź  → wzrost szerokości idzie W PRAWO
anchors.left + anchors.right  → widget jest ROZCIĄGANY między krawędziami (stała pozycja, zmienna szerokość)
```

Kod odpowiedzialny — `uianchorlayout.cpp` linie 228-265:

```cpp
case Fw::AnchorLeft:
    if (!horizontalMoved) {
        newRect.moveLeft(point + widget->getMarginLeft());   // przesuwa cały rect aby left = punkt
        horizontalMoved = true;
    } else
        newRect.setLeft(point + widget->getMarginLeft());    // ROZCIĄGA — ustawia lewą krawędź
    break;
case Fw::AnchorRight:
    if (!horizontalMoved) {
        newRect.moveRight(point - widget->getMarginRight()); // przesuwa cały rect aby right = punkt
        horizontalMoved = true;
    } else
        newRect.setRight(point - widget->getMarginRight());  // ROZCIĄGA — ustawia prawą krawędź
    break;
```

**Kluczowa reguła**: Pierwszy anchor (`!horizontalMoved`) **przesuwa** rect. Drugi anchor **rozciąga** rect. Kolejność anchorów w OTUI definiuje kierunek.

### 2.2 Auto-resize w C++ (`uiwidgettext.cpp`)

Gdy `text-horizontal-auto-resize: true`, metoda `updateText()` oblicza rozmiar tekstu i wstawia go jako nowy `size`:

```cpp
// uiwidgettext.cpp:67-79
if (hasProp(PropTextHorizontalAutoResize) || hasProp(PropTextVerticalAutoResize)) {
    Size textBoxSize = m_textSize;
    textBoxSize += Size(padding.left + padding.right, padding.top + padding.bottom) + textOffset;
    textBoxSize *= std::max<float>(fontScale, 1.f);
    
    if (hasProp(PropTextHorizontalAutoResize) && !isTextWrap())
        size.setWidth(textBoxSize.width());     // ← szerokość = rozmiar tekstu
    
    setSize(size);  // ← to triggeruje anchor layout przeliczenie
}
```

Następnie `setSize()` → `setRect()` → `updateLayout()` → rodzic przelicza pozycje dzieci przez anchory.

### 2.3 Łańcuch zdarzeń

```
setText("Czat wyłączony")
  → updateText()
    → m_textSize = font->calculateTextRectSize("Czat wyłączony")  // np. 112px
    → setSize(112, 18)    // było 64×18
      → setRect()
        → updateLayout()
          → parent->getLayout()->updateLater()
            → UIAnchorLayout przelicza pozycje SĄSIADÓW
              → consoleTextEdit (anchored right: toggleChat.left) 
                  → jego prawa krawędź przesuwa się W LEWO
```

---

## 3. Konkretny przykład: przycisk „Czatuj dalej" w console.otui

### 3.1 Obecna definicja

```yaml
# console.otui, linia ~346
TopToggleButton
  id: toggleChat
  anchors.right: parent.right     # ← przypiętY DO PRAWEJ krawędzi rodzica
  anchors.bottom: parent.bottom
  margin-bottom: 3
  size: 64 18                     # ← STAŁY rozmiar — 64px szerokosc
  !text: tr("otclient_modules.console_otui.tr_12")
```

### 3.2 Tłumaczenia i ich długości

| Język | Klucz tr_12 (off) | Klucz tr_11 (on) | Klucz tr_10 (off toggle) |
|---|---|---|---|
| EN | "Chat Off" (8 zn.) | "Chat On" (7 zn.) | "Chat Off" (8 zn.) |
| PL | "Czat wyłączony" (15 zn.) | "Czatuj dalej" (13 zn.) | "Czat wyłączony" (15 zn.) |
| RU | "Чат Off" (7 zn.) | "Чат On" (6 zn.) | "Чат Off" (7 zn.) |
| DE | "[EN] Chat Off" (14 zn.) | "[EN] Chat On" (13 zn.) | — (nieprzetłumaczone) |

**Efekt**: Przy `size: 64 18` tekst "Czat wyłączony" jest **ucinany** — potrzeba ~112px.

### 3.3 Zależności anchorowe (łańcuch widgetów)

```
[sayModeButton] ←anchors.left: parent.left
    ↓
[consoleTextEdit] ←anchors.left: sayModeButton.right
                  ←anchors.right: toggleChat.left    ← ZALEŻNOŚĆ OD ROZMIARU toggleChat
    ↓
[toggleChat] ←anchors.right: parent.right            ← PRZYPIĘTY DO PRAWEJ
```

**Wniosek**: Gdy `toggleChat` dostanie auto-resize, rozszerzy się **w lewo** (bo `anchors.right` trzyma prawą krawędź). `consoleTextEdit` automatycznie się **skurczy** z prawej strony — bo jego prawa krawędź jest anchored do `toggleChat.left`. To jest **poprawne** zachowanie.

### 3.4 Poprawka

```yaml
TopToggleButton
  id: toggleChat
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  margin-bottom: 3
  text-horizontal-auto-resize: true   # ← ZAMIAST stałego size
  min-width: 64                        # ← minimum = angielski tekst
  max-width: 150                       # ← max aby nie zjeść całego inputa
  height: 18
  !text: tr("otclient_modules.console_otui.tr_12")
```

---

## 4. Mapa zależności anchorowych — kto od kogo zależy

### 4.1 Console (game_console/console.otui)

```
parent (consolePanel)
  ├─ sayModeButton
  │    anchors.left: parent.left
  │    anchors.bottom: parent.bottom
  │    size: 18 18 (ikonka — STAŁY, OK)
  │
  ├─ consoleTextEdit
  │    anchors.left: sayModeButton.right    ← zależy od sayModeButton
  │    anchors.right: toggleChat.left       ← ZALEŻY OD toggleChat
  │    anchors.bottom: parent.bottom
  │    height: 18 (tylko wysokość stała, szerokość ELASTYCZNA)
  │
  └─ toggleChat
       anchors.right: parent.right          ← przypiętY do prawej
       anchors.bottom: parent.bottom
       size: 64 18 (STAŁY → powinien być auto-resize)
```

**Kierunek rozszerzania toggleChat**: ← W LEWO (poprawnie)  
**Efekt na consoleTextEdit**: skurczy się z prawej (poprawnie)  
**Efekt na sayModeButton**: BRAK (nie zależy od toggleChat)

### 4.2 Options Sidebar (client_options/options.otui)

```
optionsWindow (MainWindow, size: 686 534 — STAŁY)
  ├─ optionsTabBar (sidebar)
  │    anchors.top/left/bottom: parent
  │    size: 128 453 (STAŁY)
  │    └─ OptionsCategory[]
  │         size: 115 22 (STAŁY)
  │         └─ Button size: 115 20 (STAŁY)
  │
  └─ optionsTabContent (panel)
       anchors.left: optionsTabBar.right    ← ZALEŻY OD SIDEBARA
       anchors.top/right/bottom: parent
```

**Problem**: Jeśli sidebar się poszerzy (np. "Общие горячие клавиши" = 22 zn.), optionsTabContent przesuwa się w prawo → ale okno ma stały rozmiar → content jest UCIĘTY.

**Wymagany łańcuch**:
1. `OptionsCategory` → `text-horizontal-auto-resize: true` + `min-width: 115`
2. `optionsTabBar` → `min-width: 128`, ale musi rosnąć do max dziecka
3. `optionsWindow` → `min-width: 686`, ale musi rosnąć gdy sidebar rośnie

### 4.3 Inventory buttons (game_inventory/inventory.otui)

```
TopToggleButton (12+ instancji — ikony bez tekstu)
  size: 26 26 (ikonki — NIE wymagają auto-resize)
```

**Uwaga**: `TopToggleButton` bazowy styl ma `size: 26 26` — to jest dla **ikon**. W `console.otui` jest użyty z **tekstem** i nadpisanym `size: 64 18`. Nie zmieniaj bazowego stylu — zmień instancję w console.otui.

---

## 5. Trzy warstwy systemu i18n layoutu (obecne)

### Warstwa 1: Style globalne OTUI (10-buttons.otui)

| Styl | Mechanizm | Używa auto-resize? |
|---|---|---|
| `Button` | `size: 106 23` | ❌ STAŁY |
| `QtButton` | `size: 106 23` | ❌ STAŁY |
| `TopToggleButton` | `size: 26 26` | ❌ STAŁY (ikony) |
| `I18NButton` | `min-width: 106`, `text-horizontal-auto-resize: true` | ✅ TAK |
| `I18NQtButton` | `min-width: 106`, `text-horizontal-auto-resize: true` | ✅ TAK |

**Problem**: `I18NButton` istnieje, ale prawie nigdzie nie jest użyty. Widgety nadal dziedziczą po `Button`/`QtButton` ze stałym rozmiarem.

### Warstwa 2: Per-język overrides (i18n_layout.lua + data/i18n_layout/*.lua)

Pliki: `de.lua`, `ru.lua`, `es.lua`, `fr.lua`

Obecna zawartość (DE jako przykład):
```lua
return {
    ["client_options/options"] = {
        ["optionsWindow"] = { ["min-width"] = 740, ["max-width"] = 1120 },
        ["optionsTabBar"] = { ["min-width"] = 178 },
    },
    ["styles/controls/general"] = {
        ["hotkeysButton"] = { ["min-width"] = 188 },
    },
}
```

**Problem**: Trzeba ręcznie definiować dla KAŻDEGO języka × KAŻDEGO widgetu. Nie skaluje się.

### Warstwa 3: Moduł i18n_layout.lua (hook na g_ui.loadUI/displayUI)

Mechanizm:
1. Hookuje `g_ui.loadUI()` i `g_ui.displayUI()` — po załadowaniu każdego UI
2. Rejestruje root widget → szuka overrides dla bieżącego języka
3. Aplikuje `setWidth()`, `setMinWidth()`, `setTextHorizontalAutoResize()` etc.
4. Na zmianę locale → re-aplikuje do zarejestrowanych rootów

**Problem**: Działa reaktywnie (po załadowaniu), a nie deklaratywnie (w OTUI). Override'y nie znają kontekstu anchorów sąsiadów.

---

## 6. Dlaczego podejście hybrydowe daje złe efekty

### 6.1 Brak propagacji child→parent w anchor layout

```
fit-children ISTNIEJE → ale TYLKO w UIVerticalLayout / UIHorizontalLayout
    uiverticallayout.cpp:96:
    if (m_fitChildren && preferredHeight != parentWidget->getHeight()) {
        g_dispatcher.deferEvent([=] { parentWidget->setHeight(preferredHeight); });
    }

fit-children NIE ISTNIEJE → w UIAnchorLayout
    uianchorlayout.cpp: BRAK jakiejkolwiek logiki fit-children
    Anchor layout TYLKO przelicza pozycje dzieci, NIGDY nie zmienia rodzica
```

**Efekt**: Jeśli `OptionsCategory` urośnie bo tekst jest dłuższy — `optionsTabBar` o tym NIE WIE i nie rośnie.

### 6.2 Override per-język bez wiedzy o anchorach

Gdy `de.lua` mówi `["optionsTabBar"] = { ["min-width"] = 178 }`:
- Nie wie, że `optionsTabContent` jest anchored do `optionsTabBar.right`
- Nie wie, czy okno jest wystarczająco szerokie na nowy sidebar
- Jeśli to samo okno otwiera się z DE a potem przełącza na RU → stare wartości mogą kolidować

### 6.3 Stały `size:` koliduje z auto-resize

Jeśli widget ma `size: 64 18` (stały), a `i18n_layout.lua` ustawi `text-horizontal-auto-resize: true`:
- `setText()` wywoła `updateText()` → obliczy rozmiar tekstu → `setSize(textWidth, 18)`
- ALE jeśli OTUI parser wcześniej ustawił `size: 64 18` z `PropFixedSize` → `setSize()` ZIGNORUJE nowy rozmiar
- **To wymaga explicit `size: none`** albo użycia `min-width` + `height` zamiast `size`

---

## 7. Rekomendacja architektoniczna — poprawne podejście

### 7.1 Zasada: jawne reguły per-widget

Zamiast:
- ❌ Globalny auto-resize na wszystkim
- ❌ Per-język override na każdym widgetcie

Lepsze jest:
- ✅ **Jawne:** każdy widget z `tr()` ma w OTUI `text-horizontal-auto-resize: true` + `min-width` + `max-width`
- ✅ **Anchor-aware:** kierunek rozszerzania wynika z anchorów — NIE wymaga dodatkowego kodu
- ✅ **Per-język override TYLKO tam**, gdzie auto-resize nie wystarcza (np. okno za małe globalnie)

### 7.2 Tabela decyzyjna: kiedy co stosować

| Sytuacja | Rozwiązanie | Przykład |
|---|---|---|
| Przycisk z `tr()`, anchored LEFT | `text-horizontal-auto-resize: true` + `min-width` | Rośnie w prawo ✅ |
| Przycisk z `tr()`, anchored RIGHT | `text-horizontal-auto-resize: true` + `min-width` + `max-width` | Rośnie w lewo ✅ |
| Przycisk z `tr()`, anchored LEFT+RIGHT | Usunąć jeden anchor LUB dodać `text-wrap: true` | Rozciągany / zawijany |
| Label w stałym panelu | `text-wrap: true` + `text-vertical-auto-resize: true` | Wieloliniowy |
| Sidebar/kontener z dziećmi auto-resize | Per-język `min-width` override w `i18n_layout.lua` | Sidebar 128→178px |
| Okno główne | `min-width`/`min-height` + ewentualny `max-width` | Rośnie do max |

### 7.3 Priorytet wdrożenia (od najwyższego wpływu)

1. **Console toggleChat** — najczęściej widziany widget, ucina "Czat wyłączony"
2. **Options sidebar OptionsCategory** — kategorie ucinane w każdym języku innym niż EN
3. **hotkeysButton** w general.otui — stały 120px, rosyjski się nie mieści
4. **Options okno** — `size: 686 534` za małe dla DE/RU sidebarów
5. **CheckBox labels** — dodać `text-wrap: true` aby zawijać długi tekst

---

## 8. Zweryfikowane zależności plików

### 8.1 Pliki definicji stylów bazowych

| Plik | Rola | Auto-resize? |
|---|---|---|
| `testyy/data/styles/10-buttons.otui` | `Button`, `QtButton`, `I18NButton`, `I18NQtButton` | Tylko I18N* |
| `testyy/data/styles/20-topmenu.otui` | `TopToggleButton` (ikony 26×26) | ❌ |

### 8.2 Pliki używające `TopToggleButton` z TEKSTEM (wymagają poprawki)

| Plik | Widget ID | Obecny size | Tekst tr() | Kierunek rozszerzania |
|---|---|---|---|---|
| `testyy/modules/game_console/console.otui:346` | `toggleChat` | `64 18` | `tr_12/tr_11/tr_10` | ← lewo (anchors.right) ✅ |

### 8.3 Pliki używające `TopToggleButton` bez tekstu (NIE wymagają poprawki)

| Plik | Ile instancji | Opis |
|---|---|---|
| `testyy/modules/game_inventory/inventory.otui` | 12 | Ikony (attack/follow/PvP) — bez tr() |

### 8.4 Pliki per-język layoutu (obecne overrides)

| Plik | Zawartość |
|---|---|
| `testyy/data/i18n_layout/de.lua` | optionsWindow: min-w 740, sidebar: min-w 178, hotkeys: min-w 188 |
| `testyy/data/i18n_layout/ru.lua` | optionsWindow: min-w 735, sidebar: min-w 174, hotkeys: min-w 184 |
| `testyy/data/i18n_layout/es.lua` | (do sprawdzenia) |
| `testyy/data/i18n_layout/fr.lua` | (do sprawdzenia) |

### 8.5 Moduł sterujący

| Plik | Rola | Linie kluczowe |
|---|---|---|
| `testyy/modules/client_locales/i18n_layout.lua` | Hook na loadUI/displayUI, override applicator | L1-438 |

### 8.6 Silnik C++ — pliki odpowiedzialne

| Plik | Mechanizm |
|---|---|
| `testyy/src/framework/ui/uiwidgettext.cpp:40-79` | `updateText()` — oblicza m_textSize, ustawia rozmiar widgetu |
| `testyy/src/framework/ui/uianchorlayout.cpp:228-265` | Przelicza pozycje anchorowanych widgetów (moveLeft/moveRight/setLeft/setRight) |
| `testyy/src/framework/ui/uiverticallayout.cpp:96-99` | `fit-children` — jedyny mechanizm child→parent resize |

---

## 9. Diagram przepływu — co się dzieje gdy język się zmienia

```
Użytkownik wybiera język PL
  │
  ├─ locales.lua: setLocale("pl")
  │   └─ _G.onLocaleChanged("pl")
  │       └─ i18n_layout.lua: handleLocaleChanged("pl")
  │           ├─ loadLayoutFile("pl") → szuka data/i18n_layout/pl.lua
  │           └─ reapplyRegisteredRoots("pl")
  │               └─ dla każdego zarejestrowanego rootWidget:
  │                   └─ applyOverrides(root, modulePath, "pl")
  │                       └─ per widget: setWidth/setMinWidth/setMaxWidth...
  │
  ├─ Wszystkie tr() zwracają polskie tłumaczenia
  │   └─ Widgety z !text: tr(...) automatycznie dostają nowy tekst
  │       └─ setText("Czat wyłączony")
  │           └─ updateText()
  │               └─ Jeśli text-horizontal-auto-resize:
  │                   └─ setSize(nowySzerokosc, height)
  │                       └─ setRect() → updateLayout()
  │                           └─ Anchor layout przelicza sąsiadów
  │
  └─ BRAK: automatycznej propagacji child→parent (w anchor layout)
      → sidebar NIE rośnie gdy dziecko jest za duże
      → okno NIE rośnie gdy sidebar jest za duży
      → TO wymaga i18n_layout overrides lub box layout z fit-children
```

---

## 10. Podsumowanie decyzji

| Decyzja | Uzasadnienie |
|---|---|
| **NIE** zmieniać bazowego stylu `TopToggleButton` (26×26) | Używany jako ikona w 12+ miejscach w inventory |
| **TAK** zmienić instancję `toggleChat` w console.otui | Jedyne miejsce z tekstem + stałym rozmiarem |
| **TAK** dodać `text-horizontal-auto-resize` per widget | Anchor-aware, kierunek wynika z anchorów |
| **NIE** generować globalnego auto-resize | Psuje widgety z anchors.left+right i stałe ikony |
| **TAK** utrzymać i18n_layout overrides | Dla kontenerów/okien które nie mają auto-resize |
| **NIE** implementować fit-children w anchor layout (na razie) | Duża zmiana C++, ryzyko regresji |

---

## 11. Plan implementacji (propozycja)

### Faza A: Quick wins (tylko OTUI, bez C++)

1. **console.otui toggleChat** → `text-horizontal-auto-resize: true` + `min-width: 64` + `max-width: 150` + `height: 18`
2. **options.otui OptionsCategory** → `min-width: 115` + `text-horizontal-auto-resize: true`
3. **general.otui hotkeysButton** → `min-width: 120` + `text-horizontal-auto-resize: true`

### Faza B: Per-język overrides (Lua)

1. Dodać `pl.lua` do `data/i18n_layout/` z konkretnymi wartościami
2. Zaktualizować istniejące `de.lua`, `ru.lua` z nowymi widgetami
3. Dodać `console.otui toggleChat` do overrides (max-width per lang)

### Faza C: Systemowe (przyszłość, wymaga C++)

1. Opcjonalnie: `fit-children` w anchor layout (propagacja child→parent)
2. Opcjonalnie: `PropAutoFitParent` — dziecko mówi rodzicowi "dopasuj się"
3. Opcjonalnie: Lua callback `onChildResize` → ręczna propagacja w Lua
