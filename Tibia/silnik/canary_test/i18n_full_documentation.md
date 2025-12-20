# 🌍 I18N Full Documentation

Automatyczna dokumentacja wszystkich zmian internacjonalizacji.

**Worker:** v4.0 - Full Internationalization  
**Języki:** 53  
**Zakres:** Lua, C++, PHP, HTML, JS, XML, JSON

---

# 🔧 CHANGELOG POPRAWEK WORKERA

## [2025-12-17 06:00-07:00] Naprawa dynamicznych tekstów i przechodzenia między kategoriami

### 📋 Podsumowanie sesji nocnej

Sesja naprawcza workera skupiona na:
1. Oznaczaniu plików z dynamicznymi tekstami (konkatenacja Lua) do ręcznej edycji
2. Naprawie dispatchera żeby pomijał pliki z konkatenacją w liczniku
3. Naprawie błędów parsowania (`integer expression expected`)
4. Weryfikacji przechodzenia między kategoriami

---

### 🐛 PROBLEM 1: Pliki z dynamicznymi tekstami (konkatenacja Lua)

**Opis problemu:**
- Pliki jak `a_dead_bureaucrat1.lua` mają teksty z konkatenacją: `"Hello " .. player:getName()`
- Worker nie może automatycznie zmigrować takich tekstów (wymagają interpolacji)
- Dispatcher pokazywał 52 pliki NPC do pracy, ale tylko ~14 było realnie migrowalne
- 135 plików NPC ma konkatenację ` .. ` i wymaga ręcznej edycji

**Przykład problematycznego kodu:**
```lua
npcHandler:setMessage(MESSAGE_GREET, "Hello " .. creature:getName() .. "! How can I help?")
```

**Rozwiązanie:**

1. **Dodano wykrywanie konkatenacji w dispatcherze** (~linia 6563):
```python
# Pomiń pliki z konkatenacją Lua (wymagają ręcznej edycji)
if ' .. ' in content:
    continue
```

2. **Dodano plik `i18n_manual_review.txt`** (~linia 2466-2471):
```bash
# Sprawdź czy plik ma dynamiczne teksty (konkatenacja Lua)
has_dynamic=$(grep -cE ' \.\. ' "$file" 2>/dev/null | head -1 | tr -d '\n\r ' || echo "0")
[[ ! "$has_dynamic" =~ ^[0-9]+$ ]] && has_dynamic=0
if [ "$has_dynamic" -gt 0 ]; then
    echo "$file" >> "$WORK_DIR/i18n_manual_review.txt"
    log "${CYAN}📝 Plik wymaga ręcznej edycji (dynamiczne teksty)${NC}"
fi
```

**Wynik:**
- Dispatcher pokazuje teraz 14 plików NPC zamiast 52 (realna liczba)
- Pliki z konkatenacją są dodawane do `i18n_manual_review.txt`
- Pattern ` .. ` (ze spacjami) nie matchuje `...` (wielokropek w tekście)

---

### 🐛 PROBLEM 2: Błąd parsowania `integer expression expected`

**Opis problemu:**
- Błąd: `i18n_worker_simple.sh: line 2466: [: 0\n0: integer expression expected`
- Zmienna `has_dynamic` z `grep -c` czasem zawierała newline lub niespodziewane znaki
- Również błąd był z `$WORKSPACE` który nie był zdefiniowany (powinno być `$WORK_DIR`)

**Rozwiązanie:**

1. **Sanityzacja wartości** (~linia 2466-2468):
```bash
local has_dynamic
has_dynamic=$(grep -cE ' \.\. ' "$file" 2>/dev/null | head -1 | tr -d '\n\r ' || echo "0")
[[ ! "$has_dynamic" =~ ^[0-9]+$ ]] && has_dynamic=0
```

2. **Poprawiono zmienną ścieżki**:
```bash
# PRZED: echo "$file" >> "$WORKSPACE/i18n_manual_review.txt"  # WORKSPACE undefined!
# PO:    echo "$file" >> "$WORK_DIR/i18n_manual_review.txt"
```

---

### 🐛 PROBLEM 3: Worker zawsze przetwarzał tylko NPC

**Opis problemu:**
- Użytkownik zauważył że worker zawsze pokazuje kategorię NPC
- Worker nie przechodził do innych kategorii (monsters, quests, scripts)

**Wyjaśnienie:**
- NPC ma priorytet 1 w dispatcherze - musi być ukończone przed innymi
- Dispatcher pokazywał 52 pliki (zawyżona liczba przez pliki z konkatenacją)
- Po naprawie dispatchera, NPC ma tylko 14 plików i worker szybciej przechodzi dalej

**Wynik po naprawie:**
Worker teraz przechodzi przez kategorie w kolejności priorytetów:
- NPC (14 plików) → world (11) → spells (0) → talkactions (0) → movements (4) → ...
- Kategorie z 0 przetworzonych są automatycznie pomijane na 5-10 minut

---

### 🐛 PROBLEM 4: MESSAGE_SENDTRADE nieobsługiwany

**Opis problemu:**
- 91 plików używało `npcHandler:setMessage(MESSAGE_SENDTRADE, "...")`
- Ten wzorzec nie był obsługiwany przez transformację

**Rozwiązanie:**
- Dodano MESSAGE_SENDTRADE do TRANSFORMACJA 5 (~linia 2350)
- Dodano ekstrakcję do EKSTRAKCJA 5 (~linia 2590)
- Dodano wzorzec do detekcji w dispatcherze (~linia 6612)

**Uwaga:** Większość plików z MESSAGE_SENDTRADE ma również konkatenację,
więc trafią do `i18n_manual_review.txt` zamiast automatycznej migracji.

---

### 📊 Statystyki zmian

| Metryka | Przed | Po |
|---------|-------|-----|
| NPC pliki wykryte przez dispatcher | 52 | 14 |
| Pliki z konkatenacją (manual review) | 0 | 135 |
| Kategorie przetwarzane | tylko NPC | NPC→world→spells→... |
| Błędy parsowania | tak | nie |

---

### 📁 Zmodyfikowane pliki

1. **i18n_worker_simple.sh**:
   - Linia ~2463-2472: Dodano wykrywanie dynamicznych tekstów i zapis do manual_review
   - Linia ~6563: Pomijanie plików z konkatenacją w dispatcherze NPC

2. **i18n_npc_detector.py**: (już wcześniej)
   - Funkcja `has_concatenation()` - zwraca False dla plików z ` .. `

3. **Nowy plik: i18n_manual_review.txt**:
   - Lista plików wymagających ręcznej edycji (dynamiczne teksty)

---

## [2025-12-17] Wielka naprawa detekcji NPC i wsparcie setMessage

### 📋 Podsumowanie sesji

Sesja naprawcza workera `i18n_worker_simple.sh` skupiona na poprawie detekcji plików NPC wymagających migracji oraz dodaniu wsparcia dla nowego wzorca `setMessage()`.

**Przed naprawą:** Worker wykrywał ~19-20 plików do migracji  
**Po naprawie:** Worker wykrywa **633+ plików** do migracji  
**Nowe klucze dodane:** 50+ w pierwszych minutach pracy

---

### 🐛 PROBLEM 1: Brak wsparcia dla setMessage()

**Opis problemu:**
- 621 plików NPC używało `npcHandler:setMessage(MESSAGE_GREET, "...")`, `MESSAGE_FAREWELL`, `MESSAGE_WALKAWAY`
- Worker całkowicie ignorował ten wzorzec - żaden z tych plików nie był migrowany

**Przykład nieobsługiwanego kodu:**
```lua
npcHandler:setMessage(MESSAGE_GREET, "GET ME OUT OF HERE! NOW!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "...")
```

**Rozwiązanie:**

1. **Dodano TRANSFORMACJA 5** (~linia 2315-2370):
```python
# TRANSFORMACJA 5: npcHandler:setMessage(MESSAGE_GREET/FAREWELL, "...") → NPC_LIB.i18n.setLocalizedMessage()
pattern_setmsg_greet = r'npcHandler:setMessage\s*\(\s*MESSAGE_GREET\s*,\s*"([^"]+)"\s*\)'

def safe_replace_setmsg_greet(match):
    text = match.group(1)
    if '..' in text or '\\' in text:  # Pomiń konkatenacje
        return match.group(0)
    setmsg_greet_counter[0] += 1
    key = f"npc.{safe_name}.greet_msg_{setmsg_greet_counter[0]}"
    return f'NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "{key}")'
```

2. **Dodano EKSTRAKCJA 5** (~linia 2551-2600):
   - Ekstrakcja tekstów z setMessage do `i18n/en/npc.json`
   - Klucze: `npc.{name}.greet_msg_N`, `farewell_msg_N`, `walkaway_msg_N`

**Wynik transformacji:**
```lua
-- PRZED:
npcHandler:setMessage(MESSAGE_GREET, "GET ME OUT OF HERE! NOW!")

-- PO:
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_bearded_woman.greet_msg_1")
```

---

### 🐛 PROBLEM 2: Wadliwa logika detekcji per-plik zamiast per-linia

**Opis problemu:**
- Stara logika: `if 'i18nKey' not in content` - sprawdzała CAŁY plik
- Pliki częściowo zmigrowane (np. 8 z i18nKey, 3 bez) były pomijane
- Jeśli plik miał CHOĆBY JEDEN `i18nKey`, wszystkie pozostałe wzorce były ignorowane

**Przykład problemu:**
```lua
-- Plik ma mieszane wzorce:
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.test.stdmod_1" })  -- OK
keywordHandler:addKeyword({ "pirate" }, StdModule.say, { npcHandler = npcHandler, text = { "In a just world..." } })  -- IGNOROWANY!
```

**Rozwiązanie:**

Zmieniono detekcję na sprawdzanie **per-linię** w trzech miejscach:

1. **count_files_needing_work()** (~linia 6467-6495):
```python
# StdModule.say z text= BEZ i18nKey W TEJ SAMEJ LINII
lines = content.split('\n')
for line in lines:
    if 'StdModule.say' in line and 'text' in line and 'i18nKey' not in line:
        if re.search(r'text\s*=\s*["{]', line):
            needs = True
            break
```

2. **stage_2 (ANALYSIS)** (~linia 2015-2030):
```bash
# Sprawdź per-linię czy jest StdModule.say z text= bez i18nKey
local stdmod_needs=$(python3 -c "
import re
with open('$file', 'r', errors='ignore') as f:
    lines = f.readlines()
for line in lines:
    if 'StdModule.say' in line and 'text' in line and 'i18nKey' not in line:
        if re.search(r'text\s*=\s*[\"{]', line):
            print('true')
            exit(0)
print('false')
" 2>/dev/null || echo "false")
```

3. **Dashboard** (~linia 6955-6990):
   - Ta sama logika per-linię dla spójnego raportowania

---

### 🐛 PROBLEM 3: Wadliwa detekcja voices - sprawdzanie całego pliku

**Opis problemu:**
- Stara logika: `if 'text = "' in content and 'i18nKey' not in content`
- Nie uwzględniała że `i18nKey` może być w INNEJ sekcji pliku (np. w keywords)
- 124 pliki z voices były pomijane mimo że sekcja voices nie była zmigrowana

**Rozwiązanie:**

Sprawdzanie **per-sekcję** (tylko blok voices):

```python
# npcConfig.voices z text bez i18nKey W TEJ SEKCJI
if re.search(r'npcConfig\.voices\s*=\s*\{', content):
    voices_match = re.search(
        r'npcConfig\.voices\s*=\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}', 
        content, re.DOTALL
    )
    if voices_match:
        voices_block = voices_match.group(1)
        if re.search(r'text\s*=\s*"', voices_block) and 'i18nKey' not in voices_block:
            needs = True
```

---

### 🐛 PROBLEM 4: Niespójność między detekcją a batch processingiem

**Opis problemu:**
- `count_files_needing_work()` używało nowej logiki (Python)
- Batch processing NPC (`case npc)`) używało starej logiki (bash grep)
- Worker wykrywał 633 plików, ale przetwarzał 0!

**Lokalizacja w kodzie:** ~linia 7433-7470

**Stara logika (bash):**
```bash
if grep -q "StdModule\.say" "$f" 2>/dev/null; then
    if ! grep -q "i18nKey" "$f" 2>/dev/null; then
        if grep -q 'text = "' "$f" 2>/dev/null; then
            NEEDS_WORK=true
        fi
    fi
fi
```

**Nowa logika (Python heredoc):**
```bash
NEEDS_WORK=$(python3 << NEEDSWORK
import re
with open("$f", "r", errors="ignore") as fp:
    content = fp.read()
needs = False

# 1. StdModule.say z text= BEZ i18nKey W TEJ SAMEJ LINII
lines = content.split('\n')
for line in lines:
    if 'StdModule.say' in line and 'text' in line and 'i18nKey' not in line:
        if re.search(r'text\s*=\s*["{]', line):
            needs = True
            break

# 2. npcHandler:say( bez NPC_LIB
if 'npcHandler:say(' in content and 'NPC_LIB.i18n.npcSay' not in content:
    needs = True

# 3. voices per-sekcja
if re.search(r'npcConfig\.voices\s*=\s*\{', content):
    voices_match = re.search(r'npcConfig\.voices\s*=\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}', content, re.DOTALL)
    if voices_match:
        voices_block = voices_match.group(1)
        if re.search(r'text\s*=\s*"', voices_block) and 'i18nKey' not in voices_block:
            needs = True

# 4. setMessage bez NPC_LIB
if re.search(r'setMessage\s*\(\s*MESSAGE_(GREET|FAREWELL|WALKAWAY)\s*,\s*"[^"]+"', content):
    if 'NPC_LIB.i18n.setLocalizedMessage' not in content:
        needs = True

print("true" if needs else "false")
NEEDSWORK
)
```

---

### 🐛 PROBLEM 5: Brakujące pole w output transformacji

**Opis problemu:**
- Transformacja wypisywała 6 pól: `total|stdmod|npcsay|greetfare|voices|setmsg`
- Fallback (brak zmian) wypisywał tylko 5: `0|0|0|0|0`
- Parser bash gubił się przy parsowaniu

**Rozwiązanie:**
```python
# PRZED:
else:
    print("0|0|0|0|0")

# PO:
else:
    print("0|0|0|0|0|0")
```

Oraz aktualizacja parsera bash:
```bash
local setmsg_t=$(echo "$transformed" | cut -d'|' -f6)
[ -z "$setmsg_t" ] && setmsg_t=0
log "... setMsg=$setmsg_t, Total=$total_t"
```

---

### 🐛 PROBLEM 6: stage_2 (ANALYSIS) nie wykrywała setMessage

**Opis problemu:**
- Etap ANALYSIS decyduje czy plik `needs=true/false`
- Brak detekcji setMessage powodował `needs=false` dla 621 plików!

**Rozwiązanie - dodano na końcu stage_2():**
```bash
# setMessage(MESSAGE_GREET/FAREWELL/WALKAWAY, "...") bez NPC_LIB.i18n.setLocalizedMessage
if grep -qE 'setMessage\s*\(\s*MESSAGE_(GREET|FAREWELL|WALKAWAY)' "$file" 2>/dev/null; then
    if ! grep -q "NPC_LIB.i18n.setLocalizedMessage" "$file" 2>/dev/null; then
        if grep -qE 'setMessage\s*\(\s*MESSAGE_(GREET|FAREWELL|WALKAWAY)\s*,\s*"[^"]+"' "$file" 2>/dev/null; then
            needs="true"
        fi
    fi
fi
```

---

### 📁 PLIKI ZMODYFIKOWANE

| Plik | Linie | Opis zmian |
|------|-------|------------|
| `i18n_worker_simple.sh` | ~2015-2030 | stage_2: per-liniowa detekcja StdModule |
| `i18n_worker_simple.sh` | ~2035-2065 | stage_2: per-sekcyjna detekcja voices + setMessage |
| `i18n_worker_simple.sh` | ~2315-2370 | TRANSFORMACJA 5: setMessage |
| `i18n_worker_simple.sh` | ~2380-2382 | Output format fix (6 pól) |
| `i18n_worker_simple.sh` | ~2390-2405 | Parser setmsg_t |
| `i18n_worker_simple.sh` | ~2551-2600 | EKSTRAKCJA 5: setMessage |
| `i18n_worker_simple.sh` | ~6467-6500 | count_files_needing_work: pełna logika |
| `i18n_worker_simple.sh` | ~6955-6990 | Dashboard: spójna logika |
| `i18n_worker_simple.sh` | ~7433-7470 | Batch NPC: Python zamiast bash |

---

### ✅ WYNIKI PO NAPRAWIE

| Metryka | Przed | Po | Zmiana |
|---------|-------|-----|--------|
| Pliki do migracji | 19 | 633 | +614 |
| Detekcja setMessage | ❌ | ✅ | Nowe |
| Detekcja per-linia | ❌ | ✅ | Poprawione |
| Detekcja voices | Częściowa | ✅ | Poprawione |
| Spójność detekcji | ❌ | ✅ | 4 miejsca zsynchronizowane |

---

### 📝 NOTATKI DLA PRZYSZŁYCH NAPRAW

1. **Zawsze synchronizuj logikę detekcji w 4 miejscach:**
   - `count_files_needing_work()` - dispatcher
   - `stage_2()` - ANALYSIS
   - Batch processing (`case npc)`)
   - Dashboard statistics

2. **Per-linia vs per-plik:**
   - Pliki mogą być częściowo zmigrowane
   - NIGDY nie używaj `if 'x' not in content` dla detekcji migracji
   - Zawsze sprawdzaj kontekst (ta sama linia, ta sama sekcja)

3. **Nowe wzorce:**
   - Dodając nowy wzorzec (jak setMessage), zaktualizuj WSZYSTKIE 4 miejsca
   - Dodaj TRANSFORMACJĘ + EKSTRAKCJĘ + OUTPUT FIELD

4. **Testowanie:**
   - `bash i18n_worker_simple.sh --file <plik>` - test pojedynczego pliku
   - `bash i18n_worker_simple.sh --auto 5` - test batch 5 plików
   - `bash i18n_worker_simple.sh --status` - dashboard

5. **State management:**
   - `skip_until` - timestamp kiedy kategoria może być ponownie sprawdzona
   - `last_processed` - info o ostatnim przetwarzaniu (count, timestamp)
   - `consecutive_zeros` - ile razy z rzędu kategoria dała 0 wyników
   - Reset: usuń kategorię z WSZYSTKICH trzech słowników!

---

### 🔍 WZORCE OBSŁUGIWANE PO NAPRAWIE

| Wzorzec | Transformacja | Ekstrakcja |
|---------|---------------|------------|
| `StdModule.say, { text = "..." }` | → `i18nKey = "..."` | ✅ |
| `StdModule.say, { text = { "...", "..." } }` | → `i18nKey = "..."` | ✅ |
| `npcHandler:say("...")` | → `NPC_LIB.i18n.npcSay()` | ✅ |
| `addGreetKeyword(..., text = "...")` | → `i18nKey = "..."` | ✅ |
| `addFarewellKeyword(..., text = "...")` | → `i18nKey = "..."` | ✅ |
| `npcConfig.voices = { { text = "..." } }` | → `{ i18nKey = "..." }` | ✅ |
| `npcHandler:setMessage(MESSAGE_GREET, "...")` | → `NPC_LIB.i18n.setLocalizedMessage()` | ✅ **NOWE** |
| `npcHandler:setMessage(MESSAGE_FAREWELL, "...")` | → `NPC_LIB.i18n.setLocalizedMessage()` | ✅ **NOWE** |
| `npcHandler:setMessage(MESSAGE_WALKAWAY, "...")` | → `NPC_LIB.i18n.setLocalizedMessage()` | ✅ **NOWE** |

### ⚠️ WZORCE CELOWO POMIJANE

| Wzorzec | Powód |
|---------|-------|
| `npcHandler:say("..." .. variable)` | Konkatenacja - wymaga ręcznej migracji |
| `setMessage(MESSAGE_SENDTRADE, ...)` | Zwykle z konkatenacją |
| Stringi z `\\` (escape sequences) | Mogą zawierać specjalne formatowanie |

---

## [2025-12-08 18:03:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_last_object.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:21] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_tar.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:21] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_crate.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:22] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_task_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:22] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_analyser.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_misguided.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_ice_death.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_check_oasis.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_begin_task.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_energy_fence.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:51] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_torch.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:53] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_ice.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:53] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_magnifier.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_document.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/movements_looktype.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:55] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/cults_of_tibia/actions_counter_agent.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:55] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_outlaw_camp/actions_the_outlaw_camp_quest.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:55] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_travelling_trader/actions_outlaw_camp_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:56] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/koshei_the_deathless_quest/action_bag.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:03:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/grimvale/actions_ancient_feud_entrances.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/grimvale/actions_closed_silvered_trap.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/grimvale/movements_strangely_glowing_mark.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/hero_of_rathleton/actions_reward.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/hero_of_rathleton/movements_fast_way.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:29] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/svargrond_arena/movements_arena_enter.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:30] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_postman_missions_quest/actions_waldos_posthorn.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:31] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/wrath_of_the_emperor/movements_boss_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/wrath_of_the_emperor/actions_mission12_just_rewards.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/wrath_of_the_emperor/actions_mission11_payback_time_lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:33] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_thieves_guild_quest/actions_climbing_vine.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/in_service_of_yalahar/actions_yalahar_machine_war_golems.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/in_service_of_yalahar/movements_yalahar_machine_war_golems.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/in_service_of_yalahar/actions_reward.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:04:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/in_service_of_yalahar/movements_quara_vortex.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/in_service_of_yalahar/actions_mechanism.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_primal_ordeal/creaturescripts_magma_bubble_death.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_lost_brother/movement-find-remains.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_ancient_tombs/actions_oasis_lever_door.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:02] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_ancient_tombs/actions_ruins_instruments.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_ancient_tombs/actions_dipthrah_signs_doors.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_spike_tasks/movements_spike_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_spike_tasks/movements_geomantic_charges.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/formogar_mine_hoist/movements_hoist.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_coruja.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_scissors.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_glasshoneyfun.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_tortoise.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_scissorsfun.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_cagekey.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_tumuloerro.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_lyre.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:05:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_augerfun.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_pickenchanted.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_basin.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_peelerfun.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_tumulo.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_peeler.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/kilmaresh_quest/actions_sangra.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_paradox_tower/movement_sacrifice_skulls.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/hunter_outfits_quest/action_all_hymn_piano_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:40] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/hunter_outfits_quest/action_music_sheet.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:43] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_reward.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:44] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_sparks_lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:46] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_cracklers_lever.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:47] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_devourer_access.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:49] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/movements_teleport_heart.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:52] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_final_lever.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:52] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/movements_vortex_crackler.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/heart_of_destruction/actions_charges_lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:06:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/children_of_the_revolution/actions_mission3_chest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/children_of_the_revolution/actions_zalamon_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_inquisition_quest/actions_ungreez_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_inquisition_quest/actions_rewards.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/rotten_blood_quest/movements_blood_entrance.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/rotten_blood_quest/actions_entrances.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:30] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/rotten_blood_quest/actions_sacrifice.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:30] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/rotten_blood_quest/creaturescripts_bosses_killed.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:30] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/oramond/actions_glooth_fairy_lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:31] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_cursed_crystal/actions_MedusaOil.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_cursed_crystal/actions_Ointment.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_cursed_crystal/movements_StepIn_CursedCrystal.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_cursed_crystal/actions_Misc.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_tainted_soul/actions_star_herb.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_annihilator/lever.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:07:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_annihilator/door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_gnomish_chest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_gnome_chart.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_gnomish_pesticide.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/movements_boss_entrance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:04] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/movements_warzone_entrance.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:31] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/movements_gnome_ordnance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_gnome_items.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:33] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_gnome_trignometre.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:39] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/actions_using_crystals.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:40] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dangerous_depth/movements_energy_entrance.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/adventures_of_galthen/actions_iksupan_entrance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/adventures_of_galthen/actions_yselda_entrances.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/adventures_of_galthen/actions_yselda_shortcut.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/adventures_of_galthen/actions_idol_of_tukh.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:08:43] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/chayenne_realm/actions_reward.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:16] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/chayenne_realm/movements_enter_realm.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:16] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/chayenne_realm/actions_lever.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:17] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_flower_puzzle_lever.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/creaturescripts_bosses_kill.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_statue.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_habitats_access.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_ice.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_reward.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:29] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_grass.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:09:29] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_teleportation_rod.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:04] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_venom.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:06] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_entrance.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:10] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_roshamuul.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:10] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_mysterious_scroll.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:11] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_seal.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_lever_third.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_zamulosh_teleport.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_bone_flute_wall.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_lever_first.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_dimension.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:51] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_lever_second.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:52] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_sacrifice.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_desert.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_tarbaz_notes.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:10:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_color_levers.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_corrupted.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:02] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_boots_of_homecoming.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:02] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_shulgrax_lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/movements_gate_of_deathstruction.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:07] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/ferumbras_ascension/actions_habitat_mushroom.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:40] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/a_pirates_tail/actions_cheesy_key.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/a_pirates_tail/actions_rascacoon_shortcut.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/a_pirates_tail/creaturescripts_ratmiral_death.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_first_dragon/actions_lair_entrance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:44] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_first_dragon/movements_last_teleport.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:46] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_first_dragon/actions_sacrifice_items.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:47] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_first_dragon/actions_rewards.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:48] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/creaturescripts_middle_spike_kill.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:49] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/creaturescripts_upper_spike_kill.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:11:50] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_spirit_shovel.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_nests.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:21] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_thermometer.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:22] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_ghost_detector.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:22] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_tuning_fork.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/creaturescripts_lower_spike_kill.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/spike_tasks/actions_fertilizer.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/movements_servant_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_fount.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_time_machine.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_secret_wall.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:56] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_lost_time.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_frozen_horror.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_old_desk.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:12:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_girl_picture.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:13:04] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_plant.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:13:06] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/actions_bird_cage.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:13:08] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/movements_entrance_teleport.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:13:08] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/movements_challenger.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:13:09] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/forgotten_knowledge/movements_teleport_tree.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission02_defence.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:15] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission09_rock_troll.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission05_web_terror.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission10_tomb_raiding.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission11_sweet_poison.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:30] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission12_into_fortress.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission06_run_like_wolf.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:34] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_rookie_guard/mission07_attack.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/grave_danger_quest/actions_custodian_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:14:38] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/demon_oak/actions_demon_oak_chest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:10] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/demon_oak/actions_demon_oak.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:10] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/demon_oak/movements_entrance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:11] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/threatened_dreams/action_poacher_book.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/threatened_dreams/movement_poacher_notes.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/threatened_dreams/action_whelp_fur.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/threatened_dreams/action_poacher_notes.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/threatened_dreams/event_raven_herb_bush.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:15] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/soulpit/soul_prism.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:16] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/soulpit/exalted_core.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/lions_rock/actions_lions_rock.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:53] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/lions_rock/movements_lions_rock.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:53] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dark_trails/movements_necrometer_tile_access.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dark_trails/actions_corpse.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:55] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/tinder_box_quest_chyllfroest/actions_reward.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:56] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/tinder_box_quest_chyllfroest/actions_ursagrodon.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:56] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/tinder_box_quest_chyllfroest/movements_prohibit_entry.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:57] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dreamers_challenge_quest/actions_documents.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_hidden_city_of_beregar/moviments_elevator.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:15:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_hidden_city_of_beregar/moviments_ore_wagon.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_hidden_city_of_beregar/actions_ore_wagon.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:35] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_explorer_society/actions_findings.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_explorer_society/movements_calassa.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_pits_of_inferno_quest/movements_pumin_teleport.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:43] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_djinn_war_quest/action_water_fountain.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:46] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/marapur/actions_boss_timira_fight.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:48] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_hunt_for_the_sea_serpent/movements_teleports.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:51] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_hunt_for_the_sea_serpent/actions_bait.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:52] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/edron_rope/movements_rope.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_ape_city/movements_mission9_the_deepest_catacomb_teleport.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:16:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/others/actions_calassa_comb_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:31] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/others/actions_holy_water.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/others/actions_steal_from_thieves.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:33] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/others/actions_deeper_banuta_shortcut.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:34] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/others/actions_gooey_mass.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:34] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/deeplings_worldchange/actions_statue.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:35] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/deeplings_worldchange/actions_coral.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:35] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/deeplings_worldchange/actions_questfirst.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/deeplings_worldchange/actions_crystal.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_statue.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:17:37] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_ashes.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:11] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_pyramids2.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_key1.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_scroll.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_caixa.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_candles.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_inscriptions.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_pyramids1.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_palanca.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_flask.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:14] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_key2.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:48] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_cape.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:49] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_hallowed.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:49] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_brain.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:49] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_sacrifice.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:50] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_tears.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:50] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_tincture.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:50] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/actions_chalk.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:51] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_gravedigger_of_drefia/movements_dormitory_teleport.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:52] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/roshamuul_quest/actions_chalk.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:18:54] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/roshamuul_quest/actions_gravel.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:27] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/roshamuul_quest/actions_bone.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/liquid_black/actions_notescoordinates.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:28] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/liquid_black/actions_seashell_key.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:29] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/feaster_of_souls/actions_entrances.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:31] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_brain_head.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:32] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/feaster_of_souls/actions_portal_pale_worm.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:35] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/hidden_threats/action-corym_works_doors.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_great_dragon_hunt_quest/actions_warrior_skeleton.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:37] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_great_dragon_hunt_quest/actions_treasure.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:19:37] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_new_frontier/action_outfit.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:12] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_new_frontier/movement_jail_exit.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_new_frontier/action_hidden_note.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:13] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_new_frontier/movement_minotaur_boss.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:15] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_new_frontier/action_arena.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:15] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dawnport/movements_legion_helmet.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:16] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dawnport/actions_vocation_reward.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:17] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/dawnport/actions_the_rare_herb.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/soul_war/action-reward_soul_war.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/soul_war/moveevent-teleport_entrance_reward.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/soul_war/moveevent-soul_war_entrances.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:55] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_oldLock.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:56] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_goldenIdol.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_containerRewards.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:20:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_magicalPaint.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_questDoors.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_strangeBucket.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:02] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_dreamcatcher_curse.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_rosebushUse.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_acidFishingRod.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_doorInvisible.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:36] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_sacrophagusUse.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:37] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_keyCheck.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:38] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_bookOnTable.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:38] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/actions_sunFruit.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_dream_courts_quest/movements_acessTeleports.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:41] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/object/wz789_entrance.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/object/golden_outfit_display.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:42] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/object/imbuement_shrine.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:45] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/system/quest_reward_common.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:21:45] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/rookgaard/rapier_quest.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:17] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/rookgaard/chest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/rookgaard/goblin_temple_quest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/tools/hammer.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/tools/lock_pick.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:20] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/rafzane_elevator.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:21] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/mechanical_fishing.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:22] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/fishing.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:23] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/kits.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:25] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/gems.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:26] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/music.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:22:59] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/special_firework_rocket.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:01] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/fluids.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:02] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/other/construction_kits.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/actions/dawnport/vocation_door.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:17] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/lib/register_actions.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/rookgaard/rook_village.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:18] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/rookgaard/level_bridge.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/oramond/seacrest.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:19] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/roshamuul/strange_vortex_tp.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:23:24] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/others/dawnport_vocation_trial.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/others/dawnport_tiles.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:03] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/teleport/gray_beach_vortex.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:04] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/teleport/gnomprona.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:05] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/teleport/roshamuul_carpet.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:05] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/teleport/schrodingers_island_teleport_lvl_999.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:06] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/movements/teleport/citizen.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:24:58] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/globalevents/others/check_mount.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:25:00] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/creaturescripts/customs/reward_exercise.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:25:04] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/creaturescripts/customs/freequests.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:25:07] MIGRACJA LUA

### Plik: `data-otservbr-global/lib/quests/svargrond_arena.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: quests

---

## [2025-12-08 18:25:58] MIGRACJA LUA

### Plik: `data-otservbr-global/lib/quests/soul_war.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: quests

---

## [2025-12-08 18:26:00] MIGRACJA LUA

### Plik: `data/scripts/actions/items/sweet_mangonaise_elixir.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:01] MIGRACJA LUA

### Plik: `data/scripts/actions/items/rotworm_stew.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:01] MIGRACJA LUA

### Plik: `data/scripts/actions/items/banana_chocolate_shake.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:02] MIGRACJA LUA

### Plik: `data/scripts/actions/items/store_coins.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:02] MIGRACJA LUA

### Plik: `data/scripts/actions/items/blessed_steak.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:03] MIGRACJA LUA

### Plik: `data/scripts/actions/items/pot_of_blackjack.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:07] MIGRACJA LUA

### Plik: `data/scripts/actions/items/exercise_training_weapons.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:07] MIGRACJA LUA

### Plik: `data/scripts/actions/items/premium_scroll.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:08] MIGRACJA LUA

### Plik: `data/scripts/actions/items/hireling_lamp.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:44] MIGRACJA LUA

### Plik: `data/scripts/actions/items/ferumbras_amulet.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:45] MIGRACJA LUA

### Plik: `data/scripts/actions/items/anniversary_balloons.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:46] MIGRACJA LUA

### Plik: `data/scripts/actions/items/reward_bags.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:47] MIGRACJA LUA

### Plik: `data/scripts/actions/items/demonic_candy_ball.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:48] MIGRACJA LUA

### Plik: `data/scripts/actions/items/carrot_cake.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:48] MIGRACJA LUA

### Plik: `data/scripts/actions/items/tropical_fried_terrorbird.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:49] MIGRACJA LUA

### Plik: `data/scripts/actions/items/northern_fishburger.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:49] MIGRACJA LUA

### Plik: `data/scripts/actions/items/cup_of_molten_gold.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:51] MIGRACJA LUA

### Plik: `data/scripts/actions/items/foods.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:26:52] MIGRACJA LUA

### Plik: `data/scripts/actions/items/hydra_tongue_salad.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:30] MIGRACJA LUA

### Plik: `data/scripts/actions/items/usable_phantasmal_jade_items.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:31] MIGRACJA LUA

### Plik: `data/scripts/actions/items/ferumbras_mana_keg.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:31] MIGRACJA LUA

### Plik: `data/scripts/actions/items/veggie_casserole.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:32] MIGRACJA LUA

### Plik: `data/scripts/actions/items/coconut_shrimp_bake.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:33] MIGRACJA LUA

### Plik: `data/scripts/actions/items/cobra_flask.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:33] MIGRACJA LUA

### Plik: `data/scripts/actions/items/bed_modification_kits.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:34] MIGRACJA LUA

### Plik: `data/scripts/actions/items/roasted_dragon_wings.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:35] MIGRACJA LUA

### Plik: `data/scripts/actions/items/wheel_scrolls.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:36] MIGRACJA LUA

### Plik: `data/scripts/actions/items/filled_jalapeno_peppers.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:27:37] MIGRACJA LUA

### Plik: `data/scripts/actions/items/blueberry_cupcake.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:14] MIGRACJA LUA

### Plik: `data/scripts/actions/items/lemon_cupcake.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:14] MIGRACJA LUA

### Plik: `data/scripts/actions/items/strawberry_cupcake.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:16] MIGRACJA LUA

### Plik: `data/scripts/actions/objects/carpets.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:17] MIGRACJA LUA

### Plik: `data/scripts/actions/objects/cask_and_kegs.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:18] MIGRACJA LUA

### Plik: `data/scripts/actions/tools/watch.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:19] MIGRACJA LUA

### Plik: `data/scripts/actions/tools/crushers.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:20] MIGRACJA LUA

### Plik: `data/scripts/actions/tools/claw_of_the_noxious_spawn.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:21] MIGRACJA LUA

### Plik: `data/scripts/actions/doors/key_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:21] MIGRACJA LUA

### Plik: `data/scripts/actions/doors/level_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:28:22] MIGRACJA LUA

### Plik: `data/scripts/actions/doors/quest_door.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:03] MIGRACJA LUA

### Plik: `data/scripts/movements/closing_door.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:04] MIGRACJA LUA

### Plik: `data/scripts/movements/special_tiles.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:14] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/create_spawn.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:15] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/close_server.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:16] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/manage_vip.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:16] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/add_money.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:17] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/open_server.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:18] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/raids.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:20] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/icons_functions.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:29:21] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/test_send_message.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:00] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/save.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:00] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/reload.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:01] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/achievement_functions.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:02] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/start_raid.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:05] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/zones.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:07] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/manage_kv.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:08] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/manage_tutor.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:09] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/create_npc.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:10] MIGRACJA LUA

### Plik: `data/scripts/talkactions/god/test.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:11] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/position.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:50] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/ghost.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:51] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/mc_check.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:51] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/push_town.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:52] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/info.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:53] MIGRACJA LUA

### Plik: `data/scripts/talkactions/gm/afk.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:54] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/reward.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:55] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/emote_spell.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:57] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/refill.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:57] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/buy_house.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:30:58] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/flask.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:37] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/hidden_npc_sell_shop_items.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:38] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/leave_house.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:39] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/auto_loot.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:39] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/vip.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:42] MIGRACJA LUA

### Plik: `data/scripts/talkactions/player/bank.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:43] MIGRACJA LUA

### Plik: `data/scripts/systems/concoctions.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:45] MIGRACJA LUA

### Plik: `data/scripts/creaturescripts/player/offline_training.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:46] MIGRACJA LUA

### Plik: `data/scripts/creaturescripts/player/login.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:47] MIGRACJA LUA

### Plik: `data/scripts/creaturescripts/player/name_lock.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:31:58] MIGRACJA LUA

### Plik: `data/npclib/npc_system/bank_system.lua`

**Akcja:** Zmigrowano 67 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:32:42] MIGRACJA LUA

### Plik: `data/npclib/npc_system/modules.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:32:54] MIGRACJA LUA

### Plik: `data/libs/compat/compat.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:04] MIGRACJA LUA

### Plik: `data/libs/functions/functions.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:06] MIGRACJA LUA

### Plik: `data/libs/functions/lever.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:10] MIGRACJA LUA

### Plik: `data/libs/functions/boss_lever.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:16] MIGRACJA LUA

### Plik: `data/libs/systems/hireling.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:20] MIGRACJA LUA

### Plik: `data/libs/systems/blessing.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:21] MIGRACJA LUA

### Plik: `data/libs/systems/daily_reward.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:23] MIGRACJA LUA

### Plik: `data/libs/systems/concoctions.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: misc

---

## [2025-12-08 18:33:43] MIGRACJA LUA

### Plik: `data/modules/scripts/gamestore/init.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:34:28] MIGRACJA LUA

### Plik: `data/modules/scripts/daily_reward/daily_reward.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-08 18:34:28] ANALIZA C++

### Plik: `src/game/game.cpp`

**Akcja:** Znaleziono 62 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:34] ANALIZA C++

### Plik: `src/io/ioprey.cpp`

**Akcja:** Znaleziono 5 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:37] ANALIZA C++

### Plik: `src/creatures/npcs/npc.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:38] ANALIZA C++

### Plik: `src/creatures/combat/spells.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:39] ANALIZA C++

### Plik: `src/creatures/players/grouping/party.cpp`

**Akcja:** Znaleziono 14 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:42] ANALIZA C++

### Plik: `src/lua/functions/map/house_functions.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:44] ANALIZA C++

### Plik: `src/server/network/protocol/protocolgame.cpp`

**Akcja:** Znaleziono 8 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-08 18:34:44] ANALIZA WEB

### Plik: `html_copy/whereami.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:34:44] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:35:22] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:36:19] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:37:18] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:38:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:39:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:40:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:41:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:42:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:43:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:44:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:45:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:46:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:47:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:48:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:49:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:50:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:51:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:52:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:53:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:54:21] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:55:18] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:56:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:57:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:58:16] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 18:59:16] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:00:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:01:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:02:16] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:03:16] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:04:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:05:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:06:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:07:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:07:52] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:08:14] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:08:31] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:09:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:10:12] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:11:12] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:12:13] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:13:12] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:14:15] ANALIZA WEB

### Plik: `html_copy/routes/api.php`

**Akcja:** Znaleziono 0
0 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/accounts.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/clmd.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/mailer.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/reports.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/pages.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/dashboard.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/news.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:13] ANALIZA WEB

### Plik: `html_copy/admin/pages/menus.php`

**Akcja:** Znaleziono 5 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:14] ANALIZA WEB

### Plik: `html_copy/admin/pages/changelog.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:14] ANALIZA WEB

### Plik: `html_copy/admin/pages/players.php`

**Akcja:** Znaleziono 7 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:46] ANALIZA WEB

### Plik: `html_copy/admin/pages/logs.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:46] ANALIZA WEB

### Plik: `html_copy/admin/pages/tools.php`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:46] ANALIZA WEB

### Plik: `html_copy/index.nginx-debian.html`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 19:15:46] ANALIZA WEB

### Plik: `html_copy/system/exception.php`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/src/Settings.php`

**Akcja:** Znaleziono 11 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/src/Spells.php`

**Akcja:** Znaleziono 5 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/src/Monsters.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/libs/rfc6238.php`

**Akcja:** Znaleziono 14 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/pages/exp-stages.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:15:47] ANALIZA WEB

### Plik: `html_copy/system/pages/polls.php`

**Akcja:** Znaleziono 35 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:22] ANALIZA WEB

### Plik: `html_copy/system/pages/bans.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:22] ANALIZA WEB

### Plik: `html_copy/system/pages/monsters.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:24] ANALIZA WEB

### Plik: `html_copy/system/pages/records.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:24] ANALIZA WEB

### Plik: `html_copy/system/pages/highscores.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:25] ANALIZA WEB

### Plik: `html_copy/system/pages/team.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:26] ANALIZA WEB

### Plik: `html_copy/system/pages/news.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:26] ANALIZA WEB

### Plik: `html_copy/system/pages/gallery.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:26] ANALIZA WEB

### Plik: `html_copy/system/pages/characters.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:16:28] ANALIZA WEB

### Plik: `html_copy/system/migrations/27-downloads.html`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 19:16:28] ANALIZA WEB

### Plik: `html_copy/system/migrations/27-commands.html`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 19:16:59] ANALIZA WEB

### Plik: `html_copy/vendor/composer/platform_check.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:00] ANALIZA WEB

### Plik: `html_copy/install/steps/3-requirements.php`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:00] ANALIZA WEB

### Plik: `html_copy/install/steps/1-welcome.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:00] ANALIZA WEB

### Plik: `html_copy/install/includes/twig_error.html`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 19:17:00] ANALIZA WEB

### Plik: `html_copy/install/template/template.php`

**Akcja:** Znaleziono 3 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:00] ANALIZA WEB

### Plik: `html_copy/node_modules/lazy-ass/index.html`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 19:17:01] ANALIZA WEB

### Plik: `html_copy/phpmyadmin/examples/openid.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:01] ANALIZA WEB

### Plik: `html_copy/phpmyadmin/examples/signon.php`

**Akcja:** Znaleziono 2 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:02] ANALIZA WEB

### Plik: `html_copy/tools/translation_manager.php`

**Akcja:** Znaleziono 24 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:02] ANALIZA WEB

### Plik: `html_copy/index.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:17:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:17:30] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:19:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:19:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:22:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:22:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:24:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:24:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:26:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:26:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:28:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:28:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:30:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:30:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:32:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:33:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:35:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:35:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:37:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:37:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:39:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:39:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:42:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:42:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:44:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:44:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:46:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:46:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:48:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:49:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:51:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:51:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:53:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:53:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:55:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 19:55:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44449

---

## [2025-12-08 19:57:23] MIGRACJA LUA

### Plik: `data-canary/npc/canary.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-08 19:58:36] ANALIZA WEB

### Plik: `html_copy/app/Controller/Pages/Outfit.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:58:36] ANALIZA WEB

### Plik: `html_copy/app/Controller/Admin/Items.php`

**Akcja:** Znaleziono 1 stringów

**Szczegóły:**
Typ: php

---

## [2025-12-08 19:58:37] ANALIZA WEB

### Plik: `html_copy/resources/icons/bootstrap-icons-1.8.1/index.html`

**Akcja:** Znaleziono 1153 stringów

**Szczegóły:**
Typ: html

---

## [2025-12-08 21:16:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:16:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:18:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:18:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:20:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:20:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:21:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:21:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:23:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:23:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:25:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:25:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:29:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:29:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:31:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:31:43] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:34:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:34:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:37:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:37:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:39:46] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:39:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:42:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:42:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:45:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:45:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:47:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:47:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:50:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:50:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:52:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:52:39] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:55:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:55:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 21:57:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 21:57:41] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 22:00:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:00:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 22:06:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:06:52] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44768

---

## [2025-12-08 22:08:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alyxo.lua`

**Akcja:** Przetworzono 24 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:11:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:11:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:14:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:14:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:16:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:16:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:19:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:19:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:21:51] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:21:53] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:24:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:24:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:27:01] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:27:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:30:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:30:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:32:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:32:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44792

---

## [2025-12-08 22:35:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shimun.lua`

**Akcja:** Przetworzono 6 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:35:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tefrit.lua`

**Akcja:** Przetworzono 6 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:35:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/saideh.lua`

**Akcja:** Przetworzono 3 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:35:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tigo.lua`

**Akcja:** Przetworzono 2 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:35:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kallimae.lua`

**Akcja:** Przetworzono 9 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:35:43] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yonan.lua`

**Akcja:** Przetworzono 9 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-08 22:41:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:42:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:44:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:44:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:44:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:44:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:46:55] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:46:57] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:48:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:48:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:49:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:49:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:50:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:51:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:51:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:51:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:53:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:53:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:55:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:55:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 22:58:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 22:58:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:00:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:00:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:01:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:01:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:04:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:04:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:06:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:06:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:08:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:08:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:10:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:10:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:12:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:12:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:14:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:14:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:16:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:16:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:18:41] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:18:43] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:20:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:20:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:22:50] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:22:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:24:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:24:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:46:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:46:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:49:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:49:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:51:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:51:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:53:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:53:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:56:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:56:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-08 23:58:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-08 23:58:39] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:01:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:01:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:05:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:05:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:07:44] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:07:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:10:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:10:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:12:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:12:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:14:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:15:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:16:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:17:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:18:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:18:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:20:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:20:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:22:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:22:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:25:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:25:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:31:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:31:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:33:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:33:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:36:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:36:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:38:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:38:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:41:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:43:35] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:43:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:46:04] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:46:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:49:34] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:49:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:52:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:52:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:54:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:54:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:56:50] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:56:53] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 00:59:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 00:59:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 01:01:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 01:01:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 44827

---

## [2025-12-09 01:04:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chondur.lua`

**Akcja:** Przetworzono 38 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:04:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/herbert.lua`

**Akcja:** Przetworzono 3 stringów

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/malor.lua`

**Akcja:** Wyciągnięto 10 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/romir.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:27] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/grombur.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_haba.lua`

**Akcja:** Wyciągnięto 35 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ceiron.lua`

**Akcja:** Wyciągnięto 17 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:38] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_thelandil.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/queen_eloise.lua`

**Akcja:** Wyciągnięto 66 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/curos.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/izsh.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:07:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/angelina.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hjaern.lua`

**Akcja:** Wyciągnięto 15 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/baa_leal.lua`

**Akcja:** Wyciągnięto 10 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gorn.lua`

**Akcja:** Wyciągnięto 24 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/navigator.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/barbara.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:27] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rata_mari.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/fenbala.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomargery.lua`

**Akcja:** Wyciągnięto 43 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/fa_hradin.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:08:41] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_dragon_mother.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:28] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_majestic_warwolf.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/snake_eye.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:34] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_dream_master.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rock_steady.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_elena.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:41] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/charos.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:43] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/an_old_dragon_lord.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:44] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_fluffy_squirrel.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:47] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bron.lua`

**Akcja:** Wyciągnięto 13 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:11:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/alesar.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomewart.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eustacio.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnominus.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_bone_master.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomespector.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tony.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zirella.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/corym_servant.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/siflind.lua`

**Akcja:** Wyciągnięto 32 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:12:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/aruda.lua`

**Akcja:** Wyciągnięto 42 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:14:41] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/paulie.lua`

**Akcja:** Wyciągnięto 47 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:14:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gregor.lua`

**Akcja:** Wyciągnięto 32 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:14:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dalbrect.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:14:58] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/charles.lua`

**Akcja:** Wyciągnięto 13 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_weakened_forest_fury.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_dead_bureaucrat4.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:05] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/shimun.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jeronimo.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hireling.lua`

**Akcja:** Wyciągnięto 20 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sven.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:34] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dove.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:41] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guard_saros.lua`

**Akcja:** Wyciągnięto 42 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/servant_sentry.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/morgan.lua`

**Akcja:** Wyciągnięto 12 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/percybald.lua`

**Akcja:** Wyciągnięto 36 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_blind_prophet.lua`

**Akcja:** Wyciągnięto 16 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:15:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/marina.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:16:03] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/storkus.lua`

**Akcja:** Wyciągnięto 24 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:16:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/taegen.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:16:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jack.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:17:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lukosch.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:17:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/alwin.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cael.lua`

**Akcja:** Wyciągnięto 37 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:03] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hal.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:05] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/svenson.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:08] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tefrit.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:09] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/demonguard.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bertha.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:17] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/frosty.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/umar.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/denominator.lua`

**Akcja:** Wyciągnięto 12 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:39] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_bearded_woman.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tehlim.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/duncan.lua`

**Akcja:** Wyciągnięto 21 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eshaya.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cillia.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zurak_arena.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bunny_bonecrusher.lua`

**Akcja:** Wyciągnięto 19 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/edron_guardsman.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:18:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_beggar_king.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:20:46] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/razan.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bozo.lua`

**Akcja:** Wyciągnięto 86 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:15] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_dreadnought.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/wyda.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lubo.lua`

**Akcja:** Wyciągnięto 23 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/awarness_of_the_emperor.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:27] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sinclair.lua`

**Akcja:** Wyciągnięto 10 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/erayo.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/carlos.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:38] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dedoras.lua`

**Akcja:** Wyciągnięto 20 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/busty_bonecrusher.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/palomino.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:21:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_swan.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cledwyn.lua`

**Akcja:** Wyciągnięto 19 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/boozer.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:04] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eroth.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sebastian.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/grizzly_adams.lua`

**Akcja:** Wyciągnięto 37 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:27] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zurak.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:22:28] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/timothy.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ghostly_wolf.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gabel.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/berenice.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/christoph.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:26] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/elliott.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:28] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maris.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:31] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tomruk_the_ruddy.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:32] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/nor.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:38] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomeral.lua`

**Akcja:** Wyciągnięto 25 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:41] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/avar_tar.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:24:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/battlemart.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/trisha.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/an_idol.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:08] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/commander_stone.lua`

**Akcja:** Wyciągnięto 27 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_sweaty_cyclops.lua`

**Akcja:** Wyciągnięto 48 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/leeland.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/blossom_bonecrusher.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/palimuth.lua`

**Akcja:** Wyciągnięto 15 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/atrad.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:25:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tamoril.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:27:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ustan.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:27:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/shauna.lua`

**Akcja:** Wyciągnięto 35 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:27:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/aurita.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:27:39] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sigurd.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:27:46] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/inigo.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/seymour.lua`

**Akcja:** Wyciągnięto 107 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/vescu.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sundara.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bo_ques.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/armenius.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:35] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/irmana.lua`

**Akcja:** Wyciągnięto 42 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chuckles.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ajax.lua`

**Akcja:** Wyciągnięto 20 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_behil.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chartan.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/beatrice.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chrak.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/broken_servant_sentry.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:28:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/emperor_rehal.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:29:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/yalahari.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:30:43] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomally.lua`

**Akcja:** Wyciągnięto 14 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:30:46] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cassino.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:30:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/undal.lua`

**Akcja:** Wyciągnięto 14 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:30:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/emael.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:30:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/brewster.lua`

**Akcja:** Wyciągnięto 31 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/daniel_steelsoul.lua`

**Akcja:** Wyciągnięto 23 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:04] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tim_the_guard.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_queen_of_the_banshees.lua`

**Akcja:** Wyciągnięto 26 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/simon_the_beggar.lua`

**Akcja:** Wyciągnięto 29 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hugo.lua`

**Akcja:** Wyciągnięto 14 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:39] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomission.lua`

**Akcja:** Wyciągnięto 19 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/xodet.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:43] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/reed.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/albinius.lua`

**Akcja:** Wyciągnięto 38 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rottin_wood.lua`

**Akcja:** Wyciągnięto 13 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:31:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lisander.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:32:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/yaman.lua`

**Akcja:** Wyciągnięto 15 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:32:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/arnold.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:32:03] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/frafnar.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:32:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/testserver_assistant.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:33:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ariella.lua`

**Akcja:** Wyciągnięto 16 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:33:58] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/alesar_functions.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_beggar.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sarina.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:05] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/arito.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_jack_rat.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:09] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/charlotta.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnome_trooper.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lardoc_bashsmite.lua`

**Akcja:** Wyciągnięto 22 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bambi_bonecrusher.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/vanys.lua`

**Akcja:** Wyciągnięto 14 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tandros.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_rahlkora.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:34:55] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/emma.lua`

**Akcja:** Wyciągnięto 35 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/arkulius.lua`

**Akcja:** Wyciągnięto 10 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:04] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tamerin.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bolfona.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:12] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jack_springer.lua`

**Akcja:** Wyciągnięto 22 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/elvith.lua`

**Akcja:** Wyciągnięto 19 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:35:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/norma.lua`

**Akcja:** Wyciągnięto 47 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/markwin.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rachel.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jacob.lua`

**Akcja:** Wyciągnięto 7 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/alyxo.lua`

**Akcja:** Wyciągnięto 24 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:43] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/karl.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/shiriel.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ghost_of_a_priest.lua`

**Akcja:** Wyciągnięto 23 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/bruce.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/santa_claus.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:37:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ivalisse.lua`

**Akcja:** Wyciągnięto 12 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dermot.lua`

**Akcja:** Wyciągnięto 12 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/omrabas.lua`

**Akcja:** Wyciągnięto 40 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/the_librarian.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ongulf.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:31] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/saideh.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lazaran.lua`

**Akcja:** Wyciągnięto 19 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/raymond_striker.lua`

**Akcja:** Wyciągnięto 13 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:46] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maelyrra.lua`

**Akcja:** Wyciągnięto 18 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zalamon.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:38:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/asima.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chrystal.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:44] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lokur.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gnomad.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:50] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rock_in_a_hard_place.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_tiko.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/aldo.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:40:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_luke.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/perod.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ezebeth.lua`

**Akcja:** Wyciągnięto 8 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:04] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/miles_the_guard.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/karith.lua`

**Akcja:** Wyciągnięto 31 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sholley.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:26] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/oressa.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:34] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chester_kahs.lua`

**Akcja:** Wyciągnięto 34 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ghorza.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/mortimer.lua`

**Akcja:** Wyciągnięto 61 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:41:59] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/klom_stonecutter.lua`

**Akcja:** Wyciągnięto 25 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:42:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/iwar.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:42:05] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maryza.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:42:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tigo.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:43:58] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/miraia.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eruaran.lua`

**Akcja:** Wyciągnięto 47 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dancing_fairy.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/guide_davina.lua`

**Akcja:** Wyciągnięto 11 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zora.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/mr._west.lua`

**Akcja:** Wyciągnięto 2 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_strange_chalice.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/serafin.lua`

**Akcja:** Wyciągnięto 4 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kulag_the_guard.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:28] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jerom.lua`

**Akcja:** Wyciągnięto 26 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tom.lua`

**Akcja:** Wyciągnięto 41 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/melfar.lua`

**Akcja:** Wyciągnięto 6 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jean_claude.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/mother_of_jack.lua`

**Akcja:** Wyciągnięto 3 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:44:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/warbert.lua`

**Akcja:** Wyciągnięto 1 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:45:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hairycles.lua`

**Akcja:** Wyciągnięto 75 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:45:12] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/torkada.lua`

**Akcja:** Wyciągnięto 5 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:45:15] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ubaid.lua`

**Akcja:** Wyciągnięto 9 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:45:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/padreia.lua`

**Akcja:** Wyciągnięto 17 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:45:23] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/flickering_soul.lua`

**Akcja:** Wyciągnięto 17 kluczy

**Szczegóły:**
Kategoria: npc, NPC: true

---

## [2025-12-09 01:48:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dorian.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:48:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/brodrosch.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:48:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomilly.lua`

**Akcja:** Zmigrowano 36 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:48:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_dead_bureaucrat3.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:48:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/barnabas_dee.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/muriel.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/stricken_soul.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/wentworth.lua`

**Akcja:** Zmigrowano 41 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rashid_custom.lua`

**Akcja:** Zmigrowano 48 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gate_guardian.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnommander.lua`

**Akcja:** Zmigrowano 21 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/xelvar.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mirabell.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jorge.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:49:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/woblin.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:50:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/myra.lua`

**Akcja:** Zmigrowano 47 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:50:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sandomo.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:50:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/flora.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:50:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/briasol.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:50:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/santiago.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/altar.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tarak_sunken.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eleonore.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/plunderpurse.lua`

**Akcja:** Zmigrowano 40 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/julius.lua`

**Akcja:** Zmigrowano 44 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_prisoner.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sam.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_kunibert.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:47] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alexander.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:52:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lurik.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomux.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zizzle.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/barazbaz.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/noodles.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/myzzi.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:16] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lugri.lua`

**Akcja:** Zmigrowano 21 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/walter_the_guard.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/talphion.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/uncle.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:53:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gareth.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/xorlosh.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/canary.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zarifan.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/thanita.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/oliver.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/grof_the_guard.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/theodore_loveless.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomaticus.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/costello.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/pemaret.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/doubleday.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/habdel.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:55:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/budrik.lua`

**Akcja:** Zmigrowano 21 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rabaz.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sinatuki.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sandra.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:10] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_dead_bureaucrat1.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chief_grarkharok.lua`

**Akcja:** Zmigrowano 30 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:56:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomelvis.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/malor.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:10] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/grombur.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:16] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_haba.lua`

**Akcja:** Zmigrowano 35 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ceiron.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_thelandil.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/queen_eloise.lua`

**Akcja:** Zmigrowano 66 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/curos.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/izsh.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/angelina.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hjaern.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/baa_leal.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:58:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gorn.lua`

**Akcja:** Zmigrowano 24 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/navigator.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/barbara.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rata_mari.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/fenbala.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomargery.lua`

**Akcja:** Zmigrowano 39 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:21] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/fa_hradin.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 01:59:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_dragon_mother.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:01:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_majestic_warwolf.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:01:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/snake_eye.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:01:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_dream_master.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:01:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rock_steady.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/charos.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/an_old_dragon_lord.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_fluffy_squirrel.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bron.lua`

**Akcja:** Zmigrowano 13 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alesar.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:42] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomewart.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eustacio.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnominus.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_bone_master.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:03:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomespector.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tony.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zirella.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:08] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/corym_servant.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/siflind.lua`

**Akcja:** Zmigrowano 32 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/aruda.lua`

**Akcja:** Zmigrowano 42 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/paulie.lua`

**Akcja:** Zmigrowano 39 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gregor.lua`

**Akcja:** Zmigrowano 32 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dalbrect.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:04:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/charles.lua`

**Akcja:** Zmigrowano 13 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:05:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_weakened_forest_fury.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_dead_bureaucrat4.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shimun.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jeronimo.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hireling.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sven.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dove.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:08:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guard_saros.lua`

**Akcja:** Zmigrowano 42 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/servant_sentry.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/morgan.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/percybald.lua`

**Akcja:** Zmigrowano 36 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_blind_prophet.lua`

**Akcja:** Zmigrowano 16 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/marina.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/storkus.lua`

**Akcja:** Zmigrowano 22 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/taegen.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jack.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:42] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lukosch.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alwin.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cael.lua`

**Akcja:** Zmigrowano 37 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hal.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:09:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/svenson.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:11:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tefrit.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:11:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/demonguard.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bertha.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/frosty.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/umar.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/denominator.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_bearded_woman.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tehlim.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/duncan.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eshaya.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cillia.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zurak_arena.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bunny_bonecrusher.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:12:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/edron_guardsman.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_beggar_king.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/razan.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bozo.lua`

**Akcja:** Zmigrowano 86 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_dreadnought.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:43] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/wyda.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:13:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lubo.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:15:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/awarness_of_the_emperor.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:15:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sinclair.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:02] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/erayo.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/carlos.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dedoras.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/busty_bonecrusher.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/palomino.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_swan.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cledwyn.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/boozer.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eroth.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:39] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sebastian.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/grizzly_adams.lua`

**Akcja:** Zmigrowano 27 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zurak.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/timothy.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:16:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ghostly_wolf.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:17:02] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gabel.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:17:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/berenice.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:17:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/christoph.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:17:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/elliott.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:18:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/maris.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:18:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tomruk_the_ruddy.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:18:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/nor.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:18:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomeral.lua`

**Akcja:** Zmigrowano 25 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/avar_tar.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/trisha.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/an_idol.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/commander_stone.lua`

**Akcja:** Zmigrowano 27 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_sweaty_cyclops.lua`

**Akcja:** Zmigrowano 48 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/leeland.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/blossom_bonecrusher.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/palimuth.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/atrad.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tamoril.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ustan.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shauna.lua`

**Akcja:** Zmigrowano 35 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:19:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/aurita.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:20:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/inigo.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:20:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/seymour.lua`

**Akcja:** Zmigrowano 103 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:20:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/vescu.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bo_ques.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/armenius.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/irmana.lua`

**Akcja:** Zmigrowano 42 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ajax.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_behil.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chartan.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/beatrice.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:22:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chrak.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/broken_servant_sentry.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/emperor_rehal.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yalahari.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomally.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cassino.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/undal.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/emael.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:39] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/brewster.lua`

**Akcja:** Zmigrowano 31 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/daniel_steelsoul.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tim_the_guard.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_queen_of_the_banshees.lua`

**Akcja:** Zmigrowano 26 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:23:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/simon_the_beggar.lua`

**Akcja:** Zmigrowano 29 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hugo.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomission.lua`

**Akcja:** Zmigrowano 16 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/xodet.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/reed.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/albinius.lua`

**Akcja:** Zmigrowano 38 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rottin_wood.lua`

**Akcja:** Zmigrowano 13 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:25:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lisander.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yaman.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/arnold.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/frafnar.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/testserver_assistant.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ariella.lua`

**Akcja:** Zmigrowano 16 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alesar_functions.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_beggar.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sarina.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/arito.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_jack_rat.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/charlotta.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnome_trooper.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:26:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lardoc_bashsmite.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bambi_bonecrusher.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/vanys.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_rahlkora.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/emma.lua`

**Akcja:** Zmigrowano 35 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/arkulius.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tamerin.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:28:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bolfona.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jack_springer.lua`

**Akcja:** Zmigrowano 22 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:08] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/elvith.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:21] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/norma.lua`

**Akcja:** Zmigrowano 47 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/markwin.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rachel.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:43] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jacob.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alyxo.lua`

**Akcja:** Zmigrowano 24 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/karl.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:29:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ghost_of_a_priest.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:30:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bruce.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:30:02] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/santa_claus.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:30:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ivalisse.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:30:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dermot.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:10] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/omrabas.lua`

**Akcja:** Zmigrowano 40 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_librarian.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:16] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ongulf.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/saideh.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lazaran.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/raymond_striker.lua`

**Akcja:** Zmigrowano 13 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/maelyrra.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zalamon.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:47] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/asima.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:32:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chrystal.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lokur.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomad.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:08] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rock_in_a_hard_place.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_tiko.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/aldo.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_luke.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/perod.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ezebeth.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/miles_the_guard.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:33:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/karith.lua`

**Akcja:** Zmigrowano 31 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:35:43] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sholley.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:35:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/oressa.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chester_kahs.lua`

**Akcja:** Zmigrowano 34 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mortimer.lua`

**Akcja:** Zmigrowano 61 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/klom_stonecutter.lua`

**Akcja:** Zmigrowano 21 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/iwar.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/maryza.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tigo.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:43] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/miraia.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:36:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eruaran.lua`

**Akcja:** Zmigrowano 25 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dancing_fairy.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_davina.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zora.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mr._west.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_strange_chalice.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/serafin.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kulag_the_guard.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:42] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jerom.lua`

**Akcja:** Zmigrowano 26 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:37:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tom.lua`

**Akcja:** Zmigrowano 41 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:38:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/melfar.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:40:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jean_claude.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:40:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mother_of_jack.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:40:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/warbert.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:40:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hairycles.lua`

**Akcja:** Zmigrowano 75 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:40:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/torkada.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:41:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ubaid.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:41:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/padreia.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:41:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/angus.lua`

**Akcja:** Zmigrowano 79 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:41:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/huntsman.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:21] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kallimae.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_strange_fellow.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/uzgod.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_dead_bureaucrat2.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gail.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:47] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/maeryn.lua`

**Akcja:** Zmigrowano 22 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jondrin.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:42:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/haroun.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:43:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/marvin.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:43:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/elathriel.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/barry.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tarak_inner.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/carina.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zebron.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/harlow.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_haba_open_sea.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/pukosch.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:45:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tereban_functions.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rashid.lua`

**Akcja:** Zmigrowano 48 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:08] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kroox.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:10] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/roswitha.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jack_fate_goroma.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/partos.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:21] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kazzan.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/liane.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/corym_ratter.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/skjaar.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:48:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/nurik.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomus.lua`

**Akcja:** Zmigrowano 20 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:10] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dukosch.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:13] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/fenech.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zumtah.lua`

**Akcja:** Zmigrowano 24 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:20] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rose.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/amber.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gelidrazahs_thirst.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shoddy_beggar.lua`

**Akcja:** Zmigrowano 24 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ruprecht.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:49:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alkestios.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:53:47] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/henricus.lua`

**Akcja:** Zmigrowano 53 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:53:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kevin.lua`

**Akcja:** Zmigrowano 60 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:53:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/farhilorn_of_the_winter_court.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/sister_of_jack.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/iskan.lua`

**Akcja:** Zmigrowano 32 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/riddler.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/freezhild.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ambassador_of_rathleton.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_orc_king.lua`

**Akcja:** Zmigrowano 26 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:54:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/robson.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jean_pierre.lua`

**Akcja:** Zmigrowano 48 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:09] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hanna.lua`

**Akcja:** Zmigrowano 12 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/peter.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomadness.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yasir.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:33] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/andrew_lyze.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/spectulus.lua`

**Akcja:** Zmigrowano 39 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cobra.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/rehon.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:55:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_jonathan.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ztiss.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:45] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_starving_dog.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chavis.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shiantis.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/orockle.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shirith.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:58:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/benjamin.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:02] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_waverider.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/shirtalis_of_the_summer_court.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:06] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/swolt.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:27] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_sleeping_dragon.lua`

**Akcja:** Zmigrowano 31 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_alexena.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lorbas.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/harsky.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gamel.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:47] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/emperor_kruzak.lua`

**Akcja:** Zmigrowano 19 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnomerik.lua`

**Akcja:** Zmigrowano 34 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 02:59:57] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/willard.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:00:01] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/nah_bob.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:00:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/stutch.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mazarius.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/appaloosa.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ahmet.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bloodshade_sacrifice.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/noozer.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yonan.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/zoltan.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gnombold.lua`

**Akcja:** Zmigrowano 36 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/wyrdin.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:02:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/elyen_ravenlock.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:12] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/terrence.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:16] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/eremo.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:17] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/pig.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:31] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/walter_jaeger.lua`

**Akcja:** Zmigrowano 25 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/klaus.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/topsy.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:42] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lynda.lua`

**Akcja:** Zmigrowano 26 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/inkaef.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:03:46] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/faloriel.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:05:50] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/khanna.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:05:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/chantalle.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:05:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cornelia.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/yana.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:03] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/telas.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ikassis.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bloodshade_rotten.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/jamesfrancis.lua`

**Akcja:** Zmigrowano 5 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:15] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ishina.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/angelo.lua`

**Akcja:** Zmigrowano 15 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/elane.lua`

**Akcja:** Zmigrowano 45 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:39] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/humgolf.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:48] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/king_tibianus.lua`

**Akcja:** Zmigrowano 22 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:51] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/halvar.lua`

**Akcja:** Zmigrowano 18 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:56] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/mr_morris.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:06:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ulala.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:07:11] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/vascalir.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:07:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/vulturenose.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:07:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gewen.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:07:24] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tarun.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:09:22] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/gerimor.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:09:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/guide_edna.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:09:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ortheus.lua`

**Akcja:** Zmigrowano 24 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:09:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/the_oracle.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:09:40] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/moe.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-09 03:10:05] MIGRACJA LUA

### Plik: `data-otservbr-global/scripts/quests/the_first_dragon/actions_rewards.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: scripts

---

## [2025-12-09 03:11:11] ANALIZA C++

### Plik: `src/game/game.cpp`

**Akcja:** Znaleziono 62 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:11] ANALIZA C++

### Plik: `src/io/ioprey.cpp`

**Akcja:** Znaleziono 5 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:12] ANALIZA C++

### Plik: `src/creatures/npcs/npc.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:48] ANALIZA C++

### Plik: `src/creatures/combat/spells.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:48] ANALIZA C++

### Plik: `src/creatures/players/grouping/party.cpp`

**Akcja:** Znaleziono 14 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:49] ANALIZA C++

### Plik: `src/lua/functions/map/house_functions.cpp`

**Akcja:** Znaleziono 3 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:11:49] ANALIZA C++

### Plik: `src/server/network/protocol/protocolgame.cpp`

**Akcja:** Znaleziono 8 stringów do migracji

**Szczegóły:**
Wymaga ręcznej weryfikacji

---

## [2025-12-09 03:23:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:23:43] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:26:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:26:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:28:34] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:28:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:31:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:31:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:33:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:33:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:36:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:36:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:38:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:38:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:41:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:41:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:43:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:43:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:45:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:45:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:47:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:47:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:49:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:49:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:52:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:52:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:54:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:54:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:56:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:56:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 03:59:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 03:59:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:02:23] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:02:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:04:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:04:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:07:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:07:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:09:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:09:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:12:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:12:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:14:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 58 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:14:56] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:17:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:17:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:19:41] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:19:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:21:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:21:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:23:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:23:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:25:41] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:25:43] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:27:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:27:50] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:30:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:30:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:32:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:32:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:34:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:34:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:36:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:36:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:38:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:38:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:40:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:40:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:42:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:42:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:44:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:44:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:46:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:46:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:48:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:48:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:50:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:50:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:52:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:52:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:55:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:55:39] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:57:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:57:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 04:59:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 04:59:48] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:01:55] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:01:57] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:05:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:05:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:07:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:07:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:10:29] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:10:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:13:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:13:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:16:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:16:30] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:19:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:19:24] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:21:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:21:56] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:24:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:24:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:26:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:26:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:28:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:28:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:30:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:30:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:32:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:32:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:34:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:34:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:36:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:36:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:38:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:38:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:40:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:40:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:42:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:42:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:44:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:44:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:46:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:46:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:48:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:48:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:50:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:50:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:52:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:52:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:54:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:54:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:56:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:56:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 05:58:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 05:58:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:00:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:00:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:02:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:02:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:04:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:04:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:06:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:06:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:08:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:08:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:10:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:10:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:12:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:12:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:55:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:55:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 06:58:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 06:58:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:01:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:01:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:03:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:03:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:05:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:05:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:07:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:07:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:09:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:09:41] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:11:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:11:41] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:13:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:13:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:15:41] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:15:43] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:17:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:17:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:19:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:19:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:21:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:21:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:23:47] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:23:48] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:25:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:25:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:27:50] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:27:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:29:51] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:29:53] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:32:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:32:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:34:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:34:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:36:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:36:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:38:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:38:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:40:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:40:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:42:34] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:42:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:44:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:44:41] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:46:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:46:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:48:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:48:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:50:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:50:55] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:52:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:53:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:55:04] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:55:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:57:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:57:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 07:59:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 07:59:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:01:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:01:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:03:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:03:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:05:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:05:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:07:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:07:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:09:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:09:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:11:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:11:30] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:13:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:13:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:15:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:15:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:17:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:17:56] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:20:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:20:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:22:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:23:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:25:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:25:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:27:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:27:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:29:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:29:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:31:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:31:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:33:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:33:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:35:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:35:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:37:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:37:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:39:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:39:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:41:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:41:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:43:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:43:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:45:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:45:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:47:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:47:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:49:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:49:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:51:47] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:51:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:53:50] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:53:52] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:55:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:55:53] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:57:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:57:56] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 08:59:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 08:59:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:01:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:02:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:04:01] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:04:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:06:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:06:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:08:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:08:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:10:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:10:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:12:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:12:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:14:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:14:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:16:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:16:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:18:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:18:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:20:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:20:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:22:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:22:50] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:24:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:24:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:26:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:26:57] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:29:01] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:29:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:31:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:31:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:33:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:33:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:35:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:35:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:37:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:37:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:39:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:39:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:41:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:41:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:43:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:43:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:45:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:45:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:47:35] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:47:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:49:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:49:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:51:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:51:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:53:47] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:53:48] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:55:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:55:52] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:57:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:57:55] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 09:59:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 09:59:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:02:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:02:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:04:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:04:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:06:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:06:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:08:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:08:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:10:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:10:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:12:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:12:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:14:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:14:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:16:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:16:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:18:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:18:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:20:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:20:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:22:50] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:22:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:24:55] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:24:56] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:26:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:27:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:29:04] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:29:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:31:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:31:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:33:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:33:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:35:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:35:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:37:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:37:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:39:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:39:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:41:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:41:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:43:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:43:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:45:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:45:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:47:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:47:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:49:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:49:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:51:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:51:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:53:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:53:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:55:47] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:55:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:57:51] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:57:52] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 10:59:53] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 10:59:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:01:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:01:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:03:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:04:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:06:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:06:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:08:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:08:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:10:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:10:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:12:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:12:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:14:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:14:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:16:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:16:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:18:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:18:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:20:41] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:20:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:22:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:22:50] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:24:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:24:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:26:57] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:26:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:29:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:29:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:31:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:31:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:33:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:33:11] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:35:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:35:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:37:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:37:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:39:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:39:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:41:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:41:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:43:29] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:43:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:45:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:45:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:47:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:47:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:49:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:49:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:51:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:51:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:53:48] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:53:50] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:55:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:55:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:57:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 11:57:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 11:59:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:00:00] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:02:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:02:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:04:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:04:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:06:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:06:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:08:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:08:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:10:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:10:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:12:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:12:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:14:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:14:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:16:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:16:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:18:43] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:18:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:20:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:20:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:23:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:23:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:25:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:25:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:27:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:27:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:29:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:29:11] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:31:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:31:11] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:33:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:33:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:35:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:35:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:37:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:37:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:39:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:39:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:41:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:41:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:43:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:43:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:45:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:45:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:47:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:47:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:49:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:49:14] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:51:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:51:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:53:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:53:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:55:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:55:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:57:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:57:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 12:59:29] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 12:59:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:01:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:01:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:03:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:03:41] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:06:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:06:09] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:08:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:08:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:11:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:11:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:13:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:13:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:16:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:16:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:18:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:18:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:20:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:20:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:22:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:22:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:24:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:24:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:26:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:26:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:28:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:28:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:30:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:30:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:32:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:32:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:34:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:34:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:36:23] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:36:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:38:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:38:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:40:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:40:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:42:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:42:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:44:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:44:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:46:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:46:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:48:12] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:48:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:50:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:50:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:52:09] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:52:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:54:08] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:54:10] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:56:07] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:56:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 13:58:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 13:58:07] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:00:04] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:00:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:02:04] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:02:05] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:04:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:04:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:06:02] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:06:04] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:08:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:08:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:10:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:10:02] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:11:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:12:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:13:58] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:13:59] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:15:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:15:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:17:55] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:17:57] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:19:54] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:19:55] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:21:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:21:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:23:51] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:23:52] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:25:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:25:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:27:47] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:27:49] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:29:46] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:29:48] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:31:44] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:31:45] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:33:42] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:33:44] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:35:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:35:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:37:38] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:37:40] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:39:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:39:38] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:41:36] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:41:37] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:43:34] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:43:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:45:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:45:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:47:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:47:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:49:29] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:49:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:51:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:51:30] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:53:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:53:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:55:25] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:55:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:57:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:57:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 14:59:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 14:59:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:01:21] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:01:23] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:03:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:03:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:05:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:05:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:07:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:07:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:09:14] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:09:16] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:11:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:11:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:13:13] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:13:15] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:15:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:15:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:17:33] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:17:35] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:19:34] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:19:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:21:32] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:21:34] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:23:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:23:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:25:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:25:30] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:27:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:27:28] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:29:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:29:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:31:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:31:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:33:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:33:24] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-09 15:35:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-09 15:35:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:49:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:49:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:51:17] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:51:19] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:53:15] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:53:17] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:55:16] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:55:18] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:57:18] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:57:20] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 03:59:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 03:59:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 04:01:05] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:01:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 04:04:11] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:04:12] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 52191

---

## [2025-12-10 04:06:18] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ninev.lua`

**Akcja:** Zmigrowano 30 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:19] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/bruno.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_gulliver.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/archery.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/hyacinth.lua`

**Akcja:** Zmigrowano 46 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:35] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_chelop.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/nina.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:37] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cornell.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:39] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_cookie.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:41] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/petros.lua`

**Akcja:** Zmigrowano 8 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tonar.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:06:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/uzon.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:16] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/al_dee.lua`

**Akcja:** Zmigrowano 57 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/isimov.lua`

**Akcja:** Zmigrowano 30 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:26] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kendra_thais.lua`

**Akcja:** Zmigrowano 9 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:29] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ziyad.lua`

**Akcja:** Zmigrowano 11 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/norf.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:38] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/kawill.lua`

**Akcja:** Zmigrowano 29 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:07:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/dallheim.lua`

**Akcja:** Zmigrowano 55 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:08:00] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lily.lua`

**Akcja:** Zmigrowano 62 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/tyrias.lua`

**Akcja:** Zmigrowano 30 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:42] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/cedrik.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:53] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lee_delle.lua`

**Akcja:** Zmigrowano 53 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ferryman_kamil_meluna.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:55] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lector.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:09:59] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/humphrey.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:04] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/anerui.lua`

**Akcja:** Zmigrowano 17 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:05] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/old_adall.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:07] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/nydala.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:14] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/oswald.lua`

**Akcja:** Zmigrowano 37 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:21] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/carlson.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:23] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/buddel_okolnir.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:25] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/junkar_mines.lua`

**Akcja:** Zmigrowano 2 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:30] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lorietta.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:32] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/a_ghostly_sage.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:36] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/alia.lua`

**Akcja:** Zmigrowano 23 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:39] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_harava.lua`

**Akcja:** Zmigrowano 10 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:44] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/lea.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:52] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/edala.lua`

**Akcja:** Zmigrowano 14 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:10:54] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/captain_seahorse.lua`

**Akcja:** Zmigrowano 7 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/iyad.lua`

**Akcja:** Wyekstrahowano 20 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/junkar_robsons.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lorek.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/buddel_raider_camp.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/iptar-sin.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_jack.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:37] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/nomad.lua`

**Akcja:** Wyekstrahowano 13 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/prezil.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/lailene.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/prezil.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/duria.lua`

**Akcja:** Wyekstrahowano 3 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:55] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/duria.lua`

**Akcja:** Wyekstrahowano 3 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:14:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hardek.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:00] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_max.lua`

**Akcja:** Wyekstrahowano 7 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kasmir.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kasmir.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/imbul.lua`

**Akcja:** Wyekstrahowano 3 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:15] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/imbul.lua`

**Akcja:** Wyekstrahowano 3 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/brasith.lua`

**Akcja:** Wyekstrahowano 10 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/brasith.lua`

**Akcja:** Wyekstrahowano 10 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/blind_orc.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/blind_orc.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:31] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/phillip.lua`

**Akcja:** Wyekstrahowano 25 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:31] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/phillip.lua`

**Akcja:** Wyekstrahowano 25 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:47] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dixi.lua`

**Akcja:** Wyekstrahowano 47 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:47] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dixi.lua`

**Akcja:** Wyekstrahowano 47 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:49] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ottokar.lua`

**Akcja:** Zmigrowano 4 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_pelagia.lua`

**Akcja:** Wyekstrahowano 12 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_frog.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_frog.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:58] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tonar_oskayaat.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:15:58] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tonar_oskayaat.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/sebastian_nargor.lua`

**Akcja:** Wyekstrahowano 5 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:15] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/obi.lua`

**Akcja:** Wyekstrahowano 47 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kendra.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:20] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maris_fenrock.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rapanaio_isle_of_evil.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/alternative_rock.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:26] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_ghostly_woman.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:16:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rafzan.lua`

**Akcja:** Wyekstrahowano 12 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/loui.lua`

**Akcja:** Wyekstrahowano 36 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/edvard.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:16] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eddy.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:26] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ferus.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/a_wrinkled_bonelord.lua`

**Akcja:** Wyekstrahowano 19 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rahkem.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_bluebear.lua`

**Akcja:** Wyekstrahowano 27 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/uzon_back.lua`

**Akcja:** Wyekstrahowano 7 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:52] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/legola.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:29:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/melian.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cipfried.lua`

**Akcja:** Wyekstrahowano 62 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:24] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/azalea.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_seagull.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:32] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/imalas.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:34] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/ninos.lua`

**Akcja:** Zmigrowano 1 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:42] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/frodo.lua`

**Akcja:** Wyekstrahowano 42 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:30:43] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hawkhurst.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:02] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zerbrus.lua`

**Akcja:** Wyekstrahowano 58 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:10] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/pythius_the_rotten.lua`

**Akcja:** Wyekstrahowano 14 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/pythius_the_rotten.lua`

**Akcja:** Wyekstrahowano 14 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:12] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_max_calassa.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_max_calassa.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tibra.lua`

**Akcja:** Wyekstrahowano 44 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_waverider_island.lua`

**Akcja:** Wyekstrahowano 5 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:26] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_breezelda.lua`

**Akcja:** Wyekstrahowano 7 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:28] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/narsai.lua`

**Akcja:** Zmigrowano 6 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/cranky_lizard_crone.lua`

**Akcja:** Wyekstrahowano 9 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:30] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/thorgrin.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/fiona.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:34] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maris_mistrock.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:46] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/buddel_helheim.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/maealil.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rock_with_a_soft_spot.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:56] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/zedrulon_the_fallen.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:31:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/dane.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:06] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/quentin.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:07] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ishebad.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gurbasch.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:11] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/junkar_thais.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:13] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/graubart.lua`

**Akcja:** Wyekstrahowano 10 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gelagos.lua`

**Akcja:** Wyekstrahowano 7 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:15] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rapanaio.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:17] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/buddel.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kais.lua`

**Akcja:** Wyekstrahowano 12 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:21] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_fearless.lua`

**Akcja:** Wyekstrahowano 13 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:31] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/archery_rook.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:33] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jack_fate.lua`

**Akcja:** Wyekstrahowano 13 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:34] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/edowir.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/red_lilly.lua`

**Akcja:** Wyekstrahowano 25 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:38] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/tanyt.lua`

**Akcja:** Wyekstrahowano 11 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:40] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/yoem.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:44] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/gamon.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:45] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/valentina.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:47] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/kjesse.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:33:49] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/buddel_tyrsung.lua`

**Akcja:** Wyekstrahowano 6 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:14] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/penny.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:18] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/edgar-ellen.lua`

**Akcja:** Wyekstrahowano 5 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:19] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/hawkhurst_ingol.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:22] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/elf_guard.lua`

**Akcja:** Wyekstrahowano 8 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:25] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/amanda.lua`

**Akcja:** Wyekstrahowano 33 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:28] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/yberius.lua`

**Akcja:** Wyekstrahowano 30 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:29] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/jack_drone.lua`

**Akcja:** Wyekstrahowano 5 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:32] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/billy.lua`

**Akcja:** Wyekstrahowano 52 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:35] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/pydar.lua`

**Akcja:** Wyekstrahowano 33 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:36] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/eliyas.lua`

**Akcja:** Wyekstrahowano 3 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:47] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/harlow_vengoth.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/ferryman_kamil.lua`

**Akcja:** Wyekstrahowano 2 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:51] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_sinbeard.lua`

**Akcja:** Wyekstrahowano 23 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:53] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/romella.lua`

**Akcja:** Wyekstrahowano 9 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:54] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/pino.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:55] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/chemar.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:57] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/luna.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:58] MIGRACJA LUA

### Plik: `data-otservbr-global/npc/olrik.lua`

**Akcja:** Zmigrowano 3 stringów

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:35:59] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/rapanaio_boat.lua`

**Akcja:** Wyekstrahowano 4 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:36:01] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/captain_greyhound.lua`

**Akcja:** Wyekstrahowano 27 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:37:48] EKSTRAKCJA LUA

### Plik: `data-otservbr-global/npc/urks_the_mute.lua`

**Akcja:** Wyekstrahowano 1 kluczy

**Szczegóły:**
Kategoria: npc

---

## [2025-12-10 04:40:30] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:40:33] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:42:35] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:42:36] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:44:37] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:44:39] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:46:40] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:46:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:48:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:48:47] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:50:44] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:50:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:52:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:52:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:55:00] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:55:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53386

---

## [2025-12-10 04:56:59] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:57:01] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53391

---

## [2025-12-10 04:59:06] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 04:59:08] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53391

---

## [2025-12-10 05:03:28] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:03:31] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:05:26] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:05:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:07:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:07:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:09:22] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:09:24] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:11:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:11:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:13:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:13:21] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:15:23] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:15:25] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:17:20] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:17:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:19:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:19:26] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:21:27] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:21:29] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:23:31] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:23:32] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:25:44] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:25:46] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:28:10] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:28:13] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:30:49] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:30:51] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:33:24] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:33:27] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:36:03] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:36:06] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:38:39] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:38:42] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53399

---

## [2025-12-10 05:41:19] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:41:22] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53414

---

## [2025-12-10 05:43:45] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:43:48] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53414

---

## [2025-12-10 05:45:52] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:45:54] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53414

---

## [2025-12-10 05:47:56] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:47:58] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 53414

---

## [2025-12-10 05:50:01] ANALIZA KONFLIKTÓW

### Plik: `Cały projekt`

**Akcja:** Znaleziono 50 konfliktów

**Szczegóły:**
Duplikaty, błędy składni, brakujące tłumaczenia

---

## [2025-12-10 05:50:03] WALIDACJA STRUKTURY

### Plik: `Cały projekt`

**Akcja:** Lua: 11085, C++: 186, PHP: 5587

**Szczegóły:**
Klucze i18n: 40200

---
