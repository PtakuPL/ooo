# Migration & Rollout Plan: Rust Launcher

**LR-057..060** — Etap 6 (Migracja i rollout)  
**Data:** 2026-03-03  
**Status:** Planowanie

---

## Faza M1: Parytet Rust vs Python (LR-057)

### Cel
Potwierdzenie, że Rust launcher zachowuje identyczne zachowanie co Python launcher.

### Macierz parytetu

| Funkcja | Python Launcher | Rust Launcher | Status |
|---------|----------------|---------------|--------|
| Pobranie manifestu (`update.php`) | ✅ | ✅ `fetch_manifest()` | Parytet |
| Parsowanie manifest v1 | ✅ | ✅ `parse_manifest_compat()` | Parytet |
| Parsowanie manifest v2 | N/A | ✅ native | Rozszerzenie |
| Skan plików lokalnych + SHA-256 | ✅ | ✅ `file_index` | Parytet |
| `filesHash` computation | ✅ | ✅ `compute_files_hash()` | **KRYTYCZNE** |
| Launch-token request | ✅ | ✅ `request_launch_token()` | Parytet |
| Start klienta z `OTC_LAUNCH_TOKEN` | ✅ | ✅ `process_runner` | Parytet |
| Download z retry | ✅ | ✅ `download_file()` | Parytet |
| Weryfikacja SHA-256 po downloanzie | ✅ | ✅ `integrity` | Parytet |
| Progress reporting | ✅ (stdout) | ✅ (Tauri events) | UI różnica |
| Error codes | Brak standardu | ✅ `LCH_*` | Rozszerzenie |
| Rollback/recovery | Brak | ✅ `patcher + state` | Rozszerzenie |
| Self-update | Brak | ✅ `self_update + helper` | Rozszerzenie |
| Server list sync | Brak | ✅ `serverlist_sync` | Rozszerzenie |
| Config file (`launcher_config.json`) | Brak | ✅ `LauncherConfig` | Rozszerzenie |

### Testy parytetu

1. **filesHash agreement** — porównanie hash z Rust vs Python na tym samym zestawie plików.
2. **Token request parity** — ten sam payload, ten sam response (lub ten sam error).
3. **Manifest parse agreement** — Rust `NormalizedManifest` z v1 JSON odpowiada temu co Python parsuje.

### Narzędzie weryfikacji

```bash
# Python reference
python3 launcher.py --check-only --channel stable > python_result.json

# Rust reference  
launcher-cli check --channel stable --json > rust_result.json

# Porównanie
diff <(jq -S . python_result.json) <(jq -S . rust_result.json)
```

---

## Faza M2: Kanał testowy Rust launcher (LR-058)

### Konfiguracja kanałów

| Kanał | Launcher | Cel |
|-------|----------|-----|
| `dev` | Rust | Wewnętrzne testy deweloperskie |
| `test` | Rust | Testy QA, ograniczona grupa użytkowników |
| `stable` | Python (fallback) | Produkcja — dotychczasowy launcher |

### Rollout config (`rollout_config.json`)

```json
{
  "version": "1.0.0",
  "updatedAt": "2026-03-03T12:00:00Z",
  "channels": {
    "dev": {
      "launcher": "rust",
      "minLauncherVersion": "0.1.0",
      "enabled": true
    },
    "test": {
      "launcher": "rust",
      "minLauncherVersion": "0.1.0",
      "enabled": true,
      "allowlist": ["tester1", "tester2"]
    },
    "stable": {
      "launcher": "python",
      "fallbackToRust": false,
      "enabled": true
    }
  }
}
```

### Kryteria przejścia M2 → M3

1. ✅ Rust launcher na `dev` przez 7 dni bez krytycznych błędów.
2. ✅ Rust launcher na `test` przez 14 dni z grupą beta testerów.
3. ✅ `filesHash` parity 100% potwierdzone.
4. ✅ Token acceptance rate ≥99.5% na `test`.
5. ✅ Zero rollbacków z powodu buga launchera.

---

## Faza M3: Soft rollout (LR-059)

### Stopniowe włączanie

| Dzień | % użytkowników na Rust | Kanał |
|-------|----------------------|-------|
| D+0 | 0% | stable = Python |
| D+1 | 5% | A/B: 5% Rust |
| D+3 | 10% | Monitoring |
| D+7 | 25% | Checkpoint |
| D+14 | 50% | Midpoint |
| D+21 | 75% | Pre-full |
| D+28 | 100% | Full rollout (M4) |

### Mechanizm A/B

```json
{
  "stable": {
    "launcher": "rust",
    "rolloutPercentage": 25,
    "rolloutSeed": "user_id_hash_mod_100",
    "fallbackLauncher": "python",
    "autoRollbackThreshold": {
      "tokenRejectRate": 0.05,
      "updateFailRate": 0.10
    }
  }
}
```

### Warunki auto-rollback

- Token rejection rate > 5% w 1-godzinnym oknie → auto-rollback do Python.
- Update failure rate > 10% → auto-rollback.
- Brak heartbeat z dashboardu > 15 min → pause rollout.

### Monitoring w trakcie M3

- Dashboard z telemetrii (LR-054, LR-055).
- Alerty na Slacku/Discordzie.
- Ręczny checkpoint co 7 dni.

---

## Faza M4: Full rollout (LR-060)

### Konfiguracja finalna

```json
{
  "stable": {
    "launcher": "rust",
    "rolloutPercentage": 100,
    "minLauncherVersion": "1.0.0",
    "pythonFallbackEnabled": true,
    "pythonFallbackEndDate": "2026-06-01T00:00:00Z"
  }
}
```

### Python launcher jako fallback

1. Python launcher **nie jest usuwany** z dystrybucji.
2. Dostępny jako `launcher-legacy.py` lub osobny download.
3. Fallback aktywny przez **90 dni** po full rollout.
4. Po 90 dniach: deprecacja, Python launcher = "unsupported".

### Kryteria sukcesu M4

1. Token acceptance rate ≥99.9% przez 30 dni.
2. Zero krytycznych bugów (P0) przez 30 dni.
3. Self-update chain works (v1.0 → v1.1 → ...).
4. Rollback procedura przetestowana (drill).

---

## Timeline

```
Mar 2026: M1 — parity verification + internal testing
Apr 2026: M2 — test channel deployment
May 2026: M3 — soft rollout (5% → 100%)
Jun 2026: M4 — full rollout, Python fallback (90 dni)
Sep 2026: Python launcher deprecation
```
