# Fix: Coverage calculation bug + quest translation unblock

**Data:** 2025-02-26
**Problem:** Worker raportował coverage=100% dla plików z tysiącami kluczy identycznych z EN.
Np. PL/questlog.json: 1918 kluczy, 1814 identycznych z EN, realnie przetłumaczonych 104 (5.4%), ale DONE_CONTRACT mówił "SPEŁNIONY ✅ (coverage=100.0%)".

## Przyczyny

### 1. Błąd w obliczaniu coverage (linia ~17108)
**Stary kod:**
```python
real_translations = sum(1 for k, v in lang_data.items() 
    if k in en_data and not str(v).startswith(f"[{target_lang.upper()}]"))
```
Sprawdzał tylko prefix `[PL]` — klucze identyczne z EN (np. "The Hidden Seal" = "The Hidden Seal") były liczone jako "przetłumaczone".

**Nowy kod:** Klucze identyczne z EN są liczone jako przetłumaczone TYLKO jeśli to proper noun (`_is_proper_noun_key()`) lub game-nontranslatable (`_is_game_nontranslatable()`). W przeciwnym razie — nie liczy się jako tłumaczenie.

### 2. Heurystyka "game-language phrases" zbyt agresywna (linia ~15001)
`_is_probably_nontranslatable_text()` blokowała quest names jak:
- "Mission 01: Something Rotten" → blocked as "technical token" (digits)
- "Sea of Light" → blocked as "game-language phrase" (≤3 words, no function words)
- "Dwarven Armor Quest" → blocked similarly

**Fix A:** Token check: dodano warunek `len(_alpha_tokens) < 3` — jeśli tekst ma ≥3 czysto-alfabetyczne tokeny, to nie jest identyfikator techniczny.

**Fix B:** Game-language check: rozszerzono `_basic_en_nontrans` z ~60 function words → ~300+ words (function + content + game-specific). Teraz blokuje tylko prawdziwe fikcyjne frazy językowe gry.

### 3. Usunięto stare done_contracts
Usunięto 56 stałych kontraktów dla plików z fałszywym 100% coverage:
- questlog.json (13 języków)
- achievements.json, html.json, raids.json, spells.json (po ~10 języków)

## Dotknięte pliki (PL)
| Plik | Fałszywe coverage | Realne tłumaczenia | Identyczne z EN |
|------|-------------------|--------------------|--------------------|
| questlog.json | 100.0% | 5.4% | 1814/1918 |
| achievements.json | 100.0% | 52.8% | 495/1048 |
| html.json | 100.0% | 51.1% | 731/1495 |
| raids.json | 100.0% | 43.2% | 155/273 |
| spells.json | 100.0% | 51.3% | 747/1534 |

## Efekt
Po restarcie worker automatycznie:
1. Obliczy prawidłowe coverage (np. questlog → ~5.4% zamiast 100%)
2. Nie utworzy DONE_CONTRACT dopóki coverage < 95%
3. Priorytetowo przetłumaczy ~1700+ kluczy questlog (zamiast 10 na batch)
4. Te same fixy dotyczą wszystkich 11 języków

## Zmienione pliki
- `i18n_worker_simple.sh` — coverage calculation, `_is_probably_nontranslatable_text()` (3 kopie), `_is_nontranslatable_tier()`
