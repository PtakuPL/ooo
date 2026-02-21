# Arena PvP — Instrukcja dla GM / Administratora

> **Wersja:** Pre-Alpha 1.0  
> **Data:** 2026-02-21

---

## Komendy administracyjne

Wszystkie komendy wymagają uprawnień Game Mastera (group ≥ 3).

### `!arena-admin info <nazwa_gracza>`

Wyświetla kompletne informacje o graczu w systemie areny:
- Aktualny stan (IDLE / IN_QUEUE / IN_MATCH)
- MMR, W/L/D, seria zwycięstw
- Arena Points
- KDR (Kill/Death Ratio)

**Przykład:**
```
!arena-admin info Ptaku
→ [Arena] Info: Ptaku | MMR: 1250 | Record: 15-8-2 | Win Rate: 60% | ...
```

### `!arena-admin stats`

Statystyki systemowe:
- Liczba aktywnych meczów
- Rozmiary kolejek wg trybów
- Łączna liczba graczy w systemie

### `!arena-admin setmmr <nazwa_gracza> <wartość>`

Ręcznie ustawia MMR gracza. Przydatne do testowania matchmakingu.

**Przykład:**
```
!arena-admin setmmr Ptaku 1500
→ [Arena] MMR gracza Ptaku ustawione na 1500
```

### `!arena-admin addpoints <nazwa_gracza> <ilość>`

Dodaje Arena Points graczowi. Punkty ujemne odejmują.

**Przykład:**
```
!arena-admin addpoints Ptaku 100
→ [Arena] Dodano 100 punktów areny graczowi Ptaku
```

### `!arena-admin reset <nazwa_gracza>`

Resetuje WSZYSTKIE statystyki areny gracza:
- MMR wraca do 1000
- W/L/D zerowane
- Punkty zerowane
- Historia zostaje w bazie

**UWAGA:** To jest nieodwracalne!

### `!arena-admin broadcast <wiadomość>`

Wysyła wiadomość do WSZYSTKICH graczy aktualnie w arenie (w kolejkach lub w meczach).

**Przykład:**
```
!arena-admin broadcast Serwer areny zostanie zrestartowany za 5 minut!
```

---

## Monitorowanie i logi

### Plik logów: `logs/arena.log`

Każdy wpis zawiera:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

Poziomy logowania:
| Poziom | Opis |
|---|---|
| `INFO` | Normalne zdarzenia (join, leave, match result) |
| `WARN` | Ostrzeżenia (AFK, podejrzane wzorce) |
| `ERROR` | Błędy systemu |
| `SECURITY` | Zdarzenia bezpieczeństwa (zablokowane akcje, próby exploitów) |
| `METRIC` | Metryki wydajności (co 5 min) |

### Alerty GM

System automatycznie wysyła alert do online GM-ów gdy:
- Gracz zostanie oflagowany jako podejrzany (np. wintrading)
- Gracz próbuje wielokrotnie obejść zabezpieczenia
- Wykryto anomalię w wynikach meczu

Format alertu:
```
[Arena SECURITY] Suspicious player: <nazwa> - <powód>
```

---

## Konfiguracja serwera

Parametry w `config.lua`:

| Parametr | Domyślnie | Opis |
|---|---|---|
| `arenaSystemEnabled` | `true` | Włącz/wyłącz cały system |
| `arenaMinLevel` | `50` | Minimalny poziom do gry |
| `arenaJoinCooldownSeconds` | `30` | Cooldown między dołączeniami |
| `arenaMatchMaxDuration` | `600` | Max czas meczu (10 min) |
| `arenaAfkTimeoutSeconds` | `60` | AFK = przegrana po 60s |
| `arenaDailyMaxMMRGain` | `200` | Max dzienny zysk MMR |
| `arenaMaxSameOpponentDaily` | `3` | Max meczy z tym samym graczem/dzień |
| `arenaMinMatchDuration` | `30` | Min czas meczu żeby się liczył |
| `arenaAntiBoostEnabled` | `true` | Włącz anti-wintrading |
| `arenaLogEnabled` | `true` | Włącz logowanie |

### Wyłączenie areny na żywo

Zmień w `config.lua`:
```lua
arenaSystemEnabled = false
```
Po restarcie serwera arena będzie wyłączona. Gracze nie mogą dołączać do kolejek.

---

## Troubleshooting

### Problem: Gracz utknął w stanie IN_MATCH

1. Sprawdź: `!arena-admin info <nazwa>`
2. Jeśli stan to IN_MATCH ale mecz nie istnieje:
   - Restart serwera wyczyści stany in-memory
   - Lub ręcznie: `!arena-admin reset <nazwa>` (uwaga: resetuje statystyki)

### Problem: Matchmaking nie działa

1. Sprawdź logi: `tail -f logs/arena.log | grep MATCH`
2. Upewnij się, że co najmniej 2 graczy jest w kolejce tego samego trybu
3. Sprawdź różnicę MMR — na starcie range to ±100, poszerza się z czasem

### Problem: Gracz nie może dołączyć do areny

Możliwe przyczyny:
- Level < `arenaMinLevel` (50)
- Już w kolejce lub w meczu
- Arena wyłączona (`arenaSystemEnabled = false`)
- Cooldown po ostatnim wyjściu z kolejki

### Problem: Podejrzany wzorzec gry

1. Sprawdź logi: `grep SECURITY logs/arena.log`
2. `!arena-admin info <podejrzany>` — sprawdź statystyki
3. Jeśli wintrading potwierdzony: `!arena-admin reset` dla obu graczy

---

## FAQ

**P: Czy mogę zmienić nagrody za wygraną?**
O: Tak, edytuj `ArenaConfig.rewards` w `data/libs/systems/arena.lua`.

**P: Jak dodać nowy tryb gry?**
O: Wymaga zmian w C++ (`arena_definitions.hpp`), recompile, i nowych kluczy i18n.

**P: Czy historia meczów jest trwała po restarcie?**
O: Tak, wszystko zapisane w MySQL (`arena_matches`, `arena_match_players`).

**P: Jak sprawdzić wydajność?**
O: Metryki w `logs/arena.log` (co 5 min): active matches, queue size, total matches.

---

*Dokument wygenerowany: 2026-02-21*
