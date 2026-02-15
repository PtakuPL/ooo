# I18N Runbook Operacyjny

> Wersja: 1.0 | Data: 2026-02-14  
> System: i18n_worker_simple.sh + i18n_guardian.sh + i18n-statusd.sh

---

## 1. Architektura systemu

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ i18n_guardian.sh │────▶│i18n_worker_simple│────▶│ i18n-statusd.sh │
│   (watchdog)     │     │  (tłumaczenia)   │     │ (telemetria/KPI)│
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │                        │
        ▼                        ▼                        ▼
  guardian_profiles/     i18n/{en,pl,es,...}      i18n/status/*.json
  worker_config.json     i18n/status/ops.jsonl   i18n/status/daily/
```

- **Guardian** — watchdog, restart workera, auto-policy, profile management
- **Worker** — główny silnik tłumaczeń (MIGRATION → COMPACT_KEYS → TRANSLATION_SYNC → AUTO_TRANSLATE → IDLE)
- **Statusd** — 3. daemon: telemetria, KPI, guardrails, webhook, daily report

---

## 2. Uruchamianie

### 2.1 Start standardowy (zalecany)

```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test

# 1. Uruchom guardiana w tle (on startuje workera automatycznie)
nohup bash i18n_guardian.sh >> logs/guardian.log 2>&1 &

# 2. (Opcjonalnie) Uruchom statusd
nohup bash i18n-statusd.sh >> logs/statusd.log 2>&1 &
```

### 2.2 Start manualny workera (bez guardiana)

```bash
# Tryb ciągły z tłumaczeniami PL+ES, Google Translate, bez git
bash i18n_worker_simple.sh --continuous 20 4 \
  --translations-only \
  --langs pl,es \
  --use-gt \
  --no-git

# Tryb jednorazowy (1 cykl)
bash i18n_worker_simple.sh --continuous 20 4 \
  --translations-only \
  --langs pl,es \
  --use-gt \
  --no-git \
  --once
```

### 2.3 Parametry startowe

| Parametr | Domyślnie | Opis |
|----------|-----------|------|
| `--continuous B D` | 20 4 | B=batch, D=delay (sekundy) |
| `--translations-only` | off | Tylko tłumaczenia (bez migracji) |
| `--langs L1,L2` | pl,es | Języki docelowe |
| `--use-gt` | off | Używaj Google Translate |
| `--no-git` | off | Wyłącz automatyczne commit/push |
| `--translate-limit N` | 80 | Max kluczy na cykl na plik |
| `--parallel-langs N` | 3 | Ile języków na cykl |
| `--once` | off | Zakończ po 1 cyklu |

---

## 3. Zatrzymywanie

```bash
# Graceful stop guardiana (worker zatrzyma się sam)
kill $(cat i18n_guardian.pid 2>/dev/null)

# Stop workera bezpośrednio
kill $(cat i18n_worker_simple.pid 2>/dev/null)

# Awaryjny stop wszystkiego
pkill -f "i18n_worker_simple|i18n_guardian|i18n-statusd"
```

---

## 4. Komendy runtime (w locie)

Zapisz komendę do `.worker_command`:

```bash
echo "KOMENDA" > .worker_command
```

### 4.1 Sterowanie językiem

| Komenda | Opis |
|---------|------|
| `LANG:pl` | Przypiąj do PL |
| `LANG:es:npc.json,server.json` | Przypiąj ES + konkretne pliki |
| `LANG:random` | Przywróć rotację |
| `FOCUS:de` | Trwale skup się na DE |
| `UNFOCUS` | Zdejmij focus |

### 4.2 Konfiguracja

| Komenda | Opis |
|---------|------|
| `GT:on` / `GT:off` | Włącz/wyłącz Google Translate |
| `BATCH:200` | Ustaw translate_limit na 200 |
| `SET:parallel_langs=5` | Zmień config |
| `CONFIG` | Pokaż aktualną konfigurację |
| `RESTART` | Restart workera z nowym kodem |

### 4.3 Testowanie i audyt

| Komenda | Opis |
|---------|------|
| `TEST:de` | Pełny test DE (translate + validate + crossref) |
| `TEST_ALL` | Dodaj wszystkie języki do kolejki testowej |
| `LANGVAL:pl` | Wymuś walidację PL |
| `LANGVAL:all` | Walidacja wszystkich języków |
| `SPOTCHECK:es:50` | Losowy audit 50 tłumaczeń ES |
| `REPORT` | Raport coverage |

### 4.4 Plik worker_config.json

```json
{
  "focus_lang": "",
  "use_gt": true,
  "translate_limit": 80,
  "parallel_langs": 3,
  "paused": false,
  "adaptive_batch": true
}
```

Worker wczytuje config co cykl — zmiany są natychmiastowe.

---

## 5. Profile guardiana

Katalog: `guardian_profiles/`

| Profil | Opis |
|--------|------|
| `translations_pl_es.json` | PL+ES, batch=20, delay=4, GT=true |
| `translations_general.json` | Wszystkie języki, rotacja |
| `translations_random.json` | Losowa rotacja z quality gate |
| `fast_translate.json` | Szybki tryb (batch=50, delay=2) |
| `quality_focus.json` | Wolny, dokładny (batch=10, delay=8) |

Zmiana profilu:
```bash
# W guardian_profiles/active.json:
echo '{"profile": "translations_general"}' > guardian_profiles/active.json
# Guardian automatycznie wczyta przy kolejnym sprawdzeniu
```

---

## 6. Monitoring i diagnostyka

### 6.1 Szybki status

```bash
bash i18n_worker_simple.sh --status
```

### 6.2 Pliki statusu

| Plik | Opis |
|------|------|
| `i18n/status/ops.jsonl` | Log operacji (translate, sync, audit) |
| `i18n/status/errors.jsonl` | Log błędów |
| `i18n/status/translation_guard_report.jsonl` | Guard fail reports |
| `i18n/status/quality_audit_latest.json` | Ostatni audyt jakości |
| `i18n/status/tier_quality_gate.json` | Walidacja tierów |
| `i18n/status/done_contracts.jsonl` | Done contracts per plik/lang |
| `i18n/status/suspicious_rejected.jsonl` | Odrzucone tłumaczenia |
| `i18n/status/pending_skip_24h.json` | Pending skip metryki 24h |
| `i18n_global_stats.json` | Global stats (dashboard) |

### 6.3 Metryki kluczowe

```bash
# Coverage per język
python3 -c "
import json, os
for lang in ['pl','es','de','fr']:
    en = sum(len(json.load(open(f'i18n/en/{f}'))) for f in os.listdir('i18n/en') if f.endswith('.json'))
    try:
        tr = sum(1 for f in os.listdir('i18n/en') if f.endswith('.json') 
                 for k,v in json.load(open(f'i18n/en/{f}')).items()
                 if os.path.exists(f'i18n/{lang}/{f}') and k in json.load(open(f'i18n/{lang}/{f}'))
                 and not str(json.load(open(f'i18n/{lang}/{f}'))[k]).startswith('[')
                 and str(json.load(open(f'i18n/{lang}/{f}'))[k]) != str(v))
    except: tr = 0
    print(f'{lang}: {tr}/{en} = {tr/en*100:.1f}%')
"

# Guard fail rate
tail -100 i18n/status/translation_guard_report.jsonl | \
  python3 -c "import sys,json; lines=[json.loads(l) for l in sys.stdin]; \
  t=sum(int(l.get('translated',0)) for l in lines); \
  g=sum(int(l.get('guard_fail',0)) for l in lines); \
  print(f'guard_fail_rate={g/(t+g)*100:.1f}% ({g}/{t+g})')"

# Throughput
tail -50 i18n/status/ops.jsonl | \
  python3 -c "import sys,json; ops=[json.loads(l) for l in sys.stdin if 'TRANSLATE' in l]; \
  total=sum(int(o.get('delta',{}).get('translated',0)) for o in ops); \
  print(f'Last 50 ops: {total} keys translated')"
```

---

## 7. Troubleshooting

### 7.1 Worker nie postępuje

1. Sprawdź logi: `tail -50 logs/worker.log`
2. Sprawdź guard_fail: `cat i18n/status/translation_guard_latest.json | python3 -m json.tool`
3. Sprawdź blokery: `cat i18n/status/translation_blockers_latest.json`
4. Reset backoff: `rm i18n/status/translation_strict_candidates_cache.json`

### 7.2 Wysoki guard_fail_rate (>10%)

1. Sprawdź przyczyny: `tail -20 i18n/status/translation_guard_report.jsonl | python3 -c "..."`
2. Najczęstsze przyczyny:
   - `placeholder` — brakujące tokeny {player}, |SPELL| w tłumaczeniu
   - `command` — komendy gry nie zachowane (sprawdź GAME_COMMANDS set)
   - `pipe` — tokeny |...| usunięte
3. Rozwiązanie: worker auto-fix (F1-F6) powinien naprawić większość. Jeśli nie — sprawdź `_auto_fix_translation()`.

### 7.3 Guardian restart loop

1. Sprawdź `i18n/status/guardian_health.json` → `restart_count`
2. Jeśli > 5 restartów: guardian przechodzi w cooldown (exponential backoff)
3. Reset: `rm i18n/status/guardian_health.json`

### 7.4 GT (Google Translate) nie działa

1. Sprawdź: `curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=pl&dt=t&q=hello" | head -c 200`
2. Jeśli rate limited: zwiększ `GT_DELAY` (domyślnie 1.5s)
3. Fallback: worker używa słowników bazowych + TM automatycznie

### 7.5 Duża liczba identical_to_en

1. Sprawdź: `cat i18n/status/quality_audit_latest.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('identical_to_en',0), d.get('identical_to_en_exempt',0))"`
2. Repair bonus round działa co 3 cykle (REPAIR_IDENTICAL_INTERVAL=3)
3. Można wymusić wyższy limit: `echo "BATCH:200" > .worker_command`

---

## 8. Rollback

### 8.1 Cofnięcie tłumaczeń

```bash
# Cofnij ostatni commit
git log --oneline -5
git revert HEAD

# Cofnij do konkretnego commita
git revert <commit-hash>
```

### 8.2 Cofnięcie kodu workera

```bash
# Przywróć poprzednią wersję
git checkout HEAD~1 -- i18n_worker_simple.sh
# Restart
echo "RESTART" > .worker_command
```

### 8.3 Awaryjny reset

```bash
# Zatrzymaj wszystko
pkill -f "i18n_worker_simple|i18n_guardian"
# Wyczyść stany
rm -f i18n/status/translation_strict_candidates_cache.json
rm -f i18n/status/translation_dispatch_state.json
rm -f i18n_worker_simple.pid i18n_guardian.pid .worker_command
# Restart
nohup bash i18n_guardian.sh >> logs/guardian.log 2>&1 &
```

---

## 9. Checklista poranna

- [ ] Sprawdź czy worker działa: `pgrep -f i18n_worker_simple`
- [ ] Sprawdź coverage PL/ES: `bash i18n_worker_simple.sh --status 2>/dev/null | grep coverage`
- [ ] Sprawdź guard_fail_rate: < 10%
- [ ] Sprawdź logi błędów: `tail -10 i18n/status/errors.jsonl`
- [ ] Sprawdź tier quality gate: `cat i18n/status/tier_quality_gate.json | python3 -m json.tool | head -20`

## 10. Checklista po deploy

- [ ] Zweryfikuj `bash -n i18n_worker_simple.sh` (brak błędów składni)
- [ ] Wyślij restart: `echo "RESTART" > .worker_command`
- [ ] Poczekaj 2 cykle, sprawdź logi: `tail -30 logs/worker.log`
- [ ] Sprawdź guard_fail_rate po 10 cyklach
- [ ] Porównaj coverage z baseline

---

## 11. Kontakty i referencje

- Repo: `PtakuPL/ooo`, branch `feature/i18n-multilanguage`
- Plan: `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`
- Plan naprawczy: `docs/I18N_WORKER_PLAN_NAPRAWCZY_2026-02-13.md`
- Guardian/daemon: `docs/i18n/I18N_STATUS_GUARD_3DAEMON_REPAIR_PLAN_2026-02-13.md`
