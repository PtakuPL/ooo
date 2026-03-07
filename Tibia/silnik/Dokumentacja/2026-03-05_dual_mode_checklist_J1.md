# J1 — Checklista dual-mode: Classic 7.4 vs Modern

**Data:** 2026-03-06  
**Gałąź:** `feature/ticket-gate`  
**Status:** Do weryfikacji na demo

---

## 1. Mapa różnic zachowań

| Funkcja | Classic 7.4 | Modern 14.20+ | Warstwa egzekucji |
|---------|-------------|---------------|---------------------|
| **Hotkey na itemy/runy** | ❌ Zablokowane | ✅ Dozwolone | Klient (`init.lua` → `hotkeys_items=false`) + Serwer (`isClassic74Blocked()`) |
| **Hotkey na spelle** | ✅ Dozwolone | ✅ Dozwolone | — |
| **Quick Loot** | ❌ Wyłączone | ✅ Włączone | Klient (`quick_loot=false`) + Serwer guard |
| **Auto Loot** | ❌ Wyłączone | ✅ Włączone | Klient (`auto_loot=false`) + Serwer guard |
| **Market** | ❌ Wyłączony | ✅ Włączony | Klient (`market=false`) + Serwer (`parseMarketLeave/Browse/Create/Cancel/Accept`) |
| **Action Bar** | ❌ Ukryty | ✅ Widoczny | Klient (`action_bar=false`) |
| **Smart Equip** (Ctrl+click) | ❌ Wyłączone | ✅ Włączone | Klient (`smart_equip=false`) + Serwer guard |
| **Prey System** | ❌ Ukryty | ✅ Dostępny | Klient (`prey=false`) + Serwer guard |
| **Bestiary** | ❌ Ukryty | ✅ Dostępny | Klient (`bestiary=false`) + Serwer guard |
| **Wheel of Destiny** | ❌ Ukryty | ✅ Dostępny | Klient (`wheel=false`) + Serwer guard |
| **Analytics** | ❌ Wyłączony | ✅ Włączony | Klient (`analytics=false`) |
| **Rune z hotkeya (server hard-block)** | ❌ Blokada serwera (fromPos 0xFFFF + isRune) | ✅ Dozwolone | Serwer (`protocolgame.cpp` — UseItemEx + UseWithCreature) |
| **Lista serwerów** | Wyłącznie serwer Classic | Wyłącznie serwer Modern | Klient (`GameModes` w `init.lua`) |
| **Dodawanie serwerów** | ❌ Zablokowane (CLIENT_LOCKED=true) | ❌ Zablokowane | Klient (serverlist.lua) |

---

## 2. Warstwowy model egzekucji

```
┌──────────────────────────┐
│   KLIENT (init.lua)      │  Warstwa UX — feature flags ukrywają UI
│   isFeatureEnabled()     │  Obchodzenie: modyfikacja init.lua
│   CLIENT_LOCKED=true     │
├──────────────────────────┤
│   SERWER (protocolgame)  │  Warstwa TWARDA — isClassic74Blocked()
│   18 guardów w C++       │  NIE do obejścia bez kodu serwera
│   + rune hard-block      │
├──────────────────────────┤
│   TICKET-GATE (HMAC)     │  Warstwa KRYPTO — gameMode w tickecie
│   Tryb zapisany w sesji  │  player.setGameMode() przy loginie
│   player.isClassic74()   │
└──────────────────────────┘
```

### Kluczowa zasada: **klient sugeruje, serwer egzekwuje**

Nawet jeśli gracz zmodyfikuje `init.lua` i włączy `hotkeys_items=true` w trybie Classic 7.4:
- Serwer nadal sprawdzi `isClassic74()` i zablokuje rune z hotkeya
- Serwer nadal zablokuje Market, Quick Loot, Prey itd.
- Ticket-gate gwarantuje, że tryb gry (`gameMode`) jest kryptograficznie podpisany

---

## 3. Pliki implementacji — stan

### Klient (Lua)

| Plik | Status | Opis |
|------|--------|------|
| `init.lua` | ✅ | GameModes, features, `isFeatureEnabled()`, CLIENT_LOCKED |
| `modules/game_hotkeys/hotkeys_manager.lua` | ✅ | `isFeatureEnabled("hotkeys_items")` check w hotkey execution |
| `modules/game_interface/gameinterface.lua` | ✅ | Feature flags dla UI paneli |
| `modules/client_entergame/entergame.lua` | ✅ | Ekran wyboru trybu + lista serwerów z GameModes |
| `modules/game_market/market.lua` | ✅ | `isFeatureEnabled("market")` guard |

### Serwer (C++)

| Plik | Status | Opis |
|------|--------|------|
| `player.hpp` | ✅ | `PlayerGameMode_t` enum, `gameMode_` field, `isClassic74()` getter |
| `protocolgame.hpp` | ✅ | `pendingGameMode_`, `isClassic74Blocked()` helper |
| `protocolgame.cpp` | 🟠 | 18 guardów — **canary_test/ ma problemy z pozycjonowaniem** (audit wykazał osierocone guardy) |
| `protocolgame.cpp` (canary/) | ✅ | Guardy poprawnie wewnątrz funkcji |

### API (PHP)

| Plik | Status | Opis |
|------|--------|------|
| `login.php` | ✅ | Wydaje ticket z `gameMode` zaszyfrowanym w HMAC |
| `ticket.php` | ✅ | Weryfikuje HMAC i zwraca `GameMode` do serwera |

---

## 4. Checklista weryfikacji (test na demo)

### A. Uruchomienie dwóch sesji

- [ ] **A1** Start launcher → wybór trybu Classic 7.4 → połączenie z serwerem
- [ ] **A2** Start launcher → wybór trybu Modern → połączenie z serwerem (druga instancja klienta)
- [ ] **A3** Obie sesje działają jednocześnie na tym samym serwerze Canary

### B. Różnica zasad widoczna na ekranie

- [ ] **B1** Classic 7.4: próba użycia runy z hotkeya → komunikat "Uzycie run z hotkeya nie jest dostepne w trybie Classic 7.4."
- [ ] **B2** Modern: użycie runy z hotkeya → działa normalnie
- [ ] **B3** Classic 7.4: panel Market niedostępny (przycisk ukryty lub wyszarzony)
- [ ] **B4** Modern: panel Market otwarty i funkcjonalny
- [ ] **B5** Classic 7.4: Quick Loot wyłączony (element UI ukryty)
- [ ] **B6** Modern: Quick Loot działa

### C. Bezpieczeństwo — nie da się obejść client-side

- [ ] **C1** Zmodyfikowany init.lua (features.hotkeys_items=true w Classic) → serwer nadal blokuje rune z hotkeya
- [ ] **C2** Bezpośredni login bez launchera (brak launch-token) → login.php odrzuca (lub ostrzega)
- [ ] **C3** Ticket z gameMode=modern na sesji Classic → serwer odrzuca mismatch

### D. Integralność plików

- [ ] **D1** Modyfikacja init.lua → launcher wykrywa zmieniony hash przy następnym check
- [ ] **D2** Repair → launcher przywraca oryginalny init.lua

### E. Self-update

- [ ] **E1** Zmiana wersji na serwerze → launcher pobiera nowe pliki
- [ ] **E2** Po aktualizacji klient działa poprawnie w obu trybach

---

## 5. Znane problemy / ryzyka

| # | Problem | Priorytet | Status |
|---|---------|-----------|--------|
| 1 | Guardy C++ w `canary_test/protocolgame.cpp` — osierocone (poza metodami) | 🔴 Wysoki | Zidentyfikowany, wymaga poprawki (audit w Dokumentacja) |
| 2 | `canary/` (referencyjna kopia) ma guardy poprawne — trzeba zmergować do canary_test/ | 🟠 Średni | Do wykonania |
| 3 | `isFeatureEnabled()` domyślnie zwraca `true` gdy brak trybu — gracz bez trybu ma pełne flagi | 🟡 Niski | Design decision: domyślnie modern |
| 4 | Challenge-response walidacja IP nie działa za NAT/proxy | 🟡 Niski | Znany limit — akceptujemy |

---

## 6. Podsumowanie

**Dual-mode jest zaimplementowany w pełnym three-layer stack:**
1. **Klient** — feature flags w `init.lua` + `isFeatureEnabled()` w modułach Lua
2. **API** — login.php zaszywa `gameMode` w tickecie HMAC
3. **Serwer** — 18 guardów `isClassic74Blocked()` + hard-block na rune z hotkeya

**Brakujące na demo:**
- Fix guardów C++ w canary_test/ (osierocone pozycje)
- Build + deployment gotowej paczki z GHA
- Test E2E na faktycznej paczce Windows
