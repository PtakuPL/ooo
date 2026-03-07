# J6 — Rejestr otwartych bugów instalatora/UI launchera

**Data:** 2026-03-06  
**Ownerzy:** Copilot + Codex  
**Źródło:** testy D1..D5, audyt kodu, dokumentacja

---

## Podsumowanie

| Priorytet | Otwarte | Naprawione | Razem |
|-----------|---------|------------|-------|
| 🔴 critical | 2 | 6 | 8 |
| 🟠 high | 2 | 12 | 14 |
| 🟡 medium | 2 | 10 | 12 |
| 🔵 low | 2 | 6 | 8 |
| **Razem** | **8** | **34** | **42** |

---

## Otwarte bugi

| ID | Obszar | Krok | Severity | Objaw | Expected | Actual | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| B-001 | Security/TLS | D1 | critical | Klient OTClient nie weryfikuje cert SSL | Cert chain sprawdzony, self-signed odrzucony | Cert verify wyłączone, MITM możliwy | Copilot | open |
| B-002 | Security/TLS | D1 | critical | HTTP fallback po HTTPS failure | HTTPS-only, brak fallback | Downgrade do HTTP, dane logowania plain-text | Copilot | open |
| B-003 | Security/TLS | D1 | high | Emscripten (WebGL) ma ten sam HTTP fallback | Brak fallback w przeglądarce | HTTP downgrade w WebGL build | Copilot | open |
| B-004 | Launcher/Crypto | D4 | high | Ed25519 placeholder w manifest_signature.rs | Prawdziwe Ed25519 verify | HMAC-SHA256 zamiast Ed25519 | Copilot | open |
| B-005 | Klient/Feature flags | D3 | medium | `isFeatureEnabled()` domyślnie true | Nieznana flaga = false (bezpieczne) | Nieznana flaga = true (modern all-enabled) | Copilot | open |
| B-006 | API/Security | D2 | medium | Brak rate-limit na `/ticket.php` | Jawny rate_limit_check() | Brak, domyślny PHP/nginx limit | Copilot | open |
| B-007 | Klient/Code quality | — | low | Dead code: `loginHttpJson()` nigdy nie wywołane | Usunięte lub oznaczone | Martwy kod w build | Codex | open |
| B-008 | Build/Docs | — | low | Flagi MSVC `/d2SSAOptimizer-` bez komentarza w CMake | Komentarz inline | Brak komentarza (tylko w osobnym doc) | Codex | open |

---

## Pliki z bugami

| ID | Plik | Linia |
|---|------|-------|
| B-001 | `canary_test/src/client/network/http/httplogin.cpp` | 215 |
| B-002 | `canary_test/src/client/network/http/httplogin.cpp` | 108 |
| B-003 | `canary_test/src/client/network/http/httplogin.cpp` | ~170 |
| B-004 | `launcher-rust/crates/launcher-core/src/manifest_signature.rs` | 165 |
| B-005 | `canary_test/testyy/init.lua` | 89 |
| B-006 | `/var/www/html/apik/v1/ticket.php` | — |
| B-007 | `canary_test/src/framework/net/httplogin.cpp` | 236 |
| B-008 | `canary/CMakeLists.txt` | flagi kompilacji |

---

## Proponowane priorytety naprawy

1. **B-001 + B-002** (TLS) — krytyczne dla bezpieczeństwa, ale w zamkniętej sieci dev akceptowalne ryzyko
2. **B-004** (Ed25519) — flow gotowy, trzeba podmienić placeholder na `ed25519-dalek` crate
3. **B-006** (rate-limit ticket) — szybka zmiana, dodać `rate_limit_check()` z `common.php`
4. **B-005** (feature flags default) — design decision, wymaga dyskusji
5. **B-003** (Emscripten) — analogiczne do B-002, fix w tym samym pliku
6. **B-007, B-008** — cleanup, niski priorytet

---

## Definicja pól

1. `Severity`: `critical`, `high`, `medium`, `low`.
2. `Owner`: `Copilot` lub `Codex`.
3. `Status`: `open`, `in_progress`, `fixed`, `verified`, `wontfix`.

---

*Ostatnia aktualizacja: 2026-03-06, Copilot*
