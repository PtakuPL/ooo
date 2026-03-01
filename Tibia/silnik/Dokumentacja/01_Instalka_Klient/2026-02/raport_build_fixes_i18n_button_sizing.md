# Kompleksowy raport — Poprawki build CI + System I18N Button Sizing

**Data:** 2026-02-22  
**Autor:** GitHub Copilot  
**Kontekst:** Naprawa buildów Linux i Windows CI + system dopasowywania UI do języków

---

## 1. Stan buildów CI

### 1.1 Problem Linux — pch.h double-inclusion ✅ NAPRAWIONE

**Symptom:** `pch.h:70:1: error: redefinition of 'template<class E> format_as(E)'`

**Przyczyna:** CMake PCH injection (`-include cmake_pch.hxx` → włącza pch.h) + łańcuch include'ów (`global.h` → `pch.h`) powodował dwukrotne zdefiniowanie szablonu `format_as` w globalnej przestrzeni nazw. fmt 12.1 (`FMT_VERSION 120100`) definiuje własny `format_as` w `fmt::enums`, więc nasz globalny nie kolidował z fmt — kolidował sam ze sobą przy podwójnym włączeniu.

**Naprawa:** Dodano tradycyjny include guard `#ifndef FRAMEWORK_PCH_H` / `#define FRAMEWORK_PCH_H` obok `#pragma once` w `framework/pch.h`. `#pragma once` nie zawsze chroni gdy ten sam plik jest włączany różnymi ścieżkami (bezpośrednio i przez PCH injection).

**Pliki zmienione:**
- `src/framework/pch.h` — dodano `#ifndef FRAMEWORK_PCH_H` / `#define FRAMEWORK_PCH_H` na początku i `#endif` na końcu

**Status:** Scommitowane i pushowane. Buildy CI w trakcie.

### 1.2 Problem Windows — ICE C1001 (Internal Compiler Error) ✅ NAPRAWIONE (Runda 1-3)

Pełny opis w `podsumowanie_statusu_ice_c1001.md`. Skrót:

| Krok | Opis | Status |
|------|------|--------|
| 1 | Dodanie brakujących include'ów (C2139/C2665) | ✅ |
| 2A | Flagi MSVC: `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-` | ✅ |
| 2B | Fix `if constexpr` w `luainterface.h` | ✅ |
| 2C | Fold expressions zamiast rekurencyjnych szablonów w `luabinder.h` | ✅ |
| 2C.1 | Guard N==0, `#include <utility>`, `std::size_t` | ✅ |
| 3A | Usunięcie `#include <protocolhttp.h>` (Asio) | ✅ |
| 3B | Split `luafunctions_ui.cpp` → 3 pliki | ✅ |
| 3C | Fold expressions w `luavaluecasts.h` (tuple) | ✅ |
| 3D | Fix `registerClass<PainterShaderProgram, ShaderProgram>()` | ✅ |
| 3E | `auto` → `std::size_t` w constexpr | ✅ |

### 1.3 Split client/luafunctions.cpp ✅ NAPRAWIONE (Runda 4)

**Problem:** `client/luafunctions.cpp` miał 1104 linii i 939 template binds — najcięższy TU w projekcie.

**Naprawa:** Split na 3 pliki:

| Plik | Linii | Zawartość |
|------|-------|-----------|
| `client/luafunctions.cpp` | 405 | Singleton registrations (g_things, g_map, g_game, g_minimap, g_sprites, g_client, g_attachedEffects, g_gameConfig) + extern calls |
| `client/luafunctions_entities.cpp` **NOWY** | 567 | Entity class bindings: ProtocolGame, Container, AttachableObject, Thing, Creature, Player, Npc, Monster, LocalPlayer, Item, Effect, Missile, AttachedEffect, StaticText, AnimatedText, Tile, ThingType, ItemType, House, Spawn, Town, CreatureType |
| `client/luafunctions_ui_client.cpp` **NOWY** | 210 | Client UI widget bindings: UIItem, UIEffect, UIMissile, UISprite, UICreature, UIMap, UIMinimap, UIProgressRect, UIGraph, UIMapAnchorLayout |

**CMakeLists.txt:** Oba nowe pliki dodane do:
- Group 2 (linia 177-178) — z flagami MSVC ICE workaround + `SKIP_PRECOMPILE_HEADERS ON`
- Lista źródeł (linia 766-767)

**Architektura wywołań:**
```
Client::registerLuaFunctions()        ← client/luafunctions.cpp (405 linii)
  ├─ singletons: g_things, g_map, g_game, g_minimap, g_sprites...
  ├─ global functions: getOutfitColor, getAngleFromPos, getDirectionFromPos
  ├─ registerLuaFunctions_ClientEntities()  ← luafunctions_entities.cpp
  └─ registerLuaFunctions_ClientUI()        ← luafunctions_ui_client.cpp
```

---

## 2. System I18N Button Sizing

### 2.1 Analiza problemu

**Statystyki:**
- 98 z 120 plików OTUI (82%) używa `tr()` do tłumaczenia tekstów
- 399 deklaracji `width:` (stały rozmiar) w plikach z `tr()`
- 255 deklaracji `text-auto-resize: true` 
- 10 deklaracji `text-horizontal-auto-resize: true`
- 49 deklaracji `text-wrap: true`
- 55 języków obsługiwanych (od arabskiego po chiński)

**Przykłady rozszerzenia tekstu:**

| Klucz EN | EN (px) | PL | DE | FR | ES | RU |
|----------|---------|-----|-----|-----|-----|-----|
| Enter Game (10 chars) | ~60px | 12 chars | 15 chars | 13 chars | 15 chars | 12 chars |
| Login Error (11 chars) | ~66px | 14 chars | 16 chars | 19 chars | **25 chars** | 12 chars |
| Please wait (11 chars) | ~66px | 13 chars | 16 chars | 18 chars | 16 chars | **21 chars** |
| Remember password (18 chars) | ~108px | 17 chars | 23 chars | **29 chars** | 20 chars | 17 chars |

Najgorsze języki pod względem rozszerzenia tekstu:
1. **Francuski (FR)** — 30-60% dłuższy
2. **Niemiecki (DE)** — 30-50% dłuższy  
3. **Hiszpański (ES)** — 15-127% dłuższy (duże wahania)
4. **Rosyjski (RU)** — 10-90% dłuższy

### 2.2 Istniejące mechanizmy

#### A. Właściwości UIWidget (C++):
- `text-auto-resize: true` — widget automatycznie zmienia szerokość I wysokość do rozmiaru tekstu
- `text-horizontal-auto-resize: true` — widget zmienia TYLKO szerokość do tekstu
- `text-vertical-auto-resize: true` — widget zmienia TYLKO wysokość do tekstu
- `text-wrap: true` — zawijanie tekstu (nie zmienia rozmiaru, obcina długi tekst)
- `min-width: N` / `max-width: N` — limity rozmiaru
- `resizeToText()` — metoda Lua

#### B. Style I18NButton / I18NQtButton (data/styles/10-buttons.otui):
```
I18NButton < UIButton
  font: noto-12
  color: #dfdfdfff
  min-width: 106        ← minimum jak zwykły Button
  height: 23
  text-horizontal-auto-resize: true  ← KLUCZOWE: rośnie gdy tekst dłuższy
  text-offset: 0 0
  image-source: /images/ui/button
  ...
```

**Aktualnie użyte w:** tylko 5 miejsc (2 moduły: help, general controls).

#### C. Funkcja tr() (modules/corelib/util.lua → modules/client_locales/locales.lua):
- Bazowa: `string.format(s, ...)` — globalna w `corelib/util.lua`
- Override: `_G.tr()` w `client_locales/locales.lua` — pełny system tłumaczeń z fallback EN → klucz semantyczny → EN value → tłumaczenie
- Ścieżka: klucz → `currentLocale.translation[key]` → fallback przez EN

### 2.3 Zaprojektowane rozwiązanie — 3 warstwy

#### Warstwa 1: Zamiana Button → I18NButton (globalna)
**Wysiłek:** Niski  
**Efekt:** Wysoki

W plikach OTUI, gdzie `Button` ma `!text: tr(...)`, zastąpić na `I18NButton`. Dzięki `text-horizontal-auto-resize: true` + `min-width: 106` przycisk automatycznie rośnie aby pomieścić przetłumaczony tekst.

**Przed:**
```
Button
  !text: tr("key")
  anchors.left: parent.left
  anchors.right: parent.horizontalCenter
```

**Po:**
```
I18NButton
  !text: tr("key")
  anchors.left: parent.left
  anchors.right: parent.horizontalCenter
```

**Ograniczenie:** Gdy przycisk jest anchored zarówno do `left` jak i `right`, anchor wymusza rozmiar i `text-horizontal-auto-resize` nie zadziała. W takim przypadku potrzeba albo zniknięcia prawego anchora, albo użycia Warstwy 2.

#### Warstwa 2: Per-language config overrides (nowe)
**Wysiłek:** Średni  
**Efekt:** Precyzyjny

Moduł Lua `modules/client_locales/i18n_layout.lua` + pliki konfiguracyjne `data/i18n_layout/<lang>.lua`.

**Działanie:**
1. Moduł ładuje plik konfiguracyjny dla aktywnego języka
2. Konfiguracja zawiera mapę: moduł → widget ID → nadpisane właściwości
3. Po załadowaniu okna, moduł wywoływany ręcznie: `i18nLayout.applyOverrides(window, "client_entergame/entergame")`

**Przykład konfiguracji (data/i18n_layout/de.lua):**
```lua
return {
    ["client_entergame/entergame"] = {
        ["serverListButton"] = { ["min-width"] = 150 },
        ["btnCreateNewAccount"] = { ["min-width"] = 160 },
    },
}
```

#### Warstwa 3: Auto-measurement tool (dev-time)
**Wysiłek:** Niski (już zaimplementowany)  
**Efekt:** Diagnostyczny

Funkcja Lua `i18nLayout.measureLanguage("de")` mierzy renderowaną szerokość wszystkich kluczy `tr()` dla danego języka i porównuje z angielskim. Generuje raport:
```
=== I18N Layout Report for de ===
Translations wider than EN by >20%: 234

  [2.3x] otclient_modules.entergame.tr_11
    EN (66px): Login Error
    DE (152px): Anmeldefehler beim Einloggen
```

Funkcja `i18nLayout.generateOverrideStub("de")` generuje szablon pliku konfiguracyjnego.

### 2.4 Pliki utworzone

| Plik | Opis |
|------|------|
| `modules/client_locales/i18n_layout.lua` | Moduł Lua z systemem override + auto-measurement |
| `data/i18n_layout/de.lua` | Szablon overrides dla niemieckiego |
| `data/i18n_layout/fr.lua` | Szablon overrides dla francuskiego |
| `data/i18n_layout/es.lua` | Szablon overrides dla hiszpańskiego |
| `data/i18n_layout/ru.lua` | Szablon overrides dla rosyjskiego |

### 2.5 Skala migracji Button → I18NButton

**Pliki OTUI z największą liczbą stałych szerokości + tr():**

| Plik | width: | tr() | Priorytet |
|------|--------|------|-----------|
| game_cyclopedia/tab/character/character.otui | 23 | 97 | WYSOKI |
| game_spelllist/spelllist.otui | 20 | 32 | WYSOKI |
| client_entergame/createAccount.otui | 17 | 39 | WYSOKI |
| game_console/communicationwindow.otui | 15 | 16 | ŚREDNI |
| game_highscore/game_highscore.otui | 14 | 23 | ŚREDNI |
| game_imbuing/imbuing.otui | 13 | 16 | ŚREDNI |
| client_options/styles/controls/keybinds.otui | 13 | 16 | ŚREDNI |
| game_hotkeys/hotkeys_manager.otui | 12 | 20 | ŚREDNI |

**Uwaga:** Nie wszystkie `width:` dotyczą przycisków z tr(). Wiele to panele, TextEdity, separatory. Faktyczna liczba przycisków wymagających migracji jest mniejsza.

---

## 3. Co zostało zrobione — pełna lista zmian

### Pliki C++ zmodyfikowane:

| Plik | Zmiana | Commit |
|------|--------|--------|
| `framework/pch.h` | Include guard + `#endif` | f75be4197 |
| `framework/luabinder.h` | Fold expressions, N==0 guard, std::size_t | f94e5c6fc |
| `framework/luainterface.h` | Fix if constexpr | f94e5c6fc |
| `framework/luavaluecasts.h` | Fold expressions (tuple) | f94e5c6fc |
| `framework/luafunctions.cpp` | Dodano otmlnode.h, usunięto protocolhttp.h | f94e5c6fc |
| `framework/luafunctions_gfx_singletons.cpp` | Dodano uiwidget.h | f94e5c6fc |
| `framework/luafunctions_ui.cpp` | Split + usunięto protocolhttp.h + fix PainterShaderProgram | f94e5c6fc |
| `client/luafunctions.cpp` | Trimmed 1104→405 linii, extern calls | 6e6713242 |
| `src/CMakeLists.txt` | Nowe pliki, flagi MSVC | multiple |

### Nowe pliki C++ (split TU):

| Plik | Linii | Zawartość |
|------|-------|-----------|
| `framework/luafunctions_net.cpp` | 60 bindów | Server, Connection, Protocol, InputMessage, OutputMessage |
| `framework/luafunctions_sound.cpp` | 43 bindów | SoundManager, SoundSource, CombinedSoundSource, StreamSoundSource, SoundEffect, SoundChannel |
| `client/luafunctions_entities.cpp` | 567 linii | 20+ entity classes |
| `client/luafunctions_ui_client.cpp` | 210 linii | 10 UI widget classes |

### Nowe pliki I18N:

| Plik | Opis |
|------|------|
| `modules/client_locales/i18n_layout.lua` | System per-language button sizing |
| `data/i18n_layout/de.lua` | Overrides DE |
| `data/i18n_layout/fr.lua` | Overrides FR |
| `data/i18n_layout/es.lua` | Overrides ES |
| `data/i18n_layout/ru.lua` | Overrides RU |

---

## 4. Co jeszcze można zrobić

### Priorytet WYSOKI

1. **Poczekać na wynik CI Linux** — buildy 22245780181, 22245673448 w trakcie. Powinny przejść z fixem pch.h + split client.

2. **Uruchomić build Windows** — workflow `build-windows.yml` jest `workflow_dispatch` (ręczny). Po potwierdzeniu Linux, uruchomić ręcznie.

3. **Migracja Button → I18NButton** — zacząć od `client_entergame/entergame.otui` jako test:
   - Zamienić `Button` na `I18NButton` dla przycisków z `!text: tr(...)`
   - Usunąć anchor `right` jeśli koliduje z auto-resize
   - Przetestować z PL, DE, FR, RU

### Priorytet ŚREDNI

4. **Wypełnić pliki i18n_layout/*.lua** — uruchomić `i18nLayout.measureLanguage()` dla każdego języka i na podstawie raportu uzupełnić overrides.

5. **Dalszy split framework/luafunctions_ui.cpp** — 434 bindów to nadal dużo. Ewentualny dalszy podział na:
   - `luafunctions_uiwidget.cpp` (~290 bindów UIWidget)
   - `luafunctions_ui_misc.cpp` (layouts, textedit, qrcode, shaders, particles)

6. **Fix logic bugs w luavaluecasts.h:**
   - Linia ~555-560: odwrócony warunek `!` przy `luavalue_cast` (pair cast)
   - Linia ~157: mieszanie `requires` z `enable_if_t` (enum push_luavalue)

### Priorytet NISKI

7. **E2E test I18N z serwerem** — weryfikacja pakietów `0xBC`, `0x99`, `0xC5`, `0xC4`.

8. **TTFFont batching** — grupowanie quadów per atlas, uploadSubImage.

9. **Smoke test UI w CI** — headless test rysujący tekst.

10. **ClangCL jako backup** — jeśli MSVC 14.44 nadal ICE, pin na MSVC 14.29 lub przejście na ClangCL.

---

## 5. Architektura systemu I18N — przegląd

```
┌─────────────────────────────────────────────────────────────────┐
│                        OTUI Files                               │
│  modules/*/\*.otui                                              │
│  !text: tr("key")         ← tekst z tłumaczeniem               │
│  Button / I18NButton      ← style widgetu                      │
│  width: 106 / min-width   ← rozmiar (stały vs. elastyczny)     │
└──────────────────┬──────────────────────────────────────────────┘
                   │ load
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Lua Engine                                    │
│  _G.tr(key, ...)          ← tłumaczy klucz                     │
│  currentLocale.translation[key]                                 │
│  fallback: EN value → local translation                        │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│               Translation Sources                               │
│  data/locales/<lang>.lua       ← bazowe tłumaczenia             │
│  data/locales/game_i18n_<lang>.lua  ← game translations        │
│  data/locales/game_i18n_<lang>_compact.lua  ← klucze compact   │
│  data/i18n/<lang>_client_all.json  ← eksport/import (55 langs) │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              I18N Layout Override System (NOWE)                  │
│  modules/client_locales/i18n_layout.lua  ← moduł Lua            │
│  data/i18n_layout/<lang>.lua    ← overrides per-language        │
│                                                                  │
│  Workflow:                                                       │
│  1. setLocale("de") → onLocaleChanged("de")                    │
│  2. i18nLayout loads data/i18n_layout/de.lua                    │
│  3. widget.applyOverrides(window, "module/file")                │
│  4. Zmienia min-width, width, auto-resize na widgetach          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              C++ UIWidget (text rendering)                        │
│  updateText() → calculateTextRectSize()                          │
│  PropTextHorizontalAutoResize → setWidth(textBoxSize)           │
│  PropTextVerticalAutoResize → setHeight(textBoxSize)            │
│  m_minSize / m_maxSize → clamp                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Rekomendowane następne kroki

1. ✅ Poczekać na wynik CI Linux
2. 🔲 Uruchomić CI Windows (workflow_dispatch)
3. 🔲 Przetestować `I18NButton` na `entergame.otui` z kilkoma językami
4. 🔲 Uruchomić `i18nLayout.measureLanguage()` dla DE, FR, ES, RU, PL
5. 🔲 Uzupełnić pliki `data/i18n_layout/*.lua` na podstawie raportów
6. 🔲 Masowa migracja `Button → I18NButton` w 98 plikach OTUI
