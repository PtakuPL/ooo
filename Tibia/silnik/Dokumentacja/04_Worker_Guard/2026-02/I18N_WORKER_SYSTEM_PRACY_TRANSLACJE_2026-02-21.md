# System pracy tłumaczeń i18n Workera (operacyjny)

**Data:** 2026-02-21  
**Zakres:** Canary i18n worker + guardian + statusd  
**Tryb docelowy:** 7 języków (`ru,ro,it,sr,sv,pl,es`)

---

## 1) Cel systemu

Celem jest stabilna, powtarzalna praca tłumaczeń bez zawieszania środowiska (WSL/VS Code), z jasnym kontraktem:
- worker tłumaczy tylko uzgodnione języki,
- status jest świeży i czytelny,
- obciążenie hosta jest kontrolowane,
- incydenty mają gotowy runbook.

---

## 2) Kontrakt runtime (obowiązujący)

### 2.1. Zakres języków
- Worker działa wyłącznie na: `ru,ro,it,sr,sv,pl,es`.
- Profil guardiana musi mieć tryb, który **wymusza `--langs`**.

### 2.2. Tryb uruchomienia
- Start/stop/restart wyłącznie przez:
```bash
bash i18n_start_all.sh
bash i18n_start_all.sh --stop
bash i18n_start_all.sh --restart
bash i18n_start_all.sh --status
```

### 2.3. Quality mode
- `global_quality_mode` = OFF (dla throughput/stabilności operacyjnej).
- `global_quality_priority_gate_enabled` = OFF.

### 2.4. Ograniczenie churnu statusowego
- Push statusu: co najmniej co `480s`.
- Commit statusu: cooldown `900s`.

---

## 3) Dzienne SOP (Standard Operating Procedure)

## Krok A — start zmiany
1. Sprawdź status daemonów:
```bash
bash i18n_start_all.sh --status
```
2. Sprawdź świeżość heartbeat:
```bash
python3 - << 'PY'
import json,datetime
o=json.load(open('i18n/status/activity.json',encoding='utf-8'))
ts=o.get('generated_at_utc')
print('generated_at_utc=',ts)
if ts:
  dt=datetime.datetime.fromisoformat(ts.replace('Z','+00:00'))
  age=int((datetime.datetime.now(datetime.timezone.utc)-dt).total_seconds())
  print('activity_age_sec=',age)
print('phase=',o.get('phase'),'category=',o.get('category'),'file=',o.get('file'))
PY
```
3. Potwierdź komendę procesu workera (`--langs ...`):
```bash
ps -eo pid,ppid,cmd | grep -E 'i18n_worker_simple.sh --continuous' | grep -v grep
```

## Krok B — monitoring w trakcie
- Co 30–60 min sprawdź:
  - `i18n/status/activity.json` (heartbeat age),
  - `i18n/status/translation_guard_latest.json`,
  - `i18n/status/strict_hourly_window_latest.json`.

## Krok C — koniec zmiany
- Dopisz krótką notkę do planu naprawczego:
  - co zmieniono,
  - wynik (`RUNNING/STOPPED`, KPI),
  - ewentualny incydent + działania.

---

## 4) KPI operatorskie

Priorytetowe metryki:
- `net_effective_translated/h`
- `guard_fail_rate_pct`
- `no_progress_rate_pct`
- świeżość heartbeat (`activity_age_sec`)

Kryteria „zdrowego” runtime:
- `activity_age_sec` zwykle < 60s,
- brak długich okien `STOPPED`,
- brak serii wpisów `Killed` dla workera,
- brak objawów freeze IDE/WSL.

---

## 5) Sekcja „Ostatnie 10–20 przetłumaczonych kluczy” — kontrakt

### Problem, który występował
Po przejściu na 7 języków sekcja potrafiła pokazywać stare wpisy z all-langs i sprawiać wrażenie braku aktualizacji.

### Naprawa
Generator statusu został poprawiony:
- filtruje wpisy po aktywnej liście `langs` z `guardian_profile.json`,
- stosuje okno świeżości (`STATUS_RECENT_KEYS_LOOKBACK_HOURS`, domyślnie 6h),
- dzięki temu sekcja pokazuje aktualne klucze z bieżącego zakresu języków.

### Szybka weryfikacja
```bash
python3 - << 'PY'
from pathlib import Path
import re
text=Path('I18N_STATUS.md').read_text(encoding='utf-8',errors='ignore')
idx=text.find('### 📝 Ostatnie 10-20 przetłumaczonych kluczy')
chunk=text[idx:idx+3500] if idx>=0 else ''
langs=re.findall(r'^- \[([A-Z_]+)/', chunk, flags=re.M)
print('LANGS_IN_SECTION=',sorted(set(langs)))
print(chunk[:1200])
PY
```

---

## 6) Postępowanie awaryjne (freeze WSL/VS Code)

Skrót:
1. Natychmiast stop:
```bash
bash i18n_start_all.sh --stop
```
2. Snapshot logów:
```bash
tail -n 120 i18n/logs/guardian.log
tail -n 120 i18n/logs/start_all.log
```
3. Start kontrolowany:
```bash
bash i18n_start_all.sh
bash i18n_start_all.sh --status
```
4. Jeśli problem wraca: obniż obciążenie (`parallel_langs`, `translate_limit`) i restart.

> Pełny runbook incydentowy jest w planie naprawczym (`WQ-HARD-52`).

---

## 7) Zasady zmian konfiguracyjnych

Każda zmiana profilu musi mieć komplet:
1. edycja pliku,
2. `--restart`,
3. walidacja procesu (`--langs`, parametry),
4. wpis do dokumentacji z timestampem i wynikiem.

Bez tych 4 kroków zmiana jest traktowana jako niezamknięta operacyjnie.

---

## 8) Stan na teraz (2026-02-21)

- Tryb pracy: 7 języków (`ru,ro,it,sr,sv,pl,es`)
- Quality mode: OFF
- Priority gate: OFF
- Anti-churn status commit: ON (push 480s + commit cooldown 900s)
- Sekcja „Ostatnie 10–20 kluczy”: działa i pokazuje właściwe języki
