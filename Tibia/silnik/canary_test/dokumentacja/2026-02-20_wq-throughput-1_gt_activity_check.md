# 2026-02-20 — WQ-THROUGHPUT-1 (P0): check aktywności GT w oknie 1h

## Zakres
Zrealizowano pierwszy task z planu kanonicznego (`docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`):
- dodanie operacyjnego checku, czy Google Translate jest realnie aktywny w bieżącym oknie godzinowym,
- publikacja metryki do artefaktów statusowych i dashboardu Markdown.

## Zmiany
Plik:
- `canary_test/i18n_worker_simple.sh`

Wdrożone:
1. Dodano odczyt `translation_recent_report.jsonl` w oknie strict 1h.
2. Dodano liczenie:
   - `gt_translated` (liczba wpisów przetłumaczonych przez źródło `gt` / `google_translate`),
   - `gt_active` (`gt_translated > 0`).
3. Dodano pola do `i18n/status/strict_hourly_window_latest.json`:
   - `gt_translated`,
   - `gt_active`.
4. Dodano widoczność w `I18N_STATUS.md` (sekcja „Ta godzina”):
   - „GT aktywny (1h)”,
   - „GT tłumaczeń (1h)”.

## Walidacja
- `bash -n i18n_worker_simple.sh` — OK.
- `bash i18n_worker_simple.sh --update-status` — OK.
- Potwierdzono obecność pól `gt_active` i `gt_translated` w `strict_hourly_window_latest.json`.
- Potwierdzono obecność nowych linii w `I18N_STATUS.md`.

## Uwagi
- Metryka opiera się na rzeczywistych wpisach `entries[*].source` w `translation_recent_report.jsonl`, więc odróżnia tryb włączonego GT od realnej pracy GT.
- To domyka część kryterium sukcesu dla `WQ-THROUGHPUT-1` (widoczny check operacyjny GT).
