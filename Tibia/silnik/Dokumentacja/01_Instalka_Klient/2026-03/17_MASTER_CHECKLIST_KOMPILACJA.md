# MASTER CHECKLIST: Dzień Kompilacji 2026-03-07
**Data planu:** 2026-03-06 (noc)  
**Realizacja:** 2026-03-07  
**Autor:** Agent Copilot  
**Równolegle:** Codex agent (osobne plany)

---

## Przegląd dokumentów planowania

| # | Plik | Zakres | Zadań |
|---|---|---|---|
| 10 | `10_PLAN_SERWER_CANARY_74_VS_MODERN.md` | Serwer Canary: konfiguracja, porty, binary, ticket-gate | S-01..S-12 |
| 11 | `11_PLAN_BAZY_DANYCH_SYNC_TRIGGERY.md` | DB: triggery, sync kont, brakujące tabele, routing postaci | DB-01..DB-12 |
| 12 | `12_PLAN_API_ENDPOINTY_POPRAWKI.md` | API: .env, login, context, ticket, dual-world, security | API-01..API-15 |
| 13 | `13_PLAN_KONTO_GLOBALNE_UNIFIED.md` | Konto globalne: flow rejestracja/login, SSO, password sync | ACC-01..ACC-12 |
| 14 | `14_PLAN_LAUNCHER_TAURI_RUST.md` | Launcher: login, UI, self-update, manifest, i18n | LAU-01..LAU-16 |
| 15 | `15_PLAN_INSTALKA_KLIENT_PACZKA.md` | Klient OTClient: paczka gracza, ticket-gate, delta update | INS-01..INS-14 |
| 16 | `16_PLAN_WWW_REDDAXE_I18N.md` | WWW + RedDAXE + i18n: strony, tłumaczenia, dual-server | WWW-01..13, RDX-01..06, I18N-01..05 |
| 07 | `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` | High-level plan dnia + backlog J-* (Codex) | J-CAN..J-COMP |
| 08 | `08_PLAN_INSTALKA_JUTRO_DETALE.md` | Szczegóły instalki (Codex) | J-INS-01..85 |
| 09 | `09_PLAN_INTEGRACJA_LAUNCHER_WWW_CANARY_JUTRO.md` | Integracja E2E (Codex) | INT-P0..P2 |

---

## KOLEJNOŚĆ PRACY NA JUTRO

### Blok 0: Start dnia (08:00)
- [x] Przeczytać ten dokument + dokumenty 10-16
- [x] `mysqldump` backup trzech baz danych (DB-10)
- [x] Sprawdzić stan procesów canary (`ps aux | grep canary`)
- [x] Zabić defunct process (S-12) — brak defunct w momencie audytu

### Blok 1: BAZY DANYCH (krytyczne — fundament) ⏱ ~2h
**Priorytet:** Wszystko zależy od poprawnego sync kont

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 1.1 | Backup wszystkich 3 baz | DB-10 | P0 | 5 min | ✅ ZAKONCZONE (2026-03-06 10:01) |
| 1.2 | Dodać brakujący trigger DELETE canary | DB-01 | P0 | 10 min | ✅ ZAKONCZONE (trigger `acc_sync_ad` istnieje; poprawiono tez `acc_sync_ai/au`) |
| 1.3 | Naprawić rozsynchronizowane konta w canary | DB-03 | P0 | 10 min | ✅ ZAKONCZONE |
| 1.4 | Sync brakujących kont do canary + canary_modern | DB-02, DB-04 | P0 | 15 min | ✅ ZAKONCZONE |
| 1.5 | Sprawdzić schemat accounts (3 bazy) | DB-05 | P0 | 15 min | ✅ ZAKONCZONE |
| 1.6 | Sprawdzić/dodać kolumnę world_id w canaryaac.players | DB-09 | P1 | 10 min | ✅ ZAKONCZONE (obsłużony fallback `players.world`/`players.world_id`, smoke create=modern PASS, 2026-03-06 11:24) |
| 1.7 | Test: INSERT/UPDATE/DELETE → sync działa | T-DB-01..04 | P0 | 20 min | ✅ PASS |
| 1.8 | Stworzenie brakujących engine tables w canary_modern | DB-06 | P1 | 30 min | ✅ ZAKONCZONE (73/73 tabel w obu engine DBs) |

### Blok 2: API — naprawić .env i kluczowe endpointy ⏱ ~2h
**Priorytet:** API musi poprawnie obsługiwać 2 serwery

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 2.1 | Naprawić ENGINE_DB_NAME w .env (canaryaac→canary) | API-01 | P0 | 5 min | ✅ ZAKONCZONE (runtime + repo env) |
| 2.2 | Dodać ENGINE_MODERN_DB_* do .env | API-01 | P0 | 5 min | ✅ ZAKONCZONE (runtime + repo env) |
| 2.3 | MULTI_WORLD=true | API-02 | P0 | 2 min | ✅ ZAKONCZONE (runtime + repo env) |
| 2.4 | Dual PDO helper w common.php | API-06 | P0 | 20 min | ✅ ZAKONCZONE |
| 2.5 | Weryfikacja login.php dual-world | API-03 | P0 | 30 min | ✅ ZAKONCZONE (fix filtrowania postaci per world) |
| 2.6 | Weryfikacja account-context.php | API-04 | P0 | 30 min | ✅ ZAKONCZONE |
| 2.7 | Weryfikacja ticket.php world mismatch | API-05 | P0 | 20 min | ✅ ZAKONCZONE (HTTP 403) |
| 2.8 | Test: login (all/classic74/modern) | T-API-01..03 | P0 | 15 min | ✅ PASS |

### Blok 3: SERWER CANARY — konfiguracja ⏱ ~1h
**Priorytet:** Oba serwery muszą działać poprawnie

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 3.1 | Ujednolicić serverName | S-01 | P0 | 5 min | ✅ ZAKONCZONE |
| 3.2 | Zdecydować: 1 binary 2 configi vs 2 osobne | S-03, S-04 | P0 | 15 min | 🔄 W TRAKCIE (binary+symlink gotowe, decyzja pipeline otwarta) |
| 3.3 | Symlink/kopia data-otservbr-global dla modern | S-06 | P0 | 10 min | ✅ ZAKONCZONE |
| 3.4 | Weryfikacja ticketSecret spójności | S-09 | P1 | 10 min | ✅ ZAKONCZONE |
| 3.5 | Test: oba serwery przyjmują połączenia | T-S-01..02 | P0 | 15 min | ✅ PASS (2026-03-06 10:25) |

### Blok 4: KONTA + SSO ⏱ ~2h
**Priorytet:** Jedno konto, wiele frontendów

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 4.1 | Test rejestracji API + sync triggery | ACC-01 | P0 | 20 min | ✅ PASS (2026-03-07) — register→canaryaac→triggers→canary+canary_modern, ID preserved |
| 4.2 | Weryfikacja engine_password_sha1 | ACC-02 | P0 | 20 min | ✅ PASS (2026-03-07) — SHA1 w password+engine_password_sha1, Argon2→SHA1 fix (14 kont), MyAAC create/change-pwd/lost also fixed |
| 4.3 | Test account-sync-www-token flow | ACC-03, ACC-04 | P0 | 30 min | ✅ PASS (2026-03-07) — SSO E2E: launch_token→login→sync_token→consume→PHPSESSID→loginStatus=true. Web login OK (ptakukolo + test_acc01) |
| 4.4 | Stworzyć sync-login.php na WWW | ACC-05, WWW-05 | P0 | 30 min | ✅ ZAKONCZONE (2026-03-07) — 3 bugi naprawione: session_name→PHPSESSID, session keys→myaac_ prefix, save_path fix |
| 4.5 | WWW create character z wyborem serwera | ACC-07, WWW-02 | P0 | 30 min | ✅ PASS (2026-03-07) — radio Classic/Modern, world=0/1 w DB, E2E: Test Klasyk(w=0) + Test Modernowy(w=1) |

### Blok 5: WWW + RedDAXE ⏱ ~2h
**Priorytet:** Strona musi wyglądać i działać

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 5.1 | Audit i18n stron (szukanie EN text) | WWW-01 | P0 | 30 min | ✅ ZAKONCZONE (2026-03-07) — 9 stron przeskanowanych, 5 szablonów (characters/spells/serverinfo/exp_table/team) przetłumaczonych, lost.php (69 stringów), account templates (22+), pl.json +72 klucze |
| 5.2 | Account management — postacie per serwer | WWW-03 | P0 | 30 min | ✅ ZAKONCZONE (2026-03-06) |
| 5.3 | Login box wizualny check | WWW-04 | P0 | 15 min | ✅ ZAKONCZONE (2026-03-06) |
| 5.4 | RedDAXE — rejestracja przez API | RDX-01 | P0 | 20 min | ✅ ZAKONCZONE (2026-03-06) |
| 5.5 | RedDAXE — login przez API | RDX-02 | P0 | 15 min | ✅ ZAKONCZONE (2026-03-06) |
| 5.6 | Downloads — link do paczki launchera | WWW-09 | P1 | 15 min | ✅ ZAKONCZONE (2026-03-06) |
| 5.7 | Highscores dual-server + topka czasu online (3 tryby) | WWW-06 | P1 | 30 min | ✅ ZAKONCZONE (2026-03-06 11:35) |
| 5.8 | Online dual-server (3 tryby + summary + world) | WWW-07 | P1 | 25 min | ✅ ZAKONCZONE (2026-03-06 11:52) — `/online?mode=all/classic74/modern` + licznik `Classic/Modern/Total` |
| 5.9 | Persist wyboru serwera w sesji | WWW-08 | P1 | 20 min | ✅ ZAKONCZONE (2026-03-06 11:56) — `server_mode` dla `/online` i `/highscores` + fallback bez `mode` |
| 5.10 | i18n hardening tekstów user-visible (online/highscores) | WWW-11 | P1 | 25 min | ✅ ZAKONCZONE (2026-03-06 12:01) — record label, PvP/server-datetime, outfit alt, onlinetime units, `Unknown` fallback |
| 5.11 | i18n hardening `account.login` + `account.management` | WWW-11 | P1 | 35 min | ✅ ZAKONCZONE (2026-03-06 12:06) — hardcoded EN -> locale keys (`pl/en`) dla etykiet, sekcji, tabel i komunikatów |

### Blok 6: LAUNCHER ⏱ ~1.5h
**Priorytet:** Launcher musi logować, pokazywać serwery, starować grę

| # | Zadanie | Plik planu | Priorytet | Czas | Status |
|---|---|---|---|---|---|
| 6.1 | Zsynchronizować wersje Cargo/env | LAU-01 | P0 | 10 min | ✅ ZAKONCZONE (2026-03-06) |
| 6.2 | Weryfikacja login flow | LAU-02 | P0 | 20 min | ✅ CODE REVIEW PASS (2026-03-07) — login.php call + sessionkey extraction gotowe w commands.rs |
| 6.3 | Weryfikacja account-context w UI | LAU-04 | P0 | 20 min | ✅ CODE REVIEW PASS (2026-03-07) — worlds+characters z login response |
| 6.4 | "Utwórz postać" → browser SSO | LAU-05 | P0 | 20 min | ✅ CODE REVIEW PASS (2026-03-07) — account-sync-token.php → browser URL |
| 6.5 | "GRAJ" → ticket → start klienta | LAU-06 | P0 | 20 min | ✅ CODE REVIEW PASS (2026-03-07) — launcher-token.php → OTC_LAUNCH_TOKEN env |

### Blok 7: GATE PRE-KOMPILACJA ⏱ ~1h
**Sprawdzenie gotowości do kompilacji**

| # | Gate | Warunek | Status |
|---|---|---|---|
| G1 | DB sync działa | T-DB-01..07 PASS | ✅ (2026-03-07) — INSERT/UPDATE/DELETE sync OK, 19/19/19 kont |
| G2 | API login dual-world | T-API-01..03 PASS | ✅ |
| G3 | Ticket validation | T-API-05..06 PASS | ✅ |
| G4 | Oba serwery online | T-S-01..02 PASS | ✅ |
| G5 | Konto globalne E2E | T-ACC-01..05 PASS | ✅ (2026-03-07) — register+login+SSO+sync E2E PASS |
| G6 | Tworzenie postaci per serwer | T-ACC-06..07 PASS | ✅ (2026-03-07) — Classic w=0, Modern w=1 |
| G7 | WWW login + manage | T-WWW-01..05 PASS | ✅ (2026-03-07) — login OK, manage per-server OK |
| G8 | .env spójne z config.lua | API-01, S-09 | ✅ |
| G9 | Brak sekretów w paczce | INS-02 | ✅ (2026-03-07) — no .env, .key, .secret in client pack |
| G10 | Wersje spójne (Cargo/env/manifest) | LAU-01 | ✅ |

### Blok 8: KOMPILACJA (jeśli gate'y przejdą) ⏱ ~2h+
| # | Artefakt | Workflow |
|---|---|---|
| 8.1 | Serwer Canary Linux | build-ubuntusr.yml |
| 8.2 | Serwer Canary Windows | build-windowssr.yml |
| 8.3 | OTClient dev | build-windows.yml |
| 8.4 | OTClient paczka gracza | build-client-package.yml |
| 8.5 | Launcher CLI + Tauri | build-launcher.yml |

---

## Podsumowanie zadań — ŁĄCZNIE

| Priorytet | Ile zadań | Czego dotyczą |
|---|---|---|
| P0 (blokuje kompilację) | ~35 | DB sync, API dual-world, login, ticket, konto, serwer config |
| P1 (przed RC) | ~30 | Highscores, online, i18n audit, launcher UX, repair, rules |
| P2 (po pierwszym buildzie) | ~20 | FAQ, AV compatibility, rotation secrets, backlog |

---

## Kluczowe BUGI do naprawienia PIERWSZEGO

1. ✅ **`.env ENGINE_DB_NAME=canaryaac`** — naprawione na `canary`
2. ✅ **`.env MULTI_WORLD=false`** — naprawione na `true`
3. ✅ **Brak triggera `acc_sync_ad` (DELETE → canary)** — trigger istnieje i dziala
4. ✅ **Rozjazd kont** canary: id=3 "migrated_3", id=6 "proelo" — naprawione (sync po `id`)
5. ✅ **Brak `ENGINE_MODERN_DB_*`** w .env — dodane
6. ✅ **Wersja Cargo 0.1.0 vs .env 1.0.0** — domkniete (workspace + tauri + UI/API na 1.0.0)

---

## Architektura systemu — diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   GRACZ     │     │   GRACZ     │     │   GRACZ     │
│  (browser)  │     │ (launcher)  │     │  (klient)   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │ HTTPS :443        │ HTTPS :443        │ TCP :7171-7174
       │                   │                   │
┌──────▼──────────────────▼──────┐     ┌──────▼──────────┐
│         NGINX (reverse proxy)   │     │  Canary Server  │
│  ┌──────────┐ ┌──────────────┐ │     │  ┌──────────┐   │
│  │ WWW Tibia│ │ API /apik/v1/│ │     │  │Classic7.4│   │
│  │(CanaryAAC│ │  30 endpoints│ │     │  │:7171/7172│   │
│  │+ RedDAXE)│ │              │ │     │  ├──────────┤   │
│  └──────────┘ └──────────────┘ │     │  │ Modern   │   │
└─────────────┬──────────────────┘     │  │:7173/7174│   │
              │                        │  └──────────┘   │
              │ MySQL :3306            └────────┬────────┘
              │                                 │
     ┌────────▼─────────────────────────────────▼────────┐
     │                    MySQL                           │
     │  ┌─────────────┐  ┌──────────┐  ┌──────────────┐ │
     │  │ canaryaac   │  │ canary   │  │canary_modern │ │
     │  │ (109 tabel) │→→│(73 tabel)│  │ (47 tabel)   │ │
     │  │ MASTER      │→→│ engine74 │  │ engine_mod   │ │
     │  └─────────────┘  └──────────┘  └──────────────┘ │
     │       │ trigger sync                              │
     │       └─────────────→→→→→→→→→→→→→→→→→┘           │
     └───────────────────────────────────────────────────┘
```

---

## Notatki dla Codexa

Codex pracuje równolegle. Jego plany (07, 08, 09) są komplementarne do moich (10-16):
- **07** = harmonogram dnia + backlog J-*
- **08** = szczegóły instalki (J-INS-01..85)
- **09** = integracja E2E (INT-P0..P2)
- **10** = konkretne config/pliki serwera Canary
- **11** = konkretne SQL triggery/sync + brakujące tabele
- **12** = konkretne endpointy API + poprawki .env
- **13** = flow konta globalnego + diagramy + SSO
- **14** = konkretna struktura kodu launchera + zadania
- **15** = paczka klienta/gracza + manifest + ticket-gate flow
- **16** = WWW + RedDAXE strony + i18n audit
- **17** (ten dokument) = master checklist + kolejność pracy

Brak duplikacji — moje pliki mają konkretne ścieżki plików, SQL-e i komendy; Codex ma high-level flow i gating.
