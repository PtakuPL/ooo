# Worker – Postęp wdrożenia planu (rozbudowa/poprawa)

**Źródła planu:**
- [docs/i18n/WORKER_MASTER_PLAN.md](docs/i18n/WORKER_MASTER_PLAN.md)
- [docs/i18n/STATUS_AND_DASHBOARD_PLAN.md](docs/i18n/STATUS_AND_DASHBOARD_PLAN.md)

**Stan na:** 2025-12-16

Legenda: ✅ done | 🟡 partial | ⏳ todo

---

## 1) Dashboard / obserwowalność (STATUS_AND_DASHBOARD_PLAN)

- ✅ JSON jako źródło prawdy w `i18n/status/` (activity/ops/errors/daily/worker_state).
- ✅ Heartbeat + stale w dashboardzie (na podstawie `activity.json`/`worker_state.json`).
- ✅ Sekcja „🔴 LIVE”: pokazuje fazę/etap/kategorię/plik/wiadomość/progress/ETA/heartbeat.
- ✅ Sekcja „🔁 W tym cyklu”: z `i18n/status/ops.jsonl` (ostatnie 5–10 zdarzeń cyklu).
- ✅ Sekcja „📅 Dziś (UTC)”: z `i18n/status/daily/YYYY-MM-DD.json`.
- ✅ Obsługa faz 5–6: `MIGRATION`, `COMPACT_KEYS`, `TRANSLATION_SYNC`, `AUTO_TRANSLATE`, `IDLE` (+ `VALIDATION` jako opcjonalna/6).

**Uwagi/ryzyka:**
- 🟡 Nazwy `stage` są częściowo ujednolicone (np. `SYNC_FILE_DONE`, `AUTO_TRANSLATE_DONE`), ale nie wszędzie są 1:1 z dokumentem (do dopięcia, jeśli chcesz ścisłe nazwy etapów).

---

## 2) Emitowanie eventów (ops.jsonl) – pełne pokrycie faz

- ✅ `MIGRATION`: log-op z deltą (`keys_added`, `files_changed`).
- ✅ `COMPACT_KEYS`: log-op z deltą `mapped_new` + event eksportu.
- ✅ `TRANSLATION_SYNC`: log-op z deltą `keys_added` (per lang+file, `detail: lang=.. file=..`).
- ✅ `AUTO_TRANSLATE`: log-op z deltą `translated` + `skipped` (użyte jako liczba placeholderów).
- ✅ `IDLE`: log-op dla cyklu/wykrycia nowej pracy/sleep.

**Uwagi/ryzyka:**
- 🟡 `AUTO_TRANSLATE.skipped` jest obecnie liczbą placeholderów (semantycznie: „nie udało się przetłumaczyć / zostawiono placeholder”). Jeśli chcesz rozróżnić „skipped bo limit” vs „placeholder”, trzeba rozbudować delty.

---

## 3) Guardian / publikacja na GitHub

- ✅ Guardian odświeża dashboard tuż przed pushem (`--update-status` przed `git add/commit/push`).

---

## 4) Porządki/liczniki/spójność

- ✅ Naprawione liczenie języków (wykluczenie `i18n/status` z licznika języków).
- ✅ `--update-status` zapisuje dashboard zarówno do repo-roota (push) jak i do katalogu workera (podgląd w workspace).

---

## 4.1) Scope repo (canary server vs instalka)

- ✅ Domyślny scope ustawiony na **serwer canary**: worker nie migruje `html_copy` ani `testyy/*` (OTClient) w `--continuous`.
- ✅ Sterowanie przez env: `I18N_SCOPE=server` (default) lub `I18N_SCOPE=all` (jeśli chcesz kiedyś wrócić do website/OTClient kategorii).

---

## 4.2) Server/network: ukrywanie fallbackText

- ✅ `i18nSendFallbackText` działa end-to-end: jeśli `false`, serwer wysyła w pakietach I18N pusty fallback (dla `sendLocalizedTextMessage`, `sendCreatureLocalizedSay`, `sendLocalizedError`).

---

## 5) Następne kroki (proponowane)

- ⏳ Ujednolicić nazwy `stage` dokładnie pod plan (np. `SYNC_START`, `SYNC_FILE_DONE`, `SYNC_LANG_DONE`, `AUTO_TRANSLATE_START`, `AUTO_TRANSLATE_KEY_OK/SKIP`, `AUTO_TRANSLATE_DONE`).
- ⏳ Dopiąć dodatkowe delty dla `COMPACT_KEYS` (np. `exported_langs`) jeśli chcesz widzieć je w daily.
- ⏳ Rozszerzyć `VALIDATION` (jeśli ma być realną fazą, nie tylko fallback/placeholder w UI) – emitowanie eventów + daily agregacja.
