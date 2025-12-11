# Rozmowa nad workerem 2 - Plan integracji Hard Strings

## Data: 2025-12-11 ~22:50

## Status aktualny (podsumowanie)

### Serwer (canary_test)
- **Worker działa**: PID aktywny, tryb MIGRATION, kategoria `world`
- **i18n_file_status.json**: 96 plików z pełnymi metadanymi
- **i18n_processed_files.txt**: 416 plików
- **Funkcja `mark_file_completed()`**: ✅ NAPRAWIONA - zapisuje do obu źródeł

### NPC do migracji
- **431 plików NPC** w hard_strings.csv bez i18nKey (pełna lista)
- **39 NPC** z literalnymi dialogami (`npcHandler:say`) bez i18nKey (wg audytu Agenta 1)
- Różnica: 431 vs 39 - prawdopodobnie 392 NPC mają stringi ale NIE mają handlerów say (np. tylko nazwa/opis)
- Przykłady: `a_beautiful_girl.lua`, `a_beggar.lua`, `a_behemoth.lua`, `abran_ironeye.lua`, etc.

### Hard strings reports (istniejące)
- `docs/i18n/generated/hard_strings.csv`: **24205 wpisów** (serwer)
- `docs/i18n/generated/testyy_hard_strings.csv`: **51254 wpisów** (klient - głównie już przetłumaczone locales)

### Podział hard_strings serwera (24205 wpisów):
| Kategoria | Wpisów | Priorytet |
|-----------|--------|-----------|
| NPC | 14262 | 🔴 WYSOKI |
| scripts/lib | 2339 | 🟡 ŚREDNI |
| spells/monster | 816 | 🟢 NISKI |
| talkactions/god | 480 | 🟢 NISKI |
| actions/items | 398 | 🟡 ŚREDNI |
| creaturescripts | 363 | 🟡 ŚREDNI |
| spells/attack | 283 | 🟢 NISKI |
| quests/* | ~1500 | 🟡 ŚREDNI |
| inne | ~3764 | 🟢 NISKI |

## 🔍 KLUCZOWE ODKRYCIE

### Problem: 71 NPC częściowo zmigrowanych!
Worker migruje część dialogów ale NIE wszystkie. Pliki mają:
- `NPC_LIB.i18n.npcSay(...)` - zmigrowane dialogi ✅
- `npcHandler:say("...")` - niezmigrowane dialogi ❌

**Przykład** (`a_prisoner.lua`):
```lua
-- ZMIGROWANE:
NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_1")

-- NIEZMIGROWANE:
npcHandler:say("Great riddle, isn't it? ...", npc, creature)
```

### Przyczyna
Worker wykrywa wzorzec i migruje JEDEN dialog, oznacza plik jako "przetworzony" i idzie dalej.
Nie wraca do pliku żeby zmigrować pozostałe dialogi.

### Rozwiązanie
1. Zmienić logikę workera: nie oznaczaj pliku jako "completed" jeśli nadal ma `npcHandler:say("...")`
2. Lub dodać tryb "deep migration" który przetwarza WSZYSTKIE dialogi w pliku

---

## 📊 AKTUALNA STATYSTYKA NPC

| Kategoria | Plików | Status |
|-----------|--------|--------|
| W pełni zmigrowane | ~555 | ✅ Gotowe |
| Częściowo zmigrowane | 71 | ⚠️ DO NAPRAWY |
| Bez dialogów (tylko nazwa) | ~400 | ℹ️ Nie wymaga migracji say |
| **RAZEM NPC** | ~1026 | |

---

### Źródło danych (IDLE scan)
1. Włączyć `hard_strings_report.py` jako krok IDLE (raz na dobę lub przy zmianach)
2. Output do:
   - `docs/i18n/generated/testyy_hard_strings.{csv,md}` 
   - `i18n/hard_strings_status.json` (JSON ze statusem)
3. JSON zawiera: plik, kategoria (npc/items/client), liczba stringów, timestamp

### Integracja z kolejką/migracją
1. Każdy wpis z `hard_strings_status.json` zasila `translation_queue` lub osobną kolejkę "hard_strings"
2. Deduplikacja po ścieżce/hash treści
3. Dispatcher w MIGRATION sprawdza czy plik jest w kolejce hard_strings
4. Ignore-lista/filtry dla false-positive (URL, ścieżki, kody)

### Status/monitoring
1. Update I18N_STATUS.md: sekcja "Hard-coded strings"
   - Liczba plików/wpisów per kategoria
   - Trend (ile do zrobienia, ile przerobionych)
2. Dodać do `i18n_global_stats.json`:
   - `hard_strings_pending`
   - `hard_strings_processed`
   - `last_hard_scan`
   - `last_hard_file`
3. LIVE box: jeśli MIGRATION pracuje nad wpisem z hard_strings, pokazać "Kategoria: hard_strings/<plik>"

---

## Plan szczegółowy (do wykonania)

### FAZA 1: Struktura danych hard_strings

**Plik**: `i18n/hard_strings_status.json`
```json
{
  "last_scan": "2025-12-11T22:50:00",
  "scan_source": "server",  // "server" lub "client"
  "total_entries": 24205,
  "categories": {
    "npc": {"total": 5000, "migrated": 4500, "pending": 500},
    "scripts": {"total": 1000, "migrated": 800, "pending": 200},
    "items": {"total": 13000, "migrated": 0, "pending": 13000},
    "client": {"total": 51254, "migrated": 0, "pending": 51254}
  },
  "files": {
    "data-otservbr-global/npc/a_bearded_woman.lua": {
      "strings_count": 20,
      "migrated": true,
      "last_update": "2025-12-11T22:00:00"
    }
  }
}
```

### FAZA 2: Funkcja skanująca w workerze

**Nowa funkcja**: `scan_hard_strings()`
- Uruchamiana w trybie IDLE lub jako osobny cykl
- Skanuje: `data-*/npc/*.lua`, `data-*/scripts/**/*.lua`, `data/items/*.xml`
- Zapisuje wyniki do `i18n/hard_strings_status.json`
- Aktualizuje `i18n_global_stats.json`

### FAZA 3: Integracja z Dispatcherem

**Modyfikacja dispatchera** (linie ~5300-5400):
```python
# Po sprawdzeniu normalnych kategorii
if all_categories_skipped:
    # Sprawdź hard_strings_status.json
    hard_strings = load_hard_strings_status()
    pending_files = [f for f, info in hard_strings["files"].items() if not info["migrated"]]
    if pending_files:
        print(f"MIGRATION:hard_strings:{len(pending_files)}")
        exit(0)
```

### FAZA 4: Sekcja w I18N_STATUS.md

**Nowa sekcja** (po "📊 Globalny Postęp"):
```markdown
## 🔍 Hard-coded Strings

| Źródło | Plików | Wpisów | Zmigrowane | Pending |
|--------|--------|--------|------------|---------|
| 🖥️ Server | 500 | 24205 | 20000 | 4205 |
| 💻 Client | 1000 | 51254 | 0 | 51254 |

### Ostatni skan
- Server: 2025-12-11 22:50
- Client: 2025-12-11 22:47
```

### FAZA 5: Ignore-lista

**Plik**: `i18n/hard_strings_ignore.txt`
```
# Ignorowane wzorce (regex)
^https?://
^/
^\d+$
^[A-Z_]+$
\.lua$
\.xml$
```

---

## Podział zadań

### Agent 2 (obecny) - IMPLEMENTACJA W WORKERZE
- [ ] Dodać strukturę `i18n/hard_strings_status.json`
- [ ] Stworzyć funkcję `scan_hard_strings()` w workerze
- [ ] Zintegrować z dispatcherem (MIGRATION:hard_strings)
- [ ] Dodać sekcję "Hard-coded Strings" do I18N_STATUS.md
- [ ] Dodać pola do `i18n_global_stats.json`

### Agent 1 - AUDYT I RAPORTY
- [ ] Zweryfikować 39 NPC do migracji (lista konkretnych plików)
- [ ] Uruchomić hard_strings_report na testyy (jeśli nie było)
- [ ] Stworzyć ignore-listę dla false-positive
- [ ] Przygotować baseline dla client hard_strings

---

## Pytania wymagające odpowiedzi

1. **Gdzie jest testyy?** - ✅ ZNALEZIONE: `/home/ptaku/serweryt/Tibia/silnik/canary_test/testyy` - to jest **OTClient** (klient gry)
2. **Hard strings report dla client** - 51254 wpisów to głównie pliki `data/locales/*.lua` (już przetłumaczone!) - system `tr()` w kliencie
3. **Priorytet** - czy najpierw 39 NPC serwera czy hard_strings z client?
4. **Ignore-lista** - jakie wzorce mam ignorować? (URL, komendy, ścieżki?)

### WAŻNE ODKRYCIE:
- **testyy** = OTClient (klient gry Tibia)
- **canary_test** = Canary Server (serwer gry)
- Hard strings z testyy (51254) to głównie **już istniejące tłumaczenia** w `data/locales/`
- Klient używa systemu `tr("tekst")` który jest już zaimplementowany
- **Prawdziwa praca** to 39 NPC na serwerze bez i18nKey

### Struktura testyy (OTClient):
```
testyy/
├── data/
│   └── locales/     # <- Tłumaczenia klienta (af.lua, pl.lua, de.lua, etc.)
├── modules/         # <- UI klienta (game_store, game_viplist, etc.)
├── src/             # <- Kod C++ klienta
└── otclient         # <- Executable
```

---

## Log działań

| Data | Agent | Akcja |
|------|-------|-------|
| 2025-12-11 22:50 | Agent 2 | Utworzenie tego pliku z planem |
| 2025-12-11 23:00 | Agent 2 | Analiza hard_strings.csv - 24205 wpisów serwera, 51254 klienta |
| 2025-12-11 23:05 | Agent 2 | Znalezienie testyy = OTClient w canary_test/testyy |
| 2025-12-11 23:10 | Agent 2 | **KLUCZOWE ODKRYCIE**: 71 NPC częściowo zmigrowanych (mają i18n + literały) |
| | | |

---

## 📋 LISTA 71 CZĘŚCIOWO ZMIGROWANYCH NPC

```
a_dead_bureaucrat1    gnomally           lokur
a_dead_bureaucrat3    gnomargery         lynda
albinius              gnombold           maeryn
alexander             gnomerik           miraia
angus                 gnomilly           nilsor
arkulius              gnomission         ninos
asima                 gnomus             nokmir
benjamin              grizzly_adams      ocelus
captain_dreadnought   halvar             oldrak
cassino               hamish             olrik
charos                henricus           paulie
chrystal              hireling           plunderpurse
cledwyn               hjaern             rabaz
daniel_steelsoul      imbuement_assistant rachel
dove                  inkaef             richard
duncan                jeronimo           ruprecht
eruaran               jorge              sandomo
fenech                khanna             spectulus
frosty                klom_stonecutter   storkus
gnomadness            kroox              sven
                      lardoc_bashsmite   the_oracle
                      liane              the_orc_king
                                         topsy
                                         vascalir
                                         walter_jaeger
                                         wentworth
                                         xodet
                                         yana
                                         zebron
```

---

## Notatki techniczne

### Jak działa mark_file_completed()
```bash
mark_file_completed() {
    local file="$1"
    local category="$2"
    local keys_added="${3:-0}"
    
    # 1. Dodaj do processed_files.txt
    echo "$file" >> "$PROCESSED_FILE"
    
    # 2. Dodaj do i18n_file_status.json
    python3 << PYMARK
    # ... aktualizuje JSON z metadanymi
    PYMARK
}
```

### Jak działa dispatcher (uproszczony)
```python
# Dla każdej kategorii sprawdź:
for cat_name, config in sorted_cats:
    needs_work = count_files_needing_work(cat_name)
    if needs_work > 0:
        print(f"MIGRATION:{cat_name}:{needs_work}")
        exit(0)

# Jeśli wszystkie na skip:
if pending_skip:
    print(f"MIGRATION:pending_skip:{total_needs}:WAIT")
```

---

## Następne kroki

Po ustaleniu odpowiedzi na pytania, zaczynam od:

1. **Struktura JSON** - stworzenie `i18n/hard_strings_status.json`
2. **Funkcja scan** - dodanie `scan_hard_strings()` do workera
3. **Integracja** - połączenie z dispatcherem
4. **Status** - aktualizacja I18N_STATUS.md

---

## 🎯 KONKRETNY PLAN AKCJI

### Etap 1: Migracja 431 NPC (PRIORYTET)
**Problem:** 431 plików NPC ma hard-coded stringi bez i18nKey
**Rozwiązanie:** 
1. Worker w trybie MIGRATION już przetwarza NPC
2. Trzeba sprawdzić dlaczego pomija te 431 plików
3. Możliwe przyczyny:
   - NPC nie mają handlerów `say` (tylko nazwa/opis)
   - Pattern matching nie łapie wszystkich wzorców
   - Pliki są w `PROCESSED_FILE` ale bez faktycznej migracji

### Etap 2: Integracja hard_strings z workerem
1. Parsować `hard_strings.csv` do JSON
2. Porównywać z `i18n_file_status.json`
3. Znaleźć pliki które są w hard_strings ale nie w file_status

### Etap 3: Priorytetyzacja
1. **Faza A**: 39 NPC z handlerami say (dialogi)
2. **Faza B**: 392 NPC bez handlerów say (nazwy/opisy)
3. **Faza C**: scripts/lib (2339 wpisów)
4. **Faza D**: quests (1500 wpisów)

---

## 📋 ZADANIA DO WYKONANIA

### Agent 2 (obecny):
- [x] Analiza struktury hard_strings.csv
- [x] Identyfikacja 431 NPC bez i18nKey
- [x] Znalezienie testyy (OTClient)
- [x] Sprawdzić dlaczego worker pomija 431 NPC → **ZNALEZIONO: 71 częściowo zmigrowanych!**
- [ ] Naprawić logikę workera - nie oznaczać pliku jako "completed" jeśli ma jeszcze niezmigrowane dialogi
- [ ] Dodać tryb "deep migration" dla NPC
- [ ] Dodać logikę hard_strings do dispatchera
- [ ] Stworzyć sekcję "Hard-coded Strings" w I18N_STATUS.md

### Agent 1:
- [ ] Zweryfikować listę 71 NPC częściowo zmigrowanych
- [ ] Sprawdzić czy hard_strings.csv jest aktualny
- [ ] Przygotować ignore-listę dla false-positive

---

*Ten plik będzie aktualizowany przez obu agentów podczas pracy.*
