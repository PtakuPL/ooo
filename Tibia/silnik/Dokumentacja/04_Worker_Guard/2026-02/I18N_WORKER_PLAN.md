# I18N Worker — Kompleksowy Plan Rozwoju

> **Data:** 2025-02-12 (aktualizacja)  
> **Wersja:** 1.1  
> **Repozytorium:** PtakuPL/ooo, branch `feature/i18n-multilanguage`  
> **Plik:** `i18n_worker_simple.sh` (~15 300 linii)

---

## Spis treści

1. [Stan obecny](#1-stan-obecny)
2. [Monitoring jakości tłumaczeń](#2-monitoring-jakości-tłumaczeń) ✅ **ZAIMPLEMENTOWANE**
3. [Wykrywanie podejrzanych/trudnych tłumaczeń](#3-wykrywanie-podejrzanych-trudnych-tłumaczeń) ✅ **ZAIMPLEMENTOWANE**
4. [Rozszerzenie tłumaczeń słownikowych (bez GT)](#4-rozszerzenie-tłumaczeń-słownikowych-bez-gt) ✅ **ZAIMPLEMENTOWANE**
5. [Plan obsługi 55 języków](#5-plan-obsługi-55-języków) 🟡 **CZĘŚCIOWO (INFRA GOTOWA, MASÓWKA W TOKU)**
6. [Walidacja per-język](#6-walidacja-per-język) ✅ **ZAIMPLEMENTOWANE**
7. [Cross-referencing z EN i PL](#7-cross-referencing-z-en-i-pl) ✅ **W DUŻEJ CZĘŚCI ZAIMPLEMENTOWANE**
8. [Optymalizacja wydajności (P0/P1)](#8-optymalizacja-wydajności-p0-p1) ✅ **ZAIMPLEMENTOWANE**
9. [Plan wykonania — kolejność kroków](#9-plan-wykonania--kolejność-kroków)

---

## 1. Stan obecny

### 1.1 Statystyki bazowe (2025-01-21)

| Metryka | Wartość |
|---------|---------|
| Klucze EN (source) | 53 421 |
| Języki docelowe | 52 |
| Kategorie (pliki JSON) | 38 |
| Języki z plikami ≥38 | 1 (es) |
| Języki z plikami = 32 | 51 |
| Brakujące pliki per język | 6 kategorii (errors, mounts, otclient_mods, otclient_src, otclient_tools, ui, world — puste) |

### 1.2 Pokrycie tłumaczeń (tiery)

| Tier | Zakres | Ile języków | Języki |
|------|--------|------------|--------|
| **Tier 1** | ≥50% | 2 | **es** (56.0%), **pl** (55.3%) |
| **Tier 2** | 10–49% | 50 | ar, az, bg, bn, bs, cs, da, **de** (11.9%), el, et, fa, fi, fr, he, hi, hr, hu, hy, id, it, ja, ka, kk, ko, lt, lv, mk, ml, ms, nl, no, **pt** (13.9%), ro, **ru** (13.8%), sk, sl, sq, sr, sv, sw, ta, te, th, tl, **tr** (12.6%), uk, uz, vi, zh, zh_TW |
| **Tier 3** | 1–9% | 0 | — |
| **Tier 4** | <1% | 0 | — |

**Obserwacja:** Większość języków Tier 2 ma identyczny wynik ~11.8% (6 286 kluczy) — to jest baseline z migracji (NPC dialogi z istniejących plików, wspólne tłumaczenia). Wyróżniają się: de (+53), pt (+1122), ru (+1068), tr (+448), es (+23624).

### 1.3 Pipeline tłumaczeń (obecny)

```
TM (Translation Memory) → SIMPLE_TRANSLATIONS → WORD_TRANSLATIONS → Google Translate → [placeholder]
```

| Etap | PL | TR | DE | ES | Inne |
|------|-----|-----|-----|-----|------|
| SIMPLE_TRANSLATIONS | ~300 fraz | ~292 fraz | ~15 fraz | ~15 fraz | 0 |
| WORD_TRANSLATIONS | ~338 słów | ~338 słów | 0 | 0 | 0 |
| Google Translate | ✅ | ✅ | ✅ | ✅ | ✅ (51/52 języków) |

### 1.4 Znane problemy

- `select_auto_translate_target_strict` trwa ~26s (skanuje wszystkie języki)
- `update_github_status` (STATUSPY) trwa ~21s i uruchamia się co cykl
- GT_LANG_MAP brakuje: `"zh_TW": "zh-TW"`, `"he": "iw"`
- SIMPLE/WORD_TRANSLATIONS tylko dla PL i TR (reszta języków = pure GT)
- Brak mechanizmu kontroli jakości po tłumaczeniu
- Brak wykrywania podejrzanych tłumaczeń
- Brak porównywania z PL/EN jako referencją

---

## 2. Monitoring jakości tłumaczeń

### 2.1 Raport po każdym cyklu tłumaczenia

**Cel:** Worker po każdym cyklu generuje krótki raport jakości i zapisuje do logów.

- **2.1.1** Dodać plik `i18n/status/quality_report.jsonl` (JSONL — jedna linia per raport)
  - Pola: `timestamp`, `lang`, `category`, `keys_translated`, `source_breakdown` (tm/simple/word/gt), `avg_length_ratio`, `suspicious_count`, `guard_fail_count`
- **2.1.2** Po każdym wywołaniu AUTOTRANSPY, Python zwraca rozszerzony JSON z sekcją `quality`:
  ```json
  {
    "quality": {
      "avg_en_len": 24.5,
      "avg_translated_len": 28.1,
      "length_ratio": 1.15,
      "suspicious_keys": ["npc.foo.greet_1"],
      "gt_guard_fails": 0,
      "identical_to_en": 3,
      "very_short_translations": 1,
      "very_long_translations": 0
    }
  }
  ```
- **2.1.3** Bash wrapper parsuje `quality` i loguje ostrzeżenia, jeśli:
  - `length_ratio` < 0.5 lub > 3.0 (podejrzane proporcje)
  - `suspicious_count` > 5 (dużo podejrzanych)
  - `gt_guard_fails` > 20% tłumaczonych

### 2.2 Cykliczny audyt jakości (co N cykli)

**Cel:** Co 10 cykli (lub co godzinę) worker uruchamia głębszy audyt.

- **2.2.1** Skrypt audytu (Python heredoc `QUALITY_AUDIT_PY`) sprawdza ostatnie 100 tłumaczeń z `translation_recent_report.jsonl`:
  - Ratio długości EN→LANG per klucz
  - Powtórzenia (ten sam klucz przetłumaczony tak samo w 5+ językach = prawdopodobnie niepoprawne)
  - Tłumaczenia identyczne z EN (false positive — mogą być poprawne dla nazw własnych)
  - Tłumaczenia zawierające `???`, `[LANG]`, `TODO`, `FIXME`
- **2.2.2** Wynik audytu → `i18n/status/quality_audit_latest.json`:
  ```json
  {
    "timestamp": "2025-01-21T15:00:00",
    "checked_entries": 100,
    "issues_found": 3,
    "issues": [
      {"key": "npc.foo.bar", "lang": "ja", "type": "length_anomaly", "ratio": 4.2, "en": "Hello", "translated": "こんにちは、冒険者よ！元気ですか？"},
      {"key": "items.123.name", "lang": "de", "type": "identical_to_en", "en": "Crystal Sword", "translated": "Crystal Sword"},
      {"key": "spells.fire.desc", "lang": "ar", "type": "placeholder_mismatch", "en": "Deals {0} damage", "translated": "يتسبب في ضرر"}
    ]
  }
  ```
- **2.2.3** Jeśli `issues_found` > threshold (np. 10), worker spowalnia (zmniejsza batch do 5) i loguje WARN

### 2.3 Dashboard jakości

- **2.3.1** Rozszerzyć `I18N_STATUS.md` o sekcję "Jakość tłumaczeń":
  - Ostatni audyt: data, wynik
  - Top 5 najczęstszych typów problemów
  - Języki z najgorszą jakością (najwyższy % podejrzanych)
- **2.3.2** Dodać plik `i18n/status/quality_dashboard.json` aktualizowany co audyt:
  - Per-język: `quality_score` (0–100), `last_audit`, `issues_count`

---

## 3. Wykrywanie podejrzanych/trudnych tłumaczeń

### 3.1 Definicja "podejrzanego" tłumaczenia

Tłumaczenie jest podejrzane, jeśli spełnia **jedno lub więcej** kryteriów:

| # | Kryterium | Opis | Priorytet |
|---|-----------|------|-----------|
| S1 | **Placeholder mismatch** | Liczba `{0}`, `%s`, `|NAME|` różni się EN vs LANG | CRITICAL |
| S2 | **Ekstremalny ratio długości** | len(LANG)/len(EN) < 0.3 lub > 4.0 | HIGH |
| S3 | **Identyczne z EN** | Tłumaczenie = EN, ale EN nie jest nazwą własną | MEDIUM |
| S4 | **Mieszane skrypty Unicode** | np. łacińskie litery w tłumaczeniu arabskim/japońskim | HIGH |
| S5 | **Zduplikowane w wielu językach** | To samo tłumaczenie w 5+ językach (prawdopodobnie EN-copy) | MEDIUM |
| S6 | **Zawiera artefakty** | `???`, `[LANG]`, `TODO`, `sNiew`, `piaNie` | HIGH |
| S7 | **Brak wielkich liter (gdzie EN ma)** | EN zaczyna się wielką literą, LANG nie (zależne od pisma) | LOW |
| S8 | **Tłumaczenie dłuższe niż 500 znaków, EN < 50** | Eksplozja tekstu | MEDIUM |
| S9 | **Powtórzony wyraz 3+ razy** | Np. "ogień ogień ogień" — zacięcie GT | HIGH |
| S10 | **Niekompletne zdanie** | Brak kropki/znaku na końcu, gdzie EN ma | LOW |

### 3.2 Implementacja detektora

- **3.2.1** Nowa funkcja Python `detect_suspicious(en_text, translated_text, lang) → list[Issue]`
  - Uruchamiana na KAŻDYM tłumaczeniu (w AUTOTRANSPY)
  - Zwraca listę Issue z typem, severity, opisem
- **3.2.2** Podejrzane tłumaczenia:
  - `severity=CRITICAL` → **odrzuć tłumaczenie**, loguj do `suspicious_rejected.jsonl`
  - `severity=HIGH` → **oznacz flagą** `__suspicious: true` w metadata, przetłumacz ale loguj
  - `severity=MEDIUM/LOW` → **loguj** do `suspicious_log.jsonl`, nie blokuj

### 3.3 Trudne/techniczne tłumaczenia

**Definicja:** Tekst jest "trudny" jeśli zawiera:

- **3.3.1** Terminologię Tibia (spell names, item names, quest names)
  - Lista ~200 nazw własnych Tibia, które NIE powinny być tłumaczone
  - Plik: `i18n/status/tibia_proper_nouns.json`
  - Przykłady: "Exura", "Utamo Vita", "Rathleton", "Thais", "Ankrahmun"
- **3.3.2** Tekst z wieloma placeholder'ami (>3 w jednym kluczu)
  - Strategia: GT + ręczna walidacja placeholder'ów
- **3.3.3** HTML/formatowanie (`<b>`, `\n`, `|`)
  - Strategia: ochrona tagów przed GT (jak placeholder'y)
- **3.3.4** Tekst mieszany (EN + kod + placeholder)
  - Np. `"Use '/heal' to heal yourself for {0} HP"`
  - Strategia: komenda `'/heal'` → protect, reszta → GT

### 3.4 Reakcja na trudne tłumaczenia

- **3.4.1** Klucze z >3 flagami suspicious → **pomiń** (zostaw placeholder) i dodaj do `manual_review_queue.json`
- **3.4.2** `manual_review_queue.json` — kolejka do ręcznego sprawdzenia:
  ```json
  {
    "queue": [
      {"key": "npc.rashid.trade_1", "lang": "ja", "reason": "3 placeholders + game terms", "en_text": "...", "attempted_translation": "..."},
    ],
    "stats": {"total": 15, "reviewed": 0, "approved": 0, "rejected": 0}
  }
  ```
- **3.4.3** Worker sprawdza `manual_review_queue.json` co cykl — jeśli klucz został oznaczony jako `approved`, zastosuj tłumaczenie

---

## 4. Rozszerzenie tłumaczeń słownikowych (bez GT)

### 4.1 Cel

Zmniejszyć zależność od Google Translate przez rozszerzenie SIMPLE_TRANSLATIONS i WORD_TRANSLATIONS. Cel: 70%+ kluczy możliwych do przetłumaczenia słownikowo dla PL, 40%+ dla top-10 języków.

### 4.2 SIMPLE_TRANSLATIONS — rozszerzenie fraz

#### 4.2.1 Analiza najczęstszych fraz EN

- **Krok 1:** Skrypt analizuje WSZYSTKIE 53 421 wartości EN i liczy częstotliwość identycznych tekstów
- **Krok 2:** Top 500 najczęstszych fraz → kandydaci do SIMPLE_TRANSLATIONS
- **Krok 3:** Dla PL — dodać ręcznie/z GT + walidacja
- **Krok 4:** Dla innych języków — GT batch + walidacja

**Kategorie fraz do dodania:**

| Kategoria | Przykłady EN | Estymowana liczba |
|-----------|-------------|-------------------|
| Odpowiedzi NPC | "I can offer you...", "What do you need?" | ~50 |
| Opisy questów | "Mission completed!", "You have found..." | ~30 |
| Komunikaty systemowe | "You cannot...", "Not enough..." | ~40 |
| Opisy itemów | "It weighs X oz.", "You see a..." | ~30 |
| Nazwy efektów | "Healing", "Haste", "Strong Mana" | ~50 |
| Opisy stworzeń | "It is weak to...", "It drops..." | ~20 |
| Dialogi handlowe | "Do you want to buy...", "I will pay..." | ~30 |
| Komunikaty walki | "Critical hit!", "You have slain..." | ~20 |
| **RAZEM** | | **~270 nowych fraz** |

#### 4.2.2 Automatyczne wydobywanie fraz z istniejących tłumaczeń PL

- Skrypt porównuje EN→PL dla kluczy gdzie PL ≠ EN i ≠ placeholder
- Grupuje identyczne pary (EN→PL) — jeśli ta sama para pojawia się 3+ razy → automatycznie dodaj do SIMPLE_TRANSLATIONS
- To "uczy się" z istniejących tłumaczeń

#### 4.2.3 Generowanie SIMPLE_TRANSLATIONS dla innych języków

Dla każdego języka w Tier 2+:
1. Weź istniejące SIMPLE_TRANSLATIONS dla PL (300 fraz)
2. Przetłumacz przez GT na dany język (batch, z walidacją)
3. Zweryfikuj ręcznie top 50 najczęstszych
4. Zapisz do SIMPLE_TRANSLATIONS w kodzie workera

**Format rozszerzony — plik zewnętrzny:**
- Zamiast trzymać 52 × 300 fraz w kodzie bash (= 15 600 linii), przenieść do:
- `i18n/status/simple_translations.json`:
  ```json
  {
    "pl": {"Hello": "Witaj", "Goodbye": "Do widzenia", ...},
    "de": {"Hello": "Hallo", "Goodbye": "Auf Wiedersehen", ...},
    ...
  }
  ```
- AUTOTRANSPY ładuje plik JSON zamiast hardcoded dict

### 4.3 WORD_TRANSLATIONS — rozszerzenie słownika

#### 4.3.1 Analiza najczęstszych słów EN

- **Krok 1:** Tokenizuj WSZYSTKIE wartości EN, policz częstotliwość słów
- **Krok 2:** Top 500 najczęstszych słów → kandydaci do WORD_TRANSLATIONS
- **Krok 3:** Odfiltruj function words (the, a, is, are, etc.) — nie tłumaczyć per-słowo
- **Krok 4:** Odfiltruj nazwy własne Tibia (nie tłumaczyć)

#### 4.3.2 Kategorie do dodania (PL jako wzór)

| Kategoria | Przykłady | Est. słów |
|-----------|-----------|-----------|
| Stworzenia (brakujące) | basilisk, behemoth, banshee, cyclops, demon | ~100 |
| Itemsy (brakujące) | amulet, wand, rod, ring, backpack | ~80 |
| Lokacje | temple, depot, market, bridge, cave | ~40 |
| Przymiotniki | ancient, blessed, cursed, enchanted, golden | ~60 |
| Czasowniki | attack, cast, buy, sell, equip, trade | ~40 |
| Materiały | platinum, crystal, obsidian, amber, ivory | ~30 |
| **RAZEM** | | **~350 nowych słów** |

#### 4.3.3 Plik zewnętrzny WORD_TRANSLATIONS

- `i18n/status/word_translations.json` — analogicznie do simple_translations
- Łatwe do edycji, nie wymaga modyfikacji bash

### 4.4 Translation Memory (TM) — wzmocnienie

- **4.4.1** Po każdym udanym GT → automatycznie dodaj do TM
- **4.4.2** TM per-język: `i18n/status/tm/{lang}.json`
- **4.4.3** Priorytet: TM > SIMPLE > WORD > GT
- **4.4.4** TM z confidence score: `{"Hello": {"text": "Witaj", "source": "gt", "confidence": 0.9, "verified": false}}`
- **4.4.5** Ręcznie zweryfikowane tłumaczenia → `confidence: 1.0, verified: true`

---

## 5. Plan obsługi 55 języków

### 5.1 Mapowanie języków → Google Translate

| # | Kod i18n | Nazwa | Kod GT | Pismo | Status | Uwagi |
|---|----------|-------|--------|-------|--------|-------|
| 1 | ar | Arabic | ar | RTL/Arabic | ✅ | Wymaga walidacji RTL |
| 2 | az | Azerbaijani | az | Latin | ✅ | — |
| 3 | bg | Bulgarian | bg | Cyrillic | ✅ | — |
| 4 | bn | Bengali | bn | Bengali | ✅ | Egzotyczny skrypt |
| 5 | bs | Bosnian | bs | Latin | ✅ | — |
| 6 | cs | Czech | cs | Latin | ✅ | Znaki diakrytyczne |
| 7 | da | Danish | da | Latin | ✅ | — |
| 8 | de | German | de | Latin | ✅ | Composita |
| 9 | el | Greek | el | Greek | ✅ | — |
| 10 | es | Spanish | es | Latin | ✅ | **56% done** |
| 11 | et | Estonian | et | Latin | ✅ | — |
| 12 | fa | Persian | fa | RTL/Arabic | ✅ | Wymaga walidacji RTL |
| 13 | fi | Finnish | fi | Latin | ✅ | Długie composita |
| 14 | fr | French | fr | Latin | ✅ | — |
| 15 | he | Hebrew | **iw** | RTL/Hebrew | ⚠️ FIX | **GT_LANG_MAP brakuje `"he": "iw"`** |
| 16 | hi | Hindi | hi | Devanagari | ✅ | — |
| 17 | hr | Croatian | hr | Latin | ✅ | — |
| 18 | hu | Hungarian | hu | Latin | ✅ | — |
| 19 | hy | Armenian | hy | Armenian | ✅ | Egzotyczny skrypt |
| 20 | id | Indonesian | id | Latin | ✅ | — |
| 21 | it | Italian | it | Latin | ✅ | — |
| 22 | ja | Japanese | ja | CJK | ✅ | Brak spacji, ratio specjalny |
| 23 | ka | Georgian | ka | Georgian | ✅ | Egzotyczny skrypt |
| 24 | kk | Kazakh | kk | Cyrillic | ✅ | — |
| 25 | ko | Korean | ko | Hangul | ✅ | — |
| 26 | lt | Lithuanian | lt | Latin | ✅ | — |
| 27 | lv | Latvian | lv | Latin | ✅ | — |
| 28 | mk | Macedonian | mk | Cyrillic | ✅ | — |
| 29 | ml | Malayalam | ml | Malayalam | ✅ | Egzotyczny skrypt |
| 30 | ms | Malay | ms | Latin | ✅ | — |
| 31 | nl | Dutch | nl | Latin | ✅ | — |
| 32 | no | Norwegian | no | Latin | ✅ | — |
| 33 | pl | Polish | pl | Latin | ✅ | **55.3% done** — język referencyjny |
| 34 | pt | Portuguese | pt | Latin | ✅ | 13.9% (pt-BR baseline) |
| 35 | ro | Romanian | ro | Latin | ✅ | — |
| 36 | ru | Russian | ru | Cyrillic | ✅ | 13.8% |
| 37 | sk | Slovak | sk | Latin | ✅ | — |
| 38 | sl | Slovenian | sl | Latin | ✅ | — |
| 39 | sq | Albanian | sq | Latin | ✅ | — |
| 40 | sr | Serbian | sr | Cyrillic | ✅ | — |
| 41 | sv | Swedish | sv | Latin | ✅ | — |
| 42 | sw | Swahili | sw | Latin | ✅ | — |
| 43 | ta | Tamil | ta | Tamil | ✅ | Egzotyczny skrypt |
| 44 | te | Telugu | te | Telugu | ✅ | Egzotyczny skrypt |
| 45 | th | Thai | th | Thai | ✅ | Brak spacji |
| 46 | tl | Filipino | tl | Latin | ✅ | — |
| 47 | tr | Turkish | tr | Latin | ✅ | 12.6% |
| 48 | uk | Ukrainian | uk | Cyrillic | ✅ | — |
| 49 | uz | Uzbek | uz | Latin | ✅ | — |
| 50 | vi | Vietnamese | vi | Latin | ✅ | Diacritics |
| 51 | zh | Chinese (Simplified) | zh-CN | CJK | ✅ | — |
| 52 | zh_TW | Chinese (Traditional) | **zh-TW** | CJK | ⚠️ FIX | **GT_LANG_MAP brakuje `"zh_TW": "zh-TW"`** |

### 5.2 Wymagane poprawki GT_LANG_MAP ✅ (2026-02-12)

```python
GT_LANG_MAP = {
    "pt-br": "pt",
    "zh-cn": "zh-CN",
    "zh-tw": "zh-TW",
    "zh_TW": "zh-TW",   # ← DODAĆ (folder = zh_TW z underscore)
    "he": "iw",          # ← DODAĆ (Hebrew → iw w Google Translate)
    "sr": "sr",
    "bs": "bs",
    "no": "no",
    "nb": "no",
}
```

**Status:** wykonane w [i18n_worker_simple.sh](i18n_worker_simple.sh) (normalizacja kodów + `he -> iw` + obsługa `zh_TW`/`zh_tw`).

### 5.3 Grupy językowe — strategia tłumaczenia

#### Grupa A: Języki łacińskie (27 języków)
`az, bs, cs, da, de, es, et, fi, fr, hr, hu, id, it, lt, lv, ms, nl, no, pl, pt, ro, sk, sl, sq, sv, sw, tl, tr, uz, vi`

- **Strategia:** GT działa dobrze, WORD_TRANSLATIONS daje sens
- **Walidacja:** Standard (ratio, placeholder, artefakty)
- **WORD_TRANSLATIONS:** Możliwe do rozszerzenia

#### Grupa B: Języki cyrylicowe (6 języków)
`bg, kk, mk, ru, sr, uk`

- **Strategia:** GT działa dobrze
- **Walidacja:** Sprawdzić czy nie ma łacińskich liter w cyrylickim tekście (S4)
- **WORD_TRANSLATIONS:** NIE stosować (zmiana pisma per-słowo nie ma sensu)

#### Grupa C: Języki CJK (4 języki)
`ja, ko, zh, zh_TW`

- **Strategia:** GT wymagane, słowniki nieskuteczne
- **Walidacja:** Ratio specjalny (CJK krótsze), sprawdzenie skryptu
- **WORD_TRANSLATIONS:** NIE stosować
- **Uwaga:** ja i th — brak spacji między słowami → WORD_TRANSLATIONS niemożliwe

#### Grupa D: Języki RTL (3 języki)
`ar, fa, he`

- **Strategia:** GT wymagane
- **Walidacja:** Sprawdzić kierunek tekstu, placeholder'y na właściwych pozycjach
- **WORD_TRANSLATIONS:** NIE stosować (zmiana kierunku tekstu)
- **Uwaga:** `he` wymaga kodu `iw` w GT

#### Grupa E: Języki z egzotycznym pismem (8 języków)
`bn, el, hy, ka, ml, ta, te, th`

- **Strategia:** Pure GT
- **Walidacja:** Sprawdzenie skryptu Unicode (czy wynik jest w poprawnym piśmie)
- **WORD_TRANSLATIONS:** NIE stosować

### 5.4 Brakujące pliki JSON per język ✅ (2026-02-12)

Każdy język ma 32 pliki, EN ma 38. Brakujące 6 to puste kategorie:
- `mounts.json` (0 kluczy)
- `otclient_mods.json` (0 kluczy)
- `otclient_src.json` (0 kluczy)
- `otclient_tools.json` (0 kluczy)
- `questlog.json` (0 kluczy)
- `world.json` (0 kluczy)

**Status:** wykonane — utworzono 314 brakujących plików `{}`; walidacja po akcji: `langs_with_missing=0`, `missing_total=0`.

### 5.5 Plan masowego tłumaczenia

**Faza 1 — Infrastruktura (zadania 5.2, 5.4, sekcje 2–3):**
- Poprawić GT_LANG_MAP
- Utworzyć brakujące puste pliki
- Zaimplementować monitoring jakości
- Zaimplementować detektor podejrzanych

**Faza 2 — Języki Tier 1 (PL, ES) — doprowadzić do 90%:**
- PL: brakuje ~24 000 kluczy (z czego ~19 400 to placeholder'y do zastąpienia)
- ES: brakuje ~23 500 kluczy (z czego ~3 291 to placeholder'y)
- Użyć GT batch (50 kluczy/cykl) z walidacją

**Faza 3 — Języki "bliskie" (DE, PT, RU, TR) — doprowadzić do 50%:**
- Te języki mają już 12–14% → łatwiejszy start
- DE/PT/RU mają istniejące tłumaczenia z OTServ community
- Priorytet: NPC dialogi → itemy → spells → questy

**Faza 4 — Reszta Tier 2 (46 języków) — doprowadzić do 30%:**
- GT batch z walidacją
- Priorytet kategorii: `items` (16 894 kluczy), `npc` (13 769), `monsters` (5 915), `server` (2 574)
- Kategorie z krótkimi tekstami (items, monsters, spells) → wyższa jakość GT

**Faza 5 — Cross-referencing i poprawa jakości (sekcja 7)**

### 5.6 Plan operacyjny (podział ról) — AZ pilot jakości gramatycznej

#### Rola 1: Operator Workera (24/7)
- Uruchamia worker w `--continuous` z plikiem komend (`worker_commands.txt`).
- Zdalnie steruje cyklem przez komendy: `SWITCH`, `LANGVAL`, `SPOTCHECK`, `GRAMMARFIX`, `RESTART`.
- Pilnuje, aby każda komenda testowa miała wariant jednorazowy (`:ONCE`) przed masowym uruchomieniem.

#### Rola 2: Reviewer Językowy (AZ-first)
- Priorytet: `az/npc.json`, następnie `az/items.json`, `az/monsters.json`.
- Po każdej paczce poprawek z `GRAMMARFIX` sprawdza raporty walidacji i 20-próbkowy spotcheck.
- Oznacza reguły, które powodują regresje (fałszywe poprawki, naruszenia placeholderów).

#### Rola 3: Inżynier Reguł i Narzędzi
- Tuninguje heurystyki w `tools/i18n_grammar_refine.py` (detekcja EN-copy, artefaktów, ochrona tokenów).
- Na podstawie feedbacku reviewera aktualizuje limity i filtry kandydatów.
- Utrzymuje stabilność restartu (`RESTART`) i zgodność z walidacją per-język po każdej zmianie.

#### Rola 4: Raportowanie i Go/No-Go
- Generuje raport gotowości (`i18n/status/language_readiness.md`) po każdej większej serii komend.
- Decyzja `GO` dla nocnego runu tylko jeśli: brak CRITICAL, spójne placeholdery, brak trendu regresji w AZ.
- Decyzja `NO-GO` jeśli `crossref_total_issues` rośnie lub pojawiają się błędy guard/token.

#### Minimalny rytm dzienny (MVP)
1. `SWITCH:az:npc.json:10` → `GRAMMARFIX:az:npc.json:10` → `LANGVAL:az`
2. `SPOTCHECK:az:20`
3. `RESTART` po zmianie reguł i ponowny krótki test komend
4. Aktualizacja statusu i decyzja o nocnym trybie ciągłym

### 5.7 Tryb Live-Ops (na bieżąco, bezinwazyjnie)

#### Cel
- Worker działa stale, a zmiany wprowadzamy bez zatrzymania całości: przez komendy runtime albo kontrolowany `RESTART` po patchu.

#### Pętla operacyjna (co 5–15 minut)
1. Odczyt zdrowia procesu (`ps`) + status (`I18N_STATUS.md`) + `validation/summary.json`.
2. Jeśli trend jakości się pogarsza (więcej `critical`, rośnie `crossref_total_issues`) → ogranicz zakres do jednego języka i jednego pliku.
3. Wysyłaj małe paczki komend (limity 5–20), nie masowe skoki.

#### Bezinwazyjne zmiany w runtime
- **Bez zmian kodu:** używaj `SWITCH`, `AUTO`, `LANGVAL`, `SPOTCHECK`, `GRAMMARFIX`.
- **Ze zmianą kodu:** commit lokalny + `RESTART` komendą (bez ręcznego kill), potem krótka walidacja kontrolna.
- Każdą nową regułę najpierw testuj z limitem `<=5` i tylko na `az/npc.json`.

#### Komendy wymuszające podczas pracy (kolejność bezpieczna)
1. `SWITCH:az:npc.json:10`
2. `GRAMMARFIX:az:npc.json:10`
3. `LANGVAL:az`
4. `SPOTCHECK:az:20`
5. `AUTO:az:npc.json:5` (tylko gdy walidacja po fixie nie pogarsza metryk)

#### Zasady restartu
- `RESTART` tylko po realnej zmianie reguł/skryptu.
- Po restarcie: szybki smoke (`LANGVAL:az` + `SPOTCHECK:az:10`).
- Jeśli po restarcie rośnie liczba `critical`, wróć do poprzednich limitów i zawęź zakres.

#### Warunki STOP / eskalacja
- Stop działań jakościowych dla języka, gdy:
  - `critical` rośnie 2 cykle z rzędu,
  - pojawiają się naruszenia guard/token,
  - spotcheck wykazuje utratę sensu tłumaczeń.
- Wtedy tylko: `LANGVAL` + raport + korekta heurystyk.

---

## 6. Walidacja per-język

### 6.1 Walidatory ogólne (wszystkie języki)

| # | Walidator | Opis |
|---|-----------|------|
| V1 | **placeholder_match** | Sprawdź czy `{0}`, `{name}`, `%s`, `|PLAYERNAME|`, `''commands''` są zachowane |
| V2 | **length_ratio** | len(LANG)/len(EN) w rozsądnym zakresie (0.3–4.0) |
| V3 | **empty_check** | Tłumaczenie nie jest puste |
| V4 | **artifact_check** | Brak `???`, `[LANG]`, `TODO`, śmieci |
| V5 | **pipe_token_check** | Tokeny `|TOKEN|` zachowane |
| V6 | **newline_check** | Liczba `\n` taka sama jak w EN |
| V7 | **command_check** | Komendy w `''` zachowane (np. `''trade''`) |

### 6.2 Walidatory specyficzne per-grupa

#### Grupa B (cyrylica): Walidator `cyrillic_script_check`
```python
def cyrillic_script_check(text, lang):
    """Sprawdź czy tekst cyrylicowy nie zawiera łacińskich liter."""
    import unicodedata
    latin_chars = sum(1 for c in text if unicodedata.category(c) == 'Lu' and ord(c) < 0x0400)
    return latin_chars / max(len(text), 1) < 0.1  # Max 10% łacińskich
```

#### Grupa C (CJK): Walidator `cjk_ratio_check`
```python
def cjk_ratio_check(en_text, translated, lang):
    """CJK jest zwykle 30-70% długości EN w znakach."""
    ratio = len(translated) / max(len(en_text), 1)
    if lang in ('ja', 'zh', 'zh_TW', 'ko'):
        return 0.15 < ratio < 2.0  # Luźniejszy zakres
    return True
```

#### Grupa D (RTL): Walidator `rtl_direction_check`
```python
def rtl_direction_check(text, lang):
    """Sprawdź obecność znaków RTL."""
    import unicodedata
    rtl_count = sum(1 for c in text if unicodedata.bidirectional(c) in ('R', 'AL', 'AN'))
    # Przynajmniej 30% znaków powinno być RTL (pomijając placeholder'y)
    total = sum(1 for c in text if not c.isspace() and c not in '{}|%')
    return rtl_count / max(total, 1) > 0.3
```

#### Grupa E (egzotyczne): Walidator `script_consistency_check`
```python
EXPECTED_SCRIPTS = {
    'bn': 'BENGALI', 'el': 'GREEK', 'hy': 'ARMENIAN', 'ka': 'GEORGIAN',
    'ml': 'MALAYALAM', 'ta': 'TAMIL', 'te': 'TELUGU', 'th': 'THAI',
    'hi': 'DEVANAGARI',
}
def script_consistency_check(text, lang):
    """Sprawdź czy tekst jest w oczekiwanym piśmie."""
    if lang not in EXPECTED_SCRIPTS:
        return True
    import unicodedata
    expected = EXPECTED_SCRIPTS[lang]
    correct_script = sum(1 for c in text if expected in unicodedata.name(c, ''))
    total_alpha = sum(1 for c in text if c.isalpha())
    return correct_script / max(total_alpha, 1) > 0.5  # >50% w poprawnym piśmie
```

### 6.3 Procedura walidacji per-język (jednorazowa)

Dla **KAŻDEGO z 52 języków** wykonać pełen audyt:

1. **Załaduj** wszystkie pliki JSON danego języka
2. **Porównaj** z EN — klucz po kluczu:
   - Brakujące klucze → raport
   - Placeholder mismatch → raport
   - Identyczne z EN (false translates) → raport
   - Placeholder artefakty `[LANG] text` → policz
3. **Uruchom** walidatory specyficzne (V1–V7 + grupa)
4. **Wygeneruj** raport: `i18n/status/validation/{lang}_report.json`
   ```json
   {
     "lang": "de",
     "total_keys": 51503,
     "translated": 6339,
     "issues": {
       "placeholder_mismatch": 12,
       "length_anomaly": 5,
       "identical_to_en_suspicious": 200,
       "artifact_found": 0,
       "script_issue": 0
     },
     "worst_keys": [...],
     "score": 92
   }
   ```
5. **Zbiorczy raport** → `i18n/status/validation/summary.json`

### 6.4 Ciągła walidacja (w workerze)

- Każde nowe tłumaczenie przechodzi przez V1–V7 + walidatory grupy
- Odrzucone → logowane, nie zapisywane
- Statystyki odrzuceń per-język w `quality_dashboard.json`

---

## 7. Cross-referencing z EN i PL

**Status (2026-02-12):** wdrożone 7.2.1, 7.2.2, 7.2.3, 7.4 (auto-fix flagowany) oraz workflow 7.3 (raporty `*_crossref.json` + agregacja w `validation/summary.json`); planowane pozostaje 7.2.4 (semantic similarity).

### 7.1 Teoria

Kiedy język `X` ma już >50% przetłumaczonych kluczy, worker może:
1. **Porównywać** tłumaczenie `X` z EN i PL
2. **Wykrywać** niespójności cross-language
3. **Uczyć się** z PL jako "zweryfikowanego" języka

### 7.2 Typy cross-reference checks

#### 7.2.1 Consistency check (spójność w obrębie języka)
- Jeśli klucz `item.100.name` = "Magic Sword" w EN
- I ten sam tekst "Magic Sword" pojawia się w `item.200.description`
- To w `lang=de`: `item.100.name` → "Magisches Schwert" i `item.200.description` powinien też zawierać "Magisches Schwert" (nie np. "Zauberklinge")

**Implementacja:**
```python
def cross_ref_consistency(en_data, lang_data, lang):
    """Znajdź niespójne tłumaczenia tego samego tekstu EN."""
    en_to_translations = {}  # en_text → set of translations
    for key, en_val in en_data.items():
        if key in lang_data:
            en_to_translations.setdefault(en_val, set()).add(lang_data[key])
    
    inconsistent = {}
    for en_text, translations in en_to_translations.items():
        if len(translations) > 1:
            inconsistent[en_text] = list(translations)
    return inconsistent
```

#### 7.2.2 PL-reference check (porównanie z PL)
- Jeśli PL tłumaczy "Golden Armor" → "Złota Zbroja"
- I `lang=de` tłumaczy "Golden Armor" → "Golden Armor" (identyczne z EN)
- → **PODEJRZANE** — prawdopodobnie nie przetłumaczone

**Implementacja:**
```python
def cross_ref_with_pl(en_data, pl_data, lang_data, lang):
    """Jeśli PL przetłumaczyło klucz ale LANG nie (=EN), to flaguj."""
    suspicious = []
    for key in en_data:
        en_val = en_data[key]
        pl_val = pl_data.get(key, "")
        lang_val = lang_data.get(key, "")
        
        if pl_val and pl_val != en_val and lang_val == en_val:
            # PL has translation, LANG doesn't (still EN copy)
            suspicious.append(key)
    return suspicious
```

#### 7.2.3 Length-ratio cross-check
- Porównanie ratio (len(LANG)/len(EN)) z ratio (len(PL)/len(EN))
- Jeśli PL ratio = 1.2 a LANG ratio = 3.5 → podejrzane
- Jeśli PL ratio = 1.2 a LANG ratio = 1.1 → OK

#### 7.2.4 Semantic similarity (zaawansowane — Phase 5)
- Użycie GT do przetłumaczenia PL→LANG i porównanie z istniejącym tłumaczeniem
- Jeśli GT(PL→LANG) ≈ istniejące → OK
- Jeśli GT(PL→LANG) ≠ istniejące → flaguj do review
- **Uwaga:** Wolne, użyć tylko dla podejrzanych kluczy

### 7.3 Workflow cross-referencing

```
┌─────────────────────────────────────────────────┐
│           Cross-Reference Pipeline              │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. Załaduj EN, PL, LANG                        │
│  2. Consistency check (wewnątrz LANG)           │
│  3. PL-reference check (PL vs LANG)             │
│  4. Length-ratio cross-check                    │
│  5. Flaguj podejrzane klucze                    │
│  6. Raport → validation/{lang}_crossref.json    │
│                                                 │
│  Uruchamiany: razem z walidacją per-język      │
│  (domyślnie co 50 cykli) LUB na żądanie         │
│  Warunek: LANG != pl i ma >=30% coverage        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 7.4 Auto-korekta na podstawie cross-reference

- **Tryb 1 (bezpieczny):** Tylko raportuj niespójności
- **Tryb 2 (auto-fix):** Jeśli niespójność jest oczywista (np. EN-copy gdzie PL ma tłumaczenie), automatycznie przetłumacz przez GT i zastosuj
- **Tryb 3 (agresywny):** Nadpisuj tłumaczenia z niskim confidence score nowymi z GT

**Domyślnie:** Tryb 1 (bezpieczny).  Tryb 2 włączany flagą `--auto-fix-crossref`.

---

## 8. Optymalizacja wydajności (P0/P1)

### 8.1 P0: Cache target selection (26s → <1s)

**Problem:** `select_auto_translate_target_strict()` skanuje WSZYSTKIE pliki WSZYSTKICH języków co cykl.

**Rozwiązanie:**
- **8.1.1** Cache w pliku `i18n/status/target_cache.json`:
  ```json
  {
    "timestamp": "2025-01-21T15:00:00",
    "targets": [
      {"lang": "de", "category": "items", "untranslated": 15000, "priority": 1},
      ...
    ]
  }
  ```
- **8.1.2** Odświeżanie cache co 10 cykli (nie co cykl)
- **8.1.3** Po tłumaczeniu kategorii: aktualizuj tylko ten wpis w cache (dekrementuj `untranslated`)
- **8.1.4** Fallback: jeśli cache > 5 min old → pełny re-scan

### 8.2 P0: Throttle STATUSPY (21s → 0 w większości cykli)

**Problem:** `update_github_status()` uruchamia się co cykl i trwa 21s.

**Rozwiązanie:**
- **8.2.1** Uruchamiać STATUSPY co 10 cykli ALBO co 5 minut (co wcześniejsze)
- **8.2.2** Zmienna `LAST_STATUS_UPDATE_TIME` — sprawdzić przed wywołaniem
- **8.2.3** Wymusić update jeśli `--force-status` flag

### 8.3 P1: Batch size tuning

- **8.3.1** Domyślny batch: 20 kluczy/cykl (obecnie 10)
- **8.3.2** GT batch: 50 kluczy jednocześnie (obecnie brak limitu per-request)
- **8.3.3** Adaptive: jeśli guard_fail_rate > 20% → zmniejsz batch; jeśli < 5% → zwiększ

### 8.4 P1: Parallel language processing

- **8.4.1** Zamiast 1 język/cykl → 3 języki/cykl (dla różnych kategorii)
- **8.4.2** Round-robin: cykl 1 → de/items, fr/items, it/items; cykl 2 → de/npc, fr/npc, it/npc
- **8.4.3** Unikać GT rate-limiting: max 100 requests/min

---

## 9. Plan wykonania — kolejność kroków

### Faza 0: Poprawki krytyczne (1–2 godziny)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 0.1 | Poprawić GT_LANG_MAP (`"zh_TW": "zh-TW"`, `"he": "iw"`) | P0 | 5 min | ✅ 2026-02-12 |
| 0.2 | Cache target selection (8.1) | P0 | 30 min | ✅ 2026-02-12 |
| 0.3 | Throttle STATUSPY (8.2) | P0 | 15 min | ✅ 2026-02-12 |
| 0.4 | Utworzyć brakujące puste pliki JSON (5.4) | P0 | 10 min | ✅ 2026-02-12 |
| 0.5 | Test: uruchomić workera 2 min i sprawdzić czas cyklu | P0 | 5 min | ✅ 2026-02-12 |

**Wynik Fazy 0 (pomiar 0.5):**
- Run: `timeout 130s bash i18n_worker_simple.sh --continuous 1 0 --translations-only --no-git --translate-limit 1`
- Źródło metryk: [i18n/status/worker_cycle_perf.jsonl](i18n/status/worker_cycle_perf.jsonl), faza `cycle_total` (ostatnie 6 pełnych cykli)
- Czasy cyklu: min **4089 ms**, p50 **12771 ms**, avg **10810 ms**, max **20444 ms**
- Wniosek: P0 cache/throttle działają; pełny update statusu jest throttle’owany, a smart-force uruchamia pełny update przy istotnych zmianach.

### Faza 1: Monitoring i detekcja (2–3 godziny)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 1.1 | Implementacja `detect_suspicious()` w AUTOTRANSPY (3.2) | HIGH | 45 min | ✅ Było wcześniej |
| 1.2 | Rozszerzenie output JSON o sekcję `quality` (2.1) | HIGH | 20 min | ✅ 2025-02-12 |
| 1.3 | Plik `tibia_proper_nouns.json` — lista nazw własnych (3.3.1) | MEDIUM | 30 min | ✅ 2026-02-12 |
| 1.4 | Cykliczny audyt QUALITY_AUDIT_PY (2.2) | MEDIUM | 45 min | ✅ 2025-02-12 |
| 1.5 | Dashboard jakości w I18N_STATUS.md (2.3) | LOW | 20 min | ✅ 2025-02-12 |
| 1.6 | `manual_review_queue.json` + obsługa w workerze (3.4) | LOW | 30 min | ✅ 2026-02-12 |

### Faza 2: Rozszerzenie słowników (3–4 godziny)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 2.1 | Analiza top 500 fraz EN (4.2.1 krok 1–2) | HIGH | 30 min | ✅ 2026-02-12 |
| 2.2 | Auto-wydobycie fraz z PL (4.2.2) | HIGH | 30 min | ✅ 2026-02-12 |
| 2.3 | Przeniesienie SIMPLE/WORD do plików JSON (4.2.3, 4.3.3) | HIGH | 45 min | ✅ 2026-02-12 |
| 2.4 | Generowanie SIMPLE_TRANSLATIONS dla top-10 języków (4.2.3) | MEDIUM | 60 min | ✅ 2026-02-12 |
| 2.5 | Rozszerzenie WORD_TRANSLATIONS o ~350 słów PL (4.3.2) | MEDIUM | 45 min | ✅ 2026-02-12 (quality-first, 660 PL wpisów) |
| 2.6 | TM wzmocnienie — confidence scores (4.4) | LOW | 30 min | ✅ 2026-02-12 |

**Postęp 2026-02-12:** wykonano analizę 4.2.1 (krok 1–2) skryptem [tools/i18n_dictionary_expansion_analysis.py](tools/i18n_dictionary_expansion_analysis.py), wygenerowano: [i18n/status/top_phrases_en.json](i18n/status/top_phrases_en.json), [i18n/status/simple_translations_pl_candidates.json](i18n/status/simple_translations_pl_candidates.json), [i18n/status/top_words_en.json](i18n/status/top_words_en.json), [i18n/status/dictionary_expansion_summary.json](i18n/status/dictionary_expansion_summary.json).

**Postęp 2026-02-12 (ciąg dalszy, jakość-first):**
- ✅ 4.2.3 / 4.3.3: wdrożono zewnętrzne słowniki [i18n/status/simple_translations.json](i18n/status/simple_translations.json) i [i18n/status/word_translations.json](i18n/status/word_translations.json), oraz podpięto je w AUTOTRANSPY z priorytetem nad fallbackiem hardcoded.
- ✅ 4.2.4: wygenerowano słowniki dla top-10 języków z istniejących jakościowych tłumaczeń (bez agresywnego GT auto-fill), przez [tools/i18n_dictionary_materialize.py](tools/i18n_dictionary_materialize.py).
- ✅ 4.4.2 / 4.4.3 / 4.4.4 / 4.4.5: TM przeniesione do per-język [i18n/status/tm/{lang}.json](i18n/status/tm), z metadanymi `source`, `confidence`, `verified`, `updated_at`; zachowany fallback do legacy TM.
- ✅ 4.3.1 / 4.3.2 (analitycznie): wygenerowano listę kandydatów top słów i rozszerzeń PL [i18n/status/word_translations_pl_candidates.json](i18n/status/word_translations_pl_candidates.json) (350 pozycji do kuracji quality).
- ✅ 4.3.2 (domknięcie): przebudowano kurację WORD dla PL w [tools/i18n_dictionary_materialize.py](tools/i18n_dictionary_materialize.py) (Unicode-safe tokenizacja + filtry hybryd EN/PL + confidence), wynik: [i18n/status/word_translations.json](i18n/status/word_translations.json) zawiera 660 jakościowych mapowań dla `pl`.

**Start punktu 5 (2026-02-12):**
- ✅ 5.2: poprawiono mapowanie GT w workerze (`he -> iw`, obsługa `zh_TW`/`zh_tw` przez normalizację kodu) w [i18n_worker_simple.sh](i18n_worker_simple.sh).
- ✅ 5.4: uzupełniono strukturę i18n o brakujące puste pliki (`{}`) dla wszystkich języków (314 plików), po walidacji: `langs_with_missing=0`, `missing_total=0`.

### Faza 3: Walidacja języków (3–4 godziny)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 3.1 | Implementacja walidatorów V1–V7 (6.1) | HIGH | 45 min | ✅ 2026-02-12 |
| 3.2 | Walidatory specyficzne: cyrylica, CJK, RTL, egzotyczne (6.2) | HIGH | 45 min | ✅ 2026-02-12 |
| 3.3 | Jednorazowy audyt per-język (6.3) — skrypt | MEDIUM | 60 min | ✅ 2026-02-12 |
| 3.4 | Integracja walidatorów w ciągłe tłumaczenie (6.4) | MEDIUM | 30 min | ✅ 2026-02-12 |
| 3.5 | Raport zbiorczy `validation/summary.json` (6.3.5) | LOW | 20 min | ✅ 2026-02-12 |

**Postęp 2026-02-12 (weryfikacja Fazy 3):**
- ✅ Worker posiada pełny pipeline `run_full_lang_validation()` (V1–V7 + walidatory grupowe) i zapisuje raporty per-język do [i18n/status/validation](i18n/status/validation).
- ✅ Dostępny raport zbiorczy [i18n/status/validation/summary.json](i18n/status/validation/summary.json) oraz raporty dla wszystkich języków `*_report.json`.
- ✅ Integracja cykliczna aktywna przez `LANG_VALIDATION_INTERVAL` i wywołanie w pętli continuous (co N cykli).

### Faza 4: Cross-referencing (2–3 godziny)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 4.1 | Consistency check w obrębie języka (7.2.1) | HIGH | 30 min | ✅ 2026-02-12 |
| 4.2 | PL-reference check (7.2.2) | HIGH | 30 min | ✅ 2026-02-12 |
| 4.3 | Length-ratio cross-check (7.2.3) | MEDIUM | 20 min | ✅ 2026-02-12 |
| 4.4 | Integracja w worker (co 50 cykli) (7.3) | MEDIUM | 30 min | ✅ 2026-02-12 |
| 4.5 | Auto-fix Tryb 2 (7.4) | LOW | 45 min | ✅ 2026-02-12 (flagowane, domyślnie OFF) |

**Postęp 2026-02-12 (domknięcie Fazy 4):**
- ✅ W `run_full_lang_validation()` dodano dedykowany pipeline cross-referencing EN↔PL↔LANG: spójność w języku, PL-reference oraz cross-check ratio długości vs PL.
- ✅ Raporty per-język zapisują się do `i18n/status/validation/{lang}_crossref.json` (potwierdzone dla 52 języków).
- ✅ Raport zbiorczy `i18n/status/validation/summary.json` zawiera pola `crossref_issues` per język oraz `crossref_total_issues` (aktualnie: `24609`).
- ✅ Warunki uruchomienia działają zgodnie z planem: crossref aktywny przy `coverage >= 30` i `lang != "pl"`.
- ✅ Wdrożono Tryb 2 (4.5) jako opcjonalny `--auto-fix-crossref` + `--auto-fix-crossref-limit N` (default OFF, limit 30).
- ✅ Auto-fix działa wyłącznie przy `--use-gt`, coverage `>=30`, `lang != pl` i zapisuje metryki (`auto_fix_*`) do `*_crossref.json` oraz `crossref_autofix_total_applied` do `validation/summary.json`.
- ⏳ Niewdrożone pozostają semantyczne porównania 7.2.4 (Phase 5 advanced).

**Postęp 2026-02-12 (Faza 6 — rewalidacja po 4.5):**
- ✅ Pipeline walidacji per-język (sekcja 6) został utrzymany bez regresji po dodaniu auto-fix 4.5 (brak błędów składni/workspace diagnostics).
- ✅ Rozszerzono raportowanie sekcji 6 o metryki auto-fix crossref w summary (`crossref_autofix_total_applied`).
- 🟡 Krótki run kontrolny `timeout 40s` potwierdził start i integrację flag 4.5; pełen przebieg walidacji 52 języków wymaga dłuższego okna niż 40s.

**Postęp 2026-02-13 (sterowanie runtime + readiness przed nocnym runem):**
- ✅ Dodano komendy runtime do przełączania języka podczas pracy: `SWITCH:<lang>[:json[:limit]]` i `UNSWITCH` (przypinanie języka między cyklami).
- ✅ Dodano komendę runtime `LANGVAL:all|<lang>` do wymuszenia walidacji per-język w bieżącym przebiegu.
- ✅ Dodano CLI do ręcznych walidacji: `--lang-validate <lang>` i `--lang-validate-all`.
- ✅ Dodano raport gotowości wszystkich języków: [tools/i18n_language_readiness_report.py](tools/i18n_language_readiness_report.py) → [i18n/status/language_readiness.md](i18n/status/language_readiness.md).

### Faza 5: Masowe tłumaczenie (ciągłe, tygodnie)

| # | Zadanie | Priorytet | Est. czasu | Status |
|---|---------|-----------|------------|--------|
| 5.1 | PL → 90% (GT batch, 50 kluczy/cykl) | HIGH | Worker: ~12h | ⏳ not started |
| 5.2 | ES → 90% | HIGH | Worker: ~8h | ⏳ not started |
| 5.3 | DE, PT, RU, TR → 50% | MEDIUM | Worker: ~24h | ⏳ not started |
| 5.4 | Reszta 46 języków → 30% | LOW | Worker: ~72h | ⏳ not started |
| 5.5 | Cross-referencing pass dla języków >50% | MEDIUM | Worker: ~4h | 🟡 gotowe technicznie, brak pełnego przebiegu |

---

## Szacunkowe harmonogramy

| Faza | Praca programistyczna | Czas workera |
|------|----------------------|--------------|
| Faza 0 | ~1.5h | 5 min (test) |
| Faza 1 | ~3h | — |
| Faza 2 | ~4h | — |
| Faza 3 | ~3.5h | 1h (audyt) |
| Faza 4 | ~2.5h | — |
| Faza 5 | — | ~120h (5 dni non-stop) |
| **RAZEM** | **~14.5h pracy** | **~5 dni workera** |

---

## Appendix A: Struktura plików statusowych

```
i18n/
  status/
    quality_report.jsonl           # Raporty jakości (JSONL, jeden per cykl)
    quality_audit_latest.json      # Ostatni audyt jakości
    quality_dashboard.json         # Dashboard per-język
    target_cache.json              # Cache celów tłumaczenia
    suspicious_rejected.jsonl      # Odrzucone tłumaczenia
    suspicious_log.jsonl           # Zalogowane podejrzane (non-blocking)
    manual_review_queue.json       # Kolejka do ręcznego przeglądu
    tibia_proper_nouns.json        # Nazwy własne Tibia
    simple_translations.json       # Frazy (wszystkie języki)
    word_translations.json         # Słowa (wszystkie języki)
    translation_recent_report.jsonl # Logi tłumaczeń
    i18n_file_status.json          # Status plików
    i18n_global_stats.json         # Statystyki globalne
    tm/
      pl.json                      # Translation Memory — PL
      de.json                      # TM — DE
      ...                          # (per-język)
    validation/
      pl_report.json               # Raport walidacji PL
      de_report.json               # Raport walidacji DE
      pl_crossref.json             # Raport cross-reference PL (crossref_enabled=false)
      de_crossref.json             # Raport cross-reference DE
      ...
      summary.json                 # Zbiorczy raport (+ crossref_total_issues)
```

## Appendix B: Puste kategorie (do pominięcia w tłumaczeniu)

| Kategoria | Kluczy | Uwaga |
|-----------|--------|-------|
| errors | 0 | Pusta |
| mounts | 0 | Pusta |
| otclient_mods | 0 | Pusta |
| otclient_src | 0 | Pusta |
| otclient_tools | 0 | Pusta |
| ui | 0 | Pusta |
| world | 0 | Pusta |

## Appendix C: Top 10 największych kategorii

| # | Kategoria | Kluczy | Typ tekstu | Trudność GT |
|---|-----------|--------|------------|-------------|
| 1 | items | 16 894 | Krótkie nazwy/opisy | ⭐ Łatwa |
| 2 | npc | 13 769 | Dialogi, długie | ⭐⭐⭐ Trudna |
| 3 | monsters | 5 915 | Nazwy, krótkie | ⭐ Łatwa |
| 4 | server | 2 574 | Komunikaty, mieszane | ⭐⭐ Średnia |
| 5 | scripts | 2 170 | Opisy sklepu/gry | ⭐⭐ Średnia |
| 6 | otclient_modules | 1 987 | UI stringi | ⭐ Łatwa |
| 7 | questlog | 1 918 | Opisy questów | ⭐⭐ Średnia |
| 8 | spells | 1 534 | Nazwy, krótkie | ⭐ Łatwa |
| 9 | html | 1 495 | Szablony web | ⭐⭐⭐ Trudna (HTML) |
| 10 | books | 1 403 | Długie teksty fabularne | ⭐⭐⭐ Trudna |

---

## Appendix D: Log zmian implementacji

### 2025-02-12 — Sekcja 2: Monitoring jakości tłumaczeń ✅

**Zaimplementowane:**

1. **Quality metrics w AUTOTRANSPY** (2.1.1–2.1.3)
   - Obliczanie `avg_en_len`, `avg_translated_len`, `length_ratio`, `source_breakdown` po każdym cyklu
   - Śledzenie `identical_to_en`, `very_short_translations`, `very_long_translations`
   - Zapis do `i18n/status/quality_report.jsonl` (JSONL, 1 linia per cykl)
   - Ostrzeżenia `QUALITY_WARNINGS` gdy ratio <0.5 lub >3.0, suspicious >5, GT fail rate >20%
   - Linia `__QUALITY__` z JSON do parsowania przez bash

2. **Quality dashboard per-język** (2.3.2)
   - `i18n/status/quality_dashboard.json` — aktualizowany po każdym cyklu AUTOTRANSPY
   - Per-język: `quality_score` (0–100, rolling average), `cycles`, `total_suspicious`, `total_rejected`, `total_gt_guard_fail`
   - Quality score = (ratio_score + reject_score) / 2, rolling average

3. **Bash wrapper rozszerzony** (2.1.3)
   - Parsowanie `__QUALITY__` i `QUALITY_WARNINGS` z output AUTOTRANSPY
   - Logowanie ostrzeżeń do stderr

4. **Cykliczny audyt QUALITY_AUDIT_PY** (2.2.1–2.2.3)
   - `run_quality_audit()` bash function uruchamiana co `QUALITY_AUDIT_INTERVAL` cykli (domyślnie 10)
   - Analiza ostatnich 200 wpisów z `quality_report.jsonl` + 100 z `translation_recent_report.jsonl`
   - Wykrywanie: persistent length anomaly, high reject rate, high GT fail rate, cross-language duplicates
   - Raport → `i18n/status/quality_audit_latest.json` + `quality_audit_history.jsonl`
   - Automatyczne zmniejszenie batch do 5 przy CRITICAL issues

5. **Dashboard jakości w I18N_STATUS.md** (2.3.1)
   - Tabela per-język z ikonami jakości (🟢/🟡/🟠/🔴)
   - Ostatni audyt: data, problemy, severity breakdown
   - Top problemy + źródła tłumaczeń

6. **Integracja w main loop**
   - `run_quality_audit "$CYCLE"` wywoływane po każdym AUTO_TRANSLATE

**Pliki statusowe dodane:**
- `i18n/status/quality_report.jsonl`
- `i18n/status/quality_dashboard.json`  
- `i18n/status/quality_audit_latest.json`
- `i18n/status/quality_audit_history.jsonl`

---

### 2025-02-12 — Sekcja 3: Wykrywanie podejrzanych/trudnych tłumaczeń ✅

**Zaimplementowane:**

1. **Rozszerzenie `detect_suspicious()` o brakujące kryteria** (3.1)
   - **S7 — Capitalization mismatch**: EN zaczyna wielką literą, tłumaczenie małą (łacińskie pismo, LOW)
   - **S10 — Incomplete sentence**: EN kończy się `.!?`, tłumaczenie nie ma znaku końca zdania (LOW)
   - **S5**: Cross-language dups obsługiwane przez `run_quality_audit()` (batch audit)
   - Kompletny zestaw: S1–S4, S6–S10 aktywne

2. **Auto-ekstrakcja nazw własnych Tibia** (3.3.1)
   - `ensure_tibia_proper_nouns()` przebudowana — auto-generuje z danych EN
   - Źródła: spell words (169), spell names (764), quest names (498), raid names (86), core terms (92)
   - **Wynik: 1597 termów** (poprzednio 48 hardcoded)
   - Format v2: `auto_generated: true`, statystyki per-źródło
   - Regenerowany przy każdym uruchomieniu workera

3. **Rozszerzona ochrona przed GT** (3.3.2–3.3.4)
   - `_protect_placeholders()` rozszerzona o:
     - **HTML tagi**: `<b>`, `</b>`, `<br>`, `<font color='red'>` itp.
     - **Escape sequences**: `\n`, `\t`, `\r`
     - **HTML entities**: `&amp;`, `&lt;`, `&#123;` itp.
     - **Komendy**: `'/heal'`, `'/cast'` itp.
     - **Nazwy własne Tibia**: automatyczna ochrona termenów >4 znaków z word boundary
   - Kolejność: nazwy własne NAJPIERW → potem regex patterns (unika kolizji z tokenami)

4. **Manual review queue** (3.4) — **było wcześniej zaimplementowane**
   - `_enqueue_manual_review()` z deduplication
   - `apply_manual_review_approvals()` z obsługą approved translations
   - Klucze z >3 flagami suspicious → reject + enqueue

**Wynik testów (17 cykli):**
- `suspicious_log.jsonl`: 68 wpisów (identical_to_en=56, proper_noun=12, capitalization=1)
- `manual_review_queue.json`: działa (1 testowy wpis approved+applied)
- `tibia_proper_nouns.json`: 1597 termów auto-wygenerowanych
- `quality_dashboard.json`: pl score=61.0 (34 cykli), tr score=95.7

---

### 2025-02-12 — Sekcja 6: Walidacja per-język ✅

**Zaimplementowane:**

1. **`validate_per_lang()` w AUTOTRANSPY** (6.1)
   - Inline walidacja każdego nowego tłumaczenia
   - V6 — Newline count mismatch (MEDIUM)
   - Script-specific: cyrillic_latin_mix (>30% łacin w cyrylicy), cjk_ratio_anomaly, rtl_insufficient, wrong_script (exotic)
   - `LANG_SCRIPT_GROUP`: latin(33), cyrillic(5), CJK(4), RTL(2), exotic(9)
   - `EXPECTED_SCRIPTS`: bn=BENGALI, el=GREEK, hi=DEVANAGARI, hy=ARMENIAN, ka=GEORGIAN, ml=MALAYALAM, ta=TAMIL, te=TELUGU, th=THAI
   - Zintegrowane w 3 call-site'ach `detect_suspicious()` (TM, simple, GT)

2. **`run_full_lang_validation()` — cykliczny audyt per-język** (6.2–6.3)
   - Bash function z osadzonym LANG_VALIDATION_PY heredoc
   - `validate_key()` — pełny zestaw V1–V7 + script-specific
   - V1 placeholder mismatch (CRITICAL), V2 length ratio (MEDIUM), V3 empty (LOW — early return)
   - V4 artifact (HIGH), V5 pipe mismatch (CRITICAL), V6 newline (MEDIUM), V7 command mismatch (MEDIUM)
   - CMD_RE: `''[^']+?''` — podwójne apostrofy (komendy gry: `''trade''`, `''job''`)
   - Interwał: `LANG_VALIDATION_INTERVAL=50` cykli (domyślnie)

3. **Raporty walidacji** (6.4)
   - Per-język: `i18n/status/validation/{lang}_report.json`
     - Fields: lang, script_group, total_keys, translated, identical_to_en, placeholder_keys, coverage_pct, issues_total, issues_by_type, issues_by_severity, score, worst_keys
   - Summary: `i18n/status/validation/summary.json`
     - Fields: total_languages, avg_score, by_score (sorted), by_group

4. **Scoring (formuła)** (6.5)
   - `penalty = (critical_count * 3 + high_count * 1.5 + medium_count * 0.3 + low_count * 0.05)`
   - `score = max(0, min(100, 100 * (1 - penalty / translated_keys)))`
   - V3_empty → LOW (z early return, brak kaskady na inne validatory)
   - Score ikony: 🟢≥95, 🟡≥80, 🟠≥60, 🔴<60

5. **Dashboard w I18N_STATUS.md** (6.6)
   - Sekcja "Walidacja per-język" po dashboard jakości
   - Tabele per script group: Łacińskie, Cyrylica, CJK, RTL, Egzotyczne
   - Kolumny: Język, Score, Coverage, Issues, Crit, High

6. **Integracja w main loop** (6.7)
   - `run_full_lang_validation "$CYCLE"` po `run_quality_audit "$CYCLE"`
   - Wykluczenie nie-językowych katalogów: `_SKIP_DIRS = {"en","status","reports","scripts","tools","docs","backup"}` + `len(d) <= 6`

**Wynik testów (52 języki, 53 421 kluczy EN):**
- **avg_score: 98.8** (zakres: 93.3–99.7)
- PL: score=99.7, issues=246 (V3_empty=225, V4_artifact=13, V1=7, V5=1, V7=2)
- RU: score=93.3, issues=7405 (cyrillic_latin_mix=1045, V3_empty=6275)
- JA: score=99.0, issues=6283 (V3_empty=6275, V1=7, V5=1)
- Group averages: latin=98.9, cyrillic=97.7, CJK=99.0, RTL=99.0, exotic=99.0

**Bugfixy podczas implementacji:**
- `CMD_RE` zmieniony z `'[^']+?'` na `''[^']+?''` — unik fałszywych V7 na kontrakcjach angielskich (you're, don't)
- V7 severity: HIGH → MEDIUM
- V3_empty: HIGH → LOW z early return (unik kaskady na V2, script-specific)
- "reports" katalog wykluczony z walidacji (nie jest językiem)

**Pliki statusowe dodane:**
- `i18n/status/validation/{lang}_report.json` (×52 języki)
- `i18n/status/validation/summary.json`

---

### 2026-02-12 — Sekcja 5: Plan obsługi 55 języków ✅

**Zaimplementowane:**

1. **System tierów językowych** (5.3, 5.5)
   - `TIER1_LANGS="pl es"` — cel 90%, waga ×4
   - `TIER2_LANGS="de pt ru tr fr it"` — cel 50%, waga ×2
   - `TIER3` — reszta (40 języków) — cel 30%, waga ×1
   - Konfigurowane przez zmienne środowiskowe

2. **Tier-weighted interleaving w strict selector** (5.5)
   - W każdej super-rundzie:
     - Tier 1 przetwarza TIER1_WEIGHT plików (4) per język
     - Tier 2 przetwarza TIER2_WEIGHT plików (2) per język
     - Tier 3 przetwarza 1 plik per język
   - Dystrybucja w pierwszych 100 kandydatach: T1=16%, T2=24%, T3=60%

3. **Category translate priority** (5.5 Faza 4)
   - `CATEGORY_TRANSLATE_PRIORITY="items.json npc.json monsters.json server.json spells.json quests.json scripts.json actions.json raids.json"`
   - Kandydaci per-język sortowani wg priorytetu kategorii (items→npc→monsters→...)

4. **Group-aware WORD_TRANSLATIONS guard** (5.3)
   - `translate_words_for_simple_text()` sprawdza `LANG_SCRIPT_GROUP`
   - Pomija tłumaczenia słownikowe dla cyrillic, CJK, RTL, exotic
   - Tylko łacińskie skrypty mogą korzystać z WORD_TRANSLATIONS

5. **GT_LANG_MAP** (5.2) — potwierdzone: `he→iw`, `zh_TW→zh-TW` ✅
6. **Brakujące pliki JSON** (5.4) — potwierdzone: 0 brakujących ✅

7. **Tier info w I18N_STATUS.md**
   - Sekcja "System tierów" z tabelą tier/waga/cel
   - Priorytet kategorii

8. **Tier info w dispatch state**
   - `translation_dispatch_state.json` zawiera: `last_tier`, `last_cat_priority`, `tier_config`

**Wynik testów (5 języków: pl, de, es, ru, cs):**
- Kolejność: pl:items → es:items → pl:npc → es:npc (T1 first, high-priority categories)
- Tier 1 dostaje 4x cykle, Tier 2 2x, Tier 3 1x
- Zero błędów

---

### 2026-02-13 — Sekcja 8 P1: Optymalizacja wydajności — adaptive batch + parallel langs ✅

**Zaimplementowane:**

1. **8.3 Adaptive batch tuning (8.3.1–8.3.3)**
   - Nowe zmienne konfiguracyjne: `ADAPTIVE_BATCH_ENABLED`, `ADAPTIVE_BATCH_DEFAULT=20`, `ADAPTIVE_BATCH_MIN=5`, `ADAPTIVE_BATCH_MAX=50`
   - `compute_adaptive_batch()` — analiza ostatnich N cykli z `translation_guard_report.jsonl`
   - Logika adaptacyjna: `guard_fail_rate > 20%` → zmniejsz batch o 25%; `< 5%` → zwiększ o 25%
   - `GT_BATCH_SIZE` automatycznie dostosowywany (nie większy niż batch kluczy)
   - Stan persystowany w `i18n/status/adaptive_batch_state.json`
   - Reset `TRANSLATE_LIMIT` na początku cyklu z `USER_TRANSLATE_LIMIT` (CLI override ma priorytet)
   - CLI: `--no-adaptive-batch` wyłącza adaptive tuning

2. **8.4 Parallel language processing (8.4.1–8.4.3)**
   - Nowa zmienna `PARALLEL_LANGS_PER_CYCLE=3`
   - Po przetworzeniu głównego targetu, worker wybiera dodatkowe N-1 języków (różne od primary)
   - Warunek: `TRANSLATIONS_ONLY=true` (parallel działa tylko w trybie strict translation)
   - Metryki parallel zapisywane do `translation_guard_report.jsonl` (osobno per język)
   - Status log: `PARALLEL_TRANSLATE_DONE` w oplog
   - Detekcja pętli: jeśli selector zwraca ten sam język lub IDLE → stop parallel
   - CLI: `--parallel-langs N` konfiguruje liczbę (domyślnie 3)

**Wynik testu (40s run):**
- Banner poprawnie wyświetla: `📈 Adaptive batch: ON (default=20, range=5-50)` i `🔀 Parallel langs: 3 języki/cykl`
- Adaptive: `keys=15 gt_batch=15 fail_rate=34.4% (decrease_high_fail_rate=34.4%)` — poprawna redukcja przy wysokim fail rate
- Parallel: `🔀 Parallel [2/3]: es/monsters.json` — po pl automatycznie przełączył na es
- CLI `--translate-limit 1` poprawnie nadpisuje adaptive (priorytet user > adaptive)

---

*Koniec dokumentu. Wszystkie sekcje planu (2–8) zaimplementowane ✅.*
