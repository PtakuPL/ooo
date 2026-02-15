# I18N Translation First — Start Checklist (2026-02-13)

## Cel dnia
Ustabilizować tryb tłumaczeń PL/ES i uruchomić egzekwowanie hard gate kategorii bez regresji statusu.

## Blok A — Start operacyjny (must-do)
1. ✅ Potwierdzić `required_languages` z aktywnego `guardian_profile.json`. **DONE** — `langs: pl,es`.
2. ✅ Ustawić i zapisać progi runtime (stuck/no-progress/cooldown/TTL) z planu kanonicznego. **DONE** — `worker_config.json` sekcja `thresholds`.
3. ✅ Włączyć rejestrowanie `net_effective_translated` w statusie cyklu. **DONE** — widoczne w header I18N_STATUS.md i KPI Dashboard.
4. ✅ Potwierdzić, że status sekcji ma `active|inactive` + `freshness`. **DONE** — 6 sekcji z META/LIVE/MIGRATION/TRANSLATION/QUALITY/HISTORY.

## Blok A.1 — Guard fixes (dodatkowe, zrealizowane)
1. ✅ GAME_COMMANDS whitelist w `_extract_command_tokens()` — guard_fail_rate 10.6% → 3.5%.
2. ✅ Slash-command regex: wykluczanie URL-i i ścieżek plików.
3. ✅ `worker_config.json`: `focus_lang=""`, `use_gt=true`.
4. ✅ `guardian_profile.json`: `translations_pl_es` z poprawnymi flagami.

## Blok B — Tryb tłumaczeń (must-do)
1. Wdrożyć deterministyczną kolejkę `category -> lang -> file`.
2. Dodać `translation done contract` przed oznaczeniem klucza jako done.
3. Włączyć retry policy per reason (`command`, `quality`, `shape`, `provider_error`).
4. Wymusić balans cykli ES >= 35% dla profilu `pl,es`.

## Blok C — Walidacja (go/no-go)
1. 6h obserwacji: `pending_skip_share < 35%`.
2. 6h obserwacji: `no_progress_rate < 25%`.
3. Brak nieuprawnionego switchu kategorii.
4. Brak stale sekcji statusu > 2 cykle.

## Blok D — Decyzja po pierwszym oknie
- Jeśli wszystkie warunki są spełnione: przejście do P1.
- Jeśli którykolwiek warunek nie jest spełniony: pozostajemy w P0 i naprawiamy wyłącznie tłumaczenia/quality.

## Źródła kanoniczne
- `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`
- `docs/i18n/I18N_CPP_H_SEMANTIC_DOC_SYSTEM_PLAN_2026-02-13.md`
