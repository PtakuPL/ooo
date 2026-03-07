# J7 — Rozdział instalek: dev vs gracze/prod

**Data:** 2026-03-05  
**Cel:** rozdzielić środowisko deweloperskie od paczki dla graczy, aby testy i rollout były powtarzalne.

## 1. Zakres rozdziału

| Obszar | Instalka dev | Instalka graczy/prod |
|---|---|---|
| Przeznaczenie | debug i szybkie iteracje | dystrybucja dla graczy |
| Źródło paczki | artefakty robocze / kanał `dev` | czysty artefakt GHA release / kanał `stable` |
| API base URL | dev/staging API | produkcyjne API |
| Kanał launchera | `dev` | `stable` |
| Katalog klienta | oddzielny (`client-dev`) | oddzielny (`client`) |
| launcher_data_dir | oddzielny (`launcher-data-dev`) | oddzielny (`launcher-data`) |
| Manifest | wersje testowe, częste bump | wersje release, kontrolowany bump |
| Kryterium akceptacji | smoke/regresja techniczna | D1..D9 + test paczki usera |

## 2. Minimalna konfiguracja (target)

### 2.1 Dev
```json
{
  "channel": "dev",
  "clientDir": "client-dev",
  "launcherDataDir": "launcher-data-dev"
}
```

### 2.2 Gracze/prod
```json
{
  "channel": "stable",
  "clientDir": "client",
  "launcherDataDir": "launcher-data"
}
```

## 3. Zasady operacyjne

1. Paczka graczy jest jedynym źródłem prawdy dla testów akceptacyjnych.
2. Dev i prod nie współdzielą katalogu klienta ani katalogu danych launchera.
3. Rollout na graczy idzie tylko przez `stable` + manifest release.
4. Self-update launchera testujemy osobno na dev i osobno na paczce graczy.

## 4. Checklist wdrożeniowy J7

| ID | Zadanie | Status |
|---|---|---|
| J7.1 | Dodać/zweryfikować dwa profile `launcher_config.json` (dev, stable) | ⬜ |
| J7.2 | Potwierdzić separację katalogów (`client-dev` vs `client`) | ⬜ |
| J7.3 | Ustawić osobne endpointy manifestu dev/stable | ⬜ |
| J7.4 | Smoke test dev (check/update/repair) | ⬜ |
| J7.5 | Smoke test paczki graczy (check/update/repair) | ⬜ |
| J7.6 | Dopisać wyniki do `2026-03-05_dual_mode_test_results_J4.md` | ⬜ |

## 5. Otwarte ryzyka

1. Przypadkowe uruchomienie dev na danych stable (lub odwrotnie).
2. Nadpisanie paczki graczy artefaktem deweloperskim.
3. Mylące wersjonowanie manifestu między kanałami.
