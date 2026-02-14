# I18N — Plan jakości wielojęzycznej (Europejskie)

> Data: 2026-02-14 | Autor: Copilot + PtakuPL  
> Branch: `feature/i18n-multilanguage`

---

## 1. Audyt stanu obecnego

### 1.1 Pokrycie tłumaczeń (genuine translations vs `[EN]` placeholder)

| Język | Tier | Genuine | `[EN]`-prefix | identical_to_EN | `[XX]` placeholder | **Real %** |
|-------|------|---------|--------------|-----------------|---------------------|-----------|
| **pl** | T1 | 37 713 | – | ~3 000 | ~15 800 | **68.0%** |
| **es** | T1 | 39 069 | – | ~1 000 | ~13 300 | **76.8%** |
| **de** | T2 | 1 212 | 8 655 | ~30 200 | ~15 454 | **2.2%** |
| **fr** | T2 | 839 | 8 794 | ~30 400 | ~15 583 | **1.5%** |
| **pt** | T2 | ~900 | ~8 800 | ~30 300 | ~15 500 | ~1.6% |
| **it** | T2 | ~800 | ~8 700 | ~30 500 | ~15 500 | ~1.4% |
| **ru** | T2 | ~600 | ~8 900 | ~30 500 | ~15 500 | ~1.1% |
| **cs** | T2 | 303 | 8 898 | ~30 700 | ~15 718 | **0.5%** |
| **sk** | T3 | 345 | 8 971 | ~30 600 | ~15 726 | **0.6%** |
| **hr** | T3 | 356 | 24 694 | ~30 200 | 0 | **0.6%** |
| **sl** | T3 | 269 | 24 697 | ~30 300 | 0 | **0.5%** |
| **hu** | T3 | 349 | ~8 970 | ~30 600 | ~15 700 | **0.6%** |
| **ro** | T3 | 265 | ~8 970 | ~30 700 | ~15 700 | **0.5%** |
| **lv** | T3 | 352 | ~8 970 | ~30 600 | ~15 726 | **0.6%** |
| **lt** | T3 | 352 | ~8 970 | ~30 600 | ~15 726 | **0.6%** |
| **bg** | T3 | ~300 | ~8 900 | ~30 700 | ~15 700 | ~0.5% |
| **el** | T3 | ~300 | ~8 900 | ~30 700 | ~15 700 | ~0.5% |
| **sv** | T3 | ~350 | ~9 000 | ~30 500 | ~15 700 | ~0.6% |
| **da** | T3 | ~330 | ~9 000 | ~30 500 | ~15 700 | ~0.6% |
| **no** | T3 | ~340 | ~9 000 | ~30 500 | ~15 700 | ~0.6% |
| **fi** | T3 | ~320 | ~9 000 | ~30 600 | ~15 700 | ~0.6% |

**Wniosek**: Tier 2/3 mają <2% prawdziwych tłumaczeń. Główny problem = throughput, nie jakość GT.

### 1.2 Jakość diakrytyków (wśród genuine translations)

| Język | Oczekiwane znaki | % z diakrytykami | Ocena |
|-------|-----------------|------------------|-------|
| **pl** | ąćęłńóśźż | 68.0% | ✅ OK |
| **es** | áéíóúñü¿¡ | 49.3% | ✅ OK |
| **sk** | áäčďéíľĺňóôŕšťúýž | 75.7% | ✅ OK |
| **cs** | áčďéěíňóřšťúůýž | 71.9% | ✅ OK |
| **hu** | áéíóöőúüű | 69.3% | ✅ OK |
| **lt** | ąčęėįšųūž | 60.8% | ✅ OK |
| **lv** | āčēģīķļņšūž | 59.4% | ✅ OK |
| **ro** | ăâîșț | 41.1% | ⚠️ Niższe (Romanian używa mniej diakrytyków/słowo) |
| **fr** | àâæçéèêëîïôùûüÿœ | 39.8% | ⚠️ Akceptowalne (wiele słów bez akcentów) |
| **hr** | čćđšž | 38.2% | ⚠️ Niższe (chorwacki ma mniej háčków niż czeski) |
| **de** | äöüß | 35.5% | ⚠️ Akceptowalne (niemieckie umlauty są rzadsze) |
| **sl** | čšž | 30.5% | ⚠️ Akceptowalne |

**Wniosek**: GT poprawnie generuje diakrytyki. Nie potrzebujemy diacritics-fixer — potrzebujemy więcej tłumaczeń.

### 1.3 Co jest wspólne dla wszystkich języków (✅ działa)

| Komponent | Opis | Status |
|-----------|------|--------|
| `sync_translation_keys()` | Sync EN → `[EN]` prefix | ✅ Uniwersalne |
| `_candidate_shape_ok()` | Ratio 0.3–4.0 | ✅ Uniwersalne |
| `_auto_fix_translation()` | F1-F6 autofixy | ✅ Uniwersalne |
| `detect_suspicious()` | S1-S11 | ✅ `latin_langs` / `non_latin_langs` |
| `validate_per_lang()` | Cyrillic/CJK/RTL/Exotic | ✅ Script-aware |
| `validate_key()` | V1-V7 + script | ✅ |
| `LANG_SCRIPT_GROUP` | 50+ języków | ✅ |
| `_gt_lang_code()` | GT API kody | ✅ |
| Tier system | T1/T2/T3 + weight | ✅ |
| Round-robin dispatch | z backoff/balance | ✅ |
| Quality dashboard | per-language quality_score | ✅ |

### 1.4 Co jest TYLKO dla PL/ES (❌ brak parity)

| Komponent | Opis | Brakujące języki |
|-----------|------|------------------|
| `SIMPLE_TRANSLATIONS` | Hardcoded quality phrases | Brak: fr, it, nl, sv, da, no, fi, cs, sk, hu, ro, hr, sl, bs, bg, el, lv, lt, sq, et, uk |
| Bootstrap priority | `BOOTSTRAP_PRIORITY_LANGS=es pl` | Inne nie mają boost-u |
| PL/ES balance enforcer | 35% min share | Nie dotyczy T2/T3 (one go nie potrzebują) |
| Repair queue cycles | PL=721, ES=793 | DE=51, FR=23, reszta=5-25 |
| Testowane `identical_to_en` repair | PL/ES centric | Inne potrzebują to samo |

---

## 2. Plan realizacji — Fazy

### Faza 1: Szybkie wygrane (1-2 dni) ✅ DONE 2026-02-14

#### 1a. Rozszerzyć TIER2 o kluczowe języki EU ✅

Obecny TIER2: `de pt ru tr fr it`  
Proponowany TIER2: `de pt ru tr fr it nl cs sk hu`

**Uzasadnienie**: nl/cs/sk/hu to ważne języki EU z unikalnymi regułami pisowni.

```bash
# i18n_worker_simple.sh linia 82
TIER2_LANGS="de pt ru tr fr it nl cs sk hu"
```

#### 1b. Podnieść TIER2_WEIGHT z 2 na 3 ✅

Aby T2 szybciej nadgonił zaległy backlog `[EN]`-prefixów.

```bash
TIER2_WEIGHT=3  # było 2
```

#### 1c. Dodać SIMPLE_TRANSLATIONS dla 20 języków EU ✅ (dodano 20 języków: fr,it,nl,cs,sk,hu,sv,da,no,fi,ro,hr,sl,bg,el,lv,lt,et,sq,uk)

Języki priorytetowe (Latin script, które mają unikalne słowa):

| Język | Przykłady SIMPLE_TRANSLATIONS |
|-------|-------------------------------|
| **fr** | `"Hello" → "Bonjour"`, `"Yes" → "Oui"`, `"No" → "Non"`, `"Gold" → "Or"` |
| **it** | `"Hello" → "Ciao"`, `"Yes" → "Sì"`, `"No" → "No"`, `"Gold" → "Oro"` |
| **nl** | `"Hello" → "Hallo"`, `"Yes" → "Ja"`, `"No" → "Nee"`, `"Gold" → "Goud"` |
| **cs** | `"Hello" → "Ahoj"`, `"Yes" → "Ano"`, `"No" → "Ne"`, `"Gold" → "Zlato"` |
| **sk** | `"Hello" → "Ahoj"`, `"Yes" → "Áno"`, `"No" → "Nie"`, `"Gold" → "Zlato"` |
| **hu** | `"Hello" → "Helló"`, `"Yes" → "Igen"`, `"No" → "Nem"`, `"Gold" → "Arany"` |
| **sv** | `"Hello" → "Hej"`, `"Yes" → "Ja"`, `"No" → "Nej"`, `"Gold" → "Guld"` |
| **da** | `"Hello" → "Hej"`, `"Yes" → "Ja"`, `"No" → "Nej"`, `"Gold" → "Guld"` |
| **no** | `"Hello" → "Hei"`, `"Yes" → "Ja"`, `"No" → "Nei"`, `"Gold" → "Gull"` |
| **fi** | `"Hello" → "Hei"`, `"Yes" → "Kyllä"`, `"No" → "Ei"`, `"Gold" → "Kulta"` |
| **ro** | `"Hello" → "Bună"`, `"Yes" → "Da"`, `"No" → "Nu"`, `"Gold" → "Aur"` |
| **hr** | `"Hello" → "Bok"`, `"Yes" → "Da"`, `"No" → "Ne"`, `"Gold" → "Zlato"` |
| **sl** | `"Hello" → "Živjo"`, `"Yes" → "Da"`, `"No" → "Ne"`, `"Gold" → "Zlato"` |
| **bg** | `"Hello" → "Здравей"`, `"Yes" → "Да"`, `"No" → "Не"`, `"Gold" → "Злато"` |
| **el** | `"Hello" → "Γειά"`, `"Yes" → "Ναι"`, `"No" → "Όχι"`, `"Gold" → "Χρυσός"` |

> Uwaga: Pełne dict-y powinny zawierać ~50-100 najczęstszych fraz gry (jak w PL/ES).

#### 1d. Dodać walidator diakrytyków (ostrzeżenie, nie blokada) ✅ S12 diacritics_missing w detect_suspicious()

Nowy check S12 w `detect_suspicious()`:

```python
# S12 — diacritics_missing: tłumaczenie > 30 znaków nie zawiera oczekiwanych diakrytyków
EXPECTED_DIACRITICS = {
    "pl": r"[ąćęłńóśźż]",
    "cs": r"[áčďéěíňóřšťúůýž]",
    "sk": r"[áäčďéíľĺňóôŕšťúýž]",
    "hu": r"[áéíóöőúüű]",
    "ro": r"[ăâîșț]",
    "hr": r"[čćđšž]",
    "sl": r"[čšž]",
    "lv": r"[āčēģīķļņšūž]",
    "lt": r"[ąčęėįšųūž]",
    "fr": r"[àâæçéèêëîïôûùüÿœ]",
    "es": r"[áéíóúñü]",
    "pt": r"[ãáàâçéêíóôõúü]",
    "de": r"[äöüß]",
    "tr": r"[çğıöşü]",
    "sv": r"[åäö]",
    "da": r"[æøå]",
    "no": r"[æøå]",
    "fi": r"[äö]",
}

# Próg: tekst > 80 znaków bez żadnego diakrytyku → suspicious (WARN, nie REJECT)
```

### Faza 2: Zwiększenie throughput T2/T3 (3-5 dni) ✅ DONE 2026-02-15

#### 2a. Dodać tryb "turbo" dla T2 z dużym backlogiem ✅

Zaimplementowano `apply_turbo_batch()` w workerze:
- Backlog >8000 → batch=30
- Backlog >3000 → batch=20
- Backlog <3000 → batch=10
- Turbo działa tylko dla T2/T3 (T1 używa standardowego adaptive)
- Nowe zmienne: TURBO_BATCH_ENABLED, TURBO_BATCH_THRESHOLD_HIGH/MED, TURBO_BATCH_SIZE_HIGH/MED/LOW

#### 2b. Priorytet kategorii per tier ✅

Zaimplementowano per-tier category priority w dispatch:
- T1 (PL/ES): items → npc → monsters → server → ...
- T2 (DE/FR/...): **npc → items → monsters** (NPC krótsze = szybciej)
- T3 (reszta): npc → server → monsters → items (łatwe najpierw)
- Nowe env vars: CATEGORY_PRIO_T1, CATEGORY_PRIO_T2, CATEGORY_PRIO_T3
- `get_cat_priority(json_file, lang)` — tier-aware

#### 2c. Repair queue: włączyć identical_to_en repair dla T2 ✅

Rozszerzono repair_identical_bonus_round na T2/T3:
- T1 (PL/ES): max_repair_per_cycle = 300 (jak wcześniej)
- T2 (DE/FR/...): max_repair_per_cycle = 50 (REPAIR_T2_LIMIT)
- T3 (reszta): max_repair_per_cycle = 20 (REPAIR_T3_LIMIT)
- Force GT dla wszystkich tierów (nie tylko PL/ES)
- Nowe zmienne: REPAIR_T2_LIMIT, REPAIR_T3_LIMIT, REPAIR_T2_ENABLED, REPAIR_T3_ENABLED

### Faza 3: Per-language quality rules (1-2 tygodnie) ✅ DONE 2026-02-15

#### 3a. Per-language expansion factor ✅

Zaimplementowano per-language calibrated ratio bounds w `_candidate_shape_ok()`:
- Germanic (DE/NL/SV/DA/NO): 0.40–3.5
- Romance (FR/ES/PT/IT/RO): 0.40–3.5
- Slavic: 0.40–3.5
- Uralic (FI/HU/ET): 0.40–4.0 (agglutynacja = dłuższe słowa)
- CJK (ZH/JA/KO): 0.20–2.0
- Arabic/Hebrew: 0.30–3.0
- Default: 0.30–4.0

#### 3b. Specyficzne reguły pisowni per język (future) ⬜ — niska priorytet, kosmetyka

| Język | Specyficzna reguła | Priorytet |
|-------|-------------------|-----------|
| **DE** | Rzeczowniki wielką literą (Substantive) | P2 |
| **FR** | Spacje przed ! ? : ; | P3 |
| **ES** | ¿...? i ¡...! | P2 — już w detect_suspicious S8 |
| **PL** | Nie→nie (lowercase) na początku odpowiedzi NPC | P3 |
| **FI** | Aglutynacja — długie słowa (>25 znaków) OK | P2 |
| **HU** | Aglutynacja — długie słowa OK + vowel harmony | P3 |
| **CJK** | Brak spacji między słowami | P1 — już w validate_per_lang |
| **AR/HE** | RTL marker + diacritics | P1 — już w validate_per_lang |
| **BG/RU/UK** | Cyrillic script | P1 — już w validate_per_lang |
| **EL** | Greek script | P1 — już w validate_per_lang (exotic) |

#### 3c. EXT_SIMPLE_TRANSLATIONS.json rozszerzenie ⬜ — opcjonalne, 26 już hardcoded

Przenieść hardcoded `SIMPLE_TRANSLATIONS` do zewnętrznego pliku `simple_translations.json`
i dodać 15 języków EU z ~100 frazami gry każdy.

Fazy per język:
1. NPC greetings: "Hello", "Bye", "Yes", "No", "Trade", "Quest"
2. Items: "Gold", "Gold Coin", "Sword", "Shield", "Potion"
3. UI phrases: "You can't move that item so fast", "It is empty", "You are dead"
4. Monster names: zachować EN (nie tłumaczyć)

### Faza 4: Monitoring i telemetria wielojęzyczna (ciągłe) ✅ DONE 2026-02-15

#### 4a. Statusd: per-language throughput rate ✅

Dodano do KPI Snapshot (MODUŁ 3 statusd):
- genuine_translations per T2 language
- en_backlog per T2 language
- diacritics_rate per T2 language (genuine only)

#### 4b. Doctor check: lang parity alert ✅

Nowy check w `run_status_doctor()`:
- T2 lang <100 genuine translations po 72h → CRIT
- T2 lang >5000 [EN]-backlog po 48h → WARN
- Śledzi `first_run_ts` dla precyzyjnego timer

#### 4c. Tygodniowy raport wielojęzyczny ⬜

Automatyczny raport co 7 dni:
```
🌍 Raport wielojęzyczny (tydzień 7)
──────────────────────────────────
Tier 1: PL 68.0% (+2.1%) | ES 76.8% (+1.5%)
Tier 2: DE 2.2% (+0.8%) | FR 1.5% (+0.6%) | ...
Tier 3: CS 0.5% (+0.2%) | HR 0.6% (+0.1%) | ...
──────────────────────────────────
⚡ Najszybciej rosnący: DE (+0.8%)
🐌 Najwolniejszy: SL (+0.05%)
```

---

## 3. Specyficzne reguły per język — dokładny opis

### 3.1 Języki germańskie (DE, NL, SV, DA, NO)

**Wspólne cechy:**
- Rzeczowniki pisane wielką literą (tylko DE!)
- Złożenia słów (Zusammensetzung) — DE/NL/SV mogą mieć bardzo długie słowa
- Porządek słów: V2 (czasownik na 2. pozycji)

**Walidacja:**
- DE: `_candidate_shape_ok` ratio 0.4–3.5 (DE jest ~20-35% dłuższy od EN)
- NL: ratio 0.4–3.5 (zbliżony do EN)
- SV/DA/NO: ratio 0.4–3.5

**Diakrytyki:**
- DE: ä, ö, ü, ß (rzadkie, ~35% tekstów)
- SV: å, ä, ö (częste, ~40% tekstów)
- DA/NO: æ, ø, å (częste, ~40% tekstów)
- NL: praktycznie brak (ë, ï sporadycznie)

### 3.2 Języki romańskie (FR, IT, PT, RO, ES)

**Wspólne cechy:**
- Bogate odmiany czasowników
- Rodzajniki (le/la/il/o/el + formy liczby mn.)
- Akcenty i diakrytyki

**Walidacja:**
- FR: spacja przed `!`, `?`, `:`, `;` (typografia francuska)
- ES: `¿...?` i `¡...!` — już w S8
- PT: zbliżony do ES
- IT: zbliżony do FR/ES
- RO: `ă, â, î, ș, ț` — unikalne dla rumyńskiego

### 3.3 Języki słowiańskie (PL, CS, SK, HR, SL, BS, BG, SR, UK, RU, MK)

**Wspólne cechy:**
- Deklinacja (7 przypadków w PL/CS/SK/HR/SL)
- Koniugacja (bogate formy czasownikowe)
- Aspekt (dokonany/niedokonany)
- Brak rodzajników

**Podgrupy:**
- **Łacinka**: PL, CS, SK, HR, SL, BS — bogate diakrytyki háčky/čárky
- **Cyrylica**: BG, SR, UK, RU, MK — sprawdzane przez `validate_per_lang()` (cyrillic check)

**Walidacja:**
- PL: ąćęłńóśźż (68% tekstów)
- CS: áčďéěíňóřšťúůýž (72% tekstów) — najgęstsze háčky
- SK: áäčďéíľĺňóôŕšťúýž (76% tekstów)  
- HR: čćđšž (38% tekstów — mniej niż CS/SK)
- SL: čšž (30% — jeszcze mniej, ale to normalne)

### 3.4 Języki ugrofińskie (FI, HU, ET)

**Wspólne cechy:**
- **Aglutynacja**: jedno słowo może zastąpić całe zdanie EN
- Wyjątkowo długie słowa (>25 znaków normalne)
- Brak rodzaju gramatycznego
- FI: 15 przypadków, HU: 18 przypadków, ET: 14 przypadków
- Harmonia samogłoskowa (HU, FI)

**Walidacja:**
- EN→FI ratio: 1.20–1.45 (fińskie słowa są dłuższe!)
- EN→HU ratio: 1.25–1.50
- Akceptować słowa >25 znaków bez podejrzeń (S5 max_word_len)
- FI: ä, ö (w ~30% tekstów)
- HU: á, é, í, ó, ö, ő, ú, ü, ű (w ~70% tekstów)
- ET: ä, ö, ü, õ (w ~40% tekstów)

### 3.5 Języki bałtyckie (LV, LT)

**Wspólne cechy:**
- Bogate diakrytyki (makrony, háčky, cedylle)
- Deklinacja (LV: 7, LT: 7 przypadków)
- LV i LT są BARDZO różne od siebie mimo sąsiedztwa!

**Walidacja:**
- LV: āčēģīķļņšūž (60% tekstów z diakrytykami)
- LT: ąčęėįšųūž (61% tekstów)
- Ratio EN→LV/LT: 0.95–1.20

### 3.6 Inne (EL, SQ, TR)

- **EL** (grecki): Unique script — `validate_per_lang()` exotic check, ratio 1.10–1.30
- **SQ** (albański): Latin script, ë/ç, ratio ~1.05–1.20
- **TR** (turecki): Latin script, çğıöşü, harmonia samogłoskowa, aglutynacja, ratio 1.10–1.30

---

## 4. Priorytety implementacji

| # | Zadanie | Priorytet | Wysiłek | Wpływ |
|---|---------|-----------|---------|-------|
| 1 | Rozszerzyć TIER2 o nl/cs/sk/hu | **P0** | 5 min | Duży — 4 języki dostaną 3× więcej cykli |
| 2 | TIER2_WEIGHT=3 | **P0** | 1 min | Duży — T2 przyspiesza o 50% |
| 3 | S12 diacritics_missing check | **P1** | 30 min | Średni — wykrywa brak diakrytyków |
| 4 | SIMPLE_TRANSLATIONS fr/it/nl/cs/sk/hu | **P1** | 2h | Średni — lepsze krótkie frazy |
| 5 | Turbo batch dla >8000 backlog | **P1** | 30 min | Duży — 3× szybsze tłumaczenie backlogu |
| 6 | Per-language ratio calibration | **P2** | 1h | Średni — lepsze accept/reject |
| 7 | Repair queue T2 | **P2** | 30 min | Średni — naprawia identical_to_en |
| 8 | Per-lang grammar checks (DE capitals, FR spaces) | **P3** | 4h | Mały — kosmetyka |
| 9 | Statusd genuine_translations telemetria | **P2** | 1h | Monitoring |
| 10 | Tygodniowy raport wielojęzyczny | **P3** | 1h | Visibility |

---

## 5. Uwagi implementacyjne

### 5.1 SIMPLE_TRANSLATIONS — format

Istniejący format w workerze (Python dict w heredoc):
```python
SIMPLE_TRANSLATIONS = {
    "pl": {
        "Hello": "Witaj",
        "Yes": "Tak",
        ...
    },
    "es": {
        "Hello": "Hola",
        ...
    },
}
```

Nowe języki dodać w tym samym formacie. Alternatywa: EXT_SIMPLE_TRANSLATIONS z pliku JSON.

### 5.2 Nie tłumaczyć nazw własnych

Monster names, city names, NPC names, spell names — zachować EN:
- "Rotworm" → "Rotworm" (nie tłumaczyć)
- "Liberty Bay" → "Liberty Bay"
- "Exura Vita" → "Exura Vita"

### 5.3 Identyczne-do-EN a prawdziwe tłumaczenia

Wiele kluczy jest naturalnie identycznych w EN i innych językach:
- Nazwy potworów (Rotworm, Cyclops)
- Nazwy zaklęć (Exori, Utevo)  
- Ścieżki plików, kody techniczne
- Nazwy przedmiotów (Magic Plate Armor → w wielu językach zostaje)

Te NIE powinny być flagowane jako "brakujące" — potrzebna jest lista `UNTRANSLATABLE_PATTERNS`.

---

## 6. Harmonogram

| Tydzień | Faza | Zadania |
|---------|------|---------|
| **W1** | Faza 1 | ✅ Tier2 rozszerzenie, TIER2_WEIGHT=3, S12 diacritics, 20 EU SIMPLE_TRANSLATIONS |
| **W1** | Import | ✅ Import ZIP: FR +27k, RU +25k, RO +8k, BG/DE/NL +2k each. Cleanup mixed-lang entries. |
| **W2** | Faza 2 | ✅ Turbo batch, category priority per tier, repair queue T2/T3 |
| **W2** | Faza 3 | ✅ Per-language ratio bounds, agglutinative langs (FI/HU/ET) 0.40-4.0 |
| **W2** | Faza 4 | ✅ Statusd genuine/backlog/diacritics KPI, lang parity doctor alert |
| **W3+** | Faza 5 | ✅ Historia postępu: MODUŁ 9 w statusd, i18n_status_historia.md (hourly/daily/weekly) |
| **W3+** | Grammar | ✅ S13: DE noun capitalization (artykuł + rzeczownik małą literą). S14: FR punctuation spacing (brak spacji przed ;:!?) |
| **W3+** | Ciągłe | ⬜ Tygodniowy raport wielojęzyczny |

---

## Faza 5: Historia postępu — `i18n_status_historia.md` ✅ DONE

> Status: **✅ DONE** — MODUŁ 9 w statusd wdrożony i przetestowany (2026-02-14)  
> Cel: Automatycznie generowany raport .md, który co godzinę zapisuje postęp pracy workera.  
> Kiedy użytkownik wstaje rano — widzi jasno jaki postęp nastąpił w nocy, w jakim tempie i co konkretnie worker robił.

---

### 5.0 Problem i motywacja

Obecnie:
- `statusd_daily_report.json` — raport 24h w JSON → trudno czytać
- `translation_global_overview.json` — snapshot stanu bieżącego → brak historii
- `worker_cycle_perf.jsonl` — surowe logi cykli → za dużo danych, brak podsumowania
- `ops.jsonl` — 2.8 MB logów → nieczytalne

**Brakuje**: Jednego czytelnego pliku Markdown z chronologiczną historią postępu, podzielonego na:
- ⏱️ Snapshoty godzinowe (co worker zrobił w ostatniej godzinie)
- 📅 Podsumowania dzienne (cały dzień w jednym bloku)
- 📊 Podsumowania tygodniowe (trend, tempo, szacowanie zakończenia)

---

### 5.1 Źródła danych (już istniejące — BEZ nowych zbierek)

| Źródło | Opis | Klucze wykorzystane |
|--------|------|---------------------|
| `translation_guard_report.jsonl` | Per-cycle: lang, json_file, translated, guard_fail | translated, guard_fail per lang/file |
| `quality_report.jsonl` | Per-cycle: lang, file, suspicious_count/high, identical_to_en | suspicious, identical_to_en |
| `worker_cycle_perf.jsonl` | Per-cycle: timestamp, mode, category, duration_ms | mode, duration, tempo |
| `translation_global_overview.json` | Snapshot: per-lang completion_pct, translated_keys | completion_pct, missing_keys |
| `statusd_daily_report.json` → `kpi_24h` | Zagregowane: translated, guard_fail_rate, throughput | throughput_keys_per_h |
| `statusd_daily_report.json` → `trend_per_language` | Per-lang 24h: translated, guard_fail_rate | delta per lang |
| `statusd_daily_report.json` → `trend_per_category` | Per-file 24h: translated, guard_fail_rate | delta per kategoria |
| `statusd_daily_report.json` → `coverage_snapshot` | Per-lang: completion_pct, server/client split | aktualny snapshot |
| `statusd_daily_report.json` → `repair_backlog` | Repair queue: by_lang, stagnation | repair delta |
| `identical_to_en_repair_queue.json` | Repair queue bieżący | entries_total, by_lang |
| `adaptive_batch_state.json` | Batch size, fail rate, adjustments | current batch |

---

### 5.2 Struktura pliku `i18n_status_historia.md`

Plik jest **generowany jeśli go nie ma**, a gdy już istnieje — **aktualizowany co godzinę** (nowy snapshot godzinowy + odświeżenie podsumowań). Struktura:

```markdown
# 📊 I18N — Historia postępu tłumaczeń

> Auto-generated by statusd | Last update: 2026-02-15 08:00 UTC

---

## 📅 Podsumowanie tygodniowe (2026-02-10 → 2026-02-16)

| Metryka | Wartość | Δ od zeszłego tyg. |
|---------|---------|-------------------|
| Kluczy przetłumaczonych (SUMA) | 248 310 | +72 400 (+41%) |
| Średni throughput | 1 850 kluczy/h | +320 vs zeszły tyg |
| Guard fail rate | 5.2% | -1.8% ↓ |
| Repair queue | 4 752 → 2 100 | -55.8% ↓ |
| Nowe języki >50% | FR, RU | — |

### Pokrycie per TIER (koniec tygodnia)

| Tier | Język | % | Δ tydzień | Szac. do celu |
|------|-------|---|-----------|---------------|
| T1 | PL | 75.1% | +4.2% | ~6 dni do 90% |
| T1 | ES | 86.7% | +3.1% | ~2 dni do 90% |
| T2 | FR | 54.0% | +52.5% | ~9 dni do 50% ✅ |
| T2 | RU | 54.9% | +53.8% | ✅ cel osiągnięty |
| T2 | DE | 16.4% | +14.2% | ~18 dni do 50% |
| T2 | PT | 19.5% | +17.9% | ~14 dni do 50% |
| ... | ... | ... | ... | ... |

---

## 📅 Podsumowanie dzienne: 2026-02-14

| Metryka godzinowa | Wartość |
|-------------------|---------|
| Kluczy przetłumaczonych (24h) | 45 352 |
| Throughput avg | 1 889 kluczy/h |
| Guard fail rate | 5.2% |
| Cykli workera | 659 |
| Repair queue zmiana | 6 537 → 4 752 (-27%) |

### Top 5 języków dnia

| # | Język | Przetłumaczono | Guard fail % | Δ coverage |
|---|-------|---------------|-------------|------------|
| 1 | PL | 7 241 | 15.2% | +1.3% |
| 2 | FR | 6 800 | 3.1% | +12.7% |
| 3 | RU | 5 900 | 2.8% | +11.1% |
| 4 | ES | 4 200 | 1.8% | +0.8% |
| 5 | TR | 3 500 | 4.5% | +6.5% |

### Top 5 kategorii dnia

| # | Plik | Przetłumaczono | Guard fail % |
|---|------|---------------|-------------|
| 1 | items.json | 12 755 | 1.8% |
| 2 | npc.json | 9 300 | 3.2% |
| 3 | monsters.json | 8 200 | 2.1% |
| 4 | spells.json | 5 100 | 1.5% |
| 5 | quests.json | 4 800 | 4.8% |

---

## ⏱️ Snapshot godzinowy: 2026-02-14 08:00–09:00 UTC

| Metryka | Wartość |
|---------|---------|
| Przetłumaczono | 1 432 kluczy |
| Guard fail | 82 (5.7%) |
| Suspicious high | 14 (1.0%) |
| Repair queue Δ | -35 |
| Cykli | 20 |
| Batch size avg | 18 |

<details><summary>🔍 Szczegóły per język (kliknij)</summary>

| Język | +kluczy | fail% | coverage% | Δ% |
|-------|---------|-------|-----------|-----|
| pl | 180 | 15.2% | 75.14 | +0.34 |
| es | 95 | 1.8% | 86.70 | +0.18 |
| fr | 220 | 3.1% | 54.05 | +0.41 |
| ru | 185 | 2.8% | 54.88 | +0.35 |
| de | 140 | 4.5% | 16.43 | +0.26 |
| tr | 80 | 4.2% | 14.00 | +0.15 |
| ... | ... | ... | ... | ... |

</details>

---

## ⏱️ Snapshot godzinowy: 2026-02-14 07:00–08:00 UTC

(analogicznie ...)
```

---

### 5.3 Kategorie informacji — 7 sekcji

| # | Sekcja | Co zawiera | Widoczność |
|---|--------|-----------|------------|
| **A** | **Nagłówek** | Timestamp, uptime workera, PID-y demonów | Zawsze |
| **B** | **Snapshot godzinowy** | translated, guard_fail, suspicious, repair Δ, batch size, cykle | Co 1h (append) |
| **C** | **Szczegóły per język** (w `<details>`) | +kluczy per lang, fail%, coverage%, Δ% | Co 1h (zwijany) |
| **D** | **Szczegóły per kategoria** (w `<details>`) | +kluczy per json_file, fail% | Co 1h (zwijany) |
| **E** | **Podsumowanie dzienne** (progresywne) | SUMA: translated, throughput avg, repair Δ, top5 lang/cat | Co 5h (rośnie do 24h) |
| **F** | **Podsumowanie tygodniowe** (progresywne) | SUMA tygodnia, Δ vs zeszły tyg, szacowanie do celu, tier table | Po 7 daily |
| **G** | **ETA / prognoza** | Tempo → ile dni do celu per język | W tygodniowym |

---

### 5.4 Metryki zbierane per godzinę

| Metryka | Źródło | Opis |
|---------|--------|------|
| `translated_keys` | `guard_report.jsonl` SUM(translated) w oknie 1h | Klucze przetłumaczone |
| `guard_fail_count` | `guard_report.jsonl` SUM(guard_fail) w oknie 1h | Odrzucone tłumaczenia |
| `guard_fail_rate` | guard_fail / (translated + guard_fail) | Procent odrzuceń |
| `suspicious_high` | `quality_report.jsonl` SUM(suspicious_high) w oknie 1h | Podejrzane (wysoka pewność) |
| `identical_to_en` | `quality_report.jsonl` SUM(identical_to_en) w oknie 1h | Identyczne z EN |
| `repair_delta` | Δ `repair_queue.json` entries | Zmiana repair queue |
| `cycles_count` | `worker_cycle_perf.jsonl` COUNT w oknie 1h | Ile cykli workera |
| `avg_batch_size` | translated / cycles | Średni batch |
| `coverage_per_lang` | `global_overview.json` snapshot | Coverage na koniec godziny |
| `per_lang_translated` | `guard_report.jsonl` GROUP BY language SUM(translated) | +kluczy per język |
| `per_cat_translated` | `guard_report.jsonl` GROUP BY json_file SUM(translated) | +kluczy per kategoria |

---

### 5.5 Agregacja dzienna — progresywna (5h → 10h → 15h → 24h)

Podsumowanie dzienne **rośnie progresywnie** w miarę gromadzenia snapshortów godzinowych:

| Snapshoty zebrane | Co widać w sekcji dziennej | Opis |
|-------------------|---------------------------|------|
| 1–4 h | Brak sekcji dziennej | Za mało danych — widać tylko snapshoty godzinowe |
| **5 h** | "Podsumowanie dzienne (ostatnie 5h)" | Pierwsza agregacja — top3 lang/cat |
| **10 h** | "Podsumowanie dzienne (ostatnie 10h)" | Aktualizacja — top5 lang/cat, coverage Δ |
| **15 h** | "Podsumowanie dzienne (ostatnie 15h)" | Aktualizacja — rozszerzony trend |
| **20 h** | "Podsumowanie dzienne (ostatnie 20h)" | Aktualizacja — prawie pełny dzień |
| **24 h** | "Podsumowanie dzienne: 2026-02-14" | Zamknięte podsumowanie — pełna doba |

Gdy podsumowanie dzienne zostanie zamknięte (24h zebrane):
- **Snapshoty godzinowe z tego dnia są USUWANE** z `.md` (przeniesione do `historia_snapshots.jsonl`)
- W pliku `.md` zostaje TYLKO podsumowanie dzienne — czytelne i zwięzłe
- Nowy dzień zaczyna zbierać snapshoty godzinowe od nowa

**Analogicznie tygodniowe**: po 7 zamkniętych podsumowaniach dziennych → powstaje podsumowanie tygodniowe.
Po zamknięciu tygodnia — stare podsumowania dzienne mogą być skrócone do jednolinijkowego wpisu w tabeli.

Źródło: Suma snapshortów godzinowych z bieżącego okna.

| Metryka | Obliczenie |
|---------|----------|
| `total_translated` | SUM(hourly.translated_keys) w oknie |
| `avg_throughput` | total_translated / ilość_godzin |
| `total_guard_fail` | SUM(hourly.guard_fail_count) w oknie |
| `avg_guard_fail_rate` | total_guard_fail / (total_translated + total_guard_fail) |
| `repair_delta` | repair_queue[now] - repair_queue[start_of_window] |
| `top5_langs` | sort by per_lang_translated DESC LIMIT 5 |
| `top5_cats` | sort by per_cat_translated DESC LIMIT 5 |
| `coverage_delta` | coverage[now] - coverage[start_of_window] per lang |

---

### 5.6 Agregacja tygodniowa (7d)

Źródło: Suma podsumowań dziennych + snapshot bieżący vs snapshot sprzed 7 dni.

| Metryka | Obliczenie |
|---------|-----------|
| `week_total_translated` | SUM(daily.total_translated) |
| `week_avg_throughput` | week_total_translated / 168 (h) |
| `delta_vs_prev_week` | week_total - prev_week_total |
| `repair_queue_delta_week` | repair[end] - repair[start_of_week] |
| `eta_per_lang` | (target% - current%) / weekly_delta_pct → dni |
| `new_langs_above_target` | Które języki osiągnęły cel tier-u w tym tygodniu |
| `slowest_lang` | Min weekly Δ% |
| `fastest_lang` | Max weekly Δ% |

---

### 5.7 Limity i retencja

| Parametr | Wartość | Uzasadnienie |
|----------|---------|-------------|
| Snapshoty godzinowe w `.md` | **Tylko bieżący dzień** | Usuwane po zamknięciu dobowego podsumowania |
| Max podsumowań dziennych w `.md` | **14** (2 tygodnie) | Starsze → jednolinijkowy wiersz w tabeli archiwum |
| Max podsumowań tygodniowych w `.md` | **8** (2 miesiące) | Starsze → jednolinijkowy wiersz |
| Backup JSONL (snapshoty surowe) | **168 linii** (7 dni) | W `historia_snapshots.jsonl` — pełne dane |
| Backup JSON (daily pełne) | **30** wpisów | W `historia_daily.json` |
| Backup JSON (weekly pełne) | **12** wpisów | W `historia_weekly.json` |
| Rozmiar max `.md` | ~100 KB | Mniejszy bo godzinowe usuwane po daily |
| Format czasu | UTC | Spójne z resztą systemu |

**Cykl życia danych w `.md`:**
```
Godz. 1-4:  [snap 1h] [snap 2h] [snap 3h] [snap 4h]        (brak daily)
Godz. 5:    [snap 1-5h]  + [daily: ostatnie 5h]             (pierwszy daily)
Godz. 10:   [snap 6-10h] + [daily: ostatnie 10h] (updated)  (snapshoty 1-5 nadal widoczne)
Godz. 24:   [daily: pełna doba]                              (snapshoty USUNIĘTE z .md)
Dzień 7:    [daily d1-d7] + [weekly: tydzień X]              
Dzień 14:   [daily d8-d14] + [weekly: tyg X+1] + [weekly: tyg X jednolinijkowy]
```

---

### 5.8 Wewnętrzny store dla historii

Ponieważ `.md` jest trudny do parsowania wstecz, statusd będzie trzymał wewnętrzny JSON:

```
i18n/status/historia_snapshots.jsonl    # append-only, 1 linia per snapshot 1h
i18n/status/historia_daily.json         # tablica podsumowań dziennych (max 30)
i18n/status/historia_weekly.json        # tablica podsumowań tygodniowych (max 12)
```

**historia_snapshots.jsonl** — format linii:
```json
{
  "ts": "2026-02-14T09:00:00Z",
  "window": "08:00-09:00",
  "translated": 1432,
  "guard_fail": 82,
  "guard_fail_pct": 5.7,
  "suspicious_high": 14,
  "identical_to_en": 3,
  "repair_delta": -35,
  "cycles": 20,
  "avg_batch": 18,
  "per_lang": {
    "pl": {"t": 180, "gf": 30, "cov": 75.14},
    "es": {"t": 95, "gf": 2, "cov": 86.70},
    "fr": {"t": 220, "gf": 7, "cov": 54.05}
  },
  "per_cat": {
    "items.json": {"t": 450, "gf": 8},
    "npc.json": {"t": 380, "gf": 12}
  }
}
```

---

### 5.9 Implementacja — gdzie i jak

| Element | Lokalizacja | Opis |
|---------|------------|------|
| **Zbieranie danych** | `i18n-statusd.sh` → MODUŁ 9 (nowy) | Nowy moduł `run_historia_snapshot()` |
| **Generowanie .md** | `i18n-statusd.sh` → MODUŁ 9 | `render_historia_md()` — buduje Markdown z JSONL |
| **Cron/interwał** | Co godzinę (w głównej pętli statusd) | Dodać `HISTORIA_INTERVAL=3600` |
| **Plik docelowy** | `docs/i18n/i18n_status_historia.md` | Widoczny w docs/ |
| **Backup/archiwum** | `i18n/status/i18n_status_historia_archive.md` | Stare snapshoty |

#### Pseudokod MODUŁU 9:

```bash
# ═══════════════════════════════════════════════════════
# MODUŁ 9 — Historia postępu (i18n_status_historia.md)
# ═══════════════════════════════════════════════════════

HISTORIA_INTERVAL=3600   # co 1h
HISTORIA_MAX_HOURLY=168  # 7 dni snapshoty
HISTORIA_MAX_DAILY=30    # 30 dni podsumowania
HISTORIA_MAX_WEEKLY=12   # kwartał

HISTORIA_SNAPSHOTS="i18n/status/historia_snapshots.jsonl"
HISTORIA_DAILY="i18n/status/historia_daily.json"
HISTORIA_WEEKLY="i18n/status/historia_weekly.json"
HISTORIA_MD="docs/i18n/i18n_status_historia.md"

run_historia_snapshot() {
    local now_ts; now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local window_start; window_start=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)

    # 1) Parsuj guard_report.jsonl za ostatnią godzinę
    #    → SUM translated, guard_fail, GROUP BY language, json_file
    
    # 2) Parsuj quality_report.jsonl za ostatnią godzinę
    #    → SUM suspicious_high, identical_to_en
    
    # 3) Parsuj worker_cycle_perf.jsonl za ostatnią godzinę
    #    → COUNT cycles
    
    # 4) Odczytaj bieżący coverage z global_overview.json
    #    → per-lang completion_pct
    
    # 5) Odczytaj repair_queue delta
    #    → current - previous snapshot
    
    # 6) Zapisz snapshot do historia_snapshots.jsonl (append)
    
    # 7) Sprawdź czy minęła pełna doba → jeśli tak: aggregate_daily()
    
    # 8) Sprawdź czy minął pełny tydzień → jeśli tak: aggregate_weekly()
    
    # 9) render_historia_md() → wygeneruj Markdown
    
    # 10) Trim: historia_snapshots.jsonl → max 168 linii (FIFO)
}

aggregate_daily() {
    # Suma wszystkich snapshortów z danego dnia
    # Append do historia_daily.json
    # Trim: max 30 wpisów
}

aggregate_weekly() {
    # Suma 7 podsumowań dziennych
    # ETA per lang: (target - current) / weekly_delta
    # Append do historia_weekly.json
    # Trim: max 12 wpisów
}

render_historia_md() {
    # 1) Jeśli plik nie istnieje → utwórz z nagłówkiem
    #    Jeśli istnieje → aktualizuj in-place
    # 2) Najnowsze podsumowanie tygodniowe (jeśli jest)
    # 3) Podsumowanie dzienne (progresywne: 5h/10h/15h/20h/24h)
    # 4) Snapshoty godzinowe TYLKO z bieżącego dnia
    #    → po zamknięciu daily (24h) usunięte z .md
    # 5) Archiwum: jednolinijkowe wpisy starych daily/weekly
    # 6) Zapisz do HISTORIA_MD
}
```

---

### 5.10 Zadania implementacyjne (podział na kroki) ✅ DONE 2026-02-14

| # | Zadanie | Estymacja | Status |
|---|---------|-----------|--------|
| 5.10a | Dodać MODUŁ 9 do `i18n-statusd.sh` — szkielet `run_historia_snapshot()` | 30 min | ✅ |
| 5.10b | Implementacja parsera: guard_report.jsonl → okno 1h | 20 min | ✅ |
| 5.10c | Implementacja parsera: quality_report.jsonl → okno 1h | 15 min | ✅ |
| 5.10d | Implementacja parsera: worker_cycle_perf.jsonl → okno 1h | 10 min | ✅ |
| 5.10e | Coverage snapshot z global_overview.json | 10 min | ✅ |
| 5.10f | Repair queue delta tracker (previous vs current) | 10 min | ✅ |
| 5.10g | Zapis snapshot → `historia_snapshots.jsonl` | 10 min | ✅ |
| 5.10h | `aggregate_daily()` — progressive daily (5h→10h→15h→20h→24h) | 20 min | ✅ |
| 5.10i | `aggregate_weekly()` — suma daily + ETA → `historia_weekly.json` | 20 min | ✅ |
| 5.10j | `render_historia_md()` — generator Markdown | 40 min | ✅ |
| 5.10k | Trim/retencja: FIFO 168 snapshortów, 30 daily, 12 weekly | 15 min | ✅ |
| 5.10l | Integracja z główną pętlą statusd (co 1h trigger) + CLI `--historia` | 10 min | ✅ |
| 5.10m | Testy: symulacja snapshortów, weryfikacja .md output | 15 min | ✅ |
| **SUMA** | | **~3.5h** | **✅ DONE** |

---

### 5.11 Wizualizacja poranna — co widzi użytkownik

Gdy użytkownik otwiera `docs/i18n/i18n_status_historia.md` rano:

```
1. NAGŁÓWEK → kiedy ostatnia aktualizacja, uptime, PID-y
2. PODSUMOWANIE TYGODNIOWE → full-picture: ile przetłumaczono, trend, ETA → "za 6 dni PL osiągnie 90%"
3. PODSUMOWANIE DZIENNE (wczoraj) → ile worker zrobił w ciągu 24h, top5 języków i kategorii
4. SNAPSHOTY GODZINOWE (nocne) → chronologicznie: 
   - 23:00-00:00: +1200 kluczy, FR +350, DE +180...
   - 00:00-01:00: +1100 kluczy, RU +280, PL +200...
   - ...
   - 07:00-08:00: +1400 kluczy, ES +300, TR +250...
5. <details> per język — rozwijane tabele ze szczegółami
```

**Kluczowe pytania jakie raport odpowiada:**
- ❓ „Ile kluczy przetłumaczył w nocy?" → SUMA snapshortów 22:00-08:00
- ❓ „Który język najszybciej rośnie?" → top5 w podsumowaniu dziennym
- ❓ „Kiedy PL osiągnie 90%?" → ETA w podsumowaniu tygodniowym
- ❓ „Czy repair queue się zmniejsza?" → repair_delta w snapshortach
- ❓ „Czy quality się pogarsza?" → guard_fail_rate trend
- ❓ „Co dokładnie robił o 3:00 w nocy?" → snapshot 03:00-04:00

---

### 5.12 Konfiguracja zmiennych (env / config)

```bash
# Nowe zmienne dla MODUŁU 9
HISTORIA_ENABLED=true                      # włącz/wyłącz generowanie
HISTORIA_INTERVAL=3600                     # interwał w sekundach (domyślnie 1h)
HISTORIA_MAX_HOURLY_SNAPSHOTS=168          # max 7 dni snapshortów
HISTORIA_MAX_DAILY_SUMMARIES=30            # max 30 podsumowań dziennych
HISTORIA_MAX_WEEKLY_SUMMARIES=12           # max 12 podsumowań tygodniowych
HISTORIA_MD_PATH="docs/i18n/i18n_status_historia.md"
HISTORIA_ARCHIVE_PATH="i18n/status/i18n_status_historia_archive.md"
HISTORIA_SNAPSHOTS_FILE="i18n/status/historia_snapshots.jsonl"
HISTORIA_DAILY_FILE="i18n/status/historia_daily.json"
HISTORIA_WEEKLY_FILE="i18n/status/historia_weekly.json"
HISTORIA_DAILY_FIRST_THRESHOLD=5           # po ilu godzinach pojawia się pierwszy daily (progresywny)
HISTORIA_DAILY_STEP=5                      # co ile godzin aktualizować daily (5→10→15→20→24)
HISTORIA_CLEANUP_HOURLY_AFTER_DAILY=true   # usuwaj snapshoty godzinowe z .md po zamknięciu daily 24h
HISTORIA_TIER_TARGETS='{"T1":90,"T2":50,"T3":30}'  # cele % per tier (dla ETA)
```

---

### 5.13 Inne tryby pracy workera — pełna mapa w historii

> Worker v2.0 pracuje w **6 trybach** (fazach), które automatycznie się przełączają w trybie `--continuous`.
> Każdy tryb generuje inne metryki i ma inne problemy.
> Sekcja 5.0–5.12 pokrywa TYLKO tryb `AUTO_TRANSLATE`.
> Ta sekcja rozszerza plan historii o **wszystkie** tryby pracy.

---

### 5.13.0 Architektura trybów workera

```
PHASE_ORDER = ["MIGRATION", "COMPACT_KEYS", "TRANSLATION_SYNC", "AUTO_TRANSLATE", "IDLE"]
```

| # | Tryb (Phase) | Etapy | Co robi | Pliki źródłowe |
|---|-------------|-------|---------|---------------|
| 1 | **MIGRATION** | 8 etapów (stage_1–stage_8) | Migracja NPC `.lua`: backup → analiza → dokumentacja → transformacja kodu → ekstrakcja kluczy EN → tłumaczenie → walidacja → sync | `data-otservbr-global/npc/*.lua` |
| 1b | **MIGRATION (scripts)** | process_scripts_file | `sendTextMessage()` → `sendLocalizedTextMessage()`, `:say()` → `:sayLocalized()`, `broadcastMessage()` → `broadcastLocalizedMessage()` | `data-otservbr-global/scripts/**/*.lua` |
| 1c | **MIGRATION (inne)** | 20 kategorii | monsters, spells, items (XML), raids, world, libs, events, chatchannels, modules, startup, npclib, php, html, cpp, client, twig, generic | Różne katalogi |
| 2 | **COMPACT_KEYS** | keymap_sync → verify → export | Sync keymap, weryfikacja, export compact keys | `i18n/en/*.json` |
| 3 | **TRANSLATION_SYNC** | sync_start → sync_file_done → sync_done | Synchronizacja EN → inne języki (dodanie brakujących kluczy jako `[EN]` prefix) | `i18n/{lang}/*.json` |
| 4 | **AUTO_TRANSLATE** | auto_start → parallel → auto_done | Tłumaczenie via Google Translate + SIMPLE_TRANSLATIONS + repair queue | `i18n/{lang}/*.json` |
| 5 | **VALIDATION** | validation_start → validation_done | Walidacja jakości tłumaczeń | Wszystkie przetłumaczone pliki |
| 6 | **IDLE** | idle_cycle / sleeping | Skanowanie nowych plików, generowanie dokumentacji kategorii, audyt jakości | Workspace scan |

---

### 5.13.1 Tryb MIGRATION — NPC (8 etapów)

Worker przetwarza pliki NPC `.lua` przez 8 sekwencyjnych etapów:

| Etap | Nazwa | Funkcja | Co robi | Obecne metryki |
|------|-------|---------|---------|---------------|
| 1 | STARTED | `stage_1()` | Hash pliku, backup, utworzenie wpisu w `i18n_file_status.json` | hash, type |
| 2 | ANALYSIS | `stage_2()` | Analiza: `StdModule.say`, `greet/farewell`, `needs_migration` flag | stdmod_count, greet_farewell, needs_migration |
| 3 | DOCUMENTATION | `stage_3()` | Generowanie `.md` z oryginalnym tekstem, tabela klucz→tekst EN | doc_file, keys_documented |
| 4 | TRANSFORMATION | `stage_4()` | Przepisanie kodu: `text="..."` → `i18nKey="key"`, `npcHandler:say(...)` → `NPC_LIB.i18n.npcSay(...)` | total_transformed, stdmod_t, npcsay_t, voices_t |
| 5 | EXTRACTION_EN | `stage_5()` | Ekstrakcja kluczy do `i18n/en/npc.json` | keys_added |
| 6 | TRANSLATION | `stage_6()` | Placeholder — syncuje `[EN]` do wszystkich języków | — (sync) |
| 7 | VALIDATION | `stage_7()` | Walidacja Lua + sprawdzenie kluczy JSON | lua_valid, json_valid |
| 8 | SYNC | `stage_8()` | Aktualizacja `i18n_file_status.json`, `i18n_processed_files.txt` | overall_status=completed |

**Aktualny stan NPC:**

| Metryka | Wartość | Źródło |
|---------|---------|--------|
| Pliki NPC w workspace | **1 028** | `data-otservbr-global/npc/*.lua` |
| Przetworzone (completed) | **789** (77%) | `i18n_processed_files.txt` |
| Zostało do przetworzenia | **239** | — |
| Pliki w `i18n_file_status.json` | **499** (tylko NPC) | stage_1 = 499, stage_2 = 499 |
| Z etapem transformation (4) | **138** | Reszta = tylko analiza |
| Z etapem extraction (5) | **1 897** (w tym scripts/inne) | — |
| NPC zmigrowane (mają i18n) | zob. `npc_migrated` | `translation_global_overview.json` |
| NPC do migracji | zob. `needs_migration_npc` | j.w. |

**Problemy migracji NPC:**

| Problem | Opis | Skala | Rozwiązanie |
|---------|------|-------|-------------|
| Voices w tabeli | `npcConfig.voices = { {text = "...", yell = true} }` — table concat, nie prosty string | **9 817** table concat w przetworzonych plikach | Wymaga dedykowanego parsera tabel Lua |
| Złożone say patterns | `npcHandler:say({...}, ...)` z tablicą wariantów tekstu | Trudne do dekompresji | Częściowo obsłużone w stage_4 |
| Multi-message | NPC mówi kilka rzeczy w sekwencji (`addTalkCallback` z ifami) | Wiele kluczy na 1 callback | Wymaga analizy control flow |
| Embedded Lua expressions | `"You have " .. player:getLevel() .. " levels"` — dynamiczne | **18** concat `..` przypadków | Wymaga `string.format` refactor |
| Resztkowe hardcoded | 1 plik (`walter_jaeger.lua`) nadal ma hardcoded `sendTextMessage` | **1** call | Manualna poprawka |

**Co powinno trafić do historii (sekcja MIGRATION w snapshort godzinowym):**

```markdown
### 🔧 Migracja NPC (1h)

| Metryka | Wartość |
|---------|---------|
| Plików przetworzonych | +12 |
| Kluczy wyekstrahowanych | +340 |
| Transformacji kodu | +89 |
| Plików z błędami | 0 |
| Pozostało NPC | 227 / 1028 (78% done) |
```

---

### 5.13.2 Tryb MIGRATION — Scripts (sendTextMessage / say / broadcast)

Worker migruje pliki skryptów `.lua` za pomocą **3 narzędzi Python**:

| Narzędzie | Plik | Linii kodu | Co robi |
|-----------|------|-----------|---------|
| `i18n_migrate_lua_sendtext.py` | 338 linii | `player:sendTextMessage(TYPE, "text")` → `player:sendLocalizedTextMessage(TYPE, "key")` |
| `i18n_migrate_lua_say.py` | 363 linii | `creature:say("text")` → `creature:sayLocalized("key")` |
| `i18n_migrate_lua_broadcast.py` | 337 linii | `broadcastMessage("text")` → `broadcastLocalizedMessage("key")` |

**Jak działa `process_scripts_file()`:**
1. Uruchom `i18n_migrate_lua_sendtext.py` → zamień sendTextMessage na sendLocalizedTextMessage
2. Walidacja Lua (`validate_lua_file`) → jeśli fail: przywróć backup
3. Uruchom `i18n_migrate_lua_say.py` → zamień `:say()` na `:sayLocalized()`
4. Ponowna walidacja Lua → jeśli fail: przywróć backup
5. Uruchom `i18n_migrate_lua_broadcast.py` → zamień broadcastMessage
6. Końcowa walidacja
7. Zapis kluczy do `i18n/en/scripts.json`
8. Oznacz plik w `i18n_processed_files.txt`

**Aktualny stan Scripts:**

| Metryka | Wartość |
|---------|---------|
| Pliki Lua scripts w workspace | **1 780** |
| Przetworzone (w processed_files) | **965** (54%) |
| Pozostało do przetworzenia | **815** |
| Plików z hardcoded (spośród pozostałych) | **5** plików, **7** callów |

**Co obsługuje narzędzie ✅:**
- Proste stringi literalne: `sendTextMessage(TYPE, "Hello world")`
- `string.format()`: `sendTextMessage(TYPE, string.format("You have %d gold", amount))`
- Obie składnie: `:sendTextMessage(...)` i `.sendTextMessage(...)`
- Komentarze — poprawnie pomijane

**Czego NIE obsługuje ❌:**

| Wzorzec | Przykład | Dlaczego trudne | Ile w workspace |
|---------|---------|-----------------|-----------------|
| Konkatenacja `..` | `"You found " .. item:getName() .. "!"` | Parser nie łączy fragmentów, `item:getName()` to runtime | **18** callów z `..` |
| Zagnieżdżony `string.format` | `string.format("Level %d of %d", lvl, maxLvl)` z logiką branching | Klucz musi obsłużyć zmienne pozycyjne | **4** callów |
| Zmienne jako string | `sendTextMessage(TYPE, myVar)` — myVar to zmienna | Nie da się określić tekstu w compile-time | Nieznane |
| Wieloliniowe stringi | `[[ ... ]]` Lua long strings | Inny syntax parsowania | Rzadkie |
| Callback chains | Tekst budowany w pętli/warunkach i dopiero na końcu wysyłany | Wymaga analizy data flow | Sporadyczne |

**Dodatkowe narzędzia migracji (OTClient):**

| Narzędzie | Plik | Co robi |
|-----------|------|---------|
| `i18n_migrate_otclient_otui_text.py` | 186 linii | Migracja `.otui` — `text: "..."` → `text-i18n: key` |
| `i18n_migrate_otclient_tr.py` | 300 linii | Migracja `tr("...")` w Lua klienta → klucze i18n |

---

### 5.13.3 Tryb MIGRATION — Pozostałe 20 kategorii

Worker przetwarza **20 kategorii** plików źródłowych:

| # | Kategoria | Funkcja | Pliki źródłowe | Ekstrakcja |
|---|-----------|---------|---------------|------------|
| 1 | **scripts** | `process_scripts_file()` | `data-otservbr-global/scripts/**/*.lua` | sendTextMessage, say, broadcast → klucze |
| 2 | **monsters** | `process_monsters_category()` | `data-otservbr-global/monster/**`, `data-canary/monster/**` | Nazwy, opisy z XML/Lua |
| 3 | **spells** | `process_spells_category()` | `data-otservbr-global/scripts/spells/**` | Spell names, descriptions |
| 4 | **items** | `process_items_category()` | `items.xml` | Item names, descriptions z XML |
| 5 | **raids** | `process_raids_category()` | `data-otservbr-global/raids/**` | Raid messages |
| 6 | **world** | `process_world_category()` | `data-otservbr-global/world/**` | World messages |
| 7 | **libs** | `process_libs_category()` | `data/libs/**`, `data-otservbr-global/lib/**` | Library strings |
| 8 | **events** | `process_events_category()` | `data/events/**`, `data-otservbr-global/events/**` | Event messages |
| 9 | **chatchannels** | `process_chatchannels_category()` | `data/chatchannels/**` | Channel names/descriptions |
| 10 | **modules** | `process_modules_category()` | `data/modules/**`, `data-otservbr-global/modules/**` | Module strings |
| 11 | **startup** | `process_startup_category()` | `data-otservbr-global/startup/**` | Startup messages |
| 12 | **npclib** | `process_npclib_category()` | NPC library files | Library strings |
| 13 | **php** | `process_php_category()` | PHP web files (jeśli istnieją) | Web strings |
| 14 | **html** | `process_html_category()` | HTML/template files | UI text |
| 15 | **cpp** | `process_cpp_category()` | `src/**/*.cpp`, `src/**/*.hpp` | C++ user-facing strings |
| 16 | **client** | `process_client_category()` | `testyy/modules/**`, `testyy/mods/**` | OTClient Lua/OTUI strings |
| 17 | **sendTextMessage** | `process_sendTextMessage_category()` | Skrypty z sendTextMessage | Fizyczna migracja kodu |
| 18 | **keywordHandler** | `process_keywordHandler_category()` | NPC z keywordHandler | Migracja keyword patterns |
| 19 | **twig** | `process_twig_category()` | Szablony Twig (web) | Template strings |
| 20 | **generic** | `process_generic_category()` | Fallback dla reszty | Generyczny regex na stringi |

**Aktualny stan per kategoria:**

| Kategoria | Plików total | Przetworzonych | % | Uwagi |
|-----------|-------------|----------------|---|-------|
| npc | 1 028 | 789 | 77% | 239 plików pozostało |
| scripts | 1 780 | 965 | 54% | 815 plików, 5 z hardcoded |
| libs | 82 | 81 | 99% | Praktycznie ukończone |
| events | 4 | 4 | 100% | ✅ Gotowe |
| startup | 20 | 20 | 100% | ✅ Gotowe |
| cpp/hpp/h | **437** | **26** | **6%** | 🔴 Najsłabsze pokrycie |

---

### 5.13.4 Tryb MIGRATION — C++ (`process_cpp_category()`)

Ekstrakcja stringów z kodu C++ silnika serwera:

**Jak działa:**
1. `find src -name "*.cpp" -o -name "*.hpp"` → lista plików
2. Regex `"([^"]{10,100})"` — wyciąga stringi 10-100 znaków
3. Filtry: pomiń `%`, `\\`, `::`, `->`, `/`, `.`, `_` (kod/ścieżki/formaty)
4. Tylko stringi z literami i spacjami (`[a-zA-Z].*[[:space:]].*[a-zA-Z]`)
5. Max 5 stringów per plik
6. Zapis do `i18n/en/cpp.json`

**Aktualny stan C++:**

| Metryka | Wartość |
|---------|---------|
| Plików C++/HPP/H w `src/` | **437** |
| Przetworzonych | **26** (6%) |
| Plików z user-facing stringami (nieprzetworzonych) | **94** |
| Szacunkowa liczba user-facing stringów | **~1 037** |

**Problemy C++:**

| Problem | Opis | Przykład |
|---------|------|---------|
| Fałszywe positive | Stringi logowania/debug wyglądają jak UI | `"Player disconnected from lobby"` → debug, nie UI |
| Enum/const stringi | `const char* MSG = "..."` — trudno odróżnić od runtime | Wymaga analizy kontekstu |
| Compile-time concat | `"Part1" "Part2"` → jedna linijka | Parser widzi 2 stringi |
| Template strings | `fmt::format("...", args)` — fmt library | Wymaga fmt-aware parsera |
| Makra (defines) | `#define MSG "..."` → tekst w preprocessorze | Nie widoczne jako string w runtime |
| Brak sendLocalizedTextMessage w C++ | C++ nie ma jeszcze API `sendLocalizedTextMessage` | Wymaga implementacji w silniku |

**Kluczowy problem**: Nawet jeśli wyekstrahujemy klucze z C++, **silnik serwera nie ma jeszcze mechanizmu lokalizacji** (brak i18n API w C++). Potrzebna implementacja:
- `Player::sendLocalizedTextMessage(type, key, args)` w C++
- Ładowanie JSON tłumaczeń per język gracza
- Lookap klucza → tekst w języku gracza

**Co powinno trafić do historii:**

```markdown
### ⚙️ Migracja C++ (snapshot 1h)

| Metryka | Wartość |
|---------|---------|
| Plików przeskanowanych | +5 |
| Stringów wyekstrahowanych | +23 |
| Filtrowanych (pominięto) | 48 |
| Plików z błędami | 0 |
| Pokrycie C++ | 31/437 (7.1%) |
| User-facing pozostało | ~1 014 |
```

---

### 5.13.5 Tryb DOCUMENTATION (etap 3 MIGRATION + IDLE doc gen)

Dokumentacja generowana w 2 miejscach:

#### A. Etap 3 migracji NPC (`stage_3`)

Generuje per-NPC Markdown w `docs/i18n/npc/{name}.md`:
- Parsuje backup pliku (oryginalne `text = "..."`)
- Tabela: klucz i18n → oryginalny tekst EN
- Metadane: plik źródłowy, data migracji, liczba tekstów
- **Status**: Działa OK, 497 plików z etapem 3

#### B. IDLE: `generate_npc_documentation()`

Generuje dokumentację per-kategoria w `docs/i18n/categories/{category}.md`:
- Dynamicznie z `i18n/en/*.json`
- Statystyki: ile kluczy, ile języków przetłumaczonych
- Tabela: język → count → coverage%
- Przykładowe klucze (first 10)
- **Status**: Działa w trybie IDLE, odświeża automatycznie

**Problemy dokumentacji:**

| Problem | Opis | Wpływ |
|---------|------|-------|
| Brak diff/delta | Doc generowana od nowa za każdym razem → brak historii zmian | Nie wiadomo co się zmieniło |
| Brak C++ doc | Dokumentacja NPC OK, ale brak doc dla C++ strings | C++ strings bez kontekstu |
| Brak kontekstu | Klucz `npc.oliver.stdmod_3` bez info co to za NPC i jaki quest | Tłumacz nie wie kontekstu |
| Brak automatycznego odświeżania | Doc generowana tylko w IDLE — może być stale | Outdated |

**Co powinno trafić do historii:**

| Metryka | Źródło | Opis |
|---------|--------|------|
| `docs_generated` | IDLE cycle counter | Ile doc plików wygenerowano/zaktualizowano |
| `docs_npc_count` | `docs/i18n/npc/*.md` | Ile NPC ma dokumentację |
| `docs_categories_count` | `docs/i18n/categories/*.md` | Ile kategorii ma doc |
| `docs_outdated_count` | timestamp compare | Ile doc jest starsze niż 7 dni |
| `docs_coverage_npc` | docs_npc / total_npc * 100 | % pokrycia doc NPC |

---

### 5.13.6 Tryb TRANSLATION_SYNC

Synchronizacja kluczy EN → wszystkie języki:
- Dla każdego `i18n/en/{category}.json` → sprawdź `i18n/{lang}/{category}.json`
- Brakujące klucze → dodaj jako `[EN] Original text`
- Istniejące klucze → nie nadpisuj

**Aktualny stan:**

| Metryka | Wartość |
|---------|---------|
| Kluczy EN (total) | **53 586** |
| Kategorii JSON | **~20** |
| Języków docelowych | **51** |
| `[EN]`-prefix backlog (szacunek) | Zależy od języka — zob. coverage |

**Problemy SYNC:**

| Problem | Opis |
|---------|------|
| Ogromna liczba kluczy | 53k × 51 = ~2.7M operacji sync |
| Konflikty merge | Jeśli ktoś edytuje ręcznie plik JSON w tym samym czasie |
| Encoding | Unicode w kluczach/wartościach → `ensure_ascii=False` |
| Duże pliki | `items.json` (~16k kluczy) — wolne do parsowania |

**Co powinno trafić do historii:**

| Metryka | Źródło | Opis |
|---------|--------|------|
| `keys_synced` | sync log | Ile kluczy dodano jako `[EN]` prefix |
| `files_synced` | sync log | Ile plików JSON zaktualizowanych |
| `langs_synced` | sync log | Dla ilu języków wykonano sync |
| `sync_duration_ms` | cycle perf | Czas trwania sync |
| `sync_errors` | errors.jsonl | Błędy podczas sync |

---

### 5.13.7 Tryb COMPACT_KEYS

Kompresja kluczy i18n do krótszej formy (keymap):

| Etap | Opis |
|------|------|
| `keymap_sync` | Sync keymap z kluczami EN |
| `keymap_verify` | Weryfikacja spójności keymap |
| `export` | Export compact keys |

**Co powinno trafić do historii:**

| Metryka | Opis |
|---------|------|
| `keymap_entries` | Ile kluczy w keymap |
| `keymap_new` | Ile nowych kluczy dodano |
| `keymap_orphaned` | Ile kluczy nie ma odpowiednika w EN |
| `export_size_bytes` | Rozmiar eksportu |

---

### 5.13.8 Tryb VALIDATION

Walidacja jakości tłumaczeń:

**Istniejące walidatory (validate_translation_quality):**
- `_candidate_shape_ok()` — ratio check per language
- `_auto_fix_translation()` — autofixy F1-F6
- `detect_suspicious()` — S1-S12 (12 reguł)
- `validate_per_lang()` — Cyrillic/CJK/RTL/Exotic script check
- `validate_key()` — V1-V7 per-key validation

**Co powinno trafić do historii:**

| Metryka | Źródło | Opis |
|---------|--------|------|
| `keys_validated` | quality_report | Ile kluczy zwalidowano |
| `issues_found` | quality_report | Ile problemów wykryto |
| `issues_by_rule` | quality_report per S1-S12 | Breakdown per reguła |
| `auto_fixed` | repair log | Ile naprawiono automatem (F1-F6) |
| `quality_score_per_lang` | dashboard | Quality score per język |
| `reject_rate` | guard_report | % odrzuceń przez guard |

---

### 5.13.9 Tryb IDLE

Worker w trybie IDLE wykonuje 3 zadania:

| Zadanie | Funkcja | Co robi |
|---------|---------|---------|
| Skan nowych plików | `scan_new_files()` | Szuka `.lua` w workspace które nie są w `i18n_processed_files.txt`, sprawdza patterns do migracji |
| Generowanie doc | `generate_npc_documentation()` | Generuje/aktualizuje `.md` per kategoria |
| Audyt jakości | `validate_translation_quality()` | Pełny przegląd jakości tłumaczeń |

**Raport z `scan_new_files()`:**
- Zapisywany w `i18n/new_files_detected.json`
- Zawiera: `total_new`, `needs_migration`, lista plików
- Wzorce: `StdModule.say(...)`, `npcHandler:say(...)`, `npcConfig.voices`

**Co powinno trafić do historii:**

| Metryka | Źródło | Opis |
|---------|--------|------|
| `new_files_detected` | `new_files_detected.json` | Ile nowych plików wykryto |
| `new_files_needs_migration` | j.w. | Ile z nich wymaga migracji |
| `idle_cycles` | cycle perf | Ile cykli w trybie IDLE |
| `quality_issues_found` | audit | Ile issue znaleziono w audycie |
| `docs_refreshed` | doc gen | Ile doc odświeżono |

---

### 5.13.10 Globalna statystyka hardcoded — co pozostało do migracji

**Podsumowanie z 2026-02-14 (realna analiza workspace):**

| Kategoria źródłowych | Total plików | Przetworzonych | Pozostało | % done |
|----------------------|-------------|----------------|-----------|--------|
| NPC (`.lua`) | 1 028 | 789 | 239 | **77%** |
| Scripts (`.lua`) | 1 780 | 965 | 815 | **54%** |
| Libraries (`.lua`) | 82 | 81 | 1 | **99%** |
| Events (`.lua`) | 4 | 4 | 0 | **100%** |
| Startup (`.lua`) | 20 | 20 | 0 | **100%** |
| **C++/HPP/H** | **437** | **26** | **411** | **6%** |
| **ŁĄCZNIE** | **3 351** | **1 885** | **1 466** | **56%** |

**Resztkowe hardcoded w przetworzonych plikach:**

| Wzorzec | Wystąpień | Opis |
|---------|-----------|------|
| **Table concat** `{...text="..."...}` | **9 817** | Główny problem — tabele Lua z tekstami w NPC voices/say arrays |
| **Concat `..`** | **18** | `"text" .. var .. "text"` — dynamiczne stringi |
| **`string.format()`** | **4** | Format stringi z wieloma argumentami |
| **Resztkowy sendTextMessage** | **1** | `walter_jaeger.lua` |
| **ŁĄCZNIE resztkowych** | **~9 840** | Wymaga zaawansowanego parsera |

**Hardcoded w C++ (nieprzetworzonych):**

| Metryka | Wartość |
|---------|---------|
| Plików z user-facing stringami | **94** |
| Szacunkowa liczba stringów | **~1 037** |
| Problemowe (debug/log vs UI) | ~60% to debug, ~40% to UI |
| Faktycznie user-facing do migracji | **~400-500** |

**Co powinno trafić do historii (sekcja "Migracja — Big Picture"):**

```markdown
## 🔧 Migracja — Big Picture

| Kategoria | Done | Total | % | Δ dzień |
|-----------|------|-------|---|---------|
| NPC .lua | 798 | 1028 | 77.6% | +9 |
| Scripts .lua | 970 | 1780 | 54.5% | +5 |
| C++/HPP | 26 | 437 | 5.9% | +0 |
| Resztkowe hardcoded | 9840 | — | — | -12 (fixed) |
| Łącznie | 1894 | 3351 | 56.5% | +14 |
```

---

### 5.13.11 Plan implementacji historii multi-mode

| # | Zadanie | Estymacja | Priorytet | Zależności |
|---|---------|-----------|----------|-----------|
| 5.13-I1 | Dodać `mode_distribution` do snapshort godzinowego | 30 min | **P1** | 5.10b |
| 5.13-I2 | Sekcja "Migracja NPC" w daily summary: pliki/kluczy/etapy | 1h | **P1** | 5.10h |
| 5.13-I3 | Sekcja "Migracja Scripts" w daily summary: sendText/say/broadcast stats | 45 min | **P1** | 5.10h |
| 5.13-I4 | Sekcja "C++ Mining" w daily summary: pliki/stringi/pokrycie | 30 min | **P2** | 5.10h |
| 5.13-I5 | Sekcja "SYNC" w daily summary: keys_synced/langs | 30 min | **P2** | 5.10h |
| 5.13-I6 | Tracker `hardcoded_remaining` — resztkowe 9.8k + C++ | 1h | **P2** | 5.13-I2,I3 |
| 5.13-I7 | IDLE metrics w weekly summary: new_files, quality_audit | 30 min | **P3** | 5.10i |
| 5.13-I8 | "Big Picture" tabela w weekly — wszystkie kategorie % | 30 min | **P1** | 5.10i |
| 5.13-I9 | ETA per kategoria migracji (nie tylko tłumaczeń) | 30 min | **P2** | 5.13-I8 |
| 5.13-I10 | Doc generation tracker — outdated/fresh count | 20 min | **P3** | 5.13-I7 |
| 5.13-I11 | Compact keys stats w weekly | 15 min | **P3** | 5.10i |
| 5.13-I12 | Resztkowe hardcoded trend chart (text-based) | 45 min | **P2** | 5.13-I6 |
| **SUMA** | | **~7h** | | |

**Łączna estymacja pełnej historii (Faza 5 + 5.13):**

| Komponent | Estymacja |
|-----------|-----------|
| Faza 5 podstawowa (AUTO_TRANSLATE) | ~3.5h |
| 5.13 rozszerzenie multi-mode | ~7h |
| **ŁĄCZNIE** | **~10.5h** |

---

### 5.13.12 Przykład pełnego daily summary z wszystkimi trybami

```markdown
## 📅 Podsumowanie dzienne: 2026-02-14 (24h)

### 🤖 Tłumaczenie (AUTO_TRANSLATE)
| Metryka | Wartość |
|---------|---------|
| Kluczy przetłumaczonych | 45 352 |
| Throughput | 1 889 kluczy/h |
| Guard fail rate | 5.2% |
| Repair queue | 6 537 → 4 752 (-27%) |

### 🔧 Migracja kodu
| Kategoria | Plików +done | Kluczy +extracted | % total |
|-----------|-------------|-------------------|---------|
| NPC .lua | +9 | +245 | 77.6% |
| Scripts .lua | +5 | +18 | 54.5% |
| C++ | +0 | +0 | 5.9% |
| Table concat fixed | — | -12 resztkowych | 9 828 zost. |

### 🌍 Synchronizacja (SYNC)
| Metryka | Wartość |
|---------|---------|
| Klucze zsync. | 1 200 |
| Języki | 51 |
| Czas | 4.2 min |

### 📚 Dokumentacja & Audyt
| Metryka | Wartość |
|---------|---------|
| Doc plików odświeżonych | 8 |
| Quality issues znaleziono | 27 |
| Nowe pliki wykryte | 0 |
```

---

### 5.13.13 Źródła danych dla multi-mode historii

Uzupełnienie tabeli z 5.1 o dane multi-mode:

| Źródło | Tryb | Klucze/metryki |
|--------|------|---------------|
| `i18n_file_status.json` | MIGRATION | stages per file, overall_status, keys_added |
| `i18n_processed_files.txt` | MIGRATION | Lista zakończonych plików |
| `i18n/new_files_detected.json` | IDLE | total_new, needs_migration |
| `ops.jsonl` → `phase=MIGRATION` | MIGRATION | Cykle migracji, pliki, klucze |
| `ops.jsonl` → `phase=COMPACT_KEYS` | COMPACT | Keymap sync/verify/export |
| `ops.jsonl` → `phase=TRANSLATION_SYNC` | SYNC | keys_synced, files |
| `errors.jsonl` | Wszystkie | Błędy per tryb |
| `worker_cycle_perf.jsonl` → `mode` field | Wszystkie | mode_distribution, duration per mode |
| `translation_global_overview.json` → `migration` | MIGRATION | files_total, files_completed, scanned_files |
| `statusd_daily_report.json` → `migration` | MIGRATION | Aktualny stan migracji |
| `i18n_global_stats.json` → `migration` | MIGRATION | files_scanned, keys_extracted |

---

### 5.13.14 Zmienne konfiguracyjne multi-mode

```bash
# Rozszerzenie konfiguracji z 5.12 o multi-mode
HISTORIA_INCLUDE_MIGRATION=true            # Sekcja migracji w daily/weekly
HISTORIA_INCLUDE_SYNC=true                 # Sekcja sync w daily
HISTORIA_INCLUDE_COMPACT=false             # Compact keys (rzadki tryb)
HISTORIA_INCLUDE_IDLE=true                 # IDLE metrics
HISTORIA_INCLUDE_DOC=true                  # Doc generation stats
HISTORIA_HARDCODED_SCAN_INTERVAL=86400     # Co ile sekund skanować resztkowe hardcoded (1/dzień)
HISTORIA_CPP_SCAN_INTERVAL=86400           # Co ile sekund skanować C++ stringi
HISTORIA_MIGRATION_BIG_PICTURE=true        # Tabela "Big Picture" w weekly
```

---

## Changelog

| Data | Zmiana |
|------|--------|
| 2026-02-14 | Utworzenie dokumentu. Audyt: 21 języków EU, diakrytyki, throughput, SIMPLE_TRANSLATIONS gap |
| 2026-02-14 | Faza 1 DONE: TIER2 +nl/cs/sk/hu, WEIGHT=3, S12 diacritics, 20 EU SIMPLE_TRANSLATIONS |
| 2026-02-14 | Import ZIP: FR 43.6%, RU 44.0%, RO 21.7%, BG 11.4%, DE 9.6%, NL 11.2% genuine |
| 2026-02-14 | Cel: **100% pokrycia** i **100% jakości gramatycznej** we wszystkich językach |
| 2026-02-15 | Faza 2 DONE: turbo batch (apply_turbo_batch), per-tier category priority (T1/T2/T3), repair queue T2/T3 (REPAIR_T2_LIMIT=50, REPAIR_T3_LIMIT=20) |
| 2026-02-15 | Faza 3 DONE: per-language ratio bounds w _candidate_shape_ok(), FI/HU/ET→0.40-4.0, CJK→0.20-2.0 |
| 2026-02-15 | Faza 4 DONE: statusd KPI genuine/backlog/diacritics per T2, doctor lang_parity alert (CRIT <100 genuine@72h, WARN >5k backlog@48h) |
| 2026-02-14 | Faza 5 PLAN: pełny plan historii postępu (5.0–5.13.14), ~1400 linii dokumentacji |
| 2026-02-14 | Faza 5 IMPL: MODUŁ 9 w statusd ✅ — run_historia_snapshot(), aggregate_daily_progressive(), aggregate_weekly(), render_historia_md(). Pliki: historia_snapshots.jsonl, historia_daily.json, historia_weekly.json, i18n_status_historia.md. CLI: --historia. Integracja z daemon loop (co 1h). Przetestowane ✅ |
| 2026-02-14 | Grammar checks ✅: S13 (DE noun capitalization after articles), S14 (FR punctuation spacing before ;:!?). Dodane do detect_suspicious() w workerze. |
