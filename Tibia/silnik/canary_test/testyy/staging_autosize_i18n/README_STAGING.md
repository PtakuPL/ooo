# Staging: Auto-size i18n + Warning fixes — Gotowe do push na `feature/i18n-multilanguage`
**Data przygotowania**: 2026-02-22  
**Status**: OCZEKUJE na wynik build'a Windows commitu `e74e30ad5` (letter fix)  
**Build Linux**: ✅ PRZESZEDŁ (2 warningi — fixy w tym staging)  
**Build Windows**: 🔄 W TOKU  
**NIE PUSHOWAĆ** dopóki build Windows letter fix nie przejdzie!

---

## Jak pushować (po przejściu buildu letter fix)

```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy

# 0. NAJPIERW: Skopiuj fixy warningów (commit osobno przed auto-size)
cp staging_autosize_i18n/src/framework/text/TextShaper.cpp src/framework/text/TextShaper.cpp
cp staging_autosize_i18n/src/main.cpp src/main.cpp
git add src/framework/text/TextShaper.cpp src/main.cpp
git commit -m "fix(warnings): handle fribidi_reorder_line return value, fix g_client shared_ptr UB

- TextShaper.cpp: check fribidi_reorder_line return value (-Wunused-result)
- main.cpp: use no-op deleter for global g_client shared_ptr (-Wfree-nonheap-object)
  Prevents undefined behavior: delete on non-heap global object"
git push origin feature/i18n-multilanguage

# 1. PO PRZEJŚCIU BUILDU WARNINGÓW: Skopiuj pliki auto-size
cp staging_autosize_i18n/data/styles/10-buttons.otui data/styles/10-buttons.otui
cp staging_autosize_i18n/modules/client_options/options.otui modules/client_options/options.otui
cp staging_autosize_i18n/modules/client_options/options.lua modules/client_options/options.lua
cp staging_autosize_i18n/modules/client_options/styles/controls/general.otui modules/client_options/styles/controls/general.otui
cp staging_autosize_i18n/modules/client_options/styles/graphics/graphics.otui modules/client_options/styles/graphics/graphics.otui
cp staging_autosize_i18n/modules/client_options/styles/graphics/effects.otui modules/client_options/styles/graphics/effects.otui
cp staging_autosize_i18n/modules/client_options/styles/interface/interface.otui modules/client_options/styles/interface/interface.otui
cp staging_autosize_i18n/modules/client_options/styles/interface/console.otui modules/client_options/styles/interface/console.otui
cp staging_autosize_i18n/modules/client_options/styles/interface/HUD.otui modules/client_options/styles/interface/HUD.otui
cp staging_autosize_i18n/modules/client_options/styles/sound/audio.otui modules/client_options/styles/sound/audio.otui
cp staging_autosize_i18n/modules/client_options/styles/misc/misc.otui modules/client_options/styles/misc/misc.otui

# 2. Dodaj pliki
git add data/styles/10-buttons.otui \
  modules/client_options/options.otui \
  modules/client_options/options.lua \
  modules/client_options/styles/controls/general.otui \
  modules/client_options/styles/graphics/graphics.otui \
  modules/client_options/styles/graphics/effects.otui \
  modules/client_options/styles/interface/interface.otui \
  modules/client_options/styles/interface/console.otui \
  modules/client_options/styles/interface/HUD.otui \
  modules/client_options/styles/sound/audio.otui \
  modules/client_options/styles/misc/misc.otui

# 3. Commit
git commit -m "feat(i18n): auto-size buttons, sidebar, text-wrap panels + tr() categories

- Add I18NButton/I18NQtButton styles with text-horizontal-auto-resize
- Options sidebar: min-width + adjustSidebarWidth() dynamic resize
- Options window: auto-grow when sidebar expands
- All SmallReversedQtPanel checkboxes: text-wrap + text-vertical-auto-resize
- Wrap all sidebar category names in tr() for translation
- Close button uses I18NQtButton"

# 4. Push
git push origin feature/i18n-multilanguage
```

---

## Lista zmian (13 plików: 2 C++ warning fixes + 11 auto-size OTUI/Lua)

### Warning fixes (commit osobny — PRZED auto-size!)
| Plik | Zmiana |
|------|--------|
| `src/framework/text/TextShaper.cpp` | Sprawdzenie return value `fribidi_reorder_line()` — eliminuje `-Wunused-result` |
| `src/main.cpp` | No-op deleter dla `ApplicationDrawEventsPtr(&g_client, ...)` — eliminuje `-Wfree-nonheap-object` i naprawia **UB** (delete na globalnym obiekcie) |

### Faza A-1: Style przycisków i18n
| Plik | Zmiana |
|------|--------|
| `data/styles/10-buttons.otui` | Dodano `I18NButton` i `I18NQtButton` — dziedziczą od Button/QtButton + `text-horizontal-auto-resize: true` + `min-width: 106` |

### Faza A-2: Sidebar auto-resize
| Plik | Zmiana |
|------|--------|
| `modules/client_options/options.otui` | `optionsTabBar`: `size: 128 453` → `min-width: 128`, `width: 128` (bez height anchor). Przycisk Close: `QtButton` → `I18NQtButton`. `OptionsCategory`: `size: 115 22` → `min-width: 115`, `height: 22` |
| `modules/client_options/options.lua` | Nowa funkcja `adjustSidebarWidth()` — mierzy tekst w kategoriach, ustawia szerokość sidebar, propaguje do okna głównego |

### Faza A-3: Text-wrap w panelach opcji
| Plik | Zmiana |
|------|--------|
| `styles/controls/general.otui` | Checkboxy: `text-wrap: true`. Panele: `height: 22` → `min-height: 22` + `text-vertical-auto-resize: true`. Button hotkeys: `QtButton` → `I18NQtButton` |
| `styles/graphics/graphics.otui` | jw. dla paneli grafiki |
| `styles/graphics/effects.otui` | jw. dla paneli efektów |
| `styles/interface/interface.otui` | jw. dla paneli interfejsu |
| `styles/interface/console.otui` | jw. dla paneli konsoli |
| `styles/interface/HUD.otui` | jw. dla paneli HUD |
| `styles/sound/audio.otui` | jw. dla paneli audio |
| `styles/misc/misc.otui` | jw. dla paneli misc |

### Faza A-4: tr() dla kategorii sidebar
| Plik | Zmiana |
|------|--------|
| `modules/client_options/options.lua` | `text = "Controls"` → `text = tr("Controls")`, `text = "Interface"` → `text = tr("Interface")`, itd. dla wszystkich kategorii i subkategorii |

---

## Kluczowe zmiany techniczne

### `adjustSidebarWidth()` (options.lua)
```lua
function adjustSidebarWidth()
    local sidebar = controller.ui.optionsTabBar
    local maxWidth = 128
    for i = 1, sidebar:getChildCount() do
        local widget = sidebar:getChildByIndex(i)
        -- mierzy szerokość tytułu + margines
        local tw = titleLabel:getTextSize().width + 50
        maxWidth = math.max(maxWidth, tw)
        -- sprawdza też subkategorie
    end
    sidebar:setWidth(maxWidth)
    -- propaguje delta do okna głównego
    window:setWidth(686 + delta)
end
```

### `I18NButton` / `I18NQtButton` (10-buttons.otui)
```otui
I18NButton < Button
  text-horizontal-auto-resize: true
  min-width: 106

I18NQtButton < QtButton
  text-horizontal-auto-resize: true
  min-width: 106
```

### Panel text-wrap pattern
```otui
SmallReversedQtPanel
  min-height: 22                      // zamiast height: 22
  text-vertical-auto-resize: true     // nowe — panel rośnie gdy tekst się zawija

  OptionCheckBox
    text-wrap: true                   // nowe — tekst się zawija zamiast obcinać
```
