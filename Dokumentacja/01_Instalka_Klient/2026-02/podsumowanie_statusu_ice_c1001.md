# Podsumowanie statusu ICE C1001 — po Rundzie 4

**Data:** 2026-02-22 (aktualizacja)  
**Kontekst:** Analiza wyników CI + poprawki build Linux + split client TU + I18N button sizing

---

## Podsumowanie aktualnej sytuacji

**Krok 1 ✅ — zadziałał:** Dodanie include'ów naprawiło błędy C2139 i C2665 (4 z 6 błędów zniknęło).

**Kroki 2A-2C ✅ — zaimplementowane:** Flagi MSVC, fix `if constexpr`, fold expressions w luabinder.h.

**Krok 2C.1 ✅ — poprawki ChatGPT review:** Guard N==0, `#include <utility>`, explicit `std::size_t`.

**Kroki 3A-3E ✅ — głębokie badanie (Runda 3):** Usunięcie ciężkiego include'a Asio, split TU, refaktor tuple templates, fix PainterShaderProgram, explicit `std::size_t`.

**Runda 4A ✅ — Fix pch.h (Linux):** Include guard `#ifndef FRAMEWORK_PCH_H` naprawił `redefinition of 'format_as'` na GCC 13.

**Runda 4B ✅ — Split client/luafunctions.cpp:** 1104→405 linii + 2 nowe TU (entities: 567, ui_client: 210).

**Aktualny status:** Buildy CI Linux w trakcie. HEAD = origin/master = `e096f7242`. Wszystkie zmiany scommitowane i pushowane.

---

## Co zostało zrobione w Rundzie 4 (2026-02-22)

### 4A: Fix pch.h double-inclusion (Linux) ✅

**Problem:** Build Linux failował: `pch.h:70:1: error: redefinition of 'template<class E> format_as(E)'`

**Przyczyna:** CMake PCH injection (`-include cmake_pch.hxx` → `pch.h`) + zwykły łańcuch include'ów (`global.h` → `pch.h`) powodował podwójne zdefiniowanie szablonu `format_as`. `#pragma once` nie chroni gdy ten sam plik jest włączany raz bezpośrednio, raz przez CMake injection.

**Naprawa:** Dodano tradycyjny include guard:
```cpp
#ifndef FRAMEWORK_PCH_H
#define FRAMEWORK_PCH_H
// ... pch.h content ...
#endif // FRAMEWORK_PCH_H
```

### 4B: Split client/luafunctions.cpp ✅

**Problem:** Najcięższy TU w projekcie: 1104 linii, 939 template binds.

**Naprawa:** Split na 3 pliki:

| Plik | Linii | Bindy | Zawartość |
|------|-------|-------|-----------|
| `client/luafunctions.cpp` | 405 | ~200 | Singletons: g_things, g_map, g_game, g_minimap, g_sprites, g_client, g_attachedEffects, g_gameConfig |
| `client/luafunctions_entities.cpp` **NOWY** | 567 | ~540 | 20+ entity classes: ProtocolGame, Container, AttachableObject, Thing, Creature, Player/Npc/Monster, LocalPlayer, Item, Effect, Missile, AttachedEffect, StaticText, AnimatedText, Tile, ThingType, ItemType, House, Spawn, Town, CreatureType |
| `client/luafunctions_ui_client.cpp` **NOWY** | 210 | ~200 | 10 UI widget classes: UIItem, UIEffect, UIMissile, UISprite, UICreature, UIMap, UIMinimap, UIProgressRect, UIGraph, UIMapAnchorLayout |

CMakeLists.txt zaktualizowany: oba pliki w Group 2 (flagi MSVC ICE workaround + SKIP_PRECOMPILE_HEADERS ON) + lista źródeł.

---

## Co zostało zrobione w Rundzie 3 (2026-02-21)

### 3A: Usunięcie `#include <framework/net/protocolhttp.h>` ✅

**Problem:** `protocolhttp.h` ciągnie `<asio.hpp>` + `<asio/ssl.hpp>` — masywne nagłówki szablonowe. Typ `ProtocolHttp` **nie był nigdzie używany** w `luafunctions_ui.cpp` ani `luafunctions.cpp` (potwierdzone grepem).

**Naprawa:** Usunięto include z obu plików. Eliminuje tysiące symboli szablonowych z tych TU.

### 3B: Split `luafunctions_ui.cpp` na 3 pliki ✅

**Problem:** 537 template instantiations w jednym TU — główny czynnik ryzyka ICE C1001.

**Naprawa:**
| Plik | Bindy | Zawartość |
|------|-------|-----------|
| `luafunctions_ui.cpp` | 434 | UIWidget (~290), UILayout, UIBoxLayout, UIVerticalLayout, UIHorizontalLayout, UIGridLayout, UIAnchorLayout, UITextEdit, UIQrCode, ShaderProgram, PainterShaderProgram, ParticleEffectType, UIParticles |
| `luafunctions_net.cpp` **NOWY** | 60 | Server, Connection, Protocol, InputMessage, OutputMessage |
| `luafunctions_sound.cpp` **NOWY** | 43 | SoundManager (singleton), SoundSource, CombinedSoundSource, StreamSoundSource, SoundEffect, SoundChannel |

Nowe pliki dodane do CMakeLists.txt (Group 2 z flagami ICE workaround + lista źródeł).

### 3C: Refaktor rekurencyjnych tuple templates w `luavaluecasts.h` ✅

**Problem:** `push_tuple_internal_luavalue<N>` i `push_tuple_luavalue<N>` — rekurencyjne struct templates z partial specialization dla N=0. Taki sam wzorzec jak naprawiony w `luabinder.h`.

**Naprawa:** Zamienione na fold expressions:
```cpp
// PRZED (rekurencyjne):
template<int N>
struct push_tuple_internal_luavalue {
    template<typename Tuple>
    static void call(const Tuple& tuple) {
        push_internal_luavalue(std::get<N - 1>(tuple));
        g_lua.rawSeti(N);
        push_tuple_internal_luavalue<N - 1>::call(tuple);
    }
};

// PO (fold expression):
template<typename Tuple, std::size_t... I>
void push_tuple_internal_luavalue_impl(const Tuple& tuple, std::index_sequence<I...>) {
    constexpr std::size_t N = sizeof...(I);
    if constexpr (N > 0) {
        ((push_internal_luavalue(std::get<N - 1 - I>(tuple)),
          g_lua.rawSeti(static_cast<int>(N - I))), ...);
    }
}
```
Dodano `#include <utility>` dla `std::index_sequence`.

### 3D: Fix `registerClass<PainterShaderProgram>()` ✅

**Problem (bug logiczny):** `PainterShaderProgram final : public ShaderProgram`, ale registracja Lua używała `registerClass<PainterShaderProgram>()` co domyślnie ustawia `LuaObject` jako bazę.

**Skutek:** Lua nie widziała metod `ShaderProgram` na obiektach `PainterShaderProgram`.

**Naprawa:** `registerClass<PainterShaderProgram, ShaderProgram>()`

### 3E: `constexpr auto N` → `constexpr std::size_t N` ✅

**Problem:** `auto` w kontekście constexpr w lambda capture ze szablonami — potencjalnie niejednoznaczne na MSVC.

**Naprawa:** Jawny typ `std::size_t` w `bind_fun_specializer()` w `luabinder.h`.

---

## Bilans zmniejszenia template pressure

### Przed Rundą 3:
- `luafunctions_ui.cpp`: 537 bindów + `<asio.hpp>` + `<asio/ssl.hpp>` + rekurencyjne tuple szablony
- Rekurencyjne tuple templates w `luavaluecasts.h` → N poziomów instancjacji

### Po Rundzie 3:
- `luafunctions_ui.cpp`: 434 bindów, **BEZ Asio**
- `luafunctions_net.cpp`: 60 bindów (osobna TU)
- `luafunctions_sound.cpp`: 43 bindów (osobna TU)
- Tuple templates: fold expressions (1 poziom vs N)
- Łącznie: **~20% mniej bindów w najcięższym TU** + **eliminacja Asio** + **zero rekurencyjnych szablonów**

---

## Znane pozostałe problemy

### Jeśli CI nadal failuje (priorytet: WYSOKI jeśli wystąpi)

1. **`luafunctions_ui.cpp` (434 bindów)** — nadal najcięższy TU po stronie framework. Dalszy split:
   - `luafunctions_uiwidget.cpp` (~290 bindów UIWidget)
   - `luafunctions_ui_misc.cpp` (reszta: layouts, textedit, qrcode, shaders, particles)

2. **Krok 2D (backup):** ClangCL zamiast MSVC cl.exe, lub pin na MSVC 14.29.

### Problemy niskiego priorytetu (nie blokują build)

3. **Mieszanie `requires` z `enable_if_t`** w `luavaluecasts.h` linia ~157 — enum push_luavalue używa C++20 `requires` a reszta overloadu `enable_if_t`. Może zmylić MSVC.

4. **Logic bug w pair cast** (`luavaluecasts.h` ~555-560) — odwrócony warunek `!` przy `luavalue_cast`. Runtime bug, nie kompilacyjny.

5. **Trailing backslash** w `luainterface.cpp` (~linia 736) — kosmetyczne, z konwersji makro.

6. **Weryfikacja `/std:c++20`** na MSVC — kod używa `requires`, fold expressions, `if constexpr`. Warto potwierdzić że CMake ustawia C++20 na runnerze.

---

## Bilans zmniejszenia template pressure (po Rundzie 4)

### Łączny obraz:

| TU | Przed | Po | Zmiana |
|----|-------|----|--------|
| `framework/luafunctions_ui.cpp` | 537 bindów + Asio | 434 bindów, bez Asio | -19% |
| `framework/luafunctions_net.cpp` | — | 60 bindów | nowy |
| `framework/luafunctions_sound.cpp` | — | 43 bindów | nowy |
| `client/luafunctions.cpp` | 1104 linii / 939 bindów | 405 linii / ~200 bindów | -57% linii |
| `client/luafunctions_entities.cpp` | — | 567 linii / ~540 bindów | nowy |
| `client/luafunctions_ui_client.cpp` | — | 210 linii / ~200 bindów | nowy |

**Eliminacja rekurencyjnych szablonów:**
- `luabinder.h` — fold expressions zamiast `call_fun_args<N>`
- `luavaluecasts.h` — fold expressions zamiast `push_tuple_internal_luavalue<N>`

**Eliminacja ciężkich include'ów:**
- `<asio.hpp>` + `<asio/ssl.hpp>` usunięte z luafunctions_ui.cpp i luafunctions.cpp
