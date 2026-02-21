# Naprawa Windows Build — MSVC toolset 14.29 fallback

**Data:** 2026-02-17  
**Commit:** `51c003a0a` — `fix(ci): remove MSVC 14.44 toolset filter`  
**Dotyczy:** OTClient — Build Windows (Release) workflow na GitHub Actions  

## Problem

Build Windows (#4365, #4366, #4367) failował z błędem:
```
fatal error C1189: #error: "You need Visual Studio 2022(17.2) or greater to compile."
```

Plik `compiler.h` linia 39 sprawdza `#if _MSC_VER < 1932`.

## Przyczyna

Krok "Select MSVC toolset" w workflow miał filtr:
```powershell
$selected = $toolsets | Where-Object { $_ -notmatch '^14\.44\.' } | Select-Object -First 1
```

Celem było uniknięcie buga ICE C1001 w toolsecie 14.44. Problem polega na tym, że **GitHub zaktualizowali obraz `windows-2022` runnera** i usunęli pośrednie toolsety (14.38, 14.42, 14.43).

Na runnerze zostały tylko 2 toolsety:
- `14.44.35207` (MSVC 2022 17.12, `_MSC_VER = 1944`) — **WYFILTROWANY**
- `14.29.30133` (VS2019 compat, `_MSC_VER = 1929`) — **WYBRANY**

`_MSC_VER 1929 < 1932` → #error w compiler.h.

## Naprawa

Usunięto filtr na 14.44. Projekt już ma obejście na ICE C1001 — IPO/LTCG jest wyłączone w CMakeLists.txt, więc toolset 14.44 jest bezpieczny.

Dodano logowanie dostępnych toolsetów:
```powershell
Write-Host "Selected MSVC toolset: $selected (available: $($toolsets -join ', '))"
```

## Zmienione pliki

| Plik | Zmiana |
|---|---|
| `.github/workflows/build-windows.yml` | Usunięcie filtru `'^14\.44\.'`, dodanie komentarzy wyjaśniających |

## Rezultat

Build Windows powinien teraz używać toolsetu 14.44.35207 (`_MSC_VER = 1944`), co przejdzie check w `compiler.h`.

## Dodatkowa informacja

Build jest `workflow_dispatch` (ręczne uruchomienie). Po pushu trzeba ręcznie uruchomić workflow "Build - Windows" na GitHubie.

## Aktualizacja 2026-02-21

1. Stan workflow potwierdzony:  
   - aktywny plik: `/home/ptaku/serweryt/.github/workflows/build-windows.yml`
   - wybór toolsetu: najnowszy dostępny (`Select-Object -First 1`)
2. W pliku workflow jest niespójny komentarz historyczny w kroku `Configure CMake` ("already skips 14.44"), który nie odpowiada aktualnemu kodowi.
3. Pełny audyt techniczny (UI i CI):  
   - `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_audyt_i18n_layout_ci_linux_windows.md`
