# 🏟️ Arena System - Plan Implementacji

> **Status:** 📋 PLANOWANE  
> **Priorytet:** Na później (po i18n)  
> **Autor:** Agent 2  
> **Data:** 2025-12-11

---

## 📋 Opis Systemu

System areny z automatycznym dobieraniem przeciwników (matchmaking), wieloma trybami walki i topkami wyświetlanymi w grze oraz na stronie WWW.

**Interfejs:** Menu podobne do Market - okno z opcjami wyboru trybu areny.

---

## 🎮 Tryby Walki (6-8)

| # | Tryb | Opis | Gracze | Czas |
|---|------|------|--------|------|
| 1 | **1v1 Duel** | Klasyczny pojedynek | 2 | 5 min |
| 2 | **2v2 Team** | Drużynowa walka | 4 | 7 min |
| 3 | **3v3 Team** | Większe drużyny | 6 | 10 min |
| 4 | **FFA (Free For All)** | Każdy na każdego | 4-8 | 5 min |
| 5 | **Capture The Flag** | Zdobądź flagę | 6 (3v3) | 10 min |
| 6 | **King of the Hill** | Utrzymaj punkt | 4-6 | 8 min |
| 7 | **Last Man Standing** | Ostatni wygrywa | 8-16 | 15 min |
| 8 | **Tournament** | Bracket 1v1/2v2 | 8-32 | event |

---

## 🔄 Matchmaking System

### Algorytm dobierania:
```
┌─────────────────────────────────────────────────────────────────┐
│                    MATCHMAKING ENGINE                           │
├─────────────────────────────────────────────────────────────────┤
│ 1. Gracz wchodzi do kolejki (wybiera tryb)                     │
│ 2. System oblicza MMR gracza                                    │
│ 3. Szuka przeciwników w zakresie MMR ±100                       │
│ 4. Po 30s rozszerza zakres do ±200                              │
│ 5. Po 60s rozszerza do ±500                                     │
│ 6. Po 120s dopasowuje kogokolwiek                               │
├─────────────────────────────────────────────────────────────────┤
│ MMR = Base(1000) + Wins×25 - Losses×20 + Streak×5              │
└─────────────────────────────────────────────────────────────────┘
```

### Czynniki MMR:
- **Level** - bazowy wpływ
- **Vocation** - balans klas
- **Equipment Score** - siła ekwipunku
- **Win/Loss Ratio** - historia walk
- **Streak Bonus** - seria zwycięstw

---

## 🏆 System Topek

### Kategorie rankingów:

| Topka | Opis | Wyświetlanie |
|-------|------|--------------|
| **Top MMR** | Najwyższy rating | Serwer + WWW |
| **Top Wins** | Najwięcej zwycięstw | Serwer + WWW |
| **Top Win Streak** | Najdłuższa seria | Serwer + WWW |
| **Top K/D Ratio** | Najlepszy stosunek | WWW |
| **Top Damage** | Najwięcej obrażeń | WWW |
| **Top Healer** | Najwięcej leczenia | WWW (druidy) |
| **Weekly Champion** | Tygodniowy mistrz | Serwer + WWW |
| **Monthly Champion** | Miesięczny mistrz | Serwer + WWW |

### Wyświetlanie w grze:
```lua
-- Komenda /arena top
-- NPC "Arena Master" z dialogiem
-- Panel w menu areny
```

### Wyświetlanie na WWW:
```
/arena/rankings       - Główna strona rankingów
/arena/rankings/1v1   - Top 1v1
/arena/rankings/team  - Top drużynowe
/arena/player/{name}  - Profil gracza
```

---

## 🗃️ Struktura Bazy Danych

### Tabele SQL:

```sql
-- Główna tabela graczy areny
CREATE TABLE arena_players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    mmr INT DEFAULT 1000,
    wins INT DEFAULT 0,
    losses INT DEFAULT 0,
    draws INT DEFAULT 0,
    win_streak INT DEFAULT 0,
    best_streak INT DEFAULT 0,
    total_damage BIGINT DEFAULT 0,
    total_healing BIGINT DEFAULT 0,
    total_kills INT DEFAULT 0,
    total_deaths INT DEFAULT 0,
    last_match DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

-- Historia meczy
CREATE TABLE arena_matches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mode ENUM('1v1','2v2','3v3','ffa','ctf','koth','lms','tournament'),
    started_at DATETIME,
    ended_at DATETIME,
    duration INT,
    winner_team INT,
    map_id INT
);

-- Uczestnicy meczy
CREATE TABLE arena_match_players (
    match_id INT,
    player_id INT,
    team INT,
    kills INT DEFAULT 0,
    deaths INT DEFAULT 0,
    damage_dealt BIGINT DEFAULT 0,
    healing_done BIGINT DEFAULT 0,
    mmr_change INT,
    PRIMARY KEY (match_id, player_id)
);

-- Kolejka matchmakingu
CREATE TABLE arena_queue (
    player_id INT PRIMARY KEY,
    mode VARCHAR(20),
    mmr INT,
    queued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expanded_range INT DEFAULT 0
);

-- Sezony
CREATE TABLE arena_seasons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT FALSE
);

-- Rankingi sezonowe
CREATE TABLE arena_season_rankings (
    season_id INT,
    player_id INT,
    final_mmr INT,
    final_rank INT,
    rewards_claimed BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (season_id, player_id)
);
```

---

## 📁 Struktura Plików

```
data/
├── scripts/
│   └── arena/
│       ├── arena_main.lua           # Główny system
│       ├── arena_matchmaking.lua    # Matchmaking
│       ├── arena_combat.lua         # Walka w arenie
│       ├── arena_rewards.lua        # Nagrody
│       └── modes/
│           ├── duel_1v1.lua
│           ├── team_2v2.lua
│           ├── team_3v3.lua
│           ├── ffa.lua
│           ├── ctf.lua
│           ├── koth.lua
│           ├── lms.lua
│           └── tournament.lua
│
├── npc/
│   └── arena_master.lua             # NPC Arena Master
│
└── XML/
    └── arena/
        ├── arena_maps.xml           # Mapy aren
        └── arena_rewards.xml        # Nagrody

src/
├── game/
│   └── arena/
│       ├── arena_system.cpp         # C++ core
│       ├── arena_system.hpp
│       ├── arena_matchmaking.cpp
│       └── arena_matchmaking.hpp
│
└── server/
    └── network/
        └── protocolgame_arena.cpp   # Pakiety sieciowe

html_copy/                           # Strona WWW
├── arena/
│   ├── index.php                    # Główna strona areny
│   ├── rankings.php                 # Rankingi
│   ├── queue.php                    # Status kolejki
│   └── templates/
│       ├── arena.html.twig
│       └── rankings.html.twig
```

---

## 🎨 UI/UX - Menu Areny

```
┌─────────────────────────────────────────────────────────────────┐
│                      ⚔️ ARENA MENU                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [🎯 1v1 Duel]     [👥 2v2 Team]     [👥 3v3 Team]             │
│                                                                  │
│  [💀 FFA]          [🚩 CTF]          [👑 King of Hill]         │
│                                                                  │
│  [🏆 Last Man]     [🎪 Tournament]                              │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  📊 Your Stats:                                                  │
│  MMR: 1250 | Wins: 45 | Losses: 32 | Streak: 3                  │
├─────────────────────────────────────────────────────────────────┤
│  [📋 Rankings]  [📜 History]  [🎁 Rewards]  [❌ Close]          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎁 System Nagród

### Nagrody za walkę:
| Wynik | Nagroda |
|-------|---------|
| Zwycięstwo | +25 Arena Points, +25 MMR |
| Porażka | +5 Arena Points, -20 MMR |
| MVP | +10 bonus Arena Points |
| First Blood | +5 bonus |
| Killing Spree | +3 per kill |

### Sklep Arena:
- Kosmetyki (outfity, mounts, efekty)
- Tytuły (np. "Gladiator", "Champion")
- Dekoracje (trofea do domu)
- Consumables (buffs tylko do areny)

### Nagrody sezonowe:
- Top 1: Unikatowy outfit + tytuł + mount
- Top 10: Outfit + tytuł
- Top 100: Tytuł + dekoracja
- Top 1000: Tytuł

---

## 🗓️ Plan Implementacji

### Faza 1: Core (2-3 tygodnie)
- [ ] Baza danych (tabele)
- [ ] Podstawowy system C++
- [ ] 1v1 Duel mode
- [ ] Podstawowe UI

### Faza 2: Matchmaking (1-2 tygodnie)
- [ ] Algorytm MMR
- [ ] Kolejka matchmakingu
- [ ] Auto-balance drużyn

### Faza 3: Tryby (2-3 tygodnie)
- [ ] 2v2, 3v3 Team
- [ ] FFA
- [ ] CTF, KotH
- [ ] Last Man Standing

### Faza 4: Rankings & WWW (1-2 tygodnie)
- [ ] Topki w grze
- [ ] Strona WWW rankings
- [ ] API dla statystyk

### Faza 5: Polish (1 tydzień)
- [ ] Nagrody i sklep
- [ ] Balans
- [ ] Testy
- [ ] i18n (tłumaczenia)

---

## 📝 Notatki

- System musi być **fair** - brak P2W
- Matchmaking musi być **szybki** - max 2 min czekania
- Topki muszą być **aktualizowane na żywo**
- Trzeba przemyśleć **anti-cheat** i **anti-boost**
- Rozważyć **sezony** z resetem MMR

---

## 🔗 Powiązania

- `i18n/en/arena.json` - Tłumaczenia (do dodania po implementacji)
- `docs/API_ARENA.md` - Dokumentacja API (do napisania)
- `tests/arena/` - Testy jednostkowe

