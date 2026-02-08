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

---

## 18) Kontynuacja prac (combatChangeMana: lokalizacja komunikatów utraty many) - 2026-02-08

### Pliki
- `src/game/game.cpp`

### Co zmieniono
- W gałęzi `manaLoss` funkcji `Game::combatChangeMana(...)` usunięto hardcoded EN komunikaty składane przez `std::stringstream`.
- Podłączono istniejące klucze i18n `cpp.combat.mana_*`:
  - `cpp.combat.mana_attacker` / `cpp.combat.mana_attacker_crit`
  - `cpp.combat.mana_target_none`
  - `cpp.combat.mana_target_self` / `cpp.combat.mana_target_self_crit`
  - `cpp.combat.mana_target_by` / `cpp.combat.mana_target_by_crit`
  - `cpp.combat.mana_spectator_none`
  - `cpp.combat.mana_spectator_self`
  - `cpp.combat.mana_spectator_by` / `cpp.combat.mana_spectator_by_crit`
- Dodano cache komunikatu spectatorów per-locale:
  - `std::unordered_map<std::string, std::string> spectatorManaCache`
  - dzięki temu formatowanie tekstu dla spectatorów wykonuje się raz na język, nie raz na gracza.

### Po co
- Domknięcie kolejnej często wykonywanej ścieżki combat pod i18n.
- Usunięcie twardych EN z runtime C++.
- Lepsza wydajność formatowania komunikatów (cache per locale), ważna przy dużej liczbie spectatorów.

---

## 19) Walidacja po tym etapie
- Zweryfikowano, że hardcoded EN frazy utraty many nie występują już w tym bloku `combatChangeMana`.
- Sprawdzono składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla `src/game/game.cpp` (brak problemów whitespace).
- Testów nie uruchamiano (zgodnie z ustaleniem: testy dopiero po większym domknięciu migracji i18n).

---

## 20) Kontynuacja prac (quick loot: pełne zdania i18n zamiast sklejania fragmentów) - 2026-02-08

### Pliki
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- W `Game::playerQuickLootCorpse(...)` usunięto składanie komunikatów z fragmentów:
  - `cpp.game.you_looted` / `cpp.game.could_not_loot` + hardcoded `" gold."` / `"1 item."`
- Zastąpiono je pełnymi kluczami i18n (całe zdania):
  - `cpp.game.quick_loot_success_gold`
  - `cpp.game.quick_loot_success_one_item`
  - `cpp.game.quick_loot_fail_gold`
  - `cpp.game.quick_loot_fail_one_item`
- Dodano powyższe klucze bazowe EN do `i18n/en/cpp.json`.

### Po co
- Pełne zdania per klucz dają poprawny szyk i fleksję w innych językach (bez narzucania angielskiej kolejności przez konkatenację).
- Kolejne usunięcie hardcoded EN z runtime C++.

---

## 21) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/game/game.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycia nowych kluczy `cpp.game.quick_loot_*` w `game.cpp`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 22) Kontynuacja prac (protocolgame.cpp: Cyclopedia/Container/Outfit UI pod i18n) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `ProtocolGame::sendCyclopediaCharacterInspection()`:
  - dodano locale-aware tłumaczenie etykiet i opisów:
    - `Character Title`, `Level`, `Vocation`, `Loyalty Title`, `Married to`, `Outfit`, `unknown`
  - przepięto tytuł aktywnego Prey na klucz formatowany:
    - `cpp.protocol.active_prey_label`
  - usunięto hardcoded składanie EN dla opisu bonusu Prey:
    - `Improved Damage/Defense/Experience/Loot`
    - fallback `Unknown creature`
  - opis Prey jest teraz budowany jako pełny klucz:
    - `cpp.protocol.active_prey_desc`
- `ProtocolGame::sendContainer()`:
  - przepięto nazwę kontenera browse field:
    - `cpp.protocol.browse_field`
- `ProtocolGame::sendOutfitWindow()`:
  - przepięto nazwy support outfitów:
    - `cpp.protocol.support_outfit_gamemaster`
    - `cpp.protocol.support_outfit_customer_support`
    - `cpp.protocol.support_outfit_community_manager`
- `i18n/en/cpp.json`:
  - dodano komplet kluczy `cpp.protocol.*` dla powyższych ekranów i opisów.

### Po co
- Kolejne usunięcie hardcoded EN z warstwy serwer->klient dla interfejsów Cyclopedii i okien.
- Lepsza gotowość do masowego tłumaczenia (pełne klucze zamiast fragmentów zdań).
- Spójna lokalizacja na bazie locale gracza.

---

## 23) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że docelowe hardcoded etykiety EN w zmienionych sekcjach `protocolgame.cpp` zostały zastąpione kluczami i18n.
- Testów nie uruchamiano (zgodnie z ustaleniem: dopiero GitHub Actions po większej migracji i18n).

---

## 24) Kontynuacja prac (protocolgame.cpp: Resting Status pod i18n) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- W `ProtocolGame::sendRestingStatus(...)` usunięto hardcoded EN:
  - `Resting Area (no active bonus)`
  - `Active Resting Area Bonuses: ...`
  - nazwy bonusów regeneracji (HP/Mana/Stamina/Soul, w tym warianty double).
- Komunikaty są teraz pobierane z `cpp.protocol.*` per locale gracza.
- Dodano klucze:
  - `cpp.protocol.resting_no_bonus`
  - `cpp.protocol.resting_active_bonuses`
  - `cpp.protocol.resting_hp_regen`
  - `cpp.protocol.resting_hp_regen_double`
  - `cpp.protocol.resting_mana_regen`
  - `cpp.protocol.resting_mana_regen_double`
  - `cpp.protocol.resting_stamina_regen`
  - `cpp.protocol.resting_soul_regen`
- Sposób budowania listy bonusów pozostał semantycznie zgodny (separator `",\\n"`), ale finalny komunikat jest składany przez klucz formatowany.

### Po co
- Kolejny ekran klienta wysyłany przez protokół jest gotowy pod wielojęzyczność.
- Usunięcie EN z runtime C++ i ujednolicenie mechanizmu tłumaczeń.

---

## 25) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycia nowych kluczy `cpp.protocol.resting_*` w `sendRestingStatus`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 26) Kontynuacja prac (protocolgame.cpp: highscores vocation "all") - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- W `ProtocolGame::sendHighscores(...)` usunięto hardcoded etykietę `"(all)"` dla filtra vocation.
- Etykieta jest teraz pobierana z i18n:
  - `cpp.protocol.vocation_all`
- Dodano klucz bazowy EN:
  - `cpp.protocol.vocation_all`

### Po co
- Domknięcie kolejnej drobnej etykiety UI w protokole pod pełne i18n.
- Utrzymanie spójności: brak twardych EN w filtrach highscores.

---

## 27) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycie `cpp.protocol.vocation_all` w `sendHighscores`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 28) Kontynuacja prac (Tentugly: usunięcie hardcoded nazwy z C++) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `ProtocolGame::sendPodiumDetails(...)`:
  - usunięto hardcoded `"Tentugly"` z odpowiedzi protokołu,
  - podmieniono na klucz i18n per locale gracza:
    - `cpp.protocol.tentugly_name`.
- `Game::playerSetShowOffSocket(...)` (nazwa podium-itemu):
  - usunięto hardcoded `"Tentugly"` przy nadawaniu nazwy itemu,
  - podmieniono na klucz EN (stały, globalny atrybut itemu):
    - `cpp.game.tentugly_name` z locale `"en"`.
- Dodano klucze bazowe EN:
  - `cpp.protocol.tentugly_name`
  - `cpp.game.tentugly_name`

### Po co
- Domknięcie ostatniego jawnego hardcoded `msg.addString("...")` w `protocolgame.cpp`.
- Utrzymanie spójności i18n także dla specjalnego wyjątku bossa podium.
- Zachowanie bezpieczeństwa semantycznego: globalna nazwa itemu nadal oparta o EN (niezależnie od locale gracza, który wykonał akcję).

---

## 29) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `src/game/game.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że hardcoded `"Tentugly"` został usunięty z obu miejsc i zastąpiony kluczami i18n.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 30) Kontynuacja prac (offline training modal: klucze zamiast hardcoded EN) - 2026-02-08

### Pliki
- `src/game/game.hpp`
- `src/game/game.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `Game::offlineTrainingWindow`:
  - tytuł i treść modala ustawiono jako klucze i18n (zamiast EN literal):
    - `cpp.game.offline_training_title`
    - `cpp.game.offline_training_message`
- `Game::Game()`:
  - wybory treningu i przyciski modala zapisano jako klucze:
    - `cpp.game.offline_training_choice_*`
    - `cpp.game.offline_training_button_*`
- `Game::sendOfflineTrainingDialog(...)`:
  - dodano budowę zlokalizowanej kopii modala per locale gracza,
  - tłumaczone są: `title`, `message`, `buttons`, `choices` przed wysyłką.
- `i18n/en/cpp.json`:
  - dodano komplet kluczy EN dla offline training modala.

### Po co
- Offline training window jest teraz gotowy pod pełne tłumaczenia (bez hardcoded EN w C++).
- Lokalizacja odbywa się per gracz przy wysyłce modala, więc działa poprawnie dla wielu języków jednocześnie.

---

## 31) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/game/game.hpp`
  - `src/game/game.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że hardcoded EN z offline training modala zostały zastąpione kluczami i18n.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 32) Kontynuacja prac (highscores: nazwy kategorii jako klucze i18n) - 2026-02-08

### Pliki
- `src/game/game.cpp`
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `Game::m_highscoreCategories`:
  - nazwy kategorii (EN literal) zostały zastąpione kluczami `cpp.game.highscore_category_*`.
- `ProtocolGame::sendHighscores(...)`:
  - wysyłka nazwy kategorii do klienta została przepięta na tłumaczenie per locale:
    - `tr.get(category.m_name, locale)`
- `i18n/en/cpp.json`:
  - dodano klucze EN dla kategorii highscores:
    - experience, fist, club, sword, axe, distance, shielding, fishing, magic level.

### Po co
- Kategorie highscores są teraz gotowe do tłumaczeń wielojęzycznych.
- Usunięto kolejne hardcoded EN z danych UI wysyłanych przez protokół.

---

## 33) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/game/game.cpp`
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że `sendHighscores` wysyła lokalizowaną nazwę kategorii zamiast surowego EN.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 34) Kontynuacja prac (Cyclopedia Badges: lokalizacja nazw bez migracji KV) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `ProtocolGame::sendCyclopediaCharacterBadges()`:
  - dodano tłumaczenie nazw badge per locale gracza,
  - mapowanie odbywa się po `badge.m_id` -> `cpp.badge.name_<id>`,
  - dla nieznanego `id` zachowano fallback do `badge.m_name` (bez zmian danych runtime).
- `i18n/en/cpp.json`:
  - dodano klucze EN `cpp.badge.name_1..21`.

### Po co
- UI Cyclopedii (badges) jest gotowy pod tłumaczenia, bez zmiany nazw przechowywanych w KV i logice odblokowań.
- Minimalizacja ryzyka regresji: wewnętrzne identyfikatory/nazwy badge pozostają kompatybilne.

---

## 35) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że wysyłka badge do klienta korzysta z kluczy `cpp.badge.name_*`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 36) Kontynuacja prac (Cyclopedia Titles: paczka 1-20 pod i18n) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `ProtocolGame::sendCyclopediaCharacterTitles()`:
  - dodano locale-aware tłumaczenie nazw i opisów tytułów dla ID `1..20`,
  - użyte klucze:
    - `cpp.title.name_<id>`
    - `cpp.title.desc_<id>`
  - dla pozostałych ID zachowano fallback do istniejących wartości runtime (`title.m_*`), bez zmian logiki odblokowań/KV.
- `i18n/en/cpp.json`:
  - dodano klucze EN dla tytułów `1..20` (name + desc).

### Po co
- UI Cyclopedii (titles) zaczyna być migrowany do i18n bez ryzykownej jednorazowej zmiany wszystkich 90+ wpisów.
- Podejście etapowe umożliwia dalszą migrację kolejnych pakietów ID bez regresji kompatybilności danych.

---

## 37) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono, że `sendCyclopediaCharacterTitles` używa kluczy i18n dla zakresu `1..20` i fallback dla pozostałych wpisów.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 38) Kontynuacja prac (Cyclopedia Titles: paczka 21-40 + warianty female) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- Rozszerzono lokalizację w `ProtocolGame::sendCyclopediaCharacterTitles()` z zakresu `1..20` do `1..40`.
- Dodano obsługę wariantów żeńskich dla tytułów z osobnymi nazwami:
  - ID `32` (`Princess Charming`)
  - ID `35` (`Blood Moon Huntress`)
- Dla tytułów `1..40` pobierane są klucze:
  - `cpp.title.name_<id>` (oraz `*_female` dla wybranych)
  - `cpp.title.desc_<id>`
- Dla pozostałych ID zachowany fallback do danych runtime.
- `i18n/en/cpp.json`:
  - dodano klucze EN `cpp.title.name_21..40`,
  - dodano `cpp.title.name_32_female`, `cpp.title.name_35_female`,
  - dodano klucze EN `cpp.title.desc_21..40`.

### Po co
- Kolejna duża paczka Cyclopedia Titles jest gotowa do tłumaczeń wielojęzycznych.
- Zachowano kompatybilność danych i bezpieczny etapowy rollout (fallback dla niezmigrowanych ID).

---

## 39) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycie kluczy `cpp.title.*` dla zakresu `1..40` w `sendCyclopediaCharacterTitles`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 40) Kontynuacja prac (Cyclopedia Titles: paczka 41-60 + warianty female) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- Rozszerzono zakres lokalizacji tytułów w `sendCyclopediaCharacterTitles()` do `1..60`.
- Dodano warianty żeńskie dla tytułów z osobnymi nazwami w tej paczce:
  - `43`, `44`, `45`, `47`, `48`
- Dla zakresu `1..60` wysyłane są klucze:
  - `cpp.title.name_<id>` (+ `*_female` dla wskazanych ID)
  - `cpp.title.desc_<id>`
- Dla pozostałych ID nadal działa fallback do danych runtime.
- `i18n/en/cpp.json`:
  - dodano klucze EN `cpp.title.name_41..60`,
  - dodano klucze EN `cpp.title.desc_41..60`,
  - dodano klucze EN `*_female` dla wymaganych ID.

### Po co
- Migracja Cyclopedia Titles postępuje etapowo i bezpiecznie (bez zmian w KV).
- Kolejna duża część tekstów gracza jest gotowa pod wielojęzyczne tłumaczenia.

---

## 41) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycie kluczy `cpp.title.*` dla zakresu `1..60` oraz wariantów `*_female`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 42) Kontynuacja prac (Cyclopedia Titles: paczka 61-93 + warianty female) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- Rozszerzono zakres lokalizacji tytułów w `sendCyclopediaCharacterTitles()` z `1..60` do pełnego `1..93`.
- Dodano warianty żeńskie dla tytułów z osobnymi nazwami w tej paczce:
  - `70` (`Aspiring Huntswoman`)
  - `90` (`Queen of Demon`)
- Dla zakresu `1..93` wysyłane są klucze:
  - `cpp.title.name_<id>` (+ `*_female` dla wskazanych ID)
  - `cpp.title.desc_<id>`
- `i18n/en/cpp.json`:
  - dodano klucze EN `cpp.title.name_61..93`,
  - dodano klucze EN `cpp.title.desc_61..93`,
  - dodano klucze EN `cpp.title.name_70_female` i `cpp.title.name_90_female`.

### Po co
- Cyclopedia Titles ma teraz pełne pokrycie kluczami i18n dla wszystkich istniejących ID (`1..93`).
- Zostawiono fallback dla potencjalnych przyszłych/niestandardowych wpisów spoza tego zakresu, więc migracja pozostaje bezpieczna operacyjnie.

---

## 43) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycie kluczy `cpp.title.*` dla pełnego zakresu `1..93` wraz z wariantami `*_female`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 44) Kontynuacja prac (Cyclopedia: lokalizacja bieżącego tytułu + refactor helperów) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`

### Co zmieniono
- Dodano wspólne helpery i18n dla tytułów:
  - `hasFemaleTitleVariant(...)`
  - `getLocalizedTitleName(...)`
  - `getLocalizedTitleDescription(...)`
  - `getLocalizedCurrentTitleName(...)`
- `sendCyclopediaCharacterBaseInformation()`:
  - bieżący tytuł postaci (`character title`) jest teraz tłumaczony per locale, zamiast surowego `getCurrentTitleName()`.
- `sendCyclopediaCharacterInspection()`:
  - sekcja `Player title` została przepięta na ten sam helper lokalizujący.
- `sendCyclopediaCharacterTitles()`:
  - uproszczono pętlę: nazwa i opis tytułu pobierane są przez wspólne helpery (bez duplikacji logiki warunków).

### Po co
- Usunięto niespójność: wcześniej lista tytułów mogła być tłumaczona, ale bieżący wybrany tytuł nadal potrafił wyświetlać EN.
- Jedna ścieżka lokalizacji tytułów upraszcza utrzymanie i zmniejsza ryzyko regresji przy kolejnych etapach i18n.

---

## 45) Walidacja po tym etapie
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Potwierdzono, że w `src/server/network/protocol/protocolgame.cpp` nie ma już wywołań `getCurrentTitleName()`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 46) Kontynuacja prac (Vocation names: klucze i18n + fallback) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- Dodano helper `getLocalizedVocationName(vocationId, fallbackName, locale)`:
  - buduje klucz `cpp.vocation.id_<id>`,
  - przy braku tłumaczenia zachowuje fallback do oryginalnej nazwy z danych vocacji.
- Przepięto wysyłkę nazw vocacji na helper w:
  - `sendHighscores(...)` (lista filtrów vocacji),
  - `sendCyclopediaCharacterBaseInformation()`,
  - `sendCyclopediaCharacterInspection()` (sekcja `Vocation`).
- `i18n/en/cpp.json`:
  - dodano bazowe klucze EN:
    - `cpp.vocation.id_0..8` (None, Sorcerer, Druid, Paladin, Knight, Master Sorcerer, Elder Druid, Royal Paladin, Elite Knight).

### Po co
- Nazwy vocacji są teraz gotowe do tłumaczeń per locale bez naruszania kompatybilności z custom vocacjami.
- Fallback minimalizuje ryzyko regresji na serwerach z rozszerzonym `vocations.xml`.

---

## 47) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
  - `i18n/en/cpp.json`
- Potwierdzono użycie `getLocalizedVocationName(...)` we wszystkich trzech docelowych miejscach w `protocolgame.cpp`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 48) Kontynuacja prac (`look`: locale-aware opisy gracza + Lua bridge) - 2026-02-08

### Pliki
- `src/creatures/players/player.hpp`
- `src/creatures/players/player.cpp`
- `src/lua/functions/creatures/creature_functions.cpp`
- `data/scripts/eventcallbacks/player/on_look.lua`
- `data/events/scripts/player.lua`
- `i18n/en/cpp.json`

### Co zmieniono
- `Player`:
  - dodano metodę `getDescriptionLocalized(int32_t lookDistance, const std::string &viewerLocale)`,
  - `getDescription(...)` pozostawiono jako fallback EN (`return getDescriptionLocalized(..., "en")`),
  - logika opisu gracza (`look`) została przepięta na klucze i18n `cpp.player.look.*`,
  - lokalizowany jest też bieżący tytuł postaci (z użyciem `cpp.title.name_*` + `*_female`) oraz opis vocacji (`cpp.vocation.desc_id_*`).
- Lua API:
  - rozszerzono `creature:getDescription(...)` do wariantu:
    - `creature:getDescription(distance[, viewerPlayer])`,
  - jeśli `viewerPlayer` podano i oglądany obiekt jest graczem, używane jest `getDescriptionLocalized(..., viewerLocale)`.
- Skrypty look:
  - `data/scripts/eventcallbacks/player/on_look.lua`:
    - `inspectedThing:getDescription(lookDistance, player)`,
  - `data/events/scripts/player.lua` (legacy hook):
    - `creature:getDescription(distance, self)`.
- `i18n/en/cpp.json`:
  - dodano komplet kluczy EN `cpp.player.look.*` dla zdań opisu gracza (self/other, party, guild, loyalty, VIP),
  - dodano `cpp.vocation.desc_id_0..8` (opisowe formy vocacji, np. `a knight`, `an elder druid`).

### Po co
- Opis gracza (`look`) jest teraz budowany pod locale oglądającego zamiast stałego EN.
- Ten etap domyka ważną lukę i18n między C++ (opis gracza) a Lua eventami `on_look`.

---

## 49) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/creatures/players/player.hpp`
  - `src/creatures/players/player.cpp`
  - `src/lua/functions/creatures/creature_functions.cpp`
  - `data/scripts/eventcallbacks/player/on_look.lua`
  - `data/events/scripts/player.lua`
  - `i18n/en/cpp.json`
- Potwierdzono użycie:
  - `Player::getDescriptionLocalized(...)` w bridge Lua,
  - `creature:getDescription(distance, player)` w głównym `on_look` callbacku.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 50) Kontynuacja prac (legacy `onLookInBattleList`: usunięcie hardcoded EN) - 2026-02-08

### Pliki
- `data/events/scripts/player.lua`

### Co zmieniono
- `Player:onLookInBattleList(...)` został przepięty na istniejące tłumaczenia `scripts.on_look.*`:
  - prefix opisu (`see_prefix`),
  - opis familiara (`familiar_master`),
  - dane administracyjne (`admin_player_health`, `admin_player_health_mana`, `admin_player_id`, `admin_monster_id`, `admin_npc_id`, `admin_speed`, `admin_ip`),
  - pozycja (`position_coords`).
- Utrzymano przekazywanie viewer locale przez:
  - `creature:getDescription(distance, self)`.

### Po co
- Legacy ścieżka `onLookInBattleList` nie miesza już hardcoded EN z systemem i18n.
- Zmniejszono rozjazd między nowym callbackiem `data/scripts/eventcallbacks/player/on_look.lua` a starszym eventem.

---

## 51) Walidacja po tym etapie
- Sprawdzono `git diff --check` dla:
  - `data/events/scripts/player.lua`
  - oraz wcześniej dotkniętych plików i18n/C++/Lua z tej serii.
- Potwierdzono, że funkcja `Player:onLookInBattleList` używa kluczy `scripts.on_look.*` zamiast literalnych EN.
- Lokalny parser `luac` nie był dostępny w środowisku (`SKIP_LUAC`), więc wykonano walidację przez przegląd diffa i spójność kluczy.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 52) Kontynuacja prac (Blessing list: i18n nazw + łączniki listy) - 2026-02-08

### Pliki
- `src/creatures/players/player.cpp`
- `i18n/en/cpp.json`

### Co zmieniono
- `Player::getBlessingsName()`:
  - nazwy blessów nie są już budowane wyłącznie z `magic_enum` po EN,
  - dodano tłumaczenie nazw przez klucze:
    - `cpp.player.blessing_name_1..8`
  - dodano i18n dla składania listy:
    - `cpp.player.list_delimiter`
    - `cpp.player.list_and`
    - `cpp.player.list_end`
  - przy braku klucza działa fallback do wcześniejszego zachowania (tekst z enum/EN).
- `i18n/en/cpp.json`:
  - dodano komplet kluczy EN dla nazw blessów oraz łączników listy.

### Po co
- Komunikaty gracza korzystające z `getBlessingsName()` (`death`/`blessing` flow) są gotowe do tłumaczeń wielojęzycznych.
- Usunięto kolejne EN-only fragmenty sklejane w C++ (`and`, separator listy, nazwy blessów).

---

## 53) Walidacja po tym etapie
- Zweryfikowano składnię `i18n/en/cpp.json`:
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/creatures/players/player.cpp`
  - `i18n/en/cpp.json`
  - oraz aktualnego pakietu zmian (`data/events/scripts/player.lua`, dokumentacja).
- Potwierdzono użycie kluczy:
  - `cpp.player.blessing_name_*`
  - `cpp.player.list_delimiter`
  - `cpp.player.list_and`
  - `cpp.player.list_end`
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 54) Kontynuacja prac (Cyclopedia Store Summary: lokalizacja nazw blessingów) - 2026-02-08

### Pliki
- `src/server/network/protocol/protocolgame.cpp`

### Co zmieniono
- W `ProtocolGame::sendCyclopediaCharacterStoreSummary()`:
  - dodano pobranie locale gracza (`player->getLocale()` z fallbackiem `en`),
  - zastąpiono wysyłanie nazw blessingów z `magic_enum` (EN-only) na:
    - `getLocalizedBlessingName(bless, locale)`.
- `getLocalizedBlessingName(...)` wykorzystuje klucze:
  - `cpp.player.blessing_name_1..8`
  - i fallback do poprzedniej nazwy EN, jeśli tłumaczenie nie istnieje.

### Po co
- Cyclopedia Store Summary wysyła teraz nazwy blessingów zgodne z locale gracza.
- Domknięto niedokończoną wcześniej migrację tej ścieżki protokołu do i18n.

---

## 55) Walidacja po tym etapie
- Sprawdzono `git diff --check` dla:
  - `src/server/network/protocol/protocolgame.cpp`
- Potwierdzono użycie `getLocalizedBlessingName(...)` w pętli blessingów w `sendCyclopediaCharacterStoreSummary()`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 56) Kontynuacja prac (Loyalty Title: klucz i18n + tłumaczenie per-viewer locale) - 2026-02-08

### Pliki
- `src/creatures/players/player.hpp`
- `src/creatures/players/player.cpp`
- `src/server/network/protocol/protocolgame.cpp`
- `data/libs/functions/player.lua`
- `i18n/en/libs.json`

### Co zmieniono
- `Player`:
  - dodano metodę:
    - `getLoyaltyTitleLocalized(std::string_view locale) const`
  - metoda rozpoznaje klucze loyalty (`lib.player.loyalty_title_*`) i tłumaczy je przez `Translator` pod locale odbiorcy;
  - przy braku tłumaczenia lub dla legacy literalu zachowuje fallback do oryginalnego tekstu.
- `Player::getDescriptionLocalized(...)`:
  - zamiast surowego `loyaltyTitle` używa teraz `getLoyaltyTitleLocalized(viewerLocale)`,
  - dzięki temu opis `look` pokazuje loyalty title w języku oglądającego.
- `protocolgame.cpp`:
  - w `sendCyclopediaCharacterInspection()` loyalty title jest wysyłany przez `player->getLoyaltyTitleLocalized(locale)`,
  - w `sendCyclopediaCharacterBadges()` pole loyalty title również używa wersji zlokalizowanej.
- `data/libs/functions/player.lua`:
  - system lojalności przestał wpisywać EN literal do `setLoyaltyTitle(...)`,
  - teraz zapisuje stabilny klucz i18n (`lib.player.loyalty_title_1..11`).
- `i18n/en/libs.json`:
  - dodano klucze EN:
    - `lib.player.loyalty_title_1..11`.

### Po co
- Usunięto EN-only źródło loyalty title w runtime.
- Loyalty title stał się tłumaczalnym identyfikatorem, a nie „zamrożonym” tekstem.
- Opisy i Cyclopedia mogą prezentować ten sam tytuł poprawnie per locale odbiorcy.

---

## 57) Walidacja po tym etapie
- Zweryfikowano składnię JSON:
  - `python3 -m json.tool i18n/en/libs.json`
  - `python3 -m json.tool i18n/en/cpp.json`
- Sprawdzono `git diff --check` dla:
  - `src/creatures/players/player.hpp`
  - `src/creatures/players/player.cpp`
  - `src/server/network/protocol/protocolgame.cpp`
  - `data/libs/functions/player.lua`
  - `i18n/en/libs.json`
- Potwierdzono użycie nowych kluczy i metody:
  - `lib.player.loyalty_title_*`
  - `Player::getLoyaltyTitleLocalized(...)`
- Lokalny parser Lua nie był dostępny (`SKIP_LUA_PARSE`), więc walidację Lua wykonano przez diff + spójność kluczy.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 58) Kontynuacja prac (Highscore: loyalty title pod i18n + optymalizacja lookup) - 2026-02-08

### Pliki
- `src/game/game.cpp`
- `src/server/network/protocol/protocolgame.cpp`

### Co zmieniono
- `protocolgame.cpp`:
  - dodano helper `getLocalizedLoyaltyTitle(const std::string&, const std::string&)`,
  - `sendHighscores(...)` nie wysyła już loyalty title „as-is”, tylko:
    - `getLocalizedLoyaltyTitle(character.loyaltyTitle, locale)`.
  - jeśli wartość jest kluczem (`lib.player.loyalty_title_*`), jest tłumaczona na locale odbiorcy;
    dla wartości legacy (literal) zachowany jest fallback.
- `game.cpp` (`Game::processHighscoreResults(...)`):
  - usunięto TODO z pustym loyalty title,
  - dodano jednorazową mapę `GUID -> loyaltyTitle` budowaną z aktualnie online graczy,
  - przy budowie `HighscoreCharacter` loyalty title jest uzupełniany z tej mapy (bez ładowania offline postaci).

### Po co
- Highscore jest spójny z nowym modelem i18n loyalty title.
- Eliminujemy EN-only prezentację tam, gdzie loyalty title jest dostępny.
- Rozwiązanie jest lekkie wydajnościowo:
  - brak dodatkowych zapytań DB,
  - brak kosztownego `loadPlayerById` dla każdej pozycji highscore,
  - lookup O(1) po lokalnej mapie zamiast powtarzanych skanów.

---

## 59) Walidacja po tym etapie
- Sprawdzono `git diff --check` dla:
  - `src/game/game.cpp`
  - `src/server/network/protocol/protocolgame.cpp`
  - `docs/I18N_LOCALE_SYNC_IMPLEMENTATION_2026-02-08.md`
- Potwierdzono użycie:
  - `getLocalizedLoyaltyTitle(...)` w `sendHighscores(...)`,
  - mapy `onlineLoyaltyTitleByGuid` w `Game::processHighscoreResults(...)`.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 60) Kontynuacja prac (punkt 2: Lua modal defaults bez hardcoded EN) - 2026-02-08

### Pliki
- `data/libs/functions/player.lua`
- `i18n/en/libs.json`

### Co zmieniono
- `Player:showInfoModal(...)`:
  - domyślny tekst przycisku nie jest już hardcoded (`"Close"`),
  - używany jest klucz i18n:
    - `lib.player.modal_button_close`
- `Player:showConfirmationModal(...)`:
  - domyślne przyciski `Yes` / `No` zostały przepięte na klucze i18n:
    - `lib.player.modal_button_yes`
    - `lib.player.modal_button_no`
- Dodano bezpieczny helper Lua:
  - `getTranslationOrFallback(player, key, fallback)`
  - pobiera tłumaczenie z `Translator.getTranslation(...)` i robi fallback, gdy klucz/translator niedostępny.
- Usunięto martwy hardcoded fragment EN:
  - `baseMessage = "You have found a ..."` w `Player:canGetReward(...)` (zmienna nieużywana).
- `i18n/en/libs.json`:
  - dodano klucze EN:
    - `lib.player.modal_button_close`
    - `lib.player.modal_button_yes`
    - `lib.player.modal_button_no`

### Po co
- Kolejne teksty UI po stronie Lua są gotowe pod wielojęzyczność.
- Usunięto twarde EN ze wspólnych helperów modalnych, które są używane w wielu miejscach.

---

## 61) Walidacja po tym etapie
- Zweryfikowano JSON:
  - `python3 -m json.tool i18n/en/libs.json`
- Sprawdzono `git diff --check` dla:
  - `data/libs/functions/player.lua`
  - `i18n/en/libs.json`
- Potwierdzono użycia nowych kluczy:
  - `lib.player.modal_button_close`
  - `lib.player.modal_button_yes`
  - `lib.player.modal_button_no`
- Lokalny parser Lua niedostępny (`SKIP_LUA_PARSE`), więc walidację Lua wykonano przez diff + spójność kluczy.
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 62) Backlog / później (punkt 1)
- Zgodnie z decyzją: odkładamy na później temat
  - pełnego uzupełnienia loyalty title dla **offline** wpisów highscore.
- Aktualny stan:
  - loyalty title w highscore działa dla online postaci i jest lokalizowany per-locale odbiorcy.
- Plan na później:
  - dodać źródło loyalty title dla offline wpisów bez nadmiernego kosztu (np. precomputing/lekki cache/rozszerzenie query).

---

## 63) Kontynuacja prac (Questy: timeout boss-room bez hardcoded EN) - 2026-02-08

### Pliki
- `data/libs/functions/functions.lua`
- `data-otservbr-global/scripts/quests/cults_of_tibia/actions_bosses_levers.lua`
- `i18n/en/quests.json`

### Co zmieniono
- Rozszerzono helper `kickerPlayerRoomAfterMin(...)` o opcjonalne parametry:
  - `messageI18nKey`
  - `messageI18nArgs`
- Dodano wewnętrzną obsługę wysyłki:
  - jeżeli podany jest `messageI18nKey`, używane jest `sendLocalizedTextMessage(...)`,
  - w przeciwnym razie zachowany dotychczasowy fallback do `sendTextMessage(...)`.
- W `actions_bosses_levers.lua`:
  - zastąpiono 7 hardcoded wywołań EN komunikatu timeoutu boss-room zmiennymi:
    - `timeoutKickMessage` (fallback tekstu),
    - `timeoutKickMessageKey` (`quests.cults_of_tibia.boss_room_timeout_kick`).
- W `i18n/en/quests.json` dodano klucz:
  - `quests.cults_of_tibia.boss_room_timeout_kick`.

### Po co
- Najwyższy priorytet z listy questowej: usunięcie powtarzanego EN-only komunikatu z krytycznego flow quest boss-room.
- Zachowana pełna kompatybilność wstecz:
  - stare wywołania helpera bez klucza i18n nadal działają.

---

## 64) Kontynuacja prac (Items: locale-aware nazwa + pipeline eksportu klienta OTC) - 2026-02-08

### Pliki
- `src/items/item.hpp`
- `src/items/item.cpp`
- `src/lua/functions/items/item_functions.cpp`
- `src/creatures/players/player.cpp`
- `tools/i18n_pipeline.py`

### Co zmieniono
- Dodano API C++:
  - `Item::getNameLocalized(std::string_view locale) const`
  - tłumaczy nazwę przez `item.<id>.name` (z fallback do tekstu bazowego),
  - obsługuje też legacy namespace `items.<id>.name` dla kompatybilności.
- Lua `item:getName()` rozszerzone do:
  - `item:getName([player|string locale])`
  - dzięki temu skrypty mogą pobierać nazwę itemu w locale odbiorcy bez ręcznych obejść.
- Poprawiono key namespace w stash:
  - `Player::getLocalizedItemName(...)` używa teraz `item.<id>.name`,
  - pozostawiono fallback do `items.<id>.name` (legacy).
- Pipeline i18n (`tools/i18n_pipeline.py`) rozszerzony o etap eksportu klienta OTC:
  - wywołuje `tools/json_to_lua_locales.py --all`,
  - nowa konfiguracja:
    - `--client-locales-dir`
    - `--skip-client-export`
    - `--client-compact-keys`
  - to domyka temat „czy `otclient_modules.json` jest brane do paczki klienta” na poziomie pipeline.

### Po co
- Usunięto blokadę z listy Copilot dla itemów: brak locale-aware `Item::getName()` dostępnego dla warstwy skryptowej.
- Uspójniono nazewnictwo kluczy itemów (`item.*`) i zachowano bezpieczny fallback.
- Zabezpieczono workflow klienta OTC przed pomijaniem kategorii JSON (w tym `otclient_modules.json`) podczas eksportu locale.

---

## 65) Walidacja po tym etapie
- Zweryfikowano JSON:
  - `python3 -m json.tool i18n/en/quests.json`
- Zweryfikowano składnię Pythona:
  - `python3 -m py_compile tools/i18n_pipeline.py`
- Sprawdzono `git diff --check` dla:
  - `data/libs/functions/functions.lua`
  - `data-otservbr-global/scripts/quests/cults_of_tibia/actions_bosses_levers.lua`
  - `i18n/en/quests.json`
  - `src/items/item.hpp`
  - `src/items/item.cpp`
  - `src/lua/functions/items/item_functions.cpp`
  - `src/creatures/players/player.cpp`
  - `tools/i18n_pipeline.py`
- Potwierdzono, że w `cults_of_tibia` wszystkie 7 wywołań timeoutu używa już klucza:
  - `quests.cults_of_tibia.boss_room_timeout_kick`
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 66) Kontynuacja prac (Encounter broadcast: ścieżka localized bez łamania legacy) - 2026-02-08

### Pliki
- `data/libs/systems/encounters.lua`

### Co zmieniono
- Dodano nową metodę runtime:
  - `Encounter:broadcastLocalized(messageType, key, args, fallbackMessage)`
  - wysyła komunikat per-gracz przez `sendLocalizedTextMessage(...)`.
- Dodano nowy builder stage:
  - `Encounter:addLocalizedBroadcast(key, fallbackMessage, args, type)`
  - analogiczny do `addBroadcast(...)`, ale pod i18n.
- Zachowano pełną kompatybilność:
  - istniejące `Encounter:addBroadcast(...)` i `Encounter:broadcast(...)` działają bez zmian.

### Po co
- Encounter stage był jedną z dróg, która naturalnie omijała i18n i trzymała EN literal.
- Nowa metoda pozwala migrować questy etapami, bez masowego refaktoru istniejących raidów/encounterów.

---

## 67) Kontynuacja prac (Questy: kolejny batch EN -> i18n w encounter/soul war) - 2026-02-08

### Pliki
- `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_brain_head.lua`
- `data-otservbr-global/scripts/quests/primal_ordeal_quest/magma_bubble_fight.lua`
- `data-otservbr-global/scripts/quests/soul_war/moveevent-soul_war_entrances.lua`
- `i18n/en/scripts.json`

### Co zmieniono
- `actions_portal_brain_head.lua`:
  - wejściowy broadcast encounter przepięty na:
    - `encounter:addLocalizedBroadcast("scripts.actions_portal_brain_head.msg_5", ...)`
- `magma_bubble_fight.lua`:
  - 3 broadcasty EN (`entered volcano`, `volcano vibrates`, `take its revenge`) przepięte na `addLocalizedBroadcast(...)` z kluczami:
    - `scripts.magma_bubble_fight.msg_2`
    - `scripts.magma_bubble_fight.msg_3`
    - `scripts.magma_bubble_fight.msg_4`
- `moveevent-soul_war_entrances.lua`:
  - usunięto sklejanie tekstu z kluczem i liczbą (anti-pattern),
  - `msg_4` i `msg_5` teraz idą przez args do lokalizacji:
    - `scripts.moveevent-soul_war_entrances.msg_4` + `{ text }`
    - `scripts.moveevent-soul_war_entrances.msg_5` + `{ killCount, "20" }`
- `i18n/en/scripts.json`:
  - dodano:
    - `scripts.actions_portal_brain_head.msg_5`
    - `scripts.magma_bubble_fight.msg_2`
    - `scripts.magma_bubble_fight.msg_3`
    - `scripts.magma_bubble_fight.msg_4`
  - poprawiono format klucza:
    - `scripts.moveevent-soul_war_entrances.msg_5` (drugi placeholder `{1}` zamiast hardcoded `20`).

### Po co
- Usunięto kolejne realne EN-only komunikaty gracza w questach (nie nazwy potworów/ID techniczne).
- Naprawiono ścieżkę soul war, gdzie klucz i18n był wcześniej de facto obchodzony przez konkatenację.

---

## 68) Walidacja po tym etapie
- Zweryfikowano JSON:
  - `python3 -m json.tool i18n/en/scripts.json`
- Sprawdzono `git diff --check` dla:
  - `data/libs/systems/encounters.lua`
  - `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_brain_head.lua`
  - `data-otservbr-global/scripts/quests/primal_ordeal_quest/magma_bubble_fight.lua`
  - `data-otservbr-global/scripts/quests/soul_war/moveevent-soul_war_entrances.lua`
  - `i18n/en/scripts.json`
- Potwierdzono użycie nowych kluczy i metod (`addLocalizedBroadcast`, `broadcastLocalized`, `msg_5` z argami).
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).

---

## 69) Weryfikacja OTC (`otclient_modules.json`) i stan eksportu - 2026-02-08

### Co sprawdzono
- Porównano źródło i18n modułów OTC:
  - `i18n/en/otclient_modules.json` (1,987 kluczy)
- Ze stanem aktualnego artefaktu klientowego:
  - `testyy/data/locales/game_i18n_en.lua`

### Wynik
- Aktualny `game_i18n_en.lua` jest krótki (177 linii) i **nie zawiera** kluczy z `otclient_modules.json`.
- To oznacza, że artefakt klientowy jest niezsynchronizowany / historyczny (nieprzegenerowany pełnym eksporterem).

### Działanie naprawcze (workflow)
- W poprzednim etapie rozszerzono `tools/i18n_pipeline.py` o krok:
  - `tools/json_to_lua_locales.py --all`
- Dzięki temu przy uruchomieniu pipeline klucze z `otclient_modules.json` będą trafiać do paczek `game_i18n_<lang>.lua`.

### Po co
- Domknięcie punktu „czy instalka/pack bierze `otclient_modules.json`” na poziomie procesu build/export.
- Eliminacja cichego rozjazdu między serwerowym `i18n/*.json` a klientowym bundle locale.

---

## 70) Kontynuacja prac (Items: locale-aware nazwa także w opisie/look i ItemType API) - 2026-02-08

### Pliki
- `src/items/item.hpp`
- `src/items/item.cpp`
- `src/lua/functions/items/item_type_functions.cpp`

### Co zmieniono
- `Item::getNameDescription(...)`:
  - rozszerzono sygnaturę o `std::string_view locale` (domyślnie pusty),
  - `Item::getDescription(..., locale)` przekazuje locale dalej do `getNameDescription(...)`,
  - nazwa itemu w opisie/look korzysta teraz z lokalizacji (`item.<id>.name`) przez `resolveItemTypeName(...)` / `getNameLocalized(...)`.
- `ItemType:getName(...)` w Lua:
  - rozszerzono do wariantu:
    - `itemType:getName([player|string locale])`
  - dodano tłumaczenie po kluczu `item.<id>.name` z fallbackiem do `items.<id>.name` i finalnie do bazowej nazwy.

### Po co
- To domyka praktyczną część punktu „brak implementacji locale dla `Item::getName()`”:
  - nie tylko `Item:getName(...)`, ale też opis/look itemu i `ItemType:getName(...)` w skryptach respektują locale.
- Ułatwia dalszą migrację questów i UI, gdzie często operuje się na `ItemType` zamiast instancji `Item`.

---

## 71) Walidacja po tym etapie
- Sprawdzono `git diff --check` dla:
  - `src/items/item.hpp`
  - `src/items/item.cpp`
  - `src/lua/functions/items/item_type_functions.cpp`
  - oraz batcha questowego (`encounters.lua`, questy, `i18n/en/scripts.json`).
- Zweryfikowano JSON:
  - `python3 -m json.tool i18n/en/scripts.json`
- Potwierdzono użycia:
  - `Encounter:addLocalizedBroadcast(...)`
  - `Item::getNameDescription(..., locale)`
  - `itemType:getName([player|string locale])`
- Testów nie uruchamiano (zgodnie z ustaleniem projektowym).
