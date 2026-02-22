# 🔄 BRIEFING DLA NOWEGO CZATU — Arena PvP & Canary Server

> **Data:** 2026-02-21  
> **Repo:** `PtakuPL/ooo`, branch `master`  
> **Ostatni commit:** `217d34066` (fix: arena Lua scripts - use valid EventCallback types)  
> **Serwer:** Canary v3.2.0, protokół 14.12  
> **Workspace:** `/home/ptaku/serweryt/Tibia/silnik/canary_test/`

---

## CO ZOSTAŁO ZROBIONE

### Kompilacja C++ ✅
- fmt v12 łamał kompilację 5 enumów — naprawiono bezwarunkowym `format_as<E>` w `src/pch.hpp`
- CI build na GitHub Actions przechodzi (commit `5688443c9`)

### Binaria ✅
- Pobrane z CI: release (147M) + debug (217M) dla ubuntu-24.04
- Zainstalowane w `canary_test/`

### Startup serwera ✅
- Serwer startuje z ZEREM błędów arena
- Jedyny błąd: `bozo.lua:81` (niezwiązany z areną — `unexpected symbol near '['`)
- Serwer wyświetla: "Tibia 7.4 test server online!"

### Arena system — fazy zrobione:
| Faza | Opis | Status |
|------|------|--------|
| 0 | Przygotowanie (baza, mapy) | ✅ |
| 1 | Baza danych (schema.sql) | ✅ |
| 2 | Core C++ (ArenaSystem, matchmaking, IOArena) | ✅ |
| 3 | Hooki C++ (creature/player/game) | ✅ |
| 4 | Protokół sieciowy (parseArenaAction, sendArena*) | ✅ |
| 5 | Lua scripting layer (15 plików) | ✅ |
| 8 | Security, anti-cheat, logging | ✅ |
| 10 | i18n (EN+PL + 55 locale fallback, ~90 kluczy) | ✅ |
| 11.1 | Testy jednostkowe C++ | ✅ |
| 12 | Dokumentacja (API, GM guide, deploy checklist) | ✅ |

---

## CO TRZEBA ROBIĆ DALEJ

### 🔴 PRIORYTET WYSOKI

1. **Faza 6 — UI klienta (OTC)**
   - Okno areny w kliencie (podobne do Market)
   - Przyciski: Join Queue, Stats, Ranking, Shop
   - Obsługa opcodes arena w kliencie
   - **UWAGA:** Prace nad OTC są OSOBNYM projektem — użytkownik mówił "ty masz się zająć buildem canary a nie instalką otc!!!" — więc UI klienta robić TYLKO jeśli user poprosi

2. **Nowe C++ EventCallback types** (opcjonalnie)
   - Brakuje w Canary: `playerOnSpellCheck`, `playerOnUseItem`, `playerOnLogout`, `playerOnDeath`
   - Potrzebne do pełnej blokady spelli i itemów w arenie
   - Wymaga zmian w: `callbacks_definitions.hpp`, `event_callback.cpp`, `player.cpp`
   - Aktualnie obejście: `playerOnMoveItem` blokuje przenoszenie, `creatureOnDrainHealth` zapobiega śmierci

3. **ArenaConfig.enabled = true**
   - Obecnie arena jest wyłączona (`enabled = false`) w `data/libs/systems/arena.lua`
   - Włączyć gdy system C++ ArenaSystem będzie przetestowany

### 🟡 PRIORYTET ŚREDNI

4. **Faza 7 — WWW (strona WWW z rankingiem)**
   - Endpoint API do topek areny
   - Strona pod MyAccount z podglądem statystyk gracza

5. **Faza 9 — Sezony**
   - System sezonów z resetem MMR
   - Nagrody za sezon

6. **Faza 11 (reszta) — Testy**
   - 11.2: Testy integracyjne (pełny flow meczu)
   - 11.4: Testy obciążeniowe (wielu graczy jednocześnie)
   - 11.5: Balans (nagrody, MMR, cooldowny)

### 🟢 PRIORYTET NISKI

7. **Naprawa bozo.lua:81** — `unexpected symbol near '['` w `data-otservbr-global/npc/bozo.lua` (niezwiązane z areną, ale warto naprawić)

8. **Pełna lista NPC Arena Master dialogów** — przetestować czy NPC odpowiada poprawnie na wszystkie słowa kluczowe (arena, modes, join, stats, ranking, shop, help)

---

## WAŻNE ZASADY

- **Buildy TYLKO na GitHub Actions** — zakaz używania cmake/make lokalnie
- **Wszystko do brancha `master`** w repo `PtakuPL/ooo`
- **Po każdym zakończeniu pracy** → aktualizuj dokumentację w `/home/ptaku/serweryt/Tibia/silnik/Dokumentacja/`
- **Focus na Canary server** — nie OTC client (chyba że user poprosi)
- **Otwieraj pliki w całości** przed edycją aby uniknąć błędów z wcięciami

---

## PLIKI KLUCZOWE

### Dokumentacja
- `Dokumentacja/02_Serwer_Canary/areny/ARENA_PVP_PLAN_ZADAN.md` — główny plan zadań
- `Dokumentacja/02_Serwer_Canary/2026-02-21_arena_kompilacja_i_startup.md` — pełna dokumentacja tej sesji
- `Dokumentacja/02_Serwer_Canary/2026-02-21_arena_lua_fixes.md` — szczegóły napraw Lua

### Konfiguracja
- `canary_test/data/libs/systems/arena.lua` — ArenaConfig (globalny config Lua)
- `canary_test/config.lua` — konfiguracja serwera

### Poprawne EventCallback types
Lista w: `src/lua/callbacks/callbacks_definitions.hpp`
Dokumentacja: `Dokumentacja/02_Serwer_Canary/2026-02-21_arena_kompilacja_i_startup.md` sekcja 5

### fmt fix
- `src/pch.hpp` — generyczny `format_as<E>` template (NIE RUSZAĆ — naprawia kompilację)
