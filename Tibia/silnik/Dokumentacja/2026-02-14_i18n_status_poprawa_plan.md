# 📊 PLAN POPRAWY I18N_STATUS.MD — Lista zadań

> **Data:** 2026-02-14  
> **Cel:** Znacząco ulepszyć czytelność, kompletność i użyteczność dashboardu I18N_STATUS.md  
> **Język interfejsu:** 100% polski (żadnej angielskiej nazwy wyświetlanej użytkownikowi)

---

## ❌ Zidentyfikowane problemy w aktualnej wersji

### P1. Angielskie nazwy / niezrozumiałe terminy
| Obecny tekst | Problem | Proponowana zmiana |
|---|---|---|
| `Guard fail rate` | Niejasne co to jest | `Odrzucone tłumaczenia (strażnik jakości)` |
| `Throughput` | Angielska nazwa | `Przepustowość (kluczy/h)` |
| `Pending skip` | Angielska nazwa | `Pominięte (kategoria nieaktywna)` |
| `No progress rate` | Angielska nazwa | `Cykle bez postępu` |
| `Suspicious` | Angielska nazwa | `Podejrzane tłumaczenia` |
| `EN-copy` | Niejasne | `Kopie EN (nie przetłumaczone, skopiowane z oryginału)` |
| `Coverage` | Angielska nazwa | `Pokrycie tłumaczeniami` |
| `Net effective translated` | Angielska nazwa | `Tłumaczeń netto (efektywnie)` |
| `Guard reports` | Angielska nazwa | `Raporty strażnika jakości` |
| `Blocker reports` | Angielska nazwa | `Raporty blokad` |
| `Strict hourly window` | Angielska nazwa | `Ścisłe okno godzinowe` |
| `Adaptive batch` | Angielska nazwa | `Adaptacyjny rozmiar paczki` |
| `heartbeat_tick` | Angielska nazwa stage | `Sygnał życia` |
| `auto_start` / `auto_done` | Angielska nazwa stage | `Tłumaczenie: start` / `Tłumaczenie: zakończono` |
| `dispatch` | Angielska nazwa stage | `Wybór zadania` |
| `signal` | Angielska nazwa stage | `Sygnał` |
| `RUNNING` / `IDLE` / `INACTIVE` | Angielska nazwa | `DZIAŁA` / `BEZCZYNNY` / `NIEAKTYWNY` |

### P2. Sekcja LIVE — za mało informacji, błędne dane
| Problem | Opis |
|---|---|
| `Postęp: 0/0 keys` | Zawsze pokazuje 0/0 — brak prawdziwych danych progression |
| Brak info o bieżącej pracy | Nie widać CO worker aktualnie robi (tłumaczy, waliduje, skanuje) |
| Brak kontekstu pracy | Nie widać JAKIE funkcje/etapy wykonuje w ramach tłumaczenia |
| Tylko 1 linia `LIVE` | Powinno być więcej: bieżący język, plik, ile kluczy, metoda (GT/TM/dict) |
| Brak live activity per faza | Każda główna praca (tłumaczenie, walidacja, sync) powinna mieć swój live |

### P3. Brak historii pracy i informacji o językach
| Problem | Opis |
|---|---|
| Nie widać jakie języki pracują | Nie wiem czy teraz robi tylko ES czy 5 języków naraz |
| Brak listy aktywnych języków | Brak "aktualnie przetwarzane: ES, PL, RU" |
| Brak info godzinowe | Nie widać co zrobiono w tej godzinie |
| Brak info dzienne | Sekcja "Dziś" ma za mało danych |
| Brak info tygodniowe | Brak podsumowania tygodniowego |
| Brak historii per etap/funkcja | Nie widać np. "repair_identical: 5 cykli", "parallel_translate: 12 cykli" |

### P4. Inne brakujące informacje
| Problem | Opis |
|---|---|
| Brak szacowanego ETA | Kiedy skończy się tłumaczenie danego języka / wszystkich |
| Brak trendu | Czy tempo rośnie / spada / stoi |
| Brak wykresu / pasków postępu per język | Wizualizacja postępu języków |
| Sekcja MIGRATION wciąż widoczna | Powinna być "PRE_MIGRATION (skan)" albo ukryta |
| Tabele za długie | Lista 52 języków — lepiej TOP 10 + reszta w `<details>` |

---

## ✅ Lista zadań do wykonania

### 🔹 Grupa A: Polonizacja nazw i terminów (każdy po ~15 min)

| # | Zadanie | Gdzie | Status |
|---|---------|-------|--------|
| A1 | Zamienić `Guard fail rate` → `Odrzucone (strażnik jakości) %` | LIVE, Strict Hourly, KPI | ⬜ |
| A2 | Zamienić `Throughput` → `Przepustowość (kluczy/h)` | Strict Hourly | ⬜ |
| A3 | Zamienić `Pending skip` → `Pominięte (kat. nieaktywna)` | Strict Hourly | ⬜ |
| A4 | Zamienić `No progress rate` → `Cykle bez postępu %` | Strict Hourly | ⬜ |
| A5 | Zamienić `Suspicious` → `Podejrzane tłumaczenia` | Strict Hourly, Quality | ⬜ |
| A6 | Zamienić `EN-copy` → `Kopie EN (bez tłumaczenia)` | Translation tabele | ⬜ |
| A7 | Zamienić `Coverage` → `Pokrycie` | Translation | ⬜ |
| A8 | Zamienić `Net effective translated` → `Tłumaczeń netto` | META | ⬜ |
| A9 | Przetłumaczyć nazwy etapów (`heartbeat_tick` → `sygnał życia`, `auto_start` → `start tłumaczenia`, `auto_done` → `tłumaczenie zakończone`, `dispatch` → `wybór zadania`) | LIVE, History | ⬜ |
| A10 | Zamienić statusy (`RUNNING` → `DZIAŁA`, `IDLE` → `BEZCZYNNY`, `INACTIVE` → `NIEAKTYWNY`) | META, LIVE, nagłówki sekcji | ⬜ |
| A11 | Zamienić nagłówki tabel z angielskiego | Daily report, Strict Window | ⬜ |
| A12 | Zamienić `Repair Queue` → `Kolejka napraw` | Daily report | ⬜ |

### 🔹 Grupa B: Rozbudowa sekcji LIVE (łącznie ~2-3h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| B1 | **Naprawić progress 0/0** | Przekazywać prawdziwe wartości `done/total` z translate_batch do activity.json. Źródło: `translate_limit`, `translated_count`, `guard_fail_count` — te zmienne istnieją w auto_translate ale nie są zapisywane do activity progress | ⬜ |
| B2 | **Dodać "Co teraz robi worker"** | Nowa linia w LIVE: `Praca: Tłumaczenie automatyczne (Google Translate)` / `Naprawa kopii EN` / `Walidacja jakości` / `Synchronizacja kluczy` — mapowanie stage → opis po polsku | ⬜ |
| B3 | **Dodać "Aktywne języki"** | Parsowanie ostatnich N wpisów z `activity.json.recent[]` — wyciągnąć unikalne `category` (=język) z ostatnich 10 min. Wyświetlić: `Aktywne języki (10 min): ES, PL, CS` | ⬜ |
| B4 | **Dodać "Metoda tłumaczenia"** | Z `translation_guard_latest.json` lub `translation_recent_latest.json` — widać `method: gt / tm / dict / simple`. Wyświetlić: `Metoda: Google Translate + TM fallback` | ⬜ |
| B5 | **Dodać "Statystyki bieżącego cyklu"** | Z `worker_cycle_perf_latest.json`: ile kluczy przetłumaczono, ile guard_fail, ile czasu na cykl | ⬜ |
| B6 | **LIVE per faza** | Osobne live info dla: TŁUMACZENIE, WALIDACJA, SYNC. Jeśli worker jest w tłumaczeniu → pokaż tłumaczenie live. Jeśli w walidacji → pokaż walidacja live | ⬜ |
| B7 | **Funkcje/etapy bieżącej pracy** | Lista aktualnie wykonywanych sub-tasków (np. `→ repair_identical_to_en`, `→ parallel_translate`, `→ translate_batch`, `→ quality_audit`). Już istnieją jako `stage` w `ops.jsonl` | ⬜ |

### 🔹 Grupa C: Informacje o językach — co robi teraz, co robił (łącznie ~2h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| C1 | **Tabela "Języki ostatnia godzina"** | Z `strict_hourly_window_latest.json` + `ops.jsonl`: per język ile kluczy przetłumaczono, ile guard_fail, ile repair. Wyświetlić TOP 10 aktywnych | ⬜ |
| C2 | **Tabela "Historia pracy per język (24h)"** | Z `statusd_daily_report.json` → `coverage_snapshot`: zmiana pokrycia PL 42.02% → teraz 42.14%, ES 73.15% → 73.15%. Wyświetlić delta: `+0.12%` | ⬜ |
| C3 | **"Aktualny język focus"** | Z `worker_config.json` → `focus_lang`. Wyświetlić: `Focus: brak (tryb tier-round-robin)` lub `Focus: ES (priorytetowy)` | ⬜ |
| C4 | **"Kolejka języków"** | Z tier systemu: wyświetlić obecną kolejkę → `Następne: PL → ES → DE → FR → ...` | ⬜ |
| C5 | **Mini-sekcja per aktywny język** | Dla TOP 5 aktywnych języków: osobna mała tabela z kluczami, pokryciem, ostatnim plikiem, przyrostem /h | ⬜ |

### 🔹 Grupa D: Informacje godzinowe / dzienne / tygodniowe (łącznie ~3h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| D1 | **Sekcja "Ta godzina"** | Nowa sekcja z: ile kluczy, ile języków, ile cykli, ile błędów, najaktywniejszy język, najaktywniejszy plik, dominujący etap pracy, trend vs poprzednia godzina | ⬜ |
| D2 | **Sekcja "Dziś (24h)" — rozszerzyć** | Aktualna sekcja "Dziś" ma za mało danych. Dodać: sumę tłumaczeń per język, TOP 5 plików, porównanie z wczoraj, trend tempo, lista wykonanych etapów/funkcji | ⬜ |
| D3 | **Sekcja "Ten tydzień"** | Nowa sekcja: suma 7 dni, wykres ASCII tłumaczeń per dzień, zmiana pokrycia globalnego per dzień, ile nowych kluczy dodano | ⬜ |
| D4 | **Trend / porównanie** | W każdej sekcji (godzinowa/dzienna/tygodniowa) dodać strzałki: `↑ +15%` / `↓ -3%` / `→ bez zmian` vs poprzedni okres | ⬜ |
| D5 | **Historia etapów pracy** | Tabela: ile razy w danym okresie worker wykonał `repair_identical`, `parallel_translate`, `translate_batch`, `quality_audit`, `sync_file_done`. Źródło: `ops.jsonl` | ⬜ |

### 🔹 Grupa E: Postęp i ETA (łącznie ~1.5h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| E1 | **ETA per język** | Na podstawie obecnego tempa (kluczy/h) wyliczyć ile godzin do 95% pokrycia per język. Wyświetlić: `PL: ~120h do 95%` | ⬜ |
| E2 | **ETA globalne** | Ile godzin/dni do ukończenia WSZYSTKICH języków (95% coverage) | ⬜ |
| E3 | **Paski postępu per język (TOP 20)** | Bardziej wizualne paski ASCII: `ES ████████████████░░░░ 73%` — już istnieją w Roadmap, ale trzeba dodać do głównej tabeli języków | ⬜ |
| E4 | **Zmiana pokrycia (trend 24h)** | `PL: 42.02% → 42.14% (+0.12%)` per język — porównanie z 24h temu | ⬜ |

### 🔹 Grupa F: Refaktor i czytelność (łącznie ~1h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| F1 | **Ukryć mało ważne języki** | TOP 20 widoczne, reszta w `<details>Pokaż wszystkie (53)</details>` | ⬜ |
| F2 | **Skompresować duplikaty sekcji** | Tabela TM/Etap2 jest zduplikowana. Usunąć duplikaty | ⬜ |
| F3 | **Uporządkować kolejność sekcji** | Najważniejsze na górze: META → LIVE → Ta godzina → Języki → Postęp → Dziś → Tydzień → Jakość → Historia | ⬜ |
| F4 | **Sekcja MIGRATION → PRE_MIGRATION** | Zmienić nagłówek, opis — skan plików bez modyfikacji | ⬜ |
| F5 | **Usunąć martwe metryki** | `Cykl #1` (od uruchomienia — bezwartościowe), `Reconcile korekta rejestru` (techniczne) | ⬜ |
| F6 | **Dodać legendę** | Na dole: co oznaczają emoji, co oznaczają statusy, co to tier | ⬜ |

### 🔹 Grupa G: Nowe sekcje / informacje dodatkowe (łącznie ~2h)

| # | Zadanie | Opis | Status |
|---|---------|------|--------|
| G1 | **"Podsumowanie dla właściciela"** | Nowa sekcja na samej górze: 3-4 zdania po polsku: „Worker tłumaczy 53 języków. Najlepszy: ES 73%. Tempo: ~2000 kluczy/h. ETA do ukończenia ES: 48h." | ⬜ |
| G2 | **"Problemy i uwagi"** | Lista: co nie działa, co jest wolne, jakie języki mają problemy z jakością. Źródło: `quality_dashboard.json` + `suspicious_log.jsonl` | ⬜ |
| G3 | **"Ostatnie komendy"** | Lista ostatnich 5 komend wykonanych przez właściciela (z `worker_commands.txt`). Np.: `FORCE:scripts:ONCE` — wykonana 14:05 | ⬜ |
| G4 | **"Zdrowie systemu"** | Sekcja: czy worker działa, czy statusd działa, dysk, ostatni git push, ile czasu od restartu. Źródło: `guardian_health.json` + heartbeat | ⬜ |
| G5 | **"Wykres ASCII dzienny"** | W sekcji "Dziś": wykres godzina po godzinie ile przetłumaczono. Np.: `12:00 ██████ 340`, `13:00 ████████████ 680` | ⬜ |

---

## 📐 Proponowana nowa struktura I18N_STATUS.md

```
1.  📋 PODSUMOWANIE DLA WŁAŚCICIELA (G1)
     → 3-4 zdania po polsku, najważniejsze metryki

2.  🧭 META
     → Wersja, języki, klucze, czas aktualizacji

3.  🔴 LIVE — Bieżąca praca
     → Co teraz robi (B2), aktywne języki (B3), metoda (B4)
     → Progress z prawdziwymi danymi (B1)
     → Funkcje/etapy bieżące (B7)

4.  ⏱️ TA GODZINA (D1)
     → Tłumaczenia, język, pliki, etapy, trend

5.  🌍 JĘZYKI — Stan tłumaczeń
     → TOP 20 z paskiem postępu (E3)
     → Aktywne języki (C1), focus (C3), kolejka (C4)
     → ETA per język (E1)
     → Trend 24h (E4)
     → <details> reszta </details> (F1)

6.  📅 DZIŚ (24h) — rozszerzone (D2)
     → Suma, per język, TOP pliki, trend, wykres ASCII (G5)

7.  📆 TEN TYDZIEŃ (D3)
     → Suma 7d, wykres per dzień, zmiana pokrycia

8.  🔍 PRE_MIGRATION (skan) (F4)
     → Pliki, klucze EN, kategorie

9.  🔬 JAKOŚĆ (A5)
     → Audyt, podejrzane, problemy (G2)

10. 📜 HISTORIA
     → Ostatnie akcje, ostatnie komendy (G3)
     → Historia etapów (D5)

11. 🏥 ZDROWIE SYSTEMU (G4)
     → Worker, statusd, dysk, git

12. 🗺️ ROADMAP
     → Kategorie z paskami

13. 🏷️ LEGENDA (F6)
```

---

## 🔌 Źródła danych (co już istnieje i wystarczy sparsować)

| Dane | Plik | Co zawiera |
|------|------|------------|
| Bieżąca aktywność | `i18n/status/activity.json` | phase, stage, category, file, progress, recent[] |
| Stan workera | `i18n/status/worker_state.json` | kategorie, backoff, cykle |
| Perf per cykl | `i18n/status/worker_cycle_perf.jsonl` | czas, mode, category, events |
| Perf latest | `i18n/status/worker_cycle_perf_latest.json` | ostatni cykl |
| Strict hourly | `i18n/status/strict_hourly_window_latest.json` | okno 1h: cykle, tłumaczenia, guard_fail |
| Dzienny raport | `i18n/status/statusd_daily_report.json` | KPI 24h, quality 24h, coverage per język |
| Tygodniowy | `i18n/status/weekly_multilang_report.json` | dane tygodniowe |
| Guard raporty | `i18n/status/translation_guard_report.jsonl` | guard_fail per język/plik |
| Guard latest | `i18n/status/translation_guard_latest.json` | ostatni guard check |
| Tłumaczenia recent | `i18n/status/translation_recent_latest.json` | ostatnie tłumaczenie |
| Ops log | `i18n/status/ops.jsonl` | wszystkie operacje z phase/stage/category |
| Quality audit | `i18n/status/quality_audit_latest.json` | wynik audytu jakości |
| Quality dashboard | `i18n/status/quality_dashboard.json` | dashboard jakości |
| Suspicious | `i18n/status/suspicious_log.jsonl` | podejrzane tłumaczenia |
| Adaptive batch | `i18n/status/adaptive_batch_state.json` | rozmiar paczki, GF rate |
| Translation overview | `i18n/status/translation_global_overview.json` | globalne pokrycie, migracja |
| Guardian health | `i18n/status/guardian_health.json` | zdrowie systemu |
| Daily snapshots | `i18n/status/daily/*.json` | dzienne snapshoty |
| Repair queue | `i18n/status/identical_to_en_repair_queue.json` | kolejka napraw EN-copy |
| Dispatch state | `i18n/status/translation_dispatch_state.json` | stan dispatchera języków |
| Lang sequence | `i18n/status/lang_sequence.log` | sekwencja wybranych języków |
| Worker config | `worker_config.json` | konfiguracja (focus, batch, GT on/off) |

---

## ⏱️ Szacowany czas realizacji wszystkich grup

| Grupa | Opis | Szacowany czas | Priorytet |
|-------|------|----------------|-----------|
| **A** | Polonizacja terminów | 2-3h | 🔴 WYSOKI |
| **B** | Rozbudowa LIVE | 2-3h | 🔴 WYSOKI |
| **C** | Info o językach | 2h | 🔴 WYSOKI |
| **D** | Godzinowe/dzienne/tygodniowe | 3h | 🟡 ŚREDNI |
| **E** | Postęp i ETA | 1.5h | 🟡 ŚREDNI |
| **F** | Refaktor i czytelność | 1h | 🟡 ŚREDNI |
| **G** | Nowe sekcje | 2h | 🟢 DODATKOWY |
| **RAZEM** | | **~14-16h** | |

---

## 📌 Proponowana kolejność realizacji

1. **A1-A12** — Polonizacja (szybkie, niezależne od siebie)
2. **B1** — Naprawić progress 0/0 (najpilniejszy bug)
3. **B2, B3** — Co robi + aktywne języki (najważniejsze brakujące info)
4. **C1, C2** — Języki per godzina/dzień
5. **D1** — Sekcja "Ta godzina"
6. **F3, F4** — Uporządkować sekcje + PRE_MIGRATION
7. **G1** — Podsumowanie dla właściciela
8. **E1-E4** — ETA i trendy
9. **D2, D3** — Rozszerzone "Dziś" i "Tydzień"
10. **B4-B7, C3-C5** — Pozostałe rozszerzenia LIVE i języków
11. **F1, F2, F5, F6** — Porządki, legenda
12. **G2-G5** — Dodatkowe nowe sekcje

---

*Dokument wygenerowany 2026-02-14. Odhaczaj zadania jako ✅ po wykonaniu.*
