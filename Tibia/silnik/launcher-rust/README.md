# Launcher Rust — RedDAXE Game Launcher

> Zintegrowany launcher gry w Rust z Tauri v2 frontendem. Dwupoziomowa dystrybucja:
> lekki bootstrap (~KB) instaluje pełny launcher (~MB), który pobiera klienta gry (~GB).

---

## Architektura — 3 warstwy dystrybucji

```
┌─────────────────────────────────┐
│  WARSTWA 1: Bootstrap (~KB)     │  ← Gracz pobiera ze strony
│  launcher-bootstrap             │     Jednorazowy: pobierz → uruchom → czekaj
│  Rust + reqwest(blocking)       │
└──────────────┬──────────────────┘
               │ GET /apik/v1/installer-catalog.php?type=launcher
               ▼
┌─────────────────────────────────┐
│  WARSTWA 2: Pełny Launcher     │  ← Zarządza grą, aktualizacjami, logowaniem
│  launcher-tauri (Tauri v2)      │     Self-update, ticket-gate, i18n (5 języków)
│  Rust backend + HTML/JS/CSS     │
└──────────────┬──────────────────┘
               │ GET manifest → download → verify → extract
               ▼
┌─────────────────────────────────┐
│  WARSTWA 3: Klient gry         │  ← GOTOWE BINARKI ze serwera artefaktów
│  OTClient + dane (sprite, map)  │     Launcher NIE kompiluje — tylko pobiera
│  ~100-500 MB                    │
└─────────────────────────────────┘
```

**Launcher pobiera GOTOWE, skompilowane paczki gry. NIE kompiluje niczego.**

---

## Workspace — 7 crate'ów

```
launcher-rust/
├── Cargo.toml                     # Workspace root
├── Cargo.lock
├── apps/
│   ├── launcher-bootstrap/        # WARSTWA 1: Lekki downloader (~KB)
│   │   └── src/ (main, downloader, installer, platform, ui)
│   ├── launcher-cli/              # CLI narzędzie diagnostyczne
│   └── launcher-tauri/            # WARSTWA 2: Pełny launcher (Tauri v2)
│       ├── src/ (Rust backend: commands, state)
│       ├── frontend/ (HTML/JS/CSS)
│       └── icons/ (32x32, 128x128, ico)
├── crates/
│   ├── common-models/             # DTOs, validation, LauncherConfig
│   ├── launcher-api/              # HTTP client (reqwest/rustls)
│   ├── launcher-core/             # 17 modułów logiki
│   └── launcher-helper/           # Self-update helper binary
├── docs/
│   └── contracts/                 # 14 kontraktów API/systemu
└── tests/                         # Integration tests
```

## Key Features

- **Ticket-Gate**: Bezpieczne łączenie klienta gry z serwerem (HMAC-SHA256 token)
- **i18n**: 5 języków (PL, EN, AR, HE, FA) z RTL support
- **Self-Update**: Helper binary aktualizuje launcher w tle
- **SHA-256 Verification**: Każdy pobrany artefakt weryfikowany przed użyciem
- **Social OAuth**: Google, Facebook, Steam login
- **Challenge-Response**: Nonce-based auth dla launcher-token

## Profil kompilacji

```toml
[profile.release]
opt-level = "z"        # Optymalizacja pod rozmiar
lto = true             # Link-Time Optimization
strip = true           # Strip debug symbols
codegen-units = 1      # Lepsze LTO
panic = "abort"        # Mniejszy runtime
```

## GitHub Actions Workflows

| Workflow | Plik | Opis |
|----------|------|------|
| Launcher CI | `launcher-ci.yml` | fmt + clippy + test (Ubuntu + Windows) |
| Build Launcher | `build-launcher.yml` | Release build CLI + Tauri + Helper |
| Release Launcher | `release-launcher.yml` | Tag-based release z checksums |
| Build Bootstrap | `build-bootstrap-launcher.yml` | Build bootstrap (~KB) Win + Linux |

## API Endpoints

| Endpoint | Opis |
|----------|------|
| `installer-catalog.php?type=launcher` | Katalog artefaktów launchera |
| `installer-catalog.php?type=bootstrap` | Katalog bootstrap launchera |
| `artifacts-health.php` | Health-check plików do pobrania |
| `launcher-version.php` | Sprawdzenie najnowszej wersji |
| `launcher-token.php` | Generowanie tokenu do gry |
| `login.php` | Logowanie konta globalnego |

## Dokumentacja

- [LAUNCHER_PLAN.md](../Dokumentacja/01_Instalka_Klient/LAUNCHER_PLAN.md) — Master plan z zadaniami
- [ADR-001: Dwupoziomowa dystrybucja](../Dokumentacja/01_Instalka_Klient/ADR-001_dwupoziomowa_dystrybucja.md)
- [docs/contracts/](docs/contracts/) — 14 kontraktów API i systemu
