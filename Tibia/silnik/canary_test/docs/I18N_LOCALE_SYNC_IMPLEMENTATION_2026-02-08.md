# I18N Locale Sync - Implementacja (2026-02-08)

## Cel zmiany
Domknąć przepływ locale klient -> serwer -> baza danych, tak aby wybrany język gracza:
- był odbierany przez serwer,
- był stosowany przez logikę i18n po stronie serwera,
- był zapisywany i odtwarzany po relogu/restarcie.

## Zakres wykonanych zmian
Zmiany objęły 9 plików kodu/migracji + 1 zmianę nazwy pliku skryptu (z aktywacją).

---

## 1) Lua API gracza - udostępnienie locale dla skryptów

### Plik
`src/lua/functions/creatures/player/player_functions.hpp`

### Co zmieniono
- Dodano deklaracje:
  - `luaPlayerGetLocale(lua_State* L)`
  - `luaPlayerSetLocale(lua_State* L)`

### Po co
Skrypty Lua muszą mieć oficjalne API do odczytu i ustawienia locale gracza.

---

### Plik
`src/lua/functions/creatures/player/player_functions.cpp`

### Co zmieniono
- Zarejestrowano metody Lua:
  - `Player:getLocale()`
  - `Player:setLocale(locale)`
- Dodano implementacje obu metod:
  - `getLocale` zwraca aktualne locale gracza.
  - `setLocale` przekazuje wartość do `Player::setLocale(...)` (z normalizacją po stronie C++).

### Po co
Bez tego skrypt od extended opcode nie mógł ustawić locale na obiekcie `Player`.

---

## 2) Persistencja locale w bazie danych

### Plik
`src/io/functions/iologindata_load_player.cpp`

### Co zmieniono
- W `loadPlayerBasicInfo(...)` dodano:
  - `player->setLocale(result->getString("locale"));`

### Po co
Po zalogowaniu gracz ma odzyskać locale z bazy, a nie zawsze startować z domyślnego.

---

### Plik
`src/io/functions/iologindata_save_player.cpp`

### Co zmieniono
- W `savePlayerFirst(...)` dodano zapis kolumny:
  - `` `locale` = db.escapeString(player->getLocale()) ``

### Po co
Zmiana języka musi być trwała między sesjami.

---

### Plik
`schema.sql`

### Co zmieniono
- Zmieniono seed `db_version` z `52` na `53`.
- W tabeli `players` dodano kolumnę:
  - ``locale VARCHAR(5) NOT NULL DEFAULT 'en'``

### Po co
Nowe instalacje muszą mieć od razu poprawny schemat pod locale.

---

### Plik
`data-otservbr-global/migrations/53.lua`

### Co zmieniono
- Dodano migrację:
  - `ALTER TABLE players ADD COLUMN locale VARCHAR(5) NOT NULL DEFAULT 'en' AFTER pronoun`

### Po co
Istniejące bazy (produkcyjne/testowe) muszą dostać nową kolumnę bez ręcznych zmian SQL.

---

## 3) Obsługa locale z klienta przez Extended Opcode

### Plik (zmiana nazwy + aktywacja)
`data/scripts/creaturescripts/others/#extended_opcode.lua` -> `data/scripts/creaturescripts/others/extended_opcode.lua`

### Co zmieniono
- Plik z prefiksem `#` był wyłączony przez loader skryptów.
- Przeniesiono go do aktywnej nazwy.
- Zmieniono logikę:
  - obsługa tylko `opcode == 1` (locale),
  - sanitizacja locale (`lower`, usunięcie niedozwolonych znaków, limit 5),
  - ustawienie locale przez `player:setLocale(locale)`.

### Po co
Serwer musi faktycznie przyjmować locale wysyłane przez klienta i zapisywać je w obiekcie gracza.

---

### Plik
`data/scripts/creaturescripts/player/login.lua`

### Co zmieniono
- W `onLogin` dodano:
  - `player:registerEvent("ExtendedOpcode")`

### Po co
Event `onExtendedOpcode` działa tylko dla gracza z zarejestrowanym eventem. Bez tego pakiet z klienta nie byłby obsłużony.

---

## 4) Efekt końcowy (przepływ)
1. Klient (`testyy/modules/client_locales/locales.lua`) wysyła locale przez `ExtendedIds.Locale` (opcode `1`) po starcie gry.
2. Serwer odbiera opcode w `ProtocolGame::parseExtendedOpcode(...)` i przekazuje do eventów Lua.
3. Aktywny event `ExtendedOpcode` ustawia `player:setLocale(...)`.
4. Przy zapisie postaci `IOLoginDataSave::savePlayerFirst(...)` zapisuje `players.locale`.
5. Przy kolejnym logowaniu `IOLoginDataLoad::loadPlayerBasicInfo(...)` odtwarza locale z bazy.

Wynik: locale jest sesyjne i trwałe (persistowane).

---

## 5) Walidacja wykonana po zmianie
- Zweryfikowano diff i spójność ścieżek.
- Nie udało się wykonać kompilacji w tym środowisku (brak `ninja` i poprawnego `VCPKG_ROOT` dla presetów CMake).
- Nie było dostępnego `luac` do lokalnej walidacji składni Lua.

## 6) Uwaga wdrożeniowa
Po deployu należy uruchomić serwer tak, by wykonała się migracja `53` (dodanie `players.locale`).

---

## 7) Kontynuacja prac (stabilizacja locale) - 2026-02-08

W kolejnym kroku dopięto stabilność pełnej i18n dla wariantów locale i case-sensitive katalogów:

### Plik
`src/utils/i18n/translator.hpp`

### Co zmieniono
- Dodano API:
  - `Translator::normalizeLocale(std::string locale)`

### Po co
Ujednolicenie locale do postaci kanonicznej serwera.

---

### Plik
`src/utils/i18n/translator.cpp`

### Co zmieniono
- Dodano canonical mapping locale (w tym aliasy i warianty):
  - `zh_tw`, `zh-TW`, `zh_hant` -> `zh_TW`
  - `zh_cn` -> `zh`
  - `fil` -> `tl`
  - `pt_BR` -> `pt`
- Zaktualizowano listę wspieranych locale:
  - dodano `zh_TW`
  - zastąpiono `fil` przez `tl`
- `format`, `plural`, `loadLocale`, `isLocaleLoaded`, `setFallbackLocale` korzystają z normalizacji.

### Po co
Naprawa krytycznego przypadku, gdzie `zh_TW` traciło poprawną postać i fallbackowało do EN.

---

### Plik
`src/creatures/players/player.cpp`

### Co zmieniono
- `Player::setLocale(...)` przełączono na `Translator::normalizeLocale(...)` z fallbackiem do `defaultLocale`/`en`.

### Po co
Odrzucenie nieprawidłowych locale i spójna kanonizacja przed zapisem do `players.locale`.

---

### Plik
`src/server/network/protocol/protocolgame.cpp`

### Co zmieniono
- W `parseExtendedOpcode(...)` dodano natywną obsługę opcode `1` (locale):
  - `player->setLocale(buffer)`

### Po co
Locale działa nawet gdy event Lua nie zostanie zarejestrowany; mechanizm jest odporny i niezależny od datapacka.

---

### Plik
`data-otservbr-global/scripts/creaturescripts/others/login.lua`

### Co zmieniono
- Dodano `player:registerEvent("ExtendedOpcode")`.

### Po co
Zachowanie kompatybilności dla logiki Lua extended opcode po stronie datapacka.

---

### Pliki testowe
- `tests/unit/utils/locale_normalization_test.cpp` (nowy)
- `tests/unit/utils/CMakeLists.txt` (aktualizacja)

### Co zmieniono
- Dodano testy jednostkowe normalizacji locale (m.in. `zh_TW`, `fil/tl`, `pt_BR`).

### Po co
Regresyjna ochrona krytycznej ścieżki i18n.

---

## 8) Kontynuacja prac (pełne i18n C++: forge + komunikaty EXP/stash) - 2026-02-08

### Plik
`src/creatures/players/player.cpp`

### Co zmieniono
- Usunięto hardcoded EN z opisu historii forge i zastąpiono kluczami i18n:
  - `cpp.forge.history_fusion`
  - `cpp.forge.history_transfer`
  - `cpp.forge.unknown`
  - `cpp.forge.convergence_suffix`
  - `cpp.forge.tier_plus_one`
  - `cpp.forge.unchanged`
- Opisy kosztów w historii forge korzystają z pluralizacji (`tr.plural`) zamiast twardych suffixów:
  - `cpp.forge.cores_*`
  - `cpp.forge.dust_*`
- W `forgeTransferItemTier(...)` zapisano do historii realne koszty z konfiguracji:
  - `history.dustCost`
  - `history.coresCost`
  (zamiast wartości zaszytych na sztywno).
- Komunikaty EXP przepięto z literalnych EN na i18n:
  - bazowy tekst punktów EXP (`cpp.player.exp_points_*`)
  - bonus VIP (`cpp.player.exp_vip_bonus`)
  - bonus animus mastery (`cpp.player.exp_animus_bonus`)
  - strata EXP (`cpp.player.exp_lost_points_*`)
  - znacznik hazardu przez klucz `cpp.game.hazard_tag` (bez hardcoded `" (Hazard)"`).
- Komunikaty stash przepięto na pluralizację:
  - `cpp.player.stowed_objects_*`
  - `cpp.player.moved_objects_*`

### Po co
- Przygotowanie pełnego pipeline tłumaczeń z EN na wszystkie języki (bez fragmentów EN ukrytych w C++).
- Lepsza jakość językowa dla pluralizacji (różne reguły per locale).
- Zgodność historii forge z rzeczywistymi kosztami serwera (konfiguracja, bez stałych na sztywno).

---

### Plik
`i18n/en/cpp.json`

### Co zmieniono
- Dodano nowe klucze bazowe EN dla wszystkich powyższych ścieżek C++:
  - sekcja `cpp.forge.*` (szablony historii, pluralizacja kosztów, fallback unknown),
  - sekcja `cpp.player.*` (EXP/plural/suffixy),
  - sekcja `cpp.player.*` (pluralizacja stash).

### Po co
EN staje się pełnym źródłem dla masowego tłumaczenia na pozostałe locale.

---

## 9) Walidacja wykonana po tej iteracji
- Sprawdzono poprawność składni JSON:
  - `python3 -m json.tool i18n/en/cpp.json`
- Wykonano ręczną inspekcję diff i powiązań kluczy i18n w C++.
- Testów nie uruchamiano zgodnie z decyzją projektową (uruchomienie dopiero na GitHub Actions po większym zakresie migracji i18n).

---

## 10) Kontynuacja prac (pełne i18n C++: party.cpp) - 2026-02-08

### Pliki
- `src/creatures/players/grouping/party.cpp`
- `src/creatures/players/grouping/party.hpp`

### Co zmieniono
- Dodano helper broadcastu lokalizowanego:
  - `Party::broadcastPartyLocalizedMessage(...)`
  - wysyła komunikat per-odbiorca przez `sendLocalizedTextMessage(...)` (każdy gracz dostaje własne locale).
- Przepięto hardcoded komunikaty party na klucze i18n:
  - join/leave/new leader (`cpp.party.member_joined`, `cpp.party.member_left`, `cpp.party.new_leader`)
  - invite/revoke (`cpp.party.invited_*`, `cpp.party.invitation_revoked_*`)
  - statusy shared exp (`cpp.party.shared_exp_*`)
- `getSharedExpReturnMessage(...)` zastąpiono `getSharedExpReturnKey(...)` i wysyłką przez `sendLocalizedTextMessage(...)`.

### Po co
- Usunięcie twardych EN z krytycznej ścieżki komunikacji party.
- Poprawna internacjonalizacja broadcastów (wcześniej jedna angielska wiadomość dla wszystkich członków, teraz per-locale).

---

### Plik
`i18n/en/cpp.json`

### Co zmieniono
- Dodano nowe klucze bazowe EN dla komunikatów party:
  - `cpp.party.member_joined`
  - `cpp.party.member_left`
  - `cpp.party.new_leader`
  - `cpp.party.invited_member`
  - `cpp.party.invited_member_with_hint`
  - `cpp.party.invited_you`
  - `cpp.party.invitation_revoked_by_leader`
  - `cpp.party.invitation_revoked_for`
  - `cpp.party.shared_exp_active*`
  - `cpp.party.shared_exp_error`

### Po co
Kolejny moduł C++ ma komplet EN jako źródło do tłumaczeń na wszystkie języki.

---

## 11) Walidacja po migracji party.cpp
- Sprawdzono komplet nowych kluczy `cpp.party.*` używanych w `party.cpp` względem `i18n/en/cpp.json`.
- Ponownie zweryfikowano poprawność składni `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Testów nie uruchamiano (zgodnie z ustaleniem: dopiero GitHub Actions po szerszej migracji i18n).

---

## 12) Kontynuacja prac (chat.cpp + trade komunikaty game.cpp) - 2026-02-08

### Pliki
- `src/creatures/interactions/chat.cpp`
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `chat.cpp`:
  - Przepięto komunikaty prywatnego kanału z hardcoded EN na klucze i18n:
    - `cpp.chat.private_invite_received`
    - `cpp.chat.private_invited_confirm`
    - `cpp.chat.private_excluded_confirm`
  - Zastosowano `sendLocalizedTextMessage(...)` zamiast ręcznego składania `std::ostringstream`.
- `game.cpp`:
  - Przepięto 2 komunikaty trade z hardcoded EN na i18n:
    - `cpp.game.trade_move_closer`
    - `cpp.game.trade_wants_to_trade`
  - Komunikaty są formatowane per-locale odbiorcy.
- `i18n/en/cpp.json`:
  - Dodano bazowe klucze EN dla nowych ścieżek `cpp.chat.*` i `cpp.game.trade_*`.

### Po co
- Usunięcie kolejnych twardych tekstów EN z C++.
- Ujednolicenie ścieżki tłumaczeń dla chat/trade przed masowym tłumaczeniem na wszystkie języki.

---

## 13) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono powiązanie użyć kluczy w C++ z wpisami w `i18n/en/cpp.json`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 14) Kontynuacja prac (store/wrap opisy w game.cpp) - 2026-02-08

### Pliki
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- W `Game::createItemBatch(...)` usunięto hardcoded opis wrap i podmieniono na i18n:
  - `cpp.game.unwrap_house_description`
- W `Game::addItemStoreInbox(...)` usunięto hardcoded opis sklepu i podmieniono na i18n:
  - `cpp.game.store_item_description`
- Dodano brakujący klucz EN:
  - `cpp.game.unwrap_house_description`

### Po co
- Kolejne usunięcie twardych EN z C++.
- Spójny mechanizm opisu przedmiotów wrap/store, gotowy do tłumaczeń na wszystkie języki.

---

## 15) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Potwierdzono brak hardcoded wersji tych opisów w `game.cpp` (zastąpione kluczami i18n).
- Testów nie uruchamiano (zgodnie z ustaleniem).

---

## 16) Kontynuacja prac (market: usunięcie porównań po EN stringu) - 2026-02-08

### Pliki
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- Dodano klucz i18n dla błędu nieprawidłowego przedmiotu na market:
  - `cpp.game.market_item_not_correct`
- W `game.cpp` usunięto porównania logiczne oparte o surowy tekst EN:
  - zamiast `"The item you tried to market is not correct. Check the item again."`
  - używany jest marker-klucz `marketInvalidItemMessageKey`.
- Przy błędach `removeOfferItems(...)` dodano natychmiastową wysyłkę lokalizowanego komunikatu do gracza:
  - create offer (`server.game.msg_24` fallback),
  - accept offer (`server.game.msg_27` fallback).
- Zachowano logi techniczne (offerStatus) dla diagnostyki serwera.

### Po co
- Eliminacja kruchej logiki zależnej od dokładnego EN stringa.
- Lepsza przygotowalność pod tłumaczenia (logika oparta o klucz, nie literal).
- Stabilniejsze zachowanie przy dalszym rozwoju i18n.

---

## 17) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono użycia:
  - `marketInvalidItemMessageKey` w `game.cpp`,
  - obecność `cpp.game.market_item_not_correct` w `i18n/en/cpp.json`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).
