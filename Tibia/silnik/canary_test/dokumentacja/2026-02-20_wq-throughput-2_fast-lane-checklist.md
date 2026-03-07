# 2026-02-20 — WQ-THROUGHPUT-2 (P0): fast-lane 25–30 + checklista 3 cykli

## Cel
Realizacja zadania planu kanonicznego:
- utrzymać `TRANSLATE_LIMIT` w bezpiecznym paśmie fast-lane `25–30` (domyślnie `30`),
- po zmianie limitu uruchamiać checklistę kontrolną 3 kolejnych cykli (`translated`, `guard_fail`, `strict_skipped_done`).

## Zmiany
Plik:
- `canary_test/i18n_worker_simple.sh`

Wdrożone elementy:
1. **Bezpieczne pasmo limitu AUTO**
   - dodano parametry:
     - `FAST_LANE_SAFE_MIN` (default `25`),
     - `FAST_LANE_SAFE_MAX` (default `30`),
     - `FAST_LANE_SAFE_DEFAULT` (default `30`).
   - domyślny `TRANSLATE_LIMIT` ustawiono na `30`.
   - dodano funkcje normalizacji i clampu:
     - `normalize_fast_lane_bounds`,
     - `clamp_translate_limit_fast_lane`.

2. **Wymuszenie clampu przy runtime commands**
   - komenda `BATCH:<N>`:
     - `N` jest clampowane do zakresu `25–30`,
     - loguje `request -> effective`,
     - zapisuje efektywny limit do `worker_config.json`.

3. **Checklista 3 cykli po zmianie limitu**
   - dodano artifact: `i18n/status/translate_limit_checklist.json`.
   - po `BATCH:<N>` inicjowany jest tracker:
     - `status=in_progress`, `checks_required=3`, `checks_done=0`.
   - po każdym zapisie guard report aktualizowany jest postęp checklisty:
     - rejestruje: `cycle`, `lang`, `json_file`, `translated`, `guard_fail`, `strict_skipped_done`, `guard_fail_rate_pct`.
   - po 3 wpisach tracker przechodzi na `status=completed`.

4. **Widoczność w dashboardzie**
   - `I18N_STATUS.md` (sekcja „Ta godzina”) pokazuje:
     - `Checklist limitu (3 cykle)`,
     - `Ostatnie checki limitu`.

## Walidacja
- `bash -n i18n_worker_simple.sh` — OK.
- Test live command: `.worker_command` z `BATCH:999`:
  - log runtime: `request=999 -> effective=30 (safe range 25-30)`.
- `i18n/status/translate_limit_checklist.json`:
  - start: `in_progress 0/3`,
  - finalnie: `completed 3/3`.
- `I18N_STATUS.md` zawiera nowe wiersze checklisty.

## Uwagi
- Mechanizm nie dotyka specjalnych limitów rund naprawczych (`repair_identical_bonus_round`), które mają własny tuning.
- Kolejny naturalny krok z planu: `WQ-THROUGHPUT-3` (krokowe strojenie `GT_BATCH_SIZE/GT_DELAY` z progowym rollbackiem jakości).
