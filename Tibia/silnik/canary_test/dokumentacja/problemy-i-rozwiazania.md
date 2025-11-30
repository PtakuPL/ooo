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
