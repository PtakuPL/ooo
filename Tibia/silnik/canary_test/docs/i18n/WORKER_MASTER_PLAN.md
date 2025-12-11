# I18N WORKER - MASTER PLAN v3.0

**Data:** 2025-12-11  
**Cel:** Pełna autonomia workera - działanie 24/7 bez interwencji

---

## 🎯 WIZJA KOŃCOWA

Worker pracuje w trybie `--continuous` non-stop:
1. Migruje wszystkie kategorie plików
2. Przygotowuje tłumaczenia na 55 języków (sync EN → [LANG])
3. Automatycznie tłumaczy co może
4. W trybie IDLE: dokumentacja, analiza nowych plików, monitorowanie

---

## 📊 FAZY PRACY WORKERA

### FAZA 1: MIGRATION (obecnie działająca)
**Cel:** Zamiana twardych stringów na klucze i18n

**Kategorie (31 zdefiniowanych):**
| Priorytet | Kategoria | Ścieżki |
|-----------|-----------|---------|
| 1 | npc | data-otservbr-global/npc, data-canary/npc |
| 2 | scripts | data-otservbr-global/scripts, data/scripts |
| 3 | monsters | data-otservbr-global/monster |
| 4 | actions | scripts/actions |
| 5 | quests | scripts/quests |
| 6-31 | raids, world, spells, talkactions, movements, creaturescripts, globalevents, items, mounts, outfits, addons, achievements, chatchannels, events, startup, modules, libs, npclib, otclient_modules, otclient_data, otclient_src, otclient_mods, otclient_tools, server, errors | różne |

**Logika przechodzenia między kategoriami:**
```
1. Pobierz listę kategorii posortowaną po priorytecie
2. Dla każdej kategorii:
   a. Jeśli skip_until > now → pomiń
   b. Zlicz pliki wymagające migracji
   c. Jeśli > 0 → praca!
   d. Jeśli = 0 → ustaw backoff (progresywny: 5min, 10min, 30min, 1h, 2h)
3. Jeśli wszystkie = 0 → migrations_done = true
4. Przejdź do FAZY 2
```

**Backoff progresywny:**
- 1x zero → skip 5 min
- 2x zero → skip 10 min
- 3x zero → skip 30 min
- 4x zero → skip 1h
- 5+ zero → skip 2h
- Auto-reset po 24h nieaktywności

---

### FAZA 2: TRANSLATION_SYNC (przygotowanie tłumaczeń)
**Cel:** Synchronizacja kluczy EN → wszystkie 55 języków z prefixem [LANG]

**Języki (55 docelowych):**
```
Europa Zachodnia: de, pl, es, pt, fr, it, nl
Europa Środkowa: cs, sk, hu
Europa Północna: sv, da, no, fi, et, lv, lt
Europa Południowa: ro, bg, el, hr, sl, bs, sr, mk, sq
Europa Wschodnia: ru, uk
Azja Środkowa: kk, uz, az, hy, ka
Bliski Wschód: tr, ar, he, fa
Azja: zh, zh_TW, ja, ko, hi, th, vi, id, ms, tl
Inne: bn, ta, te, ml, sw
```

**Logika:**
```
1. Dla każdego języka w kolejności priorytetu:
   a. Dla każdego pliku JSON (npc.json, items.json, ...):
      - Zlicz brakujące klucze
      - Jeśli > 0 → skopiuj z EN z prefixem [LANG]
2. Gdy wszystkie zsynchronizowane → FAZA 3
```

**Format placeholdera:**
```json
{
  "npc.alejandro.greeting": "[DE] Welcome to my shop, traveler!"
}
```

---

### FAZA 3: AUTO_TRANSLATE (automatyczne tłumaczenia)
**Cel:** Automatyczne tłumaczenie kluczy z [LANG] na docelowy język

**Metody tłumaczenia (priorytet):**
1. **Translation Memory (TM)** - wewnętrzna baza podobnych tłumaczeń
2. **Glossary** - słownik terminów gry (nie tłumaczyć: Tibia, spell names, etc.)
3. **API Translation** - zewnętrzne API (jeśli skonfigurowane)
4. **Pattern-based** - wzorce dla prostych fraz

**Limity:**
- `--translate-limit N` - max N kluczy na cykl
- Domyślnie: bez limitu (przetwarza wszystko co może)

**Logika:**
```
1. Dla każdego języka:
   a. Znajdź klucze z prefixem [LANG]
   b. Próbuj przetłumaczyć:
      - TM match > 85% → użyj
      - Glossary match → użyj z szablonem
      - API available → wywołaj
      - Pattern match → użyj
   c. Jeśli sukces → zapisz bez prefixu
   d. Jeśli brak → zostaw [LANG]
2. Gdy wszystko przetłumaczone → FAZA 4
```

---

### FAZA 4: IDLE (praca ciągła / maintenance)
**Cel:** Dokumentacja, monitoring, analiza - gdy brak pilnej pracy

**Zadania w trybie IDLE:**

#### 4.1 Analiza nowych plików
```
1. Skanuj foldery co 5 minut
2. Porównaj z listą przetworzonych
3. Jeśli nowy plik z twardymi stringami → wróć do FAZY 1
```

#### 4.2 Dokumentacja pełna
```
1. Generuj docs/i18n/npc/{npc_name}.md dla każdego NPC
2. Aktualizuj docs/i18n/COVERAGE.md z % pokrycia
3. Aktualizuj I18N_STATUS.md z globalnym stanem
```

#### 4.3 Walidacja jakości
```
1. Sprawdź tłumaczenia pod kątem:
   - Niespójności (ten sam EN → różne tłumaczenia)
   - Błędów formatowania ({player} zachowane?)
   - Komend w 'apostrofach' (nie przetłumaczone?)
2. Raportuj błędy do docs/i18n/QUALITY_REPORT.md
```

#### 4.4 Statystyki i raporty
```
1. Generuj raport dzienny do docs/i18n/reports/YYYY-MM-DD.md
2. Aktualizuj metryki w metrics/
3. Push do GitHub co godzinę
```

#### 4.5 Czekanie z monitoringiem
```
1. Sleep 5 minut
2. Sprawdź czy pojawiły się nowe pliki
3. Jeśli tak → wróć do odpowiedniej FAZY
4. Jeśli nie → powtórz od 4.1
```

---

## 🔄 FLOWCHART GŁÓWNY

```
┌─────────────────────────────────────────────────────────────┐
│                    START --continuous                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  DISPATCHER: select_work_mode()                              │
│  ├─ Sprawdź komendy sterowania (.worker_command)             │
│  ├─ Sprawdź kategorie MIGRATION                              │
│  ├─ Sprawdź TRANSLATION_SYNC                                 │
│  ├─ Sprawdź AUTO_TRANSLATE                                   │
│  └─ Zwróć tryb: MIGRATION|TRANSLATION_SYNC|AUTO_TRANSLATE|IDLE│
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┬───────────────┐
              │               │               │               │
              ▼               ▼               ▼               ▼
        ┌─────────┐    ┌───────────┐   ┌────────────┐   ┌──────────┐
        │MIGRATION│    │TRANSLATION│   │AUTO_TRANSLATE│   │   IDLE   │
        │(Faza 1) │    │  _SYNC    │   │  (Faza 3)  │   │(Faza 4)  │
        └────┬────┘    │ (Faza 2)  │   └─────┬──────┘   └────┬─────┘
             │         └─────┬─────┘         │                │
             │               │               │                │
             ▼               ▼               ▼                ▼
      ┌──────────────────────────────────────────────────────────┐
      │  Wykonaj zadanie → Git commit → Update status            │
      │  Sleep DELAY → Wróć do DISPATCHER                        │
      └──────────────────────────────────────────────────────────┘
```

---

## 📋 CZEGO BRAKUJE W OBECNEJ IMPLEMENTACJI

### ✅ Już zaimplementowane:
1. [x] Dispatcher z priorytetami kategorii (31 kategorii)
2. [x] Progresywny backoff dla pustych kategorii
3. [x] TRANSLATION_SYNC (55 języków)
4. [x] count_files_needing_work() dla każdej kategorii
5. [x] Rozszerzona detekcja NPC (npcHandler:say, NpcHandler:say)

### ❌ Do zaimplementowania:

#### 1. AUTO_TRANSLATE (Faza 3) - obecnie brak automatyzacji
```python
# Potrzebne:
- Translation Memory loader
- Glossary z terminami gry
- Funkcja auto_translate_key(lang, key, en_text)
- Integracja z dispatcher (po TRANSLATION_SYNC)
```

#### 2. IDLE z pełną funkcjonalnością (Faza 4)
```python
# Potrzebne:
- Skanowanie nowych plików
- Generowanie dokumentacji per-NPC
- Raporty jakości
- Raporty dzienne
```

#### 3. Walidacja jakości tłumaczeń
```python
# Potrzebne:
- Sprawdzanie {placeholders}
- Sprawdzanie 'komend'
- Wykrywanie niespójności
```

---

## 🚀 PLAN IMPLEMENTACJI

### Etap 1: Napraw detekcję (✅ DONE)
- Rozszerzona detekcja npcHandler:say

### Etap 2: Uzupełnij AUTO_TRANSLATE
- [ ] Dodaj tryb AUTO_TRANSLATE do dispatcher
- [ ] Implementuj auto_translate_keys() z TM
- [ ] Dodaj glossary loader

### Etap 3: Rozbuduj IDLE
- [ ] Skanowanie nowych plików
- [ ] Generowanie dokumentacji
- [ ] Raporty jakości

### Etap 4: Testy i stabilizacja
- [ ] Test pełnego cyklu 24h
- [ ] Obsługa błędów i recovery
- [ ] Logi i monitoring

---

## ⚙️ KONFIGURACJA DOCELOWA

```bash
# Uruchomienie workera autonomicznego
./i18n_worker_simple.sh --continuous 50 15

# Opcje:
#   50 = batch size per category
#   15 = delay między cyklami (sekundy)
#   --no-git = bez pushowania do git
#   --translate-limit 100 = max 100 tłumaczeń na cykl
```

---

## 📊 METRYKI SUKCESU

| Metryka | Cel | Sposób pomiaru |
|---------|-----|----------------|
| Pliki NPC zmigrowane | 100% | count with i18nKey + NPC_LIB |
| Języki zsynchronizowane | 55 | count languages with npc.json |
| Tłumaczenia bez [LANG] | >50% | count non-placeholder values |
| Dokumentacja NPC | 100% | count docs/i18n/npc/*.md |
| Czas IDLE | <10% cyklu | stats from logs |

---

## ❓ PYTANIA DO ZATWIERDZENIA

1. **Czy zgadzasz się z 4 fazami pracy?**
   - MIGRATION → TRANSLATION_SYNC → AUTO_TRANSLATE → IDLE

2. **Czy 55 języków to docelowa lista?**
   - Mogę dodać/usunąć według potrzeb

3. **Czy priorytety kategorii są OK?**
   - NPC (1) → scripts (2) → monsters (3) → ...

4. **Czy AUTO_TRANSLATE ma używać zewnętrznych API?**
   - Na razie tylko TM + glossary + patterns

5. **Jakie raporty w trybie IDLE?**
   - Dzienne? Tygodniowe? Per-język?

---

**Czekam na Twoje zatwierdzenie lub uwagi!**
