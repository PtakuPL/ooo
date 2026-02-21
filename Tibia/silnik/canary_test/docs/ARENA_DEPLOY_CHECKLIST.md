# Arena PvP — Deploy Checklist (Pre-Alpha)

> **Wersja:** Pre-Alpha 1.0  
> **Data:** 2026-02-21

---

## Pre-Deploy

### 1. Kompilacja
- [ ] Upewnij się, że branch `master` jest aktualny (`git pull origin master`)
- [ ] Kompilacja C++ przeszła bez błędów (`cmake --build . --config Release`)
- [ ] Testy jednostkowe przeszły (`ctest --output-on-failure`)

### 2. Baza danych
- [ ] Wykonaj migrację SQL na bazie docelowej:
  ```bash
  mysql -u root -p canary < schema.sql
  ```
  Lub uruchom tylko arena-specyficzne tabele (jeśli baza już istnieje):
  ```sql
  -- Sprawdź czy tabele istnieją:
  SHOW TABLES LIKE 'arena_%';
  
  -- Jeśli nie — utwórz (patrz schema.sql sekcja arena)
  ```
- [ ] Zweryfikuj: `SELECT COUNT(*) FROM arena_players;` → powinno dać 0

### 3. Pliki Lua
- [ ] Skopiuj/zgituj pliki Lua na serwer:
  ```
  data/libs/systems/arena.lua
  data/scripts/arena/arena_main.lua
  data/scripts/arena/arena_security.lua
  data/scripts/arena/arena_anticheat.lua
  data/scripts/arena/arena_logging.lua
  data/scripts/talkactions/player/arena.lua
  data/scripts/talkactions/player/arena_rewards.lua
  data/scripts/talkactions/gm/arena_admin.lua
  data/scripts/eventcallbacks/player/arena_on_death.lua
  data-otservbr-global/npc/arena_master.lua
  ```

### 4. Tłumaczenia (i18n)
- [ ] Skopiuj pliki `i18n/*/arena.json` (57 plików)
- [ ] Zweryfikuj: `ls i18n/en/arena.json i18n/pl/arena.json`

### 5. Konfiguracja
- [ ] Dodaj wpisy areny do `config.lua` (jeśli nie ma):
  ```lua
  arenaSystemEnabled = true
  arenaMinLevel = 50
  arenaJoinCooldownSeconds = 30
  arenaMatchMaxDuration = 600
  arenaAfkTimeoutSeconds = 60
  arenaDailyMaxMMRGain = 200
  arenaMaxSameOpponentDaily = 3
  arenaMinMatchDuration = 30
  arenaAntiBoostEnabled = true
  arenaLogEnabled = true
  ```

### 6. Mapa
- [ ] Upewnij się, że pozycje teleportacji areny istnieją na mapie
- [ ] NPC Arena Master ma spawnpoint zdefiniowany w mapie/NPC data

---

## Deploy

### 7. Wykonanie
- [ ] Zatrzymaj serwer: `./stop.sh` lub `kill $(cat server.pid)`
- [ ] Podmień binarki (skompilowany canary)
- [ ] Uruchom serwer: `./start.sh`
- [ ] Sprawdź logi startu: `tail -f output.log | grep -i arena`
  - Powinno być: `[Arena] System initialized`

---

## Post-Deploy (Smoke Test)

### 8. Weryfikacja podstawowa
- [ ] Zaloguj się jako GM
- [ ] `!arena-admin stats` → System odpowiada (0 active matches, 0 queued)
- [ ] NPC Arena Master reaguje na rozmowę

### 9. Test meczu (wymaga 2 klientów)
- [ ] Gracz A: `!arena join 1v1`
- [ ] Gracz B: `!arena join 1v1`
- [ ] Mecz się tworzy, gracze teleportowani
- [ ] Po zakończeniu — statystyki w DB: `SELECT * FROM arena_matches ORDER BY id DESC LIMIT 1;`

### 10. Sprawdzenie logów
- [ ] `tail -20 logs/arena.log` → Wpisy o meczu widoczne
- [ ] Brak wpisów ERROR

---

## Rollback Plan

Jeśli arena powoduje problemy:

1. Zmień w `config.lua`: `arenaSystemEnabled = false`
2. Restart serwera
3. Arena wyłączona — reszta serwera działa normalnie
4. Tabele DB zostają (dane nie giną)

---

## Monitoring po deploy

- [ ] Sprawdzaj `logs/arena.log` codziennie przez pierwszy tydzień
- [ ] Monitoruj RAM/CPU serwera (arena nie powinna dodawać >5% obciążenia)
- [ ] Zbieraj feedback od testerów
- [ ] Zwracaj uwagę na wpisy SECURITY (próby exploitów)

---

*Dokument wygenerowany: 2026-02-21*
