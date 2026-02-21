# Workflows cleanup (2025-12-12)

## Cel
Zostawić tylko workflow budowania Canary w GitHub Actions, żeby nie uruchamiały się inne joby.

## Co zrobiłem
- Wykonałem backup całego katalogu `.github/workflows/` do:
  - `/home/ptaku/serweryt/Dokumentacja/workflows_backup_20251212_043104`
  - (wcześniejsza próba backupu również istnieje: `/home/ptaku/serweryt/Dokumentacja/workflows_backup_20251212_043049`)
- Usunąłem lokalnie wszystkie inne pliki z `.github/workflows/`.

## Stan repo (git)
- Na gałęzi `master` git śledzi tylko:
  - `.github/workflows/build-canary-ubuntu.yml`
  - `.github/workflows/build-canary-linux.yml`
- `git status` jest czysty (brak zmian do wypchnięcia).
