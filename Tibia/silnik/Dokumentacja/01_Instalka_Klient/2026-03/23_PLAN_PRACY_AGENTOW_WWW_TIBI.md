# Plan Pracy Agentow - WWW Tibia

Data: 2026-03-06
Zakres: `canary_test/html_copy/` + runtime `/var/www/html`
Cel: zatrzymac chaos z ostatnich zadan WWW (`K67-K74`, `WWW-01..WWW-13`, `K160-K168`) i wprowadzic jeden, powtarzalny workflow dla agentow.

## 1) Problemy, ktore ten plan zamyka
- mieszanie zmian repo i runtime bez jednego source of truth,
- laczenie UI, i18n, PHP flow i runtime deployu w jednym tasku,
- brak ownera na plik i brak twardego podzialu odpowiedzialnosci,
- brak jednego formatu statusu `repo / runtime / E2E / owner`,
- poprawki layoutu robione "na oko" mimo istnienia danych geometrii,
- brak pelnego handoffu po zakonczeniu pracy nad podstrona.

## 2) Source of Truth
1. Status zadania aktualizujemy tylko w `00_START_PRACY_CHECKLISTA.md`.
2. Przebieg prac, decyzje i runtime smoke wpisujemy tylko do `01_DZIENNIK_PRAC.md`.
3. Zmiany UI/layoutu prowadzone sa wedlug `22_STANDARD_WPROWADZANIA_ZMIAN_TIBI_UI.md`.
4. Kontekst runtime/i18n legacy bierzemy z `06_AUDYT_RUNTIME_UI_I18N_TIBIACOM.md`.
5. Backlog WWW i kolejnosc biznesowa bierzemy z:
   - `16_PLAN_WWW_REDDAXE_I18N.md`,
   - `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md`,
   - `03_PLAN_WSPOLNE_KONTO_2_SERWERY.md`.
6. Kod zrodlowy WWW jest w `canary_test/html_copy/`.
7. `/var/www/html/` jest targetem runtime do smoke testow, nie canonical source.
8. Kazda zmiana zrobiona bezposrednio w runtime musi byc w tej samej sesji przeniesiona do repo albo wpisana jako `BLOCKED/EMERGENCY` do dziennika.

## 3) Role agentow
Jedna osoba moze pelnic wiecej niz jedna role, ale nie moze prowadzic dwoch lane'ow naraz bez jawnego handoffu.

### Agent A - UI/Geometry
- Dotyka tylko:
  - `templates/tibiacom/index.php`,
  - `templates/tibiacom/basic.css`,
  - `templates/tibiacom/boxes/templates/*.twig`,
  - strukturalnych wrapperow w `system/templates/*.twig`, jesli sa konieczne do layoutu.
- Odpowiada za:
  - spacing,
  - clipping,
  - sidebar,
  - menu,
  - zgodnosc z `geometry contract`.
- Nie dotyka:
  - `system/pages/*.php`,
  - sesji/logiki `mode`,
  - locale i JSON poza minimalnym odczytem.

### Agent B - I18N/Copy
- Dotyka tylko:
  - `system/locale/pl/main.php`,
  - `system/locale/en/main.php`,
  - `resources/i18n/pl.json`,
  - `resources/i18n/en.json`,
  - assetow `templates/tibiacom/images/menu/label-*.{lang}.gif`.
- Odpowiada za:
  - usuwanie hardcoded EN/PL,
  - fallbacki serwer-side i client-side,
  - strategie tekstu w grafikach,
  - brak mixu EN/PL na trasach krytycznych.
- Nie dotyka:
  - CSS layoutu,
  - logiki konta/sesji,
  - runtime DB bez zgody koordynatora.

### Agent C - PHP Flow / Dual-Server
- Dotyka tylko:
  - `system/pages/*.php`,
  - `system/templates/*.twig` w zakresie danych/flow,
  - `reddaxe/*.php`,
  - ewentualnie `apik/v1/*.php`, jesli task dotyczy flow WWW.
- Odpowiada za:
  - login/sync,
  - `all/classic74/modern`,
  - create-character,
  - highscores/online,
  - sesje i redirecty.
- Nie robi:
  - pixel-pass UI,
  - assetow i18n,
  - zmian "na oko" w `basic.css`.

### Agent D - Runtime / QA / Deploy
- Dotyka tylko:
  - sync repo -> `/var/www/html`,
  - runtime config,
  - cache,
  - `myaac_menu`,
  - smoke testy i screenshoty.
- Odpowiada za:
  - `php -l`, `node --check`, `curl -sk`,
  - potwierdzenie `repo / runtime / E2E`,
  - wpisanie blockerow typu cache, schema, permissions, drift.
- Nie tworzy nowej logiki produktu bez istniejacego patcha w repo.

### Koordynator
- Nadaje task ID.
- Wyznacza jeden typ zadania i jednego ownera lane'u.
- Pilnuje, zeby dwa agenty nie edytowaly tych samych plikow.
- Domyka wpisy w `00`, `01` i dokumencie tematycznym.

## 4) Typy zadan
Kazdy task WWW musi miec jeden glowny typ. Jesli dotyka wiecej niz jednego typu, rozbijamy go na podtaski.

1. `UI`
   - layout, clipping, spacing, sidebar, menu, obrazki layoutowe.
2. `I18N`
   - locale, JSON, fallback, label assets, mixed EN/PL.
3. `FLOW`
   - sesja, konto, sync token, `mode`, create-character, toplisty, online.
4. `RUNTIME`
   - deploy, cache, `myaac_menu`, config runtime, smoke.
5. `DOC`
   - checklisty, audyty, plan, handoff.

Regula:
- `UI` nie niesie zmian biznesowych.
- `I18N` nie niesie geometrii.
- `FLOW` nie niesie pixel-passa.
- `RUNTIME` niczego nie "projektuje", tylko potwierdza lub blokuje.

## 5) Procedura wykonania taska
1. Koordynator nadaje `ID`, typ, ownera, trase i liste plikow.
2. Agent przed edycja czyta tylko dokumenty potrzebne do swojego typu:
   - `UI` -> `22`, ostatnie 2 bloki z `01`, odpowiedni template/CSS,
   - `I18N` -> `06`, `16`, locale/JSON dla trasy,
   - `FLOW` -> `09`, `16`, `03` i odpowiednie `system/pages/*.php`,
   - `RUNTIME` -> `06` + pliki runtime dotkniete przez patch.
3. Agent zapisuje scope w formacie roboczym:
   - task ID,
   - typ,
   - owner,
   - pliki repo,
   - pliki runtime,
   - trasy smoke,
   - kryterium PASS.
4. Zmiany wykonujemy najpierw w repo `canary_test/html_copy/`.
5. Runtime sync wolno robic dopiero po zamknieciu patcha repo.
6. Kazda zmiana przechodzi minimum:
   - lint/syntax dla dotknietego jezyka,
   - smoke trasy,
   - wpis do `01`.
7. Status w `00` aktualizujemy po wyniku, nie po samym patchu.
8. Jesli task zostal zablokowany, wpis musi zawierac:
   - dokladny plik lub trase,
   - czy blokada jest w repo, runtime, DB czy E2E,
   - co zostalo juz potwierdzone.

## 6) Twarde zasady dla WWW Tibia
1. Nie edytujemy jednoczesnie `basic.css`, locale i `system/pages/*.php` w ramach jednego niepodzielonego taska.
2. Nie robimy zmian CSS "na oko"; kazdy offset musi wynikac z `22_STANDARD_WPROWADZANIA_ZMIAN_TIBI_UI.md`.
3. Nie stawiamy `data-i18n` na kontenerach strukturalnych typu `CaptionContainer`, jesli moze to zniszczyc markup.
4. Nie traktujemy runtime `/var/www/html` jako jedynego miejsca prawdy.
5. Dla zadan dual-server zawsze sprawdzamy jawnie:
   - `mode=all`,
   - `mode=classic74`,
   - `mode=modern`.
6. Jesli runtime schema moze miec `world` albo `world_id`, fallback musi byc jawny i wpisany do dziennika.
7. Zmiany w menu legacy wymagaja uwzglednienia, ze czesc danych moze siedziec w `myaac_menu`, a nie tylko w plikach.
8. Dla tekstu w grafikach wybieramy jedna strategie na task:
   - asset per jezyk,
   - albo HTML/CSS zamiast grafiki.
   Nie mieszamy obu podejsc na jednej podstronie bez decyzji koordynatora.

## 7) Minimalny zestaw smoke testow
Dobieramy pod trase, ale ponizszy zestaw jest domyslny dla zmian WWW:

1. `php -l` dla kazdego zmienionego pliku PHP.
2. `node --check` dla zmienionego JS, jesli dotyczy.
3. `curl -sk` dla tras:
   - `/`,
   - `/index.php/highscores`,
   - `/index.php/online`,
   - `/account/login`,
   - `/account/manage`.
4. Dla i18n:
   - `?lang=pl`,
   - `?lang=en`.
5. Dla UI:
   - desktop 100%, 125%, 150% DPI lub zoom.
6. Dla flow dual-server:
   - `all`,
   - `classic74`,
   - `modern`.

## 8) Format handoff po tasku
Kazdy agent oddaje task w jednym, krotkim formacie:

```md
ID:
Typ:
Owner:
Repo:
Runtime:
E2E:
Zmienione pliki:
Smoke:
Blockery:
Nastepny krok:
```

Statusy:
- `Repo` -> `NOT STARTED | IN PROGRESS | CODE DONE`
- `Runtime` -> `NOT NEEDED | SYNCED | BLOCKED`
- `E2E` -> `NOT RUN | SMOKE PASS | FAIL | BLOCKED`

## 9) Kiedy task wraca do podzialu
Task wraca do koordynatora i jest rozbijany ponownie, gdy:
1. wymaga jednoczesnie zmian w lane `UI` i `FLOW`,
2. wymaga zmian w repo i recznego grzebania w runtime DB,
3. potrzebuje osobnej decyzji architektonicznej (`tibiacom` vs nowy frontend),
4. smoke test nie potwierdza, czy blad jest w repo, runtime czy cache,
5. agent nie umie wskazac jednego source-of-truth dla problemu.

## 10) Definition of Done dla zadania WWW
Task jest zamkniety dopiero gdy:
1. patch istnieje w repo,
2. runtime jest zsynchronizowany albo jawnie oznaczony `NOT NEEDED`,
3. smoke zostal wykonany na konkretnych trasach,
4. status jest wpisany do `00`,
5. przebieg i decyzje sa wpisane do `01`,
6. jesli task mial wplyw na backlog lub strategje, odpowiedni dokument tematyczny tez jest zaktualizowany.

## 11) Kolejnosc pracy od teraz
1. Najpierw klasyfikacja taska i owner.
2. Potem patch w repo.
3. Potem runtime sync.
4. Potem smoke.
5. Potem `00` + `01` + handoff.

To jest domyslny tryb pracy dla wszystkich kolejnych zmian WWW Tibia, dopoki nie powstanie nowy nadrzedny standard.
