# Checklista Publikacji Paczki Gracza (Release Readiness)

Data: 2026-03-06
Zakres: K108

## 1. Przed publikacja (must pass)
1. Artefakt paczki ma poprawna wersje i channel.
2. `launcher_config.json` jest zgodny ze schema i profilem runtime.
3. Endpointy krytyczne odpowiadaja: `launcher-version`, `update`, `login`, `account-context`.
4. Manifest ma poprawne `minLauncherVersion`, hash i (jezeli wlaczone) podpis.
5. Brak plikow dev/test/debug/sekretow w paczce.
6. Wszystkie artefakty maja `sha256` i `size`.
7. Lock single-instance i preflight zasobow sa aktywne.
8. Anti-tamper flow jest aktywny (kwarantanna + redownload).

## 2. Go/No-Go
1. GO tylko gdy wszystkie punkty z sekcji 1 sa PASS.
2. NO-GO gdy wystepuje jakikolwiek CRITICAL z mapy `LCH_*`.
3. NO-GO gdy brak mozliwosci rollbacku channel/self-update.

## 3. Publikacja
1. Upload artefaktow do bazy/CDN.
2. Publikacja metadanych `installer-catalog` z hashami i rozmiarami.
3. Aktualizacja `launcher-version` (wersja, minVersion, required).
4. Potwierdzenie, ze URL-e sa HTTPS dla profile non-dev.

## 4. Post-publish smoke (bez kompilacji lokalnej)
1. Launcher pobiera nowa wersje statusu.
2. Self-update launchera przechodzi verify SHA.
3. Update klienta przechodzi verify i finalizacje.
4. Start klienta dziala po preflight.

## 5. Rollback readiness
1. Dostepny poprzedni artefakt launchera.
2. Dostepny poprzedni manifest.
3. Runbook rollback aktualny i dostepny zespolowi.
