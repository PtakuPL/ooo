# ⚔️ Arena PvP — Dokładny Plan Zadań (krok po kroku)

> **Data:** 2026-02-21 (aktualizacja: 2026-02-21 20:00)  
> **Bazuje na:** ARENA_SYSTEM_PLAN.md  
> **Stan obecny:** ✅ Fazy 0-5, 8, 10, 11 (częściowo), 12 GOTOWE. Kompilacja C++ ✅, Build CI ✅, Startup serwera ✅ (zero błędów arena). System gotowy do pre-alpha.  
> **Brakuje:** UI klienta (Faza 6), WWW (Faza 7), sezony (Faza 9), testy integracyjne/obciążeniowe/balans (Faza 11.2/11.4/11.5), nowe C++ EventCallback types (playerOnSpellCheck, playerOnUseItem) dla pełnej blokady spelli/itemów.  
> **Pre-alpha target: ✅ OSIĄGNIĘTY** — serwer kompiluje się, startuje, zero błędów arena.  
> **Ostatni commit:** `217d34066` — fix arena Lua scripts  
> **Poprzedni fix:** `5688443c9` — fix fmt v12 format_as (kompilacja C++)

---

## 📋 LEGENDA STATUSÓW

- ⬜ Do zrobienia
- 🔄 W trakcie
- ✅ Zrobione

---

## FAZA 0 — PRZYGOTOWANIE PROJEKTU (2-3 dni)

### 0.1 ✅ Analiza istniejącego kodu serwera
- Przejrzeć jak działa Market (okno klienta) — będzie wzorcem do UI areny
- Przeanalizować istniejące systemy: Party, Guild, Combat — na nich oprzemy hooki
- Zrozumieć flow pakietów klient↔serwer (protocolgame.cpp/hpp)
- Zidentyfikować wolne opcody do wykorzystania dla areny

### 0.2 ✅ Zaprojektowanie map areny w edytorze mapy
- Stworzyć min. 3 mapy aren (mała 1v1, średnia 3v3, duża FFA/LMS)
- Oznaczyć pozycje spawnów (team A, team B, FFA spawny)
- Dodać strefy: poczekalnia (lobby), arena walki, strefa wyjścia
- Ustawić barierki/ściany uniemożliwiające ucieczkę
- Zapisać koordynaty spawn pointów do późniejszej konfiguracji

### 0.3 ✅ Backup i branch
- Stworzyć nowy branch git np. `feature/arena-pvp`
- Backup bazy danych przed zmianami schemy

---

## FAZA 1 — BAZA DANYCH (1-2 dni)

### 1.1 ✅ Utworzenie tabeli `arena_players`
**Plik:** `schema.sql` (dodać na końcu) + plik migracji `data/migrations/arena_tables.sql`
```sql
CREATE TABLE IF NOT EXISTS `arena_players` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `player_id` INT NOT NULL,
    `mmr` INT DEFAULT 1000,
    `wins` INT DEFAULT 0,
    `losses` INT DEFAULT 0,
    `draws` INT DEFAULT 0,
    `win_streak` INT DEFAULT 0,
    `best_streak` INT DEFAULT 0,
    `total_damage` BIGINT DEFAULT 0,
    `total_healing` BIGINT DEFAULT 0,
    `total_kills` INT DEFAULT 0,
    `total_deaths` INT DEFAULT 0,
    `last_match` DATETIME NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_player` (`player_id`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 1.2 ✅ Utworzenie tabeli `arena_matches`
```sql
CREATE TABLE IF NOT EXISTS `arena_matches` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `mode` ENUM('1v1','2v2','3v3','ffa','ctf','koth','lms','tournament') NOT NULL,
    `map_id` INT DEFAULT 0,
    `started_at` DATETIME NOT NULL,
    `ended_at` DATETIME NULL,
    `duration` INT DEFAULT 0,
    `winner_team` INT DEFAULT 0,
    `season_id` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 1.3 ✅ Utworzenie tabeli `arena_match_players`
```sql
CREATE TABLE IF NOT EXISTS `arena_match_players` (
    `match_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `team` INT DEFAULT 0,
    `kills` INT DEFAULT 0,
    `deaths` INT DEFAULT 0,
    `damage_dealt` BIGINT DEFAULT 0,
    `healing_done` BIGINT DEFAULT 0,
    `mmr_change` INT DEFAULT 0,
    PRIMARY KEY (`match_id`, `player_id`),
    FOREIGN KEY (`match_id`) REFERENCES `arena_matches`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 1.4 ✅ Utworzenie tabeli `arena_queue`
```sql
CREATE TABLE IF NOT EXISTS `arena_queue` (
    `player_id` INT PRIMARY KEY,
    `mode` VARCHAR(20) NOT NULL,
    `mmr` INT DEFAULT 1000,
    `queued_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expanded_range` INT DEFAULT 0,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 1.5 ✅ Utworzenie tabel sezonów
```sql
CREATE TABLE IF NOT EXISTS `arena_seasons` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `is_active` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `arena_season_rankings` (
    `season_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `final_mmr` INT DEFAULT 1000,
    `final_rank` INT DEFAULT 0,
    `rewards_claimed` TINYINT(1) DEFAULT 0,
    PRIMARY KEY (`season_id`, `player_id`),
    FOREIGN KEY (`season_id`) REFERENCES `arena_seasons`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 1.6 ✅ Wykonanie migracji na serwerze deweloperskim
- Uruchomić SQL na bazie testowej
- Sprawdzić czy FK działają poprawnie
- Przetestować INSERT/SELECT/UPDATE na każdej tabeli

---

## FAZA 2 — CORE C++ SERWERA (1-2 tygodnie)

### 2.1 ✅ Utworzenie struktury plików C++
Stworzyć pliki:
```
src/game/arena/arena_system.hpp
src/game/arena/arena_system.cpp
src/game/arena/arena_matchmaking.hpp
src/game/arena/arena_matchmaking.cpp
src/game/arena/arena_match.hpp
src/game/arena/arena_match.cpp
```

### 2.2 ✅ Klasa `ArenaMatch` — stan pojedynczego meczu
```cpp
// arena_match.hpp
enum class ArenaMode : uint8_t {
    DUEL_1V1, TEAM_2V2, TEAM_3V3, FFA, CTF, KOTH, LMS, TOURNAMENT
};

enum class ArenaMatchState : uint8_t {
    WAITING, COUNTDOWN, IN_PROGRESS, FINISHED
};

struct ArenaPlayerStats {
    uint32_t playerId;
    uint8_t team;
    uint16_t kills = 0;
    uint16_t deaths = 0;
    uint64_t damageDealt = 0;
    uint64_t healingDone = 0;
    int32_t mmrChange = 0;
};

class ArenaMatch {
public:
    uint32_t matchId;
    ArenaMode mode;
    ArenaMatchState state;
    uint32_t mapId;
    int64_t startTime;
    int64_t maxDuration; // ms
    std::map<uint32_t, ArenaPlayerStats> players; // playerId -> stats
    uint8_t winnerTeam = 0;
    // metody: addPlayer, removePlayer, onKill, onDeath, checkWinCondition, finish
};
```

### 2.3 ✅ Klasa `ArenaSystem` — singleton zarządzający areną
Odpowiedzialności:
- Zarządzanie kolejkami (`joinQueue`, `leaveQueue`)
- Utrzymywanie listy aktywnych meczów
- Tworzenie/kończenie meczów
- Hooki do combatu (`onArenaKill`, `onArenaDeath`, `onArenaLogout`)
- Periodic tick (matchmaking co 5s)
- Zapis/odczyt z bazy danych
- Sprawdzanie czy gracz jest w arenie (`isPlayerInArena`)

### 2.4 ✅ Integracja ArenaSystem z klasą `Game`
- Dodać `ArenaSystem` jako member `Game` (lub singleton)
- Załadować ArenaSystem w `Game::start()`
- Wywoływać `ArenaSystem::tick()` co 5 sekund z głównej pętli
- Dodać cleanup w `Game::shutdown()`

### 2.5 ✅ Hooki do istniejącego systemu walki
- W `Player::onKilledCreature()` → sprawdzić `ArenaSystem::isPlayerInArena()` → jeśli tak, wywołać `ArenaSystem::onArenaKill()`
- W `Player::onDeath()` → analogicznie `ArenaSystem::onArenaDeath()`
- W `Player::logout()` → `ArenaSystem::onArenaLogout()` (gracz przegrywa mecz)
- Zmodyfikować logikę PvP: w arenie nie tracisz exp, nie dostajesz skulli, nie dropujesz itemów

### 2.6 ✅ Logika teleportów i przygotowania meczu
- Teleportacja graczy na pozycje spawnów areny
- Odliczanie 5s przed startem (efekty wizualne)
- Po zakończeniu — teleportacja z powrotem do temple/punktu wejścia
- Przywrócenie HP/Mana do pełna na starcie meczu
- Zdjęcie negatywnych stanów (poison, fire, etc.)

### 2.7 ✅ Zapis wyników do bazy danych
- Po zakończeniu meczu → INSERT do `arena_matches`
- INSERT do `arena_match_players` dla każdego uczestnika
- UPDATE `arena_players` (mmr, wins/losses, streak, total_damage itd.)
- Obsługa transakcji SQL (rollback w razie błędu)

### 2.8 ✅ Aktualizacja CMakeLists.txt
- Dodać nowe pliki .cpp/.hpp do buildu
- Upewnić się że kompilacja przechodzi czysto

---

## FAZA 3 — MATCHMAKING (3-5 dni)

### 3.1 ✅ Klasa `ArenaMatchmaking`
Odpowiedzialności:
- Kolejka graczy per tryb (osobna kolejka dla 1v1, 2v2, 3v3 itd.)
- Algorytm dobierania po MMR
- Rozszerzanie zakresu szukania z upływem czasu

### 3.2 ✅ Algorytm MMR
```
Formuła: MMR = Base(1000) + Wins×25 - Losses×20 + Streak×5
Zmiana po meczu:
  - Zwycięstwo: +25 (modyfikowane różnicą MMR)
  - Porażka:    -20 (modyfikowane różnicą MMR)
  - Remis:       0
K-factor: jeśli różnica MMR duża → mniejsza strata dla słabszego
```

### 3.3 ✅ Rozszerzanie zakresu szukania
```
0-30s:   MMR ±100
30-60s:  MMR ±200
60-120s: MMR ±500
120s+:   dowolny przeciwnik
```
- Stan zakresu zapisywany w `arena_queue.expanded_range`
- Tick co 5s sprawdza i rozszerza zakres

### 3.4 ✅ Auto-balance drużyn (2v2, 3v3)
- Sortowanie graczy w kolejce po MMR
- Podział „zygzakiem": 1. gracz → team A, 2. → team B, 3. → team B, 4. → team A
- Sprawdzenie że jedna drużyna nie ma 2+ graczy tej samej vocation (opcjonalnie)

### 3.5 ✅ Powiadomienia dla graczy w kolejce
- Wysyłanie komunikatów: „Szukanie przeciwnika... (30s)"
- „Rozszerzono zakres szukania"
- „Znaleziono mecz! Przygotuj się..."

---

## FAZA 4 — PROTOKÓŁ SIECIOWY (3-5 dni)

### 4.1 ✅ Zdefiniowanie nowych opcodes
W `src/server/network/`:
```
Client → Server:
  ARENA_OPEN           = 0xD0  (otwórz okno areny)
  ARENA_JOIN_QUEUE     = 0xD1  (dołącz do kolejki, param: mode)
  ARENA_LEAVE_QUEUE    = 0xD2  (opuść kolejkę)
  ARENA_REQUEST_RANKING = 0xD3 (żądanie rankingu, param: page, filter)
  ARENA_REQUEST_HISTORY = 0xD4 (żądanie historii meczów)

Server → Client:
  ARENA_STATUS         = 0xD5  (stan: idle/queue/match + info)
  ARENA_STATS          = 0xD6  (MMR, wins, losses, streak)
  ARENA_MATCH_FOUND    = 0xD7  (info o meczu, przeciwnikach)
  ARENA_RANKING_DATA   = 0xD8  (dane rankingowe)
  ARENA_MATCH_UPDATE   = 0xD9  (aktualizacja w trakcie meczu: czas, score)
  ARENA_MATCH_RESULT   = 0xDA  (wynik po zakończeniu meczu)
```
**UWAGA:** Sprawdzić które opcody są wolne! Nie kolidować z istniejącymi.

### 4.2 ✅ Implementacja parsowania pakietów klienta (protocolgame.cpp)
- `parseArenaOpen()` → odczyt z DB + wysłanie `ARENA_STATS`
- `parseArenaJoinQueue()` → odczyt mode + wywołanie `ArenaSystem::joinQueue()`
- `parseArenaLeaveQueue()` → `ArenaSystem::leaveQueue()`
- `parseArenaRequestRanking()` → query DB + wysłanie `ARENA_RANKING_DATA`

### 4.3 ✅ Implementacja wysyłania pakietów do klienta
- `sendArenaStatus()` → informacja o stanie gracza w systemie areny
- `sendArenaStats()` → statystyki gracza (MMR itd.)
- `sendArenaMatchFound()` → dane meczu
- `sendArenaRankingData()` → lista rankingowa
- `sendArenaMatchUpdate()` → score/czas w trakcie meczu
- `sendArenaMatchResult()` → podsumowanie meczu

### 4.4 ✅ Rejestracja handlerów
- Dodać nowe case'y w switch opcode w `ProtocolGame::parsePacket()`
- Powiązać opcodes klienta z funkcjami parsującymi

---

## FAZA 5 — SKRYPTY LUA (1 tydzień)

### 5.1 ✅ Przebudowa istniejących skryptów arena_pvp
- Przepisać `arena_2x2.lua` i `arena_10x10.lua` aby korzystały z `ArenaSystem`
- Zamiast prostych teleportów → `ArenaSystem.joinQueue(player, "2v2")`

### 5.2 ✅ Utworzenie `data/scripts/arena/arena_main.lua`
- Rejestracja eventów (GlobalEvent dla ticka matchmakingu)
- Konfiguracja map, pozycji spawnów, trybów
- Komenda `/arena` — otwieranie menu areny (tymczasowo zanim będzie UI klienta)

### 5.3 ✅ Skrypty trybów w `data/scripts/arena/modes/`
Każdy plik definiuje reguły trybu:
- `duel_1v1.lua` — warunek wygranej: zabij przeciwnika (lub timer → HP%)
- `team_2v2.lua` / `team_3v3.lua` — warunek: eliminacja całego teamu
- `ffa.lua` — najwięcej killów w limicie czasu
- `lms.lua` — ostatni żywy wygrywa
- `ctf.lua` — zdobądź i przynieś flagę (wymaga specjalnej mapy z flagami)
- `koth.lua` — utrzymaj punkt centralny najdłużej

### 5.4 ✅ NPC `arena_master.lua`
- Rozmowa o systemie areny
- Sprawdzenie statystyk gracza
- Pokazanie Top 10 rankingu
- Wejście do kolejki przez dialog NPC (alternatywa dla UI klienta)
- Sklep areny (wydawanie Arena Points na nagrody)

### 5.5 ✅ Lua bindings — eksport funkcji C++ do Lua
Dodać w `src/lua/functions/`:
```lua
-- Funkcje dostępne z Lua:
Arena.joinQueue(player, mode)
Arena.leaveQueue(player)
Arena.getPlayerStats(player) -- zwraca table {mmr, wins, losses, streak, ...}
Arena.getTopRanking(mode, limit) -- zwraca top X graczy
Arena.isPlayerInArena(player) -- bool
Arena.isPlayerInQueue(player) -- bool
```

### 5.6 ✅ System nagród w Lua
- `arena_rewards.lua` — tabela nagród per wynik
- Arena Points jako storage value gracza
- Sklep: wymiana Arena Points na outfity, mounty, tytuły, dekoracje
- Nagrody sezonowe: automatyczne przyznanie po zakończeniu sezonu

---

## FAZA 6 — INTERFEJS KLIENTA (1-2 tygodnie)

### 6.1 ⬜ Nowe okno "Arena" w kliencie (OTClient)
- Moduł `modules/game_arena/` w OTClient
- Okno wzorowane na Market: lista trybów, statystyki, przycisk Join/Leave
- Zakładki: Tryby | Ranking | Historia | Nagrody

### 6.2 ⬜ Widok trybów
- Kafle/przyciski dla każdego z 6-8 trybów
- Ikona + nazwa + krótki opis + wymagane ilości graczy
- Podświetlenie aktywnego trybu
- Przycisk "Dołącz do kolejki" / "Opuść kolejkę"

### 6.3 ⬜ Panel statystyk gracza
- Wyświetlanie: MMR, Wins, Losses, Win Rate %, Streak, Best Streak
- Odświeżanie po każdym meczu

### 6.4 ⬜ Widok rankingów
- Top 50 graczy (MMR, Wins, Streak)
- Filtrowanie per tryb (1v1, 2v2, ogólny)
- Paginacja
- Podświetlenie pozycji zalogowanego gracza

### 6.5 ⬜ Widok historii meczów
- Lista ostatnich N meczów gracza
- Tryb, wynik, MMR change, K/D, czas trwania
- Możliwość kliknięcia → szczegóły meczu

### 6.6 ⬜ Overlay w trakcie meczu
- Timer odliczający czas meczu
- Score board (kille na zespół / per gracz)
- Komunikaty: First Blood, Killing Spree, mecz się kończy za 30s

### 6.7 ⬜ Obsługa pakietów areny w kliencie
- Parsowanie nowych opcodes w kliencie (C++ OTClient lub Lua modules)
- Reakcja na `ARENA_MATCH_FOUND`, `ARENA_MATCH_UPDATE`, `ARENA_MATCH_RESULT`

### 6.8 ⬜ Grafiki i zasoby
- Ikony trybów areny (1v1, 2v2, FFA itd.)
- Tło okna areny
- Ikony statusu (w kolejce, w meczu)
- Dźwięki (opcjonalne): fanfara na wygraną, gong na start

---

## FAZA 7 — STRONA WWW (3-5 dni)

### 7.1 ⬜ Routing i struktura plików
```
html_copy/arena/
├── index.php          — główna strona areny (opis, aktualny sezon)
├── rankings.php       — rankingi globalne
├── player.php         — profil arenowy gracza
├── api.php            — JSON API dla klienta/AJAX
└── templates/
    ├── arena_layout.html.twig
    ├── rankings.html.twig
    └── player_profile.html.twig
```

### 7.2 ⬜ Strona rankingów (`rankings.php`)
- Query do `arena_players` JOIN `players` ORDER BY `mmr` DESC
- Filtrowanie: Ogólny / 1v1 / Team
- Paginacja (50 na stronę)
- Kolumny: Rank, Gracz, MMR, Wins, Losses, Win%, Streak

### 7.3 ⬜ Profil gracza (`player.php`)
- Statystyki gracza (MMR, W/L, K/D, total damage)
- Ostatnie mecze (query `arena_match_players` JOIN `arena_matches`)
- Wykres MMR w czasie (opcjonalnie — JS chart)

### 7.4 ⬜ API JSON (`api.php`)
- Endpoint: `/arena/api.php?action=rankings&page=1&mode=1v1`
- Endpoint: `/arena/api.php?action=player&name=PlayerName`
- Cache JSON co 5 minut (`cache/arena_rankings.json`)
- Używany przez klienta OTClient do wyświetlania rankingów

### 7.5 ⬜ Stylowanie (CSS)
- Spójne z resztą strony (MyAccount / highscores style)
- Responsywne tabele
- Podświetlenie Top3 (złoto, srebro, brąz)

---

## FAZA 8 — BEZPIECZEŃSTWO I ANTI-CHEAT (2-3 dni) ✅ GOTOWE

### 8.1 ✅ Reguły w trakcie meczu areny
- ✅ Blokada teleportów (spelle: Levitate, Magic Rope, Find Person + itemy teleportacyjne)
- ✅ Blokada logoutu (ostrzeżenie + force-lose po 60s AFK, reset przy akcji)
- ✅ Blokada używania itemów spoza areny (exercise weapons, teleport items)
- ✅ Blokada zapraszania do party graczy spoza meczu
- ✅ Gracz nie traci exp, przedmiotów, blokada skulli (return 0 ticks)
- Plik: `data/scripts/arena/arena_security.lua` (226 linii)
- 7 kluczy i18n: arena.security.*

### 8.2 ✅ Anti-boost / Anti-wintrading
- ✅ Śledzenie powtarzających się par graczy (max 3 mecze/dzień z tym samym przeciwnikiem dają MMR)
- ✅ Dzienne limity zysku MMR (max +200/dzień, konfigurowalne w config.lua)
- ✅ Walidacja: minimalny czas meczu (>30s) żeby mecz się liczył
- ✅ Flagowanie podejrzanych wzorców + alert GM po przekroczeniu progu
- ✅ Automatyczny cleanup danych co godzinę (GlobalEvent)
- Plik: `data/scripts/arena/arena_anticheat.lua` (239 linii)
- 4 klucze i18n: arena.anticheat.*

### 8.3 ✅ Logowanie
- ✅ Plik `logs/arena.log` — strukturowane logi z timestampem i poziomami (INFO/WARN/ERROR/SECURITY/METRIC)
- ✅ Logi: matchCreated, matchResult, queueJoin/Leave, disconnect, security, blockedAction, AFK
- ✅ Metryki: co 5 min zapis aktywnych meczy, graczy w kolejce, łącznych meczy
- ✅ Alerty GM na podejrzane działania (via ArenaAntiCheat.flagSuspicious)
- ✅ Logowanie akcji adminów (ArenaLog.logAdminAction)
- Plik: `data/scripts/arena/arena_logging.lua` (212 linii)
- 11 wpisów konfiguracyjnych w config.lua (arenaSystemEnabled, arenaMinLevel, etc.)

---

## FAZA 9 — SEZONY I NAGRODY (2-3 dni)

### 9.1 ⬜ System sezonów
- Sezon trwa np. 3 miesiące
- Na koniec sezonu: snapshot MMR → `arena_season_rankings`
- Soft reset MMR na nowy sezon: `newMMR = (oldMMR + 1000) / 2`

### 9.2 ⬜ Nagrody sezonowe
- Top 1: Unikatowy outfit + tytuł "Arena Champion" + mount
- Top 10: Outfit + tytuł "Arena Master"
- Top 100: Tytuł "Gladiator" + dekoracja do domu
- Top 1000: Tytuł "Arena Veteran"
- Automatyczne przyznanie po zakończeniu sezonu (skrypt Lua lub cron)

### 9.3 ⬜ Sklep za Arena Points
- Outfity (np. gladiator outfit)
- Mounty (np. war horse)
- Cosmetic efekty (np. aura)
- Dekoracje (trofea, flagi do domu)
- Consumables: buffy tylko do areny (np. +5% dmg w arenie)

---

## FAZA 10 — i18n / TŁUMACZENIA (1-2 dni) ✅ GOTOWE

### 10.1 ✅ Utworzenie pliku `i18n/en/arena.json`
- 181 kluczy tłumaczeń (commit: d1468edc4)
- Klucze: tryby, opisy, matchmaking, mecz (First Blood, Victory, Defeat), UI, NPC dialogi, błędy
- Konwencja kluczy: `arena.<kontekst>.<akcja>`, parametry: `{0}`, `{1}`

### 10.2 ✅ Tłumaczenie na polski (`i18n/pl/arena.json`)
- 181 kluczy z pełnymi polskimi tłumaczeniami
- Skopiowano EN fallback do 55 pozostałych lokalizacji

### 10.3 ✅ Podpięcie kluczy i18n w kodzie Lua
- Wszystkie 7 skryptów arena Lua przepisane na i18n:
  - `player:sendLocalizedTextMessage()` — wiadomości do gracza
  - `player:getTranslation()` — dynamiczne stringi (ranking, formatowanie)
  - `NPC_LIB.i18n.npcSay()` — dialogi NPC Arena Master
  - `NPC_LIB.i18n.setLocalizedMessage()` — greet/farewell/walkaway NPC
- Nowe helpery w ArenaConfig: `getTitleI18nKey()`, `getTranslatedTitle()`, `formatRecord(player, stats)`

---

## FAZA 11 — TESTY (3-5 dni) ✅ CZĘŚCIOWO

### 11.1 ✅ Testy jednostkowe C++
- ✅ Testy `arena_definitions.hpp`: arenaModeToString, stringToArenaMode, getRequiredPlayers, getMatchDuration, roundtrip, domyślne wartości structów
- ✅ Testy `ArenaMatchmaking`: addToQueue, removeFromQueue, isInQueue, getQueuedMode, getQueueSize, clear, duplikaty
- ✅ Testy matchmakingu 1v1: match 2 bliskich MMR, brak matchu przy dużej różnicy, brak matchu z 1 graczem
- ✅ Testy matchmakingu team: 2v2 (4 graczy), 3v3 (6 graczy), za mało graczy
- ✅ Testy FFA: minimum 4 graczy, izolacja trybów, wiele meczów naraz
- Pliki: `tests/unit/arena/arena_definitions_test.cpp`, `tests/unit/arena/arena_matchmaking_test.cpp`
- Zarejestrowano w `tests/unit/arena/CMakeLists.txt` + `tests/unit/CMakeLists.txt`

### 11.2 ⬜ Testy integracyjne
- Test pełnego flow: join queue → matchmaking → mecz → wynik → zapis DB
- Test protokołu: pakiety klient↔serwer poprawnie parsowane
- Test bazy: transakcje, rollbacki, spójność danych
- _Wymaga działającego serwera + bazy danych_

### 11.3 ✅ Testy manualne — Checklist
- ✅ Utworzono `docs/ARENA_TEST_CHECKLIST.md` (55 testów w 10 sekcjach)
- Sekcje: Queue, Matchmaking, Statistics, NPC, Security, Anti-Cheat, Admin, Shop, i18n, Edge Cases
- _Do wykonania na serwerze deweloperskim z 2+ klientami_

### 11.4 ⬜ Testy obciążeniowe
- Symulacja 100+ graczy w kolejkach jednocześnie
- Sprawdzenie wydajności ticka matchmakingu
- Monitoring RAM/CPU serwera podczas wielu meczów

### 11.5 ⬜ Balans i tuning
- Sprawdzenie czy MMR się stabilizuje (nie inflacja/deflacja)
- Czy matchmaking nie trwa za długo
- Czy czasy meczów są odpowiednie
- Dostosowanie nagród (nie za dużo, nie za mało)

---

## FAZA 12 — DOKUMENTACJA I DEPLOY (1-2 dni) ✅ GOTOWE

### 12.1 ✅ Dokumentacja techniczna
- ✅ `docs/API_ARENA.md` — pełna dokumentacja API:
  - Architektura systemu (diagram), komponenty
  - Protokół sieciowy: opcode 0xD0 (client→server), 0xDB (server→client), 7 sub-typów
  - C++ API: ArenaSystem (lifecycle, queue, combat hooks, stats), MMR formuła, matchmaking algorytm
  - Lua API: Arena global, Player methods, ArenaConfig
  - Schemat bazy danych (6 tabel)
  - Klucze i18n (193 kluczy, 13 namespaceów)
  - Konfiguracja (11 parametrów config.lua)
  - Struktura plików

### 12.2 ✅ Dokumentacja użytkownika
- ✅ `docs/ARENA_GM_GUIDE.md` — instrukcja dla GM:
  - 6 komend administracyjnych z przykładami
  - Monitorowanie i logi (poziomy, alerty)
  - Konfiguracja serwera (10 parametrów)
  - Troubleshooting (4 typowe problemy)
  - FAQ

### 12.3 ✅ Deploy checklist
- ✅ `docs/ARENA_DEPLOY_CHECKLIST.md` — 10-punktowa lista:
  - Pre-deploy: kompilacja, migracja DB, pliki Lua, i18n, konfiguracja, mapa
  - Deploy: zatrzymanie/uruchomienie serwera
  - Post-deploy: smoke test (GM komendy, mecz 1v1, logi)
  - Rollback plan
  - Monitoring po deploy

### 12.4 ✅ Merge do master
- Wszystkie zmiany areny są już na master (PtakuPL/ooo)
- Commity: fazy 0-5 (89b305974), i18n (d1468edc4), Phase 8+fixes (e1b50d55b)

---

## 📊 PODSUMOWANIE ESTYMACJI

| Faza | Opis | Estymacja |
|------|------|-----------|
| 0 | Przygotowanie | 2-3 dni |
| 1 | Baza danych | 1-2 dni |
| 2 | Core C++ | 7-14 dni |
| 3 | Matchmaking | 3-5 dni |
| 4 | Protokół sieciowy | 3-5 dni |
| 5 | Skrypty Lua | 5-7 dni |
| 6 | UI klienta | 7-14 dni |
| 7 | WWW | 3-5 dni |
| 8 | Bezpieczeństwo ✅ | 2-3 dni |
| 9 | Sezony i nagrody | 2-3 dni |
| 10 | i18n | 1-2 dni |
| 11 | Testy ✅ (częściowo) | 3-5 dni |
| 12 | Dokumentacja + deploy ✅ | 1-2 dni |
| **RAZEM** | | **~40-70 dni roboczych** |

---

## 🔑 KOLEJNOŚĆ PRIORYTETÓW (co robić najpierw)

1. **Faza 0+1** — Przygotowanie + Baza danych (bez tego nic nie ruszy)
2. **Faza 2** — Core C++ (serce systemu)
3. **Faza 3** — Matchmaking (bez tego nie ma automatycznego dobierania)
4. **Faza 5** — Lua skrypty (tryby gry, NPC, nagrody)
5. **Faza 4** — Protokół sieciowy (komunikacja klient↔serwer)
6. **Faza 6** — UI klienta (żeby gracze mogli używać systemu wygodnie)
7. **Faza 8** — Anti-cheat (zanim system wyjdzie publicznie)
8. **Faza 7** — WWW rankingi (ładne, ale nie krytyczne na start)
9. **Faza 9** — Sezony i nagrody (po stablilizacji systemu)
10. **Faza 10+11+12** — i18n, testy, deploy

---

## ⚠️ ZALEŻNOŚCI KRYTYCZNE

```
Faza 1 (DB)  ──→  Faza 2 (C++)  ──→  Faza 3 (Matchmaking)
                       │                      │
                       ▼                      ▼
                  Faza 5 (Lua)          Faza 4 (Protokół)
                       │                      │
                       ▼                      ▼
                  Faza 9 (Nagrody)      Faza 6 (Klient UI)
                                              │
                                              ▼
                                        Faza 7 (WWW)
                                              │
                                              ▼
                                    Faza 8, 10, 11, 12
```

- **Faza 2 wymaga Fazy 1** — C++ musi wiedzieć o tabelach DB
- **Faza 3 wymaga Fazy 2** — matchmaking używa ArenaSystem
- **Faza 4 wymaga Fazy 2** — protokół wywołuje metody ArenaSystem  
- **Faza 5 wymaga Fazy 2** — Lua bindings do C++ ArenaSystem
- **Faza 6 wymaga Fazy 4** — klient używa opcodes areny
- **Faza 7 wymaga Fazy 1** — WWW czyta z DB areny
- **Fazy 8-12** mogą iść równolegle po Fazie 6

---

## 💡 MINIMALNA WERSJA MVP (na szybki start)

Jeśli chcesz mieć działającą arenę **jak najszybciej**, to MVP to:

1. ✅ Tabele DB (Faza 1)
2. ✅ Prosty ArenaSystem C++ — tylko 1v1, bez matchmakingu (Faza 2 minimum)
3. ✅ Komenda `/arena join` i `/arena leave` w Lua (Faza 5 minimum)
4. ✅ Teleport na arenę, timer, wynik oparty o kill (Faza 5)
5. ✅ Zapis do DB po meczu (Faza 2)
6. ✅ NPC do sprawdzania statystyk (Faza 5)

**Estymacja MVP: ~2-3 tygodnie**

Reszta (matchmaking, UI, WWW, sezony) dochodzi iteracyjnie.
