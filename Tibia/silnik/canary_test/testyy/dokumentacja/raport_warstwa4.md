# 🔐 Raport Warstwy 4 - Code Safety & Format Consistency

**Data generowania:** 2025-12-06

---

## 1. Printf-style formatowanie w C++

**Znaleziono 1 potencjalnych problemów**

| Plik | Linia | Typ | Fragment kodu |
|------|-------|-----|---------------|
| src/framework/stdext/string.h | 38 | Printf format in string literal | `[[nodiscard]] std::string date_time_string(const c` |

## 2. Formatowanie w plikach Lua

**Znaleziono 117 użyć string.format**

| Plik | Linia | Fragment kodu |
|------|-------|---------------|
| modules/corelib/json.lua | 179 | `error(string.format('%s at line %d col %d', msg, line_count,` |
| modules/corelib/json.lua | 194 | `error(string.format('invalid unicode codepoint \'%x\'', n))` |
| modules/corelib/keybind.lua | 133 | `pwarning(string.format("Keybind for [%s: %s] is already in u` |
| modules/game_rewardwall/game_rewardwall.lua | 531 | `local text = string.format("You have selected [color=#D33C3C` |
| modules/game_rewardwall/game_rewardwall.lua | 639 | `free = string.format("Reward for Free Accounts:\n * %d x Pre` |
| modules/game_rewardwall/game_rewardwall.lua | 640 | `premium = string.format("Reward for Premium Accounts:\n * %d` |
| modules/game_rewardwall/game_rewardwall.lua | 644 | `free = string.format("Reward for Free Accounts:\n * %d minut` |
| modules/game_rewardwall/game_rewardwall.lua | 645 | `premium = string.format("Reward for Premium Accounts:\n * %d` |
| modules/game_rewardwall/game_rewardwall.lua | 718 | `local text = string.format("You have selected [color=%s]%d[/` |
| modules/game_quickloot/quickloot.lua | 90 | `local add_text = string.format("Add to %s Loot List", widget` |
| modules/game_quickloot/quickloot.lua | 91 | `local clear_text = string.format("Clear %s Loot List", widge` |
| modules/game_quickloot/quickloot.lua | 163 | `local file = string.format("/settings/%s_containers.json",` |
| modules/game_quickloot/quickloot.lua | 193 | `local file = string.format("/settings/%s_containers.json",` |
| modules/game_cyclopedia/utils.lua | 641 | `string.format("%s gp, %s\nResidence: %s", Cyclopedia.formatG` |
| modules/game_cyclopedia/utils.lua | 643 | `table.insert(sell, string.format("%s gp, %s\nResidence: %s",` |
| modules/game_cyclopedia/utils.lua | 650 | `string.format("%s gp, %s\nResidence: %s", Cyclopedia.formatG` |
| modules/game_cyclopedia/utils.lua | 652 | `table.insert(buy, string.format("%s gp, %s\nResidence: %s", ` |
| modules/game_cyclopedia/tab/boss_slots/boss_slots.lua | 69 | `UI.TopBase.InfoLabel:setText(string.format("Equipment Loot B` |
| modules/game_cyclopedia/tab/boss_slots/boss_slots.lua | 78 | `progress.ProgressBorder1:setTooltip(string.format(" %d / %d ` |
| modules/game_cyclopedia/tab/boss_slots/boss_slots.lua | 80 | `progress.ProgressBorder2:setTooltip(string.format(" %d / %d ` |

*Uwaga: string.format w Lua jest poprawne i bezpieczne.*


## 3. Użycie fmt::format w C++

**Znaleziono 50 użyć fmt::format/stdext::format**

| Plik | Linia | Placeholdery | Fragment kodu |
|------|-------|--------------|---------------|
| src/framework/sound/soundmanager.cpp | 65 | 1 placeholders | `g_logger.error(fmt::format("unable to create audio` |
| src/framework/sound/soundmanager.cpp | 70 | 1 placeholders | `g_logger.error(fmt::format("unable to make context` |
| src/framework/sound/soundmanager.cpp | 420 | 2 placeholders | `g_resources.readFileStream(g_resources.resolvePath` |
| src/framework/graphics/bitmapfont.cpp | 70 | 1 placeholders | `g_logger.error(fmt::format("TTF load failed: {}", ` |
| src/framework/platform/win32platform.cpp | 59 | 1 placeholders | `commandLine += fmt::format(" \"{}\"", arg);` |
| src/framework/platform/win32platform.cpp | 432 | 1 placeholders | `ret += fmt::format(" (build {})", osvi.dwBuildNumb` |
| src/framework/platform/win32crashhandler.cpp | 125 | 3 placeholders | `ss << fmt::format("    {}: {}({}+%#0lx) [0x%016lX]` |
| src/framework/platform/win32crashhandler.cpp | 127 | 2 placeholders | `ss << fmt::format("    {}: {} [0x%016lX]\n", count` |
| src/framework/platform/win32crashhandler.cpp | 137 | 0 placeholders | `std::string crashReport = fmt::format(` |
| src/framework/platform/win32crashhandler.cpp | 176 | 1 placeholders | `std::string fileName = fmt::format("{}\\crashrepor` |
| src/framework/platform/win32crashhandler.cpp | 187 | 0 placeholders | `std::string msg = fmt::format(` |
| src/framework/platform/unixcrashhandler.cpp | 45 | 1 placeholders | `ss << fmt::format("app name: {}\n", g_app.getName(` |
| src/framework/platform/unixcrashhandler.cpp | 46 | 1 placeholders | `ss << fmt::format("app version: {}\n", g_app.getVe` |
| src/framework/platform/unixcrashhandler.cpp | 47 | 1 placeholders | `ss << fmt::format("build compiler: {}\n", BUILD_CO` |
| src/framework/platform/unixcrashhandler.cpp | 48 | 1 placeholders | `ss << fmt::format("build date: {}\n", __DATE__);` |
| src/framework/platform/unixcrashhandler.cpp | 49 | 1 placeholders | `ss << fmt::format("build type: {}\n", BUILD_TYPE);` |
| src/framework/platform/unixcrashhandler.cpp | 50 | 2 placeholders | `ss << fmt::format("build revision: {} ({})\n", BUI` |
| src/framework/platform/unixcrashhandler.cpp | 51 | 1 placeholders | `ss << fmt::format("crash date: {}\n", stdext::date` |
| src/framework/platform/unixplatform.cpp | 121 | 2 placeholders | `return system(fmt::format("/bin/cp '{}' '{}'", fro` |
| src/framework/platform/unixplatform.cpp | 152 | 1 placeholders | `return system(fmt::format("open {}", url).c_str())` |

## 4. Potencjalnie niebezpieczne wzorce

**Znaleziono 17 potencjalnie niebezpiecznych wzorców**

| Plik | Linia | Typ | Fragment kodu |
|------|-------|-----|---------------|
| src/framework/platform/win32crashhandler.cpp | 118 | Unsafe strcpy | `strcpy(modname, "Unknown");` |
| src/framework/net/httplogin.cpp | 149 | Unsafe strcpy | `strcpy(attr.requestMethod, "POST");` |
| src/client/attachableobject.h | 61 | Unsafe gets | `const std::vector<UIWidgetPtr>& getAttachedWidgets` |
| src/client/attachableobject.h | 62 | Unsafe gets | `bool hasAttachedWidgets() const { return m_data &&` |
| src/client/attachableobject.h | 68 | Unsafe gets | `void clearAttachedWidgets(bool callEvent = true);` |
| src/client/attachableobject.cpp | 44 | Unsafe gets | `clearAttachedWidgets(false);` |
| src/client/attachableobject.cpp | 246 | Unsafe gets | `if (!hasAttachedWidgets()) return false;` |
| src/client/attachableobject.cpp | 272 | Unsafe gets | `if (!hasAttachedWidgets()) return false;` |
| src/client/attachableobject.cpp | 289 | Unsafe gets | `if (!hasAttachedWidgets()) return false;` |
| src/client/attachableobject.cpp | 304 | Unsafe gets | `void AttachableObject::clearAttachedWidgets(const ` |
| src/client/attachableobject.cpp | 306 | Unsafe gets | `if (!hasAttachedWidgets()) return;` |
| src/client/attachableobject.cpp | 323 | Unsafe gets | `if (!hasAttachedWidgets()) return nullptr;` |
| src/client/map.cpp | 1204 | Unsafe gets | `void Map::updateAttachedWidgets(const MapViewPtr& ` |
| src/client/map.h | 223 | Unsafe gets | `void updateAttachedWidgets(const MapViewPtr& mapVi` |
| src/client/mapview.cpp | 121 | Unsafe gets | `g_map.updateAttachedWidgets(static_self_cast<MapVi` |
| src/client/tile.cpp | 202 | Unsafe gets | `if (hasAttachedWidgets()) {` |
| src/client/tile.cpp | 203 | Unsafe gets | `clearAttachedWidgets();` |

## 5. Podsumowanie problemów per plik

| Plik | Liczba problemów |
|------|------------------|
| src/client/attachableobject.cpp | 7 |
| src/client/attachableobject.h | 3 |
| src/client/tile.cpp | 2 |
| src/framework/stdext/string.h | 1 |
| src/framework/platform/win32crashhandler.cpp | 1 |
| src/framework/net/httplogin.cpp | 1 |
| src/client/map.cpp | 1 |
| src/client/map.h | 1 |
| src/client/mapview.cpp | 1 |

## 6. Rekomendacje

### ✅ Co jest dobrze:

- Projekt używa fmt:: dla nowoczesnego formatowania
- Większość kodu jest zgodna ze standardami

### ⚠️ Do poprawy:

- 1 miejsc używa starego formatowania printf
- 17 potencjalnie niebezpiecznych wywołań funkcji

### 🔧 Zalecane działania:

1. Zamienić wszystkie `%s`, `%d`, `%i` na `{}` w fmt::format
2. Zamienić sprintf/snprintf na fmt::format lub std::format
3. Unikać strcpy/strcat - używać std::string lub bezpiecznych alternatyw
4. Dodać linting do CI dla wykrywania tych wzorców

### 📝 Przykłady naprawy:

```cpp
// PRZED:
g_logger.error("Error: %s at line %d", msg, line);

// PO:
g_logger.error("Error: {} at line {}", msg, line);
```

---

*Raport wygenerowany automatycznie przez Code Safety & Format Consistency Checker*