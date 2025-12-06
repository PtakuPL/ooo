# Historia projektu (skrót)

Ten dokument streszcza historię prac nad projektem, opierając się na:
- `../testyy/worklog_all.md`
- `../testyy/WszystkieSRCLOG.md`
- `../testyy/wykonane_zadania.md`
- commitach w gałęzi `windows-build-clean`.

## 1. Początek

- Bazą był serwer Canary 14.x (`opentibiabr/canary`).
- Do repozytorium dołączono zmodyfikowanego otclienta (katalog `testyy/`) z obsługą TTF/i18n.

## 2. Problemy z dużymi plikami i historią

- Do repozytorium trafiły duże binaria (`canary`, `canary-debug`, pliki klienta), co uniemożliwiało push na GitHub (limit rozmiaru).
- Rozwiązanie:
  - użycie `git filter-repo` w celu usunięcia dużych plików z historii,
  - przeniesienie dużych danych do archiwów `.zip` podzielonych na ~40MB części.

## 3. Przygotowanie gałęzi `windows-build-clean`

- utworzono czystą gałąź z usuniętymi dużymi plikami z historii,
- skonfigurowano workflow GitHub Actions do budowy Windows,
- dodano skrypty i pliki ułatwiające build:
  - `BUILD_WINDOWS.md`
  - `build_windows.bat`

## 4. Integracja katalogu `testyy/`

- usunięto osadzone `.git` w `testyy/` (pierwotnie submoduł/fork),
- dodano `testyy/` jako zwykły katalog z plikami klienta i dokumentacją,
- dopasowano `.gitignore`, aby ignorować niepotrzebne artefakty.

## 5. Dodanie dużych danych klienta

- dodano nowe pliki w `testyy/data/...`, zbyt duże do trzymania bezpośrednio,
- rozwiązanie: spakowanie do archiwów i podział na części,
- zanotowano strukturę i sposób odtworzenia danych w logach.

## 6. Dalsze prace nad TTF/i18n

- rozwój funkcji TTF i internacjonalizacji udokumentowany w:
  - `../testyy/I18N_Progress.md`
  - `../testyy/I18N_Next_Steps.md`.

Ten dokument można rozwijać o dokładne daty i numery commitów, jeśli będzie taka potrzeba.
