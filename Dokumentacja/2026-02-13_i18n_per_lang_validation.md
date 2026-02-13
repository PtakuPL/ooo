# I18N: Walidacja per-język (Sekcja 6)

**Data:** 2026-02-13  
**Branch:** `feature/i18n-multilanguage`  
**Plik:** `i18n_worker_simple.sh`

---

## Co zaimplementowano

### 1. `validate_per_lang()` — inline walidacja nowych tłumaczeń

Funkcja w AUTOTRANSPY wywoływana po każdym `detect_suspicious()` (3 call-site'y: TM, simple, GT source):

- **V6** — Newline count mismatch (MEDIUM)
- **cyrillic_latin_mix** — >30% łacińskich znaków w języku cyrylicowym (HIGH)
- **cjk_ratio_anomaly** — stosunek długości poza zakresem 0.15–2.5 (MEDIUM)
- **rtl_insufficient** — <30% znaków RTL w tekście (HIGH)
- **wrong_script** — <40% expected script w exotic (HIGH)

Mapowanie grup:
- `LANG_SCRIPT_GROUP`: latin(33), cyrillic(5: bg,mk,ru,sr,uk), CJK(4: ja,ko,zh,zh-tw), RTL(2: ar,he), exotic(9: bn,el,hi,hy,ka,ml,ta,te,th)
- `EXPECTED_SCRIPTS`: bn=BENGALI, el=GREEK, hi=DEVANAGARI, hy=ARMENIAN, ka=GEORGIAN itd.

### 2. `run_full_lang_validation()` — cykliczny audyt

Bash function z osadzonym LANG_VALIDATION_PY heredoc. Uruchamiana co 50 cykli (`LANG_VALIDATION_INTERVAL`).

Validatory V1–V7:
| Validator | Opis | Severity |
|-----------|------|----------|
| V1 | Placeholder mismatch ({name}, %d) | CRITICAL |
| V2 | Length ratio <0.2 lub >5.0 | MEDIUM |
| V3 | Empty translation | LOW (early return) |
| V4 | Artifact (???, [TODO], FIXME) | HIGH |
| V5 | Pipe token mismatch (\|word\|) | CRITICAL |
| V6 | Newline count mismatch | MEDIUM |
| V7 | Command mismatch (''trade'') | MEDIUM |

### 3. Raporty

- `i18n/status/validation/{lang}_report.json` (×52)
- `i18n/status/validation/summary.json`
- Sekcja w I18N_STATUS.md z tabelami per-grupa skryptowa

### 4. Scoring

```
penalty = (critical * 3 + high * 1.5 + medium * 0.3 + low * 0.05)
score = max(0, min(100, 100 * (1 - penalty / translated_keys)))
```

---

## Wyniki testów

| Metryka | Wartość |
|---------|---------|
| Języki | 52 |
| avg_score | **98.8** |
| Zakres | 93.3 (RU) — 99.7 (PL) |
| latin avg | 98.9 |
| cyrillic avg | 97.7 |
| CJK avg | 99.0 |
| RTL avg | 99.0 |
| exotic avg | 99.0 |

## Bugfixy

1. **V7 false positives** — `CMD_RE` matchował angielskie kontrakcje (you're, don't) jako komendy gry → zmieniony z `'[^']+?'` na `''[^']+?''`
2. **V7 severity** — HIGH → MEDIUM
3. **V3_empty kaskada** — empty translations wywoływały V2 (ratio 0.0), V7 (brak komend) i script-specific → dodany early return
4. **"reports" directory** — katalog `i18n/reports/` był traktowany jako język → `_SKIP_DIRS` + `len(d) <= 6`
5. **Score formula** — penalty weights obniżone (CRIT 5→3, HIGH 2→1.5, MED 0.5→0.3, LOW 0.1→0.05), avg_score: 39.0 → 59.4 → **98.8**

## Status

✅ Sekcja 6 w pełni zaimplementowana i przetestowana. Oznaczona w I18N_WORKER_PLAN.md.
