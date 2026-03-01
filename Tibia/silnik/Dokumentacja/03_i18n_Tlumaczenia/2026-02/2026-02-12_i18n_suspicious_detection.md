# I18N Worker — Sekcja 3: Wykrywanie podejrzanych/trudnych tłumaczeń

**Data:** 2026-02-12  
**Branch:** `feature/i18n-multilanguage`  
**Plik:** `i18n_worker_simple.sh`

---

## Co zostało zrobione

### 1. Rozszerzenie `detect_suspicious()` — nowe kryteria

Dodano brakujące kryteria detekcji:

| Kryterium | Typ | Severity | Opis |
|-----------|-----|----------|------|
| S7 | `capitalization_mismatch` | LOW | EN zaczyna wielką literą, tłumaczenie małą (tylko dla języków łacińskich) |
| S10 | `incomplete_sentence` | LOW | EN kończy się `.!?`, tłumaczenie nie ma znaku końca zdania |

Wcześniej zaimplementowane (bez zmian):
- S1: placeholder_mismatch (CRITICAL)
- S2: length_extreme_ratio (HIGH)
- S3: identical_to_en (MEDIUM)
- S4: mixed_scripts (HIGH)
- S6: artifact_tokens (HIGH)
- S8: exploded_length (MEDIUM)
- S9: word_repetition (HIGH)
- S5: cross-lang duplicates — obsługiwane w `run_quality_audit()` (batch)

### 2. Auto-ekstrakcja nazw własnych Tibia

`ensure_tibia_proper_nouns()` przebudowana z hardcoded 48 → auto-generowane 1597 termów.

**Źródła:**
- Spell words (zaklęcia): 169 termów (`exura`, `utamo vita`, ...)
- Spell names: 764 termów (`Berserk`, `Animate Dead Rune`, ...)
- Quest names: 498 termów (`Pits of Inferno`, `Soul War`, ...)
- Raid names: 86 termów
- Core terms (miasta, klasy, bogowie): 92 termów ręcznie

**Plik:** `i18n/status/tibia_proper_nouns.json` (v2, auto_generated=true)

### 3. Rozszerzona ochrona `_protect_placeholders()`

Nowe wzorce ochronne (oprócz istniejących `{}`, `%s`, `|PIPE|`, `''cmd''`):

| Wzorzec | Przykład | Opis |
|---------|----------|------|
| HTML tagi | `<b>`, `</b>`, `<br>` | Ochrona formatowania |
| Escape seq | `\n`, `\t` | Znaki specjalne |
| HTML entities | `&amp;`, `&lt;` | Encje HTML |
| Komendy | `'/heal'` | Komendy gry w apostrofach |
| Nazwy własne | `Thais`, `Exura` | Auto z tibia_proper_nouns (>4 znaków, word boundary) |

**Kolejność ochrony:** nazwy własne NAJPIERW → regex patterns (unika kolizji z tokenami `__PH0__`)

### 4. Istniejące mechanizmy (bez zmian)

- `_enqueue_manual_review()` — kolejka do ręcznego przeglądu (>3 flagi suspicious)
- `apply_manual_review_approvals()` — aplikacja zatwierdzonych tłumaczeń
- `suspicious_log.jsonl` + `suspicious_rejected.jsonl` — logowanie

## Wyniki testów

17 cykli workera z GT + PL:
- 68 wpisów w suspicious_log (56 identical_to_en, 12 proper_noun, 1 capitalization)
- 0 odrzuconych (suspicious_rejected)
- 1597 termów w tibia_proper_nouns  
- Ochrona HTML/proper nouns w GT działa poprawnie

## Problemy

Brak problemów — wszystko przeszło testy pomyślnie.
