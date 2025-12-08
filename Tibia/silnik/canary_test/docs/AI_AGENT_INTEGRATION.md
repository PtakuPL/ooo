# 🤖 AI Agent Integration Guide

> Przewodnik integracji dla Codex, Copilot i innych AI agentów

---

## 📋 Przegląd systemu

System i18n został zaprojektowany z myślą o współpracy z AI agentami:

```
┌────────────────────────────────────────────────────────────────────┐
│                    I18N WORKER ECOSYSTEM                          │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │   Worker    │    │  Guardian   │    │   AI Agent  │            │
│  │   v4.0      │◄──►│   v2.0      │◄──►│ (Codex etc) │            │
│  └─────────────┘    └─────────────┘    └─────────────┘            │
│         │                 │                  │                     │
│         ▼                 ▼                  ▼                     │
│  ┌───────────────────────────────────────────────────────────┐    │
│  │                  i18n/status/                              │    │
│  │  ├── worker_state.json     (main status)                   │    │
│  │  └── categories/                                           │    │
│  │      ├── npc_details.json                                  │    │
│  │      ├── scripts_details.json                              │    │
│  │      ├── items_details.json                                │    │
│  │      ├── monsters_details.json                             │    │
│  │      └── server_details.json                               │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Dla AI Agentów - Jak pomagać

### 1. Sprawdzenie aktualnego stanu

```bash
# Odczytaj główny status
cat i18n/status/worker_state.json | jq '.'

# Sprawdź która kategoria jest aktywna
cat i18n/status/worker_state.json | jq '.categories | to_entries[] | select(.value.status == "in_progress")'

# Sprawdź postęp konkretnej kategorii
cat i18n/status/categories/scripts_details.json | jq '.summary'
```

### 2. Walidacja tłumaczeń

```bash
# Sprawdź poprawność JSON
jq '.' i18n/en/npc.json > /dev/null && echo "OK" || echo "BŁĄD JSON"

# Sprawdź składnię Lua
lua -e 'dofile("data-otservbr-global/npc/rashid.lua")'

# Porównaj klucze między językami
diff <(jq -r 'keys[]' i18n/en/npc.json | sort) <(jq -r 'keys[]' i18n/pl/npc.json | sort)
```

### 3. Sugerowanie poprawek

Gdy znajdziesz problem:
1. Sprawdź plik JSON kategorii
2. Zidentyfikuj problematyczny klucz
3. Zaproponuj poprawkę

**Przykład:**
```json
// Znaleziono błąd w i18n/en/npc.json
{
  "npc.rashid.greeting": "Helo adventurer!"  // błąd: "Hello"
}

// Sugerowana poprawka:
{
  "npc.rashid.greeting": "Hello adventurer!"
}
```

---

## 📊 Struktura danych

### worker_state.json (główny plik)

```json
{
  "schema_version": "2.0",
  "worker": {
    "version": "4.0",
    "status": "running",      // running | stopped | error
    "mode": "migration",
    "cycle": 1
  },
  "global_progress": {
    "total_files_processed": 877,
    "total_keys": 44449,
    "total_languages": 53
  },
  "categories": {
    "npc": { "status": "completed", ... },
    "scripts": { "status": "in_progress", ... },
    "items": { "status": "completed", ... },
    "monsters": { "status": "pending", ... }
  },
  "ai_instructions": {
    "for_codex": "...",
    "for_copilot": "...",
    "help_areas": [...]
  }
}
```

### categories/*.json (szczegóły kategorii)

```json
{
  "category": "scripts",
  "display_name": "📜 Lua Scripts",
  "status": "in_progress",
  
  "summary": {
    "total_files": 2500,
    "files_processed": 150,
    "completion_percent": 6.0
  },
  
  "current_work": {
    "directory": "data-otservbr-global/scripts/quests/",
    "files_in_queue": 50,
    "processing_speed": "10 files/cycle"
  },
  
  "subdirectories": {
    "quests/": { "total": 800, "processed": 100 },
    "actions/": { "total": 500, "processed": 30 }
  },
  
  "recent_files": [...],
  
  "ai_notes": {
    "review_needed": false,
    "quality_score": 90,
    "help_wanted": [
      "Review quest dialog translations"
    ]
  }
}
```

---

## 🎯 Zadania dla AI Agentów

### Priorytet 1: Walidacja
- [ ] Sprawdź poprawność wszystkich plików JSON
- [ ] Zweryfikuj składnię Lua w zmodyfikowanych plikach
- [ ] Znajdź brakujące tłumaczenia

### Priorytet 2: Review
- [ ] Przejrzyj ostatnio dodane klucze
- [ ] Sprawdź spójność tłumaczeń
- [ ] Zidentyfikuj literówki

### Priorytet 3: Sugestie
- [ ] Zaproponuj lepsze tłumaczenia
- [ ] Zgłoś problematyczne wzorce
- [ ] Zoptymalizuj klucze i18n

---

## 📝 Jak raportować problemy

### Format issue na GitHub:

```markdown
## 🐛 Problem z i18n

**Kategoria:** scripts
**Plik:** data-otservbr-global/scripts/quests/example.lua
**Klucz:** scripts.quests.example.dialog_1

**Problem:**
Błędne tłumaczenie / literówka / brakujący klucz

**Aktualna wartość:**
"Helo adventurer!"

**Sugerowana poprawka:**
"Hello adventurer!"

**Wykryto przez:** AI Agent (Codex/Copilot/Claude)
```

---

## 🔄 Workflow współpracy

```
┌──────────────────────────────────────────────────────────────┐
│                      AI AGENT WORKFLOW                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. FETCH STATUS                                             │
│     └─► cat i18n/status/worker_state.json                    │
│                                                              │
│  2. IDENTIFY ACTIVE CATEGORY                                 │
│     └─► Sprawdź: categories[x].status == "in_progress"       │
│                                                              │
│  3. READ CATEGORY DETAILS                                    │
│     └─► cat i18n/status/categories/{category}_details.json   │
│                                                              │
│  4. CHECK RECENT FILES                                       │
│     └─► recent_files[] - ostatnio przetworzone               │
│                                                              │
│  5. VALIDATE                                                 │
│     └─► jq, lua -e, diff                                     │
│                                                              │
│  6. REPORT / SUGGEST                                         │
│     └─► GitHub Issue / PR / komentarz                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Narzędzia pomocnicze

### Skrypty dla AI

```bash
# Sprawdź wszystkie JSON na błędy
for f in i18n/en/*.json; do jq '.' "$f" > /dev/null || echo "BŁĄD: $f"; done

# Znajdź puste tłumaczenia
jq -r 'to_entries[] | select(.value == "") | .key' i18n/en/npc.json

# Policz klucze per kategoria
for f in i18n/en/*.json; do echo "$f: $(jq 'length' "$f")"; done

# Porównaj języki
diff <(jq -r 'keys[]' i18n/en/npc.json) <(jq -r 'keys[]' i18n/de/npc.json)
```

---

## 📞 Kontakt

- **Worker log:** `work_i18n_live.log`
- **Guardian log:** `/tmp/i18n_guardian.log`
- **Repository:** https://github.com/PtakuPL/ooo
- **Status page:** `I18N_STATUS.md`

---

*Wersja dokumentu: 1.0*
*Ostatnia aktualizacja: 2025-12-08*
