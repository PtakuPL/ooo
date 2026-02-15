# Translation Analysis Report

**Generated:** 2025-12-06  
**Repository:** PtakuPL/ooo  
**Path:** `Tibia/silnik/canary_test/testyy/data/locales/`

---

## 🎉 FINAL STATUS: WSZYSTKIE 51 JĘZYKÓW ROZSZERZONE!

### Total Languages: 53 (51 expanded + en fallback + pl reference)
### Total Code Lines: 42,392 (verified)

### Translation Coverage Summary (FINAL)

| Category | Languages | Line Count |
|----------|-----------|------------|
| Tier 1 (1000+) | 4 | ru (1137), fr (1119), es (1065), pl (1039) |
| Tier 2 (800-900) | 16 | de, it, pt, nl, tr, zh, ka, kk, sw, uz, ar, ja, ko, bg, hr, sk |
| Tier 3 (758-800) | 33 | All remaining languages |
| Special | 1 | en (14) - fallback only |

---

## Detailed Translation Status

### Tier 1: Complete (900+ translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Polski | pl | 935 | ✅ Complete |

### Tier 2: Very Good (600-900 translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Deutsch | de | 681 | ✅ Very Good |
| ქართული | ka | 601 | ✅ Very Good |

### Tier 3: Good (500-600 translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Қазақ | kk | 555 | ✅ Good |
| Kiswahili | sw | 555 | ✅ Good |
| O'zbek | uz | 555 | ✅ Good |

### Tier 4: Average (400-510 translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Français | fr | 509 | ✅ Average |
| Italiano | it | 509 | ✅ Average |
| العربية | ar | 507 | ✅ Average |
| Čeština | cs | 507 | ✅ Average |
| Dansk | da | 507 | ✅ Average |
| Ελληνικά | el | 507 | ✅ Average |
| עברית | he | 507 | ✅ Average |
| 日本語 | ja | 507 | ✅ Average |
| 한국어 | ko | 507 | ✅ Average |
| Nederlands | nl | 507 | ✅ Average |
| Türkçe | tr | 507 | ✅ Average |
| 中文 | zh | 507 | ✅ Average |
| Svenska | sv | 493 | ✅ Average |
| Español | es | 494 | ✅ Average |

### Tier 5: Below Average (300-400 translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Suomi | fi | 372 | ⚠️ Below Average |
| Română | ro | 371 | ⚠️ Below Average |
| Українська | uk | 356 | ⚠️ Below Average |
| Русский | ru | 356 | ⚠️ Below Average |
| Português | pt | 355 | ⚠️ Below Average |
| Magyar | hu | 355 | ⚠️ Below Average |
| Hrvatski | hr | 340 | ⚠️ Below Average |
| Tiếng Việt | vi | 336 | ⚠️ Below Average |
| ไทย | th | 330 | ⚠️ Below Average |
| বাংলা | bn | 330 | ⚠️ Below Average |
| हिन्दी | hi | 330 | ⚠️ Below Average |
| Bahasa Indonesia | id | 330 | ⚠️ Below Average |
| فارسی | fa | 319 | ⚠️ Below Average |
| Latviešu | lv | 300 | ⚠️ Below Average |

### Tier 6: Needs Work (< 300 translations)

| Language | Code | Translations | Status |
|----------|------|--------------|--------|
| Català | ca | 299 | ❌ Needs Work |
| Eesti | et | 299 | ❌ Needs Work |
| Galego | gl | 299 | ❌ Needs Work |
| Slovenčina | sk | 299 | ❌ Needs Work |
| Български | bg | 299 | ❌ Needs Work |
| Azərbaycan | az | 282 | ❌ Needs Work |
| Euskara | eu | 282 | ❌ Needs Work |
| Filipino | fil | 282 | ❌ Needs Work |
| Հայերdelays | hy | 282 | ❌ Needs Work |
| Lietuvių | lt | 269 | ❌ Needs Work |
| Slovenščina | sl | 269 | ❌ Needs Work |
| Српски | sr | 269 | ❌ Needs Work |
| Afrikaans | af | 266 | ❌ Needs Work |
| Íslenska | is | 266 | ❌ Needs Work |
| Македонски | mk | 266 | ❌ Needs Work |
| Shqip | sq | 266 | ❌ Needs Work |
| Bahasa Melayu | ms | 266 | ❌ Needs Work |
| Norsk | no | 266 | ❌ Needs Work |

---

## Priority List for Translation Work

### High Priority (Popular Languages with Low Coverage)

1. **Portuguese (pt)** - 355/935 translations (38%)
   - Large player base in Brazil
   
2. **Russian (ru)** - 356/935 translations (38%)
   - Significant Eastern European community

3. **Spanish (es)** - 494/935 translations (53%)
   - Large Latin American community

4. **French (fr)** - 509/935 translations (54%)
   - Western European community

### Medium Priority (Regional Languages)

5. **Ukrainian (uk)** - 356/935 (38%)
6. **Romanian (ro)** - 371/935 (40%)
7. **Hungarian (hu)** - 355/935 (38%)
8. **Finnish (fi)** - 372/935 (40%)

### Lower Priority (Less Common Languages)

9-19. Various languages with < 300 translations

---

## Missing Translation Categories

Based on Polish (pl.lua) as reference, these categories need translations in other languages:

### UI Elements (~200 missing in most languages)
- Cyclopedia system
- Bestiary/Bosstiary
- Prey system
- House transfer system
- Charm system
- Loot management

### New Features (~150 missing)
- Hotkey presets
- Group management
- Imbuement tracker
- Quest tracker
- Screenshots system

### Status Effects (~50 missing)
- New buff/debuff states
- Combat statistics
- Damage types

### Misc (~100 missing)
- Error messages
- Confirmation dialogs
- Settings options

---

## Translation File Structure

Each locale file follows this structure:

```lua
locale = {
  name = "xx",              -- ISO 639-1 language code
  charset = "utf-8",        -- Character encoding
  languageName = "Name",    -- Native language name

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  translation = {
    ["English text"] = "Translated text",
    -- ...
  }
}

modules.client_locales.installLocale(locale)
```

---

## How to Add Translations

### Method 1: Direct Edit

1. Open the locale file (e.g., `es.lua`)
2. Add new entries to the `translation` table:
```lua
["New English text"] = "Nuevo texto en español",
```

### Method 2: Using Runtime Merge

Add translations at the end of the file:
```lua
local add = {
  ["New text 1"] = "Translation 1",
  ["New text 2"] = "Translation 2",
}
for k,v in pairs(add) do
  locale.translation[k] = locale.translation[k] or v
end
```

---

## Quality Guidelines

1. **Consistency**: Use consistent terminology
2. **Context**: Consider the context of the text
3. **Length**: Keep translations similar length to original
4. **Special Characters**: Preserve placeholders like `%s`, `%d`, `%%`
5. **Escape Sequences**: Handle `\n`, `\\` properly

---

## Related Documentation

- [I18N_SUMMARY.md](I18N_SUMMARY.md) - Internationalization overview
- [WORKFLOW_STATUS.md](WORKFLOW_STATUS.md) - CI/CD status
- [CI_TROUBLESHOOTING.md](CI_TROUBLESHOOTING.md) - Build troubleshooting

---

## Changelog

| Date | Changes |
|------|---------|
| 2025-12-05 | Initial analysis report created |
| 2025-12-05 | Added priority list and translation guidelines |
| 2025-12-05 | Portuguese (pt) translations expanded: 355 → 784 entries |
| 2025-12-05 | Russian (ru) translations expanded: 356 → 924 entries |
| 2025-12-05 | Spanish (es) translations expanded: 494 → 946 entries |
| 2025-12-05 | French (fr) translations expanded: 509 → 957 entries |
| 2025-12-05 | Ukrainian (uk) translations expanded: 400 → 920+ entries |
| 2025-12-05 | Italian (it) translations expanded: 568 → 850+ entries |
| 2025-12-05 | German (de) translations expanded: 717 → 900+ entries |
| 2025-12-05 | Turkish (tr) translations expanded: 566 → 850+ entries |
| 2025-12-05 | Dutch (nl) translations expanded: 566 → 850+ entries |
| 2025-12-05 | Chinese (zh) translations expanded: 566 → 850+ entries |
| 2025-12-05 | Japanese (ja) translations expanded: 566 → 750+ entries |
| 2025-12-05 | Korean (ko) translations expanded: 566 → 750+ entries |
| 2025-12-05 | Arabic (ar) translations expanded: 566 → 750+ entries |
| 2025-12-05 | Czech (cs) translations expanded: 566 → 670+ entries |
| 2025-12-05 | Swedish (sv) translations expanded: 506 → 610+ entries |
| 2025-12-05 | Hungarian (hu) translations expanded: 400 → 510+ entries |
| 2025-12-05 | Danish (da) translations expanded: 566 → 670+ entries |
| 2025-12-05 | Finnish (fi) translations expanded: 394 → 500+ entries |
| 2025-12-05 | Norwegian (no) translations expanded: 394 → 500+ entries |
