# 2026-05-02 - build-client-package: poprawka sciezki binarki

## Problem
Workflow `build-client-package` na `feature/ticket-gate` padal w kroku `Assemble client package` dla Windows i Linux.

Logi GitHub Actions pokazaly, ze CMake/Ninja linkuje binarki do katalogu klienta:

- Windows: `Tibia/silnik/canary_test/testyy/otclient.exe`
- Linux: `Tibia/silnik/canary_test/testyy/otclient`

Natomiast packaging szukal ich tylko pod `build/otclient.exe`, `build/Release/otclient.exe`, `build/RelWithDebInfo/otclient.exe` oraz `build/otclient`.

## Zmiana
W `.github/workflows/build-client-package.yml` dodano fallback wyboru binarki:

- Windows: `otclient.exe`, potem warianty pod `build/`.
- Linux: `otclient`, potem warianty pod `build/`.

Jesli binarka nadal nie zostanie znaleziona, workflow wypisze diagnostyczne `find`, zeby nastepny blad byl czytelniejszy.

Po tej poprawce GHA doszlo dalej i padlo w `Verify package integrity` na braku fallbackow Unicode w `data/fonts/mono-12.otfont`. Do commita dolaczono pelne fallbacki wymagane przez `tools/verify-player-package.sh` dla wszystkich TTF `.otfont` w `data/fonts`.

## Walidacja lokalna
- Pobrano logi runa `25252716772` przez GitHub API.
- Potwierdzono, ze oba joby padly na `Assemble client package` przez brak binarki w oczekiwanej sciezce.
- Uruchomiono `git diff --check` dla workflowa.
- Zasymulowano shellowy wybor binarki dla Windows i Linux bez lokalnej kompilacji.
- VS Code diagnostics nie pokazaly bledow w workflowie.
- Po drugim runie `25255731139` potwierdzono, ze `Assemble client package` przechodzi na Windows i Linux, a nastepna blokada dotyczyla juz font fallbackow.
- Skryptowo sprawdzono, ze kazdy TTF `.otfont` ma fallbacki wymagane przez `verify-player-package.sh`.

## Uwagi
Nie instalowano lokalnie zadnych toolchainow ani narzedzi buildowych. Pelna weryfikacja kompilacji nadal odbywa sie przez GitHub Actions.
