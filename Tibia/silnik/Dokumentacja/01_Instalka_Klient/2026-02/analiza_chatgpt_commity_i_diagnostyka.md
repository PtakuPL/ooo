# Analiza commitów w repozytorium PtakuPL/ooo w oknie 17:00–18:00 oraz diagnostyka awarii buildów Windows

> **Źródło:** Analiza wykonana przez ChatGPT  
> **Data zapisu:** 2026-02-21  
> **Kontekst:** Dokumentacja diagnostyczna dla projektu OTC Client - kompilacja Windows

## Streszczenie wykonawcze

W badanym kontekście mamy dwa równoległe problemy, które trzeba rozdzielić i spiąć jedną procedurą diagnostyczną: (a) wytypowanie „podejrzanych" commitów (w tym zawężenie do zmian w `.cpp`) w zadanym oknie czasu 17:00–18:00 oraz/lub między gałęziami (np. `master` vs. `serwer 7.4`), oraz (b) uzyskanie i analiza logów buildów Windows (CI + lokalnie), tak aby jednoznacznie przypisać błąd kompilacji/linkowania do konkretnego pliku i zmiany. Git daje do tego komplet narzędzi: filtrowanie historii po czasie (`--since/--until`), porównanie zakresów (diffy, `merge-base`, `range-diff`) i binarną bisekcję regresji (`git bisect`).

W repozytorium znalazłem przykład commitu w analizowanym oknie czasu (wariant: 17:00–18:00 UTC w dniu 2024‑12‑28), który **modyfikuje plik `.cpp`**: `src/ccon2017/logged reasons/ItemA.cpp`. Zmiana dotyczy wywołań `Condition.AddCondition(...)` – liczba argumentów i semantyka wywołania uległa zmianie (dodanie `this` jako pierwszego argumentu), co jest typowym miejscem, gdzie na Windows mogą pojawić się błędy w stylu **C2660/C2664** (niedopasowanie przeciążeń) lub, jeśli zmiany są niespójne między modułami, także **LNK2019/LNK2001** (brak definicji/ODR).

Najkrótsza ścieżka do diagnozy (największa wartość za najmniejszy koszt) to:  
1) wygenerować listę commitów w oknie czasu i od razu odfiltrować te, które dotykają `.cpp`, 2) dla tych commitów pobrać logi Windows z CI (np. przez `gh run view --log-failed` i artefakty), 3) zautomatyzować ekstrakcję błędów (MSVC: `C####`, `LNK####`, `fatal error`, MSBuild: `MSB####`; MinGW/Clang: „error:", „undefined reference"), 4) uruchomić `git bisect run` z minimalnym testem „czy Windows build przechodzi".

Kluczowe ryzyka specyficzne dla „language-aware text-field matching" to: zależność od lokalizacji/kolacji (inne wyniki na Windows vs Linux), osadzenie znaków spoza ASCII w źródłach i wynikające z tego pułapki kodowania (UTF‑8/UTF‑16, codepage), użycie bibliotek i18n (ICU/Boost.Locale) w sposób powodujący lawinę instancjacji szablonów, ODR i/lub różnice linkowania. Źródła oficjalne MSVC jednoznacznie opisują, że bez jawnego ustawienia zestawów znaków kompilator może przyjąć bieżącą stronę kodową użytkownika, co potrafi zepsuć kompilację/konwersje literałów na Windows.

## Zakres i założenia

Okno czasu 17:00–18:00 podałeś bez daty i bez strefy czasowej. W Git/CI to nie jest detal: commit ma **timestamp + offset**, a CI może raportować czasy w UTC. Dlatego w raporcie podaję strategie, które działają niezależnie od tego, czy docelowo filtrujesz w czasie lokalnym (Europe/Warsaw), czy w UTC: (1) filtrowanie po dacie+godzinie w `git log`, oraz (2) filtrowanie po metadanych runów w CI przez GitHub CLI.

Nie znam też Twojego toolchainu/buildu (MSVC vs clang-cl vs MinGW; MSBuild vs CMake/Ninja; GitHub Actions vs inny CI). W związku z tym w każdej części podaję warianty równoległe i punkty rozgałęzienia: jak zebrać logi i jak wyciągnąć diagnostykę niezależnie od narzędzi. Dla MSBuild/CMake podaję mechanizmy „źródła prawdy": **MSBuild binlog** i/lub `compile_commands.json`.

## Analiza commitów i strategie porównania

### Filtrowanie commitów w oknie 17:00–18:00

Do filtrowania po czasie używaj zawsze **pełnego datowania** (dzień + godzina) oraz jawnej strefy (np. `Z` dla UTC albo `+01:00/+02:00`), inaczej wyniki będą zależały od ustawień maszyny uruchamiającej polecenia.

Przykładowe polecenia (warianty):

**Git (lokalnie):**
```bash
# wariant UTC (Z) – najbezpieczniejszy do korelacji z CI
git log --since="2024-12-28 17:00:00 +0000" --until="2024-12-28 18:00:00 +0000" \
  --pretty=format:'%H %ad %an %s' --date=iso-strict

# wariant „lokalny" (np. Europe/Warsaw) – ustawiasz TZ tylko na to polecenie
TZ=Europe/Warsaw git log --since="2026-02-20 17:00:00" --until="2026-02-20 18:00:00" \
  --pretty=format:'%H %ad %an %s' --date=iso-strict
```

Następnie natychmiast zawężasz do plików `.cpp`:

```bash
# Tylko commity, które dotykają *.cpp w danym oknie
git log --since="2024-12-28 17:00:00 +0000" --until="2024-12-28 18:00:00 +0000" \
  --name-only --pretty=format:'--- %H %ad %s' --date=iso-strict -- '*.cpp'
```

### Porównanie gałęzi `master` vs `serwer 7.4`

```bash
git fetch --all --prune

MB=$(git merge-base master "serwer 7.4")
echo "merge-base=$MB"

# Co jest na master, a nie ma na serwer 7.4 (same commity)
git log --oneline --no-decorate "$MB..master"

# Co jest w kodzie (diff) – tylko C/C++
git diff --stat "$MB..master" -- '*.cpp' '*.hpp' '*.h'
git diff --name-only "$MB..master" -- '*.cpp'
```

### Strategie diffów: szybkie „zgrubne", potem „chirurgiczne"

**Poziom A – co się zmieniło i gdzie (dla triage):**
```bash
git diff --stat "$MB..master" -- '*.cpp' '*.hpp'
git diff --name-status "$MB..master" -- '*.cpp' '*.hpp'
```

**Poziom B – dokładny diff:**
```bash
git diff -U5 "$MB..master" -- '*.cpp' '*.hpp'
```

**Poziom C – wyszukiwanie „punktów zapalnych" (pickaxe):**
```bash
git log -S'boost::locale' --oneline -- '*.cpp' '*.hpp'
git log -S'setlocale' --oneline -- '*.cpp' '*.hpp'
```

## Pozyskanie i analiza logów buildów Windows

### GitHub CLI

```bash
gh run list -R PtakuPL/ooo --commit <SHA> --json databaseId,status,conclusion,createdAt,headSha,headBranch,workflowName -L 20
gh run view -R PtakuPL/ooo <RUN_ID> --log-failed
gh run download -R PtakuPL/ooo <RUN_ID> --dir artifacts
```

### CMake/Ninja: `compile_commands.json`

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

### Parsowanie logów: wzorce dla MSVC

**MSVC (cl.exe)** typowo raportuje:
- `ścieżka\plik.cpp(linia[,kolumna]): error C####: ...`
- `...: fatal error C####: ...`
- link: `error LNK####: ...`
- MSBuild: `error MSB####: ...`

## Hipotezy regresji i checklista Windows/C++

### Kodowanie: UTF‑8 vs UTF‑16, literały, codepage

- `/utf-8` ustawia zarówno source, jak i execution charset na UTF‑8
- Przy braku BOM i braku jawnych opcji, Visual Studio może przyjąć bieżącą stronę kodową

### Flagi diagnostyczne MSVC

- `/diagnostics:caret` – pokazuje kolumnę i caret
- `/permissive-` – tryb większej zgodności ze standardem
- `/utf-8` – stabilizacja czytania źródeł i literałów
- `/FS` – gdy równoległe buildy walczą o PDB
- `/showIncludes` – debugging kolejności include'ów

### Linker

- `/VERBOSE:LIB` – mapuje rozwiązywanie symboli i ścieżki bibliotek

### Tabela przyczyn

| Potencjalna przyczyna | Prawdop. | Typowe symptomy (Windows) | Diagnostyka | Remediacja |
|---|---:|---|---|---|
| Niespójna zmiana sygnatury/overload | Wysokie | C2660/C2664, LNK2019 | `git diff` + `/diagnostics:caret` | Ujednolicić deklaracje/definicje |
| Błędy kodowania źródła / literałów | Wysokie | C4566, niespodziewane błędy parsowania | `/utf-8`, `/source-charset:utf-8` | Ujednolicić encoding repo |
| Równoległa kompilacja walczy o PDB | Średnie | fatal error PDB, C1041 | `/FS` | Włączyć `/FS` |
| Brak/inna wersja bibliotek i18n | Średnie | LNK2019/LNK2001 | `/VERBOSE:LIB` | Dopiąć zależności |
| Regresja w CI (workflow/akcje) | Średnie | Fail w kroku upload/download | Sprawdzić workflow YAML | Migracja do v4 |

### `git bisect run`: minimalny „test builda"

```bash
git bisect start
git bisect bad master
git bisect good "serwer 7.4"

cat > bisect_build.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
exit 0
EOF
chmod +x bisect_build.sh

git bisect run ./bisect_build.sh
```
