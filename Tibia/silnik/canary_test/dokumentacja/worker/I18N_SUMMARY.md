# 🌍 Internationalization (I18N) Project Summary

## Project Status: 🔄 PHASE 2 - Protocol Implementation

This document summarizes the comprehensive internationalization effort for OTClient (testyy) and Canary Server.

---

## 🔴 CURRENT PHASE: Client-Server Protocol (2025-12-12)

### Architecture Change
**OLD:** Server translates texts → sends translated → client displays  
**NEW:** Server sends i18n keys → client translates locally → displays

### Why This Change?
| Aspect | Old Approach | New Approach |
|--------|--------------|--------------|
| Server CPU | ❌ High (translation per request) | ✅ Minimal |
| Bandwidth | ❌ Full text strings | ✅ Short keys |
| Memory | ❌ Cache per locale on server | ✅ Dictionary only on client |
| Scalability | ❌ Limited by server | ✅ Client handles translation |

### Client (testyy)
- ✅ Added localized opcodes parsing:
   - `0xBC` (188) `LocalizedTextMessage`
   - `0x99` (153) `LocalizedCreatureSay`
   - `0xC5` (197) `LocalizedTextMessageArgs` (includes `argc + args[]`)
   - `0xC4` (196) `LocalizedCreatureSayArgs` (includes `argc + args[]`)
   - `0xC1` (193) `LocalizedError` (dialog/error via `onServerError`, includes `fallbackText + i18nKey + argc + args[]`)
- ✅ Calls `tr(i18nKey, ...)` when args are present (client-side `string.format`).
- ✅ Fix: `tr()` correctly handles compact IDs that look numeric (e.g. "00").

### Server (canary_test)
- ✅ Sends localized packets using dedicated opcodes (no optional trailing bytes):
   - `0xBC/0x99` (no args)
   - `0xC5/0xC4` (with args)
- ✅ Compact-keys mapping on send path (semantic → compact) when enabled.

### Remaining TODO (both)
- [ ] End-to-end verification with real client/server (including args on both packet types).
- [ ] Rollout discipline: keep args sending behind feature flag by default until verified.

---

## 🎯 Achievements (Phase 1 - Completed)

### Language Support
- **53 languages** fully supported
- **All 53 locales** have comprehensive translations (150-500+ strings each)
- Support for **RTL languages** (Arabic, Hebrew, Persian)
- Support for **CJK languages** (Chinese, Japanese, Korean)
- Support for **Cyrillic scripts** (Russian, Ukrainian, Serbian, Bulgarian, etc.)
- Support for **Special scripts** (Georgian, Armenian, Thai, Hindi, Bengali)

### Documentation
- **8 comprehensive documentation files** created
- Architecture documentation for both client and server
- API documentation for Lua scripting
- Configuration guides with I18N settings

### Build System
- Emscripten/WASM build fix implemented
- CMake Lua detection improved for cross-platform builds

---

## 📊 Language Coverage

### Tier 1: Complete (500+ translations)
| Language | Code | Status |
|----------|------|--------|
| German | de | ✅ Original |
| Spanish | es | ✅ Original |
| Portuguese | pt | ✅ Original |
| Swedish | sv | ✅ Complete |
| Polish | pl | ✅ Complete |

### Tier 2: Comprehensive (400+ translations)
| Language | Code | Status |
|----------|------|--------|
| French | fr | ✅ Comprehensive |
| Italian | it | ✅ Comprehensive |
| Chinese | zh | ✅ Comprehensive |
| Japanese | ja | ✅ Comprehensive |
| Korean | ko | ✅ Comprehensive |
| Turkish | tr | ✅ Comprehensive |
| Dutch | nl | ✅ Comprehensive |
| Arabic | ar | ✅ RTL Comprehensive |
| Danish | da | ✅ Comprehensive |
| Greek | el | ✅ Comprehensive |
| Hebrew | he | ✅ RTL Comprehensive |
| Czech | cs | ✅ Comprehensive |
| Hungarian | hu | ✅ Comprehensive |
| Romanian | ro | ✅ Comprehensive |
| Ukrainian | uk | ✅ Comprehensive |
| Norwegian | no | ✅ Comprehensive |
| Finnish | fi | ✅ Comprehensive |
| Thai | th | ✅ Comprehensive |
| Vietnamese | vi | ✅ Comprehensive |
| Hindi | hi | ✅ Comprehensive |
| Indonesian | id | ✅ Comprehensive |

### Tier 3: Major Features (200-400 translations)
| Language | Code | Status |
|----------|------|--------|
| Russian | ru | ✅ Major features |
| Persian | fa | ✅ RTL Comprehensive |
| Malay | ms | ✅ Comprehensive |
| Bengali | bn | ✅ Comprehensive |
| Slovak | sk | ✅ Comprehensive |
| Bulgarian | bg | ✅ Comprehensive |
| Croatian | hr | ✅ Comprehensive |
| Serbian | sr | ✅ Cyrillic Comprehensive |
| Slovenian | sl | ✅ Comprehensive |
| Lithuanian | lt | ✅ Comprehensive |
| Latvian | lv | ✅ Comprehensive |
| Estonian | et | ✅ Comprehensive |
| Catalan | ca | ✅ Comprehensive |
| Galician | gl | ✅ Comprehensive |

### Tier 4: Base UI (150+ translations)
| Language | Code | Status |
|----------|------|--------|
| Icelandic | is | ✅ Comprehensive |
| Macedonian | mk | ✅ Cyrillic Comprehensive |
| Albanian | sq | ✅ Comprehensive |
| Afrikaans | af | ✅ Comprehensive |
| Azerbaijani | az | ✅ Comprehensive |
| Basque | eu | ✅ Comprehensive |
| Filipino | fil | ✅ Comprehensive |
| Armenian | hy | ✅ Comprehensive |
| Georgian | ka | ✅ Comprehensive |
| Kazakh | kk | ✅ Comprehensive |
| Swahili | sw | ✅ Comprehensive |
| Uzbek | uz | ✅ Comprehensive |

---

## 📚 Documentation Created

### OTClient (testyy/docs/)
| Document | Description |
|----------|-------------|
| `ARCHITECTURE.md` | Client architecture overview |
| `TEXT_RENDERING.md` | Text rendering and localization |
| `MODULES.md` | 60+ module documentation |
| `SOURCE_CODE.md` | C++ source code guide |

### Canary Server (canary/docs/)
| Document | Description |
|----------|-------------|
| `INTERNATIONALIZATION.md` | Server I18N implementation |
| `SOURCE_CODE.md` | Server architecture guide |
| `LUA_SCRIPTING.md` | Lua API documentation |
| `CONFIGURATION.md` | Server configuration guide |

---

## 🔧 Technical Implementation

### Client-Side (OTClient/testyy)

1. **Locale System**
   - Files in `data/locales/*.lua`
   - `tr()` function for translation
   - Automatic language detection
   - Manual language selection in options

2. **Translation Categories**
   - UI elements (buttons, menus, dialogs)
   - Game messages (combat, skills, items)
   - Status effects (20+ effects)
   - Error messages and warnings
   - Hotkey presets
   - Cyclopedia/Bestiary/Bosstiary
   - House system
   - Imbuing system
   - Store and rewards
   - Party and chat systems

3. **Script Updates**
   - `neededtranslations.lua` expanded to ~450 keys
   - All `tr()` calls catalogued

### Server-Side (Canary)

1. **Message System**
   - Server sends base language messages
   - Client handles translation
   - Consistent terminology guidelines

2. **Lua Scripts**
   - Simple string patterns for easy translation
   - Format strings for variable placeholders
   - Documentation for script authors

---

## 🚀 Build Status

### Workflow Status
| Platform | Status |
|----------|--------|
| Windows | ✅ Ready |
| Linux | ✅ Ready |
| Android | ✅ Ready |
| Browser (Emscripten) | ✅ Fixed |

### Emscripten Fix
- Modified CMake Lua detection
- Uses standard `FindLua` module for WASM builds
- vcpkg Lua package now detected correctly

---

## 📁 Project Structure

```
ooo/
├── Tibia/
│   └── silnik/
│       ├── canary/                 # Server
│       │   ├── docs/               # Server documentation
│       │   │   ├── INTERNATIONALIZATION.md
│       │   │   ├── SOURCE_CODE.md
│       │   │   ├── LUA_SCRIPTING.md
│       │   │   └── CONFIGURATION.md
│       │   └── src/                # Server source
│       │
│       └── canary_test/
│           └── testyy/             # Client (OTClient)
│               ├── docs/           # Client documentation
│               │   ├── ARCHITECTURE.md
│               │   ├── TEXT_RENDERING.md
│               │   ├── MODULES.md
│               │   └── SOURCE_CODE.md
│               │
│               ├── data/
│               │   └── locales/    # 53 language files
│               │       ├── en.lua
│               │       ├── de.lua
│               │       ├── pl.lua
│               │       └── ... (50 more)
│               │
│               └── modules/
│                   └── client_locales/
│                       └── neededtranslations.lua
```

---

## 🌐 Regional Coverage

| Region | Languages | Scripts |
|--------|-----------|---------|
| Western Europe | 12 | Latin |
| Eastern Europe | 11 | Latin/Cyrillic |
| Baltic | 3 | Latin |
| Slavic | 2 | Cyrillic |
| Asia | 10 | CJK, Thai, Devanagari, Bengali |
| Middle East | 4 | Arabic, Hebrew (RTL) |
| Caucasus | 3 | Georgian, Armenian |
| Central Asia | 2 | Cyrillic/Latin |
| Africa | 2 | Latin |
| Other | 4 | Latin |

---

## ✅ Completion Checklist

- [x] 50+ language goal achieved (53 languages)
- [x] All locales have translations
- [x] RTL language support (Arabic, Hebrew, Persian)
- [x] CJK language support (Chinese, Japanese, Korean)
- [x] Cyrillic script support
- [x] Special script support (Georgian, Armenian, Thai, etc.)
- [x] Emscripten build fixed
- [x] Client architecture documented
- [x] Server architecture documented
- [x] Lua scripting API documented
- [x] Configuration guide created
- [x] Translation keys catalogued

---

## 🔮 Future Recommendations

1. **Community Translations**
   - Set up translation platform (Crowdin, Weblate)
   - Enable community contributions
   - Regular translation updates

2. **Quality Assurance**
   - Native speaker review for major languages
   - Context verification for game-specific terms
   - Regular testing with different locales

3. **Automation**
   - Automated translation key extraction
   - Missing translation detection
   - CI/CD integration for locale validation

---

## 📞 Contact

For questions or contributions regarding internationalization:
- Repository: PtakuPL/ooo
- Issue #22: Internationalization tracking

---

*This documentation is part of the OTClient & Canary Server I18N initiative.*
*Last updated: December 2025*
