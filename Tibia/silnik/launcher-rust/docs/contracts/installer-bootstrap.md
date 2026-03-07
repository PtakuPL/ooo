# Kontrakt: Model instalatora bootstrap

**ID:** LR-041  
**Status:** zaktualizowany (BL-30)  
**Data:** 2026-03-03  
**Aktualizacja:** 2026-03-07 — nowy model: lekki launcher bootstrap (~KB)

## Cel

Bootstrap launcher to **minimalny plik** (~50-300 KB), pobierany ze strony RedDaxe.pl,
którego jedynym zadaniem jest pobranie i zainstalowanie pełnego launchera (Tauri ~3-5 MB).
Po instalacji pełny launcher samodzielnie pobiera klienta gry.

> **⚠️ ZMIANA:** Poprzedni model zakładał instalator ~10-50 MB zawierający binarkę launchera.
> Nowy model: lekki bootstrap (~KB) pobiera pełny launcher z API (jak plik .torrent).

## Trzy warstwy dystrybucji

| Warstwa | Byt | Rozmiar | Kto go pobiera | Źródło |
|---|---|---|---|---|
| 1 | **Bootstrap** (lekki launcher) | ~50-300 KB | Gracz ze strony RedDaxe.pl | GHA build → serwer artefaktów |
| 2 | **Pełny Launcher** (Tauri) | ~3-5 MB | Bootstrap z `installer-catalog.php?type=launcher` | GHA build → serwer artefaktów |
| 3 | **Klient gry** (OTClient + dane) | ~100-500 MB | Pełny launcher z manifest API | **GOTOWE BINARKI** — skompilowane osobno, wrzucone do bazy |

> **Launcher NIE kompiluje klienta gry.** Pobiera GOTOWE, skompilowane paczki z serwera artefaktów.

## Flow użytkownika

```
1. Gracz wchodzi na RedDaxe.pl → klika "Pobierz grę"
2. Pobiera lekki bootstrap (~50-300 KB)
3. Uruchamia bootstrap
4. Bootstrap:
   a. GET /apik/v1/installer-catalog.php?channel=stable&type=launcher
   b. Sprawdza platform/arch
   c. Pobiera pełny launcher (~3-5 MB) z progress barem
   d. Weryfikuje SHA-256
   e. Rozpakowuje do docelowego katalogu
   f. Tworzy launcher_config.json
   g. Uruchamia pełny launcher
   h. Zamyka się (jednorazowe użycie)
5. Pełny launcher startuje:
   a. Self-update check
   b. Login/rejestracja
   c. Pobiera GOTOWĄ paczkę klienta gry z manifestu (~100-500 MB)
   d. Gracz gra
```

## Technologia bootstrap

- **Rust** + reqwest(blocking) + sha2 + zip — cele: < 500 KB
- **Brak** tokio/async — blocking HTTP (bez runtime = mniejsza binarka)
- **Brak** launcher-core, launcher-api — bootstrap jest autonomiczny
- **Brak** Tauri — to nie GUI app z WebView, to minimalny downloader
- **Profile release:** opt-level="z", lto=true, strip=true, codegen-units=1, panic="abort"

## Kod źródłowy

```
launcher-rust/apps/launcher-bootstrap/
├── Cargo.toml
└── src/
    ├── main.rs          (entry point + orchestracja)
    ├── downloader.rs    (HTTP GET + progress + SHA-256 + retry 3x)
    ├── installer.rs     (rozpakowanie ZIP, config, detekcja)
    ├── platform.rs      (Windows/Linux detekcja, ścieżki)
    └── ui.rs            (console progress + Win32 MessageBox)
```

## Struktura katalogu po instalacji

```
C:\SerwerCanary\
├── Launcher.exe             # Glowna aplikacja (Tauri)
├── LauncherHelper.exe       # Helper do self-update (Etap 4)
├── launcher_config.json     # Minimalna konfiguracja
├── launcher_data/
│   ├── installed_state.json # Stan instalacji
│   ├── staging/             # Pliki tymczasowe update
│   └── logs/                # Logi launchera
└── client/                  # Klient gry (pobierany przez launcher)
    ├── otclient.exe
    ├── data/
    └── ...
```

## launcher_config.json (bootstrap config)

```json
{
  "api_base_url": "https://api.serwercanary.pl/client/",
  "channel": "stable",
  "launcher_version_check": true,
  "client_dir": "client",
  "launcher_data_dir": "launcher_data"
}
```

### Pola

| Pole | Typ | Wymagane | Opis |
|---|---|---|---|
| `api_base_url` | string | TAK | Bazowy URL API launchera |
| `channel` | string | TAK | Domyslny kanal: stable / test / dev |
| `launcher_version_check` | bool | NIE | Czy sprawdzac wersje launchera (default: true) |
| `client_dir` | string | NIE | Sciezka katalogu klienta (wzgledna do exe, default: "client") |
| `launcher_data_dir` | string | NIE | Sciezka katalogu danych launchera (default: "launcher_data") |

## Wymagania instalatora

1. **Minimalnosc**: Installer nie pobiera klienta gry. To robi launcher.
2. **Idempotentnosc**: Ponowne uruchomienie instalatora nie psuje istniejacego state.
3. **Detekcja istniejaceji instalacji**: Sprawdza czy katalog istnieje; pyta o nadpisanie.
4. **Nie nadpisuje plikow uzytkownika**: Pliki konfiguracyjne sa tworzone tylko jesli nie istnieja.
5. **Kompatybilnosc**: Windows 10+ (WebView2 runtime), Linux (GTK3 / WebKitGTK).

## Wariant hybrydowy (opcjonalny)

Dla lepszego UX przy slow internet:
- Installer moze zawierac minimalny snapshot klienta (ostatni stabilny build)
- Launcher po pierwszym starcie robi tylko "dogranie roznic" (delta update)
- To nie zmienia architektury — skraca tylko pierwszy update

## Podpisywanie instalatora

1. Installer musi byc podpisany (Windows: Authenticode / Linux: GPG .sig)
2. SHA-256 hash dostepny w `installer-catalog.php`
3. Uzytkownicy moga zweryfikowac hash recznie lub przez Download Center w launcherze

## Integracja z launcher-version.php

Po zainstalowaniu, launcher sprawdza `launcher-version.php`:
- Jesli `required=true` i lokalna wersja < `minVersion` → wymuszony self-update
- Jesli `required=false` → soft-update (propozycja)
- Flow: installer → launcher start → version check → (opcjonalnie self-update) → klient update → gra

## Dezinstalacja

1. Installer tworzy wpis w "Dodaj/usun programy" (Windows) lub skrypt uninstall (Linux)
2. Dezinstalacja usuwa: Launcher.exe, LauncherHelper.exe, launcher_config.json, skrot
3. Dezinstalacja NIE USUWA: katalogu client/ (uzytkownik moze chciec zachowac pliki gry)
4. Opcjonalnie: "Usun wszystko" usuwa takze client/ i launcher_data/
