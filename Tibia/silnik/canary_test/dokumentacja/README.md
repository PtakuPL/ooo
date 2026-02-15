# Dokumentacja projektu Canary / OTClient

Ten katalog zawiera centralną dokumentację dla projektu składającego się z:
- **Serwera Canary** - emulator serwera MMORPG (bazowany na OpenTibiaBR/canary)
- **Klienta OTClient** - klient gry z obsługą TTF, i18n, HarfBuzz (testyy/)

## Struktura dokumentacji

```
docs/
├── README.md                 # Ten plik - przegląd dokumentacji
├── ARCHITECTURE.md           # Architektura kodu (klient)
├── BUILD_GUIDE.md            # Instrukcje kompilacji
├── CHANGELOG.md              # Historia zmian (główna)
├── AGENT_HANDOFF.md          # Szablon przekazywania prac między agentami (Issue #30)
├── DEPENDENCIES.md           # Zależności projektu
├── MODULES.md                # Opis modułów klienta
├── SOURCE_CODE.md            # Przegląd kodu źródłowego
│
├── ci-cd/                    # Status i błędy CI/CD
│   ├── build-status.md       # Aktualny status buildów
│   ├── ci-errors.md          # Kompletny raport błędów CI
│   ├── CI_STATUS.md          # Szczegóły statusu workflow
│   ├── errory-actions.md     # Logi błędów GitHub Actions
│   ├── bledykompilacji.md    # Błędy kompilacji (PL)
│   └── bledyw.md             # Błędy workflow (PL)
│
├── i18n/                     # Internacjonalizacja
│   ├── I18N_SUMMARY.md       # Podsumowanie i18n
│   ├── I18N_Progress.md      # Postęp prac i18n
│   ├── I18N_Next_Steps.md    # Następne kroki i18n
│   └── TEXT_RENDERING.md     # Renderowanie tekstu (TTF/HarfBuzz)
│
├── analysis/                 # Analiza kodu (Issue #30)
│   ├── planAnalizakodu.md    # Plan 6-warstwowej analizy
│   ├── raport_warstwa1.md    # Language Asset Auditor
│   ├── raport_warstwa2.md    # Unicode Coverage Scanner
│   ├── raport_warstwa3.md    # HarfBuzz/FriBidi Compliance
│   ├── raport_warstwa4.md    # Code Safety & Format
│   ├── raport_warstwa5.md    # Runtime Simulation
│   └── raport_warstwa6.md    # Installer/Launcher Audit
│
├── project/                  # Historia i plany projektu
│   ├── historia-projektu.md  # Chronologia rozwoju
│   ├── ogolny-opis-modyfikacji.md  # Różnice vs. upstream
│   ├── plany-na-przyszlosc.md      # Roadmapa
│   └── problemy-i-rozwiazania.md   # Napotkane problemy + fix
│
└── archive/                  # Archiwalne logi i notatki
    ├── worklog_all.md        # Dziennik prac
    ├── wykonane_zadania.md   # Lista zakończonych zadań
    ├── plan.md               # Stary plan rozwoju
    ├── WszystkieSRCLOG.md    # Zebrane logi zmian w src
    ├── changelog-sessions.md # Log sesji naprawczych
    └── analiza copilota.md   # Notatki z pracy z AI
```

## Szybki start

### Budowanie projektu

- **Linux**: Zobacz [BUILD_GUIDE.md](BUILD_GUIDE.md)
- **Windows**: Zobacz [../BUILD_WINDOWS.md](../BUILD_WINDOWS.md)
- **Docker**: Zobacz [../docker/DOCKER.md](../docker/DOCKER.md)

### Status CI/CD

| Platforma | Status |
|-----------|--------|
| Linux (Ubuntu) | ✅ Działa |
| Windows (MSVC) | ⏳ Czeka na rerun |
| Emscripten (WASM) | ⏳ Naprawione |
| Android | ⏳ Naprawione |

Szczegóły: [ci-cd/build-status.md](ci-cd/build-status.md)

### Internacjonalizacja (i18n)

Projekt obsługuje **53 języki** z pełnym wsparciem dla:
- Skryptów RTL (arabski, hebrajski, perski)
- CJK (chiński, japoński, koreański)
- Cyrylica, grecki, łaciński

Szczegóły: [i18n/I18N_SUMMARY.md](i18n/I18N_SUMMARY.md)

## Powiązane dokumenty

- [../README.md](../README.md) - Główny README klienta
- [../../README.md](../../README.md) - README serwera Canary
- [../../canary/docs/](../../canary/docs/) - Dokumentacja upstream serwera

## Ostatnia aktualizacja

**Data:** 2025-12-06  
**Gałąź:** `PtakuPL/issue30`
