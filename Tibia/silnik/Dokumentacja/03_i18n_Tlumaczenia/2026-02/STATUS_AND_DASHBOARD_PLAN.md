# 📊 Status & Dashboard — Plan integracji (Worker → JSON → I18N_STATUS.md)

**Data:** 2025-12-15  
**Cel:** Zrobić status workera maksymalnie czytelny i „prawdziwy”, tak aby:
- widać było **co robi teraz** (LIVE) na poziomie fazy/etapu/kategorii/pliku,
- było widać **co zrobił dziś** (daily summary) i co zostało zrobione w ostatnich cyklach,
- każda faza/etap miał własne, spójne metryki i był widoczny we wszystkich kategoriach.

---

## 0) Stan wdrożenia (w repo)

Zaimplementowane (pierwszy, minimalny pion):
- `tools/i18n_status.py` zapisuje: `activity.json`, `ops.jsonl`, `errors.jsonl`, `daily/YYYY-MM-DD.json`.
- `i18n_worker_simple.sh` aktualizuje LIVE w pętli `--continuous`:
  - snapshot `cycle_start`/`cycle_end`,
  - snapshot per plik dla `MIGRATION` w kategoriach `npc` i `scripts`,
  - log `ops` po zakończeniu kategorii (z delta: `keys_added`, `files_changed`).
- Generator `I18N_STATUS.md` preferuje nowe źródła:
  - **LIVE** z `i18n/status/activity.json` (fallback: `i18n_global_stats.json`),
  - **Dziś (UTC)** z `i18n/status/daily/YYYY-MM-DD.json`.

---

## 1) Zasady projektu statusu

1. **Jedno źródło prawdy (machine-readable):** JSON w `i18n/status/`.
2. **Dashboard dla ludzi:** `I18N_STATUS.md` generowany wyłącznie z JSON.
3. **Heartbeat:** worker zapisuje aktualizację co krok/etap; brak heartbeat = dashboard pokazuje „stale”.
4. **Event log (append-only):** wszystkie istotne działania jako zdarzenia (JSONL), żeby dało się zrobić dzienne podsumowanie bez zgadywania.
5. **Kompatybilność wsteczna:** istniejące pliki `i18n_worker_state.json` i `.i18n_category_state.json` pozostają, ale w planie traktujemy je jako „legacy/compat” lub źródło wejściowe do budowy nowego JSON.

---

## 2) Struktura plików statusu (docelowa)

```
canary_test/
└── i18n/
    └── status/
        ├── worker_state.json          # główny stan (LIVE + global)
        ├── activity.json              # szybki snapshot LIVE (UI-friendly)
        ├── categories/
        │   ├── npc.json
        │   ├── scripts.json
        │   ├── monsters.json
        │   ├── items.json
        │   ├── php.json
        │   └── ...
        ├── daily/
        │   ├── 2025-12-15.json        # sumarycznie per dzień
        │   └── ...
        ├── ops.jsonl                  # dziennik zdarzeń (append-only)
        └── errors.jsonl               # błędy/wyjątki (append-only)
```

**Dlaczego `activity.json` osobno?**
- bo jest lekki, czytelny, i pozwala „LIVE” aktualizować nawet gdy reszta danych jest chwilowo niekompletna.

---

## 3) Schema: worker_state.json (minimum)

```json
{
  "schema_version": "3.0",
  "generated_at_utc": "2025-12-15T12:34:56Z",
  "worker": {
    "name": "i18n_worker_simple.sh",
    "version": "2.x",
    "pid": 12345,
    "host": "linux",
    "status": "running",            
    "mode": "continuous",
    "cycle": 27,
    "cycle_started_at_utc": "2025-12-15T12:30:00Z",
    "heartbeat_at_utc": "2025-12-15T12:34:56Z",
    "current": {
      "phase": "MIGRATION|COMPACT_KEYS|TRANSLATION_SYNC|AUTO_TRANSLATE|IDLE",
      "stage": "MIGRATION:SCAN|EXTRACT|TRANSFORM|VALIDATE|WRITE_JSON|...",
      "category": "npc",
      "file": "data-otservbr-global/npc/rashid.lua",
      "detail": "Migracja npcHandler:say → NPC_LIB.i18n.npcSay",
      "progress": {
        "done": 7,
        "total": 50,
        "unit": "files"
      },
      "eta_seconds": 120
    }
  },
  "global": {
    "languages_total": 53,
    "en_keys_total": 28967,
    "files_processed_total": 812,
    "errors_total": 0
  },
  "phases": {
    "MIGRATION": { "last_cycle": 27, "active": true },
    "COMPACT_KEYS": { "last_cycle": 26, "active": false },
    "TRANSLATION_SYNC": { "last_cycle": 25, "active": false },
    "AUTO_TRANSLATE": { "last_cycle": 24, "active": false }
  },
  "categories": {
    "npc": {
      "status": "in_progress|completed|backoff|idle|error",
      "priority": 1,
      "backoff": { "skip_until_utc": null, "consecutive_zeros": 0 },
      "counts": {
        "files_total": 1026,
        "files_done": 318,
        "remaining": 0,
        "en_keys": 5253
      },
      "last": {
        "file": "...",
        "updated_at_utc": "...",
        "delta": { "keys_added": 3, "files_migrated": 1 }
      }
    }
  },
  "translation": {
    "sync": { "last_lang": "pl", "keys_added": 10, "placeholders_added": 10 },
    "auto": { "langs_active": ["pl"], "translated": 10, "skipped": 0 }
  },
  "compact_keys": {
    "enabled": true,
    "min_length": 2,
    "max_length": 7,
    "alphabet": "base62",
    "mapped_keys": 28967,
    "en_keys_total": 28967,
    "next_id": 28968,
    "last_export": { "langs": ["en","pl"], "updated_at_utc": "..." }
  }
}
```

**Uwaga:** `phase` i `stage` muszą być rozdzielone — `phase` mówi „co”, `stage` mówi „jaki krok”.

---

## 4) Schema: activity.json (LIVE snapshot)

```json
{
  "generated_at_utc": "2025-12-15T12:34:56Z",
  "status": "running|idle|error",
  "cycle": 27,
  "phase": "MIGRATION",
  "stage": "VALIDATE",
  "category": "npc",
  "file": "data-otservbr-global/npc/rashid.lua",
  "message": "Walidacja Lua: OK",
  "progress": { "done": 7, "total": 50, "unit": "files" },
  "rates": { "avg_seconds_per_file": 4.1 },
  "eta_seconds": 120,
  "recent": [
    { "t": "2025-12-15T12:34:10Z", "phase": "MIGRATION", "category": "npc", "action": "transform", "file": "...", "result": "ok" },
    { "t": "2025-12-15T12:34:20Z", "phase": "MIGRATION", "category": "npc", "action": "write_json", "result": "ok" }
  ]
}
```

To jest jedyny plik, z którego sekcja „🔴 LIVE” w `I18N_STATUS.md` bierze dane.

---

## 5) Event log: ops.jsonl / errors.jsonl

### 5.1 ops.jsonl (zdarzenia)
Każdy etap powinien emitować zdarzenie:

```json
{"t":"2025-12-15T12:34:20Z","cycle":27,"phase":"MIGRATION","stage":"WRITE_JSON","category":"npc","file":"...","delta":{"keys_added":3,"files_migrated":1},"result":"ok"}
```

Minimalne pola: `t`, `cycle`, `phase`, `stage`, `category`, `result`.

### 5.2 errors.jsonl (błędy)
```json
{"t":"2025-12-15T12:35:00Z","cycle":27,"phase":"MIGRATION","stage":"VALIDATE","category":"npc","file":"...","error":"Lua syntax error","action":"skipped"}
```

---

## 6) Daily summary: i18n/status/daily/YYYY-MM-DD.json

**Cel:** 100% pewne odpowiedzi na „co zrobił dziś”.

Przykład:
```json
{
  "date": "2025-12-15",
  "cycles": 12,
  "work": {
    "migration": { "files_changed": 18, "keys_added": 142, "categories_touched": ["npc","scripts"] },
    "translation_sync": { "langs": { "pl": {"keys_added": 10}, "ru": {"keys_added": 10} } },
    "auto_translate": { "langs": { "pl": {"translated": 10, "skipped": 0} } },
    "compact_keys": { "mapped_new": 250, "exported_langs": ["en","pl"] }
  },
  "errors": { "count": 0 }
}
```

**Źródło danych:** agregacja z `ops.jsonl` + `errors.jsonl`.

---

## 7) I18N_STATUS.md — wymagania treści (co musi być widoczne)

### 7.1 Sekcja globalna
- `Aktualizacja`, `Cykl`, `Status`, `Tryb`, `Faza`, `Etap`, `Kategoria`, `Plik`, `ETA`, `Heartbeat`.
- Ostrzeżenie „stale”: jeśli `heartbeat` starszy niż np. 2× delay.

### 7.2 🔴 LIVE: Aktualna Aktywność (do poprawy)
Wymagania:
- zawsze pokazywać: `phase`, `stage`, `category`, `file`, `message`.
- progres w jednostkach zależnych od fazy:
  - MIGRATION: `files done/total` + `keys delta`
  - TRANSLATION_SYNC: `lang` + `keys added`
  - AUTO_TRANSLATE: `lang` + `translated/skipped`
  - COMPACT_KEYS: `mapped_new`, `export langs`, `next_id`
  - IDLE: `sleep`, `next scan at`

### 7.3 „W tym cyklu”
Krótka tabela per faza:
- co uruchomiono,
- co zmieniono (delta),
- wynik (ok/error/skip/backoff).

### 7.4 „Dziś (UTC)”
Tabela z daily summary:
- migracja: pliki/klucze
- sync: per język
- auto: per język
- compact: mapowania/export
- błędy

### 7.5 Kategorie — spójny format dla każdej
Każda kategoria ma mieć *te same pola* (nawet jeśli 0):
- status, backoff, remaining, last_updated, delta_today, delta_last_cycle.

---

## 8) Integracja z istniejącymi plikami (stan repo)

W repo już istnieją:
- `i18n_worker_state.json` (ogólny stan workera)
- `.i18n_category_state.json` (backoff per kategoria)
- `I18N_STATUS.md` (dashboard)

Plan migracji statusów:
1. Utworzyć `i18n/status/` i zacząć pisać `activity.json` + `worker_state.json`.
2. Na start: budować `worker_state.json` z danych z `i18n_worker_state.json` + `.i18n_category_state.json`.
3. Stopniowo: przenieść emitowanie zdarzeń do `ops.jsonl`/`errors.jsonl`.
4. Docelowo: `I18N_STATUS.md` generować tylko z `i18n/status/*`.

---

## 9) Checklista wdrożenia (status)

- [ ] Dodać `i18n/status/activity.json` i aktualizować go w każdym etapie.
- [ ] Dodać `i18n/status/worker_state.json` (schema 3.0) + heartbeat.
- [ ] Dodać `i18n/status/ops.jsonl` + `errors.jsonl` (append-only).
- [ ] Dodać `i18n/status/daily/YYYY-MM-DD.json` (agregacja per dzień).
- [ ] Zmienić generator `I18N_STATUS.md`: LIVE + TODAY + per-kategoria z JSON.
- [ ] Dodać testy/validator: JSON schema + sanity checks (np. brak ujemnych delt).
