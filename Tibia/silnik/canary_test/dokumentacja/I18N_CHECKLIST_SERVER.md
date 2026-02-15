# I18N Checklist (Canary Server)

Szybka lista kontrolna dla wdrażania/weryfikacji wielojęzyczności po stronie serwera.

## Dane i ścieżki
- [ ] Locale dostępne w jednym z katalogów (kolejność): `<DATA_DIRECTORY>/i18n` (dataPackDirectory), `data/i18n`, repo `i18n/`.
- [ ] Każdy locale ma spójny układ plików (np. `items.json`, `player.json`, `system.json`, `game.json`, `npcs.json`, `quests.json`).
- [ ] `i18n/en/*.json` traktowany jako baza; inne locale synchronizowane względem EN.

## Pokrycie języków
- [ ] Lista `supportedLocales()` w `src/utils/i18n/translator.cpp` zawiera wszystkie języki wymagane przez klienta (rozszerzona do 50+); w razie dodania nowego języka dodaj katalog i wpis na listę.
- [ ] Dodając nowy język, upewnij się, że katalog istnieje i ma minimalny zestaw kluczy bazowych.

## Konfiguracja i baza
- [ ] Kolumna `players.locale` istnieje, domyślnie `'en'`; indeks/constraint zgodny z listą języków.
- [ ] `config.lua` ma `serverDefaultLocale` (fallback) oraz poprawnie ustawione `dataPackDirectory` (jeśli używane paczki danych).
- [ ] Serwer zawsze wysyła/oczekuje UTF-8 w komunikatach do klienta.

## Narzędzia i synchronizacja
- [ ] `python tools/export_items_translations.py --locale en --locale <lang>` (items z XML → JSON, uzupełnia klucze).
- [ ] `python tools/i18n_extract_messages.py --roots data-otservbr-global src --out build/i18n/messages.json` (zbiera klucze z Lua/C++).
- [ ] `python tools/i18n_sync_messages.py --locale <lang> --filename system.json` (synchronizuje bazę EN z ekstraktem do docelowego języka).
- [ ] `python tools/i18n_report.py --locales <lang> --csv-dir i18n/reports` (raport pokrycia, status brakujących wpisów).
- [ ] `python tools/i18n_pipeline.py --locales pl es pt de` (pełny przepływ extract ➜ sync ➜ items ➜ report, aktualizuje `i18n/reports/` dla QA).

## Użycie w kodzie
- [ ] Wszystkie teksty wysyłane do gracza przechodzą przez `i18n::Translator::get/format` z kluczem; brak literali hardcode w `sendTextMessage`/`setMessage`/NPC dialog.
- [ ] Locale gracza jest ustawiane/przekazywane (np. z configu klienta lub pola konta) i używane jako pierwszy wybór; fallback do `fallbackLocale` gdy brak klucza.
- [ ] Przy formatowaniu tekstu używać placeholderów zgodnych z `fmt` (`{}`), a liczba argumentów odpowiada liczbie placeholderów.
- [ ] Do okien dialogowych używać `Player::sendLocalizedMessageDialog` (zastępuje `sendMessageDialog`) dla zgodności z locale gracza.

## Walidacja przed releasem
- [ ] Przepuść skrypt(y) raportujące, usuń brakujące klucze lub zaakceptuj fallback.
- [ ] Ręczny smoke test: logowanie gracza z locale EN i innym (np. PL), weryfikacja nazw przedmiotów/NPC/system messages.
- [ ] Sprawdź logi: brak ostrzeżeń "Missing translation"/"Failed to format translation" po starcie serwera.

## Koordynacja prac
- Agent (ten PR): dodane testy jednostkowe translatora (`tests/unit/i18n/translator_test.cpp`) oraz checklisty/wytyczne i18n.
- Inny agent: pełna internacjonalizacja danych (przedmioty/NPC/questy) i synchronizacja JSON względem EN.

## Notatki
- Dodanie nowego locale wymaga: katalogu w `i18n/<lang>`, wpisu w `supportedLocaleList`, danych w DB (jeśli walidujesz), oraz aktualizacji paczek danych (jeśli używane).
- Struktury JSON mogą być zagnieżdżone; w runtime dostępne przez kropki (np. `player.condition.poisoned`).
