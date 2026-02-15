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

---

## 🆕 Aktualizacja 2026-02-14 (Plan 2 sesji: PRE_MIGRATION + DOCUMENTATION w I18N_STATUS.md)

**Powód aktualizacji:** obecny plan statusu mocno skupia się na tłumaczeniach, a brak pełnego, równorzędnego podglądu dla `PRE_MIGRATION` i `DOCUMENTATION` powoduje, że operator nie widzi jasno co worker zrobił i co robi teraz poza AUTO_TRANSLATE.

**Cel nadrzędny:**
1. `I18N_STATUS.md` ma pokazywać PRE_MIGRATION i DOCUMENTATION tak samo czytelnie jak tłumaczenie.
2. Każda z tych faz ma mieć LIVE + metryki cyklu + metryki godzinowe + metryki 24h + historię etapów.
3. Dashboard ma raportować nie tylko „ile”, ale też „co konkretnie zostało wykonane” (pliki, wzorce, artefakty, błędy, pominięcia).

## 🎯 Podział pracy na 2 sesje

### Sesja 1 (Status i prezentacja): `I18N_STATUS.md` + kontrakt telemetryczny

**Szacowany czas:** 8-10h  
**Efekt sesji:** pełna widoczność PRE_MIGRATION i DOCUMENTATION w dashboardzie.

| ID | Priorytet | Zadanie | Źródło danych | Wynik w `I18N_STATUS.md` |
|---|---|---|---|---|
| S1-01 | P0 | Dodać LIVE-card `PRE_MIGRATION` | `pre_migration_todo_latest.json`, `activity.json`, `ops.jsonl` | „Skanuje: <kategoria>, plik X/Y, trafienia, top pattern, ETA skanu” |
| S1-02 | P0 | Dodać LIVE-card `DOCUMENTATION` | `documentation_latest.json`, `documentation_state.json`, `activity.json` | „Dokumentuje: plik X/Y, cursor, files_done, errors, ETA” |
| S1-03 | P0 | Dodać sekcję „Co zrobił w bieżącym cyklu” dla PM/DOC | `ops.jsonl`, `worker_cycle_perf_latest.json` | lista operacji z ostatniego cyklu |
| S1-04 | P0 | Dodać sekcję „Ta godzina — PRE_MIGRATION/DOC” | `strict_hourly_window_latest.json` + agregacja z `ops.jsonl` | hits/h, files_scanned/h, docs_generated/h, errors/h |
| S1-05 | P0 | Dodać sekcję „Dziś (24h) — PRE_MIGRATION/DOC” | `statusd_daily_report.json`, `historia_daily.json` | wolumen i trendy 24h |
| S1-06 | P0 | Dodać mapowanie stage -> ludzki opis PL dla PM/DOC | `activity.json.stage`, `ops.jsonl.stage` | „Co robi worker teraz” po polsku |
| S1-07 | P1 | Dodać „ostatnie artefakty” PM/DOC | `pre_migration_todo_latest.json`, `documentation_latest.json` | timestamp + ścieżki wygenerowanych plików |
| S1-08 | P1 | Dodać „Top źródła pracy” | `ops.jsonl` | top kategorie i top pliki dla PM/DOC |
| S1-09 | P1 | Dodać „jakość wykonania PM/DOC” | `documentation_latest.json.errors`, `pre_migration_todo_latest.json.hits` | error rate, skip rate, parse_fail rate |
| S1-10 | P1 | Dodać sekcję „Historia etapów PM/DOC” | `ops.jsonl` | ile razy wykonano etapy scan/extract/render/index |
| S1-11 | P1 | Ujednolicić layout z sekcjami tłumaczeń | `I18N_STATUS.md` renderer | jedna struktura kart: Translation, PM, DOC |
| S1-12 | P2 | Dodać mini-ASCII trend 6h dla PM/DOC | `ops.jsonl` + agregacja godzinowa | szybki trend aktywności |

### Sesja 2 (Wykonanie i narzędzia): poprawność PRE_MIGRATION/DOCUMENTATION + lepsza ekstrakcja tekstów gracza

**Szacowany czas:** 12-16h  
**Efekt sesji:** worker lepiej wykrywa teksty widoczne dla gracza w serwerze, kliencie, html i innych źródłach, a dokumentacja staje się bardziej semantyczna i użyteczna.

| ID | Priorytet | Zadanie | Obszar |
|---|---|---|---|
| S2-01 | P0 | Wprowadzić zunifikowany „Extraction Catalog” (jedno źródło prawdy o kandydatach) | pre-migration tooling |
| S2-02 | P0 | Rozszerzyć skaner Lua o kontekst runtime-calls (`npcHandler:say`, `sendTextMessage`, `broadcastMessage`, `voices.text`) | server Lua |
| S2-03 | P0 | Dodać parser C++ pod literały UI/komunikatów gracza (nie tylko regex line-by-line) | server/client C++ |
| S2-04 | P0 | Dodać parser OTUI/OTML dla `text`, `tooltip`, `title`, `description` | client UI |
| S2-05 | P0 | Dodać parser HTML/PHP/Twig dla widocznych stringów (z filtrami template) | web/install panel |
| S2-06 | P0 | Dodać klasyfikację „player-visible vs technical” z confidence score | wszystkie źródła |
| S2-07 | P1 | Dodać blacklist/whitelist wzorców i tokens (false positive control) | quality |
| S2-08 | P1 | Dodać queue manual review dla niskiego confidence | status + review flow |
| S2-09 | P1 | Dodać cross-link candidate -> istniejący i18n key | deduplikacja |
| S2-10 | P1 | Dodać metrykę „coverage ekstrakcji” per źródło (lua/cpp/otui/html/php/twig) | KPI |
| S2-11 | P1 | Dodać semantyczne sekcje docs: events, callbacks, i18n touchpoints, unresolved symbols | documentation |
| S2-12 | P1 | Dodać raport „czego worker nie zrozumiał” (parse failures / unsupported syntax) | documentation + PM |
| S2-13 | P2 | Dodać incremental checksum cache dla parserów | performance |
| S2-14 | P2 | Dodać benchmark i limity czasu per parser | stability |

## 📦 Kontrakt danych dla statusu (nowe/rozszerzone pola)

### 1) Blok `pre_migration_live`

```json
{
  "mode": "PRE_MIGRATION",
  "category": "npc",
  "scope": "all",
  "files_scanned": 312,
  "files_total": 1450,
  "hits": 284,
  "top_patterns": ["npcHandler:say", "sendTextMessage"],
  "current_file": "data-otservbr-global/npc/ashop.lua",
  "eta_seconds": 420,
  "last_artifact": "i18n/status/pre_migration_todo/npc.json",
  "updated_at": "2026-02-14T22:10:00Z"
}
```

### 2) Blok `documentation_live`

```json
{
  "mode": "DOCUMENTATION",
  "batch": 50,
  "cursor": 900,
  "files_done": 900,
  "files_total": 7935,
  "errors": 2,
  "current_file": "src/game/creature.cpp",
  "last_doc_file": "docs/i18n/project/files/src__game__creature.cpp.md",
  "index_updated": true,
  "eta_seconds": 3600,
  "updated_at": "2026-02-14T22:11:00Z"
}
```

### 3) Blok `pm_doc_cycle_stats` (wspólny per cykl)

```json
{
  "cycle": 1284,
  "phase": "PRE_MIGRATION",
  "files_processed": 72,
  "entries_added": 49,
  "errors": 0,
  "duration_ms": 12432,
  "ops": ["SCAN_START", "PATTERN_MATCH", "ARTIFACT_WRITE", "SCAN_DONE"]
}
```

## 🧱 Render `I18N_STATUS.md` (docelowy układ PM/DOC)

1. `🔴 LIVE`  
Linia 1: aktywna faza + stage + czas od ostatniego heartbeat.  
Linia 2: karta Translation (jak dziś).  
Linia 3: karta PRE_MIGRATION (S1-01).  
Linia 4: karta DOCUMENTATION (S1-02).

2. `⏱️ TA GODZINA`  
- osobne kolumny: Translation, PRE_MIGRATION, DOCUMENTATION,
- metryki per faza: processed, added, error_rate, avg_cycle_ms.

3. `📅 DZIŚ (24h)`  
- suma i trend dla PM/DOC,
- top 5 kategorii PM,
- top 5 katalogów dokumentowanych.

4. `📜 HISTORIA ETAPÓW`  
- stage histogram oddzielnie dla Translation/PM/DOC,
- ostatnie 20 operacji PM/DOC z `ops.jsonl`.

## 🧪 Testy akceptacyjne (dla planu 2 sesji)

| Test | Kryterium |
|---|---|
| T1 | Po wymuszeniu `PREMIG:all` LIVE pokazuje postęp plików i hits != 0 |
| T2 | Po wymuszeniu `DOCUMENTATION:50` LIVE pokazuje cursor/files_done/current_file |
| T3 | Sekcja „Ta godzina” raportuje niezerowe metryki PM/DOC gdy fazy działały |
| T4 | Sekcja „Dziś (24h)” pokazuje trend PM/DOC vs poprzednie 24h |
| T5 | `ops.jsonl` i `activity.json` mają spójne nazwy stage dla PM/DOC |
| T6 | W razie błędu parsera status pokazuje error_count i ostatni błąd |

## ✅ Definition of Done — Sesja 1

1. `I18N_STATUS.md` ma pełne LIVE + Hourly + Daily dla PRE_MIGRATION i DOCUMENTATION.
2. Operator widzi „co worker zrobił” w obu fazach na poziomie pliku i etapu.
3. Dane są aktualizowane bez regresji dla AUTO_TRANSLATE.
4. Testy T1-T6 przechodzą.

## ✅ Definition of Done — Sesja 2

1. Ekstrakcja tekstów gracza obejmuje server + client + html/php/twig + otui/otml.
2. Mamy confidence score i manual review queue dla trudnych przypadków.
3. Dokumentacja raportuje także „niewyjaśnione/niezrozumiane” fragmenty.
4. Dashboard pokazuje coverage ekstrakcji per źródło i poziom jakości parserów.

## 🚀 Kolejność wdrożenia (rekomendowana)

1. Sesja 1: S1-01..S1-06 (krytyczne dla widoczności operacyjnej).
2. Sesja 1: S1-07..S1-12 (uzupełnienie i ergonomia).
3. Sesja 2: S2-01..S2-06 (fundament jakości ekstrakcji).
4. Sesja 2: S2-07..S2-12 (jakość, review, raportowanie braków).
5. Sesja 2: S2-13..S2-14 (wydajność i stabilizacja).

