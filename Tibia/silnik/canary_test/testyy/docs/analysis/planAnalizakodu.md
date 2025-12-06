# Plan analizy kodu (issue #30)

## Założenia wstępne
- Zakres prac dotyczy repozytorium `Tibia/silnik/canary` na gałęzi `PtakuPL/issue30`.
- Analiza ma charakter tylko-odczyt: raportujemy problemy i braki, nie zmieniamy kodu ani zasobów.
- Wyniki z każdej warstwy będą dopisywane w dedykowanych sekcjach raportowych (poniżej) oraz w końcowym podsumowaniu PR.

## Konwencja raportowania
- Dla każdej warstwy opisujemy: **wejścia**, **metodę (kroki / narzędzia)**, **artefakty** i **status**.
- Jeżeli dane wejściowe są niekompletne (np. brak czcionek), odnotowujemy to w sekcji „Ryzyka / luki”.
- Wygenerowane listy/znalezione problemy zapisujemy w plikach raportowych w `docs/` lub w sekcji „Wyniki” poniżej.

## Plan warstwa-po-warstwie

### Warstwa 1 — Language Asset Auditor
- **Cel:** inwentaryzacja kluczy tłumaczeń i miejsc bez systemu tłumaczeń.
- **Wejście:**
  - Jeśli występują: `/data/locales/*.lua`, `/modules/**/locales/*.lua`, `/data/lang/*.json`.
  - Pliki UI: `**/*.otui`, `**/*.otml`.
  - Kody źródłowe z `tr("...")` w `.cpp/.h/.lua`.
- **Kroki / narzędzia:**
  1) Zebrać listę dostępnych plików locale i kluczy (skrypt w Pythonie/Lua + `rg`/`find`).
  2) Zidentyfikować użycia `tr("...")` oraz twardo zakodowane stringi w UI (`text="..."` w `.otui`, stringi w `.otml`).
  3) Zbudować macierz: klucz × język → brak/obecny; wylistować klucze nieużywane.
  4) Raportować brakujące klucze, nieużywane klucze, „hard-coded” teksty.
- **Artefakty:** `docs/raport_warstwa1.md` (lista braków, nieużyć, hard-coded UI/kod).
- **Ryzyka / luki:** możliwy brak folderów locale w głównym drzewie; jeśli tak, należy odnotować lokalizacje alternatywne (np. `canary_test/testyy/data/locales`).

### Warstwa 2 — Unicode Coverage Scanner (TTF)
- **Cel:** sprawdzenie pokrycia Unicode przez dostępne czcionki i łańcuch fallback.
- **Wejście:** `data/fonts/ttf/*.ttf`, pliki `.otfont` (jeśli są), konfiguracja fallback w kliencie.
- **Kroki / narzędzia:**
  1) Zainwentaryzować dostępne pliki TTF/OTF (lub potwierdzić ich brak w repo).
  2) Wydobyć zakresy Unicode (OS/2 `ulUnicodeRange`) narzędziem typu `ttx`/`otfinfo` (lub alternatywny parser Python).
  3) Zmapować czcionki na skrypty (LATN, CYRL, ARAB, HANI, itp.).
  4) Porównać pokrycie ze wspieranymi językami (lista z warstwy 1) i opisać brakujące skrypty / brak fallbacku.
- **Artefakty:** `docs/raport_warstwa2.md` (pokrycie skryptów, luki, zalecenia). 
- **Ryzyka / luki:** brak plików fontów w repo → raportujemy brak danych i potrzebę dostarczenia fontów/konfiguracji.

### Warstwa 3 — HarfBuzz/FriBidi Compliance Checker
- **Cel:** weryfikacja poprawnego użycia HarfBuzz/FriBidi w pipeline renderowania tekstu.
- **Wejście:** `TextShaper.cpp/.h`, `TTFFont.cpp/.h`, fragmenty `uilayout`, `uiwidgettext`, `uitextedit`, `drawpooltext` (lub odpowiedniki w repo).
- **Kroki / narzędzia:**
  1) Odszukać pliki odpowiedzialne za shaping/rendering tekstu i wywołania `hb_shape()`.
  2) Sprawdzić wykrywanie RTL (HB_DIRECTION_RTL), parametry script/lang, brak ścieżek ASCII-only.
  3) Zweryfikować, że atlas TTF trafia do DrawPool i nie ma pominięć dla stylów.
- **Artefakty:** `docs/raport_warstwa3.md` (lista braków/błędów implementacyjnych, luki w RTL/shaping).
- **Ryzyka / luki:** jeśli pliki shapingowe nie istnieją w repo, raportujemy lukę i wymagane materiały.

### Warstwa 4 — Code Safety & Format Consistency (fmt)
- **Cel:** wykrycie niebezpiecznych format stringów i niespójności z `{}`/`fmt`.
- **Wejście:** wszystkie `.cpp/.h/.lua`.
- **Kroki / narzędzia:**
  1) `rg` / skrypt do wykrycia `%s`, `%i`, `%d`, gołych `%` bez parametrów, gołych `{}` w stringach formatowanych.
  2) Zestawić listę miejsc do konwersji `%` → `{}` oraz potencjalnych mismatch parametrowych.
- **Artefakty:** `docs/raport_warstwa4.md` (lista plik:linia + sugerowana poprawka do fmt).
- **Ryzyka / luki:** brak — analiza w pełni statyczna.

### Warstwa 5 — Runtime Simulation (Dry Run)
- **Cel:** offline weryfikacja shapingu 30 języków (bez uruchamiania klienta graficznie).
- **Wejście:** czcionki z warstwy 2 + fragmenty tekstu 30 języków.
- **Kroki / narzędzia:**
  1) Przygotować próbki tekstów dla języków (w pliku testowym).
  2) Użyć HarfBuzz offline do shapingu i sprawdzić, czy zwracają glyphy oraz poprawny kierunek RTL/LTR.
  3) Raportować języki nieobsłużone lub częściowo obsłużone.
- **Artefakty:** `docs/raport_warstwa5.md` (tabela język → status glyphów / kierunku / pokrycia).
- **Ryzyka / luki:** brak czcionek lub brak zależności HB/FRIBIDI w środowisku → należy odnotować.

### Warstwa 6 — Installer/Launcher Multi-Language Audit
- **Cel:** audyt tłumaczeń instalatora/launchera.
- **Wejście:** `launcher_config.json`, pliki instalatora (`*.xaml`, `.resx`), stringi w `/modules/client_entergame`.
- **Kroki / narzędzia:**
  1) Zlokalizować pliki konfiguracyjne/instalatora w repo (lub potwierdzić ich brak w gałęzi).
  2) Sprawdzić twardo zakodowane teksty, brakujące tłumaczenia, brak plików językowych `.resx`.
  3) Raportować brakujące tłumaczenia / zasoby.
- **Artefakty:** `docs/raport_warstwa6.md` (lista miejsc w instalatorze z hard-coded tekstami / brakami tłumaczeń).
- **Ryzyka / luki:** jeżeli installer/launcher nie jest obecny w repo, należy to udokumentować i wskazać potrzebne pliki.

## Sekcja statusów (do uzupełniania podczas prac)
- Warstwa 1: ZAKOŃCZONE (raport: `docs/raport_warstwa1.md`)
- Warstwa 2: ZAKOŃCZONE (raport: `docs/raport_warstwa2.md`; brak fontów w drzewie produkcyjnym)
- Warstwa 3: ZAKOŃCZONE/Brak kodu renderera (raport: `docs/raport_warstwa3.md`)
- Warstwa 4: ZAKOŃCZONE (raport: `docs/raport_warstwa4.md`)
- Warstwa 5: BLOKADA — brak fontów + brak warstwy HarfBuzz/FriBidi (raport: `docs/raport_warstwa5.md`)
- Warstwa 6: BLOKADA — brak plików instalatora/launchera (raport: `docs/raport_warstwa6.md`)

## Notatki operacyjne
- Wszystkie raporty lokujemy w `docs/` dla łatwego przeglądu w PR.
- Analiza nie zmienia żadnych plików produkcyjnych; tylko dokumentacja/raporty.
