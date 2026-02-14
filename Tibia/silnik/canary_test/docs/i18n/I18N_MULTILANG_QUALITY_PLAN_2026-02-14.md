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

### Faza 1: Szybkie wygrane (1-2 dni) ⬜

#### 1a. Rozszerzyć TIER2 o kluczowe języki EU ⬜

Obecny TIER2: `de pt ru tr fr it`  
Proponowany TIER2: `de pt ru tr fr it nl cs sk hu`

**Uzasadnienie**: nl/cs/sk/hu to ważne języki EU z unikalnymi regułami pisowni.

```bash
# i18n_worker_simple.sh linia 82
TIER2_LANGS="de pt ru tr fr it nl cs sk hu"
```

#### 1b. Podnieść TIER2_WEIGHT z 2 na 3 ⬜

Aby T2 szybciej nadgonił zaległy backlog `[EN]`-prefixów.

```bash
TIER2_WEIGHT=3  # było 2
```

#### 1c. Dodać SIMPLE_TRANSLATIONS dla 15 języków EU ⬜

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

#### 1d. Dodać walidator diakrytyków (ostrzeżenie, nie blokada) ⬜

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

### Faza 2: Zwiększenie throughput T2/T3 (3-5 dni) ⬜

#### 2a. Dodać tryb "turbo" dla T2 z dużym backlogiem ⬜

Jeśli język ma >8000 `[EN]`-prefixów, zwiększ batch_size z 10 na 30:

```bash
# Dynamiczny batch: im więcej [EN]-backlogu, tym większy batch
if en_backlog > 8000:
    batch_size = 30
elif en_backlog > 3000:
    batch_size = 20
else:
    batch_size = 10
```

#### 2b. Priorytet kategorii per tier ⬜

T1 (PL/ES): items → npc → monsters → server → ...  
T2 (DE/FR/...): **npc → items → monsters** (NPC mają najkrótsze teksty = szybciej)  
T3 (reszta): npc → server → monsters → items (najpierw łatwe)

#### 2c. Repair queue: włączyć identical_to_en repair dla T2 ⬜

Obecnie repair queue działa głównie dla PL/ES. Rozszerzyć na T2:
- DE ma ~30 200 identical_to_en — ogromny backlog
- FR ma ~30 400 identical_to_en

```python
REPAIR_TIERS = {
    "tier1": {"langs": ["pl","es"], "max_repair_per_cycle": 50},
    "tier2": {"langs": ["de","pt","ru","tr","fr","it","nl","cs","sk","hu"], "max_repair_per_cycle": 20},
    "tier3": {"langs": "...", "max_repair_per_cycle": 5},
}
```

### Faza 3: Per-language quality rules (1-2 tygodnie) ⬜

#### 3a. Per-language expansion factor ⬜

Zamiast stałego ratio 0.3–4.0, użyć kalibrowanych wartości:

| Język | EN → LANG ratio | Min | Max |
|-------|-----------------|-----|-----|
| DE | 1.20–1.35 | 0.4 | 3.5 |
| FR | 1.15–1.30 | 0.4 | 3.5 |
| ES | 1.10–1.25 | 0.4 | 3.5 |
| IT | 1.10–1.25 | 0.4 | 3.5 |
| PL | 1.05–1.20 | 0.4 | 3.5 |
| NL | 1.05–1.20 | 0.4 | 3.5 |
| CS | 0.95–1.15 | 0.4 | 3.5 |
| FI | 1.20–1.45 | 0.4 | 4.0 |
| HU | 1.25–1.50 | 0.4 | 4.0 |
| SV | 0.95–1.15 | 0.4 | 3.5 |
| RO | 1.05–1.20 | 0.4 | 3.5 |
| BG/RU/UK | 0.90–1.10 | 0.4 | 3.5 |
| EL | 1.10–1.30 | 0.4 | 3.5 |
| HR/SL/BS | 0.95–1.15 | 0.4 | 3.5 |
| CJK | 0.40–0.70 | 0.2 | 2.0 |
| AR/HE | 0.85–1.10 | 0.3 | 3.0 |

#### 3b. Specyficzne reguły pisowni per język (future) ⬜

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

#### 3c. EXT_SIMPLE_TRANSLATIONS.json rozszerzenie ⬜

Przenieść hardcoded `SIMPLE_TRANSLATIONS` do zewnętrznego pliku `simple_translations.json`
i dodać 15 języków EU z ~100 frazami gry każdy.

Fazy per język:
1. NPC greetings: "Hello", "Bye", "Yes", "No", "Trade", "Quest"
2. Items: "Gold", "Gold Coin", "Sword", "Shield", "Potion"
3. UI phrases: "You can't move that item so fast", "It is empty", "You are dead"
4. Monster names: zachować EN (nie tłumaczyć)

### Faza 4: Monitoring i telemetria wielojęzyczna (ciągłe) ⬜

#### 4a. Statusd: per-language throughput rate ⬜

Dodać do quality_dashboard:
- `genuine_translations` — ile prawdziwych tłumaczeń (bez [EN], bez identical)
- `en_backlog` — ile `[EN]`-prefixów do przetłumaczenia
- `diacritics_rate` — % tłumaczeń z oczekiwanymi diakrytykami (genuine only)

#### 4b. Doctor check: lang parity alert ⬜

Nowy check w `_doctor()`:
- Jeśli T2 lang ma >5000 `[EN]`-backlog po 48h → WARN
- Jeśli T2 lang ma <100 genuine translations po 72h → CRIT

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
| **W1** | Faza 1 | ⬜ Tier2 rozszerzenie, TIER2_WEIGHT=3, S12 diacritics |
| **W1** | Faza 1 | ⬜ SIMPLE_TRANSLATIONS 6 głównych EU |
| **W2** | Faza 2 | ⬜ Turbo batch, category priority per tier, repair queue T2 |
| **W3** | Faza 3 | ⬜ Per-language ratio, DE capitals, FR spaces |
| **W4** | Faza 4 | ⬜ Statusd telemetria, tygodniowy raport |
| **W5+** | Faza 3 | ⬜ SIMPLE_TRANSLATIONS reszta EU, grammar checks |

---

## Changelog

| Data | Zmiana |
|------|--------|
| 2026-02-14 | Utworzenie dokumentu. Audyt: 21 języków EU, diakrytyki, throughput, SIMPLE_TRANSLATIONS gap |
