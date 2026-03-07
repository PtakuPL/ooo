# I18N_STATUS.md — Pełna przebudowa dashboardu

**Data:** 2026-02-14  
**Commit:** `a04c31170`  
**Plik:** `i18n_worker_simple.sh` (+631, -56 lines)

## Co zostało zrobione

### Grupa A: Polonizacja (12/12 ✅)
- Wszystkie etykiety PL: DZIAŁA/BEZCZYNNY/NIEAKTYWNY/ZATRZYMANY/BŁĄD
- 26 mapowań stage→PL w `_nice_stage()` (heartbeat_tick→sygnał życia, auto_start→start tłumaczenia, itd.)
- Nagłówki tabel, KPI, Strict Hourly — po polsku
- EN-copy→Kopie EN, Guard reports→Raporty strażnika jakości
- `_section_state()` i `_state_plain()` — obsługa PL nazw

### Grupa B: Rozbudowa LIVE (6/7 ✅)
- **B1: Fix progress 0/0** — Python pisze postęp do `auto_translate_progress.tmp` co 5 kluczy, heartbeat czyta i raportuje dane w real-time. `auto_start/auto_done` z `translate_limit` jako total.
- **B2: Co robi worker** — mapowanie phase+stage→opis po polsku (np. "Tłumaczenie automatyczne → naprawa kopii EN")
- **B3: Aktywne języki (10 min)** — parsowanie `activity.json.recent[]`, wyciągnięcie unikalnych języków z ostatnich 10 min
- **B4: Metoda tłumaczenia** — GT/TM/dict z `translation_guard_latest.json`
- **B5: Statystyki ostatniego cyklu** — z `worker_cycle_perf_latest.json`
- **B7: Ostatnie operacje** — 5 ostatnich wpisów z `ops.jsonl`
- B6 (LIVE per faza) — pominięte, zbyt złożone bez korzyści

### Grupa C: Języki (2/5 ✅)
- **C1: "Języki ostatnia godzina"** — tabela per język z `strict_targets`
- **C2: "Pokrycie per język TOP 20"** — z `translation_lang_overview`
- C3-C5 — pominięte (focus config, kolejka, mini-sekcje per język)

### Grupa D: Godzinowe/dzienne/tygodniowe (3/5 ✅)
- **D1: "Ta godzina"** — tłumaczenia, cykle, języki, najaktywniejszy, tempo, GF rate, podejrzane
- **D2: "Dziś" rozszerzone** — TOP5 języków, porównanie z wczoraj (↑/↓%), aktywne języki, błędy
- **D3: "Ten tydzień"** — 7 dni z wykresem ASCII, suma tygodniowa
- D4/D5 — pominięte (trend strzałkami, historia etapów)

### Grupa E: Postęp i ETA (3/4 ✅)
- **E1: ETA per język** — ile h/d do 95% pokrycia
- **E2: ETA globalne** — suma kluczy brakujących / tempo
- **E3: Paski postępu ASCII** — 20-znakowe paski ██░░ per język
- E4 — pominięte (zmiana pokrycia 24h w tabeli)

### Grupa F: Cleanup (2/6 ✅)
- **F4: PRE_MIGRATION** — poprawiony nagłówek (bylo `�` → `🔍`)
- **F6: Legenda** — 18-pozycyjna tabela emoji i terminów na dole
- F1/F2/F3/F5 — pominięte (details collapse, dedup sekcji, reorder, usuwanie metryk)

### Grupa G: Nowe sekcje (4/5 ✅)
- **G1: Podsumowanie** — 1-liner na samej górze z kluczowymi metrykami
- **G2: Problemy i uwagi** — języki z niską jakością, wysoki GF rate, brak tempa
- **G3: Ostatnie komendy** — z `worker_commands.txt`
- **G4: Zdrowie systemu** — worker status, heartbeat age, uptime
- G5 — pominięte (ASCII wykres godzinowy)

## Nowa struktura I18N_STATUS.md

```
1.  📝 PODSUMOWANIE (G1) — 1 linia z metrykami
2.  🧭 META — wersja, update, okno godzinowe, tłumaczenia netto
3.  🔴 LIVE — tabela 10 metryk + ostatnie operacje
4.  ⏱️ TA GODZINA (D1)
5.  🌍 JĘZYKI — OSTATNIA GODZINA (C1)
6.  🗺️ POKRYCIE PER JĘZYK TOP 20 (C2)
7.  📈 POSTĘP I ETA (E1-E3)
8.  🤖 AI AGENT INTEGRATION
9.  🔍 PRE_MIGRATION (F4)
10. 🌍 TRANSLATION
11. 🔬 QUALITY
12. ⚠️ PROBLEMY I UWAGI (G2)
13. 📜 OSTATNIE KOMENDY (G3)
14. 🏥 ZDROWIE SYSTEMU (G4)
15. 📜 HISTORY + DZIŚ + TYDZIEŃ (D2, D3)
16. ... istniejące sekcje ...
17. 🏷️ LEGENDA (F6)
```

## Pominięte zadania (do przyszłej implementacji)

| # | Zadanie | Powód pominięcia |
|---|---------|-----------------|
| B6 | LIVE per faza | Zbyt złożone, mała wartość |
| C3-C5 | Focus/kolejka/mini-sekcje | Potrzebuje rozbudowy worker_config |
| D4-D5 | Trendy strzałkami, historia etapów | Wymaga snapshotu z poprzedniej godziny |
| E4 | Zmiana pokrycia 24h | Wymaga snapshot z 24h temu w daily/*.json |
| F1 | Details collapse | Markdown collapse trudne w GitHub |
| F2 | Dedup sekcji | Wymaga analizy powiązań |
| F3 | Reorder globalny | Wymaga przebudowy template (ryzyko regresji) |
| F5 | Usunięcie metryk | Trzeba potwierdzenie co usunąć |
| G5 | Wykres ASCII godzinowy | Wymaga hourly snapshots |

## Stan końcowy

- Dashboard: **983 linii** (z 795 przed zmianami)
- Plik worker: **23362 linii** (z 22814 przed zmianami)
- Test: `--update-status` działa bez błędów
- Commit: pushed to `PtakuPL/ooo:master` jako `a04c31170`
