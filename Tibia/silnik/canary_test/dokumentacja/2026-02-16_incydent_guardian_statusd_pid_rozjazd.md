# Incydent: guardian/statusd nie publikował statusu na GitHub

**Data:** 2026-02-16  
**Repo:** `PtakuPL/ooo`  
**Katalog roboczy:** `/home/ptaku/serweryt/Tibia/silnik/canary_test`

---

## 1) Objawy zgłoszone

- Monitoring przez `I18N_STATUS.md` sugerował, że system „stoi” / nie puszuje statusu.
- Worker tłumaczeń działał, ale były wątpliwości czy guardian i statusd publikują dane poprawnie.

---

## 2) Obserwacje techniczne (diagnoza)

### Co działało

- `i18n_worker_simple.sh --continuous` był aktywny i wykonywał kolejne cykle.
- `work_i18n_live.log` miał świeże wpisy (kolejne cykle, tłumaczenia, DONE_CONTRACT).

### Co było niespójne

- `statusd` był martwy (PID z `.statusd.pid` wskazywał nieżyjący proces).
- `guardian` działał pod **innym** PID niż zapisany w `.guardian.pid` (rozjazd pid-file vs realny proces).
- `i18n/status/statusd_*` miały stare timestampy (brak bieżącej agregacji przez daemon).

### Ważny kontekst

- W `guardian.log` były cykliczne wpisy `Push do GitHub OK`, ale warstwa pid-file/daemon-state była niespójna.
- To powodowało mylący obraz „publikacja nie działa” mimo częściowo działającego pipeline.

---

## 3) Przyczyna robocza (operacyjna)

Incydent miał charakter operacyjny, nie logiczny błąd translacji:

1. **Rozjazd PID-ów** (`.guardian.pid`, `.statusd.pid`) względem realnych procesów.
2. **Padnięty statusd daemon** bez automatycznego wyrównania stanu PID/lock.
3. W efekcie monitoring i orchestration miały niespójny obraz komponentów.

---

## 4) Wykonana naprawa (dzisiaj)

Wykonano kontrolowany restart całego pipeline przez kanoniczny skrypt:

```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
bash i18n_start_all.sh --restart
bash i18n_start_all.sh --status
```

### Wynik

- `Guardian: RUNNING`
- `Statusd: RUNNING`
- `Worker: RUNNING`
- Po restarcie wróciły świeże wpisy agregacji i odświeżenia statusu.
- `I18N_STATUS.md` zaczął się aktualizować na nowo.

---

## 5) Jak szybko rozpoznać ten sam problem następnym razem

### Szybkie sprawdzenie

```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test

# PID pliki
cat .guardian.pid .statusd.pid .worker_simple.pid 2>/dev/null

# Realne procesy
pgrep -af 'i18n_guardian.sh|i18n-statusd.sh|i18n_worker_simple.sh --continuous'

# Świeżość statusu
stat -c '%y %n' I18N_STATUS.md i18n/status/activity.json i18n/status/statusd_report.json
```

### Sygnały alarmowe

- PID z pliku nie istnieje w `ps`.
- `statusd_report.json` / `statusd_state.json` stoi w czasie.
- `I18N_STATUS.md` nie zmienia się mimo aktywnego `work_i18n_live.log`.

---

## 6) Plan na jutro (hardening)

1. Dodać auto-healing stale PID files (`.guardian.pid`, `.statusd.pid`).
2. Dodać self-check, że `statusd` żyje i zapisuje `statusd_state.json` w oknie czasu.
3. Dodać jasny wpis diagnostyczny: „pid-file stale vs process alive mismatch”.
4. Dodać jedną komendę „doctor/recover” (np. przez `i18n_start_all.sh`) bez pełnego manualnego śledztwa.

---

## 7) Stan końcowy sesji

- Pipeline przywrócony i zdrowy po restarcie.
- Problem zidentyfikowany jako **rozjazd warstwy daemon/pid/status**, nie awaria samego workera tłumaczeń.
- Temat odłożony do hardeningu na kolejną sesję.
