# Procedura debugowania błędów kompilacji na GitHub Actions
**Data**: 2026-02-17  
**Status**: Obowiązujący  

---

## 1. Szybka diagnostyka — 5 kroków

### Krok 1: Znajdź failed run
```bash
# Lista ostatnich buildów Windows (lub Linux/WASM/Android)
gh api "repos/PtakuPL/ooo/actions/workflows/211701257/runs?per_page=10" \
  --jq '.workflow_runs[] | {id, created: .created_at, conclusion, head_sha: .head_sha[:12]}'
```

### Krok 2: Pobierz logi
```bash
# Znajdź job ID
gh api "repos/PtakuPL/ooo/actions/runs/XXXXXXXXX/jobs" \
  --jq '.jobs[] | {id, name, conclusion}'

# Pobierz logi
gh api "repos/PtakuPL/ooo/actions/jobs/YYYYYYYYYY/logs" > /tmp/build_failed.log
wc -l /tmp/build_failed.log
```

### Krok 3: Znajdź błędy
```bash
# Szukaj error/FAILED
grep -n 'error:\|FAILED:\|fatal:\|undefined symbol' /tmp/build_failed.log | grep -v warning

# Kontekst błędu (±10 linii)
grep -n 'FAILED:' /tmp/build_failed.log   # weź numer linii
sed -n 'NUMER-10,NUMER+10p' /tmp/build_failed.log
```

### Krok 4: Porównaj z ostatnim udanym buildem
```bash
# Znajdź ostatni udany build tego samego workflow
gh api "repos/PtakuPL/ooo/actions/workflows/211701257/runs?per_page=30" \
  --jq '.workflow_runs[] | select(.conclusion == "success") | {id, created: .created_at, head_sha: .head_sha[:12]}' | head -5

# Pobierz jego logi też
gh api "repos/PtakuPL/ooo/actions/jobs/ZZZZZZZZZZ/logs" > /tmp/build_success.log
```

### Krok 5: Porównaj konfigurację cmake
```bash
# Porównaj cmake config
echo "=== SUCCESS ===" && grep 'cmake -G' -A10 /tmp/build_success.log
echo "=== FAILED ===" && grep 'cmake -G' -A10 /tmp/build_failed.log

# Porównaj kompilatory
grep 'compiler identification' /tmp/build_success.log
grep 'compiler identification' /tmp/build_failed.log

# Porównaj triplet
grep 'VCPKG_DEFAULT_TRIPLET' /tmp/build_success.log | head -1
grep 'VCPKG_DEFAULT_TRIPLET' /tmp/build_failed.log | head -1
```

---

## 2. Częste przyczyny awarii

### 2.1 Zmiana kompilatora (MSVC vs clang-cl)
**Objaw**: `lld-link: error: undefined symbol: __declspec(dllimport) ...`  
**Przyczyna**: vcpkg buduje biblioteki z MSVC, a nasz kod z clang-cl. Dekoracja symboli DLL się nie zgadza.  
**Fix**: Nie mieszaj kompilatorów. Jeśli vcpkg używa MSVC, nasz kod też musi być MSVC.  
**Przykład**: Commit `bcf4906aa718` dodał `-DCMAKE_C_COMPILER=clang-cl` → zrevertowane w `57ebac85a`.

### 2.2 Niezgodność triplet (static vs dynamic)
**Objaw**: `undefined symbol` na symbolach bibliotek  
**Przyczyna**: `VCPKG_DEFAULT_TRIPLET=x64-windows` (DLL) vs `-DVCPKG_TARGET_TRIPLET=x64-windows-static`  
**Fix**: Upewnij się że CMakeLists.txt, workflow i vcpkg.json używają tego samego triplet.  
**Sprawdzanie**: 
```bash
grep 'TRIPLET' /tmp/build.log | head -5   # czego użyto
grep 'protobuf:x64-windows' /tmp/build.log  # jak vcpkg zbudował
```

### 2.3 MSVC ICE C1001 (Internal Compiler Error)
**Objaw**: `fatal error C1001: Internal compiler error` w fazie P2 (codegen)  
**Przyczyna**: Bug w MSVC 14.44.x  
**Fix**: Step "Select MSVC toolset" w workflow pomija 14.44 i wybiera starszą wersję.  
**NIE FIX**: Zmiana na clang-cl — to powoduje problem 2.1.

### 2.4 Brakujący case w switch
**Objaw**: `-Wswitch` warning → error z `-Werror`  
**Fix**: Dodaj brakujący `case X: break;`

### 2.5 Nieużywane zmienne  
**Objaw**: `-Wunused-variable` warning  
**Fix**: Usuń zmienną lub dodaj `(void)zmienna;`

---

## 3. Workflow IDs (szybki dostęp)

| Workflow | ID | Plik | Trigger |
|---|---|---|---|
| Build - Windows | 211701257 | build-windows.yml | workflow_dispatch |
| Build - Linux | 211701256 | build-linux.yml | push (src/**) |
| Build - Android | 211716124 | build-android.yml | workflow_dispatch |
| Build - WASM | 231874161 | build-wasm.yml | workflow_dispatch |
| Canary - Build | 231874122 | build-canary.yml | workflow_dispatch |
| SonarCloud Windows | 213154351 | analysis-sonarcloud-windows.yml | push |

---

## 4. Checklist PRZED pushowaniem zmian w workflow

1. [ ] Nie zmieniaj kompilatora (MSVC → clang-cl) bez testowania linkowania
2. [ ] Jeśli zmieniasz triplet — zmień też w CMakeLists.txt `BUILD_STATIC_LIBRARY`
3. [ ] Nie dodawaj `-DOPTIONS_ENABLE_SCCACHE=ON` z clang-cl (ccache/sccache wrapper zmienia compiler path)
4. [ ] Sprawdź czy `VCPKG_DEFAULT_TRIPLET` w env pasuje do `-DVCPKG_TARGET_TRIPLET` w cmake
5. [ ] Porównaj z ostatnim udanym buildem: `diff <(workflow@success_sha) <(workflow@current_sha)`

---

## 5. Checklist PRZED pushowaniem zmian w C++ (.cpp/.h)

1. [ ] Skompiluj lokalnie (Linux): `cd budowa_silnik && cmake .. && make -j$(nproc)`
2. [ ] Sprawdź warningi: `make 2>&1 | grep -i warning`
3. [ ] Jeśli dodajesz nowy `case` w enum switch — dodaj WSZYSTKIE brakujące case'y
4. [ ] Jeśli usuwasz zmienną — upewnij się że nie jest używana dalej (w callLuaField, callback, itp.)
5. [ ] Po push — monitoruj Actions: `gh run list --workflow=build-linux.yml --limit 3`

---

## 6. Historia napraw

| Data | Problem | Przyczyna | Fix | Commit |
|---|---|---|---|---|
| 2026-02-17 | Windows linker error (protobuf dllimport) | clang-cl zamiast MSVC | Revert do MSVC cl.exe | `57ebac85a` |
| 2026-02-17 | Linux 30+ warnings | Unused vars, missing switch cases | Poprawki w 10 plikach | `322727516` |
