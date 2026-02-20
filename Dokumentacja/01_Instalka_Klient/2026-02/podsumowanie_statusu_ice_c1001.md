# Podsumowanie statusu ICE C1001 — po Rundzie 3

**Data:** 2026-02-21 (aktualizacja)  
**Kontekst:** Analiza wyników CI + głębokie badanie .cpp/.h + implementacja poprawek Rundy 3

---

## Podsumowanie aktualnej sytuacji

**Krok 1 ✅ — zadziałał:** Dodanie include'ów naprawiło błędy C2139 i C2665 (4 z 6 błędów zniknęło).

**Kroki 2A-2C ✅ — zaimplementowane:** Flagi MSVC, fix `if constexpr`, fold expressions w luabinder.h.

**Krok 2C.1 ✅ — poprawki ChatGPT review:** Guard N==0, `#include <utility>`, explicit `std::size_t`.

**Kroki 3A-3E ✅ — głębokie badanie (Runda 3):** Usunięcie ciężkiego include'a Asio, split TU, refaktor tuple templates, fix PainterShaderProgram, explicit `std::size_t`.

**Aktualny status:** 2 buildy CI w trakcie (run 22244152617, 22243721692). Oczekujemy na wyniki.

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

1. **`luafunctions_ui.cpp` (434 bindów)** — nadal najcięższy TU. Dalszy split:
   - `luafunctions_uiwidget.cpp` (~290 bindów UIWidget)
   - `luafunctions_ui_misc.cpp` (reszta: layouts, textedit, qrcode, shaders, particles)

2. **`client/luafunctions.cpp`** — nie badany. Może mieć podobne problemy.

3. **Krok 2D (backup):** ClangCL zamiast MSVC cl.exe, lub pin na MSVC 14.29.

### Problemy niskiego priorytetu (nie blokują build)

4. **Mieszanie `requires` z `enable_if_t`** w `luavaluecasts.h` linia ~157 — enum push_luavalue używa C++20 `requires` a reszta overloadu `enable_if_t`. Może zmylić MSVC.

5. **Logic bug w pair cast** (`luavaluecasts.h` ~555-560) — odwrócony warunek `!` przy `luavalue_cast`. Runtime bug, nie kompilacyjny.

6. **Trailing backslash** w `luainterface.cpp` (~linia 736) — kosmetyczne, z konwersji makro.

7. **Weryfikacja `/std:c++20`** na MSVC — kod używa `requires`, fold expressions, `if constexpr`. Warto potwierdzić że CMake ustawia C++20 na runnerze.
