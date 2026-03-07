# Plan i18n launchera Rust+Tauri — pełna wielojęzyczność i Unicode

**Data:** 2026-03-04  
**Branch:** `feature/ticket-gate`  
**Status:** W TRAKCIE (FAZA 9.4 BACKEND START)  
**Priorytet:** Wysoki (po naprawieniu CI)

---

## 1. Cel

Wprowadzenie pełnego systemu wielojęzyczności (i18n) do launchera Rust+Tauri,  
spójnego z systemem używanym na serwerze Canary (`Translator` + pliki JSON per locale)  
i w instalce OTClient (Unicode fonty + renderowanie wszystkich skryptów pisma).

**Klucze:**
- Pakiet bazowy: **angielski (en)** + **polski (pl)** — wbudowane w launcher
- Pozostałe języki pobierane na żądanie z serwera (tak jak paczki gry)
- Pełna obsługa Unicode: łacińskie, cyrylica, arabskie (RTL), CJK, devnagari, gruzińskie itd.
- Spójność kluczy tłumaczeń z serwerem Canary (ten sam format JSON, ten sam namespace)

---

## 2. Obecny stan

### 2.1 Launcher (Rust+Tauri)
| Element | Stan | Problem |
|---------|------|---------|
| UI HTML/JS | Hardcoded polski | Brak systemu tłumaczeń |
| Backend Rust | Hardcoded komunikaty PL | Brak i18n crate |
| Fonty | System default | Brak fontów Unicode dla CJK/Arabic/Devnagari |
| Logo/branding | Brak | Placeholder tekst "SerwerCanary" |
| Kolory | Ciemny motyw basic | Brak brandingu |
| Sidebar/nav | Proste text buttons | Brak ikon, brak localized labels |
| CSS variables | Bazowe | Brak RTL support |

### 2.2 Serwer Canary
| Element | Stan |
|---------|------|
| Translator C++ | ✅ 53+ locale (en, pl, de, es, fr, zh, ja, ko, ar, he, fa, ru...) |
| Format plików | ✅ JSON: `{locale}/system.json` z kluczami np. `"system.welcome"` |
| Fallback | ✅ Jeśli brak klucza w locale → fallback do `en` |
| Parametry | ✅ `{0}`, `{1}` w stringach (fmt) |

### 2.3 Instalka (OTClient)
| Element | Stan |
|---------|------|
| Unicode fonty | ✅ Noto Sans + CJK + Arabic (aktualnie w budowie) |
| Rendering | ✅ FreeType → glyph cache → OpenGL atlas |
| Locale switching | W budowie |

---

## 3. Architektura systemu i18n launchera

### 3.1 Warstwy

```
┌─────────────────────────────────────────────────────┐
│  Warstwa 1: Klucze tłumaczeń (JSON)                │
│  - en.json, pl.json (wbudowane)                     │
│  - de.json, es.json, ... (pobierane)               │
│  - Format spójny z Canary server                    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  Warstwa 2: Moduł i18n Rust (common-models)         │
│  - LauncherTranslator struct                         │
│  - Ładowanie/parsowanie JSON                        │
│  - Fallback chain: requested → pl → en              │
│  - Interpolacja parametrów {0}, {1}                 │
│  - Tauri command: get_translations(locale)          │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  Warstwa 3: Frontend JS (i18n.js)                    │
│  - data-i18n="klucz" atrybuty w HTML                │
│  - Dynamiczne podmenianie tekstu                    │
│  - RTL/LTR auto-detection                           │
│  - Fallback do klucza jeśli brak tłumaczenia        │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│  Warstwa 4: Fonty i Unicode rendering               │
│  - Podstawowe: system fonts → Noto Sans (bundled)   │
│  - Rozszerzone: font-pack per script (pobierany)    │
│  - CSS @font-face z fallback chain                  │
│  - RTL: dir="rtl" dla ar, he, fa                    │
└─────────────────────────────────────────────────────┘
```

### 3.2 Format pliku tłumaczeń (JSON)

Spójny z Canary `Translator`:

```json
// launcher-rust/i18n/en/launcher.json
{
  "launcher": {
    "title": "SerwerCanary",
    "status": {
      "launcher_label": "Launcher:",
      "client_label": "Client:",
      "channel_label": "Channel:",
      "status_label": "Status:",
      "checking": "checking…",
      "ready": "ready",
      "updating": "updating…",
      "error": "error"
    },
    "actions": {
      "play": "▶ Launch game",
      "check_updates": "🔄 Check for updates",
      "retry": "🔄 Retry",
      "back": "← Back",
      "repair": "🔧 Repair",
      "save": "💾 Save",
      "export_logs": "Export logs",
      "refresh": "🔄 Refresh",
      "update_launcher": "⬇ Update launcher",
      "download_language": "⬇ Download language pack"
    },
    "screens": {
      "error_title": "⚠ An error occurred",
      "repair_title": "🔧 Installation diagnostics",
      "settings_title": "⚙ Settings",
      "downloads_title": "📦 Download Center",
      "self_update_title": "🔄 Launcher update"
    },
    "repair": {
      "files_ok": "Files OK:",
      "corrupted": "Corrupted:",
      "missing": "Missing:",
      "to_download": "To download:"
    },
    "settings": {
      "channel": "Channel:",
      "install_path": "Install path:",
      "language": "Language:",
      "language_description": "Choose your display language"
    },
    "update": {
      "title": "Update",
      "checking": "Checking…",
      "files_count": "{0} / {1} files",
      "downloading": "Downloading…",
      "verifying": "Verifying…",
      "applying": "Applying…"
    },
    "self_update": {
      "current_version": "Current version:",
      "new_version": "New version:",
      "status": "Status:"
    },
    "nav": {
      "status": "Status",
      "downloads": "Downloads",
      "repair": "Repair",
      "settings": "Settings"
    },
    "downloads": {
      "loading": "Loading catalog…"
    },
    "errors": {
      "api_offline": "Cannot connect to server. Please check your internet connection.",
      "files_hash_mismatch": "Client integrity check failed. Please update or repair.",
      "launcher_version_rejected": "Your launcher is too old. Please update.",
      "rate_limited": "Too many requests. Please wait.",
      "manifest_fetch_failed": "Failed to fetch update manifest.",
      "manifest_parse_failed": "Failed to parse update manifest.",
      "hash_compute_failed": "Failed to compute file hash.",
      "token_request_failed": "Failed to get launch token.",
      "client_launch_failed": "Failed to start the game client."
    },
    "language_packs": {
      "title": "Language packs",
      "bundled": "Bundled",
      "available": "Available for download",
      "downloading": "Downloading {0}…",
      "installed": "Installed",
      "size": "Size: {0}"
    }
  }
}
```

```json
// launcher-rust/i18n/pl/launcher.json
{
  "launcher": {
    "title": "SerwerCanary",
    "status": {
      "launcher_label": "Launcher:",
      "client_label": "Klient:",
      "channel_label": "Kanał:",
      "status_label": "Status:",
      "checking": "sprawdzanie…",
      "ready": "gotowy",
      "updating": "aktualizacja…",
      "error": "błąd"
    },
    "actions": {
      "play": "▶ Uruchom grę",
      "check_updates": "🔄 Sprawdź aktualizacje",
      "retry": "🔄 Ponów",
      "back": "← Powrót",
      "repair": "🔧 Napraw",
      "save": "💾 Zapisz",
      "export_logs": "Eksport logów",
      "refresh": "🔄 Odśwież",
      "update_launcher": "⬇ Aktualizuj launcher",
      "download_language": "⬇ Pobierz pakiet językowy"
    },
    "screens": {
      "error_title": "⚠ Wystąpił błąd",
      "repair_title": "🔧 Diagnostyka instalacji",
      "settings_title": "⚙ Ustawienia",
      "downloads_title": "📦 Download Center",
      "self_update_title": "🔄 Aktualizacja launchera"
    },
    "repair": {
      "files_ok": "Pliki OK:",
      "corrupted": "Uszkodzone:",
      "missing": "Brakujące:",
      "to_download": "Do pobrania:"
    },
    "settings": {
      "channel": "Kanał:",
      "install_path": "Ścieżka instalacji:",
      "language": "Język:",
      "language_description": "Wybierz język interfejsu"
    },
    "update": {
      "title": "Aktualizacja",
      "checking": "Sprawdzanie…",
      "files_count": "{0} / {1} plików",
      "downloading": "Pobieranie…",
      "verifying": "Weryfikacja…",
      "applying": "Aplikowanie…"
    },
    "self_update": {
      "current_version": "Obecna wersja:",
      "new_version": "Nowa wersja:",
      "status": "Status:"
    },
    "nav": {
      "status": "Status",
      "downloads": "Pobieranie",
      "repair": "Naprawa",
      "settings": "Ustawienia"
    },
    "downloads": {
      "loading": "Ładowanie katalogu…"
    },
    "errors": {
      "api_offline": "Nie można połączyć się z serwerem. Sprawdź połączenie internetowe.",
      "files_hash_mismatch": "Sprawdzenie integralności klienta nie powiodło się. Zaktualizuj lub napraw.",
      "launcher_version_rejected": "Twój launcher jest za stary. Zaktualizuj.",
      "rate_limited": "Za dużo żądań. Proszę czekać.",
      "manifest_fetch_failed": "Nie udało się pobrać manifestu aktualizacji.",
      "manifest_parse_failed": "Nie udało się zinterpretować manifestu aktualizacji.",
      "hash_compute_failed": "Nie udało się obliczyć sumy kontrolnej.",
      "token_request_failed": "Nie udało się uzyskać tokenu uruchomienia.",
      "client_launch_failed": "Nie udało się uruchomić klienta gry."
    },
    "language_packs": {
      "title": "Pakiety językowe",
      "bundled": "Wbudowany",
      "available": "Dostępny do pobrania",
      "downloading": "Pobieranie {0}…",
      "installed": "Zainstalowany",
      "size": "Rozmiar: {0}"
    }
  }
}
```

---

## 4. Plan implementacji — fazy

### Faza 1: Infrastruktura i18n w Rust (LR-I18N-001..005)

| Zadanie | Opis | Szacunek |
|---------|------|----------|
| LR-I18N-001 | Moduł `common-models/src/i18n.rs` — `LauncherTranslator` struct z ładowaniem JSON, fallback chain, interpolacją | 4h |
| LR-I18N-002 | Pliki bazowe `i18n/en/launcher.json` + `i18n/pl/launcher.json` — pełne klucze UI | 2h |
| LR-I18N-003 | Tauri command `get_translations(locale)` + `get_available_locales()` | 2h |
| LR-I18N-004 | Integracja z `LauncherConfig` — pole `language` (domyślnie "pl") | 1h |
| LR-I18N-005 | Unit testy modułu i18n (fallback, interpolacja, brak klucza) | 2h |

### Faza 2: Frontend i18n system (LR-I18N-006..010)

| Zadanie | Opis | Szacunek |
|---------|------|----------|
| LR-I18N-006 | `ui/i18n.js` — silnik tłumaczeń frontend (data-i18n attributes, dynamiczne podmiany) | 4h |
| LR-I18N-007 | Refactor `index.html` — zastąpienie hardcoded tekstu atrybutami `data-i18n="klucz"` | 3h |
| LR-I18N-008 | Refactor `app.js` — dynamiczne teksty z obiektu tłumaczeń | 2h |
| LR-I18N-009 | RTL support: `dir="rtl"` w CSS, mirrored layout dla Arabic/Hebrew/Farsi | 3h |
| LR-I18N-010 | Selector języka w ekranie Ustawienia (dropdown z flagami/nazwami natywna) | 2h |

### Faza 3: Fonty i Unicode rendering (LR-I18N-011..015)

| Zadanie | Opis | Szacunek |
|---------|------|----------|
| LR-I18N-011 | Bundled font: Noto Sans (Latin+Cyrillic+Greek, ~300KB) jako domyślny | 2h |
| LR-I18N-012 | Font pack system: definicja pakietów fontów per script w manifeście | 3h |
| LR-I18N-013 | CSS @font-face chain z fallback (system → bundled → downloaded) | 2h |
| LR-I18N-014 | CJK font pack: Noto Sans CJK (ch/ja/ko, ~16MB — pobierany na żądanie) | 2h |
| LR-I18N-015 | Arabic/Devanagari/Thai font packs (po ~1-3MB — pobierane na żądanie) | 2h |

### Faza 4: Pakiety językowe do pobrania (LR-I18N-016..020)

| Zadanie | Opis | Szacunek |
|---------|------|----------|
| LR-I18N-016 | API endpoint `/api/language-packs.php` — lista dostępnych paczek | 2h |
| LR-I18N-017 | Ekran Language Packs w UI — lista z przyciskami "Pobierz"/"Zainstalowany" | 3h |
| LR-I18N-018 | Mechanizm pobierania + weryfikacji SHA-256 paczki językowej | 2h |
| LR-I18N-019 | Aktualizacja paczek językowych razem z manifestem (wersjonowanie) | 2h |
| LR-I18N-020 | Synchronizacja locale z serwerem Canary — przesyłanie `locale` w API calls | 1h |

### Faza 5: Branding i visual design (LR-I18N-021..028)

| Zadanie | Opis | Szacunek |
|---------|------|----------|
| LR-I18N-021 | Projektowanie logo SerwerCanary (SVG/PNG, min 3 warianty) | — (wymaga decyzji) |
| LR-I18N-022 | Paleta kolorów — finalizacja (obecne CSS variables jako baza) | 2h |
| LR-I18N-023 | Sidebar z ikonami zamiast tekstu (ikony SVG/emoji + tooltip z i18n) | 3h |
| LR-I18N-024 | Splash screen / loading z logo i animacją | 2h |
| LR-I18N-025 | Tray icon / taskbar icon (Windows/Linux) | 2h |
| LR-I18N-026 | Window title z wersją: "{title} v{version}" z i18n | 1h |
| LR-I18N-027 | Auto-dark/light mode (opcjonalnie, na przyszłość) | 3h |
| LR-I18N-028 | Responsywne UI — minimalne okno 600x400, pełne 800x600+ | 2h |

---

## 5. System pakietów językowych — szczegóły

### 5.1 Poziomy (tiers) pakietów

| Tier | Zawartość | Rozmiar | Dystrybucja |
|------|-----------|---------|-------------|
| **Tier 0 — Core** | `en` + `pl` + Noto Sans Latin/Cyrillic | ~400KB | Wbudowany w launcher binary |
| **Tier 1 — European** | `de`, `es`, `fr`, `it`, `pt`, `nl`, `sv`, `ru`, `cs`, `hu`, `ro`, `bg`, `uk` | ~50KB per locale | Pobierany — <1 sek |
| **Tier 2 — CJK** | `zh`, `ja`, `ko` + Noto Sans CJK font | ~16MB | Pobierany — osobna paczka |
| **Tier 3 — Arabic/RTL** | `ar`, `he`, `fa` + Arabic font + RTL CSS | ~3MB | Pobierany |
| **Tier 4 — Indic/SE Asian** | `hi`, `bn`, `th`, `vi` + fonty | ~5MB | Pobierany |
| **Tier 5 — Other** | `tr`, `ka`, `hy`, `az`, `kk`, `uz`, `af`, `sw`, `eu`, `ca`, `gl`, `el`, `fi`, `is`, `da`, `no`, `et`, `lt`, `lv`, `sk`, `hr`, `sr`, `sl`, `sq`, `mk`, `id`, `ms`, `fil` | ~20KB per locale | Pobierany |

### 5.2 Format paczki językowej

```
language-pack-{locale}-{version}.zip
├── {locale}/
│   └── launcher.json        # Tłumaczenia klucz→tekst
├── fonts/                    # (opcjonalne, tylko jeśli tier wymaga)
│   └── NotoSans{Script}.woff2
└── manifest.json             # Metadane paczki
```

### 5.3 Manifest paczki

```json
{
  "locale": "de",
  "version": "1.0.0",
  "tier": 1,
  "sha256": "abcdef...",
  "size": 48000,
  "fonts": [],
  "minLauncherVersion": "0.2.0",
  "displayName": "Deutsch",
  "nativeName": "Deutsch",
  "flag": "🇩🇪"
}
```

### 5.4 API: `/api/language-packs.php`

```json
{
  "availablePacks": [
    { "locale": "en", "version": "1.0.0", "bundled": true, "displayName": "English", "nativeName": "English", "flag": "🇬🇧", "tier": 0 },
    { "locale": "pl", "version": "1.0.0", "bundled": true, "displayName": "Polish", "nativeName": "Polski", "flag": "🇵🇱", "tier": 0 },
    { "locale": "de", "version": "1.0.0", "bundled": false, "displayName": "German", "nativeName": "Deutsch", "flag": "🇩🇪", "tier": 1, "url": "https://cdn.example.com/i18n/de-1.0.0.zip", "sha256": "...", "size": 48000 },
    { "locale": "zh", "version": "1.0.0", "bundled": false, "displayName": "Chinese", "nativeName": "中文", "flag": "🇨🇳", "tier": 2, "url": "https://cdn.example.com/i18n/zh-1.0.0.zip", "sha256": "...", "size": 16500000, "requiresFonts": ["NotoSansCJK"] }
  ]
}
```

---

## 6. Obsługa RTL (Right-to-Left)

Dla języków: **Arabic (ar), Hebrew (he), Farsi/Persian (fa)**

### 6.1 HTML
```html
<html lang="ar" dir="rtl">
```

### 6.2 CSS
```css
/* Auto-direction based on lang */
[dir="rtl"] { direction: rtl; text-align: right; }
[dir="rtl"] .nav-btn { order: -1; }  /* Mirror navigation */
[dir="rtl"] .progress-bar { transform: scaleX(-1); }  /* Mirror progress */
[dir="rtl"] .actions { flex-direction: row-reverse; }

/* Use logical properties */
.status-row { padding-inline-start: 12px; margin-inline-end: 8px; }
```

### 6.3 Bidirectional text
```javascript
// Auto-detect RTL locales
const RTL_LOCALES = ['ar', 'he', 'fa'];
function applyTextDirection(locale) {
  const dir = RTL_LOCALES.includes(locale) ? 'rtl' : 'ltr';
  document.documentElement.dir = dir;
  document.documentElement.lang = locale;
}
```

---

## 7. Wymagania fontowe per skrypt pisma

| Skrypt | Font | Rozmiar (woff2) | Unicode Range |
|--------|------|-----------------|---------------|
| Latin + Cyrillic + Greek | Noto Sans Regular | ~150KB | U+0000-024F, U+0400-04FF, U+0370-03FF |
| Latin Extended (PL, CZ, RO, HU...) | Noto Sans (subset) | wliczony w above | U+0100-024F |
| CJK (Chinese, Japanese, Korean) | Noto Sans CJK SC/JP/KR | ~7MB each | U+4E00-9FFF, U+3040-309F, U+AC00-D7AF |
| Arabic | Noto Sans Arabic | ~200KB | U+0600-06FF, U+FB50-FDFF |
| Hebrew | Noto Sans Hebrew | ~80KB | U+0590-05FF |
| Devanagari (Hindi) | Noto Sans Devanagari | ~150KB | U+0900-097F |
| Bengali | Noto Sans Bengali | ~120KB | U+0980-09FF |
| Thai | Noto Sans Thai | ~80KB | U+0E00-0E7F |
| Georgian | Noto Sans Georgian | ~60KB | U+10A0-10FF |
| Armenian | Noto Sans Armenian | ~50KB | U+0530-058F |

---

## 8. Spójność z OTClient i serwerem Canary

### 8.1 Wspólne klucze
Tam gdzie ma sens, klucze tłumaczeń będą kompatybilne:
- Serwer: `system.welcome`, `npc.*.greeting`
- Launcher: `launcher.status.ready`, `launcher.actions.play`
- OTClient: `client.ui.*`, `client.error.*`

### 8.2 Wspólny pipeline tłumaczeń
1. Translator tworzy klucze w `en`
2. Klucze trafiają do systemu (Crowdin/Weblate/ręcznie)
3. Przetłumaczone pliki generowane jako JSON per locale
4. Release pipeline pakuje per tier i uploaduje na CDN
5. Launcher/OTClient/Serwer pobierają przy aktualizacji

### 8.3 Wspólne locale ID
| ID | Język | Serwer | OTClient | Launcher |
|----|-------|--------|----------|----------|
| `en` | English | ✅ | ✅ | ✅ (bundled) |
| `pl` | Polski | ✅ | ✅ | ✅ (bundled) |
| `de` | Deutsch | ✅ | ✅ | ✅ (tier 1) |
| `es` | Español | ✅ | ✅ | ✅ (tier 1) |
| `zh` | 中文 | ✅ | ✅ | ✅ (tier 2) |
| `ar` | العربية | ✅ | ✅ | ✅ (tier 3, RTL) |
| ... | ... | 53+ | 53+ | 53+ |

---

## 9. Co BRAKUJE i wymaga decyzji

### 9.1 Branding — Logo
- **Status:** Brak logo. Używany tekst "SerwerCanary".
- **Potrzebne:**
  - Logo SVG (skalowalne, wektorowe)
  - Warianty: pełne (tekst+ikona), ikona, favicon
  - Formaty: SVG, PNG @1x/@2x, ICO (Windows tray)
  - Motyw: dark + light variant
- **Decyzja:** Projektant graficzny lub AI generator?

### 9.2 Paleta kolorów
Obecne CSS variables:
```css
--bg-primary: #1a1a2e;     /* Ciemny granatowy */
--bg-secondary: #16213e;   /* Granatowy */
--bg-card: #0f3460;        /* Niebieski */
--accent: #e94560;         /* Czerwony/różowy */
--accent-hover: #ff6b81;   /* Jasny różowy */
--text: #eaeaea;           /* Biały */
--success: #2ecc71;        /* Zielony */
--warn: #f39c12;           /* Pomarańczowy */
--error: #e74c3c;          /* Czerwony */
```

**Pytania:**
- Czy obecna paleta jest OK?
- Czy chcemy light mode?
- Czy accent color pasuje do brandingu SerwerCanary?

### 9.3 Sidebar / nawigacja
Obecna: text buttons w footer.

**Propozycja redesignu:**
```
┌─────┬────────────────────────────────┐
│ 🏠  │                                │
│ 📦  │    [główna treść ekranu]       │
│ 🔧  │                                │
│ ⚙  │                                │
│     │                                │
│ 📋  │                                │
│     │                                │
│     │                                │
│  🌐 │    [selector języka na dole]   │
└─────┴────────────────────────────────┘
```

- Sidebar ze SVG ikonami (nie emoji — cross-platform spójne)
- Tooltip z localized label
- Active state z accent color
- Collapsed mode na małych oknach

### 9.4 Window icon / tray
- Wymaga `.ico` (Windows) i `.png` (Linux)
- Obecny: brak (generowany placeholder w CI)
- Potrzebny design logo aby wygenerować ikony

---

## 10. Priorytet i kolejność

```
[CI FIXES] ← obecnie
    │
    ▼
[Faza 1] Infrastruktura i18n Rust         ← 11h
    │
    ▼
[Faza 2] Frontend i18n system             ← 14h
    │
    ▼
[Faza 5] Branding — LOGO + KOLORY         ← wymaga decyzji
    │
    ▼
[Faza 3] Fonty + Unicode                  ← 11h
    │
    ▼
[Faza 4] Pakiety językowe do pobrania     ← 10h
```

**Łączny szacunek:** ~50-60h kodowania + czas na design logo/brandingu

---

## 11. Zależności od CI

Przed rozpoczęciem prac i18n, muszą przejść:
1. ✅ Clippy fixes (ae6706ace — pushed)
2. ⏳ Build Launcher (czeka na CI)
3. ⏳ Launcher Rust CI (czeka na CI)
4. ⏳ Canary Build (osobny pipeline)
5. ⏳ Windows Build (osobny pipeline — CDN 503 retry)

---

## 12. Appendix: Pełna lista 53+ locale (spójna z serwerem)

```
TIER 0 (bundled):  en, pl
TIER 1 (European): de, es, fr, it, pt, nl, sv, da, no, fi, is,
                    cs, hu, ro, bg, sk, hr, sr, sl, sq, mk,
                    ru, uk, lt, lv, et, el
TIER 2 (CJK):      zh, ja, ko
TIER 3 (RTL):      ar, he, fa
TIER 4 (Indic/SE): hi, bn, th, vi
TIER 5 (Other):    tr, ka, hy, az, kk, uz, af, sw, eu, ca, gl,
                    id, ms, fil
```

Łącznie: **53 locale**, identycznie jak Canary server `supportedLocaleList()`.

---

## 13. Aktualizacja wykonania (2026-03-05, Codex)

### 13.1 Zrobione teraz (Faza 9.2, frontend)

- `launcher-rust/apps/launcher-tauri/ui/app.js`:
  - dodano runtime i18n PL/EN (`I18N`, `t()`, fallback locale, interpolacja `{0}`),
  - dodano wykrywanie preferencji języka (`localStorage` + `navigator.language`),
  - dodano przełączanie języka w runtime (`setLocale()`), w tym tłumaczenie:
    - etykiet ekranów,
    - przycisków,
    - statusów faz i progress stage,
    - komunikatów download center i self-update,
    - alertów eksportu logów,
  - dodano fallback dla nieznanych statusów/stage (z API) do surowej wartości zamiast klucza i18n.
- `launcher-rust/apps/launcher-tauri/ui/index.html`:
  - dodano identyfikatory elementów pod i18n (nagłówki/labelki/tytuły),
  - dodano selector języka w ustawieniach (`#setting-language`),
  - dodano dedykowane pole opisu błędu download center (`#downloads-error-hint`) tłumaczone z i18n.

### 13.2 W trakcie / do domknięcia

- [x] Wyciągnięcie słownika z `app.js` do osobnych plików `ui/i18n/*.json`.
- [x] Integracja persist języka z backendem (`LauncherConfig.language`) + zapis do `launcher_config.json` przez `change_channel`.
- [x] Przepięcie backendowych komunikatów `status.error.userMessage` na klucze i18n zamiast surowego tekstu (z fallbackiem do surowego tekstu).
- [x] Implementacja pełnego RTL (`dir=rtl`, mirrored layout) dla `ar/he/fa`.

### 13.4 Aktualizacja wykonania (2026-03-05, Codex — etap 2)

- `common-models/src/launcher_config.rs`:
  - dodano pole `language` (default `pl`) + walidację,
  - dodano `discover_with_path()` (config + ścieżka do zapisu).
- `apps/launcher-tauri/src/state.rs`:
  - `AppStateInner` przechowuje `language`, `config`, `config_path`.
- `apps/launcher-tauri/src/commands.rs`:
  - `change_channel(channel, language)` zapisuje ustawienia do `launcher_config.json`,
  - `get_status` zwraca aktualny `language` w DTO.
- `common-models/src/dto.rs`:
  - `LauncherStatusDto` rozszerzony o `language`.
- `apps/launcher-tauri/ui/app.js`:
  - startup synchronizuje locale z backendu (`status.language`) oraz zapisuje przy `change_channel`.

### 13.3 Ryzyka / uwagi techniczne

- Obecna implementacja i18n jest frontend-first (bez nowego Tauri command `get_translations`).
- W pierwszym kroku produkcyjnym wspierane są 2 locale (`pl`, `en`), a technicznie UI ma już także `ar/he/fa` pod testy RTL.
- Rozszerzenie do 53 locale wymaga osobnej fazy: pipeline paczek językowych + font packs.

### 13.5 Aktualizacja wykonania (2026-03-05, Codex — etap 3)

- `launcher-rust/apps/launcher-tauri/ui/i18n/pl.json` i `ui/i18n/en.json`:
  - słowniki zostały wydzielone z `app.js` do osobnych plików JSON (Tier0: PL/EN),
  - dodano sekcję `errors.backend.*` dla kodów `LCH_*`.
- `launcher-rust/apps/launcher-tauri/ui/app.js`:
  - dodano asynchroniczne ładowanie słowników (`loadI18nDictionaries()`),
  - startup czeka na wczytanie i18n przed renderem (`DOMContentLoaded`),
  - dodano `resolveBackendErrorMessage()` z obsługą `userMessageKey` + fallback do `userMessage`.
- `launcher-rust/crates/common-models/src/dto.rs`:
  - `ErrorInfoDto` rozszerzono o `userMessageKey` (`camelCase`),
  - `from_code()` i `generic()` ustawiają `errors.backend.LCH_*` gdy dostępny kod launcherowy,
  - dodano testy DTO dla `userMessageKey`.

### 13.6 Aktualizacja wykonania (2026-03-05, Codex — etap 4 RTL)

- `launcher-rust/apps/launcher-tauri/ui/app.js`:
  - rozszerzono `SUPPORTED_LOCALES` o `ar`, `he`, `fa`,
  - dodano `RTL_LOCALES` i normalizację locale (`normalizeLocale`),
  - `document.documentElement.dir` ustawiany dynamicznie (`rtl` dla `ar/he/fa`),
  - selector języka obsługuje zapis/odczyt RTL locale.
- `launcher-rust/apps/launcher-tauri/ui/style.css`:
  - dodano reguły mirrored layout dla `html[dir="rtl"]` (header, karty status/settings/error, server list, progress, download card, footer/nav).
- `launcher-rust/apps/launcher-tauri/ui/i18n/`:
  - dodano `ar.json`, `he.json`, `fa.json` (bazowe paczki UI dla testów RTL).

### 13.7 Aktualizacja wykonania (2026-03-05, Codex — etap 5 i18n coverage + Unicode fallback)

- `launcher-rust/apps/launcher-tauri/ui/index.html`:
  - nazwy światów dostały dedykowane identyfikatory (`server-name-main`, `server-name-retro`) do podmiany przez i18n.
- `launcher-rust/apps/launcher-tauri/ui/app.js`:
  - dodano mapowanie frontendowych kodów błędów na klucze i18n (`errors.frontend.*`),
  - flow `showError(...)` dla `CHECK_ERROR/UPDATE_ERROR/LAUNCH_ERROR/REPAIR_ERROR/SETTINGS_ERROR` nie pokazuje już surowych komunikatów jako ścieżki głównej,
  - nazwy światów są ustawiane przez `t("labels.serverMainName")` i `t("labels.serverRetroName")`.
- `launcher-rust/apps/launcher-tauri/ui/i18n/*.json`:
  - dodano klucze `labels.serverMainName`, `labels.serverRetroName`,
  - dodano sekcję `errors.frontend.*` (w tym fallback `UNKNOWN`) we wszystkich aktualnie wspieranych locale.
- `launcher-rust/apps/launcher-tauri/ui/style.css`:
  - rozszerzono `font-family` o fallback chain oparty o Noto (`Noto Sans`, `Noto Sans Arabic`, `Noto Sans Hebrew`, `Noto Sans CJK`).

Uwaga:
- to podnosi pokrycie znaków, ale pełna gwarancja „wszystkie litery w każdym skrypcie” nadal wymaga bundlowanych font-packów (Faza 9.3/9.4).

### 13.8 Aktualizacja wykonania (2026-03-05, Codex — etap 6 font-pack model)

- `launcher-rust/crates/common-models/src/font_pack.rs`:
  - dodano model `FontPackInfo` (`locale`, `script`, `version`, `url`, `sha256`, `size`, `bundled`),
  - dodano walidację metadanych (HTTPS URL, SHA-256 hex, size > 0),
  - dodano helper `cache_key()`.
- `launcher-rust/crates/common-models/src/lib.rs`:
  - eksport modułu `font_pack`.
- testy:
  - `test_font_pack_info_validate_ok`,
  - `test_font_pack_info_validate_bad_sha`,
  - `test_font_pack_info_validate_non_https_url`,
  - `test_font_pack_info_cache_key`.

### 13.9 Aktualizacja wykonania (2026-03-05, Codex — etap 7 font-pack download)

- `launcher-rust/crates/launcher-core/src/font_pack_download.rs`:
  - dodano `download_font_pack()` dla etapu 9.3.5,
  - dodano walidację metadanych wejściowych (locale/script/version/url/sha256/size),
  - dodano kontrolę integralności pobranej paczki (`size` + `sha256`),
  - dodano zapis zweryfikowanej paczki do cache (`cache_dir`).
- `launcher-rust/crates/launcher-core/src/lib.rs`:
  - wyeksportowano moduł `font_pack_download`.
- testy modułu `font_pack_download`:
  - `test_download_font_pack_ok`,
  - `test_download_font_pack_hash_mismatch`,
  - `test_download_font_pack_size_mismatch`,
  - `test_download_font_pack_rejects_non_https_non_loopback`.

Status etapu:
- 9.3.5 i 9.3.6 są gotowe kodowo (🟢), ale walidacja build/test całego `launcher-core` czeka,
  bo na tym etapie prace są prowadzone bez uruchamiania kompilacji (zgodnie z dyspozycją usera).

### 13.10 Aktualizacja wykonania (2026-03-05, Codex — etap 8 language-pack backend)

- `launcher-rust/crates/common-models/src/api_responses.rs`:
  - dodano modele kontraktu API dla paczek językowych:
    - `LanguagePacksResponse`,
    - `LanguagePackInfo`.
- `launcher-rust/crates/launcher-api/src/client.rs`:
  - dodano `fetch_language_packs()` dla endpointu `language-packs.php`,
  - obsługa `HTTP 429` + błędów statusu analogicznie do pozostałych endpointów.
- `launcher-rust/crates/launcher-core/src/language_pack_download.rs`:
  - dodano `download_language_pack()` (walidacja, pobranie, verify `size`/`sha256`, unzip),
  - dodano bezpieczny unzip z ochroną przed path traversal (`enclosed_name()`),
  - dodano zapis metadanych lokalnej instalacji (`.launcher_pack.json`),
  - dodano `list_installed_packs()` do skanowania lokalnie zainstalowanych paczek.
- `launcher-rust/apps/launcher-tauri/src/commands.rs`:
  - dodano komendy Tauri dla paczek językowych:
    - `get_language_packs`,
    - `download_language_pack`,
    - `list_installed_language_packs`.
- `launcher-rust/apps/launcher-tauri/src/main.rs`:
  - rejestracja nowych komend Tauri w `invoke_handler`.
- `launcher-rust/apps/launcher-tauri/ui/index.html`:
  - dodano blok "Language packs" do ekranu Ustawienia (lista, stan, refresh).
- `launcher-rust/apps/launcher-tauri/ui/app.js`:
  - dodano `loadLanguagePacksPanel()` + `installLanguagePack(...)`,
  - integracja frontendu z komendami `get_language_packs`, `list_installed_language_packs`, `download_language_pack`,
  - ładowanie panelu przy wejściu na ekran Ustawienia.
- `launcher-rust/apps/launcher-tauri/ui/style.css`:
  - dodano style `language-pack-*` + wsparcie RTL dla wierszy paczek.
- `launcher-rust/apps/launcher-tauri/ui/i18n/{pl,en,ar,he,fa}.json`:
  - dodano klucze `labels.languagePacks` i `languagePacks.*`.
- `launcher-rust/crates/launcher-core/src/lib.rs`:
  - wyeksportowano moduł `language_pack_download`.
- `launcher-rust/Cargo.toml` + `launcher-rust/crates/launcher-core/Cargo.toml`:
  - dodano dependency `zip` dla obsługi paczek językowych.

Status etapu:
- 9.4.4 i 9.4.5: 🟢 gotowe kodowo,
- 9.4.2: ⏳ panel UI jest już podłączony, ale endpoint produkcyjny `language-packs.php` wymaga domknięcia po stronie API,
- 9.4.6 (testy) pozostaje otwarte,
- walidacja build/test pozostaje na CI/GHA (bez lokalnej kompilacji).
