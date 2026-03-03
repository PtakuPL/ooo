# Thin Frontend — zasady bezpieczeństwa UI (LR-080)

## Cel
Tauri frontend (HTML/CSS/JS) **nie** zawiera żadnej logiki bezpieczeństwa,
kryptografii, walidacji manifestu ani decyzji dotyczących integralności plików.
Cała logika domenowa żyje w Rust backend (launcher-core + common-models).

---

## Reguły

### 1. Frontend = widok + input
- Wyświetla status (faza, progres, błędy) otrzymany z backendu.
- Zbiera akcje użytkownika (start, retry, repair, zmiana kanału).
- **Nie** przetwarza danych, nie liczy hashy, nie parsuje JSON manifestu.

### 2. Komunikacja: Tauri Commands
Frontend wywołuje wyłącznie zdefiniowane Tauri commands:

| Command | Opis | Zwraca |
|---------|------|--------|
| `get_status` | Aktualny status launchera | `LauncherStatusDto` |
| `check_for_updates` | Sprawdza manifest | `UpdatePlanSummaryDto` |
| `start_update` | Rozpoczyna aktualizację | stream `UpdateProgressDto` |
| `launch_game` | Startuje klienta | `Result<(), ErrorInfoDto>` |
| `repair_installation` | Naprawa plików | `RepairDiagnosticsDto` + stream |
| `get_installation_info` | Podsumowanie stanu | `InstallationSummaryDto` |
| `change_channel` | Zmiana kanału | `Result<(), ErrorInfoDto>` |
| `export_logs` | Archiwum logów | ścieżka do ZIP |

### 3. DTO — jedyny kontrakt z frontendem
- Struktury DTO (moduł `common_models::dto`) to jedyne typy widoczne dla UI.
- Żadna surowa struktura (`NormalizedManifest`, `InstalledState`, `UpdatePlan`) nie trafia do frontendu.
- DTO mają `camelCase` klucze JSON (standard JS/TS).

### 4. Tauri allowlist (przyszłe `tauri.conf.json`)
```json
{
  "tauri": {
    "allowlist": {
      "all": false,
      "shell": { "open": false },
      "fs": { "all": false },
      "http": { "all": false },
      "dialog": { "open": true, "save": true },
      "notification": { "all": true }
    }
  }
}
```
- `fs`, `http`, `shell` — **wyłączone** dla ipcMain.
- Sieć (HTTP) odbywa się **tylko** przez Rust (`reqwest` w `launcher-api`).
- System plików — **tylko** przez Rust (`patcher`, `state`, `integrity`).

### 5. Walidacja na granicy
- Każdy Tauri command waliduje argumenty po stronie Rust.
- Błędy zwracane jako `ErrorInfoDto` z kodem LCH_* i `user_message`.
- Frontend wyświetla `user_message` — nie interpretuje kodu.

### 6. Brak sekretów w UI
- Token nigdy nie trafia do frontendu (używany tylko w Rust do env/pipe klienta gry).
- `filesHash` widoczny jedynie jako skrót w `InstallationSummaryDto`.
- API base URL nie jest edytowalny z UI (konfiguracja lokalna / CLI).

---

## Diagram przepływu

```
┌─────────────────────────────┐
│  Tauri Frontend (webview)   │
│  HTML/CSS/JS — czysto UI    │
│  ┌─────────┐ ┌───────────┐  │
│  │ Ekran   │ │ Ekran     │  │
│  │ statusu │ │ update'u  │  │
│  └────┬────┘ └─────┬─────┘  │
│       │ invoke()   │         │
└───────┼────────────┼─────────┘
        │ IPC        │ IPC
┌───────┼────────────┼─────────┐
│  Rust Backend (Tauri cmds)   │
│  ┌────▼────────────▼─────┐   │
│  │   Command handlers    │   │
│  │   (thin wrappers)     │   │
│  └──────────┬────────────┘   │
│             │                │
│  ┌──────────▼────────────┐   │
│  │   launcher-core       │   │
│  │   (cała logika)       │   │
│  └───────────────────────┘   │
└──────────────────────────────┘
```

## Testowanie
- DTO serde testy: `common-models/src/dto.rs` (13 testów).
- Contract testy DTO: przyszły `tests/dto_contract_tests.rs`.
- Tauri integration: mockowe komendy + snapshot JSON.
