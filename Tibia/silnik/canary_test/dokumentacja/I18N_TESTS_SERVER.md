# I18N Smoke/Regression Tests (Canary Server)

Krótki zestaw testów do potwierdzenia, że serwerowa internacjonalizacja działa po zmianach w danych lub kodzie.

## Skrypty pomocnicze
- `python tools/i18n_extract_messages.py --roots data-otservbr-global src --out build/i18n/messages.json` – zbiera klucze z Lua/C++.
- `python tools/i18n_sync_messages.py --locale <lang> --filename system.json` – dopasowuje locale do bazy EN.
- `python tools/i18n_report.py --locales <lang> --csv-dir i18n/reports` – raport braków względem EN.

## Smoke test (manual/QA)
1. Uruchom serwer z `serverDefaultLocale = en` (config.lua) i zaloguj gracza z domyślnym locale EN. Sprawdź w logach brak ostrzeżeń "Missing translation".
2. Zmień locale gracza (np. `pl`) i powtórz logowanie. Zweryfikuj:
   - Nazwy przedmiotów: komenda/akcja pokazująca item tooltip/name ma tłumaczenie.
   - Komunikaty systemowe (błędne hasło, brak uprawnień, wiadomości serwera) są w danym języku.
   - Dialog NPC (przynajmniej 1 NPC) zwraca tekst w locale gracza.
   - Dialog NPC z konkatenacją (`npcHandler:say("..." .. var .. "...")`) wstawia argumenty poprawnie.
   - Dialog NPC z tablicą (`npcHandler:say({ ... })`) wysyła sekwencję i18n (`npcSayMultiple`) z poprawnym opóźnieniem.
   - Potwory: nazwa/description potwora i losowe `monster.voices` są lokalizowane (gdy `i18nKey` jest ustawiony).
   - Broadcast: globalny komunikat (np. server save) używa `Game.broadcastLocalizedMessage` i wyświetla tłumaczenie w locale gracza.
   - Skrypty: przykładowa akcja/quest z `player:sayLocalized` lub `sendLocalizedTextMessage` zwraca klucz i tłumaczenie.
3. Jeśli brak klucza, upewnij się, że następuje fallback do EN bez crasha; zanotuj brak w raporcie.

## Test formatowania
- Wymuś wiadomość z placeholderami (np. `%s` lub `{}` zależnie od użycia fmt) i podaj tyle argumentów, ile placeholderów; oczekuj poprawnie sformatowanego ciągu bez `fmt::format_error` w logach.

## Automatyczny sanity check (propozycja)
- Dodać test C++ (np. w `tests/i18n_translator_test.cpp`):
  - ustawia `searchPaths` na tymczasowy katalog z dwoma locale (en/pl),
  - ładuje oba locale,
  - sprawdza lookup istniejącego klucza, brakującego klucza (fallback), oraz format z argumentami,
  - weryfikuje, że brak pliku nie crashuje (zwraca key lub fallback).

## Raportowanie
- Po każdej aktualizacji danych/locale dołącz raport CSV z `i18n_report.py` do PR (lub jako artefakt CI).
- W opisie PR zapisz: lista dotkniętych języków, liczba brakujących kluczy przed/po, ewentualne fallbacki.

## TODO po integracji runtime (testy zablokowane)
- Spells: nazwa/words/desc w UI klienta po podpięciu kluczy i18n w runtime.
- Items: nazwy/opisy z `items.xml` po wprowadzeniu i18nKey lub Lua hooków (`Item:setLocalizedName/Description`).
- Chatchannels: lokalizowane nazwy kanałów po stronie serwera/klienta.
