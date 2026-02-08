# i18n Batch 26 — Loot, imbuement, protocollogin, boss speech + STATUS PROJEKTU

**Data:** 2026-02-08  
**Branch:** `feature/i18n-multilanguage`  
**Commit:** `00d48682d`

---

## Co zrobiono w batch 26

### C++ zmiany

| Plik | Zmiana |
|------|--------|
| `src/creatures/creature.cpp:711` | `"Loot of {}: {}"` → klucz i18n `cpp.creature.loot_of` z locale gracza |
| `src/items/item.cpp:193,206` | 2 × `sendImbuementResult("...")` → klucze `cpp.item.invalid_slot` + `cpp.item.imbuement_error_reopen` |
| `src/server/network/protocol/protocollogin.cpp` | 7 × `disconnectClient("...")` → istniejące klucze i18n (protocol version, gameworld starting/maintenance, IP ban, invalid login, invalid password) — fallback na EN bo gracz jeszcze nie zalogowany |

### Lua zmiany

| Plik | Zmiana |
|------|--------|
| `data-otservbr-global/lib/quests/soul_war.lua` | 4 × `boss:say("...")` → `sayLocalized()` (megalomania taunt/wrath/vulnerable/immune) |
| `data-otservbr-global/lib/quests/grimvale.lua` | 1 × `spec:say("...")` → `sayLocalized()` + 2 × `Game.broadcastMessage` → `Game.broadcastLocalizedMessage` |

### Klucze JSON dodane

- **cpp.json:** +4 klucze (creature.loot_of, item.invalid_slot, item.imbuement_error_reopen, protocol.invalid_password)
- **scripts.json:** +7 kluczy (4 soul_war + 3 grimvale)
- Zsynchronizowane do 54 locale

### Odnalezione jako już zmigrowane (pominięte)

- `special_tiles.lua` — depot/stash — już używa `sendLocalizedTextMessage`
- Offline training modal — już na kluczach i18n
- NPC handler defaults — już ma `localizedMessages` mapping
- `sendCancelMessage` z literałami — 0 w C++
- `sendTextMessage` z literałami — 0 w C++

### Świadomie pominięte (nie wymagają i18n)

| Element | Uzasadnienie |
|---------|-------------|
| `m_highscoreCategoriesNames` | Dead code — nigdzie nie odczytywane w wysyłaniu do gracza |
| `addCoins("Purchased on Market")` | Log w bazie danych, nie widoczne dla gracza |
| Chat `"Party"` / `"Private Chat Channel"` | Klient Tibia ma wbudowane nazwy kanałów po stronie klienta |
| `Container::getContentDescription "nothing"` | Metoda C++ bez kontekstu locale (brak obiektu Player) |
| `HouseTransferItem "It is a house transfer document..."` | Atrybut przedmiotu tworzony bez kontekstu gracza |

---

## Stan projektu i18n — pełne podsumowanie

### Statystyki kluczy (po batch 26)

| Plik JSON | Kluczy | Opis |
|-----------|--------|------|
| items.json | 16,894 | Nazwy/opisy przedmiotów |
| npc.json | 13,765 | Dialogi NPC (KOMPLETNE) |
| spells.json | 1,534 | Zaklęcia |
| scripts.json | 1,524 | Skrypty Lua |
| html.json | 1,495 | Treści cyklopedii/HTML |
| books.json | 1,403 | Książki, znaki, listy |
| otclient_modules.json | 1,987 | Moduły klienta OTC |
| cpp.json | 858 | Komunikaty serwera C++ |
| monsters.json | 5,915 | Potwory |
| quests.json | 505 | Questy/misje |
| raids.json | 273 | Najazdy |
| client.json | 242 | Client strings |
| talkactions.json | 185 | Komendy talk |
| server.json | 97 | Server misc |
| libs.json | 81 | Biblioteki Lua |
| npclib.json | 80 | System NPC lib |
| otclient_data.json | 72 | Dane klienta |
| php.json | 59 | WebAAC |
| actions.json | 35 | Akcje |
| startup.json | 23 | Startowe |
| modules.json | 19 | Moduły |
| chatchannels.json | 16 | Kanały czatu |
| example_merchant.json | 14 | Przykład handlarza |
| events.json | 14 | Eventy |
| messages.json | 11 | Wiadomości |
| globalevents.json | 5 | Eventy globalne |
| creaturescripts.json | 4 | Skrypty stworzeń |
| dataroot.json | 3 | Root danych |
| movements.json | 2 | Ruchy |
| **RAZEM** | **~47,238** | **We wszystkich JSON** |

**Locale:** 55 (EN + 54 przetłumaczonych z fallback EN)

### Pokrycie C++ (src/) — po batch 26

| Wzorzec | Pozostałe hardcoded | Status |
|---------|--------------------:|--------|
| `disconnectClient("...")` | 0 | ✅ KOMPLETNE |
| `sendCancelMessage("...")` z literałem | 0 | ✅ KOMPLETNE |
| `sendTextMessage(TYPE, "...")` z literałem | 0 | ✅ KOMPLETNE |
| `sendImbuementResult("...")` | 0 | ✅ KOMPLETNE |
| `sendLocalizedTextMessage` (nowe API) | ~50+ użyć | ✅ Działające |
| `getReturnMessage()` stara wersja EN | 1 (protocolgame sendMessageDialog) | ⚠️ Niski priorytet |

### Pokrycie Lua (data/) — po batch 26

| Wzorzec | Pozostałe | Status |
|---------|----------:|--------|
| NPC `npcHandler:say("...")` | 0 | ✅ KOMPLETNE |
| NPC `text = "..."` / `text = {...}` | 0 | ✅ KOMPLETNE |
| Boss `:say("...")` w lib/ | 0 | ✅ KOMPLETNE |
| `Game.broadcastMessage("...")` w lib/ | 0 | ✅ KOMPLETNE |
| `sendTextMessage` z literałem w scripts/ | 0 (1 zakomentowana) | ✅ KOMPLETNE |

### Obszary wymagające dalszej pracy (PRIORYTET)

| # | Obszar | Szacunek pracy | Priorytet | Opis |
|---|--------|---------------|-----------|------|
| 1 | **Quest log / quest stringi** | ~590 stringów | WYSOKI | `data-otservbr-global/scripts/` — opisy questów w `player:sendTextMessage()` i quest logach. Większość już jest w `scripts.json` ale brakuje konwersji w samych skryptach quest. |
| 2 | **Klient OTC moduły UI** | ~1987 kluczy (istnieją!) | WYSOKI | Klucze w `otclient_modules.json` istnieją, ale trzeba sprawdzić czy **klient OTC** faktycznie je odczytuje. Wymaga pracy po stronie instalki. |
| 3 | **Game store opisy** | ~30 stringów | ŚREDNI | Niektóre opisy w `scripts.json` mogą nie mieć powiązania z Lua. |
| 4 | **items.xml nazwy** | 16,894 kluczy | NISKI | Klucze istnieją w `items.json`. Trzeba implementację po stronie C++ `Item::getName()` z locale. Trudne bo `Item` nie ma `Player*`. |
| 5 | **Spells opisy** | 1,534 kluczy | NISKI | Klucze istnieją w `spells.json`. Trzeba powiązanie z opisami w `data/XML/spells.xml`. |
| 6 | **Mapa OTBM — znaki/tablice** | ~1,403 kluczy (books) | NISKI | System `buildReverseTextMap()` + `getKeyForText()` istnieje. Trzeba uruchomić go przy ładowaniu mapy. |
| 7 | **`getReturnMessage()` stara EN** | 1 użycie | NISKI | Tylko w `protocolgame.cpp sendMessageDialog` — fallback. |
| 8 | **Tłumaczenia 54 locale** | OGROMNE | NISKI (teraz) | Wszystkie klucze mają fallback EN. Tłumaczenia na PL/DE/ES/etc. to osobny projekt po zakończeniu migracji. |

### Chronologia commitów (branch feature/i18n-multilanguage)

| Commit | Batch | Opis |
|--------|-------|------|
| ... | 1-16 | Wcześniejsze batche (books, scripts, items, quests, NPCs 1-16) |
| `e615218b5` | 22 | grizzly_adams — 161 kluczy |
| `eff1414f9` | 23 | bozo + seymour |
| `90af36ae0` | 24 | Kill ALL npcHandler:say() + fix 43 złamanych konkatenacji |
| `ba7be9e49` | 25 | text={} conversion + 6276 kluczy JSON + integralność |
| `00d48682d` | 26 | Loot msg, imbuement, protocollogin, boss speech + Codex work |

### Co zrobił Codex (parallel, uwzględniony w commicie batch 26)

Codex w tym samym dniu (2026-02-08) dodał:
- **Locale sync pipeline** — klient→ExtendedOpcode→Player::setLocale→DB migration 53
- **Translator normalization** — `normalizeLocale()` z canonical mapping (zh_tw, fil→tl, pt_BR→pt)
- **Forge history** i18n (player.cpp)
- **EXP messages** i18n (player.cpp)
- **Stash** i18n z pluralizacją (player.cpp)
- **Party** i18n + `broadcastPartyLocalizedMessage()` (party.cpp)
- **Chat** private channel invite/exclude (chat.cpp)
- **Trade** move closer, wants to trade (game.cpp)
- **Store/wrap** unwrap/description (game.cpp)
- **Market** marker-key zamiast EN comparison (game.cpp)
- **combatChangeMana** manaLoss z cache per-locale (game.cpp)
- **Quick loot** pełne zdania (game.cpp)
- **on_look.lua** — admin info (health/mana/position/IP/speed) z i18n
- **player.lua** — events i18n

Szczegóły: `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md` (501 linii)

---

## Jak kontynuować

1. Otwierasz nowe okno czatu
2. Mówisz: "Kontynuuj prace i18n — przeczytaj dokumentację z /home/ptaku/serweryt/Dokumentacja/"
3. Agent przeczyta ten plik i będzie wiedział co dalej
4. Priorytet #1: quest log stringi w `data-otservbr-global/scripts/`
5. Priorytet #2: weryfikacja czy klient OTC odczytuje `otclient_modules.json`
