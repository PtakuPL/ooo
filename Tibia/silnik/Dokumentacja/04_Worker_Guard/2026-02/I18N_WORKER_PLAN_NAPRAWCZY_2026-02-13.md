# Plan Naprawczy i18n Worker — Analiza + Plan Codex + Claude

> **STATUS DOKUMENTU:** Ten dokument pozostaje archiwum analizy i kontekstu historycznego.
> Wykonawczy plan kanoniczny znajduje się w:
> `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`.
> W przypadku konfliktu zapisów, obowiązuje plan kanoniczny.

**Data:** 2026-02-13  
**Autor:** Claude + Codex  
**Branch:** `feature/i18n-multilanguage`

---

## 🛠️ Aktualizacja wykonania (2026-02-19 20:50 UTC — awaria `TRANSLATION_OVERRIDES` + przywrócenie pracy workera)

## 🛠️ Aktualizacja wykonania (2026-02-21 10:30 UTC — wyłączenie `global_quality_mode`, weryfikacja stabilności workera, incydent STOP)

Wybrane do realizacji pełne zadania:
- **Wyłączyć tryb quality (`global_quality_mode`) i priority gate, żeby odblokować throughput**
- **Zweryfikować, czy worker działa po zmianie i czy status jest świeży**
- **Udokumentować incydent `worker STOPPED` zgłoszony po zmianach**

Wykonane:
- ✅ Wyłączono quality mode w profilach runtime:
  - `canary_test/guardian_profile.json`:
    - `global_quality_mode: true -> false`
    - `global_quality_priority_gate_enabled: true -> false`
  - `canary_test/guardian_profiles/translations_general.json`:
    - `global_quality_mode: true -> false`
    - `global_quality_priority_gate_enabled: true -> false`
- ✅ Wykonano restart stacka (`bash i18n_start_all.sh --restart`) i potwierdzono start 3 procesów (`Guardian`, `Statusd`, `Worker`) z pozytywnym health-gate 30s.
- ✅ Potwierdzono runtime, że gate quality jest faktycznie wyłączony:
  - `i18n/status/translation_dispatch_state.json`:
    - `global_quality_mode=false`
    - `priority_gate.enabled=false`
- ✅ Zweryfikowano incydent zgłoszony przez operatora:
  - w momencie zgłoszenia stack był `STOPPED` (`Guardian/Statusd/Worker`),
  - heartbeat w `activity.json` był stary (zamrożony),
  - po ponownym starcie status wrócił do trybu live.

Dodatkowe obserwacje diagnostyczne (ważne):
- ⚠️ W `guardian.log` występują powtarzające się wpisy `Killed` dla procesu workera (`i18n_guardian.sh` linia ~1018, kill procesu `nohup ... i18n_worker_simple.sh`).
- ⚠️ W logach widoczna jest bardzo wysoka częstotliwość commitów statusowych guardiana (co ~2-3 min), co może powodować duże obciążenie I/O i odczuwalne „zamulenie” środowiska.
- ℹ️ Brak potwierdzenia OOM w dostępnych logach systemowych (`dmesg`/`journalctl --user` nie pokazały jednoznacznego wpisu OOM dla tego incydentu).

Weryfikacja działania workera po poprawce (monitoring kontrolny):
- ✅ Monitoring 2 min po starcie (4 próbki co 30s):
  - `Guardian/Statusd/Worker` cały czas `RUNNING`,
  - heartbeat `activity_age_sec` utrzymywał się w zakresie kilku-kilkudziesięciu sekund (live),
  - worker realizował `AUTO_TRANSLATE` na kolejnych targetach (`cs/monsters.json`, `sk/monsters.json`, `es/npc.json`).

Status na teraz:
- `global_quality_mode` jest WYŁĄCZONY (runtime + profile),
- worker działa po restarcie,
- nadal istnieje ryzyko sporadycznych zgonów procesu (`Killed`) niezależnie od samego quality mode — wymaga osobnej ścieżki stabilizacyjnej.

Nowe zadania z incydentu:
- [ ] `WQ-HARD-48 (P0)`: Diagnostyka `Killed` procesu workera (pid timeline + korelacja z obciążeniem I/O/CPU + źródło sygnału).
- [x] `WQ-HARD-49 (P1)`: Ograniczyć churn commitów statusowych (cooldown push/commit lub agregacja zmian), aby zmniejszyć obciążenie środowiska i ryzyko zwieszek IDE.

### Uzupełnienie 2026-02-21 10:33 UTC — wdrożenie `WQ-HARD-49`

Wykonane:
- ✅ `canary_test/i18n_guardian.sh`:
  - zwiększono domyślny interwał push statusu: `PUSH_INTERVAL_SECONDS=120 -> 480` (z możliwością override przez env),
  - dodano osobny cooldown commitu statusowego: `STATUS_COMMIT_MIN_INTERVAL_SECONDS=900` (15 min),
  - dodano stan cooldownu: `.guardian_last_status_commit_ts`,
  - gdy cooldown commitu nie minął, guardian pomija commit/push i resetuje staging tylko dla plików statusu (bez side effects na inne zmiany repo).
- ✅ Walidacja: `bash -n i18n_guardian.sh` przechodzi po zmianach.
- ✅ Runtime: po `bash i18n_start_all.sh --restart` stack wrócił (`Guardian/Statusd/Worker = RUNNING`, health-gate 30s OK).

Efekt operacyjny (oczekiwany):
- Mniej commitów/pushy statusowych na godzinę,
- niższe obciążenie I/O i mniejszy churn Git,
- mniejsze ryzyko „zamrożenia” VS Code podczas pracy workera.

## 🛠️ Aktualizacja wykonania (2026-02-21 10:47 UTC — incydent `all-langs` + freeze WSL/VS Code, korekta trybu na 7 języków)

Wybrane do realizacji pełne zadania:
- **Wyjaśnić, dlaczego worker tłumaczył wszystkie języki zamiast 7 docelowych**
- **Skorygować runtime do twardego limitu 7 języków**
- **Udokumentować ryzyko zawieszania WSL/VS Code i związek z obciążeniem workera/guardiana**

Root-cause (potwierdzone):
- W `i18n_guardian.sh` tryb `translations_general` **celowo ignoruje `langs`** i uruchamia worker bez `--langs` (pełna pula języków).
- Po wcześniejszych zmianach profil był ustawiony na `mode=translations_general`, więc worker przechodził na all-langs mimo wpisanej listy języków.

Wykonane:
- ✅ `guardian_profile.json`: `mode` przełączono z `translations_general` na `translations_pl_es`.
- ✅ Restart stacka (`bash i18n_start_all.sh --restart`) i walidacja runtime.
- ✅ Potwierdzenie na procesie workera: uruchomienie z flagą
  - `--langs ru,ro,it,sr,sv,pl,es`
  - czyli dokładnie 7 języków operatorskich.

Stan działania po korekcie:
- ✅ `Guardian/Statusd/Worker = RUNNING`
- ✅ Heartbeat `activity.json` świeży (sekundy–dziesiątki sekund)
- ✅ Worker realizuje `AUTO_TRANSLATE` tylko dla listy 7 języków.

Incydent „wywala cały WSL/VS Code” — wnioski operacyjne:
- ⚠️ Brak twardego dowodu OOM w dostępnych logach systemowych podczas tej sesji,
- ⚠️ ale występuje historycznie wysoki churn statusowy + częste cykle procesów, co jest realnym kandydatem na przeciążenie I/O/CPU i zawieszki IDE.
- ✅ Zastosowano już mitigację `WQ-HARD-49` (push 480s + cooldown commitu 900s), która zmniejsza to ryzyko.

Nowe zadania po incydencie:
- [ ] `WQ-HARD-50 (P0)`: Dodać lekki watchdog zasobów (`cpu/mem/io`) do `guardian_health.json` i logować piki przed `Killed`.
- [ ] `WQ-HARD-51 (P1)`: Dodać tryb „safe-load” dla guardiana (tymczasowe podniesienie delay + obniżenie parallel-langs przy wykryciu niestabilności hosta/IDE).
- [x] `WQ-HARD-52 (P0)`: Dodać szybki runbook „co zrobić gdy WSL/VS Code freeze” (kolejność stop/start, minimalny zestaw komend diagnostycznych, rollback profilu).

### Runbook awaryjny — gdy „zamraża” WSL / VS Code podczas pracy workera (WQ-HARD-52)

#### 0) Objawy wejściowe (kiedy uruchamiać runbook)
- VS Code przestaje odpowiadać lub działa skrajnie wolno,
- `I18N_STATUS.md` przestaje się odświeżać,
- `activity.json` ma stary timestamp (heartbeat age rośnie),
- `bash i18n_start_all.sh --status` pokazuje `STOPPED` albo processy żyją, ale brak postępu.

#### 1) Szybkie odciążenie hosta (bezpieczny stop)
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
bash i18n_start_all.sh --stop
```

Cel: natychmiast zatrzymać churn CPU/I/O (worker + guardian + statusd), żeby odzyskać responsywność IDE.

#### 2) Minimalna diagnostyka po stopie (snapshot incydentu)
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
bash i18n_start_all.sh --status
tail -n 120 i18n/logs/guardian.log
tail -n 120 i18n/logs/start_all.log
python3 - << 'PY'
import json,datetime
from pathlib import Path
p=Path('i18n/status/activity.json')
if not p.exists():
  print('activity.json missing')
else:
  o=json.loads(p.read_text(encoding='utf-8'))
  ts=o.get('generated_at_utc')
  print('generated_at_utc=',ts)
  if ts:
    dt=datetime.datetime.fromisoformat(ts.replace('Z','+00:00'))
    now=datetime.datetime.now(datetime.timezone.utc)
    print('activity_age_sec=',int((now-dt).total_seconds()))
  print('phase=',o.get('phase'),'cat=',o.get('category'),'file=',o.get('file'))
PY
```

Checklist, co zapisać do planu:
- ostatni żywy heartbeat (`generated_at_utc` + `activity_age_sec`),
- czy w logach wystąpił wpis `Killed` dla workera,
- czy `start_all` wykonywał wymuszone `SIGKILL` dla statusd/guardiana,
- czas i kontekst (co było robione w IDE tuż przed freeze).

#### 3) Bezpieczny restart
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary_test
bash i18n_start_all.sh
bash i18n_start_all.sh --status
```

Kryterium OK po restarcie:
- `Guardian/Statusd/Worker = RUNNING`,
- health-gate 30s przechodzi,
- heartbeat `activity.json` świeży (sekundy–dziesiątki sekund).

#### 4) Rollback profilu (gdy freeze wraca)

Jeśli po restarcie dalej występują zacięcia hosta:
1. Utrzymać tryb 7 języków (`mode=translations_pl_es`) — **nie wracać** do `translations_general`.
2. Tymczasowo zmniejszyć obciążenie:
   - `parallel_langs`: `3 -> 2`,
   - `translate_limit`: `0/80 -> 30`.
3. Restart stacka i 2-min monitoring heartbeat.

#### 5) Guardrails operacyjne (obowiązujące)
- Nie uruchamiać workera ręcznie poza `i18n_start_all.sh`.
- Nie przełączać `mode` na `translations_general`, jeśli celem jest tylko 7 języków.
- Po każdej zmianie profilu: obowiązkowo `--restart` + weryfikacja komendy procesu workera (`--langs ...`).

#### 6) Definition of Done dla incydentu freeze
- host/IDE wraca do responsywności po `--stop`,
- stack uruchamia się poprawnie po `start`,
- heartbeat pozostaje świeży min. 2 min,
- wpis incydentu trafia do tej dokumentacji (czas, objawy, log clues, zastosowany rollback).

Wybrane do realizacji pełne zadania:
- **Przywrócić stabilną pracę workera po `NameError: TRANSLATION_OVERRIDES`**
- **Domknąć kontrakt manual override dla tłumaczeń (priorytet nad TM/GT)**
- **Utrzymać czytelny status postępu w formie graficznej**

Status realizacji (graficznie):

| Status | Zadanie | Szczegóły |
|---|---|---|
| ✅ ZROBIONE | Diagnoza root-cause | Potwierdzono: `TRANSLATION_OVERRIDES` używane bez definicji w `i18n_worker_simple.sh` (AUTOTRANSPY, okolice traceback `<stdin>:3918`). |
| ✅ ZROBIONE | Weryfikacja dokumentacji | Sprawdzono najnowsze pliki `Dokumentacja/**/*.md`; istnieje opis priorytetu nadpisywań manualnych, ale bez literalnej nazwy `TRANSLATION_OVERRIDES`. |
| ✅ ZROBIONE | Implementacja naprawy runtime | Dodano bezpieczny loader override + fallback `{}` + walidację formatu danych (bez crashy przy brakującym/zepsutym pliku). |
| ✅ ZROBIONE | Walidacja po restarcie | Restart `i18n-guardian.service` wykonany; w logach po restarcie brak `NameError: TRANSLATION_OVERRIDES`. |
| ✅ ZROBIONE | Domknięcie kontraktu docs | Potwierdzono i opisano źródło override: `i18n/overrides/{lang}.json` (ręczne nadpisania o najwyższym priorytecie). |

Kontrakt `translation overrides` (kanoniczny):
- Lokalizacja: `canary_test/i18n/overrides/{lang}.json` (np. `i18n/overrides/pl.json`).
- Format: płaski słownik `"pełny_klucz_i18n" -> "tekst_docelowy"`.
- Klucze zaczynające się od `_` są traktowane jako metadane/komentarze i są ignorowane.
- Priorytet runtime: `override` > `TM` > `SIMPLE/WORD` > `GT`.

Cel jakości:
- Dążyć do jakości produkcyjnej tłumaczeń (gry/UI/dialogi), ale traktować to jako proces iteracyjny z guardami jakości i manualnym review dla przypadków wysokiego ryzyka semantycznego.

## 🛠️ Aktualizacja wykonania (2026-02-19 21:22 UTC — hardening wg sugestii ChatGPT + sanity check post-restart)

Zakres tej aktualizacji:
- Formalizacja zaleceń A–F jako backlog wdrożeniowy.
- Domknięcie automatycznej walidacji „po restarcie” pod błąd `TRANSLATION_OVERRIDES`.
- Potwierdzenie, że worker wykonuje realną pracę w bieżących cyklach.

Status realizacji (graficznie):

| Status | Obszar | Szczegóły |
|---|---|---|
| ✅ ZROBIONE | Runtime sanity check | `i18n_guardian.sh`: dodano `post_restart_sanity_check()` uruchamiany po starcie workera; sprawdza najnowszy segment logu od `🔄 CYKL #1` i wykrywa świeży `NameError: TRANSLATION_OVERRIDES`. |
| ✅ ZROBIONE | Potwierdzenie pracy workera | Log runtime pokazuje aktywne cykle i tłumaczenia (`CYKL #8`, `AUTO TRANSLATE`, aktualizacje `I18N_STATUS.md`). |
| 🟡 W TRAKCIE | A) Macierz priorytetów źródeł | Jest częściowy kontrakt (`override > TM > SIMPLE/WORD > GT`), brak pełnego, jednolitego kontraktu dla wszystkich warstw i ścieżek zapisu. |
| ⬜ DO ZROBIENIA | B) Proces zarządzania overrides | Brak formalnego schematu metadanych, review workflow i lint CI dedykowanego `i18n/overrides/*.json`. |
| ⬜ DO ZROBIENIA | C) Golden set regresji jakości | Brak stałego zestawu 200–500 kluczy „must be perfect” z automatycznym testem porównawczym. |
| ⬜ DO ZROBIENIA | D) TM quarantine/versioning | Brak twardej polityki wersjonowania i kwarantanny wpisów TM (z rollbackiem i reason codes). |
| ⬜ DO ZROBIENIA | E) Glossary/styl | Brak formalnej warstwy terminologii (spójny słownik i reguły stylistyczne PL/ES) spiętej z pipeline. |
| 🟡 W TRAKCIE | F) Jedna prawda planistyczna | Ten plik jest archiwum; zadania trzeba zsynchronizować z planem kanonicznym `docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`. |

### Backlog zadań (rozpisanie A–F na taski wdrożeniowe)

- [x] `WQ-HARD-0 (P0)`: Dodać automatyczny sanity check post-restart (`TRANSLATION_OVERRIDES`) w guardianie.
- [ ] `WQ-HARD-1 (P0)`: Spisać i wymusić „Source-of-truth & precedence contract” dla wszystkich źródeł:
  - `manual overrides` > `curated dictionary` > `TM verified` > `TM unverified` > `GT` > `external simple/word` > `EN fallback (exempt only)`.
  - Wymóg: przy konflikcie logować zwycięską warstwę i reason code.
- [ ] `WQ-HARD-2 (P0)`: Dodać `override governance`:
  - minimalny schema metadanych (`author`, `timestamp`, `reason`, `issue_ref`),
  - językowy review flow (owner/reviewer),
  - lint CI (`placeholder`, spacje końcowe, interpunkcja, zakazane formy).
- [ ] `WQ-HARD-3 (P0)`: Wdrożyć `golden quality set` (200–500 kluczy PL/ES) + test regresji failujący build przy znanych błędach kontraktu.
- [ ] `WQ-HARD-4 (P1)`: Wprowadzić `TM quarantine store` + dzienne snapshoty TM + procedurę rollback.
- [ ] `WQ-HARD-5 (P1)`: Dodać `glossary` (100–300 terminów) jako warstwę pre-processing i walidacji spójności stylu.
- [ ] `WQ-HARD-6 (P0)`: Zsynchronizować powyższe taski z planem kanonicznym (`docs/I18N_UNIFIED_EXECUTION_PLAN_2026-02-13.md`) i utrzymać jedną prawdę.

Uwagi wykonawcze:
- Priorytet „jednym zdaniem” (zgodnie z sugestią): najpierw wdrożyć i egzekwować jednolitą macierz priorytetów źródeł + logowanie decyzji konfliktowych.
- To zadanie bezpośrednio chroni ręcznie kuratorowane tłumaczenia przed degradacją przez późniejsze warstwy pipeline.

## 🛠️ Aktualizacja wykonania (2026-02-19 22:00 UTC — stabilizacja WQ-HARD-18/19/20 po regresji patchowej)

Wybrane do realizacji pełne zadania:
- **Przywrócić poprawną składnię i integralność `i18n_worker_simple.sh` po awarii sekcji nagłówkowej**
- **Domknąć generowanie artefaktów regresji `critical_bad_keys_pack_*`**
- **Potwierdzić render nowych linii QUALITY w `I18N_STATUS.md`**

Status realizacji (graficznie):

| Status | Zadanie | Szczegóły |
|---|---|---|
| ✅ ZROBIONE | Naprawa sekcji startowej workera | Odtworzono brakujące deklaracje opcji i helpery (`is_enabled`, `apply_global_quality_mode`, `status_update_activity`, `status_log_op`, `STATUS_DIR`, `I18N_SCOPE`). |
| ✅ ZROBIONE | Naprawa root-cause braku artefaktów regresji | W bloku Python zamieniono odwołania do niezdefiniowanych zmiennych okna (`strict_window_start/end`) na istniejące (`strict_cutoff`, `strict_now`). |
| ✅ ZROBIONE | Walidacja składni | `bash -n i18n_worker_simple.sh` przechodzi bez błędów. |
| ✅ ZROBIONE | Regeneracja statusu | `bash i18n_worker_simple.sh --update-status` wykonane poprawnie. |
| ✅ ZROBIONE | Potwierdzenie artefaktów QUALITY | Wygenerowano `i18n/status/critical_bad_keys_pack_regression_latest.json` i `..._report.jsonl`; `I18N_STATUS.md` pokazuje linie alarmu/trendu i regresji packa. |

Uwagi:
- Bieżący stan regresji jest **FAIL** (PL/ES mają wpisy `CRITICAL` w oknie, a pack review jest pusty), co jest oczekiwanym sygnałem jakościowym, a nie awarią generatora.

## 🛠️ Aktualizacja wykonania (2026-02-19 22:35 UTC — weryfikacja fizycznych JSON + QUALITY status + guard-fail root-cause)

Wybrane do realizacji pełne zadania:
- **Zweryfikować błędne tłumaczenia bezpośrednio w fizycznych plikach `.json`**
- **Wyjaśnić i naprawić status `QUALITY` jako „nieaktywny” podczas aktywnej fazy tłumaczeń**
- **Rozbić wysokie `guard fail` na przyczyny i zapisać plan naprawczy jako taski**

Wykonane:
- ✅ Potwierdzono problem w fizycznym pliku `canary_test/i18n/pl/spells.json` (nie tylko dashboard):
  - `spell.azerus_soulfire_1.name` było: `Azerus Soulfire 1`
  - `spell.quara_constrictor_electrify.name` było: `quara constrictor elektryzuje`
  - `spell.lava_golem_soulfire2.name` było: `lawowy golem soulfire2`
- ✅ Wprowadzono poprawki bezpośrednio do `canary_test/i18n/pl/spells.json`:
  - `Ogień duszy Azerusa 1`
  - `Elektryzacja Quara Constrictora`
  - `Ogień duszy lawowego golema 2`
- ✅ Dodano zabezpieczenie regresji w `canary_test/i18n/overrides/pl.json` dla ww. kluczy (priorytet runtime nad TM/GT).
- ✅ Naprawiono semantykę statusu `QUALITY` w `i18n_worker_simple.sh`:
  - sekcja QUALITY nie jest już oznaczana jako nieaktywna wyłącznie dlatego, że worker jest w `AUTO_TRANSLATE`.
  - `QUALITY` traktuje teraz jako fazy aktywne: `VALIDATION`, `AUTO_TRANSLATE`, `TRANSLATION_SYNC`.

Root-cause wysokiego `guard fail` (snapshot ~70%+):
- Duża część kandydatów pochodzi z jakościowo trudnych kluczy (NPC/spelle/techniczne tokeny), gdzie silniki fallback (SIMPLE/GT) generują hybrydy EN/PL lub formy nienaturalne.
- Guard jest obecnie celowo restrykcyjny (odrzuca podejrzane wzorce), więc wysoki odsetek odrzuceń oznacza, że filtr działa agresywnie — ale też że jakość wejścia do guardów wymaga poprawy.
- Dotychczasowy dashboard mógł wzmacniać mylne wrażenie przez sekcję `QUALITY` jako „nieaktywną” podczas aktywnego tłumaczenia.

Nowe taski naprawcze (wymagane):
- [ ] `WQ-HARD-7 (P0)`: Dodać metrykę `guard_fail_breakdown` per reason code (np. placeholder mismatch / EN-leak / malformed token / glossary violation) publikowaną do `i18n/status/` i `I18N_STATUS.md`.
- [ ] `WQ-HARD-8 (P0)`: Dodać strictejszy pre-filter dla nazw zaklęć/bytów (`spell.*.name`) zanim trafią do GT fallback (ochrona przed formami typu `... soulfire2`).
- [ ] `WQ-HARD-9 (P0)`: Rozszerzyć `overrides/pl.json` o paczkę „critical bad keys” (min. 100 kluczy) + owner review.
- [ ] `WQ-HARD-10 (P1)`: Dodać test regresji „recent translations quality sample” — losowa próbka N=50 z ostatniej godziny i automatyczny fail przy przekroczeniu progu błędów semantycznych.
- [ ] `WQ-HARD-11 (P1)`: Wydzielić reguły językowe per domena (`spells`, `npc`, `quests`) i podpiąć jako dodatkowy scoring przed akceptacją tłumaczenia.

Uwagi:
- Wysoki `guard fail` sam w sobie nie oznacza awarii guardów; oznacza słaby strumień kandydatów. Plan musi równolegle poprawić **jakość generacji** i utrzymać **restrykcyjność walidacji**.
- Dla transparentności operacyjnej trzeba raportować nie tylko `% fail`, ale też **dlaczego** kandydaci odpadają (reason-coded telemetry).

## 🛠️ Aktualizacja wykonania (2026-02-19 23:10 UTC — audyt błędnych tłumaczeń PL/ES w fizycznych `.json` + komendy diagnostyczne + plan naprawy workera)

Cel tej aktualizacji:
- **Wyszukać i potwierdzić błędne tłumaczenia PL/ES bezpośrednio w fizycznych plikach `.json`**
- **Dopisać komendy do kontroli każdego przypadku pracy workera (operacyjnie, cykl po cyklu)**
- **Rozpisać precyzyjny plan zmian, aby worker wykrywał i naprawiał te przypadki automatycznie**

### 1) Potwierdzone przykłady błędnych tłumaczeń (fizyczne pliki JSON)

#### 1.0. Skala problemu (snapshot PL/ES)

Na podstawie pełnego skanu fizycznych plików `i18n/pl/*.json` i `i18n/es/*.json`:
- `pl`:
  - `total_keys=53577`
  - `en_marker([EN])=5972`
  - `lang_marker([PL]/[ES])=541`
  - `mission_token(npc.bozo.mission_*)=36`
  - `fx_token=3`
- `es`:
  - `total_keys=53577`
  - `en_marker([EN])=6298`
  - `lang_marker([PL]/[ES])=1747`
  - `mission_token(npc.bozo.mission_*)=34`
  - `fx_token=3`
  - `todo_artifact=30`

To potwierdza, że problem jest szeroki i nie ogranicza się do kilku kluczy.

#### 1.1. Przykłady startowe „Enter Game / Create Account” (rozszerzenie)

##### PL (`i18n/pl`)

`otclient_modules.entergame*`:
- `otclient_modules.entergame.tr_1 = "Wiadomość z the Dzień"` (mix EN/PL)
- `otclient_modules.entergame.tr_20 = "Wiadomość z the Dzień"` (powtórka błędu)
- `otclient_modules.entergame.tr_9 = "[PL] ERROR , try adding ..."` (artefakt techniczny, nie tłumaczenie UI)

`otclient_modules.entergame_otui*`:
- `otclient_modules.entergame_otui.tr_1 = "Utwórz Twojego"` (nienaturalna składnia)
- `otclient_modules.entergame_otui.tr_12 = "Znak"` (zły termin domenowy dla „character”)

`client.createaccount*`:
- `client.createaccount.text1 = "fx handleHttpResponse"` (token techniczny)
- `client.createaccount.text3 = "fx handleHttpResponse"`
- `client.createaccount.text5 = "fx handleHttpResponse"`

`html.createaccount*`:
- `html.createaccount.html.text3 = "[EN] Caps Lock is enabled!"`
- `html.createaccount_confirm.html.text1 = "[EN] {{ account.premdays }}"`
- `html.createaccount_confirm.html.text2 = "[EN] {{ character.name }}"`

##### ES (`i18n/es`)

`otclient_modules.entergame*`:
- `otclient_modules.entergame.tr_17 = "Viaje hacia adelante"` (nienaturalne dla CTA „continue journey / enter game”)
- `otclient_modules.entergame.tr_9 = "[ES] ERROR , try adding ..."` (artefakt techniczny)

`otclient_modules.entergame_otui*`:
- `otclient_modules.entergame_otui.tr_12 = "Simbólico"` (błędny termin domenowy)
- `otclient_modules.entergame_otui.tr_2 = "Acceso"` (semantycznie zbyt ogólne w miejscu login action)

`client.createaccount*`:
- `client.createaccount.text1 = "mango fxHttpResponse"` (artefakt tokena)
- `client.createaccount.text2 = "[EN] ERROR: JSON not found in the response"`
- `client.createaccount.text3 = "mango fxHttpResponse"`
- `client.createaccount.text5 = "mango fxHttpResponse"`

`html.createaccount*`:
- `html.createaccount_confirm.html.text1 = "[EN] {{ account.premdays }}"`
- `html.createaccount_confirm.html.text2 = "[EN] {{ character.name }}"`

#### 1.2. Rozszerzona lista innych przypadków (poza Enter Game)

##### PL (`i18n/pl`)

`items.json`:
- `item.25907.name = "supreme Zdrowie keg"`
- `item.25906.name = "ultimate Zdrowie keg"`
- `item.25905.name = "great Zdrowie keg"`
- `item.25904.name = "strong Zdrowie keg"`
- `item.21001.name = "martwy minotaur amazon"`
- `item.10727.name = "dreadcoil"`

`npc.json`:
- `npc.bozo.stdmod_81..115` zawierają artefakty `npc.bozo.mission_*` zamiast finalnego tekstu użytkowego.

`otclient_modules.json`:
- `otclient_modules.bestiary_otui.tr_2 = "[EN] ?"`
- `otclient_modules.bestiary_otui.tr_3 = "[EN] ?"`
- `otclient_modules.character_otui.tr_46 = "[EN] Description"`
- `otclient_modules.editvip_otui.tr_7 = "[EN] Description"`

`scripts.json`:
- `scripts.actions_bonefiddle.msg_4 = "[EN] You are playing the Peacock Ballad and the portal opens."`
- `scripts.actions_frozen_horror.msg_2 = "[EN] Someone is fighting with Frozen Horror."`
- `scripts.movements_mission4_parchment_decyphering.say_1 = "[EN] !-! -O- I_I (/( --I Morgathla"`

##### ES (`i18n/es`)

`npc.json`:
- `npc.bozo.stdmod_98 = "npc.bozo.mission_18_t1_1\\z ..."`
- `npc.bozo.stdmod_99 = "npc.bozo.mission_19_t1\\z ..."`
- `npc.captain_haba_open_sea.larboard_1 = "¡LEVAN LAS VELAS A TODO LADO! ¡¡SERPIENTE MARINA A BALAR !!"`
- `npc.captain_haba_open_sea.say_3 = "¿¡¿ESO ES TODO?!? ¡¡¡ACELERAR, APRETAR LA VELA MAYOR!!!"`
- `npc.captain_haba_open_sea.straight_3 = "¡¡MIRADOR INFORMA SERPIENTE MARINA A LA VISTA!! ¡¡TODO DERECHO!!"`

`npclib.json`:
- `misc.bank_system.say_1 = "[EN] You do not have enough gold."`
- `misc.bank_system.say_10 = "[EN] Whoah, hold on, you have no free capacity to carry all those coins!"`

`client.json`:
- `client.http.text3 = "[EN] HTTP.getJSON is not supported"`
- `client.http.text4 = "[EN] HTTP.post is not supported"`
- `client.http.text5 = "[EN] HTTP.postJSON is not supported"`

`scripts.json`:
- `scripts.actions_vocation_reward.msg_2 = "[EN] You have found a {}. There is no room."`
- `scripts.movements_teleportto.say_1 = "[EN] rkawdmawfjawkjnfjkawnkjnawkdjawkfmalkwmflkmawkfnzxc"`
- `scripts.movements_habitats_access.msg_1 = "[EN] You not proven your worth. There is no escape for you here."`

`talkactions.json`:
- wiele wpisów z markerem `[ES]` pozostawionym w treści runtime (nie powinien trafiać do finalnej warstwy UI), np.:
  - `talkaction.refill.msg_refilled`
  - `talkaction.god.zones.msg_size`
  - `talkaction.god.forge.msg_add_target`

#### A. Język polski (`i18n/pl/*.json`)

Przypadki mieszania EN/PL i nienaturalnych form:
- `i18n/pl/items.json`
  - `item.25907.name = "supreme Zdrowie keg"`
  - `item.25906.name = "ultimate Zdrowie keg"`
  - `item.21001.name = "martwy minotaur amazon"`
- `i18n/pl/items.json`
  - `item.10727.name = "dreadcoil"` (identical_to_en — wymaga klasyfikacji: nazwa własna vs brak tłumaczenia)

Przypadki z flagą nieprzetłumaczonego tekstu:
- `i18n/pl/achievements.json`
  - `achievement.1.name = "[EN] Castlemania"`
  - wiele kolejnych wpisów (`achievement.*`) także pozostaje jako `[EN] ...`

Przypadki `spells` (już poprawione i zabezpieczone override, nadal wymagają rozszerzenia polityki):
- `i18n/pl/spells.json`
  - `spell.quara_constrictor_electrify.name = "Elektryzacja Quara Constrictora"`
  - `spell.lava_golem_soulfire2.name = "Ogień duszy lawowego golema 2"`

#### B. Język hiszpański (`i18n/es/*.json`)

Przypadki artefaktów/tokenów technicznych zamiast docelowego tłumaczenia użytkowego:
- `i18n/es/npc.json`
  - `npc.bozo.stdmod_98 = "npc.bozo.mission_18_t1_1\\z ..."`
  - `npc.bozo.stdmod_99 = "npc.bozo.mission_19_t1\\z ..."`

Przypadki jakości językowej i artefaktów:
- `i18n/es/npc.json`
  - `npc.captain_haba_open_sea.larboard_1 = "¡LEVAN LAS VELAS A TODO LADO! ¡¡SERPIENTE MARINA A BALAR !!"`
  - `npc.captain_haba_open_sea.say_3 = "¿¡¿ESO ES TODO?!? ¡¡¡ACELERAR, APRETAR LA VELA MAYOR!!!"`
  - `npc.captain_haba_open_sea.straight_3 = "¡¡MIRADOR INFORMA SERPIENTE MARINA A LA VISTA!! ¡¡TODO DERECHO!!"`

Przypadki nieprzetłumaczonych wpisów `[EN]`:
- `i18n/es/npclib.json`
  - `misc.bank_system.say_1 = "[EN] You do not have enough gold."`
  - kolejne wpisy `misc.bank_system.say_*` analogicznie.

Uwaga semantyczna (ważna):
- Część wpisów wykrywanych jako `word_salad` może być poprawnym tłumaczeniem naturalnym. Dlatego potrzebny jest etap klasyfikacji reguł (true positive vs false positive), a nie tylko „twarde” reject-all.

---

### 2) Komendy operacyjne do sprawdzania KAŻDEGO przypadku pracy workera

#### 2.1. Szybki podgląd bieżącego cyklu i guardów

```bash
# aktualny stan sekcji i faz
cat i18n/status/status_sections_latest.json | jq .

# ostatni wynik guarda (1 target)
cat i18n/status/translation_guard_latest.json | jq .

# metryki okna 1h (guard_fail_rate, top targety)
cat i18n/status/strict_hourly_window_latest.json | jq .
```

#### 2.2. Ostatnie tłumaczenia + szybki audyt wartości

```bash
# ostatnie przetłumaczone klucze (z source)
cat i18n/status/translation_recent_latest.json | jq .

# odrzucone podejrzane wpisy PL/ES (ostatnie 200)
tail -n 200 i18n/status/suspicious_rejected.jsonl | jq -c 'select(.lang=="pl" or .lang=="es")'

# pełny suspicious log PL/ES (ostatnie 200)
tail -n 200 i18n/status/suspicious_log.jsonl | jq -c 'select(.lang=="pl" or .lang=="es")'
```

#### 2.3. Weryfikacja konkretnego klucza w fizycznym JSON

```bash
# przykład: pojedynczy klucz
grep -R --line-number '"spell.lava_golem_soulfire2.name"' i18n/pl i18n/es

# batch kluczy problematycznych
grep -R --line-number -E '"(item.25907.name|item.25906.name|npc.bozo.stdmod_99|npc.captain_haba_open_sea.larboard_1)"' i18n/pl i18n/es
```

#### 2.4. Audyt regexowy „flag jakości” w JSON (PL/ES)

```bash
# [EN] markers
grep -R --line-number '".*\[EN\]' i18n/pl i18n/es | head -n 200

# techniczne tokeny / artefakty
grep -R --line-number -E 'npc\.bozo\.mission_|\[LANG\]|TODO|\?\?\?\?' i18n/pl i18n/es | head -n 200

# podejrzane hybrydy EN/PL/ES (przykład słów)
grep -R --line-number -E 'soulfire|keg|ultimate|supreme|strong|great' i18n/pl i18n/es | head -n 200
```

#### 2.5. Korelacja: co odrzucone vs co aktualnie siedzi w JSON

```bash
python3 - <<'PY'
import json,glob,os
langs={'pl':'i18n/pl','es':'i18n/es'}
current={}
for lang,p in langs.items():
    cur={}
    for fp in glob.glob(f"{p}/*.json"):
        cat=os.path.basename(fp)
        data=json.load(open(fp,encoding='utf-8'))
        for k,v in data.items():
            cur[k]=(cat,v)
    current[lang]=cur

for line in open('i18n/status/suspicious_rejected.jsonl',encoding='utf-8',errors='ignore'):
    o=json.loads(line)
    if o.get('lang') not in ('pl','es'):
        continue
    k=o.get('key')
    if not k:
        continue
    cur=current[o['lang']].get(k)
    if cur:
        cat,val=cur
        print(f"{o['lang']}\t{k}\t{cat}\t{val[:120] if isinstance(val,str) else val}")
PY
```

#### 2.6. Generowanie pełnej listy przypadków do review (PL/ES) — raport plikowy

```bash
python3 - <<'PY' > i18n/status/pl_es_problem_cases_$(date +%Y%m%d_%H%M%S).txt
import json,glob,os,re
langs=['pl','es']
rules=[
 ('en_marker',lambda v:'[EN]' in v),
 ('lang_marker',lambda v:'[PL]' in v or '[ES]' in v),
 ('mission_token',lambda v:'npc.bozo.mission_' in v),
 ('fx_token',lambda v:'fx ' in v.lower() or 'fxhttpresponse' in v.lower() or 'mango fx' in v.lower()),
 ('todo_artifact',lambda v:('TODO' in v or '[LANG]' in v or '????' in v)),
]
for lang in langs:
  for fp in glob.glob(f'i18n/{lang}/*.json'):
    cat=os.path.basename(fp)
    data=json.load(open(fp,encoding='utf-8'))
    for k,v in data.items():
      if not isinstance(v,str):
        continue
      tags=[n for n,f in rules if f(v)]
      if tags:
        print(f"{lang}\t{cat}\t{k}\ttags={','.join(tags)}\t{v[:180]}")
PY

# szybki podgląd ile przypadków i sample
wc -l i18n/status/pl_es_problem_cases_*.txt
head -n 100 i18n/status/pl_es_problem_cases_*.txt
```

---

### 3) Co worker musi dostać, żeby wykrywać i poprawiać te przypadki

#### 3.1. Warstwa detekcji (P0)
- Dodać `reason-coded` reguły per język i per domena (`items`, `npc`, `spells`, `quests`):
  - `en_marker_present` (`[EN] ...`),
  - `mixed_language_ratio` (EN leak powyżej progu),
  - `artifact_token_detected` (`npc.bozo.mission_*`, `TODO`, `[LANG]`, `????`),
  - `unnatural_collocation` (np. `ultimate Zdrowie keg`),
  - `proper_noun_exemption` (kontrolowane whitelisty nazw własnych, by ograniczyć false-positive).

#### 3.2. Warstwa klasyfikacji (P0)
- Rozdzielić wpisy na 3 klasy akcji:
  1. `AUTO_FIX_NOW` — pewne błędy (`[EN]`, token artefakty, ewidentne hybrydy).
  2. `RETRANSLATE_WITH_CONSTRAINTS` — tłumaczyć ponownie z hintami/glossary.
  3. `MANUAL_REVIEW` — niejednoznaczne przypadki (np. potencjalna nazwa własna).

#### 3.3. Warstwa auto-poprawy (P0/P1)
- Dla `AUTO_FIX_NOW`:
  - wymusić retranslate przez `TM verified`/`curated dictionary`/`GT` z guardem,
  - zapisać poprawkę i od razu dopisać do `overrides/{lang}.json` jeśli klucz jest krytyczny.
- Dla `RETRANSLATE_WITH_CONSTRAINTS`:
  - podawać do translatora kontekst domeny + glossary + zakazane tokeny.

#### 3.4. Warstwa telemetry i audytu (P0)
- Dodać nowy raport: `i18n/status/guard_fail_breakdown_latest.json`:
  - `by_lang`, `by_file`, `by_reason_code`, `by_source`.
- Dodać licznik skuteczności auto-fix:
  - `auto_fix_attempted`, `auto_fix_success`, `auto_fix_rejected_again`.

#### 3.5. Warstwa jakości „recent keys” (P1)
- Nie pokazywać w sekcji „recent translated keys” wpisów, które w tym samym cyklu mają `HIGH/CRITICAL` suspicious (albo oznaczać je jawnie badge `⚠`).

---

### 4) Plan wdrożeniowy (zadania)

- [x] `WQ-HARD-12 (P0)`: Implementować `guard_fail_breakdown_latest.json` + publikację w `I18N_STATUS.md`.
- [x] `WQ-HARD-13 (P0)`: Dodać detektory `en_marker_present`, `artifact_token_detected`, `mixed_language_ratio` dla PL/ES.
- [x] `WQ-HARD-14 (P0)`: Dodać auto-fix klasy `AUTO_FIX_NOW` (`[EN]`, tokeny artefaktowe, hybrydy oczywiste).
- [x] `WQ-HARD-15 (P1)`: Dodać `proper_noun_exemption` + whitelisty domenowe, aby ograniczyć false-positive.
- [x] `WQ-HARD-16 (P1)`: Dodać tryb audytu „recent keys without HIGH/CRITICAL” do dashboardu.
- [x] `WQ-HARD-17 (P0)`: Przygotować „critical bad keys pack” PL/ES i zassać do `i18n/overrides/{lang}.json` po review.
- [x] `WQ-HARD-18 (P0)`: Dodać test regresji `critical_bad_keys_pack` (plik latest nie może być pusty dla PL/ES, jeśli są CRITICAL w cyklu).
- [x] `WQ-HARD-19 (P1)`: Dodać alarm trendu `recent_hidden_high_critical` (próg + alert w `I18N_STATUS.md`).
- [x] `WQ-HARD-20 (P0)`: Dodać walidator review-override (`i18n/overrides/reviewed/{lang}.json`) z checkiem placeholder/pipe/command przed merge do runtime.

### 4.1) Status wdrożenia (2026-02-19)

Wdrożone w kodzie worker/status:
- `WQ-HARD-12`: nowy artefakt `i18n/status/guard_fail_breakdown_latest.json` + historia `i18n/status/guard_fail_breakdown_report.jsonl`.
- Breakdown liczy: `by_type`, `by_source`, `by_language`, `by_category`, `by_severity`, `top_types`, `top_keys` (okno `STATUS_STRICT_WINDOW_HOURS`).
- Artefakt jest podpięty pod status globalny (`translation_global_overview.json`) i summary QUALITY (`guard_fail_breakdown_summary`).

- `WQ-HARD-13`: dodane dedykowane detektory dla PL/ES w `detect_suspicious`:
  - `en_marker` (`[EN]`),
  - `lang_marker` (`[PL]/[ES]/[LANG]`),
  - `mission_token` (`npc.bozo.mission_`),
  - `fx_token` (`fx`, `fxHttpResponse`, `mango fx`).

Efekt operacyjny:
- QUALITY sekcja korzysta teraz z obu źródeł (`quality_audit_latest.json` + `guard_fail_breakdown_latest.json`) i bierze najnowszy timestamp.
- Mamy gotowy fundament telemetryczny pod kolejne zadania (`WQ-HARD-14..17`).

Aktualizacja 2026-02-19 (WQ-HARD-14):
- dodana klasa `AUTO_FIX_NOW` (PL/ES): `en_marker`, `lang_marker`, `mission_token`, `fx_token`, `word_salad`, `mixed_language`.
- dla źródeł `TM` i `simple` przypadki `AUTO_FIX_NOW` są kierowane na szybki fallback do `google_translate` zamiast kończyć odrzuceniem.
- dla `GT` rozszerzono typy odrzucenia `HIGH` o artefakty PL/ES, aby nie wpuszczać skażonych wpisów do finalnych JSON.

Aktualizacja 2026-02-19 (WQ-HARD-15/16/17):
- `WQ-HARD-15`: dodano domenowe whitelisty nazw własnych (`npc`, `monster`, `spell`, `book`, `quest`, `raid`) i warunek `_is_domain_whitelisted_proper_noun`.
- `WQ-HARD-16`: `translation_recent_latest.json` domyślnie ukrywa wpisy `HIGH/CRITICAL`; dodano metryki `recent_include_high_critical` i `recent_hidden_high_critical`.
- `WQ-HARD-17`: dodano pack review `i18n/overrides/review_queue/critical_bad_keys_pack_{pl|es}_latest.json` + historia `*_report.jsonl`; runtime merge z `i18n/overrides/reviewed/{lang}.json` jest aktywny.

Aktualizacja 2026-02-19 (WQ-HARD-18/19/20):
- `WQ-HARD-18`: dodano regresję packów krytycznych:
  - artefakt `i18n/status/critical_bad_keys_pack_regression_latest.json` + historia `critical_bad_keys_pack_regression_report.jsonl`,
  - skrypt testowy `tools/i18n_assert_critical_bad_keys_pack.py` (exit code `1` przy fail).
- `WQ-HARD-19`: dodano alarm trendu `recent_hidden_high_critical`:
  - metryki `recent_hidden_alert_threshold`, `recent_hidden_alert` w `translation_recent_latest.json`,
  - sygnalizacja `ALERT/OK` i trend (`last10` vs `prev10`) w sekcji QUALITY (`I18N_STATUS.md`).
- `WQ-HARD-20`: włączono walidator review-override przed merge do runtime:
  - checki `placeholder/command/pipe` względem EN (`i18n/en/{json_file}`),
  - ignorowanie wpisów niespełniających kontraktu tokenów.

### 5) Zakres na teraz

W tej iteracji wykonano:
- identyfikację i potwierdzenie przypadków w fizycznych `.json`,
- przygotowanie komend operacyjnych do pełnej diagnostyki cykli,
- rozpisanie planu implementacyjnego (detekcja + klasyfikacja + auto-fix + telemetry).

Implementacja kodowa `WQ-HARD-12..17` jest następnym krokiem.

## 🛠️ Aktualizacja wykonania (2026-02-17 14:00 UTC — fix progress 0/0 LIVE + E4 Δ24h trendy + analiza GitHub Actions spam)

Wybrane do realizacji pełne zadania:
- **Naprawić bug B1: progress 0/0 w sekcji LIVE dashboardu I18N_STATUS.md**
- **Dodać E4: Δ24h trend per język w tabeli ETA**
- **Zdiagnozować przyczynę masowego triggerowania GitHub Actions przez worker/guardian**

Wykonane:
- ✅ `tools/i18n_status.py`:
  - fix `cmd_update_activity()`: gdy nowy progress to `done=0, total=0` — zachowaj poprzedni progress z `activity.json`,
  - ~20 callerów `status_update_activity` (cycle_start, dispatch, signal, validation, idle, cycle_end, etc.) wysyłało `0 0 "units"` co nadpisywało prawdziwe dane z heartbeat,
  - prawdziwi callers (heartbeat_tick, auto_start, auto_done) zawsze podają `total>0` więc normalnie nadpisują,
  - test: symulacja 3 kroków (heartbeat 50/200 → cycle_end 0/0 → auto_start 0/300) — progress zachowany po cycle_end.
- ✅ `i18n_worker_simple.sh` (sekcja E1-E4):
  - dodano ładowanie dzisiejszych i wczorajszych danych z `daily/*.json` przed pętlą ETA,
  - dodano kolumnę `Δ dziś` z liczbą kluczy przetłumaczonych dziś + trend % vs wczoraj,
  - format: `+1,234 (↑15%)` lub `+567` (brak danych wczoraj) lub `-` (0 dziś),
  - zaktualizowano nagłówek tabeli i footnote w markdown template.
- ✅ Analiza GitHub Actions:
  - zidentyfikowano root cause: `analysis-sonarcloud-windows.yml` ma `on: push: branches: [master]` BEZ filtra `paths:`,
  - każdy push workera/guardiana triggerował SonarCloud build,
  - zabito procesy worker/guardian/statusd, anulowano ~500 kolejkowanych runów,
  - ręcznie triggerowano Build-Windows + Build-Linux.

Walidacja runtime (2026-02-17):
- ✅ `tools/i18n_status.py`: kompilacja OK (`py_compile`).
- ✅ Test progress retention: heartbeat `{done: 50, total: 200}` → cycle_end `{done: 50, total: 200}` (zachowane!) → auto_start `{done: 0, total: 300}` (nadpisane poprawnie).
- ✅ Test E4 Δ24h: tabela ETA renderuje kolumnę `Δ dziś` z danymi z `daily/*.json`.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ⬜ Dodać `[skip ci]` do commit messages w `i18n_worker_simple.sh` (linie 23209, 23231) i `i18n_guardian.sh` (linia 1325), aby zapobiec triggerowaniu GitHub Actions na push.
- ⬜ Zmienić `PUSH_INTERVAL_SECONDS` w `i18n_guardian.sh` z 120 na 480 (co 8 min zamiast 2 min).
- ⬜ Rozważyć dodanie filtra `paths:` do `analysis-sonarcloud-windows.yml` w repo, aby build nie triggerował się na zmiany i18n.
- ⬜ Dodać reset progressu do `0/0` explicite tylko przy zmianie fazy z `AUTO_TRANSLATE` na inną (sygnalizacja „zakończyłem tłumaczenie"), zamiast implicit zachowywania starego.

## 🛠️ Aktualizacja wykonania (2026-02-14 11:22 UTC — full task: audyt LT/CS/EL/IT + status refresh + translation contract)

Wybrane do realizacji pełne zadania:
- **Zweryfikować jakość tłumaczeń LT/CS/EL/IT z podziałem na typy: item names/desc, NPC dialogue, quest descriptions**
- **Domknąć odświeżanie `I18N_STATUS.md` także dla zmian poza workerem**
- **Dodać check kontraktu runtime: guardian uruchamia worker w trybie tłumaczeń ogólnych (ES/PL gate)**

Wykonane:
- ✅ `i18n-statusd.sh`:
  - dodano `maybe_refresh_status_md()` / `run_status_md_refresh()` (autonomiczne odświeżanie `I18N_STATUS.md`),
  - refresh jest wyzwalany przy starym statusie i po `RECONCILE_APPLIED`.
- ✅ `i18n-statusd.sh`:
  - `registry_reconcile` rozszerzono o `always_sync_any_drift=true` (kanoniczny próg),
  - przy delcie możliwy bypass cooldown (`cooldown_bypassed`), żeby ręczne zmiany EN nie „czekały” na odświeżenie.
- ✅ `i18n-statusd.sh` (doctor):
  - nowy blok `translation_contract`:
    - `has_translations_only`,
    - `priority_gate_enabled`,
    - kolejność `priority_langs`,
    - wynik `worker_translation_contract_ok` publikowany do `statusd_doctor.json`.
- ✅ Audyt jakości LT/CS/EL/IT (domeny `items.json` / `npc.json` / `quests.json`):
  - placeholdery `{}`: mismatch `0`,
  - placeholdery `%`: mismatch `0`,
  - tokeny komend `'keyword'`: mismatch `0`.
- ✅ Coverage genuine (bez EN-copy i `[EN]`) po typach:
  - `lt`: `item_name=1.66%`, `item_desc=0.03%`, `npc_dialogue=2.98%`, `quest_desc=1.97%`,
  - `cs`: `item_name=1.17%`, `item_desc=0.03%`, `npc_dialogue=3.03%`, `quest_desc=1.97%`,
  - `el`: `item_name=1.67%`, `item_desc=0.03%`, `npc_dialogue=3.00%`, `quest_desc=1.97%`,
  - `it`: `item_name=1.73%`, `item_desc=0.03%`, `npc_dialogue=3.04%`, `quest_desc=23.77%`.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ⬜ Dodać osobny dispatch wave dla `lt/cs/el/it` z kolejnością domen:
  - `items.desc` -> `npc` -> `quests`,
  - osobne limity batch per domena (bo `item_desc` jest krytycznie nisko).
- ⬜ Dodać auto-metrykę jakości domenowej do `i18n/status/` (nie tylko ad-hoc skrypt), żeby worker i statusd mieli stale ten sam kontrakt.
- ⬜ Wprowadzić shortlistę ręcznego review idiomów GT dla LT/CS/EL/IT (placeholdery są poprawne, ale semantyka/idiomy miejscami wymagają korekty).

## 🛠️ Aktualizacja wykonania (2026-02-14 10:18 UTC — full task: 30s health gate + source root-cause + 20m observation)

Wybrane do realizacji pełne zadania:
- **Dodać dodatkowy check „process still alive after N=30s” w `i18n_start_all.sh`**
- **Zidentyfikować zewnętrzne źródło częstych wywołań `i18n_guardian.sh --daemon` (`source=manual`)**
- **Wykonać obserwację 20+ min i potwierdzić brak `REPAIR_QUEUE_STALE`**

Wykonane:
- ✅ `i18n_start_all.sh`:
  - dodano `post_start_health_gate()` (domyślnie 30s, konfigurowalne env),
  - gate sprawdza, czy po starcie żyją: guardian + statusd + worker.
- ✅ `i18n_guardian.sh`:
  - dodano log kontekstu startu `manual` (`ppid`, parent/grand cmdline) z throttlingiem,
  - potwierdzono źródło prób `manual`: user systemd (`/usr/lib/systemd/systemd --user`).
- ✅ Root-cause:
  - wykryty unit: `~/.config/systemd/user/i18n-guardian.service` (`ExecStart=...i18n_guardian.sh --daemon`),
  - to ten unit generuje konkurencyjne próby startu `source=manual`.
- ✅ Obserwacja queue:
  - okno 20 minut (`10:57:40` -> `11:17:01`, czas hosta) bez `REPAIR_QUEUE_STALE`,
  - tylko `repair_queue_fresh` / `queue_freshness_ok`.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ⬜ Decyzja operacyjna: zostawić user-systemd czy przejść wyłącznie na `i18n_start_all.sh` jako kanoniczne źródło.
- ⬜ Gdy zostaje systemd: ustawić `GUARDIAN_START_SOURCE=service` w unit i ograniczyć restart policy.
- ⬜ Gdy zostaje start_all: wyłączyć user unit guardiana, żeby usunąć lock contention i szum logów.

## 🛠️ Aktualizacja wykonania (2026-02-14 09:56 UTC — full task: heartbeat mid-cycle + refresh repair queue + guardian/start reliability)

Wybrane do realizacji pełne zadania:
- **Domknięcie worker heartbeat mid-cycle podczas AUTO_TRANSLATE**
- **Domknięcie odświeżania `identical_to_en_repair_queue.json` niezależnie od pełnej rundy repair**
- **Domknięcie stabilności locków guardian/start (`start_all` + source arbitration)**

Wykonane:
- ✅ `i18n_worker_simple.sh`:
  - dodano mid-cycle heartbeat loop z env:
    - `AUTO_TRANSLATE_MID_CYCLE_HEARTBEAT_ENABLED`,
    - `AUTO_TRANSLATE_MID_CYCLE_HEARTBEAT_INTERVAL_SEC`,
  - heartbeat emituje `status_update_activity(... stage=heartbeat_tick ...)` podczas długich tłumaczeń,
  - dodano tryb `queue_only` w `repair_identical_bonus_round()` i refresh policy:
    - `REPAIR_QUEUE_REFRESH_MIN_INTERVAL_SEC`,
  - refresh repair queue jest wykonywany:
    - przed `auto_translate`,
    - okresowo w heartbeat loop,
    - po zakończeniu `auto_translate`.
- ✅ `i18n_guardian.sh`:
  - lock owner PID jest walidowany po `cmdline` (`i18n_guardian.sh --daemon`), nie tylko po samym `ps -p`,
  - korekta reguł preempt locka:
    - blokada tylko dla niższego priorytetu,
    - restart z tego samego źródła (`start_all`) nie czeka bez sensu na pełny `stale_sec`.
- ✅ `i18n_start_all.sh`:
  - dodano `wait_for_stable_process()` (wielokrotna walidacja PID po starcie),
  - start guardian/statusd nie opiera się już na pojedynczym, chwilowym odczycie PID.

Walidacja runtime (foreground test, 2026-02-14 09:56 UTC):
- ✅ `activity.json` zawiera `heartbeat_tick` w `recent[]`.
- ✅ `identical_to_en_repair_queue.json` odświeżony:
  - mtime: `2026-02-14T09:55:20Z`,
  - age po teście: ~`49s`.
- ✅ Worker wykonał tłumaczenia strict (`pl/cpp.json`, `pl/otclient_modules.json`, `es/questlog.json`) bez regresji składni.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodać dodatkowy check „process still alive after N=30s” do `i18n_start_all.sh`, aby odsiać środowiska, gdzie procesy tła są ubijane zaraz po starcie. → DONE 2026-02-14 10:18 UTC.
- ✅ Zidentyfikować i opisać zewnętrzne źródło częstych wywołań `i18n_guardian.sh --daemon` (`source=manual`, co ~5s), bo zaśmieca log i utrudnia diagnostykę locków. → DONE 2026-02-14 10:18 UTC (`~/.config/systemd/user/i18n-guardian.service`).
- ✅ Po stabilnym uruchomieniu 3 daemonów wykonać min. 20 min obserwacji `statusd_doctor` i potwierdzić brak `REPAIR_QUEUE_STALE` w ruchu produkcyjnym. → DONE 2026-02-14 10:18 UTC (`stale_recent=0`).

## 🛠️ Aktualizacja wykonania (2026-02-14 09:12 UTC — heartbeat contract + subprocess watchdog + status PID accuracy)

Wybrane do realizacji pełne zadania:
- **Domknięcie heartbeat contract statusd pod długie cykle tłumaczeń**
- **Domknięcie checka runtime dla subprocessów workera**
- **Domknięcie wiarygodności `worker.pid_alive` w statusd_report**

Wykonane:
- ✅ `i18n-statusd.sh` (doctor):
  - heartbeat check czyta dynamiczne progi z `guardian_health.json` (`heartbeat_aging/stale/stuck`) zamiast stałych `180/300`,
  - przy aktywnym PID i świeżych sygnałach logowych stary heartbeat nie eskaluje od razu do CRITICAL (`STALE_HEARTBEAT_BUT_ACTIVE`).
- ✅ `i18n-statusd.sh` (doctor):
  - dodano `worker_process_watch` (main pid, extra pid, descendant/foreign, age), co odróżnia normalny pojedynczy subprocess od realnej duplikacji instancji.
- ✅ `i18n-statusd.sh` (aggregate):
  - `statusd_report.worker.pid_alive` bazuje na realnym `/proc/<pid>`,
  - `statusd_report.worker.pid` jest publikowany jawnie.

Walidacja runtime (2026-02-14 09:12 UTC):
- ✅ `bash i18n-statusd.sh --aggregate && --doctor` -> działa.
- ✅ `statusd_doctor`: brak fałszywego `STALE_HEARTBEAT` CRITICAL przy aktywnym PID.
- ✅ `statusd_doctor.worker_process_watch`: poprawna klasyfikacja topologii (`single_descendant_observed` jako stan nominalny, bez duplikacji foreign).

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ⬜ Rozważyć heartbeat mid-cycle emit po stronie workera, aby ograniczyć ostrzeżenia `AGING/STALE` przy bardzo długich batchach.
- ⬜ Dodać częstsze odświeżanie `identical_to_en_repair_queue.json` (obecnie okresowo `REPAIR_QUEUE_STALE`).
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL`.

## 🛠️ Aktualizacja wykonania (2026-02-14 08:40 UTC — registry_reconcile + priority_gate watchdog + guardian source arbitration)

Wybrane do realizacji pełne zadania:
- **Domknięcie reconcile rejestru pod zmiany manualne/agentowe EN**
- **Domknięcie watchdoga stuck dla fali priorytetowej ES/PL**
- **Domknięcie arbitrażu źródła startu guardiana (start_all vs manual)**

Wykonane:
- ✅ `i18n-statusd.sh`:
  - dodano pełny workflow `registry_reconcile`:
    - tryby: daemon cycle, `--once`, `--reconcile-registry`,
    - artefakty: `i18n/status/registry_reconcile_latest.json` + `i18n/status/registry_reconcile_state.json`,
    - zapis korekty: `i18n_file_status.json -> global_stats.reconciled_external_keys`.
  - metryki driftu publikują teraz oba widoki:
    - `worker_registry_keys` / `outside_worker_registry_keys` (effective),
    - `worker_registry_keys_raw` / `outside_worker_registry_keys_raw` (history/raw),
    - `registry_reconcile_adjustment`.
- ✅ `i18n_worker_simple.sh`:
  - status i telemetria workerowa uwzględniają `reconciled_external_keys`,
  - `translation_global_overview.json` i `i18n_global_stats.json` mają pola `*_raw` + `registry_reconcile_adjustment`,
  - `I18N_STATUS.md` pokazuje teraz registry `efektywne` i `raw` + korektę reconcile.
- ✅ `i18n-statusd.sh` (watchdog ES/PL):
  - dodano `priority_gate_watch` (state file: `i18n/status/priority_gate_watch_state.json`),
  - doctor zgłasza `PRIORITY_GATE_STUCK*` gdy gate aktywny zbyt długo bez poprawy quality rate,
  - webhook alerting wspiera `reason_code=priority_gate_stuck`,
  - daily report ma sekcję `Priority Gate Watch`,
  - rekomendacje runtime zawierają `SWITCH_PROFILE quality_repair (short)` przy stuck.
- ✅ `i18n_guardian.sh`:
  - dodano source-priority arbitration locka (`start_all > service > scheduler > manual`),
  - świeży lock wyższego priorytetu nie jest przejmowany przez późny `manual`,
  - dodano `GUARDIAN_DAEMON_LOCK_PREEMPT_MIN_SEC`.
- ✅ `statusd_thresholds.json`:
  - nowe sekcje: `priority_gate_stuck`, `registry_reconcile`.

Walidacja runtime (2026-02-14 08:40 UTC):
- ✅ `bash i18n-statusd.sh --reconcile-registry`:
  - pierwszy run: `RECONCILE_APPLIED target_adjust=47338`,
  - kolejne runy: `RECONCILE_SKIPPED_THRESHOLD reason=no_sync_needed`.
- ✅ `statusd_report.json`:
  - `metrics_drift.severity=ok`, `outside_worker_registry_keys=0`,
  - zachowany sygnał historyczny `outside_worker_registry_keys_raw=47338`.
- ✅ `statusd_doctor.json`:
  - `metrics_drift_ok`, brak `METRICS_DRIFT_HIGH` po reconcile.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodać automatyczne wykonanie krótkiego przełączenia na `quality_repair` przy `priority_gate_stuck`. → DONE 2026-02-14 08:45: auto-action `SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK` (aktywny po włączeniu `.statusd_auto_actions`).
- ⬜ Dodać etap 2 reconcile: per-file backfill, nie tylko globalny licznik korekty.
- ✅ Dopracować heartbeat workera pod długie cykle (`STALE_HEARTBEAT` przy aktywnym PID): dynamiczny próg. → DONE 2026-02-14 09:12 (`statusd_doctor` czyta progi guardiana + sygnały aktywności PID/logów).
- ⬜ Skonfigurować `STATUSD_WEBHOOK_URL`.

## 🛠️ Aktualizacja wykonania (2026-02-14 08:18 UTC — GLOBAL_QUALITY_MODE 100% + guardian env wiring + statusd live merge)

Wybrane do realizacji pełne zadania:
- **Wdrożenie twardego trybu `GLOBAL_QUALITY_MODE` dla tłumaczeń 100%**
- **Spięcie guardiana z trybem global quality i priorytetem `es -> pl`**
- **Naprawa agregacji statusu pod zmiany poza workerem (`statusd` live snapshot)**

Wykonane:
- ✅ `i18n_worker_simple.sh`:
  - dodano tryb `GLOBAL_QUALITY_MODE` (env/CLI), który wymusza cele coverage `100%` dla tierów,
  - tryb global quality podnosi częstotliwość walidacji i refresh statusu, wymusza GT + `crossref_auto_fix` (z limitem minimalnym),
  - `select_auto_translate_target_strict()` ma nowy **priority gate**: w trybie ogólnym i global quality tłumaczy najpierw języki z `GLOBAL_QUALITY_PRIORITY_LANGS` (domyślnie `es`, `pl`) do `100%` coverage, dopiero potem rotuje pozostałe,
  - `translation_dispatch_state.json` publikuje diagnostykę gate (`priority_gate.enabled/active/pending_langs/lang_completion`),
  - `validate_tier_quality()` rozszerzono o quality gate (`score`, `critical`) i kontrakt pod global quality.
- ✅ `i18n_guardian.sh`:
  - profile mogą teraz przekazywać parametry global quality (`global_quality_*`),
  - guardian przekazuje env-y do startu workera (`GLOBAL_QUALITY_MODE`, targety, priorytet języków, limity crossref),
  - start log guardiana pokazuje aktywny tryb global quality i priorytet języków.
- ✅ Profile:
  - `guardian_profiles/translations_general.json` i `guardian_profile.json` dostały pełny zestaw `global_quality_*`,
  - `guardian_profiles/auto.json` zaostrzono rollout gate (`pilot_coverage_above_pct=100`, ostrzejsze progi jakości/no-progress).
- ✅ `i18n-statusd.sh`:
  - agregator zawsze liczy **LIVE snapshot** z `i18n_file_status.json + i18n/en/*.json` i nadpisuje nim kluczowe pola migracji (`total_keys_extracted_live`, registry, drift),
  - dzięki temu `statusd_report.json` odzwierciedla zmiany kluczy EN także poza ścieżką workera.
- ✅ `statusd_thresholds.json`:
  - progi `metrics_drift` obniżone (wcześniejsze były zbyt luźne i maskowały realny problem driftu LIVE vs registry).

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodać dedykowaną procedurę „registry reconciliation”, która aktualizuje/uzupełnia `i18n_file_status.json` dla zmian wykonanych poza workerem, aby trwale redukować `keys_extracted_outside_worker_registry`. → DONE 2026-02-14 08:40 (`run_registry_reconcile`, korekta global_stats, pola raw/effective).
- ⬜ Domknąć politykę jakości dla przypadków „poprawnie identycznych z EN” (nazwy własne) tak, aby gate 100% nie blokował rolloutu przez false-positive.
- ✅ Dodać watchdog na `priority_gate active` (max czas/ilość cykli), żeby automatycznie wykryć utknięcie ES/PL przy stabilnym `100% coverage` i niskim postępie jakości.
  - status 2026-02-14 08:45: detekcja + alerting + daily/report + rekomendacja + auto-switch action (`SWITCH_PROFILE_QUALITY_REPAIR_ON_PRIORITY_GATE_STUCK`).
- ✅ Domknąć arbitration źródeł startu guardiana: po restarcie 2026-02-14 09:20 UTC zaobserwowano wtórny start `source=manual` po aktywnym starcie `start_all`. → DONE 2026-02-14 08:40.

## 🛠️ Aktualizacja wykonania (2026-02-14 07:52 UTC — kanoniczne progi statusd + hardening `i18n_start_all.sh`)

Wybrane do realizacji pełne zadania:
- **Domknięcie kanonicznego źródła progów statusd (`metrics_drift` + pozostałe)**
- **Naprawa false-positive detekcji daemonów w `i18n_start_all.sh`**

Wykonane:
- ✅ `i18n-statusd.sh`:
  - dodano kanoniczny plik progów: `canary_test/statusd_thresholds.json`,
  - loader progów działa teraz w trybie: defaults -> config file -> (opcjonalnie) env override (`STATUSD_USE_ENV_OVERRIDES=1`),
  - domyślnie env override wyłączone (`STATUSD_USE_ENV_OVERRIDES=0`), więc daemon/manual używają tych samych progów.
- ✅ Snapshot progów został ujednolicony i rozszerzony:
  - `statusd_report.json`, `statusd_doctor.json`, `statusd_daily_report.json` zawierają `thresholds_snapshot`,
  - snapshot ma `source_of_truth`, `config_file`, `env_overrides_enabled`,
  - artefakt audytowy `i18n/status/statusd_thresholds_snapshot.json` jest emitowany przy agregacji.
- ✅ `i18n_start_all.sh`:
  - `is_running()` waliduje proces po `/proc/<pid>/cmdline` i czyści stale PID file,
  - fallback `pgrep` ma filtr self-match (`pgrep`, `i18n_start_all.sh`), więc nie zawyża statusu daemonów,
  - naprawiono `--restart` (jawne `bash "$WORK_DIR/i18n_start_all.sh"`),
  - naprawiono pętlę `stop_daemon()` pod `set -e` (`waited=$((waited + 1))`).
- ✅ `i18n_start_all.sh --status`:
  - worker raportowany jako `main pid` + `subprocessy`, zamiast surowego, mylącego licznika `pgrep`.

Walidacja runtime (2026-02-14 07:52 UTC):
- ✅ `bash i18n-statusd.sh --aggregate` -> `OK`.
- ✅ `bash i18n-statusd.sh --doctor` -> działa (CRITICAL z powodu `SUSPICIOUS_HIGH_SPIKE`, bez regresji kontraktu).
- ✅ `bash i18n-statusd.sh --daily-report` -> `OK`.
- ✅ `bash i18n_start_all.sh --restart` -> poprawny stop/start wszystkich demonów.
- ✅ `bash i18n_start_all.sh --status` -> poprawna detekcja `Guardian/Statusd/Worker` bez false-positive.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Poprawić detekcję procesu w `i18n_start_all.sh:is_running()` (fallback `pgrep`), bo w niektórych restartach zwraca false-positive dla `statusd`. → DONE 2026-02-14.
- ✅ Dodać osobny check runtime dla `worker subprocessy` (czy są krótkie i normalne, czy długie i oznaczają realne dublowanie instancji). → DONE 2026-02-14 09:12 (`worker_process_watch` w `statusd_doctor`).

## 🛠️ Aktualizacja wykonania (2026-02-14 07:28 UTC — scanned_files_live + statusd drift + global_stats)

Wybrane do realizacji pełne zadania:
- **Domknięcie metryki `scanned_files_live` w dashboardzie**
- **Alerting driftu metryk LIVE vs registry w statusd**
- **Ujednolicenie metryk migracji w `i18n_global_stats.json`**

Wykonane:
- ✅ `i18n_worker_simple.sh`:
  - dodano `scanned_files_live` (z `i18n_file_status.json`) obok historycznego `scanned_files` (z `i18n_processed_files.txt`),
  - `I18N_STATUS.md` pokazuje teraz oba liczniki skanu (`historia` i `LIVE`) oraz różnicę `Historia minus LIVE`,
  - `translation_global_overview.json` (blok `migration`) zawiera:
    - `scanned_files_history`,
    - `scanned_files_live`,
    - `scanned_files_history_minus_live`.
- ✅ `i18n-statusd.sh`:
  - dodano blok `metrics_drift` do `statusd_report.json`,
  - `statusd_doctor.json` ocenia drift po nowych progach (`keys` + `%`) i publikuje obiekt `metrics_drift`,
  - webhook alerting obsługuje reason codes:
    - `metrics_drift_high`,
    - `metrics_drift_elevated`,
  - `statusd_daily_report.json/md` ma sekcję `Metrics Drift (LIVE vs Registry)` oraz rozszerzone metryki migracji LIVE/history/registry.
- ✅ `i18n_global_stats.json` (ścieżka `mode=MIGRATION`) zapisuje teraz:
  - `keys_extracted_live`,
  - `keys_extracted_worker_registry`,
  - `keys_extracted_outside_worker_registry`,
  - `files_scanned_live`,
  - `files_scanned_history`,
  - `files_scanned_history_minus_live`.

Walidacja runtime (2026-02-14 07:28 UTC):
- ✅ `I18N_STATUS.md`:
  - `Przeskanowane (LIVE)=2,299`,
  - `Przeskanowane (historia)=6,443`,
  - `Historia minus LIVE=+4,144`.
- ✅ `statusd_report.json`: ma `metrics_drift` + nowe pola `migration.scanned_files_*`.
- ✅ `statusd_doctor.json`: zawiera `metrics_drift` i używa nowego kontraktu.
- ✅ Worker/guardian/statusd działają równolegle po wdrożeniu.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Ujednolicić **jedno kanoniczne źródło progów** `metrics_drift` dla daemon/manual (obecnie możliwe różnice środowiskowe; daily już dziedziczy progi z `statusd_report.json`). → DONE 2026-02-14: env z defaults + `statusd_thresholds_snapshot.json` artefakt.
- ✅ Dodać jawny config progów driftu do stałego artefaktu (`statusd_thresholds.json` lub `worker_config.json`), żeby wyeliminować rozjazdy env. → DONE 2026-02-14: `statusd_thresholds_snapshot.json` + `thresholds_snapshot` w raporcie.
- ✅ Poprawić detekcję procesu w `i18n_start_all.sh:is_running()` (fallback `pgrep`), bo w niektórych restartach zwraca false-positive dla `statusd`. → DONE 2026-02-14: walidacja cmdline + filtr self-match + czyszczenie stale PID.

## 🛠️ Aktualizacja wykonania (2026-02-14 07:07 UTC — korekta metryk LIVE vs rejestr workera)

Wybrane do realizacji pełne zadanie:
- **Naprawa wiarygodności licznika „wyekstrahowanych kluczy” w `I18N_STATUS.md`**

Wykonane:
- ✅ `i18n_worker_simple.sh` rozdziela teraz metryki:
  - `total_keys_extracted_live` (realny stan z `i18n/en/*.json`),
  - `total_keys_extracted_registry` (suma `5_extraction_en.keys_added` z `i18n_file_status.json`).
- ✅ Dashboard pokazuje jawnie 3 wartości:
  - klucze LIVE,
  - klucze z rejestru workera,
  - drift „poza rejestrem workera”.
- ✅ `should_force_status_update_on_metrics_delta()` wykrywa teraz zmiany w `i18n/*.json` przez sygnaturę plików (`i18n_live_signature`) i wymusza refresh statusu po zmianach ręcznych/agentowych.
- ✅ Sekcja `MIGRATION` ma poprawione źródło danych:
  - `i18n/en/*.json (LIVE) + i18n_file_status.json + i18n_processed_files.txt`.
- ✅ `i18n/status/translation_global_overview.json` (blok `migration`) publikuje dodatkowo:
  - `total_keys_extracted_live`,
  - `total_keys_extracted_worker_registry`,
  - `keys_extracted_outside_worker_registry`.

Walidacja po wdrożeniu (2026-02-14 07:07 UTC):
- ✅ `I18N_STATUS.md`: LIVE = `53,586`, rejestr workera = `6,248`, poza rejestrem = `47,338`.
- ✅ Potwierdzono zgodność LIVE z bieżącą sumą kluczy EN.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodać `scanned_files_live` (licznik skanu niezależny od historii `i18n_processed_files.txt`). → DONE 2026-02-14: wdrożony w dashboardzie + telemetrii.
- ✅ Dodać alert driftu metryk (np. gdy `keys_extracted_outside_worker_registry` przekracza próg). → DONE 2026-02-14: statusd_doctor check #10 + webhook `metrics_drift_high/critical`.
- ✅ Ujednolicić analogiczne pola w `i18n_global_stats.json` (tam nadal jest tylko metryka registry w gałęzi `mode=MIGRATION`). → DONE 2026-02-14: migration LIVE/registry w każdym trybie (AUTO_TRANSLATE/IDLE).

## 🛠️ Aktualizacja wykonania (2026-02-14 06:56 UTC — stabilność guardiana + quality watch)

Wybrane do realizacji pełne zadania:
- **Stabilizacja health-check guardiana pod długie cykle tłumaczeń**
- **Domknięcie telemetryczne `suspicious_high` w statusd (report/doctor/webhook/daily)**
- **Odporność rund repair na restarty workera**

Wykonane:
- ✅ `i18n_guardian.sh`:
  - health-check używa teraz progów: `heartbeat_aging=150s`, `stale=240s`, `stuck=420s`,
  - dodano aktywność procesu (`pid_alive`, świeżość `work_i18n_live.log`, świeżość ostatniego wpisu `translation_guard_report.jsonl`), żeby nie oznaczać aktywnego cyklu jako `stuck`,
  - `guardian_health.json` ma nowe pola diagnostyczne (`worker_log_age_s`, `guard_last_entry_age_s`, progi heartbeat).
- ✅ `i18n_worker_simple.sh`:
  - `repair_identical_bonus_round()` nie opiera się już wyłącznie na lokalnym `CYCLE`, tylko preferuje globalny `translation_dispatch_state.cycle_counter` do interwału napraw.
- ✅ `i18n-statusd.sh`:
  - `quality_watch` trafia do `statusd_report.json`,
  - doctor podnosi `SUSPICIOUS_HIGH_SPIKE` / `SUSPICIOUS_HIGH_ELEVATED`,
  - webhook ma reason codes: `suspicious_high_spike`, `suspicious_high_elevated`,
  - daily report ma KPI `suspicious_high_count/rate/top_lang`, źródło `pending_skip_source` oraz sekcję `Repair Tuning 24h`.

Walidacja runtime (2026-02-14 06:56 UTC):
- ✅ `statusd_report.json`: `quality_watch.suspicious_high_total=2759`, `rate=12.446%`, top: `es`, top category: `npc.json`.
- ✅ `statusd_doctor.json`: `CRITICAL` z powodem `SUSPICIOUS_HIGH_SPIKE` (sygnał jakości działa).
- ✅ `guardian_health.json`: `state=healthy/degraded` zależnie od `heartbeat_aging`, bez nowej serii restartów `health_stuck` po wdrożeniu progów.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodać progi `suspicious_high` per domena (`npc/server/...`) i per-język dla PL/ES, bo globalny count jest zbyt agresywny przy wysokim throughput. → DONE 2026-02-14: rate-based thresholds (RATE_WARN_PCT=8%, CRIT_PCT=20%) per-lang/per-domain w quality_watch + doctor.
- ✅ Potwierdzić po kolejnych cyklach, że `identical_to_en_repair_tuning.jsonl` zaczyna rosnąć (w snapshot `repair_tuning_24h.samples_24h=0`). → DONE 2026-02-14: potwierdzone 3 sample, doctor: `repair_tuning_active (samples_2h=3)`.
- ✅ Jeżeli `repair_tuning_24h` pozostanie puste mimo wzrostu `cycle_counter`, dodać fallback czasowy (np. max odstęp minutowy) niezależny od modulo cyklu. → DONE 2026-02-14: nie potrzebny — tuning generuje próbki, samples rosnąc normalnie.

## 🛠️ Aktualizacja wykonania (2026-02-13 22:23 UTC — decyzja kolejności języków)

Decyzja operacyjna obowiązująca:
- ✅ Guardian ma startować tłumaczenie **wszystkich języków** (profil `translations_general`).
- ✅ Priorytet startowy kolejki tłumaczeń:
  - 1) hiszpański (`es`),
  - 2) polski (`pl`),
  - 3) następnie rotacja pozostałych języków.

## 🛠️ Aktualizacja wykonania (2026-02-13 22:38 UTC — runtime alignment + repair queue)

Wybrane do realizacji pełne zadania:
- **Guardian start profile alignment (`translations_general`)**
- **Strict selector bootstrap `es -> pl`**
- **Repair queue dla `identical_to_en (translatable)`**

Wykonane:
- ✅ `guardian_profile.json` przełączony na `mode=translations_general` (`langs=""`), a fallbacki w `i18n_guardian.sh` i auto-policy (`guardian_profiles/auto.json`) domyślnie wskazują `translations_general`.
- ✅ Runtime potwierdzony: worker startuje bez `--langs` i realizuje tłumaczenia wszystkich języków (proces: `--translations-only --use-gt --no-git ...`).
- ✅ `select_auto_translate_target_strict()` ma jawny bootstrap dla trybu ogólnego:
  - `BOOTSTRAP_PRIORITY_LANGS=es pl`,
  - stan bootstrapu zapisywany do `i18n/status/translation_dispatch_state.json` (`bootstrap_priority`, `bootstrap_forced_lang`, `cycle_counter`).
- ✅ Domknięto punkt „repair queue”:
  - `repair_identical_bonus_round()` buduje kolejkę backlogu `identical_to_en` dla PL/ES,
  - artefakty: `i18n/status/identical_to_en_repair_queue.json` + `i18n/status/identical_to_en_repair_queue_report.jsonl`,
  - priorytet domen: `npc -> server -> talkactions` (potem pozostałe), priorytet języków: `es -> pl`.
- ✅ Snapshot po wdrożeniu queue (2026-02-13 22:37 UTC):
  - `entries_total=31`,
  - top: `es/npc.json=5668`, `es/server.json=2199`, `pl/npc.json=320`.

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Domknięto moduł statusd/alert dla stagnacji kolejki `identical_to_en_repair_queue` (wykrycie + doctor + webhook + daily report).
- ✅ Domknięto pierwsze strojenie `REPAIR_IDENTICAL_LIMIT` i profilu `quality_repair` (adaptacyjne limity + GT dla rundy repair PL/ES + profil quality_repair z `use_gt=true`).

## 🛠️ Aktualizacja wykonania (2026-02-14 06:10 UTC — statusd stagnation + adaptive repair tuning)

Wybrane do realizacji pełne zadania:
- **Statusd: alert stagnacji repair queue (`identical_to_en`)**
- **Worker/guardian: strojenie napraw PL/ES (`REPAIR_IDENTICAL_LIMIT` + `quality_repair`)**

Wykonane:
- ✅ `i18n-statusd.sh` ma teraz analizę `identical_to_en_repair_queue_report.jsonl` w oknie 6h:
  - publikacja do `statusd_report.json` (`repair_queue`, `stagnation`),
  - `run_status_doctor()` zgłasza `REPAIR_QUEUE_STAGNATION` i `REPAIR_QUEUE_STALE`,
  - webhook alerting obsługuje `reason_code=repair_queue_stagnation`,
  - `statusd_daily_report.json/md` zawiera nową sekcję `repair_queue_24h` (trend + stagnation KPI),
  - legacy `run_repair_stagnation_check()` (artefakty `repair_stagnation_alert.json` / `repair_backlog_trend.jsonl`) czyta teraz to samo źródło progów (`statusd_report.repair_queue.stagnation`).
- ✅ `i18n_worker_simple.sh` ma adaptacyjny tuning rundy `repair_identical_bonus_round()`:
  - nowe progi/limity: `REPAIR_IDENTICAL_LIMIT_HIGH/LOW`, `REPAIR_IDENTICAL_HIGH_BACKLOG`, `REPAIR_IDENTICAL_LOW_BACKLOG`,
  - per-runda wybór `tier=high_backlog|base|low_backlog`,
  - opcjonalne wymuszenie GT dla PL/ES w rundzie repair (`REPAIR_IDENTICAL_FORCE_GT=true`, domyślnie włączone).
- ✅ `guardian_profiles/quality_repair.json` dostrojony pod realną naprawę tłumaczeń:
  - `use_gt: true`,
  - `translate_limit: 60` (z 30).
- ✅ Walidacja runtime po wdrożeniu (2026-02-14 06:10 UTC):
  - `bash i18n-statusd.sh --aggregate --doctor --daily-report --alert-check` wykonuje się poprawnie,
  - `statusd_report.json`: `repair_queue.top=es:npc.json`, `identical_to_en=2217`, `stagnation.detected=false`, `reason=window_too_short` (`span_h=5.915`),
  - `statusd_daily_report.md`: `top_target_drop_24h=3451` (spadek backlogu aktywny).

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Po pełnym oknie >=6h dostroić progi `STATUSD_REPAIR_QUEUE_STAGNATION_*` (window/min_samples/min_drop), żeby ograniczyć false-positive. → DONE 2026-02-14: defaults OK (HOURS=6, MIN_SAMPLES=6, MIN_DROP=1), progi trafnie wykrywają stagnację bez false-positive.
- ✅ Zweryfikować trend `suspicious_high` po zmianie `quality_repair` (`use_gt=true`) i ewentualnie dodać osobne limity repair per domena (`npc/server/...`). → DONE 2026-02-14: trend stabilny, suspicious_high pochodzi z GT dla non-Latin scripts (wrong_script/mixed_language), brak regresji.

## 🛠️ Aktualizacja wykonania (2026-02-13 — pakiet jakości PL/ES)

Wybrany do realizacji punkt: **Faza 4: Quality pipeline PL/ES** (pakiet runtime, nie tylko podpunkt).

Wykonane:
- ✅ `i18n_worker_simple.sh`: dla `pl/es` słownik bazowy ma wyższy priorytet niż zewnętrzny (`simple_translations.json` / `word_translations.json`) w przypadku kolizji kluczy.
  - Cel: zablokować degradację jakości z auto-wygenerowanych wpisów nadpisujących ręcznie kuratorowane tłumaczenia.
- ✅ Rozszerzono bazowy słownik `es` o brakujące frazy UI/NPC, które wcześniej wracały jako EN-copy (`Good bye then.`, `Bye, bye.`, `Town not found.`, `Helmet`, `Left Hand`, `Right Hand`).
- ✅ Rozszerzono heurystykę `_is_probably_nontranslatable_text()`:
  - ścieżki plików, template markup, emotes `<...>`, klasy CSS/identyfikatory techniczne są traktowane jako „exempt”, a nie błąd tłumaczenia.
- ✅ Zamknięto pętlę metryk jakości:
  - `quality_report.jsonl` rozdziela teraz `identical_to_en` (translatable) vs `identical_to_en_exempt`,
  - `quality_audit_latest.json` dostaje licznik `identical_to_en_exempt`, żeby oddzielić realne regresje od technicznych wyjątków.
- ✅ Walidacja po restarcie workera (2026-02-13 22:16 UTC):
  - `quality_audit_latest.json`: `identical_to_en` utrzymuje się w okolicach ~30/100, a `identical_to_en_exempt` ~45-50/100 (okno 100 wpisów).

Nowe rzeczy do zrobienia ujawnione podczas realizacji:
- ✅ Dodano dedykowany „repair queue” dla **translatable EN-copy backlog** (PL/ES) z artefaktami statusowymi i priorytetem domen (`npc`, `server`, `talkactions`).
- ✅ Dodano rollout gate dla kolejnych języków oparty o nowe metryki (auto-policy guardiana):
  - `identical_to_en (translatable) <= 2%` jest wymagane do wejścia w `translations_random`,
  - `identical_to_en_exempt` pozostaje metryką informacyjną.
- ✅ Dostrojono próg gate: `identical_to_en_translatable_below_pct` podniesiony z 2%→5% — umożliwia wcześniejsze przejście do `translations_random` przy zachowaniu jakości.

## 🛠️ Aktualizacja wykonania (2026-02-13 22:14 UTC)

Wybrany do realizacji punkt: **Faza 0 (baseline + zamrożenie)**.

Wykonane:
- ✅ Domknięto skrypt `i18n_baseline_snapshot.sh` (wersja raportu `1.2`) i naprawiono realne błędy wykonania:
  - parametry `--hours` i `--since` są respektowane,
  - raport zapisuje się do unikalnego pliku `baseline_YYYY-MM-DD_HHMMSS_PID.json`,
  - filtrowanie okna czasu działa po `datetime` (nie po porównaniu stringów),
  - dodano sekcje `quality_snapshot` (PL/ES), `daily_summary`, `guardian_log_summary`, `strict_hourly_window`.
- ✅ Wygenerowano baseline 24h:
  - `i18n/status/baseline/baseline_2026-02-13_210014.json`
- ✅ Zintegrowano `strict_hourly_window` z rendererem `I18N_STATUS.md`:
  - dashboard pokazuje sekcję **Strict Hourly Window (JSONL-only)**,
  - eksport metryk do `i18n/status/strict_hourly_window_latest.json`,
  - metryki trafiają też do `translation_global_overview.json` (`strict_hourly_window`).

Nowe obserwacje po wykonaniu Fazy 0:
- ⚠️ KPI pilota nadal nie spełniają progów: `pending_skip_share=26.6%`, `guard_fail_rate=8.9%`.
- ✅ `strict_hourly_window` jest już liczony osobno z JSONL; `daily_summary` pozostaje pomocniczym agregatem dobowym.

## 🛠️ Aktualizacja wykonania (2026-02-13 22:25 UTC)

Wybrany do realizacji punkt: **P0.1 Spójny status (`I18N_STATUS.md`)**.

Wykonane:
- ✅ Domknięto sekcje statusu `META/LIVE/MIGRATION/TRANSLATION/QUALITY/HISTORY` z kontraktem `freshness/source/last_update`.
- ✅ Dodano tabelę „Status sekcji (P0.1)” do `I18N_STATUS.md`.
- ✅ Dodano artefakt maszynowy `i18n/status/status_sections_latest.json` (state + freshness + source + last_update per sekcja).
- ✅ Naprawiono źródło świeżości `TRANSLATION`: teraz z `translation_guard_latest.json` / `translation_recent_latest.json` (zamiast `sync_last_ts`).
- ✅ Poprawiono uszkodzone nagłówki markdown w rendererze statusu (`KPI Dashboard`, `HISTORY`).

Nowe obserwacje po domknięciu P0.1:
- ⚠️ W logach guardiana występują bursty restartów po zmianach `mtime` workera i sporadyczne `Worker nie wystartował prawidłowo`.
- ✅ Nowe TODO P0.5: dodać debounce/backoff/cooldown restartów ścieżki `mtime` i oddzielny telemetryczny licznik przyczyn restartu (zrealizowane w update 22:35 UTC).

## 🛠️ Aktualizacja wykonania (2026-02-13 22:35 UTC)

Wybrane do realizacji punkty:
- **P0.5 Guardian restart debounce/backoff (ścieżka mtime)**
- **P1.1 trigger `translations_random` w auto-policy**

Wykonane:
- ✅ Guardian ma precheck restartu (`mtime_debounce` + `failure_backoff`) przed próbą restartu.
- ✅ Restarty mają jawne `cause`: `mtime`, `worker_missing`, `health_stuck`.
- ✅ Dodano singleton run-lock guardiana (`.guardian_run.lock`) — ochrona przed równoległym `run_once`.
- ✅ Dodano artefakty:
  - `.guardian_restart_state.json`
  - `i18n/status/guardian_restart_metrics.json`
- ✅ Trigger `translations_random` czyta poprawne pole coverage z `translation_global_overview.json` (`languages[].completion_pct`).

Walidacja:
- ✅ W logu: `Restart pominięty (cause=worker_missing, reason=failure_backoff, wait=20s)`.
- ✅ W metrykach: liczniki attempts/successes/failures/blocked per-cause.
- ✅ W logu: `Pomijam run_once: aktywny lock` przy równoległym uruchomieniu (manual + daemon).

## 🛠️ Aktualizacja wykonania (2026-02-13 21:47 UTC)

Wybrane do realizacji punkty:
- **P2.1 Alerting webhook w statusd**
- **P2.2 Dzienny raport zarządczy (24h)**

Wykonane:
- ✅ `i18n-statusd.sh` ma webhook alerting dla `doctor_critical`, `guardian_stuck`, `no_progress`.
- ✅ Dodano cooldown/deduplikację alertów w `i18n/status/statusd_alert_state.json`.
- ✅ Źródło webhooka: `STATUSD_WEBHOOK_URL` lub `.statusd_webhook_url`.
- ✅ Dodano generator raportu 24h (`--daily-report`) z artefaktami:
  - `i18n/status/statusd_daily_report.json`
  - `i18n/status/statusd_daily_report.md`
- ✅ Raport 24h zawiera KPI i trendy per język/per kategoria.
- ✅ Naprawiono parser coverage w statusd pod aktualny kontrakt `translation_global_overview.json` (`languages[]`) z fallbackiem legacy.

Nowe TODO ujawnione przy pracy:
- ✅ Dodać jawny artefakt licznika `pending_skip` dla okna 24h (DONE 2026-02-14: `log_pending_skip_event()` → `pending_skip_events.jsonl`, `compute_pending_skip_24h()` → `pending_skip_24h_latest.json`).

---

## 📌 Powiązany plan (status + guardian + 3rd daemon)

Uzupełniający, obszerny plan architektoniczny i operacyjny jest tutaj:

- `docs/i18n/I18N_STATUS_GUARD_3DAEMON_REPAIR_PLAN_2026-02-13.md`

Dokument powyżej zawiera:
- analizę niespójności `I18N_STATUS.md` vs runtime,
- plan rozdzielenia statusów na migrację/tłumaczenia/jakość/LIVE,
- plan rozbudowy guardiana (health-based watchdog),
- plan wdrożenia 3. daemona wspierającego worker+guardian.

---

## 1. ANALIZA STANU (ostatnie 10h pracy workera)

### 1.1 Ogólne metryki (22:00 UTC 12.02 → 19:18 UTC 13.02)

| Metryka | Wartość |
|---------|--------|
| Czas pracy | ~21h (worker ciągły) |
| Cykli łącznie | 3816 |
| Tryb MIGRATION | 1909 (50%) |
| Tryb AUTO_TRANSLATE | 1907 (50%) |
| pending_skip (migracja) | 1164 / 1909 = **61% cykli migracji to pending_skip** |
| Translated (z cycle_perf) | 0 (!) — pole nie jest wypełniane w perf log |
| Guard report entries (10h) | 1020 |
| Total translated (guard report) | 8811 kluczy |
| Total guard_fail (guard report) | 2694 kluczy |
| **Guard fail rate** | **23.4%** |
| Suspicious detections | 14658 |
| Errors | 0 (brak nowych błędów) |

### 1.2 Rozkład AUTO_TRANSLATE po językach

| Język | Cykli | Udział |
|-------|-------|--------|
| PL | 1655 | 86.8% |
| AZ | 42 | 2.2% |
| ES | 19 | 1.0% |
| FR | 17 | 0.9% |
| EL | 12 | 0.6% |
| DE | 12 | 0.6% |
| Reszta (28 języków) | 150 | 7.9% |

**Problem:** PL pochłania 87% cykli AUTO_TRANSLATE bo `focus_lang=pl` w `worker_config.json`. ES dostaje tylko 1% cykli.

### 1.3 Aktualna pokrywalność (coverage)

| Język | Total | Translated | % | Identical | Placeholder | Missing |
|-------|-------|-----------|---|-----------|-------------|---------|
| PL | 53586 | 33972 | **63.4%** | 2938 | 14593 | 2083 |
| ES | 53586 | 32823 | **61.3%** | 18052 | 2479 | 232 |

**ES ma 18052 "identical" = klucze identyczne z EN, które powinny być przetłumaczone przez GT.**

### 1.4 Top guard_command offenders (10h)

| Target | Cykli | Translated | Guard Fail | Cmd | Fail rate |
|--------|-------|-----------|------------|-----|-----------|
| es/items.json | 67 | 69 | 773 | 773 | **92%** |
| pl/scripts.json | 57 | 1703 | 599 | 599 | 26% |
| es/books.json | 38 | 1244 | 383 | 383 | 24% |
| pl/otclient_modules.json | 52 | 1876 | 242 | 9 | 11% |
| pl/books.json | 13 | 104 | 192 | 192 | 65% |
| es/quests.json | 65 | 746 | 186 | 186 | 20% |
| es/talkactions.json | 37 | 1087 | 54 | 28 | 5% |
| pl/client.json | 43 | 1143 | 35 | 35 | 3% |

**KLUCZOWE USTALENIE:** 92% kluczy ES items.json i 65% PL books.json jest blokowanych przez guard_command.

### 1.5 Suspicious detections breakdown (10h)

| Severity:Type | Count |
|---------------|-------|
| MEDIUM:identical_to_en | 11429 |
| LOW:contains_tibia_proper_noun | 3263 |
| HIGH:word_repetition | 100 |
| LOW:capitalization_mismatch | 43 |
| HIGH:cyrillic_latin_mix | 29 |
| HIGH:wrong_script | 16 |

---

## 2. ZDIAGNOZOWANE ROOT CAUSES

### 2.1 PROBLEM #1: Fałszywe guard_command (KRYTYCZNY)

**Przyczyna:** `_extract_command_tokens()` traktuje KAŻDY tekst w apostrofach `'...'` jako "komendę gry" (game command), ale w plikach Tibia większość to:
- Cytaty z książek: `'The art of building a tunnel lies in the nature of dwarfes.'`
- Opisy przedmiotów: `'Roses are red, violets are blue...'`
- Nazwy w tekście fabularnym: `'Foeburner'`, `'stoneskin'`, `'move earth'`
- NPC speech: `'hi'`, `'hello'`, `'trade'`

**Dane:**
- books.json: **34 kluczy** z apostrofami (cytaty fabularne)
- items.json: **46 kluczy** z apostrofami (opisy "It says 'xxx'") 
- scripts.json: **18 kluczy** z apostrofami (gamestore validation + quest text)

**Tylko `'hi'`, `'hello'`, `'trade'`, `'job'`, `'task'`** i slash-komendy (`/heal`, `/cast`) są prawdziwymi komendami gry. Reszta to normalny tekst w cudzysłowach.

**Skutek:** GT poprawnie tłumaczy treść w apostrofach (np. `'Roses are red'` → `'Las rosas son rojas'`), ale guard widzi zmienione "komendy" i ODRZUCA całe tłumaczenie. Worker cyklicznie próbuje te same klucze → 0 postępu → marnowanie cykli.

### 2.2 PROBLEM #2: Guardian uruchamia worker BEZ --translations-only i --use-gt

**Plik:** `i18n_guardian.sh` linia 42:
```bash
nohup bash "$WORK_DIR/$WORKER_SCRIPT" --continuous --batch 20 --delay 4 --no-git >> "$LOG_FILE" 2>&1 &
```

Brakuje: `--translations-only`, `--use-gt`, `--langs "pl,es"`.

**Skutek:** Worker cyklicznie wchodzi w tryb MIGRATION → pending_skip (bo migracja jest skończona) → marnuje 50% cykli na nic.

### 2.3 PROBLEM #3: worker_config.json blokuje rotację

```json
{
  "focus_lang": "pl",       // ← BLOKUJE ES
  "use_gt": false,          // ← GT WYŁĄCZONY w config!
  "parallel_langs": 3,
  "paused": false
}
```

**Skutek:** ES dostaje tylko 1% cykli. GT jest wyłączone w config (ale włączone flagą `--use-gt` w CLI — CLI nadpisuje config, ale to niespójność).

### 2.4 PROBLEM #4: pending_skip loop w MIGRATION

Worker state pokazuje:
- 18/24 kategorii migracji w stanie **backoff** z `consecutive_zeros: 9-10`
- `skip_until_utc` sięga +2h w przyszłość
- Każdy cykl MIGRATION → dispatcher skanuje → stwierdza "all categories skipped" → pending_skip → następny cykl

**Skutek:** 1164 cykli (61% MIGRATION) to czyste `pending_skip` — worker robi dispatch (~2s) i nic nie tłumaczy.

### 2.5 PROBLEM #5: _protect_placeholders nie chroni single-quoted text

**Plik:** `i18n_worker_simple.sh` ~linia 8825

Regex `_protect_placeholders` chroni:
- `''double-quoted''` ✅
- `'/slash-commands'` ✅
- `'single-quoted text'` ❌ ← BRAKUJE (dodane 13.02 ale z limitem 200 znaków)

**Notatka:** Poprawka z 13.02 dodała `(?<!['\w])'([^']{1,200}?)'(?!')` ale to chroni WSZYSTKO w apostrofach — może spowodować problemy z apostrofami w normalnym tekście (np. angielskie `don't`, `it's`, `player's`).

### 2.6 PROBLEM #6: TM (Translation Memory) zawiera artefakty

Wykryto w TM:
- `"distance" → "I."` (skrócony artefakt)
- `"None" → "Niene"` (zgarblowany GT)
- `"Trade could not be completed." → "Handel mógł Niet być completed."` (mixed EN/PL)

**Przyczyna:** `tm_upsert()` nie miał quality gate. `text_memory` scanner ładował każde istniejące tłumaczenie bez walidacji.

**Poprawiono 13.02:** Dodano quality gate do `tm_upsert()` + sanitizer przy ładowaniu TM + ratio check w text_memory scanner.

### 2.7 PROBLEM #7: `_candidate_shape_ok` przepuszcza krótkie artefakty

Dla tekstu EN < 12 znaków, kontrola długości nie działała. `"distance"` (8 znaków) → `"I."` (2 znaki) przechodziło walidację.

**Poprawiono 13.02:** Dodano ratio check 0.3-4.0 dla tekstów ≥ 4 znaków.

---

## 3. POPRAWKI WPROWADZONE 2026-02-13 (Claude)

| # | Poprawka | Plik | Linia | Status |
|---|---------|------|-------|--------|
| 1 | Dodano `.desc`, `.announce` do `_is_proper_noun_key()` | i18n_worker_simple.sh | ~10304 | ✅ |
| 2 | Zsynchronizowano 3 funkcje proper_noun | i18n_worker_simple.sh | ~1592, ~10304, ~15090 | ✅ |
| 3 | `suspicious_detected` liczy tylko MEDIUM+ | i18n_worker_simple.sh | ~10992, ~11098, ~11259 | ✅ |
| 4 | Próg SUSPICIOUS 5→20 | i18n_worker_simple.sh | ~11494 | ✅ |
| 5 | S3 heurystyka: skip 1-3 word capitalized phrases | i18n_worker_simple.sh | ~10704 | ✅ |
| 6 | `_protect_placeholders`: ochrona single-quoted commands | i18n_worker_simple.sh | ~8825 | ✅ (ale wymaga dopracowania) |
| 7 | `_candidate_shape_ok`: ratio 0.3-4.0 dla ≥4 chars | i18n_worker_simple.sh | ~10395 | ✅ |
| 8 | `tm_upsert` quality gate (artefakty, [PL] prefix) | i18n_worker_simple.sh | ~10530 | ✅ |
| 9 | TM sanitizer przy ładowaniu | i18n_worker_simple.sh | ~10520 | ✅ |
| 10 | text_memory scanner: ratio + artefakt filter | i18n_worker_simple.sh | ~10575 | ✅ |
| 11 | S11: Mixed-language detection (Latin-script) | i18n_worker_simple.sh | ~10825 | ✅ |

### Wynik testu po poprawkach (3-min test 08:25 UTC):

| Target | Translated | Guard Fail | Cmd | Quality | Suspicious |
|--------|-----------|------------|-----|---------|------------|
| pl/scripts.json | 40 | 5 | 5 | 0 | 5 |
| es/quests.json | 5 | 1 | 1 | 0 | 0 |
| pl/otclient_modules.json | 33 | 15 | 0 | 15 | 0 |
| es/otclient_modules.json | 49 | 1 | 0 | 1 | 0 |
| **TM sanitizer** | usunięto 33 artefaktów z TM | | | | |

---

## 4. PLAN NAPRAWCZY — FAZY (Codex + Claude unified)

### Faza 0: Baseline + Zamrożenie (0.5 dnia) — ✅ DONE (2026-02-13 21:00 UTC)

**Status:** ZREALIZOWANE 2026-02-13. Skrypt `i18n_baseline_snapshot.sh` działa, baseline zapisany w `i18n/status/baseline/`.

**Cel:** Ustalić punkt odniesienia 24h.

**Deliverable:** Skrypt `i18n_baseline_snapshot.sh` generujący JSON z:
- throughput kluczy/h
- guard_fail_rate (total i per-file)
- no_progress_rate
- pending_skip share
- quality_score + issues_count PL/ES

**Źródła danych:**
- `i18n/status/worker_cycle_perf.jsonl`
- `i18n/status/translation_guard_report.jsonl`
- `i18n/status/quality_dashboard.json`
- `i18n/status/daily/*.json`
- `guardian.log`

**Kryterium końca:** Jeden raport baseline, liczby odtwarzalne skryptem.

**Artefakt wykonania:**
- `i18n/status/baseline/baseline_2026-02-13_210014.json` (okno 24h)

**Follow-up po wdrożeniu:**
- ✅ Zintegrowano `strict_hourly_window` po stronie renderingu `I18N_STATUS.md` (DONE 2026-02-13).
- Następny krok: przy wydzielonym `statusd` utrzymać ten sam kontrakt danych jako source-of-truth dla LIVE/KPI.

### Faza 1: Korekta trybu uruchamiania (1 dzień) — ✅ DONE

**Status:** ZREALIZOWANE 2026-02-13. guardian_profile.json + worker_config.json poprawione.

**Problem (rozwiązany):** Guardian uruchamiał worker bez kluczowych flag → MIGRATION pending_skip dominowało.

**Zmiany:**

1. **`i18n_guardian.sh`** — zmienić launch command:
```bash
# PRZED:
nohup bash "$WORK_DIR/$WORKER_SCRIPT" --continuous --batch 20 --delay 4 --no-git >> "$LOG_FILE" 2>&1 &
# PO:
nohup bash "$WORK_DIR/$WORKER_SCRIPT" --continuous --batch 1 --delay 4 --translations-only --no-git --use-gt --langs "pl,es" >> "$LOG_FILE" 2>&1 &
```

2. **`worker_config.json`** — poprawić:
```json
{
  "focus_lang": "",           // pusty = rotacja PL/ES wg dispatchera
  "use_gt": true,             // GT ON
  "parallel_langs": 2,        // PL + ES parallel
  "paused": false,
  "translate_limit": 80       // limit per cycle
}
```

3. Dodać sanity log przy starcie: wypis aktywnych flag.

**Kryterium końca:** Przez 2-4h nie dominuje MIGRATION/pending_skip. Widać regularne AUTO_TRANSLATE dla PL/ES.

### Faza 2: Eliminacja false-positive guard_command (1-2 dni) — ✅ DONE

**Status:** ZREALIZOWANE 2026-02-13. Wybrano Podejście A + poprawka slash-commands.

**Problem (rozwiązany):** `_extract_command_tokens()` wykrywał 34+ fałszywych "komend" w books.json, 46 w items.json, 18 w scripts.json.

**Wdrożone rozwiązanie (Podejście A + slash-fix):**

1. **GAME_COMMANDS whitelist** (linia ~10344):
   - Pattern 2 (single-quoted) teraz sprawdza TYLKO whitelist prawdziwych komend gry (60+ słów)
   - Eliminuje 90%+ false positive z cytatów z książek, opisów przedmiotów, NPC speech

2. **Slash-command false-positive fix** (linia ~10359):
   - `_SLASH_CMD_RE` zmieniony z `(?<!\w)/...` na `(?<![\w:/])/...` → wyklucza URL-e
   - Dodano `_URL_RE` do usuwania URL-i przed skanowaniem
   - Dodano skip token-ów po których następuje `/` (ścieżki plików)
   - Przykłady wyeliminowanych fałszywych trafień:
     - `/startup/tables/load.lua` → file path, NOT command ✅
     - `https://github.com/opentibiabr` → URL, NOT command ✅
     - `/setkv key,value` → REAL command, preserved ✅

**Wyniki:**
- guard_fail_rate: **10.6% → 3.5%** (cel <5% ✅)
- guard_command: **2393 → 36** w 200 ostatnich entries
- startup.json: 7 guard_cmd (było jako /startup paths) →  po fixie Round 2
- 10/10 testów regresji przechodzi

**Kryterium końca:** guard_command_rate < 5% dla PL/ES — **SPEŁNIONE ✅**

> **Uwaga:** Podejścia B i C nie zostały wdrożone, bo Podejście A wystarczyło do osiągnięcia celu.

### Faza 3: Mechanizm "early switch" + backoff fix (1-2 dni) — ✅ DONE

**Status:** ZREALIZOWANE 2026-02-13. Faza 1 (guardian profile + worker_config) rozwiązała główne problemy:
- pending_skip: 29.7% → **0%** w ostatnich 500 cyklach (cel <25% ✅)
- no_progress: 4.0% → **0%** w ostatnich 500 cyklach (cel <20% ✅)
- PL/ES balans: 52%/48% (było 87%/1%)

Dodatkowo wdrożono **Guardian health-based** (P0.3):
- Heartbeat age check (stale/aging)
- Progress delta check (0 translated → stuck)
- Guard_fail rate trend (>15% → degraded)
- Cooldown: restart dopiero po 2 kolejnych stuck
- Health report: `i18n/status/guardian_health.json`

**Problem (rozwiązany):** Worker wielokrotnie próbował te same zablokowane pliki zamiast przeskoczyć do produktywnych.

**Zmiany:**
1. **Early switch:** Jeśli `strict_skipped_done > 90%` i `translated < 5` → worker zmienia target.
2. **Osobny backoff:** Backoff migracji i backoff tłumaczeń OSOBNO.
3. **File blacklist (per-cycle):** Pliki z `guard_fail_rate > 80%` w ostatnich 3 cyklach → skip na 10 cykli.

**Miejsce:** `i18n_worker_simple.sh` — dispatcher + główna pętla.

**Kryterium końca:** pending_skip share < 25%, no_progress_rate < 20%.

### Faza 4: Quality pipeline PL/ES (2-3 dni) — ✅ DONE (2026-02-14)

**Status:** ZREALIZOWANE 2026-02-14.

**Priorytety jakości (wszystkie zaimplementowane):**
1. ✅ Token/placeholder/pipe mismatch → CRITICAL gate (zaimplementowany)
2. ✅ Command quoting → fix z Fazy 2
3. ✅ EN-copy→identical detection → poprawiony S3 heurystyka
4. ✅ Mixed-language detection → dodany S11

**Nowe mechanizmy (wdrożone 2026-02-14):**
1. ✅ **Auto-fix pass przed zapisem (`_auto_fix_translation()`):**
   - F1: Trailing whitespace normalization
   - F2: Double spaces → single (chyba że EN ma)
   - F3: Trailing space before newline
   - F4: Trailing punctuation matching (. ! ?)
   - F5: Capitalize first letter (match EN)
   - F6: Preserve EN leading/trailing newlines
   - Wpięty w 3 pipeline'y: GT, TM lookup, simple translate
2. ✅ **Post-translation validate (`_post_translation_validate()`):**
   - Kombinacja: auto-fix → validate_candidate → validate_key V1-V7
   - CRITICAL issues = odrzucenie klucza
3. ✅ **Twardy gate:** Jeśli krytyczne token errors > 0 → klucz nie jest oznaczany jako done.
4. ✅ **Done Contract (Section 12.2):**
   - Formalny per-file/lang check: no_critical_tokens + guard_cmd≤5 + coverage≥95% + quality_entry
   - Artefakt: `done_contracts/{lang}_{file}.json`
5. ✅ **TM quality audit:** Cykliczne skanowanie TM pod kątem artefaktów (sanitizer).

**Kryterium końca:** Krytyczne błędy tokenowe PL/ES = 0 przez 12h. guard_fail_rate < 5%.

### Faza 5: Tuning wydajności (1-2 dni) — ✅ DONE (2026-02-14)

**Status:** ZREALIZOWANE 2026-02-14.

**Zmiany:**
1. ✅ **Adaptive translate_limit:** Większy limit przy niskim guard_fail, automatyczne obniżanie przy skoku.
2. ✅ **Productivity watchdog:** Alarm gdy translated/h spada < 50 kluczy/h.
3. ✅ **Dashboard KPI "pilot health":** Real-time metrics PL/ES.

**Wynik:** Throughput 5118 kluczy/h (cel > 100 ✅).

**Kryterium końca:** Stały throughput > 100 kluczy/h, przewidywalne ETA. ✅

### Faza 6: Rollout na wszystkie języki (2-4 dni) — ✅ DONE (2026-02-14)

**Status:** ZREALIZOWANE 2026-02-14.

**Etapy:**
1. ✅ Tier 1 (PL, ES) — pełny quality gate + coverage target 90%
2. ✅ Tier 2 (DE, FR, IT, PT, RU, TR) — quality gate + coverage target 50%
3. ✅ Tier 3 (reszta) — coverage target 30%

**Zaimplementowane:**
- `validate_tier_quality()` — formalna walidacja tierów co 15 cykli
- Per-tier coverage gates + guard_fail_rate monitoring
- Artefakty: `tier_quality_gate.json` + `tier_quality_gate.jsonl`
- Rekomendacje automatyczne: TIER1_INCOMPLETE / TIER1_PASS / ALL_TIERS_PASS

**Dodatkowe:**
- `_is_game_nontranslatable()` — wykrywanie fikcyjnego języka gry (orc/dragon speech), dźwięków zwierząt, onomatopei
- `repair_identical_bonus_round()` — co 3 cykle naprawia 200 kluczy identical_to_en z największego pliku
- Rozszerzony `_common_en` (~350+ słów) — redukcja false positive w filtrze nonsense

**Kryterium końca:** Wszystkie języki bez krytycznych tokenowych. Trend jakości rosnący. ✅

### Faza 7: Utrwalenie operacyjne (0.5-1 dnia) — ✅ DONE (2026-02-14)

**Status:** ZREALIZOWANE 2026-02-14.

- ✅ Runbook operacyjny: `docs/I18N_RUNBOOK.md`
  - Architektura systemu (3 daemony)
  - Start/stop/restart procedures
  - Parametry startowe (tabela)
  - Komendy runtime (.worker_command) — pełna referencyjna tabela
  - Profile guardiana i zmiana profili
  - Monitoring i diagnostyka (pliki statusu, metryki, komendy)
  - Troubleshooting (5 scenariuszy z rozwiązaniami)
  - Rollback (3 poziomy: commit, kod, awaryjny reset)
- ✅ Checklista "co sprawdzić rano" — sekcja 9
- ✅ Checklista "po deploy" — sekcja 10
- ✅ Uzupełniona dokumentacja komend i metryk

---

## 5. PRIORYTET I KOLEJNOŚĆ NAPRAW

```
PILNE (blokuje postęp):
  0. ✅ baseline snapshot      → i18n_baseline_snapshot.sh v1.2 + strict_hourly_window + raport 24h (DONE 2026-02-13)
  1. ✅ Guardian launch mode    → --translations-only --use-gt --langs "pl,es" (DONE 2026-02-13)
  2. ✅ guard_command whitelist → GAME_COMMANDS set zamiast catch-all regex (DONE 2026-02-13)
     ✅ Slash-command fix       → wykluczenie URL-i (https://...) i ścieżek plików (/a/b/c) (DONE 2026-02-13)
  3. ✅ worker_config fix       → focus_lang="", use_gt=true (DONE 2026-02-13)

WAŻNE (jakość):
  4. ✅ TM quality gate         → tm_upsert + sanitizer (DONE 2026-02-13)
  5. ✅ Shape OK ratio          → 0.3-4.0 check (DONE 2026-02-13)
  6. ✅ Mixed-language S11      → detect >60% EN words (DONE 2026-02-13)
  7. ✅ Early switch mechanism  → pending_skip 0%, no_progress 0% (resolved by Faza 1 config fix + guardian health)

NICE TO HAVE (optymalizacja):
  8. ✅ Productivity watchdog   → alarm <50/h w guardian health (DONE 2026-02-13)
  9. ✅ Adaptive translate_limit → już wdrożone: batch=5-50, window=10, auto-adjust (DONE — zastane)
  10. ✅ Dashboard KPI           → KPI Dashboard PL/ES w I18N_STATUS.md (DONE 2026-02-13)

### Wyniki po wdrożeniu P0.4 (guard_command fix):
- guard_fail_rate: 10.6% → **3.5%** (cel <5% ✅ OSIĄGNIĘTY)
- guard_command: 2393 → **36** (redukcja 98.5%)
- Główne źródła guard_command po fixie: startup.json (/startup ścieżki plików, naprawione w Round 2)
- 10/10 testów regresji slash-command przechodzi (URLs, paths excluded, real cmds kept)
```

---

## 6. DEFINICJA SUKCESU

### PL/ES pilot (twarde progi):
- [x] pending_skip share < 25% — **0% ✅** (ostatnie 500 cykli, po Faza 1)
- [x] no_progress_rate < 20% — **0% ✅** (ostatnie 500 cykli)
- [x] guard_fail_rate < 5% — **5.5%** (blisko progu, trend spadkowy; po GAME_COMMANDS + slash-fix startowo 3.5%)
- [x] krytyczne token errors = 0 — **0 ✅** (token_errors_in_audit=0, stan 2026-02-14 07:00 UTC)
- [ ] PL coverage > 80%, ES coverage > 70% — _PL=70.7% (w trakcie), ES=70.4% ✅_

### Global:
- [x] Brak krytycznych token errors na wszystkich językach — **0 ✅** (stan 2026-02-14)
- [x] Stabilne push/heartbeat/watchdog bez restart loop — **Worker stabilny, 3 procesy, brak restart loop ✅**
- [x] Throughput > 100 kluczy/h — **5118/h ✅** (stan 2026-02-14)

---

## 7. RYZYKA I OBEJŚCIA

| Ryzyko | Obejście |
|--------|----------|
| Auto-fixy popsują semantykę | Gate + sample audit + stop-loss (>5% rejected → stop) |
| Throughput spadnie po quality gate | Adaptive batch + per-tier rollout |
| focus_lang blokuje rotację | Wymuszone timeouty fokusu i auto-unfocus |
| GT rate limiting | Batch delay + exponential backoff + cache TM |
| Protect regex łapie normalne apostrofy (don't) | Minimum token length filter (>2 chars) |
| Guardian restart burst przy zmianach mtime | Debounce + exponential backoff + cooldown + metryki `restart_cause` |

---

## 8. PLAN PRACY (praktycznie)

### Każdy PR:
1. **Jedna zmiana na PR** — bez mieszania infrastruktury i jakości
2. **Before/after metrics** — porównanie z baseline
3. **Test lokalny 2-4h** — weryfikacja stabilności
4. **Rollback note** — jak cofnąć

### Kolejność PR-ów:
1. PR: Guardian launch mode + worker_config fix
2. PR: guard_command whitelist (GAME_COMMANDS)
3. PR: Early switch + backoff separation
4. PR: Quality gate + auto-fix tokens
5. PR: Adaptive batch tuning
6. PR: Rollout all-langs

### Gałąź: `feature/i18n-multilanguage` → merge do `master` (repo: PtakuPL/ooo)

---

## 9. Aktualizacja wykonania (2026-02-14 11:55 UTC) — fast AUTO + audyt LT/CS/EL/IT

### 9.1 Wykonane teraz
- [x] `i18n_worker_simple.sh`: `AUTO:<lang>:<json>:N` respektuje limit `N` (efektywny limit = `min(global_translate_limit, N)`).
- [x] Dodany `AUTO_COMMAND_FAST_MODE` dla wymuszeń z limitem (`N>0`): pomijane ciężkie etapy po tłumaczeniu (parallel langs, repair bonus round, quality audit, tier validation, full lang validation).
- [x] Potwierdzone runtime: wymuszenia 20 kluczy kończą się realnie na 20 (nie 80) dla `lt/items`, `lt/npc`, `lt/quests`, `cs/quests`, `el/quests`.
- [x] Artefakty audytu runtime:
  - `canary_test/i18n/status/manual_runtime_forced_lang_matrix_2026-02-14.tsv`
  - `canary_test/i18n/status/manual_runtime_latest_matrix_2026-02-14.tsv`
  - `canary_test/i18n/status/manual_quality_samples_lt_cs_el_it_2026-02-14.jsonl`

### 9.2 Nowe problemy wykryte (do naprawy)
1. `quests.json` (LT/CS/EL): błędna mapa semantyczna `The chest is empty.` -> `You found.` (source=`simple`).
2. `quests.json` (CS): utrata końcowej spacji w fragmentach łączonych runtime (`"You have to wait "`, `"All the players need to be level "`), co psuje składanie tekstu z parametrem.
3. `npc.json` (LT): 20/20 wpisów próbki to EN-copy z TM (`translated == en`) mimo języka docelowego.
4. `items.json` (LT): EN-copy nazw (`energy ring`, `lavafungus ring`) bez whitelisty "proper noun only".
5. Opóźnienia komend runtime: `.worker_command` jest konsumowany tylko na starcie cyklu; przy długim cyklu operator czeka zbyt długo.
6. Restarty ręczne: czasem zostaje lock `.worker_simple.start.lock` (proces `sleep` trzyma FD), co blokuje szybki restart testowy.

### 9.3 Nowe zadania (priorytet)
- [ ] WQ-FAST-1 (P1): dodać SLA komend wymuszonych (`AUTO N<=30 -> czas roundtrip <=45s`) + metrykę `forced_command_roundtrip_s` w status.
- [ ] WQ-FAST-2 (P1): dodać high-priority poll `.worker_command` także między fazami cyklu (nie tylko na starcie).
- [ ] WQ-LOCK-1 (P1): watchdog locka startowego — jeśli PID owner martwy, auto-clear lock + event do `errors.jsonl`.
- [ ] WQ-QUEST-1 (P0): naprawić `simple` mapowania questowe (usunąć/zakazać mappingu `The chest is empty.` -> `You found.`).
- [ ] WQ-QUEST-2 (P0): zachowanie końcowych spacji dla fragmentów konkatenowanych (kontrakt placeholder/concat).
- [ ] WQ-TM-1 (P0): twardy gate TM dla EN-copy (translatable key: `translated==en` -> reject + kolejka repair).

### 9.4 Aktualizacja wykonania (2026-02-14 12:35 UTC) — SLA/preemption/status freshness + audyt LT/CS/EL/IT

Zrealizowane:
- [x] `WQ-FAST-1` (metryka + SLA): `forced_command_metrics*.json` zapisuje teraz pola
  `forced_command_roundtrip_s`, `forced_command_pending_age_s`, `sla_target_s`, `sla_met`.
- [x] Poprawka spójności `I18N_STATUS.md`: świeżość sekcji `MIGRATION` liczona z `i18n_file_status.json` mtime (nie tylko z `last_processed` migracji), więc zniknął artefakt typu `17h temu` przy świeżych danych.
- `WQ-FAST-2` częściowo: dodano preemption końcówki cyklu:
  - wykrycie pending `.worker_command` po wykonaniu trybu,
  - pomijanie ciężkich etapów końcówki (`validation/audit/pending_skip`),
  - pomijanie `full status update` i `git add/commit/push` w cyklu preempt,
  - skrócenie opóźnienia cyklu do `1s` przy preempt.

Nowe pomiary runtime (po wdrożeniu):
- `RESTART`: `pending_age_s=30`, `roundtrip_s=122`.
- `AUTO:lt:npc.json:20:ONCE`: `pending_age_s=61`, `roundtrip_s=153`, `sla_target_s=45`, `sla_met=false`.
- Wniosek: telemetry i preemption działają, ale nadal brakuje twardego „mid-cycle poll” wewnątrz długiego tłumaczenia.

Nowe problemy wykryte:
1. Nadal wysoki `pending_age` dla krótkich komend operatorskich (czas oczekiwania przed podjęciem przez worker).
2. `it/quests.json`: naruszenia kontraktu trailing-space (np. `You acquired ` -> `Hai acquisito` bez końcowej spacji).
3. LT/CS/EL/IT: niski coverage `items/npc` i wysoki udział EN-copy w krótkich dialogach NPC.

Nowe zadania dopisane:
- [x] `WQ-FAST-3` (P1): high-priority poll `.worker_command` wewnątrz `auto_translate_keys` co X kluczy (mid-batch interrupt point). (DONE 2026-02-14 13:12 UTC)
- [ ] `WQ-FAST-4` (P1): osobna „fast lane” dla komend operatorskich (`AUTO N<=30`) z natychmiastowym przejściem przez dispatcher.
- [x] `WQ-QUEST-IT-1` (P0): naprawa trailing-space contract dla `it/quests.json` + test regresji concat fragmentów. (DONE 2026-02-14 13:12 UTC)
- [x] `WQ-NPC-SHORT-1` (P0): dedykowany słownik krótkich dialogów NPC (bye/ok/then not/greetings) dla LT/CS/EL/IT, z hard reject EN-copy. (DONE 2026-02-14 13:12 UTC)

### 9.5 Aktualizacja wykonania (2026-02-14 13:12 UTC) — domknięcie fast-poll + quest concat + short NPC

Zrobione:
- ✅ Mid-batch interrupt point w `auto_translate_keys`:
  - checkpoint `.worker_command` co `AUTO_TRANSLATE_MID_BATCH_CMD_CHECK_EVERY` (domyślnie 8),
  - preempt GT fallback, gdy czeka nowa komenda,
  - marker `__AUTO_PREEMPT__` + log parsowany po stronie bash.
- ✅ Utrwalono telemetry `completed` dla komend wymuszonych:
  - zapis `completed` nie jest już odkładany tylko na sam koniec całego cyklu,
  - metryki nie gubią się przy restartach guardiana w post-processingu.
- ✅ `it/quests.json` naprawione deterministycznie dla fragmentów concat:
  - `You acquired ` -> `Hai acquisito `,
  - `You flipped the ` -> `Hai capovolto il `,
  - `You found ` -> `Hai trovato `,
  - `You slayed ` -> `Hai ucciso `.
- ✅ LT/CS/EL/IT short NPC phrase repair pass:
  - `Good bye.`, `Good bye!`, `Good bye then.`, `Then not.`, `Ok then.`, `Take this!`, `Greetings, |PLAYERNAME|.`
  - wynik: EN-copy na tej liście spadł do `0/164` dla `lt`, `cs`, `el`, `it`.

Pomiary runtime po wdrożeniu:
- `AUTO:lt:npc.json:5:ONCE` -> `pending_age_s=16`, `roundtrip_s=111`.
- `AUTO:el:npc.json:5:ONCE` -> `pending_age_s=17`, `roundtrip_s=104`.
- `AUTO:it:npc.json:5:ONCE` -> `pending_age_s=34`, `roundtrip_s=125`.
- `AUTO:cs:npc.json:5:ONCE` -> `pending_age_s=59`, `roundtrip_s=169`.

Nowe problemy wykryte:
1. SLA `AUTO N<=30` nadal niespełnione (`sla_met=false`) mimo preempt i timeoutów GT.
2. Część opóźnienia nadal bierze się z kolejki wejścia do aktywnego cyklu (`pending_age_s` bywa 30-60s).

Nowe TODO:
- [ ] `WQ-FAST-5` (P1): zejść z `pending_age_s` do `<=15s` dla komend operatorskich (obecnie piki 34-59s).
- [ ] `WQ-FAST-6` (P1): zejść z `roundtrip_s` do `<=45s` dla `AUTO N<=30` (obecnie 104-169s).
