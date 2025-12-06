# 📋 Plan Analizy Kodu - System 6 Warstw

## Wstęp

Ten dokument opisuje szczegółowy plan działania dla kompleksowej analizy kodu projektu OTClient (testyy).
Analiza jest podzielona na 6 warstw, każda koncentruje się na innym aspekcie systemu wielojęzyczności
i bezpieczeństwa kodu.

---

## 📊 Informacje o strukturze projektu

### Statystyki plików do analizy

| Typ pliku | Ilość | Lokalizacja |
|-----------|-------|-------------|
| Pliki .lua (lokalizacje) | 53 | `data/locales/*.lua` |
| Pliki .lua (moduły) | 230 | `modules/**/*.lua` |
| Pliki .otui | 152 | `data/styles/*.otui`, `modules/**/*.otui` |
| Pliki .otml | 3 | `data/**/*.otml` |
| Pliki .cpp/.h | 371 | `src/**/*.cpp`, `src/**/*.h` |
| Pliki TTF | 4 | `data/fonts/ttf/*.ttf` |

### Katalogi kluczowe

```
testyy/
├── data/
│   ├── locales/          # 53 plików .lua z tłumaczeniami
│   ├── fonts/
│   │   └── ttf/          # Czcionki TTF (NotoSans, NotoNaskh, NotoSansSC)
│   ├── i18n/             # Pliki lokalizacji JSON/OTML
│   └── styles/           # Pliki UI (.otui)
├── modules/
│   ├── client_locales/   # System lokalizacji klienta
│   └── client_entergame/ # Ekran logowania
└── src/
    └── framework/
        ├── text/         # TextShaper, TTFFont, LocaleShaping
        ├── graphics/     # DrawPool, BitmapFont
        └── ui/           # UITextEdit, UIWidgetText
```

---

## 🧩 WARSTWA 1 — Language Asset Auditor

### Cel
Skanowanie i audyt wszystkich zasobów językowych w projekcie.

### Pliki do przeskanowania

1. **Lokalizacje główne:** `data/locales/*.lua` (53 pliki)
2. **Lokalizacje modułów:** `modules/**/locales/*.lua` (jeśli istnieją)
3. **Pliki JSON:** `data/lang/*.json` (jeśli istnieją)
4. **Pliki UI:** wszystkie `*.otui` pod kątem `text="..."`
5. **Pliki OTML:** wszystkie `*.otml` z wartościami string
6. **Kod źródłowy:** wszystkie `.cpp/.h/.lua` gdzie występuje `tr("...")`

### Plan działania

```
[ ] Krok 1.1: Ekstrakcja kluczy z data/locales/en.lua (wzorcowy plik)
[ ] Krok 1.2: Porównanie kluczy we wszystkich 53 językach
[ ] Krok 1.3: Skanowanie plików .otui pod kątem text="..."
[ ] Krok 1.4: Skanowanie plików .cpp/.h/.lua pod kątem tr("...")
[ ] Krok 1.5: Identyfikacja hardcoded stringów (nie używających tr())
[ ] Krok 1.6: Generowanie raportu brakujących kluczy
```

### Oczekiwany raport

1. ✔️ Lista kluczy brakujących per język
2. ✔️ Lista kluczy nieużywanych
3. ✔️ Lista stringów "na sztywno" w kodzie (nie używających tr())
4. ✔️ Lista miejsc z UI bez możliwości tłumaczenia (otui: text="xxx")
5. ✔️ Regresje językowe (klucz istnieje w EN/PL, ale brakuje w DE/AR/ZH)

### Narzędzia potrzebne
- Skrypty Lua/Python do parsowania
- grep/awk do wyszukiwania wzorców
- Porównywarka słowników

### Status: ⏳ W TRAKCIE

---

## 🧩 WARSTWA 2 — Unicode Coverage Scanner (TTF)

### Cel
Analiza pokrycia Unicode przez czcionki TTF w projekcie.

### Pliki do analizy

1. **Czcionki TTF:** `data/fonts/ttf/*.ttf`
   - NotoSans-Regular.ttf
   - NotoSans-Bold.ttf
   - NotoNaskhArabic-Regular.ttf
   - NotoSansSC-Regular.ttf

2. **Definicje czcionek:** `data/fonts/*.otfont`

3. **Kod:** `src/framework/text/TTFFont.cpp`, `src/framework/graphics/fontmanager.cpp`

### Plan działania

```
[ ] Krok 2.1: Analiza zakresów Unicode w każdym pliku TTF (OS/2 table)
[ ] Krok 2.2: Mapowanie czcionka → obsługiwane skrypty
[ ] Krok 2.3: Analiza fallback chain w kodzie klienta
[ ] Krok 2.4: Weryfikacja pokrycia dla wszystkich 53 języków
[ ] Krok 2.5: Test rasteryzacji atlasów TTF
```

### Oczekiwany raport

1. ✔️ Czy każdy język ma czcionkę zdolną wyświetlić Unicode?
2. ✔️ Czy fallback chain pokrywa 100% znaków w locale?
3. ✔️ Czy TTFFont.cpp ma aktywne rasteryzowanie atlasów?

### Mapowanie czcionek (wstępne)

| Czcionka | Obsługiwane skrypty |
|----------|---------------------|
| NotoSans-Regular.ttf | Latin, Cyrillic, Greek |
| NotoNaskhArabic-Regular.ttf | Arabic |
| NotoSansSC-Regular.ttf | Han (Chinese) |
| NotoSans-Bold.ttf | Latin, Cyrillic, Greek |

### Brakujące czcionki (do weryfikacji)

- Hebrew (he) - potrzebna Noto Sans Hebrew
- Thai (th) - potrzebna Noto Sans Thai
- Hindi/Bengali (hi/bn) - potrzebna Noto Sans Devanagari/Bengali
- Japanese/Korean (ja/ko) - potrzebne Noto Sans JP/KR

### Status: ⏳ ZAPLANOWANE

---

## 🧩 WARSTWA 3 — HarfBuzz/FriBidi Compliance Checker

### Cel
Weryfikacja poprawności implementacji HarfBuzz i obsługi RTL/bidi.

### Pliki do analizy

1. **TextShaper:** `src/framework/text/TextShaper.cpp`, `TextShaper.h`
2. **TTFFont:** `src/framework/text/TTFFont.cpp`, `TTFFont.h`
3. **LocaleShaping:** `src/framework/text/LocaleShaping.cpp`, `LocaleShaping.h`
4. **UI Text:** `src/framework/ui/uitextedit.cpp`, `uiwidgettext.cpp`
5. **DrawPool:** `src/framework/graphics/drawpool.cpp`

### Plan działania

```
[ ] Krok 3.1: Weryfikacja wywołań hb_shape() przed rysowaniem
[ ] Krok 3.2: Sprawdzenie obsługi HB_DIRECTION_RTL dla arabskiego/hebrajskiego
[ ] Krok 3.3: Analiza parametrów script/lang (czy nie są hardcoded na "Latn")
[ ] Krok 3.4: Weryfikacja ścieżek ASCII/Latin-only
[ ] Krok 3.5: Sprawdzenie czy atlas TTF trafia do DrawPool
```

### Oczekiwany raport

1. ✔️ Czy w kodzie nie pozostały ścieżki ASCII/Latin-only
2. ✔️ Czy hb_shape() jest wywoływane zawsze przed rysowaniem
3. ✔️ Czy RTL jest poprawnie wykrywane i ustawiane (HB_DIRECTION_RTL)
4. ✔️ Czy parametry shaping script/lang nie są hardcoded („Latn")
5. ✔️ Czy atlas TTF jest faktycznie wysyłany do DrawPool

### Znalezione implementacje (wstępne)

**TextShaper.cpp (linie 1-59):**
```cpp
static hb_script_t toHbScript(const std::string& s) {
  if (s == "Cyrl") return HB_SCRIPT_CYRILLIC;
  if (s == "Grek") return HB_SCRIPT_GREEK;
  if (s == "Arab") return HB_SCRIPT_ARABIC;
  if (s == "Hani") return HB_SCRIPT_HAN;
  return HB_SCRIPT_LATIN;  // ⚠️ Default fallback
}
```

**⚠️ Potencjalny problem:** Brak obsługi wielu skryptów (Hebrew, Thai, Devanagari, etc.)

### Status: ⏳ ZAPLANOWANE

---

## 🧩 WARSTWA 4 — Code Safety & Format Consistency

### Cel
Wykrywanie niebezpiecznych wzorców formatowania i potencjalnych crashów.

### Wzorce do wykrycia

1. **Stare formatowanie printf:** `%s`, `%i`, `%d`, `%` bez parametru
2. **Niekompletne format stringi:** gołe `{}` bez escapingu
3. **Niezgodność parametrów:** ilość `{}` vs ilość argumentów

### Plan działania

```
[ ] Krok 4.1: Skanowanie .cpp/.h pod kątem %s, %i, %d
[ ] Krok 4.2: Skanowanie .lua pod kątem string.format z %
[ ] Krok 4.3: Weryfikacja zgodności fmt::format z parametrami
[ ] Krok 4.4: Identyfikacja miejsc wymagających zamiany % → {}
[ ] Krok 4.5: Sprawdzenie escapingu {} w stringach
```

### Oczekiwany raport

1. ✔️ Lista wszystkich miejsc wymagających zamiany `%` → `{}`
2. ✔️ Lista miejsc gdzie parametry fmt nie zgadzają się z format stringiem
3. ✔️ Lista miejsc gdzie string zawiera `{}` i może powodować fallback fmt

### Znane problemy (z dokumentacji)

**protocol.cpp:**
```cpp
// PRZED:
g_logger.traceError("invalid size %i", totalSize);
// PO:
g_logger.traceError("invalid size {}", totalSize);
```

**bitmapfont.cpp:**
```cpp
// PRZED:
"TTF load failed: %s"
// PO:
"TTF load failed: {}"
```

### Status: ⏳ ZAPLANOWANE

---

## 🧩 WARSTWA 5 — Runtime Simulation (Dry Run)

### Cel
Symulacja shaping dla różnych języków bez uruchamiania klienta graficznego.

### Języki do testu (30 języków)

| Grupa | Języki | Skrypt |
|-------|--------|--------|
| Europejskie | pl, de, es, pt, fr, it | Latin |
| Cyrilica | ru, uk, bg, sr | Cyrillic |
| Greka | el | Greek |
| RTL | ar, he, fa | Arabic/Hebrew |
| CJK | zh, ja, ko | Han/Hiragana/Hangul |
| Indyjskie | hi, bn | Devanagari/Bengali |
| Azjatyckie | th, vi, id, ms | Thai/Latin |
| Inne | tr, hu, fi, sv, da, no | Latin |

### Plan działania

```
[ ] Krok 5.1: Przygotowanie sample tekstów dla każdego języka
[ ] Krok 5.2: Wysłanie sample do HarfBuzz offline
[ ] Krok 5.3: Weryfikacja czy shaping zwraca glify
[ ] Krok 5.4: Sprawdzenie kierunku (RTL vs LTR)
[ ] Krok 5.5: Test UV i szerokości kolumn atlasu
```

### Oczekiwany raport

1. ✔️ Lista języków nieobsłużonych przez font chain
2. ✔️ Lista języków obsłużonych częściowo (brakujące znaki)
3. ✔️ Informacja czy shaping RTL jest aktywny

### Sample teksty testowe

```lua
samples = {
  pl = "Zażółć gęślą jaźń — ąćęłńóśźż",
  ru = "Привет мир — кириллица",
  ar = "مرحبا بالعالم — العربية",
  he = "שלום עולם — עברית",
  zh = "你好，世界 — 中文",
  ja = "こんにちは世界 — 日本語",
  ko = "안녕하세요 세계 — 한국어",
  th = "สวัสดีโลก — ไทย",
  hi = "नमस्ते दुनिया — हिंदी",
  el = "Γειά σου Κόσμε — Ελληνικά"
}
```

### Status: ⏳ ZAPLANOWANE

---

## 🧩 WARSTWA 6 — Installer/Launcher Multi-Language Audit

### Cel
Weryfikacja wielojęzyczności instalatora i launchera.

### Pliki do analizy

1. **Launcher config:** `launcher_config.json` (jeśli istnieje)
2. **Instalator:** pliki `.xaml` w launcherze (jeśli istnieje)
3. **Komendy .NET/C#:** stringi w launcherze
4. **Ekran logowania:** `modules/client_entergame/*`

### Plan działania

```
[ ] Krok 6.1: Identyfikacja plików launchera/instalatora
[ ] Krok 6.2: Skanowanie tekstów hardcoded w XAML
[ ] Krok 6.3: Weryfikacja plików .resx dla tłumaczeń
[ ] Krok 6.4: Analiza client_entergame pod kątem tr()
[ ] Krok 6.5: Raport brakujących tłumaczeń launchera
```

### Oczekiwany raport

1. ✔️ Teksty twardo zaszyte w XAML
2. ✔️ Teksty launcherów bez tłumaczeń
3. ✔️ Pliki językowe dla launchera (.resx) — czy są, czy nie są

### Struktura client_entergame

```
modules/client_entergame/
├── entergame.lua         # Logika ekranu logowania
├── entergame.otmod       # Definicja modułu
└── entergame.otui        # UI ekranu logowania
```

### Status: ⏳ ZAPLANOWANE

---

## 📅 Harmonogram wykonania

| Warstwa | Priorytet | Czas szacowany | Status |
|---------|-----------|----------------|--------|
| Warstwa 1 | 🔴 Wysoki | 2-3 godziny | ⏳ W trakcie |
| Warstwa 2 | 🟡 Średni | 1-2 godziny | ⏳ Zaplanowane |
| Warstwa 3 | 🟡 Średni | 2-3 godziny | ⏳ Zaplanowane |
| Warstwa 4 | 🔴 Wysoki | 1-2 godziny | ⏳ Zaplanowane |
| Warstwa 5 | 🟢 Niski | 2-3 godziny | ⏳ Zaplanowane |
| Warstwa 6 | 🟢 Niski | 1 godzina | ⏳ Zaplanowane |

---

## 🔧 Narzędzia wymagane

### Dostępne w repozytorium
- ✅ Bash/shell scripts
- ✅ grep/awk/sed
- ✅ Python 3.x

### Do zainstalowania (opcjonalnie)
- ⚠️ fonttools (analiza TTF)
- ⚠️ HarfBuzz CLI (hb-view, hb-shape)
- ⚠️ FriBidi CLI (fribidi)

---

## 📝 Notatki

### Ograniczenia agenta AI

1. **Brak możliwości uruchomienia klienta graficznego** - symulacja offline tylko
2. **Brak dostępu do zewnętrznych narzędzi** - analiza oparta na parsowaniu tekstu
3. **Nie można instalować pakietów systemowych** - tylko dostępne narzędzia

### Co może być wykonane automatycznie

- ✅ Parsowanie plików .lua, .cpp, .h, .otui
- ✅ Porównywanie kluczy tłumaczeń
- ✅ Wyszukiwanie wzorców (grep)
- ✅ Generowanie raportów markdown

### Co wymaga manualnej interwencji

- ⚠️ Instalacja brakujących czcionek TTF
- ⚠️ Konfiguracja fallback chain
- ⚠️ Naprawa błędów formatowania w kodzie

---

## 📊 Postęp realizacji

| Data | Warstwa | Wykonane |
|------|---------|----------|
| 2025-12-06 | Plan | ✅ Utworzono plan analizy |
| - | 1 | ⏳ W trakcie wykonywania |
| - | 2 | ⏳ Zaplanowane |
| - | 3 | ⏳ Zaplanowane |
| - | 4 | ⏳ Zaplanowane |
| - | 5 | ⏳ Zaplanowane |
| - | 6 | ⏳ Zaplanowane |

---

*Dokument utworzony: 2025-12-06*
*Ostatnia aktualizacja: 2025-12-06*
