# Historia poprawek i nieudanych kompilacji

Data utworzenia: 2026-03-22  
Branch: `feature/ticket-gate`  
Repo: `PtakuPL/ooo`

> Ten plik dokumentuje KAŻDĄ próbę kompilacji — zarówno udaną jak i nieudaną.
> Dla każdego błędu: dokładna diagnoza, plik, linia, poprawka, commit.

---

## Format wpisów

```
### [DATA] [WORKFLOW] — [PASS/FAIL]
- **GHA Run**: #ID / URL
- **Branch**: feature/ticket-gate @ commit HASH
- **Czas**: X min
- **Wynik**: PASS / FAIL

#### Błędy (jeśli FAIL):
1. **[PLIK:LINIA]** — opis błędu
   - Komunikat: `...`
   - Diagnoza: ...
   - Poprawka: ... (commit HASH)
   
#### Artefakty (jeśli PASS):
- `nazwa-artefaktu` — rozmiar, SHA256
```

---

## Próby kompilacji

### Poprzednie udane kompilacje (historia)
- **GHA #22717070014** — Canary Linux (commit `652c0e033`) — ✅ PASS
  - Ubuntu 22.04 + 24.04, linux-release + linux-debug: wszystkie 4 warianty PASS
  - Artefakt serwera Canary dostępny i przetestowany

---

### [2026-03-22] Przygotowanie do kompilacji
- ⬜ Oczekuje na push kodu do `feature/ticket-gate`
- Zmiany od ostatniej kompilacji:
  - ticket_validator.cpp/hpp — nonce replay + worldId check
  - protocolgame.cpp — feature flags D2-D10
  - httplogin.cpp — TLS hard-fail, usunięcie HTTP fallback
  - Lua: entergame.lua, serverlist.lua, characterlist.lua, init.lua
  - 20+ plików PHP API (login, ticket, account-context, etc.)
  - 12 migracji SQL
  - Launcher Rust — 33 komend, session store, i18n
  - Workflows GHA — build-canary, build-linux, build-windows, build-client-package, build-launcher

---

<!-- NOWE WPISY PONIŻEJ -->
