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

## 📡 STATUS / DASHBOARD (wymagania jakości)

**Cel:** Każdy cykl workera ma być w 100% obserwowalny: co robi teraz, co zrobił w cyklu, co zrobił dziś.

**Kanoniczny plan:** `docs/i18n/STATUS_AND_DASHBOARD_PLAN.md`

### Wymagania wspólne (dla każdej fazy)
- **Heartbeat:** worker aktualizuje stan co etap (min: start/koniec etapu). Brak heartbeat ma być widoczny jako "stale".
- **Phase + Stage:** zawsze raportuj oba pola (faza = co, etap = jaki krok).
- **Kategoria + Plik:** jeśli faza jest per-kategoria/per-plik — te pola muszą być ustawione.
- **Delta:** każda faza raportuje "co zmieniła" (keys_added/files_changed/translated/etc.).
- **Wynik:** `ok|skip|backoff|error` na poziomie etapu.

### Wymagania do I18N_STATUS.md
- Sekcja **🔴 LIVE** pokazuje *aktualny* `phase`, `stage`, `category`, `file`, `message`, `progress`, `ETA`.
- Sekcja **W tym cyklu** pokazuje krótką listę kroków wykonanych w cyklu (max 5–10 ostatnich).
- Sekcja **Dziś (UTC)** pokazuje agregację dzienną (pliki/klucze/tłumaczenia/błędy).
- Sekcje kategorii mają **spójny format**: te same pola niezależnie od statusu (nawet 0).

### FAZA 1.5: COMPACT_KEYS (optymalizacja bandwidth)
**Cel:** Stabilne mapowanie kluczy semantycznych (EN) → krótkie ID (2–7 znaków) + eksport słowników klienta pod compact ID.

**Założenia:**
- Kod i dane serwera dalej używają kluczy semantycznych (`npc.rashid.greeting`).
- Protokół i klient docelowo używają kluczy compact (2–7 znaków), aby zmniejszyć payload.

**Artefakty (kanoniczne):**
- `i18n/keymap.json`, `i18n/keymap_rev.json`, `i18n/keymap_meta.json`
- `testyy/data/locales/game_i18n_{lang}_compact.lua`

**Logika (na cykl / w IDLE między większymi pracami):**
```
1. Keymap sync: uzupełnij mapping dla wszystkich kluczy EN (append-only)
2. Keymap verify: sprawdź unikalność i zakres 2–7
3. Eksport client locales: generuj game_i18n_{lang}_compact.lua (min: en, pl)
4. Zapisz metryki do statusu: mapped/en_total, next_id, min..max
```

**Wymagania statusu (COMPACT_KEYS):**
- LIVE: `mapped_new` w cyklu, `mapped_total/en_total`, `next_id`, `exported_langs`.
- Eventy: `KEYMAP_SYNC`, `KEYMAP_VERIFY`, `EXPORT_COMPACT_LOCALES`.

**Narzędzia:**
- `python3 tools/i18n_keymap.py sync --i18n-dir i18n --min-len 2 --max-len 7`
- `python3 tools/i18n_keymap.py verify --i18n-dir i18n`
- `python3 tools/json_to_lua_locales.py --lang pl --compact-keys --i18n-dir i18n`

**Dokument docelowy:** `docs/i18n/COMPACT_KEYS_PLAN.md`

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

**Wymagania statusu (TRANSLATION_SYNC):**
- LIVE: `lang`, `json_file/category`, `keys_to_sync`, `keys_synced`.
- Eventy: `SYNC_START`, `SYNC_FILE_DONE`, `SYNC_LANG_DONE`.

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

**Wymagania statusu (AUTO_TRANSLATE):**
- LIVE: `lang`, `json_file`, `translated/skipped`, `validator_result` (placeholders).
- Eventy: `AUTO_TRANSLATE_START`, `AUTO_TRANSLATE_KEY_OK`, `AUTO_TRANSLATE_KEY_SKIP`, `AUTO_TRANSLATE_DONE`.

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

**Wymagania statusu (IDLE):**
- LIVE: `sleep_seconds`, `next_check_at`, `new_files_detected`.
- Eventy: `IDLE_SLEEP`, `IDLE_SCAN`, `IDLE_NEW_WORK_DETECTED`.

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
│  ├─ Sprawdź COMPACT_KEYS (keymap sync/export)                │
│  ├─ Sprawdź TRANSLATION_SYNC                                 │
│  ├─ Sprawdź AUTO_TRANSLATE                                   │
│  └─ Zwróć tryb: MIGRATION|TRANSLATION_SYNC|AUTO_TRANSLATE|IDLE│
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┬───────────────┐
              │               │               │               │
              ▼               ▼               ▼               ▼
        ┌─────────┐    ┌───────────┐   ┌────────────┐   ┌──────────┐
      │MIGRATION│    │COMPACT_KEYS│   │TRANSLATION │   │AUTO_TRANSLATE│
      │(Faza 1) │    │ (Faza 1.5) │   │  _SYNC    │   │  (Faza 3)    │
      └────┬────┘    └─────┬─────┘   │ (Faza 2)  │   └─────┬────────┘
           │               │         └─────┬─────┘         │
           │               │               │                │
           ▼               ▼               ▼                ▼
                         ┌──────────┐
                         │   IDLE   │
                         │(Faza 4)  │
                         └────┬─────┘
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

#### 0. COMPACT_KEYS (Faza 1.5) - do spięcia w dispatcher/status
```text
# Potrzebne:
- Job: keymap sync/verify (tools/i18n_keymap.py)
- Job: export compact locales (tools/json_to_lua_locales.py --compact-keys)
- Status: metryki mappingu w I18N_STATUS.md + JSON status (jeśli wdrożymy)
```

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

### Etap 1.5: Wdroż COMPACT_KEYS
- [ ] Ustalić mapowanie EN→compact jako append-only (2–7 znaków)
- [ ] Dodać cykliczny `keymap sync` i `keymap verify`
- [ ] Generować `game_i18n_{lang}_compact.lua` (min: en + pl)
- [ ] Dopisać sekcję do `I18N_STATUS.md` z metrykami compact keys
- [ ] (Opcjonalnie) ujednolicić ścieżki statusu: `i18n/status/*.json` vs realne pliki workera

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
   - MIGRATION → COMPACT_KEYS → TRANSLATION_SYNC → AUTO_TRANSLATE → IDLE

2. **Czy 55 języków to docelowa lista?**
   - Mogę dodać/usunąć według potrzeb

3. **Czy priorytety kategorii są OK?**
   - NPC (1) → scripts (2) → monsters (3) → ...

4. **Czy AUTO_TRANSLATE ma używać zewnętrznych API?**
   - Na razie tylko TM + glossary + patterns

5. **Jakie raporty w trybie IDLE?**
   - Dzienne? Tygodniowe? Per-język?

6. **Czy compact keys mają być używane tylko w protokole i słownikach klienta?**
   - Domyślnie: TAK (kod i JSON na serwerze zostają semantyczne).

---

**Czekam na Twoje zatwierdzenie lub uwagi!**
