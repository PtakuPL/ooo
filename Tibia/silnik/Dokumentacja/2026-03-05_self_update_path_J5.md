# J5 — Ścieżka self-update launchera jako jedyny kanał dystrybucji

**Data:** 2026-03-06  
**Gałąź:** `feature/ticket-gate`  
**Status:** ✅ Potwierdzone — mechanizm zaimplementowany

---

## 1. Decyzja architektoniczna

**Jedyna ścieżka dystrybucji poprawek launchera dla graczy to mechanizm self-update.**

Gracz NIE powinien:
- ❌ Ręcznie pobierać nowy launcher ze strony
- ❌ Reinstalować launcher od zera
- ❌ Kopiować plików launchera z innego komputera

Gracz POWINIEN:
- ✅ Uruchomić launcher → launcher sam sprawdzi wersję → zaproponuje/wymusi aktualizację

---

## 2. Flow self-update (LR-048..051)

```
┌─────────────────────────────┐
│  LAUNCHER (start)           │
│  ↓                          │
│  check_launcher_update()    │ ← GET launcher-version.php
│  ↓                          │
│  Porównanie wersji:         │
│  ┌───────────────────────┐  │
│  │ UpToDate → kontynuuj  │  │
│  │ UpdateAvailable →     │──┼─→ Propozycja w UI (przycisk "Aktualizuj")
│  │ UpdateRequired →      │──┼─→ Hard block — nie da się kontynuować bez update
│  └───────────────────────┘  │
│                             │
│  perform_self_update():     │
│  1. Pobierz ZIP z url       │ ← download_file(url)
│  2. Weryfikuj SHA-256       │ ← verify_self_update_package(data, sha256)
│  3. Stage do staging/       │ ← stage_self_update_package(data, staging_path)
│  4. Uruchom launcher-helper │ ← launch_helper(plan)
│  5. Zamknij launcher        │
│                             │
└─────────────────────────────┘
         ↓
┌─────────────────────────────┐
│  LAUNCHER-HELPER            │
│  1. Czeka aż stary launcher│
│     zwolni plik             │
│  2. Backup starego →        │
│     launcher.bak            │
│  3. Kopiuje nowy z staging/ │
│  4. Restart nowego launchera│
│  5. Jeśli błąd → rollback   │
│     z launcher.bak          │
└─────────────────────────────┘
```

---

## 3. Endpoint: launcher-version.php

**URL:** `GET /apik/v1/launcher-version.php?platform={os}`

**Odpowiedź:**
```json
{
  "version": "1.2.0",
  "minVersion": "1.0.0",
  "url": "https://cdn.example.com/launcher/canary-launcher-1.2.0-linux.zip",
  "sha256": "abcdef1234567890...",
  "notes": "Poprawki bezpieczeństwa, nowy ekran ustawień",
  "releaseDate": "2026-03-06T12:00:00Z"
}
```

**Logika wersjonowania:**
- `version > currentVersion` → `UpdateAvailable`
- `currentVersion < minVersion` → `UpdateRequired` (hard block)
- `version == currentVersion` → `UpToDate`

---

## 4. Bezpieczeństwo self-update

| Krok | Zabezpieczenie | Opis |
|------|----------------|------|
| Pobieranie | HTTPS + dev_mode TLS | Paczka pobierana przez szyfrowane połączenie |
| Weryfikacja | SHA-256 hash | `verify_self_update_package()` porównuje hash |
| Staging | Osobny katalog | Nowa binarka trafia do `staging/`, nie nadpisuje starej |
| Podmiana | launcher-helper | Dedykowany process uruchamiany z PID helperProcess |
| Rollback | Backup → `.bak` | Jeśli helper nie może uruchomić nowego → przywraca backup |
| Integralność | Ed25519 (docelowo) | Podpis paczki — weryfikowany przed staging (LR-053) |

### Brakujące (do zrobienia):
- [ ] Ed25519 podpis paczki launchera (nie tylko manifestu klienta)
- [ ] Pinned SHA-256 w launcher-version.php response (serwer authority)
- [ ] Retry logic jeśli download się nie powiedzie

---

## 5. Dlaczego self-update a nie reinstalacja?

| Aspekt | Self-update | Ręczna reinstalacja |
|--------|-------------|---------------------|
| **UX** | Automatyczne, 1 klik | Gracz musi pobrać, rozpakować, skonfigurować |
| **Bezpieczeństwo** | SHA-256 verify + HTTPS | Gracz może pobrać z niezaufanego źródła |
| **Konfiguracja** | Zachowana | Utracona (launcher_config.json nadpisany) |
| **Stan instalacji** | Zachowany (installed_state.json) | Reset |
| **Rollback** | Automatyczny backup | Brak |
| **Dystrybucja** | Kontrolowana (serwer decyduje) | Niekontrolowana |

---

## 6. Scenariusze wersjonowania

### 6.1 Soft update (propozycja)
```
currentVersion: 1.0.0
latestVersion:  1.1.0
minVersion:     0.9.0
→ UpdateAvailable — gracz widzi "Nowa wersja dostępna", może odłożyć
```

### 6.2 Hard update (wymuszenie)
```
currentVersion: 0.8.0
latestVersion:  1.1.0
minVersion:     1.0.0
→ UpdateRequired — launcher blokuje, gracz MUSI zaktualizować
```

### 6.3 Up to date
```
currentVersion: 1.1.0
latestVersion:  1.1.0
→ UpToDate — kontynuuj normalny flow
```

---

## 7. Implementacja w Rust

| Moduł | Plik | Odpowiedzialność |
|-------|------|------------------|
| `self_update.rs` | `crates/launcher-core/src/self_update.rs` (504 linii) | Logika: check version, verify SHA-256, stage, launch helper |
| `commands.rs` | `apps/launcher-tauri/src/commands.rs` | Komendy Tauri: `check_launcher_update`, `perform_self_update` |
| `launcher-helper` | `apps/launcher-helper/` | Binary: czeka → backup → kopiuj → restart → rollback |
| `app.js` | `apps/launcher-tauri/ui/app.js` | Frontend: sekcja Self-Update z przyciskiem |

---

## 8. Podsumowanie

**Self-update jest jedynym wspieranym kanałem dystrybucji poprawek launchera.**

Mechanizm jest w pełni zaimplementowany:
- ✅ `check_launcher_update` — porównanie wersji z API
- ✅ `perform_self_update` — download → SHA-256 verify → stage → helper → restart
- ✅ Helper binary — podmiana + rollback
- ✅ Frontend UI — przycisk + status

Gracz nie musi (i nie powinien) ręcznie reinstalować launchera. Każda poprawka trafia przez `launcher-version.php` → self-update path.
