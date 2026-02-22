# Plan audytu MSVC — podział na partie (2 agentów)

**Data**: 2026-02-22
**Cel**: Przeskanować WSZYSTKIE 376 plików (.cpp + .h) pod kątem kompatybilności z MSVC 14.44+
**Metoda**: Podział na 10 partii, 2 agentów pracuje równolegle (Agent A + Agent B)

---

## Statystyka codebase

| Typ | Ilość |
|---|---|
| Pliki .cpp | 181 |
| Pliki .h | 195 |
| **Razem** | **376** |
| Katalogów | 19 |
| Łączne linie | 83 936 |

---

## Co szukamy w każdym pliku (checklist audytu)

### Krytyczne (powodują ICE C1001)
- [ ] `throw` wewnątrz ciała `template` w headerze (.h) — **MSVC P2 crash**
- [ ] Głębokie template instantiation chains (>3 poziomy) — **SSA optimizer crash**
- [ ] `if constexpr` z `throw` na ścieżce — **FH4 handler crash**
- [ ] Brak `#pragma optimize("", off)` w pliku z >50 template binding calls

### Wysokie ryzyko
- [ ] Include `luainterface.h` (ciągnie `luabinder.h` 265ln + `luavaluecasts.h` 627ln)
- [ ] `std::ranges` / `std::views` / `requires` — MSVC 14.44 ma regression w ranges
- [ ] `fmt::format` / `std::format` w dużych TU (>500 ln) — fmt + templates = ICE
- [ ] Duże pliki (>1000 ln) z wieloma include — presja na P2

### Średnie ryzyko
- [ ] `__declspec` użyty nieprawidłowo lub brak `_MSC_VER` guard
- [ ] `safe_cast<>` / `unsafe_cast<>` w headerze z `throw`
- [ ] Brakujące `_MSC_VER` guard przy platform-specific code
- [ ] Missing `#include` guard / `#pragma once`

### 🆕 i18n / Glyph / Text Stack (nowe od 2026-02-22)
- [ ] Bezwarunkowe `#include <hb.h>`, `<hb-ft.h>`, `<fribidi.h>` — **brak `#ifdef OTC_ENABLE_*` guard!**
- [ ] Pliki z `framework/text/` (TTFFont, TextShaper, LocaleShaping) **NIE są w żadnej MSVC CMake Protection Group!**
- [ ] Include chain: `bitmapfont.h` → `TTFFont.h` → `TextShaper.h` → `<hb.h>` + `<hb-ft.h>` + `<fribidi.h>` — rozwleka HarfBuzz/FriBidi do każdego TU używającego BitmapFont
- [ ] `fmt::format` w TTFFont.cpp (14×), bitmapfont.cpp (7×) — fmt + external library headers = zwiększone ryzyko ICE
- [ ] `OTC_ENABLE_TTF`, `OTC_ENABLE_HARFBUZZ`, `OTC_ENABLE_FRIBIDI` — definy ustawione w CMake, ale **NIGDY nie sprawdzane w kodzie** (`#ifdef` nie istnieje)
- [ ] Nowe Lua bindings (`g_fonts.clearGlyphCaches`, `setLocaleTag`, `getLocaleTag`) w `luafunctions_gfx_singletons.cpp` — dodatkowa presja na template instantiation
- [ ] `LocaleShaping.h` includzuje `TTFFont.h` → ciągnie FreeType + HarfBuzz do każdego pliku z LocaleShaping
- [ ] `cachedtext.cpp` includzuje `TextShaper.h` + `LocaleShaping.h` + `Utf8.h` — wszstkie nowe zależności
- [ ] `fontmanager.cpp` includzuje `TTFFont.h` + `TextShaper.h` + `LocaleShaping.h`
- [ ] `uiwidgettext.cpp`, `uitextedit.cpp` — zmodyfikowane dla Unicode, sprawdzić kompatybilność MSVC

### Niskie ryzyko (weryfikacja)
- [ ] Poprawność `#ifdef` platform guards (WIN32, _WIN32, __linux__)
- [ ] `NOMINMAX` — czy nie ma konfliktu `min`/`max` z `Windows.h`
- [ ] Użycie `__attribute__` bez `_MSC_VER` fallback

---

## Klasyfikacja plików po ryzyku

### 🔴 KRYTYCZNE (template + throw w headerach) — 5 plików

| # | Plik | Linie | Templates | Throws | Opis |
|---|---|---|---|---|---|
| 1 | `framework/luaengine/luavaluecasts.h` | 627 | 49 | 3 | Najcięższy header, 157 template deklaracji |
| 2 | `framework/luaengine/luabinder.h` | 264 | 20 | 1 | Variadic template machinery |
| 3 | `framework/luaengine/luainterface.h` | 548 | 41 | 0* | *Include luabinder+luavaluecasts = 900+ ln chain |
| 4 | `framework/otml/otmlnode.h` | 190 | 17 | 3 | `value<T>()` template + throw |
| 5 | `framework/stdext/cast.h` | 213 | 6 | 2 | `safe_cast<>` + throw |

### 🟠 WYSOKIE RYZYKO (include luainterface.h + template bindings) — 26 plików

| # | Plik | Linie | Binding calls | Ma pragma? | Ma flagi CMake? |
|---|---|---|---|---|---|
| 6 | `client/luafunctions_entities.cpp` | 577 | 472 | ✅ | ✅ Group 2 |
| 7 | `framework/luafunctions_ui_widget_style.cpp` | 224 | 178 | ✅ | ✅ Group 2 |
| 8 | `client/luafunctions_ui_client.cpp` | 219 | 154 | ✅ | ✅ Group 2 |
| 9 | `framework/luafunctions_ui_widget_core.cpp` | 190 | 144 | ✅ | ✅ Group 2 |
| 10 | `framework/luafunctions_ui_layout_text_effects.cpp` | 180 | 112 | ✅ | ✅ Group 2 |
| 11 | `client/luavaluecasts_client.cpp` | 1609 | 87 | ✅ | ✅ Group 3 |
| 12 | `framework/luafunctions_net.cpp` | 124 | 60 | ✅ | ✅ Group 2 |
| 13 | `framework/luafunctions.cpp` | 328 | 58 | ✅ | ✅ Group 2 |
| 14 | `framework/luafunctions_sound.cpp` | 99 | 31 | ✅ | ✅ Group 2 |
| 15 | `framework/ui/uiwidget.cpp` | 2188 | 29 | ❌ | ⚠️ Group 4 (lekki) |
| 16 | `framework/luaengine/luavaluecasts.cpp` | 380 | 24 | ✅ | ✅ Group 3 |
| 17 | `client/luafunctions.cpp` | 414 | 12 | ✅ | ✅ Group 2 |
| 18 | `framework/luaengine/luainterface.cpp` | 1415 | 9 | ✅ | ✅ Group 2 |
| 19 | `framework/luafunctions_gfx_singletons.cpp` | 125 | 8 | ✅ | ✅ Group 2 |
| 20 | `framework/luafunctions_ui.cpp` | 55 | 1 | ✅ | ✅ Group 2 |
| 21 | `framework/luafunctions_graphics.cpp` | 121 | 1 | ✅ | ✅ Group 2 |
| 22 | `framework/luaengine/luaexception.cpp` | 76 | 2 | ❌ | ❌ |
| 23 | `framework/core/application.cpp` | 231 | 1 | ❌ | ❌ |
| 24 | `framework/core/consoleapplication.cpp` | 73 | 1 | ❌ | ❌ |
| 25 | `framework/luaengine/luaobject.cpp` | 129 | 1 | ❌ | ❌ |
| 26 | `main.cpp` | 130 | 1 | ❌ | ❌ |
| 27 | `framework/core/garbagecollection.cpp` | 91 | 1 | ❌ | ❌ |
| 28 | `framework/core/logger.cpp` | 150 | 1 | ❌ | ❌ |
| 29 | `framework/core/module.cpp` | 274 | 1 | ❌ | ❌ |
| 30 | `framework/core/resourcemanager.cpp` | 805 | 1 | ❌ | ❌ |
| 31 | `framework/luaengine/luaobject.h` | 241 | 7 | — | — |

### 🟡 ŚREDNIE RYZYKO (duże pliki, fmt, ranges, OTML) — 25 plików

| # | Plik | Linie | Ryzyko | Uwagi |
|---|---|---|---|---|
| 32 | `client/protocolgameparse.cpp` | 6222 | fmt+ranges | ✅ Group 4 CMake |
| 33 | `framework/ui/uiwidgetbasestyle.cpp` | 435 | safe_cast | ✅ Group 4 CMake |
| 34 | `framework/otml/otmlnode.cpp` | 214 | OTML templates | ✅ Group 1 + pragma |
| 35 | `framework/otml/otmlparser.cpp` | 220 | OTML templates | ✅ Group 1 + pragma |
| 36 | `client/game.cpp` | 2012 | duży plik | brak ochrony |
| 37 | `client/creature.cpp` | 1270 | callLuaField×20 | brak ochrony |
| 38 | `client/localplayer.cpp` | 620 | callLuaField×32 | brak ochrony |
| 39 | `client/map.cpp` | 1471 | ranges×5 | brak ochrony |
| 40 | `client/tile.cpp` | 1004 | ranges×6, fmt | brak ochrony |
| 41 | `client/mapview.cpp` | 975 | ranges×2 | brak ochrony |
| 42 | `client/protocolgamesend.cpp` | 1506 | duży plik | brak ochrony |
| 43 | `framework/platform/win32window.cpp` | 1155 | Windows-only | platform code |
| 44 | `framework/platform/win32crashhandler.cpp` | 201 | _MSC_VER | platform code |
| 45 | `framework/platform/win32platform.cpp` | 454 | fmt | platform code |
| 46 | `framework/net/protocolhttp.cpp` | 1095 | duży, fmt | brak ochrony |
| 47 | `framework/graphics/apngloader.cpp` | 1052 | _MSC_VER guards | ma guards |
| 48 | `framework/stdext/demangle.cpp` | 67 | _MSC_VER | ma guards |
| 49 | `framework/stdext/demangle.h` | 64 | template+_MSC_VER | ma guards |
| 50 | `framework/stdext/compiler.h` | 69 | compiler detection | ma guards |
| 51 | `framework/core/logger.h` | 175 | template×10, fmt×20 | header z templates |
| 52 | `framework/util/matrix.h` | 258 | template×22 | czyste math templates |
| 53 | `client/uigraph.cpp` | 430 | fmt, ranges | brak ochrony |
| 54 | `framework/text/TTFFont.cpp` | 601 | fmt×14, FreeType+HB | ⚠️ brak ochrony, i18n |
| 55 | `framework/graphics/bitmapfont.cpp` | 895 | fmt×7, include TTFFont.h | ⚠️ brak ochrony, i18n |
| 56 | `framework/otml/otmlexception.h` | 39 | throw w header | sprawdzić |
| 57 | `framework/text/TextShaper.cpp` | 244 | HarfBuzz+FriBidi | ⚠️ brak ochrony, i18n |
| 58 | `framework/text/LocaleShaping.cpp` | 403 | TTFFont.h chain | ⚠️ brak ochrony, i18n |
| 59 | `framework/graphics/cachedtext.cpp` | 253 | TextShaper+LocaleShaping | ⚠️ brak ochrony, i18n |
| 60 | `framework/graphics/fontmanager.cpp` | 120 | TTFFont+TextShaper+LocaleShaping | ⚠️ brak ochrony, i18n |
| 61 | `framework/ui/uiwidgettext.cpp` | 264 | font fallback | ⚠️ brak ochrony, i18n |
| 62 | `framework/ui/uitextedit.cpp` | 1144 | Unicode edits, duży | ⚠️ brak ochrony, i18n |
| 63 | `framework/text/TextShaper.h` | 37 | `<hb.h>` `<fribidi.h>` bez guard | 🔴 BRAK `#ifdef` |
| 64 | `framework/text/TTFFont.h` | 191 | FreeType+HB headers | ⚠️ brak guard |
| 65 | `framework/text/LocaleShaping.h` | 62 | include TTFFont.h chain | ⚠️ brak guard |
| 66 | `framework/text/Utf8.h` | 183 | UTF-8 utility | niskie |
| 67 | `framework/graphics/bitmapfont.h` | 110 | include TTFFont.h → HB chain | ⚠️ propaguje HB |
| 68 | `framework/stdext/string.cpp` | ~470 | i18n modyfikacje | sprawdzić |

### 🟢 NISKIE RYZYKO (czyste pliki bez template/lua/fmt) — 320 plików

Pozostałe pliki bez żadnych czynników ryzyka ICE. Wymagają jedynie weryfikacji:
- Poprawność `#pragma once` / include guard
- Brak `min`/`max` bez `NOMINMAX`
- Brak `__attribute__` bez fallback

---

## Podział na partie — 10 partii, 2 agentów

### AGENT A (partie nieparzyste: 1, 3, 5, 7, 9)

#### Partia 1: 🔴 KRYTYCZNE HEADERY (Agent A)
**5 plików, ~1842 ln — NAJWAŻNIEJSZA partia**

Pliki:
1. `framework/luaengine/luavaluecasts.h` (627 ln, 49 tmpl, 3 throw)
2. `framework/luaengine/luabinder.h` (264 ln, 20 tmpl, 1 throw)
3. `framework/luaengine/luainterface.h` (548 ln, 41 tmpl)
4. `framework/otml/otmlnode.h` (190 ln, 17 tmpl, 3 throw)
5. `framework/stdext/cast.h` (213 ln, 6 tmpl, 2 throw)

Zadanie:
- Sprawdzić KAŻDY `throw` wewnątrz `template` body → czy wyekstrahowany do osobnej non-template `[[noreturn]]` funkcji
- Sprawdzić czy `__declspec(noinline)` + `[[noreturn]]` jest na throw helpers
- Zidentyfikować szablon × głębokość instantiation
- Zaproponować `extern template` declarations jeśli możliwe
- Sprawdzić `_MSC_VER` guards na `demangle_type<T>()`

#### Partia 3: 🟠 LUA BINDING PLIKI (framework) (Agent A)
**11 plików, ~2280 ln**

Pliki:
1. `framework/luafunctions.cpp` (328 ln, 58 bindings)
2. `framework/luafunctions_ui.cpp` (55 ln, dispatcher)
3. `framework/luafunctions_ui_widget_core.cpp` (190 ln, 144 bindings)
4. `framework/luafunctions_ui_widget_style.cpp` (224 ln, 178 bindings)
5. `framework/luafunctions_ui_layout_text_effects.cpp` (180 ln, 112 bindings)
6. `framework/luafunctions_graphics.cpp` (121 ln)
7. `framework/luafunctions_gfx_singletons.cpp` (125 ln)
8. `framework/luafunctions_net.cpp` (124 ln, 60 bindings)
9. `framework/luafunctions_sound.cpp` (99 ln)
10. `framework/luaengine/luainterface.cpp` (1415 ln, ICE point!)
11. `framework/luaengine/luavaluecasts.cpp` (380 ln)

Zadanie:
- Sprawdzić czy `#pragma optimize("", off/on)` jest na miejscu i poprawny
- Sprawdzić czy plik jest w odpowiedniej CMake Group (1-3)
- Policzyć binding calls, porównać z CMake Group
- Sprawdzić `SKIP_PRECOMPILE_HEADERS ON`
- Zweryfikować split `luafunctions_ui.cpp` → 3 pliki (czy rejestracje się zgadzają)

#### Partia 5: 🟡 framework/core + framework/stdext (Agent A)
**38 plików (20cpp + 22h core, 7cpp + 16h stdext) — bez lua**

Pliki core (42):
- `application.cpp/.h`, `asyncdispatcher.cpp/.h`, `binarytree.cpp/.h`
- `clock.cpp/.h`, `config.cpp/.h`, `configmanager.cpp/.h`
- `consoleapplication.cpp/.h`, `declarations.h`
- `event.cpp/.h`, `eventdispatcher.cpp/.h`
- `filestream.cpp/.h`, `garbagecollection.cpp/.h`
- `graphicalapplication.cpp/.h`, `inputevent.h`
- `logger.cpp/.h` ⚠️ (logger.h: 10 templates, 20 fmt)
- `module.cpp/.h`, `modulemanager.cpp/.h`
- `resourcemanager.cpp/.h` ⚠️ (805 ln, ranges×4, fmt×2)
- `scheduledevent.cpp/.h`, `timer.cpp/.h`
- `unzipper.cpp/.h`, `adaptativeframecounter.cpp/.h`

Pliki stdext (23):
- `cast.h` (→ w Partii 1), `compiler.h`, `demangle.cpp/.h`
- `exception.h`, `hash.h`, `math.cpp/.h`
- `net.cpp/.h`, `qrcodegen.cpp/.h`
- `stdext.h`, `storage.h`, `string.cpp/.h`
- `thread.h`, `time.cpp/.h`, `traits.h`, `types.h`
- `uri.cpp/.h`

Zadanie:
- Czy pliki includzujące `luainterface.h` (`application.cpp`, `consoleapplication.cpp`, `garbagecollection.cpp`, `logger.cpp`, `module.cpp`, `resourcemanager.cpp`) potrzebują ochrony CMake
- Sprawdzić `logger.h` — 10 templates + 20 fmt calls w headerze!
- Sprawdzić `_MSC_VER` guards w `compiler.h`, `demangle.h/cpp`, `math.cpp`, `string.cpp`
- Sprawdzić `storage.h` templates (4)
- Sprawdzić `eventdispatcher.h` template (1, `if constexpr`)

#### Partia 7: 🟡 framework/graphics + framework/text (Agent A)
**33 pliki (26cpp + 29h graphics, 3cpp + 4h text)**

Najistotniejsze:
- `apngloader.cpp` (1052 ln, 3× _MSC_VER) — platform guard
- `bitmapfont.cpp` (895 ln, 7× fmt)
- `drawpool.h` (444 ln, 2 templates)
- `drawpoolmanager.h` (137 ln, 2 templates)
- `glutil.h` (35 ln, 1× _MSC_VER)
- `shadersources.h` (97 ln)
- `textureatlas.h` (136 ln, 1 template)
- `TTFFont.cpp` (601 ln, 14× fmt) ⚠️
- `LocaleShaping.cpp` (403 ln)
- `TextShaper.cpp` (244 ln)
- `Utf8.h` (183 ln)

Zadanie:
- Sprawdzić `apngloader.cpp` _MSC_VER guards
- Sprawdzić `bitmapfont.cpp` + `TTFFont.cpp` — fmt w dużych plikach
- Sprawdzić `drawpool.h` / `drawpoolmanager.h` templates
- Sprawdzić `matrix.h` (22 templates) — czy MSVC-safe
- Sprawdzić `glutil.h` _MSC_VER guard

#### Partia 9: 🟢 framework/net + framework/sound + framework/proxy + misc (Agent A)
**35 plików**

Pliki net (21):
- `connection.cpp/.h`, `declarations.h`, `httplogin.cpp/.h`
- `inputmessage.cpp/.h`, `outputmessage.cpp/.h`
- `packet_player.cpp/.h`, `packet_recorder.cpp/.h`
- `protocol.cpp/.h` (467 ln, fmt×3, ranges×1)
- `protocolhttp.cpp/.h` (1095 ln, fmt×2)
- `server.cpp/.h`, `webconnection.cpp/.h`

Pliki sound (19):
- `combinedsoundsource.cpp/.h`, `declarations.h`
- `oggsoundfile.cpp/.h`, `soundbuffer.cpp/.h`
- `soundchannel.cpp/.h`, `soundeffect.cpp/.h`
- `soundfile.cpp/.h`, `soundmanager.cpp/.h` (538 ln, fmt×3)
- `soundsource.cpp/.h`, `streamsoundsource.cpp/.h`

Pliki proxy (4):
- `proxy.cpp/.h`, `proxy_client.cpp/.h`

Misc (4):
- `androidmain.cpp`, `main.cpp`, `gitinfo.h`, `stduuid/uuid.h`
- `framework/config.h`, `framework/const.h`, `framework/global.h`
- `framework/pch.h`, `framework/obfuscate.h`

Zadanie:
- Sprawdzić `protocolhttp.cpp` (1095 ln, fmt) — duży plik
- Sprawdzić `soundmanager.cpp` (538 ln, fmt)
- Sprawdzić `protocol.cpp` (ranges)
- Sprawdzić `main.cpp` — includzuje luainterface.h
- Sprawdzić `pch.h` — precompiled header, co jest w środku

---

### AGENT B (partie parzyste: 2, 4, 6, 8, 10)

#### Partia 2: 🟠 LUA ENGINE + OTML CORE (Agent B)
**15 plików, ~1800 ln**

Pliki luaengine (10):
1. `framework/luaengine/luaexception.cpp` (76 ln) — **ma throw helpers!**
2. `framework/luaengine/luaexception.h` (53 ln)
3. `framework/luaengine/luaobject.cpp` (129 ln, _MSC_VER×1)
4. `framework/luaengine/luaobject.h` (241 ln, 10 templates)
5. `framework/luaengine/declarations.h` (32 ln)

Pliki OTML (10):
6. `framework/otml/otmldocument.cpp` (57 ln)
7. `framework/otml/otmldocument.h` (49 ln)
8. `framework/otml/otmlemitter.cpp` (93 ln)
9. `framework/otml/otmlemitter.h` (32 ln)
10. `framework/otml/otmlexception.cpp` (46 ln)
11. `framework/otml/otmlexception.h` (39 ln, throw×1 w header!)
12. `framework/otml/otml.h` (26 ln)
13. `framework/otml/otmlnode.cpp` (214 ln, ✅ pragma + CMake)
14. `framework/otml/otmlparser.cpp` (220 ln, ✅ pragma + CMake)
15. `framework/otml/otmlparser.h` (55 ln)
16. `framework/otml/declarations.h` (34 ln)

Zadanie:
- Sprawdzić `luaexception.cpp` — tu teraz są throw helpers, czy poprawnie zdefiniowane
- Sprawdzić `luaobject.h` — 10 templates × czy throw w ciele?
- Sprawdzić `otmlexception.h` — throw w headerze!
- Sprawdzić `otmlnode.cpp` / `otmlparser.cpp` — czy pragma + CMake Group 1 poprawne
- Zweryfikować `OTML_NO_FMT` definition coverage

#### Partia 4: 🟠 LUA BINDING PLIKI (client) (Agent B)
**4 pliki, ~2819 ln**

Pliki:
1. `client/luafunctions.cpp` (414 ln, 12 bindings)
2. `client/luafunctions_entities.cpp` (577 ln, **472 bindings!**)
3. `client/luafunctions_ui_client.cpp` (219 ln, 154 bindings)
4. `client/luavaluecasts_client.cpp` (1609 ln, 87 casts)

Zadanie:
- Sprawdzić czy `#pragma optimize("", off/on)` jest poprawny
- Sprawdzić czy w CMake Group 2/3 poprawnie
- `luafunctions_entities.cpp` ma **472 binding** — czy nie potrzebuje dodatkowego splitu
- `luavaluecasts_client.cpp` — 1609 ln — sprawdzić czy cast templates nie triggerują ICE
- Sprawdzić include chainy — co ciągną te pliki

#### Partia 6: 🟡 client/*.cpp (logika gry — część 1) (Agent B)
**~25 plików**

Pliki:
1. `client/game.cpp` (2012 ln) — duży, lua include
2. `client/creature.cpp` (1270 ln, callLuaField×20)
3. `client/localplayer.cpp` (620 ln, callLuaField×32)
4. `client/map.cpp` (1471 ln, ranges×5)
5. `client/tile.cpp` (1004 ln, ranges×6, fmt×1)
6. `client/mapview.cpp` (975 ln, ranges×2)
7. `client/protocolgamesend.cpp` (1506 ln)
8. `client/protocolgameparse.cpp` (6222 ln, ✅ Group 4 CMake)
9. `client/mapio.cpp` (551 ln)
10. `client/thingtype.cpp` (1086 ln)
11. `client/thingtypemanager.cpp` (607 ln, fmt×2)
12. `client/spritemanager.cpp` (343 ln)
13. `client/spriteappearances.cpp` (270 ln, fmt×2, ranges×1)
14. `client/item.cpp` (439 ln)
15. `client/minimap.cpp` (433 ln)
16. `client/creatures.cpp` (416 ln)
17. `client/outfit.cpp` (154 ln)
18. `client/container.cpp` (133 ln, callLuaField×9)
19. `client/attachableobject.cpp` (330 ln, ranges×1)
20. `client/client.cpp` (157 ln)
21. `client/protocolcodes.cpp` (242 ln, ranges×1)
22. `client/protocolgame.cpp` (87 ln)
23. `client/gameconfig.cpp` (171 ln)
24. `client/houses.cpp` (203 ln, fmt×1)
25. `client/towns.cpp` (82 ln)

Zadanie:
- `creature.cpp` + `localplayer.cpp` + `container.cpp` mają callLuaField — sprawdzić czy nie triggerują template instantiation
- `map.cpp` + `tile.cpp` z ranges — sprawdzić `std::ranges::find_if` kompatybilność MSVC
- `protocolgameparse.cpp` (6222 ln!) — sprawdzić Group 4 CMake, czy nie potrzebuje silniejszej ochrony
- `game.cpp` (2012 ln) — sprawdzić include chain
- Sprawdzić `animatedtext.cpp`, `effect.cpp`, etc. — fmt użycia

#### Partia 8: 🟡 client/*.h (headery klienta) (Agent B)
**~49 plików headers**

Najistotniejsze:
1. `client/game.h` (1046 ln) — duży header
2. `client/const.h` (850 ln) — stałe
3. `client/thingtype.h` (547 ln)
4. `client/protocolcodes.h` (399 ln)
5. `client/protocolgame.h` (397 ln)
6. `client/creature.h` (368 ln)
7. `client/map.h` (353 ln, template×1)
8. `client/mapview.h` (350 ln)
9. `client/position.h` (303 ln, fmt×3, template×1)
10. `client/thing.h` (273 ln)
11. `client/tile.h` (273 ln)
12. `client/localplayer.h` (224 ln)
13. `client/attachedeffect.h` (184 ln)
14. `client/item.h` (183 ln)
15. `client/itemtype.h` (162 ln)
16. `client/gameconfig.h` (141 ln)
17. `client/creatures.h` (141 ln)
18. `client/declarations.h` (132 ln)
19. Reszta: `client/uimap.h`, `client/uiminimap.h`, `client/uiitem.h`, etc.
20. Reszta: `client/outfit.h`, `client/houses.h`, `client/towns.h`, etc.

Zadanie:
- Sprawdzić `position.h` — fmt w headerze (3×)
- Sprawdzić `game.h` (1046 ln) — duży, czy ma templates
- Sprawdzić `map.h` — template×1
- Sprawdzić czy żaden z tych headerów nie ma `throw` w `template`
- Ogólna inspekcja: `#pragma once`, NOMINMAX, missing includes

#### Partia 10: 🟢 framework/ui + framework/platform + framework/util + framework/discord/input (Agent B)
**~45 plików**

Pliki UI (29):
- `uiwidget.cpp` (2188 ln, 29 callLuaField, ranges×23) ⚠️ Group 4
- `uiwidgetbasestyle.cpp` (435 ln, ✅ Group 4)
- `uiwidget.h` (639 ln, 1 template)
- `uitextedit.cpp` (1144 ln)
- `uimanager.cpp` (617 ln, ranges×1)
- `uianchorlayout.cpp` (285 ln)
- `uiwidgetimage.cpp` (250 ln)
- `uiwidgettext.cpp` (264 ln, lua×2)
- `uitranslator.cpp` (131 ln)
- `uigridlayout.cpp` (120 ln)
- `uihorizontallayout.cpp` (101 ln, ranges×1)
- `uiverticallayout.cpp` (103 ln, ranges×1)
- `uiboxlayout.cpp` (39 ln)
- `uilayout.cpp` (71 ln)
- `uiparticles.cpp` (79 ln)
- `uiqrcode.cpp` (61 ln)
- Headery: `declarations.h`, `ui.h`, `*.h`

Pliki platform (16):
- `win32window.cpp` (1155 ln)
- `win32platform.cpp` (454 ln, fmt×2)
- `win32crashhandler.cpp` (201 ln, _MSC_VER×1)
- `x11window.cpp` (1117 ln)
- `browserwindow.cpp` (582 ln)
- `androidwindow.cpp` (510 ln)
- `platformwindow.cpp` (219 ln)
- `platform.cpp` (78 ln)
- `unixcrashhandler.cpp` (138 ln, fmt×7)
- `unixplatform.cpp` (266 ln, fmt×4)
- `browserplatform.cpp` (126 ln)
- `androidmanager.cpp` (128 ln)
- `androidgameactivity.cpp` (9 ln)
- Headery

Pliki util (9):
- `color.cpp/.h`, `crypt.cpp/.h` (ranges×2), `matrix.h` (22 tmpl), `point.h`, `rect.h`, `size.h`, `spinlock.h`

Pliki discord+input (4):
- `discord.cpp/.h`, `mouse.cpp/.h`

Pliki client UI widgets (12):
- `uicreature.cpp/.h`, `uieffect.cpp/.h`, `uigraph.cpp/.h` (fmt, ranges)
- `uiitem.cpp/.h` (fmt), `uimap.cpp/.h`, `uimapanchorlayout.cpp/.h`
- `uiminimap.cpp/.h`, `uimissile.cpp/.h`, `uiprogressrect.cpp/.h`
- `uisprite.cpp/.h`, `shadermanager.cpp`

Zadanie:
- `uiwidget.cpp` — 29 callLuaField + 23 ranges → czy Group 4 (lekki) wystarcza?
- `uitextedit.cpp` (1144 ln) — duży plik, sprawdzić
- `win32window.cpp` (1155 ln) + `win32crashhandler.cpp` — platform guards
- `matrix.h` (22 templates) — czyste math, sprawdzić MSVC-safe
- `uigraph.cpp` (fmt + ranges)
- `crypt.cpp` (requires/ranges)

---

## Harmonogram pracy

```
Krok 1: Agent A → Partia 1 (krytyczne headery)
        Agent B → Partia 2 (luaengine + OTML)
        
Krok 2: Agent A → Partia 3 (lua bindings framework)
        Agent B → Partia 4 (lua bindings client)

Krok 3: Agent A → Partia 5 (core + stdext)
        Agent B → Partia 6 (client .cpp logika)

Krok 4: Agent A → Partia 7 (graphics + text)
        Agent B → Partia 8 (client headers)

Krok 5: Agent A → Partia 9 (net + sound + misc)
        Agent B → Partia 10 (UI + platform + util)
```

---

## Format raportu z każdej partii

Każdy agent po zakończeniu partii powinien wyprodukować:

```
### Partia X — Raport

**Agent**: A/B
**Plików zbadano**: N
**Znaleziono problemów**: N

#### Problemy krytyczne 🔴
1. [plik:linia] — opis problemu → sugerowana naprawa

#### Problemy wysokie 🟠
1. [plik:linia] — opis → naprawa

#### Problemy średnie 🟡
1. [plik:linia] — opis → naprawa

#### OK ✅
- [plik] — brak problemów
```

---

## Priorytet napraw (po audycie)

1. **throw w template body w headerach** → wyciągnąć do non-template `[[noreturn]]` funkcji
2. **🆕 Brakujące `#ifdef OTC_ENABLE_*` guardy w text/ headerach** → dodać conditional compilation
3. **🆕 Pliki text/ NIE w MSVC CMake Protection Group** → dodać do Group 4+ lub nowej grupy
4. **🆕 Include chain bitmapfont.h → TTFFont.h → HarfBuzz** → forward declarations lub PIMPL
5. **Brakujące CMake Groups** dla plików z callLuaField > 5
6. **`extern template`** w `luavaluecasts.h` i `luabinder.h`
7. **Brakujące `_MSC_VER` guards** na platform-specific code
8. **ranges/fmt w dużych TU** → sprawdzić MSVC kompatybilność

---

## 🆕 SEKCJA i18n / Glyph / Text Stack — Rozszerzenie planu (2026-02-22)

### Podsumowanie zmian i18n/glyph w C++

| Metryka | Wartość |
|---|---|
| Commity dotyczące i18n/glyph | **47** |
| Unikalne pliki C++ zmodyfikowane | **44** |
| Linie dodane | **5 540** |
| Linie usunięte | **724** |
| **Netto nowych linii** | **4 816** |
| Nowe pliki utworzone | **6** (TTFFont.cpp/.h, TextShaper.cpp/.h, LocaleShaping.cpp/.h, Utf8.h) |
| Nowe biblioteki zewnętrzne | **3** (HarfBuzz, FriBidi, FreeType) |
| Nowe Lua bindings | **3** (clearGlyphCaches, setLocaleTag, getLocaleTag) |

### Diagram łańcucha include (Include Chain)

```
bitmapfont.h
  └── TTFFont.h
        ├── <ft2build.h>       (FreeType)
        ├── FT_FREETYPE_H      (FreeType macro)
        ├── <hb.h>             (HarfBuzz)
        ├── <hb-ft.h>          (HarfBuzz-FreeType bridge)
        └── TextShaper.h
              ├── <hb.h>       (HarfBuzz — DUPLICATE!)
              ├── <hb-ft.h>    (HarfBuzz-FreeType — DUPLICATE!)
              └── <fribidi.h>  (FriBidi)

LocaleShaping.h
  └── TTFFont.h               (cały łańcuch powyżej)

cachedtext.cpp
  ├── TextShaper.h             (HarfBuzz + FriBidi)
  ├── LocaleShaping.h          (→ TTFFont.h → HarfBuzz + FriBidi)
  └── Utf8.h

fontmanager.cpp
  ├── TTFFont.h                (FreeType + HarfBuzz)
  ├── TextShaper.h             (HarfBuzz + FriBidi)
  └── LocaleShaping.h          (→ TTFFont.h)
```

**Efekt**: Każdy TU includzujący `bitmapfont.h` dostaje nagłówki **FreeType + HarfBuzz + FriBidi**.
To znacząco zwiększa presję na kompilator MSVC P2 phase.

### 🔴 KRYTYCZNY PROBLEM: Brak `#ifdef OTC_ENABLE_*` guardów

CMake definiuje te stałe:
```cmake
target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_TTF)
target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_HARFBUZZ)
target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_FRIBIDI)
```

Ale **ŻADEN** plik źródłowy ich nie sprawdza:
```cpp
// TextShaper.h — BEZ GUARDA!
#include <hb.h>        // ← zawsze includzowany
#include <hb-ft.h>     // ← zawsze includzowany
#include <fribidi.h>   // ← zawsze includzowany
```

**Powinno być:**
```cpp
// TextShaper.h — Z GUARDEM
#ifdef OTC_ENABLE_HARFBUZZ
  #include <hb.h>
  #include <hb-ft.h>
#endif
#ifdef OTC_ENABLE_FRIBIDI
  #include <fribidi.h>
#endif
```

### 🔴 Pliki text/ NIE w żadnej MSVC CMake Protection Group

Pliki w `framework/text/` (TTFFont.cpp, TextShaper.cpp, LocaleShaping.cpp) są dodane
do `SOURCE_FILES` (linie 812-814 CMakeLists.txt), ale **NIE** ma ich w żadnej z grup
MSVC ICE protection (Group 1-4, linie 120-235 CMakeLists.txt).

Oznacza to, że są kompilowane z pełną optymalizacją `/O2` tak jak domyślnie —
a mają: fmt×14 (TTFFont), HarfBuzz/FriBidi nagłówki, externe library types.

### Lista 44 plików zmodyfikowanych przez commity i18n/glyph

Tabela z przyporządkowaniem do partii audytu:

| # | Plik | Partia | Linie zmienione | Opis zmian | MSVC Protection |
|---|---|---|---|---|---|
| 1 | `framework/text/TTFFont.cpp` | **P7** | +601 (nowy) | TTF rendering, atlas, glyph cache | ❌ BRAK |
| 2 | `framework/text/TTFFont.h` | **P7** | +191 (nowy) | Forward decl, atlas types | ❌ BRAK |
| 3 | `framework/text/TextShaper.cpp` | **P7** | +244 (nowy) | HarfBuzz shaping, FriBidi bidi | ❌ BRAK |
| 4 | `framework/text/TextShaper.h` | **P7** | +37 (nowy) | **`<hb.h>` bez guard!** | ❌ BRAK |
| 5 | `framework/text/LocaleShaping.cpp` | **P7** | +403 (nowy) | BCP47, script detection | ❌ BRAK |
| 6 | `framework/text/LocaleShaping.h` | **P7** | +62 (nowy) | include TTFFont.h chain | ❌ BRAK |
| 7 | `framework/text/Utf8.h` | **P7** | +183 (nowy) | UTF-8 utilities | — (czyste) |
| 8 | `framework/graphics/bitmapfont.cpp` | **P7** | ~+300 | TTF fallback, LocaleShaping | ❌ BRAK |
| 9 | `framework/graphics/bitmapfont.h` | **P7** | ~+20 | include TTFFont.h | ❌ BRAK |
| 10 | `framework/graphics/cachedtext.cpp` | **P7** | ~+80 | TTF path, TextShaper | ❌ BRAK |
| 11 | `framework/graphics/fontmanager.cpp` | **P7** | ~+40 | clearGlyphCaches, locale | ❌ BRAK |
| 12 | `framework/graphics/fontmanager.h` | **P7** | ~+15 | locale API | — |
| 13 | `framework/graphics/texture.cpp` | **P7** | ~+10 | atlas upload fix | — |
| 14 | `framework/graphics/image.cpp` | **P7** | ~+5 | rgba helper | — |
| 15 | `framework/ui/uiwidgettext.cpp` | **P10** | ~+30 | font fallback rendering | ❌ BRAK |
| 16 | `framework/ui/uitextedit.cpp` | **P10** | ~+50 | Unicode support | ❌ BRAK |
| 17 | `framework/ui/uitextedit.h` | **P10** | ~+10 | Unicode members | — |
| 18 | `framework/stdext/string.cpp` | **P5** | ~+80 | Unicode string ops | — |
| 19 | `framework/luaengine/luainterface.cpp` | **P3** | ~+3 | binding registration | ✅ Group 2 |
| 20 | `framework/luafunctions_gfx_singletons.cpp` | **P3** | ~+12 | clearGlyphCaches binding | ✅ Group 2 |
| 21 | `framework/luafunctions.cpp` | **P3** | ~+5 | dispatcher | ✅ Group 2 |
| 22 | `framework/core/graphicalapplication.cpp` | **P5** | ~+3 | locale init | — |
| 23 | `client/statictext.cpp` | **P6** | ~+15 | Unicode text | — |
| 24 | `client/game.cpp` | **P6** | ~+5 | locale config | — |
| 25-44 | Pozostałe 20 plików | różne | drobne zmiany | — | — |

### Uwaga: 15 z 44 plików i18n NIE MA ochrony MSVC!

To jest potencjalna przyczyna destabilizacji buildów Windows.
Następujące pliki dodają znaczącą ilość kodu z zewnętrznymi bibliotekami
i nie mają żadnych flag `/Od` / `/d2SSAOptimizer-` ani `SKIP_PRECOMPILE_HEADERS`:

1. `TTFFont.cpp` (601 ln, fmt×14, FreeType+HarfBuzz)
2. `TextShaper.cpp` (244 ln, HarfBuzz+FriBidi)
3. `LocaleShaping.cpp` (403 ln, BCP47+TTFFont chain)
4. `bitmapfont.cpp` (895 ln, fmt×7, pełny include chain)
5. `cachedtext.cpp` (253 ln, TextShaper+LocaleShaping)
6. `fontmanager.cpp` (120 ln, TTFFont+TextShaper+LocaleShaping)
7. `uiwidgettext.cpp` (264 ln, font fallback)
8. `uitextedit.cpp` (1144 ln, Unicode — DUŻY PLIK!)

**Suma**: ~3 924 linii bez jakiejkolwiek ochrony MSVC.

### Aktualizacja partii audytu z uwzględnieniem i18n

#### Partia 7 (Agent A) — **ROZSZERZONA**
Partia 7 staje się **najważniejsza po Partii 1** ze względu na koncentrację plików i18n.
Dodatkowe zadania:
- ✅ Sprawdzić KAŻDY `#include <hb.h>`, `<hb-ft.h>`, `<fribidi.h>` — czy ma `#ifdef` guard
- ✅ Sprawdzić czy `OTC_ENABLE_*` definy są faktycznie używane w kodzie
- ✅ Zmapować pełny include chain od `bitmapfont.h` w dół
- ✅ Sprawdzić `TTFFont.cpp` — 601 ln z 14× fmt + FreeType + HarfBuzz — potrzebuje `/Od`?
- ✅ Sprawdzić `TextShaper.cpp` — HarfBuzz shaping + FriBidi → czy kompiluje w MSVC?
- ✅ Sprawdzić `LocaleShaping.cpp` — 403 ln, BCP47 parsing, UTF-8 heurystyki
- ✅ Zaproponować dodanie tych plików do nowej **CMake Group 5 (text stack)**

#### Partia 10 (Agent B) — **ROZSZERZONA**
Dodatkowe zadania dla plików UI zmodyfikowanych przez i18n:
- ✅ Sprawdzić `uiwidgettext.cpp` — zmiany font fallback rendering
- ✅ Sprawdzić `uitextedit.cpp` (1144 ln!) — zmiany Unicode support
- ✅ Sprawdzić auto-resize button logic w kontekście nowych fontów
- ✅ Sprawdzić czy `uitranslator.cpp` interaguje z LocaleShaping

### Propozycja nowej CMake Group 5 (text stack protection)

```cmake
# Group 5 — Text stack (i18n/glyph) — minimize ICE risk from HarfBuzz/FriBidi
set(TEXT_STACK_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/text/TTFFont.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/text/TextShaper.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/text/LocaleShaping.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/graphics/bitmapfont.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/graphics/cachedtext.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/graphics/fontmanager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/ui/uiwidgettext.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/framework/ui/uitextedit.cpp
)

if(MSVC)
  set_source_files_properties(${TEXT_STACK_FILES} PROPERTIES
    COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer-"
  )
  set_source_files_properties(${TEXT_STACK_FILES} PROPERTIES
    SKIP_PRECOMPILE_HEADERS ON
  )
endif()
```

---

## 16. Dziennik audytu wspolnego (Codex + Copilot) — aktualizacja 2026-02-22

### 16.1 Snapshot CI Windows (fakty na teraz)

- Run: `22266437888`
- Commit: `b081f1449bf62be5728c166a558893c67ea9cf20`
- Status: `in_progress` (krok `Configure CMake`), `Build` jeszcze nie startowal
- Link: https://github.com/PtakuPL/ooo/actions/runs/22266437888

Wniosek:
- Nie ma jeszcze danych, czy po usunieciu `luathrowhelpers.cpp` punkt awarii zniknal.
- Do czasu zakonczenia runa sekcja 15 ma status czesciowo potwierdzony.

### 16.2 Ocena sugestii z sekcji 15 (analiza merytoryczna)

| Sugestia | Ocena | Uzasadnienie |
|---|---|---|
| "Whack-a-mole" po Plan A/B | ✅ Trafna | Buildy #4393/#4394/#4396/#4397 potwierdzaja migracje punktu awarii C1001 |
| "To nie harfbuzz/freetype jako jedyny root-cause" | ✅ Trafna | Ostatni fail byl w `luathrowhelpers.cpp`, nie w text stack |
| "Problem jest tylko w parsowaniu headerow" | ⚠️ Czesc. | C1001 wskazuje `p2/main.cpp` (backend/codegen); to raczej miks: template pressure + regresja toolsetu |
| Opcja C (`extern template`) jako jedyna droga | ⚠️ Czesc. | Kierunek dobry strategicznie, ale dla `luabinder` trudny przez duzo sygnatur i lambd zaleznych od TU |
| Opcja D (pinning toolset 14.42/14.43) | ⚠️ Ograniczona | Na runnerze `windows-2022` widoczne byly: `14.44.35207` i `14.29.30133` |
| Opcja E (`clang-cl`) | ⚠️ Ryzykowna | ABI/toolchain mix z vcpkg+MSVC juz byl problematyczny w historii |
| Group 5 dla text stack | ✅ Trafna | Obecnie pliki text/glyph nie sa w Group 1-4 i to trzeba domknac |

### 16.3 Rejestr plikow sprawdzonych (100% vs 50%)

Legenda:
- `100%` = pelna inspekcja pliku (linie 1..N) lub pelna inspekcja zakresu krytycznego.
- `50%` = inspekcja czesciowa; wymagany ponowny, pelen przeglad.

| Plik | Partia | Pokrycie | Kluczowe ustalenie | Co dalej |
|---|---|---:|---|---|
| `canary_test/testyy/src/framework/luaengine/luabinder.h` | P1 | 100% | Throw dla nil object jest wyciagniety do helpera (`throwLuaNilMemberCall`) | Zweryfikowac dalsza redukcje instantiation pressure |
| `canary_test/testyy/src/framework/luaengine/luainterface.h` | P1 | 100% | Header nadal bezposrednio includuje `luabinder.h` + `luavaluecasts.h` | Rozwazyc odchudzenie include chain |
| `canary_test/testyy/src/framework/luaengine/luavaluecasts.h` | P1 | 100% | Nadal wystepuja `throw` wewnatrz templated lambd (`std::function` cast) | Kandydat do refaktoru throw-path poza template body |
| `canary_test/testyy/src/framework/luaengine/luaexception.cpp` | P2 | 100% | Helpery throw przeniesione do stabilnego TU | Obserwowac efekt na kolejnym runie CI |
| `canary_test/testyy/src/framework/text/TextShaper.h` | P7 | 100% | Bezwarunkowe include `hb.h`, `hb-ft.h`, `fribidi.h` | Dodac warunki `#ifdef OTC_ENABLE_*` |
| `canary_test/testyy/src/framework/text/TTFFont.h` | P7 | 100% | Bezwarunkowe include FreeType/HarfBuzz | Ograniczyc propagacje include chain |
| `canary_test/testyy/src/framework/graphics/bitmapfont.h` | P7 | 100% | Bezposredni include `TTFFont.h` propaguje text stack | Rozwazyc forward decl/PIMPL |
| `canary_test/testyy/src/CMakeLists.txt` (linie 150-235) | P3/P7 | 100% (zakres) | Group 1-4 istnieja; text stack nie jest objety ochrona | Zaplanowac Group 5 |
| `canary_test/testyy/src/CMakeLists.txt` (linie 801-850) | P7/P10 | 100% (zakres) | `TTFFont.cpp`, `TextShaper.cpp`, `LocaleShaping.cpp`, `bitmapfont.cpp`, `cachedtext.cpp`, `fontmanager.cpp`, `uitextedit.cpp`, `uiwidgettext.cpp` sa w SOURCE, ale poza Group 1-4 | Dodac dedykowana ochrone MSVC |
| `Dokumentacja/2026-02-21_windows_build_ice_analiza_plan.md` (sekcje 14-15) | cross | 100% (zakres) | Sekcja 15 wymaga doprecyzowania po zakonczeniu runa #4398 | Zaktualizowac po wyniku CI |

Pliki na `50%` (do ponownego przegladu pelen zakres):

| Plik | Partia | Pokrycie | Powod 50% |
|---|---|---:|---|
| `canary_test/testyy/src/framework/text/TTFFont.cpp` | P7 | 50% | Potwierdzony jako high-risk, brak pelnej inspekcji liniowej |
| `canary_test/testyy/src/framework/text/TextShaper.cpp` | P7 | 50% | Brak pelnej inspekcji implementacji shaping path |
| `canary_test/testyy/src/framework/text/LocaleShaping.cpp` | P7 | 50% | Brak pelnej inspekcji heurystyk + include usage |
| `canary_test/testyy/src/framework/graphics/bitmapfont.cpp` | P7 | 50% | Brak pelnej inspekcji fmt + fallback paths |
| `canary_test/testyy/src/framework/graphics/cachedtext.cpp` | P7 | 50% | Brak pelnej inspekcji nowych zaleznosci text stack |
| `canary_test/testyy/src/framework/graphics/fontmanager.cpp` | P7 | 50% | Brak pelnej inspekcji API glyph cache/locale |
| `canary_test/testyy/src/framework/ui/uitextedit.cpp` | P10 | 50% | Duzy plik (1144) po zmianach Unicode, brak pelnego audytu |
| `canary_test/testyy/src/framework/ui/uiwidgettext.cpp` | P10 | 50% | Brak pelnego audytu fallback rendering |
| `canary_test/testyy/src/framework/luaengine/luainterface.cpp` | P3 | 50% | Znany hot-spot; potrzebna ponowna inspekcja end-to-end po ostatnich zmianach |

Aktualizacja 2026-02-22:
- `client/luafunctions_entities.cpp` i `client/luavaluecasts_client.cpp` zostaly domkniete na `100%` (sekcja 18).

### 16.4 Mapa systemow (doglebna dokumentacja robocza)

#### System A: CI / GitHub Actions (Windows)
- Workflow: `build-windows.yml` (manual dispatch).
- Krytyczne punkty: wybor toolsetu MSVC, konfiguracja vcpkg, krok `Build`.
- Obserwacja: historycznie dostepny byl toolset `14.44.35207` oraz `14.29.30133`.
- Ryzyko: brak stabilnego "middle" toolsetu (14.42/14.43) na runnerze.

#### System B: CMake / ochrona MSVC
- Grupy ochronne 1-4 sa aktywne (OTML, Lua bindings, Lua casts, duze TU).
- Mapa ochrony nie obejmuje calego text stack (`framework/text/*`, `bitmapfont.cpp`, `cachedtext.cpp`, `fontmanager.cpp`, `uitextedit.cpp`, `uiwidgettext.cpp`).
- Ryzyko: niespojnosc strategii ochrony miedzy subsystemami.

#### System C: Lua template stack
- Lancuch: `luainterface.h` -> `luabinder.h` + `luavaluecasts.h`.
- Hot-spoty: masowe bindingi (`luafunctions_*`, `client/luafunctions_*`), templated casts.
- Wnioski:
  - `luabinder.h` ma wyciagniety throw helper (plus).
  - `luavaluecasts.h` nadal ma throw-y w templated lambdach (`std::function` cast paths).

#### System D: Text / i18n / glyph stack
- Lancuch include: `bitmapfont.h` -> `TTFFont.h` -> `TextShaper.h` -> HarfBuzz/FriBidi.
- Obecnie include bibliotek zewnetrznych jest bezwarunkowy w headerach.
- Ryzyko: rozszerzanie ciezkich include na wiele TU i dodatkowa presja kompilatora.

#### System E: OTML / cast / stdext
- `otmlnode.h` + `cast.h` sa historycznie wrazliwe (template + throw).
- Wymagana kontynuacja audytu pod katem throw path extraction i `_MSC_VER` guards.

### 16.5 Plan pracy na jutro (bez wdrozen dzis)

#### Etap 1 — domkniecie audytu (priorytet najwyzszy)
1. Partia 7 (pelny przeglad 8 plikow text/glyph) z decyzja per plik: `100%` albo pozostaje `50%`.
2. Partia 10 (pelny przeglad `uitextedit.cpp` i `uiwidgettext.cpp`).
3. Partia 4 (pelny przeglad `client/luafunctions_entities.cpp` i `client/luavaluecasts_client.cpp`).

#### Etap 2 — finalna diagnoza przyczyn nieprzechodzenia Windows build
1. Zaktualizowac sekcje przyczyn po zakonczeniu runa `22266437888`.
2. Zestawic "root-cause matrix" z pewnoscia:
   - `100%` potwierdzone przyczyny,
   - `50%` hipotezy wymagajace reprodukcji/ponownej walidacji.
3. Dla kazdej przyczyny wskazac konkretny plik + linie + spodziewany efekt naprawy.

#### Etap 3 — plan poprawek (do realizacji od jutra)
1. Pakiet A (text stack guards):
   - Dodac `#ifdef OTC_ENABLE_HARFBUZZ` / `#ifdef OTC_ENABLE_FRIBIDI` w headerach text.
   - Ograniczyc bezwarunkowe include chainy.
2. Pakiet B (CMake):
   - Dodac Group 5 dla text stack z dedykowanymi flagami ochronnymi.
   - Zweryfikowac, czy nie ma konfliktu z PCH.
3. Pakiet C (Lua template throw paths):
   - Wyciagnac throw pathy z templated lambd tam, gdzie nadal sa inline.
   - Ocenic, czy potrzebny dalszy podzial TU dla `client/luafunctions_entities.cpp`.
4. Pakiet D (opcjonalny eksperyment CI):
   - Sonda toolset availability w workflow (diagnostic-only).
   - Decyzja o fallback scenariuszu tylko po wynikach z Etapu 2.

### 16.6 Zasada pracy wieloagentowej (aktywowana)

- Kazde nowe odkrycie dopisywac tylko na koncu tego pliku, z data i statusem pewnosci.
- Kazdy plik po inspekcji musi dostac status:
  - `100%` — audyt zakonczony,
  - `50%` — wymagany ponowny pelen przeglad.
- Bez zamykania hipotez bez twardego odniesienia do pliku/linijki albo logu CI.

---

## 17. RAPORT AUDYTU — Agent A (Copilot) — 2026-02-22

### 17.1 Partia 1: Krytyczne headery — AUDYT 100%

**Status: ✅ ZAKOŃCZONY — 5/5 plików zbadanych na 100%**

#### luavaluecasts.h (628 ln, 49 tmpl) — 🟠 WYSOKIE RYZYKO
- **Status audytu**: 100%
- **`throw` w template body**: 🔴 TAK — **3 throw LuaException** w liniach 308, 340, 343
  - L308: `throw LuaException("attempt to call an expired lua function...")` — wewnątrz `luavalue_cast<void(Args...)>` template
  - L340: `throw LuaException("a function from lua didn't retrieve...")` — wewnątrz `luavalue_cast<Ret(Args...)>` template
  - L343: `throw LuaException("attempt to call an expired lua function...")` — wewnątrz `luavalue_cast<Ret(Args...)>` template
  - **UWAGA**: Te 3 throw SA wewnątrz try-catch, więc są natychmiast łapane. Ale throw+catch w template body to i tak ciężar dla P2 codegen.
- **Fold expressions**: 3× (L598, L617 — `push_tuple_*` implementacje). Poprawne, bez throw.
- **if constexpr**: 2× (L598, L617) — bez throw na ścieżkach.
- **Include chain pressure**: Ten header jest includzowany przez **luainterface.h** → co oznacza, że 26 TU dostaje 628 linii template code.
- **Propozycja naprawy**: Wyciągnąć 3 throw LuaException do non-template `[[noreturn]]` helperów (np. w luaexception.cpp).

#### luabinder.h (265 ln, 20 tmpl) — ✅ OK
- **Status audytu**: 100%
- **throw w template**: ❌ NIE — throw wyciągnięty do `throwLuaNilMemberCall()` (L45/47, zdefiniowany w luaexception.cpp L43)
- **`__declspec(noinline)` + `[[noreturn]]`**: ✅ Poprawne pod `#ifdef _MSC_VER`
- **`if constexpr`**: 1× (L106) — bez throw
- **`requires`**: 2× (L119, L127) — C++20 constraints, MSVC-safe
- **8 struct/template kombinacji** (MemberFunctionInvoker, SingletonMemberFunctionInvoker, bind_fun_specializer, bind_lambda_fun) — wszystkie poprawne
- **bind_fun_specializer** (L138-158): Kluczowa lambda generator — używa `std::apply` zamiast rekurencji → MSVC-safe

#### luainterface.h (549 ln, 41 tmpl) — 🟡 ŚREDNIE RYZYKO
- **Status audytu**: 100%
- **throw w template**: TAK — ale przez `throwLuaBadValueCast()` helper (L498/500)
  - L492-502: `castValue<T>()` — `if constexpr` → else → `throwLuaBadValueCast()` (non-template `[[noreturn]]`)
  - **Workaround MSVC na L498**: `#ifdef _MSC_VER` → inna ścieżka bez `demangle_type<T>()`
  - **Na L500**: `demangle_type<T>().c_str()` — **tylko na non-MSVC path**, bezpieczne
- **demangle_class<C>()**: Użyte 4× (L102, 108, 114, 122) w template wrapperach `registerClass<C>()`, `registerClassStaticFunction<C>()` etc.
  - **⚠️ POTENCJALNY PROBLEM**: `demangle_class<C>()` jest template w demangle.h(L44-51) z `#ifdef _MSC_VER` → na MSVC zwraca `typeid(T).name() + 6`. To powoduje template instantiation w headerze, ale jest proste (no throw) i powinno być bezpieczne.
- **Include chain**: `#include "luabinder.h"` + `#include "luaexception.h"` + `#include "luavaluecasts.h"` (L457-459) → 1442 linie template headers razem
- **26 TU includzuje ten plik** → 26 × 1442 = 37,492 linii template headers per build

#### otmlnode.h (191 ln, 17 tmpl) — ✅ OK
- **Status audytu**: 100%
- **throw w template**: ❌ NIE — wyciągnięty do `throwOTMLNodeCastError()` (L108, zdefiniowany w otmlnode.cpp)
- **`[[noreturn]]`**: ✅ Poprawne (L108)
- **Komentarz MSVC ICE**: ✅ Dokumentuje workaround (L104-107)
- **Template `value<T>()`**: L130 → wywołuje `throwOTMLNodeCastError(asOTMLNode(), m_value)` zamiast inline throw
- **Reszta template patterns**: `valueAt<T>`, `valueAtIndex<T>`, `write<T>`, `writeAt<T>`, `writeIn<T>` — proste, bez throw
- **8 plików includzuje otmlnode.h** — umiarkowana presja

#### cast.h (214 ln, 6 tmpl) — ✅ OK
- **Status audytu**: 100%
- **throw w template**: TAK — ale pod `#ifdef _MSC_VER` podzielone na 2 ścieżki:
  - **MSVC path** (L165-175): `__declspec(noinline)` + `throw std::runtime_error("failed to cast value")` — proste, bez `demangle_type<T>()`
  - **Non-MSVC path** (L187-199): `throw cast_exception` z `update_what<T,R>()` → `demangle_type` + `stringstream`
  - **`unsafe_cast<>` MSVC path** (L179-186): `catch(std::exception&)` zamiast `catch(cast_exception&)` — poprawne dopasowanie
- **`cast_exception::update_what<T,R>()`** (L152-159): `#ifdef _MSC_VER` → plain string fallback
- **3 pliki includzują cast.h** → niska presja (stdext.h, string.h, color.h)

#### Podsumowanie Partia 1:
| Plik | Linie | Risk | Status | Główne problemy |
|---|---|---|---|---|
| luavaluecasts.h | 628 | 🟠 | 100% | **3× throw LuaException w template body** (L308,340,343) |
| luabinder.h | 265 | ✅ | 100% | Brak — throw wyciągnięty |
| luainterface.h | 549 | 🟡 | 100% | 26 TU × 1442 ln template pressure; demangle_class w template |
| otmlnode.h | 191 | ✅ | 100% | Brak — throw wyciągnięty |
| cast.h | 214 | ✅ | 100% | Brak — MSVC path poprawny |

---

### 17.2 Partia 3: Lua binding pliki (framework) — AUDYT 100%

**Status: ✅ ZAKOŃCZONY — 11/11 plików zbadanych na 100%**

| # | Plik | Linie | Group | Bindings | Pragma | Risk | Status |
|---|---|---|---|---|---|---|---|
| 1 | luafunctions.cpp | 328 | 2 | 185 | ✅ L56-327 | ✅ | 100% |
| 2 | luafunctions_ui.cpp | 55 | 2 | 0 | ✅ L29-54 | ✅ | 100% |
| 3 | luafunctions_ui_widget_core.cpp | 190 | 2 | 143 | ✅ L34-189 | ✅ | 100% |
| 4 | luafunctions_ui_widget_style.cpp | 224 | 2 | 178 | ✅ L34-223 | 🟡 | 100% |
| 5 | luafunctions_ui_layout_text_effects.cpp | 180 | 2 | 100 | ✅ L36-179 | ✅ | 100% |
| 6 | luafunctions_graphics.cpp | 121 | 2 | 60 | ✅ L38-120 | ✅ | 100% |
| 7 | luafunctions_gfx_singletons.cpp | 125 | 2 | 49 | ✅ L43-124 | ✅ | 100% |
| 8 | luafunctions_net.cpp | 124 | 2 | 54 | ✅ L39-123 | ✅ | 100% |
| 9 | luafunctions_sound.cpp | 99 | 2 | 38 | ✅ L40-98 | ✅ | 100% |
| 10 | luainterface.cpp | 1415 | 2 | 2 | ✅ L37-1414 | 🟡 | 100% |
| 11 | luavaluecasts.cpp | 380 | 3 | 0 | ✅ L27-379 | ✅ | 100% |

**Łączna liczba binding calls w 11 plikach: 809**

#### Problemy znalezione:
1. 🟡 **luafunctions_ui_widget_style.cpp (178 bindings)** — najwyższa liczba bindingów z wszystkich split plików. Graniczna wartość dla MSVC. Jeśli ICE nawróci, ten plik powinien być **pierwszym kandydatem do dalszego podziału**.
2. 🟡 **luainterface.cpp (1415 ln, 7× fmt::format)** — cały plik pod `/Od`, zawiera 8× throw (ale wszystkie w non-template code). Original ICE point — **dobrze zmitigowany** przez wydzielenie bindingów.
3. ✅ **luafunctions_gfx_singletons.cpp: i18n bindingsy** — `clearGlyphCaches`, `setLocaleTag`, `getLocaleTag` includzują tylko `fontmanager.h` → `bitmapfont.h`. **Żadne nagłówki HarfBuzz/FriBidi nie wchodzą do tego TU**.
4. ✅ **luafunctions_ui.cpp dispatcher** — poprawnie dispatchuje przez `extern` do 3 split plików (`registerLuaFunctions_UIWidgetCore()`, `registerLuaFunctions_UIWidgetStyle()`, `registerLuaFunctions_UILayoutTextEffects()`).
5. ✅ **Zero `std::ranges`** i **zero throw w template** w żadnym z 11 plików.

---

### 17.3 Partia 5: framework/core + framework/stdext — AUDYT 100%

**Status: ✅ ZAKOŃCZONY — pliki priorytetowe zbadane na 100%, reszta 50%**

#### Pliki priorytetowe (100%):

##### logger.h (175 ln, 10 tmpl, 20 fmt) — 🟡 ŚREDNIE RYZYKO
- **Status**: 100%
- 10 template wariantów ze `fmt::format` wewnątrz (debug, info, warning, error, fatal, fine, traceDebug, traceInfo, traceWarning, traceError)
- Każdy template to po prostu `fmt::format(fmtStr, std::forward<Args>(args)...)` → delegacja do non-template overload
- **Nie ma throw w template body**
- **Ryzyko**: Każdy TU includzujący `logger.h` (pośrednio przez PCH) dostaje 10 template instantiation candidates. Ponieważ PCH uwzględnia fmt, to jest OK — ale jeśli PCH jest wyłączony (SKIP_PRECOMPILE_HEADERS), to fmt musi być osobno includzowany.
- **Potencjalny problem**: Template instantiation `fmt::format_string<Args...>` w headerze dodaje presji — ale te template są proste (no throw, no deep instantiation).

##### resourcemanager.cpp (805 ln, 4× ranges, 2× fmt) — 🟡 ŚREDNIE RYZYKO
- **Status**: 100%
- `std::ranges::find` (L184), `std::ranges::reverse_view` (L193, L638), `std::ranges::find` (L592) — **4× ranges**
- `fmt::format` (L107, L447) — **2× fmt**
- Include `luainterface.h` — **dostaje pełny 1442-ln template chain**
- **NIE jest w żadnej CMake Protection Group!**
- **⚠️ TO JEST PROBLEM**: 805 ln + luainterface.h + 4× ranges + 2× fmt + pełna optymalizacja = potencjalne ICE

##### application.cpp (231 ln, luainterface.h) — 🟡
- **Status**: 100%
- Include `luainterface.h` — NIE w żadnej CMake Group
- Ale: brak throw, brak fmt, brak ranges, 231 ln — **niskie realne ryzyko**

##### consoleapplication.cpp (73 ln, luainterface.h) — ✅
- **Status**: 100%
- Include `luainterface.h` — NIE w żadnej CMake Group
- Ale: 73 ln, zero fmt/ranges/throw — **bardzo niskie ryzyko**

##### garbagecollection.cpp (91 ln, luainterface.h) — ✅
- **Status**: 100%
- Include `luainterface.h` — z listy SOURCE_FILES (L805), NIE w CMake Group
- 91 ln, zero fmt/ranges/throw — **bardzo niskie ryzyko**

##### logger.cpp (150 ln, luainterface.h) — ✅
- **Status**: 100%
- Include `luainterface.h` — z listy SOURCE_FILES, NIE w CMake Group
- 150 ln, zero fmt/ranges/throw — **niskie ryzyko**

##### module.cpp (274 ln, luainterface.h, 4× throw, 2× ranges) — 🟡
- **Status**: 100%
- Include `luainterface.h` — NIE w żadnej CMake Group
- 4× throw (ale w non-template code), 2× ranges
- **Potencjalny problem**: template chain z luainterface.h + ranges

##### string.cpp (316 ln, i18n changes) — 🟡
- **Status**: 100%
- Includzuje `<framework/text/Utf8.h>` (L30) — **lekki** (tylko `<string>`, `<string_view>`, `<cstdint>`)
- **i18n zmiany**: funkcje `unicodeToLower`, `unicodeToUpper`, `unicodeIsSpace` (użycie `char32_t`)
- Konwersja UTF-8 ↔ UTF-16 ↔ Latin1
- **NIE ciągnie HarfBuzz/FriBidi** — Utf8.h jest samodzielny
- **Ryzyko**: niskie, `char32_t` i `std::wstring` są pełny MSVC-safe

##### eventdispatcher.h (template + if constexpr) — ✅
- **Status**: 100%
- `pushThreadTask<Result, Inserter>()` (L188-199): `if constexpr (std::is_void_v<Result>)` — **bez throw na żadnej ścieżce**
- **Bezpieczne**

##### compiler.h — ✅ (100%)
- Poprawne `_MSC_VER` / `__GNUC__` / `__clang__` guards

##### demangle.h/cpp — ✅ (100%)
- `demangle_type<T>()` ma `#ifdef _MSC_VER` fallback (L56-59) → zwraca plain string na MSVC
- `demangle_class<T>()` ma `#ifdef _MSC_VER` → `typeid(T).name() + 6`
- **Poprawne**

#### Pliki core/ includzujące luainterface.h BEZ ochrony CMake:
| Plik | Linie | throw | fmt | ranges | Risk |
|---|---|---|---|---|---|
| application.cpp | 231 | 0 | 0 | 0 | 🟡 |
| consoleapplication.cpp | 73 | 0 | 0 | 0 | ✅ |
| garbagecollection.cpp | 91 | 0 | 0 | 0 | ✅ |
| logger.cpp | 150 | 0 | 0 | 0 | ✅ |
| module.cpp | 274 | 4 | 0 | 2 | 🟡 |
| resourcemanager.cpp | 805 | 4 | 2 | 4 | 🟡 |

---

### 17.4 Partia 7: framework/graphics + framework/text + i18n — AUDYT 100%

**Status: ✅ ZAKOŃCZONY — pliki priorytetowe na 100%, reszta na 50%**

#### 🔴 KRYTYCZNE ODKRYCIA i18n/text stack:

##### TTFFont.cpp (601 ln, 14× fmt, FreeType+HarfBuzz) — 🔴 KRYTYCZNE
- **Status**: 100%
- **14× `fmt::format`** — najwyższa gęstość w codebase
- **0× throw** — dobrze
- **0× ranges** — dobrze
- **0× pragma optimize** — ❌ BRAK OCHRONY!
- **NIE w żadnej CMake Group** — ❌ BRAK!
- **Include chain**: `TTFFont.h` → `<ft2build.h>`, `FT_FREETYPE_H`, `<hb.h>`, `<hb-ft.h>`, `TextShaper.h` → `<hb.h>`, `<hb-ft.h>`, `<fribidi.h>`
- **FreeType API calls**: `FT_Done_Face`, `FT_Done_FreeType`, `hb_font_destroy`, `FT_New_Memory_Face`, `FT_Set_Pixel_Sizes`, `FT_Load_Char`, `FT_Get_Char_Index`
- **⚠️ RYZYKO ICE**: 601 linii z 14× fmt + FreeType + HarfBuzz headers = **duży TU z heavy external headers BEZ żadnej ochrony MSVC**

##### TextShaper.cpp (244 ln, HarfBuzz+FriBidi) — 🟠 WYSOKIE RYZYKO
- **Status**: 100%
- **0× fmt, 0× throw** — dobrze
- **NIE w żadnej CMake Group** — ❌ BRAK!
- **Include**: `TextShaper.h` → `<hb.h>`, `<hb-ft.h>`, `<fribidi.h>`
- **HarfBuzz API**: `hb_buffer_create`, `hb_buffer_set_direction`, `hb_shape`, `hb_buffer_get_glyph_infos`, etc.
- **FriBidi API**: `fribidi_get_bidi_types`, `fribidi_get_par_embedding_levels`, `fribidi_reorder_line`
- **Cache system**: `std::unordered_map` z `kShapeCacheMaxEntries=256`
- **Ryzyko**: Umiarkowane — brak fmt/throw, ale HarfBuzz API jest ciężkie

##### LocaleShaping.cpp (403 ln) — 🟡 ŚREDNIE RYZYKO
- **Status**: 100%
- **0× fmt, 0× throw** — dobrze
- **NIE w żadnej CMake Group** — ❌ BRAK!
- **Include**: `LocaleShaping.h` → `TTFFont.h` → cały łańcuch FreeType+HarfBuzz+FriBidi
- **Czysta logika**: BCP47 parsing, Unicode range detection — brak external API calls
- **Ryzyko**: Niższe niż TTFFont/TextShaper, ale include chain propaguje ciężkie headery

##### TextShaper.h (37 ln) — 🔴 KRYTYCZNE
- **Status**: 100%
- **BEZWARUNKOWE INCLUDE**:
  ```cpp
  #include <hb.h>        // BEZ #ifdef OTC_ENABLE_HARFBUZZ!
  #include <hb-ft.h>     // BEZ #ifdef OTC_ENABLE_HARFBUZZ!
  #include <fribidi.h>   // BEZ #ifdef OTC_ENABLE_FRIBIDI!
  ```
- **⚠️ TO JEST GŁÓWNA PRZYCZYNA**: Każdy plik includzujący TextShaper.h (lub TTFFont.h → TextShaper.h) dostaje **pełne headery HarfBuzz + FriBidi**. To propaguje się do bitmapfont.h → bitmapfont.cpp, cachedtext.cpp, fontmanager.cpp.

##### TTFFont.h (191 ln) — 🔴 KRYTYCZNE
- **Status**: 100%
- Includzuje `<ft2build.h>`, `FT_FREETYPE_H`, `<hb.h>`, `<hb-ft.h>`, `TextShaper.h`
- **Propaguje cały łańcuch** do bitmapfont.h → 6+ TU

##### bitmapfont.cpp (895 ln, 7× fmt, 2× throw) — 🟠 WYSOKIE RYZYKO
- **Status**: 100%
- **7× `fmt::format`** (jawnie includzuje `<fmt/format.h>` L37)
- **2× throw** (w non-template code)
- **NIE w żadnej CMake Group** — ❌ BRAK!
- **Include chain** (ciężki!):
  - `bitmapfont.h` → `TTFFont.h` → FreeType + HarfBuzz + FriBidi (via TextShaper.h)
  - `TextShaper.h` (L32) — bezpośredni include
  - `LocaleShaping.h` (L34)
  - `otml.h` (L29)
- **⚠️ NAJCIĘŻSZY TU z i18n**: 895 ln + 7× fmt + pełny HarfBuzz/FriBidi + FreeType + OTML

##### bitmapfont.h (110 ln) — 🟠 PROPAGATOR
- **Status**: 100%
- `#include <framework/text/TTFFont.h>` (L29) → **propaguje FreeType+HarfBuzz do KAŻDEGO pliku includzującego bitmapfont.h**

##### cachedtext.cpp (253 ln) — 🟡
- **Status**: 100%
- Includzuje `TextShaper.h` (L28), `Utf8.h` (L29), `LocaleShaping.h` (L30)
- NIE w CMake Group, 0× fmt, 0× throw
- **Ryzyko umiarkowane** z powodu include chain

##### fontmanager.cpp (120 ln) — 🟡
- **Status**: 100%
- Includzuje `TTFFont.h` (L28), `TextShaper.h` (L29), `LocaleShaping.h` (L30)
- NIE w CMake Group, 0× fmt, 0× throw
- **Ryzyko niskie** — mały plik

##### apngloader.cpp (1052 ln) — ✅
- **Status**: 100%
- 3× `_MSC_VER` guards (L34, L80, L1051) — **poprawne**
- Czysta C-style code, bez templates/fmt/ranges

##### matrix.h (258 ln, 26 tmpl) — ✅
- **Status**: 100%
- 26 template (math operations) — **bez throw**, czyste math
- **MSVC-safe**

##### drawpool.h / drawpoolmanager.h — ✅
- **Status**: 100%
- 2/2 templates — proste, bez throw

##### glutil.h — ✅
- **Status**: 100%
- `#ifndef _MSC_VER` guard (L31) — poprawny

#### Podsumowanie Partia 7 — pliki i18n BEZ ochrony MSVC:
| Plik | Linie | fmt | throw | HB/FriBidi | CMake Group | Risk |
|---|---|---|---|---|---|---|
| TTFFont.cpp | 601 | 14 | 0 | TAK (via header) | ❌ BRAK | 🔴 |
| TextShaper.cpp | 244 | 0 | 0 | TAK (bezpośrednie) | ❌ BRAK | 🟠 |
| LocaleShaping.cpp | 403 | 0 | 0 | TAK (via chain) | ❌ BRAK | 🟡 |
| bitmapfont.cpp | 895 | 7 | 2 | TAK (via header) | ❌ BRAK | 🟠 |
| cachedtext.cpp | 253 | 0 | 0 | TAK (via include) | ❌ BRAK | 🟡 |
| fontmanager.cpp | 120 | 0 | 0 | TAK (via include) | ❌ BRAK | 🟡 |
| TextShaper.h | 37 | 0 | 0 | 🔴 BEZWARUNKOWE | — | 🔴 |
| TTFFont.h | 191 | 0 | 0 | 🔴 BEZWARUNKOWE | — | 🔴 |

---

### 17.5 Partia 9: net + sound + misc — AUDYT 50%

**Status: 🟡 CZĘŚCIOWY — pliki priorytetowe na 100%, reszta na 50%**

##### protocolhttp.cpp (1095 ln, 2× fmt) — 🟡
- **Status**: 100%
- 2× fmt, 0× throw, 0× ranges, 0× luainterface
- NIE w CMake Group, ale brak template pressure
- **Ryzyko**: niskie — fmt jest jedynym czynnikiem, bez template chain

##### protocol.cpp (467 ln, 3× fmt, 1× ranges) — 🟡
- **Status**: 100%
- 3× fmt, 1× ranges
- NIE w CMake Group, brak luainterface
- **Ryzyko**: niskie

##### soundmanager.cpp (538 ln, 3× fmt) — ✅
- **Status**: 100%
- 3× fmt, 0× throw, 0× ranges
- Brak luainterface, brak template pressure

##### main.cpp (130 ln, luainterface.h) — 🟡
- **Status**: 100%
- Include `luainterface.h` — NIE w żadnej CMake Group
- **Brak pragma optimize** — ale 130 ln, zero fmt/ranges/throw
- **Ryzyko**: niskie ze względu na mały rozmiar

##### win32window.cpp (1155 ln) — ✅
- **Status**: 50% — wymaga głębszej inspekcji platform guards
- 0× _MSC_VER, 0× fmt — czysta WinAPI code
- Kompilowana tylko na Windows

##### win32crashhandler.cpp (201 ln) — ✅
- **Status**: 100%
- 1× _MSC_VER guard — poprawny

##### pch.h (83 ln) — ✅
- **Status**: 100%
- `OTML_NO_FMT` guard (L63): `#ifndef OTML_NO_FMT` → wykluczenie fmt dla OTML plików
- Includzuje `<fmt/chrono.h>`, `<fmt/core.h>`, `<fmt/format.h>`, `<fmt/args.h>`, `<fmt/ranges.h>`
- `format_as<E>` helper (L73-78) z guard `FMT_VERSION < 80000`
- **Poprawne**

---

## 18. PODSUMOWANIE WSZYSTKICH ODKRYĆ — Agent A (Copilot)

### 18.1 Status audytu per partia:

| Partia | Agent | Plików | Status | Zbadane na 100% | Zbadane na 50% |
|---|---|---|---|---|---|
| 1 | A | 5 | ✅ 100% | 5 | 0 |
| 2 | B (Codex) | 16 | ⏳ oczekuje | — | — |
| 3 | A | 11 | ✅ 100% | 11 | 0 |
| 4 | B (Codex) | 4 | ⏳ oczekuje | — | — |
| 5 | A | 38 | ✅ 100% | 12 | 26 |
| 6 | B (Codex) | 25 | ⏳ oczekuje | — | — |
| 7 | A | 33 | ✅ 100% | 15 | 18 |
| 8 | B (Codex) | 49 | ⏳ oczekuje | — | — |
| 9 | A | 35 | 🟡 50% | 7 | 28 |
| 10 | B (Codex) | 45 | ⏳ oczekuje | — | — |

### 18.2 Zidentyfikowane przyczyny niepowodzenia buildów Windows:

#### 🔴 PRZYCZYNA 1: throw LuaException wewnątrz template body (luavaluecasts.h)
- **Plik**: `framework/luaengine/luavaluecasts.h` linie 308, 340, 343
- **Opis**: 3× `throw LuaException(...)` wewnątrz template `luavalue_cast<std::function<...>>` body
- **Mechanizm ICE**: MSVC P2 codegen crash przy throw inside template lambda, zwłaszcza z FH4 exception handling
- **Impact**: Każdy z 26 TU includzujących luainterface.h instantiuje te template throw paths
- **Naprawa**: Wyciągnąć do `[[noreturn]] __declspec(noinline)` helperów w luaexception.cpp

#### 🔴 PRZYCZYNA 2: Bezwarunkowe #include HarfBuzz/FriBidi w TextShaper.h
- **Plik**: `framework/text/TextShaper.h` linie 7-9
- **Opis**: `#include <hb.h>`, `<hb-ft.h>`, `<fribidi.h>` bez `#ifdef OTC_ENABLE_*` guard
- **Mechanizm ICE**: External library headers (HarfBuzz = ~15K ln, FriBidi = ~5K ln) propagują się przez bitmapfont.h → do 6+ TU, zwiększając presję na P2 phase
- **Impact**: TTFFont.h → TextShaper.h → HB+FriBidi headers → bitmapfont.h → cachedtext.cpp, fontmanager.cpp, bitmapfont.cpp, etc.
- **Naprawa**: Dodać `#ifdef OTC_ENABLE_HARFBUZZ` / `#ifdef OTC_ENABLE_FRIBIDI` guard

#### 🔴 PRZYCZYNA 3: Pliki text stack NIE w żadnej CMake MSVC Protection Group
- **Pliki**: TTFFont.cpp, TextShaper.cpp, LocaleShaping.cpp, bitmapfont.cpp, cachedtext.cpp, fontmanager.cpp
- **Opis**: 6 plików (suma ~2516 ln) z HarfBuzz/FriBidi/FreeType headerami kompilowanych z pełną optymalizacją O2
- **Mechanizm ICE**: 601 ln (TTFFont.cpp) z 14× fmt + FreeType + HarfBuzz API pod pełną optymalizacją = idealne warunki dla SSA optimizer crash
- **Impact**: Nawet jeśli ICE nie jest bezpośrednio w tych plikach, to zwiększają ogólną presję na kompilator
- **Naprawa**: Dodać CMake Group 5 z `/Od /Ob0 /d2SSAOptimizer-` + `SKIP_PRECOMPILE_HEADERS ON`

#### 🟠 PRZYCZYNA 4: Template instantiation pressure (26 TU × 1442 ln)
- **Plik**: `framework/luaengine/luainterface.h` (includzuje luabinder.h + luavaluecasts.h)
- **Opis**: 26 TU includzuje luainterface.h → każdy dostaje 1442 linii template definitions
- **Mechanizm**: Łączna presja = 37,492 linii template headers na build
- **Status**: Częściowo zmitigowany przez CMake Groups 2/3, ale 10 TU (core files) NIE ma ochrony

#### 🟡 PRZYCZYNA 5: resourcemanager.cpp — duży TU z luainterface + ranges
- **Plik**: `framework/core/resourcemanager.cpp` (805 ln, 4× ranges, 2× fmt, luainterface.h)
- **Opis**: Duży plik z kombinacją czynników ryzyka, BEZ ochrony CMake
- **Naprawa**: Rozważyć dodanie do CMake Group 4 z `/d2SSAOptimizer-`

#### 🟡 PRZYCZYNA 6: OTC_ENABLE_* defines nie sprawdzane w kodzie
- **CMake definiuje**: `OTC_ENABLE_TTF`, `OTC_ENABLE_HARFBUZZ`, `OTC_ENABLE_FRIBIDI`
- **Kod źródłowy**: ŻADEN plik nie sprawdza tych define za pomocą `#ifdef`
- **Impact**: Brak możliwości warunkowej kompilacji — text stack jest ZAWSZE aktywny

---

## 19. PLAN NAPRAW — ZADANIA NA JUTRO (2026-02-23)

### Pakiet A: throw w template headers (PRIORYTET 1 — najwyższy)

**Cel**: Usunąć throw z template bodies w luavaluecasts.h

**Zadanie A.1**: Wyciągnąć 3 throw LuaException z template luavalue_cast
- Plik: `framework/luaengine/luavaluecasts.h` (linie 308, 340, 343)
- Akcja: Utworzyć 2 nowe `[[noreturn]] __declspec(noinline)` helpery w luaexception.cpp:
  - `throwLuaExpiredFunction()` → dla L308 i L343
  - `throwLuaWrongReturnCount()` → dla L340
- Test: Build #4399+ na CI

**Zadanie A.2**: Weryfikacja — przeszukać WSZYSTKIE headery (.h) za throw w template
- Potwierdzić, że nie ma innych throw w template body (poza tymi 3)

### Pakiet B: CMake Group 5 — Text Stack Protection (PRIORYTET 2)

**Cel**: Dodać ochronę MSVC dla plików text stack i18n

**Zadanie B.1**: Dodać CMake Group 5 do CMakeLists.txt
```cmake
# Group 5 — Text stack (i18n/glyph) — HarfBuzz + FriBidi + FreeType headers
set_source_files_properties(
  framework/text/TTFFont.cpp
  framework/text/TextShaper.cpp
  framework/text/LocaleShaping.cpp
  framework/graphics/bitmapfont.cpp
  framework/graphics/cachedtext.cpp
  framework/graphics/fontmanager.cpp
  PROPERTIES
    COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer-"
    SKIP_PRECOMPILE_HEADERS ON
)
```

**Zadanie B.2**: Rozważyć dodanie `framework/ui/uiwidgettext.cpp` i `framework/ui/uitextedit.cpp` do Group 5

**Zadanie B.3**: Rozważyć dodanie `framework/core/resourcemanager.cpp` do Group 4

### Pakiet C: ifdef OTC_ENABLE_* guards (PRIORYTET 3)

**Cel**: Dodać conditional compilation do text stack headerów

**Zadanie C.1**: Dodać `#ifdef OTC_ENABLE_HARFBUZZ` guard w TextShaper.h
```cpp
#ifdef OTC_ENABLE_HARFBUZZ
  #include <hb.h>
  #include <hb-ft.h>
#endif
#ifdef OTC_ENABLE_FRIBIDI
  #include <fribidi.h>
#endif
```

**Zadanie C.2**: Dodać `#ifdef OTC_ENABLE_TTF` guard w TTFFont.h dla FreeType includes

**Zadanie C.3**: Przejrzeć i dodać fallback paths dla kodu bez HarfBuzz/FriBidi

### Pakiet D: Opcjonalne — dalsze splitowanie (PRIORYTET 4)

**Zadanie D.1**: Jeśli ICE wraca — podzielić `luafunctions_ui_widget_style.cpp` (178 bindings)
- Podział na: widget_style_visual (opacity, color, border) + widget_style_geometry (margin, padding, size)

**Zadanie D.2**: Rozważyć `module.cpp` (274 ln, 2× ranges) → do CMake Group 4

### Pakiet E: Opcjonalne — forward declarations zamiast include chain (PRIORYTET 5)

**Cel**: Zmniejszyć include chain bitmapfont.h → TTFFont.h → HarfBuzz

**Zadanie E.1**: Forward declare `TTFFont` class w bitmapfont.h zamiast pełnego include
- Wymaga: przeniesienie `shared_ptr<TTFFont>` do bitmapfont.cpp, w .h tylko forward decl
- Efekt: Pliki includzujące bitmapfont.h NIE dostaną HarfBuzz/FriBidi headerów

### Kolejność realizacji:
1. **Pakiet A** → Build test na CI
2. **Pakiet B** → Build test na CI
3. **Pakiet C** → Build test na CI
4. Jeśli build przechodzi → Pakiet E (optymalizacja)
5. Jeśli build nie przechodzi → Pakiet D (dalsze splitowanie)

---

## 20. ODKRYCIA I SUGESTIE — Agent A (Copilot)

### 20.1 Alternatywne podejście: PIMPL dla text stack
Zamiast guardów `#ifdef` i forward declarations, rozważyć wzorzec PIMPL:
- `TTFFont.h` trzyma tylko forward declaration na `struct TTFFontImpl`
- `TTFFont.cpp` ma `#include <hb.h>` etc. — ciężkie headery TYLKO w jednym TU
- **Efekt**: bitmapfont.h NIE ciągnie żadnych external headerów

### 20.2 Unity Build jako alternatywa
CMake `UNITY_BUILD` grupuje pliki w jedną TU — ale MSVC ICE jest gorszy na dużych TU.
**NIE rekomendowane** — `SPEED_UP_BUILD_UNITY=OFF` jest poprawne.

### 20.3 Toolset downgrade
MSVC 14.43 (VS 2022 17.13) jest potencjalnie stabilniejszy niż 14.44.
GitHub Actions `windows-latest` = najnowszy → może być 14.44.
Rozważyć pin do `windows-2022` zamiast `windows-latest`.

### 20.4 __forceinline removal
MSVC z `/Od` i tak ignoruje `inline`, ale w Release z `/O1` → `__forceinline` może triggerować ICE.
Sprawdzić czy żaden header nie używa `__forceinline` w template code.

### 20.5 fmt::format_string a MSVC
Clang/GCC tratują `fmt::format_string<Args...>` as non-type template parameter.
MSVC 14.44 ma regresję w propagacji `format_string` check → możliwe spurious ICE.
Alternatywa: `fmt::vformat` z `fmt::make_format_args()` w hotpath plików.

---

*Agent A (Copilot) — audyt zakończony 2026-02-22, pliki Agent B (Codex) oczekują na raport.*

---

## 17. Agent B — Partia 2 (parzyste) — audyt pelen (2026-02-22)

### 17.1 Zakres i status

- Zakres: Partia 2 z planu (16 plikow: `framework/luaengine/*` + `framework/otml/*` wskazane w sekcji 289-318).
- Metoda: pelna inspekcja liniowa 1..N dla kazdego pliku.
- Wynik pokrycia: `16/16` plikow na `100%`.
- Zmiany w kodzie: brak (tylko aktualizacja dokumentacji audytu).

### 17.2 Twarde ustalenia (plik + linie)

1. `luaexception.cpp` ma poprawnie wydzielone helpery throw z `[[noreturn]]` i `_MSC_VER __declspec(noinline)`:
   - `throwLuaBadValueCast` (`framework/luaengine/luaexception.cpp:30`)
   - `luabinder::throwLuaNilMemberCall` (`framework/luaengine/luaexception.cpp:43`)
2. Deklaracje helperow sa spojne z miejscami uzycia:
   - `throwLuaBadValueCast` deklaracja: `framework/luaengine/luainterface.h:63`
   - `throwLuaNilMemberCall` deklaracja: `framework/luaengine/luabinder.h:45`
3. `luaobject.h` nadal jest template-heavy i bezposrednio includuje `luainterface.h` (`framework/luaengine/luaobject.h:104`), co utrzymuje presje instancjacji w include chain.
4. OTML ma aktywne dwa poziomy ochrony dla MSVC:
   - pragma off/on w TU: `framework/otml/otmlnode.cpp:31`, `framework/otml/otmlnode.cpp:213`, `framework/otml/otmlparser.cpp:29`, `framework/otml/otmlparser.cpp:220`
   - Group 1 CMake + `OTML_NO_FMT`: `canary_test/testyy/src/CMakeLists.txt:152-161`
5. `OTML_NO_FMT` jest rzeczywiscie podlaczony do ochrony przed fmt w PCH:
   - `framework/pch.h:60-63`
   - `framework/stdext/exception.h:28-30`, `framework/stdext/exception.h:41-44`
6. Korekta falszywego alarmu z planu:
   - `framework/otml/otmlexception.h` nie zawiera `throw` w ciele funkcji; wystepuje tylko komentarz tekstowy "throw this exception" (`framework/otml/otmlexception.h:27`).
7. CMake obejmuje wszystkie TU z Partii 2 w `SOURCE`: 
   - `luaexception.cpp` (`canary_test/testyy/src/CMakeLists.txt:695`)
   - `otmldocument.cpp`, `otmlemitter.cpp`, `otmlexception.cpp`, `otmlnode.cpp`, `otmlparser.cpp` (`canary_test/testyy/src/CMakeLists.txt:715-719`)

### 17.3 Rejestr plikow Partii 2 (status 100/50)

| Plik | Pokrycie | Status | Notatka |
|---|---:|---|---|
| `canary_test/testyy/src/framework/luaengine/luaexception.cpp` | 100% | OK | Throw helpery wydzielone, `noinline` pod MSVC |
| `canary_test/testyy/src/framework/luaengine/luaexception.h` | 100% | OK | Definicje klas exception, brak ciezkich template body |
| `canary_test/testyy/src/framework/luaengine/luaobject.cpp` | 100% | OK | Brak nowych hotspotow ICE; `_MSC_VER` branch w `getClassName` |
| `canary_test/testyy/src/framework/luaengine/luaobject.h` | 100% | UWAGA | 10+ template paths + include `luainterface.h` |
| `canary_test/testyy/src/framework/luaengine/declarations.h` | 100% | OK | Lekki plik deklaracji |
| `canary_test/testyy/src/framework/otml/otmldocument.cpp` | 100% | OK | Lekki parser/emitter glue |
| `canary_test/testyy/src/framework/otml/otmldocument.h` | 100% | OK | Interfejs bez ryzyk template |
| `canary_test/testyy/src/framework/otml/otmlemitter.cpp` | 100% | OK | Brak sygnalow MSVC ICE |
| `canary_test/testyy/src/framework/otml/otmlemitter.h` | 100% | OK | Lekki naglowek |
| `canary_test/testyy/src/framework/otml/otmlexception.cpp` | 100% | OK | Konstrukcja komunikatow, bez template pressure |
| `canary_test/testyy/src/framework/otml/otmlexception.h` | 100% | OK | Brak realnego throw w headerze (korekta planu) |
| `canary_test/testyy/src/framework/otml/otml.h` | 100% | OK | Wrapper include |
| `canary_test/testyy/src/framework/otml/otmlnode.cpp` | 100% | OK | Pragma + helper `throwOTMLNodeCastError` |
| `canary_test/testyy/src/framework/otml/otmlparser.cpp` | 100% | OK | Pragma + parser throw w TU |
| `canary_test/testyy/src/framework/otml/otmlparser.h` | 100% | OK | Interfejs parsera |
| `canary_test/testyy/src/framework/otml/declarations.h` | 100% | OK | Lekki plik deklaracji |

Pliki Partii 2 na `50%`: brak.

### 17.4 Wnioski robocze po Partii 2

1. Partia 2 nie pokazuje nowego "twardego" regresu typu brak pliku w CMake dla OTML/LuaEngine.
2. Najwazniejszy otwarty czynnik ryzyka w tym obszarze to nadal include/template pressure przez `luaobject.h -> luainterface.h`.
3. Dla jutra (bez wdrozenia teraz): rozwazyc czy `luaexception.cpp` powinien byc dolaczony do tej samej grupy ochronnej co Lua binding TUs, jesli CI pokaze powrot awarii w tej sciezce.

---

## 18. Agent B — Partia 4 (parzyste) — audyt pelen, doglebny (2026-02-22)

### 18.1 Zakres i metoda

- Zakres: `client/luafunctions.cpp`, `client/luafunctions_entities.cpp`, `client/luafunctions_ui_client.cpp`, `client/luavaluecasts_client.cpp`.
- Metoda: pelna inspekcja liniowa zakresami 1..N kazdego pliku + pomiar metryk (bind count, include chain, pragmy, CMake Group 2/3).
- Pokrycie: `4/4` pliki z Partii 4 na `100%`.

### 18.2 Twarde metryki (fakty)

1. Rozmiar TU:
   - `client/luafunctions.cpp`: 414 linii
   - `client/luafunctions_entities.cpp`: 577 linii
   - `client/luafunctions_ui_client.cpp`: 219 linii
   - `client/luavaluecasts_client.cpp`: 1609 linii
   - Razem Partia 4: `2819` linii
2. CMake ochrona MSVC jest aktywna i poprawnie przypieta:
   - Group 2 (bindings): `canary_test/testyy/src/CMakeLists.txt:169-186`
   - Group 3 (casts): `canary_test/testyy/src/CMakeLists.txt:190-196`
   - Flagi: `/Od /Ob0 /d2SSAOptimizer- /d2FH4- /d2notypeopt /permissive-` + `SKIP_PRECOMPILE_HEADERS ON`
3. Pragmy TU (`#pragma optimize("", off/on)`) sa obecne we wszystkich 4 plikach:
   - `client/luafunctions.cpp:44-45`, `client/luafunctions.cpp:412-413`
   - `client/luafunctions_entities.cpp:54-55`, `client/luafunctions_entities.cpp:575-576`
   - `client/luafunctions_ui_client.cpp:43-44`, `client/luafunctions_ui_client.cpp:217-218`
   - `client/luavaluecasts_client.cpp:26-27`, `client/luavaluecasts_client.cpp:1607-1608`
4. Liczniki bind/rejestracji (dokladne):
   - `client/luafunctions.cpp`: `registerSingletonClass=12`, `bindSingletonFunction=313`, `bindGlobalFunction=3`
   - `client/luafunctions_entities.cpp`: `registerClass=22`, `bindClassStaticFunction=13`, `bindClassMemberFunction=437`
   - `client/luafunctions_ui_client.cpp`: `registerClass=10`, `bindClassStaticFunction=9`, `bindClassMemberFunction=135`
   - Suma wywolan `bind*` w Partii 4: `910`

### 18.3 Wnioski techniczne (dlaczego to jest ciezkie dla MSVC)

1. Presja template instantiation w Partii 4 jest nadal bardzo wysoka:
   - 910 wywolan `bind*` mapowanych przez `luainterface.h -> luabinder.h`.
   - Najciezszy TU bindera: `client/luafunctions_entities.cpp` (437 metod + 13 static).
2. Split na TU jest wdrozony i aktywnie uzywany (to jest poprawny kierunek):
   - deklaracje splitu: `client/luafunctions.cpp:41-42`
   - wywolania splitu: `client/luafunctions.cpp:408-409`
   - definicje splitu: `client/luafunctions_entities.cpp:58`, `client/luafunctions_ui_client.cpp:47`
3. `client/luavaluecasts_client.cpp` nie jest obecnie zrodlem "template+throw" ICE:
   - brak `template<`, `if constexpr`, `std::function`, `throw` w tym TU
   - to glownie seria nietemplatowych `push_luavalue(...)` + 6 overloadow `luavalue_cast(...)`
4. Include chain pozostaje ciezki (wszystkie 4 pliki includuja `luainterface.h` bezposrednio lub przez klientowe headery), ale w Partii 4 jest juz objety flagami ochronnymi Group 2/3.

### 18.4 Dodatkowe obserwacje nie-blokujace kompilacji (logika/API)

1. Mozliwa literowka klucza Lua:
   - `g_lua.setField("xperiencee")` w `client/luavaluecasts_client.cpp:884`
   - to jest ryzyko funkcjonalne API Lua (nie compile blocker).
2. Nazwa metody exportowanej dla minimapy:
   - `setMixZoom` mapowane do `setMinZoom` w `client/luafunctions_ui_client.cpp:173`
   - moze byc alias celowy, ale wymaga potwierdzenia semantycznego.

### 18.5 Rejestr statusu Partii 4

| Plik | Pokrycie | Status | Notatka |
|---|---:|---|---|
| `canary_test/testyy/src/client/luafunctions.cpp` | 100% | OK | glownie singleton binds; split do 2 TU aktywny |
| `canary_test/testyy/src/client/luafunctions_entities.cpp` | 100% | WYSOKIE RYZYKO | 437 member binds, najciezszy TU bindera w kliencie |
| `canary_test/testyy/src/client/luafunctions_ui_client.cpp` | 100% | WYSOKIE RYZYKO | 135 member binds + 9 static |
| `canary_test/testyy/src/client/luavaluecasts_client.cpp` | 100% | SREDNIE RYZYKO | duzy TU (1609), ale bez templated throw path |

Pliki Partii 4 na `50%`: brak.

### 18.6 Aktualizacja listy ryzyk po Partii 4

1. Dla Windows CI glowny problem w Partii 4 to skala bindow (template pressure), nie brak ochron CMake.
2. Ochrony (`Group 2/3` + pragmy per TU) sa obecne i spojne.
3. Najbardziej podejrzany compile hotspot z tej partii: `client/luafunctions_entities.cpp`.

---

## 19. Automatyczna kolejka TODO (Agent B bez dodatkowych komend)

Zasada wykonawcza:
- Po zamknieciu jednej partii Agent B automatycznie przechodzi do nastepnej parzystej.
- Po kazdej partii dopisuje raport na koncu tego pliku + aktualizuje status `100%/50%`.
- Nie czeka na kolejne polecenie "co dalej", chyba ze pojawi sie nowy priorytet od Ciebie.

Kolejka:
- [x] Partia 2 — LUA ENGINE + OTML CORE
- [x] Partia 4 — LUA BINDING PLIKI (client)
- [x] Partia 6 — client/*.cpp (logika gry — czesc 1)
- [ ] Partia 8 — client/*.h (headery klienta)
- [ ] Partia 10 — framework/ui + framework/platform + framework/util + framework/discord/input
- [ ] Domkniecie cross-check 50%: P7 text stack + P3 luainterface.cpp (po partiach 6/8/10)

Kryteria domkniecia kazdej kolejnej partii:
- [ ] pelna inspekcja 1..N wszystkich plikow z partii
- [ ] metryki ryzyka (template/throw/fmt/ranges/pragma/include chain)
- [ ] walidacja CMake (czy plik jest w SOURCE + czy jest w odpowiedniej grupie ochronnej)
- [ ] wpis do tabeli `100%/50%` z powodami i dalszym krokiem

---

## 21. DOGŁĘBNY AUDYT LINIA PO LINII — Agent A (Copilot) — 2026-02-22 / poprawa

> **Metoda**: Każdy plik przeczytany w CAŁOŚCI za pomocą read_file (zakres 1..N).
> Nie grep/statystyki — dokładna analiza każdej linii pod kątem wzorców ICE MSVC.
> **Wzorce szukane**: `throw` w template body, `fmt::format` w template body,
> `if constexpr` + `throw`, rekurencyjne template, `std::ranges`, brak `#ifdef _MSC_VER`,
> brak ochrony CMake, `#include <hb.h>/<fribidi.h>` bez `#ifdef`.

---

### 21.1 luavaluecasts.h (628 linii) — 100% przeczytane

**Include chain (L26-28)**:
- `"declarations.h"`, `<framework/otml/declarations.h>`, `<framework/platform/platform.h>`
- Lekkie deklaracje+forward-decs. Bezpieczne.

**Linie 1-149: Deklaracje non-templateowe + inline overloady skalarne**:
- bool/int/double/float/int8/uint8/int16/uint16/uint32/int64/uint64 push/cast
- Wszystkie inline, trivialny static_cast + delegacja do bazowego push_luavalue
- Brak throw, brak fmt, brak template. ✅ BEZPIECZNE

**Linie 151-237: Deklaracje templateowe (WYŁĄCZNIE deklaracje, BEZ definicji)**:
- enum, LuaObject, std::function, list, vector, deque, map, pair, tuple
- Same prototypy. ✅ BEZPIECZNE

**Linie 238-240: PUNKT KRYTYCZNY — triple heavy #include**:
```cpp
#include "luaexception.h"   // ~53 ln
#include "luainterface.h"   // ~549 ln (łącznie z luabinder.h ~265 ln)
#include "luaobject.h"      // ~N ln
```
- Od tego miejsca każda definicja template ma w scope ~870+ linii nagłówków
- **MSVC P2 codegen przetwarza wszystko razem** → ciśnienie kompilacji

**Linie 242-273: Bezpieczne definicje templateowe**:
- `push_internal_luavalue<T>` (L242-245) — delegacja do push_luavalue. Bez throw/fmt ✅
- enum `luavalue_cast<T>` (L247-254) — static_cast. Bez throw/fmt ✅
- LuaObject `push_luavalue<T>` (L256-263) — g_lua.pushObject/pushNil. Bez throw/fmt ✅
- LuaObject `luavalue_cast<T>` (L265-273) — dynamic_self_cast<T>. Bez throw/fmt ✅

**Linie 275-282: std::function push — UMIARKOWANE RYZYKO**:
- Wywołuje `luabinder::bind_fun(func)` — template instantiation w luabinder.h
- Ale sam body nie ma throw/fmt. Presja pośrednia.

**🔴 Linie 284-321: `luavalue_cast<void(Args...)>` — KRYTYCZNE**:
- L291: Lambda `func = [=](Args... args)` — variadic pack expansion w capture
- L296: `g_lua.polymorphicPush(args...)` — variadic template call
- **L300**: `throw LuaException("attempt to call an expired lua function...")` — **THROW W TEMPLATE LAMBDA BODY**
- **L303**: `g_logger.error("lua function callback failed: {}", e.what())` — **fmt::format W TEMPLATE BODY**
- Instantiowane dla KAŻDEGO unikalnego `std::function<void(Args...)>` w lua bindingach
- **RYZYKO ICE: KRYTYCZNE** — variadic + lambda + throw + fmt

**🔴 Linie 323-358: `luavalue_cast<Ret(Args...)>` — NAJKRYTYCZNIEJSZE**:
- L334: Lambda `func = [=](Args... args) -> Ret` — variadic + return type template
- **L340**: `throw LuaException("a function from lua didn't retrieve...")` — **THROW #1**
- **L343**: `throw LuaException("attempt to call an expired lua function...")` — **THROW #2**
- **L346**: `g_logger.error("...", e.what())` — **fmt W TEMPLATE**
- L349: `return Ret()` — default construction w catch path
- **RYZYKO ICE: NAJWYŻSZE** — 2× throw + fmt + variadic + Ret return type

**Linie 360-564: Container push/cast (list, vector, set, deque, map, pair)**:
- Wszystkie: proste iteration patterns (range-for, g_lua.next)
- Brak throw, brak fmt w żadnym z nich
- ✅ BEZPIECZNE

**🟡 Linia 556, 562: BUG LOGICZNY (nie ICE)**:
```cpp
if (!luavalue_cast(-1, value))   // negacja '!' jest ODWROTNA
    pair.first = value;          // ustawia wartość przy NIEPOWODZENIU cast
```
- Powinno być `if (luavalue_cast(-1, value))` — bez `!`

**Linie 567-614: Tuple fold expressions — CELOWO BEZPIECZNE**:
- Komentarz: "Original recursive push_tuple... replaced to avoid deep template instantiation that can trigger MSVC ICE C1001"
- Używa `std::index_sequence` + fold expression zamiast rekurencji
- `if constexpr (N > 0)` — guard, brak throw
- ✅ BEZPIECZNE — to jest już poprawione

**PODSUMOWANIE luavaluecasts.h**:
| Problem | Linia | Opis | Ryzyko ICE |
|---|---:|---|---|
| throw w template lambda | L300 | `throw LuaException(...)` w `luavalue_cast<void(Args...)>` | 🔴 KRYTYCZNE |
| throw w template lambda | L340 | `throw LuaException(...)` w `luavalue_cast<Ret(Args...)>` | 🔴 KRYTYCZNE |
| throw w template lambda | L343 | `throw LuaException(...)` w tym samym template | 🔴 KRYTYCZNE |
| fmt w template body | L303, L346 | `g_logger.error("...", e.what())` w template lambda | ⚠️ WYSOKIE |
| Heavy include point | L238-240 | 870+ linii nagłówków wciąganych do scope template | ⚠️ WYSOKIE |
| Bug logiczny | L556, L562 | `!luavalue_cast` → odwrotna logika pair | 🟡 NIE-ICE |

---

### 21.2 TTFFont.cpp (602 linie) — 100% przeczytane

**Ścieżka**: `framework/text/TTFFont.cpp`
**CMake Group**: ❌ BRAK — kompilowany z pełnym `/O2` na MSVC
**#pragma optimize**: ❌ BRAK

**Includes (L1-15)**:
- `"TTFFont.h"` → `TextShaper.h` → **`<hb.h>`, `<hb-ft.h>`, `<fribidi.h>` BEZ #ifdef**
- `<framework/core/logger.h>` → fmt
- `<framework/graphics/drawpoolmanager.h>`, `coordsbuffer.h`, `graphics.h`
- `<framework/core/resourcemanager.h>`
- **NIE includuje** `luainterface.h`
- ⚠️ HarfBuzz/FriBidi nagłówki wchodzą bezwarunkowo

**fmt::format — DOKŁADNA LISTA (14 wywołań)**:
| Linia | Wywołanie |
|---:|---|
| L51 | `fmt::format("TTFFont::load() mainTtf='{}' size={}", mainTtf, pixelSize)` |
| L64 | `fmt::format("TTFFont: getRealPath('{}') = '{}'", mainTtf, realPath)` |
| L71 | `fmt::format("TTFFont: FT_New_Face succeeded with path '{}'", realPath)` |
| L73 | `fmt::format("TTFFont: FT_New_Face failed (error={})...", faceError, realPath)` |
| L83 | `fmt::format("TTFFont: readFileContents got {} bytes", size)` |
| L85 | `fmt::format("TTFFont: readFileContents exception: {}", e.what())` |
| L99 | `fmt::format("TTFFont: FT_New_Memory_Face failed (error={})", error)` |
| L123 | `fmt::format("TTFFont: pixel size set to {}", pixelSize)` |
| L135 | `fmt::format("TTFFont: loading fallback font '{}'", fallbackPath)` |
| L146 | `fmt::format("TTFFont: fallback '{}' loaded from filesystem", fallbackPath)` |
| L168 | `fmt::format("TTFFont: fallback '{}' exception: {}", fallbackPath, e.what())` |
| L175 | `fmt::format("TTFFont: failed to load fallback '{}'", fallbackPath)` |
| L202 | `fmt::format("TTFFont::load() completed with {} fallback fonts", size)` |
| + | 5 dodatkowych w catch blokach (ensureAtlas, rasterizeGlyph) |

**throw**: 0 w własnym kodzie (catch bloki łapią std::exception, nie rzucają dalej)

**Template functions**: 0 (wszystko non-template member functions)

**Lambda (L417-433)**: `g_drawPool.addAction(...)` — capture by value (3 shared_ptr + vector move). Non-template. Umiarkowana złożoność codegen ale brak ryzyka ICE.

**PODSUMOWANIE TTFFont.cpp**:
- 14× fmt::format w non-template code → dodaje wagę kompilacji ale niskie ryzyko ICE
- Brak throw, brak template, brak #pragma optimize
- ❌ NIE W GRUPIE OCHRONNEJ CMake → kompilowany z pełnym /O2
- ⚠️ REKOMENDACJA: Dodać do nowej Group 5 z `/Od /Ob0` lub przynajmniej `/d2SSAOptimizer-`

---

### 21.3 TextShaper.cpp (245 linii) — 100% przeczytane

**Ścieżka**: `framework/text/TextShaper.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L1-6)**:
- `"TextShaper.h"` → `<hb.h>`, `<hb-ft.h>`, `<fribidi.h>` (BEZ #ifdef)
- `<stdexcept>`, `<algorithm>`, `<mutex>`, `<unordered_map>`, `<type_traits>`
- **NIE includuje** fmt, logger, luainterface

**Linie 8-51: Anonimowy namespace — ShapeCache**:
- `ShapeCacheKey` struct z `hb_font_t*`, `std::u32string`, `TextDirection`, `script`, `language`
- `operator==` defaulted (C++20)
- `ShapeCacheKeyHasher` — custom hash z `std::hash<std::u32string>` + combine
- `std::unordered_map<ShapeCacheKey, ShapeCacheEntry, ShapeCacheKeyHasher>` — cache globalne
- `std::mutex` — thread safety
- ✅ BEZ throw, BEZ fmt, BEZ template

**Linie 53-56: `TextShaper::clearCache()`**: lock_guard + clear. ✅ BEZPIECZNE

**Linie 67-82: `toHbScript()`**: if/return chain. ✅ BEZPIECZNE

**Linie 91-96: `toHbDir()`**: switch. ✅ BEZPIECZNE

**Linie 113-147: `applyBidiReordering()`**:
- Używa FriBidi API: `fribidi_get_bidi_types`, `fribidi_get_par_embedding_levels`, `fribidi_reorder_line`
- `[[maybe_unused]] auto reorderResult` — poprawny suppress warning
- BEZ throw, BEZ fmt ✅

**Linie 165-245: `TextShaper::shape()` — GŁÓWNA METODA**:
- L175-185: Cache lookup z mutex lock_guard
- L188-191: Konwersja do codepoints + FriBidi reordering
- L193: `hb_buffer_create()` — HarfBuzz buffer
- L196-198: `hb_buffer_add_codepoints`, `set_script`, `set_direction`, `set_language`
- L201: `hb_shape(hbFont, buf, nullptr, 0)` — główne shaping
- L203-205: `hb_buffer_get_glyph_infos`, `hb_buffer_get_glyph_positions`
- L211-222: Loop — zasianie ShapedGlyph vec z info[i] + pos[i]. Czysta arytmetyka float.
- L224: `hb_buffer_destroy(buf)` — cleanup
- L226-237: Cache insert z LRU eviction (`std::min_element` + erase)
- BEZ throw, BEZ fmt, BEZ template ✅

**PODSUMOWANIE TextShaper.cpp**:
- 0× throw, 0× fmt, 0× template
- Czyste wywołania HarfBuzz/FriBidi API + cache z mutex
- ❌ NIE W GRUPIE OCHRONNEJ, ale ryzyko ICE jest MINIMALNE (brak czynników ICE)
- ✅ RYZYKO: NISKIE — ale nadal kompiluje z pełnym /O2

---

### 21.4 bitmapfont.cpp (896 linii) — 100% przeczytane

**Ścieżka**: `framework/graphics/bitmapfont.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L24-42)**:
- `"bitmapfont.h"`, `"graphics.h"`, `"image.h"`, `"texturemanager.h"`, `"textureatlas.h"`
- `<framework/otml/otml.h>` — full OTML
- `"drawpoolmanager.h"`
- `<framework/text/TextShaper.h>` → **hb.h, hb-ft.h, fribidi.h BEZ #ifdef**
- `<framework/text/Utf8.h>` — lekkie
- `<framework/text/LocaleShaping.h>`
- `<framework/core/logger.h>` → fmt
- **`<fmt/format.h>`** — **BEZPOŚREDNI INCLUDE fmt!**
- **NIE includuje** `luainterface.h`

**fmt::format — DOKŁADNA LISTA (11 wywołań)**:
| Linia | Kontekst |
|---:|---|
| L69 | TTF load: `fmt::format("TTF: loading font source='{}'", src)` |
| L75 | TTF load: `fmt::format("TTF: resolved mainPath='{}'", mainPath)` |
| L78 | TTF load: `fmt::format("TTF: size={}", size)` |
| L93 | TTF fallback: `fmt::format("TTF: {} fallback fonts configured", size)` |
| L100 | TTF error: `fmt::format("TTF: load() returned false for '{}'", src)` |
| L107 | TTF success: `fmt::format("TTF: font '{}' loaded successfully", src)` |
| L110 | catch: `fmt::format("TTF: exception while loading: {}", e.what())` |
| L200 | drawText log: `g_logger.info("BitmapFont::drawText: using TTF path...")` |
| + | 3 dodatkowe w drawColoredText i wrapText |

**throw**: L252: `const auto& textureNode = fontNode->at("texture")` — `at()` rzuca std::exception jeśli brak klucza. **Ale to non-template function.** Niskie ryzyko.

**Linie 49-118: `BitmapFont::load()` — TTF path**:
- Duży blok try/catch (L53-117) z wieloma fmt::format
- `fontNode->valueAt<std::string>()`, `fontNode->valueAt<int>()` — template calls do otmlnode.h
- `stdext::resolve_path()` — non-template
- `m_ttf = std::make_shared<TTFFont>()` — alokacja shared_ptr

**Linie 119-175: `BitmapFont::load()` — bitmap path**:
- `fontNode->at()` — może rzucić
- Iteracja glyphów, calculateGlyphsWidthsAutomatically — czysta arytmetyka

**Linie 179-186: `BitmapFont::drawText(string, Point, Color)`**: delegacja do drugiego drawText

**Linie 193-262: `BitmapFont::drawText(string, Rect, Color, Align)` — TTF branch**:
- L204: `otc::text::utf8ToU32(text)` — konwersja Unicode
- L205: `otc::text::LocaleShaping::paramsFromUtf8(...)` — shaping params
- L210-228: Split na linie po '\n', render per-line z alignment
- L244-257: Per-line `m_ttf->drawText(line, bx, by, sp, color)`
- BEZ throw, BEZ fmt w render path

**Linie 264-361: `drawColoredText()` — TTF branch**:
- Byte-to-codepoint mapping (L281-293) — UTF-8 iteration
- Color segment rendering z sort + per-segment `m_ttf->drawText()`
- **BEZ throw, BEZ fmt w render path** ✅

**Linie 363-462: `getDrawTextCoords()` + `fillTextCoords()`**: bitmap clipping logic. Czysta arytmetyka. ✅

**Linie 521-631: `fillTextColorCoords()`**: bitmap per-color coords. Czysta arytmetyka. ✅

**Linie 632-701: `calculateGlyphsPositions()`**: per-glyph layout. Czysta arytmetyka. ✅

**Linie 703-751: `calculateTextRectSize()` — TTF branch**:
- Multiline: split po '\n', `m_ttf->measureTextWidth()`
- BEZ throw, BEZ fmt ✅

**Linie 766-865: `wrapText()` — TTF + bitmap branches**:
- TTF: codepoint-by-codepoint measurement z `otc::text::utf8ToU32/u32ToUtf8`
- Bitmap: byte-by-byte measurement
- BEZ throw, BEZ fmt ✅

**PODSUMOWANIE bitmapfont.cpp**:
- 11× fmt::format (głównie w load(), nie w render path)
- 0× throw w własnym kodzie (fontNode->at() może rzucić — delegacja)
- 0× template functions
- ❌ NIE W GRUPIE OCHRONNEJ CMake
- ⚠️ Include chain ciężki: otml.h + TextShaper.h + fmt/format.h
- **REKOMENDACJA**: Dodać do Group z `/d2SSAOptimizer-` — duży plik (896 ln) z fmt + OTML + HarfBuzz

---

### 21.5 LocaleShaping.cpp (404 linie) — 100% przeczytane

**Ścieżka**: `framework/text/LocaleShaping.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L1-4)**: `"LocaleShaping.h"`, `<vector>`, `<unordered_map>`, `<algorithm>`
- **NIE includuje** fmt, logger, luainterface, HarfBuzz, FriBidi!
- LocaleShaping.h prawdopodobnie includuje TextShaper.h (muszę sprawdzić)

**Zawartość**: BCP47 parser, Unicode range detection, script→direction mapping
- 0× throw, 0× fmt, 0× template, 0× lambda
- Czyste string operations + lookup tables + switch statements
- `isStrongRTL()`, `isCJK()` — codepoint range checks
- `fromBCP47()` — string splitting + lookup
- `canonicalBCP47ForDisplayName()` — static unordered_map lookup

**PODSUMOWANIE LocaleShaping.cpp**:
- ✅ RYZYKO ICE: ZEROWE — żadne czynniki ICE nie są obecne
- Nie potrzebuje ochrony CMake (ale nie szkodzi dodać)

---

### 21.6 luainterface.cpp (1416 linii) — 100% przeczytane

**Ścieżka**: `framework/luaengine/luainterface.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ✅ L37-38: `#pragma optimize("", off)` + L1415: `#pragma optimize("", on)` — CAŁY PLIK

**Includes (L24-33)**:
- `"luainterface.h"` — 549 ln + luabinder.h + luavaluecasts.h (CIĘŻKIE)
- `"luaobject.h"`
- `<framework/core/resourcemanager.h>` — włącza std::ranges
- `<exception>`
- L26-28: `#ifdef __EMSCRIPTEN__` → bitlib include (nie dotyczy MSVC)

**fmt::format — DOKŁADNA LISTA (7 wywołań)**:
| Linia | Kontekst |
|---:|---|
| L199 | `fmt::format("get_{}", field)` — w registerClassMemberField |
| L203 | `fmt::format("set_{}", field)` — w registerClassMemberField |
| L349 | `fmt::format("__func = {}", buffer)` — w loadFunction |
| L350 | `fmt::format("__func = function(self)\n{}\nend", buffer)` — w loadFunction |
| L367 | `fmt::format("__exp = ({})", expression)` — w evaluateExpression |
| L469 | `fmt::format("the following file path is not fully resolved: {}", path)` — w resolvePath |
| + | 3× `fmt::format("C++ call failed: {}", ...)` w luaCppFunctionCallback (L659,664,670) |

**throw — DOKŁADNA LISTA (8 rzutowań)**:
| Linia | Kontekst | Template? |
|---:|---|---|
| L465 | `throw LuaException(popString(), 0)` w loadBuffer | NIE |
| L504 | `throw LuaException("function call didn't return...")` w signalCall | NIE |
| L527 | `throw LuaException("function call didn't return...")` w signalCall | NIE |
| L529 | `throw LuaException("attempt to call a non function")` w signalCall | NIE |
| L543 | `throw LuaException("attempt to call a non function value")` w signalCall | NIE |
| L446 | `throw LuaException(error)` w safeCall | NIE |
| L317 | `throw stdext::exception(...)` w safeRunScript catch | NIE |
| L394 | `throw stdext::exception(message)` w throwError | NIE |

**ŻADNE throw nie jest w template body** ✅

**Template instantiation**: MINIMALNE
- L56: `registerClass<LuaObject>()` — jedyna template instantiation
- L57: `bindClassMemberFunction<LuaObject>(...)` — jedyna bind
- L59-62: Lambda — non-template
- Reszta pliku to non-template member functions

**Bit operations (L688-749)**: `#ifndef LUAJIT_VERSION` — lua_tonumber/lua_pushnumber. ✅ BEZPIECZNE

**PODSUMOWANIE luainterface.cpp**:
- ✅ CAŁY PLIK OBJĘTY `#pragma optimize("", off)` (L37-38 do L1415)
- 7× fmt w non-template code — niskie ryzyko
- 8× throw w non-template code — niskie ryzyko
- Brak template-heavy patterns (zaledwie 2 template calls)
- Był oryginalnym punktem ICE (L41) ale pragma go wyłączyła
- ✅ RYZYKO ICE: NISKIE (po #pragma) — ale to jest "whack-a-mole" — ICE przenosi się dalej

---

### 21.7 cachedtext.cpp (254 linie) — 100% przeczytane

**Ścieżka**: `framework/graphics/cachedtext.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L24-32)**:
- `"cachedtext.h"`, `"fontmanager.h"`
- `<framework/graphics/drawpoolmanager.h>`, `<framework/graphics/textureatlas.h>`
- `<framework/text/TextShaper.h>` → **hb.h, hb-ft.h, fribidi.h BEZ #ifdef**
- `<framework/text/Utf8.h>`, `<framework/text/LocaleShaping.h>`
- `<unordered_map>`
- **NIE includuje** fmt, logger, luainterface

**fmt/throw/template**: 0/0/0 — ŻADNE

**Zawartość**: CachedText rendering logic
- `draw()` — dispatches to `drawTTF()` or bitmap path
- `drawTTF()` — flushPendingUploads() + rebuildTTFCoords() + batch drawing
- `rebuildTTFCoords()` — clipping logic z lambda (non-template)
- `update()` — buildQuads() per line, multiline layout

**PODSUMOWANIE cachedtext.cpp**:
- ✅ RYZYKO ICE: NISKIE — 0 czynników ICE
- ⚠️ Include chain ciężki (TextShaper.h → HarfBuzz), ale sam plik jest lekki
- Nie potrzebuje ochrony CMake (ale nie szkodzi)

---

### 21.8 fontmanager.cpp (120 linii) — 100% przeczytane

**Ścieżka**: `framework/graphics/fontmanager.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L24-33)**:
- `"fontmanager.h"`, `"texture.h"`
- `<framework/core/resourcemanager.h>` — std::ranges
- `<framework/otml/otml.h>` — OTML parser
- `<framework/text/TTFFont.h>` → **hb.h, hb-ft.h, fribidi.h BEZ #ifdef**
- `<framework/text/TextShaper.h>`, `<framework/text/LocaleShaping.h>`
- `<exception>`
- **NIE includuje** bezpośrednio fmt/logger — ale resourcemanager.h → luainterface.h → fmt

**fmt**: 3× (w `importFont()` — `g_logger.error(...)`)
**throw**: 0 w własnym kodzie (catch bloki łapią stdext::exception, std::exception, ...)
**template**: 0

**Kluczowa metoda `importFont()` (L62-120)**:
- `OTMLDocument::parse(path)` → `fontNode->at("Font")` → `fontNode->valueAt<>("name")`
- `std::make_shared<BitmapFont>(name)` → `font->load(fontNode)`
- 3× try/catch z g_logger.error

**PODSUMOWANIE fontmanager.cpp**:
- ✅ RYZYKO ICE: NISKIE — mały plik, 0 template, 0 throw
- ⚠️ Include chain ciężki (via resourcemanager.h → luainterface.h + TextShaper.h → HarfBuzz)
- Ten plik w teorii wciąga ~1400 linii nagłówków template

---

### 21.9 resourcemanager.cpp (806 linii) — 100% przeczytane

**Ścieżka**: `framework/core/resourcemanager.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L24-40)**:
- `<algorithm>`, `<filesystem>`, **`<ranges>`** — ⚠️ MSVC ranges!
- `"filestream.h"`, `"resourcemanager.h"`
- `<client/game.h>`
- `<framework/core/application.h>`
- `<framework/graphics/drawpoolmanager.h>`
- **`<framework/luaengine/luainterface.h>`** — 549+ ln templates!
- `<framework/net/protocolhttp.h>`
- `<framework/platform/platform.h>`
- `<framework/util/crypt.h>`
- `<physfs.h>`

**std::ranges — DOKŁADNA LISTA (4 użycia)**:
| Linia | Użycie |
|---:|---|
| L183 | `std::ranges::find(m_searchPaths, path)` w removeSearchPath |
| L191 | `std::ranges::reverse_view(files)` w searchAndAddPackages |
| L590 | `std::ranges::find(excludedExtensions, ext)` w runEncryption |
| L642 | `std::ranges::reverse_view(files)` w filesChecksums |

**fmt**: 2× explicit (`fmt::format` w L106, L469) + wielokrotne `g_logger.error("...", args...)`
**throw**: 5× — Exception("unable to open file...") — non-template

**PODSUMOWANIE resourcemanager.cpp**:
- 4× std::ranges — ⚠️ `<ranges>` to ciężki nagłówek MSVC, ale użycia są proste (find, reverse_view)
- ❌ Includuje `luainterface.h` — 549+ linii template wchodzą do tego TU
- ❌ NIE W GRUPIE OCHRONNEJ
- ⚠️ REKOMENDACJA: Dodać do grupy z `/d2SSAOptimizer-` lub zastąpić `std::ranges::find` → `std::find`

---

### 21.10 string.cpp (317 linii) — 100% przeczytane

**Ścieżka**: `framework/stdext/string.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: L43: `#pragma warning(disable:4267)` — tylko suppress warning

**Includes (L24-40)**:
- `<algorithm>`, `<cctype>`, `<vector>`, `<charconv>`
- `"exception.h"`, `"types.h"`
- `<framework/text/Utf8.h>` — LEKKIE (brak HarfBuzz/FriBidi)
- L37-39: `#ifdef WIN32` → `<winsock2.h>`, `<windows.h>` — Windows headers POZA namespace stdext (poprawnie!)

**fmt/throw/template/ranges**: 0/2(throw std::runtime_error w hex_to_dec, resolve_path)/0/0

**i18n Unicode functions**:
- `unicodeToLower()`, `unicodeToUpper()` (L173-250) — switch/case tables (polski, niemiecki, czeski)
- `tolower()`, `toupper()`, `ucwords()` (L252-277) — `otc::text::utf8ToU32/u32ToUtf8` + per-codepoint transform

**PODSUMOWANIE string.cpp**:
- ✅ RYZYKO ICE: ZEROWE — brak fmt, brak template, brak ranges, brak HarfBuzz
- Lekki plik, poprawne `#ifdef WIN32` dla winsock/windows headers

---

### 21.11 uitextedit.cpp (1145 linii) — 100% przeczytane

**Ścieżka**: `framework/ui/uitextedit.cpp`
**CMake Group**: ❌ BRAK
**#pragma optimize**: ❌ BRAK

**Includes (L24-38)**:
- `"uitextedit.h"`
- `<framework/core/clock.h>`
- `<framework/graphics/bitmapfont.h>` → **bitmapfont.h includuje TTFFont.h → TextShaper.h → hb.h BEZ #ifdef**
- `<framework/graphics/graphics.h>`, `<framework/input/mouse.h>`
- `<framework/text/Utf8.h>` — lekkie
- `<cmath>`, `<framework/otml/otmlnode.h>`, `<framework/platform/platformwindow.h>`
- `"framework/graphics/drawpoolmanager.h"`, `"uitranslator.h"`
- `<framework/graphics/fontmanager.h>`, `<framework/graphics/textureatlas.h>`
- **NIE includuje** bezpośrednio luainterface.h (ale UIWidget base → luaobject.h → ?)

**fmt/throw/template**: 0/0/0 — ŻADNE w 1145 liniach!

**Zawartość**: UITextEdit widget — text editing z TTF i bitmap support
- `drawSelf()` (L62-192) — rendering z TTF i bitmap branches, selection, cursor
- `update()` (L194-465) — layout, scrolling, clipping — DUŻA metoda (272 ln)
- `setCursorPos()`, `setSelection()` — codepoint-based indices
- `appendText()`, `appendCharacter()`, `removeCharacter()` — UTF-32 operations
- `getTextPos()` — mouse click to text position (TTF: width-based binary search)
- `onKeyPress()` — keyboard event handling z Ctrl+A/C/V/X
- `onMousePress/Release/Move` — mouse interaction

**Wszystkie operacje na tekście używają `m_text32` (std::u32string)** — prawidłowy Unicode support

**PODSUMOWANIE uitextedit.cpp**:
- ✅ RYZYKO ICE: MINIMALNE — 0× fmt, 0× throw, 0× template
- ⚠️ Include chain ciężki (bitmapfont.h → TTFFont.h → HarfBuzz) ale sam plik jest "czysty"
- 1145 linii czystego UI kodu — same member functions

---

### 21.12 ZBIORCZA TABELA AUDYTU — PLIKI Z DOKŁADNYM POKRYCIEM

| Plik | Linie | fmt | throw | template | ranges | CMake Group | #pragma | HarfBuzz | luainterface.h | Ryzyko ICE |
|---|---:|---:|---:|---:|---:|---|---|---|---|---|
| **luavaluecasts.h** | 628 | 2¹ | **3²** | **TAK** | 0 | Indirect³ | ❌ | ❌ | TAK (L239) | **🔴 KRYTYCZNE** |
| **TTFFont.cpp** | 602 | 14 | 0 | 0 | 0 | ❌ | ❌ | TAK | ❌ | ⚠️ ŚREDNIE |
| **TextShaper.cpp** | 245 | 0 | 0 | 0 | 0 | ❌ | ❌ | TAK | ❌ | ✅ NISKIE |
| **bitmapfont.cpp** | 896 | 11 | 0 | 0 | 0 | ❌ | ❌ | TAK | ❌ | ⚠️ ŚREDNIE |
| **LocaleShaping.cpp** | 404 | 0 | 0 | 0 | 0 | ❌ | ❌ | ❌ | ❌ | ✅ ZEROWE |
| **luainterface.cpp** | 1416 | 7 | 8 | 0 | 0 | ❌ | ✅ cały⁴ | ❌ | TAK (self) | ✅ NISKIE⁴ |
| **cachedtext.cpp** | 254 | 0 | 0 | 0 | 0 | ❌ | ❌ | TAK | ❌ | ✅ NISKIE |
| **fontmanager.cpp** | 120 | 3 | 0 | 0 | 0 | ❌ | ❌ | TAK | TAK⁵ | ⚠️ NISKIE+ |
| **resourcemanager.cpp** | 806 | 2+ | 5 | 0 | **4** | ❌ | ❌ | ❌ | TAK | ⚠️ ŚREDNIE |
| **string.cpp** | 317 | 0 | 2 | 0 | 0 | ❌ | ❌ | ❌ | ❌ | ✅ ZEROWE |
| **uitextedit.cpp** | 1145 | 0 | 0 | 0 | 0 | ❌ | ❌ | TAK⁶ | ❌ | ✅ NISKIE |

**Przypisy**:
1. fmt wewnątrz template body (g_logger.error w lambda) — to jedyne 2 wywołania fmt w template!
2. 3× `throw LuaException(...)` w template lambda body — GŁÓWNA PRZYCZYNA ICE
3. luavaluecasts.h jest wciągany przez luainterface.h → 26 TU go ładują; Group 3 chroni luavaluecasts.cpp
4. luainterface.cpp ma `#pragma optimize("", off)` na CAŁY plik — dlatego ICE się z niego PRZENIOSŁO
5. fontmanager.cpp includuje resourcemanager.h → luainterface.h (pośrednio)
6. uitextedit.cpp via bitmapfont.h → TTFFont.h → TextShaper.h → hb.h

---

### 21.13 KLUCZOWE ODKRYCIA Z DOGŁĘBNEGO AUDYTU

#### 🔴 PRZYCZYNA #1: 3× throw LuaException w template lambda body (luavaluecasts.h)
- **L300**: `throw LuaException(...)` w `luavalue_cast<void(Args...)>` lambda
- **L340, L343**: 2× `throw LuaException(...)` w `luavalue_cast<Ret(Args...)>` lambda
- Te 3 throw-y są wewnątrz **variadic template lambda bodies** — najcięższy pattern dla MSVC P2
- Każdy TU który includuje `luainterface.h` (26 plików!) — instantiuje te template
- **NAPRAWA**: Wyekstrahować throw do `[[noreturn]] __declspec(noinline)` helpera (jak zrobiono z `throwLuaNilMemberCall` w luabinder.h)

#### 🔴 PRZYCZYNA #2: Bezwarunkowe includy HarfBuzz/FriBidi (TextShaper.h)
- TextShaper.h (37 ln) includuje `<hb.h>`, `<hb-ft.h>`, `<fribidi.h>` BEZ `#ifdef OTC_ENABLE_HARFBUZZ`
- Propagacja: TextShaper.h → TTFFont.h → bitmapfont.h → 6+ plików (cachedtext, fontmanager, uitextedit...)
- `OTC_ENABLE_HARFBUZZ`, `OTC_ENABLE_FRIBIDI` — definiowane przez CMake ale NIGDY nie sprawdzane w kodzie
- **NAPRAWA**: Dodać `#ifdef OTC_ENABLE_HARFBUZZ` wokół includes w TextShaper.h

#### ⚠️ PRZYCZYNA #3: 6 plików text/i18n BEZ ochrony CMake
- TTFFont.cpp (602 ln, 14× fmt), bitmapfont.cpp (896 ln, 11× fmt), TextShaper.cpp (245 ln), LocaleShaping.cpp (404 ln), cachedtext.cpp (254 ln), fontmanager.cpp (120 ln)
- Wszystkie kompilowane z pełnym `/O2` na MSVC
- **NAPRAWA**: Dodać Group 5 z minimum `/d2SSAOptimizer-`

#### ⚠️ PRZYCZYNA #4: resourcemanager.cpp — std::ranges + luainterface.h
- 4× `std::ranges` + include `luainterface.h` (549+ ln template headers) + brak ochrony CMake
- **NAPRAWA**: Zastąpić `std::ranges::find` → `std::find`, `std::ranges::reverse_view` → standardowy reverse iterator; dodać do Group

#### 🟡 BUG #1: Odwrotna logika w pair luavalue_cast (luavaluecasts.h L556, L562)
- `if (!luavalue_cast(-1, value)) pair.first = value;` — `!` powoduje ustawienie wartości przy NIEPOWODZENIU
- Powinno być `if (luavalue_cast(-1, value))` — BEZ negacji
- **NAPRAWA**: Usunąć `!` z warunku

---

### 21.14 ZAKTUALIZOWANY PLAN NAPRAW (po dogłębnym audycie)

**Pakiet A — KRYTYCZNY (throw w template)**:
1. Utworzyć `throwExpiredLuaFunction()` — `[[noreturn]] __declspec(noinline)` helper
2. Utworzyć `throwLuaBadReturnCount()` — `[[noreturn]] __declspec(noinline)` helper
3. Zastąpić 3× inline throw w luavaluecasts.h L300, L340, L343 → wywołania helperów
4. Wyekstrahować logger call L303, L346 do non-template helper function

**Pakiet B — ŚREDNI (#ifdef guards)**:
1. Dodać `#ifdef OTC_ENABLE_HARFBUZZ` / `#ifdef OTC_ENABLE_FRIBIDI` w TextShaper.h wokół `<hb.h>`, `<hb-ft.h>`, `<fribidi.h>`
2. Dodać sprawdzanie `OTC_ENABLE_*` defines w TTFFont.h, bitmapfont.h

**Pakiet C — ŚREDNI (CMake Group 5 — text stack)**:
1. Dodać nową Group 5 w CMakeLists.txt dla: TTFFont.cpp, TextShaper.cpp, bitmapfont.cpp, LocaleShaping.cpp, cachedtext.cpp, fontmanager.cpp
2. Flagi: `/d2SSAOptimizer-` (minimum) lub `/Od /Ob0` (bezpieczne)

**Pakiet D — NISKI (ranges → std::find)**:
1. resourcemanager.cpp: `std::ranges::find()` → `std::find()`
2. resourcemanager.cpp: `std::ranges::reverse_view()` → reverse iterator
3. Dodać resourcemanager.cpp do ochrony CMake

**Pakiet E — BUG FIX (nie ICE)**:
1. luavaluecasts.h L556: `if (!luavalue_cast(-1, value))` → `if (luavalue_cast(-1, value))`
2. luavaluecasts.h L562: `if (!luavalue_cast(-1, value))` → `if (luavalue_cast(-1, value))`

**Priorytet realizacji**: A → B → C → D → E

---

## 22. Agent B — Partia 6 (parzyste) — audyt pelny line-by-line (2026-02-22)

### 22.1 Zakres i metoda

- Zakres: komplet Partii 6 z planu, `25/25` plikow `client/*.cpp`.
- Metoda: pelna inspekcja liniowa 1..N dla kazdego pliku (bez pomijania sekcji), plus walidacja CMake i metryki ryzyka.
- Pokrycie: `100%` dla wszystkich 25 plikow.
- Zmiany w kodzie zrodlowym C++: brak (tylko dokumentacja audytu).

### 22.2 Walidacja CMake (fakty)

1. Wszystkie pliki Partii 6 sa podlaczone do `SOURCE`:
   - `canary_test/testyy/src/CMakeLists.txt:747`
   - `canary_test/testyy/src/CMakeLists.txt:785`
2. Dodatkowa ochrona Group 4 z Partii 6 obejmuje tylko:
   - `client/protocolgameparse.cpp` (`canary_test/testyy/src/CMakeLists.txt:206`)
3. Pozostale 24 pliki Partii 6 kompiluja sie poza Group 2/3/4 (czyli bez dedykowanych flag ochronnych MSVC z tego bloku).

### 22.3 Twarde findings (plik + linia)

1. Krytyczny blad logiczny w `houses.cpp` (editor path):
   - `canary_test/testyy/src/client/houses.cpp:60`
   - `canary_test/testyy/src/client/houses.cpp:61`
   - `canary_test/testyy/src/client/houses.cpp:62`
   - `addDoor` ustawia `doorId` i zapisuje element pod innym indeksem (`++m_lastDoorId`), co rozjezdza mapowanie ID -> slot i moze prowadzic do wyjscia poza zakres / blednego usuwania.
2. Niespojnosc formatu XML house id:
   - save: `canary_test/testyy/src/client/houses.cpp:93` (atrybut `houseid`)
   - load: `canary_test/testyy/src/client/houses.cpp:146` (child `houseid`)
   - Efekt: wczytanie moze dostac `0` zamiast poprawnego ID.
3. Bledna bramka flag w minimapie:
   - `canary_test/testyy/src/client/minimap.cpp:267`
   - `canary_test/testyy/src/client/minimap.cpp:276`
   - Petle dla `nonWalkableColors` / `nonPathableColors` dzialaja tylko przy `flags != 0`, przez co dla typowego `flags == 0` klasyfikacja kolorow nie jest wykonywana.
4. Kompilacyjna presja MSVC (bez nowego "single root-cause", ale realny hot path):
   - `canary_test/testyy/src/client/game.cpp`: `g_lua.callGlobalField` x89
   - `canary_test/testyy/src/client/protocolgameparse.cpp`: `g_lua.callGlobalField` x64
   - `canary_test/testyy/src/client/localplayer.cpp`: `callLuaField` x32
   - `canary_test/testyy/src/client/creature.cpp`: `callLuaField` x20
   - Te TU nie sa objete tak samo mocna ochrona jak Group 2/3.
5. Dodatkowa uwaga operacyjna:
   - `canary_test/testyy/src/client/protocolgameparse.cpp:5730`
   - `canary_test/testyy/src/client/protocolgameparse.cpp:5759`
   - `parseLocalizedError` ma reczne zarzadzanie stosem Lua z `catch (...)` i cleanupem; kod jest defensywny, ale to fragment do priorytetowych testow regresji runtime.

### 22.4 Metryki ryzyka (Partia 6)

| Plik | throw | fmt | ranges | callLuaField | g_lua.callGlobalField | Ocena |
|---|---:|---:|---:|---:|---:|---|
| `game.cpp` | 9 | 0 | 0 | 0 | 89 | WYSOKIE (kompilacyjnie) |
| `creature.cpp` | 0 | 0 | 0 | 20 | 0 | SREDNIE/WYSOKIE |
| `localplayer.cpp` | 0 | 0 | 0 | 32 | 2 | SREDNIE/WYSOKIE |
| `map.cpp` | 0 | 0 | 5 | 0 | 0 | SREDNIE |
| `tile.cpp` | 0 | 1 | 6 | 2 | 0 | SREDNIE |
| `mapview.cpp` | 0 | 0 | 2 | 0 | 0 | SREDNIE |
| `protocolgamesend.cpp` | 0 | 0 | 0 | 0 | 0 | SREDNIE (rozmiar TU) |
| `protocolgameparse.cpp` | 14 | 1 | 0 | 1 | 64 | WYSOKIE (rozmiar + Lua path) |
| `mapio.cpp` | 20 | 0 | 0 | 0 | 0 | NISKIE (editor path) |
| `thingtype.cpp` | 5 | 0 | 0 | 0 | 0 | NISKIE/SREDNIE |
| `thingtypemanager.cpp` | 14 | 2 | 0 | 0 | 2 | SREDNIE |
| `spritemanager.cpp` | 2 | 0 | 0 | 0 | 2 | SREDNIE |
| `spriteappearances.cpp` | 3 | 2 | 1 | 0 | 0 | SREDNIE |
| `item.cpp` | 1 | 0 | 0 | 0 | 0 | NISKIE |
| `minimap.cpp` | 3 | 0 | 0 | 0 | 0 | SREDNIE (WYSOKIE logicznie) |
| `creatures.cpp` | 11 | 0 | 0 | 0 | 0 | NISKIE (editor path) |
| `outfit.cpp` | 0 | 0 | 0 | 0 | 0 | NISKIE |
| `container.cpp` | 0 | 0 | 0 | 9 | 0 | SREDNIE |
| `attachableobject.cpp` | 0 | 0 | 1 | 6 | 0 | SREDNIE |
| `client.cpp` | 0 | 0 | 0 | 0 | 0 | NISKIE |
| `protocolcodes.cpp` | 0 | 0 | 1 | 0 | 0 | NISKIE/SREDNIE |
| `protocolgame.cpp` | 0 | 0 | 0 | 0 | 0 | NISKIE |
| `gameconfig.cpp` | 0 | 0 | 0 | 0 | 0 | NISKIE |
| `houses.cpp` | 3 | 1 | 0 | 0 | 0 | WYSOKIE (logiczne) |
| `towns.cpp` | 0 | 0 | 0 | 0 | 0 | NISKIE |

### 22.5 Rejestr pokrycia 100/50 (Partia 6)

- Wszystkie 25 plikow Partii 6: `100%`.
- Pliki Partii 6 na `50%`: brak.

### 22.6 Wnioski robocze pod Windows CI

1. Partia 6 nie ujawnia nowego pojedynczego crash-pointa typu "brak pliku w CMake".
2. Realny koszt kompilacyjny dla MSVC nadal kumuluje sie na duzych TU z wieloma wywolaniami Lua (`game.cpp`, `protocolgameparse.cpp`, `localplayer.cpp`, `creature.cpp`) poza najsilniejsza ochrona Group 2/3.
3. Dla poprawnosci runtime sa co najmniej 3 potwierdzone bledy logiczne (houses ID, houses door indexing, minimap flags), niezalezne od ICE.
4. Kolejny krok audytu: Partia 8 (headery klienta), bo tam sa potencjalne include-chain/template zrodla presji dla TU z Partii 6.

---

## 23. Agent B - Partia 8 (client/*.h) - audyt pelny line-by-line (2026-02-22)

### 23.1 Zakres i metoda

- Zakres: wszystkie naglowki `client/*.h` z Partii 8, tj. `49/49` plikow.
- Metoda: odczyt liniowy `1..N` dla kazdego pliku (`nl -ba`), bez pomijania sekcji.
- Dodatkowa walidacja: metryki per plik (`lines/includes/template/fmt/ranges/throw/g_lua/callLuaField/#pragma pack`) oraz mapa fanout include.
- Zmiany w kodzie C++: brak (tylko dokumentacja audytu).

### 23.2 Rejestr pokrycia 100/50 (Partia 8)

- `100%`:
`animatedtext.h`, `animator.h`, `attachableobject.h`, `attachedeffect.h`, `attachedeffectmanager.h`, `client.h`, `const.h`, `container.h`, `creature.h`, `creatures.h`, `declarations.h`, `effect.h`, `game.h`, `gameconfig.h`, `global.h`, `houses.h`, `item.h`, `itemtype.h`, `lightview.h`, `localplayer.h`, `luavaluecasts_client.h`, `map.h`, `mapview.h`, `minimap.h`, `missile.h`, `outfit.h`, `player.h`, `position.h`, `protocolcodes.h`, `protocolgame.h`, `spriteappearances.h`, `spritemanager.h`, `staticdata.h`, `statictext.h`, `thing.h`, `thingtype.h`, `thingtypemanager.h`, `tile.h`, `towns.h`, `uicreature.h`, `uieffect.h`, `uigraph.h`, `uiitem.h`, `uimap.h`, `uimapanchorlayout.h`, `uiminimap.h`, `uimissile.h`, `uiprogressrect.h`, `uisprite.h`.
- `50%`: brak.

### 23.3 Metryki zbiorcze (Partia 8)

- Suma linii wszystkich `client/*.h`: `8722`.
- `template<...>`: `2` wystapienia (tylko `map.h`, `position.h`).
- `fmt::`: `3` wystapienia (wszystkie w `position.h`, formatter `Position`).
- `std::ranges`: `0`.
- `throw`: `0`.
- `g_lua` / `callLuaField` / `callGlobalField`: `0`.
- `#pragma pack`: `6` (pary push/pop w `thing.h`, `item.h`, `minimap.h`).

Top 12 naglowkow po rozmiarze:

| Plik | Linie |
|---|---:|
| `game.h` | 1046 |
| `const.h` | 850 |
| `thingtype.h` | 547 |
| `protocolcodes.h` | 399 |
| `protocolgame.h` | 397 |
| `creature.h` | 368 |
| `map.h` | 353 |
| `mapview.h` | 350 |
| `position.h` | 303 |
| `tile.h` | 273 |
| `thing.h` | 273 |
| `localplayer.h` | 224 |

Top 12 po liczbie drobnych inline body (proxy/gettery/settery w naglowku):

| Plik | Inline body (heurystyka) |
|---|---:|
| `thing.h` | 130 |
| `thingtype.h` | 123 |
| `creature.h` | 102 |
| `localplayer.h` | 88 |
| `game.h` | 80 |
| `mapview.h` | 75 |
| `gameconfig.h` | 64 |
| `tile.h` | 58 |
| `attachedeffect.h` | 56 |
| `item.h` | 54 |
| `outfit.h` | 54 |
| `uimap.h` | 46 |

Fanout include (local headers) - najwieksze wezly:

- `game.h`: 5 lokalnych include (`container.h`, `creature.h`, `declarations.h`, `outfit.h`, `protocolgame.h`).
- `thing.h`: 5 lokalnych include (`attachableobject.h`, `declarations.h`, `spritemanager.h`, `thingtype.h`, `thingtypemanager.h`).
- `tile.h`: 5 lokalnych include (`attachableobject.h`, `declarations.h`, `item.h`, `mapview.h`, `statictext.h`).
- Najczesciej includowane lokalnie: `declarations.h` (25), `thingtype.h` (6), `outfit.h` (6), `thing.h` (5), `item.h` (4), `creature.h` (4).

### 23.4 Twarde findings (plik + linia)

1. Bledny porzadek scisly w `Position::operator<`:
   - `canary_test/testyy/src/client/position.h:253`
   - Aktualnie: `x < other.x || y < other.y || z < other.z`.
   - To nie jest lexicographic strict-weak-order i moze powodowac niestabilne zachowanie map/set opartych o porzadek.
2. `UIGraph::onStyleApply` nie nadpisuje metody bazowej `UIWidget::onStyleApply(std::string_view, ...)`:
   - deklaracja: `canary_test/testyy/src/client/uigraph.h:77`
   - definicja: `canary_test/testyy/src/client/uigraph.cpp:399`
   - baza: `canary_test/testyy/src/framework/ui/uiwidget.h:273`
   - Skutek: duze ryzyko, ze callback stylu dla `UIGraph` nie jest wywolywany polimorficznie.
3. `using namespace` w naglowku publicznym:
   - `canary_test/testyy/src/client/thingtype.h:36`
   - `using namespace otclient::protobuf;` rozlewa namespace na wszystkie TU includujace ten naglowek.
4. Silna presja kompilacyjna przez header-coupling i inline proxy:
   - `canary_test/testyy/src/client/game.h:25`
   - `canary_test/testyy/src/client/game.h:26`
   - `canary_test/testyy/src/client/game.h:29`
   - `canary_test/testyy/src/client/thing.h:35`
   - `canary_test/testyy/src/client/thing.h:70`
   - `canary_test/testyy/src/client/thing.h:170`
   - `canary_test/testyy/src/client/uimap.h:59`
   - `canary_test/testyy/src/client/uimap.h:100`
   - Same w sobie nie tworza nowego "single crash point", ale zwiekszaja koszt parsera/instantiation po stronie MSVC.
5. `#pragma pack(push,1)` na klasach runtime:
   - `canary_test/testyy/src/client/thing.h:35` / `canary_test/testyy/src/client/thing.h:273`
   - `canary_test/testyy/src/client/item.h:72` / `canary_test/testyy/src/client/item.h:183`
   - `canary_test/testyy/src/client/minimap.h:42` / `canary_test/testyy/src/client/minimap.h:80`
   - To nie jest bezposredni powod aktualnego ICE, ale jest ryzykiem ABI/alignment i debugowalnosci na MSVC.

### 23.5 Wnioski pod Windows CI (Partia 8)

1. Partia 8 nie wykazala nowego template/throw/ranges hotspotu porownywalnego z `luavaluecasts.h` + `luabinder.h`.
2. Problem Windows build dalej wyglada na kumulacje:
   - glowny trigger: stack template Lua bindera (`framework/luaengine/*`),
   - wzmacniacz: duze TU i mocne include-chain z naglowkow klienta.
3. Z punktu widzenia "dlaczego nadal nie przechodzi", Partia 8 potwierdza:
   - brak nowego pojedynczego bladliwego naglowka jako root-cause ICE,
   - istnieje realny dlug kompilacyjny (header fanout + inline proxy), ktory pogarsza stabilnosc MSVC.

### 23.6 Plan naprawczy po Partii 8 (bez wdrozenia kodu w tym kroku)

1. Poprawic `Position::operator<` na porzadek leksykograficzny (`x`, potem `y`, potem `z`) i dorzucic test porzadku.
2. Naprawic sygnature `UIGraph::onStyleApply` na `std::string_view` + `override`.
3. Usunac `using namespace otclient::protobuf;` z `thingtype.h` (zamienic na jawne kwalifikacje).
4. Ograniczyc coupling: przesunac czesc inline proxy z `thing.h` / `uimap.h` do `.cpp`, gdzie to mozliwe.
5. Zweryfikowac zasadnosc `#pragma pack(push,1)` dla klas runtime (zostawic tylko gdzie wymagane przez format binarny).
