# I18N Worker — Monitoring Jakości Tłumaczeń

**Data:** 2026-02-12  
**Dotyczy:** `i18n_worker_simple.sh`  
**Sekcja planu:** Punkt 2 z I18N_WORKER_PLAN.md

## Co zrobiono

### 1. Quality metrics w AUTOTRANSPY
- Po każdym cyklu tłumaczenia AUTOTRANSPY oblicza metryki jakości:
  - `avg_en_len` / `avg_translated_len` / `length_ratio` — ratio długości
  - `source_breakdown` — ile z TM, SIMPLE, WORD, Google Translate
  - `identical_to_en` — ile tłumaczeń identycznych z EN
  - `very_short_translations` / `very_long_translations` — anomalie
- Metryki zapisywane do `i18n/status/quality_report.jsonl` (1 linia per cykl)
- Ostrzeżenia `QUALITY_WARNINGS` gdy: ratio <0.5 lub >3.0, podejrzane >5, GT fail rate >20%
- Nowa linia `__QUALITY__` w output'cie do parsowania przez bash

### 2. Quality dashboard per-język
- Plik `i18n/status/quality_dashboard.json` aktualizowany co cykl
- Per-język: `quality_score` (0–100), `cycles`, `total_suspicious`, `total_rejected`, `total_gt_guard_fail`
- Score = rolling average z (ratio_score + reject_score) / 2

### 3. Bash wrapper rozszerzony
- auto_translate_keys() parsuje `__QUALITY__` i `QUALITY_WARNINGS` z output'u Python
- Loguje ostrzeżenia do stderr z kolorami

### 4. Cykliczny audyt QUALITY_AUDIT_PY
- Nowa funkcja bash `run_quality_audit()` uruchamiana co 10 cykli (QUALITY_AUDIT_INTERVAL)
- Python heredoc QUALITY_AUDIT_PY analizuje:
  - Ostatnie 200 wpisów z quality_report.jsonl
  - Ostatnie 100 wpisów z translation_recent_report.jsonl
  - Persistent length anomaly per-język
  - High reject rate / GT fail rate
  - Cross-language duplicate translations (ten sam tekst w 4+ językach)
- Raporty: `quality_audit_latest.json` + `quality_audit_history.jsonl`
- Automatyczne zmniejszenie batch do 5 przy CRITICAL issues

### 5. Dashboard jakości w I18N_STATUS.md
- Nowa sekcja "🔬 Jakość Tłumaczeń" z tabelą per-język
- Ikony: 🟢 (≥90) / 🟡 (≥70) / 🟠 (≥50) / 🔴 (<50)
- Ostatni audyt z podsumowaniem severity + top problemy

### 6. Integracja
- `run_quality_audit "$CYCLE"` wywoływane po każdym AUTO_TRANSLATE w main loop

## Pliki statusowe
- `i18n/status/quality_report.jsonl` — raporty per-cykl
- `i18n/status/quality_dashboard.json` — dashboard per-język
- `i18n/status/quality_audit_latest.json` — ostatni audyt
- `i18n/status/quality_audit_history.jsonl` — historia audytów

## Problemy
- Brak — implementacja przebiegła bez problemów
- Bash syntax check: OK
- Python unit test: OK
