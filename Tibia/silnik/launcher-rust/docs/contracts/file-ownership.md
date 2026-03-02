# Polityka plików: managed vs user-owned

**ID:** LR-008  
**Status:** FROZEN  
**Data:** 2026-03-02

## Cel

Jednoznaczne określenie, które pliki launcher może nadpisywać, usuwać lub ignorować.

## Kategorie plików

### 1. Managed (zarządzane przez launcher)

Pliki wymienione w manifeście z `managed=true`. Launcher ma pełną kontrolę.

**Przykłady:**
- `otclient.exe` / `otclient` — binarka klienta
- `*.dll` — biblioteki klienta
- `modules/**/*.lua` — moduły UI klienta
- `modules/**/*.otui` — definicje interfejsu
- `data/**` — assety gry (sprites, dat, spr)
- `init.lua` — konfiguracja startowa klienta

**Zasady:**
- Launcher MOŻE nadpisać wg `overwritePolicy`
- Launcher MOŻE usunąć jeśli manifest zawiera `action=delete`
- Uczestniczą w `filesHash` jeśli `includeInFilesHash=true`
- Backup przed podmianą (w staging/backup)

### 2. User-owned (pliki użytkownika)

Pliki, które użytkownik może modyfikować. Launcher ich NIE dotyka.

**Przykłady:**
- `userdata/settings_local.json` — ustawienia lokalne gracza
- `userdata/hotkeys.json` — konfiguracja klawiszy
- `userdata/*.cfg` — inne preferencje
- `screenshots/**` — screenshoty
- `logs/**` — logi klienta (inne niż logi launchera)

**Zasady:**
- Launcher NIGDY nie nadpisuje
- Launcher NIGDY nie usuwa
- NIE uczestniczą w `filesHash`
- W manifeście: `managed=false`, `overwritePolicy="never"`, `deletePolicy="protect"`

### 3. Launcher-internal (pliki wewnętrzne launchera)

Pliki tworzone i zarządzane wyłącznie przez launcher.

**Przykłady:**
- `.launcher/installed_state.json` — stan instalacji
- `.launcher/launcher_settings.json` — ustawienia launchera
- `.launcher/staging/**` — pliki tymczasowe podczas update
- `.launcher/backup/**` — backup plików przed update
- `.launcher/logs/**` — logi launchera

**Zasady:**
- Tworzone przez launcher
- Nie w manifeście (nie są częścią klienta)
- Nie w `filesHash`
- `.launcher/staging/` — czyszczony po udanym update

### 4. Unknown (nieznane)

Pliki w katalogu instalacji, które NIE są w manifeście i NIE są w kategorii launcher-internal.

**Przykłady:**
- Pliki dodane ręcznie przez użytkownika
- Pliki z poprzednich wersji, które nie mają wpisu `action=delete`

**Zasady:**
- Launcher NIE RUSZA (MVP — brak agresywnego orphan cleanup)
- Logowanie ostrzeżenia w trybie diagnostycznym
- W przyszłości (v2+): opcjonalny orphan cleanup z potwierdzeniem użytkownika

## Macierz decyzyjna

| Sytuacja | Managed | User-owned | Unknown |
|----------|---------|------------|---------|
| Plik zmieniony w manifeście | Nadpisz (wg policy) | NIE | NIE |
| Plik usunięty z manifestu | action=delete → usuń | NIE | NIE |
| Plik nie w manifeście | N/A | Zostaw | Zostaw |
| Plik uszkodzony (hash mismatch) | Re-download | Zostaw | Zostaw |
| Repair install | Re-download wszystkie | Zostaw | Zostaw |

## Flagi w manifeście — podsumowanie

| Flaga | Wartość | Zastosowanie |
|-------|---------|-------------|
| `managed=true` | domyślna | Pliki klienta zarządzane |
| `managed=false` | jawna | Pliki user-owned w manifeście (info only) |
| `overwritePolicy="if_hash_differs"` | domyślna | Nadpisz gdy hash inny |
| `overwritePolicy="never"` | jawna | Pliki user-owned |
| `overwritePolicy="preserve_user"` | jawna | Managed, ale szanuj lokalne zmiany |
| `deletePolicy="protect"` | domyślna | Nie usuwaj automatycznie |
| `deletePolicy="allow"` | jawna | Można usunąć gdy action=delete |
| `includeInFilesHash=true` | domyślna | Uczestniczy w integralności |
| `includeInFilesHash=false` | jawna | Wyłącz z filesHash (pliki pomocnicze) |
