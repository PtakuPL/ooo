# I18N Worker — Naprawy i GT Cooldown Cycling

**Data:** 2026-02-14  
**Sesja:** Diagnostyka + naprawy + nowy mechanizm GT cooldown  
**Status:** ✅ Naprawy wdrożone | ✅ GT Cooldown Cycling wdrożony | ⏳ Test e2e

Legenda: ✅ done | 🟡 partial | ⏳ todo

## 1. Problemy znalezione i naprawione

| # | Problem | Status | Plik |
|---|---|---|---|
| 1.1 | SIGALRM nie przerywa SSL I/O | ✅ | `i18n_worker_simple.sh` ~L11066 |
| 1.2 | Indentation bug — blok for/while | ✅ | `i18n_worker_simple.sh` ~L13547 |
| 1.3 | Guardian zabija workera — niskie timeouty | ✅ | `i18n_guardian.sh` ~L1088 |
| 1.4 | Guardian restartuje po edycji skryptu | ✅ | `.worker_script_mtime` |
| 1.5 | NameError: `_gt_rate_limited` | ✅ | `i18n_worker_simple.sh` ~L13367 |

### 1.1 SIGALRM nie przerywa SSL I/O (KRYTYCZNE) ✅
- **Objaw:** Python process (PID 2829159) zawieszony na SSL socket do Google (142.250.109.101:443) przez 8+ minut
- **Przyczyna:** `_call_with_timeout()` używał `signal.SIGALRM` (POSIX), który nie może przerwać C-level SSL I/O z powodu PEP 475 (auto-retry interrupted syscalls)
- **Naprawa:** Zamiana na `threading.Thread(daemon=True)` + `threading.Event.wait(timeout=)` — niezawodnie przerywa blokujące I/O
- **Dodano:** `socket.setdefaulttimeout(30)` jako dodatkowe zabezpieczenie
- **Plik:** `i18n_worker_simple.sh` linie ~11066-11098

### 1.2 Indentation bug — blok for/while (KRYTYCZNE) ✅
- **Objaw:** `_gt_batch_idx += gt_batch_size` i blok "Zastosuj wyniki" (`for i` loop) były na złym poziomie wcięcia — poza pętlą `while _gt_batch_idx` zamiast wewnątrz
- **Skutek:** Przetwarzane były wyniki tylko OSTATNIEGO batcha, wcześniejsze tłumaczenia tracone
- **Naprawa:** Przesunięto linie 13547-13690 o 4 spacje w prawo (z 12 na 16 spacji)
- **Plik:** `i18n_worker_simple.sh`

### 1.3 Guardian zabija workera — zbyt niskie timeouty ✅
- **Objaw:** Guardian `HEARTBEAT_STUCK_SECONDS=420` (7 min) — worker tłumaczący 80 kluczy z items.json (16 batchy × 7-18s timeout) przekraczał ten limit
- **Naprawa:** Zwiększono timeouty:
  - `HEARTBEAT_STUCK_SECONDS`: 420 → 900 (15 min)
  - `HEARTBEAT_STALE_SECONDS`: 240 → 480 (8 min)
  - `HEARTBEAT_AGING_SECONDS`: 150 → 300 (5 min)
  - `STUCK_WINDOW_MINUTES`: 15 → 20
- **Plik:** `i18n_guardian.sh`

### 1.4 Guardian restartuje po edycji skryptu ✅
- **Objaw:** Guardian wykrywa zmianę mtime `i18n_worker_simple.sh` i restartuje workera po każdej naszej edycji
- **Naprawa:** Synchronizacja `.worker_script_mtime` po edycjach
- **Lekcja:** Przy edycjach worker script → zawsze `stat -c %Y i18n_worker_simple.sh > .worker_script_mtime`

### 1.5 NameError: `_gt_rate_limited` is not defined ✅
- **Objaw:** W trybie REPAIR (bez GT) zmienna `_gt_rate_limited` nie była inicjalizowana
- **Przyczyna:** Inicjalizacja była wewnątrz bloku `if use_google_translate and gt_pending`
- **Naprawa:** Dodano `_gt_rate_limited = False` wcześniej, na poziomie globalnym (obok `gt_guard_fail`)

## 2. Implementacja GT 429 → Natychmiastowy Fallback ✅

### 2.1 Mechanizm w Pythonie (AUTOTRANSPY heredoc)
- Przy wykryciu 429: natychmiastowy `defer` pozostałych kluczy → `_gt_rate_limited = True`
- Bez sleep'ów — worker nie czeka na nic
- Na końcu emituje sygnał `__GT_RATE_LIMITED__ cooldown=300`

### 2.2 Mechanizm w Bashu
- Parsowanie `__GT_RATE_LIMITED__` → zapis `.gt_rate_limit_until` (timestamp)
- Dispatcher check: przed `case "$MODE_TYPE"` sprawdza cooldown plik
- Jeśli aktywny → przełącza `AUTO_TRANSLATE` → `PRE_MIGRATION` z `MODE_EXTRA2="GT_COOLDOWN_FALLBACK"`
- Po cyklu AUTO_TRANSLATE gdy `GT_RATE_LIMITED_ACTIVE=true` → wykonuje PRE_MIGRATION skan + docs + validation

## 3. GT Cooldown Cycling ✅

| Element | Status | Szczegóły |
|---|---|---|
| Konfiguracja w workerze | ✅ | `GT_COOLDOWN_RETRY_INTERVAL=300`, `GT_COOLDOWN_FALLBACK_MODES`, rotacja |
| Sygnał `__GT_RATE_LIMITED__` w Python | ✅ | Emitowany do stdout gdy batch GT dostanie 429 |
| Bash parser sygnału | ✅ | Parsuje `__GT_RATE_LIMITED__`, ustawia `GT_RATE_LIMITED_ACTIVE=true` |
| Dispatcher z rotacją fallback | ✅ | Rotacja PRE_MIGRATION ↔ DOCUMENTATION po tablicy |
| Post-translate cooldown work | ✅ | Natychmiast wykonuje pracę fallback zamiast idle |
| `DOCUMENTATION` case w workerze | ✅ | Wywołuje `tools/i18n_generate_project_docs.py --batch` |
| Generator dokumentacji | ✅ | `tools/i18n_generate_project_docs.py` — 7935 plików, incremental |
| Wdrożenie (restart workera) | ✅ | Wdrożone 2026-02-14 22:57 UTC |
| Test end-to-end cyklu | ⏳ | Czeka na naturalny GT 429 w runtime |

## 4. Pliki zmienione

| Plik | Status | Zmiany |
|---|---|---|
| `i18n_worker_simple.sh` | ✅ | timeout, indentation, 429 fallback, `_gt_rate_limited` init, GT cooldown cycling, DOCUMENTATION case |
| `i18n_guardian.sh` | ✅ | heartbeat timeouts (STUCK 420→900, STALE 240→480, AGING 150→300) |
| `tools/i18n_generate_project_docs.py` | ✅ | NOWY — generator dokumentacji per plik (7935 plików inventory) |
| `docs/i18n/PRE_MIGRATION_AND_DOCUMENTATION_MODES_PLAN_2026-02-14.md` | ✅ | Zaktualizowane statusy PM, DOC, dodana sekcja GT Cooldown Cycling |
