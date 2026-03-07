# Audyt otwartych zadań workera i18n — 2026-02-15

## Zakres i źródła

Priorytet źródeł:
1. `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md` (plan kanoniczny wykonawczy)
2. `docs/I18N_WORKER_PLAN_NAPRAWCZY_2026-02-13.md` (archiwum/historia)
3. `I18N_WORKER_PLAN.md` (plan rozwoju historyczny)

Uwaga: dokument naprawczy sam wskazuje, że plan kanoniczny to `I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`.

---

## Wynik audytu — status realny

### ✅ Zadania domknięte

- `WQ-QUALITY-55-1` (automatyczny audyt gramatyczno-stylistyczny) — oznaczone jako DONE w najnowszych aktualizacjach planu kanonicznego.
- Potwierdzenie runtime artefaktami:
  - `i18n/status/translation_grammar_audit_latest.json`
  - `i18n/status/translation_grammar_audit_history.jsonl`

### ⏳ Zadania otwarte (aktywne)

1. `WQ-FAST-7` (P1)
   - Cel: formalne potwierdzenie SLA 24h dla forced commands
     - `p95 pending_age <= 15s`
     - `p95 roundtrip <= 45s`
     - min. 20 próbek
   - Aktualny stan telemetry (z `statusd_doctor.json`):
     - `analysis_view=full_window`
     - `samples=11`
     - `p95_pending_age_s=95.0`
     - `p95_roundtrip_s=149.5`
     - `operational_window.samples=0`
   - Wniosek: zadanie nadal NIE domknięte (brak wymaganej liczby próbek i brak formalnego spełnienia SLA).

### 🚫 Zadania wyłączone decyzją właściciela

- `STATUSD_WEBHOOK_URL` — **nie wdrażamy**.
- Decyzja operacyjna: usuwamy/oznaczamy jako poza zakresem (de-scoped) w dokumentacji zamiast implementacji webhooka.

---

## Dlaczego widoczne są „otwarte” stare punkty?

W planach są historyczne sekcje „Nowe TODO” z wcześniejszych godzin. Część z nich została później wykonana i opisana wyżej jako DONE, ale starsze wpisy pozostały w tekście (log zmian). To powoduje pozorne duplikaty TODO.

---

## Checklista wykonawcza (aktualna)

### A) Domknąć `WQ-FAST-7`

- [ ] Uruchomić kontrolowaną serię forced commands (`AUTO <lang>:<json>:N:ONCE`) tak, by zebrać >=20 próbek w aktywnym oknie.
- [ ] Potwierdzić gotowość operational window (`operational_window_ready=true`).
- [ ] Zweryfikować p95 dla `pending_age` i `roundtrip`.
- [ ] Jeśli SLA spełnione: oznaczyć `WQ-FAST-7` jako DONE w planie kanonicznym.
- [ ] Jeśli niespełnione: dopisać root-cause i plan korekt (bez mieszania z historycznym full_window).

### B) Oczyścić dokumentację z webhooka

- [ ] W planie kanonicznym zastąpić otwarte punkty `STATUSD_WEBHOOK_URL` adnotacją: `DE-SCOPED (decyzja właściciela)`, z datą.
- [ ] To samo zrobić w planie naprawczym (archiwalnym), żeby nie wracało jako fałszywie otwarte.

---

## Rekomendowana kolejność dalszych prac

1. Najpierw `WQ-FAST-7` (jedyne technicznie aktywne zadanie P1).
2. Następnie porządek dokumentacji (`STATUSD_WEBHOOK_URL -> DE-SCOPED`).
3. Na końcu szybki refresh statusu (`I18N_STATUS.md`) po zamknięciu `WQ-FAST-7`.
