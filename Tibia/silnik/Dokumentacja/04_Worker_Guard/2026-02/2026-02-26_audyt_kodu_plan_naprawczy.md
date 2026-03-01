# 🔍 Audyt kodu i18n_worker_simple.sh + i18n_guardian.sh — Plan naprawczy

**Data:** 2026-02-26  
**Pliki:** `i18n_worker_simple.sh` (26 064 linii), `i18n_guardian.sh` (1 624 linie)  
**Metoda:** Analiza statyczna + runtime, szukanie wzorców błędów  

---

## ✅ Naprawione w tej sesji

| # | Problem | Opis | Status |
|---|---------|------|--------|
| G-FIX1 | Guardian push → `git push origin master` z brancha feature | Zamiast `HEAD:master` guardian pushował lokalny `master` (setki commitów za) | ✅ Naprawione — przełączono na `push_status_snapshot()` |
| G-FIX2 | Guardian: `push_status_snapshot()` nigdy nie wywoływany | Funkcja zdefiniowana ale nieużywana; guardian pushował bezpośrednio z głównego repo | ✅ Naprawione — teraz to jedyna ścieżka push |
| G-FIX3 | Push fallback na re-clone | Gdy push failuje (diverged history) brak retry | ✅ Dodano re-clone + retry |
| W-FIX1 | [EN] prefix na kluczach {{ template }} | 4800+ kluczy szablonowych z `[EN] {{ value }}` zamiast `{{ value }}` | ✅ Naprawione skryptem fix_en_prefix.py |

---

## 🔴 CRITICAL — Do naprawienia jak najszybciej

### C1: `_is_domain_identical_exempt` — dwie rozbieżne implementacje
- **Lokalizacja:** AUTOTRANSPY L13776 vs QUALITY_AUDIT_PY L22515
- **Problem:** Translator (AUTOTRANSPY) ma wersję **restrykcyjną** (tylko `demon/demons`, wymaga `.name/.title/.desc`). Audit (QUALITY_AUDIT_PY) ma wersję **permisywną** (exempt dla większości items/monsters/spells). Powoduje to:
  - Translator flaguje nazwy przedmiotów jako "identical_to_en" → sztuczne guard_fail
  - Audit pomija te same klucze → underreporting problemów
- **Fix:** Zsynchronizować obie wersje — prawdopodobnie audit ma rację (nazwy game itemów nie powinny być tłumaczone)
- **Szacowany czas:** 30 min
- **Priorytet:** P1

### C2: Guardian — funkcje zdefiniowane WEWNĄTRZ `run_once()`
- **Lokalizacja:** L893–L1611 w i18n_guardian.sh
- **Problem:** 8 funkcji + Python heredocs re-parsowane co 30 sekund (daemon loop). Marnowanie CPU + pamięci.
- **Fix:** Przenieść definicje funkcji PRZED `run_once()` na top-level scope
- **Szacowany czas:** 20 min
- **Priorytet:** P2

### C3: Guardian — contract enforcement vs migration mode
- **Lokalizacja:** L1235-1268, L51, L813-818
- **Problem:** `GUARDIAN_ENFORCE_TRANSLATION_CONTRACT=true` wymaga `--translations-only` w cmdline workera. Ale tryby `migration`, `migration_only`, `hybrid` celowo pomijają `--translations-only`. Efekt: nieskończona pętla restartów przy tych trybach.
- **Fix:** Dodać świadomość trybu profilu do `worker_translation_contract_ok()`
- **Szacowany czas:** 15 min
- **Priorytet:** P2 (aktualnie tryb translations, ale bomb tykająca)

---

## 🟠 HIGH — Istotne problemy

### H1: `guard_fail` — 12 z 14 punktów NIE loguje do `recent_translations`
- **Lokalizacja:** L16131–L16598 w AUTOTRANSPY
- **Problem:** Tylko 1 z 6 `recent_translations.append()` niesie info o guard_fail. Pozostałe 12 inkrementacji `guard_fail += 1` nie mają odpowiadającego append → niewidoczne w "ostatnich kluczach"
- **Fix:** Dodać `recent_translations.append(...)` z `source: "guard_fail:{reason}"` przy każdym guard_fail
- **Szacowany czas:** 30 min
- **Priorytet:** P1

### H2: `_is_probably_nontranslatable_text` — rozbieżność AUTOTRANSPY vs QUALITY_AUDIT_PY
- **Lokalizacja:** AUTOTRANSPY L14902 vs QUALITY_AUDIT_PY L22534
- **Problem:** Wersja audit jest krótsza, brak detekcji game-language. Powoduje fałszywe flagi w audycie.
- **Fix:** Zsynchronizować obie wersje
- **Szacowany czas:** 20 min
- **Priorytet:** P2

### H3: Guardian — `pkill -9 -f` zabija za dużo procesów
- **Lokalizacja:** L1191 w i18n_guardian.sh
- **Problem:** `pkill -9 -f "i18n_worker_simple.sh"` zabija KAŻDY proces z tym stringiem w cmdline (vim, grep, cat...)
- **Fix:** Użyć PID z PID file zamiast `pkill -f`
- **Szacowany czas:** 5 min
- **Priorytet:** P2

### H4: Guardian — `exit 1` wewnątrz `run_once()` zabija daemon
- **Lokalizacja:** L1602 w i18n_guardian.sh
- **Problem:** `cd "$WORK_DIR" || exit 1` — exit terminuje cały daemon, nie tylko tę iterację
- **Fix:** Zmienić na `return 1`
- **Szacowany czas:** 2 min
- **Priorytet:** P2

### H5: Guardian — early return w contract-check pomija push
- **Lokalizacja:** L1547-1549
- **Problem:** Gdy contract check failuje → `return 0` → skip push dashboard → status nie aktualizowany na GitHub
- **Fix:** Przenieść push logic przed early return
- **Szacowany czas:** 10 min
- **Priorytet:** P2

### H6: Guardian — misleading indentation else/fi
- **Lokalizacja:** L1538-1594
- **Problem:** `else` indented jak nested statement — maintenance trap
- **Fix:** Un-indent `else` i `fi` do poziomu `if`
- **Szacowany czas:** 5 min
- **Priorytet:** P3

---

## 🟡 MEDIUM — Usprawnienia

### M1: 8 unquoted heredocs w workerze — ryzyko bash expansion
- **Lokalizacja:** L925, L1000, L6448, L7528, L8248, L8645, L11716, L12038
- **Problem:** `<< MARKER` zamiast `<<'MARKER'` — bash expanduje `$variables` wewnątrz Python code
- **Fix:** Zmienić na `<<'MARKER'` (single-quoted)
- **Szacowany czas:** 10 min
- **Priorytet:** P3

### M2: Dead code w guardianach — `list_available_profiles`, `STATUS_COMMIT_MIN_INTERVAL_SECONDS`
- **Lokalizacja:** L560-568, L30-31 w guardian
- **Problem:** Zdefiniowane ale nigdy nieużywane
- **Fix:** Usunąć nieużywany kod
- **Szacowany czas:** 5 min
- **Priorytet:** P3

### M3: Guardian — usunięcie `.git/index.lock` bez sprawdzenia
- **Lokalizacja:** L108 w guardian
- **Problem:** Może korupcja concurrent git operacji
- **Fix:** Sprawdzić wiek locka przed usunięciem (> 60s)
- **Szacowany czas:** 5 min
- **Priorytet:** P3

### M4: Guardian — `worker_running()` nie weryfikuje cmdline PID
- **Lokalizacja:** L1225-1233
- **Problem:** PID reuse → false positive (process exists ale to nie worker)
- **Fix:** Dodać `guardian_pid_matches_cmdline`
- **Szacowany czas:** 5 min
- **Priorytet:** P3

### M5: Guardian — `last_ts` non-numeric → arithmetic error
- **Lokalizacja:** L1599
- **Problem:** Jeśli plik z timestamp uszkodzony → bash error
- **Fix:** Sanitize z regex check
- **Szacowany czas:** 3 min
- **Priorytet:** P3

### M6: Guardian — `post_restart_sanity_check` czyta 8000 linii x15 razy
- **Lokalizacja:** L1107-1109
- **Problem:** Wydajność — skanuje 120k linii per sanity check
- **Fix:** Zmniejszyć `tail_lines` do 200
- **Szacowany czas:** 2 min
- **Priorytet:** P3

### M7: Worker — ~30 utility functions copy-paste przez heredocs
- **Lokalizacja:** Cały worker (atomic_write x4, split_langs x2, itp.)
- **Problem:** Dryft logiki, trudność utrzymania, ryzyko rozbieżności
- **Fix:** Ekstrakcja do wspólnego pliku Python (importowanego w heredocach) — DUŻE zadanie
- **Szacowany czas:** 2-4h
- **Priorytet:** P4 (refactoring backlog)

### M8: Guardian — Python `except Exception` nie łapie `SystemExit`
- **Lokalizacja:** L655-656, L728-729
- **Problem:** Dead code — `SystemExit` dziedziczy po `BaseException`, nie `Exception`
- **Fix:** Usunąć martwy string check
- **Szacowany czas:** 5 min
- **Priorytet:** P4

---

## 🟢 LOW — Nice-to-have

| # | Problem | Lokalizacja | Czas |
|---|---------|-------------|------|
| L1 | Unquoted command substitutions w guardian | L1229, L1542 | 5 min |
| L2 | `printf %b` z zmienną daną | L362 | 2 min |
| L3 | Brak `set -u` (typo w zmiennej → cichy empty) | Cały plik | 10 min |
| L4 | Hardcoded `HOME="/home/ptaku"` | L56 | 2 min |
| L5 | Brak `--help` w guardianie | — | 15 min |
| L6 | Dead code `pass #` w KWPY heredoc | worker L11552 | 2 min |
| L7 | GIT_TRACK_BRANCH `-z` check always false | L19-21 | 2 min |
| L8 | Daemon loop bez backoff na powtórne failures | L1624-1636 | 15 min |

---

## 📋 Sugerowany plan sesji

### Sesja 1 (szybkie fixy — ~1.5h)
1. ✅ C1: Sync `_is_domain_identical_exempt`
2. ✅ H1: Dodać guard_fail do `recent_translations` (12 brakujących punktów)
3. ✅ H2: Sync `_is_probably_nontranslatable_text`
4. ✅ H3: `pkill -f` → PID-based kill
5. ✅ H4: `exit 1` → `return 1`
6. ✅ H5: Push przed early return
7. ✅ H6: Fix indentation

### Sesja 2 (guardian refactor — ~1h)
1. ✅ C2: Przenieść funkcje przed `run_once()`
2. ✅ C3: Contract vs migration mode
3. ✅ M2: Usunięcie dead code
4. ✅ M3: Lock file age check
5. ✅ M4: PID cmdline verification
6. ✅ M5: Sanitize `last_ts`
7. ✅ M6: Zmniejszyć `tail_lines`

### Sesja 3 (worker cleanup — ~2h)
1. ✅ M1: Quote 8 heredocs
2. ✅ M7: Ekstrakcja utility functions (partial)
3. ✅ M8: SystemExit dead code
4. ✅ L1-L8: Drobne poprawki

---

## Statystyki audytu

| Kategoria | Worker | Guardian | Razem |
|-----------|--------|----------|-------|
| CRITICAL | 1 | 2 | 3 |
| HIGH | 2 | 4 | 6 |
| MEDIUM | 3 | 5 | 8 |
| LOW | 2 | 6 | 8 |
| **Razem** | **8** | **17** | **25** |
