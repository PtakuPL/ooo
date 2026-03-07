# ADR-001: Dwupoziomowa dystrybucja launchera (Bootstrap + Pełny Launcher)

**Data:** 2026-03-07  
**Status:** zaakceptowane  
**Dotyczy:** BL-32, SYS-A08

---

## Kontekst

Mamy do dystrybucji 3 warstwy oprogramowania:
1. **Pełny launcher** (Tauri/Rust) — ~3-5 MB — zarządza grą, aktualizacjami, logowaniem
2. **Klient gry** (OTClient + dane) — ~100-500 MB — właściwa gra
3. **Punkt wejścia** — to, co gracz pobiera ze strony

Pytanie: jakie powinno być to pierwsze pobranie?

## Rozważane opcje

### A) Pełny launcher jako jedyny punkt wejścia (~3-5 MB)
- Gracz pobiera pełny launcher bezpośrednio
- **+** Prosta architektura, jeden artefakt
- **−** 3-5 MB to dużo na "kliknij i czekaj" na wolnym łączu
- **−** Każda aktualizacja launchera = gracz pobiera nowy plik ręcznie (self-update rozwiązuje to częściowo)

### B) Lekki bootstrap launcher (~50-300 KB) → Pełny launcher
- Gracz pobiera mini-plik podobny do .torrent
- Bootstrap automatycznie pobiera pełny launcher
- **+** Ultra-szybkie pobranie ze strony (<1 sek.)
- **+** Pełny launcher może się aktualizować bez ingerencji gracza
- **+** Gracz nie musi wracać na stronę po aktualizacjach
- **−** Dodatkowa warstwa do utrzymania
- **−** Wymaga API katalogu artefaktów

### C) Klasyczny instalator (NSIS/WiX, ~10-50 MB)
- Tradycyjny setup wizard z UAC
- **+** Znany UX na Windows
- **−** Duży plik do pobrania
- **−** Wymaga admina (UAC)
- **−** Osobny toolchain (NSIS/WiX), nie Rust

## Decyzja

**Opcja B: Lekki bootstrap launcher.**

## Uzasadnienie

1. **Minimalny próg wejścia** — gracz pobiera ~200 KB zamiast 3-5 MB
2. **Brak UAC** — instalacja w folderze usera (`%LOCALAPPDATA%` / `~/Games/`)
3. **Jednorazowy** — po instalacji pełnego launchera bootstrap nie jest już potrzebny
4. **Self-update** — pełny launcher sam się aktualizuje, gracz nie wraca na stronę
5. **Ten sam język** — Rust, ten sam workspace, te same narzędzia CI/CD
6. **Bezpieczeństwo** — SHA-256 weryfikacja, HTTPS only, bez admina, bez stored credentials

## Konsekwencje

- Nowy crate `launcher-bootstrap` w workspace (autonomiczny, bez launcher-core)
- Nowy workflow GHA `build-bootstrap-launcher.yml`
- API `installer-catalog.php` rozszerzone o `?type=bootstrap`
- Strona RedDaxe.pl zaktualizowana — bootstrap jako główny przycisk "Pobierz grę"
- Deploy script (`deploy_bootstrap.sh`) do publikacji binarek na serwerze

## Powiązane zadania

- BL-01..BL-10: Kod bootstrap launchera
- BL-11..BL-14: Workflow GHA
- BL-15..BL-18: API
- BL-19..BL-23: Strona WWW
- BL-30..BL-33: Dokumentacja i kontrakty
