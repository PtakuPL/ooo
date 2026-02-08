# 📚 Migracja tekstów książek, listów i scrolli do i18n

**Data rozpoczęcia:** 2026-02-05  
**Status:** � Migracja kluczy zakończona — gotowe do tłumaczenia

## 📊 Skala problemu

### Źródła tekstów

| Źródło | Lokalizacja | Ilość tekstów | Status migracji |
|--------|-------------|---------------|-----------------|
| Plik mapy .otbm | `data-otservbr-global/world/otservbr.otbm` | ~2811 stringów (1375 w JSON) | ✅ Reverse lookup |
| Lua multiline `text = [[...]]` | `data-otservbr-global/scripts/` | 15 tekstów | ✅ Markery #i18n: |
| Lua `text = "..."` | `data-otservbr-global/scripts/` + `npc/` | ~2833 | ⬜ Nie rozpoczęte |
| Hardcoded C++ | `item.cpp`, `house.cpp` | ~5 | 🟡 Częściowo (resolver #i18n:) |

### Statystyki tekstów .otbm wg długości

| Długość | Ilość | Typ treści |
|---------|-------|------------|
| >10 znaków | 2811 | Wszystkie teksty (znaki, książki, listy) |
| >50 znaków | 865 | Znaki informacyjne, krótkie opisy |
| >100 znaków | 535 | Opisy questowe, informacje NPC |
| >200 znaków | 234 | Książki, listy, dokumenty |
| >500 znaków | 108 | Duże książki, lore, historia |
| >1000 znaków | 31 | Pełne rozdziały (np. History of the Augur) |

### Stan i18n JSON

| Plik | Pokrycie treści książek |
|------|------------------------|
| `i18n/en/books.json` | ✅ NOWY - klucze książek/listów/scrolli |
| `i18n/en/items.json` | ❌ Tylko nazwy/opisy itemów, nie treści |
| `i18n/en/quests.json` | ❌ 132 krótkich komunikatów questowych |
| `i18n/en/world.json` | ❌ Pusty |

## 🔧 Architektura tłumaczenia

### Przepływ tekstu (przed migracją)
```
Mapa .otbm → mapcache.cpp → item->setAttribute(TEXT, "angielski tekst")
Lua skrypt → item:setAttribute(ITEM_ATTRIBUTE_TEXT, "angielski tekst")
    ↓
Gracz klika → actions.cpp → player->sendTextWindow(item)
    ↓
protocolgame.cpp → msg.addString(item->getText()) → klient otrzymuje angielski tekst
```

### Przepływ tekstu (po migracji)
```
PODEJŚCIE 1 - Lua z markerem #i18n:
  Lua skrypt → item:setAttribute(TEXT, "#i18n:book.quest_name.page_1")
      ↓
  sendTextWindow → wykrywa marker #i18n: → i18n::g_translator().get(key, locale)
      ↓
  Klient otrzymuje przetłumaczony tekst

PODEJŚCIE 2 - Reverse lookup dla .otbm
  Mapa .otbm → item->setAttribute(TEXT, "angielski tekst oryginalny")
      ↓
  sendTextWindow → hash lookup angielskiego tekstu → znaleziony klucz i18n
      ↓
  i18n::g_translator().get(key, locale) → klient otrzymuje tłumaczenie
```

## 📋 Pliki zmigrowane

### Lua skrypty
- [x] `scripts/actions/other/others/quest_system2.lua` — 9 tekstów → markery #i18n:
- [x] `scripts/quests/koshei_the_deathless_quest/action_bag.lua` — 1 tekst → #i18n:book.koshei.*
- [x] `scripts/quests/the_new_frontier/action_hidden_note.lua` — 1 tekst → #i18n:book.new_frontier.*
- [x] `scripts/quests/dawnport/actions_vocation_reward.lua` — 1 tekst → #i18n:book.dawnport.*
- [x] `scripts/quests/the_cursed_crystal/actions_Misc.lua` — 1 tekst → #i18n:book.cursed_crystal.*
- [x] `scripts/actions/system/quest_reward_common.lua` — 3 teksty → #i18n:book.quest_reward.*
- [x] `scripts/quests/parchment_room/parchment.lua` — 1 tekst → #i18n:book.parchment_room.*
- ~~`scripts/quests/heart_of_destruction/actions_final_lever.lua`~~ — fałszywy pozytyw (brak tekstów)
- ~~`scripts/movements/others/remove-create_item.lua`~~ — fałszywy pozytyw (brak tekstów)

### C++ hardcoded
- [x] `item.cpp` — resolver #i18n: w getDescription (podgląd tekstu)
- [ ] `item.cpp:3149` — "You read: " (odroczone — brak locale w getDescription)
- [ ] `item.cpp:3153-3156` — "Nothing is written on it" (odroczone)
- [ ] `item.cpp:3159` — "You are too far away to read it" (odroczone)
- [ ] `house.cpp:977` — "Warning! The rent..." (odroczone — tekst dynamiczny z danymi gracza)

### Pliki .otbm
- [x] ~1375 tekstów — reverse lookup via `buildReverseTextMap` + `getKeyForText`

### Zmodyfikowane pliki C++
- [x] `src/utils/i18n/translator.hpp` — dodano `buildReverseTextMap()`, `getKeyForText()`
- [x] `src/utils/i18n/translator.cpp` — implementacja reverse map
- [x] `src/server/network/protocol/protocolgame.hpp` — dodano `translateBookText()`
- [x] `src/server/network/protocol/protocolgame.cpp` — implementacja + 2 hooki w sendTextWindow
- [x] `src/items/item.cpp` — resolver prefiksu #i18n: w getDescription

## 📝 Changelog

### 2026-02-05
- Utworzono dokumentację migracji
- Rozpoczęto ekstrakcję tekstów z Lua i .otbm
- Utworzono `i18n/en/books.json` — **1403 klucze**
- Skopiowano books.json do 54 katalogów języków
- Dodano reverse lookup w Translator (buildReverseTextMap + getKeyForText)
- Dodano `translateBookText()` w protocolgame.cpp z 2 podejściami:
  - `#i18n:` marker dla tekstów Lua (15 tekstów zmigrowanych)
  - Reverse lookup dla .otbm (1375 tekstów)
- Hooki w obu overloadach `sendTextWindow`
- Zmigrowano 7 plików Lua (15 tekstów → markery #i18n:)
- Dodano resolver #i18n: w `item.cpp::getDescription` (podgląd EN)
- Utworzono `tools/extract_book_texts.py` — skrypt ekstrakcji
