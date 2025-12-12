# 🔄 I18N Session Handoff - Stan projektu

> **Data**: 2025-12-12 (aktualizacja)  
> **Sesja**: Decyzja architekturalna - protokół klient-serwer zamiast server-side translation  
> **Dla nowej sesji**: Przeczytaj ten plik żeby kontynuować

---

## 🔴 WAŻNA ZMIANA ARCHITEKTURALNA (2025-12-12)

### Poprzednie podejście (PORZUCONE):
- Server-side translation: serwer tłumaczy teksty i wysyła przetłumaczone
- Wymaga kompilacji serwera z nowymi funkcjami C++
- Problem z mutex contention przy 200 graczy × 50 języków

### Nowe podejście (AKTUALNE):
**Serwer wysyła klucze i18n → Klient tłumaczy lokalnie**

#### Dlaczego lepsze:
| Aspekt | Server-side | Client-side (WYBRANE) |
|--------|-------------|----------------------|
| Obciążenie serwera | ❌ Wysokie (tłumaczenie per-request) | ✅ Minimalne (tylko klucze) |
| Bandwidth | ❌ Dłuższe teksty | ✅ Krótkie klucze |
| Kompilacja serwera | ❌ Wymagana | ✅ Tylko protokół |
| Klient (OTClient) | Bez zmian | ⚠️ Wymaga modyfikacji |
| Pamięć | ❌ Cache per-locale na serwerze | ✅ Słownik tylko na kliencie |

#### Pliki do modyfikacji:

**SERWER (canary_test):**
- `src/server/network/protocol/protocolgame.cpp` - wysyłanie kluczy zamiast tekstów
- `src/server/network/protocol/protocolgame.hpp` - nowe metody/opcodes

**KLIENT (testyy/OTClient):**
- `testyy/src/client/protocolgame.cpp` - parsowanie kluczy
- `testyy/data/locales/*.lua` - słowniki tłumaczeń (już istnieją!)
- `testyy/modules/corelib/keyboard.lua` - funkcja `tr()` (już istnieje!)

#### Plan implementacji:
1. **Etap 1**: Rozszerzyć pakiety tekstowe o pole `i18nKey` (opcjonalne)
2. **Etap 2**: Klient sprawdza czy jest `i18nKey` → jeśli tak, wywołuje `tr(key)`
3. **Etap 3**: Fallback: jeśli brak klucza w słowniku → wyświetl oryginalny tekst

---

## 📊 AKTUALNY STAN (po tej sesji)

### Statystyki kluczy:
| Plik JSON | Klucze | Opis |
|-----------|--------|------|
| `i18n/en/npc.json` | **4252** | Główna baza tekstów NPC |
| `i18n/pl/npc.json` | **4252** | Polski (placeholder [PL]) |
| `i18n/de/npc.json` | **4252** | Niemiecki (placeholder [DE]) |

### Zmigrowane wzorce:
| Wzorzec | Status | Plików | Kluczy |
|---------|--------|--------|--------|
| `StdModule.say` z `text = "..."` | ✅ **100%** | 297/297 | ~3800 |
| `npcHandler:say("...", npc, creature)` | ✅ **100%** | ~150 | ~350 |
| `addGreetKeyword` | ✅ **100%** | 43/43 | 39 |
| `addFarewellKeyword` | ✅ **100%** | 43/43 | 39 |
| `voices = {{ text = "..." }}` | ❌ **0%** | ~300+ | ~500+ |
| `npcHandler:say({...})` tablice | ❌ **0%** | ~50 | ~200 |

---

## 🛠️ CO ZOSTAŁO ZROBIONE W TEJ SESJI

### 1. ✅ Naprawiono KRYTYCZNY BUG w workerze
**Problem**: W `stage_5` (EXTRACTION) przy błędzie odczytu JSON:
```python
except:
    data = {}  # ← KASOWAŁO 4000+ kluczy!
```

**Fix** (linia ~950 w `i18n_worker_simple.sh`):
```python
except Exception as e:
    print(f"BŁĄD KRYTYCZNY: Nie można wczytać {json_file}: {e}")
    exit(1)  # ← Teraz przerywa zamiast nadpisywać
```

### 2. ✅ Przywrócono npc.json po korupcji
- Plik był skasowany z **4177 kluczy** do **4 kluczy**
- Odzyskano z `git cat-file -p <blob>` + uzupełniono z `i18n/pl/npc.json`

### 3. ✅ Zakończono migrację addGreetKeyword/addFarewellKeyword
- **78 nowych kluczy** (greet_N, farewell_N)
- Naprawiono regex dla przypadków z callbackiem:
  ```lua
  -- Ten format teraz działa:
  addGreetKeyword({ "hi" }, { text = "Hello" }, function(player)
  ```

### 4. ✅ Naprawiono pattern regex dla greet/farewell
**Stary pattern** (nie łapał callbacków):
```python
pattern_greet = r'(addGreetKeyword\s*\(\{[^}]+\}\s*,\s*\{[^}]*?)(text\s*=\s*"([^"]+)")(\s*\})'
```

**Nowy pattern** (łapie wszystkie formaty):
```python
pattern_greet = r'(addGreetKeyword\s*\([^)]*?)(text\s*=\s*"([^"]+)")([^}]*?\})'
```

---

## 🎯 CO ROBIĆ DALEJ (PRIORYTETY) - ZAKTUALIZOWANE 2025-12-12

### 🔴 Priorytet 1: PROTOKÓŁ KLIENT-SERWER (NOWE!)

**Cel**: Wysyłanie kluczy i18n z serwera, tłumaczenie po stronie klienta.

**Kroki:**

#### Krok 1: Analiza istniejącego protokołu
- [ ] Przeanalizować `src/server/network/protocol/protocolgame.cpp` - jak działa `sendTextMessage()`
- [ ] Przeanalizować `testyy/src/client/protocolgame.cpp` - jak działa `parseTextMessage()`
- [ ] Zidentyfikować format pakietów tekstowych

#### Krok 2: Modyfikacja serwera
- [ ] Rozszerzyć `sendTextMessage()` o opcjonalny parametr `i18nKey`
- [ ] Dodać nową metodę `sendLocalizedTextMessage()` która wysyła klucz
- [ ] Zachować kompatybilność wsteczną (klient bez i18n nadal działa)

#### Krok 3: Modyfikacja klienta (testyy)
- [ ] Rozszerzyć `parseTextMessage()` o odczyt klucza i18n
- [ ] Jeśli jest klucz → wywołać `tr(key)` z `modules/corelib/keyboard.lua`
- [ ] Jeśli brak tłumaczenia → fallback do oryginalnego tekstu

#### Krok 4: Słowniki na kliencie
- [ ] Przenieść klucze z `i18n/en/*.json` (serwer) do `testyy/data/locales/` (klient)
- [ ] Format klienta: `tr "key" "translation"` lub Lua tables

### 🟡 Priorytet 2: voices (WYMAGA C++) - ODŁOŻONE
**Powód odłożenia**: Najpierw implementujemy protokół - potem voices wykorzysta ten sam mechanizm.

### 🟢 Priorytet 3: Automatyczne tłumaczenia - ODŁOŻONE
**Powód odłożenia**: Zależy od działającego protokołu i18n.

---

## 📁 WAŻNE PLIKI

### Worker i narzędzia:
```
i18n_worker_simple.sh     # Główny worker v2.2 (8 etapów)
i18n_guardian.sh          # Auto-restart workera + git push
i18n_status_pusher.sh     # Pushuje status do git
```

### Pliki JSON z kluczami:
```
i18n/en/npc.json          # 4252 klucze EN (source of truth)
i18n/pl/npc.json          # 4252 klucze PL (placeholdery [PL])
i18n/de/npc.json          # 4252 klucze DE (placeholdery [DE])
```

### Biblioteki i18n Lua:
```
data-otservbr-global/lib/npc/i18n.lua    # NPC_LIB.i18n.npcSay()
data/npclib/npc_system/custom_modules.lua # GreetModule z i18nKey
data/npclib/npc_system/modules.lua        # StdModule.say z i18nKey
```

### Dokumentacja:
```
docs/I18N_DEVELOPMENT_ROADMAP.md   # Główny plan rozwoju
docs/I18N_SESSION_HANDOFF.md       # TEN PLIK - status sesji
I18N_STATUS.md                     # Auto-generowany dashboard
```

---

## 🚀 JAK URUCHOMIĆ WORKERA

### Tryb ciągły (migracja + tłumaczenia):
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
./i18n_worker_simple.sh --continuous 10 5
# 10 = batch size, 5 = delay między batchami
```

### Jeden plik:
```bash
./i18n_worker_simple.sh --file data-otservbr-global/npc/nazwa.lua
```

### Status:
```bash
./i18n_worker_simple.sh --status
```

### Guardian (auto-restart + push):
```bash
./i18n_guardian.sh
```

---

## ⚠️ ZNANE PROBLEMY

1. **Zombie procesy** - Stare procesy workera pozostają jako `<defunct>` (kosmetyczne)
2. **Tryb TRANSLATION wymaga terminala** - Nie działa w tle
3. **voices wymaga C++** - Broadcast nie może być przetłumaczony per-player bez modyfikacji silnika

---

## 📝 KONTEKST DLA AI

Jeśli otwierasz nową sesję i chcesz kontynuować:

1. **Przeczytaj ten plik** + `docs/I18N_DEVELOPMENT_ROADMAP.md`
2. **Sprawdź statystyki**: `./i18n_worker_simple.sh --status`
3. **Główne zadania**:
   - voices wymaga modyfikacji C++ (pliki w `src/`)
   - npcHandler:say z tablicami wymaga rozszerzenia stage_4
   - Automatyczne tłumaczenia wymagają integracji z API

**Workspace**: `/home/ptaku/serweryt/Tibia/silnik/canary_test`

**Git**: Commity są automatyczne przez workera i guardiana
