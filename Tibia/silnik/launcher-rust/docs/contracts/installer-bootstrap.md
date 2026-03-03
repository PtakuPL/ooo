# Kontrakt: Model instalatora bootstrap

**ID:** LR-041  
**Status:** zamrozony  
**Data:** 2026-03-03

## Cel

Instalator bootstrap to maly plik (~10-50 MB), ktory instaluje launcher na nowej
maszynie. Nie jest odpowiedzialny za aktualizacje klienta gry — to robi launcher.

## Trzy byty w systemie

| Byt | Opis | Rozmiar | Kto go pobiera |
|---|---|---|---|
| Installer bootstrap | Instaluje launcher + minimalny config | ~10-50 MB | Uzytkownik recznie (ze strony / Download Center) |
| Launcher | Zarzadza gra: update, token, start klienta | ~5-20 MB | Installer go instaluje; potem sam sie aktualizuje |
| Klient gry (OTClient + dane) | Wlasciwa gra | ~100-500 MB | Launcher go pobiera i patchuje |

## Flow uzytkownika

```
1. Uzytkownik pobiera installer ze strony / Download Center
2. Installer tworzy katalog instalacji
3. Installer kopiuje: Launcher.exe + launcher_config.json
4. Installer tworzy skrot na pulpicie
5. Installer uruchamia launcher
6. Launcher sprawdza wersje -> pobiera klienta -> gotowy do gry
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
