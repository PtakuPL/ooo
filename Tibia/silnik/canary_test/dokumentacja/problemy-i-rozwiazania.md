# Problemy i rozwiązania

Zbiór najważniejszych problemów napotkanych podczas rozwoju projektu oraz sposobów ich rozwiązania.

## 1. Duże pliki binarne w repozytorium

**Problem:**
- pliki wykonywalne (`canary`, `canary-debug`) oraz dane klienta przekraczały limity GitHuba,
- push do zdalnego repozytorium kończył się błędami związanymi z rozmiarem.

**Rozwiązanie:**
- użycie `git filter-repo` do usunięcia dużych plików z historii,
- trzymanie dużych danych w archiwach `.zip` podzielonych na części (~40MB),
- ignorowanie artefaktów buildu w `.gitignore`.

(Szczegóły operacji znajdują się w logach: `../testyy/worklog_all.md`.)

## 2. Konflikt submodułu / osadzonego repozytorium w `testyy/`

**Problem:**
- katalog `testyy/` zawierał własne `.git`, co powodowało konflikt z głównym repozytorium.

**Rozwiązanie:**
- usunięcie `.git` z `testyy/`,
- dodanie `testyy/` jako zwykłego katalogu,
- dostosowanie `.gitignore` do nowej struktury.

## 3. GitHub Actions – błędy builda Windows

**Problem:**
- początkowo workflow nie miał wszystkich potrzebnych plików, co powodowało błędy,
- później pojawiały się problemy z konfiguracją zależności / ścieżek.

**Rozwiązanie:**
- skorzystanie ze wzorca workflow z oryginalnego `opentibiabr/canary`,
- dodanie brakujących plików i dostosowanie ścieżek,
- dokumentacja błędów i poprawek w `../testyy/errory-actions.md` oraz `../testyy/docs/build-status.md`.

## 4. Organizacja dokumentacji i planów

**Problem:**
- notatki były rozproszone po wielu plikach w `testyy/`, co utrudniało ogólny obraz.

**Rozwiązanie:**
- utworzenie katalogu `dokumentacja/` jako centralnego miejsca opisów,
- pozostawienie oryginalnych plików (`plan.md`, logi, I18N_*) w `testyy/` jako źródło prawdy,
- stworzenie dokumentów podsumowujących (ten plik, ogólny opis modyfikacji, plany na przyszłość).

## 5. Potencjalne przyszłe problemy (do monitorowania)

- dalszy wzrost danych (mapy, assety klienta) – konieczność ciągłej kontroli wielkości repo,
- utrzymanie spójności między wersjami serwera a klienta,
- ewentualne zmiany w API/systemie budowania na platformach CI.

Te punkty można rozwijać w miarę pojawiania się kolejnych doświadczeń.

## 6. GitHub Actions - Duplikaty i błędy składni YAML w workflow (01.12.2025)

**Problem:**
- Pliki workflow zawierały duplikaty sekcji `name:` i innych kluczy YAML
- Python commands używały niepoprawnego heredoc syntax, który był zbyt długi i ucinany
- CMake 4.2.0 w GitHub Actions wymaga minimum CMake 3.5, a niektóre porty vcpkg miały starsze wersje
- Błędy kompilacji związane z `CMake Error: Compatibility with CMake < 3.5 has been removed`
- Ścieżki w cache używały `$HOME` zamiast `~`, co mogło powodować problemy

**Rozwiązanie:**
- Usunięto wszystkie duplikaty sekcji w plikach:
  - `.github/workflows/build-linux.yml`
  - `.github/workflows/build-windows.yml`
  - `.github/workflows/analysis-sonarcloud.yml`
- Zamieniono Python heredoc na prostsze wywołanie: `python3 -c "import json; print(json.load(open('vcpkg.json')).get('builtin-baseline',''))"`
- Dodano wymuszenie CMake 3.27.0 w akcji `lukka/get-cmake@latest` poprzez parametr `cmakeVersion: '~3.27.0'`
- Poprawiono ścieżki cache z `$HOME/.ccache` na `~/.ccache`
- Ujednolicono format ścieżek w artifact upload (dodano pełne ścieżki z working-directory)
- Commit: `979c22988` - "Fix GitHub Actions workflows: remove duplicates, fix Python commands, add CMake 3.27 constraint"

**Status:** Zmiany wypushowane na branch master, oczekujemy na wynik kompilacji w GitHub Actions.

**Dodatkowe notatki:**
- Błędy kompilacji udokumentowane w `testyy/bledykompilacji.md`
- Główny problem dotyczył pakietu `brotli` w vcpkg, który wymagał CMake 3.5+
