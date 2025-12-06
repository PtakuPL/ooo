# 📋 Plan Działań - Naprawa Wykrytych Problemów

## Status: ✅ CZĘŚĆ NAPRAW WYKONANA

Na podstawie raportów z 6 warstw analizy, wykonano naprawy.

---

## 🔴 Priorytety wysokie (do naprawy automatycznie)

### 1. Warstwa 4 - Printf-style formatowanie

**Problem:** 2 miejsca używają starego formatowania printf zamiast fmt

| Plik | Linia | Status | Opis |
|------|-------|--------|------|
| src/framework/core/logger.cpp | 76 | ✅ OK | Android log - wymaga printf dla __android_log_print |
| src/framework/stdext/string.h | 38 | ✅ OK | Funkcja date_time_string - tylko deklaracja |

**Wynik:** Te przypadki są poprawne - Android API wymaga printf, a string.h to tylko deklaracja funkcji.

### 2. Warstwa 4 - Niebezpieczne wzorce (strcpy)

**Problem:** 2 miejsca używają strcpy

| Plik | Linia | Status | Opis |
|------|-------|--------|------|
| src/framework/platform/win32crashhandler.cpp | 118 | ✅ NAPRAWIONE | Zamieniono na strncpy z null-termination |
| src/framework/net/httplogin.cpp | 149 | ✅ NAPRAWIONE | Zamieniono na strncpy z sizeof() |

---

## 🟡 Priorytety średnie (wymagają ostrożności)

### 3. Warstwa 1 - Brakujące klucze tr() w locale PL

**Problem:** 14 kluczy używanych w tr() nie istnieje w pl.lua

| Klucz | Status |
|-------|--------|
| (Frozen) | ✅ DODANE |
| Do you really want to keep your house... | ✅ DODANE |
| Do you really want to move out... | ✅ DODANE |
| Unable to load dat file... | ✅ DODANE |
| Unable to load spr file... | ✅ DODANE |
| You don't have enough coins | ✅ DODANE |
| You don't may receive experience... | ✅ DODANE |
| You gain only 50%% experience... | ✅ DODANE |
| Edit Primary Key for \ | ⚠️ Wymaga sprawdzenia kontekstu |
| Edit Secondary Key for \ | ⚠️ Wymaga sprawdzenia kontekstu |
| Join %s\ | ⚠️ Wymaga sprawdzenia kontekstu |
| Revoke %s\ | ⚠️ Wymaga sprawdzenia kontekstu |

**Wynik:** Dodano 8 kluczowych tłumaczeń. Pozostałe 4 z backslashem wymagają sprawdzenia - mogą być niekompletnymi stringami.

### 4. Warstwa 3 - Brakujące skrypty w TextShaper

**Problem:** toHbScript() nie obsługuje wszystkich skryptów

| Skrypt | Status |
|--------|--------|
| HB_SCRIPT_HEBREW | ✅ DODANE |
| HB_SCRIPT_THAI | ✅ DODANE |
| HB_SCRIPT_DEVANAGARI | ✅ DODANE |
| HB_SCRIPT_BENGALI | ✅ DODANE |
| HB_SCRIPT_GEORGIAN | ✅ DODANE |
| HB_SCRIPT_ARMENIAN | ✅ DODANE |
| HB_SCRIPT_HIRAGANA | ✅ DODANE |
| HB_SCRIPT_KATAKANA | ✅ DODANE |
| HB_SCRIPT_HANGUL | ✅ DODANE |
| HB_SCRIPT_LATIN (explicit) | ✅ DODANE |

**Wynik:** Funkcja toHbScript() rozszerzona o 10 nowych skryptów z odpowiednimi komentarzami.

---

## 🟢 Priorytety niskie (dokumentacja/przyszłość)

### 5. Warstwa 1 - Hardcoded teksty w .otui (180 miejsc)

**Problem:** Teksty takie jak "Save", "Cancel", "Preview" są na stałe w plikach .otui

**Status:** ⏸️ ODŁOŻONE - Wymaga kompleksowej zmiany architektury

### 6. Warstwa 2 - Brakujące czcionki

**Problem:** 6 skryptów wymaga dodatkowych czcionek

| Skrypt | Wymagana czcionka | Status |
|--------|-------------------|--------|
| Hebrew | NotoSansHebrew-Regular.ttf | ⏸️ Do pobrania |
| Japanese | NotoSansJP-Regular.ttf | ⏸️ Do pobrania |
| Korean | NotoSansKR-Regular.ttf | ⏸️ Do pobrania |
| Thai | NotoSansThai-Regular.ttf | ⏸️ Do pobrania |
| Devanagari | NotoSansDevanagari-Regular.ttf | ⏸️ Do pobrania |
| Bengali | NotoSansBengali-Regular.ttf | ⏸️ Do pobrania |

**Status:** ⏸️ ODŁOŻONE - Wymaga pobrania i dodania plików TTF

---

## 📊 Podsumowanie napraw

| Kategoria | Przed | Po | Postęp |
|-----------|-------|-----|--------|
| Printf issues | 2 | 0 (OK) | ✅ 100% |
| strcpy issues | 2 | 0 | ✅ 100% |
| Missing tr() keys | 14 | 6 | 🔶 57% |
| Missing HB scripts | 10 | 0 | ✅ 100% |
| Hardcoded UI texts | 180 | 180 | ⏸️ 0% |
| Missing fonts | 6 | 6 | ⏸️ 0% |

---

## 📝 Wykonane zmiany

1. **TextShaper.cpp** - Rozszerzono funkcję `toHbScript()` o 10 nowych skryptów Unicode
2. **win32crashhandler.cpp** - Zamieniono `strcpy` na bezpieczne `strncpy` z null-termination
3. **httplogin.cpp** - Zamieniono `strcpy` na `strncpy` z `sizeof()` dla bezpieczeństwa
4. **pl.lua** - Dodano 8 brakujących kluczy tłumaczeń

---

*Dokument utworzony: 2025-12-06*
*Ostatnia aktualizacja: 2025-12-06*
