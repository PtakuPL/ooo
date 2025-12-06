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
- ewentualne zmiany w API/systemie budowania na platformach CI.n

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

## 7. vcpkg build Windows - MSYS2 mirror 404 (01.12.2025)

**Problem:**
- Po naprawieniu Zone.Identifier, build Windows kończy się błędem podczas instalacji vcpkg dependencies
- Konkretnie: `abseil:x64-windows-static` nie może pobrać `mingw-w64-i686-libwinpthread-git-9.0.0.6373.5be8fcd83-1-any.pkg.tar.zst`
- Wszystkie mirrory MSYS2 zwracają HTTP 404
- Błąd: `Failed to download file with error: 1`
- To zewnętrzny problem - plik został usunięty/przeniesiony w repozytoriach MSYS2

**Temporary Status:**
- Build Linux działa poprawnie (nie wymaga MSYS2)
- Build Windows zablokowany przez brak dostępu do pakietu MSYS2
- Problem nie jest po naszej stronie - to infrastruktura upstream

**Możliwe rozwiązania:**
1. Poczekać aż MSYS2 naprawi swoje repozytoria
2. Użyć starszej wersji vcpkg baseline (przed zmianą tej zależności)
3. Tymczasowo wyłączyć workflow build-windows
4. Dodać custom vcpkg overlay z patchowanym abseil

**Link do błędu:**
- Nie można pobrać: `mingw-w64-i686-libwinpthread-git-9.0.0.6373.5be8fcd83-1`
- Próbowano wszystkich mirrorów: repo.msys2.org, futureware.at, yandex.ru, tsinghua, ustc, bit.edu.cn, selfnet.de, sjtug

**Status:** Oczekujemy na naprawę upstream lub rozważamy workaround.

## 8. vcpkg manifest – brak wersji portów (Windows, 2025-12-06)

**Problem:** Przy commitcie vcpkg `5b121431` manifest wskazuje na porty/wersje, których nie ma w bazie (`abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0`). `run-vcpkg` kończy się błędem „no version database entry”.

**Rozwiązanie:**
- zaktualizować `builtin-baseline` w `vcpkg.json` lub `vcpkgGitCommitId` w workflow do wersji zawierającej te porty; **lub**
- obniżyć wersje portów do dostępnych (np. `abseil@20230125.0`, `angle@chromium_5414`, `asio@1.24.0`).

**Uwagi:** Po zmianie baseline/wersji wykonać `vcpkg format-manifest` i ponowić build Windows.

## 9. Konflikt typu `g_asyncDispatcher` (Linux/Windows, 2025-12-06)

**Problem:** `asyncdispatcher.h` deklaruje `extern BS::thread_pool g_asyncDispatcher;` (domyślnie `BS::thread_pool<0>`), a `asyncdispatcher.cpp` definiuje obiekt bez parametru szablonu, co powoduje błąd „conflicting declaration”.

**Rozwiązanie:**
- wprowadzić alias typu (np. `using AsyncPool = BS::thread_pool<>;`),
- użyć aliasu w deklaracji i w definicji (jedna definicja w `.cpp`),
- upewnić się, że nagłówki nie tworzą inline-definicji globalnego obiektu.

**Efekt oczekiwany:** Kompilacja `asyncdispatcher.cpp` przechodzi na Linux/Windows; SonarCloud nie zgłasza konfliktu definicji.
