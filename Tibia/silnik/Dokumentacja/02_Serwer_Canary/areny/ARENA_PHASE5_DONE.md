# ⚔️ Arena PvP — Faza 5: Skrypty Lua — GOTOWA

> **Data:** 2026-02-21  
> **Commit:** `89b305974` (master)  
> **Pliki:** 15 nowych + 1 modyfikowany = 1039 linii kodu

---

## Zrealizowane zadania

### 5.1 ✅ Biblioteka konfiguracji (`data/libs/systems/arena.lua`)
- Tabela `ArenaConfig` z minLevel, cooldown, storage keys, rewards
- Ustawienia MMR (initial, k-factor, min/max gain)
- Nazwy i opisy trybów (MODE_1V1 do MODE_TOURNAMENT)
- System tytułów (12 rangów: Novice → Immortal, po MMR)
- Sklep areny (4 przedmioty za Arena Points)
- Funkcje helper: `getTitleForMMR()`, `canPlayerJoin()`, `formatRecord()`, `formatKDR()`
- Załadowane w `load.lua` (pierwszy wpis alfabetycznie)

### 5.2 ✅ Główna logika areny (`data/scripts/arena/arena_main.lua`)
- Tabela `ArenaPvP` z pełną logiką Lua
- `validateMatchGroup()` — walidacja drużyny przed meczem
- `processMatchRewards()` — MVP bonus, killing spree bonus, zapis do DB
- `broadcast()` / `announceResult()` — ogłoszenia wyników
- `checkTitlePromotion()` — automatyczne awanse tytułów
- `getQueueSummary()` — podsumowanie kolejek dla GM

### 5.3 ✅ Skrypty trybów (`data/scripts/arena/modes/`)
| Plik | Tryb | Gracze | Czas | Specjalne |
|------|------|--------|------|-----------|
| `duel_1v1.lua` | 1v1 Duel | 2 | 5 min | Bez respawnu |
| `team_2v2.lua` | 2v2 Team | 4 | 7 min | 2 zespoły |
| `team_3v3.lua` | 3v3 Team | 6 | 10 min | 2 zespoły |
| `ffa.lua` | Free For All | 4-8 | 5 min | Respawn, kille |
| `lms.lua` | Last Man Standing | 4-8 | 15 min | Bez respawnu |
| `ctf.lua` | Capture The Flag | 6-10 | 10 min | 3 captures |
| `koth.lua` | King of the Hill | 4-8 | 8 min | 100 score |
| `tournament.lua` | Tournament | 8-16 | 5 min | Bracket |

### 5.4 ✅ EventCallbacks
- `arena_on_death.lua` — blokada normalnej śmierci w arenie (brak trupa, brak exp loss, brak item drop)
- `arena_on_combat.lua` — walidacja walki (gracze areny vs non-arena)

### 5.5 ✅ Komendy graczy
- `!arena-shop` / `!arenashop` — sklep za Arena Points (lista, kupno)
- `!arena-title` — wyświetlanie postępu tytułów

### 5.6 ✅ Komendy GM (`!arena-admin`)
- `info` — status systemu (aktywne mecze, kolejki)
- `stats <gracz>` — statystyki gracza
- `setmmr <gracz> <mmr>` — ustawienie MMR (testy)
- `addpoints <gracz> <n>` — dodanie Arena Points
- `reset <gracz>` — reset statystyk
- `broadcast <msg>` — ogłoszenie areny

---

## Istniejące pliki (z wcześniejszych faz)
- `data/scripts/talkactions/player/arena.lua` — komenda `!arena` (join/leave/stats/ranking/history/modes/status)
- `data-otservbr-global/npc/arena_master.lua` — NPC Arena Master (dialog, statystyki, ranking)
- `data/migrations/20260221_arena_tables.sql` — 6 tabel DB

## C++ Lua bindings (Faza 2)
- `Arena.getPlayerStats(id)`, `Arena.getTopRanking(mode, limit)`, `Arena.getPlayerHistory(id, limit)`
- `Arena.getActiveMatchCount()`, `Arena.getQueueSize(mode)`
- `Arena.MODE_*` (8 trybów), `Arena.STATE_*` (3 stany)
- `Player:arenaJoinQueue(mode)`, `arenaLeaveQueue()`, `arenaGetState()`, `arenaIsInArena()`, `arenaIsInQueue()`, `arenaGetStats()`, `arenaGetMMR()`, `arenaSendStatus()`

---

## Problemy rozwiązane
1. **Lua PANIC** (commit `93637c274`): `ArenaFunctions::init(L)` wywoływane przed `CreatureFunctions::init(L)` — klasa "Player" jeszcze nie istniała. Przeniesione do `lua_functions_loader.cpp` po `CreatureFunctions`.
2. **MESSAGE_INFO_DESCR** (commit `4ca838ab6`): Enum nie istnieje w Canary — zamienione na `MESSAGE_EVENT_ADVANCE`.
3. **CI build errors** (commit `9c2e0f5ac`): `MESSAGE_STATUS_SMALL`, `Position::sendMagicEffect()`, nieużywana zmienna `Condition*`.

---

## Co dalej
- **Faza 6:** Interfejs klienta OTClient (moduł `game_arena`)
- **Faza 7:** Strona WWW (rankingi, profil gracza)
- **Faza 8:** Anti-cheat (blokady teleportów, anty-wintrading)
