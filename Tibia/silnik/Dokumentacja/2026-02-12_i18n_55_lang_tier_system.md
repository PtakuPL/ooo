# I18N: Plan obsługi 55 języków — System tierów (Sekcja 5)

**Data:** 2026-02-12  
**Branch:** `feature/i18n-multilanguage`  
**Plik:** `i18n_worker_simple.sh`

---

## Co zaimplementowano

### 1. System tierów językowych

Konfiguracja w zmiennych bash na górze workera:

```bash
TIER1_LANGS="pl es"         # cel: 90%, waga: ×4
TIER2_LANGS="de pt ru tr fr it"  # cel: 50%, waga: ×2
TIER3 = reszta (40 języków)      # cel: 30%, waga: ×1
```

### 2. Tier-weighted interleaving

W strict selector (`select_auto_translate_target_strict`):
- Kandydaci grupowani per język, sortowani wg `CATEGORY_TRANSLATE_PRIORITY`
- W każdej super-rundzie:
  - Tier 1: 4 pliki per język (items→npc→monsters→server)
  - Tier 2: 2 pliki per język (items→npc)
  - Tier 3: 1 plik per język (items)
- Dystrybucja w pierwszych 100 kandydatach: T1=16%, T2=24%, T3=60%

### 3. Category translate priority

```
items.json → npc.json → monsters.json → server.json → spells.json → quests.json → scripts.json → actions.json → raids.json
```

Kategorie z największą liczbą kluczy (items=16894, npc=13769, monsters=5915) tłumaczone jako pierwsze.

### 4. Group-aware WORD_TRANSLATIONS

`translate_words_for_simple_text()` sprawdza `LANG_SCRIPT_GROUP` i pomija tłumaczenia słownikowe dla:
- Cyrillic (bg, mk, ru, sr, uk)
- CJK (ja, ko, zh, zh_TW)
- RTL (ar, he)
- Exotic (bn, el, hi, hy, ka, ml, ta, te, th)

### 5. Wcześniej zaimplementowane (potwierdzone)

- GT_LANG_MAP: `he→iw`, `zh_TW→zh-TW` ✅
- Brakujące pliki JSON: 0 brakujących ✅

---

## Wyniki testów

Test z `--langs "pl,de,es,ru,cs"`:
- Kolejność: pl:items → es:items → pl:npc → es:npc (T1 first)
- Tier 1 (pl,es) priorytetowane nad Tier 2 (de,ru) i Tier 3 (cs)
- Category priority: items → npc → monsters → ...
- Zero błędów

## Status

✅ Sekcja 5 w pełni zaimplementowana i przetestowana.
