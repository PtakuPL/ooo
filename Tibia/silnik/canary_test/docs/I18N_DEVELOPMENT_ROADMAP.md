# 🗺️ I18N System - Plan Rozwoju i Usprawnień

> **Dokument**: Plan rozwoju systemu internacjonalizacji  
> **Wersja**: 7.0  
> **Data**: 2025-12-12 (AKTUALIZACJA ARCHITEKTURY)  
> **Autor**: AI Assistant + PtakuPL

---

## 🔴 ZMIANA ARCHITEKTURY (2025-12-12) - WAŻNE!

### Poprzednie podejście: Server-Side Translation (PORZUCONE)

❌ Serwer tłumaczy teksty → wysyła przetłumaczone → klient wyświetla

**Problemy:**
- Mutex contention przy wielu graczach (200+ × 50 języków)
- Wymaga kompilacji całego serwera C++ z nowymi funkcjami
- Większe obciążenie CPU/RAM na serwerze
- Dłuższe pakiety sieciowe (pełne teksty)

### Nowe podejście: Client-Side Translation (AKTUALNE)

✅ Serwer wysyła klucz i18n → klient tłumaczy lokalnie → wyświetla

**Korzyści:**
| Aspekt | Wartość |
|--------|---------|
| Obciążenie serwera | **Minimalne** - tylko wysyłanie kluczy |
| Bandwidth | **Mniejszy** - klucze krótsze od tekstów |
| Pamięć serwera | **Bez cache** - słowniki tylko na kliencie |
| Kompilacja | **Tylko protokół** - nie cały system i18n |
| Skalowalność | **Lepsza** - każdy klient tłumaczy samodzielnie |
| Hotfix tłumaczeń | **Łatwiejszy** - tylko update plików klienta |

### Pliki do modyfikacji

```
SERWER (canary_test/src/):
├── server/network/protocol/protocolgame.cpp  ← wysyłanie kluczy
├── server/network/protocol/protocolgame.hpp  ← definicje
└── creatures/players/player.cpp               ← sendTextMessage → sendLocalizedMessage

KLIENT (testyy/):
├── src/client/protocolgame.cpp               ← parsowanie kluczy
├── modules/corelib/keyboard.lua              ← funkcja tr() (już istnieje!)
└── data/locales/*.lua                         ← słowniki (już istnieją!)
```

### Plan implementacji protokołu

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ETAP 1: Rozszerzenie pakietu                     │
├─────────────────────────────────────────────────────────────────────┤
│  Pakiet tekstowy (stary):                                           │
│  [opcode][messageType][text]                                        │
│                                                                     │
│  Pakiet tekstowy (nowy - kompatybilny wstecz):                     │
│  [opcode][messageType][text][hasI18nKey:byte][i18nKey?]            │
│                                                                     │
│  hasI18nKey = 0 → brak klucza, użyj text                           │
│  hasI18nKey = 1 → jest klucz, spróbuj przetłumaczyć                │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    ETAP 2: Logika klienta                           │
├─────────────────────────────────────────────────────────────────────┤
│  1. Odczytaj pakiet                                                 │
│  2. if hasI18nKey:                                                  │
│     a. translation = tr(i18nKey)                                    │
│     b. if translation != i18nKey:  # znaleziono tłumaczenie        │
│        displayText = translation                                    │
│     c. else:                                                        │
│        displayText = text  # fallback do oryginału                 │
│  3. else:                                                           │
│     displayText = text  # stary format                             │
└─────────────────────────────────────────────────────────────────────┘
```

### Checklist implementacji

- [ ] **SERWER: Analiza** `sendTextMessage()` w `protocolgame.cpp`
- [ ] **SERWER: Dodanie** `sendLocalizedTextMessage(type, text, i18nKey)`
- [ ] **SERWER: Test** kompatybilności wstecznej (stary klient działa)
- [ ] **KLIENT: Analiza** `parseTextMessage()` w `protocolgame.cpp`
- [ ] **KLIENT: Rozszerzenie** o odczyt `i18nKey`
- [ ] **KLIENT: Integracja** z `tr()` z `keyboard.lua`
- [ ] **KLIENT: Fallback** gdy brak tłumaczenia
- [ ] **TEST: End-to-end** - serwer → klient → wyświetlenie

---

## 🛡️ SYSTEM ZABEZPIECZEŃ WORKERA

### Progresywny Backoff dla kategorii

Worker automatycznie zarządza kategoriami które nie zwracają wyników:

| Seria zer | Czas skip | Opis |
|-----------|-----------|------|
| 1x | 5 min | Pierwsza próba bez wyników |
| 2x | 10 min | Druga próba |
| 3x | 30 min | Trzecia próba |
| 4x | 1h | Czwarta próba |
| 5x+ | 2h | Maksymalny czas skip |

### Auto-reset po 24h

Kategorie pomijane przez 24h są automatycznie resetowane:
```python
# W read_category_state():
if now - last_time > 24 * 3600:  # 24 godziny
    state["skip_until"].pop(cat_name, None)
    state["consecutive_zeros"][cat_name] = 0
```

### Plik stanu `.i18n_category_state.json`

```json
{
  "skip_until": {"scripts": 1765398348.92},
  "last_processed": {"npc": {"count": 1, "timestamp": ...}},
  "consecutive_zeros": {"scripts": 3},
  "total_processed": {"items": 1500, "npc": 26}
}
```

### Funkcje zabezpieczające

| Funkcja | Opis |
|---------|------|
| `update_category_state(cat, count)` | Zapisuje wynik, ustawia progresywny skip |
| `read_category_state()` | Odczytuje stan, wykonuje auto-reset 24h |
| `should_skip_category(cat, state)` | Sprawdza czy kategoria ma być pominięta |

---

## 🌍 SYSTEM TŁUMACZEŃ - Etap 1: Synchronizacja Kluczy

> **Data dodania**: 2025-12-10 23:20 UTC  
> **Status**: 🔄 W IMPLEMENTACJI

### Koncepcja

Gdy worker nie ma kategorii do przetwarzania (wszystkie w backoff), przechodzi w **TRYB TŁUMACZEŃ**.

**Etap 1** to **synchronizacja struktury kluczy** - kopiowanie kluczy z `en/*.json` do innych języków z prefixem `[EN]`.

### Przepływ pracy

```
┌─────────────────────────────────────────────────────────────┐
│                    DISPATCHER LOGIC                          │
├─────────────────────────────────────────────────────────────┤
│  1. Sprawdź kategorie migracji (items, npc, scripts...)     │
│     └─ Jeśli wszystkie w backoff → przejdź do TŁUMACZEŃ     │
│                                                              │
│  2. TRYB TŁUMACZEŃ - Etap 1:                                │
│     ├─ Weź kolejny język z listy (de → pl → es → ...)       │
│     ├─ Weź kolejną kategorię JSON (npc → items → monsters)  │
│     ├─ Synchronizuj klucze EN → LANG                        │
│     └─ Zapisz postęp do state                               │
│                                                              │
│  3. Po zakończeniu wszystkich języków:                      │
│     └─ Wróć do sprawdzania migracji (backoff mógł minąć)    │
└─────────────────────────────────────────────────────────────┘
```

### Przykład działania

**Źródło `i18n/en/npc.json`:**
```json
{
  "npc.seymour.greet_1": "Hello, |PLAYERNAME|!",
  "npc.seymour.farewell_1": "Goodbye!"
}
```

**Wynik `i18n/pl/npc.json` (po synchronizacji):**
```json
{
  "npc.seymour.greet_1": "[EN] Hello, |PLAYERNAME|!",
  "npc.seymour.farewell_1": "[EN] Goodbye!"
}
```

### Kolejność języków (od europejskich)

```bash
TARGET_LANGUAGES=(
  # Europa Zachodnia & Środkowa
  "de" "pl" "es" "pt" "fr" "it" "nl" "cs" "sk" "hu" 
  # Europa Północna
  "sv" "da" "no" "fi" "et" "lv" "lt"
  # Europa Południowa & Wschodnia  
  "ro" "bg" "el" "hr" "sl" "bs" "sr" "mk" "sq"
  # Rosja & Azja Środkowa
  "ru" "uk" "kk" "uz" "az" "hy" "ka"
  # Bliski Wschód
  "tr" "ar" "he" "fa"
  # Azja
  "zh" "zh_TW" "ja" "ko" "hi" "th" "vi" "id" "ms" "tl"
  # Inne
  "bn" "ta" "te" "ml" "sw"
)
# Razem: 53 języki (en jest źródłem)
```

### Parametry

| Parametr | Wartość | Opis |
|----------|---------|------|
| `TRANSLATION_BATCH_SIZE` | 300 | Kluczy na cykl |
| `UNTRANSLATED_PREFIX` | `[EN] ` | Prefix dla nieprzetłumaczonych |
| `TRANSLATION_PRIORITY` | NISKI | Migracja ma wyższy priorytet |

### Śledzenie postępu

**Nowy state w `.i18n_category_state.json`:**
```json
{
  "translation_sync": {
    "current_lang": "de",
    "current_category": "npc", 
    "languages_done": ["pl"],
    "stats": {
      "pl": {"npc": 5270, "items": 9000, "total": 14270},
      "de": {"npc": 5270, "total": 5270}
    },
    "last_sync": 1733871600
  }
}
```

### Korzyści Etapu 1

1. ✅ **Wszystkie pliki językowe mają identyczną strukturę**
2. ✅ **Łatwo zobaczyć co wymaga tłumaczenia** (szukaj `[EN]`)
3. ✅ **Gra działa od razu** - wyświetla angielski tekst z prefixem
4. ✅ **Przygotowanie do Etapu 2** - wiadomo ile jest do przetłumaczenia
5. ✅ **Statystyki** - dokładnie widać postęp per język/kategoria

### Etap 2 (przyszłość)

Po ukończeniu Etapu 1, Etap 2 będzie automatycznie tłumaczył teksty z `[EN]` na docelowy język.

---

## 📊 AKTUALNY STAN PROJEKTU (2025-12-10 21:25)

### Statystyki kluczy

| Plik JSON | Kluczy | Opis |
|-----------|--------|------|
| npc.json | 5,270+ | Dialogi NPC |
| monsters.json | 4,158 | Głosy potworów |
| items.json | 1,450+ | Nazwy przedmiotów |
| scripts.json | 385+ | Wiadomości questów |
| spells.json | 15+ | Nazwy zaklęć |
| html.json | 39 | Szablony Twig |
| raids.json | 30 | Wiadomości rajdów |
| cpp.json | 15 | Stringi C++ |
| **TOTAL** | **11,400+** | |

### Co zostało do zrobienia

| Kategoria | Ilość | Priorytet | Status |
|-----------|-------|-----------|--------|
| keywordHandler bez i18nKey | ~1,500 | 🔴 WYSOKI | Worker obsługuje |
| Twig bez trans() | 575 | 🟡 ŚREDNI | Worker obsługuje |
| PHP bez __() | 5,289 | 🟡 ŚREDNI | Worker obsługuje |
| Spells | 591 | 🟡 ŚREDNI | Worker obsługuje |
| Items (pozostałe) | ~2,000+ | 🟢 NISKI | W trakcie |

---

## 🆕 CHANGELOG - Co zostało zrobione

### 📅 2025-12-10 (sesja #6) - System zabezpieczeń Worker 🛡️

| Zmiana | Opis | Status |
|--------|------|--------|
| **Progresywny backoff** | Skip 5min→10min→30min→1h→2h dla kategorii z 0 wynikami | ✅ ZAIMPLEMENTOWANO |
| **consecutive_zeros** | Licznik ile razy z rzędu kategoria zwróciła 0 | ✅ ZAIMPLEMENTOWANO |
| **total_processed** | Śledzenie łącznej liczby przetworzonych elementów per kategoria | ✅ ZAIMPLEMENTOWANO |
| **Auto-reset 24h** | Kategorie pomijane >24h automatycznie resetowane | ✅ ZAIMPLEMENTOWANO |
| **Batch zwiększony** | Z 5 do 15 plików/cykl (3x szybciej) | ✅ ZAIMPLEMENTOWANO |
| **Pattern scripts** | Rozszerzony by łapał stringi z konkatenacją | ✅ NAPRAWIONO |

**📊 Postęp sesji #6:**
| Metryka | Wartość |
|---------|---------|
| keywordHandler | +17 kluczy (ghost_of_a_priest +6, klom_stonecutter +5...) |
| spells | +15 kluczy (dragonling_wave, devovorga_curse...) |
| items | +300+ kluczy (batch=15) |
| Total | 9,810 → 11,400+ (+1,590 kluczy) |

### 📅 2025-12-10 (sesja #5) - Naprawa rotacji kategorii w Dispatcherze 🔄

| Zmiana | Opis | Status |
|--------|------|--------|
| **Problem zidentyfikowany** | Worker utknął na kategorii `scripts` zwracając 0 przetworzonych plików w kółko | ✅ ZDIAGNOZOWANO |
| **Przyczyna** | Dispatcher (Python) zwracał `scripts:406` ale bash processor nic nie znajdował (wszystko już zrobione) | ✅ ZNALEZIONO |
| **Rozwiązanie 1** | Dodano `.i18n_category_state.json` - plik stanu kategorii z mechanizmem skip | ✅ ZAIMPLEMENTOWANO |
| **Rozwiązanie 2** | Nowe funkcje: `read_category_state()`, `should_skip_category()`, `update_category_state()` | ✅ ZAIMPLEMENTOWANO |
| **Rozwiązanie 3** | Śledzenie `KEYS_BEFORE`/`KEYS_AFTER` + `FILES_CHANGED` po każdej kategorii | ✅ ZAIMPLEMENTOWANO |
| **Skip mechanizm** | Kategoria z 0 wynikami pomijana na 5 minut, potem ponowna próba | ✅ DZIAŁA |
| **Nowe kategorie** | Dodano `sendtextmessage`, `keywordhandler`, `twig` do CATEGORIES dict w Pythonie | ✅ DODANO |
| **Wynik** | Worker przeszedł do `items` i dodaje +5 kluczy/cykl | ✅ SUKCES |

**📊 Postęp podczas sesji #5:**
| Metryka | Początek | Koniec | Zmiana |
|---------|----------|--------|--------|
| Total kluczy | 9,810 | 10,683+ | **+873+** |
| Items.json | 110 | 850+ | **+740+** |
| Cykli workera | 1 | 167+ | - |

**📁 Nowe pliki/zmiany:**
- `.i18n_category_state.json` - stan kategorii z `skip_until` i `last_processed`
- `update_category_state()` - funkcja bash zapisująca wynik do JSON
- CATEGORIES dict w Pythonie - dodane priorytety 18-20 dla nowych kategorii

**🔧 Kluczowa zmiana w select_work_mode():**
```python
# Przed: ignorował kategorie które nic nie zwracają
# Po: pomija je na 5 minut dzięki skip_until

cat_state = read_category_state()
for cat_name, config in sorted_cats:
    if should_skip_category(cat_name, cat_state):
        continue  # Pomiń "puste" kategorie
    ...
```

**📊 Stan kategorii po naprawie:**
| Kategoria | Status | Powód |
|-----------|--------|-------|
| npc | ✅ OK | count=1, wszystko zmigrowane |
| scripts | ⏭️ SKIP | count=0, 92 pliki już przetworzone |
| monsters | ⏭️ SKIP | count=0, pattern nie pasuje |
| raids | ⏭️ SKIP | count=0, brak danych XML |
| world | ⏭️ SKIP | count=0, brak danych |
| items | 🔄 AKTYWNY | count=5+, +5 kluczy/cykl |

---

### 📅 2025-12-10 (sesja #4) - Analiza player:sendTextMessage + keywordHandler + Twig 📋

| Zmiana | Opis | Status |
|--------|------|--------|
| **sendTextMessage analiza** | Zidentyfikowano 304 plików z tym samym pattern `"Sold %ix %s for %i gold."` | ✅ ZBADANO |
| **sendLocalizedTextMessage** | Odkryto że istnieje C++ funkcja `player:sendLocalizedTextMessage(type, key, args)` | ✅ ODKRYTO |
| **NPC_LIB.i18n** | Pełna dokumentacja systemu i18n dla NPC (lokalizacja: `data-otservbr-global/lib/npc/i18n.lua`) | ✅ ZDOKUMENTOWANO |
| **keywordHandler status** | 2915 z i18nKey (79%), 778 bez i18nKey (21%) - większość już zrobiona! | ✅ ZLICZONO |
| **Twig templates** | 575 plików, tylko 42 z `trans()` - ogromny potencjał | ✅ ZBADANO |
| **messages.json** | Stworzono z 11 kluczami systemowymi, skopiowano do 53 języków | ✅ ZROBIONO |
| **Test zamiany** | `irea.lua` - pomyślna zamiana na `sendLocalizedTextMessage` | ✅ TEST OK |

**📊 Szczegółowa analiza player:sendTextMessage:**

| Pattern | Ilość | Opis |
|---------|-------|------|
| `"Sold %ix %s for %i gold."` | **304** | Callback sprzedaży - JEDEN pattern! |
| Inne unikalne teksty | ~20 | Różne wiadomości systemowe |

**Odkrycie:** 304 plików ma IDENTYCZNY tekst - wystarczy jedna zamiana sed!

**📊 Status keywordHandler:**

| Stan | Ilość | Procent |
|------|-------|---------|
| Z i18nKey | 2,915 | **79%** ✅ |
| Bez i18nKey | 778 | 21% |
| **RAZEM** | 3,693 | 100% |

**📊 Twig templates:**

| Metryka | Wartość |
|---------|---------|
| Pliki .twig | 575 |
| Z `trans()` | 42 (7%) |
| Bez tłumaczenia | 533 (93%) |
| Najczęstsze teksty | `'Are you sure?'`, `'Logo'`, `'Description'` |

---

### 📅 2025-12-10 (sesja #3) - Naprawa I18N_STATUS.md na GitHub 🔧

| Zmiana | Opis | Status |
|--------|------|--------|
| **Faza 2 hardcode** | PHP/HTML/JS pokazywały 0/X zamiast zmiennych php_keys, html_keys, client_keys | ✅ FIXED |
| **Faza 3 hardcode** | Installer pokazywał 0/94 zamiast cpp_keys | ✅ FIXED |
| **Guard analiza** | Sprawdzono współpracę guard↔worker (push co 2 min) | ✅ OK |
| **Worker targets** | Zaktualizowano TARGETS dict dla nowych kategorii | ✅ DONE |

**Problem:** GitHub I18N_STATUS.md pokazywał 202 kluczy (stara wersja) zamiast 9713.
**Przyczyna:** Worker nadpisywał status swoją funkcją która miała zahardcodowane wartości.
**Rozwiązanie:** Naprawiono `update_github_status()` - Faza 2/3 teraz używa `php_keys`, `html_keys`, `cpp_keys`, `client_keys`.

---

### 📅 2025-12-10 (sesja wieczorna #2) - Masowa ekstrakcja kluczy 🚀

| Zmiana | Opis | Status |
|--------|------|--------|
| **NPC arrays** | Ekstrakcja `npcHandler:say({...})` multiline patterns | ✅ +81 kluczy |
| **NPC voices** | Ekstrakcja `{ text = "...", yell = ... }` patterns | ✅ +604 kluczy |
| **Monster voices** | Rekurencyjne skanowanie monster/**/*.lua | ✅ +4,098 kluczy |
| **Scripts deep scan** | sendTextMessage + creature:say w scripts/**/*.lua | ✅ +290 kluczy |
| **I18N_STATUS.md** | Regeneracja z aktualnymi danymi (pokazywał 3594 zamiast 9448) | ✅ FIXED |
| **Worker keys** | Dodano php_keys, cpp_keys, html_keys, client_keys do total_keys | ✅ FIXED |

**📊 Statystyki PRZED → PO sesji:**
| Źródło | Przed | Po | Zmiana |
|--------|-------|-----|--------|
| npc.json | 4,256 | 4,941 | +685 |
| monsters.json | 10 | 4,108 | **+4,098** |
| scripts.json | 78 | 368 | +290 |
| **RAZEM** | ~4,350 | **9,448** | **+117%** |

---

### 📅 2025-12-10 (sesja wieczorna #1) - Worker v3.0

| Zmiana | Opis | Status |
|--------|------|--------|
| **17 kategorii** | Rozszerzono z 13 do 17: dodano `php`, `html`, `cpp`, `client` | ✅ DONE |
| **worker_commands.txt** | Sterowanie workerem przez GitHub (z telefonu!) | ✅ DONE |
| **Komendy** | `FORCE:kategoria`, `RANDOM`, `STATUS`, `SKIP`, `PAUSE:X`, `NOTE:tekst` | ✅ DONE |
| **PHP kategoria** | Przetwarzanie html_copy/ (5587 plików PHP) | ✅ DONE |
| **C++ kategoria** | Przetwarzanie src/ (186 plików C++) | ✅ DONE |
| **OTClient** | Przetwarzanie testyy/modules (klient gry) | ✅ DONE |
| **update_github_status** | Naprawiono - liczy wszystkie 17+ kategorii | ✅ DONE |

**Statystyki po sesji:**
- 4375 kluczy wyciągniętych
- 17 kategorii obsługiwanych
- 26 plików NPC zmigrowanych z transformacją Lua
- Nowe pliki: `php.json` (8 kluczy), `cpp.json` (15 kluczy)

### 📅 2025-12-10 (sesja popołudniowa) - Worker v2.2

| Zmiana | Opis | Status |
|--------|------|--------|
| **Multi-category dispatcher** | Worker przełącza się między kategoriami | ✅ DONE |
| **13 kategorii** | npc, scripts, monsters, raids, world, spells, items, libs, events, chatchannels, modules, startup, npclib | ✅ DONE |
| **Priorytetyzacja** | Kategorie mają priorytety 1-17 | ✅ DONE |

---

## 🔴 PROBLEM: I18N_STATUS.md - Brakujące kategorie

### Analiza problemu (2025-12-10 21:30)

**Symptom:** I18N_STATUS.md nie pokazuje wielu aktywnych kategorii i ich statystyk.

### Kategorie JSON które ISTNIEJĄ ale NIE SĄ pokazane:

| Plik JSON | Kluczy | Status w I18N_STATUS.md |
|-----------|--------|-------------------------|
| html.json | 39 | ❌ BRAK |
| raids.json | 30 | ❌ BRAK |
| messages.json | 11 | ❌ BRAK |
| startup.json | 8 | ❌ BRAK |
| events.json | 0 | ❌ BRAK w szczegółach |
| chatchannels.json | 0 | ❌ BRAK |
| modules.json | 0 | ❌ BRAK |
| npclib.json | 0 | ❌ BRAK |
| libs.json | 0 | ❌ BRAK |
| world.json | 0 | ❌ BRAK |

### Kategorie WORKERA które NIE SĄ pokazane:

| Kategoria | Opis | Status |
|-----------|------|--------|
| sendtextmessage | Zamiana na sendLocalizedTextMessage | ❌ BRAK |
| keywordhandler | Dodawanie i18nKey do keyword | ❌ BRAK |
| twig | Ekstrakcja z szablonów Twig | ❌ BRAK |

### Informacje z `.i18n_category_state.json` NIE pokazane:

| Pole | Opis | Status |
|------|------|--------|
| consecutive_zeros | Ile razy kategoria zwróciła 0 | ❌ BRAK |
| total_processed | Łączna liczba przetworzonych | ❌ BRAK |
| skip_until | Czas do którego pomijana | ❌ BRAK |
| last_processed | Ostatni wynik kategorii | ❌ BRAK |

### PLAN NAPRAWY I18N_STATUS.md

#### Krok 1: Dynamiczna lista kategorii

```python
# Zamiast hardcodowanych zmiennych:
game_keys = count_keys("game.json")
items_keys = count_keys("items.json")
# ... 

# Użyć dynamicznego skanowania:
all_json_files = os.listdir("i18n/en")
categories = {}
for f in all_json_files:
    if f.endswith(".json"):
        name = f.replace(".json", "")
        categories[name] = count_keys(f)
```

#### Krok 2: Integracja z .i18n_category_state.json

```python
# Wczytaj stan kategorii
try:
    with open(".i18n_category_state.json") as f:
        cat_state = json.load(f)
except:
    cat_state = {}

# Dla każdej kategorii pokaż:
# - Aktualną liczbę kluczy
# - consecutive_zeros (jeśli > 0)
# - skip_until (jeśli aktywny)
# - total_processed
```

#### Krok 3: Nowa sekcja "Worker Activity"

```markdown
## 🤖 Worker Activity

| Kategoria | Kluczy | Przetworzono | Seria zer | Skip do |
|-----------|--------|--------------|-----------|---------|
| items | 2990 | 1155 | 0 | - |
| scripts | 385 | 92 | 2 | 21:35 |
| monsters | 4158 | 0 | 2 | 21:40 |
```

#### Krok 4: Automatyczne TARGETS

```python
# Zamiast hardcodowanych celów:
TARGETS = {"items": 40000, ...}

# Dynamiczne obliczanie z potencjału:
# - items: count(data/XML/items/*.xml)
# - npc: count(data-otservbr-global/npc/*.lua) * avg_keys_per_npc
# - scripts: count(scripts/**/*.lua z sendTextMessage)
```

### Priorytet implementacji

| Krok | Trudność | Wartość | Priorytet |
|------|----------|---------|-----------|
| 1. Dynamiczna lista | ⭐⭐ | ⭐⭐⭐⭐⭐ | P0 |
| 2. Integracja state | ⭐⭐⭐ | ⭐⭐⭐⭐ | P0 |
| 3. Worker Activity | ⭐⭐ | ⭐⭐⭐⭐ | P1 |
| 4. Auto TARGETS | ⭐⭐⭐⭐ | ⭐⭐⭐ | P2 |

---

## 🐛 KNOWN ISSUES / DO NAPRAWY

### 🔴 Priorytet WYSOKI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 1 | **Tryb TRANSLATION pomijany w background** | Worker po zakończeniu migracji przechodzi do TRANSLATION, ale wymaga interaktywnego terminala i jest pomijany. Powinien automatycznie tłumaczyć klucze EN→PL bez interakcji użytkownika. | ❌ DO NAPRAWY |
| 2 | **Brak automatycznego przejścia do dokumentacji** | Po migracji worker nie generuje automatycznie dokumentacji dla wszystkich plików - tylko dla tych przetwarzanych w danym cyklu. | ❌ DO NAPRAWY |
| 3 | **Pliki z konkatenacjami pomijane bez logu** | Pliki z `npcHandler:say("text" .. var)` są pomijane bez informacji dlaczego. | ⚠️ CZĘŚCIOWO |

### 🟡 Priorytet ŚREDNI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 4 | **npcHandler:say z tablicami** | `npcHandler:say({...})` z tablicami tekstów nie jest obsługiwane. | ❌ DO ROZBUDOWY |
| 5 | **voices pattern** | `voices = {{ text = "..." }}` wymaga modyfikacji C++ (broadcast → per-player). | ❌ WYMAGA C++ |
| 6 | **Brak raportu końcowego** | Po zakończeniu migracji brak szczegółowego raportu co zostało zrobione vs co pominięto. | ❌ DO DODANIA |

### ✅ NAPRAWIONE (2025-12-10)

| # | Problem | Rozwiązanie |
|---|---------|-------------|
| N1 | **Bug stage_5 kasujący JSON** | Zmieniono `except: data = {}` na `exit(1)` przy błędzie odczytu |
| N2 | **addGreetKeyword/addFarewellKeyword** | Dodano transformację + naprawiono regex dla callbacków |
| N3 | **GreetModule bez i18n** | Dodano obsługę i18nKey w `custom_modules.lua` |

### ✅ ZROBIONE (2025-12-10 wieczór) - Sesja z agentem

| # | Co zrobiono | Szczegóły |
|---|-------------|-----------|
| W1 | **Worker v3.0 - 17 kategorii** | Rozszerzono z 5 do 17 kategorii: npc, scripts, monsters, raids, world, spells, items, libs, events, chatchannels, modules, startup, npclib, php, html, cpp, client |
| W2 | **worker_commands.txt** | Plik sterowania przez GitHub! Można edytować z telefonu. Komendy: FORCE:kategoria, RANDOM, STATUS, SKIP, PAUSE:X, NOTE:tekst |
| W3 | **Kategoria PHP (html_copy)** | 5587 plików PHP ze strony WWW, funkcja `process_php_category()` |
| W4 | **Kategoria HTML/Twig** | 102 pliki HTML + Twig templates |
| W5 | **Kategoria C++ (src)** | 186 plików C++ serwera, funkcja `process_cpp_category()` |
| W6 | **Kategoria Client (testyy)** | OTClient modules/mods z testyy/ |
| W7 | **Naprawiono update_github_status** | Teraz liczy wszystkie 17+ kategorii (startup, raids, cpp, php, etc.) |
| W8 | **Naprawiono parsing opcji --continuous** | Błąd `head: unrecognized option '---batch'` - naprawiono shift w parsowaniu |
| W9 | **Statystyki: 4375 kluczy** | npc:4256, scripts:78, monsters:10, startup:8, php:8, cpp:15 |

### 🟢 Priorytet NISKI

| # | Problem | Opis | Status |
|---|---------|------|--------|
| 7 | **Zombie procesy** | Stare procesy workera pozostają jako `<defunct>`. | ⚠️ KOSMETYCZNE |
| 8 | **Duplikaty kluczy w JSON** | Brak sprawdzania czy klucz już istnieje z inną wartością. | ❌ DO WALIDACJI |

---

## 🔧 PLAN NAPRAWY (Krótkoterminowy)

### Issue #1: Tryb TRANSLATION w background

**Problem**: Tryb TRANSLATION wymaga interaktywnego terminala (`read` do potwierdzenia tłumaczeń).

**Rozwiązanie**: 
1. Stworzyć tryb `TRANSLATION_AUTO` który automatycznie tłumaczy bez potwierdzenia
2. Użyć API tłumaczeniowego (Google/DeepL) w tle
3. Lub: Kopiować wartości EN jako placeholder z prefiksem `[AUTO] `

**Implementacja**:
```bash
# W select_work_mode po MIGRATION:
if needs_migration == 0:
    # Przejdź do automatycznego tłumaczenia
    print("TRANSLATION_AUTO:pl:1000")
```

### Issue #2: Automatyczna dokumentacja

**Problem**: Dokumentacja generowana tylko dla przetwarzanych plików.

**Rozwiązanie**:
1. Dodać nowy tryb `DOCUMENTATION` po MIGRATION
2. Skanować wszystkie pliki z i18nKey i generować MD
3. Aktualizować index dokumentacji

---

## 🎯 ANALIZA TECHNICZNA: voices i keywordHandler

### 📢 npcConfig.voices - Analiza (2025-12-10)

**Lokalizacja w kodzie:**
- Definicja w NPC: `npcConfig.voices = { interval=N, chance=N, { text = "...", yell = true/false }, ... }`
- Przetwarzanie Lua: `data/scripts/lib/register_npc_type.lua` → `registerNpcType.voices()`
- Przetwarzanie C++: `src/lua/functions/creatures/npc/npc_type_functions.cpp` → `luaNpcTypeAddVoice()`
- Odtwarzanie C++: `src/creatures/npcs/npc.cpp` linii 635-644 → `g_game().internalCreatureSay()`

**Problem i18n voices:**
Voices są **broadcastem** do wszystkich graczy w zasięgu NPC przez `g_game().internalCreatureSay()`. 
Tekst jest wysyłany jednocześnie do wielu graczy - a każdy może mieć inny język!

**Obecny przepływ:**
```
1. Lua: npcConfig.voices = {{ text = "Hello!", yell = false }}
2. Lua: registerNpcType.voices() → npcType:addVoice(text, interval, chance, yell)
3. C++: luaNpcTypeAddVoice() → voiceBlock_t{text, yellText} → voiceVector.push_back()
4. C++: npc.cpp onThink() → losowy voice → g_game().internalCreatureSay(text)
5. C++: game.cpp → dla każdego spectator → player->sendCreatureSay(text)
```

**Propozycja rozwiązania (WYMAGA C++):**

1. **Rozszerzyć `voiceBlock_t`** o pole `std::string i18nKey`:
   ```cpp
   struct voiceBlock_t {
       std::string text;      // Oryginalna wartość (fallback)
       bool yellText;
       std::string i18nKey;   // NOWE: klucz i18n
   };
   ```

2. **Zmodyfikować `luaNpcTypeAddVoice`** aby przyjmować opcjonalny `i18nKey`:
   ```cpp
   // npcType:addVoice(sentence, interval, chance, yell, i18nKey)
   voice.i18nKey = Lua::isString(L, 6) ? Lua::getString(L, 6) : "";
   ```

3. **Zmodyfikować `npc.cpp`** aby wysyłać zlokalizowany tekst:
   ```cpp
   for (const auto &spectator : spectators) {
       if (const auto &tmpPlayer = spectator->getPlayer()) {
           std::string localizedText = text;
           if (!i18nKey.empty()) {
               localizedText = tmpPlayer->getLocalizedText(i18nKey, text);
           }
           tmpPlayer->sendCreatureSay(creature, type, localizedText, pos);
       }
   }
   ```

4. **Zmodyfikować `registerNpcType.voices`** w Lua:
   ```lua
   registerNpcType.voices = function(npcType, mask)
       if type(mask.voices) == "table" then
           local interval = mask.voices.interval
           local chance = mask.voices.chance
           for k, v in pairs(mask.voices) do
               if type(v) == "table" then
                   npcType:addVoice(v.text, interval, chance, v.yell, v.i18nKey or "")
               end
           end
       end
   end
   ```

**Transformacja worker'em:**
```lua
-- PRZED:
npcConfig.voices = {
    interval = 15000, chance = 50,
    { text = "Don't forget to deposit your money!", yell = false },
}

-- PO:
npcConfig.voices = {
    interval = 15000, chance = 50,
    { text = "Don't forget to deposit your money!", yell = false, i18nKey = "npc.paulie.voice_1" },
}
```

**Klucze w npc.json:**
```json
{
    "npc.paulie.voice_1": "Don't forget to deposit your money!"
}
```

**Szacowany nakład pracy:**
- Modyfikacje C++: 2-4 godziny (voiceBlock_t, npc_type_functions, npc.cpp)
- Modyfikacje Lua: 30 min (register_npc_type.lua)
- Transformacja worker: 1-2 godziny (nowy etap stage_4_voices)
- Testowanie: 1-2 godziny

### 🔑 keywordHandler:add*Keyword - Analiza (TODO)

**Typy:**
- `keywordHandler:addKeyword({"word"}, callback, {i18nKey = "..."})`
- `keywordHandler:addAliasKeyword({"alias"}, callback)`

**Lokalizacja:**
- Definicja: `data/npclib/npc_system/keyword_handler.lua`

**Status:** ✅ 79% ZROBIONE (2915 z i18nKey, 778 bez)

---

## 🔧 TECHNICZNE FAKTY - System i18n (Sesja #4)

### 📁 Struktura plików i18n

**Główny folder:** `i18n/` (53 języki: en, pl, de, es, fr, etc.)

**Pliki JSON w każdym języku:**
| Plik | Opis | Klucze |
|------|------|--------|
| `npc.json` | Dialogi NPC | ~5,206 |
| `monsters.json` | Głosy potworów | ~4,108 |
| `scripts.json` | Teksty ze skryptów | ~368 |
| `messages.json` | **NOWY!** Wiadomości systemowe | 11 |
| `cpp.json` | Teksty z kodu C++ | 15 |
| `php.json` | Teksty z PHP (strona WWW) | 8 |
| `startup.json` | Teksty startowe | 8 |

**Szukanie plików przez C++ (w kolejności):**
1. `data-otservbr-global/i18n/`
2. `data/i18n/`
3. `i18n/`

### 📞 Funkcje wysyłania tekstu do gracza

| Funkcja | Tłumaczy? | Użycie |
|---------|-----------|--------|
| `player:sendTextMessage(type, text)` | ❌ NIE | Zwykły tekst |
| `player:sendLocalizedTextMessage(type, key, args)` | ✅ TAK | **Główna funkcja i18n!** |
| `NPC_LIB.i18n.npcSay(handler, npc, creature, key, args)` | ✅ TAK | Wrapper dla NPC |
| `NPC_LIB.i18n.sayLocalized(player, key, args, type)` | ✅ TAK | Bezpośredni wrapper |

### 🔑 Format kluczy i argumentów

**Klucze używają numerowanych placeholderów `{1}`, `{2}`, `{3}`:**
```json
{
  "system.trade.sold": "Sold {1}x {2} for {3} gold."
}
```

**Wywołanie z Lua:**
```lua
-- Argumenty jako tablica (indeksowana od 1)
player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
-- → "Sold 5x sword for 100 gold."
```

### 📄 Lokalizacja kodu i18n

| Komponent | Plik | Opis |
|-----------|------|------|
| **NPC_LIB.i18n** | `data-otservbr-global/lib/npc/i18n.lua` | Wrapper Lua dla NPC |
| **Translator C++** | `src/utils/i18n/translator.cpp` | Ładowanie JSON, tłumaczenie |
| **Player functions** | `src/lua/functions/creatures/player/player_functions.cpp:2631` | `sendLocalizedTextMessage` |
| **Player implementation** | `src/creatures/players/player.cpp:2345` | Wysyłanie do klienta |
| **server_i18n.lua** | `data/libs/server_i18n.lua` | Alternatywny system (nieużywany) |

### 🔄 Przepływ tłumaczenia

```
1. Lua: player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {5, "sword", 100})
2. C++: PlayerFunctions::luaPlayerSendLocalizedTextMessage()
3. C++: player->sendLocalizedTextMessage(type, key, args)
4. C++: Translator::translate(key, player->getLanguage())  ← TŁUMACZENIE
5. C++: Podstawienie {1}, {2}, {3} → "Sold 5x sword for 100 gold."
6. C++: player->sendTextMessage() z przetłumaczonym tekstem
7. Klient: Wyświetla tekst
```

### 📦 messages.json - Klucze systemowe (Sesja #4)

```json
{
  "system.trade.sold": "Sold {1}x {2} for {3} gold.",
  "system.trade.bought": "Bought {1}x {2} for {3} gold.",
  "system.blessing.received": "You received the remaining {1} blesses.",
  "system.blessing.already": "You are already blessed.",
  "system.store.check_inbox": "Please make sure you have free slots in your store inbox.",
  "system.experience.gained": "You gained {1} experience points.",
  "system.mission.points": "You earned {1} point(s) on the {2} mission.",
  "system.mount.received": "Congratulations you received the {1} mount.",
  "system.item.received": "You gained a {1}.",
  "system.stash.count": "Your supply stash contains {1} items.",
  "system.venture.decay": "Venture the path of decay!"
}
```

### ⚡ Gotowe polecenia sed do migracji

**1. Zamiana `Sold %ix %s for %i gold.` (304 pliki):**
```bash
find data-otservbr-global/npc/ -name "*.lua" -exec sed -i \
  's|player:sendTextMessage(MESSAGE_TRADE, string\.format("Sold %ix %s for %i gold\.", amount, name, totalCost))|player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})|g' {} \;
```

**2. Zamiana `You are already blessed.`:**
```bash
sed -i 's|player:sendTextMessage(MESSAGE_STATUS, "You are already blessed.")|player:sendLocalizedTextMessage(MESSAGE_STATUS, "system.blessing.already")|g' data-otservbr-global/npc/*.lua
```

### 📊 Statystyki do dalszej pracy

| Kategoria | Do zrobienia | Priorytet |
|-----------|--------------|-----------|
| sendTextMessage `"Sold..."` | 304 pliki | 🔴 WYSOKI (1 sed!) |
| keywordHandler bez i18nKey | 778 wywołań | 🟡 ŚREDNI |
| Twig bez trans() | 533 pliki | 🟢 NISKI |
| Inne sendTextMessage | ~20 unikalnych | 🟡 ŚREDNI |

---

## 📋 Spis treści

1. [Obecny stan systemu](#-obecny-stan-systemu)
2. [Faza 1: Optymalizacja Workera](#-faza-1-optymalizacja-workera)
3. [Faza 2: Rozszerzenie typów plików](#-faza-2-rozszerzenie-typów-plików)
4. [Faza 3: System tłumaczeń](#-faza-3-system-tłumaczeń)
5. [Faza 4: Walidacja i testy](#-faza-4-walidacja-i-testy)
6. [Faza 5: Integracja z serwerem](#-faza-5-integracja-z-serwerem)
7. [Faza 6: Panel administracyjny](#-faza-6-panel-administracyjny)
8. [Faza 7: Automatyzacja CI/CD](#-faza-7-automatyzacja-cicd)
9. [Skrypty do stworzenia](#-skrypty-do-stworzenia)
10. [Priorytety i harmonogram](#-priorytety-i-harmonogram)

---

## 📊 Obecny stan systemu

> **Ostatnia aktualizacja:** 2025-12-10 16:15 UTC

### ✅ Co mamy (ZROBIONE):
- ✅ `i18n_worker_simple.sh` - **Worker v3.0** Multi-Mode (17 kategorii!)
- ✅ `worker_commands.txt` - **Sterowanie przez GitHub** (z telefonu!)
- ✅ `i18n_guardian.sh` - Guardian restartujący workera + auto-push
- ✅ 53 katalogi językowe w `i18n/`
- ✅ Pliki JSON z kluczami (npc.json, scripts.json, monsters.json, php.json, cpp.json, etc.)
- ✅ Cron job dla Guardian
- ✅ **StdModule.say** - 297/297 plików zmigrowanych (100%)
- ✅ **npcHandler:say("...", npc, creature)** - ~150 plików zmigrowanych
- ✅ **addGreetKeyword/addFarewellKeyword** - 43/43 plików zmigrowanych (78 kluczy)
- ✅ **GreetModule** obsługuje i18nKey w `custom_modules.lua`
- ✅ **4375 kluczy** we wszystkich plikach JSON

### 🆕 Worker v3.0 - 17 kategorii:
| Kategoria | Folder | Plików | Kluczy | Status |
|-----------|--------|--------|--------|--------|
| `npc` | data-otservbr-global/npc | 1026 | 4256 | 🔄 Aktywna |
| `scripts` | data-otservbr-global/scripts | 1755 | 78 | 🔄 Aktywna |
| `monsters` | data-otservbr-global/monster | 1637 | 10 | 🔄 Aktywna |
| `raids` | data-otservbr-global/raids | ~50 | 0 | ⏳ Nowa |
| `world` | data-otservbr-global/world | ~20 | 0 | ⏳ Nowa |
| `spells` | data/scripts/spells | ~200 | 0 | ⏳ Nowa |
| `items` | data/items | 1 (XML) | 0 | ⏳ Nowa |
| `libs` | data/libs | 55 | 0 | ⏳ Nowa |
| `events` | data/events | 4 | 0 | ⏳ Nowa |
| `chatchannels` | data/chatchannels | 8 | 0 | ⏳ Nowa |
| `modules` | data/modules | 7 | 0 | ⏳ Nowa |
| `startup` | data-otservbr-global/startup | 20 | 8 | 🔄 Aktywna |
| `npclib` | data/npclib | 7 | 0 | ⏳ Nowa |
| `php` | html_copy/ | 5587 | 8 | 🆕 Nowa! |
| `html` | html_copy/ | 102 | 0 | 🆕 Nowa! |
| `cpp` | src/ | 186 | 15 | 🆕 Nowa! |
| `client` | testyy/modules | ~100 | 0 | 🆕 Nowa! |

### 🎮 Sterowanie workerem (worker_commands.txt):
```bash
# Komendy (odkomentuj w pliku na GitHub):
FORCE:monsters    # Wymuś kategorię
RANDOM           # Losowa kategoria
STATUS           # Pokaż status
SKIP             # Pomiń cykl
PAUSE:5          # Pauza 5 cykli
NOTE:tekst       # Notatka
```

### ⚠️ NAPRAWIONE BUGI (ta sesja):
- ✅ **Krytyczny bug stage_5**: `data = {}` przy błędzie kasowało JSON → zmieniono na `exit(1)`
- ✅ **Regex greet/farewell**: Nie łapał formatu z callbackiem `}, function(player)` → naprawiono
- ✅ **update_github_status**: Nie liczył nowych kategorii → naprawiono

### ❌ Pozostało do zrobienia:
- ❌ **voices** - ~300+ plików, wymaga modyfikacji C++ (broadcast → per-player)
- ✅ **npcHandler:say({...})** - tablice tekstów (22 z 24 plików przetworzonych - 265 nowych kluczy)
- ❌ **Automatyczne tłumaczenia** - tryb TRANSLATION wymaga interaktywnego terminala
- ❌ **Scripts z wieloliniowymi sendTextMessage** - regex nie łapie multi-line
- ❌ **Scripts ze zmiennymi** - `sendTextMessage(type, info.msgs[2])` - pominąć lub oznaczyć

### 🔴 Kolejne do zrobienia (PRIORYTET):
| Wzorzec | Plików | Wymaga C++ | Złożoność | Status |
|---------|--------|------------|-----------|--------|
| `voices = {{ text = }}` | ~131 | **TAK** | 🔶 ŚREDNIA | 📋 ANALIZA GOTOWA |
| `npcHandler:say({array})` | ~~50~~ **2** | NIE | 🟢 NISKA | ✅ **95% GOTOWE** |
| `player:sendTextMessage()` | ~312 | NIE | 🟡 ŚREDNIA | ❌ DO ZROBIENIA |
| `scripts - zmienne` | ~100+ | NIE | 🔴 WYSOKA | ⚠️ RĘCZNA PRACA |
| `keywordHandler:add*Keyword` | ~21 | NIE | 🟢 NISKA | ❌ DO ANALIZY |

### ✅ ZROBIONE (2025-12-10 - sesja wieczorna 17:00+)

| ID | Co zrobiono | Szczegóły |
|----|-------------|-----------|
| A1 | **npcHandler:say({...}) konwersja** | 22/24 plików, 89 tablic → 265 kluczy i18n |
| A2 | **Nowy skrypt Python** | `i18n_process_say_arrays.py` do konwersji tablic |
| A3 | **Nowa funkcja Lua** | `NPC_LIB.i18n.npcSayMultiple()` do tablic i18n |

**Pozostałe 2 pliki z tablicami (wymaga ręcznej migracji):**
- `lynda.lua` - dynamiczne wartości (imiona graczy w ceremonii ślubnej)
- `inigo.lua` - używa zmiennych (`hints[i]`) zamiast stringów

### 📝 NOTATKI - Scripts problem:
Wiele plików scripts używa:
1. **Zmiennych**: `sendTextMessage(type, info.msgs[2])` - nie można automatycznie
2. **Konkatenacji**: `"You have " .. time .. " seconds"` - wymaga placeholderów `{time}`
3. **Multi-line**: Regex `sendTextMessage\([^)]+\)` nie łapie wieloliniowych

**Rozwiązanie**: Nowy regex lub ręczna migracja dla skomplikowanych przypadków.

---

## 📈 PEŁNA ANALIZA PROJEKTU (2025-12-10)

### 🎮 1. DATA-OTSERVBR-GLOBAL (Serwer Lua)

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **npc/** | 1026 | 812 | 🔄 Częściowo |
| **scripts/** | 1755 | 668 | ❌ Do zrobienia |
| **monster/** | 1637 | 3 | ❌ Do zrobienia |
| **startup/** | 20 | 3 | ❌ Do zrobienia |
| **lib/** | 26 | 10 | ❌ Do zrobienia |
| **migrations/** | 52 | 0 | ✅ Nie wymaga |

#### Typy funkcji tekstowych w NPC:

| Typ | Plików | Z i18nKey | Do migracji | Priorytet | Status |
|-----|--------|-----------|-------------|-----------|--------|
| `StdModule.say(text=)` | 297 | 297 ✅ | 0 | - | ✅ DONE |
| `npcHandler:say("text")` | ~450 | ~450 ✅ | **~2** | - | ✅ v2.1 DONE |
| `npcHandler:say({array})` | 24 | **22** ✅ | **2** | 🟡 ŚREDNI | ✅ 95% DONE |
| `player:sendTextMessage()` | 312 | 0 | **312** | 🔴 WYSOKI | ❌ TODO |
| `voices = {{ text = }}` | 131 | 0 | **131** | 🟡 ŚREDNI | ❌ TODO (C++) |
| `keywordHandler:add*Keyword` | 21 | 0 | **21** | 🟡 ŚREDNI | ❌ TODO |

### 🌐 2. HTML_COPY (Strona WWW - AAC)

| Typ pliku | Ilość | Z tekstami | Status |
|-----------|-------|------------|--------|
| **PHP** | 5587 | ~1310 | ❌ Do zrobienia |
| **HTML** | 102 | ~50 | ❌ Do zrobienia |
| **JavaScript** | 4967 | ~500 | ❌ Do zrobienia |
| **Twig templates** | 575 | ~300 | ❌ Do zrobienia |

### 📂 3. DATA (Główne skrypty)

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **scripts/** | 479 | 200 | ❌ Do zrobienia |
| **libs/** | 55 | 23 | ❌ Do zrobienia |
| **modules/** | 7 | 5 | ❌ Do zrobienia |
| **chatchannels/** | 8 | 6 | ❌ Do zrobienia |
| **npclib/** | 7 | 6 | ❌ Do zrobienia |
| **events/** | 4 | 1 | ❌ Do zrobienia |

### ⚙️ 4. SRC (C++ Server)

| Typ | Ilość | Z stringami | Status |
|-----|-------|-------------|--------|
| **cpp** | 186 | 168 | ❌ Do zrobienia |
| **hpp** | 249 | ~50 | ❌ Do zrobienia |

### 🎮 5. DATA-CANARY

| Katalog | Plików | Z tekstami | Status |
|---------|--------|------------|--------|
| **monster/** | 67 | 51 | ❌ Do zrobienia |
| **scripts/** | 25 | 5 | ❌ Do zrobienia |
| **npc/** | 1 | 1 | ❌ Do zrobienia |

### 💻 6. TESTYY (Instalka/Klient OTClient)

| Typ | Ilość | Z tekstami | Status |
|-----|-------|------------|--------|
| **Lua/OTUI/OTMOD** | 449 | 284 | ❌ Do zrobienia |

---

## 📋 PLAN ROZSZERZENIA WORKERA

### Faza A: NPC Completion (PRIORYTET 🔴)

1. **`npcHandler:say("text")`** - 91 plików
   - Format: `npcHandler:say("text", npc, creature)`
   - Zamiana na: `npcHandler:sayI18n("key", npc, creature)`
   - Klucze: `npc.{nazwa}.say_{N}`

2. **`player:sendTextMessage()`** - 312 plików
   - Format: `player:sendTextMessage(TYPE, "text")`
   - Zamiana na: `player:sendTextMessageI18n(TYPE, "key")`
   - Klucze: `system.{nazwa}.msg_{N}`

### Faza B: Scripts (PRIORYTET 🟡)

3. **data-otservbr-global/scripts/** - 668 plików
   - `player:sendTextMessage()`
   - `creature:say()`
   - `Game.broadcastMessage()`
   - Klucze: `scripts.{kategoria}.{nazwa}.msg_{N}`

### Faza C: C++ Server (PRIORYTET 🟡)

4. **src/*.cpp** - 168 plików
   - `player->sendTextMessage()`
   - `fmt::format()`
   - Wymaga: Raportu + ręcznej implementacji
   - Klucze: `cpp.{moduł}.{funkcja}.msg_{N}`

### Faza D: Website AAC (PRIORYTET 🟢)

5. **html_copy/*.php** - 1310 plików
   - `echo "text"`
   - `$lang['key']`
   - Klucze: `web.{strona}.{sekcja}.msg_{N}`

6. **html_copy/*.twig** - 575 plików
   - `{{ 'text' }}`
   - Klucze: `web.tpl.{nazwa}.msg_{N}`

### Faza E: Klient OTClient (PRIORYTET 🟢)

7. **testyy/** - 284 plików
   - `tr("text")` (już może istnieć system!)
   - `.otui` files
   - Klucze: `client.{moduł}.{element}`

---

## 📊 PODSUMOWANIE DO MIGRACJI

| Kategoria | Plików | Szacunkowa ilość tekstów | Priorytet |
|-----------|--------|--------------------------|-----------|
| NPC (pozostałe) | 403 | ~2000 | 🔴 WYSOKI |
| Scripts Lua | 868 | ~3000 | 🟡 ŚREDNI |
| C++ Server | 218 | ~500 | 🟡 ŚREDNI |
| PHP Website | 1310 | ~5000 | 🟢 NISKI |
| Twig Templates | 575 | ~1500 | 🟢 NISKI |
| OTClient | 284 | ~1000 | 🟢 NISKI |
| **RAZEM** | **~3658** | **~13000** | - |

---

### Ograniczenia obecnego systemu (v2.1):
- ✅ ~~Worker przetwarza tylko `StdModule.say`~~ - NAPRAWIONE v2.1
- ✅ ~~Brak obsługi `npcHandler:say()`~~ - DODANE v2.1
- ❌ Brak obsługi `npcHandler:say({tablica})` z wieloma tekstami
- ❌ Brak obsługi `player:sendTextMessage()`
- ❌ Brak obsługi `voices` i `keywordHandler`
- ❌ Brak parsera PHP/C++/Twig
- ❌ **Brak automatycznego tłumaczenia** (tryb TRANSLATION wymaga interaktywnego terminala)
- ❌ **Brak automatycznego przejścia** z MIGRATION → TRANSLATION → DOCUMENTATION
- ❌ Brak walidacji poprawności kodu po modyfikacji
- ❌ Brak rollback w przypadku błędów

---

## 🚀 Faza 1: Optymalizacja Workera

### 1.1 Wielowątkowość / Równoległe przetwarzanie

**Cel**: Przyspieszenie przetwarzania plików

**Skrypt**: `i18n_parallel_worker.sh`

```
Koncepcja:
- Podział plików na partie (batches) po 50-100 plików
- Uruchomienie N procesów równoległych (np. 4)
- Każdy proces przetwarza swoją partię
- Synchronizacja wyników do wspólnego pliku JSON
- Mutex/lock na plikach JSON podczas zapisu
```

**Korzyści**:
- 4x szybsze przetwarzanie
- Lepsze wykorzystanie CPU

---

### 1.2 Inteligentne wykrywanie zmian

**Cel**: Przetwarzanie tylko zmienionych plików

**Skrypt**: `i18n_incremental_worker.sh`

```
Koncepcja:
- Przechowywanie hash MD5/SHA256 każdego przetworzonego pliku
- Plik: .i18n_file_hashes.json
- Przy każdym cyklu: porównanie hashy
- Przetwarzanie tylko plików ze zmienionym hashem
- Obsługa nowych plików (brak hashu = nowy)
- Obsługa usuniętych plików (hash bez pliku = usuń klucze)
```

**Struktura hashy**:
```json
{
  "data-otservbr-global/npc/john.lua": {
    "hash": "a1b2c3d4...",
    "last_processed": "2025-12-08T18:00:00Z",
    "keys_count": 15
  }
}
```

---

### 1.3 Checkpoint i Resume

**Cel**: Możliwość wznowienia od miejsca przerwania

**Skrypt**: `i18n_checkpoint_manager.sh`

```
Koncepcja:
- Co 100 plików: zapis checkpoint do .i18n_checkpoint.json
- Checkpoint zawiera:
  - Lista przetworzonych plików
  - Aktualny katalog
  - Liczniki statystyk
  - Timestamp
- Przy starcie: sprawdź czy jest checkpoint
- Jeśli tak: zapytaj o resume lub fresh start
- Po zakończeniu pełnego cyklu: usuń checkpoint
```

---

### 1.4 Zaawansowane logowanie

**Cel**: Lepsze monitorowanie i debugging

**Skrypt**: `i18n_logger.sh` (library)

```
Koncepcja:
- Poziomy logów: DEBUG, INFO, WARN, ERROR, FATAL
- Rotacja logów (max 10 plików, max 10MB każdy)
- Osobne logi dla różnych komponentów:
  - worker.log - główny worker
  - guardian.log - guardian
  - git.log - operacje git
  - errors.log - tylko błędy
- Format: [TIMESTAMP] [LEVEL] [COMPONENT] Message
- Opcja: wysyłanie krytycznych błędów na Discord/Telegram
```

---

## 📁 Faza 2: Rozszerzenie typów plików

### 2.1 Parser C++ dla src/

**Cel**: Ekstrakcja stringów z kodu C++

**Skrypt**: `i18n_cpp_parser.sh`

```
Koncepcja:
- Skanowanie plików .cpp i .hpp w src/
- Wykrywanie wzorców:
  - player->sendTextMessage(MESSAGE_*, "text")
  - fmt::format("text {}", var)
  - std::string msg = "text"
  - #define MSG_* "text"
- Generowanie kluczy: cpp.filename.line_number lub cpp.filename.function.msg_N
- Tworzenie pliku mapowania: cpp_strings_map.json
- NIE modyfikowanie kodu C++ automatycznie (tylko raport)
```

**Wyjście**:
```json
{
  "cpp.game.player.sendTextMessage_line_123": {
    "original": "You have been killed by %s",
    "file": "src/game/game.cpp",
    "line": 123,
    "context": "player death message"
  }
}
```

---

### 2.2 Parser PHP dla html_copy/

**Cel**: Ekstrakcja stringów z kodu PHP

**Skrypt**: `i18n_php_parser.sh`

```
Koncepcja:
- Skanowanie plików .php
- Wykrywanie wzorców:
  - echo "text"
  - print "text"
  - $msg = "text"
  - define('CONST', 'text')
  - $_['key'] = 'text'
- Ignorowanie:
  - SQL queries
  - Ścieżki plików
  - Zmienne techniczne
- Generowanie: php.filename.msg_N
```

---

### 2.3 Parser HTML/Smarty/Twig

**Cel**: Ekstrakcja stringów z szablonów

**Skrypt**: `i18n_template_parser.sh`

```
Koncepcja:
- Skanowanie .html, .tpl, .twig
- Wykrywanie:
  - Tekst między tagami HTML
  - Atrybuty: title="", alt="", placeholder=""
  - Tekst w JavaScript inline
- Ignorowanie:
  - Tagi techniczne
  - Zmienne szablonów
  - Komentarze
```

---

### 2.4 Parser XML/OTBM

**Cel**: Ekstrakcja z plików konfiguracyjnych

**Skrypt**: `i18n_xml_parser.sh`

```
Koncepcja:
- Skanowanie data/XML/*.xml
- Wykrywanie atrybutów z tekstem:
  - name="..."
  - description="..."
  - text="..."
- Mapowanie do kluczy: xml.items.item_1234.name
```

---

### 2.5 Uniwersalny silnik parserów

**Cel**: Jeden interfejs dla wszystkich parserów

**Skrypt**: `i18n_universal_parser.sh`

```
Koncepcja:
- Konfiguracja w YAML/JSON:
  parsers:
    lua:
      extensions: [.lua]
      patterns:
        - regex: 'sendTextMessage\([^,]+,\s*"([^"]+)"'
          key_template: "{category}.{filename}.msg_{n}"
    cpp:
      extensions: [.cpp, .hpp]
      patterns: [...]
- Dynamiczne ładowanie reguł
- Łatwe dodawanie nowych typów plików
```

---

## 🌍 Faza 3: System tłumaczeń

### 3.1 Auto-tłumaczenie przez API

**Cel**: Automatyczne tłumaczenie na 53 języki

**Skrypt**: `i18n_auto_translator.sh`

```
Koncepcja:
- Integracja z API tłumaczeń:
  - Google Translate API (płatne, wysokiej jakości)
  - DeepL API (płatne, bardzo wysokiej jakości)
  - LibreTranslate (darmowe, self-hosted)
  - Lingva Translate (darmowe)
- Kolejkowanie tłumaczeń (rate limiting)
- Cache tłumaczeń (nie tłumacz tego samego 2x)
- Priorytetyzacja języków (najpierw PL, DE, ES, PT)
- Fallback: jeśli API niedostępne, oznacz jako [NEEDS_TRANSLATION]
```

**Konfiguracja**:
```bash
# .env.translation
TRANSLATION_API=deepl
DEEPL_API_KEY=xxx
TRANSLATION_RATE_LIMIT=100  # requests per minute
PRIORITY_LANGUAGES=pl,de,es,pt,fr
```

---

### 3.2 Pamięć tłumaczeń (Translation Memory)

**Cel**: Wykorzystanie wcześniejszych tłumaczeń

**Skrypt**: `i18n_translation_memory.sh`

```
Koncepcja:
- Baza danych podobnych fraz
- Przy nowym stringu: szukaj podobnych (fuzzy match)
- Jeśli podobieństwo > 80%: zaproponuj istniejące tłumaczenie
- Uczenie się z poprawek użytkowników
- Export/import pamięci (TMX format)
```

**Struktura**:
```json
{
  "memory": [
    {
      "en": "You have gained %d experience",
      "pl": "Zdobyłeś %d doświadczenia",
      "similarity_hash": "abc123",
      "usage_count": 47
    }
  ]
}
```

---

### 3.3 Glosariusz terminów

**Cel**: Spójność tłumaczeń terminów gry

**Skrypt**: `i18n_glossary_manager.sh`

```
Koncepcja:
- Plik: i18n/glossary.json
- Definicje terminów gry:
  - "experience points" -> "punkty doświadczenia" (PL)
  - "mana" -> "mana" (nie tłumaczymy)
  - "hitpoints" -> "punkty życia"
- Wymuszanie użycia terminów z glosariusza
- Walidacja: czy tłumaczenie używa właściwych terminów
```

---

### 3.4 Walidator zmiennych i formatów

**Cel**: Sprawdzanie poprawności tłumaczeń

**Skrypt**: `i18n_validator.sh`

```
Koncepcja:
- Sprawdzanie czy tłumaczenie zawiera te same zmienne co oryginał:
  - %s, %d, %f (printf)
  - {0}, {1}, {name} (format strings)
  - {{variable}} (Lua)
- Sprawdzanie długości (czy nie za długie dla UI)
- Sprawdzanie znaków specjalnych
- Raport błędów walidacji
```

**Przykład błędu**:
```
ERROR: pl/npc.json key "npc.john.greeting"
  Original: "Hello %s, you have %d gold"
  Translation: "Witaj %s"
  Missing: %d (gold amount)
```

---

## ✅ Faza 4: Walidacja i testy

### 4.1 Test syntaktyczny Lua

**Cel**: Sprawdzenie czy zmodyfikowane pliki Lua są poprawne

**Skrypt**: `i18n_lua_syntax_test.sh`

```
Koncepcja:
- Po każdej modyfikacji pliku Lua:
  - luac -p filename.lua (sprawdzenie składni)
  - Jeśli błąd: rollback do backup, dodaj do excluded
- Batch testing wszystkich plików co noc
- Raport błędów składni
```

---

### 4.2 Test integracyjny serwera

**Cel**: Sprawdzenie czy serwer startuje z nowymi plikami

**Skrypt**: `i18n_server_test.sh`

```
Koncepcja:
- Uruchomienie serwera w trybie testowym
- Timeout 30 sekund
- Sprawdzenie czy:
  - Serwer się uruchomił
  - Załadował wszystkie NPC
  - Załadował wszystkie skrypty
  - Brak błędów w logach
- Jeśli błąd: identyfikacja problematycznego pliku
```

---

### 4.3 Testy jednostkowe funkcji i18n

**Cel**: Testowanie funkcji translate()

**Skrypt**: `i18n_unit_tests.lua`

```
Koncepcja:
- Testy w Lua:
  - Test ładowania plików JSON
  - Test funkcji translate(key, lang)
  - Test fallback do EN
  - Test zmiennych w stringach
  - Test brakujących kluczy
- Integracja z CI/CD
```

---

### 4.4 Regression testing

**Cel**: Wykrywanie regresji po zmianach

**Skrypt**: `i18n_regression_test.sh`

```
Koncepcja:
- Snapshot aktualnego stanu (baseline)
- Po zmianach: porównanie z baseline
- Wykrywanie:
  - Usunięte klucze (mogą być używane!)
  - Zmienione klucze (czy zamierzone?)
  - Nowe klucze bez tłumaczeń
- Raport różnic
```

---

## 🔧 Faza 5: Integracja z serwerem

### 5.1 Loader i18n dla serwera C++

**Cel**: Ładowanie tłumaczeń w serwerze

**Plik**: `src/i18n/i18n_loader.cpp`

```
Koncepcja:
- Klasa I18nLoader:
  - loadTranslations(lang) - ładuje JSON dla języka
  - translate(key, lang) - zwraca tłumaczenie
  - translateFormat(key, lang, args...) - z formatowaniem
- Cache w pamięci
- Hot-reload bez restartu serwera
- Fallback: key -> EN -> zwróć klucz
```

---

### 5.2 Konfiguracja języka gracza

**Cel**: Przechowywanie preferencji językowych

**Plik**: `src/i18n/player_language.cpp`

```
Koncepcja:
- Nowa kolumna w bazie: players.language VARCHAR(5)
- Komenda: /language pl
- Automatyczne wykrywanie z IP (GeoIP)
- Domyślny język serwera w config.lua
```

---

### 5.3 API REST dla tłumaczeń

**Cel**: Endpoint do pobierania tłumaczeń przez klienta

**Plik**: `src/server/network/i18n_endpoint.cpp`

```
Koncepcja:
- GET /api/i18n/{lang} - wszystkie tłumaczenia
- GET /api/i18n/{lang}/{category} - kategoria (npc, items)
- Cache HTTP (ETag, Last-Modified)
- Kompresja gzip
- Wersjonowanie (?v=1.2.3)
```

---

### 5.4 Moduł Lua i18n

**Cel**: Funkcje Lua do tłumaczeń

**Plik**: `data/libs/i18n.lua`

```
Koncepcja:
- I18n.translate(key, lang, params)
- I18n.translateForPlayer(player, key, params)
- I18n.setPlayerLanguage(player, lang)
- I18n.getAvailableLanguages()
- I18n.reload() - przeładowanie bez restartu
```

---

## 🖥️ Faza 6: Panel administracyjny

### 6.1 Web UI do zarządzania tłumaczeniami

**Cel**: Interfejs graficzny dla tłumaczy

**Katalog**: `html_copy/admin/i18n/`

```
Koncepcja:
- Dashboard:
  - Statystyki (ile przetłumaczono, ile brakuje)
  - Wykresy postępu
  - Ostatnie zmiany
- Lista kluczy:
  - Filtrowanie po kategorii, języku, statusie
  - Wyszukiwanie
  - Sortowanie
- Edytor tłumaczeń:
  - Oryginał (EN) obok tłumaczenia
  - Podpowiedzi z Translation Memory
  - Walidacja w czasie rzeczywistym
- Historia zmian:
  - Kto, kiedy, co zmienił
  - Możliwość przywrócenia poprzedniej wersji
```

---

### 6.2 System ról i uprawnień

**Cel**: Kontrola dostępu dla tłumaczy

```
Koncepcja:
Role:
- Admin: pełen dostęp
- Translator: edycja przypisanych języków
- Reviewer: zatwierdzanie tłumaczeń
- Viewer: tylko odczyt

Uprawnienia:
- Przypisanie języków do użytkownika
- Wymaganie review przed publikacją
- Blokowanie kluczy (system only)
```

---

### 6.3 Import/Export

**Cel**: Wymiana danych z zewnętrznymi narzędziami

**Skrypt**: `i18n_import_export.sh`

```
Koncepcja:
Formaty:
- JSON (natywny)
- CSV (dla Excel)
- XLIFF (standard lokalizacji)
- PO/POT (gettext)
- TMX (Translation Memory Exchange)

Funkcje:
- Export wybranych języków/kategorii
- Import z walidacją
- Merge z istniejącymi danymi
- Raport konfliktów
```

---

### 6.4 Powiadomienia i workflow

**Cel**: Automatyzacja procesu tłumaczenia

```
Koncepcja:
- Powiadomienia email/Discord:
  - Nowe klucze do tłumaczenia
  - Tłumaczenie wymaga review
  - Błędy walidacji
- Workflow:
  - DRAFT -> TRANSLATED -> REVIEWED -> PUBLISHED
  - Automatyczne przypisanie do tłumacza
  - Deadline tracking
```

---

## 🔄 Faza 7: Automatyzacja CI/CD

### 7.1 GitHub Actions dla i18n

**Cel**: Automatyczne testy i deployment

**Plik**: `.github/workflows/i18n.yml`

```yaml
Koncepcja:
Triggers:
- Push do i18n/
- Pull Request z zmianami tłumaczeń
- Scheduled (codziennie o 3:00)

Jobs:
1. validate:
   - Sprawdź składnię JSON
   - Sprawdź zmienne w tłumaczeniach
   - Sprawdź duplikaty kluczy

2. test:
   - Testy jednostkowe
   - Test ładowania na serwerze

3. stats:
   - Generowanie statystyk
   - Update README badges

4. deploy:
   - Sync do serwera produkcyjnego
   - Invalidacja cache
```

---

### 7.2 Pre-commit hooks

**Cel**: Walidacja przed commitem

**Plik**: `.pre-commit-config.yaml`

```
Koncepcja:
Hooks:
- json-lint: sprawdź składnię JSON
- i18n-validate: sprawdź zmienne
- i18n-no-empty: brak pustych tłumaczeń
- i18n-keys-sorted: klucze posortowane alfabetycznie
```

---

### 7.3 Automatyczne release notes

**Cel**: Dokumentacja zmian w tłumaczeniach

**Skrypt**: `i18n_release_notes.sh`

```
Koncepcja:
- Przy każdym release:
  - Lista nowych kluczy
  - Lista zmienionych tłumaczeń
  - Statystyki pokrycia na język
- Format Markdown
- Automatyczny commit do CHANGELOG_I18N.md
```

---

### 7.4 Monitoring i alerty

**Cel**: Monitorowanie systemu i18n

**Skrypt**: `i18n_monitoring.sh`

```
Koncepcja:
Metryki:
- Liczba kluczy (total, per language)
- Procent pokrycia
- Błędy walidacji
- Czas przetwarzania workera

Alerty (Discord/Telegram/Email):
- Worker nie działa > 5 min
- Błąd składni w JSON
- Pokrycie spadło poniżej 80%
- Nowe klucze bez tłumaczeń > 100
```

---

## 📜 Skrypty do stworzenia

### Priorytet: KRYTYCZNY (P0)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_incremental_worker.sh` | Przetwarzanie tylko zmienionych plików | 4h |
| `i18n_lua_syntax_test.sh` | Walidacja składni Lua po modyfikacji | 2h |
| `i18n_validator.sh` | Walidacja zmiennych w tłumaczeniach | 3h |
| `i18n_rollback.sh` | Przywracanie z backup przy błędzie | 2h |

### Priorytet: WYSOKI (P1)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_cpp_parser.sh` | Ekstrakcja stringów z C++ | 6h |
| `i18n_php_parser.sh` | Ekstrakcja stringów z PHP | 4h |
| `i18n_auto_translator.sh` | Integracja z API tłumaczeń | 8h |
| `i18n_translation_memory.sh` | Pamięć tłumaczeń | 6h |
| `i18n_glossary_manager.sh` | Zarządzanie glosariuszem | 3h |

### Priorytet: ŚREDNI (P2)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_parallel_worker.sh` | Wielowątkowe przetwarzanie | 5h |
| `i18n_checkpoint_manager.sh` | Checkpoint i resume | 3h |
| `i18n_logger.sh` | Zaawansowane logowanie | 2h |
| `i18n_server_test.sh` | Test integracyjny serwera | 4h |
| `i18n_import_export.sh` | Import/export formatów | 6h |

### Priorytet: NISKI (P3)

| Skrypt | Opis | Estymacja |
|--------|------|-----------|
| `i18n_template_parser.sh` | Parser HTML/Twig | 4h |
| `i18n_xml_parser.sh` | Parser XML | 3h |
| `i18n_universal_parser.sh` | Uniwersalny silnik | 8h |
| `i18n_regression_test.sh` | Testy regresji | 4h |
| `i18n_release_notes.sh` | Automatyczne release notes | 2h |
| `i18n_monitoring.sh` | System monitoringu | 4h |

---

## 📅 Priorytety i harmonogram

### Sprint 1 (Tydzień 1-2): Stabilizacja
- [ ] `i18n_incremental_worker.sh`
- [ ] `i18n_lua_syntax_test.sh`
- [ ] `i18n_validator.sh`
- [ ] `i18n_rollback.sh`
- [ ] Testy obecnego systemu

### Sprint 2 (Tydzień 3-4): Rozszerzenie parserów
- [ ] `i18n_cpp_parser.sh`
- [ ] `i18n_php_parser.sh`
- [ ] Dokumentacja wyekstrahowanych stringów C++/PHP
- [ ] Plan integracji z kodem źródłowym

### Sprint 3 (Tydzień 5-6): System tłumaczeń
- [ ] `i18n_auto_translator.sh`
- [ ] `i18n_translation_memory.sh`
- [ ] `i18n_glossary_manager.sh`
- [ ] Tłumaczenie PL, DE, ES, PT

### Sprint 4 (Tydzień 7-8): Integracja serwera
- [ ] `src/i18n/i18n_loader.cpp`
- [ ] `src/i18n/player_language.cpp`
- [ ] `data/libs/i18n.lua`
- [ ] Testy na serwerze testowym

### Sprint 5 (Tydzień 9-10): Panel administracyjny
- [ ] Web UI podstawowy
- [ ] System ról
- [ ] Import/Export

### Sprint 6 (Tydzień 11-12): CI/CD i monitoring
- [ ] GitHub Actions
- [ ] Pre-commit hooks
- [ ] Monitoring i alerty
- [ ] Dokumentacja końcowa

---

## 🎯 KPI (Key Performance Indicators)

| Metryka | Cel | Obecny |
|---------|-----|--------|
| Pokrycie EN | 100% | ~95% |
| Pokrycie PL | 100% | 0% |
| Pokrycie pozostałe | >50% | 0% |
| Czas przetwarzania 1 pliku | <100ms | ~200ms |
| Błędy składni po modyfikacji | 0% | ~2% |
| Uptime workera | 99.9% | ~95% |
| Czas do tłumaczenia nowego klucza | <24h | N/A |

---

## 📝 Notatki implementacyjne

### Technologie do rozważenia:
- **jq** - przetwarzanie JSON w bash
- **yq** - przetwarzanie YAML
- **GNU parallel** - równoległe przetwarzanie
- **SQLite** - lokalna baza dla Translation Memory
- **Redis** - cache dla API tłumaczeń
- **Docker** - izolacja środowiska testowego

### Potencjalne problemy:
1. **Rate limiting API tłumaczeń** - rozwiązanie: kolejkowanie, cache
2. **Konflikty przy równoległym zapisie JSON** - rozwiązanie: file locking
3. **Duże pliki JSON (>10MB)** - rozwiązanie: podział na mniejsze pliki
4. **Encoding UTF-8** - rozwiązanie: konsekwentne używanie UTF-8 wszędzie
5. **Zmienne w różnych formatach** - rozwiązanie: normalizacja do jednego formatu

### Backwards compatibility:
- Stare pliki Lua muszą działać bez i18n
- Fallback do hardcoded stringów
- Graceful degradation przy braku tłumaczenia

---

## 🔗 Powiązane dokumenty

- [I18N_STATUS.md](../I18N_STATUS.md) - Aktualny status
- [i18n_full_documentation.md](../i18n_full_documentation.md) - Pełna dokumentacja
- [I18N_CHECKLIST_SERVER.md](./I18N_CHECKLIST_SERVER.md) - Checklist wdrożenia
- [I18N_PL_ROADMAP.md](./I18N_PL_ROADMAP.md) - Plan tłumaczenia PL

---

*Dokument będzie aktualizowany wraz z postępem prac.*

**Ostatnia aktualizacja**: 2025-12-08
