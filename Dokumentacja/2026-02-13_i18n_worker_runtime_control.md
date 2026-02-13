# Worker Runtime Control — System sterowania w locie

**Data:** 2026-02-13  
**Plik:** `i18n_worker_simple.sh`, `worker_config.json`

---

## Cele

Worker i18n działa 24/7. Bez restartowania można:
- Przełączać język na którym operuje (FOCUS/UNFOCUS)
- Testować poszczególne języki (TEST/TEST_ALL)
- Włączać/wyłączać Google Translate (GT:on/off)
- Zmieniać batch size (BATCH:N)
- Pauzować/wznawiać (paused=true/false w config)
- Wyświetlać status (REPORT, CONFIG, LANGS)

## Sposoby sterowania

### 1. Plik `.worker_command` (jednorazowy)
```bash
echo "FOCUS:de" > .worker_command
echo "TEST:pl" > .worker_command
echo "GT:on" > .worker_command
```
Worker odczyta i usunie plik w następnym cyklu.

### 2. Plik `worker_commands.txt` (wieloliniowy)
Każda linia = jedna komenda. Po wykonaniu zostaje zakomentowana.

### 3. Plik `worker_config.json` (persystentny)
Edytuj ręcznie — worker wczytuje co cykl.
```json
{
  "focus_lang": "de",
  "use_gt": true,
  "translate_limit": 50,
  "parallel_langs": 3,
  "paused": false,
  "test_lang": "fr"
}
```

## Pełna lista komend runtime

| Komenda | Opis |
|---------|------|
| `FOCUS:<lang>[:json[:limit]]` | Skup się na jednym języku (persystentne) |
| `UNFOCUS` | Zdejmij focus, wróć do automatycznego round-robin |
| `TEST:<lang>` | Pełny test: translate + validate + crossref (1 cykl, potem stop) |
| `TEST_ALL` | Dodaj wszystkie 52 języki do kolejki testowej |
| `GT:on` / `GT:off` | Włącz/wyłącz Google Translate |
| `BATCH:<N>` | Ustaw translate_limit na N kluczy/cykl |
| `SET:<key>=<value>` | Zmień dowolną wartość w worker_config.json |
| `CONFIG` | Wyświetl aktualną konfigurację |
| `REPORT` | Generuj raport coverage wszystkich języków |
| `LANGS` | Lista dostępnych języków |
| `LANGVAL:all` / `LANGVAL:<lang>` | Wymuś walidację |
| `SPOTCHECK:<lang>[:N]` | Losowy audit N tłumaczeń |
| `SKIP` | Pomiń bieżący cykl |
| `PAUSE:<N>` | Pauza na N cykli |
| `IDLE` | Wymuś tryb IDLE |  
| `(komenda):ONCE` | Wykonaj i zakończ workera po cyklu |

## Klucze worker_config.json

| Klucz | Typ | Opis |
|-------|-----|------|
| `focus_lang` | string | Język do skupienia (pusty = auto) |
| `focus_category` | string | Kategoria JSON (pusty = auto) |
| `use_gt` | bool | Google Translate fallback |
| `gt_batch_size` | int | Batch GT (domyślnie 50) |
| `gt_delay` | float | Delay między batchami GT (sek) |
| `translate_limit` | int | Max kluczy/cykl (0 = adaptive) |
| `parallel_langs` | int | Ile języków na cykl (domyślnie 3) |
| `adaptive_batch` | bool | Adaptive batch tuning |
| `crossref_auto_fix` | bool | Auto-fix crossref |
| `crossref_auto_fix_limit` | int | Max auto-fix na język |
| `paused` | bool | Wstrzymaj workera |
| `test_lang` | string | Jednorazowy test języka |
| `test_all_langs_queue` | array | Kolejka języków do testowania |

## Typowe scenariusze

### Przetestowanie niemieckiego
```bash
echo "TEST:de" > .worker_command
```

### Skupienie na polskim z GT
```bash
echo "FOCUS:pl" > .worker_command
echo "GT:on" > .worker_command  
```

### Masowy test wszystkich języków
```bash
echo "TEST_ALL" > .worker_command
# Worker będzie testował po jednym języku na cykl
```

### Wstrzymanie workera
```bash
python3 -c "import json; d=json.load(open('worker_config.json')); d['paused']=True; json.dump(d,open('worker_config.json','w'),indent=2)"
```
