# Migracja i18n - Item::getDescription() i helpery

**Data:** 2025-02-08 (kontynuacja sesji)  
**Branch:** `feature/i18n-multilanguage`  
**Commit:** `a90d04d7c` + `34b37a394`

## Co zostało zrobione

### Pliki C++ zmodyfikowane:

1. **`src/items/item.hpp`** - dodano parametr `std::string_view locale = {}` do 7 metod:
   - `parseImbuementDescription()`
   - `parseShowDurationSpeed()`
   - `parseShowDuration()`
   - `parseShowAttributesDescription()`
   - `parseClassificationDescription()`
   - `getTierEffectDescription()`
   - `getWeightDescription()` (wersja statyczna)

2. **`src/items/item.cpp`** - ~150 linii zmian:
   - 7 helperów przepisanych na i18n z `tr.get()` / `tr.format()`
   - `getDescription()` (~800 linii) - ~90 hardcodowanych angielskich stringów zastąpionych kluczami i18n
   - Wzorzec: `std::string locStr(locale.empty() ? "en" : locale)` na początku funkcji

3. **`src/game/game.cpp`**:
   - Dodano `#include "utils/i18n/translator.hpp"`
   - `playerLookInShop()` - przekazuje locale gracza do `getDescription()`

### Klucze i18n (80 nowych, 184 łącznie w cpp.json):

Kategorie kluczy `cpp.look.*`:
- Rune requirements (level_n, magic_level_n, rune_requires)
- Weapon stats (range, atk, def, hit_percent, vol)
- Equipment effects (protections, magic level, shield capacity)
- Ring/necklace effects
- Containers/fluids (empty, full of)
- Books/writable items
- Charges (charges_one, charges_many)
- Wield info (vocation requirements, level)
- Weight (it_weighs, they_weigh)
- Duration (expires in, brand-new, day/hour/minute/second)
- Imbuements (slots, empty slot)
- Classification & tier effects (Onslaught, Momentum, Ruse, Transcendence, Amplification)
- Shop look (you_see)

### JSON sync:
- 80 nowych kluczy zsynchronizowanych do 52 języków (53 z EN)
- Pliki `i18n/*/cpp.json` zaktualizowane

## Problemy napotkane

1. **`tr.format()` API** - przyjmuje `std::vector<std::string>` a nie variadic args. Poprawione 28+ wywołań na syntax `{std::to_string(val)}` lub `{stringVal}`.
2. **Build lokalny** - vcpkg path issues (budujemy tylko na GitHub Actions).

## Co NIE zostało zmodyfikowane (do zrobienia później)

- `getDescriptions()` - market/inspect UI (inny format)
- `getSkillName()` / `getCombatName()` - nazwy skilli/combatów (osobne zadanie)
- `parseAugmentDescription()` w `items.cpp` (metoda ItemType, nie Item)
- `getTradeErrorDescription()` w game.cpp - brak parametru locale

## Następne kroki

- Migracja `getDescriptions()` (market inspect)
- Migracja `getSkillName()` / `getCombatName()`
- Migracja pozostałych C++ stringów (creature look, trade errors)
- Tłumaczenia kluczy na inne języki (DE, PL, ES, etc.)
