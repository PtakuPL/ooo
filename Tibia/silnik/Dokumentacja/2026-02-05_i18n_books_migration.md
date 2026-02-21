# 📚 i18n — Migracja tekstów książek/listów/scrolli
**Data:** 2026-02-05

## Co zostało zrobione

### 1. Ekstrakcja i books.json
- Utworzono skrypt `tools/extract_book_texts.py` do ekstrakcji wszystkich tekstów
- Wygenerowano `i18n/en/books.json` — **1403 klucze tłumaczeniowe**
  - 15 z Lua skryptów
  - 1375 z pliku mapy .otbm
  - 11 z hardcoded C++ (UI strings)
  - 2 dodane ręcznie
- Skopiowano do 54 katalogów języków

### 2. Infrastruktura C++ (Translator)
- `translator.hpp/cpp` — dodano reverse lookup:
  - `buildReverseTextMap("book.otbm.")` — buduje mapę: tekst EN → klucz i18n
  - `getKeyForText(text)` — wyszukiwanie klucza po tekście
- Leniwe budowanie mapy (tylko przy pierwszym wywołaniu)

### 3. Tłumaczenie tekstów książek (ProtocolGame)
- `translateBookText()` w protocolgame.cpp z dwoma ścieżkami:
  - **Lua**: wykrywa prefiks `#i18n:` → pobiera tłumaczenie z JSON
  - **OTBM**: reverse lookup tekstu EN → klucz → tłumaczenie
- Hookowane oba overloady `sendTextWindow`

### 4. Migracja Lua (7 plików, 15 tekstów)
| Plik | Teksty | Klucze |
|------|--------|--------|
| quest_system2.lua | 9 | book.quest_system2.* |
| action_bag.lua | 1 | book.koshei.* |
| action_hidden_note.lua | 1 | book.new_frontier.* |
| actions_Misc.lua | 1 | book.cursed_crystal.* |
| actions_vocation_reward.lua | 1 | book.dawnport.* |
| quest_reward_common.lua | 3 | book.quest_reward.* |
| parchment.lua | 1 | book.parchment_room.* |

### 5. Resolver #i18n: w item.cpp
- `getDescription()` teraz rozwiązuje prefiks `#i18n:` do tekstu EN
- Uniknięto pokazywania surowych kluczy w podglądzie (Look at)

## Co odłożone na później
- Hardcoded UI strings w item.cpp ("You read:", "Nothing is written on it", "You are too far away to read it") — brak locale w getDescription
- house.cpp rent warning — tekst dynamiczny z danymi gracza
- Lua `text = "..."` i NPC dialogi (~2833 tekstów) — osobna migracja

## Problemy
- Brak — kompilacja będzie weryfikowana przez GitHub Actions
