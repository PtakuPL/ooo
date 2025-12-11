# Rozmowa nad workerem 2 - Plan integracji Hard Strings

## Data: 2025-12-11 ~22:50

## Status aktualny (podsumowanie)

### Serwer (canary_test)
- **Worker działa**: PID aktywny, tryb MIGRATION, kategoria `world`
- **i18n_file_status.json**: 96 plików z pełnymi metadanymi
- **i18n_processed_files.txt**: 416 plików
- **Funkcja `mark_file_completed()`**: ✅ NAPRAWIONA - zapisuje do obu źródeł

### NPC do migracji
- **39 NPC** z literalnymi dialogami bez i18nKey (wg audytu Agenta 1)
- Przykłady: `a_prisoner.lua`, `alaistar.lua`, `angus.lua`, `asima.lua`, etc.
- **3 NPC znalezione lokalnie**: `grizzly_adams.lua`, `ruprecht.lua`, `the_oracle.lua`

### Hard strings reports (istniejące)
- `docs/i18n/generated/hard_strings.csv`: **24205 wpisów** (serwer)
- `docs/i18n/generated/testyy_hard_strings.csv`: **51254 wpisów** (instalka)

---

## Co ustalił Agent 1 (plan do wdrożenia)

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
| | | |

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

*Ten plik będzie aktualizowany przez obu agentów podczas pracy.*
