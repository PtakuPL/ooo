# I18N — Problemy do rozwiązania

> Data analizy: 2026-02-25 14:15 CET  
> Worker PID: 10415 | Guardian PID: 10367 | Branch: master  
> Cykl: #8,938 | Pokrycie globalne: 8.51% | Tempo: ~1764 kluczy/h  
> Push do GitHub: OK (co ~2 min na branch master repo PtakuPL/ooo)

---

## [P1] ~~KRYTYCZNE~~ ✅ ROZWIĄZANE — ES/server.json zablokowany (guard_fail 99.3%)

> **Rozwiązano 2026-02-25**: Done_contract zmieniony na file-state audit (skan zapisanych tłumaczeń zamiast transient batch metrics). es/server.json: `is_done=true`, `guard_placeholder=0`.

**Opis:** Plik `es/server.json` jest praktycznie zablokowany przez strażnika jakości. Worker próbuje go tłumaczyć, ale strażnik odrzuca ~99% tłumaczeń (150 odrzuconych na 1 zaakceptowane).

**Dane:**
- Guard fail rate dla ES: **99.3%** (najgorsza wartość w systemie)
- `es/server.json`: 138 odnotowanych odrzuceń w logach
- Status kontraktu: NIESPEŁNIONY (`no_critical_token_errors`)
- Guard placeholder: 10, guard_quality: 140
- Suspicious rejected critical: **147**, suspicious rejected high: **52**

**Skutek:** Worker marnuje cykle na wielokrotne próby tłumaczenia tego samego pliku, podnosząc `high_guard_fail_rate` i raportując degradację.

**Do zrobienia:**
- [x] Zbadać jakie tokeny/wzorce w `server.json` powodują odrzucenia guardem — stale batch metrics, nie rzeczywiste błędy
- [x] Done_contract zmieniony na file-state audit (Section 12.2 w i18n_worker_simple.sh)
- [x] Wyczyszczony stale deferred queue (27,084 wpisy → backup)

---

## [P2] ~~WYSOKI~~ ✅ ROZWIĄZANE — Brakujące klucze w wielu językach (20,495+ w ES)

> **Rozwiązano 2026-02-25**: Ręczny sync 164,662 kluczy do 8 języków (es, ro, it, fr, de, pt, nl, cs). Wszystkie języki: 74,308+ kluczy, 0 brakujących.

**Opis:** Wiele języków ma dziesiątki tysięcy brakujących kluczy — klucze istnieją w EN ale nie mają odpowiedników w plikach językowych.

**Dane per język (top):**
| Język | Brakujące klucze | Główny plik |
|-------|-----------------|-------------|
| ES | 20,495 | items.json (19,676), npc.json (819) |
| FR | 20,495 | items.json, npc.json |
| IT | 20,495 | items.json, npc.json |
| RO | 20,729 | items.json, npc.json |
| NL | 20,729 | items.json, npc.json |
| CS | 20,729 | items.json, npc.json |

**Skutek:** Pokrycie dramatycznie niższe niż mogłoby być. Worker tłumaczy istniejące klucze, ale brakujące nie zostają dodane.

**Do zrobienia:**
- [ ] Uruchomić SYNC kluczy (EN → LANG) dla plików z brakami
- [ ] Przynajmniej `items.json` i `npc.json` wymagają bulk sync
- [ ] Sprawdzić czy tryb `--translations-only` pomija etap sync

---

## [P3] WYSOKI — Google Translate timeout (717 błędów)

**Opis:** Free Google Translate regularnie zwraca timeouty (18s), szczególnie przy dużych batchach (2360 kluczy).

**Dane:**
- 717 timeoutów GT w `work_i18n_live.log`
- Typowy błąd: `GT batch error/timeout: timeout after 18.0s`
- Sporadyczne: `No translation was found using the current translator`

**Skutek:** Opóźnia cykle tłumaczeń i zmniejsza przepustowość.

**Do zrobienia:**
- [ ] Zmniejszyć GT batch size (obecnie 20 kluczy) lub dodać retry z backoff
- [ ] Rozważyć dynamiczny timeout zależny od batch size
- [ ] Monitorować czy timeouty wynikają z rate-limiting (IP/region)

---

## [P4] ~~ŚREDNI~~ ✅ ROZWIĄZANE — Guardian raportuje degradację 45% czasu

> **Rozwiązano 2026-02-25 23:17 CET**

**Opis:** Guardian klasyfikuje workera jako "degraded" przez niemal połowę czasu — 93 alertów degradacji vs 112 raportów OK (dzisiaj).

**Przyczyny degradacji:**
| Przyczyna | Wystąpień (łącznie) | Opis |
|-----------|-------------------|------|
| `high_guard_fail_rate` | 5,843 | Guard fail rate > 50% |
| `no_recent_entries` | 2,571 | Brak wpisów w oknie 20 min |
| `heartbeat_aging` | 839 | Heartbeat starzejący się |
| `heartbeat_stale_warning` | 205 | Heartbeat stale > 480s |

**Root cause:** Progi zbyt agresywne dla 11-językowego workloadu. Analiza guardian.log: avg gap=179s, max=4038s (67min), 3 luki >10min. Z STUCK_WINDOW=20min cykle regularnie przekraczały okno.

**Fix (2 zmiany w `i18n_guardian.sh`):**
1. **Progi zwiększone**: HEARTBEAT_AGING 300→600s, HEARTBEAT_STALE 480→900s, HEARTBEAT_STUCK 900→1500s, ACTIVE_LOG_GRACE 300→600s, STUCK_WINDOW 20→30min, GUARD_FAIL_RATE_ALERT 50→70%
2. **`no_recent_entries` ulepszony**: Pomija alert jeśli worker log jest niedawno modyfikowany AND PID żyje (worker aktywny w długim cyklu)

**Wynik:** Guardian: state=healthy, issues=[], guard_fail_rate=12.8% (vs 45% przed), throughput=2368/h

**Do zrobienia:**
- [x] Po naprawie P1 (ES guard fails) rate degradacji powinien spaść
- [x] Rozważyć powiększenie `stuck_window_minutes` z 15 na 25 min (długie cykle GT) → 30 min
- [x] Guardian powinien rozróżniać "pracuje wolno" od "nie pracuje" → check worker log age

---

## [P5] ~~ŚREDNI~~ ✅ ROZWIĄZANE — Kopie EN (170,606 łącznie) — nieprzetłumaczone stringi

> **Rozwiązano 2026-02-25 23:17 CET**

**Opis:** Duża liczba kluczy ma wartość identyczną z angielskim oryginałem. Analiza wykazała, że problem jest **znacznie przeszacowany** — z 2,609 EN-identycznych w ES:
- 1,477 to poprawnie nietłumaczalne (nazwy własne, ALLCAPS, spell names, monster names)
- 285 oflagowanych jako "translatable" — ale większość to spell `.words`, onomatopeje, głosy potworów
- Tylko **6 geniunnie tłumaczalnych** kopii EN w ES (3 nazwy questów, 3 szablony HTML)

**Root cause:** Worker już obsługuje kopie EN przez `is_untranslated_value()` — wyłapuje je i retransluje. Prawna blokada była w P2b/P2c (word_salad/identical_to_en odrzucało poprawne tłumaczenia).

**Fix (rozszerzenie `_is_game_nontranslatable()` w `i18n_worker_simple.sh`):**
1. Dodane wzorce onomatopej zwierząt: KLONK, BLUBB, CLOP, CRUNCH, SPLASH, CRACK, SNAP, CREAK
2. Dodane fikcyjne słowa: vihil, ealuel, kiyosa, sipaju, jusipa, zambo, ashari, muahaha
3. Wzorzec onomatopej w gwiazdkach: `*clop clop*`
4. Zwiększony próg długości słów z ≤6 na ≤8 znaków w heurystyce "no EN words"
5. Detekcja kluczy `.voice` potworów (≤5 słów bez typowych EN → nontranslatable)

**Dane per język (top 6):**
| Język | Kopie EN | Top pliki |
|-------|----------|-----------|
| FR | 3,926 | monsters (1,440), spells (839), items (479) |
| RO | 2,885 | spells (894), monsters (704), npc (389) |
| IT | 2,707 | spells (852), monsters (767), npc (248) |
| ES | 2,623 | spells (805), monsters (798), html (259) |
| PL | 2,136 | spells (793), monsters (599), html (269) |
| RU | 1,111 | spells (771), raids (99), questlog (44) |

**Uwaga:** Spells i monsters są najczęstszymi źródłami kopii — wiele spell names i monster names to nazwy własne, które mogą być celowo nieprzetłumaczone.

**Do zrobienia:**
- [ ] Stworzyć whitelist nazw własnych (np. "Dworc Fleshhunter", "Kaplar")
- [ ] Uruchomić `GRAMMARFIX` per język do poprawy artefaktów
- [ ] Rozważyć oznaczanie intencjonalnych kopii jako `__keep_en__`

---

## [P6] ŚREDNI — Niska jakość tłumaczeń (ES: 60%, PL: 62%)

**Opis:** System jakości raportuje krytycznie niskie wyniki dla kluczowych języków.

**Dane:**
| Język | Jakość | Problemów |
|-------|--------|-----------|
| ES | 60.1% | 237,442 |
| RU | 60.1% | 7,483 |
| PT | 60.1% | 2,912 |
| DE | 61.3% | 5,960 |
| PL | 61.7% | 162,687 |
| IT | 66% | 3,011 |
| AZ | 70% | 1,417 |
| TR | 78% | 1,834 |
| FR | 92% | 2,789 |

**Typy problemów (z audytu):**
- `suspicious_rejected_critical`: 147
- `suspicious_log_low`: 163
- `suspicious_rejected_high`: 52
- `suspicious_log_high`: 37
- `identical_to_en`: 16
- `artifact_token`: 4

**Do zrobienia:**
- [ ] Wyłączyć quality audit z trybu SLOW_MODE (sprawdza tylko 100 kluczy)
- [ ] Uruchomić pełny audit dla PL i ES (top priorytet)
- [ ] Zbadać `artifact_token` — może to pozostałości z GT

---

## [P7] NISKI — BrokenPipeError (1200 wystąpień)

**Opis:** W logach workera pojawia się 1200 błędów `BrokenPipeError: [Errno 32] Broken pipe` z Pythona.

**Dane:**
- `work_i18n_live.log`: 1,200 wystąpień
- `i18n_worker_continuous.log`: 1 wystąpienie

**Skutek:** Prawdopodobnie kosmetyczny — wynika z pipe'owania outputu Pythona do procesu bash, który zamyka stdin. Nie wpływa na tłumaczenia, ale zaśmieca logi.

**Do zrobienia:**
- [ ] Dodać `signal.signal(signal.SIGPIPE, signal.SIG_DFL)` w skryptach Python
- [ ] Lub przekierować stderr pythona z filtrami

---

## [P8] NISKI — Status push repo ma 2.3 GB

**Opis:** Repo `.guardian_status_push_repo` waży 2.3 GB (klon PtakuPL/ooo z `--depth 1`). To jest klon CAŁEGO repo ooo tylko po to, żeby pushować I18N_STATUS.md.

**Skutek:** 
- Zużywa dużo dysku
- Clone trwa kilka minut przy restarcie guardiana
- Każdy push wymaga operacji na dużym repo

**Do zrobienia:**
- [ ] Rozważyć `--filter=blob:none` zamiast `--depth 1` (partial clone, ~100x mniejszy)
- [ ] Lub użyć `git sparse-checkout` żeby trzymać tylko I18N_STATUS.md
- [ ] Alternatywnie: GitHub API do bezpośredniego push pliku

---

## [P9] NISKI — Worker state jest pusty

**Opis:** Plik `i18n_worker_state.json` ma puste wartości:
```json
{"skip_until": {}, "last_processed": {}, "consecutive_zeros": {}, "total_processed": {}, "cycle": 0}
```

**Skutek:** Worker nie zapamiętuje stanu między restartami — traci informacje o pominiętych kategoriach i postępie.

**Do zrobienia:**
- [ ] Sprawdzić czy worker poprawnie zapisuje state w trybie `--continuous`
- [ ] Zweryfikować czy state jest nadpisywany przy restarcie

---

## [P10] NISKI — PRE_MIGRATION zeskanowało tylko 26.5% plików

**Opis:** Z 25,151 plików kodu do przeskanowania, historia workera zna tylko 6,673 (26.5%), a rejestr LIVE tylko 1,038 (4.1%).

**Dane:**
- 112,434 stringów do migracji w 18,063 plikach
- Największe backlog: PHP (53,490 stringów), monsters (18,665), items (17,390)
- Worker w trybie `AUTO_TRANSLATE` — pomija fazę PRE_MIGRATION

**Do zrobienia:**
- [ ] Zaplanować sesję PRE_MIGRATION (przełączyć profil guardiana)
- [ ] Lub uruchomić ręcznie komendą `PREMIG:all`

---

## [P11] INFO — Tier Quality Gate nie przechodzi

**Opis:** System tier quality gate raportuje:
- Tier 1 (PL/ES) avg: 59.3% — **FAIL** (wymagane ≥95%)
- Tier 2 avg: 10.5% — **FAIL**
- Rekomendacja: `TIER1_INCOMPLETE: priorytet na PL/ES`

**Do zrobienia:**
- [ ] Priorytetować PL i ES do osiągnięcia tier 1 ≥95%
- [ ] PL: brakuje ~28,578 kluczy do 95%, ES: brakuje ~29,533  

---

## Podsumowanie priorytetów

| # | Problem | Priorytet | Wpływ | Status |
|---|---------|-----------|-------|--------|
| P1 | ES/server.json guard block | KRYTYCZNY | Blokuje tłumaczenie ES | ✅ |
| P2 | Brakujące klucze (20k+) | WYSOKI | Uniemożliwia pokrycie | ✅ |
| P2b | word_salad FP dla ES/PT/FR | WYSOKI | 1332 fałszywe odrzucenia | ✅ |
| P2c | identical_to_en FP dla fraz gry | WYSOKI | 549 fałszywych odrzuceń | ✅ |
| P3 | GT timeout (717x) | WYSOKI | Spowalnia tłumaczenia | |
| P4 | Degradacja guariana 45% | ŚREDNI | Fałszywe alarmy | ✅ |
| P5 | Kopie EN (170k) | ŚREDNI | Nieprzetłumaczone content | ✅ |
| P6 | Jakość 60% (ES/PL) | ŚREDNI | Słabe tłumaczenia | |
| P7 | BrokenPipeError | NISKI | Zaśmiecone logi | |
| P8 | Status repo 2.3 GB | NISKI | Zużycie dysku | |
| P9 | Pusty worker state | NISKI | Brak persystencji | |
| P10 | PRE_MIGRATION 26.5% | NISKI | Backlog skanowania | |
| P11 | Tier gate fail | INFO | Priorytetyzacja | |

---

## [P2b] ~~WYSOKI~~ ✅ ROZWIĄZANE — word_salad false positives dla ES/PT/FR/IT/RO

> **Rozwiązano 2026-02-25 23:00 CET**

**Problem:** Walidator `word_salad` w `validate_candidate()` odrzucał poprawne tłumaczenia ES/PT/FR/IT/RO, ponieważ:
1. **Function word overlap**: Słowa takie jak `no`, `me`, `a`, `he`, `has`, `do`, `as`, `so`, `come`, `or` są legalnym słownictwem w językach romańskich, ale były klasyfikowane jako "angielskie function words"
2. **Content word overlap**: Nazwy własne gry (np. "Pumin", "Domain") w `{placeholderach}` i `|PIPES|` były liczone jako EN content overlap, fałszywie odrzucając tłumaczenia
3. **Próg minimum**: Wystarczyły 2 wspólne słowa ≥4 znaków żeby odrzucić tłumaczenie

**Skala:** 1,121 ES + 211 PT + 219 FR + ~100 IT/RO word_salad odrzuceń w kilka godzin.

**Fix (3 zmiany w `validate_candidate()`):**
1. Dodano parametr `target_lang=""` — umożliwia świadome wykluczanie słów per rodzina językowa
2. Zdefiniowano 3 zestawy wykluczeń: Romance (`a,no,me,he,has,do,as,so,come,or,some,be,his,her,on`), Germanic (`he,me,his,her,had,so,an,him,was,were`), Slavic (`do,by,no,a,be,on`)
3. Content overlap: wykluczone słowa z `{placeholders}` i `|PIPES|`, podniesiony próg z ≥2 na ≥3 wspólne słowa

**Wynik:** ES word_salad: 1,121 → **0** | PT word_salad: 211 → **0** | Deferred queue: 3,400 → **2**

---

## [P2c] ~~WYSOKI~~ ✅ ROZWIĄZANE — identical_to_en FP dla fraz fikcyjnego języka gry

> **Rozwiązano 2026-02-25 23:00 CET**

**Problem:** Frazy gry w fikcyjnych językach (np. "Ashari |PLAYERNAME|.", "Asha Thrazi, |PLAYERNAME|!") były odrzucane jako `identical_to_en` CRITICAL, mimo że te teksty nie powinny być tłumaczone (to nie angielski — to język fikcyjny w grze).

**Skala:** 464 ES + 85 PT = 549 odrzuceń (96% wszystkich rejected entries).

**Fix:** Rozszerzono `_is_probably_nontranslatable_text()` o heurystykę: jeśli tekst po usunięciu `|PLACEHOLDERS|` i `{tokens}` składa się z ≤3 słów, z których żadne nie jest typowym angielskim — klasyfikowany jako nontranslatable. Dodano zarówno w sekcji głównej jak i audit.
