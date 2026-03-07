# I18N Worker: Wyłączenie translations-only + PRE_MIGRATION + GT fallback

**Data:** 2026-02-15  
**Sesja:** Kontynuacja prac nad workerem i18n  

## Problem

Worker i18n działał z flagą `--translations-only`, która była **tymczasowa** (dodana aby skupić się wyłącznie na tłumaczeniach). Flaga ta blokowała:

1. **PRE_MIGRATION** — skany kodu źródłowego szukające stringów do migracji
2. **IDLE full cycle** — dokumentacja, raporty, walidacja pełna
3. **Wymuszone komendy** — nawet `PREMIG:all` via `.worker_command` było nadpisywane przez check `translations_only` (linia ~21160)

Dodatkowo nie było sposobu aby wyłączyć `--translations-only` bez restartowania workera z innymi argumentami.

## Wykonane zmiany

### 1. Forced commands omijają translations-only (linia ~21160)

**Przed:**
```bash
if [ "$TRANSLATIONS_ONLY" = "true" ] && [ "$MODE_TYPE" != "AUTO_TRANSLATE" ] && [ "$MODE_EXTRA2" != "SYNC" ]; then
```

**Po:**
```bash
if [ "$TRANSLATIONS_ONLY" = "true" ] && [ "$MODE_TYPE" != "AUTO_TRANSLATE" ] && [ "$MODE_EXTRA2" != "SYNC" ] && [ "$MODE_EXTRA" != "FORCED" ]; then
```

Dzięki temu komendy wymuszone (PREMIG, FORCE, IDLE itp.) z `MODE_EXTRA=FORCED` omijają blokadę translations-only.

### 2. Runtime config: translations_only w worker_config.json

Dodano obsługę klucza `translations_only` w `load_worker_config()`:

- **Python config loader** — dodano `"translations_only": None` do defaults, emituje `CFG_TRANSLATIONS_ONLY=true/false` (puste = nie nadpisuj)
- **Bash apply** — jeśli `CFG_TRANSLATIONS_ONLY` jest ustawione i różne od bieżącej wartości, nadpisuje `TRANSLATIONS_ONLY`

Teraz można zmieniać flagę runtime:
```bash
echo "SET:translations_only=false" > .worker_command
```

### 3. Wyłączenie flagi

Sekwencja komend:
1. `echo "SET:translations_only=false" > .worker_command` — zapisanie do config
2. `echo "RESTART" > .worker_command` — restart workera z nowym kodem

Worker po restarcie:
- CLI nadal przekazuje `--translations-only` (z WORKER_ORIGINAL_ARGS)
- Ale `load_worker_config()` nadpisuje `TRANSLATIONS_ONLY=false` z configu
- Log potwierdza: `⚙️ Config reload: limit=80 translations_only=false`

## Weryfikacja

### PRE_MIGRATION działa:
```
CYKL #1  → PRE_MIGRATION | Kategoria: scripts  | 11 plików
CYKL #4  → PRE_MIGRATION | Kategoria: spells   | 4 pliki
CYKL #5  → PRE_MIGRATION | Kategoria: talkactions | 3 pliki
CYKL #6  → PRE_MIGRATION | Kategoria: creaturescripts | 2 pliki
CYKL #9  → PRE_MIGRATION | Kategoria: events   | 1 plik
```

Worker naturalnie cyklicznie przechodzi przez kategorie PRE_MIGRATION.

### GT Rate-Limit Fallback:
Mechanizm jest poprawnie zaimplementowany:
1. Python wykrywa rate-limit → `gt_rate_limited=1` w `__AUTO_RESULT__`
2. Bash parsuje → ustawia `GT_RATE_LIMITED_COOLDOWN_UNTIL` = now + 300s
3. Dispatch → sprawdza cooldown → wywołuje `gt_cooldown_do_fallback_work()`
4. Fallback: repair identical (bez GT) → quality audit → I18N_STATUS.md → sleep resztę

**Status:** Mechanizm nigdy nie był trigggerowany — darmowy tier GT wystarcza przy obecnym obciążeniu (`gt_rate_limited=0` we wszystkich wynikach). Poprawność kodu zweryfikowana przez review.

## Zmodyfikowane pliki

- `i18n_worker_simple.sh`:
  - Linia ~21160: dodanie `&& [ "$MODE_EXTRA" != "FORCED" ]`
  - Linia ~14305: dodanie `"translations_only": None` do defaults Python
  - Linia ~14343: dodanie emisji `CFG_TRANSLATIONS_ONLY`
  - Linia ~14447: dodanie bloku apply `translations_only` w bash

## Worker PID

- Stary PID: 3690622 (zatrzymany przez RESTART)
- Nowy PID: 3781689 (z nowym kodem, translations_only=false z configu)
