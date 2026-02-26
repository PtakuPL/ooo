# 2026-02-15 — PL 3k + rozszerzenie słowników na wszystkie języki

## Zakres
- Dodano mechanizm gwarantujący minimum 3000 wpisów łącznych dla języka polskiego (simple + word).
- Następnie przebudowano słowniki dla pełnej listy języków.

## Zmiany techniczne
- Zmieniono generator: `tools/i18n_dictionary_materialize.py`
  - nowy parametr CLI: `--min-pl-combined` (domyślnie 3000),
  - nowa funkcja rozszerzająca słownik PL do progu minimalnego,
  - dodatkowe pola w summary: `pl_min_combined_target`, `pl_combined_count`, `pl_added_for_target`.

## Wynik po materializacji
- `pl_combined_count`: 3000
- `pl_added_for_target`: 583
- wygenerowane słowniki: `i18n/status/simple_translations.json`, `i18n/status/word_translations.json`
- raport: `i18n/status/dictionary_materialize_summary.json`
