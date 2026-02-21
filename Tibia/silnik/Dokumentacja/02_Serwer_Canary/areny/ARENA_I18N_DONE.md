# Arena PvP — Faza 10: i18n (Wielojęzyczność) — GOTOWE

> **Data realizacji:** 2026-02-21  
> **Commit:** `d1468edc4`  
> **Pliki zmienione:** 64 (7 skryptów Lua + 57 plików JSON)

---

## Co zostało zrobione

### 1. Pliki tłumaczeń JSON

| Plik | Klucze | Opis |
|------|--------|------|
| `i18n/en/arena.json` | 181 | Angielskie tłumaczenia (bazowe) |
| `i18n/pl/arena.json` | 181 | Polskie tłumaczenia (pełne) |
| `i18n/<55 locale>/arena.json` | 181 × 55 | Fallback EN dla pozostałych języków |

### 2. Konwencja kluczy i18n

- Format: `arena.<kontekst>.<akcja>` (dot-separated, lowercase)
- Parametry: `{0}`, `{1}`, `{2}` (pozycyjne)
- Przykłady:
  - `arena.mode.1v1` → "1v1 Duel" / "Pojedynek 1v1"
  - `arena.cmd.join.success` → "You joined the {0} queue." / "Dołączyłeś do kolejki {0}."
  - `arena.reward.mvp` → "MVP Bonus: +{0} pts" / "Bonus MVP: +{0} pkt"

### 3. Kategorie kluczy

| Kategoria | Prefiks | Ilość kluczy | Opis |
|-----------|---------|-------------|------|
| Tryby | `arena.mode.*` | 16 | Nazwy i opisy trybów |
| Tytuły | `arena.title.*` | 12 | Tytuły rankingowe |
| Komendy | `arena.cmd.*` | ~40 | Wiadomości !arena |
| NPC | `arena.npc.*` | ~25 | Dialogi Arena Master |
| Sklep | `arena.shop.*` | ~15 | Nazwy i wiadomości sklepu |
| Admin | `arena.admin.*` | ~25 | Komendy !arena-admin |
| Mecz | `arena.result.*` | ~15 | Wyniki, ogłoszenia |
| Walidacja | `arena.check.*` | ~10 | Błędy (level, cooldown) |
| Nagrody | `arena.reward.*` | ~10 | Bonusy, punkty |
| Inne | `arena.*` | ~13 | Kolejka, rekordy, śmierć |

### 4. Skrypty Lua przepisane na i18n

| Plik | API używane |
|------|-------------|
| `data/libs/systems/arena.lua` | `player:getTranslation()` |
| `data/scripts/talkactions/player/arena.lua` | `sendLocalizedTextMessage()`, `getTranslation()` |
| `data-otservbr-global/npc/arena_master.lua` | `NPC_LIB.i18n.npcSay()`, `setLocalizedMessage()` |
| `data/scripts/arena/arena_main.lua` | `broadcastLocalized()`, `getTranslation()` |
| `data/scripts/talkactions/player/arena_rewards.lua` | `sendLocalizedTextMessage()`, `getTranslation()` |
| `data/scripts/talkactions/gm/arena_admin.lua` | `sendLocalizedTextMessage()`, `getTranslation()` |
| `data/scripts/eventcallbacks/player/arena_on_death.lua` | `sendLocalizedTextMessage()` |

### 5. Nowe helpery w ArenaConfig

- `ArenaConfig.getTitleI18nKey(titleName)` — zwraca klucz i18n dla tytułu
- `ArenaConfig.getTranslatedTitle(player, mmr)` — przetłumaczony tytuł
- `ArenaConfig.getModeName(player, modeId)` — przetłumaczona nazwa trybu
- `ArenaConfig.formatRecord(player, stats)` — sformatowany rekord W/L/D

---

## Jak dodać nowy język

1. Skopiuj `i18n/en/arena.json` do `i18n/<nowy_kod>/arena.json`
2. Przetłumacz wartości (klucze zostają bez zmian)
3. Zachowaj `{0}`, `{1}` placeholdery w odpowiednich miejscach
4. System C++ `i18n::Translator` automatycznie załaduje plik przy starcie serwera
