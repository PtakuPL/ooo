# i18n OTC: Achievementy w Cyclopedii

**Data:** 2026-02-08  
**Commit OTC:** `8255d6ceb` (testyy repo, branch `feature/i18n-multilanguage`)  
**Commit serwer:** `061cb556f` (canary_test repo — achievementy server-side)  
**Push:** GitHub PtakuPL/ooo, branch `feature/i18n-multilanguage`

---

## Co zostało zrobione

### 1. Serwer Canary (commit `061cb556f`)

Pełna migracja i18n 524 achievementów:

- **`player_achievement.cpp`** — wiadomość gratulacyjna po odblokowaniu achievementa teraz używa `tr.get("achievement.<id>.name", locale)` z fallbackiem na angielski
- **`protocolgame.cpp`** — w `sendCyclopediaCharacterAchievements()` nazwy i opisy sekretnych achievementów tłumaczone per locale gracza
- **`game.cpp`** — 4 stringi transakcji market coin → klucze i18n
- **`i18n/en/achievements.json`** — 1,048 kluczy (524 × nazwa + opis)
- Sync do 54 lokali (łącznie 55 z EN), ~57,750 nowych klucz-locale wpisów

### 2. OTC Klient (commit `8255d6ceb`)

Modyfikacja wyświetlania achievementów w Cyclopedii:

- **Plik:** `modules/game_cyclopedia/tab/character/character.lua`
- **Funkcja:** `achievementSort()` (linia 430+)
- **Zmiana:** Zamiast `data.name` / `data.description` z tabeli `ACHIEVEMENTS` (hardcoded EN), wywołuje `tr("achievement.<id>.name")` i `tr("achievement.<id>.description")`
- **Fallback:** Jeśli `tr()` zwraca klucz bez tłumaczenia, wraca do oryginalnego EN z tabeli ACHIEVEMENTS
- **Tabela ACHIEVEMENTS** w `utils.lua` — bez zmian, działa jako fallback

### Jak to działa

```
Gracz otwiera Cyclopedię → zakładka Achievements
  ↓
character.lua:achievementSort() iteruje ACHIEVEMENTS
  ↓
Dla każdego ID: tr("achievement.123.name") → szuka w locale
  ↓
Znalezione? → wyświetla tłumaczenie
Nie znalezione? → wyświetla angielski z tabeli ACHIEVEMENTS
```

### System locale OTC

- `_G.tr(key)` zdefiniowane w `client_locales/locales.lua`
- `loadGameI18nForLocale()` ładuje ZARÓWNO:
  - `game_i18n_<lang>.lua` (klucze pełne: `achievement.1.name`)
  - `game_i18n_<lang>_compact.lua` (klucze kompaktowe: `O60`)
- Oba mergowane do `locale.translation` — `tr()` znajduje klucze pełne

### Co NIE zostało zmienione

- **OTC C++ parser achievementów** (`protocolgameparse.cpp:4925`) — nadal `break;`, ignoruje dane z serwera. Klient korzysta wyłącznie z lokalnej tabeli Lua. Server-side tłumaczenie w `protocolgame.cpp` jest na przyszłość (gdy parser zostanie zaimplementowany).
- **Protobuf `staticdata.proto`** — `Achievement { id, name, description, grade }` — deklaracja, nigdzie nie używana w logice
- **`utils.lua` ACHIEVEMENTS table** — nietknięta, służy jako fallback

---

## Problemy / Uwagi

- Brak problemów — prosta zmiana, 15 linii dodanych, 2 usunięte
- Klucze i18n achievementów (`achievement.<id>.name/description`) były już wygenerowane i zsynchronizowane do wszystkich 55 lokali w poprzednim kroku server-side
- Fallback działa niezawodnie — nawet jeśli locale nie jest załadowany, gracz widzi angielski

## Statystyki

| Metryka | Wartość |
|---------|---------|
| Achievementów | 524 |
| Kluczy i18n | 1,048 |
| Pliki zmienione (OTC) | 1 |
| Linie dodane | 15 |
| Linie usunięte | 2 |
| Lokale wspierane | 55 |
