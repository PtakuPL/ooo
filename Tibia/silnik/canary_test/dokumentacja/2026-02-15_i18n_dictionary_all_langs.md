# 2026-02-15 — i18n: rozszerzenie słowników na wszystkie języki

## Co zrobiono
- Rozszerzono domyślną listę języków w `tools/i18n_dictionary_materialize.py` z 10 języków do pełnego zestawu 53 języków.
- Przebudowano słowniki:
  - `i18n/status/simple_translations.json`
  - `i18n/status/word_translations.json`
  - `i18n/status/dictionary_materialize_summary.json`

## Ważne
- Wycofano wcześniejsze zmiany logiki w `i18n_worker_simple.sh` (powrót do stanu bazowego), aby zakres obejmował wyłącznie zwiększenie słowników.

## Efekt
- Materializacja słowników działa dla wszystkich języków obecnych w i18n.
