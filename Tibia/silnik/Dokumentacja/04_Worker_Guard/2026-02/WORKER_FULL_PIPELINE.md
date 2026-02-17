# 🤖 I18N Worker - Pełny Pipeline Automatyzacji

> **Dokument**: Szczegółowy plan autonomicznego workera i18n  
> **Wersja**: 2.0  
> **Data**: 2025-12-10  
> **Status**: PLANOWANIE (implementacja częściowo w `i18n_worker_simple.sh`)

### Mapowanie na aktualny skrypt (`i18n_worker_simple.sh`)
- Wejścia CLI: `--file`, `--auto`, `--continuous [--batch N --delay S]`, `--translate [lang]`, `--status/--stats`, `--update-status`.
- Tryby w dispatcherze continuous: `MIGRATION` (kategorie NPC/SCRIPTS/... 16+), `TRANSLATION_SYNC`, `AUTO_TRANSLATE`, `IDLE`.
- Pliki stanu: `i18n_file_status.json` (etapy), `.i18n_category_state.json` (backoff kategorii), `i18n_global_stats.json` (cykle), `worker_commands.txt`/`.worker_command` (sterowanie), backupy w `backups/`.
- Każdy cykl continuous wykonuje commit/push jeśli są zmiany (nazwa: `📊 I18N: <klucze> <tryb> - Cykl #N`).

---

## 📋 Wizja

Worker działa **autonomicznie** i sam decyduje co robić. Przetwarza pliki **etapami**, zapisując postęp każdego etapu. Może być przerwany i wznowiony w dowolnym momencie.

---

## 🗂️ System śledzenia postępu

### Plik stanu: `i18n_file_status.json`

```json
{
  "data-otservbr-global/npc/oldrak.lua": {
    "file_path": "data-otservbr-global/npc/oldrak.lua",
    "file_type": "npc",
    "file_hash": "a1b2c3d4...",
    "last_modified": "2025-12-10T05:00:00Z",
    
    "stages": {
      "1_started": {
        "status": "completed",
        "timestamp": "2025-12-10T05:01:00Z"
      },
      "2_analysis": {
        "status": "completed",
        "timestamp": "2025-12-10T05:01:05Z",
        "result": {
          "patterns_found": ["StdModule.say", "npcHandler:say"],
          "strings_count": 26,
          "related_files": ["data/npclib/npc_system/modules.lua"],
          "npc_name": "Oldrak",
          "npc_type": "quest_giver"
        }
      },
      "3_documentation": {
        "status": "completed",
        "timestamp": "2025-12-10T05:01:10Z",
        "doc_file": "docs/i18n/generated/npc/oldrak.md"
      },
      "4_transformation": {
        "status": "completed",
        "timestamp": "2025-12-10T05:01:15Z",
        "result": {
          "transformed": 26,
          "patterns": {
            "StdModule.say": 21,
            "npcHandler:say": 5
          }
        }
      },
      "5_extraction_en": {
        "status": "completed",
        "timestamp": "2025-12-10T05:01:20Z",
        "keys_added": 26,
        "json_file": "i18n/en/npc.json"
      },
      "6_translation": {
        "status": "in_progress",
        "timestamp": "2025-12-10T05:01:25Z",
        "languages_done": ["pl", "de", "es"],
        "languages_pending": ["fr", "it", "ru", "..."],
        "progress": "3/53"
      },
      "7_validation": {
        "status": "pending"
      },
      "8_sync": {
        "status": "pending"
      }
    },
    
    "overall_status": "in_progress",
    "overall_progress": "6/8",
    "errors": []
  }
}
```

---

## 📊 Etapy przetwarzania pliku

### ETAP 1: 🚀 STARTED (Rozpoczęcie)

**Co robi:**
- Rejestruje że zaczyna pracę nad plikiem
- Oblicza hash pliku (MD5/SHA256)
- Sprawdza czy plik się zmienił od ostatniego przetwarzania
- Tworzy backup pliku

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "file_hash": "abc123...",
  "backup_path": "backups/npc/oldrak.lua.bak"
}
```

---

### ETAP 2: 🔍 ANALYSIS (Analiza)

**Co robi:**
- Wykrywa typ pliku (NPC, quest, script, lib)
- Skanuje wzorce do migracji
- Liczy stringi do ekstrakcji
- Identyfikuje powiązane pliki
- Analizuje kontekst (nazwa NPC, typ questa, etc.)

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "result": {
    "patterns_found": ["StdModule.say", "npcHandler:say", "sendTextMessage"],
    "strings_count": 26,
    "strings_by_pattern": {
      "StdModule.say": 21,
      "npcHandler:say": 3,
      "sendTextMessage": 2
    },
    "related_files": [
      "data/npclib/npc_system/modules.lua",
      "data-otservbr-global/scripts/quests/demon_oak.lua"
    ],
    "context": {
      "npc_name": "Oldrak",
      "npc_type": "quest_giver",
      "location": "Plains of Havoc",
      "quests": ["Demon Oak Quest"],
      "keywords": ["job", "name", "monster", "demon oak", "axe"]
    }
  }
}
```

---

### ETAP 3: 📝 DOCUMENTATION (Dokumentacja)

**Co robi:**
- Generuje dokumentację dla pliku
- Opisuje co robi NPC/skrypt
- Listuje wszystkie dialogi/komunikaty
- Tworzy mapę kluczy i18n

**Generuje plik:** `docs/i18n/generated/npc/oldrak.md`

```markdown
# NPC: Oldrak

## Informacje podstawowe
- **Lokalizacja**: Plains of Havoc, Temple
- **Typ**: Quest Giver, Monk
- **Questy**: Demon Oak Quest

## Dialogi
| Słowo kluczowe | Klucz i18n | Tekst EN |
|----------------|------------|----------|
| job | npc.oldrak.job | "I guard this humble temple..." |
| name | npc.oldrak.name | "My name is Oldrak." |
| ...

## Powiązane pliki
- `scripts/quests/demon_oak.lua`
- `lib/quests/demon_oak_lib.lua`

## Historia zmian
- 2025-12-10: Migracja do i18n
```

---

### ETAP 4: 🔄 TRANSFORMATION (Transformacja kodu)

**Co robi:**
- Zamienia `text = "..."` na `i18nKey = "..."`
- Zamienia `npcHandler:say("...")` na `NPC_LIB.i18n.npcSay(...)`
- Zamienia `sendTextMessage(...)` na `sendLocalizedTextMessage(...)`
- Zachowuje formatowanie i wcięcia

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "result": {
    "transformed": 26,
    "by_pattern": {
      "StdModule.say → i18nKey": 21,
      "npcHandler:say → npcSay": 3,
      "sendTextMessage → sendLocalized": 2
    },
    "backup_created": true
  }
}
```

---

### ETAP 5: 📤 EXTRACTION_EN (Ekstrakcja do EN)

**Co robi:**
- Dodaje klucze do `i18n/en/{category}.json`
- Używa atomowych zapisów (flock + temp file)
- Weryfikuje że klucze zostały zapisane

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "keys_added": 26,
  "json_file": "i18n/en/npc.json",
  "keys": [
    "npc.oldrak.job",
    "npc.oldrak.name",
    "npc.oldrak.monster",
    "..."
  ]
}
```

---

### ETAP 6: 🌍 TRANSLATION (Tłumaczenie)

**Co robi:**
- Kopiuje klucze z EN do innych języków
- Opcjonalnie: używa API do automatycznego tłumaczenia
- Śledzi postęp dla każdego języka

**Lista języków (53):**
```
pl, de, es, pt, fr, it, ru, uk, zh, ja, ko, ar, tr, nl, sv, 
da, no, fi, cs, sk, hu, ro, bg, hr, sr, sl, et, lv, lt, 
el, he, th, vi, id, ms, tl, hi, bn, ta, te, mr, gu, kn, 
ml, pa, ur, fa, sw, am, zu, af, ca
```

**Zapisuje:**
```json
{
  "status": "in_progress",
  "timestamp": "...",
  "languages": {
    "pl": {"status": "completed", "keys": 26},
    "de": {"status": "completed", "keys": 26},
    "es": {"status": "pending"},
    "...": "..."
  },
  "progress": "2/53"
}
```

---

### ETAP 7: ✅ VALIDATION (Walidacja)

**Co robi:**
- Sprawdza składnię Lua (luac -p)
- Weryfikuje że wszystkie klucze istnieją w JSON
- Testuje parsowanie JSONów
- Opcjonalnie: uruchamia serwer testowo

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "result": {
    "lua_syntax": "ok",
    "keys_exist": true,
    "json_valid": true,
    "server_test": "skipped"
  }
}
```

---

### ETAP 8: 🔄 SYNC (Synchronizacja)

**Co robi:**
- Git commit zmian
- Opcjonalnie: git push
- Aktualizuje statystyki globalne
- Oznacza plik jako w pełni przetworzony

**Zapisuje:**
```json
{
  "status": "completed",
  "timestamp": "...",
  "git_commit": "abc123",
  "synced": true
}
```

---

## 🎮 Tryby pracy workera

### Tryb AUTO (domyślny)
```bash
./i18n_autonomous_worker.sh
```
Worker sam decyduje:
1. Szuka plików z niedokończonymi etapami
2. Kontynuuje od miejsca przerwania
3. Jeśli wszystko gotowe - szuka nowych plików
4. Priorytety: NPC → Scripts → Quests → Libs

### Tryb FOCUS
```bash
./i18n_autonomous_worker.sh --focus npc
./i18n_autonomous_worker.sh --focus scripts
./i18n_autonomous_worker.sh --focus quests
```
Pracuje tylko nad wybraną kategorią.

### Tryb FILE
```bash
./i18n_autonomous_worker.sh --file data-otservbr-global/npc/oldrak.lua
```
Przetwarza tylko wskazany plik (wszystkie etapy).

### Tryb STAGE
```bash
./i18n_autonomous_worker.sh --stage translation
```
Wykonuje tylko wskazany etap dla wszystkich plików które go potrzebują.

### Tryb RESUME
```bash
./i18n_autonomous_worker.sh --resume
```
Kontynuuje przerwane prace (domyślne zachowanie).

---

## 📁 Struktura katalogów

```
canary_test/
├── i18n_autonomous_worker.sh      # Główny skrypt
├── i18n_file_status.json          # Status wszystkich plików
├── i18n_global_stats.json         # Globalne statystyki
├── i18n_worker_log.txt            # Log działania
│
├── i18n/
│   ├── en/                        # Źródłowe klucze (angielski)
│   │   ├── npc.json
│   │   ├── quests.json
│   │   ├── scripts.json
│   │   └── system.json
│   │
│   ├── pl/                        # Polski
│   ├── de/                        # Niemiecki
│   ├── es/                        # Hiszpański
│   └── .../                       # 53 języki
│
├── docs/i18n/
│   ├── WORKER_FULL_PIPELINE.md    # Ten dokument
│   ├── WORKER_MIGRATION_PLAN.md   # Plan migracji wzorców
│   │
│   └── generated/                 # Auto-generowana dokumentacja
│       ├── npc/
│       │   ├── oldrak.md
│       │   ├── a_frog.md
│       │   └── ...
│       ├── quests/
│       └── scripts/
│
└── backups/                       # Backupy przed transformacją
    └── npc/
        ├── oldrak.lua.bak
        └── ...
```

---

## 📊 Globalne statystyki: `i18n_global_stats.json`

```json
{
  "last_updated": "2025-12-10T05:30:00Z",
  "total_files": {
    "npc": 1025,
    "scripts": 500,
    "quests": 200,
    "libs": 50
  },
  "processed_files": {
    "npc": 450,
    "scripts": 100,
    "quests": 50,
    "libs": 10
  },
  "total_keys": {
    "en": 15000,
    "pl": 15000,
    "de": 14500,
    "es": 14000
  },
  "stages_summary": {
    "1_started": 610,
    "2_analysis": 600,
    "3_documentation": 580,
    "4_transformation": 550,
    "5_extraction_en": 550,
    "6_translation": 400,
    "7_validation": 350,
    "8_sync": 300
  },
  "errors": {
    "total": 15,
    "by_stage": {
      "4_transformation": 10,
      "6_translation": 5
    }
  }
}
```

---

## 🔧 Komendy workera

| Komenda | Opis |
|---------|------|
| `--status` | Pokaż globalny status |
| `--status oldrak` | Status konkretnego pliku |
| `--focus npc` | Pracuj tylko nad NPC |
| `--file <path>` | Przetwórz jeden plik |
| `--stage <n>` | Wykonaj tylko etap N |
| `--resume` | Kontynuuj przerwane |
| `--reset <file>` | Resetuj status pliku |
| `--reset-all` | Resetuj wszystko |
| `--dry-run` | Symulacja bez zmian |
| `--verbose` | Szczegółowe logi |

---

## 🚦 Priorytety automatycznego wyboru

Gdy worker działa w trybie AUTO, wybiera pliki według priorytetów:

1. **Pliki z błędami** - najpierw napraw błędy
2. **Pliki w trakcie** - dokończ rozpoczęte
3. **NPC** - najważniejsze dla graczy
4. **Questy** - drugie najważniejsze
5. **Scripts** - komunikaty systemowe
6. **Libs** - biblioteki na końcu

W każdej kategorii: alfabetycznie lub według rozmiaru (małe najpierw).

---

## ⚠️ Obsługa błędów

### Błąd w transformacji
- Przywraca backup
- Zapisuje błąd w statusie
- Przechodzi do następnego pliku
- Raportuje na koniec

### Błąd w JSON
- Próbuje naprawić (json.tool)
- Jeśli nie da się - oznacza jako błąd
- Nie traci poprzednich kluczy

### Przerwanie workera
- Status zapisywany po każdej operacji
- Można wznowić w dowolnym momencie
- Atomowe zapisy (brak uszkodzeń)

---

## 📈 Raportowanie

### Dzienny raport (automatyczny)
```
=== I18N Worker Report: 2025-12-10 ===
Files processed: 50
Keys extracted: 1200
Translations done: 800
Errors: 2

Top errors:
1. oldrak.lua - transformation failed (regex)
2. ninev.lua - JSON write error

Next priority:
- 75 NPC files pending
- 30 quest files pending
```

### Raport na żądanie
```bash
./i18n_autonomous_worker.sh --report
./i18n_autonomous_worker.sh --report detailed
./i18n_autonomous_worker.sh --report errors
```

---

## 🔄 Integracja z Git

### Auto-commit (opcjonalnie)
```bash
# Po każdych 10 plikach
git add i18n/ data-otservbr-global/npc/
git commit -m "i18n: Migrate 10 NPC files (oldrak, ninev, ...)"
```

### Branch roboczy
```bash
git checkout -b i18n-migration
# ... praca workera ...
git checkout master
git merge i18n-migration
```

---

## 📝 TODO - Implementacja

- [ ] Utworzyć strukturę `i18n_file_status.json`
- [ ] Zaimplementować 8 etapów jako osobne funkcje
- [ ] Dodać obsługę argumentów CLI
- [ ] Zaimplementować tryby pracy
- [ ] Dodać system raportowania
- [ ] Testy na małej grupie plików
- [ ] Dokumentacja użytkownika

---

## 📚 Powiązane dokumenty

- `WORKER_MIGRATION_PLAN.md` - Wzorce transformacji
- `NPC_MIGRATION_STATUS.md` - Status migracji NPC
- `I18N_DEVELOPMENT_ROADMAP.md` - Ogólny plan rozwoju
