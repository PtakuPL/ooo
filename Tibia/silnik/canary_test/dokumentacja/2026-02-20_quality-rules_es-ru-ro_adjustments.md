# 2026-02-20 — Quality rules tuning (ES/RU/RO) + domain exemptions

## Cel
Zmniejszyć fałszywe odrzucenia i zbędne retry GT dla przypadków zgłoszonych na produkcji:
1. ES poprawne zdanie błędnie oznaczane jako `word_salad`.
2. RU mieszanie alfabetów (łacinka + cyrylica) i potrzeba transliteracji nazw własnych.
3. RO `identical_to_en` dla nazw opisowych (np. `Frost Troll`) nadal traktować jako błąd.

## Zmiany w `i18n_worker_simple.sh`

### 1) Zawężenie `word_salad` (false-positive)
- Dodano `_EN_FUNCTION_WORDS` + `_LANG_FUNCTION_FALSE_FRIENDS`.
- Dodano `_count_en_function_words(words, lang)` z wykluczaniem false-friendów dla języków łacińskich.
- `word_salad` (hard-gate i suspicious S23) wymaga teraz jednocześnie:
  - podwyższonego udziału EN function words,
  - oraz realnego overlapu EN-content (`>=2` wspólne słowa 4+).
- Efekt: zdania typu ES `Has derrotado...` nie są już odrzucane jako `word_salad`.

### 2) Cyrylica: transliteracja tylko nazw własnych
- Dodano `_auto_transliterate_cyrillic_proper_nouns(...)` i `_transliterate_latin_word_ru(...)`.
- Auto-fix (`_auto_fix_translation`) dla języków cyrylickich transliteruje tylko termy świata gry/nazwy własne.
- Dodano denylistę ról opisowych (`knight`, `sorcerer`, `familiar`, itp.), żeby NIE transliterować słów, które powinny być tłumaczone semantycznie.

### 3) Rozdział nazw własnych od opisowych
- W `_is_proper_noun_key(...)` dodano blokadę automatycznego exemptu dla słów opisowych (`knight/sorcerer/...`).
- Dzięki temu nazwy typu `Frost Troll` pozostają wymuszone do tłumaczenia (brak zgody na EN-copy).

### 4) Domenowe wyjątki `identical_to_en` (na start: demon)
- Dodano:
  - `_DOMAIN_IDENTICAL_EXEMPT_TERMS = {"demon", "demons"}`
  - `_is_domain_identical_exempt(key, en_value)`
- Wykorzystano w:
  - `detect_suspicious` (S3) — nie oznacza jako CRITICAL dla dopuszczonych wyjątków,
  - metrykach jakości cyklu (`identical_to_en_exempt`),
  - quality audit (`identical_to_en_exempt`).

## Walidacja
- `bash -n i18n_worker_simple.sh` — OK.
- `bash i18n_worker_simple.sh --update-status` — OK (status generuje się poprawnie).
- Testy scenariuszy (symulacja reguł):
  - ES przykład `Has derrotado...` => `word_salad=False`.
  - RU `Sorcerer` => brak transliteracji (wymaga tłumaczenia semantycznego).
  - `monster.*.name` + `Demon` => poprawny exempt domenowy.

## Ryzyka / Uwagi
- Exempt `demon` jest celowo wąski (tylko domeny + sufiksy `.name/.title/.desc`).
- Jeśli będzie potrzeba, listę można rozszerzyć o kolejne kontrolowane termy po obserwacji metryk.

## Następne kroki
1. Obserwacja 1-2 okien godzinowych: spadek odrzuceń ES/PL i mniejszy churn GT.
2. Dodać transliterację dla większej liczby nazw własnych RU (mapa aliasów city/boss), ale bez luzowania ról opisowych.
3. Ewentualnie dodać osobny raport `identical_to_en_exempt_by_term` dla pełnej transparentności.

---

## 2026-02-20 (late update) — Obszerna polityka terminów nieprzetłumaczalnych per język

Wdrożono dodatkową warstwę polityki per-język, aby przyspieszyć tłumaczenia i ograniczyć zbędne retry GT:

1. Dodano rozbudowany zbiór termów świata gry (`_NONTRANSLATABLE_WORLD_TERMS`) — miasta, bossy, lokacje, termy systemowe, nazwy świata Tibii.
2. Dodano tryby per język (`_LANG_EXEMPT_MODE`):
  - `keep` dla języków łacińskich (EN-copy może być traktowany jako exempt dla dozwolonych termów),
  - `transliterate` dla cyrylicy (`ru/uk/bg/sr/mk`) — EN-copy nie jest exemptem.
3. Dla cyrylicy uszczelniono przepływ:
  - termy świata i nazwy własne są transliterowane,
  - role opisowe (`knight/sorcerer/...`) pozostają na ścieżce tłumaczenia semantycznego (bez transliteracji),
  - surowe EN-copy w cyrylicy nie jest pomijane jako „gotowe”.
4. Exempt `identical_to_en` stał się językowo zależny (`_is_domain_identical_exempt(..., lang)`), co realizuje zasadę:
  - łacińskie języki: można zachować wybrane termy,
  - cyrylica: EN ma zostać usunięte z finalnego tekstu (transliteracja/tłumaczenie), nie przechodzi jako exempt.

Walidacja po update:
- `bash -n i18n_worker_simple.sh` — OK.
- `bash i18n_worker_simple.sh --update-status` — OK.

### Korekta po review (ten sam dzień)
- Cofnięto z listy `_NONTRANSLATABLE_WORLD_TERMS` termy zgłoszone jako tłumaczalne (m.in. `behemoth`, `dragon lord`, `warlock`, `hydra`, `cyclops`, `necromancer`, `vampire`, `minotaur`, `orc`, oraz `imbuement/prey/charms/runes/runestone/stamina/highscore/hotkey/loot`).
- Cofnięto też role opisowe (`paladin/sorcerer/druid/knight/familiar`) z exempt policy.
- Efekt: w języku polskim te słowa wracają na normalną ścieżkę tłumaczenia i nie są traktowane jako „nie tłumaczyć”.

### Auto-repair z suspicious_rejected.jsonl
- Dodano mechanizm backlogu napraw oparty o `i18n/status/suspicious_rejected.jsonl`.
- Worker buduje listę kluczy do wymuszonej naprawy per `(lang, json_file)` na bazie ostatnich wpisów i częstości wystąpień.
- Te klucze są przetwarzane nawet w strict/fast-mode (nie są już łatwo pomijane jako „done”).
- Domyślnie obejmuje wszystkie typy issue z `suspicious_rejected` (chyba że ustawiony filtr ENV).

Nowe ENV:
- `SUSPICIOUS_REPAIR_ENABLED` (domyślnie `true`)
- `SUSPICIOUS_REPAIR_LOOKBACK_LINES` (domyślnie `8000`)
- `SUSPICIOUS_REPAIR_MIN_HITS` (domyślnie `2`)
- `SUSPICIOUS_REPAIR_MAX_KEYS` (domyślnie `400`)
- `SUSPICIOUS_REPAIR_ISSUE_TYPES` (opcjonalny filtr, np. `identical_to_en,word_salad`)

Artefakt audytowy:
- `i18n/status/suspicious_rejected_backlog_latest.json` z listą wybranych kluczy, hit-count i top issue.

### Auto-cleanup suspicious_rejected po naprawie
- Dodano cleanup końca cyklu: jeśli klucz został skutecznie naprawiony (accepted translation), worker usuwa odpowiadające wpisy z `i18n/status/suspicious_rejected.jsonl` dla bieżącego `(lang, json_file, key)`.
- Cleanup działa po wszystkich ścieżkach sukcesu (`override`, `tm`, `simple`, `google_translate`, forced repairs).
- Operacja jest atomowa (tmp + `os.replace`) i loguje podsumowanie: liczba usuniętych wpisów oraz liczba naprawionych kluczy.

### Update: cleanup co X cykli + blokada dopisywania nowych rejectów
- Cleanup jest teraz harmonogramowany co `X` cykli (domyślnie co 3), z buforem pending kluczy:
  - plik stanu: `i18n/status/suspicious_rejected_cleanup_state.json`
  - cleanup uruchamia się gdy `cycle % X == 0` lub bufor pending przekroczy próg.
- Dodano tryb zapisu nowych rejectów (`SUSPICIOUS_REJECTED_WRITE_MODE`):
  - `append` — klasyczne dopisywanie do `suspicious_rejected.jsonl`
  - `suppress_known` — blokuje dopisywanie znanych kluczy
  - `suppress_all` (domyślnie) — nie dopisuje nowych wpisów, zamiast tego zapisuje zdarzenie do `suspicious_log.jsonl` z akcją `suppressed_rejected_write`.

Nowe ENV:
- `SUSPICIOUS_REJECTED_CLEANUP_EVERY` (domyślnie `3`)
- `SUSPICIOUS_REJECTED_CLEANUP_PENDING_THRESHOLD` (domyślnie `200`)
- `SUSPICIOUS_REJECTED_WRITE_MODE` (`append|suppress_known|suppress_all`, domyślnie `suppress_all`)

### Safeguard wydajności (po spadku tłumaczeń netto)
- Wymuszone `forced_suspicious_repair` działa teraz tylko dla kluczy rzeczywiście niedokończonych:
  - EN-copy,
  - placeholder (`[XX]`/`[TODO]`),
  - pusta wartość.
- Nie wymusza już reprocessingu stabilnych, poprawnie przetłumaczonych wpisów.
- Cel: ograniczyć przepalanie batchy na „already-good” key i zminimalizować spadki `Tłumaczeń netto`.
