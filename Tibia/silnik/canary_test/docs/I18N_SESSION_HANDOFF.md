# 🔄 I18N Session Handoff - Stan projektu

> **Data**: 2025-12-10 ~14:15  
> **Sesja**: Zakończona migracja greet/farewell + naprawa krytycznego buga  
> **Dla nowej sesji**: Przeczytaj ten plik żeby kontynuować

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

## 🎯 CO ROBIĆ DALEJ (PRIORYTETY)

### 🔴 Priorytet 1: voices (WYMAGA C++)
**Problem**: `npcConfig.voices` to broadcast - tekst wysyłany do wszystkich graczy jednocześnie.

**Co trzeba zrobić:**
1. Zmodyfikować C++ `voiceBlock_t` o pole `i18nKey`
2. Zmodyfikować `npc.cpp` żeby wysyłać tekst per-player
3. Zmodyfikować `register_npc_type.lua` żeby przekazywać i18nKey
4. Dodać transformację voices do workera

**Szczegóły**: Zobacz `docs/I18N_DEVELOPMENT_ROADMAP.md` sekcja "voices"

### 🟡 Priorytet 2: npcHandler:say({...}) z tablicami
**Problem**: Niektóre NPC używają tablic tekstów:
```lua
npcHandler:say({
    "Line 1",
    "Line 2", 
    "Line 3"
}, npc, creature)
```

**Rozwiązanie**: Trzeba rozszerzyć worker o detekcję i transformację tablic.

### 🟢 Priorytet 3: Automatyczne tłumaczenia
**Problem**: Tryb TRANSLATION wymaga interaktywnego terminala.

**Rozwiązanie**: Dodać tryb `TRANSLATION_AUTO` z API tłumaczeniowym.

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
