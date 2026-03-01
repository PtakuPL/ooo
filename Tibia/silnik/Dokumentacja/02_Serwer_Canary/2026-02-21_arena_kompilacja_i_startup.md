# Arena PvP - Kompilacja, Build, Startup (2026-02-21)

## Podsumowanie sesji

W tej sesji naprawiono kompilację serwera Canary (C++), pobrano binaria z CI, 
uruchomiono serwer i naprawiono wszystkie błędy Lua systemu arena.

---

## 1. Naprawa kompilacji C++ (fmt v12)

### Problem
Serwer Canary nie kompilował się na GitHub Actions. Błąd:
```
static_assert failed: don't know how to format CoinType
```
Dotyczyło 5 enumów: `CoinType`, `CoinTransactionType`, `AccountType`, `MarketOfferState_t`, `MarketAction_t`.

### Przyczyna
- Commit `0364a1c14` wyłączył generyczny `format_as<E>` dla fmt >= 8
- fmt v12 (FMT_VERSION >= 120000) usunął automatyczne formatowanie enumów
- Próba naprawy przez `fmt::formatter` partial specialization nie działa z fmt v12 bo `static_assert` odpala się w primary template PRZED rozpatrzeniem specjalizacji

### Rozwiązanie
Przywrócono bezwarunkowy generyczny `format_as<E>` template w `src/pch.hpp`:
```cpp
template <typename E>
    requires std::is_enum_v<E>
constexpr auto format_as(E e) {
    return fmt::underlying(e);
}
```
To działa dla WSZYSTKICH wersji fmt (7, 8, 9, 10, 11, 12+).

### Commit: `5688443c9`
### Pliki zmienione:
- `src/pch.hpp` — dodany bezwarunkowy `format_as`
- `src/lib/logging/fmt_extensions.hpp` — wyczyszczony (pusty placeholder)

---

## 2. CI Build i pobranie binarek

- GitHub Actions build #22 przeszedł pomyślnie
- Pobrano artefakty: `canary-ubuntu-24.04-linux-debug` i `canary-ubuntu-24.04-linux-release`
- Binaria skopiowane do `/home/ptaku/serweryt/Tibia/silnik/canary_test/`
  - `canary` — release (147M)
  - `canary-debug` — debug (217M)

---

## 3. Naprawa błędów Lua arena

### Problem
Serwer startował ale wyświetlał błędy Lua w 3 plikach arena:

| Plik | Linia | Błąd |
|------|-------|------|
| `arena_security.lua` | 27, 64, 84, 188, 208 | Invalid EventCallback with name: {} |
| `arena_main.lua` | 82 | invalid escape sequence near 'UPDATE' |
| `arena_on_death.lua` | 7 | Invalid EventCallback with name: {} |
| `arena_security.lua` | 75 (runtime) | Wrong enum (configKeys.ARENA_SYSTEM_ENABLED) |

### Przyczyna

**EventCallback** — Canary używa systemu `EventCallback_t` enum zdefiniowanego w `src/lua/callbacks/callbacks_definitions.hpp`. Skrypty arena używały nazw callbacków które NIE ISTNIEJĄ w tym enumie:

| Użyte (NIE ISTNIEJE) | Zamienione na (ISTNIEJE) |
|---|---|
| `playerOnSpellCheck` | Usunięte (brak odpowiednika) |
| `playerOnItemUse` | `playerOnMoveItem` |
| `playerOnPartyInvite` | `partyOnJoin` |
| `playerOnGainSkullTicks` | `playerOnLoseExperience` |
| `playerOnLogout` | Usunięte (C++ obsługuje) |
| `playerOnDeath` | `creatureOnDrainHealth` + `playerOnLoseExperience` |

**SQL escape** — Lua 5.3+ nie obsługuje `\`` jako escape. Backtick nie wymaga escapowania w Lua.

**configKeys** — `configKeys.ARENA_SYSTEM_ENABLED` nie istnieje w Canary config. Zamienione na `ArenaConfig.enabled` (Lua-side flaga).

### Naprawy

#### arena_security.lua
- Usunięto sekcję 1 (spell blocking) — wymaga `playerOnSpellCheck` który nie istnieje
- Sekcja 2 (item blocking): `playerOnItemUse` → `playerOnMoveItem`
- Sekcja 3 (party blocking): `playerOnPartyInvite` → `partyOnJoin`
- Sekcja 4 (AFK): `configManager.getBoolean(configKeys.ARENA_SYSTEM_ENABLED)` → `ArenaConfig.enabled`
- Sekcja 5 (skull blocking): `playerOnGainSkullTicks` → `playerOnLoseExperience`
- Sekcja 6 (logout): usunięta (C++ `Arena.onPlayerLogout` obsługuje)

#### arena_main.lua
- Linia 82: `"UPDATE \`arena_players\`..."` → `"UPDATE `arena_players`..."`

#### arena_on_death.lua
- `playerOnDeath` → `creatureOnDrainHealth` (przechwytuje obrażenia śmiertelne, uzdrawia zamiast zabijać) + `playerOnLoseExperience` (blokuje utratę exp)

#### arena.lua (ArenaConfig)
- Dodano pole `enabled = false` jako domyślny wyłącznik systemu

### Commit: `217d34066`

---

## 4. Wynik końcowy

```
Serwer startuje z ZEREM błędów arena.
Jedyny pozostały błąd: bozo.lua:81 (niezwiązany z areną)
Serwer wyświetla: "Tibia 7.4 test server online!"
Przy zamykaniu: "[Arena] Shutting down - 0 active matches"
```

---

## 5. Pełna lista EventCallback types w Canary

Zdefiniowane w `src/lua/callbacks/callbacks_definitions.hpp`:

**Creature:** `creatureOnChangeOutfit`, `creatureOnAreaCombat`, `creatureOnTargetCombat`, `creatureOnDrainHealth`, `creatureOnCombat`

**Party:** `partyOnJoin`, `partyOnLeave`, `partyOnDisband`, `partyOnShareExperience`

**Player:** `playerOnBrowseField`, `playerOnLook`, `playerOnLookInBattleList`, `playerOnLookInTrade`, `playerOnLookInShop`, `playerOnMoveItem`, `playerOnItemMoved`, `playerOnChangeZone`, `playerOnChangeHazard`, `playerOnMoveCreature`, `playerOnReportRuleViolation`, `playerOnReportBug`, `playerOnTurn`, `playerOnTradeRequest`, `playerOnTradeAccept`, `playerOnGainExperience`, `playerOnLoseExperience`, `playerOnGainSkillTries`, `playerOnRequestQuestLog`, `playerOnRequestQuestLine`, `playerOnStorageUpdate`, `playerOnRemoveCount`, `playerOnCombat`, `playerOnInventoryUpdate`, `playerOnRotateItem`, `playerOnWalk`, `playerOnThink`

**Monster:** `monsterOnDropLoot`, `monsterPostDropLoot`

**Zone:** `zoneBeforeCreatureEnter`, `zoneBeforeCreatureLeave`, `zoneAfterCreatureEnter`, `zoneAfterCreatureLeave`

**Map:** `mapOnLoad`

---

## 6. Kompletna lista plików systemu Arena

### C++ (src/)
| Plik | Opis |
|------|------|
| `src/game/arena/arena_definitions.hpp` | Definicje enum/struct |
| `src/game/arena/arena_system.hpp/.cpp` | Główny system |
| `src/game/arena/arena_match.hpp/.cpp` | Logika meczu |
| `src/game/arena/arena_matchmaking.hpp/.cpp` | Matchmaking/MMR |
| `src/io/ioarena.hpp/.cpp` | I/O bazy danych |
| `src/lua/functions/core/game/arena_functions.hpp/.cpp` | Lua bindings |

### Lua - Lib
| Plik | Opis |
|------|------|
| `data/libs/systems/arena.lua` | ArenaConfig (konfiguracja globalna) |

### Lua - Scripts
| Plik | Opis |
|------|------|
| `data/scripts/arena/arena_main.lua` | Główna logika (nagrody, ogłoszenia) |
| `data/scripts/arena/arena_security.lua` | Bezpieczeństwo, AFK, blokady |
| `data/scripts/arena/arena_anticheat.lua` | Anti-cheat |
| `data/scripts/arena/arena_logging.lua` | Logowanie zdarzeń |
| `data/scripts/arena/modes/duel_1v1.lua` | Tryb 1v1 |
| `data/scripts/arena/modes/team_2v2.lua` | Tryb 2v2 |
| `data/scripts/arena/modes/team_3v3.lua` | Tryb 3v3 |
| `data/scripts/arena/modes/ffa.lua` | Free For All |
| `data/scripts/arena/modes/ctf.lua` | Capture The Flag |
| `data/scripts/arena/modes/koth.lua` | King of the Hill |
| `data/scripts/arena/modes/lms.lua` | Last Man Standing |
| `data/scripts/arena/modes/tournament.lua` | Turniej |

### Lua - EventCallbacks
| Plik | Opis |
|------|------|
| `data/scripts/eventcallbacks/player/arena_on_death.lua` | Zapobieganie śmierci w arenie |

### NPC
| Plik | Opis |
|------|------|
| `data-otservbr-global/npc/arena_master.lua` | NPC Arena Master |

### i18n
| Plik | Klucze |
|------|--------|
| `i18n/en/arena.json` | 194 linii, ~90 kluczy EN |
| `i18n/pl/arena.json` | 165 linii, tłumaczenie PL |
| + 55 pozostałych locali | Fallback do EN |

### Testy
| Plik | Opis |
|------|------|
| `tests/unit/arena/arena_definitions_test.cpp` | Testy definicji |
| `tests/unit/arena/arena_matchmaking_test.cpp` | Testy matchmakingu |

### Dokumentacja (w repo)
| Plik | Opis |
|------|------|
| `docs/API_ARENA.md` | API reference |
| `docs/ARENA_DEPLOY_CHECKLIST.md` | Checklist wdrożenia |
| `docs/ARENA_GM_GUIDE.md` | Instrukcja dla GM |
| `docs/ARENA_TEST_CHECKLIST.md` | Checklist testów |
