# Plan Aren PvP (1v1, 2v2, Guild War) – Canary/OTClient (wersja robocza)
Data: 2026-02-18 (Europe/Warsaw)

## 0. Cel dokumentu
Ten plik jest **jednym spójnym planem** wdrożenia aren PvP: **1v1, 2v2 oraz walk gildyjnych (Guild War)**.
Plan zakłada:
- minimalny **MVP** (szybkie uruchomienie i testy),
- architekturę, która pozwala później rozbudować system o frakcje, capture points, głosowania map itd.,
- **wysoką wydajność** (kolejkowanie i mecze w RAM) oraz **odporność na crash** (START/END w MySQL),
- spójny podział obowiązków: **C++ (rdzeń), Lua (reguły), MySQL (trwałe dane), WWW (rankingi), opcjonalnie klient (UX/PRO)**.

---

## 1. Założenia i priorytety
### 1.1 Co robimy najpierw (MVP)
1) Areny **1v1** i **2v2**:
- kolejki per tryb,
- dobieranie przeciwników (MMR + fallback),
- start meczu, przebieg, koniec, nagrody/rating,
- brak strat itemów (lub kontrolowana polityka – decyzja w Lua).

2) **Guild War** jako wariant tego samego systemu (ten sam rdzeń):
- kolejka / wyzwania gildii,
- instancja meczu gildyjnego,
- ranking gildii.

### 1.2 Co świadomie odkładamy (rozszerzenia)
- frakcje i przejmowanie punktów,
- głosowanie mapy/trybu w UI klienta,
- „snapshot eq i wirtualny ekwipunek arenowy” (możliwe później, ryzykowne bez twardej transakcyjności).

---

## 2. Architektura wysokiego poziomu
### 2.1 Podział odpowiedzialności
**C++ (Serwer / Canary Core)**
- kolejki i matchmaking w RAM (wydajność),
- rezerwacje slotów aren (TTL),
- stan meczów (state machine),
- obsługa eventów (death/logout/think),
- integracja z MySQL: zapis START/END + aktualizacja ratingów.

**Lua (Reguły gry / konfiguracja)**
- konfiguracje trybów (limity, mapy, zasady),
- polityka bonusów (underdog), ranked/unranked,
- warunki wygranej (kill limit, time limit, surrender),
- NPC/komendy do join/leave/status,
- rotacje map i opcjonalne preferencje aren.

**MySQL (Trwałe dane / recovery / rankingi)**
- zapis meczu START i END,
- historia meczów i uczestników,
- rating/MMR/ELO,
- sezony i rankingi.

**Strona WWW**
- rankingi per tryb i globalne (z kilku serwerów),
- profile graczy/gildii (historia meczów),
- sezonowe podsumowania i statystyki.

**Klient (opcjonalnie – „PRO/UX”)**
- UI do join/queue status, głosowania map, HUD areny,
- onboarding/hinty,
- (oddzielny temat) pełna internacjonalizacja i auto-layout UI.

---

## 3. Rdzeń aren w C++ (Arena Core)
### 3.1 Kluczowe koncepcje
**State machine meczu**
- `QUEUE -> READY -> STARTING -> RUNNING -> FINISHED -> CLEANUP`

**Tryby**
- `Duel1v1`, `Team2v2`, `GuildWar`

**Główne struktury (w RAM)**
- `QueueEntry` (wpis gracza w kolejce konkretnego trybu)
- `PlayerQueueState` (indeks globalny per gracz)
- `Reservation` (rezerwacja miejsca w slocie areny z TTL)
- `ArenaSlot` (slot instancji meczu, wolny/zarezerwowany/trwający)
- `ArenaMatch` (stan meczu, drużyny, kill count, timery)

### 3.2 Zasady kolejek (ustalone)
- **Osobne kolejki per tryb** (1v1, 2v2, Guild).
- Gracz może być w wielu kolejkach, ale:
  - może mieć **tylko jedną aktywną rezerwację** naraz,
  - jeśli jest `IN_MATCH`, jego wpisy w kolejkach mogą zostać:
    - **zachowane**, ale gracz jest **pomijany** przy doborze, aż wróci do `IDLE`,
    - lub w polityce Lua mogą być czasowo „zawieszone” (nie usuwane).

### 3.3 Rezerwacje i „wpuszczanie, gdy ktoś wyjdzie”
Mechanizm:
1) Slot areny robi się `FREE`.
2) Matchmaker wybiera kandydatów z kolejki.
3) Tworzy `Reservation` (TTL np. 20–30s).
4) Jeśli gracze są dostępni (`IDLE`, online, bez locka), rezerwacja jest `CONFIRMED` i startuje mecz.
5) Jeśli rezerwacja wygaśnie albo gracz nie jest dostępny, wybierany jest kolejny kandydat.

To rozwiązuje:
- „gracz jest #1 w kolejce, ale gra w innym meczu”,
- „ktoś wyszedł z areny – slot natychmiast się uzupełnia”.

### 3.4 Matchmaking (MMR + fallback)
**Model okna MMR**
- start zakresu: np. ±50 MMR
- rozszerzanie co czas w kolejce: np. +25 co 10s
- po dłuższym oczekiwaniu: fallback do „open match” (unranked albo ranked z ograniczeniami)

**Bonus dla słabszego**
Preferowane formy (bezpieczne anty-nadużyciowo):
- bonus nagród/pointów,
- mniejsza kara MMR przy porażce,
- większa nagroda MMR przy wygranej.
Bonusy statowe (HP/dmg) tylko w unranked i bardzo ostrożnie.

### 3.5 Obsługa edge-case
- `onLogout`: grace period (np. 30s) lub walkower wg reguł Lua.
- teleport poza arenę / wyjście: traktowane jako porażka / karne opuszczenie (konfigurowalne).
- crash serwera: recovery z MySQL (patrz sekcja 5).

---

## 4. Lua – reguły i konfiguracja
### 4.1 Co Lua definiuje
- parametry trybów:
  - `timeLimitSec`, `killLimit`, `isRanked`, `noItemLoss`, `allowPotions`, itp.
- map pool:
  - lista map/aren per tryb,
  - rotacja (pseudolos / kolejność),
  - preferencje aren (opcjonalnie).
- polityka MMR:
  - początkowe okno, tempo rozszerzania,
  - fallback time,
  - zasady underdoga.
- zasady kar:
  - opuszczenie meczu,
  - disconnect,
  - cooldown na ponowne queue.
- komendy i NPC:
  - join/leave/status,
  - teleporter „Arena Master”,
  - (opcjonalnie) tablice wyników / posągi.

### 4.2 Interfejs Lua -> C++ (minimalny)
C++ udostępnia prymitywy:
- `QueueJoin(playerId, mode, options)`
- `QueueLeave(playerId, mode)`
- `QueueStatus(playerId)`
- `RegisterArenaSlot(mode, arenaId, capacity, tags)`
- `NotifySlotFreed(arenaId, slotId)`
- `TryFillSlot(slotId)` (matchmaker)
- `GetPlayerArenaState(playerId)` / `GetPlayerLock(playerId)`
- `SetPlayerLock(playerId, lockMask)`
- `ConfirmReservation(resId)` / `CancelReservation(resId)`

Lua wywołuje te funkcje i buduje politykę.

---

## 5. MySQL – zapis START/END i recovery po craszu
### 5.1 Dlaczego START i END do MySQL
- po craszu serwer „wie na 100%”, że mecz wystartował,
- zna listę graczy (do bezpiecznego przywrócenia),
- może oznaczyć mecze niedomknięte jako `aborted`.

### 5.2 Polityka zapisu (optymalna)
**START (lekki zapis, jedna transakcja)**
- `arena_matches`: wpis startowy (`state='running'`, `started_at`, `server_id`, `mode`, `map_id`)
- `arena_match_players`: lista uczestników + teamy + `mmr_before` (opcjonalnie)

**END (pełny zapis, jedna transakcja)**
- domknięcie `arena_matches` (`ended_at`, `winner_team`, `state='finished'`, killcount, meta)
- uzupełnienie `arena_match_players` (kille/deathy/assist itd.)
- aktualizacja `arena_ratings` (mmr_after, wins/losses)

**Opcjonalnie heartbeat** co 30–60s:
- `last_heartbeat_at` w `arena_matches` (pomocne diagnostycznie).

### 5.3 Recovery po starcie serwera
Zalecenie:
- areny aktywne dopiero po **3–5 minutach** od startu serwera (okno stabilizacji).

Procedura:
1) `arenas_enabled=false`
2) Query: mecze `state='running'` dla `server_id` z ostatnich np. 10 min.
3) Dla każdego:
   - pobierz graczy,
   - jeśli gracz online: teleport do bezpiecznej strefy + czyszczenie flag aren,
   - oznacz mecz jako `aborted`, ustaw `ended_at=NOW()`.
4) `arenas_enabled=true`

To realizuje wymóg „2–3 min od startu aren” na przywrócenie bezpieczeństwa.

### 5.4 Czy rozbijać na .json -> MySQL?
- ma sens tylko, jeśli MySQL bywa niedostępny, albo chcesz „czarną skrzynkę”.
- rekomendacja: jeśli chcesz backup, użyć prostego **WAL append-only** (MATCH_START/MATCH_END/RATING_UPDATE) jako opcjonalnego kanału awaryjnego, a główny tor trzymać w MySQL.

---

## 6. Schemat danych MySQL (minimalny)
Poniżej minimalny zestaw tabel (docelowo do uzupełnienia o konkretne pola zależne od Twojego modelu ID gracza).

### 6.1 `arena_ratings`
- `player_id`
- `mode`
- `mmr`
- `games`, `wins`, `losses`, `streak`
- `season_id` (opcjonalnie)
- `updated_at`
Indeksy:
- UNIQUE (`player_id`, `mode`, `season_id?`)
- INDEX (`mode`, `mmr` DESC)

### 6.2 `arena_matches`
- `match_id`
- `server_id`
- `mode`
- `map_id`
- `state` (`running/finished/aborted`)
- `started_at`, `ended_at`
- `winner_team`
- `team1_kills`, `team2_kills`
- `is_ranked`
- `meta_json` (opcjonalnie)
Indeksy:
- (`server_id`, `started_at` DESC)
- (`mode`, `started_at` DESC)
- (`state`, `started_at` DESC)

### 6.3 `arena_match_players`
- `match_id`
- `player_id`
- `team_id`
- `kills`, `deaths`, `assists` (opcjonalnie)
- `damage_done`, `healing_done` (opcjonalnie)
- `mmr_before`, `mmr_after`
- `result` (`W/L/D`)
Indeksy:
- (`player_id`, `match_id`)
- (`match_id`)

### 6.4 `arena_seasons` (zalecane)
- `season_id`
- `mode`
- `starts_at`, `ends_at`
- `ruleset_version`
- `is_active`

---

## 7. Strona WWW (rankingi i profile)
### 7.1 Widoki rankingów
- 1v1: Top MMR, Top Winrate, Top Streak
- 2v2: analogicznie (z parą / teamem – decyzja: ranking per gracz czy per team)
- Guild War: ranking gildii (MMR gildyjny, W/L, sezony)

### 7.2 Profile gracza/gildii
- historia meczów (ostatnie N),
- statystyki sezonowe,
- wykresy (opcjonalnie).

### 7.3 Globalne rankingi multi-serwer
- wspólna DB lub agregacja po `server_id`,
- filtry: global / per serwer.

---

## 8. Klient (opcjonalnie – wersja profesjonalna)
To NIE jest wymagane do działania aren (serwer wystarczy), ale poprawia UX:
- okno kolejki: pozycja, ETA, tryb, przycisk leave,
- okno głosowania mapy/trybu (później),
- HUD areny (status, timer, wynik),
- onboarding/hint (np. nowa opcja „Rozmawiaj” z battle list – analogicznie można dodać hinty aren).

---

## 9. Bezpieczeństwo i anty-nadużycia (zalecenia)
- blokada multi-rezerwacji,
- cooldown na opuszczenie meczu (leave penalty),
- wykrywanie farmienia MMR (powtarzalne parowania, alt accounts) – na poziomie WWW/DB analityka,
- logowanie kluczowych zdarzeń (START/END, disconnects, penalties).

---

## 10. Roadmap (proponowana kolejność prac)
1) C++: struktury RAM + kolejka per tryb + rezerwacje TTL + sloty
2) C++: match lifecycle (start/run/end/cleanup) + event hooks (death/logout/think)
3) MySQL: START/END + tabele minimalne + recovery po starcie serwera (3–5 min)
4) Lua: konfiguracje trybów + polityka MMR + komendy/NPC
5) WWW: rankingi 1v1 i 2v2 (pierwsza wersja)
6) Guild War: tryb oparty na tym samym rdzeniu
7) Rozszerzenia: sezony, kary, anti-abuse, profesjonalny UX w kliencie

---

## 11. Otwarte decyzje do uzupełnienia (do kolejnych iteracji)
- identyfikator gracza w DB: `account_id` vs `player_id` (globalne ID w sieci),
- ranking 2v2: per gracz czy per stały team,
- polityka disconnect: grace period vs natychmiastowa porażka,
- ranked/unranked split i bonusy underdoga,
- czy i kiedy wchodzi „snapshot/wirtualny ekwipunek” (osobny etap).

