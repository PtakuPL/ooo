# Implementacja trybu DOCUMENTATION w i18n worker — 2026-02-15

## Co zostało zrobione

### 1. Tryb DOCUMENTATION w workerze (`i18n_worker_simple.sh`)
- Dodano akceptację komend `DOCUMENTATION`, `DOCUMENTATION:<batch>`, `DOCINDEX` w regex walidacji (2 miejsca)
- Dodano handlery komend ustawiające `MODE_TYPE="DOCUMENTATION"` z odpowiednimi parametrami
- Dodano dispatcher `DOCUMENTATION)` case z pełnym pipeline:
  - Wywołuje `python3 tools/i18n_generate_project_docs.py --batch N`
  - Parsuje metryki (processed/total/errors/cursor)
  - Aktualizuje `i18n_global_stats.json`
- Dodano live display w rendererze statusu (Python embedded) — pokazuje cursor/total/remaining/errors/%
- Dodano ikony `"DOCUMENTATION": "📄"` w obu mapach ikon
- Dodano opis `"DOCUMENTATION": "Generowanie dokumentacji projektu"` w work_description_map
- Dodano sekcję DOCUMENTATION w szablonie I18N_STATUS.md z tabelą `doc_section_table`
- Dodano do help text

### 2. GT Cooldown z rotacją PRE_MIGRATION ↔ DOCUMENTATION
- Przepisano `gt_cooldown_do_fallback_work()` z rotacją trybów
- Konfiguracja: `GT_COOLDOWN_FALLBACK_MODES=("PRE_MIGRATION" "DOCUMENTATION")`
- Stan rotacji w pliku `.gt_cooldown_rotation` (indeks 0/1)
- Przy GT 429 worker automatycznie przełącza się między skanowaniem pre-migration a generowaniem dokumentacji

### 3. Narzędzie docs generator (`tools/i18n_generate_project_docs.py`)
- Dodano flagę `--index-only` — przebudowuje INDEX.md i index.json bez przetwarzania nowych plików
- Używane przez komendę `DOCINDEX`

### 4. Skaner pre-migration (`tools/i18n_pre_migration_scan.py`)
- Ponownie dodano kategorię `documentation` (utracona przez guardian git pull)
- `DOCUMENTATION_PATTERNS`: heading, bullet, table_cell, paragraph
- `CATEGORY_DEFS["documentation"]`: roots=(docs, Dokumentacja, data-*), extensions=(.md, .txt, .rst)

### 5. Wrapper komend (`worker_command.sh`)
- Dodano subkomendy: `documentation [N]`, `docindex`, `premig [cat|all]`
- Dodano fallback passthrough dla raw komend workera

## Testy
- `DOCUMENTATION:5` → processed=23→28, total=7975→7976, errors=0 ✅
- `DOCINDEX` → index rebuilt (28 entries) ✅
- `documentation` category scanner → 12230 hits / 934 files ✅
- `bash -n` syntax validation → OK ✅

## Problemy napotkane
1. **Guardian git pull** nadpisywał lokalne edycje — rozwiązano przez natychmiastowy commit + push po każdej edycji
2. **`--index-only` flag missing** — nie był zaimplementowany w i18n_generate_project_docs.py, dodano

## Commity
- `e79052d17` — feat(i18n): implement DOCUMENTATION mode in worker + scanner documentation category
- `ab19ba75e` — feat(docs): add --index-only flag to i18n_generate_project_docs.py
