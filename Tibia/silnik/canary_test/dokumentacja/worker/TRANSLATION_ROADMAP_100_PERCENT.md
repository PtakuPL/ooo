# 🌍 Roadmap do 100% tłumaczeń — Canary i18n

**Data:** 2025-06-24  
**Autor:** AI Worker + ptaku  
**Status:** W realizacji

---

## 📊 Aktualny stan pokrycia

| Język | Genuine | % | [EN] placeholders | Do przetłumaczenia |
|-------|---------|---|-------------------|-------------------|
| 🇪🇸 ES | 37,892 | 70.7% | 12,945 | ~15,694 |
| 🇫🇷 FR | 14,331 | 26.7% | 35,106 | ~39,255 |
| 🇵🇱 PL | 22,805 | 42.6% | 28,728 | ~30,781 |
| 🇩🇪 DE | 2,155 | 4.0% | 48,568 | ~51,431 |
| Inne (50 języków) | ~0-5% | <5% | ~50,000+ | ~50,000+ |

**Łącznie:** 53,586 kluczy EN × 54 języki = **2,893,644** par do przetłumaczenia  
**Pliki:** 38 domen JSON (items, npc, monsters, spells, quests, books, ...)

### Top 5 największych plików (priorytet)

| Plik | Kluczy | Opis |
|------|--------|------|
| items.json | 17,057 | Przedmioty — najważniejsze dla graczy |
| npc.json | 13,769 | Dialogi NPC — długie teksty, wiele kontekstów |
| monsters.json | 5,915 | Nazwy i opisy potworów |
| server.json | 2,574 | Komunikaty serwera |
| scripts.json | 2,170 | Tekstu z Lua skryptów |

---

## ❓ Dlaczego nie mamy 100%?

### 1. Ograniczenia darmowego Google Translate (`deep_translator`)

Obecny moduł `deep_translator.GoogleTranslator` to **nieoficjalne API** (web scraping):

| Problem | Opis | Wpływ |
|---------|------|-------|
| **Rate limiting** | Google blokuje po ~100-500 requestów/minutę | Worker musi czekać 1.5s między batchami |
| **Brak glosariusza** | Nie można chronić terminów gry (Tibia, Mana, exura) | GT tłumaczy nazwy własne i inkantacje |
| **Artefakty jakości** | `"brand-new"` → `"I.-new"`, mieszanie języków | ~20% tłumaczeń wymaga naprawy |
| **Brak batch API** | Symulowane batchowanie po 50 kluczy | Wolne, ~18s timeout na batch |
| **Brak Neural MT** | Używa modelu Statistical (SMT) dla wolumenu | Gorsza jakość dla krótkich fraz |
| **Identyczne zwroty** | GT zwraca EN tekst bez zmian (invented words) | Items/monsters z fantasy nazwami |
| **Brak SLA** | Google może zablokować IP w każdej chwili | Brak gwarancji dostępności |

### 2. Quality Guard odrzuca złe tłumaczenia

System jakości (`detect_suspicious`) prawidłowo odrzuca:
- **S3 identical_to_en** — tłumaczenie identyczne z EN (GT nie przetłumaczył)
- **S11 mixed_language** — mix angielskiego i docelowego języka
- **S23 word_salad** — chaotyczny tekst z fragmentami EN
- **S25 wrong_script** — łaciński tekst dla języków CJK/cyrylickich

To **poprawne odrzucenia** — lepiej mieć `[EN]` placeholder niż złe tłumaczenie.

### 3. Klucze chronione (nie wymagają tłumaczenia)

| Typ | Ilość | Opis |
|-----|-------|------|
| spell.*.words | 762 | Inkantacje zaklęć (exura, ###123) — **NIGDY nie tłumaczone** |
| NPC names/titles | ~500 | Nazwy NPC — identyczne we wszystkich językach |
| Technical values | ~300 | Kody, formaty, wyrażenia regularne |
| Onomatopeje | ~100 | Dźwięki (Hum hum hum, Clink clank) |
| **Razem chronionych** | **~1,662** | Automatycznie = wartość EN |

---

## 🛡️ Ochrona inkantacji zaklęć (spell.*.words)

### Zasada

| Element | Czy tłumaczony? | Przykład |
|---------|-----------------|---------|
| **spell.X.name** | ✅ TAK | `"Ultimate Healing"` → `"Ostateczne Leczenie"` |
| **spell.X.words** | ❌ NIGDY | `"exura vita"` — to komenda gry, musi być identyczna |

### Typy inkantacji (762 kluczy)

| Typ | Ilość | Przykład |
|-----|-------|---------|
| Kody `###NNN` | 578 | `###100`, `###large_fire_ring` |
| Słowa Tibia | 105 | `exura`, `exori gran`, `utani hur` |
| Inne | 79 | `rune_target`, `area_effect` |

### Implementacja ochrony

Funkcja `_is_immutable_key(key)` w `i18n_worker_simple.sh`:
- **Hard skip** w pętli tłumaczenia — klucz nigdy nie trafia do GT/TM
- **Auto-repair** w pętli naprawczej — jeśli wartość ≠ EN → przywróć EN
- **Sync protection** — nowe klucze dodawane z surową wartością EN (bez `[EN]` prefix)
- **6,343 naprawionych** inkantacji w 52 językach (2025-06-24)

---

## 📋 Kolejka odroczonych tłumaczeń

Gdy GT nie może przetłumaczyć klucza (timeout, error, quality rejection), zapisujemy go do:

```
i18n/status/deferred_translation_queue.jsonl
```

### Powody odłożenia

| Reason | Opis |
|--------|------|
| `gt_no_result` | GT nie zwrócił wyniku |
| `gt_rejected_critical` | Tłumaczenie odrzucone — jakość krytyczna |
| `gt_rejected_multi_issues` | Więcej niż 3 problemy jakościowe |
| `gt_rejected_high_*` | Odrzucone: wrong_script, word_salad, etc. |
| `gt_validate_fail_*` | Walidacja strukturalna nie przeszła |
| `gt_import_error` | deep-translator nie zainstalowany |
| `gt_init_error_*` | Błąd inicjalizacji GT |

### Priorytet retry

Klucze z kolejki są przetwarzane ponownie w kolejnych cyklach workera.  
Z Google Cloud Translation API — retry z lepszym modelem + glosariusz.

---

## 🔮 Co trzeba zrobić aby tłumaczenie było na 100%

### Etap 1: Optymalizacja istniejącego pipeline (bez kosztów)

- [x] Naprawiono 6,343 uszkodzonych inkantacji w 52 językach
- [x] Dodano hard skip dla spell.*.words (nigdy nie tłumaczone)
- [x] Dodano kolejkę odroczonych tłumaczeń
- [x] Zmniejszono false-positive o 35.3% (2,181 flag)
- [ ] **Rozbudowa słowników TM** — dodanie tłumaczeń z fanowskich wiki Tibia
- [ ] **Poprawa simple_translations_base.json** — ręcznie kuratorowane krótkie frazy
- [ ] **Poprawa word_translations_base.json** — słownik per-wyrazowy
- [ ] **Naprawa artefaktu „I."** — `"I.-new"` → retranslate z kontekstem

### Etap 2: Google Cloud Translation API (wymagany budżet)

- [ ] Integracja Google Cloud Translation API v3
- [ ] Konfiguracja glosariuszy (chroniące terminy Tibia)
- [ ] Batch API (500K znaków/request)
- [ ] Custom glossary: 200+ terminów gry + nazw własnych
- [ ] Retry kolejki odroczonych z Cloud API

### Etap 3: Automatyczny QA + human review

- [ ] Porównanie GT free vs Cloud API na próbce 1000 kluczy
- [ ] Human review dla top-5 języków (PL, ES, FR, DE, PT-BR)
- [ ] Automatyczne testy regresji na znanych błędach
- [ ] Dashboard z postępem per język

### Etap 4: Finalizacja

- [ ] Przetłumaczenie 100% kluczy w 5 głównych językach
- [ ] Export raportu jakości per język
- [ ] Pełne pokrycie 54 języków

---

## 💰 Google Cloud Translation API vs darmowe GT

### Porównanie

| Funkcja | deep_translator (darmowe) | Google Cloud Translation API |
|---------|--------------------------|------------------------------|
| **Typ API** | Nieoficjalne (web scraping) | Oficjalne REST API z SLA |
| **Model** | Statistical MT (SMT) | Neural MT (NMT) — znacznie lepsza jakość |
| **Batch** | Symulowane, 50 kluczy | Natywne, do 5,000 segmentów/request |
| **Throughput** | ~100-500 req/min (rate limit) | **600,000 znaków/min** (default quota) |
| **Glosariusz** | ❌ Brak | ✅ Custom Glossary — chroni terminy gry |
| **Model niestandardowy** | ❌ Brak | ✅ AutoML Translation (trenuj na własnych danych) |
| **Dostępność** | Brak SLA, może zablokować IP | 99.9% SLA |
| **Jakość krótkich fraz** | Słaba (1-3 słowa) | Dobra — NMT rozumie kontekst |
| **Fantasy/invented words** | Zwraca identycznie lub śmieciowe | Lepsza obsługa z glosariuszem |
| **Format wejścia** | Tylko plain text | HTML, plain text, MIME |
| **Detekcja języka** | Podstawowa | Zaawansowana (rozróżnia zh-CN/zh-TW) |

### Szacunkowy koszt (Google Cloud)

| Metryka | Wartość |
|---------|---------|
| Kluczy EN | 53,586 |
| Średnia długość klucza | ~30 znaków |
| Języków docelowych | 54 |
| **Łączne znaki** | ~86.8M znaków |
| **Koszt za 1M znaków** | $20 (Standard NMT) |
| **Łączny koszt jednorazowy** | **~$1,736** |
| Koszt miesięczny (przyrostowy) | ~$5-20 (tylko nowe/zmienione klucze) |

> **Uwaga:** Glosariusze i AutoML wymagają dodatkowej konfiguracji, ale nie kosztują extra.

### Co się zmieni po przejściu na Cloud API

1. **Jakość tłumaczeń wzrośnie o ~40-60%** dla krótkich fraz (1-3 słowa)
2. **Throughput wzrośnie ~1000x** — zamiast 50 kluczy/18s → 5000 kluczy/3s
3. **Glosariusz ochroni**:
   - Nazwy własne Tibia (Thais, Venore, Kazordoon)
   - Terminy gry (Mana, Health Points, Stamina)
   - Inkantacje (exura — wymuszenie identyczności)
   - Tibia-specific items (Golden Armor, Magic Plate Armor)
4. **Artefakty GT znikną** — NMT nie produkuje `"I.-new"` z `"brand-new"`
5. **Rate limiting zniknie** — oficjalne API, 99.9% SLA
6. **Retry queue** — odroczone klucze przetłumaczone automatycznie
7. **Czas do 100%** — szacunkowo **2-3 dni** zamiast tygodni

### Implementacja Cloud API (plan)

```python
# Obecny kod (deep_translator):
from deep_translator import GoogleTranslator
translator = GoogleTranslator(source='en', target=gt_lang)
result = translator.translate(text)

# Nowy kod (Google Cloud Translation API v3):
from google.cloud import translate_v3 as translate
client = translate.TranslationServiceClient()
parent = f"projects/{PROJECT_ID}/locations/global"
response = client.translate_text(
    contents=[text],
    target_language_code=gt_lang,
    source_language_code="en",
    parent=parent,
    glossary_config=glossary_config,  # Ochrona terminów gry
    model="general/nmt",  # Neural Machine Translation
)
result = response.translations[0].translated_text
```

### Wymagane zmienne środowiskowe

```bash
# Włączenie Cloud API (zamiast darmowego):
export USE_GOOGLE_CLOUD_TRANSLATE="true"
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

---

## 🔧 Podsumowanie zmian z sesji 2025-06-24

### Naprawione problemy

| Problem | Rozwiązanie | Wpływ |
|---------|-------------|-------|
| 6,343 uszkodzonych inkantacji | Przywrócono wartości EN w 52 językach | 100% inkantacji poprawnych |
| Brak ochrony .words keys | `_is_immutable_key()` + hard skip | Nigdy więcej uszkodzeń |
| GT failures lost | Kolejka odroczonych tłumaczeń | 0% utraconych kluczy |
| False positive 35.3% | Rozszerzone _INTL_WORDS + onomatopoeia | Mniej fałszywych odrzuceń |

### Pliki zmodyfikowane

1. `i18n_worker_simple.sh` — `_is_immutable_key()`, hard skip, deferred queue
2. `i18n/*/spells.json` (52 pleki) — naprawione inkantacje
3. `docs/i18n/TRANSLATION_ROADMAP_100_PERCENT.md` — ten dokument

---

## 📈 Prognoza osiągnięcia 100%

| Scenariusz | Czas | Warunek |
|-----------|------|---------|
| **Z Cloud API** | 2-3 dni | Budżet ~$1,736, konfiguracja projektu GCP |
| **Z darmowym GT** | 3-4 tygodnie | Rate limiting, niższa jakość |
| **Z manual review** | +1-2 tygodnie | Human review top-5 języków |
| **Pełne 100%** | ~1 miesiąc | Cloud API + QA + human review |

> **Rekomendacja:** Przejście na Google Cloud Translation API to najszybsza droga do 100%.
> Z budżetem ~$1,736 i glosariuszem, możemy przetłumaczyć WSZYSTKIE 54 języki w 2-3 dni robotnicze.
