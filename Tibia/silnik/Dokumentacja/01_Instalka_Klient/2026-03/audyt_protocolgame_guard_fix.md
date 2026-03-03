# Audyt protocolgame.cpp — Naprawa guardów D2-D10

**Data:** 2025-06-18  
**Commit:** `365fe958b` (FIX-GUARDS)  
**Branch:** `feature/ticket-gate`

## Problem

Commit `dfe1a8784` (GUARD-FIX + X8 + CFG-KEY) miał naprawić guardy Classic 7.4 w `protocolgame.cpp`, ale sam wprowadził **11 błędów kompilacji** — korupcja kodu, zgubione definicje funkcji, guardy w złych miejscach.

## Znalezione i naprawione błędy

### Korupcja kodu (D2)
1. **parseUseItem** — usunięte deklaracje zmiennych `pos`, `itemId`, `stackpos`, `index`
2. **parseUseItemEx** — tekst komentarza wklejony do kodu: `Position fromPos =from-hotkey for Classic 7.4`
3. **parseUseWithCreature** — definicja funkcji scalona z parseUseItemEx (brak nagłówka)

### Guardy w złych miejscach
4. **parseBestiarySendCreatures** — D5 Prey wstawiony wewnątrz pętli for (zamiast `if (_it.first == raceid_)`)
5. **parsePreyAction** — D5 Prey wewnątrz łańcucha if-else (zamiast na początku funkcji)
6. **parseSendResourceBalance** — definicja funkcji scalona z osieroconym blokiem D4 Market
7. **parseMarketLeave** — brak D4 Market guard
8. **parseMarketBrowse** — duplikat D4 Market guard
9. **sendHighscores** — D10 Bestiary guard wstawiony tutaj (blokował highscores, nie bestiary)
10. **parseRuleViolationReport** — D10 Bestiary guard wewnątrz warunku (łamał raportowanie)
11. **sendBestiaryCharms** — D10 Bestiary guard wewnątrz else-block (łamał logikę charmów)

### Brakujące guardy
- **D3 Quick Loot** w `parseQuickLootBlackWhitelist` — brak
- **D10 Bestiary** w `parseBestiarySendRaces` — brak
- **D10 Bestiary** w `parseBestiarysendMonsterData` — brak
- **D10 Bestiary** w `parseBestiarySendCreatures` — brak

## Stan po naprawie

| Metryka | Wartość |
|---------|---------|
| Guardy `isClassic74Blocked()` w canary_test | **18** |
| Guardy `isClassic74Blocked()` w canary/ (referencja) | **18** |
| Parytet | ✅ 100% |

## Audyt pozostałych plików C++ (brak błędów)

- `ticket_validator.cpp/hpp` — HMAC-SHA256, nonce, constant-time compare ✅
- `configmanager.cpp` + `config_enums.hpp` — 5 kluczy ticketGate ✅
- `config.lua.dist` — wpisy ticket-gate ✅
- `player.hpp` — PlayerGameMode_t enum, isClassic74() ✅
- `protocolgame.hpp` — pendingGameMode_, forward-decl ✅
- `CMakeLists.txt` — ticket_validator.cpp w build, OpenSSL linked ✅
- `vcpkg.json` — openssl dodany ✅

## Audyt klienta testyy/ (brak błędów)

- `httplogin.cpp/h` — TLS, launchToken, gameMode, requestTicket, brak HTTP fallback ✅
- `luafunctions.cpp` — bindingi setLaunchToken, setGameMode, requestTicket ✅
- `entergame.lua` — CLIENT_LOCKED, GameModes, ticket flow ✅
- `characterlist.lua` — requestTicket integracja ✅

## Następne kroki

Kompilacja na GHA potwierdzi brak dalszych błędów. Nie pushujemy do czasu polecenia użytkownika.
