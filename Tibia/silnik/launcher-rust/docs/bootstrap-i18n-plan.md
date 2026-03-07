# Bootstrap Launcher — Plan i18n + Unicode Fix

## Zidentyfikowane problemy

### P-01: Brak polskich znaków w MessageBox (Windows)
- `MessageBoxA` — używa ANSI (codepage), NIE Unicode
- Polskie znaki ą, ę, ó, ś, ł, ż, ź, ć, ń są UTF-8, ale MessageBoxA oczekuje ANSI
- **Fix**: zamienić na `MessageBoxW` (Wide / UTF-16)
- Dotyczy: `ui.rs` linia 43-57

### P-02: Konsola Windows nie wyświetla UTF-8
- `eprintln!` wysyła UTF-8, ale konsola Windows domyślnie używa codepage 1250/437
- **Fix**: ustawić konsolę na UTF-8 na starcie: `SetConsoleOutputCP(65001)`
- Dotyczy: `ui.rs` lub `main.rs` (init)

### P-03: Hardcoded polskie stringi
- Wszystkie komunikaty (main.rs, downloader.rs, installer.rs) są po polsku i zahardkodowane
- Brak mechanizmu i18n
- ~25 stringów do tłumaczenia

---

## Plan implementacji

### Faza 1: Unicode fix (szybka)

**BL-I18N-01**: MessageBoxW zamiast MessageBoxA
- Zmienić `CString` → `encode_wide` do UTF-16
- Zmienić `MessageBoxA` → `MessageBoxW`
- ~15 linii zmiany w `ui.rs`

**BL-I18N-02**: Ustawienie konsoli na UTF-8
- Na starcie `main()`: `SetConsoleOutputCP(65001)` + `SetConsoleCP(65001)`
- Linux: nie potrzeba (terminal domyślnie UTF-8)
- ~5 linii w `main.rs`

### Faza 2: Lekki system i18n (wbudowany w binarkę)

**BL-I18N-03**: Stworzenie lekkiego systemu i18n

**Koncept**: Wbudowane stringi w binarce (bez pobierania plików językowych)
- Bootstrap musi być MAŁY (<2 MB) — nie pobieramy języków z sieci
- 5 języków wbudowanych: EN, PL, PT-BR, ES, DE
- ~25 stringów × 5 = 125 stringów = **~5-10 KB** dodatkowego kodu
- Zero dodatkowych zależności

**Struktura**:
```rust
// src/i18n.rs
pub enum Lang { En, Pl, PtBr, Es, De }

pub struct Strings {
    pub bootstrap_title: &'static str,
    pub installing_launcher: &'static str,
    pub existing_installation: &'static str,
    pub updating: &'static str,
    pub fetching_catalog: &'static str,
    pub invalid_api_response: &'static str,
    pub no_artifact: &'static str,
    pub downloading_launcher: &'static str,
    pub download_complete: &'static str,
    pub extracting: &'static str,
    pub saving_config: &'static str,
    pub install_complete: &'static str,
    pub launching: &'static str,
    pub error_http_client: &'static str,
    pub error_download: &'static str,
    pub error_hash_mismatch: &'static str,
    pub error_io: &'static str,
    pub error_unzip: &'static str,
    pub error_launcher_not_found: &'static str,
    pub error_temp_dir: &'static str,
    pub progress_label: &'static str,
    pub retry_message: &'static str,
    pub choose_language: &'static str,  // zawsze po angielsku
}
```

### Faza 3: Okienko wyboru języka

**BL-I18N-04**: Natywne okno dialogowe wyboru języka

**Na Windows**: Win32 API dialog (bez dodatkowych deps)
- `DialogBoxIndirectW` z wbudowanym template dialogu
- Lub `TaskDialogIndirect` (Vista+) z radio buttons

```
┌─────────────────────────────────┐
│  SerwerCanary — Choose Language │
│                                 │
│  ○ English                      │
│  ○ Polski                       │
│  ○ Português (Brasil)           │
│  ○ Español                      │
│  ○ Deutsch                      │
│                                 │
│       [ OK ]   [ Cancel ]       │
└─────────────────────────────────┘
```

**Na Linux**: Konsolowy wybór (1-5), bo bootstrap na Linux i tak jest konsolowy

**Przepływ**:
1. Uruchomienie bootstrapa
2. Wyskakuje okienko "Choose Language" (angielski, bez polskich znaków w UI wyboru)
3. User wybiera język
4. Zapisanie wyboru do `%LOCALAPPDATA%\SerwerCanary\language.conf`
5. Dalszy ciąg bootstrapa wypisuje komunikaty w wybranym języku
6. Język przekazywany do `launcher_config.json` → główny launcher też go czyta

### Faza 4: Auto-detect języka systemu

**BL-I18N-05**: Automatyczne wykrywanie języka

- Windows: `GetUserDefaultUILanguage()` → kod LCID (bez extra deps, kernel32)
- Linux: `$LANG` / `$LC_ALL`
- Jeśli wykryty język jest w naszej liście → używamy go automatycznie (bez dialogu)
- Jeśli nie → fallback na dialog "Choose Language"
- Można łączyć: auto-detect + możliwość zmiany w dialogu

---

## Kolejność implementacji

1. **BL-I18N-01 + BL-I18N-02** — szybki fix Unicode
2. **BL-I18N-03** — system i18n ze stringami
3. **BL-I18N-04** — dialog wyboru języka
4. **BL-I18N-05** — auto-detect języka systemu
5. **Testy** — build + ręczny test na Windows

## Wpływ na rozmiar binarki

| Element | Rozmiar dodatkowy |
|---------|-------------------|
| 125 stringów (5 języków) | +5-10 KB |
| Win32 dialog template | +2-3 KB |
| GetUserDefaultUILanguage | +0 KB (kernel32) |
| **Razem** | **~15 KB** |

Obecna binarka: 1884 KB (Windows), 2184 KB (Linux)
Po zmianach: ~1900 KB — niezauważalny wzrost.
Zero nowych zależności crateowych.

## Przepływ po zmianach

```
Bootstrap start
    │
    ├── SetConsoleOutputCP(65001)  ← Faza 1
    │
    ├── Auto-detect język systemu  ← Faza 4
    │   ├── znany? → użyj go
    │   └── nieznany? → dialog "Choose Language"  ← Faza 3
    │
    ├── Komunikaty w wybranym języku  ← Faza 2
    │   ├── "Pobieranie katalogu..."
    │   ├── "Pobieranie launchera..."
    │   └── "Instalacja zakończona!"
    │
    ├── Zapisz język do launcher_config.json
    │
    └── Uruchom główny launcher (dziedziczy język)
```
