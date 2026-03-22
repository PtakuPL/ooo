# Kontrakt integracji z klientem

**ID:** LR-009  
**Status:** HISTORYCZNY / FROZEN
**Data:** 2026-03-02

> Uwaga 2026-03-15:
> Ten dokument opisuje starszy model integracji `launcher -> klient`.
> Nie jest juz kanonicznym zrodlem prawdy dla finalnego pipeline.
> Aktualne dokumenty nadrzedne:
> - [15_MASTER_PLAN_LAUNCHER_INSTALKA_FINALNY_PIPELINE.md](/home/ptaku/serweryt/Tibia/silnik/Dokumentacja/01_Instalka_Klient/2026-03/15_MASTER_PLAN_LAUNCHER_INSTALKA_FINALNY_PIPELINE.md)
> - [15_PLAN_MINIMALNA_INSTALKA_GRACZA_I_PLAYER_RUNTIME.md](/home/ptaku/serweryt/Tibia/silnik/Dokumentacja/01_Instalka_Klient/2026-03/15_PLAN_MINIMALNA_INSTALKA_GRACZA_I_PLAYER_RUNTIME.md)
> - [15_ARCHITEKTURA_LAUNCHER_KLIENT_KONTRAKTY.md](/home/ptaku/serweryt/Tibia/silnik/Dokumentacja/01_Instalka_Klient/2026-03/15_ARCHITEKTURA_LAUNCHER_KLIENT_KONTRAKTY.md)
>
> Najwazniejsze rozjazdy wzgledem obecnego stanu:
> - launcher przekazuje `OTC_LAUNCH_TOKEN`, `OTC_CHANNEL`, opcjonalny `OTC_ACCOUNT` i `OTC_SESSION_TOKEN` zamiast `OTC_PASSWORD`,
> - `launch_game()` nie przekazuje juz `OTC_GAME_MODE`; wybor trybu pozostaje po stronie klienta,
> - finalny produkt nie zaklada juz recznego logowania klienta jako glownego UX dla gracza.

## Cel

Definicja interfejsu między launcherem a klientem OTClient.
Launcher odpowiada za update, integralność i start — klient za login, wybór świata/postaci i grę.

## Ścieżka klienta

Launcher zna ścieżkę klienta z:
- `installed_state.json` → `clientInstallPath`
- `launcher_settings.json` → nadpisanie użytkownika

## Plik wykonywalny klienta

| Platforma | Nazwa pliku | Uwagi |
|-----------|------------|-------|
| Windows | `otclient.exe` | Główna binarka |
| Linux | `otclient` | Ustawić +x po pobraniu |

Launcher znajduje exe: `{clientInstallPath}/{clientExe}`

## Przekazywanie launch-token

**JEDYNA metoda:** zmienna środowiskowa `OTC_LAUNCH_TOKEN`

```
OTC_LAUNCH_TOKEN=550e8400-e29b-41d4-a716-446655440000
```

**ZABRONIONE:**
- Argument CLI (widoczny w `ps aux`)
- Plik tymczasowy
- Pipe/socket (zbyt skomplikowane, nie warte)
- Schowek / clipboard

## Zmienne środowiskowe

| Zmienna | Typ | Wymagane | Opis |
|---------|-----|----------|------|
| `OTC_LAUNCH_TOKEN` | string (UUID) | TAK | Jednorazowy launch-token |

Opcjonalne (przyszłość):
| Zmienna | Typ | Opis |
|---------|-----|------|
| `OTC_CHANNEL` | string | Kanał (stable/test/dev) — informacyjne |
| `OTC_LAUNCHER_VERSION` | string | Wersja launchera — diagnostyczne |

## Flow uruchamiania

1. Launcher kończy update + filesHash + token
2. Launcher ustawia env: `OTC_LAUNCH_TOKEN={token}`
3. Launcher uruchamia proces klienta
4. Klient startuje, odczytuje `OTC_LAUNCH_TOKEN` z env
5. Klient wyświetla ekran logowania (wybór serwera, login, hasło)
6. Klient wysyła token do `login.php` i kontynuuje flow

## Czego launcher NIE robi

- NIE wybiera świata (to robi klient)
- NIE loguje gracza (to robi klient → login.php)
- NIE wysyła ticketów (to robi klient → ticket.php)
- NIE dotyka protokołu gry (to robi klient ↔ Canary)
- NIE modyfikuje UI klienta w runtime

## Czego klient NIE robi

- NIE sprawdza aktualizacji (to robi launcher)
- NIE pobiera plików (to robi launcher)
- NIE liczy filesHash (to robi launcher)
- NIE wyświetla progress update (to robi launcher)

## Synchronizacja listy serwerów

Launcher zapisuje listę serwerów do plików klienta:
- `init.lua` / `ServerList` / konfiguracja wg implementacji klienta
- Dane z `manifest.servers[]` lub z osobnego API
- Gracz NIE edytuje listy ręcznie (klient: locked)
- Wybór serwera odbywa się w kliencie z dostarczonej listy

## Monitorowanie procesu (opcjonalne)

Launcher MOŻE monitorować:
- Czy proces klienta się uruchomił (PID check)
- Exit code po zakończeniu
- Crash detection (exit code != 0)

Launcher NIE blokuje interfejsu — po uruchomieniu klienta może się zamknąć lub pozostać w tle.

## Diagram

```
┌─────────────┐     env: OTC_LAUNCH_TOKEN     ┌─────────────┐
│   Launcher   │ ─────────────────────────────▶ │   OTClient   │
│  (Rust+Tauri)│                                │   (C++/Lua)  │
│              │   update files, serverlist      │              │
│  update.php  │───────────────────────────────▶│  login.php   │
│  token.php   │                                │  ticket.php  │
│  version.php │                                │  ↔ Canary    │
└─────────────┘                                └─────────────┘
```
