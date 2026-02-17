# Sekcja 8 P1: Optymalizacja wydajności — Adaptive Batch + Parallel Langs

**Data:** 2026-02-13  
**Plik:** `i18n_worker_simple.sh`  
**Sekcja planu:** 8.3 + 8.4

---

## Co zrobiono

### 8.3 Adaptive Batch Tuning

Automatyczne dostosowywanie rozmiaru batcha tłumaczeń na podstawie historii guard_fail_rate:

- **Zmienne konfiguracyjne:**
  - `ADAPTIVE_BATCH_ENABLED=true` (wyłącz: `--no-adaptive-batch`)
  - `ADAPTIVE_BATCH_DEFAULT=20` — domyślny batch kluczy/cykl
  - `ADAPTIVE_BATCH_MIN=5` / `ADAPTIVE_BATCH_MAX=50` — zakres adaptacji
  - `ADAPTIVE_BATCH_WINDOW=10` — ile ostatnich cykli analizować
  - `ADAPTIVE_BATCH_HIGH_THRESHOLD=20` / `LOW_THRESHOLD=5` — progi fail rate

- **Logika:**
  - `guard_fail_rate > 20%` → zmniejsz batch o 25%
  - `guard_fail_rate < 5%` → zwiększ batch o 25%
  - W normie → utrzymaj poprzedni batch
  - `GT_BATCH_SIZE` automatycznie ≤ batch kluczy

- **Stan:** `i18n/status/adaptive_batch_state.json`
- **CLI override:** `--translate-limit N` ma priorytet nad adaptive

### 8.4 Parallel Language Processing

Tłumaczenie wielu języków w jednym cyklu zamiast jednego:

- **Zmienna:** `PARALLEL_LANGS_PER_CYCLE=3` (konfiguracja: `--parallel-langs N`)
- Po przetworzeniu głównego targetu, worker wybiera N-1 dodatkowych języków
- Warunek: działa tylko w `--translations-only` (tryb strict)
- Detekcja pętli: stop jeśli selector zwraca ten sam język lub IDLE
- Metryki per język w `translation_guard_report.jsonl`

## Wynik testu

```
📊 Adaptive batch: keys=15 gt_batch=15 fail_rate=34.4% (decrease_high_fail_rate=34.4%)
🔀 Parallel [2/3]: es/monsters.json (3085 kluczy)
```

- Adaptive poprawnie redukuje batch przy wysokim fail rate
- Parallel poprawnie przełącza na inny język po primary

## Status

Sekcja 8 kompletna (P0 + P1). Cały plan I18N_WORKER_PLAN.md — wszystkie sekcje 2-8 ✅.
